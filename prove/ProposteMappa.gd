extends Control

# LA MAPPA DI ZONA, TRE PROPOSTE. Provvisorio: se ne va quando Bru ne sceglie una
# e la mappa vera nasce da li', come e' successo con la crescita.
#
# Bru, dopo aver tolto il filo dei piani: «ora accupiamoci della mappa
# riusciamo a migliorare anche questa?». Cosa non va nella mappa di oggi e perche'
# sta in docs/mappa.md; qui ci sono le tre strade, disegnate sulle zone vere
# con le regole vere (cosa sai, dove arrivi):
#   a  LA VETRINA   il plastico 3D nella lingua della mappa stellare, coi piani
#                   aperti come un cassettiera (prove/mappa/VetrinaMappa.gd)
#   b  IL MANIFESTO il plastico di carta, arancio e nero come la pausa e la
#                   crescita, coi piani in pila (prove/mappa/ManifestoMappa.gd)
#   c  PIANTA E SEZIONE  un piano alla volta visto dall'alto, e di fianco
#                   l'edificio tagliato in due (prove/mappa/PiantaMappa.gd)
#
#   ./prove/proposte_mappa.sh      le fotografa in scatti/proposte_mappa/
#   nell'editor, F6: destra e sinistra cambiano tavola

const Modello := preload("res://prove/mappa/ModelloMappa.gd")
const STILI := {"0": preload("res://prove/mappa/OggiMappa.gd"), "a": preload("res://prove/mappa/VetrinaMappa.gd"), "b": preload("res://prove/mappa/ManifestoMappa.gd"),
		"c": preload("res://prove/mappa/PiantaMappa.gd")}
const CARTELLA := "res://scatti/proposte_mappa"
# [nome, stile, zona, opzioni]: "piano" il piano in primo piano, "punta" la stanza sotto il cursore
const TAVOLE := [
	["0_oggi", "0", "casa", {}],
	["a1_casa", "a", "casa", {}],
	["a2_casa_piano_terra", "a", "casa", {"piano": 0, "punta": "cucina"}],
	["a3_sede", "a", "sede", {"punta": "infermeria"}],
	["b1_casa", "b", "casa", {}],
	["b2_casa_piano_terra", "b", "casa", {"piano": 0, "punta": "cucina"}],
	["b3_sede", "b", "sede", {"punta": "infermeria"}],
	["c1_casa", "c", "casa", {}],
	["c2_casa_piano_terra", "c", "casa", {"piano": 0, "punta": "cucina"}],
	["c3_sede", "c", "sede", {"punta": "infermeria"}],
]
# LA CASA GIGANTE A META': la casa girata dalla soglia all'attico, la botola
# scesa fino all'altare (il boss e' li', non ancora battuto), il giardino appena
# cominciato. Sei piani visti su sei: e' il caso in cui una mappa regge o no
const CASA_VISTE := ["soglia", "salone", "sala_principale", "cucina", "ala_destra", "ala_sinistra", "scala",
		"stanza_giochi", "grande_bagno", "soffitta", "attico", "camera_da_letto", "stanza_studi", "tunnel", "altare",
		"giardino_ingresso", "giardino"]
# dove li metteremo, quando ci saranno: per far vedere come si legge chi c'e'
const SEDE_CHI := {"sala_allenamento": ["Veronica"], "infermeria": ["Dr. Reika"]}

var indice := 0
var tavola: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var foto := "foto" in OS.get_cmdline_user_args()
	mostra(0)
	if not foto:
		return
	DirAccess.make_dir_recursive_absolute(CARTELLA)
	var solo := ""
	for argomento in OS.get_cmdline_user_args():
		solo = argomento if argomento != "foto" else solo
	for i in TAVOLE.size():
		if not String(TAVOLE[i][0]).begins_with(solo):
			continue
		mostra(i)
		for k in (70 if String(TAVOLE[i][1]) == "0" else 6):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var immagine := get_viewport().get_texture().get_image()
		immagine.save_png(CARTELLA.path_join("%s.png" % TAVOLE[i][0]))
		print("tavola: %s" % TAVOLE[i][0])
	get_tree().quit()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_right"):
		mostra((indice + 1) % TAVOLE.size())
	elif evento.is_action_pressed("ui_left"):
		mostra((indice - 1 + TAVOLE.size()) % TAVOLE.size())


func mostra(quale: int) -> void:
	indice = quale
	var voce: Array = TAVOLE[quale]
	if tavola != null:
		remove_child(tavola)
		tavola.queue_free()
	var modello := Modello.new()
	modello.leggi(prepara(String(voce[2])))
	tavola = (STILI[voce[1]] as GDScript).new()
	add_child(tavola)
	tavola.call("prepara", modello, voce[3])


func prepara(zona: String) -> Dictionary:
	# lo stato del gioco per quella tavola; torna chi c'e' dove
	GameState.nuova_partita()
	if zona == "sede":
		GameState.avvia_carnivalz("sede", "res://data/events_sede.json")
		GameState.imposta_flag(String(GameState.mappa_zona.get("flag_completamento", "")))
		GameState.nodo_corrente = "alloggio"
		for id_stanza in ["alloggio", "mensa", "emporio", "sala_allenamento", "infermeria", "sala_operativa"]:
			GameState.nodi_visitati.append(id_stanza)
		return SEDE_CHI
	GameState.avvia_carnivalz("casa_gigante", "res://data/vuoti/casa_gigante.json")
	for id_stanza: String in CASA_VISTE:
		GameState.nodi_visitati.append(id_stanza)
		GameState.sblocca_stanza(id_stanza)
	GameState.nodo_corrente = "scala"
	return {"camera_da_letto": ["Yhvina"]}
