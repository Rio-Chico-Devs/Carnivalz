extends Control

# LE PROPOSTE PER LA CRESCITA. Provvisorio: quando Bru sceglie, la schermata
# vera nasce da quella scelta e questo file se ne va (come ProposteZaino).
#
# Bru: «basandoti sulle nostre grafiche mi faresti degli esempi di schermate di
# crescita? spesa punti e così via?». Oggi nessuna schermata spende l'hype
# (docs/albero.md, 3.1): il livello resta 1 per tutta la partita. Qui sei
# schermate fatte coi pezzi veri del manifesto - gli schermi dei cabinati, le
# fasce storte, i cartigli, i tasti disegnati, l'arancio col retino - e coi nomi
# veri dei dati (abilita.json, crescita.json). I numeri (l'hype, il livello,
# cosa e' gia' preso) sono d'esempio, uguali in tutte e sei.
#
#   1 costellazione   le stelle collegate: si prende una stella accanto a una tua
#   2 fasce           il tronco della demo in fila, un livello per fascia
#   3 biglietti       ogni 1.000 hype un biglietto; ogni linea un'attrazione
#   4 salita          il momento in cui sali: il martello del luna park
#   5 stella_doppia   un punto, due strade: si sceglie dentro la stella
#   6 passive         quelle sbloccate, e le tre che si portano
#
#   ./prove/proposte_crescita.sh   le fotografa tutte in scatti/proposte_crescita/
#   nell'editor: F6 su prove/ProposteCrescita.tscn, e le frecce girano le sei

const PROPOSTE := ["costellazione", "fasce", "biglietti", "salita", "stella_doppia", "passive"]
const CARTELLA := "res://scatti/proposte_crescita"
const HYPE := 3450
const LIVELLO := 7
const SINISTRO := Rect2(18, 70, 498, 648)     # gli schermi della scheda della squadra
const DESTRO := Rect2(986, 62, 282, 656)
const BANDA := [Vector2(760, 62), Vector2(1025, 62), Vector2(750, 720), Vector2(485, 720)]

# la costellazione d'esempio: tre linee del protagonista che partono dal centro,
# e fra una linea e l'altra le stelle delle statistiche
const CENTRO := Vector2(902, 422)
const LINEE := {"annichilazione": -90.0, "mantra": 30.0, "flagello": 150.0}
const DISTANZE := [76.0, 122.0, 166.0, 208.0, 246.0, 280.0]
const PRESE := ["annichilazione_0", "flagello_0", "mantra_0", "stat_-30", "stat_90", "stat2_-30"]
const SCELTA := "flagello_1"

var indice := 0
var tavola: Tavola
var foto := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	foto = "foto" in OS.get_cmdline_user_args()
	if not foto:
		mostra(0)
		return
	DirAccess.make_dir_recursive_absolute(CARTELLA)
	for i in PROPOSTE.size():
		mostra(i)
		for k in 50:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var immagine := get_viewport().get_texture().get_image()
		immagine.save_png(CARTELLA.path_join("%d_%s.png" % [i + 1, PROPOSTE[i]]))
		print("PROPOSTA %d: %s" % [i + 1, PROPOSTE[i]])
	get_tree().quit()


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
	call("costruisci_" + String(PROPOSTE[quale]))
	if not foto:
		var gira := TastoObliquo.nuovo("PROPOSTA %d DI %d  ›" % [quale + 1, PROPOSTE.size()], "chiaro", 16)
		gira.scelto.connect(func() -> void: mostra.call_deferred((indice + 1) % PROPOSTE.size()))
		tavola.add_child(gira)
		gira.position = Vector2(560, 14)


# --- i pezzi comuni --------------------------------------------------------------

class Disegno extends Control:
	var come: Callable

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)

	func _draw() -> void:
		come.call(self)


func disegno(come: Callable) -> Disegno:
	var d := Disegno.new()
	d.come = come
	tavola.add_child(d)
	return d


func fondo(con_banda: bool, schermi: Array[Rect2]) -> void:
	# l'arancio del manifesto col suo retino, la fascia nera che pende, e gli
	# schermi dei cabinati: lo stesso fondo della scheda della squadra
	var d := disegno(func(tela: CanvasItem) -> void:
		if con_banda:
			lastra(tela, PackedVector2Array(BANDA))
		for schermo in schermi:
			Manifesto.disegna_schermo(tela, schermo))
	Manifesto.trama_dietro(d).show_behind_parent = true


static func lastra(tela: CanvasItem, punti: PackedVector2Array) -> void:
	var striscia := PackedVector2Array()
	for i in [0, 0, 3, 3]:
		striscia.append(punti[i] + Vector2(-14.0 - (5.0 if striscia.size() in [1, 2] else 0.0), 0))
	Manifesto.poligono(tela, striscia, Stile.colore("bordo_acceso"))
	Manifesto.poligono(tela, punti, Stile.colore("bordo"))


func barra_alta(titolo: String, linguette: Array) -> void:
	var indietro := TastoObliquo.nuovo("INDIETRO", "nero", 20)
	tavola.add_child(indietro)
	indietro.position = Vector2(16, 10)
	var x := 30.0 + indietro.misura_voluta().x
	for i in linguette.size():
		var linguetta := TastoObliquo.nuovo(String(linguette[i]), "accento" if i == 0 else "inchiostro", 18)
		tavola.add_child(linguetta)
		linguetta.position = Vector2(x, 12)
		x += linguetta.misura_voluta().x + 6.0
	var cartiglio := Cartiglio.nuovo(titolo, Stile.colore("bordo"), Stile.colore("testo"), Color(0, 0, 0, 0),
			Stile.dimensione("sezione"))
	tavola.add_child(cartiglio)
	cartiglio.size = cartiglio.get_combined_minimum_size()
	cartiglio.position = Vector2(Tavola.LARGO - cartiglio.size.x - 18.0, 4.0)
	cartiglio.svela(0.05)


func tasto(scritta: String, stile: String, corpo: int, dove: Vector2, inerte := false) -> TastoObliquo:
	var t := TastoObliquo.nuovo(scritta, stile, corpo)
	t.inerte = inerte
	tavola.add_child(t)
	t.position = dove
	return t


