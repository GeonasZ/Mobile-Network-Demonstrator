extends AnimationPlayer

@onready var gathered_tiles = $"../../GatheredTiles"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_animation_init_pos():
	var track_name_list = ["GatheredTiles:position","Users:position",
							"PathLayer:position"]
	var animation
	var track_index
	
	animation = self.get_animation("config_appear")
	for track_name in track_name_list:
		track_index = animation.find_track(track_name,Animation.TYPE_VALUE)
		animation.track_set_key_value(track_index,0,gathered_tiles.pos_after_zoom)
		animation.track_set_key_value(track_index,1,Vector2(-2000,0)+gathered_tiles.pos_after_zoom)
		
	animation = self.get_animation("config_disappear")
	for track_name in track_name_list:
		track_index = animation.find_track(track_name,Animation.TYPE_VALUE)
		#var start_key_value = animation.track_get_key_value(track_index,animation.length)
		animation.track_set_key_value(track_index,1,gathered_tiles.pos_after_zoom)
		animation.track_set_key_value(track_index,0,Vector2(-2000,0)+gathered_tiles.pos_after_zoom)
		#print(animation.track_get_key_time(track_index,1))
		#print(animation.length)
		
		
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
