extends Node2D
# UN PIANETA DA ESPLORARE, generato (prove/MondoGenera.gd) e disegnato con le
# tessere di art/pianeti/ (prove/MondoTessere.gd). Provvisorio: e' la prova
# di come si generano i mondi, non ancora un pezzo del gioco.
#
# Bru: «mi piacerebbe che esplorassi come in the legend of zelda, i vecchi
# giochi, a link to the past o the minish cap, ma con la differenza che è solo
# un gioco di progressi, dove rendi autonome le zone spendendo risorse fino a
# colonizzare tutto il pianeta». E: «dobbiamo concentrarci per generare le
# mappe e i mondi da esplorare che siano coerenti con il nostro stile».
#
# Visto dall'alto, pixel art a 16 pixel ingrandita tre volte, la telecamera
# che segue. Si scava nelle vene, si paga per passare da una regione
# all'altra, si ripara il faro di ogni regione: da li' la regione e' autonoma
# (produce da sola, e la corruzione se ne va a onda). Tutti i fari accesi, il
# pianeta e' colonizzato.
#
#   frecce o WASD   cammina
#   E o spazio      scava, ripara, paga, apri (la cosa davanti a te)
#   M               la mappa del pianeta
#   N               un altro pianeta (seme dopo)      B  l'altro bioma
#
#   nell'editor: F6 su prove/MondoProva.tscn
#   ./prove/mondi.sh   il film col pilota automatico, le panoramiche, i controlli
#
# Dalla riga di comando (dopo --): seme N, bioma pianure|ardente, film,
# anteprima N (la foto del fotogramma N), panoramica (il pianeta intero, 1:1).

const Genera := preload("res://prove/MondoGenera.gd")
const Tessere := preload("res://prove/MondoTessere.gd")
const Protagonisti := preload("res://prove/MondoProtagonisti.gd")
const Hud := preload("res://prove/MondoHud.gd")
const CORRUZIONE := preload("res://prove/mondo_corruzione.gdshader")
const LATO := 16
const INGRANDIMENTO := 3.0
const VELOCITA := 74.0
const PORTATA := 20.0
const PRODUZIONE := 6.0          # secondi fra un pezzo e l'altro, per ogni regione autonoma
const RICRESCITA := 25.0
const SCORTA := 5
const TINTE_CORRUZIONE := {"pianure": Color("#86305a"), "ardente": Color("#a4241e")}

# dove sta il piede di ogni oggetto dentro il suo disegno
const PIEDI := {
	"albero_1": Vector2(16, 36), "albero_2": Vector2(16, 36), "cespuglio": Vector2(8, 14),
	"sasso": Vector2(8, 14), "masso": Vector2(16, 26), "rovi": Vector2(8, 14), "rovi_2": Vector2(8, 14),
	"vena_quarzo": Vector2(8, 14), "vena_ferro": Vector2(8, 14), "vena_cristallo": Vector2(8, 14),
	"vena_vuota": Vector2(8, 14), "faro": Vector2(16, 44), "faro_rotto": Vector2(16, 44),
	"modulo": Vector2(16, 28), "lampione": Vector2(8, 29), "capsula": Vector2(16, 29),
	"forziere": Vector2(8, 14),
}

var seme := 3
var bioma := "pianure"
var m: RefCounted                       # il pianeta (MondoGenera)
var fogli := {}                         # nome -> Image
var trame := {}                         # nome -> ImageTexture
var materiale: ShaderMaterial
var maschera: Image
var maschera_tex: ImageTexture
var corrotto := PackedFloat32Array()    # quanto e' corrotta ogni casella, adesso
var onde: Array[Dictionary] = []        # {regione, da, quando}
var regione_di := PackedInt32Array()    # anche l'acqua appartiene alla regione piu' vicina

var strati: Node2D
var cose_nodo: Node2D
var io: Sprite2D
var camera: Camera2D
var hud: Control
var sprite_di := {}                     # indice della cosa -> Sprite2D (o Array di Sprite2D per i varchi)

var piedi := Vector2.ZERO
var verso := Vector2i(0, 1)
var passo := 0.0
var borsa := {"quarzo": 0, "ferro": 0, "cristallo": 0, "tazo": 0}
var tempo := 0.0
var produzione := 0.0
var visti := {}                          # le caselle viste (per la mappa)
var regione_qui := -1
var mappa_aperta := false

# il pilota automatico (il film)
var film := false
var anteprima := -1
var panoramica := false
var controllo := false
var colonizzato := false                # dalla riga di comando: il pianeta gia' tutto tuo
var protagonista := "lui"               # lui o lei: P cambia
var fotogrammi := 0
var strada: Array[Vector2i] = []
var meta := -1
var pausa_pilota := 0.0
var finito_da := -1.0
var fermo := 0.0
var scatti_fatti := {}
var colonizzate := 0
var quando_la_mappa := -1
var durata_film := -1
var ultimo_posto := Vector2.ZERO


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	leggi_la_riga_di_comando()
	if controllo:
		return
	costruisci()


