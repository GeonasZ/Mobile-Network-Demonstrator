extends Control

@onready var path_layer = $"../../PathLayer"
@onready var tile_controller = $"../TileController"
@onready var user_controller = $"../UserController"

var block_width = 300
var start_pos = Vector2(0,0)
var end_pos = Vector2(1920,1080)
var path_blocks = []

var path_block_prefab

func user_in_which_block(user):
	return in_which_block(user.global_position)

# the point should be a global position.
func in_which_block(point:Vector2):
	var col = int((point.x-(path_layer.global_position+self.start_pos*path_layer.scale.x).x+0.5*self.block_width*path_layer.global_scale.x)/(self.block_width*path_layer.global_scale.x))
	var row = int((point.y-(path_layer.global_position+self.start_pos*path_layer.scale.y).y+0.5*self.block_width*path_layer.global_scale.x)/(self.block_width*path_layer.global_scale.y))
	if row < 0 or row >= len(self.path_blocks) or col < 0 or col >= len(self.path_blocks[0]):
		print("Point ",point)
		print("Scale ",path_layer.scale)
		print("col ", (point.x-(self.global_position+self.start_pos*path_layer.scale.x).x-0.5*self.block_width*path_layer.global_scale.x)/(self.block_width*path_layer.global_scale.x))
		print("row ",(point.y-(self.global_position+self.start_pos*path_layer.scale.y).y-0.5*self.block_width*path_layer.global_scale.x)/(self.block_width*path_layer.global_scale.y))
		print("global pos ",self.global_position)
		print("start pos ",path_layer.global_position+self.start_pos*path_layer.scale)
		print("true start pos ",self.path_blocks[0][0].global_position)
		print("col ",col," row ",row)
		return null

	return self.path_blocks[row][col]

func make_path_step(current_row,current_col,direction,only_on_screen=false,padding=0):
	if padding < 0:
		padding = 0
	if direction == "up":
		if current_row <= padding:
			return [current_row,current_col]
		if only_on_screen and self.path_blocks[current_row-1][current_col].position.y<0:
			return [current_row,current_col]
		self.path_blocks[current_row][current_col].path_connectivity["top"] = true
		current_row -= 1
		self.path_blocks[current_row][current_col].path_connectivity["bottom"] = true
	elif direction == "down":
		if current_row >= len(self.path_blocks) - padding - 1:
			return [current_row,current_col]
		if only_on_screen and self.path_blocks[current_row+1][current_col].position.y>1080:
			return [current_row,current_col]
		self.path_blocks[current_row][current_col].path_connectivity["bottom"] = true
		current_row += 1
		self.path_blocks[current_row][current_col].path_connectivity["top"] = true
	elif direction == "left":
		if current_col <= padding:
			return [current_row,current_col]
		if only_on_screen and self.path_blocks[current_row][current_col-1].position.x<0:
			return [current_row,current_col]
		self.path_blocks[current_row][current_col].path_connectivity["left"] = true
		current_col -= 1
		self.path_blocks[current_row][current_col].path_connectivity["right"] = true
	elif direction == "right":
		if current_col >= len(self.path_blocks[0])-padding-1:
			return [current_row,current_col]
		if only_on_screen and self.path_blocks[current_row][current_col+1].position.x>1920:
			return [current_row,current_col]
		self.path_blocks[current_row][current_col].path_connectivity["right"] = true
		current_col += 1
		self.path_blocks[current_row][current_col].path_connectivity["left"] = true
	else:
		print("path_controller<make_path_step>: Unknown Direction.")
		
	return [current_row,current_col]

