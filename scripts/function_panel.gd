extends Control

# buttons under control
@onready var instr_button =  $InstructionButton
@onready var obs_button = $ObserverButton
@onready var freq_button = $FreqReuseButton
@onready var config_button = $ConfigButton
@onready var engineer_button = $EngineerButton
@onready var add_user_button = $AddUserButton

# other nodes
@onready var user_controller = $"../Controllers/UserController"
@onready var instr_panel = $"../InstructionPanel"
@onready var over_layer = $"../OverLayer"
@onready var mouse_panel = $"../MousePanel"

var registered_buttons
var instruction_panel_visibility = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.registered_buttons = [self.instr_button, self.obs_button,
							  self.freq_button, self.config_button,
							  self.engineer_button, self.add_user_button]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func all_button_smart_appear():
	for button in self.registered_buttons:
		button.smart_appear()

func all_button_smart_disappear():
	for button in self.registered_buttons:
		button.smart_disappear()

func all_button_disappear_with_instr_panel_appear():
	self.all_button_smart_disappear()
	self.instruction_panel_visibility = true
	over_layer.make_invisible()
	instr_panel.on_work = false
	instr_panel.animator.play("panel_appear")
	instr_panel.visible = true

	await mouse_panel.disappear_with_anime_at_speed(2)
	instr_panel.on_work = true
	user_controller.pause_all_user()

func all_button_appear_with_instr_panel_disappear():

	self.all_button_smart_appear()
	self.instruction_panel_visibility = false
	self.over_layer.make_visible()
	instr_panel.on_work = false
	instr_panel.animator.play("panel_disappear")
	user_controller.resume_all_user()
	# wait until hide mouse_panel
	var mouse_panel_should_show = true
	for button in self.registered_buttons:
		if button.is_mouse_in_original_rect():
			mouse_panel_should_show = false
			break
	if mouse_panel_should_show:
		await mouse_panel.appear_with_anime()
	else:
		await self.instr_button.animator.animation_finished
	instr_panel.visible = false

func on_mouse_right_click_on_background(pos):
	for button in self.registered_buttons:
		button.visible = !button.visible

func disable_all_keyboard_input():
	for button in self.registered_buttons:
		button.can_be_controlled_by_key = false
	
func enable_all_keyboard_input():
	for button in self.registered_buttons:
		button.can_be_controlled_by_key = true
		
func set_all_button_mode(mode):
	for button in self.registered_buttons:
		button.set_button_mode(mode)
		
func is_instruction_panel_visible():
	return instruction_panel_visibility
