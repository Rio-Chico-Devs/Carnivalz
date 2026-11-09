extends RefCounted
# COME SI DISEGNA LA RACCOLTA (prove/RaccoltaProva.gd). Provvisorio come lei.
#
# Bru, sul primo prototipo: «si è carino ma c'è ancora molto lavoro da fare per
# renderlo bello e con grafiche migliori». Qui le regole del disegno:
#   - LA LUCE viene dall'alto a sinistra, per tutto: il lato sinistro delle cose
#     e' piu' chiaro, l'ombra cade in basso a destra;
#   - IL CONTORNO e' l'inchiostro del manifesto, spesso uguale per tutto;
#   - I CAMPI SONO ISOLE sospese nel Vuoto: sopra la terra, sotto la parete di
#     roccia, e sotto ancora il fondo che si perde nel buio;
#   - il personaggio e' un segnaposto a forme, come le Sagome: il disegno vero
#     arrivera' da Bru.
# La terra, la nebbia e il cielo sono shader (prove/raccolta_*.gdshader).

# I COLORI SONO DOSI D'INCHIOSTRO. Tutto passa dalla stampa (raccolta_stampa):
# carta crema e tre inchiostri, nero, arancio e blu. Ogni colore qui sotto e'
# carta x nero^n x arancio^a x blu^b, scelto per ruolo:
#   la carta e' la luce; l'arancio i toni caldi e quello che si accende; il blu
#   le ombre, le piante, la nebbia; il nero le linee e il buio fondo.
# Fra parentesi le dosi (nero, arancio, blu).
const INK := Color("#1a1720")                 # (1, 0, 0): pieno
const CARTA := Color("#efd8b2")               # (0, 0, 0)
const ARANCIO := Color("#f29a2e")             # (0, 1, 0)
const LINEA := Color("#2f6aa8")               # (0, 0, 1)
const OMBRA_TINTA := Color("#57808b")         # (0, 0, .6): le ombre sono blu
const RUPE_ALTA := Color("#cf8731")           # (.05, .7, 0)
const RUPE_BASSA := Color("#2a2718")          # (.45, .55, .45)
const STRATO := Color("#261e15")              # (.7, .4, .2)
const LEGNO := Color("#6e4319")               # (.35, .75, 0)
const LEGNO_CHIARO := Color("#bc8239")        # (.1, .55, 0)
const LEGNO_SCURO := Color("#2a1e10")         # (.65, .6, .2)
const METALLO := Color("#6b7e7e")             # (.1, 0, .35)
const METALLO_CHIARO := Color("#c3c2a9")      # (0, 0, .12)
const METALLO_SCURO := Color("#293541")       # (.4, 0, .55)
const PIETRA := Color("#6f7765")              # (.12, .12, .3)
const PIETRA_CHIARA := Color("#bcb998")       # (0, .06, .14)
const PIETRA_SCURA := Color("#313c3d")        # (.35, .1, .5)
const VERDE_ACQUA := Color("#385f74")         # (.05, 0, .8): le piante sono blu
const VERDE_SCURO := Color("#1b2e3f")         # (.35, 0, .85)
const PELLE := Color("#eecb91")               # (0, .12, 0)
const CAPPOTTO := Color("#171a22")            # (.75, 0, .45)
const CAPPOTTO_LUCE := Color("#242c36")       # (.5, 0, .5)
const ALTEZZA := 34.0            # la parete di roccia sotto un campo
const FONDO := 170.0             # quanto scende il fondo dell'isola, al centro
const OMBRA := Vector2(14, 7)    # dove cade l'ombra: in basso a destra, lunga
const TINTE_RISORSA := {"quarzo": [Color("#efd8b2"), Color("#7e9b98"), Color("#ffffff")],
		"ferro": [Color("#3a5765"), Color("#17212d"), Color("#90a69d")],
		"cristallo": [Color("#e48926"), Color("#734814"), Color("#ebb562")],
		"tazo": [Color("#e79c3a"), Color("#864c15"), Color("#edc88a")]}


static func zolla(centro: Vector2, raggi: Vector2, seme: float) -> PackedVector2Array:
	# il contorno storto di un campo, sempre lo stesso per lo stesso seme. La
	# stessa formula sta nello shader (dentro_al_campo): non cambiarne una sola
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


# ------------------------------------------------------------------ le isole

