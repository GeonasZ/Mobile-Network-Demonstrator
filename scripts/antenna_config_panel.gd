extends Control

@onready var animator = $AnimationPlayer
@onready var title = $Title
@onready var mouse_controller = $"../Controllers/MouseController"
@onready var content_frame_scroll = $ScrollContainer
@onready var content_frame_v = $ScrollContainer/VBoxContainer
@onready var engineer_button = $"../FunctionPanel/EngineerButton"
@onready var antenna_config_button = $"../FunctionPanel/AntennaConfigButton"

var length = 320
var width = 420
var slash_len = 20
var on_work = true

var focused_hex = null

func _draw():
	draw_set_transform(Vector2(length/2,width/2))
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
	
func move_to_station(station):
	# config x position
	if station.position.x > 960:
		self.position.x = station.position.x - 0.5* self.length - 1 * self.length
	else:
		self.position.x = station.position.x - 0.5* self.length + 1 * self.length
	# config y position
	if station.position.y < 270:
		self.position.y = station.position.y -0.5* self.width + 0.5* (270.-station.position.y)/270. * self.width
	elif station.position.y > 810:
		self.position.y = station.position.y -0.5* self.width - 0.5* (station.position.y-810.)/(1080.-810.) * self.width
	else:
		self.position.y = station.position.y -0.5* self.width
func appear():
	self.move_to_station(focused_hex)
	self.visible = true
	self.on_work = false
	self.title.text = "Station ID " + str(focused_hex.id) + " Edit"
	animator.play("appear")
	await animator.animation_finished
	self.on_work = true
	
func disappear():
	self.on_work = false
	animator.play("disappear")
	self.visible = false
	self.on_work = true

func set_antenna_mode_to_custom():
	antenna_config_button.set_antenna_mode_to_custom()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.size = Vector2(self.length,self.width)
	self.position = Vector2(500,500)
	self.pivot_offset = self.size/2.
	self.on_work = true
	title.size = Vector2(self.length,0)
	title.position = Vector2(0,self.slash_len/2)
	content_frame_scroll.size = Vector2(self.length,self.width*2/3)
	content_frame_scroll.position = Vector2(0,title.position.y+title.size.y+20)
	content_frame_v.size = content_frame_scroll.size
	content_frame_v.position = Vector2(0,0)
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_gathered_tiles_mouse_left_click_on_background(event) -> void:
	if mouse_controller.current_hex.is_center_on_focus() and self.on_work and engineer_button.button_mode == engineer_button.Mode.ENGINEER:
		self.focused_hex = mouse_controller.current_hex
		self.appear()
		
func _on_gathered_tiles_mouse_right_click_on_background(event) -> void:
	if self.visible:
		self.disappear()
