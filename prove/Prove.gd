extends Node

# Le prove del progetto. Girano dentro Godot vero, con gli autoload caricati,
# quindi possono usare GameState e i suoi dati come li usa il gioco.
#
#   /percorso/godot --headless --path . prove/Prove.tscn
#
# Esce con codice 0 se passa tutto, 1 se qualcosa e' rotto: cosi' si puo'
# mettere in una pipeline e sapere che una modifica ha rotto qualcosa PRIMA
# di scoprirlo giocando. Per un gioco fatto di dati come questo, un id
# sbagliato dentro un JSON non e' un errore di compilazione: e' un vicolo
# cieco che il giocatore trova venti minuti dopo. Queste prove servono a
# quello, non a coprire percentuali di codice.

# Le 16 espressioni dei ritratti nei dialoghi (vedi art/personaggi/README.md).
# "neutra" e' quella di ripiego quando un dialogo ne chiede una che non c'e'.
const ESPRESSIONI := [
	"neutra", "arrabbiata", "felice", "carina", "infastidita", "disgusto",
	"speciale", "dialogo", "delusa", "petrificata", "annoiata", "pensiero",
	"sorpresa", "sforzo", "cool", "decisa",
]

const ICONE_MAPPA := ["boss", "miniboss", "forte", "uscita", "negozio", "personaggio", "chiave"]

var fallimenti: Array[String] = []
var conteggio := 0

func _ready() -> void:
	print("\n=== PROVE CARNIVALZ ===\n")
	prova_dati_caricati()
	prova_riferimenti_eventi()
	prova_nodi_raggiungibili()
	prova_riferimenti_creature()
	prova_agguati()
	prova_agguati_hanno_una_via_duscita()
	prova_riferimenti_oggetti()
	prova_negozi()
	prova_appunti()
	prova_mappe()
	prova_equipaggiamento()
	prova_crescita()
	prova_salvataggio()
	prova_zaino()
	prova_compagni_temporanei()
	prova_carte()
	prova_slot_accessori()
	prova_scheda_personaggio()
	prova_finale_scriptato()
	prova_salvataggio_vecchio()
	prova_ingresso_nodi()
	prova_gerarchia_schermate()
	prova_sede()
	prova_posti_visitati()
	prova_livello_dei_nemici()
	prova_curva_creature()
	prova_salire_di_livello_non_peggiora()
	prova_crescita_non_scappa()
	prova_la_difesa_riduce_non_cancella()
	prova_i_boss_non_si_superano_farmando()
	prova_salita_di_livello_si_racconta()
	prova_guardia_a_scatti()
	prova_corazza_che_cresce()
	prova_colori_del_danno()
	prova_abilita_di_combattimento()
	await prova_carta_del_titolo_sta_su_una_riga()
	prova_barra_di_dominio_si_vede()
	prova_ogni_abilita_gira_davvero()
	prova_attacchi_darma()
	prova_linee_abilita()
	prova_punti_abilita()
	prova_abilita_arrivano_al_livello_giusto()
	prova_transizioni()
	prova_suoni()
	prova_game_over_ricarica_davvero()
	prova_espressione_per_battuta()
	prova_nomi_delle_immagini()
	prova_illustrazioni()
	prova_leva_bersaglio()
	prova_mappa_a_quadratini()
	prova_script_compilano()
	prova_scene_caricabili()
	stampa_esito()

func esigi(condizione: bool, messaggio: String) -> void:
	conteggio += 1
	if not condizione:
		fallimenti.append(messaggio)

func titolo(testo: String) -> void:
	print("--- %s" % testo)

# --- i dati ci sono e non sono vuoti ---

func prova_dati_caricati() -> void:
	titolo("dati caricati")
	esigi(not GameState.classi.is_empty(), "classes.json non caricato")
	esigi(not GameState.personaggi.is_empty(), "personaggi.json non caricato")
	esigi(not GameState.oggetti.is_empty(), "oggetti.json non caricato")
	esigi(not GameState.regole.is_empty(), "regole.json non caricato")
	esigi(not GameState.stati.is_empty(), "stati.json non caricato")
	esigi(not GameState.crescita.is_empty(), "crescita.json non caricato")
	esigi(not GameState.negozi.is_empty(), "negozi.json non caricato")
	esigi(not GameState.task_catalogo.is_empty(), "task.json non caricato")
	esigi(GameState.id_protagonista != "", "protagonista non definito in classes.json")

# --- ogni file di eventi ---

func creature() -> Array[String]:
	# l'elenco delle creature che combattono, in un posto solo. Serve alle prove
	# per dire "le ho guardate tutte": un filtro sbagliato dentro una prova la fa
	# restringere in silenzio, e una prova che guarda meta' del gioco passa
	# esattamente come una che lo guarda tutto
	var elenco: Array[String] = []
	for id_creatura in GameState.personaggi:
		if GameState.e_creatura(id_creatura):
			elenco.append(String(id_creatura))
	elenco.sort()
	return elenco

func file_eventi() -> Array[String]:
	var elenco: Array[String] = [
		"res://data/events_intro.json",
		"res://data/events_tutorial.json",
		"res://data/events.json",
	]
	var cartella := DirAccess.open("res://data/vuoti")
	if cartella != null:
		for nome in cartella.get_files():
			if nome.ends_with(".json"):
				elenco.append("res://data/vuoti/" + nome)
	return elenco

func carica_eventi(percorso: String) -> Dictionary:
	var dati: Variant = GameState.carica_json(percorso)
	return dati if dati is Dictionary else {}

func destinazioni_di(nodo: Dictionary) -> Array[String]:
	# ogni posto in cui un nodo puo' mandare il giocatore
	var uscite: Array[String] = []
	for chiave in ["vai"]:
		if nodo.has(chiave):
			uscite.append(String(nodo[chiave]))
	var salto: Dictionary = nodo.get("vai_se_flag", {})
	if salto.has("vai"):
		uscite.append(String(salto["vai"]))
	for blocco_nome in ["combattimento_automatico", "agguato"]:
		var blocco: Dictionary = nodo.get(blocco_nome, {})
		for chiave in ["se_vinci", "se_vinci_eroe", "se_perdi", "se_fuggi"]:
			if blocco.has(chiave):
				uscite.append(String(blocco[chiave]))
	for scelta in nodo.get("scelte", []):
		for chiave in ["vai", "se_vinci", "se_vinci_eroe", "se_perdi", "se_fuggi"]:
			if scelta.has(chiave):
				uscite.append(String(scelta[chiave]))
	return uscite

func prova_riferimenti_eventi() -> void:
	titolo("ogni destinazione punta a un nodo che esiste")
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		var nodi: Dictionary = dati.get("nodi", {})
		esigi(not nodi.is_empty(), "%s: nessun nodo" % percorso)
		var iniziale := String(dati.get("nodo_iniziale", ""))
		esigi(nodi.has(iniziale), "%s: nodo_iniziale '%s' non esiste" % [percorso, iniziale])
		for id_nodo in nodi:
			for destinazione in destinazioni_di(nodi[id_nodo]):
				esigi(nodi.has(destinazione),
						"%s: il nodo '%s' manda a '%s', che non esiste" % [percorso, id_nodo, destinazione])

func prova_nodi_raggiungibili() -> void:
	# un nodo che nessuno raggiunge e' contenuto scritto e mai visto: o e'
	# un errore di collegamento, o e' lavoro buttato. In tutti e due i casi
	# va saputo
	titolo("nessun nodo orfano")
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		var nodi: Dictionary = dati.get("nodi", {})
		if nodi.is_empty():
			continue
		var visti: Dictionary = {}
		var da_visitare: Array[String] = [String(dati.get("nodo_iniziale", ""))]
		while not da_visitare.is_empty():
			var corrente: String = da_visitare.pop_back()
			if corrente in visti or not nodi.has(corrente):
				continue
			visti[corrente] = true
			for destinazione in destinazioni_di(nodi[corrente]):
				da_visitare.append(destinazione)
		for id_nodo in nodi:
			esigi(visti.has(id_nodo),
					"%s: il nodo '%s' non e' raggiungibile da nessuna parte" % [percorso, id_nodo])

func prova_riferimenti_creature() -> void:
	titolo("ogni creatura evocata in un combattimento esiste")
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		for id_nodo in dati.get("nodi", {}):
			var nodo: Dictionary = dati["nodi"][id_nodo]
			var gruppi: Array = []
			var automatico: Dictionary = nodo.get("combattimento_automatico", {})
			if automatico.has("nemici"):
				gruppi.append(automatico["nemici"])
			for scelta in nodo.get("scelte", []):
				if scelta.has("combatti"):
					gruppi.append(scelta["combatti"])
			# gli agguati hanno una lista di gruppi possibili, uno per tiro
			for gruppo_agguato in nodo.get("agguato", {}).get("gruppi", []):
				gruppi.append(gruppo_agguato)
			for gruppo in gruppi:
				for id_nemico in gruppo:
					esigi(GameState.personaggi.has(String(id_nemico)),
							"%s/%s: il nemico '%s' non esiste in personaggi.json"
							% [percorso, id_nodo, id_nemico])
			# chi parla in una battuta deve esistere
			for msg in nodo.get("sequenza", []):
				if String(msg.get("tipo", "")) != "dialogo" or not msg.has("chi"):
					continue
				var chi := String(msg["chi"])
				esigi(GameState.personaggi.has(chi) or GameState.classi.has(chi),
						"%s/%s: parla '%s', che non e' ne' un personaggio ne' una classe"
						% [percorso, id_nodo, chi])
	titolo("le creature evocate dalle mosse esistono")
	for id_creatura in GameState.personaggi:
		var dati_creatura: Dictionary = GameState.personaggi[id_creatura]
		for mossa in dati_creatura.get("mosse", []):
			if String(mossa.get("tipo", "")) == "evoca":
				esigi(GameState.personaggi.has(String(mossa.get("valore", ""))),
						"%s: evoca '%s', che non esiste" % [id_creatura, mossa.get("valore", "")])
		var frenesia: Dictionary = dati_creatura.get("frenesia", {})
		if frenesia.has("bersaglio_extra"):
			esigi(GameState.personaggi.has(String(frenesia["bersaglio_extra"])),
					"%s: bersaglio_extra '%s' non esiste" % [id_creatura, frenesia["bersaglio_extra"]])

func prova_agguati() -> void:
	titolo("agguati")
	var alzati := flag_alzati()
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		for id_nodo in dati.get("nodi", {}):
			var agguato: Dictionary = dati["nodi"][id_nodo].get("agguato", {})
			if agguato.is_empty():
				continue
			esigi(not agguato.get("gruppi", []).is_empty(),
					"%s/%s: agguato senza gruppi di nemici" % [percorso, id_nodo])
			var probabilita := float(agguato.get("probabilita", 0.3))
			esigi(probabilita > 0.0 and probabilita <= 1.0,
					"%s/%s: probabilita' d'agguato fuori scala (%f)" % [percorso, id_nodo, probabilita])
			if agguato.has("salta_se_flag"):
				esigi(alzati.has(String(agguato["salta_se_flag"])),
						"%s/%s: l'agguato si spegne col flag '%s', che nessuno alza mai"
						% [percorso, id_nodo, agguato["salta_se_flag"]])

func prova_riferimenti_oggetti() -> void:
	titolo("ogni oggetto nominato esiste")
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		for id_nodo in dati.get("nodi", {}):
			var nodo: Dictionary = dati["nodi"][id_nodo]
			for scelta in nodo.get("scelte", []):
				# "oggetto" accetta un id singolo o una lista (una scelta puo'
				# far raccogliere due fiale): si legge con lo stesso lettore che
				# usa il gioco, altrimenti la prova guarda un'altra cosa
				for chiave in ["oggetto", "oggetti", "richiede_oggetto"]:
					for id_oggetto in IngressoNodo.lista_id(scelta.get(chiave, [])):
						esigi(GameState.oggetti.has(id_oggetto),
								"%s/%s: l'oggetto '%s' non esiste" % [percorso, id_nodo, id_oggetto])
				for id_oggetto in scelta.get("richiede_oggetti", []):
					esigi(GameState.oggetti.has(String(id_oggetto)),
							"%s/%s: l'oggetto '%s' non esiste" % [percorso, id_nodo, id_oggetto])
	titolo("bottini, leve e premi delle creature")
	for id_creatura in GameState.personaggi:
		var dati_creatura: Dictionary = GameState.personaggi[id_creatura]
		for voce in dati_creatura.get("bottino_comune", []):
			esigi(GameState.oggetti.has(String(voce.get("oggetto", ""))),
					"%s: bottino '%s' non esiste" % [id_creatura, voce.get("oggetto", "")])
		var raro: Dictionary = dati_creatura.get("drop_raro", {})
		if raro.has("oggetto"):
			esigi(GameState.oggetti.has(String(raro["oggetto"])),
					"%s: drop raro '%s' non esiste" % [id_creatura, raro["oggetto"]])
		var risparmio: Dictionary = dati_creatura.get("risparmio", {})
		if risparmio.has("oggetto"):
			esigi(GameState.oggetti.has(String(risparmio["oggetto"])),
					"%s: premio del risparmio '%s' non esiste" % [id_creatura, risparmio["oggetto"]])
		for leva in dati_creatura.get("leve", []):
			if String(leva.get("tipo", "")) == "oggetto":
				esigi(GameState.oggetti.has(String(leva.get("id", ""))),
						"%s: leva su '%s', che non esiste" % [id_creatura, leva.get("id", "")])

func prova_negozi() -> void:
	titolo("negozi")
	for id_negozio in GameState.negozi:
		var negozio: Dictionary = GameState.negozi[id_negozio]
		for voce in negozio.get("stock", []):
			var id_oggetto := String(voce.get("oggetto", ""))
			esigi(GameState.oggetti.has(id_oggetto),
					"negozio %s: vende '%s', che non esiste" % [id_negozio, id_oggetto])
			esigi(int(voce.get("prezzo", 0)) > 0,
					"negozio %s: '%s' costa zero" % [id_negozio, id_oggetto])
		for baratto in negozio.get("baratti", []):
			for id_materiale in baratto.get("richiede", []):
				esigi(GameState.oggetti.has(String(id_materiale)),
						"negozio %s: baratto chiede '%s', che non esiste" % [id_negozio, id_materiale])
			esigi(GameState.oggetti.has(String(baratto.get("produce", ""))),
					"negozio %s: baratto produce '%s', che non esiste" % [id_negozio, baratto.get("produce", "")])

func flag_alzati() -> Dictionary:
	# tutti i flag che il gioco alza da qualche parte, per sapere se una
	# condizione e' soddisfacibile o se e' una porta murata
	var alzati: Dictionary = {}
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		for id_nodo in dati.get("nodi", {}):
			var nodo: Dictionary = dati["nodi"][id_nodo]
			for chiave in ["flag", "una_tantum"]:
				if nodo.has(chiave):
					alzati[String(nodo[chiave])] = true
			for scelta in nodo.get("scelte", []):
				for chiave in ["flag", "una_tantum"]:
					if scelta.has(chiave):
						alzati[String(scelta[chiave])] = true
			for id_stanza in nodo.get("sblocca_stanze", []):
				alzati["__stanza__" + String(id_stanza)] = true
	# ANCHE I COMPAGNI ALZANO FLAG. La botola della Casa Gigante si scopre
	# parlando con Yhvina, e quel dialogo sta in dialoghi.json, non nei file di
	# eventi: guardando solo quelli, un flag alzato li' sembra non alzato da
	# nessuno e la prova sugli appunti grida al lupo su un appunto sanissimo.
	for contenitore in [GameState.dialoghi, GameState.conversazioni]:
		for id_nodo in contenitore:
			var voce: Dictionary = contenitore[id_nodo]
			for chiave in ["flag", "una_tantum"]:
				if voce.has(chiave):
					alzati[String(voce[chiave])] = true
			for opzione in voce.get("mediazione", {}).get("opzioni", []):
				for chiave in ["flag", "una_tantum"]:
					if opzione.has(chiave):
						alzati[String(opzione[chiave])] = true
	return alzati

func prova_appunti() -> void:
	titolo("appunti del Diario")
	var alzati := flag_alzati()
	var visti: Dictionary = {}
	for voce in GameState.task_catalogo:
		var id_task := String(voce.get("id", ""))
		esigi(id_task != "", "un appunto non ha id")
		esigi(not visti.has(id_task), "appunto '%s' definito due volte" % id_task)
		visti[id_task] = true
		esigi(String(voce.get("titolo", "")) != "", "appunto '%s' senza titolo" % id_task)
		esigi(String(voce.get("testo", "")) != "", "appunto '%s' senza testo" % id_task)
		for nome_flag in voce.get("richiede_flags", []):
			esigi(alzati.has(String(nome_flag)),
					"appunto '%s': aspetta il flag '%s', che nessuno alza mai" % [id_task, nome_flag])
		for nome_flag in voce.get("chiuso_da", []):
			esigi(alzati.has(String(nome_flag)),
					"appunto '%s': si chiude col flag '%s', che nessuno alza mai" % [id_task, nome_flag])
		var chi := String(voce.get("da", ""))
		if chi != "":
			esigi(GameState.personaggi.has(chi) or GameState.classi.has(chi),
					"appunto '%s': lo chiede '%s', che non esiste" % [id_task, chi])

func prova_mappe() -> void:
	titolo("mappa stellare e mappe delle zone")
	var mappa: Variant = GameState.carica_json("res://data/mappa.json")
	esigi(mappa is Dictionary, "mappa.json non caricata")
	if mappa is Dictionary:
		for punto in mappa.get("punti", []):
			for vuoto in punto.get("vuoti", []):
				var file_vuoto := String(vuoto.get("file_eventi", ""))
				esigi(file_vuoto == "" or FileAccess.file_exists(file_vuoto),
						"lo squarcio '%s' punta a '%s', che non esiste" % [vuoto.get("id", "?"), file_vuoto])
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		var mappa_zona: Dictionary = dati.get("mappa_dungeon", {})
		if mappa_zona.is_empty():
			continue
		var nodi: Dictionary = dati.get("nodi", {})
		var stanze: Dictionary = {}
		# DUE STANZE NON POSSONO STARE SULLO STESSO QUADRATINO.
		#
		# Da quando una stanza puo' essere grande (campo "dimensione"), allargarne
		# una di un quadratino puo' farla finire sopra la vicina. A schermo non
		# si vede un errore: si vede un quadrato che ne copre un altro, e la
		# stanza sotto diventa incliccabile. Qui si tiene il conto di ogni cella
		# occupata, cosi' la sovrapposizione non e' improbabile: non passa.
		var occupate: Dictionary = {}
		esigi(String(mappa_zona.get("nome", "")) != "",
				"%s: la mappa della zona non ha nome" % percorso)
		for stanza in mappa_zona.get("stanze", []):
			var id_stanza := String(stanza.get("id", ""))
			stanze[id_stanza] = true
			esigi(nodi.has(id_stanza),
					"%s: la mappa mostra la stanza '%s', che non e' un nodo" % [percorso, id_stanza])
			esigi(String(stanza.get("nome", "")) != "",
					"%s: la stanza '%s' non ha nome sulla mappa" % [percorso, id_stanza])
			var cella: Array = stanza.get("cella", [])
			esigi(cella.size() == 2 and int(cella[0]) >= 0 and int(cella[1]) >= 0,
					"%s: la stanza '%s' non ha una cella valida sulla griglia" % [percorso, id_stanza])
			if cella.size() != 2:
				continue
			var misura: Array = stanza.get("dimensione", [1, 1])
			esigi(misura.size() == 2 and int(misura[0]) >= 1 and int(misura[1]) >= 1,
					"%s: la stanza '%s' ha una dimensione impossibile" % [percorso, id_stanza])
			var tipo := String(stanza.get("tipo", "normale"))
			esigi(tipo in ["normale", "segreta"],
					"%s: la stanza '%s' e' di tipo '%s', che non esiste" % [percorso, id_stanza, tipo])
			if stanza.has("icona"):
				esigi(String(stanza["icona"]) in ICONE_MAPPA,
						"%s: la stanza '%s' chiede l'icona '%s', che non esiste"
						% [percorso, id_stanza, stanza["icona"]])
			for dx in maxi(int(misura[0]), 1):
				for dy in maxi(int(misura[1]), 1):
					var chiave := "%d,%d" % [int(cella[0]) + dx, int(cella[1]) + dy]
					esigi(not occupate.has(chiave),
							"%s: '%s' e '%s' occupano lo stesso quadratino %s"
							% [percorso, occupate.get(chiave, "?"), id_stanza, chiave])
					occupate[chiave] = id_stanza
		for coppia in mappa_zona.get("connessioni", []):
			for estremo in coppia:
				esigi(stanze.has(String(estremo)),
						"%s: connessione verso '%s', che non e' sulla mappa" % [percorso, estremo])

