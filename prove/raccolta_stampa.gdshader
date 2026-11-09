// LA STAMPA (prove/RaccoltaProva.gd): tutto quello che e' disegnato sotto passa
// da qui, e diventa una serigrafia a tre inchiostri su carta crema. Provvisorio.
//
// Bru, sul secondo prototipo: «la grafica è troppo banale». Il pianeta prende
// la lingua del resto di Carnivalz, che e' quella del manifesto e del Vuoto
// («quattro inchiostri come una serigrafia», stile.json "proiezione"):
//   - il colore si separa in nero, arancio e blu (la matrice "separa", fatta
//     da RaccoltaProva: quanto di ogni inchiostro serve per ogni colore);
//   - ogni inchiostro e' un retino a puntini, con un angolo suo, ancorato al
//     mondo (non allo schermo: camminando i puntini non scorrono sulle cose);
//   - il nero sopra una soglia e' pieno, cosi' le linee restano linee;
//   - i fogli sono un poco fuori registro, e la carta ha la sua grana;
//   - gli angoli dello schermo scendono nel buio.
shader_type canvas_item;
#include "res://prove/raccolta_rumore.gdshaderinc"

uniform sampler2D schermo : hint_screen_texture, filter_linear;
uniform vec4 carta : source_color = vec4(0.937, 0.847, 0.698, 1.0);
uniform vec4 nero : source_color = vec4(0.122, 0.102, 0.141, 1.0);
uniform vec4 arancio : source_color = vec4(0.949, 0.604, 0.180, 1.0);
uniform vec4 blu : source_color = vec4(0.184, 0.416, 0.659, 1.0);
uniform mat3 separa;
uniform vec2 angolo_mondo = vec2(0.0);
uniform float cella = 4.5;

float puntino(vec2 p, float angolo, float quota) {
	// un retino ruotato: il puntino cresce con la quota d'inchiostro, e oltre
	// il 90% il foglio e' pieno
	if (quota > 0.9) {
		return 1.0;
	}
	float c = cos(angolo);
	float s = sin(angolo);
	vec2 q = mat2(vec2(c, s), vec2(-s, c)) * p / cella;
	float d = length(fract(q) - 0.5);
	float r = sqrt(max(quota, 0.0)) * 0.75;
	return 1.0 - smoothstep(r - 0.1, r + 0.1, d);
}

vec3 quote(vec3 colore) {
	vec3 d = -log(max(colore, vec3(0.004)) / carta.rgb);
	return separa * d;
}

void fragment() {
	vec2 passo = SCREEN_PIXEL_SIZE;
	vec2 p = SCREEN_UV / passo + angolo_mondo;
	// tre fogli, tre registri: ognuno legge il disegno un poco spostato
	float k_nero = quote(texture(schermo, SCREEN_UV).rgb).x;
	float k_arancio = quote(texture(schermo, SCREEN_UV + vec2(1.2, -0.8) * passo).rgb).y;
	float k_blu = quote(texture(schermo, SCREEN_UV + vec2(-0.9, 1.1) * passo).rgb).z;
	// sotto una soglia l'inchiostro non c'e': niente polvere di puntini sulla carta
	k_nero = k_nero < 0.14 ? 0.0 : k_nero;
	k_arancio = k_arancio < 0.08 ? 0.0 : k_arancio;
	k_blu = k_blu < 0.08 ? 0.0 : k_blu;
	// il nero: pieno sopra la meta' (le linee, i buchi), a retino sotto
	float a = k_nero > 0.55 ? 1.0 : puntino(p, 0.26, k_nero * 1.6);
	float b = puntino(p, 1.31, k_arancio);
	float c = puntino(p, 0.79, k_blu);
	vec3 colore = carta.rgb * pow(arancio.rgb, vec3(b)) * pow(blu.rgb, vec3(c)) * pow(nero.rgb, vec3(a));
	// la grana della carta e l'inchiostro che non copre uguale dappertutto
	float grana = caso(floor(p * 0.5));
	float macchia = ottave(p / 90.0);
	colore *= 0.93 + 0.05 * grana + 0.04 * macchia;
	// gli angoli nel buio
	vec2 q = SCREEN_UV - 0.5;
	colore *= 1.0 - smoothstep(0.38, 0.9, length(q * vec2(1.0, 0.8))) * 0.5;
	COLOR = vec4(colore, 1.0);
}
