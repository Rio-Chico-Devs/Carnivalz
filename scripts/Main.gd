extends Control

# Motore eventi: mostra il nodo corrente, filtra le scelte per requisiti
# e applica gli effetti (recluta / oggetto / lascia / reset). I contenuti
# vivono solo nei JSON.
#
# --- come si legge questa schermata ---
# Il box in basso (scenes/BoxTesto.tscn) mostra UN messaggio alla volta, preso
# da una coda (coda_messaggi). Il testo si scrive a macchina: un click lo
# completa, il successivo passa avanti. Non c'e' piu' un bottone "Continua"
# in mezzo alle scelte: si clicca dove si vuole (AreaAvanza copre lo schermo
# mentre si legge) oppure si preme Invio/Spazio. Le scelte vere compaiono solo
# quando la coda e' finita E il testo ha finito di scriversi: cosi' non si
# clicca mai per sbaglio su un'opzione mentre si sta ancora leggendo.
#
# Quattro tipi di messaggio, quattro trattamenti diversi (le regole grafiche
# stanno in BoxTesto.gd, non qui):
#   - "narrazione": la voce narrante che descrive la scena in seconda persona
#     ("ti nota", "il tuo compito"), in corsivo e senza nome — non è Anonimo
#     che parla, è chi racconta la storia dall'esterno
#   - "dialogo": un personaggio parla (incluso Anonimo, in prima persona), col
#     suo nome nella targhetta del box
#   - "notifica": oggetti/Tazo/passive, centrato e color accento: è il gioco
#     che ti informa, non la storia
#   - "titolo": il nome di un luogo — non entra nel box, prende tutto lo
#     schermo come una carta da film e poi si scioglie
# Un nodo può avere "sequenza" (lista di messaggi) oppure, in alternativa,
# il vecchio campo "testo" (diventa un'unica narrazione, per compatibilità
# con i contenuti non ancora convertiti).
#
# Schermata a tre fasce che non si muovono mai: barra di stato in alto, in
# mezzo il palco dei ritratti con a destra la colonna delle scelte (larghezza
# sempre riservata, anche vuota), e il box del testo inchiodato in basso a
# un'altezza fissa. Niente di quello che compare o sparisce - triangolino,
# scelte, bottoni - puo' far muovere il resto: era la cosa piu' fastidiosa
# della vecchia disposizione, dove ogni click faceva ballare mezza schermata.
#
# Palco dei ritratti sopra il box: a sinistra il protagonista (o un
# alternativo indicato dal nodo), a destra l'interlocutore. Se il nodo indica
# "centro", parla un solo personaggio al centro e i due spazi laterali
# spariscono. Chi non ha la battuta in quel momento resta in scena ma
# attenuato: l'occhio va da solo su chi sta parlando.

const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_COMBATTIMENTO := "res://scenes/Combattimento.tscn"
const SCENA_MAPPA_ZONA := "res://scenes/MappaZona.tscn"
const SCENA_EVENTI := "res://scenes/Main.tscn"
const EVENTI_DEBUG := "res://data/events.json"
const APPUNTI_LETTI_A_VOCE := 2  # quanti appunti nuovi il protagonista pensa a voce prima di rimandare al Diario

@onready var sfondo: ColorRect = %Sfondo
@onready var slot_sinistra = %SlotSinistra
@onready var slot_centro = %SlotCentro
@onready var slot_destra = %SlotDestra
@onready var box = %BoxTesto
@onready var contenitore_scelte: VBoxContainer = %Scelte
@onready var bottone_dialoga: Button = %BottoneDialoga
@onready var bottone_mappa: Button = %BottoneMappa
@onready var menu_compagni: VBoxContainer = %MenuCompagni
@onready var colonna_azioni: VBoxContainer = %ColonnaAzioni
@onready var etichetta_party: Label = %Party
@onready var etichetta_risorse: Label = %Risorse
@onready var etichetta_stat: Label = %BarraStat
@onready var carta_titolo: Control = %CartaTitolo
@onready var colonna_titolo: VBoxContainer = %ColonnaTitolo
@onready var testo_titolo: Label = %TestoTitolo
@onready var area_avanza: Button = %AreaAvanza

