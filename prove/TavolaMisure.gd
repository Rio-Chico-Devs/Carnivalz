extends RefCounted

# LA TAVOLA DELLE MISURE (proposte della crescita, foto «misure»): le icone di
# IconeStatistiche guardate come le guarda chi corregge un set.
#   - sulle forme chiave di Material, riportate su 100: il quadrato di 75, il
#     cerchio di 83, il rettangolo verticale 67 x 83 e quello orizzontale 83 x 67.
#     Non sono una gabbia: dicono quanto spazio prende di solito una forma di
#     quel genere;
#   - il baricentro (il punto arancio) e il centro visivo (la crocetta), contro
#     il centro del quadrato;
#   - la prova della sfocatura: sfocate, le nove devono sembrare macchie dello
#     stesso peso e della stessa grandezza;
#   - la sagoma, e le icone a 24 e 16 pixel sul fondo della scheda.
# I numeri: la pienezza e lo scarto dalla media, lo scarto del centro visivo, il
# raggio d'inerzia (quanto la massa e' sparsa).

const P := preload("res://scripts/crescita/PezziCrescita.gd")
const I := preload("res://scripts/crescita/IconeStatistiche.gd")
const SCHEDA := Color("#1a1512")

static var sfocate: Dictionary = {}


static func disegna(t: CanvasItem) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.06), Vector2(1.0, 1.0))
	P.etichetta(t, Vector2(28, 52), "LE MISURE", 36, P.CREMA, P.NERO, P.ARANCIO)
	P.scritta(t, Vector2(300, 80), "Sfocate, le nove devono sembrare macchie uguali. In arancio le forme chiave di Material",
			15, P.CARTA, Caratteri.tondo(700))
	P.scritta(t, Vector2(300, 100), "riportate su 100, il baricentro (il punto) e il centro visivo (la crocetta).",
			15, P.CARTA, Caratteri.tondo(700))
	var foglio := Rect2(28, 132, 1224, 560)
	P.cartoncino(t, foglio, P.CARTA, 0.0, P.OMBRA, true)
	var media := 0.0
	for chiave: String in I.CHIAVI:
		media += I.pienezza(chiave, 1.0)
	media /= I.CHIAVI.size()
	for i in I.CHIAVI.size():
		var chiave: String = I.CHIAVI[i]
		var x0 := foglio.position.x + 136.0 * i
		var cx := x0 + 68.0
		if i > 0:
			t.draw_line(Vector2(x0, foglio.position.y + 14), Vector2(x0, foglio.end.y - 14), Color(P.NERO, 0.1), 1.0)
		var nome := "Maestria" if chiave == "maestria_dominio" else String(I.NOMI[chiave])
		P.scritta(t, Vector2(x0 + 4, 156), nome.to_upper(), 11, P.NERO, Caratteri.tondo(900),
				HORIZONTAL_ALIGNMENT_CENTER, 128)
		chiavi_material(t, Vector2(cx, 232), 104.0)
		I.disegna(t, chiave, Vector2(cx, 232), 104.0, P.NERO, P.CARTA)
		centri(t, chiave, Vector2(cx, 232), 104.0)
		sfocata(t, chiave, Vector2(cx, 352), 104.0)
		I.disegna(t, chiave, Vector2(cx, 460), 80.0, P.NERO, P.CARTA, true)
		var pien := I.pienezza(chiave, 1.0)
		var scarto := I.centro_visivo(chiave) - I.CENTRO
		var righe := ["pienezza %.3f" % pien, "dalla media %+.0f%%" % ((pien / media - 1.0) * 100.0),
				"centro %+.1f, %+.1f" % [scarto.x, scarto.y], "raggio %.1f" % I.raggio_inerzia(chiave)]
		for k in righe.size():
			P.scritta(t, Vector2(x0 + 4, 524 + 15 * k), String(righe[k]), 11, P.TRATTO, Caratteri.tondo(800),
					HORIZONTAL_ALIGNMENT_CENTER, 128)
		t.draw_rect(Rect2(x0 + 14, 592, 108, 84), SCHEDA)
		I.timbro(t, chiave, Vector2(cx - 22, 634), 24.0, P.CREMA, SCHEDA, P.ARANCIO)
		I.timbro(t, chiave, Vector2(cx + 22, 634), 16.0, P.CREMA, SCHEDA, P.ARANCIO)
	P.scritta(t, Vector2(1060, 708), "sul fondo della scheda: 24 e 16 px", 11, P.CARTA, Caratteri.tondo(800))


