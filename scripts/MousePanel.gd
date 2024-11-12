extends Control

@onready var tile_controller = $"../Controllers/TileController"
@onready var info_label = $InfoLabel
@onready var mouse_controller = $"../Controllers/MouseController"
@onready var user_controller = $"../Controllers/UserController"
@onready var anime_player = $AnimationPlayer
@onready var gathered_tiles = $"../GatheredTiles"

enum XMotion {MOVE_LEFT, MOVE_RIGHT}
enum YMotion {MOVE_UP,MOVE_DOWN,MOVE_LEVEL}
enum DisplayMode {STATION, USER}
enum TrackingMode {MOUSE, USER}

var x_motion_state = XMotion.MOVE_RIGHT
var y_motion_state = YMotion.MOVE_LEVEL
var display_mode = DisplayMode.STATION
var tracking_mode = TrackingMode.MOUSE
var displayed_user = []
var tracked_user = null
var motion_speed_param = 0.3
var length = 240
var width = 180
var slash_len = 20

var out_of_window = false
var set_to_visible = true

# just a indicative property
# does not represent actual visibility of node
var keep_invisible = false


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

func label_change_style(display_mode, track_mode):
	# default mode
	if display_mode == DisplayMode.STATION and track_mode == TrackingMode.MOUSE:
		# more negative, more right bottom
		info_label.position = Vector2(-length*0.45,-width*0.47)
		info_label.size = Vector2(length*0.9, width)
	# user mode
	elif display_mode == DisplayMode.USER or track_mode == TrackingMode.USER:
		# more negative, more right bottom
		info_label.position = Vector2(-length*0.4,-width*0.27)
		info_label.size = Vector2(length, width)
	else:
		print("MousePanel: label_change_style(): Unknown State.")

func initialize_mouse_panel():
	self.display_mode = DisplayMode.STATION
	self.tracking_mode = TrackingMode.MOUSE
	self.displayed_user = []
	self.tracked_user = null
	label_change_style(self.display_mode, self.tracking_mode)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = true
	self.scale = Vector2(0,0)
	# set alpha to 0.5 (make the panel transparent)
	(self.material as ShaderMaterial).set_shader_parameter("alpha",0.5)
	# initialize info_label
	info_label.text = "[center]Loading...[/center]"
	keep_invisible = true
	
func on_mouse_right_click_on_background(event):
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_RIGHT and event.pressed == true:
		if self.keep_invisible == true:
			appear_with_anime()
		else:
			disappear_with_anime()

func process_x_motion(mouse_position, delta):
	# if in left motion
	if x_motion_state == XMotion.MOVE_LEFT:
		self.position.x -= delta/motion_speed_param * (position.x - mouse_position.x + 0.7*length)
	# if in right motion
	elif x_motion_state == XMotion.MOVE_RIGHT:
		self.position.x -= delta/motion_speed_param * (position.x - mouse_position.x - 0.7*length)
		
	# determine whether there should be a motion
	if mouse_position.x > 1920*0.6:
		x_motion_state = XMotion.MOVE_LEFT
	elif mouse_position.x < 1920*0.4:
		x_motion_state = XMotion.MOVE_RIGHT

func process_y_motion(mouse_position, delta):
	
	# move upward
	if y_motion_state == YMotion.MOVE_UP:
		self.position.y -= delta/motion_speed_param  * (position.y - mouse_position.y + 0.7*width)
	# move downward
	elif y_motion_state == YMotion.MOVE_DOWN:
		self.position.y -= delta/motion_speed_param * (position.y - mouse_position.y - 0.7*width)
	# move to level
	elif y_motion_state == YMotion.MOVE_LEVEL:
		self.position.y -= delta/motion_speed_param * (position.y - mouse_position.y)
		
	# determine whether there should be a motion
	if mouse_position.y >= 1080*0.93:
		y_motion_state = YMotion.MOVE_UP
	elif 1080*0.2 <= mouse_position.y:
		y_motion_state = YMotion.MOVE_LEVEL
	elif mouse_position.y <= 1080*0.07:
		y_motion_state = YMotion.MOVE_DOWN

func appear_with_anime():
	if self.tracking_mode == TrackingMode.USER:
		return
	self.scale = Vector2(0,0)
	self.keep_invisible = false
	anime_player.play("appear")

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

func track_user():
	self.tracking_mode = TrackingMode.USER
	# turn off the tracked_by_panel property of the user that beeen tracked before
	if self.tracked_user != null and self.tracked_user != self.displayed_user[-1]:
		self.tracked_user.end_tracked_by_panel()
	# turn on the tracked_by_panel property of the current user
	self.tracked_user = self.displayed_user[-1]
	self.tracked_user.begin_tracked_by_panel()
	
func track_mouse():
	self.tracking_mode = TrackingMode.MOUSE
	self.tracked_user.end_tracked_by_panel()
	self.tracked_user = null

