extends VBoxContainer

# Ritratto riusabile (palco dialoghi e menu selezione): immagine del
# personaggio da art/, con espressione, o placeholder con l'iniziale finché
# manca il disegno.
#
# Espressioni: ogni personaggio ha un'immagine per posa, in
#   res://art/personaggi/<id>/<espressione>.png
# Se manca l'espressione richiesta si ripiega su "neutra", poi sul vecchio
# campo "ritratto" (immagine singola), poi sull'iniziale.

const ESPRESSIONI := [
	"neutra", "arrabbiata", "felice", "carina", "infastidita", "disgusto",
	"speciale", "dialogo", "delusa", "petrificata", "annoiata", "pensiero",
	"sorpresa", "sforzo", "cool", "decisa",
]

@onready var immagine: TextureRect = %Immagine
@onready var iniziale: Label = %Iniziale
@onready var etichetta_nome: Label = %Nome
@onready var etichetta_extra: Label = %Extra

func mostra(id_personaggio: String, livello: int = 0, espressione: String = "neutra") -> void:
	var personaggio: Dictionary = GameState.personaggi.get(id_personaggio, {})
	var nome: String = personaggio.get("nome", id_personaggio)
	etichetta_nome.text = nome if livello <= 0 else "%s · Lv %d" % [nome, livello]
	var percorso := percorso_immagine(id_personaggio, personaggio, espressione)
	if percorso != "":
		immagine.texture = load(percorso)
		iniziale.visible = false
	else:
		immagine.texture = null
		iniziale.text = nome.left(1).to_upper()
		iniziale.visible = true

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
