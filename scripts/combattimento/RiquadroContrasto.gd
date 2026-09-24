class_name RiquadroContrasto
extends Control

# IL RIQUADRO DELLA MAZZATA: suo dall'inizio alla fine, come quello della
# raffica (RiquadroRaffica.gd), e per le stesse ragioni - e' una faccia del
# quadrante, opaca, con un titolo e un bordo, non uno strato sopra.
#
# UNA BARRA SOLA, e si legge senza istruzioni: la parte verde e' tua, la rossa
# e' della mazza. Ogni pressione spinge il confine verso destra, il goblin lo
# riporta indietro. Verde fino in fondo: l'hai respinta. Rossa fino in fondo:
# la mazza cala. Sotto, una linea gialla che si accorcia: e' il tempo che la
# mazza ti concede prima di calare comunque.
#
# ALL'IMPROVVISO, MA NON AL BUIO. Bru la vuole «una mazzata che arriva
# all'improvviso»: il riquadro compare con un lampo rosso e due colpi secchi
# (il suono "allarme"), e la cosa da fare e' scritta in grande nel riquadro
# stesso, nel momento in cui serve. Per il primo mezzo secondo la mazza non
# spinge ancora (ContrastoCombattimento.REAZIONE): la sorpresa e' nel quando,
# non nel non capire cosa fare.
#
# IL CLIC CONTA COME IL TASTO, e conta quando premi (non al rilascio): chi gioca
# col mouse deve poter martellare anche lui. E' la stessa scelta della raffica.

const ALTEZZA_TESTATA := 44.0
const MARGINE := 12.0
const DURATA_SCOSSA := 0.12
const AMPIEZZA_SCOSSA := 3.0
const LAMPO := 0.35   # quanto dura il lampo rosso all'arrivo

var gioco: ContrastoCombattimento
var testata: ColorRect
var titolo: Label
var contatore: Label
var avviso: Label
var scossa := 0.0
var dado := RandomNumberGenerator.new()


func _init(chi: ContrastoCombattimento) -> void:
	gioco = chi


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	testata = ColorRect.new()
	testata.color = Stile.colore("fascia_nemico")
	testata.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(testata)
	titolo = etichetta(Stile.dimensione("corpo"))
	testata.add_child(titolo)
	contatore = etichetta(Stile.dimensione("corpo"))
	contatore.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	testata.add_child(contatore)
	avviso = etichetta(Stile.dimensione("sezione"))
	avviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avviso.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(avviso)
	resized.connect(disponi)
	disponi()


func etichetta(corpo: int) -> Label:
	var fatta := Label.new()
	fatta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fatta.add_theme_color_override("font_color", Stile.colore("testo"))
	Stile.imposta_corpo(fatta, corpo)
	return fatta


func disponi() -> void:
	# tutto dal rettangolo del pannello, come la raffica: la finestra cambia
	# misura, e con lei il quadrante
	if testata == null:
		return
	testata.size = Vector2(size.x, ALTEZZA_TESTATA)
	titolo.position = Vector2(MARGINE, 0.0)
	titolo.size = Vector2(size.x * 0.6, ALTEZZA_TESTATA)
	titolo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	contatore.position = Vector2(size.x * 0.4, 0.0)
	contatore.size = Vector2(size.x * 0.6 - MARGINE, ALTEZZA_TESTATA)
	contatore.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var piano := rettangolo_piano()
	avviso.position = piano.position
	avviso.size = Vector2(piano.size.x, piano.size.y * 0.5)


func rettangolo_piano() -> Rect2:
	var alto := ALTEZZA_TESTATA + MARGINE
	return Rect2(Vector2(MARGINE, alto), Vector2(maxf(size.x - MARGINE * 2.0, 1.0),
			maxf(size.y - alto - MARGINE, 1.0)))


