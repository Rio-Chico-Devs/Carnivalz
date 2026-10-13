extends RefCounted

# I PEZZI DISEGNATI DELLE PROPOSTE DI CRESCITA (prove/ProposteCrescita.gd).
# Provvisorio come loro. Il luna park e' quello del menu (LunaPark.gd) rifatto
# a pezzi spostabili: la ruota, il tendone, le lampadine, i fili che pendono.
# Il resto e' la lingua del manifesto: cartoncini col contorno nero e l'ombra
# piena, scritte ritagliate, fasce storte, niente sfumature sulle cose (le
# sfumature solo nel cielo, come nel menu).

const NERO := Color("#0b0908")
const CREMA := Color("#ece6df")
const CARTA := Color("#d8cfc7")
const ARANCIO := Color("#f4931b")
const ARANCIO_SCURO := Color("#c96f12")
const BRUNO := Color("#2a211a")
const LUCE := Color("#fff1dd")
const OMBRA := Vector2(8, 8)


# --- girare e tornare dritti ---------------------------------------------------------

static func gira(t: CanvasItem, perno: Vector2, gradi: float, scala := 1.0) -> void:
	t.draw_set_transform(perno, deg_to_rad(gradi), Vector2(scala, scala))


static func dritto(t: CanvasItem) -> void:
	t.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# --- il cielo e il luna park -----------------------------------------------------------

static func cielo(t: CanvasItem, tinte: Array, quote: Array) -> void:
	# fasce di colore una sotto l'altra: tinte[i] a quote[i], sfumate fra loro
	for i in tinte.size() - 1:
		var da := float(quote[i])
		var a := float(quote[i + 1])
		t.draw_polygon(PackedVector2Array([Vector2(-20, da), Vector2(1300, da), Vector2(1300, a), Vector2(-20, a)]),
				PackedColorArray([tinte[i], tinte[i], tinte[i + 1], tinte[i + 1]]))


static func stelline(t: CanvasItem, area: Rect2, quante: int, seme: int, tempo: float) -> void:
	var dado := RandomNumberGenerator.new()
	dado.seed = seme
	for i in quante:
		var p := Vector2(dado.randf_range(area.position.x, area.end.x), dado.randf_range(area.position.y, area.end.y))
		var forza := dado.randf_range(0.25, 0.8) * (0.7 + 0.3 * sin(tempo * 1.3 + i * 2.1))
		var lato := 2.0 if dado.randf() < 0.85 else 3.0
		t.draw_rect(Rect2(p, Vector2(lato, lato)), Color(CARTA, forza * (1.0 - (p.y - area.position.y) / area.size.y * 0.6)))


static func luna(t: CanvasItem, c: Vector2, r: float) -> void:
	for anello: Array in [[3.6, 0.03], [2.6, 0.05], [1.9, 0.08], [1.35, 0.14]]:
		t.draw_circle(c, r * float(anello[0]), Color(CARTA, float(anello[1])), true, -1.0, true)
	t.draw_circle(c, r, Color(CARTA, 0.95), true, -1.0, true)
	for macchia: Vector3 in [Vector3(-0.3, -0.2, 0.22), Vector3(0.28, 0.12, 0.16), Vector3(-0.1, 0.36, 0.11)]:
		t.draw_circle(c + Vector2(macchia.x, macchia.y) * r, macchia.z * r, Color(ARANCIO_SCURO, 0.14), true, -1.0, true)


static func colline(t: CanvasItem, y: float, onda: float, tinta: Color) -> void:
	var punti := PackedVector2Array()
	var x := -40.0
	while x <= 1320.0:
		punti.append(Vector2(x, y + onda * sin(x * 0.006) + onda * 0.5 * sin(x * 0.017 + 1.0)))
		x += 40.0
	punti.append(Vector2(1320, 760))
	punti.append(Vector2(-40, 760))
	Manifesto.poligono(t, punti, tinta)


static func nebbia(t: CanvasItem, y: float, alta: float, forza: float, tinta: Color) -> void:
	var nulla := Color(tinta, 0.0)
	var piena := Color(tinta, forza)
	cielo(t, [nulla, piena, nulla], [y - alta, y, y + alta])


