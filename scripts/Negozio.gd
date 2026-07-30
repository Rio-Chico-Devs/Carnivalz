extends Control

# Negozi data-driven (data/negozi.json): mostra solo quelli sbloccati
# (negozi_sbloccati in GameState), lo stock evolve con le fonti estinte
# (campo da_fonti) e l'Artigiano baratta materiali collezionati.

const SCENA_MAPPA := "res://scenes/Mappa.tscn"

@onready var etichetta_tazo: Label = %Tazo
@onready var lista: VBoxContainer = %Lista
@onready var bottone_mappa: Button = %BottoneMappa

func _ready() -> void:
	bottone_mappa.pressed.connect(_su_mappa)
	costruisci()

func costruisci() -> void:
	etichetta_tazo.text = "Tazo: %d   •   Sacca %d/%d" % [
		GameState.tazo, GameState.sacca.size(), int(GameState.regole.get("sacca_massima", 20))]
	for figlio in lista.get_children():
		figlio.queue_free()
	for id_negozio in GameState.negozi_sbloccati:
		var negozio: Dictionary = GameState.negozi.get(id_negozio, {})
		if negozio.is_empty():
			continue
		aggiungi_intestazione(negozio)
		for voce in negozio.get("stock", []):
			if int(voce.get("da_fonti", 0)) > GameState.fonti_estinte:
				continue  # lo stock evolve man mano che estingui fonti
			aggiungi_voce_vendita(voce)
		for baratto in negozio.get("baratti", []):
			aggiungi_voce_baratto(baratto)

func aggiungi_intestazione(negozio: Dictionary) -> void:
	var titolo := Label.new()
	titolo.text = negozio.get("nome", "?")
	titolo.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	lista.add_child(titolo)
	var descrizione := Label.new()
	descrizione.text = negozio.get("descrizione", "")
	descrizione.modulate = Color(1, 1, 1, 0.7)
	descrizione.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lista.add_child(descrizione)

func aggiungi_voce_vendita(voce: Dictionary) -> void:
	var id_oggetto: String = voce.get("oggetto", "")
	var oggetto := GameState.dati_oggetto(id_oggetto)
	var prezzo := int(voce.get("prezzo", 0))
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 12)
	var nome := Label.new()
	nome.text = "%s — %s" % [oggetto.get("nome", id_oggetto), oggetto.get("descrizione", "")]
	nome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(nome)
	var bottone := Button.new()
	bottone.text = "Compra (%d Tazo)" % prezzo
	bottone.disabled = GameState.tazo < prezzo
	bottone.pressed.connect(func() -> void:
		if GameState.compra(id_oggetto, prezzo):
			costruisci())
	riga.add_child(bottone)
	lista.add_child(riga)

func aggiungi_voce_baratto(baratto: Dictionary) -> void:
	var richiesti: Array = baratto.get("richiede", [])
	var prodotto: String = baratto.get("produce", "")
	var nomi_materiali: Array[String] = []
	for materiale in richiesti:
		nomi_materiali.append(String(GameState.dati_oggetto(materiale).get("nome", materiale)))
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 12)
	var nome := Label.new()
	nome.text = "Porta: %s  →  %s" % [", ".join(nomi_materiali),
			GameState.dati_oggetto(prodotto).get("nome", prodotto)]
	nome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(nome)
	var bottone := Button.new()
	bottone.text = "Baratta"
	bottone.pressed.connect(func() -> void:
		if GameState.baratta(richiesti, prodotto):
			costruisci())
	riga.add_child(bottone)
	lista.add_child(riga)

func _su_mappa() -> void:
	Transizioni.vai(SCENA_MAPPA)
