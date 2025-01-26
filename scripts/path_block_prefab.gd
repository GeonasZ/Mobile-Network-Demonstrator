extends Node2D

@onready var path_controller

var id
# row index in the path block list
var row
# column index in the path block list
var col
var fully_spaced = false

var x_sub_pos = ["left","middle","right"]
var y_sub_pos = ["top","middle","bottom"]

var neighbours = {"right":null,"left":null,
	 			  "top":null,"bottom":null}
var width = 240
var no_access_block_color = Color(0.74,0.74,0.74,1)
var path_line_color = Color(0.5,0.5,0.5,1)
var path_line_width = 5
# each value should be either true, false or null
var path_connectivity = {"right":null,"left":null,
						 "top":null,"bottom":null}

func initialize(id, row, col, input_path_controller):
	self.id = id
	self.row = row
	self.col = col
	self.path_controller = input_path_controller

# point should be respect to the global position
func in_block(point:Vector2):
	if abs(point.x - self.global_position.x) < 0.5 * self.width * self.global_scale.x and abs(point.y - self.global_position.y) < 0.5 * self.width * self.global_scale.x:
		return true
	return false
	
func user_velocity_calc(user):
	print(self.in_block(user))
	
func at_least_connected():
	for key in path_connectivity:
		if path_connectivity[key] == true:
			return true
	return false

func at_least_not_all_connection_null():
	for key in path_connectivity:
		if path_connectivity[key] != null:
			return true
	return false

func connected_direction_count(value = true):
	var count = 0
	for key in path_connectivity:
		if path_connectivity[key] == value:
			count += 1
	return count

func connected_directions(value = true):
	var connected_directions = []
	for key in path_connectivity:
		if path_connectivity[key] == value:
			connected_directions.append(key)
	return connected_directions

func inverse_key(key):
	if key == "top":
		return "bottom"
	elif key == "bottom":
		return "top"
	elif key == "left":
		return "right"
	elif key == "right":
		return "left"
	elif key == "middle":
		return "middle"
	else:
		print("PathBlockPrefab<invserse_key>: Invalid Key.")
	
func _draw() -> void:
	pass
	
func set_connectivity(right,left,top,bottom):
	self.path_connectivity["right"] = right
	self.path_connectivity["left"] = left
	self.path_connectivity["top"] = top
	self.path_connectivity["bottom"] = bottom
	
func set_width(width):
	self.width = width


func dir_unit_vec(key):
	if key == "right":
		return Vector2(1,0)
	elif key == "left":
		return Vector2(-1,0)
	elif key == "top":
		return Vector2(0,-1)
	elif key == "bottom":
		return Vector2(0,1)
	elif key == "middle":
		return Vector2(0,0)
	else:
		print("PathBlockPrefab<dir_unit_vec>: Invalid Key.")


func nearest_connected_block():
	var count: int = 1
	var max_row = len(path_controller.path_blocks)-1
	var max_col = len(path_controller.path_blocks[0])-1
	while 1:
		# if no block is found
		if count > max_col and count > max_row:
			return null
		# travel to find the nearest block
		for j in range(0,count+1):
			for i in [-count,count]:
				if self.row+i >= 0 and self.row+i <= max_row and self.col+j >= 0 and self.col+j <= max_col:
					if path_controller.path_blocks[self.row+i][self.col+j].at_least_connected():
						return path_controller.path_blocks[self.row+i][self.col+j]
				elif self.row+i >= 0 and self.row+i <= max_row and self.col-j >= 0 and self.col-j <= max_col:
					if path_controller.path_blocks[self.row+i][self.col-j].at_least_connected():
						return path_controller.path_blocks[self.row+i][self.col-j]
				elif self.row+j >= 0 and self.row+j <= max_row and self.col+i >= 0 and self.col+i <= max_col:
					if path_controller.path_blocks[self.row+j][self.col+i].at_least_connected():
						return path_controller.path_blocks[self.row+j][self.col+i]
				elif self.row-j >= 0 and self.row-j <= max_row and self.col+i >= 0 and self.col+i <= max_col:
					if path_controller.path_blocks[self.row-j][self.col+i].at_least_connected():
						return path_controller.path_blocks[self.row-j][self.col+i]
		count += 1
		
		
