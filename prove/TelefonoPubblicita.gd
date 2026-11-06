extends Control
# UN TELEFONO DEL PIANETA CHE PROMETTE, per le tavole di prove/PropostePianeti.gd.
# Provvisorio come loro: se ne va con la scelta di Bru (docs/pianeti_giochi.md, §8).
#
# Bru, sul primo giro: «i giochi devono essere fatti meglio di come sono ora e
# dobbiamo renderli leggermente diversi». Qui ogni gioco ha una decisione vera,
# che quello delle pubblicita' non ha, e un'idea nostra:
#   perni   le sostanze si mescolano: l'acqua sulla lava fa pietra
#   torre   i mostri crescono a ogni mossa, le pozioni moltiplicano, il buio si guarda
#   corteo  tre elementi che si battono in cerchio
#   tratto  prima vedi da dove arrivano; l'inchiostro e' poco, e si crepa
#   prova   c'e' sempre una ragione, e uno studio per livello
# E in tutti e cinque la mano della pubblicita', che se esiti gioca lei (e
# sbaglia), e l'omino, con lo stress e la speranza come i personaggi degli scontri.
#
# "fase" e' il momento: 0 l'inizio, poi i tre passi della soluzione.
# Si disegna sempre a 360x640, il telefono intero; chi lo usa lo scala.

const SCHERMO := Rect2(14, 14, 332, 612)
const INK := Color("#1c1b2e")
const GUSCIO := Color("#1f1f24")
const PELLE := Color("#ffd2a8")
const MAGLIA := Color("#2f7bff")
const CALZONI := Color("#2b3346")
const CAPELLI := Color("#4a2f1f")
const VIOLA := Color("#8b48d8")
const LAVA := Color("#ff5a1f")
const LAVA_LUCE := Color("#ffb04a")
const ACQUA := Color("#3aa8ff")
const ACQUA_LUCE := Color("#bdeaff")
const PIETRA := Color("#8d919c")
const PIETRA_LUCE := Color("#c9ccd4")
const ORO := Color("#ffd23a")
const ORO_SCURO := Color("#c98d10")
const FUOCO := Color("#ff5a3a")
const NATURA := Color("#3fc25a")
const MURO := Color("#7a5236")
const ROSSO := Color("#ff3b3b")
const ACCIAIO := Color("#dfe3ea")

var gioco := "perni"
var fase := 0


func _init() -> void:
	size = Vector2(360, 640)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	guscio()
	match gioco:
		"perni":
			perni()
		"torre":
			torre()
		"corteo":
			corteo()
		"tratto":
			tratto()
		_:
			prova()
	arrotonda()


# ------------------------------------------------------------------ I PERNI

func perni() -> void:
	cielo(Color("#86dcff"), Color("#2e6fe0"))
	barra_stato(0.15 if fase == 3 else 0.35, 0.6 if fase == 3 else 0.45)
	urla(Vector2(180, 102), "SALVO!" if fase == 3 else "IL 90% SBAGLIA!", 30)
	pillola(180, 116, "LIVELLO 7")
	# le sostanze, prima dei muri: i muri ci stanno davanti
	if fase == 0:
		for k in 15:
			tazo(Vector2(68.0 + 21.0 * float(k % 5) + (10.0 if int(floorf(float(k) / 5.0)) % 2 == 1 else 0.0), 322.0 - 17.0 * floorf(float(k) / 5.0)))
	if fase < 2:
		liquido(Rect2(196, 192, 112, 44), ACQUA, ACQUA_LUCE)
	if fase == 0:
		liquido(Rect2(196, 276, 112, 58), LAVA, LAVA_LUCE)
	elif fase == 1:
		liquido(Rect2(196, 478, 112, 32), LAVA, LAVA_LUCE)
		for p: Vector2 in [Vector2(236, 456), Vector2(262, 446), Vector2(288, 458)]:
			sbuffo(p, 11.0, Color("#5a5a66"))
	else:
		pietra(Rect2(196, 480, 112, 30))
	if fase == 2:
		for p: Vector2 in [Vector2(222, 460), Vector2(254, 448), Vector2(290, 462)]:
			sbuffo(p, 12.0, Color.WHITE)
	# i muri, e la porta d'uscita nel muro di destra
	muro(Rect2(40, 168, 12, 354))
	muro(Rect2(40, 510, 280, 12))
	muro(Rect2(308, 168, 12, 278))
	muro(Rect2(184, 168, 12, 172))
	uscita(Vector2(314, 446))
	# i perni: quelli tirati non ci sono piu'
	if fase < 3:
		perno(Vector2(26, 340), Vector2(186, 340))
		perno(Vector2(190, 540), Vector2(190, 346))
	if fase < 2:
		perno(Vector2(334, 242), Vector2(194, 242))
	if fase < 1:
		perno(Vector2(334, 340), Vector2(194, 340))
	if fase == 0:
		mostro(Vector2(252, 510), "sveglio")
	if fase < 3:
		omino(Vector2(112, 510), "paura")
	else:
		for k in 6:
			tazo(Vector2(96.0 + 30.0 * float(k), 500.0 - 6.0 * float(k % 2)), 7.0)
		omino(Vector2(276, 480), "felice")
		urla(Vector2(200, 400), "+30 TAZO", 18)
		scintilla(Vector2(248, 420), 9.0)
		scintilla(Vector2(304, 410), 7.0)
	if fase == 0:
		guanto(Vector2(190, 540), 0.45, 0.65)


func uscita(soglia: Vector2) -> void:
	# il varco nel muro, col cartello verde
	draw_rect(Rect2(soglia + Vector2(-6, 0), Vector2(12, 64)), Color("#163b2a"))
	var cartello := Rect2(soglia + Vector2(-46, -30), Vector2(40, 18))
	scatola(cartello, Color("#2fbf5a"), 4, 2.0)
	scritta(cartello.get_center() + Vector2(0, 4), "ESCI", 11, Color.WHITE)


func perno(anello: Vector2, punta: Vector2) -> void:
	draw_line(anello, punta, INK, 10.0, true)
	draw_line(anello, punta, ACCIAIO, 6.0, true)
	draw_line(anello, punta, Color("#9aa3b0"), 1.5, true)
	draw_circle(anello, 13.0, INK)
	draw_circle(anello, 10.5, ACCIAIO)
	draw_circle(anello, 5.0, INK)
	draw_circle(anello, 3.0, Color("#9aa3b0"))


func muro(r: Rect2) -> void:
	draw_rect(r.grow(2.5), INK)
	draw_rect(r, MURO)
	draw_line(r.position + Vector2(1, 1.5), Vector2(r.end.x - 1, r.position.y + 1.5), Color("#a77452"), 2.0)


