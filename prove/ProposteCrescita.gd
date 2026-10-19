extends Control

# LE PROPOSTE PER LA CRESCITA, quinta mano. Provvisorio: quando la schermata vera
# nasce da qui, questo file se ne va (come ProposteZaino).
#
# Delle sei astratte Bru ne ha tenute tre: «approvato quella che sembra una
# roulette, le passive e un punto due strade». Sono un sistema solo, quello di
# docs/albero.md (4.3, 4.4, 4.5), e dicono cose vere: cosa arriva a ogni
# livello, i nomi, le descrizioni e i potenziamenti vengono da abilita.json e
# crescita.json. Poi, sulla roulette: «arriva fino a 20, superato il 20
# dovremmo farla ricominciare da 21 con un look piu' figo e cosi' via fino al
# livello massimo [...] ovviamente nella beta il cap e' 20». Il massimo e'
# livello_massimo di regole.json (130): sei giri da venti e un ultimo da dieci,
# ognuno con un aspetto piu' acceso del precedente.
#
#   giro_1 .. giro_7  la roulette, un giro per foto
#   fine_beta         il primo giro chiuso, nella beta: il 20 e' il tetto
#   massimo           l'ultimo giro chiuso, al 130: si torna sui bivi
#   statistiche       le icone delle statistiche (IconeStatistiche, TavolaIcone): ognuna
#                     con le due figure da cui nasce, timbrate, nella scheda, piccole
#   misure            le stesse icone sotto la lente (TavolaMisure): forme chiave, centri,
#                     la prova della sfocatura, i numeri, la resa sul fondo della scheda
#   costruzione       le stesse icone coi loro cerchi, centri, tangenti e punti di controllo
#                     (TavolaCostruzione)
#   simboli           la tavola dei simboli (SimboliCrescita), grandi e piccoli
#   bivio             prendere lo spicchio: un punto, due strade
#   passive           quelle sbloccate si portano in tre alloggi, e si cambiano
#
#   ./prove/proposte_crescita.sh        le fotografa in scatti/proposte_crescita/
#   -- film giri                        dal primo giro all'ultimo, coi passaggi
#   -- film giro_1 (o bivio, passive)   una sola, usata da un copione
#   nell'editor, F6: destra e sinistra cambiano schermata; su, giu' e invio la usano

const P := preload("res://prove/PezziCrescita.gd")
const S := preload("res://prove/SimboliCrescita.gd")
const IS := preload("res://prove/IconeStatistiche.gd")
const TI := preload("res://prove/TavolaIcone.gd")
const TM := preload("res://prove/TavolaMisure.gd")
const TC := preload("res://prove/TavolaCostruzione.gd")
const PROPOSTE := ["giro_1", "giro_2", "giro_3", "giro_4", "giro_5", "giro_6", "giro_7", "fine_beta", "massimo",
		"statistiche", "misure", "costruzione", "simboli", "bivio", "passive"]
const CARTELLA := "res://scatti/proposte_crescita"
const HYPE := 3450
const LIVELLO := 7          # il protagonista d'esempio del bivio
const TETTO_BETA := 20      # Bru: «nella beta il cap e' 20»
# dove sta il protagonista d'esempio in ogni foto della roulette: un livello
# prima di uno in cui arriva qualcosa, per vederlo sulla lastra
const ADESSO := {"giro_1": 7, "giro_2": 32, "giro_3": 44, "giro_4": 64, "giro_5": 87, "giro_6": 110, "giro_7": 125,
		"fine_beta": 20, "massimo": 130, "giri": 20}
# nel film: quando (secondi dall'entrata) e cosa fa da solo chi la usa
const COPIONI := {
	"giro_1": [[1.5, "avanti"], [1.95, "avanti"], [2.4, "avanti"], [3.5, "indietro"], [3.75, "indietro"], [4.0, "indietro"]],
	# il giro chiuso passa al prossimo; il prossimo si riempie (la ruota fa un giro intero) e passa ancora
	"giri": [[1.2, "conferma"], [3.2, "riempi"], [4.4, "conferma"], [6.4, "riempi"], [7.6, "conferma"], [9.6, "riempi"],
			[10.8, "conferma"], [12.8, "riempi"], [14.0, "conferma"], [16.0, "riempi"], [17.2, "conferma"], [19.6, "riempi"]],
	"bivio": [[1.5, "avanti"], [2.4, "avanti"], [3.2, "conferma"]],
	"passive": [[1.4, "conferma"], [2.5, "avanti"], [3.2, "avanti"]],
}

var indice := 0
var schermata := ""
var tavola: Tavola
var tela: Disegno
var tempo := 1.3
var inizio := 0.0       # quando e' comparsa la schermata: le entrate contano da qui
var foto := false
var copione: Array = []
var arrivi := {}        # livello -> [[tipo, id], ...]: cosa arriva a quel livello
# lo stato di chi la usa
var adesso := LIVELLO          # il livello del protagonista
var beta := false
var guardato := LIVELLO + 1    # il livello sotto la lancetta
var vista := float(LIVELLO + 1)   # dove sta davvero la ruota: ci arriva con una molla
var spinta_vista := 0.0
var giro_prima := 0            # nel passaggio da un giro all'altro, quello che se ne va
var cambio_giro_a := -10.0
var riempi_a := -10.0          # nel film: il giro si riempie in un attimo, come il tempo che passa
var riempi_da := 0
var riempi_fino := 0
var a_destra := true           # la strada scelta nel bivio
var peso := 1.0                # 0 = la strada di sinistra, 1 = quella di destra, con la molla
var spinta_peso := 0.0
var cambiato_a := -10.0
var preso_a := -1.0
var passiva := 2               # quella guardata fra tutte
var portata := false
var scelte := {}               # livello -> la strada presa (la scrive la salita); senza, pari o dispari


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prepara_arrivi()
	var argomenti := OS.get_cmdline_user_args()
	foto = "foto" in argomenti
	if not foto:
		# "-- film bivio": parte da quella, per registrarla col Movie Maker
		var quale := String(argomenti[argomenti.find("film") + 1]) if "film" in argomenti and argomenti.size() > 1 else ""
		if quale in PROPOSTE:
			mostra(PROPOSTE.find(quale))
		else:
			mostra_nome(quale if COPIONI.has(quale) else String(PROPOSTE[0]))
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
		immagine.save_png(CARTELLA.path_join("%02d_%s.png" % [i + 1, PROPOSTE[i]]))
		print("PROPOSTA %d: %s" % [i + 1, PROPOSTE[i]])
	get_tree().quit()


