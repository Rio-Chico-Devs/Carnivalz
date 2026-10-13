extends Control

# LE PROPOSTE PER LA CRESCITA, quarta mano. Provvisorio: quando la schermata vera
# nasce da qui, questo file se ne va (come ProposteZaino).
#
# Delle sei astratte Bru ne ha tenute tre: «approvato quella che sembra una
# roulette, le passive e un punto due strade, miglioriamo per ora queste
# approvate». Qui sono diventate un sistema solo, quello di docs/albero.md
# (4.3, 4.4, 4.5), e dicono cose vere: cosa arriva a ogni livello, i nomi, le
# descrizioni e i numeri dei potenziamenti vengono da abilita.json e crescita.json.
#
#   quadrante  il tronco della demo, venti spicchi: un punto = un livello. Su ogni
#              spicchio si vede cosa da' (una statistica a scelta, e a volte
#              un'abilita' o una passiva). La lancetta sta ferma, gira la ruota
#   bivio      prendere lo spicchio: un punto, due strade. La strada scelta si
#              allarga; quello che arriva comunque sta sulla fascia in basso
#   passive    quelle sbloccate si portano in tre alloggi, e si cambiano quando vuoi
#
# Il protagonista d'esempio e' lo stesso: livello 7, 3.450 di hype. Le passive
# lo mostrano al 24, perche' prima del 10 non ce n'e' nessuna.
#
#   ./prove/proposte_crescita.sh   le fotografa in scatti/proposte_crescita/
#   -- film quadrante              per il Movie Maker: il copione la usa da solo
#   nell'editor, F6: destra e sinistra cambiano schermata; su, giu' e invio la usano

const P := preload("res://prove/PezziCrescita.gd")
const PROPOSTE := ["quadrante", "quadrante_avanti", "bivio", "passive"]
const CARTELLA := "res://scatti/proposte_crescita"
const HYPE := 3450
const LIVELLO := 7
# nel film: quando (secondi dall'entrata) e cosa fa da solo chi la usa
const COPIONI := {
	"quadrante": [[1.5, "avanti"], [1.95, "avanti"], [2.4, "avanti"], [3.5, "indietro"], [3.75, "indietro"], [4.0, "indietro"]],
	"bivio": [[1.5, "avanti"], [2.4, "avanti"], [3.2, "conferma"]],
	"passive": [[1.4, "conferma"], [2.5, "avanti"], [3.2, "avanti"]],
}

var indice := 0
var tavola: Tavola
var tela: Disegno
var tempo := 1.3
var inizio := 0.0       # quando e' comparsa la schermata: le entrate contano da qui
var foto := false
var copione: Array = []
# lo stato di chi la usa
var guardato := LIVELLO        # lo spicchio sotto la lancetta (livello - 1)
var vista := float(LIVELLO)    # dove sta davvero la ruota: ci arriva con una molla
var spinta_vista := 0.0
var a_destra := true           # la strada scelta nel bivio
var peso := 1.0                # 0 = la strada di sinistra, 1 = quella di destra, con la molla
var spinta_peso := 0.0
var cambiato_a := -10.0
var preso_a := -1.0
var passiva := 2               # quella guardata fra tutte
var portata := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var argomenti := OS.get_cmdline_user_args()
	foto = "foto" in argomenti
	if not foto:
		# "-- film bivio": parte da quella, per registrarla col Movie Maker
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
	while not copione.is_empty() and tempo - inizio >= float(copione[0][0]):
		var battuta: Array = copione.pop_front()
		azione(String(battuta[1]))
	var ruota := molla(vista, spinta_vista, float(guardato), delta)
	vista = ruota.x
	spinta_vista = ruota.y
	var taglio := molla(peso, spinta_peso, 1.0 if a_destra else 0.0, delta)
	peso = taglio.x
	spinta_peso = taglio.y
	if tela != null:
		tela.queue_redraw()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_right"):
		mostra((indice + 1) % PROPOSTE.size())
	elif evento.is_action_pressed("ui_left"):
		mostra((indice + PROPOSTE.size() - 1) % PROPOSTE.size())
	elif evento.is_action_pressed("ui_down"):
		azione("avanti")
	elif evento.is_action_pressed("ui_up"):
		azione("indietro")
	elif evento.is_action_pressed("ui_accept"):
		azione("conferma")


func mostra(quale: int) -> void:
	indice = quale
	if tavola != null:
		tavola.queue_free()
	tavola = Tavola.su(self)
	tela = Disegno.new()
	var nome := String(PROPOSTE[quale])
	tela.come = Callable(self, "disegna_" + nome.get_slice("_", 0))
	tavola.add_child(tela)
	Manifesto.trama_dietro(tela).show_behind_parent = true
	inizio = tempo - (20.0 if foto else 0.0)   # nelle foto, a entrata finita
	guardato = LIVELLO + (8 if nome == "quadrante_avanti" else 0)
	vista = float(guardato) - (0.0 if foto else 5.0)   # nel film la ruota entra girando
	spinta_vista = 0.0
	a_destra = true
	peso = 1.0
	spinta_peso = 0.0
	cambiato_a = -10.0
	preso_a = -1.0
	passiva = 2
	portata = false
	copione = [] if foto else (COPIONI.get(nome, []) as Array).duplicate(true)
	call("tasti_" + nome.get_slice("_", 0))


