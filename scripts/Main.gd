extends Control

# Motore eventi: mostra il nodo corrente, filtra le scelte per requisiti
# e applica gli effetti (recluta / oggetto / lascia / reset). I contenuti
# vivono solo nei JSON.
#
# Il box in basso mostra UN messaggio alla volta, in coda (coda_messaggi),
# avanzata cliccando "Continua"; solo a coda vuota compaiono le scelte vere.
# Quattro tipi di messaggio:
#   - "narrazione": la voce narrante che descrive la scena in seconda persona
#     ("ti nota", "il tuo compito"), sempre in corsivo, senza nome — non è
#     Anonimo che parla, è chi racconta la sua storia dall'esterno
#   - "dialogo": un personaggio parla (incluso Anonimo, in prima persona: le
#     sue battute/pensieri sono "dialogo" con chi="anonimo"), il suo nome
#     compare centrato sul box
#   - "notifica": oggetti/Tazo raccolti, centrato, una voce alla volta
#   - "titolo": rivela il nome di un luogo (es. "Pianure di Redenna"), grande
#     e centrato, senza nome
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
const SCENA_MAPPA_ZONA := "res://scenes/MappaZona.tscn"
const SCENA_EVENTI := "res://scenes/Main.tscn"
const EVENTI_DEBUG := "res://data/events.json"

@onready var slot_sinistra = %SlotSinistra
@onready var slot_centro = %SlotCentro
@onready var slot_destra = %SlotDestra
@onready var nome_parlante: Label = %NomeParlante
@onready var narratore: RichTextLabel = %Narratore
@onready var contenitore_scelte: VBoxContainer = %Scelte
@onready var bottone_dialoga: Button = %BottoneDialoga
@onready var bottone_mappa: Button = %BottoneMappa
@onready var menu_compagni: HBoxContainer = %MenuCompagni
@onready var stato: Label = %Stato

var nodo_in_corso: Dictionary = {}
var coda_messaggi: Array[Dictionary] = []
var azione_dopo_coda: Callable = Callable()  # eseguita a coda vuota al posto delle scelte normali (es. mediazione)

func _ready() -> void:
	if GameState.eventi.is_empty():
		# scena avviata direttamente dall'editor: carica la campagna di prova
		GameState.avvia_carnivalz("debug", EVENTI_DEBUG)
	AudioManager.musica(GameState.musica_ambiente)
	for slot in [slot_sinistra, slot_centro, slot_destra]:
		slot.imposta_grande(true)  # ritratto cinematografico, riempie lo schermo sopra il box
	bottone_dialoga.pressed.connect(_su_dialoga)
	bottone_mappa.visible = GameState.stanza_nella_mappa(GameState.nodo_corrente)
	bottone_mappa.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(SCENA_MAPPA_ZONA))
	mostra_nodo(GameState.nodo_corrente)

