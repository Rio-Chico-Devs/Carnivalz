extends RefCounted
# LA PIANTA DI UN LIVELLO DISEGNATO: dove si cammina, gli ostacoli, le porte,
# le stanze, le cose alte che coprono chi ci passa dietro e il giro del pilota
# automatico. La legge prove/LivelloProva.gd per farci camminare, e la usano
# le prove (prove/Prove.gd) per far fare al pilota il giro intero senza
# finestra.
#
# Sta in art/livelli/<nome>.json accanto alla mappa, art/livelli/<nome>.png.
# I numeri sono pixel del disegno: un rettangolo e' [x0, y0, x1, y1], con x1 e
# y1 fuori; un poligono e' una lista di punti [[x, y], ...]. "scala" dice
# quante volte il gioco ingrandisce il disegno (le Pianure: 2): qui dentro,
# dopo averla letta, tutto e' gia' in pixel del mondo. Dove si cammina conta
# il piede, il punto per terra al centro dei piedi: e' un rettangolo di 10x6,
# come nei mondi (MondoProva.libero).

const VELOCITA := 74.0
const ANGOLI_DEL_PIEDE := [Vector2(-5, -3), Vector2(4.9, -3), Vector2(-5, 2.9), Vector2(4.9, 2.9), Vector2.ZERO]
const ARRIVATO := 2.0            # a quanti pixel da un punto del giro il pilota passa al prossimo
const PASSO_DI_PROVA := 1.0 / 60.0

var nome := ""
var titolo := ""
var mappa := ""
var mappa_sopra := ""                    # le cose alte, ritagliate dalla mappa ("" se non ce ne sono)
var scala := 1.0
var ingrandimento := 3.0                 # quanto ingrandisce la telecamera
var limiti := Rect2()
var partenza := Vector2.ZERO
var verso := Vector2i(0, 1)
var pavimento: Array[Rect2] = []
var pavimento_poligoni: Array[PackedVector2Array] = []
var ostacoli: Array[Rect2] = []
var ostacoli_poligoni: Array[PackedVector2Array] = []
var porte: Array[Dictionary] = []        # {zona: Rect2, a: Vector2, verso: Vector2i}
var stanze: Array[Dictionary] = []       # {nome: String, rett: Rect2, poligono: PackedVector2Array}
var sopra: Array[Dictionary] = []        # {rett: Rect2, piede: float}
var giro: Array[Vector2] = []
var errore := ""


func carica(quale: String) -> bool:
	nome = quale
	var percorso := "res://art/livelli/%s.json" % quale
	if not FileAccess.file_exists(percorso):
		errore = "manca " + percorso
		return false
	var letto: Variant = JSON.parse_string(FileAccess.get_file_as_string(percorso))
	if not letto is Dictionary:
		errore = percorso + " non e' un oggetto JSON"
		return false
	var d: Dictionary = letto
	titolo = String(d.get("nome", quale))
	mappa = "res://art/livelli/" + String(d.get("mappa", quale + ".png"))
	mappa_sopra = "res://art/livelli/" + String(d["sopra_mappa"]) if d.has("sopra_mappa") else ""
	scala = float(d.get("scala", 1.0))
	ingrandimento = float(d.get("ingrandimento", 3.0))
	limiti = rettangolo(d.get("limiti", [0, 0, 0, 0]))
	partenza = punto(d.get("partenza", [0, 0]))
	var v: Array = d.get("verso", [0, 1])
	verso = Vector2i(int(v[0]), int(v[1]))
	pavimento.clear()
	pavimento_poligoni.clear()
	for f: Variant in d.get("pavimento", []):
		forma(f, pavimento, pavimento_poligoni)
	ostacoli.clear()
	ostacoli_poligoni.clear()
	for f: Variant in d.get("ostacoli", []):
		forma(f, ostacoli, ostacoli_poligoni)
	porte.clear()
	for p: Variant in d.get("porte", []):
		var porta: Dictionary = p
		var va: Array = porta.get("verso", [0, 1])
		porte.append({"zona": rettangolo(porta.get("zona", [0, 0, 0, 0])), "a": punto(porta.get("a", [0, 0])),
			"verso": Vector2i(int(va[0]), int(va[1]))})
	stanze.clear()
	for s: Variant in d.get("stanze", []):
		var stanza: Dictionary = s
		stanze.append({"nome": String(stanza.get("nome", "")),
			"rett": rettangolo(stanza["rett"]) if stanza.has("rett") else Rect2(),
			"poligono": poligono(stanza["poligono"]) if stanza.has("poligono") else PackedVector2Array()})
	sopra.clear()
	for s: Variant in d.get("sopra", []):
		var cosa: Array = s
		sopra.append({"rett": rettangolo(cosa.slice(0, 4)), "piede": float(cosa[4]) * scala})
	giro.clear()
	for p: Variant in d.get("giro", []):
		giro.append(punto(p))
	return true


func forma(f: Variant, rettangoli: Array[Rect2], poligoni: Array[PackedVector2Array]) -> void:
	# [x0, y0, x1, y1] e' un rettangolo, [[x, y], ...] un poligono
	var a: Array = f
	if not a.is_empty() and a[0] is Array:
		poligoni.append(poligono(a))
	else:
		rettangoli.append(rettangolo(a))


