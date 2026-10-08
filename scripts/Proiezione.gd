class_name Proiezione
extends Control

# LA PROIEZIONE: la mappa stellare e il Vuoto, in tre dimensioni vere.
#
# Bru, mandando tre poster (Interstellar, uno ciano, uno verde acido):
# «riusciamo a farla dinamica e animata? e con interazioni come su mass
# effect per i pianeti intorno e le fratture». Approvata la bozza filmata:
# «moooolto bene, implementiamo cosi».
#
# L'IDEA. Il Carnivalz deforma la realta' intorno al pianeta (storia.md, «Il
# Vuoto»), e qui la deformazione si vede: e' un pozzo nella griglia. Ogni
# frattura e' un pozzo piu' piccolo che orbita il grande. Le linee le disegna
# lo shader sul piano (shaders/), quindi si piegano da sole dentro i pozzi.
#
# SOLO I CARNIVALZ SONO PIANETI. Bru: «le fratture devono sembrare piu'
# distorsioni spazio tempo piu' che pianeti». Un corpo ha una "forma": "sfera"
# (i Carnivalz, i pianeti delle risorse, i meteoriti) e' una palla a retino;
# "lente" (le fratture) e' un vortice che piega quello che c'e' dietro
# (shaders/proiezione_lenti); "nessuna" e' solo un punto con la sua scheda.
#
# COME MASS EFFECT (dai riassunti che ho potuto leggere: la mappa a livelli,
# «entrare in orbita», la scansione a impulso):
#   - due livelli, il settore e il Vuoto: dal settore ci si lancia sul pianeta
#     del sistema, nel Vuoto si risale (chi li riempie: Mappa.gd e Vuoto.gd)
#   - passando su un corpo il mirino si stringe e la scheda a destra si
#     riempie; il primo clic lo SCEGLIE, il secondo CONFERMA. La navicella che
#     volava fin li' non c'e' piu': Bru, «possiamo risparmiarci questa
#     animazione»
#   - Esc, o il tasto destro, annulla la scelta; senza una scelta Esc resta
#     la pausa, come in ogni altra schermata
#   - aprendo la proiezione parte un'onda di scansione; una frattura nuova si
#     strappa nella griglia
#
# I CORPI SONO BUTTON VERI, trasparenti, che inseguono il loro pianeta sullo
# schermo: il mouse, la tastiera (Tab, frecce, Invio), le prove e l'automa li
# premono come qualunque bottone. Quello che si vede lo disegnano
# DisegnoProiezione (sopra la griglia) e SchedaProiezione (la colonna).
#
# Col movimento ridotto (Impostazioni) la camera e le orbite stanno ferme,
# niente cadute, niente scansione: le informazioni restano tutte.
#
# NIENTE GRANA. C'era un velo di puntini chiari e scuri, a tutto schermo, che
# saltavano otto volte al secondo come la carta di una serigrafia. Si
# leggevano come stelle che non stanno ferme, anche dentro le schede. Bru:
# «tutti quei pallini che appaiono quando entri o esci dalle zone nella mappa
# stellare vanno tolti».

signal puntato(id: String)
signal scelto_corpo(id: String)
signal confermato(id: String)
signal annullato

const GRIGLIA := preload("res://shaders/proiezione_griglia.gdshader")
const RETINO := preload("res://shaders/proiezione_retino.gdshader")
const ANELLO := preload("res://shaders/proiezione_anello.gdshader")
const LENTI := preload("res://shaders/proiezione_lenti.gdshader")
const LENTI_MASSIME := 12   # quante ne tiene lo shader
const LENTE := 4.05         # quanto e' largo un gorgo rispetto al suo corpo: il buco nero sta a un quinto
const SPALLA := 2.4      # la camera guarda un po' a sinistra: a destra c'e' la colonna delle schede
const PER_LIVELLO := {
	"settore": {"bersaglio": Vector3(0, -0.8, 0.5), "giro": -0.05, "fov": 50.0, "polare": 0.0, "passo": 1.0,
			"esponente": 1.4, "distanza": 17.0, "beccheggio": 28.0},
	"vuoto": {"bersaglio": Vector3(0, -1.6, 0), "giro": 0.12, "fov": 50.0, "polare": 7.5, "passo": 0.9,
			"esponente": 1.15, "distanza": 21.0, "beccheggio": 33.0},
}

