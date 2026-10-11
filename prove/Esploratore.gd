extends Node

# L'ESPLORATORE: gioca TUTTE le strade della storia, senza schermo, e cerca i
# punti morti.
#
# Bru, prima di provare il gioco: «lancia una review deep di quello che abbiamo
# fatto fino ad ora, dobbiamo essere sicuri non ci siano punti morti, punti in
# cui sei bloccato, deadlock o altri problemi».
#
# Le prove sui dati guardano un nodo alla volta: ha un'uscita? la destinazione
# esiste? E l'automa gioca UNA partita alla volta, con clic veri. Nessuno dei
# due risponde alla domanda che conta: c'e' un modo di giocare - una scelta
# fatta prima, una porta aperta dopo, uno scontro perso - che ti chiude in un
# posto da cui la storia non va piu' avanti? Per rispondere bisogna provare
# tutte le combinazioni, e una persona non lo fa.
#
# Qui si fa cosi'. Per ogni zona, partendo da dove ci si arriva:
#   - si entra nei nodi con IngressoNodo.entra, lo stesso del gioco
#   - si prova ogni scelta visibile (IngressoNodo.scelta_visibile) coi suoi
#     effetti (IngressoNodo.effetti_della_scelta)
#   - dalla mappa si prova ogni stanza in cui si entra (IngressoNodo.si_entra)
#   - ogni scontro finisce in tutti i modi: vinto, perso, fuggito
#   - ogni agguato scatta e non scatta
#   - i dialoghi coi compagni, che accendono flag, si fanno e non si fanno
# Ogni situazione nuova (dove sei + quello che conta di cio' che sai) si
# ricorda; alla fine, all'indietro, si chiede di ognuna:
#   PRIGIONE    - da qui non si esce piu' dalla zona
#   PUNTO MORTO - da qui la zona non si finisce piu' (anche uscendo e
#                 rientrando: un flag perso resta perso)
#   ERRORE      - una strada che finisce dove il gioco non sa dove mandarti
#                 (la rete di sicurezza, un nodo che non c'e', una mappa
#                 senza niente da premere)
#
# COSA NON GUARDA, detto: il bilanciamento (uno scontro si da' per vincibile,
# per perdibile e per fuggibile), le scelte a tempo (si danno per prese in
# tempo, e il caso "scaduta" e' una scelta in meno), e lo schermo. Lo schermo
# lo guarda l'automa (prove/automa.sh).
#
#   ./prove/esplora.sh

const LIMITE_STATI := 120000
const ESEMPI := 4                 # quanti casi mostrare per tipo di difetto
const SCENA_COMBATTIMENTO := "res://scenes/Combattimento.tscn"
const SLOT_FINTO := 99   # fuori dagli slot del gioco (GameState.SLOT_MASSIMO)

# quello che di GameState si fotografa: tutto quello che una scelta, un ingresso
# o uno scontro possono cambiare. Le collezioni meta (carte, bestiario) no
const CAMPI := ["flags", "nodi_visitati", "nodo_corrente", "carnivalz_corrente", "file_eventi_corrente",
		"stanza_iniziale_zona", "party", "alleati_temporanei", "ospiti", "classi_sbloccate", "livelli", "legame",
		"scelte_eroe", "scelte_malvagie", "sacca", "collezionabili", "pila", "chiavi", "armi", "accessori",
		"oggetti_speciali", "tazo", "stanze_ripulite", "proiettori", "nodo_se_vinci", "nodo_se_vinci_eroe",
		"nodo_se_perdi", "nodo_se_fuggi"]
# questi cambiano solo cambiando zona: si fotografa il riferimento, non una copia
const CAMPI_DI_ZONA := ["eventi", "mappa_zona", "punto_mappa_corrente"]

var zona: Dictionary = {}
var stati: Array[Dictionary] = []     # {pos, foto}
var indice := {}                      # chiave -> numero dello stato
var archi: Array = []                 # numero -> Array di numeri
var padre: Array[int] = []
var come: Array[String] = []
var segnalazioni := {}                # testo -> numero dello stato in cui e' successo
var letti := {}                       # i flag che cambiano qualcosa, in questa zona
var oggetti_che_contano := {}
var soglie := {"tazo": [], "legame": [], "eroe": [], "malvagio": [], "eroe_max": [], "malvagio_max": []}
var visite_che_contano := {}
var difetti := 0
var finali: Array[Dictionary] = []    # le fotografie con cui la zona e' finita (per la prossima)
var espansi := 0                      # quante situazioni si sono guardate fino in fondo
var foto_ingresso: Dictionary = {}    # com'eri entrando: e' quello che un salvataggio ti ridà


func _ready() -> void:
	# da sola (./prove/esplora.sh) gira tutto e chiude; dentro le prove
	# (Prove.gd) aspetta che le si chieda quali zone guardare
	if get_tree().current_scene != self:
		return
	await get_tree().process_frame
	var sola := OS.get_environment("ESPLORA_ZONA")
	var esito := esplora_tutto([] if sola == "" else ["intro", "tutorial", sola])
	print("\nESITO ESPLORATORE: %s" % ("PULITO" if esito == 0 else "%d DIFETTI" % esito))
	get_tree().quit(0 if esito == 0 else 1)


