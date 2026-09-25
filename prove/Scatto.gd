extends Node

# FOTOGRAFA UNA SCHERMATA E SE NE VA.
#
# Le prove misurano quello che si puo' misurare: che un numero sia giusto, che
# una porta si apra, che uno scontro finisca. Non sanno dire se una cosa e'
# VENUTA come doveva venire - e da quando l'interfaccia la disegna Bru e io la
# ricostruisco, quella e' esattamente la domanda che conta.
#
# Quindi: apri una scena, aspetta che si assesti, salva un PNG. Non e' una
# prova e non fallisce mai; e' un paio d'occhi.
#
#   ./prove/scatto.sh dialogo
#   ./prove/scatto.sh menu
#
# Vuole un display vero (xvfb-run basta): senza finestra Godot non disegna, e
# uno scatto di un rendering che non e' avvenuto sarebbe nero e bugiardo.

const CARTELLA := "res://scatti/"
const FOTOGRAMMI_DI_ASSESTAMENTO := 45

func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	var quale := String(argomenti[0]) if argomenti.size() > 0 else "dialogo"
	var etichetta := quale if argomenti.size() < 2 else "%s_%s" % [quale, argomenti[1]]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARTELLA))
	await prepara(quale)
	# la rottura si assesta da sola dentro prepara(): aspettare altri quaranta
	# fotogrammi qui vorrebbe dire fotografare il vetro quando e' gia' svanito
	# L'ECG SI FOTOGRAFA SUBITO. Lo scontro gira in tempo reale e decidi_faccia
	# rimette il parlato a ogni fotogramma: aspettare l'assestamento vuol dire
	# fotografare il box del testo. Successo due volte prima che lo capissi.
	if quale != "rottura" and quale != "nastro" and not quale.begins_with("ecg"):
		await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
	salva(etichetta)
	get_tree().quit()

func partite_finte() -> void:
	# due partite vere, scritte come le scrive il gioco, per vedere il menu
	# com'e' dopo qualche ora di gioco invece che la prima volta
	for dati: Array in [[2, "Bru", 4, 3030], [4, "Veronica", 2, 450]]:
		GameState.nuova_partita()
		GameState.imposta_nome_protagonista(String(dati[1]))
		GameState.livelli[GameState.id_protagonista] = int(dati[2])
		GameState.tazo = int(dati[3])
		GameState.salva_slot(int(dati[0]))
	GameState.nuova_partita()

func pellicola(dove: String) -> void:
	# LA COREOGRAFIA IN UN FOGLIO SOLO: dodici fotogrammi, uno ogni tre (50 ms
	# con --fixed-fps 60, che rende il tempo del gioco esatto anche se la
	# finestra finta disegna lenta), in una griglia quattro per tre. Si legge
	# da sinistra a destra e dall'alto in basso.
	var foglio := Image.create(1280, 540, false, Image.FORMAT_RGBA8)
	for i in 12:
		await RenderingServer.frame_post_draw
		var fotogramma := get_viewport().get_texture().get_image()
		fotogramma.convert(Image.FORMAT_RGBA8)
		fotogramma.resize(320, 180, Image.INTERPOLATE_BILINEAR)
		foglio.blit_rect(fotogramma, Rect2i(0, 0, 320, 180), Vector2i((i % 4) * 320, floori(i / 4.0) * 180))
		await attendi(2)
	foglio.save_png(ProjectSettings.globalize_path(dove))
	print("pellicola salvata: %s" % dove)

func ferma_dopo(millesimi: int) -> void:
	# il tempo del gioco si ferma quando ne sono passati tanti: i tween e le
	# molle restano dove sono, e lo scatto prende quell'istante. Preciso a un
	# fotogramma, che per guardare una coreografia basta
	var partenza := Time.get_ticks_msec()
	while Time.get_ticks_msec() - partenza < millesimi:
		await get_tree().process_frame
	Engine.time_scale = 0.0

func attendi(quanti: int) -> void:
	for i in quanti:
		await get_tree().process_frame

func fotografa_la_mazzata(contrasto: ContrastoCombattimento, momento: String) -> void:
	# una mano che preme sei volte al secondo (o nessuna, per "colpo"), a passi
	# di un fotogramma: "spinta" si ferma a meta' gara, le altre alla fine
	contrasto.avvia({})
	var passo := 1.0 / 60.0
	var fotogramma := 0
	while contrasto.fase == "reazione" or contrasto.fase == "spinta":
		if momento == "reazione" and contrasto.secondi >= 0.12:
			break
		if momento == "spinta" and contrasto.secondi >= 1.0:
			break
		if momento != "colpo" and fotogramma % 10 == 0:
			contrasto.premi_col_tasto()
		contrasto.passa(passo)
		fotogramma += 1
	contrasto.passa(passo)
	await attendi(2)
	if not contrasto.attivo:
		push_error("la mazzata non e' a schermo: non c'e' niente da fotografare")

