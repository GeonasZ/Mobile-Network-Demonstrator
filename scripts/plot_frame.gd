extends Panel

var n_displayed_data = 100
var y_padding = 10
var x_padding = 10

@onready var analysis_panel = $".."
@onready var analysis_panel_title = $"../Title"
@onready var invalid_userid_label = $InvalidIDLabel
@onready var y_axis = $YAxisLabels
@onready var results_panel = $"../ResultsPanel"
# @onready var user_controller = $"../../Controllers/UserController"

enum DisplayMode {SIGNAL, SIR}
var current_display_mode = DisplayMode.SIGNAL

var axis_indicative_line_len = 20

# plot dots raiuds and line width
var dot_radius = 5
var line_width = 3

func dBm(num:float):
	return 10*log(num/0.001)

func make_indicative_y_values():
	# make an indicative axis if max or min value is not accessable
	var element_data_diff = 1
	for i in range(len(y_axis.y_axis_label_list)):
		y_axis.y_axis_label_list[i].text = self._make_displayed_content(element_data_diff*i + 0)

func _draw() -> void:
	var y_diff = self.size.y-2.*self.y_padding
	var y_start = self.y_padding
	var diff_per_element = y_diff/(y_axis.n_labels-1)
	# draw y axis lines
	for i in range(y_axis.n_labels):
		draw_line(Vector2(0,y_start+i*diff_per_element),Vector2(axis_indicative_line_len,y_start+i*diff_per_element),Color8(0,0,0),5)
	
	if analysis_panel.current_user == null:
		invalid_userid_label.visible = true
		invalid_userid_label.text = "Unexistent User ID"
		make_indicative_y_values()
		return
	invalid_userid_label.visible = false
		
	draw_set_transform(Vector2(0,self.size.y))
	var data_list = []
	if current_display_mode == self.DisplayMode.SIGNAL:
		data_list = analysis_panel.current_user.signal_power_hist
	else:
		data_list = analysis_panel.current_user.sir_hist
	
	
	if data_list == []:
		invalid_userid_label.visible = true
		invalid_userid_label.text = "No Data Recorded"
		return
	
	# take the last 100 points to be plotted
	var indexes_to_be_ploted = []
	
	if len(data_list) < self.n_displayed_data:
		indexes_to_be_ploted = range(len(data_list))
	else:
		indexes_to_be_ploted = range(len(data_list)-self.n_displayed_data,len(data_list),)
	var max_dBm
	var min_dBm

	for i in indexes_to_be_ploted:
		if data_list[i] is not String:
			if data_list[i] != INF and data_list[i] != 0 and (max_dBm == null or (dBm(data_list[i]) > max_dBm)):
				max_dBm = dBm(data_list[i])
			if data_list[i] != INF and data_list[i] != 0 and (min_dBm == null or (dBm(data_list[i]) < min_dBm)):
				min_dBm = dBm(data_list[i])
	var diff
	if max_dBm != null and min_dBm != null:
		invalid_userid_label.visible = false
		diff = max_dBm - min_dBm
	else:
		invalid_userid_label.visible = true
		invalid_userid_label.text = "No Invalid Data can be Plotted"
		diff = 1
		return
		
	
	if diff == 0:
		diff = 1
	# make y axis labels
	if max_dBm != null and min_dBm != null:
		var element_data_diff = diff/(y_axis.n_labels-1)
		for i in range(len(y_axis.y_axis_label_list)):
			y_axis.y_axis_label_list[i].text = self._make_displayed_content(element_data_diff*i + min_dBm)
	else:
		make_indicative_y_values()
	var j = 0
	var last_data_point
	var current_data_point
	for i in indexes_to_be_ploted:
		if data_list[i] is not String and data_list[i]!=0 and data_list[i]!= INF and max_dBm!= null and min_dBm!= null:

			current_data_point = Vector2((self.size.x-2*self.x_padding)/(self.n_displayed_data-1)*j+self.x_padding,-((dBm(data_list[i])-min_dBm)/diff*(self.size.y-2*self.y_padding)+self.y_padding))
			draw_circle(current_data_point,self.dot_radius,Color8(0,0,0),true)
			if j > 0 and (data_list[i-1] is not String):
				if data_list[i-1] != INF and data_list[i-1] != 0:
					draw_line(current_data_point,last_data_point,Color8(0,0,0),self.line_width)
		j += 1
		last_data_point = current_data_point

func truncate_double(num, n_digits=3):
	return int(num * pow(10,n_digits))/pow(10,n_digits)

# only used here
func _make_displayed_content(input)->String:
	var displayed_content
	if (input is float or input is int):
		if input != INF:
			displayed_content = str(truncate_double(input)) +" dBm"
		else:
			displayed_content = "Inf dBm"
	else:
		displayed_content = "N/A"
	return displayed_content

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var x_offset = - analysis_panel.length*0.035
	self.size = Vector2(analysis_panel.length*0.92+x_offset,analysis_panel.width*0.6)
	self.position = Vector2((analysis_panel.length-self.size.x)/2-x_offset,analysis_panel_title.size.y*1.5)
	invalid_userid_label.size = self.size
	invalid_userid_label.position = Vector2(0,0)
	invalid_userid_label.visible = false
	y_axis.make_y_axis(y_axis.n_labels)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if analysis_panel.visible:
		queue_redraw()