func prova_equipaggiamento() -> void:
	titolo("equipaggiamento: slot, tipi e somme")
	GameState.nuova_partita()
	var eroe := GameState.id_protagonista
	# un accessorio non entra nello slot dell'arma
	GameState.accessori.append("amuleto_di_pietra")
	esigi(not GameState.equipaggia(eroe, "arma", "amuleto_di_pietra"),
			"un amuleto e' entrato nello slot dell'arma")
	esigi(GameState.equipaggia(eroe, "accessori", "amuleto_di_pietra"),
			"l'amuleto non entra nello slot accessori")
	# quanto dia lo si chiede al suo file, non lo si scrive qui: se un giorno i
	# numeri del gioco vengono riscalati, questa prova deve continuare a
	# verificare la REGOLA (l'oggetto addosso conta) e non un valore di allora
	var difesa_amuleto := int(GameState.dati_oggetto("amuleto_di_pietra")
			.get("effetto_equipaggiato", {}).get("difesa", 0))
	esigi(difesa_amuleto > 0, "l'amuleto di pietra non dichiara nessuna difesa")
	esigi(GameState.bonus_equipaggiamento(eroe, "difesa") == difesa_amuleto,
			"l'amuleto di pietra non da' la difesa che dichiara (%d)" % difesa_amuleto)
	# lo stesso oggetto non puo' stare addosso a due persone
	esigi(GameState.e_equipaggiato("amuleto_di_pietra"), "l'oggetto addosso non risulta equipaggiato")
	esigi(GameState.portatore_di("amuleto_di_pietra") == eroe, "il portatore non e' quello giusto")
	# gli slot accessori sono limitati
	var massimo := int(GameState.regole.get("slot_accessori", 4))
	for i in range(massimo + 2):
		var finto := "amuleto_di_ferro" if i % 2 == 0 else "amuleto_di_vento"
		GameState.accessori.append(finto)
		GameState.equipaggia(eroe, "accessori", finto)
	var addosso: Array = GameState.slot_di(eroe)["accessori"]
	esigi(addosso.size() <= massimo,
			"si possono mettere %d accessori, il massimo e' %d" % [addosso.size(), massimo])
	# gli stigmi tolgono davvero
	GameState.nuova_partita()
	GameState.accessori.append("stigma_del_muto")
	GameState.equipaggia(eroe, "stigma", "stigma_del_muto")
	var patto: Dictionary = GameState.dati_oggetto("stigma_del_muto").get("effetto_equipaggiato", {})
	esigi(int(patto.get("difesa", 0)) > 0 and int(patto.get("attacco", 0)) < 0,
			"lo stigma del muto non e' piu' un patto: deve dare difesa e togliere attacco")
	esigi(GameState.bonus_equipaggiamento(eroe, "difesa") == int(patto.get("difesa", 0)),
			"lo stigma del muto non da' la difesa che dichiara")
	esigi(GameState.bonus_equipaggiamento(eroe, "attacco") == int(patto.get("attacco", 0)),
			"lo stigma del muto non toglie l'attacco che dichiara")
	# togliere svuota lo slot
	GameState.togli_oggetto_equipaggiato("stigma_del_muto")
	esigi(GameState.bonus_equipaggiamento(eroe, "difesa") == 0, "togliere lo stigma non toglie il bonus")
	GameState.nuova_partita()

func prova_crescita() -> void:
	titolo("crescita e statistiche")
	GameState.nuova_partita()
	for nome_azione in GameState.crescita.get("crescita", {}):
		var regola: Dictionary = GameState.crescita["crescita"][nome_azione]
		var nome_stat := String(regola.get("stat", ""))
		esigi(GameState.crescita.get("stat", {}).has(nome_stat),
				"la regola di crescita '%s' fa salire '%s', che non e' una statistica"
				% [nome_action_sicuro(nome_azione), nome_stat])
		esigi(int(regola.get("ogni", 0)) > 0,
				"la regola '%s' ha 'ogni' a zero: divisione impossibile" % nome_action_sicuro(nome_azione))
	for gruppo in ["passive_livello", "passive_soglia", "passive_rare"]:
		for passiva in GameState.crescita.get(gruppo, []):
			esigi(String(passiva.get("id", "")) != "", "una passiva di %s non ha id" % gruppo)
			esigi(String(passiva.get("nome", "")) != "",
					"la passiva '%s' non ha nome" % passiva.get("id", "?"))

func nome_action_sicuro(valore: Variant) -> String:
	return String(valore)

func prova_salvataggio() -> void:
	# il salvataggio e' l'unico posto dove un errore costa al giocatore ore di
	# gioco. Ogni volta che si aggiunge un campo allo stato va verificato che
	# faccia il giro completo: scritto, riletto, uguale a prima
	titolo("salvataggio: scrivi, rileggi, confronta")
	GameState.nuova_partita()
	var eroe := GameState.id_protagonista
	GameState.tazo = 137
	GameState.fonti_estinte = 2
	GameState.legame = 44
	GameState.imposta_flag("prova_salvataggio")
	GameState.aggiungi_oggetto("fiala_hp")
	GameState.aggiungi_oggetto("amuleto_di_ferro")
	GameState.equipaggia(eroe, "accessori", "amuleto_di_ferro")
	GameState.equipaggia(eroe, "ultima_risorsa", "fiala_hp")
	GameState.registra_azione("attacchi_sferrati", 3)
	var attacco_prima := GameState.bonus_equipaggiamento(eroe, "attacco")

	var percorso := "user://prova_salvataggio.json"
	GameState._scrivi_salvataggio(percorso)
	esigi(FileAccess.file_exists(percorso), "il salvataggio non e' stato scritto")

	GameState.nuova_partita()
	esigi(GameState.tazo != 137, "nuova_partita non ha ripulito i Tazo")
	esigi(GameState._leggi_salvataggio(percorso), "il salvataggio non si rilegge")

	esigi(GameState.tazo == 137, "Tazo persi nel salvataggio (%d invece di 137)" % GameState.tazo)
	esigi(GameState.fonti_estinte == 2, "fonti estinte perse nel salvataggio")
	esigi(GameState.legame == 44, "legame perso nel salvataggio")
	esigi(GameState.ha_flag("prova_salvataggio"), "flag persi nel salvataggio")
	esigi("fiala_hp" in GameState.sacca, "la sacca non e' stata salvata")
	esigi("amuleto_di_ferro" in GameState.accessori, "l'armadio non e' stato salvato")
	esigi(GameState.equipaggiato_in(eroe, "accessori", 0) == "amuleto_di_ferro",
			"l'accessorio addosso non e' stato salvato")
	esigi(GameState.equipaggiato_in(eroe, "ultima_risorsa") == "fiala_hp",
			"l'ultima risorsa non e' stata salvata")
	esigi(GameState.bonus_equipaggiamento(eroe, "attacco") == attacco_prima,
			"il bonus dell'equipaggiamento non sopravvive al salvataggio")
	esigi(int(GameState.contatori.get("attacchi_sferrati", 0)) == 3,
			"i contatori della crescita non sopravvivono al salvataggio")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(percorso))
	GameState.nuova_partita()

func prova_zaino() -> void:
	# Lo zaino e' diviso per categoria e ogni categoria ha il suo tetto, che si
	# alza comprando spazio. Le tabelle in regole.json sono la capacita' TOTALE
	# a ogni acquisto: se qualcuno le legge come incrementi, i numeri che il
	# giocatore vede al negozio smettono di combaciare con quelli che ottiene.
	titolo("lo zaino: categorie, capacita', spazi comprati")
	GameState.nuova_partita()
	for categoria: String in ["consumabili", "armi", "accessori"]:
		var dati: Dictionary = GameState.regole.get("zaino", {}).get(categoria, {})
		esigi(not dati.is_empty(), "manca la capacita' di '%s' in regole.json" % categoria)
		var scala: Array = dati.get("scala", [])
		esigi(GameState.capacita_zaino(categoria) == int(dati.get("base", 0)),
				"%s: senza acquisti la capacita' non e' quella di base" % categoria)
		var precedente := int(dati.get("base", 0))
		for i in range(scala.size()):
			esigi(GameState.compra_spazio(categoria), "%s: acquisto %d rifiutato" % [categoria, i + 1])
			var adesso := GameState.capacita_zaino(categoria)
			esigi(adesso == int(scala[i]),
					"%s: dopo %d acquisti la capacita' dovrebbe essere %d, e' %d"
					% [categoria, i + 1, int(scala[i]), adesso])
			esigi(adesso > precedente, "%s: l'acquisto %d non allarga niente" % [categoria, i + 1])
			precedente = adesso
		esigi(not GameState.compra_spazio(categoria),
				"%s: si compra spazio anche oltre l'ultimo gradino" % categoria)
	# gli oggetti speciali non hanno tetto: sono la storia che ti porti dietro
	esigi(GameState.capacita_zaino("speciali") < 0, "gli oggetti speciali non devono avere un limite")
	# il tetto e' vero: a scomparto pieno non entra piu' niente
	GameState.nuova_partita()
	var consumabile := ""
	for dati_oggetto in GameState.oggetti.values():
		if dati_oggetto is Dictionary and String(dati_oggetto.get("tipo", "")) == "consumabile":
			consumabile = String(dati_oggetto.get("id", ""))
			break
	if consumabile != "":
		var tetto := GameState.capacita_zaino("consumabili")
		for i in range(tetto + 5):
			GameState.aggiungi_oggetto(consumabile)
		esigi(GameState.sacca.size() == tetto,
				"la sacca sfonda il tetto: %d oggetti su %d posti" % [GameState.sacca.size(), tetto])
	# comprare uno spazio non lascia niente in mano: allarga e basta
	GameState.nuova_partita()
	var prima := GameState.capacita_zaino("consumabili")
	var pezzi_prima := GameState.sacca.size() + GameState.oggetti_speciali.size()
	esigi(GameState.aggiungi_oggetto("spazio_nella_realta"), "lo spazio nella realta' non si compra")
	esigi(GameState.capacita_zaino("consumabili") > prima, "comprare spazio non allarga la sacca")
	esigi(GameState.sacca.size() + GameState.oggetti_speciali.size() == pezzi_prima,
			"lo spazio nella realta' e' finito nello zaino invece di allargarlo")

func prova_compagni_temporanei() -> void:
	# Chi ti accompagna per un tratto non e' ancora dei tuoi: combatte al tuo
	# fianco ma non gli si affida niente. E quando qualcuno se ne va, le sue
	# cose tornano nello zaino - erano tue, gliele avevi prestate.
	titolo("compagni temporanei: niente da tenere, e niente da portarsi via")
	GameState.nuova_partita()
	var accessorio := ""
	for dati in GameState.oggetti.values():
		if dati is Dictionary and String(dati.get("tipo", "")) == "accessorio":
			accessorio = String(dati.get("id", ""))
			break
	if accessorio == "":
		return
	var ospite := "sopravvissuta"
	GameState.alleati_temporanei.append(ospite)
	GameState.aggiungi_oggetto(accessorio)
	GameState.togli_oggetto_equipaggiato(accessorio)
	esigi(not GameState.e_definitivo(ospite), "un alleato temporaneo risulta definitivo")
	esigi(not GameState.equipaggia(ospite, "accessori", accessorio),
			"si riesce a equipaggiare un compagno che e' con te solo per un tratto")
	# diventa definitivo: adesso si'
	GameState.alleati_temporanei.erase(ospite)
	esigi(GameState.equipaggia(ospite, "accessori", accessorio),
			"un compagno definitivo non riesce a equipaggiare niente")
	# e se se ne va, l'oggetto resta a te
	GameState.alleati_temporanei.append(ospite)
	GameState.congeda(ospite)
	esigi(GameState.portatore_di(accessorio) == "",
			"chi lascia la squadra si porta via le tue cose")
	esigi(accessorio in GameState.accessori,
			"l'oggetto di chi ha lasciato la squadra non e' tornato nello zaino")

func prova_carte() -> void:
	# I doppioni non si buttano: si accumulano, e si vendono o si scambiano.
	# L'ultima copia pero' non si cede mai - l'album non si buca.
	titolo("carte: doppioni, finiture, scambi")
	GameState.nuova_partita()
	esigi(GameState.regole.get("carte_rarita", []).size() >= 7,
			"le rarita' delle carte dovrebbero essere sette")
	esigi(GameState.regole.get("carte_finiture", []).size() == 3,
			"le finiture dovrebbero essere tre: normale, con stile, proibita")
	esigi(GameState.ottieni_carta("prova_carta", "normale"), "la prima copia non risulta nuova")
	esigi(not GameState.ottieni_carta("prova_carta", "normale"), "un doppione risulta una carta nuova")
	esigi(GameState.copie_carta("prova_carta") == 2, "il doppione non e' stato contato")
	esigi(GameState.doppioni_carta("prova_carta") == 1, "i doppioni cedibili sono contati male")
	GameState.ottieni_carta("prova_carta", "proibita")
	esigi(GameState.copie_carta("prova_carta", "proibita") == 1, "la finitura non viene tenuta a parte")
	esigi(GameState.cedi_carta("prova_carta", "proibita"), "non si riesce a cedere un doppione")
	esigi(GameState.copie_carta("prova_carta") == 2, "cedere non ha tolto la copia")
	esigi(GameState.cedi_carta("prova_carta"), "il secondo doppione non si cede")
	esigi(not GameState.cedi_carta("prova_carta"), "si e' ceduta l'ultima copia: l'album si buca")
	esigi("prova_carta" in GameState.carte, "la voce nell'album e' sparita cedendo i doppioni")

func prova_slot_accessori() -> void:
	# Gli accessori non si aprono tutti insieme: uno solo all'inizio, poi uno a
	# ogni soglia di livello, piu' quelli di chi ha il talento.
	titolo("gli slot degli accessori si aprono a poco a poco")
	GameState.nuova_partita()
	var eroe := GameState.id_protagonista
	var base := int(GameState.regole.get("slot_accessori_base", 1))
	var soglie: Array = GameState.regole.get("slot_accessori_per_livello", [])
	esigi(base >= 1, "senza almeno uno slot non si puo' equipaggiare niente")
	GameState.livelli[eroe] = 1
	esigi(GameState.slot_accessori_di(eroe) == base,
			"al livello 1 gli slot dovrebbero essere %d, sono %d" % [base, GameState.slot_accessori_di(eroe)])
	for i in range(soglie.size()):
		GameState.livelli[eroe] = int(soglie[i])
		esigi(GameState.slot_accessori_di(eroe) == base + i + 1,
				"al livello %d gli slot dovrebbero essere %d" % [int(soglie[i]), base + i + 1])
		esigi(GameState.livello_slot_accessorio(base + i) == int(soglie[i]),
				"lo slot %d dovrebbe aprirsi al livello %d" % [base + i, int(soglie[i])])
	# i due talenti: se qualcuno li sposta di classe, questa prova lo dice
	var con_talento := 0
	for dati_classe in GameState.classi.values():
		if not dati_classe is Dictionary:
			continue
		var id_classe := String(dati_classe.get("id", ""))
		if GameState.slot_accessori_da_talento(id_classe) > 0:
			con_talento += 1
			esigi(GameState.talento_dello_slot(id_classe, 20) != "",
					"%s ha slot da talento ma la scheda non sa dire quale" % id_classe)
	esigi(con_talento == 2, "i talenti che aprono slot dovrebbero essere su due classi, sono su %d" % con_talento)
	# il tetto e' vero: oltre non si equipaggia, anche a forza
	GameState.livelli[eroe] = 1
	var accessori_veri: Array[String] = []
	for dati in GameState.oggetti.values():
		if dati is Dictionary and String(dati.get("tipo", "")) == "accessorio":
			accessori_veri.append(String(dati.get("id", "")))
	if accessori_veri.size() > base:
		for id_oggetto in accessori_veri:
			GameState.aggiungi_oggetto(id_oggetto)
		var messi := 0
		for id_oggetto in accessori_veri:
			if GameState.equipaggia(eroe, "accessori", id_oggetto):
				messi += 1
		esigi(GameState.slot_di(eroe)["accessori"].size() <= base,
				"si riescono a mettere piu' accessori degli slot aperti")

func prova_scheda_personaggio() -> void:
	# La scheda si costruisce tutta in codice: un errore qui non si vede finche'
	# qualcuno non apre il menu. Qui si apre, si passa da ogni compagno e si
	# spalanca ogni slot, cosi' ogni ramo del disegno viene percorso davvero.
	#
	# E soprattutto: la scheda calcola la differenza di statistiche SIMULANDO
	# l'oggetto addosso - lo equipaggia, guarda, e rimette tutto com'era.
	# Se quel "rimette tutto com'era" avesse una crepa, guardare un oggetto
	# cambierebbe l'equipaggiamento del giocatore. Questo lo verifica.
	titolo("la scheda del personaggio si apre, e guardare non cambia niente")
	GameState.nuova_partita()
	var eroe := GameState.id_protagonista
	GameState.livelli[eroe] = 40
	for dati in GameState.oggetti.values():
		if dati is Dictionary and String(dati.get("tipo", "")) in ["accessorio", "arma", "stigma"]:
			GameState.aggiungi_oggetto(String(dati.get("id", "")))
	var prima := JSON.stringify(GameState.equipaggiamento)
	var scheda := SchedaPersonaggio.new()
	add_child(scheda)
	scheda.apri(func() -> void: pass, func() -> void: pass)
	esigi(scheda.get_child_count() > 0, "la scheda non ha disegnato niente")
	for slot: String in ["arma", "stigma", "ultima_risorsa", "accessori"]:
		scheda.slot_aperto = slot
		scheda.indice_aperto = 0
		scheda.ridisegna()
		esigi(scheda.get_child_count() > 0, "la scheda si svuota aprendo lo slot '%s'" % slot)
	scheda.slot_aperto = ""
	scheda.ridisegna()
	esigi(JSON.stringify(GameState.equipaggiamento) == prima,
			"guardare gli oggetti nella scheda ha cambiato quello che il giocatore ha addosso")
	scheda.queue_free()

