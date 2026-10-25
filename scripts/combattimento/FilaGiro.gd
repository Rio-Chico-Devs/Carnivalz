class_name FilaDelGiro
extends Control
# CHI TOCCA DOPO (Plancia.gd).
#
# Lo scontro va a giri, in ordine di velocita' (Turni.gd): l'ordine il motore
# ce l'aveva, lo schermo no. Ed e' la domanda che decide se curare adesso o
# dopo. In alto a destra: «GIRO 1», poi un gettone per ognuno nell'ordine del
# giro - quello di adesso piu' grande e cerchiato, la creatura in rosso, chi ha
# gia' agito piu' spento, una freccia fra uno e l'altro.

var giro := 0
var gettoni: Array[Dictionary] = []   # {iniziale, nemico, adesso, fatto}
var scala := 1.0                      # quanto e' grande il foglio, in alto


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func mostra(numero: int, chi: Array[Dictionary]) -> void:
	giro = numero
	gettoni = chi
	queue_redraw()


func _draw() -> void:
	if giro <= 0 or gettoni.is_empty():
		return
	var corpo := int(round(18.0 * scala))
	var scritta := "GIRO %d" % giro
	var largo := Caratteri.titolo().get_string_size(scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo \
			+ Manifesto.INCLINA * corpo * 1.3
	Manifesto.etichetta_tinta(self, Vector2(0.0, 4.0 * scala), scritta, corpo,
			Stile.colore("bordo"), Stile.colore("manifesto"))
	var x := largo + 22.0 * scala
	var centro_y := 18.0 * scala
	var font := Caratteri.titolo()
	for i in gettoni.size():
		var g: Dictionary = gettoni[i]
		var adesso := bool(g.get("adesso", false))
		var raggio := (24.0 if adesso else 17.0) * scala
		var c := Vector2(x + raggio, centro_y)
		var pieno := Stile.colore("pericolo") if bool(g.get("nemico", false)) else Stile.colore("bordo")
		if bool(g.get("fatto", false)):
			# chi ha gia' agito: spento, ma ancora al suo posto nella fila
			pieno = pieno.lerp(Stile.colore("manifesto_scuro"), 0.55)
		draw_circle(c + Manifesto.OMBRA * 0.5 * scala, raggio, Stile.colore("bordo"), true, -1.0, true)
		draw_circle(c, raggio, pieno, true, -1.0, true)
		if adesso:
			draw_arc(c, raggio + 3.0 * scala, 0.0, TAU, 48, Stile.colore("box_fondo"), 3.0 * scala, true)
		var lettera := String(g.get("iniziale", "?"))
		var corpo_lettera := int(round((24.0 if adesso else 17.0) * scala))
		var misura := font.get_string_size(lettera, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo_lettera)
		draw_string(font, c + Vector2(-misura.x * 0.5, corpo_lettera * 0.36), lettera, HORIZONTAL_ALIGNMENT_LEFT,
				-1, corpo_lettera, Stile.colore("testo"))
		x += raggio * 2.0
		if i < gettoni.size() - 1:
			# la freccia verso chi viene dopo
			var punta := Vector2(x + 12.0 * scala, centro_y)
			Manifesto.poligono(self, PackedVector2Array([punta + Vector2(-8, -6) * scala, punta,
					punta + Vector2(-8, 6) * scala]), Stile.colore("bordo"))
			x += 20.0 * scala
