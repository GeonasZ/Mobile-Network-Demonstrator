extends Label

@onready var parent_node = $".."
@onready var notice_label = $"../NoticeLabel"
@onready var config_panel = $"../.."
@onready var user_controller = $"../../../Controllers/UserController"
@onready var tile_controller = $"../../../Controllers/TileController"
@onready var path_controller = $"../../../Controllers/PathController"
@onready var mouse_panel = $"../../../MousePanel"
@onready var tile_length_edit = $"../../ContentFrame/GridContainer/TileLengthEdit/LineEdit"
@onready var user_height_edit = $"../../ContentFrame/GridContainer/UserHeightEdit/LineEdit"
@onready var decay_edit = $"../../ContentFrame/GridContainer/DecayEdit/LineEdit"
@onready var freq_n_edit = $"../../ContentFrame/GridContainer/NFrequencyEdit/LineEdit"
@onready var n_user_edit = $"../../ContentFrame/GridContainer/NUserEdit/LineEdit"
@onready var path_width_edit = $"../../ContentFrame/GridContainer/PathWidthEdit/LineEdit"
@onready var building_decay_edit = $"../../ContentFrame/GridContainer/BuildingDecayEdit/LineEdit"


var on_work = true
var is_mouse_in = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	notice_label.size = Vector2(1200,50)
	var ref_pos = Vector2(-1.7*self.get_rect().size)
	notice_label.position = Vector2(0.67*ref_pos.x,ref_pos.y)
	self.set_focus_mode(FocusMode.FOCUS_ALL)

func restart_program(tile_length,user_height,n_channel,n_user,block_width,decay, building_decay):
	user_controller.initialize_user_system(user_height)
	tile_controller.initialize_map(tile_length,n_channel)
	mouse_panel.initialize_mouse_panel()
	user_controller.random_add_user(n_user,true)
	path_controller.set_block_width(block_width)
	tile_controller.set_decay(decay)
	tile_controller.set_building_decay(building_decay)
		
func apply_config(tile_length,user_height,n_channel,n_user,block_width, decay, building_decay):
	if tile_length != tile_controller.arc_len or len(user_controller.linear_user_list) != n_user:
		mouse_panel.initialize_mouse_panel()
		user_controller.initialize_user_system(user_height)
		tile_controller.initialize_map(tile_length,n_channel,false)
		user_controller.random_add_user(n_user,true)
	elif tile_controller.total_channel_number != n_channel:
		tile_controller.total_channel_number = n_channel
		tile_controller.all_tile_safely_reallocate_channels()
	
	if path_controller.block_width != block_width:
		path_controller.set_block_width(block_width)
	tile_controller.set_decay(decay)
	tile_controller.set_building_decay(building_decay)
	
	
	
func _gui_input(event):
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.pressed:
		self.on_work = false
		var tile_length = int(tile_length_edit.text)
		var user_height = int(user_height_edit.text)
		var decay = float(decay_edit.text)
		var n_freq = int(freq_n_edit.text)
		var n_user = int(n_user_edit.text)
		var block_width = int(path_width_edit.text)
		var building_decay = float(building_decay_edit.text)
			
		apply_config(tile_length, user_height,n_freq,n_user,block_width, decay, building_decay)
		config_panel.close_config_with_anime()
		
		await get_tree().create_timer(0.5).timeout
		self.on_work = true
		
func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_mouse_in_rect():
		self.grab_focus()
		self.parent_node.scale = Vector2(1.05,1.05)
		if int(tile_length_edit.text) != tile_controller.arc_len or len(user_controller.linear_user_list) != int(n_user_edit.text):
			notice_label.text = "[b]Notice:[/b] This operation [b]WILL[/b] remove all users currently on the map. "
		else:
			notice_label.text = "[b]Notice:[/b] Applying these configs will [b]NOT[/b] remove the users on the map. "
			
		notice_label.visible = true
	else:
		self.parent_node.scale = Vector2(1,1)
		notice_label.visible = false
