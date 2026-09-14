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
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARTELLA))
	await prepara(quale)
	await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
	salva(quale)
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

func salva(quale: String) -> void:
	var immagine := get_viewport().get_texture().get_image()
	var percorso := "%s%s.png" % [CARTELLA, quale]
	immagine.save_png(ProjectSettings.globalize_path(percorso))
	print("scatto salvato: %s  (%dx%d)" % [percorso, immagine.get_width(), immagine.get_height()])
