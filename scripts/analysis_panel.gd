extends Control

@onready var title = $Title
@onready var user_select_panel = $UserSelectPanel
@onready var plot_select_panel = $PlotSelectPanel
@onready var n_plot_data_panel = $NPlotDataPanel
@onready var user_select = $"UserSelectPanel/UserSelectEdit"
@onready var n_plot_data_edit = $NPlotDataPanel/NPlotDataEdit
@onready var results_panel = $ResultsPanel
@onready var animator = $AnimationPlayer
@onready var mouse_panel = $"../MousePanel"
@onready var user_controller = $"../Controllers/UserController"
@onready var analysis_mode_button = $"../FunctionPanel/AnalysisModeButton"
@onready var analysis_button = $AnalysisButton
@onready var plot_frame = $PlotFrame

var length = 1850
var width = 1000
var slash_len = 50

var current_user
var on_work = true

var last_mouse_pos = null
var on_drag = false

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
	self.visible = false
	self.size = Vector2(self.length,self.width)
	self.pivot_offset = Vector2(self.length/2,self.width/2)
	self.position = Vector2((1920-self.length)/2,(1080-self.width)/2)
	title.size = Vector2(self.size.x,self.size.y/10)
	title.position = Vector2(0,self.width/64.)
	user_select_panel.position = Vector2(self.slash_len,self.width-1.65*self.slash_len+0.15*self.slash_len)
	n_plot_data_panel.position = Vector2(self.slash_len,self.width-3.3*self.slash_len+0.15*self.slash_len)
	results_panel.position = Vector2(self.length*0.285,self.width-4.95*self.slash_len+0.15*self.slash_len)
	plot_select_panel.position = Vector2(self.slash_len,self.width-5.2*self.slash_len+0.15*self.slash_len)
	n_plot_data_edit.initialize(plot_frame.n_displayed_data)
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and not on_drag:
		self.on_drag = true
		self.last_mouse_pos = get_global_mouse_position()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed() and on_drag:
		self.on_drag = false
		
## set current user by its index in the linear_user_list
func set_current_user_by_index(index:int):
	if self.current_user != null:
		self.current_user.set_boundary_color_default()
		self.current_user.hide_boundary()
		self.current_user.redraw_user()
		
	if index < 0:
		self.current_user = null
		return

	self.current_user = user_controller.linear_user_list[index]
	if self.current_user != null:
		self.current_user.set_boundary_color_red()
		self.current_user.show_boundary()
		self.current_user.redraw_user()
		

func set_current_user_by_id(id:int):
	if self.current_user != null:
		self.current_user.set_boundary_color_default()
		self.current_user.hide_boundary()
		self.current_user.redraw_user()
	var index = user_controller.binary_search_user_in_linear_user_list(id)
	
	if index != -1:
		self.current_user = user_controller.linear_user_list[index]
	else:
		self.current_user = null
		
	if self.current_user != null:
		self.current_user.set_boundary_color_red()
		self.current_user.show_boundary()
		self.current_user.redraw_user()
	
func appear():
	self.visible = true
	self.animator.play("appear")
	self.on_work = false
	
	if analysis_mode_button.analysis_on:
		analysis_button.set_analysis_start()
	else:
		analysis_button.set_analysis_end()
	
	mouse_panel.on_analysis_panel_open()
	if user_controller.linear_user_list != [] and self.current_user == null:
		user_select.initialize(str(user_controller.linear_user_list[0].id))
		set_current_user_by_index(0)
	elif user_controller.linear_user_list == []:
		user_select.initialize(str(0))
		set_current_user_by_index(-1)
	if current_user != null:
		self.current_user.set_boundary_color_red()
		current_user.show_boundary()
		self.current_user.redraw_user()
	await self.animator.animation_finished
	self.on_work = true
	
func disappear():
	if self.current_user != null:
		self.current_user.hide_boundary()
		self.current_user.set_boundary_color_default()
		self.current_user.redraw_user()
		
	self.animator.play("disappear")
	self.on_work = false
	mouse_panel.on_analysis_panel_close()
	await self.animator.animation_finished
	self.visible = false
	self.on_work = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.on_drag:
		self.position = self.position + (get_global_mouse_position()-self.last_mouse_pos)
		self.last_mouse_pos = get_global_mouse_position()
