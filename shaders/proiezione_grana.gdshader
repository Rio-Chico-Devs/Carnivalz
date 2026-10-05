// LA GRANA DELLA SERIGRAFIA (Proiezione.gd): puntini sparsi che saltano a
// scatti ("scatto" cambia otto volte al secondo; fermo col movimento ridotto).
shader_type canvas_item;

uniform vec4 tinta : source_color = vec4(1.0);
uniform float quanta = 0.01;
uniform float scatto = 0.0;
uniform vec2 celle = vec2(640.0, 360.0);

float caso(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 cella = floor(UV * celle);
	float r = caso(cella + vec2(scatto * 17.0, scatto * 31.0));
	float a = step(1.0 - quanta, r) * mix(0.35, 0.7, caso(cella.yx + vec2(scatto)));
	COLOR = vec4(tinta.rgb, tinta.a * a);
}
