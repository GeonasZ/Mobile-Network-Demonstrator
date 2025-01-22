extends Control

var background_alpha = int(0.3*255)

func _draw() -> void:
	# draw the background of blocks
	draw_rect(Rect2(Vector2(0,0),Vector2(1920,1080)),Color8(255,255,255,background_alpha),true)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