func prova_finale_scriptato() -> void:
	# LA PROVA DELLA BOMBA. Nell'allenamento con Veronica la bomba e' l'ultimo
	# passo del copione: appena la usi il tutorial si chiude, e la chiusura e'
	# lei che ti stende con la Meteora di Atlante. Giusto cosi'. Solo che il
	# ritratto del protagonista si spegneva SUBITO, sette messaggi prima che il
	# box raccontasse la meteora - e allora il nesso che il giocatore vede e'
	# "ho tirato la bomba e sono morto io".
	#
	# Qui si verifica la regola generale: una sconfitta scritta azzera i punti
	# vita all'istante (il motore deve saperlo) ma non tocca nessuna scheda
	# finche' la coda non ci arriva.
	titolo("un finale scritto non spegne le schede prima del tempo")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scena: PackedScene = load("res://scenes/Combattimento.tscn")
	var scontro: Node = scena.instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	add_child(scontro)
	# si riparte da uno scontro pulito: qualcuno vivo, coda vuota, contatore a zero
	for combattente in scontro.combattenti:
		combattente.hp = combattente.hp_max
	scontro.voce.coda.clear()
	scontro.voce.scrivi("Veronica scatena il suo attacco speciale.")
	var schede_prima: int = scontro.campo.aggiornamenti
	scontro.sconfitta_scriptata()
	var eroe: Dictionary = scontro.vivi(true)[0] if not scontro.vivi(true).is_empty() else {}
	esigi(eroe.is_empty(), "la sconfitta scriptata non ha azzerato i punti vita")
	esigi(scontro.campo.aggiornamenti == schede_prima,
			"il finale scritto spegne il ritratto prima che il box abbia raccontato perche': "
			+ "e' il bug della bomba di Veronica")
	esigi(not scontro.voce.coda.is_empty(),
			"il finale scritto non ha lasciato niente da leggere")
	scontro.free()

func prova_salvataggio_vecchio() -> void:
	# UN SALVATAGGIO DI IERI DEVE APRIRSI OGGI.
	#
	# Lo zaino e' cambiato: armi, accessori e oggetti speciali stavano tutti
	# nello stesso mucchio ("accessori") e adesso hanno scomparti diversi; le
	# carte non avevano copie. Una partita in corso non si butta per questo.
	#
	# Qui si scrive a mano un salvataggio nel VECCHIO formato - senza "armi",
	# senza "oggetti_speciali", senza "spazi_zaino", senza "carte_copie" - e si
	# pretende che si apra senza perdere niente.
	titolo("un salvataggio del vecchio formato si apre ancora")
	GameState.nuova_partita()
	var eroe := GameState.id_protagonista
	# tre oggetti di tipo diverso, tutti nel mucchio unico di una volta
	var un_arma := ""
	var uno_stigma := ""
	var un_accessorio := ""
	for dati in GameState.oggetti.values():
		if not dati is Dictionary:
			continue
		var id_oggetto := String(dati.get("id", ""))
		match String(dati.get("tipo", "")):
			"arma": un_arma = id_oggetto if un_arma == "" else un_arma
			"stigma": uno_stigma = id_oggetto if uno_stigma == "" else uno_stigma
			"accessorio": un_accessorio = id_oggetto if un_accessorio == "" else un_accessorio
	var vecchio := {
		"versione": 1,
		"seed": 4242,
		"tazo": 314,
		"legame": 55,
		"classi_sbloccate": [eroe],
		"livelli": {eroe: 7},
		"sacca": ["fiala_hp", "fiala_hp"],
		"accessori": [un_arma, uno_stigma, un_accessorio],   # il vecchio mucchio unico
		"carte": ["carta_di_prova"],                          # senza conteggio delle copie
		"flags": ["una_cosa_successa"],
		"nodi_visitati": ["una_stanza"],
		"equipaggiamento": {eroe: {"arma": un_arma, "stigma": uno_stigma,
				"ultima_risorsa": "", "accessori": [un_accessorio]}},
		"nome_protagonista": "Bru",
	}
	var percorso := "user://prova_salvataggio_vecchio.json"
	var file := FileAccess.open(percorso, FileAccess.WRITE)
	file.store_string(JSON.stringify(vecchio))
	file.close()
	GameState.nuova_partita()
	esigi(GameState._leggi_salvataggio(percorso), "il salvataggio vecchio non si apre proprio")
	esigi(GameState.tazo == 314, "Tazo persi aprendo un salvataggio vecchio")
	esigi(GameState.legame == 55, "legame perso")
	esigi(GameState.livello_di(eroe) == 7, "livello perso")
	esigi(GameState.sacca.size() == 2, "consumabili persi")
	esigi("una_cosa_successa" in GameState.flags, "flag di progresso persi")
	# gli oggetti si sono smistati da soli nei nuovi scomparti, senza sparire
	if un_arma != "":
		esigi(un_arma in GameState.armi, "l'arma non e' finita nello scomparto delle armi")
		esigi(GameState.equipaggiato_in(eroe, "arma") == un_arma, "l'arma equipaggiata si e' staccata")
	if uno_stigma != "":
		esigi(uno_stigma in GameState.oggetti_speciali, "lo stigma non e' finito tra gli oggetti speciali")
		esigi(GameState.equipaggiato_in(eroe, "stigma") == uno_stigma, "lo stigma equipaggiato si e' staccato")
	if un_accessorio != "":
		esigi(un_accessorio in GameState.accessori, "l'accessorio e' sparito dallo zaino")
		esigi(GameState.equipaggiato_in(eroe, "accessori", 0) == un_accessorio,
				"l'accessorio equipaggiato si e' staccato")
	# le carte vecchie hanno adesso una copia a testa, e l'album le conta ancora
	esigi("carta_di_prova" in GameState.carte, "una carta e' sparita dall'album")
	esigi(GameState.copie_carta("carta_di_prova") == 1, "la carta vecchia non ha una copia")
	# nessuno spazio comprato: si riparte dalle capacita' di base
	esigi(GameState.capacita_zaino("consumabili") == int(GameState.regole.get("zaino", {})
			.get("consumabili", {}).get("base", 20)), "la capacita' della sacca non e' quella di base")

func prova_ingresso_nodi() -> void:
	# LA GARANZIA, NELLA SUA FORMA DEFINITIVA.
	#
	# Entrare in un nodo puo' finire in due modi e basta: o c'e' qualcosa da
	# mostrare, o si va da un'altra parte. Un terzo caso - ne' l'uno ne' l'altro -
	# era la schermata vuota su cui Bru si e' bloccato tre volte.
	#
	# Adesso quella decisione sta in IngressoNodo, che non tocca l'albero delle
	# scene: si puo' entrare in OGNI nodo del gioco e guardare il verdetto senza
	# istanziare niente. E si controlla molte volte per nodo, cosi' si passa sia
	# per il ramo dell'agguato che per quello della stanza tranquilla.
	#
	# Non e' una prova sul sintomo: e' una prova sull'invariante. Finche' passa,
	# non esiste un ingresso che lasci il gioco a meta'.
	titolo("entrare in un nodo finisce sempre in uno dei due modi")
	GameState.nuova_partita()
	var controllati := 0
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		var nodi: Dictionary = dati.get("nodi", {})
		if nodi.is_empty():
			continue
		GameState.eventi = nodi
		for id_nodo in nodi:
			for tentativo in 6:
				GameState.stanze_ripulite.clear()
				GameState.nodi_visitati.clear()
				var esito: Dictionary = IngressoNodo.entra(String(id_nodo))
				controllati += 1
				var va_altrove := String(esito.get("scena", "")) != ""
				var c_e_da_mostrare: bool = not (esito.get("nodo", {}) as Dictionary).is_empty()
				esigi(va_altrove or c_e_da_mostrare,
						"%s/%s: entrare non porta ne' a una schermata ne' altrove"
						% [percorso, id_nodo])
				if esito.get("agguato", false):
					esigi(va_altrove, "%s/%s: l'agguato scatta ma non si parte" % [percorso, id_nodo])
					esigi(not GameState.nemici_combattimento.is_empty(),
							"%s/%s: si parte per un combattimento senza nemici" % [percorso, id_nodo])
	esigi(controllati > 500, "la prova ha guardato solo %d ingressi" % controllati)

func prova_transizioni() -> void:
	# LA PROVA DELLA SCHERMATA VUOTA. Bru e' rimasto bloccato a Meridia: vinci
	# un agguato, la stanza rientra, dentro il suo _ready() ne tira subito un
	# altro - ma la transizione precedente non e' ancora finita, e quel cambio di
	# scena spariva nel nulla. Stanza senza testo, senza uscite, partita persa.
	#
	# Nessun dato era sbagliato: nessuna delle 1300 verifiche di prima poteva
	# vederlo. Questa si'.
	titolo("le transizioni non perdono nessuna richiesta")
	var stato_prima := Transizioni.in_corso
	Transizioni.in_corso = true
	Transizioni.prossima = ""
	Transizioni.vai("res://scenes/Combattimento.tscn")
	esigi(Transizioni.prossima == "res://scenes/Combattimento.tscn",
			"un cambio di scena chiesto durante una transizione viene ingoiato: "
			+ "e' il bug della schermata vuota a Meridia")
	# l'ultima richiesta vince, e una richiesta vuota non cancella quella buona
	Transizioni.vai("res://scenes/Mappa.tscn")
	esigi(Transizioni.prossima == "res://scenes/Mappa.tscn",
			"la seconda richiesta non sostituisce la prima")
	Transizioni.vai("")
	esigi(Transizioni.prossima == "res://scenes/Mappa.tscn",
			"una destinazione vuota cancella quella in coda")
	Transizioni.prossima = ""
	Transizioni.in_corso = stato_prima

func prova_agguati_hanno_una_via_duscita() -> void:
	# un agguato perso deve portare da qualche parte: senza se_perdi si finisce
	# nel ramo "reset_campagna" e si perde la posizione senza spiegazione
	titolo("ogni agguato dice dove si va se si perde")
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		var nodi: Dictionary = dati.get("nodi", {})
		for id_nodo in nodi:
			var agguato: Dictionary = nodi[id_nodo].get("agguato", {})
			if agguato.is_empty():
				continue
			var se_perdi := String(agguato.get("se_perdi", ""))
			esigi(se_perdi != "" and nodi.has(se_perdi),
					"%s/%s: l'agguato non dice dove si va se si perde" % [percorso, id_nodo])

func prova_suoni() -> void:
	# I suoni del gioco non sono file, sono numeri calcolati all'avvio
	# (Sintesi.gd). Un'onda sbagliata non da' errore: da' silenzio, o un clic.
	titolo("suoni sintetizzati")
	for nome: String in ["conferma", "annulla", "colpo", "cura", "raccolta", "errore"]:
		var suono := Sintesi.interfaccia(nome)
		esigi(suono != null and suono.data.size() > 0, "il suono '%s' esce vuoto" % nome)
		esigi(suono.mix_rate == Sintesi.CAMPIONAMENTO, "il suono '%s' ha il campionamento sbagliato" % nome)
	# due nomi diversi devono suonare diversi, e lo stesso nome sempre uguale:
	# un personaggio che cambia voce tra una battuta e l'altra e' peggio del silenzio
	var una := Sintesi.voce_da_nome("Veronica")
	var altra := Sintesi.voce_da_nome("Jerah")
	esigi(una != altra, "due personaggi diversi hanno la stessa identica voce")
	esigi(una == Sintesi.voce_da_nome("Veronica"), "la voce di un personaggio cambia tra una chiamata e l'altra")
	var blip := Sintesi.blip("Veronica")
	esigi(blip.data.size() > 0, "il blip di una battuta esce vuoto")
	# il primo campione deve partire da zero: senza rampa d'attacco ogni suono
	# comincia con un clic, ed e' la differenza tra "voce" e "disturbo"
	esigi(absi(blip.data.decode_s16(0)) < 500, "il blip parte di scatto: si sentirebbe un clic")

func testo_script(percorso: String) -> String:
	return FileAccess.get_file_as_string(percorso) if FileAccess.file_exists(percorso) else ""

func script_del_gioco() -> Array[String]:
	var elenco: Array[String] = []
	for cartella_nome: String in ["res://scripts", "res://scripts/combattimento"]:
		var cartella := DirAccess.open(cartella_nome)
		if cartella == null:
			continue
		for nome in cartella.get_files():
			if nome.ends_with(".gd"):
				elenco.append(cartella_nome + "/" + nome)
	return elenco

func prova_gerarchia_schermate() -> void:
	# LA REGOLA, in una prova.
	#
	# "Il caricamento della partita, la gestione dei salvataggi e i controlli su
	# come far partire il gioco devono essere una prerogativa della schermata
	# principale." Non e' un consiglio di stile: e' una regola, e come tutte le
	# regole che contano deve poter FALLIRE quando qualcuno la rompe. Altrimenti
	# fra tre mesi qualcuno rimette un selettore di slot dentro una schermata di
	# gioco perche' li' faceva comodo, e nessuno se ne accorge.
	#
	# Chi puo' nominare la gestione dei salvataggi:
	#   GameState  - ce l'ha dentro, e' lui che scrive i file
	#   Menu       - E' la schermata principale
	# Chi puo' chiamare salva():
	#   Sede         - rientrare alla Sede E' il salvataggio
	#   IngressoNodo - i checkpoint di meta' dungeon, deliberati e documentati
	titolo("la gerarchia: i salvataggi stanno solo dove devono")
	var gestione := ["carica_slot(", "salva_slot(", "elimina_slot(", "anteprima_slot(",
			"ha_salvataggio_slot(", "nome_slot(", "imposta_slot(", "percorso_slot("]
	var puo_gestire := ["res://scripts/GameState.gd", "res://scripts/Menu.gd"]
	var puo_salvare := ["res://scripts/GameState.gd", "res://scripts/Sede.gd",
			"res://scripts/IngressoNodo.gd"]
	for percorso in script_del_gioco():
		var testo := testo_script(percorso)
		if percorso not in puo_gestire:
			for nome_funzione in gestione:
				esigi(testo.find(nome_funzione) == -1,
						"%s tocca la gestione dei salvataggi (%s): e' roba da schermata principale"
						% [percorso.get_file(), nome_funzione])
		if percorso not in puo_salvare:
			esigi(testo.find("GameState.salva(") == -1,
					"%s salva la partita: si salva solo rientrando alla Sede" % percorso.get_file())
	# e la Sede lo fa davvero: se questa riga sparisse, non salverebbe piu' nessuno
	esigi(testo_script("res://scripts/Sede.gd").find("GameState.salva()") != -1,
			"la Sede non salva piu': il gioco non ha piu' nessun punto di salvataggio")
	# una partita e' uno slot, e lo slot lo sceglie il menu
	GameState.imposta_slot(3)
	esigi(GameState.slot_corrente == 3, "imposta_slot non cambia la partita corrente")
	esigi(GameState.percorso_slot(3) == GameState.percorso_slot(GameState.slot_corrente),
			"salva() non scriverebbe nella partita scelta")
	GameState.imposta_slot(99)
	esigi(GameState.slot_corrente == GameState.SLOT_MASSIMO,
			"uno slot fuori scala non viene riportato dentro")
	GameState.imposta_slot(1)

func prova_livello_dei_nemici() -> void:
	# La regola di Bru: una creatura puo' stare sopra di te quanto vuole, mai
	# piu' di tre livelli sotto. Il perche' e' nella storia (il disallineamento
	# si nutre del tuo fattore Carnivalz), ma qui si controlla il numero.
	titolo("nessun nemico scende piu' di tre livelli sotto di te")
	GameState.nuova_partita()
	# Lo scarto si legge dal FILE, non dalla funzione che dovrebbe applicarlo:
	# se lo chiedessi a GameState, una funzione sbagliata sposterebbe anche il
	# metro con cui la misuro, e la prova direbbe di si' a qualunque cosa. Era
	# proprio cosi' che non si accorgeva dello scarto portato da 3 a 5.
	var scarto := int(GameState.regole.get("scarto_livello_massimo", 0))
	esigi(scarto > 0, "scarto_livello_massimo non e' impostato in regole.json")
	esigi(GameState.scarto_livello_massimo() == scarto,
			"GameState non usa lo scarto scritto in regole.json")
	var attese := creature().size()
	esigi(attese > 30, "l'elenco delle creature si e' svuotato: la prova non guarda piu' niente")
	for livello_eroe in [1, 5, 12, 40]:
		GameState.livelli[GameState.id_protagonista] = livello_eroe
		var esaminate := 0
		for id_creatura in GameState.personaggi:
			if not GameState.e_creatura(id_creatura):
				continue  # non e' una creatura da combattimento
			esaminate += 1
			var livello := GameState.livello_nemico(id_creatura)
			var base := GameState.livello_base_nemico(id_creatura)
			esigi(livello >= base, "%s e' stato indebolito dal livellamento" % id_creatura)
			if GameState.nemico_scala(id_creatura):
				# QUESTA riga e' la regola, e la prima volta l'avevo scritta
				# sbagliata: un mini() al posto di un maxi() la rendeva vera
				# sempre, e passava anche col pavimento tolto. Il pavimento e'
				# "livello del protagonista meno lo scarto", punto - non e' il
				# livello base della creatura, che e' proprio quello da cui la si
				# vuole tirare su.
				var pavimento := maxi(livello_eroe - scarto, 1)
				esigi(livello >= pavimento,
						"%s e' lv %d con un protagonista lv %d: doveva essere almeno lv %d"
						% [id_creatura, livello, livello_eroe, pavimento])
			else:
				esigi(livello == base,
						"%s non doveva scalare col giocatore, e invece e' salito" % id_creatura)
			# le stat seguono il livello, e non calano mai
			for chiave in ["hp", "attacco", "difesa"]:
				esigi(GameState.stat_nemico(id_creatura, chiave)
						>= GameState.stat_base_nemico(id_creatura, chiave),
						"%s ha perso %s salendo di livello" % [id_creatura, chiave])
		esigi(esaminate == attese,
				"col protagonista lv %d la prova ha guardato %d creature su %d"
				% [livello_eroe, esaminate, attese])
	GameState.nuova_partita()