func azione(quale: String) -> void:
	var avanti := 1 if quale == "avanti" else -1
	match String(PROPOSTE[indice]).get_slice("_", 0):
		"quadrante":
			if quale != "conferma":
				guardato = clampi(guardato + avanti, 0, SPICCHI - 1)
				cambiato_a = tempo
		"bivio":
			if quale == "conferma":
				preso_a = tempo
			elif preso_a < 0.0:
				a_destra = not a_destra
		"passive":
			if quale != "conferma":
				passiva = posmod(passiva + avanti, PASSIVE.size())
			elif String(PASSIVE[passiva][1]) == "libera" and not portata:
				portata = true
				preso_a = tempo


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
	for voce: Array in coppie:
		var tappo := TappoTasto.nuovo(String(voce[0]))
		tavola.add_child(tappo)
		tappo.position = Vector2(x, dove.y)
		tappo.size = tappo.get_combined_minimum_size()
		x += tappo.size.x + 8.0
		var parola := Tavola.scritta(String(voce[1]), 16, inchiostro, Caratteri.tondo(850))
		tavola.add_child(parola)
		parola.position = Vector2(x, dove.y - 2.0)
		parola.size = Vector2(parola.get_combined_minimum_size().x, tappo.size.y + 4.0)
		x += parola.size.x + 24.0


# --- i dati, i conti e i tempi ---------------------------------------------------------------

const SPICCHI := 20
# cosa arriva a ogni livello oltre alla statistica a scelta: le abilita' senza
# costo arrivano da sole a quel livello (abilita.json), le passive pure
# (crescita.json, passive_livello)
const ARRIVA := {5: ["abilita", "astio"], 8: ["abilita", "vendetta"], 10: ["passiva", "non_ce_tempo"],
		11: ["abilita", "flagello"], 14: ["abilita", "mantra"], 16: ["passiva", "immondizia_tesoro"],
		19: ["abilita", "annichilazione"]}
# la stella doppia di ogni livello (docs/albero.md 4.4), d'esempio, a giro; l'8
# e' quella del bivio, coi due potenziamenti veri
const COPPIE := [["velocita", "difesa"], ["attacco", "fattore"], ["hp", "intelligenza"], ["hp", "attacco"], ["difesa", "attacco"]]
const POTENZIAMENTO := {"hp": "vita_i", "attacco": "attacco_i", "fattore": "dominio_i"}
const ATTUALI := {"hp": 110, "attacco": 17}       # il protagonista d'esempio al livello 7
const FINO_A := {"hp": 200.0, "attacco": 30.0}    # quanto e' lunga la barretta
const PAROLE := {"hp": "VITA", "attacco": "ATTACCO", "difesa": "DIFESA", "velocita": "VELOCITÀ",
		"intelligenza": "INTELLIGENZA", "fattore": "FATTORE"}
const GLIFI := {"astio": "spirale", "vendetta": "fuoco_interno", "flagello": "aghi", "mantra": "loto",
		"annichilazione": "vuoto", "non_ce_tempo": "clessidra", "immondizia_tesoro": "gemma",
		"battito_dell_eroe": "battito", "trinita": "tre", "presenza_minacciosa": "fuoco_interno", "furia": "fiamma",
		"perspicacia_acuta": "occhio"}


static func abilita(id: String) -> Dictionary:
	var tutte: Dictionary = GameState.abilita.get("abilita", {})
	return tutte.get(id, {})


static func potenziamento(stat: String) -> Dictionary:
	var tutti: Dictionary = GameState.abilita.get("potenziamenti", {})
	return tutti.get(String(POTENZIAMENTO.get(stat, "")), {})


static func dati_passiva(id: String) -> Dictionary:
	for elenco in ["passive_livello", "passive_soglia"]:
		for voce: Dictionary in GameState.crescita.get(elenco, []):
			if String(voce.get("id", "")) == id:
				return voce
	return {}


static func nome_stat(chiave: String) -> String:
	var stat: Dictionary = GameState.crescita.get("stat", {})
	return String(stat.get(chiave, {}).get("nome", chiave))


static func coppia(livello: int) -> Array:
	return COPPIE[livello % COPPIE.size()]


static func migliaia(n: int) -> String:
	var s := str(n)
	var fuori := ""
	while s.length() > 3:
		fuori = "." + s.substr(s.length() - 3) + fuori
		s = s.substr(0, s.length() - 3)
	return s + fuori


static func per_punto() -> int:
	return int(GameState.regole.get("hype_per_punto", 1000))


static func punti() -> int:
	return floori(float(HYPE) / per_punto())


func entrata(da: float, durata: float) -> float:
	# dove e' un pezzo della sua entrata, da 0 a 1
	return clampf((tempo - inizio - da) / durata, 0.0, 1.0)


func dopo(quando: float, da: float, durata: float) -> float:
	# come entrata, ma da un momento qualsiasi (una scelta, un tasto)
	return clampf((tempo - quando - da) / durata, 0.0, 1.0) if quando >= 0.0 else 0.0


