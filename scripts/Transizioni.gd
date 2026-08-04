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
const CATENA_MASSIMA := 8   # oltre questo due scene si stanno rimpallando a vicenda

var velo: ColorRect
var in_corso := false
# Una scena che, appena entrata nell'albero, chiede subito di andare altrove.
# Succede davvero: una stanza del Vuoto tira l'agguato dentro il suo _ready() e
# parte per il combattimento senza che il giocatore abbia visto niente.
var prossima := ""

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
	if percorso == "":
		return
	if in_corso:
		# QUESTA RIGA E' UN BUG CHE E' COSTATO UNA PARTITA. Prima qui c'era un
		# "return" secco, e la richiesta spariva nel nulla. Il caso: vinci un
		# agguato a Meridia, il combattimento chiama vai(eventi), la stanza
		# rientra nell'albero e dentro il suo _ready() tira subito un altro
		# agguato - ma la transizione precedente non e' ancora finita (in_corso
		# resta acceso finche' il velo non si e' rialzato, tre decimi di secondo
		# dopo che la scena e' gia' dentro). Quel vai(combattimento) veniva
		# ingoiato: la stanza restava li' senza testo e senza uscite, e il
		# giocatore era bloccato per sempre.
		#
		# Adesso si mette in fila. Il velo continua a mangiare i click, quindi la
		# guardia fa ancora il suo mestiere vero - impedire che un doppio click
		# apra due stanze - senza buttare via una navigazione legittima.
		prossima = percorso
		return
	in_corso = true
	velo.color = Color(Stile.colore("velo"), velo.color.a)
	velo.mouse_filter = Control.MOUSE_FILTER_STOP  # da qui in poi i click non passano
	var durata := Stile.tempo("transizione_scena")
	var chiusura := create_tween()
	chiusura.tween_property(velo, "color:a", 1.0, durata)
	await chiusura.finished
	# Si resta al buio finche' le scene smettono di rimbalzare: chi entra e
	# riparte subito non deve comparire per un istante e poi sparire
	var destinazione := percorso
	var passaggi := 0
	while destinazione != "":
		get_tree().change_scene_to_file(destinazione)
		# un frame perche' la nuova scena entri nell'albero e possa dire la sua
		await get_tree().process_frame
		destinazione = prossima
		prossima = ""
		passaggi += 1
		if passaggi > CATENA_MASSIMA:
			push_error("Transizioni: %d cambi di scena di fila, due schermate si rimpallano" % passaggi)
			break
	var apertura := create_tween()
	apertura.tween_property(velo, "color:a", 0.0, durata)
	await apertura.finished
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	in_corso = false
	# E QUI C'ERA ANCORA IL BUCO. Il ciclo qui sopra legge "prossima" un frame
	# dopo il cambio di scena, ma il _ready() della scena appena entrata non e'
	# detto che sia gia' girato a quel punto: dipende da quando Godot smaltisce
	# le chiamate differite. Se arriva un attimo dopo, la richiesta finiva in
	# "prossima" e non la raccoglieva piu' nessuno - stessa schermata vuota di
	# prima, solo piu' difficile da incontrare.
	#
	# Adesso si guarda di nuovo alla fine, quando la transizione e' chiusa per
	# davvero e in_corso e' gia' tornato falso. Non esiste piu' nessun istante
	# in cui una richiesta puo' entrare e non essere raccolta da nessuno.
	if prossima != "":
		var rimasta := prossima
		prossima = ""
		vai(rimasta)
