extends Control

# LE PROPOSTE PER LA CRESCITA, seconda mano. Provvisorio: quando Bru sceglie, la
# schermata vera nasce da quella scelta e questo file se ne va (come ProposteZaino).
#
# Bru: «basandoti sulle nostre grafiche mi faresti degli esempi di schermate di
# crescita? spesa punti e così via?». Alla prima mano: «sono pessime. devi
# impegnarti di più». Erano moduli - riquadri dentro riquadri, linee sottili,
# tanto testo piccolo, niente da guardare. Qui ogni schermata sta DENTRO il
# luna park del menu, a schermo intero, con le regole del manifesto che il
# gioco usa gia' (Persona 5): forme grandi col contorno nero e l'ombra piena,
# scritte ritagliate, tutto in diagonale, una cosa sola che chiama l'occhio.
#
#   1 cielo      le stelle sono lampadine, le linee fili di luci: accendere una
#                stella col tuo hype e' salire di un livello
#   2 banco      il banco dei premi: l'hype fa biglietti, le abilita' sono premi
#   3 ruota      la ruota panoramica: ogni cabina un livello, si sale una alla volta
#   4 colpo      il momento in cui sali: il martello della forza, a tutto schermo
#   5 spille     le passive sono spille, e sulla fascia ce ne stanno tre
#   6 indovino   un punto, due destini: la macchina della fortuna ti da' due carte
#
# I nomi e le frasi vengono dai dati (abilita.json, crescita.json); i numeri
# (l'hype, il livello, cosa e' gia' preso) sono d'esempio, uguali in tutte.
#
#   ./prove/proposte_crescita.sh   le fotografa in scatti/proposte_crescita/
#   nell'editor: F6 su prove/ProposteCrescita.tscn; le frecce girano le sei

const P := preload("res://prove/PezziCrescita.gd")
const PROPOSTE := ["cielo", "banco", "ruota", "colpo", "spille", "indovino"]
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
		# "-- film colpo": parte da quella, per registrarla col Movie Maker
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
	inizio = tempo - (20.0 if foto else 0.0)   # nelle foto, a entrata finita
	tavola.add_child(tela)
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


static func abilita(id: String) -> Dictionary:
	var tutte: Dictionary = GameState.abilita.get("abilita", {})
	return tutte.get(id, {})


static func perche(azione: String) -> String:
	var regole: Dictionary = GameState.crescita.get("crescita", {})
	return "per " + String(regole.get(azione, {}).get("racconto", ""))


static func squadra(t: CanvasItem, dove: Vector2, chiara: bool) -> void:
	# chi cresce: l'hype e' della squadra, e si sceglie su chi spenderlo
	var chi := [["A", 7], ["V", 4], ["Y", 2]]
	for i in chi.size():
		var r := Rect2(dove + Vector2(104.0 * i, 0), Vector2(96, 60))
		var scelto := i == 0
		var fondo := P.CREMA if scelto else (P.NERO if chiara else Color(P.CREMA, 0.12))
		P.fascia(t, r, fondo, P.ARANCIO if scelto else Color(0, 0, 0, 0))
		var inchiostro := P.NERO if scelto else P.CREMA
		P.scritta(t, r.position + Vector2(18, 46), String(chi[i][0]), 38, inchiostro)
		P.scritta(t, r.position + Vector2(54, 48), "LV %d" % int(chi[i][1]), 14, inchiostro)


static func conto_hype(t: CanvasItem, r: Rect2, gradi: float, parola := "STELLE DA ACCENDERE") -> void:
	var per_punto := int(GameState.regole.get("hype_per_punto", 1000))
	P.gira(t, r.position, gradi)
	var q := Rect2(Vector2.ZERO, r.size)
	P.cartoncino(t, q, P.CREMA, 4.0, P.OMBRA, true)
	P.scritta(t, Vector2(16, 26), "HYPE DELLA SQUADRA", 13, P.NERO, Caratteri.tondo(900))
	P.scritta(t, Vector2(14, 80), migliaia(HYPE), 54, P.NERO)
	var punti := floori(float(HYPE) / per_punto)
	P.etichetta(t, Vector2(14, 92), "%d %s" % [punti, parola], 15, P.NERO, P.CREMA)
	var barra := Rect2(16, 130, q.size.x - 120, 8)
	t.draw_rect(barra, Color(P.NERO, 0.18))
	t.draw_rect(Rect2(barra.position, Vector2(barra.size.x * float(HYPE % per_punto) / per_punto, barra.size.y)), P.ARANCIO_SCURO)
	P.scritta(t, Vector2(barra.end.x + 8, 140), "%s/%s" % [migliaia(HYPE % per_punto), migliaia(per_punto)], 13, P.NERO,
			Caratteri.tondo(900))
	P.dritto(t)


static func migliaia(n: int) -> String:
	var s := str(n)
	var fuori := ""
	while s.length() > 3:
		fuori = "." + s.substr(s.length() - 3) + fuori
		s = s.substr(0, s.length() - 3)
	return s + fuori


# --- 1. il cielo ------------------------------------------------------------------------
#
# Le stelle sono lampadine e le linee sono i fili delle luci del luna park, che
# pendono come quelli del menu. Tutto parte dalla luna. Accesa = tua; quella
# che si puo' prendere ha il filo che la chiama (le lampadine si accendono una
# dopo l'altra verso di lei); le altre sono vetro spento.

const STELLE := {
	"luna": Vector2(690, 300),
	"f1": Vector2(566, 262), "f2": Vector2(452, 304), "f3": Vector2(372, 236), "f4": Vector2(286, 284),
	"f5": Vector2(206, 210), "f6": Vector2(122, 254),
	"a1": Vector2(738, 204), "a2": Vector2(806, 132), "a3": Vector2(900, 104), "a4": Vector2(992, 146),
	"a5": Vector2(1084, 104), "a6": Vector2(1178, 150),
	"m1": Vector2(812, 334), "m2": Vector2(916, 306), "m3": Vector2(1004, 352), "m4": Vector2(1092, 298),
	"m5": Vector2(1172, 332), "m6": Vector2(1236, 262),
	"s1": Vector2(618, 182), "s2": Vector2(872, 236), "s3": Vector2(690, 412), "s4": Vector2(520, 150), "s5": Vector2(806, 452),
}
const FILI := [["luna", "f1"], ["f1", "f2"], ["f2", "f3"], ["f3", "f4"], ["f4", "f5"], ["f5", "f6"],
	["luna", "a1"], ["a1", "a2"], ["a2", "a3"], ["a3", "a4"], ["a4", "a5"], ["a5", "a6"],
	["luna", "m1"], ["m1", "m2"], ["m2", "m3"], ["m3", "m4"], ["m4", "m5"], ["m5", "m6"],
	["f1", "s1"], ["a1", "s1"], ["a1", "s2"], ["m1", "s2"], ["f1", "s3"], ["m1", "s3"], ["s1", "s4"], ["s3", "s5"]]
const ACCESE := ["luna", "f1", "a1", "m1", "s1", "s3", "s4"]
const SCELTA := "f2"
const PICCOLE := {"s1": "+6 attacco", "s2": "+8 fattore", "s3": "+60 vita", "s4": "+10 attacco", "s5": "+110 vita"}


static func stato_stella(id: String) -> String:
	if id in ACCESE:
		return "accesa"
	for f: Array in FILI:
		if (String(f[0]) == id and String(f[1]) in ACCESE) or (String(f[1]) == id and String(f[0]) in ACCESE):
			return "aperta"
	return "spenta"