func _process(delta: float) -> void:
	if foto:
		return
	tempo += delta
	while not copione.is_empty() and tempo - inizio >= float(copione[0][0]):
		var battuta: Array = copione.pop_front()
		azione(String(battuta[1]))
	if riempi_a >= 0.0:
		var fatto := clampf((tempo - riempi_a) / 0.9, 0.0, 1.0)
		adesso = riempi_da + roundi(fatto * (riempi_fino - riempi_da))
		guardato = maxi(adesso, riempi_da + 1)
		if fatto >= 1.0:
			riempi_a = -10.0
	if tempo - cambio_giro_a < 1.0:
		# mentre passa al giro nuovo la ruota aspetta, poi entra girando
		vista = float(guardato) - 5.0
		spinta_vista = 0.0
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


static func genere(nome: String) -> String:
	return nome if nome in ["bivio", "passive", "simboli", "statistiche", "misure", "costruzione"] else "quadrante"


func mostra(quale: int) -> void:
	indice = quale
	mostra_nome(String(PROPOSTE[quale]))


func mostra_nome(nome: String) -> void:
	schermata = nome
	if tavola != null:
		tavola.queue_free()
	tavola = Tavola.su(self)
	tela = Disegno.new()
	tela.come = Callable(self, "disegna_" + genere(nome))
	tavola.add_child(tela)
	Manifesto.trama_dietro(tela).show_behind_parent = true
	inizio = tempo - (20.0 if foto else 0.0)   # nelle foto, a entrata finita
	adesso = int(ADESSO.get(nome, LIVELLO))
	beta = nome == "fine_beta"
	# a giro chiuso la lancetta sta sull'ultimo; se no sul prossimo
	guardato = adesso if nome in ["fine_beta", "massimo", "giri"] else adesso + 1
	vista = float(guardato) - (0.0 if foto else 5.0)   # nel film la ruota entra girando
	spinta_vista = 0.0
	giro_prima = giro_di(guardato)
	cambio_giro_a = -10.0
	riempi_a = -10.0
	a_destra = true
	peso = 1.0
	spinta_peso = 0.0
	cambiato_a = -10.0
	preso_a = -1.0
	passiva = 2
	portata = false
	copione = [] if foto else (COPIONI.get(nome, []) as Array).duplicate(true)
	call("tasti_" + genere(nome))
	grana()


func azione(quale: String) -> void:
	var avanti := 1 if quale == "avanti" else -1
	match genere(schermata):
		"quadrante":
			var g := giro_di(guardato)
			if quale == "riempi":
				riempi_a = tempo
				riempi_da = adesso
				riempi_fino = ultimo_del_giro(g)
			elif quale != "conferma":
				guardato = clampi(guardato + avanti, primo_del_giro(g), mini(ultimo_del_giro(g), TETTO_BETA if beta else 999))
				cambiato_a = tempo
			elif chiuso() and not beta and g < giri() - 1:
				# giro chiuso: si passa al prossimo
				giro_prima = g
				guardato = adesso + 1
				cambio_giro_a = tempo
				cambiato_a = tempo + 0.55
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


static var carta_grana: ImageTexture


func grana() -> void:
	# la grana della stampa, sopra a tutto: il vettoriale perfetto e liscio e'
	# una delle cose che fanno «sa di ai». Rumore fisso (stesso seme), chiaro e
	# scuro, leggerissimo
	if carta_grana == null:
		var immagine := Image.create(256, 256, false, Image.FORMAT_LA8)
		var caso := RandomNumberGenerator.new()
		caso.seed = 1907
		for y in 256:
			for x in 256:
				var v := caso.randf()
				immagine.set_pixel(x, y, Color(1.0 if v > 0.5 else 0.0, 0, 0, absf(v - 0.5) * 2.0))
		carta_grana = ImageTexture.create_from_image(immagine)
	var sopra := TextureRect.new()
	sopra.texture = carta_grana
	sopra.stretch_mode = TextureRect.STRETCH_TILE
	sopra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sopra.size = Vector2(Tavola.LARGO, Tavola.ALTO)
	sopra.modulate = Color(1, 1, 1, 0.09)
	tavola.add_child(sopra)


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

# le abilita' del protagonista: le sue tre linee (classes.json) e le tre senza
# linea che oggi sono sue (docs/albero.md, domanda 8)
const LINEE := ["flagello", "annichilazione", "mantra"]
const SENZA_LINEA := ["astio", "vendetta", "pieta"]
# la stella doppia di ogni livello (docs/albero.md 4.4), d'esempio, a giro; l'8
# e' quella del bivio, coi due potenziamenti veri
const COPPIE := [["velocita", "difesa"], ["attacco", "fattore"], ["hp", "intelligenza"], ["hp", "attacco"], ["difesa", "attacco"]]
const POTENZIAMENTO := {"hp": "vita_i", "attacco": "attacco_i", "fattore": "dominio_i"}
const ATTUALI := {"hp": 110, "attacco": 17}       # il protagonista d'esempio al livello 7
const FINO_A := {"hp": 200.0, "attacco": 30.0}    # quanto e' lunga la barretta
const PAROLE := {"hp": "VITA", "attacco": "ATTACCO", "difesa": "DIFESA", "velocita": "VELOCITÀ",
		"intelligenza": "INTELLIGENZA", "fattore": "FATTORE"}
func prepara_arrivi() -> void:
	# le abilita' senza costo arrivano da sole al loro livello (abilita.json), e
	# cosi' le passive (crescita.json, passive_livello): prima le abilita'
	arrivi = {}
	var tutte: Dictionary = GameState.abilita.get("abilita", {})
	for id: String in tutte:
		var dati: Dictionary = tutte[id]
		if dati.has("livello") and (String(dati.get("linea", "")) in LINEE or id in SENZA_LINEA):
			(arrivi.get_or_add(int(dati["livello"]), []) as Array).append(["abilita", id])
	for voce: Dictionary in GameState.crescita.get("passive_livello", []):
		(arrivi.get_or_add(int(voce.get("livello", 0)), []) as Array).append(["passiva", String(voce.get("id", ""))])


func arrivi_di(livello: int) -> Array:
	return arrivi.get(livello, [])


static func simbolo_di(tipo: String, id: String) -> String:
	# il simbolo (SimboliCrescita) di una passiva e' il suo id; di un'abilita', la sua linea
	if tipo == "passiva":
		return id
	var linea := String(abilita(id).get("linea", ""))
	return linea if linea != "" else id


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


static func dati_di(tipo: String, id: String) -> Dictionary:
	return dati_passiva(id) if tipo == "passiva" else abilita(id)


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


static func velo(tinta: Color, quanto: float) -> Color:
	return Color(tinta, tinta.a * quanto)


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