var livello := "settore"
var intestazione := "CARNIVALZ  ·  SALA OPERATIVA  ·  PROIEZIONE"
var titolo_grande := ""
var sopratitolo := ""
var nota_destra := ""
var tinte: Dictionary = {}
var corpi: Array[Dictionary] = []
var pozzi_fissi: Array[Vector4] = []   # stelle lontane: pozzi minimi, senza nome
var strato: Control                    # dove vivono i Button dei corpi
var bottone_entra: Button
var t := 0.0
var t_livello := 0.0

var vista: SubViewport
var schermo: TextureRect
var lenti: ColorRect
var mat_lenti: ShaderMaterial
var camera: Camera3D
var mat_griglia: ShaderMaterial
var sopra: Control
var fondo_dietro: Control

# la camera guarda 'bersaglio' da 'distanza', girata di 'giro' e inclinata di
# 'beccheggio' gradi; si avvicina a cam_voluta senza scatti
var cam := {}
var cam_voluta := {}
var rapidita := 2.0

var sotto := ""                # il corpo sotto il mouse, o col fuoco
var scelto := ""               # il corpo scelto: il secondo clic lo conferma
var da_quando_sotto := 0.0
var da_quando_scelto := 0.0
var onda := -1.0
var onda_centro := Vector2.ZERO
var accensione := 999.0
var lampo := 0.0
var crepa_dove := ""
var nuova_t := -1.0
var pronta := false            # dopo il primo fotogramma: prima la camera non e' ancora al suo posto
var cursore_finto := Vector2.INF      # per le prove: il mouse dove lo vuole la prova (anche fuori schermo)
var mano := ManoProiezione.new()      # quello che il giocatore aggiunge all'inquadratura


func _ready() -> void:
	tinte = CieloProiezione.tinte()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	costruisci()
	imposta_livello(livello)


func costruisci() -> void:
	var nero := ColorRect.new()
	nero.color = tinte["fondo"]
	nero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nero.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(nero)
	fondo_dietro = CieloProiezione.nebulosa(tinte["inchiostro"])
	add_child(fondo_dietro)
	vista = SubViewport.new()
	vista.own_world_3d = true
	vista.transparent_bg = true
	vista.msaa_3d = Viewport.MSAA_4X
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vista.size = misura_della_vista()
	add_child(vista)
	schermo = TextureRect.new()
	schermo.texture = vista.get_texture()
	schermo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	schermo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	schermo.stretch_mode = TextureRect.STRETCH_SCALE
	schermo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schermo)
	# le fratture: lenti che piegano quello che e' gia' disegnato qui sotto
	mat_lenti = CieloProiezione.materiale(LENTI, {"segnale": tinte["segnale"]})
	tingi(mat_lenti)
	lenti = ColorRect.new()
	lenti.material = mat_lenti
	lenti.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lenti.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lenti.visible = false
	add_child(lenti)
	camera = Camera3D.new()
	camera.near = 0.05
	camera.far = 400.0
	camera.h_offset = SPALLA
	vista.add_child(camera)
	costruisci_griglia()
	vista.add_child(CieloProiezione.stelle(tinte["carta"], 900, 5))
	sopra = Control.new()
	sopra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sopra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sopra.draw.connect(func() -> void: DisegnoProiezione.disegna(self, sopra))
	add_child(sopra)
	bottone_entra = Button.new()
	DisegnoProiezione.trasparente(bottone_entra)
	bottone_entra.position = SchedaProiezione.posto_del_bottone().position
	bottone_entra.size = SchedaProiezione.posto_del_bottone().size
	bottone_entra.pressed.connect(conferma)
	add_child(bottone_entra)