static func molla(dove: float, spinta: float, verso: float, delta: float) -> Vector2:
	# ci arriva e rimbalza appena, come la ruota che si ferma sullo spicchio
	var nuova := spinta + (170.0 * (verso - dove) - 17.0 * spinta) * delta
	return Vector2(dove + nuova * delta, nuova)


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
	for i in punti() + 1:
		P.gettone(t, dove + Vector2(r * 2.6 * i, 0), r, 1.0 if i < punti() else float(HYPE % per_punto()) / per_punto(),
				inchiostro, vuoto)
	P.scritta(t, dove + Vector2(r * 2.6 * (punti() + 1) - 4, 6), "%d PUNTI" % punti(), 18, inchiostro)
	P.scritta(t, dove + Vector2(r * 2.6 * (punti() + 1) - 4, 26), "%s/%s al prossimo" % [migliaia(HYPE % per_punto()),
			migliaia(per_punto())], 13, inchiostro, Caratteri.tondo(900))


static func segno_arriva(t: CanvasItem, livello: int, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	# il disegno di quello che arriva a quel livello: il glifo dell'abilita',
	# o il rombo della passiva
	var arriva: Array = ARRIVA[livello]
	if String(arriva[0]) == "passiva":
		P.segno_passiva(t, c, l * 0.42)
	else:
		P.glifo(t, String(GLIFI.get(String(arriva[1]), "")), c, l, tinta, fondo)


# --- 1. il quadrante -----------------------------------------------------------------------
#
# Il tronco della demo come una roulette di venti spicchi, uno per livello. La
# lancetta sta ferma, a sinistra, dove la lastra mette il dente; gira la ruota.
# Presi = neri, col disegno di quello che hai scelto; il prossimo esce
# dall'anello; gli altri sono il contorno, col disegno di quello che daranno.

const CENTRO := Vector2(920, 392)
const DENTRO := 206.0
const FUORI := 300.0
const LASTRA_QUADRANTE := [Vector2(-20, -20), Vector2(606, -20), Vector2(440, 740), Vector2(-20, 740)]


func angolo_spicchio(k: int) -> float:
	return PI + deg_to_rad(360.0 / SPICCHI * (k - vista))


func disegna_quadrante(t: CanvasItem) -> void:
	quadrante(t)
	legenda(t, Vector2(1144, 650))
	P.gira(t, Vector2(-600.0 * (1.0 - frena(entrata(0.0, 0.45))), 0), 0.0)
	P.lastra(t, PackedVector2Array(LASTRA_QUADRANTE), P.NERO, P.CREMA, 16.0)
	# il dente della lastra: la lancetta
	var bordo := lerpf(606.0, 440.0, (CENTRO.y + 20.0) / 760.0) + 14.0
	Manifesto.poligono(t, PackedVector2Array([Vector2(bordo, CENTRO.y - 24), Vector2(bordo + 30, CENTRO.y),
			Vector2(bordo, CENTRO.y + 24)]), P.CREMA)
	pannello_quadrante(t, guardato)
	P.dritto(t)
	testata(t, "CRESCITA", true, false)


func quadrante(t: CanvasItem) -> void:
	var c := CENTRO
	var mezzo := deg_to_rad(360.0 / SPICCHI * 0.5 - 1.0)
	var vicini: Array[int] = []
	for k in SPICCHI:
		var a := angolo_spicchio(k)
		var tacca := a + mezzo + deg_to_rad(1.0)
		t.draw_line(c + Vector2.from_angle(tacca) * (FUORI + 6), c + Vector2.from_angle(tacca) * (FUORI + 16), P.NERO, 2.0, true)
		if absf(k - vista) < 1.0:
			vicini.append(k)
			continue
		var preso := k < LIVELLO
		P.spicchio(t, c, DENTRO, FUORI, a - mezzo, a + mezzo, P.NERO if preso else Color(0, 0, 0, 0), P.NERO, 2.0)
		segno_spicchio(t, k + 1, c + Vector2.from_angle(a) * 244.0, 30.0, P.CREMA if preso else P.NERO,
				P.NERO if preso else P.ARANCIO)
		P.scritta(t, c + Vector2.from_angle(a) * 282.0 + Vector2(-20, 6), str(k + 1), 15,
				Color(P.CREMA, 0.6) if preso else Color(P.NERO, 0.5), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER, 40)
	# quello sotto la lancetta esce dall'anello (anche a meta' giro: esce di quanto e' vicino)
	vicini.sort_custom(func(x: int, y: int) -> bool: return absf(x - vista) > absf(y - vista))
	var batte := 0.5 + 0.5 * sin(tempo * 3.0)
	for k in vicini:
		var fuori := 1.0 - absf(k - vista)
		var a := angolo_spicchio(k)
		var spinta := c + Vector2.from_angle(a) * (12.0 + 4.0 * batte) * fuori
		var chiaro := fuori > 0.5
		var tinta := P.CREMA if chiaro else (P.NERO if k < LIVELLO else Color(0, 0, 0, 0))
		var bordo_fuori := FUORI + 34.0 * fuori
		var largo := mezzo + 0.05 * fuori
		P.spicchio(t, spinta + Vector2(8, 8) * fuori, DENTRO + 10 * fuori, bordo_fuori, a - largo, a + largo,
				Color(P.NERO, fuori))
		P.spicchio(t, spinta, DENTRO + 10 * fuori, bordo_fuori, a - largo, a + largo, tinta, P.NERO, 2.0 + 2.0 * fuori)
		var dove := spinta + Vector2.from_angle(a) * (DENTRO + bordo_fuori) * 0.5
		var inchiostro := P.NERO if chiaro or k >= LIVELLO else P.CREMA
		segno_spicchio(t, k + 1, dove + Vector2(0, -18) * fuori, 30.0 + 8.0 * fuori, inchiostro,
				P.CREMA if chiaro else (P.NERO if k < LIVELLO else P.ARANCIO))
		P.scritta(t, dove + Vector2(-30, 8 + 22 * fuori), str(k + 1), roundi(15 + 13 * fuori), inchiostro, null,
				HORIZONTAL_ALIGNMENT_CENTER, 60)
	# il centro: dove sei adesso
	t.draw_circle(c, 190.0, P.NERO, true, -1.0, true)
	t.draw_arc(c, 176.0, 0.0, TAU, 96, P.ARANCIO, 3.0, true)
	Manifesto.poligono(t, PackedVector2Array([c + Vector2(-216, 0), c + Vector2(-178, -18), c + Vector2(-178, 18)]), P.ARANCIO)
	Sagome.emblema(t, c + Vector2(0, -70), 84.0, P.CREMA, P.ARANCIO)
	P.scritta(t, c + Vector2(-90, 4), "LIVELLO", 15, P.CARTA, Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER, 180)
	P.scritta(t, c + Vector2(-90, 108), str(LIVELLO), 104, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 180)


static func segno_spicchio(t: CanvasItem, livello: int, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	# cosa da' (o ha dato) lo spicchio: quello che arriva, se arriva qualcosa;
	# se no la statistica scelta, o il rombo a meta' della scelta che verra'
	if ARRIVA.has(livello):
		segno_arriva(t, livello, c, l, tinta, fondo)
	elif livello == 1:
		P.rombo(t, c, l * 0.14, tinta)
	elif livello <= LIVELLO:
		P.icona_stat(t, String(coppia(livello)[livello % 2]), c, l * 0.9, tinta, fondo)
	else:
		P.biforca(t, c, l * 0.3, Color(tinta, 0.6), 2.0)


static func legenda(t: CanvasItem, dove: Vector2) -> void:
	P.biforca(t, dove + Vector2(8, -5), 8.0, P.NERO, 2.0)
	P.scritta(t, dove + Vector2(26, 0), "STAT A SCELTA", 13, P.NERO, Caratteri.tondo(900))
	P.glifo(t, "aghi", dove + Vector2(8, 18), 20.0, P.NERO, P.ARANCIO)
	P.scritta(t, dove + Vector2(26, 23), "ABILITÀ", 13, P.NERO, Caratteri.tondo(900))
	P.segno_passiva(t, dove + Vector2(8, 41), 9.0)
	P.scritta(t, dove + Vector2(26, 46), "PASSIVA", 13, P.NERO, Caratteri.tondo(900))


func pannello_quadrante(t: CanvasItem, k: int) -> void:
	# quello che dice la lastra cambia con lo spicchio sotto la lancetta
	var livello := k + 1
	var stato := "prossimo" if k == LIVELLO else ("preso" if k < LIVELLO else "dopo")
	var servono := k - LIVELLO + 1
	gettoni(t, Vector2(46, 104), P.CREMA, Color(P.CREMA, 0.14))
	var sopra := {"prossimo": "ARRIVI AL", "preso": "GIÀ PRESO", "dopo": "PIÙ AVANTI"}
	P.scritta(t, Vector2(36, 172), String(sopra[stato]), 18, P.CARTA)
	var numero := str(livello)
	var sale := 26.0 * (1.0 - frena(dopo(cambiato_a, 0.0, 0.22)))
	P.ritagliata(t, Vector2(30, 322 + sale), numero, 170, P.ARANCIO if stato == "prossimo" else P.CREMA, P.NERO, 0,
			P.ARANCIO_SCURO if stato == "prossimo" else P.TRATTO, Vector2(10, 10))
	var x := 40.0 + P.larghezza(numero, 170)
	P.scritta(t, Vector2(x, 226), "LIVELLO", 34, P.CREMA)
	var quanti := {"prossimo": "%d DI %d · COSTA 1 PUNTO" % [livello, SPICCHI], "preso": "%d DI %d" % [livello, SPICCHI],
			"dopo": "SERVONO %d PUNTI · NE HAI %d" % [servono, punti()]}
	P.scritta(t, Vector2(x, 254), String(quanti[stato]), 15, P.CARTA, Caratteri.tondo(900))
	P.scritta(t, Vector2(36, 390), "COSA TI HA DATO" if stato == "preso" else "COSA TI DÀ", 14, P.CARTA, Caratteri.tondo(900))
	var y := 404.0
	if livello == 1:
		P.scritta(t, Vector2(36, y + 26), "IL PUNTO DI PARTENZA", 22, P.CREMA)
		y += 60.0
	else:
		var due: Array = coppia(livello)
		if stato == "preso":
			var scelta_presa := String(due[livello % 2])
			P.icona_stat(t, scelta_presa, Vector2(56, y + 20), 32.0, P.CREMA, P.NERO)
			P.scritta(t, Vector2(90, y + 26), "PIÙ " + String(PAROLE[scelta_presa]), 22, P.CREMA)
			P.scritta(t, Vector2(90, y + 46), "l'hai scelta tu, invece di %s" % nome_stat(String(due[1 - livello % 2])).to_lower(),
					14, P.CARTA, Caratteri.tondo(700))
		else:
			P.biforca(t, Vector2(56, y + 18), 15.0, P.CREMA)
			var detta := "PIÙ %s O PIÙ %s" % [PAROLE[due[0]], PAROLE[due[1]]]
			P.scritta(t, Vector2(90, y + 26), detta, P.corpo_che_entra(detta, 22, 390.0), P.CREMA)
			var come := "una delle due: la scegli quando lo prendi"
			if stato == "prossimo":
				come = "%+d %s o %+d %s: la scegli dopo" % [int(potenziamento(String(due[0])).get("quanto", 1)),
						nome_stat(String(due[0])).to_lower(), int(potenziamento(String(due[1])).get("quanto", 1)),
						nome_stat(String(due[1])).to_lower()]
			P.scritta(t, Vector2(90, y + 46), come, 14, P.CARTA, Caratteri.tondo(700))
		y += 70.0
	if ARRIVA.has(livello):
		var arriva: Array = ARRIVA[livello]
		var tipo := String(arriva[0])
		var id := String(arriva[1])
		var dati := dati_passiva(id) if tipo == "passiva" else abilita(id)
		P.rombo(t, Vector2(56, y + 30), 24.0, P.ARANCIO, P.CREMA, 2.0)
		P.glifo(t, String(GLIFI.get(id, "")), Vector2(56, y + 30), 26.0, P.NERO, P.ARANCIO)
		P.etichetta(t, Vector2(88, y), ("ARRIVA UNA PASSIVA" if tipo == "passiva" else "ARRIVA UN'ABILITÀ")
				if stato != "preso" else ("PASSIVA" if tipo == "passiva" else "ABILITÀ"), 12, P.ARANCIO, P.NERO)
		var nome := String(dati.get("nome", id)).to_upper()
		P.scritta(t, Vector2(90, y + 44), nome, P.corpo_che_entra(nome, 22, 380.0), P.CREMA)
		P.a_capo(t, Rect2(90, y + 52, 370, 44), String(dati.get("descrizione", "")), 14, P.CARTA)
	match stato:
		"prossimo":
			P.etichetta(t, Vector2(30, 606), "PRENDI · 1 PUNTO", 26, P.ARANCIO, P.NERO, P.CREMA)
		"dopo":
			P.etichetta(t, Vector2(30, 612), "IN FILA: PRIMA IL LIVELLO %d" % (LIVELLO + 1), 20, P.SPENTO, P.TRATTO)


func tasti_quadrante() -> void:
	comandi(Vector2(30, 686), [["SU", "gira"], ["INVIO", "prendi"], ["ESC", "indietro"]], P.CARTA)


# --- 2. il bivio ----------------------------------------------------------------------------
#
# Prendere uno spicchio: un punto, due strade. Lo schermo tagliato in due; la
# strada scelta si allarga e il taglio si sposta. Quello che arriva comunque a
# quel livello attraversa il taglio, sulla fascia in basso. Presa la strada,
# il taglio spazza via l'altra.

func disegna_bivio(t: CanvasItem) -> void:
	var batte := 0.5 + 0.5 * sin(tempo * 2.0)
	var due: Array = coppia(LIVELLO + 1)
	var chiude := frena(dopo(preso_a, 0.0, 0.5))
	var entra := -900.0 * (1.0 - frena(entrata(0.0, 0.42)))   # entrando, il nero arriva da sinistra
	var alto := lerpf(760.0, 640.0, peso)                      # il taglio, in cima
	var taglio := lerpf(alto, -200.0 if a_destra else 1480.0, chiude) + entra
	var basso := taglio - 120.0
	t.draw_rect(Rect2(0, 0, 1280, 720), P.CREMA)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.NERO, 0.07), Vector2(1.0, 1.0))
	P.icona_stat(t, String(due[1]), Vector2(1010, 450), 640.0, Color(P.NERO, 0.06), P.CREMA)
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, -20), Vector2(taglio, -20), Vector2(basso, 740), Vector2(-20, 740)]),
			P.NERO)
	P.icona_stat(t, String(due[0]), Vector2(taglio - 410, 470), 600.0, Color(P.CREMA, 0.06), P.NERO)
	Manifesto.poligono(t, PackedVector2Array([Vector2(taglio, -20), Vector2(taglio + 14, -20), Vector2(basso + 14, 740),
			Vector2(basso, 740)]), P.ARANCIO)
	# presa la strada, quella scelta va al margine e l'altra se ne va col taglio
	var sinistra := 54.0 + (taglio - alto if a_destra else entra)
	var destra := lerpf(alto + 60.0, 54.0, chiude) + entra if a_destra else taglio + 60.0
	strada(t, Vector2(sinistra, 0), String(due[0]), 1.0 - peso, true, alto - 150.0)
	strada(t, Vector2(destra, 0), String(due[1]), peso, false, 1250.0 - destra)
	var c := Vector2(taglio - 60.0, 362)
	var r := (66.0 + 4.0 * batte) * (1.0 - chiude)
	if r > 1.0:
		P.rombo(t, c + Vector2(8, 8), r, P.NERO)
		P.rombo(t, c, r, P.ARANCIO, P.NERO, 5.0)
		P.scritta(t, c + Vector2(-60, 16), "1", roundi(58 * r / 66.0), P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 120)
		P.scritta(t, c + Vector2(-60, 40), "PUNTO", 14, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 120)
	fascia_comunque(t)
	var titolo := Color(1, 1, 1, 1.0 - (chiude if not a_destra else 0.0))
	var x := alto + 60.0
	P.etichetta(t, Vector2(x, 40), "UN PUNTO, DUE STRADE", 34, P.NERO * titolo, P.CREMA * titolo, P.ARANCIO * titolo)
	P.scritta(t, Vector2(x + 4, 124), "Il punto ti porta al livello %d. La strada la scegli tu." % (LIVELLO + 1), 16,
			P.NERO * titolo, Caratteri.tondo(800))
	presa(t, String(due[1 if a_destra else 0]))
	P.gira(t, Vector2(entra, 0), 0.0)
	testata(t, "", taglio - entra > 560.0, false)
	P.dritto(t)


