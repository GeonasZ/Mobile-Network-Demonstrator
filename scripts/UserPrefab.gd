extends Control

@onready var boundary = $Boundary
@onready var gathered_tiles = null
var mouse_panel = null

var observer_mode = false
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

var index_i_in_user_list = 0
var index_j_in_user_list = 0
var index_k_in_user_list = 0

var tracked_by_panel = false
var motion_pause = false
var max_acc = Vector2(3,3)
var max_ini_velocity = 10
var max_velocity = 50
var velocity = Vector2(0,0)
var is_mouse_in = false
var direction_to_station = 0

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


# Called when the node enters the scene tree for the first time.
func _ready():
	# take a random initial velocity
	self.velocity = Vector2(randi_range(0,2*max_ini_velocity) - max_ini_velocity,randi_range(0,2*max_ini_velocity) - max_ini_velocity)
	self.position = Vector2(1920./2,1080./2)

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


func mouse_track_user():
	mouse_panel.track_user()

func initialize(input_mouse_panel, input_gathered_tiles):
	self.gathered_tiles = input_gathered_tiles
	self.mouse_panel = input_mouse_panel
	self.mouse_enter_user.connect(input_mouse_panel._on_mouse_enter_user)
	self.mouse_leave_user.connect(input_mouse_panel._on_mouse_leave_user)
	self.is_initialized = true

func show_boundary():
	boundary.visible = true
	
func hide_boundary():
	if not tracked_by_panel:
		boundary.visible = false

func connection_status():
	if self.connected_channel != null:
		return self.connected_channel
	else:
		return "None"

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
	
func pause_motion():
	self.motion_pause = true
	
func resume_motion():
	self.motion_pause = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# move a step if not paused
	if not observer_mode and not motion_pause:
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
		
		# move a step
		self.position += self.velocity * delta
		
		
		#self.position += Vector2(50,50) * delta
	else:
		self.mouse_filter = Control.MOUSE_FILTER_STOP