func liquido(r: Rect2, tinta: Color, luce: Color) -> void:
	var pelo := PackedVector2Array()
	for i in 13:
		pelo.append(Vector2(lerpf(r.position.x, r.end.x, float(i) / 12.0), r.position.y + 4.0 * sin(float(i) * 1.4)))
	var punti := pelo.duplicate()
	punti.append(r.end)
	punti.append(Vector2(r.position.x, r.end.y))
	draw_colored_polygon(punti, tinta)
	draw_polyline(pelo, luce, 3.0, true)
	for k in 4:
		draw_arc(r.position + Vector2(18.0 + 26.0 * float(k), r.size.y * (0.45 + 0.15 * float(k % 2))), 3.0, 0.0, TAU, 10,
				Color(luce, 0.8), 1.5, true)


func pietra(r: Rect2) -> void:
	# l'acqua sulla lava: blocchi di pietra, sfalsati, su cui si cammina
	var y := r.position.y
	var riga := 0
	while y < r.end.y - 1.0:
		var x := r.position.x - (13.0 if riga % 2 == 1 else 0.0)
		while x < r.end.x:
			var blocco := Rect2(Vector2(maxf(x, r.position.x), y), Vector2(minf(x + 26.0, r.end.x) - maxf(x, r.position.x), 15))
			draw_rect(blocco, PIETRA)
			draw_line(blocco.position + Vector2(2, 2), Vector2(blocco.end.x - 2, blocco.position.y + 2), PIETRA_LUCE, 2.0)
			draw_rect(blocco, INK, false, 2.0)
			x += 26.0
		y += 15.0
		riga += 1


# --------------------------------------------------------------- LA TORRE

func torre() -> void:
	cielo(Color("#c896ff"), Color("#5b2bb0"))
	barra_stato(0.3, 0.6 if fase == 3 else 0.45)
	urla(Vector2(180, 100), "IN CIMA!" if fase == 3 else "SOLO L'1% ARRIVA IN CIMA!", 30 if fase == 3 else 21)
	pillola(180, 116, "LIVELLO 12")
	draw_rect(Rect2(14, 560, 332, 20), Color("#3e9e4c"))
	draw_line(Vector2(14, 560), Vector2(346, 560), INK, 2.5)
	# le due torri
	corpo_di_torre(Rect2(40, 404, 112, 156), Vector2(96, 352))
	corpo_di_torre(Rect2(172, 268, 148, 292), Vector2(246, 206))
	var stanze := {"trappola": Rect2(48, 414, 96, 62), "eroe": Rect2(48, 488, 96, 62), "a": Rect2(180, 488, 132, 62),
			"b": Rect2(180, 418, 132, 62), "c": Rect2(180, 348, 132, 62), "d": Rect2(180, 278, 132, 62)}
	for quale: String in stanze:
		stanza(stanze[quale], quale == "b" and fase < 2)
	# dove sta l'eroe, e quanto vale, momento per momento
	var dove := ["eroe", "a", "b", "d"][fase] as String
	var vale := ["9", "13", "21", "42"][fase] as String
	var cima := ["30", "31", "32", "33"][fase] as String
	trappola(stanze["trappola"])
	if fase < 1:
		mostro(Vector2(232, 548), "sveglio", 0.5, Color("#e2364a"))
		numero(Vector2(288, 504), "4", Color("#e2364a"))
		piu_uno(Vector2(306, 486))
	if fase < 2:
		buio(stanze["b"])
	if fase < 3:
		pozione(Vector2(232, 404))
		mostro(Vector2(232, 338), "sveglio", 0.62, Color("#b0182c"))
		corona(Vector2(232, 300))
		numero(Vector2(288, 296), cima, Color("#b0182c"), 18)
		if fase > 0:
			piu_uno(Vector2(310, 278))
	var stanza_eroe: Rect2 = stanze[dove]
	omino(Vector2(stanza_eroe.position.x + 38.0, stanza_eroe.end.y - 2.0), "felice" if fase == 3 else "calmo", 0.6)
	numero(Vector2(stanza_eroe.end.x - 24.0, stanza_eroe.position.y + 16.0), vale, MAGLIA, 18 if fase < 3 else 22)
	if fase == 3:
		corona(Vector2(stanza_eroe.position.x + 38.0, stanza_eroe.position.y + 4.0))
		scintilla(Vector2(300, 250), 10.0)
	var barra := barra_sotto("OCCHIATE")
	for k in 2:
		occhio(Vector2(barra.position.x + 112.0 + 34.0 * float(k), barra.get_center().y), k == 0 or fase < 2)
	scritta(Vector2(barra.end.x - 64.0, barra.get_center().y + 5.0), "MOSSA %d" % [0, 1, 2, 4][fase], 12, INK)
	if fase == 0:
		guanto(Vector2(300, 304), 2.75, 0.55)


func corpo_di_torre(r: Rect2, cima: Vector2) -> void:
	draw_rect(r.grow(2.5), INK)
	draw_rect(r, Color("#9a86d6"))
	for k in int(r.size.y / 14.0):
		var y := r.position.y + 14.0 * float(k)
		draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), Color("#8371c4"), 1.0)
	var tetto := PackedVector2Array([Vector2(r.position.x - 8.0, r.position.y), Vector2(r.end.x + 8.0, r.position.y), cima])
	draw_colored_polygon(tetto, Color("#e2364a"))
	tetto.append(tetto[0])
	draw_polyline(tetto, INK, 3.0, true)


func stanza(r: Rect2, scura: bool) -> void:
	draw_rect(r, Color("#3a2c5a") if scura else Color("#f3ecff"))
	draw_rect(r, INK, false, 2.5)


func buio(r: Rect2) -> void:
	# la stanza al buio: si sa che c'e' qualcosa, non quanto vale
	scritta(r.get_center() + Vector2(0, 12), "?", 34, Color(1, 1, 1, 0.9))
	occhio(r.position + Vector2(r.size.x - 18.0, 14), true, 0.7)


func trappola(r: Rect2) -> void:
	for k in 6:
		var x := r.position.x + 8.0 + 14.0 * float(k)
		var punta := PackedVector2Array([Vector2(x, r.end.y - 2), Vector2(x + 7, r.end.y - 18), Vector2(x + 14, r.end.y - 2)])
		draw_colored_polygon(punta, Color("#d9dce3"))
		punta.append(punta[0])
		draw_polyline(punta, INK, 1.5, true)
	numero(r.get_center() + Vector2(0, -10), "÷2", Color("#5a5a66"), 16)


