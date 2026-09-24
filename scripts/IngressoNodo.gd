class_name IngressoNodo
extends RefCounted

# Cosa succede quando si entra in un nodo, e dove si finisce.
#
# PERCHÉ ESISTE. Prima tutto questo stava dentro mostra_nodo(), insieme al
# disegno della schermata. Una funzione sola faceva cinque mestieri:
#
#   1. capire quale nodo sia davvero (vai_se_flag, nodo inesistente)
#   2. applicare gli effetti d'ingresso (flag, stanze, congedi, appunti,
#      checkpoint, conteggio delle visite)
#   3. decidere se qui scatta un agguato, e se il party recupera i punti vita
#   4. disegnare la schermata
#   5. andarsene da un'altra parte
#
# Ogni bug delle schermate vuote è nato in una giuntura fra due di questi
# cinque. Non era sfortuna: cinque responsabilità in una funzione fanno quattro
# giunture, e ogni giuntura è un posto dove si può restare in mezzo.
#
# Adesso la DECISIONE sta qui, il DISEGNO sta in Main. Qui dentro non c'è
# nessuna scena, nessun nodo dell'albero, nessun await: entrano un id e lo stato
# del gioco, esce un verdetto.
#
#   {"id": String, "nodo": Dictionary, "scena": String, "stanza": String,
#    "prima_visita": bool, "agguato": bool}
#
#   scena == ""  ->  si resta, e "nodo" è quello che c'è da mostrare
#   scena != ""  ->  non si mostra niente: si va lì
#
# È questo che chiude la faccenda della schermata vuota, e non un controllo in
# più. Main viene costruita SOLO quando c'è un nodo da disegnare: lo stato
# "schermata viva e vuota" non è reso improbabile, non è più costruibile.
#
# E siccome non tocca l'albero delle scene, si può provare direttamente: entrare
# in ogni nodo del gioco e controllare il verdetto costa qualche millesimo,
# senza istanziare niente (vedi prova_ingresso_nodi).

const SCENA_SEDE := "res://scenes/Sede.tscn"
const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_COMBATTIMENTO := "res://scenes/Combattimento.tscn"

const SALTI_MASSIMI := 8   # oltre questo due nodi si stanno rimandando a vicenda
const SCENA_EVENTI := "res://scenes/Main.tscn"

# Il verdetto dell'ultimo ingresso, che Main raccoglie appena nasce. E' l'unico
# stato che questa classe tiene, e dura un istante: chi entra decide, chi
# disegna raccoglie. Serve perche' gli effetti d'ingresso (flag, appunti,
# checkpoint) devono succedere UNA volta sola, non di nuovo alla nascita della
# schermata.
static var ultimo_esito: Dictionary = {}

static func vai_al_nodo(id_nodo: String) -> void:
	# L'UNICO MODO DI ENTRARE IN UN NODO DA UN'ALTRA SCHERMATA.
	#
	# Si decide PRIMA di scegliere la scena. Se qui scatta un agguato si va
	# dritti al combattimento e la schermata degli eventi non viene mai
	# costruita: non c'e' nessun istante in cui esiste una stanza a cui nessuno
	# ha detto cosa mostrare. Non e' resa improbabile - non viene proprio al
	# mondo.
	#
	# E' per questo che questa funzione esiste al posto di
	# "Transizioni.vai(SCENA_EVENTI)" sparso in cinque file.
	var esito := entra(id_nodo)
	ultimo_esito = esito
	Transizioni.vai(String(esito.scena) if String(esito.scena) != "" else SCENA_EVENTI)

