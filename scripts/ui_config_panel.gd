extends Control

@onready var animator = $AnimationPlayer
@onready var title = $Title
@onready var mouse_controller = $"../Controllers/MouseController"
@onready var scroll_container = $ScrollContainer
@onready var grid_container = $ScrollContainer/GridContainer
@onready var engineer_button = $"../FunctionPanel/EngineerButton"
@onready var antenna_config_button = $"../FunctionPanel/AntennaConfigButton"
@onready var mouse_panel = $"../MousePanel"
@onready var tile_controller = $"../Controllers/TileController"
@onready var ui_controller = $"../Controllers/UIStyleController"
@onready var scroll_container_border = $ScrollContainerBorder
@onready var confirm_button = $ConfirmButton
@onready var undo_button = $UndoButton
@onready var function_panel = $"../FunctionPanel"
@onready var user_controller = $"../Controllers/UserController"

var ui_color_option_prefab
var ui_placehold_prefab
var ui_tick_option_prefab

var option_list = []

signal station_config_panel_open
signal station_config_panel_close

var length = 1850
var width = 1000
var slash_len = 50
var on_work = true
var on_drag = false
var last_mouse_pos = null
var target_pos = null

var focused_hex = null

func _draw():
	draw_set_transform(Vector2(length/2,width/2))
	draw_line(Vector2(-length/2+slash_len, -width/2),Vector2(length/2-slash_len, -width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2-slash_len, -width/2), Vector2(length/2, -width/2+slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, -width/2+slash_len),Vector2(length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, width/2 - slash_len), Vector2(length/2 - slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2 - slash_len, width/2), Vector2(-length/2 + slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2 + slash_len, width/2), Vector2(-length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, width/2 - slash_len), Vector2(-length/2, -width/2 + slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, -width/2 + slash_len), Vector2(-length/2 + slash_len, -width/2), Color(0,0,0), 5, true)
	draw_polygon([Vector2(-length/2 + slash_len, -width/2),
					Vector2(length/2 - slash_len, -width/2),
					Vector2(length/2, -width/2 + slash_len),
					Vector2(length/2, width/2 - slash_len),
					Vector2(length/2 - slash_len, width/2),
					Vector2(-length/2 + slash_len, width/2),
					Vector2(-length/2, width/2 - slash_len),
					Vector2(-length/2, -width/2 + slash_len)],
					[Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),
					Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255)])
	

func appear():
	self.on_work = false
	user_controller.pause_all_user()
	mouse_panel.disappear_with_anime()
	await mouse_panel.anime_player.animation_finished
	animator.play("appear")
	self.scale = Vector2(0,0)
	self.visible = true
	await animator.animation_finished
	self.on_work = true
	
func disappear():
	self.on_work = false
	animator.play("disappear")
	await animator.animation_finished
	mouse_panel.appear_with_anime()
	self.visible = false
	self.on_work = true
	user_controller.resume_all_user()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and not on_drag:
		self.on_drag = true
		self.last_mouse_pos = get_global_mouse_position()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed() and on_drag:
		self.on_drag = false

func ui_config_option_fill_values():
	for option in option_list:
		if option.option_type == "Color":
			if option.subject == option.UISubject.CELL_COLOR:
				option.set_color(ui_controller.ui_style_history[-1][option.UISubject.CELL_COLOR][option.id_in_group])
			else:
				option.set_color(ui_controller.ui_style_history[-1][option.subject])
		elif option.option_type == "Tick":
			option.set_button(ui_controller.ui_style_history[-1][option.subject])
		else:
			print("UIConfigPanel<ui_config_option_fill_values>: Unknown option type.")