var nodo_in_corso: Dictionary = {}
var coda_messaggi: Array[Dictionary] = []
# un messaggio con "attesa" non aspetta il click: finito di scriversi si conta
# il tempo indicato e si passa avanti da soli (il conto alla rovescia del
# lancio, un silenzio che deve pesare). Il contatore serve a non avanzare due
# volte se nel frattempo il giocatore clicca lo stesso.
var attesa_messaggio := 0.0
var contatore_messaggi := 0
var azione_dopo_coda: Callable = Callable()     # eseguita a coda vuota al posto delle scelte normali (es. mediazione)
var azione_a_fine_testo: Callable = Callable()  # eseguita appena il box ha finito di scrivere
var mostrando_scena := false  # true quando il nodo sta mostrando la sua descrizione di ritorno
var azione_dopo_titolo: Callable = Callable()  # ripresa in sospeso mentre la carta del titolo e' a schermo

func _ready() -> void:
	if GameState.eventi.is_empty():
		# scena avviata direttamente dall'editor: carica la campagna di prova
		GameState.avvia_carnivalz("debug", EVENTI_DEBUG)
	AudioManager.musica(GameState.musica_ambiente)
	applica_stile()
	for slot in [slot_sinistra, slot_centro, slot_destra]:
		slot.imposta_grande(true)  # ritratto cinematografico, riempie lo schermo sopra il box
	box.scrittura_finita.connect(_su_testo_pronto)
	area_avanza.focus_mode = Control.FOCUS_NONE
	area_avanza.pressed.connect(_su_avanza)
	bottone_dialoga.pressed.connect(_su_dialoga)
	bottone_mappa.visible = GameState.stanza_nella_mappa(GameState.nodo_corrente)
	bottone_mappa.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_MAPPA_ZONA))
	mostra_nodo(GameState.nodo_corrente)
	sorveglia_schermata_vuota()

func applica_stile() -> void:
	sfondo.color = Stile.colore("sfondo")
	# la colonna delle scelte tiene sempre la sua larghezza, anche quando e'
	# vuota: se comparisse solo al momento del bisogno, i ritratti si
	# restringerebbero di colpo a ogni fine testo
	colonna_azioni.custom_minimum_size = Vector2(Stile.forma("larghezza_scelte"), 0)
	Stile.etichetta_piccola(etichetta_party)
	Stile.etichetta_piccola(etichetta_risorse)
	etichetta_stat.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	etichetta_stat.add_theme_color_override("font_color", Stile.colore("bordo"))
	testo_titolo.add_theme_font_size_override("font_size", Stile.dimensione("titolo"))
	testo_titolo.add_theme_color_override("font_color", Stile.colore("accento"))
	var suggerimento_titolo := Stile.costruisci_prompt("continua")
	colonna_titolo.add_child(suggerimento_titolo)
	Stile.pulsa(suggerimento_titolo)

func _unhandled_input(evento: InputEvent) -> void:
	# la tastiera fa esattamente quello che fa il mouse: avanza
	if area_avanza.visible and evento.is_action_pressed("ui_accept"):
		_su_avanza()
		get_viewport().set_input_as_handled()

func sorveglia_schermata_vuota() -> void:
	# LA RETE SOTTO IL TRAPEZIO. mostra_nodo() esce senza disegnare niente
	# quando sta per cambiare schermata - un agguato, un'espulsione. E' giusto:
	# non ha senso costruire testo e bottoni per una schermata che sparira' tra
	# un istante. Ma se per qualsiasi ragione quel cambio non avviene, resta li'
	# una scena viva e VUOTA: niente testo, nessuna uscita, solo il bottone
	# "Parla con la squadra". Da li' non si esce piu'.
	#
	# E' successo due volte, per due motivi diversi. Il secondo l'ho chiuso, ma
	# la FORMA del codice permette che ne esista un terzo: finche' una funzione
	# sola sia disegna sia decide di andarsene, quello stato intermedio esiste.
	#
	# Quindi: due frame dopo, se siamo ancora qui e non abbiamo disegnato
	# niente, si disegna. Meglio una stanza mostrata di troppo che una partita
	# persa. E se scatta e' un bug: resta scritto nel registro.
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_inside_tree() or not nodo_in_corso.is_empty():
		return
	if Transizioni.in_corso or Transizioni.prossima != "":
		return   # sta davvero cambiando schermata: e' tutto a posto
	push_error("Schermata vuota evitata sul nodo '%s': mostra_nodo() e' uscito senza disegnare e senza partire"
			% GameState.nodo_corrente)
	mostra_nodo(GameState.nodo_corrente)

