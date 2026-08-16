extends Node

# Autoload: stato di gioco e regole. Niente contenuti hardcodati:
# classi, personaggi, psichi, oggetti, negozi, eventi, mappa e numeri
# di bilanciamento vivono nei JSON sotto data/.

const PERCORSO_CLASSI := "res://data/classes.json"
const PERCORSO_PERSONAGGI := "res://data/personaggi.json"
const PERCORSO_PSICHE := "res://data/psiche.json"
const PERCORSO_OGGETTI := "res://data/oggetti.json"
const PERCORSO_NEGOZI := "res://data/negozi.json"
const PERCORSO_MAPPA := "res://data/mappa.json"
const PERCORSO_REGOLE := "res://data/regole.json"
const PERCORSO_DIALOGHI := "res://data/dialoghi.json"
const PERCORSO_AUDIO := "res://data/audio.json"
const PERCORSO_STUDIO := "res://data/studio.json"
const PERCORSO_STATI := "res://data/stati.json"
const PERCORSO_RUOLI := "res://data/ruoli.json"
const PERCORSO_TECNOLOG := "res://data/tecnolog.json"
const PERCORSO_ABILITA := "res://data/abilita.json"
const PERCORSO_CRESCITA := "res://data/crescita.json"
const PERCORSO_TASK := "res://data/task.json"
const PERCORSO_CODICI := "res://data/codici.json"  # extra: sblocchi via codice
const PERCORSO_CODICI_RISCATTATI := "user://codici_riscattati.cfg"
const PERCORSO_SALVATAGGIO_VECCHIO := "user://salvataggio.json"  # autosalvataggio di prima
const SLOT_MASSIMO := 5  # una partita per slot: non ci sono altri salvataggi

# Una partita = uno slot, e basta.
#
# Prima c'erano due cose diverse: un autosalvataggio unico (uno solo per tutto
# il gioco) e cinque slot manuali. Il giocatore doveva sapere quale delle due
# stesse usando, e "Salva" apriva un selettore in mezzo alla partita. Era la
# stessa confusione di gerarchia che si vedeva nel menu: roba da schermata
# principale che spuntava dentro il gioco.
#
# Adesso si sceglie la partita PRIMA di giocare, una volta, dalla schermata
# principale. Da li' in poi il gioco scrive sempre in quel file, da solo, e in
# gioco non c'e' piu' niente da amministrare: nessun selettore, nessuna scelta,
# nessun modo di sovrascrivere per sbaglio la partita di qualcun altro.
var slot_corrente: int = 1
# Questa partita ha gia' scritto (o letto) il suo file almeno una volta.
# Serve al game over: si ricarica il salvataggio solo se e' DI QUESTA partita.
# Senza, chi comincia una partita nuova in uno slot occupato e muore nel
# tutorial si ritroverebbe addosso l'inventario della partita di prima.
var partita_su_file := false

# Unica fonte di casualità del gioco: sempre seedata, per determinismo
# e sync multiplayer futuro.
var rng := RandomNumberGenerator.new()
var seed_partita: int = 0

var classi: Dictionary = {}
var personaggi: Dictionary = {}      # classi + NPC (ritratti, dialoghi, stat)
var psichi: Dictionary = {}
var oggetti: Dictionary = {}         # id oggetto -> definizione
var negozi: Dictionary = {}          # id negozio -> definizione
var regole: Dictionary = {}
var dialoghi: Dictionary = {}        # id nodo -> battuta di un compagno (lore, sblocchi)
var conversazioni: Dictionary = {}   # id nodo -> discussione tra due compagni + mediazione
var audio: Dictionary = {}           # config musica (chiavi -> percorsi)
var domande_studio_generiche: Array = []  # pool di domande per Studia sui nemici comuni
var stati: Dictionary = {}
                                          # id stato -> definizione generica (tipo, contagiosa, ...)
var ruoli: Dictionary = {}   # data/ruoli.json: curva e ruoli da cui escono i numeri di una creatura
var tecnolog: Dictionary = {}      # data/tecnolog.json: la scheda di specie che lo Studio riempie
var abilita: Dictionary = {}       # data/abilita.json: abilita', linee, punti, classi d'arma
var nodi_abilita: Array[String] = []  # i nodi comprati coi punti (abilita' e potenziamenti)
var codici: Dictionary = {}               # codice (maiuscolo) -> {testo, effetto}, vedi Extra
var codici_riscattati: Array[String] = []  # persiste da solo, fuori dagli slot di salvataggio
var musica_ambiente: String = ""     # traccia della scena eventi corrente (frattura/campagna)
var id_protagonista: String = ""
var nome_protagonista: String = ""     # vuoto = usa il nome di default ("Anonimo")
var nome_anonimo_default: String = ""  # catturato da classes.json al primo caricamento

var classi_sbloccate: Array[String] = []  # roster: persiste tra le campagne
var party: Array[String] = []             # scelto a inizio campagna
var livelli: Dictionary = {}              # id classe -> livello (default 1)
var xp: Dictionary = {}                   # id classe -> xp verso il prossimo livello
var stress: Dictionary = {}               # id classe -> 0..100
var legame: int = 0                       # 0..100, respira di continuo

# Inventario a slot: solo la sacca ha un limite ed è spendibile in combattimento
var sacca: Array[String] = []             # consumabili, max regole.sacca_massima
var collezionabili: Array[String] = []
# La pila: id oggetto -> quanti. Non una lista, un conto (vedi aggiungi_alla_pila)
var pila: Dictionary = {}
# LA BARRA DI DOMINIO NON STA QUI, e la riga resta per dirlo. Si riempie
# dentro un combattimento e si azzera al successivo: e' una prerogativa dello
# scontro, non una risorsa che ti porti dietro per la mappa. Vive nella scheda
# del combattente (Combattimento.gd, campo "dominio"), non nello stato del
# mondo. Per un giorno e' stata qui e la si vedeva sulla schermata dei dialoghi
# gia' carica a inizio partita: due errori in uno.
var chiavi: Array[String] = []
# Lo zaino non e' un mucchio: e' diviso per categoria, e ogni categoria ha la
# sua capacita' (vedi "zaino" in regole.json).
#   armi             -> quante ne puoi PORTARE, non quante ne puoi impugnare.
#                       Un'arma equipaggiata resta qui dentro, segnata "in uso"
#   accessori        -> i piccoli aggiustamenti
#   consumabili      -> la sacca: l'unica che si spende in combattimento
#   oggetti speciali -> stigmi, ricordi, chiavi. Nessun limite: sono la storia
#                       che ti porti dietro, non zavorra da amministrare
var armi: Array[String] = []
var accessori: Array[String] = []         # equipaggiamento posseduto (unico per id, non consumabile)
var oggetti_speciali: Array[String] = []
# quante volte hai comprato spazio, per categoria: "spazi nella realta'" per i
# consumabili, "frammenti" per armi e accessori
var spazi_zaino: Dictionary = {}
var accessorio_equipaggiato: String = ""  # eredita' del vecchio sistema a un solo slot: migrato al caricamento

# Equipaggiamento per personaggio. Ogni membro della squadra ha i suoi slot,
# e quello che ci mette dentro vale solo per lui: un amuleto addosso a Yhvina
# non protegge il protagonista. Struttura:
#   id_classe -> { "arma": id, "stigma": id, "accessori": [id, ...],
#                  "ultima_risorsa": id }
# Gli slot non sono numeri: ognuno vuole dire una cosa diversa. Un'arma e' come
# colpisci, uno stigma e' un patto (da' e toglie), gli accessori sono i piccoli
# aggiustamenti, l'ultima risorsa e' la rete che scatta quando stai per cadere.
var equipaggiamento: Dictionary = {}
const SLOT_SINGOLI := ["arma", "stigma", "ultima_risorsa"]
# Album delle carte. "carte" resta l'elenco di quelle che hai visto almeno una
# volta (e' quello che l'Album conta); i doppioni non si buttano, si accumulano
# in "carte_copie" - una carta in piu' e' merce da vendere o da scambiare, non
# un drop sprecato. Ogni copia ha la sua finitura (normale, con stile, proibita):
#   carte_copie = { id_carta: { "normale": 3, "con stile": 1 } }
var carte: Array[String] = []             # carte dei nemici (album): id carta ottenute
var carte_copie: Dictionary = {}
var tazo: int = 0
var fonti_estinte: int = 0
var negozi_sbloccati: Array[String] = []

var eventi: Dictionary = {}
var nodo_corrente: String = ""
var carnivalz_corrente: String = ""
var file_eventi_corrente: String = ""  # serve a rientrare nella zona dopo un game over
var stanza_iniziale_zona: String = ""  # nodo_iniziale della zona (sempre sbloccato sulla mappa)
var mappa_zona: Dictionary = {}         # "mappa_dungeon" del file eventi corrente, se presente
var ospiti: Array[String] = []       # personaggi temporanei della campagna
var alleati_temporanei: Array[String] = []  # compagni che combattono per un solo squarcio
var studiati: Array[String] = []     # chi hai studiato (per la sezione studio futura)
# QUANTE VOLTE HAI STUDIATO OGNI SPECIE, e non si azzera a partita nuova.
# I numeri di una creatura (quanti hp le restano, quanto para) vanno riscoperti
# a ogni scontro - sono lo stato di QUELLA creatura li' davanti. Il tecno log no:
# e' quello che si sa della specie, e una volta scritto e' scritto. Per questo
# sta con le collezioni meta, accanto al bestiario, e non fra le cose di partita
var rilevamenti: Dictionary = {}     # id creatura -> studi accumulati
var flags: Array[String] = []        # scoperte permanenti (loot una tantum, segreti)

# --- crescita del protagonista (data/crescita.json). Le stat non salgono da
# sole con il livello: si alimentano con quello che il giocatore fa davvero
# (attaccare, studiare, esplorare, incassare colpi...). I contatori si
# convertono in punti stat a ogni passaggio di livello e si azzerano.
var crescita: Dictionary = {}
var punti_stat: Dictionary = {}          # nome stat -> punti guadagnati oltre la base
var contatori: Dictionary = {}           # nome azione -> quante volte compiuta
var resistenze_stato: Dictionary = {}    # id stato -> punti di resistenza
var volte_stato_subito: Dictionary = {}  # id stato -> quante volte subito (verso il prossimo punto)
var passive_sbloccate: Array[String] = []
var passive_da_notificare: Array[String] = []  # svuotato da chi le mostra a schermo
# Le salite di livello in attesa di essere raccontate: {livello, stat, punti_abilita}.
# Non entrano nel salvataggio - sono una cosa da dire adesso, non un progresso -
# e le svuota chi le mostra a schermo (vedi Main.notifiche_salite_di_livello)
var salite_di_livello: Array[Dictionary] = []
var nodi_visitati: Array[String] = []    # per contare l'esplorazione (una volta per stanza)

# Storico dei messaggi gia' letti nel box: in un gioco fatto di testo, un click
# di troppo non deve far perdere per sempre una battuta. Non entra nel
# salvataggio (e' contesto della sessione, non progresso) e ha un tetto, cosi'
# una partita lunga non se lo porta dietro all'infinito.
const STORICO_MASSIMO := 200
var storico: Array[Dictionary] = []      # {tipo, chi, testo}, dal piu' vecchio

# Appunti del Diario: dove andare, cosa qualcuno ti ha chiesto di fare. Non
# sono una lista della spesa con le spunte, sono quello che il protagonista
# pensa fra se'. Il catalogo sta in data/task.json; quali siano aperti e quali
# chiusi e' progresso di partita, quindi entra nel salvataggio.
var task_catalogo: Array[Dictionary] = []   # definizioni, da data/task.json
var task_attivi: Array[String] = []         # aperti, nell'ordine in cui sono comparsi
var task_chiusi: Array[String] = []         # gia' risolti
var task_da_notificare: Array[String] = []  # svuotato da chi li annuncia a schermo

# hp che il party si porta dietro da uno scontro al successivo, finche' gli
# scontri si incatenano senza respiro (ondate di agguati, fasi di un boss).
# Si azzera appena si mette piede in una stanza in pace: li' si recupera tutto.
var hp_persistenti: Dictionary = {}      # id classe -> hp rimasti

# Collezioni (meta-progressione): si popolano da sole e sopravvivono alle
# campagne. Album delle carte, bestiario, compendio degli oggetti.
var bestiario: Array[String] = []        # id nemici incontrati (voce al 1o incontro)
var oggetti_catalogo: Array[String] = [] # id oggetti ottenuti almeno una volta
var stanze_ripulite: Array[String] = []  # agguati gia' tirati in questa visita

# IL PROIETTORE. Sulla mappa non ci si teletrasporta dove si vuole: si va solo
# in una stanza confinante, come si andrebbe a piedi. L'unica eccezione e'
# questo, che il dominatore ha in dotazione: lo si pianta in una stanza che lo
# permette, e da li' in avanti da qualunque punto della zona ci si torna.
#
# UNO SOLO, e piantarlo altrove lo sposta. E' quello che rende la scelta di
# dove ancorarlo una decisione invece di una comodita' che si accumula. Vive
# per zona (chiave = carnivalz_corrente), perche' un'ancora piantata a Meridia
# non ha senso dentro la Casa Gigante.
var proiettori: Dictionary = {}   # id zona -> id stanza dove sta il proiettore
var punto_mappa_corrente: Dictionary = {}  # il sistema/Vuoto che stai guardando

