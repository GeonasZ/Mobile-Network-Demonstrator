extends Control
@onready var users = $"../../Users"
@onready var tile_controller = $"../TileController"
@onready var obs_button = $"../../FunctionPanel/ObserverButton"
@onready var mouse_pamel = $"../../MousePanel"
@onready var gathered_tiles = $"../../GatheredTiles"
const sqrt3 = 1.732
var user_prefab = null
# initialize in tile controller when hex_list gets initialized
var user_list = []
var user_need_relocate = [] # [current_user, i, j]
var total_user_number = 0
var current_available_user_id = 0

var user_height = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	user_prefab = preload("res://scenes/user_prefab.tscn")

func initialize_user_system(user_height):
	# remove all users
	for row in user_list:
		for station in row:
			for user in station["connected"]:
				user.queue_free()
			for user in station["disconnected"]:
				user.queue_free()
	# clear user list
	user_list = []
	user_need_relocate = []
	total_user_number = 0
	current_available_user_id = 0
	self.user_height = user_height

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
	
	var channel = tile_controller.tile_allocate_channel(i,j, current_user)
	if channel != null:
		user_list[i][j]["connected"].append(current_user)
		current_user.index_k_in_user_list = user_list[i][j]["connected"].size()
		
	else:
		user_list[i][j]["disconnected"].append(current_user)
		current_user.index_k_in_user_list = user_list[i][j]["connected"].size()
		
	total_user_number += 1
	current_user.initialize(mouse_pamel, gathered_tiles)
	if obs_button.observer_mode_on:
		current_user.enter_observer_mode()
	current_user.redraw_with_height(self.user_height)
	return current_user

# try to allocate channels for those who does not have a connection before
func try_connect_user(i, j):
	var channel = null
	var user = null
	for k in range(self.user_list[i][j]["disconnected"].size()-1,-1,-1):
		user = self.user_list[i][j]["disconnected"][k]
		channel = tile_controller.tile_allocate_channel(i,j,user)
		if channel != null:
			self.user_list[i][j]["disconnected"].remove_at(k)
			self.user_list[i][j]["connected"].append(user)
		else:
			break
					
# move users need to be moved to a new tile
func relocate_user():
	for info in user_need_relocate:
		var i = info[1]
		var j = info[2]
		var user = info[0]
		user.index_i_in_user_list = i
		user.index_j_in_user_list = j
		var channel = tile_controller.tile_allocate_channel(i,j, user)
		if channel != null:
			user_list[i][j]["connected"].append(user)
			user.index_k_in_user_list = user_list[i][j]["connected"].size()
		else:
			user_list[i][j]["disconnected"].append(user)
			user.index_k_in_user_list = user_list[i][j]["disconnected"].size()
			
		
	user_need_relocate = []

# decide whether the user should be allocate to a new tile or be removed
func redirect_user(current_user, station_i, station_j, user_k):
	# current_user: the current user
	# station_i: the index i of the original station the user is in
	# station_j: the index j of the original station the user is in
	var station = user_list[station_i][station_j]
	var connection_stat = "connected"
	if current_user.connected_channel == null:
		connection_stat = "disconnected"
	# delete the user if they reach the boundary
	if current_user.position.x < -20 or current_user.position.y < -20 or current_user.position.x > 1940 or current_user.position.y > 1100:
		
		# restore the chanenl of user
		var user_channel = station[connection_stat][user_k].connected_channel
		tile_controller.tile_restore_channel(station_i, station_j, user_channel)
		# remove user from user list
		
		if mouse_pamel.tracked_user == station[connection_stat][user_k]:
			mouse_pamel.track_mouse()
		
		station[connection_stat].remove_at(user_k)
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
		var user_channel = station[connection_stat][user_k].connected_channel
		tile_controller.tile_restore_channel(station_i, station_j, user_channel)
		# remove user from user list
		station[connection_stat].remove_at(user_k)
		# append to list for relocate later
		user_need_relocate.append([current_user, i_with_least_distance, j_with_least_distance])
		
func all_user_enter_observer_mode():
		for row in user_list:
			for tile in row:
				for user in tile["connected"]:
					user.enter_observer_mode()
				for user in tile["disconnected"]:
					user.enter_observer_mode()

func all_user_leave_observer_mode():
		for row in user_list:
			for tile in row:
				for user in tile["connected"]:
					user.leave_observer_mode()
				for user in tile["disconnected"]:
					user.leave_observer_mode()
		
func pause_all_user():
	for row in user_list:
		for tile in row:
			for user in tile["connected"]:
				user.pause_motion()
			for user in tile["disconnected"]:
				user.pause_motion()
		
func resume_all_user():
	for row in user_list:
			for tile in row:
				for user in tile["connected"]:
					user.resume_motion()
				for user in tile["disconnected"]:
					user.resume_motion()
					
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	for i in range(user_list.size()):
		for j in range(user_list[i].size()):
			for k in range(user_list[i][j]["connected"].size()-1,-1, -1):
				if tile_controller.hex_list[i][j].position.distance_to(user_list[i][j]["connected"][k].position)>sqrt3/2.*tile_controller.arc_len:
					redirect_user(user_list[i][j]["connected"][k],i,j,k)
			for k in range(user_list[i][j]["disconnected"].size()-1,-1, -1):
				if tile_controller.hex_list[i][j].position.distance_to(user_list[i][j]["disconnected"][k].position)>sqrt3/2.*tile_controller.arc_len:
					redirect_user(user_list[i][j]["disconnected"][k],i,j,k)
			try_connect_user(i,j)
	relocate_user()
