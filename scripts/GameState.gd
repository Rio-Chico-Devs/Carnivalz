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
var audio: Dictionary = {}           # config musica (chiavi -> percorsi)
var musica_ambiente: String = ""     # traccia della scena eventi corrente (frattura/campagna)
var id_protagonista: String = ""

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
var carte: Array[String] = []             # carte dei nemici (album): id carta ottenute
var tazo: int = 0
var fonti_estinte: int = 0
var negozi_sbloccati: Array[String] = []

var eventi: Dictionary = {}
var nodo_corrente: String = ""
var carnivalz_corrente: String = ""
var ospiti: Array[String] = []       # personaggi temporanei della campagna
var alleati_temporanei: Array[String] = []  # compagni che combattono per un solo squarcio
var studiati: Array[String] = []     # chi hai studiato (per la sezione studio futura)
var flags: Array[String] = []        # scoperte permanenti (loot una tantum, segreti)

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

func carica_personaggi() -> void:
	personaggi.clear()
	for id_classe in classi:
		personaggi[id_classe] = classi[id_classe]
	var dati: Variant = carica_json(PERCORSO_PERSONAGGI)
	if dati is Dictionary:
		for personaggio in dati.get("personaggi", []):
			personaggi[personaggio["id"]] = personaggio

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

func carica_audio() -> void:
	var dati: Variant = carica_json(PERCORSO_AUDIO)
	audio = dati if dati is Dictionary else {}

func carica_mappa() -> Dictionary:
	var dati: Variant = carica_json(PERCORSO_MAPPA)
	return dati if dati is Dictionary else {}

func nuova_partita() -> void:
	classi_sbloccate.clear()
	party.clear()
	livelli.clear()
	xp.clear()
	stress.clear()
	studiati.clear()
	sacca.clear()
	collezionabili.clear()
	chiavi.clear()
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
	annulla_combattimento()

func avvia_carnivalz(id_punto: String, file_eventi: String) -> bool:
	var dati: Variant = carica_json(file_eventi)
	if not dati is Dictionary:
		return false
	carnivalz_corrente = id_punto
	eventi = dati.get("nodi", {})
	nodo_corrente = dati.get("nodo_iniziale", "")
	return not eventi.is_empty() and nodo_corrente != ""

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
		_:
			if sacca.size() >= int(regole.get("sacca_massima", 20)):
				return false  # sacca piena
			sacca.append(id_oggetto)
	return true

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
			or id_oggetto in collezionabili or id_oggetto in carte

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

func segna_studiato(id_personaggio: String) -> void:
	if id_personaggio not in studiati:
		studiati.append(id_personaggio)

func imposta_flag(nome_flag: String) -> void:
	if nome_flag not in flags:
		flags.append(nome_flag)

func ha_flag(nome_flag: String) -> bool:
	return nome_flag in flags

func entra_squarcio(id_squarcio: String, file_eventi: String) -> bool:
	# a ogni rientro gli agguati si ritirano: i nemici del Vuoto rispuntano;
	# gli alleati temporanei di un altro squarcio restano fuori
	stanze_ripulite.clear()
	congeda_tutti_temporanei()
	return avvia_carnivalz(id_squarcio, file_eventi)

func prepara_combattimento(nemici: Array, se_vinci: String, se_vinci_eroe: String, se_perdi: String) -> void:
	nemici_combattimento = nemici.duplicate()
	nodo_se_vinci = se_vinci
	nodo_se_vinci_eroe = se_vinci_eroe
	nodo_se_perdi = se_perdi

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
	annulla_combattimento()
