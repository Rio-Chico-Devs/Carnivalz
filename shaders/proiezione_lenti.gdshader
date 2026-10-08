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
// LE PROPOSTE NUOVE (Bru: «non mi piace come si vedono»): 0 com'era, 1 lo
// strappo, 2 la crepa, 3 il varco, 4 il gorgo a retino (Proiezione.STILI_FRATTURA)
uniform int stile = 0;

mat2 giro(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat2(vec2(c, s), vec2(-s, c));
}

float caso(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

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
	float anello = 0.0;
	float buio = 0.0;
	float spire = 0.0;
	float detriti = 0.0;
	float alone = 0.0;
	float bordo = 0.0;
	float dentro = 0.0;
	float spento = 0.0;
	vec3 mondo = vec3(0.0);
	vec4 sopra = vec4(0.0);
	float nero = 0.0;
	float cella = 4.0 * scala;
	for (int i = 0; i < n_lenti; i++) {
		float raggio = lenti[i].z;
		vec2 d = p - lenti[i].xy;
		if (raggio < 1.0 || length(d) >= raggio) {
			continue;
		}
		if (stile != 0) {
			float fase_n = lenti_b[i].y;
			float en = lenti_b[i].z;
			float sch = max(lenti_b[i].w, 0.2);
			float sp = lenti_b[i].x;
			float apre_n = lenti_c[i].x;
			vec3 luce = mix(carta, inchiostro, sp * 0.7);
			vec3 calda = mix(segnale, inchiostro, sp);
			vec2 e = vec2(d.x, d.y / sch);
			float r = length(e) / raggio;
			float th = atan(e.y, e.x);
			vec2 s = giro(lenti_c[i].y) * d;
			float aperta = step(0.02, apre_n);
			if (stile == 1) {
				// LO STRAPPO: un taglio alto in piedi sulla griglia, coi bordi di
				// carta strappata, e dentro un altro mondo stampato a retino
				if (r < 1.0) {
					float k = 1.0 - r;
					vec2 tira = -e * 0.35 * k * k;
					sposta += vec2(tira.x, tira.y * sch);
				}
				float alto_n = raggio * 0.9 * mix(1.0, 0.6, sch * sch);
				float l = s.y / alto_n;
				if (abs(l) < 1.0) {
					float n1 = texture(rumore, vec2(l * 0.8 + fase_n, fase_n * 0.3)).r - 0.5;
					float n2 = texture(rumore, vec2(l * 3.1 - fase_n, 0.7)).r - 0.5;
					float largo_n = raggio * 0.17 * apre_n * pow(1.0 - l * l, 0.75) * (1.0 + n1 * 1.3);
					float fuori_n = abs(s.x) - largo_n;
					float fibra = raggio * 0.03 * (1.0 + n2 * 2.5);
					float orlo_n = smoothstep(fibra + 0.8, fibra - 0.8, fuori_n) * smoothstep(-1.0, 0.5, fuori_n);
					float dentro_n = smoothstep(0.8, -0.8, fuori_n);
					// dentro e' buio, e dal fondo sale una luce: piu' forte al centro del
					// taglio, a retino come tutto quello che e' stampato
					float cuore = exp(-pow(s.x / max(largo_n, 0.5), 2.0) * 3.0) * pow(1.0 - l * l, 0.8);
					float pt = retino(FRAGCOORD.xy, cuore * (0.35 + 0.5 * en), cella * 0.8);
					vec3 interno = mix(fondo * 0.6, mix(calda, luce, 0.35), pt);
					float cucitura = exp(-pow(s.x / max(largo_n * 0.18, 0.6), 2.0)) * pow(1.0 - l * l, 1.2) * (0.5 + 0.5 * en);
					interno = mix(interno, luce, cucitura * dentro_n);
					float alone_n = exp(-pow(max(fuori_n, 0.0) / (raggio * 0.1), 2.0)) * pow(1.0 - l * l, 0.5)
							* (0.2 + 0.4 * en);
					sovrapponi(sopra, luce, retino(FRAGCOORD.xy, alone_n, cella) * alone_n * aperta * (1.0 - dentro_n));
					sovrapponi(sopra, interno, dentro_n * aperta);
					sovrapponi(sopra, luce, orlo_n * aperta);
				}
			} else if (stile == 2) {
				// LA CREPA: lo spazio si incrina come un vetro, sul piano della
				// griglia. Sei crepe frastagliate partono dal buco, ognuna col suo
				// ramo; fra una crepa e l'altra il mondo dietro scivola un poco, e
				// dalle crepe esce luce
				if (r < 1.0) {
					float k = 1.0 - r;
					float vicina = 1e5;
					float settore = 0.0;
					for (int c = 0; c < 6; c++) {
						float fc = float(c);
						float lunga = 0.55 + 0.45 * caso(vec2(fc, fase_n));
						float base = (fc + 0.35 * (caso(vec2(fc, fase_n + 1.3)) - 0.5)) * 1.0471976;
						float storta = (texture(rumore, vec2(r * 1.6 + fc * 0.37, fase_n + fc * 0.11)).r - 0.5) * 1.1;
						float dove = base + storta * r;
						float scarto = abs(mod(th - dove + 3.14159265, 6.2831853) - 3.14159265);
						float dist = scarto * r * raggio + max(r - lunga, 0.0) * raggio * 3.0;
						vicina = min(vicina, dist / mix(1.0, 0.3, r));
						// il ramo: parte a meta' crepa e se ne va di lato
						float ramo_da = 0.3 + 0.3 * caso(vec2(fc, fase_n + 2.9));
						float ramo = dove + (caso(vec2(fc, fase_n + 4.1)) > 0.5 ? 1.0 : -1.0) * (r - ramo_da) * 1.4;
						float scarto_r = abs(mod(th - ramo + 3.14159265, 6.2831853) - 3.14159265);
						float dist_r = scarto_r * r * raggio + max(r - (ramo_da + 0.3), 0.0) * raggio * 3.0
								+ max(ramo_da - r, 0.0) * raggio * 3.0;
						vicina = min(vicina, dist_r / mix(1.4, 0.4, r));
						settore += step(base + storta * r, th + 3.14159265 - 3.14159265 * step(3.14159265, th));
					}
					float crepa = (1.0 - smoothstep(1.2, 2.4, vicina)) * smoothstep(0.12, 0.17, r) * apre_n;
					vec2 via = normalize(e + vec2(0.0001));
					vec2 off = (vec2(caso(vec2(settore, fase_n)), caso(vec2(settore + 5.0, fase_n))) - 0.5) * raggio * 0.05 * k
							+ via * raggio * 0.025 * k;
					sposta += vec2(off.x, off.y * sch) * apre_n;
					float batte = 0.8 + 0.2 * sin(tempo * 1.4 + fase_n * 6.0);
					float bagliore = exp(-pow(vicina / (4.0 + 4.0 * en), 2.0)) * smoothstep(1.0, 0.5, r)
							* (0.35 + 0.55 * en) * batte * apre_n;
					sovrapponi(sopra, calda, retino(FRAGCOORD.xy, bagliore, cella) * bagliore);
					sovrapponi(sopra, luce, crepa);
					// il buco, dall'orlo spezzato
					float orlo_r = 0.13 + (texture(rumore, vec2(th * 0.9, fase_n * 3.0)).r - 0.5) * 0.06;
					nero = max(nero, smoothstep(orlo_r + 0.01, orlo_r - 0.01, r) * apre_n);
					sovrapponi(sopra, luce, exp(-pow((r - orlo_r) / 0.012, 2.0)) * (0.7 + 0.3 * en) * apre_n);
				}
			} else if (stile == 3) {
				// IL VARCO: una mandorla in piedi, col tratto arancio del manifesto,
				// e intorno sulla griglia onde lente come in uno stagno
				if (r < 1.0) {
					for (int o = 0; o < 3; o++) {
						float fr = fract(tempo * 0.06 + float(o) / 3.0 + fase_n);
						float onda = exp(-pow((r - (0.2 + fr * 0.8)) / 0.012, 2.0)) * (1.0 - fr);
						sovrapponi(sopra, luce, onda * 0.7 * (0.4 + 0.6 * en));
						sposta += normalize(d + vec2(0.0001)) * onda * 3.0;
					}
				}
				float alto_n = raggio * 0.75 * mix(1.0, 0.6, sch * sch);
				float l = s.y / alto_n;
				if (abs(l) < 1.0) {
					float largo_n = raggio * 0.3 * apre_n * (1.0 - l * l);
					float fuori_n = abs(s.x) - largo_n;
					float dentro_n = smoothstep(0.8, -0.8, fuori_n);
					float tratto = 1.0 - smoothstep(1.6, 2.6, abs(fuori_n + 1.2));
					float cuore = exp(-pow(length(vec2(s.x / max(largo_n, 1.0), l)) * 1.4, 2.0));
					float pt = retino(FRAGCOORD.xy, cuore * (0.5 + 0.5 * en) + 0.05, cella);
					sovrapponi(sopra, mix(fondo, luce, pt), dentro_n * aperta);
					sovrapponi(sopra, calda, tratto * aperta);
				}
			} else {
				// IL GORGO A RETINO: un disco di puntini che si stringe in un buco
				// nero, coi bracci fermi come in una stampa
				if (r < 1.0) {
					float k = 1.0 - r;
					sposta += -d * 0.45 * k * k * k;
					float braccio = 0.5 + 0.5 * sin(th * 3.0 + log(max(r, 0.05)) * 5.0 + fase_n * 3.0);
					float densita = smoothstep(1.0, 0.25, r) * (0.25 + 0.75 * braccio) * (0.5 + 0.5 * en);
					float pt = retino(FRAGCOORD.xy, densita, cella * 0.9);
					vec3 tinta = mix(luce, calda, smoothstep(0.6, 0.25, r));
					sovrapponi(sopra, tinta, pt * smoothstep(0.17, 0.22, r) * apre_n);
					nero = max(nero, smoothstep(0.2, 0.15, r) * apre_n);
					sovrapponi(sopra, luce, exp(-pow((r - 0.2) / 0.015, 2.0)) * apre_n);
				}
			}
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
	col = mix(col, fondo, nero * 0.95);
	col = mix(col, sopra.rgb, clamp(sopra.a, 0.0, 1.0));
	COLOR = vec4(col, 1.0);
}
