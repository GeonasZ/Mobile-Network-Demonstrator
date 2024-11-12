extends Control

@onready var instr_panel = $"../../InstructionPanel"
@onready var animator = $AnimationPlayer
@onready var mouse_panel = $"../../MousePanel"
@onready var label = $FunctionLabel
@onready var obs_button = $"../ObserverButton"
@onready var freq_button = $"../FreqReuseButton"
@onready var config_button = $"../ConfigButton"
@onready var user_controller = $"../../Controllers/UserController"


var button_radius = 45
var on_work = true
var is_mouse_in_box = false
var original_rect
var instr_panel_can_be_controlled_by_key = true

func _draw():
	draw_circle(Vector2(button_radius,button_radius), button_radius, Color8(255,255,255))
	draw_arc(Vector2(button_radius,button_radius), button_radius, 0, TAU, 50, Color8(50,50,50), 5, true)
	

func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())

func is_mouse_in_original_rect():
	return self.original_rect.has_point(get_viewport().get_mouse_position())


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
		
func appear_with_disappearing_instr_panel():
	self.visible = true
	instr_panel.on_work = false
	self.animator.play("button_appear")
	instr_panel.animator.play("panel_disappear")
	await self.animator.animation_finished
	self.on_work = true
	await instr_panel.animator.animation_finished
	instr_panel.visible = false
	user_controller.resume_all_user()
	
	# show mouse_panel
	if not self.is_mouse_in_box and not obs_button.is_mouse_in_box:
		mouse_panel.appear_with_anime()
	

func disappear_with_appearing_instr_panel():
	self.on_work = false
	instr_panel.visible = true
	self.animator.play("button_disappear")
	instr_panel.animator.play("panel_appear")
	await self.animator.animation_finished
	self.visible = false
	user_controller.pause_all_user()
	label.disappear_with_anime()
	
	# hide mouse_panel
	mouse_panel.disappear_with_anime_at_speed(2)
	
	await instr_panel.animator.animation_finished
	instr_panel.on_work = true

func func_buttons_appear():
	self.appear_with_disappearing_instr_panel()
	obs_button.appear_with_disappearing_instr_panel()
	freq_button.appear_with_disappearing_instr_panel()
	config_button.appear_with_disappearing_instr_panel()

func func_buttons_disappear():
	self.disappear_with_appearing_instr_panel()
	obs_button.disappear_with_appearing_instr_panel()
	freq_button.disappear_with_appearing_instr_panel()
	config_button.disappear_with_appearing_instr_panel()


# handel key input
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_I and event.pressed:
		if instr_panel.visible and instr_panel_can_be_controlled_by_key:
			instr_panel_can_be_controlled_by_key = false
			func_buttons_appear()
			await get_tree().create_timer(0.2).timeout
			instr_panel_can_be_controlled_by_key = true
		elif not instr_panel.visible and instr_panel_can_be_controlled_by_key:
			instr_panel_can_be_controlled_by_key = false
			func_buttons_disappear()
			await get_tree().create_timer(0.2).timeout
			instr_panel_can_be_controlled_by_key = true
			

# handel mouse input
func _gui_input(event):
	if not instr_panel_can_be_controlled_by_key:
		return
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.pressed and not instr_panel.visible:
		if event.position.distance_to(Vector2(button_radius,button_radius)) <= button_radius and self.on_work:
			func_buttons_disappear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.is_mouse_in_original_rect():
		# trigger only at the frame cursor enters button
		if not is_mouse_in_box and self.visible:
			mouse_panel.disappear_with_anime()
			is_mouse_in_box = true
		if label.visible == false and self.visible:
			self.scale = Vector2(1.05,1.05)
			label.visible == true
			label.appear_with_anime()
	else:
		# trigger only at the frame cursor leaves button
		if is_mouse_in_box and self.visible:
			mouse_panel.appear_with_anime()
			is_mouse_in_box = false
		if label.visible == true:
			label.disappear_with_anime()
			self.scale = Vector2(1,1)
