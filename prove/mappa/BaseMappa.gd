extends Control

# IL BANCO DI UNA PROPOSTA DI MAPPA: quello che le tre (VetrinaMappa,
# ManifestoMappa, PiantaMappa) hanno in comune. Ognuna disegna a strati, ogni
# strato un Control col suo disegno: cosi' il modellino si ritaglia nel suo
# riquadro e le scritte gli stanno sopra.
#
# "opz" dice cosa si sta guardando: "piano" il piano in primo piano (di solito
# quello in cui sei), "punta" la stanza sotto il cursore, se ce n'e' una.

const Modello := preload("res://prove/mappa/ModelloMappa.gd")
const Asso := preload("res://prove/mappa/Assonometria.gd")
const Pitto := preload("res://prove/mappa/Pittogrammi.gd")


class Strato extends Control:
	var disegno: Callable

	func _draw() -> void:
		disegno.call(self)


var m: Modello
var v := Asso.new()
var opz := {}
var occupati: Array[Rect2] = []    # dove ci sono gia' scritte: le altre ci girano intorno


func prepara(modello: Modello, opzioni: Dictionary) -> void:
	m = modello
	opz = opzioni
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	costruisci()


func costruisci() -> void:
	pass


func strato(dove: Rect2, disegno: Callable, ritaglia := false) -> Strato:
	var s := Strato.new()
	s.disegno = disegno
	s.position = dove.position
	s.size = dove.size
	s.clip_contents = ritaglia
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(s)
	return s


func piano_scelto() -> int:
	return int(opz.get("piano", m.piano_qui))


func puntata() -> String:
	return String(opz.get("punta", ""))


func guardata() -> String:
	# la stanza di cui parla la scheda: quella puntata, se no quella in cui sei
	return puntata() if puntata() != "" else m.qui


# --- le scritte -----------------------------------------------------------------

static func scrivi(t: Control, dove: Vector2, testo: String, corpo: int, tinta: Color, peso := 300.0, largo := 80.0,
		spazio := 2) -> void:
	DisegnoProiezione.scrivi(t, dove, testo, corpo, tinta, peso, largo, spazio)


static func misura_testo(testo: String, corpo: int, peso := 300.0, quanto := 80.0, spazio := 2) -> float:
	return DisegnoProiezione.larghezza(testo, corpo, peso, quanto, spazio)


static func tondo(t: CanvasItem, dove: Vector2, testo: String, corpo: int, tinta: Color, peso := 600,
		allinea := HORIZONTAL_ALIGNMENT_LEFT, largo_max := -1.0) -> void:
	t.draw_string(Caratteri.tondo(peso), dove, testo, allinea, largo_max, corpo, tinta)


static func largo_tondo(testo: String, corpo: int, peso := 600) -> float:
	return Caratteri.tondo(peso).get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x


static func titolo(t: CanvasItem, dove: Vector2, testo: String, corpo: int, tinta: Color) -> void:
	t.draw_string(Caratteri.titolo(), dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, tinta)


static func largo_titolo(testo: String, corpo: int) -> float:
	return Caratteri.titolo().get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x


static func etichetta(t: CanvasItem, dove: Vector2, testo: String, corpo: int, fondo: Color, inchiostro: Color) -> Rect2:
	# la fascia inclinata del manifesto; torna lo spazio che prende
	Manifesto.etichetta_tinta(t, dove, testo, corpo, fondo, inchiostro)
	var w := largo_titolo(testo, corpo) + corpo + Manifesto.INCLINA * corpo * 1.3
	return Rect2(dove, Vector2(w, corpo * 1.3))


static func misura_etichetta(testo: String, corpo: int) -> Vector2:
	return Vector2(largo_titolo(testo, corpo) + corpo + Manifesto.INCLINA * corpo * 1.3, corpo * 1.3)


func posto_libero(prove: Array[Rect2]) -> Rect2:
	# il primo posto che non pesta niente; se non ce n'e', il primo
	for r in prove:
		if not occupati.any(func(o: Rect2) -> bool: return o.intersects(r)):
			return r
	return Rect2() if prove.is_empty() else Rect2(prove[0].position, Vector2.ZERO)


