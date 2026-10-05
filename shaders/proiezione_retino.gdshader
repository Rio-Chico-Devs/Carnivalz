// UN PIANETA A RETINO (Proiezione.gd): puntini di stampa grandi dove arriva
// la luce e piccoli dove non arriva, fermi sullo schermo come sulla carta.
// "bande" lo fa infuocato (il Carnivalz), "spento" lo stampa in inchiostro.
shader_type spatial;
render_mode unshaded;

uniform vec3 fondo : source_color = vec3(0.04, 0.05, 0.07);
uniform vec3 inchiostro : source_color = vec3(0.29, 0.48, 0.66);
uniform vec3 carta : source_color = vec3(0.94, 0.85, 0.70);
uniform vec3 luce_dir = vec3(-0.5, 0.7, 0.4);
uniform float cella = 5.0;
uniform float giro = 0.0;
uniform float bande = 0.0;
uniform float bordo = 1.0;
uniform float spento = 0.0;
varying vec3 locale;

void vertex() {
	locale = VERTEX;
}

void fragment() {
	vec3 n = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float lam = clamp(dot(n, normalize(luce_dir)) * 0.85 + 0.15, 0.0, 1.0);
	vec3 p = normalize(locale);
	float ang = atan(p.z, p.x) + giro;
	float b = sin(p.y * 9.0 + sin(ang * 3.0) * 0.8) * 0.5 + 0.5;
	lam *= mix(1.0, 0.55 + 0.6 * b, bande);
	vec2 q = FRAGCOORD.xy / cella;
	q = vec2(q.x + q.y, q.y - q.x) * 0.7071;
	vec2 f = fract(q) - 0.5;
	float r = sqrt(lam) * 0.62;
	float punto = 1.0 - smoothstep(r - 0.06, r + 0.06, length(f));
	float orlo = pow(1.0 - abs(dot(NORMAL, VIEW)), 5.0) * bordo;
	vec3 tinta = mix(carta, inchiostro, spento);
	vec3 col = mix(fondo, tinta, punto);
	col = mix(col, inchiostro, clamp(orlo * 1.4, 0.0, 1.0));
	ALBEDO = col;
}
