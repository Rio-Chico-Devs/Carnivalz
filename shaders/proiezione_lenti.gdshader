// LE FRATTURE NON SONO PIANETI (Proiezione.gd). Bru: «le fratture devono
// sembrare piu' distorsioni spazio tempo piu' che pianeti, solo i carnivalz
// sono pianeti». Ognuna e' una lente: prende quello che e' gia' disegnato
// dietro - la griglia, le stelle - e lo risucchia girandolo, con un anello di
// luce a meta' e un cuore scuro. Tutte le lenti in un passaggio solo, sopra
// la proiezione e sotto le scritte.
shader_type canvas_item;

uniform sampler2D schermo : hint_screen_texture, filter_linear_mipmap;
uniform vec4 lenti[12];     // centro e raggio (nei pixel della proiezione, 1280x720), forza del vortice
uniform vec4 lenti_b[12];   // spento, fase, -, -
uniform int n_lenti = 0;
uniform float scala = 1.0;  // pixel veri dello schermo per ogni pixel della proiezione
uniform vec3 carta : source_color = vec3(0.94, 0.85, 0.70);
uniform vec3 inchiostro : source_color = vec3(0.29, 0.48, 0.66);
uniform vec3 fondo : source_color = vec3(0.04, 0.05, 0.07);
uniform float tempo = 0.0;

mat2 giro(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat2(vec2(c, s), vec2(-s, c));
}

// le lenti si misurano sul rettangolo, non sulla finestra: a schermo intero,
// con le bande nere ai lati, i conti restano gli stessi
varying vec2 locale;

void vertex() {
	locale = VERTEX;
}

void fragment() {
	vec2 p = locale;
	vec2 uv = SCREEN_UV;
	vec2 sposta = vec2(0.0);
	float anello = 0.0;
	float buio = 0.0;
	float spire = 0.0;
	float spento = 0.0;
	for (int i = 0; i < n_lenti; i++) {
		float raggio = lenti[i].z;
		vec2 d = p - lenti[i].xy;
		float r = length(d) / max(raggio, 0.001);
		if (raggio < 1.0 || r >= 1.0) {
			continue;
		}
		// piu' vicino al centro, piu' giro e piu' risucchio: al bordo niente,
		// cosi' la lente non ha un contorno, si confonde con la griglia
		float k = 1.0 - r;
		float ang = lenti[i].w * 3.4 * k * k + tempo * 0.6 * k + lenti_b[i].y;
		vec2 tirato = giro(ang) * d * (1.0 - 0.6 * k * k);
		sposta += tirato - d;
		// l'anello non e' un contorno: un arco di luce spezzato che gira,
		// come la luce piegata intorno a una massa
		float th = atan(d.y, d.x);
		float arco = smoothstep(-0.2, 0.9, sin(th * 2.0 + lenti_b[i].y * 3.0 + tempo * 0.7))
				* (0.55 + 0.45 * sin(th * 7.0 - tempo * 1.3));
		anello = max(anello, exp(-pow((r - 0.36) / 0.03, 2.0)) * arco);
		buio = max(buio, exp(-pow(r / 0.2, 2.0)));
		spire = max(spire, smoothstep(0.92, 1.0, sin(th * 3.0 + ang * 1.5 + r * 16.0 - tempo * 2.0)) * k * 0.5
				* smoothstep(0.08, 0.4, r));
		spento = max(spento, lenti_b[i].x);
	}
	uv += sposta * scala * SCREEN_PIXEL_SIZE;
	// i colori si separano di un soffio dove lo spazio e' piegato di piu'
	vec2 sfasa = sposta * scala * SCREEN_PIXEL_SIZE * 0.035;
	vec3 col = vec3(texture(schermo, uv + sfasa).r, texture(schermo, uv).g, texture(schermo, uv - sfasa).b);
	col = mix(col, fondo, buio * 0.9);
	col = mix(col, inchiostro, spire * (1.0 - spento * 0.6));
	col = mix(col, mix(carta, inchiostro, spento * 0.7), clamp(anello, 0.0, 1.0) * (0.9 - spento * 0.4));
	COLOR = vec4(col, 1.0);
}
