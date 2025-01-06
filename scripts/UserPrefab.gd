extends Control

@onready var boundary = $Boundary
@onready var gathered_tiles = null
var mouse_panel = null

var observer_mode = false
var engineer_mode = false
var analyzer_mode = false
var analysis_on = false

signal mouse_enter_user()
signal mouse_leave_user()

var is_initialized = false

var id = -1
# null for not connected, int for channel index
var connected_channel = null

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
var station_deadzone_ratio = 0.1
var deadzone_outskirt_multiple = 2
var penalty_lr = 0.6

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
var signal_power_hist = []
var sir_hist = []

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
	self.position = Vector2(1920./2,1080./2)

func redraw_user():
		self.queue_redraw()

func redraw_with_height(people_height):
	self.visible = false
	self.height = people_height
	self.width = 0.375 * people_height
	self.radius = 0.5 * people_height
	self.feet_height = 0.5 * people_height
	self.arm_height = 0.875 * people_height
	self.queue_redraw()
	await get_tree().process_frame
	self.visible = true

func set_displacement_from_station(displacement: Vector2):
	self.displacement_from_station = displacement
	self.distance_from_station = displacement.length()
	self.direction_from_station = displacement.normalized()
	
func mouse_track_user():
	mouse_panel.track_user()

func initialize(input_mouse_panel, input_gathered_tiles):
	self.gathered_tiles = input_gathered_tiles
	self.mouse_panel = input_mouse_panel
	self.mouse_enter_user.connect(input_mouse_panel._on_mouse_enter_user)
	self.mouse_leave_user.connect(input_mouse_panel._on_mouse_leave_user)
	self.is_initialized = true

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

func eval_motion_penalty():
	var deadzone_radius = station_deadzone_ratio * self.station.arc_len
	if self.distance_from_station >= deadzone_outskirt_multiple * deadzone_radius:
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
	boundary.rect_color = Color8(0,0,0)
	boundary.queue_redraw()

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
func user_speed_protect():
	# x speed check
	if self.position.x < 0 and self.velocity.x < 0:
		self.velocity.x = -self.velocity.x
	elif self.position.x > 1920 and self.velocity.x > 0:
		self.velocity.x = -self.velocity.x
	# y speed check
	if self.position.y < 0 and self.velocity.y < 0:
		self.velocity.y = -self.velocity.y
	elif self.position.y > 1080 and self.velocity.y > 0:
		self.velocity.y = -self.velocity.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# move a step if not paused
	if (not observer_mode or under_analysis) and not engineer_mode and not motion_pause:
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# take a random acceleration from max_acc to -max_acc
		var acc = Vector2(randi_range(0,2*max_acc.x) - max_acc.x,randi_range(0,2*max_acc.y) - max_acc.y)
		self.velocity += acc
		
		# limit the speed within a specific range
		# limit x velocity
		if self.velocity.x > self.max_velocity:
			self.velocity.x = self.max_velocity
		elif self.velocity.x < -self.max_velocity:
			self.velocity.x = -self.max_velocity
		# limit y velocity
		if self.velocity.y > self.max_velocity:
			self.velocity.y = self.max_velocity
		elif self.velocity.y < -self.max_velocity:
			self.velocity.y = -self.max_velocity
		
		# analysis speed check
		# if the under is currently under analysis,
		# then they should not move beyond the map
		# use the analysis_user_speed_protect() function
		self.user_speed_protect()
		
		# move a step
		self.position += (self.velocity+self.eval_motion_penalty()) * delta
		
		# learn from penalty
		self.velocity += self.penalty_lr * self.eval_motion_penalty()
		
		#print(self.eval_motion_penalty()/(self.velocity*(self.velocity.normalized().dot(self.direction_from_station))))

		#self.position += Vector2(50,50) * delta
	else:
		self.mouse_filter = Control.MOUSE_FILTER_STOP
	
