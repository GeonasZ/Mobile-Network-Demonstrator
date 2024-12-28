shader_type canvas_item;
render_mode blend_mix;


void fragment() {
	float uv_x = UV.x;
	
// Output:0
	COLOR = vec4(0.4,0.4,0.4,1.-(2.*abs(uv_x-0.5)));
	

}
