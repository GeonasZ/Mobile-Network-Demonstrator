extends Node2D

var id
var width = 240
var no_access_block_color = Color(0.74,0.74,0.74,1)
var path_color = Color8(130,130,130,int(1*255))
var path_line_width = 5
# each value should be either true, false or null
var path_connectivity = {"right":null,"left":null,
						 "top":null,"bottom":null}

func in_block(point:Vector2):
	if abs(point.x - self.global_position.x) < self.width and abs(point.y - self.global_position.y) < self.width:
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

func _draw() -> void:
	var block_width = int(width/3.)
	var at_least_not_all_connection_null = self.at_least_not_all_connection_null()
	var at_least_connected = self.at_least_connected()
	
	# highlight the border of each block
	draw_rect(Rect2(Vector2(-1.5*block_width,-1.5*block_width),Vector2(self.width,self.width)),Color8(255,0,0),false,2)
	
	if at_least_not_all_connection_null:
		
		draw_rect(Rect2(Vector2(-1.5*block_width,-1.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
		draw_rect(Rect2(Vector2(0.5*block_width,-1.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
		draw_rect(Rect2(Vector2(-1.5*block_width,0.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
		draw_rect(Rect2(Vector2(0.5*block_width,0.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
		
		for key in path_connectivity:
			if key == "right":
				draw_set_transform(Vector2(0,0),PI/2)
			elif key == "top":
				draw_set_transform(Vector2(0,0),0)
			elif key == "bottom":
				draw_set_transform(Vector2(0,0),PI)
			elif key == "left":
				draw_set_transform(Vector2(0,0),PI*1.5)
			else:
				print("PathBlockPrefab<_draw>: Invalid Key in path_connectivity (key='%s')"%str(key))
				continue
				
			# draw the top block as a reference, then transform through rotation
			if self.path_connectivity[key] == true:
				draw_line(Vector2(-0.5*block_width,-1.5*block_width),Vector2(-0.5*block_width,-0.5*block_width+0.5*path_line_width),path_color,path_line_width)
				draw_line(Vector2(0.5*block_width,-1.5*block_width),Vector2(0.5*block_width,-0.5*block_width+0.5*path_line_width),path_color,path_line_width)
			elif self.path_connectivity[key] == false:
				draw_rect(Rect2(Vector2(-0.5*block_width,-1*block_width),Vector2(block_width,block_width/2)),no_access_block_color,true)
				# draw the walls of the end of path
				draw_line(Vector2(-0.5*block_width,-1.5*block_width),Vector2(-0.5*block_width,-1*block_width),path_color,path_line_width)
				draw_line(Vector2(0.5*block_width,-1.5*block_width),Vector2(0.5*block_width,-1*block_width),path_color,path_line_width)
				# draw the end of path
				draw_line(Vector2(-0.5*block_width-path_line_width*0.5,-1*block_width),Vector2(0.5*block_width+path_line_width*0.5,-1*block_width),path_color,path_line_width)
				# draw the top edge of the central block
				if at_least_connected:
					draw_line(Vector2(-0.5*block_width-path_line_width*0.5,-0.5*block_width),Vector2(0.5*block_width+path_line_width*0.5,-0.5*block_width),path_color,path_line_width)
			elif self.path_connectivity[key] == null:
				# draw the backgorund color
				draw_rect(Rect2(Vector2(-0.5*block_width,-1.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
				# draw the top edge of the central block
				if at_least_connected:
					draw_line(Vector2(-0.5*block_width-0.5*path_line_width,-0.5*block_width),Vector2(0.5*block_width+0.5*path_line_width,-0.5*block_width),path_color,path_line_width)
			else:
				print("PathBlockPrefab<_draw>: Unknown Value of the Connectivity <top>.")
		if not at_least_connected:
			draw_rect(Rect2(Vector2(-0.5*block_width,-0.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
	else:
		draw_rect(Rect2(Vector2(-1.5*block_width,-1.5*block_width),Vector2(self.width,self.width)),no_access_block_color,true)
		
func set_connectivity(right,left,top,bottom):
	self.path_connectivity["right"] = right
	self.path_connectivity["left"] = left
	self.path_connectivity["top"] = top
	self.path_connectivity["bottom"] = bottom
	
func set_width(width):
	self.width = width
	
func redraw():
	self.queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
