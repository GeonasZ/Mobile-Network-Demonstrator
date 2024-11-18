extends LineEdit

@onready var mouse_panel = $"../../../../../MousePanel"
@onready var father_node = $".."


var legal_characters = ["0","1","2","3","4","5","6","7","8","9"]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	father_node.set_focus_mode(FocusMode.FOCUS_ALL)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var caret_location = self.caret_column
	var processed_text = ""
	var has_float = false
	
	for i in range(self.text.length()):
		if text[i] in legal_characters or 1:
			processed_text += text[i]
		elif i > 0 and text[i] == '.' and not has_float:
			has_float = true
			processed_text += text[i]
			
	if processed_text == "":
		self.text = ""
		return
		
	self.text = str(processed_text)
	if caret_location > self.text.length():
		self.caret_column = self.text.length()
	else:
		self.caret_column = caret_location

func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.is_pressed() and not is_mouse_in_rect() and self.has_focus():
		focus_exited.emit()

func initialize():
	self.text = str(mouse_panel.decay)
	
	

func _on_focus_exited() -> void:
	var max_value = 5
	var min_value = 2
	father_node.grab_focus()
	if self.text == "":
		self.text = str(min_value)

	var length = float(self.text)
	if length > max_value:
		self.text = str(max_value)
	elif length < min_value:
		self.text = str(min_value)
