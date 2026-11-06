extends Control
# I GIOCHI DEI PIANETI: QUATTRO TAVOLE FERME. Provvisorio come le altre
# vetrine: se ne va quando Bru ha scelto (docs/pianeti_giochi.md).
#
# Bru: «in alcuni pianeti potrai fare dei minigiochi come quelli che vedi nelle
# ads del telefono [...] in determinati pianeti potrai spendere soldi e risorse
# per fare upgrade a delle basi tipo tower defense [...] l'organizzazione ti
# permettera' di organizzare insediamenti e resistenze su alcuni pianeti, poi
# avremo anche giochi di raccolta [...] come garden scapes, ma solo la parte in
# cui accumula risorse e apre cancelli per avanzare e automatizza le raccolte».
#
#   1_raccolta     un pianeta da scavare, sul tavolo della Sala operativa
#   2_resistenza   un avamposto sotto assedio
#   3_pubblicita   il pianeta che promette: i cinque giochi, la mano, l'omino
#   3a..3e         ognuno dei cinque in grande, coi tre passi della soluzione
#   4_il_giro      come si parlano le tre, attraverso le riserve
#
# Il secondo giro. Bru: «i giochi devono essere fatti meglio di come sono ora e
# dobbiamo renderli leggermente diversi». Ogni gioco ha adesso una decisione
# vera e un'idea nostra (docs/pianeti_giochi.md, §8): la raccolta il polso e i
# cancelli che si chiedono a vicenda, la resistenza i soldati che si stressano e
# gli elementi, le pubblicita' i telefoni di TelefonoPubblicita.gd.
#
# Disegnate nella lingua del Vuoto (i quattro inchiostri di stile.json
# "proiezione", le schede a destra, le etichette): si comandano dalla Sala
# operativa, come si guarda la mappa. Solo il gioco delle pubblicita' esce dal
# tavolo e va sul data pad, in verticale, coi colori sguaiati di una pubblicita'.
# Tutti i nomi e i numeri sono miei, d'esempio.
#
#   ./prove/proposte_pianeti.sh   le fotografa in scatti/proposte_pianeti/
#   nell'editor, F6: destra e sinistra cambiano tavola

const TAVOLE := ["1_raccolta", "2_resistenza", "3_pubblicita", "3a_perni", "3b_torre", "3c_corteo", "3d_tratto",
		"3e_prova", "4_il_giro"]
const Telefono := preload("res://prove/TelefonoPubblicita.gd")
const GIOCHI := ["perni", "torre", "corteo", "tratto", "prova"]
# quello che dicono le schede di ogni gioco, nella sua tavola grande
const SCHEDE := {
	"perni": {"nome": "I PERNI", "di_solito": "«TIRA IL PERNO»",
		"solito": "Un ordine giusto solo, e lo vedi al primo sguardo. Lava e acqua sono cose che cadono, e basta.",
		"nostro": "Le sostanze si mescolano: l'acqua sulla lava fa pietra, il gelo sull'acqua fa ghiaccio, la lava sul ghiaccio fa vapore. Spesso le strade giuste sono due, e una vale più tazo.",
		"mano": "Se esiti, tira lei: il perno sbagliato. L'anello rosso dice quanto manca. Più vai avanti, meno aspetta.",
		"passi": ["Il perno della lava: cade sul mostro.", "Il perno dell'acqua: sulla lava diventa pietra.",
			"Il perno di mezzo: l'omino passa sul ponte di pietra e raccoglie i tazo."]},
	"torre": {"nome": "LA TORRE CHE CRESCE", "di_solito": "LA TORRE DEI NUMERI",
		"solito": "Mangi sempre il più piccolo, e vinci. Non c'è niente da decidere.",
		"nostro": "I mostri crescono di uno a ogni tua mossa, le pozioni moltiplicano, le trappole dimezzano, e alcune stanze sono al buio: con un'occhiata le guardi. Conta l'ordine: la pozione presa subito fa perdere.",
		"mano": "Se esiti, la mano ti porta verso il numero più grosso, quello che non puoi ancora battere.",
		"passi": ["Il 4: sali a 13. Gli altri crescono di uno.", "Un'occhiata al buio: è un 8. Lo mangi: 21.",
			"La pozione per ultima: 42 contro 33. In cima."]},
	"corteo": {"nome": "IL CORTEO", "di_solito": "LE PORTE CHE MOLTIPLICANO",
		"solito": "Scegli la porta col numero più grande, ogni volta. Basta saper contare.",
		"nostro": "Il corteo è di tre elementi: il fuoco batte la natura, la natura l'acqua, l'acqua il fuoco. Guardi chi ti aspetta in fondo, e scegli le porte per diventare quello che lo batte. Chi batte vale doppio.",
		"mano": "Se esiti, ti spinge verso la porta col numero più grosso: +10 fuoco, contro un muro d'acqua.",
		"passi": ["×2 natura: i verdi da 5 a 10.", "L'acqua diventa natura: 18 verdi.",
			"La natura batte l'acqua e vale doppio: 36 contro 30."]},
	"tratto": {"nome": "IL TRATTO", "di_solito": "DISEGNA LA LINEA",
		"solito": "Un muro a caso, e speri che regga: decide la fisica, non tu.",
		"nostro": "Prima vedi da dove arriveranno, per tre secondi. L'inchiostro è poco, e quello che avanza diventa tazo. Il tratto si crepa a ogni colpo: troppo sottile si rompe, troppo lungo costa.",
		"mano": "Se esiti, disegna lei: uno scarabocchio che non para niente.",
		"passi": ["Tre secondi per vedere da dove vengono.", "Un arco solo, dal lato giusto.",
			"Crepato, ma regge. Avanza metà dell'inchiostro: tazo."]},
	"prova": {"nome": "LA PROVA", "di_solito": "SCEGLI QUELLO GIUSTO",
		"solito": "Tre oggetti, uno giusto, e lo trovi tirando a indovinare.",
		"nostro": "C'è sempre una ragione, e chi guarda bene la scena la trova: qui il mostro ha la chiave al collo. Uno studio per livello ti dice com'è fatto un oggetto, come lo Studio negli scontri.",
		"mano": "Indica sempre quello sbagliato. Fidarsi della pubblicità è il modo più veloce per perdere.",
		"passi": ["Lo studio sulla chiave: è arrugginita, si spezza.", "L'osso al mostro. La chiave vera è al suo collo.",
			"La chiave vera apre la porta."]},
}
const CARTELLA := "res://scatti/proposte_pianeti"
const X := SchedaProiezione.X
const LARGO := SchedaProiezione.LARGO
const RISERVE := "MINERALI 128     TAZO 2.430     ORG 4"

