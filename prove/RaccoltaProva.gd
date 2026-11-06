extends Node2D
# LA RACCOLTA, DA GIOCARE. Un prototipo per far vedere a Bru come la intendo,
# prima di portarla nel gioco (docs/pianeti_giochi.md, §9). Provvisorio.
#
# Bru, dopo le tavole: «no non ci siamo, a me interessa tipo garden scape che
# muovi il personaggio accumula risorse e le spendi muovendoti sulla mappa».
#
# Quindi si cammina. Le vene si scavano andandoci, e ricrescono col tempo. Il
# ponte rotto, la trivella, il cancello si pagano sul posto, e aprono un pezzo
# di pianeta che prima era nella nebbia. La trivella poi scava da sola: si
# passa a prendere quello che ha messo da parte.
#
#   frecce o WASD          cammina
#   E, spazio o invio      scava, ripara, costruisci, apri (la cosa piu' vicina)
#   clic                   vai li'; su una cosa: vai e falla
#
#   nell'editor: F6 su prove/RaccoltaProva.tscn
#   ./prove/raccolta.sh    il film col pilota automatico, in scatti/raccolta/

const Disegno := preload("res://prove/RaccoltaDisegno.gd")
const MONDO := Rect2(0, 0, 2300, 1260)
const VELOCITA := 250.0
const PORTATA := 70.0          # quanto vicino devi essere per fare una cosa
const SI_VEDE := 160.0         # da quanto lontano la cosa ti dice cosa costa
const SCAVO := 0.8
const LAVORO := 1.3
const SVELA := 1.6
const NOMI := {"quarzo": "QUARZO", "ferro": "FERRO", "cristallo": "CRISTALLI", "tazo": "TAZO"}
const CATENA := ["atterraggio", "piana", "cratere"]      # i campi in fila, e fra uno e l'altro un passaggio
const PASSAGGI := ["ponte", "cancello"]
const OBIETTIVI := [["quarzo", "Raccogli 12 quarzo"], ["ponte", "Ripara il ponte"], ["trivella", "Costruisci la trivella"],
		["cancello", "Apri il cancello"], ["forziere", "Scopri cosa c'è nel cratere"]]

var zone := {}
var cose := {}
var borsa := {"quarzo": 0, "ferro": 0, "cristallo": 0, "tazo": 0}
var io := Vector2(420, 930)
var faccia := 1.0
var passo := 0.0
var percorso: Array[Vector2] = []
var bersaglio := ""
var lavoro := {}
var scritte: Array[Dictionary] = []
var annuncio := {}
var tempo := 0.0
var stelle := PackedVector2Array()
var camera: Camera2D
var hud: Control
# il film: il pilota automatico fa il giro, e dice quando fotografare
var film := false
var pilota: Array[String] = ["attesa", "q1", "q2", "q3", "ponte", "f1", "f2", "trivella", "aspetta_trivella", "trivella",
		"cancello", "forziere", "r1", "fine"]
var pausa_pilota := 0.0


func _ready() -> void:
	film = "film" in OS.get_cmdline_user_args()
	prepara_zone()
	prepara_cose()
	camera = Camera2D.new()
	camera.position = io
	camera.limit_left = int(MONDO.position.x) - 200
	camera.limit_top = int(MONDO.position.y) - 120
	camera.limit_right = int(MONDO.end.x) + 200
	camera.limit_bottom = int(MONDO.end.y) + 160
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	add_child(camera)
	var strato := CanvasLayer.new()
	add_child(strato)
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.draw.connect(disegna_hud)
	strato.add_child(hud)
	if film:
		print("INIZIO_FILM ", Engine.get_frames_drawn())


# ------------------------------------------------------------- la mappa

