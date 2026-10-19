extends RefCounted

# I PEZZI DISEGNATI DELLA CRESCITA: la schermata vera (SchedaCrescita) e le
# proposte da cui e' nata (prove/ProposteCrescita.gd). Niente oggetti del luna park («meno dettagli da circo,
# piu' astratto», Bru), solo la lingua del manifesto: l'arancio col retino, le
# lastre nere in diagonale, i rombi dell'emblema, le fasce storte, le scritte
# ritagliate, il contorno nero e l'ombra piena.

const NERO := Color("#0b0908")
const CREMA := Color("#ece6df")
const CARTA := Color("#d8cfc7")
const ARANCIO := Color("#f4931b")
const ARANCIO_SCURO := Color("#c96f12")
const BRUNO := Color("#2a211a")
const SPENTO := Color("#1c1611")
const TRATTO := Color("#6b635d")
const OMBRA := Vector2(8, 8)


# --- girare e tornare dritti ---------------------------------------------------------

static func gira(t: CanvasItem, perno: Vector2, gradi: float, scala := 1.0) -> void:
	t.draw_set_transform(perno, deg_to_rad(gradi), Vector2(scala, scala))


static func dritto(t: CanvasItem) -> void:
	t.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# --- le lastre e i rombi --------------------------------------------------------------

static func lastra(t: CanvasItem, punti: PackedVector2Array, tinta := NERO, striscia := CREMA, scosta := -16.0) -> void:
	# la lastra in diagonale con la striscia chiara accanto, come nella pausa
	if striscia.a > 0.0:
		var s := PackedVector2Array()
		for p in punti:
			s.append(p + Vector2(scosta, 0))
		Manifesto.poligono(t, s, striscia)
	Manifesto.poligono(t, punti, tinta)


static func rombo(t: CanvasItem, c: Vector2, r: float, pieno: Color, bordo := Color(0, 0, 0, 0), spessore := 3.0) -> void:
	var forma := Sagome.rombo(c, r)
	if pieno.a > 0.0:
		Manifesto.poligono(t, forma, pieno)
	if bordo.a > 0.0:
		t.draw_polyline(Sagome.chiudi(forma), bordo, spessore, true)


static func rombo_fino_a(c: Vector2, r: float, quota: float) -> PackedVector2Array:
	# la parte di sotto di un rombo, piena fino a "quota" (0..1)
	var y0 := c.y + r - 2.0 * r * clampf(quota, 0.0, 1.0)
	var p := PackedVector2Array()
	var giro := [c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)]
	for i in 4:
		var a: Vector2 = giro[i]
		var b: Vector2 = giro[(i + 1) % 4]
		if a.y >= y0:
			p.append(a)
		if (a.y - y0) * (b.y - y0) < 0.0:
			p.append(a.lerp(b, (y0 - a.y) / (b.y - a.y)))
	return p


static func gettone(t: CanvasItem, c: Vector2, r: float, quota: float, tinta := NERO, vuoto := Color(0, 0, 0, 0.18)) -> void:
	# un punto da spendere: un rombo pieno; quota < 1 e' quello che si sta riempiendo
	rombo(t, c, r, vuoto)
	if quota > 0.0:
		var parte := rombo_fino_a(c, r, quota)
		if parte.size() >= 3:
			Manifesto.poligono(t, parte, tinta)
	t.draw_polyline(Sagome.chiudi(Sagome.rombo(c, r)), tinta, 3.0, true)






static func barretta(t: CanvasItem, r: Rect2, quota: float, pieno: Color, vuoto := Color(0, 0, 0, 0)) -> void:
	# quanto manca a qualcosa, storta come le fasce
	if vuoto.a > 0.0:
		Manifesto.poligono(t, storta(r, 0.5), vuoto)
	if quota > 0.0:
		Manifesto.poligono(t, storta(Rect2(r.position, Vector2(maxf(r.size.x * clampf(quota, 0.0, 1.0), r.size.y), r.size.y)),
				0.5), pieno)




static func spicchio(t: CanvasItem, c: Vector2, dentro: float, fuori: float, da: float, a: float, tinta: Color,
		bordo := Color(0, 0, 0, 0), spessore := 3.0) -> void:
	# un pezzo d'anello, da un angolo all'altro (radianti)
	var p := PackedVector2Array()
	var passi := maxi(int(absf(a - da) / 0.04), 2)
	for i in passi + 1:
		p.append(c + Vector2.from_angle(lerpf(da, a, float(i) / passi)) * fuori)
	for i in passi + 1:
		p.append(c + Vector2.from_angle(lerpf(a, da, float(i) / passi)) * dentro)
	if tinta.a > 0.0:
		Manifesto.poligono(t, p, tinta)
	if bordo.a > 0.0:
		p.append(p[0])
		t.draw_polyline(p, bordo, spessore, true)


# --- la carta, le scritte, le forme ---------------------------------------------------