func mostra_nodo(id_nodo: String, notifiche_precedenti: Array[Dictionary] = []) -> void:
	var nodo: Dictionary = GameState.eventi.get(id_nodo, {})
	if nodo.is_empty():
		# Un nodo che non esiste era un vicolo cieco definitivo: si usciva da qui
		# senza aver mostrato niente e senza aver costruito nessuna scelta, e il
		# giocatore restava davanti a una schermata vuota da cui non si esce.
		# Meglio perdere la posizione che perdere la partita: si torna indietro
		# di una schermata. Le prove non lasciano passare un id sbagliato, ma
		# nessuna schermata deve poter diventare una prigione.
		push_error("Nodo evento mancante: " + id_nodo)
		Transizioni.vai(SCENA_VUOTO if GameState.carnivalz_corrente != "" else SCENA_MAPPA)
		return
	if nodo.has("vai_se_flag") and GameState.ha_flag(String(nodo["vai_se_flag"].get("flag", ""))):
		# stessa stanza, seconda visita: si mostra un altro nodo al suo posto
		# (es. un luogo dove il primo incontro e' gia' avvenuto)
		mostra_nodo(String(nodo["vai_se_flag"].get("vai", "")), notifiche_precedenti)
		return
	GameState.nodo_corrente = id_nodo
	var prima_visita: bool = id_nodo not in GameState.nodi_visitati
	if prima_visita:
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
	applica_task(nodo)
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
				Transizioni.vai(SCENA_COMBATTIMENTO)
				return
	# nessun agguato e' scattato: qui si respira, e il party recupera tutto.
	# Finche' gli scontri si incatenano (ondate), invece, gli hp restano quelli
	# lasciati dallo scontro precedente. Un nodo puo' chiedere esplicitamente di
	# non far recuperare ("mantieni_hp"): serve alle fasi di uno stesso scontro,
	# dove in mezzo c'e' solo una scena e non una vera pausa
	if not nodo.get("mantieni_hp", false):
		GameState.hp_persistenti.clear()
	nodo_in_corso = nodo
	aggiorna_palco(nodo)
	aggiorna_stato()
	# i dialoghi di un posto si sentono una volta sola: da li' in avanti il
	# nodo mostra la sua "scena", cioe' com'e' quel posto adesso
	mostrando_scena = not prima_visita and nodo.has("scena")
	if nodo.get("espulsione_automatica", false):
		# non c'e' niente da scegliere: il posto stesso ti rigetta fuori
		var seq := contenuto_nodo(nodo)
		azione_a_fine_testo = Callable()
		nascondi_comandi()
		mostra_messaggio(seq[0] if not seq.is_empty() else {"tipo": "narrazione", "testo": ""})
		area_avanza.visible = false
		await get_tree().create_timer(2.2, false).timeout  # false = rispetta la pausa
		GameState.congeda_tutti_temporanei()
		Transizioni.vai(SCENA_VUOTO)
		return
	# gli appunti chiudono la coda, non la aprono: prima si vive la scena che
	# li ha fatti nascere, poi il protagonista ci ragiona sopra
	coda_messaggi = notifiche_precedenti + notifiche_passive() + contenuto_nodo(nodo) + notifiche_task()
	avanza_messaggio()

func contenuto_nodo(nodo: Dictionary) -> Array[Dictionary]:
	# prima visita: la scena si gioca per intero (dialoghi compresi). Dalla
	# seconda in poi resta solo la descrizione del posto, cosi' tornare
	# indietro non ti rifa' sentire le stesse battute
	return messaggi_scena(nodo) if mostrando_scena else sequenza_di(nodo)

