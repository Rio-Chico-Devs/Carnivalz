extends Node2D
# LA RACCOLTA, DA GIOCARE. Un prototipo per far vedere a Bru come la intendo,
# prima di portarla nel gioco (docs/pianeti_giochi.md, §9). Provvisorio.
#
# Bru, dopo le tavole: «no non ci siamo, a me interessa tipo garden scape che
# muovi il personaggio accumula risorse e le spendi muovendoti sulla mappa».
# Poi, sul primo prototipo: «si è carino ma c'è ancora molto lavoro da fare per
# renderlo bello e con grafiche migliori».
#
# Quindi si cammina. Le vene si scavano andandoci, e ricrescono col tempo. Il
# ponte rotto, la trivella, il cancello si pagano sul posto, e aprono un pezzo
# di pianeta che prima era nella nebbia. La trivella poi scava da sola: si
# passa a prendere quello che ha messo da parte.
#
# Il disegno sta a strati, dal fondo: il cielo (shader) e il Carnivalz lontano,
# le pareti e il fondo delle isole, la terra (shader), gli orli e il ponte, le
# cose in ordine di profondita', la nebbia (shader), le particelle e gli inviti.
# Sopra tutto la tasca e l'obiettivo (RaccoltaHud.gd).
#
#   frecce o WASD          cammina
#   E, spazio o invio      scava, ripara, costruisci, apri (la cosa piu' vicina)
#   clic                   vai li'; su una cosa: vai e falla
#
#   nell'editor: F6 su prove/RaccoltaProva.tscn
#   ./prove/raccolta.sh    il film col pilota automatico, in scatti/raccolta/

const Disegno := preload("res://prove/RaccoltaDisegno.gd")
const Tasca := preload("res://prove/RaccoltaHud.gd")
const TERRA := preload("res://prove/raccolta_terra.gdshader")
const NEBBIA := preload("res://prove/raccolta_nebbia.gdshader")
const VUOTO := preload("res://prove/raccolta_vuoto.gdshader")
const STAMPA := preload("res://prove/raccolta_stampa.gdshader")
# la carta e i tre inchiostri della stampa: gli stessi valori stanno nello shader
const CARTA_STAMPA := Color("#efd8b2")
const INCHIOSTRI := [Color("#1f1a24"), Color("#f29a2e"), Color("#2f6aa8")]
const MONDO := Rect2(0, 0, 2300, 1260)
const VELOCITA := 250.0
const PORTATA := 70.0          # quanto vicino devi essere per fare una cosa
const SI_VEDE := 160.0         # da quanto lontano la cosa ti dice cosa si fa
const SCAVO := 0.8
const LAVORO := 1.3
const SVELA := 1.8
const COLPO := 0.4             # un colpo di piccone
const NOMI := {"quarzo": "QUARZO", "ferro": "FERRO", "cristallo": "CRISTALLI", "tazo": "TAZO"}
const CATENA := ["atterraggio", "piana", "cratere"]      # i campi in fila, e fra uno e l'altro un passaggio
const PASSAGGI := ["ponte", "cancello"]
const OBIETTIVI := [["quarzo", "Raccogli 12 quarzo"], ["ponte", "Ripara il ponte"], ["trivella", "Costruisci la trivella"],
		["cancello", "Apri il cancello"], ["forziere", "Scopri cosa c'è nel cratere"]]

var zone := {}
var cose := {}
var decori: Array[Dictionary] = []
var pezzi_passerella: Array[PackedVector2Array] = []
var borsa := {"quarzo": 0, "ferro": 0, "cristallo": 0, "tazo": 0}
var io := Vector2(420, 930)
var faccia := 1.0
var dietro := false
var passo := 0.0
var percorso: Array[Vector2] = []
var bersaglio := ""
var lavoro := {}
var scritte: Array[Dictionary] = []
var particelle: Array[Dictionary] = []
var impronte: Array[Dictionary] = []
var strada_fatta := 0.0
var primo_piano: Node2D
var tempo := 0.0
var polvere := 0.0
var scossa := 0.0
var dado := RandomNumberGenerator.new()
var camera: Camera2D
var tasca: Control
var cielo: ShaderMaterial
var stampa: ShaderMaterial
var anteprima := -1          # ./prove/raccolta.sh non la usa: la foto di un fotogramma solo, per provare
var lontano: Control
var rupi: Node2D
var suolo: Node2D
var cose_strato: Node2D
var sopra: Node2D
var nebbie := {}
# il film: il pilota automatico fa il giro, e dice quando fotografare
var film := false
var pilota: Array[String] = ["attesa", "q1", "q2", "q3", "ponte", "f1", "f2", "trivella", "aspetta_trivella", "trivella",
		"cancello", "forziere", "r1", "fine"]
var pausa_pilota := 0.0


func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	film = "film" in argomenti or "anteprima" in argomenti
	if "anteprima" in argomenti:
		anteprima = int(argomenti[argomenti.find("anteprima") + 1]) if argomenti.size() > argomenti.find("anteprima") + 1 else 60
	dado.seed = 11
	prepara_zone()
	prepara_cose()
	prepara_passerella()
	prepara_decori()
	prepara_strati()
	if film:
		print("INIZIO_FILM ", Engine.get_frames_drawn())


# ------------------------------------------------------------- la mappa

func prepara_zone() -> void:
	var dati := {"atterraggio": [Vector2(470, 800), Vector2(400, 280), 0.7, "IL CAMPO D'ATTERRAGGIO"],
			"piana": [Vector2(1370, 740), Vector2(330, 260), 2.1, "LA PIANA DI FERRO"],
			"cratere": [Vector2(1900, 330), Vector2(270, 200), 3.7, "IL CRATERE"]}
	for id: String in dati:
		var d: Array = dati[id]
		var poligono := Disegno.zolla(d[0], d[1], float(d[2]))
		zone[id] = {"nome": d[3], "centro": d[0], "raggi": d[1], "seme": float(d[2]), "poligono": poligono,
				"calpesto": Geometry2D.offset_polygon(poligono, -16.0)[0], "aperta": id == "atterraggio",
				"svela": 1.0 if id == "atterraggio" else 0.0, "da": Vector2.ZERO}


