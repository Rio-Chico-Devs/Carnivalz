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
// PROVVISORIO, le proposte per Bru («secondo te si puo' fare meglio? mandami
// degli esempi, sempre per uniformare»): 0 com'e' oggi, 1 retino, 2 curve di
// livello, 3 tavola tecnica, 4 rilievo (CieloProiezione.FORME_GRIGLIA)
uniform int stile = 0;
uniform float cella = 5.0;   // il retino dei pianeti, nei pixel veri
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

// il retino dei pianeti e dei gorghi: puntini grandi dove c'e' luce, sulla
// stessa griglia obliqua, fermi sullo schermo come sulla carta
float retino(vec2 px, float lum, float c) {
	vec2 q = px / c;
	q = vec2(q.x + q.y, q.y - q.x) * 0.7071;
	vec2 f = fract(q) - 0.5;
	float r = sqrt(clamp(lum, 0.0, 1.0)) * 0.62;
	return 1.0 - smoothstep(r - 0.08, r + 0.08, length(f));
}

// una crocetta su ogni incrocio della griglia, come i segni di una tavola tecnica
float croci(vec2 c, float braccio, float spessore) {
	vec2 f = abs(fract(c - 0.5) - 0.5);
	vec2 g = f / (fwidth(c) * spessore);
	float x = (1.0 - min(g.x, 1.0)) * step(f.y, braccio);
	float y = (1.0 - min(g.y, 1.0)) * step(f.x, braccio);
	return max(x, y);
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
	if (stile == 0) {
		col = mix(col, inchiostro, schizzi * 0.55);
		col = mix(col, inchiostro * (1.0 + vicino * 0.8), a * 0.9);
		col = mix(col, carta, a * vicino * 0.8);
	} else {
		// quanto e' profondo e quanto e' ripido, qui: lo si ricalcola per
		// frammento, cosi' le curve restano lisce anche dove la maglia e' larga
		float h = altezza(xz);
		vec2 grad = vec2(altezza(xz + vec2(0.03, 0.0)) - h, altezza(xz + vec2(0.0, 0.03)) - h) / 0.03;
		float ripido = clamp(length(grad) * 0.6, 0.0, 1.0);
		float in_buca = smoothstep(0.08, 0.5, -h);
		if (stile == 1) {
			// IL RETINO: le linee stampate a puntini come i pianeti, e le pareti
			// dei pozzi ombreggiate a retino, piu' fitto dove scendono di piu'
			float spessa = linee(c, 2.1);
			if (polare > 0.0 && n_pozzi > 0) {
				vec2 r = xz - pozzi[0].xy;
				float d = length(r);
				float peso = smoothstep(polare, polare * 0.7, d);
				float giri = max(linea(d / passo, 2.1), linea(atan(r.y, r.x) / 6.2831853 * 32.0, 2.1) * smoothstep(0.3, 1.5, d));
				spessa = mix(spessa, giri, peso);
			}
			float pareti = retino(FRAGCOORD.xy + vec2(1.7, 0.9), ripido * 0.45, cella);
			col = mix(col, inchiostro * 0.75, pareti);
			col = mix(col, mix(inchiostro, carta, vicino * 0.8), retino(FRAGCOORD.xy, spessa * 0.7, cella * 0.7));
		} else if (stile == 2) {
			// LE CURVE DI LIVELLO: fuori dai pozzi un quadrettato leggero con una
			// linea maestra ogni quattro; dentro, le linee di uguale profondita',
			// come le depressioni su una carta topografica. Una ogni quattro e' carta
			float piano = max(linee(c, 0.9) * 0.4, linee(c / 4.0, 1.5) * 0.85) * (1.0 - in_buca * 0.85);
			float fitte = linea(h / 0.3, 1.1) * smoothstep(0.03, 0.12, -h);
			float maestre = linea(h / 1.2, 1.8) * smoothstep(0.03, 0.12, -h);
			col = mix(col, inchiostro, max(piano, fitte * 0.9));
			col = mix(col, carta, maestre * 0.85);
			col = mix(col, carta, max(piano, fitte) * vicino * 0.7);
		} else if (stile == 3) {
			// LA TAVOLA TECNICA: sul piano solo crocette agli incroci (piu' grandi
			// e chiare ogni quattro); la linea intera compare solo dove lo spazio
			// si piega, cosi' la deformazione salta all'occhio
			float piccole = croci(c, 0.11, 1.0);
			float grandi = croci(c / 4.0, 0.07, 1.6);
			float piega = smoothstep(0.08, 0.45, ripido);
			float intere = a * piega;
			col = mix(col, inchiostro, max(piccole, intere) * 0.95);
			col = mix(col, carta, grandi * 0.75 + intere * piega * 0.35);
			col = mix(col, carta, max(piccole, intere) * vicino * 0.7);
		} else {
			// IL RILIEVO: la griglia di oggi, e i pozzi illuminati come i pianeti
			// (stessa luce, stesso retino): la parete che guarda la luce si stampa
			// in carta, quella in ombra si spegne e porta via anche le linee
			vec3 n = normalize(vec3(-grad.x, 1.0, -grad.y));
			vec3 l = normalize(vec3(-0.5, 0.7, 0.4));
			float lume = dot(n, l) - l.y;
			float chiaro = smoothstep(0.06, 0.4, lume);   // i pendii dolci restano scuri: solo le pareti
			float ombra = clamp(-lume * 2.6, 0.0, 1.0);
			col = mix(col, carta, retino(FRAGCOORD.xy, chiaro * 0.8, cella));
			col = mix(col, inchiostro * (1.0 + vicino * 0.8), a * 0.9 * (1.0 - ombra * 0.8));
			col = mix(col, carta, a * vicino * 0.8);
		}
	}
	ALBEDO = col;
	ALPHA = nebbia * acceso;
}
