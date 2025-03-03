extends HBoxContainer

#@onready var r_label = $RLabel
#@onready var g_label = $GLabel
#@onready var b_label = $BLabel
#@onready var a_label = $ALabel

@onready var tile_controller
@onready var ui_controller

@onready var name_label = $Label
@onready var r_edit = $REdit
@onready var g_edit = $GEdit
@onready var b_edit = $BEdit
@onready var a_edit = $AEdit

enum UISubject {CELL_COLOR,CELL_BORDER,LAWN_COLOR,LAWN_BORDER,
				LAKE_COLOR,LAKE_BORDER, BUILDING_COLOR, BUILDING_BORDER,MAP_SHADING}

var subject

var id
var id_in_group
var option_type = "Color"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	r_edit.color_type = r_edit.ColorType.RED
	g_edit.color_type = g_edit.ColorType.GREEN
	b_edit.color_type = b_edit.ColorType.BLUE
	a_edit.color_type = a_edit.ColorType.ALPHA

func initialize(tile_controller, ui_controller):
	self.tile_controller = tile_controller
	self.ui_controller = ui_controller
	r_edit.value_changed.connect(ui_controller._on_color_edit_value_changed)
	g_edit.value_changed.connect(ui_controller._on_color_edit_value_changed)
	b_edit.value_changed.connect(ui_controller._on_color_edit_value_changed)
	a_edit.value_changed.connect(ui_controller._on_color_edit_value_changed)
	
	
func set_subject(subject):
	self.subject = subject
	
func set_id(id):
	self.id = id
	
func set_id_in_group(id):
	self.id_in_group = id
	
func set_color(color):
	self.r_edit.text = str(int(color.r * 255))
	self.g_edit.text = str(int(color.g * 255))
	self.b_edit.text = str(int(color.b * 255))
	self.a_edit.text = str(int(color.a * 255))

func get_color():
	var r = int(self.r_edit.text)/255.
	var g = int(self.g_edit.text)/255.
	var b = int(self.b_edit.text)/255.
	var a = int(self.a_edit.text)/255.
	return Color(r,g,b,a)
	
func set_option_name(name):
	self.name_label.text = name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
