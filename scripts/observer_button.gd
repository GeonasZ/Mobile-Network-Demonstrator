extends Control

@onready var user_controller = $"../../Controllers/UserController"
@onready var animator = $AnimationPlayer
@onready var mouse_panel = $"../../MousePanel"
@onready var cross = $Cross
@onready var label = $FunctionLabel

var observer_mode_on = false
var button_radius = 45
var length = 25
var width = 44
var slash_len = 3
var on_work = true
var is_mouse_in_box = false
var original_rect
var obs_mode_can_be_controlled_by_key = true

func _draw():
	draw_circle(Vector2(button_radius,button_radius), button_radius, Color8(255,255,255))
	draw_arc(Vector2(button_radius,button_radius), button_radius, 0, TAU, 50, Color8(50,50,50), 7, true)

func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())

func is_mouse_in_original_rect():
	return self.original_rect.has_point(get_viewport().get_mouse_position())

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	self.label.visible = false
	cross.visible = true
	self.scale = Vector2(1,1)
	self.on_work = true
	self.position = Vector2(1820 - button_radius, 220 - button_radius)
	self.size = Vector2(2*button_radius, 2*button_radius)
	self.pivot_offset = self.size/2
	
	self.original_rect = self.get_global_rect()
	
	# update for the first time whether mouse is in the button
	if self.is_mouse_in_original_rect():
		is_mouse_in_box = true
	else:
		is_mouse_in_box = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_O and event.is_pressed() and obs_mode_can_be_controlled_by_key:
		obs_mode_can_be_controlled_by_key = false
		if observer_mode_on:
			observer_mode_on = false
			cross.appear_with_anime()
			user_controller.all_user_leave_observer_mode()
		else:
			observer_mode_on = true
			cross.disappear_with_anime()
			user_controller.all_user_enter_observer_mode()
		await get_tree().create_timer(0.2).timeout
		obs_mode_can_be_controlled_by_key = true
	
func _gui_input(event: InputEvent) -> void:
	
	if not obs_mode_can_be_controlled_by_key:
		return
	
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		if observer_mode_on:
			observer_mode_on = false
			cross.appear_with_anime()
			user_controller.all_user_leave_observer_mode()
		else:
			observer_mode_on = true
			cross.disappear_with_anime()
			user_controller.all_user_enter_observer_mode()
			

func appear_with_disappearing_instr_panel():

	self.visible = true
	self.animator.play("button_appear")
	await self.animator.animation_finished
	self.on_work = true

	

func disappear_with_appearing_instr_panel():
	self.on_work = false
	self.animator.play("button_disappear")
	await self.animator.animation_finished
	self.visible = false
	# label.disappear_with_anime()
	# hide mouse_panel

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
		if label.visible == true and self.visible:
			label.disappear_with_anime()
			self.scale = Vector2(1,1)
