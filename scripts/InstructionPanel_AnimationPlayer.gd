extends AnimationPlayer

@onready var instr_panel = $".."
@onready var instr_button = $"../../FunctionPanel/InstructionButton"

var appear_time = 0.2
var disappear_time = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	# add position track to disappear animation
	var animation = self.get_animation("panel_disappear")
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index,"./:position")
	animation.track_insert_key(track_index, 0, instr_panel.origin)
	animation.track_insert_key(track_index, disappear_time, Vector2(1920,0), 1)
	# add position track to appear animation
	animation = self.get_animation("panel_appear")
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index,"./:position")
	animation.track_insert_key(track_index, 0, Vector2(1920,0), 1)
	animation.track_insert_key(track_index, appear_time, instr_panel.origin)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