func prepara_cose() -> void:
	cose = {"modulo": {"tipo": "modulo", "dove": Vector2(330, 880), "zona": "atterraggio"},
		"q1": vena(Vector2(300, 680), "quarzo", 5, 28.0, "atterraggio"),
		"q2": vena(Vector2(570, 640), "quarzo", 5, 28.0, "atterraggio"),
		"q3": vena(Vector2(660, 930), "quarzo", 5, 28.0, "atterraggio"),
		"f1": vena(Vector2(1260, 620), "ferro", 6, 34.0, "piana"),
		"f2": vena(Vector2(1500, 850), "ferro", 6, 34.0, "piana"),
		"q4": vena(Vector2(1160, 860), "quarzo", 5, 28.0, "piana"),
		"r1": vena(Vector2(1990, 400), "cristallo", 3, 45.0, "cratere"),
		"r2": vena(Vector2(1790, 390), "cristallo", 3, 45.0, "cratere"),
		"trivella": {"tipo": "trivella", "dove": Vector2(1330, 910), "zona": "piana", "costruita": false,
				"costo": {"ferro": 6}, "scorta": 0, "tiene": 12, "ogni": 1.6, "conto": 0.0, "cartello": Vector2(78, 26)},
		"forziere": {"tipo": "forziere", "dove": Vector2(1920, 255), "zona": "cratere", "aperto": false},
		"ponte": passaggio(Vector2(862, 772), Vector2(1084, 752), 66.0, {"quarzo": 12}, "RIPARA IL PONTE", "atterraggio", "piana"),
		"cancello": passaggio(Vector2(1588, 584), Vector2(1752, 452), 64.0, {"ferro": 6, "quarzo": 5}, "APRI IL CANCELLO",
				"piana", "cratere")}
	(cose["ponte"] as Dictionary)["cartello"] = Vector2(-50, 34)
	(cose["cancello"] as Dictionary)["cartello"] = Vector2(-66, 30)


func vena(dove: Vector2, risorsa: String, quanto: int, ricarica: float, zona: String) -> Dictionary:
	return {"tipo": "vena", "dove": dove, "risorsa": risorsa, "quanto": quanto, "ricarica": ricarica, "carica": 1.0, "zona": zona}


func passaggio(da: Vector2, a: Vector2, largo: float, costo: Dictionary, azione: String, di_qua: String,
		di_la: String) -> Dictionary:
	# il passaggio e' un rettangolo fra i due capi, che sporge un po' dentro i campi
	var verso := (a - da).normalized()
	var lato := verso.orthogonal() * largo * 0.5
	var inizio := da - verso * 30.0
	var fine := a + verso * 30.0
	return {"tipo": "passaggio", "dove": da - verso * 18.0, "da": da, "a": a, "largo": largo, "costo": costo,
			"azione": azione, "zona": di_qua, "apre": di_la, "aperto": false,
			"poligono": PackedVector2Array([inizio - lato, fine - lato, fine + lato, inizio + lato])}


func prepara_passerella() -> void:
	# la lingua di roccia fra la piana e il cratere: il pezzo che sta nel vuoto
	var pezzi: Array[PackedVector2Array] = [(cose["cancello"] as Dictionary)["poligono"]]
	for id: String in zone:
		var restano: Array[PackedVector2Array] = []
		for pezzo in pezzi:
			for resto in Geometry2D.clip_polygons(pezzo, (zone[id] as Dictionary)["poligono"]):
				if not Geometry2D.is_polygon_clockwise(resto):
					restano.append(resto)
		pezzi = restano
	pezzi_passerella = pezzi


func prepara_decori() -> void:
	# massi, piante e crateri, sempre negli stessi posti: lontano dalle cose,
	# dai passaggi e fra loro
	var occupati: Array[Vector2] = []
	for id: String in cose:
		occupati.append((cose[id] as Dictionary)["dove"])
	for id: String in PASSAGGI:
		occupati.append((cose[id] as Dictionary)["da"])
		occupati.append((cose[id] as Dictionary)["a"])
	var quanti := {"atterraggio": [5, 12, 2], "piana": [5, 10, 2], "cratere": [3, 8, 1]}
	for id: String in zone:
		var z: Dictionary = zone[id]
		var n: Array = quanti[id]
		for k in int(n[2]):
			var p := posto_libero(z, occupati, 0.15, 0.6, 110.0)
			decori.append({"tipo": "cratere", "p": p, "r": Vector2(dado.randf_range(34, 52), dado.randf_range(13, 19))})
		for k in int(n[0]):
			var p := posto_libero(z, occupati, 0.3, 0.85, 90.0)
			decori.append({"tipo": "masso", "p": p, "r": dado.randf_range(11, 20), "seme": dado.randf() * 10.0})
		for k in int(n[1]):
			var p := posto_libero(z, occupati, 0.62, 0.9, 60.0)
			decori.append({"tipo": "pianta", "p": p, "r": dado.randf_range(18, 30), "seme": dado.randf() * 10.0})
	decori.append({"tipo": "bruciatura", "p": (cose["modulo"] as Dictionary)["dove"] + Vector2(0, 4), "r": 0.0})


func posto_libero(z: Dictionary, occupati: Array[Vector2], da: float, a: float, distanza: float) -> Vector2:
	var centro: Vector2 = z["centro"]
	var raggi: Vector2 = z["raggi"]
	for tentativo in 400:
		var angolo := dado.randf() * TAU
		var p := centro + Vector2(cos(angolo) * raggi.x, sin(angolo) * raggi.y) * dado.randf_range(da, a)
		if not Geometry2D.is_point_in_polygon(p, z["calpesto"]):
			continue
		if occupati.any(func(o: Vector2) -> bool: return o.distance_to(p) < distanza):
			continue
		occupati.append(p)
		return p
	return centro


