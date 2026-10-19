extends RefCounted

# I SEGNI DELLA MAPPA, ridisegnati per le proposte. Quelli di oggi (SegniMappa)
# sono tre cerchi e una croce: il boss e' un anello, un personaggio e' un anello
# piu' piccolo, uno scontro duro e' un punto. Sulla Casa Gigante l'anello sopra
# l'attico (Yhvina) e quello sopra l'altare (il boss) si leggono uguali.
#
# Qui ogni segno e' una sagoma piena, diversa dalle altre gia' nel contorno (si
# riconosce anche piccola, anche senza colore), sempre con la sua fascia intorno
# perche' regga su qualunque fondo. Il punto esclamativo resta quello approvato.


const NOMI := {"uscita": "uscita", "boss": "il boss", "forte": "scontro duro", "personaggio": "qualcuno ti aspetta",
		"obiettivo": "dove devi andare", "chiave": "serve qualcosa", "scala": "scale", "chiusa": "chiusa",
		"proiettore": "proiettore", "sei_qui": "sei qui"}


static func disegna(t: CanvasItem, quale: String, c: Vector2, r: float, inchiostro: Color, fondo: Color, fascia := 2.5) -> void:
	match quale:
		"uscita":
			uscita(t, c, r, inchiostro, fondo, fascia)
		"boss":
			pieno(t, corona(c, r), inchiostro, fondo, fascia)
		"forte":
			pieno(t, stella(c, r * 0.95, r * 0.5, 7), inchiostro, fondo, fascia)
		"personaggio":
			persona(t, c, r, inchiostro, fondo, fascia)
		"obiettivo":
			esclamativo(t, c, r, inchiostro, fondo, fascia)
		"chiave":
			chiave(t, c, r, inchiostro, fondo, fascia)
		"scala", "scala_su", "scala_giu":
			scala(t, c, r, inchiostro, fondo, fascia, quale)
		"chiusa":
			lucchetto(t, c, r, inchiostro, fondo, fascia)
		"proiettore":
			proiettore(t, c, r, inchiostro, fondo, fascia)
		"sei_qui":
			pieno(t, freccia_giu(c, r), inchiostro, fondo, fascia)
		_:
			pieno(t, cerchio(c, r * 0.4, 16), inchiostro, fondo, fascia)


static func pieno(t: CanvasItem, punti: PackedVector2Array, inchiostro: Color, fondo: Color, fascia: float) -> void:
	if fascia > 0.0:
		Manifesto.poligono(t, Manifesto.scosta(punti, fascia), fondo)
	Manifesto.poligono(t, punti, inchiostro)


static func tratto(t: CanvasItem, da: Vector2, a: Vector2, spesso: float, inchiostro: Color, fondo: Color, fascia: float) -> void:
	if fascia > 0.0:
		t.draw_line(da, a, fondo, spesso + fascia * 2.0, true)
		t.draw_circle(da, spesso * 0.5 + fascia, fondo)
		t.draw_circle(a, spesso * 0.5 + fascia, fondo)
	t.draw_line(da, a, inchiostro, spesso, true)
	t.draw_circle(da, spesso * 0.5, inchiostro)
	t.draw_circle(a, spesso * 0.5, inchiostro)


static func cerchio(c: Vector2, r: float, lati := 24) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in lati:
		p.append(c + Vector2.from_angle(TAU * float(i) / float(lati)) * r)
	return p


static func corona(c: Vector2, r: float) -> PackedVector2Array:
	# tre punte su una fascia: il boss, il padrone del posto
	var b := r * 0.62
	var h := r * 0.9
	return PackedVector2Array([c + Vector2(-r * 0.9, b), c + Vector2(-r * 0.9, -h * 0.45), c + Vector2(-r * 0.45, -h * 0.05),
			c + Vector2(0.0, -h), c + Vector2(r * 0.45, -h * 0.05), c + Vector2(r * 0.9, -h * 0.45), c + Vector2(r * 0.9, b)])


static func stella(c: Vector2, fuori: float, dentro: float, punte: int) -> PackedVector2Array:
	# lo scoppio: uno scontro piu' grosso di quelli di passaggio
	var p := PackedVector2Array()
	for i in punte * 2:
		var a := TAU * float(i) / float(punte * 2) - PI * 0.5
		p.append(c + Vector2.from_angle(a) * (fuori if i % 2 == 0 else dentro))
	return p


static func freccia_giu(c: Vector2, r: float) -> PackedVector2Array:
	var w := r * 0.55
	return PackedVector2Array([c + Vector2(0, r), c + Vector2(-r * 0.9, 0), c + Vector2(-w * 0.5, 0), c + Vector2(-w * 0.5, -r),
			c + Vector2(w * 0.5, -r), c + Vector2(w * 0.5, 0), c + Vector2(r * 0.9, 0)])


static func uscita(t: CanvasItem, c: Vector2, r: float, inchiostro: Color, fondo: Color, fascia: float) -> void:
	# la porta aperta e la freccia che ne esce
	var s := maxf(r * 0.26, 2.0)
	tratto(t, c + Vector2(-r * 0.7, -r * 0.8), c + Vector2(-r * 0.7, r * 0.8), s, inchiostro, fondo, fascia)
	tratto(t, c + Vector2(-r * 0.35, 0.0), c + Vector2(r * 0.45, 0.0), s, inchiostro, fondo, fascia)
	pieno(t, PackedVector2Array([c + Vector2(r * 0.95, 0.0), c + Vector2(r * 0.25, -r * 0.6), c + Vector2(r * 0.25, r * 0.6)]),
			inchiostro, fondo, fascia)


