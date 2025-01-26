extends Node2D

var background_color = Color(1,1,1,0.3)

func _draw() -> void:
	# draw the background of blocks
	draw_rect(Rect2(Vector2(0,0),Vector2(1920,1080)),background_color,true)
	# draw all children
	for block in self.get_children():
		var block_width = int(block.width/3.)
		var at_least_not_all_connection_null = block.at_least_not_all_connection_null()
		var at_least_connected = block.at_least_connected()
		var path_line_width = block.path_line_width
		var path_line_color = block.path_line_color
		var no_access_block_color = block.no_access_block_color
		# highlight the border of each block
		draw_set_transform(block.position,0)
		draw_rect(Rect2(Vector2(-1.5*block_width,-1.5*block_width),Vector2(block.width,block.width)),Color8(255,0,0),false,2)
		# fully-spaced block style
		if block.fully_spaced:
			if at_least_connected:
				for key in block.path_connectivity:
						if key == "right":
							draw_set_transform(block.position,PI/2)
						elif key == "top":
							draw_set_transform(block.position,0)
						elif key == "bottom":
							draw_set_transform(block.position,PI)
						elif key == "left":
							draw_set_transform(block.position,PI*1.5)
						else:
							print("PathBlockPrefab<_draw>: Invalid Key in path_connectivity (key='%s')"%str(key))
							continue
						# draw the top block as a reference, then transform through rotation
						if block.neighbours[key] != null:
							if not block.neighbours[key].fully_spaced and block.path_connectivity[key] == true:
								draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(-0.5*block_width+0.5*path_line_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
								draw_line(Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(0.5*block_width-0.5*path_line_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
							elif block.neighbours[key].fully_spaced and block.neighbours[key].path_connectivity[block.inverse_key(key)] == true:
								pass
							else:
								draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
				for v_key in ["top","bottom"]:
					for h_key in ["left","right"]:
						if block.neighbours[v_key] == null or block.neighbours[h_key] == null:
							continue
						elif block.neighbours[v_key].fully_spaced and block.neighbours[h_key].fully_spaced and not block.neighbours[v_key].neighbours[h_key].fully_spaced:
							draw_set_transform(block.position,0)
							if v_key == "top" and h_key == "left":
								draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(-1.5*block_width+path_line_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
							elif v_key == "top" and h_key == "right":
								draw_line(Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(1.5*block_width-path_line_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
							elif v_key == "bottom" and h_key == "left":
								draw_line(Vector2(-1.5*block_width,1.5*block_width-0.5*path_line_width),Vector2(-1.5*block_width+path_line_width,1.5*block_width-0.5*path_line_width),path_line_color,path_line_width)
							elif v_key == "bottom" and h_key == "right":
								draw_line(Vector2(1.5*block_width,1.5*block_width-0.5*path_line_width),Vector2(1.5*block_width-path_line_width,1.5*block_width-0.5*path_line_width),path_line_color,path_line_width)
							else:
								print("PathBlockPrefab<_draw>: Invalid combination of keys.")
								
			# if no access is allowed to the block
			else:		
				# draw the whole block as no-access style
				draw_rect(Rect2(Vector2(-1.5*block_width,-1.5*block_width),Vector2(block.width,block.width)),no_access_block_color,true)
		# not fully-spaced block style
		else:
			# if at least one of the connectivity of block is not null
			if at_least_not_all_connection_null:
				
				# draw the four corner blocks as no-access style
				draw_rect(Rect2(Vector2(-1.5*block_width,-1.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
				draw_rect(Rect2(Vector2(0.5*block_width,-1.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
				draw_rect(Rect2(Vector2(-1.5*block_width,0.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
				draw_rect(Rect2(Vector2(0.5*block_width,0.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
				
				for key in block.path_connectivity:
					if key == "right":
						draw_set_transform(block.position,PI/2)
					elif key == "top":
						draw_set_transform(block.position,0)
					elif key == "bottom":
						draw_set_transform(block.position,PI)
					elif key == "left":
						draw_set_transform(block.position,PI*1.5)
					else:
						print("PathBlockPrefab<_draw>: Invalid Key in path_connectivity (key='%s')"%str(key))
						continue
					# draw the top block as a reference, then transform through rotation
					if block.path_connectivity[key] == true:
						draw_line(Vector2(-0.5*block_width,-1.5*block_width),Vector2(-0.5*block_width,-0.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
						draw_line(Vector2(0.5*block_width,-1.5*block_width),Vector2(0.5*block_width,-0.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
					elif block.path_connectivity[key] == false:
						draw_rect(Rect2(Vector2(-0.5*block_width,-1*block_width),Vector2(block_width,block_width/2)),no_access_block_color,true)
						# draw the walls of the end of path
						draw_line(Vector2(-0.5*block_width,-1.5*block_width),Vector2(-0.5*block_width,-1*block_width),path_line_color,path_line_width)
						draw_line(Vector2(0.5*block_width,-1.5*block_width),Vector2(0.5*block_width,-1*block_width),path_line_color,path_line_width)
						# draw the end of path
						draw_line(Vector2(-0.5*block_width-path_line_width*0.5,-1*block_width),Vector2(0.5*block_width+path_line_width*0.5,-1*block_width),path_line_color,path_line_width)
						# draw the top edge of the central block
						if at_least_connected:
							draw_line(Vector2(-0.5*block_width-path_line_width*0.5,-0.5*block_width),Vector2(0.5*block_width+path_line_width*0.5,-0.5*block_width),path_line_color,path_line_width)
					elif block.path_connectivity[key] == null:
						# draw the backgorund color
						draw_rect(Rect2(Vector2(-0.5*block_width,-1.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
						# draw the top edge of the central block
						if at_least_connected:
							draw_line(Vector2(-0.5*block_width-0.5*path_line_width,-0.5*block_width),Vector2(0.5*block_width+0.5*path_line_width,-0.5*block_width),path_line_color,path_line_width)
					else:
						print("PathBlockPrefab<_draw>: Unknown Value of the Connectivity <top>.")
				# draw the center block to "no access" style if no connection is done.
				if not at_least_connected:
					draw_rect(Rect2(Vector2(-0.5*block_width,-0.5*block_width),Vector2(block_width,block_width)),no_access_block_color,true)
			else:
				# draw the whole block as no-access style
				draw_rect(Rect2(Vector2(-1.5*block_width,-1.5*block_width),Vector2(block.width,block.width)),no_access_block_color,true)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func redraw():
	self.queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(self.position)
	#print(self.scale)
	pass
