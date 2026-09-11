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
	await prova_scontro_vero_si_gioca()
	prova_il_nemico_non_ti_aspetta()
	prova_barra_di_dominio_come_energia()
	await prova_mattanza_svuota_la_barra()
	prova_ogni_creatura_ha_un_set_di_mosse()
	prova_le_creature_capiscono_come_stanno()
	prova_nessuna_creatura_perde_la_battuta()
	prova_le_meccaniche_nuove_delle_mosse()
	prova_hype()
	prova_abilita_di_veronica_e_yhvina()
	prova_i_cinque_tipi()
	prova_il_colpo_si_sente()
	prova_il_fermo_immagine_non_resta_acceso()
	prova_il_tipo_si_vede_sul_colpo()
	prova_resistere_non_e_essere_immuni()
	prova_il_tetto_alla_cura_di_se()
	prova_la_vita_bassa_si_annuncia()
	prova_gli_otto_status()
	prova_mediazione()
	prova_menu_cinque_voci_fisse()
	prova_i_dominatori_non_sono_bestiario()
	prova_modalita_e_trasformazione()
	prova_tecnolog_completo()
	prova_areale_e_la_regione_grande()
	prova_tecnolog_si_riempie_studiando()
	prova_il_drop_c_e_sempre()
	prova_guardia_a_scatti()
	prova_corazza_che_cresce()
	prova_colori_del_danno()
	prova_abilita_di_combattimento()
	await prova_carta_del_titolo_sta_su_una_riga()
	prova_barra_di_dominio_sta_nel_combattimento()
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
		var mediazione: Dictionary = GameState.mediazione_di(String(id_creatura))
		if mediazione.has("oggetto"):
			esigi(GameState.oggetti.has(String(mediazione["oggetto"])),
					"%s: premio della mediazione '%s' non esiste" % [id_creatura, mediazione["oggetto"]])
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
	GameState.porta_al_livello(eroe, 1)
	esigi(GameState.slot_accessori_di(eroe) == base,
			"al livello 1 gli slot dovrebbero essere %d, sono %d" % [base, GameState.slot_accessori_di(eroe)])
	for i in range(soglie.size()):
		GameState.porta_al_livello(eroe, int(soglie[i]))
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
	GameState.porta_al_livello(eroe, 1)
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
	GameState.porta_al_livello(eroe, 40)
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
	# IL LIVELLO NON STA PIU' NEL SALVATAGGIO, ci sta quello da cui esce: i
	# nodi comprati. Un salvataggio del tempo in cui il livello era un numero a
	# se' non puo' portarselo dietro, e va bene cosi' - quello che conta e' che
	# si apra senza perdere Tazo, legame, sacca e flag
	esigi(GameState.livello_di(eroe) >= 1, "il personaggio non esiste piu' aprendo un salvataggio vecchio")
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
		GameState.porta_al_livello(GameState.id_protagonista, livello_eroe)
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

func prova_barra_di_dominio_sta_nel_combattimento() -> void:
	# Bru: "non c'e' bisogno di far vedere le stats, sono consultabili nel
	# diario, inutile metterle nella schermata dei dialoghi. Stessa cosa la
	# barra di dominio: e' una prerogativa del combattimento, non e' che e'
	# sempre li', a ogni combattimento si riazzera".
	#
	# Erano due errori in uno: la barra stava dove non serviva, e li' mostrava
	# la vecchia statistica 'fattore' (che parte da 15) invece di se stessa - a
	# partita nuova risultava gia' carica senza che nessuno avesse fatto niente.
	titolo("la barra di dominio vive nel combattimento, e riparte da zero")
	GameState.nuova_partita()

	# 1. la schermata dei dialoghi non mostra ne' statistiche ne' barra
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	esigi(not schermata.etichetta_stat.visible,
			"la riga delle statistiche e' ancora sulla schermata dei dialoghi")
	esigi(not "barra_dominio" in schermata,
			"la schermata dei dialoghi ha ancora una barra di dominio addosso")
	schermata.free()

	# 2. in combattimento la barra c'e', sulla scheda di chi giochi tu
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.limite_giri = 1
	scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	add_child(scontro)
	var eroe: Dictionary = {}
	var trovata := false
	for combattente in scontro.combattenti:
		if combattente.giocatore:
			if eroe.is_empty():
				eroe = combattente
			if combattente.get("barra_dominio", null) != null:
				trovata = true
	esigi(trovata, "in combattimento la scheda del party non ha la barra di dominio")

	# 3. E RIPARTE DA ZERO. Si carica combattendo, e il combattimento dopo
	#    ricomincia da capo: non e' una risorsa che ci si porta per la mappa
	RegoleCombattimento.riempi_dominio(eroe, "per_uccisione")
	esigi(int(eroe.get("dominio", 0)) > 0, "la barra non si carica combattendo")
	scontro.free()
	var secondo: Node = load("res://scenes/Combattimento.tscn").instantiate()
	secondo.muto = true
	secondo.limite_giri = 1
	secondo.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	add_child(secondo)
	for combattente in secondo.combattenti:
		if combattente.giocatore:
			esigi(int(combattente.get("dominio", 0)) == 0,
					"lo scontro dopo comincia con %d di dominio gia' in cassa: non si riazzera"
					% int(combattente.get("dominio", 0)))
	secondo.free()
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
		GameState.porta_al_livello(GameState.id_protagonista, 40)
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
		# e la barra di dominio piena: gli speciali la spendono, e senza non
		# partono affatto (che e' giusto, ma qui si sta misurando altro)
		eroe.dominio = RegoleCombattimento.dominio_pieno()
		# LO SCONTRO VA RIMESSO IN PIEDI, E IL PROTAGONISTA ANCHE. Con
		# limite_giri = 1 l'orologio virtuale ha gia' chiuso tutto dentro _ready,
		# e i due ghoul possono averlo steso: un'abilita' che - giustamente - non
		# parte da morto o a scontro finito qui non partirebbe affatto, e
		# sembrerebbe rotta. E' successo con la Mattanza, che al contrario delle
		# altre controlla chi la sta dando.
		scontro.in_corso = true
		eroe.hp = eroe.hp_max
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
			"mattanza":
				scontro.usa_abilita_su(eroe, String(id_abilita), nemico)
				esigi(int(nemico.hp) < hp_nemico_prima,
						"%s non ha fatto nessun danno al bersaglio" % id_abilita)
				esigi(int(eroe.get("dominio", 1)) == 0,
						"%s ha lasciato %d nella barra: doveva portarsela via tutta"
						% [id_abilita, int(eroe.get("dominio", 0))])
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
		GameState.porta_al_livello(GameState.id_protagonista, 10)
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
	GameState.porta_al_livello(GameState.id_protagonista, 130)
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
	GameState.porta_al_livello(GameState.id_protagonista, 25)
	# I PUNTI NON ARRIVANO PIU' COL LIVELLO: si comprano con l'hype. Qui se ne
	# mette in tasca esattamente uno, che e' la condizione che questa prova
	# vuole misurare - una porta sola aperta e due strade davanti
	GameState.hype_disponibile = GameState.costo_in_hype(1)
	esigi(GameState.punti_abilita_liberi() == 1,
			"con l'hype di un punto in tasca ne risultano %d" % GameState.punti_abilita_liberi())
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
	GameState.porta_al_livello(GameState.id_protagonista, 29)
	GameState.hype_disponibile = GameState.costo_in_hype(1)
	esigi(GameState.punti_abilita_liberi() == 1, "al livello 29 il secondo punto non si compra")
	esigi(GameState.nodo_disponibile("pieta"), "al 29 Pieta' doveva essere ancora li'")
	esigi(GameState.nodo_disponibile("annichilazione_ii"),
			"al 29 Annichilazione II non e' disponibile")

	# 4. non si salta un grado: Maelstrom vuole Terra bruciata, e il livello
	esigi(not GameState.nodo_disponibile("maelstrom"),
			"al livello 29 si puo' gia' comprare Maelstrom, che apre molto piu' avanti")
	GameState.porta_al_livello(GameState.id_protagonista, 130)
	GameState.hype_disponibile = GameState.costo_in_hype(1)
	esigi(GameState.nodo_disponibile("apocalisse") == false,
			"si puo' comprare Apocalisse saltando i gradi in mezzo")
	esigi(GameState.nodo_disponibile("maelstrom"),
			"col livello alto e Terra bruciata in mano Maelstrom non si apre")

	# 5. mai piu' di quello che hai guadagnato, comprando tutto quello che si puo'
	GameState.hype_disponibile = GameState.costo_in_hype(200)
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
	# IL TETTO ADESSO E' L'HYPE, non i punti che il livello regalava. La regola
	# vera e' una sola: non si compra piu' di quello che si ha in tasca
	esigi(GameState.hype_disponibile >= 0, "l'hype e' andato sotto zero comprando")
	esigi(GameState.punti_abilita_liberi() >= 0, "i punti liberi sono andati sotto zero")
	esigi(GameState.costo_in_hype(GameState.punti_abilita_spesi()) <= GameState.costo_in_hype(200),
			"spesi %d punti con l'hype di 200" % GameState.punti_abilita_spesi())
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
		GameState.porta_al_livello(GameState.id_protagonista, livello - 1)
		esigi(not id_abilita in GameState.abilita_del_protagonista(),
				"al livello %d il protagonista sa gia' fare %s" % [livello - 1, id_abilita])
		GameState.porta_al_livello(GameState.id_protagonista, livello)
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
	GameState.porta_al_livello(GameState.id_protagonista, livello)
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
		GameState.porta_al_livello(GameState.id_protagonista, livello_eroe)
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
	# IL MOMENTO E' CAMBIATO: prima si saliva quando l'esperienza traboccava,
	# adesso si sale comprando - perche' comprare E' salire di livello. Quello
	# che la prova misura pero' e' lo stesso: che il momento venga raccontato
	GameState.hype_disponibile = GameState.costo_in_hype(5)
	var qualcosa_comprato := false
	for id_nodo in GameState.abilita.get("abilita", {}):
		if GameState.nodo_disponibile(String(id_nodo)):
			qualcosa_comprato = GameState.sblocca_nodo(String(id_nodo))
			break
	esigi(qualcosa_comprato, "non si riesce a comprare niente pur avendo hype")
	esigi(GameState.livello_di(GameState.id_protagonista) == 2,
			"comprato un nodo, non si e' saliti di livello")
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

func prova_scontro_vero_si_gioca() -> void:
	# LA PROVA CHE MANCAVA, E CHE E' COSTATA UN COMBATTIMENTO INTERO.
	#
	# Tutte le altre girano in "muto" col giocatore automatico: chiamano le
	# funzioni direttamente e non premono mai un bottone. Quindi non hanno mai
	# visto che, in tempo reale, NESSUNO svuotava la coda dei messaggi e nessuno
	# chiudeva lo scontro - il ciclo a turni faceva tutte e due le cose, e
	# toglierlo le ha portate via. Bru, giocando: "non sto subendo danni ne'
	# riesco ad infliggerli, il primo combattimento blocca tutto".
	#
	# Qui lo scontro si monta come in partita - non muto, senza strategia - e si
	# gioca come si gioca: cliccando sul nemico.
	titolo("uno scontro vero si gioca: si colpisce, si viene colpiti, e finisce")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	var eroe: Dictionary = {}
	var nemico: Dictionary = {}
	for combattente in scontro.combattenti:
		if combattente.giocatore and eroe.is_empty():
			eroe = combattente
		elif not combattente.giocatore and nemico.is_empty():
			nemico = combattente
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro non si e' montato")

	# 0. LA BARRA PARTE VUOTA. Bru: "appare con una piccola porzione piena e non
	#    vuota a inizio scontro" - leggeva il Fattore (base 15) invece del dominio
	esigi(int(eroe.get("dominio", -1)) == 0,
			"lo scontro comincia con %d di dominio in cassa" % int(eroe.get("dominio", -1)))
	var barra = eroe.get("barra_dominio", null)
	esigi(barra != null, "la scheda del protagonista non ha la barra")
	if barra != null:
		esigi(is_zero_approx(float(barra.get_meta("quota", -1.0))),
				"a inizio scontro la barra e' gia' piena per un %d%%"
				% int(float(barra.get_meta("quota", 0.0)) * 100))

	# 1. SUL NEMICO SI CLICCA, e il click e' un colpo. Il bersaglio dev'essere
	#    un Control che sente il mouse: la prima versione ci metteva un Button
	#    dentro un VBoxContainer, dove gli ancoraggi non contano e diventava una
	#    riga alta zero - c'era, e non si poteva cliccare
	esigi(nemico.get("bersaglio_cliccabile", null) != null,
			"il nemico non ha niente da cliccare: il colpo normale non si puo' dare")
	var da_cliccare = nemico.get("bersaglio_cliccabile", null)
	if da_cliccare != null:
		esigi(da_cliccare.mouse_filter == Control.MOUSE_FILTER_STOP,
				"la scheda del nemico non ferma il mouse: il click le passa attraverso")
		esigi(da_cliccare.size.x > 8.0 and da_cliccare.size.y > 8.0,
				"l'area cliccabile del nemico e' %dx%d pixel: non ci si becca"
				% [int(da_cliccare.size.x), int(da_cliccare.size.y)])
	esigi(eroe.get("bersaglio_cliccabile", null) == null,
			"anche il protagonista e' cliccabile come bersaglio")
	var vita_nemico := int(nemico.hp)
	eroe.ricarica = 0.0          # la ricarica e' pronta, come dopo qualche istante
	scontro._su_click_nemico(nemico)
	esigi(int(nemico.hp) < vita_nemico,
			"cliccando sul nemico non gli e' successo niente: il colpo normale non arriva")

	# 2. e non si martella a vuoto: finche' ricarichi, il click non conta
	var dopo_il_colpo := int(nemico.hp)
	scontro._su_click_nemico(nemico)
	scontro._su_click_nemico(nemico)
	esigi(int(nemico.hp) == dopo_il_colpo,
			"cliccando durante la ricarica si colpisce lo stesso: la ricarica non serve a niente")

	# 2-bis. LA BARRA SI RIEMPIE COLPENDO E INCASSANDO
	esigi(int(eroe.get("dominio", 0)) > 0,
			"dopo aver colpito la barra di dominio e' ancora a zero")
	var dominio_prima := int(eroe.get("dominio", 0))
	scontro.attacca(nemico, eroe)
	esigi(int(eroe.get("dominio", 0)) > dominio_prima,
			"incassando un colpo la barra non si e' mossa: restare in mezzo non paga niente")

	# 2-ter. OGNI CREATURA HA LA SUA RAPIDITA': i ruoli si devono sentire
	var ricarica_eroe: float = scontro.ricarica_di(eroe)
	var lento_finto := {"velocita": maxi(int(eroe.velocita) / 2, 1), "stati_attivi": {}}
	var svelto_finto := {"velocita": int(eroe.velocita) * 2, "stati_attivi": {}}
	esigi(scontro.ricarica_di(svelto_finto) < ricarica_eroe,
			"chi e' il doppio piu' veloce di te ricarica in %.2fs contro i tuoi %.2fs: la velocita' non si sente"
			% [scontro.ricarica_di(svelto_finto), ricarica_eroe])
	esigi(scontro.ricarica_di(lento_finto) > ricarica_eroe,
			"chi e' la meta' piu' lento di te ricarica in %.2fs contro i tuoi %.2fs: la velocita' non si sente"
			% [scontro.ricarica_di(lento_finto), ricarica_eroe])

	# 3. IL MONDO VA AVANTI DA SOLO: si lascia scorrere il tempo senza toccare
	#    niente e il protagonista deve incassare
	var vita_eroe := int(eroe.hp)
	for battito in 300:
		scontro.avanza_orologio(0.1)
		if int(eroe.hp) < vita_eroe:
			break
	esigi(int(eroe.hp) < vita_eroe,
			"trenta secondi senza fare niente e il protagonista e' intatto: i nemici non si muovono")

	# 4. E FINISCE. Si abbatte il nemico e lo scontro deve chiudersi
	nemico.hp = 1
	eroe.ricarica = 0.0
	scontro._su_click_nemico(nemico)
	esigi(int(nemico.hp) <= 0, "il colpo di grazia non ha abbattuto il nemico")
	esigi(not scontro.in_corso,
			"abbattuto l'ultimo nemico lo scontro e' ancora in corso: non finisce piu'")
	esigi(scontro.giocatore_ha_vinto, "lo scontro e' finito senza registrare la vittoria")

	# 5. E LE PAROLE ARRIVANO A SCHERMO. Non si pretende che la coda sia gia'
	#    vuota - ogni messaggio ha il suo tempo di lettura, e sono secondi - si
	#    pretende che CALI: che ci sia qualcuno che la consuma. Era esattamente
	#    quello che mancava, e nessuna prova poteva vederlo perche' giravano
	#    tutte in muto, dove non c'e' niente da leggere
	var in_coda_prima: int = scontro.voce.coda.size()
	esigi(in_coda_prima > 0, "lo scontro non ha prodotto un solo messaggio da leggere")
	var girati := 0
	while scontro.voce.coda.size() >= in_coda_prima and girati < 2000:
		await get_tree().process_frame
		girati += 1
	esigi(scontro.voce.coda.size() < in_coda_prima,
			"la coda dei messaggi non cala mai (%d ferma li'): non la svuota nessuno, e a schermo non arriva niente"
			% in_coda_prima)
	scontro.free()
	GameState.nuova_partita()

