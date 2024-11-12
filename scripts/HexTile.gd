extends Polygon2D

var arc_len = 200
var network_type = ""
var n_available_channel = 7
var station_scale = 1
var id
# null for available, not null for not available
var channel_allocation_list = []

var frequency_group

var ref_signal_power = 1
#var noise = 1e-3
#var noise_distr_deviation = 1.
#var noise_refresh_time = 0.5
#var need_refresh_noise = true

func _draw():
	var width = int(arc_len / 100)
	# draw hexagon
	draw_line(Vector2(-1./2*arc_len,-sqrt(3)/2*arc_len),Vector2(1./2*arc_len,-sqrt(3)/2*arc_len), Color8(210,210,210), width, true)
	draw_line(Vector2(1./2*arc_len,-sqrt(3)/2*arc_len),Vector2(arc_len,0), Color8(210,210,210), width, true)
	draw_line(Vector2(arc_len,0),Vector2(1./2*arc_len,sqrt(3)/2*arc_len), Color8(210,210,210), width, true)
	draw_line(Vector2(1./2*arc_len,sqrt(3)/2*arc_len),Vector2(-1./2*arc_len,sqrt(3)/2*arc_len), Color8(210,210,210), width, true)
	draw_line(Vector2(-1./2*arc_len,sqrt(3)/2*arc_len),Vector2(-arc_len, 0), Color8(210,210,210), width, true)
	draw_line(Vector2(-arc_len, 0),Vector2(-1./2*arc_len,-sqrt(3)/2*arc_len), Color8(210,210,210), width, true)
	# draw signal station
	draw_line(Vector2(-9*station_scale,0), Vector2(9*station_scale,0), Color(0,0,0), 3, true)
	draw_line(Vector2(-8*station_scale,0), Vector2(0,-16*station_scale), Color(0,0,0), 3,true)
	draw_line(Vector2(8*station_scale,0), Vector2(0,-16*station_scale), Color(0,0,0), 3,true)
	draw_line(Vector2(0,-16*station_scale), Vector2(0,-22*station_scale), Color(0,0,0), 3,true)
	
func get_available_channels():
	var available_channels = []
	# look for channels available
	for i in range(channel_allocation_list.size()):
		if channel_allocation_list[i] == null:
			available_channels.append(i)
	return available_channels
	
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

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(n_available_channel):
		# true for available
		channel_allocation_list.append(null)
	self.set_arc_len(arc_len)
	#self.noise_distr_deviation = randf_range(0.7,1.3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if need_refresh_noise:
		#self.need_refresh_noise = false
		#self.noise = randfn(0, noise_distr_deviation) * 1e-3
		#await get_tree().create_timer(noise_refresh_time).timeout
		#need_refresh_noise = true
