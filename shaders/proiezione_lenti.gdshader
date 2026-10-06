// LE FRATTURE NON SONO PIANETI (Proiezione.gd). Bru: «le fratture devono
// sembrare piu' distorsioni spazio tempo piu' che pianeti, solo i carnivalz
// sono pianeti»; e poi: «miglioriamo anche la grafica delle fratture».
//
// Ognuna e' fatta di due cose:
//   - un VORTICE che giace sulla griglia: prende quello che e' gia' disegnato
//     dietro e lo risucchia girandolo, con un arco di luce spezzato, un cuore
//     scuro e dei detriti che spiraleggiano dentro. Sta sul piano, quindi in
//     prospettiva e' un'ellisse: piu' guardi di lato, piu' si schiaccia
//   - uno SQUARCIO che si alza in piedi dalla gola: un taglio dai bordi
//     strappati, e dentro, al posto del nero, un altro mondo che si muove
// Quanto e' viva lo dice "energia": una frattura nuova brucia, una gia' vista
// e' calma, una chiusa e' solo una cicatrice, una spenta e' grigia; quella che
// punti si accende. Tutte le lenti in un passaggio solo, sopra la proiezione e
// sotto le scritte.
shader_type canvas_item;

uniform sampler2D schermo : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D rumore : repeat_enable, filter_linear;
uniform vec4 lenti[12];     // centro e raggio (nei pixel della proiezione, 1280x720), forza del vortice
uniform vec4 lenti_b[12];   // spento, fase, energia, schiacciamento (1 = vista dall'alto)
uniform vec4 lenti_c[12];   // apertura dello squarcio, inclinazione, -, -
uniform int n_lenti = 0;
uniform float scala = 1.0;  // pixel veri dello schermo per ogni pixel della proiezione
uniform vec3 carta : source_color = vec3(0.94, 0.85, 0.70);
uniform vec3 inchiostro : source_color = vec3(0.29, 0.48, 0.66);
uniform vec3 fondo : source_color = vec3(0.04, 0.05, 0.07);
uniform vec3 segnale : source_color = vec3(0.95, 0.60, 0.18);
uniform float tempo = 0.0;

mat2 giro(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat2(vec2(c, s), vec2(-s, c));
}