static func isola(tela: CanvasItem, sopra: PackedVector2Array, seme: float) -> void:
	# sotto la terra: il fondo che si perde nel buio, poi la parete con gli strati.
	# I punti 0..32 del contorno sono la meta' di sotto (da destra a sinistra)
	var bordo := PackedVector2Array()
	for i in 33:
		bordo.append(sopra[i] + Vector2(0, ALTEZZA))
	# il fondo, a strisce: una per lato del contorno, chiara in alto e persa
	# nel buio in basso. Un poligono solo si piegherebbe su se stesso dove il
	# fianco dell'isola e' ripido
	var punte := PackedVector2Array()
	for i in 33:
		var curva := pow(sin(PI * float(i) / 32.0), 0.8)
		var giu := 6.0 + curva * FONDO * (0.7 + 0.5 * absf(sin(float(i) * 2.7 + seme)))
		giu += 18.0 * curva if i % 3 == 0 else 0.0
		punte.append(bordo[i] + Vector2(sin(float(i) * 1.3 + seme) * 6.0 * curva, giu))
	var buio := Color(RUPE_BASSA.darkened(0.55), 0.0)
	for i in 32:
		var striscia := PackedVector2Array([bordo[i], bordo[i + 1], punte[i + 1], punte[i]])
		if absf(area(striscia)) > 1.0:
			tela.draw_polygon(striscia, PackedColorArray([RUPE_BASSA, RUPE_BASSA, buio, buio]))
	# le punte che pendono: piu' scure, a gocce
	for i in range(3, 30, 5):
		var radice := bordo[i] + Vector2(0, 30.0 + 40.0 * sin(PI * float(i) / 32.0))
		var lungo := 26.0 + 30.0 * absf(sin(float(i) * 1.7 + seme))
		tela.draw_polygon(PackedVector2Array([radice + Vector2(-9, 0), radice + Vector2(9, 0), radice + Vector2(1, lungo)]),
				PackedColorArray([Color(RUPE_BASSA, 0.7), Color(RUPE_BASSA, 0.7), Color(RUPE_BASSA, 0.0)]))
	# la parete: chiara in alto, scura in basso, con uno strato a meta'
	for i in 32:
		var quadro := PackedVector2Array([sopra[i], sopra[i + 1], bordo[i + 1], bordo[i]])
		if absf(area(quadro)) > 1.0:
			tela.draw_polygon(quadro, PackedColorArray([RUPE_ALTA, RUPE_ALTA, RUPE_BASSA, RUPE_BASSA]))
	var strato := PackedVector2Array()
	for i in 33:
		strato.append(sopra[i] + Vector2(0, ALTEZZA * (0.45 + 0.08 * sin(float(i) * 0.9 + seme))))
	tela.draw_polyline(strato, STRATO, 2.0, true)
	for i in range(2, 31, 4):
		tela.draw_line(sopra[i] + Vector2(0, 5), sopra[i] + Vector2(2, ALTEZZA * 0.4), STRATO, 1.5, true)
	tela.draw_polyline(bordo, INK, 2.5, true)


static func area(poligono: PackedVector2Array) -> float:
	# l'area con il segno: quasi zero vuol dire un poligono schiacciato, che
	# il disegno non sa riempire
	var somma := 0.0
	for i in poligono.size():
		var a := poligono[i]
		var b := poligono[(i + 1) % poligono.size()]
		somma += a.x * b.y - b.x * a.y
	return somma * 0.5


static func orlo(tela: CanvasItem, sopra: PackedVector2Array) -> void:
	tela.draw_polyline(chiuso(sopra), INK, 3.0, true)


static func passerella_sotto(tela: CanvasItem, pezzo: PackedVector2Array) -> void:
	# la parete della lingua di roccia: solo i lati che guardano in giu'
	for i in pezzo.size():
		var a := pezzo[i]
		var b := pezzo[(i + 1) % pezzo.size()]
		if a.distance_to(b) < 1.0:
			continue
		var normale := (b - a).orthogonal()
		if Geometry2D.is_polygon_clockwise(pezzo):
			normale = -normale
		if normale.y >= 0.0:
			continue
		tela.draw_polygon(PackedVector2Array([a, b, b + Vector2(0, ALTEZZA), a + Vector2(0, ALTEZZA)]),
				PackedColorArray([RUPE_ALTA, RUPE_ALTA, RUPE_BASSA, RUPE_BASSA]))
		tela.draw_polygon(PackedVector2Array([a + Vector2(0, ALTEZZA), b + Vector2(0, ALTEZZA), b + Vector2(0, ALTEZZA + 50),
				a + Vector2(0, ALTEZZA + 50)]), PackedColorArray([RUPE_BASSA, RUPE_BASSA, Color(RUPE_BASSA, 0.0),
				Color(RUPE_BASSA, 0.0)]))
		tela.draw_line(a + Vector2(0, ALTEZZA), b + Vector2(0, ALTEZZA), INK, 2.5, true)


# ------------------------------------------------------------------ i passaggi

static func ponte(tela: CanvasItem, da: Vector2, a: Vector2, largo: float, quanto: float) -> void:
	# rotto: le corde spezzate, due assi per parte. Riparandolo, le assi cadono
	# al loro posto una alla volta, con un rimbalzo
	var verso := (a - da).normalized()
	var lato := verso.orthogonal() * largo * 0.5
	var lungo := da.distance_to(a)
	var assi := int(lungo / 15.0)
	# le due travi sotto, scure
	for s: float in [-0.7, 0.7]:
		if quanto >= 1.0:
			tela.draw_line(da + lato * s + Vector2(0, 14), a + lato * s + Vector2(0, 14), LEGNO_SCURO, 6.0, true)
	for k in assi:
		var f := (float(k) + 0.5) / float(assi)
		var ai_capi := k < 2 or k >= assi - 2
		var arrivo := 1.0 if ai_capi else clampf((quanto - f * 0.85) / 0.15, 0.0, 1.0)
		if arrivo <= 0.0:
			continue
		var cade := (1.0 - rimbalzo(arrivo)) * -46.0
		var p := da.lerp(a, f) + Vector2(0, 6.0 + cade)
		var asse := PackedVector2Array([p - lato - verso * 6.5, p - lato + verso * 6.5, p + lato + verso * 6.5,
				p + lato - verso * 6.5])
		tela.draw_polygon(asse, PackedColorArray([LEGNO_CHIARO, LEGNO_CHIARO, LEGNO, LEGNO]))
		tela.draw_polyline(chiuso(asse), INK, 1.5, true)
		tela.draw_circle(p - lato * 0.75, 1.5, INK)
		tela.draw_circle(p + lato * 0.75, 1.5, INK)
	for s: float in [-1.0, 1.0]:
		var corda_da := da + lato * s * 1.12 + Vector2(0, -8)
		var corda_a := a + lato * s * 1.12 + Vector2(0, -8)
		if quanto < 1.0:
			var mezzo := corda_da.lerp(corda_a, 0.5)
			tela.draw_polyline(PackedVector2Array([corda_da, corda_da.lerp(mezzo, 0.5) + Vector2(0, 12), mezzo + Vector2(-6, 46)]),
					LEGNO_SCURO, 3.0, true)
			tela.draw_polyline(PackedVector2Array([corda_a, corda_a.lerp(mezzo, 0.5) + Vector2(0, 14), mezzo + Vector2(8, 52)]),
					LEGNO_SCURO, 3.0, true)
		else:
			var curva := PackedVector2Array()
			for i in 13:
				var t := float(i) / 12.0
				curva.append(corda_da.lerp(corda_a, t) + Vector2(0, sin(t * PI) * 10.0))
			tela.draw_polyline(curva, LEGNO_SCURO, 3.0, true)
		for estremo: Vector2 in [corda_da, corda_a]:
			palo(tela, estremo + Vector2(0, 10))