func pozione(fondo: Vector2) -> void:
	var collo := Rect2(fondo + Vector2(-6, -44), Vector2(12, 12))
	draw_rect(collo.grow(2.5), INK)
	draw_rect(collo, Color("#bfe9ff"))
	draw_circle(fondo + Vector2(0, -18), 18.5, INK)
	draw_circle(fondo + Vector2(0, -18), 16.0, Color("#bfe9ff"))
	draw_circle(fondo + Vector2(0, -14), 12.0, NATURA)
	draw_circle(fondo + Vector2(-5, -22), 3.0, Color(1, 1, 1, 0.8))
	draw_rect(Rect2(fondo + Vector2(-7, -50), Vector2(14, 7)), Color("#a06a3a"))
	numero(fondo + Vector2(48, -32), "×2", Color("#2a9a48"), 16)


func corona(base: Vector2) -> void:
	var punti := PackedVector2Array([base + Vector2(-14, 0), base + Vector2(-16, -16), base + Vector2(-7, -8),
			base + Vector2(0, -20), base + Vector2(7, -8), base + Vector2(16, -16), base + Vector2(14, 0)])
	draw_colored_polygon(punti, ORO)
	punti.append(punti[0])
	draw_polyline(punti, INK, 2.5, true)


func piu_uno(dove: Vector2) -> void:
	scatola(Rect2(dove - Vector2(14, 9), Vector2(28, 18)), Color("#2fbf5a"), 9, 2.0)
	scritta(dove + Vector2(0, 4), "+1", 11, Color.WHITE)


# --------------------------------------------------------------- IL CORTEO

func corteo() -> void:
	draw_polygon(PackedVector2Array([SCHERMO.position, Vector2(346, 14), Vector2(346, 200), Vector2(14, 200)]),
			PackedColorArray([Color("#c8ecff"), Color("#c8ecff"), Color("#8fd3ff"), Color("#8fd3ff")]))
	draw_polygon(PackedVector2Array([Vector2(14, 200), Vector2(346, 200), Vector2(346, 626), Vector2(14, 626)]),
			PackedColorArray([Color("#86d672"), Color("#86d672"), Color("#3e9e4c"), Color("#3e9e4c")]))
	var strada := PackedVector2Array([Vector2(146, 190), Vector2(214, 190), Vector2(330, 626), Vector2(30, 626)])
	draw_colored_polygon(strada, Color("#ecd39f"))
	strada.append(strada[0])
	draw_polyline(strada, INK, 2.5, true)
	barra_stato(0.25, 0.6 if fase == 3 else 0.45)
	urla(Vector2(180, 100), "VITTORIA!" if fase == 3 else "SCEGLI LA PORTA GIUSTA!", 30 if fase == 3 else 22)
	pillola(180, 116, "LIVELLO 5")
	# chi aspetta in fondo: trenta d'acqua
	folla(Vector2(180, 214), {"acqua": 30}, 0.85)
	numero(Vector2(180, 168), "30", ACQUA, 16)
	icona("acqua", Vector2(146, 168), 7.0)
	# le porte: in alto piccole, in basso grandi (la strada va via)
	porta(Rect2(122, 272, 56, 32), "", ACQUA, NATURA, "acqua", "natura")
	porta(Rect2(184, 272, 56, 32), "-5", Color("#e2364a"), Color("#e2364a"), "", "")
	porta(Rect2(88, 392, 88, 46), "+10", FUOCO, FUOCO, "fuoco", "")
	porta(Rect2(184, 392, 88, 46), "×2", NATURA, NATURA, "natura", "")
	var squadra: Dictionary = [{"fuoco": 12, "acqua": 8, "natura": 5}, {"fuoco": 12, "acqua": 8, "natura": 10},
			{"fuoco": 12, "natura": 18}, {"fuoco": 12, "natura": 18}][fase]
	var dove: Vector2 = [Vector2(180, 520), Vector2(196, 352), Vector2(176, 238), Vector2(180, 226)][fase]
	folla(dove, squadra, [1.0, 0.8, 0.62, 0.62][fase])
	if fase == 3:
		var esito := Rect2(84, 334, 192, 40)
		scatola(esito, Color.WHITE, 12, 2.5)
		icona("natura", esito.position + Vector2(22, 20), 9.0)
		scritta(esito.get_center() + Vector2(10, 6), "18 ×2 = 36 > 30", 16, INK)
		scintilla(Vector2(80, 200), 9.0)
		scintilla(Vector2(284, 196), 8.0)
	var barra := barra_sotto("")
	var x := barra.position.x + 18.0
	for elemento: String in ["fuoco", "acqua", "natura"]:
		icona(elemento, Vector2(x, barra.get_center().y), 8.0)
		scritta(Vector2(x + 20.0, barra.get_center().y + 5.0), str(int(squadra.get(elemento, 0))), 13, INK)
		x += 46.0
	chi_batte_chi(Vector2(barra.end.x - 136.0, barra.get_center().y))
	if fase == 0:
		guanto(Vector2(98, 436), 0.55, 0.55)


func porta(r: Rect2, testo: String, da: Color, a: Color, icona_da: String, icona_a: String) -> void:
	draw_line(Vector2(r.position.x + 4, r.end.y), Vector2(r.position.x + 4, r.end.y + r.size.y * 0.7), INK, 3.0)
	draw_line(Vector2(r.end.x - 4, r.end.y), Vector2(r.end.x - 4, r.end.y + r.size.y * 0.7), INK, 3.0)
	var sinistra := Rect2(r.position, Vector2(r.size.x * 0.5, r.size.y))
	draw_rect(sinistra, Color(da, 0.9))
	draw_rect(Rect2(r.position + Vector2(r.size.x * 0.5, 0), Vector2(r.size.x * 0.5, r.size.y)), Color(a, 0.9))
	draw_rect(r, INK, false, 2.5)
	var c := r.get_center()
	if testo == "":
		# la porta che cambia un elemento in un altro
		icona(icona_da, c + Vector2(-r.size.x * 0.26, 0), r.size.y * 0.22)
		draw_line(c + Vector2(-5, 0), c + Vector2(5, 0), Color.WHITE, 2.5)
		draw_colored_polygon(PackedVector2Array([c + Vector2(4, -5), c + Vector2(10, 0), c + Vector2(4, 5)]), Color.WHITE)
		icona(icona_a, c + Vector2(r.size.x * 0.26, 0), r.size.y * 0.22)
		return
	var corpo := int(r.size.y * 0.5)
	if icona_da != "":
		icona(icona_da, c + Vector2(-r.size.x * 0.3, 0), r.size.y * 0.2)
		scritta(c + Vector2(r.size.x * 0.1, corpo * 0.36), testo, corpo, Color.WHITE, true)
	else:
		scritta(c + Vector2(0, corpo * 0.36), testo, corpo, Color.WHITE, true)


