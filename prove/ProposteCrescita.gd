extends Control

# LE PROPOSTE PER LA CRESCITA, terza mano. Provvisorio: quando Bru sceglie, la
# schermata vera nasce da quella scelta e questo file se ne va (come ProposteZaino).
#
# Bru: «basandoti sulle nostre grafiche mi faresti degli esempi di schermate di
# crescita? spesa punti e così via?». Prima mano: «sono pessime. devi impegnarti
# di più» (erano moduli). Seconda: «meno dettagli da circo, più astratto» (erano
# oggetti del luna park). Qui solo la lingua del manifesto, quella della pausa e
# dello zaino: l'arancio col retino, le lastre nere in diagonale, i rombi
# dell'emblema, le fasce storte, le scritte grandi, il contorno nero e l'ombra
# piena. Un punto da spendere e' un gettone a rombo.
#
#   1 costellazione   rombi collegati da fasce: si prende un rombo accanto a uno tuo
#   2 colonne         una colonna per linea, un tassello per grado, dal basso
#   3 quadrante       un anello a spicchi, uno per livello: il prossimo esce dall'anello
#   4 salto           il momento in cui sali: la barra a segmenti, il numero che piomba
#   5 incastri        le passive in tre alloggi a rombo, e tutte le altre sotto
#   6 bivio           un punto, due strade: lo schermo tagliato in due
#
# I nomi e le frasi vengono dai dati (abilita.json, crescita.json); i numeri
# (l'hype, il livello, cosa e' gia' preso) sono d'esempio, uguali in tutte.
#
#   ./prove/proposte_crescita.sh   le fotografa in scatti/proposte_crescita/
#   nell'editor: F6 su prove/ProposteCrescita.tscn; le frecce girano le sei

const P := preload("res://prove/PezziCrescita.gd")
const PROPOSTE := ["costellazione", "colonne", "quadrante", "salto", "incastri", "bivio"]
const CARTELLA := "res://scatti/proposte_crescita"
const HYPE := 3450
const LIVELLO := 7

var indice := 0
var tavola: Tavola
var tela: Disegno
var tempo := 1.3
var inizio := 0.0       # quando e' comparsa la schermata: le entrate contano da qui
var foto := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var argomenti := OS.get_cmdline_user_args()
	foto = "foto" in argomenti
	if not foto:
		# "-- film salto": parte da quella, per registrarla col Movie Maker
		var quale := PROPOSTE.find(argomenti[argomenti.find("film") + 1]) if "film" in argomenti and argomenti.size() > 1 else 0
		mostra(maxi(quale, 0))
		return
	DirAccess.make_dir_recursive_absolute(CARTELLA)
	for i in PROPOSTE.size():
		if argomenti.size() > 1 and not String(PROPOSTE[i]) in argomenti:
			continue
		mostra(i)
		for k in 8:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var immagine := get_viewport().get_texture().get_image()
		immagine.save_png(CARTELLA.path_join("%d_%s.png" % [i + 1, PROPOSTE[i]]))
		print("PROPOSTA %d: %s" % [i + 1, PROPOSTE[i]])
	get_tree().quit()


func _process(delta: float) -> void:
	if foto:
		return
	tempo += delta
	if tela != null:
		tela.queue_redraw()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_right"):
		mostra((indice + 1) % PROPOSTE.size())
	elif evento.is_action_pressed("ui_left"):
		mostra((indice + PROPOSTE.size() - 1) % PROPOSTE.size())


func mostra(quale: int) -> void:
	indice = quale
	if tavola != null:
		tavola.queue_free()
	tavola = Tavola.su(self)
	tela = Disegno.new()
	tela.come = Callable(self, "disegna_" + String(PROPOSTE[quale]))
	tavola.add_child(tela)
	Manifesto.trama_dietro(tela).show_behind_parent = true
	inizio = tempo - (20.0 if foto else 0.0)   # nelle foto, a entrata finita
	call("tasti_" + String(PROPOSTE[quale]))


class Disegno extends Control:
	var come: Callable

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)

	func _draw() -> void:
		come.call(self)


func comandi(dove: Vector2, coppie: Array, inchiostro: Color) -> void:
	# i tasti disegnati del gioco (TappoTasto) e cosa fanno, in fila
	var x := dove.x
	for coppia: Array in coppie:
		var tappo := TappoTasto.nuovo(String(coppia[0]))
		tavola.add_child(tappo)
		tappo.position = Vector2(x, dove.y)
		tappo.size = tappo.get_combined_minimum_size()
		x += tappo.size.x + 8.0
		var parola := Tavola.scritta(String(coppia[1]), 16, inchiostro, Caratteri.tondo(850))
		tavola.add_child(parola)
		parola.position = Vector2(x, dove.y - 2.0)
		parola.size = Vector2(parola.get_combined_minimum_size().x, tappo.size.y + 4.0)
		x += parola.size.x + 24.0


# --- i conti e i tempi ---------------------------------------------------------------------

static func abilita(id: String) -> Dictionary:
	var tutte: Dictionary = GameState.abilita.get("abilita", {})
	return tutte.get(id, {})


static func perche(azione: String) -> String:
	var regole: Dictionary = GameState.crescita.get("crescita", {})
	return "per " + String(regole.get(azione, {}).get("racconto", ""))


static func migliaia(n: int) -> String:
	var s := str(n)
	var fuori := ""
	while s.length() > 3:
		fuori = "." + s.substr(s.length() - 3) + fuori
		s = s.substr(0, s.length() - 3)
	return s + fuori


static func per_punto() -> int:
	return int(GameState.regole.get("hype_per_punto", 1000))


func entrata(da: float, durata: float) -> float:
	# dove e' un pezzo della sua entrata, da 0 a 1
	return clampf((tempo - inizio - da) / durata, 0.0, 1.0)


static func rimbalza(x: float) -> float:
	var c1 := 1.70158
	return 1.0 + (c1 + 1.0) * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0)


static func frena(x: float) -> float:
	return 1.0 - pow(1.0 - x, 3.0)