static func rimbalzo(x: float) -> float:
	# arriva, rimbalza una volta, si posa
	if x < 0.7:
		var t := x / 0.7
		return t * t
	var u := (x - 0.85) / 0.15
	return 1.0 - 0.12 * (1.0 - u * u)


static func palo(tela: CanvasItem, base: Vector2) -> void:
	var r := Rect2(base + Vector2(-5, -24), Vector2(10, 26))
	tela.draw_rect(r, LEGNO)
	tela.draw_rect(Rect2(r.position, Vector2(4, r.size.y)), LEGNO_CHIARO)
	tela.draw_rect(r, INK, false, 2.0)


static func cancello(tela: CanvasItem, dove: Vector2, verso: Vector2, largo: float, aperto: float, t: float) -> void:
	# due pilastri di pietra con le lanterne, e le sbarre che rientrano nel
	# pilastro di sinistra. Chiuso, le lanterne sono spente
	var lato := verso.orthogonal() * largo * 0.6
	for s: float in [-1.0, 1.0]:
		var base := dove + lato * s
		ovale(tela, base + OMBRA * 0.6, Vector2(16, 6), Color(OMBRA_TINTA, 0.79), false)
		var corpo := Rect2(base + Vector2(-11, -46), Vector2(22, 48))
		tela.draw_rect(corpo, PIETRA)
		tela.draw_rect(Rect2(corpo.position, Vector2(8, corpo.size.y)), PIETRA_CHIARA)
		tela.draw_rect(Rect2(corpo.position + Vector2(16, 0), Vector2(6, corpo.size.y)), PIETRA_SCURA)
		for k in 3:
			tela.draw_line(corpo.position + Vector2(0, 14.0 + 12.0 * float(k)), corpo.position + Vector2(22, 14.0 + 12.0 * float(k)),
					PIETRA_SCURA, 1.0)
		tela.draw_rect(corpo, INK, false, 2.0)
		var cappello := Rect2(base + Vector2(-14, -54), Vector2(28, 10))
		tela.draw_rect(cappello, PIETRA_CHIARA)
		tela.draw_rect(cappello, INK, false, 2.0)
		var lume := base + Vector2(0, -62)
		if aperto >= 1.0:
			alone(tela, lume, 22.0, ARANCIO, 0.35 + 0.1 * sin(t * 3.0 + s))
		tela.draw_circle(lume, 6.0, INK)
		tela.draw_circle(lume, 4.0, ARANCIO if aperto >= 1.0 else Color("#4a4452"))
	var chiusura := 1.0 - aperto
	if chiusura <= 0.0:
		return
	var sinistra := dove - lato + Vector2(0, -6)
	var destra := (dove - lato).lerp(dove + lato, chiusura) + Vector2(0, -6)
	for k in 6:
		var x := sinistra.lerp(destra, (float(k) + 0.5) / 6.0)
		tela.draw_line(x + Vector2(0, -32), x + Vector2(0, 4), INK, 5.0)
		tela.draw_line(x + Vector2(0, -32), x + Vector2(0, 4), METALLO, 2.5)
		tela.draw_colored_polygon(PackedVector2Array([x + Vector2(-4, -32), x + Vector2(4, -32), x + Vector2(0, -40)]), METALLO_SCURO)
	for y: float in [-26.0, -8.0]:
		tela.draw_line(sinistra + Vector2(0, y), destra + Vector2(0, y), INK, 5.0)
		tela.draw_line(sinistra + Vector2(0, y), destra + Vector2(0, y), METALLO_SCURO, 2.5)


# ------------------------------------------------------------------ le cose

static func vena(tela: CanvasItem, p: Vector2, quale: String, carica: float, t: float) -> void:
	# la vena: un cumulo di roccia e i cristalli. Piena, ha l'alone e la
	# scintilla; scavata, restano i mozziconi e il giro che si riempie
	var tinte: Array = TINTE_RISORSA.get(quale, TINTE_RISORSA["quarzo"])
	var pronta := carica >= 1.0
	ovale(tela, p + OMBRA, Vector2(30, 10), Color(OMBRA_TINTA, 0.72), false)
	if pronta:
		alone(tela, p + Vector2(0, -14), 44.0, tinte[2], 0.22 + 0.06 * sin(t * 2.5 + p.x))
	var cumulo := PackedVector2Array([p + Vector2(-28, 4), p + Vector2(-22, -8), p + Vector2(-6, -13), p + Vector2(12, -11),
			p + Vector2(26, -4), p + Vector2(28, 5), p + Vector2(0, 9)])
	tela.draw_polygon(cumulo, PackedColorArray([PIETRA, PIETRA_CHIARA, PIETRA_CHIARA, PIETRA, PIETRA_SCURA, PIETRA_SCURA,
			PIETRA_SCURA]))
	tela.draw_polyline(chiuso(cumulo), INK, 2.0, true)
	if not pronta:
		anello_a_terra(tela, p + Vector2(0, 2), Vector2(34, 13), carica)
	var alti := [24.0, 36.0, 20.0, 29.0, 16.0]
	var posti := [Vector2(-15, -4), Vector2(-3, -8), Vector2(10, -4), Vector2(18, -1), Vector2(-22, 1)]
	var pendenze := [-0.25, 0.0, 0.2, 0.35, -0.4]
	for k in 5:
		var alto: float = alti[k] * (1.0 if pronta else 0.28 + 0.22 * carica)
		cristallo(tela, p + (posti[k] as Vector2), alto, 6.0, float(pendenze[k]), tinte, quale == "ferro")
	if pronta:
		var batte := 0.6 + 0.4 * absf(sin(t * 3.0 + p.x * 0.1))
		stella(tela, p + Vector2(8, -46), 8.0 * batte, Color.WHITE)