func rettangolo_barra() -> Rect2:
	# la meta' bassa del piano, e dentro quella una fascia spessa: abbastanza
	# grossa da leggerla con la coda dell'occhio mentre guardi il tasto
	var piano := rettangolo_piano()
	var alta := clampf(piano.size.y * 0.24, 18.0, 44.0)
	var y := piano.position.y + piano.size.y * 0.5 + (piano.size.y * 0.5 - alta) * 0.35
	return Rect2(Vector2(piano.position.x, y), Vector2(piano.size.x, alta))


# --- cosa si dice ----------------------------------------------------------

func comincia(nome: String) -> void:
	titolo.text = "%s!" % nome.to_upper()
	avviso.text = "Premi SPAZIO a raffica!"
	scossa = 0.0
	AudioManager.interfaccia("allarme")
	aggiorna(0.0)


func chiudi(esito: Dictionary) -> void:
	var secondi := String.num(float(esito.get("secondi", 0.0)), 1).replace(".", ",")
	if bool(esito.get("vinto", false)):
		avviso.text = "PARATA!\n%d colpi in %s secondi" % [int(esito.get("pressioni", 0)), secondi]
	else:
		avviso.text = "TI HA BATTUTO\nLa mazza cala."


func pressione() -> void:
	# ogni colpo si sente e si vede: un tic, e la barra che sobbalza. Chi ha
	# chiesto meno movimento sente il tic e vede la barra ferma
	AudioManager.tocco("sfiora")
	if not Impostazioni.movimento_ridotto:
		scossa = DURATA_SCOSSA


func aggiorna(delta: float) -> void:
	if titolo == null:
		return
	contatore.text = "× %d" % gioco.pressioni
	scossa = maxf(scossa - delta, 0.0)
	queue_redraw()


func _gui_input(evento: InputEvent) -> void:
	var premuto := evento is InputEventMouseButton \
			and (evento as InputEventMouseButton).pressed \
			and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	if not premuto:
		return
	accept_event()
	gioco.premi_col_tasto()


# --- il disegno ------------------------------------------------------------

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Stile.colore("ecg_fondo"))
	if gioco.fase == "reazione" and not Impostazioni.movimento_ridotto:
		# il lampo dell'arrivo: parte forte e si spegne entro LAMPO secondi
		var quanto := clampf(1.0 - gioco.tempo_fase / LAMPO, 0.0, 1.0)
		draw_rect(Rect2(Vector2.ZERO, size), Color(Stile.colore("pericolo"), 0.45 * quanto))
	var barra := rettangolo_barra()
	if scossa > 0.0:
		barra.position += Vector2(dado.randf_range(-1.0, 1.0), dado.randf_range(-1.0, 1.0)) \
				* AMPIEZZA_SCOSSA * (scossa / DURATA_SCOSSA)
	draw_rect(barra, Stile.colore("pericolo"))
	var tua := barra.size.x * clampf(gioco.forza, 0.0, 1.0)
	draw_rect(Rect2(barra.position, Vector2(tua, barra.size.y)), Stile.colore("positivo"))
	# il confine: e' li' che si combatte, quindi e' la cosa piu' chiara di tutte
	var confine := barra.position.x + tua
	draw_line(Vector2(confine, barra.position.y - 6.0), Vector2(confine, barra.end.y + 6.0),
			Stile.colore("testo"), 4.0)
	draw_rect(barra, Stile.colore("testo"), false, 2.0)
	disegna_tempo(barra)


func disegna_tempo(barra: Rect2) -> void:
	# il tempo che resta prima che la mazza cali comunque: pieno durante la
	# reazione, poi si accorcia verso sinistra
	if gioco.fase == "chiusura":
		return
	var durata := maxf(float(gioco.fisica.get("durata", 1.0)), 0.001)
	var resta := clampf(1.0 - gioco.tempo / durata, 0.0, 1.0)
	var y := barra.end.y + 12.0
	draw_line(Vector2(barra.position.x, y), Vector2(barra.position.x + barra.size.x * resta, y),
			Stile.colore("ecg_giallo"), 4.0)
