// IL RUMORE DELLA RACCOLTA (prove/RaccoltaProva.gd): un caso per cella, un
// rumore morbido e la sua somma a ottave. Lo usano la terra, la nebbia e il
// vuoto. Provvisorio come la raccolta.

float caso(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float morbido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(caso(i), caso(i + vec2(1.0, 0.0)), u.x),
			mix(caso(i + vec2(0.0, 1.0)), caso(i + vec2(1.0, 1.0)), u.x), u.y);
}

float ottave(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int k = 0; k < 5; k++) {
		v += a * morbido(p);
		p = p * 2.03 + vec2(17.3, 9.1);
		a *= 0.5;
	}
	return v;
}

// il contorno storto dei campi, lo stesso di RaccoltaDisegno.zolla: dato un
// punto, quanto e' lontano dal centro rispetto al bordo (1 = sul bordo)
float dentro_al_campo(vec2 p, vec2 centro, vec2 raggi, float seme) {
	vec2 q = (p - centro) / raggi;
	float a = atan(q.y, q.x);
	float r = 1.0 + 0.07 * sin(3.0 * a + seme) + 0.05 * sin(5.0 * a + seme * 2.3);
	return length(q) / r;
}