func leggi_la_riga_di_comando() -> void:
	var argomenti := OS.get_cmdline_user_args()
	for j in argomenti.size():
		var a := argomenti[j]
		var dopo := argomenti[j + 1] if j + 1 < argomenti.size() else ""
		match a:
			"seme":
				seme = int(dopo)
			"bioma":
				bioma = dopo
			"film":
				film = true
				durata_film = int(dopo) if dopo.is_valid_int() else -1
			"anteprima":
				anteprima = int(dopo)
			"panoramica":
				panoramica = true
			"colonizzato":
				colonizzato = true
			"protagonista":
				protagonista = "lei" if dopo == "lei" else "lui"
			"controlla":
				controllo = true
				controlla(int(dopo))
			"tessere":
				controllo = true
				salva_le_tessere()


func salva_le_tessere() -> void:
	# i PNG di art/pianeti/<bioma>/ che non ci sono ancora, disegnati da
	# MondoTessere. Quelli che ci sono gia' non si toccano: possono essere
	# stati ridisegnati a mano. Per rifarne uno, cancellalo e rilancia
	var scritti := 0
	for quale: String in Tessere.TAVOLOZZE:
		var cartella := "res://art/pianeti/".path_join(quale)
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(cartella))
		var fogli_nuovi: Dictionary = Tessere.new(quale).tutte()
		for nome: String in fogli_nuovi:
			var percorso := cartella.path_join(nome + ".png")
			if FileAccess.file_exists(percorso):
				continue
			(fogli_nuovi[nome] as Image).save_png(percorso)
			scritti += 1
	var cartella_io := "res://art/pianeti/protagonista"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(cartella_io))
	for chi: String in ["lui", "lei"]:
		var percorso := cartella_io.path_join(chi + ".png")
		if not FileAccess.file_exists(percorso):
			Protagonisti.foglio(chi).save_png(percorso)
			scritti += 1
	print("TESSERE: %d file scritti in art/pianeti/" % scritti)
	get_tree().quit()


func controlla(quanti: int) -> void:
	# tanti semi per bioma: ognuno deve dare un pianeta che si finisce
	# (MondoGenera.controlla), al primo tentativo o ai successivi
	var primi := 0
	var buoni := 0
	for quale: String in ["pianure", "ardente"]:
		for numero in range(1, quanti + 1):
			var prova: RefCounted = Genera.new(numero, quale)
			prova.call("genera")
			var guai: Array[String] = prova.call("controlla")
			if guai.is_empty():
				primi += 1
			var finale: RefCounted = Genera.buono(numero, quale)
			var restano: Array[String] = finale.call("controlla")
			if restano.is_empty():
				buoni += 1
			else:
				print("SEME CATTIVO %s %d: %s" % [quale, numero, restano])
	print("CONTROLLO %d semi: %d buoni al primo colpo, %d buoni alla fine" % [quanti * 2, primi, buoni])
	get_tree().quit(0 if buoni == quanti * 2 else 1)


func costruisci() -> void:
	for figlio in get_children():
		figlio.queue_free()
	sprite_di.clear()
	onde.clear()
	visti.clear()
	borsa = {"quarzo": 0, "ferro": 0, "cristallo": 0, "tazo": 0}
	m = Genera.buono(seme, bioma)
	fogli = Tessere.new(bioma).carica()
	trame.clear()
	for nome: String in fogli:
		trame[nome] = ImageTexture.create_from_image(fogli[nome])
	prepara_maschera()
	strati = Node2D.new()
	add_child(strati)
	disegna_terreno()
	cose_nodo = Node2D.new()
	cose_nodo.y_sort_enabled = true
	cose_nodo.material = materiale
	strati.add_child(cose_nodo)
	metti_le_cose()
	prepara_me()
	camera = Camera2D.new()
	camera.zoom = Vector2.ONE * INGRANDIMENTO
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(m.get("w")) * LATO
	camera.limit_bottom = int(m.get("h")) * LATO
	add_child(camera)
	camera.make_current()
	var livello_hud := CanvasLayer.new()
	livello_hud.layer = 2
	add_child(livello_hud)
	hud = Hud.new()
	hud.set("scena", self)
	livello_hud.add_child(hud)
	if colonizzato:
		colonizza_tutto()
	if panoramica:
		prepara_panoramica()
	segui()


# ---------------------------------------------------------------- il terreno

func cella_ok(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < int(m.get("w")) and c.y < int(m.get("h"))


func k(c: Vector2i) -> int:
	return c.y * int(m.get("w")) + c.x


func terreno_a(c: Vector2i) -> int:
	if not cella_ok(c):
		return Genera.ACQUA
	var t: PackedByteArray = m.get("terreno")
	return t[k(c)]


func livello_a(c: Vector2i) -> int:
	if not cella_ok(c):
		return 0
	var l: PackedByteArray = m.get("livello")
	return l[k(c)]


func foglio_atlante(immagini: Array[Image], colonne: int) -> Image:
	# mette in colonna piu' fogli larghi uguali
	var alto := 0
	for img in immagini:
		alto += img.get_height()
	var tutto := Image.create_empty(colonne * LATO, alto, false, Image.FORMAT_RGBA8)
	var y := 0
	for img in immagini:
		tutto.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(0, y))
		y += img.get_height()
	return tutto


func sorgente(insieme: TileSet, img: Image) -> int:
	var s := TileSetAtlasSource.new()
	s.texture = ImageTexture.create_from_image(img)
	s.texture_region_size = Vector2i(LATO, LATO)
	for y in floori(img.get_height() / float(LATO)):
		for x in floori(img.get_width() / float(LATO)):
			s.create_tile(Vector2i(x, y))
	return insieme.add_source(s)