func comandi(dove: Vector2, coppie: Array, inchiostro := "testo_smorzato") -> void:
	# i tasti disegnati e cosa fanno, in fila: come in fondo a ogni schermata
	var x := dove.x
	for coppia: Array in coppie:
		var tappo := TappoTasto.nuovo(String(coppia[0]))
		tavola.add_child(tappo)
		tappo.position = Vector2(x, dove.y)
		tappo.size = tappo.get_combined_minimum_size()
		x += tappo.size.x + 8.0
		var parola := Tavola.scritta(String(coppia[1]), 15, Stile.colore(inchiostro), Caratteri.tondo(800))
		tavola.add_child(parola)
		parola.position = Vector2(x, dove.y - 2.0)
		parola.size = Vector2(parola.get_combined_minimum_size().x, tappo.size.y + 4.0)
		x += parola.size.x + 22.0


# --- scrivere e disegnare ----------------------------------------------------------

static func scrivi(tela: CanvasItem, dove: Vector2, testo: String, corpo: int, tinta: Color,
		font: Font = null, allinea := HORIZONTAL_ALIGNMENT_LEFT, largo := -1.0) -> void:
	tela.draw_string(font if font != null else Caratteri.tondo(800), dove, testo, allinea, largo, corpo, tinta)


static func a_capo(tela: CanvasItem, r: Rect2, testo: String, corpo: int, tinta: Color, font: Font = null) -> void:
	var f := font if font != null else Caratteri.tondo(600)
	tela.draw_multiline_string(f, r.position + Vector2(0, f.get_ascent(corpo)), testo, HORIZONTAL_ALIGNMENT_LEFT,
			r.size.x, corpo, -1, tinta)


static func storta(r: Rect2) -> PackedVector2Array:
	var obliquo := r.size.y * Manifesto.INCLINA
	return PackedVector2Array([r.position + Vector2(obliquo, 0), Vector2(r.end.x, r.position.y),
			r.end - Vector2(obliquo, 0), Vector2(r.position.x, r.end.y)])


static func fascia(tela: CanvasItem, r: Rect2, tinta: Color, sfoglia := Color(0, 0, 0, 0)) -> void:
	if sfoglia.a > 0.0:
		Manifesto.poligono(tela, storta(Rect2(r.position + Vector2(6, 5), r.size)), sfoglia)
	Manifesto.poligono(tela, storta(r), tinta)


static func pillola(tela: CanvasItem, r: Rect2, testo: String, corpo: int, fondo_tinta: Color, inchiostro: Color) -> void:
	var stile := Manifesto.stile_pillola(fondo_tinta)
	tela.draw_style_box(stile, r)
	scrivi(tela, Vector2(r.position.x, r.get_center().y + corpo * 0.36), testo, corpo, inchiostro, Caratteri.titolo(),
			HORIZONTAL_ALIGNMENT_CENTER, r.size.x)


static func barra(tela: CanvasItem, r: Rect2, quota: float, vuota := Stile.colore("barra_vuota"),
		piena := Stile.colore("accento")) -> void:
	tela.draw_rect(r, vuota)
	tela.draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(quota, 0.0, 1.0), r.size.y)), piena)


static func migliaia(n: int) -> String:
	var s := str(n)
	var fuori := ""
	while s.length() > 3:
		fuori = "." + s.substr(s.length() - 3) + fuori
		s = s.substr(0, s.length() - 3)
	return s + fuori


static func abilita(id: String) -> Dictionary:
	return GameState.abilita.get("abilita", {}).get(id, {}) if GameState.abilita.has("abilita") else {}


static func linea_di(nome_linea: String) -> Array[Dictionary]:
	# i sei gradi di una linea, nell'ordine
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


static func identita(tela: CanvasItem, livello: int) -> void:
	# l'emblema, il nome, il livello: come in cima alla scheda della squadra
	Sagome.emblema(tela, Vector2(90, 152), 92.0, Stile.colore("testo"), Stile.colore("accento"))
	scrivi(tela, Vector2(150, 164), "ANONIMO", 44, Stile.colore("testo"), Caratteri.titolo())
	scrivi(tela, Vector2(400, 170), str(livello), 60, Stile.colore("accento"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_RIGHT, 90)
	scrivi(tela, Vector2(158, 196), "CLASSE", 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900))
	scrivi(tela, Vector2(222, 196), "PROTAGONISTA", 15, Stile.colore("accento"), Caratteri.tondo(900))
	scrivi(tela, Vector2(393, 196), "LIVELLO", 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_RIGHT, 97)
	tela.draw_line(Vector2(40, 214), Vector2(493, 214), Color(Stile.colore("testo"), 0.25), 2.0)


static func conto_hype(tela: CanvasItem, y: float) -> void:
	# quanto hype ha la squadra, e quanti punti fa: il mucchio e' uno solo
	var per_punto := int(GameState.regole.get("hype_per_punto", 1000))
	scrivi(tela, Vector2(44, y + 16), "HYPE DELLA SQUADRA", 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900))
	scrivi(tela, Vector2(44, y + 64), migliaia(HYPE), 46, Stile.colore("testo"), Caratteri.titolo())
	pillola(tela, Rect2(338, y + 28, 152, 34), "%d PUNTI" % floori(float(HYPE) / per_punto), 20, Stile.colore("accento"),
			Stile.colore("bordo"))
	barra(tela, Rect2(44, y + 80, 446, 8), float(HYPE % per_punto) / per_punto)
	scrivi(tela, Vector2(44, y + 108), "%s / %s al prossimo punto" % [migliaia(HYPE % per_punto), migliaia(per_punto)], 14,
			Stile.colore("testo_smorzato"), Caratteri.tondo(700))


# --- 1. la costellazione ---------------------------------------------------------

