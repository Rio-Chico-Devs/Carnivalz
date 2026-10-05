// LA NEBULOSA DEL SETTORE (Proiezione.gd): una fascia di polvere a puntini,
// come quella del poster ciano. Sta dietro la griglia, sopra l'orizzonte.
shader_type canvas_item;

uniform sampler2D rumore : repeat_enable, filter_linear;
uniform vec4 tinta : source_color = vec4(0.29, 0.48, 0.66, 1.0);
uniform vec2 celle = vec2(800.0, 310.0);

float caso(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float asse = 0.62 - 0.32 * UV.x;
	float fascia = exp(-pow((UV.y - asse) / 0.2, 2.0));
	float v = texture(rumore, UV * vec2(1.6, 0.62)).r * fascia;
	vec2 cella = floor(UV * celle);
	float a = smoothstep(0.3, 0.52, v + (caso(cella) - 0.5) * 0.28);
	COLOR = vec4(tinta.rgb, tinta.a * a * 0.38);
}