static func raccogli(id_atteso: String) -> Dictionary:
	# Main chiama questa alla nascita. Se qualcuno e' gia' entrato per lei
	# (vai_al_nodo) prende il verdetto pronto; altrimenti - scena aperta a mano
	# dall'editor, o un flusso che non passa dal router - entra adesso.
	#
	# Main la chiama con GameState.nodo_corrente, e entra() li' scrive la
	# STANZA del nodo, non il suo nome: il risveglio in infermeria lascia
	# "infermeria", la partenza dalla sala di proiezione "sala_proiezione".
	# Confrontando solo il nome il verdetto pronto veniva buttato e si
	# rientrava nella stanza, la cui regola mandava altrove: dopo l'allenamento
	# si saltava il risveglio con la Dr. Reika («hai dimenticato qualcosa?»), e
	# scelta la prima missione sulla mappa ricominciava la scena di Veronica,
	# all'infinito. Le prove guardavano il verdetto in partenza, non cosa
	# arrivava a schermo; l'ha trovato l'automa (prove/automa.sh), girando in
	# tondo per ventisette minuti di gioco.
	var esito := ultimo_esito
	ultimo_esito = {}
	if not esito.is_empty() and id_atteso in [String(esito.get("id", "")),
			String((esito.get("nodo", {}) as Dictionary).get("stanza", "")),
			String(esito.get("stanza", ""))]:
		return esito
	return entra(id_atteso)


static func entra(id_nodo: String) -> Dictionary:
	var esito := {
		"id": id_nodo, "nodo": {}, "scena": "", "stanza": "",
		"prima_visita": false, "agguato": false,
	}
	var id_vero := risolvi(id_nodo)
	if id_vero == "":
		# nodo inesistente: non c'è niente da mostrare, quindi non si costruisce
		# nessuna schermata. Che ogni destinazione punti a un nodo esistente è
		# verificato dalle prove su tutti i file di eventi: qui si finisce solo
		# con dati sbagliati, e allora meglio la mappa che una prigione
		push_error("Nodo evento mancante: " + id_nodo)
		esito.scena = SCENA_VUOTO if GameState.carnivalz_corrente != "" else SCENA_SEDE
		return esito
	var nodo: Dictionary = GameState.eventi[id_vero]
	esito.id = id_vero
	esito.nodo = nodo
	esito.prima_visita = id_vero not in GameState.nodi_visitati
	# UNA SCENA PUO' SUCCEDERE IN UNA STANZA CHE NON PORTA IL SUO NOME.
	#
	# Di solito il nodo E' la stanza, e va benissimo. Ma "ti risvegli in
	# infermeria" e' una scena sola, che capita una volta e arriva da un
	# combattimento: chiamarla "infermeria" vorrebbe dire sovrascrivere la
	# stanza vera, che sulla mappa c'e' tutti i giorni. Col campo "stanza" la
	# scena dice dove sta, e la mappa sa dove sei: il "sei qui" finisce nel
	# posto giusto e da li' si cammina verso i vicini di QUELLA stanza.
	#
	# E UNA SCENA PUO' NON SPOSTARTI AFFATTO: "resta_dove_sei". Bru, sul
	# promontorio dopo la fuga: «se provi ad andare sul promontorio: Se ne
	# occupera' l'organizzazione di quella creatura». Ci provi, ti fermi, e sei
	# ancora dov'eri - al bivio o dall'altra parte, verso le urla. Nessuna delle
	# due stanze si puo' scrivere nei dati, perche' dipende da dove arrivi: la
	# stanza resta quella in cui gia' eri, e il verdetto se la porta dietro
	# ("stanza") perche' Main la riconosca nascendo.
	if not nodo.get("resta_dove_sei", false):
		GameState.nodo_corrente = String(nodo.get("stanza", id_vero))
	esito.stanza = GameState.nodo_corrente
	applica_effetti(id_vero, nodo, esito.prima_visita)
	esito.agguato = tira_agguato(id_vero, nodo)
	if esito.agguato:
		esito.scena = SCENA_COMBATTIMENTO
	elif not nodo.get("mantieni_hp", false):
		# nessun agguato: qui si respira, e il party recupera tutto. Finché gli
		# scontri si incatenano (ondate) gli hp restano quelli lasciati dallo
		# scontro precedente; "mantieni_hp" lo chiede esplicitamente per le fasi
		# di uno stesso scontro, dove in mezzo c'è una scena e non una pausa
		GameState.hp_persistenti.clear()
	return esito