# --- i pezzi comuni ------------------------------------------------------------------------

static func testata(t: CanvasItem, titolo: String, sinistra_su_nero: bool, destra_su_nero: bool, livello := LIVELLO) -> void:
	# in alto a sinistra INDIETRO e la squadra (l'hype e' di tutti: si sceglie su
	# chi spenderlo); in alto a destra il titolo, come nello zaino e nella scheda
	var x := 16.0 + P.etichetta(t, Vector2(16, 12), "INDIETRO", 20, P.CREMA if sinistra_su_nero else P.NERO,
			P.NERO if sinistra_su_nero else P.CREMA) + 16.0
	var chi := [["ANONIMO", livello], ["VERONICA", 4], ["YHVINA", 2]]
	for i in chi.size():
		var testo := "%s · LV %d" % [chi[i][0], chi[i][1]]
		if i == 0:
			x += P.etichetta(t, Vector2(x, 14), testo, 17, P.ARANCIO, P.NERO, P.CREMA if sinistra_su_nero else P.NERO) + 20.0
		else:
			P.scritta(t, Vector2(x + 6, 37), testo, 17, P.CREMA if sinistra_su_nero else P.NERO)
			x += P.larghezza(testo, 17) + 32.0
	if titolo != "":
		var largo := P.larghezza(titolo, 40) + 44.0
		P.etichetta(t, Vector2(1262 - largo, 8), titolo, 40, P.CREMA if destra_su_nero else P.NERO,
				P.NERO if destra_su_nero else P.CREMA, P.ARANCIO)


static func gettoni(t: CanvasItem, dove: Vector2, inchiostro: Color, vuoto: Color, r := 15.0) -> void:
	# i punti da spendere: un rombo pieno per punto, e quello che si sta riempiendo
	var pieni := floori(float(HYPE) / per_punto())
	for i in pieni + 1:
		P.gettone(t, dove + Vector2(r * 2.6 * i, 0), r, 1.0 if i < pieni else float(HYPE % per_punto()) / per_punto(),
				inchiostro, vuoto)
	P.scritta(t, dove + Vector2(r * 2.6 * (pieni + 1) - 4, 6), "%d PUNTI" % pieni, 18, inchiostro)
	P.scritta(t, dove + Vector2(r * 2.6 * (pieni + 1) - 4, 26), "%s/%s al prossimo" % [migliaia(HYPE % per_punto()),
			migliaia(per_punto())], 13, inchiostro, Caratteri.tondo(900))


static func conto_hype(t: CanvasItem, dove: Vector2, inchiostro: Color, vuoto: Color) -> void:
	P.scritta(t, dove, "HYPE DELLA SQUADRA", 14, inchiostro, Caratteri.tondo(900))
	P.scritta(t, dove + Vector2(-4, 70), migliaia(HYPE), 72, inchiostro)
	gettoni(t, dove + Vector2(16, 112), inchiostro, vuoto)


# --- 1. la costellazione ------------------------------------------------------------------
#
# Le tre linee del protagonista partono dal suo emblema, a zig zag; fra una
# linea e l'altra le statistiche (tonde). Preso = arancio, unito da una fascia
# piena; quello che si puo' prendere ha la fascia tratteggiata che lo raggiunge;
# il resto e' un puntino spento.

const NODI := {
	"centro": Vector2(830, 430),
	"a0": Vector2(872, 352), "a1": Vector2(846, 274), "a2": Vector2(904, 206), "a3": Vector2(878, 136), "a4": Vector2(946, 84),
	"m0": Vector2(922, 456), "m1": Vector2(1002, 424), "m2": Vector2(1082, 470), "m3": Vector2(1160, 436), "m4": Vector2(1232, 488),
	"f0": Vector2(762, 500), "f1": Vector2(690, 466), "f2": Vector2(630, 540), "f3": Vector2(560, 508), "f4": Vector2(498, 580),
	"s1": Vector2(946, 372), "s2": Vector2(846, 548), "s3": Vector2(752, 384), "s4": Vector2(1016, 316), "s5": Vector2(862, 630),
}
const ARCHI := [["centro", "a0"], ["a0", "a1"], ["a1", "a2"], ["a2", "a3"], ["a3", "a4"],
	["centro", "m0"], ["m0", "m1"], ["m1", "m2"], ["m2", "m3"], ["m3", "m4"],
	["centro", "f0"], ["f0", "f1"], ["f1", "f2"], ["f2", "f3"], ["f3", "f4"],
	["a0", "s1"], ["m0", "s1"], ["m0", "s2"], ["f0", "s2"], ["f0", "s3"], ["a0", "s3"], ["s1", "s4"], ["s2", "s5"]]
const PRESI := ["centro", "a0", "m0", "f0", "s1", "s3", "s4"]
const SCELTO := "f1"
const STATISTICHE := {"s1": "+6 ATT", "s2": "+60 VITA", "s3": "+8 FATT", "s4": "+10 ATT", "s5": "+110 VITA"}
const LASTRA_COSTELLAZIONE := [Vector2(640, -20), Vector2(1300, -20), Vector2(1300, 740), Vector2(410, 740)]


static func stato_nodo(id: String) -> String:
	if id in PRESI:
		return "preso"
	for arco: Array in ARCHI:
		if (String(arco[0]) == id and String(arco[1]) in PRESI) or (String(arco[1]) == id and String(arco[0]) in PRESI):
			return "aperto"
	return "chiuso"


