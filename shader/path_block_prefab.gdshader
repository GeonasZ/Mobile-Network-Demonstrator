shader_type canvas_item;
render_mode blend_mix;


void fragment() {
	vec2 uv = UV;
// Output:0
if (COLOR.r > 1.) COLOR.r = 1.;
if (COLOR.g > 1.) COLOR.g = 1.;
if (COLOR.b > 1.) COLOR.b = 1.;
COLOR.a = 0.8;
}