func disegna_cielo(t: CanvasItem) -> void:
	P.cielo(t, [Color("#0e0a08"), Color("#2b1609"), Color("#6c340b"), P.ARANCIO_SCURO, Color("#f08a17")],
			[0.0, 210.0, 390.0, 520.0, 600.0])
	P.stelline(t, Rect2(0, 0, 1280, 430), 110, 20261013, tempo)
	P.luna(t, STELLE["luna"], 52.0)
	P.colline(t, 572.0, 16.0, Color("#7a3f0b"))
	P.nebbia(t, 598.0, 40.0, 0.3, Color("#f7a94a"))
	P.ruota(t, Vector2(1128, 552), 168.0, tempo * 0.05, Color("#140e0a"), tempo)
	P.tendone(t, Vector2(232, 478), 150.0, 596.0, Color("#140e0a"), Color("#33251c"), tempo)
	P.terra(t, 662.0, P.NERO)
	for f: Array in FILI:
		filo_del_cielo(t, String(f[0]), String(f[1]))
	for id: String in STELLE:
		stella(t, id)
	nomi_del_cielo(t)
	cartellino(t, STELLE[SCELTA], "terra_bruciata", "FLAGELLO · GRADO II")
	P.etichetta(t, Vector2(28, 24), "CRESCITA", 46, P.NERO, P.CREMA, P.ARANCIO)
	P.scritta(t, Vector2(34, 118), "Ogni stella accesa è un livello.", 17, P.CARTA, Caratteri.tondo(800))
	squadra(t, Vector2(30, 136), false)
	conto_hype(t, Rect2(26, 534, 272, 154), -3.0)


func filo_del_cielo(t: CanvasItem, da: String, a: String) -> void:
	var p: Vector2 = STELLE[da]
	var q: Vector2 = STELLE[a]
	if da == "luna":
		p += (q - p).normalized() * 58.0
	var sa := stato_stella(da)
	var sb := stato_stella(a)
	var pancia := p.distance_to(q) * 0.14
	if sa == "accesa" and sb == "accesa":
		P.filo(t, p, q, pancia, 1.0, tempo, false, Color("#4a3426"))
	elif "accesa" in [sa, sb]:
		P.filo(t, p if sa == "accesa" else q, q if sa == "accesa" else p, pancia, 0.0, tempo, true, Color("#4a3426"))
	else:
		P.filo(t, p, q, pancia, 0.0, tempo, false, Color("#3a2a20"))


func stella(t: CanvasItem, id: String) -> void:
	if id == "luna":
		return
	var c: Vector2 = STELLE[id]
	var piccola := id.begins_with("s")
	var k := 0.7 if piccola else 1.0
	match stato_stella(id):
		"accesa":
			t.draw_circle(c, 30.0 * k, Color(P.LUCE, 0.08), true, -1.0, true)
			t.draw_circle(c, 17.0 * k, Color(P.ARANCIO, 0.28), true, -1.0, true)
			P.scintilla(t, c, 22.0 * k, Color(P.LUCE, 0.95))
			t.draw_circle(c, 7.0 * k, P.LUCE, true, -1.0, true)
		"aperta":
			var batte := 0.55 + 0.45 * sin(tempo * 3.0)
			if id == SCELTA:
				t.draw_arc(c, 30.0 + 3.0 * batte, 0.0, TAU, 48, P.ARANCIO, 4.0, true)
				t.draw_circle(c, 20.0, Color(P.ARANCIO, 0.25), true, -1.0, true)
				P.scintilla(t, c, 26.0, P.CREMA)
			else:
				t.draw_arc(c, 16.0 * k, 0.0, TAU, 32, Color(P.CARTA, 0.25 + 0.3 * batte), 2.0, true)
				P.scintilla(t, c, 15.0 * k, Color(P.CARTA, 0.55 + 0.35 * batte))
		_:
			P.lampadina(t, c, 0.0, 4.5 * k)
	if piccola and PICCOLE.has(id):
		var acceso := stato_stella(id) != "spenta"
		var dove := {"s1": Vector2(14, -16), "s4": Vector2(-104, 6)}
		P.scritta(t, c + (dove[id] if dove.has(id) else Vector2(16, 22)), String(PICCOLE[id]), 14,
				Color(P.CARTA, 0.95 if acceso else 0.55), Caratteri.tondo(900))


func nomi_del_cielo(t: CanvasItem) -> void:
	var f := Caratteri.nomi()
	var tinta := Color(P.CARTA, 0.9)
	P.scritta(t, Vector2(60, 326), "Il Flagello", 26, tinta, f)
	P.scritta(t, Vector2(1000, 76), "L'Annichilazione", 26, tinta, f)
	P.scritta(t, Vector2(1104, 232), "Il Mantra", 26, tinta, f)


func cartellino(t: CanvasItem, stella_dove: Vector2, id: String, che_cosa: String) -> void:
	# IL CARTELLINO APPESO alla stella scelta, come il prezzo a un premio: dice
	# cos'e', cosa fa, quanto costa
	var dati := abilita(id)
	var aggancio := stella_dove + Vector2(0, 74)
	t.draw_line(stella_dove + Vector2(0, 28), aggancio + Vector2(0, 12), P.CARTA, 2.0, true)
	P.gira(t, aggancio, -3.0)
	var r := Rect2(-150, 0, 300, 196)
	P.cartoncino(t, r, P.CREMA, 4.0, P.OMBRA, true)
	t.draw_circle(Vector2(0, 14), 7.0, P.NERO, true, -1.0, true)
	t.draw_circle(Vector2(0, 14), 3.5, P.CARTA, true, -1.0, true)
	P.etichetta(t, Vector2(-134, 30), che_cosa, 14, P.NERO, P.CREMA)
	P.scritta(t, Vector2(-134, 92), String(dati.get("nome", id)), 34, P.NERO)
	P.a_capo(t, Rect2(-134, 100, 270, 56), String(dati.get("descrizione", "")), 15, Color(P.NERO, 0.82))
	P.etichetta(t, Vector2(-134, 158), "1 STELLA · 1.000 HYPE", 15, P.ARANCIO, P.NERO)
	P.scritta(t, Vector2(80, 180), "AURA %d" % int(dati.get("aura", 0)), 16, P.NERO)
	P.dritto(t)


func tasti_cielo() -> void:
	comandi(Vector2(840, 684), [["SU", "muoviti"], ["INVIO", "accendi"], ["ESC", "indietro"]], P.CARTA)


# --- 4. il colpo -------------------------------------------------------------------------
#
# Salire di livello deve essere un momento. Il martello della forza: il peso
# vola fino alla campana, DING, e il numero nuovo grande come lo schermo. Sotto,
# il perche' di ogni punto: le frasi di crescita.json.

func entrata(da: float, durata: float) -> float:
	# dove e' un pezzo della sua entrata, da 0 a 1
	return clampf((tempo - inizio - da) / durata, 0.0, 1.0)


static func rimbalza(x: float) -> float:
	# arriva oltre e torna: l'ease out back
	var c1 := 1.70158
	return 1.0 + (c1 + 1.0) * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0)


static func frena(x: float) -> float:
	return 1.0 - pow(1.0 - x, 3.0)


