// L'ANELLO DEL CARNIVALZ (Proiezione.gd): un disco bucato, a strisce.
shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform vec3 inchiostro : source_color = vec3(0.29, 0.48, 0.66);
uniform vec3 carta : source_color = vec3(0.94, 0.85, 0.70);
uniform float dentro = 0.62;

void fragment() {
	vec2 c = UV * 2.0 - 1.0;
	float d = length(c);
	if (d > 1.0 || d < dentro) {
		discard;
	}
	float t = (d - dentro) / (1.0 - dentro);
	float strisce = step(0.5, fract(t * 7.0 + sin(t * 23.0) * 0.2));
	ALBEDO = mix(inchiostro, carta, strisce * 0.8);
	ALPHA = 0.85 * smoothstep(0.0, 0.05, t) * smoothstep(1.0, 0.95, t);
}