static func cristallo(tela: CanvasItem, base: Vector2, alto: float, largo: float, pende: float, tinte: Array, tozzo: bool) -> void:
	# un cristallo a due facce: la sinistra prende la luce, la destra no
	var cima := base + Vector2(pende * alto, -alto)
	var spalla := alto * (0.62 if tozzo else 0.74)
	var lx := largo * (1.35 if tozzo else 1.0)
	var sx := base + Vector2(-lx, 0)
	var dx := base + Vector2(lx, 0)
	var sx_su := base + Vector2(-lx + pende * spalla, -spalla)
	var dx_su := base + Vector2(lx + pende * spalla, -spalla)
	var mezzo := base + Vector2(pende * spalla * 0.5, 2)
	tela.draw_colored_polygon(PackedVector2Array([sx, sx_su, cima, mezzo]), tinte[0])
	tela.draw_colored_polygon(PackedVector2Array([mezzo, cima, dx_su, dx]), tinte[1])
	tela.draw_line(sx_su.lerp(cima, 0.2), mezzo.lerp(cima, 0.3), Color(tinte[2], 0.9), 1.5, true)
	tela.draw_polyline(PackedVector2Array([sx, sx_su, cima, dx_su, dx]), INK, 2.0, true)


static func anello_a_terra(tela: CanvasItem, c: Vector2, r: Vector2, quota: float) -> void:
	# il giro che si riempie, steso per terra come un'ellisse
	var tutto := PackedVector2Array()
	var pieno := PackedVector2Array()
	for i in 41:
		var a := -PI * 0.5 + TAU * float(i) / 40.0
		tutto.append(c + Vector2(cos(a) * r.x, sin(a) * r.y))
		if float(i) / 40.0 <= quota:
			pieno.append(c + Vector2(cos(a) * r.x, sin(a) * r.y))
	tela.draw_polyline(tutto, Color(INK, 0.25), 4.0, true)
	if pieno.size() > 1:
		tela.draw_polyline(pieno, LINEA, 4.0, true)


static func modulo(tela: CanvasItem, p: Vector2, t: float) -> void:
	# il modulo d'atterraggio: da qui quello che raccogli parte per le riserve
	ovale(tela, p + OMBRA + Vector2(4, 4), Vector2(56, 15), Color(OMBRA_TINTA, 0.79), false)
	for x: float in [-38.0, 38.0, -16.0, 16.0]:
		var piede := p + Vector2(x, 6.0 if absf(x) < 20.0 else 2.0)
		tela.draw_line(p + Vector2(x * 0.55, -26), piede, INK, 6.0, true)
		tela.draw_line(p + Vector2(x * 0.55, -26), piede, METALLO_SCURO, 3.0, true)
		ovale(tela, piede, Vector2(8, 3), METALLO)
	var corpo := PackedVector2Array([p + Vector2(-38, -52), p + Vector2(38, -52), p + Vector2(34, -22), p + Vector2(-34, -22)])
	tela.draw_polygon(corpo, PackedColorArray([CARTA, CARTA.darkened(0.25), CARTA.darkened(0.3), CARTA.lightened(0.1)]))
	tela.draw_polyline(chiuso(corpo), INK, 2.5, true)
	tela.draw_rect(Rect2(p + Vector2(-36, -36), Vector2(72, 5)), ARANCIO)
	var cupola := semicerchio(p + Vector2(0, -52), 32.0)
	var luci := PackedColorArray()
	for i in cupola.size():
		luci.append(CARTA.lightened(0.15).lerp(CARTA.darkened(0.3), float(i) / float(cupola.size() - 1)))
	tela.draw_polygon(cupola, luci)
	tela.draw_polyline(cupola, INK, 2.5, true)
	tela.draw_arc(p + Vector2(-6, -58), 18.0, PI * 1.1, PI * 1.45, 10, Color(1, 1, 1, 0.7), 3.0, true)
	tela.draw_circle(p + Vector2(0, -58), 10.0, INK)
	tela.draw_circle(p + Vector2(0, -58), 7.5, Color("#3d6f9e"))
	tela.draw_circle(p + Vector2(-2.5, -60.5), 2.5, Color("#bfe3ff"))
	tela.draw_line(p + Vector2(20, -76), p + Vector2(30, -100), INK, 2.5)
	var lampeggia := fmod(t, 1.4) < 0.8
	if lampeggia:
		alone(tela, p + Vector2(30, -100), 16.0, ARANCIO, 0.45)
	tela.draw_circle(p + Vector2(30, -100), 4.5, ARANCIO if lampeggia else Color(ARANCIO, 0.35))


