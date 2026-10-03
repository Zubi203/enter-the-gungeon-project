shader_type canvas_item;

uniform float angle = 0.0;
uniform float thickness = 0.01;
uniform vec2 center = vec2(1.0);

void fragment() {
	vec2 uv = 2.0 * UV - center;
	
	float slope = tan(angle);
	float line = uv.y - slope * uv.x;
	float distance_to_line = abs(line) / sqrt(1.0 + slope * slope);
	float shine_mask = step(distance_to_line, thickness);
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), vec3(shine_mask));
}