# Dove sei gia' stato, a livello di mondo: id dei sistemi e degli squarci in cui
# hai messo piede almeno una volta. Non e' progresso (i flag fanno quel
# mestiere): serve alle mappe per dire "questo posto non l'hai ancora visto"
# senza raccontare niente di cosa ci sia dentro.
var zone_visitate: Array[String] = []

var nemici_combattimento: Array = []
var nodo_se_vinci: String = ""
var nodo_se_vinci_eroe: String = ""
var nodo_se_perdi: String = ""
var nodo_se_fuggi: String = ""

func _ready() -> void:
	imposta_seed(int(Time.get_unix_time_from_system()))
	carica_classi()
	carica_personaggi()
	carica_psichi()
	carica_oggetti()
	carica_negozi()
	carica_regole()
	carica_dialoghi()
	carica_audio()
	carica_studio()
	carica_stati()
	carica_ruoli()
	carica_tecnolog()
	carica_abilita()
	carica_crescita()
	carica_task()
	carica_codici()
	nuova_partita()

func imposta_seed(nuovo_seed: int) -> void:
	seed_partita = nuovo_seed
	rng.seed = nuovo_seed

func carica_json(percorso: String) -> Variant:
	if not FileAccess.file_exists(percorso):
		push_error("File dati mancante: " + percorso)
		return null
	var dati: Variant = JSON.parse_string(FileAccess.get_file_as_string(percorso))
	if dati == null:
		push_error("JSON non valido: " + percorso)
	return dati

func carica_classi() -> void:
	var dati: Variant = carica_json(PERCORSO_CLASSI)
	if not dati is Dictionary:
		return
	id_protagonista = dati.get("protagonista", "")
	classi.clear()
	for classe in dati.get("classi", []):
		classi[classe["id"]] = classe
	nome_anonimo_default = String(classi.get(id_protagonista, {}).get("nome", ""))

func imposta_nome_protagonista(nome: String) -> void:
	# il giocatore puo' scegliere un nome per il protagonista (altrimenti
	# resta "Anonimo"); si applica direttamente ai dati in memoria cosi' che
	# ogni punto che legge il nome (box dialoghi, ritratti, party) lo veda
	# senza bisogno di un caso speciale
	nome_protagonista = nome.strip_edges()
	var nome_finale := nome_protagonista if nome_protagonista != "" else nome_anonimo_default
	if classi.has(id_protagonista):
		classi[id_protagonista]["nome"] = nome_finale
	if personaggi.has(id_protagonista):
		personaggi[id_protagonista]["nome"] = nome_finale

func carica_personaggi() -> void:
	personaggi.clear()
	for id_classe in classi:
		personaggi[id_classe] = classi[id_classe]
	var dati: Variant = carica_json(PERCORSO_PERSONAGGI)
	if dati is Dictionary:
		for personaggio in dati.get("personaggi", []):
			var id: String = String(personaggio["id"])
			if personaggi.has(id):
				# un personaggio che e' anche una classe giocabile (es. Yara,
				# gia' in classes.json) non va sostituito di netto: perderebbe
				# hp/attacco/difesa/ritratto della classe. Si fondono i campi,
				# quelli di personaggi.json (qui di solito solo lore extra)
				# vincono in caso di conflitto
				var unito: Dictionary = personaggi[id].duplicate()
				for chiave in personaggio:
					unito[chiave] = personaggio[chiave]
				personaggi[id] = unito
			else:
				personaggi[id] = personaggio

func carica_psichi() -> void:
	var dati: Variant = carica_json(PERCORSO_PSICHE)
	psichi = dati.get("psichi", {}) if dati is Dictionary else {}

func carica_oggetti() -> void:
	oggetti.clear()
	var dati: Variant = carica_json(PERCORSO_OGGETTI)
	if dati is Dictionary:
		for oggetto in dati.get("oggetti", []):
			oggetti[oggetto["id"]] = oggetto

func carica_negozi() -> void:
	negozi.clear()
	var dati: Variant = carica_json(PERCORSO_NEGOZI)
	if dati is Dictionary:
		for negozio in dati.get("negozi", []):
			negozi[negozio["id"]] = negozio

func carica_regole() -> void:
	var dati: Variant = carica_json(PERCORSO_REGOLE)
	regole = dati if dati is Dictionary else {}

func carica_dialoghi() -> void:
	var dati: Variant = carica_json(PERCORSO_DIALOGHI)
	dialoghi = dati.get("luoghi", {}) if dati is Dictionary else {}
	conversazioni = dati.get("conversazioni", {}) if dati is Dictionary else {}

func carica_audio() -> void:
	var dati: Variant = carica_json(PERCORSO_AUDIO)
	audio = dati if dati is Dictionary else {}

func carica_studio() -> void:
	var dati: Variant = carica_json(PERCORSO_STUDIO)
	domande_studio_generiche = dati.get("domande_generiche", []) if dati is Dictionary else []

func carica_crescita() -> void:
	var dati: Variant = carica_json(PERCORSO_CRESCITA)
	crescita = dati if dati is Dictionary else {}

func carica_stati() -> void:
	var dati: Variant = carica_json(PERCORSO_STATI)
	stati = dati.get("stati", {}) if dati is Dictionary else {}

func carica_abilita() -> void:
	var dati: Variant = carica_json(PERCORSO_ABILITA)
	abilita = dati if dati is Dictionary else {}

func carica_ruoli() -> void:
	var dati: Variant = carica_json(PERCORSO_RUOLI)
	ruoli = dati if dati is Dictionary else {}

func carica_tecnolog() -> void:
	var dati: Variant = carica_json(PERCORSO_TECNOLOG)
	if dati is Dictionary:
		tecnolog = dati

func carica_task() -> void:
	task_catalogo.clear()
	var dati: Variant = carica_json(PERCORSO_TASK)
	if not dati is Dictionary:
		return
	for voce in dati.get("task", []):
		task_catalogo.append(voce)

func carica_codici() -> void:
	codici.clear()
	var dati: Variant = carica_json(PERCORSO_CODICI)
	if dati is Dictionary:
		for voce in dati.get("codici", []):
			codici[String(voce.get("codice", "")).to_upper()] = voce
	codici_riscattati.clear()
	var cfg := ConfigFile.new()
	if cfg.load(PERCORSO_CODICI_RISCATTATI) == OK:
		for chiave in cfg.get_value("riscattati", "lista", []):
			codici_riscattati.append(String(chiave))

func riscatta_codice(testo: String) -> Dictionary:
	# ritorna il risultato per l'UI: {trovato, gia_riscattato, testo}. Vive
	# fuori dagli slot di salvataggio (user://codici_riscattati.cfg): un
	# codice riscattato resta tale anche iniziando una nuova partita, come
	# l'album delle carte e il bestiario
	var chiave := testo.strip_edges().to_upper()
	if chiave == "" or not codici.has(chiave):
		return {"trovato": false}
	if chiave in codici_riscattati:
		return {"trovato": true, "gia_riscattato": true, "testo": String(codici[chiave].get("testo", ""))}
	codici_riscattati.append(chiave)
	var cfg := ConfigFile.new()
	cfg.set_value("riscattati", "lista", codici_riscattati)
	cfg.save(PERCORSO_CODICI_RISCATTATI)
	var effetto: Dictionary = codici[chiave].get("effetto", {})
	if effetto.has("oggetto"):
		aggiungi_oggetto(String(effetto["oggetto"]))
	if effetto.has("tazo"):
		modifica_tazo(int(effetto["tazo"]))
	return {"trovato": true, "gia_riscattato": false, "testo": String(codici[chiave].get("testo", ""))}

func domanda_studio_casuale() -> String:
	# per i nemici comuni: la domanda del giocatore e' pescata a caso da un
	# pool condiviso. Le risposte restano scritte per ogni personaggio;
	# solo boss e creature particolari hanno anche la domanda su misura.
	if domande_studio_generiche.is_empty():
		return ""
	return String(domande_studio_generiche[rng.randi_range(0, domande_studio_generiche.size() - 1)])

func carica_mappa() -> Dictionary:
	var dati: Variant = carica_json(PERCORSO_MAPPA)
	return dati if dati is Dictionary else {}

func nuova_partita() -> void:
	partita_su_file = false
	imposta_nome_protagonista("")  # si riparte da "Anonimo": si rinomina di nuovo, se si vuole
	classi_sbloccate.clear()
	party.clear()
	livelli.clear()
	xp.clear()
	stress.clear()
	studiati.clear()
	punti_stat.clear()
	nodi_abilita.clear()
	contatori.clear()
	resistenze_stato.clear()
	volte_stato_subito.clear()
	passive_sbloccate.clear()
	passive_da_notificare.clear()
	salite_di_livello.clear()
	nodi_visitati.clear()
	proiettori.clear()
	zone_visitate.clear()
	storico.clear()
	task_attivi.clear()
	task_chiusi.clear()
	task_da_notificare.clear()
	hp_persistenti.clear()
	sacca.clear()
	collezionabili.clear()
	pila.clear()
	chiavi.clear()
	armi.clear()
	accessori.clear()
	oggetti_speciali.clear()
	spazi_zaino.clear()
	accessorio_equipaggiato = ""
	equipaggiamento.clear()
	# carte, bestiario e oggetti_catalogo sono collezioni meta: non si azzerano
	tazo = int(regole.get("tazo_iniziale", 30))
	fonti_estinte = 0
	negozi_sbloccati.clear()
	negozi_sbloccati.append("organizzazione")
	legame = int(regole.get("legame_iniziale", 20))
	if id_protagonista != "":
		classi_sbloccate.append(id_protagonista)
		party.append(id_protagonista)
	ospiti.clear()
	alleati_temporanei.clear()
	flags.clear()
	stanze_ripulite.clear()
	punto_mappa_corrente = {}
	eventi.clear()
	nodo_corrente = ""
	carnivalz_corrente = ""
	file_eventi_corrente = ""
	stanza_iniziale_zona = ""
	mappa_zona = {}
	annulla_combattimento()

func avvia_carnivalz(id_punto: String, file_eventi: String) -> bool:
	var dati: Variant = carica_json(file_eventi)
	if not dati is Dictionary:
		return false
	carnivalz_corrente = id_punto
	file_eventi_corrente = file_eventi
	if id_punto != "" and id_punto not in zone_visitate:
		zone_visitate.append(id_punto)
	eventi = dati.get("nodi", {})
	nodo_corrente = dati.get("nodo_iniziale", "")
	stanza_iniziale_zona = nodo_corrente
	mappa_zona = dati.get("mappa_dungeon", {})
	return not eventi.is_empty() and nodo_corrente != ""

# --- mappa dungeon di una zona (data/events_*.json, campo "mappa_dungeon"):
# stanze libere da visitare in qualunque ordine, ma solo se sbloccate. La
# stanza iniziale della zona e' sempre sbloccata; le altre lo diventano
# tramite il campo nodo "sblocca_stanze" (Main.gd, alla prima visita del
# nodo che le sblocca). Lo stato vive nei flag di GameState, come qualunque
# altra scoperta permanente, ma con nome namespaced per zona (carnivalz_corrente)
# cosi' zone diverse possono riusare gli stessi id di stanza senza scontrarsi.

func stanza_nella_mappa(id_stanza: String) -> bool:
	# la mappa vale per la sezione esplorabile della zona, non per tutto il
	# file: fuori da quelle stanze (prologhi, scene al quartier generale...)
	# il bottone "Mappa" non ha senso e non compare
	for stanza in mappa_zona.get("stanze", []):
		if String(stanza.get("id", "")) == id_stanza:
			return true
	return false

func stanza_sbloccata(id_stanza: String) -> bool:
	if id_stanza == stanza_iniziale_zona:
		return true
	var flag_completamento := String(mappa_zona.get("flag_completamento", ""))
	if flag_completamento != "" and ha_flag(flag_completamento):
		# a zona completata, tutte le sue stanze restano liberamente visitabili
		# (anche quelle mai scoperte in quella run), non solo quelle sbloccate
		return true
	return ha_flag(_flag_stanza(id_stanza))

func sblocca_stanza(id_stanza: String) -> void:
	imposta_flag(_flag_stanza(id_stanza))

func _flag_stanza(id_stanza: String) -> String:
	return "%s__stanza__%s" % [carnivalz_corrente, id_stanza]

# --- il proiettore ---

func piazza_proiettore(id_stanza: String) -> void:
	# I PROIETTORI SONO PIU' D'UNO, e questa non e' una rifinitura: e' la
	# regola. Bru: "puoi selezionare i punti dove si trovano i proiettori per
	# il teletrasporto, ma solo se sei in uno dei punti dove c'e' un altro
	# teletrasporto". Cioe' si salta da un proiettore a un altro, e basta.
	# Prima ce n'era uno solo per zona e ci si arrivava da ovunque: era un
	# ritorno alla base, non una rete.
	if carnivalz_corrente == "" or id_stanza == "":
		return
	var suoi: Array = proiettori.get(carnivalz_corrente, [])
	if id_stanza not in suoi:
		suoi.append(id_stanza)
	proiettori[carnivalz_corrente] = suoi

