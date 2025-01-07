extends Panel
@onready var analysis_panel = $"../.."
@onready var label = $Label
@onready var plot_frame = $"../../PlotFrame"
var is_mouse_in = false
# DO NOT replace this variable (analysis_on) with those
# store under the function buttons. 
# This variable changes at a slightly different 
#  occursion compared to those ones.
var analysis_on = false
var on_work = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pivot_offset = self.size/2
	

func button_click_function():
	if plot_frame.current_display_mode == plot_frame.DisplayMode.SIGNAL:
		plot_frame.current_display_mode = plot_frame.DisplayMode.SIR
		self.label.text = "SIR"
	else:
		plot_frame.current_display_mode = plot_frame.DisplayMode.SIGNAL
		self.label.text = "Signal Power"

func _input(event: InputEvent) -> void:
	if (analysis_panel.visible and analysis_panel.on_work) and self.on_work:
		if event is InputEventKey and event.keycode==KEY_P and event.is_pressed():
			self.on_work = false
			self.button_click_function()
			self.on_work = true

func _gui_input(event: InputEvent) -> void:
	if not on_work:
		return
		
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP) and event.is_pressed():
		self.on_work = false
		self.button_click_function()
		self.on_work = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.label.size = self.size
	if not self.get_rect().has_point(self.get_local_mouse_position()+self.get_rect().position) and self.is_mouse_in:
		self.is_mouse_in = false
		self.scale = Vector2(1,1)
	elif self.get_rect().has_point(self.get_local_mouse_position()+self.get_rect().position) and not self.is_mouse_in:
		self.is_mouse_in = true
		self.scale = Vector2(1.02,1.02)
