class_name PlasticoZona
extends Control

# IL PLASTICO: la mappa di una zona come un modellino olografico in 3D, a piani.
# Bru, mandando una mappa di Metroid Prime: «vorrei dessimo una
# rappresentazione tridimensionale ma semplice come nelle mappe di metroid,
# per farti capire come e' strutturata la zona, per esempio piani inferiori o
# superiori, dove collocheremo anche quando li avremo gli npc». E prima ancora:
# «cliccando sopra ogni area dovrebbe essere possibile entrarci».
#
# Lo chiede la zona: "vista": "plastico" nel suo "mappa_dungeon". Ogni stanza e'
# un volume di luce sul suo "piano" (0 il piano terra, 1 quello sopra, -1
# quello sotto) con la pianta del suo "riquadro" (o della sua "cella", sulle
# zone a quadratini); i corridoi aperti sono tubi, e quando uniscono due piani
# diventano pozzi. Si gira, si inclina e si avvicina come la mappa stellare, e
# con gli stessi limiti (ManoProiezione): si guarda meglio, non ci si perde.
#
# QUI SI DISEGNA SOLTANTO. Cosa si sa di una stanza, dove si puo' andare e cosa
# succede cliccandola lo decide MappaZona, come sulla mappa a quadratini: le
# stanze si premono con PortaStanza, che e' un bottone vero ritagliato sulla
# sagoma che la stanza ha a schermo. Le icone (il punto esclamativo, la freccia
# del «sei qui») restano quelle di SegniMappa, sopra la stanza.
#
# I PERSONAGGI: "personaggi" su una stanza (id di personaggi.json) mette un
# segnalino sopra il suo volume, e MappaZona dice chi c'e' nella riga in basso.

const SHADER := preload("res://shaders/plastico.gdshader")
const PREDEFINITE := {"linea": "#3fd6e6", "qui": "#f29a2e", "segreta": "#8fe08a", "chiusa": "#7d8a90"}
const ALTEZZA_PIANO := 4.5       # unita' fra un piano e l'altro: abbastanza da non coprirsi
const ALTEZZA_STANZA := 0.8
const SCALA_PIANTA := 0.01       # un pixel del foglio della pianta: 1920 diventano 19,2 unita'
const LATO_CELLA := 1.7          # una cella delle zone a quadratini
const TUBO := 0.2                # quanto e' spesso un corridoio
const POZZO := 0.34              # e un pozzo fra due piani
const MARGINE_PIANI := 120.0     # a sinistra, la colonna coi nomi dei piani
const SOGLIA := 4.0              # pixel prima che un clic diventi un trascinamento
const BASE := {"giro": -0.38, "beccheggio": 22.0, "fov": 30.0}

var zona: MappaZona
var vista: SubViewport
var camera: Camera3D
var radice: Node3D
var scritte: Control             # i nomi dei piani e i segnalini: sopra il 3D, sotto le porte
var mano := ManoProiezione.new()
var cam := {}                    # l'inquadratura di partenza: tutta la zona, di tre quarti
var scatole := {}                # id stanza -> {"centro": Vector3, "misura": Vector3, "piano": int}
var accese := {}                 # id stanza -> il suo materiale, per accenderla quando la si punta
var tinte := {}
var puntata := ""
var premuto := false
var trascinando := false
var da := Vector2.ZERO
var ultima := Transform3D()      # dov'era la camera l'ultima volta che si sono messe a posto le porte


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tinte = tavolozza()
	vista = SubViewport.new()
	vista.own_world_3d = true
	vista.transparent_bg = true
	vista.msaa_3d = Viewport.MSAA_4X
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vista)
	camera = Camera3D.new()
	camera.current = true
	vista.add_child(camera)
	radice = Node3D.new()
	vista.add_child(radice)
	var schermo := TextureRect.new()
	schermo.texture = vista.get_texture()
	schermo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	schermo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	schermo.stretch_mode = TextureRect.STRETCH_SCALE
	schermo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schermo)
	scritte = Control.new()
	scritte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scritte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scritte.draw.connect(_disegna_scritte)
	add_child(scritte)
	misura_le_stanze()


