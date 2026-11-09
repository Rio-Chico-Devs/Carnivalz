// LA NEBBIA SU QUELLO CHE NON SAI (prove/RaccoltaProva.gd): nuvole lente fra
// il buio e il blu, i bordi morbidi intorno al campo. Quando un
// passaggio si apre si ritira da li', col bordo strappato e acceso. Provvisorio.
shader_type canvas_item;
#include "res://prove/raccolta_rumore.gdshaderinc"

uniform vec4 buio : source_color = vec4(0.07, 0.09, 0.15, 1.0);
uniform vec4 linea : source_color = vec4(0.29, 0.48, 0.66, 1.0);
uniform vec4 acceso : source_color = vec4(0.95, 0.60, 0.18, 1.0);
uniform vec2 centro = vec2(0.0);
uniform vec2 raggi = vec2(300.0, 200.0);
uniform float seme = 0.0;
uniform vec2 da = vec2(0.0);
uniform float raggio = 0.0;
uniform float tempo = 0.0;

varying vec2 mondo;

void vertex() {
	mondo = VERTEX;
}

void fragment() {
	float l = dentro_al_campo(mondo, centro, raggi, seme);
	float nuvola = ottave(mondo / 170.0 + vec2(tempo * 0.04, tempo * 0.025));
	float alfa = 1.0 - smoothstep(1.06, 1.3, l + (nuvola - 0.5) * 0.25);
	// dove si e' aperto: il cerchio che cresce, col bordo strappato dalle nuvole
	float bordo = 1.0;
	float scintilla = 0.0;
	if (raggio > 0.0) {
		float d = length(mondo - da) - raggio + (nuvola - 0.5) * 160.0;
		bordo = smoothstep(0.0, 30.0, d);
		scintilla = (1.0 - smoothstep(0.0, 46.0, d)) * smoothstep(-8.0, 0.0, d);
	}
	// le nuvole: dal buio al blu. Il retino lo mette la stampa
	vec3 c = mix(buio.rgb, linea.rgb, smoothstep(0.4, 0.85, nuvola) * 0.8);
	c = mix(c, acceso.rgb, scintilla * 0.9);
	COLOR = vec4(c, alfa * max(bordo, scintilla) * 0.97);
}