static func lampadina(t: CanvasItem, dove: Vector2, luce: float, raggio := 2.6) -> void:
	# luce 0 = spenta (si vede il vetro), 1 = accesa col suo alone
	if luce <= 0.05:
		t.draw_circle(dove, raggio, BRUNO, true, -1.0, true)
		t.draw_circle(dove + Vector2(-raggio * 0.3, -raggio * 0.3), raggio * 0.35, Color(CARTA, 0.35), true, -1.0, true)
		return
	t.draw_circle(dove, raggio * 3.2, Color(LUCE, 0.10 * luce), true, -1.0, true)
	t.draw_circle(dove, raggio * 1.9, Color(ARANCIO, 0.22 * luce), true, -1.0, true)
	t.draw_circle(dove, raggio, Color(LUCE, 0.35 + 0.6 * luce), true, -1.0, true)


static func catena(da: Vector2, a: Vector2, pancia: float, quanti := 24) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in quanti + 1:
		var k := float(i) / quanti
		p.append(da.lerp(a, k) + Vector2(0, pancia * 4.0 * k * (1.0 - k)))
	return p


static func filo(t: CanvasItem, da: Vector2, a: Vector2, pancia: float, luce: float, tempo: float, inseguono := false,
		filo_tinta := Color(0, 0, 0, 0)) -> void:
	# un filo di lampadine che pende fra due punti. "inseguono": le lampadine si
	# accendono una dopo l'altra verso "a", come le luci che chiamano dentro
	var tratto := catena(da, a, pancia)
	t.draw_polyline(tratto, filo_tinta if filo_tinta.a > 0.0 else Color(NERO, 0.9), 2.0, true)
	var lungo := da.distance_to(a)
	var quante := maxi(int(lungo / 20.0), 2)
	for i in range(1, quante):
		var k := float(i) / quante
		var dove := da.lerp(a, k) + Vector2(0, pancia * 4.0 * k * (1.0 - k)) + Vector2(0, 3)
		var accesa := luce
		if inseguono:
			accesa = 0.25 + 0.75 * maxf(0.0, sin(tempo * 4.0 - k * 9.0))
		lampadina(t, dove, accesa, 2.8)


static func ruota(t: CanvasItem, c: Vector2, r: float, giro: float, tinta: Color, tempo: float, cabine := 16,
		con_cabine := true) -> void:
	t.draw_line(c, c + Vector2(-r * 0.55, r * 1.55), tinta, r * 0.06, true)
	t.draw_line(c, c + Vector2(r * 0.55, r * 1.55), tinta, r * 0.06, true)
	t.draw_line(c + Vector2(-r * 0.42, r * 1.2), c + Vector2(r * 0.42, r * 1.2), tinta, r * 0.03)
	t.draw_arc(c, r, 0.0, TAU, 128, tinta, maxf(r * 0.035, 3.0), true)
	t.draw_arc(c, r * 0.9, 0.0, TAU, 128, tinta, maxf(r * 0.015, 2.0), true)
	t.draw_arc(c, r * 0.2, 0.0, TAU, 48, tinta, maxf(r * 0.025, 2.0), true)
	t.draw_circle(c, r * 0.07, tinta, true, -1.0, true)
	for i in cabine:
		var angolo := giro + TAU * float(i) / cabine
		var bordo := c + Vector2.from_angle(angolo) * r
		t.draw_line(c + Vector2.from_angle(angolo) * r * 0.07, bordo, tinta, maxf(r * 0.014, 1.5), true)
		if con_cabine:
			t.draw_line(bordo, bordo + Vector2(0, r * 0.05), tinta, 2.0)
			t.draw_rect(Rect2(bordo + Vector2(-r * 0.055, r * 0.05), Vector2(r * 0.11, r * 0.085)), tinta)
	for j in 40:
		lampadina(t, c + Vector2.from_angle(giro + TAU * j / 40.0) * r, 0.7 + 0.3 * sin(tempo * 2.1 + j * 1.7), 2.6)


