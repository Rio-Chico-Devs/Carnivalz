class_name Foglio
extends PanelContainer

# UN FOGLIO CHE CONTIENE ALTRO, come il pannello dello zaino nel bozzetto
# approvato del Data pad: la carta chiara, il contorno nero spesso, l'ombra
# piena e il retino nell'angolo; sopra, a cavallo del bordo, l'etichetta nera
# col nome di quello che contiene. Quello che ci si scrive dentro era pensato
# per il nero: sulla carta si ritinge da se' (ritingi, qui sotto)
const MARGINE := 28.0
var titolo := "":
	set(nuovo):
		titolo = nuovo
		queue_redraw()

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margini := StyleBoxEmpty.new()
	margini.set_content_margin_all(MARGINE)
	add_theme_stylebox_override("panel", margini)
	theme = tema_carta()
	resized.connect(queue_redraw)

func _enter_tree() -> void:
	get_tree().node_added.connect(nodo_nuovo)
	nodo_nuovo(self)

func _exit_tree() -> void:
	get_tree().node_added.disconnect(nodo_nuovo)

func nodo_nuovo(nodo: Node) -> void:
	# alla fine del fotogramma: chi aggiunge una scritta le da' il colore
	# DOPO averla aggiunta
	if nodo == self or is_ancestor_of(nodo):
		(func() -> void:
			if is_instance_valid(nodo):
				ritingi(nodo)).call_deferred()

func _draw() -> void:
	# il retino stretto nell'angolo: sul foglio ci si legge, e i puntini
	# sotto le parole le sporcano
	Manifesto.carta(self, Rect2(Vector2.ZERO, size), Stile.colore("box_fondo"), 6.0, true, Vector2(0.72, 0.6))
	if titolo != "":
		Manifesto.etichetta(self, Vector2(MARGINE * 0.5, -MARGINE * 1.1), titolo, 28)


static func in_foglio(contenuto: Control, intestazione := "") -> Foglio:
	# mette "contenuto" su un foglio, al posto dove stava
	var foglio := Foglio.new()
	foglio.titolo = intestazione
	Manifesto.al_posto_di(contenuto, foglio)
	return foglio


# --- scrivere sulla carta ---------------------------------------------------------

# quello che sul nero era chiaro, sulla carta e' nero; l'arancio pieno sulla
# carta non si legge (1,5:1) e diventa quello bruciato. Contrasti su box_fondo:
# box_testo 16:1, accento_su_carta 4,6:1, tratto 4,8:1
const INCHIOSTRI_SU_CARTA := {"testo": "box_testo", "bordo_acceso": "box_testo",
		"accento": "accento_su_carta", "testo_smorzato": "tratto", "spento": "tratto"}
const COLORI_SCRITTA := ["font_color", "default_color", "font_hover_color", "font_focus_color",
		"font_pressed_color", "font_hover_pressed_color", "font_placeholder_color"]

static var il_tema_carta: Theme = null


static func tema_carta() -> Theme:
	# i colori di serie sulla carta: chi non ne sceglie uno scrive nero
	if il_tema_carta != null:
		return il_tema_carta
	il_tema_carta = Theme.new()
	var nero := Stile.colore("box_testo")
	for tipo in ["Label", "Button", "CheckBox", "LineEdit"]:
		for chiave in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
			il_tema_carta.set_color(chiave, tipo, nero)
	il_tema_carta.set_color("default_color", "RichTextLabel", nero)
	return il_tema_carta


static func ritingi(nodo: Node) -> void:
	# i colori scelti per il nero, uno per uno, con quelli della carta. Le voci
	# dei menu (VoceMenu) si colorano da sole a ogni passo e hanno gia' i loro
	if nodo.get_parent() is VoceMenu or not nodo is Control:
		return
	var scritta := nodo as Control
	for chiave in COLORI_SCRITTA:
		if scritta.has_theme_color_override(chiave):
			scritta.add_theme_color_override(chiave, su_carta(scritta.get_theme_color(chiave)))
	if scritta is RichTextLabel and (scritta as RichTextLabel).bbcode_enabled:
		var testo := (scritta as RichTextLabel).text
		for da: String in INCHIOSTRI_SU_CARTA:
			testo = testo.replace(Stile.colore(da).to_html(false), Stile.colore(INCHIOSTRI_SU_CARTA[da]).to_html(false))
		if testo != (scritta as RichTextLabel).text:
			(scritta as RichTextLabel).text = testo


static func su_carta(tinta: Color) -> Color:
	for da: String in INCHIOSTRI_SU_CARTA:
		if Color(tinta, 1.0).is_equal_approx(Stile.colore(da)):
			return Color(Stile.colore(INCHIOSTRI_SU_CARTA[da]), tinta.a)
	return tinta