func prepara_strati() -> void:
	# il cielo, lontano: lo shader del vuoto e il Carnivalz grande che scorre piano
	var fondo := CanvasLayer.new()
	fondo.layer = -5
	add_child(fondo)
	var tela := ColorRect.new()
	tela.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cielo = ShaderMaterial.new()
	cielo.shader = VUOTO
	# il cielo: blu pieno con un retino di nero, le nuvole piu' chiare o piu' calde
	cielo.set_shader_parameter("fondo", Color("#142435"))
	cielo.set_shader_parameter("nebbia_fredda", Color("#2c4a60"))
	cielo.set_shader_parameter("nebbia_calda", Color("#3a3a22"))
	tela.material = cielo
	fondo.add_child(tela)
	lontano = Control.new()
	lontano.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lontano.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lontano.draw.connect(disegna_lontano)
	fondo.add_child(lontano)
	# il mondo, dal fondo in su
	rupi = strato(disegna_rupi)
	for id: String in zone:
		var z: Dictionary = zone[id]
		terra(z["poligono"], z["centro"], z["raggi"], float(z["seme"]))
	for pezzo in pezzi_passerella:
		terra(pezzo, Vector2.ZERO, Vector2(9000, 9000), 0.0)
	suolo = strato(disegna_suolo)
	cose_strato = strato(disegna_cose)
	for id: String in zone:
		if not bool((zone[id] as Dictionary)["aperta"]):
			nebbie[id] = nebbia(zone[id])
	primo_piano = strato(disegna_primo_piano)
	sopra = strato(disegna_sopra)
	camera = Camera2D.new()
	camera.position = io
	camera.limit_left = int(MONDO.position.x) - 200
	camera.limit_top = int(MONDO.position.y) - 120
	camera.limit_right = int(MONDO.end.x) + 200
	camera.limit_bottom = int(MONDO.end.y) + 200
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	add_child(camera)
	# LA STAMPA: tutto quello che sta sotto diventa una serigrafia a tre
	# inchiostri (raccolta_stampa.gdshader). La tasca, sopra, resta nitida
	var torchio := CanvasLayer.new()
	torchio.layer = 1
	add_child(torchio)
	var foglio := ColorRect.new()
	foglio.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	foglio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stampa = ShaderMaterial.new()
	stampa.shader = STAMPA
	stampa.set_shader_parameter("separa", separazione())
	foglio.material = stampa
	torchio.add_child(foglio)
	var davanti := CanvasLayer.new()
	davanti.layer = 2
	add_child(davanti)
	tasca = Tasca.new()
	davanti.add_child(tasca)


func separazione() -> Basis:
	# quanto di ogni inchiostro serve per ogni colore: la densita' di un
	# inchiostro e' -log(inchiostro / carta), canale per canale; la matrice che
	# va dai colori alle quote e' l'inversa di quella delle densita'
	var colonne: Array[Vector3] = []
	for inchiostro: Color in INCHIOSTRI:
		colonne.append(Vector3(densita(inchiostro.r, CARTA_STAMPA.r), densita(inchiostro.g, CARTA_STAMPA.g),
				densita(inchiostro.b, CARTA_STAMPA.b)))
	return Basis(colonne[0], colonne[1], colonne[2]).inverse()


func densita(inchiostro: float, foglio: float) -> float:
	return maxf(-log(minf(inchiostro / foglio, 1.0)), 0.0)


func strato(disegna: Callable) -> Node2D:
	var n := Node2D.new()
	n.draw.connect(disegna.bind(n))
	add_child(n)
	return n


func terra(poligono: PackedVector2Array, centro: Vector2, raggi: Vector2, seme: float) -> void:
	var p := Polygon2D.new()
	p.polygon = poligono
	p.antialiased = true
	var m := ShaderMaterial.new()
	m.shader = TERRA
	m.set_shader_parameter("centro", centro)
	m.set_shader_parameter("raggi", raggi)
	m.set_shader_parameter("seme", seme)
	# le dosi della terra: quasi carta, un velo d'arancio, l'ombra blu
	m.set_shader_parameter("terra", Color("#eecb91"))
	m.set_shader_parameter("chiara", Color("#efd8b2"))
	m.set_shader_parameter("scura", Color("#748666"))
	p.material = m
	add_child(p)


func nebbia(z: Dictionary) -> Polygon2D:
	# un rettangolo largo intorno al campo: i bordi morbidi li fa lo shader
	var centro: Vector2 = z["centro"]
	var raggi: Vector2 = z["raggi"] * 1.35 + Vector2(40, 40)
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([centro - raggi, centro + Vector2(raggi.x, -raggi.y), centro + raggi,
			centro + Vector2(-raggi.x, raggi.y)])
	var m := ShaderMaterial.new()
	m.shader = NEBBIA
	m.set_shader_parameter("centro", centro)
	m.set_shader_parameter("raggi", z["raggi"])
	m.set_shader_parameter("seme", float(z["seme"]))
	m.set_shader_parameter("buio", Color("#0d121a"))
	m.set_shader_parameter("linea", Color("#223a4d"))
	p.material = m
	add_child(p)
	return p


# ------------------------------------------------------------- il tempo

func _process(delta: float) -> void:
	tempo += delta
	ricresce(delta)
	if lavoro.is_empty():
		cammina(delta)
	else:
		lavora(delta)
	if film:
		pilota_automatico(delta)
	muovi_particelle(delta)
	camera.position = io
	scossa = move_toward(scossa, 0.0, delta * 24.0)
	camera.offset = Vector2(dado.randf_range(-1, 1), dado.randf_range(-1, 1)) * scossa
	cielo.set_shader_parameter("scorre", camera.get_screen_center_position())
	stampa.set_shader_parameter("angolo_mondo", camera.get_screen_center_position() - get_viewport_rect().size * 0.5)
	cielo.set_shader_parameter("tempo", tempo)
	for id: String in nebbie:
		var z: Dictionary = zone[id]
		var n: Polygon2D = nebbie[id]
		(n.material as ShaderMaterial).set_shader_parameter("tempo", tempo)
		(n.material as ShaderMaterial).set_shader_parameter("da", z["da"])
		(n.material as ShaderMaterial).set_shader_parameter("raggio", pow(float(z["svela"]), 1.6) * 1300.0 if bool(z["aperta"]) else 0.0)
		n.visible = float(z["svela"]) < 1.0
	aggiorna_tasca()
	parole_sopra_la_stampa()
	for n: CanvasItem in [rupi, suolo, cose_strato, primo_piano, sopra, lontano]:
		n.queue_redraw()
	if anteprima >= 0 and Engine.get_process_frames() >= anteprima:
		anteprima = -1
		fotografa()


func fotografa() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://scatti/raccolta")
	get_viewport().get_texture().get_image().save_png("res://scatti/raccolta/anteprima.png")
	get_tree().quit()


