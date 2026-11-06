extends RefCounted
# COME SI DISEGNA LA RACCOLTA (prove/RaccoltaProva.gd). Provvisorio come lei.
#
# Il pianeta visto dall'alto, un po' di sbieco: i campi sono altipiani dal
# bordo storto, con la parete di roccia sotto, e intorno il buio del Vuoto. Gli
# inchiostri sono quelli del Vuoto (il buio, la luce della carta, l'arancio
# per quello che si puo' fare), con la terra calda del pianeta in mezzo.
# Il personaggio e' un segnaposto a forme, come le Sagome: il disegno vero
# arrivera' da Bru.

const VUOTO := Color("#0b0e14")
const INK := Color("#1a1720")
const TERRA := Color("#e6c995")
const TERRA_CHIARA := Color("#f3e2bd")
const TERRA_SCURA := Color("#c9a56a")
const RUPE := Color("#9a6a3c")
const RUPE_SCURA := Color("#6e4724")
const NEBBIA := Color("#121826")
const LINEA := Color("#4a7aa8")
const CARTA := Color("#efd8b2")
const ARANCIO := Color("#f29a2e")
const LEGNO := Color("#8a5a32")
const LEGNO_CHIARO := Color("#b98250")
const PIETRA := Color("#8d8f99")
const ALTEZZA := 26.0          # quanto e' alta la parete di roccia sotto un campo
const TINTE_RISORSA := {"quarzo": [Color("#f7f1e3"), Color("#d6c9ad")], "ferro": [Color("#8796ab"), Color("#5b6b80")],
		"cristallo": [Color("#ff5d73"), Color("#b51f3a")], "tazo": [Color("#ffd23a"), Color("#c98d10")]}


static func zolla(centro: Vector2, raggi: Vector2, seme: float) -> PackedVector2Array:
	# il contorno storto di un campo, sempre lo stesso per lo stesso seme
	var punti := PackedVector2Array()
	for i in 64:
		var a := TAU * float(i) / 64.0
		var r := 1.0 + 0.07 * sin(3.0 * a + seme) + 0.05 * sin(5.0 * a + seme * 2.3)
		punti.append(centro + Vector2(cos(a) * raggi.x, sin(a) * raggi.y) * r)
	return punti


static func chiuso(punti: PackedVector2Array) -> PackedVector2Array:
	var giro := punti.duplicate()
	giro.append(punti[0])
	return giro


static func vuoto(tela: CanvasItem, dove: Rect2, stelle: PackedVector2Array) -> void:
	tela.draw_rect(dove, VUOTO)
	for k in stelle.size():
		tela.draw_circle(stelle[k], 1.0 + float(k % 3) * 0.5, Color(CARTA, 0.25 + 0.2 * float(k % 2)))


static func zona(tela: CanvasItem, sopra: PackedVector2Array, ciottoli: PackedVector2Array) -> void:
	# prima la parete di roccia, poi il piano
	var sotto := PackedVector2Array()
	for p in sopra:
		sotto.append(p + Vector2(0, ALTEZZA))
	tela.draw_colored_polygon(sotto, RUPE)
	var mezzo := 0.0
	for p in sopra:
		mezzo += p.y / float(sopra.size())
	for i in sopra.size():
		var j := (i + 1) % sopra.size()
		tela.draw_colored_polygon(PackedVector2Array([sopra[i], sopra[j], sotto[j], sotto[i]]), RUPE)
		if i % 3 == 0 and sopra[i].y > mezzo:
			tela.draw_line(sopra[i] + Vector2(0, 4), sotto[i] - Vector2(0, 3), RUPE_SCURA, 2.0)
	tela.draw_polyline(chiuso(sotto), INK, 2.5, true)
	tela.draw_colored_polygon(sopra, TERRA)
	for k in ciottoli.size():
		var c := ciottoli[k]
		if k % 6 == 0:
			tela.draw_circle(c, 10.0 + float(k % 5) * 2.0, Color(TERRA_CHIARA, 0.45))
		else:
			ovale(tela, c, Vector2(4.0 + float(k % 3), 2.5 + float(k % 2)), TERRA_SCURA, false)
	tela.draw_polyline(chiuso(sopra), INK, 3.0, true)