static func tratteggio(t: CanvasItem, punti: PackedVector2Array, tinta: Color, spesso: float, pieno := 6.0, vuoto := 4.0) -> void:
	# un contorno a trattini, chiuso
	var n := punti.size()
	for i in n:
		var da := punti[i]
		var a := punti[(i + 1) % n]
		var lungo := da.distance_to(a)
		var k := 0.0
		while k < lungo:
			var fine := minf(k + pieno, lungo)
			t.draw_line(da.lerp(a, k / lungo), da.lerp(a, fine / lungo), tinta, spesso, true)
			k += pieno + vuoto


static func a_tratti(t: CanvasItem, punti: PackedVector2Array, tinta: Color, spesso: float, pieno := 5.0, vuoto := 4.0) -> void:
	# una spezzata aperta a trattini, che non ricomincia a ogni vertice
	var resto := 0.0
	for i in punti.size() - 1:
		var da := punti[i]
		var a := punti[i + 1]
		var lungo := da.distance_to(a)
		var k := -resto
		while k < lungo:
			var inizio := maxf(k, 0.0)
			var fine := minf(k + pieno, lungo)
			if fine > inizio:
				t.draw_line(da.lerp(a, inizio / lungo), da.lerp(a, fine / lungo), tinta, spesso, true)
			k += pieno + vuoto
		resto = k - lungo


static func intorno(cima: Vector2, w: float, h: float) -> Array[Rect2]:
	# i posti dove provare a mettere una scritta larga w e alta h intorno a un
	# punto: prima vicini e in alto, poi sempre piu' lontani
	var prove: Array[Rect2] = []
	for distanza: float in [30.0, 58.0, 90.0, 125.0]:
		for d: Vector2 in [Vector2(1, -1), Vector2(-1, -1), Vector2(1, 0), Vector2(-1, 0), Vector2(1, 1), Vector2(-1, 1),
				Vector2(0, -1.3), Vector2(0, 1.3)]:
			var dove := cima + d.normalized() * distanza
			var x := dove.x if d.x > 0.1 else (dove.x - w if d.x < -0.1 else dove.x - w * 0.5)
			var y := dove.y - h if d.y < -0.1 else (dove.y if d.y > 0.1 else dove.y - h * 0.5)
			prove.append(Rect2(Vector2(x, y), Vector2(w, h)))
	return prove


static func chiuso(punti: PackedVector2Array) -> PackedVector2Array:
	var p := punti.duplicate()
	if p.size() > 0 and p[0] != p[p.size() - 1]:
		p.append(p[0])
	return p


static func freccina(t: CanvasItem, da: Vector2, a: Vector2, tinta: Color, spesso: float) -> void:
	# un tratto con la punta: dove porta un'uscita
	t.draw_line(da, a, tinta, spesso, true)
	var dir := (a - da).normalized()
	var lato := Vector2(-dir.y, dir.x)
	var punta := spesso * 2.6
	Manifesto.poligono(t, PackedVector2Array([a + dir * punta * 0.6, a - dir * punta * 0.6 + lato * punta * 0.75,
			a - dir * punta * 0.6 - lato * punta * 0.75]), tinta)


# --- cosa dire di una stanza ------------------------------------------------------

func parola_dello_stato(s: Dictionary) -> String:
	match String(s["stato"]):
		"qui":
			return "SEI QUI"
		"vicina":
			return "CLIC · VAI" if s["visitata"] else "CLIC · ESPLORA"
		"chiusa":
			return "CHIUSA"
		"intravista":
			return "NON SAI COSA C'È"
	return "TROPPO LONTANO"


func freccia_del_piano(da: int, a: int) -> String:
	if a > da:
		return "↑"
	if a < da:
		return "↓"
	return "→"


func ponte(s: Dictionary) -> int:
	# se dalla stanza si sale o si scende: +1, -1, 0 (o 2 se tutte e due)
	var su := false
	var giu := false
	for altra in m.uscite(String(s["id"])):
		su = su or int(altra["piano"]) > int(s["piano"])
		giu = giu or int(altra["piano"]) < int(s["piano"])
	if su and giu:
		return 2
	return 1 if su else (-1 if giu else 0)
