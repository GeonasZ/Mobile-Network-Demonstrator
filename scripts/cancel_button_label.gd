extends Label

@onready var parent_node = $".."
@onready var notice_label = $"../NoticeLabel"
@onready var config_panel = $"../.."
@onready var user_controller = $"../../../Controllers/UserController"
@onready var tile_controller = $"../../../Controllers/TileController"
@onready var tile_length_edit = $"../../ContentFrame/GridContainer/TileLengthEdit/LineEdit"
@onready var user_height_edit = $"../../ContentFrame/GridContainer/UserHeightEdit/LineEdit"

var on_work = true
var is_mouse_in = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	notice_label.size = Vector2(1200,50)
	var ref_pos = Vector2(-1.7*self.get_rect().size)
	notice_label.position = Vector2(2.2*ref_pos.x,ref_pos.y)

func restart_program(tile_length,user_height):
	user_controller.initialize_user_system(user_height)
	tile_controller.initialize_map(tile_length)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.pressed:
		self.on_work = false
		config_panel.close_config_with_anime()
		await get_tree().create_timer(0.5).timeout
		self.on_work = true
		
func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_mouse_in_rect():
		self.parent_node.scale = Vector2(1.05,1.05)
		notice_label.visible = true
	else:
		self.parent_node.scale = Vector2(1,1)
		notice_label.visible = false
