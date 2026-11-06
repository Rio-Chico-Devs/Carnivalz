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
#   3_pubblicita   il pianeta che promette: i giochi delle pubblicita', veri
#   4_il_giro      come si parlano le tre, attraverso le riserve
#
# Disegnate nella lingua del Vuoto (i quattro inchiostri di stile.json
# "proiezione", le schede a destra, le etichette): si comandano dalla Sala
# operativa, come si guarda la mappa. Solo il gioco delle pubblicita' esce dal
# tavolo e va sul data pad, in verticale, coi colori sguaiati di una pubblicita'.
# Tutti i nomi e i numeri sono miei, d'esempio.
#
#   ./prove/proposte_pianeti.sh   le fotografa in scatti/proposte_pianeti/
#   nell'editor, F6: destra e sinistra cambiano tavola

const TAVOLE := ["1_raccolta", "2_resistenza", "3_pubblicita", "4_il_giro"]
const CARTELLA := "res://scatti/proposte_pianeti"
const X := SchedaProiezione.X
const LARGO := SchedaProiezione.LARGO
const RISERVE := "MINERALI 128     TAZO 2.430     ORG 4"
# i colori di una pubblicita' da telefono: apposta fuori dalla tavolozza
const CIELO_ALTO := Color("#6fd3ff")
const CIELO_BASSO := Color("#2a68d8")
const LAVA := Color("#ff5a1f")
const ORO := Color("#ffd23a")
const MOSTRO := Color("#8c4bd6")
const VERDE := Color("#37c94a")
const MURO := Color("#4a3426")