# --- 1. la roulette, a giri -----------------------------------------------------------------
#
# Il tronco come una roulette: un giro di venti tasche, una per livello. La
# lancetta sta ferma, a sinistra, dove la lastra mette il dente; gira la ruota.
# Chiuso un giro se ne apre un altro, dal 21, dal 41... fino al massimo
# (l'ultimo, 121-130, ha dieci tasche, piu' grandi).
#
# Terza mano. La seconda era la ghiera di un orologio: Bru, «già meglio ma sa
# ancora di ai». Aveva ragione: anelli sottili, tacche minute e scritte
# piccolissime sono il pannello di fantascienza che fa qualunque generatore.
# Qui ci sono tre cose sole, grandi, nella lingua del manifesto:
#   le tasche   prese piene, da prendere chiare, coi simboli timbrati
#   i numeri    grandi, ognuno nella sua cella, come sull'anello della ruota
#               vera; dove arriva qualcosa la cella cambia colore, come lo zero
#   il mozzo    il retino del manifesto, il giro e il livello, enorme
# Ogni giro rimescola i tre colori; dal terzo in poi la ruota ha un orlo, dal
# quinto coi rombi, nell'ultimo doppio.

const CENTRO := Vector2(938, 392)
const R_MOZZO := 170.0
const R_DENTRO := 180.0
const R_FUORI := 276.0
const R_CELLE := 282.0      # l'anello dei numeri
const R_ORLO := 336.0
const LASTRA_QUADRANTE := [Vector2(-20, -20), Vector2(606, -20), Vector2(440, 740), Vector2(-20, 740)]
const SIPARIO := [Vector2(596, -20), Vector2(1300, -20), Vector2(1300, 740), Vector2(430, 740)]
const ROMANI := ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]


static func massimo() -> int:
	return int(GameState.regole.get("livello_massimo", 130))


static func giri() -> int:
	return ceili(massimo() / 20.0)


static func giro_di(livello: int) -> int:
	return clampi(floori((livello - 1) / 20.0), 0, giri() - 1)


static func primo_del_giro(g: int) -> int:
	return 20 * g + 1


static func spicchi_del_giro(g: int) -> int:
	return mini(20, massimo() - 20 * g)


static func ultimo_del_giro(g: int) -> int:
	return primo_del_giro(g) + spicchi_del_giro(g) - 1


func chiuso() -> bool:
	# il giro di adesso e' finito: tutte le sue tasche sono prese
	return adesso == ultimo_del_giro(giro_di(adesso)) or (beta and adesso >= TETTO_BETA)


static func tema(g: int) -> Dictionary:
	# per ogni giro: il campo, l'anello dei numeri, le tasche prese e da
	# prendere, quella che esce, il mozzo. Tre colori soli e due loro toni
	# (la carta e il bruno), ogni volta in un ordine diverso. "ombra" e' quella
	# piena dei simboli timbrati
	var tm: Dictionary
	match g:
		0:
			tm = {"campo": "arancio", "anello": P.NERO, "numero": P.CREMA, "numero_preso": P.ARANCIO,
					"speciale": P.CREMA, "speciale_segno": P.NERO,
					"presa": P.NERO, "presa_segno": P.CREMA, "presa_ombra": P.ARANCIO,
					"futura": P.CREMA, "futura_segno": P.NERO, "futura_ombra": P.ARANCIO,
					"esce": P.CREMA, "esce_segno": P.NERO, "esce_ombra": P.ARANCIO,
					"mozzo": P.NERO, "mozzo_numero": P.CREMA, "mozzo_ombra": P.ARANCIO, "retino": Color(P.ARANCIO, 0.55),
					"accento": P.ARANCIO}
		1:
			tm = {"campo": "carta", "anello": P.NERO, "numero": P.CREMA, "numero_preso": P.ARANCIO,
					"speciale": P.ARANCIO, "speciale_segno": P.NERO,
					"presa": P.ARANCIO, "presa_segno": P.NERO, "presa_ombra": P.CREMA,
					"futura": P.CARTA, "futura_segno": P.NERO, "futura_ombra": P.ARANCIO,
					"esce": P.NERO, "esce_segno": P.ARANCIO, "esce_ombra": P.CREMA,
					"mozzo": P.NERO, "mozzo_numero": P.ARANCIO, "mozzo_ombra": P.CREMA, "retino": Color(P.CREMA, 0.3),
					"accento": P.ARANCIO}
		2:
			tm = {"campo": "nero", "anello": P.ARANCIO, "numero": P.NERO, "numero_preso": Color(P.NERO, 0.45),
					"speciale": P.CREMA, "speciale_segno": P.NERO,
					"presa": P.CREMA, "presa_segno": P.NERO, "presa_ombra": P.ARANCIO,
					"futura": P.BRUNO, "futura_segno": P.CREMA, "futura_ombra": P.NERO,
					"esce": P.ARANCIO, "esce_segno": P.NERO, "esce_ombra": P.CREMA,
					"mozzo": P.ARANCIO, "mozzo_numero": P.NERO, "mozzo_ombra": P.CREMA, "retino": Color(P.NERO, 0.3),
					"accento": P.NERO}
		3:
			tm = {"campo": "arancio", "anello": P.CREMA, "numero": P.NERO, "numero_preso": P.ARANCIO_SCURO,
					"speciale": P.NERO, "speciale_segno": P.CREMA,
					"presa": P.NERO, "presa_segno": P.CREMA, "presa_ombra": P.ARANCIO,
					"futura": P.ARANCIO_SCURO, "futura_segno": P.NERO, "futura_ombra": P.CREMA,
					"esce": P.CREMA, "esce_segno": P.NERO, "esce_ombra": P.ARANCIO,
					"mozzo": P.CREMA, "mozzo_numero": P.NERO, "mozzo_ombra": P.ARANCIO, "retino": Color(P.ARANCIO, 0.5),
					"accento": P.ARANCIO_SCURO}
		4:
			tm = {"campo": "nero", "anello": P.CREMA, "numero": P.NERO, "numero_preso": P.TRATTO,
					"speciale": P.ARANCIO, "speciale_segno": P.NERO,
					"presa": P.ARANCIO, "presa_segno": P.NERO, "presa_ombra": P.CREMA,
					"futura": P.BRUNO, "futura_segno": P.CREMA, "futura_ombra": P.NERO,
					"esce": P.CREMA, "esce_segno": P.NERO, "esce_ombra": P.ARANCIO,
					"mozzo": P.NERO, "mozzo_numero": P.CREMA, "mozzo_ombra": P.ARANCIO, "retino": Color(P.ARANCIO, 0.4),
					"accento": P.ARANCIO}
		5:
			tm = {"campo": "carta", "anello": P.ARANCIO, "numero": P.NERO, "numero_preso": Color(P.NERO, 0.45),
					"speciale": P.NERO, "speciale_segno": P.CREMA,
					"presa": P.NERO, "presa_segno": P.ARANCIO, "presa_ombra": P.CREMA,
					"futura": P.CARTA, "futura_segno": P.NERO, "futura_ombra": P.ARANCIO,
					"esce": P.ARANCIO, "esce_segno": P.NERO, "esce_ombra": P.CREMA,
					"mozzo": P.ARANCIO, "mozzo_numero": P.NERO, "mozzo_ombra": P.CREMA, "retino": Color(P.NERO, 0.25),
					"accento": P.NERO}
		_:
			tm = {"campo": "nero", "anello": P.ARANCIO, "numero": P.NERO, "numero_preso": Color(P.NERO, 0.45),
					"speciale": P.CREMA, "speciale_segno": P.NERO,
					"presa": P.ARANCIO, "presa_segno": P.NERO, "presa_ombra": P.CREMA,
					"futura": P.BRUNO, "futura_segno": P.ARANCIO, "futura_ombra": P.NERO,
					"esce": P.CREMA, "esce_segno": P.NERO, "esce_ombra": P.ARANCIO,
					"mozzo": P.NERO, "mozzo_numero": P.ARANCIO, "mozzo_ombra": P.CREMA, "retino": Color(P.ARANCIO, 0.45),
					"accento": P.ARANCIO}
	tm["nome"] = ["PRIMO", "SECONDO", "TERZO", "QUARTO", "QUINTO", "SESTO", "ULTIMO"][mini(g, 6)] + " GIRO"
	return tm