func disegna_colpo(t: CanvasItem) -> void:
	P.raggi(t, Vector2(930, 230), 24, 1700.0, P.ARANCIO, Color("#e8830f"), tempo * 0.04)
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, 548), Vector2(1300, 300), Vector2(1300, 740), Vector2(-20, 740)]),
			P.CREMA)
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, 560), Vector2(1300, 312), Vector2(1300, 740), Vector2(-20, 740)]),
			P.NERO)
	martello_della_forza(t)
	var entra := frena(entrata(0.55, 0.3))
	if entra > 0.0:
		P.gira(t, Vector2(470 - 500 * (1.0 - entra), 176), -7.0)
		P.ritagliata(t, Vector2(0, 0), "LIVELLO", 78, P.CREMA, P.NERO, 14, P.NERO, Vector2(8, 8))
		P.dritto(t)
	var piomba := entrata(0.72, 0.2)
	if piomba > 0.0:
		var scala := lerpf(2.4, 1.0, frena(piomba))
		var scossa := Vector2(sin(tempo * 90.0), cos(tempo * 77.0)) * 10.0 * (1.0 - entrata(0.92, 0.25)) if piomba >= 1.0 else Vector2.ZERO
		P.gira(t, Vector2(800, 452) + scossa, -7.0, scala)
		P.ritagliata(t, Vector2(-100, 120) * (1.0 - 1.0 / scala), str(LIVELLO + 1), 330, Color(P.CREMA, minf(piomba * 3.0, 1.0)),
				P.NERO, 22, P.ARANCIO_SCURO, Vector2(16, 14))
		P.dritto(t)
	var appare := entrata(1.6, 0.35)
	if appare > 0.0:
		adesivo(t, Vector2(1122, 146), "HAI ACCESO", "TERRA BRUCIATA", rimbalza(appare))
	var righe := [["lama", "ATTACCO", "attacchi_sferrati", 15, 17], ["cuore", "PUNTI VITA", "danni_subiti", 100, 110],
			["occhio", "INTELLIGENZA", "studi", 1, 2], ["saetta", "VELOCITÀ", "stanze_esplorate", 3, 4]]
	for i in righe.size():
		var arriva := frena(entrata(1.0 + 0.14 * i, 0.32))
		if arriva > 0.0:
			striscia_della_crescita(t, Vector2(548 + 10 * i + 760 * (1.0 - arriva), 450 + 63 * i), righe[i], -0.6 if i % 2 == 0 else 0.5)


const BASE := Vector2(250, 704)
const SCALA_TORRE := 0.84


func nella_torre(p: Vector2) -> Vector2:
	return BASE + (p * SCALA_TORRE).rotated(deg_to_rad(-6.0))


func martello_della_forza(t: CanvasItem) -> void:
	# il peso sale per la torre in un terzo di secondo, poi la campana scoppia
	var sale := entrata(0.05, 0.36)
	var y_peso := lerpf(-70.0, -604.0, sale * sale * (3.0 - 2.0 * sale))
	P.gira(t, BASE, -6.0, SCALA_TORRE)
	var parole := ["MOSCERINO", "COSÌ COSÌ", "BRAVO", "FORZUTO", "ERCOLE"]
	t.draw_rect(Rect2(-110, -40, 220, 40), P.NERO)
	t.draw_rect(Rect2(-104, -40, 208, 8), P.CREMA)
	P.cartoncino(t, Rect2(-52, -618, 104, 578), P.CREMA, 6.0, Vector2(10, 10), true)
	t.draw_rect(Rect2(-9, -600, 18, 548), P.NERO)
	for i in parole.size():
		var y := -112.0 - 112.0 * i
		var passato := y_peso <= y + 4.0
		var lui := i == parole.size() - 1 and sale >= 1.0
		t.draw_rect(Rect2(-48, y - 3, 30, 6), P.NERO)
		var largo := P.larghezza(parole[i], 15) + 18.0
		P.fascia(t, Rect2(-62 - largo, y - 14, largo, 26), P.CREMA if lui else (P.NERO if passato else Color(P.NERO, 0.35)),
				P.NERO if lui else Color(0, 0, 0, 0), Vector2(4, 4))
		P.scritta(t, Vector2(-54 - largo, y + 6), parole[i], 15, P.NERO if lui else Color(P.CREMA, 1.0 if passato else 0.5))
	if sale > 0.0:
		for k in 2:
			var lato := -1.0 if k == 0 else 1.0
			for j in 3:
				t.draw_line(Vector2(lato * 30, y_peso + 14 + 22 * j), Vector2(lato * (46 + 10 * j), y_peso + 34 + 22 * j), P.NERO, 4.0, true)
	var scoppia := entrata(0.42, 0.28)
	if scoppia > 0.0:
		P.gira(t, nella_torre(Vector2(0, -664)), -6.0, SCALA_TORRE * rimbalza(scoppia))
		P.scoppio(t, Vector2.ZERO, 128.0, 66.0, 14, P.CREMA, P.NERO, 8.0, tempo * 0.3)
		P.gira(t, BASE, -6.0, SCALA_TORRE)
	Manifesto.poligono(t, Sagome.rombo(Vector2(0, y_peso), 30.0), P.NERO)
	Manifesto.poligono(t, Sagome.rombo(Vector2(0, y_peso), 22.0), P.ARANCIO)
	t.draw_circle(Vector2(0, -662), 40.0, P.NERO, true, -1.0, true)
	t.draw_circle(Vector2(0, -664), 33.0, P.ARANCIO if scoppia > 0.0 else P.ARANCIO_SCURO, true, -1.0, true)
	t.draw_circle(Vector2(-10, -676), 9.0, Color(P.LUCE, 0.8), true, -1.0, true)
	if scoppia > 0.0:
		P.gira(t, nella_torre(Vector2(70, -704)), -14.0, SCALA_TORRE * rimbalza(scoppia))
		P.ritagliata(t, Vector2(0, 0), "DING!", 48, P.NERO, P.CREMA, 10)
	# il martello, appoggiato alla torre col manico a terra
	P.gira(t, BASE, -6.0, SCALA_TORRE)
	t.draw_line(Vector2(120, -6), Vector2(220, -330), P.NERO, 24.0, true)
	t.draw_line(Vector2(120, -6), Vector2(220, -330), P.CARTA, 13.0, true)
	P.gira(t, nella_torre(Vector2(224, -344)), 11.0, SCALA_TORRE)
	var testa := StyleBoxFlat.new()
	testa.bg_color = P.NERO
	testa.set_corner_radius_all(18)
	t.draw_style_box(testa, Rect2(-64 + 8, -36 + 8, 128, 72))
	t.draw_style_box(testa, Rect2(-64, -36, 128, 72))
	t.draw_rect(Rect2(-46, -36, 16, 72), P.CREMA)
	t.draw_rect(Rect2(30, -36, 16, 72), P.CREMA)
	t.draw_rect(Rect2(-64, -36, 128, 72).grow(-2), P.NERO, false, 4.0)
	P.dritto(t)


func adesivo(t: CanvasItem, c: Vector2, sopra: String, sotto: String, scala := 1.0) -> void:
	P.gira(t, c, 9.0, scala)
	P.scoppio(t, Vector2.ZERO, 128.0, 100.0, 18, P.CREMA, P.NERO, 6.0)
	P.scritta(t, Vector2(-90, -6), sopra, 18, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 180)
	P.scritta(t, Vector2(-100, 26), sotto, 20, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 200)
	P.scintilla(t, Vector2(0, -42), 14.0, P.ARANCIO)
	P.dritto(t)


func striscia_della_crescita(t: CanvasItem, dove: Vector2, riga: Array, gradi: float) -> void:
	# una striscia di carta strappata: il disegno, cosa e' cresciuto, perche', di quanto
	P.gira(t, dove, gradi)
	var largo := 600.0
	var bordo := PackedVector2Array([Vector2(0, 0), Vector2(largo, 0)])
	for k in 7:
		bordo.append(Vector2(largo + (8.0 if k % 2 == 0 else -4.0), 7.0 * (k + 1)))
	bordo.append(Vector2(0, 48))
	Manifesto.poligono(t, bordo, P.CREMA)
	P.glifo(t, String(riga[0]), Vector2(32, 24), 34.0, P.NERO)
	P.scritta(t, Vector2(64, 24), String(riga[1]), 24, P.NERO)
	P.scritta(t, Vector2(64, 42), perche(String(riga[2])), 14, Color(P.NERO, 0.75), Caratteri.tondo(800))
	P.scritta(t, Vector2(392, 36), str(int(riga[3])), 28, Color(P.NERO, 0.45), null, HORIZONTAL_ALIGNMENT_RIGHT, 70)
	Sagome.freccia(t, Vector2(486, 25), 26.0, Vector2.RIGHT, P.NERO)
	P.scritta(t, Vector2(500, 40), str(int(riga[4])), 38, P.ARANCIO_SCURO, null, HORIZONTAL_ALIGNMENT_RIGHT, 84)
	P.dritto(t)


