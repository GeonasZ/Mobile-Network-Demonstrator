extends LineEdit

@onready var user_controller = $"../../../Controllers/UserController"
@onready var analysis_panel = $"../.."
@onready var plot_frame = $"../../PlotFrame"

var legal_characters = ["0","1","2","3","4","5","6","7","8","9"]

var min_value = 20
var max_value = 500
var previous_text = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	analysis_panel.set_focus_mode(FocusMode.FOCUS_ALL)
	
func mouse_wheel_scroll_function(button_index):
	if button_index == MOUSE_BUTTON_WHEEL_UP:
		if int(self.text) > self.min_value:
			self.text = str(int(self.text)-1)
		plot_frame.n_displayed_data = int(self.text)
	elif button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if int(self.text) < self.max_value:
			self.text = str(int(self.text)+1)
		plot_frame.n_displayed_data = int(self.text)
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
		self.mouse_wheel_scroll_function(MOUSE_BUTTON_WHEEL_UP)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
		self.mouse_wheel_scroll_function(MOUSE_BUTTON_WHEEL_DOWN)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not analysis_panel.visible:
		return
		
	if self.text == self.previous_text:
		return
	
	var caret_location = self.caret_column
	var processed_text = ""
	
	for i in range(self.text.length()):
		if text[i] in legal_characters:
			processed_text += text[i]
			
	if processed_text == "":
		self.text = ""
		self.previous_text = self.text
		return

	processed_text = processed_text.lstrip("0")
	if processed_text == "":
		processed_text = "0"
		
	self.text = str(processed_text)
	
	if caret_location > self.text.length():
		self.caret_column = self.text.length()
	else:
		self.caret_column = caret_location
		
	self.previous_text = self.text
	plot_frame.n_displayed_data = int(self.text)

func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.is_pressed() and not is_mouse_in_rect() and self.has_focus():
		focus_exited.emit()

func initialize(n_data:int):
	self.text = str(n_data)

func _on_focus_exited() -> void:
	analysis_panel.grab_focus()