func ricresce(delta: float) -> void:
	# il tempo che passa giocando: le vene ricrescono, la trivella scava, la
	# nebbia si ritira, le scritte salgono
	for id: String in cose:
		var c: Dictionary = cose[id]
		if String(c["tipo"]) == "vena" and float(c["carica"]) < 1.0:
			c["carica"] = minf(1.0, float(c["carica"]) + delta / float(c["ricarica"]))
	var trivella: Dictionary = cose["trivella"]
	if bool(trivella["costruita"]) and int(trivella["scorta"]) < int(trivella["tiene"]):
		trivella["conto"] = float(trivella["conto"]) + delta
		if float(trivella["conto"]) >= float(trivella["ogni"]):
			trivella["conto"] = 0.0
			trivella["scorta"] = int(trivella["scorta"]) + 1
			soffio(Vector2(trivella["dove"]) + Vector2(0, -4), 2)
	for id: String in zone:
		var z: Dictionary = zone[id]
		if bool(z["aperta"]) and float(z["svela"]) < 1.0:
			z["svela"] = minf(1.0, float(z["svela"]) + delta / SVELA)
			if float(z["svela"]) >= 1.0:
				scatto("svelata_" + id)
	for impronta in impronte:
		impronta["eta"] = float(impronta["eta"]) + delta
	var restano: Array[Dictionary] = []
	for s in scritte:
		s["eta"] = float(s["eta"]) + delta
		if float(s["eta"]) < 1.6:
			restano.append(s)
	scritte = restano


func aggiorna_tasca() -> void:
	var fatti := 0
	var adesso := ""
	for obiettivo: Array in OBIETTIVI:
		if obiettivo_fatto(String(obiettivo[0])):
			fatti += 1
		elif adesso == "":
			adesso = String(obiettivo[1])
	tasca.set("fatti", fatti)
	tasca.set("obiettivo", adesso)


func obiettivo_fatto(chiave: String) -> bool:
	match chiave:
		"quarzo":
			return int(borsa["quarzo"]) >= 12 or bool((cose["ponte"] as Dictionary)["aperto"])
		"trivella":
			return bool((cose["trivella"] as Dictionary)["costruita"])
	return bool((cose[chiave] as Dictionary)["aperto"])


# ------------------------------------------------------------- camminare

func _unhandled_input(evento: InputEvent) -> void:
	if film:
		return
	if evento is InputEventMouseButton and (evento as InputEventMouseButton).pressed \
			and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		# dal punto dello schermo al punto del pianeta, passando dalla camera
		var dove := get_viewport().get_canvas_transform().affine_inverse() * (evento as InputEventMouseButton).position
		var cosa := cosa_sotto(dove)
		if cosa != "":
			vai_a(cosa)
		elif zona_di(dove) != "":
			bersaglio = ""
			percorso = strada(dove)
	elif evento.is_action_pressed("ui_accept") or (evento is InputEventKey and (evento as InputEventKey).pressed
			and (evento as InputEventKey).keycode == KEY_E):
		var vicina := cosa_vicina(PORTATA)
		if vicina != "":
			agisci(vicina)


func tasti() -> Vector2:
	var v := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		v.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		v.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		v.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		v.y += 1.0
	return v.normalized()


func cammina(delta: float) -> void:
	var v := Vector2.ZERO if film else tasti()
	if v != Vector2.ZERO:
		percorso.clear()
		bersaglio = ""
	elif not percorso.is_empty():
		if arrivato_alla_tappa():
			percorso.remove_at(0)
			if percorso.is_empty():
				arrivato()
				return
		v = (percorso[0] - io).normalized()
	if v == Vector2.ZERO:
		passo = 0.0
		dietro = false
		return
	if absf(v.x) > 0.2:
		faccia = signf(v.x)
	dietro = v.y < -0.75
	var nuovo := io + v * VELOCITA * delta
	if calpestabile(nuovo):
		io = nuovo
	elif calpestabile(Vector2(nuovo.x, io.y)):
		io.x = nuovo.x
	elif calpestabile(Vector2(io.x, nuovo.y)):
		io.y = nuovo.y
	elif not percorso.is_empty():
		percorso.clear()
		arrivato()
		return
	passo += delta * 11.0
	# le impronte: una ogni passo, a destra e a sinistra, solo sulla terra
	strada_fatta += VELOCITA * delta
	if strada_fatta >= 24.0 and zona_di(io) != "":
		strada_fatta = 0.0
		var lato := v.orthogonal() * (4.0 if impronte.size() % 2 == 0 else -4.0)
		impronte.append({"p": io + lato, "eta": 0.0, "verso": v})
		if impronte.size() > 70:
			impronte.pop_front()
	polvere -= delta
	if polvere <= 0.0:
		polvere = 0.16
		particelle.append({"tipo": "polvere", "p": io + Vector2(dado.randf_range(-6, 6), 0), "v": -v * 18.0 + Vector2(0, -12),
				"eta": 0.0, "dura": 0.55, "r": dado.randf_range(3.5, 6.0), "g": -10.0})


func arrivato_alla_tappa() -> bool:
	if io.distance_to(percorso[0]) < 6.0:
		return true
	# all'ultima tappa, se vai verso una cosa, ti fermi accanto: non sopra
	return percorso.size() == 1 and bersaglio != "" and io.distance_to((cose[bersaglio] as Dictionary)["dove"]) < stacco(bersaglio)


func stacco(id: String) -> float:
	# quanto lontano ti fermi da una cosa: dalle macchine grandi, un passo in piu'
	match String((cose[id] as Dictionary)["tipo"]):
		"trivella":
			return 70.0
		"forziere":
			return 54.0
		"passaggio":
			return 8.0
	return 44.0


func arrivato() -> void:
	if bersaglio != "" and io.distance_to((cose[bersaglio] as Dictionary)["dove"]) <= PORTATA:
		agisci(bersaglio)
	bersaglio = ""


func vai_a(id: String) -> void:
	bersaglio = id
	var dove: Vector2 = (cose[id] as Dictionary)["dove"]
	if io.distance_to(dove) <= PORTATA:
		percorso.clear()
		arrivato()
		return
	percorso = strada(dove)


func strada(meta: Vector2) -> Array[Vector2]:
	# fra un campo e l'altro si passa dai passaggi aperti: i loro capi sono le
	# tappe. Un passaggio chiuso ferma la strada al suo capo di qua
	var tappe: Array[Vector2] = []
	var i := CATENA.find(zona_di(io))
	var j := CATENA.find(zona_di(meta))
	if i < 0 or j < 0:
		tappe.append(meta)
		return tappe
	while i != j:
		var avanti := j > i
		var p: Dictionary = cose[PASSAGGI[i if avanti else i - 1]]
		tappe.append(p["da"] if avanti else p["a"])
		if not bool(p["aperto"]):
			return tappe
		tappe.append(p["a"] if avanti else p["da"])
		i += 1 if avanti else -1
	tappe.append(meta)
	return tappe


