extends Control

@onready var path_layer = $"../../PathLayer"
@onready var tile_controller = $"../TileController"
@onready var user_controller = $"../UserController"

var block_width = 150
var start_pos = Vector2(0,0)
var end_pos = Vector2(2100,1200)
var path_blocks = []

var path_block_prefab

func in_which_block(point:Vector2):
	var col = int((point.x-self.start_pos.x)/self.block_width)
	var row = int((point.y-self.start_pos.y)/self.block_width)
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
		self.path_blocks[current_row][current_col].redraw()
		current_row -= 1
		self.path_blocks[current_row][current_col].path_connectivity["bottom"] = true
		self.path_blocks[current_row][current_col].redraw()
	elif direction == "down":
		if current_row >= len(self.path_blocks) - padding - 1:
			return [current_row,current_col]
		if only_on_screen and self.path_blocks[current_row+1][current_col].position.y>1080:
			return [current_row,current_col]
		self.path_blocks[current_row][current_col].path_connectivity["bottom"] = true
		self.path_blocks[current_row][current_col].redraw()
		current_row += 1
		self.path_blocks[current_row][current_col].path_connectivity["top"] = true
		self.path_blocks[current_row][current_col].redraw()
	elif direction == "left":
		if current_col <= padding:
			return [current_row,current_col]
		if only_on_screen and self.path_blocks[current_row][current_col-1].position.x<0:
			return [current_row,current_col]
		self.path_blocks[current_row][current_col].path_connectivity["left"] = true
		self.path_blocks[current_row][current_col].redraw()
		current_col -= 1
		self.path_blocks[current_row][current_col].path_connectivity["right"] = true
		self.path_blocks[current_row][current_col].redraw()
	elif direction == "right":
		if current_col >= len(self.path_blocks[0])-padding-1:
			return [current_row,current_col]
		if only_on_screen and self.path_blocks[current_row][current_col+1].position.x>1920:
			return [current_row,current_col]
		self.path_blocks[current_row][current_col].path_connectivity["right"] = true
		self.path_blocks[current_row][current_col].redraw()
		current_col += 1
		self.path_blocks[current_row][current_col].path_connectivity["left"] = true
		self.path_blocks[current_row][current_col].redraw()
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
			current_path_block.redraw()
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
			
			# redraw all neighboured blocks.
			for i in [row-1,row,row+1]:
				for j in [col-1,col,col+1]:
					if i >= 0 and i < len(self.path_blocks) and j >= 0 and j < len(self.path_blocks[0]):
						self.path_blocks[i][j].redraw()

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
	# redraw all neighboured blocks.
	for i in [row-1,row,row+1]:
		for j in [col-1,col,col+1]:
			if i >= 0 and i < len(self.path_blocks) and j >= 0 and j < len(self.path_blocks[0]):
				self.path_blocks[i][j].redraw()
				
func clear_redundant_connection(path_block):
	if path_block.connected_direction_count() == 1:
		for key in path_block.path_connectivity:
			if path_block.path_connectivity[key] == true:
				path_block.path_connectivity[key] = false
		path_block.redraw()

# connect the ends whose connectivity are false 
# to form a path if the connectivity of 
# more than one direction is false.
func connect_potential_path(path_block):
	var false_connection = path_block.connected_directions(false)
	if len(false_connection) > 1:
		for key in path_block.path_connectivity:
			if path_block.path_connectivity[key] == false:
				path_block.path_connectivity[key] = true
		