func strada(t: CanvasItem, dove: Vector2, stat: String, scelta: float, su_nero: bool, spazio: float) -> void:
	# una delle due: la parola grande, quanto da', da quanto a quanto, e il
	# potenziamento vero che c'e' dietro (abilita.json, potenziamenti)
	var dati := potenziamento(stat)
	var inchiostro := P.CREMA if su_nero else P.NERO
	var piano := P.CARTA if su_nero else Color(P.NERO, 0.75)
	var quanto := int(dati.get("quanto", 1))
	var prima := int(ATTUALI.get(stat, 0))
	var x := dove.x
	if scelta > 0.5:
		P.etichetta(t, Vector2(x, 198), "◆ LA SCEGLI", 16, P.ARANCIO, P.NERO, P.CREMA if su_nero else P.NERO)
	P.scritta(t, Vector2(x, 264), "PIÙ", 44, inchiostro)
	var parola := String(PAROLE[stat])
	var corpo := P.corpo_che_entra(parola, roundi(lerpf(104.0, 150.0, scelta)), spazio)
	P.ritagliata(t, Vector2(x - 6, 396), parola, corpo, inchiostro, P.NERO, 0, Color(P.ARANCIO, scelta), Vector2(8, 8))
	P.scritta(t, Vector2(x, 444), "%+d %s" % [quanto, nome_stat(stat).to_upper()], 30, P.ARANCIO if su_nero else P.ARANCIO_SCURO)
	P.scritta(t, Vector2(x, 472), "«%s» · %s" % [String(dati.get("nome", "")), String(dati.get("descrizione", "")).get_slice(".", 0)],
			16, piano, Caratteri.tondo(700))
	P.scritta(t, Vector2(x, 520), "%d → %d" % [prima, prima + quanto], 34, inchiostro)
	var fondo := float(FINO_A.get(stat, 100.0))
	var barra := Rect2(x + 2, 534, 300, 14)
	P.barretta(t, barra, (prima + quanto) / fondo, P.ARANCIO, Color(inchiostro, 0.15))
	P.barretta(t, barra, prima / fondo, inchiostro)