func mostra_nodo(id_nodo: String, notifiche_precedenti: Array[Dictionary] = []) -> void:
	var nodo: Dictionary = GameState.eventi.get(id_nodo, {})
	if nodo.is_empty():
		push_error("Nodo evento mancante: " + id_nodo)
		return
	if nodo.has("vai_se_flag") and GameState.ha_flag(String(nodo["vai_se_flag"].get("flag", ""))):
		# stessa stanza, seconda visita: si mostra un altro nodo al suo posto
		# (es. un luogo dove il primo incontro e' gia' avvenuto)
		mostra_nodo(String(nodo["vai_se_flag"].get("vai", "")), notifiche_precedenti)
		return
	GameState.nodo_corrente = id_nodo
	if id_nodo not in GameState.nodi_visitati:
		# esplorare allena la velocita': ogni stanza conta una volta sola
		GameState.nodi_visitati.append(id_nodo)
		GameState.registra_azione("stanze_esplorate")
	if nodo.has("flag"):
		GameState.imposta_flag(nodo["flag"])
	if nodo.has("sblocca_stanze"):
		# mappa dungeon di zona: visitare questo nodo sblocca altre stanze
		for id_stanza in nodo["sblocca_stanze"]:
			GameState.sblocca_stanza(String(id_stanza))
	if nodo.has("congeda"):
		GameState.congeda(nodo["congeda"])
	if nodo.get("salva_checkpoint", false):
		# eccezione deliberata alla regola "si salva solo dalla mappa stellare":
		# protegge Tazo/oggetti/flag raccolti finora in un dungeon lungo. NON
		# fa riprendere la partita da qui: _leggi_salvataggio() riporta sempre
		# a uno stato overworld pulito, quindi un game_over dopo questo punto
		# torna comunque alla mappa stellare (progresso di posizione perso,
		# ma non il bottino raccolto prima del checkpoint)
		GameState.salva()
	# agguato: ogni volta che si entra nella stanza si tenta la probabilita';
	# se scatta si combatte (e non si ritenta subito tornando qui a vittoria
	# ottenuta); se non scatta, la prossima visita ritenta da capo. Una zona
	# "ripulita" (salta_se_flag) non tenta piu' nessun agguato. Un agguato
	# "ripetibile" non si esaurisce mai: la stanza continua a generare scontri
	# a ogni ingresso, anche dopo averne vinto uno (farm zone)
	if nodo.has("agguato") and id_nodo not in GameState.stanze_ripulite \
			and not (nodo["agguato"].has("salta_se_flag") and GameState.ha_flag(String(nodo["agguato"]["salta_se_flag"]))):
		var agguato: Dictionary = nodo["agguato"]
		if GameState.rng.randf() < float(agguato.get("probabilita", 0.3)):
			var gruppi: Array = agguato.get("gruppi", [])
			if not gruppi.is_empty():
				if not agguato.get("ripetibile", false):
					GameState.stanze_ripulite.append(id_nodo)
				var gruppo: Array = gruppi[GameState.rng.randi_range(0, gruppi.size() - 1)]
				# fuggire da un agguato non ha penalita': si torna semplicemente qui
				GameState.prepara_combattimento(gruppo, id_nodo, "", agguato.get("se_perdi", ""), id_nodo)
				get_tree().change_scene_to_file(SCENA_COMBATTIMENTO)
				return
	# nessun agguato e' scattato: qui si respira, e il party recupera tutto.
	# Finche' gli scontri si incatenano (ondate), invece, gli hp restano quelli
	# lasciati dallo scontro precedente. Un nodo puo' chiedere esplicitamente di
	# non far recuperare ("mantieni_hp"): serve alle fasi di uno stesso scontro,
	# dove in mezzo c'e' solo una scena e non una vera pausa
	if not nodo.get("mantieni_hp", false):
		GameState.hp_persistenti.clear()
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
	coda_messaggi = notifiche_precedenti + notifiche_passive() + sequenza_di(nodo)
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
		# durante la lettura dei messaggi i bottoni "Parla con la squadra" e
		# "Mappa" restano nascosti: appaiono solo a coda vuota, mai a meta' di
		# una sequenza
		bottone_dialoga.visible = false
		bottone_mappa.visible = false
		for figlio in menu_compagni.get_children():
			figlio.queue_free()
		if coda_messaggi.is_empty() and not azione_dopo_coda.is_valid() \
				and not nodo_in_corso.has("combattimento_automatico") and not nodo_in_corso.has("avvio_automatico"):
			# ultimo messaggio e nessuna transizione in sospeso: le scelte vere
			# compaiono subito sotto lo stesso testo, senza un "Continua" a vuoto
			aggiorna_palco(nodo_in_corso)
			ricostruisci_scelte(nodo_in_corso)
			aggiorna_dialoga()
		else:
			mostra_continua()
		return
	if azione_dopo_coda.is_valid():
		var richiamo := azione_dopo_coda
		azione_dopo_coda = Callable()
		richiamo.call()
		return
	if nodo_in_corso.has("combattimento_automatico"):
		# non c'e' nulla da scegliere: il combattimento parte da solo a fine sequenza
		avvia_combattimento_automatico(nodo_in_corso["combattimento_automatico"])
		return
	if nodo_in_corso.has("avvio_automatico"):
		# fine di un mini-evento (es. l'introduzione): parte in automatico una
		# nuova campagna, senza che il giocatore debba scegliere nulla
		avvia_automatico(nodo_in_corso["avvio_automatico"])
		return
	aggiorna_palco(nodo_in_corso)
	ricostruisci_scelte(nodo_in_corso)
	aggiorna_dialoga()

func avvia_combattimento_automatico(dati: Dictionary) -> void:
	if dati.has("salta_se_flag") and GameState.ha_flag(String(dati["salta_se_flag"])):
		# zona gia' ripulita (boss sconfitto): non ci sono piu' nemici qui
		mostra_nodo(String(dati.get("se_vinci", "")))
		return
	GameState.prepara_combattimento(dati.get("nemici", []), dati.get("se_vinci", ""),
			dati.get("se_vinci_eroe", ""), dati.get("se_perdi", ""), dati.get("se_fuggi", ""))
	get_tree().change_scene_to_file(SCENA_COMBATTIMENTO)

