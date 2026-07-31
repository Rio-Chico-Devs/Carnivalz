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
const PERCORSO_CRESCITA := "res://data/crescita.json"
const PERCORSO_TASK := "res://data/task.json"
const PERCORSO_CODICI := "res://data/codici.json"  # extra: sblocchi via codice
const PERCORSO_CODICI_RISCATTATI := "user://codici_riscattati.cfg"
const PERCORSO_SALVATAGGIO := "user://salvataggio.json"  # autosalvataggio
const SLOT_MASSIMO := 5  # salvataggi manuali dell'utente, oltre all'autosalvataggio

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
var stati: Dictionary = {}                # id stato -> definizione generica (tipo, contagiosa, ...)
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
var chiavi: Array[String] = []
var accessori: Array[String] = []         # equipaggiamento posseduto (unico per id, non consumabile)
var accessorio_equipaggiato: String = ""  # al massimo uno alla volta, vuoto = nessuno
var carte: Array[String] = []             # carte dei nemici (album): id carta ottenute
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
var punto_mappa_corrente: Dictionary = {}  # il sistema/Vuoto che stai guardando

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
	imposta_nome_protagonista("")  # si riparte da "Anonimo": si rinomina di nuovo, se si vuole
	classi_sbloccate.clear()
	party.clear()
	livelli.clear()
	xp.clear()
	stress.clear()
	studiati.clear()
	punti_stat.clear()
	contatori.clear()
	resistenze_stato.clear()
	volte_stato_subito.clear()
	passive_sbloccate.clear()
	passive_da_notificare.clear()
	nodi_visitati.clear()
	storico.clear()
	task_attivi.clear()
	task_chiusi.clear()
	task_da_notificare.clear()
	hp_persistenti.clear()
	sacca.clear()
	collezionabili.clear()
	chiavi.clear()
	accessori.clear()
	accessorio_equipaggiato = ""
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

func party_ha_abilita(abilita: String) -> bool:
	for id_classe in party:
		if abilita in classi.get(id_classe, {}).get("abilita", []):
			return true
	return false

func livello_di(id_classe: String) -> int:
	return int(livelli.get(id_classe, 1))

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

func aggiungi_oggetto(id_oggetto: String) -> bool:
	cataloga_oggetto(id_oggetto)  # la voce nel compendio appare al primo possesso
	match dati_oggetto(id_oggetto).get("tipo", "consumabile"):
		"collezionabile":
			collezionabili.append(id_oggetto)
		"chiave":
			if id_oggetto not in chiavi:
				chiavi.append(id_oggetto)
		"accessorio":
			if id_oggetto not in accessori:
				accessori.append(id_oggetto)
			if accessorio_equipaggiato == "":
				# se non ne hai gia' uno addosso, il primo accessorio si
				# equipaggia da solo: "avere" la Pietra Quieta deve bastare a
				# proteggerti, senza passare per il Compendio
				accessorio_equipaggiato = id_oggetto
		_:
			if sacca.size() >= int(regole.get("sacca_massima", 20)):
				return false  # sacca piena
			sacca.append(id_oggetto)
	return true

# --- equipaggiamento: un solo accessorio alla volta, effetto passivo in
# combattimento (Combattimento._ready() legge accessorio_equipaggiato) ---

func equipaggia_accessorio(id_oggetto: String) -> void:
	if id_oggetto in accessori:
		accessorio_equipaggiato = id_oggetto

func rimuovi_accessorio() -> void:
	accessorio_equipaggiato = ""

func consuma_accessorio_equipaggiato() -> void:
	# l'oggetto si rompe/si consuma usando il suo effetto: sparisce del tutto
	if accessorio_equipaggiato == "":
		return
	accessori.erase(accessorio_equipaggiato)
	accessorio_equipaggiato = ""

# --- collezioni (album carte, bestiario, compendio oggetti) ---

func cataloga_oggetto(id_oggetto: String) -> void:
	if oggetti.has(id_oggetto) and id_oggetto not in oggetti_catalogo:
		oggetti_catalogo.append(id_oggetto)

func registra_bestiario(id_nemico: String) -> void:
	if personaggi.has(id_nemico) and id_nemico not in bestiario:
		bestiario.append(id_nemico)