func update_user_acc(user,max_acc: Vector2):
	var dis_ratio = 2
	var block_width = self.width/3.
	var user_pos = self.get_global_transform().affine_inverse()*user.global_position
	var x_key
	var y_key
	# find its x position
	if user_pos.x < -0.5*block_width:
		x_key = "left"
	elif user_pos.x > 0.5*block_width:
		x_key = "right"
	else:
		x_key = "middle"
	# find its y position
	if user_pos.y < -0.5*block_width:
		y_key = "top"
	elif user_pos.y > 0.5*block_width:
		y_key = "bottom"
	else:
		y_key = "middle"
	var unit_acc = Vector2(0,0)
	# when the block has no connection to others
	if not self.at_least_connected():
		var nearest_connected_block = self.nearest_connected_block()
		if nearest_connected_block == null:
			print("PathBlockPrefab<update_user_acc>: Cannot find a block with path connection.")
		else:
			unit_acc = user.global_position.direction_to(nearest_connected_block.global_position)
	# when the user is in the corner blocks
	elif x_key != "middle" and y_key != "middle":
		if self.path_connectivity[x_key] == true and self.path_connectivity[y_key] == true:
			if randi_range(0,1):
				unit_acc = dir_unit_vec(self.inverse_key(x_key))
			else:
				unit_acc = dir_unit_vec(self.inverse_key(y_key))
		elif self.path_connectivity[x_key] == true:
			unit_acc = dir_unit_vec(self.inverse_key(x_key))
		elif self.path_connectivity[y_key] == true:
			unit_acc = dir_unit_vec(self.inverse_key(y_key))
		else:
			unit_acc = Vector2(0,0).direction_to(dir_unit_vec(self.inverse_key(x_key))+dir_unit_vec(self.inverse_key(y_key)))
	# when the user at the top, bottom, left or right block
	elif x_key != "middle" or y_key != "middle":
		if self.path_connectivity[x_key if x_key != "middle" else y_key] == true:
			unit_acc = Vector2(1,0).rotated(randf_range(0,2*PI))
			# modify acceleration
			var ref_dir = dir_unit_vec(self.inverse_key(x_key))+dir_unit_vec(self.inverse_key(y_key))
			# reverse the reference direction if needed
			if ref_dir.dot(unit_acc) > 0:
				pass
			else:
				ref_dir = - ref_dir
			# angle_to_ref_dir must smaller than 90 degrees
			var angle_to_ref_dir = unit_acc.angle_to(ref_dir)
			
			if angle_to_ref_dir > 0.1 * PI:
				var angle_diff = angle_to_ref_dir - PI / dis_ratio
				unit_acc = unit_acc.rotated(angle_diff+randf_range(0.2*PI / dis_ratio,PI / dis_ratio))
			elif angle_to_ref_dir < -0.1 * PI:
				var angle_diff = angle_to_ref_dir + PI / dis_ratio
				unit_acc = unit_acc.rotated(angle_diff-randf_range(0.2*PI / dis_ratio,PI / dis_ratio)) 
		else:
			unit_acc = dir_unit_vec(self.inverse_key(x_key))+dir_unit_vec(self.inverse_key(y_key))
			
	# when at middle, take a noise vector as acceleration
	else:
		unit_acc = Vector2(1,0).rotated(randf_range(0,2*PI))
	
	# add some little noise to acceleration
	var noise = randfn(0,0.15) 
	if noise > 0.75:
		noise = 0.75
	elif noise < -0.75:
		noise = -0.75
	unit_acc += noise * Vector2(1,0).rotated(randf_range(0,2*PI))
	
	unit_acc = unit_acc / unit_acc.length()
	
	# make a magnitude for tne accleration
	var acc = unit_acc * randi_range(0,max_acc.length())

	return acc
	
func redraw():
	self.queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