func proiettori_di_zona() -> Array[String]:
	var elenco: Array[String] = []
	var grezzo: Variant = proiettori.get(carnivalz_corrente, [])
	if grezzo is String:
		# salvataggi fatti quando il proiettore era uno solo
		if String(grezzo) != "":
			elenco.append(String(grezzo))
		return elenco
	for id_stanza in (grezzo as Array):
		elenco.append(String(id_stanza))
	return elenco

func ce_un_proiettore(id_stanza: String) -> bool:
	return id_stanza in proiettori_di_zona()

func su_un_proiettore() -> bool:
	# se sei su un proiettore puoi saltare agli altri. Se no, si cammina
	return ce_un_proiettore(nodo_corrente)

func proiettore_qui() -> String:
	# il primo proiettore della zona, "" se non ne e' stato piantato nessuno.
	# Resta per chi lo chiedeva quando ce n'era uno solo
	var elenco := proiettori_di_zona()
	return elenco[0] if not elenco.is_empty() else ""

func stanze_confinanti(id_stanza: String) -> Array[String]:
	# i vicini sulla mappa: sono gli unici posti in cui la mappa lascia andare,
	# perche' muoversi vuol dire attraversare quello che c'e' in mezzo
	var vicine: Array[String] = []
	for coppia in mappa_zona.get("connessioni", []):
		if coppia.size() < 2:
			continue
		var a := String(coppia[0])
		var b := String(coppia[1])
		if a == id_stanza and b not in vicine:
			vicine.append(b)
		elif b == id_stanza and a not in vicine:
			vicine.append(a)
	return vicine

# --- dove sei gia' stato ---
#
# Un posto puo' essere in tre stati, e sono gli stessi per la mappa stellare,
# per il Vuoto, per una stanza della Sede: "nuovo" (mai messo piede),
# "visto" (ci sei stato), "chiuso" (li' non c'e' piu' niente da fare, e lo dice
# un flag). I colori li mette Stile; qui si sa solo com'e' messo il mondo.

func segna_visitata(id_posto: String) -> void:
	if id_posto != "" and id_posto not in zone_visitate:
		zone_visitate.append(id_posto)

func gia_visitata(id_posto: String) -> bool:
	return id_posto in zone_visitate

func stato_visita(id_posto: String, flag_chiuso := "") -> String:
	if flag_chiuso != "" and ha_flag(flag_chiuso):
		return "chiuso"
	return "visto" if gia_visitata(id_posto) else "nuovo"

func abilita_combattimento(id_abilita: String) -> Dictionary:
	# la definizione di un'abilita' usabile in battaglia, o {} se quel nome e'
	# un'abilita' narrativa (scasso, volo, sesto senso...) che in combattimento
	# non fa niente
	var tabella: Dictionary = abilita.get("abilita", {})
	var dati: Variant = tabella.get(id_abilita, {})
	return dati if dati is Dictionary else {}

# --- la progressione: cosa sai fare, e cosa puoi ancora imparare -------------
#
# Fino al livello in cui cominciano i punti, un'abilita' arriva da sola quando
# arrivi al suo livello: e' il mestiere di base. Dopo, arriva un punto ogni
# tot livelli e lo spendi su quello che vuoi fra i nodi che il livello ha
# aperto. Le scelte che Bru ha descritto (al 25 Pieta' o Terra bruciata, al 29
# quello che resta o Annichilazione II) non sono scritte da nessuna parte come
# casi particolari: sono la conseguenza di avere un punto solo e piu' di una
# porta aperta.

func punti_abilita_guadagnati(livello: int) -> int:
	var regola: Dictionary = abilita.get("punti", {})
	var dal := int(regola.get("dal_livello", 25))
	if livello < dal:
		return 0
	var ogni := maxi(int(regola.get("ogni_livelli", 4)), 1)
	@warning_ignore("integer_division")
	var quanti := 1 + (livello - dal) / ogni
	return quanti * int(regola.get("per_volta", 1))

func costo_nodo(id_nodo: String) -> int:
	return int(nodo_abilita(id_nodo).get("costo", 0))

func nodo_abilita(id_nodo: String) -> Dictionary:
	# un nodo e' un'abilita' o un potenziamento: si cercano nello stesso modo
	# perche' costano allo stesso modo
	var dati: Variant = abilita.get("abilita", {}).get(id_nodo,
			abilita.get("potenziamenti", {}).get(id_nodo, {}))
	return dati if dati is Dictionary else {}

func punti_abilita_spesi() -> int:
	var totale := 0
	for id_nodo in nodi_abilita:
		totale += costo_nodo(id_nodo)
	return totale

func punti_abilita_liberi() -> int:
	return punti_abilita_guadagnati(livello_di(id_protagonista)) - punti_abilita_spesi()

func nodo_gia_preso(id_nodo: String) -> bool:
	return id_nodo in nodi_abilita

func nodo_disponibile(id_nodo: String) -> bool:
	# aperto dal livello, non gia' preso, alla portata dei punti che hai, e con
	# il nodo che richiede gia' in mano
	var dati := nodo_abilita(id_nodo)
	if dati.is_empty() or nodo_gia_preso(id_nodo):
		return false
	if livello_di(id_protagonista) < int(dati.get("livello", 999)):
		return false
	var richiesto := String(dati.get("richiede", ""))
	if richiesto != "" and not nodo_gia_preso(richiesto):
		return false
	# di una linea si compra il grado successivo a quello che hai, non uno a caso
	var linea := String(dati.get("linea", ""))
	if linea != "" and int(dati.get("grado", 1)) != grado_di_linea(linea) + 1:
		return false
	return costo_nodo(id_nodo) <= punti_abilita_liberi()

func sblocca_nodo(id_nodo: String) -> bool:
	if not nodo_disponibile(id_nodo):
		return false
	nodi_abilita.append(id_nodo)
	return true

func grado_di_linea(linea: String) -> int:
	# a che punto sei di una linea. Zero vuol dire che non l'hai ancora aperta
	var massimo := 0
	for id_nodo in abilita_del_protagonista():
		var dati := abilita_combattimento(id_nodo)
		if String(dati.get("linea", "")) == linea:
			massimo = maxi(massimo, int(dati.get("grado", 1)))
	return massimo

func abilita_del_protagonista() -> Array[String]:
	# tutto quello che sa fare: quelle scritte nella sua classe, quelle che il
	# livello gli ha dato da solo, e quelle che ha comprato coi punti
	var elenco: Array[String] = []
	for id_abilita in classi.get(id_protagonista, {}).get("abilita", []):
		if not String(id_abilita) in elenco:
			elenco.append(String(id_abilita))
	var livello := livello_di(id_protagonista)
	for id_abilita in abilita.get("abilita", {}):
		var dati := abilita_combattimento(String(id_abilita))
		var suo_livello := int(dati.get("livello", 0))
		if suo_livello <= 0 or String(id_abilita) in elenco:
			continue
		var arriva_da_sola := int(dati.get("costo", 0)) <= 0
		if arriva_da_sola and livello >= suo_livello:
			elenco.append(String(id_abilita))
		elif nodo_gia_preso(String(id_abilita)):
			elenco.append(String(id_abilita))
	return elenco

func abilita_usabili(id_classe: String) -> Array[String]:
	# QUELLO CHE COMPARE NEL MENU. Di una linea si vede un grado solo, il piu'
	# alto: Terra bruciata prende il posto di Flagello invece di stargli
	# accanto, altrimenti dopo cinque potenziamenti il menu sarebbe una lista di
	# sei versioni della stessa cosa
	if id_classe != id_protagonista:
		var altrui: Array[String] = []
		for id_abilita in classi.get(id_classe, {}).get("abilita", []):
			altrui.append(String(id_abilita))
		return altrui
	var migliore := {}   # linea -> [grado, id]
	var senza_linea: Array[String] = []
	for id_abilita in abilita_del_protagonista():
		var dati := abilita_combattimento(id_abilita)
		var linea := String(dati.get("linea", ""))
		if linea == "":
			senza_linea.append(id_abilita)
			continue
		var grado := int(dati.get("grado", 1))
		if not migliore.has(linea) or grado > int(migliore[linea][0]):
			migliore[linea] = [grado, id_abilita]
	for linea in migliore:
		senza_linea.append(String(migliore[linea][1]))
	return senza_linea

# --- le armi portano i loro attacchi ----------------------------------------

func classe_arma_di(id_classe: String) -> String:
	# che tipo di arma sa impugnare questo personaggio
	for nome_classe in abilita.get("classi_arma", {}):
		if id_classe in abilita["classi_arma"][nome_classe].get("usata_da", []):
			return String(nome_classe)
	return ""

func puo_impugnare(id_classe: String, id_arma: String) -> bool:
	# un'arma senza classe la impugna chiunque (le vecchie armi del gioco);
	# altrimenti deve essere della classe di quel personaggio
	var richiesta := String(dati_oggetto(id_arma).get("classe_arma", ""))
	return richiesta == "" or richiesta == classe_arma_di(id_classe)

func attacchi_arma(id_classe: String) -> Array[Dictionary]:
	# GLI ATTACCHI CHE COMPAIONO PERCHE' HAI QUELL'ARMA IN MANO.
	#
	# Bru: "ogni arma equipaggiata fara' comparire una serie di attacchi
	# collegati all'arma in se'". Quindi cambiare arma non cambia solo un
	# numero: cambia cosa puoi fare. Il danno di ognuno e' l'attacco base del
	# personaggio piu' il bonus che l'arma da' a QUELL'attacco, e il bonus e'
	# scritto sull'arma perche' e' dell'arma che stiamo parlando.
	var elenco: Array[Dictionary] = []
	var id_arma := String(slot_di(id_classe).get("arma", ""))
	if id_arma == "" or not puo_impugnare(id_classe, id_arma):
		return elenco
	for attacco in dati_oggetto(id_arma).get("attacchi", []):
		if attacco is Dictionary:
			var voce: Dictionary = (attacco as Dictionary).duplicate()
			voce["arma"] = id_arma
			elenco.append(voce)
	return elenco

func bonus_da_potenziamenti(nome_stat: String) -> int:
	var totale := 0
	for id_nodo in nodi_abilita:
		var dati: Variant = abilita.get("potenziamenti", {}).get(id_nodo, {})
		if dati is Dictionary and String(dati.get("stat", "")) == nome_stat:
			totale += int(dati.get("quanto", 0))
	return totale

func party_ha_abilita(cercata: String) -> bool:
	for id_classe in party:
		if cercata in classi.get(id_classe, {}).get("abilita", []):
			return true
	return false

func livello_di(id_classe: String) -> int:
	return int(livelli.get(id_classe, 1))

# --- quanto e' forte una creatura ADESSO ---
#
# Il mondo non ti aspetta fermo. Un dominatore porta addosso il fattore
# Carnivalz, e il disallineamento si nutre di quello: piu' sei forte tu, piu'
# forte diventa cio' che ti viene incontro. Non e' un livellamento
# amministrativo per non annoiare il giocatore - e' letteralmente il motore del
# mondo, ed e' anche il motivo per cui zone diverse hanno creature diverse:
# vicino a una fonte potente vive roba potente.
#
# In pratica: nessuna creatura scende mai piu' di "scarto_livello_massimo"
# livelli sotto di te. Puo' stare sopra quanto vuole - il goblin arrabbiato del
# tutorial resta il macellaio che deve essere - ma non sotto. Un posto
# rivisitabile non diventa mai un campo di grano da falciare.
#
# Chi non scala:
#   - "incontro_scriptato": scene, non scontri. I loro numeri sono battute
#   - "scala_col_giocatore": false, per chi deve restare esattamente com'e'
#     (la Tartaruga Innocente non diventa un mostro perche' sei salito di livello)

func scarto_livello_massimo() -> int:
	return int(regole.get("scarto_livello_massimo", 3))

func e_boss(id_nemico: String) -> bool:
	var dati: Dictionary = personaggi.get(id_nemico, {})
	return bool(dati.get("fonte", false)) or String(dati.get("categoria", "")) == "boss" \
			or dati.has("frenesia")

func scarto_di(id_nemico: String) -> int:
	# Un boss non si supera farmando. Le creature comuni restano al massimo tre
	# livelli sotto di te, e va bene: sono il paesaggio, e un paesaggio che si
	# attraversa piu' in fretta e' una ricompensa. Una fonte no: quella e' il
	# motivo per cui sei li'. Se farmando la si potesse rendere una formalita',
	# lo scontro che dovrebbe essere il punto della zona diventerebbe la sua
	# parte piu' noiosa. Le fonti stanno SEMPRE almeno al tuo livello.
	return int(regole.get("scarto_livello_boss", 0)) if e_boss(id_nemico) \
			else scarto_livello_massimo()

func livello_base_nemico(id_nemico: String) -> int:
	return maxi(int(personaggi.get(id_nemico, {}).get("livello", 1)), 1)

