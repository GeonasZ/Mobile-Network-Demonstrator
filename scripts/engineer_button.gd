extends Control

@onready var user_controller = $"../../Controllers/UserController"
@onready var animator = $AnimationPlayer
@onready var mouse_panel = $"../../MousePanel"
@onready var label = $FunctionLabel
@onready var tile_controller = $"../../Controllers/TileController"
@onready var button_char = $Char
@onready var cross = $Cross
@onready var config_panel = $"../../ConfigPanel"
@onready var function_panel = $".."
@onready var station_config_panel = $"../../StationConfigPanel"

enum Mode {NONE, OBSERVER, ENGINEER}
var button_mode = Mode.NONE
var analysis_on = false
var button_radius = 45
var on_work = true
var is_mouse_in_box = false
var original_rect
var current_pattern = -1
var can_be_controlled_by_key = true

#var _engineer_mode = false
#var _analyzer_mode = false

var small_font
var large_font

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
	self.scale = Vector2(1,1)
	self.label.visible = false
	self.on_work = true
	self.position = Vector2(1820 - button_radius, 340 - button_radius)
	self.size = Vector2(2*button_radius, 2*button_radius)
	self.pivot_offset = self.size/2
	self.original_rect = self.get_global_rect()
	button_char.position = Vector2(-2,-2)
	
	# update for the first time whether mouse is in the button
	if self.is_mouse_in_original_rect():
		is_mouse_in_box = true
	else:
		is_mouse_in_box = false

func set_button_mode(mode):
	var previous_mode = self.button_mode
	self.button_mode = mode
	
	# determine whether the cross on the button should be visible
	if previous_mode != self.Mode.ENGINEER and self.button_mode == self.Mode.ENGINEER:
		self.cross.disappear_with_anime()
	elif previous_mode == self.Mode.ENGINEER and self.button_mode != self.Mode.ENGINEER:
		self.cross.appear_with_anime()
		
	# determine whether the cross on the button should be visible
	if previous_mode != self.Mode.ENGINEER and self.button_mode == self.Mode.ENGINEER:
		self.label.disappear_with_anime()
	elif previous_mode == self.Mode.ENGINEER and self.button_mode != self.Mode.ENGINEER:
		self.label.appear_with_anime()
		
	# determine whether the button itself should be visible
	if previous_mode != self.Mode.OBSERVER and self.button_mode == self.Mode.OBSERVER:
		self.smart_disappear()
	elif previous_mode == self.Mode.OBSERVER and self.button_mode != self.Mode.OBSERVER:
		self.smart_appear()

func appear():
	self.visible = true
	self.on_work = false
	self.animator.play("button_appear")
	await self.animator.animation_finished
	self.on_work = true

## future use for logical appear of button
func smart_appear():
	if not self.analysis_on and self.button_mode != self.Mode.OBSERVER:
		self.appear()

func disappear():
	self.on_work = false
	self.animator.play("button_disappear")
	await self.animator.animation_finished
	self.visible = false

## future use for logical disappear of button
func smart_disappear():
	self.disappear()
	#if function_panel.is_instruction_panel_visible() and self.visible:
		#self.disappear()
	#if not function_panel.is_instruction_panel_visible() and self.visible and self.button_mode == Mode.OBSERVER:
		#self.disappear()

func button_left_click_function(event):
	self.on_work = false
	if self.button_mode != Mode.ENGINEER:
		function_panel.set_all_button_mode(Mode.ENGINEER)
		user_controller.all_user_enter_engineer_mode()
		
	else:
		function_panel.set_all_button_mode(Mode.NONE)
		user_controller.all_user_leave_engineer_mode()
		station_config_panel.disappear()
		mouse_panel.track_mouse()
			
	await get_tree().create_timer(0.25).timeout
	self.on_work = true

func _input(event: InputEvent) -> void:
	if not self.visible or not function_panel.visible:
		return
	if self.button_mode == Mode.OBSERVER:
		return
		
	if not can_be_controlled_by_key or not on_work:
		return
	if self.analysis_on:
		return 
	
	if event is InputEventKey and event.keycode == KEY_E and event.is_pressed() and self.can_be_controlled_by_key:
		self.button_left_click_function(event)
	
func _gui_input(event: InputEvent) -> void:
	
	if self.button_mode == Mode.OBSERVER:
		return
		
	if not on_work:
		return
	
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		self.button_left_click_function(event)

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
	# mouse in button animes
	if self.is_mouse_in_original_rect():
		# trigger only at the frame cursor enters button
		if not is_mouse_in_box and self.visible:
			if not mouse_panel.is_tracking_station():
				mouse_panel.disappear_with_anime()
			is_mouse_in_box = true
		if label.visible == false and self.visible:
			self.scale = Vector2(1.05,1.05)
			if self.button_mode != self.Mode.ENGINEER:
				label.visible == true
				label.appear_with_anime()
	else:
		# trigger only at the frame cursor leaves button
		if is_mouse_in_box and self.visible:
			if not mouse_panel.is_tracking_station():
				mouse_panel.appear_with_anime()
			is_mouse_in_box = false
		if label.visible == true:
			label.disappear_with_anime()
		self.scale = Vector2(1,1)