static func chiavi_material(t: CanvasItem, c: Vector2, l: float) -> void:
	var k := l / I.LATO
	var tinta := Color(P.ARANCIO, 0.55)
	t.draw_rect(Rect2(c - Vector2(46, 46) * k, Vector2(92, 92) * k), Color(P.NERO, 0.12), false, 1.0)
	t.draw_rect(Rect2(c - Vector2(37.5, 37.5) * k, Vector2(75, 75) * k), tinta, false, 1.0)
	t.draw_arc(c, 41.5 * k, 0.0, TAU, 64, tinta, 1.0, true)
	t.draw_rect(Rect2(c - Vector2(33.5, 41.5) * k, Vector2(67, 83) * k), Color(tinta, 0.35), false, 1.0)
	t.draw_rect(Rect2(c - Vector2(41.5, 33.5) * k, Vector2(83, 67) * k), Color(tinta, 0.35), false, 1.0)


static func centri(t: CanvasItem, chiave: String, c: Vector2, l: float) -> void:
	var k := l / I.LATO
	var g := c + (I.baricentro(chiave) - I.CENTRO) * k
	var v := c + (I.centro_visivo(chiave) - I.CENTRO) * k
	t.draw_line(c - Vector2(3, 0), c + Vector2(3, 0), P.TRATTO, 1.0)
	t.draw_line(c - Vector2(0, 3), c + Vector2(0, 3), P.TRATTO, 1.0)
	t.draw_circle(g, 3.5, P.ARANCIO)
	t.draw_line(v - Vector2(6, 0), v + Vector2(6, 0), P.ARANCIO_SCURO, 2.0)
	t.draw_line(v - Vector2(0, 6), v + Vector2(0, 6), P.ARANCIO_SCURO, 2.0)


static func sfocata(t: CanvasItem, chiave: String, c: Vector2, l: float) -> void:
	# l'inchiostro su celle di 2 unita', sfocato con una gaussiana di 6 unita'
	var lato := 50
	if not sfocate.has(chiave):
		var celle := I.griglia_inchiostro(chiave, 2.0)
		var nucleo: Array[float] = []
		var somma := 0.0
		for d in range(-9, 10):
			var w := exp(-0.5 * pow(d / 3.0, 2.0))
			nucleo.append(w)
			somma += w
		var orizzontale := PackedFloat32Array()
		orizzontale.resize(lato * lato)
		for y in lato:
			for x in lato:
				var v := 0.0
				for d in range(-9, 10):
					var xx := x + d
					if xx >= 0 and xx < lato:
						v += celle[y * lato + xx] * nucleo[d + 9]
				orizzontale[y * lato + x] = v / somma
		var tutta := PackedFloat32Array()
		tutta.resize(lato * lato)
		for y in lato:
			for x in lato:
				var v := 0.0
				for d in range(-9, 10):
					var yy := y + d
					if yy >= 0 and yy < lato:
						v += orizzontale[yy * lato + x] * nucleo[d + 9]
				tutta[y * lato + x] = v / somma
		sfocate[chiave] = tutta
	var valori: PackedFloat32Array = sfocate[chiave]
	var cella := l / lato
	var origine := c - Vector2(l, l) * 0.5
	for y in lato:
		for x in lato:
			var v := valori[y * lato + x]
			if v > 0.01:
				t.draw_rect(Rect2(origine + Vector2(x, y) * cella, Vector2(cella + 0.5, cella + 0.5)),
						P.CARTA.lerp(P.NERO, minf(v * 1.6, 1.0)))
