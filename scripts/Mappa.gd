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
@onready var bottone_salva: Button = %BottoneSalva

func _ready() -> void:
	AudioManager.musica_chiave("mappa")
	GameState.salva()  # autosalvataggio: la mappa stellare è l'unico punto che salva
	resized.connect(queue_redraw)
	etichetta_tazo.text = "Tazo: %d" % GameState.tazo
	bottone_negozio.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(SCENA_NEGOZIO))
	bottone_menu.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(SCENA_MENU))
	bottone_salva.pressed.connect(_su_salva)
	var mappa: Dictionary = GameState.carica_mappa()
	var percorso_sfondo: String = mappa.get("sfondo", "")
	if percorso_sfondo != "" and ResourceLoader.exists(percorso_sfondo):
		sfondo.texture = load(percorso_sfondo)
	crea_punti(mappa.get("punti", []))

func crea_punti(punti: Array) -> void:
	for punto in punti:
		if not punto.get("attivo", false):
			continue  # nessun Carnivalz in corso qui: niente marker
		if punto.has("richiede_flag") and not GameState.ha_flag(punto["richiede_flag"]):
			continue  # sbloccato solo dopo un'altra campagna (es. il tutorial)
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

func _su_salva() -> void:
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
	titolo.text = "Scegli uno slot di salvataggio"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(titolo)
	for slot in range(1, GameState.SLOT_MASSIMO + 1):
		var bottone := Button.new()
		bottone.text = "Slot %d — %s" % [slot, GameState.anteprima_slot(slot)]
		bottone.custom_minimum_size = Vector2(0, 44)
		bottone.pressed.connect(_su_scelta_slot.bind(slot, overlay))
		colonna.add_child(bottone)
	var annulla := Button.new()
	annulla.text = "Annulla"
	annulla.custom_minimum_size = Vector2(0, 40)
	annulla.pressed.connect(overlay.queue_free)
	colonna.add_child(annulla)

func _su_scelta_slot(slot: int, overlay: ColorRect) -> void:
	GameState.salva_slot(slot)
	overlay.queue_free()

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