func init_ui_config_panel():
	var tile_color_list = ui_controller.default_tile_color_list
	var building_color = ui_controller.default_building_color
	var building_wall_color = ui_controller.default_building_wall_color
	var lawn_color = ui_controller.default_lawn_color
	var lawn_edge_color = ui_controller.default_lawn_edge_color
	var lake_color = ui_controller.default_lake_color
	var lake_border_color = ui_controller.default_lake_border_color
	var cell_border_color = ui_controller.default_cell_border_color
	
	# make a list consisting of all other ui color features apart from 
	# the cell colors
	var other_ui_color_option_list = [ui_controller.UISubject.BUILDING_COLOR,
	ui_controller.UISubject.BUILDING_BORDER, ui_controller.UISubject.LAWN_BORDER,
	ui_controller.UISubject.LAWN_COLOR, ui_controller.UISubject.LAKE_COLOR, 
	ui_controller.UISubject.LAKE_BORDER, ui_controller.UISubject.CELL_BORDER]
	
	# instantiate two placeholders first
	for i in range(2):
		var ph = ui_placehold_prefab.instantiate()
		grid_container.add_child(ph)
	
	# define id
	var id = 0
	var option
	
	# instanciate the map shading tick option
	option = ui_tick_option_prefab.instantiate()
	grid_container.add_child(option)
	self.option_list.append(option)
	option.initialize(tile_controller, ui_controller)
	option.set_id(id)
	option.set_subject(ui_controller.UISubject.MAP_SHADING)
	option.set_option_name("Map Shading: ")
	id += 1
	
	# instanciate the options regarding to the cell color
	for j in range(len(tile_color_list)):
		option = ui_color_option_prefab.instantiate()
		grid_container.add_child(option)
		option.initialize(tile_controller, ui_controller)
		self.option_list.append(option)
		option.set_subject(ui_controller.UISubject.CELL_COLOR)
		option.set_id(id)
		option.set_id_in_group(j)
		option.set_option_name("Cell Color %d: " % (j+1))
		id += 1
		
	# instanciate the options regarding to other ui features
	for j in range(len(other_ui_color_option_list)):
		option = ui_color_option_prefab.instantiate()
		grid_container.add_child(option)
		option.initialize(tile_controller, ui_controller)
		self.option_list.append(option)
		option.set_subject(other_ui_color_option_list[j])
		option.set_id(id)
		match other_ui_color_option_list[j]:
			ui_controller.UISubject.BUILDING_COLOR:
				option.set_option_name("Building Color: ")
			ui_controller.UISubject.BUILDING_BORDER:
				option.set_option_name("Building Walls Color: ")
			ui_controller.UISubject.LAWN_BORDER:
				option.set_option_name("Lawn Border Color: ")
			ui_controller.UISubject.LAWN_COLOR:
				option.set_option_name("Lawn Color: ")
			ui_controller.UISubject.LAKE_COLOR:
				option.set_option_name("Lake Color: ")
			ui_controller.UISubject.LAKE_BORDER:
				option.set_option_name("Lake Border Color: ")
			ui_controller.UISubject.CELL_BORDER:
				option.set_option_name("Cell Border Color: ")
			_:
				print("UIConfigPanel<init_ui_config_panel>: Invalid UI Color Type.")
		id += 1
		
	# instantiate two placeholders at the end
	for i in range(2):
		var ph = ui_placehold_prefab.instantiate()
		grid_container.add_child(ph)
		
	ui_config_option_fill_values()
		