func disegna_costellazione(t: CanvasItem) -> void:
	var lastra := PackedVector2Array(LASTRA_COSTELLAZIONE)
	P.lastra(t, lastra)
	P.puntini(t, Rect2(400, 0, 880, 720), 34.0, Color(P.CREMA, 0.07),
			func(q: Vector2) -> bool: return Geometry2D.is_point_in_polygon(q, lastra))
	P.gira(t, Vector2(440, 714), -8.0)
	P.scritta(t, Vector2.ZERO, "CRESCITA", 236, Color(P.CREMA, 0.05))
	P.dritto(t)
	for arco: Array in ARCHI:
		arco_costellazione(t, String(arco[0]), String(arco[1]))
	for id: String in NODI:
		nodo(t, id)
	P.etichetta(t, NODI["a2"] + Vector2(28, -14), "ANNICHILAZIONE", 14, P.CREMA, P.NERO)
	P.etichetta(t, NODI["m2"] + Vector2(-40, 28), "MANTRA", 14, P.CREMA, P.NERO)
	P.etichetta(t, NODI["f3"] + Vector2(-64, 28), "FLAGELLO", 14, P.CREMA, P.NERO)
	conto_hype(t, Vector2(30, 98), P.NERO, Color(P.NERO, 0.14))
	var dal: Vector2 = NODI[SCELTO] + Vector2(-38, 0)
	t.draw_line(dal, Vector2(400, dal.y), P.NERO, 7.0)
	t.draw_line(dal, Vector2(400, dal.y), P.CREMA, 3.0)
	scheda_scelta(t, Rect2(24, 300, 372, 262), "terra_bruciata", "FLAGELLO · GRADO II", "PRENDI · 1 PUNTO")
	testata(t, "CRESCITA", false, true)


func arco_costellazione(t: CanvasItem, da: String, a: String) -> void:
	var p: Vector2 = NODI[da]
	var q: Vector2 = NODI[a]
	var sa := stato_nodo(da)
	var sb := stato_nodo(a)
	if sa == "preso" and sb == "preso":
		t.draw_line(p, q, P.ARANCIO, 7.0, true)
	elif "preso" in [sa, sb]:
		t.draw_dashed_line(p, q, P.CREMA, 3.0, 9.0, true, true)
	else:
		t.draw_line(p, q, Color(P.TRATTO, 0.5), 2.0, true)


func nodo(t: CanvasItem, id: String) -> void:
	var c: Vector2 = NODI[id]
	if id == "centro":
		P.rombo(t, c, 50.0, P.NERO, P.CREMA, 3.0)
		Sagome.emblema(t, c, 64.0, P.CREMA, P.ARANCIO)
		return
	var tondo := id.begins_with("s")
	var stato := stato_nodo(id)
	var batte := 0.5 + 0.5 * sin(tempo * 3.0)
	if id == SCELTO:
		P.rombo(t, c, 40.0 + 4.0 * batte, Color(0, 0, 0, 0), P.ARANCIO, 4.0)
		P.rombo(t, c + Vector2(5, 5), 26.0, P.ARANCIO_SCURO)
		P.rombo(t, c, 26.0, P.ARANCIO, P.CREMA, 4.0)
		P.glifo(t, "fiamma", c, 26.0, P.NERO, P.ARANCIO)
		return
	match stato:
		"preso":
			if tondo:
				t.draw_circle(c, 11.0, P.ARANCIO, true, -1.0, true)
				t.draw_arc(c, 11.0, 0.0, TAU, 32, P.CREMA, 3.0, true)
			else:
				P.rombo(t, c, 15.0, P.ARANCIO, P.CREMA, 3.0)
		"aperto":
			if tondo:
				t.draw_circle(c, 11.0, P.NERO, true, -1.0, true)
				t.draw_arc(c, 11.0, 0.0, TAU, 32, P.CREMA, 3.0, true)
				t.draw_circle(c, 4.0, P.ARANCIO, true, -1.0, true)
			else:
				P.rombo(t, c, 22.0 + 3.0 * batte, Color(0, 0, 0, 0), Color(P.CREMA, 0.3), 2.0)
				P.rombo(t, c, 15.0, P.NERO, P.CREMA, 3.0)
				P.rombo(t, c, 5.5, P.ARANCIO)
		_:
			if tondo:
				t.draw_circle(c, 5.0, P.TRATTO, true, -1.0, true)
			else:
				P.rombo(t, c, 7.0, P.TRATTO)
	if tondo and STATISTICHE.has(id):
		P.scritta(t, c + Vector2(16, 6), String(STATISTICHE[id]), 14, P.CREMA if stato != "chiuso" else P.TRATTO)


func scheda_scelta(t: CanvasItem, r: Rect2, id: String, che_cosa: String, azione: String) -> void:
	var dati := abilita(id)
	P.gira(t, r.position, -2.0)
	P.cartoncino(t, Rect2(Vector2.ZERO, r.size), P.CREMA, 4.0, P.OMBRA, true)
	P.etichetta(t, Vector2(16, -16), che_cosa, 15, P.NERO, P.CREMA)
	P.scritta(t, Vector2(18, 66), String(dati.get("nome", id)), 38, P.NERO)
	P.a_capo(t, Rect2(18, 78, r.size.x - 36, 70), String(dati.get("descrizione", "")), 17, Color(P.NERO, 0.82))
	P.scritta(t, Vector2(18, 178), "COSTA", 13, Color(P.NERO, 0.7), Caratteri.tondo(900))
	P.scritta(t, Vector2(76, 180), "1 PUNTO", 22, P.NERO)
	P.scritta(t, Vector2(196, 178), "AURA", 13, Color(P.NERO, 0.7), Caratteri.tondo(900))
	P.scritta(t, Vector2(244, 180), str(int(dati.get("aura", 0))), 22, P.NERO)
	P.scritta(t, Vector2(18, 208), "LIVELLO %d → %d" % [LIVELLO, LIVELLO + 1], 18, P.ARANCIO_SCURO)
	P.etichetta(t, Vector2(16, 222), azione, 22, P.NERO, P.CREMA, P.ARANCIO)
	P.dritto(t)


func tasti_costellazione() -> void:
	comandi(Vector2(846, 690), [["SU", "muoviti"], ["INVIO", "prendi"], ["ESC", "indietro"]], P.CARTA)


# --- 2. le colonne -------------------------------------------------------------------------
#
# Una colonna per linea, un tassello per grado, dal basso verso l'alto: si
# vede subito quanto e' salita ognuna. Preso = arancio; il prossimo di ogni
# colonna ha il bordo chiaro; quello scelto esce dalla colonna.

