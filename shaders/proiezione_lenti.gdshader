// LE FRATTURE SONO GORGHI (Proiezione.gd). Bru: «le fratture devono sembrare
// piu' distorsioni spazio tempo piu' che pianeti, solo i carnivalz sono
// pianeti»; poi, fra quattro proposte (strappo, crepa, varco, gorgo): «il gorgo
// e' il meglio la 4 per favore, approvata».
//
// Un gorgo giace sulla griglia, quindi in prospettiva e' un'ellisse: piu' lo
// guardi di lato, piu' si schiaccia. E' fatto di tre cose:
//   - un disco a RETINO, come i pianeti: puntini grandi dove c'e' luce, sulla
//     stessa griglia obliqua, fermi sullo schermo come sulla carta. I bracci
//     della spirale girano piano su se stessi (col movimento ridotto tempo e'
//     zero, e stanno fermi); verso la gola il bianco si scalda d'arancio
//   - un BUCO NERO al centro, col suo anello di luce
//   - la griglia dietro che SCIVOLA verso la gola
// Quanto e' viva lo dice "energia": una frattura nuova brucia, una gia' vista
// e' calma; quella che punti si accende. Una spenta e' grigia, una chiusa e'
// appena un'ombra (l'apertura). Tutte le lenti in un passaggio solo, sopra la
// proiezione e sotto le scritte.
shader_type canvas_item;

uniform sampler2D schermo : hint_screen_texture, filter_linear_mipmap;
uniform vec4 lenti[12];     // centro e raggio (nei pixel della proiezione, 1280x720), -
uniform vec4 lenti_b[12];   // spento, fase, energia, schiacciamento (1 = vista dall'alto)
uniform vec4 lenti_c[12];   // apertura (una chiusa e' poco piu' di un'ombra), -, -, -
uniform int n_lenti = 0;
uniform float scala = 1.0;  // pixel veri dello schermo per ogni pixel della proiezione
uniform vec3 carta : source_color = vec3(0.94, 0.85, 0.70);
uniform vec3 inchiostro : source_color = vec3(0.29, 0.48, 0.66);
uniform vec3 fondo : source_color = vec3(0.04, 0.05, 0.07);
uniform vec3 segnale : source_color = vec3(0.95, 0.60, 0.18);
uniform float tempo = 0.0;

// il retino dei pianeti (proiezione_retino): puntini grandi dove c'e' luce,
// sulla stessa griglia obliqua, fermi sullo schermo come sulla carta
float retino(vec2 px, float lum, float cella) {
	vec2 q = px / cella;
	q = vec2(q.x + q.y, q.y - q.x) * 0.7071;
	vec2 f = fract(q) - 0.5;
	float r = sqrt(clamp(lum, 0.0, 1.0)) * 0.62;
	return 1.0 - smoothstep(r - 0.08, r + 0.08, length(f));
}

// una tinta sopra le altre: vince la piu' coprente
void sovrapponi(inout vec4 sopra, vec3 tinta, float quanto) {
	float a = clamp(quanto, 0.0, 1.0);
	sopra.rgb = mix(sopra.rgb, tinta, a);
	sopra.a = max(sopra.a, a);
}

// le lenti si misurano sul rettangolo, non sulla finestra: a schermo intero,
// con le bande nere ai lati, i conti restano gli stessi
varying vec2 locale;

void vertex() {
	locale = VERTEX;
}

void fragment() {
	vec2 p = locale;
	vec2 sposta = vec2(0.0);
	vec4 sopra = vec4(0.0);
	float nero = 0.0;
	float cella = 4.0 * scala;
	for (int i = 0; i < n_lenti; i++) {
		float raggio = lenti[i].z;
		vec2 d = p - lenti[i].xy;
		if (raggio < 1.0 || length(d) >= raggio) {
			continue;
		}
		float spento = lenti_b[i].x;
		float fase = lenti_b[i].y;
		float energia = lenti_b[i].z;
		float schiaccia = max(lenti_b[i].w, 0.2);
		float apre = lenti_c[i].x;
		vec2 e = vec2(d.x, d.y / schiaccia);
		float r = length(e) / raggio;
		if (r >= 1.0) {
			continue;
		}
		vec3 luce = mix(carta, inchiostro, spento * 0.7);
		vec3 calda = mix(segnale, inchiostro, spento);
		float th = atan(e.y, e.x);
		float k = 1.0 - r;
		// la griglia scivola verso la gola: al bordo niente, cosi' il gorgo non
		// ha un contorno, si confonde con la griglia
		sposta += -d * 0.45 * k * k * k;
		// i bracci: una spirale che si stringe verso il buco, e gira piano
		float braccio = 0.5 + 0.5 * sin(th * 3.0 + log(max(r, 0.05)) * 5.0 + fase * 3.0
				- tempo * (0.25 + 0.35 * energia));
		float densita = smoothstep(1.0, 0.25, r) * (0.25 + 0.75 * braccio) * (0.5 + 0.5 * energia);
		float punti = retino(FRAGCOORD.xy, densita, cella * 0.9);
		vec3 tinta = mix(luce, calda, smoothstep(0.6, 0.25, r));
		sovrapponi(sopra, tinta, punti * smoothstep(0.17, 0.22, r) * apre);
		// il buco nero, e l'anello di luce sul suo orlo
		nero = max(nero, smoothstep(0.2, 0.15, r) * apre);
		sovrapponi(sopra, luce, exp(-pow((r - 0.2) / 0.015, 2.0)) * apre);
	}
	vec2 uv = SCREEN_UV + sposta * scala * SCREEN_PIXEL_SIZE;
	// i colori si separano di un soffio dove lo spazio e' piegato di piu'
	vec2 sfasa = sposta * scala * SCREEN_PIXEL_SIZE * 0.035;
	vec3 col = vec3(texture(schermo, uv + sfasa).r, texture(schermo, uv).g, texture(schermo, uv - sfasa).b);
	col = mix(col, fondo, nero * 0.95);
	col = mix(col, sopra.rgb, clamp(sopra.a, 0.0, 1.0));
	COLOR = vec4(col, 1.0);
}