func make_path(from_row,from_column,to_row,to_column,optimal_path=true, rand_prob=0.3):
	
	var row_diff = abs(from_row - to_row)
	var col_diff = abs(from_column - to_column)
	
	var current_row = from_row
	var current_col = from_column
	
	while current_row - to_row != 0 or current_col - to_column != 0:
		if not optimal_path:
			var thres = rand_prob * 100
			# take random steps
			while randi_range(0,100) < thres:
				for i in range(randi_range(2,4)):
					thres *= rand_prob
					# choose from the four options
					var option = randi_range(1,4)
					if option == 1:
						var temp = make_path_step(current_row,current_col,"up")
						current_row = temp[0]
						current_col = temp[1]
					elif option == 2:
						var temp = make_path_step(current_row,current_col,"down")
						current_row = temp[0]
						current_col = temp[1]
					elif option == 3:
						var temp = make_path_step(current_row,current_col,"left")
						current_row = temp[0]
						current_col = temp[1]
					else:
						var temp = make_path_step(current_row,current_col,"right")
						current_row = temp[0]
						current_col = temp[1]
		
		if current_row - to_row > 0:
			var temp = make_path_step(current_row,current_col,"up")
			current_row = temp[0]
			current_col = temp[1]
		elif current_row - to_row < 0:
			var temp = make_path_step(current_row,current_col,"down")
			current_row = temp[0]
			current_col = temp[1]

		if current_col - to_column > 0:
			var temp = make_path_step(current_row,current_col,"left")
			current_row = temp[0]
			current_col = temp[1]
		elif current_col - to_column < 0:
			var temp = make_path_step(current_row,current_col,"right")
			current_row = temp[0]
			current_col = temp[1]

func avoid_path_across_point_with_connectivity(point:Vector2):
	var col = int((point.x)/self.block_width)
	var row = int((point.y)/self.block_width)
	if col >= 0 and row >= 0 and row < len(self.path_blocks) and col < len(self.path_blocks[0]):
		var current_path_block = self.path_blocks[row][col]
		var connected_directions = current_path_block.connected_directions()
		var n_connected_directions = len(connected_directions)
		# modify connectivities without affecting the connectivity between blocks.
		if n_connected_directions == 0:
			return
		elif n_connected_directions == 1:
			current_path_block.path_connectivity[connected_directions[0]] = false
			return
		elif n_connected_directions > 1:
			if current_path_block.path_connectivity["top"] == true and current_path_block.path_connectivity["right"] == true:
				if row > 0 and col < len(self.path_blocks[0])-1:
					# modify the connectivity of the neighbour blocks
					self.path_blocks[row-1][col].path_connectivity["right"] = true
					self.path_blocks[row][col+1].path_connectivity["top"] = true
					# modify the connectivity of the coner block
					self.path_blocks[row-1][col+1].path_connectivity["left"] = true
					self.path_blocks[row-1][col+1].path_connectivity["bottom"] = true
					
			if current_path_block.path_connectivity["right"] == true and current_path_block.path_connectivity["bottom"] == true:
				if row < len(self.path_blocks) - 1 and col < len(self.path_blocks[0])-1:
					# modify the connectivity of the neighbour blocks
					self.path_blocks[row+1][col].path_connectivity["right"] = true
					self.path_blocks[row][col+1].path_connectivity["bottom"] = true
					# modify the connectivity of the coner block
					self.path_blocks[row+1][col+1].path_connectivity["left"] = true
					self.path_blocks[row+1][col+1].path_connectivity["top"] = true
			if current_path_block.path_connectivity["bottom"] == true and current_path_block.path_connectivity["left"] == true:
				if row < len(self.path_blocks) - 1 and col > 0:
					# modify the connectivity of the coner block
					self.path_blocks[row+1][col].path_connectivity["left"] = true
					self.path_blocks[row][col-1].path_connectivity["bottom"] = true
					# modify the connectivity of the neighbour blocks
					self.path_blocks[row+1][col-1].path_connectivity["right"] = true
					self.path_blocks[row+1][col-1].path_connectivity["top"] = true
			if current_path_block.path_connectivity["left"] == true and current_path_block.path_connectivity["top"] == true:
				if row > 0 and col > 0:
					# modify the connectivity of the coner block
					self.path_blocks[row-1][col].path_connectivity["left"] = true
					self.path_blocks[row][col-1].path_connectivity["top"] = true
					# modify the connectivity of the neighbour blocks
					self.path_blocks[row-1][col-1].path_connectivity["right"] = true
					self.path_blocks[row-1][col-1].path_connectivity["bottom"] = true
			if current_path_block.path_connectivity["top"] == true and current_path_block.path_connectivity["bottom"] == true:
				if row > 0 and row < len(self.path_blocks)-1:
					# if the block is on the right half of the map, the lefthand side blocks
					# would be connected
					var reverse = -1
					# if the block is on the left half of the map, the righthand side blocks
					# would be connected instead
					if col >= 0 and col <= int(len(self.path_blocks[0])/2):
						reverse = 1
					# modify the connectivity of the up and down block
					self.path_blocks[row-1][col].path_connectivity["right" if reverse == 1 else "left"] = true
					self.path_blocks[row+1][col].path_connectivity["right" if reverse == 1 else "left"] = true
					# modify the connectivity of the top left/right block
					self.path_blocks[row-1][col+1*reverse].path_connectivity["left" if reverse == 1 else "right"] = true
					self.path_blocks[row-1][col+1*reverse].path_connectivity["bottom"] = true
					# modify the connectivity of the bottom left/right block
					self.path_blocks[row+1][col+1*reverse].path_connectivity["left" if reverse == 1 else "right"] = true
					self.path_blocks[row+1][col+1*reverse].path_connectivity["bottom"] = true
					# modify the connectivity of the middle left/right block
					self.path_blocks[row][col+1*reverse].path_connectivity["top"] = true
					self.path_blocks[row][col+1*reverse].path_connectivity["bottom"] = true
				if current_path_block.path_connectivity["left"] == true and current_path_block.path_connectivity["right"] == true:
					if col > 0 and col < len(self.path_blocks[0])-1:
						# if the block is on the bottom half of the map, the top side blocks would be connected
						var reverse = -1
						# if the block is on the top half of the map, the bottom side blocks
						# would be connected instead
						if row >= 0 and row <= int(len(self.path_blocks)/2):
							reverse = 1
						# modify the connectivity of the left and right block
						self.path_blocks[row][col-1].path_connectivity["bottom" if reverse == 1 else "top"] = true
						self.path_blocks[row][col+1].path_connectivity["bottom" if reverse == 1 else "top"] = true
						# modify the connectivity of the top/bottom left block
						self.path_blocks[row+1*reverse][col-1].path_connectivity["top" if reverse == 1 else "bottom"] = true
						self.path_blocks[row+1*reverse][col-1].path_connectivity["right"] = true
						# modify the connectivity of the top/bottom right block
						self.path_blocks[row+1*reverse][col+1].path_connectivity["top" if reverse == 1 else "bottom"] = true
						self.path_blocks[row+1*reverse][col+1].path_connectivity["left"] = true
						# modify the connectivity of the top/bottom middle block
						self.path_blocks[row+1*reverse][col].path_connectivity["left"] = true
						self.path_blocks[row+1*reverse][col].path_connectivity["right"] = true
					
			# disconnect all directions of current block
			for key in current_path_block.path_connectivity:
				if current_path_block.path_connectivity[key] == true:
					current_path_block.path_connectivity[key] = false