static func tavolozza() -> Dictionary:
	var scritte_qui: Variant = Stile.dati.get("plastico", {})
	var d: Dictionary = scritte_qui if scritte_qui is Dictionary else {}
	var t := {}
	for chiave in PREDEFINITE:
		t[chiave] = Color(String(d.get(chiave, PREDEFINITE[chiave])))
	return t


# --- le misure: dove sta ogni stanza nel modellino -----------------------------

func misura_le_stanze() -> void:
	scatole.clear()
	for stanza: Dictionary in GameState.mappa_zona.get("stanze", []):
		scatole[String(stanza.get("id", ""))] = scatola_di(stanza)


static func scatola_di(stanza: Dictionary) -> Dictionary:
	var pianta := pianta_di(stanza)
	var piano := int(stanza.get("piano", 0))
	var quota := float(piano) * ALTEZZA_PIANO
	return {"centro": Vector3(pianta.get_center().x, quota + ALTEZZA_STANZA * 0.5, pianta.get_center().y),
			"misura": Vector3(pianta.size.x, ALTEZZA_STANZA, pianta.size.y), "piano": piano}


static func pianta_di(stanza: Dictionary) -> Rect2:
	# la stanza vista dall'alto, in unita' del modellino: dal riquadro della
	# pianta, o dalla cella (e dalla dimensione) delle zone a quadratini
	var r: Array = stanza.get("riquadro", [])
	if r.size() == 4:
		return Rect2(Vector2(float(r[0]), float(r[1])) * SCALA_PIANTA, Vector2(float(r[2]), float(r[3])) * SCALA_PIANTA)
	var cella: Array = stanza.get("cella", [0, 0])
	var misura: Array = stanza.get("dimensione", [1, 1])
	var lati := Vector2(maxf(float(misura[0]), 1.0), maxf(float(misura[1]), 1.0))
	return Rect2(Vector2(float(cella[0]), float(cella[1])) * LATO_CELLA, lati * LATO_CELLA).grow(-0.18)


func ingombro() -> AABB:
	# tutta la zona, anche le stanze che non si vedono ancora: cosi' scoprendone
	# una la vista non salta
	var tutto := AABB()
	var primo := true
	for id_stanza in scatole:
		var s: Dictionary = scatole[id_stanza]
		var scatola := AABB(s["centro"] - s["misura"] * 0.5, s["misura"])
		tutto = scatola if primo else tutto.merge(scatola)
		primo = false
	return tutto


# --- il modellino ---------------------------------------------------------------

func aggiorna() -> void:
	# si rifa' tutto: quello che si sa della zona e' cambiato (o la misura)
	for figlio in radice.get_children():
		radice.remove_child(figlio)
		figlio.queue_free()
	accese.clear()
	for id_stanza in scatole:
		if zona.si_vede(id_stanza):
			var s: Dictionary = scatole[id_stanza]
			accese[id_stanza] = volume(s["centro"], s["misura"], Basis(), stato_di(id_stanza))
	for coppia in GameState.collegamenti_aperti():
		if coppia.size() >= 2 and zona.si_vede(String(coppia[0])) and zona.si_vede(String(coppia[1])):
			corridoio(String(coppia[0]), String(coppia[1]))
	for piano in piani_visti():
		lastra(int(piano))
	evidenzia(puntata)
	scritte.queue_redraw()


