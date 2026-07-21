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
	if scelta.has("recluta"):
		GameState.recluta(scelta["recluta"])
	if scelta.has("oggetto"):
		GameState.aggiungi_oggetto(scelta["oggetto"])
	if scelta.has("lascia"):
		GameState.rimuovi_classe(scelta["lascia"])
	if scelta.has("combatti"):
		GameState.prepara_combattimento(scelta["combatti"],
				scelta.get("se_vinci", ""), scelta.get("se_perdi", ""))
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
	var testo_zaino := ", ".join(GameState.inventario) if not GameState.inventario.is_empty() else "vuoto"
	stato.text = "Party: %s   •   Zaino: %s" % [testo_party, testo_zaino]
