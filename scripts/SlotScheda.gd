class_name SlotScheda
extends Button

# UNA CASELLA DELL'EQUIPAGGIAMENTO, nel carosello in basso a sinistra (F1-F3).
#
# Il carosello mostra tre slot alla volta: al centro, grande, quello su cui
# sei; ai lati il precedente e il successivo, piu' piccoli. Premendo una
# laterale il carosello gira; premendo quella al centro si apre la scelta di
# cosa metterci. Uno slot chiuso lo dice e dice quando si apre: un premio che
# non sai di poter vincere non e' un premio (vedi Personaggio.gd).
#
# Dentro: in alto che slot e' (ARMA, STIGMA...), in mezzo il disegno di quello
# che ci hai messo - o la sagoma vuota dello slot, spenta - e in fondo il nome.

signal presa(casella: SlotScheda)
signal gira(verso: int)
signal compagno(verso: int)     # su e giu': il compagno prima o dopo, senza lasciare il carosello

const SFOGLIA := Vector2(6, 5)
const SAGOMA_DI_SLOT := {"arma": "arma", "stigma": "stigma", "ultima_risorsa": "consumabile",
		"accessori": "accessorio"}

var dati: Dictionary = {}       # slot, indice, etichetta, oggetto, aperto, livello, talento
var al_centro := false
var in_scelta := false          # si sta scegliendo cosa metterci
var accesa: Movimento.Molla
var rifiutata := -1.0


func _init() -> void:
	accesa = Movimento.molla("colore")
	flat = true
	clip_text = true      # la misura la decide la tavola, non la scritta nel carattere del tema
	focus_mode = Control.FOCUS_ALL
	for stato in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		add_theme_stylebox_override(stato, StyleBoxEmpty.new())
	for chiave in TastoObliquo.COLORI_TESTO:
		add_theme_color_override(chiave, Color(0, 0, 0, 0))
	set_process(false)


func _ready() -> void:
	mouse_entered.connect(accendi)
	mouse_exited.connect(spegni_se_libera)
	focus_entered.connect(accendi)
	focus_exited.connect(spegni_se_libera)
	gui_input.connect(_su_input)
	pressed.connect(func() -> void:
		if al_centro and not bool(dati.get("aperto", true)):
			rifiuta()
			return
		Movimento.suona("pressione")
		presa.emit(self))


func carica(nuovi: Dictionary, centro: bool, scegliendo: bool) -> void:
	dati = nuovi
	al_centro = centro
	in_scelta = scegliendo
	text = String(dati.get("etichetta", ""))
	visible = not dati.is_empty()
	# la tastiera sta solo al centro: le laterali si cliccano, non ci si arriva
	# col tab (ci si arriva girando)
	focus_mode = Control.FOCUS_ALL if centro else Control.FOCUS_CLICK
	queue_redraw()


