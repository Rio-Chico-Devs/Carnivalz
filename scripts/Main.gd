extends Control

# Motore eventi: mostra il nodo corrente, filtra le scelte per requisiti
# e applica gli effetti (recluta / oggetto / lascia / reset). I contenuti
# vivono solo nei JSON.
#
# Il box in basso mostra UN messaggio alla volta, in coda (coda_messaggi),
# avanzata cliccando "Continua"; solo a coda vuota compaiono le scelte vere.
# Tre tipi di messaggio:
#   - "narrazione": descrizione di quel che accade, sempre in corsivo, senza nome
#   - "dialogo": un personaggio parla, il suo nome compare centrato sul box
#   - "notifica": oggetti/Tazo raccolti, centrato, una voce alla volta
# Un nodo può avere "sequenza" (lista di messaggi) oppure, in alternativa,
# il vecchio campo "testo" (diventa un'unica narrazione, per compatibilità
# con i contenuti non ancora convertiti).
#
# Palco dialoghi sopra il box: a sinistra sempre il protagonista (o un
# alternativo indicato dal nodo), a destra l'interlocutore della
# discussione. Se il nodo indica "centro", parla un solo personaggio al
# centro e i due spazi laterali spariscono. Questo riguarda solo i ritratti
# visibili, non il nome sul box (quello segue il messaggio corrente).

const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_COMBATTIMENTO := "res://scenes/Combattimento.tscn"
const EVENTI_DEBUG := "res://data/events.json"

@onready var slot_sinistra = %SlotSinistra
@onready var slot_centro = %SlotCentro
@onready var slot_destra = %SlotDestra
@onready var nome_parlante: Label = %NomeParlante
@onready var narratore: RichTextLabel = %Narratore
@onready var contenitore_scelte: VBoxContainer = %Scelte
@onready var bottone_dialoga: Button = %BottoneDialoga
@onready var menu_compagni: HBoxContainer = %MenuCompagni
@onready var stato: Label = %Stato

var nodo_in_corso: Dictionary = {}
var coda_messaggi: Array[Dictionary] = []

func _ready() -> void:
	if GameState.eventi.is_empty():
		# scena avviata direttamente dall'editor: carica la campagna di prova
		GameState.avvia_carnivalz("debug", EVENTI_DEBUG)
	AudioManager.musica(GameState.musica_ambiente)
	for slot in [slot_sinistra, slot_centro, slot_destra]:
		slot.imposta_grande(true)  # ritratto cinematografico, riempie lo schermo sopra il box
	bottone_dialoga.pressed.connect(_su_dialoga)
	mostra_nodo(GameState.nodo_corrente)

func mostra_nodo(id_nodo: String, notifiche_precedenti: Array[Dictionary] = []) -> void:
	var nodo: Dictionary = GameState.eventi.get(id_nodo, {})
	if nodo.is_empty():
		push_error("Nodo evento mancante: " + id_nodo)
		return
	GameState.nodo_corrente = id_nodo
	if nodo.has("flag"):
		GameState.imposta_flag(nodo["flag"])
	if nodo.has("congeda"):
		GameState.congeda(nodo["congeda"])
	# agguato: ogni volta che si entra nella stanza si tenta la probabilita';
	# se scatta si combatte (e non si ritenta subito tornando qui a vittoria
	# ottenuta); se non scatta, la prossima visita ritenta da capo
	if nodo.has("agguato") and id_nodo not in GameState.stanze_ripulite:
		var agguato: Dictionary = nodo["agguato"]
		if GameState.rng.randf() < float(agguato.get("probabilita", 0.3)):
			var gruppi: Array = agguato.get("gruppi", [])
			if not gruppi.is_empty():
				GameState.stanze_ripulite.append(id_nodo)
				var gruppo: Array = gruppi[GameState.rng.randi_range(0, gruppi.size() - 1)]
				# fuggire da un agguato non ha penalita': si torna semplicemente qui
				GameState.prepara_combattimento(gruppo, id_nodo, "", agguato.get("se_perdi", ""), id_nodo)
				get_tree().change_scene_to_file(SCENA_COMBATTIMENTO)
				return
	aggiorna_palco(nodo)
	aggiorna_stato()
	if nodo.get("espulsione_automatica", false):
		# non c'e' niente da scegliere: il posto stesso ti rigetta fuori
		var seq := sequenza_di(nodo)
		mostra_messaggio(seq[0] if not seq.is_empty() else {"tipo": "narrazione", "testo": ""})
		for figlio in contenitore_scelte.get_children():
			figlio.queue_free()
		aggiorna_dialoga()
		await get_tree().create_timer(1.8).timeout
		GameState.congeda_tutti_temporanei()
		get_tree().change_scene_to_file(SCENA_VUOTO)
		return
	nodo_in_corso = nodo
	coda_messaggi = notifiche_precedenti + sequenza_di(nodo)
	avanza_messaggio()