func tasti_colpo() -> void:
	comandi(Vector2(1124, 692), [["INVIO", "avanti"]], P.CARTA)


# --- le altre, in arrivo -----------------------------------------------------------------

# --- 2. il banco dei premi --------------------------------------------------------------
#
# L'hype della squadra fa biglietti (uno ogni 1.000), e le abilita' sono premi
# sugli scaffali del banco: uno scaffale per linea, un premio per grado, da
# sinistra a destra. Vinto = timbrato; quello dopo si puo' prendere; gli altri
# sono ancora incartati, col cartellino del livello.

const SCAFFALI := [
	["FLAGELLO", "aghi", [["Flagello", "aghi"], ["Terra bruciata", "fiamma"], ["Maelstrom", "spirale"], ["Devastazione", "saetta"], ["Apocalisse", "fuoco_interno"]]],
	["ANNICHILAZIONE", "vuoto", [["Annichilazione", "vuoto"], ["Annichilazione II", "vuoto"], ["Annichilazione III", "vuoto"], ["Annichilazione IV", "vuoto"], ["Annichilazione V", "vuoto"]]],
	["MANTRA", "loto", [["Mantra", "loto"], ["Mantra II", "loto"], ["Mantra III", "loto"], ["Mantra IV", "loto"], ["Mantra V", "loto"]]],
]
const PIANI := [296.0, 445.0, 592.0]
const INCLINAZIONI := [-4.0, 3.0, -2.0, 5.0, -3.0]


func disegna_banco(t: CanvasItem) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), P.ARANCIO)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO_SCURO, 0.5), Vector2(0.1, 0.95))
	Manifesto.poligono(t, PackedVector2Array([Vector2(916, -20), Vector2(1300, -20), Vector2(1300, 740), Vector2(770, 740)]), P.CREMA)
	Manifesto.poligono(t, PackedVector2Array([Vector2(930, -20), Vector2(1300, -20), Vector2(1300, 740), Vector2(784, 740)]), P.NERO)
	banco(t)
	macchina_dei_biglietti(t, Vector2(990, 104))
	scheda_del_premio(t, Rect2(926, 492, 320, 182), "terra_bruciata", "FLAGELLO · GRADO II", "PRENDILO · 1 BIGLIETTO")
	squadra(t, Vector2(948, 22), true)


func banco(t: CanvasItem) -> void:
	# la parete, i pali, la tenda a strisce col suo festone, l'insegna, gli
	# scaffali coi premi, il bancone
	t.draw_rect(Rect2(60, 140, 800, 500), P.BRUNO)
	for k in 20:
		t.draw_rect(Rect2(70 + 40 * k, 140, 18, 500), Color(P.NERO, 0.22))
	for x in [36.0, 852.0]:
		P.cartoncino(t, Rect2(x, 112, 32, 520), P.NERO, 0.0, Vector2(6, 6))
	tenda(t, 30.0, 890.0, 92.0, 158.0)
	P.gira(t, Vector2(460, 50), -2.0)
	P.cartoncino(t, Rect2(-250, -40, 500, 72), P.NERO, 0.0, Vector2(8, 8))
	t.draw_rect(Rect2(-250, -40, 500, 72).grow(-6), P.CREMA, false, 2.0)
	for k in 24:
		var x := -238.0 + 476.0 * k / 23.0
		P.lampadina(t, Vector2(x, -32), 0.7 + 0.3 * sin(tempo * 3.0 + k), 2.6)
		P.lampadina(t, Vector2(x, 24), 0.7 + 0.3 * sin(tempo * 3.0 + k + 2.0), 2.6)
	P.scritta(t, Vector2(-250, 12), "BANCO DEI PREMI", 40, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 500)
	P.dritto(t)
	for i in SCAFFALI.size():
		scaffale(t, i)
	P.cartoncino(t, Rect2(26, 634, 872, 120), P.NERO, 0.0, Vector2(8, 8))
	t.draw_rect(Rect2(26, 634, 872, 10), P.CREMA)
	P.scritta(t, Vector2(26, 694), "UN BIGLIETTO · UN PREMIO", 24, Color(P.CREMA, 0.9), Caratteri.striscia(),
			HORIZONTAL_ALIGNMENT_CENTER, 872)


func tenda(t: CanvasItem, da: float, a: float, su: float, giu: float) -> void:
	var strisce := 14
	var passo := (a - da) / strisce
	for k in strisce:
		var x := da + passo * k
		var tinta := P.CREMA if k % 2 == 0 else P.ARANCIO_SCURO
		var forma := PackedVector2Array([Vector2(x + 6, su), Vector2(x + passo + 6, su), Vector2(x + passo, giu), Vector2(x, giu)])
		Manifesto.poligono(t, forma, tinta)
		t.draw_circle(Vector2(x + passo * 0.5, giu), passo * 0.5, tinta, true, -1.0, true)
		t.draw_arc(Vector2(x + passo * 0.5, giu), passo * 0.5, 0.0, PI, 16, P.NERO, 3.0, true)
	t.draw_line(Vector2(da + 6, su), Vector2(a + 6, su), P.NERO, 5.0)
	for k in strisce + 1:
		P.lampadina(t, Vector2(da + passo * k, giu + 4), 0.75 + 0.25 * sin(tempo * 2.4 + k * 1.3), 3.2)


func scaffale(t: CanvasItem, i: int) -> void:
	var y: float = PIANI[i]
	var dati: Array = SCAFFALI[i]
	# l'insegna dello scaffale, a sinistra: il disegno della linea e il nome
	P.gira(t, Vector2(126, y - 62), -3.0)
	P.cartoncino(t, Rect2(-60, -44, 120, 88), P.NERO, 0.0, Vector2(5, 5))
	t.draw_rect(Rect2(-60, -44, 120, 88).grow(-5), P.ARANCIO, false, 2.0)
	P.glifo(t, String(dati[1]), Vector2(0, -12), 38.0, P.ARANCIO, P.NERO)
	P.scritta(t, Vector2(-58, 30), String(dati[0]), 13 if String(dati[0]).length() > 10 else 15, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 116)
	P.dritto(t)
	P.cartoncino(t, Rect2(66, y, 790, 16), P.CREMA, 3.0, Vector2(0, 6))
	var premi: Array = dati[2]
	for k in premi.size():
		var stato := "vinto" if k == 0 else ("scelto" if i == 0 and k == 1 else ("aperto" if k == 1 else "incartato"))
		premio(t, Vector2(244 + 124 * k, y), premi[k], k, stato)