func prova_curva_creature() -> void:
	# LA PROVA CHE RENDE INUTILE RICALIBRARE A MANO.
	#
	# Bru: "dobbiamo trovare un modo di avere sempre sotto controllo xp, livelli
	# e potenza dei nemici senza dover sempre ricalibrare". Il modo e' smettere
	# di scrivere i numeri: una creatura dichiara livello e ruolo, il resto esce
	# da ruoli.json, e ruoli.json non ha numeri suoi - ha quote del protagonista.
	# Ma un sistema del genere regge solo finche' nessuno ci infila dentro
	# un'eccezione di nascosto: basta una creatura con "hp": 400 scritto a mano
	# perche' il giorno che cambi la curva quella resti indietro in silenzio.
	# Quindi qui si pretende che ogni numero a mano dica anche perche'.
	titolo("ogni creatura sta sulla curva del suo ruolo, o dice perche' no")
	var tabella: Dictionary = GameState.ruoli.get("ruoli", {})
	esigi(not tabella.is_empty(), "ruoli.json non caricato o senza ruoli")
	var stat_derivate := ["hp", "attacco", "difesa", "velocita", "xp", "tazo"]

	# 1. nessuna creatura senza ruolo, nessun ruolo inventato, nessun livello a caso
	var elenco := creature()
	esigi(elenco.size() > 30, "l'elenco delle creature si e' svuotato: la prova non guarda piu' niente")
	var ruoli_usati := {}
	for id_creatura in elenco:
		var dati: Dictionary = GameState.personaggi[id_creatura]
		var nome_ruolo := String(dati.get("ruolo", ""))
		esigi(tabella.has(nome_ruolo),
				"%s ha ruolo '%s', che in ruoli.json non esiste" % [id_creatura, nome_ruolo])
		ruoli_usati[nome_ruolo] = true
		esigi(dati.has("livello"),
				"%s non dice a che livello sta: senza livello la curva non sa che numeri darle" % id_creatura)
		esigi(int(dati.get("livello", 0)) >= 1,
				"%s e' al livello %d" % [id_creatura, int(dati.get("livello", 0))])

	# 2. ogni numero scritto a mano e' un'eccezione dichiarata, con la sua ragione
	for id_creatura in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_creatura]
		if not dati.has("ruolo"):
			continue
		var a_mano: Array[String] = []
		for chiave: String in stat_derivate:
			if dati.has(chiave):
				a_mano.append(chiave)
		var motivo := String(dati.get("fuori_curva", ""))
		if a_mano.is_empty():
			# il contrario conta uguale: una ragione senza eccezione e' una bugia
			# che resta nel file e racconta di un numero che non c'e' piu'
			esigi(motivo == "",
					"%s dichiara fuori_curva ma non scrive nessun numero a mano: la ragione non descrive niente"
					% id_creatura)
			continue
		esigi(motivo.length() >= 30,
				"%s scrive a mano %s senza dire perche' (campo 'fuori_curva'): fra sei mesi nessuno sapra' se era una scelta o una svista"
				% [id_creatura, ", ".join(a_mano)])

	# 3. i ruoli descritti sono i ruoli usati: un ruolo che nessuno ha e' una
	#    riga che promette un modo di combattere che nel gioco non esiste
	for nome_ruolo in tabella:
		esigi(ruoli_usati.has(nome_ruolo) or nome_ruolo == "oggetto_scena",
				"il ruolo '%s' e' descritto in ruoli.json ma nessuna creatura ce l'ha" % nome_ruolo)

	# 4. il ruolo mantiene la promessa del suo nome. Non e' pedanteria: i
	#    moltiplicatori sono sei numeri per riga, e invertirne due si nota solo
	#    giocandoci mezz'ora
	var comune: Dictionary = tabella.get("comune", {})
	esigi(float(tabella.get("veloce", {}).get("velocita", 0.0)) > float(comune.get("velocita", 0.0)),
			"il ruolo 'veloce' non e' piu' veloce di un comune")
	esigi(float(tabella.get("corazzato", {}).get("difesa", 0.0)) > float(comune.get("difesa", 0.0)),
			"il ruolo 'corazzato' non para piu' di un comune")
	esigi(float(tabella.get("veloce", {}).get("hp", 9.9)) < float(comune.get("hp", 0.0)),
			"il ruolo 'veloce' regge quanto un comune: allora e' solo un comune piu' rapido")
	for nome_ruolo: String in ["particolare", "miniboss", "fonte"]:
		var r: Dictionary = tabella.get(nome_ruolo, {})
		esigi(float(r.get("hp", 0.0)) > float(comune.get("hp", 0.0)),
				"il ruolo '%s' regge meno di un nemico di riserva" % nome_ruolo)
		esigi(float(r.get("xp", 0.0)) > float(comune.get("xp", 0.0)),
				"il ruolo '%s' vale meno esperienza di un nemico di riserva" % nome_ruolo)

	# 5. la curva sale. Un segno sbagliato in una formula si vede solo qui: le
	#    creature non calerebbero a vista d'occhio, calerebbero piano
	var prima := {}
	for livello in range(1, 41):
		for chiave: String in ["hp", "attacco", "difesa", "velocita", "xp"]:
			var ora := valore_di_curva(chiave, livello)
			esigi(ora > 0, "al livello %d la curva da' %s = %d" % [livello, chiave, ora])
			if prima.has(chiave):
				esigi(ora >= int(prima[chiave]),
						"dal livello %d al %d la curva fa CALARE %s (%d -> %d)"
						% [livello - 1, livello, chiave, int(prima[chiave]), ora])
			prima[chiave] = ora

	# 6. LA PARTE CHE VALE. La curva delle creature e quella del protagonista
	#    sono la stessa curva: se lo fossero solo "piu' o meno", il giorno che
	#    Bru tocca crescita.json le creature resterebbero indietro senza che
	#    nessuno se ne accorga - ed e' esattamente com'era prima.
	for livello: int in [1, 3, 8, 15, 30]:
		var eroe_hp := GameState.stat_eroe_tipo("hp", livello)
		esigi(eroe_hp > 0.0, "al livello %d il protagonista tipo ha %d hp" % [livello, int(eroe_hp)])
		var atteso := int(round(eroe_hp
				* float(GameState.ruoli.get("curva", {}).get("quota_hp", 1.05))
				* float(comune.get("hp", 1.0))))
		esigi(valore_di_curva("hp", livello) == atteso,
				"al livello %d un comune ha %d hp invece dei %d che dice la quota del protagonista"
				% [livello, valore_di_curva("hp", livello), atteso])
		# e il protagonista tipo e' davvero quello che il gioco costruisce:
		# stessa stima, stesso conto, non una tabella parallela
		cresci_giocatore_fino_a(livello)
		for chiave: String in ["hp", "attacco", "difesa", "velocita"]:
			esigi(int(GameState.stat_eroe_tipo(chiave, livello)) == GameState.stat_di(chiave),
					"al livello %d stat_eroe_tipo dice %s = %d, ma il protagonista costruito ne ha %d"
					% [livello, chiave, int(GameState.stat_eroe_tipo(chiave, livello)),
					GameState.stat_di(chiave)])

	# 7. il ritmo e' quello dichiarato: "scontri_per_livello" deve voler dire
	#    davvero quanti scontri servono per salire, altrimenti e' una manopola
	#    che gira a vuoto e si torna a tarare l'esperienza creatura per creatura
	GameState.nuova_partita()
	for livello: int in [1, 4, 10, 25]:
		var quanti := GameState.scontri_per_livello(livello)
		esigi(quanti >= 1.0, "al livello %d servirebbero %.1f scontri" % [livello, quanti])
		var per_scontro := valore_di_curva("xp", livello)
		var servono := float(GameState.fabbisogno_xp(livello)) / float(maxi(per_scontro, 1))
		esigi(absf(servono - quanti) <= 1.0,
				"al livello %d ruoli.json promette %.1f scontri per salire, ma ne servono %.1f"
				% [livello, quanti, servono])
	# e il ritmo non deve scappare: era 4 scontri al livello 1 e 26 al 20, e
	# nessuno l'aveva mai misurato perche' nessuna prova guardava sopra l'8
	var al_primo := GameState.scontri_per_livello(1)
	var al_trentesimo := GameState.scontri_per_livello(30)
	esigi(al_trentesimo <= al_primo * 4.0,
			"per salire di livello al 30 servono %.1f scontri contro i %.1f del livello 1: e' una macinata"
			% [al_trentesimo, al_primo])
	GameState.nuova_partita()

func prova_salire_di_livello_non_peggiora() -> void:
	# LA PROVA CHE NESSUNO AVEVA, E CHE SI VEDEVA SOLO GIOCANDO PARECCHIO.
	#
	# Il disallineamento tira su le creature perche' una zona vecchia non
	# diventi un corridoio vuoto. Ma la crescita del nemico e quella del
	# protagonista sono due cose diverse, e se la prima corre piu' della seconda
	# succede una cosa assurda: SALIRE DI LIVELLO TI PEGGIORA LA VITA. Era
	# esattamente cosi' - +13% per livello di scarto contro un protagonista che
	# dal 18 al 25 cresce di 1,2 volte - e il giocatore automatico l'ha
	# misurato: Jerah vinto il 100% delle volte al livello 18, il 29% al 25.
	#
	# Non si misura il numero del nemico da solo (che deve salire), si misura
	# quanto pesa RISPETTO a te: quanti colpi ti serve dargli, e quanti gliene
	# servono a lui. Quella e' la forma dello scontro, ed e' quella che non deve
	# peggiorare mentre giochi.
	# IL METRO GIUSTO, dopo che il primo era sbagliato. La prima versione
	# pretendeva che uno scontro non diventasse mai relativamente piu' duro, e
	# non e' vero: il disallineamento tira su le creature APPOSTA perche' una
	# zona vecchia non diventi un corridoio vuoto, quindi un goblin di livello 1
	# a fine gioco deve costare piu' colpi di quanti ne costava all'inizio.
	# Quello che non deve succedere e' che superi il suo stesso ruolo: una
	# creatura tirata su puo' avvicinarsi a una del tuo livello, mai batterla.
	# Questa e' anche esattamente la condizione che il vecchio +13% violava.
	titolo("nessuna creatura diventa piu' dura di una del suo ruolo al tuo livello")
	var elenco := creature()
	esigi(elenco.size() > 30, "l'elenco delle creature si e' svuotato: la prova non guarda piu' niente")
	var esaminate := 0
	for id_creatura in elenco:
		if not GameState.nemico_scala(id_creatura):
			continue  # chi non scala resta dov'e': e' il suo mestiere
		if String(GameState.personaggi[id_creatura].get("fuori_curva", "")) != "":
			# le eccezioni dichiarate stanno fuori dalla curva per scelta, ed e'
			# il senso di essere un'eccezione: la bambola ha 6660 punti vita
			# perche' non deve essere abbattuta a colpi. Il tetto qui misura la
			# curva, e loro non ci sono sopra. Che siano poche e che dicano
			# perche' lo pretende prova_curva_creature
			continue
		var nome_ruolo := String(GameState.personaggi[id_creatura].get("ruolo", ""))
		esaminate += 1
		for livello_eroe in range(2, 31):
			cresci_giocatore_fino_a(livello_eroe)
			if GameState.livello_nemico(id_creatura) > livello_eroe:
				# sta ancora sopra di te: deve fare male, e' il suo mestiere. Il
				# tetto vale da quando l'hai raggiunta in poi, cioe' nel tratto
				# in cui e' il disallineamento a tenerla su e non il suo posto
				# nella storia
				continue
			var mio_attacco := maxi(GameState.stat_di("attacco"), 1)
			var mia_vita := maxi(GameState.stat_di("hp"), 1)
			# quanto costa lei adesso: colpi per abbatterla, e colpi suoi per
			# abbattere te
			var colpi := float(GameState.stat_nemico(id_creatura, "hp")) / maxf(
					float(mio_attacco - GameState.stat_nemico(id_creatura, "difesa")), 1.0)
			var incassi := float(mia_vita) / maxf(float(GameState.stat_nemico(id_creatura, "attacco")), 1.0)
			# e quanto costerebbe una del suo ruolo nata al tuo livello: il tetto
			var tetto_colpi := float(valore_di_ruolo("hp", nome_ruolo, livello_eroe)) / maxf(
					float(mio_attacco - valore_di_ruolo("difesa", nome_ruolo, livello_eroe)), 1.0)
			var tetto_incassi := float(mia_vita) / maxf(
					float(valore_di_ruolo("attacco", nome_ruolo, livello_eroe)), 1.0)
			esigi(colpi <= tetto_colpi * 1.1 + 1.0,
					"%s: col protagonista lv %d servono %.1f colpi per abbatterla, piu' dei %.1f che costerebbe un '%s' nato al tuo livello"
					% [id_creatura, livello_eroe, colpi, tetto_colpi, nome_ruolo])
			esigi(incassi >= tetto_incassi * 0.9 - 1.0,
					"%s: col protagonista lv %d ti abbatte in %.1f colpi, meno dei %.1f di un '%s' nato al tuo livello"
					% [id_creatura, livello_eroe, incassi, tetto_incassi, nome_ruolo])
	esigi(esaminate > 20,
			"la prova ha guardato solo %d creature che scalano: il filtro si e' stretto" % esaminate)
	GameState.nuova_partita()

func prova_carta_del_titolo_sta_su_una_riga() -> void:
	# IL BUG CHE 8389 VERIFICHE NON HANNO VISTO, e che si vedeva al primo
	# sguardo: "Pianure di Redenna" scritto una lettera per riga.
	#
	# Con l'autowrap acceso, la larghezza minima di una Label collassa a quella
	# del carattere piu' largo - e' letteralmente il suo minimo. Dentro un
	# CenterContainer, che dimensiona il figlio proprio sul minimo, viene fuori
	# una colonna di lettere. Nessuna prova poteva accorgersene guardando i
	# dati: e' una proprieta' di come il testo finisce sullo schermo, e va
	# misurata sullo schermo.
	titolo("il titolo di una zona sta su una riga, non una lettera per riga")
	GameState.nuova_partita()
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	# i titoli veri del gioco, non uno inventato per l'occasione
	var titoli: Array[String] = ["Pianure di Redenna"]
	var dati: Variant = GameState.carica_json("res://data/mappa.json")
	if dati is Dictionary:
		for voce in (dati as Dictionary).get("punti", []):
			var nome := String(voce.get("nome", ""))
			if nome != "" and not nome in titoli:
				titoli.append(nome)
	esigi(titoli.size() >= 2, "non si e' trovato nessun nome di zona da provare")
	for testo in titoli:
		schermata.mostra_carta_titolo(testo)
		# il layout non e' pronto finche' il contenitore non l'ha calcolato
		await get_tree().process_frame
		var etichetta: Label = schermata.testo_titolo
		esigi(etichetta.size.x > 200.0,
				"la carta del titolo e' larga %d pixel: il testo ci finisce incolonnato"
				% int(etichetta.size.x))
		esigi(etichetta.get_line_count() <= 2,
				"'%s' viene spezzato su %d righe: e' il titolo incolonnato"
				% [testo, etichetta.get_line_count()])
	schermata.free()
	GameState.nuova_partita()

func prova_barra_di_dominio_si_vede() -> void:
	# Bru: "non vedo la barra di dominio". Non la vedeva perche' non c'era: al
	# suo posto c'era "FAT 15" in fondo a una riga di sette numeri. Il dominio
	# e' quello che si carica mentre giochi e che spendi in un colpo solo, e una
	# cosa che sale e scende va guardata, non letta.
	titolo("la barra di dominio c'e', e si riempie insieme al dominio")
	GameState.nuova_partita()
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	esigi(schermata.barra_dominio != null, "nella schermata di gioco non c'e' nessuna barra di dominio")
	if schermata.barra_dominio == null:
		schermata.free()
		return
	esigi(schermata.barra_dominio.custom_minimum_size.x > 0.0,
			"la barra di dominio e' larga zero: c'e' ma non si vede")
	# si riempie per davvero, e in proporzione
	var letta := func() -> float:
		return float(schermata.barra_dominio.get_meta("quota", -1.0))
	GameState.punti_stat["fattore"] = 0 - GameState.stat_base_di("fattore")
	schermata.aggiorna_barra_dominio()
	esigi(is_zero_approx(letta.call()), "col dominio a zero la barra e' piena il %d%%"
			% int(letta.call() * 100))
	GameState.punti_stat["fattore"] = 50 - GameState.stat_base_di("fattore")
	schermata.aggiorna_barra_dominio()
	esigi(absf(letta.call() - 0.5) < 0.02,
			"col dominio a 50 la barra e' piena il %d%% invece che a meta'" % int(letta.call() * 100))
	GameState.punti_stat["fattore"] = 100 - GameState.stat_base_di("fattore")
	schermata.aggiorna_barra_dominio()
	esigi(absf(letta.call() - 1.0) < 0.001, "col dominio al massimo la barra non e' piena")
	# e in campo la vede anche la scheda di chi giochi tu
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.limite_giri = 1
	scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	add_child(scontro)
	var trovata := false
	for combattente in scontro.combattenti:
		if combattente.giocatore and combattente.get("barra_dominio", null) != null:
			trovata = true
	esigi(trovata, "in combattimento la scheda del party non ha la barra di dominio")
	scontro.free()
	schermata.free()
	GameState.nuova_partita()

func prova_ogni_abilita_gira_davvero() -> void:
	# LA PROVA CHE VALE PIU' DI TUTTE LE ALTRE MESSE INSIEME.
	#
	# Le altre guardano i dati: che i gradi salgano, che i punti si contino,
	# che le percentuali siano quelle. Ma un'abilita' puo' essere scritta
	# benissimo e non fare niente, e nel gioco si vede cosi': la scegli dal
	# menu, il turno passa, e non succede nulla. Qui ognuna viene ESEGUITA
	# davvero, dentro un combattimento vero, e deve lasciare un segno.
	titolo("ogni abilita' del protagonista fa davvero qualcosa")
	var tabella: Dictionary = GameState.abilita.get("abilita", {})
	var esaminate := 0
	for id_abilita in tabella:
		var dati: Dictionary = tabella[id_abilita]
		var tipo := String(dati.get("tipo", ""))
		if tipo in ["provoca", "carica"]:
			continue  # non fanno danno per mestiere: le guarda prova_abilita_di_combattimento
		esaminate += 1
		GameState.nuova_partita()
		GameState.livelli[GameState.id_protagonista] = 40
		GameState.nemici_combattimento = ["ghoul", "ghoul"]
		var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
		scontro.muto = true
		scontro.limite_giri = 1
		scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
		add_child(scontro)
		var eroe: Dictionary = {}
		var nemico: Dictionary = {}
		for combattente in scontro.combattenti:
			if combattente.giocatore and eroe.is_empty():
				eroe = combattente
			elif not combattente.giocatore and nemico.is_empty():
				nemico = combattente
		if eroe.is_empty() or nemico.is_empty():
			esigi(false, "%s: non si e' riusciti a montare lo scontro di prova" % id_abilita)
			scontro.free()
			continue
		# gli si mette in mano quello che l'abilita' consuma, altrimenti si
		# misura solo il ramo "non hai niente da bruciare"
		eroe.aura = 99
		eroe.fattore = 80
		var attacco_prima := int(eroe.attacco)
		var difesa_prima := int(eroe.difesa)
		var hp_nemico_prima := int(nemico.hp)
		match tipo:
			"astio":
				scontro.usa_abilita(eroe, String(id_abilita))
				esigi(int(eroe.get("astio_turni", 0)) > 0,
						"%s non ha acceso l'astio" % id_abilita)
				# e adesso il patto: incassare deve alzare l'attacco
				scontro.registra_danno_subito(eroe, 10)
				esigi(int(eroe.attacco) > attacco_prima,
						"%s: il protagonista ha incassato un colpo e l'attacco non e' salito" % id_abilita)
			"mantra":
				scontro.usa_abilita(eroe, String(id_abilita))
				esigi(int(eroe.get("fattore", 99)) == 0,
						"%s non ha svuotato la barra di dominio" % id_abilita)
				esigi(int(eroe.difesa) > difesa_prima and int(eroe.attacco) > attacco_prima,
						"%s ha svuotato la barra senza dare niente in cambio" % id_abilita)
			"flagello":
				scontro.usa_abilita(eroe, String(id_abilita))
				var restano := 0
				for combattente in scontro.combattenti:
					if not combattente.giocatore:
						restano += int(combattente.hp)
				esigi(restano < hp_nemico_prima * 2,
						"%s: venti colpi e nessun nemico ha perso un punto vita" % id_abilita)
			"vendetta", "annichilazione":
				scontro.usa_abilita_su(eroe, String(id_abilita), nemico)
				esigi(int(nemico.hp) < hp_nemico_prima,
						"%s non ha fatto nessun danno al bersaglio" % id_abilita)
			"pieta":
				# su un nemico intero non deve fare niente...
				scontro.usa_abilita_su(eroe, String(id_abilita), nemico)
				esigi(is_zero_approx(float(nemico.get("bonus_drop", 0.0))),
						"%s ha funzionato su un nemico ancora in piedi" % id_abilita)
				# ...e su uno quasi finito deve alzare il drop
				nemico.hp = maxi(int(nemico.hp_max) / 10, 1)
				scontro.usa_abilita_su(eroe, String(id_abilita), nemico)
				esigi(float(nemico.get("bonus_drop", 0.0)) > 0.0,
						"%s su un moribondo non ha alzato il drop: costa un turno e non compra niente" % id_abilita)
			"area", "raffica":
				scontro.usa_abilita(eroe, String(id_abilita))
		scontro.free()
	esigi(esaminate >= 15,
			"la prova ha eseguito solo %d abilita': il filtro si e' stretto" % esaminate)
	GameState.nuova_partita()