func esplora_tutto(solo: Array = []) -> int:
	# torna quanti difetti ha trovato. Le zone si giocano in fila: ognuna parte
	# da come e' finita quella prima (il primo giorno, poi le Pianure, poi il resto)
	difetti = 0
	var slot_prima := GameState.slot_corrente
	# un nodo puo' salvare (salva_checkpoint): mai sugli slot veri di chi gioca
	GameState.slot_corrente = SLOT_FINTO
	var partenza := {}
	for z: Dictionary in tutte_le_zone():
		if not solo.is_empty() and z["id"] not in solo:
			continue
		if z.get("dopo", "") != "" and not partenza.has(z["dopo"]):
			print("\n=== %s: salto, la zona prima (%s) non e' finita" % [z["id"], z["dopo"]])
			difetti += 1
			continue
		esplora(z, partenza.get(z.get("dopo", ""), {}))
		if not finali.is_empty():
			partenza[z["id"]] = finali[0]
	ogni_cancello_ha_chi_lo_apre()
	GameState.elimina_slot(SLOT_FINTO)
	GameState.slot_corrente = slot_prima
	GameState.nuova_partita()
	return difetti


func ogni_cancello_ha_chi_lo_apre() -> void:
	# I FLAG CHE LA MAPPA CHIEDE, per l'anomalia e per le fratture nascoste,
	# devono essere la meta di qualche zona: se nessuna li porta a casa, quello
	# che chiedono resta chiuso per sempre. Contano solo le cose che si possono
	# aprire davvero (con un file): un segnaposto senza file aspetta il contenuto
	var mete := {}
	for z: Dictionary in tutte_le_zone():
		var flag_meta: Variant = z.get("flag_meta", [])
		for f in (flag_meta if flag_meta is Array else [flag_meta]):
			mete[String(f)] = true
	for punto: Dictionary in GameState.carica_mappa().get("punti", []):
		if String(punto.get("file_eventi", "")) == "":
			continue
		var cancelli: Array = [[String(punto.get("nome", "")), punto.get("pianeta_richiede_flags", [])]]
		for voce: Dictionary in punto.get("vuoti", []):
			if String(voce.get("file_eventi", "")) != "":
				cancelli.append([String(voce.get("nome", "")), voce.get("richiede_flags", [])])
		for cancello: Array in cancelli:
			for f in cancello[1]:
				if not mete.has(String(f)):
					difetti += 1
					print("  ✗ «%s» chiede il flag %s, e nessuna zona lo porta a termine" % [cancello[0], f])


# --- le zone, nell'ordine in cui si giocano ----------------------------------

func tutte_le_zone() -> Array[Dictionary]:
	var zone: Array[Dictionary] = [
		{"id": "intro", "file": "res://data/events_intro.json", "ingresso": "nodo",
				"meta": "T|avvio:tutorial", "game_over": "zona"},
		{"id": "tutorial", "file": "res://data/events_tutorial.json", "ingresso": "nodo", "dopo": "intro",
				"meta": "T|sede", "flag_meta": "tutorial_completato", "game_over": "zona"},
		{"id": "sede", "file": "res://data/events_sede.json", "ingresso": "sede", "dopo": "tutorial",
				"meta": "T|apre:mappa_stellare", "game_over": "salvataggio"},
	]
	var mappa: Dictionary = GameState.carica_mappa()
	for punto: Dictionary in mappa.get("punti", []):
		if String(punto.get("file_eventi", "")) == "":
			continue
		zone.append({"id": String(punto["id"]), "file": String(punto["file_eventi"]), "ingresso": "nodo",
				"dopo": "tutorial", "meta": "T|sede", "game_over": "salvataggio", "punto": punto,
				"flag_iniziali": punto.get("pianeta_richiede_flags", [])})
		for voce: Dictionary in punto.get("vuoti", []) + punto.get("pianeti", []):
			if String(voce.get("file_eventi", "")) == "":
				continue
			zone.append({"id": String(voce["id"]), "file": String(voce["file_eventi"]), "ingresso": "frattura",
					"dopo": "tutorial", "game_over": "salvataggio", "punto": punto,
					"flag_iniziali": voce.get("richiede_flags", []),
					"flag_meta": flag_che_servono_fuori(String(voce["file_eventi"]), mappa)})
	return zone


func flag_che_servono_fuori(file: String, mappa: Dictionary) -> Array:
	# LA META DI UNA FRATTURA E' QUELLO CHE IL RESTO DEL GIOCO LE CHIEDE: i flag
	# che mappa.json pretende (per l'anomalia, per le fratture nascoste) e che
	# solo questo file accende. Senza, la meta e' poterne uscire
	var chiesti := {}
	for punto: Dictionary in mappa.get("punti", []):
		for f in punto.get("pianeta_richiede_flags", []):
			chiesti[String(f)] = true
		for voce: Dictionary in punto.get("vuoti", []):
			for f in voce.get("richiede_flags", []):
				chiesti[String(f)] = true
	var dati: Variant = GameState.carica_json(file)
	var accesi := {}
	raccogli_i_flag_accesi(dati, accesi)
	# E QUELLO CHE LA FRATTURA DICHIARA DI SE': il suo flag di completamento,
	# se il resto del gioco lo chiede, e' la sua meta anche quando nessun nodo
	# lo accende piu'. Ricavata solo dai flag accesi, la meta spariva insieme al
	# flag - e l'esploratore diceva «tutto a posto» a una frattura che non si
	# finiva piu' (l'ha trovato un sabotaggio)
	var dichiarato := String((dati as Dictionary).get("mappa_dungeon", {}).get("flag_completamento", "")) \
			if dati is Dictionary else ""
	var suoi: Array = []
	for f: String in chiesti:
		if accesi.has(f) or f == dichiarato:
			suoi.append(f)
	return suoi


