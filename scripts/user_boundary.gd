extends Control

@onready var user = $".."
var rect
var width = 3
var rect_color = Color8(50,50,50)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set alpha to 0.5 (make the panel transparent)
	(self.material as ShaderMaterial).set_shader_parameter("alpha",0.5)
	self.visible = false
	self.size = Vector2(user.radius*2,user.height+user.radius*2)

func _draw() -> void:
	draw_rect(Rect2(Vector2(0,0),self.rect.size), self.rect_color, false, self.width)
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT and event.pressed:
		if user.observer_mode and not user.motion_pause and not user.mouse_panel.keep_invisible:
			user.mouse_track_user()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_RIGHT and event.pressed:
		user.gathered_tiles.on_mouse_right_click_on_background(event)
	elif event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		user.gathered_tiles._gui_input(event)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# when mouse enter user
	if user.observer_mode and not user.motion_pause and not user.mouse_panel.keep_invisible:
		if rect.has_point(self.get_local_mouse_position()) and user.is_mouse_in == false:
			user.mouse_enter_user.emit(user)
			user.is_mouse_in = true
	# when mouse leave user
	if not rect.has_point(self.get_local_mouse_position()) and user.is_mouse_in == true:
		user.mouse_leave_user.emit(user)
		user.is_mouse_in = false