static func trivella(tela: CanvasItem, p: Vector2, costruita: float, scorta: int, tiene: int, t: float) -> void:
	# la piazzola, poi la macchina che si monta dal basso (costruita da 0 a 1)
	if costruita <= 0.0:
		var giro := PackedVector2Array()
		for i in 33:
			var a := TAU * float(i) / 32.0
			giro.append(p + Vector2(cos(a) * 34.0, sin(a) * 13.0))
		for i in range(0, 32, 2):
			tela.draw_line(giro[i], giro[i + 1], INK, 2.5, true)
		tela.draw_line(p + Vector2(-9, 0), p + Vector2(9, 0), INK, 3.0)
		tela.draw_line(p + Vector2(0, -5), p + Vector2(0, 5), INK, 3.0)
		return
	var su := clampf(costruita, 0.0, 1.0)
	ovale(tela, p + OMBRA, Vector2(40, 12), Color(OMBRA_TINTA, 0.79), false)
	var cima := p + Vector2(0, -80.0 * su)
	for piede: Vector2 in [Vector2(-32, 4), Vector2(32, 4), Vector2(0, 12)]:
		tela.draw_line(cima, p + piede, INK, 7.0, true)
		tela.draw_line(cima, p + piede, METALLO_SCURO if piede.x > 0 else METALLO, 4.0, true)
	if su < 1.0:
		return
	var motore := Rect2(cima + Vector2(-14, -16), Vector2(28, 20))
	tela.draw_rect(motore, ARANCIO)
	tela.draw_rect(Rect2(motore.position + Vector2(18, 0), Vector2(10, 20)), ARANCIO.darkened(0.3))
	tela.draw_rect(motore, INK, false, 2.0)
	# la punta che gira: righe a spirale che scendono
	var punta := PackedVector2Array([p + Vector2(-8, -42), p + Vector2(8, -42), p + Vector2(0, -6)])
	tela.draw_colored_polygon(punta, METALLO_CHIARO)
	for k in 3:
		var y := -40.0 + fmod(t * 50.0 + 11.0 * float(k), 33.0)
		var stretto := 8.0 * (1.0 - (y + 42.0) / 36.0)
		tela.draw_line(p + Vector2(-stretto, y), p + Vector2(stretto, y + 4.0), METALLO_SCURO, 2.0)
	tela.draw_polyline(chiuso(punta), INK, 2.0, true)
	tela.draw_line(cima + Vector2(0, 4), p + Vector2(0, -42), INK, 4.0)
	# la tramoggia, a sinistra: si riempie di quarzo
	var scatola := Rect2(p + Vector2(-66, -46), Vector2(30, 34))
	tela.draw_rect(scatola, METALLO_SCURO)
	var pieno := scatola.size.y * float(scorta) / float(tiene)
	tela.draw_rect(Rect2(scatola.position.x, scatola.end.y - pieno, scatola.size.x, pieno), (TINTE_RISORSA["quarzo"] as Array)[0])
	tela.draw_rect(Rect2(scatola.position, Vector2(6, scatola.size.y)), Color(1, 1, 1, 0.15))
	tela.draw_rect(scatola, INK, false, 2.0)
	tela.draw_line(scatola.position + Vector2(scatola.size.x, 8), p + Vector2(-8, -30), INK, 3.0)
	if scorta >= tiene:
		stella(tela, scatola.position + Vector2(scatola.size.x * 0.5, -12), 8.0, ARANCIO)


static func forziere(tela: CanvasItem, p: Vector2, aperto: bool, t: float) -> void:
	ovale(tela, p + OMBRA, Vector2(32, 9), Color(OMBRA_TINTA, 0.79), false)
	if not aperto:
		alone(tela, p + Vector2(0, -20), 40.0, ARANCIO, 0.15 + 0.08 * sin(t * 2.0))
	var cassa := Rect2(p + Vector2(-26, -28), Vector2(52, 30))
	tela.draw_rect(cassa, LEGNO)
	tela.draw_rect(Rect2(cassa.position, Vector2(16, cassa.size.y)), LEGNO_CHIARO)
	for x: float in [-18.0, 14.0]:
		tela.draw_rect(Rect2(p + Vector2(x, -28), Vector2(5, 30)), METALLO_SCURO)
	tela.draw_rect(cassa, INK, false, 2.5)
	if aperto:
		var dentro := PackedVector2Array([p + Vector2(-26, -28), p + Vector2(26, -28), p + Vector2(32, -58), p + Vector2(-20, -58)])
		tela.draw_colored_polygon(dentro, LEGNO_SCURO)
		tela.draw_polyline(chiuso(dentro), INK, 2.5, true)
		alone(tela, p + Vector2(0, -32), 34.0, TINTE_RISORSA["tazo"][0], 0.5)
		for k in 4:
			stella(tela, p + Vector2(-16.0 + 11.0 * float(k), -42.0 - 7.0 * sin(t * 3.0 + float(k))), 6.0, TINTE_RISORSA["tazo"][0])
		return
	var coperchio := PackedVector2Array([p + Vector2(-28, -28), p + Vector2(28, -28), p + Vector2(24, -44), p + Vector2(-24, -44)])
	tela.draw_polygon(coperchio, PackedColorArray([LEGNO, LEGNO_SCURO, LEGNO_SCURO, LEGNO_CHIARO]))
	tela.draw_polyline(chiuso(coperchio), INK, 2.5, true)
	tela.draw_rect(Rect2(p + Vector2(-6, -34), Vector2(12, 12)), ARANCIO)
	tela.draw_rect(Rect2(p + Vector2(-6, -34), Vector2(12, 12)), INK, false, 1.5)


static func cartello(tela: CanvasItem, base: Vector2, costo: Dictionary) -> void:
	# il cartello di legno: si vede da lontano. Le cifre del prezzo le scrive
	# la tasca sopra la stampa (cifre_del_cartello), perche' restino nitide
	var largo := 20.0 + 50.0 * float(costo.size())
	palo(tela, base)
	var tavola := Rect2(base + Vector2(-largo * 0.5, -60), Vector2(largo, 32))
	ovale(tela, base + OMBRA, Vector2(12, 4), Color(OMBRA_TINTA, 0.72), false)
	tela.draw_rect(Rect2(tavola.position + Vector2(4, 4), tavola.size), Color(OMBRA_TINTA, 0.90))
	tela.draw_rect(tavola, LEGNO_CHIARO)
	tela.draw_rect(Rect2(tavola.position + Vector2(0, tavola.size.y - 7), Vector2(tavola.size.x, 7)), LEGNO)
	tela.draw_rect(tavola, INK, false, 2.0)


