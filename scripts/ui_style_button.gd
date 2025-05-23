extends Control

@onready var user_controller = $"../../Controllers/UserController"
@onready var animator = $AnimationPlayer
@onready var mouse_panel = $"../../MousePanel"
@onready var ui_config_panel = $"../../UIConfigPanel"
@onready var label = $FunctionLabel
@onready var tile_controller = $"../../Controllers/TileController"
@onready var button_char = $Char
@onready var function_panel = $".."

enum Mode {NONE, OBSERVER, ENGINEER}
var button_mode = Mode.NONE
var analysis_on = false
var button_radius = 45
var on_work = true
var is_mouse_in_box = false
var original_rect
var current_pattern = -1

var small_font
var large_font
var can_be_controlled_by_key = true

#var _engineer_mode = false
#var _analyzer_mode = false

func _draw():
	draw_circle(Vector2(button_radius,button_radius), button_radius, Color8(255,255,255))
	draw_arc(Vector2(button_radius,button_radius), button_radius, 0, TAU, 50, Color8(50,50,50), 7, true)

func appear():
	self.scale = Vector2(0,0)
	self.on_work = false
	self.visible = true
	self.animator.play("button_appear")
	await self.animator.animation_finished
	self.on_work = true

## future use for logical appear of button
func smart_appear():
	
	if self.analysis_on:
		return
	if self.button_mode == Mode.NONE:
		self.appear()

func disappear():
	self.on_work = false
	self.animator.play("button_disappear")
	await self.animator.animation_finished
	self.visible = false

## future use for logical disappear of button
func smart_disappear():
	self.disappear()

func is_mouse_in_rect():
	return self.get_global_rect().has_point(get_viewport().get_mouse_position())

func is_mouse_in_original_rect():
	return self.original_rect.has_point(get_viewport().get_mouse_position())


func set_button_mode(mode):
	# hide if either observer or engineer mode is on
	if mode != self.button_mode and (mode == Mode.OBSERVER or mode == Mode.ENGINEER):
		self.disappear()
	elif mode != self.button_mode and mode == Mode.NONE and not self.visible:
		self.appear()
	self.button_mode = mode

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	self.scale = Vector2(1,1)
	self.label.visible = false
	self.on_work = true
	self.position = Vector2(1820 - button_radius, 700 - button_radius)
	self.size = Vector2(2*button_radius, 2*button_radius)
	self.pivot_offset = self.size/2
	self.large_font = preload("res://fonts/pre_set_theme/button_large_font.tres")
	self.small_font = preload("res://fonts/pre_set_theme/button_small_font.tres")
	self.original_rect = self.get_global_rect()
	
	# update for the first time whether mouse is in the button
	if self.is_mouse_in_original_rect():
		is_mouse_in_box = true
	else:
		is_mouse_in_box = false

func button_click_function():
	if not ui_config_panel.on_work:
		return
	
	if not ui_config_panel.visible:
		ui_config_panel.appear()
		function_panel.all_button_smart_disappear()

func _input(event: InputEvent) -> void:
	if not self.visible or not function_panel.visible:
		return
	if not on_work or self.analysis_on:
		return
	if not self.can_be_controlled_by_key:
		return
		
	if event is InputEventKey and event.keycode == KEY_F and event.is_pressed():
		button_click_function()
	
func _gui_input(event: InputEvent) -> void:
	
	if not on_work:
		return
	
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		button_click_function()
			

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
	mouse_panel.disappear_with_anime()

func _process(delta):
	# hide if analysis on, show if analysis off
	if self.analysis_on and self.visible:
		self.disappear()
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
			self.scale = Vector2(1,1)
	## change the content displayed on the button when mouse in
	#if self.visible and self.is_mouse_in_original_rect():
		#if self.current_pattern == -1:
			#self.current_pattern = tile_controller.get_current_freq_pattern()
		#self.button_char.text = "N = " + str(self.current_pattern)
		#self.button_char.theme = self.small_font
	#else:
		#self.button_char.text = "F"
		#self.button_char.theme = self.large_font
		
