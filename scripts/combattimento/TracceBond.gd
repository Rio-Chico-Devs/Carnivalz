class_name TracceBond
extends Node2D
# LA LUCE CHE SALE LUNGO I CONTORNI delle lettere del BOND (LuceBond.gd): per
# ogni giro del contorno due pezzi, uno per verso, che partono dal punto piu'
# basso e si incontrano dall'altra parte. Bianca: la dora il suo CanvasGroup,
# un po' piu' chiara delle lettere.

var lettere: Array[LetteraBond] = []


func _draw() -> void:
	for lettera in lettere:
		if lettera.traccia <= 0.0 or lettera.traccia_luce <= 0.0:
			continue
		draw_set_transform_matrix(lettera.transform)
		var bianco := Color(1, 1, 1, lettera.traccia_luce)
		for c in lettera.contorni.size():
			for pezzo in lettera.tratti(c):
				draw_polyline(pezzo, bianco, 2.4, true)
	draw_set_transform_matrix(Transform2D.IDENTITY)