const COLONNE := [["FLAGELLO", "flagello"], ["ANNICHILAZIONE", "annichilazione"], ["MANTRA", "mantra"]]
const LASTRA_COLONNE := [Vector2(990, -20), Vector2(1300, -20), Vector2(1300, 740), Vector2(864, 740)]


static func lungo_il_taglio(y: float) -> float:
	# dove comincia la lastra a quell'altezza: il dettaglio segue il taglio
	var a: Vector2 = LASTRA_COLONNE[0]
	var b: Vector2 = LASTRA_COLONNE[3]
	return lerpf(a.x, b.x, (y - a.y) / (b.y - a.y)) + 30.0


static func linea(nome_linea: String) -> Array[Dictionary]:
	var gradi: Array[Dictionary] = []
	var tutte: Dictionary = GameState.abilita.get("abilita", {})
	for id: String in tutte:
		var dati: Dictionary = tutte[id]
		if String(dati.get("linea", "")) == nome_linea:
			var copia := dati.duplicate()
			copia["id"] = id
			gradi.append(copia)
	gradi.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("grado", 0)) < int(b.get("grado", 0)))
	return gradi


func disegna_colonne(t: CanvasItem) -> void:
	P.lastra(t, PackedVector2Array(LASTRA_COLONNE))
	# l'hype in riga, non in colonna: sotto ci stanno le colonne
	P.scritta(t, Vector2(30, 92), "HYPE DELLA SQUADRA", 14, P.NERO, Caratteri.tondo(900))
	P.scritta(t, Vector2(26, 162), migliaia(HYPE), 72, P.NERO)
	gettoni(t, Vector2(252, 136), P.NERO, Color(P.NERO, 0.14))
	for i in COLONNE.size():
		colonna(t, 30.0 + 270.0 * i, COLONNE[i], i == 0)
	dettaglio_sulla_lastra(t, "terra_bruciata", "FLAGELLO · GRADO II")
	testata(t, "CRESCITA", false, true)


func colonna(t: CanvasItem, x0: float, dati: Array, con_la_scelta: bool) -> void:
	var su := 236.0
	var giu := 704.0
	var pende := 26.0
	P.lastra(t, PackedVector2Array([Vector2(x0 + pende, su), Vector2(x0 + 252, su), Vector2(x0 + 252 - pende, giu),
			Vector2(x0, giu)]), P.NERO, P.CREMA, -8.0)
	var gradi := linea(String(dati[1]))
	var largo := P.etichetta(t, Vector2(x0 + 30, su - 22), String(dati[0]), 18, P.CREMA, P.NERO, P.ARANCIO)
	P.scritta(t, Vector2(x0 + 44 + largo, su - 6), "1 DI %d" % gradi.size(), 13, P.NERO, Caratteri.tondo(900))
	var romani := ["I", "II", "III", "IV", "V", "VI"]
	for g in mini(gradi.size(), 6):
		var y := giu - 18.0 - 70.0 * (g + 1)
		var x := x0 + 14.0 + pende * (giu - y) / (giu - su)
		var stato := "preso" if g == 0 else ("scelto" if con_la_scelta and g == 1 else ("aperto" if g == 1 else "chiuso"))
		tassello(t, Rect2(x, y, 218, 58), romani[g], String(gradi[g].get("nome", "")), int(gradi[g].get("livello", 0)), stato)


func tassello(t: CanvasItem, r: Rect2, romano: String, nome_grado: String, livello: int, stato: String) -> void:
	var batte := 0.5 + 0.5 * sin(tempo * 3.0)
	var forma := P.storta(r, 0.14)
	match stato:
		"preso":
			Manifesto.poligono(t, forma, P.ARANCIO)
		"scelto":
			var fuori := P.storta(Rect2(r.position + Vector2(-10, -6), r.size + Vector2(28, 12)), 0.14)
			var sotto := PackedVector2Array()
			for q in fuori:
				sotto.append(q + Vector2(8, 7))
			Manifesto.poligono(t, sotto, P.ARANCIO)
			Manifesto.poligono(t, fuori, P.CREMA)
		"aperto":
			Manifesto.poligono(t, forma, P.NERO)
			var bordo := forma.duplicate()
			bordo.append(forma[0])
			t.draw_polyline(bordo, Color(P.CREMA, 0.5 + 0.5 * batte), 3.0, true)
		_:
			Manifesto.poligono(t, forma, P.SPENTO)
	var inchiostro := P.NERO if stato in ["preso", "scelto"] else (P.CREMA if stato == "aperto" else P.TRATTO)
	P.scritta(t, r.position + Vector2(18, 38), romano, 20, inchiostro)
	var largo := r.size.x - 74.0
	if stato == "chiuso":
		# quelli lontani: il nome e, sotto, da che livello
		P.scritta(t, r.position + Vector2(60, 29), nome_grado, P.corpo_che_entra(nome_grado, 17, largo), inchiostro)
		P.scritta(t, r.position + Vector2(60, 47), "DAL LIVELLO %d" % livello, 11, P.TRATTO, Caratteri.tondo(900))
	else:
		P.scritta(t, r.position + Vector2(60, 38), nome_grado, P.corpo_che_entra(nome_grado, 18, largo), inchiostro)


