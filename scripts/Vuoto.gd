extends Control

# Il Vuoto: il sistema deformato intorno al pianeta del Carnivalz.
# Al centro il pianeta (la campagna principale), intorno gli squarci
# spazio-tempo (data-driven da mappa.json, campo "vuoti" del punto).
# Gli squarci nascosti appaiono solo con gli oggetti/flag giusti.

const SCENA_SELEZIONE := "res://scenes/Selezione.tscn"
const SCENA_EVENTI := "res://scenes/Main.tscn"
const SCENA_MAPPA := "res://scenes/Mappa.tscn"
# Seed solo cosmetico: il caso di gioco sta in GameState.rng
const SEED_STELLE := 20260722

@onready var titolo: Label = %Titolo
@onready var strato_punti: Control = %Punti
@onready var etichetta_tazo: Label = %Tazo
@onready var bottone_mappa: Button = %BottoneMappa

func _ready() -> void:
	resized.connect(queue_redraw)
	var punto: Dictionary = GameState.punto_mappa_corrente
	AudioManager.musica(String(punto.get("musica", "")))
	# si salva solo dalla mappa stellare: il Vuoto e' gia' "dentro" un sistema
	titolo.text = "IL VUOTO — %s" % punto.get("nome", "?")
	etichetta_tazo.text = "Tazo: %d" % GameState.tazo
	bottone_mappa.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(SCENA_MAPPA))
	crea_pianeta(punto)
	for vuoto in punto.get("vuoti", []):
		if vuoto_visibile(vuoto):
			crea_squarcio(vuoto)

func pianeta_accessibile(punto: Dictionary) -> bool:
	# il Carnivalz vero e proprio al centro del sistema non e' aperto da
	# subito: compare solo quando le fratture richieste sono state percorse
	for nome_flag in punto.get("pianeta_richiede_flags", []):
		if not GameState.ha_flag(nome_flag):
			return false
	return true

func crea_pianeta(punto: Dictionary) -> void:
	if not pianeta_accessibile(punto):
		return
	var bottone := Button.new()
	bottone.text = "☉  Scendi verso l'anomalia"
	bottone.custom_minimum_size = Vector2(240, 64)
	bottone.position = Vector2(640, 330) - Vector2(120, 32)
	bottone.pressed.connect(_su_pianeta)
	strato_punti.add_child(bottone)

func crea_squarcio(vuoto: Dictionary) -> void:
	var bottone := Button.new()
	bottone.text = vuoto.get("nome", "?")
	bottone.custom_minimum_size = Vector2(180, 48)
	var pos: Array = vuoto.get("pos", [0, 0])
	bottone.position = Vector2(pos[0], pos[1]) - Vector2(90, 24)
	bottone.pressed.connect(_su_squarcio.bind(vuoto))
	strato_punti.add_child(bottone)
	var pulsazione := bottone.create_tween().set_loops()
	pulsazione.tween_property(bottone, "modulate:a", 0.55, 0.8)
	pulsazione.tween_property(bottone, "modulate:a", 1.0, 0.8)

func vuoto_visibile(vuoto: Dictionary) -> bool:
	if not vuoto.get("nascosto", false):
		return true
	for id_oggetto in vuoto.get("richiede_oggetti", []):
		if not GameState.possiede_oggetto(id_oggetto):
			return false
	# richiede_flags: tutte le quest indicate devono essere completate
	for nome_flag in vuoto.get("richiede_flags", []):
		if not GameState.ha_flag(nome_flag):
			return false
	return true

func _su_pianeta() -> void:
	var punto: Dictionary = GameState.punto_mappa_corrente
	if GameState.avvia_carnivalz(punto.get("id", ""), punto.get("file_eventi", "")):
		GameState.musica_ambiente = String(punto.get("musica_campagna", ""))
		get_tree().change_scene_to_file(SCENA_SELEZIONE)

func _su_squarcio(vuoto: Dictionary) -> void:
	if GameState.entra_squarcio(vuoto.get("id", ""), vuoto.get("file_eventi", "")):
		GameState.musica_ambiente = String(vuoto.get("musica", ""))
		get_tree().change_scene_to_file(SCENA_EVENTI)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.02, 0.07))
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED_STELLE
	for i in 160:
		var centro := Vector2(rng.randf() * size.x, rng.randf() * size.y)
		draw_circle(centro, rng.randf_range(0.5, 1.6), Color(1, 1, 1, rng.randf_range(0.2, 0.8)))
	# gli anelli del sistema deformato
	for raggio in [180.0, 280.0]:
		draw_arc(Vector2(640, 330), raggio, 0, TAU, 64, Color(1, 1, 1, 0.08), 1.5)
