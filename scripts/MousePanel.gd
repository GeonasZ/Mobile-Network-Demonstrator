extends Control

@onready var tile_controller = $"../Controllers/TileController"
@onready var info_label = $InfoLabel
@onready var mouse_controller = $"../Controllers/MouseController"
@onready var user_controller = $"../Controllers/UserController"
@onready var anime_player = $AnimationPlayer
@onready var gathered_tiles = $"../GatheredTiles"
@onready var function_panel = $"../FunctionPanel"
@onready var ui_config_panel = $"../UIConfigPanel"

enum XMotion {MOVE_LEFT, MOVE_RIGHT}
enum YMotion {MOVE_UP,MOVE_DOWN,MOVE_LEVEL}
enum DisplayMode {STATION, USER}
enum TrackingMode {MOUSE, USER, STATION}

var x_motion_state = XMotion.MOVE_RIGHT
var y_motion_state = YMotion.MOVE_LEVEL
var display_mode = DisplayMode.STATION
var tracking_mode = TrackingMode.MOUSE
var style_code = 0
var displayed_user = []
var tracked_user = null
var tracked_station = null
var motion_speed_param = 0.3
var length = 320
var width = 220
var slash_len = 20

# the mose panel and function panel should invisible in this mode
var backgorund_watching_mode = false

var out_of_window = false
var set_to_visible = true

# just a indicative property
# does not represent actual visibility of node
var keep_invisible = false
var analysis_panel_open = false
var station_config_panel_open = false


func _draw():
	draw_line(Vector2(-length/2+slash_len, -width/2),Vector2(length/2-slash_len, -width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2-slash_len, -width/2), Vector2(length/2, -width/2+slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, -width/2+slash_len),Vector2(length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, width/2 - slash_len), Vector2(length/2 - slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2 - slash_len, width/2), Vector2(-length/2 + slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2 + slash_len, width/2), Vector2(-length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, width/2 - slash_len), Vector2(-length/2, -width/2 + slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, -width/2 + slash_len), Vector2(-length/2 + slash_len, -width/2), Color(0,0,0), 5, true)
	draw_polygon([Vector2(-length/2 + slash_len, -width/2),
					Vector2(length/2 - slash_len, -width/2),
					Vector2(length/2, -width/2 + slash_len),
					Vector2(length/2, width/2 - slash_len),
					Vector2(length/2 - slash_len, width/2),
					Vector2(-length/2 + slash_len, width/2),
					Vector2(-length/2, width/2 - slash_len),
					Vector2(-length/2, -width/2 + slash_len)],
					[Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),
					Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255)])

# change the display style of panel in different states
func label_change_style(display_mode, track_mode):
	if display_mode == DisplayMode.STATION and track_mode == TrackingMode.MOUSE:
		
		if self.style_code == 1:
			# value larger, more left top
			info_label.position = Vector2(-length*0.44,-width*0.45)
			info_label.size = Vector2(0.88*length, width)
		else:
			# more negative, more right bottom
			info_label.position = Vector2(-length*0.4,-width*0.45)
			info_label.size = Vector2(length, width)
		# station mode
	elif track_mode == TrackingMode.STATION:
		# value larger, more left top
		info_label.position = Vector2(-length*0.44,-width*0.45)
		info_label.size = Vector2(length*0.88, width)
	# user mode
	elif display_mode == DisplayMode.USER or track_mode == TrackingMode.USER:
		# value larger, more left top
		info_label.position = Vector2(-length*0.38,-width*0.35)
		info_label.size = Vector2(length, width)

	else:
		print("MousePanel: label_change_style(): Unknown State.")

func initialize_mouse_panel():
	self.display_mode = DisplayMode.STATION
	self.tracking_mode = TrackingMode.MOUSE
	self.displayed_user = []
	self.tracked_user = null
	self.position = self.get_global_mouse_position()
	label_change_style(self.display_mode, self.tracking_mode)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = true
	self.scale = Vector2(0,0)
	# set alpha to 0.5 (make the panel transparent)
	(self.material as ShaderMaterial).set_shader_parameter("alpha",0.9)
	# initialize info_label
	info_label.text = "[center]Loading...[/center]"
	keep_invisible = true
	
func on_mouse_right_click_on_background(event):
	if ui_config_panel.visible:
		return
	
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_RIGHT and event.pressed == true:
		if self.keep_invisible and not self.analysis_panel_open and not self.station_config_panel_open and self.backgorund_watching_mode:
			self.backgorund_watching_mode = false
			appear_with_anime()
		elif not self.backgorund_watching_mode:
			disappear_with_anime()
			self.backgorund_watching_mode = true
			

