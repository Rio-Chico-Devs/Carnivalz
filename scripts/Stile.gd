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

func ritmo(nome: String) -> float:
	# le pause della macchina da scrivere sulla punteggiatura
	return float(dati.get("ritmo", {}).get(nome, 0.0))

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

func stile_box_testo() -> StyleBox:
	# il box dove parla il gioco (dialogo/narrazione/notifica) e il diario di
	# combattimento condividono questa stessa cornice. Se Bru fornisce
	# un'immagine (sezione "box" di data/stile.json: usa_texture + texture +
	# margini) la si usa a nove riquadri - i bordi/angoli restano nitidi alla
	# dimensione disegnata, il centro si allunga per adattarsi a qualunque
	# testo. Senza immagine resta il box piatto coi colori di questo file:
	# cambiare uno dei due non richiede toccare nessuno script.
	var config: Dictionary = dati.get("box", {})
	var percorso := String(config.get("texture", ""))
	if bool(config.get("usa_texture", false)) and percorso != "" and ResourceLoader.exists(percorso):
		var s := StyleBoxTexture.new()
		s.texture = load(percorso)
		s.texture_margin_left = float(config.get("margine_sinistro", 24))
		s.texture_margin_right = float(config.get("margine_destro", 24))
		s.texture_margin_top = float(config.get("margine_alto", 20))
		s.texture_margin_bottom = float(config.get("margine_basso", 20))
		s.content_margin_left = float(config.get("padding_sinistro", s.texture_margin_left))
		s.content_margin_right = float(config.get("padding_destro", s.texture_margin_right))
		s.content_margin_top = float(config.get("padding_alto", s.texture_margin_top))
		s.content_margin_bottom = float(config.get("padding_basso", s.texture_margin_bottom))
		return s
	var piatto := StyleBoxFlat.new()
	piatto.bg_color = Color(colore("pannello"), 0.94)
	piatto.border_color = colore("bordo")
	piatto.set_border_width_all(forma("bordo"))
	piatto.set_corner_radius_all(forma("raggio"))
	piatto.content_margin_left = forma("padding_box_x")
	piatto.content_margin_right = forma("padding_box_x")
	piatto.content_margin_top = forma("padding_box_y")
	piatto.content_margin_bottom = forma("padding_box_y")
	return piatto

func stile_bottone(stato: String) -> StyleBox:
	var texture := stile_bottone_texture(stato)
	if texture != null:
		return texture
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

func stile_bottone_texture(stato: String) -> StyleBoxTexture:
	# se Bru disegna UN SOLO frame di bottone (sezione "bottone_texture" di
	# data/stile.json), i cinque stati derivano tutti da quella stessa
	# immagine, ricolorata (modulate_color): non serve disegnare cinque
	# varianti. Senza immagine questa funzione non ritorna nulla, e
	# stile_bottone() ripiega sul bottone piatto qui sopra.
	var config: Dictionary = dati.get("bottone_texture", {})
	var percorso := String(config.get("texture", ""))
	if not bool(config.get("usa_texture", false)) or percorso == "" or not ResourceLoader.exists(percorso):
		return null
	var s := StyleBoxTexture.new()
	s.texture = load(percorso)
	s.texture_margin_left = float(config.get("margine_sinistro", 16))
	s.texture_margin_right = float(config.get("margine_destro", 16))
	s.texture_margin_top = float(config.get("margine_alto", 10))
	s.texture_margin_bottom = float(config.get("margine_basso", 10))
	s.content_margin_left = forma("padding_bottone_x")
	s.content_margin_right = forma("padding_bottone_x")
	s.content_margin_top = forma("padding_bottone_y")
	s.content_margin_bottom = forma("padding_bottone_y")
	match stato:
		"sopra":
			s.modulate_color = Color(1.18, 1.14, 1.05)
		"premuto":
			s.modulate_color = Color(0.78, 0.78, 0.8)
		"spento":
			s.modulate_color = Color(1, 1, 1, 0.4)
		"fuoco":
			s.modulate_color = Color(1.1, 1.02, 0.85)
		_:
			s.modulate_color = Color.WHITE
	return s

# --- aiutanti per i controlli costruiti a mano ---