var indice := 0
var tinte := {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tinte = CieloProiezione.tinte()
	if not "foto" in OS.get_cmdline_user_args():
		return
	DirAccess.make_dir_recursive_absolute(CARTELLA)
	for i in TAVOLE.size():
		mostra(i)
		for k in 6:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(CARTELLA.path_join("%s.png" % TAVOLE[i]))
		print("TAVOLA %s" % TAVOLE[i])
	get_tree().quit()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_right"):
		mostra((indice + 1) % TAVOLE.size())
	elif evento.is_action_pressed("ui_left"):
		mostra((indice + TAVOLE.size() - 1) % TAVOLE.size())


func mostra(i: int) -> void:
	# i telefoni sono figli: si tolgono quelli della tavola di prima
	indice = i
	for figlio in get_children():
		remove_child(figlio)
		figlio.free()
	var nome := String(TAVOLE[indice])
	if nome == "3_pubblicita":
		for k in GIOCHI.size():
			telefono(String(GIOCHI[k]), 0, Vector2(187.0 + 186.0 * float(k), 76), 0.45)
	elif nome.begins_with("3"):
		var gioco := nome.substr(3)
		telefono(gioco, 0, Vector2(459, 74), 0.95)
		for f in 3:
			telefono(gioco, f + 1, Vector2(842, 80.0 + 206.0 * float(f)), 0.28)
	queue_redraw()


func telefono(gioco: String, fase: int, dove: Vector2, quanto: float) -> void:
	var t: Control = Telefono.new()
	t.set("gioco", gioco)
	t.set("fase", fase)
	t.position = dove
	t.scale = Vector2(quanto, quanto)
	add_child(t)


func _draw() -> void:
	match String(TAVOLE[indice]):
		"1_raccolta":
			raccolta()
		"2_resistenza":
			resistenza()
		"3_pubblicita":
			pubblicita()
		"4_il_giro":
			giro()
		_:
			dettaglio(String(TAVOLE[indice]).substr(3), String(TAVOLE[indice]).unicode_at(1) - 96)


# ---------------------------------------------------------------- 1 LA RACCOLTA

func raccolta() -> void:
	tavolo("CARNIVALZ  ·  SALA OPERATIVA  ·  PIANETA D'ESEMPIO  ·  LA RACCOLTA", RISERVE)
	# i sentieri prima dei campi: i campi ci stanno sopra
	sentiero(Vector2(380, 420), Vector2(500, 372), true)
	sentiero(Vector2(690, 360), Vector2(770, 432), false)
	sentiero(Vector2(520, 262), Vector2(470, 222), false)
	sentiero(Vector2(525, 168), Vector2(665, 152), false)
	campo(Vector2(290, 470), Vector2(190, 82), 0.7, true)
	campo(Vector2(600, 322), Vector2(170, 74), 2.1, true)
	campo(Vector2(820, 478), Vector2(120, 58), 3.3, false)
	campo(Vector2(380, 172), Vector2(140, 56), 4.6, false)
	campo(Vector2(760, 150), Vector2(96, 42), 5.2, false, 0.45)
	modulo(Vector2(215, 462))
	vena(Vector2(320, 492), 1.0)
	vena(Vector2(400, 458), 0.55)
	vena(Vector2(545, 318), 1.0)
	vena(Vector2(500, 340), 0.3)
	vena(Vector2(655, 330), 0.8)
	trivella(Vector2(668, 318), 18, 30)
	nastro(Vector2(660, 342), Vector2(232, 470))
	polso(Vector2(545, 318))
	scrivi(Vector2(444, 294), "+9 AL POLSO", 13, tinte["segnale"], 560, 85, 2)
	cancello(Vector2(730, 396), true, "40 MINERALI  ·  300 TAZO")
	cancello(Vector2(495, 242), false, "100 MINERALI, O 30 + 2 FERRO")
	cancello(Vector2(595, 160), false, "?")
	cartellino(Vector2(150, 434), Vector2(-50, -46), "IL CAMPO D'ATTERRAGGIO", "APERTO  ·  2 VENE")
	cartellino(Vector2(720, 268), Vector2(18, -44), "LA PIANA DI QUARZO", "APERTO  ·  3 VENE  ·  1 MACCHINA")
	cartellino(Vector2(780, 528), Vector2(-60, 56), "LE FORRE DI FERRO", "CHIUSO  ·  DIETRO UN CANCELLO", false)
	cartellino(Vector2(290, 136), Vector2(-60, -30), "IL CRATERE", "CHIUSO  ·  COL FERRO COSTA MENO", false)
	cartellino(Vector2(800, 126), Vector2(10, -26), "?", "NON ANCORA RILEVATO", false)
	cartellino(Vector2(205, 440), Vector2(-40, 90), "IL MODULO", "DA QUI ALLE RISERVE")
	nome_scheda(Rect2(X, 76, LARGO, 64), "01 / CAMPO", "LA PIANA DI QUARZO", "APERTO  ·  3 VENE  ·  1 MACCHINA")
	var vene := Rect2(X, 148, LARGO, 96)
	SchedaProiezione.scatola(self, vene, "02 / VENE", tinte)
	riga_con_barra(vene.position + Vector2(10, 34), "QUARZO", "PRONTA  ·  BATTE", 1.0)
	riga_con_barra(vene.position + Vector2(10, 58), "QUARZO", "TRA 3 MIN DI GIOCO", 0.3)
	riga_con_barra(vene.position + Vector2(10, 82), "QUARZO  ·  TRIVELLA", "18 / 30", 0.6)
	var macchine := Rect2(X, 252, LARGO, 102)
	SchedaProiezione.scatola(self, macchine, "03 / MACCHINE", tinte)
	racconto(Rect2(macchine.position + Vector2(14, 28), Vector2(LARGO - 26, 70)),
			"La trivella raccoglie da sola, anche mentre sei altrove: è la sonda che diventa più brava. Al livello 3 (60 minerali) ne tiene 50.")
	var porta := Rect2(X, 362, LARGO, 132)
	SchedaProiezione.scatola(self, porta, "04 / CANCELLO", tinte)
	scrivi(porta.position + Vector2(10, 38), "LE FORRE DI FERRO", 15, tinte["carta"], 300, 75, 3)
	SchedaProiezione.riga(self, porta.position + Vector2(10, 58), "COSTO", "40 MINERALI  ·  300 TAZO", tinte)
	racconto(Rect2(porta.position + Vector2(14, 70), Vector2(LARGO - 26, 60)),
			"Dietro: il ferro. Il Cratere costa 100 minerali, o 30 col ferro: prima le Forre costa meno, ma ci vuole più tempo.")
	bottone(Rect2(X, 502, LARGO, 40), "APRI IL CANCELLO")
	suggerimenti(["CLIC SULLA VENA QUANDO BATTE  ·  DI PIÙ", "CLIC SU UNA VENA  ·  COSTRUISCI",
			"CLIC SU UN CANCELLO  ·  APRI", "ESC  ·  TORNA AL VUOTO"])
	titolo("PIANETA D'ESEMPIO  ·  2 CAMPI APERTI SU 5", "LA RACCOLTA")


func zolla(centro: Vector2, raggi: Vector2, seme: float) -> PackedVector2Array:
	# il contorno storto di un campo, come le radure del plastico: sempre lo stesso
	var punti := PackedVector2Array()
	for i in 48:
		var a := TAU * float(i) / 48.0
		var r := 1.0 + 0.07 * sin(3.0 * a + seme) + 0.05 * sin(5.0 * a + seme * 2.3)
		punti.append(centro + Vector2(cos(a) * raggi.x, sin(a) * raggi.y) * r)
	return punti


func campo(centro: Vector2, raggi: Vector2, seme: float, aperto: bool, luce := 1.0) -> void:
	var sopra := zolla(centro, raggi, seme)
	var sotto := sposta(sopra, Vector2(0, 16))
	if aperto:
		draw_colored_polygon(sotto, Color(tinte["inchiostro"], 0.32))
		draw_polyline(chiuso(sotto), Color(tinte["inchiostro"], 0.8), 1.0, true)
		draw_colored_polygon(sopra, Color(tinte["fondo"]).lerp(tinte["inchiostro"], 0.2))
		draw_polyline(chiuso(sopra), Color(tinte["carta"], 0.9), 1.5, true)
		return
	# chiuso: solo il tratteggio del contorno, e il punto di domanda
	var tinta := Color(tinte["inchiostro"], 0.8 * luce)
	for i in sopra.size():
		if i % 2 == 0:
			draw_line(sopra[i], sopra[(i + 1) % sopra.size()], tinta, 1.0, true)
	for i in sotto.size():
		if i % 4 == 0 and sotto[i].y > centro.y + 10.0:
			draw_line(sotto[i], sotto[(i + 1) % sotto.size()], Color(tinta, 0.5 * luce), 1.0, true)
	scrivi(centro + Vector2(-6, 8), "?", 22, Color(tinte["inchiostro"], luce), 500, 80, 0)


func sentiero(da: Vector2, a: Vector2, aperto: bool) -> void:
	if aperto:
		draw_line(da, a, Color(tinte["inchiostro"], 0.45), 12.0, true)
		trattini(da, a, Color(tinte["carta"], 0.55), 8.0)
	else:
		trattini(da, a, Color(tinte["inchiostro"], 0.8), 6.0)


func cancello(punto: Vector2, apribile: bool, costo: String) -> void:
	var tinta: Color = tinte["segnale"] if apribile else tinte["inchiostro"]
	if apribile:
		draw_circle(punto, 24.0, Color(tinte["segnale"], 0.16))
		draw_arc(punto, 24.0, 0.0, TAU, 40, Color(tinte["segnale"], 0.6), 1.0, true)
	draw_rect(Rect2(punto + Vector2(-13, -13), Vector2(5, 24)), tinta)
	draw_rect(Rect2(punto + Vector2(8, -13), Vector2(5, 24)), tinta)
	draw_line(punto + Vector2(-8, -6), punto + Vector2(8, -6), tinta, 2.0)
	draw_line(punto + Vector2(-8, 2), punto + Vector2(8, 2), tinta, 2.0)
	# il lucchetto
	draw_rect(Rect2(punto + Vector2(-4, -3), Vector2(8, 7)), tinte["fondo"])
	draw_rect(Rect2(punto + Vector2(-4, -3), Vector2(8, 7)), tinta, false, 1.0)
	draw_arc(punto + Vector2(0, -3), 3.0, PI, TAU, 8, tinta, 1.0)
	if costo != "?":
		var w := DisegnoProiezione.larghezza(costo, 10, 450, 85, 2)
		draw_rect(Rect2(punto + Vector2(-w * 0.5 - 4, 18), Vector2(w + 8, 16)), Color(tinte["fondo"], 0.85))
		scrivi(punto + Vector2(-w * 0.5, 30), costo, 10, tinta, 450, 85, 2)


func polso(punto: Vector2) -> void:
	# IL POLSO: una vena pronta batte. Cliccata sul battito da' la meta' in piu':
	# la raccolta non e' piu' solo cliccare, e' cliccare bene
	for k in 2:
		draw_arc(punto, 30.0 + 9.0 * float(k), 0.0, TAU, 48, Color(tinte["segnale"], 0.55 - 0.25 * float(k)), 2.0, true)


func vena(punto: Vector2, quota: float) -> void:
	# tre cristalli e il giro che si riempie: pieno vuol dire pronta
	var pronta := quota >= 1.0
	var tinta: Color = tinte["carta"]
	for k in 3:
		var p := punto + Vector2(-7 + 7 * k, -2 + 3 * (k % 2))
		var alto := 9.0 + 4.0 * float(k % 2)
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -alto), p + Vector2(4, 0), p + Vector2(0, 4),
				p + Vector2(-4, 0)]), tinta)
	var anello: Color = tinte["segnale"] if pronta else Color(tinte["inchiostro"], 0.95)
	draw_arc(punto, 17.0, 0.0, TAU, 40, Color(tinte["inchiostro"], 0.3), 2.0, true)
	draw_arc(punto, 17.0, -PI * 0.5, -PI * 0.5 + TAU * quota, 40, anello, 3.0, true)
	if pronta:
		draw_arc(punto, 23.0, 0.0, TAU, 40, Color(tinte["segnale"], 0.35), 1.0, true)


