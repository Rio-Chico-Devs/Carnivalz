extends Node

# Autoload: il linguaggio visivo del gioco, costruito una volta sola da
# data/stile.json e applicato alla radice dell'albero. Da quel momento ogni
# schermata eredita font, colori, bordi e spaziature senza doverseli
# ridichiarare: le scene non contengono piu' font_size o colori a occhio.
#
# Chi disegna qualcosa a mano (menu, mappa, combattimento) chiede qui i suoi
# valori - Stile.colore("accento"), Stile.dimensione("piccolo"),
# Stile.tempo("comparsa_box") - invece di scriverseli in giro.
#
# Deve stare negli autoload PRIMA di Impostazioni: l'alto contrasto e' una
# variante di questo tema, non un tema che lo sostituisce.

const PERCORSO := "res://data/stile.json"

var dati: Dictionary = {}
var tema: Theme
var alto_contrasto := false

func _ready() -> void:
	carica()
	applica()

func carica() -> void:
	if not FileAccess.file_exists(PERCORSO):
		push_error("File stile mancante: " + PERCORSO)
		return
	var letto: Variant = JSON.parse_string(FileAccess.get_file_as_string(PERCORSO))
	dati = letto if letto is Dictionary else {}

# --- accesso ai valori (usato anche da chi costruisce controlli a mano) ---

func colore(nome: String) -> Color:
	var esadecimale := String(dati.get("colori", {}).get(nome, ""))
	if esadecimale == "":
		return Color.MAGENTA  # colore "manca un valore": si nota subito
	if alto_contrasto and nome in ["testo", "narrazione", "testo_smorzato"]:
		return Color(1.0, 0.92, 0.2)
	return Color.html(esadecimale)

func dimensione(nome: String) -> int:
	return int(dati.get("dimensioni", {}).get(nome, 20))

func forma(nome: String) -> int:
	return int(dati.get("forme", {}).get(nome, 0))

func tempo(nome: String) -> float:
	return float(dati.get("tempi", {}).get(nome, 0.3))

func caratteri_al_secondo() -> float:
	return float(dati.get("tempi", {}).get("caratteri_al_secondo", 45))

# --- font ---

func font_da(chiave: String) -> Font:
	# priorita': un .ttf messo dentro il progetto > un font di sistema >
	# niente (e Godot usa il suo font incorporato)
	var config: Dictionary = dati.get("font", {})
	var percorso := String(config.get("file_" + chiave, ""))
	if percorso != "" and ResourceLoader.exists(percorso):
		return load(percorso)
	if not bool(config.get("usa_font_di_sistema", true)):
		return null
	var nomi: Array = config.get(chiave, [])
	if nomi.is_empty():
		return null
	var famiglia := SystemFont.new()
	var elenco := PackedStringArray()
	for nome in nomi:
		elenco.append(String(nome))
	famiglia.font_names = elenco
	return famiglia

# --- costruzione del tema ---

func applica() -> void:
	tema = costruisci_tema()
	get_tree().root.theme = tema

func imposta_alto_contrasto(attivo: bool) -> void:
	alto_contrasto = attivo
	applica()

func costruisci_tema() -> Theme:
	var t := Theme.new()
	var corpo := font_da("corpo")
	if corpo != null:
		t.default_font = corpo
	t.default_font_size = dimensione("corpo")

	# Label: il testo semplice dell'interfaccia
	t.set_color("font_color", "Label", colore("testo"))
	t.set_font_size("font_size", "Label", dimensione("corpo"))

	# RichTextLabel: narrazione, dialoghi, diario di combattimento
	t.set_color("default_color", "RichTextLabel", colore("testo"))
	for chiave in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		t.set_font_size(chiave, "RichTextLabel", dimensione("corpo"))

	# Bottoni: un solo aspetto in tutto il gioco, quattro stati leggibili
	t.set_stylebox("normal", "Button", stile_bottone("normale"))
	t.set_stylebox("hover", "Button", stile_bottone("sopra"))
	t.set_stylebox("pressed", "Button", stile_bottone("premuto"))
	t.set_stylebox("disabled", "Button", stile_bottone("spento"))
	t.set_stylebox("focus", "Button", stile_bottone("fuoco"))
	t.set_color("font_color", "Button", colore("testo"))
	t.set_color("font_hover_color", "Button", colore("accento"))
	t.set_color("font_pressed_color", "Button", colore("accento"))
	t.set_color("font_focus_color", "Button", colore("accento"))
	t.set_color("font_disabled_color", "Button", colore("testo_smorzato"))
	t.set_font_size("font_size", "Button", dimensione("corpo"))

	# CheckBox e slider delle Opzioni: stessi colori del resto
	t.set_color("font_color", "CheckBox", colore("testo"))
	t.set_color("font_hover_color", "CheckBox", colore("accento"))
	t.set_font_size("font_size", "CheckBox", dimensione("corpo"))
	t.set_color("font_color", "LineEdit", colore("testo"))

	# Pannelli
	t.set_stylebox("panel", "PanelContainer", stile_pannello())
	t.set_stylebox("panel", "Panel", stile_pannello())
	return t

func stile_pannello() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = colore("pannello")
	s.border_color = colore("bordo")
	s.set_border_width_all(forma("bordo"))
	s.set_corner_radius_all(forma("raggio"))
	return s

func stile_bottone(stato: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(forma("raggio"))
	s.set_border_width_all(forma("bordo"))
	s.content_margin_left = forma("padding_bottone_x")
	s.content_margin_right = forma("padding_bottone_x")
	s.content_margin_top = forma("padding_bottone_y")
	s.content_margin_bottom = forma("padding_bottone_y")
	match stato:
		"sopra":
			s.bg_color = colore("pannello_chiaro")
			s.border_color = colore("bordo_acceso")
		"premuto":
			s.bg_color = colore("bordo")
			s.border_color = colore("bordo_acceso")
		"spento":
			s.bg_color = Color(colore("pannello"), 0.35)
			s.border_color = Color(colore("bordo"), 0.4)
		"fuoco":
			s.bg_color = colore("pannello_chiaro")
			s.border_color = colore("bordo_acceso")
			s.set_border_width_all(forma("bordo_acceso"))
		_:
			s.bg_color = colore("pannello")
			s.border_color = colore("bordo")
	return s

# --- aiutanti per i controlli costruiti a mano ---

func scelta(bottone: Button) -> void:
	# le scelte di un dialogo si leggono come righe di un elenco, non come
	# pulsanti da modulo: testo a sinistra, tutta la larghezza disponibile
	bottone.alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottone.custom_minimum_size = Vector2(0, 44)

func etichetta_piccola(etichetta: Label) -> void:
	etichetta.add_theme_font_size_override("font_size", dimensione("piccolo"))
	etichetta.add_theme_color_override("font_color", colore("testo_smorzato"))

func titolo_schermata(etichetta: Label) -> void:
	etichetta.add_theme_font_size_override("font_size", dimensione("sezione"))
	etichetta.add_theme_color_override("font_color", colore("accento"))

func lampeggia(nodo: CanvasItem, tinta: Color) -> void:
	# un colpo si deve vedere sul ritratto, non solo leggere nel diario
	if nodo == null or not is_instance_valid(nodo):
		return
	var durata := tempo("lampeggio_colpo")
	var battito := nodo.create_tween()
	battito.tween_property(nodo, "modulate", tinta, durata * 0.35)
	battito.tween_property(nodo, "modulate", Color.WHITE, durata * 0.65)