func prepara_zone() -> void:
	var dati := {"atterraggio": [Vector2(470, 800), Vector2(400, 280), 0.7, "IL CAMPO D'ATTERRAGGIO"],
			"piana": [Vector2(1370, 740), Vector2(330, 260), 2.1, "LA PIANA DI FERRO"],
			"cratere": [Vector2(1900, 330), Vector2(270, 200), 3.7, "IL CRATERE"]}
	var dado := RandomNumberGenerator.new()
	dado.seed = 7
	for id: String in dati:
		var d: Array = dati[id]
		var poligono := Disegno.zolla(d[0], d[1], float(d[2]))
		var nebbia: PackedVector2Array = Geometry2D.offset_polygon(poligono, 34.0)[0]
		zone[id] = {"nome": d[3], "poligono": poligono, "calpesto": Geometry2D.offset_polygon(poligono, -16.0)[0],
				"nebbia": nebbia, "aperta": id == "atterraggio", "svela": 1.0 if id == "atterraggio" else 0.0,
				"da": Vector2.ZERO, "ciottoli": punti_dentro(poligono, 70, dado), "puntini": retino(nebbia)}
	for k in 260:
		stelle.append(Vector2(dado.randf_range(-600, MONDO.end.x + 600), dado.randf_range(-400, MONDO.end.y + 400)))


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
				"costo": {"ferro": 6}, "scorta": 0, "tiene": 12, "ogni": 1.6, "conto": 0.0},
		"forziere": {"tipo": "forziere", "dove": Vector2(1920, 255), "zona": "cratere", "aperto": false},
		"ponte": passaggio(Vector2(862, 772), Vector2(1084, 752), 66.0, {"quarzo": 12}, "RIPARA IL PONTE", "atterraggio", "piana"),
		"cancello": passaggio(Vector2(1588, 584), Vector2(1752, 452), 64.0, {"ferro": 6, "quarzo": 5}, "APRI IL CANCELLO",
				"piana", "cratere")}


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


func punti_dentro(poligono: PackedVector2Array, quanti: int, dado: RandomNumberGenerator) -> PackedVector2Array:
	var punti := PackedVector2Array()
	var ingombro := Rect2(poligono[0], Vector2.ZERO)
	for p in poligono:
		ingombro = ingombro.expand(p)
	var dentro: PackedVector2Array = Geometry2D.offset_polygon(poligono, -20.0)[0]
	while punti.size() < quanti:
		var p := Vector2(dado.randf_range(ingombro.position.x, ingombro.end.x), dado.randf_range(ingombro.position.y, ingombro.end.y))
		if Geometry2D.is_point_in_polygon(p, dentro):
			punti.append(p)
	return punti


func retino(poligono: PackedVector2Array) -> PackedVector2Array:
	var punti := PackedVector2Array()
	var ingombro := Rect2(poligono[0], Vector2.ZERO)
	for p in poligono:
		ingombro = ingombro.expand(p)
	var riga := 0
	var y := ingombro.position.y
	while y < ingombro.end.y:
		var x := ingombro.position.x + (8.0 if riga % 2 == 1 else 0.0)
		while x < ingombro.end.x:
			if Geometry2D.is_point_in_polygon(Vector2(x, y), poligono):
				punti.append(Vector2(x, y))
			x += 16.0
		y += 14.0
		riga += 1
	return punti


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
	camera.position = io
	queue_redraw()
	hud.queue_redraw()


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
	for id: String in zone:
		var z: Dictionary = zone[id]
		if bool(z["aperta"]) and float(z["svela"]) < 1.0:
			z["svela"] = minf(1.0, float(z["svela"]) + delta / SVELA)
			if float(z["svela"]) >= 1.0:
				scatto("svelata_" + id)
	var restano: Array[Dictionary] = []
	for s in scritte:
		s["eta"] = float(s["eta"]) + delta
		if float(s["eta"]) < 1.6:
			restano.append(s)
	scritte = restano
	if not annuncio.is_empty():
		annuncio["eta"] = float(annuncio["eta"]) + delta


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
		return
	if absf(v.x) > 0.2:
		faccia = signf(v.x)
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
			return 52.0
		"passaggio":
			return 8.0
	return 42.0


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
		var di_qua: Vector2 = p["da"] if avanti else p["a"]
		var di_la: Vector2 = p["a"] if avanti else p["da"]
		tappe.append(di_qua)
		if not bool(p["aperto"]):
			return tappe
		tappe.append(di_la)
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
	var prezzo := PackedStringArray()
	var mancano := PackedStringArray()
	for risorsa: String in costo:
		prezzo.append("%d %s" % [int(costo[risorsa]), NOMI[risorsa]])
		var manca := int(costo[risorsa]) - int(borsa[risorsa])
		if manca > 0:
			mancano.append("%d %s" % [manca, NOMI[risorsa]])
	return {"testo": azione + "  ·  " + "  ".join(prezzo), "puoi": mancano.is_empty(),
			"manca": "" if mancano.is_empty() else "MANCANO " + " E ".join(mancano)}


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
	lavoro = {"cosa": id, "tempo": 0.0, "durata": durata}