# Not in use. Bad perforamce warning.
func just_avoid_path_across_point(point:Vector2):
	var col = int((point.x-self.start_pos.x)/self.block_width)
	var row = int((point.y-self.start_pos.y)/self.block_width)
	if col >= 0 and row >= 0 and row < len(self.path_blocks) and col < len(self.path_blocks[0]):
		var current_path_block = self.path_blocks[row][col]
		for key in current_path_block.path_connectivity:
			if current_path_block.path_connectivity[key] == true:
				if key == "top" and row > 0:
					self.path_blocks[row-1][col].path_connectivity["bottom"] = false
				elif key == "bottom" and row < len(self.path_blocks)-1:
					self.path_blocks[row+1][col].path_connectivity["top"] = false
				elif key == "left" and col > 0:
					self.path_blocks[row][col-1].path_connectivity["right"] = false
				elif key == "right" and col < len(self.path_blocks[0]) - 1:
					self.path_blocks[row][col+1].path_connectivity["left"] = false
				else:
					continue
				current_path_block.path_connectivity[key] = false

# set connectivity to false if just one direction has a connectivity of true
func clear_redundant_connection(path_block):
	if path_block.connected_direction_count() == 1:
		for key in path_block.path_connectivity:
			if path_block.path_connectivity[key] == true:
				path_block.path_connectivity[key] = false