func messaggi_scena(nodo: Dictionary) -> Array[Dictionary]:
	# "scena" puo' essere una stringa (una narrazione sola) o una sequenza
	var risultato: Array[Dictionary] = []
	var scena: Variant = nodo.get("scena", "")
	if scena is Array:
		for msg in scena:
			risultato.append(msg)
	else:
		risultato.append({"tipo": "narrazione", "testo": String(scena)})
	return risultato

func sequenza_di(nodo: Dictionary) -> Array[Dictionary]:
	if nodo.has("sequenza"):
		var seq: Array[Dictionary] = []
		for msg in nodo["sequenza"]:
			seq.append(msg)
		return seq
	return [{"tipo": "narrazione", "testo": nodo.get("testo", "")}]

# --- coda dei messaggi ---

func avanza_messaggio() -> void:
	contatore_messaggi += 1
	if not coda_messaggi.is_empty():
		var msg: Dictionary = coda_messaggi.pop_front()
		attesa_messaggio = float(msg.get("attesa", 0.0))
		nascondi_comandi()
		# se questo e' l'ultimo messaggio e non c'e' nessuna transizione in
		# sospeso, appena finisce di scriversi compaiono le scelte vere
		var ultimo: bool = coda_messaggi.is_empty() and not azione_dopo_coda.is_valid() \
				and not nodo_in_corso.has("combattimento_automatico") \
				and not nodo_in_corso.has("avvio_automatico")
		azione_a_fine_testo = _apri_scelte if ultimo else Callable()
		mostra_messaggio(msg)
		area_avanza.visible = true
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
	_apri_scelte()

func _su_avanza() -> void:
	# primo click: il testo si completa subito. Secondo click: si va avanti.
	if box.sta_scrivendo:
		box.completa()
		return
	if carta_titolo.visible:
		chiudi_carta_titolo()
		return
	avanza_messaggio()

func _su_testo_pronto() -> void:
	if attesa_messaggio > 0.0:
		# si va avanti da soli: quello che sarebbe successo a fine testo lo fa
		# comunque avanza_messaggio() quando la coda si svuota
		var quanto := attesa_messaggio
		attesa_messaggio = 0.0
		azione_a_fine_testo = Callable()
		_avanza_fra(quanto, contatore_messaggi)
		return
	if azione_a_fine_testo.is_valid():
		var richiamo := azione_a_fine_testo
		azione_a_fine_testo = Callable()
		richiamo.call()

func _avanza_fra(secondi: float, atteso: int) -> void:
	# false = il timer rispetta la pausa: aprendo ESC il conto si ferma
	await get_tree().create_timer(secondi, false).timeout
	if not is_inside_tree():
		return
	if contatore_messaggi != atteso:
		return  # il giocatore ha cliccato prima: e' gia' andato avanti da solo
	avanza_messaggio()

func _apri_scelte() -> void:
	box.nascondi_indicatore()
	area_avanza.visible = false
	aggiorna_palco(nodo_in_corso)
	ricostruisci_scelte(nodo_in_corso)
	aggiorna_dialoga()

func nascondi_comandi() -> void:
	# mentre si legge non c'e' niente da premere: i comandi tornano a coda vuota
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	bottone_dialoga.visible = false
	bottone_mappa.visible = false
	for figlio in menu_compagni.get_children():
		figlio.queue_free()

func avvia_combattimento_automatico(dati: Dictionary) -> void:
	if dati.has("salta_se_flag") and GameState.ha_flag(String(dati["salta_se_flag"])):
		# zona gia' ripulita (boss sconfitto): non ci sono piu' nemici qui
		mostra_nodo(String(dati.get("se_vinci", "")))
		return
	GameState.prepara_combattimento(dati.get("nemici", []), dati.get("se_vinci", ""),
			dati.get("se_vinci_eroe", ""), dati.get("se_perdi", ""), dati.get("se_fuggi", ""))
	Transizioni.vai(SCENA_COMBATTIMENTO)

func avvia_automatico(dati: Dictionary) -> void:
	GameState.avvia_carnivalz(String(dati.get("id_punto", "")), String(dati.get("file_eventi", "")))
	mostra_nodo(GameState.nodo_corrente)

