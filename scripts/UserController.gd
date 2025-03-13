extends Control
@onready var users = $"../../Users"
@onready var tile_controller = $"../TileController"
@onready var path_controller = $"../PathController"
@onready var mouse_panel = $"../../MousePanel"
@onready var gathered_tiles = $"../../GatheredTiles"
@onready var obs_button = $"../../FunctionPanel/ObserverButton"
@onready var engineer_button = $"../../FunctionPanel/EngineerButton"
@onready var sampling_timer = $AnalysisSamplingTimer
@onready var function_panel = $"../../FunctionPanel"
@onready var path_layer = $"../../PathLayer"
@onready var ui_config_panel = $"../../UIConfigPanel"
const sqrt3 = 1.732
var user_prefab = null
# initialize in tile controller when hex_list gets initialized
var user_list = []
var linear_user_list = []
var current_available_user_id = 0
var show_popup = false

var analysis_sampling_interval = 0.2

var user_height = 10

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
	linear_user_list = []
	current_available_user_id = 0
	self.user_height = user_height

func add_user(pos,out_of_dead_zone=false, force=false):
	if not force and (obs_button.analysis_on or engineer_button.button_mode == engineer_button.Mode.ENGINEER or ui_config_panel.visible):
		return
	
	var current_user = user_prefab.instantiate()
	users.add_child(current_user)
	linear_user_list.append(current_user)
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
	if randi_range(1,0):
		current_user.x_key_first = true
	else:
		current_user.x_key_first = false
		
	current_user.set_station(temp[0])
	var channel = tile_controller.tile_allocate_channel(i,j, current_user)
	if channel != null:
		user_list[i][j]["connected"].append(current_user)
		current_user.index_k_in_user_list = user_list[i][j]["connected"].size() - 1
		
	else:
		user_list[i][j]["disconnected"].append(current_user)
		current_user.index_k_in_user_list = user_list[i][j]["disconnected"].size() - 1
	current_user.initialize(mouse_panel, gathered_tiles, path_controller, path_layer)
	if obs_button.button_mode == obs_button.Mode.OBSERVER:
		current_user.enter_observer_mode()
	if engineer_button.button_mode == engineer_button.Mode.ENGINEER:
		current_user.enter_engineer_mode()
	current_user.redraw_with_height(self.user_height)
	if out_of_dead_zone:
		current_user.move_out_spawn_deadzone()
	return current_user

func redraw_all_users():
	for row in user_list:
		for tile in row:
			for user in tile["connected"]:
				user.redraw_with_height(self.user_height)
			for user in tile["disconnected"]:
				user.redraw_with_height(self.user_height)
			

func random_add_user(n_user:int,out_of_dead_zone=false):
	var user_pos
	for i in range(n_user):
		user_pos = Vector2(randi_range(0.05*1920,0.95*1920),randi_range(0.05*1080,0.95*1080))
		self.add_user(user_pos, out_of_dead_zone, true)

func remove_user(user,index_in_linear_user_list=null):
	var user_connection_stat = "connected" if user.connected_channel != null else "disconnected"
	self.remove_user_from_user_list(user.index_i_in_user_list,user.index_j_in_user_list,user_connection_stat, user.index_k_in_user_list)
	# if user index is provided, delete from linear_user_list directly
	# rather than doing a binary search
	if index_in_linear_user_list == null:
		self.remove_user_from_linear_user_list(user.id)
	else:
		self.remove_user_from_linear_user_list_by_index(index_in_linear_user_list)
	
	if user_connection_stat == "connected":
		tile_controller.tile_restore_channel(user.index_i_in_user_list,user.index_j_in_user_list,user.connected_channel)
	# remove focus if the mouse panel is currently tracking the user
	if mouse_panel.tracked_user == user:
		mouse_panel.track_mouse()
	# travel through all displayed users under mouse panel to see
	# if current user is in it. Remove it if yes.
	for j in range(len(mouse_panel.displayed_user)):
		if mouse_panel.displayed_user[j] == user:
			mouse_panel.displayed_user.remove_at(j)
			mouse_panel._on_mouse_leave_user(user)
			break
	user.queue_free()

## remove a user from the linear user list by their id
func remove_user_from_linear_user_list(user_id):
	var index = binary_search_user_in_linear_user_list(user_id)
	if index >= 0:
		self.linear_user_list.remove_at(index)
	else:
		print("User Controller [remove_user_from_linear_user_list]: Invalid user_id (%s) to be removed."%user_id)

func remove_user_from_linear_user_list_by_index(index):
	self.linear_user_list.remove_at(index)

func remove_user_from_user_list(index_i,index_j,connection_stat,index_k):
	var station_connection_pool = user_list[index_i][index_j][connection_stat]
	for i in range(len(station_connection_pool)-1,index_k,-1):
		station_connection_pool[i].index_k_in_user_list -= 1
	user_list[index_i][index_j][connection_stat].remove_at(index_k)
	