func costruisci_costellazione() -> void:
	fondo(false, [SINISTRO, Rect2(536, 70, 732, 648)])
	disegno(func(tela: CanvasItem) -> void:
		identita(tela, LIVELLO)
		conto_hype(tela, 222)
		dettaglio_stella(tela, 352, "terra_bruciata", "FLAGELLO · GRADO II")
		cielo(tela))
	barra_alta("CRESCITA", ["COSTELLAZIONE"])
	for i in 3:
		tasto(["ANONIMO · 7", "VERONICA · 4", "YHVINA · 2"][i], "accento" if i == 0 else "spoglio", 16,
				Vector2(562 + 150 * i, 92))
	tasto("COMPRA · 1 PUNTO", "accento", 22, Vector2(44, 640))
	comandi(Vector2(300, 650), [["INVIO", "compra"]])


static func dettaglio_stella(tela: CanvasItem, y: float, id: String, che_cosa: String) -> void:
	var dati := abilita(id)
	tela.draw_line(Vector2(40, y - 6), Vector2(493, y - 6), Color(Stile.colore("testo"), 0.25), 2.0)
	Manifesto.etichetta_tinta(tela, Vector2(44, y + 6), che_cosa, 14, Stile.colore("accento"), Stile.colore("bordo"))
	scrivi(tela, Vector2(44, y + 72), String(dati.get("nome", id)), 34, Stile.colore("testo"), Caratteri.titolo())
	a_capo(tela, Rect2(44, y + 86, 446, 90), String(dati.get("descrizione", "")), 17, Stile.colore("testo_smorzato"))
	var righe := [["COSTA", "1 PUNTO · 1.000 HYPE"], ["AURA", str(int(dati.get("aura", 0)))], ["SALI AL", "LIVELLO %d" % (LIVELLO + 1)]]
	for i in righe.size():
		scrivi(tela, Vector2(44, y + 196 + 30 * i), String(righe[i][0]), 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900))
		scrivi(tela, Vector2(118, y + 197 + 30 * i), String(righe[i][1]), 20, Stile.colore("testo"), Caratteri.titolo())


static func stelle() -> Dictionary:
	# id -> [posizione, che stella e'] ; e i collegamenti
	var dove := {"origine": CENTRO}
	for linea: String in LINEE:
		var angolo := deg_to_rad(float(LINEE[linea]))
		for i in DISTANZE.size():
			dove["%s_%d" % [linea, i]] = CENTRO + Vector2(cos(angolo), sin(angolo)) * float(DISTANZE[i])
	for gradi in [-30, 90, 210]:
		var a := deg_to_rad(float(gradi))
		dove["stat_%d" % gradi] = CENTRO + Vector2(cos(a), sin(a)) * 150.0
		dove["stat2_%d" % gradi] = CENTRO + Vector2(cos(a), sin(a)) * 236.0
	return dove


static func collegamenti() -> Array:
	var archi := []
	for linea: String in LINEE:
		archi.append(["origine", linea + "_0"])
		for i in DISTANZE.size() - 1:
			archi.append(["%s_%d" % [linea, i], "%s_%d" % [linea, i + 1]])
	var vicine := {-30: ["annichilazione", "mantra"], 90: ["mantra", "flagello"], 210: ["flagello", "annichilazione"]}
	for gradi: int in vicine:
		for linea: String in vicine[gradi]:
			archi.append(["%s_0" % linea, "stat_%d" % gradi])
		archi.append(["stat_%d" % gradi, "stat2_%d" % gradi])
	return archi


static func stato_di(id: String) -> String:
	if id == "origine" or id in PRESE:
		return "presa"
	for arco: Array in collegamenti():
		var altra := String(arco[1]) if String(arco[0]) == id else (String(arco[0]) if String(arco[1]) == id else "")
		if altra != "" and (altra == "origine" or altra in PRESE):
			return "aperta"
	return "chiusa"


static func cielo(tela: CanvasItem) -> void:
	for r in [76.0, 150.0, 236.0, 290.0]:
		tela.draw_arc(CENTRO, r, 0.0, TAU, 96, Color(Stile.colore("testo"), 0.05), 1.5, true)
	var dove := stelle()
	for arco: Array in collegamenti():
		var a: Vector2 = dove[arco[0]]
		var b: Vector2 = dove[arco[1]]
		var sa := stato_di(String(arco[0]))
		var sb := stato_di(String(arco[1]))
		if sa == "presa" and sb == "presa":
			tela.draw_line(a, b, Stile.colore("accento"), 4.0, true)
		elif "presa" in [sa, sb]:
			tela.draw_dashed_line(a, b, Stile.colore("testo"), 2.0, 7.0, true, true)
		else:
			tela.draw_line(a, b, Color(Stile.colore("tratto"), 0.45), 1.5, true)
	for id: String in dove:
		stella_in_cielo(tela, id, dove[id])
	nomi_in_cielo(tela, dove)
	leggenda(tela, Vector2(566, 690))


static func stella_in_cielo(tela: CanvasItem, id: String, c: Vector2) -> void:
	var tondo := id.begins_with("stat")
	if id == "origine":
		Sagome.emblema(tela, c, 52.0, Stile.colore("testo"), Stile.colore("accento"))
		return
	var stato := stato_di(id)
	var r := 13.0 if stato == "presa" else (12.0 if stato == "aperta" else 6.0)
	if id == SCELTA:
		r = 18.0
		tela.draw_arc(c, r + 11.0, 0.0, TAU, 40, Stile.colore("accento"), 3.0, true)
	elif stato == "aperta":
		tela.draw_arc(c, r + 7.0, 0.0, TAU, 32, Color(Stile.colore("testo"), 0.3), 1.5, true)
	var pieno := Stile.colore("accento") if stato == "presa" else (Stile.colore("quadro_vuoto") if stato == "aperta" else Color(Stile.colore("tratto"), 0.8))
	var bordo := Stile.colore("bordo_acceso") if stato != "chiusa" else Color(0, 0, 0, 0)
	if tondo:
		tela.draw_circle(c, r * 0.8, pieno, true, -1.0, true)
		if bordo.a > 0.0:
			tela.draw_arc(c, r * 0.8, 0.0, TAU, 32, bordo, 2.5, true)
	else:
		var forma := Sagome.rombo(c, r)
		Manifesto.poligono(tela, forma, pieno)
		if bordo.a > 0.0:
			tela.draw_polyline(Sagome.chiudi(forma), bordo, 2.5, true)
	if stato == "aperta" and not tondo:
		Manifesto.poligono(tela, Sagome.rombo(c, r * 0.35), Stile.colore("accento"))


