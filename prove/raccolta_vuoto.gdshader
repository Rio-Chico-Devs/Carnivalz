// IL CIELO DIETRO IL PIANETA (prove/RaccoltaProva.gd): il buio del Vuoto, una
// nebulosa lenta in due colori, le stelle che respirano. Scorre piu' piano
// della camera, cosi' sembra lontano. Provvisorio.
shader_type canvas_item;
#include "res://prove/raccolta_rumore.gdshaderinc"

uniform vec4 fondo : source_color = vec4(0.043, 0.055, 0.078, 1.0);
uniform vec4 nebbia_fredda : source_color = vec4(0.13, 0.21, 0.36, 1.0);
uniform vec4 nebbia_calda : source_color = vec4(0.32, 0.15, 0.22, 1.0);
uniform vec4 stella : source_color = vec4(0.94, 0.85, 0.70, 1.0);
uniform vec2 scorre = vec2(0.0);
uniform float tempo = 0.0;

void fragment() {
	vec2 p = FRAGCOORD.xy + scorre * 0.12;
	float n = ottave(p / 420.0);
	float m = ottave(p / 260.0 + 31.0);
	vec3 c = fondo.rgb;
	c = mix(c, nebbia_fredda.rgb, smoothstep(0.45, 0.85, n) * 0.55);
	c = mix(c, nebbia_calda.rgb, smoothstep(0.55, 0.9, m) * 0.4);
	// le stelle: una cella su tante, e respira
	vec2 cella = floor(p / 6.0);
	float s = caso(cella);
	if (s > 0.992) {
		vec2 dentro = fract(p / 6.0) - 0.5;
		float lume = 0.55 + 0.45 * sin(tempo * (1.0 + 3.0 * caso(cella + 7.0)) + s * 40.0);
		c = mix(c, stella.rgb, (1.0 - smoothstep(0.1, 0.35, length(dentro))) * lume);
	}
	COLOR = vec4(c, 1.0);
}