func prova_il_nemico_non_ti_aspetta() -> void:
	# LA PROVA DEL CAMBIO D'IMPIANTO. Bru: "eliminiamo i turni, i nemici non
	# aspetteranno che tu scelga la tua mossa, continueranno ad attaccare".
	#
	# E' l'unica cosa che distingue davvero il gioco nuovo dal vecchio, e si
	# misura in un modo solo: si sta fermi e si guarda se si viene colpiti. Un
	# motore che sembra in tempo reale ma aspetta comunque il giocatore passa
	# tutte le altre prove del mondo.
	titolo("i nemici non aspettano che tu scelga")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["ghoul"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	# una battuta sola, se no l'orologio virtuale gioca tutto lo scontro qui
	# dentro e quando si torna non c'e' piu' niente da guardare (e' successo:
	# la prima versione misurava un protagonista gia' morto e concludeva che il
	# nemico non lo aveva toccato)
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
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro di prova non si e' montato")

	# LO SCONTRO E' FINITO DA SOLO, e questo e' gia' un risultato: con la prima
	# versione del motore l'orologio virtuale girava a vuoto per sempre, perche'
	# le battute del protagonista si contavano solo se le comandava una persona
	esigi(not scontro.in_corso,
			"con limite_giri = 1 lo scontro non si e' chiuso: la fine non scatta piu'")
	esigi(scontro.battute_del_giocatore >= 1,
			"il protagonista ha mosso %d volte: il contatore delle battute non sale"
			% scontro.battute_del_giocatore)

	# si riapre lo scontro: da qui in poi il giocatore non fa NIENTE
	scontro.in_corso = true
	scontro.limite_giri = 0
	scontro.strategia = Callable()
	scontro.id_comandato = GameState.id_protagonista
	for combattente in scontro.combattenti:
		combattente.hp = int(combattente.hp_max)
		combattente.ricarica = scontro.ricarica_di(combattente)

	# la ricarica e' una ricarica: piu' sei veloce, meno aspetti
	var lento := {"velocita": 2, "stati_attivi": {}}
	var svelto := {"velocita": 20, "stati_attivi": {}}
	esigi(scontro.ricarica_di(svelto) < scontro.ricarica_di(lento),
			"chi e' piu' veloce non ricarica prima: la velocita' non conta piu' niente")
	esigi(scontro.ricarica_di(lento) > 0.0, "la ricarica e' zero: tutti agirebbero a ogni fotogramma")

	# IL TEMPO SI FERMA solo quando il gioco ha qualcosa da dirti. Si controlla
	# adesso, a scontro vivo: piu' avanti il protagonista sara' caduto (sta
	# fermo mentre lo picchiano) e a scontro chiuso il tempo e' fermo per un
	# altro motivo - la prima versione di questa prova ci si e' fatta ingannare
	esigi(scontro.il_tempo_scorre(), "il tempo e' gia' fermo senza nessuna ragione")
	scontro.ferma_il_tempo()
	esigi(not scontro.il_tempo_scorre(), "fermare il tempo non lo ferma")
	var vita_ferma := int(eroe.hp)
	for battito in 100:
		scontro.avanza_orologio(0.1)
	esigi(int(eroe.hp) == vita_ferma,
			"col tempo fermo il protagonista ha perso vita: gli script dei boss e lo studio non proteggono niente")
	scontro.riprendi_il_tempo()
	esigi(scontro.il_tempo_scorre(), "il tempo non riparte")
	# e si annida: due cose che fermano il tempo insieme non si scavalcano
	scontro.ferma_il_tempo()
	scontro.ferma_il_tempo()
	scontro.riprendi_il_tempo()
	esigi(not scontro.il_tempo_scorre(),
			"una sola ripresa ha fatto ripartire il tempo che era stato fermato due volte")
	scontro.riprendi_il_tempo()
	esigi(scontro.il_tempo_scorre(), "dopo due riprese il tempo e' ancora fermo")

	# E ADESSO LA COSA CHE CONTA: si sta fermi e si guarda se il mondo va avanti
	var vita_prima := int(eroe.hp)
	for battito in 200:
		scontro.avanza_orologio(0.1)
	esigi(int(eroe.hp) < vita_prima,
			"venti secondi di immobilita' e il protagonista ha ancora %d vita su %d: il nemico sta aspettando il tuo turno"
			% [int(eroe.hp), vita_prima])
	scontro.free()
	GameState.nuova_partita()

func prova_barra_di_dominio_come_energia() -> void:
	# Bru: "useremo la barra di dominio come una barra di energia che si riempie
	# man mano che attacchi, fai critici, uccidi nemici, vieni colpito... ha 3
	# livelli di barra, verde, blu e rossa... puoi usare barra per usare attacchi
	# speciali che consumeranno tot barra".
	#
	# Quindi non e' piu' un contatore che guardi: e' una risorsa che entra ed
	# esce. Se entrasse e basta non sarebbe una risorsa, e se uscisse senza
	# entrare nessuno la userebbe: qui si controllano tutti e due i versi.
	titolo("la barra di dominio si riempie combattendo e si spende sugli speciali")
	GameState.nuova_partita()
	var pieno := RegoleCombattimento.dominio_pieno()
	var segmenti := int(GameState.regole.get("dominio", {}).get("segmenti", 0))
	esigi(segmenti == 3, "i segmenti della barra sono %d invece di 3" % segmenti)
	esigi(pieno > 0, "la barra piena vale zero")
	var eroe := {"id": GameState.id_protagonista, "giocatore": true, "dominio": 0}

	# 1. si riempie, e ogni cosa che fai vale qualcosa
	for motivo in ["per_attacco", "per_critico", "per_uccisione", "per_colpo_subito"]:
		eroe.dominio = 0
		var entrato := RegoleCombattimento.riempi_dominio(eroe, motivo)
		esigi(entrato > 0, "'%s' non carica niente nella barra" % motivo)
		esigi(int(eroe.dominio) == entrato, "la barra non ha registrato quello che e' entrato")
	# e non sfonda
	eroe.dominio = 0
	for volta in 200:
		RegoleCombattimento.riempi_dominio(eroe, "per_uccisione")
	esigi(int(eroe.dominio) == pieno, "la barra ha sfondato: %d su %d" % [int(eroe.dominio), pieno])

	# 2. i tre colori sono tre soglie vere, non un'etichetta
	var per_segmento := int(GameState.regole.get("dominio", {}).get("per_segmento", 100))
	var visti: Array[String] = []
	for quanti in [0, 1, 2, 3]:
		eroe.dominio = quanti * per_segmento
		esigi(RegoleCombattimento.segmenti_pieni(eroe) == quanti,
				"con %d di barra risultano %d segmenti invece di %d"
				% [int(eroe.dominio), RegoleCombattimento.segmenti_pieni(eroe), quanti])
		var colore := RegoleCombattimento.colore_dominio(eroe)
		if quanti > 0:
			esigi(colore != "", "col segmento %d la barra non ha colore" % quanti)
			esigi(colore not in visti, "il segmento %d ha lo stesso colore di uno prima" % quanti)
			visti.append(colore)
	esigi(visti == ["verde", "blu", "rossa"],
			"i colori della barra sono %s invece di verde/blu/rossa" % str(visti))

	# 3. si spende, e quello che non si puo' pagare non parte
	eroe.dominio = pieno
	esigi(RegoleCombattimento.puo_spendere_dominio(eroe, 1.0), "a barra piena non si paga un segmento")
	esigi(RegoleCombattimento.spendi_dominio(eroe, 1.0), "spendere un segmento non e' riuscito")
	esigi(int(eroe.dominio) < pieno, "spendere non ha tolto niente dalla barra")
	eroe.dominio = 0
	esigi(not RegoleCombattimento.puo_spendere_dominio(eroe, 1.0),
			"a barra vuota si paga lo stesso: la barra non e' una risorsa")
	esigi(not RegoleCombattimento.spendi_dominio(eroe, 1.0), "si e' speso quello che non c'era")

	# 4. LA MAESTRIA CONTA, in tutti e due i versi, e non arriva mai a gratis
	var senza_maestria := RegoleCombattimento.costo_in_dominio(eroe, 1.0)
	GameState.punti_stat["maestria_dominio"] = int(GameState.regole.get("maestria_massima", 100))
	var con_maestria := RegoleCombattimento.costo_in_dominio(eroe, 1.0)
	esigi(con_maestria < senza_maestria,
			"con cento punti di maestria uno speciale costa uguale (%d)" % con_maestria)
	# e non arriva mai a gratis: al massimo della maestria uno speciale deve
	# costare ancora piu' di meta' barra, altrimenti la barra smette di essere
	# una risorsa e diventa un contatore da guardare
	esigi(con_maestria >= senza_maestria / 2,
			"al massimo della maestria uno speciale costa %d invece di %d: quasi gratis"
			% [con_maestria, senza_maestria])
	eroe.dominio = 0
	var carica_alta := RegoleCombattimento.riempi_dominio(eroe, "per_attacco")
	GameState.punti_stat["maestria_dominio"] = 0
	eroe.dominio = 0
	var carica_bassa := RegoleCombattimento.riempi_dominio(eroe, "per_attacco")
	esigi(carica_alta > carica_bassa,
			"la maestria non fa riempire la barra piu' in fretta (%d contro %d)"
			% [carica_alta, carica_bassa])
	esigi(GameState.stat_di("maestria_dominio") <= int(GameState.regole.get("maestria_massima", 100)),
			"la maestria puo' andare oltre il suo tetto")

	# 5. i due attacchi che Bru ha chiesto dall'inizio, e quanto costano
	var spezza: Dictionary = GameState.abilita_combattimento("spezza_spazio")
	esigi(not spezza.is_empty(), "Spezza spazio non esiste")
	esigi(absf(float(spezza.get("dominio", 0.0)) - 1.0) < 0.001,
			"Spezza spazio costa %.1f barre invece di una" % float(spezza.get("dominio", 0.0)))
	var mattanza: Dictionary = GameState.abilita_combattimento("mattanza")
	esigi(not mattanza.is_empty(), "Mattanza non esiste")
	esigi(bool(mattanza.get("consuma_tutto", false)),
			"la Mattanza ha un prezzo invece di un serbatoio: deve portarsi via TUTTA la barra")
	esigi(float(mattanza.get("dominio_minimo", 0.0)) >= 1.0,
			"la Mattanza si puo' chiamare con %.1f segmenti: serve almeno una barra PIENA"
			% float(mattanza.get("dominio_minimo", 0.0)))
	esigi(int(spezza.get("livello", 99)) <= 1 and int(mattanza.get("livello", 99)) <= 1,
			"Spezza spazio e Mattanza non ci sono dall'inizio")
	GameState.nuova_partita()

func prova_mattanza_svuota_la_barra() -> void:
	# LA MATTANZA, COME L'HA CHIESTA BRU: "quando riempi almeno una barra, puoi
	# andare in mattanza, solo in quel momento; la mattanza consuma tutta la
	# barra e finche' non e' consumata potrai premere spazio per colpire numerose
	# volte il nemico, con un valore di ogni colpo pari a 1/10 del tuo attacco
	# attuale".
	#
	# Sono quattro promesse, e ognuna puo' rompersi da sola senza che si veda:
	# la soglia (mezza barra non apre niente), il serbatoio (se ne va TUTTO), la
	# durata (piu' barra, piu' colpi) e il valore del colpo. La quinta - che
	# spazio colpisca davvero - non si vede da nessuna parte se non premendolo,
	# ed e' quella che in partita si nota per prima.
	titolo("la Mattanza si apre a barra piena, si porta via tutto, e la batti tu")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
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
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro di prova non si e' montato")
	var dati := GameState.abilita_combattimento("mattanza")
	var per_segmento := maxi(int(GameState.regole.get("dominio", {}).get("per_segmento", 100)), 1)
	nemico.hp_max = 1000000
	nemico.hp = 1000000   # un sacco da boxe: qui si conta, non si vince
	# e lo scontro va rimesso in piedi: con limite_giri = 1 l'orologio virtuale
	# l'ha gia' chiuso dentro _ready, e la Mattanza - giustamente - non martella
	# un combattimento finito
	scontro.in_corso = true

	# 1. MEZZA BARRA NON APRE NIENTE. E' la promessa piu' facile da perdere:
	#    basta scrivere il costo come tutti gli altri e la Mattanza diventa
	#    un'abilita' che si chiama quando capita
	eroe.dominio = per_segmento / 2
	esigi(not bool(scontro.dominio_sufficiente(eroe, dati)),
			"il menu accenderebbe la Mattanza con mezza barra")
	var vita := int(nemico.hp)
	scontro.usa_abilita_su(eroe, "mattanza", nemico)
	esigi(int(nemico.hp) == vita, "con mezza barra la Mattanza e' partita lo stesso")
	esigi(int(eroe.dominio) == per_segmento / 2,
			"una Mattanza che non e' partita ha svuotato la barra lo stesso")

	# 2. UNA BARRA PIENA LA APRE, E SE LA PORTA VIA TUTTA
	eroe.dominio = per_segmento
	esigi(bool(scontro.dominio_sufficiente(eroe, dati)),
			"con una barra piena il menu tiene ancora spenta la Mattanza")
	vita = int(nemico.hp)
	scontro.usa_abilita_su(eroe, "mattanza", nemico)
	var danno_una_barra := vita - int(nemico.hp)
	var colpi_una_barra: int = scontro.mattanza_colpi
	esigi(danno_una_barra > 0, "la Mattanza non ha fatto un solo punto di danno")
	esigi(int(eroe.dominio) == 0,
			"la Mattanza ha lasciato %d nella barra: doveva portarsela via tutta" % int(eroe.dominio))
	esigi(colpi_una_barra > 1,
			"la Mattanza ha dato %d colpo: doveva essere una raffica" % colpi_una_barra)

	# 3. OGNI COLPO VALE UN DECIMO DEL TUO ATTACCO, e va diritto: se passasse
	#    dalla difesa, contro un corazzato non farebbe niente - ed e' proprio
	#    contro i corazzati che uno se la tiene da parte
	var atteso := maxi(int(round(RegoleCombattimento.attacco_di(eroe)
			* float(dati.get("frazione_attacco", 0.1)))), 1)
	esigi(danno_una_barra == colpi_una_barra * atteso,
			"%d colpi hanno fatto %d danni invece di %d: un colpo non vale un decimo dell'attacco"
			% [colpi_una_barra, danno_una_barra, colpi_una_barra * atteso])
	# e la corazza non deve contare NIENTE, non "poco": chiedere solo che passi
	# qualcosa non prova un bel niente, perche' un colpo normale contro un
	# corazzato passa lo stesso - c'e' un minimo di legge (danno_minimo_percentuale)
	# che gli lascia sempre briciole. Si pretende lo stesso identico numero
	nemico.difesa = int(eroe.attacco) * 10   # una corazza assurda
	eroe.dominio = per_segmento
	vita = int(nemico.hp)
	scontro.usa_abilita_su(eroe, "mattanza", nemico)
	var danno_corazzato := vita - int(nemico.hp)
	var colpi_corazzato: int = scontro.mattanza_colpi
	esigi(danno_corazzato == colpi_corazzato * atteso,
			"contro un corazzato %d colpi fanno %d invece di %d: la Mattanza passa dalla difesa, e proprio contro i corazzati uno se la tiene da parte"
			% [colpi_corazzato, danno_corazzato, colpi_corazzato * atteso])
	nemico.difesa = 0

	# 4. PIU' BARRA, PIU' COLPI: e' quello che rende una scelta il tenersela
	eroe.dominio = per_segmento * 3
	vita = int(nemico.hp)
	scontro.usa_abilita_su(eroe, "mattanza", nemico)
	var colpi_tre_barre: int = scontro.mattanza_colpi
	esigi(colpi_tre_barre > colpi_una_barra,
			"tre barre danno %d colpi come una (%d): tenersi la barra non compra niente"
			% [colpi_tre_barre, colpi_una_barra])
	# e la barra dev'essere vuota anche partendo da tre. Guardarla dopo UNA sola
	# non prova niente: un costo fisso da un segmento la svuoterebbe uguale, e la
	# prova direbbe di si' a una Mattanza che si porta via solo la sua parte
	esigi(int(eroe.dominio) == 0,
			"partita con tre barre, la Mattanza ne ha lasciate %d: non si porta via tutto"
			% int(eroe.dominio))
	scontro.free()

	# 5. E SPAZIO COLPISCE DAVVERO. Tutto quello che sta sopra girerebbe uguale
	#    anche se la barra spaziatrice non fosse collegata a niente - e sarebbe
	#    la prima cosa che si nota giocando, e l'unica che nessuna prova muta
	#    puo' vedere
	GameState.nemici_combattimento = ["goblin_tipico"]
	var vero: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(vero)
	await get_tree().process_frame
	var tu: Dictionary = {}
	var lui: Dictionary = {}
	for combattente in vero.combattenti:
		if combattente.giocatore and tu.is_empty():
			tu = combattente
		elif not combattente.giocatore and lui.is_empty():
			lui = combattente
	esigi(not tu.is_empty() and not lui.is_empty(), "lo scontro vero non si e' montato")
	lui.hp_max = 1000000
	lui.hp = 1000000
	tu.dominio = per_segmento
	vero.usa_abilita_su(tu, "mattanza", lui)
	esigi(bool(vero.mattanza_attiva),
			"chiamata la Mattanza in tempo reale, la finestra non si e' aperta")
	var spazio := InputEventKey.new()
	spazio.keycode = KEY_SPACE
	spazio.physical_keycode = KEY_SPACE
	spazio.pressed = true
	var prima_di_battere := int(lui.hp)
	vero._unhandled_input(spazio)
	esigi(int(lui.hp) < prima_di_battere, "spazio non colpisce: la Mattanza e' una finestra vuota")
	var dopo_un_colpo := int(lui.hp)
	vero._unhandled_input(spazio)
	esigi(int(lui.hp) < dopo_un_colpo, "il secondo spazio non conta: si batte una volta sola")
	# e la barra che si scarica E' il cronometro: quando e' vuota, finisce
	esigi(int(tu.dominio) > 0, "la barra e' gia' vuota a raffica appena cominciata")
	for battito in 400:
		vero.avanza_mattanza(0.05)
		if not vero.mattanza_attiva:
			break
	esigi(not bool(vero.mattanza_attiva),
			"la Mattanza non finisce piu': la barra non si scarica")
	esigi(int(tu.dominio) == 0, "finita la Mattanza restano %d di barra" % int(tu.dominio))
	var a_raffica_finita := int(lui.hp)
	vero._unhandled_input(spazio)
	esigi(int(lui.hp) == a_raffica_finita,
			"si continua a colpire con spazio anche a barra finita: la finestra non si chiude")
	vero.free()
	GameState.nuova_partita()

func prova_ogni_creatura_ha_un_set_di_mosse() -> void:
	# Bru: "dobbiamo dare un set di attacchi a ogni nemico che o fanno danno o
	# fanno cose". Una creatura senza mosse non e' un nemico facile: e' un
	# nemico che non esiste - tira il suo colpo normale finche' uno dei due
	# cade, e lo scontro non ha niente da raccontare. Erano trenta su
	# trentanove, e nessuna prova poteva accorgersene perche' il motore
	# funzionava benissimo: era il bestiario a essere vuoto.
	titolo("ogni creatura che combatte ha un set di mosse, e le mosse sono eseguibili")
	var tipi_noti := ["difendi", "attacco_forte", "spezza_guardia", "meta_vita",
			"attacco_multiplo", "buff_attacco", "incendia", "attacco_tutti",
			"autolesione", "buff_difesa", "buff_fattore", "evoca", "sacrificio",
			"cura", "rubavita", "stato", "potenziamento", "scena", "tormento",
			"modalita", "trasformazione"]
	# gli scriptati non hanno mosse per scelta: il loro turno lo detta un copione.
	# Le sei caselle ce le hanno lo stesso, tutte libere
	var senza_mosse_per_scelta := ["manifestazione_di_un_sogno", "veronica"]
	var caselle_per_creatura := 6
	var chiavi_condizione := ["vita_sotto", "vita_sopra", "alleati_almeno",
			"alleati_al_massimo", "battuta_almeno", "senza_stato", "bersaglio_vita_sotto",
			"dopo_rinascita", "dopo_mossa"]
	var contate := 0
	var con_cura := 0
	for id_creatura in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_creatura]
		if not dati.has("ruolo") or String(dati.get("ruolo", "")) == "oggetto_scena":
			continue
		contate += 1
		var mosse: Array = dati.get("mosse", [])
		# SEI CASELLE PER TUTTI, anche a chi ne servono tre: Bru le tiene per
		# decidere alla fine quante mosse dare a ognuno, e vederle vuote nel file
		# e' il punto. Le libere non sono mosse deboli: sono posti liberi
		esigi(mosse.size() == caselle_per_creatura,
				"%s ha %d caselle invece di %d: l'elenco non si legge piu' a colpo d'occhio"
				% [id_creatura, mosse.size(), caselle_per_creatura])
		var piene := 0
		for mossa in mosse:
			if String(mossa.get("tipo", "")) != "-":
				piene += 1
		if String(id_creatura) in senza_mosse_per_scelta:
			esigi(piene == 0,
					"%s ha %d mosse: il suo turno lo detta un copione, non deve averne" % [id_creatura, piene])
			continue
		esigi(piene >= 1,
				"%s ha sei caselle e sono tutte libere: in campo tira il suo colpo e basta" % id_creatura)
		var viste: Array[String] = []
		for mossa in mosse:
			if String(mossa.get("tipo", "")) == "-":
				# una casella libera dev'essere libera DAVVERO: se le restasse
				# addosso mezzo campo di quando era piena, prima o poi qualcuno
				# lo legge
				esigi(String(mossa.get("nome", "")) == "-" and String(mossa.get("testo", "")) == "-",
						"%s: una casella libera porta ancora qualcosa scritto" % id_creatura)
				esigi(mossa.size() <= 4,
						"%s: una casella libera ha %d campi addosso" % [id_creatura, mossa.size()])
				continue
			var etichetta := "%s / %s" % [id_creatura, String(mossa.get("id", "?"))]
			esigi(String(mossa.get("id", "")) != "",
					"%s: una mossa senza id - ricariche e una_tantum si perdono per strada"
					% id_creatura)
			esigi(String(mossa.get("nome", "")) != "",
					"%s: la mossa non ha un nome, e il documento dei nemici non puo' chiamarla" % etichetta)
			esigi(String(mossa.get("id", "")) not in viste,
					"%s: due mosse con lo stesso id, e la ricarica dell'una spegne l'altra" % etichetta)
			viste.append(String(mossa.get("id", "")))
			esigi(String(mossa.get("tipo", "")) in tipi_noti,
					"%s e' di tipo '%s', che il combattimento non sa eseguire" % [etichetta, String(mossa.get("tipo", ""))])
			esigi(String(mossa.get("testo", "")) != "",
					"%s non ha un testo: in campo succede qualcosa e nessuno dice cosa" % etichetta)
			if mossa.has("stato"):
				esigi(GameState.stati.has(String(mossa["stato"])),
						"%s lascia addosso '%s', che non esiste in stati.json" % [etichetta, String(mossa["stato"])])
			if String(mossa.get("tipo", "")) == "cura":
				con_cura += 1
				esigi(float(mossa.get("quota_vita", 0.0)) > 0.0,
						"%s e' una cura che non cura niente" % etichetta)
				# UNA CURA SENZA RICARICA NON RENDE LO SCONTRO DIFFICILE: LO RENDE
				# INFINITO. Con la priorita' alta e' la scelta migliore anche il
				# giro dopo, e quello dopo ancora. "una_tantum" va bene uguale, ed
				# e' anzi piu' forte di una ricarica: si fa una volta e mai piu'
				esigi(int(mossa.get("ricarica", 0)) > 0 or mossa.get("una_tantum", false),
						"%s si puo' rifare ogni battuta: lo scontro non finisce piu'" % etichetta)
			if int(mossa.get("priorita", 0)) > 0:
				esigi(not Dictionary(mossa.get("quando", {})).is_empty(),
						"%s ha priorita' ma nessuna condizione: la sceglierebbe sempre, e sarebbe l'unica mossa che fa"
						% etichetta)
			for chiave in Dictionary(mossa.get("quando", {})):
				esigi(String(chiave) in chiavi_condizione,
						"%s guarda '%s', che il motore non sa guardare: la condizione sarebbe sempre vera"
						% [etichetta, String(chiave)])
			if mossa.has("valore") and String(mossa.get("tipo", "")) in ["attacco_forte",
					"attacco_multiplo", "attacco_tutti", "spezza_guardia", "rubavita"]:
				# un numero scritto a mano non sale col livello della creatura:
				# al livello 20 fa il danno che faceva al 4. Si puo' fare, ma
				# dev'essere dichiarato, come per le stat fuori curva
				esigi(mossa.has("fuori_curva"),
						"%s picchia con un numero fisso (%d) invece di una quota del suo attacco: al doppio del livello farebbe lo stesso danno. Se e' voluto, scrivi perche' in 'fuori_curva'"
						% [etichetta, int(mossa["valore"])])
	esigi(contate >= 30, "la prova ha guardato solo %d creature: il filtro si e' stretto" % contate)
	esigi(con_cura >= 5,
			"nel bestiario ci sono %d creature che sanno rimettersi in piedi: Bru ne voleva abbastanza da farlo notare"
			% con_cura)

