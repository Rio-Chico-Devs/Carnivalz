class_name Collezione
extends Control

# Base riusabile per le schermate-collezione (album, bestiario, compendio): le
# sottoclassi implementano solo popola().
#
# LA CORNICE E' QUELLA DEL MENU PRINCIPALE, e non per bellezza: queste
# schermate si aprono da li' (COLLEZIONI), e prima erano un'altra cosa - fondo
# nero, titolo al centro, e in fondo un solo bottone, «Torna al menu», che ti
# rimetteva in cima al menu principale. Bru: «dovrei poter tornare indietro».
# Adesso:
#   - la testata sta dove sta nel menu, e l'elenco scorre in uno spazio suo,
#     fra la testata e i comandi: qualunque sia la lunghezza, non esce;
#   - in basso a destra c'e' «ESC Indietro», come in ogni passo del menu, e si
#     clicca; ESC fa la stessa cosa;
#   - indietro vuol dire COLLEZIONI, sulla voce da cui eri entrato (il menu se
#     lo segna uscendo: MenuPrincipale.ritorno);
#   - le frecce e pagina su/giu' scorrono l'elenco: si naviga anche senza mouse;
#   - la barra che scorre e' del menu (sottile, azzurra) e l'elenco le lascia
#     spazio: prima «mai trovato» ci finiva attaccato.

const SCENA_MENU := "res://scenes/Menu.tscn"
const PASSO_FRECCIA := 80.0
const FINE_ELENCO := 0.86
const SPAZIO_BARRA := 24

var lista: VBoxContainer
var scorri: ScrollContainer
var testata: Testata
var comandi: HBoxContainer
# dove porta «Indietro»: le prove lo sostituiscono, perche' cambiare scena in
# mezzo alle prove le interromperebbe
var torna := func() -> void: Transizioni.vai(SCENA_MENU)

func _ready() -> void:
	var fondale := LunaPark.new()
	fondale.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondale)
	# un velo sopra il luna park: qui si leggono schede fitte, non cinque voci
	var velo := ColorRect.new()
	velo.color = Color(Stile.colore("menu_macchia"), 0.6)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(velo)
	testata = Testata.new()
	appendi(testata, MenuPrincipale.X_TESTO, MenuPrincipale.Y_TESTATA)
	add_child(testata)
	testata.imposta(titolo_schermata().to_upper())
	scorri = ScrollContainer.new()
	scorri.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scorri.follow_focus = true
	scorri.anchor_left = MenuPrincipale.X_TESTO
	scorri.anchor_right = 1.0 - MenuPrincipale.X_TESTO
	scorri.anchor_top = MenuPrincipale.Y_VOCI
	scorri.anchor_bottom = FINE_ELENCO
	add_child(scorri)
	vesti_barra(scorri.get_v_scroll_bar())
	var margine := MarginContainer.new()
	margine.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margine.add_theme_constant_override("margin_right", SPAZIO_BARRA)
	scorri.add_child(margine)
	lista = VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation", 10)
	margine.add_child(lista)
	comandi = HBoxContainer.new()
	appendi(comandi, MenuPrincipale.X_COMANDI, MenuPrincipale.Y_COMANDI)
	comandi.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	comandi.add_child(Tasto.nuovo("ESC", "Indietro", indietro))
	add_child(comandi)
	popola()


static func vesti_barra(barra: ScrollBar) -> void:
	# sottile, dell'azzurro della testata; piu' accesa sotto il mouse
	var chiaro := Stile.colore("menu_chiaro")
	var binario := StyleBoxFlat.new()
	binario.bg_color = Color(chiaro, 0.12)
	binario.set_corner_radius_all(3)
	binario.content_margin_left = 3.0
	binario.content_margin_right = 3.0
	barra.add_theme_stylebox_override("scroll", binario)
	barra.add_theme_stylebox_override("scroll_focus", binario)
	for stato: String in ["grabber", "grabber_highlight", "grabber_pressed"]:
		var presa := StyleBoxFlat.new()
		presa.bg_color = Color(chiaro, 0.55 if stato == "grabber" else 0.9)
		presa.set_corner_radius_all(3)
		barra.add_theme_stylebox_override(stato, presa)


func appendi(nodo: Control, x: float, y: float) -> void:
	nodo.anchor_left = x
	nodo.anchor_right = x
	nodo.anchor_top = y
	nodo.anchor_bottom = y


func _unhandled_input(evento: InputEvent) -> void:
	var passo := 0.0
	if evento.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		indietro()
		return
	if evento.is_action_pressed("ui_down"):
		passo = PASSO_FRECCIA
	elif evento.is_action_pressed("ui_up"):
		passo = -PASSO_FRECCIA
	elif evento.is_action_pressed("ui_page_down"):
		passo = scorri.size.y * 0.8
	elif evento.is_action_pressed("ui_page_up"):
		passo = -scorri.size.y * 0.8
	if passo != 0.0:
		get_viewport().set_input_as_handled()
		scorri.scroll_vertical += int(passo)


func indietro() -> void:
	Movimento.suona("chiusura")
	torna.call()

func titolo_schermata() -> String:
	return "Collezione"

func popola() -> void:
	pass

# --- helper per le schede ---

func aggiungi_scheda(titolo: String, sottotitolo: String, corpo: String, colore: Color, sbloccata: bool, extra: Control = null) -> void:
	var pannello := PanelContainer.new()
	pannello.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not sbloccata:
		pannello.modulate = Color(1, 1, 1, 0.45)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	pannello.add_child(v)
	var riga := HBoxContainer.new()
	var etichetta_titolo := Label.new()
	etichetta_titolo.text = titolo
	etichetta_titolo.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	etichetta_titolo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(etichetta_titolo)
	if sottotitolo != "":
		var tag := Label.new()
		tag.text = sottotitolo
		tag.modulate = colore
		riga.add_child(tag)
	v.add_child(riga)
	if corpo != "":
		var etichetta_corpo := Label.new()
		etichetta_corpo.text = corpo
		etichetta_corpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		etichetta_corpo.modulate = Color(1, 1, 1, 0.82)
		v.add_child(etichetta_corpo)
	if extra != null:
		v.add_child(extra)
	lista.add_child(pannello)

func colore_rarita(rarita: String) -> Color:
	match rarita:
		"comune": return Color(0.75, 0.75, 0.75)
		"non_comune": return Color(0.5, 0.85, 0.55)
		"rara": return Color(0.45, 0.7, 1.0)
		"epica": return Color(0.8, 0.55, 1.0)
		"leggendaria": return Color(1.0, 0.78, 0.35)
		_: return Color(0.8, 0.8, 0.8)