func prepara(quale: String) -> void:
	match quale:
		"menu":
			# IL MENU DI PAUSA, e con un secondo argomento anche a meta' della sua
			# entrata: "menu 120" lo ferma 120 millesimi dopo l'apertura, "menu
			# sopra" lo lascia assestare con il fuoco sul Diario e il mouse in
			# alto a destra (la parallasse e l'estrusione della parola)
			await apri_dialogo()
			await attendi(10)
			Pausa.apri()
			var argomenti := OS.get_cmdline_user_args()
			var quando := String(argomenti[1]) if argomenti.size() > 1 else ""
			if quando.is_valid_int():
				await ferma_dopo(int(quando))
			elif quando == "film":
				await pellicola("res://scatti/menu_pellicola.png")
			elif quando == "sopra":
				Pausa.quinte.puntatore_finto = Vector2(1240.0, 60.0)
				await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
				var voci := Pausa.colonna.get_children().filter(
						func(n: Node) -> bool: return n is VoceMenu)
				(voci[2] as VoceMenu).bottone.grab_focus()
		"scena":
			# una schermata qualunque di scenes/, com'e' appena aperta:
			# "scena Compendio", "scena Album"...
			var argomenti := OS.get_cmdline_user_args()
			var nome_scena := String(argomenti[1]) if argomenti.size() > 1 else "Compendio"
			add_child(load("res://scenes/%s.tscn" % nome_scena).instantiate())
		"principale":
			# IL MENU PRINCIPALE: "principale titolo", "principale menu", e i passi
			# "nuova", "carica", "chi_sei", "come", "film" (la pellicola
			# dell'entrata). Con "partite" in fondo ci sono due partite salvate,
			# che alla fine si cancellano
			var argomenti := OS.get_cmdline_user_args()
			var passo := String(argomenti[1]) if argomenti.size() > 1 else "titolo"
			var con_partite := "partite" in argomenti
			if "grande" in argomenti:
				# il caso peggiore per lo spazio: «testo piu' grande» acceso
				Impostazioni.testo_grande = true
				Impostazioni.applica_scala_testo()
			if con_partite:
				partite_finte()
			var schermo: Control = load("res://scenes/Menu.tscn").instantiate()
			add_child(schermo)
			await attendi(3)
			if passo != "titolo":
				schermo.entra_dal_titolo()
			match passo:
				"nuova": schermo.pagina_nuova()
				"carica": schermo.pagina_carica()
				"chi_sei": schermo.pagina_chi_sei(1)
				"anonimo":
					# la domanda sul nome vuoto, aperta come la apre COMINCIA
					schermo.pagina_chi_sei(1)
					schermo.al_via = func() -> void: pass
					await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
					schermo.comincia()
				"come": schermo.pagina_come_si_gioca()
				"come_storia": schermo.pagina_come_si_gioca("STORIA")
				"come_scontro": schermo.pagina_come_si_gioca("COMBATTIMENTO")
				"come_mosse": schermo.pagina_come_si_gioca("MOSSE SPECIALI")
				"opzioni": schermo.pagina_opzioni()
				"audio": schermo.pagina_opzioni_di("Audio")
				"grafica": schermo.pagina_opzioni_di("Grafica")
				"accessibilita": schermo.pagina_opzioni_di("Accessibilità")
				"extra": schermo.pagina_extra()
				"codice": schermo.pagina_codice()
				"collezioni": schermo.pagina_collezioni()
				"film": await pellicola("res://scatti/principale_pellicola.png")
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			if passo == "menu" and con_partite:
				# e una voce scelta a meta' elenco, come EXTRAS nel riferimento
				(schermo.voci[4] as VoceMenu).bottone.grab_focus()
				await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			if con_partite:
				salva("principale_%s_partite" % passo)
				for slot in [2, 4]:
					GameState.elimina_slot(slot)
		"pausa":
			# un pannello della pausa: "pausa diario", "pausa zaino", "pausa
			# opzioni", "pausa storico", "pausa uscita"
			await apri_dialogo()
			await attendi(10)
			Pausa.apri()
			await attendi(5)
			var argomenti := OS.get_cmdline_user_args()
			match String(argomenti[1]) if argomenti.size() > 1 else "diario":
				"zaino": Pausa.mostra_inventario()
				"opzioni": Pausa.mostra_opzioni()
				"storico": Pausa.mostra_storico()
				"uscita": Pausa.conferma_uscita()
				"squadra": Pausa.mostra_equipaggiamento()
				_: Pausa.mostra_diario()
		"nodo":
			# UN NODO VERO DI events_intro, portato avanti di N clic: "nodo
			# infermeria_risveglio 12" fotografa la dodicesima battuta. Con
			# "fine" al posto del numero si clicca finche' non ci sono le scelte
			var argomenti_nodo := OS.get_cmdline_user_args()
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			GameState.imposta_flag("rientro_infermeria")
			GameState.nodo_corrente = String(argomenti_nodo[1]) if argomenti_nodo.size() > 1 else "infermeria_risveglio"
			# un nodo che non e' dell'introduzione e' del livello dei goblin
			if not GameState.eventi.has(GameState.nodo_corrente):
				var cercato := GameState.nodo_corrente
				GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
				GameState.nodo_corrente = cercato
			IngressoNodo.ultimo_esito = {}
			var dialogo: Node = load("res://scenes/Main.tscn").instantiate()
			add_child(dialogo)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var quanti := String(argomenti_nodo[2]) if argomenti_nodo.size() > 2 else "0"
			var clic := 0
			while clic < (400 if quanti == "fine" else int(quanti)):
				if quanti == "fine" and dialogo.contenitore_scelte.get_child_count() > 0 \
						and dialogo.coda_messaggi.is_empty():
					break
				# un clic completa la frase, il secondo va avanti: come un giocatore
				dialogo._su_avanza()
				await attendi(2)
				dialogo._su_avanza()
				await attendi(2)
				clic += 1
		"giro_data_pad":
			# IL GIRO GUIDATO DEL DATA PAD, portato fino a un passo: "giro_data_pad
			# alloggio 0" e' il tasto in alto a sinistra da premere, "giro_data_pad
			# data_pad_istruzioni 4" il messaggio da aprire in sala. I gesti che il
			# giro aspetta li fa lo scatto al posto del giocatore
			var argomenti_giro := OS.get_cmdline_user_args()
			var nodo_giro := String(argomenti_giro[1]) if argomenti_giro.size() > 1 else "alloggio"
			var fino_al := int(argomenti_giro[2]) if argomenti_giro.size() > 2 else 0
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			if nodo_giro != "alloggio":
				GameState.imposta_flag("rientro_infermeria")
				GameState.imposta_flag("ordini_ricevuti")
			GameState.nodo_corrente = nodo_giro
			IngressoNodo.ultimo_esito = {}
			var con_giro: Node = load("res://scenes/Main.tscn").instantiate()
			add_child(con_giro)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var giro: GiroDataPad = null
			for i in 60:
				giro = con_giro.find_children("*", "GiroDataPad", true, false).pop_back() as GiroDataPad
				if giro != null:
					break
				con_giro.box.completa()
				con_giro.avanza_messaggio()
				await attendi(2)
			while giro != null and giro.quale < fino_al and not giro.chiuso:
				var aspetta := String(giro.passo().get("aspetta", ""))
				if aspetta == "apri":
					Pausa.apri()
				elif aspetta == "voce:diario":
					Pausa.mostra_diario()
				elif aspetta.begins_with("sezione:"):
					Pausa.sezione_diario = aspetta.trim_prefix("sezione:")
					Pausa.mostra_diario()
				elif aspetta == "":
					giro.clic()
					giro.clic()
				else:
					break
				await attendi(12)
			await attendi(40)
			if giro != null:
				giro.box.completa()
		"guida_mappa":
			# la Guida che parla sopra la mappa delle Pianure, all'arrivo:
			# "guida_mappa 2" fotografa la seconda battuta
			GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
			GameState.nodi_visitati.append("inizio")
			GuidaSullaMappa.in_corso = {"zona": GameState.carnivalz_corrente,
					"righe": GameState.mappa_zona.get("guida", []), "ritorno": "inizio_guida", "solo_chiudere": true}
			var mappa: Node = load(GuidaSullaMappa.SCENA_MAPPA_ZONA).instantiate()
			add_child(mappa)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var argomenti_guida := OS.get_cmdline_user_args()
			var battute := int(argomenti_guida[1]) if argomenti_guida.size() > 1 else 1
			var guida: GuidaSullaMappa = mappa.find_children("*", "GuidaSullaMappa", true, false)[0] as GuidaSullaMappa
			for i in battute - 1:
				guida._su_clic()
				await attendi(2)
				guida._su_clic()
				await attendi(2)
		"pianure_scontro":
			# UNO SCONTRO DELLE PIANURE CON LA SUA REGIA, fermato sulla battuta
			# che si vuole guardare: "pianure_scontro banchetto precedenza" e' la
			# Guida che spiega la precedenza, "pianure_scontro pozze gracchiare"
			# l'annuncio dell'orda, "pianure_scontro tartaruga bond" BOND acceso
			var argomenti_s := OS.get_cmdline_user_args()
			var id_nodo := String(argomenti_s[1]) if argomenti_s.size() > 1 else "banchetto"
			var cercato := String(argomenti_s[2]) if argomenti_s.size() > 2 else ""
			GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
			var dati_scontro: Dictionary = GameState.eventi[id_nodo]["combattimento_automatico"]
			GameState.prepara_combattimento(dati_scontro["nemici"], "", "", "", "", dati_scontro.get("regia", {}))
			var scontro_p: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(scontro_p)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var giri := 0
			if id_nodo == "tartaruga" and cercato != "bond":
				# la scena della tartaruga parte alla tua seconda azione
				for azione in 2:
					scontro_p.regia.dopo_di_te(scontro_p.combattente_comandato())
			if cercato == "skill":
				# la lista SKILL di chi comincia, col mondo fermo: e' quella che
				# deve reggere Onda psichica e Concentrazione accanto al resto
				while giri < 600 and (not scontro_p.voce.coda.is_empty() or scontro_p.voce.sta_facendo_leggere):
					scontro_p.voce.salta_messaggio = true
					await attendi(4)
					giri += 1
				scontro_p.set_process(false)
				scontro_p.attaccante_corrente = scontro_p.combattente_comandato()
				scontro_p.menu.abilita()
				await attendi(10)
			elif cercato == "bond":
				scontro_p.regia.apri_il_bond()
				while giri < 600 and (not scontro_p.voce.coda.is_empty() or scontro_p.voce.sta_facendo_leggere):
					scontro_p.voce.salta_messaggio = true
					await attendi(4)
					giri += 1
				scontro_p.turni.passa_a(scontro_p.combattente_comandato())
				await attendi(30)
			elif cercato == "turno":
				# IL TUO TURNO, arrivato giocando: si legge tutto quello che c'e' da
				# leggere (l'imboscata, la Guida, il colpo del goblin) finche' il
				# giro non arriva a te e il menu si accende
				var tu_p: Dictionary = scontro_p.combattente_comandato()
				while giri < 900 and not (scontro_p.puo_agire(tu_p) and scontro_p.fase_adesso() == "comandi"):
					if scontro_p.area_avanza.visible:
						scontro_p.voce.avanza()
					await attendi(2)
					giri += 1
				await attendi(30)
				print("giro %d, tocca a te" % scontro_p.turni.giro)
			else:
				var testo_box: RichTextLabel = scontro_p.box.get("testo")
				while giri < 600 and not cercato in testo_box.get_parsed_text():
					scontro_p.voce.salta_messaggio = true
					await attendi(4)
					giri += 1
				await attendi(20)
		"zona_pianure":
			# la mappa delle Pianure a meta' strada: sei al bivio, la caverna
			# l'hai vista e visitata, le pozze e il promontorio no
			GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
			GameState.imposta_flag("tut_caverna_vista")
			for id_stanza in ["inizio", "banchetto", "pianura", "albero", "caverna", "masso", "bivio"]:
				GameState.nodi_visitati.append(id_stanza)
				GameState.sblocca_stanza(id_stanza)
			GameState.nodo_corrente = "bivio"
			var pianure: Control = load("res://scenes/MappaZona.tscn").instantiate()
			pianure.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(pianure)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"mappa_prima":
			# la mappa stellare aperta da Veronica: solo la prima missione
			MappaStellare.missione_da_scegliere = "proiezione_partenza"
			add_child(load("res://scenes/Mappa.tscn").instantiate())
		"scelte":
			await apri_dialogo(nodo_di_prova())
		"nastro":
			# IL NASTRO A META' VOLO. Dura meno di mezzo secondo: a occhio nudo
			# non si ferma, e senza fermarlo non si puo' dire se la curva e'
			# quella che ha disegnato Bru o un'altra.
			await apri_dialogo(nodo_di_prova())
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			var schermata := get_child(0)
			schermata.nome_sul_nastro = ""
			schermata.aggiorna_nastro("Veronica")
			var argomenti := OS.get_cmdline_user_args()
			var quando := int(argomenti[1]) if argomenti.size() > 1 else 11
			await attendi(quando)
		"intro":
			# la vera introduzione, non un nodo finto: si guarda che il testo di
			# Bru ci stia nel box e che lo sfondo non copra niente
			await apri_dialogo()
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"collisioni":
			# LA RAFFICA FERMATA IN UN MOMENTO PRECISO. Il secondo argomento dice
			# quale: "apertura", "chiusura", oppure i secondi dall'inizio dei
			# pugni (di serie 2.3: un pugno appena parato, uno a meta' strada,
			# uno appena comparso - le tre cose che si devono leggere insieme).
			#
			# L'orologio del minigioco si muove a mano, a passi di un
			# fotogramma: aspettare fotogrammi veri sotto xvfb vuol dire
			# fotografare un istante diverso a ogni prova.
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["veronica"]
			var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(scontro)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			scontro.voce.coda.clear()
			scontro.set_process(false)
			var gioco: MinigiocoCombattimento = scontro.minigioco
			gioco.avvia({"nome": "Collisioni infinite", "quanti": 12,
					"intervallo": 1.0, "durata": 2.0, "danno": 9})
			var argomenti := OS.get_cmdline_user_args()
			var quando := String(argomenti[1]) if argomenti.size() > 1 else "2.3"
			if quando != "apertura":
				gioco.salta()
				var fino_a := 99.0 if quando == "chiusura" else float(quando)
				var parato := false
				while gioco.fase == "raffica" and gioco.tempo < fino_a:
					gioco.passa(1.0 / 60.0)
					# una mano che prende il primo pugno quando il cerchio si chiude
					if not parato and gioco.tempo >= 1.95:
						gioco.colpisci(0)
						parato = true
			# alla chiusura il conto compare quando l'ultimo riscontro e' svanito
			for i in (50 if quando == "chiusura" else 1):
				gioco.passa(1.0 / 60.0)
			await attendi(3)
			if not gioco.attivo:
				push_error("la raffica non e' a schermo: non c'e' niente da fotografare")
		"mazzata", "gregari":
			# IL GOBLIN ARRABBIATO. "mazzata <momento>" ferma il contrasto in uno
			# dei suoi istanti ("reazione", "spinta", "parata", "colpo");
			# "gregari" mostra i due goblin che ha chiamato, nei quadratini in
			# basso a sinistra del suo riquadro. Anche qui l'orologio si muove a
			# mano, come per la raffica
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["goblin_arrabbiato"]
			var boss: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(boss)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			for volta in 2:
				boss.aggiungi_combattente("goblin_tipico", false)
			var ferito: Dictionary = boss.combattenti[boss.combattenti.size() - 1]
			ferito.hp = int(ferito.hp_max * 0.4)
			boss.aggiorna_scheda(ferito)
			boss.voce.coda.clear()
			boss.set_process(false)
			if quale == "gregari":
				boss.plancia.mostra_faccia("comandi")
			else:
				var argomenti_m := OS.get_cmdline_user_args()
				await fotografa_la_mazzata(boss.mazzata.contrasto,
						String(argomenti_m[1]) if argomenti_m.size() > 1 else "spinta")
			await attendi(3)
		"ecgrosso", "ecggiallo":
			# L'ECG IN AVARIA. Un tracciato a occhio non si giudica da fermo:
			# serve vederlo col guasto acceso, e per vederlo bisogna portare il
			# protagonista sotto la soglia rossa o in mezzo a quella gialla.
			GameState.nuova_partita()
			GameState.party = ["anonimo", "veronica"]
			GameState.nemici_combattimento = ["marionetta"]
			var malmesso: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(malmesso)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			for c in malmesso.combattenti:
				c.hp = c.hp_max
				malmesso.campo.aggiorna(c)
			malmesso.arena.imposta_pericolo(0.0)
			malmesso.campo.evidenzia(malmesso.combattenti, malmesso.combattenti[0])
			# LA VITA SI ABBASSA DAVVERO, non si racconta alla plancia. Lo
			# scontro gira e aggiorna_pronto_giocatore riscrive la condizione
			# con gli hp VERI di chi ha il turno a ogni fotogramma: chiamare
			# aggiorna_condizione a mano dura un fotogramma e poi viene
			# sovrascritto. Successo: chiedevo rosso e fotografavo giallo.
			var quota := 0.12 if quale == "ecgrosso" else 0.50
			for c in malmesso.combattenti:
				if c.giocatore:
					c.hp = maxi(int(float(c.hp_max) * quota), 1)
					c.stress = 70 if quale == "ecgrosso" else 25
					malmesso.campo.aggiorna(c)
			malmesso.aggiorna_pronto_giocatore()
			malmesso.menu.principale()
			# tanti fotogrammi: il guasto va a scatti, e va beccato acceso
			var argomenti_ecg := OS.get_cmdline_user_args()
			await attendi(int(argomenti_ecg[1]) if argomenti_ecg.size() > 1 else 90)
			# LA FACCIA SI FORZA PER ULTIMA. Lo scontro gira in tempo reale e
			# rimette il parlato appena arriva una battuta: senza questa riga lo
			# scatto dell'ecg fotografa il box del testo, che e' esattamente
			# quello che e' successo al primo tentativo.
			# E POI SI FERMA IL MOTORE. Forzare la faccia non basta: _process
			# gira a ogni fotogramma e decidi_faccia la rimette sul parlato
			# appena arriva una battuta. Spegnendo il process il quadrante
			# resta dove l'ho messo, e l'ecg - che ha un process suo - continua
			# a disegnarsi. Tre tentativi prima di capirlo.
			malmesso.voce.coda.clear()
			malmesso.set_process(false)
			# E LA VITA SI RIMETTE DOVE L'AVEVO CHIESTA. Nei novanta fotogrammi
			# qui sopra lo scontro e' VIVO: la marionetta picchia, e chiedendo
			# giallo mi sono ritrovato 13/100 e un tracciato rosso. Adesso che
			# il motore e' fermo nessuno la riscrive piu': si rimette il numero
			# e si aggiorna la condizione una volta sola.
			for c in malmesso.combattenti:
				if c.giocatore:
					c.hp = maxi(int(float(c.hp_max) * quota), 1)
					malmesso.campo.aggiorna(c)
			malmesso.aggiorna_pronto_giocatore()
			malmesso.plancia.mostra_faccia("comandi")
			# E DUE FOTOGRAMMI PER RIDISEGNARE. mostra_faccia cambia solo
			# .visible: chi guarda subito dopo vede ancora il fotogramma di
			# prima, cioe' il box del testo. Col motore fermo aspettare non
			# costa piu' niente - e' il motivo per cui tre scatti di fila
			# hanno fotografato il parlato invece del quadrante.
			await attendi(2)
		"plancia":
			# LA SCHERMATA DI COMBATTIMENTO INTERA, come l'ha disegnata Bru.
			# Non c'e' altro modo di controllare che sia quella: le prove sanno
			# dire che i pezzi ci sono, non che il disegno e' quello.
			GameState.nuova_partita()
			GameState.party = ["anonimo", "veronica"]
			GameState.nemici_combattimento = ["marionetta"]
			var scena: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(scena)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			# la faccia dei comandi: e' quella del terzo disegno di Bru
			for c in scena.combattenti:
				c.hp = c.hp_max   # a riposo: il disegno di Bru e' una squadra intera
				scena.campo.aggiorna(c)
			scena.arena.imposta_pericolo(0.0)
			# chi ha il turno: cornice accesa e numero dell'aura
			scena.campo.evidenzia(scena.combattenti, scena.combattenti[0])
			for c in scena.combattenti:
				if c.giocatore:
					scena.campo.aggiorna(c)
			scena.plancia.aggiorna_condizione(0.18, 70, 68)
			scena.plancia.accendi(scena.plancia.tasto_mattanza, true)
			scena.plancia.accendi(scena.plancia.tasto_bond, true)
			scena.menu.principale()
			await attendi(60)
		"lista":
			# LA SECONDA FACCIA DEL QUADRANTE. Bru: «se premi su attacco vedi una
			# lista degli attacchi disponibili, stessa cosa le skill [...] per
			# oggetti invece la lista di oggetti utilizzabili».
			#
			# SKILL e' la piu' affollata delle tre - Studia, i colpi d'arma, le
			# abilita', Indietro - ed e' quella che dice se le colonne reggono.
			GameState.nuova_partita()
			GameState.party = ["anonimo", "veronica"]
			GameState.nemici_combattimento = ["marionetta"]
			var scontro_lista: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(scontro_lista)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			for c in scontro_lista.combattenti:
				c.hp = c.hp_max
				scontro_lista.campo.aggiorna(c)
			scontro_lista.arena.imposta_pericolo(0.0)
			scontro_lista.campo.evidenzia(scontro_lista.combattenti, scontro_lista.combattenti[0])
			scontro_lista.plancia.aggiorna_condizione(0.62, 30, 68)
			scontro_lista.plancia.accendi(scontro_lista.plancia.tasto_mattanza, true)
			# LA LISTA SI APRE PER ULTIMA. Lo scontro gira in tempo reale e rifa'
			# il menu principale quando torni pronto: aprendola prima
			# dell'attesa, al momento dello scatto era gia' tornata la colonna
			# dei comandi - ed e' esattamente quello che era successo.
			scontro_lista.menu.principale()
			await attendi(60)
			scontro_lista.menu.abilita()
			await attendi(3)
			if scontro_lista.plancia.griglia_lista.get_child_count() == 0:
				push_error("la griglia e' vuota: non c'e' nessuna lista da fotografare")
			if scontro_lista.plancia.faccia_adesso != "lista":
				push_error("al momento dello scatto il quadrante mostra '%s', non la lista"
						% scontro_lista.plancia.faccia_adesso)
		"mattanza":
			# LA MATTANZA APERTA: il tassello, la barra che si scarica, e sotto
			# come si batte. Bru: «la mattanza non causa mai alcun danno»
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["goblin_tipico"]
			var pesta: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(pesta)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			var eroe: Dictionary = pesta.combattenti[0]
			var goblin: Dictionary = pesta.vivi(false)[0]
			goblin.hp_max = 100000
			goblin.hp = 100000
			eroe.dominio = 300
			pesta.usa_abilita_su(eroe, "mattanza", goblin)
			while not pesta.voce.coda.is_empty() or pesta.voce.sta_facendo_leggere:
				pesta.voce.avanza()
				await attendi(2)
			for colpo in 5:
				pesta.colpo_di_mattanza(goblin)
				await attendi(4)
		"lezione":
			# LA LEZIONE DI VERONICA, FOTOGRAFATA MENTRE PARLA.
			#
			# E' la cosa che Bru non riusciva a vedere: il testo del tutorial
			# finiva dietro al menu e si sentiva solo il rumore. Una prova puo'
			# dire che il pannello mostra la faccia "parlato"; solo uno scatto
			# dice se quel testo si LEGGE davvero.
			#
			# Adesso e' anche uno scatto stabile: mentre il tutorial parla il
			# mondo e' fermo, quindi non c'e' nessuna corsa contro la ricarica.
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["veronica"]
			var lezione: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(lezione)
			var attesa := 0
			while attesa < 900 and (lezione.voce.coda.is_empty() or lezione.il_tempo_scorre()):
				await attendi(1)
				attesa += 1
			if lezione.voce.coda.is_empty():
				push_error("il tutorial non ha messo in coda nessuna battuta: non c'e' niente da fotografare")
			if lezione.plancia.faccia_adesso != "parlato":
				push_error("il quadrante mostra '%s' invece del box: il testo starebbe ancora dietro al menu"
						% lezione.plancia.faccia_adesso)
			# si avanza fino alla battuta che indica un pezzo: l'evidenziazione
			# si fotografa solo mentre e' accesa
			var avanzate := 0
			while avanzate < 12 and lezione.plancia.evidenziato == null:
				lezione.voce.salta_messaggio = true
				await attendi(6)
				avanzate += 1
			if lezione.plancia.evidenziato == null:
				push_error("in dodici battute non si e' acceso nessun pezzo dello schermo")
			await attendi(20)
		"ecg":
			# I QUATTRO STATI DELLA LINEA, uno sotto l'altro. Il colore dice la
			# vita, il movimento dice lo stress: sono due informazioni diverse
			# nella stessa riga, e l'unico modo di controllare che si leggano
			# davvero e' guardarle insieme.
			GameState.nuova_partita()
			var casi := [
				["vita piena, sereno", 1.0, 0],
				["mezza vita, teso", 0.5, 55],
				["a pezzi, nel panico", 0.15, 100],
				["a terra", 0.0, 0],
			]
			var colonna := VBoxContainer.new()
			colonna.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			colonna.add_theme_constant_override("separation", 18)
			add_child(colonna)
			for caso in casi:
				var etichetta := Label.new()
				etichetta.text = String(caso[0])
				etichetta.add_theme_color_override("font_color", Stile.colore("testo_smorzato"))
				colonna.add_child(etichetta)
				var riga := TracciatoEcg.new()
				riga.custom_minimum_size = Vector2(0, 110)
				riga.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				riga.dado.seed = 20260915
				riga.imposta(float(caso[1]), int(caso[2]))
				colonna.add_child(riga)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 260)
		"complesso_dopo":
			# LA MAPPA DEL POMERIGGIO: tutta visibile, i corridoi aperti, e il
			# punto esclamativo che si e' spostato sulla sala comunicazioni.
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			GameState.imposta_flag("rientro_infermeria")
			GameState.nodo_corrente = "infermeria"
			for id_stanza in ["alloggio", "sala_allenamento", "sala_comunicazioni",
					"infermeria", "archivio", "mensa", "sala_proiezione", "hangar"]:
				GameState.sblocca_stanza(id_stanza)
			var dopo: Control = load("res://scenes/MappaZona.tscn").instantiate()
			dopo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(dopo)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"complesso":
			# la mappa del complesso: tutte le aree visibili, una sola aperta,
			# e il punto esclamativo che salta
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			GameState.nodo_corrente = "alloggio"
			for id_stanza in ["alloggio", "sala_allenamento", "sala_comunicazioni",
					"infermeria", "archivio", "mensa", "sala_proiezione", "hangar"]:
				GameState.sblocca_stanza(id_stanza)
			if not "alloggio" in GameState.nodi_visitati:
				GameState.nodi_visitati.append("alloggio")
			# SENZA DIRGLI QUANTO E' GRANDE, una schermata non si dispone: in
			# gioco ci pensa Transizioni, che la mette come scena corrente. Qui
			# no, e la prima foto usciva con la mappa schiacciata in un angolo -
			# un difetto del fotografo scambiabile per un difetto della mappa.
			var schermo: Control = load("res://scenes/MappaZona.tscn").instantiate()
			schermo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(schermo)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"paragrafo":
			# UN PARAGRAFO VERO, per guardare la forma del testo: l'interlinea,
			# la lunghezza della riga, i margini del box. Su una battuta di
			# quattro parole non si giudica niente - e le schermate che
			# avevamo mostravano tutte una riga sola.
			await apri_dialogo(nodo_di_prova())
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var pagina := get_child(0)
			pagina.box.mostra("narrazione",
					"Nell'universo la vita prende forme che nessuno aveva " +
					"previsto, e ognuna di loro si porta dietro una fame che " +
					"non sa di avere. Le Fratture si aprono dove quella fame " +
					"diventa piu' forte del posto che la contiene.", "")
			pagina.box.completa()
			await attendi(4)
		"pagine":
			# UN TESTO LUNGO DIVISO IN PAGINE (vedi Impaginatore.gd): "pagine
			# eventi 1" e' la seconda pagina nel box degli eventi, "pagine
			# combattimento 0" la prima nel quadrante dello scontro. Il testo e'
			# la soglia della Casa Gigante, il piu' lungo del gioco
			var argomenti_p := OS.get_cmdline_user_args()
			var dove := String(argomenti_p[1]) if argomenti_p.size() > 1 else "eventi"
			var quale_pagina := int(argomenti_p[2]) if argomenti_p.size() > 2 else 0
			var casa: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/vuoti/casa_gigante.json"))
			var lungo := String(casa["nodi"]["soglia"]["sequenza"][0]["testo"])
			var con_box: Node
			if dove == "combattimento":
				GameState.nuova_partita()
				GameState.nemici_combattimento = ["goblin_tipico"]
				con_box = load("res://scenes/Combattimento.tscn").instantiate()
				add_child(con_box)
				await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
				con_box.set_process(false)
				con_box.voce.coda.clear()
				con_box.plancia.mostra_faccia("parlato")
			else:
				await apri_dialogo(nodo_di_prova())
				con_box = get_child(0)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			con_box.box.mostra("narrazione", lungo, "")
			for volta in quale_pagina + 1:
				con_box.box.completa()
				if volta < quale_pagina:
					con_box.box.pagina_seguente()
			await attendi(4)
			print("pagina %d di %d" % [con_box.box.pagina + 1, con_box.box.pagine.size()])
		"evidenza":
			# L'EVIDENZA CHE INDICA UN PEZZO, arrivata tutta: "evidenza bond
			# cornice" fotografa BOND con lo stile cornice (gli stili stanno in
			# Evidenza.STILI; senza, quello di stile.json). Si ferma l'entrata e
			# la si mette a mano tutta fuori, cosi' la foto e' sempre lo stesso
			# istante e due stili si possono confrontare.
			GameState.nuova_partita()
			GameState.party = ["anonimo", "veronica"]
			GameState.nemici_combattimento = ["marionetta"]
			var indicato: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(indicato)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			indicato.voce.coda.clear()
			indicato.set_process(false)
			indicato.plancia.mostra_faccia("comandi")
			var quale_pezzo := "mattanza"
			var argomenti_alone := OS.get_cmdline_user_args()
			if argomenti_alone.size() > 1:
				quale_pezzo = String(argomenti_alone[1])
			if argomenti_alone.size() > 2:
				Stile.dati["evidenza"] = {"stile": String(argomenti_alone[2])}
			indicato.plancia.evidenzia_pezzo(quale_pezzo)
			if indicato.plancia.alone_evidenza != null:
				indicato.plancia.alone_evidenza.ferma()
				indicato.plancia.alone_evidenza.completa()
				indicato.plancia.alone_evidenza.fase = 0.5
			await attendi(2)
		"zona":
			# LA MAPPA A QUADRETTI, quella che non aspetta nessun disegno.
			#
			# Il complesso e' una pianta e la pianta la disegna Bru; una zona
			# invece si costruisce da se', e quindi e' l'unica delle due che si
			# puo' guardare adesso. Casa Gigante e' la piu' grande che abbiamo -
			# ventisette stanze - ed e' il caso in cui una mappa o regge o non
			# regge: su sei stanze qualunque disposizione sembra buona.
			GameState.nuova_partita()
			GameState.avvia_carnivalz("casa_gigante",
					"res://data/vuoti/casa_gigante.json")
			# MEZZA ESPLORATA, non tutta: una mappa tutta accesa non dice niente
			# di come si legge mentre ci stai dentro. Si sbloccano tutte (cosi'
			# si vedono) ma se ne visitano solo le prime, che e' la situazione
			# vera di chi ci sta girando.
			var stanze_zona: Array = GameState.mappa_zona.get("stanze", [])
			for stanza in stanze_zona:
				GameState.sblocca_stanza(String(stanza.get("id", "")))
			for i in mini(floori(stanze_zona.size() / 2.0), stanze_zona.size()):
				var id_visitata := String(stanze_zona[i].get("id", ""))
				if not id_visitata in GameState.nodi_visitati:
					GameState.nodi_visitati.append(id_visitata)
			if not stanze_zona.is_empty():
				GameState.nodo_corrente = String(stanze_zona[2].get("id", ""))
			var quadretti: Control = load("res://scenes/MappaZona.tscn").instantiate()
			quadretti.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(quadretti)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"negozio":
			# IL NEGOZIO NUOVO, sullo schema di Bru: "negozio" col primo negozio,
			# "negozio artigiano" coi baratti, "negozio povero" senza un Tazo
			GameState.nuova_partita()
			var argomenti_negozio := OS.get_cmdline_user_args()
			var variante := String(argomenti_negozio[1]) if argomenti_negozio.size() > 1 else ""
			GameState.negozi_sbloccati = ["organizzazione", "nyu", "artigiano"] as Array[String]
			GameState.tazo = 0 if variante == "povero" else 140
			GameState.sacca.append("razione_del_circo")
			GameState.sacca.append("razione_del_circo")
			var bottega: Control = load("res://scenes/Negozio.tscn").instantiate()
			add_child(bottega)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			if variante == "artigiano":
				bottega.apri_negozio("artigiano")
				bottega.seleziona(bottega.fila.size() - 1, true)
			elif variante != "povero":
				bottega.seleziona(1, true)
			await attendi(40)
		"scheda":
			# LA SCHEDA DELLA SQUADRA CON UNA SQUADRA VERA: quattro compagni (le
			# carte scorrono), uno solo di passaggio, qualcosa addosso e qualcosa
			# da mettere. "scheda scelta" apre l'arma e passa sulla mannaia;
			# "scheda passaggio" guarda chi e' con te solo per un tratto
			GameState.nuova_partita()
			for id_compagno in ["sally", "vega"]:
				GameState.recluta(id_compagno)
			GameState.recluta_temporaneo("niru", 3)
			for id_oggetto in ["coltello_di_servizio", "mannaia_scheggiata", "amuleto_di_pietra",
					"amuleto_di_ferro", "stigma_del_muto", "benda_stretta"]:
				GameState.aggiungi_oggetto(id_oggetto)
			GameState.equipaggia(GameState.id_protagonista, "arma", "coltello_di_servizio")
			GameState.equipaggia("sally", "accessori", "amuleto_di_ferro")
			var argomenti_scheda := OS.get_cmdline_user_args()
			var variante_scheda := String(argomenti_scheda[1]) if argomenti_scheda.size() > 1 else ""
			var scheda := SchedaPersonaggio.new()
			add_child(scheda)
			scheda.apri(Callable(), Callable())
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			if variante_scheda == "scelta":
				scheda._su_casella(scheda.caselle[1])
				await attendi(5)
				var voci := scheda.elenco.get_children().filter(func(v: Node) -> bool: return v is VoceCandidato)
				if voci.size() > 1:
					(voci[1] as VoceCandidato).grab_focus()
			elif variante_scheda == "passaggio":
				scheda.cambia_compagno("niru")
			await attendi(20)
		"sede":
			# LA SEDE, che e' la schermata su cui si torna piu' volte di tutte:
			# ci si passa dopo ogni Carnivalz, ed e' li' che si salva. Bru:
			# «siamo ancora disordinati e l'interfaccia non e' accattivante,
			# alcune cose sono illeggibili, altre fuori inquadratura».
			GameState.nuova_partita()
			# con le stanze aperte, se no meta' schermata dice "— chiuso —" e
			# non si vede quello che c'e' da guardare
			for stanza in GameState.carica_json("res://data/sede.json").get("stanze", []):
				var flag := String(stanza.get("richiede_flag", ""))
				if flag != "":
					GameState.imposta_flag(flag)
			var casa: Control = load("res://scenes/Sede.tscn").instantiate()
			casa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(casa)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"rottura":
			# il vetro a meta' caduta: e' l'unico modo di guardarlo, perche'
			# dura poco piu' di un secondo e a occhio nudo non si ferma
			await apri_dialogo(nodo_di_prova())
			# LE SCELTE NON CI SONO FINCHE' IL TESTO NON HA FINITO DI SCRIVERSI.
			# Aspettando poco si cercava un orologio che non era ancora nato, non
			# si rompeva niente, e lo scatto veniva identico a quello di prima -
			# una foto verde di una cosa che non era successa.
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			var orologio := cerca_orologio(self)
			if orologio == null:
				push_error("Scatto 'rottura': nessun orologio in campo, non c'e' niente da rompere")
				return
			orologio._process(99.0)
			await attendi(22)   # a meta' caduta: i pezzi sono in aria e ancora visibili
		_:
			await apri_dialogo()