func disegna_quadrante(t: CanvasItem) -> void:
	# nel passaggio da un giro all'altro: il vecchio vola via (fino a 0,55 s), una
	# lastra col nome del nuovo copre tutto, il nuovo si monta (da 1 s)
	var p := tempo - cambio_giro_a
	var g := giro_prima if p < 0.55 else giro_di(guardato)
	var tm := tema(g)
	var v := float(adesso) if p < 0.55 else vista
	match String(tm["campo"]):
		"nero":
			t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
			Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.07), Vector2(1.0, 1.0))
		"carta":
			t.draw_rect(Rect2(0, 0, 1280, 720), P.CREMA)
			Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.NERO, 0.07), Vector2(1.0, 1.0))
	ruota_giro(t, tm, g, v, p)
	mozzo(t, tm, g)
	legenda(t)
	P.gira(t, Vector2(-600.0 * (1.0 - frena(entrata(0.0, 0.45))), 0), 0.0)
	P.lastra(t, PackedVector2Array(LASTRA_QUADRANTE), P.NERO, P.CREMA, 16.0)
	# il dente della lastra e' la lancetta
	var bordo := lerpf(606.0, 440.0, (CENTRO.y + 20.0) / 760.0) + 14.0
	Manifesto.poligono(t, PackedVector2Array([Vector2(bordo, CENTRO.y - 22), Vector2(bordo + 34, CENTRO.y),
			Vector2(bordo, CENTRO.y + 22)]), P.CREMA)
	pannello_quadrante(t, adesso if p < 0.55 else guardato)
	P.dritto(t)
	sipario(t, p, giro_di(guardato))
	testata(t, "CRESCITA", true, tm["campo"] == "nero", adesso)


func ruota_giro(t: CanvasItem, tm: Dictionary, g: int, v: float, p: float) -> void:
	# p: i secondi dall'inizio del passaggio a questo giro (tanti, se non ce n'e' stato)
	var c := CENTRO
	var n := spicchi_del_giro(g)
	var primo := primo_del_giro(g)
	var passo := TAU / n
	var mezzo := passo * 0.5 - deg_to_rad(1.1)
	var lato := 42.0 * sqrt(20.0 / n)   # i simboli crescono quando le tasche sono meno
	var vicini: Array[int] = []
	# l'orlo, dal terzo giro: uno spesso, poi coi rombi, nell'ultimo doppio
	var tutta := 1.0 - frena(clampf(p / 0.45, 0.0, 1.0)) if p < 0.55 else frena(clampf((p - 1.0) / 0.5, 0.0, 1.0))
	if g >= 2:
		t.draw_arc(c, R_ORLO + 9.0, 0.0, TAU, 180, velo(tm["anello"], tutta), 6.0, true)
	if g >= 6:
		t.draw_arc(c, R_ORLO + 19.0, 0.0, TAU, 180, velo(tm["anello"], tutta), 2.0, true)
	if g >= 4:
		for k in n:
			var su := Vector2.from_angle(PI + passo * (primo + k - v) + passo * 0.5)
			Manifesto.poligono(t, Sagome.rombo(c + su * (R_ORLO + 9.0), 7.0), velo(tm["accento"] if g < 6 else P.CREMA, tutta))
	for k in n:
		var livello := primo + k
		var a := PI + passo * (livello - v)
		# volano via nel passaggio, e il giro nuovo si monta una tasca alla volta
		var esce := frena(clampf((p - 0.012 * k) / 0.3, 0.0, 1.0)) if p < 0.55 else 0.0
		var entra := frena(clampf((p - 1.0 - 0.022 * k) / 0.32, 0.0, 1.0)) if p >= 0.55 else 1.0
		var alfa := (1.0 - esce) * entra
		if alfa <= 0.0:
			continue
		var o := c + Vector2.from_angle(a) * (460.0 * esce + 420.0 * (1.0 - entra))
		cella(t, tm, o, a, mezzo, livello, alfa)
		if absf(livello - v) < 1.0 and alfa >= 1.0:
			vicini.append(livello)
			continue
		var preso := livello <= adesso
		var pieno: Color = tm["presa"] if preso else tm["futura"]
		P.spicchio(t, o, R_DENTRO, R_FUORI, a - mezzo, a + mezzo, velo(pieno, alfa))
		simbolo_tasca(t, livello, o + Vector2.from_angle(a) * (R_DENTRO + R_FUORI) * 0.5, lato,
				velo(tm["presa_segno"] if preso else tm["futura_segno"], alfa), pieno,
				velo(tm["presa_ombra"] if preso else tm["futura_ombra"], alfa), preso)
	# quella sotto la lancetta esce dalla ruota (anche a meta' giro: esce di quanto e' vicina)
	vicini.sort_custom(func(x: int, y: int) -> bool: return absf(x - v) > absf(y - v))
	for livello in vicini:
		var fuori := 1.0 - absf(livello - v)
		var a := PI + passo * (livello - v)
		var o := c + Vector2.from_angle(a) * 12.0 * fuori
		var chiara := fuori > 0.5
		var preso := livello <= adesso
		var pieno: Color = tm["esce"] if chiara else (tm["presa"] if preso else tm["futura"])
		var dentro := R_DENTRO + 4.0 * fuori
		var oltre := R_FUORI + 36.0 * fuori
		var largo := mezzo + 0.04 * fuori
		P.spicchio(t, o + Vector2(9, 9) * fuori, dentro, oltre, a - largo, a + largo, velo(tm["anello"], fuori))
		P.spicchio(t, o, dentro, oltre, a - largo, a + largo, pieno, velo(P.NERO, fuori), 3.0)
		var dove := o + Vector2.from_angle(a) * (dentro + oltre) * 0.5
		var segno: Color = tm["esce_segno"] if chiara else (tm["presa_segno"] if preso else tm["futura_segno"])
		var ombra: Color = tm["esce_ombra"] if chiara else (tm["presa_ombra"] if preso else tm["futura_ombra"])
		simbolo_tasca(t, livello, dove + Vector2(0, -18) * fuori, lato + 10.0 * fuori, segno, pieno, ombra, preso)
		P.scritta(t, dove + Vector2(-40, 12 + 28 * fuori), str(livello), roundi(18 + 12 * fuori), segno, null,
				HORIZONTAL_ALIGNMENT_CENTER, 80)


