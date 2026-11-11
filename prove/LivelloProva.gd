extends Node2D
# UN LIVELLO DISEGNATO, DA ATTRAVERSARE A PIEDI. La mappa e' un disegno intero
# (art/livelli/<nome>.png), non tessere: lo si guarda dall'alto e un po' di
# fronte come i mondi (prove/MondoProva.gd), con la telecamera che segue.
# Dove si cammina, le porte, le stanze, quanto si ingrandisce e le cose alte
# che le passano davanti stanno nella pianta accanto (art/livelli/<nome>.json,
# prove/LivelloPianta.gd).
# Provvisorio come i mondi: e' la prova di come ci si muove dentro un livello
# disegnato, non ancora un pezzo del gioco.
#
# I livelli: le Pianure di Redenna, il primo («ecco come mi piacerebbe che
# fosse la mappa delle pianure»), e il Panottico silenzioso, dietro la porta
# enorme oltre l'altare della Casa Gigante («riesci a replicare questa mappa?
# questo è il livello sottostante nella grande casa, quello bloccato
# all'accesso»).
#
#   frecce o WASD   cammina          P   lui / lei
#
#   nell'editor: F6 su prove/LivelloProva.tscn
#
# Dalla riga di comando (dopo --): livello pianure|panottico (se manca, le
# Pianure), protagonista lui|lei, film
# (il pilota automatico fa il giro della pianta e chiude), anteprima N (la
# foto del fotogramma N, in scatti/livelli/).

const Pianta := preload("res://prove/LivelloPianta.gd")
const PASSO_PX := 5.0            # i pixel di strada per ogni tempo del passo, come nei mondi
const RESPIRO := 1.6
const LARGO_FOTOGRAMMA := 32
const BUIO := 0.3                # quanto dura il buio quando si passa una porta
const CARTA := Color("#efd8b2")
const SEGNALE := Color("#f29a2e")
const FONDO := Color("#0b0e14")

var livello := "pianure"
var protagonista := "lei"
var film := false
var anteprima := -1

var pianta: Pianta
var io: Sprite2D
var camera: Camera2D
var hud: Control

var piedi := Vector2.ZERO
var verso := Vector2i(0, 1)
var passo := 0.0                 # la strada fatta camminando, in pixel; 0 da fermi
var fermo_da := 0.0
var stanza_qui := ""
var cartello := {}               # {titolo, eta}
var buio := 0.0
var tappa := 1                   # il pilota: il prossimo punto del giro
var bloccato := 0.0
var vicino := INF                # il pilota: quanto e' arrivato vicino alla tappa
var fotogrammi := 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	leggi_la_riga_di_comando()
	pianta = Pianta.new()
	if not pianta.carica(livello):
		push_error(pianta.errore)
		return
	costruisci()


func leggi_la_riga_di_comando() -> void:
	var argomenti := OS.get_cmdline_user_args()
	for j in argomenti.size():
		var dopo := argomenti[j + 1] if j + 1 < argomenti.size() else ""
		match argomenti[j]:
			"livello":
				livello = dopo
			"protagonista":
				protagonista = "lui" if dopo == "lui" else "lei"
			"film":
				film = true
			"anteprima":
				anteprima = int(dopo)