func costruisci_griglia() -> void:
	var griglia := MeshInstance3D.new()
	var piano := PlaneMesh.new()
	piano.size = Vector2(90, 90)
	piano.subdivide_width = 300
	piano.subdivide_depth = 300
	griglia.mesh = piano
	mat_griglia = CieloProiezione.materiale(GRIGLIA, {"rumore": CieloProiezione.rumore()})
	tingi(mat_griglia)
	griglia.material_override = mat_griglia
	griglia.extra_cull_margin = 60.0
	vista.add_child(griglia)


func misura_della_vista() -> Vector2i:
	# la proiezione si disegna ai pixel veri della finestra, non ai 1280x720
	# del gioco: a schermo intero i puntini del retino restano puntini
	# (la scala del foglio compresa: col testo grande la schermata e' rimpicciolita)
	var scala := (get_viewport().get_final_transform() * get_global_transform_with_canvas()).get_scale() \
			if get_viewport() != null else Vector2.ONE
	if DisplayServer.window_get_size() == Vector2i.ZERO:
		scala = Vector2.ONE   # senza finestra (le prove) si disegna come a 1280x720
	return Vector2i(maxi(64, roundi(size.x * scala.x)), maxi(64, roundi(size.y * scala.y)))


func tingi(m: ShaderMaterial) -> void:
	for chiave in ["fondo", "inchiostro", "carta"]:
		m.set_shader_parameter(chiave, tinte[chiave])


func imposta_livello(quale: String) -> void:
	livello = quale
	t_livello = 0.0
	var p: Dictionary = PER_LIVELLO.get(quale, PER_LIVELLO["settore"])
	mat_griglia.set_shader_parameter("polare", p["polare"])
	mat_griglia.set_shader_parameter("passo", p["passo"])
	mat_griglia.set_shader_parameter("esponente", p["esponente"])
	fondo_dietro.visible = quale == "settore"
	cam = inquadratura()
	cam_voluta = cam.duplicate()


func inquadratura() -> Dictionary:
	# l'inquadratura di riposo del livello: i numeri che si toccano stanno in stile.json
	var p: Dictionary = PER_LIVELLO.get(livello, PER_LIVELLO["settore"])
	var scritti := CieloProiezione.inquadratura(livello)
	return {"bersaglio": p["bersaglio"], "giro": p["giro"], "fov": p["fov"], "spalla": SPALLA,
			"distanza": float(scritti.get("distanza", p["distanza"])),
			"beccheggio": float(scritti.get("beccheggio", p["beccheggio"]))}


func immagine_di_fondo(texture: Texture2D) -> void:
	# un'illustrazione vera (mappa.json, "sfondo") prende il posto della nebulosa
	var r := TextureRect.new()
	r.texture = texture
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(r)
	move_child(r, fondo_dietro.get_index())
	fondo_dietro.visible = false


# --- i corpi ---------------------------------------------------------------------

func aggiungi(dati: Dictionary) -> Dictionary:
	var c := {"id": "", "nome": "", "tipo": "frattura", "orbita": 0.0, "angolo": 0.0, "vel": 0.0,
			"profondita": 1.6, "largo": 0.55, "raggio": 0.42, "stato": "visto", "epoca": "", "testo": "",
			"azione": "", "attiva": false, "apertura": 1.0, "bande": 0.0, "spento": 0.0, "segnale": false,
			"xz": Vector2.ZERO, "pos": Vector3.ZERO, "respiro": 0.0, "forma": "sfera", "dati": []}
	c.merge(dati, true)
	if c["forma"] == "sfera":
		c["nodo"] = sfera(c)
	c["bottone"] = bersaglio(c)
	corpi.append(c)
	return c


func sfera(c: Dictionary) -> MeshInstance3D:
	# un pianeta a retino, come i punti stampati del poster
	var nodo := MeshInstance3D.new()
	var forma := SphereMesh.new()
	forma.radius = 1.0
	forma.height = 2.0
	forma.radial_segments = 48
	forma.rings = 24
	nodo.mesh = forma
	var m := CieloProiezione.materiale(RETINO, {"bande": float(c["bande"]), "spento": float(c["spento"]),
			"cella": 4.0 * float(vista.size.y) / 720.0})
	tingi(m)
	nodo.material_override = m
	vista.add_child(nodo)
	return nodo


