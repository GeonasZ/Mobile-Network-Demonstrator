extends LineEdit

@onready var user_controller = $"../../../Controllers/UserController"
@onready var analysis_panel = $"../.."

var legal_characters = ["0","1","2","3","4","5","6","7","8","9"]

var previous_text = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	analysis_panel.set_focus_mode(FocusMode.FOCUS_ALL)
	
func set_caret_location(caret_location,to_end=false):
	print(caret_location)
	if to_end or caret_location > self.text.length():
		self.caret_column = self.text.length()
	else:
		self.caret_column = caret_location

func mouse_wheel_scroll_function(button_index):
	var index = user_controller.binary_search_user_in_linear_user_list(int(self.text))
	var caret_location = self.caret_column
	
	if user_controller.linear_user_list.is_empty():
		analysis_panel.set_current_user_by_index(-1)
		self.text = "0"
		self.set_caret_location(1,true)
		return
	
	# if current user does not exist
	if index == -1:
		if button_index == MOUSE_BUTTON_WHEEL_UP:
			if self.text == "0":
				analysis_panel.set_current_user_by_index(-1)
				return
			if not user_controller.linear_user_list.is_empty() and int(self.text) > user_controller.linear_user_list[-1].id:
				analysis_panel.set_current_user_by_index(len(user_controller.linear_user_list)-1)
				self.text = str(analysis_panel.current_user.id)
				set_caret_location(caret_location,true)
				return
			self.text = str(int(self.text)-1)
			index = user_controller.binary_search_user_in_linear_user_list(int(self.text))
			analysis_panel.set_current_user_by_index(index)
		elif button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if not user_controller.linear_user_list.is_empty() and int(self.text) > user_controller.linear_user_list[-1].id:
				analysis_panel.set_current_user_by_index(0)
				self.text = str(analysis_panel.current_user.id)
				set_caret_location(caret_location,true)
				return
			self.text = str(int(self.text)+1)
			index = user_controller.binary_search_user_in_linear_user_list(int(self.text))
			analysis_panel.set_current_user_by_index(index)
		else:
			print("UserSelectEdit<mouse_wheel_scroll_function>: Invalid Input.")
	else:
		# if current user exist
		if button_index == MOUSE_BUTTON_WHEEL_UP:
			if index == 0:
				self.text = str(user_controller.linear_user_list[-1].id)
				analysis_panel.set_current_user_by_index(len(user_controller.linear_user_list)-1)
			else:
				self.text = str(user_controller.linear_user_list[index-1].id)
				analysis_panel.set_current_user_by_index(index-1)
		elif button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if index == len(user_controller.linear_user_list)-1:
				self.text = str(user_controller.linear_user_list[0].id)
				analysis_panel.set_current_user_by_index(0)
			else:
				self.text = str(user_controller.linear_user_list[index+1].id)
				analysis_panel.set_current_user_by_index(index+1)
		else:
			print("UserSelectEdit<mouse_wheel_scroll_function>: Invalid Input.")
	self.caret_column = self.text.length()
	set_caret_location(caret_location,true)
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
		self.mouse_wheel_scroll_function(MOUSE_BUTTON_WHEEL_UP)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
		self.mouse_wheel_scroll_function(MOUSE_BUTTON_WHEEL_DOWN)
	if self.text == "":
		analysis_panel.set_current_user_by_index(-1)

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
		elif i < caret_location:
			caret_location -= 1
			
	if processed_text == "":
		self.text = ""
		self.previous_text = self.text
		analysis_panel.set_current_user_by_index(-1)
		return

	processed_text = processed_text.lstrip("0")
	if processed_text == "":
		processed_text = "0"
		
	analysis_panel.set_current_user_by_id(int(processed_text))
	self.text = str(processed_text)
	
	self.set_caret_location(caret_location)
		
	self.previous_text = self.text

func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.is_pressed() and not is_mouse_in_rect() and self.has_focus():

		if self.text == "":
			self.text = "0"
			analysis_panel.set_current_user_by_index(-1)
		focus_exited.emit()

func initialize(text):
	self.text = text

func _on_focus_exited() -> void:

	analysis_panel.grab_focus()
