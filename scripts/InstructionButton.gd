extends Control

@onready var instr_panel = $"../../InstructionPanel"
@onready var animator = $AnimationPlayer
@onready var mouse_panel = $"../../MousePanel"
@onready var label = $FunctionLabel
@onready var obs_button = $"../ObserverButton"
@onready var freq_button = $"../FreqReuseButton"
@onready var config_button = $"../ConfigButton"
@onready var user_controller = $"../../Controllers/UserController"
@onready var over_layer = $"../../OverLayer"
@onready var function_panel = $".."

enum Mode {NONE, OBSERVER, ENGINEER}
var button_mode = Mode.NONE
var analysis_on = false
var button_radius = 45
var on_work = true
var is_mouse_in_box = false
var original_rect
var can_be_controlled_by_key = true

func _draw():
	draw_circle(Vector2(button_radius,button_radius), button_radius, Color8(255,255,255))
	draw_arc(Vector2(button_radius,button_radius), button_radius, 0, TAU, 50, Color8(50,50,50), 7, true)
	

func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())

func is_mouse_in_original_rect():
	return self.original_rect.has_point(get_viewport().get_mouse_position())

func set_button_mode(mode):
	self.button_mode = mode

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	self.on_work = true
	self.scale = Vector2(1,1)
	self.position = Vector2(1820 - button_radius, 100 - button_radius)
	self.size = Vector2(2*button_radius, 2*button_radius)
	self.pivot_offset = self.size/2
	self.original_rect = self.get_global_rect()
	# update for the first time whether mouse is in the button
	if self.is_mouse_in_original_rect():
		is_mouse_in_box = true
	else:
		is_mouse_in_box = false

func appear():
	self.on_work = false
	self.visible = true
	self.animator.play("button_appear")
	await self.animator.animation_finished
	self.on_work = true

## future use for logical appear of button
func smart_appear():
	if self.analysis_on:
		return
	self.appear()

func disappear():
	self.on_work = false
	self.animator.play("button_disappear")
	await self.animator.animation_finished
	self.visible = false

## future use for logical disappear of button
func smart_disappear():
	self.disappear()


# handel key input
func _input(event: InputEvent) -> void:
	if not function_panel.visible:
		return
	if not can_be_controlled_by_key:
		return
		
	if not on_work and not function_panel.is_instruction_panel_visible():
		return
		
	if self.analysis_on:
		return
		
	if event is InputEventKey and event.keycode == KEY_I and event.pressed:
		if instr_panel.visible:
			on_work = false
			function_panel.all_button_appear_with_instr_panel_disappear()
			await get_tree().create_timer(0.2).timeout
			on_work = true
		elif not instr_panel.visible:
			on_work = false
			function_panel.all_button_disappear_with_instr_panel_appear()
			await get_tree().create_timer(0.2).timeout
			on_work = true
			

# handel mouse input
func _gui_input(event):
	if not can_be_controlled_by_key or not on_work:
		return
		
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.pressed:
		function_panel.all_button_disappear_with_instr_panel_appear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	
	# hide if analysis on, show if analysis off
	if self.analysis_on and self.visible:
		self.disappear()
	elif self.button_mode == self.Mode.OBSERVER and not self.analysis_on and not self.visible and not function_panel.analysis_panel_open:
		self.appear()
	# mouse in button animes
	if self.is_mouse_in_original_rect() and not mouse_panel.backgorund_watching_mode:
		# trigger only at the frame cursor enters button
		if not is_mouse_in_box and self.visible:
			if not mouse_panel.is_tracking_station():
				mouse_panel.disappear_with_anime()
			is_mouse_in_box = true
		if label.visible == false and self.visible:
			self.scale = Vector2(1.05,1.05)
			label.visible == true
			label.appear_with_anime()
	elif not mouse_panel.backgorund_watching_mode:
		# trigger only at the frame cursor leaves button
		if is_mouse_in_box and self.visible:
			if not mouse_panel.is_tracking_station():
				mouse_panel.appear_with_anime()
			is_mouse_in_box = false
		if label.visible == true:
			label.disappear_with_anime()
			self.scale = Vector2(1,1)
