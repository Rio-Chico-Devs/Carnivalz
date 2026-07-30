extends Control

# Crawl introduttivo: testo centrato su schermo nero, dissolve in ingresso,
# un paragrafo alla volta (clic per proseguire). Racconta l'origine del
# Vuoto e del fattore di disallineamento prima che inizi il gioco vero.
# Finita la sequenza si passa al monologo del protagonista (Main.tscn,
# data/events_intro.json), che avvia da solo il tutorial - il giocatore non
# sceglie lui il punto di partenza.

const SCENA_EVENTI := "res://scenes/Main.tscn"
const FILE_EVENTI_INTRO := "res://data/events_intro.json"
const DURATA_DISSOLVE := 1.0

const PARAGRAFI := [
	"In uno spazio remoto... fra il calore di mille stelle e il freddo mortale del vuoto... diverse forme di vita cercano di farsi strada per poter guardare per la prima volta la luce...",
	"Una lotta continua che fa ribollire i fluidi all'interno dei loro corpi imperfetti...",
	"Nel corso del tempo innumerevoli battaglie, epoche di pace e distorsioni hanno avuto luogo... creando quella che oggi definiamo come realtà.",
	"Non si sa bene quando né dove... Ma strane anomalie hanno cominciato a distorcere e corrompere quelle che possono essere chiamate epoche distribuite nell'asse del tempo, creando delle brecce nelle quali alcuni esseri speciali, benedetti dalle proprie fratture interne, possono entrare e uscire a piacimento...",
	"L'intera esistenza ha cominciato a muoversi in modo più caotico, con un ritmo macabro... Ogni cambiamento nel suo movimento genera una frattura dove le emozioni più forti hanno la meglio sulle regole e l'equilibrio, danzando freneticamente in un carnevale infinito, contaminando e corrompendo tutto quel che è vicino...",
]

var indice := 0
var etichetta: RichTextLabel
var suggerimento: Label

func _ready() -> void:
	AudioManager.musica_chiave("intro")
	var sfondo := ColorRect.new()
	sfondo.color = Color(0, 0, 0)
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sfondo)

	var margini := MarginContainer.new()
	margini.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margini.add_theme_constant_override("margin_left", 140)
	margini.add_theme_constant_override("margin_right", 140)
	add_child(margini)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margini.add_child(centro)
	etichetta = RichTextLabel.new()
	etichetta.bbcode_enabled = true
	etichetta.fit_content = true
	etichetta.scroll_active = false
	etichetta.custom_minimum_size = Vector2(880, 0)
	etichetta.add_theme_font_size_override("normal_font_size", Stile.dimensione("corpo"))
	etichetta.add_theme_color_override("default_color", Stile.colore("narrazione"))
	centro.add_child(etichetta)

	suggerimento = Label.new()
	suggerimento.text = "▸ premi per continuare"
	suggerimento.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	suggerimento.add_theme_color_override("font_color", Stile.colore("testo_smorzato"))
	suggerimento.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	suggerimento.position.y -= 40
	add_child(suggerimento)

	var bottone_avanti := Button.new()
	bottone_avanti.flat = true
	bottone_avanti.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bottone_avanti.pressed.connect(_su_avanti)
	add_child(bottone_avanti)

	mostra_paragrafo(0)

func mostra_paragrafo(i: int) -> void:
	indice = i
	if i >= PARAGRAFI.size():
		_su_fine_introduzione()
		return
	etichetta.text = "[center]%s[/center]" % PARAGRAFI[i]
	etichetta.modulate = Color(1, 1, 1, 0)
	var dissolve := create_tween()
	dissolve.tween_property(etichetta, "modulate:a", 1.0, DURATA_DISSOLVE)

func _su_avanti() -> void:
	mostra_paragrafo(indice + 1)

func _su_fine_introduzione() -> void:
	# "fine introduzione": da qui in poi parla il protagonista, e alla fine
	# del suo monologo il tutorial parte da solo (avvio_automatico)
	GameState.avvia_carnivalz("intro", FILE_EVENTI_INTRO)
	Transizioni.vai(SCENA_EVENTI)
