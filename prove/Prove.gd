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
	prova_transizioni()
	prova_suoni()
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
				for chiave in ["oggetto", "richiede_oggetto"]:
					if scelta.has(chiave):
						esigi(GameState.oggetti.has(String(scelta[chiave])),
								"%s/%s: l'oggetto '%s' non esiste" % [percorso, id_nodo, scelta[chiave]])
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
		for stanza in mappa_zona.get("stanze", []):
			var id_stanza := String(stanza.get("id", ""))
			stanze[id_stanza] = true
			esigi(nodi.has(id_stanza),
					"%s: la mappa mostra la stanza '%s', che non e' un nodo" % [percorso, id_stanza])
			esigi(String(stanza.get("nome", "")) != "",
					"%s: la stanza '%s' non ha nome sulla mappa" % [percorso, id_stanza])
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
	esigi(GameState.bonus_equipaggiamento(eroe, "difesa") == 1,
			"l'amuleto di pietra non da' +1 difesa")
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
	esigi(GameState.bonus_equipaggiamento(eroe, "difesa") == 2, "lo stigma del muto non da' +2 difesa")
	esigi(GameState.bonus_equipaggiamento(eroe, "attacco") == -1, "lo stigma del muto non toglie attacco")
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
	titolo("ogni script compila")
	for cartella_nome: String in ["res://scripts", "res://scripts/combattimento", "res://prove"]:
		var cartella := DirAccess.open(cartella_nome)
		if cartella == null:
			continue
		for nome in cartella.get_files():
			if not nome.ends_with(".gd"):
				continue
			var percorso := cartella_nome + "/" + nome
			esigi(load(percorso) != null, "%s non compila (vedi l'errore qui sopra)" % percorso)

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
