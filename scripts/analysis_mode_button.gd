extends Control

@onready var user_controller = $"../../Controllers/UserController"
@onready var tile_controlller = $"../../Controllers/TileController"
@onready var animator = $AnimationPlayer
@onready var char = $Char
@onready var mouse_panel = $"../../MousePanel"
@onready var label = $FunctionLabel
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
	if self.button_mode != previous_mode and self.button_mode == self.Mode.OBSERVER:
		self.smart_appear()
	elif self.button_mode != previous_mode and self.button_mode != self.Mode.OBSERVER:
		self.smart_disappear()
		
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	self.label.visible = false
	self.scale = Vector2(1,1)
	self.on_work = true
	self.position = Vector2(1700 - button_radius, 220 - button_radius)
	self.size = Vector2(2*button_radius, 2*button_radius)
	self.pivot_offset = self.size/2
	
	self.original_rect = self.get_global_rect()
	
	# update for the first time whether mouse is in the button
	if self.is_mouse_in_original_rect():
		is_mouse_in_box = true
	else:
		is_mouse_in_box = false

func button_click_function(append=false):
	if self.button_mode == self.Mode.OBSERVER:
		if self.analysis_on == true:
			function_panel.all_button_reset_analysis_on()
			user_controller.all_user_end_analysis()
			self.char.text = "S"
			if user_controller.linear_user_list != [] and user_controller.linear_user_list[0].sir_hist != []:
				self.label.set_text("Restart Analysis")
			else:
				self.label.set_text("Start Analysis")
		else:
			function_panel.all_button_set_analysis_on()
			user_controller.all_user_start_analysis(append)
			self.char.text = "E"
			self.label.set_text("End Analysis")
			
			
func _input(event: InputEvent) -> void:
	if not self.visible or not function_panel.visible:
		return
	if not can_be_controlled_by_key:
		return
	if self.button_mode != self.Mode.OBSERVER:
		return
	if not on_work:
		return
	
	if event is InputEventKey and event.is_pressed() and (event.keycode == KEY_S and not self.analysis_on or event.keycode == KEY_E and self.analysis_on):
		on_work = false
		self.button_click_function()
		await get_tree().create_timer(0.2).timeout
		on_work = true
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		self.button_click_function()
			

func appear():
	self.visible = true
	self.on_work = false
	self.animator.play("button_appear")
	await self.animator.animation_finished
	self.on_work = true

## future use for logical appear of button
func smart_appear():
	if not function_panel.is_instruction_panel_visible() and not self.visible and self.button_mode == Mode.OBSERVER:
		self.appear()

func disappear():
	self.on_work = false
	self.animator.play("button_disappear")
	await self.animator.animation_finished
	self.visible = false

## future use for logical disappear of button
func smart_disappear():
	if function_panel.is_instruction_panel_visible() and self.visible:
		self.disappear()
	elif not function_panel.is_instruction_panel_visible() and self.visible and self.button_mode != Mode.OBSERVER:
		self.disappear()
	elif function_panel.analysis_panel_open:
		self.disappear()

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
