extends Control

@onready var plot_frame = $".."

var label_element_prefab = null
# the button most one first, position in an increasing order
var y_axis_label_list = []
var n_labels = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_element_prefab = preload("res://scenes/plot_axis_label_element.tscn")

func make_element(pos):
	var current_element = label_element_prefab.instantiate()
	self.add_child(current_element)
	y_axis_label_list.append(current_element)
	current_element.position = pos
	return current_element

func make_y_axis(n_labels):
	var y_diff = plot_frame.size.y-2.*plot_frame.y_padding
	var y_start = plot_frame.y_padding
	var diff_per_element = y_diff/(n_labels-1)
	var current_element = null
	for i in range(n_labels-1,-1,-1):
		current_element = make_element(Vector2(-140,y_start+i*diff_per_element-20))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