# --- messaggi a schermo ---

func mostra_messaggio(msg: Dictionary) -> void:
	var tipo := String(msg.get("tipo", "narrazione"))
	var contenuto := sostituisci_nome(String(msg.get("testo", "")))
	if tipo == "titolo":
		GameState.registra_storico(tipo, "", contenuto)
		mostra_carta_titolo(contenuto)
		return
	carta_titolo.visible = false
	box.visible = true
	var nome_parlante := ""
	if tipo == "dialogo":
		var chi := String(msg.get("chi", GameState.id_protagonista))
		nome_parlante = String(GameState.personaggi.get(chi, {}).get("nome", chi))
		if msg.has("espr"):
			aggiorna_espressione_centro(chi, String(msg["espr"]))
		evidenzia_parlante(chi)
	else:
		evidenzia_parlante("")
	GameState.registra_storico(tipo, nome_parlante, contenuto)
	box.mostra(tipo, contenuto, nome_parlante)

func mostra_carta_titolo(contenuto: String) -> void:
	# il nome di un luogo non e' una riga di narrazione: si prende lo schermo,
	# resta finche' non lo si chiude, e solo dopo la scena riprende. Quello che
	# sarebbe dovuto succedere a fine testo (aprire le scelte) resta in attesa:
	# altrimenti i bottoni comparirebbero dietro il velo della carta.
	azione_dopo_titolo = azione_a_fine_testo
	azione_a_fine_testo = Callable()
	box.visible = false
	testo_titolo.text = contenuto
	carta_titolo.visible = true
	carta_titolo.modulate.a = 0.0
	var comparsa := create_tween()
	comparsa.tween_property(carta_titolo, "modulate:a", 1.0, Stile.tempo("carta_titolo"))

func chiudi_carta_titolo() -> void:
	var uscita := create_tween()
	uscita.tween_property(carta_titolo, "modulate:a", 0.0, Stile.tempo("carta_titolo") * 0.6)
	uscita.finished.connect(_dopo_carta_titolo)

func _dopo_carta_titolo() -> void:
	carta_titolo.visible = false
	if azione_dopo_titolo.is_valid():
		var richiamo := azione_dopo_titolo
		azione_dopo_titolo = Callable()
		richiamo.call()
		return
	avanza_messaggio()

func sostituisci_nome(testo: String) -> String:
	# permette a narrazione/dialogo di citare il nome scelto dal giocatore
	# per il protagonista, es. "Benvenuto, {nome}." (distinto dal "%s" di
	# dialoghi.json, gia' risolto altrove per i nomi dei compagni)
	if testo.find("{nome}") == -1:
		return testo
	var nome := String(GameState.personaggi.get(GameState.id_protagonista, {}).get("nome", "Anonimo"))
	return testo.replace("{nome}", nome)

# --- scelte ---

func ricostruisci_scelte(nodo: Dictionary) -> void:
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	var primo: Button = null
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
		var bottone := bottone_scelta(String(scelta.get("testo", "…")))
		bottone.pressed.connect(_su_scelta.bind(scelta))
		contenitore_scelte.add_child(bottone)
		if primo == null:
			primo = bottone
	if mostrando_scena:
		# la descrizione del posto resta sempre a portata di mano: dopo qualche
		# scelta il box ha gia' cambiato testo, e riguardarsi intorno e' gratis
		var bottone_osserva := bottone_scelta("Osserva la scena")
		bottone_osserva.pressed.connect(_su_osserva)
		contenitore_scelte.add_child(bottone_osserva)
		if primo == null:
			primo = bottone_osserva
	if primo != null:
		# la prima scelta parte gia' selezionata: si puo' giocare da tastiera
		primo.grab_focus()

func bottone_scelta(testo: String) -> Button:
	var bottone := Button.new()
	bottone.text = testo
	Stile.scelta(bottone)
	return bottone

