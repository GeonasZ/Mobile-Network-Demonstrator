extends GridContainer

@onready var analysis_panel = $".."
@onready var user_controller = $"../../Controllers/UserController"
# elements
@onready var average_signal_label = $AverageSignalPower

var element_list = []
var length
var width
var slash_len = 50

func _draw():
	draw_set_transform(Vector2(length/2,width/2))
	draw_line(Vector2(-length/2+slash_len, -width/2),Vector2(length/2-slash_len, -width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2-slash_len, -width/2), Vector2(length/2, -width/2+slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, -width/2+slash_len),Vector2(length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2, width/2 - slash_len), Vector2(length/2 - slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(length/2 - slash_len, width/2), Vector2(-length/2 + slash_len, width/2), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2 + slash_len, width/2), Vector2(-length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, width/2 - slash_len), Vector2(-length/2, -width/2 + slash_len), Color(0,0,0), 5, true)
	draw_line(Vector2(-length/2, -width/2 + slash_len), Vector2(-length/2 + slash_len, -width/2), Color(0,0,0), 5, true)
	draw_polygon([Vector2(-length/2 + slash_len, -width/2),
					Vector2(length/2 - slash_len, -width/2),
					Vector2(length/2, -width/2 + slash_len),
					Vector2(length/2, width/2 - slash_len),
					Vector2(length/2 - slash_len, width/2),
					Vector2(-length/2 + slash_len, width/2),
					Vector2(-length/2, width/2 - slash_len),
					Vector2(-length/2, -width/2 + slash_len)],
					[Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),
					Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255)])


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.element_list = [self.average_signal_label]
	self.init_size()
	set_all_elements_length(Vector2(self.length/self.columns,self.width/2))
	
func init_size():
	self.size = Vector2(analysis_panel.length*2/3.,analysis_panel.width/4.)
	self.position = Vector2(analysis_panel.length*1/3.,analysis_panel.width/4*3.)
	self.length = self.size.x
	self.width = self.size.y

func set_all_elements_length(size:Vector2):
	for element in element_list:
		element.custom_minimum_size = size

## return [signal_mean, sir_mean, signal_max, sir_max,
## signal_min, sir_min]
func extract_user_data(user):
	var signal_hist = user.signal_power_hist
	var sir_hist = user.sir_hist
	
	if not signal_hist or not sir_hist:
		return []
	
	var signal_sum = 0
	var sir_sum = 0
	var signal_max = signal_hist[0]
	var signal_min = signal_hist[0]
	var sir_max = sir_hist[0]
	var sir_min = sir_hist[0]
	for i in range(len(signal_hist)):
		# sum signal and sir up
		signal_sum += signal_hist[i]
		sir_sum += sir_hist[i]
		# look for the max and min for signal power
		if signal_hist[i] > signal_max:
			signal_max = signal_hist[i]
		elif signal_hist[i] < signal_min:
			signal_min = signal_hist[i]
		# look for the max and min of sir
		if sir_hist[i] > sir_max:
			sir_max = sir_hist[i]
		elif sir_hist[i] < sir_min:
			sir_min = sir_hist[i]
	return [signal_sum/len(signal_hist),
			sir_sum/len(sir_hist), signal_max,
			sir_max, signal_min, sir_min]

func dBm(num:float):
	return 10*log(num/0.001)
	
func display_user_data(user):
	var data = self.extract_user_data(user)
	if not data:
		average_signal_label.text = "Average Signal Power:\n[center] N/A [/center]"
		return
	average_signal_label.text = "Average Signal Power:\n[center] %f dBm[/center]" % dBm(data[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if user_controller.linear_user_list:
		display_user_data(user_controller.linear_user_list[0])
	
