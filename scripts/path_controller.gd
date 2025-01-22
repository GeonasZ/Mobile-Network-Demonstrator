extends Control

@onready var path_layer = $"../../PathLayer"

var block_width = 240
var start_pos = Vector2(0,0)
var end_pos = Vector2(1920,1080)
var path_blocks = []

var path_block_prefab

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

func make_map(width,start:Vector2,end:Vector2):
	var current_pos = start
	while current_pos.y - 0.5 * width < end_pos.y:
		self.path_blocks.append([])
		while current_pos.x - 0.5 * width < end_pos.x:
			var current_path_block = path_block_prefab.instantiate()
			path_layer.add_child(current_path_block)
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

func set_path_width(width):
	
	for row in self.path_blocks:
		for block in row:
			block.queue_free()
	self.path_blocks = []
	self.block_width = width
	make_map(block_width,self.start_pos,self.end_pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	self.start_pos = Vector2(-randi_range(0,block_width*0.1),-randi_range(0,block_width*0.1))
	self.end_pos = Vector2(1925,1085)
	
	self.path_block_prefab = preload("res://scenes/path_block_prefab.tscn")
	make_map(block_width,self.start_pos,self.end_pos)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