func nemico_scala(id_nemico: String) -> bool:
	var dati: Dictionary = personaggi.get(id_nemico, {})
	if dati.is_empty() or dati.has("incontro_scriptato"):
		return false
	return bool(dati.get("scala_col_giocatore", true))

func livello_nemico(id_nemico: String) -> int:
	var base := livello_base_nemico(id_nemico)
	if not nemico_scala(id_nemico):
		return base
	var pavimento := livello_di(id_protagonista) - scarto_di(id_nemico)
	return clampi(maxi(base, pavimento), 1, int(regole.get("livello_massimo", 130)))

func e_creatura(id_personaggio: String) -> bool:
	# ha un ruolo che combatte. Chi parla e basta non ha ruolo; un oggetto di
	# scena (le lettere sull'altare) ce l'ha ma non e' un nemico: sta in campo
	# per essere colpito, non va nel bestiario e non vale niente
	var ruolo := String(personaggi.get(id_personaggio, {}).get("ruolo", ""))
	return ruolo != "" and ruolo != "oggetto_scena"

func mediazione_di(id_personaggio: String) -> Dictionary:
	# CHI ASCOLTA, e a quali condizioni. Un dizionario vuoto vuol dire che questa
	# creatura non media mai: e' la sua natura, non un tiro andato male.
	#
	# La lettura sta qui e non sparsa nei file perche' i posti che se lo chiedono
	# sono cinque - il menu, il motore, la scheda in campo, il simulatore e le
	# prove - e finche' esiste il vecchio nome "risparmio" nei dati, tutti e
	# cinque devono ricadere sullo stesso ripiego o si contraddicono a vicenda
	var dati: Dictionary = personaggi.get(id_personaggio, {})
	return dati.get("mediazione", dati.get("risparmio", {}))

func e_da_bestiario(id_personaggio: String) -> bool:
	# COMBATTERE E FINIRE NEL BESTIARIO SONO DUE COSE DIVERSE, e le abbiamo
	# scoperte separate il giorno in cui Veronica e' diventata una dominatrice.
	# Lei combatte - il tutorial la usa - ma Bru: "Veronica non necessita di un
	# entry nel bestiario ma di un entry nella sezione dei dominatori". Con una
	# funzione sola per tutte e due le domande sarebbe rimasta nel Bestiario con
	# una scheda vuota, perche' la sua voce di tecno log non c'e' piu': una
	# pagina di "non ancora rilevato" per una persona che conosci da bambino
	return e_creatura(id_personaggio) \
			and not personaggi.get(id_personaggio, {}).get("dominatore", false)

func stat_eroe_tipo(chiave: String, livello: int) -> float:
	# QUANTO VALE DAVVERO IL PROTAGONISTA AL LIVELLO N.
	#
	# Non "quanto varrebbe se il livello desse le stat": in Carnivalz il livello
	# non le da', le stat salgono con quello che hai fatto (crescita.json). Qui
	# si rifa' il conto che fa il gioco - stat base piu' i punti guadagnati -
	# partendo dalla stima di quante volte uno compie ogni azione per livello
	# (profilo_giocatore_tipo). E' la stessa stima che usa il giocatore
	# automatico, letta dallo stesso posto: se stesse in due posti, prima o poi
	# direbbero due cose diverse.
	var punti := 0
	var profilo: Dictionary = crescita.get("profilo_giocatore_tipo", {})
	for nome_azione in crescita.get("crescita", {}):
		var regola: Dictionary = crescita["crescita"][nome_azione]
		if String(regola.get("stat", "")) != chiave:
			continue
		var ogni := maxi(int(regola.get("ogni", 1)), 1)
		var fatte := int(profilo.get(nome_azione, 0)) * maxi(livello - 1, 0)
		punti += (fatte / ogni) * int(regola.get("punti", 1))
	return float(stat_base_di(chiave) + punti)

func scontri_per_livello(livello: int) -> float:
	# quante creature comuni del tuo livello per guadagnare un livello
	var ritmo: Dictionary = ruoli.get("scontri_per_livello", {})
	var quanti := float(ritmo.get("base", 5.0)) + float(ritmo.get("passo", 0.35)) * float(maxi(livello - 1, 0))
	return maxf(quanti, 1.0)

func xp_di_riferimento(livello: int) -> float:
	# l'esperienza di una creatura comune a quel livello: non un numero scelto,
	# ma il fabbisogno del livello diviso per quanti scontri vogliamo che costi
	return float(fabbisogno_xp(livello)) / scontri_per_livello(livello)

func stat_di_ruolo(id_nemico: String, chiave: String, a_livello := 0) -> int:
	# DA DOVE ESCONO I NUMERI DI UNA CREATURA.
	#
	# Non stanno piu' scritti uno per uno: escono dal livello a cui la creatura
	# sta e dal ruolo che ha. E il riferimento non e' una tabella a parte, e' il
	# PROTAGONISTA a quel livello (stat_eroe_tipo): la creatura vale una quota
	# di lui. Cosi' le due curve non possono divergere di nascosto mentre si
	# aggiunge contenuto, perche' non sono due curve - e' una sola, guardata da
	# due parti. Ricalibrare il gioco intero e' cambiare una riga di ruoli.json.
	#
	# Una creatura puo' comunque scrivere il numero a mano: quello vince. Ma e'
	# un'eccezione dichiarata, non un numero fra gli altri, e prova_curva_creature
	# pretende che dica anche perche' (campo "fuori_curva").
	var dati: Dictionary = personaggi.get(id_nemico, {})
	var ruolo: Dictionary = ruoli.get("ruoli", {}).get(String(dati.get("ruolo", "comune")), {})
	if ruolo.is_empty():
		return 0
	var curva: Dictionary = ruoli.get("curva", {})
	# a_livello < 1 vuol dire "al suo livello": chi la tira su per il
	# disallineamento passa il livello a cui si trova adesso
	var livello := maxi(livello_base_nemico(id_nemico), 1) if a_livello < 1 else a_livello
	var quanto := float(ruolo.get(chiave, 1.0))
	match chiave:
		"hp":
			return maxi(int(round(stat_eroe_tipo("hp", livello) * float(curva.get("quota_hp", 1.05)) * quanto)), 1)
		"attacco":
			# la deriva: quanto il gioco si fa piu' duro andando avanti, oltre
			# alla semplice crescita dei numeri. Una manopola sola
			var deriva := 1.0 + float(ruoli.get("deriva_attacco_per_livello", 0.0)) * float(livello - 1)
			return maxi(int(round(stat_eroe_tipo("attacco", livello)
					* float(curva.get("quota_attacco", 0.29)) * quanto * deriva)), 0)
		"difesa":
			# il protagonista al livello 1 non ha difesa: se la guadagna parando.
			# Le creature una corazza ce l'hanno gia' addosso
			var d := float(curva.get("difesa_base", 1.0)) + stat_eroe_tipo("difesa", livello)
			return maxi(int(round(d * quanto)), 0)
		"velocita":
			if quanto <= 0.0:
				return 0
			return maxi(int(round(stat_eroe_tipo("velocita", livello)
					* float(curva.get("quota_velocita", 1.0)) * quanto)), 1)
		"xp":
			if quanto <= 0.0:
				return 0
			return maxi(int(round(xp_di_riferimento(livello) * quanto)), 1)
		"tazo":
			# i soldi non seguono l'esperienza: l'esperienza insegue un
			# fabbisogno che cresce come livello^1.5, i soldi inseguono un
			# negozio con i prezzi fermi. Due domande diverse, due curve diverse
			if quanto <= 0.0:
				return 0
			var soldi: Dictionary = ruoli.get("tazo", {})
			return maxi(int(round((float(soldi.get("base", 1.8))
					+ float(soldi.get("per_livello", 1.15)) * float(livello - 1)) * quanto)), 1)
	return 0

func stat_base_nemico(id_nemico: String, chiave: String, difetto := 0) -> int:
	# il numero al suo livello base: scritto a mano se c'e', altrimenti dedotto
	var dati: Dictionary = personaggi.get(id_nemico, {})
	if dati.has(chiave):
		return int(dati[chiave])
	return stat_di_ruolo(id_nemico, chiave) if dati.has("ruolo") else difetto

func stat_nemico(id_nemico: String, chiave: String, difetto := 0) -> int:
	# QUANTO VALE UNA CREATURA ADESSO, tirata su dal disallineamento.
	#
	# Qui c'era una percentuale fissa per ogni livello di scarto (+13% di hp e
	# attacco), e faceva una cosa che nessuno aveva mai misurato perche' il
	# simulatore non guardava sopra il livello 8: I BOSS DIVENTAVANO PIU'
	# DIFFICILI MAN MANO CHE SALIVI. Dal livello 18 al 25 il protagonista cresce
	# di 1,2 volte, un nemico livellato col +13% cresceva di 1,5. Misurato:
	# Jerah si vinceva il 100% delle volte al livello 18 e il 29% al 25.
	#
	# Adesso una creatura tirata su non e' "la sua stat base piu' una
	# percentuale": e' la stat che ha una creatura del suo ruolo A QUEL
	# LIVELLO, presa dalla stessa curva di tutte le altre - che e' agganciata al
	# protagonista. Quindi salire di livello non puo' piu' peggiorare la tua
	# situazione, per costruzione.
	var dati: Dictionary = personaggi.get(id_nemico, {})
	var livello := livello_nemico(id_nemico)
	var salto := livello - livello_base_nemico(id_nemico)
	if not dati.has(chiave) and dati.has("ruolo"):
		return stat_di_ruolo(id_nemico, chiave, livello)
	# le eccezioni scritte a mano stanno fuori dalla curva per scelta: per loro
	# resta la vecchia crescita percentuale, perche' non c'e' nessuna curva da
	# cui ricalcolarle
	var base := stat_base_nemico(id_nemico, chiave, difetto)
	if salto <= 0 or base <= 0:
		return base
	var per_livello: Dictionary = regole.get("crescita_nemico_per_livello", {})
	var passo := float(per_livello.get(chiave, 0.0))
	if passo <= 0.0:
		return base
	return maxi(int(round(base * (1.0 + passo * salto))), base)

func stress_di(id_classe: String) -> int:
	return int(stress.get(id_classe, 0))

func modifica_stress(id_classe: String, quantita: int) -> void:
	stress[id_classe] = clampi(stress_di(id_classe) + quantita, 0, 100)

func modifica_legame(quantita: int) -> void:
	legame = clampi(legame + quantita, 0, 100)

func modifica_tazo(quantita: int) -> void:
	tazo = maxi(tazo + quantita, 0)

func dati_oggetto(id_oggetto: String) -> Dictionary:
	return oggetti.get(id_oggetto, {})

# --- la pila: dove finisce quello che i nemici lasciano cadere ---------------
#
# Bru: "un'altra sezione dell'inventario dove finiscono i drop comuni dei vari
# nemici, che sono solo vendibili o scambiabili e non hanno altra funzione".
#
# E' uno scomparto a parte apposta: se la roba da vendere finisse nella sacca,
# ogni scontro riempirebbe lo spazio dei consumabili e il giocatore passerebbe
# la partita a buttare via cose invece che a combattere. Qui invece si accumula
# e basta - e' quello il piacere. Non e' una lista come gli altri scomparti ma
# un conto per tipo: novecentonovantanove cianfrusaglie sono un numero, non
# novecentonovantanove voci.

func drop_garantito_di(id_nemico: String) -> Dictionary:
	# COSA LASCIA SEMPRE QUESTA CREATURA. Ritorna {"tipo": "tazo"|"oggetto",
	# "oggetto": id, "quanti": n} - mai vuoto per una creatura che combatte.
	#
	# Bru: "il drop deve sempre esserci, ogni nemico droppa qualcosa di suo".
	# Un nemico che non lascia niente e' un nemico che non valeva la pena
	# affrontare; dieci di fila cosi' e non si combatte piu' volentieri. Quindi
	# qui non c'e' nessun ramo che ritorna "niente".
	var dati: Dictionary = personaggi.get(id_nemico, {})
	if dati.has("drop_garantito"):
		# quello che la creatura dichiara di suo vince: e' il posto dove darle
		# una cosa che lasciano solo lei e i suoi simili
		var suo: Dictionary = dati["drop_garantito"]
		return {"tipo": "oggetto", "oggetto": String(suo.get("oggetto", "cianfrusaglia")),
				"quanti": maxi(int(suo.get("quanti", 1)), 1)}
	var ruolo := String(dati.get("ruolo", ""))
	var pesi: Dictionary = ruoli.get("drop_garantito", {}).get(ruolo, {})
	var totale := 0
	for chiave in pesi:
		if not String(chiave).begins_with("_"):
			totale += int(pesi[chiave])
	if totale <= 0:
		return {}
	var tiro := rng.randi_range(1, totale)
	var scelto := "cianfrusaglia"
	for chiave in pesi:
		if String(chiave).begins_with("_"):
			continue
		tiro -= int(pesi[chiave])
		if tiro <= 0:
			scelto = String(chiave)
			break
	if scelto == "tazo":
		var quanto := int(round(stat_nemico(id_nemico, "tazo")
				* float(ruoli.get("quota_tazo_garantito", 0.35))))
		return {"tipo": "tazo", "quanti": maxi(quanto, 1)}
	return {"tipo": "oggetto", "oggetto": scelto, "quanti": 1}

