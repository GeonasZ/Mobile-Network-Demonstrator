extends GridContainer

@onready var analysis_panel = $".."
@onready var user_controller = $"../../Controllers/UserController"
# elements
@onready var min_signal_label = $MinSignalPower
@onready var average_signal_label = $AverageSignalPower
@onready var max_signal_label = $MaxSignalPower
@onready var min_sir_label = $MinSIR
@onready var average_sir_label = $AverageSIR
@onready var max_sir_label = $MaxSIR
@onready var current_signal_label = $CurrentSignalPower
@onready var current_sir_label = $CurrentSIR
@onready var plot_frame = $"../PlotFrame"

var element_list = []
var length
var width
var slash_len = 50

#func _draw():
	#draw_set_transform(Vector2(length/2,width/2))
	#draw_line(Vector2(-length/2+slash_len, -width/2),Vector2(length/2-slash_len, -width/2), Color(0,0,0), 5, true)
	#draw_line(Vector2(length/2-slash_len, -width/2), Vector2(length/2, -width/2+slash_len), Color(0,0,0), 5, true)
	#draw_line(Vector2(length/2, -width/2+slash_len),Vector2(length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	#draw_line(Vector2(length/2, width/2 - slash_len), Vector2(length/2 - slash_len, width/2), Color(0,0,0), 5, true)
	#draw_line(Vector2(length/2 - slash_len, width/2), Vector2(-length/2 + slash_len, width/2), Color(0,0,0), 5, true)
	#draw_line(Vector2(-length/2 + slash_len, width/2), Vector2(-length/2, width/2 - slash_len), Color(0,0,0), 5, true)
	#draw_line(Vector2(-length/2, width/2 - slash_len), Vector2(-length/2, -width/2 + slash_len), Color(0,0,0), 5, true)
	#draw_line(Vector2(-length/2, -width/2 + slash_len), Vector2(-length/2 + slash_len, -width/2), Color(0,0,0), 5, true)
	#draw_polygon([Vector2(-length/2 + slash_len, -width/2),
					#Vector2(length/2 - slash_len, -width/2),
					#Vector2(length/2, -width/2 + slash_len),
					#Vector2(length/2, width/2 - slash_len),
					#Vector2(length/2 - slash_len, width/2),
					#Vector2(-length/2 + slash_len, width/2),
					#Vector2(-length/2, width/2 - slash_len),
					#Vector2(-length/2, -width/2 + slash_len)],
					#[Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),
					#Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255)])


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.element_list = [self.average_signal_label,self.min_signal_label,
						 self.max_signal_label, self.average_sir_label,
						 self.min_sir_label, self.max_sir_label,
						 self.current_signal_label, self.current_sir_label]
	self.init_size()
	set_all_elements_length(Vector2(self.length/self.columns,self.width/2))
	self._display_null_data()
	
func init_size():
	self.size = Vector2(analysis_panel.length*0.68,analysis_panel.width/4.)
	self.position = Vector2(analysis_panel.length*0.285,analysis_panel.width/4*3.)
	self.length = self.size.x
	self.width = self.size.y

func set_all_elements_length(size:Vector2):
	for element in element_list:
		element.custom_minimum_size = size

## return [signal_mean, sir_mean, signal_max, sir_max,
## signal_min, sir_min]
func extract_user_data(user,n_displayed_data=-1):
	
	if user == null:
		return []
	
	var signal_hist = user.signal_power_hist
	var sir_hist = user.sir_hist
	
	if not signal_hist or not sir_hist:
		return []
	
	if n_displayed_data < 0:
		n_displayed_data = len(sir_hist)
	
	var signal_sum = 0
	var sir_sum = 0
	var signal_max = signal_hist[0]
	var signal_min = signal_hist[0]
	var sir_max = sir_hist[0]
	var sir_min = sir_hist[0]
	
	var index_range
	var n_valid_sir = 0
	#if len(sir_hist) > n_displayed_data:
		#index_range = range(len(sir_hist)-n_displayed_data,len(sir_hist))
	#else:
		#index_range = range(len(sir_hist))
		
	index_range = range(len(sir_hist))
		
	for i in index_range:
		# sum signal up
		signal_sum += signal_hist[i]
		# look for the max and min for signal power
		if signal_hist[i] > signal_max:
			signal_max = signal_hist[i]
		elif signal_hist[i] < signal_min:
			signal_min = signal_hist[i]
		
		# ensure sir is a number
		if sir_hist[i] is int or sir_hist[i] is float:
			# ensure sir is not Inf
			if sir_hist[i] != INF:
				# sum sir up
				sir_sum += sir_hist[i]
				n_valid_sir += 1
				# look for the max and min of sir
				if sir_max is String or sir_hist[i] > sir_max:
					sir_max = sir_hist[i]
				elif sir_min is String or sir_hist[i] < sir_min:
					sir_min = sir_hist[i]
	var mean_sir = sir_sum/n_valid_sir if n_valid_sir > 0 else "N/A"

	return [signal_sum/len(index_range),
			mean_sir, signal_max,
			sir_max, signal_min, sir_min]

func dBm(num:float):
	return 10*log(num/0.001)

func truncate_double(num, n_digits=3):
	return int(num * pow(10,n_digits))/pow(10,n_digits)

func _display_null_data():
	average_signal_label.text = "Avg. Signal Power:\n\tN/A"
	average_sir_label.text = "Avg. SIR:\n\tN/A"
	min_signal_label.text = "Min Signal Power:\n\tN/A"
	current_signal_label.text = "Realtime Signal Power:\n\tN/A"
	min_sir_label.text = "Min SIR:\n\tN/A"
	max_signal_label.text = "Max Signal Power:\n\tN/A"
	max_sir_label.text = "Max SIR:\n\tN/A"
	current_sir_label.text = "Realtime SIR:\n\tN/A"

func make_displayed_content(input,zero_as_inf=false)->String:
	var displayed_content
	if (input is float or input is int):
		if input == 0:
			if zero_as_inf:
				displayed_content = "-Inf dBm"
			else:
				displayed_content = "0"
		elif input != INF:
			displayed_content = str(truncate_double(dBm(input))) +" dBm"
		else:
			displayed_content = "Inf dBm"
	else:
		displayed_content = "N/A"
	return displayed_content

func _display_user_data(data):
	var current_data = user_controller.eval_user_sir(analysis_panel.current_user)
	average_signal_label.text = "Avg. Signal Power:\n\t%s" % make_displayed_content(data[0])
	average_sir_label.text = "Avg. SIR:\n\t%s" % make_displayed_content(data[1])
	current_signal_label.text = "Realtime Signal Power\n\t%s" % make_displayed_content(current_data[0])
	max_signal_label.text = "Max Signal Power:\n\t%s" % make_displayed_content(data[2])
	max_sir_label.text = "Max SIR:\n\t%s" % make_displayed_content(data[3])
	min_signal_label.text = "Min Signal Power:\n\t%s" % make_displayed_content(data[4])
	min_sir_label.text = "Min SIR:\n\t%s" % make_displayed_content(data[5])
	current_sir_label.text = "Realtime SIR:\n\t%s" % make_displayed_content(current_data[2])

func display_user_data(user):
	if user == null:
		self._display_null_data()
	
	var data = self.extract_user_data(user)
	# if no data recorded
	if not data:
		self._display_null_data()
		return
	# display data
	_display_user_data(data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if user_controller.linear_user_list:
		display_user_data(analysis_panel.current_user)
	