static func nebbia(tela: CanvasItem, poligono: PackedVector2Array, puntini: PackedVector2Array, da: Vector2,
		raggio: float) -> void:
	# QUELLO CHE NON SAI ANCORA: buio e retino, come il Vuoto. Quando un
	# passaggio si apre, la nebbia si ritira in un cerchio che parte da li'
	var pezzi: Array[PackedVector2Array] = [poligono]
	if raggio > 1.0:
		var cerchio := PackedVector2Array()
		for i in 48:
			cerchio.append(da + Vector2.from_angle(TAU * float(i) / 48.0) * raggio)
		pezzi.clear()
		for pezzo in Geometry2D.clip_polygons(poligono, cerchio):
			if not Geometry2D.is_polygon_clockwise(pezzo):
				pezzi.append(pezzo)
	for pezzo in pezzi:
		tela.draw_colored_polygon(pezzo, Color(NEBBIA, 0.96))
		tela.draw_polyline(chiuso(pezzo), Color(LINEA, 0.5), 1.5, true)
	for p in puntini:
		if raggio > 1.0 and p.distance_to(da) < raggio:
			continue
		tela.draw_circle(p, 1.6, Color(LINEA, 0.45))


static func ponte(tela: CanvasItem, da: Vector2, a: Vector2, largo: float, quanto: float) -> void:
	# rotto: restano le corde e due assi per parte. Riparandolo, le assi
	# arrivano una alla volta da questa parte all'altra
	var verso := (a - da).normalized()
	var lato := verso.orthogonal() * largo * 0.5
	var lungo := da.distance_to(a)
	var assi := int(lungo / 15.0)
	for k in assi:
		var f := (float(k) + 0.5) / float(assi)
		var ai_capi := k < 2 or k >= assi - 2     # le assi ai due capi non sono mai cadute
		if not ai_capi and f >= quanto:
			continue
		var p := da.lerp(a, f) + Vector2(0, 6)
		var asse := PackedVector2Array([p - lato - verso * 6.0, p - lato + verso * 6.0, p + lato + verso * 6.0,
				p + lato - verso * 6.0])
		tela.draw_colored_polygon(asse, LEGNO_CHIARO if k % 2 == 0 else LEGNO)
		tela.draw_polyline(chiuso(asse), INK, 1.5, true)
	for s: float in [-1.0, 1.0]:
		var corda_da := da + lato * s * 1.1 + Vector2(0, -6)
		var corda_a := a + lato * s * 1.1 + Vector2(0, -6)
		if quanto < 1.0:
			# la corda e' spezzata a meta': pende
			var mezzo := corda_da.lerp(corda_a, 0.5)
			tela.draw_polyline(PackedVector2Array([corda_da, corda_da.lerp(mezzo, 0.5) + Vector2(0, 10), mezzo + Vector2(-6, 40)]),
					LEGNO, 3.0, true)
			tela.draw_polyline(PackedVector2Array([corda_a, corda_a.lerp(mezzo, 0.5) + Vector2(0, 12), mezzo + Vector2(8, 46)]),
					LEGNO, 3.0, true)
		else:
			tela.draw_polyline(PackedVector2Array([corda_da, corda_da.lerp(corda_a, 0.5) + Vector2(0, 8), corda_a]), LEGNO, 3.0, true)
		for estremo: Vector2 in [corda_da, corda_a]:
			tela.draw_rect(Rect2(estremo + Vector2(-4, -10), Vector2(8, 20)), LEGNO)
			tela.draw_rect(Rect2(estremo + Vector2(-4, -10), Vector2(8, 20)), INK, false, 1.5)