func avvia_automatico(dati: Dictionary) -> void:
	GameState.avvia_carnivalz(String(dati.get("id_punto", "")), String(dati.get("file_eventi", "")))
	mostra_nodo(GameState.nodo_corrente)

func mostra_messaggio(msg: Dictionary) -> void:
	match String(msg.get("tipo", "narrazione")):
		"dialogo":
			nome_parlante.visible = true
			var chi := String(msg.get("chi", GameState.id_protagonista))
			aggiorna_nome_parlante(chi)
			narratore.text = sostituisci_nome(String(msg.get("testo", "")))
			if msg.has("espr"):
				aggiorna_espressione_centro(chi, String(msg["espr"]))
		"notifica":
			nome_parlante.visible = false
			narratore.text = "[center][b]%s[/b][/center]" % sostituisci_nome(String(msg.get("testo", "")))
		"titolo":
			# rivela il nome di un luogo: grande e centrato, non e' narrazione
			# di scena ne' una battuta di qualcuno
			nome_parlante.visible = false
			narratore.text = "[center][b][font_size=36]%s[/font_size][/b][/center]" % sostituisci_nome(String(msg.get("testo", "")))
		_:
			nome_parlante.visible = false
			narratore.text = "[i]%s[/i]" % sostituisci_nome(String(msg.get("testo", "")))

func sostituisci_nome(testo: String) -> String:
	# permette a narrazione/dialogo di citare il nome scelto dal giocatore
	# per il protagonista, es. "Benvenuto, {nome}." (distinto dal "%s" di
	# dialoghi.json, gia' risolto altrove per i nomi dei compagni)
	if testo.find("{nome}") == -1:
		return testo
	var nome := String(GameState.personaggi.get(GameState.id_protagonista, {}).get("nome", "Anonimo"))
	return testo.replace("{nome}", nome)

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
		if scelta.has("richiede_compagno") and scelta["richiede_compagno"] not in GameState.party:
			continue  # serve un alleato specifico in squadra (es. un compagno temporaneo reclutato)
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

func notifiche_passive() -> Array[Dictionary]:
	# abilita' passive sbloccate salendo di livello: si annunciano appena si
	# torna a una schermata di eventi, insieme alle altre notifiche
	var righe: Array[Dictionary] = []
	for nome in GameState.passive_da_notificare:
		righe.append({"tipo": "notifica", "testo": "Nuova abilità passiva: %s" % nome})
	GameState.passive_da_notificare.clear()
	return righe

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

func aggiorna_espressione_centro(id_personaggio: String, espressione: String) -> void:
	# una scena "centro" (un solo personaggio a schermo) puo' cambiare la sua
	# espressione a meta' sequenza: es. il giocoliere che perde il sorriso
	# un attimo prima del combattimento
	var centro: Variant = nodo_in_corso.get("centro")
	var id_centro := String(centro.get("id", "")) if centro is Dictionary else String(centro)
	if slot_centro.visible and id_centro == id_personaggio:
		mostra_slot(slot_centro, id_personaggio, espressione)

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
	if scelta.get("game_over", false):
		# si perde il progresso non salvato, ma non si viene sbalzati sulla
		# mappa stellare: si ricomincia il livello dal suo punto di partenza
		if GameState.game_over():
			get_tree().change_scene_to_file(SCENA_EVENTI)
		else:
			get_tree().change_scene_to_file(SCENA_MAPPA)
		return
	if scelta.get("torna_a_mappa", false):
		# mappa dungeon di zona: si torna li' a scegliere la prossima stanza,
		# invece di proseguire dritti verso un altro nodo
		get_tree().change_scene_to_file(SCENA_MAPPA_ZONA)
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
	# "Mappa" compare solo dentro la sezione esplorabile della zona
	bottone_mappa.visible = GameState.stanza_nella_mappa(GameState.nodo_corrente)
	for figlio in menu_compagni.get_children():
		figlio.queue_free()

