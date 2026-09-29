class_name NastroStrappato
extends Control

# IL NASTRO DI CARTA COL NOME, STRAPPATO A MANO.
#
# Bru ha scelto questo fra le prove dei nomi (scatti nome_fell_strappato):
# «complimenti anche per il nastro». Prima era un rettangolo rosa liscio, e un
# rettangolo liscio si legge digitale anche sotto un bel carattere: un pezzo
# di nastro adesivo di carta vero ha le due estremita' strappate, a morsi
# piccoli e irregolari. Lo stesso rosa, la stessa inclinazione.
#
# Qui c'e' solo il fondo: la scritta e' la Label del nome che gli sta davanti
# (vesti_la_scritta le da' carattere, inchiostro e margini). Quando c'e' il
# nastro disegnato da Bru per quel personaggio, questo si spegne: il disegno e'
# gia' tutto.
#
# C'era anche un fregio ❧ cremisi davanti al nome, dalla prova approvata. Bru,
# 29 settembre: «la foglia cremisi non mi piace». Tolto, col carattere che
# serviva solo a lui.
#
# Ogni nome si strappa a modo suo (il seme e' il nome): due nastri uguali uno
# dopo l'altro sembrerebbero stampati, non strappati.

const MORSO := 9.0      # quanto al massimo lo strappo entra nella carta
const PASSO := 2.5      # ogni quanti pixel lo strappo cambia
const LATO := 30.0      # l'aria fra lo strappo e il nome, uguale ai due lati

var colore := Color.PINK
var seme := 7


static func dentro(nastro: Control, etichetta: Label) -> NastroStrappato:
	# mette il nastro dietro la scritta del nome e la veste
	var carta := NastroStrappato.new()
	nastro.add_child(carta)
	nastro.move_child(carta, 0)
	carta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	carta.vesti_la_scritta(etichetta)
	return carta


static func misura(nome: String, di_serie: Variant) -> Variant:
	return (Stile.dati.get("nomi", {}) as Dictionary).get(nome, di_serie)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	colore = Stile.colore("nastro")
	resized.connect(queue_redraw)


func vesti_la_scritta(scritta: Label) -> void:
	# il nome in maiuscoletto Fell, con l'inchiostro che si allarga appena nella
	# carta (un alone dello stesso colore, trasparente)
	var margini := StyleBoxEmpty.new()
	margini.content_margin_left = LATO
	margini.content_margin_right = LATO
	margini.content_margin_top = 4
	margini.content_margin_bottom = 6
	scritta.add_theme_stylebox_override("normal", margini)
	if Caratteri.nomi() != null:
		scritta.add_theme_font_override("font", Caratteri.nomi())
	scritta.add_theme_font_size_override("font_size", Caratteri.corpo_nomi())
	var inchiostro := Color(String(misura("inchiostro", Stile.colore("nastro_testo").to_html())))
	scritta.add_theme_color_override("font_color", inchiostro)
	scritta.add_theme_color_override("font_shadow_color", Color(inchiostro, float(misura("steso", 0.28))))
	scritta.add_theme_constant_override("shadow_offset_x", 0)
	scritta.add_theme_constant_override("shadow_offset_y", 0)
	scritta.add_theme_constant_override("shadow_outline_size", 2)


func strappa(nome: String) -> void:
	seme = hash(nome)
	queue_redraw()


func contorno() -> PackedVector2Array:
	# lo strappo: un passeggio casuale che resta fra 0 e MORSO pixel dentro la
	# carta, un punto ogni PASSO. Destra dall'alto in basso, sinistra risalendo
	var caso := RandomNumberGenerator.new()
	caso.seed = seme
	var destra := PackedVector2Array()
	var sinistra := PackedVector2Array()
	var d := MORSO * 0.45
	var s := MORSO * 0.45
	var y := 0.0
	while y <= size.y + 0.1:
		d = clampf(d + caso.randf_range(-2.6, 2.6), 0.0, MORSO)
		s = clampf(s + caso.randf_range(-2.6, 2.6), 0.0, MORSO)
		destra.append(Vector2(size.x - d, minf(y, size.y)))
		sinistra.append(Vector2(s, minf(y, size.y)))
		y += PASSO
	sinistra.reverse()
	return destra + sinistra


func _draw() -> void:
	if size.x > 2.0 * MORSO and size.y > 2.0:
		draw_colored_polygon(contorno(), colore)
