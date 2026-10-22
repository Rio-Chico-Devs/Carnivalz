// IL VETRO ROTTO CHE SI GUARDA ATTRAVERSO (TeleVetro.gd): i pezzi fra le
// crepe e quelli che saltano via mostrano quello che c'e' dietro, ognuno
// spostato per conto suo. E' cosi' che un vetro spaccato si riconosce anche
// senza guardare le crepe: le cose dietro non combaciano piu' da un pezzo
// all'altro.
//
// UV e' lo spostamento, in pixel del piano: per un pezzo fermo e' lo stesso in
// tutti i suoi vertici, per un pezzo che vola e' da dove viene ogni vertice
// (cosi' si porta dietro il suo pezzo di immagine, anche girando). COLOR e' la
// luce del pezzo (0.5 = com'e', sopra piu' chiaro, sotto piu' scuro) e quanto
// si vede. Con UV oltre i 9000 pixel il pezzo non guarda dietro: e' un colore
// pieno (i bordi dei pezzi che volano).
//
// L'ONDA dell'impatto e' una deformazione, non un cerchio disegnato: un anello
// che si allarga e spinge in fuori quello che c'e' dietro. Il rosso e il blu si
// spostano un poco piu' e un poco meno del verde: ai bordi la luce si scompone
// in un filo di colore, come in un vetro vero.
//
// Si legge solo DENTRO il piano dei pugni (misura): sul bordo un pezzo
// spostato pescherebbe la cornice nera del riquadro.
shader_type canvas_item;

uniform sampler2D schermo : hint_screen_texture, repeat_disable, filter_linear;
uniform vec2 misura = vec2(1.0, 1.0);
uniform vec2 impatto = vec2(0.0, 0.0);
uniform float onda_raggio = -1.0;   // dove e' l'onda, in pixel dall'impatto (sotto zero: non c'e')
uniform float onda_forza = 0.0;     // di quanti pixel spinge
uniform float scomposta = 0.3;      // quanto si apre il colore ai bordi

varying vec2 locale;

void vertex() {
	locale = VERTEX;
}

vec2 entro(vec2 voluto, vec2 da) {
	// lo spostamento, accorciato quanto serve perche' resti sul piano
	return clamp(da + voluto, vec2(1.0), misura - 1.0) - da;
}

void fragment() {
	if (UV.x > 9000.0) {
		COLOR = COLOR;
	} else {
		vec2 voluto = UV;
		if (onda_raggio >= 0.0) {
			vec2 dal_centro = locale - impatto;
			float lontano = length(dal_centro);
			float anello = exp(-pow((lontano - onda_raggio) / 9.0, 2.0)) * onda_forza;
			voluto -= dal_centro / max(lontano, 0.001) * anello;
		}
		float rosso = texture(schermo, SCREEN_UV + entro(voluto * (1.0 + scomposta), locale) * SCREEN_PIXEL_SIZE).r;
		float verde = texture(schermo, SCREEN_UV + entro(voluto, locale) * SCREEN_PIXEL_SIZE).g;
		float blu = texture(schermo, SCREEN_UV + entro(voluto * (1.0 - scomposta), locale) * SCREEN_PIXEL_SIZE).b;
		vec3 luce = (COLOR.rgb - 0.5) * 0.7;
		COLOR = vec4(clamp(vec3(rosso, verde, blu) + luce, 0.0, 1.0), COLOR.a);
	}
}