func sequenza_di(nodo: Dictionary) -> Array[Dictionary]:
	if nodo.has("sequenza"):
		var seq: Array[Dictionary] = []
		for msg in nodo["sequenza"]:
			seq.append(msg)
		return seq
	return [{"tipo": "narrazione", "testo": nodo.get("testo", "")}]

func avanza_messaggio() -> void:
	if not coda_messaggi.is_empty():
		var msg: Dictionary = coda_messaggi.pop_front()
		mostra_messaggio(msg)
		mostra_continua()
		return
	ricostruisci_scelte(nodo_in_corso)
	aggiorna_dialoga()

func mostra_messaggio(msg: Dictionary) -> void:
	match String(msg.get("tipo", "narrazione")):
		"dialogo":
			nome_parlante.visible = true
			aggiorna_nome_parlante(String(msg.get("chi", GameState.id_protagonista)))
			narratore.text = String(msg.get("testo", ""))
		"notifica":
			nome_parlante.visible = false
			narratore.text = "[center][b]%s[/b][/center]" % String(msg.get("testo", ""))
		_:
			nome_parlante.visible = false
			narratore.text = "[i]%s[/i]" % String(msg.get("testo", ""))

func mostra_continua() -> void:
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	var bottone := Button.new()
	bottone.text = "▸ Continua"
	bottone.pressed.connect(avanza_messaggio)
	contenitore_scelte.add_child(bottone)

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
		if scelta.has("richiede_oggetti") and not GameState.possiede_tutti(scelta["richiede_oggetti"]):
			continue  # servono tutti i pezzi (es. la Fontana)
		if scelta.has("una_tantum") and GameState.ha_flag(scelta["una_tantum"]):
			continue  # gia' raccolto/fatto: la scelta non torna
		if int(scelta.get("tazo", 0)) < 0 and GameState.tazo < -int(scelta.get("tazo", 0)):
			continue  # non puoi pagare cio' che non hai
		var bottone := Button.new()
		bottone.text = scelta.get("testo", "…")
		bottone.pressed.connect(_su_scelta.bind(scelta))
		contenitore_scelte.add_child(bottone)

func pickup(id_oggetto: String) -> Array[Dictionary]:
	# notifiche sequenziali: "hai raccolto X" e' un messaggio a se',
	# ordinato insieme agli altri, non un testo mescolato o un elemento minore.
	# Per gli oggetti chiave (di solito indizi/lore, come le pagine di
	# giornale di Meridia) la descrizione diventa una seconda pagina.
	var dati := GameState.dati_oggetto(id_oggetto)
	var nome: String = String(dati.get("nome", id_oggetto))
	if not GameState.aggiungi_oggetto(id_oggetto):
		return [{"tipo": "notifica", "testo": "%s: la sacca è piena, non c'è posto per lui." % nome}]
	var tipo := String(dati.get("tipo", "consumabile"))
	var luogo := "nella sacca"
	match tipo:
		"collezionabile":
			luogo = "tra i collezionabili"
		"chiave":
			luogo = "tra gli oggetti chiave"
	var risultato: Array[Dictionary] = [{"tipo": "notifica", "testo": "Hai raccolto: %s (%s)." % [nome, luogo]}]
	if tipo == "chiave":
		risultato.append({"tipo": "narrazione", "testo": String(dati.get("descrizione", ""))})
	return risultato

func aggiorna_palco(nodo: Dictionary) -> void:
	if nodo.has("centro"):
		slot_sinistra.visible = false
		slot_destra.visible = false
		slot_centro.visible = true
		mostra_slot(slot_centro, nodo["centro"], nodo.get("espr_centro", ""))
		return
	slot_centro.visible = false
	slot_sinistra.visible = true
	mostra_slot(slot_sinistra, nodo.get("sinistra", GameState.id_protagonista), nodo.get("espr_sinistra", ""))
	slot_destra.visible = nodo.has("destra")
	if nodo.has("destra"):
		mostra_slot(slot_destra, nodo["destra"], nodo.get("espr_destra", ""))

func aggiorna_nome_parlante(id_personaggio: String) -> void:
	nome_parlante.text = String(GameState.personaggi.get(id_personaggio, {}).get("nome", id_personaggio))

func mostra_slot(slot, valore: Variant, espr_nodo: String) -> void:
	# valore: id stringa, oppure {id, espr}. L'espressione può anche venire
	# dalla chiave espr_<lato> del nodo.
	var id_personaggio := ""
	var espressione := "neutra"
	if valore is Dictionary:
		id_personaggio = String(valore.get("id", ""))
		espressione = String(valore.get("espr", "neutra"))
	else:
		id_personaggio = String(valore)
	if espr_nodo != "":
		espressione = espr_nodo
	slot.mostra(id_personaggio, 0, espressione)