func fascia_comunque(t: CanvasItem) -> void:
	# quello che arriva comunque a quel livello: attraversa il taglio
	var arriva: Array = ARRIVA[LIVELLO + 1]
	var dati := abilita(String(arriva[1]))
	var entra := frena(entrata(0.35, 0.4))
	P.gira(t, Vector2(-20 - 1400.0 * (1.0 - entra), 604), -1.5)
	t.draw_rect(Rect2(8, 8, 1340, 50), P.NERO)
	t.draw_rect(Rect2(0, 0, 1340, 50), P.ARANCIO)
	t.draw_rect(Rect2(0, 0, 1340, 50), P.NERO, false, 3.0)
	var x := 74.0 + P.scritta_larga(t, Vector2(74, 34), "E IN OGNI CASO, AL LIVELLO %d, ARRIVA" % (LIVELLO + 1), 20, P.NERO)
	P.rombo(t, Vector2(x + 30, 25), 20.0, P.NERO)
	P.glifo(t, String(GLIFI.get(String(arriva[1]), "")), Vector2(x + 30, 25), 24.0, P.ARANCIO, P.NERO)
	x += 62.0 + P.scritta_larga(t, Vector2(x + 62, 36), String(dati.get("nome", "")).to_upper(), 28, P.NERO)
	P.scritta(t, Vector2(x + 16, 33), "nuova abilità: " + String(dati.get("descrizione", "")).get_slice(".", 0).to_lower(),
			15, P.NERO, Caratteri.tondo(800))
	P.dritto(t)


