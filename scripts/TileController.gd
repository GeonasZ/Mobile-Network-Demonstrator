extends Control

const network_type = ["GSM","UMTS","HSPA","LTE","NR"]
const sqrt3 = 1.732

var allowed_freq_pattern = [3,4,7,12]

var arc_len = 150
var current_freq_pattern_idnex = 0
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
@onready var freq_reuse_button = $"../../FunctionPanel/FreqReuseButton"
var hex_list = []

func make_tile(pos):
	var current_hex = hex_tile_prefab.instantiate()
	gathered_tiles.add_child(current_hex)
	current_hex.position = pos
	current_hex.set_arc_len(self.arc_len)
	current_hex.set_id(station_number)
	station_number += 1
	
	if arc_len < 100:
		current_hex.station_scale = arc_len/100.
	
	current_hex.queue_redraw()
	# randomize a network type for the station
	current_hex.network_type = network_type[randi_range(0,network_type.size()-1)]
	return current_hex

func initialize_freq_pattern(tile_list ,n_freq):
	hex_frequency_dict = {}
	# initialize a new dict for station-frequency relationship
	for i in range(n_freq):
		hex_frequency_dict[frequency_group[i]] = []
	
	if n_freq == 3:
		for i in range(tile_list.size()):
			for j in range(tile_list[i].size()):
				var current_hex = tile_list[i][j]
				# assign group to station
				current_hex.frequency_group = frequency_group[i%3]
				# change tile color
				current_hex.color = tile_color_list[i%3]
				# add hex to its corresponding list in the dict
				hex_frequency_dict[frequency_group[i%3]].append(current_hex)
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

func initialize_tile_background(ref_point: Vector2):
	
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
			var current_hex = make_tile(Vector2(x,y))
			hex_list[y_index].append(current_hex)
			user_controller.user_list[y_index].append([])
			
			x += 3. * arc_len
		
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

func initialize_map(tile_length):
	self.arc_len = tile_length
	initialize_tile_background(Vector2(-randi()%arc_len-arc_len, -randi()%arc_len-arc_len))
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