# connect the ends whose connectivity are all false 
# to form a path if the connectivity of 
# more than one direction is false.
func connect_multi_false_path(path_block):
	var false_connection = path_block.connected_directions(false)
	if len(false_connection) > 1:
		for key in path_block.path_connectivity:
			if path_block.path_connectivity[key] == false:
				path_block.path_connectivity[key] = true
		
func connect_true_false_path(path_block):
	var false_connection = path_block.connected_directions(false)
	var true_connection = path_block.connected_directions(true)
	if len(false_connection) == 1 and len(true_connection) == 1:
		for key in path_block.path_connectivity:
			if path_block.path_connectivity[key] == false:
				path_block.path_connectivity[key] = true
				return
		
func connect_fully_spaced_neighbours(path_block):
	# dont do anything if the block is not connected at all.
	if not path_block.at_least_connected():
		return
	# try to connect the block with its fully-spaced neighbours
	for key in path_block.path_connectivity:
		if path_block.fully_spaced and path_block.neighbours[key] != null and path_block.neighbours[key].fully_spaced:
			path_block.path_connectivity[key] = true
			path_block.neighbours[key].path_connectivity[path_block.inverse_key(key)] = true
			
# remove wrongly generated paths
# it is necessary to run this to maintain a proper path map
func globally_maintain_path_map():
	for i in range(len(self.path_blocks)):
		for j in range(len(self.path_blocks[i])):
			var path_block = self.path_blocks[i][j]
			for key in path_block.path_connectivity:
				if path_block.path_connectivity[key] == true:
					if path_block.neighbours[key] != null and path_block.neighbours[key].path_connectivity[path_block.inverse_key(key)] == null or path_block.neighbours[key] == null:
						path_block.path_connectivity[key] = null
					elif path_block.neighbours[key] != null and path_block.neighbours[key].fully_spaced and path_block.neighbours[key].path_connectivity[path_block.inverse_key(key)] != true:
						path_block.path_connectivity[key] = null
				elif path_block.path_connectivity[key] == false:
					if path_block.neighbours[key] != null and path_block.neighbours[key].path_connectivity[path_block.inverse_key(key)] == false or path_block.neighbours[key] == null:
						path_block.path_connectivity[key] = null
						if path_block.neighbours[key] != null:
							path_block.neighbours[key].path_connectivity[path_block.inverse_key(key)] = null
		
			path_layer.redraw()

# generate more random paths on the map. connectivity 
# throughout the whole map is not garenteed.
func generate_random_paths():
	# draw paths
	make_path(0,0,len(self.path_blocks)-1,len(self.path_blocks[0])-1,false)
	make_path(0,len(self.path_blocks[0])-1,len(self.path_blocks)-1,0,false)
	make_path(int(len(self.path_blocks)/2.),0,int(len(self.path_blocks)/2.),len(self.path_blocks[0])-1,false)
	make_path(0,int(len(self.path_blocks[0])/2.),int(len(self.path_blocks)-1),int(len(self.path_blocks[0])/2.),false)
	
	for row in tile_controller.hex_list:
		for station in row:
			self.avoid_path_across_point_with_connectivity(station.position)

	# clear some of the redundant path connections, keep the others to keep the path variaty
	for row in self.path_blocks:
		for path_blcok in row:
			# clear half of the connections and keep the other half
			if randi_range(0,1):
				self.clear_redundant_connection(path_blcok)
	
	# connect potentially existed paths
	for row in self.path_blocks:
		for path_blcok in row:
			self.connect_multi_false_path(path_blcok)
			
	# connect neighboured fully-spaced blocks 
	for row in self.path_blocks:
		for path_blcok in row:
			self.connect_fully_spaced_neighbours(path_blcok)
	
	# remove wrongly generated paths
	self.globally_maintain_path_map()

func _randomly_update_block_connectivity(block, threshold=null):	
	if threshold == null:
		var connection_count = block.connected_direction_count()
		threshold = randi_range(15,max(25*(3-connection_count),20))

	for key in block.path_connectivity:
		if block.path_connectivity[key] == null and block.neighbours[key] != null:
			if randi_range(0,99) < threshold:
				block.path_connectivity[key] = true
				if randf_range(0,99) < threshold * 1.5:
					block.neighbours[key].path_connectivity[block.inverse_key(key)] = true
				else:
					block.neighbours[key].path_connectivity[block.inverse_key(key)] = false

