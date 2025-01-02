extends Panel

@onready var analysis_panel = $".."
@onready var analysis_panel_title = $"../Title"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.size = Vector2(analysis_panel.length*0.95,analysis_panel.width*0.6)
	self.position = Vector2((analysis_panel.length-self.size.x)/2,analysis_panel_title.size.y*1.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