func raccogli_i_flag_accesi(dati: Variant, dentro: Dictionary) -> void:
	# chi ACCENDE un flag ("flag": "...", su un nodo, una scelta, una battuta),
	# non chi lo legge
	if dati is Dictionary:
		for k: Variant in dati:
			if String(k) == "flag" and dati[k] is String:
				dentro[String(dati[k])] = true
			raccogli_i_flag_accesi(dati[k], dentro)
	elif dati is Array:
		for v: Variant in dati:
			raccogli_i_flag_accesi(v, dentro)


# --- una zona ------------------------------------------------------------------

func esplora(z: Dictionary, base: Dictionary) -> void:
	zona = z
	stati.clear()
	indice.clear()
	archi.clear()
	padre.clear()
	come.clear()
	segnalazioni.clear()
	finali.clear()
	var inizio := Time.get_ticks_msec()
	prepara_la_partenza(base)
	foto_ingresso = fotografa()
	studia_la_zona()
	var primi := ingresso_nella_zona()
	for p: Array in primi:
		aggiungi(String(p[1]), p[2], -1, String(p[0]))
	var i := 0
	espansi = 0
	while i < stati.size():
		if stati.size() > limite():
			segnala("troppe situazioni (oltre %d): l'esplorazione si ferma qui" % limite(), i)
			break
		espandi(i)
		if not (String(stati[i]["pos"]).begins_with("T|") and stati[i]["meta"]):
			stati[i]["foto"] = {}   # gia' espanso: la fotografia non serve piu', e la memoria si'
		i += 1
		espansi = i
	racconta(Time.get_ticks_msec() - inizio)


func limite() -> int:
	var dato := OS.get_environment("ESPLORA_LIMITE")
	return int(dato) if dato.is_valid_int() else LIMITE_STATI


func prepara_la_partenza(base: Dictionary) -> void:
	GameState.nuova_partita()
	GameState.partita_su_file = false
	if not base.is_empty():
		ripristina(base)
	for f in zona.get("flag_iniziali", []):
		GameState.imposta_flag(String(f))
	GameState.punto_mappa_corrente = zona.get("punto", {})


func ingresso_nella_zona() -> Array:
	match String(zona["ingresso"]):
		"sede":
			GameState.avvia_carnivalz("sede", String(zona["file"]))
			GameState.imposta_flag(String(GameState.mappa_zona.get("flag_completamento", "")))
			return [["la Sede", pos_mappa(GameState.nodo_corrente, "", false), fotografa()]]
		"frattura":
			if not GameState.entra_squarcio(String(zona["id"]), String(zona["file"])):
				segnala("la frattura non si apre: file vuoto o senza nodo iniziale", -1)
				return []
		_:
			if not GameState.avvia_carnivalz(String(zona["id"]), String(zona["file"])):
				segnala("la zona non si apre: file vuoto o senza nodo iniziale", -1)
				return []
	return entra_in(GameState.nodo_corrente)


func studia_la_zona() -> void:
	# QUELLO CHE CONTA, e il resto no. Una situazione e' "dove sei" piu' le cose
	# che possono cambiare quali porte si aprono: i flag che qualcuno legge, gli
	# oggetti che qualcuno chiede, le soglie di Tazo, legame e karma. Un flag che
	# nessuno legge (il bottino gia' raccolto, una stanza segnata sulla mappa)
	# non fa due situazioni diverse: senza questa regola le combinazioni del
	# bottino da sole sarebbero milioni
	letti.clear()
	oggetti_che_contano.clear()
	visite_che_contano.clear()
	for k in soglie:
		soglie[k] = []
	var nodi: Dictionary = GameState.carica_json(String(zona["file"])).get("nodi", {})
	var mappa_dungeon: Dictionary = GameState.carica_json(String(zona["file"])).get("mappa_dungeon", {})
	for campo in ["richiede_flag", "flag_completamento"]:
		leggi_flag(mappa_dungeon.get(campo, ""))
	for f in (mappa_dungeon.get("connessioni_da", {}) as Dictionary):
		leggi_flag(f)
	for stanza: Dictionary in mappa_dungeon.get("stanze", []):
		leggi_flag(stanza.get("richiede_flag", ""))
	for f in zona.get("flag_meta", []) if zona.get("flag_meta", []) is Array else [zona.get("flag_meta", "")]:
		leggi_flag(f)
	leggi_flag(IconaGuida.FLAG)
	for id_nodo: String in nodi:
		studia_il_nodo(id_nodo, nodi[id_nodo])
	# i dialoghi coi compagni contano se accendono un flag che conta
	for raccolta in [GameState.dialoghi, GameState.conversazioni]:
		for id_nodo in raccolta:
			var voce: Dictionary = raccolta[id_nodo]
			if letti.has(String(voce.get("flag", ""))):
				leggi_flag(voce.get("una_tantum", ""))


func studia_il_nodo(id_nodo: String, nodo: Dictionary) -> void:
	for regola in (nodo.get("vai_se_flag", []) if nodo.get("vai_se_flag", []) is Array else [nodo["vai_se_flag"]]):
		leggi_flag((regola as Dictionary).get("flag", ""))
	for campo in ["agguato", "combattimento_automatico"]:
		leggi_flag((nodo.get(campo, {}) as Dictionary).get("salta_se_flag", ""))
	if nodo.has("apri_mappa_zona"):
		visite_che_contano[id_nodo] = true
	for scelta: Dictionary in nodo.get("scelte", []):
		leggi_flag(scelta.get("richiede_flag", ""))
		leggi_flag(scelta.get("richiede_non_flag", ""))
		for id_oggetto in scelta.get("richiede_oggetti", []):
			oggetti_che_contano[String(id_oggetto)] = true
		if int(scelta.get("tazo", 0)) < 0:
			soglie["tazo"].append(-int(scelta["tazo"]))
		for coppia in [["richiede_legame", "legame"], ["richiede_eroe", "eroe"], ["richiede_malvagio", "malvagio"],
				["richiede_eroe_max", "eroe_max"], ["richiede_malvagio_max", "malvagio_max"]]:
			if scelta.has(coppia[0]):
				soglie[coppia[1]].append(int(scelta[coppia[0]]))
		if scelta.has("una_tantum") and conta_la_scelta(scelta, id_nodo):
			leggi_flag(scelta["una_tantum"])


