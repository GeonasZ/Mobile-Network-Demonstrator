extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.size = Vector2(120,20)

func set_label_text(content):
	self.text = content

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