func binary_search_user_in_linear_user_list(user_id:int, start=0, end=-1):
	if self.linear_user_list == []:
		return -1
	elif user_id > self.linear_user_list[-1].id:
		return -1
	elif user_id < self.linear_user_list[0].id:
		return -1
	
	if end == -1:
		end = len(self.linear_user_list)
	# perform binary search
	var mid_index = int((end+start)/2)
	if self.linear_user_list[mid_index].id < user_id:
		start = mid_index
		return binary_search_user_in_linear_user_list(user_id, start, end)
	elif self.linear_user_list[mid_index].id > user_id:
		end = mid_index
		return binary_search_user_in_linear_user_list(user_id, start, end)
	elif abs(start - end) <= 1:
		if self.linear_user_list[start].id == user_id:
			return start
		elif self.linear_user_list[end].id == user_id:
			return end
		else:
			return -1
	else:
		return mid_index
	
func reallocate_channel_for_user_under_station(i,j):
	var user = null
	var channel_num = tile_controller.hex_list[i][j].n_available_channel
	for k in range(self.user_list[i][j]["connected"].size()-1,-1,-1):
			user = self.user_list[i][j]["connected"][k]
			user.connect_to_channel(null)
			self.user_list[i][j]["disconnected"].append(user)
	
	tile_controller.hex_list[i][j].init_channel_number(channel_num)
	user_list[i][j]["connected"] = []
	
	try_connect_user(i,j)
	
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
			user.index_k_in_user_list = self.user_list[i][j]["connected"].size() - 1
		else:
			break
					
# move users need to be moved to a new tile
func relocate_user(user_need_relocate):
	for info in user_need_relocate:
		if info == []:
			continue
		var i = info[1]
		var j = info[2]
		var user = info[0]
		user.index_i_in_user_list = i
		user.index_j_in_user_list = j
		user.set_station(tile_controller.hex_list[i][j])
		var channel = tile_controller.tile_allocate_channel(i,j, user)
		if channel != null:
			user_list[i][j]["connected"].append(user)
			user.index_k_in_user_list = user_list[i][j]["connected"].size() - 1
		else:
			user_list[i][j]["disconnected"].append(user)
			user.index_k_in_user_list = user_list[i][j]["disconnected"].size() - 1

# decide whether the user should be allocate to a new tile or be removed
func redirect_user(current_user, station_i, station_j, user_k) -> Array:
	# current_user: the current user
	# station_i: the index i of the original station the user is in
	# station_j: the index j of the original station the user is in
	var station = user_list[station_i][station_j]
	var connection_stat = "connected"
	var user_need_relocate = [] # [current_user, i, j]
	if current_user.connected_channel == null:
		connection_stat = "disconnected"
	# delete the user if they reach the boundary
	if current_user.position.x < - tile_controller.arc_len or current_user.position.y < -tile_controller.arc_len or current_user.position.x > 1920+tile_controller.arc_len or current_user.position.y > 1080+tile_controller.arc_len:
		
		# restore the chanenl of user
		var user_channel = station[connection_stat][user_k].connected_channel
		tile_controller.tile_restore_channel(station_i, station_j, user_channel)
		# remove user from user list
		
		self.remove_user(current_user)
		return user_need_relocate
	
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
		self.remove_user_from_user_list(station_i,station_j,connection_stat,user_k)
		# append to list for relocate later
		user_need_relocate = [current_user, i_with_least_distance, j_with_least_distance]
	return user_need_relocate

