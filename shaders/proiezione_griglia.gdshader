// LA GRIGLIA DELLA PROIEZIONE (Proiezione.gd): un piano piegato dai pozzi.
// Ogni pozzo e' (x, z, profondita, larghezza): un Carnivalz, una frattura, una
// stella lontana. Le linee si disegnano qui, per frammento, nelle coordinate
// del piano: cosi' restano dritte sul piano e si curvano dentro i pozzi, come
// nel poster di Interstellar che Bru ha mandato.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

uniform vec4 pozzi[16];
uniform int n_pozzi = 0;
uniform float esponente = 1.0;
uniform vec3 fondo : source_color = vec3(0.04, 0.05, 0.07);
uniform vec3 inchiostro : source_color = vec3(0.29, 0.48, 0.66);
uniform vec3 carta : source_color = vec3(0.94, 0.85, 0.70);
uniform float passo = 1.0;
uniform vec2 luce_pos = vec2(0.0);
uniform float luce = 0.0;
uniform vec2 onda_centro = vec2(0.0);
uniform float onda = -1.0;
uniform float accensione = 999.0;
uniform float polare = 0.0;
uniform float nebbia_da = 8.0;
uniform float nebbia_a = 40.0;
uniform sampler2D rumore : repeat_enable, filter_linear;
varying vec2 xz;
varying float prof;
varying float vicino_pozzo;

float altezza(vec2 p) {
	float h = 0.0;
	for (int i = 0; i < n_pozzi; i++) {
		vec4 w = pozzi[i];
		float d = length(p - w.xy);
		h -= w.z * pow(w.w / sqrt(d * d + w.w * w.w), esponente);
	}
	return h;
}

void vertex() {
	vec2 p = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	float h = altezza(p);
	VERTEX.y += h;
	xz = p;
	prof = h;
	float v = 0.0;
	for (int i = 0; i < n_pozzi; i++) {
		vec4 w = pozzi[i];
		float d = length(p - w.xy);
		v = max(v, exp(-pow(d / (w.w * 3.2), 2.0)) * clamp(w.z / 2.0, 0.0, 1.0));
	}
	vicino_pozzo = v;
}

float linee(vec2 c, float spessore) {
	vec2 g = abs(fract(c - 0.5) - 0.5) / (fwidth(c) * spessore);
	return 1.0 - min(min(g.x, g.y), 1.0);
}

float linea(float c, float spessore) {
	float g = abs(fract(c - 0.5) - 0.5) / (fwidth(c) * spessore);
	return 1.0 - min(g, 1.0);
}

void fragment() {
	vec2 c = xz / passo;
	float cartesiana = max(linee(c, 1.0), linee(c * 4.0, 0.7) * 0.22);
	// intorno al primo pozzo (il Carnivalz) la griglia si fa polare: anelli e raggi
	float a = cartesiana;
	if (polare > 0.0 && n_pozzi > 0) {
		vec2 r = xz - pozzi[0].xy;
		float d = length(r);
		float peso = smoothstep(polare, polare * 0.7, d);
		float anelli = linea(d / passo, 1.0);
		float raggi = linea(atan(r.y, r.x) / 6.2831853 * 32.0, 1.0) * smoothstep(0.3, 1.5, d);
		a = mix(cartesiana, max(anelli, raggi), peso);
	}
	float distanza = length(VERTEX);
	float nebbia = clamp(1.0 - (distanza - nebbia_da) / (nebbia_a - nebbia_da), 0.0, 1.0);
	float vicino = exp(-pow(length(xz - luce_pos) / 2.2, 2.0)) * luce;
	float anello = 0.0;
	if (onda >= 0.0) {
		float dietro = length(xz - onda_centro) - onda;
		anello = exp(-pow(dietro / 0.1, 2.0)) + exp(-pow(dietro / 2.5, 2.0)) * step(dietro, 0.0) * 0.08;
	}
	// gli schizzi della serigrafia, dove la griglia sprofonda
	float n = texture(rumore, xz * 0.16).r;
	float n2 = texture(rumore, xz * 0.6 + vec2(0.37, 0.11)).r;
	float schizzi = smoothstep(0.6, 0.63, n) * vicino_pozzo + smoothstep(0.7, 0.72, n2) * vicino_pozzo * 0.6;
	float acceso = smoothstep(accensione, accensione - 1.5, length(xz - onda_centro));
	vec3 col = fondo;
	col = mix(col, inchiostro, schizzi * 0.55);
	col = mix(col, inchiostro * (1.0 + vicino * 0.8), a * 0.9);
	col = mix(col, carta, a * vicino * 0.8);
	col = mix(col, carta, clamp(anello, 0.0, 1.0) * 0.6 * clamp(1.0 - onda / 60.0, 0.0, 1.0));
	ALBEDO = col;
	ALPHA = nebbia * acceso;
}