func cella(t: CanvasItem, tm: Dictionary, o: Vector2, a: float, mezzo: float, livello: int, alfa: float) -> void:
	# la cella del numero, sull'anello: dove arriva qualcosa cambia colore, come
	# lo zero sulla ruota vera. Il numero segue il cerchio: sopra con la testa
	# fuori, sotto con la testa dentro, cosi' si legge sempre
	var speciale := not arrivi_di(livello).is_empty()
	P.spicchio(t, o, R_CELLE, R_ORLO, a - mezzo, a + mezzo, velo(tm["speciale"] if speciale else tm["anello"], alfa))
	var colore: Color = tm["speciale_segno"] if speciale else (tm["numero_preso"] if livello <= adesso else tm["numero"])
	var giro := a + PI * 0.5 if sin(a) <= 0.0 else a - PI * 0.5
	P.gira(t, o + Vector2.from_angle(a) * (R_CELLE + R_ORLO) * 0.5, rad_to_deg(giro))
	P.scritta(t, Vector2(-40, 9), str(livello), 24 if livello < 100 else 20, velo(colore, alfa), null,
			HORIZONTAL_ALIGNMENT_CENTER, 80)
	P.dritto(t)


func simbolo_tasca(t: CanvasItem, livello: int, c: Vector2, l: float, tinta: Color, fondo: Color, ombra: Color,
		preso: bool) -> void:
	# cosa da' (o ha dato) la tasca: quello che arriva, se arriva qualcosa; se no
	# la statistica scelta, o la strada che si divide della scelta che verra'.
	# Timbrati: con l'ombra piena spostata
	var qui := arrivi_di(livello)
	if not qui.is_empty():
		var primo: Array = qui[0]
		var id := String(primo[1])
		if String(primo[0]) == "passiva":
			S.passiva_timbro(t, id, c, l * 1.05, tinta, fondo, ombra)
		else:
			S.timbro(t, simbolo_di("abilita", id), c, l, tinta, fondo, ombra)
			var grado := int(abilita(id).get("grado", 1))
			if grado > 1:
				S.gradi(t, grado, c + Vector2(0, l * 0.7), l, tinta)
		if qui.size() > 1:
			P.scritta(t, c + Vector2(l * 0.44, -l * 0.34), "+%d" % (qui.size() - 1), 13, tinta)
	elif livello == 1:
		S.rombo(t, c, l, 12, 12, 3.4, tinta)
	elif preso:
		IS.timbro(t, scelta_di(livello), c, l * 1.1, tinta, fondo, ombra)
	else:
		# la scelta che verra', piu' quieta: senza ombra, un colore pieno a meta' fra segno e tasca
		S.disegna(t, "biforca", c, l * 0.78, Color(Color(fondo, 1.0).lerp(Color(tinta, 1.0), 0.6), tinta.a), fondo)


func mozzo(t: CanvasItem, tm: Dictionary, g: int) -> void:
	# il centro: il retino del manifesto, il giro, e il livello enorme
	var c := CENTRO
	t.draw_circle(c, R_MOZZO, tm["mozzo"], true, -1.0, true)
	var centri: Array[Vector2] = []
	var raggi: Array[float] = []
	var passo := 10.0
	var y := -R_MOZZO
	while y <= R_MOZZO:
		var x := -R_MOZZO
		while x <= R_MOZZO:
			var q := Vector2(x + (passo * 0.5 if roundi(y / passo) % 2 == 0 else 0.0), y)
			# i punti crescono verso il basso a destra, come nelle ombre del manifesto
			var quanto := clampf((q.x + q.y) / (R_MOZZO * 1.7) + 0.3, 0.0, 1.0)
			if q.length() < R_MOZZO - 8.0 and quanto > 0.2:
				centri.append(c + q)
				raggi.append(3.9 * quanto * quanto)
			x += passo
		y += passo
	Manifesto.puntini(t, centri, raggi, tm["retino"])
	var giro := "GIRO %s" % ROMANI[g]
	P.etichetta(t, c + Vector2(-(P.larghezza(giro, 18) + 20.0) * 0.5, -122), giro, 18, tm["accento"],
			tm["mozzo"] if tm["accento"] != tm["mozzo"] else tm["mozzo_numero"])
	numero_del_mozzo(t, tm)
	if beta:
		var tetto := "TETTO DELLA BETA"
		P.etichetta(t, c + Vector2(-(P.larghezza(tetto, 14) + 15.0) * 0.5, 84), tetto, 14, P.ARANCIO, P.NERO)


func numero_del_mozzo(t: CanvasItem, tm: Dictionary) -> void:
	# il livello, enorme (nella salita rotola: FilmSalita)
	numero_nel_mozzo(t, tm, str(adesso), Vector2.ZERO, 1.0)


static func numero_nel_mozzo(t: CanvasItem, tm: Dictionary, numero: String, spinta: Vector2, alfa: float) -> void:
	var corpo := 150 if numero.length() < 3 else 112
	P.ritagliata(t, CENTRO + spinta + Vector2(-170, 54 if numero.length() < 3 else 40), numero, corpo,
			velo(tm["mozzo_numero"], alfa), P.NERO, 0, velo(tm["mozzo_ombra"], alfa), Vector2(9, 9), null,
			HORIZONTAL_ALIGNMENT_CENTER, 340)


func scelta_di(livello: int) -> String:
	# la strada presa a quel livello: quella vera, se la salita l'ha scritta
	return String(scelte.get(livello, coppia(livello)[livello % 2]))