func premio(t: CanvasItem, base: Vector2, dati: Array, grado: int, stato: String) -> void:
	var romani := ["I", "II", "III", "IV", "V", "VI"]
	var scelto := stato == "scelto"
	var alza := -16.0 if scelto else 0.0
	var scala := 1.12 if scelto else 1.0
	P.gira(t, base + Vector2(0, alza), float(INCLINAZIONI[grado]) * (0.4 if scelto else 1.0), scala)
	var r := Rect2(-52, -110, 104, 108)
	if scelto:
		t.draw_rect(r.grow(9), P.ARANCIO)
		t.draw_rect(r.grow(9), P.NERO, false, 3.0)
	if stato == "incartato":
		P.cartoncino(t, r, Color("#5a3510"), 4.0, Vector2(6, 6))
		t.draw_line(Vector2(0, r.position.y), Vector2(0, r.end.y), P.CREMA, 5.0)
		t.draw_line(Vector2(r.position.x, -56), Vector2(r.end.x, -56), P.CREMA, 5.0)
		Manifesto.poligono(t, PackedVector2Array([Vector2(0, -56), Vector2(-20, -74), Vector2(-24, -52)]), P.CREMA)
		Manifesto.poligono(t, PackedVector2Array([Vector2(0, -56), Vector2(20, -74), Vector2(24, -52)]), P.CREMA)
		P.scritta(t, Vector2(r.position.x + 8, r.end.y - 10), "LIV. %d" % (9 + 4 * grado), 13, P.CREMA)
	else:
		P.cartoncino(t, r, P.CREMA if stato != "vinto" else P.CARTA, 4.0, Vector2(6, 6))
		P.glifo(t, String(dati[1]), Vector2(0, -64), 50.0, P.NERO if stato != "vinto" else Color(P.NERO, 0.55), P.CREMA)
		if String(dati[0]).length() > 13:
			P.a_capo(t, Rect2(-48, -36, 96, 34), String(dati[0]), 13, P.NERO, Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER)
		else:
			P.scritta(t, Vector2(-48, -18), String(dati[0]), 15, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 96)
		t.draw_circle(Vector2(-36, -94), 13.0, P.NERO, true, -1.0, true)
		P.scritta(t, Vector2(-49, -89), romani[grado], 13, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 26)
	var verso := float(INCLINAZIONI[grado]) * (0.4 if scelto else 1.0)
	if stato == "vinto":
		timbro(t, base + Vector2(0, alza) + (Vector2(8, -62) * scala).rotated(deg_to_rad(verso)), verso - 18.0, "VINTO")
	elif stato != "incartato":
		# il cartellino del prezzo pende sul bordo dello scaffale
		P.gira(t, base + Vector2(30, 18), 8.0)
		t.draw_line(Vector2(-18, -14), Vector2(-26, -26), P.NERO, 2.0, true)
		P.biglietto(t, Rect2(-30, -13, 60, 26), P.ARANCIO if scelto else P.CREMA, "1", "", 15)
	P.dritto(t)


func timbro(t: CanvasItem, c: Vector2, gradi: float, testo: String) -> void:
	var tinta := Color(P.ARANCIO_SCURO, 0.92)
	P.gira(t, c, gradi)
	t.draw_arc(Vector2.ZERO, 36.0, 0.0, TAU, 40, tinta, 5.0, true)
	t.draw_arc(Vector2.ZERO, 29.0, 0.0, TAU, 40, tinta, 2.0, true)
	t.draw_rect(Rect2(-44, -12, 88, 24), P.CARTA)
	t.draw_rect(Rect2(-44, -12, 88, 24), tinta, false, 3.0)
	P.scritta(t, Vector2(-44, 8), testo, 19, tinta, null, HORIZONTAL_ALIGNMENT_CENTER, 88)
	P.dritto(t)


func macchina_dei_biglietti(t: CanvasItem, dove: Vector2) -> void:
	var per_punto := int(GameState.regole.get("hype_per_punto", 1000))
	var punti := floori(float(HYPE) / per_punto)
	P.gira(t, dove, 2.0)
	P.cartoncino(t, Rect2(0, 0, 230, 250), P.ARANCIO, 6.0, Vector2(10, 10))
	t.draw_rect(Rect2(14, 14, 202, 24), P.NERO)
	P.scritta(t, Vector2(14, 33), "BIGLIETTI", 18, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 202)
	P.cartoncino(t, Rect2(26, 50, 178, 112), P.NERO, 0.0, Vector2.ZERO)
	P.ritagliata(t, Vector2(26, 148), str(punti), 104, P.CREMA, P.NERO, 0, P.ARANCIO_SCURO, Vector2(6, 6), null,
			HORIZONTAL_ALIGNMENT_CENTER, 178)
	P.scritta(t, Vector2(26, 188), "HYPE %s" % migliaia(HYPE), 20, P.NERO)
	t.draw_rect(Rect2(26, 200, 178, 8), Color(P.NERO, 0.25))
	t.draw_rect(Rect2(26, 200, 178 * float(HYPE % per_punto) / per_punto, 8), P.NERO)
	P.scritta(t, Vector2(26, 228), "%s / %s al prossimo" % [migliaia(HYPE % per_punto), migliaia(per_punto)], 13, P.NERO,
			Caratteri.tondo(900))
	t.draw_rect(Rect2(60, 240, 110, 10), P.NERO)
	for k in punti:
		P.gira(t, dove + Vector2(116, 270 + 38 * k).rotated(deg_to_rad(2.0)), -6.0 if k % 2 == 0 else 6.0)
		P.biglietto(t, Rect2(-56, -18, 112, 38), P.CREMA, "UN GIRO", "CARNIVALZ", 16)
	P.dritto(t)


func scheda_del_premio(t: CanvasItem, r: Rect2, id: String, che_cosa: String, azione: String) -> void:
	var dati := abilita(id)
	P.gira(t, r.position, 2.0)
	P.cartoncino(t, Rect2(Vector2.ZERO, r.size), P.CREMA, 4.0, P.OMBRA, true)
	P.etichetta(t, Vector2(16, -14), che_cosa, 15, P.NERO, P.CREMA)
	P.scritta(t, Vector2(18, 64), String(dati.get("nome", id)), 32, P.NERO)
	P.a_capo(t, Rect2(18, 74, r.size.x - 34, 60), String(dati.get("descrizione", "")), 15, Color(P.NERO, 0.82))
	P.etichetta(t, Vector2(16, 128), azione, 20, P.NERO, P.CREMA, P.ARANCIO)
	P.dritto(t)


func tasti_banco() -> void:
	comandi(Vector2(930, 690), [["INVIO", "prendi"], ["ESC", "indietro"]], P.CARTA)


# --- 3. la ruota --------------------------------------------------------------------------
#
# Il tronco della crescita come una ruota panoramica: ogni cabina e' un
# livello, si sale una cabina alla volta. Quelle prese sono accese; quella
# che arriva alla pedana e' la prossima; le altre girano al buio.

const CENTRO_RUOTA := Vector2(880, 300)
const RAGGIO_RUOTA := 246.0
const CABINE_RUOTA := [["Mantra", "loto"], ["Colpo più pesante", "lama"], ["Fondo del serbatoio", "cuore"],
	["Terra bruciata", "fiamma"], ["Annichilazione II", "vuoto"], ["Sfogo più lungo", "fuoco_interno"],
	["Mantra II", "loto"], ["Colpo più pesante II", "lama"], ["Maelstrom", "spirale"], ["Fondo del serbatoio II", "cuore"],
	["Annichilazione III", "vuoto"], ["Devastazione", "saetta"]]


func disegna_ruota(t: CanvasItem) -> void:
	P.cielo(t, [P.ARANCIO, Color("#ee8a16"), P.ARANCIO_SCURO], [0.0, 520.0, 720.0])
	P.stelline(t, Rect2(500, 0, 780, 300), 40, 7, tempo)
	P.luna(t, Vector2(1186, 104), 44.0)
	P.colline(t, 590.0, 14.0, Color("#b65f0e"))
	P.nebbia(t, 610.0, 40.0, 0.3, Color("#f7a94a"))
	ruota_della_crescita(t)
	P.terra(t, 676.0, P.NERO)
	var sotto := CENTRO_RUOTA.y + RAGGIO_RUOTA + (16 + 62) * 1.75
	P.cartoncino(t, Rect2(Vector2(CENTRO_RUOTA.x - 120, sotto - 2), Vector2(240, 14)), P.CREMA, 3.0, Vector2(0, 5))
	cabina(t, 3)
	P.etichetta(t, Vector2(CENTRO_RUOTA.x + 96, sotto - 58), "SI SALE QUI", 15, P.CREMA, P.NERO, P.ARANCIO)
	pannello_della_ruota(t)