func paga(costo: Dictionary) -> void:
	for risorsa: String in costo:
		borsa[risorsa] = int(borsa[risorsa]) - int(costo[risorsa])
		scrivi(io, "-%d %s" % [int(costo[risorsa]), NOMI[risorsa]], Disegno.CARTA)


func lavora(delta: float) -> void:
	lavoro["tempo"] = float(lavoro["tempo"]) + delta
	if float(lavoro["tempo"]) >= float(lavoro["durata"]):
		var id := String(lavoro["cosa"])
		lavoro = {}
		fatto(id)


func fatto(id: String) -> void:
	var c: Dictionary = cose[id]
	match String(c["tipo"]):
		"vena":
			var risorsa := String(c["risorsa"])
			borsa[risorsa] = int(borsa[risorsa]) + int(c["quanto"])
			c["carica"] = 0.0
			scrivi(c["dove"], "+%d %s" % [int(c["quanto"]), NOMI[risorsa]], Disegno.ARANCIO)
			scatto("scavo_" + id)
		"passaggio":
			c["aperto"] = true
			var z: Dictionary = zone[c["apre"]]
			z["aperta"] = true
			z["da"] = (Vector2(c["da"]) + Vector2(c["a"])) * 0.5
			annuncio = {"testo": z["nome"], "eta": 0.0}
			scatto("aperto_" + id)
		"trivella":
			if not bool(c["costruita"]):
				c["costruita"] = true
				scatto("trivella")
			else:
				borsa["quarzo"] = int(borsa["quarzo"]) + int(c["scorta"])
				scrivi(c["dove"], "+%d QUARZO" % int(c["scorta"]), Disegno.ARANCIO)
				c["scorta"] = 0
		"forziere":
			c["aperto"] = true
			borsa["tazo"] = int(borsa["tazo"]) + 50
			scrivi(c["dove"], "+50 TAZO", Color("#ffd23a"))
			annuncio = {"testo": "UN COLLEZIONABILE", "eta": 0.0}
			scatto("forziere")


func scrivi(dove: Vector2, testo: String, tinta: Color) -> void:
	scritte.append({"dove": dove, "testo": testo, "tinta": tinta, "eta": 0.0})


func scatto(nome: String) -> void:
	# nel film: quale fotogramma tenere come foto
	if film:
		print("SCATTO %s %d" % [nome, Engine.get_frames_drawn() + 12])


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


# ------------------------------------------------------------- il disegno