func folla(centro: Vector2, quanti: Dictionary, scala: float) -> void:
	# un omino ogni due, in un mucchio che non cambia forma da un fotogramma all'altro
	var tutti: Array[String] = []
	for elemento: String in quanti:
		for k in int(ceilf(float(quanti[elemento]) / 2.0)):
			tutti.append(elemento)
	var tinte := {"fuoco": FUOCO, "acqua": ACQUA, "natura": NATURA}
	var colonne := 9
	for i in tutti.size():
		var riga := floorf(float(i) / float(colonne))
		var p := centro + Vector2((float(i % colonne) - 4.0 + (0.5 if int(riga) % 2 == 1 else 0.0)) * 13.0,
				(riga - 1.0) * 12.0) * scala
		p += Vector2(sin(float(i) * 12.9898) * 2.0, cos(float(i) * 78.233) * 2.0)
		draw_circle(p, 6.5 * scala, INK)
		draw_circle(p, 5.0 * scala, tinte[tutti[i]])
		draw_circle(p + Vector2(-1.5, -1.5) * scala, 1.5 * scala, Color(1, 1, 1, 0.7))


func chi_batte_chi(inizio: Vector2) -> void:
	# fuoco batte natura, natura batte acqua, acqua batte fuoco: in fila, col
	# primo ripetuto in fondo perche' il giro si chiuda
	var fila := ["fuoco", "natura", "acqua", "fuoco"]
	for k in fila.size():
		var c := inizio + Vector2(34.0 * float(k), 0)
		icona(String(fila[k]), c, 8.0)
		if k < fila.size() - 1:
			var punta := c + Vector2(21, 0)
			draw_colored_polygon(PackedVector2Array([punta + Vector2(-5, -6), punta + Vector2(3, 0), punta + Vector2(-5, 6)]), INK)


# --------------------------------------------------------------- IL TRATTO

func tratto() -> void:
	cielo(Color("#fff4b0"), Color("#ffc94a"))
	barra_stato(0.5 if fase < 3 else 0.2, 0.6 if fase == 3 else 0.45)
	urla(Vector2(180, 100), "CE L'HAI FATTA!" if fase == 3 else "SALVALO IN 10 SECONDI!", 26 if fase == 3 else 22)
	pillola(180, 116, "LIVELLO 9")
	var collina := PackedVector2Array()
	for i in 25:
		var a := PI + PI * float(i) / 24.0
		collina.append(Vector2(180, 640) + Vector2(cos(a) * 230.0, sin(a) * 120.0))
	for pezzo in Geometry2D.intersect_polygons(collina, schermo_poligono()):
		draw_colored_polygon(pezzo, Color("#5cc46a"))
	draw_line(Vector2(346, 176), Vector2(240, 196), INK, 9.0, true)
	draw_line(Vector2(346, 176), Vector2(240, 196), Color("#8a5a3a"), 6.0, true)
	alveare(Vector2(266, 226))
	var omino_qui := Vector2(180, 520)
	if fase < 2:
		# i tre secondi in cui si vede da dove arriveranno
		traiettoria([Vector2(252, 256), Vector2(236, 330), Vector2(206, 420)])
		traiettoria([Vector2(290, 252), Vector2(330, 340), Vector2(222, 470)])
		var conto := Vector2(204, 252)
		draw_circle(conto, 16.0, INK)
		draw_circle(conto, 13.5, Color.WHITE)
		scritta(conto + Vector2(0, 6), "3", 18, INK)
	var arco := PackedVector2Array()
	for i in 21:
		arco.append(omino_qui + Vector2(0, -50) + Vector2.from_angle(lerpf(-2.2, 0.35, float(i) / 20.0)) * 78.0)
	if fase >= 2:
		draw_polyline(arco, INK, 10.0, true)
		draw_circle(arco[0], 5.0, INK)
		draw_circle(arco[arco.size() - 1], 5.0, INK)
	if fase == 3:
		for k: int in [6, 13]:
			crepa(arco[k], (arco[k + 1] - arco[k]).normalized().orthogonal())
		for k: int in [4, 9, 14, 17]:
			var fuori := arco[k] + (arco[k] - (omino_qui + Vector2(0, -50))).normalized() * 18.0
			ape(fuori)
			scintilla(arco[k] + (fuori - arco[k]) * 0.45, 5.0)
	else:
		for p: Vector2 in [Vector2(238, 250), Vector2(292, 246), Vector2(300, 276)]:
			ape(p)
	omino(omino_qui, "felice" if fase == 3 else "paura")
	var barra := barra_sotto("INCHIOSTRO")
	var resto := 1.0 if fase < 2 else 0.55
	var tubo := Rect2(barra.position.x + 124.0, barra.get_center().y - 7.0, 120.0, 14.0)
	draw_rect(tubo, Color("#e6e6ee"))
	draw_rect(Rect2(tubo.position, Vector2(tubo.size.x * resto, tubo.size.y)), INK)
	draw_rect(tubo, INK, false, 2.0)
	scritta(Vector2(barra.end.x - 26.0, barra.get_center().y + 5.0), "0 s" if fase == 3 else "10 s", 12, INK)
	if fase == 0:
		guanto(Vector2(88, 438), 0.3, 0.5)


func alveare(c: Vector2) -> void:
	draw_line(c + Vector2(0, -30), c + Vector2(0, -18), INK, 3.0)
	for k in 4:
		var r := Vector2(26.0 - 3.0 * absf(float(k) - 1.5) * 2.0, 9.0)
		var centro := c + Vector2(0, -12.0 + 12.0 * float(k))
		ovale(centro, r, Color("#e9a93a"))
	draw_circle(c + Vector2(0, 14), 6.0, INK)


func traiettoria(punti: Array) -> void:
	# la strada delle api, tratteggiata, con la punta
	var curva := Curve2D.new()
	curva.add_point(punti[0], Vector2.ZERO, (punti[1] - punti[0]) * 0.5)
	curva.add_point(punti[2], (punti[1] - punti[2]) * 0.5, Vector2.ZERO)
	curva.bake_interval = 7.0
	var linea_api := curva.get_baked_points()
	for i in linea_api.size() - 1:
		if i % 2 == 0:
			draw_line(linea_api[i], linea_api[i + 1], ROSSO, 3.0, true)
	var fine := linea_api[linea_api.size() - 1]
	var verso := (fine - linea_api[linea_api.size() - 2]).normalized()
	draw_colored_polygon(PackedVector2Array([fine + verso * 6.0, fine - verso * 6.0 + verso.orthogonal() * 6.0,
			fine - verso * 6.0 - verso.orthogonal() * 6.0]), ROSSO)