func notifiche_task() -> Array[Dictionary]:
	# un appunto nuovo non e' una riga di sistema: e' il protagonista che si
	# ferma un attimo e mette a fuoco dove deve andare. Quindi una notifica
	# sola a fare da intestazione, e poi il pensiero vero come narrazione.
	var righe: Array[Dictionary] = []
	if GameState.task_da_notificare.is_empty():
		return righe
	var quanti := GameState.task_da_notificare.size()
	var intestazione := "Il Diario si è aggiornato."
	if quanti > 1:
		intestazione = "Il Diario si è aggiornato: %d nuovi appunti." % quanti
	righe.append({"tipo": "notifica", "testo": intestazione})
	# quando ne arrivano tanti insieme (la fine del tutorial ne apre quattro)
	# non si scaricano tutti addosso al giocatore: due si leggono qui, il
	# resto lo trova nel Diario quando decide da dove cominciare
	var letti := 0
	for id_task in GameState.task_da_notificare:
		if letti >= APPUNTI_LETTI_A_VOCE:
			righe.append({"tipo": "narrazione",
					"testo": "Il resto me lo sono segnato. Ci ripenso quando decido da dove cominciare."})
			break
		var voce := GameState.dati_task(id_task)
		var testo := String(voce.get("testo", ""))
		if testo != "":
			righe.append({"tipo": "narrazione", "testo": testo})
			letti += 1
	GameState.task_da_notificare.clear()
	return righe

func applica_task(contenitore: Dictionary) -> void:
	# "task" e "chiudi_task" accettano sia un id singolo che una lista, cosi'
	# scrivere un appunto in un nodo costa una riga sola
	for id_task in _lista_id(contenitore.get("task", [])):
		GameState.apri_task(id_task)
	for id_task in _lista_id(contenitore.get("chiudi_task", [])):
		GameState.chiudi_task(id_task)

func _lista_id(valore: Variant) -> Array[String]:
	var risultato: Array[String] = []
	if valore == null:
		return risultato
	if valore is Array:
		for elemento in valore:
			var id_elemento := String(elemento)
			if id_elemento != "":
				risultato.append(id_elemento)
		return risultato
	var id_singolo := String(valore)
	if id_singolo != "":
		risultato.append(id_singolo)
	return risultato

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

# --- palco dei ritratti ---

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

func evidenzia_parlante(id_personaggio: String) -> void:
	# chi parla resta pieno, gli altri si attenuano: si capisce a colpo d'occhio
	# di chi e' la voce nel box, senza doverne leggere il nome
	for slot in [slot_sinistra, slot_centro, slot_destra]:
		if not slot.visible:
			continue
		var suo: bool = id_personaggio == "" or String(slot.id_mostrato) == id_personaggio
		slot.imposta_attenuato(not suo)

func aggiorna_espressione_centro(id_personaggio: String, espressione: String) -> void:
	# una scena "centro" (un solo personaggio a schermo) puo' cambiare la sua
	# espressione a meta' sequenza: es. il giocoliere che perde il sorriso
	# un attimo prima del combattimento
	var centro: Variant = nodo_in_corso.get("centro")
	var id_centro := String(centro.get("id", "")) if centro is Dictionary else String(centro)
	if slot_centro.visible and id_centro == id_personaggio:
		mostra_slot(slot_centro, id_personaggio, espressione)

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

# --- azioni del giocatore ---

