extends Node2D

var background_color = Color(1,1,1,0.3)

var lake
var map_visible = true

func draw_sector(center, radius, start_rad, end_rad, n_points, color):
	# create a point list for the sector
	var points = [center]
	for i in range(n_points + 1):
		var angle = lerp(start_rad, end_rad, float(i) / float(n_points))
		var point = center + Vector2(cos(angle), sin(angle)) * radius
		points.append(point)
	# draw a sector
	draw_colored_polygon(points, color)

func cubic_value_limit(current_x,start_x,start_y,end_x,end_y):
	end_x -= start_x
	if current_x < start_x:
		current_x = 0
	elif current_x > end_x:
		current_x = end_x
	else:
		current_x -= start_x
		
	#print("start_x ",start_x,"current ",current_x, "end ", end_x)
	var a0 = start_y
	var a1 = 0
	var a2 = 3/pow(end_x,2)*(end_y-start_y)
	var a3 = -2/pow(end_x,3)*(end_y-start_y)
	return a0*pow(current_x,3)+a1*pow(current_x,2)+a2*pow(current_x,1)+a3

# draw a circle, taking the effect of draw_set_transform() into account
## return [actual max radius of the lake, a list containing all points to draw the lake]
func draw_circle_lake(origin:Vector2, ref_radius:float, max_radius, min_radius, border_width,noise_factor=35, noise_spread=1e-3):
	var lake_color = Color8(100,100,220,170)
	var lake_border_color = Color8(0,0,255,170)
	var noise_obj = FastNoiseLite.new()
	var start_rad = randf_range(-PI,PI)
	var max_ref_diff = max_radius - ref_radius
	var ref_min_diff = ref_radius - min_radius
	var start_pos = Vector2(randi_range(ref_radius-ref_min_diff*0.5, max_ref_diff*0.5+ref_radius),0).rotated(start_rad)
	var start_pos_len = start_pos.length()
	noise_obj.noise_type = FastNoiseLite.TYPE_PERLIN
	# draw the border of the lake
	var n_point = 2*PI*ref_radius
	var elementary_dis_diff = (2*PI*ref_radius)/(n_point)
	var noise
	var noise_sum = 0
	var points = []
	var current_ref_pos
	var current_pos
	var actual_max_radius = 0
	for i in range(int(n_point)):
		var current_rad = 2*PI/n_point*i
		var sq = current_rad * (current_rad-0.5*PI) * (current_rad-1.*PI) * (current_rad-1.5*PI) * (current_rad-2*PI)
		var limited_sq = sq if sq >= 0 else 0
		current_ref_pos = Vector2(ref_radius,0).rotated(current_rad+start_rad)
		
		noise = noise_obj.get_noise_2dv(noise_spread*current_ref_pos) * noise_factor
		
		# limit the radius between max_radius and min_radius by changing the noise generated
		var intended_radius = ref_radius + (noise_sum+noise) * limited_sq
		if intended_radius > max_ref_diff*0.5+ref_radius and noise > 0:
			var modified_noise = noise*cubic_value_limit(intended_radius,ref_radius+0.7*max_ref_diff,1,max_radius,0)
			noise = randi_range(modified_noise-noise, modified_noise)
		elif intended_radius < ref_min_diff*0.5+min_radius and noise < 0:
			var modified_noise = noise*cubic_value_limit(intended_radius,min_radius,0,ref_radius-0.7*ref_min_diff,1)
			noise = randi_range(modified_noise-noise, modified_noise)
			
		noise_sum += noise
		
		var current_radius = start_pos_len + noise_sum * limited_sq
		current_pos = current_radius * Vector2(1,0).rotated(current_rad+start_rad)
		
		if current_radius > actual_max_radius:
			actual_max_radius = current_radius
		
		points.append(current_pos)
	points.append(start_pos)
	draw_polyline(points,lake_border_color,border_width)
	draw_colored_polygon(points,lake_color)
	return [actual_max_radius, points]
	