func trivella(punto: Vector2, dentro: int, tiene: int) -> void:
	var tinta: Color = tinte["carta"]
	var cima := punto + Vector2(10, -30)
	draw_line(cima, punto + Vector2(-2, 6), tinta, 2.0, true)
	draw_line(cima, punto + Vector2(22, 6), tinta, 2.0, true)
	draw_line(cima, cima + Vector2(0, 30), tinte["segnale"], 2.0)
	draw_rect(Rect2(punto + Vector2(18, -10), Vector2(14, 12)), tinte["fondo"])
	draw_rect(Rect2(punto + Vector2(18, -10), Vector2(14, 12)), tinta, false, 1.0)
	var barra := Rect2(punto + Vector2(-2, 12), Vector2(36, 4))
	draw_rect(barra, Color(tinte["inchiostro"], 0.5))
	draw_rect(Rect2(barra.position, Vector2(barra.size.x * float(dentro) / float(tiene), 4)), tinte["segnale"])
	scrivi(punto + Vector2(38, 18), "%d/%d" % [dentro, tiene], 10, tinte["carta"], 450, 85, 2)


func nastro(da: Vector2, a: Vector2) -> void:
	# il nastro porta al modulo quello che la trivella tira su
	trattini(da, a, Color(tinte["segnale"], 0.6), 7.0)
	var verso := (a - da).normalized()
	var di_lato := verso.orthogonal()
	for k in range(1, 6):
		var p := da.lerp(a, float(k) / 6.0)
		draw_polyline(PackedVector2Array([p - verso * 4.0 + di_lato * 4.0, p, p - verso * 4.0 - di_lato * 4.0]),
				Color(tinte["segnale"], 0.8), 1.5, true)


