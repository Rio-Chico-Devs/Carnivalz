extends Control

# Opzioni viste dalla schermata principale. L'elenco delle opzioni non sta qui:
# sta in PannelloOpzioni, ed e' lo stesso che si apre dalla pausa mentre giochi.
# Qui c'e' solo la cornice.

const SCENA_MENU := "res://scenes/Menu.tscn"

func _ready() -> void:
	AudioManager.musica_chiave("menu")
	var sfondo := ColorRect.new()
	sfondo.color = Stile.colore("sfondo")
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sfondo)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 14)
	colonna.custom_minimum_size = Vector2(420, 0)
	centro.add_child(colonna)

	var titolo := Label.new()
	titolo.text = "Opzioni"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Stile.titolo_schermata(titolo)
	colonna.add_child(titolo)

	PannelloOpzioni.costruisci(colonna, 140)

	var spazio := Control.new()
	spazio.custom_minimum_size = Vector2(0, 10)
	colonna.add_child(spazio)
	var indietro := Button.new()
	indietro.text = "Indietro"
	indietro.custom_minimum_size = Vector2(0, 40)
	indietro.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_MENU))
	colonna.add_child(indietro)
	indietro.grab_focus()
