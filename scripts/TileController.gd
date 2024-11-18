extends Control

const network_type = ["GSM","UMTS","HSPA","LTE","NR"]
const sqrt3 = 1.732

var allowed_freq_pattern = [3,4,7,12]

var arc_len = 150
var current_freq_pattern_idnex = 0
var total_channel_number = 24
var station_number = 0

var tile_color_dict = {"blue":Color8(173,216,230),"green":Color8(152,251,152), 
"red":Color8(180,248,245), "yellow":Color8(255,255,224), "purple":Color8(230,230,250),
"mint_mist":Color8(230,255,230),"gray":Color8(211,211,211), "cyan": Color8(224,255,255),
"coral":Color8(250,209,175),"gold": Color8(240,230,140),"violet":Color8(198,164,232),
"lavender":Color8(255,240,245)}

var tile_color_list = [Color8(173,216,230),Color8(152,251,152), 
Color8(255,182,193), Color8(255,255,224),Color8(230,230,250), 
Color8(230,255,230), Color8(211,211,211),Color8(224,255,255),
Color8(250,209,175),Color8(240,230,140),Color8(198,164,232),
Color8(255,240,245)]

var frequency_group = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"]
var hex_frequency_dict = {}
var hex_tile_prefab = null
@onready var gathered_tiles = $"../../GatheredTiles"
@onready var user_controller = $"../UserController"
@onready var mouse_panel = $"../../MousePanel"
@onready var freq_reuse_button = $"../../FunctionPanel/FreqReuseButton"
var hex_list = []

## not in use
#func order_users_by_angle(users: Array) -> Array:
	#var index
	#var tmp = 0
	# apply insertion sort
	#for i in range(1, users.size()):
		#for j in range(i-1,-1,-1):
			#if users[i].angle_to_station > users[j].angle_to_station:
				#index = j
				#break
			#index = -1
		#tmp = users[i].angle_to_station
		#for j in range(i, index+1, -1):
			#users[j].angle_to_station = users[j-1].angle_to_station
	#return users

## evaluate the signal angle of a station which contains the most users
## within a given angle size.
func eval_station_direction(tile_list, user_list, index_i, index_j):
	var angle_size = null
	var tile = tile_list[index_i][index_j]
	var users = user_list[index_i][index_j]["connected"]
	
	angle_size = tile.get_divergence_angle()
	# angle size and orientation is not applicable for this tile
	if angle_size == null:
		return null
	
	if users.size() > 0:
		for k in range(users.size()):
			users[k].direction_to_station = tile.position.direction_to(users[k].position)
		# users = order_users_by_angle(users)
		var maximum_user_num = 0
		var dir_with_max_pos_diff = users[0].direction_to_station
		var dir_with_max_neg_diff = users[0].direction_to_station
		for i in range(users.size()):
			var current_user_num = 0
			var current_max_pos_angle_diff = 0
			var current_max_neg_angle_diff = 0
			var user_diff_angle = 0
			var current_dir_with_max_pos_diff = users[i].direction_to_station
			var current_dir_with_max_neg_diff = users[i].direction_to_station
			for j in range(users.size()):
				if i != j:
					user_diff_angle = users[i].direction_to_station.angle_to(users[j].direction_to_station)
					if user_diff_angle > 0 and user_diff_angle > current_max_pos_angle_diff \
					and user_diff_angle-current_max_neg_angle_diff < angle_size:
						current_max_pos_angle_diff = user_diff_angle
						current_dir_with_max_pos_diff = users[j].direction_to_station
						current_user_num += 1
					elif user_diff_angle < 0 and user_diff_angle < current_max_neg_angle_diff \
					and current_max_pos_angle_diff-user_diff_angle < angle_size:
						current_max_neg_angle_diff = user_diff_angle
						current_dir_with_max_neg_diff = users[j].direction_to_station
						current_user_num += 1
						
			if current_user_num > maximum_user_num:
				maximum_user_num = current_user_num
				dir_with_max_pos_diff = current_dir_with_max_pos_diff
				dir_with_max_neg_diff = current_dir_with_max_neg_diff
		var station_direction = (dir_with_max_pos_diff + dir_with_max_neg_diff).normalized()
		tile.signal_direction = station_direction
		return station_direction