func _generate_better_connected_paths(bonused_produce_times,_count_down,_untraveled_blocks,_block=null):
	# randomly initialize a block as start if the block is not specified
	if _block == null:
		var row = randi_range(int(len(self.path_blocks)*0.4),int(len(self.path_blocks)*0.6))
		var col = randi_range(int(len(self.path_blocks[0])*0.4),int(len(self.path_blocks[0])*0.6))
		_block = self.path_blocks[row][col]
	# mark the block itself as has been travelled
	_untraveled_blocks.erase(_block)
	var thres = null
	if _count_down > 0:
		thres = (_count_down/bonused_produce_times) * 50 + 50
	_randomly_update_block_connectivity(_block, thres)
	for key in _block.path_connectivity:
		if _block.neighbours[key] != null and _block.neighbours[key] in _untraveled_blocks:
			_generate_better_connected_paths(bonused_produce_times, _count_down - 1, _untraveled_blocks, _block.neighbours[key])
	
# generate random paths on the map. connectivity throughout the
# whole map is still not garenteed, but is expected to be better
# than generate_random_paths().
func generate_better_connected_paths(bonused_produce_times):
	_generate_better_connected_paths(bonused_produce_times, bonused_produce_times, path_layer.get_children())
	for row in self.path_blocks:
		for block in row:
			if randi_range(0,99) < 70:
				connect_multi_false_path(block)
			if randi_range(0,99) < 70:
				connect_true_false_path(block)
			connect_fully_spaced_neighbours(block)
	globally_maintain_path_map()

# generate random paths on the map. connectivity throughout the
# whole map is garenteed.
func _generate_fully_connected_paths(_block_list,_bonus_count_down=1,_block_travel_times_list=null,_max_travel_time=4,_block=null):
	# randomly initialize a block as start if the block is not specified
	if _block == null:
		var row = randi_range(int(len(self.path_blocks)*0.4),int(len(self.path_blocks)*0.6))
		var col = randi_range(int(len(self.path_blocks[0])*0.4),int(len(self.path_blocks[0])*0.6))
		_block = self.path_blocks[row][col]
		_block.set_connectivity(true,true,true,true)
		
	# if there is not a block travel list from input, 
	# initialize a block travel_times list
	if _block_travel_times_list == null:
		_block_travel_times_list = []
		for i in range(len(_block_list)):
			_block_travel_times_list.append(0)
			
	# determine whether the block has been traveled too many times
	var index = _block_list.find(_block)
	if _block_travel_times_list[index] < _max_travel_time:
		_block_travel_times_list[index] += 1
		if _block.at_least_connected():

			# update the block itself
			var n_connections = _block.connected_direction_count()
			for key in _block.path_connectivity:
				if _block.path_connectivity[key] == null:
					if randi_range(0,99) < (4-n_connections) * 25:
						_block.path_connectivity[key] = true
						
			# update the enighbour blocks
			for key in _block.path_connectivity:
				if _block.neighbours[key] != null:
					if _block.path_connectivity[key] == true and _block.neighbours[key].path_connectivity[_block.inverse_key(key)] == null:
						var do_connect = randi_range(0,99) < 70
						if do_connect:
							_block.neighbours[key].path_connectivity[_block.inverse_key(key)] = true
						else:
							if _bonus_count_down > 0:
								_block.neighbours[key].path_connectivity[_block.inverse_key(key)] = true
								_bonus_count_down -= 1
							else:
								_block.neighbours[key].path_connectivity[_block.inverse_key(key)] = false
						if _block.neighbours[key].at_least_connected():
							_generate_fully_connected_paths(_block_list,_bonus_count_down,_block_travel_times_list,_max_travel_time,_block.neighbours[key])
			
func generate_fully_connected_paths():
	var blocks = path_layer.get_children()
	while 1:
		_generate_fully_connected_paths(blocks)
		# ensure the number of blocked which has connections are not too small
		var n_connected_block = 0
		for row in self.path_blocks:
			for block in row:
				if block.at_least_not_all_connection_null():
					n_connected_block += 1
		if n_connected_block < len(self.path_blocks)*len(self.path_blocks[0]) * 0.25:
			print("PathController<generate_fully_connected_paths>: There are too few blocks connected in current map. Trying to regenerate another one...")
		else:
			break

	for row in self.path_blocks:
		for block in row:

			connect_fully_spaced_neighbours(block)
			
	globally_maintain_path_map()
			