func conta_la_scelta(scelta: Dictionary, id_nodo: String) -> bool:
	# una scelta "una tantum" che porta da qualche parte, o cambia qualcosa che
	# conta, e' una porta: sapere se l'hai gia' presa fa due situazioni diverse.
	# Una che da' solo bottino no - e «raccogli e resta qui» e' un "vai" verso
	# il nodo in cui sei gia', non uno spostamento
	const SOLO_BOTTINO := ["testo", "una_tantum", "oggetto", "oggetti", "tazo", "stress", "legame", "genere",
			"tempo", "task", "chiudi_task", "sblocca_negozio"]
	for campo: String in scelta:
		if campo == "vai" and String(scelta["vai"]) == id_nodo:
			continue
		if not campo.begins_with("_") and campo not in SOLO_BOTTINO:
			return true
	for id_oggetto in IngressoNodo.lista_id(scelta.get("oggetto", scelta.get("oggetti", []))):
		if oggetti_che_contano.has(id_oggetto):
			return true
	return false


func leggi_flag(f: Variant) -> void:
	if f is String and String(f) != "":
		letti[String(f)] = true


# --- le fotografie -------------------------------------------------------------

func fotografa() -> Dictionary:
	var foto := {}
	for campo: String in CAMPI:
		var valore: Variant = GameState.get(campo)
		foto[campo] = valore.duplicate(true) if (valore is Array or valore is Dictionary) else valore
	for campo: String in CAMPI_DI_ZONA:
		foto[campo] = GameState.get(campo)
	foto["ultima_stanza"] = IngressoNodo.ultima_stanza
	return foto


func ripristina(foto: Dictionary) -> void:
	for campo: String in CAMPI:
		if not foto.has(campo):
			continue
		var valore: Variant = foto[campo]
		var attuale: Variant = GameState.get(campo)
		if attuale is Array:
			(attuale as Array).assign(valore)
		elif attuale is Dictionary:
			GameState.set(campo, (valore as Dictionary).duplicate(true))
		else:
			GameState.set(campo, valore)
	for campo: String in CAMPI_DI_ZONA:
		if foto.has(campo):
			GameState.set(campo, foto[campo])
	IngressoNodo.ultima_stanza = String(foto.get("ultima_stanza", ""))


func chiave(pos: String, foto: Dictionary) -> String:
	var flag_letti: Array = []
	for f in foto["flags"]:
		if letti.has(String(f)):
			flag_letti.append(String(f))
	flag_letti.sort()
	var cose: Array = []
	for id_oggetto: String in oggetti_che_contano:
		for lista in ["sacca", "collezionabili", "chiavi", "armi", "accessori", "oggetti_speciali"]:
			if id_oggetto in foto[lista]:
				cose.append(id_oggetto)
				break
	var numeri: Array = []
	for t in soglie["tazo"]:
		numeri.append(int(foto["tazo"]) >= int(t))
	for t in soglie["legame"]:
		numeri.append(int(foto["legame"]) >= int(t))
	for t in soglie["eroe"]:
		numeri.append(int(foto["scelte_eroe"]) >= int(t))
	for t in soglie["malvagio"]:
		numeri.append(int(foto["scelte_malvagie"]) >= int(t))
	for t in soglie["eroe_max"]:
		numeri.append(int(foto["scelte_eroe"]) <= int(t))
	for t in soglie["malvagio_max"]:
		numeri.append(int(foto["scelte_malvagie"]) <= int(t))
	var visite: Array = []
	for id_nodo in foto["nodi_visitati"]:
		if visite_che_contano.has(String(id_nodo)):
			visite.append(String(id_nodo))
	visite.sort()
	var squadra: Array = (foto["party"] as Array).duplicate()
	squadra.sort()
	# I PROIETTORI NON CI SONO, apposta: aggiungono scorciatoie fra posti gia'
	# visti e non tolgono niente, quindi non possono chiudere una strada. Contarli
	# moltiplicava le situazioni per ogni combinazione di dove li hai piantati
	return "%s#%s#%s#%s#%s#%s#%s" % [pos, ",".join(flag_letti), ",".join(cose), str(numeri), ",".join(squadra),
			",".join(foto["ospiti"]), ",".join(visite)]


func aggiungi(pos: String, foto: Dictionary, da: int, etichetta: String) -> int:
	var k := chiave(pos, foto)
	if indice.has(k):
		return int(indice[k])
	var n := stati.size()
	indice[k] = n
	stati.append({"pos": pos, "foto": foto, "meta": e_una_meta(pos, foto)})
	archi.append([])
	padre.append(da)
	come.append(etichetta)
	if pos.begins_with("T|errore"):
		segnala(pos.substr(9), n)
	if pos.begins_with("T|") and e_una_meta(pos, foto) and finali.size() < 1:
		finali.append(foto)
	return n


# --- le posizioni ----------------------------------------------------------------
#
#   N|<nodo>|<0/1>                  la schermata di un nodo, finita di leggere
#                                   (1 = sta mostrando la scena, non i dialoghi)
#   M|<stanza>|<ritorno>|<0/1>      la mappa di zona (1 = la Guida lascia solo chiudere)
#   C|<vinci>|<eroe>|<perdi>|<fuggi> uno scontro
#   T|<cosa>                        fuori dalla zona: avvio:<id>, sede, vuoto,
#                                   apre:<cosa>, errore:<perche'>