func zona_di(p: Vector2) -> String:
	for id: String in zone:
		if bool((zone[id] as Dictionary)["aperta"]) and Geometry2D.is_point_in_polygon(p, (zone[id] as Dictionary)["poligono"]):
			return id
	return ""


func calpestabile(p: Vector2) -> bool:
	for id: String in zone:
		var z: Dictionary = zone[id]
		if bool(z["aperta"]) and Geometry2D.is_point_in_polygon(p, z["calpesto"]):
			return true
	for id: String in PASSAGGI:
		var c: Dictionary = cose[id]
		if bool(c["aperto"]) and Geometry2D.is_point_in_polygon(p, c["poligono"]):
			return true
	return false


# ------------------------------------------------------------- le cose

func si_legge(id: String) -> bool:
	# le cifre sopra la stampa non sanno della nebbia: aspettano che il campo
	# si sia scoperto quasi tutto
	var z: Dictionary = zone[(cose[id] as Dictionary)["zona"]]
	return bool(z["aperta"]) and float(z["svela"]) >= 0.85


func si_vede(id: String) -> bool:
	return bool((zone[(cose[id] as Dictionary)["zona"]] as Dictionary)["aperta"])


func cosa_vicina(entro: float) -> String:
	var vicina := ""
	var meglio := entro
	for id: String in cose:
		if not si_vede(id) or invito(id).is_empty():
			continue
		var d := io.distance_to((cose[id] as Dictionary)["dove"])
		if d <= meglio:
			meglio = d
			vicina = id
	return vicina


func cosa_sotto(p: Vector2) -> String:
	for id: String in cose:
		var dove: Vector2 = (cose[id] as Dictionary)["dove"]
		if si_vede(id) and not invito(id).is_empty() and p.distance_to(dove + Vector2(0, -20)) < 48.0:
			return id
	return ""


func invito(id: String) -> Dictionary:
	# cosa dice la cosa quando le sei vicino: cosa si fa, e se te lo puoi permettere
	var c: Dictionary = cose[id]
	match String(c["tipo"]):
		"vena":
			if float(c["carica"]) >= 1.0:
				return {"testo": "SCAVA  ·  +%d %s" % [int(c["quanto"]), NOMI[c["risorsa"]]], "puoi": true, "manca": ""}
			return {"testo": "RICRESCE", "puoi": false, "manca": ""}
		"passaggio":
			return {} if bool(c["aperto"]) else costa(String(c["azione"]), c["costo"])
		"trivella":
			if not bool(c["costruita"]):
				return costa("COSTRUISCI LA TRIVELLA", c["costo"])
			if int(c["scorta"]) > 0:
				return {"testo": "PRENDI  ·  +%d QUARZO" % int(c["scorta"]), "puoi": true, "manca": ""}
			return {"testo": "STA SCAVANDO", "puoi": false, "manca": ""}
		"forziere":
			return {} if bool(c["aperto"]) else {"testo": "APRI IL FORZIERE", "puoi": true, "manca": ""}
	return {}


func costa(azione: String, costo: Dictionary) -> Dictionary:
	# il prezzo sta sul cartello; l'invito dice cosa si fa, e cosa manca
	var mancano := PackedStringArray()
	for risorsa: String in costo:
		var manca := int(costo[risorsa]) - int(borsa[risorsa])
		if manca > 0:
			mancano.append("%d %s" % [manca, NOMI[risorsa]])
	return {"testo": azione, "puoi": mancano.is_empty(), "manca": "" if mancano.is_empty() else "MANCANO " + " E ".join(mancano)}


func agisci(id: String) -> void:
	var detto := invito(id)
	if detto.is_empty() or not lavoro.is_empty():
		return
	var c: Dictionary = cose[id]
	if not bool(detto["puoi"]):
		if String(detto["manca"]) != "":
			scrivi(c["dove"], String(detto["manca"]), Stile.colore("pericolo"))
		return
	# si paga subito, sul posto; poi il lavoro si vede
	var durata := SCAVO
	match String(c["tipo"]):
		"passaggio":
			paga(c["costo"])
			durata = LAVORO
		"trivella":
			if not bool(c["costruita"]):
				paga(c["costo"])
				durata = LAVORO
			else:
				durata = 0.35
		"forziere":
			durata = 0.6
	var dove: Vector2 = c["dove"]
	if absf(dove.x - io.x) > 4.0:
		faccia = signf(dove.x - io.x)
	dietro = false
	lavoro = {"cosa": id, "tempo": 0.0, "durata": durata}


func paga(costo: Dictionary) -> void:
	for risorsa: String in costo:
		borsa[risorsa] = int(borsa[risorsa]) - int(costo[risorsa])
		tasca.call("spendi", risorsa, int(costo[risorsa]))
		scrivi(io, "-%d %s" % [int(costo[risorsa]), NOMI[risorsa]], Disegno.CARTA)


func lavora(delta: float) -> void:
	var prima := float(lavoro["tempo"])
	lavoro["tempo"] = prima + delta
	var c: Dictionary = cose[String(lavoro["cosa"])]
	# a ogni colpo: schegge, una scintilla, e lo schermo che trema appena
	if fmod(prima / COLPO, 1.0) < 0.85 and fmod(float(lavoro["tempo"]) / COLPO, 1.0) >= 0.85:
		colpo(c)
	if float(lavoro["tempo"]) >= float(lavoro["durata"]):
		var id := String(lavoro["cosa"])
		lavoro = {}
		fatto(id)


func colpo(c: Dictionary) -> void:
	var dove: Vector2 = c["dove"]
	if String(c["tipo"]) == "vena":
		for k in 5:
			particelle.append({"tipo": "scheggia", "quale": c["risorsa"], "p": dove + Vector2(dado.randf_range(-10, 10), -16),
					"v": Vector2(dado.randf_range(-120, 120), dado.randf_range(-260, -140)), "eta": 0.0, "dura": 0.7,
					"r": dado.randf() * 6.0, "g": 700.0})
		particelle.append({"tipo": "scintilla", "p": dove + Vector2(0, -22), "v": Vector2.ZERO, "eta": 0.0, "dura": 0.25,
				"r": 14.0, "g": 0.0})
		scossa = 3.0
	else:
		soffio(dove, 3)
		scossa = 2.0


