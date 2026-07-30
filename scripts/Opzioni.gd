extends Control

# Opzioni: audio (master/musica/effetti), grafica (schermo intero), e
# accessibilità (testo grande, alto contrasto). Applicate subito e salvate a
# ogni modifica in Impostazioni (user://impostazioni.cfg, indipendente dagli
# slot di salvataggio della partita).

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

	colonna.add_child(_sezione("Audio"))
	_cursore(colonna, "Volume generale", Impostazioni.volume_master, func(v: float) -> void:
		Impostazioni.volume_master = v
		Impostazioni.applica_volumi()
		Impostazioni.salva())
	_cursore(colonna, "Musica", Impostazioni.volume_musica, func(v: float) -> void:
		Impostazioni.volume_musica = v
		Impostazioni.applica_volumi()
		Impostazioni.salva())
	_cursore(colonna, "Effetti", Impostazioni.volume_effetti, func(v: float) -> void:
		Impostazioni.volume_effetti = v
		Impostazioni.applica_volumi()
		Impostazioni.salva())

	colonna.add_child(_sezione("Grafica"))
	_interruttore(colonna, "Schermo intero", Impostazioni.schermo_intero, func(attivo: bool) -> void:
		Impostazioni.schermo_intero = attivo
		Impostazioni.applica_schermo()
		Impostazioni.salva())

	colonna.add_child(_sezione("Accessibilità"))
	_interruttore(colonna, "Testo più grande", Impostazioni.testo_grande, func(attivo: bool) -> void:
		Impostazioni.testo_grande = attivo
		Impostazioni.applica_scala_testo()
		Impostazioni.salva())
	_interruttore(colonna, "Alto contrasto", Impostazioni.alto_contrasto, func(attivo: bool) -> void:
		Impostazioni.alto_contrasto = attivo
		Impostazioni.applica_alto_contrasto()
		Impostazioni.salva())
	_cursore(colonna, "Velocità del testo", (Impostazioni.velocita_testo - 0.4) / 2.6, func(v: float) -> void:
		# 0 = si legge parola per parola, 1 = compare quasi tutto insieme
		Impostazioni.velocita_testo = 0.4 + v * 2.6
		Impostazioni.salva())

	colonna.add_child(_spazio(10))
	var indietro := Button.new()
	indietro.text = "Indietro"
	indietro.custom_minimum_size = Vector2(0, 40)
	indietro.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_MENU))
	colonna.add_child(indietro)

func _cursore(colonna: VBoxContainer, testo: String, valore: float, su_cambio: Callable) -> void:
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 12)
	colonna.add_child(riga)
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.custom_minimum_size = Vector2(140, 0)
	riga.add_child(etichetta)
	var cursore := HSlider.new()
	cursore.min_value = 0.0
	cursore.max_value = 1.0
	cursore.step = 0.05
	cursore.value = valore
	cursore.custom_minimum_size = Vector2(220, 0)
	cursore.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cursore.value_changed.connect(su_cambio)
	riga.add_child(cursore)

func _interruttore(colonna: VBoxContainer, testo: String, attivo: bool, su_cambio: Callable) -> void:
	var casella := CheckBox.new()
	casella.text = testo
	casella.button_pressed = attivo
	casella.toggled.connect(su_cambio)
	colonna.add_child(casella)

func _sezione(testo: String) -> Control:
	var contenitore := VBoxContainer.new()
	contenitore.add_theme_constant_override("separation", 2)
	var spazio := Control.new()
	spazio.custom_minimum_size = Vector2(0, 8)
	contenitore.add_child(spazio)
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.modulate = Color(1, 1, 1, 0.5)
	Stile.etichetta_piccola(etichetta)
	contenitore.add_child(etichetta)
	return contenitore

func _spazio(altezza: int) -> Control:
	var vuoto := Control.new()
	vuoto.custom_minimum_size = Vector2(0, altezza)
	return vuoto