func modulo(punto: Vector2) -> void:
	var tinta: Color = tinte["carta"]
	draw_rect(Rect2(punto + Vector2(-20, -6), Vector2(40, 16)), tinte["fondo"])
	draw_rect(Rect2(punto + Vector2(-20, -6), Vector2(40, 16)), tinta, false, 1.5)
	draw_arc(punto + Vector2(0, -6), 14.0, PI, TAU, 24, tinta, 1.5, true)
	draw_line(punto + Vector2(0, -20), punto + Vector2(4, -32), tinta, 1.0, true)
	draw_circle(punto + Vector2(4, -32), 2.0, tinte["segnale"])


# ------------------------------------------------------------- 2 LA RESISTENZA

func resistenza() -> void:
	tavolo("CARNIVALZ  ·  SALA OPERATIVA  ·  AVAMPOSTO D'ESEMPIO  ·  LA RESISTENZA", "ONDATA 3/8     " + RISERVE)
	var strada := percorso([Vector2(140, 300), Vector2(300, 222), Vector2(450, 270), Vector2(440, 392),
			Vector2(330, 462), Vector2(420, 556), Vector2(600, 560), Vector2(690, 452), Vector2(812, 414)])
	draw_polyline(strada, Color(tinte["inchiostro"], 0.3), 30.0, true)
	draw_polyline(strada, Color(tinte["fondo"]).lerp(tinte["inchiostro"], 0.18), 24.0, true)
	for i in range(0, strada.size() - 1, 2):
		draw_line(strada[i], strada[i + 1], Color(tinte["carta"], 0.35), 1.0, true)
	frattura(Vector2(118, 300))
	insediamento(Vector2(872, 404))
	var nemici := [0.08, 0.12, 0.16, 0.2, 0.235, 0.27, 0.33]
	for k in nemici.size():
		var p := lungo_il_percorso(strada, nemici[k])
		nemico(p, 5.0 if k != 3 else 9.0, 1.0 - 0.12 * float(k % 3))
	# chi spara: la postazione scelta col suo raggio, il mortaio col suo arco
	var postazione := Vector2(330, 300)
	draw_arc(postazione, 112.0, 0.0, TAU, 64, Color(tinte["segnale"], 0.55), 1.0, true)
	draw_circle(postazione, 112.0, Color(tinte["segnale"], 0.05))
	draw_line(postazione + Vector2(0, -8), lungo_il_percorso(strada, 0.2), Color(tinte["segnale"], 0.9), 1.5, true)
	var mortaio := Vector2(522, 478)
	var bersaglio := lungo_il_percorso(strada, 0.33)
	arco_tratteggiato(mortaio, bersaglio, 70.0)
	draw_arc(bersaglio, 20.0, 0.0, TAU, 32, Color(tinte["segnale"], 0.7), 2.0, true)
	torre(postazione, "postazione")
	torre(mortaio, "mortaio")
	torre(Vector2(724, 520), "rete")
	# LO STRESS DEI SOLDATI: l'abominio passa vicino alla postazione, e chi ci sta
	# dentro non ha il fattore Carnivalz. Trema, e spara piu' piano
	stress_torre(postazione, 0.7)
	stress_torre(mortaio, 0.2)
	stress_torre(Vector2(724, 520), 0.1)
	for posto: Vector2 in [Vector2(232, 196), Vector2(540, 330), Vector2(780, 506)]:
		posto_libero(posto)
	cartellino(Vector2(100, 268), Vector2(10, -70), "LA FRATTURA", "DA QUI ESCONO")
	cartellino(Vector2(345, 288), Vector2(40, -170), "POSTAZIONE  ·  LIV. 2", "STRESS 70: SPARA PIÙ PIANO")
	cartellino(Vector2(512, 492), Vector2(-150, 60), "MORTAIO  ·  FUOCO", "L'ABOMINIO NON LO SENTE")
	cartellino(Vector2(736, 528), Vector2(14, 44), "RETE  ·  GELO", "RALLENTA")
	cartellino(Vector2(552, 318), Vector2(30, -60), "POSTO LIBERO", "20 MINERALI")
	cartellino(Vector2(900, 360), Vector2(-24, -150), "IL DOMINATORE DI TURNO", "YHVINA  ·  CALMA I SOLDATI", true, true)
	velocita(Vector2(822, 572))
	nome_scheda(Rect2(X, 76, LARGO, 64), "01 / AVAMPOSTO", "AVAMPOSTO D'ESEMPIO", "2 ASSEDI RESPINTI  ·  0 PERSI")
	var assedio := Rect2(X, 148, LARGO, 112)
	SchedaProiezione.scatola(self, assedio, "02 / L'ASSEDIO", tinte)
	SchedaProiezione.riga(self, assedio.position + Vector2(10, 34), "ONDATA", "3 DI 8", tinte)
	SchedaProiezione.riga(self, assedio.position + Vector2(10, 52), "IN ARRIVO", "9 GHOUL  ·  1 ABOMINIO", tinte)
	SchedaProiezione.riga(self, assedio.position + Vector2(10, 70), "STUDIATO", "ABOMINIO: IMMUNE AL FUOCO", tinte)
	riga_con_barra(assedio.position + Vector2(10, 96), "MURA", "14 / 20", 0.7)
	var torre_scelta := Rect2(X, 268, LARGO, 102)
	SchedaProiezione.scatola(self, torre_scelta, "03 / POSTAZIONE  ·  LIV. 2", tinte)
	SchedaProiezione.riga(self, torre_scelta.position + Vector2(10, 36), "COLPO", "UNO ALLA VOLTA  ·  LONTANO", tinte)
	SchedaProiezione.riga(self, torre_scelta.position + Vector2(10, 54), "STRESS", "70  ·  SPARA PIÙ PIANO", tinte)
	SchedaProiezione.riga(self, torre_scelta.position + Vector2(10, 72), "AL LIV. 3", "40 MINERALI  ·  250 TAZO", tinte)
	SchedaProiezione.riga(self, torre_scelta.position + Vector2(10, 90), "SMONTALA", "+20 MINERALI", tinte)
	var data_pad := Rect2(X, 378, LARGO, 116)
	SchedaProiezione.scatola(self, data_pad, "04 / DAL DATA PAD", tinte)
	racconto(Rect2(data_pad.position + Vector2(14, 30), Vector2(LARGO - 26, 84)),
			"«A seguito dei risultati ottenuti, le è affidato il comando di un avamposto. Le forze sono nostre. Il dominatore di turno è suo.»")
	bottone(Rect2(X, 502, LARGO, 40), "MIGLIORA LA POSTAZIONE")
	suggerimenti(["CLIC SU UN POSTO LIBERO  ·  COSTRUISCI", "CLIC SU UNA POSTAZIONE  ·  MIGLIORA",
			"CLIC SUL DOMINATORE  ·  LA SUA MOSSA", "SPAZIO  ·  PAUSA     TAB  ·  PIÙ VELOCE"])
	titolo("PIANETA D'ESEMPIO  ·  L'INFEZIONE PREME", "LA RESISTENZA")


