class_name CartelloneNemico
extends Control
# LO SCHERMO DELLA CREATURA (Plancia.gd).
#
# La creatura e' l'attrazione della serata: lo schermo piu' grande della
# schermata, in alto a sinistra, col lato destro sulla diagonale (Spina.gd).
# E' ancora il cabinato del manifesto - l'ombra piena, il contorno nero, la
# cornice chiara, il vetro scuro - perche' quella lingua Bru l'ha approvata; e'
# cambiata la misura, e la forma che taglia lo schermo in due.
#
# Dentro ci sono tre strati, in quest'ordine:
#   Dentro  la creatura (il campo ci appende il ritratto), e i gregari
#   Palco   dove giocano i minigiochi: quando la creatura attacca il suo
#           schermo lo usa la raffica, e i pugni ti arrivano addosso da dove
#           arriva lei. Mentre si gioca la creatura si ritira dietro
#   Velo    il rosso del suo turno (FasciaTurno.accendi_nemico), sopra tutto,
#           nella forma del vetro e non in un rettangolo che ne uscirebbe

var forma := PackedVector2Array():   # il contorno, nelle coordinate del nodo: lo mette la plancia
	set(nuova):
		forma = nuova
		velo.forma = Manifesto.scosta(nuova, -cornice) if nuova.size() >= 3 else nuova
		queue_redraw()
var cornice := 13.0                  # lo spessore della cornice chiara, in pixel
var dentro: MarginContainer
var palco: Control
var velo: Velo


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	dentro = MarginContainer.new()
	dentro.name = "Dentro"
	dentro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dentro)
	palco = Control.new()
	palco.name = "Palco"
	palco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(palco)
	velo = Velo.new()
	velo.name = "Velo"
	add_child(velo)
	# il lampo del turno lo cerca qui (FasciaTurno.accendi_nemico): e' il velo,
	# non un ColorRect che coprirebbe anche l'arancio fuori dal vetro
	set_meta(FasciaTurno.META_LAMPO, velo)


func vetro() -> PackedVector2Array:
	return Manifesto.scosta(forma, -cornice) if forma.size() >= 3 else forma


func _draw() -> void:
	if forma.size() < 3:
		return
	SpinaPlancia.carta(self, forma, Stile.colore("cornice_turno"), 4.0)
	var scuro := vetro()
	Manifesto.poligono(self, Manifesto.scosta(scuro, 3.0), Stile.colore("bordo"))
	Manifesto.poligono(self, scuro, Stile.colore("quadro_vuoto"))


class Velo extends Control:
	# IL ROSSO DEL TURNO DELLA CREATURA, nella forma del vetro. "color" come un
	# ColorRect, perche' chi lo accende ne anima l'alfa
	var forma := PackedVector2Array():
		set(nuova):
			forma = nuova
			queue_redraw()
	var color := Color(0, 0, 0, 0):
		set(nuovo):
			color = nuovo
			queue_redraw()

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _draw() -> void:
		if color.a > 0.0 and forma.size() >= 3:
			Manifesto.poligono(self, forma, color)
