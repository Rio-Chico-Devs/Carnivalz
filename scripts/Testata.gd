class_name Testata
extends Control

# LA TESTATA DI UN PASSO DEL MENU PRINCIPALE: «MENU PRINCIPALE», «NUOVA
# PARTITA»... Nel riferimento di Bru e' piccola, tonda, chiara, e sta su una
# SCIA DI LUCE - una striscia azzurra che sfuma ai due capi, piu' luminosa un
# po' a sinistra del centro. Dice «sei qui» senza pesare quanto le voci.
#
# Cambiando passo la scia si riaccende da sinistra: e' il primo gesto della
# coreografia, prima che arrivino le voci.

const LARGA := 330.0
const ALTA := 16.0
const PARTE_PRIMA := -30.0        # la scia comincia un po' prima della scritta
const PICCO := 0.38               # dove la scia e' piu' luminosa, in frazione
const LUCE := 0.42

var testo := ""
var quanto := 1.0
var giro: Tween


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(LARGA, 28)


func imposta(scritta: String, ritardo := 0.0) -> void:
	testo = scritta
	if giro != null:
		giro.kill()
	if Movimento.ridotto():
		quanto = 1.0
		queue_redraw()
		return
	quanto = 0.0
	giro = create_tween()
	giro.tween_interval(ritardo)
	# tween_method non prende una curva (set_custom_interpolator e' solo dei
	# tween di proprieta'): la curva si applica qui dentro
	giro.tween_method(func(u: float) -> void: accendi(Movimento.curva("entrata", u)), 0.0, 1.0,
			Movimento.durata("entrata"))


func accendi(valore: float) -> void:
	quanto = valore
	queue_redraw()


func _draw() -> void:
	var mezzo := size.y * 0.5 + 2.0
	var fine := PARTE_PRIMA + LARGA * quanto
	var picco := PARTE_PRIMA + LARGA * PICCO * quanto
	var scia := Stile.colore("menu_scia")
	var nulla := Color(scia, 0.0)
	var piena := Color(scia, LUCE)
	for meta: Array in [[PARTE_PRIMA, picco, nulla, piena], [picco, fine, piena, nulla]]:
		var da := float(meta[0])
		var a := float(meta[1])
		draw_polygon(PackedVector2Array([Vector2(da, mezzo - ALTA * 0.5), Vector2(a, mezzo - ALTA * 0.5),
				Vector2(a, mezzo + ALTA * 0.5), Vector2(da, mezzo + ALTA * 0.5)]),
				PackedColorArray([meta[2], meta[3], meta[3], meta[2]]))
	# il filo piu' chiaro dentro la scia: e' lui a farla sembrare luce e non nebbia
	draw_line(Vector2(PARTE_PRIMA + 20.0, mezzo), Vector2(fine - 30.0, mezzo),
			Color(Stile.colore("menu_chiaro"), 0.28 * quanto), 2.0)
	var carattere := Caratteri.tondo(800)
	if carattere == null or testo == "":
		return
	var corpo := Stile.dimensione("minuscolo")
	var base := Vector2(0.0, mezzo + carattere.get_ascent(corpo) * 0.36)
	draw_string_outline(carattere, base, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, bordo(corpo),
			Color(Stile.colore("menu_macchia"), 0.8 * minf(quanto * 2.0, 1.0)))
	draw_string(carattere, base, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo,
			Color(Stile.colore("menu_chiaro"), minf(quanto * 2.0, 1.0)))


static func bordo(corpo: int) -> int:
	# il contorno disegnato a mano segue la regola di Stile.contorno: un sesto
	# del corpo, mai meno di due pixel
	return maxi(2, int(round(float(corpo) * Stile.QUOTA_CONTORNO)))
