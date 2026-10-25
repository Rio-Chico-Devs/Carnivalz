class_name FasciaNemico
extends Control
# IL NOME DELLA CREATURA, LA SUA VITA, QUELLO CHE SAI (Plancia.gd).
#
# Il nome su una fascia ROSSA di traverso che entra nel cartellone, come il
# titolo di un manifesto. E' rossa perche' qui il rosso vuol dire una cosa sola
# - il pericolo - e il pericolo e' lei. Sotto, la sua vita: non piu' «HP: ???»
# scritto e basta, ma una barra vera col pieno coperto da un tratteggio finche'
# non la studi; studiandola il tratteggio se ne va e compare il numero. Sotto
# ancora, quello che hai scoperto, sulle strisce nere.
#
# Il nome (fascia_nome), il numero della vita (in posto_vita) e le strisce
# (righe_studio) sono etichette vere: le scrive il campo, e le leggono le prove
# e chi guarda. Qui si disegnano solo la fascia e la barra.

var banda := PackedVector2Array():   # la fascia rossa, nelle coordinate del nodo
	set(nuova):
		banda = nuova
		queue_redraw()
var barra := Rect2():                # la barra della vita
	set(nuova):
		barra = nuova
		queue_redraw()
var quota := 1.0:                    # quanta vita le resta, 0..1
	set(nuova):
		quota = nuova
		queue_redraw()
var nota := false:                   # la vita si conosce (studiata), o e' coperta
	set(nuova):
		var scoperta := nuova and not nota
		nota = nuova
		if scoperta and is_inside_tree() and not Movimento.ridotto():
			# LO STUDIO TOGLIE IL TRATTEGGIO, da sinistra a destra: e' il momento
			# in cui la scopri, e si vede succedere
			svela = 0.0
			create_tween().tween_property(self, "svela", 1.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		elif scoperta or not nuova:
			svela = 1.0   # ridetta uguale (a ogni colpo) non interrompe lo studio che la sta scoprendo
		queue_redraw()
var svela := 1.0:                    # quanto del tratteggio se n'e' gia' andato, scoprendola
	set(nuova):
		svela = nuova
		queue_redraw()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	if banda.size() >= 3:
		SpinaPlancia.carta(self, banda, Stile.colore("pericolo"), 5.0)
	if barra.size.x > 0.0:
		# SULL'ARANCIO, non su un foglio: il vuoto e' scuro e il pieno rosso
		SpinaPlancia.barra(self, barra, quota, Stile.colore("pericolo"), -1.0, not nota, 0.0, "barra_vuota")
		if nota and svela < 1.0:
			# il tratteggio che resta, a destra di quello che lo studio ha gia' tolto
			var dentro := barra.grow(-1.5)
			var resto := Rect2(dentro.position + Vector2(dentro.size.x * svela, 0.0),
					Vector2(dentro.size.x * (1.0 - svela), dentro.size.y))
			draw_rect(resto, Stile.colore("barra_vuota"))
			SpinaPlancia.tratteggio(self, resto, Stile.colore("tratto"))
