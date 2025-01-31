extends Control

@onready var user_controller = $"../../Controllers/UserController"
@onready var animator = $AnimationPlayer
@onready var mouse_panel = $"../../MousePanel"
@onready var cross = $Cross
@onready var label = $FunctionLabel
@onready var analysis_mode_button = $"../AnalysisModeButton"
@onready var function_panel = $".."

enum Mode {NONE, OBSERVER, ENGINEER}
var button_mode = Mode.NONE
var analysis_on = false
var button_radius = 45
var length = 25
var width = 44
var slash_len = 3
var on_work = true
var is_mouse_in_box = false
var original_rect
var can_be_controlled_by_key = true

#var _engineer_mode = false
#var _analyzer_mode = false

func _draw():
	draw_circle(Vector2(button_radius,button_radius), button_radius, Color8(255,255,255))
	draw_arc(Vector2(button_radius,button_radius), button_radius, 0, TAU, 50, Color8(50,50,50), 7, true)

func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())

func is_mouse_in_original_rect():
	return self.original_rect.has_point(get_viewport().get_mouse_position())

func set_button_mode(mode):
	var previous_mode = self.button_mode
	self.button_mode = mode
	# determine whether the cross on the button should be visible
	if previous_mode != self.Mode.OBSERVER and self.button_mode == self.Mode.OBSERVER:
		self.cross.disappear_with_anime()
	elif previous_mode == self.Mode.OBSERVER and self.button_mode != self.Mode.OBSERVER:
		self.cross.appear_with_anime()
		
	## determine whether the function label should be visible
	#if previous_mode != self.Mode.OBSERVER and self.button_mode == self.Mode.OBSERVER:
		#self.label.disappear_with_anime()
	#elif previous_mode == self.Mode.OBSERVER and self.button_mode != self.Mode.OBSERVER:
		#self.label.appear_with_anime()
	
	# determine whether the button itself should be visible
	if previous_mode != self.Mode.ENGINEER and self.button_mode == self.Mode.ENGINEER:
		self.smart_disappear()
	elif previous_mode == self.Mode.ENGINEER and self.button_mode != self.Mode.ENGINEER:
		self.smart_appear()

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

func button_click_function():
	var analysis_temp = self.analysis_on
	if self.analysis_on:
		analysis_mode_button.button_click_function()
	if self.button_mode != Mode.OBSERVER:
		function_panel.set_all_button_mode(Mode.OBSERVER)
		user_controller.all_user_enter_observer_mode()
		self.label.set_text("Leave Observer Mode")
	else:
		function_panel.set_all_button_mode(Mode.NONE)
		user_controller.all_user_leave_observer_mode()
		self.label.set_text("Enter Observer Mode")
	if analysis_temp:
		function_panel.all_button_smart_appear()

func _input(event: InputEvent) -> void:
	if not self.visible or not function_panel.visible:
		return
	if self.button_mode == Mode.ENGINEER:
		return
		
	if not can_be_controlled_by_key or not on_work or self.analysis_on:
		return
		
	if event is InputEventKey and event.keycode == KEY_O and event.is_pressed() and can_be_controlled_by_key:
		self.on_work = false
		self.button_click_function()
		await self.get_tree().create_timer(0.25).timeout
		self.on_work = true

		self.on_work = true
	
func _gui_input(event: InputEvent) -> void:
	
	if self.button_mode == Mode.ENGINEER:
		return
			
	if not can_be_controlled_by_key or not on_work:
		return
	
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		self.on_work = false
		self.button_click_function()
		await self.get_tree().create_timer(0.25).timeout
		self.on_work = true
		
func appear():
	self.visible = true
	self.on_work = false
	self.animator.play("button_appear")
	await self.animator.animation_finished
	self.on_work = true

## future use for logical appear of button
func smart_appear():
	if self.button_mode != self.Mode.ENGINEER:
		self.appear()

func disappear():
	self.on_work = false
	self.animator.play("button_disappear")
	await self.animator.animation_finished
	self.visible = false

## future use for logical disappear of button
func smart_disappear():
	self.disappear()
	#if function_panel.is_instruction_panel_visible() and not self.visible:
		#self.disappear()
	#elif not function_panel.is_instruction_panel_visible() and self.visible and self.button_mode == Mode.ENGINEER:
		#self.disappear()

func _process(delta):
	# mouse in button animes
	if self.is_mouse_in_original_rect() and  not mouse_panel.backgorund_watching_mode:
		# trigger only at the frame cursor enters button
		if not is_mouse_in_box and self.visible:
			if not mouse_panel.is_tracking_station():
				mouse_panel.disappear_with_anime()
			is_mouse_in_box = true
		if not label.visible and self.visible:
			self.scale = Vector2(1.05,1.05)
			label.visible == true
			label.appear_with_anime()
	elif  not mouse_panel.backgorund_watching_mode:
		# trigger only at the frame cursor leaves button
		if is_mouse_in_box and self.visible:
			if not mouse_panel.is_tracking_station():
				mouse_panel.appear_with_anime()
			is_mouse_in_box = false
		if label.visible == true:
			label.disappear_with_anime()
			self.scale = Vector2(1,1)
