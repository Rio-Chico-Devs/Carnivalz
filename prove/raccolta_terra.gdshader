// LA TERRA DI UN CAMPO (prove/RaccoltaProva.gd). Una campitura quasi carta,
// macchie larghe, la luce dall'alto a sinistra: l'orlo dalla parte della luce
// resta chiaro, il lato in ombra scurisce, e la stampa ne fa retino. Provvisorio.
shader_type canvas_item;
#include "res://prove/raccolta_rumore.gdshaderinc"

uniform vec4 terra : source_color = vec4(0.92, 0.80, 0.62, 1.0);
uniform vec4 chiara : source_color = vec4(0.94, 0.85, 0.70, 1.0);
uniform vec4 scura : source_color = vec4(0.80, 0.58, 0.36, 1.0);
uniform vec4 curve : source_color = vec4(0.188, 0.369, 0.471, 1.0);
uniform vec2 centro = vec2(0.0);
uniform vec2 raggi = vec2(300.0, 200.0);
uniform float seme = 0.0;

varying vec2 mondo;

void vertex() {
	mondo = VERTEX;
}

void fragment() {
	// piatta come una campitura: il retino lo mette la stampa (raccolta_stampa).
	// Qui solo dove la terra prende luce e dove no, e qualche macchia larga
	float l = dentro_al_campo(mondo, centro, raggi, seme);
	vec2 q = (mondo - centro) / raggi;
	vec2 verso = length(q) > 0.001 ? normalize(q) : vec2(0.0);
	float macchie = ottave(mondo / 300.0);
	vec3 c = mix(chiara.rgb, terra.rgb, smoothstep(0.42, 0.7, macchie));
	float ombra = smoothstep(0.35, 1.0, l) * clamp(dot(verso, normalize(vec2(0.55, 0.85))), 0.0, 1.0);
	c = mix(c, scura.rgb, ombra * 0.9);
	float luce = clamp(dot(verso, normalize(vec2(-0.55, -0.85))), 0.0, 1.0);
	c = mix(c, chiara.rgb, smoothstep(0.8, 0.98, l) * luce);
	// le curve di livello, come su una carta: righe blu sottili, sempre dello
	// stesso spessore, che si spengono verso l'orlo
	vec2 m = mondo + vec2(seme * 97.0, seme * 53.0);
	float quota = (morbido(m / 520.0) * 0.6 + morbido(m / 260.0) * 0.3 + morbido(m / 130.0) * 0.1) * 13.0;
	float riga = abs(fract(quota + 0.5) - 0.5) / max(fwidth(quota), 0.0001);
	float curva = (1.0 - smoothstep(0.4, 1.2, riga)) * (1.0 - smoothstep(0.7, 0.95, l));
	c = mix(c, curve.rgb, curva * 0.75);
	COLOR = vec4(c, 1.0);
}
