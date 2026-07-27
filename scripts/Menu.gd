extends Control

# Menu principale del gioco: tre voci, Start / Opzioni / Extra. Start apre il
# sotto-menu di avvio partita (Continua, Carica partita, Nuova partita); una
# nuova partita passa dall'introduzione (Intro.tscn) prima della mappa,
# riprendere o caricare una partita esistente no. Album/Bestiario/Compendio
# vivono ora sotto Extra, insieme a codice/social/ringraziamenti.

const SCENA_INTRO := "res://scenes/Intro.tscn"
const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_OPZIONI := "res://scenes/Opzioni.tscn"
const SCENA_EXTRA := "res://scenes/Extra.tscn"

func _ready() -> void:
	AudioManager.musica_chiave("menu")
	var sfondo := ColorRect.new()
	sfondo.color = Color(0.04, 0.03, 0.08)
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sfondo)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 14)
	colonna.custom_minimum_size = Vector2(320, 0)
	centro.add_child(colonna)

	var titolo := Label.new()
	titolo.text = "CARNIVALZ"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titolo.add_theme_font_size_override("font_size", 44)
	colonna.add_child(titolo)

	var sottotitolo := Label.new()
	sottotitolo.text = "una festa per chi ha subìto ingiustizie"
	sottotitolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sottotitolo.modulate = Color(1, 1, 1, 0.6)
	colonna.add_child(sottotitolo)

	var demo := Label.new()
	demo.text = "— demo —"
	demo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	demo.modulate = Color(1, 1, 1, 0.4)
	colonna.add_child(demo)

	colonna.add_child(_spazio(20))
	var bottone_start := Button.new()
	bottone_start.text = "Start"
	bottone_start.custom_minimum_size = Vector2(0, 44)
	bottone_start.pressed.connect(_su_start)
	colonna.add_child(bottone_start)
	var bottone_opzioni := Button.new()
	bottone_opzioni.text = "Opzioni"
	bottone_opzioni.custom_minimum_size = Vector2(0, 44)
	bottone_opzioni.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(SCENA_OPZIONI))
	colonna.add_child(bottone_opzioni)
	var bottone_extra := Button.new()
	bottone_extra.text = "Extra"
	bottone_extra.custom_minimum_size = Vector2(0, 44)
	bottone_extra.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(SCENA_EXTRA))
	colonna.add_child(bottone_extra)

func _su_start() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(centro)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	colonna.custom_minimum_size = Vector2(320, 0)
	centro.add_child(colonna)
	if GameState.ha_salvataggio():
		var continua := Button.new()
		continua.text = "Continua"
		continua.custom_minimum_size = Vector2(0, 44)
		continua.pressed.connect(func() -> void:
			GameState.carica()
			get_tree().change_scene_to_file(SCENA_MAPPA))
		colonna.add_child(continua)
	var carica_partita := Button.new()
	carica_partita.text = "Carica partita"
	carica_partita.custom_minimum_size = Vector2(0, 44)
	carica_partita.pressed.connect(_su_carica_partita)
	colonna.add_child(carica_partita)
	var nuova_bottone := Button.new()
	nuova_bottone.text = "Nuova partita" if GameState.ha_salvataggio() else "Gioca"
	nuova_bottone.custom_minimum_size = Vector2(0, 44)
	nuova_bottone.pressed.connect(_su_nuova_partita)
	colonna.add_child(nuova_bottone)
	var annulla := Button.new()
	annulla.text = "Indietro"
	annulla.custom_minimum_size = Vector2(0, 40)
	annulla.pressed.connect(overlay.queue_free)
	colonna.add_child(annulla)

func _su_nuova_partita() -> void:
	GameState.nuova_partita()
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(centro)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	colonna.custom_minimum_size = Vector2(360, 0)
	centro.add_child(colonna)
	var titolo := Label.new()
	titolo.text = "Come ti chiami?"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(titolo)
	var sottotitolo := Label.new()
	sottotitolo.text = "Lascia vuoto per restare l'Anonimo."
	sottotitolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sottotitolo.modulate = Color(1, 1, 1, 0.6)
	colonna.add_child(sottotitolo)
	var campo := LineEdit.new()
	campo.placeholder_text = "Anonimo"
	campo.custom_minimum_size = Vector2(0, 40)
	colonna.add_child(campo)
	var conferma := Button.new()
	conferma.text = "Conferma"
	conferma.custom_minimum_size = Vector2(0, 44)
	conferma.pressed.connect(func() -> void:
		GameState.imposta_nome_protagonista(campo.text)
		get_tree().change_scene_to_file(SCENA_INTRO))
	colonna.add_child(conferma)
	campo.text_submitted.connect(func(_testo: String) -> void: conferma.pressed.emit())

func _su_carica_partita() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(centro)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	colonna.custom_minimum_size = Vector2(360, 0)
	centro.add_child(colonna)
	var titolo := Label.new()
	titolo.text = "Carica una partita salvata"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(titolo)
	for slot in range(1, GameState.SLOT_MASSIMO + 1):
		var occupato := GameState.ha_salvataggio_slot(slot)
		var bottone := Button.new()
		bottone.text = "Slot %d — %s" % [slot, GameState.anteprima_slot(slot)]
		bottone.custom_minimum_size = Vector2(0, 44)
		bottone.disabled = not occupato
		bottone.pressed.connect(_su_scelta_slot.bind(slot))
		colonna.add_child(bottone)
	var annulla := Button.new()
	annulla.text = "Annulla"
	annulla.custom_minimum_size = Vector2(0, 40)
	annulla.pressed.connect(overlay.queue_free)
	colonna.add_child(annulla)

func _su_scelta_slot(slot: int) -> void:
	GameState.carica_slot(slot)
	get_tree().change_scene_to_file(SCENA_MAPPA)

func _spazio(altezza: int) -> Control:
	var vuoto := Control.new()
	vuoto.custom_minimum_size = Vector2(0, altezza)
	return vuoto
