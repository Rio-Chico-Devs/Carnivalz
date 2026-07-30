extends Control

# Menu del party: mostra SOLO le classi sbloccate (il totale non si deve
# intuire) e si riadatta man mano che i personaggi entrano o escono dai
# disponibili. Il protagonista fa sempre parte del party.

const SCENA_EVENTI := "res://scenes/Main.tscn"
const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_RITRATTO := preload("res://scenes/Ritratto.tscn")

@onready var lista: HBoxContainer = %Lista
@onready var bottone_inizia: Button = %BottoneInizia
@onready var bottone_mappa: Button = %BottoneMappa

var carte: Dictionary = {}

func _ready() -> void:
	bottone_inizia.pressed.connect(_su_inizia)
	bottone_mappa.pressed.connect(_su_mappa)
	for id_classe in GameState.classi_sbloccate:
		var carta := SCENA_RITRATTO.instantiate()
		lista.add_child(carta)
		carta.mostra(id_classe, GameState.livello_di(id_classe))
		var psiche: String = GameState.classi.get(id_classe, {}).get("psiche", "")
		var nome_psiche: String = GameState.psichi.get(psiche, {}).get("nome", "")
		carta.imposta_extra("Stress %d · %s" % [GameState.stress_di(id_classe), nome_psiche])
		carta.mouse_filter = Control.MOUSE_FILTER_STOP
		carta.gui_input.connect(_su_carta.bind(id_classe))
		carte[id_classe] = carta
	aggiorna_selezione()

func _su_carta(evento: InputEvent, id_classe: String) -> void:
	if not (evento is InputEventMouseButton and evento.pressed \
			and evento.button_index == MOUSE_BUTTON_LEFT):
		return
	if id_classe == GameState.id_protagonista:
		return  # le sue avventure: non si sfila dal party
	if id_classe in GameState.party:
		GameState.party.erase(id_classe)
	else:
		GameState.party.append(id_classe)
	aggiorna_selezione()

func aggiorna_selezione() -> void:
	for id_classe in carte:
		var nel_party: bool = id_classe in GameState.party
		carte[id_classe].modulate = Color.WHITE if nel_party else Color(1, 1, 1, 0.4)

func _su_inizia() -> void:
	Transizioni.vai(SCENA_EVENTI)

func _su_mappa() -> void:
	GameState.reset_campagna()
	Transizioni.vai(SCENA_VUOTO)
