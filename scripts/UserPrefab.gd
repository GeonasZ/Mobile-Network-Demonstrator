extends Node2D

@onready var boundary = $Boundary
@onready var gathered_tiles = null
@onready var mouse_panel = null
@onready var path_controller = null
@onready var path_layer = null

var observer_mode = false
var engineer_mode = false

signal mouse_enter_user
signal mouse_leave_user

var is_initialized = false

var id = -1
# null for not connected, int for channel index
var connected_channel = null

var ref_height = 16.
var height = 16
var width = 6
var radius = 8
var feet_height = 8
var arm_height = 14

var station
var index_i_in_user_list = 0
var index_j_in_user_list = 0
var index_k_in_user_list = 0

var displacement_from_station
var distance_from_station
var direction_from_station

# the ratio of arc_len and deadzone radius. Deadzone is where users 
# should not go in.
var station_deadzone_ratio = 0.25
var spawn_deadzone_ratio = 0.45
var deadzone_outskirt_multiple = 1.5
var penalty_lr = 0.6
# This value represents a ratio of
# the distance between the user to the station
# to the arc_len of the cell. 
# When the user is at a distance smaller than this ratio,
# they will not accelerate to the direction of
# the station any more.
# This value should be between 0.3 and 1.
var dis_ratio = 0.5


var tracked_by_panel = false
var motion_pause = false
var max_acc = Vector2(3,3)
var max_ini_velocity = 10
var max_velocity = 50
var velocity = Vector2(0,0)
var is_mouse_in = false
var direction_to_station = 0
# applied when the user is too close to the center of station
# to keep the user away from center by controlling its velocity
var motion_penalty = Vector2(0,0)

# analysis mode paramters
var under_analysis = false
var previous_under_analysis = false
var signal_power_hist = []
var sir_hist = []

var try_other_connected_path_blocks = false
var navigate_to_block = null
var try_block_count_down = 100
var x_key_first = true

func _draw():
	# draw body
	draw_line(Vector2(0,-feet_height), Vector2(0,-height), Color8(0,0,0), width)
	# draw feet
	draw_line(Vector2(0,-feet_height), Vector2(radius,0), Color8(0,0,0), width)
	draw_line(Vector2(0,-feet_height), Vector2(-radius,0), Color8(0,0,0), width)
	# draw arms
	draw_line(Vector2(radius,-arm_height), Vector2(-radius,-arm_height), Color8(0,0,0), width)
	# draw head
	draw_circle(Vector2(0,-height-radius), radius, Color8(0,0,0))
	# draw a cross if not connected
	if connected_channel == null:
		draw_line(Vector2(radius, -0.8*(height+2*radius)),Vector2(-radius, -0.1*(height+2*radius)), Color8(255,114,118,150), width)
		draw_line(Vector2(radius, -0.1*(height+2*radius)),Vector2(-radius, -0.8*(height+2*radius)), Color8(255,114,118,150), width)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	# take a random initial velocity
	self.velocity = Vector2(randi_range(0,2*max_ini_velocity) - max_ini_velocity,randi_range(0,2*max_ini_velocity) - max_ini_velocity)
	self.position = Vector2(0,0)
	
	
func redraw_user():
		self.queue_redraw()

func redraw_with_height(people_height):
	self.visible = false
	self.height = people_height
	self.width = 0.375 * people_height
	self.radius = 0.5 * people_height
	self.feet_height = 0.5 * people_height
	self.arm_height = 0.875 * people_height
	
	boundary.position = Vector2(-self.radius,-self.height-self.radius*2)
	boundary.size = Vector2(self.radius*2,self.height+self.radius*2)
	self.boundary.rect = Rect2(Vector2(0,0),boundary.size)
	boundary.queue_redraw()
	self.queue_redraw()
	await get_tree().process_frame
	self.visible = true

