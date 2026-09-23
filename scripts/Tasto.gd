class_name Tasto
extends HBoxContainer

# UN COMANDO IN BASSO A DESTRA: il tasto disegnato come un tasto, e cosa fa.
# Nel riferimento di Bru sono «(A) Select  (B) Back»; qui la tastiera, «INVIO
# Seleziona  ESC Indietro». E si possono cliccare: chi usa il mouse non deve
# sapere che ESC torna indietro per poterci tornare.
#
# Il tasto non prende il fuoco: cliccarlo non deve spegnere la voce accesa.

static func nuovo(tasto: String, azione: String, richiamo: Callable) -> Tasto:
	var riga := Tasto.new()
	riga.add_theme_constant_override("separation", 8)
	var bottone := Button.new()
	bottone.text = tasto
	bottone.focus_mode = Control.FOCUS_NONE
	if Caratteri.tondo(850) != null:
		bottone.add_theme_font_override("font", Caratteri.tondo(850))
	bottone.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	for colore in ["font_color", "font_hover_color", "font_pressed_color"]:
		bottone.add_theme_color_override(colore, Stile.colore("menu_descrizione"))
	for stato in ["normal", "hover", "pressed"]:
		var tappo := StyleBoxFlat.new()
		tappo.bg_color = Color(Stile.colore("menu_riga"), 0.8)
		tappo.set_border_width_all(2)
		tappo.border_color = Stile.colore("menu_chiaro" if stato == "normal" else "testo")
		tappo.set_corner_radius_all(12)
		tappo.content_margin_left = 10
		tappo.content_margin_right = 10
		tappo.content_margin_top = 1
		tappo.content_margin_bottom = 1
		bottone.add_theme_stylebox_override(stato, tappo)
	bottone.pressed.connect(richiamo)
	riga.add_child(bottone)
	var scritta := Label.new()
	scritta.text = azione
	if Caratteri.tondo(700) != null:
		scritta.add_theme_font_override("font", Caratteri.tondo(700))
	scritta.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	scritta.add_theme_color_override("font_color", Stile.colore("menu_descrizione"))
	Stile.contorno(scritta, Stile.dimensione("minuscolo"))
	scritta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	riga.add_child(scritta)
	return riga