func costruisci() -> void:
	# il buio intorno, la mappa, il protagonista sopra
	var fondo := ColorRect.new()
	fondo.color = Color.BLACK
	fondo.position = pianta.limiti.position - Vector2(2000, 2000)
	fondo.size = pianta.limiti.size + Vector2(4000, 4000)
	add_child(fondo)
	var mappa := Sprite2D.new()
	mappa.centered = false
	mappa.scale = Vector2.ONE * pianta.scala * pianta.pixel
	mappa.texture = trama(pianta.mappa, "python3 strumenti/livelli/ricalca_livello.py")
	add_child(mappa)
	# lei e le cose alte stanno insieme, in ordine di piede: chi ha il piede
	# piu' in basso e' davanti. Le cose alte sono pezzi della mappa ritagliati
	# (le chiome degli alberi), rimessi esattamente al loro posto
	var mondo := Node2D.new()
	mondo.y_sort_enabled = true
	add_child(mondo)
	if not pianta.mappa_sopra.is_empty():
		var alte := trama(pianta.mappa_sopra, "python3 strumenti/livelli/ricalca_livello.py")
		for cosa in pianta.sopra:
			var r: Rect2 = cosa["rett"]
			var piede: float = cosa["piede"]
			var pezzo := Sprite2D.new()
			pezzo.texture = alte
			pezzo.centered = false
			pezzo.region_enabled = true
			# in pixel della mappa: il rettangolo allargato ai pixel interi
			var k := pianta.scala * pianta.pixel
			var da := (r.position / k).floor()
			var a := (r.end / k).ceil()
			pezzo.region_rect = Rect2(da, a - da)
			pezzo.scale = Vector2.ONE * k
			pezzo.position = Vector2(da.x * k, piede)
			pezzo.offset = Vector2(0, da.y - piede / k)
			mondo.add_child(pezzo)
	io = Sprite2D.new()
	io.vframes = 3
	io.centered = false
	mondo.add_child(io)
	metti_foglio(protagonista)
	piedi = pianta.partenza
	verso = pianta.verso
	camera = Camera2D.new()
	camera.zoom = Vector2.ONE * pianta.ingrandimento
	camera.limit_left = int(pianta.limiti.position.x)
	camera.limit_top = int(pianta.limiti.position.y)
	camera.limit_right = int(pianta.limiti.end.x)
	camera.limit_bottom = int(pianta.limiti.end.y)
	add_child(camera)
	camera.make_current()
	var strato := CanvasLayer.new()
	strato.layer = 2
	add_child(strato)
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strato.add_child(hud)
	hud.draw.connect(disegna_hud)
	segui()


func trama(percorso: String, come_rifarla: String) -> ImageTexture:
	var img := Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	if FileAccess.file_exists(percorso):
		var letta := Image.load_from_file(percorso)
		if letta != null and not letta.is_empty():
			letta.convert(Image.FORMAT_RGBA8)
			img = letta
	else:
		push_warning("manca %s: %s" % [percorso, come_rifarla])
	return ImageTexture.create_from_image(img)


func metti_foglio(chi: String) -> void:
	# lo stesso foglio dei mondi (MondoProva.metti_foglio): 10 colonne (fermo,
	# il respiro, gli otto tempi del passo) x 3 righe (giu', su, destra), i
	# piedi al centro tre righe sopra il fondo del fotogramma
	io.texture = trama("res://art/pianeti/protagonista/%s.png" % chi, "python3 strumenti/protagonisti/disegna.py")
	io.hframes = maxi(1, int(io.texture.get_width() / float(LARGO_FOTOGRAMMA)))
	var fotogramma := Vector2(LARGO_FOTOGRAMMA, io.texture.get_height() / 3.0)
	io.offset = -Vector2(fotogramma.x / 2.0, fotogramma.y - 3.0)


# ---------------------------------------------------------------- il giro

