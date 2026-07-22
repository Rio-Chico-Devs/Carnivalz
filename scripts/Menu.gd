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
	_voce(colonna, "Nuova partita" if GameState.ha_salvataggio() else "Gioca", SCENA_MAPPA, true)
	_voce(colonna, "Album delle carte", SCENA_ALBUM)
	_voce(colonna, "Bestiario", SCENA_BESTIARIO)
	_voce(colonna, "Oggetti", SCENA_COMPENDIO)

func _voce(colonna: VBoxContainer, testo: String, scena: String, nuova: bool = false) -> void:
	var bottone := Button.new()
	bottone.text = testo
	bottone.custom_minimum_size = Vector2(0, 44)
	bottone.pressed.connect(func() -> void:
		if nuova:
			GameState.nuova_partita()  # ricomincia da zero (l'autosave sulla mappa aggiorna il file)
		get_tree().change_scene_to_file(scena))
	colonna.add_child(bottone)

func _spazio(altezza: int) -> Control:
	var vuoto := Control.new()
	vuoto.custom_minimum_size = Vector2(0, altezza)
	return vuoto
