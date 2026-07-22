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
const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_COMBATTIMENTO := "res://scenes/Combattimento.tscn"
const EVENTI_DEBUG := "res://data/events.json"

@onready var slot_sinistra = %SlotSinistra
@onready var slot_centro = %SlotCentro
@onready var slot_destra = %SlotDestra
@onready var narratore: RichTextLabel = %Narratore
@onready var contenitore_scelte: VBoxContainer = %Scelte
@onready var bottone_dialoga: Button = %BottoneDialoga
@onready var menu_compagni: HBoxContainer = %MenuCompagni
@onready var stato: Label = %Stato

func _ready() -> void:
	if GameState.eventi.is_empty():
		# scena avviata direttamente dall'editor: carica la campagna di prova
		GameState.avvia_carnivalz("debug", EVENTI_DEBUG)
	bottone_dialoga.pressed.connect(_su_dialoga)
	mostra_nodo(GameState.nodo_corrente)

func mostra_nodo(id_nodo: String) -> void:
	var nodo: Dictionary = GameState.eventi.get(id_nodo, {})
	if nodo.is_empty():
		push_error("Nodo evento mancante: " + id_nodo)
		return
	GameState.nodo_corrente = id_nodo
	if nodo.has("flag"):
		GameState.imposta_flag(nodo["flag"])
	# agguato: ogni tanto, dalle macerie, qualcosa si fa avanti (una volta
	# per stanza a visita; vinto lo scontro si torna qui e si perlustra)
	if nodo.has("agguato") and id_nodo not in GameState.stanze_ripulite:
		GameState.stanze_ripulite.append(id_nodo)
		var agguato: Dictionary = nodo["agguato"]
		if GameState.rng.randf() < float(agguato.get("probabilita", 0.3)):
			var gruppi: Array = agguato.get("gruppi", [])
			if not gruppi.is_empty():
				var gruppo: Array = gruppi[GameState.rng.randi_range(0, gruppi.size() - 1)]
				GameState.prepara_combattimento(gruppo, id_nodo, "", agguato.get("se_perdi", ""))
				get_tree().change_scene_to_file(SCENA_COMBATTIMENTO)
				return
	narratore.text = nodo.get("testo", "")
	aggiorna_palco(nodo)
	aggiorna_stato()
	ricostruisci_scelte(nodo)
	aggiorna_dialoga()

func ricostruisci_scelte(nodo: Dictionary) -> void:
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	for scelta in nodo.get("scelte", []):
		if scelta.has("richiede") and not GameState.party_ha_abilita(scelta["richiede"]):
			continue  # requisito non soddisfatto: la scelta non appare proprio
		if scelta.has("richiede_legame") and GameState.legame < int(scelta["richiede_legame"]):
			continue  # evento raro: serve un legame abbastanza coltivato
		if scelta.has("richiede_ospite") and scelta["richiede_ospite"] not in GameState.ospiti:
			continue
		if scelta.has("richiede_flag") and not GameState.ha_flag(scelta["richiede_flag"]):
			continue
		if scelta.has("richiede_non_flag") and GameState.ha_flag(scelta["richiede_non_flag"]):
			continue
		if scelta.has("una_tantum") and GameState.ha_flag(scelta["una_tantum"]):
			continue  # gia' raccolto/fatto: la scelta non torna
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
	if scelta.has("flag"):
		GameState.imposta_flag(scelta["flag"])
	if scelta.has("una_tantum"):
		GameState.imposta_flag(scelta["una_tantum"])
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
	if scelta.get("torna_vuoto", false):
		# uscita da uno squarcio: lo stato resta, si torna al sistema
		get_tree().change_scene_to_file(SCENA_VUOTO)
		return
	if scelta.get("reset", false):
		GameState.reset_campagna()
		get_tree().change_scene_to_file(SCENA_MAPPA)
		return
	if scelta.has("vai"):
		mostra_nodo(scelta["vai"])

func aggiorna_dialoga() -> void:
	# senza compagni non c'e' nessuno con cui parlare: il bottone sparisce
	bottone_dialoga.visible = GameState.party.size() > 1
	for figlio in menu_compagni.get_children():
		figlio.queue_free()

func _su_dialoga() -> void:
	for figlio in menu_compagni.get_children():
		figlio.queue_free()
	for id_classe in GameState.party:
		if id_classe == GameState.id_protagonista:
			continue
		var bottone := Button.new()
		bottone.text = String(GameState.classi.get(id_classe, {}).get("nome", id_classe))
		bottone.pressed.connect(_su_compagno.bind(id_classe))
		menu_compagni.add_child(bottone)

func _su_compagno(id_classe: String) -> void:
	for figlio in menu_compagni.get_children():
		figlio.queue_free()
	var nome: String = String(GameState.classi.get(id_classe, {}).get("nome", id_classe))
	var voce: Dictionary = GameState.dialoghi.get(GameState.nodo_corrente, {})
	var gia_detta: bool = voce.has("una_tantum") and GameState.ha_flag(voce["una_tantum"])
	if voce.is_empty() or gia_detta:
		narratore.append_text("\n\n[i]%s non ha altro da dirti, qui.[/i]" % nome)
		return
	narratore.append_text("\n\n" + (String(voce.get("testo", "")) % nome))
	if voce.has("flag"):
		GameState.imposta_flag(voce["flag"])
	if voce.has("una_tantum"):
		GameState.imposta_flag(voce["una_tantum"])
	# la battuta puo' aver sbloccato una scelta gated da richiede_flag
	ricostruisci_scelte(GameState.eventi.get(GameState.nodo_corrente, {}))

func aggiorna_stato() -> void:
	var nomi: Array[String] = []
	for id_classe in GameState.party:
		nomi.append(String(GameState.classi.get(id_classe, {}).get("nome", id_classe)))
	var testo_party := ", ".join(nomi) if not nomi.is_empty() else "solo tu"
	stato.text = "Party: %s   •   Sacca %d/%d   •   Tazo %d   •   Legame %d" % [
		testo_party, GameState.sacca.size(), int(GameState.regole.get("sacca_massima", 20)),
		GameState.tazo, GameState.legame,
	]
