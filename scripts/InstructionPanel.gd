extends Polygon2D

@onready var animator = $AnimationPlayer
@onready var function_panel = $"../FunctionPanel"
@onready var title_label = $TitleLabel
@onready var content_label = $ContentLabel
@onready var mouse_panel = $"../MousePanel"


var length = 1480
var width = 840
var slash_len = 60
var on_work = true
var origin = Vector2(1980/2, 1080/2)
var viewport = null

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
func _ready():
	self.visible = true
	self.skew = 0
	self.scale = Vector2(1, 1)
	self.rotation = 0
	self.position = self.origin
	self.polygon = [Vector2(-length/2 + slash_len, -width/2),
					Vector2(length/2 - slash_len, -width/2),
					Vector2(length/2, -width/2 + slash_len),
					Vector2(length/2, width/2 - slash_len),
					Vector2(length/2 - slash_len, width/2),
					Vector2(-length/2 + slash_len, width/2),
					Vector2(-length/2, width/2 - slash_len),
					Vector2(-length/2, -width/2 + slash_len)]
	self.color = Color(255,255,255)
	title_label.position = Vector2(-title_label.size.x/2, -0.46*width)
	content_label.position = Vector2(-title_label.size.x/2, -0.36*width)
	content_label.text = "[center][b]Welcome to the mobile network demonstrator[/b][/center]
[u]Here are some basic instructions to help you start with this program.[/u]
[b]Left Click[/b] on the map to add a user to the field.
[b]Right Click[/b] on the map to show /hide the panel following your mouse.
[b]Hover[/b] on the buttons on the righthand side to see their functions.
[b]Left Click[/b] on the buttons to use.
[b]Left Click[/b] on the observer mode button to enter observer mode.
[b]Hover[/b] on the base station to see its detailed information.
[b]Left Click[/b] on the base station to track the realtime station information.
[b]Hover[/b] on the user to see their detailed information in observer mode.
[b]Left Click[/b] on the user to track their realtime information in observer mode.

[center][b]More functionalities to be found......[/b][/center]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.pressed and self.on_work:
		if self.visible:
			function_panel.all_button_appear_with_instr_panel_disappear()
			function_panel.instruction_panel_visibility = false