static func tendone(t: CanvasItem, cima: Vector2, mezza: float, gronda: float, scura: Color, chiara: Color, tempo: float) -> void:
	var spicchi := 8
	for i in spicchi:
		var da := lerpf(cima.x - mezza, cima.x + mezza, float(i) / spicchi)
		var a := lerpf(cima.x - mezza, cima.x + mezza, float(i + 1) / spicchi)
		Manifesto.poligono(t, PackedVector2Array([cima, Vector2(a, gronda), Vector2(da, gronda)]), chiara if i % 2 == 0 else scura)
	var x := cima.x - mezza + 10.0
	while x <= cima.x + mezza - 10.0:
		t.draw_circle(Vector2(x, gronda), 14.0, scura, true, -1.0, true)
		x += 30.0
	t.draw_rect(Rect2(cima.x - mezza + 20, gronda, mezza * 2.0 - 40, 140), scura)
	for k in 6:
		t.draw_rect(Rect2(cima.x - mezza + 36 + k * (mezza * 2.0 - 72) / 6.0, gronda + 14, 20, 130), chiara)
	t.draw_line(cima, cima + Vector2(0, -44), scura, 3.0)
	Manifesto.poligono(t, PackedVector2Array([cima + Vector2(0, -44), cima + Vector2(30, -36), cima + Vector2(0, -28)]), CARTA.darkened(0.35))
	for passo in 9:
		var k := float(passo + 1) / 10.0
		lampadina(t, cima.lerp(Vector2(cima.x - mezza, gronda), k), 0.7 + 0.3 * sin(tempo * 2.1 + passo * 1.7))
		lampadina(t, cima.lerp(Vector2(cima.x + mezza, gronda), k), 0.7 + 0.3 * sin(tempo * 2.1 + passo * 1.7 + 3.0))


static func terra(t: CanvasItem, y: float, tinta: Color, steccato := true) -> void:
	var punti := PackedVector2Array([Vector2(-40, y + 4)])
	var x := -40.0
	while x <= 1320.0:
		punti.append(Vector2(x, y + 5.0 * sin(x * 0.02)))
		x += 60.0
	punti.append(Vector2(1320, 760))
	punti.append(Vector2(-40, 760))
	Manifesto.poligono(t, punti, tinta)
	if not steccato:
		return
	var palo := -20.0
	while palo <= 1300.0:
		t.draw_rect(Rect2(palo, y - 44, 8, 48), tinta)
		var corda := catena(Vector2(palo + 4, y - 36), Vector2(palo + 60, y - 36), 10.0, 8)
		t.draw_polyline(corda, tinta, 3.0, true)
		palo += 56.0


# --- la carta, le scritte, le forme ---------------------------------------------------

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
		allinea := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var f := font if font != null else Caratteri.tondo(700)
	t.draw_multiline_string(f, r.position + Vector2(0, f.get_ascent(corpo)), testo, allinea, r.size.x, corpo, -1, tinta)


static func larghezza(testo: String, corpo: int, font: Font = null) -> float:
	var f := font if font != null else Caratteri.titolo()
	return f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x


static func etichetta(t: CanvasItem, dove: Vector2, testo: String, corpo: int, fondo := NERO, inchiostro := CREMA,
		sfoglia := Color(0, 0, 0, 0)) -> float:
	# la fascia storta con la scritta: restituisce quanto e' larga
	var alto := corpo * 1.35
	var largo := larghezza(testo, corpo) + corpo * 1.1
	fascia(t, Rect2(dove, Vector2(largo, alto)), fondo, sfoglia)
	scritta(t, dove + Vector2(corpo * 0.55, alto * 0.5 + corpo * 0.36), testo, corpo, inchiostro)
	return largo


static func raggi(t: CanvasItem, c: Vector2, quanti: int, lungo: float, a: Color, b: Color, rotazione: float) -> void:
	for i in quanti:
		var a0 := rotazione + TAU * float(i) / quanti
		var a1 := rotazione + TAU * float(i + 1) / quanti
		t.draw_colored_polygon(PackedVector2Array([c, c + Vector2.from_angle(a0) * lungo, c + Vector2.from_angle(a1) * lungo]),
				a if i % 2 == 0 else b)


static func scoppio(t: CanvasItem, c: Vector2, fuori: float, dentro: float, punte: int, tinta: Color, contorno := NERO,
		spessore := 5.0, giro := 0.0) -> void:
	var p := PackedVector2Array()
	for i in punte * 2:
		var a := giro - PI * 0.5 + PI * float(i) / punte
		var r := fuori if i % 2 == 0 else dentro
		p.append(c + Vector2.from_angle(a) * r)
	if spessore > 0.0:
		var largo := PackedVector2Array()
		for q in p:
			largo.append(c + (q - c) * (1.0 + spessore / fuori))
		Manifesto.poligono(t, largo, contorno)
	Manifesto.poligono(t, p, tinta)