func dettaglio_sulla_lastra(t: CanvasItem, id: String, che_cosa: String) -> void:
	# ogni riga parte dal taglio della lastra, cosi' il dettaglio pende con lei
	var dati := abilita(id)
	var nome := String(dati.get("nome", id)).to_upper()
	var righe: Array[String] = [nome]
	if P.larghezza(nome, 44) > 1250.0 - lungo_il_taglio(190):
		righe = [nome.get_slice(" ", 0), nome.substr(nome.find(" ") + 1)]
	P.scritta(t, Vector2(lungo_il_taglio(132), 132), "LIVELLO %d → %d" % [LIVELLO, LIVELLO + 1], 18, P.ARANCIO)
	var y := 184.0
	for riga in righe:
		P.scritta(t, Vector2(lungo_il_taglio(y), y), riga, 44, P.CREMA)
		y += 46.0
	P.etichetta(t, Vector2(lungo_il_taglio(y) - 4, y - 24), che_cosa, 15, P.ARANCIO, P.NERO)
	y += 22.0
	P.a_capo(t, Rect2(lungo_il_taglio(y), y, 1252.0 - lungo_il_taglio(y), 120), String(dati.get("descrizione", "")), 17, P.CARTA)
	P.scritta(t, Vector2(lungo_il_taglio(440), 440), "COSTA", 13, P.CARTA, Caratteri.tondo(900))
	P.scritta(t, Vector2(lungo_il_taglio(440) + 60, 442), "1 PUNTO", 22, P.CREMA)
	P.scritta(t, Vector2(lungo_il_taglio(472), 472), "AURA", 13, P.CARTA, Caratteri.tondo(900))
	P.scritta(t, Vector2(lungo_il_taglio(472) + 60, 474), str(int(dati.get("aura", 0))), 22, P.CREMA)
	P.etichetta(t, Vector2(lungo_il_taglio(580) - 8, 566), "PRENDI · 1 PUNTO", 24, P.ARANCIO, P.NERO, P.CREMA)


func tasti_colonne() -> void:
	comandi(Vector2(916, 690), [["INVIO", "prendi"], ["ESC", "indietro"]], P.CARTA)


# --- 3. il quadrante -----------------------------------------------------------------------
#
# Il tronco della demo come un anello di venti spicchi, uno per livello. Quelli
# presi sono neri; il prossimo esce dall'anello, chiaro, dove punta la lancetta;
# gli altri sono solo il contorno.

const CENTRO_QUADRANTE := Vector2(892, 392)
const DENTRO := 206.0
const FUORI := 300.0
const SPICCHI := 20


func disegna_quadrante(t: CanvasItem) -> void:
	quadrante(t)
	P.lastra(t, PackedVector2Array([Vector2(-20, -20), Vector2(606, -20), Vector2(440, 740), Vector2(-20, 740)]),
			P.NERO, P.CREMA, 16.0)
	gettoni(t, Vector2(46, 104), P.CREMA, Color(P.CREMA, 0.14))
	var dati := abilita("terra_bruciata")
	P.scritta(t, Vector2(36, 188), "ARRIVI AL", 18, P.CARTA)
	P.ritagliata(t, Vector2(30, 340), str(LIVELLO + 1), 170, P.ARANCIO, P.NERO, 0, P.ARANCIO_SCURO, Vector2(10, 10))
	P.scritta(t, Vector2(162, 238), "LIVELLO", 34, P.CREMA)
	P.scritta(t, Vector2(162, 268), "%d DI %d" % [LIVELLO + 1, SPICCHI], 15, P.CARTA, Caratteri.tondo(900))
	P.scritta(t, Vector2(34, 410), String(dati.get("nome", "")).to_upper(), 38, P.CREMA)
	P.etichetta(t, Vector2(30, 422), "FLAGELLO · GRADO II", 15, P.ARANCIO, P.NERO)
	P.a_capo(t, Rect2(34, 462, 350, 70), String(dati.get("descrizione", "")), 16, P.CARTA)
	P.scritta(t, Vector2(34, 562), "COSTA 1 PUNTO · AURA %d" % int(dati.get("aura", 0)), 18, P.CREMA)
	P.etichetta(t, Vector2(30, 584), "PRENDI · 1 PUNTO", 26, P.ARANCIO, P.NERO, P.CREMA)
	testata(t, "CRESCITA", true, false)


func angolo_spicchio(k: int) -> float:
	# il prossimo (k = LIVELLO) sta a sinistra, dove punta la lancetta; quelli
	# dopo salgono, quelli presi scendono
	return PI + deg_to_rad(360.0 / SPICCHI * (k - LIVELLO))


func quadrante(t: CanvasItem) -> void:
	var c := CENTRO_QUADRANTE
	var mezzo := deg_to_rad(360.0 / SPICCHI * 0.5 - 1.0)
	for k in SPICCHI:
		var a := angolo_spicchio(k)
		var tacca := a + mezzo + deg_to_rad(1.0)
		t.draw_line(c + Vector2.from_angle(tacca) * (FUORI + 6), c + Vector2.from_angle(tacca) * (FUORI + 16), P.NERO, 2.0, true)
		if k == LIVELLO:
			continue
		var preso := k < LIVELLO
		P.spicchio(t, c, DENTRO, FUORI, a - mezzo, a + mezzo, P.NERO if preso else Color(0, 0, 0, 0), P.NERO, 2.0)
		var mezzo_raggio := c + Vector2.from_angle(a) * (DENTRO + FUORI) * 0.5
		P.scritta(t, mezzo_raggio + Vector2(-30, 8), str(k + 1), 22, P.CREMA if preso else Color(P.NERO, 0.45), null,
				HORIZONTAL_ALIGNMENT_CENTER, 60)
	var a8 := angolo_spicchio(LIVELLO)
	var batte := 0.5 + 0.5 * sin(tempo * 3.0)
	var spinta := c + Vector2.from_angle(a8) * (12.0 + 4.0 * batte)
	P.spicchio(t, spinta + Vector2(8, 8), DENTRO + 10, FUORI + 34, a8 - mezzo - 0.05, a8 + mezzo + 0.05, P.NERO)
	P.spicchio(t, spinta, DENTRO + 10, FUORI + 34, a8 - mezzo - 0.05, a8 + mezzo + 0.05, P.CREMA, P.NERO, 4.0)
	var dove := spinta + Vector2.from_angle(a8) * (DENTRO + FUORI + 44) * 0.5
	P.glifo(t, "fiamma", dove + Vector2(0, -16), 34.0, P.NERO, P.CREMA)
	P.scritta(t, dove + Vector2(-30, 30), str(LIVELLO + 1), 28, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 60)
	t.draw_circle(c, 190.0, P.NERO, true, -1.0, true)
	t.draw_arc(c, 176.0, 0.0, TAU, 96, P.ARANCIO, 3.0, true)
	Manifesto.poligono(t, PackedVector2Array([c + Vector2(-216, 0), c + Vector2(-178, -18), c + Vector2(-178, 18)]), P.ARANCIO)
	Sagome.emblema(t, c + Vector2(0, -70), 84.0, P.CREMA, P.ARANCIO)
	P.scritta(t, c + Vector2(-90, 4), "LIVELLO", 15, P.CARTA, Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER, 180)
	P.scritta(t, c + Vector2(-90, 108), str(LIVELLO), 104, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 180)