func _su_scelta(scelta: Dictionary) -> void:
	GameState.modifica_legame(-1)  # il legame respira: cala se non lo curi
	if scelta.has("flag"):
		GameState.imposta_flag(scelta["flag"])
	if scelta.has("una_tantum"):
		GameState.imposta_flag(scelta["una_tantum"])
	if scelta.has("recluta"):
		GameState.recluta(scelta["recluta"])
	var notifiche: Array[Dictionary] = []
	if scelta.has("oggetto"):
		notifiche.append_array(pickup(scelta["oggetto"]))
	if scelta.has("lascia"):
		GameState.rimuovi_classe(scelta["lascia"])
	if scelta.has("ospite"):
		GameState.aggiungi_ospite(scelta["ospite"])
	if scelta.has("recluta_temporaneo"):
		GameState.recluta_temporaneo(scelta["recluta_temporaneo"], int(scelta.get("livello_alleato", 1)))
	if scelta.has("congeda"):
		GameState.congeda(scelta["congeda"])
	if scelta.has("tazo"):
		var quantita := int(scelta["tazo"])
		GameState.modifica_tazo(quantita)
		if quantita > 0:
			notifiche.append({"tipo": "notifica", "testo": "Hai ottenuto %d Tazo." % quantita})
	if scelta.has("sblocca_negozio"):
		GameState.sblocca_negozio(scelta["sblocca_negozio"])
	if scelta.has("stress"):
		for id_classe in GameState.party:
			GameState.modifica_stress(id_classe, int(scelta["stress"]))
	if scelta.has("legame"):
		GameState.modifica_legame(int(scelta["legame"]))
	if scelta.has("combatti"):
		GameState.prepara_combattimento(scelta["combatti"], scelta.get("se_vinci", ""),
				scelta.get("se_vinci_eroe", ""), scelta.get("se_perdi", ""), scelta.get("se_fuggi", ""))
		get_tree().change_scene_to_file(SCENA_COMBATTIMENTO)
		return
	if scelta.get("torna_vuoto", false):
		# uscita da uno squarcio: lo stato resta, ma gli alleati temporanei
		# non ti seguono fuori
		GameState.congeda_tutti_temporanei()
		get_tree().change_scene_to_file(SCENA_VUOTO)
		return
	if scelta.get("reset", false):
		GameState.reset_campagna()
		get_tree().change_scene_to_file(SCENA_MAPPA)
		return
	if scelta.has("vai"):
		mostra_nodo(scelta["vai"], notifiche)
	elif not notifiche.is_empty():
		# si resta sullo stesso nodo: si mostrano solo le notifiche in coda
		coda_messaggi = notifiche
		avanza_messaggio()

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
	slot_sinistra.visible = false
	slot_destra.visible = false
	slot_centro.visible = true
	mostra_slot(slot_centro, id_classe, "")
	var nome: String = String(GameState.classi.get(id_classe, {}).get("nome", id_classe))
	var voce: Dictionary = GameState.dialoghi.get(GameState.nodo_corrente, {})
	var gia_detta: bool = voce.has("una_tantum") and GameState.ha_flag(voce["una_tantum"])
	if voce.is_empty() or gia_detta:
		coda_messaggi = [{"tipo": "narrazione", "testo": "%s non ha altro da dirti, qui." % nome}]
	else:
		# le narrazioni sono scritte in terza persona col nome del compagno da
		# sostituire nel "%s"; i "dialogo" senza "chi" sono la battuta del
		# compagno con cui stai parlando in quel momento (dinamico, non fisso)
		coda_messaggi = []
		for msg in sequenza_di(voce):
			var testo_msg := String(msg.get("testo", ""))
			if String(msg.get("tipo", "narrazione")) == "dialogo":
				coda_messaggi.append({"tipo": "dialogo", "chi": msg.get("chi", id_classe), "testo": testo_msg})
			else:
				coda_messaggi.append({"tipo": "narrazione", "testo": testo_msg % nome if testo_msg.find("%s") != -1 else testo_msg})
		if voce.has("flag"):
			GameState.imposta_flag(voce["flag"])
		if voce.has("una_tantum"):
			GameState.imposta_flag(voce["una_tantum"])
	avanza_messaggio()
	# la battuta puo' aver sbloccato una scelta gated da richiede_flag: la
	# prossima volta che la coda si svuota, ricostruisci_scelte() la rilegge

func aggiorna_stato() -> void:
	var nomi: Array[String] = []
	for id_classe in GameState.party:
		nomi.append(String(GameState.classi.get(id_classe, {}).get("nome", id_classe)))
	var testo_party := ", ".join(nomi) if not nomi.is_empty() else "solo tu"
	stato.text = "Party: %s   •   Sacca %d/%d   •   Tazo %d   •   Legame %d" % [
		testo_party, GameState.sacca.size(), int(GameState.regole.get("sacca_massima", 20)),
		GameState.tazo, GameState.legame,
	]