func nodo_di_prova() -> Dictionary:
	# La stanza finta del disegno di Bru: qualcuno che parla, due scelte a tempo
	# (una da villain e una da eroe) e tre normali. Non e' contenuto del gioco -
	# e' il metro su cui si misura se la schermata e' venuta come il disegno.
	return {
		"sequenza": [
			{"tipo": "dialogo", "chi": "brawler", "testo": "So what's your choice?"},
		],
		"scelte": [
			{"testo": "Evil option", "genere": "malvagio", "tempo": 6.0, "vai": "scatto_prova"},
			{"testo": "Hero option", "genere": "eroe", "tempo": 6.0, "vai": "scatto_prova"},
			{"testo": "Choice 1", "vai": "scatto_prova"},
			{"testo": "Choice 2", "vai": "scatto_prova"},
			{"testo": "Choice 3", "vai": "scatto_prova"},
		],
		"destra": {"id": "brawler", "espr": "decisa"},
	}

func apri_dialogo(finto: Dictionary = {}) -> void:
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	if not finto.is_empty():
		GameState.eventi["scatto_prova"] = finto
		GameState.nodo_corrente = "scatto_prova"
	IngressoNodo.ultimo_esito = {}
	var scena: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(scena)
	await attendi(2)

func cerca_orologio(radice: Node) -> Node:
	for figlio in radice.get_children():
		if figlio.has_signal("scaduto"):
			return figlio
		var dentro := cerca_orologio(figlio)
		if dentro != null:
			return dentro
	return null

func salva(quale: String) -> void:
	var immagine := get_viewport().get_texture().get_image()
	var percorso := "%s%s.png" % [CARTELLA, quale]
	immagine.save_png(ProjectSettings.globalize_path(percorso))
	print("scatto salvato: %s  (%dx%d)" % [percorso, immagine.get_width(), immagine.get_height()])
