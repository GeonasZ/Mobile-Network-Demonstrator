extends Polygon2D

var mouse_panel
@onready var parent_node = $".."

var AntennaType = ["DIPOLE","ARRAY2","ARRAY3","ARRAY4"]

var index_i
var index_j

var arc_len = 200
var network_type = ""
var n_available_channel = 7
var station_scale = 1
var id
# used to decide the mouse position respect to the tile itself
var mouse_position_in_tile = Vector2(0,0)
# null for available, not null for not available
var channel_allocation_list = []
var antenna_type = "DIPOLE"
var angle_divergence = 2 * PI
var signal_direction = Vector2(0,0)
var frequency_group
var focus_radius = 0
var on_focus =  false
var center_on_focus =  false
var under_tracked = false
var mouse_panel_keep_invisible = false
var empty_display_user_list = false
var station_tower_height = 16
var station_total_height = 22
var station_half_width = 9

var ref_signal_power = 10
#var noise = 1e-3
#var noise_distr_deviation = 1.
#var noise_refresh_time = 0.5
#var need_refresh_noise = true

# just for animation use
var current_signal_radius = 0
var current_signal_alpha = 255
# ratio with respect to arc_len
var max_signal_radius_ratio = 0.8

# signal proporgation ratio for alpha, just for animation, with respected to arc_len
var signal_proporgation_ratio_per_second = 0.6
var proporgation_interval = 0.5
# controller whether the next proporgation can be down
var next_proporgation = true