func prova_attacchi_darma() -> void:
	# Bru: "ogni arma equipaggiata fara' comparire una serie di attacchi
	# collegati all'arma in se'. Il danno e' l'attacco base del personaggio piu'
	# il bonus fornito dall'arma a seconda dell'attacco". Quindi due cose devono
	# essere vere insieme: che gli attacchi COMPAIANO cambiando arma, e che il
	# bonus finisca davvero nel danno invece di stare scritto e basta.
	titolo("l'arma che impugni cambia cosa puoi fare, non solo un numero")
	GameState.nuova_partita()
	var con_attacchi: Array[String] = []
	for id_oggetto in GameState.oggetti:
		var dati: Dictionary = GameState.oggetti[id_oggetto]
		if String(dati.get("tipo", "")) != "arma":
			continue
		for attacco in dati.get("attacchi", []):
			esigi(String(attacco.get("nome", "")) != "",
					"%s ha un attacco senza nome" % id_oggetto)
			esigi(int(attacco.get("bonus", -1)) >= 0,
					"l'attacco '%s' di %s non dice quanto aggiunge"
					% [String(attacco.get("nome", "?")), id_oggetto])
			esigi(String(attacco.get("testo", "")).count("%s") <= 1,
					"l'attacco '%s' di %s ha piu' di un segnaposto nel testo"
					% [String(attacco.get("nome", "?")), id_oggetto])
		if not dati.get("attacchi", []).is_empty():
			con_attacchi.append(String(id_oggetto))
	esigi(con_attacchi.size() >= 2,
			"solo %d armi portano attacchi: il sistema non e' usato da nessuno" % con_attacchi.size())

	# a mani vuote non compare niente
	esigi(GameState.attacchi_arma(GameState.id_protagonista).is_empty(),
			"senza arma in mano compaiono comunque degli attacchi d'arma")

	# e con l'arma addosso compaiono i suoi, non quelli di un'altra
	for id_arma in con_attacchi:
		GameState.equipaggiamento.clear()
		GameState.slot_di(GameState.id_protagonista)["arma"] = id_arma
		var elenco := GameState.attacchi_arma(GameState.id_protagonista)
		var attesi: Array = GameState.dati_oggetto(id_arma).get("attacchi", [])
		esigi(elenco.size() == attesi.size(),
				"con %s in mano compaiono %d attacchi invece di %d"
				% [id_arma, elenco.size(), attesi.size()])
		for voce in elenco:
			esigi(String(voce.get("arma", "")) == id_arma,
					"un attacco di %s dice di venire da un'altra arma" % id_arma)

	# IL BONUS ARRIVA DAVVERO NEL DANNO. Si prova in campo, con lo stesso seme:
	# stesso colpo, una volta senza l'attacco d'arma e una volta con, e il
	# secondo deve fare piu' male esattamente di quanto dice l'arma
	var id_prova := con_attacchi[0]
	var attacco_forte: Dictionary = {}
	for voce in GameState.dati_oggetto(id_prova).get("attacchi", []):
		if attacco_forte.is_empty() or int(voce.get("bonus", 0)) > int(attacco_forte.get("bonus", 0)):
			attacco_forte = voce
	esigi(int(attacco_forte.get("bonus", 0)) > 0, "nessun attacco d'arma aggiunge niente")
	var danno_di := func(usa_arma: bool) -> int:
		GameState.nuova_partita()
		GameState.imposta_seed(1234)
		GameState.livelli[GameState.id_protagonista] = 10
		GameState.nemici_combattimento = ["ghoul"]
		var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
		scontro.muto = true
		scontro.limite_giri = 1
		scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
		add_child(scontro)
		var eroe: Dictionary = {}
		var nemico: Dictionary = {}
		for combattente in scontro.combattenti:
			if combattente.giocatore and eroe.is_empty():
				eroe = combattente
			elif not combattente.giocatore and nemico.is_empty():
				nemico = combattente
		eroe.aura = 99
		# niente critici e niente fattore: si misura il colpo, non la fortuna
		eroe.stress = 0
		eroe.fattore = 0
		nemico.stress = 0
		nemico.difesa = 0
		var prima := int(nemico.hp)
		scontro.colpo_darma(eroe, nemico, attacco_forte if usa_arma else {})
		var fatto := prima - int(nemico.hp)
		scontro.free()
		return fatto
	var senza: int = danno_di.call(false)
	var con: int = danno_di.call(true)
	esigi(con > senza,
			"l'attacco '%s' aggiunge +%d sulla carta ma in campo fa %d danni contro i %d di un colpo normale"
			% [String(attacco_forte.get("nome", "?")), int(attacco_forte.get("bonus", 0)), con, senza])
	# quanto aggiunge sta fra il bonus scritto e quel bonus colto in pieno: il
	# bonus dell'arma fa parte del colpo, quindi un critico moltiplica anche
	# quello. Sopra questa forbice vuol dire che il bonus e' entrato due volte,
	# sotto che non e' entrato affatto
	var bonus := int(attacco_forte.get("bonus", 0))
	var massimo := int(ceil(bonus * float(GameState.regole.get("critico_moltiplicatore", 1.5))))
	esigi(con - senza >= bonus and con - senza <= massimo,
			"l'attacco '%s' dice +%d ma in campo aggiunge %d (atteso fra %d e %d, critico compreso)"
			% [String(attacco_forte.get("nome", "?")), bonus, con - senza, bonus, massimo])

	# e le classi d'arma: chi non sa impugnarla non ne prende gli attacchi
	esigi(GameState.classe_arma_di(GameState.id_protagonista) == "catalizzatore",
			"il protagonista non usa piu' i catalizzatori")
	GameState.nuova_partita()

func prova_linee_abilita() -> void:
	# UNA LINEA E' UN'ABILITA' CHE CRESCE, non sei abilita' che si somigliano.
	# Se due gradi della stessa linea risultassero noti insieme, il menu
	# mostrerebbe Flagello accanto a Terra bruciata accanto a Maelstrom: sei
	# versioni della stessa cosa, e nessuna ragione per usare le prime cinque.
	titolo("le linee di abilita' crescono, e nel menu ne passa un grado solo")
	var tabella: Dictionary = GameState.abilita.get("abilita", {})
	esigi(not tabella.is_empty(), "data/abilita.json non caricato")
	# 1. dentro una linea i gradi sono 1,2,3... senza buchi e senza doppioni, e
	#    ogni grado sta a un livello piu' alto del precedente
	var linee := {}
	for id_abilita in tabella:
		var dati: Dictionary = tabella[id_abilita]
		var linea := String(dati.get("linea", ""))
		if linea == "":
			esigi(not dati.has("grado"),
					"%s dichiara un grado ma non dice di che linea fa parte" % id_abilita)
			continue
		var grado := int(dati.get("grado", 0))
		esigi(grado >= 1, "%s e' nella linea '%s' senza un grado" % [id_abilita, linea])
		if not linee.has(linea):
			linee[linea] = {}
		esigi(not linee[linea].has(grado),
				"nella linea '%s' ci sono due gradi %d: uno dei due non si potra' mai comprare"
				% [linea, grado])
		linee[linea][grado] = id_abilita
	esigi(linee.size() >= 3, "le linee sono %d: ne mancano" % linee.size())
	for linea in linee:
		var gradi: Dictionary = linee[linea]
		var livello_prima := 0
		for grado in range(1, gradi.size() + 1):
			esigi(gradi.has(grado),
					"la linea '%s' salta il grado %d: la scala si interrompe e i gradi sopra non si aprono mai"
					% [linea, grado])
			if not gradi.has(grado):
				continue
			var dati: Dictionary = tabella[gradi[grado]]
			var livello := int(dati.get("livello", 0))
			esigi(livello > livello_prima,
					"nella linea '%s' il grado %d si impara al livello %d, non dopo il grado precedente (%d)"
					% [linea, grado, livello, livello_prima])
			livello_prima = livello
			if grado > 1:
				esigi(int(dati.get("costo", 0)) > 0,
						"%s e' un potenziamento e non costa punti: arriverebbe da solo" % gradi[grado])

	# 2. LE PERCENTUALI CHE HA DETTO BRU, una per una. Sono il senso della
	#    linea intera, e un refuso qui non lo troverebbe nessuno giocando
	var attese := {"annichilazione": 0.50, "annichilazione_ii": 0.55, "annichilazione_iii": 0.58,
			"annichilazione_iv": 0.62, "annichilazione_v": 0.65, "annichilazione_totale": 0.70}
	for id_abilita in attese:
		esigi(tabella.has(id_abilita), "manca %s" % id_abilita)
		esigi(is_equal_approx(float(tabella.get(id_abilita, {}).get("probabilita_ko", 0.0)),
				float(attese[id_abilita])),
				"%s ha una chance di KO del %d%% invece del %d%%"
				% [id_abilita, int(float(tabella.get(id_abilita, {}).get("probabilita_ko", 0.0)) * 100),
				int(float(attese[id_abilita]) * 100)])
	# e la linea del Flagello cresce di danno grado dopo grado, mai al contrario
	var bonus_prima := -1.0
	for id_abilita in ["flagello", "terra_bruciata", "maelstrom", "devastazione",
			"apocalisse", "fine_karmica"]:
		esigi(tabella.has(id_abilita), "manca %s" % id_abilita)
		var bonus := float(tabella.get(id_abilita, {}).get("bonus_attacco", 0.0))
		esigi(bonus >= bonus_prima,
				"%s fa meno danno del grado prima: il potenziamento peggiora l'abilita'" % id_abilita)
		bonus_prima = bonus

	# 3. nel menu ne compare uno solo. Si prova sul serio: si porta il
	#    protagonista al livello, si comprano i gradi, si guarda il menu
	GameState.nuova_partita()
	GameState.livelli[GameState.id_protagonista] = 130
	for linea in linee:
		var gradi: Dictionary = linee[linea]
		for grado in range(2, gradi.size() + 1):
			if gradi.has(grado):
				GameState.nodi_abilita.append(String(gradi[grado]))
	var usabili := GameState.abilita_usabili(GameState.id_protagonista)
	for linea in linee:
		var quanti := 0
		var quale := ""
		for id_abilita in usabili:
			if String(tabella.get(id_abilita, {}).get("linea", "")) == linea:
				quanti += 1
				quale = String(id_abilita)
		esigi(quanti == 1,
				"della linea '%s' nel menu compaiono %d abilita' invece di una" % [linea, quanti])
		var gradi_linea: Dictionary = linee[linea]
		esigi(quale == String(gradi_linea.get(gradi_linea.size(), "")),
				"della linea '%s' il menu mostra '%s' invece del grado piu' alto" % [linea, quale])
	GameState.nuova_partita()

func prova_punti_abilita() -> void:
	# I PUNTI SONO UNA RISORSA, e una risorsa che non si conta non e' una
	# risorsa. Se si potesse comprare tutto, le scelte al 25 e al 29 che Bru ha
	# descritto non sarebbero scelte.
	titolo("i punti abilita' si guadagnano, si spendono, e non si spendono due volte")
	GameState.nuova_partita()
	# 1. prima del livello di partenza non ce n'e' nessuno, e crescono un po'
	#    per volta, mai a salti
	var regola: Dictionary = GameState.abilita.get("punti", {})
	var dal := int(regola.get("dal_livello", 25))
	esigi(dal > 1, "i punti abilita' partono dal livello %d" % dal)
	esigi(GameState.punti_abilita_guadagnati(dal - 1) == 0,
			"al livello %d ci sono gia' dei punti" % (dal - 1))
	esigi(GameState.punti_abilita_guadagnati(dal) == int(regola.get("per_volta", 1)),
			"al livello %d non arriva il primo punto" % dal)
	var prima := 0
	for livello in range(1, 131):
		var ora := GameState.punti_abilita_guadagnati(livello)
		esigi(ora >= prima, "al livello %d i punti CALANO da %d a %d" % [livello, prima, ora])
		esigi(ora - prima <= int(regola.get("per_volta", 1)),
				"al livello %d arrivano %d punti in un colpo solo" % [livello, ora - prima])
		prima = ora

	# 2. LA SCELTA CHE BRU HA DESCRITTO, provata come si gioca. Al 25 c'e' un
	#    punto e ci sono due porte: Pieta' o Terra bruciata. Prenderne una deve
	#    chiudere l'altra, altrimenti non e' una scelta, e' un elenco
	GameState.livelli[GameState.id_protagonista] = 25
	esigi(GameState.punti_abilita_liberi() == 1,
			"al livello 25 il protagonista ha %d punti invece di 1" % GameState.punti_abilita_liberi())
	esigi(GameState.nodo_disponibile("pieta"), "al livello 25 Pieta' non e' disponibile")
	esigi(GameState.nodo_disponibile("terra_bruciata"),
			"al livello 25 Terra bruciata non e' disponibile")
	esigi(GameState.sblocca_nodo("terra_bruciata"), "Terra bruciata non si e' sbloccata")
	esigi(not GameState.nodo_disponibile("pieta"),
			"col punto gia' speso Pieta' e' ancora disponibile: i punti non si contano")
	esigi(GameState.punti_abilita_liberi() == 0,
			"dopo aver speso l'unico punto ne restano %d" % GameState.punti_abilita_liberi())
	esigi(not GameState.sblocca_nodo("pieta"), "si e' comprato un nodo senza punti")

	# 3. al 29 arriva il secondo punto, e le porte sono quelle giuste
	GameState.livelli[GameState.id_protagonista] = 29
	esigi(GameState.punti_abilita_liberi() == 1, "al livello 29 non arriva il secondo punto")
	esigi(GameState.nodo_disponibile("pieta"), "al 29 Pieta' doveva essere ancora li'")
	esigi(GameState.nodo_disponibile("annichilazione_ii"),
			"al 29 Annichilazione II non e' disponibile")

	# 4. non si salta un grado: Maelstrom vuole Terra bruciata, e il livello
	esigi(not GameState.nodo_disponibile("maelstrom"),
			"al livello 29 si puo' gia' comprare Maelstrom, che apre molto piu' avanti")
	GameState.livelli[GameState.id_protagonista] = 130
	esigi(GameState.nodo_disponibile("apocalisse") == false,
			"si puo' comprare Apocalisse saltando i gradi in mezzo")
	esigi(GameState.nodo_disponibile("maelstrom"),
			"col livello alto e Terra bruciata in mano Maelstrom non si apre")

	# 5. mai piu' di quello che hai guadagnato, comprando tutto quello che si puo'
	for giro in 60:
		var comprato := false
		for id_nodo in GameState.abilita.get("abilita", {}):
			if GameState.sblocca_nodo(String(id_nodo)):
				comprato = true
		for id_nodo in GameState.abilita.get("potenziamenti", {}):
			if GameState.sblocca_nodo(String(id_nodo)):
				comprato = true
		if not comprato:
			break
	esigi(GameState.punti_abilita_spesi() <= GameState.punti_abilita_guadagnati(130),
			"spesi %d punti su %d guadagnati"
			% [GameState.punti_abilita_spesi(), GameState.punti_abilita_guadagnati(130)])
	esigi(GameState.punti_abilita_liberi() >= 0, "i punti liberi sono andati sotto zero")
	GameState.nuova_partita()

func prova_abilita_arrivano_al_livello_giusto() -> void:
	# Quello che Bru ha scritto, riga per riga: Astio al 5, Vendetta all'8,
	# Flagello all'11, Annichilazione al 19. Prima di quel livello non ci
	# devono essere, e a quel livello ci devono essere senza spendere niente.
	titolo("le abilita' di base arrivano ai livelli che ha detto Bru")
	var attese := {"astio": 5, "vendetta": 8, "flagello": 11, "mantra": 14, "annichilazione": 19}
	for id_abilita in attese:
		var livello := int(attese[id_abilita])
		GameState.nuova_partita()
		GameState.livelli[GameState.id_protagonista] = livello - 1
		esigi(not id_abilita in GameState.abilita_del_protagonista(),
				"al livello %d il protagonista sa gia' fare %s" % [livello - 1, id_abilita])
		GameState.livelli[GameState.id_protagonista] = livello
		esigi(id_abilita in GameState.abilita_del_protagonista(),
				"al livello %d il protagonista non ha imparato %s" % [livello, id_abilita])
		esigi(int(GameState.abilita_combattimento(String(id_abilita)).get("costo", 0)) == 0,
				"%s arriva col livello ma costa anche punti: uno dei due e' di troppo" % id_abilita)
	GameState.nuova_partita()

func valore_di_ruolo(chiave: String, nome_ruolo: String, livello: int) -> int:
	const FINTA := "__creatura_di_ruolo__"
	GameState.personaggi[FINTA] = {"id": FINTA, "ruolo": nome_ruolo, "livello": livello,
			"scala_col_giocatore": false}
	var valore := GameState.stat_di_ruolo(FINTA, chiave, livello)
	GameState.personaggi.erase(FINTA)
	return valore