func tasti_quadrante() -> void:
	comandi(Vector2(30, 686), [["SU", "gira"], ["INVIO", "prendi"], ["ESC", "indietro"]], P.CARTA)


# --- 4. il salto ----------------------------------------------------------------------------
#
# Salire di livello deve essere un momento: la barra dei livelli si riempie a
# segmenti, l'ultimo scoppia, e il numero nuovo piomba grande come lo schermo.
# Sotto, il perche' di ogni punto: le frasi di crescita.json.

func disegna_salto(t: CanvasItem) -> void:
	P.raggi(t, Vector2(930, 230), 24, 1700.0, P.ARANCIO, Color("#e8830f"), tempo * 0.04)
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, 548), Vector2(1300, 300), Vector2(1300, 740), Vector2(-20, 740)]), P.CREMA)
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, 560), Vector2(1300, 312), Vector2(1300, 740), Vector2(-20, 740)]), P.NERO)
	barra_dei_livelli(t)
	var entra := frena(entrata(0.55, 0.3))
	if entra > 0.0:
		P.gira(t, Vector2(470 - 500 * (1.0 - entra), 176), -7.0)
		P.ritagliata(t, Vector2(0, 0), "LIVELLO", 78, P.CREMA, P.NERO, 14, P.NERO, Vector2(8, 8))
		P.dritto(t)
	var piomba := entrata(0.72, 0.2)
	if piomba > 0.0:
		var scala := lerpf(2.4, 1.0, frena(piomba))
		var scossa := Vector2(sin(tempo * 90.0), cos(tempo * 77.0)) * 10.0 * (1.0 - entrata(0.92, 0.25)) if piomba >= 1.0 else Vector2.ZERO
		P.gira(t, Vector2(800, 428) + scossa, -7.0, scala)
		P.ritagliata(t, Vector2.ZERO, str(LIVELLO + 1), 330, Color(P.CREMA, minf(piomba * 3.0, 1.0)), P.NERO, 22,
				P.ARANCIO_SCURO, Vector2(16, 14))
		P.dritto(t)
	var appare := entrata(1.6, 0.35)
	if appare > 0.0:
		adesivo(t, Vector2(1122, 146), "NUOVA ABILITÀ", "TERRA BRUCIATA", rimbalza(appare))
	var righe := [["lama", "ATTACCO", "attacchi_sferrati", 15, 17], ["cuore", "PUNTI VITA", "danni_subiti", 100, 110],
			["occhio", "INTELLIGENZA", "studi", 1, 2], ["saetta", "VELOCITÀ", "stanze_esplorate", 3, 4]]
	for i in righe.size():
		var arriva := frena(entrata(1.0 + 0.14 * i, 0.32))
		if arriva > 0.0:
			striscia_della_crescita(t, Vector2(548 + 10 * i + 760 * (1.0 - arriva), 450 + 63 * i), righe[i], -0.6 if i % 2 == 0 else 0.5)


