// LA CORRUZIONE DEL CARNIVALZ sulle regioni non ancora tue (prove/MondoProva.gd).
// Provvisorio. Non aggiunge niente sopra il disegno: gli toglie colore. Una
// regione selvaggia e' spenta e virata verso la tinta della fonte; quando ne
// ripari il faro il colore torna, a onda, a partire dal faro.
//
// La maschera ha un pixel per casella del mondo (rosso = quanto e' corrotta)
// ed e' filtrata: fra due regioni il passaggio e' morbido, ma i pixel del
// disegno restano quelli.
shader_type canvas_item;

uniform sampler2D corruzione : filter_linear;
uniform vec2 celle = vec2(104.0, 76.0);
uniform vec4 tinta : source_color = vec4(0.53, 0.19, 0.35, 1.0);

varying vec2 mondo;

void vertex() {
	mondo = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 c = COLOR;
	float k = texture(corruzione, mondo / 16.0 / celle).r;
	float luce = dot(c.rgb, vec3(0.3, 0.55, 0.15));
	vec3 spento = mix(c.rgb, vec3(luce), 0.55) * 0.8;
	spento = mix(spento, spento * tinta.rgb * 2.0, 0.3);
	c.rgb = mix(c.rgb, spento, k * 0.85);
	COLOR = c;
}
