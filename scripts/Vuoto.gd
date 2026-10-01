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

@onready var sfondo: TextureRect = %Sfondo
@onready var titolo: Label = %Titolo
@onready var strato_punti: Control = %Punti
@onready var etichetta_tazo: Label = %Tazo
@onready var bottone_mappa: Button = %BottoneMappa

func _ready() -> void:
	resized.connect(queue_redraw)
	# come la mappa stellare: l'arancio del manifesto, e il sistema nel vetro
	# di un cabinato (Manifesto.vetro_della_proiezione)
	Manifesto.trama_dietro(self).show_behind_parent = true
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	sfondo.position = vetro().position
	sfondo.size = vetro().size
	Manifesto.titolo_della_proiezione(titolo)
	etichetta_tazo.add_theme_color_override("font_color", Stile.colore("box_testo"))
	Stile.ritorno(bottone_mappa)
	var punto: Dictionary = GameState.punto_mappa_corrente
	AudioManager.musica(String(punto.get("musica", "")))
	# si salva solo dalla mappa stellare: il Vuoto e' gia' "dentro" un sistema
	titolo.text = "IL VUOTO — %s" % punto.get("nome", "?")
	var percorso_sfondo := String(punto.get("sfondo", ""))
	if percorso_sfondo != "" and ResourceLoader.exists(percorso_sfondo):
		sfondo.texture = load(percorso_sfondo)
	etichetta_tazo.text = "Tazo: %d" % GameState.tazo
	bottone_mappa.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_MAPPA))
	crea_pianeta(punto)
	for vuoto in punto.get("vuoti", []):
		if vuoto_visibile(vuoto):
			crea_squarcio(vuoto)
	var legenda := Stile.legenda_visite()
	legenda.position = Vector2(24, 58)
	add_child(legenda)

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
	bottone.position = Manifesto.nella_proiezione(Vector2(640, 330), vetro()) - Vector2(120, 32)
	bottone.pressed.connect(_su_pianeta)
	strato_punti.add_child(bottone)

func crea_squarcio(vuoto: Dictionary) -> void:
	# Uno squarcio dove non sei mai entrato chiama (pallino + battito); uno gia'
	# percorso sta zitto; uno la cui fonte e' spenta porta la spunta. E' quello
	# che serve per sapere, guardando, cosa resta da fare in questo sistema.
	var id_vuoto := String(vuoto.get("id", ""))
	var stato := GameState.stato_visita(id_vuoto, String(vuoto.get("flag_completato", "")))
	var bottone := Button.new()
	bottone.text = vuoto.get("nome", "?")
	bottone.custom_minimum_size = Vector2(180, 48)
	Stile.segna_visita(bottone, stato)
	var pos: Array = vuoto.get("pos", [0, 0])
	bottone.position = Manifesto.nella_proiezione(Vector2(pos[0], pos[1]), vetro()) - Vector2(90, 24)
	bottone.pressed.connect(_su_squarcio.bind(vuoto))
	strato_punti.add_child(bottone)
	if stato == "nuovo":
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
		Transizioni.vai(SCENA_SELEZIONE)

func _su_squarcio(vuoto: Dictionary) -> void:
	if GameState.entra_squarcio(vuoto.get("id", ""), vuoto.get("file_eventi", "")):
		GameState.musica_ambiente = String(vuoto.get("musica", ""))
		IngressoNodo.vai_al_nodo(GameState.nodo_corrente)

func vetro() -> Rect2:
	return Manifesto.vetro_della_proiezione(get_viewport_rect().size)

func _draw() -> void:
	var dentro := vetro()
	Manifesto.disegna_schermo(self, dentro.grow(14.0))
	if sfondo != null and sfondo.texture != null:
		return  # un'illustrazione vera sostituisce il cielo stellato segnaposto
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED_STELLE
	for i in 160:
		var centro := dentro.position + Vector2(rng.randf() * dentro.size.x, rng.randf() * dentro.size.y)
		draw_circle(centro, rng.randf_range(0.5, 1.6), Color(1, 1, 1, rng.randf_range(0.2, 0.8)))
	# gli anelli del sistema deformato, schiacciati come il vetro
	var centro_sistema := Manifesto.nella_proiezione(Vector2(640, 330), dentro)
	var schiaccia := dentro.size / Manifesto.MISURA_PROIEZIONE
	draw_set_transform(centro_sistema, 0.0, schiaccia)
	for raggio in [180.0, 280.0]:
		draw_arc(Vector2.ZERO, raggio, 0, TAU, 64, Color(1, 1, 1, 0.08), 1.5, true)
	draw_set_transform(Vector2.ZERO)