static func risolvi(id_nodo: String) -> String:
	# quale nodo si mostra davvero: "vai_se_flag" manda a un altro al suo posto
	# (stessa stanza, seconda visita: il primo incontro è già avvenuto).
	# Restituisce "" se non si arriva a nessun nodo esistente.
	var id_corrente := id_nodo
	for salto in SALTI_MASSIMI:
		if not GameState.eventi.has(id_corrente):
			return ""
		var nodo: Dictionary = GameState.eventi[id_corrente]
		if not nodo.has("vai_se_flag"):
			return id_corrente
		# UNA REGOLA SOLA NON BASTA PIU'. La sala di proiezione vuol dire tre
		# cose in tre momenti della giornata: chiusa la mattina, "prossimo punto
		# d'interesse" dopo l'infermeria, e la procedura di proiezione quando il
		# data pad l'ha spiegata. Con un salto solo se ne potevano dire due.
		# Adesso "vai_se_flag" accetta anche una lista: vince la prima regola
		# che trova il suo flag, quindi si scrivono dalla piu' recente alla piu'
		# vecchia.
		var dove := dove_manda(nodo["vai_se_flag"])
		if dove == "":
			return id_corrente
		id_corrente = dove
	push_error("vai_se_flag: %d salti di fila da '%s', due nodi si rimandano a vicenda"
			% [SALTI_MASSIMI, id_nodo])
	return ""

static func dove_manda(regole: Variant) -> String:
	# "" vuol dire "resta dove sei". Accetta sia una regola sola (com'era) sia
	# una lista di regole (vince la prima che ha il suo flag).
	if regole is Dictionary:
		var una: Dictionary = regole
		if GameState.ha_flag(String(una.get("flag", ""))):
			return String(una.get("vai", ""))
		return ""
	if regole is Array:
		for voce in (regole as Array):
			if voce is Dictionary and GameState.ha_flag(String((voce as Dictionary).get("flag", ""))):
				return String((voce as Dictionary).get("vai", ""))
	return ""

static func applica_effetti(id_nodo: String, nodo: Dictionary, prima_visita: bool) -> void:
	# Tutto quello che il solo fatto di ENTRARE in un posto cambia nel mondo.
	# Succede una volta sola per ingresso, e prima di qualunque disegno.
	if prima_visita:
		# esplorare allena la velocità: ogni stanza conta una volta sola
		GameState.nodi_visitati.append(id_nodo)
		GameState.registra_azione("stanze_esplorate")
		# ESSERCI DENTRO VUOL DIRE AVERLA SCOPERTA. Prima una stanza risultava
		# "sbloccata" solo se un evento la nominava per nome, quindi si poteva
		# stare in una stanza che per la mappa non era ancora aperta - ed era
		# meta' della ragione per cui dalla mappa non si esplorava.
		#
		# E si sblocca LA STANZA, non la scena: «la sala comunicazioni dopo gli
		# ordini» e' un nodo, ma sulla planimetria e' sempre la sala comunicazioni
		# (vedi il campo "stanza" in entra). Sbloccare l'id del nodo segnava come
		# stanza una cosa che sulla mappa non c'e'. E una scena che non ti sposta
		# ("resta_dove_sei") non ti ha portato da nessuna parte da scoprire
		if not nodo.get("resta_dove_sei", false):
			GameState.sblocca_stanza(String(nodo.get("stanza", id_nodo)))
	if nodo.has("flag"):
		GameState.imposta_flag(nodo["flag"])
	if nodo.has("sblocca_stanze"):
		# mappa dungeon di zona: visitare questo nodo ne apre altre
		for id_stanza in nodo["sblocca_stanze"]:
			GameState.sblocca_stanza(String(id_stanza))
	if nodo.has("congeda"):
		GameState.congeda(nodo["congeda"])
	applica_task_di(nodo)
	if nodo.get("salva_checkpoint", false):
		# eccezione deliberata alla regola "si salva solo dalla mappa stellare":
		# protegge Tazo, oggetti e flag raccolti finora in un dungeon lungo. NON
		# fa riprendere la partita da qui: il caricamento riporta sempre a uno
		# stato overworld pulito, quindi un game over dopo questo punto torna
		# comunque alla mappa (si perde la posizione, non il bottino)
		GameState.salva()

