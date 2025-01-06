extends Panel

@onready var analysis_panel = $".."
@onready var user_controller = $"../../Controllers/UserController"
@onready var analysis_mode_button = $"../../FunctionPanel/AnalysisModeButton"
@onready var label = $Label
enum ButtonFunc {START,PAUSE,RESUME}
var length = 360
var width = 80
var slash_len = 10
var current_button_func = self.ButtonFunc.START
var is_mouse_in = false
# DO NOT replace this variable (analysis_on) with those
# store under the function buttons. 
# This variable changes at a slightly different 
#  occursion compared to those ones.
var analysis_on = false
var on_work = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(analysis_panel.length/10.,self.size.y/1.8)
	self.size = Vector2(self.length,self.width)
	self.label.size = self.size
	self.pivot_offset = self.size/2
	

func set_analysis_start():
	self.analysis_on = true
	label.text = "Pause Analysis"
	self.current_button_func = ButtonFunc.PAUSE

func set_analysis_end():
	self.analysis_on = false
	if user_controller.linear_user_list != []:
		if user_controller.linear_user_list[0].sir_hist != []:
			label.text = "Resume Analysis"
			self.current_button_func = ButtonFunc.RESUME
			return
	label.text = "Start Analysis"
	self.current_button_func = ButtonFunc.START

func button_click_function():
	if self.analysis_on:
		set_analysis_end()
	else:
		set_analysis_start()
	# click analysis_mode_button with append = true
	analysis_mode_button.button_click_function(true)


func _input(event: InputEvent) -> void:
	if (analysis_panel.visible and analysis_panel.on_work) and self.on_work:
		if event is InputEventKey and (self.current_button_func==ButtonFunc.START and event.keycode == KEY_S or self.current_button_func==ButtonFunc.PAUSE and event.keycode == KEY_P or self.current_button_func==ButtonFunc.RESUME and event.keycode==KEY_R) and event.is_pressed():
			self.on_work = false
			self.button_click_function()
			await get_tree().create_timer(0.2).timeout
			self.on_work = true

func _gui_input(event: InputEvent) -> void:
	if not on_work:
		return
		
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.is_pressed():
		self.on_work = false
		self.button_click_function()
		await get_tree().create_timer(0.2).timeout
		self.on_work = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not self.get_rect().has_point(self.get_local_mouse_position()+self.get_rect().position) and self.is_mouse_in:
		self.is_mouse_in = false
		self.scale = Vector2(1,1)
	elif self.get_rect().has_point(self.get_local_mouse_position()+self.get_rect().position) and not self.is_mouse_in:
		self.is_mouse_in = true
		self.scale = Vector2(1.02,1.02)