func strato_tessere(insieme: TileSet, spostato: bool) -> TileMapLayer:
	var t := TileMapLayer.new()
	t.tile_set = insieme
	t.material = materiale
	if spostato:
		t.position = Vector2(-LATO * 0.5, -LATO * 0.5)
	strati.add_child(t)
	return t


func disegna_terreno() -> void:
	var w: int = m.get("w")
	var h: int = m.get("h")
	var insieme := TileSet.new()
	insieme.tile_size = Vector2i(LATO, LATO)
	# l'acqua: una tessera sola, animata su quattro fotogrammi
	var acqua := TileSetAtlasSource.new()
	acqua.texture = trame["acqua"]
	acqua.texture_region_size = Vector2i(LATO, LATO)
	acqua.create_tile(Vector2i.ZERO)
	acqua.set_tile_animation_columns(Vector2i.ZERO, 4)
	acqua.set_tile_animation_frames_count(Vector2i.ZERO, 4)
	for f in 4:
		acqua.set_tile_animation_frame_duration(Vector2i.ZERO, f, 0.42)
	var id_acqua := insieme.add_source(acqua)
	var id_terreni := {}
	for nome: String in ["sabbia", "terra", "erba", "prato"]:
		var pezzi: Array[Image] = [fogli[nome], fogli[nome + "_varianti"]]
		id_terreni[nome] = sorgente(insieme, foglio_atlante(pezzi, 4))
	var id_rupe := sorgente(insieme, fogli["rupe"])
	var id_ombra := sorgente(insieme, ombra_della_parete())
	var fondo := strato_tessere(insieme, false)
	for y in h:
		for x in w:
			fondo.set_cell(Vector2i(x, y), id_acqua, Vector2i.ZERO)
	# la doppia griglia: la tessera (x, y) sta a cavallo delle caselle
	# (x-1, y-1), (x, y-1), (x-1, y), (x, y)
	var livelli := {"sabbia": Genera.SABBIA, "terra": Genera.TERRA, "erba": Genera.ERBA, "prato": Genera.PRATO}
	for nome: String in ["sabbia", "terra", "erba", "prato"]:
		var soglia: int = livelli[nome]
		var t := strato_tessere(insieme, true)
		for y in h + 1:
			for x in w + 1:
				var mask := 0
				if terreno_a(Vector2i(x - 1, y - 1)) >= soglia:
					mask |= 1
				if terreno_a(Vector2i(x, y - 1)) >= soglia:
					mask |= 2
				if terreno_a(Vector2i(x - 1, y)) >= soglia:
					mask |= 4
				if terreno_a(Vector2i(x, y)) >= soglia:
					mask |= 8
				if mask == 0:
					continue
				var dove := Vector2i(mask % 4, floori(mask / 4.0))
				if mask == 15:
					var caso := Tessere.dado(x, y, soglia)
					if caso > 0.72:
						dove = Vector2i(1 + floori((caso - 0.72) / 0.28 * 2.99), 4)
				t.set_cell(Vector2i(x, y), int(id_terreni[nome]), dove)
	# le rupi: la parete sotto l'orlo sud, alta due caselle; l'ombra al piede;
	# l'orlo intorno all'alto
	var pareti := strato_tessere(insieme, false)
	var orli := strato_tessere(insieme, false)
	for y in h:
		for x in w:
			var c := Vector2i(x, y)
			if livello_a(c) == 1:
				var lati := 0
				if livello_a(c + Vector2i(0, -1)) == 0:
					lati |= 1
				if livello_a(c + Vector2i(1, 0)) == 0:
					lati |= 2
				if livello_a(c + Vector2i(0, 1)) == 0:
					lati |= 4
				if livello_a(c + Vector2i(-1, 0)) == 0:
					lati |= 8
				if lati != 0:
					orli.set_cell(c, id_rupe, Vector2i(lati % 4, 2 + floori(lati / 4.0)))
				continue
			var riga := -1
			if livello_a(c + Vector2i(0, -1)) == 1:
				riga = 0
			elif livello_a(c + Vector2i(0, -2)) == 1:
				riga = 1
			if riga < 0:
				if livello_a(c + Vector2i(0, -3)) == 1 and livello_a(c + Vector2i(0, -1)) == 0:
					pareti.set_cell(c, id_ombra, Vector2i.ZERO)
				continue
			var sx := livello_a(c + Vector2i(-1, -1 - riga)) == 1 and livello_a(c + Vector2i(-1, 0)) == 0
			var dx := livello_a(c + Vector2i(1, -1 - riga)) == 1 and livello_a(c + Vector2i(1, 0)) == 0
			var pezzo := 2
			if not sx and not dx:
				pezzo = 0
			elif not sx:
				pezzo = 1
			elif not dx:
				pezzo = 3
			pareti.set_cell(c, id_rupe, Vector2i(pezzo, riga))
	# i ponti e i campi stanno per terra: sopra il terreno, sotto le cose
	disegna_a_terra()


func ombra_della_parete() -> Image:
	var img := Image.create_empty(LATO, LATO, false, Image.FORMAT_RGBA8)
	for y in 5:
		for x in LATO:
			img.set_pixel(x, y, Color(0.04, 0.03, 0.08, 0.42 - float(y) * 0.08))
	return img