func prova_le_creature_capiscono_come_stanno() -> void:
	# Bru: "quando i nemici sono a fin di vita diventano piu' ostici, devono
	# capire la loro condizione e usare le mosse a loro disposizione saggiamente,
	# per esempio se hanno pochi punti vita devono capirlo e se hanno attacchi
	# che li curano o abilita' le attivano".
	#
	# Sono due cose diverse e vanno provate separate: piu' ostici (il numero) e
	# piu' svegli (la scelta). La seconda e' quella che si sente giocando, e
	# anche quella che si rompe in silenzio: basta che la cura resti dentro il
	# sorteggio e una creatura moribonda si cura una volta su cinque, cioe' mai.
	titolo("una creatura ferita capisce di esserlo, e sceglie di conseguenza")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["robo_pattuglia"]
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
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro di prova non si e' montato")
	scontro.in_corso = true
	eroe.hp_max = 100000   # deve reggere: qui si guarda il nemico
	eroe.hp = 100000
	var cura: Dictionary = {}
	for mossa in nemico.mosse:
		if String(mossa.get("tipo", "")) == "cura":
			cura = mossa
			break
	esigi(not cura.is_empty(), "la Robo Pattuglia non sa piu' ripararsi: la prova misura un'altra creatura")

	# 0. UNA CASELLA LIBERA NON E' UNA MOSSA. Se il sorteggio potesse pescarla,
	#    la creatura passerebbe la battuta a fare niente - e con tre caselle
	#    libere su sei succederebbe una volta su due
	var libera: Dictionary = {}
	for mossa in nemico.mosse:
		if String(mossa.get("tipo", "")) == "-":
			libera = mossa
			break
	esigi(not libera.is_empty(), "la Robo Pattuglia non ha nessuna casella libera da provare")
	esigi(not bool(scontro.mossa_disponibile(nemico, libera)),
			"una casella libera risulta fra le mosse che la creatura puo' fare")

	# 1. DA INTERA NON SI CURA. E' la prima cosa che fa sembrare stupida una
	#    creatura che dovrebbe sembrare astuta
	nemico.hp = nemico.hp_max
	esigi(not bool(scontro.mossa_disponibile(nemico, cura)),
			"a vita piena la riparazione d'emergenza e' ancora disponibile")
	esigi(scontro.mossa_saggia(nemico).is_empty(),
			"a vita piena la creatura sceglie gia' una mossa da disperata")

	# 2. FERITA, SI CURA - e non "puo' capitare che si curi": lo fa
	nemico.hp = maxi(int(nemico.hp_max) / 5, 1)
	esigi(bool(scontro.mossa_disponibile(nemico, cura)),
			"ferita a un quinto, la creatura non ha la riparazione fra le cose che puo' fare")
	esigi(String(scontro.mossa_saggia(nemico).get("id", "")) == String(cura.get("id", "")),
			"ferita a un quinto sceglie '%s' invece di ripararsi"
			% String(scontro.mossa_saggia(nemico).get("id", "-")))
	var prima_della_cura := int(nemico.hp)
	scontro.turno_nemico_normale(nemico)
	esigi(int(nemico.hp) > prima_della_cura,
			"la creatura ferita ha giocato il suo turno e non si e' curata (%d -> %d)"
			% [prima_della_cura, int(nemico.hp)])

	# 3. E NON SI CURA ALL'INFINITO. Senza ricarica, la mossa migliore resta la
	#    migliore anche il giro dopo: non uno scontro difficile, uno scontro che
	#    non finisce
	esigi(not bool(scontro.mossa_disponibile(nemico, cura)),
			"la cura e' subito di nuovo pronta: la creatura si rimette in piedi piu' in fretta di quanto la si abbatta")
	nemico.hp = maxi(int(nemico.hp_max) / 5, 1)
	var dopo_la_ricarica := int(nemico.hp)
	scontro.turno_nemico_normale(nemico)
	esigi(int(nemico.hp) <= dopo_la_ricarica,
			"si e' curata due volte di fila: la ricarica non conta")

	# 4. ALLE STRETTE PICCHIA DI PIU'. E' la parte che non si vede sceglere: si
	#    misura sul numero
	nemico.hp = nemico.hp_max
	var attacco_intero := RegoleCombattimento.attacco_di(nemico)
	esigi(not RegoleCombattimento.e_disperata(nemico), "a vita piena risulta gia' disperata")
	nemico.hp = maxi(int(nemico.hp_max) / 10, 1)
	esigi(RegoleCombattimento.e_disperata(nemico), "a un decimo di vita non risulta disperata")
	var attacco_alle_strette := RegoleCombattimento.attacco_di(nemico)
	esigi(attacco_alle_strette > attacco_intero,
			"ferita a morte colpisce come prima (%d): 'a fin di vita diventano piu' ostici' non succede"
			% attacco_alle_strette)

	# 4-bis. LO STESSO POTENZIAMENTO NON SI SOMMA CON SE STESSO.
	#    Ogni uso appendeva un buff nuovo, e una mossa di potenziamento senza
	#    ricarica si puo' rifare ogni battuta: il goblin arrabbiato si sommava
	#    +9 di attacco all'infinito e Jerah +14 di difesa finche' non lo si
	#    scalfiva piu'. Non era una scelta, era una somma senza tetto - e a
	#    schermo non si vedeva, perche' compare solo il totale.
	nemico.hp = nemico.hp_max
	nemico.buffs = []
	var difesa_nuda := RegoleCombattimento.difesa_di(nemico)
	RegoleCombattimento.applica_buff(nemico, "difesa", 5, 3, "prova")
	var difesa_con_uno := RegoleCombattimento.difesa_di(nemico)
	esigi(difesa_con_uno > difesa_nuda, "il potenziamento non ha alzato la difesa")
	for volta in 5:
		RegoleCombattimento.applica_buff(nemico, "difesa", 5, 3, "prova")
	esigi(RegoleCombattimento.difesa_di(nemico) == difesa_con_uno,
			"sei usi della stessa mossa portano la difesa a %d invece di %d: si somma con se stessa, e senza tetto"
			% [RegoleCombattimento.difesa_di(nemico), difesa_con_uno])
	# ...ma due mosse DIVERSE sulla stessa stat si sommano ancora: e' un modo di
	# dire "questa creatura sta mettendo insieme due cose"
	RegoleCombattimento.applica_buff(nemico, "difesa", 5, 3, "un'altra prova")
	esigi(RegoleCombattimento.difesa_di(nemico) > difesa_con_uno,
			"due mosse diverse che alzano la difesa non si sommano piu': cosi' non se ne puo' costruire nessuna")
	nemico.buffs = []

	# 5. E IL VALORE DI UNA MOSSA E' UNA QUOTA DEL SUO ATTACCO, non un numero
	#    scritto: se no una mossa calibrata al livello 4 al livello 20 fa ridere
	var colpo: Dictionary = {}
	for mossa in nemico.mosse:
		if mossa.has("quota"):
			colpo = mossa
			break
	esigi(not colpo.is_empty(), "nessuna mossa della Robo Pattuglia usa una quota dell'attacco")
	if not colpo.is_empty():
		nemico.hp = nemico.hp_max   # via l'effetto disperazione, che qui sporcherebbe
		var attacco_vero := int(nemico.attacco)
		var con_attacco_basso: int = scontro.valore_mossa(nemico, colpo)
		nemico.attacco = attacco_vero * 4
		var con_attacco_alto: int = scontro.valore_mossa(nemico, colpo)
		esigi(con_attacco_alto > con_attacco_basso,
				"quadruplicando l'attacco della creatura la sua mossa fa sempre %d: e' un numero fisso travestito"
				% con_attacco_alto)
		nemico.attacco = attacco_vero
	scontro.free()
	GameState.nuova_partita()

func prova_nessuna_creatura_perde_la_battuta() -> void:
	# Bru: "se si parla di ricarica della mossa e' ok - non puo' usare quella
	# mossa per tre battute - ma se il nemico rimane fermo per tre battute non
	# va bene".
	#
	# E' la prova piu' scomoda da scrivere e la piu' facile da rompere senza
	# accorgersene, perche' una battuta buttata non da' nessun errore: la
	# creatura "agisce", scrive una riga, e non succede niente. Il richiamo con
	# il campo gia' pieno stampava "...ma nessuno risponde al richiamo"; la
	# guardia gia' al massimo "e' gia' chiuso quanto puo'"; e da quando i
	# potenziamenti si rinnovano invece di sommarsi, rifare un potenziamento
	# ancora acceso non aggiunge piu' niente. Tre modi diversi di stare fermi
	# raccontandolo bene.
	#
	# Qui ogni creatura del bestiario gioca otto battute di fila SENZA che le
	# ricariche scalino - cioe' nella condizione peggiore, con tutto quello che
	# ha gia' speso - e a ognuna deve succedere qualcosa.
	titolo("nessuna creatura passa una battuta a fare niente")
	var saltate := ["manifestazione_di_un_sogno", "veronica",  # copione
			"tartaruga_innocente"]  # attacco 0: il suo mestiere e' non fare male
	var guardate := 0
	for id_creatura in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_creatura]
		if not dati.has("ruolo") or String(dati.get("ruolo", "")) == "oggetto_scena":
			continue
		if String(id_creatura) in saltate:
			continue
		GameState.nuova_partita()
		GameState.legame = 0   # la crisi di gelosia e' un'inerzia voluta: qui darebbe falsi rossi
		GameState.nemici_combattimento = [String(id_creatura)]
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
			esigi(false, "%s: lo scontro non si e' montato" % id_creatura)
			scontro.free()
			continue
		guardate += 1
		scontro.in_corso = true
		eroe.hp_max = 5000000
		eroe.hp = 5000000       # deve reggere otto battute di chiunque
		nemico.hp_max = 5000000
		nemico.hp = 5000000     # e non deve morire di autolesione a meta' prova
		# IL COLPO NORMALE SI TOGLIE DAL SORTEGGIO. Con il suo peso normale una
		# creatura tira spesso un pugno e basta, e un pugno non e' mai una
		# battuta persa: la prova diventerebbe una questione di fortuna, e
		# passerebbe anche col motore rotto. A peso zero esce sempre una MOSSA
		# finche' ce n'e' una disponibile - e se non ce n'e', si vede il colpo
		# normale di ripiego, che e' proprio la cosa che si vuole garantire
		nemico.peso_attacco_normale = 0
		var ferme := 0
		for battuta in 24:
			eroe.hp = eroe.hp_max   # sempre in piedi: qui si guarda solo il nemico
			nemico.ultima_mossa_tipo = ""
			var prima := fotografia(scontro, eroe, nemico)
			scontro.turno_nemico_normale(nemico)
			if fotografia(scontro, eroe, nemico) != prima:
				continue
			# UNA SCENA E' L'UNICA BATTUTA FERMA AMMESSA, ed e' ferma apposta:
			# lo Zombie che si guarda intorno, l'Orrore che guarda il cielo.
			# Senza questa distinzione la prova avrebbe due strade sbagliate:
			# fallire su una regia voluta, oppure - togliendola - smettere di
			# vedere le mosse che promettono un effetto e non lo fanno, che e'
			# il difetto per cui era stata scritta
			if String(nemico.get("ultima_mossa_tipo", "")) != "scena":
				ferme += 1
		esigi(ferme == 0,
				"%s ha passato %d battute su 24 senza che succedesse niente: si e' fermata invece di tirare almeno un colpo"
				% [id_creatura, ferme])
		scontro.free()
	esigi(guardate >= 30, "la prova ha guardato solo %d creature: il filtro si e' stretto" % guardate)
	GameState.nuova_partita()

