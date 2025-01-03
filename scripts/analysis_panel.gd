extends Control

@onready var title = $Title
@onready var plot_frame = $PlotPanel
@onready var user_select_panel = $UserSelectPanel
@onready var user_select = $"UserSelectPanel/UserSelectEdit"
@onready var results_panel = $ResultsPanel
@onready var animator = $AnimationPlayer
@onready var mouse_panel = $"../MousePanel"
@onready var user_controller = $"../Controllers/UserController"

var length = 1850
var width = 1000
var slash_len = 50

var current_user
var on_work = true

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.size = Vector2(self.length,self.width)
	self.pivot_offset = Vector2(self.length/2,self.width/2)
	self.position = Vector2((1920-self.length)/2,(1080-self.width)/2)
	title.size = Vector2(self.size.x,self.size.y/10)
	title.position = Vector2(0,0)
	user_select_panel.position = Vector2(self.slash_len,self.width-3.*self.slash_len)

func set_current_user_by_index(index:int):
	if index < 0:
		self.current_user = null
		# print("AnalysisPanel <set_current_user_by_index>: Negative Index Assignment")
		return
	self.current_user = user_controller.linear_user_list[index]

func set_current_user_by_id(id:int):
	var index = user_controller.binary_search_user_in_linear_user_list(id)
	
	if index != -1:
		self.current_user = user_controller.linear_user_list[index]
	else:
		self.current_user = null
	
func appear():
	self.visible = true
	self.animator.play("appear")
	self.on_work = false
	mouse_panel.on_analysis_panel_open()
	if user_controller.linear_user_list != [] and self.current_user == null:
		user_select.initialize(str(user_controller.linear_user_list[0].id))
		set_current_user_by_index(0)
	elif user_controller.linear_user_list == []:
		user_select.initialize(str(0))
		set_current_user_by_index(-1)
	await self.animator.animation_finished
	self.on_work = true
	
func disappear():
	self.animator.play("disappear")
	self.on_work = false
	mouse_panel.on_analysis_panel_close()
	await self.animator.animation_finished
	self.visible = false
	self.on_work = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
