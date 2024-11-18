extends Control

@onready var instr_button =  $InstructionButton
@onready var obs_button = $ObserverButton
@onready var freq_button = $FreqReuseButton
@onready var config_button = $ConfigButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_mouse_right_click_on_background(pos):
	self.obs_button.visible = ! self.obs_button.visible
	self.instr_button.visible = ! self.instr_button.visible
	self.freq_button.visible = ! self.freq_button.visible
	self.config_button.visible = ! self.config_button.visible

func disable_all_keyboard_input():
	self.obs_button.can_be_controlled_by_key = false
	self.instr_button.can_be_controlled_by_key = false
	self.freq_button.can_be_controlled_by_key = false
	self.config_button.can_be_controlled_by_key = false
	
func enable_all_keyboard_input():
	self.obs_button.can_be_controlled_by_key = true
	self.instr_button.can_be_controlled_by_key = true
	self.freq_button.can_be_controlled_by_key = true
	self.config_button.can_be_controlled_by_key = true
