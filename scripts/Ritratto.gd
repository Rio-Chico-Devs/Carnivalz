extends VBoxContainer

# Ritratto riusabile (palco dialoghi, combattimento, menu selezione):
# immagine del personaggio da art/, con espressione, o placeholder con
# l'iniziale finché manca il disegno.
#
# Espressioni: ogni personaggio ha un'immagine per posa, in
#   res://art/personaggi/<id>/<espressione>.png
# Se manca l'espressione richiesta si ripiega su "neutra", poi sul vecchio
# campo "ritratto" (immagine singola), poi sull'iniziale.
#
# Due comportamenti di presentazione vivono qui, non in chi lo usa:
#   - cambiare immagine non e' uno scatto: la vecchia sfuma nella nuova
#   - chi non sta parlando si attenua (imposta_attenuato), cosi' l'occhio va
#     da solo su chi ha la voce nel box

const ESPRESSIONI := [
	"neutra", "arrabbiata", "felice", "carina", "infastidita", "disgusto",
	"speciale", "dialogo", "delusa", "petrificata", "annoiata", "pensiero",
	"sorpresa", "sforzo", "cool", "decisa",
]
const OPACITA_ATTENUATA := 0.42

@onready var immagine: TextureRect = %Immagine
@onready var iniziale: Label = %Iniziale
@onready var etichetta_nome: Label = %Nome
@onready var etichetta_extra: Label = %Extra

var id_mostrato := ""
var espressione_mostrata := ""
var attenuato := false
var tween_cambio: Tween
var tween_attenuazione: Tween

func _ready() -> void:
	etichetta_nome.add_theme_color_override("font_color", Stile.colore("testo_smorzato"))
	etichetta_nome.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	etichetta_extra.add_theme_color_override("font_color", Stile.colore("bordo_acceso"))
	etichetta_extra.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	iniziale.add_theme_color_override("font_color", Stile.colore("bordo"))

func mostra(id_personaggio: String, livello: int = 0, espressione: String = "neutra") -> void:
	var cambia_immagine := id_personaggio != id_mostrato or espressione != espressione_mostrata
	id_mostrato = id_personaggio
	espressione_mostrata = espressione
	var personaggio: Dictionary = GameState.personaggi.get(id_personaggio, {})
	var nome: String = personaggio.get("nome", id_personaggio)
	etichetta_nome.text = nome if livello <= 0 else "%s · Lv %d" % [nome, livello]
	var percorso := percorso_immagine(id_personaggio, personaggio, espressione)
	if not cambia_immagine:
		return
	if percorso != "":
		immagine.texture = load(percorso)
		iniziale.visible = false
	else:
		immagine.texture = null
		iniziale.text = nome.left(1).to_upper()
		iniziale.visible = true
	dissolvi_ingresso()

func dissolvi_ingresso() -> void:
	# un personaggio che cambia posa non "scatta": ci arriva in dissolvenza
	if tween_cambio != null and tween_cambio.is_valid():
		tween_cambio.kill()
	var arrivo := 1.0 if not attenuato else OPACITA_ATTENUATA
	modulate.a = 0.0
	tween_cambio = create_tween()
	tween_cambio.tween_property(self, "modulate:a", arrivo, Stile.tempo("dissolvenza_ritratto"))

func imposta_attenuato(spento: bool) -> void:
	if spento == attenuato:
		return
	attenuato = spento
	if tween_attenuazione != null and tween_attenuazione.is_valid():
		tween_attenuazione.kill()
	tween_attenuazione = create_tween()
	tween_attenuazione.tween_property(self, "modulate:a",
			OPACITA_ATTENUATA if spento else 1.0, Stile.tempo("dissolvenza_ritratto"))

func percorso_immagine(id_personaggio: String, personaggio: Dictionary, espressione: String) -> String:
	var cartella := "res://art/personaggi/%s" % id_personaggio
	var per_espressione := "%s/%s.png" % [cartella, espressione]
	if ResourceLoader.exists(per_espressione):
		return per_espressione
	var neutra := "%s/neutra.png" % cartella
	if ResourceLoader.exists(neutra):
		return neutra
	var singolo: String = personaggio.get("ritratto", "")  # vecchia immagine unica
	if singolo != "" and ResourceLoader.exists(singolo):
		return singolo
	return ""

func imposta_extra(testo: String) -> void:
	etichetta_extra.text = testo
	etichetta_extra.visible = testo != ""

func imposta_grande(grande: bool) -> void:
	# ritratto "cinematografico": riempie lo spazio disponibile invece
	# della cornice fissa 180x220 (schermo dialoghi, nemico centrale in combattimento).
	# La Cornice e' un PanelContainer, e il tema globale (Stile.gd) da' a ogni
	# PanelContainer un pannello scuro bordato di default (utile per le schede
	# del Compendio) - ma un personaggio "grande" deve galleggiare sulla scena,
	# non stare dentro una scatola: qui lo si spegne apposta.
	var cornice: PanelContainer = get_node("Cornice")
	if grande:
		cornice.custom_minimum_size = Vector2(0, 0)
		cornice.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cornice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		immagine.size_flags_vertical = Control.SIZE_EXPAND_FILL
		immagine.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cornice.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	else:
		cornice.custom_minimum_size = Vector2(180, 220)
		cornice.size_flags_vertical = 0
		cornice.size_flags_horizontal = 0
		immagine.size_flags_vertical = 0
		immagine.size_flags_horizontal = 0
		cornice.remove_theme_stylebox_override("panel")
