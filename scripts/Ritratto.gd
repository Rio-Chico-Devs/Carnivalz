extends VBoxContainer

# Ritratto riusabile (palco dialoghi e menu selezione): immagine del
# personaggio da data/, o placeholder con l'iniziale finché manca il disegno.

@onready var immagine: TextureRect = %Immagine
@onready var iniziale: Label = %Iniziale
@onready var etichetta_nome: Label = %Nome

func mostra(id_personaggio: String, livello: int = 0) -> void:
	var personaggio: Dictionary = GameState.personaggi.get(id_personaggio, {})
	var nome: String = personaggio.get("nome", id_personaggio)
	etichetta_nome.text = nome if livello <= 0 else "%s · Lv %d" % [nome, livello]
	var percorso: String = personaggio.get("ritratto", "")
	if percorso != "" and ResourceLoader.exists(percorso):
		immagine.texture = load(percorso)
		iniziale.visible = false
	else:
		immagine.texture = null
		iniziale.text = nome.left(1).to_upper()
		iniziale.visible = true
