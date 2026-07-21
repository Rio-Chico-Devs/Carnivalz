extends Control

# Combattimento a turni. Party e nemici in un'unica fila d'iniziativa
# ordinata per velocità: il più veloce di tutti agisce per primo, 1 attacco
# a testa per giro. Lo status "rabbia" può concedere (raramente) un attacco
# extra nello stesso turno. Vita volutamente minima: pochi numeri, tutti in
# data/regole.json. Il danno subìto dal party cala in proporzione al
# livello, come probabilità di assorbire il colpo.

signal azione_scelta(bersaglio: Dictionary)

const SCENA_EVENTI := "res://scenes/Main.tscn"
const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_RITRATTO := preload("res://scenes/Ritratto.tscn")

@onready var fila_party: HBoxContainer = %Party
@onready var fila_nemici: HBoxContainer = %Nemici
@onready var diario: RichTextLabel = %Diario
@onready var azioni: HBoxContainer = %Azioni

var combattenti: Array[Dictionary] = []
var in_corso := true
var giocatore_ha_vinto := false

func _ready() -> void:
	for id_classe in GameState.party:
		aggiungi_combattente(id_classe, true)
	for id_nemico in GameState.nemici_combattimento:
		aggiungi_combattente(id_nemico, false)
	combattenti.sort_custom(func(a, b): return a.velocita > b.velocita)
	scrivi("[b]Il Carnivalz fa spazio: si combatte.[/b]")
	esegui_scontro()

func aggiungi_combattente(id_personaggio: String, giocatore: bool) -> void:
	var dati: Dictionary = GameState.personaggi.get(id_personaggio, {})
	var hp_max := int(dati.get("hp", GameState.regole.get("hp_base", 5)))
	var scheda := VBoxContainer.new()
	var ritratto := SCENA_RITRATTO.instantiate()
	scheda.add_child(ritratto)
	var vita := Label.new()
	vita.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scheda.add_child(vita)
	if giocatore:
		fila_party.add_child(scheda)
		ritratto.mostra(id_personaggio, GameState.livello_di(id_personaggio))
	else:
		fila_nemici.add_child(scheda)
		ritratto.mostra(id_personaggio)
	var combattente := {
		"indice": combattenti.size(),
		"id": id_personaggio,
		"nome": dati.get("nome", id_personaggio),
		"hp": hp_max,
		"hp_max": hp_max,
		"velocita": int(dati.get("velocita", 3)),
		"giocatore": giocatore,
		"stati": [],
		"scheda": scheda,
		"etichetta_vita": vita,
	}
	combattenti.append(combattente)
	aggiorna_scheda(combattente)

func esegui_scontro() -> void:
	while in_corso:
		for combattente in combattenti:
			if not in_corso:
				break
			if combattente.hp <= 0:
				continue
			await esegui_turno(combattente)
			var prob_extra := float(GameState.regole.get("probabilita_attacco_extra_rabbia", 0.35))
			if in_corso and combattente.hp > 0 and "rabbia" in combattente.stati \
					and GameState.rng.randf() < prob_extra:
				scrivi("%s è in preda alla rabbia e attacca di nuovo!" % combattente.nome)
				await esegui_turno(combattente)
	await get_tree().create_timer(1.4).timeout
	_esci()

func esegui_turno(attaccante: Dictionary) -> void:
	evidenzia(attaccante)
	var bersaglio: Dictionary
	if attaccante.giocatore:
		mostra_azioni()
		bersaglio = await azione_scelta
	else:
		await get_tree().create_timer(0.8).timeout
		var possibili := vivi(true)
		bersaglio = possibili[GameState.rng.randi_range(0, possibili.size() - 1)]
	attacca(attaccante, bersaglio)

func mostra_azioni() -> void:
	for figlio in azioni.get_children():
		figlio.queue_free()
	for nemico in vivi(false):
		var bottone := Button.new()
		bottone.text = "Attacca %s" % nemico.nome
		bottone.pressed.connect(_scegli.bind(nemico))
		azioni.add_child(bottone)

func _scegli(bersaglio: Dictionary) -> void:
	for figlio in azioni.get_children():
		figlio.queue_free()
	azione_scelta.emit(bersaglio)

func attacca(attaccante: Dictionary, bersaglio: Dictionary) -> void:
	var danno := int(GameState.regole.get("danno_attacco", 1))
	if bersaglio.giocatore:
		# il danno subìto cala in proporzione al livello
		var riduzione := minf(
			(GameState.livello_di(bersaglio.id) - 1)
				* float(GameState.regole.get("riduzione_danno_per_livello", 0.1)),
			float(GameState.regole.get("riduzione_danno_massima", 0.5)))
		if GameState.rng.randf() < riduzione:
			danno = 0
	if danno <= 0:
		scrivi("%s attacca %s, che assorbe il colpo!" % [attaccante.nome, bersaglio.nome])
		return
	bersaglio.hp = maxi(bersaglio.hp - danno, 0)
	scrivi("%s attacca %s: %d danno." % [attaccante.nome, bersaglio.nome, danno])
	aggiorna_scheda(bersaglio)
	if bersaglio.hp <= 0:
		_su_ko(bersaglio)

func _su_ko(caduto: Dictionary) -> void:
	scrivi("[i]%s è a terra![/i]" % caduto.nome)
	if GameState.regole.get("rabbia_su_ko_alleato", false):
		for alleato in vivi(caduto.giocatore):
			if "rabbia" not in alleato.stati:
				alleato.stati.append("rabbia")
				scrivi("%s ribolle di rabbia!" % alleato.nome)
	if vivi(false).is_empty():
		giocatore_ha_vinto = true
		in_corso = false
		scrivi("[b]Vittoria! Il party guadagna esperienza.[/b]")
	elif vivi(true).is_empty():
		in_corso = false
		scrivi("[b]Il party è a terra. Il Carnivalz ha vinto.[/b]")

func vivi(giocatore: bool) -> Array[Dictionary]:
	var risultato: Array[Dictionary] = []
	for combattente in combattenti:
		if combattente.giocatore == giocatore and combattente.hp > 0:
			risultato.append(combattente)
	return risultato

func evidenzia(attivo: Dictionary) -> void:
	for combattente in combattenti:
		if combattente.hp <= 0:
			continue
		var suo_turno: bool = combattente.indice == attivo.indice
		combattente.scheda.modulate = Color.WHITE if suo_turno else Color(1, 1, 1, 0.65)

func aggiorna_scheda(combattente: Dictionary) -> void:
	if combattente.hp <= 0:
		combattente.etichetta_vita.text = "KO"
		combattente.scheda.modulate = Color(0.5, 0.4, 0.4, 0.5)
	else:
		combattente.etichetta_vita.text = "♥ %d/%d" % [combattente.hp, combattente.hp_max]

func scrivi(riga: String) -> void:
	diario.append_text(riga + "\n")

func _esci() -> void:
	if giocatore_ha_vinto:
		GameState.premia_vittoria()
		GameState.nodo_corrente = GameState.nodo_se_vinci
		get_tree().change_scene_to_file(SCENA_EVENTI)
	elif GameState.nodo_se_perdi != "":
		GameState.nodo_corrente = GameState.nodo_se_perdi
		GameState.annulla_combattimento()
		get_tree().change_scene_to_file(SCENA_EVENTI)
	else:
		GameState.reset_campagna()
		get_tree().change_scene_to_file(SCENA_MAPPA)
