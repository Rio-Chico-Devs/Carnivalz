class_name RigaBond
extends Node2D
# LA RIGA SOTTO LA PAROLA del BOND (LuceBond.gd), piena in mezzo e a punta ai
# lati, col rombo del gioco. Bianca come le lettere: la dora lo stesso shader.
# Le due comete che ci corrono sopra le disegnano le scintille (ScintilleBond),
# che sono piu' chiare.

var mezza := 0.0          # mezza lunghezza della riga
var rombo := 0.0          # quanto e' arrivato il rombo
var giro_rombo := 0.0
var corsa := -1.0         # le due comete: 0 al centro, 1 alle punte
var luce := 1.0
var alto := 8.0           # mezza altezza del rombo


func _draw() -> void:
	var bianco := Color(1, 1, 1, luce)
	if mezza > 4.0:
		draw_colored_polygon(PackedVector2Array([Vector2(-mezza, 0), Vector2(0, -1.8), Vector2(mezza, 0),
				Vector2(0, 1.8)]), bianco)
	if rombo > 0.05:
		draw_set_transform(Vector2.ZERO, giro_rombo, Vector2.ONE * rombo)
		draw_colored_polygon(PackedVector2Array([Vector2(0, -alto), Vector2(alto * 0.8, 0), Vector2(0, alto),
				Vector2(-alto * 0.8, 0)]), bianco)
		draw_set_transform(Vector2.ZERO)