func presa(t: CanvasItem, stat: String) -> void:
	# presa la strada: il timbro col livello nuovo, nel posto lasciato dall'altra
	var timbro := dopo(preso_a, 0.45, 0.35)
	if timbro <= 0.0:
		return
	var quanto := int(potenziamento(stat).get("quanto", 1))
	# sul chiaro un timbro nero, sul nero uno chiaro
	var pieno := P.NERO if a_destra else P.CREMA
	P.gira(t, Vector2(940, 336), -7.0, rimbalza(timbro))
	P.cartoncino(t, Rect2(-190, -90, 380, 170), pieno, 0.0 if a_destra else 5.0, P.OMBRA if a_destra else Vector2(10, 10))
	P.scritta(t, Vector2(-190, -10), "LIVELLO %d" % (LIVELLO + 1), 64, P.CREMA if a_destra else P.NERO, null,
			HORIZONTAL_ALIGNMENT_CENTER, 380)
	P.scritta(t, Vector2(-190, 48), "%+d %s" % [quanto, nome_stat(stat).to_upper()], 30,
			P.ARANCIO if a_destra else P.ARANCIO_SCURO, null, HORIZONTAL_ALIGNMENT_CENTER, 380)
	P.dritto(t)


func tasti_bivio() -> void:
	comandi(Vector2(54, 672), [["CLIC", "scegli"]], P.CARTA)
	comandi(Vector2(704, 672), [["INVIO", "prendi"], ["ESC", "ci penso"]], P.NERO)