func scelta(bottone: Button) -> void:
	# le scelte di un dialogo si leggono come righe di un elenco, non come
	# pulsanti da modulo: testo a sinistra, tutta la larghezza disponibile.
	# Stanno nella colonna stretta di destra, quindi una scelta lunga va a
	# capo da sola invece di essere tagliata a meta' parola.
	bottone.alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottone.custom_minimum_size = Vector2(0, 44)
	bottone.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottone.clip_text = false

func colore_danno(elemento: String) -> Color:
	# Il colore di un numero che vola. "critico" e "cura" sono due elementi come
	# gli altri: chi mostra il numero sa gia' cosa sta mostrando, e chiede il
	# colore per nome invece di sceglierselo. Un elemento che nessuno ha
	# dichiarato (o una mossa senza elemento) torna al rosso del colpo normale.
	var tabella: Dictionary = dati.get("colori_danno", {})
	var esadecimale := String(tabella.get(elemento, tabella.get("normale", "#c04a4d")))
	if alto_contrasto:
		return Color(1.0, 0.92, 0.2)
	return Color.html(esadecimale)

func colore_tipo(nome_tipo: String) -> Color:
	# Il colore di uno dei cinque tipi, preso da data/tipi.json e non da qui.
	# Una seconda copia delle tinte dentro stile.json sarebbe comoda e sbagliata:
	# il giorno che Bru cambia il colore di Spirituale lo cambia dove i tipi sono
	# descritti, e questo file non ne saprebbe niente.
	var dati_tipo: Dictionary = GameState.tipi.get(nome_tipo, {})
	var esadecimale := String(dati_tipo.get("colore", ""))
	if esadecimale == "":
		return colore_danno("normale")
	if alto_contrasto:
		return Color(1.0, 0.92, 0.2)
	return Color.html(esadecimale)

func colore_colpo(elemento: String, tipo_colpo: String, critico := false) -> Color:
	# DI CHE COLORE E' QUESTO COLPO. Tre voci, in quest'ordine, e l'ordine e' il
	# ragionamento:
	#
	#   1. un critico e' oro, sempre. E' l'eccezione piu' forte che ci sia e non
	#      deve mai confondersi con nient'altro
	#   2. l'ELEMENTO, se la mossa ne dichiara uno. Il fuoco e' arancione e il
	#      veleno e' verde acido da prima che i tipi esistessero, sono colori che
	#      funzionano, e cancellarli per far posto ai tipi sarebbe stato buttare
	#      via una cosa buona per farne entrare un'altra
	#   3. il TIPO di chi colpisce, per tutto il resto. Ed e' la novita': la
	#      stragrande maggioranza dei colpi non dichiara nessun elemento, quindi
	#      fino a ieri erano tutti dello stesso rosso. Adesso un colpo di
	#      Artificio e uno di Natura si distinguono a occhio anche senza leggere
	#      niente, e cambiare arma si VEDE
	if critico:
		return colore_danno("critico")
	if elemento != "":
		return colore_danno(elemento)
	if tipo_colpo != "":
		return colore_tipo(tipo_colpo)
	return colore_danno("normale")

# --- dove sei gia' stato ---
#
# Tre stati, tre colori, uguali in tutto il gioco: la mappa stellare, il Vuoto,
# la mappa di una zona, le stanze della Sede e persino le scelte di un dialogo
# che portano da qualche parte. Un posto nuovo chiama (ottone, e un pallino che
# lo stacca dagli altri); uno gia' visto non deve piu' chiamare (smorzato); uno
# chiuso si toglie di mezzo (verde).
#
# Perche' un pallino e non solo il colore: chi non distingue bene i colori deve
# poter vedere lo stesso quali posti gli restano da battere.
const VISITA_NUOVO := "nuovo"
const VISITA_VISTO := "visto"
const VISITA_CHIUSO := "chiuso"

func colore_visita(stato: String) -> Color:
	match stato:
		VISITA_NUOVO: return colore("accento")
		VISITA_CHIUSO: return colore("positivo")
		_: return colore("testo_smorzato")

func segna_visita(bottone: Button, stato: String) -> void:
	var tinta := colore_visita(stato)
	for chiave in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		bottone.add_theme_color_override(chiave, tinta)
	if stato == VISITA_NUOVO:
		bottone.text = "•  " + bottone.text
	elif stato == VISITA_CHIUSO:
		bottone.text = "✓  " + bottone.text

