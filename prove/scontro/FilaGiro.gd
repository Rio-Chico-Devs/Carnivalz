extends Control
# LA FILA DEL GIRO (ProposteScontro.gd): chi agisce, e chi dopo.
#
# Lo scontro va a giri (Combattimento.gd: «in ogni giro ognuno agisce una
# volta, in ordine di velocita'»), e l'ordine c'e' gia' nel motore (Turni.gd).
# A schermo pero' non c'e': sai di chi e' il turno, non di chi sara'. E' la
# domanda che decide se curare adesso o dopo - la creatura colpisce prima o
# dopo Veronica? - e la fila la dice senza parole: un gettone per ognuno,
# nell'ordine del giro, quello di adesso piu' grande, la creatura in rosso.

const Spina := preload("res://prove/scontro/Spina.gd")

var giro := 1
var ordine: Array = []      # [iniziale, e' la creatura]
var adesso := 0.0           # chi agisce: un indice, ma con la virgola mentre il segno passa al prossimo


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	var y := 42.0
	var x := Spina.diagonale(Spina.ALTO, Spina.GOLA) + 8.0
	var misura := Spina.etichetta(self, Vector2(x, y - 16.0), "GIRO %d" % giro, 20)
	x += misura.x + 34.0
	var passo := 62.0
	for i in ordine.size():
		var vicino := clampf(1.0 - absf(float(i) - adesso), 0.0, 1.0)
		var raggio := lerpf(17.0, 25.0, vicino)
		var centro := Vector2(x + passo * i, y)
		var nemico := bool((ordine[i] as Array)[1])
		var fatto := float(i) < adesso - 0.5
		var tinta := Stile.colore("pericolo") if nemico else Stile.colore("bordo")
		if fatto:
			tinta = tinta.lerp(Stile.colore("manifesto_scuro"), 0.6)
		draw_circle(centro + Manifesto.OMBRA * 0.5, raggio, Stile.colore("bordo"), true, -1.0, true)
		draw_circle(centro, raggio, tinta, true, -1.0, true)
		if vicino > 0.0:
			draw_arc(centro, raggio + 4.0, 0.0, TAU, 48, Color(Stile.colore("box_fondo"), vicino), 3.0, true)
		Spina.scritta(self, Caratteri.titolo(), centro + Vector2(0, raggio * 0.42), String((ordine[i] as Array)[0]),
				int(raggio * 1.15), Stile.colore("testo"), HORIZONTAL_ALIGNMENT_CENTER)
		if i < ordine.size() - 1:
			# la freccia verso il prossimo: e' una fila, si legge da sinistra
			var a := centro + Vector2(raggio + 7.0, 0)
			Manifesto.poligono(self, PackedVector2Array([a + Vector2(0, -6), a + Vector2(8, 0), a + Vector2(0, 6)]),
					Stile.colore("bordo"))