func ape(c: Vector2) -> void:
	ovale(c + Vector2(-3, -6), Vector2(5, 3.5), Color(1, 1, 1, 0.85))
	ovale(c + Vector2(3, -6), Vector2(5, 3.5), Color(1, 1, 1, 0.85))
	ovale(c, Vector2(8, 6), ORO)
	draw_line(c + Vector2(-2, -5), c + Vector2(-2, 5), INK, 2.0)
	draw_line(c + Vector2(3, -5), c + Vector2(3, 5), INK, 2.0)


func crepa(dove: Vector2, di_lato: Vector2) -> void:
	var lungo := di_lato.orthogonal()
	draw_polyline(PackedVector2Array([dove - di_lato * 7.0, dove - di_lato * 2.0 + lungo * 3.0, dove + di_lato * 2.0 - lungo * 2.0,
			dove + di_lato * 7.0]), Color.WHITE, 2.0, true)


# --------------------------------------------------------------- LA PROVA

func prova() -> void:
	draw_polygon(PackedVector2Array([SCHERMO.position, Vector2(346, 14), Vector2(346, 470), Vector2(14, 470)]),
			PackedColorArray([Color("#f8e2b8"), Color("#f8e2b8"), Color("#e9c48a"), Color("#e9c48a")]))
	draw_rect(Rect2(14, 470, 332, 156), Color("#b9784a"))
	for k in 6:
		draw_line(Vector2(14, 470 + 26 * k), Vector2(346, 470 + 26 * k), Color("#9a6038"), 2.0)
	draw_line(Vector2(14, 470), Vector2(346, 470), INK, 2.5)
	barra_stato(0.3, 0.6 if fase == 3 else 0.45)
	urla(Vector2(180, 100), "GENIO!" if fase == 3 else "SOLO UN GENIO!", 30)
	pillola(180, 116, "LIVELLO 4")
	porta_chiusa(Rect2(246, 290, 82, 180), fase == 3)
	# il mostro dorme, e al collo ha la chiave vera: chi guarda la vede
	mostro(Vector2(172, 470), "contento" if fase >= 2 else "dorme", 1.3)
	draw_line(Vector2(136, 444), Vector2(208, 444), INK, 9.0)
	draw_line(Vector2(136, 444), Vector2(208, 444), Color("#d8263c"), 5.0)
	if fase < 3:
		chiave(Vector2(172, 458), ORO, 0.85)
	if fase < 2:
		scritta(Vector2(222, 370), "z", 18, INK)
		scritta(Vector2(236, 348), "Z", 24, INK)
	if fase >= 2:
		osso(Vector2(150, 422), 0.9)
	if fase == 3:
		omino(Vector2(262, 470), "felice")
		chiave(Vector2(298, 396), ORO, 0.9)
		scintilla(Vector2(320, 380), 9.0)
	else:
		omino(Vector2(62, 470), "calmo")
		if fase == 0:
			nuvoletta(Vector2(98, 330))
	# il vassoio dei tre oggetti
	var carte := [Rect2(36, 494, 82, 72), Rect2(139, 494, 82, 72), Rect2(242, 494, 82, 72)]
	for k in 3:
		scatola(carte[k], Color.WHITE, 12, 2.5)
	chiave(carte[0].get_center(), Color("#b8642a"), 1.0, true)
	if fase < 2:
		osso(carte[1].get_center(), 1.0)
	trombetta(carte[2].get_center())
	if fase == 1:
		lente(carte[0].get_center() + Vector2(18, -10))
		var cartellino := Rect2(30, 538, 94, 34)
		scatola(cartellino, INK, 8, 0.0)
		scritta(cartellino.get_center() + Vector2(0, -2), "ARRUGGINITA:", 11, Color.WHITE)
		scritta(cartellino.get_center() + Vector2(0, 11), "SI SPEZZA", 11, ORO)
	var barra := barra_sotto("STUDIO")
	occhio(Vector2(barra.position.x + 100.0, barra.get_center().y), fase == 0)
	if fase == 0:
		guanto(Vector2(300, 498), -2.7, 0.6)


func porta_chiusa(r: Rect2, aperta: bool) -> void:
	draw_rect(r.grow(2.5), INK)
	if aperta:
		draw_rect(r, Color("#2a2033"))
		draw_polygon(PackedVector2Array([r.position, r.position + Vector2(r.size.x, 0), r.end, Vector2(r.position.x, r.end.y)]),
				PackedColorArray([Color("#fff7c2", 0.0), Color("#fff7c2", 0.0), Color("#fff7c2", 0.55), Color("#fff7c2", 0.55)]))
		return
	draw_rect(r, Color("#8a5a3a"))
	draw_rect(Rect2(r.position + Vector2(10, 12), Vector2(r.size.x - 20, 56)), INK, false, 2.0)
	draw_rect(Rect2(r.position + Vector2(10, 80), Vector2(r.size.x - 20, 60)), INK, false, 2.0)
	var lucchetto := r.position + Vector2(r.size.x * 0.5, 82)
	draw_arc(lucchetto + Vector2(0, -2), 8.0, PI, TAU, 12, INK, 4.0)
	scatola(Rect2(lucchetto + Vector2(-11, -2), Vector2(22, 18)), ORO, 4, 2.0)


func chiave(c: Vector2, tinta: Color, scala: float, ruggine := false) -> void:
	var testa := c + Vector2(-14, 0) * scala
	draw_circle(testa, 10.5 * scala, INK)
	draw_circle(testa, 8.0 * scala, tinta)
	draw_circle(testa, 3.5 * scala, Color.WHITE)
	draw_rect(Rect2(testa + Vector2(6, -3.5) * scala, Vector2(26, 7) * scala), INK)
	draw_rect(Rect2(testa + Vector2(7, -2) * scala, Vector2(24, 4) * scala), tinta)
	draw_rect(Rect2(testa + Vector2(24, 2) * scala, Vector2(5, 8) * scala), INK)
	draw_rect(Rect2(testa + Vector2(16, 2) * scala, Vector2(4, 6) * scala), INK)
	if ruggine:
		for p: Vector2 in [Vector2(-3, -4), Vector2(4, 3), Vector2(20, -1), Vector2(-16, 4)]:
			draw_circle(c + p * scala, 2.0 * scala, Color("#6b3412"))


func osso(c: Vector2, scala: float) -> void:
	for p: Vector2 in [Vector2(-16, -5), Vector2(-16, 5), Vector2(16, -5), Vector2(16, 5)]:
		draw_circle(c + p * scala, 7.5 * scala, INK)
	draw_rect(Rect2(c + Vector2(-16, -6.5) * scala, Vector2(32, 13) * scala), INK)
	for p: Vector2 in [Vector2(-16, -5), Vector2(-16, 5), Vector2(16, -5), Vector2(16, 5)]:
		draw_circle(c + p * scala, 5.5 * scala, Color("#fbf6ea"))
	draw_rect(Rect2(c + Vector2(-16, -4.5) * scala, Vector2(32, 9) * scala), Color("#fbf6ea"))


