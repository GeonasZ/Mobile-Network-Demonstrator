extends Control

const network_type = ["GSM","UMTS","HSPA","LTE","NR"]
const sqrt3 = 1.732

var allowed_freq_pattern = [3,4,7,12]

var arc_len = 210
var current_freq_pattern_index = 0
var total_channel_number = 24
var station_number = 0

# decay rate of signal power with distance
var decay = 0.1
var building_decay = 0.1

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
@onready var station_config = $"../../StationConfigPanel"
@onready var gathered_tiles = $"../../GatheredTiles"
@onready var user_controller = $"../UserController"
@onready var mouse_panel = $"../../MousePanel"
@onready var mouse_controller = $"../../Controllers/MouseController"
@onready var freq_reuse_button = $"../../FunctionPanel/FreqReuseButton"
@onready var station_config_panel = $"../../StationConfigPanel"
@onready var path_controller = $"../PathController"
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

# reallocate channels for a station, properly tackle the users
# being connected or disconnected
func tile_safely_reallocate_channels(current_hex, channel_number):
	var disconnected_user_list = current_hex.set_channel_number(channel_number)
	for user in disconnected_user_list:
		user_controller.user_list[current_hex.index_i][current_hex.index_j]["disconnected"].append(user)
		for i in range(len(user_controller.user_list[current_hex.index_i][current_hex.index_j]["connected"])-1,-1,-1):
			if user == user_controller.user_list[current_hex.index_i][current_hex.index_j]["connected"][i]:
				user_controller.user_list[current_hex.index_i][current_hex.index_j]["connected"].pop_at(i)
	user_controller.try_connect_user(current_hex.index_i,current_hex.index_j)

# reallocate channels for all stations, properly tackle the users
# being connected or disconnected
func all_tile_safely_reallocate_channels():
	if freq_reuse_button.current_pattern not in self.allowed_freq_pattern:
		print("TileController<tiles_reallocate_channels>: Invalid tile pattern.")
		return
	var current_hex
	var disconnected_user_list
	for i in range(len(self.hex_list)):
		for j in len(self.hex_list[i]):
			current_hex = self.hex_list[i][j]
			if current_hex.frequency_group != self.frequency_group[0]:
				tile_safely_reallocate_channels(current_hex,int(self.total_channel_number / freq_reuse_button.current_pattern))
			else:
				tile_safely_reallocate_channels(current_hex,int(self.total_channel_number / freq_reuse_button.current_pattern)+self.total_channel_number%freq_reuse_button.current_pattern)


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

func all_tile_set_antenna_type(mode:String):
	## mode: Choose from "Single", "Array2", "Array3", "Array4", "Random" and "Custom"
	for row in self.hex_list:
		for station in row:
			if mode == "Single" or mode == "SINGLE":
				station.set_antenna_type("SINGLE")
			elif mode == "Array2" or mode == "ARRAY2":
				station.set_antenna_type("ARRAY2")
			elif mode == "Array3" or mode == "ARRAY3":
				station.set_antenna_type("ARRAY3")
			elif mode == "Array4" or mode == "ARRAY4":
				station.set_antenna_type("ARRAY4")
			elif mode == "Random":
				
				var rand = randi_range(1,4)
				if rand == 1:
					station.set_antenna_type("SINGLE")
				elif rand == 2:
					station.set_antenna_type("ARRAY2")
				elif rand == 3:
					station.set_antenna_type("ARRAY3")
				elif rand == 4:
					station.set_antenna_type("ARRAY4")
			elif mode == "Custom":
				break
			else:
				print("TileController <all_tile_set_antenna_type>: Invalid antenna mode.")
				break
	
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
	current_hex.initialize(self.mouse_panel,self.station_config_panel, self.path_controller, self)
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
	
	for i in range(self.hex_list.size()):
		for j in range(self.hex_list[i].size()):
			user_controller.reallocate_channel_for_user_under_station(i,j)

func set_decay(value):
	self.decay = value

func get_decay():
	return self.decay

func next_freq_pattern():
	current_freq_pattern_index += 1
	if current_freq_pattern_index == allowed_freq_pattern.size():
		current_freq_pattern_index = 0
	initialize_freq_pattern(hex_list, allowed_freq_pattern[current_freq_pattern_index])

func get_current_freq_pattern():
	return allowed_freq_pattern[current_freq_pattern_index]

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
	while y < 1080 + 2 * tile_length:
		hex_list.append([])
		user_controller.user_list.append([])
		
		while x < 1920 + 2 * tile_length:
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
	
## return [least_distance_hex, least_distance, i_with_least_distance, j_with_least_distance]
func get_current_hex(pos):
	var least_distance = -1
	var least_distance_hex = null
	var i_with_least_distance = -1
	var j_with_least_distance = -1
	for i in range(hex_list.size()):
		for j in range(hex_list[i].size()):
			# evalute the distance from mouse to the station
			var current_dis = (hex_list[i][j].position).distance_to(pos)
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
	user.connect_to_channel(channel)
	return channel

func initialize_map(tile_length:int=0,total_channel:int=24,init_freq_pattern=true):
	self.total_channel_number = total_channel
	# if tile_length larger than 0, change default tile length
	if tile_length > 0:
		self.arc_len = tile_length
	initialize_tile_background(Vector2(-randi_range(-2*arc_len,-2.5*arc_len), -randi_range(-2*arc_len,-2.5*arc_len)),tile_length)
	self.station_number = 0
	
	if init_freq_pattern:
		self.current_freq_pattern_index = randi_range(0,allowed_freq_pattern.size()-1)
	initialize_freq_pattern(hex_list, allowed_freq_pattern[current_freq_pattern_index])
	
	
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