func angolo_cabina(i: int) -> float:
	# la prossima cabina (indice 3) sta giu', alla pedana, dove si sale; quelle
	# prese sono gia' salite a sinistra, quelle dopo aspettano a destra
	return PI * 0.5 - deg_to_rad(30.0 * (i - 3)) + 0.02 * sin(tempo * 0.6)


func ruota_della_crescita(t: CanvasItem) -> void:
	var nera := P.NERO
	var c := CENTRO_RUOTA
	t.draw_line(c, Vector2(690, 690), nera, 16.0, true)
	t.draw_line(c, Vector2(1070, 690), nera, 16.0, true)
	t.draw_line(Vector2(736, 600), Vector2(1024, 600), nera, 8.0)
	t.draw_arc(c, RAGGIO_RUOTA, 0.0, TAU, 160, nera, 10.0, true)
	t.draw_arc(c, RAGGIO_RUOTA * 0.88, 0.0, TAU, 160, nera, 4.0, true)
	t.draw_arc(c, 54.0, 0.0, TAU, 48, nera, 7.0, true)
	t.draw_circle(c, 20.0, nera, true, -1.0, true)
	for i in CABINE_RUOTA.size():
		var a := angolo_cabina(i)
		t.draw_line(c + Vector2.from_angle(a) * 20.0, c + Vector2.from_angle(a) * RAGGIO_RUOTA, nera, 4.0, true)
		t.draw_line(c + Vector2.from_angle(a) * RAGGIO_RUOTA * 0.88, c + Vector2.from_angle(a + PI / 12.0) * RAGGIO_RUOTA, nera, 3.0, true)
	for j in 48:
		var a := angolo_cabina(0) + TAU * j / 48.0
		var presa := fmod(angolo_cabina(0) - a + TAU * 2.0, TAU) < deg_to_rad(64.0) or fmod(a - angolo_cabina(0) + TAU * 2.0, TAU) < deg_to_rad(2.0)
		P.lampadina(t, c + Vector2.from_angle(a) * RAGGIO_RUOTA, 1.0 if presa else 0.45 + 0.25 * sin(tempo * 2.0 + j), 3.4)
	for i in CABINE_RUOTA.size():
		if i != 3:
			cabina(t, i)


func cabina(t: CanvasItem, i: int) -> void:
	var aggancio := CENTRO_RUOTA + Vector2.from_angle(angolo_cabina(i)) * RAGGIO_RUOTA
	var stato := "presa" if i < 3 else ("scelta" if i == 3 else "chiusa")
	var k := 1.75 if stato == "scelta" else 1.0
	var dati: Array = CABINE_RUOTA[i]
	t.draw_line(aggancio, aggancio + Vector2(0, 16 * k), P.NERO, 4.0)
	P.gira(t, aggancio + Vector2(0, 16 * k), 0.0, k)
	var corpo := Rect2(-34, 10, 68, 50)
	var tinta := P.CREMA if stato == "presa" else (P.ARANCIO if stato == "scelta" else Color("#1c1410"))
	Manifesto.poligono(t, PackedVector2Array([Vector2(-26, 0), Vector2(26, 0), Vector2(38, 12), Vector2(-38, 12)]), P.NERO)
	P.cartoncino(t, corpo, tinta, 3.0, Vector2(4, 4) if stato != "chiusa" else Vector2.ZERO)
	var vetro := Rect2(-24, 18, 48, 30)
	if stato == "chiusa":
		t.draw_rect(vetro, P.BRUNO)
		P.scritta(t, Vector2(-24, 40), str(5 + i), 18, Color(P.CARTA, 0.6), null, HORIZONTAL_ALIGNMENT_CENTER, 48)
	else:
		t.draw_rect(vetro, P.NERO if stato == "presa" else P.CREMA)
		P.glifo(t, String(dati[1]), vetro.get_center(), 26.0, P.ARANCIO if stato == "presa" else P.NERO,
				P.NERO if stato == "presa" else P.CREMA)
	P.dritto(t)


func pannello_della_ruota(t: CanvasItem) -> void:
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, -20), Vector2(548, -20), Vector2(428, 740), Vector2(-20, 740)]), P.CREMA)
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, -20), Vector2(532, -20), Vector2(412, 740), Vector2(-20, 740)]), P.NERO)
	P.etichetta(t, Vector2(28, 24), "LA RUOTA", 44, P.CREMA, P.NERO, P.ARANCIO)
	P.scritta(t, Vector2(34, 118), "Ogni cabina è un livello: si sale una alla volta.", 16, P.CARTA, Caratteri.tondo(800))
	squadra(t, Vector2(30, 136), false)
	var dati := abilita("terra_bruciata")
	P.scritta(t, Vector2(36, 262), "ARRIVI AL", 18, P.CARTA)
	P.ritagliata(t, Vector2(30, 410), str(LIVELLO + 1), 170, P.ARANCIO, P.NERO, 0, P.ARANCIO_SCURO, Vector2(10, 10))
	P.scritta(t, Vector2(160, 300), "LIVELLO", 34, P.CREMA)
	P.scritta(t, Vector2(160, 334), "CABINA %d DI 61" % (LIVELLO + 1), 15, P.CARTA, Caratteri.tondo(900))
	P.scritta(t, Vector2(34, 466), String(dati.get("nome", "")).to_upper(), 38, P.CREMA)
	P.etichetta(t, Vector2(30, 478), "FLAGELLO · GRADO II", 15, P.ARANCIO, P.NERO)
	P.a_capo(t, Rect2(34, 516, 350, 70), String(dati.get("descrizione", "")), 16, P.CARTA)
	P.etichetta(t, Vector2(30, 594), "SALI · 1 PUNTO", 26, P.ARANCIO, P.NERO, P.CREMA)
	P.scritta(t, Vector2(36, 666), "HYPE %s · 3 PUNTI DA SPENDERE" % migliaia(HYPE), 15, P.CARTA)


func tasti_ruota() -> void:
	comandi(Vector2(30, 686), [["SU", "gira"], ["INVIO", "sali"], ["ESC", "indietro"]], P.CARTA)


# --- 5. le spille -------------------------------------------------------------------------
#
# Le passive sono spille (le medaglie di Paper Mario): si sbloccano salendo, e
# sulla fascia ce ne stanno tre. Si tolgono e si rimettono quando vuoi: il
# limite e' il gioco, cambiare idea non costa (docs/albero.md, 4.5).

const SPILLE := [
	["Non c'è tempo!", "clessidra", "portata", ""],
	["La tua immondizia è il mio tesoro", "gemma", "portata", ""],
	["Battito dell'eroe", "battito", "scelta", ""],
	["Trinità", "tre", "chiusa", "LIV. 33"],
	["Presenza minacciosa", "occhio", "chiusa", "LIV. 40"],
	["Furia", "fiamma", "soglia", "FATTORE 15/20"],
	["Perspicacia acuta", "occhio", "soglia", "INTELL. 6/40"],
]


func disegna_spille(t: CanvasItem) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), P.ARANCIO)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO_SCURO, 0.55), Vector2(0.95, 0.05))
	fascia_delle_spille(t)
	bacheca(t)
	P.etichetta(t, Vector2(28, 24), "LE SPILLE", 46, P.NERO, P.CREMA, P.CREMA)
	P.scritta(t, Vector2(34, 120), "ANONIMO · LIVELLO 24", 18, P.NERO)
	P.scritta(t, Vector2(34, 144), "Le passive si appuntano sulla fascia: ce ne stanno tre.", 16, P.NERO, Caratteri.tondo(800))
	dettaglio_spilla(t, Rect2(880, 26, 370, 196))