func trombetta(c: Vector2) -> void:
	var campana := PackedVector2Array([c + Vector2(4, -6), c + Vector2(24, -18), c + Vector2(24, 18), c + Vector2(4, 6)])
	draw_rect(Rect2(c + Vector2(-26, -5), Vector2(32, 10)).grow(2.5), INK)
	draw_rect(Rect2(c + Vector2(-26, -5), Vector2(32, 10)), ORO)
	draw_colored_polygon(campana, ORO)
	campana.append(campana[0])
	draw_polyline(campana, INK, 2.5, true)
	draw_circle(c + Vector2(-26, 0), 5.0, ORO_SCURO)


func lente(c: Vector2) -> void:
	draw_line(c + Vector2(10, 10), c + Vector2(24, 24), INK, 6.0, true)
	draw_circle(c, 15.0, INK)
	draw_circle(c, 12.0, Color(0.85, 0.95, 1.0, 0.6))


func nuvoletta(c: Vector2) -> void:
	draw_circle(c + Vector2(-30, 38), 4.0, INK)
	draw_circle(c + Vector2(-22, 28), 6.0, INK)
	ovale(c, Vector2(24, 19), Color.WHITE)
	scritta(c + Vector2(0, 8), "?", 22, INK)


# ------------------------------------------------- i pezzi di tutti e cinque

func guscio() -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = GUSCIO
	s.set_corner_radius_all(36)
	s.border_color = Color("#50505a")
	s.set_border_width_all(2)
	draw_style_box(s, Rect2(Vector2.ZERO, Vector2(360, 640)))