func truncate_double(num, n_digits=3):
	return int(num * pow(10,n_digits))/pow(10,n_digits)

func eval_sir(signal_power, interference_power, f_digits=3):
	if interference_power == 0:
		return "inf"
	else:
		return truncate_double(signal_power/interference_power,f_digits)

func list2str(input_list, seperator=", "):
	var output = ""
	if input_list.size() == 0:
		return "None"
	else:
		for element in input_list:
			output += str(element) + seperator
			
		output = output.rstrip(seperator)
		return output

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var tracking_position
	var zoom_scale = gathered_tiles.scale.x
	if self.tracking_mode == TrackingMode.MOUSE:
		# get mouse position
		tracking_position = get_viewport().get_mouse_position()
	else:
		tracking_position = tracked_user.get_global_transform()*Vector2(0,0)
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
	if display_mode == DisplayMode.STATION and tracking_mode == TrackingMode.MOUSE:
		var distance = mouse_controller.current_distance/zoom_scale
		var current_hex = mouse_controller.current_hex
		var signal_power = current_hex.ref_signal_power/pow(distance,2)
		var interference_power = 0
		# sum interference power up
		for station in tile_controller.hex_frequency_dict[current_hex.frequency_group]:
			var station_dis = (station.get_global_transform()*Vector2(0,0)).distance_to(self.get_global_mouse_position())/zoom_scale
			interference_power += station.ref_signal_power/pow(station_dis,2)
		interference_power -= signal_power
		var available_channels_in_hex = current_hex.get_available_channels()
		
		info_label.text = "Nearest Station ID:\t"+ str(current_hex.id) +"\n" +\
					"Distance:\t"+str(truncate_double(distance))+"\n"+\
					"Network Type:\t"+mouse_controller.current_hex.network_type+"\n"+\
					"Frequency Group:\t"+mouse_controller.current_hex.frequency_group+"\n"+\
					"Users Under Station:\t"+str(user_controller.user_list[mouse_controller.current_hex_i][mouse_controller.current_hex_j].size())+\
					"[center][b]Channels Available[/b][/center][center]" + str(list2str(available_channels_in_hex)) + "[/center]"
	elif display_mode == DisplayMode.USER and tracking_mode == TrackingMode.MOUSE:
		var i = displayed_user[-1].index_i_in_user_list
		var j = displayed_user[-1].index_j_in_user_list
		var user_hex = tile_controller.hex_list[i][j]
		var distance = user_hex.position.distance_to(displayed_user[-1].position)
		var signal_power = user_hex.ref_signal_power/pow(distance,2)
		var interference_power = 0
		# sum interference power up
		if displayed_user[-1].connected_channel != null:
			for station in tile_controller.hex_frequency_dict[user_hex.frequency_group]:
				var station_dis = station.position.distance_to(displayed_user[-1].position)
				if station.channel_allocation_list[displayed_user[-1].connected_channel] != null:
					interference_power += station.ref_signal_power/pow(station_dis,2)
		interference_power -= signal_power
		info_label.text = "User ID:\t" + str(displayed_user[-1].id) + "\n" +\
			"Distance to Station:\t"+str(truncate_double(distance,1))+"\n"+\
			"Connected to Channel:\t "+str(displayed_user[-1].connection_status())
		# if user is connected to station, show sir
		if displayed_user[-1].connected_channel != null:
			info_label.text += "\nSIR:\t"+str(eval_sir(signal_power,interference_power))
		else:
			info_label.text += "\nSIR:\tN/A"
	elif tracking_mode == TrackingMode.USER:
		var index_i = tracked_user.index_i_in_user_list
		var index_j = tracked_user.index_j_in_user_list
		var user_hex = tile_controller.hex_list[index_i][index_j]
		var distance = user_hex.position.distance_to(tracked_user.position)
		var signal_power = user_hex.ref_signal_power/pow(distance,2)
		var interference_power = 0
		# sum interference power up
		if tracked_user.connected_channel != null:
			for station in tile_controller.hex_frequency_dict[user_hex.frequency_group]:
				var station_dis = station.position.distance_to(tracked_user.position)
				if station.channel_allocation_list[tracked_user.connected_channel] != null:
					interference_power += station.ref_signal_power/pow(station_dis,2)
		interference_power -= signal_power
		info_label.text = "User ID:\t" + str(tracked_user.id) + "\n" +\
			"Distance to Station:\t"+str(truncate_double(distance,1))+"\n"+\
			"Connected to Channel:\t "+str(tracked_user.connection_status())
			
		# if user is connected to station, show sir
		if tracked_user.connected_channel != null:
			info_label.text += "\nSIR:\t"+str(eval_sir(signal_power,interference_power))
		else:
			info_label.text += "\nSIR:\tN/A"
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
		
	
	
