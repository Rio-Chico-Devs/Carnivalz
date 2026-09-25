class_name CartaNegozio
extends Button

# UNA CARTA DELLO SCAFFALE: un oggetto in vendita (o un baratto).
#
# La forma e' quella dello schema di Bru: un parallelogramma largo 122 in
# cima, alto 190, che in basso si sposta di 91 a sinistra - la stessa pendenza
# della vetrina. Dentro, dall'alto: il prezzo, il nome, il disegno. Sotto, fuori
# dalla carta, due o tre parole che dicono se la puoi prendere.
#
# COME SI MUOVE. Passandoci sopra (o arrivandoci con le frecce) la carta si
# alza di otto pixel e il bordo si accende: sono due molle diverse, la forma e
# il colore, come vuole Material. Scelta, diventa cremisi e le compare sotto la
# sfoglia bianca - la stessa lastra doppia delle voci della pausa. Premuta, si
# schiaccia (la gelatina).
#
# I CLIC SI PRENDONO SOLO DENTRO LA CARTA: il riquadro che la contiene e'
# largo 213 e si sovrappone ai due vicini, e senza _has_point il bordo destro
# di una carta rubava i clic alla carta dopo.

signal presa(carta: CartaNegozio, da_tastiera: bool)
signal sposta(verso: int)

const LARGO := 122.0
const ALTO := 190.0
const PENDENZA := 0.48
const SPOSTA_BASSO := 91.0
const SOLLEVA := 8.0
const SFOGLIA := Vector2(6, 5)
const LATO_ICONA := 84.0
const CORPO_PREZZO := 34
const CORPO_NOME := 13
const CORPO_STATO := 12
const SPENTA := 0.42           # quanto si vede il contenuto di una carta che non puoi prendere

var voce: Dictionary = {}
var scelta := false
var accesa: Movimento.Molla
var alzata: Movimento.Molla
var premuta := -1.0
var da_tastiera := false


func _init() -> void:
	accesa = Movimento.molla("colore")
	alzata = Movimento.molla("forma")
	flat = true
	focus_mode = Control.FOCUS_ALL
	size = Vector2(LARGO + SPOSTA_BASSO, ALTO)
	for stato in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		add_theme_stylebox_override(stato, StyleBoxEmpty.new())
	for chiave in TastoObliquo.COLORI_TESTO:
		add_theme_color_override(chiave, Color(0, 0, 0, 0))
	set_process(false)


func _ready() -> void:
	pivot_offset = size * 0.5
	mouse_entered.connect(accendi)
	mouse_exited.connect(spegni_se_libera)
	focus_entered.connect(accendi)
	focus_exited.connect(spegni_se_libera)
	gui_input.connect(_su_input)
	button_down.connect(func() -> void:
		if not Movimento.ridotto():
			premuta = 0.0
			sveglia())
	pressed.connect(func() -> void:
		Movimento.suona("pressione")
		presa.emit(self, da_tastiera)
		da_tastiera = false)


func carica(nuova: Dictionary, e_scelta: bool) -> void:
	voce = nuova
	scelta = e_scelta
	text = Merce.nome_di(String(voce.get("oggetto", "")))
	visible = not voce.is_empty()
	queue_redraw()


