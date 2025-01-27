extends Control

@onready var user_controller = $"../Controllers/UserController"
@onready var mouse_controller = $"../Controllers/MouseController"
@onready var mouse_panel = $"../MousePanel"
@onready var function_panel = $"../FunctionPanel"
@onready var users = $"../Users"
@onready var path_layer = $"../PathLayer"
@onready var config_panel = $"../ConfigPanel"
@onready var station_config_panel = $"../StationConfigPanel"

signal mouse_left_click_on_background()
signal mouse_right_click_on_background()

var zoom_list = []
var zoom_in_ratio = 1.05
var zoom_out_ratio = 0.95
var max_scale = 2
var min_scale = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pivot_offset = Vector2(0,0)
	self.position = Vector2(0,0)
	self.zoom_list = [self,users,path_layer]

func zoom(zoom_ratio, zoom_to_mouse=false, subject=self):
	var old_scale = subject.scale
	var new_scale = old_scale * zoom_ratio
	# zoom towards mouse
	if zoom_to_mouse:
		var mouse_pos = subject.get_global_mouse_position()
		subject.position = mouse_pos - (mouse_pos - subject.position)/old_scale * new_scale
		subject.scale = subject.scale * zoom_ratio
	# zoom towards center of viewport
	else:
		var center_pos = get_viewport_rect().size/2
		subject.position = center_pos - (center_pos - subject.position)/old_scale * new_scale
		subject.scale = subject.scale * zoom_ratio

func on_mouse_left_click_on_background(event):
	# if analysis panel open, do not react to left click
	if mouse_panel.analysis_panel_open:
		return
	mouse_left_click_on_background.emit(event)
	if mouse_controller.current_hex.is_center_on_focus():
		mouse_panel.track_station(mouse_controller.current_hex)
	elif user_controller.user_prefab != null and not user_controller.user_list.is_empty():
		user_controller.add_user(event.position)

func on_mouse_right_click_on_background(event):
	self.mouse_right_click_on_background.emit(event)
	# if analysis panel open, do not react to right click
	if mouse_panel.analysis_panel_open:
		return
	elif station_config_panel.visible:
		return
		
	if mouse_panel.tracking_mode == mouse_panel.TrackingMode.MOUSE:
		mouse_panel.on_mouse_right_click_on_background(event)
		function_panel.on_mouse_right_click_on_background(event)
	else:
		mouse_panel.track_mouse()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.pressed == true:
			self.on_mouse_left_click_on_background(event)
		elif event.button_mask == MOUSE_BUTTON_MASK_RIGHT and event.pressed == true:
			self.on_mouse_right_click_on_background(event)
		# zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			
			if self.scale < Vector2(max_scale,max_scale):
				for obj in zoom_list:
					zoom(zoom_in_ratio, true, obj)
		# zoom out
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var viewport_size = get_viewport_rect().size
			var rect_size = self.get_rect().size
			if self.scale >= Vector2(min_scale,min_scale):
				for obj in zoom_list:
					zoom(zoom_out_ratio, true, obj)
					# if scale is smaller than 1, make it 1
					if obj.scale < Vector2(min_scale,min_scale):
						obj.scale = Vector2(min_scale,min_scale)
						obj.position = Vector2(0,0)
				
			# modify position to avoid viewport from out of bound
			if self.position.x > 0:
				for obj in zoom_list:
					obj.position.x = 0
			if self.position.y > 0:
				for obj in zoom_list:
					obj.position.y = 0
			if self.position.x + rect_size.x < viewport_size.x:
				for obj in zoom_list:
					obj.position.x = viewport_size.x - rect_size.x
			if self.position.y + rect_size.y < viewport_size.y:
				for obj in zoom_list:
					obj.position.y = viewport_size.y - rect_size.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

	
	
