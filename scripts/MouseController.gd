extends Control

# the nearest station to mouse
var current_hex = null
var current_hex_i = null
var current_hex_j = null
# the distance from mouse to the nearest station 
var current_distance = -1
@onready var tile_controller = $"../TileController"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var temp = tile_controller.get_current_hex(self.get_global_mouse_position())
	self.current_hex = temp[0]
	self.current_distance = temp[1]
	self.current_hex_i = temp[2]
	self.current_hex_j = temp[3]
