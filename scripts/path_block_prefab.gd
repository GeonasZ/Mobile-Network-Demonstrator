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

func nearest_connected_block(user):
	var count: int = 1
	var max_row = len(path_controller.path_blocks)-1
	var max_col = len(path_controller.path_blocks[0])-1
	while 1:
		# if no block is found
		if count > max_col and count > max_row:
			print(count)
			return null
		# travel to find the nearest block
		var nearest_dis = null
		var nearest_block = null
		for j in range(0,count+1):
			for i in [-count,count]:
				if self.row+i >= 0 and self.row+i <= max_row and self.col+j >= 0 and self.col+j <= max_col:
					if path_controller.path_blocks[self.row+i][self.col+j].at_least_connected():
						if nearest_block == null or nearest_dis > user.global_position.distance_to(path_controller.path_blocks[self.row+i][self.col+j].global_position):
							nearest_block = path_controller.path_blocks[self.row+i][self.col+j]
							nearest_dis = user.global_position.distance_to(path_controller.path_blocks[self.row+i][self.col+j].global_position)
				if self.row+i >= 0 and self.row+i <= max_row and self.col-j >= 0 and self.col-j <= max_col:
					if path_controller.path_blocks[self.row+i][self.col-j].at_least_connected():
						if nearest_block == null or nearest_dis > user.global_position.distance_to(path_controller.path_blocks[self.row+i][self.col-j].global_position):
							nearest_block = path_controller.path_blocks[self.row+i][self.col-j]
							nearest_dis = user.global_position.distance_to(path_controller.path_blocks[self.row+i][self.col-j].global_position)
				if self.row+j >= 0 and self.row+j <= max_row and self.col+i >= 0 and self.col+i <= max_col:
					if path_controller.path_blocks[self.row+j][self.col+i].at_least_connected():
						if nearest_block == null or nearest_dis > user.global_position.distance_to(path_controller.path_blocks[self.row+j][self.col+i].global_position):
							nearest_block = path_controller.path_blocks[self.row+j][self.col+i]
							nearest_dis = user.global_position.distance_to(path_controller.path_blocks[self.row+j][self.col+i].global_position)
				if self.row-j >= 0 and self.row-j <= max_row and self.col+i >= 0 and self.col+i <= max_col:
					if path_controller.path_blocks[self.row-j][self.col+i].at_least_connected():
						if nearest_block == null or nearest_dis > user.global_position.distance_to(path_controller.path_blocks[self.row-j][self.col+i].global_position):
							nearest_block = path_controller.path_blocks[self.row-j][self.col+i]
							nearest_dis = user.global_position.distance_to(path_controller.path_blocks[self.row-j][self.col+i].global_position)
		count += 1
		
		if nearest_block != null:
			return nearest_block
		
func block_with_connection():
	for row in path_controller.path_blocks:
		for block in row:
			if block.at_least_connected():
				return block
	
func fully_spaced_connection(block):
	var fully_spaced_connected_neighbours = []
	if block.fully_spaced:
		for key in  block.neighbours:
			if  block.neighbours[key] != null and block.neighbours[key].fully_spaced and block.path_connectivity[key]==true and block.neighbours[key].path_connectivity[block.inverse_key(key)] == true:
				fully_spaced_connected_neighbours.append(key)
	return fully_spaced_connected_neighbours
	
func user_in_fully_spaced_connection_extra_area(user_pos:Vector2,x_key,y_key,block_width:float):
		
	# get the keys of fully sapced conenctions of the block
	var fully_spaced_connections = self.fully_spaced_connection(self)
	var x_key_fitted = x_key in fully_spaced_connections
	var y_key_fitted = y_key in fully_spaced_connections
	if len(fully_spaced_connections) > 0:
		if x_key_fitted:
			if abs(user_pos.y) < 1.2 * block_width:
				return true
		elif y_key_fitted:
			if abs(user_pos.x) < 1.2 * block_width:
				return true
		
func rotate_user_acc_from_station(user, unit_acc, dis_ratio, penalty_add_ratio):
	var dir_from_station = user.direction_from_station
	# modify acceleration to avoid the user getting too close to the station
	if user.distance_from_station/user.station.arc_len < dis_ratio:
		dir_from_station = dir_from_station.rotated(randf_range(-dis_ratio*PI,dis_ratio*PI)/dis_ratio*user.distance_from_station/user.station.arc_len)
		unit_acc += dir_from_station * penalty_add_ratio
	
	unit_acc = unit_acc/unit_acc.length()
	
	return unit_acc
		