func _su_input(evento: InputEvent) -> void:
	# LE FRECCE SCORRONO LO SCAFFALE, non saltano al primo tasto a destra: le
	# prende la carta prima che Godot sposti il fuoco da solo. E la rotella
	# del mouse fa lo stesso
	if evento.is_action_pressed("ui_left") or evento.is_action_pressed("ui_right"):
		sposta.emit(-1 if evento.is_action_pressed("ui_left") else 1)
		accept_event()
	elif evento is InputEventMouseButton and evento.pressed \
			and evento.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		sposta.emit(-1 if evento.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		accept_event()
	elif not evento is InputEventMouse and evento.is_action_pressed("ui_accept"):
		da_tastiera = true


# --- i gesti ------------------------------------------------------------------

func accendi() -> void:
	if accesa.obiettivo >= 1.0:
		return
	accesa.obiettivo = 1.0
	alzata.obiettivo = 1.0
	if Movimento.ridotto():
		accesa.salta_a(1.0)
		alzata.salta_a(0.0)
	Movimento.suona("sfioro")
	sveglia()


func spegni_se_libera() -> void:
	if has_focus() or is_hovered():
		return
	accesa.obiettivo = 0.0
	alzata.obiettivo = 0.0
	if Movimento.ridotto():
		accesa.salta_a(0.0)
	sveglia()


func sveglia() -> void:
	queue_redraw()
	set_process(true)


func _process(delta: float) -> void:
	accesa.passo(delta)
	alzata.passo(delta)
	premuta = TastoObliquo.scorri(premuta, delta, Movimento.durata_gelatina())
	scale = Vector2.ONE + (Movimento.gelatina(premuta) if premuta >= 0.0 else Vector2.ZERO)
	queue_redraw()
	set_process(not accesa.ferma() or not alzata.ferma() or premuta >= 0.0)


# --- il disegno ---------------------------------------------------------------

func poligono(sopra := 0.0) -> PackedVector2Array:
	return Sagome.obliquo(SPOSTA_BASSO, sopra, LARGO, ALTO, PENDENZA)


func centro_a(y: float) -> float:
	# il centro della carta a quell'altezza: la carta pende, e il centro con lei
	return SPOSTA_BASSO + LARGO * 0.5 - PENDENZA * y


func _has_point(punto: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(punto, poligono())


func _draw() -> void:
	if voce.is_empty():
		return
	var su := -SOLLEVA * clampf(alzata.valore, 0.0, 1.5)
	var forma := poligono(su)
	if scelta:
		var sfoglia := forma.duplicate()
		for i in sfoglia.size():
			sfoglia[i] += SFOGLIA
		draw_colored_polygon(sfoglia, Stile.colore("bordo_acceso"))
	draw_colored_polygon(forma, Stile.colore("accento") if scelta else Stile.colore("pannello_chiaro"))
	var bordo := Stile.colore("spento").lerp(Stile.colore("bordo_acceso"), clampf(accesa.valore, 0.0, 1.0))
	draw_polyline(Sagome.chiudi(forma), bordo, 2.0, true)
	var velo := 1.0 if Merce.perche_no(voce) == "" else SPENTA
	disegna_prezzo(su, velo)
	disegna_nome(su, velo)
	disegna_icona(su, velo)
	disegna_stato()


func disegna_prezzo(su: float, velo: float) -> void:
	var f := Caratteri.titolo()
	if f == null:
		return
	var scritta := "BARATTO" if String(voce.get("tipo", "")) == "baratto" else "%d" % int(voce.get("prezzo", 0))
	var corpo := 24 if scritta == "BARATTO" else CORPO_PREZZO
	var misura := f.get_string_size(scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo)
	var x := centro_a(22.0) - misura.x * 0.5
	draw_string(f, Vector2(x, 40.0 + su), scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo,
			Color(Stile.colore("testo"), velo))


func disegna_nome(su: float, velo: float) -> void:
	var f := Caratteri.tondo(800)
	if f == null:
		return
	var largo := 104.0
	draw_multiline_string(f, Vector2(centro_a(60.0) - largo * 0.5, 62.0 + su), text,
			HORIZONTAL_ALIGNMENT_CENTER, largo, CORPO_NOME, 2,
			Color(Stile.colore("testo") if scelta else Stile.colore("testo_smorzato"), velo))


func disegna_icona(su: float, velo: float) -> void:
	var id_oggetto := String(voce.get("oggetto", ""))
	var centro := Vector2(centro_a(134.0), 134.0 + su)
	var disegno := Sagome.immagine_oggetto(id_oggetto)
	if disegno != null:
		var lato := LATO_ICONA * 1.15
		draw_texture_rect(disegno, Rect2(centro - Vector2(lato, lato) * 0.5, Vector2(lato, lato)), false,
				Color(1, 1, 1, velo))
	else:
		var fondo := Stile.colore("accento") if scelta else Stile.colore("pannello_chiaro")
		Sagome.icona_oggetto(self, centro, LATO_ICONA, Sagome.tipo_icona(id_oggetto),
				Color(Stile.colore("testo"), velo), fondo)
	if Merce.gia_tuo(id_oggetto):
		Sagome.timbro(self, centro + Vector2(30, 26), 16.0,
				Stile.colore("bordo_acceso") if scelta else Stile.colore("accento"))


func disegna_stato() -> void:
	# fuori dalla carta, sotto la base: non si alza con lei, e' l'etichetta
	# dello scaffale, non della carta
	var stato := Merce.stato_breve(voce)
	var f := Caratteri.tondo(900)
	if f == null or String(stato["testo"]) == "":
		return
	var colore := Stile.colore("accento") if bool(stato["problema"]) else Stile.colore("testo_smorzato")
	draw_string(f, Vector2(LARGO * 0.5 - 80.0, ALTO + 32.0), String(stato["testo"]),
			HORIZONTAL_ALIGNMENT_CENTER, 160.0, CORPO_STATO, colore)