func stato_di(id_stanza: String) -> Dictionary:
	# la tinta e quanto e' accesa: e' qui che una stanza dice cosa sai di lei
	var stanza: Dictionary = zona.stanze_per_id.get(id_stanza, {})
	var tinta: Color = tinte["linea"]
	if zona.chiusa(id_stanza):
		tinta = tinte["chiusa"]
	elif zona.visitata(id_stanza) and zona.e_segreta(stanza):
		tinta = tinte["segreta"]
	var luce := 1.0 if zona.visitata(id_stanza) else (0.55 if GameState.stanza_sbloccata(id_stanza) else 0.3)
	if not zona.si_puo_andare(id_stanza):
		luce *= 0.6
	var qui := id_stanza == GameState.nodo_corrente
	if qui:
		tinta = tinte["qui"]
		luce = 1.4   # dove sei si vede da lontano
	return {"tinta": tinta, "pieno": 0.34 * luce, "linea": 1.0 * luce, "pulsa": 1.0 if qui and not Movimento.ridotto() else 0.0}


func volume(centro: Vector3, misura: Vector3, base: Basis, stato: Dictionary) -> ShaderMaterial:
	# un parallelepipedo di luce: le facce appena velate e gli spigoli accesi
	var pieno := MeshInstance3D.new()
	var forma := BoxMesh.new()
	forma.size = misura
	pieno.mesh = forma
	var materiale := materiale_di(stato["tinta"], float(stato["pieno"]), float(stato["pulsa"]), 1.0)
	pieno.material_override = materiale
	pieno.transform = Transform3D(base, centro)
	radice.add_child(pieno)
	var spigoli := MeshInstance3D.new()
	spigoli.mesh = spigoli_di(misura)
	spigoli.material_override = materiale_di(stato["tinta"], float(stato["linea"]), float(stato["pulsa"]), 0.0)
	pieno.add_child(spigoli)
	return materiale


func materiale_di(tinta: Color, quanto: float, pulsa: float, taglio: float) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = SHADER
	m.set_shader_parameter("tinta", Color(tinta, quanto))
	m.set_shader_parameter("pulsa", pulsa)
	m.set_shader_parameter("taglio", taglio)
	return m


static func spigoli_di(misura: Vector3) -> ArrayMesh:
	var m := misura * 0.5
	var angoli: Array[Vector3] = []
	for i in 8:
		angoli.append(Vector3(m.x if i & 1 else -m.x, m.y if i & 2 else -m.y, m.z if i & 4 else -m.z))
	var punti := PackedVector3Array()
	for a in 8:
		for asse: int in [1, 2, 4]:
			if not a & asse:
				punti.append(angoli[a])
				punti.append(angoli[a | asse])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = punti
	var linee := ArrayMesh.new()
	linee.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return linee


func corridoio(a: String, b: String) -> void:
	# da porta a porta; se le due stanze stanno su piani diversi, il tratto in
	# piano arriva sopra (o sotto) l'altra e da li' un pozzo scende (o sale)
	var sa: Dictionary = scatole[a]
	var sb: Dictionary = scatole[b]
	var pa := Rect2(Vector2(sa["centro"].x, sa["centro"].z) - Vector2(sa["misura"].x, sa["misura"].z) * 0.5,
			Vector2(sa["misura"].x, sa["misura"].z))
	var pb := Rect2(Vector2(sb["centro"].x, sb["centro"].z) - Vector2(sb["misura"].x, sb["misura"].z) * 0.5,
			Vector2(sb["misura"].x, sb["misura"].z))
	var porta_a := SegniPianta.porta(pa, pb.get_center())
	var porta_b := SegniPianta.porta(pb, pa.get_center())
	var quota_a := float(sa["centro"].y) - ALTEZZA_STANZA * 0.25
	var quota_b := float(sb["centro"].y) - ALTEZZA_STANZA * 0.25
	var percorso := zona.visitata(a) and zona.visitata(b)
	var stato := {"tinta": tinte["linea"], "pieno": 0.16 if percorso else 0.08,
			"linea": 0.7 if percorso else 0.38, "pulsa": 0.0}
	var da_qui := Vector3(porta_a.x, quota_a, porta_a.y)
	var a_li := Vector3(porta_b.x, quota_a, porta_b.y)
	if da_qui.distance_to(a_li) > 0.05:
		tubo(da_qui, a_li, TUBO, stato)
	if absf(quota_a - quota_b) > 0.05:
		tubo(a_li, Vector3(porta_b.x, quota_b, porta_b.y), POZZO, stato)