var a_terra: Node2D


func disegna_a_terra() -> void:
	a_terra = Node2D.new()
	a_terra.material = materiale
	strati.add_child(a_terra)


func sprite(nome: String, cella: Vector2i, sul_terreno: bool) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = trame[nome]
	s.centered = false
	s.use_parent_material = true
	if sul_terreno:
		s.position = Vector2(cella * LATO)
		a_terra.add_child(s)
	else:
		var piede: Vector2 = PIEDI.get(nome, Vector2(8, 14))
		s.offset = -piede
		s.position = Vector2(cella * LATO) + Vector2(8, 14)
		cose_nodo.add_child(s)
	return s


func metti_le_cose() -> void:
	var cose: Array[Dictionary] = m.get("cose")
	for n in cose.size():
		var cosa := cose[n]
		var c: Vector2i = cosa["cella"]
		var tipo := String(cosa["tipo"])
		var caso := Tessere.dado(c.x, c.y, 77)
		match tipo:
			"albero":
				sprite_di[n] = sprite("albero_1" if caso < 0.6 else "albero_2", c, false)
			"cespuglio", "sasso", "forziere", "capsula", "modulo", "lampione":
				sprite_di[n] = sprite(tipo, c, false)
			"fiori", "campo":
				sprite_di[n] = sprite(tipo, c, true)
			"rovi":
				sprite_di[n] = sprite("rovi" if caso < 0.5 else "rovi_2", c, false)
			"vena":
				sprite_di[n] = sprite("vena_" + String(cosa["risorsa"]), c, false)
			"faro":
				sprite_di[n] = sprite("faro_rotto", c, false)
			"ponte", "scala", "rovi_varco":
				sprite_di[n] = disegna_varco(cosa, false)
		if cosa.has("colonia"):
			(sprite_di[n] as Sprite2D).visible = false


func disegna_varco(cosa: Dictionary, aperto: bool) -> Array[Sprite2D]:
	var pezzi: Array[Sprite2D] = []
	var celle: Array = cosa["celle"]
	var verso_varco: Vector2i = cosa["verso"]
	var tipo := String(cosa["tipo"])
	for c: Vector2i in celle:
		match tipo:
			"ponte":
				var nome := ("ponte_" if aperto else "ponte_rotto_") + ("o" if verso_varco.x != 0 else "v")
				pezzi.append(sprite(nome, c, true))
			"rovi_varco":
				if not aperto:
					pezzi.append(sprite("rovi_2" if (c.x + c.y) % 2 else "rovi", c, false))
			"scala":
				# la scala sta nelle caselle di parete (le altre sono l'orlo dell'alto)
				if livello_a(c) == 0:
					var s := sprite("scala" if aperto else "scala_rotta", c, true)
					s.region_enabled = true
					var riga := 0 if livello_a(c + Vector2i(0, -1)) == 1 else 1
					s.region_rect = Rect2(0, riga * LATO, LATO, LATO)
					pezzi.append(s)
	return pezzi


# ---------------------------------------------------------------- la corruzione

func prepara_maschera() -> void:
	var w: int = m.get("w")
	var h: int = m.get("h")
	# ogni casella d'acqua prende la regione della terra piu' vicina
	var reg: PackedInt32Array = m.get("regione")
	regione_di = reg.duplicate()
	var coda: Array[Vector2i] = []
	for y in h:
		for x in w:
			if regione_di[y * w + x] >= 0:
				coda.append(Vector2i(x, y))
	var testa := 0
	while testa < coda.size():
		var p := coda[testa]
		testa += 1
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q := p + d
			if cella_ok(q) and regione_di[k(q)] < 0:
				regione_di[k(q)] = regione_di[k(p)]
				coda.append(q)
	corrotto.resize(w * h)
	corrotto.fill(1.0)
	maschera = Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	maschera.fill(Color(1, 0, 0, 1))
	maschera_tex = ImageTexture.create_from_image(maschera)
	materiale = ShaderMaterial.new()
	materiale.shader = CORRUZIONE
	materiale.set_shader_parameter("corruzione", maschera_tex)
	materiale.set_shader_parameter("celle", Vector2(w, h))
	materiale.set_shader_parameter("tinta", TINTE_CORRUZIONE.get(bioma, Color("#86305a")))


func ritira_la_corruzione(delta: float) -> void:
	if onde.is_empty():
		return
	var w: int = m.get("w")
	var h: int = m.get("h")
	var cambiato := false
	var finite: Array[Dictionary] = []
	for onda in onde:
		var eta := tempo - float(onda["quando"])
		var da: Vector2i = onda["da"]
		var r := int(onda["regione"])
		var raggio := eta * 22.0
		var tutte := true
		for y in h:
			for x in w:
				var q := y * w + x
				if regione_di[q] != r or corrotto[q] <= 0.0:
					continue
				var d := Vector2(x - da.x, y - da.y).length()
				if d < raggio:
					corrotto[q] = maxf(corrotto[q] - delta * 3.0, 0.0)
					maschera.set_pixel(x, y, Color(corrotto[q], 0, 0, 1))
					cambiato = true
				if corrotto[q] > 0.0:
					tutte = false
		if tutte:
			finite.append(onda)
	for f in finite:
		onde.erase(f)
	if cambiato:
		maschera_tex.update(maschera)


