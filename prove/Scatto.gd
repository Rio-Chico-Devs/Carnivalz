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
	if quale != "rottura" and quale != "nastro":
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
