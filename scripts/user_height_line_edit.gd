extends LineEdit

@onready var user_controller = $"../../../../../Controllers/UserController"
@onready var father_node = $".."


var legal_characters = ["0","1","2","3","4","5","6","7","8","9"]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	father_node.set_focus_mode(FocusMode.FOCUS_ALL)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var caret_location = self.caret_column
	var processed_text = ""
	
	for i in range(self.text.length()):
		if text[i] in legal_characters:
			processed_text += text[i]
			
	if processed_text == "":
		self.text = ""
		return
		
	processed_text = int(processed_text)
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
	self.text = str(user_controller.user_height)

func _on_focus_exited() -> void:
	father_node.grab_focus()
	if self.text == "":
		self.text = str(5)
	var length = int(self.text)
	if length > 100:
		self.text = str(100)
	elif length < 5:
		self.text = str(5)
