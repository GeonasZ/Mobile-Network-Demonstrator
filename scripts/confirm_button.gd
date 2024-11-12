extends Polygon2D

@onready var label = $Label

var length = 220
var width = 100
var slash_len = 20

func _draw():
	draw_line(Vector2(-length/2+slash_len, -width/2),Vector2(length/2-slash_len, -width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2-slash_len, -width/2), Vector2(length/2, -width/2+slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, -width/2+slash_len),Vector2(length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, width/2 - slash_len), Vector2(length/2 - slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2 - slash_len, width/2), Vector2(-length/2 + slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2 + slash_len, width/2), Vector2(-length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, width/2 - slash_len), Vector2(-length/2, -width/2 + slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, -width/2 + slash_len), Vector2(-length/2 + slash_len, -width/2), Color(0,0,0), 5, true)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.polygon = [Vector2(-length/2 + slash_len, -width/2),
				Vector2(length/2 - slash_len, -width/2),
				Vector2(length/2, -width/2 + slash_len),
				Vector2(length/2, width/2 - slash_len),
				Vector2(length/2 - slash_len, width/2),
				Vector2(-length/2 + slash_len, width/2),
				Vector2(-length/2, width/2 - slash_len),
				Vector2(-length/2, -width/2 + slash_len)]
	self.color = Color(255,255,255)
	self.position = Vector2(1920/2-1.3*length,1080*6/7)
	self.label.size = Vector2(self.length, self.width)
	self.label.position = Vector2(-1./2.*length,-1./2.*width)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
