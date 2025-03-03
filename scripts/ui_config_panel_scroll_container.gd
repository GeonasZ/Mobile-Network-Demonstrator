extends ScrollContainer

var under_draged = false
var mouse_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		self.under_draged = true
		mouse_pos = self.get_global_mouse_position()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		self.under_draged = false
		mouse_pos = null
	elif event is InputEventMouseMotion and self.under_draged:
		self.scroll_vertical -= self.get_global_mouse_position().y - mouse_pos.y
		mouse_pos = self.get_global_mouse_position()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