func barra_dei_livelli(t: CanvasItem) -> void:
	# otto segmenti uno sull'altro, pendenti come le fasce: si accendono dal basso,
	# l'ottavo scoppia (lo scoppio sta dietro a tutti, non copre il settimo)
	var scoppia := entrata(0.32, 0.26)
	if scoppia > 0.0:
		var giro := Rect2(70.0 + 0.16 * 70.0 * LIVELLO, 606.0 - 70.0 * LIVELLO, 150, 58).get_center()
		P.scoppio(t, giro, 112.0 * rimbalza(scoppia), 74.0 * rimbalza(scoppia), 14, P.CREMA, P.NERO, 7.0, tempo * 0.3)
	for i in LIVELLO + 1:
		var appare := entrata(0.03 * i, 0.12) if i < LIVELLO else scoppia
		if appare <= 0.0:
			continue
		var y := 664.0 - 70.0 * i
		var x := 70.0 + 0.16 * (664.0 - y)
		var r := Rect2(x, y - 58, 150, 58)
		var ultimo := i == LIVELLO
		var forma := P.storta(r, 0.16)
		var ombra := PackedVector2Array()
		for q in forma:
			ombra.append(q + Vector2(7, 6))
		Manifesto.poligono(t, ombra, P.NERO)
		Manifesto.poligono(t, forma, P.ARANCIO if ultimo else P.CREMA)
		var bordo := forma.duplicate()
		bordo.append(forma[0])
		t.draw_polyline(bordo, P.NERO, 3.0, true)
		P.scritta(t, r.position + Vector2(0, 44), str(i + 1), 34 if ultimo else 26, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var su := entrata(0.4, 0.3)
	if su > 0.0:
		P.gira(t, Vector2(250, 110), -10.0, rimbalza(su))
		P.ritagliata(t, Vector2.ZERO, "+1", 64, P.NERO, P.CREMA, 10)
		P.dritto(t)


func adesivo(t: CanvasItem, c: Vector2, sopra: String, sotto: String, scala := 1.0) -> void:
	P.gira(t, c, 9.0, scala)
	P.scoppio(t, Vector2.ZERO, 128.0, 100.0, 18, P.CREMA, P.NERO, 6.0)
	P.scritta(t, Vector2(-90, -6), sopra, 18, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 180)
	P.scritta(t, Vector2(-100, 26), sotto, 20, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 200)
	P.rombo(t, Vector2(0, -42), 12.0, P.ARANCIO, P.NERO, 2.0)
	P.dritto(t)


func striscia_della_crescita(t: CanvasItem, dove: Vector2, riga: Array, gradi: float) -> void:
	# una striscia di carta: il disegno, cosa e' cresciuto, perche', di quanto
	P.gira(t, dove, gradi)
	Manifesto.poligono(t, P.storta(Rect2(0, 0, 600, 48), 0.18), P.CREMA)
	P.glifo(t, String(riga[0]), Vector2(36, 24), 32.0, P.NERO)
	P.scritta(t, Vector2(66, 24), String(riga[1]), 24, P.NERO)
	P.scritta(t, Vector2(66, 42), perche(String(riga[2])), 14, Color(P.NERO, 0.75), Caratteri.tondo(800))
	P.scritta(t, Vector2(386, 36), str(int(riga[3])), 28, Color(P.NERO, 0.45), null, HORIZONTAL_ALIGNMENT_RIGHT, 70)
	Sagome.freccia(t, Vector2(480, 25), 26.0, Vector2.RIGHT, P.NERO)
	P.scritta(t, Vector2(490, 40), str(int(riga[4])), 38, P.ARANCIO_SCURO, null, HORIZONTAL_ALIGNMENT_RIGHT, 84)
	P.dritto(t)


func tasti_salto() -> void:
	comandi(Vector2(1124, 692), [["INVIO", "avanti"]], P.CARTA)


# --- 5. gli incastri --------------------------------------------------------------------
#
# Le passive si sbloccano salendo, e se ne portano tre: tre alloggi a rombo su
# una fascia nera. Si tolgono e si rimettono quando vuoi (docs/albero.md, 4.5).

const PASSIVE := [
	["Non c'è tempo!", "clessidra", "in uso", ""],
	["La tua immondizia è il mio tesoro", "gemma", "in uso", ""],
	["Battito dell'eroe", "battito", "scelta", ""],
	["Trinità", "tre", "chiusa", "LV 33"],
	["Presenza minacciosa", "occhio", "chiusa", "LV 40"],
	["Furia", "fiamma", "chiusa", "FATTORE 15/20"],
	["Perspicacia acuta", "occhio", "chiusa", "INTELL. 6/40"],
]


func disegna_incastri(t: CanvasItem) -> void:
	fascia_degli_alloggi(t)
	tutte_le_passive(t)
	P.etichetta(t, Vector2(28, 64), "PASSIVE", 46, P.NERO, P.CREMA, P.CREMA)
	P.scritta(t, Vector2(34, 158), "ANONIMO · LIVELLO 24", 18, P.NERO)
	P.scritta(t, Vector2(34, 182), "Se ne portano tre. Si cambiano quando vuoi.", 16, P.NERO, Caratteri.tondo(800))
	dettaglio_passiva(t, Rect2(880, 28, 370, 148))
	testata(t, "", false, false, 24)


func alloggio(t: CanvasItem, c: Vector2, r: float, glifo: String, stato: String) -> void:
	match stato:
		"vuoto":
			var forma := Sagome.chiudi(Sagome.rombo(c, r))
			for i in 4:
				var a: Vector2 = forma[i]
				var b: Vector2 = forma[i + 1]
				t.draw_dashed_line(a, b, Color(P.CREMA, 0.8), 3.0, 10.0, true, true)
			P.scritta(t, c + Vector2(-r, 18), "+", 56, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0)
		"chiusa":
			P.rombo(t, c + Vector2(5, 5), r, Color(P.NERO, 0.5))
			P.rombo(t, c, r, P.BRUNO, P.NERO, 4.0)
			P.glifo(t, glifo, c, r * 0.9, Color(P.CARTA, 0.2), P.BRUNO)
			Sagome.lucchetto(t, c + Vector2(r * 0.42, r * 0.42), r * 0.5, P.CREMA)
		_:
			P.rombo(t, c + Vector2(6, 6), r, P.NERO)
			P.rombo(t, c, r, P.ARANCIO if stato == "scelta" else P.ARANCIO_SCURO, P.NERO, 5.0)
			P.rombo(t, c, r * 0.74, P.CREMA, P.NERO, 3.0)
			P.glifo(t, glifo, c, r * 0.8, P.NERO, P.CREMA)


func fascia_degli_alloggi(t: CanvasItem) -> void:
	P.gira(t, Vector2(600, 356), -4.5)
	t.draw_rect(Rect2(-760, -100, 1560, 200), P.NERO)
	t.draw_rect(Rect2(-760, -112, 1560, 8), P.CREMA)
	var posti := [["clessidra", "in uso", "NON C'È TEMPO!"], ["gemma", "in uso", "LA TUA IMMONDIZIA..."], ["", "vuoto", "PORTANE UNA"]]
	for i in posti.size():
		var c := Vector2(-420 + 250 * i, -12)
		alloggio(t, c, 70.0, String(posti[i][0]), String(posti[i][1]))
		P.scritta(t, c + Vector2(-120, 88), String(posti[i][2]), 16, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 240)
	var quarto := Vector2(330, -12)
	P.rombo(t, quarto, 70.0, Color(0, 0, 0, 0), Color(P.CREMA, 0.25), 3.0)
	Sagome.lucchetto(t, quarto, 34.0, Color(P.CREMA, 0.4))
	P.scritta(t, quarto + Vector2(-120, 88), "AL LIVELLO 30", 16, Color(P.CREMA, 0.5), null, HORIZONTAL_ALIGNMENT_CENTER, 240)
	P.dritto(t)


func tutte_le_passive(t: CanvasItem) -> void:
	P.gira(t, Vector2(40, 526), 1.2)
	P.cartoncino(t, Rect2(0, 0, 968, 176), P.CREMA, 5.0, P.OMBRA, true)
	P.etichetta(t, Vector2(16, -18), "TUTTE LE PASSIVE · 3 DI 24", 18, P.NERO, P.CREMA)
	for i in PASSIVE.size():
		var voce: Array = PASSIVE[i]
		var c := Vector2(76 + 136 * i, 76)
		var stato := String(voce[2])
		if stato == "scelta":
			P.rombo(t, c, 60.0, Color(P.ARANCIO, 0.35), P.NERO, 3.0)
		alloggio(t, c, 42.0, String(voce[1]), "in uso" if stato == "in uso" else stato)
		var sotto := String(voce[0]) if String(voce[3]) == "" else String(voce[3])
		P.a_capo(t, Rect2(c.x - 66, 124, 132, 40), sotto, 14, P.NERO, Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER)
		if stato == "in uso":
			P.etichetta(t, c + Vector2(4, -56), "IN USO", 11, P.NERO, P.CREMA)
	P.dritto(t)


func dettaglio_passiva(t: CanvasItem, r: Rect2) -> void:
	var dati := {}
	for voce: Dictionary in GameState.crescita.get("passive_livello", []):
		if String(voce.get("id", "")) == "battito_dell_eroe":
			dati = voce
	P.gira(t, r.position, -2.0)
	P.cartoncino(t, Rect2(Vector2.ZERO, r.size), P.NERO, 0.0, P.OMBRA)
	P.etichetta(t, Vector2(16, -16), "SBLOCCATA AL LIVELLO 23", 14, P.ARANCIO, P.NERO)
	P.scritta(t, Vector2(20, 50), "Battito dell'eroe", 32, P.CREMA)
	P.a_capo(t, Rect2(20, 60, r.size.x - 40, 60), String(dati.get("descrizione", "")), 15, P.CARTA)
	P.etichetta(t, Vector2(18, r.size.y - 20), "PORTALA", 22, P.ARANCIO, P.NERO, P.CREMA)
	P.dritto(t)


func tasti_incastri() -> void:
	comandi(Vector2(1030, 560), [["CLIC", "prendi"]], P.NERO)
	comandi(Vector2(1030, 610), [["INVIO", "porta"]], P.NERO)
	comandi(Vector2(1030, 660), [["ESC", "indietro"]], P.NERO)


# --- 6. il bivio ----------------------------------------------------------------------------
#
# Un punto, due strade. Lo schermo tagliato in due: a sinistra una, a destra
# l'altra; quella scelta prende piu' spazio. Nel taglio, il punto che si spende.

const TAGLIO_ALTO := 640.0
const TAGLIO_BASSO := 520.0


func disegna_bivio(t: CanvasItem) -> void:
	var batte := 0.5 + 0.5 * sin(tempo * 2.0)
	Manifesto.poligono(t, PackedVector2Array([Vector2(TAGLIO_ALTO, -20), Vector2(1300, -20), Vector2(1300, 740),
			Vector2(TAGLIO_BASSO, 740)]), P.CREMA)
	Manifesto.retino(t, Rect2(520, 0, 760, 720), Color(P.NERO, 0.07), Vector2(1.0, 1.0))
	P.glifo(t, "lama", Vector2(1010, 470), 620.0, Color(P.NERO, 0.06), P.CREMA)
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, -20), Vector2(TAGLIO_ALTO, -20), Vector2(TAGLIO_BASSO, 740),
			Vector2(-20, 740)]), P.NERO)
	P.glifo(t, "cuore", Vector2(230, 470), 560.0, Color(P.CREMA, 0.06), P.NERO)
	Manifesto.poligono(t, PackedVector2Array([Vector2(TAGLIO_ALTO, -20), Vector2(TAGLIO_ALTO + 14, -20),
			Vector2(TAGLIO_BASSO + 14, 740), Vector2(TAGLIO_BASSO, 740)]), P.ARANCIO)
	strada(t, Vector2(54, 0), "VITA", 150, "+60 PUNTI VITA", "Punti vita", "110 → 170", "Reggi più a lungo.", false)
	strada(t, Vector2(700, 0), "ATTACCO", 124, "+6 ATTACCO", "Attacco", "17 → 23", "L'attacco normale colpisce più forte.", true)
	P.etichetta(t, Vector2(700, 204), "◆ LA SCEGLI", 16, P.ARANCIO, P.NERO, P.NERO)
	var c := Vector2(580, 362)
	P.rombo(t, c + Vector2(8, 8), 66.0 + 4.0 * batte, P.NERO)
	P.rombo(t, c, 66.0 + 4.0 * batte, P.ARANCIO, P.NERO, 5.0)
	P.scritta(t, c + Vector2(-60, 16), "1", 58, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 120)
	P.scritta(t, c + Vector2(-60, 40), "PUNTO", 14, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 120)
	P.etichetta(t, Vector2(700, 40), "UN PUNTO, DUE STRADE", 34, P.NERO, P.CREMA, P.ARANCIO)
	P.scritta(t, Vector2(704, 124), "«Fondo del serbatoio» si prende una volta sola.", 16, P.NERO, Caratteri.tondo(800))
	testata(t, "", true, false)