func move_to(pos):
	process_x_motion(pos,0,true)
	process_y_motion(pos,0,true)

func process_x_motion(mouse_position, delta, directly_move_to=false):
	# determine whether there should be a motion
	if mouse_position.x > 1920*0.6:
		x_motion_state = XMotion.MOVE_LEFT
	elif mouse_position.x < 1920*0.4:
		x_motion_state = XMotion.MOVE_RIGHT
	
	# if in left motion
	if x_motion_state == XMotion.MOVE_LEFT:
		if directly_move_to:
			self.position.x = mouse_position.x + 0.7*length
		else:
			self.position.x -= delta/motion_speed_param * (position.x - mouse_position.x + 0.7*length)
	# if in right motion
	elif x_motion_state == XMotion.MOVE_RIGHT:
		if directly_move_to:
			self.position.x = mouse_position.x - 0.7*length
		else:
			self.position.x -= delta/motion_speed_param * (position.x - mouse_position.x - 0.7*length)
			
			
func process_y_motion(mouse_position, delta, directly_move_to=false):
	
	# determine whether there should be a motion
	if mouse_position.y >= 1080*0.93:
		y_motion_state = YMotion.MOVE_UP
	elif 1080*0.2 <= mouse_position.y:
		y_motion_state = YMotion.MOVE_LEVEL
	elif mouse_position.y <= 1080*0.07:
		y_motion_state = YMotion.MOVE_DOWN
	
	# move upward
	if y_motion_state == YMotion.MOVE_UP:
		if directly_move_to:
			self.position.y = mouse_position.y + 0.7*width
		else:
			self.position.y -= delta/motion_speed_param  * (position.y - mouse_position.y + 0.7*width)
	# move downward
	elif y_motion_state == YMotion.MOVE_DOWN:
		if directly_move_to:
			self.position.y = mouse_position.y - 0.7*width
		else:
			self.position.y -= delta/motion_speed_param * (position.y - mouse_position.y - 0.7*width)
	# move to level
	elif y_motion_state == YMotion.MOVE_LEVEL:
		if directly_move_to:
			self.position.y = mouse_position.y
		else:
			self.position.y -= delta/motion_speed_param * (position.y - mouse_position.y)


func appear_with_anime():
	if self.tracking_mode == TrackingMode.USER:
		return
	self.scale = Vector2(0,0)
	self.keep_invisible = false
	anime_player.play("appear")
	await anime_player.animation_finished

func is_tracking_station():
	return self.tracking_mode == TrackingMode.STATION

func disappear_with_anime_at_speed(speed_scale):
	if self.tracking_mode == TrackingMode.USER:
		return

	anime_player.speed_scale = speed_scale
	anime_player.play("disappear")
	self.keep_invisible = true
	await anime_player.animation_finished
	anime_player.speed_scale = 1
	
func disappear_with_anime():
	disappear_with_anime_at_speed(1)

func on_analysis_panel_open():
	self.analysis_panel_open = true
	self.track_mouse()
	self.disappear_with_anime_at_speed(1)

func on_analysis_panel_close():
	if function_panel.mouse_panel_not_in_button():
		self.analysis_panel_open = false
		self.appear_with_anime()
	
func on_station_config_panel_open():
	self.station_config_panel_open = true
	self.disappear_with_anime()
	
func on_station_config_panel_close(force=false):
	self.station_config_panel_open = false
	if force or function_panel.mouse_panel_not_in_button():
		self.appear_with_anime()

func track_station(station):
	self.tracking_mode = TrackingMode.STATION
	
	# turn off the tracked_by_panel property of the station that beeen tracked before
	if self.tracked_station != null and self.tracked_user != station:
		self.tracked_station.end_tracked_by_panel()
	if tracked_user != null:
		self.tracked_user.end_tracked_by_panel()
		self.tracked_user = null
	self.tracked_station = station
	self.tracked_station.begin_tracked_by_panel()

func track_user():
	self.tracking_mode = TrackingMode.USER

	# turn off the tracked_by_panel property of the user that beeen tracked before
	if self.tracked_user != null and self.tracked_user != self.displayed_user[-1]:
		self.tracked_user.end_tracked_by_panel()
	if tracked_station != null:
		self.tracked_station.end_tracked_by_panel()
		self.tracked_station = null
	# turn on the tracked_by_panel property of the current user
	self.tracked_user = self.displayed_user[-1]
	self.tracked_user.begin_tracked_by_panel()
	
func track_mouse():
	self.tracking_mode = TrackingMode.MOUSE
	if tracked_user != null:
		self.tracked_user.end_tracked_by_panel()
	if tracked_station != null:
		self.tracked_station.end_tracked_by_panel()
	self.tracked_user = null
	self.tracked_station = null