# create a hex tile
func make_tile(pos:Vector2,arc_len:int=0,n_channel:int=7,antenna_type=null):
	var tile_len = 0
	# if input arc_len is over 0, use input arc_len as tile length, 
	# else use default arc_len stored on top.
	if arc_len > 0:
		tile_len = arc_len
	else:
		tile_len = self.arc_len
	var current_hex = hex_tile_prefab.instantiate()
	gathered_tiles.add_child(current_hex)
	current_hex.position = pos
	current_hex.set_arc_len(tile_len)
	current_hex.set_id(station_number)
	current_hex.set_channel_number(n_channel)
	current_hex.mouse_panel = self.mouse_panel
	if antenna_type == null:
		var rand_num = randi_range(0,3)
		current_hex.set_antenna_type(current_hex.AntennaType[rand_num])
	station_number += 1
	
	if arc_len < 100:
		current_hex.station_scale = arc_len/100.
	
	current_hex.queue_redraw()
	# randomize a network type for the station
	current_hex.network_type = network_type[randi_range(0,network_type.size()-1)]
	return current_hex

func initialize_freq_pattern(tile_list ,n_freq):

	# if true, allocate channels to stations according to the total number 
	# of channels (specfied by total_channel) for every group of stations
	var need_allocate_channel = false
	
	if self.total_channel_number != 0:
		need_allocate_channel = true
	
	hex_frequency_dict = {}
	# initialize a new dict for station-frequency relationship
	for i in range(n_freq):
		hex_frequency_dict[frequency_group[i]] = []
	
	if n_freq == 3:
		for i in range(tile_list.size()):
			for j in range(tile_list[i].size()):
				var current_hex = tile_list[i][j]
				var freuqnecy_group_index = i%3
				# assign group to station
				current_hex.frequency_group = frequency_group[freuqnecy_group_index]
				# change tile color
				current_hex.color = tile_color_list[freuqnecy_group_index]
				# add hex to its corresponding list in the dict
				hex_frequency_dict[frequency_group[freuqnecy_group_index]].append(current_hex)
				if need_allocate_channel:
					if freuqnecy_group_index != 0:
						current_hex.set_channel_number(int(self.total_channel_number / n_freq))
					else:
						current_hex.set_channel_number(int(self.total_channel_number / n_freq)+self.total_channel_number%n_freq)
	elif n_freq == 4:
		var frequency_group_y_start_index = 0
		var freuqnecy_group_index = 0
		for i in range(tile_list.size()):
			frequency_group_y_start_index += 1
			for j in range(tile_list[i].size()):
				var current_hex = tile_list[i][j]
				freuqnecy_group_index = (frequency_group_y_start_index + 2*j) % 4
				# assign group to station
				current_hex.frequency_group = frequency_group[freuqnecy_group_index]
				# change tile color
				current_hex.color = tile_color_list[freuqnecy_group_index]
				# add hex to its corresponding list in the dict
				hex_frequency_dict[frequency_group[freuqnecy_group_index]].append(current_hex)
				if need_allocate_channel:
					if freuqnecy_group_index != 0:
						current_hex.set_channel_number(int(self.total_channel_number / n_freq))
					else:
						current_hex.set_channel_number(int(self.total_channel_number / n_freq)+self.total_channel_number%n_freq)
	elif n_freq == 7:
		var frequency_group_y_start_index = 0
		var freuqnecy_group_index = 0
		for i in range(tile_list.size()):
			frequency_group_y_start_index += (i%2+1)
			for j in range(tile_list[i].size()):
				var current_hex = tile_list[i][j]
				freuqnecy_group_index = (frequency_group_y_start_index + j) % 7
				# assign group to station
				current_hex.frequency_group = frequency_group[freuqnecy_group_index]
				# change tile color
				current_hex.color = tile_color_list[freuqnecy_group_index]
				# add hex to its corresponding list in the dict
				hex_frequency_dict[frequency_group[freuqnecy_group_index]].append(current_hex)
				if need_allocate_channel:
					if freuqnecy_group_index != 0:
						current_hex.set_channel_number(int(self.total_channel_number / n_freq))
					else:
						current_hex.set_channel_number(int(self.total_channel_number / n_freq)+self.total_channel_number%n_freq)
	elif n_freq == 12:
		var frequency_group_y_start_index = 0
		var freuqnecy_group_index = 0
		var inverse_allocate = false
		for i in range(tile_list.size()):
			frequency_group_y_start_index = frequency_group_y_start_index+2
			
			# take inverse index and return the y index to 0
			if frequency_group_y_start_index == 12:
				inverse_allocate = !inverse_allocate
				frequency_group_y_start_index = 0
			
			for j in range(tile_list[i].size()):
				var current_hex = tile_list[i][j]
				if not inverse_allocate:
					if j % 2 == 0:
						freuqnecy_group_index = frequency_group_y_start_index + 1
					else:
						freuqnecy_group_index = frequency_group_y_start_index
				else:
					if j % 2 == 1:
						freuqnecy_group_index = frequency_group_y_start_index + 1
					else:
						freuqnecy_group_index = frequency_group_y_start_index
				# assign group to station
				current_hex.frequency_group = frequency_group[freuqnecy_group_index]
				# change tile color
				current_hex.color = tile_color_list[freuqnecy_group_index]
				# add hex to its corresponding list in the dict
				hex_frequency_dict[frequency_group[freuqnecy_group_index]].append(current_hex)
				if need_allocate_channel:
					if freuqnecy_group_index != 0:
						current_hex.set_channel_number(int(self.total_channel_number / n_freq))
					else:
						current_hex.set_channel_number(int(self.total_channel_number / n_freq)+self.total_channel_number%n_freq)
	else:
		print("Frequency allocation not allowed.")
		
	freq_reuse_button.current_pattern = n_freq