func _draw():
	var width = int(arc_len / 100.)
	# draw hexagon
	draw_line(Vector2(-1./2*arc_len,-sqrt(3)/2*arc_len),Vector2(1./2*arc_len,-sqrt(3)/2*arc_len), Color8(210,210,210), width, true)
	draw_line(Vector2(1./2*arc_len,-sqrt(3)/2*arc_len),Vector2(arc_len,0), Color8(210,210,210), width, true)
	draw_line(Vector2(arc_len,0),Vector2(1./2*arc_len,sqrt(3)/2*arc_len), Color8(210,210,210), width, true)
	draw_line(Vector2(1./2*arc_len,sqrt(3)/2*arc_len),Vector2(-1./2*arc_len,sqrt(3)/2*arc_len), Color8(210,210,210), width, true)
	draw_line(Vector2(-1./2*arc_len,sqrt(3)/2*arc_len),Vector2(-arc_len, 0), Color8(210,210,210), width, true)
	draw_line(Vector2(-arc_len, 0),Vector2(-1./2*arc_len,-sqrt(3)/2*arc_len), Color8(210,210,210), width, true)
	# draw signal station
	if self.antenna_type =="DIPOLE":
		# draw station body
		draw_line(Vector2(-station_half_width*station_scale,0), Vector2(station_half_width*station_scale,0), Color(0,0,0), 3, true)
		draw_line(Vector2(-(station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2((station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		# draw antenna
		draw_line(Vector2(0,-station_tower_height*station_scale), Vector2(0,-station_total_height*station_scale), Color(0,0,0), 3,true)
	elif self.antenna_type == "ARRAY2":
		# draw station body
		draw_line(Vector2(-station_half_width*station_scale,0), Vector2(station_half_width*station_scale,0), Color(0,0,0), 3, true)
		draw_line(Vector2(-(station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2((station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		# draw antenna plane
		draw_line(Vector2(-0.5*station_half_width*station_scale,-station_tower_height*station_scale),Vector2(0.5*station_half_width*station_scale,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		# draw antenna
		draw_line(Vector2(-0.5*station_half_width*station_scale,-station_tower_height*station_scale),Vector2(-0.5*station_half_width*station_scale,-station_total_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2(0.5*station_half_width*station_scale,-station_tower_height*station_scale),Vector2(0.5*station_half_width*station_scale,-station_total_height*station_scale), Color(0,0,0), 3,true)
	elif self.antenna_type == "ARRAY3":
		# draw station body
		draw_line(Vector2(-station_half_width*station_scale,0), Vector2(station_half_width*station_scale,0), Color(0,0,0), 3, true)
		draw_line(Vector2(-(station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2((station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		# draw antenna plane
		draw_line(Vector2(-station_half_width*station_scale,-station_tower_height*station_scale),Vector2(station_half_width*station_scale,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		# draw antennas
		draw_line(Vector2(-station_half_width*station_scale,-station_tower_height*station_scale),Vector2(-station_half_width*station_scale,-station_total_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2(station_half_width*station_scale,-station_tower_height*station_scale),Vector2(station_half_width*station_scale,-station_total_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2(0,-station_tower_height*station_scale), Vector2(0,-station_total_height*station_scale), Color(0,0,0), 3,true)
	elif self.antenna_type == "ARRAY4":
		# draw station body
		draw_line(Vector2(-station_half_width*station_scale,0), Vector2(station_half_width*station_scale,0), Color(0,0,0), 3, true)
		draw_line(Vector2(-(station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2((station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		# draw antenna plane
		draw_line(Vector2(-station_half_width*station_scale,-station_tower_height*station_scale),Vector2(station_half_width*station_scale,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		# draw antennas
		draw_line(Vector2(-station_half_width*station_scale,-station_tower_height*station_scale),Vector2(-station_half_width*station_scale,-station_total_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2(station_half_width*station_scale,-station_tower_height*station_scale),Vector2(station_half_width*station_scale,-station_total_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2(-0.35*station_half_width*station_scale,-station_tower_height*station_scale),Vector2(-0.35*station_half_width*station_scale,-station_total_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2(0.35*station_half_width*station_scale,-station_tower_height*station_scale),Vector2(0.35*station_half_width*station_scale,-station_total_height*station_scale), Color(0,0,0), 3,true)
	else:
		self.set_antenna_type("DIPOLE")
		# draw station body
		draw_line(Vector2(-station_half_width*station_scale,0), Vector2(station_half_width*station_scale,0), Color(0,0,0), 3, true)
		draw_line(Vector2(-(station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		draw_line(Vector2((station_half_width-1)*station_scale,0), Vector2(0,-station_tower_height*station_scale), Color(0,0,0), 3,true)
		# draw antenna
		draw_line(Vector2(0,-station_tower_height*station_scale), Vector2(0,-station_total_height*station_scale), Color(0,0,0), 3,true)
		print("HexTile ID " + str(id) + ": Unknown Antenna Type, treated as DIPOLE as default.")
	# draw a circle at the center if center is on focus
	if self.under_tracked and not mouse_panel.keep_invisible:
		draw_circle(Vector2(0,-station_total_height/2.), station_scale * focus_radius, Color8(50,50,50), false, width*4)
	elif self.on_focus and self.center_on_focus and not mouse_panel.keep_invisible and empty_display_user_list:
		draw_circle(Vector2(0,-station_total_height/2.), station_scale * focus_radius, Color8(150,150,150), false, width*4)
		
func set_focus():
	self.on_focus = true

func reset_focus():
	self.on_focus = false

func get_antenna_type():
	if self.antenna_type == "DIPOLE":
		return "Dipole Antenna"
	elif self.antenna_type == "ARRAY2":
		return "Antenna Array <N=2>"
	elif self.antenna_type == "ARRAY3":
		return "Antenna Array <N=3>"
	elif self.antenna_type == "ARRAY4":
		return "Antenna Array <N=4>"

func eval_signal_pow(angle_from_center, distance, decay):
	if self.antenna_type == "DIPOLE":
		return self.ref_signal_power/pow(distance,decay)
	else:
		var N
		if self.antenna_type == "ARRAY2": 
			N = 2
		elif self.antenna_type == "ARRAY3": 
			N = 3
		elif self.antenna_type == "ARRAY4": 
			N = 4
		else:
			print("HexTile ID " + str(id) + " eval_signal_pow(): Unknown Antenna Type.")
			return null
		var array_factor
		# the limit of array_factor when angle approaches zero is N.
		if angle_from_center == 0:
			# equal to if make angle_from_center very small to evaluate array_factor
			array_factor = N
		else:
			array_factor = sin(0.5*N*angle_from_center)/sin(0.5*angle_from_center)
		return self.ref_signal_power/pow(distance,decay)*pow(array_factor,2)

func eval_signal_pow_to_user(user, decay):
	if user.connected_channel == null:
		return 0
	var distance = self.position.distance_to(user.position)
	var angle_from_center = self.signal_direction.angle_to(user.position-self.position)
	return eval_signal_pow(angle_from_center, distance, decay)

func start_wait_for_next_signal_proporgation():
	self.next_proporgation = false
	await get_tree().create_timer(self.proporgation_interval).timeout
	self.next_proporgation = true

func is_next_signal_proporgation_ready():
	return self.next_proporgation

func set_antenna_type(type):
	self.antenna_type = type
	self.angle_divergence = 2*PI
	if type == "ARRAY2":
		self.angle_divergence /= 4
	elif type == "ARRAY3":
		self.angle_divergence /= 6
	elif type == "ARRAY4":
		self.angle_divergence /= 12
	self.redraw_tile()

func get_divergence_angle():
	return self.angle_divergence if self.angle_divergence != 2*PI else null

func begin_tracked_by_panel():
	self.under_tracked = true
	self.redraw_tile()

func end_tracked_by_panel():
	self.under_tracked = false
	self.redraw_tile()
	
func redraw_tile():
	self.queue_redraw()

func init_channel_number(n_channel:int):
	self.channel_allocation_list = []
	for i in range(n_available_channel):
		# true for available
		self.channel_allocation_list.append(null)
		
func set_channel_number(n_channel:int):
	# add or delete channel until channel number is as expected
	var user
	while n_available_channel != n_channel:
		# add a channel if smaller
		if n_available_channel < n_channel:
			channel_allocation_list.append(null)
			n_available_channel += 1
		# delete a channel if larger
		else:
			user = channel_allocation_list.pop_back()
			if user != null:
				user.connect_to_channel(null)
			n_available_channel -= 1

	
	
	self.n_available_channel = n_channel

func get_available_channels():
	var available_channels = []
	# look for channels available
	for i in range(channel_allocation_list.size()):
		if channel_allocation_list[i] == null:
			available_channels.append(i)
	return available_channels

func get_mouse_position_in_tile():
	return self.get_local_mouse_position()
	
func allocate_channel(user):
	var available_channels = get_available_channels()
	# if no channel available
	if available_channels.size() == 0:
		return null
	var channel_index = randi_range(0,available_channels.size()-1)
	channel_allocation_list[available_channels[channel_index]] = user
	return available_channels[channel_index]
	
func restore_channel(channel_index):
	if channel_index != null:
		channel_allocation_list[channel_index] = null

func set_id(id):
	self.id = id

func set_arc_len(arc_len):
	self.arc_len = arc_len
	self.polygon = [Vector2(-1./2*arc_len,-sqrt(3)/2*arc_len), 
					Vector2(1./2*arc_len,-sqrt(3)/2*arc_len),
					Vector2(arc_len,0),
					Vector2(1./2*arc_len,sqrt(3)/2*arc_len),
					Vector2(-1./2*arc_len,sqrt(3)/2*arc_len),
					Vector2(-arc_len, 0)]

func is_center_on_focus():
	var distance_to_mouse = (self.get_global_transform()*Vector2(0,0)+Vector2(0, -station_scale*station_total_height/2.)).distance_to(get_global_mouse_position())
	return distance_to_mouse <= self.focus_radius * station_scale * parent_node.scale.x
	
# Called when the node enters the scene tree for the first time.
func _ready():
	self.focus_radius = self.arc_len/8
	init_channel_number(n_available_channel)
	self.set_arc_len(arc_len)
	#self.noise_distr_deviation = randf_range(0.7,1.3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.on_focus:
		if self.is_center_on_focus() and not self.center_on_focus:
			self.center_on_focus = true
			self.redraw_tile()
		elif not self.is_center_on_focus() and self.center_on_focus:
			self.center_on_focus = false
			self.redraw_tile()
	# redraw when mouse_panel_redraws
	if self.mouse_panel.keep_invisible and not self.mouse_panel_keep_invisible:
		self.mouse_panel_keep_invisible = true
		self.redraw_tile()
	elif not self.mouse_panel.keep_invisible and self.mouse_panel_keep_invisible:
		self.mouse_panel_keep_invisible = false
		self.redraw_tile()
	# redraw when displayed_user changes
	if self.empty_display_user_list and mouse_panel.displayed_user.size() != 0:
		self.empty_display_user_list = false
		self.redraw_tile()
	elif not self.empty_display_user_list and mouse_panel.displayed_user.size() == 0:
		self.empty_display_user_list = true
		self.redraw_tile()