func pos_mappa(stanza: String, ritorno: String, solo_chiudere: bool) -> String:
	return "M|%s|%s|%d" % [stanza, ritorno if ritorno != "" else stanza, int(solo_chiudere)]


func pos_scontro() -> String:
	return "C|%s|%s|%s|%s" % [GameState.nodo_se_vinci, GameState.nodo_se_vinci_eroe, GameState.nodo_se_perdi,
			GameState.nodo_se_fuggi]


func espandi(i: int) -> void:
	var pos := String(stati[i]["pos"])
	var parti := pos.split("|")
	ripristina(stati[i]["foto"])
	var mosse: Array = []
	match parti[0]:
		"N": mosse = dal_nodo(parti[1], parti[2] == "1")
		"M": mosse = dalla_mappa(parti[1], parti[2], parti[3] == "1")
		"C": mosse = dallo_scontro(parti[1], parti[2], parti[3], parti[4])
		"T": mosse = da_fuori(parti[1])
	for m: Array in mosse:
		var j := aggiungi(String(m[1]), m[2], i, String(m[0]))
		if j not in archi[i]:
			archi[i].append(j)


func entra_in(id_nodo: String) -> Array:
	# ENTRARE IN UN NODO, come fa il gioco (IngressoNodo.entra). Se il nodo ha
	# un agguato, le strade sono due: scatta e non scatta
	var base := fotografa()
	var id_vero := IngressoNodo.risolvi(id_nodo)
	var nodo: Dictionary = GameState.eventi.get(id_vero, {})
	var agguato: Dictionary = nodo.get("agguato", {})
	var varianti: Array = [-1.0] if agguato.is_empty() else [0.0, 1.0]
	var risultati: Array = []
	for forza: float in varianti:
		ripristina(base)
		var prima := float(agguato.get("probabilita", 0.3))
		if forza >= 0.0:
			agguato["probabilita"] = forza
		var esito := IngressoNodo.entra(id_nodo)
		if forza >= 0.0:
			agguato["probabilita"] = prima
		if esito.agguato:
			risultati.append(["agguato in %s" % id_vero, pos_scontro(), fotografa()])
		elif String(esito.scena) != "":
			risultati.append(["entra in «%s»" % id_nodo, "T|errore:il nodo «%s» non esiste" % id_nodo, fotografa()])
		else:
			var scena := not bool(esito.prima_visita) and (esito.nodo as Dictionary).has("scena")
			leggi_i_messaggi(esito.nodo, scena)
			risultati.append(["%s" % esito.id, "N|%s|%d" % [esito.id, int(scena)], fotografa()])
	return risultati


func leggi_i_messaggi(nodo: Dictionary, scena: bool) -> void:
	# una battuta puo' accendere un flag (Main.avanza_messaggio): la coda si
	# legge tutta prima delle scelte, quindi qui si accendono tutti
	var messaggi: Array = []
	if scena or (not nodo.has("sequenza") and not nodo.has("testo") and nodo.has("scena")):
		messaggi = nodo["scena"] if nodo.get("scena") is Array else []
	else:
		messaggi = nodo.get("sequenza", [])
	if nodo.get("espulsione_automatica", false):
		messaggi = messaggi.slice(0, 1)
	for msg in messaggi:
		if msg is Dictionary and (msg as Dictionary).has("flag"):
			GameState.imposta_flag(String(msg["flag"]))


func dal_nodo(id_nodo: String, scena: bool) -> Array:
	# Main.disegna_nodo e Main.coda_finita, nello stesso ordine
	var nodo: Dictionary = GameState.eventi.get(id_nodo, {})
	if nodo.get("espulsione_automatica", false):
		GameState.congeda_tutti_temporanei()
		return [["ti rigetta fuori", "T|vuoto", fotografa()]]
	if IngressoNodo.finisce_alla_mappa(nodo):
		if nodo.has("stanza"):
			GameState.nodo_corrente = String(nodo["stanza"])
		return [["alla mappa", pos_mappa(GameState.nodo_corrente, "", false), fotografa()]]
	if nodo.has("apri_mappa_zona") and not scena:
		var dati: Dictionary = nodo["apri_mappa_zona"]
		return [["la Guida sulla mappa", pos_mappa(GameState.nodo_corrente,
				String(dati.get("ritorno", GameState.nodo_corrente)), bool(dati.get("solo_chiudere", false))),
				fotografa()]]
	if nodo.has("combattimento_automatico"):
		return scontro_automatico(nodo["combattimento_automatico"])
	if nodo.has("avvio_automatico"):
		return [["parte", "T|avvio:%s" % String(nodo["avvio_automatico"].get("id_punto", "")), fotografa()]]
	if nodo.has("apri_mappa_stellare"):
		return alla_mappa_stellare(String(nodo["apri_mappa_stellare"]))
	if nodo.has("vai"):
		return entra_in(String(nodo["vai"]))
	return le_scelte(id_nodo, nodo, scena)


func scontro_automatico(dati: Dictionary) -> Array:
	if dati.has("salta_se_flag") and GameState.ha_flag(String(dati["salta_se_flag"])):
		return entra_in(String(dati.get("se_vinci", "")))
	GameState.prepara_combattimento(dati.get("nemici", []), dati.get("se_vinci", ""), dati.get("se_vinci_eroe", ""),
			dati.get("se_perdi", ""), dati.get("se_fuggi", ""), dati.get("regia", {}))
	return [["scontro", pos_scontro(), fotografa()]]