## return a list consists of 
## [signal power, interference power, sir]
func eval_user_sir(user, inf_thresd=1e4):
	var index_i = user.index_i_in_user_list
	var index_j = user.index_j_in_user_list
	var user_hex = tile_controller.hex_list[index_i][index_j]
	var signal_power = 0
	# inverse sqaure model
	if tile_controller.current_model == tile_controller.DecayModel.INVERSE_SQUARE:
		if path_layer.map_visible:
			signal_power = user_hex.eval_signal_pow_to_user(user, tile_controller.get_decay(), true, path_controller.get_blocking_attenuation())
		else:
			signal_power = user_hex.eval_signal_pow_to_user(user, tile_controller.get_decay(), true, 0)
	# exponent model
	elif tile_controller.current_model == tile_controller.DecayModel.EXPONENT:
		if path_layer.map_visible:
			signal_power = user_hex.eval_signal_pow_to_user(user, null, false, path_controller.get_blocking_attenuation())
		else:
			signal_power = user_hex.eval_signal_pow_to_user(user, tile_controller.get_decay(), false, 0)
	
	
	var interference_power = 0
	# sum interference power up
	if user.connected_channel != null:
		for station in tile_controller.hex_frequency_dict[user_hex.frequency_group]:
			if station.channel_allocation_list[user.connected_channel] != null:
				if tile_controller.current_model == tile_controller.DecayModel.INVERSE_SQUARE:
					if path_layer.map_visible:
						# hyperbolic method with constant decay
						interference_power += station.eval_signal_pow_to_user(user, tile_controller.get_decay(), true, path_controller.get_blocking_attenuation())
					else:
						interference_power += station.eval_signal_pow_to_user(user, tile_controller.get_decay(), true, 0)
				elif tile_controller.current_model == tile_controller.DecayModel.EXPONENT:
					if path_layer.map_visible:
						# hyperbolic method with constant decay
						interference_power += station.eval_signal_pow_to_user(user, null, false, path_controller.get_blocking_attenuation())
					else:
						interference_power += station.eval_signal_pow_to_user(user, tile_controller.get_decay(), false, 0)
					
					
	interference_power -= signal_power
	var sir
	if interference_power == 0 and signal_power == 0:
		sir = "N/A"
	elif interference_power == 0:
		sir = INF
	else:
		sir = signal_power/interference_power
		
	if signal_power > inf_thresd:
		signal_power = INF
	if interference_power > inf_thresd:
		interference_power = INF
	if sir is String or sir > inf_thresd:
		sir = "N/A"

		
	return [signal_power, interference_power, sir]

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

func all_user_enter_engineer_mode():
		for row in user_list:
			for tile in row:
				for user in tile["connected"]:
					user.enter_engineer_mode()
				for user in tile["disconnected"]:
					user.enter_engineer_mode()

func all_user_leave_engineer_mode():
		for row in user_list:
			for tile in row:
				for user in tile["connected"]:
					user.leave_engineer_mode()
				for user in tile["disconnected"]:
					user.leave_engineer_mode()

func all_user_reset_data_list():
	for row in user_list:
		for tile in row:
			for user in tile["connected"]:
				user.reset_analysis_data()
			for user in tile["disconnected"]:
				user.reset_analysis_data()

func all_user_start_analysis(append=false):
	if not append:
		self.all_user_reset_data_list()
	for row in user_list:
		for tile in row:
			for user in tile["connected"]:
				user.start_analysis()
			for user in tile["disconnected"]:
				user.start_analysis()
				
func all_user_end_analysis():
	for row in user_list:
		for tile in row:
			for user in tile["connected"]:
				user.end_analysis()
			for user in tile["disconnected"]:
				user.end_analysis()
				
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
	var users_need_relocate = {"connected":[],"disconnected":[]}
	var displacement
	# change where the user is in the user_list
	for i in range(user_list.size()):
		for j in range(user_list[i].size()):
			for k in range(user_list[i][j]["connected"].size()-1,-1, -1):
				# set the displacement of user from station
				displacement = (user_list[i][j]["connected"][k].position) - tile_controller.hex_list[i][j].position
				user_list[i][j]["connected"][k].set_displacement_from_station(displacement)
				if tile_controller.hex_list[i][j].position.distance_to(user_list[i][j]["connected"][k].position)>sqrt3/2.*tile_controller.arc_len:
					users_need_relocate["connected"].append(redirect_user(user_list[i][j]["connected"][k],i,j,k))
			for k in range(user_list[i][j]["disconnected"].size()-1,-1, -1):
				# set the displacement of user from station
				displacement = (user_list[i][j]["disconnected"][k].position) - tile_controller.hex_list[i][j].position
				user_list[i][j]["disconnected"][k].set_displacement_from_station(displacement)
				if tile_controller.hex_list[i][j].position.distance_to(user_list[i][j]["disconnected"][k].position)>sqrt3/2.*tile_controller.arc_len:
					users_need_relocate["disconnected"].append(redirect_user(user_list[i][j]["disconnected"][k],i,j,k))
			try_connect_user(i,j)
			relocate_user(users_need_relocate["connected"])
			relocate_user(users_need_relocate["disconnected"])
			users_need_relocate = {"connected":[],"disconnected":[]}
	# if analysis is on, start the timer
	if obs_button.analysis_on:
		if sampling_timer.is_stopped():
			_on_analysis_sampling_timer_timeout()
			sampling_timer.start(analysis_sampling_interval)
	elif not sampling_timer.is_stopped():
		sampling_timer.stop()


func _on_analysis_sampling_timer_timeout() -> void:
	var data_list
	for row in self.user_list:
		for station in row:
			for user in station["connected"]:
				data_list = self.eval_user_sir(user)
				user.record_analysis_data(data_list[0],data_list[2])
			for user in station["disconnected"]:
				user.record_analysis_data(0,"N/A")
