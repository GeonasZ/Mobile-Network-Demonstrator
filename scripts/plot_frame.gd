extends Panel

var n_displayed_data = 200
var y_padding = 10
var x_padding = 5

@onready var analysis_panel = $".."
@onready var analysis_panel_title = $"../Title"
@onready var invalid_userid_label = $InvalidIDLabel
# @onready var user_controller = $"../../Controllers/UserController"

enum DisplayMode {SIGNAL, SIR}
var current_display_mode = DisplayMode.SIGNAL

func _draw() -> void:
	if analysis_panel.current_user == null:
		invalid_userid_label.visible = true
		invalid_userid_label.text = "Unexistent User ID"
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
		indexes_to_be_ploted = range(len(data_list)-self.n_displayed_data,len(data_list))
	var max = 0
	var min = 0
	for i in indexes_to_be_ploted:
		if data_list[i] is int or data_list[i] is float:
			if data_list[i] > max:
				max = data_list[i]
			elif data_list[i] < min:
				min = data_list[i]
			
	var diff = max - min
	
	if diff == 0:
		diff = 1
	
	var j = 0
	var last_data_point
	var current_data_point
	for i in indexes_to_be_ploted:
		if data_list[i] is int or data_list[i] is float:
			current_data_point = Vector2((self.size.x-2*self.x_padding)/self.n_displayed_data*(j+1)+self.x_padding,-((data_list[i]-min)/diff*(self.size.y-2*self.y_padding)+self.y_padding))
			draw_circle(current_data_point,3,Color8(0,0,0),true)
			if j > 0 and (data_list[i-1] is int or data_list[i-1] is float):
				if data_list[i-1] != INF and  data_list[i] != INF:
					draw_line(current_data_point,last_data_point,Color8(0,0,0),2)
		j += 1
		last_data_point = current_data_point
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.size = Vector2(analysis_panel.length*0.95,analysis_panel.width*0.6)
	self.position = Vector2((analysis_panel.length-self.size.x)/2,analysis_panel_title.size.y*1.5)
	invalid_userid_label.size = self.size
	invalid_userid_label.position = Vector2(0,0)
	invalid_userid_label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if analysis_panel.visible:
		queue_redraw()
