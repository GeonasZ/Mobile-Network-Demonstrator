extends Polygon2D

@onready var grid_container = $GridContainer

var length = 1440
var width = 740
var slash_len = 100
var on_work = true
var origin = Vector2(1980/2, 1080/2)
var viewport = null

var y_offset = 20

func _draw():
	draw_set_transform(Vector2(0,y_offset))
	draw_line(Vector2(-length/2+slash_len, -width/2),Vector2(length/2-slash_len, -width/2), Color(0,0,0), 3, true)
	draw_line(Vector2(length/2-slash_len, -width/2), Vector2(length/2, -width/2+slash_len), Color(0,0,0), 3, true)
	draw_line(Vector2(length/2, -width/2+slash_len),Vector2(length/2, width/2 - slash_len), Color(0,0,0), 3, true)
	draw_line(Vector2(length/2, width/2 - slash_len), Vector2(length/2 - slash_len, width/2), Color(0,0,0), 3, true)
	draw_line(Vector2(length/2 - slash_len, width/2), Vector2(-length/2 + slash_len, width/2), Color(0,0,0), 3, true)
	draw_line(Vector2(-length/2 + slash_len, width/2), Vector2(-length/2, width/2 - slash_len), Color(0,0,0), 3, true)
	draw_line(Vector2(-length/2, width/2 - slash_len), Vector2(-length/2, -width/2 + slash_len), Color(0,0,0), 3, true)
	draw_line(Vector2(-length/2, -width/2 + slash_len), Vector2(-length/2 + slash_len, -width/2), Color(0,0,0), 3, true)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.polygon = [Vector2(-length/2 + slash_len, -width/2+y_offset),
				Vector2(length/2 - slash_len, -width/2+y_offset),
				Vector2(length/2, -width/2 + slash_len+y_offset),
				Vector2(length/2, width/2 - slash_len+y_offset),
				Vector2(length/2 - slash_len, width/2+y_offset),
				Vector2(-length/2 + slash_len, width/2+y_offset),
				Vector2(-length/2, width/2 - slash_len+y_offset),
				Vector2(-length/2, -width/2 + slash_len+y_offset)]
	self.color = Color(255,255,255)
	self.position = Vector2(1920/2, 480)
	grid_container.custom_minimum_size = Vector2(self.length*4/5,self.width*4/5)
	grid_container.position = Vector2(-self.length*2/5,-self.width*2/5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