func _draw() -> void:
	Disegno.vuoto(self, MONDO.grow(700), stelle)
	for id: String in zone:
		Disegno.zona(self, (zone[id] as Dictionary)["poligono"], (zone[id] as Dictionary)["ciottoli"])
	var cancello: Dictionary = cose["cancello"]
	var campi: Array = []
	for id: String in zone:
		campi.append((zone[id] as Dictionary)["poligono"])
	Disegno.passerella(self, cancello["poligono"], campi)
	var ponte: Dictionary = cose["ponte"]
	Disegno.ponte(self, ponte["da"], ponte["a"], ponte["largo"], quanto_fatto("ponte"))
	# le cose e il personaggio, dall'alto in basso: chi sta piu' giu' copre chi sta su
	var ordine: Array = cose.keys().filter(func(id: String) -> bool: return String((cose[id] as Dictionary)["tipo"]) != "passaggio")
	ordine.append("cancello")
	ordine.append("")
	ordine.sort_custom(func(a: String, b: String) -> bool: return y_di(a) < y_di(b))
	for id: String in ordine:
		disegna_cosa(id)
	for id: String in zone:
		var z: Dictionary = zone[id]
		if float(z["svela"]) < 1.0:
			Disegno.nebbia(self, z["nebbia"], z["puntini"], z["da"], float(z["svela"]) * float(z["svela"]) * 1200.0)
	disegna_cartelli()
	var vicina := cosa_vicina(SI_VEDE) if lavoro.is_empty() else ""
	if vicina != "":
		var detto := invito(vicina)
		Disegno.invito(self, Vector2((cose[vicina] as Dictionary)["dove"]) + Vector2(0, -96), String(detto["testo"]),
				bool(detto["puoi"]), String(detto["manca"]))
	for s in scritte:
		Disegno.sale(self, s["dove"], String(s["testo"]), float(s["eta"]), s["tinta"])


func y_di(id: String) -> float:
	if id == "":
		return io.y
	if id == "cancello":
		return (Vector2((cose[id] as Dictionary)["da"]) + Vector2((cose[id] as Dictionary)["a"])).y * 0.5
	return Vector2((cose[id] as Dictionary)["dove"]).y


func quanto_fatto(id: String) -> float:
	# un passaggio: 1 aperto, 0 chiuso, in mezzo mentre ci lavori
	if bool((cose[id] as Dictionary)["aperto"]):
		return 1.0
	if not lavoro.is_empty() and String(lavoro["cosa"]) == id:
		return float(lavoro["tempo"]) / float(lavoro["durata"])
	return 0.0


func disegna_cosa(id: String) -> void:
	if id == "":
		var colpo := -1.0
		if not lavoro.is_empty():
			colpo = fmod(float(lavoro["tempo"]) / 0.4, 1.0)
		Disegno.personaggio(self, io, faccia, passo, colpo)
		return
	var c: Dictionary = cose[id]
	match String(c["tipo"]):
		"vena":
			Disegno.vena(self, c["dove"], String(c["risorsa"]), float(c["carica"]), tempo)
		"modulo":
			Disegno.modulo(self, c["dove"], tempo)
		"trivella":
			var su := 1.0 if bool(c["costruita"]) else quanto_trivella()
			Disegno.trivella(self, c["dove"], su >= 1.0, int(c["scorta"]), int(c["tiene"]), tempo)
		"forziere":
			Disegno.forziere(self, c["dove"], bool(c["aperto"]), tempo)
		"passaggio":
			var verso := (Vector2(c["a"]) - Vector2(c["da"])).normalized()
			Disegno.cancello(self, (Vector2(c["da"]) + Vector2(c["a"])) * 0.5, verso, float(c["largo"]), quanto_fatto(id))


func quanto_trivella() -> float:
	if not lavoro.is_empty() and String(lavoro["cosa"]) == "trivella":
		return float(lavoro["tempo"]) / float(lavoro["durata"])
	return 0.0


func disegna_cartelli() -> void:
	# il cartello di legno davanti a quello che si paga: si vede da lontano
	for id: String in ["ponte", "cancello", "trivella"]:
		var c: Dictionary = cose[id]
		if not si_vede(id) or bool(c.get("aperto", false)) or bool(c.get("costruita", false)):
			continue
		var base: Vector2 = Vector2(c["dove"]) + Vector2(-46, 24)
		var costo: Dictionary = c["costo"]
		var largo := 18.0 + 46.0 * float(costo.size())
		draw_line(base, base + Vector2(0, -30), Disegno.INK, 4.0)
		var tavola := Rect2(base + Vector2(-largo * 0.5, -58), Vector2(largo, 30))
		draw_rect(tavola, Disegno.LEGNO_CHIARO)
		draw_rect(tavola, Disegno.INK, false, 2.0)
		var x := tavola.position.x + 14.0
		for risorsa: String in costo:
			Disegno.risorsa(self, Vector2(x, tavola.get_center().y), risorsa, 7.0)
			draw_string(Caratteri.titolo(), Vector2(x + 10.0, tavola.get_center().y + 6.0), str(int(costo[risorsa])),
					HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Disegno.INK)
			x += 46.0