#func refresh_ui_config_panel_history():
	#var tile_color_list
	#var building_color
	#var building_wall_color
	#var lawn_color
	#var lawn_edge_color
	#var lake_color
	#var lake_border_color
	#var cell_border_color
	#if ui_controller.ui_style_history:
		#tile_color_list = ui_controller.ui_style_history[-1][ui_controller.UISubject.CELL_COLOR]
		#building_color = ui_controller.ui_style_history[-1][ui_controller.UISubject.BUILDING_COLOR]
		#building_wall_color = ui_controller.ui_style_history[-1][ui_controller.UISubject.BUILDING_BORDER]
		#lawn_color = ui_controller.ui_style_history[-1][ui_controller.UISubject.LAWN_COLOR]
		#lawn_edge_color = ui_controller.ui_style_history[-1][ui_controller.UISubject.LAWN_BORDER]
		#lake_color = ui_controller.ui_style_history[-1][ui_controller.UISubject.LAKE_COLOR]
		#lake_border_color = ui_controller.ui_style_history[-1][ui_controller.UISubject.LAKE_BORDER]
		#cell_border_color = ui_controller.ui_style_history[-1][ui_controller.UISubject.CELL_BORDER]
	#else:
		#tile_color_list = ui_controller.customized_tile_color_list
		#building_color = ui_controller.default_building_color
		#building_wall_color = ui_controller.default_building_wall_color
		#lawn_color = ui_controller.default_lawn_color
		#lawn_edge_color = ui_controller.default_lawn_edge_color
		#lake_color = ui_controller.default_lake_color
		#lake_border_color = ui_controller.default_lake_border_color
		#cell_border_color = ui_controller.default_cell_border_color
	#ui_controller.update_ui_style_history({ui_controller.UISubject.CELL_COLOR:tile_color_list,
#ui_controller.UISubject.CELL_BORDER:cell_border_color, ui_controller.UISubject.LAWN_COLOR:lawn_color,
#ui_controller.UISubject.LAWN_BORDER:lawn_edge_color,ui_controller.UISubject.LAKE_COLOR:lake_color,
#ui_controller.UISubject.LAKE_BORDER:lake_border_color,ui_controller.UISubject.BUILDING_COLOR:building_color,
#ui_controller.UISubject.BUILDING_BORDER:building_wall_color})

func init_buttons():
	confirm_button.size = Vector2(200,80)
	confirm_button.position = Vector2(self.size.x*0.65-0.5*confirm_button.size.x,self.size.y*0.85)
	confirm_button.pivot_offset = confirm_button.size*0.5
	confirm_button.init_label()
	undo_button.size = Vector2(200,80)
	undo_button.position = Vector2(self.size.x*0.35-0.5*undo_button.size.x,self.size.y*0.85)
	undo_button.pivot_offset = undo_button.size*0.5
	undo_button.init_label()
	
func close():
	self.disappear()
	await animator.animation_finished
	function_panel.all_button_smart_appear()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	self.size = Vector2(self.length,self.width)
	self.pivot_offset = Vector2(self.length/2,self.width/2)
	self.position = Vector2((1920-self.length)/2,(1080-self.width)/2)
	title.size = Vector2(self.size.x,self.size.y/10)
	title.position = Vector2(0,self.width/64.)
	self.on_work = true
	title.size = Vector2(self.length,0)
	title.position = Vector2(0,self.slash_len/2)
	scroll_container.size = Vector2(self.length*0.88,self.width*2/3)
	scroll_container.position = Vector2((self.size.x-scroll_container.size.x)*0.5,title.position.y+title.size.y+20)
	scroll_container_border.size = scroll_container.size
	scroll_container_border.position = scroll_container.position
	grid_container.size = scroll_container.size
	grid_container.size = scroll_container.size
	grid_container.position = Vector2(0,0)
	self.visible = false
	ui_color_option_prefab = preload("res://scenes/ui_color_option_prefab.tscn")
	ui_placehold_prefab = preload("res://scenes/ui_config_panel_grid_container_place_holder_prefab.tscn")
	ui_tick_option_prefab = preload("res://scenes/ui_tick_option_prefab.tscn")
	init_ui_config_panel()
	var vscroll_bar = scroll_container.get_v_scroll_bar()
	vscroll_bar.custom_minimum_size.x = 40
	init_buttons()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.on_drag:
		self.position = self.position + (get_global_mouse_position()-self.last_mouse_pos)
		self.last_mouse_pos = get_global_mouse_position()
	if self.target_pos != null:
		self.position += 10*(self.target_pos - self.position)*delta
		if self.target_pos.distance_to(self.position) < 10:
			self.target_pos = null
		
func _on_gathered_tiles_mouse_right_click_on_background(event) -> void:
	if self.visible:
		self.disappear()
		mouse_panel.track_mouse()