func next_freq_pattern():
	current_freq_pattern_idnex += 1
	if current_freq_pattern_idnex == allowed_freq_pattern.size():
		current_freq_pattern_idnex = 0
	initialize_freq_pattern(hex_list, allowed_freq_pattern[current_freq_pattern_idnex])

func get_current_freq_pattern():
	return allowed_freq_pattern[current_freq_pattern_idnex]

func initialize_tile_background(ref_point:Vector2, tile_length:int=0):
	
	var i = 0;
	var j = 0;
	
	for row in hex_list:
		for tile in row:
			tile.queue_free()
	
	hex_list = []
	var x = ref_point.x
	var y = ref_point.y
	var need_indent = false
	while x > 0:
		x -= arc_len
	while y > 0:
		y -= arc_len
		
	ref_point.x = x
	ref_point.y = y
	var y_index = 0
	while y < 1480:
		hex_list.append([])
		user_controller.user_list.append([])
		
		while x < 2200:
			var current_hex = make_tile(Vector2(x,y),tile_length)
			hex_list[y_index].append(current_hex)
			user_controller.user_list[y_index].append({"connected":[],
			"disconnected":[]})
			current_hex.index_i = i
			current_hex.index_j = j
			# increase column index
			j += 1
			x += 3. * arc_len
		# increase row index
		i += 1
		j = 0
		need_indent = ! need_indent
		if need_indent:
			x = ref_point.x + 1.5 * arc_len
		else:
			x = ref_point.x
		y += sqrt(3)/2 * arc_len
		y_index += 1
	
func get_current_hex(pos):
	var least_distance = -1
	var least_distance_hex = null
	var i_with_least_distance = -1
	var j_with_least_distance = -1
	for i in range(hex_list.size()):
		for j in range(hex_list[i].size()):
			# evalute the distance from mouse to the station
			var current_dis = (hex_list[i][j].get_global_transform()*Vector2(0,0)).distance_to(pos)
			if least_distance == -1 or current_dis < least_distance:
				least_distance = current_dis
				least_distance_hex = hex_list[i][j]
				i_with_least_distance = i
				j_with_least_distance = j
	return [least_distance_hex, least_distance, i_with_least_distance, j_with_least_distance]

func tile_restore_channel(i, j, channel_index):
	hex_list[i][j].restore_channel(channel_index)

func tile_allocate_channel(i, j, user):
	var channel = hex_list[i][j].allocate_channel(user)
	user.connected_channel = channel
	return channel

func initialize_map(tile_length:int=0,total_channel:int=24):
	self.total_channel_number = total_channel
	# if tile_length larger than 0, change default tile length
	if tile_length > 0:
		self.arc_len = tile_length
	initialize_tile_background(Vector2(-randi()%arc_len-arc_len, -randi()%arc_len-arc_len),tile_length)
	self.current_freq_pattern_idnex = randi_range(0,allowed_freq_pattern.size()-1)
	initialize_freq_pattern(hex_list, allowed_freq_pattern[current_freq_pattern_idnex])
	self.station_number = 0
	
# Called when the node enters the scene tree for the first time.
func _ready():
	hex_tile_prefab = preload("res://scenes/hex_tile.tscn")
	# randomly initialize a network map
	initialize_map(arc_len)
#func _input(event):
	#print(event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
