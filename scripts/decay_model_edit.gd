extends HBoxContainer

@onready var name_label = $Label
@onready var tick_button = $Button
@onready var tick_button_label = $Button/Label
@onready var tile_controller = $"../../../../Controllers/TileController"
@onready var building_decay_edit = $"../BuildingDecayEdit"
@onready var decay_constant_edit_label = $"../DecayEdit/Label"

enum DecayModel {EXPONENT,INVERSE_SQUARE}

var model

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_button_size(Vector2(self.size.x*1.3,self.size.y*1.4))

func initialize():
	if tile_controller.current_model == DecayModel.EXPONENT:
		self.set_exp_decay_model()
	elif tile_controller.current_model == DecayModel.INVERSE_SQUARE:
		self.set_inverse_decay_model()
	
func set_text(text):
	self.text = text

func set_exp_decay_model():
	self.tick_button_label.text = "Exponential"
	self.model = DecayModel.EXPONENT
	decay_constant_edit_label.text = "Decay Exponent outside Building"
	building_decay_edit.visible = true
	
func set_inverse_decay_model():
	self.tick_button_label.text = "Inverse Squared"
	self.model = DecayModel.INVERSE_SQUARE
	decay_constant_edit_label.text = "Universal Decay Constant"
	building_decay_edit.visible = false
	
func set_button_size(size):
	self.tick_button.custom_minimum_size = size
	self.tick_button_label.position = Vector2(0,0)
	self.tick_button_label.size = size
	self.tick_button.pivot_offset = size/2

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