static func scintilla(t: CanvasItem, c: Vector2, r: float, tinta: Color) -> void:
	Manifesto.poligono(t, Sagome.stella(c, r, r * 0.28, 4), tinta)


static func biglietto(t: CanvasItem, r: Rect2, tinta: Color, testo: String, sotto := "", corpo := 18) -> void:
	# il biglietto del luna park: le tacche ai lati, la linea da strappare
	t.draw_rect(Rect2(r.position + Vector2(5, 5), r.size), NERO)
	t.draw_rect(r, tinta)
	t.draw_rect(r.grow(-2.0), NERO, false, 3.0)
	var taglio := r.position.x + r.size.x * 0.74
	t.draw_dashed_line(Vector2(taglio, r.position.y + 6), Vector2(taglio, r.end.y - 6), NERO, 2.0, 5.0)
	for lato in [r.position.x, r.end.x]:
		t.draw_circle(Vector2(lato, r.get_center().y), r.size.y * 0.16, NERO, true, -1.0, true)
	scritta(t, Vector2(r.position.x + 12, r.position.y + r.size.y * 0.5 + corpo * 0.3 - (6.0 if sotto != "" else 0.0)), testo, corpo, NERO)
	if sotto != "":
		scritta(t, Vector2(r.position.x + 12, r.position.y + r.size.y * 0.5 + corpo * 0.3 + 12), sotto, 11, Color(NERO, 0.75),
				Caratteri.tondo(900))


# --- i disegni delle abilita' ---------------------------------------------------------

