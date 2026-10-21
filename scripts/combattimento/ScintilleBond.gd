class_name ScintilleBond
extends Node2D
# LE PUNTE DI LUCE del BOND (LuceBond.gd), quasi bianche e col bagliore largo:
# le due che salgono lungo ogni giro del contorno (si spengono quando si
# incontrano), il seme dove la luce tocca la lettera per la prima volta, e le
# due comete che corrono lungo la riga, dal rombo alle punte.

var lettere: Array[LetteraBond] = []
var riga: RigaBond


func _draw() -> void:
	for lettera in lettere:
		if lettera.traccia > 0.0 and lettera.traccia_luce > 0.0:
			punte_di(lettera)
	comete()
	draw_set_transform_matrix(Transform2D.IDENTITY)


func punte_di(lettera: LetteraBond) -> void:
	draw_set_transform_matrix(lettera.transform)
	var punta := Color(1, 1, 1, lettera.traccia_luce * (1.0 - pow(lettera.traccia, 4.0)))
	for c in lettera.contorni.size():
		for dove in lettera.punte(c):
			draw_circle(dove, 3.0, punta, true, -1.0, true)
	if not lettera.contorni.is_empty() and lettera.traccia < 0.35:
		var seme := lettera.traccia / 0.35
		draw_circle(lettera.contorni[0][0], lerpf(7.0, 3.0, seme),
				Color(1, 1, 1, lettera.traccia_luce * (1.0 - seme)), true, -1.0, true)


func comete() -> void:
	if riga == null or riga.corsa < 0.0 or riga.corsa > 1.0:
		return
	draw_set_transform_matrix(riga.transform)
	var corre := Color(1, 1, 1, riga.luce * sin(riga.corsa * PI))
	for verso: float in [-1.0, 1.0]:
		var testa := Vector2(verso * riga.mezza * riga.corsa, 0.0)
		Manifesto.poligono(self, PackedVector2Array([testa - Vector2(verso * 30.0, 0.0), testa + Vector2(0.0, -2.2),
				testa + Vector2(0.0, 2.2)]), corre)
		draw_circle(testa, 2.6, corre, true, -1.0, true)
