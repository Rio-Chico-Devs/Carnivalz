extends Node

# Autoload: stato di gioco e regole. Niente contenuti hardcodati:
# classi, personaggi, psichi, eventi, mappa e numeri di bilanciamento
# vivono nei JSON sotto data/.

const PERCORSO_CLASSI := "res://data/classes.json"
const PERCORSO_PERSONAGGI := "res://data/personaggi.json"
const PERCORSO_PSICHE := "res://data/psiche.json"
const PERCORSO_MAPPA := "res://data/mappa.json"
const PERCORSO_REGOLE := "res://data/regole.json"

# Unica fonte di casualità del gioco: sempre seedata, per determinismo
# e sync multiplayer futuro.
var rng := RandomNumberGenerator.new()
var seed_partita: int = 0

var classi: Dictionary = {}
var personaggi: Dictionary = {}      # classi + NPC (ritratti, dialoghi, stat)
var psichi: Dictionary = {}          # id psiche -> nome, effetto, descrizione
var regole: Dictionary = {}
var id_protagonista: String = ""

var classi_sbloccate: Array[String] = []  # roster: persiste tra le campagne
var party: Array[String] = []             # scelto a inizio campagna
var inventario: Array[String] = []
var livelli: Dictionary = {}              # id classe -> livello (default 1)
var xp: Dictionary = {}                   # id classe -> xp verso il prossimo livello
var stress: Dictionary = {}               # id classe -> 0..100
var legame: int = 0                       # 0..100, respira di continuo

var eventi: Dictionary = {}
var nodo_corrente: String = ""
var carnivalz_corrente: String = ""
var ospiti: Array[String] = []       # personaggi temporanei della campagna
var studiati: Array[String] = []     # chi hai studiato (per la sezione studio futura)

var nemici_combattimento: Array = []
var nodo_se_vinci: String = ""
var nodo_se_vinci_eroe: String = ""
var nodo_se_perdi: String = ""

func _ready() -> void:
	imposta_seed(int(Time.get_unix_time_from_system()))
	carica_classi()
	carica_personaggi()
	carica_psichi()
	carica_regole()
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

func carica_regole() -> void:
	var dati: Variant = carica_json(PERCORSO_REGOLE)
	regole = dati if dati is Dictionary else {}

func carica_mappa() -> Dictionary:
	var dati: Variant = carica_json(PERCORSO_MAPPA)
	return dati if dati is Dictionary else {}

func nuova_partita() -> void:
	classi_sbloccate.clear()
	party.clear()
	inventario.clear()
	livelli.clear()
	xp.clear()
	stress.clear()
	studiati.clear()
	legame = int(regole.get("legame_iniziale", 20))
	if id_protagonista != "":
		classi_sbloccate.append(id_protagonista)
		party.append(id_protagonista)
	ospiti.clear()
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

func rimuovi_classe(id_classe: String) -> void:
	# un personaggio esce dai disponibili; il protagonista mai
	if id_classe == id_protagonista:
		return
	party.erase(id_classe)
	classi_sbloccate.erase(id_classe)

func aggiungi_oggetto(id_oggetto: String) -> void:
	if id_oggetto not in inventario:
		inventario.append(id_oggetto)

func aggiungi_ospite(id_personaggio: String) -> void:
	if personaggi.has(id_personaggio) and id_personaggio not in ospiti:
		ospiti.append(id_personaggio)

func segna_studiato(id_personaggio: String) -> void:
	if id_personaggio not in studiati:
		studiati.append(id_personaggio)

func prepara_combattimento(nemici: Array, se_vinci: String, se_vinci_eroe: String, se_perdi: String) -> void:
	nemici_combattimento = nemici.duplicate()
	nodo_se_vinci = se_vinci
	nodo_se_vinci_eroe = se_vinci_eroe
	nodo_se_perdi = se_perdi

func premia_vittoria(xp_totale: int) -> void:
	for id_classe in party:
		aggiungi_xp(id_classe, xp_totale)
	annulla_combattimento()

func annulla_combattimento() -> void:
	nemici_combattimento = []
	nodo_se_vinci = ""
	nodo_se_vinci_eroe = ""
	nodo_se_perdi = ""

func reset_campagna() -> void:
	# fine campagna: roster, zaino, livelli, stress e legame restano;
	# il party si scioglie e gli ospiti tornano al loro mondo
	party.clear()
	if id_protagonista != "":
		party.append(id_protagonista)
	ospiti.clear()
	eventi.clear()
	nodo_corrente = ""
	carnivalz_corrente = ""
	annulla_combattimento()
