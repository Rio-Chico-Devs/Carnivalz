// LE LASTRE DEL VETRO ROTTO (LastreVetro.gd): ogni pezzo fra le crepe sposta
// di qualche pixel quello che c'e' dietro, ognuno per conto suo. E' cosi' che
// un vetro spaccato si riconosce anche senza guardare le crepe: le cose dietro
// non combaciano piu' da un pezzo all'altro.
//
// Lo spostamento arriva nel colore dei vertici, cosi' tutti i pezzi stanno in
// un disegno solo: rosso e verde sono lo spostamento (0.5 = fermo, 0 e 1 =
// spinta_massima pixel da una parte e dall'altra), il blu e' la luce del pezzo
// (0.5 = com'e', sopra piu' chiaro, sotto piu' scuro), l'alfa quanto si vede.
// Il rosso e il blu di quello che c'e' dietro si spostano un poco piu' e un
// poco meno del verde: ai bordi di ogni pezzo la luce si scompone in un filo
// di colore, come in un vetro vero.
//
// Si legge solo DENTRO il piano dei pugni: un pezzo sul bordo che si sposta
// verso fuori pescherebbe la cornice nera del riquadro e se la porterebbe
// dentro. Il conto si fa in pixel del piano (misura), non dello schermo: lo
// scontro che sbanda sposta il piano sullo schermo a ogni fotogramma, e un
// rettangolo misurato sullo schermo arrivava sempre un fotogramma tardi.
shader_type canvas_item;

uniform sampler2D schermo : hint_screen_texture, repeat_disable, filter_linear;
uniform float spinta_massima = 16.0;
uniform vec2 misura = vec2(1.0, 1.0);

varying vec2 locale;

void vertex() {
	locale = VERTEX;
}

vec2 entro(vec2 voluto, vec2 da) {
	// lo spostamento, accorciato quanto serve perche' resti sul piano
	return clamp(da + voluto, vec2(1.0), misura - 1.0) - da;
}

void fragment() {
	vec2 voluto = (COLOR.rg - 0.5) * 2.0 * spinta_massima;
	float rosso = texture(schermo, SCREEN_UV + entro(voluto * 1.35, locale) * SCREEN_PIXEL_SIZE).r;
	float verde = texture(schermo, SCREEN_UV + entro(voluto, locale) * SCREEN_PIXEL_SIZE).g;
	float blu = texture(schermo, SCREEN_UV + entro(voluto * 0.65, locale) * SCREEN_PIXEL_SIZE).b;
	vec3 luce = vec3((COLOR.b - 0.5) * 0.6);
	COLOR = vec4(clamp(vec3(rosso, verde, blu) + luce, 0.0, 1.0), COLOR.a);
}