func set_displacement_from_station(displacement: Vector2):
	self.displacement_from_station = displacement
	self.distance_from_station = displacement.length()
	self.direction_from_station = displacement.normalized()

func get_distance_from_station():
	return self.position.distance_to(station.position)
	
func mouse_track_user():
	mouse_panel.track_user()

func initialize(input_mouse_panel, input_gathered_tiles, input_path_controller,input_path_layer):
	self.gathered_tiles = input_gathered_tiles
	self.mouse_panel = input_mouse_panel
	self.path_controller = input_path_controller
	self.path_layer = input_path_layer
	self.mouse_enter_user.connect(input_mouse_panel._on_mouse_enter_user)
	self.mouse_leave_user.connect(input_mouse_panel._on_mouse_leave_user)
	self.is_initialized = true
	self.auto_set_displacement()
	
	boundary.position = Vector2(-self.radius,-self.height+2*radius)
	boundary.size = Vector2(self.radius*2,self.height+self.radius*2)
	boundary.rect = Rect2(Vector2(0,0),Vector2(self.radius*2,self.height+self.radius*2))
	boundary.queue_redraw()

func start_analysis():
	self.under_analysis = true

func end_analysis():
	self.under_analysis = false

func reset_analysis_data():
	self.sir_hist = []
	self.signal_power_hist = []

## record a siganl power and SIR data
func record_analysis_data(siganl_power,sir):
	self.signal_power_hist.append(siganl_power)
	self.sir_hist.append(sir)

func auto_set_displacement():
	var displacement = (self.position) - station.position
	self.set_displacement_from_station(displacement)

func in_dead_zone():
	var deadzone_radius = station_deadzone_ratio * self.station.arc_len
	return self.get_distance_from_station() < deadzone_radius

func in_dead_zone_outskirt():
	var deadzone_radius = station_deadzone_ratio * self.station.arc_len
	return self.get_distance_from_station() < deadzone_outskirt_multiple * deadzone_radius

func eval_motion_penalty():
	var deadzone_radius = station_deadzone_ratio * self.station.arc_len
	if not self.in_dead_zone():
		self.motion_penalty = Vector2(0,0)
	else:
		var speed = self.velocity.length()
		var penalty_modulus = (speed*self.distance_from_station/deadzone_radius - deadzone_outskirt_multiple*speed)*min(self.velocity.normalized().dot(self.direction_from_station),0)
		self.motion_penalty = penalty_modulus * self.direction_from_station
	return self.motion_penalty
		
func show_boundary():
	boundary.visible = true
	
func hide_boundary():
	if not tracked_by_panel:
		boundary.visible = false

func move_out_deadzone():
	if self.in_dead_zone():
		self.position += self.displacement_from_station/self.distance_from_station*(self.station_deadzone_ratio*station.arc_len-self.distance_from_station)

func in_spawn_dead_zone():
	var deadzone_radius = self.spawn_deadzone_ratio * self.station.arc_len
	return self.get_distance_from_station() < deadzone_radius

func move_out_spawn_deadzone():
	if self.in_spawn_dead_zone():
		
		self.position += self.displacement_from_station/self.distance_from_station*(self.spawn_deadzone_ratio*station.arc_len-self.distance_from_station)


func connect_to_channel(channel):
	if channel != self.connected_channel and (channel == null or self.connected_channel == null):
		self.connected_channel = channel
		redraw_user()
		return
	self.connected_channel = channel
	return

func connection_status():
	if self.connected_channel != null:
		return self.connected_channel
	else:
		return "None"

func set_station(tile):
	self.station = tile

func begin_tracked_by_panel():
	self.tracked_by_panel = true

func end_tracked_by_panel():
	self.tracked_by_panel = false
	self.hide_boundary()
	boundary.rect_color = Color8(100,100,100)
	boundary.queue_redraw()
	
func enter_observer_mode():
	self.observer_mode = true

func leave_observer_mode():
	self.observer_mode = false

func enter_engineer_mode():
	self.engineer_mode = true