float caso(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
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
	float anello = 0.0;
	float buio = 0.0;
	float spire = 0.0;
	float detriti = 0.0;
	float alone = 0.0;
	float bordo = 0.0;
	float dentro = 0.0;
	float spento = 0.0;
	vec3 mondo = vec3(0.0);
	for (int i = 0; i < n_lenti; i++) {
		float raggio = lenti[i].z;
		vec2 d = p - lenti[i].xy;
		if (raggio < 1.0 || length(d) >= raggio) {
			continue;
		}
		float fase = lenti_b[i].y;
		float energia = lenti_b[i].z;
		float schiaccia = max(lenti_b[i].w, 0.2);
		// IL VORTICE, sul piano: in prospettiva un cerchio e' un'ellisse
		vec2 e = vec2(d.x, d.y / schiaccia);
		float r = length(e) / raggio;
		if (r < 1.0) {
			// piu' vicino al centro, piu' giro e piu' risucchio: al bordo niente,
			// cosi' il vortice non ha un contorno, si confonde con la griglia
			float k = 1.0 - r;
			float ang = lenti[i].w * 3.4 * k * k + tempo * (0.3 + 0.6 * energia) * k + fase;
			vec2 tirato = giro(ang) * e * (1.0 - 0.6 * k * k);
			sposta += vec2(tirato.x, tirato.y * schiaccia) - d;
			float th = atan(e.y, e.x);
			// l'anello non e' un contorno: un arco di luce spezzato che gira,
			// come la luce piegata intorno a una massa
			float arco = smoothstep(-0.2, 0.9, sin(th * 2.0 + fase * 3.0 + tempo * 0.7))
					* (0.55 + 0.45 * sin(th * 7.0 - tempo * 1.3));
			anello = max(anello, exp(-pow((r - 0.36) / 0.03, 2.0)) * arco * (0.55 + 0.6 * energia));
			buio = max(buio, exp(-pow(r / 0.2, 2.0)));
			spire = max(spire, smoothstep(0.92, 1.0, sin(th * 3.0 + ang * 1.5 + r * 16.0 - tempo * 2.0)) * k * 0.5
					* smoothstep(0.08, 0.4, r));
			// i detriti: briciole di griglia che girano e cadono verso la gola
			vec2 q = vec2(th / 6.2831853 * 18.0 + ang * 2.0, log(max(r, 0.04)) * 5.0 + tempo * (0.8 + 1.2 * energia));
			vec2 cella = floor(q);
			vec2 f = fract(q) - 0.5 - (vec2(caso(cella), caso(cella + 7.1)) - 0.5) * 0.5;
			float acceso = step(0.78 - 0.18 * energia, caso(cella + fase));
			detriti = max(detriti, acceso * smoothstep(0.16, 0.0, length(f)) * smoothstep(0.08, 0.3, r) * k * 1.4);
		}
		// LO SQUARCIO, in piedi sulla gola: un taglio coi bordi strappati
		// sta in piedi: guardandolo dall'alto si accorcia, come qualunque cosa ritta
		vec2 s = giro(lenti_c[i].y) * d;
		float alto = raggio * 0.5 * mix(1.0, 0.4, schiaccia * schiaccia);
		float lungo = s.y / alto;
		if (abs(lungo) < 1.0) {
			float apre = lenti_c[i].x;
			float strappo = texture(rumore, vec2(lungo * 0.45 + fase, fase * 0.37)).r - 0.5;
			float largo = raggio * 0.13 * apre * pow(1.0 - lungo * lungo, 0.8) * (1.0 + strappo * 1.1);
			float fuori = abs(s.x) - largo;
			float punta = pow(1.0 - lungo * lungo, 0.5);
			float qui = smoothstep(0.7, -0.7, fuori) * step(0.02, apre);
			if (qui > dentro) {
				// dentro, un altro mondo: nebbia lenta che sale, e una luce che filtra dal fondo
				vec2 w = s / raggio;
				float n1 = texture(rumore, w * 0.22 + vec2(fase, -tempo * 0.02)).r;
				float n2 = texture(rumore, w * 0.5 + vec2(tempo * 0.015, fase * 2.0)).r;
				float nebbia = smoothstep(0.35, 0.8, n1 * 0.7 + n2 * 0.4);
				float luce = exp(-pow(s.x / max(largo, 0.5), 2.0) * 2.5) * punta;
				mondo = mix(fondo * 0.5 + inchiostro * 0.35, inchiostro * 1.1, nebbia);
				mondo = mix(mondo, mix(carta, segnale, 0.3 * energia), luce * (0.35 + 0.45 * energia));
				dentro = qui;
			}
			bordo = max(bordo, exp(-pow(fuori / 1.0, 2.0)) * punta * (0.55 + 0.35 * energia) * step(0.02, apre));
			alone = max(alone, exp(-pow(max(fuori, 0.0) / (raggio * 0.1), 2.0)) * punta * (0.15 + 0.45 * energia)
					* step(0.02, apre));
		}
		spento = max(spento, lenti_b[i].x);
	}
	vec2 uv = SCREEN_UV + sposta * scala * SCREEN_PIXEL_SIZE;
	// i colori si separano di un soffio dove lo spazio e' piegato di piu'
	vec2 sfasa = sposta * scala * SCREEN_PIXEL_SIZE * 0.035;
	vec3 col = vec3(texture(schermo, uv + sfasa).r, texture(schermo, uv).g, texture(schermo, uv - sfasa).b);
	col = mix(col, fondo, buio * 0.9);
	col = mix(col, inchiostro, spire * (1.0 - spento * 0.6));
	col += carta * detriti * (1.0 - spento * 0.7);
	col = mix(col, mix(carta, inchiostro, spento * 0.7), clamp(anello, 0.0, 1.0) * (0.9 - spento * 0.4));
	col = mix(col, mix(carta, inchiostro, spento), clamp(alone, 0.0, 1.0) * 0.35);
	vec3 visto = mix(mondo, vec3(dot(mondo, vec3(0.33))) * inchiostro * 1.6, spento);
	col = mix(col, visto, dentro);
	col = mix(col, mix(carta, inchiostro, spento * 0.6), clamp(bordo, 0.0, 1.0));
	COLOR = vec4(col, 1.0);
}
