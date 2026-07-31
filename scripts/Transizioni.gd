extends CanvasLayer

# Autoload: le schermate non si sostituiscono di colpo. Ogni cambio passa da
# qui, che cala un velo nero, cambia scena mentre lo schermo e' coperto e
# rialza il velo. Sta su un CanvasLayer altissimo, quindi copre tutto, e
# durante la transizione mangia i click: niente doppio ingresso in una stanza
# perche' il giocatore ha cliccato due volte.
#
# Uso: Transizioni.vai("res://scenes/Mappa.tscn") al posto di
# get_tree().change_scene_to_file(). Non serve await: chi chiama puo'
# tranquillamente uscire dalla sua funzione subito dopo.

const LIVELLO := 128

var velo: ColorRect
var in_corso := false

func _ready() -> void:
	layer = LIVELLO
	# una dissolvenza deve poter finire anche se l'albero e' in pausa: altrimenti
	# uscire dal menu di pausa lascerebbe lo schermo nero per sempre
	process_mode = Node.PROCESS_MODE_ALWAYS
	velo = ColorRect.new()
	velo.color = Color(0, 0, 0, 0)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(velo)

func vai(percorso: String) -> void:
	if in_corso or percorso == "":
		return
	in_corso = true
	velo.color = Color(Stile.colore("velo"), velo.color.a)
	velo.mouse_filter = Control.MOUSE_FILTER_STOP  # da qui in poi i click non passano
	var durata := Stile.tempo("transizione_scena")
	var chiusura := create_tween()
	chiusura.tween_property(velo, "color:a", 1.0, durata)
	await chiusura.finished
	get_tree().change_scene_to_file(percorso)
	# un frame perche' la nuova scena entri nell'albero prima di scoprirla
	await get_tree().process_frame
	var apertura := create_tween()
	apertura.tween_property(velo, "color:a", 0.0, durata)
	await apertura.finished
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	in_corso = false