func bersaglio(c: Dictionary) -> Button:
	# il Button che insegue il corpo: invisibile, ma vero
	var id := String(c["id"])
	var b := Button.new()
	DisegnoProiezione.trasparente(b)
	b.accessibility_name = String(c["nome"])
	b.set_meta("id", id)
	b.set_meta("nome", String(c["nome"]))
	b.pressed.connect(premuto.bind(id))
	b.mouse_entered.connect(punta.bind(id))
	b.focus_entered.connect(punta.bind(id))
	b.mouse_exited.connect(lascia.bind(id))
	b.focus_exited.connect(lascia.bind(id))
	(strato if strato != null else self).add_child(b)
	return b


func aggiungi_anello(c: Dictionary, largo: float, inclinazione: Vector3) -> void:
	var anello := MeshInstance3D.new()
	var quadro := QuadMesh.new()
	quadro.size = Vector2(largo, largo)
	anello.mesh = quadro
	var m := CieloProiezione.materiale(ANELLO, {})
	tingi(m)
	anello.material_override = m
	anello.rotation_degrees = inclinazione
	vista.add_child(anello)
	c["anello"] = anello


func aggiungi_stelle_lontane(quante: int, seme: int) -> void:
	var d := RandomNumberGenerator.new()
	d.seed = seme
	for i in quante:
		pozzi_fissi.append(Vector4(d.randf_range(-24, 24), d.randf_range(-16, 10), d.randf_range(0.25, 0.7),
				d.randf_range(0.25, 0.5)))


func corpo(id: String) -> Dictionary:
	for c in corpi:
		if c["id"] == id:
			return c
	return {}


# --- scegliere, confermare, annullare -------------------------------------------

func punta(id: String) -> void:
	if sotto == id:
		return
	sotto = id
	da_quando_sotto = 0.0
	AudioManager.tocco("sfiora")
	puntato.emit(id)


func lascia(id: String) -> void:
	if sotto == id:
		sotto = ""


func premuto(id: String) -> void:
	# il primo clic sceglie, il secondo sullo stesso corpo conferma
	if scelto == id:
		conferma()
	else:
		scegli(id)


func scegli(id: String) -> void:
	var c := corpo(id)
	if c.is_empty():
		return
	scelto = id
	da_quando_scelto = 0.0
	AudioManager.interfaccia("conferma")
	mano.voluto["spinta"] = Vector3.ZERO
	if livello == "vuoto":
		# come entrare in orbita: la camera si avvicina senza perdere il sistema
		var riposo := inquadratura()
		cam_voluta["bersaglio"] = (riposo["bersaglio"] as Vector3).lerp(c["pos"], 0.3)
		cam_voluta["distanza"] = float(riposo["distanza"]) - 2.5
		cam_voluta["beccheggio"] = float(riposo["beccheggio"]) + 1.0
	scelto_corpo.emit(id)


func conferma() -> void:
	var c := corpo(scelto)
	if c.is_empty() or not bool(c["attiva"]):
		return
	AudioManager.interfaccia("conferma")
	confermato.emit(scelto)


func annulla() -> void:
	scelto = ""
	cam_voluta = inquadratura()
	AudioManager.interfaccia("annulla")
	annullato.emit()


func _unhandled_input(evento: InputEvent) -> void:
	# trascinare, la rotella, i tasti della mappa: la mano (ManoProiezione). Le
	# sue misure sono nei pixel della proiezione, non della finestra: col testo
	# grande la schermata e' un foglio scalato (Tavola.come_foglio), e la
	# rotella avvicinava verso un punto che non era quello sotto il cursore
	if pronta and mano.gestisci(make_input_local(evento), self):
		get_viewport().set_input_as_handled()
		return
	# CON UNA SCELTA IN MANO, Esc la lascia andare; senza, Esc passa avanti e
	# apre la pausa come dappertutto
	if scelto == "":
		return
	var destro := evento is InputEventMouseButton and (evento as InputEventMouseButton).pressed \
			and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT
	if evento.is_action_pressed("ui_cancel") or destro:
		annulla()
		get_viewport().set_input_as_handled()