func tubo(da_dove: Vector3, a_dove: Vector3, spessore: float, stato: Dictionary) -> void:
	var lungo := da_dove.distance_to(a_dove)
	var asse := (a_dove - da_dove) / lungo
	var su := Vector3.UP if absf(asse.y) < 0.9 else Vector3.FORWARD
	var lato := asse.cross(su).normalized()
	var base := Basis(asse, lato.cross(asse), lato)
	volume((da_dove + a_dove) * 0.5, Vector3(lungo, spessore, spessore), base, stato)


func piani_visti() -> Array:
	var piani: Array = []
	for id_stanza in scatole:
		var piano := int(scatole[id_stanza]["piano"])
		if zona.si_vede(id_stanza) and piano not in piani:
			piani.append(piano)
	piani.sort()
	return piani


func impronta_del_piano(piano: int) -> Rect2:
	# la pianta di tutte le stanze che si vedono su quel piano, con un po' d'aria
	var tutto := Rect2()
	var primo := true
	for id_stanza in scatole:
		var s: Dictionary = scatole[id_stanza]
		if int(s["piano"]) != piano or not zona.si_vede(id_stanza):
			continue
		var r := Rect2(Vector2(s["centro"].x, s["centro"].z) - Vector2(s["misura"].x, s["misura"].z) * 0.5,
				Vector2(s["misura"].x, s["misura"].z))
		tutto = r if primo else tutto.merge(r)
		primo = false
	return tutto.grow(0.6)


func lastra(piano: int) -> void:
	# il pavimento di un piano: solo un contorno sottile, per leggere a che
	# altezza sta una stanza anche quando e' sola
	var r := impronta_del_piano(piano)
	var quota := float(piano) * ALTEZZA_PIANO - 0.02
	volume(Vector3(r.get_center().x, quota, r.get_center().y), Vector3(r.size.x, 0.02, r.size.y), Basis(),
			{"tinta": tinte["linea"], "pieno": 0.035, "linea": 0.4, "pulsa": 0.0})


func evidenzia(id_stanza: String) -> void:
	puntata = id_stanza
	for id_acceso in accese:
		(accese[id_acceso] as ShaderMaterial).set_shader_parameter("acceso", 1.0 if id_acceso == id_stanza else 0.0)


# --- la camera ------------------------------------------------------------------

func misura_della_vista() -> Vector2i:
	# ai pixel veri della finestra, come la mappa stellare (Proiezione)
	var scala := get_viewport().get_final_transform().get_scale() if get_viewport() != null else Vector2.ONE
	if DisplayServer.window_get_size() == Vector2i.ZERO:
		scala = Vector2.ONE
	return Vector2i(maxi(64, roundi(size.x * scala.x)), maxi(64, roundi(size.y * scala.y)))


func inquadra() -> void:
	# tutta la zona dentro la cornice, di tre quarti e un po' dall'alto: la
	# distanza si trova provando, perche' quanto spazio prende un modellino
	# dipende da come lo si guarda
	vista.size = misura_della_vista()
	var tutto := ingombro()
	cam = {"bersaglio": tutto.get_center(), "distanza": maxf(tutto.size.length() * 2.0, 4.0),
			"giro": BASE["giro"], "beccheggio": BASE["beccheggio"], "fov": BASE["fov"]}
	for prova in 5:
		metti_camera(cam)
		var r := Rect2()
		for i in 8:
			var punto := sullo_schermo(tutto.get_endpoint(i))
			r = Rect2(punto, Vector2.ZERO) if i == 0 else r.expand(punto)
		# sopra ci vanno le icone, sotto i nomi: anche loro devono starci
		r = r.grow_individual(0.0, 40.0, 0.0, 20.0)
		var quanto := maxf(r.size.x / maxf(size.x - MARGINE_PIANI, 1.0), r.size.y / maxf(size.y, 1.0))
		# e centrata nello spazio libero, a destra dei nomi dei piani
		var per_pixel := 2.0 * float(cam["distanza"]) * tan(deg_to_rad(float(cam["fov"])) * 0.5) / maxf(size.y, 1.0)
		var scarto := r.get_center() - Vector2((size.x + MARGINE_PIANI) * 0.5, size.y * 0.5)
		cam["bersaglio"] = (cam["bersaglio"] as Vector3) + (camera.global_transform.basis.x * scarto.x
				- camera.global_transform.basis.y * scarto.y) * per_pixel
		cam["distanza"] = float(cam["distanza"]) * clampf(quanto / 0.92, 0.3, 3.0)
	metti_camera(mano.applica(cam))