func cap_pila(id_oggetto: String) -> int:
	var dichiarato := int(dati_oggetto(id_oggetto).get("cap", 0))
	if dichiarato > 0:
		return dichiarato
	return int(regole.get("pila_cap_predefinito", 99))

func quanti_nella_pila(id_oggetto: String) -> int:
	return int(pila.get(id_oggetto, 0))

func aggiungi_alla_pila(id_oggetto: String, quanti := 1) -> int:
	# ritorna quanti ne sono entrati davvero: al tetto, il resto si perde e chi
	# chiama puo' dirlo
	if quanti <= 0 or not oggetti.has(id_oggetto):
		return 0
	cataloga_oggetto(id_oggetto)
	var prima := quanti_nella_pila(id_oggetto)
	var dopo := mini(prima + quanti, cap_pila(id_oggetto))
	pila[id_oggetto] = dopo
	return dopo - prima

func togli_dalla_pila(id_oggetto: String, quanti := 1) -> int:
	var prima := quanti_nella_pila(id_oggetto)
	var tolti := mini(quanti, prima)
	if tolti <= 0:
		return 0
	if prima - tolti <= 0:
		pila.erase(id_oggetto)
	else:
		pila[id_oggetto] = prima - tolti
	return tolti

func e_da_pila(id_oggetto: String) -> bool:
	return String(dati_oggetto(id_oggetto).get("tipo", "")) == "pila"

func categoria_zaino(id_oggetto: String) -> String:
	# in quale scomparto finisce un oggetto. "" = non sta nello zaino
	match String(dati_oggetto(id_oggetto).get("tipo", "consumabile")):
		"arma":
			return "armi"
		"accessorio":
			return "accessori"
		"consumabile":
			return "consumabili"
		"stigma", "collezionabile", "chiave":
			return "speciali"
	return "consumabili"

func contenuto_zaino(categoria: String) -> Array:
	match categoria:
		"armi":
			return armi
		"accessori":
			return accessori
		"consumabili":
			return sacca
		"speciali":
			return oggetti_speciali
	return sacca

func spazi_comprati(categoria: String) -> int:
	return int(spazi_zaino.get(categoria, 0))

func capacita_zaino(categoria: String) -> int:
	# -1 = nessun limite (gli oggetti speciali). Le tabelle in regole.json danno
	# la capacita' TOTALE a ogni acquisto, non l'incremento: cosi' i numeri nel
	# file sono gli stessi che il giocatore legge al negozio
	if categoria == "speciali":
		return -1
	var dati: Dictionary = regole.get("zaino", {}).get(categoria, {})
	if dati.is_empty():
		return int(regole.get("sacca_massima", 20))
	var scala: Array = dati.get("scala", [])
	var comprati := mini(spazi_comprati(categoria), scala.size())
	if comprati <= 0:
		return int(dati.get("base", 20))
	return int(scala[comprati - 1])

func spazio_libero(categoria: String) -> int:
	var tetto := capacita_zaino(categoria)
	if tetto < 0:
		return 9999
	return maxi(tetto - contenuto_zaino(categoria).size(), 0)

func compra_spazio(categoria: String) -> bool:
	# un "spazio nella realta'" (o un frammento) allarga per sempre uno scomparto
	var scala: Array = regole.get("zaino", {}).get(categoria, {}).get("scala", [])
	if spazi_comprati(categoria) >= scala.size():
		return false   # oltre l'ultimo gradino non si compra piu' niente
	spazi_zaino[categoria] = spazi_comprati(categoria) + 1
	return true

func aggiungi_oggetto(id_oggetto: String) -> bool:
	cataloga_oggetto(id_oggetto)  # la voce nel compendio appare al primo possesso
	var tipo := String(dati_oggetto(id_oggetto).get("tipo", "consumabile"))
	if tipo == "spazio":
		# uno "spazio nella realta'" non entra nello zaino: LO ALLARGA. E' l'unico
		# acquisto che non ti lascia niente in mano, e l'unico che non finisce mai
		# in mezzo alle cose da amministrare
		return compra_spazio(String(dati_oggetto(id_oggetto).get("categoria", "consumabili")))
	if tipo == "pila":
		# non entra nello zaino: si accumula nella pila, e li' non c'e' niente
		# da amministrare
		return aggiungi_alla_pila(id_oggetto) > 0
	var categoria := categoria_zaino(id_oggetto)
	# gli scomparti a tetto lo rispettano; gli speciali no, per definizione
	if capacita_zaino(categoria) >= 0 and spazio_libero(categoria) <= 0:
		return false
	match tipo:
		"collezionabile":
			collezionabili.append(id_oggetto)
			oggetti_speciali.append(id_oggetto)
		"chiave":
			if id_oggetto in chiavi:
				return true
			chiavi.append(id_oggetto)
			oggetti_speciali.append(id_oggetto)
		"stigma":
			if id_oggetto in oggetti_speciali:
				return true
			oggetti_speciali.append(id_oggetto)
		"arma":
			if id_oggetto in armi:
				return true
			armi.append(id_oggetto)
		"accessorio":
			if id_oggetto not in accessori:
				accessori.append(id_oggetto)
			# un accessorio nuovo si mette addosso al protagonista da solo, se
			# ha ancora uno slot libero: "avere" la Pietra Quieta deve bastare
			# a proteggerti, senza passare per una schermata
			if id_protagonista != "" and not e_equipaggiato(id_oggetto):
				equipaggia(id_protagonista, "accessori", id_oggetto)
		_:
			sacca.append(id_oggetto)
	return true

# --- equipaggiamento: un solo accessorio alla volta, effetto passivo in
# combattimento (Combattimento._ready() legge accessorio_equipaggiato) ---

func slot_di(id_classe: String) -> Dictionary:
	# gli slot di un personaggio, creati alla prima richiesta
	if not equipaggiamento.has(id_classe):
		equipaggiamento[id_classe] = {
			"arma": "", "stigma": "", "ultima_risorsa": "", "accessori": [],
		}
	return equipaggiamento[id_classe]

func equipaggiato_in(id_classe: String, slot: String, indice := 0) -> String:
	var slots := slot_di(id_classe)
	if slot == "accessori":
		var elenco: Array = slots["accessori"]
		return String(elenco[indice]) if indice < elenco.size() else ""
	return String(slots.get(slot, ""))

func e_equipaggiato(id_oggetto: String) -> bool:
	# un oggetto solo puo' stare addosso a una persona sola alla volta
	for id_classe in equipaggiamento:
		var slots: Dictionary = equipaggiamento[id_classe]
		for slot in SLOT_SINGOLI:
			if String(slots.get(slot, "")) == id_oggetto:
				return true
		if id_oggetto in slots.get("accessori", []):
			return true
	return false

func portatore_di(id_oggetto: String) -> String:
	for id_classe in equipaggiamento:
		var slots: Dictionary = equipaggiamento[id_classe]
		for slot in SLOT_SINGOLI:
			if String(slots.get(slot, "")) == id_oggetto:
				return String(id_classe)
		if id_oggetto in slots.get("accessori", []):
			return String(id_classe)
	return ""

func e_definitivo(id_classe: String) -> bool:
	# Chi ti accompagna per un tratto non e' ancora dei tuoi. Un compagno
	# temporaneo combatte al tuo fianco ma non gli si da' niente da tenere: le
	# tue cose gliele affidi solo quando resta.
	return id_classe not in alleati_temporanei

func equipaggia(id_classe: String, slot: String, id_oggetto: String) -> bool:
	# il tipo dell'oggetto deve combaciare con lo slot, e lo stesso oggetto non
	# puo' stare addosso a due persone: prima si toglie da dove sta
	if not e_definitivo(id_classe):
		return false   # e' con te per un tratto: non gli si affida niente
	if id_oggetto == "" or not posseduto_equipaggiabile(id_oggetto):
		return false
	var tipo := String(dati_oggetto(id_oggetto).get("tipo", ""))
	if slot == "ultima_risorsa":
		if tipo != "consumabile":
			return false
	elif slot == "accessori":
		if tipo != "accessorio":
			return false
	elif tipo != slot:
		return false
	var vecchio_portatore := portatore_di(id_oggetto)
	if vecchio_portatore != "":
		togli_oggetto_equipaggiato(id_oggetto)
	var slots := slot_di(id_classe)
	if slot == "accessori":
		var elenco: Array = slots["accessori"]
		if elenco.size() >= slot_accessori_di(id_classe):
			return false
		elenco.append(id_oggetto)
	else:
		slots[slot] = id_oggetto
	return true

# --- quanti accessori puo' portare uno ---------------------------------------
#
# Non e' un numero uguale per tutti e non e' fisso nel tempo. Si parte con UNO
# slot solo: all'inizio del gioco decidere cosa portare deve essere una scelta,
# non un modulo da riempire. Salendo di livello se ne apre uno alla volta
# (slot_accessori_per_livello in regole.json).
#
# Due classi ne hanno di piu' per un talento loro, dichiarato tra le loro
# abilita' e pagato in regole.json (slot_accessori_da_abilita): Bero ne ha uno
# in piu' per gli innesti, Rio ne ha quattro in piu' perche' colleziona - e
# arriva a otto, che e' il suo modo di essere forte.

func slot_accessori_di(id_classe: String) -> int:
	var totale := int(regole.get("slot_accessori_base", 1))
	var livello := livello_di(id_classe)
	for soglia in regole.get("slot_accessori_per_livello", []):
		if livello >= int(soglia):
			totale += 1
	totale += slot_accessori_da_talento(id_classe)
	return maxi(totale, 1)

func slot_accessori_da_talento(id_classe: String) -> int:
	var tabella: Dictionary = regole.get("slot_accessori_da_abilita", {})
	var extra := 0
	for nome_abilita in classi.get(id_classe, {}).get("abilita", []):
		extra += int(tabella.get(String(nome_abilita), 0))
	return extra

func livello_slot_accessorio(indice: int) -> int:
	# a che livello si apre l'accessorio numero <indice> (0 = il primo).
	# 0 = aperto da sempre, -1 = non si apre col livello (viene da un talento)
	var base := int(regole.get("slot_accessori_base", 1))
	if indice < base:
		return 0
	var soglie: Array = regole.get("slot_accessori_per_livello", [])
	var passo := indice - base
	return int(soglie[passo]) if passo < soglie.size() else -1

func talento_dello_slot(id_classe: String, indice: int) -> String:
	# quale talento ha aperto questo slot, se e' stato un talento. Serve alla
	# schermata del personaggio: uno slot in piu' che compare senza spiegazione
	# e' un premio che non si capisce di aver vinto
	var soglie: Array = regole.get("slot_accessori_per_livello", [])
	var da_livello: int = int(regole.get("slot_accessori_base", 1)) + soglie.size()
	if indice < da_livello or slot_accessori_da_talento(id_classe) <= 0:
		return ""
	var tabella: Dictionary = regole.get("slot_accessori_da_abilita", {})
	for nome_abilita in classi.get(id_classe, {}).get("abilita", []):
		if int(tabella.get(String(nome_abilita), 0)) > 0:
			return String(nome_abilita)
	return ""

func togli_oggetto_equipaggiato(id_oggetto: String) -> void:
	for id_classe in equipaggiamento:
		var slots: Dictionary = equipaggiamento[id_classe]
		for slot in SLOT_SINGOLI:
			if String(slots.get(slot, "")) == id_oggetto:
				slots[slot] = ""
		var elenco: Array = slots.get("accessori", [])
		elenco.erase(id_oggetto)

func posseduto_equipaggiabile(id_oggetto: String) -> bool:
	return id_oggetto in armi or id_oggetto in accessori \
			or id_oggetto in oggetti_speciali or id_oggetto in sacca

func magazzino_per_slot(slot: String) -> Array:
	# da dove pescano gli slot della scheda personaggio e del negozio
	match slot:
		"arma":
			return armi
		"accessori":
			return accessori
		"stigma":
			return oggetti_speciali
		"ultima_risorsa":
			return sacca
	return accessori

func aura_massima(id_classe: String) -> int:
	# l'aura di base e' uguale per tutti; una classe puo' avercene di piu' nei
	# suoi dati, e l'equipaggiamento la sposta ancora
	var classe: Dictionary = classi.get(id_classe, {})
	var base := int(classe.get("aura", regole.get("aura_iniziale", 10)))
	return maxi(base + bonus_equipaggiamento(id_classe, "aura_max"), 0)

func bonus_oggetto(id_oggetto: String, chiave: String) -> int:
	# quanto da' (o toglie) un oggetto da solo, senza guardare chi lo porta.
	# Serve a confrontare due oggetti senza metterli addosso a nessuno
	if id_oggetto == "":
		return 0
	return int(dati_oggetto(id_oggetto).get("effetto_equipaggiato", {}).get(chiave, 0))

