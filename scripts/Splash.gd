extends Control

# Sequenza di loghi mostrata all'avvio, prima del menu: logo dello studio,
# poi logo personale. Ogni logo usa l'immagine in res://art/branding/ se
# esiste, altrimenti un placeholder testuale (così la sequenza funziona
# anche prima che l'illustrazione sia pronta - vedi TODO sui nomi veri).
# Un clic (o tasto) qualsiasi salta al logo successivo, o dritto al menu
# se è l'ultimo.

const SCENA_MENU := "res://scenes/Menu.tscn"
const DURATA_DISSOLVE := 0.6
const DURATA_PAUSA := 1.4

# TODO: sostituire "testo" con le immagini vere in res://art/branding/ non
# appena pronte (il percorso è già cercato per primo, in automatico).
const LOGHI := [
	{"percorso": "res://art/branding/logo_studio.png", "testo": "RIO CHICO DEVS"},
	{"percorso": "res://art/branding/logo_personale.png", "testo": "un gioco di Bru"},
]

var indice := 0
var avanzando := false
var tween_corrente: Tween
var immagine: TextureRect
var etichetta: Label

func _ready() -> void:
	var sfondo := ColorRect.new()
	sfondo.color = Color(0, 0, 0)
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sfondo)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)
	immagine = TextureRect.new()
	immagine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	immagine.custom_minimum_size = Vector2(480, 270)
	centro.add_child(immagine)
	etichetta = Label.new()
	etichetta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etichetta.add_theme_font_size_override("font_size", Stile.dimensione("sezione"))
	etichetta.add_theme_color_override("font_color", Stile.colore("accento"))
	centro.add_child(etichetta)
	var bottone_salta := Button.new()
	bottone_salta.flat = true
	bottone_salta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bottone_salta.pressed.connect(_su_salta)
	add_child(bottone_salta)
	mostra_logo(0)

func mostra_logo(i: int) -> void:
	indice = i
	if i >= LOGHI.size():
		Transizioni.vai(SCENA_MENU)
		return
	var logo: Dictionary = LOGHI[i]
	var percorso := String(logo.get("percorso", ""))
	if percorso != "" and ResourceLoader.exists(percorso):
		immagine.texture = load(percorso)
		immagine.visible = true
		etichetta.visible = false
	else:
		immagine.visible = false
		etichetta.text = String(logo.get("testo", ""))
		etichetta.visible = true
	modulate = Color(1, 1, 1, 0)
	avanzando = true
	tween_corrente = create_tween()
	tween_corrente.tween_property(self, "modulate:a", 1.0, DURATA_DISSOLVE)
	tween_corrente.tween_interval(DURATA_PAUSA)
	tween_corrente.tween_property(self, "modulate:a", 0.0, DURATA_DISSOLVE)
	tween_corrente.tween_callback(_su_fine_logo)

func _su_fine_logo() -> void:
	avanzando = false
	mostra_logo(indice + 1)

func _su_salta() -> void:
	if not avanzando:
		return
	avanzando = false
	if tween_corrente != null and tween_corrente.is_valid():
		tween_corrente.kill()
	mostra_logo(indice + 1)