func stress_torre(p: Vector2, quota: float) -> void:
	var rosso := Stile.colore("pericolo")
	draw_arc(p, 21.0, -PI * 0.5, -PI * 0.5 + TAU * quota, 32, rosso, 3.0, true)
	if quota < 0.5:
		return
	for lato: float in [-1.0, 1.0]:
		for k in 2:
			var x := p.x + lato * (27.0 + 5.0 * float(k))
			draw_line(Vector2(x, p.y - 6.0 + 3.0 * float(k)), Vector2(x, p.y + 6.0 - 3.0 * float(k)), rosso, 2.0)


func percorso(punti: Array[Vector2]) -> PackedVector2Array:
	# una curva morbida che passa per i punti (Catmull-Rom a mano)
	var curva := Curve2D.new()
	for i in punti.size():
		var prima: Vector2 = punti[maxi(i - 1, 0)]
		var dopo: Vector2 = punti[mini(i + 1, punti.size() - 1)]
		var maniglia := (dopo - prima) * 0.22
		curva.add_point(punti[i], -maniglia, maniglia)
	curva.bake_interval = 6.0
	return curva.get_baked_points()


func lungo_il_percorso(punti: PackedVector2Array, quanto: float) -> Vector2:
	return punti[clampi(roundi(quanto * float(punti.size() - 1)), 0, punti.size() - 1)]


func frattura(c: Vector2) -> void:
	# la lente del Vuoto, in piccolo: anelli arancio e il buio in mezzo
	for k in 6:
		var r := 46.0 - 6.0 * float(k)
		draw_set_transform(c, 0.0, Vector2(0.62, 1.0))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(tinte["segnale"], 0.18 + 0.12 * float(k)), 2.0, true)
	draw_set_transform(c, 0.0, Vector2(0.42, 1.0))
	draw_circle(Vector2.ZERO, 14.0, Color("#000000"))
	draw_set_transform(Vector2.ZERO)


func insediamento(c: Vector2) -> void:
	var tinta: Color = tinte["carta"]
	var pieno := Color(tinte["fondo"]).lerp(tinte["inchiostro"], 0.25)
	draw_arc(c + Vector2(6, 10), 76.0, PI * 0.58, PI * 1.42, 32, Color(tinte["inchiostro"], 0.6), 9.0, true)
	draw_arc(c + Vector2(6, 10), 76.0, PI * 0.58, PI * 1.42, 32, tinta, 3.0, true)
	for r: Rect2 in [Rect2(c + Vector2(-26, -20), Vector2(42, 28)), Rect2(c + Vector2(22, -4), Vector2(46, 30)),
			Rect2(c + Vector2(-14, 26), Vector2(40, 26))]:
		draw_rect(Rect2(r.position + Vector2(0, 6), r.size), Color(tinte["inchiostro"], 0.4))
		draw_rect(r, pieno)
		draw_rect(r, tinta, false, 1.5)
	draw_line(c + Vector2(44, -4), c + Vector2(44, -28), tinta, 1.0)
	draw_circle(c + Vector2(44, -28), 2.0, tinte["segnale"])
	# il dominatore, sul tetto del primo modulo: una pedina col suo giro di aura
	var pedina := c + Vector2(28, -44)
	draw_arc(pedina, 21.0, 0.0, TAU, 40, Color(tinte["segnale"], 0.85), 2.0, true)
	draw_circle(pedina, 15.0, tinta)
	var lettera := "Y"
	var corpo := 18
	var f := Caratteri.titolo()
	var m := f.get_string_size(lettera, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo)
	draw_string(f, pedina + Vector2(-m.x * 0.5, corpo * 0.36), lettera, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo,
			tinte["fondo"])


func nemico(p: Vector2, r: float, vita: float) -> void:
	var rosso := Stile.colore("pericolo")
	draw_colored_polygon(PackedVector2Array([p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r),
			p + Vector2(-r, 0)]), rosso)
	draw_rect(Rect2(p + Vector2(-r, -r - 6), Vector2(r * 2.0, 2)), Color(tinte["inchiostro"], 0.6))
	draw_rect(Rect2(p + Vector2(-r, -r - 6), Vector2(r * 2.0 * vita, 2)), rosso)


func torre(p: Vector2, specie: String) -> void:
	var tinta: Color = tinte["carta"]
	draw_circle(p, 15.0, tinte["fondo"])
	draw_arc(p, 15.0, 0.0, TAU, 32, tinta, 2.0, true)
	match specie:
		"postazione":
			draw_rect(Rect2(p + Vector2(-5, -2), Vector2(10, 8)), tinta)
			draw_line(p + Vector2(0, -2), p + Vector2(-6, -11), tinta, 3.0, true)
		"mortaio":
			draw_circle(p + Vector2(0, 3), 6.0, tinta)
			draw_line(p + Vector2(0, 3), p + Vector2(5, -9), tinta, 4.0, true)
		_:
			draw_polyline(PackedVector2Array([p + Vector2(-9, -3), p + Vector2(-4, 4), p + Vector2(0, -3),
					p + Vector2(4, 4), p + Vector2(9, -3)]), tinta, 2.0, true)