func valore_di_curva(chiave: String, livello: int) -> int:
	# quanto vale la stat di un nemico comune a quel livello. Si passa da una
	# creatura vera messa temporaneamente a quel livello, invece di rifare il
	# conto qui: una prova che si calcola da sola il risultato atteso non prova
	# la formula, prova se stessa
	const FINTA := "__creatura_di_prova__"
	GameState.personaggi[FINTA] = {"id": FINTA, "ruolo": "comune", "livello": livello,
			"scala_col_giocatore": false}
	var valore := GameState.stat_di_ruolo(FINTA, chiave)
	GameState.personaggi.erase(FINTA)
	return valore

func cresci_giocatore_fino_a(livello: int) -> void:
	# la stessa stima che usa il giocatore automatico, dallo stesso posto
	GameState.nuova_partita()
	GameState.livelli[GameState.id_protagonista] = livello
	var profilo: Dictionary = GameState.crescita.get("profilo_giocatore_tipo", {})
	for nome_azione: String in profilo:
		GameState.contatori[nome_azione] = int(profilo[nome_azione]) * (livello - 1)
	GameState.applica_crescita_livello()

func prova_crescita_non_scappa() -> void:
	# LA PROVA CHE MANCAVA, ED E' COSTATA IL BILANCIAMENTO DI MEZZO GIOCO.
	#
	# In Carnivalz le statistiche non salgono col livello: salgono con quello che
	# fai. Il contenuto invece e' scritto a mano, con numeri fissi. Se la crescita
	# corre piu' del contenuto, dal terzo livello in poi non si perde piu' - ed e'
	# successo davvero: +3 di attacco ogni 5 colpi, con una trentina di colpi per
	# livello, voleva dire triplicare la potenza a ogni livello. Al livello 3 il
	# protagonista aveva 375 hp e 45 di attacco contro creature da 135 hp e 6.
	#
	# Nessuno se n'era accorto perche' la tabella di bilanciamento misurava un
	# protagonista arrivato al livello 8 senza aver mai combattuto.
	#
	# Qui si controlla la PENDENZA, non i valori: quanto puo' crescere da un
	# livello al successivo, e quanto in tutto lungo la partita. Sono paletti
	# larghi: servono a fermare una valanga, non a impedire di ritoccare i numeri.
	titolo("la crescita del protagonista non scappa al contenuto")
	var profilo: Dictionary = GameState.crescita.get("profilo_giocatore_tipo", {})
	esigi(not profilo.is_empty(), "manca profilo_giocatore_tipo in crescita.json")
	var stat_misurate := ["hp", "attacco", "difesa"]
	var precedente := {}
	var base := {}
	for chiave in stat_misurate:
		base[chiave] = GameState.stat_base_di(chiave)
	for livello in range(1, 21):
		cresci_giocatore_fino_a(livello)
		for chiave: String in stat_misurate:
			var ora := GameState.stat_di(chiave)
			if precedente.has(chiave) and int(precedente[chiave]) > 0:
				# due condizioni insieme, e servono tutte e due: il rapporto da
				# solo grida al raddoppio quando la Difesa passa da 1 a 2 (che
				# non e' una valanga, e' un punto), l'incremento da solo non
				# vedrebbe niente su numeri grandi
				var salto := float(ora) / float(precedente[chiave])
				var aumento := ora - int(precedente[chiave])
				esigi(salto <= 1.6 or aumento <= 5,
						"al livello %d la stat '%s' cresce di %.1f volte in un colpo (+%d): e' una valanga"
						% [livello, chiave, salto, aumento])
			precedente[chiave] = ora
	# quanto si e' cresciuti in tutto dal livello 1 al 20: deve essere tanto (e'
	# il senso del gioco) ma non assurdo
	for chiave: String in ["hp", "attacco"]:
		var partenza := maxi(int(base[chiave]), 1)
		var arrivo := GameState.stat_di(chiave)
		var volte := float(arrivo) / float(partenza)
		esigi(volte >= 4.0,
				"dal livello 1 al 20 la stat '%s' cresce solo %.1f volte: non si sente nessuna evoluzione"
				% [chiave, volte])
		esigi(volte <= 18.0,
				"dal livello 1 al 20 la stat '%s' cresce %.1f volte: il contenuto non ci sta dietro"
				% [chiave, volte])
	GameState.nuova_partita()

func prova_la_difesa_riduce_non_cancella() -> void:
	# Bru: "il protagonista para troppo spesso i colpi". Era vero, e aveva due
	# cause: la difesa che sottraeva fino a zero, e una probabilita' di annullare
	# del tutto il colpo che al livello 6 arrivava a meta' dei colpi subiti.
	# Adesso un colpo che parte arriva sempre, e lascia sempre un numero.
	titolo("la difesa riduce, non cancella: un colpo lascia sempre un numero")
	GameState.nuova_partita()
	var frazione := float(GameState.regole.get("danno_minimo_percentuale", 0.0))
	esigi(frazione > 0.0, "danno_minimo_percentuale non e' impostato in regole.json")
	var attaccante := {
		"id": "goblin_tipico", "giocatore": false, "attacco": 30, "difesa": 0,
		"fattore": 0, "stress": 0, "buffs": [], "stati": [], "stati_attivi": {},
		"psiche": "", "immunita_temporanea": [], "hp": 100,
	}
	var bersaglio := {
		"id": "anonimo", "giocatore": false, "attacco": 0, "difesa": 0,
		"fattore": 0, "stress": 0, "buffs": [], "stati": [], "stati_attivi": {},
		"psiche": "", "immunita_temporanea": [], "hp": 100,
	}
	# 1. LA CORAZZA VINCE (difesa tripla rispetto al colpo): passa esattamente 1.
	#    Mai zero - e mai piu' di un graffio. E' quello che rende possibile una
	#    creatura che si chiude e non si abbatte piu' a mani nude.
	bersaglio.difesa = 90
	var minimo := 999
	var massimo := 0
	for prova in 200:
		var esito := RegoleCombattimento.calcola_danno(attaccante, bersaglio)
		minimo = mini(minimo, int(esito.danno))
		massimo = maxi(massimo, int(esito.danno))
	esigi(minimo >= 1,
			"contro una difesa altissima un colpo e' arrivato a %d: torna la parata a secco" % minimo)
	esigi(massimo <= 1,
			"la corazza ha perso pur superando il colpo: e' passato %d invece di 1" % massimo)
	# 2. LA CORAZZA PERDE (difesa appena sotto il colpo): passa almeno la frazione
	#    minima del colpo pieno, cosi' difendersi riduce ma non annulla
	bersaglio.difesa = 28
	minimo = 999
	for prova in 200:
		minimo = mini(minimo, int(RegoleCombattimento.calcola_danno(attaccante, bersaglio).danno))
	esigi(minimo >= int(ceil(30 * frazione)),
			"la difesa ha tolto piu' del %d%% di un colpo che passava (minimo: %d)"
			% [int(round((1.0 - frazione) * 100)), minimo])
	# 3. chi non fa male non fa male: 0 di attacco resta 0 danni
	attaccante.attacco = 0
	var esito_nullo := RegoleCombattimento.calcola_danno(attaccante, bersaglio)
	esigi(int(esito_nullo.danno) == 0, "un attaccante con 0 di attacco ha fatto danno")
	GameState.nuova_partita()

func prova_i_boss_non_si_superano_farmando() -> void:
	# Bru: "i boss saranno sempre a livello del personaggio, farmare per essere
	# piu' forti non deve poter rendere il boss meno una sfida". Le creature
	# comuni si possono superare - sono il paesaggio, e attraversarlo piu' in
	# fretta e' una ricompensa. Le fonti no.
	titolo("una fonte non si supera farmando")
	GameState.nuova_partita()
	var fonti: Array[String] = []
	var comuni: Array[String] = []
	for id_creatura in GameState.personaggi:
		if not GameState.e_creatura(id_creatura) or not GameState.nemico_scala(id_creatura):
			continue
		if GameState.e_boss(id_creatura):
			fonti.append(id_creatura)
		else:
			comuni.append(id_creatura)
	esigi(not fonti.is_empty(), "nessuna fonte riconosciuta: la regola non protegge niente")
	for livello_eroe in [5, 12, 30, 60]:
		GameState.livelli[GameState.id_protagonista] = livello_eroe
		for id_fonte in fonti:
			esigi(GameState.livello_nemico(id_fonte) >= livello_eroe,
					"la fonte %s e' lv %d contro un protagonista lv %d: si supera farmando"
					% [id_fonte, GameState.livello_nemico(id_fonte), livello_eroe])
		# e le comuni invece devono restare indietro, o non c'e' nessuna
		# ricompensa nel diventare forti
		var qualcuna_sotto := false
		for id_comune in comuni:
			if GameState.livello_nemico(id_comune) < livello_eroe:
				qualcuna_sotto = true
		esigi(qualcuna_sotto,
				"al livello %d nessuna creatura comune resta sotto di te: livellare non serve a niente"
				% livello_eroe)
	GameState.nuova_partita()

func prova_salita_di_livello_si_racconta() -> void:
	# Bru: "quando sali di livello deve spiegarti che lo hai fatto e mostrarti
	# l'aumento delle statistiche". Qui e' piu' importante che altrove, perche'
	# in Carnivalz le stat non salgono col livello: salgono con quello che hai
	# fatto, e diventano punti proprio al passaggio di livello. Se quel momento
	# non dice niente, il giocatore non scopre mai a cosa e' servito giocare
	# come ha giocato.
	titolo("salire di livello lo dice, e dice cosa e' cambiato")
	GameState.nuova_partita()
	esigi(GameState.salite_di_livello.is_empty(),
			"si parte con delle salite di livello in attesa")
	# si gioca un po' - cosi' i contatori hanno qualcosa da convertire - e poi
	# si prende l'esperienza per salire
	var profilo: Dictionary = GameState.crescita.get("profilo_giocatore_tipo", {})
	for nome_azione: String in profilo:
		GameState.contatori[nome_azione] = int(profilo[nome_azione])
	var prima_attacco := GameState.stat_di("attacco")
	GameState.aggiungi_xp(GameState.id_protagonista,
			GameState.fabbisogno_xp(GameState.livello_di(GameState.id_protagonista)))
	esigi(GameState.livello_di(GameState.id_protagonista) == 2,
			"con l'esperienza esatta non si e' saliti di livello")
	esigi(GameState.salite_di_livello.size() == 1,
			"la salita di livello non ha lasciato niente da raccontare")
	var salita: Dictionary = GameState.salite_di_livello[0]
	esigi(int(salita.get("livello", 0)) == 2, "la salita non dice a che livello sei arrivato")
	var cresciute: Array = salita.get("stat", [])
	esigi(not cresciute.is_empty(),
			"la salita non elenca nessuna statistica cresciuta, ma le stat sono cambiate")
	for voce in cresciute:
		esigi(String(voce.get("nome", "")) != "",
				"una statistica cresciuta non ha un nome da mostrare")
		esigi(int(voce.get("dopo", 0)) > int(voce.get("prima", 0)),
				"'%s' e' nell'elenco delle cresciute ma non e' cresciuta" % String(voce.get("nome", "")))
	# e il conto e' quello vero, non un numero raccontato a caso
	for voce in cresciute:
		if String(voce.get("stat", "")) == "attacco":
			esigi(int(voce.get("prima", -1)) == prima_attacco,
					"l'attacco 'prima' e' %d, ma prima era %d" % [int(voce.get("prima", -1)), prima_attacco])
			esigi(int(voce.get("dopo", 0)) == GameState.stat_di("attacco"),
					"l'attacco 'dopo' non e' quello che hai adesso")

	# ...e chi lo mostra lo svuota, altrimenti lo racconterebbe a ogni stanza.
	# La schermata le consuma gia' nascendo (e' il suo mestiere: le mostra
	# appena si torna agli eventi), quindi si apre PRIMA e si sale di livello
	# DOPO - come succede giocando, dove si sale in combattimento e si legge
	# tornando alla stanza
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	GameState.salite_di_livello.append(salita)
	var righe: Array = schermata.notifiche_salite_di_livello()
	esigi(righe.size() >= 2,
			"la salita di livello produce %d messaggi: non basta a spiegare cos'e' successo" % righe.size())
	var tutto := ""
	for riga in righe:
		tutto += String(riga.get("testo", "")) + "\n"
	esigi(tutto.contains("Livello 2"), "il messaggio non dice a che livello sei arrivato")
	esigi(tutto.contains("→"), "il messaggio non mostra il prima e il dopo delle statistiche")
	esigi(GameState.salite_di_livello.is_empty(),
			"dopo averla mostrata la salita e' ancora in coda: si ripeterebbe a ogni stanza")
	esigi(schermata.notifiche_salite_di_livello().is_empty(),
			"la salita si racconta due volte")
	schermata.free()

	# e la Manifestazione lascia la pietra per rivivere, come ha chiesto Bru:
	# e' un incontro unico, quindi il premio non puo' dipendere da un tiro di
	# dado - un dado su una cosa che non si ripete non e' una probabilita', e'
	# una beffa
	var manifestazione: Dictionary = GameState.personaggi.get("manifestazione_di_un_sogno", {})
	var lascia_la_pietra := false
	for voce in manifestazione.get("bottino_comune", []):
		if String(voce.get("oggetto", "")) == "ricordo_del_passato":
			lascia_la_pietra = true
			esigi(float(voce.get("chance", 0.0)) >= 1.0,
					"la pietra per rivivere cade solo il %d%% delle volte, da un nemico che si incontra una volta sola"
					% int(float(voce.get("chance", 0.0)) * 100))
	esigi(lascia_la_pietra, "la Manifestazione non lascia piu' la pietra per rivivere")
	esigi(GameState.oggetti.has("ricordo_del_passato"),
			"la pietra per rivivere non esiste fra gli oggetti")
	esigi(String(GameState.dati_oggetto("ricordo_del_passato").get("effetto_equipaggiato", {}).get("tipo", ""))
			== "resurrezione_dimezzata",
			"quello che lascia la Manifestazione non fa piu' rivivere")

	GameState.nuova_partita()

func prova_guardia_a_scatti() -> void:
	# BRU, IN PAROLE SUE: "quando ti difendi, la difesa sale di pochissimo, ma
	# deve essere cumulativa fino alla fine della battaglia... se mi difendo 5
	# volte dovrei poter ridurre i danni degli attacchi dei nemici, ovviamente
	# non e' che continuo a difendermi e continua a salire all'infinito...
	# bisogna fare come in pokemon".
	#
	# Sono quattro cose, e servono tutte e quattro: sale poco, resta, il quinto
	# scatto si sente addosso, e sopra il tetto non va. Prima ne mancavano due:
	# la guardia si azzerava appena facevi altro (quindi difendersi cinque volte
	# valeva quanto difendersi una) e non c'era nessun tetto vero.
	titolo("la guardia si accumula, resta, e ha un tetto (come in Pokemon)")
	GameState.nuova_partita()
	var tetto := int(GameState.regole.get("difesa_scatti_massimi", 6))
	esigi(tetto > 0, "non c'e' nessun tetto agli scatti di difesa")
	var eroe := {
		"id": GameState.id_protagonista, "giocatore": true, "attacco": 10, "difesa": 4,
		"fattore": 0, "stress": 0, "buffs": [], "stati": [], "stati_attivi": {},
		"psiche": "", "immunita_temporanea": [], "hp": 200, "scatti_difesa": 0,
	}
	var nemico := {
		"id": "ghoul", "giocatore": false, "attacco": 40, "difesa": 0,
		"fattore": 0, "stress": 0, "buffs": [], "stati": [], "stati_attivi": {},
		"psiche": "", "immunita_temporanea": [], "hp": 200, "scatti_difesa": 0,
	}
	# 1. sale poco per volta, e ogni scatto in su vale meno del precedente
	var difese: Array[int] = [RegoleCombattimento.difesa_di(eroe)]
	for scatto in tetto:
		RegoleCombattimento.alza_guardia(eroe)
		difese.append(RegoleCombattimento.difesa_di(eroe))
	for indice in range(1, difese.size()):
		esigi(difese[indice] > difese[indice - 1],
				"al %d° scatto la difesa non e' salita (%d -> %d)"
				% [indice, difese[indice - 1], difese[indice]])
	esigi(difese[1] - difese[0] <= difese[0] + 6,
			"il primo scatto raddoppia e passa la difesa: non e' 'di pochissimo'")

	# 2. IL TETTO. Oltre non si va, per quante volte ci si chiuda
	var al_tetto := RegoleCombattimento.difesa_di(eroe)
	for ancora in 20:
		RegoleCombattimento.alza_guardia(eroe)
	esigi(RegoleCombattimento.difesa_di(eroe) == al_tetto,
			"difendendosi altre venti volte la difesa e' salita ancora: si diventa inattaccabili stando fermi")
	esigi(RegoleCombattimento.scatti_difesa(eroe) == tetto,
			"gli scatti sono %d, oltre il tetto di %d" % [RegoleCombattimento.scatti_difesa(eroe), tetto])

	# 3. CINQUE VOLTE SI SENTONO, ed e' la richiesta di Bru misurata sul danno
	#    vero, non sul numero della difesa
	eroe.scatti_difesa = 0
	var danno_medio := func() -> float:
		var somma := 0
		for tiro in 400:
			somma += int(RegoleCombattimento.calcola_danno(nemico, eroe).danno)
		return float(somma) / 400.0
	var scoperto: float = danno_medio.call()
	for volta in 5:
		RegoleCombattimento.alza_guardia(eroe)
	var chiuso: float = danno_medio.call()
	esigi(chiuso < scoperto * 0.75,
			"difendendosi cinque volte si incassa %.1f invece di %.1f: non si sente"
			% [chiuso, scoperto])
	esigi(chiuso >= 1.0, "difendendosi cinque volte non si incassa piu' niente: la difesa cancella")

	# 4. e certi colpi la aprono, anche sotto zero
	var prima_di_aprirla := RegoleCombattimento.difesa_di(eroe)
	RegoleCombattimento.abbassa_guardia(eroe, 2)
	esigi(RegoleCombattimento.difesa_di(eroe) < prima_di_aprirla,
			"un colpo che apre la guardia non l'ha abbassata")
	eroe.scatti_difesa = 0
	var a_zero := RegoleCombattimento.difesa_di(eroe)
	RegoleCombattimento.abbassa_guardia(eroe, 3)
	esigi(RegoleCombattimento.difesa_di(eroe) < a_zero,
			"sotto zero gli scatti non fanno piu' niente: la guardia aperta non si paga")
	esigi(RegoleCombattimento.scatti_difesa(eroe) >= -tetto,
			"gli scatti sono scesi sotto il tetto in negativo")
	GameState.nuova_partita()