func _su_osserva() -> void:
	# guardarsi intorno non e' una scelta: non consuma niente, non muove il
	# legame, non fa scattare agguati. Ridescrive e basta.
	coda_messaggi = messaggi_scena(nodo_in_corso)
	avanza_messaggio()

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
	applica_task(scelta)
	if scelta.has("stress"):
		for id_classe in GameState.party:
			GameState.modifica_stress(id_classe, int(scelta["stress"]))
	if scelta.has("legame"):
		GameState.modifica_legame(int(scelta["legame"]))
	if scelta.has("combatti"):
		GameState.prepara_combattimento(scelta["combatti"], scelta.get("se_vinci", ""),
				scelta.get("se_vinci_eroe", ""), scelta.get("se_perdi", ""), scelta.get("se_fuggi", ""))
		Transizioni.vai(SCENA_COMBATTIMENTO)
		return
	if scelta.get("torna_vuoto", false):
		# uscita da uno squarcio: lo stato resta, ma gli alleati temporanei
		# non ti seguono fuori
		GameState.congeda_tutti_temporanei()
		Transizioni.vai(SCENA_VUOTO)
		return
	if scelta.get("reset", false):
		GameState.reset_campagna()
		Transizioni.vai(SCENA_MAPPA)
		return
	if scelta.get("game_over", false):
		# si perde il progresso non salvato, ma non si viene sbalzati sulla
		# mappa stellare: si ricomincia il livello dal suo punto di partenza
		if GameState.game_over():
			Transizioni.vai(SCENA_EVENTI)
		else:
			Transizioni.vai(SCENA_MAPPA)
		return
	if scelta.get("torna_a_mappa", false):
		# mappa dungeon di zona: si torna li' a scegliere la prossima stanza,
		# invece di proseguire dritti verso un altro nodo
		Transizioni.vai(SCENA_MAPPA_ZONA)
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
		var bottone_conv := bottone_scelta("%s e %s stanno parlando..." % [nome_a, nome_b])
		bottone_conv.pressed.connect(_su_conversazione.bind(conversazione))
		menu_compagni.add_child(bottone_conv)
	for id_classe in GameState.party:
		if id_classe == GameState.id_protagonista:
			continue
		var bottone := bottone_scelta(String(GameState.classi.get(id_classe, {}).get("nome", id_classe)))
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
	applica_task(conversazione)
	coda_messaggi = sequenza_di(conversazione) + notifiche_task()
	azione_dopo_coda = _mostra_mediazione.bind(conversazione) if conversazione.has("mediazione") else Callable()
	avanza_messaggio()

func _mostra_mediazione(conversazione: Dictionary) -> void:
	# il giocatore puo' intervenire nella discussione: alcune opzioni sono
	# sbloccate solo se ha in sacca l'oggetto giusto per dare peso alle sue parole
	var mediazione: Dictionary = conversazione.get("mediazione", {})
	nascondi_comandi()
	azione_a_fine_testo = _opzioni_mediazione.bind(mediazione)
	box.mostra("narrazione", String(mediazione.get("testo", "Puoi intervenire.")), "")
	area_avanza.visible = false

func _opzioni_mediazione(mediazione: Dictionary) -> void:
	box.nascondi_indicatore()
	var primo: Button = null
	for opzione in mediazione.get("opzioni", []):
		if opzione.has("richiede_oggetto") and not GameState.possiede_oggetto(opzione["richiede_oggetto"]):
			continue
		var bottone := bottone_scelta(String(opzione.get("testo", "…")))
		bottone.pressed.connect(_su_mediazione.bind(opzione))
		contenitore_scelte.add_child(bottone)
		if primo == null:
			primo = bottone
	if primo != null:
		primo.grab_focus()

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
		applica_task(voce)
		coda_messaggi += notifiche_task()
	avanza_messaggio()
	# la battuta puo' aver sbloccato una scelta gated da richiede_flag: la
	# prossima volta che la coda si svuota, ricostruisci_scelte() la rilegge

# --- barra di stato ---

func aggiorna_stato() -> void:
	var nomi: Array[String] = []
	for id_classe in GameState.party:
		nomi.append(String(GameState.classi.get(id_classe, {}).get("nome", id_classe)))
	etichetta_party.text = ", ".join(nomi) if not nomi.is_empty() else "solo tu"
	etichetta_risorse.text = "Lv %d   ·   Tazo %d   ·   Sacca %d/%d   ·   Legame %d" % [
		GameState.livello_di(GameState.id_protagonista), GameState.tazo,
		GameState.sacca.size(), int(GameState.regole.get("sacca_massima", 20)), GameState.legame,
	]
	etichetta_stat.text = "HP %d   ATT %d   DIF %d   VEL %d   INT %d   MEN %d   FAT %d" % [
		GameState.stat_di("hp"), GameState.stat_di("attacco"), GameState.stat_di("difesa"),
		GameState.stat_di("velocita"), GameState.stat_di("intelligenza"),
		GameState.stat_di("forza_mentale"), GameState.stat_di("fattore"),
	]