func disegna_hud() -> void:
	var f := Caratteri.titolo()
	# quello che hai in tasca, in alto a sinistra
	var x := 24.0
	for risorsa: String in ["quarzo", "ferro", "cristallo", "tazo"]:
		if int(borsa[risorsa]) == 0 and risorsa in ["cristallo", "tazo"]:
			continue
		var r := Rect2(x, 22, 112, 42)
		scatola(r)
		Disegno.risorsa(hud, r.position + Vector2(24, 21), risorsa, 9.0)
		hud.draw_string(f, r.position + Vector2(44, 30), str(int(borsa[risorsa])), HORIZONTAL_ALIGNMENT_LEFT, -1, 22,
				Disegno.CARTA)
		x += 122.0
	# l'obiettivo di adesso, sotto la tasca: uno alla volta, come le cose da
	# fare di un giardino. Quando sono finiti, lo dice
	var fatti := 0
	var adesso := ""
	for obiettivo: Array in OBIETTIVI:
		if obiettivo_fatto(String(obiettivo[0])):
			fatti += 1
		elif adesso == "":
			adesso = String(obiettivo[1])
	var riga := Rect2(24, 74, 360, 36)
	scatola(riga)
	Manifesto.etichetta_tinta(hud, riga.position + Vector2(-1, -9), "OBIETTIVO  %d / %d" % [mini(fatti + 1, OBIETTIVI.size()),
			OBIETTIVI.size()], 10, Disegno.ARANCIO, Disegno.INK)
	hud.draw_string(f, riga.position + Vector2(14, 26), adesso if adesso != "" else "Il pianeta è tuo: torna quando vuoi",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Disegno.CARTA)
	# come si gioca, in basso
	var aiuto := "FRECCE O WASD  ·  CAMMINA        E  ·  SCAVA, RIPARA, COSTRUISCI        CLIC  ·  VAI LÌ"
	scatola(Rect2(24, 672, 620, 28))
	DisegnoProiezione.scrivi(hud, Vector2(36, 691), aiuto, 10, Disegno.CARTA, 450, 85, 2)
	DisegnoProiezione.scrivi(hud, Vector2(1060, 691), "PIANETA D'ESEMPIO  ·  LA RACCOLTA", 10, Color(Disegno.CARTA, 0.7),
			450, 85, 2)
	if not annuncio.is_empty() and float(annuncio["eta"]) < 3.0:
		var a := clampf(minf(float(annuncio["eta"]) * 3.0, (3.0 - float(annuncio["eta"])) * 2.0), 0.0, 1.0)
		var testo := String(annuncio["testo"])
		var largo := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 34).x + 34.0
		Manifesto.etichetta_tinta(hud, Vector2(640 - largo * 0.5, 96), testo, 34, Color(Disegno.ARANCIO, a),
				Color(Disegno.INK, a))


func obiettivo_fatto(chiave: String) -> bool:
	match chiave:
		"quarzo":
			return int(borsa["quarzo"]) >= 12 or bool((cose["ponte"] as Dictionary)["aperto"])
		"trivella":
			return bool((cose["trivella"] as Dictionary)["costruita"])
	return bool((cose[chiave] as Dictionary)["aperto"])


func scatola(r: Rect2) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(Disegno.INK, 0.88)
	s.set_corner_radius_all(6)
	s.border_color = Color(Disegno.CARTA, 0.35)
	s.set_border_width_all(1)
	hud.draw_style_box(s, r)
