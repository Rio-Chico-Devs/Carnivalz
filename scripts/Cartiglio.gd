class_name Cartiglio
extends Control

# UNA SCRITTA SU UNA FASCIA INCLINATA: il titolo di un menu, il cartellino dei
# Tazo. E' la stessa grammatica del nastro rosa dei nomi e delle fasce rosse
# dei nemici, cioe' le cose che nel disegno di Bru dicono "questo e' un nome":
# una striscia di colore pieno, storta di -3,5 gradi, con la scritta dentro.
#
# Sotto la fascia c'e' una sfoglia di un altro colore che sporge di qualche
# pixel, come la lastra delle voci di menu: carta ritagliata e incollata a
# strati. Tutte le fasce del menu sono fatte cosi', e questa e' l'unica regola
# da ricordare per disegnarne una nuova.
#
# ENTRA SROTOLANDOSI: la fascia corre da sinistra a destra, la sfoglia la
# segue un momento dopo, e la scritta compare mentre la fascia le passa sotto.
# Con il movimento ridotto la fascia c'e' gia' tutta, e si dissolve.

const MARGINE_X := 24.0
const MARGINE_Y := 8.0
const TAGLIO := 0.35
const SFOGLIA := Vector2(7, 6)
const RITARDO_SFOGLIA := 0.04   # la sfoglia arriva dopo: e' questo a farla sembrare un altro foglio

var testo := ""
var fondo := Color.WHITE
var inchiostro := Color.BLACK
var carta := Color.WHITE        # il colore della sfoglia sotto
var corpo := 45
var font: Font
var ritardo := 0.0
var orologio := -1.0
var svolta := 1.0               # la fascia, 0..1
var svolta_sfoglia := 1.0


static func nuovo(scritta: String, colore_fondo: Color, colore_scritta: Color,
		colore_carta: Color, dimensione: int) -> Cartiglio:
	var c := Cartiglio.new()
	c.testo = scritta
	c.fondo = colore_fondo
	c.inchiostro = colore_scritta
	c.carta = colore_carta
	c.corpo = dimensione
	c.font = Stile.font_da("titolo")
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.set_process(false)
	return c


func carattere() -> Font:
	return font if font != null else get_theme_default_font()


func _get_minimum_size() -> Vector2:
	var f := carattere()
	if f == null:
		return Vector2.ZERO
	var misura_testo := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo)
	var alto := misura_testo.y + MARGINE_Y * 2.0
	return Vector2(misura_testo.x + MARGINE_X * 2.0 + TAGLIO * alto + SFOGLIA.x, alto + SFOGLIA.y)


func svela(quando: float) -> void:
	ritardo = quando
	orologio = 0.0
	svolta = 0.0
	svolta_sfoglia = 0.0
	queue_redraw()
	set_process(true)


func _process(delta: float) -> void:
	avanza(delta)


func avanza(dt: float) -> void:
	if orologio < 0.0:
		set_process(false)
		return
	orologio += dt
	if Movimento.ridotto():
		svolta = clampf((orologio - ritardo) / Movimento.durata("colore"), 0.0, 1.0)
		svolta_sfoglia = svolta
	else:
		var durata := Movimento.durata("voce")
		svolta = Movimento.curva("entrata", (orologio - ritardo) / durata)
		svolta_sfoglia = Movimento.curva("entrata", (orologio - ritardo - RITARDO_SFOGLIA) / durata)
	if svolta_sfoglia >= 1.0 and svolta >= 1.0:
		orologio = -1.0
		set_process(false)
	queue_redraw()


func _draw() -> void:
	var f := carattere()
	if f == null:
		return
	var h := size.y - SFOGLIA.y
	var largo := size.x - SFOGLIA.x
	draw_set_transform(Vector2(largo, h) * 0.5, Stile.angolo("inclinazione_nastro"))
	var origine := Vector2(largo, h) * -0.5
	var ridotto := Movimento.ridotto()
	# con il movimento ridotto la fascia non corre: c'e' tutta, e sfuma
	var quanto_sfoglia := 1.0 if ridotto else svolta_sfoglia
	var quanto_fascia := 1.0 if ridotto else svolta
	var alfa := svolta if ridotto else 1.0
	if quanto_sfoglia > 0.0:
		draw_colored_polygon(fascia(origine + SFOGLIA, largo * quanto_sfoglia, h),
				Color(carta, carta.a * alfa))
	if quanto_fascia > 0.0:
		draw_colored_polygon(fascia(origine, largo * quanto_fascia, h), Color(fondo, fondo.a * alfa))
	# la scritta compare mentre la fascia le passa sotto: prima di meta' strada
	# sarebbe inchiostro sul vuoto
	var scritta := clampf((svolta - 0.35) / 0.5, 0.0, 1.0)
	if scritta > 0.0:
		var sotto := f.get_ascent(corpo) - (f.get_ascent(corpo) + f.get_descent(corpo)) * 0.5
		draw_string(f, origine + Vector2(MARGINE_X + TAGLIO * h * 0.5, h * 0.5 + sotto), testo,
				HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Color(inchiostro, inchiostro.a * scritta))
	draw_set_transform(Vector2.ZERO)


static func fascia(origine: Vector2, largo: float, h: float) -> PackedVector2Array:
	var obliquo := TAGLIO * h
	var fine := maxf(largo - obliquo, 0.0)
	return PackedVector2Array([
		origine + Vector2(obliquo, 0.0), origine + Vector2(fine + obliquo, 0.0),
		origine + Vector2(fine, h), origine + Vector2(0.0, h)])
