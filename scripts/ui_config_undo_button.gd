extends Panel

@onready var label = $Label
@onready var ui_config_panel = $".."
@onready var ui_controller = $"../../Controllers/UIStyleController"
@onready var animator = $AnimationPlayer

var is_mouse_in = false
var on_work = true
var disabled

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pivot_offset = self.size*0.5
	self.disabled = true
	self.visible = false
	self.scale = Vector2(0,0)

func init_label():
	label.position = Vector2(0,0)
	label.size = self.size

func _input(event: InputEvent) -> void:
	if not on_work or disabled:
		return
	if event is InputEventKey and event.keycode == KEY_U and event.is_pressed():
		self.on_work = false
		ui_controller.pop_back_ui_style_history()
		ui_controller.update_all_ui_style()
		await self.get_tree().create_timer(0.2).timeout
		self.on_work = true

func _gui_input(event: InputEvent) -> void:
	if not on_work or disabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and self.on_work:
			self.on_work = false
			ui_controller.pop_back_ui_style_history()
			ui_controller.update_all_ui_style()
			await self.get_tree().create_timer(0.2).timeout
			self.on_work = true

func appear():
	self.scale = Vector2(0,0)
	self.visible = true
	self.on_work = false
	animator.play("appear")
	await animator.animation_finished
	self.on_work = true
	
func disappear():
	self.on_work = false
	animator.play("disappear")
	await animator.animation_finished
	self.on_work = true
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.on_work and not self.get_rect().has_point(self.get_local_mouse_position()+self.get_rect().position) and self.is_mouse_in:
		self.is_mouse_in = false
		self.scale = Vector2(1,1)
	elif self.on_work and not self.disabled and self.get_rect().has_point(self.get_local_mouse_position()+self.get_rect().position) and not self.is_mouse_in:
		self.is_mouse_in = true
		self.scale = Vector2(1.02,1.02)
	if len(ui_controller.ui_style_history) > 1 and self.disabled:
		self.disabled = false
		self.appear()
	elif len(ui_controller.ui_style_history) == 1 and not self.disabled:
		self.disabled = true
		self.disappear()