static func passerella(tela: CanvasItem, poligono: PackedVector2Array, campi: Array) -> void:
	# UNA LINGUA DI ROCCIA fra due campi: solo il pezzo che sta nel vuoto, con
	# la sua parete sotto come i campi. I capi spariscono sotto i campi
	var pezzi: Array[PackedVector2Array] = [poligono]
	for campo: PackedVector2Array in campi:
		var restano: Array[PackedVector2Array] = []
		for pezzo in pezzi:
			for resto in Geometry2D.clip_polygons(pezzo, campo):
				if not Geometry2D.is_polygon_clockwise(resto):
					restano.append(resto)
		pezzi = restano
	for pezzo in pezzi:
		var sotto := PackedVector2Array()
		for p in pezzo:
			sotto.append(p + Vector2(0, ALTEZZA))
		tela.draw_colored_polygon(sotto, RUPE)
		for i in pezzo.size():
			var j := (i + 1) % pezzo.size()
			tela.draw_colored_polygon(PackedVector2Array([pezzo[i], pezzo[j], sotto[j], sotto[i]]), RUPE)
		tela.draw_polyline(chiuso(sotto), INK, 2.5, true)
		tela.draw_colored_polygon(pezzo, TERRA)
		tela.draw_polyline(chiuso(pezzo), INK, 3.0, true)


static func cancello(tela: CanvasItem, dove: Vector2, verso: Vector2, largo: float, aperto: float) -> void:
	# due pilastri e le sbarre. Aperto, le sbarre si ritirano nei pilastri
	var lato := verso.orthogonal() * largo * 0.55
	for s: float in [-1.0, 1.0]:
		var base := dove + lato * s
		tela.draw_rect(Rect2(base + Vector2(-9, -34), Vector2(18, 38)), PIETRA)
		tela.draw_rect(Rect2(base + Vector2(-9, -34), Vector2(18, 38)), INK, false, 2.0)
		tela.draw_rect(Rect2(base + Vector2(-11, -40), Vector2(22, 8)), Color("#a9abb4"))
		tela.draw_rect(Rect2(base + Vector2(-11, -40), Vector2(22, 8)), INK, false, 2.0)
	var chiusura := 1.0 - aperto
	if chiusura <= 0.0:
		return
	for k in 5:
		var f := float(k + 1) / 6.0
		var su := (dove - lato).lerp(dove + lato, f)
		var x_sbarra := (dove - lato).lerp(su, chiusura)
		tela.draw_line(x_sbarra + Vector2(0, -28), x_sbarra + Vector2(0, 2), INK, 4.0)
		tela.draw_line(x_sbarra + Vector2(0, -28), x_sbarra + Vector2(0, 2), Color("#c9ccd4"), 2.0)
	tela.draw_line(dove - lato + Vector2(0, -22), (dove - lato).lerp(dove + lato, chiusura) + Vector2(0, -22), INK, 3.0)


static func vena(tela: CanvasItem, p: Vector2, quale: String, carica: float, t: float) -> void:
	# piena: i cristalli alti e la scintilla arancio. Vuota: mozziconi, e il
	# giro che si riempie intanto che ricresce
	var tinte: Array = TINTE_RISORSA.get(quale, TINTE_RISORSA["quarzo"])
	var pronta := carica >= 1.0
	ovale(tela, p + Vector2(0, 4), Vector2(26, 9), Color(0, 0, 0, 0.18), false)
	if not pronta:
		tela.draw_arc(p + Vector2(0, 4), 24.0, 0.0, TAU, 40, Color(INK, 0.25), 3.0, true)
		tela.draw_arc(p + Vector2(0, 4), 24.0, -PI * 0.5, -PI * 0.5 + TAU * carica, 40, LINEA, 3.0, true)
	var alti := [22.0, 32.0, 18.0, 26.0]
	var posti := [Vector2(-14, 2), Vector2(-3, -2), Vector2(9, 3), Vector2(16, -1)]
	for k in 4:
		var alto: float = alti[k] * (1.0 if pronta else 0.35 + 0.25 * carica)
		var b: Vector2 = p + (posti[k] as Vector2)
		cristallo(tela, b, alto, 6.0, tinte[0], tinte[1], quale == "ferro")
	if pronta:
		var batte := 0.75 + 0.25 * sin(t * 4.0 + p.x)
		stella(tela, p + Vector2(6, -40), 7.0 * batte, ARANCIO)