static func legenda(t: CanvasItem) -> void:
	# su un cartellino nero, cosi' si legge su tutti i fondi
	var dove := Vector2(1196, 670)
	Manifesto.poligono(t, P.storta(Rect2(dove + Vector2(-18, -22), Vector2(110, 74)), 0.1), P.NERO)
	S.disegna(t, "biforca", dove + Vector2(4, -6), 18.0, P.CREMA, P.NERO)
	P.scritta(t, dove + Vector2(20, -1), "A SCELTA", 12, P.CREMA, Caratteri.tondo(900))
	S.disegna(t, "flagello", dove + Vector2(4, 17), 18.0, P.CREMA, P.NERO)
	P.scritta(t, dove + Vector2(20, 22), "ABILITÀ", 12, P.CREMA, Caratteri.tondo(900))
	S.passiva(t, "non_ce_tempo", dove + Vector2(4, 40), 18.0, P.CREMA, P.NERO)
	P.scritta(t, dove + Vector2(20, 45), "PASSIVA", 12, P.CREMA, Caratteri.tondo(900))


func pannello_quadrante(t: CanvasItem, livello: int) -> void:
	# quello che dice la lastra cambia con lo spicchio sotto la lancetta
	var g := giro_di(livello)
	var stato := "prossimo" if livello == adesso + 1 else ("preso" if livello <= adesso else "dopo")
	if livello == adesso and chiuso():
		stato = "chiuso"
	var servono := livello - adesso
	gettoni(t, Vector2(46, 104), P.CREMA, Color(P.CREMA, 0.14))
	var sopra := {"prossimo": "ARRIVI AL", "preso": "GIÀ PRESO", "dopo": "PIÙ AVANTI", "chiuso": "HAI CHIUSO IL GIRO AL"}
	P.scritta(t, Vector2(36, 172), String(sopra[stato]), 18, P.CARTA)
	var numero := str(livello)
	var corpo := 170 if numero.length() < 3 else 128
	var sale := 26.0 * (1.0 - frena(dopo(cambiato_a, 0.0, 0.22))) if tempo >= cambiato_a else 0.0
	var arancio := stato in ["prossimo", "chiuso"]
	P.ritagliata(t, Vector2(30, 322 + sale), numero, corpo, P.ARANCIO if arancio else P.CREMA, P.NERO, 0,
			P.ARANCIO_SCURO if arancio else P.TRATTO, Vector2(10, 10))
	var x := 40.0 + P.larghezza(numero, corpo)
	P.scritta(t, Vector2(x, 226), "LIVELLO", 34, P.CREMA)
	var quanti := {"prossimo": "%d DI %d · 1 PUNTO" % [livello - primo_del_giro(g) + 1, spicchi_del_giro(g)],
			"preso": "%d DI %d" % [livello - primo_del_giro(g) + 1, spicchi_del_giro(g)],
			"dopo": "SERVONO %d PUNTI · NE HAI %d" % [servono, punti()],
			"chiuso": "TETTO DELLA BETA" if beta else ("IL MASSIMO" if g == giri() - 1 else "%s COMPLETO" % tema(g)["nome"])}
	P.scritta(t, Vector2(x, 254), String(quanti[stato]), 15, P.ARANCIO if stato == "chiuso" else P.CARTA, Caratteri.tondo(900))
	if stato == "chiuso":
		pannello_chiuso(t, g)
		return
	P.scritta(t, Vector2(36, 390), "COSA TI HA DATO" if stato == "preso" else "COSA TI DÀ", 14, P.CARTA, Caratteri.tondo(900))
	var y := 404.0
	if livello == 1:
		P.scritta(t, Vector2(36, y + 26), "IL PUNTO DI PARTENZA", 22, P.CREMA)
		y += 60.0
	else:
		var due: Array = coppia(livello)
		if stato == "preso":
			var scelta_presa := scelta_di(livello)
			S.disegna(t, scelta_presa, Vector2(56, y + 20), 34.0, P.CREMA, P.NERO, P.ARANCIO)
			P.scritta(t, Vector2(90, y + 26), "PIÙ " + String(PAROLE[scelta_presa]), 22, P.CREMA)
			var lasciata := String(due[1]) if String(due[0]) == scelta_presa else String(due[0])
			P.scritta(t, Vector2(90, y + 46), "l'hai scelta tu, invece di %s" % nome_stat(lasciata).to_lower(),
					14, P.CARTA, Caratteri.tondo(700))
		else:
			S.disegna(t, "biforca", Vector2(56, y + 18), 34.0, P.CREMA, P.NERO)
			var detta := "PIÙ %s O PIÙ %s" % [PAROLE[due[0]], PAROLE[due[1]]]
			P.scritta(t, Vector2(90, y + 26), detta, P.corpo_che_entra(detta, 22, 390.0), P.CREMA)
			var come := "una delle due: la scegli quando lo prendi"
			if stato == "prossimo" and livello == LIVELLO + 1:
				come = "%+d %s o %+d %s: la scegli dopo" % [int(potenziamento(String(due[0])).get("quanto", 1)),
						nome_stat(String(due[0])).to_lower(), int(potenziamento(String(due[1])).get("quanto", 1)),
						nome_stat(String(due[1])).to_lower()]
			P.scritta(t, Vector2(90, y + 46), come, 14, P.CARTA, Caratteri.tondo(700))
		y += 70.0
	var qui := arrivi_di(livello)
	if not qui.is_empty():
		var primo: Array = qui[0]
		var tipo := String(primo[0])
		var id := String(primo[1])
		var dati := dati_di(tipo, id)
		if tipo == "passiva":
			S.passiva(t, id, Vector2(56, y + 30), 50.0, P.ARANCIO, P.NERO)
		else:
			P.rombo(t, Vector2(56, y + 30), 25.0, P.ARANCIO)
			S.disegna(t, simbolo_di(tipo, id), Vector2(56, y + 30), 28.0, P.NERO, P.ARANCIO)
		P.etichetta(t, Vector2(88, y), ("ARRIVA UNA PASSIVA" if tipo == "passiva" else "ARRIVA UN'ABILITÀ")
				if stato != "preso" else ("PASSIVA" if tipo == "passiva" else "ABILITÀ"), 12, P.ARANCIO, P.NERO)
		var nome := String(dati.get("nome", id)).to_upper()
		P.scritta(t, Vector2(90, y + 44), nome, P.corpo_che_entra(nome, 22, 380.0), P.CREMA)
		P.a_capo(t, Rect2(90, y + 52, 370, 56), String(dati.get("descrizione", "")), 13, P.CARTA, null,
				HORIZONTAL_ALIGNMENT_LEFT, 3)
		if qui.size() > 1:
			var altri := PackedStringArray()
			for voce: Array in qui.slice(1):
				altri.append(String(dati_di(String(voce[0]), String(voce[1])).get("nome", voce[1])))
			P.scritta(t, Vector2(90, y + 124), "E ANCHE: " + ", ".join(altri).to_upper(), 14, P.ARANCIO, Caratteri.tondo(900))
	match stato:
		"prossimo":
			P.etichetta(t, Vector2(30, 624), "PRENDI · 1 PUNTO", 26, P.ARANCIO, P.NERO, P.CREMA)
		"dopo":
			P.etichetta(t, Vector2(30, 628), "IN FILA: PRIMA IL LIVELLO %d" % (adesso + 1), 20, P.SPENTO, P.TRATTO)