func posto_libero(p: Vector2) -> void:
	var tinta := Color(tinte["inchiostro"], 0.95)
	for k in 12:
		if k % 2 == 0:
			draw_arc(p, 15.0, TAU * float(k) / 12.0, TAU * float(k + 1) / 12.0, 6, tinta, 1.5, true)
	draw_line(p + Vector2(-5, 0), p + Vector2(5, 0), tinta, 2.0)
	draw_line(p + Vector2(0, -5), p + Vector2(0, 5), tinta, 2.0)


func arco_tratteggiato(da: Vector2, a: Vector2, su: float) -> void:
	var prima := da
	for k in range(1, 21):
		var f := float(k) / 20.0
		var p := da.lerp(a, f) + Vector2(0, -su * 4.0 * f * (1.0 - f))
		if k % 2 == 1:
			draw_line(prima, p, Color(tinte["segnale"], 0.75), 1.5, true)
		prima = p


func velocita(dove: Vector2) -> void:
	var simboli := ["pausa", "uno", "due"]
	for k in simboli.size():
		var r := Rect2(dove + Vector2(40.0 * k, 0), Vector2(34, 24))
		var acceso := k == 1
		draw_rect(r, tinte["segnale"] if acceso else Color(tinte["fondo"], 0.9))
		draw_rect(r, tinte["segnale"] if acceso else tinte["inchiostro"], false, 1.0)
		var tinta: Color = tinte["fondo"] if acceso else tinte["carta"]
		var c := r.get_center()
		match String(simboli[k]):
			"pausa":
				draw_rect(Rect2(c + Vector2(-5, -6), Vector2(3, 12)), tinta)
				draw_rect(Rect2(c + Vector2(2, -6), Vector2(3, 12)), tinta)
			"uno":
				draw_colored_polygon(PackedVector2Array([c + Vector2(-4, -6), c + Vector2(5, 0), c + Vector2(-4, 6)]), tinta)
			_:
				for d in [-5.0, 3.0]:
					draw_colored_polygon(PackedVector2Array([c + Vector2(d - 3, -6), c + Vector2(d + 5, 0),
							c + Vector2(d - 3, 6)]), tinta)


# --------------------------------------------------- 3 IL PIANETA CHE PROMETTE

func pubblicita() -> void:
	# i cinque telefoni li mette mostra(): qui i nomi sotto, e le tre schede
	tavolo("CARNIVALZ  ·  DATA PAD  ·  SEGNALE DAL PIANETA CHE PROMETTE", RISERVE)
	for k in GIOCHI.size():
		var nome := String((SCHEDE[GIOCHI[k]] as Dictionary)["nome"])
		var largo := Caratteri.titolo().get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 11.0
		Manifesto.etichetta_tinta(self, Vector2(187.0 + 186.0 * float(k) + 81.0 - largo * 0.5, 374), nome, 11,
				tinte["carta"], tinte["fondo"])
	var schede := [["01 / LA MANO", "È la pubblicità, e vuole vederti sbagliare. In ogni gioco aspetta che esiti, poi gioca lei: il perno sbagliato, il numero più grosso, la porta che conviene meno. L'anello rosso dice quanto manca, e più vai avanti meno aspetta."],
			["02 / L'OMINO", "È lo stesso in tutti e cinque. Ogni sbaglio gli dà stress, e con lo stress alto trema: un perno gli scivola, il corteo si sparpaglia. Ogni vittoria gli dà speranza: piena, all'ultimo livello esce dalla pubblicità."],
			["03 / PERCHÉ È MEGLIO", "Ognuno ha una decisione vera, che i giochi delle pubblicità non hanno: l'ordine, l'elemento, il lato da coprire, la ragione. Una cosa nuova alla volta, livello dopo livello. E niente vite, niente attese, niente video."]]
	for k in schede.size():
		var r := Rect2(60.0 + 404.0 * float(k), 420, 380, 132)
		SchedaProiezione.scatola(self, r, String(schede[k][0]), tinte)
		racconto(Rect2(r.position + Vector2(14, 32), Vector2(r.size.x - 26, 96)), String(schede[k][1]))
	titolo("IL PIANETA CHE PROMETTE  ·  5 GIOCHI", "LE PUBBLICITÀ")


func dettaglio(gioco: String, numero: int) -> void:
	# un gioco in grande (il telefono lo mette mostra()), a sinistra cosa cambia
	# rispetto alle pubblicita', a destra i tre passi della soluzione
	var d: Dictionary = SCHEDE[gioco]
	tavolo("CARNIVALZ  ·  DATA PAD  ·  IL PIANETA CHE PROMETTE  ·  " + String(d["nome"]), RISERVE)
	var x := 56.0
	nome_scheda(Rect2(x, 148, LARGO, 64), "01 / IL GIOCO", String(d["nome"]), "DI SOLITO: " + String(d["di_solito"]))
	var solito := Rect2(x, 220, LARGO, 92)
	SchedaProiezione.scatola(self, solito, "02 / DI SOLITO", tinte)
	racconto(Rect2(solito.position + Vector2(14, 30), Vector2(LARGO - 26, 60)), String(d["solito"]))
	var nostro := Rect2(x, 320, LARGO, 160)
	SchedaProiezione.scatola(self, nostro, "03 / IL NOSTRO", tinte)
	racconto(Rect2(nostro.position + Vector2(14, 30), Vector2(LARGO - 26, 128)), String(d["nostro"]))
	var mano := Rect2(x, 488, LARGO, 100)
	SchedaProiezione.scatola(self, mano, "04 / LA MANO", tinte)
	racconto(Rect2(mano.position + Vector2(14, 30), Vector2(LARGO - 26, 68)), String(d["mano"]))
	var passi: Array = d["passi"]
	for k in 3:
		var y := 80.0 + 206.0 * float(k)
		Manifesto.etichetta_tinta(self, Vector2(958, y + 40), "%d" % (k + 1), 20, Stile.colore("manifesto"),
				Stile.colore("bordo"))
		racconto(Rect2(962, y + 84, 280, 80), String(passi[k]))
	titolo("LE PUBBLICITÀ  ·  %d DI 5" % numero, String(d["nome"]))


# ----------------------------------------------------------- 4 IL GIRO