# remove wrongly generated paths
# it is necessary to run this to maintain a proper path map
func globally_maintain_path_map():
	for i in range(len(self.path_blocks)):
		for j in range(len(self.path_blocks[i])):
			var current_path_block = self.path_blocks[i][j]
			for key in current_path_block.path_connectivity:
				if key == "top":
					if current_path_block.path_connectivity[key] == true:
						if i > 0 and self.path_blocks[i-1][j].path_connectivity["bottom"] == null or i == 0:
							current_path_block.path_connectivity[key] = null
					elif current_path_block.path_connectivity[key] == false:
						if i > 0 and self.path_blocks[i-1][j].path_connectivity["bottom"] != true or i == 0:
							current_path_block.path_connectivity[key] = null
							if not i == 0:
								self.path_blocks[i-1][j].path_connectivity["bottom"] = null
				elif key == "bottom":
					if current_path_block.path_connectivity[key] == true:
						if i < len(self.path_blocks)-1 and self.path_blocks[i+1][j].path_connectivity["top"] == null or i == len(self.path_blocks)-1:
							current_path_block.path_connectivity[key] = null
					elif current_path_block.path_connectivity[key] == false:
						if i < len(self.path_blocks)-1 and self.path_blocks[i+1][j].path_connectivity["top"] != true or i == len(self.path_blocks)-1:
							current_path_block.path_connectivity[key] = null
							if not i == len(self.path_blocks)-1:
								self.path_blocks[i+1][j].path_connectivity["top"] = false
				elif key == "left":
					if current_path_block.path_connectivity[key] == true:
						if j > 0 and self.path_blocks[i][j-1].path_connectivity["right"] == null or j == 0:
							current_path_block.path_connectivity[key] = null
					elif current_path_block.path_connectivity[key] == false:
						if j > 0 and self.path_blocks[i][j-1].path_connectivity["right"] != true or j == 0:
							current_path_block.path_connectivity[key] = null
							if not j == 0:
								self.path_blocks[i][j-1].path_connectivity["right"] = null
				elif key == "right":
					if current_path_block.path_connectivity[key] == true:
						if j < len(self.path_blocks[i]) - 1 and self.path_blocks[i][j+1].path_connectivity["left"] == null or j == len(self.path_blocks[i]) - 1:
							current_path_block.path_connectivity[key] = null
					elif current_path_block.path_connectivity[key] == false:
						if j < len(self.path_blocks[i]) - 1 and self.path_blocks[i][j+1].path_connectivity["left"] != true or j == len(self.path_blocks[i]) - 1:
							current_path_block.path_connectivity[key] = null
							if not j == len(self.path_blocks[i]) - 1:
								self.path_blocks[i][j+1].path_connectivity["left"] = null
				else:
					print("path_controller<globally_maintain_path_map>: Invalid Key.")
			current_path_block.redraw()
					
func make_map(width,start:Vector2,end:Vector2):
	var current_pos = start
	var id = 0
	while current_pos.y - 0.5 * width < end_pos.y:
		self.path_blocks.append([])
		while current_pos.x - 0.5 * width < end_pos.x:
			var current_path_block = path_block_prefab.instantiate()
			path_layer.add_child(current_path_block)
			current_path_block.id = id
			id += 1
			current_path_block.position = current_pos
			current_path_block.set_width(width)
			current_path_block.redraw()
			self.path_blocks[-1].append(current_path_block)
			current_pos.x += width
			
		current_pos.y += width
		current_pos.x = start_pos.x
	# draw paths
	make_path(0,0,len(self.path_blocks)-1,len(self.path_blocks[0])-1,false)
	make_path(0,len(self.path_blocks[0])-1,len(self.path_blocks)-1,0,false)
	make_path(int(len(self.path_blocks)/2.),0,int(len(self.path_blocks)/2.),len(self.path_blocks[0])-1,false)
	make_path(0,int(len(self.path_blocks[0])/2.),int(len(self.path_blocks)-1),int(len(self.path_blocks[0])/2.),false)
	
	for row in tile_controller.hex_list:
		for station in row:
			self.avoid_path_across_point_with_connectivity(station.position)

	# clear redundant path connections
	for row in self.path_blocks:
		for path_blcok in row:
			self.clear_redundant_connection(path_blcok)

	# connect potentially existed paths
	for row in self.path_blocks:
		for path_blcok in row:
			self.connect_potential_path(path_blcok)
	
	# remove wrongly generated paths
	self.globally_maintain_path_map()
	
func set_path_width(width):
	for row in self.path_blocks:
		for block in row:
			block.queue_free()
	self.path_blocks = []
	self.block_width = width
	make_map(block_width,self.start_pos,self.end_pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	self.start_pos = Vector2(-randi_range(0,block_width*0.5),-randi_range(0,block_width*0.5))
	self.end_pos = Vector2(1925,1085)
	
	self.path_block_prefab = preload("res://scenes/path_block_prefab.tscn")
	make_map(block_width,self.start_pos,self.end_pos)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for user in user_controller.linear_user_list:
		var block = self.in_which_block(user.position)
		print(block.in_block(user.position))