func alla_mappa_stellare(ritorno: String) -> Array:
	# Veronica apre la mappa stellare per la prima missione: ci deve essere
	# almeno un punto da scegliere, o si resta li' (dalla sala di proiezione non
	# c'e' il tasto per la Sede)
	var c_e := false
	for punto: Dictionary in GameState.carica_mappa().get("punti", []):
		if bool(punto.get("prima_missione", false)) and (not punto.has("richiede_flag")
				or GameState.ha_flag(String(punto["richiede_flag"]))):
			c_e = true
	if not GameState.eventi.has(ritorno):
		return [["mappa stellare", "T|errore:la mappa stellare torna a «%s», che non esiste" % ritorno, fotografa()]]
	if not c_e:
		return [["mappa stellare", "T|errore:la mappa stellare della prima missione e' vuota", fotografa()]]
	return entra_in(ritorno)


func le_scelte(id_nodo: String, nodo: Dictionary, scena: bool) -> Array:
	var base := fotografa()
	var mosse: Array = []
	var vere := 0
	for scelta: Dictionary in nodo.get("scelte", []):
		ripristina(base)
		if not IngressoNodo.scelta_visibile(scelta):
			continue
		vere += 1
		var etichetta := "«%s»" % String(scelta.get("testo", "…")).left(40)
		for m: Array in scegli(scelta, id_nodo, scena):
			m[0] = etichetta + (" → " + String(m[0]) if String(m[0]) != "" else "")
			mosse.append(m)
	ripristina(base)
	var mappa_a_portata := GameState.stanza_nella_mappa(GameState.nodo_corrente) and GameState.mappa_consultabile() \
			and not IngressoNodo.trattiene(nodo)
	# l'icona della Guida c'e' solo dove la Guida ha qualcosa da dire sulla mappa
	# (IconaGuida.metti), e la riapre come il tasto della mappa
	var guida := GameState.ha_flag(IconaGuida.FLAG) and not IngressoNodo.trattiene(nodo) \
			and not (GameState.mappa_zona.get("guida", []) as Array).is_empty()
	if mappa_a_portata or guida:
		mosse.append(["mappa", pos_mappa(GameState.nodo_corrente, "", false), fotografa()])
	if vere == 0 and not mappa_a_portata:
		# Main._apri_scelte: la rete di sicurezza. Non deve scattare mai
		segnala("il nodo «%s» finisce senza niente da premere (scatta la rete di sicurezza)" % id_nodo, -1)
		var dove := IngressoNodo.via_d_uscita(GameState.nodo_corrente)
		if dove == IngressoNodo.SCENA_MAPPA_ZONA:
			mosse.append(["rete", pos_mappa(GameState.nodo_corrente, "", false), fotografa()])
		else:
			mosse.append(["rete", "T|errore:rete di sicurezza fuori dalla zona", fotografa()])
	mosse.append_array(i_compagni(id_nodo, scena, base))
	return mosse


func scegli(scelta: Dictionary, id_nodo: String, scena: bool) -> Array:
	# Main._su_scelta: prima gli effetti, poi dove si va, nello stesso ordine
	IngressoNodo.effetti_della_scelta(scelta)
	if scelta.has("combatti"):
		GameState.prepara_combattimento(scelta["combatti"], scelta.get("se_vinci", ""), scelta.get("se_vinci_eroe", ""),
				scelta.get("se_perdi", ""), scelta.get("se_fuggi", ""), scelta.get("regia", {}))
		return [["scontro", pos_scontro(), fotografa()]]
	if scelta.get("torna_vuoto", false):
		GameState.congeda_tutti_temporanei()
		return [["", "T|vuoto", fotografa()]]
	if scelta.get("reset", false):
		chiudi_la_campagna()
		return [["", "T|sede", fotografa()]]
	if scelta.get("game_over", false):
		return game_over()
	if scelta.has("apre"):
		# Sede.apri: squadra e data pad si aprono sopra la stanza, e chiusi si e'
		# ancora li'; dall'emporio si torna alla Sede nella stessa stanza
		match String(scelta["apre"]):
			"squadra", "diario":
				return [["", "N|%s|%d" % [id_nodo, int(scena)], fotografa()]]
			"negozio":
				return [["dall'emporio", pos_mappa(GameState.nodo_corrente, "", false), fotografa()]]
		return [["", "T|apre:%s" % String(scelta["apre"]), fotografa()]]
	if scelta.get("torna_a_mappa", false):
		if scelta.has("stanza"):
			GameState.nodo_corrente = String(scelta["stanza"])
		return [["", pos_mappa(GameState.nodo_corrente, "", false), fotografa()]]
	var dove := IngressoNodo.destinazione(scelta)
	if dove != "":
		return entra_in(dove)
	return [["", "N|%s|%d" % [id_nodo, int(scena)], fotografa()]]


func game_over() -> Array:
	# senza un salvataggio (il primo giorno, le Pianure) si rifa' la zona con
	# quello che si sa; con un salvataggio si torna alla Sede com'eri
	if String(zona["game_over"]) == "salvataggio":
		return [["game over", "T|sede:ripresa", fotografa()]]
	match GameState.game_over():
		"zona":
			return entra_in(GameState.nodo_corrente)
		_:
			return [["game over", "T|sede:ripresa", fotografa()]]


func chiudi_la_campagna() -> void:
	# reset_campagna SVUOTA SUL POSTO il dizionario dei nodi (eventi.clear()), e
	# quel dizionario e' lo stesso in tutte le fotografie: prima di chiuderla se
	# ne mette uno vuoto apposta, se no la zona sparisce anche dalle altre strade
	GameState.eventi = {}
	GameState.reset_campagna()