func ottieni_carta(id_carta: String) -> bool:
	# ritorna true solo se la carta e' nuova (drop non sprecato sui doppioni)
	if id_carta == "" or id_carta in carte:
		return false
	carte.append(id_carta)
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
			applica_crescita_livello()
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
	# valore attuale di una stat del protagonista: base + punti guadagnati
	return stat_base_di(nome_stat) + int(punti_stat.get(nome_stat, 0))

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

func congeda(id_classe: String) -> void:
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

# --- salvataggio: solo dalla mappa stellare, mai dentro un carnivalz/squarcio.
# Un autosalvataggio (PERCORSO_SALVATAGGIO) + SLOT_MASSIMO salvataggi manuali
# scelti dall'utente (percorso_slot). ---

func percorso_slot(slot: int) -> String:
	return "user://salvataggio_slot_%d.json" % slot

func ha_salvataggio() -> bool:
	return FileAccess.file_exists(PERCORSO_SALVATAGGIO)

func ha_salvataggio_slot(slot: int) -> bool:
	return FileAccess.file_exists(percorso_slot(slot))

func anteprima_slot(slot: int) -> String:
	# riga sintetica per il selettore, senza toccare lo stato in corso
	var percorso := percorso_slot(slot)
	if not FileAccess.file_exists(percorso):
		return "Vuoto"
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(percorso))
	if not d is Dictionary:
		return "Vuoto"
	return "Tazo %d · Fonti estinte %d · Legame %d" % [
		int(d.get("tazo", 0)), int(d.get("fonti_estinte", 0)), int(d.get("legame", 0))]

func salva() -> void:
	_scrivi_salvataggio(PERCORSO_SALVATAGGIO)

func salva_slot(slot: int) -> void:
	_scrivi_salvataggio(percorso_slot(slot))

func carica() -> bool:
	return _leggi_salvataggio(PERCORSO_SALVATAGGIO)

func carica_slot(slot: int) -> bool:
	return _leggi_salvataggio(percorso_slot(slot))

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
		"accessorio_equipaggiato": accessorio_equipaggiato,
		"carte": carte,
		"oggetti_catalogo": oggetti_catalogo,
		"bestiario": bestiario,
		"studiati": studiati,
		"negozi_sbloccati": negozi_sbloccati,
		"flags": flags,
		"punti_stat": punti_stat,
		"contatori": contatori,
		"resistenze_stato": resistenze_stato,
		"volte_stato_subito": volte_stato_subito,
		"passive_sbloccate": passive_sbloccate,
		"nodi_visitati": nodi_visitati,
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

func _leggi_salvataggio(percorso: String) -> bool:
	if not FileAccess.file_exists(percorso):
		return false
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(percorso))
	if not d is Dictionary:
		push_error("Salvataggio corrotto: " + percorso)
		return false
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
	accessorio_equipaggiato = String(d.get("accessorio_equipaggiato", ""))
	carte = _lista_str(d.get("carte", []))
	oggetti_catalogo = _lista_str(d.get("oggetti_catalogo", []))
	bestiario = _lista_str(d.get("bestiario", []))
	studiati = _lista_str(d.get("studiati", []))
	negozi_sbloccati = _lista_str(d.get("negozi_sbloccati", []))
	flags = _lista_str(d.get("flags", []))
	punti_stat = d.get("punti_stat", {})
	contatori = d.get("contatori", {})
	resistenze_stato = d.get("resistenze_stato", {})
	volte_stato_subito = d.get("volte_stato_subito", {})
	passive_sbloccate = _lista_str(d.get("passive_sbloccate", []))
	nodi_visitati = _lista_str(d.get("nodi_visitati", []))
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

func game_over() -> bool:
	# sconfitta seria: si ricomincia il livello dal suo punto di partenza,
	# tenendo il progresso della partita in corso. NON si ricarica il
	# salvataggio: quello e' un file solo, condiviso da tutte le partite, e
	# rileggerlo qui significherebbe ritrovarsi addosso l'inventario di
	# un'altra sessione. La penalita' della morte e' rifare il livello.
	# Ritorna false solo se non c'era una zona in cui rientrare.
	if carnivalz_corrente == "" or file_eventi_corrente == "":
		return false
	return entra_squarcio(carnivalz_corrente, file_eventi_corrente)

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
