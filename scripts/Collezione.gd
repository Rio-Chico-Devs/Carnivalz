extends Control
class_name Collezione

# Base riusabile per le schermate-collezione (album, bestiario, compendio):
# sfondo, titolo, lista scorrevole di schede, bottone indietro al menu.
# Le sottoclassi implementano solo popola().

const SCENA_MENU := "res://scenes/Menu.tscn"

var lista: VBoxContainer

func _ready() -> void:
	var sfondo := ColorRect.new()
	sfondo.color = Color(0.05, 0.04, 0.09)
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sfondo)

	var margini := MarginContainer.new()
	margini.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lato in ["left", "top", "right", "bottom"]:
		margini.add_theme_constant_override("margin_" + lato, 40)
	add_child(margini)

	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 14)
	margini.add_child(colonna)

	var titolo := Label.new()
	titolo.text = titolo_schermata()
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titolo.add_theme_font_size_override("font_size", 28)
	colonna.add_child(titolo)

	var scorri := ScrollContainer.new()
	scorri.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna.add_child(scorri)

	lista = VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation", 10)
	scorri.add_child(lista)

	var indietro := Button.new()
	indietro.text = "Torna al menu"
	indietro.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	indietro.pressed.connect(func() -> void: get_tree().change_scene_to_file(SCENA_MENU))
	colonna.add_child(indietro)

	popola()

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
	etichetta_titolo.add_theme_font_size_override("font_size", 18)
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