func truncate_double(num, n_digits=3):
	return int(num * pow(10,n_digits))/pow(10,n_digits)

func eval_sir(signal_power, interference_power, f_digits=3):
	if interference_power == 0:
		return "inf"
	else:
		return truncate_double(signal_power/interference_power,f_digits)

func list2str(input_list, seperator=", "):
	var output = ""
	var input_size = input_list.size()
	if input_size == 0:
		return "None"
	else:
		if input_size <= 7:
			for i in range(min(input_size,7)):
				output += str(input_list[i]) + seperator
			output = output.rstrip(seperator)
		else:
			for i in range(min(input_size,6)):
				output += str(input_list[i]) + seperator
			output = output.rstrip(seperator)
			output += "  < " + str(input_size-6) + " more >"
			
		
		return output

func dBm(num:float):
	return 10*log(num/0.001)/log(10)
	
func dB(num:float):
	return 10*log(num)/log(10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var tracking_position
	var zoom_scale = gathered_tiles.scale.x
	
	if self.tracking_mode == TrackingMode.MOUSE:
		# get mouse position
		tracking_position = get_viewport().get_mouse_position()
	elif self.tracking_mode == TrackingMode.USER:
		tracking_position = tracked_user.global_position
	else:
		tracking_position = tracked_station.global_position
	process_x_motion(tracking_position, delta)
	process_y_motion(tracking_position, delta)
	
	# judge whether cursor is in the screen
	if self.position.y > 1080 or self.position.y < 0 or self.position.x < 0 or self.position.x > 1920:
		out_of_window = true
		self.visible = false
	else:
		out_of_window = false 
		if not keep_invisible:
			self.visible = true
	# display station and user info
	if display_mode == DisplayMode.STATION and tracking_mode == TrackingMode.MOUSE:
		var distance = mouse_controller.current_distance/zoom_scale
		var current_hex = mouse_controller.current_hex
		var available_channels_in_hex = current_hex.get_available_channels()
		# if the mouse position is far away from the center of hex tile
		if  not mouse_controller.current_hex.is_center_on_focus():
			info_label.text = "Nearest Station ID:  "+ str(current_hex.id) +"\n" +\
						"Distance:  "+str(truncate_double(distance))+"\n"+\
						"Network Type:  "+mouse_controller.current_hex.network_type+"\n"+\
						"Antenna Type:  "+ current_hex.get_antenna_type()+'\n' +\
						"Frequency Group:  "+mouse_controller.current_hex.frequency_group+"\n"+\
						"Number of Channels:  "+str(current_hex.n_available_channel)+"\n"+\
						"Users Under Station:  "+str(
							user_controller.user_list[mouse_controller.current_hex_i][mouse_controller.current_hex_j]["connected"].size()+\
							user_controller.user_list[mouse_controller.current_hex_i][mouse_controller.current_hex_j]["disconnected"].size())+"\n"+\
						"Number of Available Channels: " + str(current_hex.n_available_channel-\
						user_controller.user_list[mouse_controller.current_hex_i][mouse_controller.current_hex_j]["connected"].size())
			self.style_code = 0
		# display more information about station if at the center of area
		else:
			info_label.text = "Station ID:  "+ str(current_hex.id) +"\n" +\
			"Network Type:  "+mouse_controller.current_hex.network_type+"\n"+\
			"Frequency Group:  "+mouse_controller.current_hex.frequency_group+"\n"+\
			"Number of Channels:  "+str(current_hex.n_available_channel)+"\n"+\
			"Users Under Station: "+\
			str(user_controller.user_list[mouse_controller.current_hex_i][mouse_controller.current_hex_j]["connected"].size()+\
			user_controller.user_list[mouse_controller.current_hex_i][mouse_controller.current_hex_j]["disconnected"].size())+"\n"+\
			"Antenna Type:  "+ current_hex.get_antenna_type() +\
			"[center][b]Channels Available[/b][/center][center]" + str(list2str(available_channels_in_hex)) + "[/center]"
			self.style_code = 1
	
	# display station information with foucs at station
	elif tracking_mode == TrackingMode.STATION:
		var distance = mouse_controller.current_distance/zoom_scale
		var available_channels_in_hex = tracked_station.get_available_channels()
		info_label.text = "Station ID:  "+ str(tracked_station.id) +"\n" +\
		"Network Type:  "+tracked_station.network_type+"\n"+\
		"Frequency Group:  "+tracked_station.frequency_group+"\n"+\
		"Number of Channels:  "+str(tracked_station.n_available_channel)+"\n"+\
		"Users Under Station: "+\
		str(user_controller.user_list[tracked_station.index_i][tracked_station.index_j]["connected"].size()+\
		user_controller.user_list[tracked_station.index_i][tracked_station.index_j]["disconnected"].size())+"\n"+\
		"Antenna Type:  "+ tracked_station.get_antenna_type() +\
		"[center][b]Channels Available[/b][/center][center]" + str(list2str(available_channels_in_hex)) + "[/center]"
		self.style_code = 0
		
	# display user information with foucs at mouse
	elif display_mode == DisplayMode.USER and tracking_mode == TrackingMode.MOUSE:
		if displayed_user.size() == 0:
			display_mode = DisplayMode.STATION
			self._process(delta)
			return
		
		var i = displayed_user[-1].index_i_in_user_list
		var j = displayed_user[-1].index_j_in_user_list
		var user_hex = tile_controller.hex_list[i][j]
		var distance = user_hex.position.distance_to(displayed_user[-1].position)
		var signal_power
		var interference_power
		var sir
		
		# evaluate signal power, interference and sir
		var temp = user_controller.eval_user_sir(displayed_user[-1])
		signal_power = temp[0]
		interference_power = temp[1]
		sir = temp[2]
		
		info_label.text = "User ID:  " + str(displayed_user[-1].id) + "\n" +\
			"Nearest Station ID: " + str(user_hex.id) +'\n'+\
			"Distance to Nearest Station:  "+str(truncate_double(distance,1))+"\n"+\
			"Connected to Channel:  "+str(displayed_user[-1].connection_status())
		# if user is connected to station, show sir
		if displayed_user[-1].connected_channel != null:
			info_label.text += "\nSignal Power: " + (str(truncate_double(dBm(signal_power))) + " dBm" if signal_power > 0 else "0 W")
			if sir is float:
				info_label.text += "\nSIR:  " + str(truncate_double(dB(sir))) + " dB"
			else:
				info_label.text += "\nSIR:  N/A"
		else:
			info_label.text += "\nSignal Power: Not Connected"
			info_label.text += "\nSIR:  N/A"
		self.style_code = 0
		
	# display user information with foucs at user
	elif tracking_mode == TrackingMode.USER:
		var index_i = tracked_user.index_i_in_user_list
		var index_j = tracked_user.index_j_in_user_list
		var user_hex = tile_controller.hex_list[index_i][index_j]
		var distance = user_hex.position.distance_to(tracked_user.position)
		var signal_power
		var interference_power
		var sir
		
		# evaluate signal power, interference and sir
		var temp = user_controller.eval_user_sir(tracked_user)
		signal_power = temp[0]
		interference_power = temp[1]
		sir = temp[2]
		
		info_label.text = "User ID:  " + str(tracked_user.id) + "\n" +\
			"Nearest Station ID: " + str(user_hex.id) + "\n" +\
			"Distance to Nearest Station:  "+str(truncate_double(distance,1))+"\n"+\
			"Connected to Channel:  "+str(tracked_user.connection_status())
			
		# if user is connected to station, show sir
		if tracked_user.connected_channel != null:
			info_label.text += "\nSignal Power: " + (str(truncate_double(dBm(signal_power))) + " dBm" if signal_power > 0 else "0 W")
			if sir is float:
				info_label.text += "\nSIR:  "+str(truncate_double(dB(sir))) + " dB"
			else:
				info_label.text += "\nSIR:  N/A"
		else:
			info_label.text += "\nSignal Power: Not Connected"
			info_label.text += "\nSIR:  N/A"
		self.style_code = 0
	# change the display style of label
	label_change_style(self.display_mode, self.tracking_mode)

func _on_mouse_enter_user(user):

	self.display_mode = DisplayMode.USER
	displayed_user.append(user)
	# add focus to current user
	if displayed_user.size() > 1:
		displayed_user[-2].z_index = 0
		displayed_user[-2].scale = Vector2(1,1)
		displayed_user[-2].hide_boundary()
	user.z_index = 1
	user.scale = Vector2(1.1,1.1)
	user.show_boundary()
		
func _on_mouse_leave_user(user):
	# remove focus
	for i in range(displayed_user.size()-1,-1,-1):
		if displayed_user[i] == user:
			displayed_user.remove_at(i)
			break
	user.z_index = 0
	user.scale = Vector2(1,1)
	user.hide_boundary()
	
	# foucs on a previous user
	if displayed_user.is_empty():
		self.display_mode = DisplayMode.STATION
	else:
		displayed_user[-1].z_index = 1
		displayed_user[-1].scale = Vector2(1.1,1.1)
		displayed_user[-1].show_boundary()
		
	
	