# ---------------------------------------------------------------- il personaggio

func prepara_me() -> void:
	io = Sprite2D.new()
	io.texture = foglio_di(protagonista)
	io.hframes = 3
	io.vframes = 3
	io.centered = false
	# fotogrammi di 24x32, i piedi a (12, 30)
	io.offset = Vector2(-12, -30)
	cose_nodo.add_child(io)
	var da: Vector2i = m.call("partenza")
	piedi = Vector2(da * LATO) + Vector2(8, 12)


func foglio_di(chi: String) -> ImageTexture:
	# il PNG di art/pianeti/protagonista/ vince; se manca, lo disegna MondoProtagonisti
	var percorso := "res://art/pianeti/protagonista/%s.png" % chi
	var img: Image = Protagonisti.foglio(chi)
	if FileAccess.file_exists(percorso):
		var letta := Image.load_from_file(percorso)
		if letta != null and not letta.is_empty():
			letta.convert(Image.FORMAT_RGBA8)
			img = letta
	return ImageTexture.create_from_image(img)


func libero(p: Vector2) -> bool:
	# il piede e' un rettangolo di 10x6: nessuno dei suoi angoli su una casella bloccata
	var blo: PackedByteArray = m.get("bloccato")
	for angolo: Vector2 in [Vector2(-5, -3), Vector2(4.9, -3), Vector2(-5, 2.9), Vector2(4.9, 2.9)]:
		var c := Vector2i((p + angolo) / LATO)
		if not cella_ok(c) or blo[k(c)] == 1:
			return false
	return true


func cammina(direzione: Vector2, delta: float) -> void:
	if direzione == Vector2.ZERO:
		passo = 0.0
		return
	direzione = direzione.normalized()
	var spostamento := direzione * VELOCITA * delta
	var prima := piedi
	if libero(piedi + Vector2(spostamento.x, 0)):
		piedi.x += spostamento.x
	elif absf(direzione.y) < 0.3:
		piedi.y += scivola(Vector2(spostamento.x, 0), Vector2(0, 1), VELOCITA * delta)
	if libero(piedi + Vector2(0, spostamento.y)):
		piedi.y += spostamento.y
	elif absf(direzione.x) < 0.3:
		piedi.x += scivola(Vector2(0, spostamento.y), Vector2(1, 0), VELOCITA * delta)
	if absf(direzione.x) > absf(direzione.y):
		verso = Vector2i(int(signf(direzione.x)), 0)
	else:
		verso = Vector2i(0, int(signf(direzione.y)))
	if piedi != prima:
		passo += delta


func scivola(avanti: Vector2, di_lato: Vector2, passo_max: float) -> float:
	# Lo spigolo, come negli Zelda: se vai contro l'angolo di un ostacolo e
	# un poco piu' in la' si passa, il personaggio ci scivola da solo
	for scarto in range(1, 8):
		for verso_lato: float in [-1.0, 1.0]:
			var prova := piedi + di_lato * float(scarto) * verso_lato
			if libero(prova) and libero(prova + avanti):
				return verso_lato * minf(passo_max, float(scarto))
	return 0.0


func segui() -> void:
	io.position = piedi.round()
	var riga := 0
	if verso.y < 0:
		riga = 1
	elif verso.x != 0:
		riga = 2
	io.flip_h = verso.x < 0
	var fase := floori(passo * 8.0) % 4
	var colonna := [0, 1, 0, 2][fase] as int if passo > 0.0 else 0
	io.frame = riga * 3 + colonna
	if not panoramica:
		camera.position = piedi.round()
	# quello che si vede diventa noto, per la mappa
	var c := Vector2i(piedi / LATO)
	for y in range(-7, 8):
		for x in range(-11, 12):
			visti[c + Vector2i(x, y)] = true
	var reg: PackedInt32Array = m.get("regione")
	if cella_ok(c) and reg[k(c)] >= 0 and reg[k(c)] != regione_qui:
		regione_qui = reg[k(c)]
		hud.call("entra", regione_qui)


# ---------------------------------------------------------------- le cose da fare

func cosa_davanti() -> int:
	# la cosa piu' vicina al piede, entro la portata; i varchi si toccano da
	# qualunque loro casella
	var cose: Array[Dictionary] = m.get("cose")
	var migliore := -1
	var meglio := PORTATA
	for n in cose.size():
		var cosa := cose[n]
		if not si_fa(cosa):
			continue
		var celle: Array = cosa.get("celle", [cosa["cella"]])
		for c: Vector2i in celle:
			var d := (Vector2(c * LATO) + Vector2(8, 8)).distance_to(piedi) - 8.0
			if d < meglio:
				meglio = d
				migliore = n
	return migliore


func si_fa(cosa: Dictionary) -> bool:
	match String(cosa["tipo"]):
		"vena":
			return int(cosa["scorta"]) > 0
		"faro", "forziere", "ponte", "scala", "rovi_varco":
			return not bool(cosa["aperto"])
	return false


func cosa_manca(costo: Dictionary) -> Dictionary:
	var manca := {}
	for r: String in costo:
		var quanti := int(costo[r]) - int(borsa[r])
		if quanti > 0:
			manca[r] = quanti
	return manca