static func cristallo(tela: CanvasItem, base: Vector2, alto: float, largo: float, chiaro: Color, scuro: Color,
		tozzo: bool) -> void:
	var forma := PackedVector2Array([base + Vector2(-largo, 0), base + Vector2(-largo, -alto * 0.7),
			base + Vector2(0, -alto), base + Vector2(largo, -alto * 0.7), base + Vector2(largo, 0)])
	if tozzo:
		forma = PackedVector2Array([base + Vector2(-largo * 1.3, 0), base + Vector2(-largo * 1.1, -alto * 0.6),
				base + Vector2(0, -alto * 0.75), base + Vector2(largo * 1.2, -alto * 0.5), base + Vector2(largo * 1.3, 0)])
	tela.draw_colored_polygon(forma, chiaro)
	tela.draw_colored_polygon(PackedVector2Array([forma[2], forma[3], forma[4], base]), scuro)
	tela.draw_polyline(chiuso(forma), INK, 2.0, true)


static func modulo(tela: CanvasItem, p: Vector2, t: float) -> void:
	# il modulo d'atterraggio: da qui quello che raccogli parte per le riserve
	ovale(tela, p + Vector2(0, 6), Vector2(48, 13), Color(0, 0, 0, 0.2), false)
	for x: float in [-34.0, 34.0, -14.0, 14.0]:
		tela.draw_line(p + Vector2(x * 0.6, -24), p + Vector2(x, 4), INK, 4.0, true)
	var corpo := Rect2(p + Vector2(-34, -44), Vector2(68, 26))
	tela.draw_rect(corpo, CARTA)
	tela.draw_rect(corpo, INK, false, 2.5)
	tela.draw_colored_polygon(semicerchio(p + Vector2(0, -44), 30.0), CARTA)
	tela.draw_polyline(semicerchio(p + Vector2(0, -44), 30.0), INK, 2.5, true)
	tela.draw_circle(p + Vector2(0, -50), 9.0, INK)
	tela.draw_circle(p + Vector2(0, -50), 6.5, LINEA)
	tela.draw_line(p + Vector2(18, -66), p + Vector2(26, -86), INK, 2.0)
	tela.draw_circle(p + Vector2(26, -86), 4.0, ARANCIO if fmod(t, 1.4) < 0.9 else Color(ARANCIO, 0.3))
	tela.draw_rect(Rect2(p + Vector2(-30, -30), Vector2(60, 4)), ARANCIO)


static func trivella(tela: CanvasItem, p: Vector2, costruita: bool, scorta: int, tiene: int, t: float) -> void:
	if not costruita:
		# la piazzola: il posto c'e', la macchina no
		for k in 16:
			if k % 2 == 0:
				tela.draw_arc(p, 30.0, TAU * float(k) / 16.0, TAU * float(k + 1) / 16.0, 6, INK, 2.5, true)
		tela.draw_line(p + Vector2(-9, 0), p + Vector2(9, 0), INK, 3.0)
		tela.draw_line(p + Vector2(0, -9), p + Vector2(0, 9), INK, 3.0)
		return
	ovale(tela, p + Vector2(0, 6), Vector2(34, 10), Color(0, 0, 0, 0.2), false)
	var cima := p + Vector2(0, -70)
	for piede: Vector2 in [Vector2(-28, 4), Vector2(28, 4), Vector2(0, 10)]:
		tela.draw_line(cima, p + piede, INK, 5.0, true)
		tela.draw_line(cima, p + piede, LEGNO_CHIARO, 2.5, true)
	# la punta gira: tre righe che scorrono
	var punta := PackedVector2Array([p + Vector2(-7, -36), p + Vector2(7, -36), p + Vector2(0, -6)])
	tela.draw_colored_polygon(punta, Color("#c9ccd4"))
	tela.draw_polyline(chiuso(punta), INK, 2.0, true)
	for k in 3:
		var y := -32.0 + fmod(t * 40.0 + 9.0 * float(k), 26.0)
		var mezzo := (32.0 + y) / 26.0
		tela.draw_line(p + Vector2(-7.0 * (1.0 - mezzo), y), p + Vector2(7.0 * (1.0 - mezzo), y + 3.0), INK, 1.5)
	var scatola := Rect2(p + Vector2(-52, -40), Vector2(26, 30))
	tela.draw_rect(scatola, CARTA)
	tela.draw_rect(Rect2(scatola.position.x, scatola.end.y - scatola.size.y * float(scorta) / float(tiene), scatola.size.x,
			scatola.size.y * float(scorta) / float(tiene)), ARANCIO)
	tela.draw_rect(scatola, INK, false, 2.0)
	if scorta >= tiene:
		stella(tela, scatola.position + Vector2(scatola.size.x * 0.5, -10), 7.0, ARANCIO)