# --- i gesti grandi ------------------------------------------------------------------

func accendi(centro: Vector2) -> void:
	# l'onda di scansione: la griglia si accende dal centro verso fuori
	if Movimento.ridotto():
		return
	accensione = 0.0
	onda = 0.0
	onda_centro = centro


func cadi_nel_pozzo(id: String) -> void:
	# DAL SETTORE AL VUOTO: ci si lancia SUL PIANETA del sistema. Bru, sulla
	# prima versione: «quando ti lanci sembra andare verso il centro del pozzo
	# gravitazionale invece che sul pianeta» - la camera guardava giu' nel
	# pozzo, e la spalla la spostava di lato. Adesso arriva di fronte al
	# pianeta, dritta, finche' lo schermo e' suo. Chi chiama cambia schermata
	# dopo; nel Vuoto si risale (risali)
	var c := corpo(id)
	if c.is_empty() or Movimento.ridotto():
		return
	# una corsa con un inizio e una fine, non un inseguimento: deve finire
	# proprio sul pianeta quando lo schermo cambia
	# parte da dove stai guardando, mano compresa: niente scatto
	cam = mano.applica(cam)
	mano.azzera()
	var da := cam.duplicate()
	var a := {"bersaglio": c["pos"], "distanza": float(c["raggio"]) * 2.2, "giro": float(cam["giro"]),
			"beccheggio": 16.0, "fov": 58.0, "spalla": 0.0}
	var corsa := create_tween()
	corsa.tween_method(func(k: float) -> void:
		cam = mescola(da, a, k)
		cam_voluta = cam.duplicate(), 0.0, 1.0, CieloProiezione.misura("tuffo", 1.1)) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await corsa.finished
	lampo = 1.0


static func mescola(da: Dictionary, a: Dictionary, k: float) -> Dictionary:
	# un'inquadratura a meta' strada fra due
	var fra := {}
	for chiave in a:
		if chiave == "bersaglio":
			fra[chiave] = (da.get(chiave, a[chiave]) as Vector3).lerp(a[chiave], k)
		else:
			fra[chiave] = lerpf(float(da.get(chiave, a[chiave])), float(a[chiave]), k)
	return fra


func risali(id_centro: String) -> void:
	# si arriva davanti al pianeta del centro, come ci si era lanciati, e la
	# camera si tira indietro fino a vedere tutto il sistema
	if Movimento.ridotto():
		return
	muovi_corpi(0.0)
	var c := corpo(id_centro)
	var dove: Vector3 = c.get("pos", Vector3(0, -1.0, 0))
	cam = {"bersaglio": dove, "distanza": float(c.get("raggio", 1.0)) * 2.4, "giro": 0.4, "beccheggio": 16.0,
			"fov": 58.0, "spalla": 0.0}
	cam_voluta = inquadratura()
	rapidita = 1.6
	accendi(Vector2.ZERO)


func apri_frattura(id: String) -> void:
	# UNA FRATTURA NUOVA: la griglia si strappa, il pozzo si scava, e lo dice
	var c := corpo(id)
	if c.is_empty():
		return
	crepa_dove = id
	nuova_t = t
	if Movimento.ridotto():
		c["apertura"] = 1.0
		return
	c["apertura"] = 0.0
	onda = 0.0
	onda_centro = c["xz"]
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void: c["apertura"] = v, 0.0, 1.0, 1.4)


# --- ogni fotogramma ---------------------------------------------------------------

