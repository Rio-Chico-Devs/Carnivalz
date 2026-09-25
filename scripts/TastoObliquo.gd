class_name TastoObliquo
extends Button

# UN TASTO A FASCIA STORTA: COMPRA, le linguette dei negozi, Indietro.
#
# E' la fascia dei cartigli (vedi Cartiglio.gd) fatta premibile: una striscia
# di colore pieno coi lati obliqui e, sotto, una sfoglia di un altro colore che
# sporge di qualche pixel - carta ritagliata e incollata. Le voci della pausa
# sono fatte cosi', i titoli pure: un tasto nuovo non inventa un'altra forma.
#
# I GESTI SONO QUELLI DI TUTTE LE VOCI (VoceMenu, Movimento): passandoci sopra
# si accende su una molla - la fascia prende il colore dell'altra, la sfoglia
# pure; premendolo si schiaccia (la gelatina); se adesso non si puo', dice di
# no: una scossa breve e il suono del rifiuto. Un tasto spento che non risponde
# si legge come rotto, uno che dice di no si legge come "non ancora".
#
# Il testo resta nel Button (text), ma trasparente: lo disegna _draw col
# carattere dei titoli. Cosi' chi cerca un tasto per nome - l'automa, le prove -
# lo trova col nome che si legge.

signal scelto

const TAGLIO := 0.35
const SFOGLIA := Vector2(6, 5)
const MARGINE := Vector2(18, 6)
const LAMPO := 0.07
const COLORI_TESTO := ["font_color", "font_hover_color", "font_pressed_color",
		"font_focus_color", "font_disabled_color", "font_hover_pressed_color"]

var stile := "chiaro"          # chiaro | accento | spoglio
var inerte := false            # si vede spento, e premuto dice di no
var corpo := 24
var font_scritta: Font
var accesa: Movimento.Molla
var premuta := -1.0
var rifiutata := -1.0
var lampo := 0.0


static func nuovo(scritta: String, quale_stile := "chiaro", dimensione := 24) -> TastoObliquo:
	var t := TastoObliquo.new()
	t.text = scritta
	t.stile = quale_stile
	t.corpo = dimensione
	return t


func _init() -> void:
	accesa = Movimento.molla("colore")
	flat = true
	focus_mode = Control.FOCUS_ALL
	for stato in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		add_theme_stylebox_override(stato, StyleBoxEmpty.new())
	for chiave in COLORI_TESTO:
		add_theme_color_override(chiave, Color(0, 0, 0, 0))
	set_process(false)


func _ready() -> void:
	font_scritta = Caratteri.titolo()
	adatta_misura()
	pivot_offset = size * 0.5
	mouse_entered.connect(accendi)
	mouse_exited.connect(spegni_se_libero)
	focus_entered.connect(accendi)
	focus_exited.connect(spegni_se_libero)
	button_down.connect(giu)
	pressed.connect(premi)
	resized.connect(func() -> void: pivot_offset = size * 0.5)


func adatta_misura() -> void:
	# LA MISURA LA DICE LA FASCIA, non il Button. Un Button calcola la sua in
	# C++ col carattere del tema (quello del testo trasparente) e non chiede mai
	# _get_minimum_size allo script: la fascia usciva alta 23 pixel sotto una
	# scritta di 31. Si scrive nella misura minima, che il Button rispetta
	custom_minimum_size = misura_voluta()
	size = size.max(custom_minimum_size)


func misura_voluta() -> Vector2:
	var f := font_scritta if font_scritta != null else Caratteri.titolo()
	if f == null:
		return Vector2(80, 40)
	var misura := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo)
	var alto := misura.y + MARGINE.y * 2.0
	return Vector2(misura.x + MARGINE.x * 2.0 + TAGLIO * alto + SFOGLIA.x, alto + SFOGLIA.y)


# --- i gesti ------------------------------------------------------------------

func accendi() -> void:
	if accesa.obiettivo >= 1.0:
		return
	accesa.obiettivo = 1.0
	if Movimento.ridotto():
		accesa.salta_a(1.0)
	if not inerte:
		Movimento.suona("sfioro")
	sveglia()