func _su_input(evento: InputEvent) -> void:
	# LA TASTIERA SULLA SCHEDA STA TUTTA QUI: destra e sinistra girano il
	# carosello, su e giu' cambiano compagno, INVIO apre lo slot, ESC torna.
	# Un punto solo da cui si fa tutto, invece di un fuoco da portare in giro
	if evento.is_action_pressed("ui_left") or evento.is_action_pressed("ui_right"):
		gira.emit(-1 if evento.is_action_pressed("ui_left") else 1)
		accept_event()
	elif evento.is_action_pressed("ui_up") or evento.is_action_pressed("ui_down"):
		compagno.emit(-1 if evento.is_action_pressed("ui_up") else 1)
		accept_event()
	elif evento is InputEventMouseButton and evento.pressed \
			and evento.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		# la rotella gira il carosello, come scorre lo scaffale del negozio
		gira.emit(-1 if evento.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		accept_event()


func accendi() -> void:
	if accesa.obiettivo >= 1.0:
		return
	accesa.obiettivo = 1.0
	if Movimento.ridotto():
		accesa.salta_a(1.0)
	Movimento.suona("sfioro")
	sveglia()


func spegni_se_libera() -> void:
	if has_focus() or is_hovered():
		return
	accesa.obiettivo = 0.0
	if Movimento.ridotto():
		accesa.salta_a(0.0)
	sveglia()


func rifiuta() -> void:
	Movimento.suona("rifiuto")
	if not Movimento.ridotto():
		rifiutata = 0.0
	sveglia()


func sveglia() -> void:
	queue_redraw()
	set_process(true)


func _process(delta: float) -> void:
	accesa.passo(delta)
	rifiutata = TastoObliquo.scorri(rifiutata, delta, Movimento.durata_scossa())
	queue_redraw()
	set_process(not accesa.ferma() or rifiutata >= 0.0)


func _draw() -> void:
	if dati.is_empty():
		return
	var scossa := Vector2(Movimento.scossa(rifiutata) if rifiutata >= 0.0 else 0.0, 0.0)
	var r := Rect2(scossa, size)
	if al_centro:
		draw_rect(Rect2(r.position + SFOGLIA, r.size), Stile.colore("bordo_acceso"))
	var fondo := Stile.colore("accento") if in_scelta else Stile.colore("pannello_chiaro")
	draw_rect(r, fondo)
	var bordo := Stile.colore("spento").lerp(Stile.colore("bordo_acceso"), clampf(accesa.valore, 0.0, 1.0))
	if al_centro and not in_scelta:
		bordo = Stile.colore("accento").lerp(Stile.colore("bordo_acceso"), clampf(accesa.valore, 0.0, 1.0))
	draw_rect(r, bordo, false, 3.0 if al_centro else 2.0)
	disegna_contenuto(r)


func disegna_contenuto(r: Rect2) -> void:
	var titolo := Caratteri.titolo()
	var tondo := Caratteri.tondo(800)
	if titolo == null or tondo == null:
		return
	var corpo_slot := 18 if al_centro else 15
	draw_string(titolo, r.position + Vector2(10, 10 + corpo_slot), text, HORIZONTAL_ALIGNMENT_LEFT,
			r.size.x - 20, corpo_slot, Stile.colore("testo") if al_centro or in_scelta else Stile.colore("testo_smorzato"))
	var lato := minf(r.size.x, r.size.y) * 0.46
	var centro := r.position + Vector2(r.size.x * 0.5, r.size.y * 0.47)
	var id_oggetto := String(dati.get("oggetto", ""))
	var sotto := Rect2(r.position.x + 8, r.end.y - 40, r.size.x - 16, 36)
	if not bool(dati.get("aperto", true)):
		Sagome.lucchetto(self, centro, lato * 0.8, Stile.colore("spento"))
		scrivi_sotto(tondo, sotto, "SI APRE AL LIVELLO %d" % int(dati.get("livello", 0)), Stile.colore("testo_smorzato"))
		return
	if id_oggetto == "":
		var sagoma: String = SAGOMA_DI_SLOT.get(String(dati.get("slot", "")), "speciale")
		Sagome.icona_oggetto(self, centro, lato, sagoma, Color(Stile.colore("testo"), 0.14), Stile.colore("pannello_chiaro"))
		# "vuoto" e' uno stato; "+ metti qualcosa" e' un invito
		scrivi_sotto(tondo, sotto, "+ METTI QUALCOSA", Stile.colore("bordo_acceso") if in_scelta else Stile.colore("accento"))
		return
	var disegno := Sagome.immagine_oggetto(id_oggetto)
	if disegno != null:
		Sagome.disegna_dentro(self, disegno, Rect2(centro - Vector2(lato, lato) * 0.6, Vector2(lato, lato) * 1.2))
	else:
		Sagome.icona_oggetto(self, centro, lato, Sagome.tipo_icona(id_oggetto), Stile.colore("testo"),
				Stile.colore("accento") if in_scelta else Stile.colore("pannello_chiaro"))
	scrivi_sotto(tondo, sotto, Merce.nome_di(id_oggetto), Stile.colore("testo"))


func scrivi_sotto(f: Font, dove: Rect2, scritta: String, colore: Color) -> void:
	var corpo := 14 if al_centro else 13
	draw_multiline_string(f, Vector2(dove.position.x, dove.position.y + corpo), scritta,
			HORIZONTAL_ALIGNMENT_CENTER, dove.size.x, corpo, 2, colore)
