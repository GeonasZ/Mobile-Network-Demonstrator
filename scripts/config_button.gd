extends Control

@onready var user_controller = $"../../Controllers/UserController"
@onready var animator = $AnimationPlayer
@onready var mouse_panel = $"../../MousePanel"
@onready var label = $FunctionLabel
@onready var tile_controller = $"../../Controllers/TileController"
@onready var button_char = $Char
@onready var config_panel = $"../../ConfigPanel"
@onready var function_panel = $".."

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

func appear():
	self.visible = true
	self.on_work = false
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

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	self.scale = Vector2(1,1)
	self.label.visible = false
	self.on_work = true
	self.position = Vector2(1820 - button_radius, 580 - button_radius)
	self.size = Vector2(2*button_radius, 2*button_radius)
	self.pivot_offset = self.size/2
	self.original_rect = self.get_global_rect()
	button_char.position = Vector2(-2,-2)
	
	# update for the first time whether mouse is in the button
	if self.is_mouse_in_original_rect():
		is_mouse_in_box = true
	else:
		is_mouse_in_box = false
		
func _input(event: InputEvent) -> void:
	if not self.visible or not function_panel.visible:
		return
	if not on_work or self.analysis_on:
		return
	if not can_be_controlled_by_key:
		return
	
	if event is InputEventKey and event.keycode == KEY_C and event.is_pressed():
		config_panel.open_config_with_anime()
		self.on_work = false
		await get_tree().create_timer(1).timeout
		self.on_work = true
	
func _gui_input(event: InputEvent) -> void:
	
	if not on_work:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		config_panel.open_config_with_anime()
			

func set_button_mode(mode):
	self.button_mode = mode

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
