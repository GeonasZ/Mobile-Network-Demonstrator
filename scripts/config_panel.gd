extends Polygon2D

# line edits
@onready var tile_length_edit = $ContentFrame/GridContainer/TileLengthEdit/LineEdit
@onready var user_height_edit = $ContentFrame/GridContainer/UserHeightEdit/LineEdit
@onready var decay_edit = $ContentFrame/GridContainer/DecayEdit/LineEdit
@onready var freq_n_edit = $ContentFrame/GridContainer/NFrequencyEdit/LineEdit
@onready var n_user_edit = $ContentFrame/GridContainer/NUserEdit/LineEdit
@onready var path_width_edit = $ContentFrame/GridContainer/PathWidthEdit/LineEdit
@onready var building_decay_edit = $ContentFrame/GridContainer/BuildingDecayEdit/LineEdit
@onready var blocking_attenuation_edit = $ContentFrame/GridContainer/BlockingAttenuationEdit/LineEdit
@onready var decay_model_edit = $ContentFrame/GridContainer/DecayModelEdit

# other nodes
@onready var config_button = $"../FunctionPanel/ConfigButton"
@onready var anime_player = $AnimationPlayer
@onready var user_controller = $"../Controllers/UserController"
@onready var title_label = $TitleLabel
@onready var over_layer = $"../OverLayer"
@onready var function_panel = $"../FunctionPanel"
@onready var station_config_panel = $"../StationConfigPanel"
@onready var mouse_panel = $"../MousePanel"
@onready var gathered_tiles = $"../GatheredTiles"

signal config_panel_opened

var edit_list
var on_work = true
var is_panel_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	self.position = Vector2(2000,0)
	self.polygon = [Vector2(0,0), Vector2(1920,0), Vector2(1920,1080),Vector2(0,1080)]
	self.color = Color8(230,230,255)
	title_label.position = Vector2(0,-30)
	title_label.size = Vector2(1920,200)
	edit_list = [tile_length_edit, user_height_edit, decay_edit, freq_n_edit, 
				 n_user_edit, path_width_edit, building_decay_edit, blocking_attenuation_edit,
				 decay_model_edit]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize():
	for edit in edit_list:
		edit.initialize()

func open_config_with_anime():
	anime_player.set_animation_init_pos()
	function_panel.disable_all_keyboard_input()
	if station_config_panel.visible:
		await station_config_panel.disappear(true)
	self.initialize()
	if self.on_work:
		over_layer.make_invisible()
		on_work = false
		self.visible = true
		user_controller.pause_all_user()
		anime_player.play("config_appear")
		await anime_player.animation_finished
		on_work = true
		is_panel_open = true
	
func close_config_with_anime():
	if self.on_work:
		is_panel_open = false
		on_work = false
		if not user_controller.user_paused:
			user_controller.resume_all_user()
		anime_player.play("config_disappear")
		await anime_player.animation_finished
		gathered_tiles.back_to_position_after_zoom()
		over_layer.make_visible()
		self.visible = false
		on_work = true
		function_panel.enable_all_keyboard_input()
	