func _process(delta: float) -> void:
	if io == null:
		return
	var direzione := Vector2.ZERO
	if film:
		direzione = pianta.verso_il_giro(piedi, tappa)
		if direzione == Vector2.ZERO and tappa < pianta.giro.size():
			tappa += 1
			vicino = INF
			direzione = pianta.verso_il_giro(piedi, tappa)
	else:
		direzione = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if direzione == Vector2.ZERO:
			direzione = Vector2(
				float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
				float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
	cammina(direzione, delta)
	var porta := pianta.porta_a(piedi)
	if porta >= 0:
		passa(porta)
	buio = maxf(0.0, buio - delta)
	if not cartello.is_empty():
		cartello["eta"] = float(cartello["eta"]) + delta
	segui()
	hud.queue_redraw()
	fotogrammi += 1
	if anteprima >= 0 and fotogrammi == anteprima:
		fotografa("anteprima")
	if film:
		controlla_il_pilota(delta)


func cammina(direzione: Vector2, delta: float) -> void:
	if direzione == Vector2.ZERO:
		passo = 0.0
		fermo_da += delta
		return
	fermo_da = 0.0
	var prima := piedi
	piedi = pianta.cammina(piedi, direzione, delta)
	if absf(direzione.x) > absf(direzione.y):
		verso = Vector2i(int(signf(direzione.x)), 0)
	else:
		verso = Vector2i(0, int(signf(direzione.y)))
	# il passo va con la strada fatta, non col tempo: i piedi non pattinano
	passo += piedi.distance_to(prima)


func passa(porta: int) -> void:
	# una porta chiusa del disegno: ci entri e sei dall'altra parte, dopo un
	# attimo di buio
	var p: Dictionary = pianta.porte[porta]
	piedi = p["a"]
	verso = p["verso"]
	passo = 0.0
	buio = BUIO
	if film:
		tappa += 1
		vicino = INF


func segui() -> void:
	io.position = piedi.round()
	var riga := 0
	if verso.y < 0:
		riga = 1
	elif verso.x != 0:
		riga = 2
	io.flip_h = verso.x < 0
	# colonne: 0 fermo, 1 il respiro, 2-9 gli otto tempi del passo
	var colonna := 0
	if passo > 0.0:
		colonna = 2 + floori(passo / PASSO_PX) % 8
	elif fmod(fermo_da, RESPIRO) > RESPIRO - 0.5:
		colonna = 1
	io.frame = riga * io.hframes + colonna
	camera.position = piedi.round()
	var stanza := pianta.stanza_a(piedi)
	if stanza != "" and stanza != stanza_qui:
		stanza_qui = stanza
		cartello = {"titolo": stanza.to_upper(), "eta": 0.0}


func controlla_il_pilota(delta: float) -> void:
	if tappa >= pianta.giro.size():
		print("GIRO FINITO %d" % fotogrammi)
		get_tree().quit()
		return
	# fermo: non si avvicina alla tappa per due secondi (anche se scivola
	# avanti e indietro contro uno spigolo)
	var manca := piedi.distance_to(pianta.giro[tappa])
	if manca < vicino - 0.5:
		vicino = manca
		bloccato = 0.0
	else:
		bloccato += delta
	if bloccato > 2.0:
		push_error("il pilota si e' fermato a %s (nel disegno), verso la tappa %d" % [(piedi / pianta.scala).round(), tappa])
		get_tree().quit(1)


func _unhandled_input(evento: InputEvent) -> void:
	if film or io == null:
		return
	if evento is InputEventKey and evento.is_pressed() and not evento.is_echo() \
			and (evento as InputEventKey).physical_keycode == KEY_P:
		protagonista = "lei" if protagonista == "lui" else "lui"
		metti_foglio(protagonista)


# ---------------------------------------------------------------- sopra

func disegna_hud() -> void:
	if buio > 0.0:
		hud.draw_rect(Rect2(Vector2.ZERO, hud.size), Color(0, 0, 0, buio / BUIO))
	if not cartello.is_empty() and float(cartello["eta"]) < 3.0:
		disegna_cartello()
	var f := Caratteri.titolo()
	var aiuto := "FRECCE O WASD  CAMMINA      P  LUI / LEI"
	hud.draw_string(f, Vector2(26, 702), aiuto, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(FONDO, 0.8))
	hud.draw_string(f, Vector2(24, 700), aiuto, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CARTA)


func disegna_cartello() -> void:
	# il nome della stanza, come il nome della regione nei mondi (MondoHud)
	var f := Caratteri.titolo()
	var eta := float(cartello["eta"])
	var a := clampf(minf(eta * 5.0, (3.0 - eta) * 2.5), 0.0, 1.0)
	var entra_x := 1.0 - pow(1.0 - clampf(eta * 3.5, 0.0, 1.0), 3.0)
	var testo := String(cartello["titolo"])
	var corpo := 34
	var largo := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo
	var dove := Vector2(640 - largo * 0.5 + (1.0 - entra_x) * 50.0, 118)
	Manifesto.etichetta_tinta(hud, dove + Vector2(6, 6), testo, corpo, Color(0, 0, 0, 0.4 * a), Color(0, 0, 0, 0))
	Manifesto.etichetta_tinta(hud, dove, testo, corpo, Color(SEGNALE, a), Color(FONDO, a))
	Manifesto.etichetta_tinta(hud, dove + Vector2(10, -22), pianta.titolo.to_upper(), 12, Color(FONDO, a), Color(CARTA, a))


func fotografa(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var cartella := "res://scatti/livelli"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(cartella))
	get_viewport().get_texture().get_image().save_png(cartella.path_join(nome + ".png"))
	print("FOTO ", nome)
	get_tree().quit()