## used to generate lakes from a fully-spaced block
## after the path generation has been done
func make_lake():
	var lakes = []
	var blocks_with_connection = 0
	for row in self.path_blocks:
		for block in row:
			if block.at_least_connected():
				blocks_with_connection += 1
			var neighbour_is_lake = false
			for key in block.neighbours:
				if block.neighbours[key] != null and block.neighbours[key].lake:
					neighbour_is_lake = true
					break
			if not neighbour_is_lake and block.at_least_connected() and not block.building:
				for key in block.neighbours:
					if block.neighbours[key] != null and block.neighbours[key].at_least_connected():
						lakes.append(block)
						block.lake = true
					break
					
	var n_lake = 0
	if len(lakes) == 0:
		return
	
	while 1:
		var i = randi_range(0,len(lakes)-1)
		var block = lakes[i]
		
		block.lake = false
		var thres = (blocks_with_connection * 0.05 - n_lake)/(blocks_with_connection * 0.05) * 100
		if randi_range(0, 99) < thres:
			n_lake += 1
			block.fully_spaced = true
			block.lake = true
						
		lakes.pop_at(i)
		if len(lakes) == 0:
			break
			
func make_path_block(pos):
	pass
			
func make_map(width,start:Vector2,end:Vector2):
	var current_pos = start
	var id = 0
	var col = 0
	var row = 0
	while current_pos.y - 0.5 * width < end_pos.y:
		self.path_blocks.append([])
		while current_pos.x - 0.5 * width < end_pos.x:
			var current_path_block = path_block_prefab.instantiate()
			path_layer.add_child(current_path_block)
			current_path_block.initialize(id,row,col,self)
			current_path_block.position = current_pos
			current_path_block.set_width(width)
			self.path_blocks[-1].append(current_path_block)
			current_pos.x += width
			id += 1
			col += 1
		col = 0
		row += 1
		current_pos.y += width
		current_pos.x = start_pos.x
		
	# record the four neighbour blocks for each block
	for i in range(len(self.path_blocks)):
		for j in range(len(self.path_blocks[i])):
			if i > 0:
				self.path_blocks[i][j].neighbours["top"] = self.path_blocks[i-1][j]
			if i < len(self.path_blocks) - 1:
				self.path_blocks[i][j].neighbours["bottom"] = self.path_blocks[i+1][j]
			if j > 0:
				self.path_blocks[i][j].neighbours["left"] = self.path_blocks[i][j-1]
			if j < len(self.path_blocks[i]) - 1:
				self.path_blocks[i][j].neighbours["right"] = self.path_blocks[i][j+1]
					
	
	# set some of the blocks to the fully-spaced style.
	for i in range(len(self.path_blocks)):
		var threshold = randi_range(5,50)
		for j in range(len(self.path_blocks[i])):
			# clear half of the connections and keep the other half
			if randi_range(0,99) < threshold:
				self.path_blocks[i][j].fully_spaced = true
				
	#generate_random_paths()
	#generate_better_connected_paths(10)
	generate_fully_connected_paths()
	make_lake()
	
	for row2 in self.path_blocks:
		for block in row2:
			connect_fully_spaced_neighbours(block)
	

	path_layer.redraw()
	#print(len(self.path_blocks)*len(self.path_blocks[0]))
	#print(path_layer.get_child_count())
	
func set_block_width(width):
	for row in self.path_blocks:
		for block in row:
			path_layer.remove_child(block)
			block.queue_free()
	self.path_blocks = []
	self.block_width = width
	make_map(block_width,self.start_pos,self.end_pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	self.start_pos = Vector2(-randi_range(block_width*0.2,block_width*0.5),-randi_range(block_width*0.2,block_width*0.5))
	
	self.path_block_prefab = preload("res://scenes/path_block_prefab.tscn")
	make_map(block_width,self.start_pos,self.end_pos)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