static func forziere(tela: CanvasItem, p: Vector2, aperto: bool, t: float) -> void:
	ovale(tela, p + Vector2(0, 4), Vector2(28, 8), Color(0, 0, 0, 0.2), false)
	var cassa := Rect2(p + Vector2(-24, -26), Vector2(48, 28))
	tela.draw_rect(cassa, LEGNO)
	tela.draw_rect(Rect2(cassa.position + Vector2(0, 10), Vector2(48, 6)), ARANCIO)
	tela.draw_rect(cassa, INK, false, 2.5)
	if aperto:
		tela.draw_colored_polygon(PackedVector2Array([p + Vector2(-24, -26), p + Vector2(24, -26), p + Vector2(30, -52),
				p + Vector2(-18, -52)]), Color(LEGNO_CHIARO, 0.95))
		tela.draw_polyline(chiuso(PackedVector2Array([p + Vector2(-24, -26), p + Vector2(24, -26), p + Vector2(30, -52),
				p + Vector2(-18, -52)])), INK, 2.5, true)
		for k in 3:
			stella(tela, p + Vector2(-14.0 + 14.0 * float(k), -38.0 - 8.0 * sin(t * 3.0 + float(k))), 6.0, Color("#ffd23a"))
		return
	var coperchio := Rect2(p + Vector2(-26, -40), Vector2(52, 16))
	tela.draw_rect(coperchio, LEGNO_CHIARO)
	tela.draw_rect(coperchio, INK, false, 2.5)
	tela.draw_rect(Rect2(p + Vector2(-5, -30), Vector2(10, 10)), ARANCIO)
	tela.draw_rect(Rect2(p + Vector2(-5, -30), Vector2(10, 10)), INK, false, 1.5)


static func personaggio(tela: CanvasItem, p: Vector2, faccia: float, passo: float, colpo: float) -> void:
	# IL SEGNAPOSTO DEL PROTAGONISTA: cappotto scuro, sciarpa arancio. Cammina
	# dondolando; quando lavora, il piccone va su e giu' (colpo da 0 a 1)
	ovale(tela, p + Vector2(0, 2), Vector2(18, 6), Color(0, 0, 0, 0.3), false)
	var dondola := absf(sin(passo)) * 3.0
	var gambe := sin(passo) * 5.0
	tela.draw_line(p + Vector2(-5, -16), p + Vector2(-5 + gambe, 0), INK, 6.0, true)
	tela.draw_line(p + Vector2(5, -16), p + Vector2(5 - gambe, 0), INK, 6.0, true)
	var busto := p + Vector2(0, -dondola)
	var cappotto := PackedVector2Array([busto + Vector2(-13, -40), busto + Vector2(13, -40), busto + Vector2(15, -12),
			busto + Vector2(-15, -12)])
	tela.draw_colored_polygon(cappotto, Color("#2b2838"))
	tela.draw_polyline(chiuso(cappotto), INK, 2.5, true)
	if colpo >= 0.0:
		# il piccone: dall'alto dietro la testa giu' davanti, e la scintilla in fondo
		var angolo := lerpf(-2.4, 0.5, colpo)
		if faccia < 0.0:
			angolo = PI - angolo
		var mano := busto + Vector2(10.0 * faccia, -26)
		var testa_piccone := mano + Vector2.from_angle(angolo) * 26.0
		tela.draw_line(mano, testa_piccone, LEGNO, 4.0, true)
		var dritto := (testa_piccone - mano).normalized().orthogonal() * 10.0
		tela.draw_line(testa_piccone - dritto, testa_piccone + dritto, INK, 4.0, true)
		if colpo > 0.85:
			stella(tela, testa_piccone + Vector2(0, 6), 8.0, ARANCIO)
	tela.draw_rect(Rect2(busto + Vector2(-14, -44), Vector2(28, 8)), ARANCIO)
	tela.draw_line(busto + Vector2(-10.0 * faccia, -40), busto + Vector2(-22.0 * faccia, -34 + sin(passo * 0.5) * 3.0),
			ARANCIO, 5.0, true)
	var testa := busto + Vector2(0, -56)
	tela.draw_circle(testa, 13.5, INK)
	tela.draw_circle(testa, 11.5, Color("#f3dcc0"))
	tela.draw_colored_polygon(semicerchio(testa + Vector2(-2.0 * faccia, -2), 12.5), Color("#2b2838"))
	tela.draw_circle(testa + Vector2(5.0 * faccia, 2), 2.0, INK)