func _su_dialoga() -> void:
	for figlio in menu_compagni.get_children():
		figlio.queue_free()
	# se due compagni presenti stanno discutendo tra loro in questo punto,
	# l'opzione per assistere (e mediare) compare prima delle chiacchiere singole
	var conversazione: Dictionary = GameState.conversazioni.get(GameState.nodo_corrente, {})
	var tra: Array = conversazione.get("tra", [])
	var conv_gia_vista: bool = conversazione.has("una_tantum") and GameState.ha_flag(conversazione["una_tantum"])
	if not conversazione.is_empty() and not conv_gia_vista and tra.size() == 2 \
			and tra[0] in GameState.party and tra[1] in GameState.party:
		var nome_a: String = String(GameState.classi.get(tra[0], {}).get("nome", tra[0]))
		var nome_b: String = String(GameState.classi.get(tra[1], {}).get("nome", tra[1]))
		var bottone_conv := Button.new()
		bottone_conv.text = "%s e %s stanno parlando..." % [nome_a, nome_b]
		bottone_conv.pressed.connect(_su_conversazione.bind(conversazione))
		menu_compagni.add_child(bottone_conv)
	for id_classe in GameState.party:
		if id_classe == GameState.id_protagonista:
			continue
		var bottone := Button.new()
		bottone.text = String(GameState.classi.get(id_classe, {}).get("nome", id_classe))
		bottone.pressed.connect(_su_compagno.bind(id_classe))
		menu_compagni.add_child(bottone)

func _su_conversazione(conversazione: Dictionary) -> void:
	for figlio in menu_compagni.get_children():
		figlio.queue_free()
	var tra: Array = conversazione.get("tra", [])
	slot_centro.visible = false
	slot_sinistra.visible = true
	slot_destra.visible = true
	mostra_slot(slot_sinistra, tra[0], "")
	mostra_slot(slot_destra, tra[1], "")
	if conversazione.has("flag"):
		GameState.imposta_flag(conversazione["flag"])
	if conversazione.has("una_tantum"):
		GameState.imposta_flag(conversazione["una_tantum"])
	coda_messaggi = sequenza_di(conversazione)
	azione_dopo_coda = _mostra_mediazione.bind(conversazione) if conversazione.has("mediazione") else Callable()
	avanza_messaggio()

func _mostra_mediazione(conversazione: Dictionary) -> void:
	# il giocatore puo' intervenire nella discussione: alcune opzioni sono
	# sbloccate solo se ha in sacca l'oggetto giusto per dare peso alle sue parole
	var mediazione: Dictionary = conversazione.get("mediazione", {})
	nome_parlante.visible = false
	narratore.text = "[i]%s[/i]" % String(mediazione.get("testo", "Puoi intervenire."))
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	for opzione in mediazione.get("opzioni", []):
		if opzione.has("richiede_oggetto") and not GameState.possiede_oggetto(opzione["richiede_oggetto"]):
			continue
		var bottone := Button.new()
		bottone.text = String(opzione.get("testo", "…"))
		bottone.pressed.connect(_su_mediazione.bind(opzione))
		contenitore_scelte.add_child(bottone)

func _su_mediazione(opzione: Dictionary) -> void:
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	if opzione.has("legame"):
		GameState.modifica_legame(int(opzione["legame"]))
	coda_messaggi = []
	if opzione.has("battuta"):
		# cio' che dice Anonimo e' una battuta vera, non l'etichetta del bottone:
		# compare come pagina di dialogo a se', mai nascosta dentro la scelta
		coda_messaggi.append({"tipo": "dialogo", "chi": GameState.id_protagonista, "testo": String(opzione["battuta"])})
	if opzione.has("risposta"):
		var risposta: Dictionary = opzione["risposta"]
		coda_messaggi.append({"tipo": "dialogo", "chi": String(risposta.get("chi", "")), "testo": String(risposta.get("testo", ""))})
	avanza_messaggio()

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
	stato.text = "Party: %s   •   Sacca %d/%d   •   Tazo %d   •   Legame %d\nLv %d   •   HP %d   ATT %d   DIF %d   VEL %d   INT %d   MEN %d   FAT %d" % [
		testo_party, GameState.sacca.size(), int(GameState.regole.get("sacca_massima", 20)),
		GameState.tazo, GameState.legame,
		GameState.livello_di(GameState.id_protagonista),
		GameState.stat_di("hp"), GameState.stat_di("attacco"), GameState.stat_di("difesa"),
		GameState.stat_di("velocita"), GameState.stat_di("intelligenza"),
		GameState.stat_di("forza_mentale"), GameState.stat_di("fattore"),
	]
