extends Control

@onready var tile_controller = $"../TileController"
@onready var ui_config_panel = $"../../UIConfigPanel"
@onready var path_controller = $"../PathController"
@onready var path_layer = $"../../PathLayer"

enum UISubject {CELL_COLOR,CELL_BORDER,LAWN_COLOR,LAWN_BORDER,
				LAKE_COLOR,LAKE_BORDER, BUILDING_COLOR, BUILDING_BORDER, MAP_SHADING}
				
# default color style
var default_tile_color_dict = {"blue":Color8(173,216,230),"violet":Color8(198,164,232), 
"red":Color8(180,248,245), "yellow":Color8(255,255,224), "purple":Color8(230,230,250),
"mint_mist":Color8(230,255,230),"gray":Color8(211,211,211), "cyan": Color8(224,255,255),
"coral":Color8(250,209,175),"gold": Color8(240,230,140),"green":Color8(152,251,152),
"lavender":Color8(255,240,245)}

var default_tile_color_list = [Color8(173,216,230),Color8(198,164,232),
Color8(255,182,193), Color8(255,255,224),Color8(230,230,250), 
Color8(230,255,230), Color8(211,211,211),Color8(224,255,255),
Color8(250,209,175),Color8(240,230,140),Color8(152,251,152), 
Color8(255,240,245)]

var default_cell_border_color = Color8(50,50,50,255)

var default_building_color = Color8(128,128,128,204)
var default_building_wall_color = Color8(77,77,77,204)
var default_lawn_color = Color8(102,204,102,179)
var default_lawn_edge_color = Color8(13,13,13,204)
var default_lake_color = Color8(100,100,220)
var default_lake_border_color = Color8(0,0,255,255)
var map_shading_color = Color(1,1,1,0.3)
var default_map_shading = true

# customised color style
var customized_tile_color_list = []

var ui_style_history = [{UISubject.CELL_COLOR:default_tile_color_list,
UISubject.CELL_BORDER:default_cell_border_color, UISubject.LAWN_COLOR:default_lawn_color,
UISubject.LAWN_BORDER:default_lawn_edge_color,UISubject.LAKE_COLOR:default_lake_color,
UISubject.LAKE_BORDER:default_lake_border_color,UISubject.BUILDING_COLOR:default_building_color,
UISubject.BUILDING_BORDER:default_building_wall_color, UISubject.MAP_SHADING:default_map_shading}]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_all_ui_style():
	# set the tile color list and border to the up-to-date version
	tile_controller.tile_color_list = self.ui_style_history[-1][UISubject.CELL_COLOR]
	tile_controller.tile_border_color = self.ui_style_history[-1][UISubject.CELL_BORDER]
	# update all cells
	tile_controller.all_tile_update_color()
	# update all path blocks
	path_controller.update_all_path_block_color_style()
	# update map shading
	path_layer.do_map_shading = self.ui_style_history[-1][UISubject.MAP_SHADING]
	path_layer.redraw()
	
func append_ui_style_history(hist_data):
	ui_style_history.append(hist_data)
	
func pop_back_ui_style_history():
	if len(ui_style_history) > 1:
		ui_style_history.pop_back()
		ui_config_panel.ui_config_option_fill_values()

func _on_color_edit_value_changed(id) -> void:
	var last_style = self.ui_style_history[-1].duplicate(true)
	var option = ui_config_panel.option_list[id]
	if option.option_type == "Color":
		var color = option.get_color()
		if option.subject == UISubject.CELL_COLOR:
			last_style[UISubject.CELL_COLOR][option.id_in_group] = color
		else:
			last_style[option.subject] = color
	elif option.option_type == "Tick":
		last_style[option.subject] = option.tick_on
	else:
		print("UIStyleController<_on_color_edit_value_changed>: Unkwon Option Type.")
	append_ui_style_history(last_style)
	update_all_ui_style()
			