func arrotonda() -> void:
	# lo schermo ha gli angoli tondi: si coprono gli spigoli col colore del guscio
	var r := 24.0
	var spigoli := [SCHERMO.position, Vector2(SCHERMO.end.x, SCHERMO.position.y), SCHERMO.end,
			Vector2(SCHERMO.position.x, SCHERMO.end.y)]
	var versi := [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
	var inizi := [PI, PI * 1.5, 0.0, PI * 0.5]
	for k in 4:
		var spigolo: Vector2 = spigoli[k]
		var centro: Vector2 = spigolo + (versi[k] as Vector2) * r
		var punti := PackedVector2Array([spigolo])
		for i in 9:
			punti.append(centro + Vector2.from_angle(float(inizi[k]) + PI * 0.5 * float(i) / 8.0) * r)
		draw_colored_polygon(punti, GUSCIO)


func schermo_poligono() -> PackedVector2Array:
	return PackedVector2Array([SCHERMO.position, Vector2(SCHERMO.end.x, SCHERMO.position.y), SCHERMO.end,
			Vector2(SCHERMO.position.x, SCHERMO.end.y)])


func cielo(alto: Color, basso: Color) -> void:
	draw_polygon(schermo_poligono(), PackedColorArray([alto, alto, basso, basso]))
	# i raggi da pubblicita', tagliati sullo schermo
	var centro := Vector2(180, 150)
	for k in 18:
		if k % 2 == 1:
			continue
		var raggio := PackedVector2Array([centro, centro + Vector2.from_angle(TAU * float(k) / 18.0) * 800.0,
				centro + Vector2.from_angle(TAU * float(k + 1) / 18.0) * 800.0])
		for pezzo in Geometry2D.intersect_polygons(raggio, schermo_poligono()):
			draw_colored_polygon(pezzo, Color(1, 1, 1, 0.08))


func barra_stato(stress: float, speranza: float) -> void:
	# L'OMINO E' LO STESSO IN TUTTI E CINQUE: lo stress sale a ogni sbaglio, la
	# speranza a ogni vittoria, come per i personaggi degli scontri
	var r := Rect2(24, 24, 312, 32)
	scatola(r, Color(1, 1, 1, 0.92), 16, 2.0)
	faccina(r.position + Vector2(18, 16), "paura" if stress >= 0.5 else "calmo")
	var tacche := [["STRESS", stress, ROSSO, 38.0], ["SPERANZA", speranza, ORO, 176.0]]
	for t: Array in tacche:
		var x := r.position.x + float(t[3])
		scritta(Vector2(x, r.position.y + 21), String(t[0]), 10, INK, false, false)
		var tubo := Rect2(x + (50.0 if String(t[0]) == "STRESS" else 64.0), r.position.y + 10, 60, 12)
		draw_rect(tubo, Color("#ececf2"))
		draw_rect(Rect2(tubo.position, Vector2(tubo.size.x * float(t[1]), tubo.size.y)), t[2])
		draw_rect(tubo, INK, false, 1.5)


func faccina(c: Vector2, umore: String) -> void:
	draw_circle(c, 11.5, INK)
	draw_circle(c, 9.5, PELLE)
	draw_circle(c + Vector2(-3.5, -1.5), 1.6, INK)
	draw_circle(c + Vector2(3.5, -1.5), 1.6, INK)
	if umore == "paura":
		draw_circle(c + Vector2(0, 4), 2.2, INK)
		draw_circle(c + Vector2(9, -7), 2.5, Color("#7fd0ff"))
	else:
		draw_arc(c + Vector2(0, 2), 4.0, 0.3, PI - 0.3, 8, INK, 1.5, true)


func barra_sotto(testo: String) -> Rect2:
	var r := Rect2(24, 578, 312, 38)
	scatola(r, Color(1, 1, 1, 0.92), 19, 2.0)
	if testo != "":
		scritta(Vector2(r.position.x + 16, r.get_center().y + 5), testo, 12, INK, false, false)
	return r


func scatola(r: Rect2, tinta: Color, raggio: int, bordo: float) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = tinta
	s.set_corner_radius_all(raggio)
	s.anti_aliasing = true
	if bordo > 0.0:
		s.border_color = INK
		s.set_border_width_all(int(bordo))
	draw_style_box(s, r)


func scritta(dove: Vector2, testo: String, corpo: int, tinta: Color, bordata := false, centrata := true) -> void:
	var f := Caratteri.titolo()
	var x := dove.x - (f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x * 0.5 if centrata else 0.0)
	if bordata:
		draw_string_outline(f, Vector2(x, dove.y), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, maxi(3, int(corpo / 5.0)), INK)
	draw_string(f, Vector2(x, dove.y), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, tinta)


func urla(centro: Vector2, testo: String, corpo: int) -> void:
	# la scritta delle pubblicita': bianca, grassa, il bordo spesso e l'ombra sotto
	var f := Caratteri.titolo()
	var dove := centro - Vector2(f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x * 0.5, 0)
	var spessore := maxi(4, int(corpo / 4.5))
	draw_string_outline(f, dove + Vector2(0, 3), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, spessore, Color(INK, 0.35))
	draw_string_outline(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, spessore, INK)
	draw_string(f, dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Color.WHITE)


func pillola(centro_x: float, y: float, testo: String) -> void:
	var f := Caratteri.titolo()
	var w := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 28.0
	scatola(Rect2(centro_x - w * 0.5, y, w, 22), Color.WHITE, 11, 2.0)
	scritta(Vector2(centro_x, y + 15.5), testo, 12, INK)


func numero(c: Vector2, testo: String, fondo: Color, corpo := 18) -> void:
	var f := Caratteri.titolo()
	var w := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
	scatola(Rect2(c - Vector2(w * 0.5 + 9.0, corpo * 0.72), Vector2(w + 18.0, corpo * 1.44)), fondo,
			int(corpo * 0.72), 2.5)
	scritta(c + Vector2(0, corpo * 0.36), testo, corpo, Color.WHITE, true)


func occhio(c: Vector2, acceso: bool, scala := 1.0) -> void:
	var mandorla := PackedVector2Array()
	for i in 17:
		var t := float(i) / 16.0
		mandorla.append(c + Vector2(lerpf(-14, 14, t), -sin(t * PI) * 9.0) * scala)
	for i in range(1, 16):
		var t := 1.0 - float(i) / 16.0
		mandorla.append(c + Vector2(lerpf(-14, 14, t), sin(t * PI) * 9.0) * scala)
	draw_colored_polygon(mandorla, Color.WHITE if acceso else Color("#c9c9d4"))
	mandorla.append(mandorla[0])
	draw_polyline(mandorla, INK, 2.0, true)
	draw_circle(c, 5.5 * scala, MAGLIA if acceso else Color("#8a8a99"))
	draw_circle(c, 2.5 * scala, INK)


func ovale(c: Vector2, r: Vector2, tinta: Color) -> void:
	var punti := PackedVector2Array()
	for i in 24:
		punti.append(c + Vector2(cos(TAU * float(i) / 24.0) * r.x, sin(TAU * float(i) / 24.0) * r.y))
	draw_colored_polygon(punti, tinta)
	punti.append(punti[0])
	draw_polyline(punti, INK, 2.0, true)


func tazo(c: Vector2, r := 9.0) -> void:
	draw_circle(c, r + 2.5, INK)
	draw_circle(c, r, ORO)
	draw_arc(c, r * 0.58, 0.0, TAU, 16, ORO_SCURO, 2.0, true)
	draw_arc(c, r * 0.8, PI * 1.1, PI * 1.5, 8, Color(1, 1, 1, 0.8), 1.5, true)


func sbuffo(c: Vector2, r: float, tinta: Color) -> void:
	for p: Vector2 in [Vector2(-r * 0.7, 0), Vector2(r * 0.7, 0), Vector2(0, -r * 0.6)]:
		draw_circle(c + p, r * 0.75 + 2.0, INK)
	for p: Vector2 in [Vector2(-r * 0.7, 0), Vector2(r * 0.7, 0), Vector2(0, -r * 0.6)]:
		draw_circle(c + p, r * 0.75, tinta)


func scintilla(c: Vector2, r: float) -> void:
	var punti := PackedVector2Array()
	for i in 8:
		punti.append(c + Vector2.from_angle(PI * 0.25 * float(i) - PI * 0.5) * (r if i % 2 == 0 else r * 0.35))
	draw_colored_polygon(punti, Color.WHITE)
	punti.append(punti[0])
	draw_polyline(punti, INK, 1.5, true)


func icona(elemento: String, c: Vector2, r: float) -> void:
	# fuoco e acqua: una goccia (in su il fuoco, con la fiamma dentro); natura: una foglia
	if elemento == "natura":
		var foglia := PackedVector2Array()
		for i in 13:
			var t := float(i) / 12.0
			foglia.append(c + Vector2(lerpf(-r, r, t), lerpf(r * 0.6, -r * 0.6, t)) + Vector2(1, 1) * sin(t * PI) * r * 0.45)
		for i in range(1, 12):
			var t := 1.0 - float(i) / 12.0
			foglia.append(c + Vector2(lerpf(-r, r, t), lerpf(r * 0.6, -r * 0.6, t)) - Vector2(1, 1) * sin(t * PI) * r * 0.45)
		draw_colored_polygon(foglia, NATURA)
		foglia.append(foglia[0])
		draw_polyline(foglia, INK, 1.5, true)
		draw_line(c + Vector2(-r, r * 0.6), c + Vector2(r * 0.6, -r * 0.35), INK, 1.0, true)
		return
	var goccia := PackedVector2Array()
	var fondo := c + Vector2(0, r * 0.25)
	for i in 17:
		goccia.append(fondo + Vector2.from_angle(lerpf(-PI * 0.2, PI * 1.2, float(i) / 16.0)) * r * 0.78)
	goccia.append(c + Vector2(0, -r * 1.25))
	draw_colored_polygon(goccia, FUOCO if elemento == "fuoco" else ACQUA)
	goccia.append(goccia[0])
	draw_polyline(goccia, INK, 1.5, true)
	if elemento == "fuoco":
		draw_circle(fondo + Vector2(0, r * 0.12), r * 0.36, ORO)
	else:
		draw_circle(fondo + Vector2(-r * 0.3, -r * 0.1), r * 0.18, Color(1, 1, 1, 0.8))


func omino(piedi: Vector2, umore: String, scala := 1.0) -> void:
	# l'omino della pubblicita': testa grande, maglia blu. Ha paura, e' calmo,
	# o e' felice; con la paura suda
	draw_set_transform(piedi, 0.0, Vector2(scala, scala))
	var su := umore != "calmo"
	var mani := [Vector2(-25, -74), Vector2(25, -74)] if su else [Vector2(-21, -24), Vector2(21, -24)]
	for k in 2:
		var spalla := Vector2(-11.0 if k == 0 else 11.0, -44)
		draw_line(spalla, mani[k], INK, 11.0, true)
		draw_circle(mani[k], 6.5, INK)
	draw_rect(Rect2(-11, -24, 9, 22).grow(2.5), INK)
	draw_rect(Rect2(2, -24, 9, 22).grow(2.5), INK)
	draw_circle(Vector2(0, -68), 20.5, INK)
	for k in 2:
		var spalla := Vector2(-11.0 if k == 0 else 11.0, -44)
		draw_line(spalla, mani[k], MAGLIA, 6.0, true)
		draw_circle(mani[k], 4.5, PELLE)
	draw_rect(Rect2(-11, -24, 9, 22), CALZONI)
	draw_rect(Rect2(2, -24, 9, 22), CALZONI)
	draw_rect(Rect2(-13, -4, 11, 5), INK)
	draw_rect(Rect2(2, -4, 11, 5), INK)
	scatola(Rect2(-15, -52, 30, 32), MAGLIA, 9, 2.5)
	draw_circle(Vector2(0, -68), 18.0, PELLE)
	var ciuffo := PackedVector2Array([Vector2(-17, -72), Vector2(-14, -86), Vector2(-7, -80), Vector2(0, -90),
			Vector2(7, -80), Vector2(14, -86), Vector2(17, -72), Vector2(9, -78), Vector2(0, -76), Vector2(-9, -78)])
	draw_colored_polygon(ciuffo, CAPELLI)
	ciuffo.append(ciuffo[0])
	draw_polyline(ciuffo, INK, 2.0, true)
	faccia(umore)
	draw_set_transform(Vector2.ZERO)


func faccia(umore: String) -> void:
	match umore:
		"felice":
			for x: float in [-7.0, 7.0]:
				draw_arc(Vector2(x, -66), 4.0, PI + 0.3, TAU - 0.3, 8, INK, 2.5, true)
			var bocca := PackedVector2Array([Vector2(-8, -60)])
			for i in 9:
				bocca.append(Vector2(0, -60) + Vector2.from_angle(PI * float(i) / 8.0) * 8.0 * Vector2(1, 0.9))
			draw_colored_polygon(bocca, INK)
			draw_circle(Vector2(0, -55), 3.0, Color("#ff6b7a"))
		"paura":
			for x: float in [-7.0, 7.0]:
				draw_circle(Vector2(x, -69), 5.5, INK)
				draw_circle(Vector2(x, -69), 4.0, Color.WHITE)
				draw_circle(Vector2(x, -69), 1.6, INK)
			ovale(Vector2(0, -57), Vector2(3.5, 4.5), INK)
			var goccia := PackedVector2Array([Vector2(22, -92), Vector2(26, -82), Vector2(22, -78), Vector2(18, -82)])
			draw_colored_polygon(goccia, Color("#9fdcff"))
			goccia.append(goccia[0])
			draw_polyline(goccia, INK, 1.5, true)
		_:
			for x: float in [-7.0, 7.0]:
				draw_circle(Vector2(x, -68), 4.5, INK)
				draw_circle(Vector2(x, -68), 3.0, Color.WHITE)
				draw_circle(Vector2(x + 0.8, -68), 1.5, INK)
			draw_arc(Vector2(0, -61), 5.0, 0.4, PI - 0.4, 10, INK, 2.0, true)


func mostro(piedi: Vector2, stato: String, scala := 1.0, tinta := VIOLA) -> void:
	draw_set_transform(piedi, 0.0, Vector2(scala, scala))
	var corna := [PackedVector2Array([Vector2(-22, -48), Vector2(-16, -70), Vector2(-8, -54)]),
			PackedVector2Array([Vector2(22, -48), Vector2(16, -70), Vector2(8, -54)])]
	for corno: PackedVector2Array in corna:
		draw_colored_polygon(corno, Color("#f3e9d2"))
		var chiuso := corno.duplicate()
		chiuso.append(corno[0])
		draw_polyline(chiuso, INK, 2.5, true)
	draw_circle(Vector2(0, -32), 30.5, INK)
	draw_rect(Rect2(-30.5, -32, 61, 32), INK)
	draw_circle(Vector2(0, -32), 28.0, tinta)
	draw_rect(Rect2(-28, -32, 56, 29), tinta)
	draw_circle(Vector2(-10, -46), 6.0, Color(1, 1, 1, 0.18))
	match stato:
		"dorme":
			for x: float in [-11.0, 11.0]:
				draw_arc(Vector2(x, -36), 6.0, 0.3, PI - 0.3, 10, INK, 2.5, true)
			draw_line(Vector2(-6, -18), Vector2(6, -18), INK, 2.5)
		"contento":
			for x: float in [-11.0, 11.0]:
				draw_arc(Vector2(x, -34), 6.0, PI + 0.3, TAU - 0.3, 10, INK, 2.5, true)
			draw_arc(Vector2(0, -22), 10.0, 0.3, PI - 0.3, 12, INK, 3.0, true)
		_:
			for x: float in [-11.0, 11.0]:
				draw_circle(Vector2(x, -38), 9.0, INK)
				draw_circle(Vector2(x, -38), 7.0, Color.WHITE)
				draw_circle(Vector2(x * 0.7, -36), 3.5, INK)
			var bocca := Rect2(-16, -22, 32, 12)
			draw_rect(bocca, INK)
			for k in 4:
				var dente := Vector2(-15.0 + 8.0 * float(k), -22)
				draw_colored_polygon(PackedVector2Array([dente, dente + Vector2(7, 0), dente + Vector2(3.5, 7)]), Color.WHITE)
	draw_set_transform(Vector2.ZERO)


func guanto(punta: Vector2, angolo: float, carica: float) -> void:
	# LA MANO DELLA PUBBLICITA'. L'anello rosso si riempie mentre esiti: pieno,
	# gioca lei, e gioca la mossa sbagliata
	draw_circle(punta, 27.0, Color(1, 1, 1, 0.4))
	draw_arc(punta, 27.0, 0.0, TAU, 48, INK, 2.0, true)
	draw_arc(punta, 27.0, -PI * 0.5, -PI * 0.5 + TAU * carica, 48, ROSSO, 6.0, true)
	draw_set_transform(punta, angolo, Vector2.ONE)
	var tondi := [[Vector2(0, 7), 7.0], [Vector2(12, 34), 7.5], [Vector2(21, 36), 7.5], [Vector2(29, 40), 7.0],
			[Vector2(-9, 46), 7.5]]
	var pieni := [Rect2(-7, 7, 14, 30), Rect2(-9, 34, 42, 32)]
	for t: Array in tondi:
		draw_circle(t[0], float(t[1]) + 2.5, INK)
	for r: Rect2 in pieni:
		draw_rect(r.grow(2.5), INK)
	draw_rect(Rect2(-6, 63, 36, 14).grow(2.5), INK)
	for t: Array in tondi:
		draw_circle(t[0], float(t[1]), Color.WHITE)
	for r: Rect2 in pieni:
		draw_rect(r, Color.WHITE)
	draw_rect(Rect2(-6, 63, 36, 14), Color("#d9dce3"))
	draw_line(Vector2(16, 40), Vector2(17, 52), INK, 1.5)
	draw_line(Vector2(25, 42), Vector2(26, 54), INK, 1.5)
	draw_set_transform(Vector2.ZERO)