func _process(delta: float) -> void:
	t += delta
	t_livello += delta
	da_quando_sotto += delta
	da_quando_scelto += delta
	if vista.size != misura_della_vista():
		vista.size = misura_della_vista()
	muovi_corpi(delta)
	mano.aggiorna(delta)
	muovi_camera(delta)
	muovi_bersagli()
	if onda >= 0.0:
		onda += delta * 16.0
		if onda > 70.0:
			onda = -1.0
	accensione = minf(accensione + delta * 26.0, 999.0)
	lampo = maxf(lampo - delta * 2.5, 0.0)
	mat_griglia.set_shader_parameter("onda", onda)
	mat_griglia.set_shader_parameter("onda_centro", onda_centro)
	mat_griglia.set_shader_parameter("accensione", accensione)
	var luce := corpo(sotto if sotto != "" else scelto)
	mat_griglia.set_shader_parameter("luce", 0.0 if luce.is_empty() else 1.0)
	if not luce.is_empty():
		mat_griglia.set_shader_parameter("luce_pos", luce["xz"])
	var guardo := mano.applica(cam)
	fondo_dietro.position = Vector2(-160 - float(guardo["giro"]) * 600.0, -40 + (float(guardo["beccheggio"]) - 28.0) * 6.0)
	muovi_lenti()
	bottone_entra.disabled = not bool(corpo(scelto).get("attiva", false))
	pronta = true
	sopra.queue_redraw()


func pozzi(solo_fermi := false) -> Array[Vector4]:
	# al massimo sedici, quanti ne tiene lo shader: prima i corpi, poi le stelle
	# lontane. Solo_fermi: senza i pianeti che girano, per chi deve stare fermo
	var lista: Array[Vector4] = []
	for c in corpi:
		if float(c["profondita"]) <= 0.0 or (solo_fermi and float(c["vel"]) != 0.0):
			continue
		lista.append(Vector4(c["xz"].x, c["xz"].y, float(c["profondita"]) * float(c["apertura"]), float(c["largo"])))
	for w in pozzi_fissi:
		if lista.size() < 16:
			lista.append(w)
	return lista


func altezza(p: Vector2, lista: Array[Vector4]) -> float:
	# la stessa piega dello shader, per mettere i pianeti al posto giusto
	var curva := float(PER_LIVELLO.get(livello, PER_LIVELLO["settore"])["esponente"])
	var h := 0.0
	for w in lista:
		var d := p.distance_to(Vector2(w.x, w.y))
		h -= w.z * pow(w.w / sqrt(d * d + w.w * w.w), curva)
	return h


func muovi_corpi(delta: float) -> void:
	var fermi := Movimento.ridotto()
	for c in corpi:
		if float(c["orbita"]) > 0.0:
			if not fermi:
				c["angolo"] = float(c["angolo"]) + float(c["vel"]) * delta
			c["xz"] = Vector2.RIGHT.rotated(float(c["angolo"])) * float(c["orbita"])
	var lista := pozzi()
	mat_griglia.set_shader_parameter("pozzi", PackedVector4Array(lista))
	mat_griglia.set_shader_parameter("n_pozzi", lista.size())
	# LE FRATTURE STANNO FERME (Bru: «perche' la frattura di qualcosa preme si
	# muove cosi' tanto? dovrebbero restare ferme sul posto»): la loro gola si
	# misura senza i pianeti che girano, che passandole accanto le facevano ballare
	var fissi := pozzi(true)
	for c in corpi:
		var xz: Vector2 = c["xz"]
		var r := float(c["raggio"]) * DisegnoProiezione.elastico(float(c["apertura"]))
		var h := altezza(xz, fissi if float(c["vel"]) == 0.0 else lista)
		# una sfera galleggia sopra il suo pozzo; una lente sta nella gola, dove la griglia si stringe
		c["pos"] = Vector3(xz.x, h * 0.8 if c["forma"] == "lente" else h * 0.5 + r * 1.2 + 0.1, xz.y)
		var nodo: Variant = c.get("nodo")
		if nodo is MeshInstance3D:
			(nodo as MeshInstance3D).position = c["pos"]
			(nodo as MeshInstance3D).scale = Vector3.ONE * maxf(r, 0.001)
			(nodo as MeshInstance3D).visible = r > 0.01
			((nodo as MeshInstance3D).material_override as ShaderMaterial).set_shader_parameter("giro",
					0.0 if fermi else t * 0.25)
		var anello: Variant = c.get("anello")
		if anello is MeshInstance3D:
			(anello as MeshInstance3D).position = c["pos"]
			(anello as MeshInstance3D).rotation_degrees.y = 0.0 if fermi else t * 3.0