static func cifre_del_cartello(tela: CanvasItem, base: Vector2, costo: Dictionary, borsa: Dictionary) -> void:
	# il prezzo, su una targhetta di carta: in rosso quello che manca
	var largo := 20.0 + 50.0 * float(costo.size())
	var targa := Rect2(base + Vector2(-largo * 0.5 + 6, -56), Vector2(largo - 12, 24))
	tela.draw_rect(targa, CARTA)
	tela.draw_rect(targa, INK, false, 1.5)
	var x := targa.position.x + 12.0
	for quale: String in costo:
		risorsa(tela, Vector2(x, targa.get_center().y), quale, 7.0)
		var manca := int(costo[quale]) > int(borsa.get(quale, 0))
		tela.draw_string(Caratteri.titolo(), Vector2(x + 11.0, targa.get_center().y + 6.0), str(int(costo[quale])),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Stile.colore("pericolo") if manca else INK)
		x += 50.0


# ------------------------------------------------------------------ i decori

static func masso(tela: CanvasItem, p: Vector2, r: float, seme: float) -> void:
	ovale(tela, p + OMBRA * (r / 16.0), Vector2(r * 1.2, r * 0.45), Color(OMBRA_TINTA, 0.72), false)
	var forma := PackedVector2Array()
	var tinte := PackedColorArray()
	for i in 9:
		var a := PI * 1.06 + PI * 0.88 * float(i) / 8.0
		var rr := r * (0.85 + 0.25 * absf(sin(float(i) * 2.1 + seme)))
		forma.append(p + Vector2(cos(a) * rr * 1.15, sin(a) * rr * 0.95))
		tinte.append(PIETRA_CHIARA if i < 4 else PIETRA)
	forma.append(p + Vector2(r * 0.8, r * 0.3))
	forma.append(p + Vector2(-r * 0.8, r * 0.3))
	tinte.append(PIETRA_SCURA)
	tinte.append(PIETRA)
	tela.draw_polygon(forma, tinte)
	tela.draw_polyline(chiuso(forma), INK, 2.0, true)
	tela.draw_line(p + Vector2(-r * 0.3, -r * 0.5), p + Vector2(r * 0.1, -r * 0.2), PIETRA_SCURA, 1.5, true)


static func pianta(tela: CanvasItem, p: Vector2, alta: float, seme: float, t: float) -> void:
	# una pianta del pianeta: steli verdeacqua che dondolano, e i bulbi accesi
	ovale(tela, p + OMBRA * 0.6, Vector2(12, 4), Color(OMBRA_TINTA, 0.65), false)
	for k in 3:
		var piega := sin(t * 1.3 + seme + float(k)) * 0.12 + (float(k) - 1.0) * 0.35
		var cima := p + Vector2.from_angle(-PI * 0.5 + piega) * alta * (0.75 + 0.25 * float(k % 2))
		var mezzo := p.lerp(cima, 0.5) + Vector2(piega * 8.0, 0)
		var stelo := PackedVector2Array([p, mezzo, cima])
		tela.draw_polyline(stelo, INK, 5.0, true)
		tela.draw_polyline(stelo, VERDE_ACQUA if k != 1 else VERDE_SCURO, 2.5, true)
		var bulbo := ARANCIO if k == 1 else Color("#ffe39a")
		alone(tela, cima, 12.0, bulbo, 0.3)
		tela.draw_circle(cima, 5.0, INK)
		tela.draw_circle(cima, 3.5, bulbo)


static func cratere(tela: CanvasItem, p: Vector2, r: Vector2) -> void:
	ovale(tela, p, r, Color("#d9a865"), false)
	ovale(tela, p + Vector2(r.x * 0.08, r.y * 0.15), r * 0.82, Color("#57808b"), false)
	var orlo_luce := PackedVector2Array()
	for i in 13:
		var a := PI * 0.05 + PI * 0.9 * float(i) / 12.0
		orlo_luce.append(p + Vector2(cos(a) * r.x, sin(a) * r.y))
	tela.draw_polyline(orlo_luce, CARTA, 2.5, true)


static func bruciatura(tela: CanvasItem, p: Vector2) -> void:
	# la terra annerita dove e' atterrato il modulo
	for k in 3:
		ovale(tela, p, Vector2(78.0 - 16.0 * float(k), 26.0 - 5.0 * float(k)), Color(0.25, 0.16, 0.1, 0.12), false)


# ------------------------------------------------------------------ il personaggio