func invito(n: int) -> Dictionary:
	# cosa dice il cartello sopra la cosa: il verbo, il costo, cosa manca
	var cose: Array[Dictionary] = m.get("cose")
	var cosa := cose[n]
	var verbi := {"vena": "SCAVA", "faro": "RIPARA IL FARO", "forziere": "APRI",
		"ponte": "RIPARA IL PONTE", "scala": "RIFAI LA SCALA", "rovi_varco": "BRUCIA I ROVI"}
	var costo: Dictionary = cosa.get("costo", {})
	return {"verbo": verbi[String(cosa["tipo"])], "costo": costo, "manca": cosa_manca(costo)}


func agisci(n: int) -> void:
	var cose: Array[Dictionary] = m.get("cose")
	var cosa := cose[n]
	var tipo := String(cosa["tipo"])
	if tipo == "vena":
		var risorsa := String(cosa["risorsa"])
		borsa[risorsa] = int(borsa[risorsa]) + int(cosa["scorta"])
		hud.call("prende", risorsa, int(cosa["scorta"]), punto_schermo(Vector2(Vector2i(cosa["cella"]) * LATO) + Vector2(8, 4)))
		cosa["scorta"] = 0
		cosa["ricresce"] = tempo + RICRESCITA
		(sprite_di[n] as Sprite2D).texture = trame["vena_vuota"]
		return
	if tipo == "forziere":
		cosa["aperto"] = true
		borsa["tazo"] = int(borsa["tazo"]) + 30
		hud.call("prende", "tazo", 30, punto_schermo(Vector2(Vector2i(cosa["cella"]) * LATO)))
		(sprite_di[n] as Sprite2D).modulate = Color(0.6, 0.6, 0.6)
		return
	var costo: Dictionary = cosa.get("costo", {})
	if not cosa_manca(costo).is_empty():
		hud.call("manca", cosa_manca(costo))
		return
	for r: String in costo:
		borsa[r] = int(borsa[r]) - int(costo[r])
	cosa["aperto"] = true
	if tipo == "faro":
		colonizza(n)
	else:
		apri_varco(n)


func apri_varco(n: int) -> void:
	var cose: Array[Dictionary] = m.get("cose")
	var cosa := cose[n]
	var blo: PackedByteArray = m.get("bloccato")
	for c: Vector2i in cosa["celle"]:
		blo[k(c)] = 0
	m.set("bloccato", blo)
	for s: Sprite2D in sprite_di[n]:
		s.queue_free()
	sprite_di[n] = disegna_varco(cosa, true)
	var regioni: Array[Dictionary] = m.get("regioni")
	if not colonizzato:
		hud.call("annuncia", "APERTO", "VERSO " + String(regioni[int(cosa["regione"])]["nome"]).to_upper())
		scatto("varco_aperto", 30)
		scatto("di_la", 240)


func colonizza(n: int, subito := false) -> void:
	var cose: Array[Dictionary] = m.get("cose")
	var cosa := cose[n]
	var r := int(cosa["regione"])
	var regioni: Array[Dictionary] = m.get("regioni")
	regioni[r]["colonizzata"] = true
	(sprite_di[n] as Sprite2D).texture = trame["faro"]
	onde.append({"regione": r, "da": Vector2i(cosa["cella"]), "quando": tempo})
	# compaiono le case; i rovi della corruzione se ne vanno
	var blo: PackedByteArray = m.get("bloccato")
	for j in cose.size():
		var altra := cose[j]
		if int(altra.get("regione", -1)) != r:
			continue
		if altra.has("colonia"):
			var s: Sprite2D = sprite_di[j]
			s.visible = true
			if not subito:
				s.scale = Vector2(1, 0.2)
				create_tween().tween_property(s, "scale", Vector2.ONE, 0.35).set_delay(0.4 + float(j % 7) * 0.12) \
					.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			if String(altra["tipo"]) != "campo":
				blo[k(Vector2i(altra["cella"]))] = 1
		elif altra.has("confine") and String(altra["tipo"]) == "rovi":
			var s: Sprite2D = sprite_di[j]
			s.texture = trame["cespuglio"]
		elif altra.has("corruzione"):
			var s: Sprite2D = sprite_di[j]
			if subito:
				s.visible = false
			else:
				create_tween().tween_property(s, "modulate:a", 0.0, 0.6).set_delay(0.3)
			blo[k(Vector2i(altra["cella"]))] = 0
	# una casa non deve mai chiudere il personaggio dentro
	var qui := Vector2i(piedi / LATO)
	if cella_ok(qui):
		blo[k(qui)] = 0
	m.set("bloccato", blo)
	if not subito:
		hud.call("annuncia", String(regioni[r]["nome"]).to_upper(), "REGIONE AUTONOMA")
		colonizzate += 1
		if colonizzate == 1:
			scatto("faro_onda", 40)
			scatto("faro_dopo", 150)
		elif colonizzate == 2:
			quando_la_mappa = fotogrammi + 200
		elif colonizzate == 3:
			scatto("terza_regione", 160)


func colonizza_tutto() -> void:
	var cose: Array[Dictionary] = m.get("cose")
	for n in cose.size():
		var cosa := cose[n]
		if ["ponte", "scala", "rovi_varco"].has(String(cosa["tipo"])):
			cosa["aperto"] = true
			apri_varco(n)
	for n in cose.size():
		if String(cose[n]["tipo"]) == "faro":
			cose[n]["aperto"] = true
			colonizza(n, true)
	for q in corrotto.size():
		corrotto[q] = 0.0
	maschera.fill(Color(0, 0, 0, 1))
	maschera_tex.update(maschera)
	onde.clear()