func prova_corazza_che_cresce() -> void:
	# La Tartaruga si chiude a ogni turno e non si riapre. La prova non e' sul
	# numero (quello e' contenuto): e' sul fatto che il campo esista, che sia
	# permanente, e che porti davvero il colpo del protagonista a 1.
	titolo("una corazza che cresce a ogni turno arriva a fermare un colpo")
	GameState.nuova_partita()
	var dati: Dictionary = GameState.personaggi.get("tartaruga_innocente", {})
	var passo := int(dati.get("difesa_per_turno", 0))
	esigi(passo > 0, "la Tartaruga non ha piu' la corazza che cresce")
	esigi(int(dati.get("attacco", 0)) == 0, "la Tartaruga ha imparato ad attaccare")
	var attaccante := {
		"id": GameState.id_protagonista, "giocatore": true, "attacco": 40, "difesa": 0,
		"fattore": 0, "stress": 0, "buffs": [], "stati": [], "stati_attivi": {},
		"psiche": "", "immunita_temporanea": [], "hp": 100,
	}
	var guscio := {
		"id": "tartaruga_innocente", "giocatore": false, "attacco": 0,
		"difesa": int(dati.get("difesa", 0)),
		"fattore": 0, "stress": 0, "buffs": [], "stati": [], "stati_attivi": {},
		"psiche": "", "immunita_temporanea": [], "hp": int(dati.get("hp", 1)),
	}
	var turni_per_fermarlo := 0
	for turno in 60:
		guscio.difesa = int(guscio.difesa) + passo
		if int(RegoleCombattimento.calcola_danno(attaccante, guscio).danno) <= 1:
			turni_per_fermarlo = turno + 1
			break
	esigi(turni_per_fermarlo > 0,
			"la corazza non arriva mai a fermare un colpo da 40: la Tartaruga si abbatte a mani nude")
	esigi(turni_per_fermarlo >= 3,
			"la corazza ferma tutto dopo %d turni: non c'e' il tempo di capire cosa sta succedendo"
			% turni_per_fermarlo)
	GameState.nuova_partita()

func prova_colori_del_danno() -> void:
	# Un numero che vola col colore sbagliato non e' un errore che si vede: e'
	# semplicemente rosso come tutti gli altri, e l'informazione si perde. Qui si
	# controlla che ogni elemento nominato nei dati abbia il suo colore.
	titolo("ogni elemento ha il suo colore")
	var tabella: Dictionary = Stile.dati.get("colori_danno", {})
	esigi(not tabella.is_empty(), "manca colori_danno in stile.json")
	for chiave: String in ["normale", "critico", "cura"]:
		esigi(tabella.has(chiave), "colori_danno non ha '%s'" % chiave)
	var elementi: Array[String] = []
	var raccogli := func(valore: Variant) -> void:
		var nome := String(valore)
		if nome != "" and nome not in elementi:
			elementi.append(nome)
	for id_stato in GameState.stati:
		raccogli.call(GameState.stati[id_stato].get("elemento", ""))
	for id_personaggio in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_personaggio]
		raccogli.call(dati.get("elemento", ""))
		raccogli.call(dati.get("combustione", {}).get("elemento", ""))
		for mossa in dati.get("mosse", []):
			raccogli.call(mossa.get("elemento", ""))
	for id_oggetto in GameState.oggetti:
		raccogli.call(GameState.oggetti[id_oggetto].get("effetto", {}).get("elemento", ""))
	var tutte: Dictionary = GameState.abilita.get("abilita", {})
	for id_abilita in tutte:
		raccogli.call(tutte[id_abilita].get("elemento", ""))
	esigi(not elementi.is_empty(), "nessun elemento dichiarato da nessuna parte: la funzione e' morta")
	for nome_elemento in elementi:
		esigi(tabella.has(nome_elemento),
				"l'elemento '%s' e' usato nei dati ma non ha un colore in stile.json" % nome_elemento)
		esigi(Stile.colore_danno(nome_elemento) != Stile.colore_danno("normale"),
				"l'elemento '%s' ha lo stesso colore di un colpo normale: non si distingue" % nome_elemento)

func prova_abilita_di_combattimento() -> void:
	# Le abilita' stanno in data/abilita.json e il motore ne conosce dei TIPI. Se
	# qualcuno ne scrive una di tipo "fiammata" il menu la mostra e poi non
	# succede niente: e' esattamente il genere di buco che si trova giocando.
	titolo("le abilita' di combattimento sono tutte eseguibili")
	var tipi_noti := ["provoca", "area", "raffica", "carica",
			"astio", "vendetta", "annichilazione", "pieta", "mantra", "flagello"]
	var tabella: Dictionary = GameState.abilita.get("abilita", {})
	esigi(not tabella.is_empty(), "nessuna abilita' di combattimento in data/abilita.json")
	for id_abilita in tabella:
		var dati: Dictionary = tabella[id_abilita]
		esigi(String(dati.get("nome", "")) != "", "l'abilita' %s non ha un nome" % id_abilita)
		# UN SEGNAPOSTO DI TROPPO NON E' UN REFUSO: in GDScript un format
		# sbagliato e' un errore a runtime, e un errore a runtime interrompe la
		# funzione dov'e' successo. Fine karmica aveva due %s e ne riceveva uno:
		# l'abilita' stampava mezza riga e poi NON FACEVA DANNO AFFATTO, e da
		# fuori sembrava solo un'abilita' debole.
		#
		# Quanti ne riceve dipende dal tipo, e sta scritto qui perche' e' un
		# patto fra i dati e il motore: Vendetta nomina chi colpisce e chi
		# subisce, tutte le altre nominano una cosa sola.
		var quanti_ne_riceve := 2 if String(dati.get("tipo", "")) == "vendetta" else 1
		for chiave in ["testo_uso", "testo_ko", "testo_niente", "testo_inutile", "testo_carica"]:
			var testo := String(dati.get(chiave, ""))
			if testo == "":
				continue
			esigi(testo.count("%s") <= quanti_ne_riceve,
					"%s: '%s' ha %d segnaposto e il motore ne passa %d: l'abilita' si interrompe li'"
					% [id_abilita, chiave, testo.count("%s"), quanti_ne_riceve])
		esigi(String(dati.get("testo_accumulo", "")).count("%") <= 2,
				"%s: 'testo_accumulo' ha troppi segnaposto" % id_abilita)
		esigi(String(dati.get("testo_statistiche", "")).count("%") <= 2,
				"%s: 'testo_statistiche' ha troppi segnaposto" % id_abilita)
		esigi(String(dati.get("tipo", "")) in tipi_noti,
				"l'abilita' %s e' di tipo '%s', che il combattimento non sa eseguire"
				% [id_abilita, String(dati.get("tipo", ""))])
		esigi(int(dati.get("aura", -1)) >= 0, "l'abilita' %s non dice quanta aura costa" % id_abilita)
		if String(dati.get("tipo", "")) == "raffica":
			esigi(int(dati.get("colpi", 0)) > 0, "la raffica %s non spara niente" % id_abilita)
			esigi(float(dati.get("frazione_danno", 0.0)) > 0.0,
					"la raffica %s non fa danno" % id_abilita)
		if String(dati.get("tipo", "")) == "carica":
			esigi(float(dati.get("moltiplicatore", 0.0)) > 1.0,
					"il colpo caricato %s vale meno di un colpo normale" % id_abilita)
	# nessuna classe deve avere un'abilita' che non esiste da nessuna parte
	var narrative := ["anonimato", "studio", "veglia", "sesto_senso", "scasso", "trappole",
			"volo", "impatto", "collezione", "innesti"]
	for id_classe in GameState.classi:
		for id_abilita in GameState.classi[id_classe].get("abilita", []):
			esigi(tabella.has(id_abilita) or String(id_abilita) in narrative,
					"%s ha l'abilita' '%s' e non esiste ne' in combattimento ne' fra le narrative"
					% [id_classe, id_abilita])
	# il costo dev'essere pagabile: un'abilita' che costa piu' dell'aura massima
	# non si userebbe mai, e nessuno capirebbe perche'
	var aura_massima := int(GameState.regole.get("aura_iniziale", 10))
	for id_abilita in tabella:
		esigi(int(tabella[id_abilita].get("aura", 0)) <= aura_massima,
				"l'abilita' %s costa piu' aura di quanta se ne possa avere" % id_abilita)

func prova_sede() -> void:
	titolo("la Sede: stanze, azioni e presidio")
	var letto: Variant = GameState.carica_json("res://data/sede.json")
	esigi(letto is Dictionary, "data/sede.json non si legge")
	if not letto is Dictionary:
		return
	var sede: Dictionary = letto
	esigi(String(sede.get("nome", "")) != "", "la Sede non ha un nome")
	var azioni_note := ["mappa", "negozio", "squadra", "diario", "testo"]
	var stanze: Array = sede.get("stanze", [])
	esigi(not stanze.is_empty(), "la Sede non ha stanze")
	var ids: Array[String] = []
	var porta_alla_mappa := false
	for stanza in stanze:
		var id_stanza := String(stanza.get("id", ""))
		esigi(id_stanza != "", "una stanza della Sede non ha id")
		esigi(id_stanza not in ids, "due stanze della Sede hanno lo stesso id: %s" % id_stanza)
		ids.append(id_stanza)
		esigi(String(stanza.get("nome", "")) != "", "la stanza %s non ha un nome" % id_stanza)
		esigi(String(stanza.get("descrizione", "")) != "",
				"la stanza %s non ha una descrizione: il pannello di destra resterebbe vuoto" % id_stanza)
		var azione := String(stanza.get("azione", "testo"))
		esigi(azione in azioni_note,
				"la stanza %s fa '%s', che la Sede non sa fare" % [id_stanza, azione])
		if azione == "mappa":
			porta_alla_mappa = true
		if stanza.has("richiede_flag"):
			esigi(String(stanza.get("testo_chiusa", "")) != "",
					"la stanza %s si puo' trovare chiusa e non dice perche'" % id_stanza)
	# Se nessuna stanza porta alla mappa stellare, il gioco e' finito qui: si
	# resta alla Sede a guardare le pareti. E' l'unico collegamento che DEVE
	# esserci, e quindi l'unico che vale la pena controllare.
	esigi(porta_alla_mappa, "dalla Sede non si arriva alla mappa stellare: non si parte piu'")

func prova_posti_visitati() -> void:
	titolo("dove sei gia' stato")
	GameState.nuova_partita()
	esigi(GameState.stato_visita("meridia") == "nuovo", "un posto mai visto non risulta nuovo")
	GameState.segna_visitata("meridia")
	esigi(GameState.stato_visita("meridia") == "visto", "un posto visitato risulta ancora nuovo")
	GameState.segna_visitata("meridia")
	esigi(GameState.zone_visitate.count("meridia") == 1, "un posto visitato due volte viene contato due volte")
	GameState.imposta_flag("meridia_finita")
	esigi(GameState.stato_visita("meridia", "meridia_finita") == "chiuso",
			"una zona conclusa non risulta chiusa")
	# entrare in una zona la segna da sola: nessuno deve ricordarsi di farlo
	GameState.nuova_partita()
	GameState.avvia_carnivalz("tutorial_prova", "res://data/events_tutorial.json")
	esigi(GameState.gia_visitata("tutorial_prova"),
			"entrare in una zona non la segna come visitata")
	# i tre stati hanno tre colori diversi, o il segno non serve a niente
	var tinte := [Stile.colore_visita("nuovo"), Stile.colore_visita("visto"), Stile.colore_visita("chiuso")]
	esigi(tinte[0] != tinte[1] and tinte[1] != tinte[2] and tinte[0] != tinte[2],
			"due stati di visita hanno lo stesso colore")
	GameState.nuova_partita()

func prova_game_over_ricarica_davvero() -> void:
	# "Riprendi dall'ultimo salvataggio" deve fare quello che dice.
	#
	# Non lo faceva: rifaceva la zona tenendo lo stato in memoria, quindi le
	# fiale usate restavano usate e i Tazo spesi restavano spesi. Il bottone
	# mentiva, e chi moriva dopo aver speso mezza sacca ricominciava senza.
	#
	# Qui si salva, si consuma roba, si muore, e si controlla che sia tornata.
	titolo("riprendere dal salvataggio riporta davvero indietro")
	var slot_prova := GameState.SLOT_MASSIMO
	var percorso := GameState.percorso_slot(slot_prova)
	var c_era := FileAccess.file_exists(percorso)
	var salvato := FileAccess.get_file_as_string(percorso) if c_era else ""

	GameState.nuova_partita()
	GameState.imposta_slot(slot_prova)
	GameState.sacca.append("fiala_hp")
	GameState.sacca.append("fiala_hp")
	GameState.tazo = 500
	GameState.salva()                       # questo e' "il momento del salvataggio"
	# ...poi si gioca: si spende, si consuma, si entra in una zona
	GameState.sacca.erase("fiala_hp")
	GameState.tazo = 12
	GameState.avvia_carnivalz("prova_zona", "res://data/events_tutorial.json")
	esigi(GameState.sacca.count("fiala_hp") == 1, "la prova non ha consumato niente")

	esigi(GameState.game_over() == "salvataggio",
			"il game over non ha ricaricato il salvataggio")
	esigi(GameState.sacca.count("fiala_hp") == 2,
			"le fiale usate non sono tornate: si riprende da un salvataggio che non e' un salvataggio")
	esigi(GameState.tazo == 500, "i Tazo spesi non sono tornati (%d invece di 500)" % GameState.tazo)
	esigi(GameState.carnivalz_corrente == "",
			"dopo aver ricaricato si e' ancora dentro la zona: il caricamento deve riportare fuori")

	# Una partita NUOVA in uno slot gia' occupato non deve ricaricare la partita
	# di prima: finche' non ha salvato lei, quel file non e' suo.
	GameState.nuova_partita()
	GameState.imposta_slot(slot_prova)
	GameState.tazo = 7
	GameState.avvia_carnivalz("prova_zona", "res://data/events_tutorial.json")
	esigi(GameState.game_over() == "zona",
			"una partita che non ha ancora salvato ha ricaricato il file di un'altra")
	esigi(GameState.tazo == 7,
			"il game over ha portato dentro i Tazo di un'altra partita (%d)" % GameState.tazo)

	# pulizia: lo slot di prova torna com'era
	if c_era:
		var f := FileAccess.open(percorso, FileAccess.WRITE)
		if f != null:
			f.store_string(salvato)
			f.close()
	else:
		GameState.elimina_slot(slot_prova)
	GameState.imposta_slot(1)
	GameState.nuova_partita()

func prova_espressione_per_battuta() -> void:
	# OGNI BATTUTA PUO' AVERE LA SUA FACCIA, E SU QUALUNQUE LATO DEL PALCO.
	#
	# Il campo "espr" su un messaggio c'era gia', ma funzionava solo nelle scene
	# a un personaggio solo ("centro"): in un dialogo a due veniva letto e
	# buttato via. Nessun errore, nessun avviso - semplicemente il ritratto non
	# cambiava, e chi scriveva i dialoghi non aveva modo di accorgersene se non
	# guardando lo schermo battuta per battuta.
	#
	# Questa prova mette due personaggi in scena e fa parlare quello di destra
	# con un'espressione: se il suo ritratto non cambia, fallisce.
	titolo("l'espressione di una battuta arriva a chi parla, ovunque sia")
	GameState.nuova_partita()
	GameState.eventi = {
		"prova_palco": {
			"sinistra": GameState.id_protagonista,
			"destra": "insonne",
			"sequenza": [{"tipo": "narrazione", "testo": "Il corridoio è fermo."}],
		},
	}
	GameState.nodo_corrente = "prova_palco"
	var scena: PackedScene = load("res://scenes/Main.tscn")
	var schermata: Node = scena.instantiate()
	add_child(schermata)
	esigi(schermata.slot_destra.visible, "il secondo personaggio non e' in scena")
	esigi(String(schermata.slot_destra.id_mostrato) == "insonne",
			"a destra c'e' qualcun altro: %s" % String(schermata.slot_destra.id_mostrato))
	var prima := String(schermata.slot_destra.espressione_mostrata)
	schermata.mostra_messaggio({"tipo": "dialogo", "chi": "insonne",
			"testo": "Non dormo da tre giorni.", "espr": "arrabbiata"})
	esigi(String(schermata.slot_destra.espressione_mostrata) == "arrabbiata",
			"la battuta chiedeva 'arrabbiata' e il ritratto a destra e' rimasto '%s'"
			% String(schermata.slot_destra.espressione_mostrata))
	esigi(prima != "arrabbiata", "la prova parte gia' col risultato che vuole verificare")
	# una battuta senza "espr" non riporta la faccia a neutra: dura finche'
	# qualcuno non la cambia, come in scena
	schermata.mostra_messaggio({"tipo": "dialogo", "chi": "insonne", "testo": "Ma sto bene."})
	esigi(String(schermata.slot_destra.espressione_mostrata) == "arrabbiata",
			"una battuta senza espressione ha riportato il ritratto a neutra")
	# e non tocca chi non sta parlando
	schermata.mostra_messaggio({"tipo": "dialogo", "chi": GameState.id_protagonista,
			"testo": "Si vede.", "espr": "pensiero"})
	esigi(String(schermata.slot_destra.espressione_mostrata) == "arrabbiata",
			"la battuta di uno ha cambiato la faccia dell'altro")
	esigi(String(schermata.slot_sinistra.espressione_mostrata) == "pensiero",
			"il protagonista a sinistra non ha cambiato espressione")
	schermata.free()
	GameState.nuova_partita()

func prova_nomi_delle_immagini() -> void:
	# UN DISEGNO COL NOME SBAGLIATO NON DA' NESSUN ERRORE.
	#
	# Il gioco cerca il file, non lo trova, e mostra il segnaposto con l'iniziale
	# del nome. Nessun avviso, niente nella console: uno se ne accorge giocando,
	# magari fra un mese, e nel frattempo pensa di aver messo il disegno.
	#
	# Il tranello vero e' che il nome del file NON e' l'id: lo decide il campo
	# "ritratto" nei dati. Yhvina ha id "insonne" e file yhvina.png.
	#
	# Qui non si pretende che i disegni ci siano - si fanno a poco a poco. Si
	# pretende che ogni file MESSO abbia un nome che qualcuno sta cercando.
	titolo("i disegni messi hanno un nome che il gioco cerca")
	var attesi: Array[String] = []
	var cartelle_attese: Array[String] = []
	var raccogli := func(id_personaggio: String, ritratto: String) -> void:
		if ritratto != "" and ritratto not in attesi:
			attesi.append(ritratto.get_file())
		if id_personaggio != "" and id_personaggio not in cartelle_attese:
			cartelle_attese.append(id_personaggio)
	for id_classe in GameState.classi:
		raccogli.call(String(id_classe), String(GameState.classi[id_classe].get("ritratto", "")))
	for id_personaggio in GameState.personaggi:
		raccogli.call(String(id_personaggio),
				String(GameState.personaggi[id_personaggio].get("ritratto", "")))
	esigi(not attesi.is_empty(), "nessun ritratto dichiarato nei dati: la prova non guarda niente")

	var cartella := DirAccess.open("res://art/personaggi")
	if cartella == null:
		return  # la cartella non c'e' ancora: non e' un errore, e' un progetto giovane
	for nome in cartella.get_files():
		if nome.begins_with(".") or nome.ends_with(".md") or nome.ends_with(".import"):
			continue
		esigi(nome in attesi,
				"art/personaggi/%s non lo cerca nessuno: nome sbagliato? (vedi docs/immagini.md)" % nome)
	for nome_cartella in cartella.get_directories():
		esigi(nome_cartella in cartelle_attese,
				"art/personaggi/%s/ non e' l'id di nessuno: le cartelle delle espressioni si chiamano come l'id"
				% nome_cartella)
		var dentro := DirAccess.open("res://art/personaggi/" + nome_cartella)
		if dentro == null:
			continue
		# Le 16 sono una convenzione, non una gabbia: un dialogo puo' chiedere
		# un'espressione con qualunque nome ("sotto_la_pioggia"), e allora quel
		# file e' legittimo. Quello che non deve passare e' un file che NESSUNO
		# chiama - cioe' un nome scritto storto, che a schermo diventa
		# silenziosamente il segnaposto.
		var ammesse := ESPRESSIONI + espressioni_usate_nei_dialoghi()
		for nome_file in dentro.get_files():
			if nome_file.begins_with(".") or nome_file.ends_with(".import"):
				continue
			esigi(nome_file.get_basename() in ammesse,
					"art/personaggi/%s/%s: nessun dialogo chiede questa espressione (nome storto?)"
					% [nome_cartella, nome_file])

