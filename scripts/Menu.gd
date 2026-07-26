extends Control

# Menu principale del gioco: punto d'avvio. Da qui si gioca e si consultano
# le collezioni (album carte, bestiario, compendio oggetti).

const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_ALBUM := "res://scenes/Album.tscn"
const SCENA_BESTIARIO := "res://scenes/Bestiario.tscn"
const SCENA_COMPENDIO := "res://scenes/Compendio.tscn"

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

	colonna.add_child(_spazio(20))
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
	_voce(colonna, "Album delle carte", SCENA_ALBUM)
	_voce(colonna, "Bestiario", SCENA_BESTIARIO)
	_voce(colonna, "Oggetti", SCENA_COMPENDIO)

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
		get_tree().change_scene_to_file(SCENA_MAPPA))
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

func _voce(colonna: VBoxContainer, testo: String, scena: String) -> void:
	var bottone := Button.new()
	bottone.text = testo
	bottone.custom_minimum_size = Vector2(0, 44)
	bottone.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(scena))
	colonna.add_child(bottone)

func _spazio(altezza: int) -> Control:
	var vuoto := Control.new()
	vuoto.custom_minimum_size = Vector2(0, altezza)
	return vuoto
