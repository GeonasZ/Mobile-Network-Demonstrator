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
	