static func personaggio(tela: CanvasItem, p: Vector2, faccia: float, dietro: bool, passo: float, colpo: float,
		carico: int, t: float) -> void:
	# IL SEGNAPOSTO DEL PROTAGONISTA, a tre quarti: cappotto scuro, sciarpa
	# arancio, zaino. Cammina dondolando con le braccia che vanno; da dietro
	# si vede lo zaino, che si riempie di cristalli. Il piccone va su e giu'
	# quando lavora (colpo da 0 a 1, -1 se non lavora)
	var muove := absf(sin(passo)) > 0.01
	var respiro := 0.0 if muove else sin(t * 2.2) * 0.8
	var dondola := absf(sin(passo)) * 3.0
	ovale(tela, p + Vector2(3, 2), Vector2(19, 6), Color(OMBRA_TINTA, 1.00), false)
	# le gambe
	var oscilla := sin(passo) * 5.0
	for g: float in [-1.0, 1.0]:
		var anca := p + Vector2(5.0 * g, -18)
		var piede := p + Vector2(5.0 * g + oscilla * g * faccia * 0.6, -maxf(0.0, sin(passo) * g) * 4.0)
		tela.draw_line(anca, piede, INK, 9.0, true)
		tela.draw_line(anca, piede, Color("#2b3346"), 5.5, true)
		ovale(tela, piede + Vector2(2.0 * faccia, 0), Vector2(6, 3.5), INK)
	var busto := p + Vector2(0, -dondola - respiro)
	# lo zaino: di fianco sporge dietro la schiena, da dietro e' tutto in vista
	if not dietro:
		disegna_zaino(tela, Rect2(busto + Vector2(-13.0 - 11.0 * faccia, -44), Vector2(26, 26)), carico)
	# il cappotto, chiaro dalla parte della luce
	var cappotto := PackedVector2Array([busto + Vector2(-13, -44), busto + Vector2(13, -44), busto + Vector2(16, -14),
			busto + Vector2(-16, -14)])
	tela.draw_polygon(cappotto, PackedColorArray([CAPPOTTO_LUCE, CAPPOTTO, CAPPOTTO, CAPPOTTO_LUCE]))
	tela.draw_polyline(chiuso(cappotto), INK, 2.5, true)
	tela.draw_line(busto + Vector2(0, -40), busto + Vector2(0, -16), Color(INK, 0.6), 1.5)
	if dietro:
		disegna_zaino(tela, Rect2(busto + Vector2(-13, -46), Vector2(26, 28)), carico)
	# le braccia: vanno al contrario delle gambe; col piccone, una alza l'attrezzo
	for g: float in [-1.0, 1.0]:
		var spalla := busto + Vector2(12.0 * g, -40)
		var mano := spalla + Vector2(3.0 * g - oscilla * g * faccia * 0.6, 22)
		if colpo >= 0.0 and g == faccia:
			mano = piccone(tela, spalla, faccia, colpo)
		tela.draw_line(spalla, mano, INK, 9.0, true)
		tela.draw_line(spalla, mano, CAPPOTTO if g == faccia else CAPPOTTO_LUCE, 5.5, true)
		tela.draw_circle(mano, 4.5, INK)
		tela.draw_circle(mano, 3.0, PELLE)
	# la sciarpa, con la coda che sventola dietro
	tela.draw_rect(Rect2(busto + Vector2(-14, -48), Vector2(28, 8)), ARANCIO)
	tela.draw_rect(Rect2(busto + Vector2(-14, -48), Vector2(28, 8)), INK, false, 1.5)
	var coda := busto + Vector2(-10.0 * faccia, -44)
	var sventola := sin(t * 9.0) * 3.0 + sin(passo) * 2.0
	var lembo := PackedVector2Array([coda, coda + Vector2(-16.0 * faccia, 4.0 + sventola), coda + Vector2(-13.0 * faccia, 10.0 + sventola),
			coda + Vector2(0, 6)])
	tela.draw_colored_polygon(lembo, ARANCIO.darkened(0.15))
	tela.draw_polyline(chiuso(lembo), INK, 1.5, true)
	# la testa
	var testa := busto + Vector2(0, -62)
	tela.draw_circle(testa, 16.5, INK)
	tela.draw_circle(testa, 14.0, PELLE)
	if dietro:
		tela.draw_circle(testa + Vector2(0, -1), 14.0, CAPPOTTO)
		tela.draw_arc(testa + Vector2(-4, -6), 8.0, PI * 1.05, PI * 1.5, 8, CAPPOTTO_LUCE, 2.5, true)
		return
	var capelli := semicerchio(testa + Vector2(-2.0 * faccia, -2), 15.0)
	capelli.append(testa + Vector2(-14.0 * faccia, 6))
	tela.draw_colored_polygon(capelli, CAPPOTTO)
	tela.draw_arc(testa + Vector2(-6.0 * faccia, -8), 7.0, PI * 1.1, PI * 1.5, 8, CAPPOTTO_LUCE, 2.5, true)
	var occhio := testa + Vector2(6.0 * faccia, 3)
	var batte := fmod(t + p.x * 0.001, 3.2) < 0.12
	if batte:
		tela.draw_line(occhio + Vector2(-2.5, 0), occhio + Vector2(2.5, 0), INK, 2.0)
	else:
		tela.draw_circle(occhio, 2.4, INK)
		tela.draw_circle(occhio + Vector2(-0.8, -0.9), 0.8, Color.WHITE)
	tela.draw_circle(testa + Vector2(9.0 * faccia, 8), 2.5, Color(1.0, 0.55, 0.5, 0.45))


static func disegna_zaino(tela: CanvasItem, r: Rect2, carico: int) -> void:
	# lo zaino: piu' ne porti, piu' cristalli spuntano dalla patta
	for k in mini(int(carico / 4.0), 4):
		cristallo(tela, r.position + Vector2(5.0 + 5.5 * float(k), 2), 10.0 + 3.0 * float(k % 2), 3.0, -0.2 + 0.15 * float(k),
				TINTE_RISORSA["quarzo"], false)
	tela.draw_rect(r, LEGNO)
	tela.draw_rect(Rect2(r.position, Vector2(8, r.size.y)), LEGNO_CHIARO)
	tela.draw_rect(Rect2(r.position, Vector2(r.size.x, 8)), ARANCIO.darkened(0.2))
	tela.draw_rect(r, INK, false, 2.0)


static func piccone(tela: CanvasItem, spalla: Vector2, faccia: float, colpo: float) -> Vector2:
	# dall'alto dietro la testa giu' davanti; in fondo, la scintilla. Ritorna
	# dove sta la mano
	var angolo := lerpf(-2.5, 0.55, colpo * colpo)
	if faccia < 0.0:
		angolo = PI - angolo
	var mano := spalla + Vector2.from_angle(angolo) * 16.0
	var testa := mano + Vector2.from_angle(angolo) * 24.0
	tela.draw_line(mano, testa, INK, 6.0, true)
	tela.draw_line(mano, testa, LEGNO_CHIARO, 3.0, true)
	var di_lato := Vector2.from_angle(angolo).orthogonal() * 11.0
	var ferro := PackedVector2Array([testa - di_lato, testa + di_lato * 0.2 + Vector2.from_angle(angolo) * 3.0, testa + di_lato])
	tela.draw_polyline(ferro, INK, 6.0, true)
	tela.draw_polyline(ferro, METALLO, 3.0, true)
	return mano


