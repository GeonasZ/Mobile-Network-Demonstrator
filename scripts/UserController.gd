extends Control
@onready var users = $"../../Users"
@onready var tile_controller = $"../TileController"
@onready var obs_button = $"../../FunctionPanel/ObserverButton"
@onready var mouse_pamel = $"../../MousePanel"
@onready var gathered_tiles = $"../../GatheredTiles"
const sqrt3 = 1.732
var user_prefab = null
var user_list = []
var user_need_relocate = [] # [current_user, i, j]
var total_user_number = 0
var current_available_user_id = 0

var user_height = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	user_prefab = preload("res://scenes/user_prefab.tscn")

func initialize_user_system(user_height):
	print(user_height)
	# remove all users
	for row in user_list:
		for station in row:
			for user in station:
				user.queue_free()
	# clear user list
	user_list = []
	user_need_relocate = []
	total_user_number = 0
	current_available_user_id = 0
	self.user_height = user_height

func on_mouse_left_click_on_background(event):
	if user_prefab != null and not user_list.is_empty():
		add_user(event.position)

func add_user(pos):
	var current_user = user_prefab.instantiate()
	users.add_child(current_user)
	current_user.position = pos
	current_user.queue_redraw()
	current_user.id = current_available_user_id
	current_available_user_id += 1
	# allocate the user into a hex
	var temp = tile_controller.get_current_hex(pos)
	var i = temp[2]
	var j = temp[3]
	current_user.index_i_in_user_list = i
	current_user.index_j_in_user_list = j
	current_user.index_k_in_user_list = user_list[i][j].size()
	user_list[i][j].append(current_user)
	tile_controller.tile_allocate_channel(i,j, current_user)
	total_user_number += 1
	current_user.initialize(mouse_pamel, gathered_tiles)
	if obs_button.observer_mode_on:
		current_user.enter_observer_mode()
	current_user.redraw_with_height(self.user_height)
	return current_user

# move the user to a new tile
func relocate_user():
	for info in user_need_relocate:
		var i = info[1]
		var j = info[2]
		var user = info[0]
		user.index_i_in_user_list = i
		user.index_j_in_user_list = j
		user.index_k_in_user_list = user_list[i][j].size()
		user_list[i][j].append(user)
		tile_controller.tile_allocate_channel(i,j, user)
		
	user_need_relocate = []

# decide whether the user should be allocate to a new tile or be removed
func redirect_user(current_user, station_i, station_j, user_k):
	# current_user: the current user
	# station_i: the index i of the original station the user is in
	# station_j: the index j of the original station the user is in
	
	# delete the user if they reach the boundary
	if current_user.position.x < -20 or current_user.position.y < -20 or current_user.position.x > 1940 or current_user.position.y > 1100:
		
		# restore the chanenl of user
		var user_channel = user_list[station_i][station_j][user_k].connected_channel
		tile_controller.tile_restore_channel(station_i, station_j, user_channel)
		# remove user from user list
		
		if mouse_pamel.tracked_user == user_list[station_i][station_j][user_k]:
			mouse_pamel.track_mouse()
		
		user_list[station_i][station_j].remove_at(user_k)
		current_user.queue_free()
		total_user_number -= 1
		return
	
	# decide whether current station is cloest to the user
	var least_distance = -1
	var i_with_least_distance = -1
	var j_with_least_distance = -1
	var current_distance = -1
	
	# decide whether the user has reached a new hexogon
	# check the distance of hexogon lies at i+2 (right above the current hexogon) 
	# and check the distance of hexogon lies at i-2 (right below the current hexogon)
	# and check the distance of current hexogon itself. 
	for i in [station_i + 2, station_i, station_i - 2]:
		if i >= 0 and i < user_list.size():
			current_distance = tile_controller.hex_list[i][station_j].position.distance_to(current_user.position)
			if least_distance == -1 or current_distance < least_distance:
				least_distance = current_distance
				i_with_least_distance = i
				j_with_least_distance = station_j
	# check the distances of six hexogons lie at i-1 and i+1 (diagonally above or below the current hexogon)
	for i in [station_i-1, station_i+1]:
		if i >= 0 and i < user_list.size():
			for j in range(station_j-1, station_j+2): # travel through j-1, j and j+1
				if j >= 0 and j < user_list[i].size():
					current_distance = tile_controller.hex_list[i][j].position.distance_to(current_user.position)
					if least_distance == -1 or current_distance < least_distance:
						least_distance = current_distance
						i_with_least_distance = i
						j_with_least_distance = j

	if i_with_least_distance != station_i or j_with_least_distance != station_j:
		# restore the chanenl of user
		var user_channel = user_list[station_i][station_j][user_k].connected_channel
		tile_controller.tile_restore_channel(station_i, station_j, user_channel)
		# remove user from user list
		user_list[station_i][station_j].remove_at(user_k)
		# append to list for relocate later
		user_need_relocate.append([current_user, i_with_least_distance, j_with_least_distance])
		
func all_user_enter_observer_mode():
		for row in user_list:
			for tile in row:
				for user in tile:
					user.enter_observer_mode()

func all_user_leave_observer_mode():
		for row in user_list:
			for tile in row:
				for user in tile:
					user.leave_observer_mode()
		
func pause_all_user():
	for row in user_list:
		for tile in row:
			for user in tile:
				user.pause_motion()
		
func resume_all_user():
	for row in user_list:
			for tile in row:
				for user in tile:
					user.resume_motion()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	for i in range(user_list.size()):
		for j in range(user_list[i].size()):
			for k in range(user_list[i][j].size()-1,-1, -1):
				if tile_controller.hex_list[i][j].position.distance_to(user_list[i][j][k].position)>sqrt3/2.*tile_controller.arc_len:
					redirect_user(user_list[i][j][k],i,j,k)
	relocate_user()