static func glifo(t: CanvasItem, quale: String, c: Vector2, l: float, tinta: Color, fondo := CREMA) -> void:
	match quale:
		"aghi":
			for i in 11:
				var a := -PI * 0.5 + (float(i) - 5.0) * 0.22
				var dir := Vector2.from_angle(a)
				Manifesto.poligono(t, PackedVector2Array([c + dir * l * 0.08 + dir.orthogonal() * l * 0.03,
						c + dir * l * 0.48, c + dir * l * 0.08 - dir.orthogonal() * l * 0.03]), tinta)
			t.draw_circle(c + Vector2(0, l * 0.12), l * 0.12, tinta, true, -1.0, true)
		"fiamma":
			Manifesto.poligono(t, PackedVector2Array([c + Vector2(0, -l * 0.48), c + Vector2(l * 0.16, -l * 0.18),
					c + Vector2(l * 0.3, -l * 0.3), c + Vector2(l * 0.32, l * 0.08), c + Vector2(l * 0.18, l * 0.36),
					c + Vector2(-l * 0.18, l * 0.36), c + Vector2(-l * 0.32, l * 0.06), c + Vector2(-l * 0.2, -l * 0.16)]), tinta)
			Manifesto.poligono(t, PackedVector2Array([c + Vector2(0, -l * 0.08), c + Vector2(l * 0.12, l * 0.14),
					c + Vector2(l * 0.06, l * 0.3), c + Vector2(-l * 0.06, l * 0.3), c + Vector2(-l * 0.12, l * 0.14)]), fondo)
		"spirale":
			var p := PackedVector2Array()
			for i in 60:
				var k := float(i) / 59.0
				p.append(c + Vector2.from_angle(k * TAU * 2.2) * l * (0.04 + 0.42 * k))
			t.draw_polyline(p, tinta, l * 0.08, true)
		"vuoto":
			t.draw_circle(c, l * 0.42, tinta, true, -1.0, true)
			t.draw_circle(c, l * 0.26, fondo, true, -1.0, true)
			t.draw_circle(c, l * 0.15, tinta, true, -1.0, true)
			t.draw_line(c + Vector2(-l * 0.46, l * 0.46), c + Vector2(l * 0.46, -l * 0.46), tinta, l * 0.07, true)
		"loto":
			for k in 5:
				var a := -PI * 0.5 + (k - 2) * 0.42
				var punta := c + Vector2(0, l * 0.22) + Vector2.from_angle(a) * l * 0.5
				Manifesto.poligono(t, PackedVector2Array([c + Vector2(0, l * 0.22), punta + Vector2.from_angle(a + 1.2) * l * 0.12,
						punta, punta + Vector2.from_angle(a - 1.2) * l * 0.12]), tinta)
			t.draw_line(c + Vector2(-l * 0.4, l * 0.34), c + Vector2(l * 0.4, l * 0.34), tinta, l * 0.06, true)
		"saetta":
			Manifesto.poligono(t, Sagome.fulmine(c, l * 1.1), tinta)
		"cuore":
			Sagome.cuore(t, c, l * 1.1, tinta)
		"lama":
			Manifesto.poligono(t, PackedVector2Array([c + Vector2(l * 0.36, -l * 0.42), c + Vector2(l * 0.44, -l * 0.34),
					c + Vector2(-l * 0.12, l * 0.2), c + Vector2(-l * 0.2, l * 0.12)]), tinta)
			t.draw_line(c + Vector2(-l * 0.32, l * 0.04), c + Vector2(-l * 0.04, l * 0.32), tinta, l * 0.08, true)
			t.draw_line(c + Vector2(-l * 0.18, l * 0.18), c + Vector2(-l * 0.36, l * 0.36), tinta, l * 0.1, true)
		"fuoco_interno":
			scoppio(t, c, l * 0.46, l * 0.2, 8, tinta, NERO, 0.0)
			t.draw_circle(c, l * 0.14, fondo, true, -1.0, true)
		"occhio":
			Sagome.occhio(t, c, l, tinta, fondo)
		"clessidra":
			Manifesto.poligono(t, PackedVector2Array([c + Vector2(-l * 0.3, -l * 0.42), c + Vector2(l * 0.3, -l * 0.42),
					c + Vector2(l * 0.04, 0), c + Vector2(l * 0.3, l * 0.42), c + Vector2(-l * 0.3, l * 0.42),
					c + Vector2(-l * 0.04, 0)]), tinta)
			Manifesto.poligono(t, PackedVector2Array([c + Vector2(-l * 0.16, l * 0.36), c + Vector2(l * 0.16, l * 0.36),
					c + Vector2(0, l * 0.16)]), fondo)
			t.draw_rect(Rect2(c + Vector2(-l * 0.38, -l * 0.5), Vector2(l * 0.76, l * 0.08)), tinta)
			t.draw_rect(Rect2(c + Vector2(-l * 0.38, l * 0.42), Vector2(l * 0.76, l * 0.08)), tinta)
		"gemma":
			Manifesto.poligono(t, PackedVector2Array([c + Vector2(-l * 0.4, -l * 0.12), c + Vector2(-l * 0.22, -l * 0.34),
					c + Vector2(l * 0.22, -l * 0.34), c + Vector2(l * 0.4, -l * 0.12), c + Vector2(0, l * 0.42)]), tinta)
			t.draw_line(c + Vector2(-l * 0.4, -l * 0.12), c + Vector2(l * 0.4, -l * 0.12), fondo, l * 0.04, true)
			t.draw_line(c + Vector2(-l * 0.1, -l * 0.12), c + Vector2(0, l * 0.36), fondo, l * 0.03, true)
			t.draw_line(c + Vector2(l * 0.1, -l * 0.12), c + Vector2(0, l * 0.36), fondo, l * 0.03, true)
		"battito":
			Sagome.cuore(t, c, l * 1.1, tinta)
			t.draw_polyline(PackedVector2Array([c + Vector2(-l * 0.5, 0), c + Vector2(-l * 0.16, 0), c + Vector2(-l * 0.06, -l * 0.18),
					c + Vector2(l * 0.06, l * 0.16), c + Vector2(l * 0.14, 0), c + Vector2(l * 0.5, 0)]), fondo, l * 0.06, true)
		"tre":
			for k in 3:
				var dir := Vector2.from_angle(-PI * 0.5 + TAU * k / 3.0)
				Manifesto.poligono(t, PackedVector2Array([c + dir * l * 0.46, c + dir.orthogonal() * l * 0.1,
						c - dir.orthogonal() * l * 0.1]), tinta)
			t.draw_circle(c, l * 0.1, tinta, true, -1.0, true)
		_:
			scintilla(t, c, l * 0.45, tinta)
