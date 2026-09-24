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

const ICONE_MAPPA := ["boss", "miniboss", "forte", "uscita", "negozio", "personaggio", "chiave", "obiettivo"]

var fallimenti: Array[String] = []
var conteggio := 0

func _ready() -> void:
	print("\n=== PROVE CARNIVALZ ===\n")
	prova_dati_caricati()
	prova_riferimenti_eventi()
	prova_nodi_raggiungibili()
	prova_riferimenti_creature()
	prova_i_punti_di_riferimento()
	prova_ogni_cancello_ha_una_chiave()
	prova_ogni_oggetto_richiesto_si_trova()
	prova_agguati()
	prova_agguati_hanno_una_via_duscita()
	prova_riferimenti_oggetti()
	prova_negozi()
	prova_appunti()
	prova_mappe()
	prova_equipaggiamento()
	prova_crescita()
	prova_salvataggio()
	prova_il_salvataggio_rende_i_numeri_e_il_dado_come_erano()
	await prova_il_motore_si_comporta_come_il_codice_crede()
	prova_una_partita_rovinata_si_riprende()
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
	prova_a_turni_ognuno_agisce_una_volta_per_giro()
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
	prova_larena_reagisce()
	prova_il_tipo_si_vede_sul_colpo()
	prova_resistere_non_e_essere_immuni()
	prova_il_tetto_alla_cura_di_se()
	prova_la_vita_bassa_si_annuncia()
	prova_i_sogni_di_yhvina()
	prova_chi_e_a_terra_non_viene_piu_colpito()
	await prova_le_scelte_a_tempo()
	await prova_il_nastro_col_nome()
	await prova_maschile_e_femminile()
	prova_dall_introduzione_al_combattimento()
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
	prova_i_quadratini_della_mappa_si_vedono_davvero()
	prova_ogni_segno_della_mappa_si_vede()
	prova_i_nomi_delle_stanze_si_leggono_senza_mouse()
	await prova_la_sede_si_legge_e_ci_sta_nello_schermo()
	prova_una_raffica_alla_volta()
	await prova_la_raffica_ha_un_riquadro_suo()
	await prova_il_pugno_si_para_quando_premi()
	prova_le_curve_del_movimento()
	prova_le_molle_di_material()
	prova_la_cascata_chiude_con_l_azione_principale()
	prova_la_gelatina_e_la_scossa()
	await prova_il_contenitore_raddrizza_i_figli()
	prova_il_menu_di_pausa_si_muove_ma_non_fa_aspettare()
	prova_il_movimento_ridotto_toglie_i_movimenti_non_le_voci()
	await prova_la_voce_inerte_dice_di_no()
	await prova_il_menu_principale_ha_piu_passi()
	await prova_il_menu_principale_sta_dove_sta_nel_riferimento()
	prova_nel_menu_principale_la_scelta_e_l_unica_cosa_calda()
	await prova_la_voce_col_segno_e_la_macchia()
	await prova_ogni_passo_del_menu_torna_indietro()
	await prova_senza_nome_si_chiede_se_restare_anonimo()
	await prova_come_si_gioca_disegna_i_tasti_veri()
	await prova_le_collezioni_tornano_indietro()
	await prova_ogni_cosa_ha_il_suo_spazio()
	await prova_un_numero_che_si_anima_non_fa_mai_aspettare()
	await prova_i_tazo_si_vedono_scendere_ma_non_fanno_aspettare()
	await prova_la_forma_del_testo()
	await prova_chi_ti_rigetta_fuori_non_ti_tiene_fermo()
	prova_giornata_dopo_allenamento()
	await prova_la_prima_missione_si_sceglie_sulla_mappa()
	await prova_da_un_altra_schermata_arriva_il_nodo_giusto()
	await prova_l_icona_del_menu_si_preme_anche_mentre_si_legge()
	await prova_arrivando_nelle_pianure_la_guida_spiega_la_mappa()
	prova_le_pianure_si_esplorano_fino_alla_tartaruga()
	prova_chi_tende_l_imboscata_muove_per_primo()
	prova_l_orda_dice_cosa_sta_per_fare()
	prova_l_onda_psichica_tira_per_ogni_componente()
	await prova_la_tua_battuta_si_apre_anche_dal_menu()
	prova_nelle_pianure_non_si_scappa()
	prova_il_bond_con_la_tartaruga()
	await prova_bond_si_preme()
	prova_la_caverna_si_apre_guardando()
	prova_il_promontorio_come_lo_ha_scritto_bru()
	prova_l_apparizione_si_batte_solo_con_la_pietra()
	await prova_il_promontorio_non_ti_lascia_andare_e_poi_ti_ferma()
	await prova_la_guida_ferma_il_mondo_mentre_parla()
	await prova_il_goblin_del_pasto_si_gioca_a_turni_dallo_schermo()
	await prova_osservando_la_scena_si_trova_la_caverna()
	prova_il_contrasto_si_vince_premendo()
	prova_la_mazzata_pesa_come_ha_detto_bru()
	await prova_la_mazzata_dal_vivo_si_prende_la_barra_spaziatrice()
	await prova_gli_evocati_hanno_un_quadratino_loro()
	prova_il_goblin_arrabbiato_e_lungo_ma_battibile()
	prova_la_musica_giusta_per_ogni_scontro_e_livello()
	await prova_nel_complesso_si_va_dritti()
	prova_l_impaginatore_taglia_dove_si_legge()
	await prova_ogni_testo_entra_nel_box()
	await prova_le_pagine_si_girano_col_click()
	prova_nome_del_data_pad()
	await prova_velo_di_pericolo()
	prova_le_liste_del_menu()
	prova_il_box_racconta_nel_quadrante()
	prova_data_pad_e_proiezione()
	prova_ritorno_dalla_missione()
	await prova_osserva_la_scena_c_e_gia_alla_prima_visita()
	prova_la_mappa_non_si_apre_prima_di_essere_spiegata()
	await prova_un_solo_artwork_quello_di_chi_parla()
	await prova_una_fase_alla_volta_e_niente_click_a_vuoto()
	prova_tenere_premuto_non_e_martellare()
	prova_la_raffica_si_para_anche_da_tastiera()
	prova_il_guasto_dell_ecg_segue_la_vita()
	await prova_la_vita_scende_animata_e_lascia_la_scia()
	await prova_il_click_dato_presto_non_si_perde()
	await prova_la_lezione_si_salta_solo_a_chi_l_ha_gia_fatta()
	await prova_l_azione_in_attesa_si_vede_a_schermo()
	await prova_non_si_puo_anticipare_la_lezione()
	await prova_l_evidenziazione_indica_un_pezzo_vero()
	await prova_la_raffica_del_tutorial_parte_davvero()
	await prova_dopo_la_raffica_resti_in_piedi_e_il_finale_si_legge()
	prova_la_raffica_accelera_verso_la_fine()
	await prova_l_allenamento_non_si_pianta_al_primo_colpo()
	prova_il_metro_del_garbuglio_e_quello_giusto()
	prova_nessuna_bandiera_letta_e_mai_scritta()
	prova_il_tetto_alla_struttura()
	prova_il_dispatch_delle_mosse_e_cablato_bene()
	prova_ogni_tipo_di_mossa_ce_l_ha_qualcuno()
	prova_ogni_mossa_si_esegue_davvero()
	prova_la_rete_dei_dati_non_ha_buchi()
	await prova_orologio_delle_scelte()
	prova_minigioco_ai_bordi()
	prova_combattimento_sotto_stress()
	await prova_la_giornata_passo_per_passo()
	await prova_la_scena_cambia_mentre_si_legge()
	prova_si_salva_solo_fuori_dalle_fratture()
	prova_il_checkpoint_non_ti_lascia_dentro()
	await prova_ecg_anello_e_riposo()
	await prova_l_ecg_non_si_apre_su_una_riga_piatta()
	prova_niente_disco_dentro_un_disegno()
	await prova_il_disco_si_interroga_una_volta()
	await prova_due_svuotamenti_non_si_pestano()
	prova_svuotare_svuota_subito()
	await prova_le_scelte_non_raddoppiano()
	await prova_un_messaggio_si_annuncia()
	await prova_flag_su_una_battuta()
	prova_orde()
	prova_orda_in_campo()
	prova_niente_nemici_misti()
	prova_condizione_di_chi_ha_il_turno()
	prova_chi_tocca_si_accende()
	prova_mattanza_e_bond_non_spariscono()
	await prova_lampo_solo_sulla_faccia()
	prova_riduci_il_movimento()
	prova_niente_disco_a_ogni_colpo()
	prova_ecg_non_accumula()
	prova_menu_da_tastiera()
	prova_ritratti_di_condizione()
	prova_ecg()
	prova_collisioni()
	prova_tutorial_di_veronica()
	prova_rivitalizzante_di_veronica()
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
	# "apri_mappa_stellare": scelta la meta sulla mappa stellare, si riprende da
	# quel nodo (la proiezione con Veronica)
	for chiave in ["vai", "apri_mappa_stellare"]:
		if nodo.has(chiave):
			uscite.append(String(nodo[chiave]))
	# "apri_mappa_zona": la Guida parla sopra la mappa, e chiudendola si va al
	# suo "ritorno" (l'arrivo nelle Pianure: la protesta, inizio_guida)
	var guida: Variant = nodo.get("apri_mappa_zona", {})
	if guida is Dictionary and (guida as Dictionary).has("ritorno"):
		uscite.append(String((guida as Dictionary)["ritorno"]))
	# "vai_se_flag" e' una regola sola oppure una lista di regole (vince la
	# prima che ha il suo flag): una stanza puo' voler dire cose diverse in
	# momenti diversi della giornata
	var salto: Variant = nodo.get("vai_se_flag", {})
	if salto is Dictionary and (salto as Dictionary).has("vai"):
		uscite.append(String((salto as Dictionary)["vai"]))
	elif salto is Array:
		for regola in (salto as Array):
			if regola is Dictionary and (regola as Dictionary).has("vai"):
				uscite.append(String((regola as Dictionary)["vai"]))
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
		# SI CAMMINA ANCHE SULLA MAPPA, non solo per le porte scritte.
		#
		# Questo camminatore conosceva un modo solo di spostarsi: un nodo che
		# ne nomina un altro. Ma da quando una zona ha una mappa, esiste una
		# seconda strada - un nodo che dice "torna_a_mappa", e dalla mappa si
		# va nelle stanze confinanti. Non se n'era mai accorto nessuno perche'
		# finora ogni zona era anche tutta collegata a mano; il complesso
		# dell'organizzazione e' la prima in cui la mappa E' il collegamento, e
		# li' la prova ha dato per orfane sei stanze che si raggiungono benissimo.
		var confinanti := confini_di_mappa(dati)
		var visti: Dictionary = {}
		var da_visitare: Array[String] = [String(dati.get("nodo_iniziale", ""))]
		while not da_visitare.is_empty():
			var corrente: String = da_visitare.pop_back()
			if corrente in visti or not nodi.has(corrente):
				continue
			visti[corrente] = true
			for destinazione in destinazioni_di(nodi[corrente]):
				da_visitare.append(destinazione)
			if apre_la_mappa(nodi[corrente]):
				# DA QUALE STANZA SI ESCE. Non tutti i nodi che aprono la mappa
				# sono stanze: il risveglio in infermeria e' un nodo a se', e la
				# stanza si chiama "infermeria". Chiedendo i vicini col nome del
				# nodo si otteneva un elenco vuoto - qui il camminatore si
				# fermava, e nel gioco la mappa si apriva senza niente da premere
				for vicina in confinanti.get(stanza_di_uscita(nodi[corrente], corrente), []):
					da_visitare.append(String(vicina))
		for id_nodo in nodi:
			# UNA STANZA CHIUSA APPOSTA NON E' UN ORFANO. Bru: "ci sono varie
			# aree, tutte non visitabili". Esistono perche' la mappa le mostri -
			# vedere un posto e poterci arrivare sono due cose diverse, e in
			# quella scena la differenza e' tutto il punto. Devono pero' dirlo:
			# un nodo dimenticato e un nodo chiuso apposta si distinguono solo
			# se il secondo lo dichiara.
			var chiusa := String((nodi[id_nodo] as Dictionary).get("_chiusa_per_ora", ""))
			esigi(visti.has(id_nodo) or chiusa != "",
					"%s: il nodo '%s' non e' raggiungibile da nessuna parte" % [percorso, id_nodo])

func apre_la_mappa(nodo: Dictionary) -> bool:
	if nodo.get("torna_a_mappa", false):
		return true
	# ANCHE UNA STANZA CHE TI SPUTA FUORI RIPORTA ALLA MAPPA. Le porte chiuse
	# del complesso hanno "espulsione_automatica": dici una riga e sei di nuovo
	# sulla planimetria. Il camminatore non lo sapeva, quindi da una porta chiusa
	# non proseguiva - e hangar e sala di proiezione non le aveva MAI percorse.
	# Passavano lo stesso perche' dichiarano "_chiusa_per_ora", che e' il
	# permesso di non essere raggiunte: due scuse diverse che insieme facevano
	# sparire un pezzo di mappa dal controllo.
	if nodo.get("espulsione_automatica", false):
		return true
	for scelta in nodo.get("scelte", []):
		if scelta.get("torna_a_mappa", false):
			return true
	return false

func stanza_di_uscita(nodo: Dictionary, id_nodo: String) -> String:
	# in che punto della planimetria ti lascia questo nodo quando apre la mappa:
	# se stesso, o la stanza che la scelta dichiara con "stanza"
	for scelta in nodo.get("scelte", []):
		var s := scelta as Dictionary
		if bool(s.get("torna_a_mappa", false)) and s.has("stanza"):
			return String(s["stanza"])
	return id_nodo

func confini_di_mappa(dati: Dictionary) -> Dictionary:
	# chi confina con chi, secondo la mappa della zona: e' quello che
	# MappaZona.si_puo_andare() usa per decidere dove si puo' cliccare
	# I CORRIDOI CHE SI APRONO PIU' TARDI SONO CORRIDOI LO STESSO.
	#
	# Il complesso al mattino ha una porta sola aperta e nel pomeriggio le ha
	# tutte ("connessioni_da" in GameState.collegamenti_aperti). Per questa
	# prova contano tutte quante: la domanda e' "esiste un giorno in cui ci si
	# arriva?", non "ci si arriva subito". Guardando solo quelle sempre aperte,
	# la sala comunicazioni - dove Bru manda il giocatore dopo l'infermeria -
	# risultava orfana.
	var mappa: Dictionary = dati.get("mappa_dungeon", {})
	var tutte: Array = mappa.get("connessioni", []).duplicate()
	for flag in mappa.get("connessioni_da", {}):
		tutte.append_array(mappa["connessioni_da"][flag])
	var vicini: Dictionary = {}
	for coppia in tutte:
		if coppia.size() < 2:
			continue
		var a := String(coppia[0])
		var b := String(coppia[1])
		if not vicini.has(a):
			vicini[a] = []
		if not vicini.has(b):
			vicini[b] = []
		vicini[a].append(b)
		vicini[b].append(a)
	return vicini

func prova_i_punti_di_riferimento() -> void:
	# LA QUINTA REGOLA DI ROMERO, e adesso e' una prova.
	#
	# «Se il giocatore vede fuori, deve poterci arrivare». E' la regola piu'
	# vecchia del mestiere e la piu' facile da tradire scrivendo: nominare un
	# posto in una descrizione costa una riga, e niente al mondo obbliga quel
	# posto a esistere. Un giardino descritto dalla finestra e mai raggiungibile
	# non e' atmosfera, e' una bugia - e il giocatore la scopre dopo aver girato
	# venti minuti a cercare la porta.
	#
	# Per questo un punto di riferimento e' un CAMPO e non semplice prosa: il
	# "verso" dichiara di quale stanza si sta parlando, e da li' in poi si puo'
	# pretendere che quella stanza esista, che sia nella stessa zona, e che
	# qualche strada ci porti davvero.
	titolo("se da una stanza si vede un posto, quel posto esiste e ci si arriva")
	var quante := 0
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		var nodi: Dictionary = dati.get("nodi", {})
		if nodi.is_empty():
			continue
		# le stanze che si raggiungono davvero dall'ingresso, per non accettare
		# un punto di riferimento che punta a un posto scollegato
		var raggiungibili: Dictionary = {}
		var da_visitare: Array[String] = [String(dati.get("nodo_iniziale", ""))]
		while not da_visitare.is_empty():
			var corrente: String = da_visitare.pop_back()
			if corrente in raggiungibili or not nodi.has(corrente):
				continue
			raggiungibili[corrente] = true
			for destinazione in destinazioni_di(nodi[corrente]):
				da_visitare.append(destinazione)
		for id_nodo in nodi:
			var nodo: Dictionary = nodi[id_nodo]
			for vista in nodo.get("vista", []):
				quante += 1
				var testo := String(vista.get("testo", ""))
				var verso := String(vista.get("verso", ""))
				esigi(testo.strip_edges() != "",
						"%s/%s: un punto di riferimento senza testo non si vede" % [percorso, id_nodo])
				esigi(verso != "",
						"%s/%s: il punto di riferimento non dice di che posto parla" % [percorso, id_nodo])
				esigi(nodi.has(verso),
						"%s/%s: si vede '%s', che in questa zona non esiste" % [percorso, id_nodo, verso])
				esigi(raggiungibili.has(verso),
						"%s/%s: si vede '%s', ma non ci si arriva: e' la bugia che la regola 5 vieta"
						% [percorso, id_nodo, verso])
				esigi(verso != id_nodo,
						"%s/%s: il punto di riferimento indica la stanza in cui sei gia'" % [percorso, id_nodo])
	# non si pretende un numero minimo: e' materiale che si scrive, e si scrive
	# piano. Ma se un giorno sparissero tutti, meglio saperlo
	esigi(quante > 0, "non c'e' un solo punto di riferimento in tutto il gioco")

func prova_ogni_cancello_ha_una_chiave() -> void:
	# UNA PORTA CHE NON SI APRE MAI e' peggio di una porta che non c'e': il
	# giocatore la vede, capisce che da qualche parte esiste il modo, e lo cerca.
	#
	# Una scelta con "richiede_flag" e' una serratura. Se in nessun punto dei
	# dati quella bandierina si accende, quella serratura non ha chiave - e non
	# se ne accorge nessuno, perche' il gioco non si rompe: semplicemente quella
	# strada non compare, per sempre, e sembra che non sia mai esistita.
	#
	# Una serratura puo' essere in attesa apposta - il contenuto che la apre non
	# e' ancora scritto - e va benissimo: basta DICHIARARLO, scrivendo accanto un
	# campo "_chiave_non_ancora" con la ragione. Cosi' la differenza fra «lo so»
	# e «mi e' sfuggito» resta scritta invece di stare nella testa di qualcuno.
	titolo("ogni porta chiusa ha, da qualche parte, la sua chiave")
	var accese: Dictionary = {}
	var richieste: Dictionary = {}   # flag -> dove serve
	var dichiarate: Dictionary = {}  # flag -> attesa dichiarata
	for percorso in tutti_i_dati():
		var dati: Variant = carica_json(percorso)
		raccogli_bandierine(dati, percorso, accese, richieste, dichiarate)
	for flag in richieste:
		if dichiarate.has(flag):
			continue
		esigi(accese.has(flag),
				"la condizione '%s' (%s) non viene accesa da nessuna parte: quella porta non si apre mai. Se e' voluto, scrivici accanto \"_chiave_non_ancora\"" 
				% [flag, String(richieste[flag])])

func prova_ogni_oggetto_richiesto_si_trova() -> void:
	# LA STESSA COSA DEI CANCELLI, MA PER GLI OGGETTI - e qui ha gia' trovato un
	# guasto vero.
	#
	# Una scelta con "richiede_oggetti" e' una serratura come le altre, solo che
	# la chiave e' una cosa che si raccoglie. Se quell'oggetto non si trova in
	# nessun posto del gioco, quella strada non compare mai: il giocatore legge
	# la stanza, capisce che esiste un modo, e lo cerca per sempre.
	#
	# LA FONTANA. Chiede quattro pezzi e ne esisteva UNO. Gli altri tre - l'anima
	# inquieta, i ricordi felici, il cuore di disallineamento - non erano
	# raccoglibili in nessuna stanza, in nessun bottino, in nessun negozio. La
	# Fontana non si poteva completare, e con lei il personaggio che ne esce.
	# Nessuna prova se n'era accorta perche' il gioco non si rompe: semplicemente
	# quella scelta non compare.
	#
	# Come per i cancelli, un oggetto puo' essere in attesa APPOSTA - il
	# meccanismo del varco dice nella sua stessa descrizione che si trova "solo
	# molto piu' avanti nel tuo viaggio" - e allora si dichiara con
	# "_non_ancora_ottenibile" nel record dell'oggetto.
	titolo("ogni oggetto che una porta chiede si trova da qualche parte")
	var si_trova: Dictionary = {}
	var richiesto: Dictionary = {}
	for percorso in tutti_i_dati():
		raccogli_oggetti(carica_json(percorso), percorso, si_trova, richiesto)
	for id_oggetto in richiesto:
		var dati_oggetto: Dictionary = GameState.dati_oggetto(String(id_oggetto))
		if dati_oggetto.has("_non_ancora_ottenibile"):
			continue
		esigi(si_trova.has(id_oggetto),
				"'%s' serve in %s e non si trova da nessuna parte: quella scelta non compare mai. Se e' voluto, scrivi \"_non_ancora_ottenibile\" nel suo record in oggetti.json"
				% [id_oggetto, String(richiesto[id_oggetto])])

func raccogli_oggetti(o: Variant, dove: String, si_trova: Dictionary, richiesto: Dictionary) -> void:
	# Un oggetto si puo' dare in tanti modi e in tante forme: "oggetto" come
	# stringa o come lista, "oggetti_forniti" del tutorial, il bottino comune di
	# una creatura, il drop raro, la merce di un negozio. Cercarne solo una forma
	# fa risultare irraggiungibili cose che si prendono benissimo - mi e' gia'
	# successo scrivendo questa prova, e la controprova qui sotto serve a quello.
	if o is Dictionary:
		var dizionario: Dictionary = o
		for chiave in dizionario:
			var valore: Variant = dizionario[chiave]
			if chiave in ["oggetto", "oggetti", "oggetti_forniti", "ricompensa_oggetto"]:
				for id_oggetto in id_oggetti_in(valore):
					si_trova[id_oggetto] = true
			elif chiave in ["richiede_oggetto", "richiede_oggetti"]:
				for id_oggetto in id_oggetti_in(valore):
					if not richiesto.has(id_oggetto):
						richiesto[id_oggetto] = dove
			raccogli_oggetti(valore, dove, si_trova, richiesto)
	elif o is Array:
		for x in o:
			raccogli_oggetti(x, dove, si_trova, richiesto)

func id_oggetti_in(valore: Variant) -> Array[String]:
	var elenco: Array[String] = []
	if valore is String and String(valore) != "":
		elenco.append(String(valore))
	elif valore is Array:
		for x in valore:
			if x is String and String(x) != "":
				elenco.append(String(x))
	elif valore is Dictionary and (valore as Dictionary).has("oggetto"):
		var dentro: Variant = (valore as Dictionary)["oggetto"]
		if dentro is String:
			elenco.append(String(dentro))
	return elenco

func tutti_i_dati() -> Array[String]:
	# ogni file di dati del gioco, zone comprese
	var elenco: Array[String] = []
	for percorso in ["res://data", "res://data/vuoti"]:
		var cartella := DirAccess.open(percorso)
		if cartella == null:
			continue
		for nome in cartella.get_files():
			if nome.ends_with(".json"):
				elenco.append("%s/%s" % [percorso, nome])
	return elenco

func carica_json(percorso: String) -> Variant:
	var testo := FileAccess.get_file_as_string(percorso)
	if testo == "":
		return {}
	var lettore := JSON.new()
	if lettore.parse(testo) != OK:
		return {}
	return lettore.data

func raccogli_bandierine(o: Variant, dove: String, accese: Dictionary,
		richieste: Dictionary, dichiarate: Dictionary) -> void:
	if o is Dictionary:
		var dizionario: Dictionary = o
		for chiave in dizionario:
			var valore: Variant = dizionario[chiave]
			if valore is String:
				var testo: String = valore
				if chiave == "flag" or chiave == "una_tantum" or chiave == "sblocca_flag":
					accese[testo] = true
				elif chiave == "richiede_flag" or chiave == "richiede_non_flag":
					if not richieste.has(testo):
						richieste[testo] = dove
			if chiave == "_chiave_non_ancora" and dizionario.has("richiede_flag"):
				dichiarate[String(dizionario["richiede_flag"])] = true
			raccogli_bandierine(valore, dove, accese, richieste, dichiarate)
	elif o is Array:
		for x in o:
			raccogli_bandierine(x, dove, accese, richieste, dichiarate)

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
		var riquadri: Dictionary = {}
		esigi(String(mappa_zona.get("nome", "")) != "",
				"%s: la mappa della zona non ha nome" % percorso)
		# il disegno, se c'e', e il foglio su cui Bru ha messo le coordinate
		var percorso_disegno := String(mappa_zona.get("disegno", ""))
		var misura_foglio: Array = mappa_zona.get("misura_disegno", [])
		var disegnata := percorso_disegno != ""
		var foglio := Vector2.ZERO
		if disegnata:
			esigi(misura_foglio.size() == 2 and float(misura_foglio[0]) > 0.0
					and float(misura_foglio[1]) > 0.0,
					"%s: la mappa dichiara un disegno ma non \"misura_disegno\": senza, i riquadri non si possono ne' disporre ne' controllare"
					% percorso)
			if misura_foglio.size() == 2:
				foglio = Vector2(float(misura_foglio[0]), float(misura_foglio[1]))
			esigi(percorso_disegno.begins_with("res://art/mappe/"),
					"%s: il disegno della mappa sta in '%s': i disegni delle mappe vanno in res://art/mappe/"
					% [percorso, percorso_disegno])
		for stanza in mappa_zona.get("stanze", []):
			var id_stanza := String(stanza.get("id", ""))
			stanze[id_stanza] = true
			esigi(nodi.has(id_stanza),
					"%s: la mappa mostra la stanza '%s', che non e' un nodo" % [percorso, id_stanza])
			esigi(String(stanza.get("nome", "")) != "",
					"%s: la stanza '%s' non ha nome sulla mappa" % [percorso, id_stanza])
			# UNA MAPPA DISEGNATA SI CONTROLLA DIVERSAMENTE. Bru: «la mappa e'
			# pessima, la dovro' disegnare io». Quando una zona dichiara un
			# "disegno", le stanze non stanno su una griglia: stanno dove dice
			# lui, in pixel del suo file, e quello che puo' andare storto e'
			# un altro paio di maniche - un riquadro fuori dal foglio, o due
			# riquadri uno sull'altro con quello sotto diventato incliccabile.
			if disegnata:
				var r: Array = stanza.get("riquadro", [])
				esigi(r.size() == 4,
						"%s: la mappa e' disegnata ma la stanza '%s' non ha un \"riquadro\" [x, y, larghezza, altezza]"
						% [percorso, id_stanza])
				if r.size() != 4:
					continue
				var suo := Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))
				esigi(suo.size.x > 0.0 and suo.size.y > 0.0,
						"%s: il riquadro di '%s' non ha misura" % [percorso, id_stanza])
				esigi(suo.position.x >= 0.0 and suo.position.y >= 0.0
						and suo.end.x <= foglio.x and suo.end.y <= foglio.y,
						"%s: il riquadro di '%s' (%s) esce dal disegno, che e' %dx%d"
						% [percorso, id_stanza, str(suo), int(foglio.x), int(foglio.y)])
				for altra_id in riquadri:
					var altra: Rect2 = riquadri[altra_id]
					esigi(not suo.intersects(altra),
							"%s: i riquadri di '%s' e '%s' si accavallano: quello sotto non si puo' cliccare"
							% [percorso, altra_id, id_stanza])
				riquadri[id_stanza] = suo
				continue
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

class Lavoratore extends RefCounted:
	# per la prova qui sotto: un RefCounted che lavora dentro un await
	var albero: SceneTree
	var fatti := [0]
	func _init(t: SceneTree, contatore: Array) -> void:
		albero = t
		fatti = contatore
	func lavora() -> void:
		for giro in 3:
			await albero.process_frame
			fatti[0] += 1

func prova_il_motore_si_comporta_come_il_codice_crede() -> void:
	# IL CONTROLLO A BASSO LIVELLO, FISSATO. Il codice si appoggia a regole del
	# motore che non sono scritte da nessuna parte nel progetto: queste righe le
	# scrivono, verificate sul Godot che fa girare il gioco. Le fonti sono il
	# riferimento delle classi di Godot 4.7 (estratto dall'eseguibile: e' lo
	# stesso testo della guida dell'editor) e, dove il riferimento tace, il
	# motore stesso. Se un aggiornamento di Godot ne cambia una, lo si sa qui e
	# non giocando. Vedi docs/basso_livello.md
	titolo("il motore si comporta come il codice crede")
	# 1. i dizionari si confrontano per contenuto, l'identita' la dice is_same
	#    (i combattenti sono dizionari: Turni.gd usa is_same, mai ==)
	var a := {"indice": 1, "hp": 10}
	var b := {"indice": 1, "hp": 10}
	esigi(a == b and not is_same(a, b), "== fra dizionari non confronta piu' il contenuto, o is_same non l'identita'")
	esigi([a].has(b), "Array.has non usa piu' l'uguaglianza per contenuto")
	# 2. JSON restituisce solo float, e dentro i contenitori il tipo conta
	#    (per questo FileSicuro.interi rimette gli interi al caricamento)
	var da_json: Variant = JSON.parse_string("[[3, 2], 7]")
	esigi(typeof(da_json[1]) == TYPE_FLOAT, "JSON restituisce gli interi come interi: FileSicuro.interi non serve piu'")
	esigi(7 == 7.0 and not ([3, 2] == da_json[0]) and not da_json.has(7),
			"int e float si confrontano diversamente da come e' scritto in FileSicuro.interi")
	# 3. un RefCounted che nessuno tiene muore anche a meta' di un await, in
	#    silenzio: ogni modulo dello scontro con un await deve avere un padrone
	var fatti := [0]
	var lavoratore := Lavoratore.new(get_tree(), fatti)
	lavoratore.lavora()
	lavoratore = null
	for giro in 4:
		await get_tree().process_frame
	esigi(fatti[0] == 0, "un RefCounted senza padrone ha finito il suo await (%d giri): le guardie viva() vanno ripensate" % fatti[0])
	# 4. il dado espone il suo stato, e lo stato e' quello che si salva (vedi
	#    GameState.riprendi_il_dado). Non si prova qui, perche' non si prova in
	#    una riga: sort_custom non e' stabile (doc di Array.sort_custom), quindi
	#    chi ordina deve spareggiare da solo - Turni spareggia fino all'indice
	esigi(ClassDB.class_exists("RandomNumberGenerator") and GameState.rng.state != 0,
			"il dado non espone piu' il suo stato: riprendi_il_dado non puo' funzionare")

func prova_il_salvataggio_rende_i_numeri_e_il_dado_come_erano() -> void:
	# IL CONTROLLO A BASSO LIVELLO, sui salvataggi. Due cose che una prova che
	# gioca da zero non vede, perche' succedono solo DOPO un caricamento:
	#
	# 1. JSON non distingue gli interi dai float («converting a Variant to JSON
	#    text will convert all numerical values to [float] types», JSON.xml,
	#    Godot 4.7). Misurato: tutti e nove i numeri di una partita tornavano
	#    float. Dentro a un array o a un dizionario il tipo conta - [3] == [3.0]
	#    e' falso, un 5.0 non entra in «match 5» - quindi devono tornare interi.
	# 2. Il dado ricominciava dal seme, cioe' dall'inizio della partita, a ogni
	#    caricamento. Deve riprendere da dove era (RandomNumberGenerator.state).
	titolo("un salvataggio rende i numeri interi, e il dado da dove era")
	GameState.nuova_partita()
	GameState.imposta_seed(4242)
	var eroe := GameState.id_protagonista
	GameState.livelli[eroe] = 3
	GameState.stress[eroe] = 12
	GameState.registra_azione("attacchi_sferrati", 7)
	GameState.carte_copie["carta_prova"] = {"normale": 2}
	for tiro in 25:
		GameState.rng.randf()   # la partita ha gia' tirato: il dado non e' piu' al seme
	var percorso := "user://prova_numeri_e_dado.json"
	esigi(GameState._scrivi_salvataggio(percorso), "il salvataggio di prova non si scrive")
	var dopo_il_salvataggio: Array[float] = []
	for tiro in 5:
		dopo_il_salvataggio.append(GameState.rng.randf())
	GameState.nuova_partita()
	esigi(GameState._leggi_salvataggio(percorso), "il salvataggio di prova non si rilegge")
	var dopo_il_caricamento: Array[float] = []
	for tiro in 5:
		dopo_il_caricamento.append(GameState.rng.randf())
	esigi(dopo_il_caricamento == dopo_il_salvataggio,
			"caricata la partita, il dado non riprende da dove era: %s invece di %s"
			% [dopo_il_caricamento, dopo_il_salvataggio])
	for valore in [GameState.livelli.get(eroe), GameState.stress.get(eroe),
			GameState.contatori.get("attacchi_sferrati"), GameState.carte_copie["carta_prova"]["normale"]]:
		esigi(typeof(valore) == TYPE_INT,
				"dopo il caricamento un numero intero e' tornato %s (%s): [3] == [3.0] e' falso"
				% [type_string(typeof(valore)), valore])
	esigi([GameState.livelli.get(eroe)] == [3], "il livello ricaricato non e' piu' uguale a 3 dentro un array")
	# e i decimali veri restano decimali: si rimette il tipo, non si arrotonda
	var misto: Dictionary = FileSicuro.interi({"a": 2.5, "b": [3.0, 1.25], "c": {"d": -4.0}, "e": 1.0e17})
	esigi(typeof(misto.a) == TYPE_FLOAT and is_equal_approx(float(misto.a), 2.5),
			"interi() ha toccato un decimale vero: 2.5 e' diventato %s" % misto.a)
	esigi(typeof(misto.b[0]) == TYPE_INT and typeof(misto.b[1]) == TYPE_FLOAT,
			"dentro un array interi() sbaglia: %s" % [misto.b])
	esigi(typeof(misto.c.d) == TYPE_INT and int(misto.c.d) == -4, "dentro un dizionario annidato interi() sbaglia: %s" % misto.c)
	esigi(typeof(misto.e) == TYPE_FLOAT, "oltre 2^53 un float non e' esatto, e interi() lo ha fatto intero lo stesso")
	# e un salvataggio vecchio, senza il dado, riparte dal seme come prima
	var vecchio := {"seed": 4242}
	GameState.riprendi_il_dado(vecchio)
	var dal_seme := GameState.rng.randf()
	GameState.imposta_seed(4242)
	esigi(is_equal_approx(dal_seme, GameState.rng.randf()),
			"un salvataggio senza il dado non riparte dal seme")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(percorso))
	GameState.nuova_partita()

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

func prova_una_partita_rovinata_si_riprende() -> void:
	# UN FILE ROVINATO NON E' UNA PARTITA PERSA. Aprire in scrittura azzerava
	# il file prima di scriverci: un gioco chiuso in quell'istante lasciava un
	# file vuoto o a meta', e nel menu la partita diventava «Anonimo, livello
	# 1», che premuta scuoteva la testa. Adesso si scrive accanto e si scambia,
	# e la versione di prima resta come riserva (vedi FileSicuro).
	titolo("una partita col file rovinato si riprende dalla riserva")
	var percorso := "user://prova_rovinata.json"
	FileSicuro.cancella(percorso)
	GameState.nuova_partita()
	GameState.tazo = 111
	GameState._scrivi_salvataggio(percorso)
	GameState.tazo = 222
	GameState._scrivi_salvataggio(percorso)
	esigi(FileAccess.file_exists(percorso + FileSicuro.RISERVA),
			"al secondo salvataggio la versione di prima non e' rimasta da parte")
	# il file si rovina a meta', come dopo una chiusura sbagliata
	var intero := FileAccess.get_file_as_string(percorso)
	var rovinato := FileAccess.open(percorso, FileAccess.WRITE)
	rovinato.store_string(intero.left(int(intero.length() / 2.0)))
	rovinato.close()
	GameState.nuova_partita()
	esigi(GameState._leggi_salvataggio(percorso),
			"col file principale rovinato la partita non si carica piu': la riserva non serve a niente")
	esigi(GameState.tazo == 111,
			"col file rovinato si riprende %d Tazo invece dei 111 della riserva" % GameState.tazo)
	# e nessun file temporaneo dimenticato accanto: lo scambio si chiude sempre
	for nome in DirAccess.get_files_at("user://"):
		esigi(not nome.begins_with("prova_rovinata.json-"),
				"lo scambio ha lasciato indietro un file temporaneo: %s" % nome)
	# UN DISCO CHE NON SCRIVE NON DICE «SALVATO». Prima l'esito si buttava, e
	# la partita risultava su file anche quando il file non c'era
	GameState.nuova_partita()
	esigi(not FileSicuro.scrivi("user://non_esiste_questa_cartella/partita.json", "{}"),
			"scrivere dove non si puo' risulta riuscito")
	GameState._scrivi_salvataggio("user://non_esiste_questa_cartella/partita.json")
	esigi(not GameState.partita_su_file,
			"un salvataggio fallito fa credere al gioco di avere la partita su file")
	FileSicuro.cancella(percorso)
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
		# e fino al tetto si arriva: «messi» si contava e non lo guardava
		# nessuno, quindi un tetto a zero sarebbe passato per giusto
		esigi(messi == base, "con %d slot aperti se ne riempiono %d" % [base, messi])

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
	for nome: String in ["conferma", "annulla", "colpo", "cura", "raccolta", "errore",
			"allarme", "vetro", "parata", "sfiora", "apertura", "chiusura"]:
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
	#   Partite    - e' la schermata principale anche lui: legge le testate dei
	#                file per il menu (la piu' recente, la data, il nome), e il
	#                pannello «Le tue partite» passa da qui invece che da GameState
	# Chi puo' chiamare salva():
	#   Sede         - rientrare alla Sede E' il salvataggio
	#   IngressoNodo - i checkpoint di meta' dungeon, deliberati e documentati
	titolo("la gerarchia: i salvataggi stanno solo dove devono")
	var gestione := ["carica_slot(", "salva_slot(", "elimina_slot(", "anteprima_slot(",
			"ha_salvataggio_slot(", "nome_slot(", "imposta_slot(", "percorso_slot("]
	var puo_gestire := ["res://scripts/GameState.gd", "res://scripts/Menu.gd", "res://scripts/Partite.gd"]
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
			# LA BARRA DI DOMINIO ADESSO E' LA TERZA DELLO SLOT DISEGNATO da Bru,
			# quella col ricciolo rosso al posto del nome. Prima era una barra a
			# se' appiccicata sotto la scheda: la schermata nuova non ha schede,
			# ha tre slot con tre barre ciascuno.
			var suo: Variant = combattente.get("slot", null)
			if suo != null and is_instance_valid(suo) and (suo as SlotCompagno).barre.has("dominio"):
				trovata = true
	esigi(trovata, "nello slot del party non c'e' la barra di dominio")

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
		# limite_giri = 1 lo scontro senza schermo ha gia' chiuso tutto dentro _ready,
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
				nemico.hp = maxi(int(nemico.hp_max / 10.0), 1)
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
	# IL RACCONTO NON STA PIU' DENTRO Main.gd: sta in Resoconto.gd, che e' il
	# suo mestiere. Main e' il direttore della storia, non il posto dove si
	# decide come si formatta una riga di statistica.
	GameState.salite_di_livello.append(salita)
	var righe: Array = Resoconto.salite_di_livello()
	esigi(righe.size() >= 2,
			"la salita di livello produce %d messaggi: non basta a spiegare cos'e' successo" % righe.size())
	var tutto := ""
	for riga in righe:
		tutto += String(riga.get("testo", "")) + "\n"
	esigi(tutto.contains("Livello 2"), "il messaggio non dice a che livello sei arrivato")
	esigi(tutto.contains("→"), "il messaggio non mostra il prima e il dopo delle statistiche")

	# E DICE IL PERCHE', che e' la meta' che mancava. In Carnivalz le stat non
	# salgono col livello: salgono con quello che hai fatto, e questo e' l'unico
	# momento in cui il giocatore lo scopre. Il dato c'era gia' - la crescita
	# sapeva per quale azione stava dando quei punti - e veniva buttato via un
	# istante dopo averlo calcolato.
	esigi(tutto.contains("per "),
			"il messaggio dice quanto sei cresciuto ma non per cosa:\n%s" % tutto)
	var un_racconto := String(GameState.crescita.get("crescita", {})
			.get("attacchi_sferrati", {}).get("racconto", ""))
	esigi(un_racconto != "", "le azioni della crescita non hanno un racconto nei dati")
	esigi(tutto.contains(un_racconto),
			"il messaggio non nomina l'azione che ha fatto crescere l'attacco ('%s'):\n%s"
			% [un_racconto, tutto])

	esigi(GameState.salite_di_livello.is_empty(),
			"dopo averla mostrata la salita e' ancora in coda: si ripeterebbe a ogni stanza")
	esigi(Resoconto.salite_di_livello().is_empty(),
			"la salita si racconta due volte")

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
	var suo_slot: Variant = eroe.get("slot", null)
	esigi(suo_slot != null and is_instance_valid(suo_slot),
			"il protagonista non ha uno slot sulla plancia")
	var barra = null
	if suo_slot != null and is_instance_valid(suo_slot):
		barra = (suo_slot as SlotCompagno).barre.get("dominio", null)
	esigi(barra != null, "lo slot del protagonista non ha la barra di dominio")
	if barra != null:
		esigi(is_zero_approx((suo_slot as SlotCompagno).quanto("dominio")),
				"a inizio scontro la barra e' gia' piena per un %d%%"
				% int((suo_slot as SlotCompagno).quanto("dominio") * 100))

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
	scontro.turni.passa_a(eroe)   # tocca a te
	scontro._su_click_nemico(nemico)
	esigi(int(nemico.hp) < vita_nemico,
			"cliccando sul nemico non gli e' successo niente: il colpo normale non arriva")

	# 2. e fuori dal tuo turno il click non colpisce: si mette da parte e
	#    aspetta il tuo turno (Intenzione.gd), non arriva adesso
	var dopo_il_colpo := int(nemico.hp)
	scontro._su_click_nemico(nemico)
	scontro._su_click_nemico(nemico)
	esigi(int(nemico.hp) == dopo_il_colpo,
			"fuori dal tuo turno il click colpisce lo stesso: i turni non valgono niente")
	scontro.intenzione.scorda()   # qui si misurano i turni, non il click messo da parte

	# 2-bis. LA BARRA SI RIEMPIE COLPENDO E INCASSANDO
	esigi(int(eroe.get("dominio", 0)) > 0,
			"dopo aver colpito la barra di dominio e' ancora a zero")
	var dominio_prima := int(eroe.get("dominio", 0))
	scontro.attacca(nemico, eroe)
	esigi(int(eroe.get("dominio", 0)) > dominio_prima,
			"incassando un colpo la barra non si e' mossa: restare in mezzo non paga niente")

	# 2-ter. LA VELOCITA' DECIDE CHI MUOVE PRIMA, non quante volte
	var lento_finto := {"velocita": maxi(int(eroe.velocita / 2.0), 1), "stati_attivi": {},
			"giocatore": false, "indice": 90}
	var svelto_finto := {"velocita": int(eroe.velocita) * 2, "stati_attivi": {},
			"giocatore": false, "indice": 91}
	esigi(scontro.turni.viene_prima(svelto_finto, eroe),
			"chi e' il doppio piu' veloce di te non muove prima di te: la velocita' non si sente")
	esigi(scontro.turni.viene_prima(eroe, lento_finto),
			"chi e' la meta' piu' lento di te muove prima di te: la velocita' non si sente")

	# 3. A TURNI. Fra un tuo turno e l'altro gli altri si muovono una volta
	#    ciascuno. Si fanno passare i turni leggendo tutto quello che c'e' da
	#    leggere (e' la condizione vera: finche' si legge il turno non passa).
	#    Il goblin va veloce quanto te, cosi' non salta nessun giro, e la misura
	#    si fa fra due tuoi turni veri: il colpo di prima te l'ha dato la prova,
	#    fuori dalla fila
	nemico.velocita = eroe.velocita
	for passo in 300:
		scontro.voce.coda.clear()
		scontro.voce.sta_facendo_leggere = false
		if scontro.puo_agire(eroe):
			break
		scontro.avanza_turni()
	esigi(scontro.puo_agire(eroe), "passando i turni non tocca mai a te")
	var sue_prima := int(nemico.get("battute", 0))
	var tue_prima := int(eroe.get("battute", 0))
	scontro.agisci_ora({"tipo": "difendi"})
	for passo in 300:
		scontro.voce.coda.clear()
		scontro.voce.sta_facendo_leggere = false
		if scontro.puo_agire(eroe):
			break
		scontro.avanza_turni()
	esigi(scontro.puo_agire(eroe), "dopo la tua mossa il turno non e' piu' tornato a te")
	esigi(int(nemico.get("battute", 0)) == sue_prima + 1,
			"fra un tuo turno e l'altro il nemico si e' mosso %d volte: a turni si muove una volta"
			% (int(nemico.get("battute", 0)) - sue_prima))
	esigi(int(eroe.get("battute", 0)) == tue_prima + 1,
			"il tuo turno non si e' aperto quando e' tornato a te")

	# 3-bis. E QUANDO TOCCA A TE, IL MONDO ASPETTA. Bru: «non ci sono i turni il
	#    goblin mi attacca di continuo». Si lascia girare il mondo senza
	#    scegliere niente, e non deve muoversi nessuno
	var vita_ferma := int(eroe.hp)
	var sue_ferme := int(nemico.get("battute", 0))
	for passo in 200:
		scontro.voce.coda.clear()
		scontro.voce.sta_facendo_leggere = false
		scontro.avanza_turni()
	esigi(int(nemico.get("battute", 0)) == sue_ferme and int(eroe.hp) == vita_ferma,
			"mentre toccava a te il nemico si e' mosso %d volte e ti ha tolto %d vita: il mondo non ti aspetta"
			% [int(nemico.get("battute", 0)) - sue_ferme, vita_ferma - int(eroe.hp)])
	esigi(scontro.puo_agire(eroe), "a forza di aspettare il turno ti e' stato tolto")

	# 3-ter. E SI VIENE COLPITI: giocando qualche giro, il nemico picchia. Il
	#    goblin si fa durare, se no cade prima di aver mostrato niente
	nemico.hp = 9999
	var vita_eroe := int(eroe.hp)
	for passo in 600:
		scontro.voce.coda.clear()
		scontro.voce.sta_facendo_leggere = false
		if int(eroe.hp) < vita_eroe:
			break
		if scontro.puo_agire(eroe):
			scontro.agisci_ora({"tipo": "attacca", "bersaglio": nemico})
			continue
		scontro.avanza_turni()
	esigi(int(eroe.hp) < vita_eroe,
			"giri interi e il protagonista e' intatto: i nemici non si muovono")

	# 4. E FINISCE. Si abbatte il nemico e lo scontro deve chiudersi
	nemico.hp = 1
	scontro.turni.passa_a(eroe)
	eroe.battuta_aperta = false
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

func prova_a_turni_ognuno_agisce_una_volta_per_giro() -> void:
	# LA PROVA DEL CAMBIO D'IMPIANTO, rifatta al contrario. Qui c'era «i nemici
	# non aspettano che tu scelga»: era la regola del motore in tempo reale, e
	# questa prova la difendeva. Bru, giocandolo: «non ci sono i turni il goblin
	# mi attacca di continuo, lo scontro con le rane diventa un casino ci
	# vogliono i turni». Adesso si difende l'opposto: in ogni giro ognuno agisce
	# una volta, in ordine di velocita', e quando tocca a te il mondo aspetta.
	titolo("a turni: ognuno agisce una volta per giro, e il tuo turno ti aspetta")
	GameState.nuova_partita()
	GameState.imposta_seed(77)
	GameState.nemici_combattimento = ["ghoul"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	# una battuta sola: e' gia' un risultato che lo scontro si chiuda da solo
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
	esigi(not scontro.in_corso,
			"con limite_giri = 1 lo scontro non si e' chiuso: la fine non scatta piu'")
	esigi(scontro.battute_del_giocatore >= 1,
			"il protagonista ha mosso %d volte: il contatore delle battute non sale"
			% scontro.battute_del_giocatore)

	# 1. LA FILA DEL GIRO: prima il piu' veloce, e al primo giro un'imboscata
	#    la ribalta. Il ghoul si fa lento apposta, cosi' le due regole dicono
	#    cose diverse
	scontro.in_corso = true
	scontro.limite_giri = 0
	nemico.velocita = 1
	eroe.velocita = 9
	scontro.turni.giro = 0
	scontro.turni.precedenza = "nemici"
	scontro.turni.nuovo_giro()
	esigi(not scontro.turni.da_muovere.is_empty() and is_same(scontro.turni.da_muovere[0], nemico),
			"con l'imboscata dei nemici il primo giro non lo apre il ghoul")
	scontro.turni.nuovo_giro()
	esigi(not scontro.turni.da_muovere.is_empty() and is_same(scontro.turni.da_muovere[0], eroe),
			"dal secondo giro l'imboscata vale ancora: il ghoul lento muove prima di te")
	esigi(scontro.giro_corrente == scontro.turni.giro,
			"il giro dei turni e' %d ma lo scontro crede di essere al %d (l'Immortale ne ha bisogno)"
			% [scontro.turni.giro, scontro.giro_corrente])

	# 2. OGNUNO UNA VOLTA PER GIRO, qualunque sia la velocita'. Il ghoul adesso
	#    e' il triplo piu' veloce di te: col motore vecchio si muoveva tre volte
	#    per ogni tua mossa
	nemico.velocita = 27
	var sue_prima := int(nemico.get("battute", 0))
	var tue_prima := int(eroe.get("battute", 0))
	for combattente in scontro.combattenti:
		combattente.hp = 9999
	scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	for passo in 30:
		scontro.avanza_turni()
		scontro.turni.fine_turno()
	var sue := int(nemico.get("battute", 0)) - sue_prima
	var tue := int(eroe.get("battute", 0)) - tue_prima
	esigi(sue > 0 and absi(sue - tue) <= 1,
			"in trenta turni il ghoul ha agito %d volte e tu %d: a turni si agisce una volta per giro"
			% [sue, tue])

	# 2-bis. MA CHI E' MOLTO PIU' LENTO SALTA DEI GIRI: il goblin arrabbiato e'
	#    stato scritto lento perche' non picchiasse a ogni tuo colpo. Un ghoul a
	#    velocita' 1 contro il tuo 9 va al ritmo minimo, due giri su cinque
	nemico.velocita = 1
	var minimo := float(GameState.regole.get("tempo", {}).get("ritmo_minimo", 0.4))
	esigi(is_equal_approx(scontro.turni.ritmo_di(nemico), minimo),
			"un ghoul nove volte piu' lento di te ha ritmo %.2f invece del minimo %.2f"
			% [scontro.turni.ritmo_di(nemico), minimo])
	esigi(is_equal_approx(scontro.turni.ritmo_di(eroe), 1.0), "il protagonista non muove a ogni giro")
	var giro_prima: int = scontro.turni.giro
	sue_prima = int(nemico.get("battute", 0))
	tue_prima = int(eroe.get("battute", 0))
	for passo in 200:
		if scontro.turni.giro >= giro_prima + 11:
			break
		scontro.avanza_turni()
		scontro.turni.fine_turno()
	sue = int(nemico.get("battute", 0)) - sue_prima
	tue = int(eroe.get("battute", 0)) - tue_prima
	esigi(tue >= 9 and sue >= 3 and sue <= 5,
			"in dieci giri il ghoul lento ha agito %d volte e tu %d: al ritmo minimo muove quattro volte su dieci"
			% [sue, tue])
	esigi(nello_storico("non riesce a muoversi a ogni giro") >= 0,
			"il ghoul salta i giri e nessuno lo dice: sembra un difetto")

	# 3. IL TEMPO SI FERMA solo quando il gioco ha qualcosa da dirti (lo
	#    studio, lo script di un boss, la lezione): fermo vuol dire che il turno
	#    non passa a nessuno
	esigi(scontro.il_tempo_scorre(), "il tempo e' gia' fermo senza nessuna ragione")
	scontro.ferma_il_tempo()
	esigi(not scontro.il_tempo_scorre(), "fermare il tempo non lo ferma")
	var ferme := int(nemico.get("battute", 0))
	for passo in 50:
		scontro.avanza_turni()
		scontro.turni.fine_turno()
	esigi(int(nemico.get("battute", 0)) == ferme,
			"col tempo fermo il ghoul si e' mosso: gli script dei boss e lo studio non proteggono niente")
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

	# 4. E QUANDO TOCCA A TE, NESSUNO SI MUOVE. Senza il giocatore automatico il
	#    protagonista e' tuo: si fanno passare i turni finche' non arriva a te, e
	#    da li' in poi il mondo deve stare fermo
	scontro.strategia = Callable()
	scontro.id_comandato = GameState.id_protagonista
	for passo in 10:
		if scontro.puo_agire(eroe):
			break
		scontro.avanza_turni()
	esigi(scontro.puo_agire(eroe), "passando i turni non e' mai toccato a te")
	var vita_prima := int(eroe.hp)
	var sue_ferme := int(nemico.get("battute", 0))
	for passo in 200:
		scontro.avanza_turni()
	esigi(int(nemico.get("battute", 0)) == sue_ferme and int(eroe.hp) == vita_prima,
			"mentre toccava a te il ghoul si e' mosso %d volte: il nemico non aspetta il tuo turno"
			% (int(nemico.get("battute", 0)) - sue_ferme))
	# e quando hai scelto, il turno passa
	scontro.agisci_ora({"tipo": "difendi"})
	esigi(not scontro.puo_agire(eroe), "dopo aver agito tocca ancora a te: si agirebbe all'infinito")
	scontro.avanza_turni()
	esigi(int(nemico.get("battute", 0)) == sue_ferme + 1,
			"dopo la tua mossa il ghoul non ha preso il suo turno")
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
	esigi(con_maestria >= int(senza_maestria / 2.0),
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
	# e lo scontro va rimesso in piedi: con limite_giri = 1 lo scontro muto
	# l'ha gia' chiuso dentro _ready, e la Mattanza - giustamente - non martella
	# un combattimento finito
	scontro.in_corso = true

	# 1. MEZZA BARRA NON APRE NIENTE. E' la promessa piu' facile da perdere:
	#    basta scrivere il costo come tutti gli altri e la Mattanza diventa
	#    un'abilita' che si chiama quando capita
	eroe.dominio = int(per_segmento / 2.0)
	esigi(not bool(scontro.dominio_sufficiente(eroe, dati)),
			"il menu accenderebbe la Mattanza con mezza barra")
	var vita := int(nemico.hp)
	scontro.usa_abilita_su(eroe, "mattanza", nemico)
	esigi(int(nemico.hp) == vita, "con mezza barra la Mattanza e' partita lo stesso")
	esigi(int(eroe.dominio) == int(per_segmento / 2.0),
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
			"modalita", "trasformazione", "provoca", "orda", "mazzata"]
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
	nemico.hp = maxi(int(nemico.hp_max / 5.0), 1)
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
	nemico.hp = maxi(int(nemico.hp_max / 5.0), 1)
	var dopo_la_ricarica := int(nemico.hp)
	scontro.turno_nemico_normale(nemico)
	esigi(int(nemico.hp) <= dopo_la_ricarica,
			"si e' curata due volte di fila: la ricarica non conta")

	# 4. ALLE STRETTE PICCHIA DI PIU'. E' la parte che non si vede sceglere: si
	#    misura sul numero
	nemico.hp = nemico.hp_max
	var attacco_intero := RegoleCombattimento.attacco_di(nemico)
	esigi(not RegoleCombattimento.e_disperata(nemico), "a vita piena risulta gia' disperata")
	nemico.hp = maxi(int(nemico.hp_max / 10.0), 1)
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
	# CHI FA UNA COSA SOLA, E RIFARLA E' GIUSTO.
	#
	# Il Nimbo Boy e' un'esca: Bru lo descrive come «una creatura che sa solo
	# provocare», e regge tre colpi. Provocare di nuovo quando la provocazione e'
	# gia' in piedi non cambia lo stato del campo - lo stato c'e' gia' - quindi
	# questa prova lo vedrebbe fermo per ventitre battute su ventiquattro. Non e'
	# un difetto: e' il suo mestiere. E per giunta lo starebbe facendo in un
	# ruolo che nel gioco non ricopre mai, visto che qui le creature vengono
	# provate come NEMICI e lui nasce solo evocato dalla parte della squadra.
	#
	# Dichiarato invece di tolto: la prova resta severa con tutti gli altri.
	var saltate := ["manifestazione_di_un_sogno", "veronica",  # copione
			"tartaruga_innocente",  # attacco 0: il suo mestiere e' non fare male
			"nimbo_boy"]  # un'esca: provoca, e riprovocare non cambia niente
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
			# E UN'ORDA CHE TI MANCA CON TUTTI I SUOI COLPI non e' ferma: ha
			# tirato i dadi. «50% di prob di fallire a colpo» (Bru), quindi con
			# cinque rane succede una volta su trentadue - e lo dice
			if String(nemico.get("ultima_mossa_tipo", "")) == "orda" and not GameState.storico.is_empty() \
					and "nessuno ti prende" in String(GameState.storico.back().get("testo", "")):
				continue
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

	# 2. E LA VELOCITA' SI SENTE NELLA FILA DEL GIRO. Qui stava il difetto vero:
	# applica_buff accetta qualunque statistica, quindi il buff esisteva e si
	# vedeva - ma velocita_effettiva non guardava i buff, e chi muoveva prima
	# non cambiava. Il confronto e' con uno veloce quanto lui prima del buff:
	# rallentato gli passa dietro, pulito torna davanti
	var pari := {"velocita": velocita_prima, "stati_attivi": {}, "giocatore": false, "indice": 999}
	var rallentato_davanti: bool = scontro.turni.viene_prima(nemico, pari)
	nemico.buffs = []
	var pulito_davanti: bool = scontro.turni.viene_prima(nemico, pari)
	esigi(not rallentato_davanti and pulito_davanti,
			"col buff muove prima: %s, senza: %s. Il potenziamento di velocita' non arriva ai turni"
			% [rallentato_davanti, pulito_davanti])

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
	esigi(int(eroe.hp) < int(vita_eroe / 2.0),
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

func prova_larena_reagisce() -> void:
	# LO SFONDO ERA UN RETTANGOLO DI UN COLORE SOLO, uguale per ogni creatura del
	# gioco: il primo goblin e l'ultimo boss si combattevano dentro la stessa
	# stanza vuota. In un gioco che non ha ancora un solo disegno quel rettangolo
	# e' TUTTO lo sfondo che esiste, e sprecarlo su un grigio piatto e' buttare
	# via l'unico spazio disponibile.
	titolo("l'arena prende il colore di chi hai davanti, e si chiude quando stai per cadere")
	var base := Stile.colore("sfondo_combattimento")

	# uno scontro senza tipo resta com'era: non si rompe niente per chi il tipo
	# non ce l'ha ancora
	esigi(ArenaCombattimento.tinta_di_scontro(base, "") == base,
			"un nemico senza tipo cambia lo sfondo lo stesso")
	esigi(ArenaCombattimento.tinta_di_scontro(base, "Marmellata") == base,
			"un tipo inventato cambia lo sfondo invece di lasciarlo stare")

	# ogni tipo vero sposta il fondo, e lo sposta in un posto suo
	var visti: Array[Color] = []
	for nome_tipo in GameState.tipi:
		var tinto := ArenaCombattimento.tinta_di_scontro(base, String(nome_tipo))
		esigi(tinto != base, "combattere una cosa di %s ha lo stesso fondo di tutto il resto" % nome_tipo)
		esigi(not visti.has(tinto),
				"il fondo di %s e' identico a quello di un altro tipo" % nome_tipo)
		visti.append(tinto)

	# E RESTA POCA. E' una temperatura, non un cambio di scena: sopra una certa
	# dose il fondo diventa il colore del nemico invece del colore del gioco, e
	# le schermate smettono di sembrare lo stesso gioco.
	#
	# La prima versione di questa prova non misurava niente: confrontava il
	# risultato con il colore del tipo COM'E' SCRITTO in tipi.json, mentre la
	# tinta viene scurita prima di essere mescolata. Portando il dosaggio a 0.9
	# - una vernice, non una temperatura - restava verde lo stesso. Se n'e'
	# accorto il sabotaggio, non io. Adesso il punto d'arrivo ha un nome suo
	# (tinta_piena) e si misura quanta strada ne ha fatta il fondo: meno di meta',
	# o e' diventata la tinta del nemico
	for nome_tipo in GameState.tipi:
		var tinto := ArenaCombattimento.tinta_di_scontro(base, String(nome_tipo))
		var arrivo := ArenaCombattimento.tinta_piena(String(nome_tipo), base)
		var strada_fatta := Vector3(tinto.r - base.r, tinto.g - base.g, tinto.b - base.b).length()
		var strada_intera := Vector3(arrivo.r - base.r, arrivo.g - base.g, arrivo.b - base.b).length()
		esigi(strada_fatta < strada_intera * 0.5,
				"il fondo di %s ha fatto %.0f%% della strada verso la tinta del tipo: non e' piu' una temperatura, e' una vernice"
				% [nome_tipo, 100.0 * strada_fatta / maxf(strada_intera, 0.0001)])

	# IL VELO AI BORDI. Il pericolo era un numero in una riga di sei voci, e si
	# passava da "sto giocando" a "e' a terra" senza nessun momento in cui il
	# gioco avesse alzato la voce
	var sani: Array[Dictionary] = [
		{"giocatore": true, "hp": 100, "hp_max": 100},
		{"giocatore": true, "hp": 90, "hp_max": 100},
	]
	esigi(is_equal_approx(ArenaCombattimento.quota_di_pericolo(sani), 0.0),
			"i bordi si chiudono con la squadra in salute")

	# GUARDA IL PIU' FERITO, NON LA MEDIA. Con una media, tre compagni sani e uno
	# in fin di vita darebbero "va tutto bene" - ed e' esattamente il momento in
	# cui il gioco deve alzare la voce
	var uno_solo_in_fin_di_vita: Array[Dictionary] = [
		{"giocatore": true, "hp": 100, "hp_max": 100},
		{"giocatore": true, "hp": 100, "hp_max": 100},
		{"giocatore": true, "hp": 100, "hp_max": 100},
		{"giocatore": true, "hp": 1, "hp_max": 100},
	]
	esigi(ArenaCombattimento.quota_di_pericolo(uno_solo_in_fin_di_vita) > 0.5,
			"un compagno a un punto dalla morte in mezzo a tre sani non chiude niente: si sta guardando la media")

	# chi e' gia' a terra non e' "in pericolo": quello non e' piu' pericolo, e'
	# gia' successo, e la sua scheda lo dice gia' con il suo KO
	var solo_ko: Array[Dictionary] = [{"giocatore": true, "hp": 0, "hp_max": 100}]
	esigi(is_equal_approx(ArenaCombattimento.quota_di_pericolo(solo_ko), 0.0),
			"un compagno gia' a terra tiene i bordi chiusi per sempre")

	# e un nemico mezzo morto non chiude niente: il velo e' il TUO pericolo
	var nemico_ferito: Array[Dictionary] = [
		{"giocatore": false, "hp": 1, "hp_max": 100},
		{"giocatore": true, "hp": 100, "hp_max": 100},
	]
	esigi(is_equal_approx(ArenaCombattimento.quota_di_pericolo(nemico_ferito), 0.0),
			"i bordi si chiudono quando sta per cadere il NEMICO")

	# non sfonda mai l'uno, o il velo diventerebbe un muro
	var quasi_morto: Array[Dictionary] = [{"giocatore": true, "hp": 1, "hp_max": 100000}]
	esigi(ArenaCombattimento.quota_di_pericolo(quasi_morto) <= 1.0,
			"la quota di pericolo ha sfondato l'uno")

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

	# E NESSUNA CURA DEVE POTER PASSARE DI LATO. Il tetto vale quanto vale la sua
	# copertura: finche' anche una sola strada scrive "hp = mini(hp + x, hp_max)"
	# per conto suo, la regola non e' una regola, e' un'abitudine. Ne erano
	# rimaste due fuori - la rigenerazione del frammento e quella della carne che
	# si richiude - e quest'ultima e' il caso limite: meta' del danno preso, a
	# ogni turno, per sempre.
	#
	# Si guarda il sorgente e non il comportamento perche' e' l'unico modo di
	# accorgersi della SESTA strada, quella che qualcuno aggiungera' domani.
	var sorgente := FileAccess.get_file_as_string("res://scripts/Combattimento.gd")
	esigi(not sorgente.contains("hp = mini("),
			"c'e' ancora una cura che si scrive da sola invece di passare da rimetti_in_piedi(): il tetto non la vede")

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

func prova_i_sogni_di_yhvina() -> void:
	# IL RICHIAMO, con le parole di Bru: «Yhvina evoca creature dai suoi sogni.
	# Nel primo incontro riuscira' a evocare solo dei Nimbo Boy, una creatura
	# debole che resiste a 3 attacchi - non ha vita, 3 attacchi anche deboli e
	# muore. E' una creatura che sa solo provocare. Oppure evoca un sogno
	# perduto, una creatura con 1/4 degli hp di Yhvina. Lei puo' evocare un sogno
	# per volta. I sogni che evoca appaiono come ally.»
	#
	# Quattro cose da misurare, e sono tutte e quattro delle SUE frasi.
	titolo("i sogni di Yhvina: tre colpi, un quarto di vita, uno per volta")
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
	scontro.in_corso = true

	# 1. TRE COLPI E SE NE VA, qualunque sia il colpo.
	scontro.aggiungi_combattente("nimbo_boy", true)
	var nimbo: Dictionary = scontro.combattenti[scontro.combattenti.size() - 1]
	esigi(bool(nimbo.giocatore), "il Nimbo Boy non arriva dalla parte della squadra")
	esigi(int(nimbo.hp) == 3, "il Nimbo Boy nasce con %d punti vita invece di 3" % int(nimbo.hp))
	# un colpo enorme vale uno come un graffio: e' il punto di tutta la creatura
	nemico.attacco = 9999
	scontro.attacca(nemico, nimbo, 9999, 1.0, "")
	esigi(int(nimbo.hp) == 2,
			"una cannonata ha tolto al Nimbo Boy piu' di un colpo: e' a %d invece che a 2" % int(nimbo.hp))
	scontro.attacca(nemico, nimbo, 1, 1.0, "")
	scontro.attacca(nemico, nimbo, 1, 1.0, "")
	esigi(int(nimbo.hp) <= 0, "dopo tre colpi il Nimbo Boy e' ancora in piedi con %d" % int(nimbo.hp))

	# 2. UN QUARTO DELLA VITA DI CHI LO SOGNA, e non un numero scritto a mano
	eroe.hp_max = 200
	eroe.hp = 200
	scontro.evoca_alleato(eroe, {"valore": ["sogno_perduto"], "testo_uso": "[i]%s chiama.[/i]"})
	var sogno: Dictionary = scontro.combattenti[scontro.combattenti.size() - 1]
	esigi(String(sogno.id) == "sogno_perduto", "il richiamo non ha portato il sogno perduto")
	esigi(int(sogno.hp_max) == 50,
			"il sogno perduto ha %d punti vita invece di un quarto dei 200 di chi lo sogna" % int(sogno.hp_max))
	esigi(int(sogno.hp) == int(sogno.hp_max), "il sogno perduto arriva gia' ferito")

	# 3. UNO PER VOLTA. Finche' quello di prima e' in piedi, il richiamo non
	# porta niente di nuovo - e non e' il limite di posti in squadra, che e'
	# un'altra cosa e sta piu' in alto
	var quanti_prima: int = scontro.combattenti.size()
	scontro.evoca_alleato(eroe, {"valore": ["sogno_perduto"]})
	esigi(scontro.combattenti.size() == quanti_prima,
			"il secondo richiamo ha portato un altro sogno mentre il primo era ancora in piedi")
	# caduto quello, se ne puo' chiamare un altro
	sogno.hp = 0
	scontro.evoca_alleato(eroe, {"valore": ["sogno_perduto"]})
	esigi(scontro.combattenti.size() == quanti_prima + 1,
			"con il sogno precedente caduto, il richiamo non porta piu' niente")

	# 4. UN RICHIAMO CHE NON SA CHI CHIAMARE non fa esplodere niente
	var quanti_ora: int = scontro.combattenti.size()
	scontro.evoca_alleato(eroe, {"valore": ""})
	scontro.evoca_alleato(eroe, {"valore": ["una_creatura_che_non_esiste"]})
	esigi(scontro.combattenti.size() == quanti_ora,
			"un richiamo senza sogni validi ha portato in campo qualcosa")
	scontro.free()

func prova_le_scelte_a_tempo() -> void:
	# Bru: «quelle eroe e villain sono a tempo, manchi timing non recuperi».
	#
	# Tre cose da misurare, e sono tutte e tre cose che non si vedono in uno
	# scatto: che l'orologio scada davvero, che a scadere sparisca SOLO lui, e
	# che scegliere lasci un segno che resta.
	titolo("le scelte a tempo: scadono, e scegliere lascia un segno")

	# 1. L'OROLOGIO. Conta alla rovescia e lo dice quando e' finita.
	var orologio: Control = load("res://scripts/Orologio.gd").new()
	add_child(orologio)
	var suonato := [false]
	orologio.scaduto.connect(func() -> void: suonato[0] = true)
	orologio.avvia(1.0, 0.0)
	esigi(is_equal_approx(orologio.quota_rimasta(), 1.0),
			"appena avviato l'orologio e' gia' a %f" % orologio.quota_rimasta())
	orologio._process(0.4)
	esigi(orologio.quota_rimasta() < 1.0 and orologio.quota_rimasta() > 0.0,
			"dopo quattro decimi su un secondo la quota e' %f" % orologio.quota_rimasta())
	esigi(not suonato[0], "l'orologio e' scaduto a meta' strada")
	orologio._process(0.7)
	esigi(suonato[0], "il tempo e' finito e l'orologio non l'ha detto")
	esigi(is_equal_approx(orologio.quota_rimasta(), 0.0),
			"scaduto, ma la quota rimasta e' %f" % orologio.quota_rimasta())
	# e una volta scaduto sta fermo: senza questo continuerebbe a contare in
	# negativo e a ripetere il segnale a ogni fotogramma
	suonato[0] = false
	orologio._process(1.0)
	esigi(not suonato[0], "l'orologio ha suonato una seconda volta dopo essere gia' scaduto")
	orologio.free()

	# 2. SCADUTA SPARISCE LEI, E LE ALTRE RESTANO. "Non recuperi" vuol dire che
	#    quella strada si chiude, non che hai perso il turno.
	GameState.nuova_partita()
	GameState.eventi["prova_a_tempo"] = {
		"sequenza": [{"tipo": "narrazione", "testo": "Decidi."}],
		"scelte": [
			{"testo": "Di corsa", "genere": "malvagio", "tempo": 0.5, "vai": "prova_a_tempo"},
			{"testo": "Con calma", "vai": "prova_a_tempo"},
		],
	}
	GameState.nodo_corrente = "prova_a_tempo"
	IngressoNodo.ultimo_esito = {}
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	schermata.ricostruisci_scelte(GameState.eventi["prova_a_tempo"])
	await get_tree().process_frame
	esigi(conta_bottoni(schermata.contenitore_scelte) == 2,
			"le scelte montate sono %d invece di 2"
			% conta_bottoni(schermata.contenitore_scelte))
	var trovato_orologio := cerca_orologio(schermata.contenitore_scelte)
	esigi(trovato_orologio != null, "la scelta con \"tempo\" non ha nessun orologio appeso")
	if trovato_orologio != null:
		trovato_orologio._process(1.0)     # il tempo scade
		# SCADUTA E' MORTA SUBITO, anche se il vetro sta ancora cadendo. Fra lo
		# scadere e la rottura passano dei fotogrammi - la fotografia del pezzo
		# che si rompe si prende alla fine di un disegno - e in quei fotogrammi
		# la si poteva ancora cliccare.
		var scaduto_ma_vivo := cerca_bottone_con_testo(schermata.contenitore_scelte, "Di corsa")
		esigi(scaduto_ma_vivo != null and scaduto_ma_vivo.disabled,
				"il tempo e' scaduto e la scelta si puo' ancora premere mentre si rompe")
		# la rottura non e' istantanea: si aspetta che il vetro abbia finito,
		# con un tetto, perche' un'attesa senza tetto in una prova e' un modo
		# elegante di piantarsi
		for i in 40:
			if conta_bottoni(schermata.contenitore_scelte) <= 1:
				break
			await get_tree().process_frame
	esigi(conta_bottoni(schermata.contenitore_scelte) == 1,
			"scaduto il tempo restano %d scelte: doveva sparire solo quella a tempo"
			% conta_bottoni(schermata.contenitore_scelte))
	esigi(testo_dei_bottoni(schermata.contenitore_scelte).has("Con calma"),
			"scaduta quella a tempo e' sparita anche la scelta normale")

	# 2-bis. I PEZZI CADONO E SVANISCONO. Bru: «si frantumano come se fosse
	#     vetro e scompaiono, i pezzi devono cadere e gradualmente svanire verso
	#     il trasparente». Tre cose, e nessuna delle tre si vede in uno scatto:
	#     che i pezzi siano piu' d'uno, che SCENDANO, e che il vetro se ne vada
	#     da solo invece di restare li' per sempre.
	var vetro: Control = load("res://scripts/Frantumi.gd").new()
	add_child(vetro)
	var finta := Control.new()
	finta.size = Vector2(240, 60)
	add_child(finta)
	await vetro.frantuma(finta)
	esigi(vetro.schegge.size() >= 8,
			"il vetro si e' rotto in %d pezzi: troppo pochi per sembrare rotto"
			% vetro.schegge.size())
	esigi(is_equal_approx(vetro.opacita(), 1.0),
			"appena rotto il vetro e' gia' a %f di opacita'" % vetro.opacita())
	var altezze_prima: Array[float] = []
	for scheggia in vetro.schegge:
		altezze_prima.append((scheggia.posizione as Vector2).y)
	# mezzo secondo di caduta: la gravita' deve aver vinto su qualunque spinta
	for i in 30:
		vetro._process(1.0 / 60.0)
	var scesi := 0
	for i in vetro.schegge.size():
		if (vetro.schegge[i].posizione as Vector2).y > altezze_prima[i]:
			scesi += 1
	esigi(scesi == vetro.schegge.size(),
			"dopo mezzo secondo solo %d pezzi su %d sono scesi: gli altri stanno per aria"
			% [scesi, vetro.schegge.size()])
	esigi(vetro.opacita() < 1.0 and vetro.opacita() > 0.0,
			"a meta' caduta l'opacita' e' %f: doveva essere a meta' strada verso il trasparente"
			% vetro.opacita())
	var sparito := [false]
	vetro.finito.connect(func() -> void: sparito[0] = true)
	for i in 90:
		if sparito[0]:
			break
		vetro._process(1.0 / 60.0)
	esigi(sparito[0], "il vetro non se n'e' mai andato: resta a schermo per sempre")
	finta.free()

	# e il tempo, finche' i dialoghi non ce l'hanno scritto, se lo tira il dado
	# dentro i secondi che ha detto Bru
	var regola: Dictionary = GameState.regole.get("scelta_a_tempo", {})
	var minimo := float(regola.get("secondi_minimo", 3.0))
	var massimo := float(regola.get("secondi_massimo", 7.0))
	esigi(is_equal_approx(minimo, 3.0) and is_equal_approx(massimo, 7.0),
			"i secondi delle scelte a tempo sono %.1f-%.1f invece di 3-7" % [minimo, massimo])
	var visti_diversi := {}
	for i in 40:
		var tirato: float = schermata.tempo_della_scelta({"genere": "eroe"})
		esigi(tirato >= minimo and tirato <= massimo,
				"una scelta a tempo ha tirato %.2f secondi, fuori da %.1f-%.1f"
				% [tirato, minimo, massimo])
		visti_diversi[snappedf(tirato, 0.01)] = true
	esigi(visti_diversi.size() > 1,
			"quaranta tiri hanno dato sempre lo stesso tempo: non e' randomizzato")
	esigi(is_equal_approx(schermata.tempo_della_scelta({"genere": "eroe", "tempo": 5.5}), 5.5),
			"una scelta che dichiara il suo tempo se l'e' visto tirare a caso lo stesso")
	esigi(is_equal_approx(schermata.tempo_della_scelta({"testo": "normale"}), 0.0),
			"una scelta normale ha preso un tempo: solo eroe e villain scadono")

	# 3. SCEGLIERE LASCIA UN SEGNO, e i due conti non si annullano a vicenda.
	esigi(GameState.scelte_eroe == 0 and GameState.scelte_malvagie == 0,
			"a partita nuova i conti di eroe/villain non sono a zero")
	schermata._su_scelta({"testo": "x", "genere": "malvagio"})
	esigi(GameState.scelte_malvagie == 1,
			"una scelta da villain non e' stata contata: il conto e' %d" % GameState.scelte_malvagie)
	schermata._su_scelta({"testo": "x", "genere": "eroe"})
	schermata._su_scelta({"testo": "x", "genere": "eroe"})
	esigi(GameState.scelte_eroe == 2,
			"due scelte da eroe hanno lasciato %d" % GameState.scelte_eroe)
	esigi(GameState.scelte_malvagie == 1,
			"comportarsi da eroe ha cancellato la scelta da villain: i due conti sono separati apposta")
	# e un requisito le sa leggere
	var esigente: Dictionary = {
		"scelte": [
			{"testo": "solo per eroi", "vai": "prova_a_tempo", "richiede_eroe": 2},
			{"testo": "per veri eroi", "vai": "prova_a_tempo", "richiede_eroe": 9},
		],
	}
	# NIENTE ATTESA QUI. I bottoni esistono appena add_child() li ha messi, e
	# quelli vecchi sono gia' in coda di cancellazione (testo_dei_bottoni li
	# salta): aspettare un fotogramma non serviva a vedere niente di piu', e
	# rendeva la verifica dipendente da cosa altro girava in quel fotogramma.
	# Con l'attesa questa riga e' fallita una volta su otto e non sono mai
	# riuscito a rifarla fallire - il che e' esattamente il motivo per cui
	# un'attesa che non serve non va lasciata in una prova.
	schermata.ricostruisci_scelte(esigente)
	var visibili: Array = testo_dei_bottoni(schermata.contenitore_scelte)
	esigi(visibili.has("solo per eroi"), "due scelte da eroe non bastano per un requisito da due")
	esigi(not visibili.has("per veri eroi"), "un requisito da nove e' passato con due scelte da eroe")
	schermata.free()
	GameState.nuova_partita()

func conta_bottoni(radice: Node) -> int:
	var quanti := 0
	for figlio in radice.get_children():
		if figlio.is_queued_for_deletion():
			continue
		if figlio is Button:
			quanti += 1
		else:
			quanti += conta_bottoni(figlio)
	return quanti

func testo_dei_bottoni(radice: Node) -> Array:
	var righe: Array = []
	for figlio in radice.get_children():
		if figlio.is_queued_for_deletion():
			continue
		if figlio is Button:
			righe.append((figlio as Button).text)
		else:
			righe.append_array(testo_dei_bottoni(figlio))
	return righe

func cerca_bottone_con_testo(radice: Node, quale: String) -> Button:
	for figlio in radice.get_children():
		if figlio is Button and (figlio as Button).text == quale:
			return figlio
		var dentro := cerca_bottone_con_testo(figlio, quale)
		if dentro != null:
			return dentro
	return null

func cerca_orologio(radice: Node) -> Control:
	for figlio in radice.get_children():
		if figlio is Control and (figlio as Control).has_signal("scaduto"):
			return figlio
		var dentro := cerca_orologio(figlio)
		if dentro != null:
			return dentro
	return null

func prova_maschile_e_femminile() -> void:
	# Bru: «a seconda del sesso che si sceglie cambiamo i dialoghi al femminile
	# o maschile, anche se scrivo in maschile tieni in conto questa cosa».
	titolo("maschile e femminile: l'accordo sta dentro la frase")

	# 1. LA SOSTITUZIONE. Maschile prima, femminile dopo, sempre.
	esigi(Testi.accorda("Sei {pronto|pronta}?", "m") == "Sei pronto?",
			"il maschile esce '%s'" % Testi.accorda("Sei {pronto|pronta}?", "m"))
	esigi(Testi.accorda("Sei {pronto|pronta}?", "f") == "Sei pronta?",
			"il femminile esce '%s'" % Testi.accorda("Sei {pronto|pronta}?", "f"))
	# piu' accordi nella stessa frase, che e' il caso normale
	var lunga := "dominat{ore|rice}, si e' {goduto|goduta} il riposo?"
	esigi(Testi.accorda(lunga, "f") == "dominatrice, si e' goduta il riposo?",
			"due accordi nella stessa frase danno '%s'" % Testi.accorda(lunga, "f"))
	# e un sesso non riconosciuto vale maschile, invece di cancellare la frase
	esigi(Testi.accorda("Sei {pronto|pronta}?", "") == "Sei pronto?",
			"senza sesso la frase esce '%s'" % Testi.accorda("Sei {pronto|pronta}?", ""))

	# 2. LE ALTRE GRAFFE NON SI TOCCANO. {nome} usa le stesse parentesi, ed e'
	#    la sostituzione piu' vecchia del gioco: mangiarsela qui vorrebbe dire
	#    che ogni "Benvenuto, {nome}" diventa "Benvenuto, " senza dirlo.
	esigi(Testi.accorda("Ciao {nome}, sei {pronto|pronta}?", "f") == "Ciao {nome}, sei pronta?",
			"l'accordo si e' mangiato {nome}: esce '%s'"
			% Testi.accorda("Ciao {nome}, sei {pronto|pronta}?", "f"))
	# e una graffa mai chiusa non deve far sparire il resto della battuta
	esigi(Testi.accorda("Testo con {graffa aperta", "m") == "Testo con {graffa aperta",
			"una graffa mai chiusa ha mangiato la frase")

	# 3. NIENTE ARRIVA A SCHERMO CON LE GRAFFE ADDOSSO. E' il guasto vero: un
	#    accordo scritto storto ("{pronto/pronta}" con la barra sbagliata) non
	#    da' nessun errore - si legge a schermo, dentro la battuta, e chi
	#    gioca vede le parentesi.
	GameState.nuova_partita()
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		for id_nodo in dati.get("nodi", {}):
			var nodo: Dictionary = dati["nodi"][id_nodo]
			for msg in nodo.get("sequenza", []):
				var grezzo := String((msg as Dictionary).get("testo", ""))
				for sesso in ["m", "f"]:
					GameState.sesso_protagonista = sesso
					var finito: String = schermata.sostituisci_nome(grezzo)
					esigi(not finito.contains("|"),
							"%s/%s: resta una barra a schermo, '%s'"
							% [percorso, id_nodo, finito.substr(0, 70)])
			for scelta in nodo.get("scelte", []):
				var testo_scelta := String((scelta as Dictionary).get("testo", ""))
				esigi(not schermata.sostituisci_nome(testo_scelta).contains("|"),
						"%s/%s: una scelta mostra una barra: '%s'" % [percorso, id_nodo, testo_scelta])
	GameState.sesso_protagonista = "m"
	schermata.free()
	GameState.nuova_partita()

func prova_dall_introduzione_al_combattimento() -> void:
	# LA STRADA CHE FA CHI COMINCIA A GIOCARE, camminata per intero.
	#
	# Non e' la stessa cosa della prova sui nodi orfani: quella dice che da
	# qualche parte una strada esiste, questa dice che e' QUESTA - introduzione,
	# alloggio, mappa, sala, scelta, combattimento. E' l'unico percorso che
	# ogni giocatore fara' senza eccezioni, e se si spezza si spezza per tutti.
	titolo("dall'introduzione al primo combattimento, passo per passo")
	var dati := carica_eventi("res://data/events_intro.json")
	var nodi: Dictionary = dati.get("nodi", {})
	esigi(String(dati.get("nodo_iniziale", "")) == "introduzione",
			"il gioco non comincia dall'introduzione ma da '%s'" % dati.get("nodo_iniziale", ""))

	# l'introduzione: nove battute di narrazione e poi la scritta
	var passi: Array = nodi["introduzione"]["sequenza"]
	var narrazioni := 0
	var scritte := 0
	var cambi_sfondo := 0
	for passo in passi:
		match String((passo as Dictionary).get("tipo", "")):
			"narrazione": narrazioni += 1
			"scritta": scritte += 1
		if (passo as Dictionary).has("sfondo"):
			cambi_sfondo += 1
	esigi(narrazioni == 9, "l'introduzione ha %d passi di narrazione invece dei 9 di Bru" % narrazioni)
	esigi(scritte == 1, "la scritta di Carnivalz compare %d volte" % scritte)
	esigi(cambi_sfondo == 5,
			"gli sfondi dell'introduzione sono %d: Bru ne ha segnati cinque con ||" % cambi_sfondo)
	esigi(String(passi[passi.size() - 1].get("tipo", "")) == "scritta",
			"la scritta non e' l'ultima cosa dell'introduzione")

	# la mappa del complesso: si vede tutto, si va in un posto solo
	var mappa: Dictionary = dati.get("mappa_dungeon", {})
	esigi(not mappa.is_empty(), "il complesso non ha nessuna mappa")
	# IL COMPLESSO HA DUE MOMENTI, e la mappa li racconta tutti e due.
	#
	# La mattina: si vede tutto, si va in un posto solo. «ci sono varie aree,
	# tutte non visitabili, puoi andare solo nella sala allenamento che ha un
	# punto esclamativo animato» (Bru).
	#
	# Dopo l'allenamento, quando ti rimetti in piedi in infermeria: «ti trovi
	# nella mappa della struttura, stavolta tutta visibile [...] ci sarà il
	# solito ! che si muove nel punto dove c'è la sala comunicazioni».
	#
	# Sono due stati diversi dello stesso posto, e una prova che ne guardi uno
	# solo lascia l'altro senza nessuno che lo controlli.
	var collegamenti: Array = mappa.get("connessioni", [])
	esigi(collegamenti.size() == 1,
			"la mattina dal complesso si va in %d posti: Bru ne ha chiesto uno solo" % collegamenti.size())
	esigi(collegamenti[0].has("alloggio") and collegamenti[0].has("sala_allenamento"),
			"l'unico collegamento aperto la mattina non e' alloggio-sala_allenamento")
	var dopo: Dictionary = mappa.get("connessioni_da", {})
	esigi(dopo.has("rientro_infermeria"),
			"dopo l'infermeria non si apre nessun corridoio: la sala comunicazioni resta irraggiungibile")
	var raggiungibili: Array[String] = []
	for coppia in collegamenti + Array(dopo.get("rientro_infermeria", [])):
		for capo in coppia:
			if String(capo) not in raggiungibili:
				raggiungibili.append(String(capo))
	esigi("sala_comunicazioni" in raggiungibili,
			"nessun corridoio porta alla sala comunicazioni: il punto esclamativo indica un posto dove non si puo' andare")

	# il punto esclamativo si sposta: la mattina in palestra, dopo in sala
	# comunicazioni. Non e' un'icona fissa, e' quello che devi fare adesso
	var obiettivo_prima: Array[String] = []
	var obiettivo_dopo: Array[String] = []
	for stanza in mappa.get("stanze", []):
		var voce := stanza as Dictionary
		if String(voce.get("icona", "")) != "obiettivo":
			continue
		var da := String(voce.get("icona_da", ""))
		var fino_a := String(voce.get("icona_fino_a", ""))
		if da == "":
			obiettivo_prima.append(String(voce.get("id", "")))
		if fino_a == "":
			obiettivo_dopo.append(String(voce.get("id", "")))
	esigi(obiettivo_prima.size() == 1 and obiettivo_prima[0] == "sala_allenamento",
			"la mattina il punto esclamativo sta su %s invece che sulla sala di allenamento" % str(obiettivo_prima))
	esigi(obiettivo_dopo.size() == 1 and obiettivo_dopo[0] == "sala_proiezione",
			"alla fine della giornata il punto esclamativo sta su %s invece che sulla sala di proiezione" % str(obiettivo_dopo))

	# TRE TAPPE, NON DUE. Il punto esclamativo e' l'unica cosa che dice dove
	# andare adesso, e la giornata ha tre momenti: la palestra la mattina, la
	# sala comunicazioni al risveglio in infermeria, la sala di proiezione
	# quando il data pad ha finito di spiegarsi. In ogni momento dev'essercene
	# UNO SOLO: due punti esclamativi insieme non sono un indizio, sono un bivio
	# che nessuno ha voluto.
	var tappe := [
		[[], "sala_allenamento"],
		[["rientro_infermeria"], "sala_comunicazioni"],
		[["rientro_infermeria", "data_pad_spiegato"], "sala_proiezione"],
	]
	for tappa in tappe:
		var flag_adesso: Array = tappa[0]
		var accesi: Array[String] = []
		for stanza in mappa.get("stanze", []):
			var st := stanza as Dictionary
			if String(st.get("icona", "")) != "obiettivo":
				continue
			var da := String(st.get("icona_da", ""))
			var fino_a := String(st.get("icona_fino_a", ""))
			if da != "" and da not in flag_adesso:
				continue
			if fino_a != "" and fino_a in flag_adesso:
				continue
			accesi.append(String(st.get("id", "")))
		esigi(accesi == [String(tappa[1])],
				"con i flag %s il punto esclamativo sta su %s invece che su '%s'"
				% [flag_adesso, accesi, String(tappa[1])])
	esigi(mappa.get("stanze", []).size() >= 6,
			"il complesso ha %d aree: era \"varie aree\"" % mappa.get("stanze", []).size())

	# LA PRIMA MATTINA E' UN CORRIDOIO, NON UNA SCELTA, e questa prova diceva il
	# contrario: pretendeva che dall'alloggio si uscisse SULLA MAPPA.
	#
	# Era la mia lettura, non quella di Bru, e provando il gioco l'ha corretta:
	# quella era la prima schermata di mappa della partita - un attrezzo mai
	# presentato, con sopra un punto esclamativo che ti teletrasporta in palestra
	# saltando il racconto. «La mappa deve essere consultabile dopo la
	# spiegazione di come si usa non prima».
	var uscite: Array = nodi["alloggio"]["scelte"]
	esigi(uscite.size() == 1 and String(uscite[0].get("vai", "")) == "sala_allenamento",
			"uscendo dall'alloggio non si va dritti in palestra: la mattina non e' ancora una scelta")
	esigi(not bool(uscite[0].get("torna_a_mappa", false)),
			"uscendo dall'alloggio si apre ancora la mappa, prima che il gioco l'abbia spiegata")

	# le tre risposte di Veronica sono tre, diverse, e portano tutte allo scontro
	var scelte_sala: Array = nodi["sala_allenamento"]["scelte"]
	esigi(scelte_sala.size() == 3, "nella sala ci sono %d scelte invece di 3" % scelte_sala.size())
	var risposte: Dictionary = {}
	for scelta in scelte_sala:
		var dove := String((scelta as Dictionary).get("vai", ""))
		esigi(nodi.has(dove), "una scelta della sala manda a '%s', che non esiste" % dove)
		var risposta: Dictionary = nodi[dove]
		var battuta := String(risposta.get("sequenza", [{}])[0].get("testo", ""))
		esigi(not risposte.has(battuta),
				"due scelte diverse ricevono la stessa risposta: '%s'" % battuta.substr(0, 40))
		risposte[battuta] = true
		var scontro: Dictionary = risposta.get("combattimento_automatico", {})
		esigi(scontro.get("nemici", []) == ["veronica"],
				"da '%s' non si finisce a combattere con Veronica" % dove)
		esigi(String(scontro.get("se_vinci", "")) != "" and String(scontro.get("se_perdi", "")) != "",
				"l'allenamento con Veronica non dice dove si va vincendo o perdendo")

func prova_il_nastro_col_nome() -> void:
	# Bru ha disegnato il nastro col nome in tre fotogrammi: fuori dal bordo
	# sinistro, poi a meta' strada ancora storto, poi al suo posto. «From outside
	# it enters following the arrow until reaching the position».
	#
	# Un'animazione non si prova guardando - per quello ci sono gli scatti - ma
	# tre cose sotto si possono misurare, e sono le tre che, se si rompono, non
	# se ne accorge nessuno finche' non si sta giocando:
	titolo("il nastro col nome entra da fuori, e rientra solo se cambia chi parla")
	GameState.nuova_partita()
	GameState.eventi["prova_nastro"] = {
		"sequenza": [{"tipo": "narrazione", "testo": "."}],
		"scelte": [{"testo": "avanti", "vai": "prova_nastro"}],
	}
	GameState.nodo_corrente = "prova_nastro"
	IngressoNodo.ultimo_esito = {}
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame

	# 1. LA CURVA E' UNA CURVA. Non ci si arriva per caso: una Bezier sbagliata
	#    passa lo stesso per i due estremi, e a vederla sembra solo "un po'
	#    storta". Quello che la distingue da una retta e' il punto di mezzo.
	var da := Vector2(0.0, 0.0)
	var verso := Vector2(100.0, -200.0)
	var a := Vector2(200.0, 0.0)
	esigi(schermata.curva(da, verso, a, 0.0).is_equal_approx(da), "la curva non parte da dove deve")
	esigi(schermata.curva(da, verso, a, 1.0).is_equal_approx(a), "la curva non arriva dove deve")
	var meta: Vector2 = schermata.curva(da, verso, a, 0.5)
	esigi(meta.y < -40.0,
			"a meta' strada la curva sta a y=%.1f: e' una retta, non un arco" % meta.y)

	# 2. PARTE DA FUORI DALLO SCHERMO. Se partisse da dentro non "entrerebbe":
	#    comparirebbe e scivolerebbe, che e' un'altra cosa.
	schermata.nome_sul_nastro = ""
	# SI ASPETTA LA PARTENZA, POI SI FERMA IL VOLO.
	#
	# Prima si lanciava senza aspettare e si guardava due fotogrammi dopo: cosi'
	# la prova non misurava "da dove parte il nastro" ma "dov'e' arrivato in due
	# fotogrammi", e quanto dura un fotogramma non lo decide nessuno qui dentro.
	# Su una macchina che tossiva il nastro aveva gia' fatto ottanta pixel e la
	# prova diventava rossa senza che niente fosse rotto - una prova che mente
	# una volta su otto e' peggio di una prova che non c'e'.
	await schermata.aggiorna_nastro("Veronica")
	if schermata.tween_nastro != null and schermata.tween_nastro.is_valid():
		schermata.tween_nastro.pause()
	var nastro: Control = schermata.nastro
	esigi(nastro.visible, "il nastro non si e' acceso")
	esigi(schermata.nome_nastro.text == "veronica",
			"sul nastro c'e' scritto '%s'" % schermata.nome_nastro.text)
	esigi(nastro.position.x + nastro.size.x < 0.0,
			"il nastro parte a x=%.1f, cioe' gia' dentro lo schermo" % nastro.position.x)
	esigi(absf(nastro.rotation) > deg_to_rad(30.0),
			"il nastro parte inclinato di %.1f gradi: doveva entrare quasi in verticale"
			% rad_to_deg(nastro.rotation))

	# 3. ARRIVA, E SI FERMA DOVE DEVE. Da qui in poi il volo deve riprendere:
	# la pausa di sopra serviva a fotografare la partenza, non a bloccarlo.
	if schermata.tween_nastro != null and schermata.tween_nastro.is_valid():
		schermata.tween_nastro.play()
	# SI ASPETTA CHE IL TWEEN ABBIA FINITO, non che la posizione sia "quasi"
	# arrivata. Fermandosi al primo fotogramma entro un pixel si campionava un
	# nastro ancora in movimento: il rimbalzo della rotazione stava ancora
	# assestandosi, e il confronto del punto 4 falliva per mezzo pixel dando la
	# colpa alla cosa sbagliata.
	var atteso: Vector2 = schermata.posto_del_nastro()
	for i in 90:
		var volo: Tween = schermata.tween_nastro
		if volo == null or not volo.is_running():
			break
		await get_tree().process_frame
	esigi(nastro.position.distance_to(atteso) < 1.0,
			"il nastro si e' fermato a %s invece che a %s" % [nastro.position, atteso])
	esigi(absf(nastro.rotation) < deg_to_rad(12.0),
			"atterrato, il nastro e' ancora inclinato di %.1f gradi" % rad_to_deg(nastro.rotation))

	# 4. NON RIENTRA A OGNI BATTUTA. Un dialogo e' dieci battute della stessa
	#    persona: rifare l'entrata a ognuna e' un tic, non un'animazione.
	var fermo := nastro.position
	schermata.aggiorna_nastro("Veronica")
	await get_tree().process_frame
	esigi(nastro.position.is_equal_approx(fermo),
			"la stessa persona ha parlato di nuovo e il nastro e' rientrato da capo")
	# ...ma se parla qualcun altro, si'
	schermata.aggiorna_nastro("Anonimo")
	await get_tree().process_frame
	await get_tree().process_frame
	esigi(not nastro.position.is_equal_approx(fermo),
			"ha parlato qualcun altro e il nastro e' rimasto dov'era")
	esigi(schermata.nome_nastro.text == "anonimo",
			"il nastro dice ancora '%s'" % schermata.nome_nastro.text)

	# 5. IL DISEGNO DI BRU VINCE SUL RIPIEGO. Bru: «ogni personaggio avra' il
	#    suo, te li forniro' appena li avro' finiti». Finche' non arrivano c'e'
	#    il rettangolo rosa col nome scritto dal gioco - ma il giorno che il
	#    primo file compare deve prendere il suo posto da solo, senza che
	#    nessuno tocchi niente. Qui si prova proprio quel passaggio, con un
	#    nastro finto inventato adesso: se il meccanismo si rompe, ce ne
	#    accorgiamo oggi e non fra sei mesi con i disegni veri in mano.
	esigi(not schermata.fondo_nastro.visible,
			"senza nessun disegno il nastro mostra gia' un'immagine")
	esigi(schermata.nome_nastro.visible, "senza disegno il nome non si vede")
	var alto_di_ripiego := nastro.size.y
	# il disegno finto: largo tre volte quanto e' alto, come un pezzo di nastro
	var finto := ImageTexture.create_from_image(
			Image.create(600, 200, false, Image.FORMAT_RGBA8))
	var alto := float(Stile.forma("altezza_nastro"))
	schermata.applica_nastro(finto)
	esigi(schermata.fondo_nastro.visible, "col disegno addosso il disegno non si vede")
	esigi(not schermata.nome_nastro.visible,
			"col disegno addosso si vede ancora il nome scritto dal gioco: due nomi sovrapposti")
	esigi(is_equal_approx(nastro.size.x, alto * 3.0),
			"il nastro e' largo %.1f: con un disegno tre volte piu' largo che alto doveva essere %.1f"
			% [nastro.size.x, alto * 3.0])
	esigi(is_equal_approx(nastro.size.y, alto),
			"col disegno addosso il nastro e' alto %.1f invece di %d"
			% [nastro.size.y, Stile.forma("altezza_nastro")])
	esigi(not is_equal_approx(alto_di_ripiego, 0.0),
			"il nastro di ripiego non aveva nessuna altezza: la prova sopra non misurava niente")
	# e il disegno copre il nastro per intero, o si vedrebbe il rosa sotto i bordi
	await get_tree().process_frame
	esigi(schermata.fondo_nastro.size.is_equal_approx(nastro.size),
			"il disegno e' %s e il nastro %s: non combaciano"
			% [schermata.fondo_nastro.size, nastro.size])
	# e tolto il disegno si torna al ripiego, senza restare grandi come il disegno
	schermata.applica_nastro(null)
	esigi(schermata.nome_nastro.visible and not schermata.fondo_nastro.visible,
			"tolto il disegno il nastro non e' tornato alla scritta di ripiego")
	esigi(is_equal_approx(nastro.size.y, alto_di_ripiego),
			"tornato al ripiego il nastro e' alto %.1f invece di %.1f: si e' tenuto la misura del disegno"
			% [nastro.size.y, alto_di_ripiego])

	# 6. LA CARTELLA SCRITTA NEL CODICE E QUELLA SCRITTA A BRU SONO LA STESSA.
	#
	# Questo e' l'unico modo onesto che ho di provarla. Il percorso vero non si
	# puo' esercitare in una prova: un .png scritto a runtime dentro res:// non
	# e' importato, e load() non lo vede - quindi "il file c'e' e viene caricato"
	# non e' misurabile da qui. Quello che invece si rompe davvero, e in
	# silenzio, e' un altro: io cambio la cartella nel codice e il README
	# continua a dire quella vecchia. Bru copia i disegni dove gli ho detto, non
	# succede niente, e nessuno dei due sa perche'.
	var istruzioni := ""
	var apri := FileAccess.open("res://art/nastri/README.md", FileAccess.READ)
	if apri != null:
		istruzioni = apri.get_as_text()
		apri.close()
	esigi(istruzioni != "", "art/nastri/README.md non c'e': Bru non sa dove mettere i disegni")
	var cartella_nel_codice := String(schermata.CARTELLA_NASTRI).replace("res://", "")
	esigi(istruzioni.contains(cartella_nel_codice + "<id>.png"),
			"il codice cerca i nastri in '%s<id>.png' ma il README dice un'altra cosa"
			% cartella_nel_codice)
	esigi(istruzioni.contains("altezza_nastro"),
			"il README non dice che l'altezza la decide il gioco: Bru li disegnera' a caso")
	schermata.free()
	GameState.nuova_partita()

func prova_chi_e_a_terra_non_viene_piu_colpito() -> void:
	# Bru, giocando: «quando vengo messo ko i nemici continuano a colpirmi».
	#
	# Non era una cosa sola, erano tre, e hanno tutte la stessa forma: lo
	# scontro non finisce quando dovrebbe, e finche' non finisce i nemici hanno
	# tutto il diritto di picchiare. Qui si misura l'invariante, non le tre
	# cause: SE LA SQUADRA E' A TERRA, LO SCONTRO E' FINITO. Comunque ci sia
	# arrivata.
	titolo("chi e' a terra non viene piu' colpito")

	# 1. IL MODO NORMALE. Cadi per un colpo, e lo scontro si chiude.
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
	eroe.resurrezione = ""
	eroe.ultima_resistenza = false
	nemico.attacco = 99999
	scontro.attacca(nemico, eroe, 99999, 1.0, "")
	esigi(int(eroe.hp) <= 0, "il colpo da 99999 non lo ha steso: e' a %d" % int(eroe.hp))
	esigi(not bool(scontro.in_corso),
			"la squadra e' a terra e lo scontro va ancora avanti")

	# e da terra non si incassa piu' niente.
	#
	# I punti vita non lo direbbero: sono gia' a zero e a zero restano comunque,
	# perche' il danno e' sempre limitato in basso. Misurarli qui sarebbe una
	# verifica che non puo' fallire - ne ho gia' scritte due cosi', e le ho
	# trovate solo rompendo apposta il codice che dovevano sorvegliare. Quello
	# che si muove davvero e' il contatore dei colpi incassati.
	var incassati_a_terra := int(eroe.colpi_incassati)
	scontro.attacca(nemico, eroe, 99999, 1.0, "")
	esigi(int(eroe.colpi_incassati) == incassati_a_terra,
			"un corpo a terra ha incassato un altro colpo: da %d a %d"
			% [incassati_a_terra, int(eroe.colpi_incassati)])
	scontro.free()

	# 2. LA MALEDIZIONE. E' l'uscita anticipata che nascondeva il guasto: chi
	#    cade cosi' non si rialza, e _su_ko usciva prima di chiedere se lo
	#    scontro fosse finito.
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var maledetto: Node = load("res://scenes/Combattimento.tscn").instantiate()
	maledetto.muto = true
	maledetto.limite_giri = 1
	add_child(maledetto)
	maledetto.in_corso = true
	var vittima: Dictionary = {}
	for c in maledetto.combattenti:
		if c.giocatore:
			vittima = c
			break
	esigi(not vittima.is_empty(), "lo scontro maledetto non si e' montato")
	maledetto.stati.applica_stato(vittima, "maledizione", 10)
	esigi(int(vittima.hp) <= 0, "la maledizione e' arrivata a zero e lui e' ancora in piedi")
	esigi(bool(vittima.get("non_rianimabile", false)),
			"caduto per maledizione ma rianimabile")
	esigi(not bool(maledetto.in_corso),
			"caduto per maledizione: la squadra e' a terra e lo scontro va ancora avanti")
	maledetto.free()

	# 3. L'ARREDAMENTO NON E' UN NEMICO. Le lettere sull'altare della bambola
	#    stanno nella fila dei nemici, hanno punti vita e non agiscono mai:
	#    contarle fra i vivi voleva dire che abbattere la bambola senza
	#    distruggerle non era una vittoria - e nessuno poteva piu' muoversi.
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var altare: Node = load("res://scenes/Combattimento.tscn").instantiate()
	altare.muto = true
	altare.limite_giri = 1
	add_child(altare)
	altare.in_corso = true
	altare.crea_oggetto_scena("goblin_tipico", 30)
	var bersaglio_fisso: Dictionary = altare.combattenti[altare.combattenti.size() - 1]
	esigi(bool(bersaglio_fisso.get("oggetto_scena", false)),
			"l'oggetto di scena non e' nato oggetto di scena")
	var nemico_vero: Dictionary = {}
	for c in altare.combattenti:
		if not c.giocatore and not c.get("oggetto_scena", false):
			nemico_vero = c
			break
	esigi(not nemico_vero.is_empty(), "non c'e' nessun nemico vero da abbattere")
	var eroe_altare: Dictionary = {}
	for c in altare.combattenti:
		if c.giocatore:
			eroe_altare = c
			break
	eroe_altare.attacco = 99999
	altare.attacca(eroe_altare, nemico_vero, 99999, 1.0, "")
	esigi(int(nemico_vero.hp) <= 0, "il nemico vero e' ancora in piedi")
	esigi(int(bersaglio_fisso.hp) > 0, "l'oggetto di scena si e' rotto da solo")
	esigi(not bool(altare.in_corso),
			"i nemici sono tutti a terra ma le lettere sull'altare tengono aperto lo scontro")
	esigi(bool(altare.giocatore_ha_vinto), "abbattuti tutti i nemici e non risulta una vittoria")
	altare.free()

	# 4. IL COMANDO PASSA. Cade chi stai giocando, la squadra e' ancora in
	#    piedi: lo scontro deve continuare - quello e' giusto - ma tu devi
	#    poter muovere qualcuno. Prima restavi a guardare.
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var squadra: Node = load("res://scenes/Combattimento.tscn").instantiate()
	squadra.muto = true
	squadra.limite_giri = 1
	add_child(squadra)
	squadra.in_corso = true
	var capo: Dictionary = {}
	var avversario: Dictionary = {}
	for c in squadra.combattenti:
		if c.giocatore and capo.is_empty():
			capo = c
		elif not c.giocatore and avversario.is_empty():
			avversario = c
	squadra.aggiungi_combattente("nimbo_boy", true)
	var compagno: Dictionary = squadra.combattenti[squadra.combattenti.size() - 1]
	esigi(bool(compagno.giocatore), "il compagno non e' arrivato dalla parte della squadra")
	var comandato_prima: Dictionary = squadra.combattente_comandato()
	esigi(String(comandato_prima.get("id", "")) == String(capo.id),
			"prima del KO non stavi comandando il protagonista")
	capo.resurrezione = ""
	capo.ultima_resistenza = false
	avversario.attacco = 99999
	squadra.attacca(avversario, capo, 99999, 1.0, "")
	esigi(int(capo.hp) <= 0, "il protagonista non e' caduto")
	esigi(bool(squadra.in_corso),
			"e' caduto il protagonista ma il compagno e' vivo: lo scontro non doveva finire")
	var comandato_dopo: Dictionary = squadra.combattente_comandato()
	esigi(not comandato_dopo.is_empty(),
			"caduto chi comandavi non comandi piu' nessuno: il menu resta grigio per tutto lo scontro")
	esigi(String(comandato_dopo.get("id", "")) == String(compagno.id),
			"il comando e' passato a '%s' invece che al compagno vivo"
			% String(comandato_dopo.get("id", "")))
	squadra.free()

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
	var con_nome: String = scontro.stati.frase_di_stato(eroe, "%s prende fuoco.")
	esigi(con_nome.contains(String(eroe.nome)),
			"una frase con %%s non ha ricevuto il nome: esce '%s'" % con_nome)
	esigi(not con_nome.contains("%s"), "il segnaposto e' rimasto scritto a schermo: '%s'" % con_nome)
	var senza_nome: String = scontro.stati.frase_di_stato(eroe, "Le fiamme si spengono.")
	esigi(senza_nome == "Le fiamme si spengono.",
			"una frase senza %%s e' stata cambiata: esce '%s'" % senza_nome)

	# TERRORE — indebolisce e toglie il critico
	eroe.stati_attivi = {}
	var attacco_sano := RegoleCombattimento.calcola_danno(eroe, nemico, 100, 1.0, 0)
	scontro.stati.applica_stato(eroe, "terrore")
	esigi(RegoleCombattimento.critico_bloccato(eroe), "col Terrore addosso si fanno ancora critici")
	esigi(RegoleCombattimento.quota_attacco_dagli_stati(eroe) < 0.0,
			"il Terrore non indebolisce: la quota di attacco e' %f" % RegoleCombattimento.quota_attacco_dagli_stati(eroe))
	var attacco_atterrito := RegoleCombattimento.calcola_danno(eroe, nemico, 100, 1.0, 0)
	esigi(int(attacco_atterrito.danno) < int(attacco_sano.danno),
			"atterrito fa %d danni, sano ne faceva %d" % [int(attacco_atterrito.danno), int(attacco_sano.danno)])

	# FIAMME e TOSSINA — la stessa macchina, due tarature. Le Fiamme fanno di piu'
	eroe.stati_attivi = {}
	scontro.stati.applica_stato(eroe, "fiamme")
	var danno_fiamme := int(eroe.stati_attivi["fiamme"].danno)
	eroe.stati_attivi = {}
	scontro.stati.applica_stato(eroe, "tossina")
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
	scontro.stati.applica_stato(eroe, "fiamme")
	esigi(int(eroe.stati_attivi["fiamme"].danno) > danno_fiamme,
			"il danno delle Fiamme non scala con la vita massima: resta un numero fisso")
	eroe.hp_max = 1000

	# SONNO — massimo tre turni, e i colpi incassati alzano il risveglio
	eroe.stati_attivi = {}
	scontro.stati.applica_stato(eroe, "sonno")
	esigi(int(eroe.stati_attivi["sonno"].turni_rimasti) <= 3, "il Sonno dura piu' di tre turni")
	scontro.registra_danno_subito(eroe, 5)
	scontro.registra_danno_subito(eroe, 5)
	esigi(int(eroe.stati_attivi["sonno"].colpi_nel_sonno) == 2,
			"i colpi incassati mentre dorme non vengono contati: scuoterlo non serve a niente")

	# MALEDIZIONE — riserva da 10, la consumano i colpi, e chi cade non si rialza
	eroe.stati_attivi = {}
	eroe.non_rianimabile = false
	scontro.stati.applica_stato(eroe, "maledizione", 3)
	esigi(int(eroe.stati_attivi["maledizione"].riserva) == 7,
			"tre punti di maledizione su dieci hanno lasciato %d invece di 7"
			% int(eroe.stati_attivi["maledizione"].riserva))
	scontro.stati.risolvi_stati_a_inizio_turno(eroe)
	esigi(int(eroe.stati_attivi["maledizione"].riserva) == 7,
			"la riserva e' scesa da sola passando un turno: doveva consumarla solo un colpo")
	scontro.stati.applica_stato(eroe, "maledizione", 7)
	esigi(int(eroe.hp) <= 0, "la riserva e' arrivata a zero e non e' successo niente")
	esigi(bool(eroe.get("non_rianimabile", false)),
			"caduto per maledizione ma rianimabile: gli oggetti lo rimettono in piedi")

	# RABBIA e FRASTORNATO — tolgono le mosse
	eroe.hp = 1000
	eroe.non_rianimabile = false
	eroe.stati_attivi = {}
	esigi(not RegoleCombattimento.solo_attacchi(eroe), "senza stati addosso non puo' gia' usare le mosse")
	scontro.stati.applica_stato(eroe, "rabbia")
	esigi(RegoleCombattimento.solo_attacchi(eroe), "con la Rabbia addosso si usano ancora le mosse")
	eroe.stati_attivi = {}
	scontro.stati.applica_stato(eroe, "frastornato")
	esigi(RegoleCombattimento.solo_attacchi(eroe),
			"Frastornato lascia usare le mosse: doveva permettere solo attacchi")

	# PROVOCATO — puoi colpire solo chi ti ha provocato
	eroe.stati_attivi = {}
	eroe.id_provocatore = String(nemico.id)
	scontro.stati.applica_stato(eroe, "provocato")
	esigi(RegoleCombattimento.bersaglio_obbligato(eroe) == String(nemico.id),
			"Provocato non ricorda chi l'ha provocato: 'solo lui' non vuol dire niente")
	var solo_lui: Array[Dictionary] = scontro.stati.bersagli_ammessi(eroe, scontro.vivi(false))
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
	# senza un limite lo scontro muto passa i turni a vuoto per 4000 volte e
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
	# I NOMI SONO QUELLI DEL DISEGNO. Bru ha scritto ATTACCHI DIFESA SKILL
	# OGGETTI FUGA sulla schermata, e sulla schermata vincono le sue parole:
	# prima dicevano "Attacca, Difendi, Abilità, Oggetti, Fuggi", che sono le
	# stesse cose chiamate in un altro modo.
	for voce in ["ATTACCHI", "DIFESA", "SKILL", "OGGETTI", "FUGA"]:
		esigi(voce in etichette, "manca la voce '%s' dal menu: c'e' %s" % [voce, etichette])
	# contro un goblin, che non media e non porta aiutanti, le condizionali
	# non devono esserci: se comparissero sempre non sarebbero condizionali
	esigi(not ("Mediazione" in etichette),
			"Mediazione compare contro un nemico che non media: %s" % [etichette])
	esigi(not ("Aiutante" in etichette),
			"Aiutante compare senza nessun aiutante: %s" % [etichette])
	# e le cinque fisse stanno PRIMA delle condizionali, nell'ordine detto
	esigi(etichette.slice(0, 5) == ["ATTACCHI", "DIFESA", "SKILL", "OGGETTI", "FUGA"],
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
	esigi(con_casa >= int(guardate * 3 / 4.0),
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
	eroe.hp = int(eroe.hp_max / 2.0)
	scontro.applica_effetto(eroe, effetto)
	esigi(int(eroe.get("rigenerazione_battute", 0)) == 3,
			"il frammento non ha aperto nessuna rigenerazione")
	var vita_prima := int(eroe.hp)
	scontro.risolvi_rigenerazione_frammento(eroe)
	esigi(int(eroe.hp) > vita_prima, "la prima battuta di rigenerazione non ha curato niente")
	esigi(int(eroe.hp) - vita_prima <= int(eroe.hp_max / 5.0),
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
	var tipi_noti := ["provoca", "area", "raffica", "carica", "onda", "potenziamento",
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

func prova_chi_ti_rigetta_fuori_non_ti_tiene_fermo() -> void:
	# LE AREE CHIUSE DEL COMPLESSO dicono una riga e ti rimandano fuori. Prima
	# nascondevano il comando per avanzare e aspettavano 2,2 secondi fissi: chi
	# legge in fretta guardava il muro, e non c'era niente da premere.
	#
	# E' il difetto che Durczok segnala su Final Fantasy XVI - le schermate «on
	# a timer that needs to elapse», «very disruptive behaviour from the UI».
	# Adesso quei secondi sono una cortesia per chi resta fermo: il comando
	# resta a schermo e chi clicca esce subito.
	#
	# Si misura sul comando, non sul tempo: se e' a schermo il giocatore ha una
	# via d'uscita, se non c'e' e' in gabbia per 2,2 secondi.
	titolo("chi ti rigetta fuori non ti tiene fermo")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame

	var chiuse: Array[String] = []
	for id_nodo in GameState.eventi:
		if bool((GameState.eventi[id_nodo] as Dictionary).get("espulsione_automatica", false)):
			chiuse.append(String(id_nodo))
	esigi(chiuse.size() >= 2,
			"non ci sono aree a espulsione automatica da controllare: ne ho trovate %d"
			% chiuse.size())

	for id_nodo in chiuse:
		GameState.nodo_corrente = id_nodo
		schermata.mostra_nodo(id_nodo)
		await get_tree().process_frame
		esigi(schermata.area_avanza.visible,
				"'%s' ti rigetta fuori col comando per avanzare nascosto: " % id_nodo +
				"2,2 secondi in cui non si puo' premere niente")
		esigi(schermata.azione_dopo_coda.is_valid(),
				"'%s': finita la coda non c'e' nessuna uscita - " % id_nodo +
				"chi clicca resta dentro")
	schermata.free()
	GameState.nuova_partita()

func prova_la_forma_del_testo() -> void:
	# LA SCALA, LA GRIGLIA, L'INTERLINEA E LA LUNGHEZZA DELLA RIGA.
	#
	# Quattro regole di mestiere, tutte e quattro misurabili, e tutte e quattro
	# erano violate prima di guardarle con un numero in mano.
	titolo("la forma del testo: scala, griglia, interlinea, lunghezza di riga")

	# 1. LA SCALA E' MODULARE. Prima i rapporti facevano 1,250 - 1,733 - 1,038 -
	#    1,259 - 1,294: corpo 26 e sezione 27 differivano di UN PIXEL, che non e'
	#    un gradino di gerarchia, e' rumore. Due misure che l'occhio non
	#    distingue sono una misura sola scritta due volte.
	var scala: Array[int] = []
	for nome in ["minuscolo", "piccolo", "corpo", "sezione", "nome", "titolo"]:
		scala.append(Stile.dimensione(nome))
	for i in range(1, scala.size()):
		var rapporto := float(scala[i]) / float(scala[i - 1])
		esigi(rapporto > 1.12 and rapporto < 1.30,
				"fra %d e %d il rapporto e' %.3f: fuori dalla scala modulare"
				% [scala[i - 1], scala[i], rapporto])

	# 2. GLI SPAZI STANNO SU UNA GRIGLIA DA 8. Prima: 7, 9, 14, 18, 22, 26, 30,
	#    34 - massimo comun divisore 1, nemmeno multipli di quattro.
	for nome in ["bordo_box", "padding_bottone_x", "padding_bottone_y",
			"padding_box_x", "padding_box_y", "separazione", "cornice",
			"bordo_plancia", "altezza_box"]:
		var misura := Stile.forma(nome)
		esigi(misura % 8 == 0,
				"'%s' vale %d: non sta sulla griglia da 8" % [nome, misura])

	# 3. L'INTERLINEA E' DICHIARATA, e sta nell'intervallo giusto.
	#
	#    Qui si controllano i NUMERI, non i pixel, e c'e' un perche'. La prima
	#    versione di questa prova chiedeva a Stile.font_da("corpo") l'altezza
	#    reale di una riga: quello costruisce un SystemFont e misurarlo lo
	#    costringe a risolvere e rasterizzare i glifi, che senza finestra puo'
	#    non tornare piu' - la suite e' rimasta appesa due volte, seicento
	#    secondi ognuna. Le prove devono restare veloci e sempre uguali: i pixel
	#    si guardano con scatto.sh, qui si guarda la regola.
	var interlinee: Dictionary = Stile.dati.get("interlinee", {})
	esigi(not interlinee.is_empty(),
			"nessuna interlinea dichiarata: la decide il font di sistema, " +
			"cioe' cambia da macchina a macchina")
	var lettura := float(interlinee.get("lettura", 0.0))
	esigi(lettura >= 1.4 and lettura <= 1.6,
			"l'interlinea del testo da leggere e' %.2f: la regola dice 1,4-1,6" % lettura)
	# E PIU' IL TESTO E' GRANDE, MENO ARIA VUOLE FRA LE RIGHE. E' la regola che
	# si sbaglia piu' spesso - viene da pensare il contrario
	esigi(float(interlinee.get("titolo", 9.0)) < lettura,
			"il titolo ha piu' interlinea del testo da leggere: e' il contrario")

	# 4. IL CONTORNO DEL TESTO E' UNA REGOLA SOLA, in un posto solo.
	#
	#    Era scelto a occhio in tre file diversi: 5, 7 e 10. Messi in rapporto
	#    ai corpi su cui stavano facevano 0,167 e 0,184 - proporzionali PER
	#    CASO. Il primo corpo che avessimo cambiato avrebbe rotto il rapporto
	#    senza che nessuno se ne accorgesse, ed e' esattamente quello che e'
	#    successo oggi: la scala e' cambiata tutta.
	for cartella_nome: String in ["res://scripts", "res://scripts/combattimento"]:
		var cartella := DirAccess.open(cartella_nome)
		if cartella == null:
			continue
		for nome in cartella.get_files():
			if not nome.ends_with(".gd") or nome == "Stile.gd":
				continue
			var sorgente := FileAccess.get_file_as_string(cartella_nome + "/" + nome)
			esigi(not sorgente.contains("\"outline_size\""),
					"%s si sceglie il contorno da solo: deve chiedere Stile.contorno" % nome)

	# e la regola proporziona davvero, invece di mettere sempre lo stesso numero
	var campione := Label.new()
	add_child(campione)
	Stile.contorno(campione, 60)
	var grosso := campione.get_theme_constant("outline_size")
	Stile.contorno(campione, 26)
	var sottile := campione.get_theme_constant("outline_size")
	esigi(grosso > sottile,
			"il contorno non segue il corpo: %d a 60 e %d a 26" % [grosso, sottile])
	Stile.contorno(campione, 4)
	esigi(campione.get_theme_constant("outline_size") >= 2,
			"su un corpo minuscolo il contorno sparisce: sotto i due pixel non si vede")

	# 5. LE LETTERE SI STRINGONO SOLO DA GRANDI. Stringere il testo da leggere
	#    lo rende solo piu' difficile; e' il corpo da manifesto che, ingrandito,
	#    si sfilaccia se non lo si stringe.
	esigi(Stile.CORPO_DA_STRINGERE >= 30,
			"si stringono le lettere gia' da corpo %d: cosi' si tocca anche il testo da leggere"
			% Stile.CORPO_DA_STRINGERE)
	esigi(Stile.dimensione("corpo") < Stile.CORPO_DA_STRINGERE,
			"il corpo del testo da leggere (%d) finisce dentro la crenatura"
			% Stile.dimensione("corpo"))
	campione.queue_free()

	# 6. LA RIGA NON E' PIU' LUNGA DI QUANTO L'OCCHIO REGGA: 50-75 caratteri,
	#    66 l'ottimo. Oltre, si perde il capo della riga dopo e ci si rilegge.
	var box: Control = load("res://scenes/BoxTesto.tscn").instantiate()
	add_child(box)
	box.size = Vector2(900.0, 200.0)
	await get_tree().process_frame
	var scritta: RichTextLabel = box.testo
	var lunga := ("Nell'universo la vita prende forme che nessuno aveva previsto, " +
			"e ognuna di loro si porta dietro una fame che non sa di avere.")
	scritta.text = lunga
	await get_tree().process_frame
	await get_tree().process_frame
	var righe := scritta.get_line_count()
	if righe >= 2:
		var per_riga := float(lunga.length()) / float(righe)
		titolo("  %d caratteri su %d righe = %.0f per riga" % [lunga.length(), righe, per_riga])
		esigi(per_riga >= 40.0 and per_riga <= 85.0,
				"la riga del dialogo tiene %.0f caratteri: la misura buona sta fra 50 e 75"
				% per_riga)
	box.queue_free()

func prova_i_tazo_si_vedono_scendere_ma_non_fanno_aspettare() -> void:
	# IL NEGOZIO E' L'UNICO POSTO DOVE IL GIOCATORE SPENDE, e un numero che
	# salta da 30 a 12 non racconta la spesa, la registra. Adesso scende sotto
	# gli occhi - ma l'acquisto succede SUBITO: e' il numero che arriva dopo,
	# non il contrario. Durczok su Final Fantasy XVI: il peccato capitale e'
	# la schermata che aspetta il contatore.
	titolo("i Tazo si vedono scendere, e non fanno aspettare nessuno")
	GameState.nuova_partita()
	GameState.tazo = 500
	GameState.negozi_sbloccati = ["organizzazione"] as Array[String]
	var bottega: Node = load("res://scenes/Negozio.tscn").instantiate()
	add_child(bottega)
	await get_tree().process_frame

	# all'apertura il numero c'e' gia': non risale da zero ogni volta che entri
	var conto: Conto = bottega.conto_tazo
	esigi(conto != null, "il negozio non ha nessun contatore dei Tazo")
	esigi(conto.mostrato == 500,
			"aprendo il negozio il numero parte da %d invece che da 500" % conto.mostrato)
	esigi(not conto.in_corso(), "aprendo il negozio il numero si mette ad animarsi")
	esigi(bottega.etichetta_tazo.text.contains("500"),
			"a schermo non c'e' il numero vero: '%s'" % bottega.etichetta_tazo.text)

	# SI COMPRA. I soldi se ne vanno adesso, il numero ci arriva dopo.
	esigi(GameState.compra("razione_del_circo", 10), "l'acquisto di prova non e' riuscito")
	bottega.costruisci()
	esigi(GameState.tazo == 490, "i Tazo non sono scesi: %d" % GameState.tazo)
	esigi(conto.meta == 490, "il contatore punta a %d invece che a 490" % conto.meta)
	await get_tree().process_frame
	esigi(conto.in_corso(), "il numero non si sta muovendo: nessuna animazione")

	# E SI RICOMPRA SUBITO, mentre il numero e' ancora per aria. Se comprare
	# dovesse aspettare la fine dell'animazione, qui si romperebbe qualcosa.
	esigi(GameState.compra("razione_del_circo", 10), "non si e' potuto ricomprare subito")
	bottega.costruisci()
	esigi(GameState.tazo == 480, "il secondo acquisto non e' passato: %d" % GameState.tazo)
	esigi(conto.meta == 480, "il contatore non ha seguito il secondo acquisto: %d" % conto.meta)
	conto.subito()
	esigi(conto.mostrato == 480,
			"saltando l'animazione il numero e' %d invece di 480" % conto.mostrato)
	esigi(bottega.etichetta_tazo.text.contains("480"),
			"a schermo resta '%s'" % bottega.etichetta_tazo.text)
	bottega.free()
	GameState.nuova_partita()

func prova_un_numero_che_si_anima_non_fa_mai_aspettare() -> void:
	# ANIMARE SI', SBARRARE MAI.
	#
	# Paweł Durczok, smontando Final Fantasy XVI, chiama «peccato capitale» una
	# schermata che non si chiude finche' l'animazione non e' finita, e l'esempio
	# e' proprio un contatore: esperienza, punti, soldi e fama che salgono con
	# l'ammorbidimento, e solo dopo si puo' chiudere. «You'll be seeing hundreds
	# of those screens during the course of the game.»
	#
	# Qui si misura la separazione: l'animazione e' un regalo, non un pedaggio.
	# Chi salta trova SUBITO il numero giusto, nello stesso fotogramma, e non
	# deve aspettare niente.
	titolo("un numero che si anima non fa mai aspettare")
	var etichetta := Label.new()
	add_child(etichetta)
	var conto := Conto.su(etichetta, "Tazo %d")

	# il valore di partenza si scrive e basta: un contatore che risale da zero a
	# ogni apertura del menu non racconta niente, fa solo aspettare
	conto.scrivi(30)
	esigi(etichetta.text == "Tazo 30",
			"il valore di partenza non e' stato scritto: c'e' '%s'" % etichetta.text)
	esigi(not conto.in_corso(), "scrivere il valore di partenza ha avviato un'animazione")

	# adesso si spende, e il numero parte
	conto.vai_a(12)
	await get_tree().process_frame
	esigi(conto.in_corso(), "il numero non si sta muovendo: nessuna animazione")
	esigi(conto.mostrato != 12,
			"l'animazione e' gia' finita al primo fotogramma: non si vedrebbe niente")

	# IL GIOCATORE HA FRETTA. Salta, e da quell'istante il numero e' quello vero.
	conto.subito()
	esigi(conto.mostrato == 12,
			"dopo aver saltato il numero e' %d invece di 12" % conto.mostrato)
	esigi(etichetta.text == "Tazo 12",
			"dopo aver saltato a schermo c'e' '%s'" % etichetta.text)
	esigi(not conto.in_corso(), "dopo aver saltato l'animazione e' ancora in corso")

	# E NON TORNA INDIETRO. Se saltare scrivesse il numero senza spegnere
	# l'animazione, al fotogramma dopo il tween riscriverebbe un valore di
	# mezzo: il giocatore vedrebbe il numero risalire dopo averlo saltato.
	for giro in 5:
		await get_tree().process_frame
	esigi(conto.mostrato == 12,
			"un fotogramma dopo il salto il numero e' tornato a %d" % conto.mostrato)
	esigi(etichetta.text == "Tazo 12",
			"un fotogramma dopo il salto a schermo c'e' '%s'" % etichetta.text)

	# CHI RIDUCE IL MOVIMENTO non vede nessuna animazione, e il numero e' giusto
	# dal primo istante
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = true
	conto.vai_a(99)
	esigi(conto.mostrato == 99,
			"con il movimento ridotto il numero e' %d invece di 99" % conto.mostrato)
	esigi(not conto.in_corso(), "con il movimento ridotto c'e' comunque un'animazione")
	Impostazioni.movimento_ridotto = prima

	# e saltare piu' contatori insieme e' quello che fa chi riceve un tasto
	var altra := Label.new()
	add_child(altra)
	var secondo := Conto.su(altra, "%d")
	secondo.scrivi(0)
	conto.scrivi(0)
	conto.vai_a(500)
	secondo.vai_a(800)
	Conto.salta([conto, secondo])
	esigi(conto.mostrato == 500 and secondo.mostrato == 800,
			"saltandoli insieme sono rimasti a %d e %d" % [conto.mostrato, secondo.mostrato])
	etichetta.queue_free()
	altra.queue_free()

func prova_i_quadratini_della_mappa_si_vedono_davvero() -> void:
	# QUELLO CHE VESTIAMO DEVE ARRIVARE A SCHERMO.
	#
	# vesti_pieno e vesti_vuoto costruiscono una scatola per ogni stato del
	# bottone: fondo, bordo, angoli, il rosso spento per i posti lontani. Tutte
	# e due venivano buttate via da una riga sola - bottone.flat = true - perche'
	# un Button piatto in Godot NON DISEGNA il suo StyleBox. Risultato: le stanze
	# visitate, che dovevano essere quadrati rossi pieni, non si vedevano; della
	# mappa restavano i "?" e i trattini dei corridoi. Bru: «la mappa e' pessima».
	#
	# Nessuna prova poteva accorgersene, perche' tutte guardavano il testo e la
	# posizione dei bottoni - cioe' le cose che flat NON tocca. Questa guarda se
	# il fondo che abbiamo calcolato verra' disegnato.
	titolo("i quadratini della mappa si vedono davvero")
	GameState.nuova_partita()
	GameState.entra_squarcio("prova_vestito", "res://data/vuoti/meridia.json")
	GameState.nodi_visitati = ["varco", "periferia"] as Array[String]
	for id_stanza in GameState.nodi_visitati:
		GameState.sblocca_stanza(id_stanza)
	GameState.nodo_corrente = "varco"

	var mappa: Control = load("res://scenes/MappaZona.tscn").instantiate()
	add_child(mappa)
	mappa.cornice.size = Vector2(900, 700)
	mappa.ricostruisci()

	var visti := 0
	var pieni := 0
	for figlio in mappa.strato_bottoni.get_children():
		if not figlio is Button:
			continue
		var quadratino := figlio as Button
		visti += 1
		esigi(not quadratino.flat,
				"'%s' e' un bottone piatto: il fondo che gli abbiamo dato non verra' disegnato"
				% quadratino.tooltip_text)
		esigi(quadratino.has_theme_stylebox_override("normal"),
				"'%s' non ha nessuna scatola: sarebbe un rettangolo trasparente"
				% quadratino.tooltip_text)
		var scatola := quadratino.get_theme_stylebox("normal") as StyleBoxFlat
		esigi(scatola != null and scatola.bg_color.a > 0.0,
				"'%s' ha il fondo trasparente: sulla mappa non si vede niente"
				% quadratino.tooltip_text)
		# UNA STANZA DOVE SEI STATO E' PIENA, non un contorno: e' l'unico segno
		# che distingue "ci sono passato" da "l'ho solo intravisto"
		if quadratino.text == "" and scatola != null and scatola.bg_color.a > 0.6:
			pieni += 1
	esigi(visti >= 2, "sulla mappa non c'e' nessun quadratino da controllare")
	esigi(pieni >= 2,
			"solo %d quadratini pieni su %d: le stanze visitate non si distinguono"
			% [pieni, visti])
	mappa.queue_free()

func prova_ogni_segno_della_mappa_si_vede() -> void:
	# UNA MAPPA SI GUARDA, E I SEGNI SPENTI NON SI GUARDANO.
	#
	# Misurata prima di toccarla, la mappa aveva cinque segni sotto la soglia
	# delle WCAG 1.4.11 (3:1 per un comando o uno stato di un comando):
	#
	#   stanza visitata ma lontana     2,03:1
	#   corridoio percorso             2,75:1
	#   "?" di un posto noto e lontano 1,80:1
	#   "?" di un posto intravisto     1,34:1
	#   bordo di un posto intravisto   1,27:1
	#
	# Un "?" a 1,34:1 su nero e' un segno che invita ad andare da qualche parte
	# e che, letteralmente, non si vede. E niente lo segnalava: a schermo
	# c'era, il codice girava, le prove passavano.
	#
	# QUESTA NON GUARDA UN CASO, LI GUARDA TUTTI. Le tinte della mappa stanno
	# in tre funzioni pure - tinta_stanza, tinta_domanda, tinta_corridoio - e
	# qui si enumerano tutte le combinazioni dei loro argomenti. Uno stato
	# nuovo aggiunto domani ci finisce dentro senza che nessuno scriva una
	# riga, che e' l'unico modo perche' una regola cosi' regga nel tempo.
	titolo("sulla mappa ogni segno che dice qualcosa si vede davvero")
	GameState.nuova_partita()
	GameState.entra_squarcio("prova_contrasto", "res://data/vuoti/meridia.json")
	var mappa: Control = load("res://scenes/MappaZona.tscn").instantiate()
	add_child(mappa)
	var segni: Array = []
	for raggiungibile in [true, false]:
		for segreta in [true, false]:
			segni.append(["la stanza %s %s" % ["segreta" if segreta else "normale",
					"dove si arriva" if raggiungibile else "lontana"],
					mappa.tinta_stanza(segreta, raggiungibile)])
		for noto in [true, false]:
			segni.append(["il '?' di un posto %s %s" % ["noto" if noto else "intravisto",
					"dove si arriva" if raggiungibile else "lontano"],
					mappa.tinta_domanda(noto, raggiungibile)])
	for percorso in [true, false]:
		segni.append(["il corridoio %s" % ["percorso" if percorso else "solo noto"],
				mappa.tinta_corridoio(percorso)])
	for segno in segni:
		# SI MISURA IL COLORE COMPOSTO, non quello scritto: era proprio l'alfa
		# a spegnere i "?" (accento a 0,4 di opacita' sul nero fa 1,80:1, ma
		# l'accento da solo ne farebbe 4,58) e una prova che guarda il colore
		# nudo passerebbe su una schermata illeggibile
		var quanto: float = Stile.contrasto_su_sfondo(segno[1])
		esigi(quanto >= Stile.CONTRASTO_MINIMO,
				"%s sta a %.2f:1 sullo sfondo: sotto %.1f:1 non si vede"
				% [segno[0], quanto, Stile.CONTRASTO_MINIMO])

	# --- IL ROSSO E IL VERDE NON POSSONO ESSERE LO STESSO GRIGIO ---
	#
	# Il difetto piu' grave non era il buio: era che stanza normale e stanza
	# segreta si distinguevano SOLO per tinta, a 1,07:1 di luminosita' l'una
	# dall'altra. Per chi non distingue il rosso dal verde - circa otto uomini
	# su cento - erano lo stesso identico quadrato.
	for raggiungibile in [true, false]:
		var normale: Color = mappa.tinta_stanza(false, raggiungibile)
		var segreta: Color = mappa.tinta_stanza(true, raggiungibile)
		var fra_loro: float = Stile.contrasto(normale, segreta)
		esigi(fra_loro >= 1.6,
				("stanza normale e segreta (%s) stanno a %.2f:1 fra loro: e' la stessa " +
				"luminosita', e chi non distingue le tinte vede due quadrati uguali")
				% ["vicine" if raggiungibile else "lontane", fra_loro])

	# ...e nemmeno la chiarezza da sola basta: sopra la segreta ci va il
	# tratteggio, che e' l'unica variabile che sopravvive a qualunque tinta
	var righe: PackedVector2Array = Tratteggio.taglio_obliquo(Rect2(0, 0, 40, 40), 40.0)
	esigi(righe.size() == 2,
			"il tratteggio non taglia il quadrato: la stanza segreta resta liscia")
	esigi(Tratteggio.taglio_obliquo(Rect2(0, 0, 40, 40), 500.0).is_empty(),
			"il tratteggio disegna righe fuori dalla stanza")

	# e un posto lontano resta comunque PIU' SPENTO di uno dove si arriva: la
	# soglia si rispetta senza appiattire quello che la mappa deve raccontare
	var vicina: Color = mappa.tinta_stanza(false, true)
	var lontana: Color = mappa.tinta_stanza(false, false)
	esigi(Stile.luminanza(vicina) > Stile.luminanza(lontana),
			"una stanza lontana non e' piu' spenta di una vicina: la distanza non si legge")

	# --- UN SEGNO SOPRA UNA STANZA SI MISURA CONTRO LA STANZA ---
	#
	# Questo non l'aveva preso nessun numero, l'ha preso uno scatto: la
	# freccia "sei qui" era accento (#e8123c) sopra il pieno rosso di una
	# stanza (#ed1c24), cioe' 1,05:1. Il segno che dice al giocatore dove si
	# trova - l'unica cosa che su una mappa non si puo' sbagliare - non si
	# vedeva, e tutte le misure di prima guardavano il nero della pagina e
	# dicevano che andava benissimo.
	#
	# LA PRIMA VERSIONE DI QUESTA PROVA ERA TROPPO BUONA, e l'ha detto un
	# sabotaggio: rimettendo la freccia in accento la prova passava lo stesso,
	# perche' chiedeva solo che il corpo O la fascia arrivassero a 3:1 - e la
	# fascia nera sul rosso ci arriva. Lo scatto pero' mostrava un segno che
	# si leggeva come un contorno vuoto, non come un simbolo: corpo e fascia
	# erano tutti e due PIU' SCURI del fondo, e quello che si vedeva era solo
	# il filo scuro.
	#
	# La regola giusta e' che il fondo dev'essere preso IN MEZZO: uno dei due
	# piu' chiaro, l'altro piu' scuro. Cosi' una meta' del segno stacca
	# sempre, qualunque sia il pieno sotto. Bianco e nero ce l'hanno per
	# costruzione, ed e' per questo che i segni della mappa sono bianchi anche
	# quando la tentazione era di farli rossi.
	var fascia: Color = mappa.tinta_fascia()
	var corpo: Color = mappa.tinta_segno()
	var stacco: float = Stile.contrasto(corpo, fascia)
	esigi(stacco >= Stile.CONTRASTO_MINIMO,
			"corpo e fascia di un segno stanno a %.2f:1: diventa una macchia sola" % stacco)
	for raggiungibile in [true, false]:
		for segreta in [true, false]:
			var pieno: Color = mappa.tinta_stanza(segreta, raggiungibile)
			var dove := "sopra la stanza %s %s" % ["segreta" if segreta else "normale",
					"vicina" if raggiungibile else "lontana"]
			var quanto: float = maxf(Stile.contrasto(corpo, pieno),
					Stile.contrasto(fascia, pieno))
			esigi(quanto >= Stile.CONTRASTO_MINIMO,
					"un segno %s: ne' corpo ne' fascia arrivano a %.1f:1 (il meglio e' %.2f:1)"
					% [dove, Stile.CONTRASTO_MINIMO, quanto])
			var sotto: float = minf(Stile.luminanza(corpo), Stile.luminanza(fascia))
			var sopra: float = maxf(Stile.luminanza(corpo), Stile.luminanza(fascia))
			esigi(sotto < Stile.luminanza(pieno) and Stile.luminanza(pieno) < sopra,
					("un segno %s ha corpo e fascia dalla stessa parte del fondo: " +
					"si legge come un contorno vuoto, non come un simbolo") % dove)

	# --- E POI I BOTTONI VERI, NON SOLO LE FUNZIONI ---
	#
	# Le tre funzioni possono restituire colori giusti e chi le chiama
	# rimetterci sopra un velo: e' esattamente com'era prima, con la tinta
	# buona avvolta in un Color(tinta, 0.35). Qui si guarda quello che il
	# bottone porta davvero addosso, dopo che la mappa e' stata costruita.
	GameState.nodi_visitati = ["varco", "periferia"] as Array[String]
	GameState.nodo_corrente = "varco"
	mappa.cornice.size = Vector2(900, 700)
	mappa.ricostruisci()
	var controllati := 0
	for figlio in mappa.strato_bottoni.get_children():
		var quadratino := figlio as Button
		if quadratino == null:
			continue
		var scatola := quadratino.get_theme_stylebox("normal") as StyleBoxFlat
		if scatola == null:
			continue
		controllati += 1
		var bordo: float = Stile.contrasto_su_sfondo(scatola.border_color)
		esigi(bordo >= Stile.CONTRASTO_MINIMO,
				"il bordo di '%s' sta a %.2f:1: il quadratino non ha contorno"
				% [quadratino.tooltip_text, bordo])
		# il pieno si misura dove c'e' un pieno; il velo dietro a un "?" e'
		# fondo, non figura, e li' l'informazione la portano glifo e bordo
		if scatola.bg_color.a > 0.6:
			var pieno: float = Stile.contrasto_su_sfondo(scatola.bg_color)
			esigi(pieno >= Stile.CONTRASTO_MINIMO,
					"il pieno di '%s' sta a %.2f:1: la stanza dove sei stato non si vede"
					% [quadratino.tooltip_text, pieno])
		if quadratino.text != "":
			var glifo: float = Stile.contrasto_su_sfondo(
					quadratino.get_theme_color("font_color"))
			esigi(glifo >= Stile.CONTRASTO_MINIMO,
					"il '?' di '%s' sta a %.2f:1: l'invito ad andarci non si vede"
					% [quadratino.tooltip_text, glifo])
	esigi(controllati >= 2, "non c'era nessun quadratino vero da misurare")
	mappa.queue_free()

func prova_i_nomi_delle_stanze_si_leggono_senza_mouse() -> void:
	# UNA MAPPA SU CUI DEVI STRISCIARE IL CURSORE E' UN INDOVINELLO.
	#
	# Il nome di una stanza si leggeva in un modo solo: passandoci sopra col
	# mouse, uno alla volta. E solo col mouse, perche' in Godot il
	# suggerimento non compare quando un bottone prende il fuoco da tastiera -
	# chi gira la mappa senza mouse passava da un quadrato all'altro senza che
	# nessuno gli dicesse mai cosa stava guardando.
	#
	# Dentro i quadratini i nomi non ci stanno: arrivano a 27 caratteri
	# ("Vecchio centro di controllo") contro quadratini da 30 a 104 pixel, e
	# ci vorrebbe un corpo di quattro pixel. Quindi la legenda di fianco, che
	# e' quello che fa la cartografia da secoli quando le etichette non
	# entrano.
	titolo("i nomi delle stanze si leggono senza passarci sopra col mouse")
	GameState.nuova_partita()
	GameState.entra_squarcio("prova_nomi", "res://data/vuoti/meridia.json")
	GameState.nodi_visitati = ["varco", "periferia"] as Array[String]
	for id_stanza in GameState.nodi_visitati:
		GameState.sblocca_stanza(id_stanza)
	GameState.nodo_corrente = "varco"

	var mappa: Control = load("res://scenes/MappaZona.tscn").instantiate()
	add_child(mappa)
	mappa.cornice.size = Vector2(700, 600)
	mappa.ricostruisci()

	# SENZA TOCCARE NIENTE, la schermata dice gia' dove sei
	esigi(mappa.etichetta_stato.text.contains("Il varco"),
			"appena aperta, la mappa non dice dove sei: dice '%s'" % mappa.etichetta_stato.text)

	# e i nomi che conosci sono scritti per esteso, senza mouse
	var scritti: Array[String] = []
	for figlio in mappa.elenco.colonna.get_children():
		if figlio is Button:
			scritti.append(String((figlio as Button).text).strip_edges())
	esigi("Il varco" in scritti,
			"il posto dove sei non e' nella legenda: ci sono %s" % str(scritti))
	esigi("Strade di periferia" in scritti,
			"un posto che conosci non e' nella legenda: ci sono %s" % str(scritti))

	# I POSTI DI CUI NON SAI IL NOME NON CI SONO. Un "?" in una lista di nomi
	# sarebbe una riga vuota che occupa un posto: quelli si scoprono
	# camminando, e sulla mappa restano un "?"
	for nome in scritti:
		esigi(nome != "?" and nome != "",
				"nella legenda c'e' una riga senza nome: %s" % str(scritti))

	# --- IL LEGAME, CHE E' LA PARTE CHE CONTA ---
	#
	# Una legenda che non si lega alla figura e' una tabella: leggi un nome e
	# poi devi cercartelo fra ventisette quadrati uguali.
	mappa._indica_stanza("periferia")
	esigi(mappa.indicata == "periferia",
			"indicando una riga della legenda, sulla mappa non si accende niente")
	esigi(mappa.etichetta_stato.text.contains("Strade di periferia"),
			"indicando una riga, la riga di stato non dice di cosa si tratta")
	var accesa := 0
	for id_riga in mappa.elenco.righe_per_id:
		var riga: Button = mappa.elenco.righe_per_id[id_riga]
		if riga.modulate.a > 0.9:
			accesa += 1
	esigi(accesa == 1,
			"indicando una stanza si accendono %d righe della legenda invece di una" % accesa)

	# e quando si smette si torna a dire dove sei, non al vuoto
	mappa._smetti_di_indicare()
	esigi(mappa.indicata == "", "l'anello resta acceso su una stanza che non indichi piu'")
	esigi(mappa.etichetta_stato.text.contains("Il varco"),
			"smettendo di indicare, la riga di stato resta muta: '%s'"
			% mappa.etichetta_stato.text)

	# --- E DALLA LEGENDA SI CAMMINA, ESATTAMENTE COME DAL QUADRATO ---
	#
	# Non e' una comodita' in piu': e' l'unico modo di girare la mappa senza
	# mouse. La cosa da non sbagliare e' che i due non decidano in modo
	# diverso - una riga che offre un viaggio che il quadrato rifiuta, o il
	# contrario - e quello si controlla senza muovere nessuno, confrontando
	# quello con cui la riga e' stata costruita con quello che dice la mappa.
	#
	# NON SI PROVA TIRANDO IL GRILLETTO. Andare davvero cambia la scena
	# corrente, e qui dentro vuol dire segare il ramo su cui sta seduta tutta
	# la suite: la prima versione di questa prova lo faceva, e le venti prove
	# dopo fallivano una dietro l'altra senza nessun rapporto col motivo.
	for posto in mappa.posti_da_elencare():
		var id_posto := String(posto.get("id", ""))
		esigi(bool(posto.get("raggiungibile", false)) == mappa.si_puo_andare(id_posto),
				("la legenda e la mappa non sono d'accordo su '%s': una delle due " +
				"offre un viaggio che l'altra rifiuta") % id_posto)

	# e scegliendo un posto troppo lontano non ci si va, ma si sa perche'
	mappa.etichetta_stato.text = " "
	mappa._su_stanza_per_id("quartieri_profondi")
	esigi(GameState.nodo_corrente == "varco",
			"scegliendo dalla legenda un posto irraggiungibile ci si e' andati lo stesso")
	esigi(mappa.etichetta_stato.text != " ",
			"scegliendo dalla legenda un posto irraggiungibile non si e' saputo perche'")
	mappa.queue_free()

func prova_la_sede_si_legge_e_ci_sta_nello_schermo() -> void:
	# DUE DIFETTI CHE HA VISTO BRU E NON AVEVA VISTO NESSUNA PROVA.
	#
	# «alcune cose sono illeggibili»: la descrizione della stanza era scritta
	# in "narrazione", cioe' #1a1a1a, direttamente sul fondo nero. 1,21:1.
	# Quel colore e' fatto per il testo scuro DENTRO il box chiaro dei
	# dialoghi, e qui finiva sul nero della schermata - non poco leggibile:
	# invisibile. Quello che si vedeva nel suo scatto era compressione.
	#
	# «altre fuori inquadratura»: il bottone per uscire stava in fondo alla
	# colonna, con un'etichetta di trentuno lettere che andava a capo, e la
	# seconda riga finiva sotto il bordo dello schermo. La via d'uscita e' la
	# sola cosa che non ti puoi permettere di perdere.
	titolo("la Sede si legge, e ci sta dentro lo schermo")
	GameState.nuova_partita()
	var casa: Control = load("res://scenes/Sede.tscn").instantiate()
	casa.custom_minimum_size = Vector2(1280, 720)
	add_child(casa)
	casa.size = Vector2(1280, 720)
	await get_tree().process_frame
	await get_tree().process_frame

	# --- SI LEGGE ---
	var guardati := 0
	for etichetta in etichette_dentro(casa):
		if etichetta.text.strip_edges() == "":
			continue
		guardati += 1
		var quanto: float = Stile.contrasto_su_sfondo(etichetta.get_theme_color("font_color"))
		esigi(quanto >= Stile.CONTRASTO_MINIMO,
				"«%s» sta a %.2f:1 sul fondo: non si legge"
				% [etichetta.text.substr(0, 40), quanto])
	esigi(guardati >= 4, "non c'era niente da leggere nella Sede: %d etichette" % guardati)

	# --- E CI STA DENTRO ---
	#
	# Quello che scorre puo' uscire: e' il suo mestiere. Tutto il resto no.
	for figlio in bottoni_fermi(casa):
		var sotto: float = figlio.global_position.y + figlio.size.y
		esigi(sotto <= 720.0 + 1.0,
				"«%s» finisce a %d pixel, cioe' %d sotto il bordo dello schermo"
				% [figlio.text, int(sotto), int(sotto - 720.0)])
		esigi(figlio.global_position.x >= -1.0 and
				figlio.global_position.x + figlio.size.x <= 1280.0 + 1.0,
				"«%s» esce dai lati dello schermo" % figlio.text)
	casa.queue_free()

func bottoni_fermi(nodo: Node) -> Array[Button]:
	# tutti i bottoni TRANNE quelli dentro a una cosa che scorre: li' uscire
	# dal bordo e' il mestiere del contenitore, non un difetto
	var trovati: Array[Button] = []
	for figlio in nodo.get_children():
		if figlio is ScrollContainer:
			continue
		if figlio is Button:
			trovati.append(figlio as Button)
		trovati.append_array(bottoni_fermi(figlio))
	return trovati

func etichette_dentro(nodo: Node) -> Array[Label]:
	var trovate: Array[Label] = []
	for figlio in nodo.get_children():
		if figlio is Label:
			trovate.append(figlio as Label)
		trovate.append_array(etichette_dentro(figlio))
	return trovate

func prova_una_raffica_alla_volta() -> void:
	# DUE RAFFICHE A SEI MILLESIMI L'UNA DALL'ALTRA, nel registro di Bru.
	#
	# Allo stesso passo del tutorial ci arrivano due strade che non si
	# conoscono - il giro dei turni e la via del giocatore - e fra il momento
	# in cui una chiede la raffica e quello in cui parte c'e' un'attesa: il box
	# deve finire di dire "preparati!". In quell'attesa entra l'altra.
	#
	# Il guardiano dentro avvia() se ne accorgeva e chiudeva la prima, ma e'
	# una rete e basta: chi l'aspettava riceve un esito inventato, e il
	# bersaglio nel frattempo e' gia' cambiato - il danno va addosso a chi non
	# c'entra. Adesso la seconda non parte proprio.
	titolo("una raffica alla volta, anche se la chiedono in due")
	var raffica := MinigiocoCombattimento.new()
	esigi(raffica.prenota(), "la prima raffica non e' riuscita nemmeno a prenotarsi")
	esigi(not raffica.prenota(),
			"due raffiche insieme: la seconda si e' prenotata sopra la prima")
	raffica.rinuncia()
	esigi(raffica.prenota(),
			"dopo che la prima ha rinunciato, non se ne puo' piu' lanciare nessuna")

	# e il racconto di com'e' finita lo fa chi ha contato i pugni
	var tutti: Dictionary = MinigiocoCombattimento.racconto({"parati": 5, "totali": 5})
	esigi(bool(tutti.get("forte", false)),
			"pararli tutti scorre via senza farsi leggere")
	var qualcuno: Dictionary = MinigiocoCombattimento.racconto({"parati": 2, "totali": 5})
	esigi(String(qualcuno.get("testo", "")).contains("3 colpi su 5"),
			"il conto dei colpi passati e' sbagliato: %s" % qualcuno.get("testo", ""))

func prova_la_raffica_ha_un_riquadro_suo() -> void:
	# Bru: «l'evento deve trovarsi dentro il riquadro, invece vedo apparire
	# cerchi rossi sull'interfaccia di combattimento [...] quando parte un
	# evento ovviamente deve avere un riquadro suo da inizio evento a fine».
	#
	# Era esattamente cosi': il minigioco era uno strato trasparente steso
	# sopra il pannello, e i pugni atterravano sull'ECG, su Morale e Stress, su
	# MATTANZA e BOND. Nessuna prova se ne accorgeva perche' tutte guardavano
	# il calendario - quando e dove, in frazioni - e mai cosa c'era sotto.
	titolo("la raffica sta in un riquadro suo, dall'inizio alla fine")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["veronica"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	await get_tree().process_frame
	# lo scontro non deve decidere le facce da solo mentre si guarda, e l'esito
	# non deve arrivargli: dodici pugni da nove mandano a terra, e un KO in
	# mezzo a una prova cambia la scena sotto i piedi della suite
	scontro.set_process(false)
	scontro.voce.coda.clear()
	var gioco: MinigiocoCombattimento = scontro.minigioco
	gioco.finito.disconnect(scontro._minigioco_finito)
	var plancia: PlanciaCombattimento = scontro.plancia
	gioco.avvia({"nome": "Collisioni infinite", "quanti": 12, "intervallo": 1.0,
			"durata": 2.0, "danno": 9})
	await get_tree().process_frame
	await get_tree().process_frame

	# --- TUTTO IL RESTO DEL PANNELLO E' SPENTO ---
	esigi(String(plancia.faccia_adesso) == "minigioco",
			"durante la raffica il pannello mostra '%s'" % String(plancia.faccia_adesso))
	var sotto := {"i comandi": plancia.faccia_comandi, "la lista": plancia.faccia_lista,
			"il box del testo": plancia.faccia_parlato, "l'ECG": plancia.ecg,
			"MATTANZA": plancia.tasto_mattanza, "BOND": plancia.tasto_bond}
	for nome in sotto:
		esigi(not (sotto[nome] as CanvasItem).is_visible_in_tree(),
				"%s si vede sotto la raffica: i pugni ci atterrano sopra" % nome)

	# --- IL RIQUADRO STA NEL PANNELLO, E LO RIEMPIE ---
	var riquadro := gioco.riquadro
	esigi(riquadro != null and riquadro.is_visible_in_tree(), "la raffica e' partita senza riquadro")
	var pannello: Rect2 = plancia.quadrante.get_global_rect()
	var suo: Rect2 = riquadro.get_global_rect()
	esigi(pannello.grow(0.5).encloses(suo), "il riquadro della raffica esce dal pannello")
	esigi(suo.get_area() >= pannello.get_area() * 0.8,
			"il riquadro copre solo il %d%% del pannello: sotto si vede il resto"
			% int(suo.get_area() / maxf(pannello.get_area(), 1.0) * 100.0))

	# --- OGNI PUGNO STA TUTTO DENTRO ---
	var piano: Rect2 = riquadro.piano.get_global_rect()
	esigi(piano.size.x > 100.0 and piano.size.y > 60.0,
			"il piano dei pugni misura %s: non c'e' posto per niente" % str(piano.size))
	var r := riquadro.raggio()
	for pugno in gioco.raffica:
		var centro: Vector2 = riquadro.piano.global_position + riquadro.centro_di(pugno)
		esigi(piano.grow(0.5).encloses(Rect2(centro - Vector2(r, r), Vector2(r, r) * 2.0)),
				"il pugno %d esce dal riquadro" % int(pugno.indice))

	# --- E SI VEDE: il pugno sul fondo del riquadro, e la testata ---
	var fondo: Color = Stile.colore("ecg_fondo")
	esigi(Stile.contrasto(Stile.colore("pericolo"), fondo) >= Stile.CONTRASTO_MINIMO,
			"il pugno sta a %.2f:1 sul fondo del riquadro"
			% Stile.contrasto(Stile.colore("pericolo"), fondo))
	esigi(Stile.contrasto(Stile.colore("testo"), Stile.colore("fascia_nemico")) >= 3.0,
			"il titolo della raffica non si legge sulla sua fascia")

	# --- UN INIZIO E UNA FINE, NELLO STESSO RIQUADRO ---
	esigi(gioco.fase == "apertura" and riquadro.avviso.visible and riquadro.avviso.text != "",
			"la raffica parte senza dire cosa fare")
	gioco.salta()
	var passi := 0
	while gioco.fase == "raffica" and passi < 60 * 30:
		gioco.passa(1.0 / 60.0)
		passi += 1
	for i in 60:
		gioco.passa(1.0 / 60.0)
	esigi(gioco.fase == "chiusura" and riquadro.is_visible_in_tree(),
			"finiti i pugni il riquadro sparisce prima di dire com'e' andata")
	esigi(riquadro.avviso.visible and riquadro.avviso.text.contains("12"),
			"la fine della raffica non dice quanti pugni erano: «%s»" % riquadro.avviso.text)
	esigi(String(plancia.faccia_adesso) == "minigioco",
			"durante il conto finale il pannello e' gia' tornato a '%s'" % String(plancia.faccia_adesso))

	# --- E POI IL PANNELLO TORNA DI CHI ERA ---
	gioco.salta()
	esigi(not gioco.attivo and not riquadro.visible, "un clic sul conto finale non chiude la raffica")
	scontro.decidi_faccia()
	esigi(String(plancia.faccia_adesso) != "minigioco",
			"finita la raffica il pannello resta al minigioco")
	scontro.in_corso = false
	scontro.voce.coda.clear()
	scontro.queue_free()
	await get_tree().process_frame

func clic_del_mouse(dove: Vector2, premuto: bool) -> InputEventMouseButton:
	var evento := InputEventMouseButton.new()
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.pressed = premuto
	evento.position = dove
	return evento

func prova_il_pugno_si_para_quando_premi() -> void:
	# IN UN GIOCO DI TEMPISMO CONTA LA PRESSIONE. I pugni erano Button, e un
	# Button di Godot scatta di serie al RILASCIO (action_mode =
	# ACTION_MODE_BUTTON_RELEASE, BaseButton.xml): la parata veniva registrata
	# quando alzavi il dito, tutta la durata del clic dopo il momento buono.
	#
	# E IL BERSAGLIO E' IL CERCHIO: il Button prendeva anche gli angoli del
	# quadrato che lo contiene, dove a schermo non c'e' niente.
	titolo("il pugno si para quando premi, e solo dove c'e' il pugno")
	var faccia := Control.new()
	faccia.size = Vector2(700, 240)
	add_child(faccia)
	var gioco := MinigiocoCombattimento.new()
	gioco.collega(faccia)
	gioco.avvia({"quanti": 3, "intervallo": 1.0, "durata": 2.0, "danno": 5})
	await get_tree().process_frame
	var riquadro := gioco.riquadro
	gioco.salta()
	while gioco.tempo < 1.9:   # il primo pugno e' nella sua finestra piena
		gioco.passa(1.0 / 60.0)
	var sul_primo: Vector2 = riquadro.piano.position + riquadro.centro_di(gioco.raffica[0])

	riquadro._gui_input(clic_del_mouse(sul_primo, false))
	esigi(String(gioco.raffica[0].esito) == "",
			"il RILASCIO del mouse ha parato il pugno: la parata arriverebbe in ritardo di un clic")
	riquadro._gui_input(clic_del_mouse(sul_primo, true))
	esigi(String(gioco.raffica[0].esito) == "piena",
			"premere sul pugno mentre il cerchio si chiude non l'ha parato in pieno (esito '%s')"
			% String(gioco.raffica[0].esito))

	# l'angolo del quadrato intorno al secondo pugno non e' il pugno
	var r := riquadro.raggio()
	var angolo: Vector2 = riquadro.centro_di(gioco.raffica[1]) + Vector2(r, r) * 0.95
	esigi(riquadro.pugno_sotto(angolo) == -1,
			"un clic nell'angolo del quadrato intorno al pugno lo prende: il bersaglio e' il cerchio")
	riquadro._gui_input(clic_del_mouse(riquadro.piano.position + angolo, true))
	esigi(String(gioco.raffica[1].esito) == "",
			"un clic fuori dal cerchio ha giudicato il pugno lo stesso")
	gioco.concludi()
	faccia.queue_free()

func prova_le_curve_del_movimento() -> void:
	# LE CURVE SONO QUELLE DI MATERIAL, E SI MISURANO. Una cubica di Bezier si
	# risolve cercando il parametro che da' la x voluta: se la ricerca sbaglia,
	# la curva resta "una curva" e nessuno se ne accorge guardando - si vede
	# solo un menu che entra un po' strano. Qui la si confronta con una ricerca
	# lenta e sicura (la bisezione fino in fondo), punto per punto.
	titolo("le curve del movimento sono le cubiche di Material")
	var dati: Dictionary = Movimento.dati().get("curve", {})
	for nome: String in ["entrata", "uscita", "standard"]:
		var c: Array = dati.get(nome, [])
		esigi(c.size() == 4, "la curva '%s' non ha i suoi quattro numeri in stile.json" % nome)
		if c.size() != 4:
			continue
		esigi(is_zero_approx(Movimento.curva(nome, 0.0)) and is_equal_approx(Movimento.curva(nome, 1.0), 1.0),
				"la curva '%s' non parte da 0 o non arriva a 1" % nome)
		var prima := 0.0
		for passo in range(1, 100):
			var u := float(passo) / 100.0
			var y := Movimento.curva(nome, u)
			esigi(y >= prima - 1e-6, "la curva '%s' torna indietro a %.2f" % [nome, u])
			prima = y
			var attesa := bezier_lenta(float(c[0]), float(c[1]), float(c[2]), float(c[3]), u)
			if absf(y - attesa) > 1e-3:
				esigi(false, "la curva '%s' a %.2f da' %.4f, e deve dare %.4f" % [nome, u, y, attesa])
				break
	# E DICONO QUELLO CHE DEVONO DIRE: l'entrata e' quasi arrivata a meta' del
	# tempo (decelera: si posa), l'uscita a meta' del tempo e' appena partita
	# (accelera: se ne va). Se si scambiano, il menu entra come se uscisse
	esigi(Movimento.curva("entrata", 0.5) > 0.9,
			"a meta' del tempo l'entrata e' solo a %.2f: non decelera" % Movimento.curva("entrata", 0.5))
	esigi(Movimento.curva("uscita", 0.5) < 0.2,
			"a meta' del tempo l'uscita e' gia' a %.2f: non accelera" % Movimento.curva("uscita", 0.5))

func bezier_lenta(x1: float, y1: float, x2: float, y2: float, u: float) -> float:
	var basso := 0.0
	var alto := 1.0
	var t := 0.5
	for i in 60:
		t = (basso + alto) * 0.5
		var x := 3.0 * x1 * t * (1.0 - t) * (1.0 - t) + 3.0 * x2 * t * t * (1.0 - t) + t * t * t
		if x < u:
			basso = t
		else:
			alto = t
	return 3.0 * y1 * t * (1.0 - t) * (1.0 - t) + 3.0 * y2 * t * t * (1.0 - t) + t * t * t

func prova_le_molle_di_material() -> void:
	# LE MOLLE: QUANTO CI METTONO, QUANTO SUPERANO, E CHE NON DIPENDANO DAI
	# FOTOGRAMMI. Una molla scritta un passo alla volta (Eulero) fa strade
	# diverse a 30 e a 240 fotogrammi al secondo: su un computer lento il menu
	# si muoverebbe in un altro modo. Questa e' la soluzione esatta, e deve
	# arrivare nello stesso punto comunque la si tagli.
	titolo("le molle di Material, esatte a ogni frequenza di fotogrammi")
	# 1. quanto ci mettono ad assestarsi entro l'1%, e quanto superano
	for caso: Array in [["forma", 0.10, 0.20], ["colore", 0.07, 0.15], ["quinte", 0.22, 0.40]]:
		var m := Movimento.molla(String(caso[0]), 0.0)
		m.obiettivo = 1.0
		var tempo := 0.0
		var assestata := 0.0
		var massimo := 0.0
		while tempo < 1.5:
			m.passo(1.0 / 1000.0)
			tempo += 1.0 / 1000.0
			massimo = maxf(massimo, m.valore)
			if absf(m.valore - 1.0) > 0.01:
				assestata = tempo
		esigi(assestata >= float(caso[1]) and assestata <= float(caso[2]),
				"la molla '%s' si assesta in %.0f ms, e deve stare fra %.0f e %.0f"
				% [caso[0], assestata * 1000.0, float(caso[1]) * 1000.0, float(caso[2]) * 1000.0])
		# lo smorzamento di Material (0,9 e 1) non si vede rimbalzare: il
		# rimbalzo, dove serve, e' la gelatina
		esigi(massimo < 1.005, "la molla '%s' supera l'arrivo del %.1f%%: rimbalza"
				% [caso[0], (massimo - 1.0) * 100.0])
	# 2. a 30 e a 240 fotogrammi al secondo arriva nello stesso punto
	var lenta := Movimento.molla("forma", 0.0)
	var veloce := Movimento.molla("forma", 0.0)
	lenta.obiettivo = 1.0
	veloce.obiettivo = 1.0
	for i in 3:
		lenta.passo(1.0 / 30.0)
	for i in 24:
		veloce.passo(1.0 / 240.0)
	esigi(absf(lenta.valore - veloce.valore) < 1e-4,
			"dopo 100 ms la molla e' a %.4f a 30 fps e a %.4f a 240 fps: dipende dai fotogrammi"
			% [lenta.valore, veloce.valore])
	# 3. cambiare obiettivo a meta' strada non fa saltare niente: riparte da
	#    dov'e', con la velocita' che ha (il mouse che entra ed esce di corsa)
	var a_meta := Movimento.molla("forma", 0.0)
	a_meta.obiettivo = 1.0
	for i in 4:
		a_meta.passo(1.0 / 60.0)
	var li := a_meta.valore
	var velocita := a_meta.velocita
	a_meta.obiettivo = 0.0
	esigi(a_meta.valore == li and a_meta.velocita == velocita,
			"cambiando obiettivo la molla salta da %.3f a %.3f" % [li, a_meta.valore])
	# 4. anche sovrasmorzata arriva, senza superare
	var pesante := Movimento.molla("forma", 0.0)
	pesante.smorzamento = 1.6
	pesante.obiettivo = 1.0
	var oltre := 0.0
	for i in 600:
		pesante.passo(1.0 / 120.0)
		oltre = maxf(oltre, pesante.valore)
	esigi(pesante.ferma() and oltre <= 1.0 + 1e-6,
			"una molla sovrasmorzata non arriva (%.3f) o supera l'arrivo (%.3f)" % [pesante.valore, oltre])

func prova_la_cascata_chiude_con_l_azione_principale() -> void:
	# LA REGOLA DI BRU, SCRITTA COME UN NUMERO. «Gli elementi secondari appaiono
	# con leggeri ritardi, mentre i pulsanti d'azione principale chiudono la
	# sequenza». IBM Carbon: 20 ms fra un elemento e l'altro, «end with the most
	# important information, such as the primary button». E tutto entro mezzo
	# secondo: un menu che finisce di entrare dopo un secondo e' un menu lento.
	titolo("la cascata: i secondari in ordine, la principale per ultima")
	var tetto := float(Movimento.dati().get("cascata", {}).get("tetto", 0.5))
	var durata_voce := Movimento.durata("voce")
	var ritardi := Movimento.ritardi_cascata(7, 0, 0.10)
	esigi(ritardi.size() == 7, "sette voci, %d ritardi" % ritardi.size())
	for i in range(1, 7):
		esigi(ritardi[0] > ritardi[i],
				"la voce principale entra a %.0f ms, prima della voce %d (%.0f ms): non chiude la sequenza"
				% [ritardi[0] * 1000.0, i, ritardi[i] * 1000.0])
	for i in range(2, 7):
		var passo := ritardi[i] - ritardi[i - 1]
		esigi(passo >= 0.02 - 1e-6 and passo <= 0.04 + 1e-6,
				"fra la voce %d e la %d passano %.0f ms: la cascata vuole 20-40" % [i - 1, i, passo * 1000.0])
	esigi(ritardi[0] + durata_voce <= tetto + 1e-6,
			"il menu finisce di entrare a %.0f ms: oltre il mezzo secondo" % ((ritardi[0] + durata_voce) * 1000.0))
	# un elenco lungo stringe il passo invece di sforare
	var lungo := Movimento.ritardi_cascata(30, 5)
	esigi(lungo.max() + durata_voce <= tetto + 1e-6,
			"trenta voci finiscono di entrare a %.0f ms" % ((lungo.max() + durata_voce) * 1000.0))
	esigi(lungo.max() == lungo[5], "in un elenco lungo la principale non e' piu' l'ultima")
	esigi(Movimento.ritardi_cascata(0).is_empty(), "un elenco vuoto ha dei ritardi")
	var sola := Movimento.ritardi_cascata(1, 0, 0.1)
	esigi(sola.size() == 1 and is_equal_approx(sola[0], 0.1),
			"una voce sola non parte subito dopo l'intestazione: %s" % [sola])
	# e i tempi del vocabolario stanno sotto il tetto, con l'uscita piu' corta
	# dell'entrata (Material: le cose che se ne vanno non devono farsi guardare)
	for nome: String in Movimento.dati().get("durate", {}):
		esigi(Movimento.durata(nome) <= tetto, "la durata '%s' e' %.2f s: sopra il mezzo secondo"
				% [nome, Movimento.durata(nome)])
	esigi(Movimento.durata("uscita") < Movimento.durata("entrata"),
			"l'uscita dura quanto l'entrata, o di piu'")

func prova_la_gelatina_e_la_scossa() -> void:
	# LA PRESSIONE E IL RIFIUTO, come numeri. La gelatina: la X si gonfia prima,
	# la Y dopo (e' lo sfasamento a farla molle), e poi tutto torna a posto -
	# una voce che resta deformata e' una voce rotta. La scossa: comincia da
	# ferma, non esce dalla sua ampiezza, e finisce ferma.
	titolo("la gelatina della pressione e la scossa del rifiuto")
	esigi(Movimento.gelatina(0.0) == Vector2.ZERO, "la gelatina deforma la voce prima della pressione")
	var g: Dictionary = Movimento.dati().get("gelatina", {})
	var salita := float(g.get("salita", 0.05))
	var al_colmo := Movimento.gelatina(salita)
	esigi(absf(al_colmo.x - float(g.get("quanto", 0.08))) < 1e-4 and is_zero_approx(al_colmo.y),
			"al colmo della X (%.3f) la Y (%.3f) deve ancora partire: senza sfasamento non e' una gelatina"
			% [al_colmo.x, al_colmo.y])
	esigi(Movimento.gelatina(Movimento.durata_gelatina() + 0.01) == Vector2.ZERO,
			"finita la gelatina la voce resta deformata")
	esigi(Movimento.durata_gelatina() <= 0.55, "la gelatina dura %.2f s" % Movimento.durata_gelatina())
	var ampiezza := float(Movimento.dati().get("rifiuto", {}).get("ampiezza", 8))
	var picco := 0.0
	for i in 400:
		picco = maxf(picco, absf(Movimento.scossa(float(i) / 1000.0)))
	esigi(picco > ampiezza * 0.3 and picco <= ampiezza,
			"la scossa arriva a %.1f px: deve vedersi e non uscire dai %.0f" % [picco, ampiezza])
	esigi(Movimento.scossa(0.0) == 0.0 and Movimento.scossa(Movimento.durata_scossa()) == 0.0,
			"la scossa non parte o non finisce da ferma")

func prova_il_contenitore_raddrizza_i_figli() -> void:
	# LA TRAPPOLA CHE HA DECISO COM'E' FATTA UNA VOCE DI MENU. Un contenitore
	# di Godot, a ogni riordino, rimette a posto i figli: la posizione, ma
	# anche la scala e la rotazione (Container::fit_child_in_rect nel sorgente
	# 4.4 chiama set_rotation(0) e set_scale(1, 1)). Qui si guarda succedere,
	# e si guarda che il bottone di una VoceMenu - che sta sul suo binario - si
	# tenga la sua scala.
	titolo("un contenitore raddrizza i figli, il binario della voce no")
	var colonna := VBoxContainer.new()
	add_child(colonna)
	var nudo := Button.new()
	nudo.text = "nudo"
	colonna.add_child(nudo)
	var voce := VoceMenu.nuova("", "sul binario")
	colonna.add_child(voce)
	await get_tree().process_frame
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = false
	# la voce premuta, fermata al colmo della gelatina
	voce.giu()
	voce.avanza(float(Movimento.dati().get("gelatina", {}).get("salita", 0.05)))
	voce.set_process(false)
	var al_colmo := voce.bottone.scale
	nudo.scale = al_colmo
	# e a meta' gelatina la scritta cambia (succede: un contatore, un "(3)" dei
	# messaggi non letti), che e' quello che fa riordinare un contenitore
	voce.bottone.text = "sul binario, e adesso piu' lunga"
	nudo.text = "nudo, e adesso piu' lungo"
	colonna.queue_sort()
	await get_tree().process_frame
	esigi(al_colmo.x > 1.05, "la prova e' sbagliata: la voce non e' al colmo della gelatina (%s)" % al_colmo)
	esigi(nudo.scale == Vector2.ONE,
			"il contenitore non ha raddrizzato il bottone nudo: la trappola non c'e' piu', e il binario si puo' togliere")
	esigi(voce.bottone.scale.is_equal_approx(al_colmo),
			"il contenitore ha raddrizzato anche il bottone della voce (%s invece di %s): la gelatina verrebbe cancellata a meta'"
			% [voce.bottone.scale, al_colmo])
	Impostazioni.movimento_ridotto = prima
	colonna.queue_free()

func voci_della_pausa() -> Array[VoceMenu]:
	var voci: Array[VoceMenu] = []
	for figlio in Pausa.colonna.get_children():
		if figlio is VoceMenu:
			voci.append(figlio)
	return voci

func prova_il_menu_di_pausa_si_muove_ma_non_fa_aspettare() -> void:
	# IL MENU DI PAUSA, CON LA SUA COREOGRAFIA. Tre cose, e sono le regole di
	# docs/animazione.md: la cascata ha l'ordine giusto (Riprendi, l'azione
	# principale, per ultima), un clic durante l'entrata fa subito quello che
	# deve (animare si', sbarrare mai), e chiudere rimette in moto il gioco
	# nell'istante in cui chiudi, non quando il velo ha finito di sparire.
	titolo("il menu di pausa si muove, ma non fa mai aspettare")
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = false
	Pausa.apri()
	esigi(get_tree().paused, "aperto il menu il gioco non si e' fermato")
	esigi(Movimento.ultimo_suono == "apertura",
			"il menu si apre in silenzio, o col tocco della voce che ha il fuoco (%s)" % Movimento.ultimo_suono)
	var voci := voci_della_pausa()
	esigi(voci.size() == 7, "il menu ha %d voci animate, e deve averne sette" % voci.size())
	if voci.size() != 7:
		Pausa.chiudi()
		Impostazioni.movimento_ridotto = prima
		return
	var riprendi := voci[0]
	esigi(riprendi.bottone.has_focus(), "Riprendi non ha il fuoco appena il menu si apre")
	# 1. al primo istante non si vede niente, ma si puo' gia' cliccare tutto
	for voce in voci:
		esigi(voce.quota_visibile() < 0.01, "'%s' e' gia' visibile prima di entrare" % voce.bottone.text)
		esigi(voce.bottone.mouse_filter == Control.MOUSE_FILTER_STOP and not voce.bottone.disabled
				and voce.bottone.is_visible_in_tree(),
				"'%s' non si puo' cliccare mentre entra: l'animazione sbarra" % voce.bottone.text)
	# 2. l'ordine: ogni voce e' tutta dentro in un istante, e Riprendi per ultima
	var arrivate: Array[float] = []
	arrivate.resize(voci.size())
	arrivate.fill(-1.0)
	var tempo := 0.0
	var costi: Array[int] = []
	while tempo < 1.0:
		var inizio := Time.get_ticks_usec()
		for voce in voci:
			voce.avanza(1.0 / 60.0)
		Pausa.quinte.avanza(1.0 / 60.0)
		costi.append(Time.get_ticks_usec() - inizio)
		tempo += 1.0 / 60.0
		for i in voci.size():
			if arrivate[i] < 0.0 and voci[i].quota_visibile() >= 0.999:
				arrivate[i] = tempo
	for i in range(1, voci.size()):
		esigi(arrivate[i] > 0.0 and arrivate[i] < arrivate[0],
				"'%s' e' entrata a %.0f ms, Riprendi a %.0f: la principale non chiude la sequenza"
				% [voci[i].bottone.text, arrivate[i] * 1000.0, arrivate[0] * 1000.0])
	for i in range(2, voci.size()):
		esigi(arrivate[i] >= arrivate[i - 1], "le voci secondarie non entrano dall'alto in basso")
	esigi(arrivate[0] <= 0.5 + 1.0 / 60.0, "il menu finisce di entrare a %.0f ms" % (arrivate[0] * 1000.0))
	esigi(riprendi.accesa.valore > 0.99 and voci[3].accesa.valore < 0.01,
			"la lastra non sta sotto la voce che ha il fuoco")
	# IL COSTO DI UN FOTOGRAMMA. Senza finestra non si disegna, quindi questo e'
	# solo il conto delle voci e delle quinte - ma e' la parte che scriviamo
	# noi. Il fotogramma tipico (la mediana) deve stare in un sedicesimo dei
	# 16 ms che ha a 60 Hz; il peggiore, che su una macchina condivisa puo'
	# prendersi una pausa del sistema, in meta'
	costi.sort()
	var mediana := costi[floori(costi.size() / 2.0)]
	esigi(mediana < 1000, "un fotogramma tipico dell'entrata costa %d microsecondi di conti" % mediana)
	esigi(costi.back() < 8000, "il fotogramma peggiore dell'entrata costa %d microsecondi" % costi.back())
	# 3. sfiorare col mouse sposta il fuoco, e fa il suo tocco (l'orologio
	#    dei tocchi si azzera: due tocchi a meno di 30 ms sono uno solo, e la
	#    prova prima potrebbe averne appena fatto uno)
	Movimento.ultimo_sfioro = -1.0
	voci[3].sfiorata()
	esigi(voci[3].bottone.has_focus() and riprendi.accesa.obiettivo == 0.0,
			"passare col mouse su una voce non la accende, o ne lascia accese due")
	esigi(Movimento.ultimo_suono == "sfioro", "sfiorare una voce non fa il suo tocco")
	# 4. riaperto da capo, un clic su Opzioni PRIMA che il menu sia entrato
	Pausa.chiudi()
	Pausa.apri()
	var opzioni := voci_della_pausa()[5]
	esigi(opzioni.quota_visibile() < 0.01, "la prova e' sbagliata: Opzioni e' gia' entrata")
	opzioni.bottone.pressed.emit()
	esigi(Pausa.pannello == "opzioni",
			"un clic su Opzioni mentre il menu entrava non ha aperto le Opzioni (pannello: %s)" % Pausa.pannello)
	# il pannello che se ne va si vede ancora, ma non si tocca piu'
	esigi(opzioni.bottone.mouse_filter == Control.MOUSE_FILTER_IGNORE
			and opzioni.bottone.focus_mode == Control.FOCUS_NONE,
			"il pannello vecchio, mentre si dissolve, prende ancora clic o fuoco")
	# 5. chiudere: il gioco riparte subito, e il velo non ruba clic mentre sparisce
	Pausa.chiudi()
	esigi(not get_tree().paused, "chiuso il menu il gioco resta fermo finche' il velo non sparisce")
	esigi(Pausa.velo.mouse_filter == Control.MOUSE_FILTER_IGNORE,
			"il velo che si dissolve prende ancora i clic: per 150 ms il gioco non risponde")
	esigi(Movimento.ultimo_suono == "chiusura", "il menu si chiude senza il suo suono")
	Pausa.dissolvenza.custom_step(1.0)
	esigi(not Pausa.velo.visible, "finita l'uscita il velo e' ancora li'")
	# 6. E SI LEGGE. Il bianco sulla lastra, il rosso sul foglio nero, il nero
	#    sul cartellino dei Tazo: 4,5:1, la soglia WCAG del testo normale, anche
	#    se queste scritte sono grandi e ne basterebbe 3
	for coppia: Array in [["testo", "accento"], ["accento", "sfondo"], ["box_testo", "bordo_acceso"]]:
		var rapporto := Stile.contrasto(Stile.colore(String(coppia[0])), Stile.colore(String(coppia[1])))
		esigi(rapporto >= 4.5, "'%s' su '%s' sta a %.2f:1: non si legge" % [coppia[0], coppia[1], rapporto])
	Impostazioni.movimento_ridotto = prima

func prova_il_movimento_ridotto_toglie_i_movimenti_non_le_voci() -> void:
	# CON IL MOVIMENTO RIDOTTO NIENTE CORRE, MA TUTTO C'E'. Le voci si
	# dissolvono sul posto invece di scivolare; la lastra della voce col fuoco
	# c'e' subito; la parallasse sta ferma; le schegge non scoppiano; il rifiuto
	# non scuote ma suona e lampeggia. Nessuna informazione persa.
	titolo("il movimento ridotto toglie i movimenti, non le voci")
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = true
	Pausa.apri()
	var voci := voci_della_pausa()
	var storico := voci[1]
	storico.avanza(storico.ritardo + 0.03)
	esigi(storico.bottone.position.x == 0.0,
			"con il movimento ridotto la voce scivola lo stesso (x = %.1f)" % storico.bottone.position.x)
	for voce in voci:
		voce.avanza(0.6)
	for voce in voci:
		esigi(voce.quota_visibile() >= 0.999, "con il movimento ridotto '%s' non compare" % voce.bottone.text)
	esigi(voci[0].accesa.valore == 1.0, "con il movimento ridotto la voce col fuoco non ha la lastra")
	voci[2].giu()
	esigi(voci[2].premuta < 0.0, "con il movimento ridotto la voce premuta fa la gelatina")
	var in_volo := Pausa.schegge.pezzi.size()   # quelle della prova prima, ancora per aria
	Pausa.schegge.scoppia(Vector2(100, 100))
	esigi(Pausa.schegge.pezzi.size() == in_volo, "con il movimento ridotto scoppiano le schegge")
	Pausa.quinte.puntatore_finto = Vector2(0, 0)
	esigi(Pausa.quinte.dove_mira() == Vector2.ZERO, "con il movimento ridotto le quinte seguono il mouse")
	Pausa.quinte.puntatore_finto = Vector2(-1, -1)
	voci[2].rifiuta()
	esigi(voci[2].rifiutata < 0.0 and voci[2].lampo > 0.0 and Movimento.ultimo_suono == "rifiuto",
			"con il movimento ridotto il rifiuto scuote, o non lampeggia, o non suona")
	Pausa.chiudi()
	Pausa.dissolvenza.custom_step(1.0)
	Impostazioni.movimento_ridotto = prima

func prova_la_voce_inerte_dice_di_no() -> void:
	# UNA VOCE CHE NON FA NIENTE NON DEVE FINGERE DI AVER FATTO QUALCOSA. La
	# sezione del Diario in cui sei gia': premerla non riapre la pagina, e il
	# riscontro e' il rifiuto - la scossa e il suono dell'errore - non la
	# conferma con le schegge, che direbbe "fatto" quando non e' successo niente.
	titolo("la voce inerte dice di no, quella viva conferma")
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = false
	var viva := VoceMenu.nuova("diario", "viva")
	var inerte := VoceMenu.nuova("", "inerte")
	inerte.inerte = true
	add_child(viva)
	add_child(inerte)
	var scoppi := [0, 0]
	viva.scoppio.connect(func(_dove: Vector2) -> void: scoppi[0] += 1)
	inerte.scoppio.connect(func(_dove: Vector2) -> void: scoppi[1] += 1)
	await get_tree().process_frame
	viva.giu()
	viva.bottone.pressed.emit()
	esigi(Movimento.ultimo_suono == "pressione" and scoppi[0] == 1 and viva.premuta >= 0.0,
			"premere una voce viva non da' la conferma, le schegge e la gelatina")
	inerte.giu()
	inerte.bottone.pressed.emit()
	esigi(Movimento.ultimo_suono == "rifiuto" and scoppi[1] == 0 and inerte.premuta < 0.0,
			"premere una voce inerte finge una conferma invece di dire di no")
	inerte.avanza(0.02)
	esigi(absf(inerte.bottone.position.x) > 0.5, "la voce inerte dice di no senza scuotersi")
	viva.queue_free()
	inerte.queue_free()
	Impostazioni.movimento_ridotto = prima

func tasto_premuto(codice: Key) -> InputEventKey:
	var evento := InputEventKey.new()
	evento.keycode = codice
	evento.physical_keycode = codice
	evento.pressed = true
	return evento

func esc_premuto() -> InputEventAction:
	var evento := InputEventAction.new()
	evento.action = "ui_cancel"
	evento.pressed = true
	return evento

func testi_delle_voci(schermo: MenuPrincipale) -> Array[String]:
	var testi: Array[String] = []
	for v in schermo.voci:
		testi.append(v.bottone.text)
	return testi

func partita_di_prova() -> int:
	# una partita vera, scritta dal gioco, in uno slot libero: la prova la
	# cancella alla fine. Se sono tutti pieni non ne scrive (e lo dice)
	for slot in range(GameState.SLOT_MASSIMO, 0, -1):
		if not GameState.ha_salvataggio_slot(slot):
			GameState.nuova_partita()
			GameState.imposta_nome_protagonista("Prova")
			GameState.salva_slot(slot)
			return slot
	return 0

func prova_il_menu_principale_ha_piu_passi() -> void:
	# «NON CHE TI SBATTE SUBITO GLI SLOT O LA PARTITA SALVATA, ci vuole piu'
	# steps e organizzazione nella ui» (Bru). Qui si cammina il menu come lo
	# camminerebbe un giocatore: il titolo, poi il menu - dove le partite non
	# ci sono - poi le partite dietro le voci giuste, e ESC che torna indietro
	# di un passo alla volta.
	titolo("il menu principale ha piu' passi, e le partite stanno dietro le voci")
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = true   # la descrizione cambia subito, senza aspettare i tween
	MenuPrincipale.titolo_visto = false
	var scritta := partita_di_prova()
	esigi(scritta > 0, "non c'e' uno slot libero per la partita di prova")
	var schermo: MenuPrincipale = load("res://scenes/Menu.tscn").instantiate()
	add_child(schermo)
	await get_tree().process_frame
	# 1. il titolo per primo, e il menu no
	esigi(schermo.insegna != null and not schermo.menu.visible,
			"la schermata principale non comincia dal titolo: il menu arriva addosso")
	schermo._unhandled_input(tasto_premuto(KEY_ENTER))
	esigi(schermo.insegna == null and schermo.menu.visible and schermo.pagina == "principale",
			"premuto un tasto sul titolo, il menu non si apre")
	# 2. le voci del menu, e nessuna partita fra loro
	var testi := testi_delle_voci(schermo)
	esigi(testi[0] == "CONTINUA", "con una partita salvata la prima voce e' '%s', non CONTINUA" % testi[0])
	for voce_menu in ["NUOVA PARTITA", "CARICA PARTITA", "COME SI GIOCA", "COLLEZIONI", "OPZIONI", "EXTRA", "ESCI"]:
		esigi(voce_menu in testi, "nel menu principale manca %s" % voce_menu)
	for testo in testi:
		esigi(not testo.begins_with("PARTITA "), "il menu principale elenca le partite: '%s'" % testo)
	# 3. ogni voce ha la sua descrizione, e la descrizione segue il fuoco
	var titoli: Array[String] = []
	for v in schermo.voci:
		v.sfiorata()
		esigi(schermo.descrizione.titolo.text != "" and schermo.descrizione.corpo.text != "",
				"la voce '%s' non ha una descrizione" % v.bottone.text)
		titoli.append(schermo.descrizione.titolo.text)
	esigi(titoli.size() == 8 and titoli[1] != titoli[2], "la descrizione non cambia passando da una voce all'altra")
	# 4. la principale chiude la cascata
	var ultima := 0.0
	for v in schermo.voci:
		ultima = maxf(ultima, v.ritardo)
	esigi(is_equal_approx(schermo.voci[0].ritardo, ultima), "CONTINUA non entra per ultima")
	# 5. i passi: NUOVA PARTITA elenca le cinque partite; ESC torna al menu
	schermo.pagina_nuova()
	esigi(testi_delle_voci(schermo).size() == GameState.SLOT_MASSIMO and schermo.pagina == "nuova",
			"NUOVA PARTITA non elenca le %d partite" % GameState.SLOT_MASSIMO)
	schermo.voci[scritta - 1].bottone.pressed.emit()
	esigi(schermo.pagina == "sovrascrivi",
			"scegliere per una partita nuova uno slot pieno non chiede niente: la vecchia sparirebbe in silenzio")
	schermo._unhandled_input(esc_premuto())
	esigi(schermo.pagina == "nuova", "ESC dalla conferma non torna alle partite (pagina: %s)" % schermo.pagina)
	schermo._unhandled_input(esc_premuto())
	esigi(schermo.pagina == "principale", "ESC dalle partite non torna al menu (pagina: %s)" % schermo.pagina)
	# 6. CARICA: una partita libera e' inerte - dice di no e resta li'
	schermo.pagina_carica()
	var libera := 1 if scritta != 1 else 2
	if not GameState.ha_salvataggio_slot(libera):
		schermo.voci[libera - 1].bottone.pressed.emit()
		esigi(schermo.pagina == "carica" and Movimento.ultimo_suono == "rifiuto",
				"caricare una partita libera non dice di no (pagina: %s)" % schermo.pagina)
	# 7. CANCELLA: si chiede, e poi si cancella davvero
	schermo.pagina_cancella()
	schermo.voci[scritta - 1].bottone.pressed.emit()
	esigi(schermo.pagina == "conferma_cancella", "cancellare una partita non chiede conferma")
	schermo.voci[1].bottone.pressed.emit()
	esigi(not GameState.ha_salvataggio_slot(scritta), "confermata la cancellazione, la partita %d c'e' ancora" % scritta)
	# 8. ESC dal menu torna al titolo; e il titolo si vede una volta sola
	schermo.pagina_principale()
	schermo._unhandled_input(esc_premuto())
	esigi(schermo.insegna != null, "ESC dal menu principale non torna al titolo")
	schermo._unhandled_input(tasto_premuto(KEY_SPACE))
	var di_nuovo: MenuPrincipale = load("res://scenes/Menu.tscn").instantiate()
	add_child(di_nuovo)
	await get_tree().process_frame
	esigi(di_nuovo.insegna == null and di_nuovo.pagina == "principale",
			"tornando al menu (dalle Opzioni) si rivede il titolo: il passo in piu' diventa un ostacolo")
	# 9. senza partite: CONTINUA non c'e', e CARICA dice di no
	if Partite.occupate().is_empty():
		di_nuovo.pagina_principale()
		esigi(testi_delle_voci(di_nuovo)[0] == "NUOVA PARTITA" and di_nuovo.voci[1].inerte,
				"senza partite il menu offre CONTINUA, o CARICA non dice di no")
		# e dire di no vuol dire NON andarci: una voce inerte che scuote la
		# testa e poi apre la pagina lo stesso e' peggio di una voce normale
		di_nuovo.voci[1].bottone.pressed.emit()
		esigi(di_nuovo.pagina == "principale",
				"CARICA senza partite dice di no e poi apre lo stesso la pagina '%s'" % di_nuovo.pagina)
	schermo.queue_free()
	di_nuovo.queue_free()
	MenuPrincipale.titolo_visto = false
	GameState.nuova_partita()
	Impostazioni.movimento_ridotto = prima

func prova_il_menu_principale_sta_dove_sta_nel_riferimento() -> void:
	# IL LAYOUT DEL RIFERIMENTO, in frazioni dello schermo. Bru: «guarda
	# attentamente il layout PRECISO di questa schermata». Misurato sul menu di
	# Borderlands 2 (736x414): le voci e la testata allineate al 7,8% da
	# sinistra, la testata all'8% dall'alto, la descrizione sotto l'80%, il
	# pannello in alto a destra dal 71%, i comandi in basso a destra.
	#
	# Solo misure orizzontali e ancore: senza finestra Godot non sa l'altezza
	# vera di un carattere importato (Anton risulta alto 93 pixel a corpo 31,
	# in una finestra vera 48), quindi le altezze qui mentirebbero.
	titolo("il menu principale sta dove sta nel riferimento")
	MenuPrincipale.titolo_visto = true
	var schermo: MenuPrincipale = load("res://scenes/Menu.tscn").instantiate()
	add_child(schermo)
	await get_tree().process_frame
	await get_tree().process_frame
	var schermata := schermo.size
	var testata := schermo.testata.global_position / schermata
	esigi(absf(testata.x - 0.078) < 0.01 and absf(testata.y - 0.08) < 0.01,
			"la testata sta a %s dello schermo, nel riferimento a (0.078, 0.08)" % testata)
	var testo_voci := (schermo.colonna.global_position.x + VoceMenu.SPAZIO_SEGNO) / schermata.x
	esigi(absf(testo_voci - testata.x) < 0.003,
			"le voci cominciano a %.3f e la testata a %.3f: nel riferimento sono sulla stessa riga verticale"
			% [testo_voci, testata.x])
	# la descrizione sta in fondo: appesa al fondo e cresce verso l'alto (la sua
	# altezza, senza finestra, non si puo' misurare - vedi sopra)
	esigi(schermo.descrizione.anchor_bottom >= 0.9 and schermo.descrizione.grow_vertical == Control.GROW_DIRECTION_BEGIN,
			"la descrizione non e' appesa al fondo dello schermo: nel riferimento sta in fondo")
	var pannello := Rect2(schermo.pannello.global_position, schermo.pannello.size)
	esigi(pannello.position.x / schermata.x > 0.69 and pannello.position.y / schermata.y < 0.15
			and pannello.end.x <= schermata.x - 32.0,
			"il pannello delle partite non sta in alto a destra dentro lo schermo: %s" % pannello)
	var comandi := Rect2(schermo.comandi.global_position, schermo.comandi.size)
	esigi(comandi.end.x / schermata.x <= 0.95 and comandi.end.x / schermata.x >= 0.9
			and comandi.position.y / schermata.y > 0.85,
			"i comandi non stanno in basso a destra: %s" % comandi)
	schermo.queue_free()
	MenuPrincipale.titolo_visto = false

func prova_nel_menu_principale_la_scelta_e_l_unica_cosa_calda() -> void:
	# LA TEORIA DEL COLORE DEL RIFERIMENTO, come numeri. Bru: «vedi che spazza
	# il giallo dell'opzione selezionata con lo sfondo?». Tutto quello che non e'
	# scelto sta nei blu; la scelta e' dell'unico colore caldo, dall'altra parte
	# del cerchio. E tutto si legge: le voci spente sopra il 3:1 (testo grande)
	# nel punto esatto in cui stanno sul luna park, la scelta sopra il 4,5:1 sulla
	# sua macchia, la testata e la descrizione sopra il 4,5:1.
	titolo("nel menu principale la scelta e' l'unica cosa calda, e tutto si legge")
	var scena := LunaPark.new()
	var calda := Stile.colore("accento").h * 360.0
	esigi(calda < 30.0 or calda > 330.0, "il colore della scelta non e' caldo (tinta %.0f)" % calda)
	for nome: String in ["menu_notte_alto", "menu_notte_basso", "menu_lontano", "menu_sagoma", "menu_voce",
			"menu_chiaro", "menu_scia", "menu_nebbia", "menu_riga", "menu_riga_accesa", "menu_spruzzo"]:
		var tinta := Stile.colore(nome).h * 360.0
		esigi(tinta > 180.0 and tinta < 260.0, "'%s' non sta nei blu (tinta %.0f): la scelta non sarebbe l'unica cosa calda"
				% [nome, tinta])
		var distanza := absf(tinta - calda)
		distanza = minf(distanza, 360.0 - distanza)
		esigi(distanza >= 120.0, "'%s' e la scelta distano %.0f gradi: non stanno da parti opposte" % [nome, distanza])
	for riga in 8:
		var dove := Vector2(100.0, 90.0 + 40.0 * float(riga) + 20.0)
		var fondo := scena.fondo_a(dove)
		var rapporto := Stile.contrasto(Stile.colore("menu_voce"), fondo)
		esigi(rapporto >= 3.0, "la voce %d sta a %.2f:1 sul luna park: non si legge" % [riga + 1, rapporto])
		# la scelta, in quella stessa riga: sulla macchia (quasi nera, al 90%)
		# deve stare ben sopra il 3:1 del testo grande - a 4. Il cremisi da solo
		# sul luna park nelle righe basse ci sta sotto: e' per questo che la
		# macchia c'e'
		var macchia := fondo.lerp(Stile.colore("menu_macchia"), VoceMacchia.OPACITA_MACCHIA)
		var sulla_macchia := Stile.contrasto(Stile.colore("accento"), macchia)
		esigi(sulla_macchia >= 4.0, "la voce %d scelta sta a %.2f:1 sulla sua macchia" % [riga + 1, sulla_macchia])
	esigi(Stile.contrasto(Stile.colore("menu_chiaro"), scena.fondo_a(Vector2(110, 70))) >= 4.5,
			"la testata non si legge sul cielo")
	esigi(Stile.contrasto(Stile.colore("menu_descrizione"), scena.fondo_a(Vector2(110, 640))) >= 4.5,
			"la descrizione non si legge in fondo allo schermo")
	scena.free()

func prova_la_voce_col_segno_e_la_macchia() -> void:
	# LA VOCE DEL MENU PRINCIPALE: spenta e' blu, senza segno e senza macchia;
	# scelta e' cremisi, col segno, con la macchia - e NON si sposta, perche'
	# nel riferimento non si sposta.
	titolo("la voce del menu principale: il segno e la macchia solo quando e' scelta")
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = false
	var v := VoceMacchia.crea("COLLEZIONI")
	add_child(v)
	await get_tree().process_frame
	esigi(v.segno.tinta.a < 0.01, "la voce spenta ha il segno")
	esigi(v.ultima_tinta.is_equal_approx(Stile.colore("menu_voce")), "la voce spenta non e' del blu delle voci")
	v.accendi()
	for i in 30:
		v.avanza(1.0 / 60.0)
	esigi(v.segno.tinta.a > 0.99, "la voce scelta non ha il segno")
	esigi(v.ultima_tinta.is_equal_approx(Stile.colore("accento")), "la voce scelta non e' cremisi")
	esigi(is_zero_approx(v.bottone.position.x), "la voce scelta si sposta di %.0f pixel: nel riferimento resta dov'e'"
			% v.bottone.position.x)
	# la macchia copre il segno e piu' di meta' della scritta: e' lei che da'
	# al cremisi il contrasto che sul blu non ha
	var testo := v.bottone.size.x - VoceMenu.SPAZIO_SEGNO - VoceMenu.MARGINE_DESTRO
	var fino_a := -VoceMacchia.SPORGE_MACCHIA + (VoceMacchia.SPORGE_MACCHIA + VoceMenu.SPAZIO_SEGNO
			+ testo * VoceMacchia.QUOTA_TESTO_COPERTO)
	esigi(fino_a >= VoceMenu.SPAZIO_SEGNO + testo * 0.5, "la macchia si ferma prima di meta' della scritta")
	esigi(Geometry2D.triangulate_polygon(v.forma).size() > 0, "la macchia e' un poligono che si incrocia: non si disegna")
	v.queue_free()
	Impostazioni.movimento_ridotto = prima

func tasto_esc_dentro(comandi: Control, schermo: Rect2) -> bool:
	# «ESC Indietro» c'e', si vede ed e' tutto dentro lo schermo
	for figlio in comandi.get_children():
		if figlio is Tasto and figlio.is_visible_in_tree():
			var bottone := (figlio as Tasto).get_child(0) as Button
			if bottone.text == "ESC":
				return schermo.encloses(Rect2(figlio.global_position, figlio.size))
	return false

func prova_ogni_passo_del_menu_torna_indietro() -> void:
	# BRU: «vado su oggetti per tornare indietro ho solo torna a menu, dovrei
	# poter tornare indietro, se entro in opzioni non c'e' modo di tornare
	# indietro... assicuriamoci che tutti i percorsi abbiano modo di tornare
	# indietro». Qui ogni passo del menu: ha un indietro, «ESC Indietro» si vede,
	# ESC riporta al passo di prima, e ci si ritrova sulla voce da cui si era
	# partiti - non in cima.
	titolo("ogni passo del menu principale torna indietro, sulla voce giusta")
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = true
	MenuPrincipale.titolo_visto = true
	MenuPrincipale.ritorno = {}
	# con una partita salvata la prima voce e' CONTINUA: solo cosi' si vede la
	# differenza fra «torna sulla voce da cui eri partito» e «torna in cima»
	var scritta := partita_di_prova()
	var schermo: MenuPrincipale = load("res://scenes/Menu.tscn").instantiate()
	add_child(schermo)
	await get_tree().process_frame
	esigi(schermo.voci[0].bottone.text == "CONTINUA", "la prova e' sbagliata: senza CONTINUA in cima non misura niente")
	var intero := Rect2(Vector2.ZERO, schermo.size)
	# le opzioni del menu, una sezione per passo, sono tutte quelle della pausa:
	# dividerle in passi non ne deve lasciare fuori nessuna
	var regolabili := func(nodo: Node) -> int:
		var quanti := 0
		for figlio in nodo.find_children("*", "", true, false):
			if figlio is Range or figlio is BaseButton:
				quanti += 1
		return quanti
	var tutte := VBoxContainer.new()
	PannelloOpzioni.costruisci(tutte)
	var nel_menu := 0
	for quale: String in PannelloOpzioni.SEZIONI:
		schermo.pagina_opzioni_di(quale)
		nel_menu += int(regolabili.call(schermo.colonna))
	esigi(nel_menu == int(regolabili.call(tutte)) and nel_menu > 0,
			"nel menu, sezione per sezione, ci sono %d opzioni e nella pausa %d: qualcuna e' rimasta fuori"
			% [nel_menu, regolabili.call(tutte)])
	tutte.free()
	schermo.pagina_opzioni()
	esigi(schermo.voci.size() == PannelloOpzioni.SEZIONI.size(),
			"OPZIONI ha %d voci per %d sezioni" % [schermo.voci.size(), PannelloOpzioni.SEZIONI.size()])
	var passi: Array[Array] = [
		[schermo.pagina_nuova, "principale", "NUOVA PARTITA"],
		[schermo.pagina_carica, "principale", "CARICA PARTITA"],
		[schermo.pagina_cancella, "carica", "CANCELLA UNA PARTITA"],
		[schermo.pagina_come_si_gioca, "principale", "COME SI GIOCA"],
		[schermo.pagina_collezioni, "principale", "COLLEZIONI"],
		[schermo.pagina_opzioni, "principale", "OPZIONI"],
		[schermo.pagina_opzioni_di.bind("Audio"), "opzioni", "AUDIO"],
		[schermo.pagina_opzioni_di.bind("Grafica"), "opzioni", "GRAFICA"],
		[schermo.pagina_opzioni_di.bind("Accessibilità"), "opzioni", "ACCESSIBILITÀ"],
		[schermo.pagina_extra, "principale", "EXTRA"],
		[schermo.pagina_codice, "extra", "CARICA UN CODICE"],
	]
	for passo in passi:
		(passo[0] as Callable).call()
		var nome := schermo.pagina
		await get_tree().process_frame
		esigi(schermo.indietro_da_qui.is_valid(), "dal passo '%s' non si torna indietro" % nome)
		esigi(tasto_esc_dentro(schermo.comandi, intero),
				"nel passo '%s' «ESC Indietro» non c'e' o esce dallo schermo" % nome)
		schermo._unhandled_input(esc_premuto())
		var col_fuoco := schermo.voce_col_fuoco()
		esigi(schermo.pagina == String(passo[1]),
				"ESC dal passo '%s' porta a '%s', e doveva portare a '%s'" % [nome, schermo.pagina, passo[1]])
		esigi(col_fuoco != null and col_fuoco.bottone.text == String(passo[2]),
				"tornando da '%s' il fuoco e' su '%s', e doveva tornare su %s: si ricomincia da capo invece che da dove si era"
				% [nome, col_fuoco.bottone.text if col_fuoco != null else "niente", passo[2]])
	# e dalla collezione (una schermata a parte) si torna su COLLEZIONI, sulla
	# voce da cui si era usciti
	MenuPrincipale.ritorno = {"pagina": "collezioni", "fuoco": "OGGETTI"}
	var rientro: MenuPrincipale = load("res://scenes/Menu.tscn").instantiate()
	add_child(rientro)
	await get_tree().process_frame
	var su := rientro.voce_col_fuoco()
	esigi(rientro.pagina == "collezioni" and su != null and su.bottone.text == "OGGETTI",
			"tornando dagli Oggetti si ritrova '%s' invece di COLLEZIONI su OGGETTI" % rientro.pagina)
	esigi(MenuPrincipale.ritorno.is_empty(), "il ritorno resta segnato: la prossima volta si tornerebbe li' di nuovo")
	schermo.queue_free()
	rientro.queue_free()
	if scritta > 0:
		GameState.elimina_slot(scritta)
	MenuPrincipale.titolo_visto = false
	GameState.nuova_partita()
	Impostazioni.movimento_ridotto = prima

func prova_senza_nome_si_chiede_se_restare_anonimo() -> void:
	# Bru: «nella scelta del personaggio in nuova partita, se non e' immesso un
	# nome deve esserci un pop up che chiede: vuoi rimanere anonimo?»
	titolo("senza un nome, prima di cominciare si chiede se restare anonimi")
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = true
	MenuPrincipale.titolo_visto = true
	var schermo: MenuPrincipale = load("res://scenes/Menu.tscn").instantiate()
	var partenze := [0]
	schermo.al_via = func() -> void: partenze[0] += 1
	add_child(schermo)
	await get_tree().process_frame
	schermo.pagina_chi_sei(1)
	GameState.sesso_protagonista = Testi.FEMMINILE
	schermo.mostra_chi_sei("")
	await get_tree().process_frame
	schermo.campo_nome.text = "   "
	schermo.comincia()
	await get_tree().process_frame
	var aperta := schermo.domanda
	esigi(partenze[0] == 0, "col nome vuoto la partita e' cominciata senza chiedere niente")
	esigi(aperta != null and is_instance_valid(aperta) and aperta.is_inside_tree(),
			"col nome vuoto non si e' aperta nessuna domanda")
	if aperta != null and is_instance_valid(aperta):
		var detto := ""
		for etichetta in aperta.find_children("*", "Label", true, false):
			detto += (etichetta as Label).text + " "
		esigi(detto.findn("anonima") != -1,
				"la domanda non chiede se restare anonima (per lei): dice «%s»" % detto.strip_edges())
		esigi(aperta.voci.size() == 2 and aperta.voci[0].bottone.has_focus(),
				"la domanda non ha il fuoco sul si': da tastiera non si risponde")
		# il fuoco non scappa sotto il velo
		var giu := NodePath(aperta.voci[0].bottone.focus_neighbor_bottom)
		esigi(aperta.voci[0].bottone.get_node_or_null(giu) == aperta.voci[1].bottone,
				"dalla prima risposta la freccia giu' porta fuori dalla domanda")
		# un secondo COMINCIA non ne apre un'altra sopra
		schermo.comincia()
		var quante := 0
		for figlio in schermo.get_children():
			if figlio is Domanda:
				quante += 1
		esigi(quante == 1, "premendo di nuovo COMINCIA si sono aperte %d domande una sopra l'altra" % quante)
		# ESC vuol dire no: si resta sulla pagina, col fuoco sul nome
		aperta._unhandled_input(esc_premuto())
		await get_tree().process_frame
		esigi(partenze[0] == 0, "rispondendo no la partita e' cominciata lo stesso")
		esigi(schermo.pagina == "chi_sei", "rispondendo no si e' finiti in '%s'" % schermo.pagina)
		esigi(schermo.campo_nome.has_focus(), "rispondendo no il fuoco non torna sul nome da scrivere")
	# si': si parte, anonimi
	schermo.comincia()
	await get_tree().process_frame
	if schermo.domanda != null and is_instance_valid(schermo.domanda):
		schermo.domanda.voci[0].scelta.emit()
	esigi(partenze[0] == 1, "rispondendo si' la partita non e' cominciata")
	# e col nome scritto non si chiede niente
	schermo.campo_nome.text = "Bru"
	schermo.comincia()
	esigi(partenze[0] == 2, "col nome scritto la partita non parte al primo COMINCIA")
	schermo.queue_free()
	GameState.sesso_protagonista = Testi.MASCHILE
	GameState.nuova_partita()
	MenuPrincipale.titolo_visto = false
	Impostazioni.movimento_ridotto = prima

func prova_come_si_gioca_disegna_i_tasti_veri() -> void:
	# Bru: «il come si gioca non deve essere cosi' ma avere una spiegazione
	# grafica con i tasti da tastiera o mouse sui comandi come in un gioco
	# professionale». Tre cose da tenere: la tavola c'e' e segue la voce accesa;
	# ogni tasto che disegna e' DAVVERO quello che fa quella cosa; e se ne va
	# quando si cambia passo, restituendo il posto alle partite.
	titolo("come si gioca: i tasti disegnati sono quelli veri")
	var mouse := ["CLIC", "ROTELLA"]
	for nome in TavolaComandi.tasti_usati():
		if nome in mouse:
			continue
		esigi(TavolaComandi.AZIONE_DI.has(nome),
				"la tavola disegna il tasto «%s», che non corrisponde a nessun comando del gioco" % nome)
		if not TavolaComandi.AZIONE_DI.has(nome):
			continue
		var azione := String(TavolaComandi.AZIONE_DI[nome][0])
		var tasto := int(TavolaComandi.AZIONE_DI[nome][1])
		var legato := false
		for evento in InputMap.action_get_events(azione):
			if evento is InputEventKey and (int((evento as InputEventKey).keycode) == tasto
					or int((evento as InputEventKey).physical_keycode) == tasto):
				legato = true
		esigi(legato, "la tavola dice che «%s» serve a '%s', ma quel tasto non e' legato a quell'azione"
				% [nome, azione])
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = true
	MenuPrincipale.titolo_visto = true
	var schermo: MenuPrincipale = load("res://scenes/Menu.tscn").instantiate()
	add_child(schermo)
	await get_tree().process_frame
	schermo.pagina_come_si_gioca()
	await get_tree().process_frame
	esigi(schermo.quadro != null and is_instance_valid(schermo.quadro) and schermo.quadro.visible,
			"in COME SI GIOCA non c'e' nessuna tavola dei comandi")
	esigi(not schermo.pannello.visible, "in COME SI GIOCA le partite restano a schermo, sotto la tavola")
	if schermo.quadro != null and is_instance_valid(schermo.quadro):
		for v in schermo.voci:
			v.bottone.grab_focus()
			await get_tree().process_frame
			var quale := String(v.bottone.text)
			esigi(schermo.quadro.categoria == quale,
					"accesa la voce %s, la tavola mostra ancora '%s'" % [quale, schermo.quadro.categoria])
			var attese: Array = (TavolaComandi.CATEGORIE.get(quale, {}) as Dictionary).get("righe", [])
			esigi(schermo.quadro.righe.get_child_count() == attese.size(),
					"la tavola di %s ha %d righe invece di %d" % [quale, schermo.quadro.righe.get_child_count(), attese.size()])
			var tappi := schermo.quadro.find_children("*", "Control", true, false).filter(
					func(n: Node) -> bool: return n is TappoTasto)
			esigi(tappi.size() >= attese.size(),
					"la tavola di %s ha %d tasti disegnati per %d righe: qualche riga e' solo testo"
					% [quale, tappi.size(), attese.size()])
	schermo._unhandled_input(esc_premuto())
	await get_tree().process_frame
	esigi(schermo.quadro == null, "tornando indietro la tavola dei comandi resta a schermo")
	esigi(schermo.pannello.visible, "tornando indietro le partite non tornano al loro posto")
	schermo.queue_free()
	MenuPrincipale.titolo_visto = false
	Impostazioni.movimento_ridotto = prima

func altezza_vera_della_tavola(tavola: TavolaComandi) -> float:
	# LA TAVOLA ALTA COME SAREBBE IN UNA FINESTRA VERA. Senza finestra Godot
	# sbaglia le altezze dei caratteri (vedi altezza_vera), quindi la si
	# ricostruisce: la testata, e per ogni riga le righe di testo - contate alla
	# larghezza vera, che invece e' giusta - o l'altezza dei tasti, la piu' alta.
	var riga_testo := altezza_vera("res://art/font/arrotondato.ttf", Stile.dimensione("minuscolo"))
	var alta := altezza_vera("res://art/font/titolo.ttf", 20) + 12.0 + float(TavolaComandi.MARGINE) + 6.0
	var righe := tavola.righe.get_children()
	for riga in righe:
		var azione: Label = null
		for etichetta in (riga as Node).find_children("*", "Label", true, false):
			if (etichetta as Label).autowrap_mode != TextServer.AUTOWRAP_OFF:
				azione = etichetta
		var quante := righe_di(azione.text, Caratteri.tondo(700), Stile.dimensione("minuscolo"),
				azione.size.x) if azione != null else 1
		alta += maxf(TavolaComandi.ALTA_RIGA - 10.0, quante * riga_testo) + 10.0
	return alta + 6.0 * maxf(righe.size() - 1, 0)

func prova_le_collezioni_tornano_indietro() -> void:
	# ALBUM, BESTIARIO, OGGETTI: si esce con ESC o con «ESC Indietro» (che si
	# vede), si scorre con le frecce, e ESC li' non apre la pausa - non c'e'
	# nessuna partita da mettere in pausa.
	titolo("le collezioni hanno il loro indietro, e si scorrono con i tasti")
	for nome_scena: String in ["Album", "Bestiario", "Compendio"]:
		var percorso := "res://scenes/%s.tscn" % nome_scena
		esigi(percorso in Pausa.SCENE_ESCLUSE, "ESC nella schermata %s apre la pausa invece di tornare indietro" % nome_scena)
		var schermo: Collezione = load(percorso).instantiate()
		var tornato := [0]
		schermo.torna = func() -> void: tornato[0] += 1
		add_child(schermo)
		await get_tree().process_frame
		await get_tree().process_frame
		var intero := Rect2(Vector2.ZERO, schermo.size)
		esigi(tasto_esc_dentro(schermo.comandi, intero), "in %s «ESC Indietro» non c'e' o esce dallo schermo" % nome_scena)
		schermo._unhandled_input(esc_premuto())
		esigi(tornato[0] == 1, "ESC in %s non torna indietro" % nome_scena)
		var giu := InputEventAction.new()
		giu.action = "ui_down"
		giu.pressed = true
		var prima_riga := schermo.scorri.scroll_vertical
		schermo._unhandled_input(giu)
		var si_puo := schermo.lista.get_combined_minimum_size().y > schermo.scorri.size.y
		esigi(not si_puo or schermo.scorri.scroll_vertical > prima_riga,
				"in %s la freccia giu' non fa scorrere l'elenco: senza mouse non si arriva in fondo" % nome_scena)
		schermo.queue_free()

func righe_di(testo: String, carattere: Font, corpo: int, largo: float) -> int:
	# quante righe fa un testo a questa larghezza. Le larghezze delle lettere
	# Godot le sa anche senza finestra; le altezze no - per questo si contano
	# le righe e non i pixel
	var paragrafo := TextParagraph.new()
	paragrafo.add_string(testo, carattere, corpo)
	paragrafo.width = largo
	paragrafo.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
	return paragrafo.get_line_count()

func ultima_riga_di(testo: String, carattere: Font, corpo: int, largo: float) -> String:
	# l'ultima riga dell'ultimo capoverso, com'e' andata a capo
	var paragrafo := TextParagraph.new()
	paragrafo.add_string(testo, carattere, corpo)
	paragrafo.width = largo
	paragrafo.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
	var dove := paragrafo.get_line_range(paragrafo.get_line_count() - 1)
	return testo.substr(dove.x, dove.y - dove.x).strip_edges()

func prova_ogni_cosa_ha_il_suo_spazio() -> void:
	# «CHE OGNI COSA ABBIA IL SUO SPAZIO NECESSARIO» (Bru). Ogni passo del menu
	# e ogni collezione, col testo normale e con «testo piu' grande» - che
	# ingrandisce l'interfaccia del 25% e lascia 1024x576: le voci finiscono
	# prima della zona della descrizione e non toccano il pannello; il pannello,
	# la testata e i comandi stanno dentro lo schermo; ogni descrizione fa al
	# massimo un titolo e tre righe, e titolo e righe - alte come sono davvero,
	# lette dal file del carattere - stanno nella loro zona.
	titolo("ogni cosa del menu ha il suo spazio, anche col testo piu' grande")
	var prima := Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = true
	# le altezze vere delle righe: senza finestra Godot le sbaglia (in questo
	# progetto anche leggendo il file), quindi si leggono dalle tabelle del
	# carattere, che sono quello che Godot usa in una finestra vera
	# il conto torna con quello misurato in una finestra vera: se leggesse male
	# il file direbbe zero, e ogni cosa «ci starebbe»
	esigi(altezza_vera("res://art/font/titolo.ttf", 31) == 48.0 and altezza_vera("res://art/font/arrotondato.ttf", 18) == 26.0,
			"l'altezza letta dal file del carattere non e' quella vera (Anton 31: %.0f invece di 48; Nunito 18: %.0f invece di 26)"
			% [altezza_vera("res://art/font/titolo.ttf", 31), altezza_vera("res://art/font/arrotondato.ttf", 18)])
	var alta_descrizione := altezza_vera("res://art/font/titolo.ttf", Stile.dimensione("corpo")) \
			+ MenuPrincipale.RIGHE_DESCRIZIONE * altezza_vera("res://art/font/arrotondato.ttf", Stile.dimensione("minuscolo"))
	for scala in [1.0, 1.25]:
		get_tree().root.content_scale_factor = scala
		MenuPrincipale.titolo_visto = true
		var schermo: MenuPrincipale = load("res://scenes/Menu.tscn").instantiate()
		add_child(schermo)
		await get_tree().process_frame
		await get_tree().process_frame
		var intero := Rect2(Vector2.ZERO, schermo.size)
		var zona := (MenuPrincipale.FINE_DESCRIZIONE - MenuPrincipale.ZONA_DESCRIZIONE) * intero.size.y
		esigi(alta_descrizione <= zona, "a scala %.2f la descrizione (%.0f pixel) non sta nella sua zona (%.0f)"
				% [scala, alta_descrizione, zona])
		var largo_descrizione := MenuPrincipale.LARGO_DESCRIZIONE * intero.size.x
		for passo: Callable in [schermo.pagina_principale, schermo.pagina_nuova, schermo.pagina_carica,
				schermo.pagina_cancella, schermo.pagina_come_si_gioca, schermo.pagina_collezioni,
				schermo.pagina_opzioni, schermo.pagina_opzioni_di.bind("Audio"), schermo.pagina_opzioni_di.bind("Grafica"),
				schermo.pagina_opzioni_di.bind("Accessibilità"), schermo.pagina_extra, schermo.pagina_codice,
				schermo.pagina_chi_sei.bind(1)]:
			passo.call()
			await get_tree().process_frame
			await get_tree().process_frame
			controlla_lo_spazio(schermo, intero, scala)
			for v in schermo.voci:
				v.sfiorata()
				await get_tree().process_frame
				controlla_la_tavola(schermo, intero, scala)
				var titolo_scritto := schermo.descrizione.titolo.text
				var corpo_scritto := schermo.descrizione.corpo.text
				esigi(righe_di(titolo_scritto, Caratteri.titolo(), Stile.dimensione("corpo"), largo_descrizione) == 1,
						"a scala %.2f il titolo «%s» va a capo" % [scala, titolo_scritto])
				# il corpo si misura largo com'e' davvero: bilanciato, e' piu'
				# stretto della sua zona
				var largo_corpo := schermo.descrizione.corpo.size.x
				var righe := righe_di(corpo_scritto, Caratteri.tondo(650), Stile.dimensione("minuscolo"), largo_corpo)
				esigi(righe <= MenuPrincipale.RIGHE_DESCRIZIONE,
						"a scala %.2f la descrizione di '%s' fa %d righe: esce dalla sua zona" % [scala, v.bottone.text, righe])
				var ultima := ultima_riga_di(corpo_scritto, Caratteri.tondo(650), Stile.dimensione("minuscolo"), largo_corpo)
				esigi(righe <= 1 or " " in ultima,
						"a scala %.2f la descrizione di '%s' lascia «%s» da sola sull'ultima riga"
						% [scala, v.bottone.text, ultima])
		schermo.queue_free()
		for nome_scena: String in ["Album", "Bestiario", "Compendio"]:
			var collezione: Collezione = load("res://scenes/%s.tscn" % nome_scena).instantiate()
			add_child(collezione)
			await get_tree().process_frame
			await get_tree().process_frame
			var elenco := Rect2(collezione.scorri.global_position, collezione.scorri.size)
			var tasti := Rect2(collezione.comandi.global_position, collezione.comandi.size)
			esigi(intero.encloses(elenco) and elenco.end.y <= tasti.position.y,
					"a scala %.2f l'elenco di %s esce dallo schermo o finisce sotto i comandi" % [scala, nome_scena])
			esigi(intero.encloses(tasti), "a scala %.2f i comandi di %s escono dallo schermo" % [scala, nome_scena])
			var barra := collezione.scorri.get_v_scroll_bar()
			var fine_lista := collezione.lista.global_position.x + collezione.lista.size.x
			esigi(not barra.visible or fine_lista <= barra.global_position.x - 12.0,
					"a scala %.2f l'elenco di %s finisce a %.0f, attaccato alla barra che scorre (%.0f)"
					% [scala, nome_scena, fine_lista, barra.global_position.x])
			collezione.queue_free()
	get_tree().root.content_scale_factor = 1.0
	MenuPrincipale.titolo_visto = false
	GameState.nuova_partita()
	Impostazioni.movimento_ridotto = prima

func altezza_vera(percorso: String, corpo: int) -> float:
	# L'ALTEZZA DI UNA RIGA, DAL FILE DEL CARATTERE: la tabella 'head' dice in
	# quante unita' e' diviso un em, la 'hhea' quanto sale e quanto scende. Godot
	# in una finestra vera fa esattamente questo conto, arrotondando per eccesso
	# la salita e la discesa (Anton a corpo 31: 37 + 11 = 48, misurato)
	var dati := FileAccess.get_file_as_bytes(percorso)
	dati.reverse()   # decode_* legge in little endian, il TTF e' big endian
	var lungo := dati.size()
	var leggi_u16 := func(da: int) -> int: return dati.decode_u16(lungo - da - 2)
	var leggi_u32 := func(da: int) -> int: return dati.decode_u32(lungo - da - 4)
	var tabelle := {}
	for i in int(leggi_u16.call(4)):
		var dove := 12 + 16 * i
		var nome := PackedByteArray([dati[lungo - dove - 1], dati[lungo - dove - 2],
				dati[lungo - dove - 3], dati[lungo - dove - 4]]).get_string_from_ascii()
		tabelle[nome] = int(leggi_u32.call(dove + 8))
	var unita := float(leggi_u16.call(int(tabelle["head"]) + 18))
	var sale := float(leggi_u16.call(int(tabelle["hhea"]) + 4))
	var scende := float(65536 - int(leggi_u16.call(int(tabelle["hhea"]) + 6)))
	return ceilf(sale * corpo / unita) + ceilf(scende * corpo / unita)

func controlla_la_tavola(schermo: MenuPrincipale, intero: Rect2, scala: float) -> void:
	if schermo.quadro != null and is_instance_valid(schermo.quadro):
		var tavola := Rect2(schermo.quadro.global_position, schermo.quadro.size)
		var colonna_voci := Rect2(schermo.colonna.global_position, schermo.colonna.size)
		esigi(tavola.position.x >= colonna_voci.end.x + 8.0 and tavola.end.x <= intero.end.x,
				"a scala %.2f la tavola dei comandi (%.0f..%.0f) tocca le voci (fino a %.0f) o esce dallo schermo"
				% [scala, tavola.position.x, tavola.end.x, colonna_voci.end.x])
		var fondo := tavola.position.y + altezza_vera_della_tavola(schermo.quadro)
		esigi(fondo <= MenuPrincipale.ZONA_DESCRIZIONE * intero.size.y,
				"a scala %.2f la tavola dei comandi di %s finisce a %.0f, dentro la zona della descrizione (%.0f)"
				% [scala, schermo.quadro.categoria, fondo, MenuPrincipale.ZONA_DESCRIZIONE * intero.size.y])

func controlla_lo_spazio(schermo: MenuPrincipale, intero: Rect2, scala: float) -> void:
	var nome := schermo.pagina
	var voci := Rect2(schermo.colonna.global_position, schermo.colonna.size)
	var pannello := Rect2(schermo.pannello.global_position, schermo.pannello.size)
	var tasti := Rect2(schermo.comandi.global_position, schermo.comandi.size)
	var testata := Rect2(schermo.testata.global_position, schermo.testata.size)
	esigi(voci.end.y <= MenuPrincipale.ZONA_DESCRIZIONE * intero.size.y + 1.0,
			"a scala %.2f le voci di '%s' finiscono a %.0f, dentro la zona della descrizione (%.0f)"
			% [scala, nome, voci.end.y, MenuPrincipale.ZONA_DESCRIZIONE * intero.size.y])
	esigi(voci.end.x <= pannello.position.x - 8.0,
			"a scala %.2f le voci di '%s' arrivano a %.0f e il pannello comincia a %.0f" % [scala, nome, voci.end.x, pannello.position.x])
	for parte: Array in [[pannello, "il pannello delle partite"], [tasti, "i comandi"], [testata, "la testata"]]:
		esigi(intero.encloses(parte[0]), "a scala %.2f, nel passo '%s', %s esce dallo schermo: %s"
				% [scala, nome, parte[1], parte[0]])
	var fine_descrizione := MenuPrincipale.X_TESTO + MenuPrincipale.LARGO_DESCRIZIONE
	esigi(fine_descrizione * intero.size.x <= tasti.position.x - 8.0,
			"a scala %.2f la descrizione arriva sotto i comandi" % scala)

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

# --- le Collisioni infinite: il primo minigioco -----------------------------

func prova_collisioni() -> void:
	# IL CALENDARIO DELLA RAFFICA, provato senza disegnare un pugno.
	#
	# Bru, adesso: «ogni pugno deve rimanere visibile per 2 secondi, e ne deve
	# apparire un altro ogni secondo». E prima: «deve essere molto difficile
	# pararli tutti senno sei invincibile». Le due cose stavano in piedi solo
	# separando il tempo per LEGGERE un pugno da quello per PARARLO - che e'
	# esattamente come osu! tiene separati Approach Rate e Overall Difficulty.
	titolo("le collisioni infinite: due secondi per leggere, un attimo per parare")
	var dado := RandomNumberGenerator.new()
	dado.seed = 20260914
	var raffica := Collisioni.calendario(12, 1.0, 2.0, dado)
	esigi(raffica.size() == 12, "la raffica doveva avere 12 pugni, ne ha %d" % raffica.size())

	# UNO OGNI SECONDO, E OGNUNO SI VEDE PER DUE
	for pugno in raffica:
		esigi(absf(float(pugno.istante) - float(pugno.indice) * 1.0) < 0.0001,
				"il pugno %d compare a %.3fs invece che a %d.000s: non e' uno al secondo"
				% [int(pugno.indice), float(pugno.istante), int(pugno.indice)])
		esigi(absf(float(pugno.impatto) - float(pugno.istante) - 2.0) < 0.0001,
				"il pugno %d si vede per %.2fs prima di arrivare invece che per 2"
				% [int(pugno.indice), float(pugno.impatto) - float(pugno.istante)])
	# e quindi mai piu' di due insieme: il terzo compare quando il primo arriva
	for decimo in 130:
		var adesso := float(decimo) * 0.1
		var insieme := 0
		for pugno in raffica:
			if adesso >= float(pugno.istante) and adesso < float(pugno.impatto):
				insieme += 1
		esigi(insieme <= 2, "a %.1fs ci sono %d pugni in arrivo insieme" % [adesso, insieme])

	# LEGGERE E PARARE SONO DUE NUMERI. La finestra piena e' una frazione
	# piccola del tempo in cui il pugno si vede: e' li' che sta la difficolta',
	# non nella fretta di vederlo
	for pugno in raffica:
		var piena := float(pugno.scade) - float(pugno.piena_da)
		esigi(piena > 0.0, "un pugno con la finestra piena chiusa non si para mai in pieno")
		esigi(piena < float(pugno.durata) * 0.25,
				("la parata piena dura %.2fs su %.2fs di pugno: pararli tutti non costa " +
				"niente, e Bru ha detto «senno sei invincibile»") % [piena, float(pugno.durata)])

	# LE QUATTRO RISPOSTE DI UN CLIC. E' la regola intera del minigioco
	var primo: Dictionary = raffica[0]
	esigi(Collisioni.giudica(raffica, 0, float(primo.istante) - 0.01) == "",
			"un pugno si para PRIMA di comparire")
	esigi(Collisioni.giudica(raffica, 0, float(primo.istante) + 0.001) == "striscio",
			"un pugno preso appena comparso doveva essere di striscio")
	esigi(Collisioni.giudica(raffica, 0, float(primo.impatto)) == "",
			"lo stesso pugno si giudica due volte: cliccare a ripetizione pagherebbe")
	var secondo: Dictionary = raffica[1]
	esigi(Collisioni.giudica(raffica, 1, float(secondo.impatto) - 0.05) == "piena",
			"un pugno preso mentre il cerchio si chiude non e' una parata piena")
	var terzo: Dictionary = raffica[2]
	esigi(Collisioni.giudica(raffica, 2, float(terzo.scade) + 0.01) == "",
			"un pugno si para dopo che ti ha gia' preso")

	# IL DANNO E' QUELLO CHE NON HAI FERMATO, E META' DI QUELLO CHE HAI FERMATO TARDI
	var tutti := Collisioni.calendario(10, 1.0, 2.0, dado)
	esigi(Collisioni.danno(tutti, 7) == 70,
			"dieci pugni non parati da 7 dovevano fare 70, fanno %d" % Collisioni.danno(tutti, 7))
	for i in tutti.size():
		Collisioni.giudica(tutti, i, float(tutti[i].istante) + 0.001)
	esigi(Collisioni.danno(tutti, 7) == 40,
			"dieci pugni presi di striscio da 7 dovevano fare 40 (meta' per eccesso), fanno %d"
			% Collisioni.danno(tutti, 7))
	esigi(not bool(Collisioni.esito(tutti, 7).get("perfetto", true)),
			"presi tutti in anticipo, la raffica risulta perfetta: la finestra non conta niente")
	var pieni := Collisioni.calendario(10, 1.0, 2.0, dado)
	for i in pieni.size():
		Collisioni.giudica(pieni, i, float(pieni[i].impatto))
	esigi(Collisioni.danno(pieni, 7) == 0,
			"parare tutta la raffica in pieno deve azzerare il danno: e' il patto che la rende difficile")
	esigi(bool(Collisioni.esito(pieni, 7).get("perfetto", false)),
			"una raffica tutta parata in pieno non viene riconosciuta come perfetta")

	# IL METRONOMO E' UNA SCELTA DELLA RAFFICA, non un obbligo: chi vuole i
	# pugni irregolari lo chiede con "sbandamento"
	var storta := Collisioni.calendario(12, 1.0, 2.0, dado, 1.0, -1.0, 0.35)
	var uguali := true
	for i in range(2, storta.size()):
		var questo := float(storta[i].istante) - float(storta[i - 1].istante)
		var quello := float(storta[i - 1].istante) - float(storta[i - 2].istante)
		if absf(questo - quello) > 0.001:
			uguali = false
	esigi(not uguali, "chiesto lo sbandamento, i pugni arrivano lo stesso a metronomo")

	# e due di fila non si coprono a vicenda
	# DUE PUGNI DI FILA NON SI DEVONO SOVRAPPORRE, e "sovrapporsi" si misura in
	# pixel con la misura vera del pugno - non in frazioni astratte.
	#
	# Il quadrante e' il box del combattimento: largo e basso, circa 1155 per
	# 175. Un pugno e' 0.40 del lato corto, cioe' settanta pixel. La distanza
	# minima era 0.22 del lato corto: trentotto pixel. Meta' del pugno. Si
	# sovrapponevano, e il controllo diceva di no perche' confrontava la
	# distanza con un numero che non aveva niente a che fare con quanto e'
	# grosso un pugno. Adesso e' la misura del pugno a decidere.
	var alto := 175.0
	var largo := 1155.0
	var proporzione := largo / alto
	var lato_pixel := Collisioni.LATO_PUGNO * alto
	var larga := Collisioni.calendario(14, 0.34, 0.52, dado, proporzione)
	for i in range(1, larga.size()):
		var qui := Vector2(float(larga[i].x) * largo, float(larga[i].y) * alto)
		var prima := Vector2(float(larga[i - 1].x) * largo, float(larga[i - 1].y) * alto)
		esigi(qui.distance_to(prima) >= lato_pixel,
				("due pugni di fila distano %d pixel e un pugno ne e' largo %d: "
				+ "il secondo nasce sotto la mano che ha appena parato il primo")
				% [int(qui.distance_to(prima)), int(lato_pixel)])

	# E LA RAFFICA DEVE RESTARE FITTA.
	#
	# Senza correggere la proporzione, chiedere la stessa distanza in frazioni
	# diventa sei volte piu' severo per il lungo che per il corto: i pugni
	# finiscono buttati mezzo schermo l'uno dall'altro e la raffica si
	# sparpaglia.
	#
	# E' UN EFFETTO DI MEDIA, E VA MISURATO COME TALE. Su una raffica sola
	# qualche coppia vicina capita comunque, e infatti la prima versione di
	# questa prova restava verde anche togliendo la correzione: misurava il
	# caso, non la regola. Misurato su quaranta raffiche il conto e' netto -
	# con la correzione 5.8 coppie vicine su 13, senza 3.0 - e la soglia sta
	# in mezzo.
	var vicini := 0
	var raffiche := 40
	for prova in raffiche:
		var altro_dado := RandomNumberGenerator.new()
		altro_dado.seed = 4000 + prova
		var una := Collisioni.calendario(14, 0.34, 0.52, altro_dado, proporzione)
		for i in range(1, una.size()):
			if absf(float(una[i].x) - float(una[i - 1].x)) < 0.25:
				vicini += 1
	var media := float(vicini) / float(raffiche)
	esigi(media >= 4.0,
			("i pugni nascono vicini solo %.1f volte su 13: la raffica e' sparpagliata "
			+ "su tutta la larghezza invece di arrivare addosso") % media)

func prova_tutorial_di_veronica() -> void:
	# IL COPIONE DELL'ALLENAMENTO, letto come lo legge il motore.
	#
	# Un passo che chiede un'azione che non esiste, o un oggetto che nessuno ti
	# ha dato, non fallisce: si pianta. Il tutorial aspetta per sempre una cosa
	# che non puoi fare, e da fuori sembra che il gioco si sia bloccato.
	titolo("l'allenamento con Veronica: ogni passo si puo' davvero eseguire")
	var dati: Dictionary = GameState.personaggi.get("veronica", {})
	var tutorial: Dictionary = dati.get("tutorial_combattimento", {})
	esigi(not tutorial.is_empty(), "Veronica non porta piu' lo script del tutorial")
	var passi: Array = tutorial.get("passi", [])
	esigi(passi.size() >= 5, "l'allenamento ha solo %d passi: non insegna abbastanza" % passi.size())

	var forniti: Array = tutorial.get("oggetti_forniti", [])
	var azioni_note := ["attacca", "difendi", "studia", "oggetto", "abilita", "fuggi", "leva", "minigioco"]
	var insegna_aura := false
	var insegna_mattanza := false
	var insegna_minigioco := false
	for passo in passi:
		var azione := String(passo.get("azione", ""))
		esigi(azione in azioni_note,
				"il passo chiede '%s', che non e' un'azione che il motore sa eseguire" % azione)
		if azione == "oggetto":
			var quale := String(passo.get("oggetto", ""))
			esigi(quale in forniti,
					"il passo chiede l'oggetto %s, che il tutorial non ti mette in tasca: si pianta li'" % quale)
		if azione == "abilita":
			var id_abilita := String(passo.get("id", passo.get("oggetto", "")))
			var scheda := GameState.abilita_combattimento(id_abilita)
			esigi(not scheda.is_empty(),
					"il passo chiede l'abilita' %s, che non esiste" % id_abilita)
			esigi(id_abilita in GameState.abilita_usabili(GameState.id_protagonista),
					"il passo chiede %s, che il protagonista non ha nel menu: si pianta li'" % id_abilita)
			if int(scheda.get("aura", 0)) > 0:
				insegna_aura = true
				esigi(int(passo.get("aura_protagonista", -1)) >= int(scheda.get("aura", 0)),
						"il passo chiede %s ma non prepara abbastanza aura per pagarla" % id_abilita)
			if String(scheda.get("tipo", "")) == "mattanza":
				insegna_mattanza = true
				esigi(int(passo.get("dominio_protagonista", 0)) >= int(RegoleCombattimento.dominio_pieno() / 3.0),
						"il passo insegna la Mattanza senza riempire la barra: non si accende nemmeno")
		if azione == "minigioco":
			insegna_minigioco = true
			var parametri: Dictionary = passo.get("minigioco", {})
			esigi(int(parametri.get("quanti", 0)) > 0, "una raffica senza pugni")
			esigi(int(parametri.get("danno", 0)) > 0,
					"i pugni non fanno danno: non c'e' niente da parare")

	# Bru: «il tutorial ti insegna come usare tutto nella ui ti spiega anche la
	# mattanza, l'aura, l'uso di oggetti». Le tre lezioni si contano.
	esigi(insegna_aura, "l'allenamento non insegna piu' l'aura")
	esigi(insegna_mattanza, "l'allenamento non insegna piu' la Mattanza")

	# OGNI PEZZO DELLA SCHERMATA VIENE SPIEGATO. Bru: «la prima cosa e' educare
	# il giocatore sulla schermata, guidando e spiegando ogni singolo componente
	# e come funziona, lo fara' veronica».
	#
	# Questa prova prima guardava solo il "prima" del passo 0, perche' li' stava
	# tutta la spiegazione: ventuno battute di fila. Adesso ne stanno quindici,
	# e sei sono andate dove la cosa di cui parlano si vede davvero - quindi il
	# controllo guarda LA LEZIONE INTERA, prima e dopo di ogni passo.
	#
	# Non e' un allentamento: prende ancora un pezzo tolto per sbaglio, che e' il
	# suo mestiere. Ed e' accompagnato dalla regola nuova, qui sotto.
	var lezione := ""
	for passo_qualsiasi in passi:
		for campo in ["prima", "dopo"]:
			for msg in (passo_qualsiasi as Dictionary).get(campo, []):
				lezione += String((msg as Dictionary).get("testo", "")) + " "
	for pezzo in ["Studia", "HP", "AURA", "dominio", "stress", "Morale",
			"DIFESA", "MATTANZA", "turni", "veloce"]:
		esigi(lezione.findn(String(pezzo)) != -1,
				"la lezione di Veronica non nomina piu' '%s': un pezzo della schermata resta senza spiegazione"
				% pezzo)
	esigi((passi[0] as Dictionary).get("prima", []).size() >= 12,
			"la lezione e' scesa a %d battute: non spiega piu' la schermata, la annuncia"
			% (passi[0] as Dictionary).get("prima", []).size())
	esigi(insegna_minigioco, "l'allenamento non ha piu' le Collisioni infinite")
	esigi(not tutorial.get("rivitalizzante", {}).is_empty(),
			"senza rivitalizzante, sbagliare a parare chiude il tutorial a meta'")

	# E NON SI TORNA INDIETRO. Le battute che parlano di una cosa che allo
	# START DELLO SCONTRO non e' ancora successa non possono stare nel "prima"
	# del passo 0: li' gli HP sono pieni, lo stress e' a zero, il dominio e'
	# vuoto. Il giocatore vedrebbe un valore solo e gliene verrebbero raccontati
	# tre - ed e' l'unico risultato di Andersen che sopravvive alla lettura del
	# paper intero: +40% di livelli completati con l'informazione data nel
	# momento in cui serve invece che in un blocco iniziale
	# (docs/tutorial.md 0-bis, docs/fonti/chi2012-tutorial-complessita.pdf).
	#
	# Le tre sull'ECG e sullo stress stanno adesso nel "dopo" del passo 2, che
	# porta il protagonista a 10 HP su 100: sotto QUOTA_ROSSA, quindi la linea
	# e' davvero rossa mentre Veronica ne parla.
	var apertura := ""
	for msg in (passi[0] as Dictionary).get("prima", []):
		apertura += String((msg as Dictionary).get("testo", "")) + " "
	for troppo_presto in ["verde sopra", "rossa sotto", "impazzisce"]:
		esigi(apertura.findn(String(troppo_presto)) == -1,
				"'%s' e' tornata nell'apertura: allo start non c'e' niente da guardare, la linea e' verde e lo stress a zero"
				% troppo_presto)
	esigi((passi[0] as Dictionary).get("prima", []).size() <= 16,
			"l'apertura e' risalita a %d battute: era 21, l'abbiamo portata a 15 apposta"
			% (passi[0] as Dictionary).get("prima", []).size())

func prova_rivitalizzante_di_veronica() -> void:
	# «se vai ko veronica dice [...] e usa un rivitalizzante su di te che ti
	# rida tutta la vita e fa proseguire il tutorial» (Bru).
	#
	# Cioe': durante l'allenamento andare sotto NON e' perdere. Qui si mette il
	# protagonista a terra davvero e si guarda se si rialza.
	titolo("durante l'allenamento andare KO non chiude niente")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["veronica"]
	var scena: PackedScene = load("res://scenes/Combattimento.tscn")
	var scontro: Node = scena.instantiate()
	scontro.muto = true
	scontro.limite_giri = 1
	scontro.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	add_child(scontro)
	esigi(not scontro.tutorial.is_empty(), "lo scontro con Veronica non ha caricato il tutorial")
	var eroe: Dictionary = {}
	for combattente in scontro.combattenti:
		if combattente.giocatore and combattente.id == GameState.id_protagonista:
			eroe = combattente
	esigi(not eroe.is_empty(), "nessun protagonista nello scontro")
	if not eroe.is_empty():
		# lo scontro muto si e' gia' giocato tutto dentro add_child: lo si
		# riapre a mano, se no qui sotto si misurerebbe il suo finale invece del
		# rivitalizzante
		scontro.in_corso = true
		eroe.hp = 0
		var rialzate_prima: int = scontro.rivitalizzanti_usati
		scontro._su_ko(eroe)
		esigi(int(eroe.hp) == int(eroe.hp_max),
				"il rivitalizzante non ha restituito tutta la vita: %d su %d" % [eroe.hp, eroe.hp_max])
		esigi(scontro.rivitalizzanti_usati == rialzate_prima + 1,
				"il rivitalizzante non e' stato contato")
		esigi(scontro.in_corso, "andare KO durante l'allenamento ha chiuso lo scontro")
		# e quando il copione e' finito, i rivitalizzanti sono finiti con lui
		scontro.tutorial_finito = true
		scontro.in_corso = true
		eroe.hp = 0
		scontro._su_ko(eroe)
		esigi(int(eroe.hp) == 0,
				"a tutorial finito Veronica ti rialza ancora: l'allenamento non finisce piu'")
	scontro.free()

func prova_giornata_dopo_allenamento() -> void:
	# LA GIORNATA DOPO L'ALLENAMENTO, dal risveglio agli ordini.
	#
	# Bru l'ha raccontata tutta d'un fiato: ti sveglia la dottoressa, esci, la
	# mappa stavolta e' tutta visibile, il punto esclamativo si e' spostato sulla
	# sala comunicazioni, li' ti danno la prima missione e il diario diventa un
	# data pad. Sono cinque cose incastrate: se ne salta una il giocatore resta
	# fermo in un corridoio senza sapere dove andare.
	titolo("dal risveglio in infermeria agli ordini, passo per passo")
	var dati := carica_eventi("res://data/events_intro.json")
	var nodi: Dictionary = dati.get("nodi", {})

	var risveglio: Dictionary = nodi.get("infermeria_risveglio", {})
	esigi(not risveglio.is_empty(), "manca il risveglio in infermeria")
	esigi(String(risveglio.get("flag", "")) == "rientro_infermeria",
			"il risveglio non alza il flag che apre la giornata: la mappa resta quella del mattino")
	esigi(String(risveglio.get("stanza", "")) == "infermeria",
			"il risveglio non dice in che stanza succede: sulla mappa il 'sei qui' finisce altrove "
			+ "e da li' non si cammina da nessuna parte")
	esigi(risveglio.get("sblocca_stanze", []).size() >= 8,
			"dopo il risveglio la mappa non e' tutta visibile: Bru l'ha chiesta «stavolta tutta visibile»")

	# tutti e tre gli esiti dell'allenamento portano li': un allenamento non si
	# vince e non si perde
	for id_nodo in ["veronica_carica", "veronica_animo", "veronica_maldiptesta"]:
		var scontro: Dictionary = (nodi.get(id_nodo, {}) as Dictionary).get("combattimento_automatico", {})
		esigi(String(scontro.get("se_vinci", "")) == "infermeria_risveglio"
				and String(scontro.get("se_perdi", "")) == "infermeria_risveglio",
				"%s non finisce in infermeria: l'allenamento con Veronica finisce sempre li'" % id_nodo)

	# dall'infermeria si cammina fino alla sala comunicazioni
	var mappa: Dictionary = dati.get("mappa_dungeon", {})
	var aperti: Array = Array(mappa.get("connessioni_da", {}).get("rientro_infermeria", []))
	var da_infermeria := false
	for coppia in aperti:
		if coppia.has("infermeria") and coppia.has("sala_comunicazioni"):
			da_infermeria = true
	esigi(da_infermeria,
			"dall'infermeria non si arriva alla sala comunicazioni: si esce e si resta fermi li'")

	# IL POMERIGGIO OGNI STANZA E' LA SUA. Si chiede al motore dove porta ogni
	# stanza con i flag del pomeriggio accesi, come farebbe il gioco.
	#
	# Il difetto che c'era: la sala di allenamento non aveva nessuna regola, e
	# rientrandoci dalla mappa si rigiocava tutto l'allenamento del mattino -
	# Veronica, lo scontro, di nuovo il risveglio. E dall'alloggio «Esci dalla
	# stanza» riportava li'.
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	GameState.imposta_flag("rientro_infermeria")
	var attese := {
		"alloggio": "alloggio_pomeriggio", "mensa": "mensa_pomeriggio",
		"archivio": "archivio_pomeriggio", "hangar": "hangar_pomeriggio",
		"sala_proiezione": "sala_proiezione_pomeriggio",
		"sala_allenamento": "sala_allenamento_soldati",
		"infermeria": "infermeria_reika",
		"sala_comunicazioni": "comunicazioni_convocazione",
	}
	for id_area: String in attese:
		var dove := IngressoNodo.risolvi(id_area)
		esigi(dove == String(attese[id_area]),
				"il pomeriggio '%s' porta a '%s' invece che a '%s'" % [id_area, dove, attese[id_area]])
		var pomeriggio: Dictionary = nodi.get(dove, {})
		esigi(not pomeriggio.has("combattimento_automatico"),
				"il pomeriggio '%s' fa ripartire uno scontro: e' la scena del mattino" % id_area)
		esigi(String(pomeriggio.get("stanza", dove)) == id_area,
				"'%s' non dice che succede in '%s': sulla mappa il «sei qui» finisce altrove" % [dove, id_area])
	# dove non c'e' storia c'e' solo da guardare - Bru: «nelle altre stanze ci
	# sara' disponibile solo osserva la scena» - e da li' si torna alla mappa
	for id_area in ["alloggio", "mensa", "archivio", "hangar", "sala_proiezione"]:
		var solo_scena: Dictionary = nodi.get(String(attese[id_area]), {})
		esigi(solo_scena.has("scena"), "nel pomeriggio '%s' non c'e' niente da osservare" % id_area)
		var alla_mappa := false
		for scelta in solo_scena.get("scelte", []):
			alla_mappa = alla_mappa or bool((scelta as Dictionary).get("torna_a_mappa", false))
		esigi(alla_mappa, "dal pomeriggio '%s' non si torna alla mappa" % id_area)
	# I SOLDATI, UNA VOLTA SOLA. «Se non la ascolti perdi l'occasione, questa
	# conversazione e' valida solo in questo frangente»: l'occasione si chiude
	# ENTRANDO - rispondere no, o uscire dalla mappa senza rispondere, e' non
	# averla ascoltata - e la chiude anche la convocazione
	esigi(String(nodi.get("sala_allenamento_soldati", {}).get("flag", "")) == "soldati_passati",
			"vedere i soldati non chiude l'occasione: uscendo dalla mappa senza rispondere li si ritrova")
	var ascolto := destinazioni_di(nodi.get("sala_allenamento_soldati", {}))
	esigi("soldati_conversazione" in ascolto, "dicendo si' ai soldati non si sente la conversazione")
	GameState.imposta_flag("soldati_passati")
	esigi(IngressoNodo.risolvi("sala_allenamento") == "sala_allenamento_vuota",
			"passati i soldati, la sala di allenamento li mostra ancora")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	GameState.imposta_flag("rientro_infermeria")
	GameState.imposta_flag("ordini_ricevuti")
	esigi(IngressoNodo.risolvi("sala_allenamento") == "sala_allenamento_vuota",
			"ricevuti gli ordini, i soldati sono ancora li': la conversazione valeva solo prima")
	esigi(IngressoNodo.risolvi("sala_comunicazioni") == "sala_comunicazioni_dopo",
			"ricevuti gli ordini, la sala comunicazioni ti convoca di nuovo")
	# LA DR. REIKA, SECONDA VOLTA: tre domande, due tornano alle domande, la
	# terza saluta e ti rimanda alla mappa
	var domande: Array = nodi.get("infermeria_reika", {}).get("scelte", [])
	esigi(domande.size() == 3, "la Dr. Reika offre %d scelte invece delle tre di Bru" % domande.size())
	for risposta in ["reika_organizzazione", "reika_missione"]:
		esigi(nodi.get(risposta, {}).get("scelte", []) == domande,
				"dopo '%s' non si torna alle domande" % risposta)
	var saluto_alla_mappa := false
	for scelta in nodi.get("reika_congedo", {}).get("scelte", []):
		saluto_alla_mappa = saluto_alla_mappa or bool((scelta as Dictionary).get("torna_a_mappa", false))
	esigi(saluto_alla_mappa, "salutata la Dr. Reika non si esce dall'infermeria")
	# LA CONVOCAZIONE SI ACCETTA O SI RIMANDA
	var convocazione := destinazioni_di(nodi.get("comunicazioni_convocazione", {}))
	esigi("comunicazioni_ordini" in convocazione, "dicendo si' alla convocazione non si apre il canale")
	var rimandabile := false
	for scelta in nodi.get("comunicazioni_convocazione", {}).get("scelte", []):
		rimandabile = rimandabile or bool((scelta as Dictionary).get("torna_a_mappa", false))
	esigi(rimandabile, "alla convocazione non si puo' dire di no")
	# e il data pad si chiude sulla mappa, non addosso alla Dr. Reika
	esigi(not "infermeria" in destinazioni_di(nodi.get("data_pad_istruzioni", {})),
			"chiuso il data pad si finisce in infermeria, cioe' da capo col dialogo della Dr. Reika")
	GameState.nuova_partita()

	var ordini: Dictionary = nodi.get("comunicazioni_ordini", {})
	esigi(not ordini.is_empty(), "manca la sala comunicazioni con gli ordini")
	esigi(String(ordini.get("flag", "")) == "ordini_ricevuti",
			"gli ordini non alzano il flag: il diario non diventa mai un data pad")
	var compiti_accesi := 0
	for compito in GameState.task_catalogo:
		if "ordini_ricevuti" in (compito as Dictionary).get("richiede_flags", []):
			compiti_accesi += 1
	esigi(compiti_accesi == 2,
			"il data pad si accende con %d compiti invece dei due di Bru "
			% compiti_accesi + "(esplorare il settore, e fare rapporto)")

func prova_la_prima_missione_si_sceglie_sulla_mappa() -> void:
	# Bru: «da qui sara' possibile procedere nel livello che avevamo gia'
	# creato, quello con il goblin arrabbiato: nella mappa dovrebbe essere
	# presente solo quella frattura, ti manderà in missione Veronica». Prima la
	# mappa era una didascalia - «Si esce dalla visuale di mappa» - e la
	# missione partiva da sola. Adesso Veronica la apre, sopra c'e' solo quella
	# frattura, e la scegli tu.
	titolo("la prima missione si sceglie sulla mappa stellare, e c'e' solo lei")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	var stato_prima := Transizioni.in_corso
	Transizioni.in_corso = true   # i cambi di scena si mettono in fila e basta
	Transizioni.prossima = ""
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	schermata.mostra_nodo("proiezione_veronica")
	# finite le battute della scena
	schermata.coda_messaggi.clear()
	schermata.avanza_messaggio()
	esigi(Transizioni.prossima == "res://scenes/Mappa.tscn",
			"finita la scena di Veronica non si apre la mappa stellare (si va a '%s')" % Transizioni.prossima)
	esigi(MappaStellare.missione_da_scegliere == "proiezione_partenza",
			"la mappa non sa a chi tornare scelta la meta: '%s'" % MappaStellare.missione_da_scegliere)
	schermata.queue_free()
	Transizioni.prossima = ""
	var mappa: Control = load("res://scenes/Mappa.tscn").instantiate()
	add_child(mappa)
	await get_tree().process_frame
	esigi(not mappa.bottone_sede.visible,
			"scegliendo la prima missione si puo' andare alla Sede: dalla sala di proiezione non ci si va")
	var segni: Array[Button] = []
	for figlio in mappa.strato_punti.get_children():
		if figlio is Button:
			segni.append(figlio)
	esigi(segni.size() == 1, "sulla mappa della prima missione ci sono %d fratture invece di una" % segni.size())
	if segni.size() == 1:
		esigi(segni[0].tooltip_text == "Pianure di Redenna",
				"la sola frattura della mappa e' «%s», non le Pianure di Redenna" % segni[0].tooltip_text)
		segni[0].pressed.emit()
		esigi(MappaStellare.missione_da_scegliere == "",
				"scelta la meta la mappa resta in modo «prima missione»: la prossima volta mostrerebbe ancora solo lei")
		esigi(Transizioni.prossima == "res://scenes/Main.tscn"
				and String(IngressoNodo.ultimo_esito.get("id", "")) == "proiezione_partenza",
				"scelta la meta non si torna da Veronica per partire (%s, %s)"
				% [Transizioni.prossima, IngressoNodo.ultimo_esito.get("id", "")])
		var partenza: Dictionary = GameState.eventi.get("proiezione_partenza", {})
		esigi(String(partenza.get("avvio_automatico", {}).get("id_punto", "")) == "tutorial",
				"dopo la scelta non parte la missione delle Pianure")
	mappa.queue_free()
	IngressoNodo.ultimo_esito = {}
	# e la mappa di sempre, dopo, quella frattura non la mostra piu'
	Transizioni.prossima = ""
	GameState.imposta_flag("tutorial_completato")
	var dopo: Control = load("res://scenes/Mappa.tscn").instantiate()
	add_child(dopo)
	await get_tree().process_frame
	var nomi: Array[String] = []
	for figlio in dopo.strato_punti.get_children():
		if figlio is Button:
			nomi.append((figlio as Button).tooltip_text)
	esigi(not "Pianure di Redenna" in nomi, "la prima missione resta sulla mappa anche dopo: %s" % [nomi])
	esigi(not nomi.is_empty(), "dopo la prima missione la mappa e' vuota")
	esigi(dopo.bottone_sede.visible, "sulla mappa di sempre non si torna alla Sede")
	dopo.queue_free()
	Transizioni.prossima = ""
	Transizioni.in_corso = stato_prima
	GameState.nuova_partita()

func prova_da_un_altra_schermata_arriva_il_nodo_giusto() -> void:
	# CHI ARRIVA DA UN'ALTRA SCHERMATA VEDE IL NODO IN CUI E' ENTRATO.
	#
	# Dal combattimento, dalla mappa stellare, dal menu si entra in un nodo con
	# IngressoNodo.vai_al_nodo, e Main, appena nasce, raccoglie il verdetto
	# chiedendolo per GameState.nodo_corrente - che per un nodo dentro una
	# stanza e' la STANZA. Il verdetto veniva buttato perche' il nome non
	# coincideva, si rientrava nella stanza, e la sua regola mandava altrove:
	# dopo l'allenamento non si vedeva il risveglio con la Dr. Reika ma «hai
	# dimenticato qualcosa?», e scelta la prima missione la scena di Veronica
	# ricominciava all'infinito. prova_la_prima_missione_si_sceglie_sulla_mappa
	# guardava il verdetto in partenza e passava: qui si apre la schermata vera
	# e si guarda cosa ci arriva.
	#
	# Per ogni nodo che sta in una stanza non sua, con tutti i flag della
	# stanza accesi: e' il caso in cui la stanza manda altrove, cioe' quello in
	# cui l'errore si vede.
	titolo("chi arriva da un'altra schermata vede il suo nodo, non la sua stanza")
	var stato_prima := Transizioni.in_corso
	Transizioni.in_corso = true   # i cambi di scena si mettono in fila e basta
	var provati := 0
	for file: String in ["res://data/events_intro.json", "res://data/events_tutorial.json"]:
		var nodi: Dictionary = (GameState.carica_json(file) as Dictionary).get("nodi", {})
		for id_nodo: String in nodi:
			var stanza := String((nodi[id_nodo] as Dictionary).get("stanza", id_nodo))
			if stanza == id_nodo:
				continue
			GameState.nuova_partita()
			GameState.avvia_carnivalz("prova", file)
			var regole: Variant = (GameState.eventi.get(stanza, {}) as Dictionary).get("vai_se_flag", [])
			for regola: Variant in (regole if regole is Array else [regole]):
				if regola is Dictionary and (regola as Dictionary).has("flag"):
					GameState.imposta_flag(String((regola as Dictionary)["flag"]))
			Transizioni.prossima = ""
			IngressoNodo.vai_al_nodo(id_nodo)
			if Transizioni.prossima != IngressoNodo.SCENA_EVENTI:
				continue   # un agguato, o un nodo che manda altrove: Main non c'entra
			var atteso: Dictionary = IngressoNodo.ultimo_esito.get("nodo", {})
			var schermata: Node = load(IngressoNodo.SCENA_EVENTI).instantiate()
			add_child(schermata)
			await get_tree().process_frame
			esigi(schermata.nodo_in_corso == atteso,
					"entrando in '%s' da un'altra schermata si vede un altro nodo: la stanza '%s' l'ha mandato altrove"
					% [id_nodo, stanza])
			provati += 1
			schermata.queue_free()
			await get_tree().process_frame
	esigi(provati >= 10, "provati solo %d nodi dentro una stanza: il filtro si e' ristretto" % provati)
	Transizioni.in_corso = stato_prima
	Transizioni.prossima = ""
	IngressoNodo.ultimo_esito = {}
	GameState.nuova_partita()

func sotto_il_mouse(c: Control) -> Control:
	# chi prende davvero un clic dato al centro di c: il mouse ci va come ci
	# andrebbe una mano, e si chiede alla finestra chi ha sotto. Senza finestra
	# Godot ne apre una da 64x64, e un clic li' finisce in un altro posto:
	# la si porta alla misura del gioco
	get_window().size = Vector2i(1280, 720)
	var centro := c.get_viewport().get_final_transform() \
			* (c.get_global_transform_with_canvas() * (c.size * 0.5))
	var mossa := InputEventMouseMotion.new()
	mossa.position = centro
	mossa.global_position = centro
	Input.parse_input_event(mossa)
	await get_tree().process_frame
	await get_tree().process_frame
	return get_viewport().gui_get_hovered_control()

func prova_l_icona_del_menu_si_preme_anche_mentre_si_legge() -> void:
	# LA FACCIA IN ALTO A SINISTRA APRE IL MENU, SEMPRE. Stava sotto AreaAvanza,
	# il bottone grande quanto lo schermo che fa andare avanti il testo: mentre
	# un dialogo scorreva, cliccarla mandava avanti la battuta. E subito dopo
	# aver chiuso la pausa, per 150 ms, il primo clic se lo prendeva il
	# contenitore della pausa che si stava dissolvendo. Le ha trovate tutte e
	# due l'automa; qui il mouse ci va per davvero e si chiede chi c'e' sotto.
	titolo("l'icona del menu si preme anche mentre si legge, e anche appena chiusa la pausa")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	var stato_prima := Transizioni.in_corso
	Transizioni.in_corso = true
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	schermata.mostra_nodo("infermeria_reika")
	for i in 30:
		await get_tree().process_frame
	var icona: Button = schermata.icona_menu
	esigi(schermata.area_avanza.visible, "la prova non sta guardando un dialogo che scorre")
	var sotto: Control = await sotto_il_mouse(icona)
	esigi(sotto == icona or icona.is_ancestor_of(sotto),
			"mentre il dialogo scorre, un clic sull'icona del menu lo prende «%s»: manda avanti la battuta invece di aprire il menu"
			% (String(sotto.name) if sotto != null else "nessuno"))
	Pausa.apri()
	for i in 20:
		await get_tree().process_frame
	Pausa.chiudi()
	await get_tree().process_frame
	sotto = await sotto_il_mouse(icona)
	esigi(sotto == icona or icona.is_ancestor_of(sotto),
			"appena chiusa la pausa, un clic sull'icona lo prende «%s»: la pausa che si dissolve ruba il primo clic"
			% (String(sotto.name) if sotto != null else "nessuno"))
	for i in 20:
		await get_tree().process_frame
	schermata.queue_free()
	Transizioni.in_corso = stato_prima
	Transizioni.prossima = ""
	get_window().size = Vector2i(64, 64)
	await get_tree().process_frame

func figlio_di_tipo(radice: Node, tipo: String) -> Node:
	for n in radice.find_children("*", tipo, true, false):
		return n
	return null

func prova_arrivando_nelle_pianure_la_guida_spiega_la_mappa() -> void:
	# BRU, IL NUOVO ARRIVO: stupore, un beep dal data pad, la Guida. «Qui si apre
	# la mappa e si spiega come funziona il livello e le fratture»: si apre la
	# mappa di zona VERA, lei parla li' sopra, e il «tasto di chiusura» che nel
	# testo preme il protagonista lo premi tu. Lei protesta, e da li' c'e' la sua
	# icona. Si guarda cosa arriva a schermo, non solo cosa c'e' nei dati.
	titolo("arrivando nelle Pianure la Guida spiega la mappa, e il tasto di chiusura lo premi tu")
	GameState.nuova_partita()
	GameState.sesso_protagonista = "f"
	GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
	var sequenza: Array = GameState.eventi["inizio"]["sequenza"]
	var chi: Array[String] = []
	for msg: Dictionary in sequenza.slice(2):
		chi.append(String(msg.get("chi", "")))
	esigi(chi == ["anonimo", "anonimo", "anonimo", "anonimo", "ignoto", "anonimo", "anonimo", "guida", "anonimo", "guida"],
			"all'arrivo parlano, nell'ordine, %s: non e' il testo di Bru" % str(chi))
	esigi(String(sequenza[6].get("suono", "")) == "data_pad", "il «beep! Beep!» non suona come il data pad")
	var stato_prima := Transizioni.in_corso
	Transizioni.in_corso = true
	Transizioni.prossima = ""
	IngressoNodo.vai_al_nodo("inizio")
	var arrivo: Node = load(IngressoNodo.SCENA_EVENTI).instantiate()
	add_child(arrivo)
	await get_tree().process_frame
	esigi("Dominatrice" in arrivo.sostituisci_nome(String(sequenza[9]["testo"])),
			"la Guida saluta una protagonista come «Dominatore»")
	arrivo.coda_messaggi.clear()
	arrivo.avanza_messaggio()
	esigi(Transizioni.prossima == GuidaSullaMappa.SCENA_MAPPA_ZONA,
			"finito «Dritti al punto eh? Subito!» non si apre la mappa (si va a '%s')" % Transizioni.prossima)
	esigi(String(GuidaSullaMappa.in_corso.get("ritorno", "")) == "inizio_guida" and GuidaSullaMappa.solo_chiudere(),
			"la mappa non sa che chiudendola si torna dalla Guida: %s" % str(GuidaSullaMappa.in_corso))
	arrivo.queue_free()
	await sulla_mappa_parla_la_guida()
	await chiusa_la_mappa_la_guida_protesta()
	Transizioni.in_corso = stato_prima
	Transizioni.prossima = ""
	IngressoNodo.ultimo_esito = {}
	GuidaSullaMappa.in_corso = {}
	GameState.nuova_partita()

func sulla_mappa_parla_la_guida() -> void:
	var mappa: Node = load(GuidaSullaMappa.SCENA_MAPPA_ZONA).instantiate()
	add_child(mappa)
	await get_tree().process_frame
	var guida := figlio_di_tipo(mappa, "GuidaSullaMappa") as GuidaSullaMappa
	esigi(guida != null, "la mappa si apre senza la Guida sopra")
	if guida == null:
		mappa.queue_free()
		return
	var detto := (guida.box.get("testo") as RichTextLabel).get_parsed_text()
	esigi("Pianure di Redenna" in detto and "vedi?" in detto, "sulla mappa la Guida non dice dove sei: «%s»" % detto)
	esigi(String(mappa.get("indicata")) == GameState.nodo_corrente,
			"su «vedi?» la mappa non cerchia il posto in cui sei")
	# le stanze sono spente finche' lei parla: andandosene si salterebbe la scena
	mappa.call("_su_stanza", "masso", true, true)
	esigi(Transizioni.prossima == GuidaSullaMappa.SCENA_MAPPA_ZONA,
			"mentre la Guida parla si puo' andare in un'altra stanza, e il resto dell'arrivo si perde")
	for i in 12:
		guida._su_clic()
	detto = (guida.box.get("testo") as RichTextLabel).get_parsed_text()
	esigi("trasportata" not in detto and "io e te? :3" in detto,
			"dopo tutte le battute la Guida non e' ferma sulla sua domanda: «%s»" % detto)
	esigi(String(mappa.get("indicata")) == "", "l'anello resta acceso dopo «vedi?»")
	var accordata := false
	for voce: Dictionary in GameState.storico:
		# la frase intera, non la parola: il segno grezzo {trasportato|trasportata}
		# la parola ce l'ha dentro, e con quella la prova passava ad accordo rotto
		accordata = accordata or "sempre trasportata vicino" in String(voce.get("testo", ""))
	esigi(accordata, "sulla mappa la Guida parla a una protagonista al maschile, o non finisce nello storico")
	var chiudi: Button = null
	for b: Button in mappa.find_children("*", "Button", true, false):
		if b.text == "Chiudi la mappa":
			chiudi = b
	esigi(chiudi != null, "con la Guida sopra non c'e' il tasto «Chiudi la mappa»")
	if chiudi != null:
		chiudi.pressed.emit()
	esigi(String(IngressoNodo.ultimo_esito.get("id", "")) == "inizio_guida",
			"chiusa la mappa non si torna dalla Guida, che deve protestare")
	esigi(not GuidaSullaMappa.sta_parlando(), "chiusa la mappa, la Guida resta «in corso»: la prossima mappa la ripeterebbe")
	mappa.queue_free()
	await get_tree().process_frame

func chiusa_la_mappa_la_guida_protesta() -> void:
	var dopo: Node = load(IngressoNodo.SCENA_EVENTI).instantiate()
	add_child(dopo)
	await get_tree().process_frame
	esigi(dopo.nodo_in_corso == GameState.eventi.get("inizio_guida", {}),
			"chiusa la mappa non arriva la protesta della Guida")
	var icona := figlio_di_tipo(dopo, "IconaGuida") as IconaGuida
	esigi(icona != null and not icona.visible, "l'icona della Guida c'e' gia' prima che lei la nomini")
	while not dopo.coda_messaggi.is_empty():
		dopo.avanza_messaggio()
	await get_tree().process_frame
	esigi(GameState.ha_flag("guida_conosciuta") and icona != null and icona.visible,
			"«Se hai bisogno puoi premere sulla mia icona» e l'icona non c'e'")
	dopo.queue_free()
	await get_tree().process_frame
	# e tornando al punto d'atterraggio la mappa non si riapre: lo ha gia' fatto
	Transizioni.prossima = ""
	IngressoNodo.vai_al_nodo("inizio")
	var ritorno: Node = load(IngressoNodo.SCENA_EVENTI).instantiate()
	add_child(ritorno)
	await get_tree().process_frame
	Transizioni.prossima = ""
	ritorno.coda_messaggi.clear()
	ritorno.avanza_messaggio()
	esigi(Transizioni.prossima == "", "tornando al punto d'atterraggio la Guida riapre la mappa ogni volta")
	ritorno.queue_free()
	# l'icona la riapre, senza spegnere le stanze, e chiudendo si resta dove sei
	GuidaSullaMappa.apri({})
	esigi(GuidaSullaMappa.sta_parlando() and not GuidaSullaMappa.solo_chiudere()
			and GuidaSullaMappa.dove_tornare() == GameState.nodo_corrente,
			"l'icona della Guida non riapre la mappa com'e' giusto")
	await get_tree().process_frame

func prova_nome_del_data_pad() -> void:
	# «(il diario diventa data pad)» (Bru). Una riga sola nel suo messaggio, e
	# cambia il nome di una schermata che il giocatore apre cento volte.
	titolo("il diario diventa data pad quando arrivano gli ordini")
	GameState.nuova_partita()
	esigi(GameState.nome_diario() == "Diario",
			"prima degli ordini si chiama gia' '%s'" % GameState.nome_diario())
	GameState.imposta_flag("ordini_ricevuti")
	esigi(GameState.nome_diario() == "Data pad",
			"dopo gli ordini si chiama ancora '%s'" % GameState.nome_diario())

func prova_ecg() -> void:
	# L'ECG DICE DUE COSE CON UNA RIGA SOLA, e qui si controllano tutte e due.
	#
	# Bru: «la linea è rossa quando ferito gravemente meno del 25% di hp, gialla
	# sopra il 25% ma meno del 75% verde sopra il 75%» e «se ha tanto stress ci
	# vuole che sia nervoso con ecg irregolare e movimentato».
	titolo("l'ecg: il colore dice la vita, il movimento dice lo stress")

	# IL COLORE, con gli estremi dove li ha messi lui. "meno del 25%" e' rossa,
	# quindi a un quarto esatto e' gia' gialla - e il quarto esatto capita di
	# continuo, e' la stessa soglia con cui il gioco dice "vita bassa".
	esigi(EcgCombattimento.colore_per(0.10) == "rosso", "a un decimo di vita la linea non e' rossa")
	esigi(EcgCombattimento.colore_per(0.2499) == "rosso", "appena sotto il quarto la linea non e' rossa")
	esigi(EcgCombattimento.colore_per(0.25) == "giallo",
			"al 25%% esatto la linea e' '%s': Bru ha scritto rossa SOTTO il 25%%"
			% EcgCombattimento.colore_per(0.25))
	esigi(EcgCombattimento.colore_per(0.50) == "giallo", "a meta' vita la linea non e' gialla")
	esigi(EcgCombattimento.colore_per(0.75) == "giallo",
			"al 75%% esatto la linea e' '%s': Bru ha scritto verde SOPRA il 75%%"
			% EcgCombattimento.colore_per(0.75))
	esigi(EcgCombattimento.colore_per(0.7501) == "verde", "appena sopra i tre quarti la linea non e' verde")
	esigi(EcgCombattimento.colore_per(1.0) == "verde", "a vita piena la linea non e' verde")

	var dado := RandomNumberGenerator.new()
	dado.seed = 20260915
	var durata := 6.0
	var campioni := 900

	# CHI E' A TERRA FA UNA RIGA DRITTA
	var morto := EcgCombattimento.traccia(durata, campioni, 0.0, 0, dado)
	esigi(EcgCombattimento.picchi(morto) == 0,
			"un combattente a terra ha ancora %d battiti" % EcgCombattimento.picchi(morto))

	# PIU' STRESS, PIU' BATTITI. Contati nel tracciato, non creduti sulla parola.
	#
	# LO STESSO DADO, RIAVVOLTO. Prima i due tracciati si tiravano di seguito
	# dallo stesso dado, quindi non avevano in comune solo lo stress: avevano
	# anche due sequenze di numeri casuali diverse. La prova restava verde anche
	# togliendo di mezzo l'accelerazione, perche' a fare la differenza bastava
	# il rumore. Riavvolgendolo, fra i due tracciati cambia una cosa sola.
	dado.seed = 20260915
	var calmo := EcgCombattimento.traccia(durata, campioni, 1.0, 0, dado)
	dado.seed = 20260915
	var teso := EcgCombattimento.traccia(durata, campioni, 1.0, 100, dado)
	var battiti_calmo := EcgCombattimento.picchi(calmo)
	var battiti_teso := EcgCombattimento.picchi(teso)
	esigi(battiti_calmo > 0, "un combattente sano e tranquillo non ha nessun battito")
	# NON "UNO IN PIU'": MOLTI IN PIU'. Da 62 a 150 al minuto il tracciato deve
	# raddoppiare abbondantemente, e chiedere solo "maggiore" non lo controlla:
	# fra i due tracciati ballava comunque un battito di scarto per come cade il
	# primo picco sul bordo, e la prova restava verde anche spegnendo del tutto
	# l'accelerazione. Con il doppio come soglia, quello scarto non basta piu'.
	esigi(battiti_teso >= battiti_calmo * 2,
			"a stress pieno i battiti sono %d contro i %d di uno tranquillo: "
			% [battiti_teso, battiti_calmo] + "il cuore non accelera abbastanza da vedersi")

	# E PIU' IRREGOLARI. E' la meta' che conta: un cuore che accelera e basta
	# sembra sforzo, uno che perde il tempo sembra paura
	var regolarita := func(stress: int) -> float:
		var quando := EcgCombattimento.istanti_dei_battiti(durata, stress, dado)
		if quando.size() < 3:
			return 0.0
		var scarti: Array[float] = []
		for i in range(1, quando.size()):
			scarti.append(quando[i] - quando[i - 1])
		var media := 0.0
		for s in scarti:
			media += s
		media /= float(scarti.size())
		var varianza := 0.0
		for s in scarti:
			varianza += (s - media) * (s - media)
		return sqrt(varianza / float(scarti.size())) / maxf(media, 0.001)
	var sbando_calmo: float = regolarita.call(0)
	var sbando_teso: float = regolarita.call(100)
	esigi(sbando_calmo < 0.02,
			"da tranquillo il cuore sbanda gia' del %.0f%%: doveva essere un metronomo" % (sbando_calmo * 100.0))
	esigi(sbando_teso > 0.10,
			"a stress pieno il cuore sbanda solo del %.0f%%: e' piu' veloce ma non e' irregolare"
			% (sbando_teso * 100.0))

	# E LA LINEA DI BASE TREMA, che e' il "movimentato" di Bru.
	#
	# Si contano i campioni che valgono ESATTAMENTE zero. Fra un battito e
	# l'altro l'onda ha dei tratti piatti, e senza tremore quei tratti sono
	# zeri precisi: tanti. Col tremore addosso non ne resta praticamente
	# nessuno, perche' ogni campione viene spostato di un pelo.
	#
	# Il primo tentativo cercava il valore piu' alto fra quelli piccoli, e
	# restava verde anche azzerando il tremore: quei valori li faceva l'onda,
	# non il rumore, e bastava che i battiti cadessero in punti diversi.
	var zeri := func(punti: PackedFloat32Array) -> int:
		var quanti := 0
		for valore in punti:
			if valore == 0.0:
				quanti += 1
		return quanti
	var zeri_calmo: int = zeri.call(calmo)
	var zeri_teso: int = zeri.call(teso)
	esigi(zeri_calmo > int(campioni / 4.0),
			"da tranquillo il tracciato ha solo %d campioni piatti su %d: non e' una linea che riposa"
			% [zeri_calmo, campioni])
	esigi(zeri_teso < int(zeri_calmo / 10.0),
			"a stress pieno il tracciato ha ancora %d campioni perfettamente piatti (calmo: %d): "
			% [zeri_teso, zeri_calmo] + "la linea di base non trema, e' solo piu' fitta")


func prova_velo_di_pericolo() -> void:
	# IL VELO ROSSO SI DEVE POTER SPEGNERE.
	#
	# I bordi dello schermo si arrossano quando la squadra sta messa male. Se
	# quando la squadra guarisce nessuno lo ridisegna, il rosso resta li' per
	# sempre - e il giocatore vede il segnale di "stai per morire" addosso a una
	# squadra a vita piena. Si e' visto fotografando la schermata nuova: tutto
	# nero come nel disegno di Bru, e i quattro bordi accesi.
	titolo("il velo del pericolo si spegne quando il pericolo passa")
	var arena := ArenaCombattimento.new(false)
	var sfondo := ColorRect.new()
	var sopra := Control.new()
	sopra.size = Vector2(320, 180)
	add_child(sopra)
	sopra.add_child(sfondo)
	arena.collega(sfondo, sopra)
	esigi(arena.velo != null, "l'arena non ha creato il velo")
	# SI ASPETTA IL FOTOGRAMMA, non si chiama il disegno a mano: in Godot si puo'
	# disegnare solo dentro un passaggio di disegno, e chiamarlo da fuori non
	# fallisce - stampa un errore e non disegna niente. Una prova che lo facesse
	# misurerebbe una cosa che a schermo non e' mai successa.
	arena.imposta_pericolo(0.9)
	await get_tree().process_frame
	await get_tree().process_frame
	esigi(is_equal_approx(arena.pericolo_disegnato, 0.9),
			"a schermo c'e' un pericolo di %.2f invece di 0.90" % arena.pericolo_disegnato)
	# e adesso la squadra guarisce
	arena.imposta_pericolo(0.0)
	await get_tree().process_frame
	await get_tree().process_frame
	esigi(is_zero_approx(arena.pericolo_disegnato),
			"la squadra e' guarita ma a schermo resta un pericolo di %.2f: i bordi restano rossi"
			% arena.pericolo_disegnato)
	sopra.free()

func prova_ritratti_di_condizione() -> void:
	# LA FACCIA CAMBIA CON LA CONDIZIONE.
	#
	# Bru: «quando subisci danno il portrait cambia con uno per low damage, mid
	# damage heavy damage e ko, a seconda degli status disegnerò portrait per
	# ogni personaggio [...] disegnerò anche un portrait generico per un
	# personaggio ko».
	titolo("il ritratto segue le ferite, gli status e il KO")

	# LE SOGLIE SONO QUELLE DELL'ECG, e devono restarlo: se un giorno si
	# separano, la faccia e la linea del cuore dicono due cose diverse nello
	# stesso istante, e il giocatore non sa piu' a quale credere
	esigi(RitrattiCombattimento.banda_nuda(1.0) == "sano",
			"a vita piena la faccia non e' quella sana")
	esigi(RitrattiCombattimento.banda_nuda(0.9) == "ferito_lieve",
			"al 90%% la faccia e' '%s'" % RitrattiCombattimento.banda_nuda(0.9))
	esigi(RitrattiCombattimento.banda_nuda(0.5) == "ferito_medio",
			"a meta' vita la faccia e' '%s'" % RitrattiCombattimento.banda_nuda(0.5))
	esigi(RitrattiCombattimento.banda_nuda(0.1) == "ferito_grave",
			"a un decimo di vita la faccia e' '%s'" % RitrattiCombattimento.banda_nuda(0.1))
	esigi(RitrattiCombattimento.banda_nuda(0.0) == "ko",
			"a terra la faccia non e' quella del KO")
	# gli estremi cadono dove cadono per l'ECG: al 25% esatto si e' gia' medio
	esigi(RitrattiCombattimento.banda_nuda(EcgCombattimento.QUOTA_ROSSA) == "ferito_medio",
			"al 25%% esatto la faccia e' '%s': la soglia non e' quella dell'ECG"
			% RitrattiCombattimento.banda_nuda(EcgCombattimento.QUOTA_ROSSA))
	esigi(RitrattiCombattimento.banda_nuda(EcgCombattimento.QUOTA_VERDE) == "ferito_medio",
			"al 75%% esatto la faccia e' '%s': la soglia non e' quella dell'ECG"
			% RitrattiCombattimento.banda_nuda(EcgCombattimento.QUOTA_VERDE))

	# NON SFARFALLA. In tempo reale la vita passa e ripassa sopra una soglia di
	# continuo: peggiorare e' immediato, migliorare chiede di risalire davvero
	var appena_sotto := EcgCombattimento.QUOTA_ROSSA - 0.001
	esigi(RitrattiCombattimento.banda(appena_sotto, "ferito_medio") == "ferito_grave",
			"scendere sotto il quarto non peggiora subito la faccia")
	var appena_sopra := EcgCombattimento.QUOTA_ROSSA + 0.001
	esigi(RitrattiCombattimento.banda(appena_sopra, "ferito_grave") == "ferito_grave",
			"basta risalire di un millesimo per cambiare faccia: sfarfalla a ogni colpo")
	var ben_sopra := EcgCombattimento.QUOTA_ROSSA + RitrattiCombattimento.MARGINE + 0.01
	esigi(RitrattiCombattimento.banda(ben_sopra, "ferito_grave") == "ferito_medio",
			"una cura vera non rimette mai la faccia a posto")

	# LA CATENA DI RIPIEGO. Bru i ritratti li sta disegnando adesso: ogni pezzo
	# che manca deve scivolare su quello dopo, e in fondo ci deve essere sempre
	# qualcosa. Qui si guarda l'ORDINE, che e' la cosa che si puo' sbagliare.
	var a_terra := RitrattiCombattimento.candidati("veronica", 0.0, [])
	esigi(a_terra[0].ends_with("veronica/ko.png"),
			"a terra si cerca prima %s" % a_terra[0])
	esigi(a_terra[1] == RitrattiCombattimento.CARTELLA + "ko.png",
			"manca il KO generico subito dopo quello suo: %s" % a_terra[1])
	var in_fiamme := RitrattiCombattimento.candidati("veronica", 0.5, ["fiamme"])
	esigi(in_fiamme[0].ends_with("veronica/fiamme.png"),
			"con uno status addosso si cerca prima %s" % in_fiamme[0])
	esigi(in_fiamme[1].ends_with("veronica/ferito_medio.png"),
			"se il ritratto dello status non c'e' non si ripiega sulla ferita: %s" % in_fiamme[1])
	for elenco in [a_terra, in_fiamme]:
		esigi(elenco[elenco.size() - 1].ends_with("neutra.png"),
				"in fondo alla catena non c'e' la posa dei dialoghi: %s" % elenco[elenco.size() - 1])
	# e un personaggio a terra non mostra mai la faccia di uno che sta bene
	for percorso in a_terra.slice(0, 2):
		esigi(not percorso.ends_with("sano.png"),
				"a terra si puo' finire a mostrare la faccia sana")

func prova_menu_da_tastiera() -> void:
	# IL COMBATTIMENTO SI DEVE POTER GIOCARE SENZA MOUSE.
	#
	# Il menu aveva il fuoco spento su ogni voce: cercava di darlo alla prima
	# utile - il codice c'era - ma un bottone con focus_mode = NONE il fuoco non
	# lo puo' prendere, quindi le frecce non facevano niente e da fuori sembrava
	# che la tastiera non fosse mai stata prevista. In uno scontro in tempo reale
	# spostare la mano sul mouse a ogni battuta e' una tassa, e per chi il mouse
	# non lo usa bene e' un muro.
	titolo("il menu di combattimento si usa anche da tastiera")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.limite_giri = 1
	add_child(scontro)
	# GLI SI DA' UN TURNO. Fuori dal tuo turno il menu e' scolorito, e per
	# guardare se la tastiera funziona serve il momento in cui si puo' davvero
	# scegliere qualcosa.
	for combattente in scontro.combattenti:
		if combattente.giocatore:
			combattente.hp = combattente.hp_max
			dai_il_turno(scontro, combattente)
	scontro.in_corso = true
	scontro.menu.principale()
	var voci: Array[Button] = []
	for figlio in scontro.plancia.comandi.get_children():
		if figlio is Button:
			voci.append(figlio)
	esigi(voci.size() >= 5, "il menu ha solo %d voci" % voci.size())
	var raggiungibili := 0
	for voce in voci:
		if voce.focus_mode != Control.FOCUS_NONE:
			raggiungibili += 1
	esigi(raggiungibili == voci.size(),
			"solo %d voci su %d possono prendere il fuoco: le altre da tastiera non esistono"
			% [raggiungibili, voci.size()])
	# LA FACCIA DEI COMANDI DEVE ESSERE APERTA. Il quadrante fa tre mestieri, e
	# se il menu si riempie mentre e' in mostra il parlato non si vede niente -
	# e nessuna voce puo' prendere il fuoco, perche' un nodo nascosto il fuoco
	# non lo prende. Era esattamente cosi': la plancia nasceva sul parlato e non
	# la cambiava mai nessuno.
	esigi(scontro.plancia.faccia_comandi.is_visible_in_tree(),
			"il menu si e' acceso ma il quadrante mostra un'altra faccia: le voci non si vedono")

	# e il fuoco deve finire su una voce utile, se no la prima freccia premuta
	# non fa niente e sembra che la tastiera sia rotta
	var utili := 0
	for voce in voci:
		if not voce.disabled:
			utili += 1
	esigi(utili > 0, "tutte le voci del menu sono spente: non si puo' fare niente")
	scontro.plancia.dai_il_fuoco()
	var chi_ha_il_fuoco: Control = scontro.plancia.comandi.get_viewport().gui_get_focus_owner()
	esigi(chi_ha_il_fuoco != null and chi_ha_il_fuoco in voci,
			"il fuoco non finisce su nessuna voce: da tastiera il menu non si comanda")
	# IL FUOCO SI DEVE VEDERE, e non con un colore soltanto: chi non distingue
	# i colori deve poter dire su quale voce sta
	# LA VOCE COL FUOCO DEVE RESTARE LEGGIBILE. Godot per un bottone col fuoco
	# usa un colore suo - font_focus_color - che viene dal tema generale, fatto
	# per il fondo scuro del resto del gioco. Sul bianco del quadrante la parola
	# spariva del tutto: restava la barretta rossa e nient'altro.
	for voce in voci:
		var tinta: Color = voce.get_theme_color("font_focus_color")
		esigi(tinta.a > 0.5 and tinta.v < 0.6,
				"la voce col fuoco si scrive in %s sul bianco: non si legge piu'" % tinta)
	var segno: StyleBox = voci[0].get_theme_stylebox("focus")
	esigi(segno is StyleBoxFlat and (segno as StyleBoxFlat).border_width_left > 0,
			"la voce col fuoco non ha nessun segno di forma: si distingue solo dal colore")
	scontro.free()

func prova_ecg_non_accumula() -> void:
	# UNO SCONTRO LUNGO NON DEVE RALLENTARE.
	#
	# Il tracciato teneva in memoria ogni battito da quando lo scontro era
	# cominciato, e li rileggeva tutti PER OGNI CAMPIONE - sessanta volte al
	# secondo. Un battito piu' vecchio di un intervallo non contribuisce piu'
	# niente, quindi erano riletture di roba morta: dopo cinque minuti sono
	# settecento battiti riletti quarantamila volte al secondo, e il conto
	# peggiora da solo piu' lo scontro dura.
	titolo("l'ecg non accumula battiti per tutto lo scontro")
	var riga := TracciatoEcg.new()
	riga.size = Vector2(400, 110)
	riga.imposta(0.6, 40)
	var dopo_poco := 0
	var dopo_molto := 0
	# si chiama valore_a() direttamente: e' la funzione che accumula, e cosi' la
	# prova non ha bisogno ne' di una finestra ne' di aspettare mezzo minuto
	for i in 120:
		riga.valore_a(float(i) * 0.05)
	dopo_poco = riga.battiti.size()
	for i in range(120, 2400):
		riga.valore_a(float(i) * 0.05)
	dopo_molto = riga.battiti.size()
	esigi(dopo_poco > 0, "il tracciato non ha generato nessun battito")
	esigi(dopo_molto <= dopo_poco + 2,
			("dopo due minuti l'elenco dei battiti e' passato da %d a %d: "
			+ "cresce senza fine, e ogni campione li rilegge tutti")
			% [dopo_poco, dopo_molto])
	riga.free()

func prova_niente_disco_a_ogni_colpo() -> void:
	# IL DISCO NON SI INTERROGA A OGNI COLPO.
	#
	# Misurato: cercare un ritratto lungo tutta la catena di ripiego costa 0.10
	# ms, e un controllo d'esistenza 0.024 ms. Sembra niente finche' non si
	# guarda QUANTE volte succedeva: la faccia si ricercava a ogni aggiornamento
	# di scheda - uno per colpo, per stato, per battuta, per tre compagni - e le
	# icone di stato addirittura dentro il disegno, cioe' potenzialmente a ogni
	# fotogramma.
	#
	# Il punto non e' il millisecondo: e' che quelle chiamate toccano il disco, e
	# un disco che si sveglia in mezzo a uno scontro in tempo reale si sente.
	titolo("il disco non si interroga a ogni colpo")
	var posto := SlotCompagno.new()
	add_child(posto)
	posto.size = Vector2(200, 320)
	posto.abita("veronica")
	# il PRIMO aggiornamento a 0.9 deve cercare davvero: abita() l'aveva messa a
	# vita piena, e passare a "ferito_lieve" e' un cambio di faccia vero. Il
	# conto di partenza si prende dopo, se no si misura anche quello
	posto.aggiorna_faccia(0.9, [])
	var dopo_il_primo := posto.ricerche
	for _volta in 40:
		posto.aggiorna_faccia(0.9, [])
	esigi(posto.ricerche == dopo_il_primo,
			"quaranta aggiornamenti con la stessa condizione hanno cercato %d volte un disegno"
			% (posto.ricerche - dopo_il_primo))
	# ma quando la condizione cambia davvero, la faccia deve cambiare
	posto.aggiorna_faccia(0.1, [])
	esigi(posto.ricerche > dopo_il_primo,
			"il personaggio e' passato a un decimo di vita e la faccia non e' stata ricercata")
	var dopo_la_ferita := posto.ricerche
	posto.aggiorna_faccia(0.1, ["fiamme"])
	esigi(posto.ricerche > dopo_la_ferita,
			"gli e' andato addosso il fuoco e la faccia non e' stata ricercata")
	posto.free()

	# e le icone di stato chiedono al disco una volta per simbolo, non a ogni
	# ridisegno
	IconeStato.svuota_cache()
	esigi(IconeStato.disegni_trovati.is_empty(), "la cache delle icone non si svuota")
	IconeStato.percorso_di("fiamme")
	IconeStato.percorso_di("fiamme")
	IconeStato.percorso_di("maledizione")
	esigi(IconeStato.disegni_trovati.size() == 2,
			"due simboli chiesti tre volte hanno lasciato %d voci in cache"
			% IconeStato.disegni_trovati.size())

func prova_riduci_il_movimento() -> void:
	# CHI NON PUO' REGGERE IL MOVIMENTO DEVE POTER GIOCARE LO STESSO.
	#
	# [Le linee guida sull'accessibilita' dei giochi] mettono "disattiva la
	# scossa dello schermo" fra le opzioni da offrire, non fra quelle carine da
	# avere: la scossa dell'inquadratura e i lampi sono fra i motivi per cui una
	# persona che soffre di mal di movimento, di emicrania o di epilessia
	# fotosensibile smette di giocare. Il gioco aveva gia' testo grande, alto
	# contrasto e velocita' del testo; questa mancava, e il combattimento trema a
	# ogni colpo.
	#
	# NON TOGLIE INFORMAZIONE. Il numero del danno, il colore dell'elemento e il
	# suono restano: sparisce solo il movimento.
	titolo("l'opzione che toglie scossa e lampi")
	var prima := Impostazioni.movimento_ridotto
	var corpo := Control.new()
	add_child(corpo)
	corpo.position = Vector2(10, 10)
	var impatto := ImpattoCombattimento.new(get_tree(), false)
	impatto.collega(corpo)

	Impostazioni.movimento_ridotto = false
	impatto.scossa(24.0)
	esigi(impatto.tween_scossa != null and impatto.tween_scossa.is_valid(),
			"senza l'opzione la scossa non parte nemmeno: e' rotta di suo")
	impatto.tween_scossa.kill()
	impatto.tween_scossa = null

	Impostazioni.movimento_ridotto = true
	impatto.scossa(24.0)
	esigi(impatto.tween_scossa == null or not impatto.tween_scossa.is_valid(),
			"con il movimento ridotto la schermata sbanda lo stesso")

	# e l'opzione si ricorda fra una partita e l'altra
	Impostazioni.salva()
	Impostazioni.movimento_ridotto = false
	Impostazioni.carica()
	esigi(Impostazioni.movimento_ridotto,
			"l'opzione non si salva: va rimessa a ogni avvio")
	Impostazioni.movimento_ridotto = prima
	Impostazioni.salva()
	corpo.free()

func prova_lampo_solo_sulla_faccia() -> void:
	# IL LAMPO DI UN COLPO NON DEVE COPRIRE LE BARRE.
	#
	# Uno slot contiene il ritratto, le tre barre e i riquadri di stato. Tingendo
	# tutto lo slot, nell'istante in cui prendi un colpo - che e' esattamente
	# l'istante in cui guardi quanta vita ti resta - le barre diventano del
	# colore dell'elemento e non si leggono piu'. Si e' visto fotografando un
	# colpo a meta' volo: HP, AURA e dominio tutti viola.
	titolo("il lampo di un colpo tinge la faccia, non le barre")
	var posto := SlotCompagno.new()
	add_child(posto)
	posto.size = Vector2(200, 320)
	posto.abita("veronica")
	var voce := VoceCombattimento.new(get_tree(), false)
	voce.lampeggia(posto, Color(0.6, 0.2, 0.9))
	# SI ASPETTA CHE IL LAMPO SIA PARTITO. E' un'animazione: misurata nello
	# stesso istante in cui la si accende, la tinta non si e' ancora mossa e
	# tutto sembra a posto. La prima versione di questa prova restava verde
	# anche rimettendo il lampo su tutto lo slot, perche' guardava troppo presto.
	for _f in 8:
		await get_tree().process_frame
	# il ritratto reagisce...
	esigi(not posto.ritratto.modulate.is_equal_approx(Color.WHITE),
			"il ritratto non reagisce affatto al colpo: la tinta e' rimasta %s"
			% posto.ritratto.modulate)
	# ...e le barre restano del loro colore
	esigi(posto.modulate.is_equal_approx(Color.WHITE),
			"il colpo ha tinto tutto lo slot di %s: le barre non si leggono piu'" % posto.modulate)
	for chiave in ["hp", "aura", "dominio"]:
		var barra: Control = posto.barre[chiave]
		esigi(barra.modulate.is_equal_approx(Color.WHITE),
				"la barra %s si e' tinta col colpo" % chiave)
	posto.free()

func prova_condizione_di_chi_ha_il_turno() -> void:
	# L'ECG, IL MORALE E LO STRESS SONO DI CHI HA IL TURNO - e non li aggiornava
	# nessuno.
	#
	# Il tracciato era costruito, misurato, provato... e in partita raccontava la
	# condizione di un personaggio immaginario, sempre la stessa, perche' la
	# funzione che gli passa i dati veri non veniva chiamata da nessuna parte
	# tranne che dal fotografo. I due numeri restavano vuoti.
	titolo("l'ecg racconta la condizione di chi ha il turno, davvero")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.limite_giri = 1
	add_child(scontro)
	var eroe: Dictionary = {}
	for combattente in scontro.combattenti:
		if combattente.giocatore and eroe.is_empty():
			eroe = combattente
	esigi(not eroe.is_empty(), "nessun protagonista")
	eroe.hp = int(eroe.hp_max / 4.0)      # un quarto di vita: la linea deve diventare rossa
	GameState.stress[String(eroe.id)] = 80
	eroe.stress = 80
	scontro.aggiorna_pronto_giocatore()
	esigi(is_equal_approx(scontro.plancia.ecg.quota_hp, 0.25),
			"l'ecg segna una vita di %.2f invece di 0.25: non gli arriva quella vera"
			% scontro.plancia.ecg.quota_hp)
	esigi(scontro.plancia.ecg.stress == 80,
			"l'ecg segna uno stress di %d invece di 80" % scontro.plancia.ecg.stress)
	esigi(scontro.plancia.etichetta_stress.text.contains("80"),
			"la riga dello stress dice '%s'" % scontro.plancia.etichetta_stress.text)
	esigi(scontro.plancia.etichetta_morale.text != "",
			"la riga del morale e' vuota")
	scontro.free()

func prova_chi_tocca_si_accende() -> void:
	# DI CHI E' IL TURNO SI VEDE ACCENDENDO LUI, NON SPEGNENDO GLI ALTRI.
	#
	# Prima gli slot di chi non toccava si sbiadivano. Sul fondo nero della
	# vecchia schermata voleva dire "piu' scuro"; sul bianco di questa vuol dire
	# "piu' pallido", e pallido si legge DISATTIVATO - come se quel compagno
	# fosse fuori combattimento invece che in attesa.
	titolo("chi ha il turno si accende, gli altri non si spengono")
	var posto := SlotCompagno.new()
	add_child(posto)
	posto.size = Vector2(200, 320)
	posto.abita("veronica")
	var spento: Color = posto.cornice.color
	posto.imposta_turno(true)
	esigi(posto.cornice.color != spento,
			"la cornice non cambia quando tocca a lui: non si vede di chi e' il turno")
	esigi(posto.modulate.is_equal_approx(Color.WHITE),
			"lo slot di chi tocca e' stato sbiadito invece che acceso")
	# e il numero dell'aura compare solo su di lui
	esigi(posto.numero_aura != null, "non c'e' nessun numero dell'aura")
	esigi(posto.numero_aura.visible, "a chi ha il turno non si vede quanta aura ha")
	posto.mostra_aura(7, 12)
	esigi(posto.numero_aura.text.contains("7"),
			"il numero dell'aura dice '%s'" % posto.numero_aura.text)
	# E L'ORDINE NON DEVE CONTARE. Se il valore arriva prima che il turno si
	# accenda - e succede, perche' chi aggiorna le schede e chi marca il turno
	# sono due strade diverse - il numero deve esserci lo stesso quando la
	# cornice si accende. Prima restava vuoto.
	posto.imposta_turno(false)
	posto.mostra_aura(3, 12)
	posto.imposta_turno(true)
	esigi(posto.numero_aura.text.contains("3"),
			"il valore arrivato prima del turno si e' perso: il numero dice '%s'"
			% posto.numero_aura.text)
	posto.imposta_turno(false)
	esigi(not posto.numero_aura.visible,
			"il numero dell'aura resta acceso anche su chi non tocca: tre numeri da leggere")
	esigi(posto.modulate.is_equal_approx(Color.WHITE),
			"chi non tocca viene sbiadito: su fondo bianco si legge 'fuori combattimento'")
	posto.free()

func prova_mattanza_e_bond_non_spariscono() -> void:
	# I DUE TASSELLI SONO L'UNICO AVVISO CHE ARRIVA.
	#
	# Se vivono dentro la faccia dei comandi, spariscono proprio mentre scegli un
	# attacco da una lista - cioe' nei secondi in cui stai guardando altrove e il
	# segnale arriva. Li nasconde solo il parlato: mentre il box racconta non
	# stai scegliendo niente, e sotto ci passa il testo.
	titolo("MATTANZA e BOND non spariscono mentre scegli da una lista")
	var radice := Control.new()
	radice.size = Vector2(1280, 720)
	add_child(radice)
	var plancia := PlanciaCombattimento.new()
	plancia.costruisci(radice)
	for faccia in ["comandi", "lista"]:
		plancia.mostra_faccia(faccia)
		esigi(plancia.tasto_mattanza.visible and plancia.tasto_bond.visible,
				"con la faccia '%s' i due tasselli sono spariti" % faccia)
	plancia.mostra_faccia("parlato")
	esigi(not plancia.tasto_mattanza.visible and not plancia.tasto_bond.visible,
			"mentre il box parla i due tasselli gli stanno sopra")
	radice.free()

func prova_ritorno_dalla_missione() -> void:
	# «dopo finita la missione, va spiegato come si torna indietro [...] appare
	# una scelta a fine dialogo, vuoi tornare indietro? si no, a ogni fine
	# missione avrai l'opzione di tornare alla base nell'ultima zona della mappa
	# altrimenti potrai ancora rivisitare la mappa se pensi di aver dimenticato
	# qualcosa» (Bru).
	titolo("finita la missione si impara a tornare, e la scelta resta li\'")
	var dati := carica_eventi("res://data/events_tutorial.json")
	var nodi: Dictionary = dati.get("nodi", {})
	for id_nodo in ["ritorno_istruzioni", "ritorno_rimandato", "ritorno_disponibile",
			"ritorno_alla_base"]:
		esigi(nodi.has(id_nodo), "manca il nodo '%s' del ritorno" % id_nodo)

	# la vittoria non manda piu' dritti al quartier generale: prima si impara
	esigi("ritorno_istruzioni" in destinazioni_di(nodi.get("vittoria", {})),
			"vinto il boss si torna alla base senza che nessuno abbia spiegato come: %s"
			% [destinazioni_di(nodi.get("vittoria", {}))])

	# LE BATTUTE CI SONO TUTTE, E IN ORDINE
	var battute: Array[String] = []
	for voce in nodi["ritorno_istruzioni"].get("sequenza", []):
		battute.append(String((voce as Dictionary).get("testo", "")))
	var attese := [
		"Beh, sicuramente ho capito come si parte... ma come ritorno?",
		"Quella maledetta ha saltato tutto e io non ci ho capito niente!",
		"Bzzzz... boop. h-heeey zzz",
		"Veronica... Come torno alla base...",
		"Devi sapere che ci sono 3 modi per entrare in quelle che chiamiamo fratture...",
		"e il terzo?",
		"Capito, proverò... Adesso, come faccio a tornare?",
	]
	var ultimo := -1
	for frase in attese:
		var dove := battute.find(String(frase))
		esigi(dove >= 0, "la battuta «%s» non c\'e\' piu\'" % frase)
		esigi(dove > ultimo, "la battuta «%s» e\' finita fuori ordine" % frase)
		ultimo = maxi(dove, ultimo)

	# I TRE MODI SONO TRE, e il terzo Veronica non lo sa: e' il filo che porta
	# al settore ricerca, non una dimenticanza
	var parlato := "\n".join(battute)
	for pezzo in ["la prima:", "la seconda:", "Non lo so!", "settore ricerca"]:
		esigi(pezzo in parlato, "dalla spiegazione delle fratture e\' sparito «%s»" % pezzo)

	# IL SUONO DEL DATA PAD. Bru: «qui metteremo un suono che creo io tipo
	# allert». Se la battuta non lo chiede, il giorno che il file arriva non
	# suonera\' da nessuna parte.
	var suona := ""
	for voce in nodi["ritorno_istruzioni"].get("sequenza", []):
		if (voce as Dictionary).has("suono"):
			suona = String((voce as Dictionary).get("chi", ""))
	esigi(suona == "data_pad",
			"l\'avviso del data pad non fa suonare niente (suono su '%s')" % suona)

	# LA SCELTA: SI\' TORNA, NO RESTA. E il no non e\' un muro: la mappa resta
	# aperta, «potrai ancora rivisitare la mappa se pensi di aver dimenticato
	# qualcosa».
	for id_nodo in ["ritorno_istruzioni", "ritorno_disponibile"]:
		var uscite := destinazioni_di(nodi[id_nodo])
		esigi("ritorno_alla_base" in uscite and "ritorno_rimandato" in uscite,
				"'%s' non offre tutte e due le strade: %s" % [id_nodo, uscite])
		var testo_scelte: Array[String] = []
		for scelta in nodi[id_nodo].get("scelte", []):
			testo_scelte.append(String((scelta as Dictionary).get("testo", "")))
		esigi(testo_scelte.size() == 2, "'%s' ha %d scelte invece di due" % [id_nodo, testo_scelte.size()])
	esigi(bool(nodi["ritorno_rimandato"].get("torna_a_mappa", false)),
			"dicendo di no si resta piantati: la mappa non si riapre")
	var nudge: Array[String] = []
	for voce in nodi["ritorno_rimandato"].get("sequenza", []):
		nudge.append(String((voce as Dictionary).get("testo", "")))
	esigi("Dai non perdere tempo, torna indietro, è quasi ora di cena..." in nudge,
			"manca la battuta di Veronica quando rimandi: %s" % [nudge])

	# LA SCELTA RESTA NELL\'ULTIMA ZONA, non solo subito dopo il boss
	var regole: Array = nodi.get("convergenza", {}).get("vai_se_flag", [])
	var prima: Dictionary = regole[0] if not regole.is_empty() else {}
	esigi(String(prima.get("flag", "")) == "pianure_compiute"
			and String(prima.get("vai", "")) == "ritorno_disponibile",
			"tornando nell\'ultima zona non si ritrova l\'opzione di rientrare: %s" % [prima])
	esigi(String(nodi.get("vittoria", {}).get("flag", "")) == "pianure_compiute",
			"la vittoria non segna la missione come compiuta: l\'opzione non comparirebbe mai")

	# e il ritorno finisce da Veronica, non da nessuna parte
	esigi("hq_veronica_saluto" in destinazioni_di(nodi["ritorno_alla_base"]),
			"tornando alla base non si arriva da Veronica")

func prova_data_pad_e_proiezione() -> void:
	# «dopo che si spiega come usare il data pad in tutte le sue parti, c'e'
	# anche una sezione messaggi dove l'organizzazione ti ha versato 3000 tazo
	# come quota di benvenuto, ci sara' la missione che ti porta nella sala
	# proiezione» (Bru).
	titolo("il data pad, i 3000 tazo, e la procedura di proiezione")
	var dati := carica_eventi("res://data/events_intro.json")
	var nodi: Dictionary = dati.get("nodi", {})

	# LA CATENA. Gli ordini aprono il data pad, il data pad rimanda alla mappa,
	# e la sala di proiezione - solo da li' in poi - e' la scena con Veronica.
	esigi(nodi.has("data_pad_istruzioni"), "manca il nodo che spiega il data pad")
	esigi(nodi.has("proiezione_veronica"), "manca la scena della proiezione")
	esigi(not nodi.has("monologo"),
			"il vecchio lancio in solitaria e' ancora attaccato: adesso la procedura la insegna Veronica")
	var uscite_ordini := destinazioni_di(nodi.get("comunicazioni_ordini", {}))
	esigi("data_pad_istruzioni" in uscite_ordini,
			"dopo gli ordini non si apre il data pad: si va in %s" % [uscite_ordini])
	var regole_proiezione: Array = nodi.get("sala_proiezione", {}).get("vai_se_flag", [])
	var prima_regola: Dictionary = regole_proiezione[0] if not regole_proiezione.is_empty() else {}
	esigi(String(prima_regola.get("flag", "")) == "data_pad_spiegato"
			and String(prima_regola.get("vai", "")) == "proiezione_veronica",
			"la sala di proiezione non si apre col data pad spiegato: la prima regola e' %s"
			% [prima_regola])
	var scena: Dictionary = nodi.get("proiezione_veronica", {})
	# IN MEZZO ALLA SCENA SI SCEGLIE LA META. Bru: «nella mappa dovrebbe essere
	# presente solo quella frattura, ti manderà in missione Veronica». La scena
	# apre la mappa stellare, e scelta la meta riprende da proiezione_partenza
	var ripresa := String(scena.get("apri_mappa_stellare", ""))
	esigi(ripresa != "" and nodi.has(ripresa),
			"Veronica dice «vedi questa mappa?» e nessuna mappa si apre: 'apri_mappa_stellare' e' '%s'" % ripresa)
	var partenza: Dictionary = nodi.get(ripresa, {})
	esigi(String(partenza.get("avvio_automatico", {}).get("file_eventi", "")).ends_with("events_tutorial.json"),
			"scelta la meta non parte la prima missione")
	var prime: Array = []
	for punto in GameState.carica_mappa().get("punti", []):
		if bool((punto as Dictionary).get("prima_missione", false)):
			prime.append(punto)
	esigi(prime.size() == 1,
			"sulla mappa della prima missione ci sono %d fratture: Bru ne vuole una sola" % prime.size())
	for didascalia in scena.get("sequenza", []):
		esigi(String((didascalia as Dictionary).get("testo", "")).find("visuale di mappa") == -1,
				"la didascalia «si esce dalla visuale di mappa» e' rimasta: adesso la mappa si apre davvero")

	# LE BATTUTE DI BRU CI SONO TUTTE, e nell'ordine - sui due pezzi della
	# scena. Una scena lunga si accorcia per sbaglio piu' facilmente di quanto
	# sembri.
	var battute: Array[String] = []
	for voce in scena.get("sequenza", []) + partenza.get("sequenza", []):
		battute.append(String((voce as Dictionary).get("testo", "")))
	var attese := [
		"!!!",
		"loquace come sempre, così mi piaci,",
		"Buongiorno!",
		"Skip... skip...",
		"acquistato!?",
		"Lo stile si paga!",
		"IL MIO CONTO È A ZERO...",
		"Ma il tuo stile è a mille!",
		"rivoglio i miei soldi...",
		"Se la caverà benissimo, sono sicura!",
	]
	var ultimo := -1
	for frase in attese:
		var dove := battute.find(String(frase))
		esigi(dove >= 0, "la battuta «%s» non c'e' piu'" % frase)
		esigi(dove > ultimo, "la battuta «%s» e' finita fuori ordine" % frase)
		ultimo = maxi(dove, ultimo)
	esigi(battute.find("Se la caverà benissimo, sono sicura!") == battute.size() - 1,
			"l'ultima battuta non e' quella di Veronica rimasta sola")

	# IL FLAG STA SULLA BATTUTA GIUSTA. La ricevuta deve arrivare quando il
	# protagonista scopre di aver pagato, non venti righe prima.
	var flag_su := ""
	for voce in scena.get("sequenza", []):
		if (voce as Dictionary).has("flag"):
			flag_su = String((voce as Dictionary).get("testo", ""))
	esigi(flag_su == "acquistato!?",
			"il flag della skin sta sulla battuta «%s» invece che su «acquistato!?»" % flag_su)

	# --- i messaggi -------------------------------------------------------
	GameState.nuova_partita()
	esigi(not GameState.messaggi_catalogo.is_empty(), "messaggi.json non caricato")
	esigi(GameState.messaggi_ricevuti.is_empty(),
			"a partita nuova ci sono gia' %d messaggi" % GameState.messaggi_ricevuti.size())
	var prima_tazo := GameState.tazo
	GameState.imposta_flag("ordini_ricevuti")
	esigi("benvenuto_quota" in GameState.messaggi_ricevuti,
			"ricevuti gli ordini, la quota di benvenuto non arriva")
	esigi(GameState.tazo == prima_tazo + 3000,
			"la quota di benvenuto ha portato %d tazo invece di 3000" % (GameState.tazo - prima_tazo))
	esigi(GameState.messaggi_non_letti() == 1,
			"il data pad non segnala %d messaggi non letti" % GameState.messaggi_non_letti())

	# UN MESSAGGIO ARRIVA UNA VOLTA SOLA. Senza questo, ogni flag rimesso - o
	# ogni caricamento - riaccrediterebbe i 3000 tazo.
	var soldi := GameState.tazo
	GameState.aggiorna_messaggi()
	GameState.aggiorna_messaggi()
	esigi(GameState.tazo == soldi,
			"chiamando due volte l'aggiornamento i tazo sono passati da %d a %d"
			% [soldi, GameState.tazo])

	# E LA SKIN SVUOTA IL CONTO. «IL MIO CONTO E' A ZERO...»: a zero, non meno
	# tremila - con una sottrazione resterebbero i trenta di partenza e la
	# battuta sarebbe una bugia.
	GameState.imposta_flag("skin_bobo_bunny")
	esigi("ricevuta_bobo_bunny" in GameState.messaggi_ricevuti,
			"comprata la skin non arriva nessuna ricevuta")
	esigi(GameState.tazo == 0,
			"dopo la skin sul conto restano %d tazo: la battuta dice zero" % GameState.tazo)

	# la sezione c'e' davvero nel data pad, e la missione pure
	var sezioni: Array[String] = []
	for voce in Pausa.SEZIONI_DIARIO:
		sezioni.append(String(voce[0]))
	esigi("messaggi" in sezioni,
			"il data pad non ha la sezione Messaggi: i 3000 tazo non si possono leggere da nessuna parte")
	esigi(not GameState.dati_task("prima_proiezione").is_empty(),
			"manca la missione che ti porta in sala di proiezione")

func prova_il_disco_si_interroga_una_volta() -> void:
	# «se il disegno c'e' vince lui» e' una buona regola, ma era scritta dentro
	# il DISEGNO:
	#
	#     if ResourceLoader.exists(percorso): load(percorso)
	#
	# Sulla mappa quel disegno si rifa' a ogni fotogramma finche' il punto
	# esclamativo pulsa: sessanta controlli sul filesystem al secondo per un file
	# che c'e' o non c'e' da quando il gioco e' partito.
	titolo("un disegno si chiede al disco una volta sola, non a ogni fotogramma")
	Disegni.svuota_cache()
	esigi(Disegni.ricerche == 0, "la cache dei disegni non si svuota")
	var finto := "res://art/che_non_esiste_di_sicuro.png"
	for giro in 50:
		Disegni.texture(finto)
	esigi(Disegni.ricerche == 1,
			"cinquanta richieste dello stesso disegno hanno interrogato il disco %d volte"
			% Disegni.ricerche)
	# ANCHE IL "NON C'E'" E' UNA RISPOSTA: e' quella che capita piu' spesso
	# finche' i disegni di Bru non ci sono, ed e' proprio quella che non veniva
	# ricordata
	esigi(Disegni.texture(finto) == null, "un disegno che non esiste non torna nullo")
	esigi(Disegni.ricerche == 1, "il 'non c'e'' non viene ricordato: si richiede ogni volta")
	Disegni.texture("res://art/nemmeno_questo.png")
	esigi(Disegni.ricerche == 2, "un secondo disegno diverso non viene cercato")

	# E DALLA PORTA VERA: la mappa che si ridisegna cento volte.
	#
	# PRIMA PERO' BISOGNA DIMOSTRARE CHE QUEL CODICE VIENE PERCORSO. La prima
	# versione di questa prova ridisegnava una mappa senza punto esclamativo in
	# vista: i cento ridisegni non toccavano mai il disegno dell'icona, e la
	# prova restava verde anche rimettendoci dentro la ricerca sul disco.
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	GameState.imposta_flag("rientro_infermeria")   # mappa tutta visibile, "!" sulla sala comunicazioni
	GameState.nodo_corrente = "infermeria"
	for id_stanza in ["alloggio", "sala_allenamento", "sala_comunicazioni",
			"infermeria", "archivio", "mensa", "sala_proiezione", "hangar"]:
		GameState.sblocca_stanza(String(id_stanza))
	var mappa: Node = load("res://scenes/MappaZona.tscn").instantiate()
	add_child(mappa)
	await get_tree().process_frame
	# SI DISEGNA PER DAVVERO, con queue_redraw e un fotogramma: chiamare a mano
	# _disegna_sopra() sembra piu' diretto ma Godot non lo permette - disegnare
	# fuori dal proprio _draw e' un errore, e una prova che lo fa sporca il
	# registro anche quando passa.
	Disegni.svuota_cache()
	mappa.strato_sopra.queue_redraw()
	await get_tree().process_frame
	await get_tree().process_frame
	var dopo_il_primo := Disegni.ricerche
	esigi(dopo_il_primo > 0,
			"disegnando la mappa non si e' chiesto nessun disegno: questa prova non sta misurando niente")
	for giro in 30:
		mappa.strato_sopra.queue_redraw()
		await get_tree().process_frame
	esigi(Disegni.ricerche == dopo_il_primo,
			"trenta ridisegni della mappa hanno interrogato il disco altre %d volte"
			% (Disegni.ricerche - dopo_il_primo))
	mappa.queue_free()

func dispatch_di_esegui_mossa() -> Dictionary:
	# I rami del match di esegui_mossa, letti DAL SORGENTE: etichetta -> nome
	# della funzione che il ramo chiama.
	#
	# Scritti a mano qui si scollerebbero dal codice al primo ramo aggiunto, e
	# una prova che si e' scollata e' peggio di nessuna prova: dice di guardare
	# una cosa e ne guarda un'altra.
	var testo := FileAccess.get_file_as_string("res://scripts/Combattimento.gd")
	var dentro := false
	var rami: Dictionary = {}
	var etichetta := ""
	for riga in testo.split("\n"):
		if riga.begins_with("func esegui_mossa("):
			dentro = true
			continue
		if dentro and riga.begins_with("func "):
			break
		if not dentro:
			continue
		var pulita := String(riga)
		if pulita.begins_with("\t\t\"") and pulita.ends_with("\":"):
			etichetta = pulita.strip_edges().trim_prefix("\"").trim_suffix("\":")
			# un ramo che non chiama niente resta a mano vuota, e si vede
			rami[etichetta] = ""
			continue
		if etichetta != "" and pulita.begins_with("\t\t\t"):
			var corpo := pulita.strip_edges()
			# i commenti stanno dentro il ramo e non sono quello che il ramo fa
			if corpo.begins_with("#"):
				continue
			if rami[etichetta] == "" and corpo.contains("("):
				rami[etichetta] = corpo.get_slice("(", 0)
	return rami

func funzioni_mossa_dichiarate() -> Array[String]:
	# LE FUNZIONI CHE FANNO UN RAMO, e solo quelle.
	#
	# "comincia per mossa_" non basta: con quel prefisso ci sono anche le domande
	# che si fanno PRIMA di eseguire - mossa_eseguibile, mossa_disponibile,
	# mossa_saggia, mossa_da_creatura - che scelgono una mossa e non ne fanno
	# nessuna. Quelle nel match non ci devono stare, e prenderle avrebbe fatto
	# gridare la prova contro quattro funzioni sanissime.
	#
	# La forma di un ramo estratto e' precisa: prende (chi, la mossa) e non
	# risponde niente. Le quattro domande rispondono tutte qualcosa - un
	# Dictionary, un bool - e cosi' si distinguono da sole.
	var testo := FileAccess.get_file_as_string("res://scripts/Combattimento.gd")
	var nomi: Array[String] = []
	for riga in testo.split("\n"):
		if riga.begins_with("func mossa_") and riga.ends_with("Dictionary) -> void:"):
			nomi.append(String(riga).trim_prefix("func ").get_slice("(", 0))
	return nomi

# I RAMI CHE NESSUNA CREATURA USA, E IL PERCHE'.
#
# Non e' un permesso generico: chi aggiunge un ramo al match e non lo da' a
# nessuno deve passare di qui e scrivere perche', altrimenti la prova lo boccia.
# Una lista di eccezioni senza motivazione e' solo un modo lento di spegnere un
# controllo.
const RAMI_SENZA_CREATURA := {
	"buff_fattore":
		"alza il Fattore Carnivalz, ed e' l'UNICO tipo di mossa che sappia " +
		"farlo: potenziamento passa dai buff, e un buff di stat 'fattore' non " +
		"lo legge nessuno (Regole.gd guarda solo attacco, difesa, velocita'). " +
		"E' documentato nel README e sa descriversi nella scheda nemici, ma " +
		"nel bestiario non lo dichiara nessuna creatura: e' contenuto che " +
		"manca, non codice morto. Toglierlo o darlo a qualcuno e' di Bru.",
}

# I RAMI CHE NON CHIAMANO UNA FUNZIONE COL LORO NOME, E PERCHE'.
#
# La prima versione di questa regola diceva "il ramo X chiama mossa_X, punto", e
# mi ha fatto scrivere tre funzioni che non servivano a niente:
#
#   func mossa_difendi(nemico, _mossa) -> void:   difendi(nemico)
#   func mossa_orda(nemico, mossa) -> void:       marea(nemico, mossa)
#   func mossa_scena(_nemico, mossa) -> void:     pass
#
# Un salto in piu', un nome in piu', zero complessita' nascosta - e l'ultima e'
# una funzione VUOTA nata solo per far contenta una prova. E' esattamente la
# bandiera rossa che Ousterhout chiama passacarte, ed e' il difetto che Google
# mette per primo dopo il progetto: codice piu' complicato del necessario.
#
# La regola giusta non e' "niente eccezioni", e' "le eccezioni si dichiarano".
# Adesso il ramo chiama la funzione che fa la cosa, anche quando si chiama
# diversamente, e qui sta scritto quale e perche'. La protezione contro il
# cablaggio sbagliato - il ramo "cura" che finisce su mossa_rubavita - resta
# intera: un ramo che cambia funzione senza passare di qui fallisce lo stesso.
const RAMI_CABLATI_ALTROVE := {
	"difendi": {"chiama": "difendi", "perche":
		"difendi() esisteva gia' ed e' la stessa cosa che fa il bottone " +
		"DIFENDI del giocatore: una creatura che si difende e un giocatore " +
		"che si difende devono alzare la guardia allo stesso modo, e due " +
		"strade separate sarebbero diventate due regole diverse"},
	"orda": {"chiama": "marea", "perche":
		"un'orda che attacca e' una marea: il nome e' quello del fatto che " +
		"si vede a schermo, non quello del campo nei dati. marea() la usa " +
		"anche l'orda che avanza da sola, quindi la mossa non la possiede"},
	"scena": {"chiama": "", "perche":
		"non fa niente, e lo fa apposta: e' la creatura che si guarda " +
		"intorno senza scopo. Una funzione vuota chiamata da un ramo per " +
		"non fare niente e' un giro largo per dire pass, e il commento che " +
		"spiega la scelta serve nel ramo, dove la scelta si legge"},
}

func prova_il_dispatch_delle_mosse_e_cablato_bene() -> void:
	# IL RISCHIO VERO DI UN'ESTRAZIONE MECCANICA A VENTITRE MANI.
	#
	# Spezzare un match di 318 righe in ventitre funzioni si fa a copia e
	# incolla, e il modo in cui si sbaglia e' sempre lo stesso: il ramo "cura"
	# che finisce per chiamare mossa_rubavita. A schermo non si vede - una
	# creatura fa una cosa diversa da quella che il suo bestiario prometteva - e
	# nessuna prova di comportamento lo nota, perche' una mossa sbagliata e'
	# comunque una mossa che funziona.
	#
	# Qui il patto e' esplicito e verificabile: il ramo "X" chiama mossa_X, e
	# basta. Letto dal sorgente, quindi non si scolla.
	titolo("ogni ramo di esegui_mossa chiama la funzione che porta il suo nome")
	var rami := dispatch_di_esegui_mossa()
	esigi(rami.size() >= 20,
			"dal sorgente ho letto solo %d rami: la lettura del match non funziona" % rami.size())
	var dichiarate := funzioni_mossa_dichiarate()
	var usate: Array[String] = []
	for etichetta in rami:
		var chiamata := String(rami[etichetta])
		if RAMI_CABLATI_ALTROVE.has(etichetta):
			var patto: Dictionary = RAMI_CABLATI_ALTROVE[etichetta]
			esigi(chiamata == String(patto["chiama"]),
					"il ramo '%s' e' dichiarato cablato su '%s' e invece chiama '%s'"
					% [etichetta, String(patto["chiama"]), chiamata])
			esigi(String(patto.get("perche", "")).length() > 40,
					"il ramo '%s' e' fra le eccezioni senza una motivazione vera" % etichetta)
			continue
		esigi(chiamata != "",
				"il ramo '%s' di esegui_mossa non chiama niente: e' una casella vuota" % etichetta)
		esigi(chiamata == "mossa_%s" % etichetta,
				"il ramo '%s' chiama '%s': deve chiamare 'mossa_%s'" % [etichetta, chiamata, etichetta])
		esigi(chiamata in dichiarate,
				"il ramo '%s' chiama '%s', che in Combattimento.gd non esiste" % [etichetta, chiamata])
		usate.append(chiamata)
	for etichetta in RAMI_CABLATI_ALTROVE:
		esigi(rami.has(etichetta),
				"fra i rami cablati altrove c'e' '%s', che nel match non esiste piu'" % etichetta)
	# e il verso opposto: una funzione estratta che nessun ramo chiama e' un
	# pezzo di combattimento che il gioco non puo' piu' raggiungere
	for nome in dichiarate:
		esigi(nome in usate,
				"%s() esiste ma nessun ramo di esegui_mossa la chiama: e' irraggiungibile" % nome)

func prova_ogni_tipo_di_mossa_ce_l_ha_qualcuno() -> void:
	# UNA DOMANDA SUI CONTENUTI, NON SUL CODICE: un tipo di mossa che il
	# combattimento sa fare e che nessuna creatura dichiara e' o un ramo morto da
	# togliere, o una creatura che manca. Tutte e due le risposte sono di Bru -
	# la prova serve a non lasciargliela scoprire in partita.
	titolo("ogni tipo di mossa che il combattimento sa fare ce l'ha qualcuno")
	var rami := dispatch_di_esegui_mossa()
	var usati: Dictionary = {}
	for id_creatura in creature():
		for mossa in GameState.personaggi.get(id_creatura, {}).get("mosse", []):
			usati[String((mossa as Dictionary).get("tipo", ""))] = true
	for etichetta in rami:
		if usati.has(etichetta):
			esigi(not RAMI_SENZA_CREATURA.has(etichetta),
					"'%s' e' fra i rami elencati come senza creatura, ma adesso qualcuno lo usa: togli l'eccezione" % etichetta)
			continue
		esigi(RAMI_SENZA_CREATURA.has(etichetta),
				"il ramo '%s' di esegui_mossa non lo usa nessuna creatura. O e' morto, o manca chi lo usa: decidi, e se resta scrivilo in RAMI_SENZA_CREATURA col perche'" % etichetta)

func prova_ogni_mossa_si_esegue_davvero() -> void:
	# QUESTA PROVA NASCE DA UN REFACTORING, e dal dubbio giusto su di esso.
	#
	# esegui_mossa era una funzione da 318 righe con ventitre rami. Spezzarla in
	# ventitre funzioni con un nome ha lasciato la suite verde e identica - ma
	# "identica" non vuol dire "verificata": se le prove percorrevano cinque
	# rami su ventitre, diciotto estrazioni erano state fatte alla cieca.
	#
	# Quindi si percorrono tutti, uno per uno, con una mossa vera presa dai dati
	# quando c'e' e una fatta a mano quando nel bestiario non c'e' nessuno.
	#
	# COSA MISURA DAVVERO, perche' da sola non basta: che il ramo si percorre
	# senza spaccarsi - argomenti giusti, niente null, niente tipo sbagliato. Che
	# il ramo giusto chiami la funzione giusta lo tiene
	# prova_il_dispatch_delle_mosse_e_cablato_bene, e non e' un doppione: qui
	# ultima_mossa_tipo lo scrive esegui_mossa PRIMA del match, quindi
	# leggerlo direbbe "sono entrata nel match", non "ho eseguito il ramo".
	titolo("ogni tipo di mossa si esegue davvero, e non solo sulla carta")
	var rami := dispatch_di_esegui_mossa()
	esigi(rami.size() >= 20,
			"dal sorgente ho letto solo %d rami: la lettura del match non funziona" % rami.size())

	# per ogni tipo, una mossa VERA dal bestiario se esiste
	var esempio: Dictionary = {}
	for id_creatura in creature():
		for mossa in GameState.personaggi.get(id_creatura, {}).get("mosse", []):
			var tipo := String((mossa as Dictionary).get("tipo", ""))
			if rami.has(tipo) and not esempio.has(tipo):
				esempio[tipo] = {"chi": id_creatura, "mossa": mossa}
	# e per i rami che nessuno usa, una mossa finta: il ramo va percorso lo
	# stesso, se no l'estrazione di quella funzione non l'ha verificata nessuno
	for etichetta in RAMI_SENZA_CREATURA:
		if not rami.has(etichetta) or esempio.has(etichetta):
			continue
		esempio[etichetta] = {
			"chi": creature()[0],
			"mossa": {"tipo": etichetta, "testo": "prova", "valore": 30},
		}

	var eseguiti := 0
	for etichetta in rami:
		esigi(esempio.has(etichetta),
				"del ramo '%s' non ho nessuna mossa con cui provarlo" % etichetta)
		if not esempio.has(etichetta):
			continue
		GameState.nuova_partita()
		GameState.nemici_combattimento = [String(esempio[etichetta]["chi"])]
		var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
		scontro.limite_giri = 1
		add_child(scontro)
		scontro.in_corso = true
		var nemici: Array[Dictionary] = scontro.vivi(false)
		if nemici.is_empty():
			scontro.free()
			continue
		var chi: Dictionary = nemici[0]
		chi.ultima_mossa_tipo = ""
		if etichetta == "buff_fattore":
			# da zero, se no il tetto a 100 renderebbe la somma indistinguibile
			chi.fattore = 0
		scontro.esegui_mossa(chi, esempio[etichetta]["mossa"])
		esigi(String(chi.ultima_mossa_tipo) == String(etichetta),
				"eseguendo una mossa di tipo '%s' il combattimento ha segnato '%s'"
				% [etichetta, String(chi.ultima_mossa_tipo)])
		if etichetta == "buff_fattore":
			# l'unico ramo senza creatura: qui l'effetto lo si guarda davvero,
			# se no resterebbe l'unico dei ventitre mai visto funzionare
			esigi(int(chi.fattore) == 30,
					"buff_fattore da 30 ha lasciato il Fattore a %d" % int(chi.fattore))
		eseguiti += 1
		scontro.voce.coda.clear()
		scontro.free()
	esigi(eseguiti == rami.size(),
			"ho eseguito %d rami su %d: gli altri non sono stati provati"
			% [eseguiti, rami.size()])

# --- IL TETTO ALLA STRUTTURA -------------------------------------------------
#
# Bru: "non passera' mai un controllo qualita' codice e struttura". Aveva
# ragione, e la parte scomoda e' che un audit sul COMPORTAMENTO non se ne
# accorge mai: il gioco funziona, le prove sono verdi, e intanto un file cresce
# fino a quattromila righe e una funzione fino a trecento. Nessuna prova del
# gioco puo' fallire per questo, perche' non e' il gioco a essere rotto.
#
# CHE COSA SI MISURA, E PERCHE' LA PRIMA VERSIONE MISURAVA MALE.
#
# All'inizio i tetti erano tre: righe per file, righe per funzione, profondita'
# dell'annidamento. Sono andata a leggere come si misura la leggibilita' fuori
# di qui, e il primo tetto ad andare giu' e' stato il mio.
#
# Sulla LUNGHEZZA la ricerca e' contro l'intuizione: McConnell, in Code
# Complete, cita sei studi in cui le funzioni piu' lunghe non avevano piu'
# difetti - e in diversi casi costavano meno e si leggevano meglio. Il numero di
# righe non e' una misura di quanto una funzione e' difficile: e' una misura di
# quanto e' grande, che non e' la stessa cosa.
#
# Sull'ANNIDAMENTO il difetto era mio: misuravo il punto PIU' PROFONDO, e cosi'
# una funzione con un solo se dentro due cicli e una che e' tutta annidata dalla
# prima riga all'ultima prendevano lo stesso voto.
#
# Adesso il garbuglio si misura con la COMPLESSITA' COGNITIVA (vedi
# complessita_cognitiva() qui sotto), che e' la metrica nata apposta perche' la
# ciclomatica misurava bene la testabilita' e male la leggibilita'. Somma invece
# di prendere il massimo, e fa pagare la profondita' a ogni punto.
#
# LA PROVA CHE LA METRICA VECCHIA GUARDAVA ALTROVE: fra le quattro funzioni piu'
# ingarbugliate del progetto, DUE non erano mai comparse - Main.ricostruisci_scelte
# (48) e Combattimento._ready (41). Non sono lunghe e non sono profonde: sono
# catene di condizioni piatte, e i tetti di prima non le vedevano.
#
# LE SOGLIE, misurate su questo codice:
#
#   961 funzioni -> garbuglio: mediana 2, 90mo 8, 95mo 12, 99mo 31
#   961 funzioni -> righe: mediana 11, 90mo 32, 99mo 86
#   49 file      -> righe: mediana 182, solo cinque sopra le 600
#
# Quindici di garbuglio e' la soglia predefinita di Sonar, ed e' anche il 95mo
# percentile di qui: le due cose cadono nello stesso punto, il che e' il
# migliore argomento possibile per una soglia. Cento righe per funzione resta,
# ma DECLASSATO: non e' piu' il controllo principale, e' una rete grossolana
# contro la funzione che diventa un file.
#
# COME SI COMPORTA LA RETE:
#   - una cosa NUOVA sopra il tetto            -> fallisce: non si peggiora
#   - un'eccezione che CRESCE                  -> fallisce: non si allarga
#   - un'eccezione che scende SOTTO il tetto   -> fallisce, e chiede di
#     togliersi dall'elenco: la rete si stringe, non si allenta
#
# NON si stringe da sola quando una cosa cala restando sopra il tetto: se
# Combattimento.gd passa da 4421 a 3000 righe qui resta scritto 4421 finche'
# qualcuno non aggiorna il numero. E' un compromesso voluto - se ogni
# miglioramento facesse fallire la suite, la prima cosa che si impara e' a
# spegnerla - ed e' il motivo per cui il messaggio stampa sempre la misura vera.
#
# I numeri delle righe sono quelli di split("\n"), cioe' uno in piu' di `wc -l`
# per un file che finisce con un a capo. Non importa quale delle due convenzioni
# sia "giusta", importa che sia la stessa che usa la prova.
#
# COSA NON MISURA, E PERCHE' LO DICO. Guarda scripts/, non prove/. Questo file
# e' oltre settemila righe e non passerebbe nessuno dei tetti - non e' una
# svista, ed e' giusto saperlo leggendo. Un file di prove cresce di una funzione
# ogni volta che si prova una cosa in piu', quindi un tetto qui fallirebbe a
# ogni prova nuova, e la cosa che si impara in fretta e' ad alzare il numero
# senza guardare. Una rete che si impara a disinnescare non protegge piu'
# niente, nemmeno i file per cui era stata tesa.

const TETTO_RIGHE_FILE := 700
const TETTO_RIGHE_FUNZIONE := 100
const TETTO_COGNITIVA := 15

const FILE_GRANDI := {
	"Combattimento.gd": {"misura": 4806, "perche":
		"il motore dello scontro: quattordici mestieri dichiarati nei suoi " +
		"stessi commenti. Ne sono usciti gli stati (Stati.gd) e il buffer " +
		"dei comandi (Intenzione.gd), e adesso so perche' quei due e non " +
		"altri: NASCONDONO UNA DECISIONE. Parnas: «si comincia da un elenco " +
		"di decisioni di progetto difficili, o che cambieranno; ogni modulo " +
		"e' poi disegnato per nascondere una di quelle decisioni». Stati.gd " +
		"nasconde cosa fa stati.json addosso a un combattente, Intenzione.gd " +
		"nasconde quando un comando dato presto puo' partire - e quella " +
		"politica (una casella, vince l'ultimo, nessuna scadenza) e' proprio " +
		"cio' che cambiera' dopo il primo playtest. " +
		"I tre blocchi che restano - il tempo, la scelta delle mosse, la " +
		"risoluzione dei colpi - NON sono decisioni nascoste: sono passi del " +
		"processo, ed e' esattamente la decomposizione che Parnas chiama " +
		"'quasi sempre sbagliata'. Non li stacco lo stesso, ma la ragione " +
		"buona non e' la mia (chiamano decine di funzioni del motore): e' " +
		"quella dei due programmatori di Celeste, che sullo stesso problema " +
		"scrivono di tenere il codice sequenziale in un file solo perche' " +
		"«il comportamento va ordinato e tarato molto strettamente». Le due " +
		"fonti si contraddicono e stanno tutte e due in docs/fonti. " +
		"IL NUMERO E' SALITO DA 4544, e il conto va detto per intero: il " +
		"buffer degli input valeva 115 righe, 97 sono finite in " +
		"Intenzione.gd, esegui_turno - un passa-carte che non chiamava piu' " +
		"nessuno - e' sparito, e restano 24 righe nette. Poi altre 6 per spiegare perche' una guardia sull'eco della tastiera NON c'e' piu' (la documentazione di InputEvent dice che era ridondante), e 9 per far parare la raffica anche da tastiera - era l'unico pezzo del combattimento che pretendeva un mouse. E 24 per «Salta la lezione», offerta solo a chi l'allenamento l'ha gia' fatto in una partita precedente. " +
			"E 29 per la fine dell'allenamento, che Bru giocando descriveva cosi': «fa fatica a rimettersi in " +
			"carreggiata, cliccando a caso va avanti». Erano quattro difetti: a scontro chiuso il box " +
			"raccontava DIETRO al menu (decidi_faccia), la raffica poteva mandarti KO e ripartire da capo " +
			"(vita_minima), la barra della vita segnava 0 coi pugni invece che con la Meteora " +
			"(mostra_vita_di_allora), e il ritratto si spegneva dopo le scuse di Veronica invece che sul " +
			"colpo (abbatte). I commenti li ho accorciati prima di alzare il numero, non dopo. Alzare la misura e' " +
		"una decisione, non una svista: si scrive qui cosa si e' comprato. " +
		"DA 4657 A 4765 per le Pianure di Redenna (24 settembre), e il conto intero: 26 righe per " +
		"un DIFETTO - in tempo reale la battuta di chi comandi tu non si apriva mai (niente veleno, " +
		"niente sonno, potenziamenti eterni), adesso apri_la_battuta la apre anche da agisci_ora; " +
		"29 per le orde che annunciano la mossa (scegli_mossa staccata da turno_nemico_normale, che " +
		"in cambio e' uscita dall'elenco delle ingarbugliate, e preannuncia); 33 per le due abilita' " +
		"nuove (onda, potenziati); il resto sono gli agganci della regia (Regia.gd, un file suo) e il " +
		"tasto BOND, che era disegnato e non era collegato a niente. " +
		"POI 22 NEL GIRO DI REVISIONE: aggiorna_bond (BOND pulsa a scena finita, non sotto il testo), " +
		"l'annuncio che resta sulla scheda (tre righe, una per ogni momento in cui cambia) e la fuga " +
		"negata che non costa il turno. " +
		"DA 4787 A 4806 per il goblin arrabbiato: 18 righe per la Mazzata - il ramo del match e " +
		"mossa_mazzata, la creazione e il collegamento, SPAZIO che le spetta prima della Mattanza, il " +
		"fotogramma che si prende, e gioco_con_la_mano, che mette raffica e mazza sotto le stesse tre " +
		"domande (la fase, la faccia, il process) invece di ripeterle due volte; 1 per collegare il " +
		"bersaglio di chi viene evocato a scontro avviato, che prima non si poteva cliccare. Il braccio di " +
		"ferro, il suo riquadro e chi lo lancia stanno in file loro (Contrasto.gd, " +
		"RiquadroContrasto.gd, Mazzata.gd), i quadratini dei gregari in Gregari.gd"},
	"GameState.gd": {"misura": 2549, "perche":
		"lo stato del mondo piu' il caricamento di tutti i dati piu' i " +
		"salvataggi. ALLARGATA DA 2537 A 2549 col controllo a basso livello: " +
		"riprendi_il_dado() rimette lo stato del dado salvato invece di " +
		"ripartire dal seme (RandomNumberGenerator.state, doc Godot 4.7). " +
		"Dodici righe, quasi tutte il perche': la funzione vera e' di tre. " +
		"Prima: " +
		"salvataggi. E' il prossimo da guardare, e a differenza del " +
		"combattimento qui i pezzi sono davvero separabili: i file di dati " +
		"non c'entrano niente con gli slot di salvataggio. " +
		"ALLARGATA DA 2530 A 2537: applica_crescita_livello() sapeva gia' per " +
		"quale azione stava dando quei punti, e lo buttava via un istante " +
		"dopo averlo calcolato - per questo la salita di livello diceva " +
		"'forza 12 -> 14' senza il perche', che in un gioco dove le stat " +
		"salgono con quello che FAI e' meta' di quello che conta. Sette " +
		"righe per far sopravvivere il dato fino a chi lo racconta. Il " +
		"racconto invece non e' entrato qui: sta in Resoconto.gd, e in " +
		"cambio ha tolto quarantanove righe di presentazione da Main.gd"},
	"Main.gd": {"misura": 1476, "perche":
		"il direttore della storia: dialoghi, scelte, notifiche, cambi di " +
		"scena. Cresce con la trama, che e' ancora in scrittura: spezzarlo " +
		"adesso vuol dire spezzarlo di nuovo fra un mese. " +
		"ALLARGATA DA 1474 A 1476, e vale la pena dire perche': l'attesa " +
		"fissa di 2,2 secondi dell'espulsione automatica e' diventata " +
		"saltabile, ed e' nata esci_dal_posto - che in cambio ha tolto una " +
		"duplicazione. Per stare dentro il numero stavo cancellando i " +
		"commenti che spiegano la correzione: il cricchetto serve a fermare " +
		"la deriva, non a farmi peggiorare il codice per due righe"},
	"Plancia.gd": {"misura": 715, "perche":
		"la schermata di combattimento intera, come l'ha disegnata Bru: il " +
		"riquadro della creatura, i tre della squadra, le tre barre, l'ECG, " +
		"i due tasti, e le tre facce del quadrante. Ha passato le 700 righe " +
		"aggiungendo l'evidenziazione dei pezzi, e quella parte NON si stacca: " +
		"pezzo() esiste proprio perche' e' la plancia a sapere com'e' fatta - " +
		"portarla fuori darebbe un file che non sa niente e chiede tutto"},
}

const FUNZIONI_LUNGHE := {
	"Combattimento.gd:aggiungi_combattente": {"misura": 163, "perche":
		"costruisce la scheda di un combattente campo per campo: e' lunga " +
		"perche' i campi sono tanti, non perche' faccia piu' di una cosa. " +
		"Spezzarla darebbe tre funzioni che si passano lo stesso Dictionary"},
	"Regole.gd:calcola_danno": {"misura": 124, "perche":
		"la formula del danno, tutta di seguito: tipo, critico, carica, " +
		"fattore, difesa, scatti, disperazione. E' il punto in cui si va a " +
		"leggere 'perche' ho fatto 47', e volerla in un posto solo e' una " +
		"scelta, non una pigrizia"},
	"Combattimento.gd:mossa_eseguibile": {"misura": 123, "perche":
		"tutte le condizioni che una mossa puo' dichiarare nei dati (quando, " +
		"priorita', ricarica, massimo_usi, dopo_mossa, alleati vivi). Da " +
		"guardare insieme a risolvi_drop: e' una delle due funzioni sopra il " +
		"tetto ANCHE per garbuglio, a quota 52, e quello si', e' un difetto"},
	"GameState.gd:_leggi_salvataggio": {"misura": 119, "perche":
		"legge un salvataggio campo per campo con un ripiego per ognuno, " +
		"perche' un file vecchio non ha i campi nuovi. Ogni riga e' una " +
		"compatibilita' all'indietro"},
	"Stati.gd:applica_stato": {"misura": 117, "perche":
		"un ramo per tipo di status (riserva, sonno, dot, velocita', " +
		"terrore, forza_attacco). E' lo stesso caso di esegui_mossa, e si " +
		"spezza allo stesso modo: e' il prossimo della lista"},
	"Combattimento.gd:attacca": {"misura": 104, "perche":
		"la sequenza intera di un colpo: bersaglio a terra, schivata, danno, " +
		"impatto, stati, KO. E' l'ordine dei fatti, ed e' il mestiere " +
		"dichiarato di questo file"},
	"Combattimento.gd:flagello": {"misura": 102, "perche":
		"venti o venticinque colpi tirati uno per uno, ognuno col suo " +
		"bersaglio, il suo fallimento e il suo critico, piu' il riepilogo. E' " +
		"un'abilita' sola e sta tutta qui"},
}

# LE FUNZIONI INGARBUGLIATE, col loro punteggio di oggi.
#
# Sopra la soglia della motivazione c'e' scritto anche PERCHE': sotto, il numero
# e' gia' tutta la storia - e' debito che si sta tenendo d'occhio. Sopra, non e'
# piu' debito, e' un difetto, e un difetto va chiamato per nome.
const MOTIVAZIONE_SOPRA := 30

const FUNZIONI_INGARBUGLIATE := {
	"Combattimento.gd:risolvi_drop": {"misura": 63, "perche":
		"la peggiore del progetto: nemici per oggetti per condizioni, tre " +
		"cicli annidati con un if dentro ognuno. Il tetto non serve a " +
		"proteggerla, serve a ricordare che e' la prima da voltare"},
	"Combattimento.gd:mossa_eseguibile": {"misura": 54, "perche":
		"tutte le condizioni che una mossa puo' dichiarare nei dati messe " +
		"una dietro l'altra. Si spezza per condizione - una funzione per " +
		"'quando', una per 'ricarica' - e cade sotto il tetto da sola"},
	"Main.gd:ricostruisci_scelte": {"misura": 49, "perche":
		"NON L'AVEVO MAI VISTA. Non e' lunga e non e' annidata: e' una " +
		"catena di condizioni piatte, e con i tetti di prima - righe e " +
		"profondita' - era invisibile. E' la prova che la metrica vecchia " +
		"guardava dalla parte sbagliata"},
	"GameState.gd:cerca_creature": {"misura": 44, "perche":
		"cerca dentro zone dentro nodi dentro gruppi dentro elenchi. " +
		"Difetto vero: il rimedio e' voltare i cicli e uscire prima"},
	"Combattimento.gd:_ready": {"misura": 41, "perche":
		"NEMMENO QUESTA L'AVEVO VISTA. Costruisce otto collaboratori e ogni " +
		"costruzione ha il suo se: e' il punto in cui lo scontro decide cosa " +
		"esiste, e si spezza in 'costruisci i moduli' e 'accendi la scena'"},
	"Stati.gd:risolvi_stati_a_inizio_turno": {"misura": 39, "perche":
		"un ciclo sugli stati addosso, un match sul tipo, e dentro il sonno " +
		"il tiro di risveglio con le sue uscite. Si appiattisce quando " +
		"applica_stato si spezza per tipo, e con lo stesso lavoro"},
	"Combattimento.gd:battuta_di": {"misura": 30, "perche":
		"sceglie la frase giusta per il fatto giusto e le condizioni sono " +
		"tante quante i fatti. Candidata a diventare una tabella nei dati " +
		"invece che una scala di se. ERA SEGNATA 38 e misurava 30: era gia' " +
		"calata e la rete non se n'era accorta, perche' un calo che resta " +
		"sopra il tetto passa in silenzio apposta (vedi sopra). Ritarata"},
	"Combattimento.gd:attacca": {"misura": 35, "perche":
		"la sequenza intera di un colpo: a terra, schivata, danno, impatto, " +
		"stati, KO. E' l'ordine dei fatti, ed e' il mestiere dichiarato di " +
		"questo file - qui la complessita' e' del problema, non del codice"},
	"Stati.gd:applica_stato": {"misura": 34, "perche":
		"un ramo per tipo di status. E' lo stesso caso di esegui_mossa e si " +
		"spezza allo stesso modo: e' il prossimo della lista"},
	"Main.gd:_su_scelta": {"misura": 31, "perche":
		"tutto quello che una scelta di dialogo puo' innescare. Cresce con " +
		"la trama, che e' ancora in scrittura"},
	"BoxTesto.gd:respiri": {"misura": 27},
	"Combattimento.gd:_racconta_ko": {"misura": 29},
	"Combattimento.gd:esegui_azione": {"misura": 29},
	"Combattimento.gd:studia": {"misura": 27},
	"Combattimento.gd:applica_effetto": {"misura": 26},
	"GameState.gd:_leggi_salvataggio": {"misura": 25},
	"GameState.gd:verifica_passive": {"misura": 26},
	"Campo.gd:aggiorna": {"misura": 22},
	"Combattimento.gd:condizioni_mossa": {"misura": 25},
	"GameState.gd:aggiungi_oggetto": {"misura": 21},
	"Campo.gd:dettagli_di": {"misura": 20},
	"Combattimento.gd:flagello": {"misura": 22},
	"Regole.gd:calcola_danno": {"misura": 20},
	"Combattimento.gd:mantra": {"misura": 19},
	"Combattimento.gd:verifica_fine_scontro": {"misura": 19},
	"Combattimento.gd:azione_automatica": {"misura": 19},
	"Voce.gd:svuota_coda": {"misura": 19},
	"Combattimento.gd:aggiungi_combattente": {"misura": 17},
	"GameState.gd:aggiorna_task": {"misura": 17},
	"MappaZona.gd:_disegna_sotto": {"misura": 16},
	"Negozio.gd:costruisci": {"misura": 16},
}

func complessita_cognitiva(corpo: Array[String]) -> int:
	# LA COMPLESSITA' COGNITIVA, nelle tre regole di Sonar.
	#
	#   1. niente punti per le scorciatoie di scrittura;
	#   2. un punto per ogni rottura del flusso lineare (if, elif, else, for,
	#      while, match, e ogni sequenza di operatori logici);
	#   3. e in piu' TANTI PUNTI QUANTO E' PROFONDO il punto in cui succede -
	#      un if dentro un for dentro un for costa tre, non uno.
	#
	# La terza regola e' tutta la differenza. Un metodo con dieci se in fila e
	# uno con un se dentro due cicli hanno la stessa complessita' ciclomatica e
	# non si leggono per niente allo stesso modo.
	#
	# else ed elif prendono il punto ma NON la profondita': stanno alla stessa
	# altezza del se che continuano, e farglielo pagare due volte punirebbe una
	# scala di casi - che si legge bene - come se fosse un annidamento.
	#
	# GLI OPERATORI LOGICI: UNA SEQUENZA, UN PUNTO. Questa riga l'avevo scritta
	# sbagliata, e me ne sono accorto solo leggendo la specifica di Campbell
	# (docs/fonti/complessita-cognitiva-sonar.pdf) invece della sua sintesi.
	# Contavo "c'e' un and? +1; c'e' un or? +1", per riga. La regola vera e':
	#
	#   «La complessita' cognitiva NON incrementa per ogni operatore logico
	#   binario. [...] Capire la seconda riga di ogni coppia non e' molto piu'
	#   difficile della prima.»   a and b   vs   a and b and c and d
	#
	# Cioe': una SEQUENZA di operatori uguali vale UNO. Si paga solo quando
	# l'operatore CAMBIA - `a and b or c and d` vale tre, perche' sono tre
	# sequenze. Il mio conto dava due, e su `a and b and c` dava uno per caso.
	#
	# COSA RESTA APPROSSIMATO, detto qui e non nascosto: la specifica conta
	# anche le sotto-sequenze fra parentesi come sequenze a se'
	# (`a and !(b and c)` vale tre), e per farlo servirebbe un parser vero.
	# Qui le parentesi non si guardano. E una condizione spezzata su piu' righe
	# con la barra si conta riga per riga, quindi puo' pagare piu' del dovuto:
	# e' la stessa cosa che la guida di stile di Godot sconsiglia di scrivere,
	# quindi l'approssimazione punisce esattamente cio' che andrebbe evitato.
	var totale := 0
	for riga in corpo:
		var nuda := riga.strip_edges()
		if nuda == "" or nuda.begins_with("#"):
			continue
		var profondita := maxi(riga.length() - riga.lstrip("\t").length() - 1, 0)
		if nuda.begins_with("if ") or nuda.begins_with("for ") \
				or nuda.begins_with("while ") or nuda.begins_with("match "):
			totale += 1 + profondita
		elif nuda.begins_with("elif ") or nuda.begins_with("else:") or nuda.begins_with("else "):
			totale += 1
		totale += sequenze_logiche(nuda)
	return totale

func sequenze_logiche(riga: String) -> int:
	# Quante SEQUENZE di operatori logici uguali ci sono in fila: `a and b and c`
	# e' una, `a and b or c` sono due. E' il conto che chiede Campbell, e si fa
	# scorrendo gli operatori in ordine e contando quante volte cambiano.
	var quante := 0
	var precedente := ""
	var pezzi := riga.split(" ")
	for pezzo in pezzi:
		if pezzo != "and" and pezzo != "or":
			continue
		if pezzo != precedente:
			quante += 1
			precedente = pezzo
	return quante

func misura_funzioni(percorso: String) -> Array[Dictionary]:
	# Ogni funzione del file: quanto e' lunga e quanto e' ingarbugliata.
	var righe := testo_script(percorso).split("\n")
	var inizi: Array[int] = []
	var nomi: Array[String] = []
	for i in righe.size():
		var riga := String(righe[i])
		if riga.begins_with("func ") or riga.begins_with("static func "):
			inizi.append(i)
			nomi.append(riga.trim_prefix("static ").trim_prefix("func ").get_slice("(", 0))
	var trovate: Array[Dictionary] = []
	for k in inizi.size():
		var da: int = inizi[k]
		var a: int = righe.size()
		if k + 1 < inizi.size():
			a = inizi[k + 1]
		# via le righe vuote in coda: sono lo spazio fra una funzione e l'altra,
		# non fanno parte di nessuna delle due
		while a > da + 1 and String(righe[a - 1]).strip_edges() == "":
			a -= 1
		var corpo: Array[String] = []
		for i in range(da + 1, a):
			corpo.append(String(righe[i]))
		trovate.append({
			"nome": nomi[k],
			"righe": a - da,
			"cognitiva": complessita_cognitiva(corpo),
		})
	return trovate

func controlla_tetto(chiave: String, misura: int, tetto: int, eccezioni: Dictionary,
		cosa: String, motivazione_sopra := 0) -> void:
	# la stessa regola per i file, per la lunghezza e per il garbuglio: scritta
	# tre volte sarebbe diventata tre regole diverse al primo ritocco
	if not eccezioni.has(chiave):
		esigi(misura <= tetto,
				"%s: %s e' %d, il tetto e' %d. O lo riduci, o lo metti fra le eccezioni col perche'"
				% [chiave, cosa, misura, tetto])
		return
	var concesso := int(eccezioni[chiave]["misura"])
	esigi(misura <= concesso,
			"%s: %s e' cresciuto da %d a %d. Le eccezioni non si allargano"
			% [chiave, cosa, concesso, misura])
	esigi(misura > tetto,
			"%s: %s e' sceso a %d, sotto il tetto di %d. Toglilo dalle eccezioni"
			% [chiave, cosa, misura, tetto])
	if misura < motivazione_sopra:
		return
	esigi(String(eccezioni[chiave].get("perche", "")).length() > 40,
			"%s sta fra le eccezioni a quota %d senza una motivazione vera: un elenco senza perche' e' solo un modo lento di spegnere il controllo"
			% [chiave, misura])

func prova_il_metro_del_garbuglio_e_quello_giusto() -> void:
	# CHI MISURA IL METRO. Il tetto strutturale si fida di complessita_cognitiva,
	# e quella funzione l'avevo scritta a memoria da una sintesi: contava "c'e'
	# un and? +1; c'e' un or? +1", per riga. Leggendo la specifica di Campbell
	# (docs/fonti/complessita-cognitiva-sonar.pdf) la regola e' un'altra: una
	# SEQUENZA di operatori uguali vale UNO, e si paga solo quando l'operatore
	# cambia.
	#
	# Gli esempi qui sotto sono quelli che la specifica porta scritti, tradotti
	# da && e || in and e or. Non li ho inventati io: e' il modo di non
	# rifidarmi della mia memoria una seconda volta.
	titolo("le sequenze di operatori logici si contano come dice la specifica")
	var casi := {
		"a and b": 1,
		"a and b and c and d": 1,
		"a or b": 1,
		"a or b or c or d": 1,
		"a or b and c or d": 3,
		"a": 0,
		"a and b and c or d or e and f": 3,
	}
	for espressione in casi:
		var atteso: int = casi[espressione]
		var avuto := sequenze_logiche(String(espressione))
		esigi(avuto == atteso,
				"«%s» vale %d sequenze, la specifica ne conta %d"
				% [espressione, avuto, atteso])

	# E L'ESEMPIO INTERO DELLA SPECIFICA, quello con l'if:
	#   if (a && b && c || d || e && f)   -> +1 per l'if, +3 per le sequenze
	var corpo: Array[String] = ["\tif a and b and c or d or e and f:", "\t\tpass"]
	esigi(complessita_cognitiva(corpo) == 4,
			"l'esempio della specifica vale %d invece di 4" % complessita_cognitiva(corpo))

	# UN MATCH VALE UNO, non uno per ramo. E' l'altra regola che distingue la
	# complessita' cognitiva da quella ciclomatica, ed e' quella per cui
	# esegui_azione non e' punita per avere ventitre casi
	var con_match: Array[String] = ["\tmatch tipo:", "\t\t\"a\":", "\t\t\t pass",
			"\t\t\"b\":", "\t\t\t pass", "\t\t\"c\":", "\t\t\t pass"]
	esigi(complessita_cognitiva(con_match) == 1,
			"un match con tre rami vale %d: la specifica ne conta uno solo"
			% complessita_cognitiva(con_match))

	# else ed elif prendono il punto ma NON la profondita': «il costo mentale
	# e' gia' stato pagato leggendo l'if»
	var scala: Array[String] = ["\tif a:", "\t\tpass", "\telif b:", "\t\tpass",
			"\telse:", "\t\tpass"]
	esigi(complessita_cognitiva(scala) == 3,
			"una scala if/elif/else vale %d invece di 3" % complessita_cognitiva(scala))

func prova_il_tetto_alla_struttura() -> void:
	titolo("nessun file e nessuna funzione cresce oltre il tetto misurato")
	var visti_file: Array[String] = []
	var viste_funzioni: Array[String] = []
	for percorso in script_del_gioco():
		var nome_file := percorso.get_file()
		visti_file.append(nome_file)
		controlla_tetto(nome_file, testo_script(percorso).split("\n").size(),
				TETTO_RIGHE_FILE, FILE_GRANDI, "il file")
		for f in misura_funzioni(percorso):
			var chiave := "%s:%s" % [nome_file, String(f["nome"])]
			viste_funzioni.append(chiave)
			controlla_tetto(chiave, int(f["righe"]), TETTO_RIGHE_FUNZIONE,
					FUNZIONI_LUNGHE, "la funzione")
			controlla_tetto(chiave, int(f["cognitiva"]), TETTO_COGNITIVA,
					FUNZIONI_INGARBUGLIATE, "il garbuglio", MOTIVAZIONE_SOPRA)
	# UN'ECCEZIONE PER UNA COSA CHE NON ESISTE PIU' e' peggio di nessuna
	# eccezione: resta li' a dare il permesso a un nome che un giorno qualcuno
	# riusa per un'altra cosa
	for chiave in FILE_GRANDI:
		esigi(String(chiave) in visti_file,
				"fra le eccezioni c'e' il file '%s', che non esiste piu'" % chiave)
	for chiave in FUNZIONI_LUNGHE:
		esigi(String(chiave) in viste_funzioni,
				"fra le eccezioni sulla lunghezza c'e' '%s', che non esiste piu'" % chiave)
	for chiave in FUNZIONI_INGARBUGLIATE:
		esigi(String(chiave) in viste_funzioni,
				"fra le eccezioni sul garbuglio c'e' '%s', che non esiste piu'" % chiave)

func prova_osserva_la_scena_c_e_gia_alla_prima_visita() -> void:
	# Bru, provando: «uscito dalla mappa è spuntata anche osserva scena, osserva
	# scena deve già essere disponibile finiti i dialoghi».
	#
	# Compariva solo dalla SECONDA visita, perche' la condizione era
	# "mostrando_scena" - una variabile che fa un altro mestiere: dice se il nodo
	# sta suonando la descrizione invece dei dialoghi, e alla prima visita e'
	# falsa. Il bottone non c'entra con la visita: c'entra col fatto che questo
	# posto abbia qualcosa da guardare.
	titolo("«Osserva la scena» c'e' gia' la prima volta, finiti i dialoghi")
	GameState.nuova_partita()
	GameState.eventi["prova_osserva"] = {
		"sequenza": [{"tipo": "narrazione", "testo": "Entri."}],
		"scena": "Il posto, adesso.",
		"scelte": [{"testo": "Vai via", "vai": "prova_osserva"}],
	}
	GameState.nodo_corrente = "prova_osserva"
	IngressoNodo.ultimo_esito = {}
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	# prima visita: mostrando_scena e' falsa, ed e' giusto che lo sia
	schermata.mostrando_scena = false
	schermata.ricostruisci_scelte(GameState.eventi["prova_osserva"])
	await get_tree().process_frame
	esigi(cerca_bottone_con_testo(schermata.contenitore_scelte, "Osserva la scena") != null,
			"alla prima visita «Osserva la scena» non c'e': si vedeva solo tornandoci una seconda volta")
	# E UN POSTO SENZA DESCRIZIONE NON LO OFFRE. Senza questa meta', la
	# correzione piu' pigra - mostrarlo sempre - passerebbe la prova, e
	# regalerebbe un bottone che apre il vuoto
	GameState.eventi["prova_senza_scena"] = {
		"sequenza": [{"tipo": "narrazione", "testo": "Entri."}],
		"scelte": [{"testo": "Vai via", "vai": "prova_senza_scena"}],
	}
	schermata.ricostruisci_scelte(GameState.eventi["prova_senza_scena"])
	await get_tree().process_frame
	esigi(cerca_bottone_con_testo(schermata.contenitore_scelte, "Osserva la scena") == null,
			"un posto che non ha nessuna 'scena' offre lo stesso di osservarla")
	schermata.queue_free()

func prima_del_cancello(dati: Dictionary, cancello: String, accesi_prima: Array[String]) -> Array[String]:
	# i nodi che si possono vedere prima che il cancello si accenda, camminando
	# dal nodo iniziale. Ci si ferma su chi lo accende (entrando: da li' in poi
	# il cancello e' aperto). Strada facendo si annotano in accesi_prima i flag
	# che si possono accendere, e le regole "vai_se_flag" si seguono solo se il
	# loro flag e' fra quelli
	var nodi: Dictionary = dati.get("nodi", {})
	var visti: Array[String] = []
	var da_vedere: Array[String] = [String(dati.get("nodo_iniziale", ""))]
	while not da_vedere.is_empty():
		var id_nodo: String = da_vedere.pop_front()
		if id_nodo == "" or id_nodo in visti or not nodi.has(id_nodo):
			continue
		visti.append(id_nodo)
		var nodo: Dictionary = nodi[id_nodo]
		if String(nodo.get("flag", "")) == cancello:
			continue
		for acceso in flag_accesi_da(nodo):
			if acceso != cancello and acceso not in accesi_prima:
				accesi_prima.append(acceso)
		var senza_regole := nodo.duplicate()
		senza_regole.erase("vai_se_flag")
		for dove in destinazioni_di(senza_regole):
			da_vedere.append(dove)
		var regole: Variant = nodo.get("vai_se_flag", [])
		for regola in ([regole] if regole is Dictionary else regole as Array):
			if String((regola as Dictionary).get("flag", "")) in accesi_prima:
				da_vedere.append(String((regola as Dictionary).get("vai", "")))
	return visti

func flag_accesi_da(nodo: Dictionary) -> Array[String]:
	# ogni flag che passare da questo nodo puo' accendere: entrando, con una
	# scelta, a meta' di una battuta
	var accesi: Array[String] = []
	if nodo.has("flag"):
		accesi.append(String(nodo["flag"]))
	for scelta in nodo.get("scelte", []):
		for chiave in ["flag", "una_tantum"]:
			if (scelta as Dictionary).has(chiave):
				accesi.append(String((scelta as Dictionary)[chiave]))
	for msg in nodo.get("sequenza", []):
		if (msg as Dictionary).has("flag"):
			accesi.append(String((msg as Dictionary)["flag"]))
	return accesi

func prova_la_mappa_non_si_apre_prima_di_essere_spiegata() -> void:
	# Bru: «sulla mappa ho cliccato sul punto esclamativo e mi ha portato subito
	# nella sala allenamento, non va bene, la mappa deve essere consultabile dopo
	# la spiegazione di come si usa non prima».
	titolo("la mappa non si consulta prima che il gioco l'abbia spiegata")

	# 1. IL CANCELLO, SUL MOTORE.
	GameState.nuova_partita()
	GameState.avvia_carnivalz("introduzione", "res://data/events_intro.json")
	var chiave := String(GameState.mappa_zona.get("richiede_flag", ""))
	esigi(chiave != "",
			"la mappa del complesso non dichiara nessun 'richiede_flag': si aprirebbe dalla prima schermata")
	esigi(not GameState.mappa_consultabile(),
			"a partita appena cominciata la mappa del complesso e' gia' consultabile")
	GameState.imposta_flag(chiave)
	esigi(GameState.mappa_consultabile(),
			"acceso '%s' la mappa dovrebbe aprirsi, e resta chiusa" % chiave)

	# 2. E NESSUNA SCELTA CI PUO' MANDARE PRIMA.
	#
	# Il cancello sul bottone da solo non bastava, ed e' il difetto vero che Bru
	# ha trovato: la prima mattina "Esci dalla stanza" usciva PASSANDO dalla
	# mappa. Quella strada il bottone non la vede nemmeno, e portava il giocatore
	# sulla sua prima schermata di mappa - un attrezzo mai presentato, con sopra
	# un punto esclamativo che teletrasporta - prima di qualunque riga che
	# spiegasse cos'e'.
	#
	# Si cammina il grafo dal nodo iniziale e ci si FERMA su chi accende il
	# flag: tutto quello che si tocca strada facendo e' roba che il giocatore
	# puo' vedere prima, e li' dentro non ci deve stare nessun ritorno a mappa.
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		var cancello := String(dati.get("mappa_dungeon", {}).get("richiede_flag", ""))
		if cancello == "":
			continue  # mappa sempre aperta: nelle Pianure e' giusto cosi'
		var nodi: Dictionary = dati.get("nodi", {})
		# UNA REGOLA "vai_se_flag" SCATTA SOLO COL SUO FLAG. Il pomeriggio del
		# complesso sta tutto dietro regole che chiedono il cancello stesso
		# (rientro_infermeria): prima che si accenda non ci si arriva, e contarle
		# come strade del mattino vorrebbe dire vietare al pomeriggio di tornare
		# alla mappa. Si seguono quindi solo le regole il cui flag si puo'
		# accendere PRIMA del cancello, e si ricammina finche' quell'elenco
		# smette di crescere (un flag acceso piu' avanti puo' aprire la regola di
		# un nodo gia' passato)
		var accesi_prima: Array[String] = []
		var visti: Array[String] = []
		var quanti := -1
		while accesi_prima.size() != quanti:
			quanti = accesi_prima.size()
			visti = prima_del_cancello(dati, cancello, accesi_prima)
		for id_nodo in visti:
			var nodo: Dictionary = nodi[id_nodo]
			if String(nodo.get("flag", "")) == cancello:
				continue   # le sue scelte si leggono a cancello gia' acceso
			for scelta in nodo.get("scelte", []):
				esigi(not bool((scelta as Dictionary).get("torna_a_mappa", false)),
						"%s: da '%s' la scelta «%s» rimanda alla mappa, ma li' '%s' non e' ancora acceso"
						% [percorso.get_file(), id_nodo,
						String((scelta as Dictionary).get("testo", "")), cancello])
		esigi(visti.size() > 1,
				"%s: camminando dal nodo iniziale ho toccato %d nodi: il grafo non si sta percorrendo"
				% [percorso.get_file(), visti.size()])

	# 2b. DURANTE L'ALLENAMENTO NON SI ESCE. Bru: «non si deve ne' poter aprire
	#     la mappa ne' tornare indietro». Uscendo e rientrando i dialoghi
	#     ricominciavano da capo, come se non fossero mai stati.
	GameState.nuova_partita()
	GameState.avvia_carnivalz("introduzione", "res://data/events_intro.json")
	GameState.nodo_corrente = "sala_allenamento"
	esigi(not GameState.mappa_consultabile(),
			"in sala di allenamento la mappa si puo' ancora aprire: da li' si esce e i dialoghi ripartono")
	var palestra: Dictionary = carica_eventi("res://data/events_intro.json").get("nodi", {}).get("sala_allenamento", {})
	esigi(not palestra.is_empty(), "la sala di allenamento non esiste piu'")
	for scelta in palestra.get("scelte", []):
		var s := scelta as Dictionary
		esigi(not bool(s.get("torna_a_mappa", false)),
				"dalla sala di allenamento la scelta «%s» apre la mappa" % String(s.get("testo", "")))
		esigi(String(s.get("vai", "")) != "alloggio",
				"dalla sala di allenamento la scelta «%s» torna nell'alloggio: l'allenamento si puo' rimandare"
				% String(s.get("testo", "")))

	# 3. E CHI APRE LA MAPPA DEVE LASCIARTI DENTRO UNA STANZA.
	#
	# Difetto trovato mentre correggevo gli altri due, e c'era gia': la mappa
	# lascia andare solo nei posti che confinano con quello in cui sei, e "dove
	# sei" per lei e' nodo_corrente. Il risveglio in infermeria NON e' una stanza
	# della planimetria - la stanza si chiama "infermeria" - quindi uscendo di li'
	# la mappa si apriva con zero vicini: aperta, disegnata, e senza niente da
	# premere. Proprio nel punto in cui il complesso si apre al giocatore.
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		var mappa: Dictionary = dati.get("mappa_dungeon", {})
		if mappa.is_empty():
			continue
		var stanze: Array[String] = []
		for stanza in mappa.get("stanze", []):
			stanze.append(String((stanza as Dictionary).get("id", "")))
		var nodi: Dictionary = dati.get("nodi", {})
		for id_nodo in nodi:
			for scelta in (nodi[id_nodo] as Dictionary).get("scelte", []):
				var s := scelta as Dictionary
				if not bool(s.get("torna_a_mappa", false)):
					continue
				var dove := String(s.get("stanza", String(id_nodo)))
				esigi(dove in stanze,
						"%s: da '%s' la scelta «%s» apre la mappa lasciandoti in '%s', che non e' una stanza: la mappa non avrebbe niente da premere"
						% [percorso.get_file(), id_nodo, String(s.get("testo", "")), dove])

func prova_l_allenamento_non_si_pianta_al_primo_colpo() -> void:
	# Bru, provando: «dopo aver attaccato veronica ho sentito il rumore del testo
	# ma la schermata non mi ha fatto vedere alcun testo, e cosi' dopo il mio
	# primo attacco sono bloccato».
	#
	# La prova che c'era guardava i DATI del tutorial - i passi esistono, le
	# azioni sono note, l'aura basta a pagare l'abilita'. Nessuna faceva partire
	# lo scontro e poi TIRAVA IL PUGNO.
	#
	# E NON SI PUO' FARE IN MODALITA' MUTA, che e' il primo modo in cui ho
	# sbagliato questa prova: muto senza strategia fa passare i turni a vuoto
	# finche' non scatta il tetto di sicurezza, e lo scontro e' gia' finito
	# prima che tu possa colpire. Il tutorial vive sullo schermo, e solo li' si
	# puo' guardare.
	titolo("l'allenamento con Veronica avanza davvero quando colpisci")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["veronica"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	# il menu si accende quando tocca a te: e' il segnale che lo scontro e' vivo
	# SI ASPETTA A TEMPO VERO, non a fotogrammi: l'apertura dello scontro usa dei
	# timer, e in headless i fotogrammi scorrono molto piu' in fretta dei secondi
	var scadenza: int = Time.get_ticks_msec() + 20000
	while not scontro.menu_acceso and Time.get_ticks_msec() < scadenza:
		await get_tree().process_frame
	esigi(scontro.menu_acceso,
			"in venti secondi lo scontro non ha mai passato il comando al giocatore")

	# LA LEZIONE E' PARTITA? E' la domanda che non faceva nessuno, ed e' la
	# causa vera di «non c'e' stata alcuna spiegazione dell'interfaccia».
	#
	# Col motore in tempo reale il turno di chi comandi tu non passava dal giro
	# delle battute: te lo dava aggiorna_pronto_giocatore accendendo il menu.
	# L'introduzione del passo - le battute, e la preparazione di aura e
	# dominio - stava solo dentro battuta_di, quindi per il protagonista non
	# partiva MAI. A turni ci passa anche il tuo. I passi si
	# chiudevano lo stesso, perche' quello lo fa esegui_azione: il tutorial
	# sembrava funzionare e non aveva mai detto una parola.
	esigi(not scontro.tutorial_passi_introdotti.is_empty(),
			"il menu si e' acceso e il primo passo del tutorial non e' mai stato introdotto: nessuna spiegazione")
	esigi(not scontro.voce.coda.is_empty(),
			"il passo e' stato introdotto ma non ha lasciato niente da leggere")
	esigi(not scontro.il_tempo_scorre(),
			"la lezione parla e il mondo continua a girare: le battute scorrono via da sole")
	esigi(scontro.voce.attende_il_click,
			"le battute della lezione non aspettano il click: ventuno di fila passerebbero da sole")

	# IL QUADRANTE E' DI CHI PARLA, finche' c'e' da leggere.
	#
	# Bru: «dopo aver attaccato il dialogo non si vede, dovrebbe apparire nel
	# riquadro dove abbiamo attacco eccetera no? invece sento solo il rumore del
	# testo, non c'e' stata alcuna spiegazione dell'interfaccia».
	#
	# Non erano due difetti: era uno solo, e spiega tutti e due. Il menu si
	# prendeva il pannello ogni volta che "puoi agire", e durante una lezione
	# menu_acceso resta vero tutto il tempo - cosi' le ventuno battute di
	# Veronica scorrevano DIETRO al menu. Si sentiva il rumore del testo e non
	# si leggeva una riga.
	esigi(PlanciaCombattimento.faccia_da_mostrare(false, true, "comandi") == "parlato",
			"la regola: con qualcosa da leggere e nessun turno da giocare il quadrante non passa al box")
	# NON SI ASPETTA IL MOMENTO GIUSTO: lo si costruisce. Legare la misura a
	# "quando il tutorial parla" l'ha resa una corsa contro la coda che si
	# svuota, e una prova che a volte guarda e a volte no non e' una prova.
	# Qui si mette il testo in coda e si ferma il tempo a mano: e' esattamente
	# lo stato in cui il gioco si trovava, e il difetto sta tutto li'.
	scontro.voce.scrivi("Veronica sta spiegando qualcosa.")
	scontro.ferma_il_tempo()
	scontro.decidi_faccia()
	await get_tree().process_frame
	esigi(String(scontro.plancia.faccia_adesso) == "parlato",
			"col tempo fermo e del testo in coda il quadrante mostra '%s' invece del box: il testo scorre dietro al menu"
			% String(scontro.plancia.faccia_adesso))
	scontro.riprendi_il_tempo()
	scontro.voce.coda.clear()

	# e la lezione FERMA DAVVERO IL MONDO: senza, il quadrante resterebbe al
	# menu e le battute scorrerebbero dietro, che e' il difetto di partenza
	# il tempo e' fermo a incastro (ferma/riprendi si contano): la lezione vera
	# l'ha gia' fermato una volta, e per misurarne una finta va pareggiato prima
	if scontro.lezione_in_corso:
		scontro.lezione_in_corso = false
		scontro.voce.attende_il_click = false
		scontro.riprendi_il_tempo()
	esigi(scontro.il_tempo_scorre(), "il tempo non e' ripartito: la misura che segue non varrebbe niente")
	scontro.scrivi_messaggio_tutorial({"tipo": "narrazione", "testo": "Una spiegazione."})
	esigi(not scontro.il_tempo_scorre(),
			"il tutorial ha parlato e il mondo non si e' fermato: la lezione diventa un turno perso")
	esigi(scontro.lezione_in_corso, "la lezione non si e' segnata come in corso: non ripartira' mai")
	scontro.voce.coda.clear()
	for giro in 20:
		if scontro.il_tempo_scorre():
			break
		await get_tree().process_frame
	esigi(scontro.il_tempo_scorre(),
			"finita la lezione il mondo non e' ripartito: lo scontro resta fermo per sempre")
	esigi(not scontro.voce.attende_il_click,
			"finita la lezione le battute normali aspettano ancora il click: il combattimento si ferma a ogni frase")

	esigi(not scontro.tutorial.is_empty(),
			"lo scontro con Veronica non ha caricato nessun tutorial")
	var primo: Dictionary = scontro.passo_tutorial()
	esigi(String(primo.get("azione", "")) == "attacca",
			"il primo passo chiede '%s': questa prova tira un pugno"
			% String(primo.get("azione", "")))

	var nemici: Array[Dictionary] = scontro.vivi(false)
	esigi(not nemici.is_empty(), "Veronica non e' scesa in campo")
	var tu: Dictionary = scontro.combattente_comandato()
	esigi(not tu.is_empty() and scontro.puo_agire(tu),
			"il menu e' acceso ma il protagonista non puo' agire")
	# IL PUGNO, DALLA STESSA PORTA DA CUI PASSA IL GIOCATORE: agisci_ora e'
	# quello che chiama il click sulla creatura (vedi _su_click_nemico)
	scontro.agisci_ora({"tipo": "attacca", "bersaglio": nemici[0]})
	var scadenza_passo: int = Time.get_ticks_msec() + 20000
	while scontro.tutorial_passo == 0 and Time.get_ticks_msec() < scadenza_passo:
		await get_tree().process_frame
	esigi(scontro.tutorial_passo == 1,
			"tirato il pugno che il primo passo chiedeva, il tutorial e' ancora al passo %d: si pianta li'"
			% scontro.tutorial_passo)
	scontro.in_corso = false
	scontro.voce.coda.clear()
	scontro.queue_free()
	await get_tree().process_frame

func prova_un_solo_artwork_quello_di_chi_parla() -> void:
	# Bru: «nei dialoghi se ci sono piu' personaggi coinvolti, ci deve sempre
	# essere solo 1 artwork, che e' quello del personaggio che parla. Io invece
	# nel dialogo iniziale con veronica ho visto subito il box con la v».
	titolo("nel dialogo c'e' un artwork solo, e e' di chi sta parlando")
	GameState.nuova_partita()
	GameState.eventi["prova_palco"] = {
		"destra": "veronica",
		"sequenza": [
			{"tipo": "dialogo", "chi": "veronica", "testo": "Parlo io."},
			{"tipo": "narrazione", "testo": "Silenzio."},
			{"tipo": "dialogo", "chi": GameState.id_protagonista, "testo": "Adesso io."},
		],
		"scelte": [{"testo": "Fine", "vai": "prova_palco"}],
	}
	GameState.nodo_corrente = "prova_palco"
	IngressoNodo.ultimo_esito = {}
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame

	schermata.aggiorna_palco(GameState.eventi["prova_palco"])
	schermata.evidenzia_parlante("veronica")
	await get_tree().process_frame
	esigi(schermata.slot_destra.visible and not schermata.slot_sinistra.visible,
			"parla Veronica e in scena ci sono ancora tutti e due")

	# LA NARRAZIONE NON SVUOTA IL PALCO: fra due battute della stessa persona
	# c'e' quasi sempre una riga di racconto, e farla sparire e ricomparire
	# sarebbe un lampeggio
	schermata.evidenzia_parlante("")
	await get_tree().process_frame
	esigi(schermata.slot_destra.visible,
			"una riga di narrazione ha fatto sparire chi stava parlando")

	schermata.evidenzia_parlante(GameState.id_protagonista)
	await get_tree().process_frame
	esigi(schermata.slot_sinistra.visible and not schermata.slot_destra.visible,
			"passata la voce al protagonista, Veronica e' rimasta in scena")

	# e rifare il palco - lo fanno le scelte, a ogni giro - non li rimette tutti
	schermata.aggiorna_palco(GameState.eventi["prova_palco"])
	await get_tree().process_frame
	esigi(not schermata.slot_destra.visible,
			"ricostruendo il palco tornano in scena tutti: le scelte lo rifanno a ogni giro")
	schermata.queue_free()

func prova_la_raffica_del_tutorial_parte_davvero() -> void:
	# Bru: «quando ti dice preparati non procede oltre».
	#
	# Le battute "preparati!" si sentivano - quelle le scrive
	# introduci_passo_tutorial - ma il LANCIO della raffica stava solo dentro
	# battuta_di, che col motore in tempo reale per il giocatore non veniva mai
	# chiamata. Veronica annunciava i pugni, e i pugni non arrivavano mai.
	#
	# Il rimedio vero era rendere quel passaggio uno solo, ed e' quello che
	# hanno fatto i turni: adesso anche il tuo turno passa da battuta_di.
	titolo("la raffica del tutorial parte quando tocca a te")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["veronica"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	var limite: int = Time.get_ticks_msec() + 20000
	while not scontro.menu_acceso and Time.get_ticks_msec() < limite:
		await get_tree().process_frame
	esigi(scontro.menu_acceso, "lo scontro non ha mai passato il comando al giocatore")

	# ci si porta al passo della raffica come farebbe il gioco: e' l'ultimo
	var passi: Array = scontro.tutorial.get("passi", [])
	var quale := -1
	for i in passi.size():
		if String((passi[i] as Dictionary).get("azione", "")) == "minigioco":
			quale = i
	esigi(quale >= 0, "il tutorial non ha piu' nessun passo con la raffica")
	esigi(quale == passi.size() - 1,
			"la raffica sta al passo %d di %d: deve essere l'ultima prova prima del colpo finale"
			% [quale, passi.size()])
	scontro.tutorial_passo = quale
	scontro.tutorial_passi_introdotti.clear()
	scontro.voce.coda.clear()
	var tu: Dictionary = scontro.combattente_comandato()
	# IL TURNO DOPO E' TUO, e te lo porta il giro come in partita: si chiude
	# quello che hai in mano e ti si mette in cima alla fila. La raffica deve
	# partire da li', dalla porta da cui passa ogni turno
	scontro.turni.fine_turno()
	tu.battuta_aperta = false
	scontro.turni.da_muovere.assign([tu])
	# LA RAFFICA ASPETTA CHE IL BOX ABBIA FINITO DI PARLARE - "preparati!" deve
	# essere leggibile prima che i pugni ci vadano sopra - e da quando la lezione
	# aspetta il click, quel "finito" lo decide il giocatore. Qui si clicca al
	# posto suo, che e' la simulazione onesta: se invece si svuotasse la coda a
	# mano si proverebbe un percorso che nel gioco non esiste.
	var scadenza_pugni: int = Time.get_ticks_msec() + 20000
	while Time.get_ticks_msec() < scadenza_pugni:
		if scontro.minigioco.attivo or scontro.minigioco.suonate > 0:
			break
		scontro.voce.salta_messaggio = true
		await get_tree().process_frame
	esigi(scontro.minigioco.attivo or scontro.minigioco.suonate > 0,
			"annunciata la raffica, non e' partita nessuna raffica: e' il blocco su «preparati»")
	esigi(not scontro.menu_acceso,
			"il passo della raffica ha acceso il menu: non e' una mossa che scegli, e' una che subisci")
	scontro.in_corso = false
	scontro.voce.coda.clear()
	scontro.queue_free()
	await get_tree().process_frame

func prova_dopo_la_raffica_resti_in_piedi_e_il_finale_si_legge() -> void:
	# Bru: «dopo il minigioco, fa fatica a rimettersi in carreggiata, cliccando a
	# caso va avanti, ma finito il minigioco dovresti rimanere minimo con 1 di
	# vita, poi parte il dialogo del colpo finale di veronica che ti abbatte e si
	# conclude tutto».
	#
	# Giocandolo erano quattro difetti, e qui si guardano uno per uno:
	#   - dodici pugni presi facevano 108 su 100: KO, Veronica ti rialzava, e la
	#     raffica ripartiva da capo - un giro senza uscita;
	#   - a scontro chiuso il quadrante tornava ai comandi, e il finale scorreva
	#     DIETRO al menu: si cliccava un testo che non si vedeva;
	#   - la barra della vita andava a zero coi pugni, non con la Meteora;
	#   - nel box dello scontro «{addormentato|addormentata}» restava cosi'.
	titolo("dopo la raffica di Veronica resti in piedi, e il finale si legge")
	GameState.nuova_partita()
	GameState.sesso_protagonista = Testi.FEMMINILE
	GameState.nemici_combattimento = ["veronica"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	var limite: int = Time.get_ticks_msec() + 20000
	while not scontro.menu_acceso and Time.get_ticks_msec() < limite:
		await get_tree().process_frame
	var passi: Array = scontro.tutorial.get("passi", [])
	scontro.tutorial_passo = passi.size() - 1
	var passo: Dictionary = scontro.passo_tutorial()
	esigi(String(passo.get("azione", "")) == "minigioco", "l'ultimo passo non e' piu' la raffica")
	esigi(int(passo.get("vita_minima", 0)) >= 1,
			"la raffica dell'allenamento non dice quanta vita ti lascia: puo' mandarti KO e ripartire da capo")
	var eroe: Dictionary = scontro.combattente_comandato()
	eroe.hp = int(eroe.hp_max)
	scontro.voce.coda.clear()
	var rialzate: int = scontro.rivitalizzanti_usati
	# nessun pugno fermato: il caso di chi prova la raffica per la prima volta
	scontro.minigioco_bersaglio = eroe
	scontro._minigioco_finito({"totali": 12, "parati": 0, "piene": 0, "striscio": 0,
			"danno": int(eroe.hp_max) + 8, "perfetto": false})
	esigi(scontro.rivitalizzanti_usati == rialzate,
			"dopo la raffica Veronica ha dovuto rialzarti: i pugni ti hanno mandato KO")
	esigi(scontro.tutorial_finito,
			"finita la raffica l'allenamento non e' andato al colpo finale: il passo e' rimasto aperto")
	# cosa c'e' da leggere, nell'ordine in cui lo si legge
	var righe: Array[String] = []
	var dopo_meteora := ""
	var colpo_dei_pugni := Callable()
	var coda: Array = scontro.voce.coda
	for i in coda.size():
		var voce_coda: Dictionary = coda[i]
		var testo := String(voce_coda.testo)
		righe.append(testo)
		if testo == "" and not colpo_dei_pugni.is_valid():
			colpo_dei_pugni = voce_coda.get("effetto", Callable())
		if "Meteora" in testo and i + 1 < coda.size():
			dopo_meteora = "effetto" if String((coda[i + 1] as Dictionary).testo) == "" \
					else String((coda[i + 1] as Dictionary).testo)
	var tutto := " | ".join(righe)
	esigi(tutto.find("{") == -1,
			"nel box dello scontro resta un accordo non risolto: %s" % tutto.left(200))
	esigi("Sei stata messa KO" in tutto,
			"il finale non si accorda al femminile: %s" % tutto.left(200))
	esigi(dopo_meteora == "effetto",
			"il ritratto non si spegne sulla Meteora di Atlante: dopo c'e' «%s»" % dopo_meteora)
	esigi(not "Il disallineamento ha vinto" in tutto and not "è a terra" in tutto,
			"l'allenamento finisce con le righe di una partita persa, dopo il suo finale")
	# la barra dei pugni dice la vita dei pugni, anche se la Meteora l'ha gia'
	# tolta tutta
	esigi(int(eroe.hp) == 0, "il colpo finale non ti ha messo a terra")
	if colpo_dei_pugni.is_valid():
		colpo_dei_pugni.call()
		var scritta := String(eroe.etichetta_vita.text) if eroe.get("etichetta_vita") != null else ""
		esigi(scritta.contains("1/"),
				"subito dopo i pugni la scheda dice «%s»: doveva dire 1 punto di vita" % scritta)
	else:
		esigi(false, "i pugni presi non mostrano nessun colpo")
	# e il finale si legge nel box, non dietro al menu
	esigi(not scontro.in_corso, "lo scontro non si e' chiuso")
	scontro.decidi_faccia()
	esigi(String(scontro.plancia.faccia_adesso) == "parlato",
			"a scontro chiuso con il finale ancora da leggere il quadrante mostra '%s': il testo scorre dietro al menu"
			% String(scontro.plancia.faccia_adesso))
	scontro.voce.coda.clear()
	scontro.queue_free()
	GameState.sesso_protagonista = Testi.MASCHILE
	await get_tree().process_frame

func prova_la_raffica_accelera_verso_la_fine() -> void:
	# Bru: «la velocita' aumenta verso la fine, 12 pugni su cui cliccare».
	titolo("i pugni della raffica si stringono andando avanti")
	var dado := RandomNumberGenerator.new()
	dado.seed = 7
	var raffica := Collisioni.calendario(12, 0.46, 0.5, dado, 1.0, 0.22)
	esigi(raffica.size() == 12, "la raffica ha %d pugni invece di 12" % raffica.size())
	# si misurano i distacchi fra i primi tre e fra gli ultimi tre: lo
	# sbandamento casuale sposta il singolo pugno, non la tendenza
	var primi := float(raffica[2]["istante"]) - float(raffica[0]["istante"])
	var ultimi := float(raffica[11]["istante"]) - float(raffica[9]["istante"])
	esigi(ultimi < primi * 0.75,
			"gli ultimi pugni distano %.2fs e i primi %.2fs: la raffica non accelera" % [ultimi, primi])
	# e senza il parametro resta com'era: gli scontri veri non devono cambiare
	dado.seed = 7
	var piatta := Collisioni.calendario(12, 0.46, 0.5, dado, 1.0)
	var p_primi := float(piatta[2]["istante"]) - float(piatta[0]["istante"])
	var p_ultimi := float(piatta[11]["istante"]) - float(piatta[9]["istante"])
	esigi(absf(p_ultimi - p_primi) < p_primi * 0.5,
			"senza intervallo_finale la raffica accelera lo stesso: cambierebbe tutti gli scontri")

	# I TEMPI DELLA RAFFICA DEL TUTORIAL SONO QUELLI DI BRU, scritti nei dati e
	# controllati qui, cosi' non possono cambiare di nascosto quando qualcuno
	# ritocca un numero: «ogni pugno deve rimanere visibile per 2 secondi, e ne
	# deve apparire un altro ogni secondo».
	var passo_raffica: Dictionary = {}
	for creatura in GameState.personaggi.values():
		for passo in (creatura as Dictionary).get("tutorial_combattimento", {}).get("passi", []):
			if String((passo as Dictionary).get("azione", "")) == "minigioco":
				passo_raffica = (passo as Dictionary).get("minigioco", {})
	esigi(not passo_raffica.is_empty(), "il tutorial non ha piu' nessuna raffica")
	esigi(absf(float(passo_raffica.get("durata", 0.0)) - 2.0) < 0.001,
			"nel tutorial un pugno si vede per %.2fs: Bru ha chiesto 2"
			% float(passo_raffica.get("durata", 0.0)))
	esigi(absf(float(passo_raffica.get("intervallo", 0.0)) - 1.0) < 0.001,
			"nel tutorial i pugni arrivano ogni %.2fs: Bru ha chiesto uno al secondo"
			% float(passo_raffica.get("intervallo", 0.0)))
	esigi(not passo_raffica.has("intervallo_finale"),
			"la raffica del tutorial accelera: Bru ha chiesto uno al secondo, sempre")
	# e la finestra piena non e' una lotteria: con la mano che deve anche
	# arrivarci, meno di un quarto di secondo e' fortuna
	var finestra := float(passo_raffica.get("finestra_prima", Collisioni.FINESTRA_PRIMA)) \
			+ float(passo_raffica.get("finestra_dopo", Collisioni.FINESTRA_DOPO))
	esigi(finestra >= 0.25,
			"la parata piena dura %.2fs: sotto i 0.25s non e' tempismo, e' una lotteria" % finestra)

func prova_l_evidenziazione_indica_un_pezzo_vero() -> void:
	# Bru: «bisogna rendere piu' accattivante la segnalazione degli elementi
	# dell'interfaccia evidenziandoli con animazioni».
	#
	# Il rischio di questa cosa non e' che non funzioni: e' che un nome scritto
	# male nei dati non evidenzi NIENTE, e che un'evidenziazione che non si vede
	# sia indistinguibile da una che non e' stata chiesta. Chi scrive i dialoghi
	# non ha modo di accorgersene se non guardando lo schermo.
	titolo("ogni «evidenzia» dei dialoghi indica un pezzo che esiste davvero")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["veronica"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	var limite: int = Time.get_ticks_msec() + 20000
	while scontro.plancia == null and Time.get_ticks_msec() < limite:
		await get_tree().process_frame
	esigi(scontro.plancia != null, "la plancia non e' mai nata")

	# 1. tutti i nomi usati nei dati sono pezzi veri
	var usati: Array[String] = []
	for creatura in GameState.personaggi.values():
		for passo in (creatura as Dictionary).get("tutorial_combattimento", {}).get("passi", []):
			for dove in ["prima", "dopo"]:
				for msg in (passo as Dictionary).get(dove, []):
					var nome := String((msg as Dictionary).get("evidenzia", ""))
					if nome != "" and nome not in usati:
						usati.append(nome)
	esigi(usati.size() >= 5,
			"i dialoghi del tutorial indicano solo %d pezzi dello schermo: quasi niente si evidenzia" % usati.size())
	for nome in usati:
		esigi(scontro.plancia.pezzo(nome) != null,
			"un dialogo chiede di evidenziare '%s', che non e' un pezzo dello schermo: non si vedrebbe niente" % nome)

	# 2. e accenderlo accende DAVVERO qualcosa, uno alla volta
	scontro.plancia.evidenzia_pezzo("ecg")
	esigi(scontro.plancia.evidenziato == scontro.plancia.fondale_ecg,
			"chiesto di evidenziare l'ECG, non si e' acceso l'ECG")
	scontro.plancia.evidenzia_pezzo("mattanza")
	esigi(scontro.plancia.evidenziato == scontro.plancia.tasto_mattanza,
			"passando a MATTANZA l'evidenza non si e' spostata")
	esigi(scontro.plancia.fondale_ecg.modulate == Color.WHITE,
			"l'ECG e' rimasto acceso mentre pulsa un altro pezzo: due cose che lampeggiano non indicano niente")
	# 3. L'ALONE STA INTORNO, NON SOPRA.
	#
	# Prima l'evidenza era un tween su modulate: il pezzo indicato diventava
	# rosso e tornava bianco. modulate MOLTIPLICA, quindi il testo bianco
	# diventava rosso, il riquadro si scuriva e la traccia verde dell'ECG si
	# sporcava - il pezzo che stiamo indicando si leggeva PEGGIO proprio mentre
	# lo indicavamo. Adesso la luce e' un nodo suo, dietro.
	esigi(scontro.plancia.tasto_mattanza.modulate == Color.WHITE,
			"il pezzo evidenziato e' stato tinto: modulate vale %s invece di bianco"
			% scontro.plancia.tasto_mattanza.modulate)
	var alone: Bagliore = scontro.plancia.alone_evidenza
	esigi(alone != null, "non c'e' nessun alone intorno al pezzo evidenziato")
	esigi(alone.get_parent() == scontro.plancia.tasto_mattanza,
			"l'alone non e' attaccato al pezzo: non lo seguirebbe se si sposta")
	esigi(alone.show_behind_parent,
			"l'alone si disegna SOPRA il pezzo: lo coprirebbe invece di illuminarlo")
	esigi(alone.mouse_filter == Control.MOUSE_FILTER_IGNORE,
			"l'alone intercetta il mouse: si mangerebbe i click sul pezzo che indica")

	# 4. LA LUCE SFUMA A ZERO, e non finisce con un gradino.
	#
	# La campana va troncata all'orlo: senza, l'ultima passata arriva al bordo
	# con un nove per cento di rosso ancora addosso e si vede un anello netto
	# tutto intorno - che si legge come un bordo colorato, non come luce.
	esigi(is_zero_approx(alone.forza_a(1.0)),
			"all'orlo l'alone vale ancora %.3f: si vedrebbe l'anello dell'ultima passata"
			% alone.forza_a(1.0))
	var prima_forza := 2.0
	for passo in 20:
		var quanto := float(passo) / 19.0
		var adesso := alone.forza_a(quanto)
		esigi(adesso <= prima_forza + 0.0001,
				"l'alone risale andando in fuori: a %.2f vale %.3f dopo %.3f"
				% [quanto, adesso, prima_forza])
		prima_forza = adesso
	esigi(alone.forza_a(0.0) > 0.25,
			"contro il bordo del pezzo l'alone vale %.3f: non si vedrebbe" % alone.forza_a(0.0))

	# 5. IL RESPIRO NON SI SPEGNE MAI DEL TUTTO. Un invito che sparisce e torna
	# e' un lampeggio, e un lampeggio a schermo per minuti da' fastidio.
	esigi(Bagliore.MINIMO > 0.2,
			"il respiro scende a %.2f: il pezzo si spegne e l'invito lampeggia" % Bagliore.MINIMO)
	esigi(Bagliore.RESPIRO >= 0.8,
			"mezzo respiro dura %.2fs: era 0,45 e Bru l'ha trovato troppo rapido"
			% Bagliore.RESPIRO)

	scontro.plancia.spegni_evidenza()
	esigi(scontro.plancia.evidenziato == null and scontro.plancia.tasto_mattanza.modulate == Color.WHITE,
			"spenta l'evidenza, qualcosa continua a pulsare")
	esigi(scontro.plancia.alone_evidenza == null,
			"spenta l'evidenza, l'alone e' ancora li'")
	scontro.in_corso = false
	scontro.voce.coda.clear()
	scontro.queue_free()
	await get_tree().process_frame

func prova_una_fase_alla_volta_e_niente_click_a_vuoto() -> void:
	# L'INVARIANTE CHE RENDE IMPOSSIBILE IL CLICK A VUOTO.
	#
	# Bru, provando: «quando dovevo premere su difesa ci ho cliccato e il primo
	# click e' andato a vuoto il secondo no, e' come se fosse lento a
	# ripristinare l'interfaccia interagibile». Misurato: per il 76% del
	# tutorial il giocatore risultava "pronto" e il pannello dei comandi non era
	# a schermo. Non era lentezza: erano cinque booleani - menu_acceso,
	# tempo_fermo, lezione_in_corso, minigioco.attivo, coda vuota - che
	# potevano dire cose diverse insieme.
	#
	# Adesso la fase e' UNA, e non si tiene in una variabile: si chiede ai
	# fatti. Questa prova fissa il patto in due righe:
	#   fase "comandi"  -> il quadrante mostra il menu, sempre
	#   fase "racconto" -> il mondo non avanza, sempre
	titolo("una fase alla volta, e il pannello e' sempre quello della fase")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	scontro.in_corso = true

	# 1. c'e' da leggere -> si legge, e il mondo aspetta
	scontro.menu_acceso = true          # "pronto" puo' anche essere vero: non conta piu'
	scontro.voce.coda.append({"tipo": "narrazione", "chi": "", "testo": "Qualcuno parla.",
			"forte": false, "effetto": Callable()})
	esigi(String(scontro.fase_adesso()) == "racconto",
			"c'e' una battuta in coda e la fase e' '%s'" % String(scontro.fase_adesso()))
	esigi(scontro.il_mondo_aspetta_che_si_legga(),
			"si sta raccontando e il mondo continua ad avanzare: le ricariche corrono sotto il testo")
	scontro.decidi_faccia()
	esigi(String(scontro.plancia.faccia_adesso) == "parlato",
			"fase racconto e quadrante su '%s'" % String(scontro.plancia.faccia_adesso))

	# 2. finito di leggere -> torna il menu, e il mondo riparte
	#
	# QUI SCRIVEVO UNA BUGIA. Svuotavo la coda e spegnevo sta_facendo_leggere a
	# mano, come se fossero due cose indipendenti. Non lo sono: la bandiera la
	# accende e la spegne chi svuota, e fingere di poterla mettere a posto da
	# fuori voleva dire provare un mondo che non esiste. Adesso si aspetta che
	# lo svuotamento sia finito per davvero, che e' quello che fa il gioco.
	scontro.voce.coda.clear()
	var scadenza := Time.get_ticks_msec() + 3000
	while (scontro.voce.sta_svuotando or scontro.voce.sta_facendo_leggere) \
			and Time.get_ticks_msec() < scadenza:
		await get_tree().process_frame
	esigi(not scontro.voce.sta_facendo_leggere,
			"lo svuotamento non si e' chiuso entro tre secondi: la fase resterebbe 'racconto' per sempre")
	esigi(String(scontro.fase_adesso()) == "comandi",
			"non c'e' piu' niente da leggere e la fase e' '%s'" % String(scontro.fase_adesso()))
	esigi(not scontro.il_mondo_aspetta_che_si_legga(),
			"finito il racconto il mondo continua ad aspettare: lo scontro si pianta")
	scontro.decidi_faccia()
	esigi(String(scontro.plancia.faccia_adesso) == "comandi",
			"fase comandi e quadrante su '%s': ecco il click che va a vuoto"
			% String(scontro.plancia.faccia_adesso))

	# 3. E LA FASE NON SI TIENE IN UNA VARIABILE. Se fosse salvata potrebbe
	#    restare indietro rispetto ai fatti, ed e' esattamente cosi' che questa
	#    roba si rompe: il pannello dice una cosa e il motore un'altra
	esigi(not ("var fase" in testo_script("res://scripts/Combattimento.gd")),
			"la fase e' finita in una variabile: una fase salvata puo' restare indietro rispetto ai fatti")
	scontro.in_corso = false
	scontro.voce.coda.clear()
	scontro.queue_free()
	await get_tree().process_frame

func prova_tenere_premuto_non_e_martellare() -> void:
	# LA MATTANZA SI PESTA, NON SI TIENE PREMUTO. Se la ripetizione automatica
	# della tastiera contasse come colpi, la finestra la vincerebbe il sistema
	# operativo invece del giocatore.
	#
	# PERCHE' QUESTA PROVA ESISTE. Nel codice c'era un `and not evento.is_echo()`
	# esplicito. La documentazione di InputEvent dice che non serve -
	# `is_action_pressed(azione, allow_echo)` ha gia' allow_echo a false - e
	# togliendolo il comportamento resta giusto. Ma resta giusto **per via di un
	# valore predefinito dell'API**, che nel codice non si vede piu': esattamente
	# il tipo di dipendenza invisibile che un giorno si rompe in silenzio.
	#
	# E non mi sono fidata del PDF: questo lo chiede al motore.
	titolo("tenere premuto lo spazio non vale come martellare")
	var normale := InputEventKey.new()
	normale.keycode = KEY_ENTER
	normale.physical_keycode = KEY_ENTER
	normale.pressed = true
	normale.echo = false
	esigi(normale.is_action_pressed("ui_accept"),
			"una pressione vera non conta come azione: la Mattanza non partirebbe mai")

	var eco := InputEventKey.new()
	eco.keycode = KEY_ENTER
	eco.physical_keycode = KEY_ENTER
	eco.pressed = true
	eco.echo = true
	esigi(eco.is_echo(), "l'evento costruito per la prova non risulta un'eco")
	esigi(not eco.is_action_pressed("ui_accept"),
			"la ripetizione automatica conta come colpo: chi tiene premuto vince la Mattanza senza giocarla")
	esigi(eco.is_action_pressed("ui_accept", true),
			"con allow_echo l'eco non passa: allora non e' quel parametro a filtrarla, e il codice si regge su altro")

func prova_il_click_dato_presto_non_si_perde() -> void:
	# IL PRIMO CLICK SU DIFESA. Bru: «la prima volta che clicco su difesa non fa
	# niente». Era vero: agisci_ora usciva in silenzio se la ricarica non era
	# finita, e il comando spariva senza lasciare traccia.
	#
	# QUESTA PROVA MISURA LA COSA GIUSTA, e vale la pena dire come faccio a
	# saperlo: la prima versione guardava solo che intenzione.azione si
	# riempisse. Sarebbe passata anche con un buffer che non fa MAI partire
	# niente - cioe' con il difetto intatto, piu' una variabile. Quello che
	# conta e' che l'azione ESCA: qui si guardano gli scatti di guardia, che li
	# alza soltanto difendi() - cioe' chi esegue davvero la mossa.
	titolo("un comando dato prima del tempo aspetta, poi parte da solo")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	# NIENTE MODO MUTO QUI. Mutato, lo scontro passa i turni da solo, e
	# senza una strategia macina quattromila battute e chiude da solo prima che
	# la prova possa cliccare qualcosa. Serve lo scontro vero, fermo.
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	scontro.in_corso = true

	var tu: Dictionary = scontro.combattente_comandato()
	esigi(not tu.is_empty(), "nessuno comandato: la prova non puo' partire")
	# NON E' IL TUO TURNO: e' esattamente il momento in cui il click moriva
	togli_il_turno(scontro)
	esigi(not scontro.giocatore_pronto(),
			"fuori dal suo turno il giocatore risulta gia' pronto: la prova non proverebbe niente")
	var guardia_prima: int = RegoleCombattimento.scatti_difesa(tu)
	scontro.agisci_ora({"tipo": "difendi"})
	esigi(RegoleCombattimento.scatti_difesa(tu) == guardia_prima,
			"la difesa e' partita fuori dal tuo turno: il turno non vale piu' niente")
	esigi(scontro.nome_azione_in_coda() == "Difesa",
			"il click dato presto non e' stato tenuto da parte: in coda c'e' '%s'"
			% scontro.nome_azione_in_coda())

	# VINCE L'ULTIMO. Ellison: «limitare la dimensione della coda e dare
	# priorita' agli input piu' recenti». Se clicchi difesa e poi fuga, volevi
	# fuga - non tutte e due
	scontro.agisci_ora({"tipo": "fuggi"})
	esigi(scontro.nome_azione_in_coda() == "Fuga",
			"il secondo click non ha sostituito il primo: in coda c'e' '%s'"
			% scontro.nome_azione_in_coda())
	scontro.agisci_ora({"tipo": "difendi"})

	# MA NON MENTRE C'E' DA LEGGERE. Bru: «mentre ci sono i dialoghi tutto si
	# incentra nella lettura, non serve che altro vada avanti». Un comando in
	# attesa non fa eccezione: aspetta come tutto il resto
	dai_il_turno(scontro, tu)
	scontro.voce.coda.append({"tipo": "narrazione", "chi": "", "testo": "Qualcuno parla.",
			"forte": false, "effetto": Callable()})
	scontro.aggiorna_pronto_giocatore()
	esigi(RegoleCombattimento.scatti_difesa(tu) == guardia_prima,
			"il comando in attesa e' partito mentre c'era ancora da leggere")
	esigi(scontro.nome_azione_in_coda() == "Difesa",
			"il comando si e' perso durante la battuta invece di aspettarla")

	# finito di leggere, tocca a te: l'intenzione parte da sola, senza altri click
	scontro.voce.coda.clear()
	scontro.voce.sta_facendo_leggere = false
	scontro.aggiorna_pronto_giocatore()
	esigi(RegoleCombattimento.scatti_difesa(tu) > guardia_prima,
			"arrivato il tuo turno il comando in attesa non e' partito: la guardia e' ferma a %d"
			% RegoleCombattimento.scatti_difesa(tu))
	esigi(scontro.nome_azione_in_coda() == "",
			"il comando e' partito ma e' rimasto anche in coda: partirebbe due volte")

	# E UN ATTACCO TENUTO DA PARTE COLPISCE LA CREATURA VERA. La difesa qui
	# sopra non ha bersaglio, e per questo la prova non vedeva che il comando
	# si copiava in profondita' - creatura compresa: l'attacco partiva contro
	# un doppione, e il goblin in campo non perdeva un punto
	var goblin: Dictionary = {}
	for c: Dictionary in scontro.combattenti:
		if not bool(c.get("giocatore", false)):
			goblin = c
	var vita_prima := int(goblin.get("hp", 0))
	togli_il_turno(scontro)
	scontro.agisci_ora({"tipo": "attacca", "bersaglio": goblin})
	esigi(int(goblin.hp) == vita_prima, "l'attacco e' partito prima del tuo turno")
	dai_il_turno(scontro, tu)
	scontro.voce.coda.clear()
	scontro.voce.sta_facendo_leggere = false
	scontro.aggiorna_pronto_giocatore()
	esigi(int(goblin.hp) < vita_prima,
			"l'attacco dato prima del tuo turno e' partito, ma il goblin in campo e' ancora a %d su %d: ha colpito una copia"
			% [int(goblin.hp), vita_prima])

	# DURANTE LA LEZIONE NO. Veronica chiede una cosa per volta: un comando
	# tenuto da parte partirebbe da solo appena lei finisce di parlare, e il
	# giocatore vedrebbe succedere una cosa che non ha appena chiesto.
	#
	# IL PASSO SI METTE A MANO, e non e' una scorciatoia: la prima versione
	# scriveva `if not passo_tutorial().is_empty():` e si fidava. In questo
	# scontro - un goblin, non l'allenamento - il tutorial e' vuoto, quindi
	# quel ramo non entrava MAI e la verifica dentro non veniva mai fatta.
	# Rompendo apposta la regola la suite restava verde: una prova che salta se
	# stessa in silenzio e' peggio di una prova che manca, perche' si conta.
	# DURANTE LA LEZIONE, SOLO QUELLO CHE VERONICA CHIEDE - ma QUELLO si'.
	#
	# All'inizio qui avevo scritto la regola larga: durante un passo del
	# tutorial non si tiene da parte niente. Sembrava prudente. L'ha bocciata
	# lo strumento di misura (prove/misura.sh): Veronica chiede ATTACCA, il
	# giocatore preme ATTACCA un attimo prima che la ricarica finisca, e non
	# succedeva niente - lo stesso difetto che Bru aveva segnalato, sopravvissuto
	# proprio dentro la lezione, cioe' dove il giocatore sta imparando se i suoi
	# comandi contano. Misurato: 0 click su 8 andavano a segno; adesso 8 su 8.
	scontro.tutorial = {"passi": [{"azione": "attacca"}]}
	scontro.tutorial_passo = 0
	scontro.tutorial_finito = false
	# IL PASSO VA ANCHE ANNUNCIATO, non solo acceso: finche' Veronica non ha
	# parlato il menu non offre niente e il buffer non tiene niente - e' la
	# regola che impedisce di anticipare la lezione (passo_gia_spiegato)
	scontro.tutorial_passi_introdotti.clear()
	scontro.tutorial_passi_introdotti.append(0)
	esigi(not scontro.passo_tutorial().is_empty(),
			"il passo di lezione non si e' acceso: le verifiche qui sotto non proverebbero niente")
	esigi(scontro.passo_gia_spiegato(),
			"il passo risulta non ancora spiegato: le verifiche qui sotto non proverebbero niente")

	# quello che NON viene chiesto resta fuori: la lezione e' una cosa per volta
	togli_il_turno(scontro)
	scontro.agisci_ora({"tipo": "difendi"})
	esigi(scontro.nome_azione_in_coda() == "",
			"durante la lezione e' finito in coda un comando che il passo non chiede")

	# quello che VIENE chiesto si tiene, anche se dato presto
	scontro.agisci_ora({"tipo": "attacca", "bersaglio": scontro.vivi(false)[0]})
	esigi(scontro.nome_azione_in_coda() == "Attacco",
			"premere l'azione che la lezione chiede, un attimo troppo presto, non lascia traccia: in coda c'e' '%s'"
			% scontro.nome_azione_in_coda())

	# e se il passo cambia, quello che aspettava non vale piu'
	scontro.tutorial = {"passi": [{"azione": "difendi"}]}
	scontro.tutorial_passi_introdotti.clear()
	scontro.tutorial_passi_introdotti.append(0)
	scontro.aggiorna_pronto_giocatore()
	esigi(scontro.nome_azione_in_coda() == "",
			"cambiato il passo, in coda resta un'azione che adesso non e' piu' quella chiesta")
	scontro.tutorial = {}

	scontro.in_corso = false
	scontro.voce.coda.clear()
	scontro.queue_free()
	await get_tree().process_frame

func prova_la_rete_dei_dati_non_ha_buchi() -> void:
	# CHI CONTROLLA I CONTROLLI.
	#
	# Le prove sui dati leggono i file che ci sono e dicono "va tutto bene".
	# Ma Bru scrivera' file nuovi, e la domanda vera e' un'altra: se sbaglia,
	# QUESTE prove se ne accorgono? Una rete che non e' mai stata provata con un
	# sasso e' un disegno di una rete.
	#
	# Qui si danno ai raccoglitori dei dati sbagliati apposta - un flag che
	# nessuno accende, un oggetto che nessuno lascia cadere - e si guarda che li
	# vedano. Non tocca nessun file: e' lo stesso codice, su dati finti.
	titolo("i controlli sui dati vedono davvero un dato sbagliato")

	# 1. UN FLAG CHIESTO E MAI ACCESO. E' la porta che non si apre mai.
	var accese: Dictionary = {}
	var richieste: Dictionary = {}
	var dichiarate: Dictionary = {}
	var finto_buono := {"nodi": {
		"uno": {"flag": "porta_aperta"},
		"due": {"scelte": [{"testo": "entra", "richiede_flag": "porta_aperta"}]},
	}}
	raccogli_bandierine(finto_buono, "finto", accese, richieste, dichiarate)
	esigi(accese.has("porta_aperta"), "un flag acceso da un nodo non viene visto come acceso")
	esigi(richieste.has("porta_aperta"), "un flag richiesto da una scelta non viene visto come richiesto")

	accese = {}
	richieste = {}
	dichiarate = {}
	var finto_rotto := {"nodi": {
		"due": {"scelte": [{"testo": "entra", "richiede_flag": "porta_che_nessuno_apre"}]},
	}}
	raccogli_bandierine(finto_rotto, "finto", accese, richieste, dichiarate)
	esigi(richieste.has("porta_che_nessuno_apre"),
			"un flag richiesto non viene nemmeno notato: la prova delle porte chiuse guarda nel vuoto")
	esigi(not accese.has("porta_che_nessuno_apre"),
			"un flag che nessuno accende risulta acceso: la prova direbbe che va tutto bene")

	# 2. UN OGGETTO CHIESTO E MAI TROVATO. E' la Fontana che non si completa.
	var si_trova: Dictionary = {}
	var richiesto: Dictionary = {}
	raccogli_oggetti({"nodi": {
		"tre": {"scelte": [{"testo": "apri", "richiede_oggetti": ["chiave_fantasma"]}]},
	}}, "finto", si_trova, richiesto)
	esigi(richiesto.has("chiave_fantasma"),
			"un oggetto richiesto da una scelta non viene notato")
	esigi(not si_trova.has("chiave_fantasma"),
			"un oggetto che non si trova da nessuna parte risulta trovabile")

	# 3. UNA DESTINAZIONE CHE NON ESISTE. E' il vicolo cieco.
	var uscite := destinazioni_di({"scelte": [{"testo": "vai", "vai": "nodo_inventato"}]})
	esigi("nodo_inventato" in uscite,
			"una destinazione dentro una scelta non viene nemmeno letta: %s" % [uscite])
	var uscite_flag := destinazioni_di({"vai_se_flag": [{"flag": "x", "vai": "altro_inventato"}]})
	esigi("altro_inventato" in uscite_flag,
			"una destinazione dentro un vai_se_flag a lista non viene letta: %s" % [uscite_flag])

	# 4. UN GRUPPO DI NEMICI MISTO. E' quello che Bru non vuole piu'.
	var gruppi := gruppi_di_nemici({"nodi": {"quattro": {
		"combattimento_automatico": {"nemici": ["goblin_tipico", "slime_infimo"]}}}})
	esigi(gruppi.size() == 1 and gruppi[0].size() == 2,
			"un gruppo di nemici dentro un combattimento automatico non viene raccolto: %s" % [gruppi])

func prova_orologio_delle_scelte() -> void:
	# «quelle eroe e villain sono a tempo, manchi timing non recuperi» (Bru).
	#
	# L'orologio e' fatto apposta per essere provato da solo: non sa cosa sia la
	# scelta a cui e' appeso, conta e dice quando e' finita. Quindi qui si conta.
	titolo("l'orologio di una scelta a tempo")
	# UNA LISTA E NON UN CONTATORE, e non e' pignoleria: in GDScript una lambda
	# cattura le variabili locali PER VALORE, quindi "quante += 1" dentro il
	# richiamo aumenta una copia e il conto qui fuori resta a zero. Un Array e'
	# un riferimento, e append() arriva davvero.
	var scadenze: Array[String] = []
	var orologio: Control = load("res://scripts/Orologio.gd").new()
	add_child(orologio)
	orologio.scaduto.connect(func() -> void: scadenze.append("scaduto"))

	# 1. SCADE UNA VOLTA SOLA, e poi smette di contare. Un orologio che continua
	#    a emettere dopo la scadenza romperebbe la stessa scelta due volte.
	orologio.avvia(1.0, 0.0)
	esigi(orologio.acceso, "l'orologio non e' partito")
	for passo in 30:
		orologio._process(0.1)
	esigi(scadenze.size() == 1, "l'orologio e' scaduto %d volte" % scadenze.size())
	esigi(not orologio.acceso, "dopo la scadenza l'orologio e' ancora acceso")
	esigi(is_equal_approx(orologio.quota_rimasta(), 0.0),
			"scaduto, la lancetta segna ancora %.2f" % orologio.quota_rimasta())

	# 2. FERMARLO PRIMA VUOL DIRE CHE NON SCADE. E' quello che succede quando
	#    scegli: la strada che hai preso non deve anche frantumarsi.
	scadenze.clear()
	orologio.avvia(1.0, 0.0)
	for passo in 5:
		orologio._process(0.1)
	orologio.ferma()
	for passo in 30:
		orologio._process(0.1)
	esigi(scadenze.is_empty(),
			"un orologio fermato e' scaduto lo stesso %d volte" % scadenze.size())

	# 3. LA LANCETTA DICE IL TEMPO CHE RESTA, e scende sempre
	orologio.avvia(2.0, 0.0)
	var prima: float = orologio.quota_rimasta()
	esigi(is_equal_approx(prima, 1.0), "appena partito segna %.2f invece di pieno" % prima)
	for passo in 10:
		orologio._process(0.1)
		var adesso: float = orologio.quota_rimasta()
		esigi(adesso <= prima, "la lancetta e' RISALITA da %.2f a %.2f" % [prima, adesso])
		prima = adesso
	esigi(prima < 1.0, "dopo un secondo la lancetta segna ancora pieno")
	orologio.ferma()

	# 4. DUE OROLOGI INSIEME NON SI DISTURBANO. Nel disegno di Bru l'opzione da
	#    eroe e quella da villain hanno ognuna la sua cipolla, partite in momenti
	#    diversi e con durate diverse: deve scadere prima quella corta.
	var ordine: Array[String] = []
	var corto: Control = load("res://scripts/Orologio.gd").new()
	var lungo: Control = load("res://scripts/Orologio.gd").new()
	add_child(corto)
	add_child(lungo)
	corto.scaduto.connect(func() -> void: ordine.append("corto"))
	lungo.scaduto.connect(func() -> void: ordine.append("lungo"))
	corto.avvia(1.0, -8.0)
	lungo.avvia(3.0, 8.0)
	for passo in 60:
		corto._process(0.1)
		lungo._process(0.1)
	esigi(ordine == ["corto", "lungo"],
			"i due orologi sono scaduti in quest'ordine: %s" % [ordine])

	# 5. SI FERMANO CON LA PAUSA. Senza, aprire l'inventario per controllare se
	#    hai l'oggetto giusto ti farebbe perdere la scelta mentre guardi.
	orologio.avvia(5.0, 0.0)
	esigi(orologio.can_process(), "l'orologio non conta nemmeno a gioco acceso")
	get_tree().paused = true
	esigi(not orologio.can_process(),
			"con la pausa aperta l'orologio continua a contare: si perde la scelta mentre si guarda l'inventario")
	get_tree().paused = false
	orologio.ferma()
	orologio.queue_free()
	corto.queue_free()
	lungo.queue_free()
	await prova_orologio_disegnato_per_intero()

func prova_orologio_disegnato_per_intero() -> void:
	# E DEV'ESSERE DISEGNATO PER DAVVERO, da pieno a zero.
	#
	# Qui non c'e' un esigi(): l'assertore e' esegui.sh, che boccia la suite se
	# Godot stampa un ERROR. E ne stampava: la "fetta gia' persa" dell'orologio,
	# appena parte, e' larga quasi zero e i suoi tre punti sono quasi allineati.
	# Non e' un triangolo, e Godot lo diceva - "triangulation failed" - a ogni
	# fotogramma finche' la lancetta non si era mossa abbastanza. Con una scelta
	# a tempo a schermo la console si riempiva, e un errore vero sarebbe finito
	# in mezzo a quelli.
	titolo("l'orologio si disegna da pieno a zero senza lamentarsi")
	var visibile: Control = load("res://scripts/Orologio.gd").new()
	visibile.custom_minimum_size = Vector2(74, 74)
	visibile.size = Vector2(74, 74)
	add_child(visibile)
	visibile.avvia(0.2, -8.0)
	# fotogrammi VERI, non _process chiamati a mano: e' il disegno che
	# interessa. Headless gira piu' veloce del tempo reale, quindi il tetto e'
	# largo: quello che conta e' che l'orologio percorra tutto l'arco.
	var passati := 0
	while passati < 2000 and visibile.acceso:
		await get_tree().process_frame
		passati += 1
	esigi(passati > 1, "l'orologio e' scaduto prima ancora di essere disegnato una volta")
	# e anche da fermo, a lancetta a zero, un ridisegno non deve lamentarsi
	visibile.queue_redraw()
	await get_tree().process_frame
	esigi(not visibile.acceso,
			"dopo %d fotogrammi un orologio da due decimi va ancora" % passati)
	visibile.queue_free()

func prova_minigioco_ai_bordi() -> void:
	# IL SEGNALE "FINITO" E' TUTTO. E' li' che il combattimento riprende, si
	# applica il danno e il tutorial va avanti: se non arriva, o arriva due
	# volte, il gioco resta fermo o conta il danno due volte.
	titolo("il minigioco ai bordi: il segnale arriva sempre, e una volta sola")
	GameState.nuova_partita()
	var quadrante := Control.new()
	quadrante.size = Vector2(700, 260)
	add_child(quadrante)

	var gioco := MinigiocoCombattimento.new()
	gioco.collega(quadrante)
	var esiti: Array[Dictionary] = []
	gioco.finito.connect(func(esito: Dictionary) -> void: esiti.append(esito))

	# 1. UNA RAFFICA NORMALE FINISCE UNA VOLTA SOLA
	gioco.avvia({"quanti": 5, "intervallo": 0.2, "durata": 0.3, "danno": 4})
	esigi(gioco.attivo, "la raffica non e' partita")
	esigi(esiti.is_empty(), "la raffica ha gia' detto di essere finita appena partita")
	for passo in 200:
		gioco.passa(0.05)
		if not gioco.attivo:
			break
	esigi(not gioco.attivo, "la raffica non finisce mai da sola")
	esigi(esiti.size() == 1, "la raffica ha detto di essere finita %d volte" % esiti.size())
	esigi(int(esiti[0].get("totali", 0)) == 5,
			"l'esito parla di %d pugni invece di cinque" % int(esiti[0].get("totali", 0)))

	# 2. CONTINUARE A FAR SCORRERE IL TEMPO DOPO LA FINE NON RIPETE NIENTE
	for passo in 50:
		gioco.passa(0.05)
	esigi(esiti.size() == 1, "dopo la fine la raffica ha detto di essere finita altre volte")

	# 3. CLICCARE DOPO LA FINE NON FA NIENTE, e non esplode
	for indice in 8:
		gioco.colpisci(indice)
	esigi(esiti.size() == 1, "cliccando a raffica finita e' arrivato un altro esito")

	# 4. PARARE TUTTO IN PIENO VUOL DIRE ZERO DANNO. E' la promessa del
	#    minigioco: «cliccando su di esse annulli il danno». Ma si para in pieno
	#    SOLO QUANDO IL CERCHIO SI CHIUDE - e' il cuore del minigioco. Qui si
	#    simula una mano perfetta: preme ogni pugno quando arriva, non quando
	#    compare.
	esiti.clear()
	gioco.avvia({"quanti": 4, "intervallo": 0.2, "durata": 0.5, "danno": 7})
	for passo in 400:
		for pugno in gioco.raffica:
			if gioco.tempo >= float(pugno.piena_da) and gioco.tempo <= float(pugno.scade):
				gioco.colpisci(int(pugno.indice))
		gioco.passa(0.05)
		if not gioco.attivo:
			break
	esigi(esiti.size() == 1, "la raffica parata tutta ha dato %d esiti" % esiti.size())
	esigi(int(esiti[0].get("parati", 0)) == 4,
			"parati %d pugni su quattro pur avendoli cliccati tutti" % int(esiti[0].get("parati", 0)))
	esigi(int(esiti[0].get("danno", 0)) == 0,
			"parandoli tutti arrivano lo stesso %d di danno" % int(esiti[0].get("danno", 0)))

	# 5. NON PARARNE NESSUNO COSTA TUTTO
	esiti.clear()
	gioco.avvia({"quanti": 4, "intervallo": 0.2, "durata": 0.3, "danno": 7})
	for passo in 400:
		gioco.passa(0.05)
		if not gioco.attivo:
			break
	esigi(int(esiti[0].get("parati", 0)) == 0, "senza cliccare qualcosa si e' parato da solo")
	esigi(int(esiti[0].get("danno", 0)) == 28,
			"quattro pugni da sette fanno %d di danno" % int(esiti[0].get("danno", 0)))

	# 6. DA MUTO SI RISOLVE SUBITO. E' la strada del giocatore automatico: non
	#    c'e' nessun rettangolo e nessuna mano, ma l'esito deve arrivare uguale.
	var muto := MinigiocoCombattimento.new(true)
	var esiti_muti: Array[Dictionary] = []
	muto.finito.connect(func(esito: Dictionary) -> void: esiti_muti.append(esito))
	muto.avvia({"quanti": 6, "intervallo": 0.2, "durata": 0.3, "danno": 3}, 1.0)
	esigi(esiti_muti.size() == 1, "da muto l'esito non arriva subito")
	esigi(not muto.attivo, "da muto la raffica resta attiva")
	esigi(int(esiti_muti[0].get("danno", 0)) == 0,
			"con bravura piena il giocatore automatico incassa %d" % int(esiti_muti[0].get("danno", 0)))
	quadrante.queue_free()

func prova_combattimento_sotto_stress() -> void:
	# QUELLO CHE FA CHI PROVA UN GIOCO DAVVERO: clicca due volte, clicca quando
	# non tocca a lui, clicca dopo che e' finita, apre la pausa a meta' colpo.
	# In un combattimento a turni queste cose non esistono; in tempo reale sono
	# la normalita', e ognuna e' un modo di far succedere due volte una cosa che
	# doveva succedere una volta sola.
	titolo("il combattimento sotto le dita di chi lo prova")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.limite_giri = 99
	add_child(scontro)
	scontro.in_corso = true
	var tu: Dictionary = scontro.combattente_comandato()
	var nemico: Dictionary = scontro.vivi(false)[0]
	esigi(not tu.is_empty() and not nemico.is_empty(), "il campo non ha due combattenti")

	# 1. DUE CLICK NELLO STESSO FOTOGRAMMA, UN COLPO SOLO. Il conto dei colpi
	#    incassati e' il testimone: il danno e' casuale, il numero di colpi no.
	tu.hp = tu.hp_max
	dai_il_turno(scontro, tu)
	nemico.hp = nemico.hp_max
	nemico["colpi_incassati"] = 0
	scontro.agisci_ora({"tipo": "attacca", "bersaglio": nemico})
	scontro.agisci_ora({"tipo": "attacca", "bersaglio": nemico})
	scontro.agisci_ora({"tipo": "attacca", "bersaglio": nemico})
	esigi(int(nemico.colpi_incassati) == 1,
			"tre click nello stesso fotogramma hanno fatto arrivare %d colpi"
			% int(nemico.colpi_incassati))
	esigi(not scontro.puo_agire(tu),
			"dopo aver agito tocca ancora a te: si potrebbe agire all'infinito")

	# 2. CLICCARE FUORI DAL TUO TURNO NON COLPISCE ADESSO
	nemico["colpi_incassati"] = 0
	for volta in 10:
		scontro.agisci_ora({"tipo": "attacca", "bersaglio": nemico})
	esigi(int(nemico.colpi_incassati) == 0,
			"martellando fuori dal tuo turno sono arrivati %d colpi" % int(nemico.colpi_incassati))

	# 3. E NEMMENO DUE AZIONI DIVERSE INSIEME. Attacco e fuga nello stesso
	#    fotogramma: passa il primo, il secondo trova il turno gia' passato.
	dai_il_turno(scontro, tu)
	nemico["colpi_incassati"] = 0
	var in_corso_prima: bool = scontro.in_corso
	scontro.agisci_ora({"tipo": "attacca", "bersaglio": nemico})
	scontro.agisci_ora({"tipo": "fuggi"})
	esigi(int(nemico.colpi_incassati) == 1,
			"attacco e fuga insieme hanno fatto arrivare %d colpi" % int(nemico.colpi_incassati))
	esigi(scontro.in_corso == in_corso_prima,
			"la fuga e' partita lo stesso pur non essendo il proprio momento")

	# 4. A SCONTRO FINITO NON SI AGISCE PIU'. E' il caso di chi clicca mentre
	#    compare la schermata di fine: il colpo non deve arrivare a un nemico
	#    che non c'e' piu'.
	scontro.in_corso = false
	dai_il_turno(scontro, tu)
	nemico["colpi_incassati"] = 0
	for volta in 5:
		scontro.agisci_ora({"tipo": "attacca", "bersaglio": nemico})
	esigi(int(nemico.colpi_incassati) == 0,
			"a scontro finito sono ancora arrivati %d colpi" % int(nemico.colpi_incassati))
	scontro.in_corso = true

	# 5. LA PAUSA FERMA IL MONDO. In tempo reale una pausa che non ferma
	#    l'orologio vuol dire prendere botte mentre si legge il menu.
	esigi(scontro.can_process(), "lo scontro non gira nemmeno a gioco acceso")
	get_tree().paused = true
	esigi(not scontro.can_process(),
			"con la pausa aperta lo scontro continua a girare: si prendono colpi mentre si legge")
	get_tree().paused = false
	esigi(scontro.can_process(), "tolta la pausa lo scontro non riparte")
	scontro.voce.coda.clear()
	scontro.free()

func prova_la_giornata_passo_per_passo() -> void:
	# LA GIORNATA ALLA BASE CAMMINATA PER DAVVERO, guardando lo stato dopo OGNI
	# passo invece che a campione.
	#
	# La prova che c'era gia' cammina i DATI - questo nodo porta a quello. Questa
	# cammina il MONDO: dopo ogni tappa, quali flag ci sono, quanti tazo, quali
	# appunti, quali messaggi. Un effetto che si applica al momento sbagliato, o
	# due volte, qui si vede.
	titolo("la giornata alla base, tappa per tappa, guardando il mondo")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame

	var tazo_di_partenza := GameState.tazo
	# [nodo, flag che DEVE esserci dopo, flag che NON deve esserci ancora]
	# la sala comunicazioni prima chiede (la convocazione), e gli ordini arrivano
	# solo aprendo il canale: entrarci non accende niente
	var tappe := [
		["infermeria_risveglio", "rientro_infermeria", "ordini_ricevuti"],
		["sala_comunicazioni", "", "ordini_ricevuti"],
		["comunicazioni_ordini", "ordini_ricevuti", "data_pad_spiegato"],
		["data_pad_istruzioni", "data_pad_spiegato", "proiezione_spiegata"],
		["sala_proiezione", "proiezione_spiegata", ""],
	]
	for tappa in tappe:
		var id_nodo := String(tappa[0])
		var deve := String(tappa[1])
		var non_ancora := String(tappa[2])
		esigi(deve == "" or not GameState.ha_flag(deve),
				"prima di entrare in '%s' il flag '%s' c'e' gia': qualcuno lo ha acceso in anticipo"
				% [id_nodo, deve])
		schermata.mostra_nodo(id_nodo)
		esigi(deve == "" or GameState.ha_flag(deve),
				"dopo '%s' manca il flag '%s'" % [id_nodo, deve])
		if non_ancora != "":
			esigi(not GameState.ha_flag(non_ancora),
					"dopo '%s' c'e' gia' il flag '%s': una tappa piu' avanti si e' accesa da sola"
					% [id_nodo, non_ancora])

	# i 3000 tazo sono arrivati UNA volta, e la missione pure
	esigi(GameState.tazo == tazo_di_partenza + 3000,
			"a fine giornata i tazo sono %d invece di %d" % [GameState.tazo, tazo_di_partenza + 3000])
	esigi("benvenuto_quota" in GameState.messaggi_ricevuti, "la quota di benvenuto non e' mai arrivata")
	esigi("prima_proiezione" in GameState.task_attivi or "prima_proiezione" in GameState.task_chiusi,
			"la missione della sala di proiezione non e' mai comparsa")

	# ENTRARE DUE VOLTE NON DEVE CONTARE DUE VOLTE.
	#
	# Un nodo si puo' rivisitare - la mappa lo permette apposta - e gli effetti
	# di una seconda visita sono la classe di difetto che nessuno prova mai: i
	# 3000 tazo accreditati un'altra volta, un appunto riaperto, una scena
	# rigiocata. Qui si ripassa da tutte le tappe e si guarda che il mondo non
	# si muova piu'.
	var tazo_prima := GameState.tazo
	var flag_prima := GameState.flags.size()
	var messaggi_prima := GameState.messaggi_ricevuti.size()
	var sacca_prima := GameState.sacca.size()
	for tappa in tappe:
		schermata.mostra_nodo(String(tappa[0]))
	esigi(GameState.tazo == tazo_prima,
			"ripassando dalle stesse stanze i tazo sono passati da %d a %d"
			% [tazo_prima, GameState.tazo])
	esigi(GameState.messaggi_ricevuti.size() == messaggi_prima,
			"ripassando sono arrivati altri %d messaggi"
			% (GameState.messaggi_ricevuti.size() - messaggi_prima))
	esigi(GameState.sacca.size() == sacca_prima,
			"ripassando la sacca e' cresciuta di %d oggetti"
			% (GameState.sacca.size() - sacca_prima))
	esigi(GameState.flags.size() == flag_prima,
			"ripassando sono comparsi altri %d flag" % (GameState.flags.size() - flag_prima))
	schermata.queue_free()

func prova_la_scena_cambia_mentre_si_legge() -> void:
	# LA SCENA PUO' CAMBIARE MENTRE IL BOX PARLA: lo scontro finisce, il
	# giocatore torna al menu, una stanza lo manda altrove.
	# change_scene_to_file libera la vecchia scena - e con lei il box e la zona
	# cliccabile - ma l'albero sopravvive, quindi la coroutine si risveglia lo
	# stesso al fotogramma dopo e va a scrivere su roba che non c'e' piu'.
	# Godot lo segnala, e chi sta giocando vede degli errori proprio mentre esce.
	titolo("se la scena cambia mentre il box parla, la voce smette in silenzio")
	GameState.nuova_partita()
	var finto := FintoBox.new()
	add_child(finto)
	var zona := Button.new()
	add_child(zona)
	var volanti := Control.new()
	add_child(volanti)
	var voce := VoceCombattimento.new(get_tree())
	voce.collega(finto, zona, volanti)
	voce.tempo_reale = true
	for testo in ["prima", "seconda", "terza"]:
		voce.scrivi(String(testo))

	voce.svuota_coda()          # parte e si mette ad aspettare la lettura
	await get_tree().process_frame
	esigi(voce.sta_svuotando, "la voce non ha nemmeno cominciato: la prova non misura niente")
	esigi(finto.mostrate.size() == 1, "la prima battuta non e' arrivata a schermo")

	# LA SCENA SPARISCE SOTTO, come fa change_scene_to_file: i nodi vecchi
	# vengono liberati in differita, non strappati via a meta' fotogramma.
	finto.queue_free()
	zona.queue_free()
	for giro in 20:
		await get_tree().process_frame
	# se non ci fossero le guardie, qui Godot avrebbe gia' stampato
	# "previously freed instance" e la suite sarebbe rossa per gli errori
	esigi(not voce.sta_svuotando,
			"la voce si crede ancora occupata dopo che la scena e' sparita: il prossimo svuotamento aspetterebbe per sempre")
	esigi(not voce.viva(), "la voce si crede ancora viva con il box liberato")
	# e riprovare a farla parlare non fa danni
	voce.scrivi("dopo la fine")
	await voce.svuota_coda()
	esigi(true, "far parlare una voce senza box non deve far esplodere niente")
	volanti.queue_free()

func prova_si_salva_solo_fuori_dalle_fratture() -> void:
	# «non puoi salvare a meta\' scontro, il salvataggio solo fuori dalle
	# fratture, nelle fratture al massimo ci sono checkpoint» (Bru).
	#
	# Oggi la regola e\' rispettata perche\' il salvataggio si chiama da due posti
	# soli. Niente pero\' la difende: basta una riga in piu\' da qualche parte -
	# un bottone "salva" nella pausa, un salvataggio a fine scontro "per comodita\'"
	# - e la regola cade senza che nessuno se ne accorga.
	titolo("il gioco si salva in due posti soli, e nessuno dei due e' dentro una frattura")
	var permessi := {
		"scripts/Sede.gd": "rientrare alla Sede E' il salvataggio: fuori dalle fratture",
		"scripts/IngressoNodo.gd": "il checkpoint di una zona lunga, dietro salva_checkpoint",
	}
	var cartelle := ["res://scripts"]
	var trovati := 0
	while not cartelle.is_empty():
		var qui: String = cartelle.pop_back()
		var dir := DirAccess.open(qui)
		if dir == null:
			continue
		for nome in dir.get_directories():
			cartelle.append(qui + "/" + nome)
		for nome in dir.get_files():
			if not nome.ends_with(".gd"):
				continue
			var percorso := qui + "/" + nome
			var corto := percorso.replace("res://", "")
			var testo := FileAccess.get_file_as_string(percorso)
			for riga in testo.split("\n"):
				var pulita := String(riga).strip_edges()
				if pulita.begins_with("#") or not pulita.contains("GameState.salva"):
					continue
				trovati += 1
				esigi(permessi.has(corto),
						"%s salva la partita: il salvataggio sta solo alla Sede e nei checkpoint («%s»)"
						% [corto, pulita.substr(0, 50)])
	esigi(trovati >= 2,
			"ho trovato %d punti di salvataggio: la prova non sta guardando abbastanza" % trovati)
	# e il checkpoint dev'essere dietro la sua chiave, non incondizionato
	var ingresso := FileAccess.get_file_as_string("res://scripts/IngressoNodo.gd")
	esigi(ingresso.contains("salva_checkpoint"),
			"il salvataggio in IngressoNodo non e' piu' dietro salva_checkpoint: salverebbe in ogni stanza")

func prova_il_checkpoint_non_ti_lascia_dentro() -> void:
	# UN CHECKPOINT NON E' UN PUNTO DA CUI SI RIPARTE. Bru: «nelle fratture al
	# massimo ci sono checkpoint». Protegge quello che hai raccolto, non la tua
	# posizione: ricaricando si torna fuori, con il bottino in mano.
	titolo("un checkpoint tiene il bottino, non ti lascia dentro la frattura")
	GameState.nuova_partita()
	var slot_prova := 1
	GameState.imposta_slot(slot_prova)
	GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
	GameState.nodo_corrente = "bivio"
	GameState.imposta_flag("prova_bottino")
	GameState.modifica_tazo(250)
	GameState.stanze_ripulite.append("masso")
	esigi(GameState.nodo_corrente == "bivio", "la preparazione non ci ha messo dentro la zona")
	esigi(not GameState.mappa_zona.is_empty(), "la zona non ha una mappa: la prova non misura niente")
	GameState.salva()

	# adesso si muore, e si riprende
	var tazo_prima := GameState.tazo
	GameState.nuova_partita()
	GameState.imposta_slot(slot_prova)
	esigi(GameState.carica(), "il salvataggio del checkpoint non si ricarica")
	esigi(GameState.ha_flag("prova_bottino"), "il checkpoint non ha tenuto i flag raccolti")
	esigi(GameState.tazo == tazo_prima,
			"il checkpoint ha tenuto %d tazo invece di %d" % [GameState.tazo, tazo_prima])
	# ...ma FUORI dalla frattura
	esigi(GameState.nodo_corrente == "",
			"ricaricando si riparte da dentro la frattura, dal nodo '%s'" % GameState.nodo_corrente)
	esigi(GameState.mappa_zona.is_empty(), "ricaricando la mappa della zona e' ancora addosso")
	esigi(GameState.eventi.is_empty(), "ricaricando i nodi della zona sono ancora caricati")
	esigi(GameState.stanze_ripulite.is_empty(),
			"ricaricando le stanze gia' ripulite restano ripulite: la zona sarebbe mezza vuota")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GameState.percorso_slot(slot_prova)))

func prova_l_ecg_non_si_apre_su_una_riga_piatta() -> void:
	# LA LINEA PIATTA VUOL DIRE MORTO, E LO DICEVA A OGNI APERTURA.
	#
	# La storia nasce piena di zeri e uno zero si disegna in mezzo al quadrante:
	# per i primi quattro secondi di ogni scontro il tracciato era per meta' una
	# riga dritta che arretrava mentre l'onda vera entrava da destra. Nessuna
	# prova lo vedeva perche' nessuna guardava il quadrante APPENA APERTO - si
	# guardava sempre dopo, a schermo gia' pieno.
	#
	# Si misura contando quanti campioni sono fermi sullo zero al primo
	# fotogramma. Non "e' bello": e' "la memoria e' piena di segnale vero".
	titolo("l'ecg non si apre su una riga piatta")
	var riga := TracciatoEcg.new()
	riga.custom_minimum_size = Vector2(300.0, 90.0)
	add_child(riga)
	riga.imposta(0.55, 30)
	await get_tree().process_frame

	var fermi := 0
	for i in TracciatoEcg.CAMPIONI:
		if is_zero_approx(riga.campione(i)):
			fermi += 1
	esigi(fermi < int(TracciatoEcg.CAMPIONI / 4.0),
			"al primo fotogramma %d campioni su %d sono piatti: il quadrante " %
			[fermi, TracciatoEcg.CAMPIONI] +
			"si apre su una riga dritta, che su un monitor vuol dire morto")
	esigi(riga.campioni_presi >= TracciatoEcg.CAMPIONI,
			"la memoria non e' stata riempita: %d campioni invece di %d"
			% [riga.campioni_presi, TracciatoEcg.CAMPIONI])

	# E IL RIEMPIMENTO SUCCEDE UNA VOLTA SOLA. Rifarlo a ogni fotogramma
	# vorrebbe dire duecentoquaranta campioni per fotogramma invece di uno.
	var dopo_il_primo := riga.campioni_presi
	for giro in 10:
		riga._process(1.0 / 60.0)
	esigi(riga.campioni_presi - dopo_il_primo <= 20,
			"in dieci fotogrammi ha preso %d campioni: si sta riempiendo ogni volta"
			% (riga.campioni_presi - dopo_il_primo))

	# CHI E' A TERRA LA RIGA DRITTA CE L'HA DAVVERO, ed e' l'unico caso.
	var spento := TracciatoEcg.new()
	spento.custom_minimum_size = Vector2(300.0, 90.0)
	add_child(spento)
	spento.imposta(0.0, 0)
	await get_tree().process_frame
	var piatti := 0
	for i in TracciatoEcg.CAMPIONI:
		if is_zero_approx(spento.campione(i)):
			piatti += 1
	esigi(piatti == TracciatoEcg.CAMPIONI,
			"a terra il tracciato non e' piatto: %d campioni su %d si muovono"
			% [TracciatoEcg.CAMPIONI - piatti, TracciatoEcg.CAMPIONI])
	riga.queue_free()
	spento.queue_free()

func prova_ecg_anello_e_riposo() -> void:
	# DUE COSE, TUTTE E DUE MISURATE.
	#
	# 1. La storia del tracciato e' un ANELLO: prima ogni campione faceva
	#    scorrere l'array di un posto - 239 scritture per campione, sessanta
	#    campioni al secondo, per tutta la durata di ogni scontro. Muovere il
	#    punto di partenza fa la stessa identica cosa.
	# 2. Se nessuno lo guarda, non campiona: il quadrante mostra un mestiere per
	#    volta, e mentre scegli da una lista l'ecg non e' a schermo.
	titolo("l'ecg: la storia e' un anello, e a riposo non campiona")
	var riga := TracciatoEcg.new()
	add_child(riga)
	await get_tree().process_frame

	# L'ORDINE E' QUELLO GIUSTO: dal piu' vecchio al piu' recente, che e' come
	# si disegna. Un anello scritto male si accorge solo guardando l'ordine.
	for i in TracciatoEcg.CAMPIONI:
		riga.spingi(float(i) / 1000.0)
	for i in TracciatoEcg.CAMPIONI:
		esigi(is_equal_approx(riga.campione(i), float(i) / 1000.0),
				"il campione %d vale %.4f invece di %.4f"
				% [i, riga.campione(i), float(i) / 1000.0])
	# e continuando a spingere, il piu' vecchio esce e il resto scala di uno
	riga.spingi(9.0)
	esigi(is_equal_approx(riga.campione(TracciatoEcg.CAMPIONI - 1), 9.0),
			"l'ultimo campione non e' quello appena spinto")
	esigi(is_equal_approx(riga.campione(0), 1.0 / 1000.0),
			"il piu' vecchio non e' uscito: campione(0) vale %.4f" % riga.campione(0))

	# A RIPOSO NON CAMPIONA. Si guarda col contatore, non a occhio.
	riga.visible = false
	var fermi := riga.campioni_presi
	for giro in 60:
		riga._process(1.0 / 60.0)
	esigi(riga.campioni_presi == fermi,
			"nascosto, l'ecg ha preso altri %d campioni" % (riga.campioni_presi - fermi))
	riga.visible = true
	for giro in 60:
		riga._process(1.0 / 60.0)
	esigi(riga.campioni_presi > fermi,
			"tornato visibile, l'ecg non ha ripreso a campionare")
	riga.queue_free()

func prova_niente_disco_dentro_un_disegno() -> void:
	# LA REGOLA, NON SOLO IL CASO. Il contatore di Disegni dice che la cache
	# funziona; non dice che qualcuno, un domani, non riscriva
	#
	#     if ResourceLoader.exists(percorso): load(percorso)
	#
	# dentro un _draw. E' com'era, ed e' facile che ritorni: e' la riga piu'
	# naturale da scrivere. Un disegno si rifa' a ogni fotogramma, quindi li'
	# dentro al disco non si chiede niente - si chiede a Disegni, che ricorda.
	titolo("dentro un disegno non si interroga il disco")
	var cartelle := ["res://scripts"]
	var da_guardare: Array[String] = []
	while not cartelle.is_empty():
		var qui: String = cartelle.pop_back()
		var dir := DirAccess.open(qui)
		if dir == null:
			continue
		for nome in dir.get_directories():
			cartelle.append(qui + "/" + nome)
		for nome in dir.get_files():
			if nome.ends_with(".gd"):
				da_guardare.append(qui + "/" + nome)
	esigi(da_guardare.size() > 20,
			"ho trovato solo %d script da guardare: il giro delle cartelle non funziona"
			% da_guardare.size())
	var guardati := 0
	for percorso in da_guardare:
		if percorso.ends_with("/Disegni.gd"):
			continue   # e' lui il posto dove si chiede al disco, una volta sola
		var testo := FileAccess.get_file_as_string(percorso)
		var dentro_un_disegno := false
		var nome_funzione := ""
		for riga in testo.split("\n"):
			var pulita := String(riga).strip_edges()
			if pulita.begins_with("func ") or pulita.begins_with("static func "):
				nome_funzione = pulita.split("(")[0].replace("static func ", "").replace("func ", "")
				dentro_un_disegno = nome_funzione == "_draw" or nome_funzione == "_process" \
						or nome_funzione.begins_with("disegna")
				if dentro_un_disegno:
					guardati += 1
				continue
			if not dentro_un_disegno or pulita.begins_with("#"):
				continue
			var chiede := pulita.contains("ResourceLoader.exists") \
					or pulita.contains("load(") and not pulita.contains("preload(")
			esigi(not chiede,
					"%s / %s() chiede al disco dentro un disegno: «%s»"
					% [percorso.get_file(), nome_funzione, pulita.substr(0, 60)])
	esigi(guardati >= 6,
			"ho controllato solo %d funzioni di disegno: la prova non sta guardando abbastanza"
			% guardati)

func prova_due_svuotamenti_non_si_pestano() -> void:
	# IN TEMPO REALE LA CODA HA DUE PADRONI: la pompa dei messaggi, che gira per
	# tutto lo scontro, e chi ogni tanto aspetta che si sia letto tutto - il
	# lancio di un minigioco parte da _process, cioe' MENTRE la pompa sta gia'
	# leggendo.
	#
	# Senza guardia due cicli pescano dalla stessa coda: il secondo chiama
	# box.mostra() sopra la battuta che il primo sta facendo leggere, e quella
	# sparisce senza essere mai stata letta. E' la riga di Veronica prima delle
	# Collisioni infinite.
	titolo("due svuotamenti insieme non si rubano le battute")
	GameState.nuova_partita()
	var finto := FintoBox.new()
	add_child(finto)
	var zona := Button.new()
	add_child(zona)
	var volanti := Control.new()
	add_child(volanti)
	var voce := VoceCombattimento.new(get_tree())
	voce.collega(finto, zona, volanti)
	voce.tempo_reale = true   # niente attese di click: si misura la coda, non il polso
	var battute := ["prima", "seconda", "terza", "quarta"]
	for testo in battute:
		voce.scrivi(String(testo))
	esigi(voce.coda.size() == battute.size(), "la coda di partenza non ha quattro battute")

	# DUE SVUOTAMENTI AVVIATI INSIEME, come succede in partita: la pompa gira
	# per conto suo (chiamata e basta, senza await - e' cosi' che parte davvero
	# in Combattimento), e subito dopo qualcuno si ferma ad aspettare che si sia
	# letto tutto. Con la guardia il secondo torna solo quando il primo ha
	# finito, quindi questo await basta per tutti e due.
	voce.svuota_coda()
	await voce.svuota_coda()

	esigi(voce.coda.is_empty(), "la coda non si e' svuotata: restano %d battute" % voce.coda.size())
	esigi(finto.mostrate.size() == battute.size(),
			"a schermo sono arrivate %d battute su %d: %s"
			% [finto.mostrate.size(), battute.size(), finto.mostrate])
	for i in battute.size():
		esigi(i < finto.mostrate.size() and finto.mostrate[i] == String(battute[i]),
				"la battuta %d doveva essere «%s», e' arrivata «%s»"
				% [i, String(battute[i]),
						finto.mostrate[i] if i < finto.mostrate.size() else "(niente)"])
	esigi(not voce.sta_svuotando,
			"finito di leggere, la voce si crede ancora occupata: il prossimo svuotamento aspetterebbe per sempre")

	# E OGNUNA DEVE ESSERE RESTATA A SCHERMO IL SUO TEMPO.
	#
	# E' qui che si vede il difetto vero, e la prima versione di questa prova non
	# lo vedeva: con due svuotamenti in parallelo le quattro battute arrivano
	# tutte e quattro lo stesso - solo che la seconda copre la prima nello stesso
	# fotogramma. Contarle non bastava; bisogna guardare quanto sono distanti.
	var minimo := 999999
	for i in range(1, finto.quando.size()):
		minimo = mini(minimo, finto.quando[i] - finto.quando[i - 1])
	esigi(finto.quando.size() >= 2, "sono arrivate meno di due battute: non c'e' distanza da misurare")
	esigi(minimo >= 80,
			"fra due battute sono passati %d millesimi: la seconda ha coperto la prima prima che si leggesse"
			% minimo)
	finto.queue_free()
	zona.queue_free()
	volanti.queue_free()

func prova_svuotare_svuota_subito() -> void:
	# queue_free() NON LIBERA ADESSO: mette in coda, e libera a fine fotogramma.
	# Finche' non succede i figli vecchi sono ancora figli - stanno nell'albero,
	# contano, e un contenitore li dispone insieme a quelli nuovi. Chi svuota E
	# RIEMPIE nella stessa chiamata, per un fotogramma ne ha il doppio.
	titolo("svuotare un contenitore lo svuota subito, non a fine fotogramma")
	var scatola := VBoxContainer.new()
	add_child(scatola)
	for i in 4:
		var b := Button.new()
		b.text = "voce %d" % i
		scatola.add_child(b)
	esigi(scatola.get_child_count() == 4, "la scatola di partenza non ha quattro figli")
	Albero.svuota(scatola)
	esigi(scatola.get_child_count() == 0,
			"dopo averlo svuotato il contenitore ha ancora %d figli: sono in coda, non tolti"
			% scatola.get_child_count())
	# e riempiendolo subito dopo non se ne trovano di vecchi in mezzo
	for i in 2:
		var b := Button.new()
		b.text = "nuova %d" % i
		scatola.add_child(b)
	esigi(scatola.get_child_count() == 2,
			"svuotato e riempito, il contenitore ha %d figli invece di due"
			% scatola.get_child_count())
	Albero.svuota(scatola)
	scatola.free()

func prova_le_scelte_non_raddoppiano() -> void:
	# E LA REGOLA DEV'ESSERE ATTACCATA ALLA PORTA VERA. I bottoni delle scelte
	# sono quello che il giocatore clicca: se per un fotogramma ce ne sono il
	# doppio, il contenitore li mette in fila tutti e il fuoco da tastiera puo'
	# finire su uno che sta morendo.
	titolo("le scelte non raddoppiano quando la schermata si rifa'")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	# un nodo con piu' di una scelta: il ritorno dalla missione ne ha due
	var nodo := {"scelte": [
		{"testo": "Sì, torno alla base", "vai": "alloggio"},
		{"testo": "No, voglio dare ancora un'occhiata", "vai": "alloggio"},
	]}
	schermata.ricostruisci_scelte(nodo)
	var dopo_una: int = schermata.contenitore_scelte.get_child_count()
	esigi(dopo_una == 2, "due scelte hanno prodotto %d righe" % dopo_una)
	# rifatta subito, nello stesso fotogramma: e' quello che succede quando la
	# coda dei messaggi si svuota e le scelte si riaprono
	schermata.ricostruisci_scelte(nodo)
	var dopo_due: int = schermata.contenitore_scelte.get_child_count()
	esigi(dopo_due == 2,
			"rifacendo le scelte nello stesso fotogramma ce ne sono %d invece di due" % dopo_due)
	schermata.ricostruisci_scelte(nodo)
	esigi(schermata.contenitore_scelte.get_child_count() == 2,
			"alla terza volta le scelte sono %d" % schermata.contenitore_scelte.get_child_count())
	schermata.queue_free()

func prova_un_messaggio_si_annuncia() -> void:
	# UN MESSAGGIO CHE ARRIVA IN SILENZIO NON E' ARRIVATO.
	#
	# messaggi_da_notificare esisteva e non lo leggeva nessuno: mezza funzione,
	# cioe' una trappola. I 3000 tazo si vedevano solo perche' la scena del data
	# pad se li scriveva a mano; qualunque altro messaggio sarebbe arrivato senza
	# che niente lo dicesse, e il giocatore non ha nessun motivo di aprire una
	# sezione che non lo ha mai chiamato.
	titolo("un messaggio nuovo si annuncia da solo")
	GameState.nuova_partita()
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	esigi(schermata.notifiche_messaggi().is_empty(),
			"senza messaggi nuovi il gioco annuncia qualcosa lo stesso")
	GameState.imposta_flag("ordini_ricevuti")
	esigi(not GameState.messaggi_da_notificare.is_empty(),
			"arrivata la quota di benvenuto non c'e' niente da annunciare")
	var righe: Array[Dictionary] = schermata.notifiche_messaggi()
	esigi(righe.size() >= 1,
			"il messaggio e' arrivato e non lo annuncia nessuno: i 3000 tazo compaiono sul conto in silenzio")
	var testo := String(righe[0].get("testo", ""))
	esigi(String(righe[0].get("tipo", "")) == "notifica",
			"l'annuncio non e' una notifica ma '%s'" % String(righe[0].get("tipo", "")))
	esigi("Quota di benvenuto" in testo,
			"l'annuncio non dice di che messaggio si tratta: «%s»" % testo)
	# e non si annuncia due volte
	esigi(schermata.notifiche_messaggi().is_empty(),
			"lo stesso messaggio si annuncia di nuovo alla chiamata dopo")

	# E L'ANNUNCIO DEV'ESSERE CUCITO AL PERCORSO VERO, non solo esistere.
	#
	# La prima versione di questa prova chiamava notifiche_messaggi() a mano e
	# passava anche togliendo tutte e tre le cuciture da Main: misurava che la
	# funzione funzionasse, non che qualcuno la chiamasse. E' il terzo caso
	# identico in questa sessione, quindi qui si entra in un nodo per davvero e
	# si guarda cosa finisce nella coda.
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	schermata.mostra_nodo("comunicazioni_ordini")
	var annunciato := false
	for msg in schermata.coda_messaggi:
		if String((msg as Dictionary).get("tipo", "")) == "notifica" \
				and "Quota di benvenuto" in String((msg as Dictionary).get("testo", "")):
			annunciato = true
	esigi(annunciato,
			"entrando in sala comunicazioni i 3000 tazo arrivano sul conto e la coda non ne parla: %d righe"
			% schermata.coda_messaggi.size())
	schermata.queue_free()

func prova_flag_su_una_battuta() -> void:
	# IL DATO GIUSTO IN UN MOTORE CHE NON LO LEGGE. La scena ha il flag sulla
	# battuta «acquistato!?», ma finche' nessuno lo applica la ricevuta non
	# arriva mai - e una prova che guarda solo il JSON direbbe che va tutto bene.
	# (E' successo: questa prova nasce da un sabotaggio passato.)
	titolo("una battuta puo' cambiare il mondo nel momento in cui la leggi")
	GameState.nuova_partita()
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	esigi(not GameState.ha_flag("prova_flag_di_battuta"),
			"il flag c'era gia' prima di cominciare: la prova non misura niente")
	var coda: Array[Dictionary] = [
		{"tipo": "narrazione", "testo": "Una riga qualunque."},
		{"tipo": "narrazione", "testo": "La riga che cambia le cose.",
				"flag": "prova_flag_di_battuta", "suono": "data_pad"},
	]
	schermata.coda_messaggi = coda
	AudioManager.lettore_sfx.stream = null
	schermata.avanza_messaggio()
	esigi(not GameState.ha_flag("prova_flag_di_battuta"),
			"il flag e' arrivato con la battuta SBAGLIATA: una riga prima del suo momento")
	schermata.avanza_messaggio()
	esigi(GameState.ha_flag("prova_flag_di_battuta"),
			"la battuta porta un flag e il motore non lo applica: la ricevuta non arriverebbe mai")
	# E PUO' ANCHE SUONARE. Bru, sull'avviso del data pad: «qui metteremo un
	# suono che creo io tipo allert». Se il motore non legge la chiave, il
	# giorno che il file arriva non suonera' da nessuna parte - e la prova che
	# guarda solo il JSON direbbe che va tutto bene. (E' successo: questo pezzo
	# nasce da un sabotaggio passato.)
	esigi(AudioManager.lettore_sfx.stream != null,
			"la battuta chiede un suono e non parte niente")
	schermata.queue_free()

func prova_orde() -> void:
	# «non abbiamo piu' il nemico zombi ma orda di zombi che puo' presentarsi in
	# varie quantita', da 3 a 10 fino a rarissimamente 30 [...] e' un singolo
	# disegno, ogni tot hp che perde esce un dialogo: l'orda si indebolisce» (Bru).
	titolo("le orde: gli scalini, i colpi che arrivano, e il senso del colpo ad area")

	# GLI SCALINI DA TRENTA SONO DI BRU, parola per parola. Se un giorno il conto
	# automatico se li mangia, questa prova lo dice.
	esigi(OrdaDiNemici.scalini_per(30) == [30, 22, 17, 11, 5, 3, 1, 0],
			"l'orda da trenta non scende piu' come l'ha scritta Bru: %s"
			% [OrdaDiNemici.scalini_per(30)])

	# «a seconda di quanti componenti ha l'orda ci saranno piu' fasi di
	# indebolimento»: piu' e' grossa, piu' volte la senti cedere
	var fasi_prima := 0
	for quanti in [3, 4, 5, 6, 7, 8, 9, 10, 30]:
		var scala := OrdaDiNemici.scalini_per(quanti)
		esigi(scala[0] == quanti,
				"l'orda da %d non comincia da %d ma da %d" % [quanti, quanti, scala[0]])
		esigi(scala[scala.size() - 1] == 0,
				"l'orda da %d non arriva mai a zero: non si puo' abbattere" % quanti)
		for i in range(1, scala.size()):
			esigi(scala[i] < scala[i - 1],
					"l'orda da %d ha due scalini che non scendono: %s" % [quanti, scala])
		esigi(scala.size() - 1 >= fasi_prima,
				"l'orda da %d ha MENO fasi di una piu' piccola (%d contro %d)"
				% [quanti, scala.size() - 1, fasi_prima])
		fasi_prima = scala.size() - 1
	esigi(OrdaDiNemici.scalini_per(30).size() > OrdaDiNemici.scalini_per(3).size(),
			"l'orda da trenta non ha piu' fasi di quella da tre")

	# QUANTI NE RESTANO IN PIEDI: a vita piena tutti, a zero nessuno, e in mezzo
	# non risale mai
	for quanti in [3, 7, 10, 30]:
		esigi(OrdaDiNemici.componenti_a(1.0, quanti) == quanti,
				"a vita piena l'orda da %d non e' piu' intera" % quanti)
		esigi(OrdaDiNemici.componenti_a(0.0, quanti) == 0,
				"a vita zero l'orda da %d ha ancora qualcuno in piedi" % quanti)
		var ultimo: int = quanti
		var passi := 0
		for centesimi in range(100, -1, -1):
			var adesso := OrdaDiNemici.componenti_a(float(centesimi) / 100.0, quanti)
			esigi(adesso <= ultimo,
					"l'orda da %d RISALE da %d a %d mentre la picchi" % [quanti, ultimo, adesso])
			if OrdaDiNemici.si_indebolisce(ultimo, adesso):
				passi += 1
			ultimo = adesso
		esigi(passi == OrdaDiNemici.scalini_per(quanti).size() - 2,
				"l'orda da %d annuncia %d indebolimenti invece di %d"
				% [quanti, passi, OrdaDiNemici.scalini_per(quanti).size() - 2])
	esigi(not OrdaDiNemici.si_indebolisce(1, 0),
			"quando l'orda cade annuncia un indebolimento invece del KO")

	# «usano un attacco che colpisce x il numero di componenti dell'orda, con un
	# 50% di prob di fallire a colpo». Si tira per OGNI componente: la media e'
	# meta', ma la coda esiste - ed e' quella che fa paura.
	var dado := RandomNumberGenerator.new()
	dado.seed = 20260916
	esigi(OrdaDiNemici.colpi_a_segno(0, dado, 0.5) == 0,
			"un'orda senza componenti colpisce lo stesso")
	esigi(OrdaDiNemici.colpi_a_segno(12, dado, 1.0) == 0,
			"con probabilita' di mancare piena qualche colpo arriva comunque")
	esigi(OrdaDiNemici.colpi_a_segno(12, dado, 0.0) == 12,
			"senza probabilita' di mancare non arrivano tutti e dodici")
	var totale := 0
	var volate := 400
	var sempre_uguale := true
	var primo := -1
	for giro in volate:
		var arrivati := OrdaDiNemici.colpi_a_segno(10, dado, 0.5)
		esigi(arrivati >= 0 and arrivati <= 10,
				"da un'orda da dieci sono arrivati %d colpi" % arrivati)
		if primo < 0:
			primo = arrivati
		elif arrivati != primo:
			sempre_uguale = false
		totale += arrivati
	var media := float(totale) / float(volate)
	esigi(absf(media - 5.0) < 0.6,
			"su %d raffiche da dieci la media e' %.2f invece di circa 5" % [volate, media])
	esigi(not sempre_uguale,
			"ogni raffica fa arrivare sempre lo stesso numero di colpi: non si tira per ognuno")

	# IL COLPO AD AREA. «debole sul singolo ma forte su piu' nemici cosi' diamo
	# un senso ed evitiamo lo spam».
	var frazione := float(GameState.regole.get("moltiplicatore_attacco_area", 0.6))
	esigi(OrdaDiNemici.moltiplicatore_area(frazione, 1) < 1.0,
			"su un nemico solo il colpo ad area vale %.2f: non e' piu' debole di uno normale"
			% OrdaDiNemici.moltiplicatore_area(frazione, 1))
	var prima_area := 0.0
	for quanti in [1, 3, 10, 30]:
		var adesso := OrdaDiNemici.moltiplicatore_area(frazione, quanti)
		esigi(adesso > prima_area,
				"contro un'orda da %d il colpo ad area non vale piu' che contro una piu' piccola"
				% quanti)
		prima_area = adesso
	esigi(OrdaDiNemici.moltiplicatore_area(frazione, 3) > 1.0,
			"gia' contro tre il colpo ad area dovrebbe battere un colpo normale")

	# E I DUE NUMERI SI TENGONO: la vita cresce coi componenti e il colpo ad area
	# pure, quindi un colpo ad area toglie SEMPRE la stessa fetta d'orda - da tre
	# o da trenta - mentre un colpo singolo su un'orda grossa e' uno spillo.
	var attacco := 40.0
	var hp_di_uno := 25
	var fetta_prima := -1.0
	var spillo_prima := 2.0
	for quanti in [3, 10, 30]:
		var vita := OrdaDiNemici.vita_per(hp_di_uno, quanti)
		esigi(vita == hp_di_uno * quanti,
				"la vita dell'orda da %d non e' quella di uno per quanti sono" % quanti)
		var fetta := attacco * OrdaDiNemici.moltiplicatore_area(frazione, quanti) / float(vita)
		if fetta_prima >= 0.0:
			esigi(absf(fetta - fetta_prima) < 0.001,
					"il colpo ad area toglie %.3f d'orda da %d e %.3f da una piu' piccola: non si tengono"
					% [fetta, quanti, fetta_prima])
		fetta_prima = fetta
		var spillo := attacco / float(vita)
		esigi(spillo < spillo_prima,
				"su un'orda da %d un colpo singolo pesa quanto su una piu' piccola" % quanti)
		spillo_prima = spillo

func prova_orda_in_campo() -> void:
	# LA LOGICA GIUSTA ATTACCATA A NIENTE E' IL DIFETTO DI SEMPRE. Orda.gd sa
	# fare i conti; questa guarda che il combattimento li usi davvero.
	titolo("un'orda scende in campo come un nemico solo che ne vale tanti")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["zombie_cittadino"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.limite_giri = 1
	add_child(scontro)

	var orda := {}
	for combattente in scontro.combattenti:
		if not combattente.giocatore:
			orda = combattente
	esigi(not orda.is_empty(), "nessun nemico in campo")
	esigi(scontro.vivi(false).size() == 1,
			"l'orda occupa %d posti invece di uno: nel box grande ci va un disegno solo"
			% scontro.vivi(false).size())

	var quanti := int(orda.get("componenti", 0))
	var regole: Dictionary = GameState.regole.get("orde", {})
	var minimo := int(regole.get("minimo", 3))
	var massimo := int(regole.get("massimo", 10))
	esigi(quanti >= minimo and (quanti <= massimo or quanti == int(regole.get("rara_componenti", 30))),
			"l'orda e' comparsa in %d: fuori da %d-%d e non e' nemmeno quella rara"
			% [quanti, minimo, massimo])
	esigi(String(orda.get("nome", "")) == String(GameState.personaggi
			.get("zombie_cittadino", {}).get("orda", {}).get("nome", "")),
			"in campo l'orda si chiama ancora '%s'" % String(orda.get("nome", "")))

	# la vita e' quella di uno per quanti sono: e' il numero che rende un colpo
	# singolo una puntura di spillo
	var uno := GameState.stat_nemico("zombie_cittadino", "hp",
			int(GameState.regole.get("hp_base", 25)))
	esigi(int(orda.hp_max) == OrdaDiNemici.vita_per(uno, quanti),
			"l'orda da %d ha %d punti vita invece di %d"
			% [quanti, int(orda.hp_max), OrdaDiNemici.vita_per(uno, quanti)])

	# PICCHIANDOLA SI INDEBOLISCE, e lo dice. Senza questo il conto scenderebbe
	# in silenzio e il giocatore non saprebbe mai di aver fatto progressi.
	orda.componenti_iniziali = 30
	orda.componenti = 30
	orda.hp_max = OrdaDiNemici.vita_per(uno, 30)
	orda.hp = orda.hp_max
	var scalini_visti: Array[int] = [30]
	var battute := 0
	for passo in 40:
		orda.hp = maxi(int(orda.hp) - int(float(orda.hp_max) / 40.0) - 1, 0)
		var prima_della_coda: int = scontro.voce.coda.size()
		scontro.aggiorna_orda(orda)
		var adesso := int(orda.componenti)
		if adesso != scalini_visti[scalini_visti.size() - 1]:
			scalini_visti.append(adesso)
			if adesso > 0:
				battute += scontro.voce.coda.size() - prima_della_coda
	esigi(scalini_visti == OrdaDiNemici.scalini_per(30),
			"picchiandola l'orda da trenta e' scesa %s invece che %s"
			% [scalini_visti, OrdaDiNemici.scalini_per(30)])
	esigi(battute == scalini_visti.size() - 2,
			"l'orda ha perso %d scalini e ha detto qualcosa %d volte"
			% [scalini_visti.size() - 2, battute])
	scontro.voce.coda.clear()

	# E COLPISCE PER QUANTI E'. Con dodici addosso devono arrivare piu' colpi
	# che con uno: e' tutto il motivo per cui un'orda fa paura.
	var mossa := {}
	for m in GameState.personaggi.get("zombie_cittadino", {}).get("mosse", []):
		if String(m.get("tipo", "")) == "orda":
			mossa = m
	esigi(not mossa.is_empty(), "l'orda non ha una mossa da orda: attacca come un singolo")
	var tu: Dictionary = scontro.combattente_comandato()
	esigi(not tu.is_empty(), "nessuno da colpire")
	var subiti := {}
	for componenti in [1, 12]:
		orda.componenti = componenti
		orda.hp = orda.hp_max
		var totale := 0
		for giro in 30:
			tu.hp = tu.hp_max
			var prima_hp := int(tu.hp)
			scontro.marea(orda, mossa)
			totale += prima_hp - int(tu.hp)
		subiti[componenti] = totale
	esigi(int(subiti[12]) > int(subiti[1]) * 3,
			"un'orda da dodici ha fatto %d di danno contro %d di una da uno: non colpisce per quanti e'"
			% [int(subiti[12]), int(subiti[1])])
	# IL COLPO AD AREA VALE PER QUANTI NE HA DAVANTI, in campo e non solo sulla
	# carta. Bru: «l'attacco ad area e' debole sul singolo ma forte su piu'
	# nemici cosi' diamo un senso ed evitiamo lo spam».
	var colpitore := tu.duplicate()
	colpitore.attacco = 200
	var tolto := {}
	for componenti in [1, 12]:
		orda.componenti = componenti
		orda.componenti_iniziali = 0   # niente scalini: qui si misura solo il colpo
		orda.hp_max = 2000000
		orda.hp = orda.hp_max
		scontro.attacco_area(colpitore, {})
		tolto[componenti] = orda.hp_max - int(orda.hp)
	esigi(int(tolto[12]) > int(tolto[1]) * 5,
			"il colpo ad area toglie %d a un'orda da dodici e %d a una da uno: non conta i componenti"
			% [int(tolto[12]), int(tolto[1])])

	# E QUANTI SONO SI LEGGE SULLA FASCIA. E' l'unico modo che ha il giocatore di
	# capire che ha davanti un'orda - e senza capirlo, il colpo ad area non ha
	# nessun senso da avere.
	orda.componenti = 7
	orda.hp = orda.hp_max
	scontro.campo.aggiorna(orda)
	esigi("7" in scontro.plancia.fascia_nome.text,
			"la fascia dice '%s': quanti sono non si vede da nessuna parte"
			% scontro.plancia.fascia_nome.text)
	orda.componenti = 0
	scontro.voce.coda.clear()
	scontro.free()

func prova_niente_nemici_misti() -> void:
	# «niente piu' nemici misti» (Bru). Nel box grande ci va un disegno solo:
	# un gruppo con due creature diverse non si potrebbe nemmeno disegnare.
	titolo("niente piu' nemici misti: ogni incontro ha una creatura sola")
	for percorso in file_eventi():
		var dati := carica_eventi(percorso)
		for gruppo in gruppi_di_nemici(dati):
			var specie := {}
			for id_nemico in gruppo:
				specie[String(id_nemico)] = true
			esigi(specie.size() <= 1,
					"%s: un incontro mette insieme %s" % [percorso.get_file(), gruppo])

func gruppi_di_nemici(dati: Variant, raccolta: Array = []) -> Array:
	if dati is Dictionary:
		var d: Dictionary = dati
		if d.has("nemici") and d["nemici"] is Array:
			raccolta.append(d["nemici"])
		for chiave in d:
			gruppi_di_nemici(d[chiave], raccolta)
	elif dati is Array:
		for voce in (dati as Array):
			gruppi_di_nemici(voce, raccolta)
	return raccolta

func prova_il_box_racconta_nel_quadrante() -> void:
	# «il suo dialogo appare dove mettiamo i minigiochi e cosi' anche quelli dei
	# nemici e protagonisti piu' la narrazione del combattimento» (Bru).
	#
	# Il box ci stava gia' dentro, ma la plancia nasceva sul parlato e AL PRIMO
	# MENU passava ai comandi senza tornarci mai piu'. Tutto quello che il
	# combattimento raccontava finiva in un pannello nascosto: in partita non
	# arrivava a schermo una parola.
	titolo("il box racconta nel quadrante, e ridA' il posto al menu quando tocca a te")
	var P := PlanciaCombattimento

	# mentre ricarichi e c'e' da leggere, si legge
	esigi(P.faccia_da_mostrare(false, true, "comandi") == "parlato",
			"mentre ricarichi il box non si prende il quadrante: la narrazione non si vede")
	esigi(P.faccia_da_mostrare(false, true, "lista") == "parlato",
			"il box non si prende il quadrante nemmeno con una lista aperta")

	# MA SE PUOI AGIRE VINCE IL MENU, anche con la coda piena. Un menu nascosto
	# non si vede E non prende il fuoco da tastiera: lasciarlo sotto una frase
	# non e' una scelta di stile, e' toglierti il turno.
	esigi(P.faccia_da_mostrare(true, true, "comandi") == "comandi",
			"il racconto tiene il quadrante mentre potresti agire: il turno e' perso")
	esigi(P.faccia_da_mostrare(true, true, "lista") == "lista",
			"potendo agire non ti ritrovi la lista che stavi guardando")

	# e senza niente da leggere comanda sempre il menu, acceso o spento
	for puoi in [true, false]:
		for modo in ["comandi", "lista"]:
			esigi(P.faccia_da_mostrare(puoi, false, modo) == modo,
					"senza niente da leggere il quadrante non torna a '%s'" % modo)

	# e la faccia si vede davvero: la regola dice un nome, il pannello lo apre
	var radice := Control.new()
	radice.size = Vector2(1280, 720)
	add_child(radice)
	var plancia := PlanciaCombattimento.new()
	plancia.costruisci(radice)
	for caso in [["parlato", plancia.faccia_parlato], ["comandi", plancia.faccia_comandi],
			["lista", plancia.faccia_lista]]:
		plancia.mostra_faccia(String(caso[0]))
		esigi((caso[1] as Control).visible,
				"il quadrante dice di essere su '%s' ma quel pannello resta nascosto" % caso[0])
	radice.free()

	# E LA REGOLA DEV'ESSERE ATTACCATA A QUALCOSA. Una regola giusta che non
	# chiama nessuno e' esattamente il difetto di prima: il box raccontava in un
	# pannello nascosto e le prove dicevano che andava tutto bene.
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.limite_giri = 1
	add_child(scontro)
	scontro.in_corso = true
	scontro.menu_acceso = false        # stai ricaricando: non puoi scegliere niente
	scontro.voce.coda.append({"tipo": "narrazione", "chi": "", "testo": "L'orda si indebolisce.",
			"forte": false, "effetto": Callable()})
	scontro.decidi_faccia()
	esigi(scontro.plancia.faccia_adesso == "parlato",
			"c'e' una battuta da leggere e nessuno accende il parlato: il quadrante mostra '%s'"
			% scontro.plancia.faccia_adesso)
	# IL CONTRATTO E' CAMBIATO, ed e' una decisione di Bru: «ogni cosa a suo
	# tempo e in modo organizzato». Prima, potendo agire, il menu vinceva SUL
	# racconto - e cosi' una battuta poteva sparire senza essere letta. Adesso
	# le due cose non si contendono piu' niente: finche' c'e' da leggere si
	# legge e il mondo aspetta, poi torna il menu. Quindi accendere menu_acceso
	# con una battuta ancora in coda NON deve piu' scoprire il menu.
	scontro.menu_acceso = true          # la ricarica e' finita, ma c'e' ancora da leggere
	scontro.decidi_faccia()
	esigi(scontro.plancia.faccia_adesso == "parlato",
			"c'e' ancora una battuta in coda e il quadrante e' gia' passato a '%s': quella battuta sparisce senza essere letta"
			% scontro.plancia.faccia_adesso)
	# LETTA: ADESSO TOCCA A TE DAVVERO.
	#
	# Qui prima svuotavo la coda e guardavo subito, come se il mondo stesse
	# fermo. Non sta fermo: lo scontro e' vivo e produce battute nuove, e la
	# bandiera sta_facendo_leggere - che prima era sempre falsa, ed era il
	# difetto - adesso resta accesa finche' quella battuta e' stata letta
	# davvero. Quindi la domanda giusta non e' «in questo istante il quadrante
	# e' sui comandi?» ma «arriva un momento, quando non c'e' piu' niente da
	# leggere, in cui il menu torna?». Se non arriva mai, lo scontro e' piantato.
	scontro.voce.coda.clear()
	var torna_il_menu := false
	var scadenza_menu := Time.get_ticks_msec() + 4000
	while Time.get_ticks_msec() < scadenza_menu:
		scontro.decidi_faccia()
		if scontro.plancia.faccia_adesso == "comandi":
			torna_il_menu = true
			break
		await get_tree().process_frame
	esigi(torna_il_menu,
			"finito il racconto il quadrante non torna mai ai comandi (resta su '%s'): il turno non si puo' giocare"
			% scontro.plancia.faccia_adesso)
	scontro.voce.coda.clear()
	scontro.free()

func voci_sovrapposte(plancia, dove: String) -> void:
	# DUE VOCI NON SI CALPESTANO MAI.
	#
	# E' l'invariante che tiene in piedi il conto delle righe: la schermata
	# decide quanto e' alta una riga, ma una voce non scende mai sotto la
	# propria misura minima - se le righe sono piu' di quelle che ci stanno, il
	# testo di una finisce addosso a quella dopo e si legge una riga doppia.
	# Misurare solo "l'ultima voce sta sopra i tasselli" non basta: tra il fondo
	# della lista e i tasselli c'e' aria, e le voci possono accavallarsi tutte
	# senza sforare.
	var rettangoli: Array[Rect2] = []
	var nomi: Array[String] = []
	for v in plancia.griglia_lista.get_children():
		if v.visible:
			rettangoli.append(Rect2(v.position, v.size))
			nomi.append(String(v.text))
	if plancia.tasto_altro != null and plancia.tasto_altro.visible:
		rettangoli.append(Rect2(plancia.tasto_altro.position - plancia.griglia_lista.position,
				plancia.tasto_altro.size))
		nomi.append("Altro")
	for i in rettangoli.size():
		for j in range(i + 1, rettangoli.size()):
			var uno: Rect2 = rettangoli[i].grow(-0.5)
			var due: Rect2 = rettangoli[j].grow(-0.5)
			esigi(not uno.intersects(due),
					"%s: \"%s\" e \"%s\" si sovrappongono (%s e %s)"
					% [dove, nomi[i], nomi[j], rettangoli[i], rettangoli[j]])

func prova_le_liste_del_menu() -> void:
	# «se premi su attacco vedi una lista degli attacchi disponibili, stessa cosa
	# le skill, invece per difesa non ce lista, per fuga neanche, per oggetti
	# invece la lista di oggetti utilizzabili» (Bru).
	#
	# La colonna verticale e la griglia sono due posti diversi dello stesso
	# rettangolo: i comandi stanno nella colonna, le voci di un comando nella
	# griglia. Se finiscono tutte nello stesso posto, la schermata dei comandi si
	# allunga fino a uscire dal pannello e non somiglia piu' al disegno.
	#
	# NIENTE COMBATTIMENTO VERO QUI DENTRO. La prima versione di questa prova
	# accendeva uno scontro intero per premere quattro voci di menu: lo scontro
	# gira in tempo reale, non finiva piu', e la suite si piantava oltre i 600
	# secondi. Serve la plancia e serve il menu - il resto e' un finto avversario
	# che risponde alle sole domande che il menu gli fa.
	titolo("le liste di attacchi, skill e oggetti vanno nella griglia")
	GameState.nuova_partita()
	var radice := Control.new()
	radice.size = Vector2(1280, 720)
	add_child(radice)
	var plancia := PlanciaCombattimento.new()
	plancia.costruisci(radice)
	var finto := FintoScontro.new()
	finto.attaccante_corrente = {
		"id": GameState.id_protagonista,
		"aura": 99,
		"stati_attivi": {},
	}
	var menu := MenuCombattimento.new(finto)
	menu.collega(plancia.comandi, plancia.vesti_le_voci, plancia.pannello_per_menu)
	# con la sacca vuota OGGETTI mostrerebbe il solo "Indietro", e la prova
	# passerebbe senza aver mai visto un oggetto
	GameState.sacca.append("razione_del_circo")
	GameState.sacca.append("razione_del_circo")

	menu.principale()
	esigi(plancia.faccia_adesso == "comandi",
			"il menu principale non apre la faccia dei comandi")
	esigi(plancia.comandi.get_child_count() >= 5,
			"i comandi non sono finiti nella colonna verticale")
	esigi(plancia.griglia_lista.get_child_count() == 0,
			"i comandi sono finiti anche nella griglia")

	# le tre voci che una lista ce l'hanno. DIFESA e FUGA no: partono e basta
	# ognuna dice quante voci deve avere ALMENO: la sola "Indietro" non e' una
	# lista, e una prova che si accontenta di "c'e' qualcosa dentro" passerebbe
	# anche con la lista vuota
	for coppia in [["ATTACCHI", menu.bersagli, 3], ["SKILL", menu.abilita, 3],
			["OGGETTI", menu.oggetti, 2]]:
		menu.principale()
		var apri: Callable = coppia[1]
		apri.call()
		esigi(plancia.faccia_adesso == "lista",
				"premendo %s il quadrante non passa alla faccia della lista" % coppia[0])
		esigi(plancia.griglia_lista.get_child_count() >= int(coppia[2]),
				"la lista di %s ha %d voci invece di %d" % [coppia[0],
						plancia.griglia_lista.get_child_count(), int(coppia[2])])
		esigi(plancia.comandi.get_child_count() == 0,
				"premendo %s la colonna dei comandi non e' stata svuotata: le vecchie voci restano sotto" % coppia[0])

	# e la griglia non sta su una colonna sola se le voci sono tante
	for quante in [1, 7, 15]:
		menu.principale()
		menu.bersagli()
		menu.svuota(plancia.griglia_lista)
		for i in quante:
			var finta := Button.new()
			finta.text = "voce"
			plancia.griglia_lista.add_child(finta)
		plancia.adatta_lista()
		var colonne := plancia.colonne_lista
		var righe := int(ceil(float(quante) / float(colonne)))
		esigi(righe <= PlanciaCombattimento.RIGHE_LISTA,
				"con %d voci la griglia fa %d righe su %d colonne: esce dal pannello"
				% [quante, righe, colonne])
		esigi(colonne <= 3,
				"con %d voci la griglia fa %d colonne: il pannello e' largo per tre"
				% [quante, colonne])

	# LA LISTA NON PASSA SOTTO MATTANZA E BOND.
	#
	# I due tasselli stanno sopra tutte le facce - e' voluto, sono l'unico avviso
	# che arriva mentre scegli. "Sopra" pero' voleva dire anche sopra le voci: la
	# griglia si prendeva tutto il pannello, e con SKILL l'ultima voce - che e'
	# "Indietro", l'unico modo di uscire dalla lista - finiva sotto un tassello
	# nero. Non si leggeva e non si cliccava. Lo ha trovato uno scatto, non una
	# prova: questa e' la prova che mancava.
	menu.principale()
	menu.abilita()
	# si misura VOCE PER VOCE, non il rettangolo della lista: e' la voce che
	# finisce sotto il tassello, e una lista che dichiara di essere alta 122
	# pixel puo' benissimo avere l'ultima riga a 240
	var tetto_tasselli: float = minf(plancia.tasto_mattanza.position.y,
			plancia.tasto_bond.position.y)
	voci_sovrapposte(plancia, "la lista di SKILL")
	for voce in plancia.griglia_lista.get_children():
		var fondo: float = plancia.griglia_lista.position.y + voce.position.y + voce.size.y
		esigi(fondo <= tetto_tasselli,
				"la voce \"%s\" arriva a %d e i tasselli cominciano a %d: ci finisce sotto"
				% [voce.text, int(fondo), int(tetto_tasselli)])

	# E CI STA DAVVERO, con tutte le abilita' che un personaggio puo' imparare.
	# Il numero non lo decido io: lo contano le classi giocabili. Se un giorno
	# una impara la ventesima mossa, questa prova lo dice prima che la lista
	# esca dal pannello.
	var massimo := 0
	var piu_carica := ""
	for id_classe in GameState.classi:
		var quante_voci := 2   # "Studia" e "Indietro" ci sono sempre
		for id_abilita in GameState.abilita_usabili(String(id_classe)):
			if not GameState.abilita_combattimento(String(id_abilita)).is_empty():
				quante_voci += 1
		quante_voci += GameState.attacchi_arma(String(id_classe)).size()
		if quante_voci > massimo:
			massimo = quante_voci
			piu_carica = String(id_classe)
	esigi(massimo <= 3 * PlanciaCombattimento.RIGHE_LISTA,
			"%s arriva a %d voci di SKILL: la griglia ne tiene %d e il resto esce dal pannello"
			% [piu_carica, massimo, 3 * PlanciaCombattimento.RIGHE_LISTA])

	# UNA LISTA PIU' LUNGA DI QUELLO CHE CI STA NON PERDE PEZZI.
	#
	# La sacca tiene venti scomparti e i consumabili del gioco sono ventinove:
	# con la borsa piena la lista degli oggetti e' piu' lunga del quadrante. Se
	# le ultime voci vengono semplicemente tagliate, quegli oggetti in
	# combattimento NON ESISTONO - e non c'e' niente a schermo che lo dica.
	menu.principale()
	menu.bersagli()
	menu.svuota(plancia.griglia_lista)
	for i in 25:
		var lunga := Button.new()
		lunga.text = "voce %d" % i
		plancia.griglia_lista.add_child(lunga)
	plancia.pagina_lista = 0
	plancia.adatta_lista()
	esigi(plancia.tasto_altro != null and plancia.tasto_altro.visible,
			"con 25 voci non compare nessun modo di arrivare alle ultime")
	var viste := {}
	for giro in 12:
		for v in plancia.griglia_lista.get_children():
			if not v.visible:
				continue
			viste[v.text] = true
			var giu: float = plancia.griglia_lista.position.y + v.position.y + v.size.y
			esigi(giu <= tetto_tasselli,
					"a pagina %d la voce \"%s\" arriva a %d: sotto i tasselli"
					% [plancia.pagina_lista, v.text, int(giu)])
		voci_sovrapposte(plancia, "pagina %d di una lista da 25" % plancia.pagina_lista)
		var fondo_altro: float = plancia.tasto_altro.position.y + plancia.tasto_altro.size.y
		esigi(fondo_altro <= tetto_tasselli,
				"il tasto per voltare pagina arriva a %d: sotto i tasselli" % int(fondo_altro))
		plancia.pagina_lista += 1
		plancia.adatta_lista()
	esigi(viste.size() == 25,
			"girando le pagine si vedono %d voci su 25: le altre sono sparite" % viste.size())

	# E LA COLONNA DEI COMANDI STA DENTRO IL PANNELLO.
	#
	# Stesso difetto della lista, dall'altra parte del quadrante: la colonna
	# partiva sotto il bordo di sopra e finiva ESATTAMENTE sul bordo di sotto,
	# quindi FUGA - l'ultima voce - restava tagliata a meta' dal bordo nero. Lo
	# ha visto uno scatto. Le sette voci sono il caso peggiore: alle cinque
	# fisse si aggiungono Aiutante e Mediazione quando ci sono.
	for quante_voci in [5, 7]:
		menu.principale()
		while plancia.comandi.get_child_count() < quante_voci:
			var extra := Button.new()
			extra.text = "Aiutante"
			plancia.comandi.add_child(extra)
		plancia.adatta_comandi()
		var interno: float = plancia.interno_di(plancia.quadrante).size.y
		var giu_comandi: float = plancia.comandi.position.y \
				+ plancia.comandi.get_combined_minimum_size().y
		esigi(giu_comandi <= interno,
				"con %d comandi la colonna arriva a %d dentro un pannello alto %d: l'ultima voce resta tagliata"
				% [quante_voci, int(giu_comandi), int(interno)])

	# "Indietro" riporta ai comandi, e la griglia resta pulita
	menu.principale()
	esigi(plancia.faccia_adesso == "comandi",
			"tornando indietro il quadrante resta sulla lista")
	esigi(plancia.griglia_lista.get_child_count() == 0,
			"tornando ai comandi la griglia resta piena")
	radice.free()

class FintoBox extends Control:
	# UN BOX CHE NON DISEGNA NIENTE E SI RICORDA TUTTO. Serve a chiedere una cosa
	# sola: quali battute sono arrivate a schermo, e quante volte.
	var mostrate: Array[String] = []
	# QUANDO e' arrivata ognuna. Contare le battute non basta: il danno di due
	# svuotamenti in parallelo non e' che se ne perdano, e' che la seconda copra
	# la prima PRIMA CHE SIA STATA LETTA. Quello si vede solo nel tempo.
	var quando: Array[int] = []
	var sta_scrivendo := false
	# una battuta e' sempre una pagina sola: qui non si misura niente
	var pagine: Array[String] = []
	var pagina := 0

	func mostra(_tipo: String, contenuto: String, _chi: String) -> void:
		mostrate.append(contenuto)
		quando.append(Time.get_ticks_msec())
		pagine = [contenuto]
		pagina = 0

	func pagina_seguente() -> bool:
		return false

	func nascondi_indicatore() -> void:
		pass

	func completa() -> void:
		sta_scrivendo = false

class FintoScontro extends RefCounted:
	# IL MINIMO CHE IL MENU CHIEDE AL COMBATTIMENTO, e niente di piu'.
	#
	# Il menu e' una vista sullo scontro: gli domanda se tocca a te, se la
	# Mattanza e' accesa, chi e' vivo. Per provare DOVE finiscono le voci non
	# serve uno scontro vero - serve qualcuno che risponda a quelle domande.
	# Cosi' la prova misura il menu e la plancia, e non il tempo reale.
	var mattanza_attiva := false
	var in_corso := true
	var attaccante_corrente := {}
	var scelte: Array[Dictionary] = []

	func giocatore_pronto() -> bool:
		return true

	# si possono accendere dall'esterno: servono alla prova sulla voce in coda
	var passo_finto: Dictionary = {}
	var coda_finta := ""

	func passo_tutorial() -> Dictionary:
		return passo_finto

	func nome_azione_in_coda() -> String:
		return coda_finta

	func si_puo_saltare_la_lezione() -> bool:
		return false

	# la lezione ha gia' parlato? Di solito si' - le prove sul menu guardano
	# dove finiscono le voci - ma prova_non_si_puo_anticipare_la_lezione lo
	# spegne apposta, perche' e' proprio quella finestra che vuole misurare
	var spiegato := true

	func passo_gia_spiegato() -> bool:
		return spiegato

	func vivi(_amici: bool) -> Array[Dictionary]:
		# DUE, non uno: con un nemico solo in campo il menu salta la lista e
		# attacca subito («con un nemico solo non si chiede nemmeno quello»).
		# Una prova sulle liste che ne mette uno solo non vedrebbe mai una lista.
		return [{"nome": "Goblin"}, {"nome": "Slime"}]

	func alleati_disponibili() -> Array:
		return []

	func bersagli_mediabili() -> Array[Dictionary]:
		return []

	func leve_utilizzabili() -> Array[Dictionary]:
		return []

	func fuga_possibile() -> bool:
		return true

	func dominio_sufficiente(_chi: Dictionary, _dati: Dictionary) -> bool:
		return true

	func abilita_vuole_bersaglio(_id: String) -> bool:
		return false

	func agisci_ora(azione: Dictionary) -> void:
		scelte.append(azione)

func prova_la_raffica_si_para_anche_da_tastiera() -> void:
	# ERA L'UNICO PEZZO CHE PRETENDEVA UN MOUSE. I pugni sono bottoni, quindi in
	# teoria il Tab li raggiunge - ma cercare col Tab durante una raffica non e'
	# giocare, e' un'altra cosa. Adesso il tasto para, e sceglie da solo.
	#
	# QUALE sceglie e' la domanda vera, e la risposta e' l'unica che non tradisce
	# il giocatore: QUELLO CHE STA PER SCADERE. E' quello che punterebbe col
	# mouse - gli altri hanno ancora tempo.
	titolo("la raffica si para anche senza mouse")
	var raffica: Array[Dictionary] = [
		{"indice": 0, "istante": 0.0, "scade": 9.0, "parato": false, "x": 0.0, "y": 0.0},
		{"indice": 1, "istante": 0.0, "scade": 2.0, "parato": false, "x": 0.0, "y": 0.0},
		{"indice": 2, "istante": 5.0, "scade": 6.0, "parato": false, "x": 0.0, "y": 0.0},
	]
	# a 1s: il 2 non e' ancora arrivato, il piu' urgente fra 0 e 1 e' l'1
	esigi(Collisioni.piu_urgente(raffica, 1.0) == 1,
			"a tastiera para il pugno sbagliato: prende il %d invece di quello che scade prima"
			% Collisioni.piu_urgente(raffica, 1.0))
	# parato quello, resta il it 0
	raffica[1].parato = true
	esigi(Collisioni.piu_urgente(raffica, 1.0) == 0,
			"dopo aver parato il piu' urgente non passa al successivo")
	# A VUOTO NON PRENDE NIENTE. Un tasto premuto quando non c'e' niente da
	# parare non deve rubare un pugno che non e' ancora arrivato
	var vuota: Array[Dictionary] = [
		{"indice": 0, "istante": 5.0, "scade": 6.0, "parato": false, "x": 0.0, "y": 0.0},
	]
	esigi(Collisioni.piu_urgente(vuota, 1.0) == -1,
			"il tasto premuto a vuoto prende un pugno che non e' ancora arrivato")
	esigi(Collisioni.piu_urgente(vuota, 8.0) == -1,
			"il tasto prende un pugno gia' scaduto: la finestra non conta piu' niente")

func prova_la_lezione_si_salta_solo_a_chi_l_ha_gia_fatta() -> void:
	# CHI RIGIOCA NON E' PIU' UN PRINCIPIANTE. Su questo la ricerca e' concorde
	# e non dipende dal genere. Ma alla PRIMA volta non si offre: la lezione di
	# Veronica e' anche una scena, e saltarla la prima volta vuol dire saltare
	# un pezzo di storia, non un pezzo di manuale.
	#
	# E NON E' UN PULSANTE DI AIUTO. Andersen ha misurato che aggiungerne uno in
	# Refraction ha RIDOTTO i progressi del 12% e il tempo di gioco del 15%
	# (docs/fonti/chi2012-tutorial-complessita.pdf). Saltare e' un'altra cosa:
	# e' la stessa lezione, non piu' offerta a chi l'ha gia' avuta.
	titolo("«Salta la lezione» compare solo a chi l'allenamento l'ha gia' fatto")
	var com_era: bool = Impostazioni.allenamento_gia_fatto
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	scontro.in_corso = true
	scontro.tutorial = {"passi": [{"azione": "attacca"}], "finale": []}
	scontro.tutorial_passo = 0
	scontro.tutorial_finito = false

	# LA PRIMA VOLTA: NON SI OFFRE
	Impostazioni.allenamento_gia_fatto = false
	esigi(not scontro.si_puo_saltare_la_lezione(),
			"la lezione si puo' saltare alla prima partita: e' anche una scena, non solo un manuale")
	scontro.salta_la_lezione()
	esigi(not scontro.tutorial_finito,
			"salta_la_lezione ha funzionato lo stesso: il guardiano non guarda niente")

	# CHI L'HA GIA' FATTA: SI OFFRE
	Impostazioni.allenamento_gia_fatto = true
	esigi(scontro.si_puo_saltare_la_lezione(),
			"chi ha gia' fatto l'allenamento non puo' saltarlo: il motivo per cui esiste questa voce")

	# E FUORI DA UNA LEZIONE NON COMPARE MAI
	scontro.tutorial = {}
	esigi(not scontro.si_puo_saltare_la_lezione(),
			"«Salta la lezione» compare anche dove non c'e' nessuna lezione")

	Impostazioni.allenamento_gia_fatto = com_era
	scontro.in_corso = false
	scontro.voce.coda.clear()
	scontro.queue_free()
	await get_tree().process_frame

func prova_l_azione_in_attesa_si_vede_a_schermo() -> void:
	# LA PROVA CHE MANCAVA, e si vede da come e' andata.
	#
	# Bru, dopo aver provato: «non noto alcun cambiamento». Aveva ragione. Il
	# buffer dei comandi funzionava - 34.000 verifiche verdi - ma la riga che
	# dice cosa sta aspettando l'avevo messa DOPO il return del tutorial: cioe'
	# nell'unico combattimento che si gioca, non compariva mai.
	#
	# Nessuna prova se n'era accorta perche' tutte guardavano lo STATO
	# (intenzione.azione si riempie? parte al momento giusto?) e nessuna
	# guardava LO SCHERMO. Un comando tenuto da parte di nascosto non e' un
	# buffer: e' ritardo, che e' il difetto che volevo togliere.
	#
	# Questa preme dove fa male: costruisce il menu davvero e ci cerca dentro
	# la riga.
	titolo("l'azione che aspetta si vede nel menu, lezione o non lezione")
	GameState.nuova_partita()
	var radice := Control.new()
	radice.size = Vector2(1280, 720)
	add_child(radice)
	var plancia := PlanciaCombattimento.new()
	plancia.costruisci(radice)
	var finto := FintoScontro.new()
	finto.attaccante_corrente = {"id": GameState.id_protagonista, "aura": 99, "stati_attivi": {}}
	var menu := MenuCombattimento.new(finto)
	menu.collega(plancia.comandi, plancia.vesti_le_voci, plancia.pannello_per_menu)

	# 1. FUORI DALLA LEZIONE
	finto.coda_finta = "Difesa"
	menu.principale()
	esigi(menu_contiene(plancia.comandi, "Difesa"),
			"fuori dalla lezione l'azione in attesa non si vede nel menu")

	# 2. DENTRO LA LEZIONE - ed e' il caso che mi era sfuggito
	finto.passo_finto = {"azione": "attacca"}
	finto.coda_finta = "Attacco"
	menu.principale()
	esigi(menu_contiene(plancia.comandi, "Attacco"),
			"DURANTE LA LEZIONE l'azione in attesa non si vede: premi, non succede niente, e un secondo dopo parte da sola")

	# 3. e quando non c'e' niente in attesa, la riga non c'e'
	finto.coda_finta = ""
	menu.principale()
	esigi(not menu_contiene(plancia.comandi, "parte appena tocca a te"),
			"la riga dell'attesa resta a schermo anche senza niente in attesa")

	radice.queue_free()
	await get_tree().process_frame

func menu_contiene(dove: Control, pezzo: String) -> bool:
	if dove == null:
		return false
	for figlio in dove.get_children():
		if figlio is Button and String((figlio as Button).text).findn(pezzo) != -1:
			return true
	return false

func prova_nessuna_bandiera_letta_e_mai_scritta() -> void:
	# IL DIFETTO PIU' CARO DI TUTTA LA SESSIONE ERA UNA RIGA CHE NON C'ERA.
	#
	# `sta_facendo_leggere` era dichiarata in Voce.gd, LETTA in
	# Combattimento.fase_adesso per decidere se il mondo deve aspettare che si
	# legga, e MAI ASSEGNATA da nessuna parte: sempre falsa. Tutto il
	# sequenziatore delle fasi si appoggiava a una condizione morta, e il
	# risultato l'ha sentito Bru: «clicco su attacca o skill e non succede
	# niente, aspetto poco e riprovo, adesso si apre».
	#
	# Nessuna delle 34.000 verifiche poteva prenderlo, perche' guardavano tutte
	# il comportamento - e il comportamento era coerente con una bandiera
	# sempre spenta. Un controllo sul TESTO lo prende in un secondo.
	#
	# LA REGOLA, e i due modi in cui la prima versione sbagliava: si guardano
	# solo le variabili di CLASSE (dichiarate a inizio riga, non le locali
	# dentro una funzione), e si cerca chi le assegna in TUTTO il progetto, non
	# solo nel loro file - perche' "muto" e "tempo_reale" si accendono da fuori
	# apposta, e quello e' un uso giusto, non un difetto.
	titolo("nessuna bandiera di classe resta senza nessuno che la scriva")
	# SOLO IL GIOCO, NON LE PROVE. Qui avevo incluso anche Prove.gd, e il
	# controllo e' passato sopra al difetto che esisteva per davvero: le mie
	# prove scrivevano `scontro.voce.sta_facendo_leggere = false` a mano, quindi
	# la bandiera risultava "assegnata" mentre nel gioco non la toccava nessuno.
	# Una bandiera che solo i test scrivono e' morta dove conta.
	var tutto := ""
	for percorso in script_del_gioco():
		tutto += testo_script(percorso) + "\n"
	var righe_tutte := tutto.split("\n")
	for percorso in script_del_gioco():
		for riga in testo_script(percorso).split("\n"):
			var nuda := String(riga)
			if not nuda.begins_with("var "):
				continue   # indentata = locale di una funzione: non e' una bandiera
			if not (nuda.contains(":= false") or nuda.contains(":= true") \
					or nuda.contains(": bool")):
				continue
			var nome := nuda.trim_prefix("var ").get_slice(" ", 0) \
					.get_slice(":", 0).get_slice("=", 0).strip_edges()
			if nome == "" or nome.begins_with("_"):
				continue
			esigi(qualcuno_la_scrive(righe_tutte, nome),
					"%s: la bandiera '%s' non viene assegnata da NESSUNA parte dentro scripts/: chi la legge sta leggendo una costante (le prove non contano - una bandiera che solo i test scrivono e' morta dove conta)"
					% [percorso.get_file(), nome])

func qualcuno_la_scrive(righe: PackedStringArray, nome: String) -> bool:
	# un'assegnazione e' "nome =" o "qualcosa.nome =", e non "nome ==".
	# Le dichiarazioni non contano: quello e' il valore di partenza
	for riga in righe:
		var nuda := String(riga).strip_edges()
		if nuda == "" or nuda.begins_with("#") or nuda.begins_with("var ") \
				or nuda.begins_with("const "):
			continue
		var dove := nuda.find(nome + " =")
		while dove != -1:
			var dopo := nuda.substr(dove + nome.length() + 2, 1)
			var prima := "" if dove == 0 else nuda.substr(dove - 1, 1)
			var attaccata_a_altro := prima != "" and prima != "." and prima != "\t" \
					and prima != " " and prima != "(" and prima != ","
			if dopo != "=" and not attaccata_a_altro:
				return true
			dove = nuda.find(nome + " =", dove + 1)
	return false

func prova_il_guasto_dell_ecg_segue_la_vita() -> void:
	# «SE ROSSA DIAMOGLI UN EFFETTO PULSANTE ROSSO, TIPO CUORE CHE BATTE [...]
	# quando e' gialla attenuiamo gli effetti [...] metteremo solo un leggero
	# glitch, come se il computer si stesse rompendo» (Bru).
	#
	# Due stati, non una scala: il rosso e' il guasto, il giallo e' il
	# cedimento, il verde non fa niente. Un'interfaccia che glitcha quando stai
	# bene non racconta niente, fa rumore.
	titolo("il guasto dell'ecg c'e' in rosso, e' attenuato in giallo, non c'e' in verde")
	esigi(is_zero_approx(EcgCombattimento.forza_glitch(1.0)),
			"a vita piena l'ecg glitcha: non c'e' niente che si stia rompendo")
	esigi(is_zero_approx(EcgCombattimento.forza_glitch(0.0)),
			"a terra l'ecg glitcha: chi e' a terra fa una riga dritta e basta")
	var giallo := EcgCombattimento.forza_glitch(0.5)
	var rosso := EcgCombattimento.forza_glitch(0.1)
	esigi(giallo > 0.0, "in giallo non si rompe niente: Bru ne vuole un po'")
	esigi(rosso > giallo,
			"il rosso (%.2f) non e' peggio del giallo (%.2f): l'attenuazione non attenua niente"
			% [rosso, giallo])

	# IL BATTITO SOLO IN ROSSO. In giallo Bru chiede di attenuare, e attenuare
	# un battito vuol dire toglierlo: un cuore che pulsa poco non si legge come
	# "meno grave", si legge come un difetto
	esigi(EcgCombattimento.batte_il_cuore(0.1),
			"sotto la soglia rossa il cuore non batte: manca il pezzo piu' chiesto")
	esigi(not EcgCombattimento.batte_il_cuore(0.5),
			"il cuore batte anche in giallo: li' gli effetti vanno attenuati, non ripetuti")
	esigi(not EcgCombattimento.batte_il_cuore(1.0), "il cuore batte a vita piena")
	esigi(not EcgCombattimento.batte_il_cuore(0.0), "il cuore batte a chi e' a terra")

	# E LE SOGLIE SONO LE STESSE DEL COLORE, non due regole che possono divergere
	esigi(EcgCombattimento.forza_glitch(EcgCombattimento.QUOTA_ROSSA - 0.001)
			> EcgCombattimento.forza_glitch(EcgCombattimento.QUOTA_ROSSA),
			"la soglia del guasto non cade dove cade quella del colore rosso")
	esigi(is_zero_approx(EcgCombattimento.forza_glitch(EcgCombattimento.QUOTA_VERDE + 0.001)),
			"appena sopra la soglia verde l'ecg si rompe ancora")

func prova_la_vita_scende_animata_e_lascia_la_scia() -> void:
	# «QUANDO RICEVI DANNO LA LINEA CHE SCENDE DEVE ESSERE ANIMATA, stessa cosa
	# se si recupera hp» (Bru).
	#
	# Prima la barra si teleportava, e non e' solo brutto: e' informazione
	# persa. QUANTO hai perso non si vedeva da nessuna parte, si vedeva solo
	# dove sei arrivato. Adesso dietro la barra resta una scia - il pezzo che ti
	# hanno appena tolto - che si richiude dopo.
	#
	# E QUANTO() DEVE DIRE IL VALORE VERO, non quello che si sta ancora
	# disegnando: questa distinzione l'ha trovata una prova esistente, che
	# chiedeva «a inizio scontro la barra e' gia' piena?» e col valore animato
	# diceva di si'.
	titolo("la vita scende animata, e la scia dice quanto se n'e' andata")
	var slot := SlotCompagno.new()
	slot.size = Vector2(160, 300)
	add_child(slot)
	await get_tree().process_frame
	slot.abita("anonimo")

	# LA PRIMA VOLTA NON SI ANIMA: non c'e' nessun "prima" da raccontare
	slot.imposta_barra("hp", 1.0)
	esigi(is_equal_approx(slot.quanto("hp"), 1.0), "la barra non ha preso il valore di partenza")
	esigi(is_equal_approx(float(slot.quote.get("hp", -1.0)), 1.0),
			"alla prima impostazione la barra si anima: partirebbe da un valore che non e' mai esistito")

	# POI SI': il valore vero e' subito quello nuovo, il disegno ci arriva dopo
	var movimento_prima: bool = Impostazioni.movimento_ridotto
	Impostazioni.movimento_ridotto = false
	slot.imposta_barra("hp", 0.3)
	esigi(is_equal_approx(slot.quanto("hp"), 0.3),
			"quanto() non dice il valore impostato: chi lo chiede vuole la meta', non il fotogramma")
	esigi(float(slot.quote.get("hp", 0.0)) > 0.3,
			"il disegno e' gia' arrivato a destinazione: la discesa non si vede")
	# LA SCIA SI GUARDA DOPO QUALCHE FOTOGRAMMA, non nello stesso istante: e'
	# fatta apposta per restare INDIETRO, quindi nell'attimo del colpo sta
	# ancora esattamente dove sta la barra. Guardarla subito era chiedere di
	# vedere il ritardo prima che ci fosse un ritardo.
	for _i in 8:
		await get_tree().process_frame
	esigi(float(slot.scie.get("hp", 0.0)) > float(slot.quote.get("hp", 0.0)) + 0.01,
			"la scia non sporge dietro la barra (scia %.3f, barra %.3f): il pezzo perso non si vede da nessuna parte"
			% [float(slot.scie.get("hp", 0.0)), float(slot.quote.get("hp", 0.0))])

	# E CHI HA SCELTO "RIDUCI IL MOVIMENTO" NON VEDE MUOVERSI NIENTE
	Impostazioni.movimento_ridotto = true
	slot.imposta_barra("hp", 0.9)
	esigi(is_equal_approx(float(slot.quote.get("hp", 0.0)), 0.9),
			"con «riduci il movimento» la barra si anima lo stesso")
	Impostazioni.movimento_ridotto = movimento_prima
	slot.queue_free()
	await get_tree().process_frame

func prova_non_si_puo_anticipare_la_lezione() -> void:
	# «SONO STATO VELOCE E AVEVO GIA' APERTO SKILLS, ma solo perche' il dialogo
	# era in ritardo, mi ha permesso di cliccare subito su skills e anticipare
	# il tutorial» (Bru).
	#
	# chiudi_passo_tutorial fa avanzare l'indice SUBITO, appena finisci l'azione
	# richiesta. Le battute del passo nuovo pero' le scrive
	# introduci_passo_tutorial, che parte piu' tardi - quando torni pronto. In
	# mezzo passo_tutorial() risponde gia' col passo NUOVO: il menu accendeva e
	# faceva pulsare l'azione che Veronica non aveva ancora chiesto.
	titolo("finche' Veronica non ha parlato, il menu della lezione non offre niente")
	GameState.nuova_partita()
	var radice := Control.new()
	radice.size = Vector2(1280, 720)
	add_child(radice)
	var plancia := PlanciaCombattimento.new()
	plancia.costruisci(radice)
	var finto := FintoScontro.new()
	finto.attaccante_corrente = {"id": GameState.id_protagonista, "aura": 99, "stati_attivi": {}}
	finto.passo_finto = {"azione": "abilita"}
	var menu := MenuCombattimento.new(finto)
	menu.collega(plancia.comandi, plancia.vesti_le_voci, plancia.pannello_per_menu)

	# PRIMA che il passo sia stato annunciato: tutto spento, niente pulsa
	finto.spiegato = false
	menu.principale()
	esigi(tutte_spente(plancia.comandi),
			"la lezione non ha ancora parlato e il menu offre gia' qualcosa: si puo' anticipare")
	esigi(not menu_contiene(plancia.comandi, "▶"),
			"una voce pulsa prima che Veronica l'abbia chiesta")

	# DOPO: quello che chiede si accende e pulsa, il resto no
	finto.spiegato = true
	menu.principale()
	esigi(not tutte_spente(plancia.comandi),
			"la lezione ha parlato e il menu resta tutto spento: non si puo' piu' fare niente")
	esigi(menu_contiene(plancia.comandi, "▶"),
			"dopo l'annuncio nessuna voce pulsa: non si sa cosa chiede")

	radice.queue_free()
	await get_tree().process_frame

func tutte_spente(dove: Control) -> bool:
	if dove == null:
		return false
	var viste := 0
	for figlio in dove.get_children():
		if figlio is Button:
			viste += 1
			if not (figlio as Button).disabled:
				return false
	return viste > 0

# --- le Pianure di Redenna, dal goblin che mangia alla tartaruga -------------

var ricordo_scontro := {}   # quello che le strategie di queste prove si annotano

func dai_il_turno(scontro: Node, chi: Dictionary) -> void:
	# TOCCA A LUI, adesso: il turno dato a mano, come se la fila del giro fosse
	# arrivata a lui. La battuta la apre agisci_ora, come quando il turno ti
	# arriva per una strada che non passa da battuta_di
	scontro.turni.passa_a(chi)
	chi.battuta_aperta = false

func togli_il_turno(scontro: Node) -> void:
	# NON TOCCA A TE: e' il turno di qualcun altro, o sta passando
	scontro.turni.fine_turno()

func scontro_muto_contro(nemici: Array, regia: Dictionary, strategia: Callable, giri := 60) -> Node:
	# uno scontro intero senza schermo: in modalita' muta si gioca tutto dentro
	# add_child, e quando torna e' gia' finito
	GameState.prepara_combattimento(nemici, "", "", "", "", regia)
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	scontro.muto = true
	scontro.limite_giri = giri
	scontro.strategia = strategia
	add_child(scontro)
	return scontro

func nello_storico(pezzo: String) -> int:
	# dove sta, nello storico, la prima riga che contiene quel pezzo (-1: mai)
	for i in GameState.storico.size():
		if pezzo in String(GameState.storico[i].get("testo", "")):
			return i
	return -1

func prova_le_pianure_si_esplorano_fino_alla_tartaruga() -> void:
	# Bru, 24 settembre: «dopo aver parlato con la guida ci sarà l'opzione
	# addentrati nelle pianure» - e da li' il goblin che mangia, la pianura
	# tranquilla, lo slime, la caverna segreta, il masso con le fiale, il
	# bivio, l'orda di rane, la tartaruga. «Per ora completiamo fino a qui».
	titolo("le Pianure si esplorano come le ha scritte Bru, fino alla tartaruga")
	var dati := carica_eventi("res://data/events_tutorial.json")
	var nodi: Dictionary = dati.get("nodi", {})
	for id_nodo in ["inizio", "inizio_guida"]:
		var scelta: Dictionary = (nodi[id_nodo].get("scelte", [{}]) as Array)[0]
		esigi(String(scelta.get("testo", "")) == "Addentrati nelle pianure" and String(scelta.get("vai", "")) == "banchetto",
				"da '%s' non ci si addentra nelle pianure verso il goblin: %s" % [id_nodo, scelta])
	# LA STRADA, un passo per volta: ogni tappa deve portare alla successiva
	var strada := [["banchetto", "banchetto_vinto"], ["banchetto_vinto", "pianura"], ["pianura", "albero"],
			["albero", "albero_vinto"], ["albero_vinto", "caverna"], ["caverna", "caverna_fondo"],
			["caverna_fondo", "caverna_pietra"], ["caverna_pietra", "caverna"], ["albero_vinto", "masso"],
			["masso", "masso_fiale"], ["masso", "bivio"], ["bivio", "pozze"], ["bivio", "collina"],
			["pozze", "pozze_vinte"], ["pozze_vinte", "tartaruga"], ["tartaruga", "tartaruga_dopo"],
			["tartaruga_dopo", "convergenza"]]
	for tappa in strada:
		esigi(nodi.has(tappa[0]) and String(tappa[1]) in destinazioni_di(nodi[tappa[0]]),
				"da '%s' non si arriva a '%s'" % [tappa[0], tappa[1]])
	# CHI PARLA, dove Bru l'ha scritto: il goblin col suo nome, il «???»
	var sequenza: Array = nodi["banchetto"].get("sequenza", [])
	var chi_dice := {}
	for msg in sequenza:
		chi_dice[String(msg.get("testo", ""))] = String(msg.get("chi", ""))
	esigi(chi_dice.get("Gnarl... barf, crunch...", "") == "ignoto" and chi_dice.get("Gna?!", "") == "goblin_tipico",
			"il goblin del pasto non parla come nel testo di Bru: %s" % chi_dice)
	# LE DUE FIALE nel masso, una volta sola
	var fiale: Dictionary = {}
	for scelta in nodi["masso"].get("scelte", []):
		if String(scelta.get("vai", "")) == "masso_fiale":
			fiale = scelta
	esigi(fiale.get("oggetti", []) == ["fiala_hp", "fiala_hp"] and fiale.has("una_tantum"),
			"il masso non da' le due fiale, o le da' ogni volta: %s" % fiale)
	# LA PIETRA ADESSO LA TIENE IL GOBLIN DELLA CAVERNA, non la tartaruga
	esigi(String(GameState.drop_garantito_di("goblin_possessivo").get("oggetto", "")) == "pietra_quieta",
			"il goblin della caverna non lascia la Pietra Quieta")
	esigi(not GameState.mediazione_di("tartaruga_innocente").has("oggetto"),
			"la tartaruga lascia ancora la pietra: adesso la tiene il goblin della caverna")
	esigi(String(GameState.personaggi.get("tartaruga_innocente", {}).get("nome", "")) == "Tartaruga Gigante",
			"la tartaruga non si chiama come la chiama Bru")
	# L'ORDA E' DA CINQUE e annuncia le mosse
	var orda: Dictionary = GameState.personaggi.get("rana_folle", {}).get("orda", {})
	esigi(int(orda.get("componenti", 0)) == 5 and bool(orda.get("preannuncia", false)),
			"l'orda di rane non e' da cinque, o non annuncia le mosse: %s" % orda)

func prova_chi_tende_l_imboscata_muove_per_primo() -> void:
	# «inizia il combattimento col goblin che ha la precedenza, se i nemici
	# tendono imboscate o ti colgono di sorpresa hanno la precedenza come turno»
	# e, per lo slime, «la precedenza la ha chi ha la velocita' maggiore» (Bru)
	titolo("chi tende l'imboscata muove per primo; altrimenti il piu' veloce")
	var nodi: Dictionary = carica_eventi("res://data/events_tutorial.json").get("nodi", {})
	var regia: Dictionary = nodi["banchetto"]["combattimento_automatico"].get("regia", {})
	esigi(String(regia.get("precedenza", "")) == "nemici", "al goblin che mangia non va la precedenza: %s" % regia)
	for sorpresa in [true, false]:
		GameState.nuova_partita()
		GameState.imposta_seed(77)
		ricordo_scontro = {}
		var guarda_prima := func(sc, chi: Dictionary) -> Dictionary:
			if not ricordo_scontro.has("colpito_prima"):
				ricordo_scontro["colpito_prima"] = int(chi.hp) < int(chi.hp_max)
			return {"tipo": "attacca", "bersaglio": sc.vivi(false)[0]}
		var scontro := scontro_muto_contro(["goblin_tipico"], regia if sorpresa else {}, guarda_prima)
		esigi(bool(ricordo_scontro.get("colpito_prima", false)) == sorpresa,
				("colto di sorpresa, alla tua prima mossa il goblin non ti ha ancora toccato" if sorpresa
				else "senza imboscata il goblin, piu' lento, ti colpisce prima che tu possa muovere"))
		if sorpresa:
			# la Guida parla prima, e il battibecco arriva DOPO il suo colpo
			var spiega := nello_storico("il nemico ha la precedenza")
			var colpo := nello_storico("Goblin Tipico")
			var battibecco := nello_storico("Chi ti ha detto che potevi accenderti?")
			esigi(spiega >= 0 and battibecco > spiega, "la Guida non spiega la precedenza, o il battibecco arriva prima")
			esigi(nello_storico("Adesso non è il momento di parlare") > battibecco,
					"il battibecco non finisce con «Adesso non è il momento di parlare»")
			esigi(colpo >= 0, "nello storico non c'e' traccia del goblin")
		scontro.free()
	# E UN AGGUATO QUALUNQUE da' la precedenza a chi l'ha teso
	GameState.nuova_partita()
	var teso := IngressoNodo.tira_agguato("prova_agguato",
			{"agguato": {"probabilita": 1.0, "ripetibile": true, "gruppi": [["goblin_tipico"]]}})
	esigi(teso and String(GameState.regia_combattimento.get("precedenza", "")) == "nemici",
			"un agguato non da' la precedenza a chi l'ha teso")
	GameState.nuova_partita()
	esigi(GameState.regia_combattimento.is_empty(), "la regia di uno scontro sopravvive a una partita nuova")

func prova_l_orda_dice_cosa_sta_per_fare() -> void:
	# «nelle orde puoi osservare i comportamenti, prima di compiere la mossa e
	# che tu scelga cosa fare appare sempre un testo collegato alla mossa che
	# fara'» (Bru)
	titolo("l'orda annuncia la mossa prima di farla, e prima che tu scelga")
	GameState.nuova_partita()
	GameState.imposta_seed(31)
	ricordo_scontro = {"scelte": 0, "senza_annuncio": 0, "componenti": 0}
	var guarda_annuncio := func(sc, _chi: Dictionary) -> Dictionary:
		var orda: Dictionary = sc.vivi(false)[0]
		ricordo_scontro["scelte"] += 1
		ricordo_scontro["componenti"] = maxi(int(ricordo_scontro["componenti"]), int(orda.componenti_iniziali))
		var prossima: Dictionary = orda.get("mossa_in_carica", {})
		# e mentre scegli, l'annuncio sta scritto sulla sua scheda: nel box e'
		# gia' passato, ed e' adesso che serve
		if prossima.is_empty() or not String(prossima.get("testo_annuncio", "")) in sc.campo.dettagli_di(orda):
			ricordo_scontro["senza_annuncio"] += 1
		return {"tipo": "attacca", "bersaglio": orda}
	var scontro := scontro_muto_contro(["rana_folle"], {}, guarda_annuncio)
	esigi(int(ricordo_scontro["componenti"]) == 5, "l'orda di rane non e' da cinque: %d" % int(ricordo_scontro["componenti"]))
	esigi(int(ricordo_scontro["scelte"]) > 3 and int(ricordo_scontro["senza_annuncio"]) == 0,
			"%d volte su %d hai dovuto scegliere senza sapere cosa stava per fare l'orda, o senza leggerlo sulla sua scheda"
			% [int(ricordo_scontro["senza_annuncio"]), int(ricordo_scontro["scelte"])])
	var annuncio := nello_storico("gracchiare ferocemente")
	var assalto := nello_storico("ti saltano addosso da ogni parte")
	esigi(annuncio >= 0 and assalto > annuncio, "l'assalto delle rane arriva senza il gracidio che lo annuncia")
	esigi(bool(scontro.giocatore_ha_vinto), "a colpi normali, al livello 1, l'orda di rane non si batte")
	scontro.free()
	# e chi non lo dichiara non annuncia niente: gli zombi i testi non li hanno
	esigi(not bool(GameState.personaggi.get("zombie_cittadino", {}).get("orda", {}).get("preannuncia", false)),
			"gli zombi annunciano le mosse senza averne i testi")

func prova_l_onda_psichica_tira_per_ogni_componente() -> void:
	# «sull'orda fa per esempio 5 colpi siccome l'orda e' composta da 5 [...]
	# tot tentativi che possono fare critico missare o colpire normale» (Bru)
	titolo("l'onda psichica tira un colpo per ogni componente dell'orda")
	GameState.nuova_partita()
	var mie := GameState.abilita_usabili(GameState.id_protagonista)
	esigi("onda_psichica" in mie and "concentrazione" in mie,
			"al livello 1 non hai l'onda psichica e la concentrazione: %s" % [mie])
	var dati := GameState.abilita_combattimento("onda_psichica")
	var scontro := scontro_muto_contro(["rana_folle"], {}, func(_s, _c) -> Dictionary: return {"tipo": "difendi"}, 1)
	var eroe: Dictionary = scontro.combattenti[0]
	var orda: Dictionary = scontro.combattenti[1]
	scontro.in_corso = true
	for caso in [[0.0, 5], [1.0, 0]]:
		orda.hp = orda.hp_max
		orda.componenti = 5
		orda.colpi_incassati = 0
		var prova_dati := dati.duplicate()
		prova_dati["probabilita_mancare"] = caso[0]
		scontro.onda(eroe, prova_dati)
		esigi(int(orda.colpi_incassati) == int(caso[1]),
				"con %d%% di colpi a vuoto l'onda ne ha fatti arrivare %d invece di %d"
				% [int(float(caso[0]) * 100), int(orda.colpi_incassati), int(caso[1])])
	esigi(nello_storico("Su 5, 5 vanno a vuoto") >= 0, "i colpi a vuoto dell'onda non si dicono")
	scontro.free()
	# su un nemico solo, un tentativo solo: e' li' il freno
	GameState.nuova_partita()
	scontro = scontro_muto_contro(["goblin_tipico"], {}, func(_s, _c) -> Dictionary: return {"tipo": "difendi"}, 1)
	eroe = scontro.combattenti[0]
	var goblin: Dictionary = scontro.combattenti[1]
	scontro.in_corso = true
	goblin.hp = goblin.hp_max
	goblin.colpi_incassati = 0
	var sicura := dati.duplicate()
	sicura["probabilita_mancare"] = 0.0
	scontro.onda(eroe, sicura)
	esigi(int(goblin.colpi_incassati) == 1, "su un goblin solo l'onda ha tirato %d colpi" % int(goblin.colpi_incassati))
	scontro.free()

func prova_la_tua_battuta_si_apre_anche_dal_menu() -> void:
	# IL DIFETTO: col motore in tempo reale chi comandi tu non passava da
	# battuta_di, e con
	# lei saltava tutto quello che si paga a ogni battuta - i potenziamenti non
	# scadevano mai, il veleno non mordeva. Concentrazione l'ha fatto vedere:
	# «leggermente piu' attacco e difesa» per sempre non e' leggermente
	titolo("la tua battuta si apre anche quando agisci dal menu: Concentrazione scade")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	scontro.set_process(false)   # il mondo fermo: qui si guarda solo la clessidra
	await get_tree().process_frame
	scontro.in_corso = true
	var tu: Dictionary = scontro.combattente_comandato()
	var battute_prima := int(scontro.battute_del_giocatore)
	dai_il_turno(scontro, tu)
	scontro.agisci_ora({"tipo": "abilita", "id": "concentrazione"})
	var attacco_su := RegoleCombattimento.attacco_di(tu)
	esigi(not tu.buffs.is_empty(), "Concentrazione non ti ha dato niente")
	var turni := int(GameState.abilita_combattimento("concentrazione").get("turni", 4))
	for volta in turni:
		dai_il_turno(scontro, tu)
		scontro.agisci_ora({"tipo": "difendi"})
		if volta < turni - 2:
			esigi(not tu.buffs.is_empty(), "Concentrazione e' gia' finita dopo %d azioni" % (volta + 1))
	esigi(tu.buffs.is_empty(), "dopo %d tue azioni Concentrazione e' ancora su: le tue battute non scorrono" % turni)
	esigi(RegoleCombattimento.attacco_di(tu) < attacco_su, "scaduta la Concentrazione l'attacco non torna com'era")
	esigi(int(scontro.battute_del_giocatore) == battute_prima + turni + 1,
			"le tue battute dal menu non si contano: %d invece di %d"
			% [int(scontro.battute_del_giocatore) - battute_prima, turni + 1])
	scontro.queue_free()
	await get_tree().process_frame

func prova_nelle_pianure_non_si_scappa() -> void:
	# «in questo livello l'opzione fuga non deve funzionare se non contro
	# l'apparizione la guida ti ferma dicendo: hey, non vorrai mica scappare
	# dai tuoi primi combattimenti vero?» (Bru)
	titolo("nelle Pianure la Guida non ti lascia scappare, tranne dall'apparizione")
	var sempre_fuga := func(_s, _c) -> Dictionary: return {"tipo": "fuggi"}
	GameState.nuova_partita()
	GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
	GameState.imposta_seed(5)
	var scontro := scontro_muto_contro(["goblin_tipico"], {}, sempre_fuga, 12)
	esigi(not bool(scontro.giocatore_e_fuggito), "nelle Pianure si scappa da un goblin")
	esigi(nello_storico("non vorrai mica scappare") >= 0, "la Guida non dice niente mentre ti ferma")
	# E FERMARTI NON TI COSTA IL TURNO: premi FUGA, la Guida parla, e il turno
	# resta tuo
	scontro.in_corso = true
	scontro.strategia = Callable()   # adesso lo comandi tu: senza, "chi comandi" e' nessuno
	var tu: Dictionary = scontro.combattente_comandato()
	esigi(not tu.is_empty(), "nello scontro della prova non comandi nessuno: la prova non misurerebbe niente")
	dai_il_turno(scontro, tu)
	scontro.agisci_ora({"tipo": "fuggi"})
	esigi(scontro.puo_agire(tu) and bool(scontro.in_corso),
			"premendo FUGA nelle Pianure hai perso il turno (tocca ancora a te: %s), o sei scappato"
			% scontro.puo_agire(tu))
	scontro.free()
	GameState.nemici_combattimento = ["manifestazione_di_un_sogno"]
	var apparizione: Node = load("res://scenes/Combattimento.tscn").instantiate()
	apparizione.muto = true
	apparizione.limite_giri = 1
	apparizione.strategia = func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	add_child(apparizione)
	esigi(apparizione.regia.fuga_negata().is_empty(), "dall'apparizione la Guida non ti lascia scappare")
	apparizione.free()
	# fuori dalle Pianure la regola non vale
	GameState.nuova_partita()
	GameState.imposta_seed(5)
	scontro = scontro_muto_contro(["goblin_tipico"], {}, sempre_fuga, 30)
	esigi(bool(scontro.giocatore_e_fuggito), "fuori dalle Pianure non si scappa piu' da nessuna parte")
	scontro.free()
	GameState.nuova_partita()

func prova_il_bond_con_la_tartaruga() -> void:
	# «la tartaruga non potrai batterla siccome alza la difesa [...] adesso si
	# accende l'opzione bond, cliccandola il dialogo parte» (Bru)
	titolo("con la tartaruga si accende BOND, e premendolo la lasci andare")
	var nodi: Dictionary = carica_eventi("res://data/events_tutorial.json").get("nodi", {})
	var regia: Dictionary = nodi["tartaruga"]["combattimento_automatico"].get("regia", {})
	GameState.nuova_partita()
	GameState.imposta_seed(9)
	ricordo_scontro = {"mosse": 0, "mediabile_a": -1}
	var aspetta_il_bond := func(sc, _chi: Dictionary) -> Dictionary:
		ricordo_scontro["mosse"] += 1
		var tartaruga: Dictionary = sc.vivi(false)[0]
		if sc.mediabile(tartaruga):
			if int(ricordo_scontro["mediabile_a"]) < 0:
				ricordo_scontro["mediabile_a"] = int(ricordo_scontro["mosse"])
			return {"tipo": "media", "bersaglio": tartaruga}
		return {"tipo": "attacca", "bersaglio": tartaruga}
	var scontro := scontro_muto_contro(["tartaruga_innocente"], regia, aspetta_il_bond, 20)
	esigi(int(ricordo_scontro["mediabile_a"]) == 3,
			"BOND si accende alla mossa %d invece che dopo le tue prime due" % int(ricordo_scontro["mediabile_a"]))
	esigi(bool(scontro.giocatore_ha_vinto) and bool(scontro.combattenti[1].get("risparmiato", false)),
			"lasciandola andare lo scontro non finisce, o la tartaruga non risulta risparmiata")
	esigi(nello_storico("non noto ostilità da parte della tartaruga") >= 0 and nello_storico("era lì per puro caso") >= 0,
			"mancano le battute di Bru sulla tartaruga")
	esigi(not GameState.possiede_oggetto("pietra_quieta"), "la tartaruga lascia ancora la pietra")
	scontro.free()

func prova_bond_si_preme() -> void:
	# il tasto BOND c'era, disegnato, e non era collegato a niente
	titolo("il tasto BOND si accende e si preme")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["tartaruga_innocente"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	scontro.set_process(false)
	await get_tree().process_frame
	scontro.in_corso = true
	var bond: Button = scontro.plancia.tasto_bond
	scontro.aggiorna_pronto_giocatore()
	esigi(bond.disabled, "BOND e' acceso prima che ci sia qualcuno con cui legare")
	var tartaruga_ora: Dictionary = scontro.combattenti[1]
	tartaruga_ora.vuole_mediare = false   # la sera storta: la scena decide lo stesso
	scontro.lezione_in_corso = true       # la Guida sta ancora parlando
	scontro.regia.apri_il_bond()
	scontro.aggiorna_pronto_giocatore()
	esigi(not bond.disabled, "la scena apre il BOND ma il tiro della sera lo tiene spento")
	esigi(scontro.plancia.evidenziato != bond, "BOND pulsa mentre sta sotto il testo della Guida, dove non si vede")
	scontro.lezione_in_corso = false
	scontro.aggiorna_pronto_giocatore()
	esigi(scontro.plancia.evidenziato == bond, "finita la scena BOND si accende ma non pulsa: non ti dice di premerlo")
	dai_il_turno(scontro, scontro.combattente_comandato())
	bond.pressed.emit()
	var tartaruga: Dictionary = scontro.combattenti[1]
	esigi(bool(tartaruga.get("risparmiato", false)), "premendo BOND la tartaruga non viene lasciata andare")
	scontro.aggiorna_pronto_giocatore()
	esigi(scontro.plancia.evidenziato != bond, "a scontro finito BOND pulsa ancora")
	scontro.queue_free()
	await get_tree().process_frame

func prova_la_caverna_si_apre_guardando() -> void:
	# «se osservi la scena vedrai che dietro a dove guardava il blob, c'è una
	# piccola caverna altrimenti puoi proseguire, la caverna è un area
	# segreta» (Bru)
	titolo("la caverna segreta si apre solo a chi osserva la scena")
	var nodi: Dictionary = carica_eventi("res://data/events_tutorial.json").get("nodi", {})
	var dopo: Dictionary = nodi.get("albero_vinto", {})
	var nella_sequenza := false
	for msg in dopo.get("sequenza", []):
		nella_sequenza = nella_sequenza or String(msg.get("flag", "")) == "tut_caverna_vista"
	var nella_scena := false
	for msg in dopo.get("scena", []):
		nella_scena = nella_scena or String(msg.get("flag", "")) == "tut_caverna_vista"
	esigi(nella_scena and not nella_sequenza, "la caverna la scopre chi non ha guardato, o non la scopre nessuno")
	var entra: Dictionary = {}
	for scelta in dopo.get("scelte", []):
		if String(scelta.get("vai", "")) == "caverna":
			entra = scelta
	esigi(String(entra.get("richiede_flag", "")) == "tut_caverna_vista", "la scelta della caverna c'e' anche senza averla vista")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
	esigi(not corridoio_aperto("albero", "caverna"), "sulla mappa il corridoio della caverna c'e' prima di averla vista")
	GameState.imposta_flag("tut_caverna_vista")
	esigi(corridoio_aperto("albero", "caverna"), "vista la caverna, sulla mappa il corridoio non si apre")
	for stanza in GameState.mappa_zona.get("stanze", []):
		if String(stanza.get("id", "")) in ["caverna", "caverna_fondo"]:
			esigi(String(stanza.get("tipo", "")) == "segreta", "%s non e' segnata come area segreta" % stanza.id)
	GameState.nuova_partita()
	# e battere il goblin della caverna da' la pietra
	GameState.imposta_seed(3)
	var picchia := func(sc, _c) -> Dictionary: return {"tipo": "attacca", "bersaglio": sc.vivi(false)[0]}
	var scontro := scontro_muto_contro(["goblin_possessivo"], {}, picchia)
	esigi(bool(scontro.giocatore_ha_vinto) and GameState.possiede_oggetto("pietra_quieta"),
			"battuto il goblin della caverna, la Pietra Quieta non arriva")
	scontro.free()
	GameState.nuova_partita()

func corridoio_aperto(a: String, b: String) -> bool:
	for coppia in GameState.collegamenti_aperti():
		if a in coppia and b in coppia:
			return true
	return false

func prova_il_promontorio_come_lo_ha_scritto_bru() -> void:
	# Bru, 24 settembre: «sviluppiamo la scena sopra la collina». Una salita in
	# due tempi, una scelta che comunque fa scattare l'apparizione, e tre modi di
	# uscirne: la batti con la pietra, scappi (e allora il promontorio ti ferma
	# finche' la pietra non ce l'hai), o dormi per sempre.
	titolo("il promontorio va come l'ha scritto Bru: salita, apparizione, e le tre uscite")
	var nodi: Dictionary = carica_eventi("res://data/events_tutorial.json").get("nodi", {})
	# LA SALITA: «prosegui», poi due scelte che portano tutte e due all'apparizione
	esigi(destinazioni_di(nodi["collina"]).has("collina_cima"), "dalla salita non si prosegue verso la cima")
	var dalla_cima: Array[String] = []
	for scelta in nodi["collina_cima"].get("scelte", []):
		dalla_cima.append(String(scelta.get("vai", "")))
	esigi(dalla_cima.size() == 2 and dalla_cima.count("collina_apparizione") == 2,
			"in cima non ci sono le due scelte che fanno scattare comunque l'apparizione: %s" % [dalla_cima])
	for id_nodo in ["collina", "collina_cima", "collina_apparizione", "collina_riprova", "collina_ritorno"]:
		esigi(bool(nodi[id_nodo].get("senza_mappa", false)),
				"'%s' lascia aprire la mappa: e' la terza scelta, quella che non fa scattare niente" % id_nodo)
	# CHI PARLA: «???» prima di vedersi, poi lei col suo nome
	var chi_dice := {}
	for msg in nodi["collina_apparizione"].get("sequenza", []):
		chi_dice[String(msg.get("testo", ""))] = String(msg.get("chi", ""))
	esigi(chi_dice.get("Hm?", "") == "ignoto" and chi_dice.get("Hm.", "") == "ignoto",
			"i due «hm» non sono di una voce che ancora non si vede: %s" % chi_dice)
	esigi(chi_dice.get("Sei tu?", "") == "manifestazione_di_un_sogno" and chi_dice.get("Scappa. Presto!", "") == "guida",
			"l'apparizione non parla col suo nome, o la Guida non ti dice di scappare: %s" % chi_dice)
	# LE TRE USCITE, uguali per il primo scontro e per quello in cui ci riprovi
	for id_nodo in ["collina_apparizione", "collina_ritorno"]:
		var scontro: Dictionary = nodi[id_nodo].get("combattimento_automatico", {})
		esigi(scontro.get("nemici", []) == ["manifestazione_di_un_sogno"]
				and String(scontro.get("se_vinci", "")) == "dopo_collina"
				and String(scontro.get("se_fuggi", "")) == "collina_fuga"
				and String(scontro.get("se_perdi", "")) == "sconfitta_manifestazione",
				"'%s': lo scontro non esce dove deve: %s" % [id_nodo, scontro])
	var battuta_fuga: Dictionary = {}
	for scelta in nodi["collina_fuga"].get("scelte", []):
		if String(scelta.get("vai", "")) == "pozze":
			battuta_fuga = scelta
	esigi(String(nodi["collina_fuga"].get("stanza", "")) == "pozze" and not battuta_fuga.is_empty(),
			"scappando non ti ritrovi alle pozze, costretto ad attraversarle")
	esigi(String(nodi["collina_fuga"].get("flag", "")) == "tut_manifestazione_fuggita",
			"scappare non lo ricorda nessuno: il promontorio non ti fermera' mai")
	var vinta: Array = nodi["dopo_collina"].get("sequenza", [])
	esigi(not vinta.is_empty() and String(vinta[0].get("testo", "")) == "Cos'era quell'affare?!",
			"battuta l'apparizione, i dialoghi non sono quelli nuovi di Bru")
	esigi("convergenza" in destinazioni_di(nodi["dopo_collina"]), "dopo l'apparizione non si prosegue verso il goblin")

	# DOVE TI PORTA IL PROMONTORIO, a seconda di com'e' andata
	GameState.nuova_partita()
	GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
	GameState.nodo_corrente = "bivio"
	esigi(String(IngressoNodo.entra("collina").id) == "collina", "la prima volta non si sale sul promontorio")
	GameState.imposta_flag("tut_manifestazione_fuggita")
	for da_dove in ["bivio", "convergenza"]:
		GameState.nodo_corrente = da_dove
		var esito := IngressoNodo.entra("collina")
		esigi(String(esito.id) == "collina_negata" and GameState.nodo_corrente == da_dove
				and String(esito.stanza) == da_dove,
				"scappato e senza pietra, provando a salire da '%s' si finisce in '%s' con la stanza '%s'"
				% [da_dove, esito.id, GameState.nodo_corrente])
	esigi(not GameState.stanza_sbloccata("collina_negata"), "il rifiuto di salire e' finito sulla mappa come una stanza")
	GameState.imposta_flag("tut_pietra_presa")
	var riprova := IngressoNodo.entra("collina")
	esigi(String(riprova.id) == "collina_riprova" and GameState.nodo_corrente == "collina",
			"con la pietra non ci si riprova: si finisce in '%s'" % riprova.id)
	GameState.imposta_flag("tut_collina_fatta")
	esigi(String(IngressoNodo.entra("collina").id) == "collina_vuota", "battuta l'apparizione, la cima non e' vuota")
	GameState.nuova_partita()

func prova_l_apparizione_si_batte_solo_con_la_pietra() -> void:
	# «ti salvi solo con pietra», e «appena si avvicina la sconfitta» tre battute:
	# la Guida che ti dice di scappare, tu che non ci riesci, lei che tace
	titolo("l'apparizione: senza pietra dormi, con la pietra la batti, e prima parla la Guida")
	var nodi: Dictionary = carica_eventi("res://data/events_tutorial.json").get("nodi", {})
	var regia: Dictionary = nodi["collina_apparizione"]["combattimento_automatico"].get("regia", {})
	var aspetta := func(_s, _c) -> Dictionary: return {"tipo": "difendi"}
	for con_la_pietra in [false, true]:
		GameState.nuova_partita()
		GameState.imposta_seed(21)
		if con_la_pietra:
			GameState.aggiungi_oggetto("pietra_quieta")
		var scontro := scontro_muto_contro(["manifestazione_di_un_sogno"], regia, aspetta, 30)
		esigi(bool(scontro.giocatore_ha_vinto) == con_la_pietra and not bool(scontro.giocatore_e_fuggito),
				("con la pietra l'apparizione non si batte" if con_la_pietra
				else "senza pietra e senza scappare l'apparizione non ti addormenta"))
		var fine_vicina := nello_storico("Senti che la fine è vicina")
		var scappa := nello_storico("Non ce la puoi fare ora!")
		var non_posso := nello_storico("Non... posso...")
		var morfeo := nello_storico("ti ricorda una persona di un lontano passato")
		esigi(fine_vicina >= 0 and scappa > fine_vicina and non_posso > scappa and morfeo > non_posso,
				"le battute di quando la sconfitta si avvicina non stanno fra l'ultimo gesto e la Chiamata di Morfeo "
				+ "(gesto %d, Guida %d, tu %d, Morfeo %d)" % [fine_vicina, scappa, non_posso, morfeo])
		if con_la_pietra:
			esigi(nello_storico("si spacca in mille pezzi") > morfeo and nello_storico("vortice di rabbia") > morfeo,
					"con la pietra il sonno non si spezza, o lei non si disperde")
		scontro.free()
	# E SI PUO' SCAPPARE, ma non al primo tentativo: «non vuole lasciarti»
	var scappato := 0
	for seme in 8:
		GameState.nuova_partita()
		GameState.imposta_seed(100 + seme)
		var scontro := scontro_muto_contro(["manifestazione_di_un_sogno"], regia,
				func(_s, _c) -> Dictionary: return {"tipo": "fuggi"}, 30)
		esigi(nello_storico("non vuole lasciarti") >= 0, "il primo tentativo di fuga dall'apparizione riesce")
		if bool(scontro.giocatore_e_fuggito):
			scappato += 1
		scontro.free()
	esigi(scappato > 0, "in otto partite dall'apparizione non si e' mai riusciti a scappare")
	GameState.nuova_partita()

func prova_il_promontorio_non_ti_lascia_andare_e_poi_ti_ferma() -> void:
	# A SCHERMO. In cima la mappa non c'e', e nemmeno l'icona della Guida che la
	# riapre: «qualunque cosa scegli triggera l'apparizione». E dopo la fuga il
	# promontorio ti ferma dove sei - anche se ci provi dalla mappa - e «Torna
	# indietro» ti rimette li'
	titolo("in cima al promontorio non si esce dalla mappa; dopo la fuga ti ferma dove sei")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
	GameState.imposta_flag("guida_conosciuta")
	GameState.nodo_corrente = "bivio"
	IngressoNodo.ultimo_esito = IngressoNodo.entra("collina_cima")
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	schermata.aggiorna_dialoga()
	var icona: Button = null
	for figlio in schermata.get_node("Interfaccia").get_children():
		if figlio is IconaGuida:
			icona = figlio
	esigi(icona != null, "nelle Pianure l'icona della Guida non c'e': la prova non misurerebbe niente")
	if icona != null:
		icona.aggiorna()
		esigi(icona.disabled, "in cima al promontorio l'icona della Guida riapre la mappa, e dalla mappa si scappa")
	esigi(not schermata.bottone_mappa.visible, "in cima al promontorio c'e' il bottone della mappa")
	# e al bivio, che non trattiene nessuno, tutto torna com'era
	schermata.mostra_nodo("bivio")
	schermata.aggiorna_dialoga()
	esigi(schermata.bottone_mappa.visible, "al bivio la mappa non c'e' piu': la trattenuta del promontorio e' rimasta addosso")
	if icona != null:
		icona.aggiorna()
		esigi(not icona.disabled, "al bivio l'icona della Guida resta spenta")
	schermata.queue_free()
	await get_tree().process_frame

	# DOPO LA FUGA, DALLA MAPPA: da verso le urla ci provi, e resti verso le urla
	GameState.imposta_flag("tut_manifestazione_fuggita")
	GameState.nodo_corrente = "convergenza"
	var mappa: Control = load("res://scenes/MappaZona.tscn").instantiate()
	add_child(mappa)
	var transizione_prima: bool = Transizioni.in_corso
	Transizioni.in_corso = true   # la navigazione si mette in fila e non parte
	mappa._su_stanza("collina", true, true)
	Transizioni.prossima = ""
	Transizioni.in_corso = transizione_prima
	var esito: Dictionary = IngressoNodo.ultimo_esito
	esigi(String(esito.get("id", "")) == "collina_negata" and GameState.nodo_corrente == "convergenza",
			"provando a salire dalla mappa ti ritrovi in '%s', sul '%s'" % [esito.get("id", ""), GameState.nodo_corrente])
	mappa.queue_free()
	# e la schermata che nasce di li' mostra il rifiuto, e «Torna indietro» ti
	# rimette verso le urla
	schermata = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	esigi(schermata.nodo_in_corso == GameState.eventi["collina_negata"],
			"la schermata non mostra il promontorio che ti ferma")
	schermata.ricostruisci_scelte(schermata.nodo_in_corso)
	var indietro := cerca_bottone_con_testo(schermata.contenitore_scelte, "Torna indietro")
	esigi(indietro != null, "fermato sul promontorio non c'e' «Torna indietro»")
	if indietro != null:
		indietro.pressed.emit()
		esigi(schermata.nodo_in_corso == GameState.eventi["convergenza"] and GameState.nodo_corrente == "convergenza",
				"«Torna indietro» non ti rimette verso le urla, da dove ci avevi provato")
	schermata.queue_free()
	await get_tree().process_frame
	IngressoNodo.ultimo_esito = {}
	GameState.nuova_partita()

func prova_il_goblin_del_pasto_si_gioca_a_turni_dallo_schermo() -> void:
	# LO SCONTRO CHE BRU HA GIOCATO, GIOCATO DALLO SCHERMO. «Il goblin mi attacca
	# di continuo»: era questo, il goblin del pasto, con l'imboscata e la Guida
	# che parla. Qui si monta com'e' in partita e lo si gioca come un giocatore:
	# si clicca il testo per andare avanti, e quando tocca a te si clicca il
	# goblin. Deve finire, e in nessun giro il goblin deve muoversi due volte.
	#
	# LA MISURA E' PER GIRO, NON FRA DUE TUOI TURNI. La prima versione contava
	# le mosse del goblin fra un tuo turno e l'altro, e ne ha trovate due: alle
	# strette il goblin «smette di ragionare» e passa da velocita' 2 a 4, quindi
	# al giro dopo muove prima di te - tu, goblin | goblin, tu. E' giusto, ed e'
	# come va in ogni gioco a turni: la regola e' che nessuno agisce due volte
	# nello STESSO giro
	titolo("il goblin del pasto si gioca a turni dallo schermo, fino in fondo")
	var nodi: Dictionary = carica_eventi("res://data/events_tutorial.json").get("nodi", {})
	GameState.nuova_partita()
	GameState.imposta_seed(11)
	GameState.prepara_combattimento(["goblin_tipico"], "", "", "", "",
			nodi["banchetto"]["combattimento_automatico"].get("regia", {}))
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	var tu: Dictionary = scontro.combattente_comandato()
	var goblin: Dictionary = scontro.vivi(false)[0]
	var mosse: Array[String] = []   # "giro:chi", una per battuta, nell'ordine in cui arrivano
	var tue := 0
	var sue := 0
	var scadenza: int = Time.get_ticks_msec() + 60000
	while scontro.in_corso and Time.get_ticks_msec() < scadenza:
		if int(goblin.get("battute", 0)) != sue:
			sue = int(goblin.get("battute", 0))
			mosse.append("%d:goblin" % scontro.turni.giro)
		if int(tu.get("battute", 0)) != tue:
			tue = int(tu.get("battute", 0))
			mosse.append("%d:tu" % scontro.turni.giro)
		if scontro.area_avanza.visible:
			scontro.voce.avanza()   # il clic che fa andare avanti il testo
		elif scontro.puo_agire(tu) and scontro.fase_adesso() == "comandi":
			scontro._su_click_nemico(goblin)   # tocca a te: si clicca il goblin
		await get_tree().process_frame
	esigi(not scontro.in_corso, "in un minuto lo scontro col goblin del pasto non e' finito: i turni si sono piantati")
	esigi(not mosse.is_empty() and mosse[0].ends_with("goblin"),
			"c'era l'imboscata e il primo a muovere non e' stato il goblin: %s" % [mosse.slice(0, 3)])
	esigi(tue >= 3, "hai avuto il turno solo %d volte" % tue)
	var doppie: Array[String] = []
	for k in mosse.size():
		if mosse.find(mosse[k]) != k:
			doppie.append(mosse[k])
	esigi(doppie.is_empty(), "nello stesso giro si e' mosso due volte: %s (%s)" % [doppie, mosse])
	scontro.queue_free()
	await get_tree().process_frame
	GameState.nuova_partita()

func prova_la_guida_ferma_il_mondo_mentre_parla() -> void:
	# NELLA PARTITA VERA la Guida parla come Veronica: il mondo sta fermo e si
	# va avanti col click. Le prove dello scontro girano mute, dove il tempo non
	# si ferma mai; questa guarda lo scontro vero, quello con lo schermo
	titolo("mentre la Guida parla, nello scontro vero il mondo e' fermo")
	var nodi: Dictionary = carica_eventi("res://data/events_tutorial.json").get("nodi", {})
	GameState.nuova_partita()
	GameState.prepara_combattimento(["goblin_tipico"], "", "", "", "",
			nodi["banchetto"]["combattimento_automatico"].get("regia", {}))
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	esigi(bool(scontro.lezione_in_corso) and not scontro.il_tempo_scorre(),
			"la Guida parla e intanto il goblin puo' gia' muoversi")
	esigi(bool(scontro.voce.attende_il_click), "le battute della Guida scorrono da sole invece di aspettare il click")
	# si legge tutto, e il mondo riparte da solo. Si guarda il goblin e non il
	# tempo: con l'imboscata il turno e' suo, lo prende nel fotogramma dopo
	# l'ultima riga, e subito la Guida torna a parlare («Ti sei fatto
	# fregare!») e il tempo si ferma di nuovo - com'e' giusto
	var goblin: Dictionary = scontro.vivi(false)[0]
	var giri := 0
	while giri < 600 and int(goblin.get("battute", 0)) == 0:
		scontro.voce.salta_messaggio = true
		await get_tree().process_frame
		giri += 1
	esigi(int(goblin.get("battute", 0)) >= 1,
			"finite le battute della Guida il mondo resta fermo: il goblin non prende mai il suo turno")
	scontro.queue_free()
	await get_tree().process_frame
	GameState.nuova_partita()

func prova_osservando_la_scena_si_trova_la_caverna() -> void:
	# LA STESSA COSA, PREMUTA DAVVERO: dopo lo slime, all'albero, la caverna
	# non c'e'; si preme «Osserva la scena», e la scelta per entrarci compare
	titolo("premendo «Osserva la scena» all'albero compare la caverna")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
	GameState.nodo_corrente = "albero_vinto"
	IngressoNodo.ultimo_esito = {}
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	var giri := 0
	while giri < 60 and not schermata.coda_messaggi.is_empty():
		schermata.avanza_messaggio()
		giri += 1
	schermata._apri_scelte()
	await get_tree().process_frame
	esigi(bottone_che_dice(schermata.contenitore_scelte, "Prosegui") != null,
			"all'albero, dopo lo slime, non si puo' proseguire")
	esigi(bottone_che_dice(schermata.contenitore_scelte, "Entra nella piccola caverna") == null,
			"la caverna si vede senza aver guardato: non e' piu' un'area segreta")
	schermata._su_osserva()
	giri = 0
	while giri < 20 and not schermata.coda_messaggi.is_empty():
		schermata.avanza_messaggio()
		giri += 1
	schermata.avanza_messaggio()
	schermata._apri_scelte()
	await get_tree().process_frame
	esigi(GameState.ha_flag("tut_caverna_vista"), "osservata la scena, il gioco non sa che hai visto la caverna")
	esigi(bottone_che_dice(schermata.contenitore_scelte, "Entra nella piccola caverna") != null,
			"osservata la scena, la scelta per entrare nella caverna non compare")
	schermata.queue_free()
	await get_tree().process_frame
	GameState.nuova_partita()

func bottone_che_dice(radice: Node, pezzo: String) -> Button:
	# come cerca_bottone_con_testo, ma la scelta col fuoco porta un pallino
	# davanti («•  Prosegui»): qui conta cosa dice, non come e' vestita
	for figlio in radice.get_children():
		if figlio is Button and pezzo in (figlio as Button).text:
			return figlio
		var dentro := bottone_che_dice(figlio, pezzo)
		if dentro != null:
			return dentro
	return null

# --- IL GOBLIN ARRABBIATO: la mazzata, i suoi goblin, e quanto dura -----------

func mossa_di(id_creatura: String, tipo: String) -> Dictionary:
	for mossa in GameState.personaggi.get(id_creatura, {}).get("mosse", []):
		if String((mossa as Dictionary).get("tipo", "")) == tipo:
			return mossa
	return {}

func esito_del_contrasto(al_secondo: float) -> Dictionary:
	# un contrasto muto giocato da una mano che preme "al_secondo" volte al
	# secondo: si gioca tutto dentro avvia(), e il segnale arriva subito
	var contrasto := ContrastoCombattimento.new(true)
	var arrivati: Array[Dictionary] = []
	contrasto.finito.connect(func(esito: Dictionary) -> void: arrivati.append(esito))
	contrasto.avvia({}, al_secondo)
	return arrivati[0] if arrivati.size() == 1 else {}

func prova_il_contrasto_si_vince_premendo() -> void:
	# Bru: «devi premere a raffica la barra spaziatrice per combattere, se ti
	# batte passa un colpo pesante, altrimenti lo pari e subisci pochissimi danni
	# a seconda di quanto ci hai messo». Tre cose da tenere: chi non preme perde,
	# chi preme abbastanza vince, e chi preme piu' svelto vince prima e paga meno
	titolo("la mazzata si respinge premendo: piu' svelto, prima e meno male")
	var nessuna := esito_del_contrasto(-1.0)
	var lenta := esito_del_contrasto(2.0)
	var tre := esito_del_contrasto(3.0)
	var media := esito_del_contrasto(5.0)
	var svelta := esito_del_contrasto(8.0)
	for esito: Dictionary in [nessuna, lenta, media, svelta]:
		esigi(not esito.is_empty(), "un contrasto si e' giocato senza dire com'e' finito")
	esigi(not bool(nessuna.get("vinto", true)), "senza premere niente la mazza e' stata respinta lo stesso")
	esigi(not bool(lenta.get("vinto", true)),
			"due pressioni al secondo bastano a respingerla: non e' piu' una raffica")
	# LA MAZZA SI FA PIU' PESANTE. A tre pressioni al secondo contro una spinta
	# fissa si vincerebbe in poco piu' di tre secondi; e' il rincaro a fare la
	# soglia (~3,5 al secondo) e a premiare chi comincia subito
	esigi(not bool(tre.get("vinto", true)),
			"tre pressioni al secondo bastano: la spinta del goblin non cresce piu'")
	esigi(bool(media.get("vinto", false)),
			"cinque pressioni al secondo non bastano: e' piu' difficile di quanto ha chiesto Bru")
	esigi(bool(svelta.get("vinto", false)), "otto pressioni al secondo non bastano a respingerla")
	esigi(float(svelta.get("secondi", 99.0)) < float(media.get("secondi", 0.0)),
			"premendo piu' svelto non si vince prima (%.2f contro %.2f secondi)"
			% [float(svelta.get("secondi", 0.0)), float(media.get("secondi", 0.0))])
	var mossa := mossa_di("goblin_arrabbiato", "mazzata")
	esigi(not mossa.is_empty(), "il goblin arrabbiato non ha piu' la sua Mazzata")
	esigi(MazzataCombattimento.danno_parato(mossa, float(svelta.get("quota", 1.0)))
			< MazzataCombattimento.danno_parato(mossa, float(nessuna.get("quota", 1.0))),
			"chi la respinge subito paga quanto chi ci mette tutto il tempo")
	# e ogni contrasto finisce: al piu' dopo la reazione e la durata concessa
	var tetto := ContrastoCombattimento.REAZIONE \
			+ float(GameState.regole.get("contrasto", {}).get("durata", 5.0)) + 0.05
	esigi(float(nessuna.get("secondi", 99.0)) <= tetto,
			"il contrasto e' durato %.2f secondi: doveva chiudersi entro %.2f"
			% [float(nessuna.get("secondi", 0.0)), tetto])

func attacca_il_primo(scontro, _chi: Dictionary) -> Dictionary:
	var nemici: Array[Dictionary] = scontro.vivi(false)
	return {"tipo": "difendi"} if nemici.is_empty() else {"tipo": "attacca", "bersaglio": nemici[0]}

func una_mazzata_con_la_mano(mano: float) -> int:
	# quanto toglie UNA mazzata, a vita piena, con una mano che preme "mano"
	# volte al secondo. Lo scontro muto si gioca una battuta e si ferma; poi si
	# rimette il protagonista com'era e gli si cala addosso la mazza
	var regole: Dictionary = GameState.regole["contrasto"]
	var di_serie := float(regole.get("mano_automatica", 5.0))
	regole["mano_automatica"] = mano
	GameState.nuova_partita()
	GameState.imposta_seed(7)
	var scontro := scontro_muto_contro(["goblin_arrabbiato"], {}, Callable(self, "attacca_il_primo"), 1)
	scontro.in_corso = true
	var tu: Dictionary = scontro.vivi(true)[0]
	tu.hp = tu.hp_max
	tu.scatti_difesa = 0
	tu.buffs = []
	var goblin: Dictionary = scontro.vivi(false)[0]
	scontro.esegui_mossa(goblin, mossa_di("goblin_arrabbiato", "mazzata"))
	var tolto := int(tu.hp_max) - int(tu.hp)
	scontro.free()
	regole["mano_automatica"] = di_serie
	return tolto

func prova_la_mazzata_pesa_come_ha_detto_bru() -> void:
	titolo("la mazzata respinta passa appena, quella che ti batte e' un colpo pesante")
	var mossa := mossa_di("goblin_arrabbiato", "mazzata")
	var forbice: Array = mossa.get("danno_parato", [1, 5])
	var parata := una_mazzata_con_la_mano(8.0)
	esigi(nello_storico(String(mossa.get("testo_parata", "?"))) >= 0,
			"respinta la mazza, il box non dice che l'hai parata")
	esigi(parata >= int(forbice[0]) and parata <= int(forbice[1]),
			"respinta la mazza ne sono passati %d: dovevano essere fra %d e %d"
			% [parata, int(forbice[0]), int(forbice[1])])
	var piena := una_mazzata_con_la_mano(-1.0)
	esigi(nello_storico(String(mossa.get("testo_colpo", "?"))) >= 0,
			"la mazza ti batte e il box non lo dice")
	# «un colpo pesante»: almeno il doppio di quanto passa respingendola al
	# peggio, e almeno il triplo di un suo colpo normale
	var normale := GameState.stat_nemico("goblin_arrabbiato", "attacco")
	esigi(piena >= 2 * int(forbice[1]) and piena >= 3 * normale,
			"la mazza che ti batte toglie %d: non e' un colpo pesante (parata al peggio %d, colpo normale %d)"
			% [piena, int(forbice[1]), normale])
	GameState.nuova_partita()

func prova_la_mazzata_dal_vivo_si_prende_la_barra_spaziatrice() -> void:
	# NELLA PARTITA VERA: la riga che la annuncia si legge, poi il riquadro si
	# prende il quadrante, il mondo si ferma, e SPAZIO spinge - anche con la
	# Mattanza accesa, che col suo SPAZIO pesterebbe il goblin invece di parare
	titolo("dal vivo la mazzata ferma il mondo, e SPAZIO spinge la mazza")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_arrabbiato"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	var giri := 0
	while giri < 400 and (not scontro.voce.coda.is_empty() or scontro.voce.sta_facendo_leggere or not scontro.scontro_avviato):
		scontro.voce.salta_messaggio = true
		await get_tree().process_frame
		giri += 1
	var goblin: Dictionary = scontro.vivi(false)[0]
	var tu: Dictionary = scontro.combattente_comandato()
	goblin.hp_max = 1000000
	goblin.hp = 1000000
	tu.hp = tu.hp_max
	var fermo_prima: int = scontro.tempo_fermo
	scontro.mossa_mazzata(goblin, mossa_di("goblin_arrabbiato", "mazzata"))
	giri = 0
	while giri < 400 and not scontro.mazzata.in_corso():
		scontro.voce.salta_messaggio = true
		await get_tree().process_frame
		giri += 1
	esigi(scontro.mazzata.in_corso(), "la mazzata e' partita e il contrasto non e' mai comparso")
	esigi(scontro.fase_adesso() == "minigioco",
			"sotto la mazza lo scontro e' in fase '%s' invece che nel minigioco" % scontro.fase_adesso())
	esigi(not scontro.il_tempo_scorre(), "mentre la mazza spinge il mondo va avanti")
	var riquadro: Control = scontro.mazzata.contrasto.riquadro
	esigi(riquadro != null and riquadro.is_visible_in_tree(), "il riquadro della mazzata non si vede")
	# la Mattanza accesa: SPAZIO e' della mazza, e il goblin non perde niente
	tu.dominio = RegoleCombattimento.dominio_pieno()
	scontro.usa_abilita_su(tu, "mattanza", goblin)
	var vita_goblin := int(goblin.hp)
	var spazio := InputEventKey.new()
	spazio.keycode = KEY_SPACE
	spazio.physical_keycode = KEY_SPACE
	spazio.pressed = true
	var prima: int = scontro.mazzata.contrasto.pressioni
	for volta in 3:
		scontro._unhandled_input(spazio)
	esigi(int(scontro.mazzata.contrasto.pressioni) == prima + 3,
			"tre SPAZIO sotto la mazza ne hanno spinte %d" % (int(scontro.mazzata.contrasto.pressioni) - prima))
	esigi(int(goblin.hp) == vita_goblin, "sotto la mazza SPAZIO e' andato alla Mattanza")
	scontro.chiudi_mattanza()
	# si finisce premendo: respinta, poco danno, e il mondo riparte
	giri = 0
	while giri < 600 and scontro.mazzata.in_corso():
		scontro._unhandled_input(spazio)
		await get_tree().process_frame
		giri += 1
	var tolto := int(tu.hp_max) - int(tu.hp)
	esigi(not scontro.mazzata.in_corso(), "premendo a raffica la mazzata non si chiude")
	esigi(int(scontro.tempo_fermo) == fermo_prima,
			"finita la mazzata il mondo resta fermo (tempo fermo %d, prima %d)"
			% [int(scontro.tempo_fermo), fermo_prima])
	esigi(tolto >= 1 and tolto <= 5, "respinta la mazza ne sono passati %d: dovevano essere pochissimi" % tolto)
	scontro.queue_free()
	await get_tree().process_frame
	GameState.nuova_partita()

func prova_gli_evocati_hanno_un_quadratino_loro() -> void:
	# Bru: «in basso a sinistra dentro il riquadro del boss [...] dei piccoli
	# quadrati 1:1 con la pic dei nemici comuni, ne puo' evocare massimo due».
	# Prima i goblin chiamati finivano DENTRO il riquadro del boss, col loro nome
	# sulla sua fascia; e la loro "scheda" era il suo pannello, quindi quando
	# cadevano sfumava via lui
	titolo("chi chiama il boss sta in un quadratino suo, al massimo due, e il riquadro resta del boss")
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_arrabbiato"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	scontro.set_process(false)
	var boss: Dictionary = scontro.vivi(false)[0]
	var fascia: String = scontro.plancia.fascia_nome.text
	var richiamo := mossa_di("goblin_arrabbiato", "evoca")
	boss.hp = int(boss.hp_max * 0.3)   # quando lo fa: sotto una certa vita
	for volta in 2:
		esigi(scontro.mossa_disponibile(boss, richiamo),
				"alla chiamata numero %d il richiamo non e' disponibile" % (volta + 1))
		scontro.esegui_mossa(boss, richiamo)
		boss.ricariche_mosse = {}
	esigi(not scontro.mossa_disponibile(boss, richiamo), "il goblin arrabbiato puo' chiamarne un terzo")
	var goblin: Array[Dictionary] = []
	for chi in scontro.vivi(false):
		if String(chi.id) == "goblin_tipico":
			goblin.append(chi)
	esigi(goblin.size() == 2, "chiamati due goblin, in campo ce ne sono %d" % goblin.size())
	esigi(scontro.plancia.fascia_nome.text == fascia,
			"arrivati i goblin la fascia dice '%s' invece di '%s'" % [scontro.plancia.fascia_nome.text, fascia])
	esigi(boss.scheda == scontro.plancia.box_nemico, "il boss non ha piu' il riquadro grande")
	var gregari: GregariNemici = scontro.campo.gregari
	esigi(gregari != null and gregari.fila.size() == 2,
			"i quadratini sono %d invece di due" % (0 if gregari == null else gregari.fila.size()))
	for chi in goblin:
		var suo: Control = chi.scheda
		esigi(suo is GregariNemici.QuadrettoNemico and gregari.is_ancestor_of(suo),
				"un goblin chiamato non sta nel suo quadratino")
		esigi(chi.bersaglio_cliccabile == suo and not suo.gui_input.get_connections().is_empty(),
				"il quadratino di un goblin non si clicca: non lo si puo' colpire")
		esigi(is_equal_approx(suo.size.x, suo.size.y) and suo.size.x > 0.0,
				"il quadratino non e' quadrato: %s" % str(suo.size))
	# il primo cade: sfuma lui, non il boss, e l'altro scorre al suo posto
	var primo: Control = goblin[0].scheda
	var secondo: Control = goblin[1].scheda
	goblin[0].hp = 0
	scontro.aggiorna_scheda(goblin[0])
	await get_tree().create_timer(Stile.tempo("uscita_sconfitto") + 0.2).timeout
	esigi(not primo.visible, "il goblin caduto resta nel suo quadratino")
	# e caduto uno non ne arriva un terzo: due in tutto, non due alla volta
	boss.ricariche_mosse = {}
	esigi(not scontro.mossa_disponibile(boss, richiamo),
			"caduto un goblin, il boss ne puo' chiamare un terzo: dovevano essere due in tutto")
	esigi(scontro.plancia.box_nemico.visible and is_equal_approx(scontro.plancia.box_nemico.modulate.a, 1.0),
			"e' caduto un goblin ed e' sfumato il riquadro del boss")
	esigi(is_equal_approx(secondo.position.x, GregariNemici.MARGINE),
			"caduto il primo, il secondo non scorre al suo posto")
	scontro.queue_free()
	await get_tree().process_frame
	GameState.nuova_partita()

func ripulisci_e_bevi(scontro, chi: Dictionary) -> Dictionary:
	# COME SI GIOCA DAVVERO uno scontro con dei gregari: prima si tolgono di
	# mezzo i piu' deboli, e sotto meta' vita si beve una fiala se c'e'
	var nemici: Array[Dictionary] = scontro.vivi(false)
	if nemici.is_empty():
		return {"tipo": "difendi"}
	if float(chi.hp) < float(chi.hp_max) * 0.45 and "fiala_hp" in GameState.sacca:
		return {"tipo": "oggetto", "id": "fiala_hp"}
	var bersaglio: Dictionary = nemici[0]
	for nemico in nemici:
		if int(nemico.hp) < int(bersaglio.hp):
			bersaglio = nemico
	return {"tipo": "attacca", "bersaglio": bersaglio}

func contro_il_goblin_arrabbiato(fiale: int, mano: float, partite: int) -> Dictionary:
	var regole: Dictionary = GameState.regole["contrasto"]
	var di_serie := float(regole.get("mano_automatica", 5.0))
	regole["mano_automatica"] = mano
	var vinte := 0
	var battute := 0
	for seme in partite:
		GameState.nuova_partita()
		GameState.imposta_seed(2000 + seme)
		for volta in fiale:
			GameState.aggiungi_oggetto("fiala_hp")
		var scontro := scontro_muto_contro(["goblin_arrabbiato"], {}, Callable(self, "ripulisci_e_bevi"), 150)
		if scontro.giocatore_ha_vinto:
			vinte += 1
		battute += int(scontro.battute_del_giocatore)
		scontro.free()
	regole["mano_automatica"] = di_serie
	GameState.nuova_partita()
	return {"vinte": vinte, "battute": float(battute) / maxf(float(partite), 1.0)}

func prova_il_goblin_arrabbiato_e_lungo_ma_battibile() -> void:
	# Bru: «rendilo battibile, ma fai in modo che il combattimento sia lungo e
	# interessante, calcola molte hit [...] deve essere time consuming non
	# difficile e imbattibile». Prima era 0 vittorie su 150 a ogni livello.
	#
	# Il giocatore misurato e' quello che arriva li' dalla strada di Bru: livello
	# 1, le due fiale del masso, e gioca come si gioca - prima i goblin chiamati,
	# poi il boss, e beve sotto meta' vita
	titolo("il goblin arrabbiato si batte, ci vuole tanto, e la mazzata conta")
	var partite := 12
	var di_serie := contro_il_goblin_arrabbiato(2, 5.0, partite)
	esigi(int(di_serie.vinte) >= partite - 1,
			"col giocatore di serie si vince %d volte su %d: non e' piu' «non difficile»"
			% [int(di_serie.vinte), partite])
	esigi(float(di_serie.battute) >= 35.0,
			"si vince in %.1f tue battute: non e' piu' uno scontro lungo" % float(di_serie.battute))
	# e il minigioco non e' decorazione: senza fiale, chi preme vince piu' spesso
	# di chi la mazza la lascia calare
	var premendo := contro_il_goblin_arrabbiato(0, 5.0, partite)
	var lasciando := contro_il_goblin_arrabbiato(0, -1.0, partite)
	# «non difficile» anche per chi le fiale non le ha raccolte: chi preme se
	# la gioca (misurate a turni 46 su 100; col tempo reale erano 55)
	esigi(int(premendo.vinte) * 4 >= partite,
			"senza fiale, premendo, si vince %d volte su %d: senza scorte e' diventato un muro"
			% [int(premendo.vinte), partite])
	esigi(int(premendo.vinte) > int(lasciando.vinte),
			"senza fiale chi preme vince %d volte e chi non preme %d: la mazzata non conta niente"
			% [int(premendo.vinte), int(lasciando.vinte)])

func prova_la_musica_giusta_per_ogni_scontro_e_livello() -> void:
	# Bru: «per i nemici comuni una musica, per i nemici speciali un'altra, per
	# i boss un'altra, per l'allenamento un'altra, e ogni livello ha la sua bg
	# music». I file li mette lui; qui si controlla che il gioco li vada a
	# cercare nel posto giusto, e che uno che manca non diventi silenzio
	titolo("ogni scontro e ogni livello cercano la loro musica, e un file che manca ripiega")
	var tracce: Dictionary = GameState.audio.get("musica", {})
	for chiave in ["combattimento_comune", "combattimento_particolare", "combattimento_miniboss",
			"combattimento_boss", "combattimento_allenamento"]:
		var percorso := String(tracce.get(chiave, ""))
		esigi(percorso.begins_with("res://audio/musica/") and percorso.ends_with(".ogg"),
				"audio.json: '%s' non punta a un .ogg in audio/musica ('%s')" % [chiave, percorso])
	for categoria in ["comune", "particolare", "boss"]:
		esigi(AudioManager.chiave_combattimento(categoria, false) == "combattimento_" + categoria,
				"uno scontro '%s' cerca '%s'" % [categoria, AudioManager.chiave_combattimento(categoria, false)])
	# il file finto e' un file che esiste davvero: basta per chiedere "c'e'?"
	var vero := "res://icon.svg"
	var allenamento := String(tracce.get("combattimento_allenamento", ""))
	var miniboss := String(tracce.get("combattimento_miniboss", ""))
	tracce["combattimento_allenamento"] = "res://audio/musica/non_ce.ogg"
	tracce["combattimento_miniboss"] = "res://audio/musica/non_ce.ogg"
	esigi(AudioManager.chiave_combattimento("comune", true) == "combattimento_comune",
			"senza il suo file, l'allenamento resta in silenzio invece di prendere la musica della categoria")
	esigi(AudioManager.chiave_combattimento("miniboss", false) == "combattimento_boss",
			"senza il suo file, il miniboss non prende la musica del boss")
	tracce["combattimento_allenamento"] = vero
	tracce["combattimento_miniboss"] = vero
	esigi(AudioManager.chiave_combattimento("comune", true) == "combattimento_allenamento",
			"col suo file, l'allenamento non suona la sua musica")
	esigi(AudioManager.chiave_combattimento("miniboss", false) == "combattimento_miniboss",
			"col suo file, il miniboss suona quella del boss")
	tracce["combattimento_allenamento"] = allenamento
	tracce["combattimento_miniboss"] = miniboss
	# ogni livello porta la sua in cima al file, e la base continua quella del
	# menu: «Nuova partita» fa partire intro.ogg, e entrando non si deve spezzare
	for livello in [["intro", "res://data/events_intro.json"], ["tutorial", "res://data/events_tutorial.json"]]:
		GameState.nuova_partita()
		GameState.avvia_carnivalz(String(livello[0]), String(livello[1]))
		var sua := GameState.musica_ambiente
		esigi(sua.begins_with("res://audio/musica/") and sua.ends_with(".ogg"),
				"il livello '%s' non ha una musica sua ('%s')" % [String(livello[0]), sua])
		if String(livello[0]) == "intro":
			esigi(sua == String(tracce.get("intro", "")),
					"la base suona '%s' e il menu parte con '%s': entrando la musica si spezza" % [sua, String(tracce.get("intro", ""))])
	GameState.nuova_partita()

func prova_nel_complesso_si_va_dritti() -> void:
	# Bru, dopo l'allenamento con Veronica: «dovrei poter accedere a sala
	# allenamento, la mia stanza, infermeria e sala comunicazioni, per di piu'
	# dopo il dialogo in sala non riesco ad andare avanti». La mappa lasciava
	# andare solo nelle stanze confinanti: al risveglio la palestra era
	# «troppo lontano», e dopo i soldati lo era la sala comunicazioni col punto
	# esclamativo. Nel complesso adesso si va dritti lungo i corridoi aperti;
	# nelle fratture si cammina ancora una stanza alla volta
	titolo("nel complesso si va dritti in ogni stanza, nelle fratture si cammina")
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	for id_nodo in ["introduzione", "alloggio", "sala_allenamento"]:
		IngressoNodo.entra(id_nodo)
	var mappa: Node = load("res://scenes/MappaZona.tscn").instantiate()
	add_child(mappa)
	await get_tree().process_frame
	# la mattina resta un corridoio solo: dall'alloggio si va in palestra e basta
	GameState.nodo_corrente = "alloggio"
	esigi(mappa.si_puo_andare("sala_allenamento") and not mappa.si_puo_andare("infermeria"),
			"la mattina il complesso e' gia' aperto: il racconto non ti porta piu' in palestra")
	IngressoNodo.entra("infermeria_risveglio")
	var quattro := ["sala_allenamento", "alloggio", "infermeria", "sala_comunicazioni"]
	for da in ["infermeria", "sala_allenamento", "alloggio", "sala_comunicazioni", "mensa", "hangar"]:
		GameState.nodo_corrente = da
		for dove in quattro:
			esigi(mappa.si_puo_andare(dove),
					"nel pomeriggio, da '%s' non si arriva a '%s'" % [da, dove])
	# e il prossimo punto esclamativo si raggiunge da dove finisce il dialogo
	IngressoNodo.entra("sala_allenamento")
	IngressoNodo.entra("soldati_conversazione")
	GameState.nodo_corrente = "sala_allenamento"
	esigi(mappa.si_puo_andare("sala_comunicazioni"),
			"dopo i soldati la sala comunicazioni e' «troppo lontano»: non si va avanti")
	for id_nodo in ["sala_comunicazioni", "comunicazioni_ordini", "data_pad_istruzioni"]:
		IngressoNodo.entra(id_nodo)
	GameState.nodo_corrente = "sala_comunicazioni"
	esigi(mappa.si_puo_andare("sala_proiezione"), "dopo il data pad la sala di proiezione non si raggiunge")
	mappa.queue_free()
	await get_tree().process_frame
	# nelle Pianure invece si cammina: due stanze piu' in la' non ci si salta
	GameState.nuova_partita()
	GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
	var pianure: Node = load("res://scenes/MappaZona.tscn").instantiate()
	add_child(pianure)
	await get_tree().process_frame
	GameState.nodo_corrente = "banchetto"
	esigi(pianure.si_puo_andare("pianura") and not pianure.si_puo_andare("albero"),
			"nelle Pianure si salta di due stanze: la frattura non si scopre piu' camminando")
	pianure.queue_free()
	await get_tree().process_frame
	GameState.nuova_partita()

# --- I TESTI LUNGHI SI DIVIDONO IN PAGINE --------------------------------------
#
# Bru: «alcuni dialoghi sforano il container di testo, bisogna dividere i testi
# piu' lunghi affinche' entrino sempre nel box». Il box ha un'altezza fissa, e
# quello che non ci stava scorreva sotto il bordo, dove non si leggeva.

func testo_piano(pezzo: String) -> String:
	# senza tag e con gli spazi normalizzati: quello che si legge, e basta
	var senza := RegEx.create_from_string("\\[[^\\]]*\\]").sub(pezzo, "", true)
	var parole: Array[String] = []
	for riga in senza.split("\n", false):
		for parola in riga.split(" ", false):
			parole.append(parola)
	return " ".join(parole)

func prova_l_impaginatore_taglia_dove_si_legge() -> void:
	titolo("un testo lungo si divide dove si legge, e non si perde niente")
	# un misuratore finto: ci stanno "quanti" caratteri leggibili
	var fino_a := func(quanti: int) -> Callable:
		return func(pezzo: String) -> bool: return testo_piano(pezzo).length() <= quanti
	var tre_frasi := "Uno due tre. Quattro cinque sei. Sette otto nove."
	var pagine := Impaginatore.dividi(tre_frasi, fino_a.call(33))
	esigi(pagine == ["Uno due tre. Quattro cinque sei.", "Sette otto nove."],
			"tre frasi si dividono male: %s" % str(pagine))
	# i puntini seguiti dalla minuscola non chiudono la frase: e' la stessa frase
	# che prende fiato, e il taglio buono e' il punto vero che viene dopo
	var fiato := "Prima frase. Non e' recisa... finche' ogni filo non viene tirato."
	pagine = Impaginatore.dividi(fiato, fino_a.call(40))
	esigi(not pagine.is_empty() and String(pagine[0]) == "Prima frase.",
			"la pagina finisce sui puntini a meta' frase invece che sul punto vero: %s" % str(pagine))
	# un a capo di Bru e' il taglio migliore di tutti
	var paragrafi := "Primo paragrafo, corto.\n\nSecondo paragrafo. Con due frasi."
	pagine = Impaginatore.dividi(paragrafi, fino_a.call(45))
	esigi(pagine.size() == 2 and String(pagine[0]) == "Primo paragrafo, corto.",
			"il paragrafo non e' diventato una pagina: %s" % str(pagine))
	# il bbcode resta chiuso su ogni pagina, e si riapre sulla dopo
	pagine = Impaginatore.dividi("[i]Uno due tre. Quattro cinque sei.[/i]", fino_a.call(20))
	esigi(pagine == ["[i]Uno due tre.[/i]", "[i]Quattro cinque sei.[/i]"],
			"il corsivo si perde o resta aperto fra le pagine: %s" % str(pagine))
	# una frase sola troppo lunga si taglia sulle virgole, poi fra le parole
	var lunga := "Una frase lunga, piena di pezzi, che non finisce mai e continua ancora"
	pagine = Impaginatore.dividi(lunga, fino_a.call(20))
	for pagina in pagine:
		esigi(testo_piano(pagina).length() <= 20, "una pagina non entra: «%s»" % pagina)
	esigi(testo_piano(" ".join(pagine)) == testo_piano(lunga), "tagliando fra le parole si e' perso del testo")
	# e una parola piu' lunga di tutto il box non blocca niente: resta intera
	pagine = Impaginatore.dividi("Supercalifragilistichespiralidoso e basta", fino_a.call(10))
	esigi(pagine.size() >= 2 and testo_piano(" ".join(pagine)) == "Supercalifragilistichespiralidoso e basta",
			"una parola che non ci sta da sola ha rotto l'impaginazione: %s" % str(pagine))

func tutti_i_testi_da_leggere() -> Array[String]:
	# ogni "testo" e ogni "scena" dei dati che il gioco puo' mettere nel box
	var trovati: Array[String] = []
	var file: Array[String] = ["res://data/events.json", "res://data/events_intro.json",
			"res://data/events_tutorial.json", "res://data/personaggi.json", "res://data/dialoghi.json"]
	for nome in DirAccess.get_files_at("res://data/vuoti"):
		if nome.ends_with(".json"):
			file.append("res://data/vuoti/" + nome)
	for percorso in file:
		raccogli_testi(JSON.parse_string(FileAccess.get_file_as_string(percorso)), trovati)
	return trovati

func raccogli_testi(dato: Variant, dentro: Array[String]) -> void:
	if dato is Dictionary:
		for chiave in dato:
			var valore: Variant = dato[chiave]
			if valore is String and String(chiave) in ["testo", "scena"] and String(valore) != "":
				dentro.append(String(valore))
			else:
				raccogli_testi(valore, dentro)
	elif dato is Array:
		for valore in dato:
			raccogli_testi(valore, dentro)

func giro_di_pagine(box: Node, testi: Array[String], dove: String) -> int:
	# ogni testo, come narrazione e come dialogo, pagina per pagina SUL TESTO
	# VERO del box: e' quello che si vede, non il doppione che misura
	var divisi := 0
	for testo in testi:
		for tipo in ["narrazione", "dialogo"]:
			box.mostra(tipo, testo, "Veronica" if tipo == "dialogo" else "")
			if box.pagine.size() > 1:
				divisi += 1
			var letto := ""
			while true:
				box.completa()
				var vero: RichTextLabel = box.testo
				esigi(vero.get_content_height() <= vero.size.y + 0.5,
						"%s: una pagina esce dal box (%.0f su %.0f): «%s»"
						% [dove, vero.get_content_height(), vero.size.y, String(box.pagine[box.pagina]).left(60)])
				letto += String(box.pagine[box.pagina]) + " "
				if not box.pagina_seguente():
					break
			esigi(testo_piano(letto) == testo_piano(testo),
					"%s: dividendo in pagine si e' perso del testo: «%s»" % [dove, testo.left(60)])
	return divisi

func prova_ogni_testo_entra_nel_box() -> void:
	titolo("ogni testo del gioco entra nel box, pagina per pagina, anche col testo grande")
	var testi := tutti_i_testi_da_leggere()
	esigi(testi.size() > 1000, "ho trovato solo %d testi: la raccolta non funziona" % testi.size())
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	scontro.set_process(false)
	scontro.voce.coda.clear()
	scontro.plancia.mostra_faccia("parlato")
	schermata.box.scrittura_finita.disconnect(schermata._su_testo_pronto)
	await get_tree().process_frame
	await get_tree().process_frame
	giro_di_pagine(schermata.box, testi, "eventi")
	giro_di_pagine(scontro.box, testi, "combattimento")
	# «Testo piu' grande» ingrandisce tutto: il box resta alto uguale ma ci
	# stanno meno parole per riga, ed e' li' che si sforava di piu'
	var larghezza_prima: float = scontro.box.testo.size.x
	get_tree().root.content_scale_factor = 1.25
	Impostazioni.testo_grande = true
	for volta in 3:
		await get_tree().process_frame
	esigi(scontro.box.testo.size.x < larghezza_prima,
			"col testo grande il box del combattimento non si e' ristretto: la prova non misura niente")
	var divisi := giro_di_pagine(scontro.box, testi, "combattimento, testo grande")
	giro_di_pagine(schermata.box, testi, "eventi, testo grande")
	esigi(divisi > 50, "col testo grande solo %d testi hanno avuto bisogno di pagine: il box non si ristringe davvero" % divisi)
	get_tree().root.content_scale_factor = 1.0
	Impostazioni.testo_grande = false
	schermata.queue_free()
	scontro.queue_free()
	await get_tree().process_frame
	GameState.nuova_partita()

func prova_le_pagine_si_girano_col_click() -> void:
	titolo("le pagine si girano col click, e si va avanti solo dopo l'ultima")
	var lungo := ""
	for volta in 6:
		lungo += "Una frase che occupa un bel pezzo di riga, e poi continua ancora un poco. \n\n"
	GameState.nuova_partita()
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	var schermata: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(schermata)
	await get_tree().process_frame
	await get_tree().process_frame
	var box: Node = schermata.box
	var finite: Array[int] = [0]
	box.scrittura_finita.disconnect(schermata._su_testo_pronto)
	box.scrittura_finita.connect(func() -> void: finite[0] += 1)
	box.mostra("narrazione", lungo, "")
	var quante: int = box.pagine.size()
	esigi(quante >= 2, "un testo di sei paragrafi sta in una pagina sola: la prova non prova niente")
	for pagina in quante:
		schermata._su_avanza()   # il primo click completa la pagina
		esigi(int(box.pagina) == pagina and not bool(box.sta_scrivendo),
				"il click a meta' pagina non l'ha completata")
		esigi(finite[0] == (1 if pagina == quante - 1 else 0),
				"alla pagina %d di %d la battuta risulta gia' finita: le scelte arriverebbero sotto il testo"
				% [pagina + 1, quante])
		if pagina < quante - 1:
			schermata._su_avanza()   # il secondo gira pagina, non passa alla battuta dopo
			esigi(int(box.pagina) == pagina + 1, "il click non gira pagina")
	schermata.queue_free()
	await get_tree().process_frame
	# NEL COMBATTIMENTO le pagine scorrono da sole, ognuna col suo tempo
	GameState.nuova_partita()
	GameState.nemici_combattimento = ["goblin_tipico"]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	scontro.set_process(false)
	scontro.voce.coda.clear()
	scontro.plancia.mostra_faccia("parlato")
	await get_tree().process_frame
	scontro.scrivi(lungo)
	var viste: Dictionary = {}
	var giri := 0
	while giri < 600 and (not scontro.voce.coda.is_empty() or scontro.voce.sta_facendo_leggere):
		viste[int(scontro.box.pagina)] = true
		scontro.voce.salta_messaggio = true
		await get_tree().process_frame
		giri += 1
	var tutte: int = scontro.box.pagine.size()
	esigi(tutte >= 2 and viste.size() == tutte,
			"nel combattimento si sono viste %d pagine su %d" % [viste.size(), tutte])
	scontro.queue_free()
	await get_tree().process_frame
	GameState.nuova_partita()