func i_compagni(id_nodo: String, scena: bool, base: Dictionary) -> Array:
	# Main._su_compagno e _su_conversazione: parlare con chi e' in squadra puo'
	# accendere un flag che apre una scelta
	var mosse: Array = []
	if GameState.party.size() <= 1:
		return mosse
	var voce: Dictionary = GameState.dialoghi.get(GameState.nodo_corrente, {})
	if not voce.is_empty() and not (voce.has("una_tantum") and GameState.ha_flag(voce["una_tantum"])) \
			and (voce.has("flag") or voce.has("una_tantum")):
		ripristina(base)
		for campo in ["flag", "una_tantum"]:
			if voce.has(campo):
				GameState.imposta_flag(String(voce[campo]))
		mosse.append(["parla coi compagni", "N|%s|%d" % [id_nodo, int(scena)], fotografa()])
	var discussione: Dictionary = GameState.conversazioni.get(GameState.nodo_corrente, {})
	var tra: Array = discussione.get("tra", [])
	if tra.size() == 2 and tra[0] in GameState.party and tra[1] in GameState.party \
			and not (discussione.has("una_tantum") and GameState.ha_flag(discussione["una_tantum"])):
		ripristina(base)
		for campo in ["flag", "una_tantum"]:
			if discussione.has(campo):
				GameState.imposta_flag(String(discussione[campo]))
		mosse.append(["ascolta la discussione", "N|%s|%d" % [id_nodo, int(scena)], fotografa()])
	return mosse


func dalla_mappa(stanza: String, ritorno: String, solo_chiudere: bool) -> Array:
	# MappaZona: «Torna alla stanza corrente» (o «Chiudi la mappa» con la Guida),
	# e le stanze in cui si entra. Alla Sede il tasto per tornare non c'e': la
	# pianta e' la Sede
	GameState.nodo_corrente = stanza
	var base := fotografa()
	var mosse: Array = []
	if GameState.carnivalz_corrente != Sede.ZONA:
		for m: Array in entra_in(ritorno):
			m[0] = "torna → " + String(m[0])
			mosse.append(m)
	if not solo_chiudere:
		for s: Dictionary in GameState.mappa_zona.get("stanze", []):
			ripristina(base)
			var id_stanza := String(s.get("id", ""))
			if IngressoNodo.si_entra(id_stanza):
				for m: Array in entra_in(id_stanza):
					m[0] = "mappa → " + String(m[0])
					mosse.append(m)
	if mosse.is_empty():
		mosse.append(["mappa", "T|errore:la mappa in «%s» non ha niente da premere" % stanza, fotografa()])
	return mosse


func dallo_scontro(vinci: String, eroe: String, perdi: String, fuggi: String) -> Array:
	# Combattimento._esci: vinto, vinto convincendo, perso, fuggito
	var base := fotografa()
	var mosse: Array = []
	for coppia in [["vinto", vinci], ["vinto da eroe", eroe], ["perso", perdi], ["fuggito", fuggi]]:
		var dove := String(coppia[1])
		if dove == "" and coppia[0] != "perso":
			continue
		ripristina(base)
		GameState.annulla_combattimento()
		if dove == "":
			# Combattimento._esci: perso senza un posto dove andare, si chiude la
			# campagna e si torna alla Sede. E' un'uscita, non la fine della zona
			chiudi_la_campagna()
			mosse.append([coppia[0], "T|sede:sconfitta", fotografa()])
			continue
		GameState.nodo_corrente = dove
		for m: Array in entra_in(dove):
			m[0] = "%s → %s" % [coppia[0], m[0]]
			mosse.append(m)
	if vinci == "":
		mosse.append(["vinto", "T|errore:uno scontro vinto non dice dove andare", fotografa()])
	return mosse


func da_fuori(cosa: String) -> Array:
	# FUORI DALLA ZONA. Da una frattura si esce nel Vuoto e ci si puo' rientrare:
	# e' la strada che resta a chi ha sbagliato qualcosa dentro, e conta
	if cosa == "vuoto" and String(zona["ingresso"]) == "frattura":
		GameState.entra_squarcio(String(zona["id"]), String(zona["file"]))
		var mosse := entra_in(GameState.nodo_corrente)
		for m: Array in mosse:
			m[0] = "rientra → " + String(m[0])
		return mosse
	if cosa.begins_with("sede:") and String(zona["game_over"]) == "salvataggio":
		# PERSO O RIPRESO DAL SALVATAGGIO: si torna alla Sede com'eri prima di
		# entrare, e da li' si puo' rientrare. Non e' un punto morto: e' ricominciare
		ripristina(foto_ingresso)
		var di_nuovo := ingresso_nella_zona()
		for m: Array in di_nuovo:
			m[0] = "dal salvataggio → " + String(m[0])
		return di_nuovo
	if cosa == "vuoto" and String(zona["ingresso"]) != "frattura":
		segnala("si finisce nel Vuoto da una zona che non e' una frattura («%s»)" % zona["id"], -1)
	return []


# --- il verdetto ---------------------------------------------------------------

func e_una_meta(pos: String, foto: Dictionary) -> bool:
	var flag_meta: Variant = zona.get("flag_meta", [])
	var serve: Array = flag_meta if flag_meta is Array else [flag_meta]
	for f in serve:
		if String(f) != "" and String(f) not in foto["flags"]:
			return false
	if zona.has("meta"):
		return pos == String(zona["meta"])
	# una frattura: la meta sono i suoi flag; se non ne ha, uscirne
	return not serve.is_empty() or pos == "T|vuoto"


