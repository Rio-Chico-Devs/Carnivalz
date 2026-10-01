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
	if not righe.is_empty():
		# le partite stanno su un foglio del manifesto, e l'etichetta ci si appoggia sopra
		var giu := TESTA + float(righe.size()) * (RIGA + STACCO) - STACCO
		Manifesto.carta(self, Rect2(-14.0, TESTA - 10.0, LARGO + 28.0, giu - TESTA + 24.0),
				Color(Stile.colore("plancia_pannello"), arrivo))
	testata()
	for i in righe.size():
		riga(i, Rect2(0.0, TESTA + float(i) * (RIGA + STACCO), LARGO, RIGA))
	draw_set_transform(Vector2.ZERO)


func testata() -> void:
	# L'ETICHETTA del manifesto, e accanto la pillola chiara con quante partite
	# ci sono: com'e' nel bozzetto approvato
	var titolo := Caratteri.titolo()
	if titolo == null:
		return
	var largo := titolo.get_string_size("LE TUE PARTITE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	Manifesto.poligono(self, VoceMenu.lastra(-12.0, largo + 12.0, -4.0, 30.0), Color(Stile.colore("bordo"), arrivo))
	draw_string(titolo, Vector2(4, 19), "LE TUE PARTITE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20,
			Color(Stile.colore("testo"), arrivo))
	var conto := "%d / %d" % [Partite.occupate().size(), GameState.SLOT_MASSIMO]
	var pillola := Rect2(LARGO - 62.0, -2.0, 62.0, 26.0)
	draw_style_box(Manifesto.stile_pillola(Color(Stile.colore("bordo_acceso"), arrivo)), pillola)
	draw_string(titolo, Vector2(pillola.position.x, 17), conto, HORIZONTAL_ALIGNMENT_CENTER, pillola.size.x, 16,
			Color(Stile.colore("box_testo"), arrivo))


func riga(i: int, dove: Rect2) -> void:
	# UNA PARTITA SUL FOGLIO: la riga chiara con la sua linea tratteggiata sotto,
	# come un modulo da riempire; quella piu' recente ha il bordo nero
	var quanto := quota_riga(i)
	if quanto <= 0.0:
		return
	var dati: Dictionary = righe[i]
	var accesa_qui := int(dati.slot) == accesa
	draw_rect(dove, Color(Stile.colore("box_fondo"), quanto))
	if accesa_qui:
		draw_rect(dove.grow(-1.0), Color(Stile.colore("bordo"), quanto), false, 2.0)
	var x := dove.position.x
	while x < dove.end.x:
		draw_line(Vector2(x, dove.end.y - 1.0), Vector2(minf(x + 8.0, dove.end.x), dove.end.y - 1.0),
				Color(Stile.colore("bordo"), quanto), 2.0)
		x += 14.0
	var carattere := Caratteri.titolo()
	var testo := Stile.colore("box_testo")
	if not bool(dati.piena):
		draw_string(carattere, dove.position + Vector2(12, 23), "Partita libera…",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(Stile.colore("comando_spento"), quanto))
		return
	draw_string(carattere, dove.position + Vector2(12, 23), "%d  %s" % [int(dati.slot), String(dati.nome)],
			HORIZONTAL_ALIGNMENT_LEFT, dove.size.x - 80.0, 18, Color(testo, quanto))
	cartellino_livello(dove, int(dati.livello), quanto)
	if accesa_qui:
		segno_della_recente(dove.position + Vector2(-2, 2), quanto)


func cartellino_livello(dove: Rect2, livello: int, quanto: float) -> void:
	# il livello in un cartellino nero a destra, la scritta chiara
	var titolo := Caratteri.titolo()
	var tessera := Rect2(dove.end.x - 58.0, dove.position.y + 6.0, 50.0, dove.size.y - 12.0)
	var fondo := StyleBoxFlat.new()
	fondo.set_corner_radius_all(3)
	fondo.bg_color = Color(Stile.colore("bordo"), quanto)
	draw_style_box(fondo, tessera)
	if titolo != null:
		draw_string(titolo, Vector2(tessera.position.x, tessera.end.y - 4.0), "LV %d" % livello,
				HORIZONTAL_ALIGNMENT_CENTER, tessera.size.x, 17, Color(Stile.colore("testo"), quanto))


func segno_della_recente(dove: Vector2, quanto: float) -> void:
	# il rombo cremisi, appoggiato di traverso sull'angolo: e' la partita che
	# CONTINUA riprende, e il cremisi qui vuol dire la stessa cosa che nella
	# voce scelta - «questa»
	var r := 7.0
	var rombo := PackedVector2Array([dove + Vector2(0, -r), dove + Vector2(r, 0), dove + Vector2(0, r),
			dove + Vector2(-r, 0)])
	Manifesto.poligono(self, rombo, Color(Stile.colore("accento"), quanto))
	rombo.append(rombo[0])
	draw_polyline(rombo, Color(Stile.colore("menu_macchia"), quanto), 2.0, true)