static func nomi_in_cielo(tela: CanvasItem, dove: Dictionary) -> void:
	var chiaro := Stile.colore("bordo_acceso")
	var nero := Stile.colore("bordo")
	Manifesto.etichetta_tinta(tela, dove["annichilazione_5"] + Vector2(24, -12), "ANNICHILAZIONE", 15, chiaro, nero)
	Manifesto.etichetta_tinta(tela, dove["flagello_5"] + Vector2(-40, 20), "FLAGELLO", 15, chiaro, nero)
	Manifesto.etichetta_tinta(tela, dove["mantra_5"] + Vector2(-60, 20), "MANTRA", 15, chiaro, nero)
	Manifesto.etichetta_tinta(tela, dove[SCELTA] + Vector2(-206, -12), "TERRA BRUCIATA", 18, Stile.colore("accento"), nero)
	var piccoli := {"stat_-30": "+6 ATTACCO", "stat_90": "+60 VITA", "stat_210": "+8 FATTORE", "stat2_-30": "+10 ATTACCO",
			"stat2_90": "+110 VITA"}
	for id: String in piccoli:
		var a_sinistra := id == "stat_210"
		scrivi(tela, dove[id] + Vector2(-112 if a_sinistra else 16, 5), String(piccoli[id]), 13,
				Stile.colore("testo") if stato_di(id) != "chiusa" else Color(Stile.colore("testo_smorzato"), 0.7), Caratteri.tondo(900))


