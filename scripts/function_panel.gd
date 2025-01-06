extends Control

# buttons under control
@onready var instr_button =  $InstructionButton
@onready var obs_button = $ObserverButton
@onready var freq_button = $FreqReuseButton
@onready var config_button = $ConfigButton
@onready var engineer_button = $EngineerButton
@onready var add_user_button = $AddUserButton
@onready var remove_user_button = $RemoveUserButton
@onready var antenna_config_button = $AntennaConfigButton
@onready var analysis_mode_button = $AnalysisModeButton
@onready var analysis_panel_button = $AnalysisPanelButton

# other nodes
@onready var user_controller = $"../Controllers/UserController"
@onready var instr_panel = $"../InstructionPanel"
@onready var over_layer = $"../OverLayer"
@onready var mouse_panel = $"../MousePanel"

var registered_buttons
var instruction_panel_visibility = true
var analysis_panel_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.registered_buttons = [self.instr_button, self.obs_button,
							  self.freq_button, self.config_button,
							  self.engineer_button, self.add_user_button,
							  self.remove_user_button, self.antenna_config_button,
							  self.analysis_mode_button, self.analysis_panel_button]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func all_button_smart_appear():
	for button in self.registered_buttons:
		button.smart_appear()

func all_button_smart_disappear():
	for button in self.registered_buttons:
		button.smart_disappear()

func mouse_panel_not_in_button():
	var panel_not_in = true
	for button in self.registered_buttons:
		if button.is_mouse_in_original_rect():
			panel_not_in = false
			break
	return panel_not_in

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
	if self.mouse_panel_not_in_button():
		await mouse_panel.appear_with_anime()
	else:
		await instr_button.animator.animation_finished
	instr_panel.visible = false

func all_button_set_analysis_on():
	for button in self.registered_buttons:
		button.analysis_on = true
		
func all_button_reset_analysis_on():
	for button in self.registered_buttons:
		button.analysis_on = false

func on_mouse_right_click_on_background(pos):
	self.visible = ! self.visible

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
	
func set_analysis_panel_open():
	self.analysis_panel_open = true
	
func set_analysis_panel_close():
	self.analysis_panel_open = false
