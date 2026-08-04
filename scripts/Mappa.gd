extends Control

# La proiezione del settore, guardata dal tavolo tattico della Sala operativa
# (vedi Sede.gd): legge data/mappa.json e mostra un "!" dove un Carnivalz sta
# avendo luogo. Click sul marker -> si entra nel Vuoto di quel sistema.
#
# Non e' piu' il posto in cui si vive fra una missione e l'altra, ed e' per
# questo che qui non si salva e non si compra: la Sede fa quelle cose. Qui si
# guarda dove andare, e si va.
#
# Un punto dove non hai ancora messo piede pulsa e si segna col pallino; uno
# gia' battuto resta li' senza chiamarti (Stile.segna_visita). E' la stessa
# regola del Vuoto e della mappa di zona.

const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_SEDE := "res://scenes/Sede.tscn"
# Seed solo cosmetico (stelle placeholder): il caso di gioco sta in GameState.rng
const SEED_STELLE := 20260721

@onready var sfondo: TextureRect = %Sfondo
@onready var strato_punti: Control = %Punti
@onready var etichetta_tazo: Label = %Tazo
@onready var bottone_sede: Button = %BottoneSede

func _ready() -> void:
	AudioManager.musica_chiave("mappa")
	resized.connect(queue_redraw)
	etichetta_tazo.text = "Tazo: %d" % GameState.tazo
	bottone_sede.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_SEDE))
	var mappa: Dictionary = GameState.carica_mappa()
	var percorso_sfondo: String = mappa.get("sfondo", "")
	if percorso_sfondo != "" and ResourceLoader.exists(percorso_sfondo):
		sfondo.texture = load(percorso_sfondo)
	crea_punti(mappa.get("punti", []))
	var legenda := Stile.legenda_visite()
	legenda.position = Vector2(24, 58)
	add_child(legenda)

func crea_punti(punti: Array) -> void:
	for punto in punti:
		if not punto.get("attivo", false):
			continue  # nessun Carnivalz in corso qui: niente marker
		if punto.has("richiede_flag") and not GameState.ha_flag(punto["richiede_flag"]):
			continue  # sbloccato solo dopo un'altra campagna (es. il tutorial)
		var id_punto := String(punto.get("id", ""))
		var stato := GameState.stato_visita(id_punto, String(punto.get("flag_completato", "")))
		var marker := Button.new()
		marker.text = "!"
		marker.tooltip_text = punto.get("nome", id_punto)
		marker.custom_minimum_size = Vector2(44, 44)
		marker.add_theme_font_size_override("font_size", Stile.dimensione("sezione"))
		Stile.segna_visita(marker, stato)
		var pos: Array = punto.get("pos", [0, 0])
		marker.position = Vector2(pos[0], pos[1]) - Vector2(22, 22)
		marker.pressed.connect(_su_punto.bind(punto))
		strato_punti.add_child(marker)
		var etichetta := Label.new()
		etichetta.text = String(punto.get("nome", id_punto))
		etichetta.add_theme_color_override("font_color", Stile.colore_visita(stato))
		etichetta.position = marker.position + Vector2(52, 10)
		etichetta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strato_punti.add_child(etichetta)
		if stato != "visto":
			# un posto nuovo (o uno appena chiuso) si fa notare; uno gia' battuto
			# resta fermo, o la mappa diventa un albero di Natale
			var pulsazione := marker.create_tween().set_loops()
			pulsazione.tween_property(marker, "modulate:a", 0.45, 0.6)
			pulsazione.tween_property(marker, "modulate:a", 1.0, 0.6)

func _su_punto(punto: Dictionary) -> void:
	# click sul "!": si entra nel sistema deformato del Carnivalz (il Vuoto)
	GameState.punto_mappa_corrente = punto
	GameState.segna_visitata(String(punto.get("id", "")))
	Transizioni.vai(SCENA_VUOTO)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Stile.colore("sfondo"))
	if sfondo != null and sfondo.texture != null:
		return
	# cielo placeholder finché non c'è l'illustrazione in art/mappa.png
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED_STELLE
	for i in 140:
		var centro := Vector2(rng.randf() * size.x, rng.randf() * size.y)
		draw_circle(centro, rng.randf_range(0.6, 1.8), Color(1, 1, 1, rng.randf_range(0.25, 0.9)))
