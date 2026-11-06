// LA TERRA DI UN CAMPO (prove/RaccoltaProva.gd). Macchie larghe e grana fine,
// la luce dall'alto a sinistra: l'orlo dalla parte della luce si accende, il
// lato in ombra si copre di retino come le ombre del manifesto. Provvisorio.
shader_type canvas_item;
#include "res://prove/raccolta_rumore.gdshaderinc"

uniform vec4 terra : source_color = vec4(0.90, 0.79, 0.58, 1.0);
uniform vec4 chiara : source_color = vec4(0.96, 0.89, 0.74, 1.0);
uniform vec4 scura : source_color = vec4(0.74, 0.58, 0.36, 1.0);
uniform vec2 centro = vec2(0.0);
uniform vec2 raggi = vec2(300.0, 200.0);
uniform float seme = 0.0;

varying vec2 mondo;

void vertex() {
	mondo = VERTEX;
}

void fragment() {
	float l = dentro_al_campo(mondo, centro, raggi, seme);
	vec2 q = (mondo - centro) / raggi;
	vec2 verso = length(q) > 0.001 ? normalize(q) : vec2(0.0);
	float macchie = ottave(mondo / 240.0);
	float minute = ottave(mondo / 34.0 + 5.0);
	vec3 c = mix(terra.rgb, chiara.rgb, smoothstep(0.5, 0.78, macchie) * 0.75);
	c = mix(c, scura.rgb, smoothstep(0.58, 0.85, minute) * 0.3);
	c *= 0.965 + 0.035 * caso(floor(mondo / 2.0));
	// il retino dell'ombra: puntini che crescono verso il bordo lontano dalla luce
	float ombra = smoothstep(0.5, 1.0, l) * clamp(dot(verso, normalize(vec2(0.55, 0.85))), 0.0, 1.0);
	vec2 cella = fract(mondo / 8.0) - 0.5;
	float r = 0.46 * ombra;
	float punto = 1.0 - smoothstep(r - 0.07, r + 0.04, length(cella));
	c = mix(c, scura.rgb * 0.82, punto * 0.6);
	// l'orlo dalla parte della luce
	float luce = clamp(dot(verso, normalize(vec2(-0.55, -0.85))), 0.0, 1.0);
	c = mix(c, chiara.rgb * 1.04, smoothstep(0.88, 0.985, l) * luce * 0.8);
	COLOR = vec4(c, 1.0);
}