func prova_leva_bersaglio() -> void:
	# LE LETTERE NON SI BRUCIANO PIU' PRIMA: SI SCOPRONO DURANTE.
	#
	# Studiando la bambola abbastanza volte le lettere sull'altare cominciano a
	# vibrare e diventano attaccabili: distruggerle e' la leva. Tre cose possono
	# rompersi senza che nessuno se ne accorga - le lettere non compaiono mai (e
	# la leva diventa irraggiungibile), compaiono ma distruggerle non da' niente
	# (leva muta), oppure il conto alla rovescia parte lo stesso dopo che sono
	# state distrutte, e allora al giocatore non resta piu' niente da colpire per
	# fermarlo: punito per aver usato la meccanica che il gioco gli ha insegnato.
	titolo("le lettere si scoprono studiando, e distruggerle vale")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["tenero_ricordo"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	add_child(scontro)

	var bambola: Dictionary = {}
	for combattente in scontro.combattenti:
		if not combattente.giocatore:
			bambola = combattente
	esigi(not bambola.is_empty(), "la bambola non e' in campo")

	var leva: Dictionary = scontro.leva_bersaglio_di("lettere_altare")
	esigi(not leva.is_empty(), "la bambola non ha piu' la leva delle lettere")
	var quanti_studi := int(leva.get("dopo_studi", 3))

	var in_campo := func() -> bool:
		for combattente in scontro.combattenti:
			if String(combattente.id) == "lettere_altare":
				return true
		return false

	# prima della soglia di studi le lettere non ci sono
	bambola.volte_studiato = quanti_studi - 1
	scontro.verifica_leve_bersaglio(bambola)
	esigi(not in_campo.call(), "le lettere compaiono prima di aver studiato abbastanza")

	bambola.volte_studiato = quanti_studi
	scontro.verifica_leve_bersaglio(bambola)
	esigi(in_campo.call(), "studiando abbastanza le lettere non compaiono: la leva e' irraggiungibile")

	# e non compaiono due volte
	scontro.verifica_leve_bersaglio(bambola)
	var quante := 0
	for combattente in scontro.combattenti:
		if String(combattente.id) == "lettere_altare":
			quante += 1
	esigi(quante == 1, "le lettere sono comparse piu' di una volta")

	# distruggerle vale la speranza dichiarata nei dati
	var lettere: Dictionary = {}
	for combattente in scontro.combattenti:
		if String(combattente.id) == "lettere_altare":
			lettere = combattente
	var speranza_prima: int = scontro.speranza
	lettere.hp = 0
	scontro._su_ko(lettere)
	esigi(scontro.speranza == speranza_prima + int(leva.get("speranza", 0)),
			"distruggere le lettere non ha dato la speranza che la leva promette")

	# e adesso il conto alla rovescia non deve piu' partire: non c'e' piu' niente
	# da colpire per fermarlo
	bambola.hp = int(bambola.hp_max * 0.2)
	scontro.verifica_innesco_frenesia(bambola)
	esigi(not scontro.frenesia_attiva,
			"la frenesia parte anche senza le lettere: il giocatore non puo' piu' fermarla")
	scontro.queue_free()

func prova_mappa_a_quadratini() -> void:
	# LA MAPPA NON DEVE RACCONTARE PIU' DI QUELLO CHE SAI.
	#
	# I tre stati di un quadratino sono l'unica cosa che la schermata deve
	# azzeccare, e sono tutti e tre sbagliabili in silenzio: una stanza mai
	# sentita che compare rovina l'esplorazione di tutta la zona, una stanza
	# raggiungibile che non compare la blocca, e un "?" cliccabile che non
	# doveva esserlo teletrasporta il giocatore dove la storia non l'ha ancora
	# portato. A schermo nessuno di questi tre casi da' errore.
	titolo("la mappa a quadratini")
	GameState.nuova_partita()
	GameState.entra_squarcio("prova_mappa", "res://data/vuoti/meridia.json")

	# stato di partenza: si e' visto solo il varco, e da li' si intravede la
	# periferia. Tutto il resto della citta' non esiste ancora
	GameState.nodi_visitati = ["varco"] as Array[String]
	GameState.nodo_corrente = "varco"

	var mappa: Control = load("res://scenes/MappaZona.tscn").instantiate()
	add_child(mappa)
	mappa.cornice.size = Vector2(900, 700)
	mappa.ricostruisci()

	var quadratini: Dictionary = {}
	for figlio in mappa.strato_bottoni.get_children():
		quadratini[figlio.tooltip_text] = figlio

	esigi(quadratini.has("Il varco"), "il varco, dove sei, non e' sulla mappa")
	esigi(quadratini.has("Strade di periferia"),
			"la periferia confina col varco: doveva comparire come '?'")
	esigi(not quadratini.has("Quartieri profondi"),
			"i quartieri profondi non confinano con niente di noto: non dovevano comparire")
	esigi(String(quadratini["Il varco"].text) == "",
			"il varco e' stato visitato: non deve mostrare un punto di domanda")
	esigi(String(quadratini["Strade di periferia"].text) == "?",
			"un posto intravisto deve mostrare il punto di domanda")

	# un quadratino LONTANO non ci porta: lo dice, e resta dov'e'
	mappa.etichetta_stato.text = " "
	mappa._su_stanza("quartieri_profondi", false, false)
	esigi(GameState.nodo_corrente == "varco",
			"cliccare un posto non raggiungibile ha spostato il giocatore")
	esigi(mappa.etichetta_stato.text != " ",
			"cliccare un posto non raggiungibile non ha detto niente al giocatore")

	# --- DALLA MAPPA NON CI SI TELETRASPORTA ---
	#
	# Vedere un posto e poterci arrivare sono due cose diverse. Una mappa che
	# porta ovunque cancella l'esplorazione senza che nessuno se ne accorga: si
	# continua a giocare, semplicemente il mondo non ha piu' distanze.
	titolo("dalla mappa si va solo dove si arriva a piedi")
	GameState.nodi_visitati = ["varco", "periferia", "ingresso_citta", "complessi",
			"strada_principale", "edicola", "vicolo"] as Array[String]
	for id_stanza in GameState.nodi_visitati:
		GameState.sblocca_stanza(id_stanza)
	GameState.nodo_corrente = "varco"
	esigi(mappa.si_puo_andare("periferia"),
			"dal varco si dovrebbe poter andare alla periferia: confinano")
	esigi(not mappa.si_puo_andare("vicolo"),
			"dal varco si arriva al vicolo in un click: la mappa e' un teletrasporto")
	esigi(mappa.si_puo_andare("varco"), "non si puo' restare dove si e'")

	# NEL BUIO CI SI CAMMINA. Il punto interrogativo accanto a te e' un invito,
	# e un invito che poi rifiuta e' peggio di nessun invito: era il difetto che
	# rendeva la mappa inutilizzabile. Andarci E' il modo di scoprire cosa c'e'
	GameState.flags.clear()
	GameState.nodi_visitati = ["varco"] as Array[String]
	GameState.nodo_corrente = "varco"
	esigi(not GameState.stanza_sbloccata("periferia"),
			"la prova parte con la periferia gia' aperta: non prova niente")
	esigi(mappa.si_puo_andare("periferia"),
			"nella stanza accanto, mai vista, non si puo' andare: la mappa non lascia esplorare")

	# --- I PROIETTORI SONO UNA RETE, NON UN RITORNO ALLA BASE ---
	#
	# Bru: "puoi selezionare i punti dove si trovano i proiettori, ma solo se
	# sei in uno dei punti dove c'e' un altro teletrasporto". Quindi il salto ha
	# due condizioni, e servono tutte e due: uno di qua e uno di la'.
	GameState.nodi_visitati = ["varco", "periferia", "ingresso_citta", "complessi",
			"strada_principale", "edicola", "vicolo"] as Array[String]
	for id_stanza in GameState.nodi_visitati:
		GameState.sblocca_stanza(id_stanza)
	GameState.nodo_corrente = "varco"
	esigi(GameState.proiettori_di_zona().is_empty(),
			"risultano piantati dei proiettori senza averne piantato nessuno")
	GameState.piazza_proiettore("vicolo")
	esigi(not mappa.si_puo_andare("vicolo"),
			"si salta a un proiettore stando in un posto qualunque: e' un ritorno alla base, non una rete")
	# adesso ce n'e' uno anche sotto i piedi: il salto si apre
	GameState.piazza_proiettore("varco")
	esigi(GameState.su_un_proiettore(), "il proiettore sotto i piedi non risulta")
	esigi(mappa.si_puo_andare("vicolo"),
			"da un proiettore a un altro non si salta: il proiettore non serve a niente")
	# e sono piu' d'uno: piantarne un altro non cancella i primi
	GameState.piazza_proiettore("edicola")
	esigi(mappa.si_puo_andare("vicolo") and mappa.si_puo_andare("edicola"),
			"piantare un proiettore nuovo ha spento quelli di prima")
	esigi(GameState.proiettori_di_zona().size() == 3,
			"i proiettori piantati sono %d invece di 3" % GameState.proiettori_di_zona().size())
	# a un proiettore mai visto non si salta: si salta dove si e' gia' stati
	GameState.piazza_proiettore("quartieri_profondi")
	esigi(not mappa.si_puo_andare("quartieri_profondi"),
			"si salta a un proiettore in un posto dove non si e' mai messo piede")
	# e vale per la zona in cui l'hai piantato, non per tutte
	GameState.entra_squarcio("prova_mappa_altrove", "res://data/vuoti/meridia.json")
	esigi(GameState.proiettori_di_zona().is_empty(),
			"i proiettori piantati in una zona risultano piantati anche in un'altra")

	# una stanza grande occupa davvero piu' di un quadratino
	GameState.entra_squarcio("prova_mappa2", "res://data/vuoti/casa_gigante.json")
	GameState.nodi_visitati = ["soglia", "salone"] as Array[String]
	GameState.nodo_corrente = "salone"
	mappa.queue_free()
	mappa = load("res://scenes/MappaZona.tscn").instantiate()
	add_child(mappa)
	mappa.cornice.size = Vector2(900, 700)
	mappa.ricostruisci()
	var salone: Dictionary = {}
	var soglia: Dictionary = {}
	for stanza in GameState.mappa_zona.get("stanze", []):
		if String(stanza.get("id", "")) == "salone":
			salone = stanza
		elif String(stanza.get("id", "")) == "soglia":
			soglia = stanza
	esigi(not salone.is_empty() and not soglia.is_empty(), "salone o soglia non sono sulla mappa")
	var rettangolo_salone: Rect2 = mappa.rettangolo_di(salone)
	var rettangolo_soglia: Rect2 = mappa.rettangolo_di(soglia)
	esigi(rettangolo_salone.size.y > rettangolo_soglia.size.y * 1.5,
			"il salone e' alto due quadratini nei dati, ma a schermo e' come gli altri")
	esigi(not rettangolo_salone.intersects(rettangolo_soglia),
			"il salone grande finisce sopra la soglia")
	mappa.queue_free()

const CARTELLA_ILLUSTRAZIONI := "res://art/illustrazioni/"

func illustrazioni_chieste() -> Array:
	# tutti i file che un messaggio "immagine" chiede, in tutti i file di eventi
	var trovate: Array = []
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		for id_nodo in dati.get("nodi", {}):
			for msg in dati["nodi"][id_nodo].get("sequenza", []):
				if msg is Dictionary and String(msg.get("tipo", "")) == "immagine":
					var file_chiesto := String(msg.get("file", ""))
					if file_chiesto != "" and file_chiesto not in trovate:
						trovate.append(file_chiesto)
	return trovate

func prova_illustrazioni() -> void:
	# UN'ILLUSTRAZIONE COL PERCORSO SBAGLIATO NON SI VEDE, E NON LO DICE NESSUNO.
	#
	# Il messaggio "immagine" e' fatto apposta per non rompersi: se il disegno
	# non c'e' ancora resta la didascalia e la scena si legge lo stesso. E'
	# giusto - i disegni si fanno a poco a poco - ma vuol dire anche che un
	# percorso scritto storto si comporta ESATTAMENTE come un disegno non ancora
	# fatto. Il giorno che il file arriva, non compare, e nessuno sa perche'.
	#
	# Quindi: la didascalia e' obbligatoria (e' quello che resta), il percorso e'
	# obbligatorio e deve stare dove il gioco lo cerchera'. E al contrario, un
	# file messo in art/illustrazioni/ che nessuna scena chiama e' un nome storto
	# dall'altro lato.
	titolo("le illustrazioni delle scene")
	var chieste := illustrazioni_chieste()
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		for id_nodo in dati.get("nodi", {}):
			for msg in dati["nodi"][id_nodo].get("sequenza", []):
				if not (msg is Dictionary) or String(msg.get("tipo", "")) != "immagine":
					continue
				var dove := "%s/%s" % [percorso, id_nodo]
				esigi(String(msg.get("testo", "")) != "",
						"%s: illustrazione senza didascalia (se il disegno manca non resta niente)" % dove)
				var file_chiesto := String(msg.get("file", ""))
				esigi(file_chiesto != "", "%s: illustrazione senza campo 'file'" % dove)
				esigi(file_chiesto.begins_with(CARTELLA_ILLUSTRAZIONI),
						"%s: l'illustrazione '%s' non sta in %s"
						% [dove, file_chiesto, CARTELLA_ILLUSTRAZIONI])
				esigi(file_chiesto.get_extension() == "png",
						"%s: l'illustrazione '%s' non e' un .png" % [dove, file_chiesto])

	var cartella := DirAccess.open(CARTELLA_ILLUSTRAZIONI)
	if cartella == null:
		return  # la cartella non c'e' ancora: si disegnera'
	for nome in cartella.get_files():
		if nome.begins_with(".") or nome.ends_with(".md") or nome.ends_with(".import"):
			continue
		esigi(CARTELLA_ILLUSTRAZIONI + nome in chieste,
				"art/illustrazioni/%s non lo chiede nessuna scena: nome sbagliato?" % nome)

func espressioni_usate_nei_dialoghi() -> Array:
	# tutte le espressioni che i file di eventi chiedono davvero, comunque si
	# chiamino: sui messaggi ("espr") e sui lati del palco
	var trovate: Array = []
	var aggiungi := func(valore: Variant) -> void:
		var nome := String(valore)
		if nome != "" and nome not in trovate:
			trovate.append(nome)
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		for id_nodo in dati.get("nodi", {}):
			var nodo: Dictionary = dati["nodi"][id_nodo]
			for chiave in ["espr_sinistra", "espr_destra", "espr_centro"]:
				aggiungi.call(nodo.get(chiave, ""))
			for lato in ["sinistra", "destra", "centro"]:
				var valore: Variant = nodo.get(lato, null)
				if valore is Dictionary:
					aggiungi.call(valore.get("espr", ""))
			for msg in nodo.get("sequenza", []):
				if msg is Dictionary:
					aggiungi.call(msg.get("espr", ""))
	return trovate

func prova_script_compilano() -> void:
	# Ogni .gd deve compilare. Sembra ovvio, e invece e' la prova che mancava:
	# caricare una scena il cui SCRIPT e' rotto riesce lo stesso (la .tscn si
	# legge, il nodo si istanzia, semplicemente resta senza codice), quindi la
	# prova sulle scene non se ne accorgeva. E' successo davvero, scorporando
	# Combattimento.gd: due chiamate rimaste indietro, tutto verde.
	#
	# Non e' la stessa cosa di "godot --check-only --script X": quello compila
	# il file da solo, fuori dal progetto, e grida "GameState non esiste" su
	# ventidue file sanissimi. Qui gli autoload e le classi con class_name ci
	# sono, perche' siamo dentro il gioco.
	#
	# E NON BASTA "load() != null". Era scritta cosi', e non funzionava: Godot
	# restituisce lo stesso una risorsa GDScript per un file che non compila
	# (vuota, ma non nulla), e per giunta la tiene in cache, quindi al secondo
	# giro non riprova nemmeno. Ho aggiunto una riga sbagliata apposta in un file
	# per controllare: tutto verde. Una prova che non sa fallire e' peggio di
	# nessuna prova, perche' ti fa credere di essere coperto.
	#
	# Adesso si chiede allo script se sa fare una sua istanza: e' falso esatta-
	# mente quando il file non ha compilato, ed e' vero per tutti gli altri
	# (anche per le RefCounted con class_name). Provato rompendo un file apposta:
	# prima passava, adesso fallisce.
	#
	# NON si ricarica ignorando la cache: farlo ricompila anche gli autoload e i
	# .gd gia' vivi in memoria mentre il gioco gira, e Godot va in crash. Provato
	# anche quello.
	titolo("ogni script compila")
	for cartella_nome: String in ["res://scripts", "res://scripts/combattimento", "res://prove"]:
		var cartella := DirAccess.open(cartella_nome)
		if cartella == null:
			continue
		for nome in cartella.get_files():
			if not nome.ends_with(".gd"):
				continue
			var percorso := cartella_nome + "/" + nome
			var script := load(percorso) as GDScript
			esigi(script != null and script.can_instantiate(),
					"%s non compila (vedi l'errore qui sopra)" % percorso)

func prova_scene_caricabili() -> void:
	# ogni schermata deve almeno istanziarsi: e' il tipo di rottura che un
	# refactor introduce e che nessuno vede finche' non ci passa sopra
	titolo("tutte le scene si caricano")
	var cartella := DirAccess.open("res://scenes")
	if cartella == null:
		esigi(false, "cartella scenes/ non leggibile")
		return
	for nome in cartella.get_files():
		if not nome.ends_with(".tscn"):
			continue
		var percorso := "res://scenes/" + nome
		var scena: Resource = load(percorso)
		esigi(scena != null, "la scena %s non si carica" % nome)
		if scena is PackedScene:
			var istanza: Node = (scena as PackedScene).instantiate()
			esigi(istanza != null, "la scena %s non si istanzia" % nome)
			if istanza != null:
				istanza.queue_free()

func stampa_esito() -> void:
	print("")
	if fallimenti.is_empty():
		print("PASSATE: %d verifiche, nessun problema." % conteggio)
		get_tree().quit(0)
		return
	print("FALLITE: %d problemi su %d verifiche.\n" % [fallimenti.size(), conteggio])
	for problema in fallimenti:
		print("  ✗ " + problema)
	print("")
	get_tree().quit(1)
