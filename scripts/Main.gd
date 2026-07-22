extends Control

# Motore eventi: mostra il nodo corrente, filtra le scelte per requisiti
# e applica gli effetti (recluta / oggetto / lascia / reset). I contenuti
# vivono solo nei JSON.
#
# Palco dialoghi sopra il box: a sinistra sempre il protagonista (o un
# alternativo indicato dal nodo), a destra l'interlocutore della
# discussione. Se il nodo indica "centro", parla un solo personaggio al
# centro e i due spazi laterali spariscono.

const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_COMBATTIMENTO := "res://scenes/Combattimento.tscn"
const EVENTI_DEBUG := "res://data/events.json"

@onready var slot_sinistra = %SlotSinistra
@onready var slot_centro = %SlotCentro
@onready var slot_destra = %SlotDestra
@onready var narratore: RichTextLabel = %Narratore
@onready var contenitore_scelte: VBoxContainer = %Scelte
@onready var stato: Label = %Stato

func _ready() -> void:
	if GameState.eventi.is_empty():
		# scena avviata direttamente dall'editor: carica la campagna di prova
		GameState.avvia_carnivalz("debug", EVENTI_DEBUG)
	mostra_nodo(GameState.nodo_corrente)

func mostra_nodo(id_nodo: String) -> void:
	var nodo: Dictionary = GameState.eventi.get(id_nodo, {})
	if nodo.is_empty():
		push_error("Nodo evento mancante: " + id_nodo)
		return
	GameState.nodo_corrente = id_nodo
	narratore.text = nodo.get("testo", "")
	aggiorna_palco(nodo)
	aggiorna_stato()
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	for scelta in nodo.get("scelte", []):
		if scelta.has("richiede") and not GameState.party_ha_abilita(scelta["richiede"]):
			continue  # requisito non soddisfatto: la scelta non appare proprio
		if scelta.has("richiede_legame") and GameState.legame < int(scelta["richiede_legame"]):
			continue  # evento raro: serve un legame abbastanza coltivato
		if scelta.has("richiede_ospite") and scelta["richiede_ospite"] not in GameState.ospiti:
			continue
		if int(scelta.get("tazo", 0)) < 0 and GameState.tazo < -int(scelta.get("tazo", 0)):
			continue  # non puoi pagare cio' che non hai
		var bottone := Button.new()
		bottone.text = scelta.get("testo", "…")
		bottone.pressed.connect(_su_scelta.bind(scelta))
		contenitore_scelte.add_child(bottone)

func aggiorna_palco(nodo: Dictionary) -> void:
	if nodo.has("centro"):
		slot_sinistra.visible = false
		slot_destra.visible = false
		slot_centro.visible = true
		slot_centro.mostra(nodo["centro"])
		return
	slot_centro.visible = false
	slot_sinistra.visible = true
	slot_sinistra.mostra(nodo.get("sinistra", GameState.id_protagonista))
	slot_destra.visible = nodo.has("destra")
	if nodo.has("destra"):
		slot_destra.mostra(nodo["destra"])

func _su_scelta(scelta: Dictionary) -> void:
	GameState.modifica_legame(-1)  # il legame respira: cala se non lo curi
	if scelta.has("recluta"):
		GameState.recluta(scelta["recluta"])
	if scelta.has("oggetto"):
		GameState.aggiungi_oggetto(scelta["oggetto"])
	if scelta.has("lascia"):
		GameState.rimuovi_classe(scelta["lascia"])
	if scelta.has("ospite"):
		GameState.aggiungi_ospite(scelta["ospite"])
	if scelta.has("tazo"):
		GameState.modifica_tazo(int(scelta["tazo"]))
	if scelta.has("sblocca_negozio"):
		GameState.sblocca_negozio(scelta["sblocca_negozio"])
	if scelta.has("stress"):
		for id_classe in GameState.party:
			GameState.modifica_stress(id_classe, int(scelta["stress"]))
	if scelta.has("legame"):
		GameState.modifica_legame(int(scelta["legame"]))
	if scelta.has("combatti"):
		GameState.prepara_combattimento(scelta["combatti"], scelta.get("se_vinci", ""),
				scelta.get("se_vinci_eroe", ""), scelta.get("se_perdi", ""))
		get_tree().change_scene_to_file(SCENA_COMBATTIMENTO)
		return
	if scelta.get("reset", false):
		GameState.reset_campagna()
		get_tree().change_scene_to_file(SCENA_MAPPA)
		return
	if scelta.has("vai"):
		mostra_nodo(scelta["vai"])

func aggiorna_stato() -> void:
	var nomi: Array[String] = []
	for id_classe in GameState.party:
		nomi.append(String(GameState.classi.get(id_classe, {}).get("nome", id_classe)))
	var testo_party := ", ".join(nomi) if not nomi.is_empty() else "solo tu"
	stato.text = "Party: %s   •   Sacca %d/%d   •   Tazo %d   •   Legame %d" % [
		testo_party, GameState.sacca.size(), int(GameState.regole.get("sacca_massima", 20)),
		GameState.tazo, GameState.legame,
	]