func racconta(millisecondi: int) -> void:
	var n := stati.size()
	var uscite: Array[int] = []
	var mete: Array[int] = []
	for i in n:
		var pos := String(stati[i]["pos"])
		if pos.begins_with("T|") and not pos.begins_with("T|errore"):
			uscite.append(i)
		if bool(stati[i]["meta"]) and (pos.begins_with("T|") or not zona.has("meta")):
			mete.append(i)
		if i >= espansi:
			# MAI GUARDATA: non si sa dove porta, e allora si da' per buona. Una
			# situazione non espansa non ha frecce, e senza questa riga ogni
			# esplorazione interrotta diventerebbe un elenco di prigioni finte
			uscite.append(i)
			mete.append(i)
	var verso_l_uscita := all_indietro(uscite)
	var verso_la_meta := all_indietro(mete)
	print("\n=== %s  (%s)" % [zona["id"], String(zona["file"]).get_file()])
	print("    %d situazioni, %d uscite dalla zona, %d volte la meta raggiunta, %.1f s"
			% [n, uscite.size(), mete.size(), millisecondi / 1000.0])
	if mete.is_empty():
		difetti += 1
		print("  ✗ LA META NON SI RAGGIUNGE MAI: %s" % descrivi_meta())
	var prigioni: Array[int] = []
	var morti: Array[int] = []
	for i in n:
		if String(stati[i]["pos"]).begins_with("T|errore"):
			continue
		if not verso_l_uscita.has(i):
			prigioni.append(i)
		elif not verso_la_meta.has(i):
			morti.append(i)
	elenca("PRIGIONI (da qui non si esce piu' dalla zona)", prigioni)
	elenca("PUNTI MORTI (da qui %s non si raggiunge piu')" % descrivi_meta(), morti)
	if espansi < n and OS.get_environment("ESPLORA_PERCHE") != "":
		perche_tante()
	for testo: String in segnalazioni:
		difetti += 1
		print("  ✗ %s" % testo)
		var dove := int(segnalazioni[testo])
		if dove >= 0:
			print("      strada: %s" % strada_fino_a(dove))


func perche_tante() -> void:
	# quale pezzo della chiave fa esplodere le situazioni: quanti valori diversi
	# prende ognuno, e quali flag cambiano piu' spesso
	var nomi := ["pos", "flag", "oggetti", "numeri", "squadra", "ospiti", "visite"]
	var diversi: Array = []
	for _n in nomi:
		diversi.append({})
	var quante_volte := {}
	for k: String in indice:
		var parti := k.split("#")
		for p in parti.size():
			diversi[p][parti[p]] = true
		for f in parti[1].split(","):
			quante_volte[f] = int(quante_volte.get(f, 0)) + 1
	for p in nomi.size():
		print("      %s: %d valori diversi" % [nomi[p], (diversi[p] as Dictionary).size()])
	var flag_ordinati: Array = quante_volte.keys()
	flag_ordinati.sort_custom(func(a: String, b: String) -> bool:
		return absi(int(quante_volte[a]) * 2 - indice.size()) < absi(int(quante_volte[b]) * 2 - indice.size()))
	print("      i flag piu' «a meta'» (quelli che raddoppiano): %s" % ", ".join(flag_ordinati.slice(0, 12)))
	print("      oggetti che contano: %s" % ", ".join(oggetti_che_contano.keys()))
	print("      soglie: %s" % str(soglie))


func descrivi_meta() -> String:
	var flag_meta: Variant = zona.get("flag_meta", [])
	var parole: Array = []
	if zona.has("meta"):
		parole.append(String(zona["meta"]).substr(2))
	if flag_meta is Array and not (flag_meta as Array).is_empty():
		parole.append("i flag " + ", ".join(flag_meta))
	elif flag_meta is String and flag_meta != "":
		parole.append("il flag " + String(flag_meta))
	return " con ".join(parole) if not parole.is_empty() else "l'uscita"


func all_indietro(arrivi: Array[int]) -> Dictionary:
	# chi arriva, seguendo gli archi all'indietro, a uno di questi
	var entranti: Array = []
	entranti.resize(stati.size())
	for i in stati.size():
		entranti[i] = []
	for i in stati.size():
		for j in archi[i]:
			(entranti[j] as Array).append(i)
	var visti := {}
	var coda: Array[int] = arrivi.duplicate()
	for a in arrivi:
		visti[a] = true
	while not coda.is_empty():
		var j: int = coda.pop_back()
		for i in entranti[j]:
			if not visti.has(i):
				visti[i] = true
				coda.append(i)
	return visti


func elenca(titolo: String, quali: Array[int]) -> void:
	if quali.is_empty():
		return
	difetti += 1
	print("  ✗ %d %s" % [quali.size(), titolo])
	# i piu' vicini all'inizio: sono quelli che un giocatore incontra davvero
	var per_distanza := quali.duplicate()
	per_distanza.sort_custom(func(a: int, b: int) -> bool: return profondita(a) < profondita(b))
	for i in per_distanza.slice(0, ESEMPI):
		print("      %s" % String(stati[i]["pos"]))
		print("        strada: %s" % strada_fino_a(i))


func profondita(i: int) -> int:
	var passi := 0
	while i >= 0 and passi < 10000:
		i = padre[i]
		passi += 1
	return passi


func strada_fino_a(i: int) -> String:
	var passi: Array[String] = []
	while i >= 0:
		passi.push_front(come[i])
		i = padre[i]
	if passi.size() > 14:
		var corta: Array[String] = passi.slice(0, 3)
		corta.append("…")
		corta.append_array(passi.slice(passi.size() - 10))
		passi = corta
	return " / ".join(passi)


func segnala(testo: String, dove: int) -> void:
	if not segnalazioni.has(testo):
		segnalazioni[testo] = dove
