// IL LAVAGGIO DEL BOND (LuceBond.gd): la luce che purifica lo scontro. Legge
// quello che c'e' sotto e lo scolora, lo schiarisce e lo sfoca, finche' ne
// resta un fantasma color crema; e lo fa fra due onde che salgono dal basso,
// quella che porta la luce e quella che la porta via. Il bordo delle onde
// ondeggia piano, come la marea, e brilla.
//
// LA FOTO. Sotto la luce lo scontro e' quello del momento in cui hai mediato,
// fermo: la creatura e' ancora li' finche' la luce la copre, e se n'e' andata
// quando la seconda onda riporta lo scontro vero. Senza la foto (senza
// finestra) si lava lo scontro com'e'.
shader_type canvas_item;

uniform sampler2D schermo : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D foto : repeat_disable, filter_linear_mipmap;
uniform float con_foto = 0.0;    // 1 = sotto la luce si vede la foto, non lo scontro di adesso
uniform float quanto = 0.0;      // quanto e' lavato dove la luce e' arrivata
uniform float sogno = 0.0;       // quanto e' sfocato (livelli di mipmap)
uniform float fronte = 2.0;      // l'onda che porta la luce: lava sotto di se'
uniform float coda = 2.0;        // l'onda che la porta via: sotto di lei lo scontro e' tornato
uniform float morbido = 0.32;    // quanto sono sfumati i bordi delle onde
uniform float cresta = 0.0;      // quanto brilla il bordo della prima
uniform float scia = 0.0;        // quanto brilla il bordo della seconda
uniform float alone = 0.0;       // il bianco dietro la parola
uniform float marea = 1.0;       // quanto ondeggiano i bordi (zero col movimento ridotto)
uniform float tempo = 0.0;
uniform vec2 centro = vec2(0.5, 0.47);
uniform vec3 pesca : source_color = vec3(0.97, 0.90, 0.80);
uniform vec3 crema : source_color = vec3(1.0, 0.975, 0.94);

void fragment() {
	vec2 uv = SCREEN_UV;
	float prop = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	float dist = length((uv - centro) * vec2(prop, 1.0));
	float onda = marea * (0.012 * sin(uv.x * 8.0 + tempo * 2.0) + 0.007 * sin(uv.x * 21.0 - tempo * 2.9));
	float f = fronte + onda;
	float c = coda - onda;
	float dentro = smoothstep(f - morbido, f, uv.y) * (1.0 - smoothstep(c - morbido, c, uv.y));
	float lava = dentro * quanto;
	float fermo = con_foto * (1.0 - smoothstep(c - morbido, c, uv.y));
	vec3 vero = mix(textureLod(schermo, uv, 0.0).rgb, textureLod(foto, uv, 0.0).rgb, fermo);
	vec3 sfocato = mix(textureLod(schermo, uv, sogno * dentro).rgb, textureLod(foto, uv, sogno * dentro).rgb, fermo);
	float l = dot(sfocato, vec3(0.299, 0.587, 0.114));
	vec3 pallido = mix(pesca, crema, smoothstep(0.0, 0.7, l));
	vec3 col = mix(vero, sfocato, clamp(lava * 1.5, 0.0, 1.0));
	col = mix(col, pallido, lava);
	col = mix(col, vec3(1.0), alone * dentro * exp(-dist * dist / 0.12));
	float d = (uv.y - (f - morbido * 0.45)) / 0.08;
	col = mix(col, vec3(1.0, 0.99, 0.96), cresta * exp(-d * d));
	float e = (uv.y - (c - morbido * 0.55)) / 0.08;
	col = mix(col, vec3(1.0, 0.99, 0.96), scia * exp(-e * e));
	COLOR = vec4(col, COLOR.a);
}