var indice := 0
var tinte := {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tinte = CieloProiezione.tinte()
	if not "foto" in OS.get_cmdline_user_args():
		return
	DirAccess.make_dir_recursive_absolute(CARTELLA)
	for i in TAVOLE.size():
		indice = i
		queue_redraw()
		for k in 6:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(CARTELLA.path_join("%s.png" % TAVOLE[i]))
		print("TAVOLA %s" % TAVOLE[i])
	get_tree().quit()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_right"):
		indice = (indice + 1) % TAVOLE.size()
		queue_redraw()
	elif evento.is_action_pressed("ui_left"):
		indice = (indice + TAVOLE.size() - 1) % TAVOLE.size()
		queue_redraw()


func _draw() -> void:
	match String(TAVOLE[indice]):
		"1_raccolta":
			raccolta()
		"2_resistenza":
			resistenza()
		"3_pubblicita":
			pubblicita()
		_:
			giro()


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
	scrivi(Vector2(452, 294), "+6 MINERALI", 13, tinte["segnale"], 560, 85, 2)
	cancello(Vector2(730, 396), true, "40 MINERALI  ·  300 TAZO")
	cancello(Vector2(495, 242), false, "100 MINERALI  ·  ORG 2")
	cancello(Vector2(595, 160), false, "?")
	cartellino(Vector2(150, 434), Vector2(-50, -46), "IL CAMPO D'ATTERRAGGIO", "APERTO  ·  2 VENE")
	cartellino(Vector2(720, 268), Vector2(18, -44), "LA PIANA DI QUARZO", "APERTO  ·  3 VENE  ·  1 MACCHINA")
	cartellino(Vector2(780, 528), Vector2(-60, 56), "LE FORRE DI FERRO", "CHIUSO  ·  DIETRO UN CANCELLO", false)
	cartellino(Vector2(290, 136), Vector2(-60, -30), "IL CRATERE", "CHIUSO  ·  MANCANO 60 MINERALI", false)
	cartellino(Vector2(800, 126), Vector2(10, -26), "?", "NON ANCORA RILEVATO", false)
	cartellino(Vector2(205, 440), Vector2(-40, 90), "IL MODULO", "DA QUI ALLE RISERVE")
	nome_scheda(Rect2(X, 76, LARGO, 64), "01 / CAMPO", "LA PIANA DI QUARZO", "APERTO  ·  3 VENE  ·  1 MACCHINA")
	var vene := Rect2(X, 148, LARGO, 96)
	SchedaProiezione.scatola(self, vene, "02 / VENE", tinte)
	riga_con_barra(vene.position + Vector2(10, 34), "QUARZO", "PRONTA", 1.0)
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
			"Dietro: vene di ferro, un relitto da smontare, e qualcosa che la sonda non sa leggere.")
	bottone(Rect2(X, 502, LARGO, 40), "APRI IL CANCELLO")
	suggerimenti(["CLIC SU UNA VENA PRONTA  ·  RACCOGLI", "CLIC SU UNA VENA  ·  COSTRUISCI",
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
	for posto: Vector2 in [Vector2(232, 196), Vector2(540, 330), Vector2(780, 506)]:
		posto_libero(posto)
	cartellino(Vector2(100, 268), Vector2(10, -70), "LA FRATTURA", "DA QUI ESCONO")
	cartellino(Vector2(345, 288), Vector2(40, -170), "POSTAZIONE  ·  LIV. 2", "SCELTA")
	cartellino(Vector2(512, 492), Vector2(-150, 60), "MORTAIO  ·  LIV. 1", "COLPISCE IN UN'AREA")
	cartellino(Vector2(736, 528), Vector2(14, 44), "RETE", "RALLENTA")
	cartellino(Vector2(552, 318), Vector2(30, -60), "POSTO LIBERO", "20 MINERALI")
	cartellino(Vector2(900, 360), Vector2(-120, -150), "IL DOMINATORE DI TURNO", "YHVINA  ·  MOSSA PRONTA")
	velocita(Vector2(822, 572))
	nome_scheda(Rect2(X, 76, LARGO, 64), "01 / AVAMPOSTO", "AVAMPOSTO D'ESEMPIO", "2 ASSEDI RESPINTI  ·  0 PERSI")
	var assedio := Rect2(X, 148, LARGO, 96)
	SchedaProiezione.scatola(self, assedio, "02 / L'ASSEDIO", tinte)
	SchedaProiezione.riga(self, assedio.position + Vector2(10, 34), "ONDATA", "3 DI 8", tinte)
	SchedaProiezione.riga(self, assedio.position + Vector2(10, 52), "IN ARRIVO", "9 GHOUL  ·  1 ABOMINIO", tinte)
	riga_con_barra(assedio.position + Vector2(10, 80), "MURA", "14 / 20", 0.7)
	var torre_scelta := Rect2(X, 252, LARGO, 102)
	SchedaProiezione.scatola(self, torre_scelta, "03 / POSTAZIONE  ·  LIV. 2", tinte)
	SchedaProiezione.riga(self, torre_scelta.position + Vector2(10, 36), "COLPO", "UNO ALLA VOLTA  ·  LONTANO", tinte)
	SchedaProiezione.riga(self, torre_scelta.position + Vector2(10, 56), "AL LIV. 3", "40 MINERALI  ·  250 TAZO", tinte)
	SchedaProiezione.riga(self, torre_scelta.position + Vector2(10, 76), "AL LIV. 3 FA", "DUE COLPI, PIÙ LONTANO", tinte)
	SchedaProiezione.riga(self, torre_scelta.position + Vector2(10, 94), "SMONTALA", "+20 MINERALI", tinte)
	var data_pad := Rect2(X, 362, LARGO, 132)
	SchedaProiezione.scatola(self, data_pad, "04 / DAL DATA PAD", tinte)
	racconto(Rect2(data_pad.position + Vector2(14, 30), Vector2(LARGO - 26, 100)),
			"«A seguito dei risultati ottenuti, le è affidato il comando di un avamposto. Le forze sono nostre. Il dominatore di turno è suo.»")
	bottone(Rect2(X, 502, LARGO, 40), "MIGLIORA LA POSTAZIONE")
	suggerimenti(["CLIC SU UN POSTO LIBERO  ·  COSTRUISCI", "CLIC SU UNA POSTAZIONE  ·  MIGLIORA",
			"CLIC SUL DOMINATORE  ·  LA SUA MOSSA", "SPAZIO  ·  PAUSA     TAB  ·  PIÙ VELOCE"])
	titolo("PIANETA D'ESEMPIO  ·  L'INFEZIONE PREME", "LA RESISTENZA")


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
	tavolo("CARNIVALZ  ·  DATA PAD  ·  SEGNALE DAL PIANETA CHE PROMETTE", RISERVE)
	var fuori := Rect2(450, 70, 380, 610)
	telefono(fuori)
	perni(fuori.grow(-14))
	var colonna := 56.0
	nome_scheda(Rect2(colonna, 148, LARGO, 64), "01 / IL PIANETA", "IL PIANETA CHE PROMETTE",
			"UN MONDO FATTO DI PUBBLICITÀ")
	var fonte := Rect2(colonna, 220, LARGO, 140)
	SchedaProiezione.scatola(self, fonte, "02 / LA FONTE", tinte)
	racconto(Rect2(fonte.position + Vector2(14, 30), Vector2(LARGO - 26, 108)),
			"Qualcuno, qui, ha passato la vita a girare pubblicità di giochi che non esistevano. Il Carnivalz gliele ha fatte vere. Dentro c'è l'omino che sbaglia apposta, ogni volta, da sempre.")
	var premi := Rect2(colonna, 368, LARGO, 76)
	SchedaProiezione.scatola(self, premi, "03 / COSA SI VINCE", tinte)
	SchedaProiezione.riga(self, premi.position + Vector2(10, 34), "OGNI LIVELLO", "TAZO", tinte)
	SchedaProiezione.riga(self, premi.position + Vector2(10, 50), "OGNI TANTO", "UN COLLEZIONABILE", tinte)
	SchedaProiezione.riga(self, premi.position + Vector2(10, 66), "ALLA FINE", "L'OMINO, SALVO", tinte)
	var regole := Rect2(colonna, 452, LARGO, 104)
	SchedaProiezione.scatola(self, regole, "04 / COSA NON C'È", tinte)
	racconto(Rect2(regole.position + Vector2(14, 30), Vector2(LARGO - 26, 72)),
			"Niente vite, niente attese, niente «guarda un video per continuare». Trenta secondi a livello.")
	miniatura(Rect2(862, 84, 172, 222), "torre", "LA TORRE DEI NUMERI")
	miniatura(Rect2(1062, 84, 172, 222), "porte", "LE PORTE")
	miniatura(Rect2(862, 352, 172, 222), "linea", "DISEGNA LA LINEA")
	miniatura(Rect2(1062, 352, 172, 222), "scegli", "SCEGLI QUELLO GIUSTO")
	titolo("IL PIANETA CHE PROMETTE  ·  5 GIOCHI", "LE PUBBLICITÀ")


func telefono(fuori: Rect2) -> void:
	# il data pad tenuto in verticale, come un telefono
	var guscio := StyleBoxFlat.new()
	guscio.bg_color = Color("#222226")
	guscio.set_corner_radius_all(30)
	guscio.border_color = Color("#55555c")
	guscio.set_border_width_all(2)
	draw_style_box(guscio, fuori)
	var schermo := fuori.grow(-14)
	cielo(schermo)
	# la pubblicita' ha sempre la sua crocetta finta, e la scritta che urla
	draw_circle(schermo.position + Vector2(schermo.size.x - 16, 16), 9.0, Color(0, 0, 0, 0.35))
	draw_line(schermo.position + Vector2(schermo.size.x - 20, 12), schermo.position + Vector2(schermo.size.x - 12, 20),
			Color(1, 1, 1, 0.7), 1.5)
	draw_line(schermo.position + Vector2(schermo.size.x - 12, 12), schermo.position + Vector2(schermo.size.x - 20, 20),
			Color(1, 1, 1, 0.7), 1.5)
	urla(Vector2(schermo.get_center().x, schermo.position.y + 64), "IL 90% SBAGLIA!", 34)
	pillola(Rect2(schermo.get_center().x - 46, schermo.position.y + 80, 92, 22), "LIVELLO 3", Color("#ffffff"),
			Color("#1d3f8f"), 12)
	pillola(Rect2(schermo.get_center().x - 110, schermo.end.y - 66, 220, 44), "GIOCA ORA", VERDE, Color.WHITE, 22)
	var nota := "non c'è niente da scaricare: si gioca qui"
	var f := DisegnoProiezione.fonte(380, 90, 0)
	var w := f.get_string_size(nota, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
	draw_string(f, Vector2(schermo.get_center().x - w * 0.5, schermo.end.y - 8), nota, HORIZONTAL_ALIGNMENT_LEFT, -1,
			10, Color(1, 1, 1, 0.8))


func perni(schermo: Rect2) -> void:
	# TIRA IL PERNO: oro a sinistra, lava a destra, sotto l'omino e il mostro.
	# Giusto: il perno della lava (cade sul mostro), poi quello dell'oro.
	# La mano della pubblicita' va dritta a quello sbagliato
	var o := schermo.position
	var muro := 9.0
	var sx := o.x + 40.0
	var dx := schermo.end.x - 40.0
	var mezzo := schermo.get_center().x
	var cima := o.y + 120.0
	var piano := o.y + 250.0
	var fondo := o.y + 420.0
	draw_polyline(PackedVector2Array([Vector2(sx, cima), Vector2(sx, fondo), Vector2(dx, fondo), Vector2(dx, cima)]),
			MURO, muro)
	draw_line(Vector2(mezzo, cima), Vector2(mezzo, piano - 8.0), MURO, muro)
	# l'oro e la lava nelle due camere di sopra
	for k in 9:
		var p := Vector2(sx + 22.0 + float(k % 4) * 24.0, piano - 18.0 - floorf(float(k) / 4.0) * 20.0)
		draw_circle(p, 10.0, ORO)
		draw_arc(p, 10.0, 0.0, TAU, 20, Color("#d08a10"), 2.0, true)
	var lava := PackedVector2Array()
	for i in 13:
		var x := lerpf(mezzo + 6.0, dx - 6.0, float(i) / 12.0)
		lava.append(Vector2(x, piano - 58.0 + 6.0 * sin(float(i) * 1.3)))
	lava.append(Vector2(dx - 6.0, piano - 8.0))
	lava.append(Vector2(mezzo + 6.0, piano - 8.0))
	draw_colored_polygon(lava, LAVA)
	draw_polyline(lava.slice(0, 13), Color("#ffb35a"), 3.0, true)
	perno(Vector2(sx - 22.0, piano - 2.0), Vector2(mezzo - 4.0, piano - 2.0), "a")
	perno(Vector2(dx + 22.0, piano - 2.0), Vector2(mezzo + 4.0, piano - 2.0), "b")
	perno(Vector2(mezzo, fondo + 24.0), Vector2(mezzo, piano + 4.0), "c")
	omino(Vector2(sx + 60.0, fondo - 44.0))
	mostriciattolo(Vector2(dx - 62.0, fondo - 38.0))
	mano(Vector2(mezzo + 10.0, fondo + 28.0))


func perno(manico: Vector2, punta: Vector2, _nome: String) -> void:
	draw_line(manico, punta, Color("#d9dde3"), 7.0, true)
	draw_line(manico, punta, Color("#8b929c"), 2.0, true)
	draw_circle(manico, 11.0, Color("#d9dde3"))
	draw_arc(manico, 11.0, 0.0, TAU, 24, Color("#5b616a"), 2.0, true)
	draw_circle(manico, 4.0, Color("#5b616a"))


func omino(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(-11, 0), Vector2(22, 30)), Color("#2f80ff"))
	draw_line(p + Vector2(-11, 6), p + Vector2(-22, -8), Color("#ffd7b0"), 5.0, true)
	draw_line(p + Vector2(11, 6), p + Vector2(22, -8), Color("#ffd7b0"), 5.0, true)
	draw_line(p + Vector2(-6, 30), p + Vector2(-6, 42), Color("#2a2a2a"), 6.0)
	draw_line(p + Vector2(6, 30), p + Vector2(6, 42), Color("#2a2a2a"), 6.0)
	draw_circle(p + Vector2(0, -12), 13.0, Color("#ffd7b0"))
	draw_circle(p + Vector2(-4, -14), 2.0, Color.BLACK)
	draw_circle(p + Vector2(4, -14), 2.0, Color.BLACK)
	draw_arc(p + Vector2(0, -5), 3.5, 0.0, TAU, 12, Color.BLACK, 1.5, true)
	# il sudore di chi sa come va a finire, ogni volta
	draw_circle(p + Vector2(14, -20), 3.0, Color("#bfe8ff"))


func mostriciattolo(p: Vector2) -> void:
	draw_circle(p, 26.0, MOSTRO)
	draw_rect(Rect2(p + Vector2(-26, 0), Vector2(52, 24)), MOSTRO)
	for k in 2:
		var occhio := p + Vector2(-10 + 20 * k, -8)
		draw_circle(occhio, 7.0, Color.WHITE)
		draw_circle(occhio + Vector2(-2, 1), 3.0, Color.BLACK)
	for k in 4:
		var dente := p + Vector2(-15 + 10 * k, 8)
		draw_colored_polygon(PackedVector2Array([dente, dente + Vector2(8, 0), dente + Vector2(4, 8)]), Color.WHITE)


func mano(dove: Vector2) -> void:
	# il guanto che indica il perno sbagliato, come in ogni pubblicita'
	draw_set_transform(dove, 0.0, Vector2(0.85, 0.85))
	var punta := Vector2.ZERO
	var forma := PackedVector2Array([punta, punta + Vector2(8, -2), punta + Vector2(12, 26), punta + Vector2(30, 24),
			punta + Vector2(40, 36), punta + Vector2(38, 62), punta + Vector2(10, 66), punta + Vector2(2, 44),
			punta + Vector2(-4, 6)])
	draw_colored_polygon(forma, Color.WHITE)
	forma.append(forma[0])
	draw_polyline(forma, Color.BLACK, 2.5, true)
	draw_line(punta + Vector2(20, 26), punta + Vector2(22, 40), Color.BLACK, 1.5, true)
	draw_line(punta + Vector2(30, 28), punta + Vector2(32, 42), Color.BLACK, 1.5, true)
	for k in 3:
		var a := -PI * 0.75 + float(k) * 0.5
		draw_line(punta + Vector2.from_angle(a) * 12.0, punta + Vector2.from_angle(a) * 22.0, Color.WHITE, 3.0, true)
	draw_set_transform(Vector2.ZERO)


func miniatura(fuori: Rect2, gioco: String, nome: String) -> void:
	var guscio := StyleBoxFlat.new()
	guscio.bg_color = Color("#222226")
	guscio.set_corner_radius_all(16)
	guscio.border_color = Color("#55555c")
	guscio.set_border_width_all(1)
	draw_style_box(guscio, fuori)
	var s := fuori.grow(-7)
	match gioco:
		"torre":
			cielo(s, Color("#b46cff"), Color("#5a2aa8"))
			torre_dei_numeri(s)
			urla(Vector2(s.get_center().x, s.position.y + 28), "MANGIA I PIÙ PICCOLI!", 13)
		"porte":
			cielo(s, Color("#8fe36a"), Color("#2f9a3a"))
			porte(s)
			urla(Vector2(s.get_center().x, s.position.y + 28), "SCEGLI LA PORTA!", 15)
		"linea":
			cielo(s, Color("#fff3a8"), Color("#ffc94a"))
			linea(s)
			urla(Vector2(s.get_center().x, s.position.y + 28), "SALVALO IN 10 SECONDI!", 12)
		_:
			cielo(s, Color("#ffb070"), Color("#e8532a"))
			scegli(s)
			urla(Vector2(s.get_center().x, s.position.y + 28), "SOLO UN GENIO!", 15)
	Manifesto.etichetta_tinta(self, Vector2(fuori.position.x, fuori.end.y + 6), nome, 12, tinte["carta"],
			tinte["fondo"])


func torre_dei_numeri(s: Rect2) -> void:
	var piano := s.end.y - 18.0
	var colonna := Rect2(s.position.x + 88, piano - 132, 62, 132)
	draw_rect(colonna, Color("#3a1e6e"))
	var numeri := ["4", "15", "40"]
	for k in 3:
		var stanza := Rect2(colonna.position.x + 4, piano - 44.0 * float(k + 1) + 4, 54, 36)
		draw_rect(stanza, Color("#e9dcff"))
		draw_circle(stanza.get_center() + Vector2(-12, 4), 9.0, Color("#e2364a"))
		urla(stanza.get_center() + Vector2(12, 6), String(numeri[k]), 14)
	var eroe := Rect2(s.position.x + 14, piano - 40, 60, 36)
	draw_rect(eroe, Color("#e9dcff"))
	draw_circle(eroe.get_center() + Vector2(-14, 4), 9.0, Color("#2f80ff"))
	urla(eroe.get_center() + Vector2(12, 6), "9", 14)
	draw_line(eroe.end + Vector2(-4, -18), Vector2(colonna.position.x + 2, eroe.end.y - 18), Color.WHITE, 3.0)


func porte(s: Rect2) -> void:
	var c := s.get_center()
	draw_colored_polygon(PackedVector2Array([Vector2(c.x - 22, s.position.y + 50), Vector2(c.x + 22, s.position.y + 50),
			Vector2(s.end.x - 8, s.end.y), Vector2(s.position.x + 8, s.end.y)]), Color("#c9b48a"))
	var porta_sx := Rect2(c.x - 52, c.y - 12, 46, 30)
	var porta_dx := Rect2(c.x + 6, c.y - 12, 46, 30)
	draw_rect(porta_sx, Color("#2f80ff", 0.85))
	draw_rect(porta_dx, Color("#e2364a", 0.85))
	urla(porta_sx.get_center() + Vector2(0, 7), "x2", 17)
	urla(porta_dx.get_center() + Vector2(0, 7), "-5", 17)
	for k in 14:
		draw_circle(Vector2(c.x - 26 + float(k % 7) * 9.0, s.end.y - 30 + floorf(float(k) / 7.0) * 9.0), 3.5, Color("#2f80ff"))
	for k in 10:
		draw_circle(Vector2(c.x - 16 + float(k % 5) * 8.0, s.position.y + 58 + floorf(float(k) / 5.0) * 7.0), 3.0,
				Color("#e2364a"))


func linea(s: Rect2) -> void:
	var c := s.get_center() + Vector2(0, 30)
	draw_circle(c, 14.0, Color("#c98a4a"))
	draw_circle(c + Vector2(0, -16), 10.0, Color("#c98a4a"))
	draw_circle(c + Vector2(-4, -18), 1.8, Color.BLACK)
	draw_circle(c + Vector2(4, -18), 1.8, Color.BLACK)
	draw_arc(c + Vector2(0, -6), 36.0, PI * 1.05, PI * 1.95, 24, Color.BLACK, 5.0, true)
	for k in 9:
		var ape := s.position + Vector2(118 + float(k % 3) * 12.0 - floorf(float(k) / 3.0) * 14.0, 62 + floorf(float(k) / 3.0) * 14.0)
		draw_circle(ape, 4.0, Color("#ffd23a"))
		draw_line(ape + Vector2(-2, -3), ape + Vector2(-2, 3), Color.BLACK, 1.5)


func scegli(s: Rect2) -> void:
	for k in 3:
		var r := Rect2(s.position.x + 12 + 52.0 * float(k), s.position.y + 64, 42, 42)
		draw_rect(r, Color.WHITE)
		draw_rect(r, Color.BLACK, false, 2.0)
		urla(r.get_center() + Vector2(0, 8), "?", 22)
	omino(s.get_center() + Vector2(0, 40))


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


func cartellino(punto: Vector2, verso: Vector2, nome: String, stato: String, acceso := true) -> void:
	# l'etichetta a didascalia del Vuoto: il filo, il nome chiaro, lo stato sotto
	var tinta: Color = tinte["carta"] if acceso else tinte["inchiostro"]
	var b := punto + verso
	var lungo := maxf(Caratteri.titolo().get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 16.0,
			DisegnoProiezione.larghezza(stato, 10, 420, 85, 2))
	draw_rect(Rect2(b + Vector2(0, -19), Vector2(lungo + 8.0, 35)), Color(tinte["fondo"], 0.72))
	draw_polyline(PackedVector2Array([punto, b, b + Vector2(lungo + 10.0, 0)]), Color(tinta, 0.8), 1.0)
	draw_circle(punto, 1.8, tinta)
	Manifesto.etichetta_tinta(self, b + Vector2(0, -20), nome, 12, tinta, tinte["fondo"])
	scrivi(b + Vector2(4, 12), stato, 10, tinte["inchiostro"] if acceso else Color(tinte["inchiostro"], 0.8), 420, 85, 2)


func cielo(r: Rect2, alto := CIELO_ALTO, basso := CIELO_BASSO) -> void:
	draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
			PackedColorArray([alto, alto, basso, basso]))


func urla(centro: Vector2, testo: String, corpo: int) -> void:
	# la scritta delle pubblicita': bianca, grassa, col bordo nero spesso
	var f := Caratteri.titolo()
	var w := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
	var dove := centro - Vector2(w * 0.5, 0)
	draw_string_outline(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, maxi(4, int(corpo / 5.0)), Color.BLACK)
	draw_string(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Color.WHITE)


func pillola(r: Rect2, testo: String, fondo: Color, inchiostro: Color, corpo: int) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = fondo
	s.set_corner_radius_all(int(r.size.y * 0.5))
	s.shadow_color = Color(0, 0, 0, 0.3)
	s.shadow_offset = Vector2(0, 4)
	draw_style_box(s, r)
	var f := Caratteri.titolo()
	var w := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
	var dove := r.get_center() + Vector2(-w * 0.5, corpo * 0.36)
	if inchiostro == Color.WHITE:
		draw_string_outline(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, 4, Color("#14581d"))
	draw_string(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, inchiostro)


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
