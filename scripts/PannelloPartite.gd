class_name PannelloPartite
extends Control

# IN ALTO A DESTRA, LE TUE PARTITE - dove nel riferimento di Bru (Borderlands 2)
# c'e' la squadra: un titolo con un contatore, e quattro righe una sotto
# l'altra, la prima accesa e le altre spente («Invite friend...»).
#
# Qui le righe sono le cinque partite. La piu' recente - quella che «CONTINUA»
# riprende - e' accesa, col segno di Carnivalz a sinistra dove li' c'e' la
# corona; le libere dicono «Partita libera…» e stanno piu' indietro. Il
# contatore in alto conta le partite in uso, con cinque tacche come le tacche
# del segnale del riferimento.
#
# NON SI CLICCA. E' un quadro, non un menu: Bru non vuole che la schermata
# principale «ti sbatta subito gli slot». Le partite si scelgono passando da
# CONTINUA, NUOVA PARTITA o CARICA PARTITA; qui si guarda e basta.

const LARGO := 300.0
const TESTA := 30.0
const RIGA := 34.0
const STACCO := 5.0
const TACCA := Vector2(4, 12)

var accesa := 0                    # la partita piu' recente; 0 = nessuna
var righe: Array[Dictionary] = []
var orologio := -1.0
var ritardo := 0.0
var arrivo := 1.0                  # 0..1: quanto e' entrato il pannello


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(LARGO, TESTA + (RIGA + STACCO) * GameState.SLOT_MASSIMO)
	set_process(false)


func aggiorna() -> void:
	accesa = Partite.piu_recente()
	righe.clear()
	for slot in range(1, GameState.SLOT_MASSIMO + 1):
		var piena := Partite.piena(slot)
		righe.append({"slot": slot, "piena": piena,
				"nome": Partite.nome(slot) if piena else "",
				"livello": Partite.livello(slot) if piena else 0})
	queue_redraw()


func entra(quando: float) -> void:
	ritardo = quando
	orologio = 0.0
	arrivo = 0.0
	set_process(true)


func _process(delta: float) -> void:
	avanza(delta)


func avanza(dt: float) -> void:
	if orologio < 0.0:
		set_process(false)
		return
	orologio += dt
	var durata := Movimento.durata("colore" if Movimento.ridotto() else "entrata")
	arrivo = Movimento.curva("entrata", (orologio - ritardo) / durata)
	if orologio - ritardo >= durata + 0.2:
		orologio = -1.0
		arrivo = 1.0
	queue_redraw()


func quota_riga(i: int) -> float:
	# le righe scendono una dopo l'altra, trenta millesimi fra l'una e l'altra
	return clampf(arrivo * 1.6 - float(i) * 0.12, 0.0, 1.0)


func _draw() -> void:
	var entrato := 0.0 if Movimento.ridotto() else (1.0 - arrivo) * 40.0
	draw_set_transform(Vector2(entrato, 0.0))
	testata()
	for i in righe.size():
		riga(i, Rect2(0.0, TESTA + float(i) * (RIGA + STACCO), LARGO, RIGA))
	draw_set_transform(Vector2.ZERO)


func testata() -> void:
	var chiaro := Color(Stile.colore("menu_chiaro"), arrivo)
	var titolo := Caratteri.titolo()
	if titolo != null:
		draw_string_outline(titolo, Vector2(26, 22), "LE TUE PARTITE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Testata.bordo(20),
				Color(Stile.colore("menu_macchia"), arrivo))
		draw_string(titolo, Vector2(26, 22), "LE TUE PARTITE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, chiaro)
	# il segno della squadra, due teste, come nel riferimento
	draw_circle(Vector2(8, 13), 4.0, chiaro)
	draw_circle(Vector2(17, 13), 4.0, chiaro)
	# le tacche: una per partita, piene quelle in uso
	var in_uso := Partite.occupate().size()
	for t in GameState.SLOT_MASSIMO:
		var dove := Vector2(LARGO - 92.0 + t * 7.0, 20.0 - TACCA.y)
		draw_rect(Rect2(dove, TACCA), Color(Stile.colore("menu_scia"), arrivo * (1.0 if t < in_uso else 0.25)))
	var tondo := Caratteri.tondo(800)
	if tondo != null:
		draw_string(tondo, Vector2(LARGO - 52.0, 21), "[%d/%d]" % [in_uso, GameState.SLOT_MASSIMO],
				HORIZONTAL_ALIGNMENT_LEFT, -1, 17, chiaro)


func riga(i: int, dove: Rect2) -> void:
	var quanto := quota_riga(i)
	if quanto <= 0.0:
		return
	var dati: Dictionary = righe[i]
	var accesa_qui := int(dati.slot) == accesa
	var fondo := StyleBoxFlat.new()
	fondo.set_corner_radius_all(4)
	fondo.bg_color = Color(Stile.colore("menu_riga_accesa" if accesa_qui else "menu_riga"),
			(0.88 if accesa_qui else 0.7) * quanto)
	fondo.set_border_width_all(2 if accesa_qui else 1)
	fondo.border_color = Color(Stile.colore("menu_riga_accesa_bordo" if accesa_qui else "menu_riga_bordo"),
			(0.9 if accesa_qui else 0.5) * quanto)
	draw_style_box(fondo, dove)
	var tondo := Caratteri.tondo(700)
	if tondo == null:
		return
	var testo := Stile.colore("menu_descrizione")
	if not bool(dati.piena):
		draw_string(tondo, Vector2(dove.position.x, dove.position.y + 23.0), "Partita libera…",
				HORIZONTAL_ALIGNMENT_CENTER, dove.size.x, 17, Color(testo, 0.62 * quanto))
		return
	draw_string(tondo, dove.position + Vector2(14, 23), "%d  %s" % [int(dati.slot), String(dati.nome)],
			HORIZONTAL_ALIGNMENT_LEFT, dove.size.x - 80.0, 18, Color(testo, quanto))
	cartellino_livello(dove, int(dati.livello), quanto)
	if accesa_qui:
		segno_della_recente(dove.position + Vector2(-2, 2), quanto)


func cartellino_livello(dove: Rect2, livello: int, quanto: float) -> void:
	# il livello in un cartellino chiaro a destra, come il numero del riferimento
	var titolo := Caratteri.titolo()
	var tessera := Rect2(dove.end.x - 58.0, dove.position.y + 6.0, 50.0, dove.size.y - 12.0)
	var fondo := StyleBoxFlat.new()
	fondo.set_corner_radius_all(3)
	fondo.bg_color = Color(Stile.colore("menu_chiaro"), 0.9 * quanto)
	draw_style_box(fondo, tessera)
	if titolo != null:
		draw_string(titolo, Vector2(tessera.position.x, tessera.end.y - 4.0), "LV %d" % livello,
				HORIZONTAL_ALIGNMENT_CENTER, tessera.size.x, 17, Color(Stile.colore("menu_macchia"), quanto))


func segno_della_recente(dove: Vector2, quanto: float) -> void:
	# il rombo cremisi, appoggiato di traverso sull'angolo: e' la partita che
	# CONTINUA riprende, e il cremisi qui vuol dire la stessa cosa che nella
	# voce scelta - «questa»
	var r := 7.0
	var rombo := PackedVector2Array([dove + Vector2(0, -r), dove + Vector2(r, 0), dove + Vector2(0, r),
			dove + Vector2(-r, 0)])
	draw_colored_polygon(rombo, Color(Stile.colore("accento"), quanto))
	rombo.append(rombo[0])
	draw_polyline(rombo, Color(Stile.colore("menu_macchia"), quanto), 2.0, true)