func muovi_camera(delta: float) -> void:
	var k := 1.0 - exp(-delta * rapidita)
	for chiave in cam_voluta:
		if chiave == "bersaglio":
			cam["bersaglio"] = (cam["bersaglio"] as Vector3).lerp(cam_voluta["bersaglio"], k)
		else:
			cam[chiave] = lerpf(float(cam[chiave]), float(cam_voluta[chiave]), k)
	# l'inquadratura del gioco piu' la mano del giocatore; e il respiro della
	# proiezione: una deriva lenta, e un filo di parallasse col mouse (non
	# mentre si trascina: li' il mouse e' la mano)
	var guardo := mano.applica(cam)
	var mouse := get_local_mouse_position()
	var vivo := 0.0 if Movimento.ridotto() else 1.0
	var segue := 0.0 if mano.trascinando else vivo
	var giro := float(guardo["giro"]) + sin(t * 0.13) * 0.06 * vivo + (mouse.x / 1280.0 - 0.5) * 0.05 * segue
	var becc := deg_to_rad(float(guardo["beccheggio"]) + sin(t * 0.17) * 1.2 * vivo - (mouse.y / 720.0 - 0.5) * 2.0 * segue)
	var bersaglio_cam: Vector3 = guardo["bersaglio"]
	camera.position = bersaglio_cam + Vector3(sin(giro) * cos(becc), sin(becc), cos(giro) * cos(becc)) \
			* float(guardo["distanza"])
	camera.fov = float(guardo["fov"])
	camera.h_offset = float(guardo.get("spalla", SPALLA))
	camera.look_at(bersaglio_cam, Vector3.UP)


func sul_piano(dove: Vector2) -> Variant:
	# il punto della griglia (a quota zero) sotto un punto dello schermo, o null
	var v := dove * Vector2(vista.size) / size
	var origine := camera.project_ray_origin(v)
	var verso := camera.project_ray_normal(v)
	if verso.y > -0.01:
		return null
	return origine + verso * (-origine.y / verso.y)


func sullo_schermo(p: Vector3) -> Vector2:
	if camera.is_position_behind(p):
		return Vector2(-9999, -9999)
	return camera.unproject_position(p) * size / Vector2(vista.size)


func coperto(punto: Vector3) -> bool:
	# UN PUNTO DIETRO UN PIANETA: la retta dalla camera al punto entra in una
	# sfera prima di arrivarci. Per quello che si disegna sopra la griglia (gli
	# anelli dei segnali), che non ha la profondita' del 3D
	var occhio := camera.global_position
	var verso := punto - occhio
	var lungo := verso.length()
	verso /= maxf(lungo, 0.0001)
	for c in corpi:
		var nodo: Variant = c.get("nodo")
		if not nodo is MeshInstance3D or not (nodo as MeshInstance3D).visible:
			continue
		var r := (nodo as MeshInstance3D).scale.x
		var al_centro := (nodo as MeshInstance3D).position - occhio
		var avanti := al_centro.dot(verso)
		var di_lato := al_centro.length_squared() - avanti * avanti
		if avanti > 0.0 and di_lato < r * r and avanti - sqrt(r * r - di_lato) < lungo:
			return true
	return false


func raggio_sullo_schermo(c: Dictionary) -> float:
	var distanza := camera.global_position.distance_to(c["pos"])
	var focale := size.y * 0.5 / tan(deg_to_rad(camera.fov) * 0.5)
	return float(c["raggio"]) * DisegnoProiezione.elastico(float(c["apertura"])) * focale / maxf(distanza, 0.01)


