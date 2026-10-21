// LA DORATURA DEL BOND (LuceBond.gd), sul CanvasGroup di ogni lettera, della
// riga e delle tracce di luce. Quello che c'e' nel gruppo arriva bianco: se ne
// legge solo quanto e' coperto. Qui si sfoca, si colora d'oro dall'alto in
// basso (oro chiaro, ambra), si riempie dal basso col pelo chiaro, ci passa il
// riflesso, e intorno gli si accende il bagliore.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D foglio : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float sfoca = 0.0;        // raggio della sfocatura, in pixel
uniform float bagliore = 0.0;     // quanto splende intorno
uniform float bianco = 0.0;       // quanto e' ancora luce invece che oro
uniform float lucido = -1.0;      // dove passa il riflesso (x sullo schermo, da 0 a 1)
uniform float riempi = -1.0;      // si riempie dal basso: c'e' sotto questa riga (y, da 0 a 1)
uniform vec2 alto_basso = vec2(0.3, 0.6);
uniform vec3 oro_chiaro : source_color = vec3(0.86, 0.63, 0.25);
uniform vec3 oro_scuro : source_color = vec3(0.52, 0.30, 0.06);
uniform vec3 tinta_alone : source_color = vec3(1.0, 0.84, 0.52);

float disco(vec2 uv, vec2 px, float r) {
	if (r < 0.75) {
		return textureLod(foglio, uv, 0.0).a;
	}
	float lod = max(0.0, log2(r) - 2.5);
	float s = 0.0;
	for (int i = 0; i < 24; i++) {
		float f = (float(i) + 0.5) / 24.0;
		float a = float(i) * 2.39996323;
		s += textureLod(foglio, uv + vec2(cos(a), sin(a)) * sqrt(f) * r * px, lod).a;
	}
	return s / 24.0;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = SCREEN_PIXEL_SIZE;
	float m = disco(uv, px, sfoca);
	float g = 0.55 * disco(uv, px, 14.0 + sfoca) + 0.45 * disco(uv, px, 42.0 + sfoca);
	m *= smoothstep(riempi - 0.005, riempi + 0.005, uv.y);
	g *= smoothstep(riempi - 0.04, riempi + 0.01, uv.y);
	float pelo = riempi > 0.0 ? exp(-pow((uv.y - riempi) / 0.012, 2.0)) : 0.0;
	float v = clamp((uv.y - alto_basso.x) / max(alto_basso.y - alto_basso.x, 0.001), 0.0, 1.0);
	vec3 tinta = mix(oro_chiaro, oro_scuro, smoothstep(0.0, 1.0, v));
	float d = (uv.x - lucido) - (uv.y - alto_basso.x) * 0.3;
	float riflesso = exp(-d * d / 0.0008);
	tinta = mix(tinta, vec3(1.0, 0.99, 0.95), clamp(max(max(bianco, pelo), riflesso * 0.9), 0.0, 1.0));
	float ga = clamp(g * bagliore * 1.6, 0.0, 1.0);
	float a = m + ga * (1.0 - m);
	vec3 col = (tinta * m + tinta_alone * ga * (1.0 - m)) / max(a, 0.0001);
	COLOR = vec4(col, a * COLOR.a);
}