# ------------------------------------------------------------------ le particelle e le scritte

static func particella(tela: CanvasItem, q: Dictionary) -> void:
	var vita := float(q["eta"]) / float(q["dura"])
	var p: Vector2 = q["p"]
	match String(q["tipo"]):
		"polvere":
			var r := float(q["r"]) * (0.6 + vita)
			tela.draw_circle(p, r, Color(Color("#e7d3a8"), 0.55 * (1.0 - vita)))
		"scheggia":
			var tinte: Array = TINTE_RISORSA.get(String(q["quale"]), TINTE_RISORSA["quarzo"])
			var giro := float(q["eta"]) * 12.0 + float(q["r"])
			var punti := PackedVector2Array()
			for i in 4:
				punti.append(p + Vector2.from_angle(giro + PI * 0.5 * float(i)) * (4.0 if i % 2 == 0 else 2.0))
			tela.draw_colored_polygon(punti, Color(tinte[0], 1.0 - vita * vita))
		"scintilla":
			stella(tela, p, float(q["r"]) * (1.0 - vita), Color(1, 1, 1, 1.0 - vita))
		"onda":
			tela.draw_arc(p, float(q["r"]) * (0.3 + vita), 0.0, TAU, 32, Color(ARANCIO, 1.0 - vita), 3.0, true)


static func invito(tela: CanvasItem, p: Vector2, testo: String, puoi: bool, manca: String, t: float) -> void:
	# sopra la cosa: il tasto E, cosa si fa; arancio se si puo', scuro se no.
	# Sotto, in rosso, quello che manca. Galleggia un poco
	var f := Caratteri.titolo()
	var corpo := 15
	p.y += sin(t * 3.0) * 2.0
	var largo := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + 52.0
	var r := Rect2(p - Vector2(largo * 0.5, 15), Vector2(largo, 30))
	var s := StyleBoxFlat.new()
	s.bg_color = ARANCIO if puoi else Color("#3a3644")
	s.set_corner_radius_all(15)
	s.border_color = INK
	s.set_border_width_all(2)
	s.shadow_color = Color(OMBRA_TINTA, 1.00)
	s.shadow_offset = Vector2(3, 4)
	s.shadow_size = 1
	tela.draw_style_box(s, r)
	var tasto := Rect2(r.position + Vector2(5, 4), Vector2(22, 22))
	var st := StyleBoxFlat.new()
	st.bg_color = CARTA
	st.set_corner_radius_all(5)
	st.border_color = INK
	st.set_border_width_all(2)
	tela.draw_style_box(st, tasto)
	tela.draw_string(f, tasto.position + Vector2(6, 17), "E", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, INK)
	tela.draw_string(f, r.position + Vector2(36, 21), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, INK if puoi else CARTA)
	tela.draw_colored_polygon(PackedVector2Array([p + Vector2(-7, 14), p + Vector2(7, 14), p + Vector2(0, 22)]),
			ARANCIO if puoi else Color("#3a3644"))
	if manca != "":
		var w := f.get_string_size(manca, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		var rossa := Rect2(p + Vector2(-w * 0.5 - 8, -40), Vector2(w + 16, 20))
		tela.draw_rect(rossa, Stile.colore("pericolo"))
		tela.draw_rect(rossa, INK, false, 1.5)
		tela.draw_string(f, rossa.position + Vector2(8, 15), manca, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)


static func sale(tela: CanvasItem, p: Vector2, testo: String, eta: float, tinta: Color) -> void:
	# la scritta che sale, con un piccolo salto all'inizio, e sparisce
	var f := Caratteri.titolo()
	var a := clampf(1.6 - eta, 0.0, 1.0)
	var salto := 1.0 + 0.4 * maxf(0.0, 1.0 - eta * 6.0)
	var corpo := int(19.0 * salto)
	var dove := p + Vector2(-f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x * 0.5, -70.0 - eta * 36.0)
	tela.draw_string_outline(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, 7, Color(INK, a))
	tela.draw_string(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Color(tinta, a))


# ------------------------------------------------------------------ i pezzi piccoli

static func risorsa(tela: CanvasItem, c: Vector2, quale: String, r: float) -> void:
	var tinte: Array = TINTE_RISORSA.get(quale, TINTE_RISORSA["quarzo"])
	if quale == "tazo":
		tela.draw_circle(c, r + 2.0, INK)
		tela.draw_circle(c, r, tinte[0])
		tela.draw_arc(c, r * 0.55, 0.0, TAU, 16, tinte[1], 2.0, true)
		tela.draw_arc(c, r * 0.8, PI * 1.05, PI * 1.5, 8, tinte[2], 1.5, true)
		return
	cristallo(tela, c + Vector2(0, r * 0.95), r * 1.9, r * 0.62, 0.0, tinte, quale == "ferro")


static func alone(tela: CanvasItem, c: Vector2, r: float, tinta: Color, forza: float) -> void:
	for k in 4:
		var f := 1.0 - float(k) / 4.0
		tela.draw_circle(c, r * f, Color(tinta, forza * 0.25))


static func stella(tela: CanvasItem, c: Vector2, r: float, tinta: Color) -> void:
	if r <= 0.5:
		return
	var punti := PackedVector2Array()
	for i in 8:
		punti.append(c + Vector2.from_angle(PI * 0.25 * float(i) - PI * 0.5) * (r if i % 2 == 0 else r * 0.32))
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