func soffio(dove: Vector2, quanti: int) -> void:
	for k in quanti:
		particelle.append({"tipo": "polvere", "p": dove + Vector2(dado.randf_range(-20, 20), dado.randf_range(-6, 6)),
				"v": Vector2(dado.randf_range(-40, 40), dado.randf_range(-50, -20)), "eta": 0.0, "dura": 0.8,
				"r": dado.randf_range(6, 10), "g": -20.0})


func muovi_particelle(delta: float) -> void:
	var restano: Array[Dictionary] = []
	for q in particelle:
		q["eta"] = float(q["eta"]) + delta
		if float(q["eta"]) >= float(q["dura"]):
			continue
		q["v"] = Vector2(q["v"]) + Vector2(0, float(q["g"]) * delta)
		q["p"] = Vector2(q["p"]) + Vector2(q["v"]) * delta
		restano.append(q)
	particelle = restano


func fatto(id: String) -> void:
	var c: Dictionary = cose[id]
	match String(c["tipo"]):
		"vena":
			var risorsa := String(c["risorsa"])
			borsa[risorsa] = int(borsa[risorsa]) + int(c["quanto"])
			c["carica"] = 0.0
			tasca.call("vola", risorsa, schermo(Vector2(c["dove"]) + Vector2(0, -24)), int(c["quanto"]))
			scrivi(c["dove"], "+%d %s" % [int(c["quanto"]), NOMI[risorsa]], Disegno.ARANCIO)
			scatto("scavo_" + id)
		"passaggio":
			c["aperto"] = true
			var z: Dictionary = zone[c["apre"]]
			z["aperta"] = true
			z["da"] = (Vector2(c["da"]) + Vector2(c["a"])) * 0.5
			tasca.set("annuncio", {"testo": z["nome"], "sopra": "UN CAMPO NUOVO", "eta": 0.0})
			particelle.append({"tipo": "onda", "p": z["da"], "v": Vector2.ZERO, "eta": 0.0, "dura": 0.8, "r": 120.0, "g": 0.0})
			soffio(z["da"], 6)
			scossa = 5.0
			scatto("aperto_" + id)
		"trivella":
			if not bool(c["costruita"]):
				c["costruita"] = true
				soffio(c["dove"], 6)
				scatto("trivella")
			else:
				borsa["quarzo"] = int(borsa["quarzo"]) + int(c["scorta"])
				tasca.call("vola", "quarzo", schermo(Vector2(c["dove"]) + Vector2(-50, -40)), int(c["scorta"]))
				scrivi(c["dove"], "+%d QUARZO" % int(c["scorta"]), Disegno.ARANCIO)
				c["scorta"] = 0
		"forziere":
			c["aperto"] = true
			borsa["tazo"] = int(borsa["tazo"]) + 50
			tasca.call("vola", "tazo", schermo(Vector2(c["dove"]) + Vector2(0, -40)), 50)
			scrivi(c["dove"], "+50 TAZO", Color("#ffd23a"))
			tasca.set("annuncio", {"testo": "UN COLLEZIONABILE", "sopra": "NEL FORZIERE", "eta": 0.0})
			particelle.append({"tipo": "onda", "p": Vector2(c["dove"]) + Vector2(0, -30), "v": Vector2.ZERO, "eta": 0.0,
					"dura": 0.7, "r": 90.0, "g": 0.0})
			for k in 8:
				particelle.append({"tipo": "scintilla", "p": Vector2(c["dove"]) + Vector2(0, -30),
						"v": Vector2.from_angle(TAU * float(k) / 8.0) * 160.0, "eta": 0.0, "dura": 0.6, "r": 9.0, "g": 200.0})
			scatto("forziere")