static func leggenda(tela: CanvasItem, dove: Vector2) -> void:
	var voci := [["presa", "PRESA"], ["aperta", "SI PUÒ PRENDERE"], ["chiusa", "NON ANCORA"], ["tondo", "STATISTICA"]]
	var x := dove.x
	for voce: Array in voci:
		var c := Vector2(x + 8, dove.y - 5)
		match String(voce[0]):
			"presa": Manifesto.poligono(tela, Sagome.rombo(c, 8), Stile.colore("accento"))
			"aperta": tela.draw_polyline(Sagome.chiudi(Sagome.rombo(c, 8)), Stile.colore("bordo_acceso"), 2.0, true)
			"chiusa": Manifesto.poligono(tela, Sagome.rombo(c, 5), Stile.colore("tratto"))
			_: tela.draw_circle(c, 6.0, Stile.colore("bordo_acceso"), true, -1.0, true)
		scrivi(tela, Vector2(x + 22, dove.y), String(voce[1]), 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900))
		x += 44.0 + Caratteri.tondo(900).get_string_size(String(voce[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x


# --- 2. il tronco a fasce -----------------------------------------------------------

const TRONCO := [
	[5, "mantra", "MANTRA · GRADO I", "presa"],
	[6, "attacco_i", "+6 ATTACCO", "presa"],
	[7, "vita_i", "+60 VITA", "presa"],
	[8, "terra_bruciata", "FLAGELLO · GRADO II", "scelta"],
	[9, "annichilazione_ii", "ANNICHILAZIONE · GRADO II", "chiusa"],
	[10, "dominio_i", "+8 FATTORE", "chiusa"],
	[11, "mantra_ii", "MANTRA · GRADO II", "chiusa"],
	[12, "attacco_ii", "+10 ATTACCO", "chiusa"],
	[13, "maelstrom", "FLAGELLO · GRADO III", "chiusa"],
]


func costruisci_fasce() -> void:
	fondo(true, [DESTRO])
	disegno(func(tela: CanvasItem) -> void:
		numerone(tela, str(LIVELLO + 1), Vector2(560, 560), 330)
		testa_del_tronco(tela)
		for i in TRONCO.size():
			fascia_del_tronco(tela, Rect2(40, 168 + 58 * i, 448, 50), TRONCO[i])
		dettaglio_a_destra(tela, "terra_bruciata", "FLAGELLO · GRADO II"))
	barra_alta("CRESCITA", ["ANONIMO · LV 7", "VERONICA · LV 4", "YHVINA · LV 2"])
	tasto("COMPRA", "accento", 22, Vector2(1006, 612))
	comandi(Vector2(1006, 576), [["INVIO", "compra"]])


static func numerone(tela: CanvasItem, testo: String, dove: Vector2, corpo: int) -> void:
	# il numero del livello dopo, grande sulla fascia nera, col suo spessore
	# arancio come la figura della scheda
	var f := Caratteri.titolo()
	for i in range(9, 0, -1):
		scrivi(tela, dove + Vector2(i * 2.2, i * 2.2), testo, corpo, Stile.colore("manifesto_scuro").darkened(0.06 * i), f)
	scrivi(tela, dove, testo, corpo, Stile.colore("testo"), f)


static func testa_del_tronco(tela: CanvasItem) -> void:
	var per_punto := int(GameState.regole.get("hype_per_punto", 1000))
	Manifesto.etichetta_tinta(tela, Vector2(40, 74), "IL TRONCO · %d DI 20" % LIVELLO, 20, Stile.colore("bordo"), Stile.colore("testo"))
	scrivi(tela, Vector2(44, 146), "HYPE %s" % migliaia(HYPE), 26, Stile.colore("bordo"), Caratteri.titolo())
	pillola(tela, Rect2(236, 120, 150, 32), "%d PUNTI" % floori(float(HYPE) / per_punto), 18, Stile.colore("bordo"), Stile.colore("testo"))
	barra(tela, Rect2(404, 124, 84, 8), float(HYPE % per_punto) / per_punto, Color(Stile.colore("bordo"), 0.25), Stile.colore("bordo"))
	scrivi(tela, Vector2(404, 150), "%s / %s" % [migliaia(HYPE % per_punto), migliaia(per_punto)], 13, Stile.colore("bordo"),
			Caratteri.tondo(900))


static func fascia_del_tronco(tela: CanvasItem, r: Rect2, voce: Array) -> void:
	var stato := String(voce[3])
	var dati := abilita(String(voce[1]))
	if dati.is_empty():
		dati = GameState.abilita.get("potenziamenti", {}).get(String(voce[1]), {})
	var chiara := stato == "scelta"
	fascia(tela, r, Stile.colore("bordo_acceso") if chiara else Color(Stile.colore("bordo"), 1.0 if stato == "presa" else 0.55),
			Stile.colore("bordo") if chiara else Color(0, 0, 0, 0))
	var inchiostro := Stile.colore("bordo") if chiara else (Stile.colore("testo") if stato == "presa" else Stile.colore("testo_smorzato"))
	scrivi(tela, Vector2(r.position.x + 22, r.position.y + 33), "LV %d" % int(voce[0]), 16, Stile.colore("accento_su_carta") if chiara else Stile.colore("accento"), Caratteri.titolo())
	scrivi(tela, Vector2(r.position.x + 82, r.position.y + 25), String(dati.get("nome", voce[1])), 21, inchiostro, Caratteri.titolo())
	scrivi(tela, Vector2(r.position.x + 82, r.position.y + 42), String(voce[2]), 13, inchiostro, Caratteri.tondo(900))
	var destra := Vector2(r.end.x - 34, r.get_center().y)
	match stato:
		"presa": Sagome.timbro(tela, destra, 15.0, Stile.colore("accento"))
		"scelta": pillola(tela, Rect2(r.end.x - 120, r.position.y + 10, 96, 30), "1 PUNTO", 16, Stile.colore("bordo"), Stile.colore("testo"))
		_: Sagome.lucchetto(tela, destra, 26.0, Stile.colore("testo_smorzato"))


static func dettaglio_a_destra(tela: CanvasItem, id: String, che_cosa: String) -> void:
	var dati := abilita(id)
	var x := DESTRO.position.x + 18.0
	scrivi(tela, Vector2(x, 112), "LIVELLO %d" % (LIVELLO + 1), 15, Stile.colore("accento"), Caratteri.tondo(900))
	scrivi(tela, Vector2(x, 148), String(dati.get("nome", id)).to_upper(), 24, Stile.colore("testo"), Caratteri.titolo())
	scrivi(tela, Vector2(x, 172), che_cosa, 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900))
	a_capo(tela, Rect2(x, 190, 246, 200), String(dati.get("descrizione", "")), 16, Stile.colore("testo_smorzato"))
	var righe := [["COSTA", "1 PUNTO"], ["HYPE", "1.000"], ["AURA", str(int(dati.get("aura", 0)))]]
	for i in righe.size():
		scrivi(tela, Vector2(x, 330 + 34 * i), String(righe[i][0]), 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900))
		scrivi(tela, Vector2(x + 70, 331 + 34 * i), String(righe[i][1]), 20, Stile.colore("testo"), Caratteri.titolo())


# --- 3. i biglietti -------------------------------------------------------------------

func costruisci_biglietti() -> void:
	fondo(false, [])
	disegno(func(tela: CanvasItem) -> void:
		biglietti_in_mano(tela)
		var linee := [["FLAGELLO", "flagello", 1], ["ANNICHILAZIONE", "annichilazione", 1], ["MANTRA", "mantra", 1]]
		for i in linee.size():
			attrazione(tela, Rect2(40 + 408 * i, 236, 384, 452), linee[i], i == 0)
		scelta_dei_biglietti(tela))
	barra_alta("BIGLIETTERIA", ["ANONIMO · LV 7", "VERONICA · LV 4", "YHVINA · LV 2"])
	tasto("PUNZONA · 1 BIGLIETTO", "nero", 20, Vector2(560, 178))
	comandi(Vector2(870, 186), [["INVIO", "punzona"], ["ESC", "indietro"]], "bordo")


static func biglietto(tela: CanvasItem, r: Rect2, tinta: Color, scritta: String, vero := true) -> void:
	# un biglietto del luna park: le tacche ai lati e la linea da strappare
	if vero:
		tela.draw_rect(Rect2(r.position + Vector2(5, 5), r.size), Stile.colore("bordo"))
		tela.draw_rect(r, tinta)
	else:
		tela.draw_rect(r, Color(Stile.colore("bordo"), 0.6), false, 2.0)
	var buco := Color(Stile.colore("manifesto"), 1.0)
	tela.draw_circle(Vector2(r.position.x, r.get_center().y), 8.0, buco, true, -1.0, true)
	tela.draw_circle(Vector2(r.end.x, r.get_center().y), 8.0, buco, true, -1.0, true)
	var taglio := r.position.x + r.size.x * 0.72
	tela.draw_dashed_line(Vector2(taglio, r.position.y + 6), Vector2(taglio, r.end.y - 6), Color(Stile.colore("bordo"), 0.6), 2.0, 5.0)
	scrivi(tela, Vector2(r.position.x + 14, r.position.y + 30), scritta, 18, Stile.colore("bordo"), Caratteri.titolo())
	scrivi(tela, Vector2(r.position.x + 14, r.position.y + 48), "CARNIVALZ" if vero else "", 11, Color(Stile.colore("bordo"), 0.7), Caratteri.tondo(900))


static func biglietti_in_mano(tela: CanvasItem) -> void:
	var per_punto := int(GameState.regole.get("hype_per_punto", 1000))
	Manifesto.etichetta_tinta(tela, Vector2(40, 74), "I TUOI BIGLIETTI", 20, Stile.colore("bordo"), Stile.colore("testo"))
	for i in floori(float(HYPE) / per_punto):
		biglietto(tela, Rect2(48 + 140 * i, 122 + (i % 2) * 6, 118, 60), Stile.colore("box_fondo"), "UN GIRO")
	var r := Rect2(48 + 140 * 3, 122, 118, 60)
	biglietto(tela, r, Color(0, 0, 0, 0), "", false)
	scrivi(tela, Vector2(r.position.x + 12, r.position.y + 28), "IL PROSSIMO", 13, Stile.colore("bordo"), Caratteri.tondo(900))
	scrivi(tela, Vector2(r.position.x + 12, r.position.y + 48), "%s / %s" % [migliaia(HYPE % per_punto), migliaia(per_punto)], 15,
			Stile.colore("bordo"), Caratteri.titolo())
	scrivi(tela, Vector2(44, 216), "Ogni 1.000 hype della squadra, un biglietto. Un biglietto, un giro.", 15,
			Stile.colore("bordo"), Caratteri.tondo(700))


static func attrazione(tela: CanvasItem, r: Rect2, linea: Array, con_la_scelta: bool) -> void:
	# una linea e' un'attrazione: il cartellone, e un biglietto per ogni giro
	Manifesto.carta(tela, r, Stile.colore("box_fondo"), 5.0)
	fascia(tela, Rect2(r.position.x + 18, r.position.y + 18, r.size.x - 36, 46), Stile.colore("bordo"))
	scrivi(tela, Vector2(r.position.x + 40, r.position.y + 52), String(linea[0]), 26, Stile.colore("testo"), Caratteri.titolo())
	var gradi := linea_di(String(linea[1]))
	var presi := int(linea[2])
	scrivi(tela, Vector2(r.position.x + 22, r.position.y + 88), "6 GIRI · %d PRESO" % presi, 14, Stile.colore("bordo"), Caratteri.tondo(900))
	for i in mini(gradi.size(), 6):
		var stato := "presa" if i < presi else ("scelta" if con_la_scelta and i == presi else ("aperta" if i == presi else "chiusa"))
		giro(tela, Rect2(r.position.x + 18, r.position.y + 100 + 56 * i, r.size.x - 36, 48), gradi[i], stato)


static func giro(tela: CanvasItem, r: Rect2, dati: Dictionary, stato: String) -> void:
	var romani := ["I", "II", "III", "IV", "V", "VI"]
	var nero := Stile.colore("bordo")
	match stato:
		"presa": tela.draw_rect(r, Stile.colore("bordo_acceso"))
		"scelta":
			tela.draw_rect(Rect2(r.position + Vector2(5, 5), r.size), nero)
			tela.draw_rect(r, Stile.colore("accento"))
		"aperta": tela.draw_rect(r, Stile.colore("testo"))
		_: tela.draw_rect(r, Color(nero, 0.25), false, 2.0)
	var inchiostro := nero if stato != "chiusa" else Color(nero, 0.45)
	tela.draw_circle(Vector2(r.position.x + 24, r.get_center().y), 15.0, inchiostro if stato != "chiusa" else Color(0, 0, 0, 0), true, -1.0, true)
	scrivi(tela, Vector2(r.position.x + 9, r.get_center().y + 6), romani[int(dati.get("grado", 1)) - 1], 15,
			Stile.colore("testo") if stato != "chiusa" else inchiostro, Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER, 30)
	scrivi(tela, Vector2(r.position.x + 50, r.get_center().y + 7), String(dati.get("nome", "")), 19, inchiostro, Caratteri.titolo())
	var destra := Vector2(r.end.x - 26, r.get_center().y)
	match stato:
		"presa":
			tela.draw_circle(destra, 10.0, nero, true, -1.0, true)
			scrivi(tela, destra + Vector2(-96, 5), "PRESO", 13, nero, Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_RIGHT, 80)
		"scelta", "aperta":
			scrivi(tela, destra + Vector2(-120, 5), "1 BIGLIETTO", 13, nero, Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_RIGHT, 140)
		_:
			Sagome.lucchetto(tela, destra, 22.0, Color(nero, 0.45))


static func scelta_dei_biglietti(tela: CanvasItem) -> void:
	var dati := abilita("terra_bruciata")
	scrivi(tela, Vector2(560, 112), String(dati.get("nome", "")).to_upper(), 28, Stile.colore("bordo"), Caratteri.titolo())
	a_capo(tela, Rect2(560, 122, 680, 50), String(dati.get("descrizione", "")), 16, Stile.colore("bordo"), Caratteri.tondo(700))


# --- 4. la salita ----------------------------------------------------------------------

func costruisci_salita() -> void:
	fondo(false, [Rect2(560, 236, 700, 420)])
	disegno(func(tela: CanvasItem) -> void:
		lastra(tela, PackedVector2Array([Vector2(70, 0), Vector2(470, 0), Vector2(330, 720), Vector2(-70, 720)]))
		martello(tela)
		cosa_ti_ha_cambiato(tela))
	var grande := Cartiglio.nuovo("LIVELLO %d" % (LIVELLO + 1), Stile.colore("bordo"), Stile.colore("testo"),
			Stile.colore("accento"), 64)
	tavola.add_child(grande)
	grande.size = grande.get_combined_minimum_size()
	grande.position = Vector2(470, 70)
	grande.svela(0.05)
	var preso := Cartiglio.nuovo("HAI PRESO TERRA BRUCIATA", Stile.colore("testo"), Stile.colore("bordo"), Color(0, 0, 0, 0), 20)
	tavola.add_child(preso)
	preso.size = preso.get_combined_minimum_size()
	preso.position = Vector2(500, 172)
	preso.svela(0.2)
	tasto("AVANTI", "chiaro", 22, Vector2(1120, 668))
	comandi(Vector2(980, 676), [["INVIO", ""]], "bordo")


static func martello(tela: CanvasItem) -> void:
	# IL MARTELLO DEL LUNA PARK: colpisci, il peso sale, la campana suona. Le
	# tacche sono i livelli: il peso si ferma su quello a cui sei arrivato
	var torre := Rect2(176, 120, 76, 520)
	tela.draw_rect(Rect2(torre.position + Vector2(6, 6), torre.size), Stile.colore("manifesto_scuro"))
	tela.draw_rect(torre, Stile.colore("box_fondo"))
	tela.draw_rect(torre, Stile.colore("bordo"), false, 4.0)
	tela.draw_rect(Rect2(torre.get_center().x - 6, torre.position.y + 14, 12, torre.size.y - 28), Stile.colore("bordo"))
	for i in 6:
		var y := torre.end.y - 40.0 - 88.0 * i
		var acceso := 5 + i <= LIVELLO + 1
		tela.draw_line(Vector2(torre.position.x + 6, y), Vector2(torre.position.x + 24, y), Stile.colore("bordo"), 3.0)
		scrivi(tela, Vector2(torre.position.x - 56, y + 10), str(5 + i), 26,
				Stile.colore("accento") if acceso else Stile.colore("tratto"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_RIGHT, 44)
	var peso := Vector2(torre.get_center().x, torre.end.y - 40.0 - 88.0 * (LIVELLO + 1 - 5))
	for k in 3:
		tela.draw_line(peso + Vector2(-10 + 10 * k, 28), peso + Vector2(-10 + 10 * k, 58), Color(Stile.colore("accento"), 0.7), 3.0)
	Manifesto.poligono(tela, Sagome.rombo(peso, 22.0), Stile.colore("accento"))
	tela.draw_polyline(Sagome.chiudi(Sagome.rombo(peso, 22.0)), Stile.colore("bordo"), 3.0, true)
	var campana := Vector2(torre.get_center().x, 82)
	Manifesto.poligono(tela, Sagome.stella(campana, 62.0, 30.0, 8), Stile.colore("testo"))
	tela.draw_circle(campana, 22.0, Stile.colore("accento"), true, -1.0, true)
	tela.draw_arc(campana, 22.0, 0.0, TAU, 32, Stile.colore("bordo"), 3.0, true)
	scrivi(tela, Vector2(262, 70), "DING!", 30, Stile.colore("testo"), Caratteri.titolo())
	tela.draw_rect(Rect2(150, 640, 128, 22), Stile.colore("bordo_acceso"))
	Manifesto.poligono(tela, PackedVector2Array([Vector2(286, 560), Vector2(352, 540), Vector2(364, 578), Vector2(298, 598)]),
			Stile.colore("bordo_acceso"))
	tela.draw_line(Vector2(330, 568), Vector2(372, 700), Stile.colore("bordo_acceso"), 9.0, true)


static func cosa_ti_ha_cambiato(tela: CanvasItem) -> void:
	# il perche' di ogni punto: e' la frase di crescita.json, «i colpi che hai tirato»
	var regole: Dictionary = GameState.crescita.get("crescita", {})
	var righe := [["attacco", "ATTACCO", "attacchi_sferrati", 15, 17], ["hp", "PUNTI VITA", "danni_subiti", 100, 110],
			["intelligenza", "INTELLIGENZA", "studi", 1, 2], ["velocita", "VELOCITÀ", "stanze_esplorate", 3, 4]]
	scrivi(tela, Vector2(592, 290), "COSA TI HA CAMBIATO", 24, Stile.colore("testo"), Caratteri.titolo())
	for i in righe.size():
		var riga: Array = righe[i]
		var y := 306.0 + 70.0 * i
		Sagome.icona_statistica(tela, Rect2(592, y + 14, 32, 32), String(riga[0]), Stile.colore("testo"))
		scrivi(tela, Vector2(640, y + 34), String(riga[1]), 22, Stile.colore("testo"), Caratteri.titolo())
		var perche := String(regole.get(String(riga[2]), {}).get("racconto", ""))
		scrivi(tela, Vector2(640, y + 56), "per " + perche, 15, Stile.colore("testo_smorzato"), Caratteri.tondo(700))
		scrivi(tela, Vector2(1000, y + 42), "%d" % int(riga[3]), 26, Stile.colore("testo_smorzato"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_RIGHT, 80)
		Sagome.freccia(tela, Vector2(1104, y + 32), 26.0, Vector2.RIGHT, Stile.colore("testo_smorzato"))
		scrivi(tela, Vector2(1120, y + 42), "%d" % int(riga[4]), 30, Stile.colore("accento"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_RIGHT, 110)
		if i < righe.size() - 1:
			tela.draw_line(Vector2(592, y + 68), Vector2(1232, y + 68), Color(Stile.colore("testo"), 0.12), 1.0)


# --- 5. la stella doppia --------------------------------------------------------------

func costruisci_stella_doppia() -> void:
	fondo(false, [Rect2(536, 70, 732, 648)])
	disegno(func(tela: CanvasItem) -> void:
		cielo(tela)
		tela.draw_rect(Rect2(0, 0, Tavola.LARGO, Tavola.ALTO), Color(Stile.colore("velo"), 0.78))
		scrivi(tela, Vector2(0, 178), "«Fondo del serbatoio» si prende una volta sola: scegli cosa diventa.", 18,
				Stile.colore("testo"), Caratteri.tondo(700), HORIZONTAL_ALIGNMENT_CENTER, Tavola.LARGO)
		strada(tela, Rect2(236, 214, 370, 380), "hp", "PIÙ VITA", "+60 PUNTI VITA", ["Punti vita", "110", "170"],
				"Reggi più a lungo.", false)
		strada(tela, Rect2(674, 200, 370, 400), "attacco", "PIÙ ATTACCO", "+6 ATTACCO", ["Attacco", "17", "23"],
				"L'attacco normale colpisce più forte.", true))
	var titolo := Cartiglio.nuovo("UN PUNTO, DUE STRADE", Stile.colore("testo"), Stile.colore("bordo"), Stile.colore("accento"), 40)
	tavola.add_child(titolo)
	titolo.size = titolo.get_combined_minimum_size()
	titolo.position = Vector2((Tavola.LARGO - titolo.size.x) * 0.5, 74)
	titolo.svela(0.05)
	comandi(Vector2(430, 640), [["CLIC", "sceglie"], ["INVIO", "prende"], ["ESC", "ci penso"]], "testo")


static func strada(tela: CanvasItem, r: Rect2, icona: String, titolo: String, quanto: String, prima_dopo: Array,
		frase: String, scelta: bool) -> void:
	var chiaro := Stile.colore("box_fondo")
	var inchiostro := Stile.colore("bordo") if scelta else Stile.colore("testo")
	if scelta:
		Manifesto.carta(tela, r, chiaro, 6.0)
		pillola(tela, Rect2(r.position.x + 20, r.position.y - 18, 120, 34), "◆ SCELTA", 16, Stile.colore("accento"), Stile.colore("bordo"))
	else:
		Manifesto.disegna_schermo(tela, r)
	var c := r.position.x + r.size.x * 0.5
	Sagome.icona_statistica(tela, Rect2(c - 40, r.position.y + 40, 80, 80), icona, Stile.colore("accento") if not scelta else inchiostro)
	scrivi(tela, Vector2(r.position.x, r.position.y + 170), titolo, 38, inchiostro, Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	scrivi(tela, Vector2(r.position.x, r.position.y + 210), quanto, 24, Stile.colore("accento_su_carta") if scelta else Stile.colore("accento"),
			Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	tela.draw_line(Vector2(r.position.x + 40, r.position.y + 236), Vector2(r.end.x - 40, r.position.y + 236), Color(inchiostro, 0.3), 2.0)
	scrivi(tela, Vector2(r.position.x + 44, r.position.y + 282), String(prima_dopo[0]), 18, inchiostro, Caratteri.tondo(800))
	scrivi(tela, Vector2(r.position.x + 150, r.position.y + 284), "%s  →  %s" % [prima_dopo[1], prima_dopo[2]], 26, inchiostro,
			Caratteri.titolo(), HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 194)
	scrivi(tela, Vector2(r.position.x, r.position.y + 336), frase, 16, Color(inchiostro, 0.75), Caratteri.tondo(700),
			HORIZONTAL_ALIGNMENT_CENTER, r.size.x)


# --- 6. le passive -------------------------------------------------------------------

func costruisci_passive() -> void:
	fondo(true, [SINISTRO, DESTRO])
	var figura := FiguraIntera.new()
	tavola.add_child(figura)
	Tavola.metti(figura, Rect2(500, 62, 490, 658))
	figura.mostra(GameState.id_protagonista)
	disegno(func(tela: CanvasItem) -> void:
		identita(tela, LIVELLO)
		posti_delle_passive(tela)
		elenco_delle_passive(tela)
		dettaglio_passiva(tela))
	barra_alta("SQUADRA", ["PASSIVE"])
	tasto("PORTA", "accento", 20, Vector2(1006, 612), true)
	comandi(Vector2(1006, 576), [["INVIO", "porta"]])


static func posti_delle_passive(tela: CanvasItem) -> void:
	Manifesto.etichetta_tinta(tela, Vector2(44, 226), "PORTATE · 2 DI 3", 15, Stile.colore("accento"), Stile.colore("bordo"))
	var nomi := ["NON C'È TEMPO!", "LA TUA IMMONDIZIA È IL MIO TESORO", ""]
	for i in 3:
		var r := Rect2(44 + 152 * i, 266, 138, 112)
		if nomi[i] == "":
			tela.draw_rect(r, Color(Stile.colore("accento"), 0.9), false, 2.0)
			scrivi(tela, Vector2(r.position.x, r.get_center().y + 6), "+ PORTANE UNA", 15, Stile.colore("accento"), Caratteri.titolo(),
					HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
			continue
		tela.draw_rect(r, Stile.colore("pannello_chiaro"))
		tela.draw_rect(r, Stile.colore("bordo_acceso"), false, 3.0)
		Manifesto.poligono(tela, Sagome.stella(Vector2(r.position.x + 22, r.position.y + 22), 12.0, 5.0), Stile.colore("accento"))
		a_capo(tela, Rect2(r.position.x + 12, r.position.y + 40, r.size.x - 20, 70), String(nomi[i]), 16, Stile.colore("testo"),
				Caratteri.titolo())
	scrivi(tela, Vector2(44, 398), "Il quarto posto si apre al livello 20.", 14, Stile.colore("testo_smorzato"), Caratteri.tondo(700))


const PASSIVE := [
	["Non c'è tempo!", "portata", ""],
	["La tua immondizia è il mio tesoro", "portata", ""],
	["Battito dell'eroe", "scelta", "LIVELLO 23"],
	["Trinità", "chiusa", "LIVELLO 33"],
	["Altruismo", "soglia", "FORZA MENTALE 4/10 · INTELLIGENZA 6/15"],
	["Furia", "soglia", "FATTORE 15/20 · ATTACCO 17/90"],
]


static func elenco_delle_passive(tela: CanvasItem) -> void:
	for i in PASSIVE.size():
		var voce: Array = PASSIVE[i]
		var r := Rect2(40, 418 + 46 * i, 454, 40)
		var stato := String(voce[1])
		if stato == "scelta":
			fascia(tela, r, Stile.colore("bordo_acceso"), Stile.colore("accento"))
		var inchiostro := Stile.colore("bordo") if stato == "scelta" else (Stile.colore("testo") if stato == "portata" else Stile.colore("testo_smorzato"))
		scrivi(tela, Vector2(r.position.x + 18, r.position.y + 27), String(voce[0]), 18, inchiostro, Caratteri.titolo())
		match stato:
			"portata":
				pillola(tela, Rect2(r.end.x - 112, r.position.y + 6, 104, 28), "PORTATA", 14, Stile.colore("accento"), Stile.colore("bordo"))
			"soglia":
				scrivi(tela, Vector2(r.position.x + 120, r.position.y + 26), String(voce[2]), 13, inchiostro, Caratteri.tondo(900),
						HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 132)
			_:
				Sagome.lucchetto(tela, Vector2(r.end.x - 120, r.get_center().y), 20.0, inchiostro)
				scrivi(tela, Vector2(r.end.x - 106, r.position.y + 25), String(voce[2]), 13, inchiostro, Caratteri.tondo(900))


static func dettaglio_passiva(tela: CanvasItem) -> void:
	var x := DESTRO.position.x + 18.0
	scrivi(tela, Vector2(x, 112), "PASSIVA · LIVELLO 23", 13, Stile.colore("accento"), Caratteri.tondo(900))
	scrivi(tela, Vector2(x, 146), "BATTITO DELL'EROE", 22, Stile.colore("testo"), Caratteri.titolo())
	var dati := {}
	for voce: Dictionary in GameState.crescita.get("passive_livello", []):
		if String(voce.get("id", "")) == "battito_dell_eroe":
			dati = voce
	a_capo(tela, Rect2(x, 166, 246, 200), String(dati.get("descrizione", "")), 16, Stile.colore("testo_smorzato"))
	a_capo(tela, Rect2(x, 330, 246, 160), "Si apre al livello 23. Poi la porti o la lasci: se ne portano tre alla volta, e si cambiano qui quando vuoi.",
			15, Stile.colore("testo_smorzato"), Caratteri.tondo(700))