func pannello_chiuso(t: CanvasItem, g: int) -> void:
	# il giro chiuso: nella beta e' il tetto; nel gioco intero si passa al prossimo
	P.scritta(t, Vector2(36, 390), "E ADESSO", 14, P.CARTA, Caratteri.tondo(900))
	if beta:
		Sagome.lucchetto(t, Vector2(56, 424), 34.0, P.CREMA)
		P.scritta(t, Vector2(90, 430), "IL SECONDO GIRO (21–40)", 22, P.CREMA)
		P.scritta(t, Vector2(90, 450), "arriva col gioco intero: nella beta il 20 è il tetto", 14, P.CARTA, Caratteri.tondo(700))
		P.gettone(t, Vector2(56, 504), 14.0, 1.0, P.CREMA, Color(P.CREMA, 0.14))
		P.scritta(t, Vector2(90, 500), "L'HYPE NON SI BUTTA", 22, P.CREMA)
		P.scritta(t, Vector2(90, 520), "i punti restano da parte: li spendi quando arriva", 14, P.CARTA, Caratteri.tondo(700))
		P.etichetta(t, Vector2(30, 628), "GIRO COMPLETO", 20, P.SPENTO, P.TRATTO)
		return
	if g == giri() - 1:
		# Oggi al 130 si torna indietro, ed e' l'unico momento (docs/albero.md 4.1 e 4.7)
		S.disegna(t, "biforca", Vector2(56, 424), 34.0, P.CREMA, P.NERO)
		P.scritta(t, Vector2(90, 430), "TORNI SUI BIVI", 22, P.CREMA)
		P.scritta(t, Vector2(90, 450), "le strade che hai lasciato, adesso, si possono prendere", 14, P.CARTA,
				Caratteri.tondo(700))
		P.rombo(t, Vector2(56, 494), 16.0, P.ARANCIO, P.CREMA, 2.0)
		P.scritta(t, Vector2(90, 500), "NON C'È UN GIRO DOPO", 22, P.CREMA)
		P.scritta(t, Vector2(90, 520), "%d livelli, %d giri: la ruota è tutta tua" % [massimo(), giri()], 14, P.CARTA,
				Caratteri.tondo(700))
		P.etichetta(t, Vector2(30, 624), "AI BIVI", 26, P.ARANCIO, P.NERO, P.CREMA)
		return
	var dopo_questo := tema(g + 1)
	P.rombo(t, Vector2(56, 424), 16.0, P.ARANCIO, P.CREMA, 2.0)
	P.scritta(t, Vector2(90, 430), "SI RICOMINCIA DAL %d" % primo_del_giro(g + 1), 22, P.CREMA)
	P.scritta(t, Vector2(90, 450), "%s, con un altro aspetto" % String(dopo_questo["nome"]).to_lower(), 14, P.CARTA,
			Caratteri.tondo(700))
	P.etichetta(t, Vector2(30, 624), "AL %s" % dopo_questo["nome"], 26, P.ARANCIO, P.NERO, P.CREMA)


func sipario(t: CanvasItem, p: float, g: int) -> void:
	# la lastra del passaggio: entra da destra col nome del giro nuovo, il rombo
	# del giro si accende, e se ne va
	if p > 1.4 or p < 0.0:
		return
	var dx := 900.0 * (1.0 - frena(clampf((p - 0.06) / 0.32, 0.0, 1.0))) + 900.0 * frena(clampf((p - 0.95) / 0.4, 0.0, 1.0))
	P.gira(t, Vector2(dx, 0), 0.0)
	P.lastra(t, PackedVector2Array(SIPARIO))
	P.dritto(t)
	var scritta := clampf((p - 0.34) / 0.2, 0.0, 1.0)
	if scritta <= 0.0:
		return
	var tm := tema(g)
	var nome := String(tm["nome"])
	var scossa := Vector2(sin(p * 90.0), cos(p * 77.0)) * 8.0 * (1.0 - clampf((p - 0.54) / 0.2, 0.0, 1.0)) if scritta >= 1.0 \
			else Vector2.ZERO
	P.gira(t, Vector2(930 + dx, 350) + scossa, -6.0, lerpf(1.8, 1.0, frena(scritta)))
	# il numero romano del giro, lo stesso che poi sta nel mozzo
	P.scritta(t, Vector2(-330, -84), ROMANI[g], 120, Color(P.ARANCIO, 0.9), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER, 660)
	P.ritagliata(t, Vector2(-330, 0), nome, P.corpo_che_entra(nome, 92, 640.0), P.CREMA, P.NERO, 0, P.ARANCIO, Vector2(9, 9),
			null, HORIZONTAL_ALIGNMENT_CENTER, 660)
	P.scritta(t, Vector2(-330, 54), "LIVELLI %d–%d" % [primo_del_giro(g), ultimo_del_giro(g)], 30, P.ARANCIO, null,
			HORIZONTAL_ALIGNMENT_CENTER, 660)
	var accende := rimbalza(clampf((p - 0.6) / 0.25, 0.0, 1.0))
	for i in giri():
		var q := Vector2((i - (giri() - 1) * 0.5) * 34.0, 104)
		if i < g:
			P.rombo(t, q, 10.0, P.CREMA)
		elif i == g:
			P.rombo(t, q, 13.0 * accende, P.ARANCIO, P.CREMA, 2.0)
		else:
			P.rombo(t, q, 9.0, Color(0, 0, 0, 0), Color(P.CREMA, 0.3), 2.0)
	P.dritto(t)


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
	# i simboli grandi sul fondo: colori pieni gia' mescolati, non trasparenze
	# (i pezzi di un simbolo si sovrappongono, e la trasparenza li farebbe a chiazze)
	IS.disegna(t, String(due[1]), Vector2(1010, 450), 640.0, P.CREMA.lerp(P.NERO, 0.06), P.CREMA)
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, -20), Vector2(taglio, -20), Vector2(basso, 740), Vector2(-20, 740)]),
			P.NERO)
	IS.disegna(t, String(due[0]), Vector2(taglio - 410, 470), 600.0, P.NERO.lerp(P.CREMA, 0.07), P.NERO)
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
	var arriva: Array = arrivi_di(LIVELLO + 1)[0]
	var dati := abilita(String(arriva[1]))
	var entra := frena(entrata(0.35, 0.4))
	P.gira(t, Vector2(-20 - 1400.0 * (1.0 - entra), 604), -1.5)
	t.draw_rect(Rect2(8, 8, 1340, 50), P.NERO)
	t.draw_rect(Rect2(0, 0, 1340, 50), P.ARANCIO)
	t.draw_rect(Rect2(0, 0, 1340, 50), P.NERO, false, 3.0)
	var x := 74.0 + P.scritta_larga(t, Vector2(74, 34), "E IN OGNI CASO, AL LIVELLO %d, ARRIVA" % (LIVELLO + 1), 20, P.NERO)
	P.rombo(t, Vector2(x + 30, 25), 20.0, P.NERO)
	S.disegna(t, simbolo_di("abilita", String(arriva[1])), Vector2(x + 30, 25), 26.0, P.ARANCIO, P.NERO)
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
				var velato := P.NERO.lerp(P.ARANCIO, 0.18 + 0.12 * batte)
				P.rombo(t, c, r * 0.74, velato)
				S.disegna(t, glifo, c, r * 0.8, velato.lerp(P.CREMA, 0.4 + 0.2 * batte), velato)
		"chiusa":
			P.rombo(t, c + Vector2(5, 5), r, Color(P.NERO, 0.5))
			P.rombo(t, c, r, P.BRUNO, P.NERO, 4.0)
			S.disegna(t, glifo, c, r * 0.8, P.BRUNO.lerp(P.CARTA, 0.22), P.BRUNO)
			Sagome.lucchetto(t, c + Vector2(r * 0.42, r * 0.42), r * 0.5, P.CREMA)
		_:
			P.rombo(t, c + Vector2(6, 6), r, P.NERO)
			P.rombo(t, c, r, P.ARANCIO if stato == "scelta" else P.ARANCIO_SCURO, P.NERO, 5.0)
			P.rombo(t, c, r * 0.74, P.CREMA, P.NERO, 3.0)
			S.disegna(t, glifo, c, r * 0.8, P.NERO, P.CREMA)


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
	var posti := [["non_ce_tempo", "in uso"], ["immondizia_tesoro", "in uso"], ["", "vuoto"]]
	if portata:
		posti[2] = ["battito_dell_eroe", "scelta"]
	elif String(guardata[1]) == "libera":
		posti[2] = [String(guardata[0]), "vuoto"]
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
		var glifo := String(voce[0])
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
	alloggio(t, Vector2(58, 76), 40.0, id, "chiusa" if stato == "chiusa" else "scelta")
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


