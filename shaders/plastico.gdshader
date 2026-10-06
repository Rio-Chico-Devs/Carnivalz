// IL PLASTICO DELLA MAPPA DI ZONA (PlasticoZona.gd): volumi di luce, non
// solidi. Si sommano a quello che c'e' dietro, come un ologramma, quindi non
// importa in che ordine si disegnano e dove due stanze si coprono si vede
// tutte e due. Il bordo di una faccia vista di taglio e' piu' acceso: e' quello
// che fa leggere un volume senza bisogno di luci.
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 tinta : source_color = vec4(0.25, 0.84, 0.9, 0.3);
uniform float pulsa = 0.0;     // la stanza in cui sei respira
uniform float acceso = 0.0;    // quella che punti si accende
uniform float taglio = 1.0;    // 0 per le linee: non hanno facce

void fragment() {
	float bordo = mix(1.0, 0.6 + 0.8 * (1.0 - abs(dot(NORMAL, VIEW))), taglio);
	float respiro = 1.0 + pulsa * 0.45 * sin(TIME * 3.4);
	ALBEDO = mix(tinta.rgb, vec3(1.0), acceso * 0.25);
	ALPHA = clamp(tinta.a * bordo * respiro + acceso * mix(0.5, 0.3, taglio), 0.0, 1.0);
}