func bonus_equipaggiamento(id_classe: String, chiave: String) -> int:
	# somma di quello che danno arma, stigma e accessori addosso a quel
	# personaggio. I malus degli stigmi entrano nella stessa somma: un patto
	# non e' un bonus con l'asterisco, e' una somma che puo' venire negativa
	var totale := 0
	var slots := slot_di(id_classe)
	var addosso: Array[String] = []
	for slot in ["arma", "stigma"]:
		var id_oggetto := String(slots.get(slot, ""))
		if id_oggetto != "":
			addosso.append(id_oggetto)
	for id_oggetto in slots.get("accessori", []):
		addosso.append(String(id_oggetto))
	for id_oggetto in addosso:
		var effetto: Dictionary = dati_oggetto(id_oggetto).get("effetto_equipaggiato", {})
		totale += int(effetto.get(chiave, 0))
	return totale

func consuma_equipaggiato(id_oggetto: String) -> void:
	# l'oggetto si rompe usando il suo effetto: esce dagli slot e dall'armadio
	togli_oggetto_equipaggiato(id_oggetto)
	armi.erase(id_oggetto)
	accessori.erase(id_oggetto)
	oggetti_speciali.erase(id_oggetto)
	sacca.erase(id_oggetto)

# --- collezioni (album carte, bestiario, compendio oggetti) ---

func cataloga_oggetto(id_oggetto: String) -> void:
	if oggetti.has(id_oggetto) and id_oggetto not in oggetti_catalogo:
		oggetti_catalogo.append(id_oggetto)

func registra_bestiario(id_nemico: String) -> void:
	if personaggi.has(id_nemico) and id_nemico not in bestiario:
		bestiario.append(id_nemico)

# --- IL TECNO LOG: la scheda di specie che lo Studio riempie ------------------
#
# Bru: "dobbiamo riformulare lo studio, che deve dare questi aspetti di
# descrizione della specie: filogenesi ovvero il corpo d'origine - nel caso
# degli zombie ci possono essere zombie umani, animali...".
#
# Studiare non e' piu' solo una battuta di dialogo e due numeri sulla scheda:
# e' una pagina che si riempie a strati, uno per studio. Il primo dice chi e' e
# da dove viene, il secondo com'e' fatto, il terzo come si comporta - e resta
# nel Bestiario, che da elenco di nomi diventa un archivio.
#
# TRE CAMPI NON SI SCRIVONO A MANO SE NON SERVE. La Denominazione e' il nome
# della creatura; la Metamorfosi dice "osservata" solo se hai incontrato anche la
# forma in cui si trasforma - e' il tuo registro, non un'enciclopedia; l'Areale
# esce da dove la creatura compare davvero nei file delle zone, tradotto in
# REGIONE GRANDE dalla tabella tecnolog.areale_per_zona. Un campo scritto a mano
# che ripete un dato che il gioco gia' conosce e' un campo che prima o poi dira'
# una bugia - ma l'areale accetta la mano, perche' dove una specie VIVE puo'
# essere piu' grande di dove il gioco ti porta a incontrarla.

var _areali: Dictionary = {}          # id creatura -> Array[String] di regioni
var _areali_costruiti := false

func campi_tecnolog() -> Array:
	return tecnolog.get("campi", [])

func strati_tecnolog() -> int:
	var massimo := 1
	for campo in campi_tecnolog():
		massimo = maxi(massimo, int(campo.get("strato", 1)))
	return massimo

func costruisci_areali() -> void:
	# si legge una volta sola, alla prima domanda: sono otto file, e nessuno
	# chiede l'areale prima di aver studiato qualcosa
	if _areali_costruiti:
		return
	_areali_costruiti = true
	var zone: Dictionary = {}   # percorso file -> id della zona
	raccogli_zone(carica_json(PERCORSO_MAPPA), zone)
	zone["res://data/events_tutorial.json"] = "tutorial"
	var per_zona: Dictionary = tecnolog.get("areale_per_zona", {})
	for percorso in zone:
		var dati: Variant = carica_json(String(percorso))
		if dati == null:
			continue
		# LA REGIONE GRANDE, NON LA STANZA. Bru: "l'areale non e' la zona
		# specifica ma quella generica: l'Oppresso si trova nella frattura
		# industriale, che e' solo una parte del pianeta Geodos". La traduzione
		# sta in un posto solo (tecnolog.areale_per_zona), quindi ribattezzare un
		# mondo e' una riga - e una zona che non e' nella tabella si fa notare,
		# perche' c'e' una prova che le pretende tutte
		var regione := String(per_zona.get(String(zone[percorso]), String(zone[percorso])))
		var trovate: Array[String] = []
		cerca_creature(dati, trovate)
		for id_creatura in trovate:
			var elenco: Array = _areali.get(id_creatura, [])
			if regione not in elenco:
				elenco.append(regione)
			_areali[id_creatura] = elenco

func raccogli_zone(nodo: Variant, dentro: Dictionary) -> void:
	if nodo is Dictionary:
		if nodo.has("file_eventi") and nodo.has("nome") and String(nodo["file_eventi"]) != "":
			# la voce senza file e' un posto annunciato e non ancora scritto
			# (una frattura che si aprira'): non c'e' niente da leggere
			dentro[String(nodo["file_eventi"])] = String(nodo.get("id", nodo["nome"]))
		for chiave in nodo:
			raccogli_zone(nodo[chiave], dentro)
	elif nodo is Array:
		for voce in nodo:
			raccogli_zone(voce, dentro)

func cerca_creature(nodo: Variant, dentro: Array[String]) -> void:
	# le creature di una stanza stanno in "combatti" (o "nemici", la forma
	# vecchia), quelle degli agguati in "gruppi". Tre chiavi, e un solo posto che
	# le conosce - la prima versione ne guardava due e lasciava senza areale
	# meta' bestiario, boss compresi
	if nodo is Dictionary:
		for chiave in nodo:
			if String(chiave) in ["nemici", "combatti"] and nodo[chiave] is Array:
				for id_creatura in nodo[chiave]:
					if String(id_creatura) not in dentro:
						dentro.append(String(id_creatura))
			elif String(chiave) == "gruppi" and nodo[chiave] is Array:
				for gruppo in nodo[chiave]:
					if gruppo is Array:
						for id_creatura in gruppo:
							if String(id_creatura) not in dentro:
								dentro.append(String(id_creatura))
			else:
				cerca_creature(nodo[chiave], dentro)
	elif nodo is Array:
		for voce in nodo:
			cerca_creature(voce, dentro)

func areale_di(id_creatura: String) -> String:
	# La mano vince sulla mappa, e non e' un'incoerenza: dove la incontri e' un
	# fatto di gioco, dove VIVE e' un fatto di mondo. Lo Slime lo trovi in una
	# radura del tutorial ed e' su tre pianeti; se scrivessimo solo quello che il
	# gioco tocca, la scheda racconterebbe il livello invece della specie
	var scritto: Variant = tecnolog.get("voci", {}).get(id_creatura, {}).get("areale", null)
	if scritto is Array and not (scritto as Array).is_empty():
		return " · ".join(scritto)
	if scritto is String and String(scritto) != "":
		return String(scritto)
	costruisci_areali()
	var zone: Array = _areali.get(id_creatura, [])
	if zone.is_empty():
		return String(tecnolog.get("non_rilevato", "— non ancora rilevato"))
	return " · ".join(zone)

func classificazione_di(id_creatura: String) -> String:
	var voce: Dictionary = tecnolog.get("voci", {}).get(id_creatura, {})
	if voce.has("classificazione"):
		return String(voce["classificazione"])
	var ruolo := String(personaggi.get(id_creatura, {}).get("ruolo", "comune"))
	var rango := String(tecnolog.get("classificazione_per_ruolo", {}).get(ruolo, ""))
	if rango == "":
		return String(tecnolog.get("non_rilevato", "— non ancora rilevato"))
	return rango

func metamorfosi_di(id_creatura: String) -> String:
	# "osservata" vuol dire che l'hai vista tu: la forma in cui si trasforma
	# dev'essere nel tuo bestiario. Finche' non la incontri, il campo dice il
	# vero - che tu non l'hai osservata - anche se il gioco lo sa gia'
	var diventa := String(tecnolog.get("voci", {}).get(id_creatura, {}).get("diventa", ""))
	if diventa != "" and diventa in bestiario:
		return "osservata"
	return "non osservata"

func valore_tecnolog(id_creatura: String, id_campo: String) -> String:
	match id_campo:
		"denominazione":
			return String(personaggi.get(id_creatura, {}).get("nome", id_creatura))
		"classificazione":
			return classificazione_di(id_creatura)
		"areale":
			return areale_di(id_creatura)
		"metamorfosi":
			return metamorfosi_di(id_creatura)
	var scritto := String(tecnolog.get("voci", {}).get(id_creatura, {}).get(id_campo, ""))
	if scritto == "":
		return String(tecnolog.get("non_rilevato", "— non ancora rilevato"))
	return scritto

func tecnolog_di(id_creatura: String, strati := -1) -> Array:
	# la scheda come la si puo' leggere adesso. "strati" e' quanti studi hai
	# fatto: -1 (il difetto) vuol dire "dammela tutta", ed e' quello che serve al
	# documento e alle prove; ZERO vuol dire zero, cioe' una pagina bianca.
	#
	# Il difetto era 0 e voleva dire "tutta", e le due cose si sono scontrate
	# subito: una creatura mai studiata mostrava l'intera scheda. Un valore che
	# vuol dire due cose opposte prima o poi le confonde.
	var righe: Array = []
	for campo in campi_tecnolog():
		var strato := int(campo.get("strato", 1))
		var rivelato: bool = strati < 0 or strati >= strato
		righe.append({
			"id": String(campo.get("id", "")),
			"etichetta": String(campo.get("etichetta", "")),
			"strato": strato,
			"rivelato": rivelato,
			"valore": valore_tecnolog(id_creatura, String(campo.get("id", ""))) if rivelato \
					else String(tecnolog.get("non_rilevato", "— non ancora rilevato")),
		})
	return righe

func ottieni_carta(id_carta: String, finitura := "") -> bool:
	# ritorna true se la carta e' NUOVA (serve a chi vuole annunciarla come
	# scoperta). Il doppione non e' mai sprecato: entra comunque nel conto,
	# perche' si vende e si scambia
	if id_carta == "":
		return false
	if finitura == "":
		finitura = tira_finitura_carta()
	var copie: Dictionary = carte_copie.get(id_carta, {})
	copie[finitura] = int(copie.get(finitura, 0)) + 1
	carte_copie[id_carta] = copie
	if id_carta in carte:
		return false
	carte.append(id_carta)
	return true

func tira_finitura_carta() -> String:
	# le finiture sono sempre piu' rare andando avanti nell'elenco: la prima e'
	# quella di tutti i giorni, l'ultima quasi non si vede
	var finiture: Array = regole.get("carte_finiture", ["normale"])
	var probabilita := float(regole.get("carte_probabilita_finitura", 0.12))
	var scelta := 0
	while scelta < finiture.size() - 1 and rng.randf() < probabilita:
		scelta += 1
	return String(finiture[scelta])

func copie_carta(id_carta: String, finitura := "") -> int:
	var copie: Dictionary = carte_copie.get(id_carta, {})
	if finitura != "":
		return int(copie.get(finitura, 0))
	var totale := 0
	for quante in copie.values():
		totale += int(quante)
	return totale

func doppioni_carta(id_carta: String) -> int:
	# quante se ne possono vendere o scambiare senza perdere la voce nell'album
	return maxi(copie_carta(id_carta) - 1, 0)

func cedi_carta(id_carta: String, finitura := "") -> bool:
	# vendere o scambiare: si cede una COPIA, mai l'ultima. L'album non si buca
	if doppioni_carta(id_carta) <= 0:
		return false
	var copie: Dictionary = carte_copie.get(id_carta, {})
	if finitura == "":
		for chiave in copie:
			if int(copie[chiave]) > 0:
				finitura = String(chiave)
				break
	if int(copie.get(finitura, 0)) <= 0:
		return false
	copie[finitura] = int(copie[finitura]) - 1
	if int(copie[finitura]) <= 0:
		copie.erase(finitura)
	carte_copie[id_carta] = copie
	return true

func possiede_oggetto(id_oggetto: String) -> bool:
	return id_oggetto in sacca or id_oggetto in chiavi \
			or id_oggetto in collezionabili or id_oggetto in carte or id_oggetto in accessori

func compra(id_oggetto: String, prezzo: int) -> bool:
	if tazo < prezzo:
		return false
	if not aggiungi_oggetto(id_oggetto):
		return false
	tazo -= prezzo
	return true

func baratta(richiesti: Array, prodotto: String) -> bool:
	# l'Artigiano lavora solo cio' che gli porti: materiali dai collezionabili
	var restanti := collezionabili.duplicate()
	for materiale in richiesti:
		var indice := restanti.find(materiale)
		if indice < 0:
			return false
		restanti.remove_at(indice)
	if not aggiungi_oggetto(prodotto):
		return false
	collezionabili = restanti
	return true