func giro() -> void:
	tavolo("CARNIVALZ  ·  SALA OPERATIVA  ·  LE RISERVE", RISERVE)
	# le tre specie intorno alle riserve: a sinistra e a destra quelle che
	# prendono e danno, in alto quella che da' soltanto
	var riserve := Rect2(430, 290, 420, 128)
	freccia(Vector2(285, 318), Vector2(428, 318), "MINERALI  ·  MATERIALI", true)
	freccia(Vector2(428, 388), Vector2(285, 388), "CANCELLI  ·  MACCHINE", false)
	freccia(Vector2(640, 232), Vector2(640, 288), "TAZO  ·  COLLEZIONABILI", true)
	freccia(Vector2(852, 318), Vector2(1015, 318), "POSTAZIONI  ·  MURA", false)
	freccia(Vector2(1015, 388), Vector2(852, 388), "ORGANIZZAZIONE  ·  TAZO", true)
	pianeta(Vector2(180, 340), 52.0, "LA RACCOLTA", "DA SUBITO")
	pianeta(Vector2(640, 128), 44.0, "LE PUBBLICITÀ", "DA SUBITO, SE LA TROVI")
	pianeta(Vector2(1120, 340), 52.0, "LA RESISTENZA", "DOPO IL PRIMO CARNIVALZ SPENTO")
	SchedaProiezione.scatola(self, riserve, "LE RISERVE  ·  NEL DATA PAD", tinte)
	var righe := [["MINERALI", "128"], ["RISORSE PER L'ORGANIZZAZIONE", "4"], ["TAZO", "2.430"],
			["MATERIALI PER L'ARTIGIANO", "7"]]
	for k in righe.size():
		var y := riserve.position.y + 40.0 + 22.0 * float(k)
		scrivi(Vector2(riserve.position.x + 14, y), String(righe[k][0]), 11, tinte["inchiostro"], 450, 85, 2)
		var w := DisegnoProiezione.larghezza(String(righe[k][1]), 14, 450, 85, 2)
		scrivi(Vector2(riserve.end.x - 14 - w, y + 1), String(righe[k][1]), 14, tinte["carta"], 450, 85, 2)
	trattini(Vector2(riserve.get_center().x, riserve.end.y), Vector2(riserve.get_center().x, 458),
			Color(tinte["carta"], 0.6), 6.0)
	var torna_scritta := "COSA TORNA AL GIOCO GRANDE"
	scrivi(Vector2(riserve.get_center().x - DisegnoProiezione.larghezza(torna_scritta, 11, 450, 85, 3) * 0.5, 476),
			torna_scritta, 11, tinte["carta"], 450, 85, 3)
	var torna := [["L'EMPORIO", "Le risorse per l'Organizzazione aprono merce nuova."],
			["L'ARTIGIANO", "Crafta dalle cose che raccogli: i materiali vengono da qui."],
			["GLI AIUTANTI", "Un avamposto che tiene manda un soldato come Aiutante negli scontri."],
			["LA STORIA", "Un avamposto salva gente. Qualcuno, poi, si ricorda di te."]]
	for k in torna.size():
		var r := Rect2(60 + 296.0 * float(k), 492, 272, 96)
		SchedaProiezione.scatola(self, r, String(torna[k][0]), tinte)
		racconto(Rect2(r.position + Vector2(14, 30), Vector2(r.size.x - 26, 66)), String(torna[k][1]))
	titolo("QUELLO CHE ENTRA E QUELLO CHE ESCE", "IL GIRO DELLE RISERVE")


func pianeta(c: Vector2, r: float, nome: String, quando: String) -> void:
	# a retino come i pianeti del Vuoto: piu' luce in alto a sinistra
	draw_set_transform(c, 0.0, Vector2(1.0, 0.32))
	draw_arc(Vector2.ZERO, r * 1.55, 0.0, TAU, 64, Color(tinte["inchiostro"], 0.8), 1.0, true)
	draw_set_transform(Vector2.ZERO)
	draw_circle(c, r, tinte["fondo"])
	var luce := c + Vector2(-0.45, -0.5) * r
	var passo := 5.0
	var y := -r
	while y <= r:
		var x := -r + (passo * 0.5 if roundi(y / passo) % 2 != 0 else 0.0)
		while x <= r:
			var p := c + Vector2(x, y)
			if p.distance_to(c) < r - 1.5:
				var quanto := clampf(1.15 - p.distance_to(luce) / (r * 1.6), 0.12, 1.0)
				draw_circle(p, passo * 0.5 * quanto, tinte["carta"])
			x += passo
		y += passo
	draw_arc(c, r, 0.0, TAU, 64, Color(tinte["carta"], 0.5), 1.0, true)
	var largo := Caratteri.titolo().get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x + 14.0
	Manifesto.etichetta_tinta(self, c + Vector2(-largo * 0.5, r + 16), nome, 14, tinte["carta"], tinte["fondo"])
	var w := DisegnoProiezione.larghezza(quando, 10, 450, 85, 2)
	scrivi(c + Vector2(-w * 0.5, r + 48), quando, 10, tinte["segnale"], 450, 85, 2)


func freccia(da: Vector2, a: Vector2, scritta: String, entra: bool) -> void:
	# entra nelle riserve: piena, chiara. Esce: tratteggiata, nel colore delle
	# linee. La scritta sopra la freccia che va a destra, sotto quella che torna
	var tinta: Color = Color(tinte["carta"], 0.9) if entra else Color(tinte["inchiostro"], 1.0)
	if entra:
		draw_line(da, a, tinta, 1.5, true)
	else:
		trattini(da, a, tinta, 7.0)
	var verso := (a - da).normalized()
	var lato := verso.orthogonal()
	draw_colored_polygon(PackedVector2Array([a, a - verso * 11.0 + lato * 5.5, a - verso * 11.0 - lato * 5.5]), tinta)
	var w := DisegnoProiezione.larghezza(scritta, 10, 450, 85, 2)
	var mezzo := (da + a) * 0.5
	var dove := mezzo + Vector2(12, 4)
	if absf(verso.x) > 0.5:
		dove = mezzo + Vector2(-w * 0.5, -8.0 if verso.x > 0.0 else 18.0)
	scrivi(dove, scritta, 10, tinta, 450, 85, 2)


# ---------------------------------------------------------- pezzi comuni