func schermo(p: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * p


func scrivi(dove: Vector2, testo: String, tinta: Color) -> void:
	scritte.append({"dove": dove, "testo": testo, "tinta": tinta, "eta": 0.0})


func scatto(nome: String) -> void:
	# nel film: quale fotogramma tenere come foto
	if film:
		print("SCATTO %s %d" % [nome, Engine.get_frames_drawn() + 14])


# ------------------------------------------------------------- il pilota

func pilota_automatico(delta: float) -> void:
	# fa il giro che farebbe un giocatore, una cosa alla volta, con un respiro in mezzo
	if not lavoro.is_empty() or not percorso.is_empty() or bersaglio != "" or pilota.is_empty():
		return
	if pausa_pilota > 0.0:
		pausa_pilota -= delta
		return
	var prossimo: String = pilota[0]
	match prossimo:
		"attesa":
			pilota.pop_front()
			pausa_pilota = 1.2
			scatto("inizio")
		"aspetta_trivella":
			if int((cose["trivella"] as Dictionary)["scorta"]) >= 4:
				pilota.pop_front()
		"fine":
			pilota.pop_front()
			get_tree().create_timer(3.0).timeout.connect(get_tree().quit)
		_:
			pilota.pop_front()
			pausa_pilota = 0.35
			vai_a(prossimo)


# ------------------------------------------------------------- il disegno, a strati

func disegna_lontano() -> void:
	# IL FONDO, a piani: piu' sono lontani, piu' scorrono piano. Le schegge di
	# cristallo lontanissime, il Carnivalz di questo Vuoto coi suoi raggi, e
	# le isole lontane che ondeggiano. Tutto in blu, con l'orlo acceso d'arancio
	# dalla parte della luce: la stampa ne fa retino
	var cam := camera.get_screen_center_position()
	schegge_lontane(cam)
	var c := Vector2(1080, 130) - cam * 0.03
	raggi_lontani(c)
	pianeta_lontano(c, 160.0)
	isole_lontane(cam, 0.05, 0, 0.55)
	isole_lontane(cam, 0.1, 1, 0.85)


func schegge_lontane(cam: Vector2) -> void:
	# schegge di cristallo che galleggiano lontanissime e girano piano: blu,
	# con lo spigolo acceso dalla parte della luce
	for k in 14:
		var seme := float(k) * 1.37
		var x := fposmod(90.0 + 190.0 * float(k) - cam.x * 0.025, 2660.0) - 300.0
		var y := fposmod(60.0 + 410.0 * absf(sin(seme * 2.1)) * 1.6 - cam.y * 0.025, 860.0) - 70.0
		var r := 10.0 + 16.0 * absf(sin(seme * 3.3))
		var giro := tempo * 0.15 * (1.0 if k % 2 == 0 else -1.0) + seme
		var punte := PackedVector2Array()
		for i in 4:
			punte.append(Vector2(x, y) + Vector2.from_angle(giro + PI * 0.5 * float(i)) * r * (1.6 if i % 2 == 0 else 0.6))
		lontano.draw_colored_polygon(PackedVector2Array([punte[0], punte[1], punte[2]]), Color("#3a5a70"))
		lontano.draw_colored_polygon(PackedVector2Array([punte[0], punte[2], punte[3]]), Color("#1b2e40"))
		lontano.draw_line(punte[1], punte[2], Color("#a47c2d"), 1.5, true)


func raggi_lontani(c: Vector2) -> void:
	# i raggi del Carnivalz: larghi, pallidi, verso il basso a sinistra
	for k in 4:
		var verso := Vector2.from_angle(PI * 0.68 + 0.13 * float(k))
		var lato := verso.orthogonal()
		var lungo := 1500.0
		var largo_qui := 30.0 + 14.0 * float(k % 2)
		var largo_la := 150.0 + 90.0 * float(k % 3)
		var forza := 0.32 - 0.05 * float(k)
		lontano.draw_polygon(PackedVector2Array([c + lato * largo_qui, c - lato * largo_qui, c + verso * lungo - lato * largo_la,
				c + verso * lungo + lato * largo_la]), PackedColorArray([Color("#998e51", forza), Color("#998e51", forza),
				Color("#998e51", 0.0), Color("#998e51", 0.0)]))


func pianeta_lontano(c: Vector2, r: float) -> void:
	# a spicchi dal punto in luce: la stampa trasforma la sfumatura in retino
	var luce := c + Vector2(-0.42, -0.5) * r
	anello_lontano(c, r, false)
	for i in 48:
		var a := c + Vector2.from_angle(TAU * float(i) / 48.0) * r
		var b := c + Vector2.from_angle(TAU * float(i + 1) / 48.0) * r
		lontano.draw_polygon(PackedVector2Array([luce, a, b]), PackedColorArray([Color("#d8c39c"), Color("#1f374b"),
				Color("#1f374b")]))
	lontano.draw_arc(c, r, PI * 0.95, PI * 1.6, 32, Color("#a47c2d"), 3.0, true)
	anello_lontano(c, r, true)


func anello_lontano(c: Vector2, r: float, davanti: bool) -> void:
	for k in 3:
		var raggi := Vector2(r * (1.45 + 0.12 * float(k)), r * (0.26 + 0.02 * float(k)))
		var punti := PackedVector2Array()
		for i in 49:
			var a := (0.0 if davanti else PI) + PI * float(i) / 48.0
			punti.append(c + Vector2(cos(a) * raggi.x, sin(a) * raggi.y).rotated(-0.18))
		lontano.draw_polyline(punti, Color("#a47c2d", 0.85 - 0.22 * float(k)), 2.0, true)


func isole_lontane(cam: Vector2, quanto_scorre: float, strato_n: int, grandezza: float) -> void:
	# isole come le nostre, piccole e lontane, che ondeggiano piano
	for k in 5:
		var seme := float(k) * 3.1 + float(strato_n) * 11.0
		var x := fposmod(200.0 + 560.0 * float(k) + 230.0 * float(strato_n) - cam.x * quanto_scorre, 2800.0) - 400.0
		var y := 250.0 + 330.0 * absf(sin(seme * 1.9)) - cam.y * quanto_scorre + sin(tempo * 0.4 + seme) * 6.0
		var raggi := Vector2(70.0 + 50.0 * absf(sin(seme)), 22.0 + 10.0 * absf(cos(seme))) * grandezza
		var sopra_isola := Disegno.zolla(Vector2(x, y), raggi, seme)
		var punta := Vector2(x + raggi.x * 0.1, y + raggi.y * 3.2)
		lontano.draw_polygon(PackedVector2Array([Vector2(x - raggi.x, y), Vector2(x + raggi.x, y), punta]),
				PackedColorArray([Color("#111e2d"), Color("#111e2d"), Color("#111e2d", 0.0)]))
		lontano.draw_colored_polygon(sopra_isola, Color("#2c4a60"))
		var orlo := sopra_isola.slice(34, 54)
		lontano.draw_polyline(orlo, Color("#a47c2d"), 2.0, true)


func disegna_rupi(n: Node2D) -> void:
	for id: String in zone:
		var z: Dictionary = zone[id]
		Disegno.isola(n, z["poligono"], float(z["seme"]))
	for pezzo in pezzi_passerella:
		Disegno.passerella_sotto(n, pezzo)


func disegna_suolo(n: Node2D) -> void:
	for impronta in impronte:
		var svanisce := clampf(1.0 - float(impronta["eta"]) / 9.0, 0.0, 1.0)
		if svanisce > 0.0:
			var p: Vector2 = impronta["p"]
			var verso: Vector2 = impronta["verso"]
			n.draw_set_transform(p, verso.angle(), Vector2.ONE)
			Disegno.ovale(n, Vector2.ZERO, Vector2(4.5, 2.6), Color(Disegno.OMBRA_TINTA, 0.85 * svanisce), false)
			n.draw_set_transform(Vector2.ZERO)
	for d in decori:
		match String(d["tipo"]):
			"cratere":
				Disegno.cratere(n, d["p"], d["r"])
			"bruciatura":
				Disegno.bruciatura(n, d["p"])
	for id: String in zone:
		Disegno.orlo(n, (zone[id] as Dictionary)["poligono"])
	for pezzo in pezzi_passerella:
		Disegno.orlo(n, pezzo)
	var ponte: Dictionary = cose["ponte"]
	Disegno.ponte(n, ponte["da"], ponte["a"], float(ponte["largo"]), quanto_fatto("ponte"))


func disegna_cose(n: Node2D) -> void:
	# le cose e il personaggio, dall'alto in basso: chi sta piu' giu' copre chi sta su
	var ordine: Array[Dictionary] = []
	for id: String in cose:
		var c: Dictionary = cose[id]
		if String(c["tipo"]) == "passaggio":
			if id == "cancello":
				ordine.append({"y": (Vector2(c["da"]) + Vector2(c["a"])).y * 0.5, "cosa": id})
		else:
			ordine.append({"y": Vector2(c["dove"]).y, "cosa": id})
		if c.has("cartello") and si_vede(id) and not bool(c.get("aperto", false)) and not bool(c.get("costruita", false)):
			ordine.append({"y": Vector2(c["dove"]).y + Vector2(c["cartello"]).y, "cartello": id})
	for d in decori:
		if String(d["tipo"]) in ["masso", "pianta"]:
			ordine.append({"y": Vector2(d["p"]).y, "decoro": d})
	ordine.append({"y": io.y, "io": true})
	ordine.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["y"]) < float(b["y"]))
	for voce in ordine:
		if voce.has("io"):
			disegna_me(n)
		elif voce.has("decoro"):
			disegna_decoro(n, voce["decoro"])
		elif voce.has("cartello"):
			var c: Dictionary = cose[voce["cartello"]]
			Disegno.cartello(n, Vector2(c["dove"]) + Vector2(c["cartello"]), c["costo"])
		else:
			disegna_cosa(n, String(voce["cosa"]))