func draw_block_stored_lake(block, border_width):
	var lake_color = Color8(100,100,220)
	var lake_border_color = Color8(0,0,255)
	draw_polyline(block.lake_shape,lake_border_color,border_width)
	draw_colored_polygon(block.lake_shape,lake_color)
	
		
func _draw() -> void:
	# draw the background of blocks
	draw_rect(Rect2(Vector2(0,0),Vector2(1920,1080)),background_color,true)
	if not map_visible:
		return
	# draw all children
	for block in self.get_children():
		var block_width = int(block.width/3.)
		var at_least_not_all_connection_null = block.at_least_not_all_connection_null()
		var at_least_connected = block.at_least_connected()
		var path_line_width = block.path_line_width
		var lawn_edge_color = block.lawn_edge_color
		var lawn_color = block.lawn_color
		var building_color = block.building_color
		var building_wall_color = block.building_wall_color
		
		var path_line_color = lawn_edge_color
		var no_access_block_color = lawn_color
		
		# set draw transform to default
		draw_set_transform(block.position,0)
		

		# fully-spaced block style
		if block.fully_spaced:
			pass
			# if the block is a building
			if block.building:
				# draw building background
				draw_rect(Rect2(Vector2(-1.5*block_width+path_line_width,-1.5*block_width+path_line_width),Vector2(block.width-2*path_line_width,block.width-2*path_line_width)),building_color,true)
				# connect the background tiles if neighbours are also buildings
				# only connect two directions, so that will not be connected twice 
				if block.neighbours["top"] != null and block.neighbours["top"].building:
					draw_rect(Rect2(Vector2(-1.5*block_width+path_line_width,-1.5*block_width-path_line_width),Vector2(3*block_width-path_line_width-path_line_width,2*path_line_width)),building_color,true)
				if block.neighbours["left"] != null and block.neighbours["left"].building:
					pass
					draw_rect(Rect2(Vector2(-1.5*block_width-path_line_width,-1.5*block_width+path_line_width),Vector2(2*path_line_width,3*block_width-path_line_width-path_line_width)),building_color,true)
					
			elif at_least_connected:
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
							if not block.neighbours[key].building:
								if not block.neighbours[key].fully_spaced and block.path_connectivity[key] == true:
									draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(-0.5*block_width+0.5*path_line_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
									draw_line(Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(0.5*block_width-0.5*path_line_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
								elif block.neighbours[key].fully_spaced and block.neighbours[key].path_connectivity[block.inverse_key(key)] == true:
									pass
									## draw the building wall if neighbour is a building
									#if block.building == ! block.neighbours[key].building:
										#draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(-0.5*block_width,-1.5*block_width+0.5*path_line_width),building_wall_color,path_line_width)
										#draw_line(Vector2(0.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),building_wall_color,path_line_width)
								else:
									draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
				
				# draw a small square to fill the blank space of 
				# two lines in fully-spaced blocks
				#for v_key in ["top","bottom"]:
					#for h_key in ["left","right"]:
						#if block.neighbours[v_key] == null or block.neighbours[h_key] == null:
							#continue
						#elif block.neighbours[v_key].fully_spaced and block.neighbours[h_key].fully_spaced and not block.neighbours[v_key].neighbours[h_key].fully_spaced:
							#draw_set_transform(block.position,0)
							#if v_key == "top" and h_key == "left":
								#draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(-1.5*block_width+path_line_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
							#elif v_key == "top" and h_key == "right":
								#draw_line(Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(1.5*block_width-path_line_width,-1.5*block_width+0.5*path_line_width),path_line_color,path_line_width)
							#elif v_key == "bottom" and h_key == "left":
								#draw_line(Vector2(-1.5*block_width,1.5*block_width-0.5*path_line_width),Vector2(-1.5*block_width+path_line_width,1.5*block_width-0.5*path_line_width),path_line_color,path_line_width)
							#elif v_key == "bottom" and h_key == "right":
								#draw_line(Vector2(1.5*block_width,1.5*block_width-0.5*path_line_width),Vector2(1.5*block_width-path_line_width,1.5*block_width-0.5*path_line_width),path_line_color,path_line_width)
							#else:
								#print("PathBlockPrefab<_draw>: Invalid combination of keys.")
				
				## draw a lake
				if block.lake:
					var ref_lake_radius = 100
					var lake_scale = Vector2(block.width/3./ref_lake_radius,block.width/3./ref_lake_radius)
					draw_set_transform(block.position,randf_range(0,2*PI), lake_scale)
					if block.lake_shape == null:
						var temp = draw_circle_lake(Vector2(0,0), ref_lake_radius*0.75, ref_lake_radius*1, ref_lake_radius*0.5, 5)
						block.max_lake_radius = temp[0] * lake_scale.x
						block.lake_shape = temp[1]
					else:
						draw_block_stored_lake(block, 5)
						
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
		
	# draw walls for the buildings after all other drawings have been done
	# so that the walls are on the top layer
	for block in self.get_children():
		if block.building:
			var block_width = int(block.width/3.)
			var path_line_width = block.path_line_width
			var building_color = block.building_color
			var building_wall_color = block.building_wall_color
			
			# set draw transform to default
			draw_set_transform(block.position,0)
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
						# draw building walls
						if (block.building == ! block.neighbours[key].building and block.path_connectivity[key] == true) or (not block.neighbours[key].fully_spaced and block.path_connectivity[key] == true):
							draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(-0.5*block_width+0.5*path_line_width,-1.5*block_width+0.5*path_line_width),building_wall_color,path_line_width)
							draw_line(Vector2(0.5*block_width-0.5*path_line_width,-1.5*block_width+0.5*path_line_width),Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),building_wall_color,path_line_width)
						elif block.path_connectivity[key] != true:
							draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),building_wall_color,path_line_width)
				
			for v_key in ["top","bottom"]:
				for h_key in ["left","right"]:
					if block.neighbours[v_key] == null or block.neighbours[h_key] == null:
						continue
					# draw a small square to fill the blank space between building blocks
					elif block.neighbours[v_key].building and block.neighbours[h_key].building and not block.neighbours[v_key].neighbours[h_key].building:
						draw_set_transform(block.position,0)
						if v_key == "top" and h_key == "left":
							draw_line(Vector2(-1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(-1.5*block_width+path_line_width,-1.5*block_width+0.5*path_line_width),building_wall_color,path_line_width)
						elif v_key == "top" and h_key == "right":
							draw_line(Vector2(1.5*block_width,-1.5*block_width+0.5*path_line_width),Vector2(1.5*block_width-path_line_width,-1.5*block_width+0.5*path_line_width),building_wall_color,path_line_width)
						elif v_key == "bottom" and h_key == "left":
							draw_line(Vector2(-1.5*block_width,1.5*block_width-0.5*path_line_width),Vector2(-1.5*block_width+path_line_width,1.5*block_width-0.5*path_line_width),building_wall_color,path_line_width)
						elif v_key == "bottom" and h_key == "right":
							draw_line(Vector2(1.5*block_width,1.5*block_width-0.5*path_line_width),Vector2(1.5*block_width-path_line_width,1.5*block_width-0.5*path_line_width),building_wall_color,path_line_width)
						else:
							print("PathBlockPrefab<_draw>: Invalid combination of keys.")
			if block.neighbours["left"] != null and block.neighbours["top"] != null and block.neighbours["left"].neighbours["top"] != null:
				if block.neighbours["left"].building and block.neighbours["top"].building and block.neighbours["left"].neighbours["top"].building:
					draw_set_transform(block.position,0)
					draw_rect(Rect2(Vector2(-1.5*block_width-path_line_width,-1.5*block_width-path_line_width),Vector2(2*path_line_width,2*path_line_width)),building_color,path_line_width)
							
	# highlight the border of each block, for testing usage
	for block in self.get_children():
		var block_width = int(block.width/3.)
		draw_set_transform(block.position,0)
		draw_rect(Rect2(Vector2(-1.5*block_width,-1.5*block_width),Vector2(block.width,block.width)),Color8(255,0,0),false,2)
		
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
