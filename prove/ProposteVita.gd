extends Control
# GLI EFFETTI DI VITA, GIRATI DAL GIOCO VERO. Provvisorio come FilmSalita.
#
# Prima era una vetrina di prototipi (docs/vita.md). Bru ha scelto: «mattanza
# approvata, bellissima ma vogliamo che la barra sia più grande dentro ci
# metteremo un artwork, bello anche lo spacco che ti introduce al combattimento,
# bello tutto tranne le particelle che si muovono nello sfondo e le immagini che
# galleggiano». Quelli approvati adesso stanno nel gioco, e qui si filmano
# facendoli succedere davvero: niente di quello che si vede e' disegnato da
# questo file.
#
#   squarcio    Transizioni.vai verso lo scontro (Squarcio.gd)
#   mattanza    la Mattanza chiamata sul nemico (TaglioMattanza.gd)
#   turno       il turno che passa a Veronica, al nemico, a te (FasciaTurno.gd)
#   collisioni  la raffica giocata: parate e colpi presi (RiquadroRaffica.gd)
#
#   ./prove/film_vita.sh             li gira tutti in scatti/proposte_vita/
#   ./prove/film_vita.sh mattanza    uno solo
#   nell'editor: ProposteVita.tscn, F6 (fa la Mattanza)

const DURATE := {"squarcio": 3.0, "mattanza": 3.6, "turno": 5.6, "collisioni": 15.0}
const ASSESTAMENTO := 90   # fotogrammi prima di cominciare: lo scontro si dispone
# la mano del film: para quello acceso dopo REAZIONE secondi, tranne quando
# si accende per quarto, settimo, decimo e ultimo - quelli ti prendono
const PARATE := [0, 1, 2, 4, 5, 7, 8, 10]
const REAZIONE := 0.42

var scena: Node
var nome := "mattanza"
var tempo := -1.0
var fatti: Dictionary = {}
var gioco: MinigiocoCombattimento


func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	if argomenti.size() > 1 and String(argomenti[0]) == "film":
		nome = String(argomenti[1])
	GameState.nuova_partita()
	GameState.party = ["anonimo", "veronica"]
	GameState.nemici_combattimento = ["marionetta"]
	if nome == "squarcio":
		# la scena di prima: il luna park del racconto. Poi si va allo scontro
		# come ci va il gioco, e questa scena se ne va con tutto il resto
		var fondale := LunaPark.new()
		fondale.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(fondale)
	else:
		scena = load("res://scenes/Combattimento.tscn").instantiate()
		add_child(scena)
	for i in ASSESTAMENTO:
		await get_tree().process_frame
	if scena != null:
		prepara()
	tempo = 0.0
	# il film comincia qui: film_vita.sh taglia i fotogrammi di prima
	print("INIZIO_FILM ", Engine.get_frames_drawn())


func prepara() -> void:
	# lo scontro a riposo, come nello scatto "plancia": il suo orologio si ferma
	# (e' a tempo reale, la marionetta attaccherebbe da sola) tranne che per la
	# Mattanza, che gira sull'orologio dello scontro
	scena.set_process(nome == "mattanza")
	scena.voce.coda.clear()
	for c: Dictionary in scena.combattenti:
		c.hp = c.hp_max
		scena.campo.aggiorna(c)
	scena.arena.imposta_pericolo(0.0)
	scena.campo.evidenzia(scena.combattenti, scena.combattenti[0])
	scena.menu.principale()
	if nome == "collisioni":
		gioco = scena.minigioco
		# la raffica del tutorial, coi suoi tempi
		for passo in GameState.personaggi.get("veronica", {}).get("tutorial_combattimento", {}).get("passi", []):
			if String((passo as Dictionary).get("azione", "")) == "minigioco":
				gioco.avvia((passo as Dictionary).get("minigioco", {}))
		gioco.salta()


func _process(delta: float) -> void:
	if tempo < 0.0:
		return
	tempo += delta
	match nome:
		"squarcio":
			if una_volta("vai", 0.6):
				Transizioni.vai(Squarcio.SCENA)
			return
		"mattanza":
			if una_volta("mattanza", 0.6):
				chiama_la_mattanza()
		"turno":
			passa_turno()
		"collisioni":
			passa_collisioni(delta)
	if tempo > float(DURATE.get(nome, 5.0)) + 0.5:
		get_tree().quit()


func una_volta(chiave: String, da: float) -> bool:
	if tempo < da or fatti.has(chiave):
		return false
	fatti[chiave] = true
	return true


func chiama_la_mattanza() -> void:
	var tu: Dictionary = {}
	var lui: Dictionary = {}
	for c: Dictionary in scena.combattenti:
		if bool(c.giocatore) and tu.is_empty():
			tu = c
		elif not bool(c.giocatore) and lui.is_empty():
			lui = c
	tu.dominio = int(GameState.regole.get("dominio", {}).get("per_segmento", 100))
	scena.usa_abilita_su(tu, "mattanza", lui)


func passa_turno() -> void:
	var giro := [[0.4, 1], [2.2, 2], [3.9, 0]]   # quando, e di chi (l'ordine di scena.combattenti)
	for passo: Array in giro:
		if una_volta("turno%d" % int(passo[1]), float(passo[0])):
			scena.campo.evidenzia(scena.combattenti, scena.combattenti[int(passo[1])])


func passa_collisioni(delta: float) -> void:
	if gioco.fase != "raffica":
		return
	gioco.passa(delta)
	var acceso := Collisioni.accesa(gioco.raffica)
	if acceso >= 0 and int(gioco.raffica[acceso].turno) in PARATE \
			and gioco.tempo - float(gioco.raffica[acceso].accesa_da) >= REAZIONE:
		gioco.colpisci(acceso)
