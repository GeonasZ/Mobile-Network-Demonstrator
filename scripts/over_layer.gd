extends Control

var keep_invisible = true
var station_direction_indicator_length_ratio = 0.8
var delta = 1

var dash_line_color = Color8(120,120,120)
var anime_indicate_line_color = Color8(70,70,70,200)

@onready var mouse_controller = $"../Controllers/MouseController"
@onready var tile_controller = $"../Controllers/TileController"
@onready var user_controller = $"../Controllers/UserController"
@onready var analysis_panel = $"../AnalysisPanel"
@onready var station_config_panel = $"../StationConfigPanel"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(0,0)
	self.size = Vector2(1920,1080)

func make_invisible():
	self.keep_invisible = true

func make_visible():
	self.keep_invisible = false
	
func _draw() -> void:
	if mouse_controller.current_hex != null:
		var hex_center = mouse_controller.current_hex.get_global_transform()*Vector2(0,0)
		var station_scale = mouse_controller.current_hex.station_scale
		if not keep_invisible:
			# draw a line for mouse and closest station
			if not analysis_panel.visible and not station_config_panel.visible:
				draw_dashed_line(hex_center, get_local_mouse_position(),dash_line_color,5*station_scale,10*station_scale)
			# draw directions for each station
			var station_global_transform
			var global_station_pos
			var global_dir_line1
			var global_dir_line2
			var direction
			var hex
			var angle_size
			for i in range(tile_controller.hex_list.size()):
				for j in range(tile_controller.hex_list[i].size()):
					hex = tile_controller.hex_list[i][j]
					angle_size = hex.get_divergence_angle()
					station_global_transform = hex.get_global_transform()
					global_station_pos = station_global_transform * Vector2(0,0)
					# if angle size is not applicable for this tile
					if angle_size == null:
						if user_controller.user_list[i][j]["connected"].size() > 0 and hex.is_next_signal_proporgation_ready():
							draw_circle(global_station_pos,hex.current_signal_radius,anime_indicate_line_color,false,5*station_scale)
							hex.current_signal_radius += self.delta * hex.signal_proporgation_ratio_per_second * hex.arc_len
							hex.current_signal_alpha -= self.delta * 220 / (hex.max_signal_radius_ratio/hex.signal_proporgation_ratio_per_second)
							if hex.current_signal_radius > hex.arc_len*hex.max_signal_radius_ratio:
								hex.current_signal_radius = 0
								hex.current_signal_alpha = 255
								hex.start_wait_for_next_signal_proporgation()
						else:
							hex.current_signal_alpha = 255
							hex.current_signal_radius = 0
					elif user_controller.user_list[i][j]["connected"].size() > 0:
						direction = tile_controller.eval_station_direction(tile_controller.hex_list, user_controller.user_list,i,j)
						global_dir_line1 = station_global_transform * (station_direction_indicator_length_ratio*hex.arc_len*direction.rotated(angle_size/2.))
						global_dir_line2 = station_global_transform * (station_direction_indicator_length_ratio*hex.arc_len*direction.rotated(-angle_size/2.))

						draw_line(global_station_pos, global_dir_line1,anime_indicate_line_color,5*station_scale)
						draw_line(global_station_pos, global_dir_line2,anime_indicate_line_color,5*station_scale)
					
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.delta = delta
	queue_redraw()