func spegni_se_libero() -> void:
	# resta accesa finche' ha il fuoco O il mouse sopra: perdere una delle due
	# non basta a spegnerla
	if has_focus() or is_hovered():
		return
	accesa.obiettivo = 0.0
	if Movimento.ridotto():
		accesa.salta_a(0.0)
	sveglia()


func giu() -> void:
	if not inerte and not Movimento.ridotto():
		premuta = 0.0
		sveglia()


func premi() -> void:
	if inerte:
		rifiuta()
		return
	Movimento.suona("pressione")
	lampo = LAMPO
	sveglia()
	scelto.emit()


func rifiuta() -> void:
	Movimento.suona("rifiuto")
	lampo = LAMPO
	if not Movimento.ridotto():
		rifiutata = 0.0
	sveglia()


func sveglia() -> void:
	queue_redraw()
	set_process(true)


func _process(delta: float) -> void:
	avanza(delta)


func avanza(dt: float) -> void:
	accesa.passo(dt)
	premuta = scorri(premuta, dt, Movimento.durata_gelatina())
	rifiutata = scorri(rifiutata, dt, Movimento.durata_scossa())
	lampo = maxf(lampo - dt, 0.0)
	scale = Vector2.ONE + (Movimento.gelatina(premuta) if premuta >= 0.0 else Vector2.ZERO)
	queue_redraw()
	set_process(not accesa.ferma() or premuta >= 0.0 or rifiutata >= 0.0 or lampo > 0.0)


static func scorri(orologio: float, dt: float, fine: float) -> float:
	if orologio < 0.0:
		return orologio
	var dopo := orologio + dt
	return dopo if dopo < fine else -1.0


# --- il disegno ---------------------------------------------------------------

func colori() -> Array[Color]:
	# [fondo, scritta, sfoglia], spento e acceso; la molla passa dall'uno all'altro
	var bianco := Stile.colore("bordo_acceso")
	var rosso := Stile.colore("accento")
	var nero := Stile.colore("box_testo")
	if inerte:
		return [Stile.colore("pannello_chiaro"), Stile.colore("spento"), Color(0, 0, 0, 0)]
	var spento: Array[Color] = []
	var acceso: Array[Color] = []
	match stile:
		"accento":
			spento = [rosso, bianco, bianco]
			acceso = [bianco, nero, rosso]
		"spoglio":
			spento = [Color(0, 0, 0, 0), Stile.colore("testo_smorzato"), Color(0, 0, 0, 0)]
			acceso = [Stile.colore("pannello_chiaro"), bianco, rosso]
		_:
			spento = [bianco, nero, rosso]
			acceso = [rosso, bianco, bianco]
	var q := clampf(accesa.valore, 0.0, 1.0)
	return [spento[0].lerp(acceso[0], q), spento[1].lerp(acceso[1], q), spento[2].lerp(acceso[2], q)]


func _draw() -> void:
	var c := colori()
	var h := size.y - SFOGLIA.y
	var largo := size.x - SFOGLIA.x
	var scossa := Vector2(Movimento.scossa(rifiutata) if rifiutata >= 0.0 else 0.0, 0.0)
	if c[2].a > 0.0:
		draw_colored_polygon(Cartiglio.fascia(SFOGLIA + scossa, largo, h), c[2])
	var fondo := c[0].lerp(Stile.colore("bordo_acceso"), 1.0 if lampo > 0.0 else 0.0)
	if fondo.a > 0.0:
		draw_colored_polygon(Cartiglio.fascia(scossa, largo, h), fondo)
	var f := font_scritta
	if f == null:
		return
	var misura := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo)
	var sotto := f.get_ascent(corpo) - (f.get_ascent(corpo) + f.get_descent(corpo)) * 0.5
	var dove := Vector2((largo - misura.x) * 0.5, h * 0.5 + sotto) + scossa
	var scritta := c[1] if lampo <= 0.0 else Stile.colore("accento")
	draw_string(f, dove, text, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, scritta)


func _has_point(punto: Vector2) -> bool:
	# si prende il clic solo sulla fascia, non sui due triangoli vuoti ai lati
	var h := size.y - SFOGLIA.y
	return Geometry2D.is_point_in_polygon(punto, Cartiglio.fascia(Vector2.ZERO, size.x - SFOGLIA.x, h + SFOGLIA.y))