func leave_engineer_mode():
	self.engineer_mode = false

func pause_motion():
	self.motion_pause = true
	
func resume_motion():
	self.motion_pause = false

## protect the user from going beyond the screen
func user_speed_protect(with_buffer_space = false):
	
	var x_lim = [0,1920]
	var y_lim = [0,1080]
	
	if with_buffer_space:
		x_lim = [0-station.arc_len*0.1,1920+station.arc_len*0.1]
		y_lim = [0-station.arc_len*0.1,1080+station.arc_len*0.1]
		
	# x speed check
	if self.position.x < x_lim[0] and self.velocity.x < 0:
		self.velocity.x = -self.velocity.x
		if try_block_count_down > 0:
			self.try_block_count_down -= 1
	elif self.position.x > x_lim[1] and self.velocity.x > 0:
		self.velocity.x = -self.velocity.x
		if try_block_count_down > 0:
			self.try_block_count_down -= 1
	# y speed check
	if self.position.y < y_lim[0] and self.velocity.y < 0:
		self.velocity.y = -self.velocity.y
		if try_block_count_down > 0:
			self.try_block_count_down -= 1
	elif self.position.y > y_lim[1] and self.velocity.y > 0:
		self.velocity.y = -self.velocity.y
		if try_block_count_down > 0:
			self.try_block_count_down -= 1

func random_move(delta):
	boundary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# take a random acceleration
	# modify acceleration to avoid getting too close to the base station
	var unit_acc = self.direction_from_station
	if self.distance_from_station/self.station.arc_len < dis_ratio:
		unit_acc = unit_acc.rotated(randf_range(-PI,PI)/dis_ratio*self.distance_from_station/self.station.arc_len)
	else:
		unit_acc = unit_acc.rotated(randf_range(-PI,PI))
	var acc = unit_acc * randf_range(0,max_acc.length())

	self.velocity += acc
	# limit the speed within a specific range
	if self.velocity.length() > self.max_velocity * self.height/ref_height:
		self.velocity = self.velocity / self.velocity.length() * self.max_velocity * self.height/ref_height
	
	# use the analysis_user_speed_protect() function
	# to run an analysis speed check, in which 
	# if the under is currently under analysis,
	# then they should not move beyond the map
	self.user_speed_protect()
	
	# move a step
	#self.position += (self.velocity) * delta
	self.position += (self.velocity+self.eval_motion_penalty()) * delta
	
	# learn from penalty
	self.velocity += self.penalty_lr * self.eval_motion_penalty()

func path_move(delta):
	var do_penalty = true
	var block = self.path_controller.in_which_block(self.global_position)
	var acc = block.update_user_acc(self,self.max_acc)
	self.velocity += acc

	self.user_speed_protect(true)
	# move a step
	#self.position += (self.velocity) * delta
	
	block.avoid_user_hitting_building_walls_from_outside(self)
	block.avoid_user_walk_in_lake(self,max(self.velocity.length(),10))
	
	# limit the speed within a specific range
	if self.velocity.length() > self.max_velocity * self.height/ref_height:
		self.velocity = self.velocity / self.velocity.length() * self.max_velocity * self.height/ref_height
	
	if do_penalty:
		self.position += (self.velocity+self.eval_motion_penalty()) * delta
	else:
		self.position += self.velocity * delta
	
	# learn from penalty
	self.velocity += self.penalty_lr * self.eval_motion_penalty()
	
func set_boundary_color_red():
	boundary.rect_color = Color8(255,0,0)
	
func set_boundary_color_default():
	boundary.rect_color = Color8(50,50,50)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# try to move a step if not paused
	if (not observer_mode or under_analysis) and not engineer_mode and not motion_pause:
		if path_layer.map_visible:
			self.path_move(delta)
		else:
			self.random_move(delta)
		
	else:
		boundary.mouse_filter = Control.MOUSE_FILTER_STOP
