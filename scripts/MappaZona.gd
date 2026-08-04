extends Control

# Mappa dungeon della zona corrente: un grafo. Le stanze sono i nodi
# (GameState.mappa_zona, campo "mappa_dungeon" del file eventi), le
# "connessioni" sono gli archi. Finche' non la esplori e' solo un insieme
# di linee: una stanza mostra un bottone vero (nome + clic per entrarci,
# GameState.stanza_sbloccata()) solo se scoperta; se e' solo l'estremo
# ignoto di una linea che parte da una stanza scoperta, appare come un
# punto muto, senza nome ne' interazione; se nessuna delle due estremita'
# di una connessione e' ancora nota, la linea stessa non si disegna
# affatto. Raggiunta dal bottone "Mappa" in Main.gd, o da una scelta con
# "torna_a_mappa": cliccare una stanza sbloccata vi rientra
# (GameState.nodo_corrente cambia, si torna a Main.tscn).

const SCENA_EVENTI := "res://scenes/Main.tscn"

var stanze_per_id: Dictionary = {}

func _ready() -> void:
	var sfondo := ColorRect.new()
	sfondo.color = Stile.colore("sfondo")
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

	for stanza in GameState.mappa_zona.get("stanze", []):
		stanze_per_id[String(stanza.get("id", ""))] = stanza

	var strato_linee := Node2D.new()
	add_child(strato_linee)
	for coppia in GameState.mappa_zona.get("connessioni", []):
		if coppia.size() < 2:
			continue
		var id_a := String(coppia[0])
		var id_b := String(coppia[1])
		if GameState.stanza_sbloccata(id_a) or GameState.stanza_sbloccata(id_b):
			crea_linea(strato_linee, id_a, id_b)

	var strato_stanze := Control.new()
	strato_stanze.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(strato_stanze)
	for stanza in GameState.mappa_zona.get("stanze", []):
		crea_marker(strato_stanze, stanza)

	var bottone_indietro := Button.new()
	bottone_indietro.text = "Torna alla stanza corrente"
	bottone_indietro.position = Vector2(24, 24)
	bottone_indietro.pressed.connect(func() -> void:
		IngressoNodo.vai_al_nodo(GameState.nodo_corrente))
	add_child(bottone_indietro)

func posizione_di(id_stanza: String) -> Vector2:
	var pos: Array = stanze_per_id.get(id_stanza, {}).get("pos", [0, 0])
	return Vector2(pos[0], pos[1])

func crea_linea(strato: Node2D, id_a: String, id_b: String) -> void:
	if not (stanze_per_id.has(id_a) and stanze_per_id.has(id_b)):
		return
	var linea := Line2D.new()
	linea.points = [posizione_di(id_a), posizione_di(id_b)]
	linea.width = 2.0
	linea.default_color = Color(Stile.colore("bordo"), 0.9)
	strato.add_child(linea)

func connessa_a_scoperta(id_stanza: String) -> bool:
	for coppia in GameState.mappa_zona.get("connessioni", []):
		if coppia.size() < 2:
			continue
		var id_a := String(coppia[0])
		var id_b := String(coppia[1])
		if id_a == id_stanza and GameState.stanza_sbloccata(id_b):
			return true
		if id_b == id_stanza and GameState.stanza_sbloccata(id_a):
			return true
	return false

func crea_marker(strato: Control, stanza: Dictionary) -> void:
	var id_stanza := String(stanza.get("id", ""))
	var sbloccata := GameState.stanza_sbloccata(id_stanza)
	var pos := posizione_di(id_stanza)
	if not sbloccata and not connessa_a_scoperta(id_stanza):
		return  # non se ne conosce nemmeno l'esistenza: nessun segno sulla mappa
	if not sbloccata:
		var punto := ColorRect.new()
		punto.color = Color(Stile.colore("bordo"), 0.9)
		punto.size = Vector2(14, 14)
		punto.position = pos - Vector2(7, 7)
		punto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strato.add_child(punto)
		return
	var bottone := Button.new()
	bottone.text = String(stanza.get("nome", id_stanza))
	bottone.custom_minimum_size = Vector2(160, 48)
	bottone.position = pos - Vector2(80, 24)
	if id_stanza == GameState.nodo_corrente:
		bottone.modulate = Stile.colore("accento")  # dove ti trovi ora
	else:
		# una stanza sbloccata ma mai aperta e' esattamente il caso in cui serve
		# sapere dove non sei ancora stato: qui il conto lo tiene nodi_visitati,
		# che e' quello che gia' segna l'esplorazione
		Stile.segna_visita(bottone,
				"visto" if id_stanza in GameState.nodi_visitati else "nuovo")
	bottone.pressed.connect(_su_stanza.bind(id_stanza))
	strato.add_child(bottone)

func _su_stanza(id_stanza: String) -> void:
	GameState.nodo_corrente = id_stanza
	IngressoNodo.vai_al_nodo(GameState.nodo_corrente)
