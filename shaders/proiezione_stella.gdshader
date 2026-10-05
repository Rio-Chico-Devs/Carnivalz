// LE STELLE (CieloProiezione.gd): quadratini sempre rivolti alla camera, tondi,
// che respirano ognuno col suo passo. "brilla" a zero le ferma.
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

uniform vec3 carta : source_color = vec3(0.94, 0.85, 0.70);
uniform float brilla = 1.0;

void vertex() {
	float s = length(MODEL_MATRIX[0].xyz);
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0] * s, INV_VIEW_MATRIX[1] * s, INV_VIEW_MATRIX[2] * s, MODEL_MATRIX[3]);
	float respiro = 0.6 + 0.4 * sin(TIME * (1.0 + mod(float(INSTANCE_ID), 3.0)) + float(INSTANCE_ID) * 1.7);
	COLOR.a *= mix(1.0, respiro, brilla);
}

void fragment() {
	float d = length(UV * 2.0 - 1.0);
	float a = smoothstep(1.0, 0.15, d) * COLOR.a;
	ALBEDO = carta * a;
}