func spilla(t: CanvasItem, c: Vector2, r: float, glifo: String, stato: String) -> void:
	match stato:
		"vuota":
			t.draw_arc(c, r, 0.0, TAU, 64, Color(P.CREMA, 0.8), 4.0, true)
			for k in 24:
				if k % 2 == 0:
					t.draw_arc(c, r - 10.0, TAU * k / 24.0, TAU * (k + 1) / 24.0, 4, Color(P.CREMA, 0.6), 3.0, true)
			P.scritta(t, c + Vector2(-r, 14), "+", 56, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0)
		"chiusa", "soglia":
			t.draw_circle(c + Vector2(5, 5), r, Color(P.NERO, 0.6), true, -1.0, true)
			t.draw_circle(c, r, P.BRUNO, true, -1.0, true)
			t.draw_arc(c, r, 0.0, TAU, 64, P.NERO, 4.0, true)
			P.glifo(t, glifo, c, r * 1.1, Color(P.CARTA, 0.22), P.BRUNO)
			Sagome.lucchetto(t, c + Vector2(r * 0.6, r * 0.6), r * 0.7, P.CREMA)
		_:
			t.draw_circle(c + Vector2(6, 6), r, P.NERO, true, -1.0, true)
			t.draw_circle(c, r, P.ARANCIO_SCURO if stato != "scelta" else P.ARANCIO, true, -1.0, true)
			t.draw_arc(c, r, 0.0, TAU, 64, P.NERO, 5.0, true)
			t.draw_circle(c, r * 0.78, P.CREMA, true, -1.0, true)
			t.draw_arc(c, r * 0.78, 0.0, TAU, 64, P.NERO, 3.0, true)
			for k in 16:
				var a := TAU * k / 16.0
				t.draw_circle(c + Vector2.from_angle(a) * r * 0.89, r * 0.035, P.NERO, true, -1.0, true)
			P.glifo(t, glifo, c, r * 1.05, P.NERO, P.CREMA)
			t.draw_arc(c + Vector2(-r * 0.25, -r * 0.3), r * 0.5, deg_to_rad(200), deg_to_rad(250), 10, Color(P.LUCE, 0.7), 3.0, true)


func fascia_delle_spille(t: CanvasItem) -> void:
	# LA FASCIA, di traverso: tre spille appuntate, e il posto che si apre piu' avanti
	P.gira(t, Vector2(560, 322), -6.0)
	t.draw_rect(Rect2(-760, -94 + 10, 1560, 188), Color(P.NERO, 0.45))
	t.draw_rect(Rect2(-760, -94, 1560, 188), P.NERO)
	t.draw_rect(Rect2(-760, -70, 1560, 6), P.ARANCIO)
	t.draw_rect(Rect2(-760, 64, 1560, 6), P.ARANCIO)
	for k in 78:
		t.draw_line(Vector2(-760 + 20 * k, -84), Vector2(-750 + 20 * k, -84), Color(P.CREMA, 0.7), 2.0)
		t.draw_line(Vector2(-760 + 20 * k, 84), Vector2(-750 + 20 * k, 84), Color(P.CREMA, 0.7), 2.0)
	var posti := [["clessidra", "portata", "NON C'È TEMPO!"], ["gemma", "portata", "LA TUA IMMONDIZIA..."],
			["", "vuota", "ATTACCANE UNA"]]
	for i in posti.size():
		var c := Vector2(-380 + 240 * i, -8)
		var posto: Array = posti[i]
		t.draw_line(c + Vector2(-26, -62), c + Vector2(26, -62), P.CARTA, 4.0, true)
		spilla(t, c, 58.0, String(posto[0]), String(posto[1]))
		P.scritta(t, c + Vector2(-110, 82), String(posto[2]), 15, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 220)
	var quarto := Vector2(340, -8)
	t.draw_arc(quarto, 58.0, 0.0, TAU, 64, Color(P.CREMA, 0.25), 3.0, true)
	Sagome.lucchetto(t, quarto, 36.0, Color(P.CREMA, 0.4))
	P.scritta(t, quarto + Vector2(-110, 82), "AL LIVELLO 30", 15, Color(P.CREMA, 0.5), null, HORIZONTAL_ALIGNMENT_CENTER, 220)
	P.dritto(t)


func bacheca(t: CanvasItem) -> void:
	P.gira(t, Vector2(40, 506), 1.2)
	P.cartoncino(t, Rect2(0, 0, 968, 186), P.CREMA, 5.0, P.OMBRA, true)
	P.etichetta(t, Vector2(16, -18), "LE TUE SPILLE · 3 DI 24", 18, P.NERO, P.CREMA)
	for i in SPILLE.size():
		var voce: Array = SPILLE[i]
		var c := Vector2(76 + 136 * i, 84)
		var stato := String(voce[2])
		if stato == "scelta":
			t.draw_circle(c, 62.0, Color(P.ARANCIO, 0.35), true, -1.0, true)
			t.draw_arc(c, 62.0, 0.0, TAU, 64, P.NERO, 3.0, true)
		spilla(t, c, 46.0, String(voce[1]), "presa" if stato == "portata" else stato)
		var sotto := String(voce[0]) if String(voce[3]) == "" else String(voce[3])
		P.a_capo(t, Rect2(c.x - 66, 134, 132, 40), sotto, 14, P.NERO, Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER)
		if stato == "portata":
			P.etichetta(t, c + Vector2(-2, -60), "SULLA FASCIA", 11, P.NERO, P.CREMA)
	P.dritto(t)


func dettaglio_spilla(t: CanvasItem, r: Rect2) -> void:
	var dati := {}
	for voce: Dictionary in GameState.crescita.get("passive_livello", []):
		if String(voce.get("id", "")) == "battito_dell_eroe":
			dati = voce
	P.gira(t, r.position, -2.0)
	P.cartoncino(t, Rect2(Vector2.ZERO, r.size), P.NERO, 0.0, P.OMBRA)
	P.etichetta(t, Vector2(16, -16), "SBLOCCATA AL LIVELLO 23", 14, P.ARANCIO, P.NERO)
	P.scritta(t, Vector2(20, 56), "Battito dell'eroe", 32, P.CREMA)
	P.a_capo(t, Rect2(20, 68, r.size.x - 40, 70), String(dati.get("descrizione", "")), 15, P.CARTA)
	P.etichetta(t, Vector2(18, 140), "APPUNTALA", 22, P.ARANCIO, P.NERO, P.CREMA)
	P.dritto(t)


func tasti_spille() -> void:
	comandi(Vector2(1030, 560), [["CLIC", "prendi"]], P.NERO)
	comandi(Vector2(1030, 610), [["INVIO", "appunta"]], P.NERO)
	comandi(Vector2(1030, 660), [["ESC", "indietro"]], P.NERO)


# --- 6. l'indovino --------------------------------------------------------------------------
#
# La stella doppia: un punto, due destini. Al posto di un menu, la macchina
# della fortuna del luna park ti da' due carte, e ne tieni una.

func disegna_indovino(t: CanvasItem) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), Color("#160c07"))
	t.draw_circle(Vector2(700, 760), 520.0, Color(P.ARANCIO, 0.06), true, -1.0, true)
	t.draw_circle(Vector2(700, 760), 380.0, Color(P.ARANCIO, 0.07), true, -1.0, true)
	t.draw_circle(Vector2(700, 760), 250.0, Color(P.LUCE, 0.05), true, -1.0, true)
	tende(t)
	macchina_della_fortuna(t, Vector2(300, 74))
	carta_del_destino(t, Vector2(716, 424), -9.0, "VIII", "cuore", "PIÙ VITA", "+60 PUNTI VITA", "Punti vita", "110", "170", false)
	carta_del_destino(t, Vector2(1020, 404), 6.0, "VIII", "lama", "PIÙ ATTACCO", "+6 ATTACCO", "Attacco", "17", "23", true)
	P.gira(t, Vector2(624, 82), -3.0)
	P.ritagliata(t, Vector2(0, 0), "UNA STELLA,", 44, P.CREMA, P.NERO, 10, P.ARANCIO_SCURO, Vector2(6, 6))
	P.ritagliata(t, Vector2(60, 52), "DUE DESTINI", 50, P.ARANCIO, P.NERO, 10, P.NERO, Vector2(6, 6))
	P.dritto(t)
	P.scritta(t, Vector2(640, 168), "«Fondo del serbatoio» si accende una volta sola. Tienine una.", 16, P.CARTA,
			Caratteri.tondo(800))


