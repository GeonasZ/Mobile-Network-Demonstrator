extends LineEdit

@onready var path_controller = $"../../../../../Controllers/PathController"
@onready var father_node = $".."

var max_value = 10
var min_value = 0
var legal_characters = ["0","1","2","3","4","5","6","7","8","9"]

var previous_text = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	father_node.set_focus_mode(FocusMode.FOCUS_ALL)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if self.text == self.previous_text:
		return
		
	var caret_location = self.caret_column
	var processed_text = ""
	
	for i in range(self.text.length()):
		if text[i] in legal_characters or (i>0 and text[i] == "."):
			processed_text += text[i]
		elif i < caret_location:
			caret_location -= 1
			
	if processed_text == "":
		self.text = ""
		self.previous_text = ""
		return
	
	self.text = str(processed_text)
	processed_text = float(processed_text)
	
	if caret_location > self.text.length():
		self.caret_column = self.text.length()
	else:
		self.caret_column = caret_location
		
	self.previous_text = self.text

func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())

func _gui_input(event: InputEvent) -> void:
	if self.text == "":
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
		if float(self.text) > min_value:
			print(float(self.text)-0.1)
			self.text = str(float(self.text)-0.1)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
		if float(self.text) < max_value:
			self.text = str(float(self.text)+0.1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.is_pressed() and not is_mouse_in_rect() and self.has_focus():
		focus_exited.emit()

func initialize():
	self.text = str(path_controller.get_blocking_attenuation())
	
	

func _on_focus_exited() -> void:
	father_node.grab_focus()
	if self.text == "":
		self.text = str(min_value)

	var length = float(self.text)
	if length > max_value:
		self.text = str(max_value)
	elif length < min_value:
		self.text = str(min_value)