func sblocca_negozio(id_negozio: String) -> void:
	if negozi.has(id_negozio) and id_negozio not in negozi_sbloccati:
		negozi_sbloccati.append(id_negozio)

func fabbisogno_xp(livello: int) -> int:
	var richiesta := ceili(float(regole.get("xp_base", 10))
			* pow(livello, float(regole.get("xp_esponente", 1.5))))
	if livello >= int(regole.get("livello_ostico", 100)):
		richiesta *= int(regole.get("moltiplicatore_ostico", 5))
	return richiesta

func aggiungi_xp(id_classe: String, quantita: int) -> void:
	if not classi.has(id_classe):
		return
	xp[id_classe] = int(xp.get(id_classe, 0)) + quantita
	var massimo := int(regole.get("livello_massimo", 130))
	while livello_di(id_classe) < massimo:
		var necessario := fabbisogno_xp(livello_di(id_classe))
		if xp[id_classe] < necessario:
			break
		xp[id_classe] -= necessario
		livelli[id_classe] = livello_di(id_classe) + 1
		if id_classe == id_protagonista:
			# SALIRE DI LIVELLO SI DEVE VEDERE. In Carnivalz le stat non salgono
			# col livello, salgono con quello che hai fatto: quindi il momento
			# in cui diventano punti e' l'unico in cui il giocatore scopre a
			# cosa e' servito giocare come ha giocato. Prima cambiavano dei
			# numeri da qualche parte e nessuno lo diceva.
			var prima := {}
			for nome_stat in crescita.get("stat", {}):
				prima[nome_stat] = stat_di(String(nome_stat))
			applica_crescita_livello()
			var cresciute: Array[Dictionary] = []
			for nome_stat in prima:
				var dopo := stat_di(String(nome_stat))
				if dopo > int(prima[nome_stat]):
					cresciute.append({
						"stat": String(nome_stat),
						"nome": String(crescita.get("stat", {}).get(nome_stat, {}).get("nome", nome_stat)),
						"prima": int(prima[nome_stat]),
						"dopo": dopo,
					})
			salite_di_livello.append({
				"livello": livello_di(id_classe),
				"stat": cresciute,
				"punti_abilita": punti_abilita_liberi(),
			})
			verifica_passive(livello_di(id_classe))

# --- crescita del protagonista: i contatori delle azioni diventano punti stat
# a ogni passaggio di livello, poi si azzerano. Chi attacca cresce in attacco,
# chi studia in intelligenza, chi esplora in velocita', chi incassa in hp... ---

func registra_azione(nome_azione: String, quantita := 1) -> void:
	contatori[nome_azione] = int(contatori.get(nome_azione, 0)) + quantita

func registra_stato_subito(id_stato: String) -> void:
	# subire uno stato allena la resistenza a quello stesso stato
	volte_stato_subito[id_stato] = int(volte_stato_subito.get(id_stato, 0)) + 1

func stat_base_di(nome_stat: String) -> int:
	return int(crescita.get("stat", {}).get(nome_stat, {}).get("base", 0))

func stat_di(nome_stat: String) -> int:
	# valore attuale di una stat del protagonista: base, piu' i punti guadagnati
	# giocando, piu' i nodi di potenziamento comprati coi punti abilita'
	return stat_base_di(nome_stat) + int(punti_stat.get(nome_stat, 0)) \
			+ bonus_da_potenziamenti(nome_stat)

func resistenza_stato_di(id_stato: String) -> int:
	return int(resistenze_stato.get(id_stato, 0))

func applica_crescita_livello() -> void:
	for nome_azione in crescita.get("crescita", {}):
		var regola: Dictionary = crescita["crescita"][nome_azione]
		var ogni := maxi(int(regola.get("ogni", 1)), 1)
		var fatte := int(contatori.get(nome_azione, 0))
		var guadagno := (fatte / ogni) * int(regola.get("punti", 1))
		if guadagno > 0:
			var nome_stat := String(regola.get("stat", ""))
			punti_stat[nome_stat] = int(punti_stat.get(nome_stat, 0)) + guadagno
			contatori[nome_azione] = fatte % ogni  # il resto vale per il prossimo livello
	var soglia := maxi(int(crescita.get("resistenze", {}).get("soglia_punto", 3)), 1)
	var tetto := int(crescita.get("resistenze", {}).get("massimo", 100))
	for id_stato in volte_stato_subito.keys():
		var volte := int(volte_stato_subito[id_stato])
		var punti := volte / soglia
		if punti > 0:
			resistenze_stato[id_stato] = mini(resistenza_stato_di(id_stato) + punti, tetto)
			volte_stato_subito[id_stato] = volte % soglia

func ha_passiva(id_passiva: String) -> bool:
	return id_passiva in passive_sbloccate

func sblocca_passiva(id_passiva: String, nome: String) -> void:
	if id_passiva in passive_sbloccate:
		return
	passive_sbloccate.append(id_passiva)
	passive_da_notificare.append(nome)

func verifica_passive(livello: int) -> void:
	for voce in crescita.get("passive_livello", []):
		if livello >= int(voce.get("livello", 999)):
			sblocca_passiva(String(voce.get("id", "")), String(voce.get("nome", "")))
	for voce in crescita.get("passive_soglia", []):
		var soddisfatta := true
		if voce.has("richiede_tutte_le_stat"):
			var minimo := int(voce["richiede_tutte_le_stat"])
			for nome_stat in crescita.get("stat", {}):
				if stat_di(nome_stat) < minimo:
					soddisfatta = false
					break
		for nome_stat in voce.get("richiede", {}):
			if stat_di(nome_stat) < int(voce["richiede"][nome_stat]):
				soddisfatta = false
				break
		if soddisfatta:
			sblocca_passiva(String(voce.get("id", "")), String(voce.get("nome", "")))
	for voce in crescita.get("passive_rare", []):
		var id_rara := String(voce.get("id", ""))
		if ha_passiva(id_rara):
			continue
		if livello >= int(voce.get("livello_garantito", 999)) \
				or rng.randf() < float(voce.get("probabilita", 0.0)):
			sblocca_passiva(id_rara, String(voce.get("nome", "")))

func bonus_passiva(chiave: String) -> float:
	# somma il contributo di tutte le passive sbloccate che dichiarano quella
	# chiave nei dati (es. bonus_drop, bonus_carta, slaughter_bonus)
	var totale := 0.0
	for voce in crescita.get("passive_livello", []):
		if voce.has(chiave) and ha_passiva(String(voce.get("id", ""))):
			totale += float(voce[chiave])
	return totale

func sblocca_classe(id_classe: String) -> void:
	if classi.has(id_classe) and id_classe not in classi_sbloccate:
		classi_sbloccate.append(id_classe)

func recluta(id_classe: String) -> void:
	sblocca_classe(id_classe)
	if classi.has(id_classe) and id_classe not in party:
		party.append(id_classe)

func recluta_temporaneo(id_classe: String, livello: int) -> void:
	# alleato che combatte con te ma non entra nel roster: dura uno squarcio
	if not classi.has(id_classe):
		return
	if id_classe not in party:
		party.append(id_classe)
	if id_classe not in alleati_temporanei:
		alleati_temporanei.append(id_classe)
	if livello > 0:
		livelli[id_classe] = livello

func svuota_equipaggiamento(id_classe: String) -> void:
	# Quando qualcuno lascia la squadra le sue cose non se ne vanno con lui:
	# tornano nello zaino. Sono tue, gliele avevi prestate.
	if not equipaggiamento.has(id_classe):
		return
	var slots: Dictionary = equipaggiamento[id_classe]
	for slot in SLOT_SINGOLI:
		slots[slot] = ""
	slots["accessori"] = []

func congeda(id_classe: String) -> void:
	svuota_equipaggiamento(id_classe)
	party.erase(id_classe)
	alleati_temporanei.erase(id_classe)

func congeda_tutti_temporanei() -> void:
	for id_classe in alleati_temporanei:
		party.erase(id_classe)
	alleati_temporanei.clear()

func possiede_tutti(lista: Array) -> bool:
	for id_oggetto in lista:
		if not possiede_oggetto(id_oggetto):
			return false
	return true

func ha_tutti_flag(lista: Array) -> bool:
	for nome_flag in lista:
		if not ha_flag(nome_flag):
			return false
	return true

func rimuovi_classe(id_classe: String) -> void:
	# un personaggio esce dai disponibili; il protagonista mai
	if id_classe == id_protagonista:
		return
	party.erase(id_classe)
	classi_sbloccate.erase(id_classe)

func aggiungi_ospite(id_personaggio: String) -> void:
	if personaggi.has(id_personaggio) and id_personaggio not in ospiti:
		ospiti.append(id_personaggio)

func registra_storico(tipo: String, chi: String, testo: String) -> void:
	# ogni messaggio che passa dal box finisce qui, cosi' il giocatore puo'
	# rileggerlo dalla pausa anche se ha cliccato troppo in fretta
	if testo.strip_edges() == "":
		return
	storico.append({"tipo": tipo, "chi": chi, "testo": testo})
	if storico.size() > STORICO_MASSIMO:
		storico.remove_at(0)

func segna_studiato(id_personaggio: String) -> void:
	if id_personaggio not in studiati:
		studiati.append(id_personaggio)
	rilevamenti[id_personaggio] = volte_studiato(id_personaggio) + 1

func volte_studiato(id_creatura: String) -> int:
	return int(rilevamenti.get(id_creatura, 0))

func imposta_flag(nome_flag: String) -> void:
	if nome_flag not in flags:
		flags.append(nome_flag)
		# gli appunti del Diario vivono sui flag: appena il mondo cambia, il
		# protagonista se ne accorge senza che ogni singolo nodo debba dirglielo
		aggiorna_task()

func ha_flag(nome_flag: String) -> bool:
	return nome_flag in flags

# --- appunti del Diario ---

func dati_task(id_task: String) -> Dictionary:
	for voce in task_catalogo:
		if String(voce.get("id", "")) == id_task:
			return voce
	return {}

func _tutti_i_flag(elenco: Variant) -> bool:
	# vero solo se ogni flag della lista e' alzato. Una lista vuota e' vera per
	# vacuita': serve saperlo, perche' "chiuso_da" vuoto va trattato a parte
	if not elenco is Array:
		return false
	for nome_flag in elenco:
		if not ha_flag(String(nome_flag)):
			return false
	return true

func task_risolto(voce: Dictionary) -> bool:
	var chiuso: Array = voce.get("chiuso_da", [])
	# elenco vuoto = non si chiude da solo: e' un seme lasciato li' per dopo
	return not chiuso.is_empty() and _tutti_i_flag(chiuso)

func aggiorna_task() -> void:
	# prima si chiude, poi si apre: cosi' un appunto che nasce gia' risolto
	# (raccogli la spilla dopo aver battuto il ricordo) non lampeggia per
	# un istante come nuovo
	for voce in task_catalogo:
		var id_task := String(voce.get("id", ""))
		if id_task == "":
			continue
		if task_risolto(voce):
			if id_task in task_attivi:
				task_attivi.erase(id_task)
			if id_task not in task_chiusi:
				task_chiusi.append(id_task)
			task_da_notificare.erase(id_task)
			continue
		if id_task in task_attivi or id_task in task_chiusi:
			continue
		var richiesti: Array = voce.get("richiede_flags", [])
		# senza condizioni non compare da solo: lo accende un nodo, con "task"
		if richiesti.is_empty() or not _tutti_i_flag(richiesti):
			continue
		task_attivi.append(id_task)
		task_da_notificare.append(id_task)

func apri_task(id_task: String) -> void:
	# apertura esplicita da un nodo o da una scelta ("task": "id"), per gli
	# appunti che nascono da una conversazione e non da uno stato del mondo
	if id_task == "" or id_task in task_attivi or id_task in task_chiusi:
		return
	if dati_task(id_task).is_empty():
		push_error("Task inesistente: " + id_task)
		return
	task_attivi.append(id_task)
	task_da_notificare.append(id_task)

func chiudi_task(id_task: String) -> void:
	task_attivi.erase(id_task)
	task_da_notificare.erase(id_task)
	if id_task not in task_chiusi:
		task_chiusi.append(id_task)

func entra_squarcio(id_squarcio: String, file_eventi: String) -> bool:
	# a ogni rientro gli agguati si ritirano: i nemici del Vuoto rispuntano;
	# gli alleati temporanei di un altro squarcio restano fuori
	stanze_ripulite.clear()
	congeda_tutti_temporanei()
	return avvia_carnivalz(id_squarcio, file_eventi)

func prepara_combattimento(nemici: Array, se_vinci: String, se_vinci_eroe: String, se_perdi: String, se_fuggi := "") -> void:
	nemici_combattimento = nemici.duplicate()
	nodo_se_vinci = se_vinci
	nodo_se_vinci_eroe = se_vinci_eroe
	nodo_se_perdi = se_perdi
	nodo_se_fuggi = se_fuggi

func premia_vittoria(xp_totale: int, tazo_totale: int, fonte_estinta: bool) -> void:
	for id_classe in party:
		aggiungi_xp(id_classe, xp_totale)
	modifica_tazo(tazo_totale)
	if fonte_estinta:
		fonti_estinte += 1
	annulla_combattimento()