func prova_le_meccaniche_nuove_delle_mosse() -> void:
	# Le sette cose che le mosse di Bru chiedevano e il motore non sapeva fare.
	# Ognuna misurata sul campo, con lo scontro montato: leggere il codice non
	# basta, perche' meta' di questi difetti sono "il valore c'e' e non arriva
	# a destinazione" - il buff di velocita' che non toccava la ricarica lo ha
	# scoperto la prova, non la rilettura
	titolo("le meccaniche nuove fanno davvero quello che dicono")
	GameState.nuova_partita()
	GameState.legame = 0
	GameState.nemici_combattimento = ["zombie_mostruoso"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = 1   # qui si chiamano le mosse a mano: l'orologio non deve girare da solo
	scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	add_child(scontro)
	var eroe: Dictionary = {}
	var nemico: Dictionary = {}
	for combattente in scontro.combattenti:
		if combattente.giocatore and eroe.is_empty():
			eroe = combattente
		elif not combattente.giocatore and nemico.is_empty():
			nemico = combattente
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro di prova non si e' montato")

	# 1. IL POTENZIAMENTO TOCCA PIU' STATISTICHE INSIEME, e sa anche togliere
	var attacco_prima := RegoleCombattimento.attacco_di(nemico)
	var velocita_prima := RegoleCombattimento.velocita_effettiva(nemico)
	scontro.esegui_mossa(nemico, {"id": "prova_moan", "tipo": "potenziamento",
			"testo": "-", "stat": {"attacco": 5, "velocita": -1}, "turni": 3})
	esigi(RegoleCombattimento.attacco_di(nemico) == attacco_prima + 5,
			"il potenziamento non ha alzato l'attacco: %d invece di %d"
			% [RegoleCombattimento.attacco_di(nemico), attacco_prima + 5])
	esigi(RegoleCombattimento.velocita_effettiva(nemico) == velocita_prima - 1,
			"il potenziamento non ha abbassato la velocita': un valore negativo non morde")

	# 2. E LA VELOCITA' SI SENTE NELLA RICARICA. Qui stava il difetto vero:
	# applica_buff accetta qualunque statistica, quindi il buff esisteva e si
	# vedeva - ma velocita_effettiva non guardava i buff, e la ricarica non
	# cambiava di un millesimo
	var ricarica_rallentato: float = scontro.ricarica_di(nemico)
	nemico.buffs = []
	var ricarica_pulita: float = scontro.ricarica_di(nemico)
	esigi(ricarica_rallentato > ricarica_pulita,
			"con la velocita' abbassata ricarica in %.2fs invece che in %.2fs: il potenziamento di velocita' non arriva all'orologio"
			% [ricarica_rallentato, ricarica_pulita])

	# 3. IL POTENZIAMENTO AGLI ALLEATI tocca gli altri e non se stesso
	scontro.aggiungi_combattente("zombie_cittadino", false)
	var compagno: Dictionary = {}
	for combattente in scontro.combattenti:
		if not combattente.giocatore and String(combattente.id) == "zombie_cittadino":
			compagno = combattente
	esigi(not compagno.is_empty(), "il compagno di prova non e' entrato in campo")
	nemico.buffs = []
	compagno.buffs = []
	scontro.esegui_mossa(nemico, {"id": "prova_incitamento", "tipo": "potenziamento",
			"testo": "-", "bersaglio": "alleati", "stat": {"velocita": 2}, "turni": 3})
	esigi(compagno.buffs.size() == 1,
			"l'incitamento non ha toccato il compagno: potenziare gli altri non funziona")
	esigi(nemico.buffs.is_empty(),
			"l'incitamento ha potenziato anche chi lo lancia: 'agli alleati' vuol dire agli altri")

	# 4. LA SCENA non fa niente, e alle strette non si sceglie mai
	var scena := {"id": "prova_scena", "tipo": "scena", "testo": "-"}
	nemico.hp = int(nemico.hp_max)
	esigi(scontro.mossa_eseguibile(nemico, scena),
			"la scena non e' disponibile nemmeno da sano: non si potrebbe usare mai")
	nemico.hp = maxi(int(float(nemico.hp_max) * 0.1), 1)
	esigi(not scontro.mossa_eseguibile(nemico, scena),
			"alle strette la creatura puo' ancora guardarsi intorno invece di reagire")
	nemico.hp = int(nemico.hp_max)

	# 5. IL DANNO CHE SALE COL CALARE DELLA VITA
	var rabbia := {"id": "prova_rabbia", "tipo": "attacco_forte", "testo": "-",
			"quota": 1.0, "quota_a_terra": 3.0}
	nemico.hp = int(nemico.hp_max)
	var da_sano: int = scontro.valore_mossa(nemico, rabbia)
	nemico.hp = maxi(int(float(nemico.hp_max) * 0.1), 1)
	var da_morente: int = scontro.valore_mossa(nemico, rabbia)
	esigi(da_morente > da_sano * 2,
			"ridotto male colpisce per %d contro i %d da sano: la rampa non c'e'"
			% [da_morente, da_sano])
	nemico.hp = int(nemico.hp_max)

	# 6. IL COLPO CHE COSTA A CHI LO TIRA, e non lo uccide mai
	var vita_prima := int(nemico.hp)
	scontro.paga_di_persona(nemico, {"costo_vita": 0.25})
	esigi(int(nemico.hp) < vita_prima, "la mossa che 'colpisce anche se stesso' non gli costa niente")
	nemico.hp = 1
	scontro.paga_di_persona(nemico, {"costo_vita": 0.9})
	esigi(int(nemico.hp) >= 1, "il colpo a proprio carico lo ha ucciso: si suicida invece di combattere")
	nemico.hp = int(nemico.hp_max)

	# 7. LA PERCENTUALE DELLA VITA RIMASTA: non passa dalla difesa, ma non uccide
	eroe.hp = int(eroe.hp_max)
	var vita_eroe := int(eroe.hp)
	scontro.esegui_mossa(nemico, {"id": "prova_discesa", "tipo": "attacco_tutti",
			"testo": "-", "quota_vita_bersaglio": 0.8})
	esigi(int(eroe.hp) < vita_eroe / 2,
			"la discesa ha tolto solo %d di %d: non e' una frazione della vita rimasta"
			% [vita_eroe - int(eroe.hp), vita_eroe])
	esigi(int(eroe.hp) >= 1, "la discesa ha steso la squadra: un colpo a cui non puoi fare niente non e' uno scontro")
	eroe.hp = int(eroe.hp_max)

	# 8. IL TORMENTO colpisce tutti a ogni loro battuta, E MUORE CON CHI LA TIENE SU
	scontro.esegui_mossa(nemico, {"id": "prova_aura", "tipo": "tormento", "testo": "-",
			"quota_per_turno": 0.3, "testo_turno": "-"})
	esigi(bool(eroe.get("in_fiamme", false)),
			"il tormento non si e' posata su nessuno")
	esigi(String(eroe.get("combustione", {}).get("fonte", "")) == String(nemico.id),
			"il tormento non ricorda chi l'ha lanciata: non potrebbe mai spegnersi")
	scontro.spegni_tormento_di(nemico)
	esigi(not bool(eroe.get("in_fiamme", false)),
			"caduto chi la teneva accesa, il vento continua a tagliare: il tormento sopravvive al suo padrone")

	# 9. LA RINASCITA: una volta sola, e poi si muore come tutti
	GameState.personaggi["zombie_mostruoso"]["rinascita"] = {"quota_vita": 0.25, "testo": "[i]%s[/i]"}
	nemico.hp = 0
	nemico.gia_rinato = false
	scontro._su_ko(nemico)
	esigi(int(nemico.hp) > 0, "la rinascita non l'ha rimesso in piedi")
	esigi(bool(nemico.get("gia_rinato", false)), "e' rinato senza segnarselo: rinascerebbe per sempre")
	nemico.hp = 0
	scontro._su_ko(nemico)
	esigi(int(nemico.hp) <= 0, "e' rinato una seconda volta: lo scontro non finisce piu'")
	GameState.personaggi["zombie_mostruoso"].erase("rinascita")
	scontro.free()

func prova_hype() -> void:
	# Bru: "facciamo che spendi xp ma maschereremo l'xp con il termine hype...
	# l'hype e' generico, scegli tu su quale personaggio spenderlo... ogni
	# personaggio ha il suo livello in base a quanti potenziamenti ha
	# acquistato... si possiamo fare la media, viva il gioco di squadra".
	titolo("l'hype: uno per tutti, e il livello e' quello che hai comprato")
	GameState.nuova_partita()
	esigi(GameState.hype_disponibile == 0 and GameState.hype_accumulato == 0,
			"una partita nuova comincia con dell'hype addosso")

	# DUE CONTATORI: spendere svuota il primo e non tocca il secondo
	var guadagnato := GameState.aggiungi_hype(50)
	esigi(guadagnato > 50, "l'hype non fa numeri piu' grossi dell'xp: ne ha dati %d su 50" % guadagnato)
	esigi(GameState.hype_disponibile == guadagnato, "l'hype guadagnato non e' spendibile")
	esigi(GameState.hype_accumulato == guadagnato, "l'hype accumulato non conta quello guadagnato")

	# IL LIVELLO E' QUANTI NODI HAI COMPRATO
	var protagonista := GameState.id_protagonista
	esigi(GameState.livello_di(protagonista) == 1, "un personaggio senza nodi non e' di livello 1")
	GameState.hype_disponibile = GameState.costo_in_hype(50)
	var accumulato_prima := GameState.hype_accumulato
	# UN NODO CHE COSTA DAVVERO. I gradi I delle linee non hanno "costo": sono
	# quelli che arrivano da soli col livello, e comprarli non spende niente.
	# Cercando "il primo che si puo' comprare" si finiva su uno di quelli, e la
	# verifica sulla spesa sarebbe passata misurando zero contro zero
	GameState.porta_al_livello(protagonista, 60)
	var livello_prima := GameState.livello_di(protagonista)
	var comprato := false
	for id_nodo in GameState.abilita.get("abilita", {}):
		if GameState.costo_nodo(String(id_nodo)) > 0 and GameState.nodo_disponibile(String(id_nodo)):
			comprato = GameState.sblocca_nodo(String(id_nodo))
			break
	esigi(comprato, "non si riesce a comprare nessun nodo pur avendo hype da spendere")
	esigi(GameState.livello_di(protagonista) == livello_prima + 1,
			"comprato un nodo, il livello e' %d invece di %d"
			% [GameState.livello_di(protagonista), livello_prima + 1])
	esigi(GameState.hype_disponibile < GameState.costo_in_hype(50),
			"comprare un nodo non ha speso hype")
	esigi(GameState.hype_accumulato == accumulato_prima,
			"spendere ha abbassato l'accumulato: la prova di aver giocato si cancella spendendo")

	# LO STESSO MUCCHIO PAGA PER CHIUNQUE, ed e' il senso dell'hype unico
	GameState.hype_disponibile = GameState.costo_in_hype(50)
	if not GameState.classi.has("brawler"):
		esigi(false, "Veronica non esiste: non si puo' provare l'hype su un compagno")
	else:
		var hype_prima := GameState.hype_disponibile
		GameState.porta_al_livello("brawler", 60)
		var suo_livello_prima := GameState.livello_di("brawler")
		var preso := false
		for id_nodo in GameState.abilita.get("abilita", {}):
			if GameState.costo_nodo(String(id_nodo)) > 0 \
					and GameState.nodo_disponibile(String(id_nodo), "brawler"):
				preso = GameState.sblocca_nodo(String(id_nodo), "brawler")
				break
		esigi(preso, "non si riesce a spendere hype su Veronica")
		esigi(GameState.hype_disponibile < hype_prima,
				"comprare per Veronica non ha toccato l'hype: non e' lo stesso mucchio")
		esigi(GameState.livello_di("brawler") == suo_livello_prima + 1,
				"comprato un nodo per Veronica, il suo livello non e' salito")
		esigi(GameState.livello_di(protagonista) != GameState.livello_di("brawler")
				or suo_livello_prima == livello_prima,
				"i livelli dei due si muovono insieme: non sono separati")

	# IL MONDO SI REGOLA SULLA MEDIA, non sul piu' forte
	GameState.party = [protagonista, "brawler"]
	GameState.nodi_abilita.clear()
	GameState.nodi_per_personaggio.clear()
	esigi(GameState.livello_squadra() == 1, "due personaggi a livello 1 non fanno media 1")
	var finti: Array[String] = []
	for numero in 10:
		finti.append("nodo_finto_%d" % numero)
	GameState.nodi_abilita.assign(finti)
	esigi(GameState.livello_di(protagonista) == 11, "dieci nodi non fanno livello 11")
	esigi(GameState.livello_squadra() == 6,
			"uno a 11 e uno a 1 dovrebbero fare media 6, fanno %d" % GameState.livello_squadra())
	esigi(GameState.livello_squadra() < GameState.livello_di(protagonista),
			"la media segue il piu' forte: chi porta avanti uno solo spacca la difficolta'")
	GameState.nodi_abilita.clear()

	# LA MAESTRIA DEL DOMINIO E' DI CHI SE L'E' GUADAGNATA
	var suo := GameState.maestria_dominio_di("brawler")
	var mio := GameState.maestria_dominio_di(protagonista)
	GameState.punti_stat["maestria_dominio"] = int(GameState.punti_stat.get("maestria_dominio", 0)) + 20
	esigi(GameState.maestria_dominio_di(protagonista) > mio, "la maestria del protagonista non e' salita")
	esigi(GameState.maestria_dominio_di("brawler") == suo,
			"la maestria di Veronica e' salita insieme a quella del protagonista: usa la sua")

func prova_abilita_di_veronica_e_yhvina() -> void:
	# I SETTE TIPI NUOVI, eseguiti davvero. Che siano dichiarati con un tipo che
	# il motore conosce lo verifica gia' un'altra prova; qui si guarda che
	# succeda qualcosa quando partono, che e' un'altra domanda. Un tipo
	# riconosciuto e implementato male passa il primo controllo e fallisce
	# questo.
	titolo("le abilita' di Veronica e Yhvina fanno qualcosa")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	add_child(scontro)
	scontro.in_corso = true
	var eroe: Dictionary = {}
	var nemico: Dictionary = {}
	for c in scontro.combattenti:
		if c.giocatore and eroe.is_empty():
			eroe = c
		elif not c.giocatore and nemico.is_empty():
			nemico = c
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro non si e' montato")
	eroe.hp_max = 1000
	eroe.hp = 1000

	# GUARDIA — uno o due scatti, e restano
	eroe.scatti_difesa = 0
	scontro.guardia(eroe, {"scatti": 2})
	esigi(RegoleCombattimento.scatti_difesa(eroe) == 2,
			"Muro ha alzato %d scatti invece di due" % RegoleCombattimento.scatti_difesa(eroe))

	# IMMUNITA — per due battute non lo scalfiscono
	eroe.turni_immune = 0
	scontro.immunita(eroe, {"turni": 2})
	esigi(int(eroe.turni_immune) == 2, "Non passa niente non ha reso nessuno intoccabile")
	eroe.turni_immune = 0

	# ULTIMA RESISTENZA — cadrebbe, e resta a 1
	eroe.ultima_resistenza = false
	scontro.ultima_resistenza(eroe, {})
	esigi(bool(eroe.ultima_resistenza), "Finche' respiro non si e' acceso")
	eroe.hp = 0
	scontro.trattieni_a_un_punto(eroe)
	esigi(int(eroe.hp) == 1, "cadrebbe e non e' rimasto a 1: e' a %d" % int(eroe.hp))
	esigi(not bool(eroe.ultima_resistenza), "si e' consumata: vale una volta per scontro")
	eroe.hp = 0
	scontro.trattieni_a_un_punto(eroe)
	esigi(int(eroe.hp) == 0, "ha trattenuto due volte in un solo scontro")
	eroe.hp = 1000

	# RIANIMA — rimette in piedi chi e' caduto, ma non chi e' caduto per maledizione
	scontro.aggiungi_combattente("insonne", true)
	var compagno: Dictionary = scontro.combattenti[scontro.combattenti.size() - 1]
	if bool(compagno.get("giocatore", false)):
		compagno.hp = 0
		compagno.non_rianimabile = true
		scontro.rianima(eroe, {"quota": 0.30})
		esigi(int(compagno.hp) == 0,
				"ha rianimato chi era caduto per maledizione: la maledizione non conta piu' niente")
		compagno.non_rianimabile = false
		scontro.rianima(eroe, {"quota": 0.30})
		esigi(int(compagno.hp) > 0, "Rialzati non ha rimesso in piedi nessuno")

		# COPERTURA — meta' del colpo va a chi copre
		compagno.hp = compagno.hp_max
		eroe.hp = eroe.hp_max
		compagno.coperto_da = int(eroe.indice)
		compagno.copertura_turni = 3
		var vita_scudo_prima := int(eroe.hp)
		var resta: int = scontro.smista_la_copertura(compagno, 40)
		esigi(resta == 20, "al coperto ne restano %d invece di venti" % resta)
		esigi(int(eroe.hp) == vita_scudo_prima - 20,
				"chi copre non ha incassato la sua meta': era a %d, adesso e' a %d"
				% [vita_scudo_prima, int(eroe.hp)])
		compagno.copertura_turni = 0

	# EVOCA_ALLEATO — senza sapere CHI evoca non deve arrivare nessuno, e non
	# deve nemmeno rompersi: e' la domanda aperta piu' grossa su Yhvina
	var quanti_prima: int = scontro.combattenti.size()
	scontro.evoca_alleato(eroe, {"valore": "", "quantita": 1})
	esigi(scontro.combattenti.size() == quanti_prima,
			"ha evocato qualcuno pur non sapendo chi: il campo 'valore' e' vuoto")
	scontro.evoca_alleato(eroe, {"valore": "slime_infimo", "quantita": 1})
	esigi(scontro.combattenti.size() > quanti_prima, "il Richiamo non ha portato nessuno")

	# e le due classi esistono con le loro armi
	esigi(GameState.classi.has("brawler"), "Veronica non esiste come personaggio giocabile")
	esigi(String(GameState.classi.get("brawler", {}).get("classe_arma", "")) == "pesante",
			"Veronica non impugna un'arma pesante")
	esigi(String(GameState.classi.get("insonne", {}).get("classe_arma", "")) == "talismani",
			"Yhvina non impugna talismani: Bru aveva corretto gli artigli")
	esigi(int(GameState.classi.get("insonne", {}).get("hp", 0)) < 200,
			"Yhvina ha ancora i 400 punti vita di quando i compagni non crescevano")
	scontro.free()

func prova_i_cinque_tipi() -> void:
	# Bru: "ora so definire anche i tipi: Natura, Artificio, Spirituale,
	# Speciale, Tetro... l'asse che decide efficacia e resistenze, uno solo,
	# non due. Tre valori soli: normale, ipersensibile, immune".
	#
	# ATTENZIONE A COSA MISURA QUESTA PROVA. Non la tabella - quella e' mia e
	# Bru la cambiera' - ma il MECCANISMO: che il tipo dell'arma vinca su quello
	# del personaggio, che l'eccezione scritta a mano vinca sulla tabella, che
	# un immune incassi zero. Se misurasse "Artificio pesa su Natura",
	# diventerebbe rossa il giorno in cui lui riscrive la tabella, ed e' proprio
	# il giorno in cui deve restare verde.
	titolo("i cinque tipi decidono quanto pesa un colpo")
	esigi(GameState.tipi.size() == 5, "i tipi sono %d invece di cinque" % GameState.tipi.size())
	for nome_tipo in ["Natura", "Artificio", "Spirituale", "Speciale", "Tetro"]:
		esigi(GameState.tipi.has(nome_tipo), "manca il tipo '%s'" % nome_tipo)
	# OGNI CREATURA DEL BESTIARIO ne ha uno, e uno dei cinque. Le persone no, ed
	# e' voluto: Veronica, Yhvina e il protagonista non sono Natura ne' Tetro -
	# il tipo del loro colpo lo da' l'arma che hanno in mano. Un tipo intrinseco
	# addosso a loro vorrebbe dire che il protagonista e' forte contro qualcosa
	# anche a mani nude, che e' l'opposto di un personaggio che si chiama Anonimo
	for id_creatura in GameState.personaggi:
		if not GameState.e_da_bestiario(String(id_creatura)):
			continue
		var suo := String(GameState.personaggi[id_creatura].get("tipo", ""))
		esigi(GameState.tipi.has(suo), "%s ha tipo '%s', che non e' uno dei cinque" % [id_creatura, suo])

	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	add_child(scontro)
	var eroe: Dictionary = {}
	var nemico: Dictionary = {}
	for c in scontro.combattenti:
		if c.giocatore and eroe.is_empty():
			eroe = c
		elif not c.giocatore and nemico.is_empty():
			nemico = c
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro non si e' montato")

	# un colpo senza tipo passa liscio: e' com'e' sempre stato, e non deve cambiare
	var senza_tipo := {"id": "nessuno_in_particolare", "giocatore": false}
	esigi(is_equal_approx(RegoleCombattimento.efficacia_tipo(senza_tipo, nemico), 1.0),
			"un attaccante senza tipo non fa piu' danno normale")

	# LA TABELLA. Si costruisce qui una coppia apposta invece di fidarsi di due
	# creature vere: cosi' la prova misura il meccanismo e non chi ha scritto
	# cosa nei dati
	var vecchio_tipo := String(GameState.personaggi["goblin_tipico"].get("tipo", ""))
	GameState.tipi["Natura"]["ipersensibile_a"] = ["Artificio"]
	GameState.personaggi["goblin_tipico"]["tipo"] = "Natura"
	var attaccante_artificio := {"id": "robo_pattuglia", "giocatore": false}
	esigi(RegoleCombattimento.efficacia_tipo(attaccante_artificio, nemico) > 1.0,
			"la tabella non conta niente: Artificio su Natura pesa uguale al normale")

	# L'ECCEZIONE SCRITTA A MANO VINCE SULLA TABELLA, in tutte e due i versi
	GameState.personaggi["goblin_tipico"]["immune_a"] = ["Artificio"]
	esigi(is_equal_approx(RegoleCombattimento.efficacia_tipo(attaccante_artificio, nemico), 0.0),
			"immune_a non ferma il colpo: la tabella vince sull'eccezione")
	GameState.personaggi["goblin_tipico"].erase("immune_a")
	GameState.personaggi["goblin_tipico"]["sensibile"] = ["Tetro"]
	var attaccante_tetro := {"id": "ghoul", "giocatore": false}
	esigi(RegoleCombattimento.efficacia_tipo(attaccante_tetro, nemico) > 1.0,
			"sensibile scritto a mano non conta: l'eccezione non arriva")
	GameState.personaggi["goblin_tipico"].erase("sensibile")

	# e in campo il danno cambia davvero, non solo il numero che torna la funzione
	scontro.in_corso = true
	nemico.hp_max = 100000
	nemico.hp = 100000
	GameState.personaggi["goblin_tipico"].erase("immune_a")
	var colpo_normale := RegoleCombattimento.calcola_danno(
			{"id": "ghoul", "giocatore": false, "attacco": 100, "buffs": [], "stati_attivi": {},
			"fattore": 0, "stress": 0, "psiche": "", "stati": []}, nemico, 100, 1.0, 0)
	GameState.personaggi["goblin_tipico"]["sensibile"] = ["Tetro"]
	var colpo_giusto := RegoleCombattimento.calcola_danno(
			{"id": "ghoul", "giocatore": false, "attacco": 100, "buffs": [], "stati_attivi": {},
			"fattore": 0, "stress": 0, "psiche": "", "stati": []}, nemico, 100, 1.0, 0)
	esigi(int(colpo_giusto.danno) > int(colpo_normale.danno),
			"il colpo giusto fa %d, quello normale %d: l'efficacia non arriva al danno"
			% [int(colpo_giusto.danno), int(colpo_normale.danno)])
	GameState.personaggi["goblin_tipico"].erase("sensibile")
	GameState.personaggi["goblin_tipico"]["tipo"] = vecchio_tipo

	# L'ARMA VINCE SUL PERSONAGGIO. E' il protagonista Anonimo: non ha un tipo
	# suo, ce l'ha quello che impugna
	GameState.sacca.append("coltello_di_servizio")
	GameState.equipaggia(String(eroe.id), "arma", "coltello_di_servizio")
	esigi(RegoleCombattimento.tipo_di(eroe) == "Artificio",
			"con un coltello in mano il tipo del colpo e' '%s' invece di quello dell'arma"
			% RegoleCombattimento.tipo_di(eroe))
	scontro.free()

func prova_il_colpo_si_sente() -> void:
	# GLI EFFETTI DI COLPO, misurati dove si possono misurare.
	#
	# Un fermo immagine e una scossa non si possono provare guardando lo schermo:
	# in queste prove lo schermo non c'e'. Per questo Impatto.gd e' scritto in
	# due meta' - le funzioni che DECIDONO (quanto scuotere, quanto fermare, con
	# che segno marcare un colpo) sono statiche e pure, e sono queste; la meta'
	# che muove i nodi e' volutamente sottile e non decide niente.
	#
	# Quello che si misura qui e' il ragionamento, non i numeri: che la severita'
	# guardi la PROPORZIONE e non il danno assoluto, che sotto soglia non succeda
	# niente, che niente possa sfondare il tetto.
	titolo("un colpo si sente: fermo immagine, scossa, scatto")

	# LA REGOLA PIU' IMPORTANTE: trenta danni non vogliono dire niente da soli.
	# Trenta a una creatura da quaranta punti vita sono la fine del mondo, trenta
	# a un boss da milleduecento sono una zanzara. Un effetto che guardasse il
	# numero scuoterebbe lo schermo per le zanzare
	var sulla_piccola := ImpattoCombattimento.severita(30, 40)
	var sul_bestione := ImpattoCombattimento.severita(30, 1200)
	esigi(sulla_piccola > sul_bestione,
			"trenta danni pesano uguale su 40 e su 1200 punti vita (%.2f contro %.2f): la severita' guarda il numero, non la proporzione"
			% [sulla_piccola, sul_bestione])
	esigi(is_equal_approx(ImpattoCombattimento.severita(0, 100), 0.0),
			"un colpo da zero danni ha una severita' sopra zero")
	esigi(is_equal_approx(ImpattoCombattimento.severita(50, 0), 0.0),
			"un bersaglio senza vita massima non manda la severita' in divisione per zero")
	esigi(ImpattoCombattimento.severita(99999, 100) <= 1.0,
			"la severita' sfonda l'uno: un colpo enorme scuoterebbe fuori scala")

	# IL FERMO NON SUCCEDE SEMPRE. Un fermo a ogni colpo non e' un fermo: e' un
	# gioco che va a scatti, ed e' il modo piu' veloce di rendere insopportabile
	# la tecnica piu' efficace che esista
	var graffio := ImpattoCombattimento.severita(1, 300)
	esigi(is_equal_approx(ImpattoCombattimento.durata_fermo(graffio), 0.0),
			"un graffio ferma il mondo: sotto soglia il fermo deve valere zero")
	esigi(is_equal_approx(ImpattoCombattimento.ampiezza_scossa(graffio), 0.0),
			"un graffio scuote lo schermo")
	var mazzata := ImpattoCombattimento.severita(120, 300)
	esigi(ImpattoCombattimento.durata_fermo(mazzata) > 0.0,
			"un colpo da 120 su 300 punti vita non ferma niente")
	esigi(ImpattoCombattimento.ampiezza_scossa(mazzata) > 0.0,
			"un colpo da 120 su 300 punti vita non scuote niente")

	# un critico e' l'eccezione: si ferma e sbanda anche quando e' piccolo,
	# esattamente come il suo numero e' grande anche quando e' piccolo
	esigi(ImpattoCombattimento.durata_fermo(graffio, true) > 0.0,
			"un critico che toglie poco non ferma niente: il critico deve sempre interrompere")
	esigi(ImpattoCombattimento.ampiezza_scossa(graffio, true) > 0.0,
			"un critico che toglie poco non scuote niente")

	# E NIENTE PUO' SFONDARE IL TETTO, nemmeno un critico da un milione di danni:
	# oltre un certo punto un fermo non e' piu' un colpo, e' il gioco bloccato,
	# e una scossa non e' piu' emozione, e' nausea
	var enorme := ImpattoCombattimento.severita(1000000, 10)
	esigi(ImpattoCombattimento.durata_fermo(enorme, true) <= ImpattoCombattimento.FERMO_MASSIMO,
			"il fermo sfonda il tetto: %.3fs" % ImpattoCombattimento.durata_fermo(enorme, true))
	esigi(ImpattoCombattimento.ampiezza_scossa(enorme, true) <= 12.0,
			"la scossa sfonda i dodici pixel: %.1f" % ImpattoCombattimento.ampiezza_scossa(enorme, true))

	# IL SEGNO DELL'EFFICACIA. Un segno e non solo un colore, per la stessa
	# ragione per cui i posti visitati hanno un pallino e non solo una tinta
	esigi(ImpattoCombattimento.marchio_efficacia(1.0) == "",
			"un colpo normale porta un segno addosso: solo l'eccezione va marcata")
	esigi(ImpattoCombattimento.marchio_efficacia(1.5) != "",
			"un colpo ipersensibile non si distingue da uno normale")
	esigi(ImpattoCombattimento.marchio_efficacia(0.5) != "",
			"un colpo resistito non si distingue da uno normale")
	esigi(ImpattoCombattimento.marchio_efficacia(1.5) != ImpattoCombattimento.marchio_efficacia(0.5),
			"ipersensibile e resistito portano lo stesso segno: sono due cose opposte")
	esigi(ImpattoCombattimento.marchio_efficacia(0.0) != "",
			"un colpo immune non lascia niente a schermo: il giocatore non sa di aver sbagliato strada")

	# IL NUMERO SCRITTO PER INTERO. Non basta che il segno esista: deve arrivare
	# dentro al numero che vola. Il posto dove si compone e' una funzione a
	# parte apposta per questo - dentro il combattimento finirebbe in una
	# Callable che da muti non viene mai guardata, e il giorno che qualcuno
	# togliesse il segno non diventerebbe rosso niente
	esigi(ImpattoCombattimento.testo_del_numero(42).contains("42"),
			"il numero che vola non contiene il danno")
	esigi(ImpattoCombattimento.testo_del_numero(42, true) != ImpattoCombattimento.testo_del_numero(42),
			"un critico da 42 si scrive come un colpo normale da 42")
	esigi(ImpattoCombattimento.testo_del_numero(42, false, 1.5)
			!= ImpattoCombattimento.testo_del_numero(42),
			"il segno dell'efficacia non arriva dentro il numero che vola")
	esigi(ImpattoCombattimento.testo_del_numero(42, true, 1.5).contains("42"),
			"un critico ipersensibile perde per strada il suo danno")

	# lo scatto ha una direzione, e la direzione dipende da dove sta l'altro
	esigi(ImpattoCombattimento.verso_scatto(true).x > 0.0,
			"chi ha il bersaglio a destra si sporge a sinistra")
	esigi(ImpattoCombattimento.verso_scatto(false).x < 0.0,
			"chi ha il bersaglio a sinistra si sporge a destra")

func prova_il_fermo_immagine_non_resta_acceso() -> void:
	# LA COSA CHE PUO' ROVINARE L'INTERA PARTITA, e sta in una riga.
	#
	# Il fermo immagine abbassa Engine.time_scale, che e' GLOBALE e non
	# appartiene a nessuna scena. Se si abbassa e qualcosa va storto prima di
	# rialzarlo - lo scontro finisce, il giocatore esce, la scena viene liberata
	# proprio in quel decimo di secondo - il gioco INTERO resta al rallentatore
	# per sempre, e non c'e' niente a schermo che spieghi perche'. Non e' un bug
	# che si nota subito: e' un gioco che "e' diventato lento".
	titolo("il fermo immagine si rimette sempre a posto")

	# 1. DA MUTI NON SI TOCCA NIENTE. Il giocatore automatico gioca migliaia di
	# scontri: se toccasse time_scale anche una volta sola rallenterebbe tutte
	# le prove, e nessuno capirebbe perche' ci mettono venti minuti
	var muto := ImpattoCombattimento.new(get_tree(), true)
	muto.fermo(0.1)
	esigi(is_equal_approx(Engine.time_scale, 1.0),
			"un Impatto muto ha abbassato il tempo del gioco a %.2f" % Engine.time_scale)
	muto.scossa(10.0)
	esigi(is_equal_approx(Engine.time_scale, 1.0), "un Impatto muto ha toccato il tempo con una scossa")

	# 2. IL FERMO VERO FUNZIONA DAVVERO. Le prove girano tutte da mute, quindi
	# senza questo pezzo la strada che il giocatore percorre davvero non la
	# proverebbe mai nessuno - e li' dentro c'e' una chiamata a create_timer con
	# quattro parametri che, se sbagliata, si scopre solo giocando
	var vero := ImpattoCombattimento.new(get_tree(), false)
	vero.fermo(0.05)
	esigi(Engine.time_scale < 1.0,
			"il fermo immagine non ha rallentato niente: il tempo e' rimasto a %.2f" % Engine.time_scale)

	# 3. UN FERMO ALLA VOLTA. Due colpi ravvicinati non devono moltiplicare il
	# rallentamento ne' rubarsi il ripristino a vicenda: il secondo trova il
	# posto occupato e lascia perdere
	var durante := Engine.time_scale
	vero.fermo(0.05)
	esigi(is_equal_approx(Engine.time_scale, durante),
			"due fermi di fila si sono sommati: il tempo e' sceso da %.2f a %.2f" % [durante, Engine.time_scale])

	# 4. LA RETE DI SICUREZZA. sblocca() viene chiamata da _exit_tree dello
	# scontro, comunque sia finito: vinto, perso, fuggito, o perche' il giocatore
	# ha chiuso tutto proprio in quel decimo di secondo
	vero.sblocca()
	esigi(is_equal_approx(Engine.time_scale, 1.0),
			"dopo un fermo vero e sblocca() il tempo e' rimasto a %.2f" % Engine.time_scale)

	# e lo rimette a posto anche partendo da un tempo sporcato da fuori: e'
	# esattamente lo stato in cui resterebbe il gioco se la scena sparisse
	Engine.time_scale = ImpattoCombattimento.SCALA_FERMO
	vero.sblocca()
	esigi(is_equal_approx(Engine.time_scale, 1.0),
			"dopo sblocca() il tempo e' rimasto a %.2f: il gioco resterebbe al rallentatore per sempre"
			% Engine.time_scale)
	Engine.time_scale = 1.0

func prova_il_tipo_si_vede_sul_colpo() -> void:
	# IL TIPO ESISTEVA SOLO COME MOLTIPLICATORE. Il colpo ipersensibile faceva
	# il cinquanta per cento in piu' e a schermo era un numero rosso come tutti
	# gli altri, appena piu' grande: non c'era modo di collegarlo all'arma che
	# avevi in mano. Adesso il colore del numero dice CON COSA hai colpito e il
	# segno dice COM'E' ANDATA.
	titolo("il tipo del colpo si vede nel numero che vola")

	# un critico e' oro e vince su tutto: e' l'eccezione piu' forte del gioco e
	# non deve mai confondersi con un elemento
	esigi(Stile.colore_colpo("fuoco", "Natura", true) == Stile.colore_danno("critico"),
			"un critico di fuoco non e' oro: il critico non vince sull'elemento")

	# l'ELEMENTO vince sul tipo quando c'e': il fuoco e' arancione da prima che i
	# tipi esistessero, e i tipi non devono cancellare una cosa che funziona
	esigi(Stile.colore_colpo("fuoco", "Natura") == Stile.colore_danno("fuoco"),
			"una mossa di fuoco non e' piu' arancione: il tipo ha mangiato l'elemento")

	# e IL TIPO arriva dove prima c'era solo il rosso generico. E' la novita':
	# quasi nessuna mossa dichiara un elemento, quindi fino a ieri erano tutte
	# dello stesso colore
	for nome_tipo in GameState.tipi:
		var suo := Stile.colore_tipo(String(nome_tipo))
		esigi(Stile.colore_colpo("", String(nome_tipo)) == suo,
				"un colpo di %s senza elemento non prende il colore del suo tipo" % nome_tipo)
	esigi(Stile.colore_tipo("Natura") != Stile.colore_tipo("Tetro"),
			"due tipi diversi hanno lo stesso colore: a schermo non si distinguono")

	# IL COLORE STA IN tipi.json, non qui. Una seconda copia delle tinte dentro
	# stile.json sarebbe comoda e sbagliata: il giorno che Bru cambia il colore
	# di Spirituale lo cambia dove i tipi sono descritti
	var prima_tinta := Stile.colore_tipo("Spirituale")
	var vecchio_colore := String(GameState.tipi["Spirituale"].get("colore", ""))
	GameState.tipi["Spirituale"]["colore"] = "#123456"
	esigi(Stile.colore_tipo("Spirituale") != prima_tinta,
			"cambiare il colore in tipi.json non cambia niente a schermo: la tinta e' scritta due volte")
	GameState.tipi["Spirituale"]["colore"] = vecchio_colore

	# un tipo che non esiste non fa esplodere niente: torna il colore normale
	esigi(Stile.colore_colpo("", "Marmellata") == Stile.colore_danno("normale"),
			"un tipo inventato non ripiega sul colore normale")

func prova_resistere_non_e_essere_immuni() -> void:
	# LA TERZA VOCE CHE MANCAVA. Una creatura poteva dichiarare "questo mi fa
	# male il doppio" e "questo non mi fa niente", ma non la cosa in mezzo -
	# "questo lo reggo bene" - che e' la piu' comune di tutte. Senza, ogni
	# eccezione al tipo doveva essere totale.
	#
	# Nessuna creatura la usa ancora: la voce c'e' perche' possa usarla Bru.
	# Questa prova misura il meccanismo, e resta verde qualunque cosa lui scriva.
	titolo("resistere a un tipo non e' essere immuni")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	add_child(scontro)
	var nemico: Dictionary = {}
	for c in scontro.combattenti:
		if not c.giocatore and nemico.is_empty():
			nemico = c
	esigi(not nemico.is_empty(), "lo scontro non si e' montato")
	var picchiatore := {"id": "ghoul", "giocatore": false, "attacco": 100, "buffs": [],
			"stati_attivi": {}, "fattore": 0, "stress": 0, "psiche": "", "stati": []}
	var tipo_del_colpo := RegoleCombattimento.tipo_di(picchiatore)
	nemico.hp_max = 100000
	nemico.hp = 100000

	var pieno: Dictionary = RegoleCombattimento.calcola_danno(picchiatore, nemico, 100, 1.0, 0)
	GameState.personaggi["goblin_tipico"]["resiste_a"] = [tipo_del_colpo]
	var retto: Dictionary = RegoleCombattimento.calcola_danno(picchiatore, nemico, 100, 1.0, 0)
	esigi(int(retto.danno) < int(pieno.danno),
			"resiste_a non toglie niente: il colpo fa %d contro %d" % [int(retto.danno), int(pieno.danno)])
	esigi(int(retto.danno) > 0,
			"resistere ha cancellato il colpo: resistere non e' essere immuni")

	# E UN COLPO RIDOTTO NON SPARISCE MAI, per quanto lo si riduca. E' la stessa
	# legge della corazza, scritta in Regole.gd: riduce, non cancella, mai zero.
	# Senza il pavimento, un colpo che moltiplicato finisce sotto il mezzo punto
	# si arrotonda a zero, e a schermo diventa indistinguibile da un'immunita'.
	#
	# La prima versione di questa prova non misurava niente: passava un attacco
	# da 1 sperando che dimezzato finisse a zero, ma fra bonus di livello e
	# arma il colpo arrivava alla riduzione gia' abbastanza grosso, e restava
	# verde anche togliendo il pavimento. Se n'e' accorto il sabotaggio, non io.
	# Cosi' invece si stringe la resistenza al punto che QUALUNQUE colpo, senza
	# pavimento, sparirebbe - e la prova vale anche per il numero che scrivera'
	# Bru, non solo per il mio
	var moltiplicatore_vero := float(GameState.regole.get("tipo_moltiplicatore_resistente", 0.5))
	GameState.regole["tipo_moltiplicatore_resistente"] = 0.001
	var minuscolo: Dictionary = RegoleCombattimento.calcola_danno(picchiatore, nemico, 100, 1.0, 0)
	esigi(int(minuscolo.danno) > 0,
			"una resistenza fortissima ha cancellato il colpo: resistere non e' essere immuni")
	GameState.regole["tipo_moltiplicatore_resistente"] = moltiplicatore_vero

	# l'immunita' invece cancella davvero, e resta distinta
	GameState.personaggi["goblin_tipico"].erase("resiste_a")
	GameState.personaggi["goblin_tipico"]["immune_a"] = [tipo_del_colpo]
	var nullo: Dictionary = RegoleCombattimento.calcola_danno(picchiatore, nemico, 100, 1.0, 0)
	esigi(int(nullo.danno) == 0, "immune_a lascia passare %d danni" % int(nullo.danno))
	GameState.personaggi["goblin_tipico"].erase("immune_a")
	scontro.free()

func prova_il_tetto_alla_cura_di_se() -> void:
	# IL DIVORATORE SI RIMETTE ADDOSSO IL 145% DELLA SUA VITA. Simulazione
	# Ouroboros: tre battute al 15%, e mentre gira e' pure irraggiungibile.
	# Autoriciclaggio subito dopo: quattro battute al 25%. Piu' quello che ruba
	# con la Presa. Non e' un boss difficile - e' uno scontro che non si puo' ne'
	# vincere ne' perdere, e finisce quando si stanca il giocatore.
	#
	# La risposta non e' limare quella creatura: domani ne arriva un'altra
	# scritta con lo stesso entusiasmo. E' una regola di motore, e questa prova
	# misura la regola.
	titolo("nessuna creatura si rimette addosso piu' vita di quanta ne abbia")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	add_child(scontro)
	var eroe: Dictionary = {}
	var nemico: Dictionary = {}
	for c in scontro.combattenti:
		if c.giocatore and eroe.is_empty():
			eroe = c
		elif not c.giocatore and nemico.is_empty():
			nemico = c
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro non si e' montato")

	var quota := float(GameState.regole.get("cura_di_se_massima_quota", 1.0))
	nemico.hp_max = 100
	nemico.hp = 1
	var totale := 0
	# venti cure da mezza vita ciascuna: senza tetto sarebbero mille punti
	for _giro in 20:
		nemico.hp = 1
		var rimesso: int = scontro.rimetti_in_piedi(nemico, 50)
		totale += rimesso
	var tetto := int(round(100.0 * quota))
	esigi(totale <= tetto,
			"la creatura si e' rimessa addosso %d punti su un tetto di %d" % [totale, tetto])
	esigi(totale > 0, "il tetto ha bloccato anche la prima cura: non e' un tetto, e' un divieto")

	# ARRIVATA AL TETTO SI FERMA, e da li' in poi non passa piu' niente
	nemico.hp = 1
	var dopo: int = scontro.rimetti_in_piedi(nemico, 50)
	esigi(dopo == 0, "oltre il tetto sono passati altri %d punti" % dopo)

	# LA TUA SQUADRA NON HA NESSUN TETTO. Le cure del party le paghi tu, con
	# oggetti comprati o aura spesa: un limite invisibile sul numero di fiale che
	# fanno effetto sarebbe la cosa piu' crudele e piu' incomprensibile del gioco
	eroe.hp_max = 100
	var totale_eroe := 0
	for _giro in 20:
		eroe.hp = 1
		var rimesso_eroe: int = scontro.rimetti_in_piedi(eroe, 50)
		totale_eroe += rimesso_eroe
	esigi(totale_eroe > tetto,
			"anche il party ha un tetto alle cure: ne ha ricevute %d" % totale_eroe)

	# non si supera mai la vita massima, tetto o non tetto
	eroe.hp = 95
	var troppo: int = scontro.rimetti_in_piedi(eroe, 999)
	esigi(int(eroe.hp) == int(eroe.hp_max),
			"una cura enorme ha portato la vita a %d su un massimo di %d" % [int(eroe.hp), int(eroe.hp_max)])
	esigi(troppo == 5, "la cura ha dichiarato %d punti rimessi invece dei 5 che ci stavano" % troppo)
	scontro.free()

func prova_la_vita_bassa_si_annuncia() -> void:
	# IL KO ARRIVAVA SENZA PREAVVISO. La vita era un numero in una riga di sei
	# voci, in mezzo a Stress, Fattore e Dominio, dello stesso colore di tutto il
	# resto: si passava da "sto giocando" a "e' a terra" senza nessun momento in
	# cui il gioco avesse detto "adesso". E un KO che non si vede arrivare non e'
	# tensione, e' sfortuna.
	titolo("una scheda in pericolo lo dice prima di cadere")
	var soglia := float(GameState.regole.get("soglia_vita_bassa", 0.25))
	esigi(soglia > 0.0 and soglia < 1.0,
			"la soglia della vita bassa e' %.2f: fuori da li' l'allarme o non suona mai o suona sempre" % soglia)
	var sotto := int(floor(100.0 * soglia))
	esigi(CampoCombattimento.in_pericolo(sotto, 100),
			"a %d punti su 100 l'allarme non suona" % sotto)
	esigi(not CampoCombattimento.in_pericolo(100, 100),
			"l'allarme suona a vita piena")
	# chi e' gia' a terra non e' "in pericolo": e' un'altra cosa, e la scheda la
	# dice gia' con il suo KO
	esigi(not CampoCombattimento.in_pericolo(0, 100), "un KO risulta 'in pericolo'")
	esigi(not CampoCombattimento.in_pericolo(10, 0),
			"un bersaglio senza vita massima manda l'allarme in divisione per zero")

func prova_gli_otto_status() -> void:
	# Gli otto che ha definito Bru, uno per uno. I numeri sono miei e si possono
	# cambiare senza toccare questa prova: qui non si misura QUANTO fa male una
	# Fiamma, si misura che faccia quello che dice di fare. Una prova che si
	# rompe quando Bru cambia un numero e' una prova che gli impedisce di
	# cambiarlo.
	titolo("gli otto status fanno quello che dicono")

	# DOVE VA IL NOME. Un %s di troppo in GDScript non e' un refuso: e' un
	# errore a runtime, e un errore a runtime INTERROMPE la funzione dov'e'
	# successo. Uno stato con due segnaposto smetterebbe di applicarsi a meta',
	# e da fuori sembrerebbe solo uno stato che non fa niente. E' lo stesso
	# controllo che le abilita' hanno da sempre, portato anche qui.
	for id_stato in GameState.stati:
		var info: Dictionary = GameState.stati[id_stato]
		for chiave in ["testo_applicazione", "testo_turno", "testo_fine", "testo_consumo"]:
			var testo := String(info.get(chiave, ""))
			esigi(testo.count("%s") <= 1,
					"%s: '%s' ha %d segnaposto e il motore ne passa uno: lo stato si interrompe lì"
					% [id_stato, chiave, testo.count("%s")])

	esigi(GameState.stati.size() == 10,
			"gli stati sono %d: dovrebbero essere gli otto piu' Rapidita' e Lentezza" % GameState.stati.size())
	for id_atteso in ["terrore", "fiamme", "tossina", "sonno", "maledizione",
			"rabbia", "provocato", "frastornato"]:
		esigi(GameState.stati.has(id_atteso), "manca lo status '%s'" % id_atteso)
	for id_vecchio in ["veleno", "berserk", "confusione", "egocentrismo", "demotivazione"]:
		esigi(not GameState.stati.has(id_vecchio),
				"lo status vecchio '%s' e' ancora li'" % id_vecchio)

	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	add_child(scontro)
	scontro.in_corso = true
	var eroe: Dictionary = {}
	var nemico: Dictionary = {}
	for c in scontro.combattenti:
		if c.giocatore and eroe.is_empty():
			eroe = c
		elif not c.giocatore and nemico.is_empty():
			nemico = c
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro non si e' montato")
	eroe.hp_max = 1000
	eroe.hp = 1000

	# IL NOME ENTRA DOVE C'E' IL %s, E SOLO LI'
	var con_nome: String = scontro.frase_di_stato(eroe, "%s prende fuoco.")
	esigi(con_nome.contains(String(eroe.nome)),
			"una frase con %%s non ha ricevuto il nome: esce '%s'" % con_nome)
	esigi(not con_nome.contains("%s"), "il segnaposto e' rimasto scritto a schermo: '%s'" % con_nome)
	var senza_nome: String = scontro.frase_di_stato(eroe, "Le fiamme si spengono.")
	esigi(senza_nome == "Le fiamme si spengono.",
			"una frase senza %%s e' stata cambiata: esce '%s'" % senza_nome)

	# TERRORE — indebolisce e toglie il critico
	eroe.stati_attivi = {}
	var attacco_sano := RegoleCombattimento.calcola_danno(eroe, nemico, 100, 1.0, 0)
	scontro.applica_stato(eroe, "terrore")
	esigi(RegoleCombattimento.critico_bloccato(eroe), "col Terrore addosso si fanno ancora critici")
	esigi(RegoleCombattimento.quota_attacco_dagli_stati(eroe) < 0.0,
			"il Terrore non indebolisce: la quota di attacco e' %f" % RegoleCombattimento.quota_attacco_dagli_stati(eroe))
	var attacco_atterrito := RegoleCombattimento.calcola_danno(eroe, nemico, 100, 1.0, 0)
	esigi(int(attacco_atterrito.danno) < int(attacco_sano.danno),
			"atterrito fa %d danni, sano ne faceva %d" % [int(attacco_atterrito.danno), int(attacco_sano.danno)])

	# FIAMME e TOSSINA — la stessa macchina, due tarature. Le Fiamme fanno di piu'
	eroe.stati_attivi = {}
	scontro.applica_stato(eroe, "fiamme")
	var danno_fiamme := int(eroe.stati_attivi["fiamme"].danno)
	eroe.stati_attivi = {}
	scontro.applica_stato(eroe, "tossina")
	var danno_tossina := int(eroe.stati_attivi["tossina"].danno)
	esigi(danno_fiamme > danno_tossina,
			"le Fiamme fanno %d e la Tossina %d: le Fiamme devono essere il piu' forte"
			% [danno_fiamme, danno_tossina])
	esigi(int(eroe.stati_attivi["tossina"].get("turni_rimasti", -1)) == 0,
			"la Tossina scade da sola: doveva restare fino a fine scontro o alla cura")
	esigi(RegoleCombattimento.quota_attacco_dagli_stati(eroe) < 0.0, "la Tossina non indebolisce")
	# e il danno scala con la vita massima, non e' un numero fisso
	eroe.stati_attivi = {}
	eroe.hp_max = 10000
	scontro.applica_stato(eroe, "fiamme")
	esigi(int(eroe.stati_attivi["fiamme"].danno) > danno_fiamme,
			"il danno delle Fiamme non scala con la vita massima: resta un numero fisso")
	eroe.hp_max = 1000

	# SONNO — massimo tre turni, e i colpi incassati alzano il risveglio
	eroe.stati_attivi = {}
	scontro.applica_stato(eroe, "sonno")
	esigi(int(eroe.stati_attivi["sonno"].turni_rimasti) <= 3, "il Sonno dura piu' di tre turni")
	scontro.registra_danno_subito(eroe, 5)
	scontro.registra_danno_subito(eroe, 5)
	esigi(int(eroe.stati_attivi["sonno"].colpi_nel_sonno) == 2,
			"i colpi incassati mentre dorme non vengono contati: scuoterlo non serve a niente")

	# MALEDIZIONE — riserva da 10, la consumano i colpi, e chi cade non si rialza
	eroe.stati_attivi = {}
	eroe.non_rianimabile = false
	scontro.applica_stato(eroe, "maledizione", 3)
	esigi(int(eroe.stati_attivi["maledizione"].riserva) == 7,
			"tre punti di maledizione su dieci hanno lasciato %d invece di 7"
			% int(eroe.stati_attivi["maledizione"].riserva))
	scontro.risolvi_stati_a_inizio_turno(eroe)
	esigi(int(eroe.stati_attivi["maledizione"].riserva) == 7,
			"la riserva e' scesa da sola passando un turno: doveva consumarla solo un colpo")
	scontro.applica_stato(eroe, "maledizione", 7)
	esigi(int(eroe.hp) <= 0, "la riserva e' arrivata a zero e non e' successo niente")
	esigi(bool(eroe.get("non_rianimabile", false)),
			"caduto per maledizione ma rianimabile: gli oggetti lo rimettono in piedi")

	# RABBIA e FRASTORNATO — tolgono le mosse
	eroe.hp = 1000
	eroe.non_rianimabile = false
	eroe.stati_attivi = {}
	esigi(not RegoleCombattimento.solo_attacchi(eroe), "senza stati addosso non puo' gia' usare le mosse")
	scontro.applica_stato(eroe, "rabbia")
	esigi(RegoleCombattimento.solo_attacchi(eroe), "con la Rabbia addosso si usano ancora le mosse")
	eroe.stati_attivi = {}
	scontro.applica_stato(eroe, "frastornato")
	esigi(RegoleCombattimento.solo_attacchi(eroe),
			"Frastornato lascia usare le mosse: doveva permettere solo attacchi")

	# PROVOCATO — puoi colpire solo chi ti ha provocato
	eroe.stati_attivi = {}
	eroe.id_provocatore = String(nemico.id)
	scontro.applica_stato(eroe, "provocato")
	esigi(RegoleCombattimento.bersaglio_obbligato(eroe) == String(nemico.id),
			"Provocato non ricorda chi l'ha provocato: 'solo lui' non vuol dire niente")
	var solo_lui: Array[Dictionary] = scontro.bersagli_ammessi(eroe, scontro.vivi(false))
	esigi(solo_lui.size() == 1 and String(solo_lui[0].id) == String(nemico.id),
			"provocato, ma puo' ancora scegliere fra %d bersagli" % solo_lui.size())
	scontro.free()

func prova_mediazione() -> void:
	# Bru: "in alcuni casi rari apparira' mediazione, solo dopo che dallo studio
	# sei riuscito a capire che quel determinato nemico vuole ascoltarti... non
	# sempre se sono nemici comuni medieranno, alcuni per natura non lo faranno,
	# quindi in quelli che mediano e' randomico se vogliono o meno".
	#
	# Tre cancelli in fila, e la prova li apre uno alla volta perche' se ne
	# saltasse uno la meccanica sembrerebbe funzionare lo stesso: chi non ha il
	# campo non media MAI (natura), chi ce l'ha ma stasera non vuole non media
	# (il tiro), chi vuole ma non l'hai ancora guardato abbastanza non media
	# ancora (lo studio). La parte piu' facile da rompere in silenzio e' la
	# terza: se il bottone comparisse subito, la mediazione smetterebbe di
	# essere una ricompensa dello studio e diventerebbe una scorciatoia.
	titolo("la mediazione: natura, volonta', studio")
	# lo script del combattimento non dichiara un class_name: per chiamarne le
	# statiche senza montare una scena si carica la risorsa
	var Scontro: GDScript = load("res://scripts/Combattimento.gd")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["tartaruga_innocente"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	# senza un limite l'orologio virtuale gira a vuoto per 4000 battute e
	# Godot stampa un errore: qui lo scontro serve solo come impalcatura
	scontro.limite_giri = 1
	add_child(scontro)
	var tartaruga: Dictionary = {}
	for combattente in scontro.combattenti:
		if not combattente.giocatore:
			tartaruga = combattente
	esigi(not tartaruga.is_empty(), "lo scontro non si e' montato")

	# CANCELLO 1 - la natura. Il Goblin non ha il campo: nessun tiro lo salva
	esigi(GameState.mediazione_di("goblin_tipico").is_empty(),
			"il goblin ha un campo mediazione che non dovrebbe avere")
	esigi(not Scontro.tira_volonta_di_mediare(GameState.personaggi["goblin_tipico"]),
			"una creatura senza campo mediazione ha comunque tirato per mediare")

	# CANCELLO 3 - lo studio. La Tartaruga vuole (probabilita' 1.0) ma finche'
	# non l'hai guardata il bottone non c'e'
	esigi(bool(tartaruga.vuole_mediare), "la Tartaruga a probabilita' 1.0 non vuole mediare")
	tartaruga.volte_studiato = 0
	esigi(not scontro.mediabile(tartaruga),
			"si media senza aver studiato: lo studio non serve piu' a niente")
	esigi(scontro.bersagli_mediabili().is_empty(),
			"il bottone Mediazione comparirebbe prima dello studio")
	tartaruga.volte_studiato = 1
	esigi(scontro.mediabile(tartaruga), "studiata quanto serve, non si riesce comunque a mediare")
	esigi(scontro.bersagli_mediabili().size() == 1, "il bottone Mediazione non compare dopo lo studio")

	# CANCELLO 2 - la volonta'. Stessa creatura, stessa scheda, ma stasera no
	tartaruga.vuole_mediare = false
	esigi(not scontro.mediabile(tartaruga),
			"media anche quando ha tirato che non vuole: il caso non conta niente")
	tartaruga.vuole_mediare = true

	# e mediare deve valere piu' che ammazzare, o nessuno lo fara' mai
	var xp_uccidendo := RegoleCombattimento.xp_effettiva(tartaruga)
	var xp_mediando := RegoleCombattimento.xp_da_risparmio(tartaruga)
	esigi(xp_mediando > xp_uccidendo,
			"mediare rende %d e uccidere %d: conviene picchiare" % [xp_mediando, xp_uccidendo])
	scontro.in_corso = true
	scontro.media(tartaruga)
	esigi(bool(tartaruga.get("risparmiato", false)), "mediata, ma non risulta risparmiata")
	esigi(int(tartaruga.hp) <= 0, "mediata, ma resta in campo a combattere")
	scontro.free()

	# i boss non mediano nemmeno se qualcuno gli scrive il campo per sbaglio
	var finto_boss := {"mediazione": {"probabilita": 1.0}, "invincibile": true}
	esigi(not Scontro.tira_volonta_di_mediare(finto_boss),
			"un invincibile si lascia mediare: lo scontro di copione si puo' saltare")
	var finto_scriptato := {"mediazione": {"probabilita": 1.0}, "incontro_scriptato": {}}
	esigi(not Scontro.tira_volonta_di_mediare(finto_scriptato),
			"un incontro scriptato si lascia mediare")

	# il tiro deve essere un tiro: su mille prove a 0.5 non puo' uscire
	# sempre la stessa risposta, o "randomico" e' una parola scritta e basta
	var meta := {"mediazione": {"probabilita": 0.5}}
	var si := 0
	for tentativo in 1000:
		if Scontro.tira_volonta_di_mediare(meta):
			si += 1
	esigi(si > 400 and si < 600,
			"probabilita' 0.5 ha dato %d si' su 1000: il tiro non e' un tiro" % si)
	var mai := {"mediazione": {"probabilita": 0.0}}
	for tentativo in 200:
		esigi(not Scontro.tira_volonta_di_mediare(mai),
				"probabilita' 0.0 ha comunque acconsentito")

func prova_menu_cinque_voci_fisse() -> void:
	# Bru: "tu hai un menu principale di combattimento: attacca, difendi,
	# abilita', oggetti, fuggi".
	#
	# Le cinque devono esserci SEMPRE, anche quando sono spente, perche' un menu
	# che cambia lunghezza e' un menu in cui il bottone che cercavi si e' spostato
	# sotto il dito. Le condizionali - Aiutante e Mediazione - vanno in fondo e
	# solo quando hanno qualcosa dietro.
	titolo("il menu di combattimento ha sempre le sue cinque voci")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	add_child(scontro)
	scontro.in_corso = true
	var contenitore := HBoxContainer.new()
	add_child(contenitore)
	var menu := MenuCombattimento.new(scontro, false)
	menu.collega(contenitore)
	menu.principale()
	var etichette: Array[String] = []
	for figlio in contenitore.get_children():
		etichette.append(String(figlio.text))
	for voce in ["Attacca", "Difendi", "Abilità", "Oggetti", "Fuggi"]:
		esigi(voce in etichette, "manca la voce '%s' dal menu: c'e' %s" % [voce, etichette])
	# contro un goblin, che non media e non porta aiutanti, le condizionali
	# non devono esserci: se comparissero sempre non sarebbero condizionali
	esigi(not ("Mediazione" in etichette),
			"Mediazione compare contro un nemico che non media: %s" % [etichette])
	esigi(not ("Aiutante" in etichette),
			"Aiutante compare senza nessun aiutante: %s" % [etichette])
	# e le cinque fisse stanno PRIMA delle condizionali, nell'ordine detto
	esigi(etichette.slice(0, 5) == ["Attacca", "Difendi", "Abilità", "Oggetti", "Fuggi"],
			"le cinque voci fisse non sono in testa nell'ordine giusto: %s" % [etichette])
	contenitore.free()
	scontro.free()

func prova_i_dominatori_non_sono_bestiario() -> void:
	# Bru: "Veronica non necessita di un entry nel bestiario ma di un entry nella
	# sezione dei dominatori". Toglierle la voce di tecno log non bastava: il
	# Bestiario in gioco elenca chiunque abbia un ruolo che combatte, e Veronica
	# combatte - quindi restava li' dentro con una scheda di dieci righe tutte
	# "non ancora rilevato". Combattere e finire nel bestiario sono due domande
	# diverse, e finche' se le faceva una funzione sola non potevano dare due
	# risposte diverse
	titolo("un dominatore combatte ma non finisce nel bestiario")
	var dominatori: Dictionary = GameState.tecnolog.get("dominatori", {})
	esigi(not dominatori.is_empty(), "nessun dominatore dichiarato")
	for id_dominatore in dominatori:
		var nome := String(id_dominatore)
		esigi(GameState.e_creatura(nome),
				"%s non risulta nemmeno capace di combattere: il tutorial la usa" % nome)
		esigi(not GameState.e_da_bestiario(nome),
				"%s e' ancora nel bestiario: la sua pagina sarebbe tutta 'non rilevato'" % nome)
		esigi(not GameState.tecnolog.get("voci", {}).has(nome),
				"%s ha ancora una voce di tecno log: le schede dei dominatori sono un'altra cosa" % nome)
		var scheda: Dictionary = dominatori[nome]
		for campo in GameState.tecnolog.get("campi_dominatore", []):
			var id_campo := String(campo.get("id", ""))
			if id_campo == "nome":
				continue   # e' quello del personaggio, non si scrive due volte
			esigi(String(scheda.get(id_campo, "")) != "",
					"%s non ha %s" % [nome, id_campo])
	# e una creatura normale invece ci deve stare
	esigi(GameState.e_da_bestiario("goblin_tipico"),
			"il Goblin Tipico e' sparito dal bestiario: il filtro dei dominatori prende troppo")

func prova_modalita_e_trasformazione() -> void:
	# Le quattro meccaniche del secondo giro: la forma in cui una creatura si
	# chiude per qualche battuta (Ouroboros, Autoriciclaggio), la trasformazione
	# annunciata, il tetto di usi, e la mossa che ne lascia addosso due
	titolo("le forme, le trasformazioni e i tetti d'uso")
	GameState.nuova_partita()
	GameState.legame = 0
	GameState.nemici_combattimento = ["divoratore"]
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
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro di prova non si e' montato")

	# 1. LA MODALITA' LAVORA A OGNI SUA BATTUTA, e finisce quando deve
	nemico.hp = maxi(int(float(nemico.hp_max) * 0.5), 1)
	var vita_prima := int(nemico.hp)
	var attacco_prima := RegoleCombattimento.attacco_di(nemico)
	scontro.esegui_mossa(nemico, {"id": "prova_forma", "tipo": "modalita", "testo": "-",
			"durata": 3, "immune": true,
			"per_battuta": {"stat": {"attacco": 3}, "cura_quota": 0.1}})
	esigi(not Dictionary(nemico.get("modalita", {})).is_empty(), "la forma non si e' accesa")
	esigi(int(nemico.get("turni_immune", 0)) > 0,
			"la forma dice 'intoccabile' e non ha reso immune nessuno")
	scontro.avanza_modalita(nemico)
	esigi(int(nemico.hp) > vita_prima, "una battuta di forma non ha curato niente")
	esigi(RegoleCombattimento.attacco_di(nemico) > attacco_prima,
			"una battuta di forma non ha alzato l'attacco")
	scontro.avanza_modalita(nemico)
	scontro.avanza_modalita(nemico)
	esigi(Dictionary(nemico.get("modalita", {})).is_empty(),
			"dopo tre battute la forma e' ancora accesa: 'per 3 turni' non finisce mai")
	esigi(RegoleCombattimento.attacco_di(nemico) == attacco_prima,
			"finita la forma, il potenziamento e' rimasto: una forma a tempo diventa per sempre")

	# 2. NON CI SI CHIUDE DUE VOLTE
	var forma := {"id": "prova_forma2", "tipo": "modalita", "testo": "-", "durata": 3}
	scontro.esegui_mossa(nemico, forma)
	esigi(not scontro.mossa_eseguibile(nemico, forma),
			"puo' richiudersi mentre e' gia' chiusa: sarebbe una battuta a vuoto")
	nemico.modalita = {}

	# 3. LA CONDIZIONE "SOLO DOPO QUELL'ALTRA MOSSA"
	var seguito := {"id": "prova_seguito", "tipo": "modalita", "testo": "-", "durata": 2,
			"quando": {"dopo_mossa": "prova_prima"}}
	nemico.mosse_usate = []
	esigi(not scontro.condizioni_mossa(nemico, seguito),
			"il seguito e' disponibile senza che la mossa che lo precede sia mai partita")
	nemico.mosse_usate = ["prova_prima"]
	esigi(scontro.condizioni_mossa(nemico, seguito),
			"fatta la prima, il seguito non si sblocca lo stesso")

	# 4. IL TETTO D'USO: due volte si', la terza no
	var bis := {"id": "prova_bis", "tipo": "cura", "testo": "-", "quota_vita": 0.1,
			"massimo_usi": 2}
	nemico.mosse_usate = []
	nemico.hp = maxi(int(float(nemico.hp_max) * 0.5), 1)
	esigi(scontro.mossa_disponibile(nemico, bis), "al primo giro il bis non c'e'")
	scontro.esegui_mossa(nemico, bis)
	nemico.hp = maxi(int(float(nemico.hp_max) * 0.5), 1)
	esigi(scontro.mossa_disponibile(nemico, bis), "al secondo giro il bis e' gia' sparito")
	scontro.esegui_mossa(nemico, bis)
	nemico.hp = maxi(int(float(nemico.hp_max) * 0.5), 1)
	esigi(not scontro.mossa_disponibile(nemico, bis),
			"al terzo giro il bis c'e' ancora: 'massimo 2 volte' non tiene")

	# 5. UNA MOSSA CHE NE LASCIA ADDOSSO DUE
	eroe.stati_attivi = {}
	scontro.esegui_mossa(nemico, {"id": "prova_assolo", "tipo": "stato", "testo": "-",
			"stati": ["frastornato", "rabbia"]})
	esigi(eroe.stati_attivi.size() >= 2,
			"l'assolo ha lasciato addosso %d stati invece di due" % eroe.stati_attivi.size())

	# 6. LA TRASFORMAZIONE: annuncia, conta, e poi entra un'altra creatura
	var quanti_prima: int = scontro.combattenti.size()
	scontro.esegui_mossa(nemico, {"id": "prova_trasf", "tipo": "trasformazione", "testo": "-",
			"diventa": "golem_errante", "battute": 2})
	esigi(not Dictionary(nemico.get("trasformazione", {})).is_empty(),
			"la trasformazione non e' stata annunciata")
	scontro.avanza_trasformazione(nemico)
	esigi(scontro.combattenti.size() == quanti_prima,
			"si e' trasformato subito: l'annuncio non serviva a niente")
	scontro.avanza_trasformazione(nemico)
	esigi(scontro.combattenti.size() > quanti_prima,
			"finito il conto non e' entrato niente in campo: la trasformazione non trasforma")
	esigi(int(nemico.hp) <= 0, "quello di prima e' ancora in piedi: adesso ce ne sono due")

	# 7. CHI SI TRASFORMA NON PAGA I PREMI DI CHI E' STATO BATTUTO. La creatura
	# trasformata resta in campo a zero punti vita, che e' la stessa forma in cui
	# la battaglia conta i caduti: senza una riga che la distingua, abbattere il
	# Golem incassava anche l'esperienza, i Tazo e il bottino dei Rottami da cui
	# era nato. Due premi per un nemico solo, e in silenzio
	esigi(bool(nemico.get("trasformato", false)),
			"la creatura trasformata non si e' segnata come tale: verra' contata fra i caduti")

	# 8. L'IMMUNITA' DELLA FORMA FINISCE QUANDO FINISCE LA FORMA
	var chiuso: Dictionary = {}
	for combattente in scontro.combattenti:
		if not combattente.giocatore and int(combattente.hp) > 0:
			chiuso = combattente
			break
	if not chiuso.is_empty():
		chiuso.modalita = {}
		chiuso.turni_immune = 0
		scontro.esegui_mossa(chiuso, {"id": "prova_scudo", "tipo": "modalita", "testo": "-",
				"durata": 2, "immune": true, "per_battuta": {"stat": {"attacco": 1}}})
		scontro.avanza_modalita(chiuso)
		chiuso.turni_immune = int(chiuso.turni_immune) - 1
		scontro.avanza_modalita(chiuso)
		chiuso.turni_immune = maxi(int(chiuso.turni_immune) - 1, 0)
		esigi(Dictionary(chiuso.get("modalita", {})).is_empty(),
				"dopo due battute la forma e' ancora accesa")
		esigi(int(chiuso.get("turni_immune", 0)) <= 0,
				"la forma e' finita ma resta intoccabile per %d battute: i colpi spariscono senza motivo"
				% int(chiuso.get("turni_immune", 0)))
	scontro.free()

func fotografia(scontro: Node, eroe: Dictionary, nemico: Dictionary) -> String:
	# tutto quello che una mossa puo' cambiare, in una riga. Se dopo la battuta
	# di una creatura questa riga e' identica a prima, quella battuta non e'
	# servita a niente - e non c'e' nessun altro modo di accorgersene, perche'
	# una mossa a vuoto scrive la sua frase esattamente come una che funziona
	var stati_addosso := 0
	var vivi_di_la := 0
	for combattente in scontro.combattenti:
		if combattente.giocatore:
			stati_addosso += combattente.stati_attivi.size()
		elif int(combattente.hp) > 0:
			vivi_di_la += 1
	return "%d/%d/%d/%d/%d/%d/%s/%s" % [
		int(eroe.hp), int(nemico.hp), stati_addosso, vivi_di_la,
		RegoleCombattimento.scatti_difesa(nemico), int(nemico.buffs.size()),
		str(bool(eroe.get("in_fiamme", false))),
		str(not Dictionary(nemico.get("mossa_in_carica", {})).is_empty()),
	]

func prova_tecnolog_completo() -> void:
	# Lo schema che ha chiesto Bru, dopo la sua passata di correzioni:
	# Denominazione, Classificazione, Filogenesi, Areale, SPECIE (era Fenotipo),
	# Stadio, Morfologia, Habitus, Metamorfosi, Ecologia. Fisiologia ed Etologia
	# sono uscite: "e' di troppo". Dieci campi sono una promessa dieci volte -
	# basta che una creatura ne abbia nove e la sua pagina, in gioco, ha un buco,
	# e non lo vedi finche' non la studi.
	titolo("il tecno log e' completo per ogni creatura, e i termini sono quelli")
	var vocabolari: Dictionary = GameState.tecnolog.get("vocabolari", {})
	esigi(not vocabolari.is_empty(), "il tecnolog non dichiara nessun vocabolario")
	var campi: Array = GameState.campi_tecnolog()
	var presenti: Array[String] = []
	for campo in campi:
		presenti.append(String(campo.get("id", "")))
	for atteso in ["denominazione", "classificazione", "filogenesi", "areale", "specie",
			"stadio", "morfologia", "habitus", "metamorfosi", "ecologia"]:
		esigi(atteso in presenti, "lo schema non ha il campo '%s'" % atteso)
	# e quelli che Bru ha TOLTO devono restare fuori: un campo che rientra in
	# silenzio si riprende trenta righe di prosa che nessuno rileggera' piu'
	for tolto in ["fenotipo", "fisiologia", "etologia"]:
		esigi(tolto not in presenti,
				"'%s' e' tornato nello schema: Bru l'aveva tolto" % tolto)
	var strati: Array[int] = []
	for campo in campi:
		esigi(String(campo.get("etichetta", "")) != "",
				"il campo %s non ha un'etichetta" % String(campo.get("id", "?")))
		var strato := int(campo.get("strato", 0))
		esigi(strato >= 1, "il campo %s non dice a quale studio si rivela" % String(campo.get("id", "?")))
		if strato not in strati:
			strati.append(strato)
	esigi(strati.size() >= 3,
			"i campi si rivelano in %d strati: cosi' studiare la seconda volta non aggiunge niente"
			% strati.size())
	var guardate := 0
	var vuoto := String(GameState.tecnolog.get("non_rilevato", "—"))
	for id_creatura in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_creatura]
		if not dati.has("ruolo") or String(dati.get("ruolo", "")) == "oggetto_scena":
			continue
		if dati.get("dominatore", false):
			continue   # ha una scheda sua, con campi suoi: non e' un tecno log
		guardate += 1
		for riga in GameState.tecnolog_di(String(id_creatura)):
			if String(riga.get("id", "")) == "areale":
				# L'AREALE PUO' ESSERE VUOTO PER DAVVERO, ed e' un'informazione:
				# vuol dire che quella creatura non e' ancora stata messa in
				# nessuna stanza e non ha una regione scritta a mano. Che il
				# conto funzioni lo garantisce la soglia qui sotto
				continue
			esigi(String(riga.get("valore", "")) != vuoto,
					"%s: il campo %s del tecno log e' vuoto"
					% [id_creatura, String(riga.get("etichetta", "?"))])
			esigi(String(riga.get("valore", "")) != "",
					"%s: il campo %s e' una stringa vuota" % [id_creatura, String(riga.get("etichetta", "?"))])
		# IL LESSICO SI CONTROLLA PER CAMPO, NON PER NOME DEL VOCABOLARIO. La
		# prima versione girava sui vocabolari e cercava una chiave con lo stesso
		# nome nella voce: cosi' la Classificazione, che pesca dal vocabolario
		# "rango", non veniva guardata da nessuno - e "Rango Base", "rango base"
		# e "Rango base" passavano tutte e tre
		var voce: Dictionary = GameState.tecnolog.get("voci", {}).get(id_creatura, {})
		for campo in campi:
			var id_campo := String(campo.get("id", ""))
			var nome_vocabolario := String(campo.get("vocabolario", ""))
			if nome_vocabolario == "" or not voce.has(id_campo):
				continue
			esigi(String(voce[id_campo]) in Array(vocabolari.get(nome_vocabolario, [])),
					"%s ha %s '%s', che non e' fra i termini ammessi: cosi' ogni creatura si inventa il suo lessico e la scheda non si legge piu' di fila"
					% [id_creatura, id_campo, String(voce[id_campo])])
	esigi(guardate >= 30, "la prova ha guardato solo %d creature" % guardate)
	# e l'areale dev'essere PIENO per quasi tutte: se il conto smettesse di
	# leggere una delle chiavi in cui una zona elenca le sue creature, il
	# documento continuerebbe a uscire - solo, con meta' bestiario senza casa.
	# E' successo: guardava "nemici" e "gruppi" e si perdeva "combatti", cioe'
	# quasi tutti i boss
	var con_casa := 0
	for id_creatura in GameState.personaggi:
		var scheda: Dictionary = GameState.personaggi[id_creatura]
		if not scheda.has("ruolo") or String(scheda.get("ruolo", "")) == "oggetto_scena":
			continue
		if GameState.areale_di(String(id_creatura)) != vuoto:
			con_casa += 1
	esigi(con_casa >= guardate * 3 / 4,
			"solo %d creature su %d hanno un areale: il conto non sta leggendo tutte le chiavi con cui una zona elenca le sue creature"
			% [con_casa, guardate])

func prova_areale_e_la_regione_grande() -> void:
	# Bru: "l'areale non e' la zona specifica ma quella generica: l'Oppresso si
	# trova nella frattura industriale, che e' solo una parte di una zona molto
	# piu' grande, il pianeta Geodos". Il rischio di questa modifica e' che sia
	# INERTE - la tabella c'e', nessuno la legge, e il documento continua a
	# stampare il nome della stanza senza che niente si lamenti.
	titolo("l'areale e' la regione grande, non la stanza in cui la incontri")
	var per_zona: Dictionary = GameState.tecnolog.get("areale_per_zona", {})
	esigi(not per_zona.is_empty(), "non c'e' nessuna traduzione da zona a regione")
	# OGNI zona della mappa dev'essere nella tabella: una frattura nuova che non
	# c'e' finisce nel documento col proprio nome, e nessuno se ne accorge
	var mappa: Variant = GameState.carica_json("res://data/mappa.json")
	var zone: Dictionary = {}
	GameState.raccogli_zone(mappa, zone)
	for percorso in zone:
		esigi(String(zone[percorso]) in per_zona,
				"la zona '%s' non ha una regione in areale_per_zona: la sua gente finirebbe con l'areale sbagliato"
				% String(zone[percorso]))
	# E LA TRADUZIONE DEVE FUNZIONARE DAVVERO: chi vive nello Squarcio dice
	# Geodos. La prova non puo' appoggiarsi a una creatura scelta a mano - le
	# prime due versioni lo facevano e sono morte tutte e due nel giro di un
	# giorno: la prima guardava l'Operaio Sfruttato, che ha "Geodos" scritto
	# nella voce e quindi passava anche senza traduzione; la seconda guardava il
	# Divoratore, e Bru gli ha scritto l'areale il giorno dopo. Quindi si toglie
	# la mano di dosso per un istante e si misura il meccanismo nudo
	var voce: Dictionary = GameState.tecnolog.get("voci", {}).get("divoratore", {})
	var scritto: Variant = voce.get("areale", null)
	voce.erase("areale")
	var dedotto := GameState.areale_di("divoratore")
	if scritto != null:
		voce["areale"] = scritto
	esigi(dedotto.contains("Geodos"),
			"dedotto dalle zone, il Divoratore ha areale '%s': lo Squarcio Industriale e' una frattura di Geodos, e la scheda deve dire il mondo"
			% dedotto)
	esigi(not dedotto.contains("Squarcio"),
			"l'areale dedotto dice ancora '%s': e' il nome della stanza, non della regione" % dedotto)
	# la mano vince sulla mappa, perche' dove una specie VIVE puo' essere piu'
	# grande di dove il gioco ti porta a incontrarla
	var slime := GameState.areale_di("slime_infimo")
	esigi(slime.contains("Gombok 2"),
			"lo Slime ha areale '%s': la sua voce ne dichiara tre, e l'areale scritto a mano deve vincere su quello dedotto"
			% slime)

func prova_tecnolog_si_riempie_studiando() -> void:
	# LA PARTE CHE VALE: la scheda non c'e' finche' non la si studia, e si
	# riempie A STRATI. Se uscisse tutta al primo studio, studiare due volte
	# sarebbe pignoleria; se non uscisse mai, sarebbe un file di testo.
	titolo("il tecno log si riempie studiando, uno strato per volta")
	GameState.nuova_partita()
	GameState.rilevamenti.clear()
	var cavia := "ghoul"
	var vuoto := String(GameState.tecnolog.get("non_rilevato", "—"))

	# 1. DA NON STUDIATA, NIENTE. Nemmeno la filogenesi, che pure il gioco sa
	for riga in GameState.tecnolog_di(cavia, 0):
		esigi(String(riga.get("valore", "")) == vuoto,
				"senza aver studiato niente si legge gia' %s" % String(riga.get("etichetta", "")))

	# 2. UN SOLO STUDIO apre il primo strato e non gli altri
	var aperti_al_primo := 0
	for riga in GameState.tecnolog_di(cavia, 1):
		if int(riga.get("strato", 1)) == 1:
			esigi(String(riga.get("valore", "")) != vuoto,
					"dopo il primo studio %s e' ancora vuoto" % String(riga.get("etichetta", "")))
			aperti_al_primo += 1
		else:
			esigi(String(riga.get("valore", "")) == vuoto,
					"il primo studio ha gia' aperto %s, che sta a uno strato piu' in la'"
					% String(riga.get("etichetta", "")))
	esigi(aperti_al_primo >= 3, "il primo studio apre %d campi soli" % aperti_al_primo)

	# 3. LA FILOGENESI C'E', ed e' la cosa che Bru ha chiesto per prima: da quale
	#    corpo viene. Creature nate da corpi diversi devono dirlo
	var filo_ghoul := GameState.valore_tecnolog("ghoul", "filogenesi")
	var filo_bestia := GameState.valore_tecnolog("divoratore_di_carcasse", "filogenesi")
	var filo_macchina := GameState.valore_tecnolog("robo_pattuglia", "filogenesi")
	esigi(filo_ghoul == "umana",
			"il ghoul risulta di filogenesi '%s': e' un corpo umano marcito" % filo_ghoul)
	esigi(filo_bestia != filo_ghoul and filo_macchina != filo_ghoul,
			"tre creature nate da corpi diversi hanno tutte la stessa filogenesi: il campo non distingue niente")

	# 4. L'AREALE NON E' SCRITTO A MANO: esce da dove la creatura compare davvero
	var areale := GameState.areale_di("ghoul")
	esigi(areale != vuoto and areale.length() > 3,
			"l'areale del ghoul e' vuoto: nessuna zona lo dichiara, o il conto non le legge")
	# e un BOSS, che una zona non elenca fra i suoi mostri vaganti ma dentro il
	# nodo in cui lo si affronta. E' la chiave che il conto si perdeva - guardava
	# "nemici" e "gruppi" e non "combatti" - e senza questa riga la cosa non si
	# vedeva: restavano abbastanza creature con la casa da far passare la soglia
	esigi(GameState.areale_di("jongo_dongo") != vuoto,
			"il signore della Rocca non ha un areale: il conto non legge la chiave con cui una stanza dichiara lo scontro che ci si combatte")
	esigi(GameState.areale_di("non_esiste_questa_creatura") == vuoto,
			"una creatura che non compare da nessuna parte ha comunque un areale")

	# 5. E LA METAMORFOSI DICE 'osservata' SOLO SE L'HAI VISTA. E' il tuo
	#    registro: finche' non incontri la seconda forma, non l'hai osservata
	GameState.bestiario.erase("jongo_dongo_risorto")
	esigi(GameState.metamorfosi_di("jongo_dongo") == "non osservata",
			"la metamorfosi risulta osservata senza aver mai incontrato la seconda forma")
	GameState.registra_bestiario("jongo_dongo_risorto")
	esigi(GameState.metamorfosi_di("jongo_dongo") == "osservata",
			"incontrata la seconda forma, la metamorfosi risulta ancora non osservata")

	# 6. E STUDIANDO IN COMBATTIMENTO IL CONTO SALE, e resta fra uno scontro e
	#    l'altro: i numeri di una creatura si riscoprono ogni volta, quello che
	#    si sa della SPECIE no
	GameState.rilevamenti.clear()
	GameState.nemici_combattimento = [cavia]
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
	esigi(not eroe.is_empty() and not nemico.is_empty(), "lo scontro di prova non si e' montato")
	scontro.in_corso = true
	eroe.hp = eroe.hp_max
	nemico.hp = nemico.hp_max
	esigi(GameState.volte_studiato(cavia) == 0,
			"il conto dei rilevamenti parte da %d" % GameState.volte_studiato(cavia))
	scontro.studia(eroe, nemico)
	esigi(GameState.volte_studiato(cavia) == 1,
			"dopo uno studio i rilevamenti sono %d" % GameState.volte_studiato(cavia))
	scontro.studia(eroe, nemico)
	esigi(GameState.volte_studiato(cavia) == 2,
			"il secondo studio non ha aperto il secondo strato (rilevamenti: %d)"
			% GameState.volte_studiato(cavia))
	scontro.free()
	esigi(GameState.volte_studiato(cavia) == 2,
			"finito lo scontro il tecno log si e' dimenticato quello che sapeva")
	GameState.nuova_partita()
	esigi(GameState.volte_studiato(cavia) == 2,
			"a partita nuova il tecno log riparte da zero: e' una collezione meta, come il bestiario")
	GameState.rilevamenti.clear()

func prova_il_drop_c_e_sempre() -> void:
	# Bru: "il sistema di drop deve creare dipendenza, il drop deve sempre
	# esserci, ogni nemico droppa qualcosa di suo". La dipendenza non nasce dai
	# premi grossi: nasce dal fatto che NON ESCE MAI NIENTE. Dieci scontri di
	# fila a mani vuote e non si combatte piu' volentieri, e nessuna tabella di
	# bilanciamento se ne accorge - il gioco resta "equilibrato" e smette di
	# tirare.
	titolo("ogni creatura lascia sempre qualcosa")
	GameState.nuova_partita()
	var elenco := creature()
	esigi(elenco.size() > 30, "l'elenco delle creature si e' svuotato")
	for id_creatura in elenco:
		# non una volta: cento, perche' un pavimento che regge il 99% delle
		# volte non e' un pavimento
		for tentativo in 100:
			var lascia := GameState.drop_garantito_di(id_creatura)
			esigi(not lascia.is_empty(), "%s non lascia niente" % id_creatura)
			if lascia.is_empty():
				break
			var tipo := String(lascia.get("tipo", ""))
			esigi(tipo in ["tazo", "oggetto"],
					"%s lascia qualcosa di tipo '%s', che nessuno sa raccogliere" % [id_creatura, tipo])
			esigi(int(lascia.get("quanti", 0)) >= 1,
					"%s lascia zero unita' di qualcosa: e' come non lasciare niente" % id_creatura)
			if tipo == "oggetto":
				esigi(GameState.oggetti.has(String(lascia.get("oggetto", ""))),
						"%s lascia '%s', che non esiste fra gli oggetti"
						% [id_creatura, String(lascia.get("oggetto", ""))])

	# LA PILA: si accumula, ha un tetto per tipo, e la cianfrusaglia ne ha uno suo
	esigi(GameState.oggetti.has("cianfrusaglia"), "la cianfrusaglia non esiste")
	esigi(GameState.e_da_pila("cianfrusaglia"), "la cianfrusaglia non finisce nella pila")
	esigi(GameState.cap_pila("cianfrusaglia") == 999,
			"la cianfrusaglia si ferma a %d invece che a 999" % GameState.cap_pila("cianfrusaglia"))
	esigi(GameState.quanti_nella_pila("cianfrusaglia") == 0, "la pila non parte vuota")
	GameState.aggiungi_alla_pila("cianfrusaglia", 5)
	esigi(GameState.quanti_nella_pila("cianfrusaglia") == 5,
			"cinque cianfrusaglie ne fanno %d" % GameState.quanti_nella_pila("cianfrusaglia"))
	var entrate := GameState.aggiungi_alla_pila("cianfrusaglia", 2000)
	esigi(GameState.quanti_nella_pila("cianfrusaglia") == 999,
			"la pila ha sfondato il tetto: %d" % GameState.quanti_nella_pila("cianfrusaglia"))
	esigi(entrate == 994, "il conto di quante ne sono entrate e' sbagliato: %d" % entrate)
	esigi(GameState.aggiungi_alla_pila("cianfrusaglia", 10) == 0,
			"al tetto entrano ancora oggetti")
	esigi(GameState.togli_dalla_pila("cianfrusaglia", 999) == 999, "non si svuota la pila")
	esigi(GameState.quanti_nella_pila("cianfrusaglia") == 0, "svuotata, la pila conta ancora qualcosa")
	# e non ruba spazio alla sacca: e' proprio il punto di essere uno scomparto a parte
	var sacca_prima := GameState.sacca.size()
	GameState.aggiungi_oggetto("cianfrusaglia")
	esigi(GameState.sacca.size() == sacca_prima,
			"la cianfrusaglia e' finita nella sacca: riempirebbe lo spazio dei consumabili")
	esigi(GameState.quanti_nella_pila("cianfrusaglia") == 1,
			"raccolta, la cianfrusaglia non e' finita nella pila")

	# IL FRAMMENTO DI VITA rigenera per piu' battute, e poco per volta
	var frammento: Dictionary = GameState.dati_oggetto("frammento_di_vita")
	esigi(not frammento.is_empty(), "il frammento di vita non esiste")
	var effetto: Dictionary = frammento.get("effetto", {})
	esigi(int(effetto.get("rigenerazione_battute", 0)) == 3,
			"il frammento rigenera per %d battute invece di 3" % int(effetto.get("rigenerazione_battute", 0)))
	esigi(absf(float(effetto.get("rigenerazione_percentuale", 0.0)) - 0.10) < 0.001,
			"il frammento rimette a posto il %d%% invece del 10%%"
			% int(float(effetto.get("rigenerazione_percentuale", 0.0)) * 100))
	# e in campo funziona davvero
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	add_child(scontro)
	var eroe: Dictionary = {}
	for combattente in scontro.combattenti:
		if combattente.giocatore and eroe.is_empty():
			eroe = combattente
	eroe.hp = int(eroe.hp_max) / 2
	scontro.applica_effetto(eroe, effetto)
	esigi(int(eroe.get("rigenerazione_battute", 0)) == 3,
			"il frammento non ha aperto nessuna rigenerazione")
	var vita_prima := int(eroe.hp)
	scontro.risolvi_rigenerazione_frammento(eroe)
	esigi(int(eroe.hp) > vita_prima, "la prima battuta di rigenerazione non ha curato niente")
	esigi(int(eroe.hp) - vita_prima <= int(eroe.hp_max) / 5,
			"una battuta ha rimesso a posto piu' di un quinto della vita: non e' 'poca'")
	for battuta in 5:
		scontro.risolvi_rigenerazione_frammento(eroe)
	esigi(int(eroe.get("rigenerazione_battute", 0)) == 0,
			"la rigenerazione non finisce mai: sono tre battute, non per sempre")
	scontro.free()
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
			"astio", "vendetta", "annichilazione", "pieta", "mantra", "flagello", "mattanza",
			# i sette che servono a Veronica e Yhvina. Sono pochi apposta: le
			# loro trentasei mosse sono trentasei tarature di questi, non
			# trentasei funzioni - e restano nove personaggi da scrivere
			"guardia", "copertura", "immunita", "rianima", "ultima_resistenza",
			"evoca_alleato", "passiva"]
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
		for chiave in ["testo_uso", "testo_ko", "testo_niente", "testo_inutile",
				"testo_carica", "testo_fine"]:
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
	# il costo dev'essere pagabile: un'abilita' che costa piu' delil tormento massima
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
