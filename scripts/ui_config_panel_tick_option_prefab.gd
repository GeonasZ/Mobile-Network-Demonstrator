extends HBoxContainer

@onready var name_label = $Label
@onready var tick_button = $Button
@onready var tick_button_label = $Button/Label
@onready var tile_controller
@onready var ui_controller


enum UISubject {CELL_COLOR,CELL_BORDER,LAWN_COLOR,LAWN_BORDER,
				LAKE_COLOR,LAKE_BORDER, BUILDING_COLOR, BUILDING_BORDER,MAP_SHADING}

var option_type = "Tick"
var subject
var tick_on = true
var id
var id_in_group

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_button_size(Vector2(self.size.x*0.45,self.size.y*1.4))
	button_set_true()

func initialize(tile_controller, ui_controller):
	self.tile_controller = tile_controller
	self.ui_controller = ui_controller
	tick_button.value_changed.connect(ui_controller._on_color_edit_value_changed)

func set_text(text):
	self.text = text

func set_button(value:bool):
	if value == true:
		button_set_true()
	else:
		button_set_false()

func button_set_true():
	self.tick_button_label.text = "ON"
	self.tick_on = true
	
func button_set_false():
	self.tick_button_label.text = "OFF"
	self.tick_on = false
	
func set_subject(subject):
	self.subject = subject
	
func set_id(id):
	self.id = id
	
func set_id_in_group(id):
	self.id_in_group = id

func set_option_name(name):
	self.name_label.text = name

func set_button_size(size):
	self.tick_button.custom_minimum_size = size
	self.tick_button_label.position = Vector2(0,0)
	self.tick_button_label.size = size
	self.tick_button.pivot_offset = self.tick_button.size/2
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