static func invito(tela: CanvasItem, p: Vector2, testo: String, puoi: bool, manca: String) -> void:
	# sopra la cosa: arancio se la puoi fare, scuro se no, e sotto cosa manca
	var f := Caratteri.titolo()
	var corpo := 15
	var largo := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo + Manifesto.INCLINA * corpo * 1.3
	var dove := p - Vector2(largo * 0.5, 0)
	Manifesto.etichetta_tinta(tela, dove + Vector2(4, 4), testo, corpo, Color(0, 0, 0, 0.35), Color(0, 0, 0, 0))
	Manifesto.etichetta_tinta(tela, dove, testo, corpo, ARANCIO if puoi else Color("#3a3644"),
			INK if puoi else CARTA)
	if manca != "":
		var w := f.get_string_size(manca, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		tela.draw_rect(Rect2(p + Vector2(-w * 0.5 - 6, 22), Vector2(w + 12, 18)), Stile.colore("pericolo"))
		tela.draw_string(f, p + Vector2(-w * 0.5, 36), manca, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)


static func sale(tela: CanvasItem, p: Vector2, testo: String, eta: float, tinta: Color) -> void:
	# la scritta che sale e sparisce: +5 QUARZO
	var f := Caratteri.titolo()
	var a := clampf(1.6 - eta, 0.0, 1.0)
	var dove := p + Vector2(-f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x * 0.5, -60.0 - eta * 40.0)
	tela.draw_string_outline(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 6, Color(INK, a))
	tela.draw_string(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(tinta, a))


static func risorsa(tela: CanvasItem, c: Vector2, quale: String, r: float) -> void:
	var tinte: Array = TINTE_RISORSA.get(quale, TINTE_RISORSA["quarzo"])
	if quale == "tazo":
		tela.draw_circle(c, r + 2.0, INK)
		tela.draw_circle(c, r, tinte[0])
		tela.draw_arc(c, r * 0.55, 0.0, TAU, 16, tinte[1], 2.0, true)
		return
	cristallo(tela, c + Vector2(0, r), r * 2.0, r * 0.6, tinte[0], tinte[1], quale == "ferro")


static func stella(tela: CanvasItem, c: Vector2, r: float, tinta: Color) -> void:
	var punti := PackedVector2Array()
	for i in 8:
		punti.append(c + Vector2.from_angle(PI * 0.25 * float(i) - PI * 0.5) * (r if i % 2 == 0 else r * 0.35))
	tela.draw_colored_polygon(punti, tinta)
	tela.draw_polyline(chiuso(punti), INK, 1.5, true)


static func ovale(tela: CanvasItem, c: Vector2, r: Vector2, tinta: Color, bordo := true) -> void:
	var punti := PackedVector2Array()
	for i in 24:
		punti.append(c + Vector2(cos(TAU * float(i) / 24.0) * r.x, sin(TAU * float(i) / 24.0) * r.y))
	tela.draw_colored_polygon(punti, tinta)
	if bordo:
		tela.draw_polyline(chiuso(punti), INK, 1.5, true)


static func semicerchio(c: Vector2, r: float) -> PackedVector2Array:
	var punti := PackedVector2Array()
	for i in 17:
		punti.append(c + Vector2.from_angle(PI + PI * float(i) / 16.0) * r)
	return punti