func strada(t: CanvasItem, dove: Vector2, parola: String, corpo: int, quanto: String, che_cosa: String, prima_dopo: String,
		frase: String, scelta: bool) -> void:
	var inchiostro := P.NERO if scelta else P.CREMA
	var piano := P.NERO if scelta else P.CARTA
	P.scritta(t, dove + Vector2(0, 268), "PIÙ", 44, inchiostro)
	P.ritagliata(t, dove + Vector2(-6, 398), parola, corpo, inchiostro, P.ARANCIO if scelta else P.NERO, 0,
			P.ARANCIO if scelta else Color(0, 0, 0, 0), Vector2(8, 8))
	P.scritta(t, dove + Vector2(0, 450), quanto, 30, P.ARANCIO_SCURO if scelta else P.ARANCIO)
	P.scritta(t, dove + Vector2(0, 508), che_cosa, 18, piano, Caratteri.tondo(900))
	P.scritta(t, dove + Vector2(130, 512), prima_dopo, 34, inchiostro)
	P.scritta(t, dove + Vector2(0, 552), frase, 17, piano, Caratteri.tondo(700))


func tasti_bivio() -> void:
	comandi(Vector2(54, 660), [["CLIC", "scegli"]], P.CARTA)
	comandi(Vector2(704, 660), [["INVIO", "prendi"], ["ESC", "ci penso"]], P.NERO)
