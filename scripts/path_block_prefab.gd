extends Node2D

var width = 240
var background_alpha = int(0.*255)
var path_color = Color8(100,100,100,int(1*255))
var path_line_width = 5
# each value should be either true, false or null
var path_connectivity = {"right":null,"left":null,
						 "top":null,"bottom":null}

func at_least_connected():
	for key in path_connectivity:
		if path_connectivity[key] == true:
			return true
	return false

func _draw() -> void:
	var block_width = int(width/3.)
	# draw the background of blocks
	draw_rect(Rect2(Vector2(-1.5*block_width,-1.5*block_width),Vector2(self.width,self.width)),Color8(255,255,255,background_alpha),true)
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
			
		# draw the top block as the reference, then transform through rotation
		if self.path_connectivity[key] == true:
			draw_line(Vector2(-0.5*block_width,-1.5*block_width),Vector2(-0.5*block_width,-0.5*block_width+0.5*path_line_width),path_color,path_line_width)
			draw_line(Vector2(0.5*block_width,-1.5*block_width),Vector2(0.5*block_width,-0.5*block_width+0.5*path_line_width),path_color,path_line_width)
		elif self.path_connectivity[key] == false:
			# draw the walls of the end of path
			draw_line(Vector2(-0.5*block_width,-1.5*block_width),Vector2(-0.5*block_width,-1*block_width),path_color,path_line_width)
			draw_line(Vector2(0.5*block_width,-1.5*block_width),Vector2(0.5*block_width,-1*block_width),path_color,path_line_width)
			# draw the end of path
			draw_line(Vector2(-0.5*block_width-path_line_width*0.5,-1*block_width),Vector2(0.5*block_width+path_line_width*0.5,-1*block_width),path_color,path_line_width)
			# draw the top edge of the central block
			draw_line(Vector2(-0.5*block_width-path_line_width*0.5,-0.5*block_width),Vector2(0.5*block_width+path_line_width*0.5,-0.5*block_width),path_color,path_line_width)
		elif self.path_connectivity[key] == null:
			if self.at_least_connected():
				# draw the top edge of the central block
				draw_line(Vector2(-0.5*block_width-0.5*path_line_width,-0.5*block_width),Vector2(0.5*block_width+0.5*path_line_width,-0.5*block_width),path_color,path_line_width)
		else:
			print("PathBlockPrefab<_draw>: Unknown Value of the Connectivity <top>.")
		
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