func update_user_acc(user,max_acc: Vector2):
	var dis_ratio = 0.5
	var block_width = self.width/3.
	var user_pos = self.get_global_transform().affine_inverse()*user.global_position
	# the ratio to be multiplied to the magnitude of 
	# the acceleration
	var acc_mag_ratio = 1
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
		var false_connections = self.connected_directions(false)
		# if there is at least one false connection
		if len(false_connections) > 0:
			var key = false_connections[randi_range(0,len(false_connections)-1)]
			if x_key in false_connections or y_key in false_connections:
				unit_acc = dir_unit_vec(x_key)+dir_unit_vec(y_key)
			elif key == "left":
				unit_acc = user_pos.direction_to(Vector2(-1.5*block_width,0))
			elif key == "right":
				unit_acc = user_pos.direction_to(Vector2(1.5*block_width,0))
			elif key == "top":
				unit_acc = user_pos.direction_to(Vector2(0,-1.5*block_width))
			elif key == "bottom":
				unit_acc = user_pos.direction_to(Vector2(0,1.5*block_width))
			else:
				print("PathBlockPrefab<update_user_acc>: Invalid Key.")
		else:
			var nearest_connected_block = self.nearest_connected_block(user)
			# if failed to find a nearest connected block, try to find a block with connection
			if nearest_connected_block == null:
				print("PathBlockPrefab<update_user_acc>: Failed to find a nearest connected block. Trying to find a block with connection...")
				nearest_connected_block = self.block_with_connection()
				# if no block is connected, re-generate a path map
				if nearest_connected_block == null:
					print("PathBlockPrefab<update_user_acc>: Cannot find a block with path connection. Regenerating a new path map for use...")
					# re-generate a path map
					path_controller.set_path_width(path_controller.path_width)
				else:
					unit_acc = user.global_position.direction_to(nearest_connected_block.global_position)
			else:
				unit_acc = user.global_position.direction_to(nearest_connected_block.global_position)
	# when self is fully spaced and user is around center
	elif self.fully_spaced and user_pos.distance_to(Vector2(0,0)) < 0.9 * 1.5 * block_width:
		unit_acc = Vector2(1,0).rotated(randf_range(0,2*PI))
	# when self is fully spaced and one or more neighbours
	# are also fully spaced and they are connected.
	elif user_in_fully_spaced_connection_extra_area(user_pos,x_key,y_key,block_width):
		unit_acc = Vector2(1,0).rotated(randf_range(0,2*PI))
	# when the user is in the corner blocks
	elif x_key != "middle" and y_key != "middle":
		if self.path_connectivity[x_key] == true and self.path_connectivity[y_key] == true:
			if randi_range(0,1):
				unit_acc = dir_unit_vec(self.inverse_key(x_key))
			else:
				unit_acc = dir_unit_vec(self.inverse_key(y_key))
		elif self.path_connectivity[x_key] == true:
			unit_acc = dir_unit_vec(self.inverse_key(y_key))
		elif self.path_connectivity[y_key] == true:
			unit_acc = dir_unit_vec(self.inverse_key(x_key))
		else:
			unit_acc = Vector2(0,0).direction_to(dir_unit_vec(self.inverse_key(x_key))+dir_unit_vec(self.inverse_key(y_key)))
	# when the user at the top, bottom, left or right block
	elif x_key != "middle" or y_key != "middle":
		# if the block is connected to other directions
		var pos_key = x_key if x_key != "middle" else y_key
		if self.path_connectivity[pos_key] == true:
			if pos_key == "right" or pos_key == "left":
				# randomly move
				if abs((user_pos.y+1e-5)/(0.5*block_width)) < dis_ratio:
					unit_acc = Vector2(1,0).rotated(randf_range(0,2*PI))
				# move with direction
				else:
					unit_acc = Vector2(randf_range(-1,1),-(user_pos.y+1e-5)/abs(user_pos.y+1e-5)*randf_range(0,abs(user_pos.y+1e-5/(0.5*block_width))))
			elif pos_key == "top" or pos_key == "bottom":
				# randomly move
				if abs((user_pos.x+1e-5)/(0.5*block_width)) < dis_ratio:
					unit_acc = Vector2(1,0).rotated(randf_range(0,2*PI))
				# move with direction
				else:
					unit_acc = Vector2(-(user_pos.x+1e-5)/abs(user_pos.x+1e-5)*randf_range(0,abs(user_pos.x+1e-5/(0.5*block_width))),randf_range(-1,1))
		elif self.path_connectivity[pos_key] == false and not self.fully_spaced:
			if pos_key == "right" or pos_key == "left":
				if user_pos.x > block_width or user_pos.x < -block_width:
					var min_dis = min(1.5*block_width-user_pos.x,user_pos.x+1.5*block_width)
					var min_ratio = randf_range(min_dis/(0.5*block_width),1) if min_dis > 0.9 * block_width else 1
					unit_acc = randf_range(min_ratio,1) * (dir_unit_vec(x_key)+dir_unit_vec(y_key))
				else:
					unit_acc = dir_unit_vec(self.inverse_key(x_key))+dir_unit_vec(self.inverse_key(y_key))
			else:
				if user_pos.y > block_width or user_pos.y < -block_width:
					var min_dis = min(1.5*block_width-user_pos.y,user_pos.x+1.5*block_width)
					var min_ratio = randf_range(min_dis/(0.5*block_width),1) if min_dis > 0.9 * block_width else 1
					unit_acc = randf_range(min_ratio,1) * (dir_unit_vec(x_key)+dir_unit_vec(y_key))
				else:
					unit_acc = dir_unit_vec(self.inverse_key(x_key))+dir_unit_vec(self.inverse_key(y_key))
				
		else:
			unit_acc = dir_unit_vec(self.inverse_key(x_key))+dir_unit_vec(self.inverse_key(y_key))
	# when at middle, take a noise vector as acceleration
	else:
		# if the block is not fully_spaced
		if not self.fully_spaced:
			# obtain the inner position of user 
			# in the middle block
			var inner_xkey = ""
			var inner_ykey = ""
			var inner_boundary_ratio = 0.8
			# find its x position
			if user_pos.x < -inner_boundary_ratio*0.5*block_width:
				inner_xkey = "left"
			elif user_pos.x > inner_boundary_ratio*0.5*block_width:
				inner_xkey = "right"
			else:
				inner_xkey = "middle"
			# find its y position
			if user_pos.y < -inner_boundary_ratio*0.5*block_width:
				inner_ykey = "top"
			elif user_pos.y > inner_boundary_ratio*0.5*block_width:
				inner_ykey = "bottom"
			else:
				inner_ykey = "middle"
			# if the user is in the corner of the 
			# middle block
			if inner_xkey != "middle" and inner_ykey != "middle":
				var user_dis = Vector2(abs(user_pos.x),abs(user_pos.y)).distance_to(Vector2(inner_boundary_ratio*0.5*block_width,inner_boundary_ratio*0.5*block_width))
				# the distance from the outer boundary corner of the block (0.5*block_width)
				# to the inner boundary corner (inner_boundary_ratio*0.5*block_width).
				var inner_dis_diff = Vector2(0.5*block_width,0.5*block_width).distance_to(Vector2(inner_boundary_ratio*0.5*block_width,inner_boundary_ratio*0.5*block_width))
				var inner_dis_ratio = user_dis/inner_dis_diff
				unit_acc = user_pos.direction_to(Vector2(0,0)).rotated(randf_range(-PI*0.5*(1-inner_dis_ratio),PI*0.5*(1-inner_dis_ratio)))
			# if the user is in the side blocks of the
			# middle block
			elif inner_xkey != "middle" or inner_ykey != "middle":
				var inner_none_middle_key = inner_xkey if inner_xkey != "middle" else inner_ykey
				# if the side block is not connected
				if self.path_connectivity[inner_none_middle_key] != true:
					unit_acc = dir_unit_vec(self.inverse_key(inner_none_middle_key))
				# if the side block is connected
				else:
					unit_acc = Vector2(1,0).rotated(randf_range(0,2*PI))
					
			# if the user is in the middle of the 
			# middle block
			else:
				unit_acc = Vector2(1,0).rotated(randf_range(0,2*PI))
				
		else:
			unit_acc = Vector2(1,0).rotated(randf_range(0,2*PI))
		
	unit_acc = rotate_user_acc_from_station(user,unit_acc,0.5,1)
	# add some little noise to acceleration
	var noise = randfn(0,0.35) 
	if noise > 1:
		noise = 1
	elif noise < -1:
		noise = -1
	unit_acc += (acc_mag_ratio-1)*unit_acc
	unit_acc += noise * Vector2(1,0).rotated(randf_range(0,2*PI))
	
	# normalize the unit acceleration vector
	unit_acc = unit_acc / unit_acc.length()
	
	# make a magnitude for tne accleration
	var acc = unit_acc * randi_range(0,acc_mag_ratio*max_acc.length())
	
	# limit acceleration to a specific range
	if acc.length() > max_acc.length():
		acc = acc/acc.length() * max_acc.length()
	
	return acc
	
func redraw():
	self.queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
