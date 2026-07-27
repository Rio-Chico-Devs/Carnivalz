extends Control

# Mappa dungeon della zona corrente: le sue stanze (GameState.mappa_zona,
# campo "mappa_dungeon" del file eventi), libere da visitare in qualunque
# ordine ma solo se sbloccate (GameState.stanza_sbloccata()). Raggiunta dal
# bottone "Mappa" in Main.gd, o da una scelta con "torna_a_mappa": cliccare
# una stanza sbloccata vi rientra (GameState.nodo_corrente cambia, si torna
# a Main.tscn). Le stanze non sbloccate mostrano solo "???", come ogni
# altro contenuto ancora nascosto in questo gioco (vedi Collezione.gd).

const SCENA_EVENTI := "res://scenes/Main.tscn"

func _ready() -> void:
	var sfondo := ColorRect.new()
	sfondo.color = Color(0.05, 0.04, 0.1)
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sfondo)

	var percorso_sfondo := String(GameState.mappa_zona.get("sfondo", ""))
	if percorso_sfondo != "" and ResourceLoader.exists(percorso_sfondo):
		var immagine := TextureRect.new()
		immagine.texture = load(percorso_sfondo)
		immagine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		immagine.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		immagine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(immagine)

	var strato_stanze := Control.new()
	strato_stanze.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(strato_stanze)
	for stanza in GameState.mappa_zona.get("stanze", []):
		crea_marker(strato_stanze, stanza)

	var bottone_indietro := Button.new()
	bottone_indietro.text = "Torna alla stanza corrente"
	bottone_indietro.position = Vector2(24, 24)
	bottone_indietro.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(SCENA_EVENTI))
	add_child(bottone_indietro)

func crea_marker(strato: Control, stanza: Dictionary) -> void:
	var id_stanza := String(stanza.get("id", ""))
	var sbloccata := GameState.stanza_sbloccata(id_stanza)
	var bottone := Button.new()
	bottone.text = String(stanza.get("nome", id_stanza)) if sbloccata else "???"
	bottone.custom_minimum_size = Vector2(160, 48)
	var pos: Array = stanza.get("pos", [0, 0])
	bottone.position = Vector2(pos[0], pos[1]) - Vector2(80, 24)
	bottone.disabled = not sbloccata
	if not sbloccata:
		bottone.modulate = Color(1, 1, 1, 0.4)
	elif id_stanza == GameState.nodo_corrente:
		bottone.modulate = Color(1, 0.9, 0.6)  # dove ti trovi ora
	bottone.pressed.connect(_su_stanza.bind(id_stanza))
	strato.add_child(bottone)

func _su_stanza(id_stanza: String) -> void:
	GameState.nodo_corrente = id_stanza
	get_tree().change_scene_to_file(SCENA_EVENTI)
