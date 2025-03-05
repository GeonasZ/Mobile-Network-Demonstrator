extends Panel

@onready var parent = $".."
@onready var label = $Label
@onready var tile_controller = $"../../../../../Controllers/TileController"

signal value_changed

var is_mouse_in = false
var on_work = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pivot_offset = self.size/2

	
func init_label():
	label.position = Vector2(0,0)
	label.size = self.size

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and self.on_work:
		if parent.model == tile_controller.DecayModel.EXPONENT:
			parent.set_inverse_decay_model()
		elif parent.model == tile_controller.DecayModel.INVERSE_SQUARE:
			parent.set_exp_decay_model()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not self.get_rect().has_point(self.get_local_mouse_position()+self.get_rect().position) and self.is_mouse_in:
		self.is_mouse_in = false
		self.scale = Vector2(1,1)
	elif self.get_rect().has_point(self.get_local_mouse_position()+self.get_rect().position) and not self.is_mouse_in:
		self.is_mouse_in = true
		self.scale = Vector2(1.02,1.02)