# --- 3. le passive --------------------------------------------------------------------------
#
# Le passive si sbloccano salendo, e se ne portano tre: tre alloggi a rombo su
# una fascia nera. Si tolgono e si rimettono quando vuoi (docs/albero.md, 4.5).
# Sotto ci sono tutte, anche quelle chiuse, con quanto manca ad aprirle.

const LIVELLO_PASSIVE := 24
const PERNO_FASCIA := Vector2(600, 356)
const PENDE_FASCIA := -4.5
# id, stato, cosa manca (per le chiuse), quanto ci sei vicino
const PASSIVE := [
	["non_ce_tempo", "in uso", "", 1.0],
	["immondizia_tesoro", "in uso", "", 1.0],
	["battito_dell_eroe", "libera", "", 1.0],
	["trinita", "chiusa", "LV 24/33", 24.0 / 33.0],
	["presenza_minacciosa", "chiusa", "LV 24/40", 24.0 / 40.0],
	["furia", "chiusa", "FATTORE 15/20", 15.0 / 20.0],
	["perspicacia_acuta", "chiusa", "INTELL. 6/40", 6.0 / 40.0],
]


static func nome_passiva(id: String) -> String:
	return String(dati_passiva(id).get("nome", id))


static func requisiti(dati: Dictionary) -> String:
	# cosa la apre: un livello, o delle statistiche (crescita.json, passive_soglia)
	if dati.has("livello"):
		return "AL LIVELLO %d" % int(dati["livello"])
	var pezzi := PackedStringArray()
	var richiede: Dictionary = dati.get("richiede", {})
	for chiave: String in richiede:
		pezzi.append("%s %d" % [nome_stat(chiave).to_upper(), int(richiede[chiave])])
	return "CON " + " E ".join(pezzi)


static func nella_fascia(q: Vector2) -> Vector2:
	return PERNO_FASCIA + q.rotated(deg_to_rad(PENDE_FASCIA))


func disegna_passive(t: CanvasItem) -> void:
	fascia_degli_alloggi(t)
	tutte_le_passive(t)
	P.etichetta(t, Vector2(28, 64), "PASSIVE", 46, P.NERO, P.CREMA, P.CREMA)
	P.scritta(t, Vector2(34, 158), "ANONIMO · LIVELLO %d" % LIVELLO_PASSIVE, 18, P.NERO)
	P.scritta(t, Vector2(34, 182), "Se ne portano tre. Si cambiano quando vuoi.", 16, P.NERO, Caratteri.tondo(800))
	dettaglio_passiva(t, Rect2(864, 24, 392, 158))
	testata(t, "", false, false, LIVELLO_PASSIVE)


func alloggio(t: CanvasItem, c: Vector2, r: float, glifo: String, stato: String) -> void:
	match stato:
		"vuoto":
			var forma := Sagome.chiudi(Sagome.rombo(c, r))
			for i in 4:
				t.draw_dashed_line(forma[i], forma[i + 1], Color(P.CREMA, 0.8), 3.0, 10.0, true, true)
			if glifo == "":
				P.scritta(t, c + Vector2(-r, 18), "+", 56, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0)
			else:
				# quella che stai guardando, se la porti: un fantasma che batte
				var batte := 0.5 + 0.5 * sin(tempo * 4.0)
				P.rombo(t, c, r * 0.74, Color(P.ARANCIO, 0.18 + 0.14 * batte))
				P.glifo(t, glifo, c, r * 0.8, Color(P.CREMA, 0.35 + 0.25 * batte), P.NERO)
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
	P.gira(t, PERNO_FASCIA, PENDE_FASCIA)
	t.draw_rect(Rect2(-760, -100, 1560, 200), P.NERO)
	t.draw_rect(Rect2(-760, -112, 1560, 8), P.CREMA)
	P.etichetta(t, Vector2(-570, -146), "IN USO · %d DI 3" % (3 if portata else 2), 16, P.CREMA, P.NERO, P.NERO)
	var guardata: Array = PASSIVE[passiva]
	var nomi := [nome_passiva("non_ce_tempo"), nome_passiva("immondizia_tesoro"), ""]
	if portata:
		nomi[2] = nome_passiva("battito_dell_eroe")
	elif String(guardata[1]) == "libera":
		nomi[2] = "QUI: " + nome_passiva(String(guardata[0]))
	else:
		nomi[2] = "PORTANE UNA"
	for i in 3:
		var sotto := String(nomi[i]).to_upper()
		if sotto.length() > 22:
			sotto = sotto.substr(0, 19).strip_edges() + "…"
		P.scritta(t, Vector2(-420 + 250 * i - 130, 76), sotto, 16, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 260)
	var quarto := Vector2(330, -12)
	P.rombo(t, quarto, 70.0, Color(0, 0, 0, 0), Color(P.CREMA, 0.25), 3.0)
	Sagome.lucchetto(t, quarto, 34.0, Color(P.CREMA, 0.4))
	P.scritta(t, quarto + Vector2(-120, 88), "AL LIVELLO 30", 16, Color(P.CREMA, 0.5), null, HORIZONTAL_ALIGNMENT_CENTER, 240)
	P.dritto(t)
	# i tre alloggi, ognuno col suo giro (il terzo, quando ci entra, rimbalza)
	var posti := [["clessidra", "in uso"], ["gemma", "in uso"], ["", "vuoto"]]
	if portata:
		posti[2] = ["battito", "scelta"]
	elif String(guardata[1]) == "libera":
		posti[2] = [String(GLIFI.get(String(guardata[0]), "")), "vuoto"]
	for i in 3:
		var scala := rimbalza(dopo(preso_a, 0.0, 0.35)) if i == 2 and portata else 1.0
		P.gira(t, nella_fascia(Vector2(-420 + 250 * i, -12)), PENDE_FASCIA, scala)
		alloggio(t, Vector2.ZERO, 70.0, String(posti[i][0]), String(posti[i][1]))
		P.dritto(t)


