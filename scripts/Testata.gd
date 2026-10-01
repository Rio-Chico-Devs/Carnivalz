class_name Testata
extends Control

# LA TESTATA DI UN PASSO DEL MENU PRINCIPALE: «MENU PRINCIPALE», «NUOVA
# PARTITA»... E' la STRISCIA del manifesto: una fascia nera sottile e inclinata
# con la scritta arancio, larga e spaziata. Dice «sei qui» senza pesare quanto
# le voci. (Prima era una scia di luce azzurra, dal riferimento di Borderlands 2.)
#
# Cambiando passo la fascia si srotola da sinistra: e' il primo gesto della
# coreografia, prima che arrivino le voci.

const LARGA := 330.0

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
	var carattere := Caratteri.striscia()
	if carattere == null or testo == "":
		return
	var corpo := Stile.dimensione("minuscolo")
	var largo := carattere.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + 28.0
	var alto := float(corpo) * 1.35
	var sopra := (size.y - alto) * 0.5
	Manifesto.poligono(self, VoceMenu.lastra(-14.0, -14.0 + largo * quanto, sopra, alto), Stile.colore("bordo"))
	var base := Vector2(0.0, sopra + (alto + carattere.get_ascent(corpo) - carattere.get_descent(corpo)) * 0.5)
	draw_string(carattere, base, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo,
			Color(Stile.colore("manifesto"), clampf(quanto * 2.0 - 0.6, 0.0, 1.0)))


static func bordo(corpo: int) -> int:
	# il contorno disegnato a mano segue la regola di Stile.contorno: un sesto
	# del corpo, mai meno di due pixel
	return maxi(2, int(round(float(corpo) * Stile.QUOTA_CONTORNO)))