# --- la tavola dei simboli ------------------------------------------------------------------
#
# Tutta la famiglia di SimboliCrescita su una pagina, ognuno grande e piccolo
# (come sta in una tasca della roulette), per giudicarli insieme.

const SIMBOLI_STAT := ["biforca", "hp", "attacco", "difesa", "velocita", "intelligenza", "fattore"]
const SIMBOLI_ABILITA := ["astio", "vendetta", "pieta", "flagello", "annichilazione", "mantra"]


func disegna_simboli(t: CanvasItem) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.06), Vector2(1.0, 1.0))
	P.etichetta(t, Vector2(28, 52), "I SIMBOLI", 40, P.CREMA, P.NERO, P.ARANCIO)
	P.scritta(t, Vector2(300, 82), "Le statistiche: due figure in una icona (la tavola delle statistiche). Abilità e",
			15, P.CARTA, Caratteri.tondo(700))
	P.scritta(t, Vector2(300, 102), "passive sono ancora timbri del manifesto, pendenti: le abilità senza cornice, le passive nel rombo.", 15,
			P.CARTA, Caratteri.tondo(700))
	riga_di_simboli(t, "STATISTICHE", 186.0, SIMBOLI_STAT, false)
	riga_di_simboli(t, "ABILITÀ", 340.0, SIMBOLI_ABILITA, false)
	var passive: Array[String] = []
	for voce: Dictionary in GameState.crescita.get("passive_livello", []):
		passive.append(String(voce.get("id", "")))
	passive.append_array(["furia", "perspicacia_acuta"])
	riga_di_simboli(t, "PASSIVE", 494.0, passive.slice(0, 9), true)
	riga_di_simboli(t, "", 626.0, passive.slice(9), true)
	testata(t, "", true, true)


func riga_di_simboli(t: CanvasItem, titolo: String, y: float, nomi: Array, passive: bool) -> void:
	if titolo != "":
		P.etichetta(t, Vector2(28, y - 76), titolo, 15, P.ARANCIO, P.NERO)
	var passo := 132.0 if passive else 158.0
	for i in nomi.size():
		var id := String(nomi[i])
		var x := 96.0 + passo * i
		var nome := String(dati_passiva(id).get("nome", id)) if passive else String(S.NOMI.get(id, id))
		if passive:
			S.passiva_timbro(t, id, Vector2(x, y), 64.0, P.CREMA, P.NERO, P.ARANCIO)
			S.passiva(t, id, Vector2(x + 50, y + 22), 22.0, P.ARANCIO, P.NERO)
		elif id in IS.CHIAVI:
			IS.timbro(t, id, Vector2(x, y), 64.0, P.CREMA, P.NERO, P.ARANCIO)
			IS.timbro(t, id, Vector2(x + 52, y + 22), 24.0, P.ARANCIO, P.NERO)
		else:
			S.timbro(t, id, Vector2(x, y), 64.0, P.CREMA, P.NERO, P.ARANCIO)
			S.disegna(t, id, Vector2(x + 52, y + 22), 22.0, P.ARANCIO, P.NERO)
		P.a_capo(t, Rect2(x - 62, y + 38, 124, 30), nome.to_upper(), 11, P.CARTA, Caratteri.tondo(900),
				HORIZONTAL_ALIGNMENT_CENTER, 2)


func tasti_simboli() -> void:
	pass


# --- la tavola delle statistiche ------------------------------------------------------------
#
# Le icone delle statistiche: la tavola sta in TavolaIcone, le icone e le loro
# idee in IconeStatistiche.

func disegna_statistiche(t: CanvasItem) -> void:
	TI.disegna(t)
	testata(t, "", true, true)


func tasti_statistiche() -> void:
	pass


func disegna_misure(t: CanvasItem) -> void:
	TM.disegna(t)
	testata(t, "", true, true)


func tasti_misure() -> void:
	pass


func disegna_costruzione(t: CanvasItem) -> void:
	TC.disegna(t)
	testata(t, "", true, true)


func tasti_costruzione() -> void:
	pass