func metti_camera(guardo: Dictionary) -> void:
	var giro := float(guardo["giro"])
	# mai di taglio: sotto i 12 gradi i piani diventano righe
	var becc := deg_to_rad(clampf(float(guardo["beccheggio"]), 12.0, 75.0))
	var bersaglio: Vector3 = guardo["bersaglio"]
	camera.fov = float(guardo["fov"])
	camera.position = bersaglio + Vector3(sin(giro) * cos(becc), sin(becc), cos(giro) * cos(becc)) \
			* float(guardo["distanza"])
	camera.look_at(bersaglio, Vector3.UP)


func _process(delta: float) -> void:
	if cam.is_empty():
		return
	mano.aggiorna(delta)
	metti_camera(mano.applica(cam))
	if not camera.transform.is_equal_approx(ultima):
		ultima = camera.transform
		zona.riposiziona()
		scritte.queue_redraw()   # i nomi dei piani e i segnalini seguono la vista


func sullo_schermo(punto: Vector3) -> Vector2:
	if camera.is_position_behind(punto):
		return Vector2(-9999, -9999)
	return camera.unproject_position(punto) * size / Vector2(vista.size)


func sagoma(id_stanza: String) -> PackedVector2Array:
	# la stanza come la si vede: l'involucro degli otto spigoli a schermo
	var s: Dictionary = scatole[id_stanza]
	var scatola := AABB(s["centro"] - s["misura"] * 0.5, s["misura"])
	var punti := PackedVector2Array()
	for i in 8:
		punti.append(sullo_schermo(scatola.get_endpoint(i)))
	return Geometry2D.convex_hull(punti)


func rettangolo(id_stanza: String) -> Rect2:
	var punti := sagoma(id_stanza)
	var r := Rect2(punti[0], Vector2.ZERO)
	for punto in punti:
		r = r.expand(punto)
	return r


func cima(id_stanza: String) -> Vector2:
	# il centro del tetto della stanza: li' sopra stanno le icone e i segnalini
	var s: Dictionary = scatole[id_stanza]
	return sullo_schermo(s["centro"] + Vector3.UP * float(s["misura"].y) * 0.5)


func distanza(id_stanza: String) -> float:
	return camera.global_position.distance_to(scatole[id_stanza]["centro"])


func metti_porta(porta: PortaStanza, id_stanza: String) -> void:
	# la porta prende il posto e la forma della stanza a schermo, e non disegna
	# niente di suo: la stanza la disegna il plastico
	var r := rettangolo(id_stanza)
	porta.position = r.position
	porta.size = r.size
	var dentro := PackedVector2Array()
	for punto in sagoma(id_stanza):
		dentro.append(punto - r.position)
	porta.sagoma = dentro


func svuota(porte: Control) -> void:
	# le porte non hanno faccia: la stanza la disegna il plastico, e si accende
	# quando la si punta (col mouse o col fuoco della tastiera)
	var niente := StyleBoxEmpty.new()
	for porta in porte.get_children():
		for stato in ["normal", "hover", "pressed", "focus", "disabled"]:
			(porta as Control).add_theme_stylebox_override(stato, niente)
		# il nome su una riga sola, sotto la stanza: a capo dentro una stanza
		# vista di sbieco diventava «Infermer / ia»
		var nome := porta.get_node_or_null("Nome") as Label
		if nome != null:
			nome.autowrap_mode = TextServer.AUTOWRAP_OFF
			nome.grow_horizontal = Control.GROW_DIRECTION_BOTH
			Stile.imposta_corpo(nome, 13)
			Stile.contorno(nome, 13)


