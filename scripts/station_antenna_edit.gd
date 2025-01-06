extends VBoxContainer

@onready var parent_node = $".."
@onready var title = $Title
@onready var option_list = $OptionList
@onready var station_config = $"../../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parent_node.custom_minimum_size = self.size
	parent_node.position = Vector2(0,0)
	

func _on_option_mouse_left_click(option_content) -> void:
	
	var station = station_config.focused_hex
	
	if option_content == "Dipole Antenna":
		if station.get_antenna_type_raw() != "DIPOLE":
			station.set_antenna_type("DIPOLE")
			station_config.set_antenna_mode_to_custom()
			return
	elif option_content == "Antenna Array < N = 2 >":
		if station.get_antenna_type_raw() != "ARRAY2":
			station.set_antenna_type("ARRAY2")
			station_config.set_antenna_mode_to_custom()
			return
	elif option_content == "Antenna Array < N = 3 >":
		if station.get_antenna_type_raw() != "ARRAY3":
			station.set_antenna_type("ARRAY3")
			station_config.set_antenna_mode_to_custom()
			return
	elif option_content == "Antenna Array < N = 4 >":
		if station.get_antenna_type_raw() != "ARRAY4":
			station.set_antenna_type("ARRAY4")
			station_config.set_antenna_mode_to_custom()
			return

		
