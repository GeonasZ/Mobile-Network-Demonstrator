extends Button

@onready var analysis_panel = $".."
@onready var analysis_panel_button = $"../../FunctionPanel/AnalysisPanelButton"

var is_mouse_in = false

var on_work = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(analysis_panel.length/7*6.,self.size.y/1.8)
	self.size = Vector2(200,80)
	self.pivot_offset = self.size/2

func _input(event: InputEvent) -> void:
	if (analysis_panel.visible and analysis_panel.on_work) and self.on_work:
		if event is InputEventKey and event.keycode == KEY_A and event.is_pressed():
			self.on_work = false
			analysis_panel_button.button_click_function()
			await get_tree().create_timer(0.2).timeout
			self.on_work = true

func _gui_input(event: InputEvent) -> void:
	if not on_work:
		return
		
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.is_pressed():
		self.on_work = false
		analysis_panel_button.button_click_function()
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