func tutte_le_passive(t: CanvasItem) -> void:
	P.gira(t, Vector2(40, 526), 1.2)
	P.cartoncino(t, Rect2(0, 0, 968, 176), P.CREMA, 5.0, P.OMBRA, true)
	P.etichetta(t, Vector2(16, -18), "TUTTE LE PASSIVE · 3 DI 24", 18, P.NERO, P.CREMA)
	for i in PASSIVE.size():
		var voce: Array = PASSIVE[i]
		var c := Vector2(76 + 136 * i, 72)
		var stato := String(voce[1])
		if stato == "libera" and portata:
			stato = "in uso"
		if i == passiva:
			var batte := 0.5 + 0.5 * sin(tempo * 3.0)
			P.rombo(t, c, 58.0 + 3.0 * batte, Color(P.ARANCIO, 0.35), P.NERO, 3.0)
		var glifo := String(GLIFI.get(String(voce[0]), ""))
		alloggio(t, c, 40.0, glifo, "chiusa" if stato == "chiusa" else ("scelta" if stato == "libera" else "in uso"))
		if stato == "chiusa":
			P.scritta(t, Vector2(c.x - 66, 134), String(voce[2]), 14, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 132)
			P.barretta(t, Rect2(c.x - 44, 144, 88, 10), float(voce[3]), P.NERO, Color(P.NERO, 0.15))
		else:
			P.a_capo(t, Rect2(c.x - 66, 120, 132, 40), nome_passiva(String(voce[0])), 14, P.NERO, Caratteri.titolo(),
					HORIZONTAL_ALIGNMENT_CENTER)
		if stato == "in uso":
			P.etichetta(t, c + Vector2(4, -54), "IN USO", 11, P.NERO, P.CREMA)
	P.dritto(t)


func dettaglio_passiva(t: CanvasItem, r: Rect2) -> void:
	# quella guardata: cosa fa, e portala; se e' chiusa, cosa manca
	var voce: Array = PASSIVE[passiva]
	var id := String(voce[0])
	var dati := dati_passiva(id)
	var stato := String(voce[1])
	if stato == "libera" and portata:
		stato = "in uso"
	P.gira(t, r.position, -2.0)
	P.cartoncino(t, Rect2(Vector2.ZERO, r.size), P.NERO, 0.0, P.OMBRA)
	var sopra := ("SI APRE " if stato == "chiusa" else "SBLOCCATA ") + requisiti(dati)
	P.etichetta(t, Vector2(16, -16), sopra, 14, P.TRATTO if stato == "chiusa" else P.ARANCIO, P.NERO)
	alloggio(t, Vector2(58, 76), 40.0, String(GLIFI.get(id, "")), "chiusa" if stato == "chiusa" else "scelta")
	var nome := String(dati.get("nome", id))
	P.scritta(t, Vector2(114, 52), nome, P.corpo_che_entra(nome, 30, r.size.x - 130.0), P.CREMA)
	var cosa_fa := String(dati.get("descrizione", ""))
	if cosa_fa == "":
		cosa_fa = "(Ancora senza descrizione in crescita.json.) Si apre da sola, quando ci arrivi."
	P.a_capo(t, Rect2(114, 62, r.size.x - 130, 64), cosa_fa, 14, P.CARTA)
	match stato:
		"libera":
			P.etichetta(t, Vector2(110, r.size.y - 20), "PORTALA", 22, P.ARANCIO, P.NERO, P.CREMA)
		"in uso":
			P.etichetta(t, Vector2(110, r.size.y - 20), "IN USO · TOGLILA", 20, P.CREMA, P.NERO, P.ARANCIO)
		_:
			P.barretta(t, Rect2(116, r.size.y - 22, 150, 12), float(voce[3]), P.ARANCIO, Color(P.CREMA, 0.15))
			P.scritta(t, Vector2(280, r.size.y - 11), String(voce[2]), 14, P.CARTA, Caratteri.tondo(900))
	P.dritto(t)


func tasti_passive() -> void:
	comandi(Vector2(1030, 560), [["SU", "scegli"]], P.NERO)
	comandi(Vector2(1030, 610), [["INVIO", "porta"]], P.NERO)
	comandi(Vector2(1030, 660), [["ESC", "indietro"]], P.NERO)