func percentuale() -> int:
	var regioni: Array[Dictionary] = m.get("regioni")
	var tutte := 0
	var nostre := 0
	for r in regioni:
		if int(r["profondita"]) < 0:
			continue
		tutte += 1
		if bool(r["colonizzata"]):
			nostre += 1
	return roundi(100.0 * float(nostre) / float(maxi(tutte, 1)))


func produci(delta: float) -> void:
	# ogni regione autonoma manda un pezzo della sua risorsa, a turno
	produzione += delta
	if produzione < PRODUZIONE:
		return
	produzione = 0.0
	var regioni: Array[Dictionary] = m.get("regioni")
	var cose: Array[Dictionary] = m.get("cose")
	for r in regioni:
		if not bool(r.get("colonizzata", false)):
			continue
		var risorsa := "quarzo"
		for cosa in cose:
			if String(cosa["tipo"]) == "vena" and int(cosa["regione"]) == int(r["id"]):
				risorsa = String(cosa["risorsa"])
		borsa[risorsa] = int(borsa[risorsa]) + 1
		hud.call("arriva", risorsa)


func ricresci() -> void:
	var cose: Array[Dictionary] = m.get("cose")
	for n in cose.size():
		var cosa := cose[n]
		if String(cosa["tipo"]) == "vena" and int(cosa["scorta"]) == 0 and tempo >= float(cosa["ricresce"]):
			cosa["scorta"] = SCORTA
			(sprite_di[n] as Sprite2D).texture = trame["vena_" + String(cosa["risorsa"])]


