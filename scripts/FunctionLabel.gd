extends Control

@onready var anime_player = $AnimationPlayer
@onready var label = $Label
var length = 240
var width = 80
var slash_len = 15

func _draw():
	draw_line(Vector2(-length/2+slash_len, -width/2),Vector2(length/2-slash_len, -width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2-slash_len, -width/2), Vector2(length/2, -width/2+slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, -width/2+slash_len),Vector2(length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, width/2 - slash_len), Vector2(length/2 - slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2 - slash_len, width/2), Vector2(-length/2 + slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2 + slash_len, width/2), Vector2(-length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, width/2 - slash_len), Vector2(-length/2, -width/2 + slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, -width/2 + slash_len), Vector2(-length/2 + slash_len, -width/2), Color(0,0,0), 5, true)
	draw_polygon([Vector2(-length/2 + slash_len, -width/2),
					Vector2(length/2 - slash_len, -width/2),
					Vector2(length/2, -width/2 + slash_len),
					Vector2(length/2, width/2 - slash_len),
					Vector2(length/2 - slash_len, width/2),
					Vector2(-length/2 + slash_len, width/2),
					Vector2(-length/2, width/2 - slash_len),
					Vector2(-length/2, -width/2 + slash_len)],
					[Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),
					Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255)])

func set_text(text:String):
	self.label.text = text

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	self.scale = Vector2(1,1)
	self.position = Vector2(-135,48)
	self.pivot_offset = Vector2(length/2, width/2)
	self.label.size = Vector2(length, width)
	self.label.position = Vector2(-length/2, -width/2)
	appear_with_anime()

func appear_with_anime():
	self.visible = true
	anime_player.play("appear")
	
func disappear_with_anime():
	anime_player.play("disappear")
	await anime_player.animation_finished
	self.visible = false
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