func disegna_me(n: Node2D) -> void:
	var colpo_ora := -1.0
	if not lavoro.is_empty():
		colpo_ora = fmod(float(lavoro["tempo"]) / COLPO, 1.0)
	var carico := int(borsa["quarzo"]) + int(borsa["ferro"]) + int(borsa["cristallo"])
	Disegno.personaggio(n, io, faccia, dietro, passo, colpo_ora, carico, tempo)


func disegna_decoro(n: Node2D, d: Dictionary) -> void:
	match String(d["tipo"]):
		"masso":
			Disegno.masso(n, d["p"], float(d["r"]), float(d["seme"]))
		"pianta":
			Disegno.pianta(n, d["p"], float(d["r"]), float(d["seme"]), tempo)


func disegna_cosa(n: Node2D, id: String) -> void:
	var c: Dictionary = cose[id]
	match String(c["tipo"]):
		"vena":
			Disegno.vena(n, c["dove"], String(c["risorsa"]), float(c["carica"]), tempo)
		"modulo":
			Disegno.modulo(n, c["dove"], tempo)
		"trivella":
			var su := 1.0 if bool(c["costruita"]) else quanto_lavoro("trivella")
			Disegno.trivella(n, c["dove"], su, int(c["scorta"]), int(c["tiene"]), tempo)
		"forziere":
			Disegno.forziere(n, c["dove"], bool(c["aperto"]), tempo)
		"passaggio":
			var verso := (Vector2(c["a"]) - Vector2(c["da"])).normalized()
			Disegno.cancello(n, (Vector2(c["da"]) + Vector2(c["a"])) * 0.5, verso, float(c["largo"]), quanto_fatto(id), tempo)


func quanto_fatto(id: String) -> float:
	# un passaggio: 1 aperto, 0 chiuso, in mezzo mentre ci lavori
	if bool((cose[id] as Dictionary)["aperto"]):
		return 1.0
	return quanto_lavoro(id)


func quanto_lavoro(id: String) -> float:
	if not lavoro.is_empty() and String(lavoro["cosa"]) == id:
		return float(lavoro["tempo"]) / float(lavoro["durata"])
	return 0.0


func disegna_primo_piano(n: Node2D) -> void:
	# DAVANTI A TUTTO: massi neri che passano ai bordi dello schermo, piu'
	# veloci del mondo (sono piu' vicini), e la polvere che galleggia
	var cam := camera.get_screen_center_position()
	var schermo_mondo := cam - get_viewport_rect().size * 0.5
	for k in 5:
		var seme := float(k) * 2.9
		var x := fposmod(120.0 + 700.0 * float(k) - cam.x * 0.35, 3500.0) - 400.0
		var y := (790.0 if k % 2 == 0 else -60.0) + sin(tempo * 0.3 + seme) * 8.0 - cam.y * 0.08
		var r := 90.0 + 50.0 * absf(sin(seme))
		var masso := Disegno.zolla(schermo_mondo + Vector2(x, y), Vector2(r * 1.3, r * 0.8), seme)
		n.draw_colored_polygon(masso, Color("#141018"))
		var orlo := masso.slice(36, 52) if k % 2 == 0 else masso.slice(2, 14)
		n.draw_polyline(orlo, Disegno.ARANCIO, 3.0, true)
	for k in 36:
		var seme := float(k) * 1.618
		var p := Vector2(fposmod(37.0 * float(k) * 13.0 + tempo * (8.0 + float(k % 5) * 3.0) - cam.x * 0.15, 1400.0) - 60.0,
				fposmod(53.0 * float(k) * 7.0 - tempo * (5.0 + float(k % 3) * 2.0) - cam.y * 0.15, 820.0) - 50.0)
		var r := 1.6 + float(k % 3) * 0.9
		n.draw_circle(schermo_mondo + p + Vector2(sin(tempo + seme) * 6.0, 0), r,
				Color(Disegno.ARANCIO if k % 4 == 0 else Disegno.CARTA, 0.75))


func disegna_sopra(n: Node2D) -> void:
	for q in particelle:
		Disegno.particella(n, q)


func parole_sopra_la_stampa() -> void:
	# QUELLO CHE SI LEGGE NON PASSA DALLA STAMPA: il retino mangerebbe le
	# lettere. Gli inviti, le scritte che salgono e le cifre dei cartelli le
	# scrive la tasca, nitide, nel punto dello schermo dove sta la cosa.
	# L'invito solo per quello che si puo' fare, o che si potra' fare pagando:
	# che una vena ricresce lo dice gia' il suo giro azzurro
	var inviti: Array[Dictionary] = []
	var vicina := cosa_vicina(SI_VEDE) if lavoro.is_empty() else ""
	var detto := invito(vicina) if vicina != "" else {}
	if not detto.is_empty() and (bool(detto["puoi"]) or String(detto["manca"]) != ""):
		inviti.append({"p": schermo(Vector2((cose[vicina] as Dictionary)["dove"]) + Vector2(0, -108)), "testo": detto["testo"],
				"puoi": detto["puoi"], "manca": detto["manca"]})
	var salgono: Array[Dictionary] = []
	for s in scritte:
		salgono.append({"p": schermo(s["dove"]), "testo": s["testo"], "eta": s["eta"], "tinta": s["tinta"]})
	var cifre: Array[Dictionary] = []
	for id: String in cose:
		var c: Dictionary = cose[id]
		if c.has("cartello") and si_legge(id) and not bool(c.get("aperto", false)) and not bool(c.get("costruita", false)):
			cifre.append({"p": schermo(Vector2(c["dove"]) + Vector2(c["cartello"])), "costo": c["costo"]})
	tasca.set("inviti", inviti)
	tasca.set("scritte", salgono)
	tasca.set("cartelli", cifre)
	tasca.set("borsa", borsa)