func legenda_visite() -> Label:
	# senza questa riga i colori sono un indovinello: si scrive una volta, in
	# fondo a ogni schermata che li usa
	var etichetta := Label.new()
	etichetta.text = "•  non ci sei ancora stato        ✓  chiuso"
	etichetta_piccola(etichetta)
	return etichetta

func barra(larghezza := 120, altezza := 8) -> Control:
	# UNA BARRA, non un numero. "Dominio 15" e' un'informazione; una barra che
	# si riempie e poi si svuota e' una cosa che GUARDI mentre gioca. Il
	# dominio e' uno sfogo che si carica e si scarica, e senza vederlo salire
	# non c'e' niente da aspettare.
	#
	# Disegnata col segnale draw invece che con una ProgressBar: cosi' non serve
	# ne' uno script suo ne' un tema a parte, e il pieno puo' cambiare colore
	# quando la barra e' carica - che e' l'unico momento che conta.
	var telaio := Control.new()
	telaio.custom_minimum_size = Vector2(larghezza, altezza)
	telaio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	telaio.set_meta("quota", 0.0)
	telaio.draw.connect(func() -> void:
		var quota := clampf(float(telaio.get_meta("quota", 0.0)), 0.0, 1.0)
		var dentro := Rect2(Vector2.ZERO, telaio.size)
		telaio.draw_rect(dentro, colore("pannello"))
		if quota > 0.0:
			var piena := quota >= 0.999
			telaio.draw_rect(Rect2(Vector2.ZERO, Vector2(telaio.size.x * quota, telaio.size.y)),
					colore("accento") if piena else colore("bordo_acceso"))
		telaio.draw_rect(dentro, colore("bordo"), false, 1.0))
	return telaio

func riempi_barra(telaio: Control, quota: float) -> void:
	if telaio == null or not is_instance_valid(telaio):
		return
	telaio.set_meta("quota", clampf(quota, 0.0, 1.0))
	telaio.queue_redraw()

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

func pulsa(nodo: CanvasItem, durata_battito := 0.0) -> Tween:
	# battito lento e infinito di opacita': l'invito a proseguire non deve
	# mai restare immobile, o si perde tra tutto il resto che e' fermo a
	# schermo. Il nodo deve gia' essere dentro l'albero quando si chiama
	# questo (create_tween() lo richiede) - va chiamato dopo add_child().
	#
	# Restituisce il tween perche' un battito che non si puo' SPEGNERE e' meta'
	# meccanica: l'allarme della vita bassa deve smettere quando ti curi, e senza
	# un riferimento da fermare resterebbe acceso per tutto lo scontro.
	if nodo == null or not is_instance_valid(nodo):
		return null
	var durata := durata_battito if durata_battito > 0.0 else tempo("battito_indicatore")
	var battito: Tween = nodo.create_tween().set_loops()
	battito.tween_property(nodo, "modulate:a", 0.35, durata)
	battito.tween_property(nodo, "modulate:a", 1.0, durata)
	return battito

func costruisci_prompt(testo: String) -> HBoxContainer:
	# la riga "◆  premi per continuare  ◆": lo stesso identico invito a
	# proseguire ovunque compaia nel gioco (crawl introduttivo, carta del
	# titolo di un luogo). Centrata per costruzione (allineamento del
	# contenitore, non offset calcolati a mano): non puo' sfasarsi quando
	# cambia la larghezza dello schermo. Non pulsa da sola: chiamare
	# Stile.pulsa() dopo averla aggiunta all'albero.
	var riga := HBoxContainer.new()
	riga.alignment = BoxContainer.ALIGNMENT_CENTER
	riga.mouse_filter = Control.MOUSE_FILTER_IGNORE
	riga.add_theme_constant_override("separation", 14)
	riga.add_child(_rombo_prompt())
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etichetta.add_theme_color_override("font_color", colore("testo_smorzato"))
	etichetta.add_theme_font_size_override("font_size", dimensione("piccolo"))
	riga.add_child(etichetta)
	riga.add_child(_rombo_prompt())
	return riga

func _rombo_prompt() -> Label:
	var rombo := Label.new()
	rombo.text = "◆"
	rombo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rombo.add_theme_color_override("font_color", colore("bordo_acceso"))
	rombo.add_theme_font_size_override("font_size", dimensione("minuscolo"))
	return rombo