func ordina(porte: Control) -> void:
	# la piu' vicina sopra: dove due stanze si coprono, il clic va a quella davanti
	var elenco := porte.get_children()
	elenco.sort_custom(func(a: Node, b: Node) -> bool:
		return distanza(String(a.get_meta("stanza", ""))) > distanza(String(b.get_meta("stanza", ""))))
	for i in elenco.size():
		porte.move_child(elenco[i], i)


# --- le scritte: i nomi dei piani e chi c'e' ----------------------------------

func _disegna_scritte() -> void:
	var font := get_theme_default_font()
	var nomi: Dictionary = GameState.mappa_zona.get("piani", {})
	for piano in piani_visti():
		var nome := String(nomi.get(str(piano), "")).to_upper()
		if nome == "":
			continue
		# a sinistra del piano, all'altezza del suo pavimento
		var r := impronta_del_piano(int(piano))
		var quota := float(piano) * ALTEZZA_PIANO
		var dove := Vector2(INF, 0.0)
		for angolo in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
			var punto := sullo_schermo(Vector3(angolo.x, quota, angolo.y))
			dove = punto if punto.x < dove.x else dove
		# in colonna sul bordo sinistro, all'altezza del pavimento: una scala
		# di piani da leggere dall'alto in basso, che non copre le stanze
		var riga := Vector2(14.0, dove.y + 4.0)
		scritte.draw_line(Vector2(14.0, dove.y + 9.0), dove, Color(tinte["linea"], 0.25), 1.0)
		scritte.draw_string_outline(font, riga, nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, 4, Color(0, 0, 0, 0.85))
		scritte.draw_string(font, riga, nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(tinte["linea"], 0.95))
	for id_stanza in scatole:
		var chi := zona.chi_c_e(id_stanza)
		for i in chi.size():
			var dove := cima(id_stanza) + Vector2(-8.0 * float(chi.size() - 1) + 16.0 * float(i), -26)
			scritte.draw_circle(dove, 6.5, Color(0, 0, 0, 0.85))
			scritte.draw_circle(dove, 4.5, tinte["qui"])


# --- la mano --------------------------------------------------------------------

func _gui_input(evento: InputEvent) -> void:
	# si trascina sul vuoto del plastico: sulle stanze ci sono le porte
	if evento is InputEventMouseButton and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var b := evento as InputEventMouseButton
		if b.double_click:
			mano.centra()
		premuto = b.pressed
		trascinando = false
		da = b.position
		accept_event()
	elif evento is InputEventMouseMotion and premuto:
		var m := evento as InputEventMouseMotion
		trascinando = trascinando or m.position.distance_to(da) >= SOGLIA
		if trascinando:
			mano.gira(-m.relative.x * 0.006, m.relative.y * 0.18)
		accept_event()


func _input(evento: InputEvent) -> void:
	# la rotella avvicina anche sopra una stanza: lì c'e' una porta, che la
	# terrebbe per se'
	if not evento is InputEventMouseButton or not is_visible_in_tree():
		return
	var b := evento as InputEventMouseButton
	if not b.pressed or b.button_index not in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		return
	if not get_global_rect().has_point(b.position):
		return
	mano.avvicina(ManoProiezione.PASSO_ROTELLA if b.button_index == MOUSE_BUTTON_WHEEL_UP
			else 1.0 / ManoProiezione.PASSO_ROTELLA, null)
	get_viewport().set_input_as_handled()


func _unhandled_input(evento: InputEvent) -> void:
	if is_visible_in_tree() and evento.is_action_pressed("mappa_centra"):
		mano.centra()
		get_viewport().set_input_as_handled()