func punto_schermo(p: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * p


# ---------------------------------------------------------------- il giro

func _process(delta: float) -> void:
	if controllo:
		return
	if panoramica:
		fotogrammi += 1
		if fotogrammi == 4:
			fotografa("panoramica_%s_%d%s" % [bioma, seme, "_colonizzato" if colonizzato else ""])
		return
	tempo += delta
	var direzione := Vector2.ZERO
	if film:
		direzione = pilota(delta)
	elif not mappa_aperta:
		direzione = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if direzione == Vector2.ZERO:
			direzione = Vector2(
				float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
				float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
	cammina(direzione, delta)
	ricresci()
	produci(delta)
	ritira_la_corruzione(delta)
	segui()
	fotogrammi += 1
	if anteprima >= 0 and fotogrammi == anteprima:
		fotografa("anteprima")
	if film:
		film_e_foto()


func _unhandled_input(evento: InputEvent) -> void:
	if film or panoramica or controllo:
		return
	if evento.is_action_pressed("ui_accept") or (evento is InputEventKey and evento.is_pressed() and not evento.is_echo() and (evento as InputEventKey).physical_keycode == KEY_E):
		var n := cosa_davanti()
		if n >= 0:
			agisci(n)
		get_viewport().set_input_as_handled()
	elif evento is InputEventKey and evento.is_pressed() and not evento.is_echo():
		match (evento as InputEventKey).physical_keycode:
			KEY_M:
				mappa_aperta = not mappa_aperta
			KEY_N:
				seme += 1
				costruisci()
			KEY_B:
				bioma = "ardente" if bioma == "pianure" else "pianure"
				costruisci()
			KEY_P:
				protagonista = "lei" if protagonista == "lui" else "lui"
				io.texture = foglio_di(protagonista)


func scatto(nome: String, fra: int) -> void:
	# il film segna i suoi momenti: prove/mondi.sh ne tira fuori le foto
	if not scatti_fatti.has(nome):
		scatti_fatti[nome] = fotogrammi + fra


func film_e_foto() -> void:
	if fotogrammi == 50:
		scatto("inizio", 0)
	for nome: String in scatti_fatti:
		if int(scatti_fatti[nome]) == fotogrammi:
			print("SCATTO %s %d" % [nome, fotogrammi])
	if fotogrammi % 1800 == 0:
		print("PILOTA t=%.0f colonizzato %d%% borsa %s" % [tempo, percentuale(), borsa])
	# a meta' film la mappa del pianeta, per tre secondi
	if quando_la_mappa > 0 and fotogrammi == quando_la_mappa:
		mappa_aperta = true
		scatto("mappa", 45)
	if quando_la_mappa > 0 and fotogrammi == quando_la_mappa + 100:
		mappa_aperta = false
	if durata_film > 0 and fotogrammi >= durata_film:
		print("FINE FILM %d" % fotogrammi)
		get_tree().quit()


func fotografa(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var cartella := "res://scatti/mondi"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(cartella))
	get_viewport().get_texture().get_image().save_png(cartella.path_join(nome + ".png"))
	print("FOTO ", nome)
	get_tree().quit()


func prepara_panoramica() -> void:
	# il pianeta intero, un pixel del disegno per pixel dello schermo
	var finestra := get_window()
	finestra.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	camera.zoom = Vector2.ONE
	camera.position = Vector2(int(m.get("w")), int(m.get("h"))) * LATO * 0.5
	camera.limit_right = 100000
	camera.limit_bottom = 100000
	camera.limit_left = -100000
	camera.limit_top = -100000
	hud.visible = false
	io.visible = false


# ---------------------------------------------------------------- il pilota automatico
# Gioca da solo, per il film e per provare che il pianeta si finisce: se ha
# di che pagare la prossima cosa (il faro di dove sta, o il passaggio verso
# la regione dopo) ci va; se no va alla vena piena piu' vicina.

func pilota(delta: float) -> Vector2:
	if pausa_pilota > 0.0:
		pausa_pilota -= delta
		return Vector2.ZERO
	if percentuale() >= 100:
		if finito_da < 0.0:
			finito_da = tempo
			print("FINITO in %.0f secondi" % tempo)
		if tempo - finito_da > 4.0:
			get_tree().quit()
		return Vector2.ZERO
	if meta < 0 or not si_fa((m.get("cose") as Array[Dictionary])[meta]):
		meta = scegli_meta()
		strada = strada_verso(meta)
		if meta < 0:
			return Vector2.ZERO
	var n := cosa_davanti()
	if n == meta:
		var cose: Array[Dictionary] = m.get("cose")
		if cosa_manca(cose[n].get("costo", {})).is_empty():
			agisci(n)
			pausa_pilota = 0.5 if String(cose[n]["tipo"]) == "vena" else 1.6
			meta = -1
			return Vector2.ZERO
	if strada.is_empty():
		meta = -1
		return Vector2.ZERO
	var prossima := Vector2(strada[0] * LATO) + Vector2(8, 10)
	if piedi.distance_to(prossima) < 2.5:
		strada.pop_front()
		fermo = 0.0
		return Vector2.ZERO
	if piedi.distance_to(ultimo_posto) < 0.05:
		fermo += delta
	else:
		fermo = 0.0
	ultimo_posto = piedi
	if fermo > 0.4:
		# incastrato: torna al centro della casella in cui e'
		piedi = Vector2(Vector2i(piedi / LATO) * LATO) + Vector2(8, 10)
		fermo = 0.0
	var verso_la := prossima - piedi
	# prima si allinea sull'asse corto, poi va dritto: come un giocatore
	if absf(verso_la.x) > 1.5 and absf(verso_la.y) > 1.5:
		return Vector2(verso_la.x, 0) if absf(verso_la.x) < absf(verso_la.y) else Vector2(0, verso_la.y)
	return verso_la


func scegli_meta() -> int:
	var cose: Array[Dictionary] = m.get("cose")
	var regioni: Array[Dictionary] = m.get("regioni")
	# le cose da pagare, nell'ordine della fila
	var fila: Array[Dictionary] = regioni.duplicate()
	fila.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["ordine"]) < int(b["ordine"]))
	var prossima := -1
	for r in fila:
		if int(r["profondita"]) < 0:
			continue
		if r.has("passaggio") and si_fa(cose[int(r["passaggio"])]):
			prossima = int(r["passaggio"])
			break
		for n in cose.size():
			if String(cose[n]["tipo"]) == "faro" and int(cose[n]["regione"]) == int(r["id"]) and si_fa(cose[n]):
				prossima = n
		if prossima >= 0:
			break
	if prossima >= 0 and cosa_manca(cose[prossima].get("costo", {})).is_empty():
		return prossima
	# se no, la vena raggiungibile piu' vicina della risorsa che manca
	var manca := cosa_manca(cose[prossima].get("costo", {})) if prossima >= 0 else {}
	var migliore := -1
	var meglio := 1e9
	for n in cose.size():
		var cosa := cose[n]
		if String(cosa["tipo"]) != "vena" and String(cosa["tipo"]) != "forziere":
			continue
		if not si_fa(cosa):
			continue
		if String(cosa["tipo"]) == "vena" and not manca.is_empty() and not manca.has(String(cosa["risorsa"])):
			continue
		var lunga := strada_verso(n).size()
		if lunga == 0 and Vector2(Vector2i(cosa["cella"]) * LATO).distance_to(piedi) > 24.0:
			continue
		if float(lunga) < meglio:
			meglio = float(lunga)
			migliore = n
	return migliore


func strada_verso(n: int) -> Array[Vector2i]:
	# la strada a caselle fino accanto alla cosa
	var vuota: Array[Vector2i] = []
	if n < 0:
		return vuota
	var cose: Array[Dictionary] = m.get("cose")
	var blo: PackedByteArray = m.get("bloccato")
	var mete := {}
	for c: Vector2i in cose[n].get("celle", [cose[n]["cella"]]):
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			mete[c + d] = true
	var da := Vector2i(piedi / LATO)
	var venuto := {da: da}
	var coda: Array[Vector2i] = [da]
	var testa := 0
	var arrivo := Vector2i(-1, -1)
	while testa < coda.size():
		var p := coda[testa]
		testa += 1
		if mete.has(p) and blo[k(p)] == 0:
			arrivo = p
			break
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q := p + d
			if cella_ok(q) and not venuto.has(q) and blo[k(q)] == 0:
				venuto[q] = p
				coda.append(q)
	if arrivo.x < 0:
		return vuota
	var al_contrario: Array[Vector2i] = []
	var c := arrivo
	while c != da:
		al_contrario.append(c)
		c = venuto[c]
	al_contrario.reverse()
	return al_contrario
