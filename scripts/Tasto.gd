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
	bottone.add_theme_font_override("font", Caratteri.titolo())
	bottone.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	# LA PILLOLA DEL MANIFESTO: arancio con la scritta nera, sulla banda nera
	# in fondo; passandoci sopra si accende il bordo chiaro
	for colore in ["font_color", "font_hover_color", "font_pressed_color"]:
		bottone.add_theme_color_override(colore, Stile.colore("box_testo"))
	for stato in ["normal", "hover", "pressed"]:
		var tappo := Manifesto.stile_pillola(Stile.colore("manifesto"), 12.0,
				Stile.colore("bordo_acceso") if stato != "normal" else Color(0, 0, 0, 0))
		tappo.content_margin_top = 1
		tappo.content_margin_bottom = 1
		bottone.add_theme_stylebox_override(stato, tappo)
	bottone.pressed.connect(richiamo)
	riga.add_child(bottone)
	var scritta := Label.new()
	scritta.text = azione
	scritta.add_theme_font_override("font", Caratteri.titolo())
	scritta.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	scritta.add_theme_color_override("font_color", Stile.colore("testo"))
	Stile.contorno(scritta, Stile.dimensione("minuscolo"))
	scritta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	riga.add_child(scritta)
	return riga
