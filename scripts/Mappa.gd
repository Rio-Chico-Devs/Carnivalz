extends Control

# Mappa stellare: legge data/mappa.json e mostra un "!" dove un Carnivalz
# sta avendo luogo. Click sul marker -> selezione del party -> eventi.

const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_NEGOZIO := "res://scenes/Negozio.tscn"
const SCENA_MENU := "res://scenes/Menu.tscn"
# Seed solo cosmetico (stelle placeholder): il caso di gioco sta in GameState.rng
const SEED_STELLE := 20260721

@onready var sfondo: TextureRect = %Sfondo
@onready var strato_punti: Control = %Punti
@onready var etichetta_tazo: Label = %Tazo
@onready var bottone_negozio: Button = %BottoneNegozio
@onready var bottone_menu: Button = %BottoneMenu

func _ready() -> void:
	AudioManager.musica_chiave("mappa")
	GameState.salva()  # autosalvataggio: la mappa stellare è un punto sicuro
	resized.connect(queue_redraw)
	etichetta_tazo.text = "Tazo: %d" % GameState.tazo
	bottone_negozio.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(SCENA_NEGOZIO))
	bottone_menu.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(SCENA_MENU))
	var mappa: Dictionary = GameState.carica_mappa()
	var percorso_sfondo: String = mappa.get("sfondo", "")
	if percorso_sfondo != "" and ResourceLoader.exists(percorso_sfondo):
		sfondo.texture = load(percorso_sfondo)
	crea_punti(mappa.get("punti", []))

func crea_punti(punti: Array) -> void:
	for punto in punti:
		if not punto.get("attivo", false):
			continue  # nessun Carnivalz in corso qui: niente marker
		var marker := Button.new()
		marker.text = "!"
		marker.tooltip_text = punto.get("nome", punto.get("id", "?"))
		marker.custom_minimum_size = Vector2(44, 44)
		marker.add_theme_font_size_override("font_size", 26)
		var pos: Array = punto.get("pos", [0, 0])
		marker.position = Vector2(pos[0], pos[1]) - Vector2(22, 22)
		marker.pressed.connect(_su_punto.bind(punto))
		strato_punti.add_child(marker)
		var pulsazione := marker.create_tween().set_loops()
		pulsazione.tween_property(marker, "modulate:a", 0.45, 0.6)
		pulsazione.tween_property(marker, "modulate:a", 1.0, 0.6)

func _su_punto(punto: Dictionary) -> void:
	# click sul "!": si entra nel sistema deformato del Carnivalz (il Vuoto)
	GameState.punto_mappa_corrente = punto
	get_tree().change_scene_to_file(SCENA_VUOTO)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.04, 0.1))
	if sfondo != null and sfondo.texture != null:
		return
	# cielo placeholder finché non c'è l'illustrazione in art/mappa.png
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED_STELLE
	for i in 140:
		var centro := Vector2(rng.randf() * size.x, rng.randf() * size.y)
		draw_circle(centro, rng.randf_range(0.6, 1.8), Color(1, 1, 1, rng.randf_range(0.25, 0.9)))