static func persona(t: CanvasItem, c: Vector2, r: float, inchiostro: Color, fondo: Color, fascia: float) -> void:
	var spalle := PackedVector2Array()
	for i in 13:
		var a := PI + PI * float(i) / 12.0
		spalle.append(c + Vector2(0, r * 0.95) + Vector2(cos(a) * r * 0.85, sin(a) * r * 0.78))
	if fascia > 0.0:
		Manifesto.poligono(t, Manifesto.scosta(spalle, fascia), fondo)
		t.draw_circle(c + Vector2(0, -r * 0.35), r * 0.42 + fascia, fondo)
	Manifesto.poligono(t, spalle, inchiostro)
	t.draw_circle(c + Vector2(0, -r * 0.35), r * 0.42, inchiostro)


static func esclamativo(t: CanvasItem, c: Vector2, r: float, inchiostro: Color, fondo: Color, fascia: float) -> void:
	var s := maxf(r * 0.36, 2.5)
	tratto(t, c + Vector2(0, -r * 0.85), c + Vector2(0, r * 0.25), s, inchiostro, fondo, fascia)
	if fascia > 0.0:
		t.draw_circle(c + Vector2(0, r * 0.8), s * 0.62 + fascia, fondo)
	t.draw_circle(c + Vector2(0, r * 0.8), s * 0.62, inchiostro)


static func chiave(t: CanvasItem, c: Vector2, r: float, inchiostro: Color, fondo: Color, fascia: float) -> void:
	var s := maxf(r * 0.24, 2.0)
	var anello := c + Vector2(-r * 0.5, 0)
	tratto(t, anello, c + Vector2(r * 0.95, 0), s, inchiostro, fondo, fascia)
	tratto(t, c + Vector2(r * 0.55, 0), c + Vector2(r * 0.55, r * 0.5), s, inchiostro, fondo, fascia)
	tratto(t, c + Vector2(r * 0.85, 0), c + Vector2(r * 0.85, r * 0.4), s, inchiostro, fondo, fascia)
	if fascia > 0.0:
		t.draw_circle(anello, r * 0.45 + fascia, fondo)
	t.draw_circle(anello, r * 0.45, inchiostro)
	t.draw_circle(anello, r * 0.18, fondo)


static func scala(t: CanvasItem, c: Vector2, r: float, inchiostro: Color, fondo: Color, fascia: float, verso: String) -> void:
	# tre gradini; se si sa dove porta, la freccia lo dice
	var gradini := PackedVector2Array([c + Vector2(-r, r * 0.8), c + Vector2(-r, r * 0.25), c + Vector2(-r * 0.35, r * 0.25),
			c + Vector2(-r * 0.35, -r * 0.3), c + Vector2(r * 0.3, -r * 0.3), c + Vector2(r * 0.3, -r * 0.85),
			c + Vector2(r, -r * 0.85), c + Vector2(r, r * 0.8)])
	pieno(t, gradini, inchiostro, fondo, fascia)
	if verso == "scala_su" or verso == "scala_giu":
		var punta := c + Vector2(-r * 0.55, -r * 0.75) if verso == "scala_su" else c + Vector2(-r * 0.55, -r * 0.05)
		var giu := 1.0 if verso == "scala_giu" else -1.0
		pieno(t, PackedVector2Array([punta, punta + Vector2(-r * 0.4, -giu * r * 0.45), punta + Vector2(r * 0.4, -giu * r * 0.45)]),
				inchiostro, fondo, fascia * 0.6)


static func lucchetto(t: CanvasItem, c: Vector2, r: float, inchiostro: Color, fondo: Color, fascia: float) -> void:
	var corpo := PackedVector2Array([c + Vector2(-r * 0.75, -r * 0.1), c + Vector2(r * 0.75, -r * 0.1),
			c + Vector2(r * 0.75, r * 0.9), c + Vector2(-r * 0.75, r * 0.9)])
	if fascia > 0.0:
		t.draw_arc(c + Vector2(0, -r * 0.15), r * 0.48, PI, TAU, 16, fondo, maxf(r * 0.22, 2.0) + fascia * 2.0, true)
	t.draw_arc(c + Vector2(0, -r * 0.15), r * 0.48, PI, TAU, 16, inchiostro, maxf(r * 0.22, 2.0), true)
	pieno(t, corpo, inchiostro, fondo, fascia)


static func proiettore(t: CanvasItem, c: Vector2, r: float, inchiostro: Color, fondo: Color, fascia: float) -> void:
	pieno(t, PackedVector2Array([c + Vector2(-r * 0.9, -r * 0.2), c + Vector2(r * 0.9, -r * 0.85), c + Vector2(r * 0.9, r * 0.85),
			c + Vector2(-r * 0.9, r * 0.2)]), inchiostro, fondo, fascia)
	t.draw_circle(c + Vector2(-r * 0.55, 0), r * 0.2, fondo)