func annulla_combattimento() -> void:
	nemici_combattimento = []
	nodo_se_vinci = ""
	nodo_se_vinci_eroe = ""
	nodo_se_perdi = ""
	nodo_se_fuggi = ""

# --- salvataggio: una partita per slot, scritto da solo.
#
# Si salva quando si rientra alla Sede (l'unico posto sicuro del gioco), mai
# dentro un carnivalz/squarcio. Quale file venga scritto non e' una domanda che
# si fa in gioco: e' lo slot scelto dalla schermata principale. ---

func percorso_slot(slot: int) -> String:
	return "user://salvataggio_slot_%d.json" % slot

func imposta_slot(slot: int) -> void:
	slot_corrente = clampi(slot, 1, SLOT_MASSIMO)

func ha_salvataggio() -> bool:
	for slot in range(1, SLOT_MASSIMO + 1):
		if ha_salvataggio_slot(slot):
			return true
	return false

func ha_salvataggio_slot(slot: int) -> bool:
	return FileAccess.file_exists(percorso_slot(slot))

func dati_slot(slot: int) -> Dictionary:
	# legge la testata di un salvataggio senza toccare la partita in corso
	var percorso := percorso_slot(slot)
	if not FileAccess.file_exists(percorso):
		return {}
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(percorso))
	return d if d is Dictionary else {}

func anteprima_slot(slot: int) -> String:
	var d := dati_slot(slot)
	if d.is_empty():
		return "Vuoto"
	return "Tazo %d · Fonti estinte %d · Legame %d" % [
		int(d.get("tazo", 0)), int(d.get("fonti_estinte", 0)), int(d.get("legame", 0))]

func nome_slot(slot: int) -> String:
	# chi sei in quella partita: il nome che ti sei dato e a che livello sei
	var d := dati_slot(slot)
	if d.is_empty():
		return ""
	var nome := String(d.get("nome_protagonista", ""))
	if nome == "":
		nome = nome_anonimo_default
	var livelli_salvati: Dictionary = d.get("livelli", {})
	var livello := int(livelli_salvati.get(id_protagonista, 1))
	return "%s · livello %d" % [nome, livello]

func elimina_slot(slot: int) -> void:
	var percorso := percorso_slot(slot)
	if FileAccess.file_exists(percorso):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(percorso))
		# su alcune piattaforme user:// non si globalizza: si riprova diretto
		if FileAccess.file_exists(percorso):
			DirAccess.open("user://").remove(percorso.get_file())

func recupera_salvataggio_vecchio() -> void:
	# Le partite giocate prima che "una partita = uno slot" esistesse stavano
	# tutte nell'autosalvataggio unico. Alla prima apertura del gioco nuovo
	# quel file diventa la partita numero 1, cosi' chi stava giocando riapre e
	# ritrova la sua roba invece di una lista di slot vuoti.
	if not FileAccess.file_exists(PERCORSO_SALVATAGGIO_VECCHIO):
		return
	if ha_salvataggio():
		return  # c'e' gia' almeno una partita nel nuovo formato: non si tocca niente
	var contenuto := FileAccess.get_file_as_string(PERCORSO_SALVATAGGIO_VECCHIO)
	var f := FileAccess.open(percorso_slot(1), FileAccess.WRITE)
	if f == null:
		return
	f.store_string(contenuto)
	f.close()

func salva() -> void:
	_scrivi_salvataggio(percorso_slot(slot_corrente))

func salva_slot(slot: int) -> void:
	_scrivi_salvataggio(percorso_slot(slot))

func carica() -> bool:
	return carica_slot(slot_corrente)

func carica_slot(slot: int) -> bool:
	if not _leggi_salvataggio(percorso_slot(slot)):
		return false
	imposta_slot(slot)
	return true

func _scrivi_salvataggio(percorso: String) -> void:
	var dati := {
		"versione": 1,
		"seed": seed_partita,
		"tazo": tazo,
		"fonti_estinte": fonti_estinte,
		"legame": legame,
		"classi_sbloccate": classi_sbloccate,
		"livelli": livelli,
		"xp": xp,
		"stress": stress,
		"sacca": sacca,
		"collezionabili": collezionabili,
		"chiavi": chiavi,
		"accessori": accessori,
		"armi": armi,
		"oggetti_speciali": oggetti_speciali,
		"spazi_zaino": spazi_zaino,
		"carte_copie": carte_copie,
		"equipaggiamento": equipaggiamento,
		"carte": carte,
		"oggetti_catalogo": oggetti_catalogo,
		"bestiario": bestiario,
		"rilevamenti": rilevamenti,
		"studiati": studiati,
		"negozi_sbloccati": negozi_sbloccati,
		"flags": flags,
		"pila": pila,
		"punti_stat": punti_stat,
		"nodi_abilita": nodi_abilita,
		"contatori": contatori,
		"resistenze_stato": resistenze_stato,
		"volte_stato_subito": volte_stato_subito,
		"passive_sbloccate": passive_sbloccate,
		"nodi_visitati": nodi_visitati,
		"proiettori": proiettori,
		"zone_visitate": zone_visitate,
		"task_attivi": task_attivi,
		"task_chiusi": task_chiusi,
		"nome_protagonista": nome_protagonista,
	}
	var f := FileAccess.open(percorso, FileAccess.WRITE)
	if f == null:
		push_error("Salvataggio non riuscito: " + str(FileAccess.get_open_error()))
		return
	f.store_string(JSON.stringify(dati, "\t"))
	f.close()
	partita_su_file = true

func _leggi_salvataggio(percorso: String) -> bool:
	if not FileAccess.file_exists(percorso):
		return false
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(percorso))
	if not d is Dictionary:
		push_error("Salvataggio corrotto: " + percorso)
		return false
	partita_su_file = true
	imposta_seed(int(d.get("seed", seed_partita)))
	tazo = int(d.get("tazo", 0))
	fonti_estinte = int(d.get("fonti_estinte", 0))
	legame = int(d.get("legame", int(regole.get("legame_iniziale", 20))))
	classi_sbloccate = _lista_str(d.get("classi_sbloccate", []))
	livelli = d.get("livelli", {})
	xp = d.get("xp", {})
	stress = d.get("stress", {})
	sacca = _lista_str(d.get("sacca", []))
	collezionabili = _lista_str(d.get("collezionabili", []))
	chiavi = _lista_str(d.get("chiavi", []))
	accessori = _lista_str(d.get("accessori", []))
	armi = _lista_str(d.get("armi", []))
	oggetti_speciali = _lista_str(d.get("oggetti_speciali", []))
	spazi_zaino = d.get("spazi_zaino", {})
	carte_copie = d.get("carte_copie", {})
	# salvataggi vecchi: armi e stigmi stavano tutti in "accessori", e le
	# carte non avevano copie. Si smistano al primo caricamento
	if armi.is_empty() and oggetti_speciali.is_empty():
		var rimaste: Array[String] = []
		for id_oggetto in accessori:
			match String(dati_oggetto(id_oggetto).get("tipo", "")):
				"arma": armi.append(id_oggetto)
				"stigma": oggetti_speciali.append(id_oggetto)
				_: rimaste.append(id_oggetto)
		accessori = rimaste
	equipaggiamento = d.get("equipaggiamento", {})
	# partite salvate col vecchio sistema a un solo accessorio: quello che
	# avevi addosso diventa il primo accessorio del protagonista
	var vecchio := String(d.get("accessorio_equipaggiato", ""))
	if equipaggiamento.is_empty() and vecchio != "" and id_protagonista != "":
		equipaggia(id_protagonista, "accessori", vecchio)
	carte = _lista_str(d.get("carte", []))
	# Salvataggi vecchi: le carte non avevano il conteggio delle copie. Ogni
	# carta gia' vista ne prende una, cosi' l'album resta pieno com'era.
	# (Questa riga stava piu' su, PRIMA che "carte" venisse caricata: girava a
	# vuoto e i doppioni di una partita vecchia sparivano. Trovato da
	# prova_salvataggio_vecchio.)
	for id_carta in carte:
		if not carte_copie.has(id_carta):
			carte_copie[id_carta] = {"normale": 1}
	oggetti_catalogo = _lista_str(d.get("oggetti_catalogo", []))
	bestiario = _lista_str(d.get("bestiario", []))
	rilevamenti = d.get("rilevamenti", {})
	studiati = _lista_str(d.get("studiati", []))
	negozi_sbloccati = _lista_str(d.get("negozi_sbloccati", []))
	flags = _lista_str(d.get("flags", []))
	pila = d.get("pila", {})
	punti_stat = d.get("punti_stat", {})
	nodi_abilita = _lista_str(d.get("nodi_abilita", []))
	contatori = d.get("contatori", {})
	resistenze_stato = d.get("resistenze_stato", {})
	volte_stato_subito = d.get("volte_stato_subito", {})
	passive_sbloccate = _lista_str(d.get("passive_sbloccate", []))
	nodi_visitati = _lista_str(d.get("nodi_visitati", []))
	proiettori = d.get("proiettori", {})
	zone_visitate = _lista_str(d.get("zone_visitate", []))
	if zone_visitate.is_empty():
		# Salvataggi fatti prima che si tenesse il conto dei posti visitati: il
		# conto c'e' lo stesso, scritto altrove. Ogni stanza sbloccata lascia un
		# flag col nome della zona davanti (vedi _flag_stanza), quindi da li' si
		# risale con certezza a dove il giocatore e' stato davvero.
		for nome_flag in flags:
			var pezzi := nome_flag.split("__stanza__")
			if pezzi.size() == 2 and pezzi[0] != "" and pezzi[0] not in zone_visitate:
				zone_visitate.append(pezzi[0])
	task_attivi = _lista_str(d.get("task_attivi", []))
	task_chiusi = _lista_str(d.get("task_chiusi", []))
	task_da_notificare.clear()
	# una partita salvata prima che un appunto esistesse (o prima che il
	# catalogo lo prevedesse) lo recupera qui dai flag che ha gia' in mano,
	# senza annunciarlo come se fosse appena successo
	aggiorna_task()
	task_da_notificare.clear()
	passive_da_notificare.clear()
	imposta_nome_protagonista(String(d.get("nome_protagonista", "")))
	# si riparte da uno stato "overworld" pulito: fuori da campagne e squarci
	party.clear()
	if id_protagonista != "":
		if id_protagonista not in classi_sbloccate:
			classi_sbloccate.append(id_protagonista)
		party.append(id_protagonista)
	if negozi_sbloccati.is_empty():
		negozi_sbloccati.append("organizzazione")
	ospiti.clear()
	alleati_temporanei.clear()
	stanze_ripulite.clear()
	eventi.clear()
	nodo_corrente = ""
	carnivalz_corrente = ""
	file_eventi_corrente = ""
	stanza_iniziale_zona = ""
	mappa_zona = {}
	punto_mappa_corrente = {}
	musica_ambiente = ""
	annulla_combattimento()
	return true

func _lista_str(v: Variant) -> Array[String]:
	var a: Array[String] = []
	if v is Array:
		for x in v:
			a.append(str(x))
	return a

func game_over() -> String:
	# "Riprendi dall'ultimo salvataggio" adesso lo fa DAVVERO.
	#
	# Prima non ricaricava niente: rifaceva la zona tenendo lo stato che c'era in
	# memoria. Le fiale usate restavano usate, i Tazo spesi restavano spesi, e
	# chi rileggeva il bottone si chiedeva giustamente che salvataggio fosse.
	# Il motivo scritto qui sopra era che il salvataggio era un file solo,
	# condiviso da tutte le partite - non e' piu' vero da quando una partita e'
	# uno slot, e con quel motivo e' caduta anche la scelta.
	#
	# Si ricarica solo il file DI QUESTA partita (partita_su_file): chi comincia
	# una partita nuova in uno slot gia' occupato e muore prima di aver salvato
	# non deve ritrovarsi addosso la partita di prima.
	#
	# Restituisce cosa e' successo, perche' chi ha chiamato deve sapere dove
	# mandare il giocatore:
	#   "salvataggio" -> ripreso dal file: si e' fuori da ogni zona, si va alla Sede
	#   "zona"        -> nessun salvataggio ancora (tutorial): si rifa' la zona
	#   ""            -> non c'era ne' l'uno ne' l'altra
	if partita_su_file and carica_slot(slot_corrente):
		return "salvataggio"
	if carnivalz_corrente == "" or file_eventi_corrente == "":
		return ""
	return "zona" if entra_squarcio(carnivalz_corrente, file_eventi_corrente) else ""

func reset_campagna() -> void:
	# fine campagna: roster, inventario, Tazo, livelli, stress e legame
	# restano; il party si scioglie e gli ospiti tornano al loro mondo
	party.clear()
	if id_protagonista != "":
		party.append(id_protagonista)
	ospiti.clear()
	alleati_temporanei.clear()
	eventi.clear()
	nodo_corrente = ""
	carnivalz_corrente = ""
	file_eventi_corrente = ""
	stanza_iniziale_zona = ""
	mappa_zona = {}
	storico.clear()
	annulla_combattimento()