func rettangolo(a: Variant) -> Rect2:
	var r: Array = a
	return Rect2(float(r[0]) * scala, float(r[1]) * scala,
		(float(r[2]) - float(r[0])) * scala, (float(r[3]) - float(r[1])) * scala)


func punto(a: Variant) -> Vector2:
	var p: Array = a
	return Vector2(float(p[0]), float(p[1])) * scala


func poligono(a: Variant) -> PackedVector2Array:
	var punti := PackedVector2Array()
	for p: Variant in a:
		punti.append(punto(p))
	return punti


# ---------------------------------------------------------------- dove si cammina

func calpestabile(q: Vector2) -> bool:
	for o in ostacoli:
		if o.has_point(q):
			return false
	for o in ostacoli_poligoni:
		if Geometry2D.is_point_in_polygon(q, o):
			return false
	for r in pavimento:
		if r.has_point(q):
			return true
	for r in pavimento_poligoni:
		if Geometry2D.is_point_in_polygon(q, r):
			return true
	for porta in porte:
		var zona: Rect2 = porta["zona"]
		if zona.has_point(q):
			return true
	return false


func libero(p: Vector2) -> bool:
	for angolo: Vector2 in ANGOLI_DEL_PIEDE:
		if not calpestabile(p + angolo):
			return false
	return true


func cammina(piedi: Vector2, direzione: Vector2, delta: float) -> Vector2:
	# come nei mondi: prima di lato, poi in su o in giu', e contro uno spigolo
	# si scivola da soli se un poco piu' in la' si passa
	if direzione == Vector2.ZERO:
		return piedi
	direzione = direzione.normalized()
	var spostamento := direzione * VELOCITA * delta
	var p := piedi
	if libero(p + Vector2(spostamento.x, 0)):
		p.x += spostamento.x
	elif absf(direzione.y) < 0.3:
		p.y += scivola(p, Vector2(spostamento.x, 0), Vector2(0, 1), VELOCITA * delta)
	if libero(p + Vector2(0, spostamento.y)):
		p.y += spostamento.y
	elif absf(direzione.x) < 0.3:
		p.x += scivola(p, Vector2(0, spostamento.y), Vector2(1, 0), VELOCITA * delta)
	return p


func scivola(p: Vector2, avanti: Vector2, di_lato: Vector2, passo_max: float) -> float:
	for scarto in range(1, 8):
		for verso_lato: float in [-1.0, 1.0]:
			var prova := p + di_lato * float(scarto) * verso_lato
			if libero(prova) and libero(prova + avanti):
				return verso_lato * minf(passo_max, float(scarto))
	return 0.0


func porta_a(p: Vector2) -> int:
	for i in porte.size():
		var zona: Rect2 = porte[i]["zona"]
		if zona.has_point(p):
			return i
	return -1


func stanza_a(p: Vector2) -> String:
	for s in stanze:
		var r: Rect2 = s["rett"]
		var poli: PackedVector2Array = s["poligono"]
		if r.has_point(p) or (not poli.is_empty() and Geometry2D.is_point_in_polygon(p, poli)):
			return String(s["nome"])
	return ""


# ---------------------------------------------------------------- il pilota

func verso_il_giro(piedi: Vector2, tappa: int) -> Vector2:
	# dove andare per arrivare alla tappa: dritti
	if tappa < 0 or tappa >= giro.size():
		return Vector2.ZERO
	var manca := giro[tappa] - piedi
	return Vector2.ZERO if manca.length() < ARRIVATO else manca.normalized()


func fai_il_giro() -> String:
	# Il pilota fa tutto il giro, a passi di un sessantesimo di secondo, senza
	# disegnare niente. "" se arriva in fondo dopo essere passato da ogni stanza,
	# se no cosa e' andato storto.
	if giro.is_empty():
		return "il giro e' vuoto"
	if not libero(partenza):
		return "si parte da un posto dove non si sta: %s" % partenza
	var p := partenza
	var tappa := 1
	var fermo := 0.0
	var tempo := 0.0
	var viste := {}
	while tappa < giro.size():
		var direzione := verso_il_giro(p, tappa)
		if direzione == Vector2.ZERO:
			tappa += 1
			continue
		var dopo := cammina(p, direzione, PASSO_DI_PROVA)
		var porta := porta_a(dopo)
		if porta >= 0:
			dopo = porte[porta]["a"]
			tappa += 1
		fermo = fermo + PASSO_DI_PROVA if dopo.distance_to(p) < 0.01 else 0.0
		if fermo > 1.0:
			return "il pilota si ferma a %s andando verso %s (tappa %d)" % [p.round(), giro[tappa], tappa]
		p = dopo
		viste[stanza_a(p)] = true
		tempo += PASSO_DI_PROVA
		if tempo > 600.0:
			return "il giro non finisce in dieci minuti"
	for s in stanze:
		if not viste.has(s["nome"]):
			return "il giro non passa da %s" % s["nome"]
	return ""