static func tira_agguato(id_nodo: String, nodo: Dictionary) -> bool:
	# Ogni volta che si entra nella stanza si tenta la probabilità. Una zona
	# "ripulita" non tenta più niente; un agguato "ripetibile" non si esaurisce
	# mai (farm zone). Qui si decide e si prepara lo scontro: partire è affare
	# di chi ha chiamato entra().
	if not nodo.has("agguato") or id_nodo in GameState.stanze_ripulite:
		return false
	var agguato: Dictionary = nodo["agguato"]
	if agguato.has("salta_se_flag") and GameState.ha_flag(String(agguato["salta_se_flag"])):
		return false
	if GameState.rng.randf() >= float(agguato.get("probabilita", 0.3)):
		return false
	var gruppi: Array = agguato.get("gruppi", [])
	if gruppi.is_empty():
		return false
	if not agguato.get("ripetibile", false):
		GameState.stanze_ripulite.append(id_nodo)
	var gruppo: Array = gruppi[GameState.rng.randi_range(0, gruppi.size() - 1)]
	# fuggire da un agguato non ha penalità: si torna semplicemente qui. E chi
	# lo tende muove per primo: «se i nemici tendono imboscate o ti colgono di
	# sorpresa hanno la precedenza come turno» (Bru)
	GameState.prepara_combattimento(gruppo, id_nodo, "", agguato.get("se_perdi", ""), id_nodo,
			{"precedenza": "nemici"})
	return true

static func destinazione(scelta: Dictionary) -> String:
	# dove porta una scelta: il nodo che nomina ("vai"), oppure la stanza in
	# cui sei ("torna_dove_eri"). La seconda serve dopo una scena che non ti ha
	# spostato ("resta_dove_sei"): al promontorio si prova a salire dal bivio o
	# da verso le urla, e «Torna indietro» deve rimetterti in quella delle due
	# da cui ci hai provato - che nei dati non si puo' scrivere. "" = nessuna
	if scelta.get("torna_dove_eri", false):
		return GameState.nodo_corrente
	return String(scelta.get("vai", ""))

static func trattiene(nodo: Dictionary) -> bool:
	# UNA SCENA CHE NON TI LASCIA ANDARE. Bru, in cima al promontorio: «qui due
	# opzioni, prosegui o torna indietro, qualunque cosa scegli triggera
	# l'apparizione». La mappa sarebbe stata la terza, l'unica che non fa
	# scattare niente: con "senza_mappa" il nodo toglie il bottone della mappa
	# (Main.aggiorna_dialoga) e spegne l'icona della Guida, che la riapre
	# (IconaGuida.aggiorna)
	return bool(nodo.get("senza_mappa", false))

static func applica_task_di(contenitore: Dictionary) -> void:
	# Gli appunti del Diario si aprono e si chiudono allo stesso modo da un nodo,
	# da una scelta o da una battuta: "task" e "chiudi_task" accettano sia un id
	# singolo che una lista, cosi' scriverne uno costa una riga sola.
	for id_task in lista_id(contenitore.get("task", [])):
		GameState.apri_task(id_task)
	for id_task in lista_id(contenitore.get("chiudi_task", [])):
		GameState.chiudi_task(id_task)

static func lista_id(valore: Variant) -> Array[String]:
	var risultato: Array[String] = []
	if valore == null:
		return risultato
	if valore is Array:
		for elemento in valore:
			var id_elemento := String(elemento)
			if id_elemento != "":
				risultato.append(id_elemento)
	elif String(valore) != "":
		risultato.append(String(valore))
	return risultato