func muovi_lenti() -> void:
	# OGNI FRATTURA PIEGA LO SCHERMO intorno alla sua gola. Centri e raggi
	# sono nei 1280x720 della proiezione; per spostare i pixel veri lo shader
	# ha bisogno di sapere quanto sono grandi
	var a := PackedVector4Array()
	var b := PackedVector4Array()
	var aperture := PackedVector4Array()
	var fermo := Movimento.ridotto()
	for c in corpi:
		var s := sullo_schermo(c["pos"])
		if c["forma"] != "lente" or s.x < -1000.0 or a.size() >= LENTI_MASSIME:
			continue
		# quella che punti (o hai scelto) si accende, senza scatti
		var puntata := 1.0 if String(c["id"]) in [sotto, scelto] else 0.0
		c["acceso"] = move_toward(float(c.get("acceso", 0.0)), puntata, get_process_delta_time() * 4.0)
		var fase := float(hash(String(c["id"])) % 628) / 100.0
		# una frattura che "respira" lo fa nella luce, non nel posto ne' nella misura:
		# prima il suo pozzo si gonfiava e lei saliva e scendeva di trenta pixel
		var respiro := 0.0 if fermo else 0.45 * float(c["respiro"]) * sin(t * 2.3)
		var energia := (energia_di(String(c["stato"])) + 0.5 * float(c["acceso"])) * (1.0 - float(c["spento"]) * 0.7) \
				* (1.0 + respiro)
		# il gorgo: un'ombra se la frattura e' chiusa; si apre quando la punti, e respira
		var apre := 0.18 if String(c["stato"]) in ["chiuso", "preso"] else 0.75 + 0.35 * float(c["acceso"])
		apre *= DisegnoProiezione.elastico(float(c["apertura"])) * (1.0 if fermo else 1.0 + 0.08 * sin(t * 1.7 + fase))
		# il gorgo giace sulla griglia: dall'alto e' un cerchio, di lato un'ellisse
		var schiaccia := absf((c["pos"] - camera.global_position).normalized().y)
		a.append(Vector4(s.x, s.y, raggio_sullo_schermo(c) * LENTE, 0.0))
		b.append(Vector4(float(c["spento"]), fase, energia, schiaccia))
		aperture.append(Vector4(apre, 0.0, 0.0, 0.0))
	var quante := a.size()
	lenti.visible = quante > 0
	a.resize(LENTI_MASSIME)
	b.resize(LENTI_MASSIME)
	aperture.resize(LENTI_MASSIME)
	mat_lenti.set_shader_parameter("lenti", a)
	mat_lenti.set_shader_parameter("lenti_b", b)
	mat_lenti.set_shader_parameter("lenti_c", aperture)
	mat_lenti.set_shader_parameter("n_lenti", quante)
	mat_lenti.set_shader_parameter("scala", (get_viewport().get_final_transform()
			* get_global_transform_with_canvas()).get_scale().y)
	mat_lenti.set_shader_parameter("tempo", 0.0 if Movimento.ridotto() else t)


static func energia_di(stato: String) -> float:
	# quanto e' viva una frattura: nuova brucia, vista e' calma, chiusa quasi niente
	match stato:
		"nuovo", "trovato":
			return 1.0
		"chiuso", "preso":
			return 0.15
		"spento":
			return 0.2
	return 0.55


func cursore() -> Vector2:
	# dove punta il giocatore, in coordinate della proiezione
	return cursore_finto if cursore_finto.is_finite() else get_local_mouse_position()


func muovi_bersagli() -> void:
	# ogni Button sta sopra il suo pianeta, grande quanto il pianeta (e mai
	# meno di un dito)
	for c in corpi:
		var b: Button = c["bottone"]
		var s := sullo_schermo(c["pos"])
		var lato := maxf(raggio_sullo_schermo(c) * 2.0 + 16.0, 44.0)
		b.size = Vector2(lato, lato)
		b.position = s - b.size * 0.5
		# dietro la colonna delle schede non si preme: ci sono le schede
		b.visible = float(c["apertura"]) >= 0.6 and s.x > -1000.0 and s.x < SchedaProiezione.X - 6.0

