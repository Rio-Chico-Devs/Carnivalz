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

func attendi(quanti: int) -> void:
	for i in quanti:
		await get_tree().process_frame

func prepara(quale: String) -> void:
	match quale:
		"menu":
			await apri_dialogo()
			await attendi(10)
			Pausa.apri()
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
			# LA RAFFICA FERMATA A META'. I pugni durano mezzo secondo l'uno: a
			# occhio nudo non si vede dove finiscono, e senza vederlo non si puo'
			# dire se stanno dentro il quadrante o gli escono fuori.
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["veronica"]
			var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(scontro)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			scontro.minigioco.avvia({"quanti": 14, "intervallo": 0.34,
					"durata": 0.52, "danno": 9})
			var argomenti := OS.get_cmdline_user_args()
			var quando := int(argomenti[1]) if argomenti.size() > 1 else 40
			await attendi(quando)
			if scontro.minigioco.pugni.is_empty():
				push_error("nessun pugno a schermo: non c'e' niente da fotografare")
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
