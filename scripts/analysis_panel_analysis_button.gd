extends Panel

@onready var analysis_panel = $".."
@onready var analysis_mode_button = $"../../FunctionPanel/AnalysisModeButton"
@onready var label = $Label

var length = 300
var width = 80
var slash_len = 10

var is_mouse_in = false
# DO NOT replace this variable (analysis_on) with those
# store under the function buttons. 
# This variable changes at a slightly different 
#  occursion compared to those ones.
var analysis_on = false
var on_work = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(analysis_panel.length/7.,self.size.y/1.8)
	self.size = Vector2(self.length,self.width)
	self.label.size = self.size
	self.pivot_offset = self.size/2

func set_analysis_start():
	self.analysis_on = true
	label.text = "End Analysis"

func set_analysis_end():
	self.analysis_on = false
	label.text = "Start Analysis"

func button_click_function():
	if self.analysis_on:
		set_analysis_end()
	else:
		set_analysis_start()
	analysis_mode_button.button_click_function()


func _input(event: InputEvent) -> void:
	if (analysis_panel.visible and analysis_panel.on_work) and self.on_work:
		if event is InputEventKey and (not self.analysis_on and event.keycode == KEY_S or self.analysis_on and event.keycode == KEY_E) and event.is_pressed():
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