static func rombini(t: CanvasItem, centri: Array[Vector2], r: float, tinta: Color) -> void:
	# tanti rombi piccoli in un disegno solo, come Manifesto.puntini: una finitura
	# ne ha centinaia, e uno per uno costerebbero un comando ciascuno
	if centri.is_empty():
		return
	var vertici := PackedVector2Array()
	var indici := PackedInt32Array()
	for q in centri:
		var base := vertici.size()
		vertici.append(q + Vector2(0, -r))
		vertici.append(q + Vector2(r, 0))
		vertici.append(q + Vector2(0, r))
		vertici.append(q + Vector2(-r, 0))
		indici.append_array(PackedInt32Array([base, base + 1, base + 2, base, base + 2, base + 3]))
	var colori := PackedColorArray()
	colori.resize(vertici.size())
	colori.fill(tinta)
	RenderingServer.canvas_item_add_triangle_array(t.get_canvas_item(), indici, vertici, colori)


static func cartoncino(t: CanvasItem, r: Rect2, tinta: Color, spessore := 4.0, ombra := OMBRA, retino := false) -> void:
	if ombra != Vector2.ZERO:
		t.draw_rect(Rect2(r.position + ombra, r.size), NERO)
	t.draw_rect(r, tinta)
	if retino:
		Manifesto.retino(t, r, Color(NERO, 0.10), Vector2(0.85, 0.85))
	if spessore > 0.0:
		t.draw_rect(r.grow(-spessore * 0.5), NERO, false, spessore)


static func storta(r: Rect2, inclina := 0.24) -> PackedVector2Array:
	var o := r.size.y * inclina
	return PackedVector2Array([r.position + Vector2(o, 0), Vector2(r.end.x, r.position.y), r.end - Vector2(o, 0),
			Vector2(r.position.x, r.end.y)])


static func fascia(t: CanvasItem, r: Rect2, tinta: Color, sfoglia := Color(0, 0, 0, 0), spostamento := Vector2(7, 6)) -> void:
	if sfoglia.a > 0.0:
		Manifesto.poligono(t, storta(Rect2(r.position + spostamento, r.size)), sfoglia)
	Manifesto.poligono(t, storta(r), tinta)


static func scritta(t: CanvasItem, dove: Vector2, testo: String, corpo: int, tinta: Color, font: Font = null,
		allinea := HORIZONTAL_ALIGNMENT_LEFT, largo := -1.0) -> void:
	t.draw_string(font if font != null else Caratteri.titolo(), dove, testo, allinea, largo, corpo, tinta)


static func ritagliata(t: CanvasItem, dove: Vector2, testo: String, corpo: int, tinta: Color, contorno := NERO,
		spessore := 10, ombra := Color(0, 0, 0, 0), spostamento := Vector2(7, 7), font: Font = null,
		allinea := HORIZONTAL_ALIGNMENT_LEFT, largo := -1.0) -> void:
	# la scritta ritagliata e incollata: il contorno nero spesso, sotto l'ombra
	# di un altro colore spostata, sopra il pieno
	var f := font if font != null else Caratteri.titolo()
	if ombra.a > 0.0:
		t.draw_string_outline(f, dove + spostamento, testo, allinea, largo, corpo, spessore, ombra)
		t.draw_string(f, dove + spostamento, testo, allinea, largo, corpo, ombra)
	if spessore > 0:
		t.draw_string_outline(f, dove, testo, allinea, largo, corpo, spessore, contorno)
	t.draw_string(f, dove, testo, allinea, largo, corpo, tinta)


static func a_capo(t: CanvasItem, r: Rect2, testo: String, corpo: int, tinta: Color, font: Font = null,
		allinea := HORIZONTAL_ALIGNMENT_LEFT, righe := -1) -> void:
	var f := font if font != null else Caratteri.tondo(700)
	t.draw_multiline_string(f, r.position + Vector2(0, f.get_ascent(corpo)), testo, allinea, r.size.x, corpo, righe, tinta)


static func scritta_larga(t: CanvasItem, dove: Vector2, testo: String, corpo: int, tinta: Color, font: Font = null) -> float:
	# la scritta, e quanto e' larga: per metterci accanto la prossima
	scritta(t, dove, testo, corpo, tinta, font)
	return larghezza(testo, corpo, font)


static func larghezza(testo: String, corpo: int, font: Font = null) -> float:
	var f := font if font != null else Caratteri.titolo()
	return f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x


static func corpo_che_entra(testo: String, corpo: int, largo: float, font: Font = null) -> int:
	# il corpo piu' grande, fino a corpo, con cui la scritta sta in largo
	var c := corpo
	while c > 9 and larghezza(testo, c, font) > largo:
		c -= 1
	return c


static func etichetta(t: CanvasItem, dove: Vector2, testo: String, corpo: int, fondo := NERO, inchiostro := CREMA,
		sfoglia := Color(0, 0, 0, 0)) -> float:
	# la fascia storta con la scritta: restituisce quanto e' larga
	var alto := corpo * 1.35
	var largo := larghezza(testo, corpo) + corpo * 1.1
	fascia(t, Rect2(dove, Vector2(largo, alto)), fondo, sfoglia)
	scritta(t, dove + Vector2(corpo * 0.55, alto * 0.5 + corpo * 0.36), testo, corpo, inchiostro)
	return largo