func tavolo(intestazione: String, nota: String) -> void:
	# il tavolo della Sala operativa: il fondo, la griglia, la cornice, il righello
	draw_rect(Rect2(Vector2.ZERO, size), tinte["fondo"])
	var griglia := Color(tinte["inchiostro"], 0.13)
	for i in 33:
		draw_line(Vector2(i * 40.0, 0), Vector2(i * 40.0, 720), griglia, 1.0)
	for j in 19:
		draw_line(Vector2(0, j * 40.0), Vector2(1280, j * 40.0), griglia, 1.0)
	var carta: Color = tinte["carta"]
	draw_rect(Rect2(18, 18, 1244, 684), Color(tinte["inchiostro"], 0.7), false, 1.0)
	for angolo: Vector2 in [Vector2(18, 18), Vector2(1262, 18), Vector2(18, 702), Vector2(1262, 702)]:
		var sx := 1.0 if angolo.x < 640.0 else -1.0
		var sy := 1.0 if angolo.y < 360.0 else -1.0
		draw_polyline(PackedVector2Array([angolo + Vector2(0, 14 * sy), angolo, angolo + Vector2(14 * sx, 0)]), carta, 2.0)
	var x0 := DisegnoProiezione.INIZIO_INTESTAZIONE
	scrivi(Vector2(x0, 44), intestazione, 11, Color(carta, 0.85), 350, 85, 3)
	draw_line(Vector2(x0, 54), Vector2(940, 54), Color(tinte["inchiostro"], 0.8), 1.0)
	for i in 41:
		var x := x0 + float(i) * 19.65
		draw_line(Vector2(x, 54), Vector2(x, 58 if i % 5 else 62), Color(tinte["inchiostro"], 0.8), 1.0)
	var w := DisegnoProiezione.larghezza(nota, 11, 350, 85, 3)
	scrivi(Vector2(1244 - w, 44), nota, 11, Color(carta, 0.85), 350, 85, 3)
	# l'iconcina del menu, come in ogni schermata
	var icona := StyleBoxFlat.new()
	icona.bg_color = Stile.colore("manifesto")
	icona.set_corner_radius_all(12)
	draw_style_box(icona, Rect2(62, 62, 64, 64))
	for k in 3:
		draw_rect(Rect2(77, 78 + 13 * k, 34, 6), Stile.colore("bordo"))


func titolo(sopra: String, nome: String) -> void:
	scrivi(Vector2(38, 626), sopra, 11, Stile.colore("manifesto"), 400, 85, 3)
	Manifesto.etichetta_tinta(self, Vector2(30, 636), nome, 34, Stile.colore("manifesto"), Stile.colore("bordo"))


func nome_scheda(r: Rect2, etichetta: String, nome: String, sotto: String) -> void:
	SchedaProiezione.scatola(self, r, etichetta, tinte)
	var corpo := 20
	while corpo > 11 and DisegnoProiezione.larghezza(nome, corpo, 260, 75, 4) > LARGO - 20.0:
		corpo -= 1
	scrivi(r.position + Vector2(10, 40), nome, corpo, tinte["carta"], 260, 75, 4)
	scrivi(r.position + Vector2(10, 57), sotto, 9, tinte["inchiostro"], 450, 85, 2)


func riga_con_barra(dove: Vector2, chiave: String, valore: String, quota: float) -> void:
	SchedaProiezione.riga(self, dove, chiave, valore, tinte)
	var barra := Rect2(dove + Vector2(0, 6), Vector2(LARGO - 20, 4))
	draw_rect(barra, Color(tinte["inchiostro"], 0.35))
	draw_rect(Rect2(barra.position, Vector2(barra.size.x * quota, 4)),
			tinte["segnale"] if quota >= 1.0 else tinte["carta"])


func racconto(r: Rect2, testo: String) -> void:
	draw_line(r.position + Vector2(-6, 2), r.position + Vector2(-6, r.size.y - 4), Color(tinte["inchiostro"], 0.9), 1.0)
	draw_multiline_string(DisegnoProiezione.fonte(380, 90, 0), r.position + Vector2(0, 13), testo,
			HORIZONTAL_ALIGNMENT_LEFT, r.size.x, 13, -1, tinte["carta"])


func bottone(r: Rect2, parola: String) -> void:
	draw_rect(r, Stile.colore("manifesto"))
	scrivi(r.position + Vector2(14, 26), parola, 13, tinte["fondo"], 500, 80, 3)
	for k in 3:
		var x := r.end.x - 44.0 + float(k) * 11.0
		var y := r.position.y + 20.0
		Manifesto.poligono(self, PackedVector2Array([Vector2(x, y - 6), Vector2(x + 7, y), Vector2(x, y + 6)]),
				tinte["fondo"])


func suggerimenti(righe: Array[String]) -> void:
	for k in righe.size():
		scrivi(Vector2(X, 561 + 13 * k), righe[k], 9, tinte["inchiostro"], 450, 85, 2)


func cartellino(punto: Vector2, verso: Vector2, nome: String, stato: String, acceso := true,
		a_sinistra := false) -> void:
	# l'etichetta a didascalia del Vuoto: il filo, il nome chiaro, lo stato sotto.
	# a_sinistra: la scritta sta a sinistra del gomito, per chi e' gia' a destra
	var tinta: Color = tinte["carta"] if acceso else tinte["inchiostro"]
	var lungo := maxf(Caratteri.titolo().get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 16.0,
			DisegnoProiezione.larghezza(stato, 10, 420, 85, 2))
	var gomito := punto + verso
	var b := gomito - Vector2(lungo + 10.0, 0) if a_sinistra else gomito
	draw_rect(Rect2(b + Vector2(0, -19), Vector2(lungo + 8.0, 35)), Color(tinte["fondo"], 0.72))
	draw_polyline(PackedVector2Array([punto, gomito, b if a_sinistra else b + Vector2(lungo + 10.0, 0)]),
			Color(tinta, 0.8), 1.0)
	draw_circle(punto, 1.8, tinta)
	Manifesto.etichetta_tinta(self, b + Vector2(0, -20), nome, 12, tinta, tinte["fondo"])
	scrivi(b + Vector2(4, 12), stato, 10, tinte["inchiostro"] if acceso else Color(tinte["inchiostro"], 0.8), 420, 85, 2)


func scrivi(dove: Vector2, testo: String, corpo: int, tinta: Color, peso := 420.0, largo := 85.0, spazio := 2) -> void:
	DisegnoProiezione.scrivi(self, dove, testo, corpo, tinta, peso, largo, spazio)


func trattini(da: Vector2, a: Vector2, tinta: Color, passo: float) -> void:
	var lungo := da.distance_to(a)
	var quanti := maxi(1, int(lungo / passo))
	for k in quanti:
		if k % 2 == 0:
			draw_line(da.lerp(a, float(k) / quanti), da.lerp(a, minf(1.0, float(k + 1) / quanti)), tinta, 1.5, true)


func sposta(punti: PackedVector2Array, di: Vector2) -> PackedVector2Array:
	var spostati := PackedVector2Array()
	for p in punti:
		spostati.append(p + di)
	return spostati


func chiuso(punti: PackedVector2Array) -> PackedVector2Array:
	var giro_chiuso := punti.duplicate()
	giro_chiuso.append(punti[0])
	return giro_chiuso
