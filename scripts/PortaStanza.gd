class_name PortaStanza
extends Button

# LA PORTA DI UNA STANZA SULLA MAPPA DI ZONA: un bottone come gli altri (mouse,
# tastiera, prove e automa lo premono allo stesso modo), che pero' si prende il
# clic solo dentro la sua sagoma.
#
# Sul plastico (PlasticoZona) una stanza vista di sbieco e' un esagono, non un
# rettangolo: col rettangolo di contorno gli angoli vuoti si prendevano il clic
# destinato alla stanza che sta dietro, o al piano di sotto. Sulla mappa a
# quadratini la sagoma resta vuota, e vale il rettangolo di sempre.

var sagoma := PackedVector2Array()   # nelle coordinate del bottone


func _has_point(punto: Vector2) -> bool:
	if sagoma.size() < 3:
		return Rect2(Vector2.ZERO, size).has_point(punto)
	return Geometry2D.is_point_in_polygon(punto, sagoma)