func tende(t: CanvasItem) -> void:
	for lato in [0, 1]:
		for k in 7:
			var x := (22.0 * k) if lato == 0 else (1280.0 - 22.0 * (k + 1))
			t.draw_rect(Rect2(x, 0, 22, 720), Color("#3b1d08") if k % 2 == 0 else Color("#24120a"))
	var passo := 1280.0 / 16.0
	for k in 16:
		var c := Vector2(passo * (k + 0.5), 34)
		t.draw_circle(c, passo * 0.52, P.ARANCIO_SCURO if k % 2 == 0 else Color("#8a4a0c"), true, -1.0, true)
	t.draw_rect(Rect2(0, 0, 1280, 36), P.ARANCIO_SCURO)
	t.draw_line(Vector2(0, 36), Vector2(1280, 36), P.NERO, 3.0)
	for k in 33:
		P.lampadina(t, Vector2(40.0 * k + 8, 18), 0.7 + 0.3 * sin(tempo * 2.4 + k), 3.0)


func macchina_della_fortuna(t: CanvasItem, dove: Vector2) -> void:
	P.gira(t, dove, 0.0)
	# l'insegna ad arco con le lampadine
	t.draw_circle(Vector2(140, 66), 128.0, P.NERO, true, -1.0, true)
	t.draw_rect(Rect2(12, 66, 256, 40), P.NERO)
	t.draw_arc(Vector2(140, 66), 118.0, PI, TAU, 40, P.ARANCIO, 3.0, true)
	for k in 15:
		P.lampadina(t, Vector2(140, 66) + Vector2.from_angle(PI + PI * k / 14.0) * 108.0, 0.7 + 0.3 * sin(tempo * 3.0 + k), 3.2)
	P.scritta(t, Vector2(12, 60), "Il Destino", 40, P.CREMA, Caratteri.nomi(), HORIZONTAL_ALIGNMENT_CENTER, 256)
	# il mobile
	P.cartoncino(t, Rect2(20, 100, 240, 556), P.ARANCIO_SCURO, 6.0, Vector2(12, 12))
	t.draw_rect(Rect2(34, 114, 212, 528), P.NERO, false, 3.0)
	# la vetrina, e dentro lui
	t.draw_rect(Rect2(44, 128, 192, 248), Color("#1d110a"))
	var testa := Vector2(140, 222)
	Manifesto.poligono(t, PackedVector2Array([Vector2(66, 376), Vector2(84, 300), Vector2(196, 300), Vector2(214, 376)]), P.NERO)
	t.draw_circle(testa, 40.0, P.NERO, true, -1.0, true)
	Manifesto.poligono(t, PackedVector2Array([testa + Vector2(-46, -12), testa + Vector2(-30, -52), testa + Vector2(0, -64),
			testa + Vector2(30, -52), testa + Vector2(46, -12), testa + Vector2(0, -24)]), P.CREMA)
	Manifesto.poligono(t, Sagome.rombo(testa + Vector2(0, -34), 9.0), P.ARANCIO)
	for occhio in [-14.0, 14.0]:
		t.draw_circle(testa + Vector2(occhio, 4), 7.0, Color(P.ARANCIO, 0.35), true, -1.0, true)
		t.draw_circle(testa + Vector2(occhio, 4), 3.5, P.ARANCIO, true, -1.0, true)
	var palla := Vector2(140, 336)
	t.draw_circle(palla, 44.0, Color(P.LUCE, 0.12), true, -1.0, true)
	t.draw_circle(palla, 30.0, Color(P.LUCE, 0.55 + 0.15 * sin(tempo * 2.0)), true, -1.0, true)
	t.draw_circle(palla + Vector2(-9, -9), 8.0, Color(P.LUCE, 0.9), true, -1.0, true)
	for lato in [-1.0, 1.0]:
		Manifesto.poligono(t, PackedVector2Array([palla + Vector2(lato * 30, 10), palla + Vector2(lato * 52, -4),
				palla + Vector2(lato * 60, 12), palla + Vector2(lato * 36, 22)]), P.CREMA)
	for k in 2:
		t.draw_line(Vector2(56 + 60 * k, 136), Vector2(96 + 60 * k, 360), Color(P.LUCE, 0.08), 14.0)
	t.draw_rect(Rect2(44, 128, 192, 248), P.NERO, false, 6.0)
	# la fessura delle carte e quella delle monete
	P.etichetta(t, Vector2(56, 400), "UNA STELLA · DUE CARTE", 13, P.NERO, P.CREMA)
	t.draw_rect(Rect2(76, 452, 128, 14), P.NERO)
	t.draw_rect(Rect2(124, 500, 32, 44), P.NERO)
	t.draw_rect(Rect2(132, 508, 16, 28), P.CARTA)
	for k in 2:
		t.draw_rect(Rect2(40 + 168 * k, 656, 32, 30), P.NERO)
	P.dritto(t)


func carta_del_destino(t: CanvasItem, c: Vector2, gradi: float, numero: String, glifo: String, titolo: String,
		quanto: String, che_cosa: String, prima: String, dopo: String, scelta: bool) -> void:
	var r := Rect2(-120, -176, 240, 352)
	P.gira(t, c + Vector2(0, -18 if scelta else 0), gradi, 1.06 if scelta else 1.0)
	if scelta:
		t.draw_rect(r.grow(12), P.ARANCIO)
		t.draw_rect(r.grow(12), P.NERO, false, 3.0)
	P.cartoncino(t, r, P.CREMA, 6.0, Vector2(10, 10), true)
	t.draw_rect(r.grow(-14), P.NERO, false, 2.0)
	P.scritta(t, Vector2(-120, -138), numero, 26, P.NERO, Caratteri.nomi(), HORIZONTAL_ALIGNMENT_CENTER, 240)
	P.scoppio(t, Vector2(0, -40), 74.0, 56.0, 16, P.ARANCIO if scelta else P.CARTA, P.NERO, 0.0)
	t.draw_circle(Vector2(0, -40), 50.0, P.CREMA, true, -1.0, true)
	t.draw_arc(Vector2(0, -40), 50.0, 0.0, TAU, 48, P.NERO, 3.0, true)
	P.glifo(t, glifo, Vector2(0, -40), 66.0, P.NERO, P.CREMA)
	P.fascia(t, Rect2(-104, 30, 208, 42), P.NERO)
	P.scritta(t, Vector2(-104, 60), titolo, 24, P.CREMA, null, HORIZONTAL_ALIGNMENT_CENTER, 208)
	P.scritta(t, Vector2(-120, 100), quanto, 20, P.ARANCIO_SCURO, null, HORIZONTAL_ALIGNMENT_CENTER, 240)
	P.scritta(t, Vector2(-96, 140), che_cosa, 15, P.NERO, Caratteri.tondo(900))
	P.scritta(t, Vector2(-30, 142), "%s → %s" % [prima, dopo], 22, P.NERO, null, HORIZONTAL_ALIGNMENT_RIGHT, 126)
	P.dritto(t)


func tasti_indovino() -> void:
	comandi(Vector2(640, 690), [["CLIC", "scegli"], ["INVIO", "tienila"], ["ESC", "ci penso"]], P.CARTA)
