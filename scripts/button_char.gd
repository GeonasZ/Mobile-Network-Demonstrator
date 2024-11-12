extends Label

@onready var parent_node = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(1,-3)
	self.size = Vector2(2*parent_node.button_radius,2*parent_node.button_radius)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
