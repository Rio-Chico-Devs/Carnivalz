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
# diventano pozzi.
#
# SI TIENE IN MANO. Bru, la prima volta che l'ha visto: «molto carino ma va
# migliorato, anche in termini di interazione e manipolazione». Si gira tutto
# intorno, si inclina fin quasi a pianta, si avvicina verso il cursore e si
# sposta, anche trascinando da sopra una stanza: tasti, gesti e limiti stanno
# in ManoPlastico.
#
# UN PIANO ALLA VOLTA, se si vuole: cliccando il nome di un piano (a sinistra)
# restano accese solo le sue stanze, quelle degli altri piani si spengono e non
# si cliccano piu', e la vista ci va sopra. E' quello che fa leggere un piano
# che sta sotto un altro: guardando dall'alto, il piano di sopra lo copriva.
#
# QUI SI DISEGNA SOLTANTO. Cosa si sa di una stanza, dove si puo' andare e cosa
# succede cliccandola lo decide MappaZona, come sulla mappa a quadratini: le
# stanze si premono con PortaStanza, che e' un bottone vero ritagliato sulla
# sagoma che la stanza ha a schermo. Le icone (il punto esclamativo, la freccia
# del «sei qui») restano quelle di SegniMappa, sopra la stanza. I nomi dei
# piani, chi c'e' e la scheda della stanza puntata stanno in ScrittePlastico.
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
const BASE := {"giro": -0.38, "beccheggio": 22.0, "fov": 30.0}
const NESSUNO := -9999           # nessun piano scelto: si vedono tutti
const VELO_SOTTO := 0.14         # scelto un piano, quelli sotto restano un'ombra
const VELO_SOPRA := 0.03         # e quelli sopra quasi spariscono: lo coprirebbero
const PER_UN_PIANO := 40.0       # gradi d'altezza, almeno, guardando un piano solo

var zona: MappaZona
var vista: SubViewport
var camera: Camera3D
var radice: Node3D
var scritte: ScrittePlastico     # i piani, chi c'e', la scheda: sopra le porte (monta_sopra)
var mano: ManoPlastico               # la vista in mano: mouse, tasti, limiti
var cam := {}                    # l'inquadratura di partenza: tutta la zona, di tre quarti
var ora := {}                    # quella di adesso: la partenza piu' la mano
var scatole := {}                # id stanza -> {"centro": Vector3, "misura": Vector3, "piano": int}
var accese := {}                 # id stanza -> il suo materiale, per accenderla quando la si punta
var tinte := {}
var puntata := ""
var solo := NESSUNO              # il piano scelto, se ce n'e' uno
var veli := {}                   # piano -> quanto si vede adesso (scivola verso velo_di)
var velati: Array = []           # [materiale, piani]: cosa si spegne con quali piani
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
	scritte = ScrittePlastico.new(self)
	add_child(scritte)
	mano = ManoPlastico.new(self)
	add_child(mano)
	misura_le_stanze()


func monta_sopra(cornice: Control) -> void:
	# le scritte vanno sopra le porte delle stanze: i bottoni dei piani si
	# devono cliccare anche quando una stanza ci passa sotto
	scritte.reparent(cornice, false)
	scritte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


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
	velati.clear()
	for id_stanza in scatole:
		if zona.si_vede(id_stanza):
			var s: Dictionary = scatole[id_stanza]
			accese[id_stanza] = volume(s["centro"], s["misura"], Basis(), stato_di(id_stanza), [s["piano"]])
	for coppia in GameState.collegamenti_aperti():
		if coppia.size() >= 2 and zona.si_vede(String(coppia[0])) and zona.si_vede(String(coppia[1])):
			corridoio(String(coppia[0]), String(coppia[1]))
	for piano in piani_visti():
		lastra(int(piano))
	applica_veli()
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


func volume(centro: Vector3, misura: Vector3, base: Basis, stato: Dictionary, piani: Array) -> ShaderMaterial:
	# un parallelepipedo di luce: le facce appena velate e gli spigoli accesi.
	# 'piani' sono i piani con cui si spegne quando se ne sceglie un altro
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
	velati.append([materiale, piani])
	velati.append([spigoli.material_override, piani])
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
	var piani := [sa["piano"], sb["piano"]]
	var da_qui := Vector3(porta_a.x, quota_a, porta_a.y)
	var a_li := Vector3(porta_b.x, quota_a, porta_b.y)
	if da_qui.distance_to(a_li) > 0.05:
		tubo(da_qui, a_li, TUBO, stato, piani)
	if absf(quota_a - quota_b) > 0.05:
		tubo(a_li, Vector3(porta_b.x, quota_b, porta_b.y), POZZO, stato, piani)


func tubo(da_dove: Vector3, a_dove: Vector3, spessore: float, stato: Dictionary, piani: Array) -> void:
	var lungo := da_dove.distance_to(a_dove)
	var asse := (a_dove - da_dove) / lungo
	var su := Vector3.UP if absf(asse.y) < 0.9 else Vector3.FORWARD
	var lato := asse.cross(su).normalized()
	var base := Basis(asse, lato.cross(asse), lato)
	volume((da_dove + a_dove) * 0.5, Vector3(lungo, spessore, spessore), base, stato, piani)


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
			{"tinta": tinte["linea"], "pieno": 0.035, "linea": 0.4, "pulsa": 0.0}, [piano])


func evidenzia(id_stanza: String) -> void:
	puntata = id_stanza
	for id_acceso in accese:
		(accese[id_acceso] as ShaderMaterial).set_shader_parameter("acceso", 1.0 if id_acceso == id_stanza else 0.0)
	porta_in_vista(id_stanza)
	if zona.strato_bottoni != null:
		scritte.dirada(zona.strato_bottoni)
	scritte.queue_redraw()


func porta_in_vista(id_stanza: String) -> void:
	# chi passa da una stanza all'altra con la tastiera o col pad non deve
	# finire su una stanza fuori dalla cornice: la vista ci va
	var porta := porta_di(id_stanza)
	if porta == null or not porta.has_focus() or porta.is_hovered():
		return
	if Rect2(Vector2.ZERO, size).grow(-60.0).has_point(cima(id_stanza)):
		return
	mano.guarda(scatole[id_stanza]["centro"], float(mano.voluto["zoom"]), 0.0)


func porta_di(id_stanza: String) -> PortaStanza:
	if id_stanza == "" or zona.strato_bottoni == null:
		return null
	for porta in zona.strato_bottoni.get_children():
		if String(porta.get_meta("stanza", "")) == id_stanza:
			return porta as PortaStanza
	return null


# --- un piano solo --------------------------------------------------------------

func isola(piano: int) -> void:
	# lo stesso piano un'altra volta (o uno che non c'e'): tornano tutti
	solo = NESSUNO if piano == solo or piano not in piani_visti() else piano
	if solo == NESSUNO:
		mano.guarda(cam.get("bersaglio", Vector3.ZERO), 1.0, 0.0)
	else:
		# la vista va su quel piano, che riempie la cornice, e un po' dall'alto:
		# un piano e' una pianta. Il giro resta quello che avevi
		var r := impronta_del_piano(solo)
		var quota := float(solo) * ALTEZZA_PIANO
		var angoli: Array[Vector3] = []
		for angolo: Vector2 in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
			angoli.append(Vector3(angolo.x, quota, angolo.y))
			angoli.append(Vector3(angolo.x, quota + ALTEZZA_STANZA, angolo.y))
		var dall_alto := clampf(float(cam["beccheggio"]) + float(mano.voluto["becc"]), PER_UN_PIANO,
				float(ManoPlastico.limiti()["alto"]))
		var g := adatta(angoli, {"bersaglio": Vector3(r.get_center().x, quota, r.get_center().y),
				"distanza": float(cam["distanza"]), "giro": float(cam["giro"]) + float(mano.voluto["giro"]),
				"beccheggio": dall_alto, "fov": cam["fov"]})
		metti_camera(mano.applica(cam))   # adatta l'ha mossa per provare
		mano.guarda(g["bersaglio"], float(g["distanza"]) / float(cam["distanza"]), PER_UN_PIANO)
	if puntata != "" and velata(puntata):
		zona._smetti_di_indicare()
	scritte.vesti_piani()
	zona.riposiziona()
	scritte.queue_redraw()


func cambia_piano(passo: int) -> void:
	# Z e X: la prima volta il piano in cui sei, poi uno su o uno giu'; oltre
	# l'ultimo tornano tutti
	var piani := piani_visti()
	if piani.is_empty():
		return
	if solo == NESSUNO:
		var qui := int(scatole.get(GameState.nodo_corrente, {}).get("piano", piani[0]))
		isola(qui if qui in piani else int(piani[0]))
		return
	var dopo := piani.find(solo) + passo
	isola(int(piani[dopo]) if dopo >= 0 and dopo < piani.size() else solo)


func ricentra() -> void:
	solo = NESSUNO
	mano.centra()
	scritte.vesti_piani()
	zona.riposiziona()
	scritte.queue_redraw()


func velata(id_stanza: String) -> bool:
	# la stanza sta su un piano che adesso e' spento
	return solo != NESSUNO and scatole.has(id_stanza) and int(scatole[id_stanza]["piano"]) != solo


func velo_di(piano: int) -> float:
	if solo == NESSUNO or piano == solo:
		return 1.0
	return VELO_SOPRA if piano > solo else VELO_SOTTO


func scivola_veli(delta: float) -> void:
	# i piani si spengono e si riaccendono in un attimo, non di colpo
	var k := 1.0 if Movimento.ridotto() else 1.0 - exp(-delta * 10.0)
	var cambiati := false
	for piano: int in piani_visti():
		var adesso := float(veli.get(piano, 1.0))
		var voluto := velo_di(piano)
		if adesso != voluto:
			veli[piano] = voluto if absf(adesso - voluto) < 0.003 else lerpf(adesso, voluto, k)
			cambiati = true
	if cambiati:
		applica_veli()


func applica_veli() -> void:
	for coppia: Array in velati:
		var quanto := 0.0
		for piano: int in coppia[1]:
			quanto = maxf(quanto, float(veli.get(piano, 1.0)))
		(coppia[0] as ShaderMaterial).set_shader_parameter("velo", quanto)


# --- la camera ------------------------------------------------------------------

func misura_della_vista() -> Vector2i:
	# ai pixel veri della finestra, come la mappa stellare (Proiezione)
	var scala := get_viewport().get_final_transform().get_scale() if get_viewport() != null else Vector2.ONE
	if DisplayServer.window_get_size() == Vector2i.ZERO:
		scala = Vector2.ONE
	return Vector2i(maxi(64, roundi(size.x * scala.x)), maxi(64, roundi(size.y * scala.y)))


func inquadra() -> void:
	# tutta la zona dentro la cornice, di tre quarti e un po' dall'alto
	vista.size = misura_della_vista()
	scritte.prepara_piani()
	var tutto := ingombro()
	var angoli: Array[Vector3] = []
	for i in 8:
		angoli.append(tutto.get_endpoint(i))
	cam = adatta(angoli, {"bersaglio": tutto.get_center(), "distanza": maxf(tutto.size.length() * 2.0, 4.0),
			"giro": BASE["giro"], "beccheggio": BASE["beccheggio"], "fov": BASE["fov"]})
	mano.base = cam
	mano.confini = tutto.grow(3.0)
	metti_camera(mano.applica(cam))


func adatta(punti: Array[Vector3], guardo: Dictionary) -> Dictionary:
	# la vista che mette quei punti dentro la cornice, a destra dei bottoni dei
	# piani: la distanza si trova provando, perche' quanto spazio prende un
	# modellino dipende da come lo si guarda. Muove la camera per provare: chi
	# chiama la rimette dove serve
	var margine := scritte.larghezza_piani() + 40.0
	var g := guardo.duplicate()
	for prova in 5:
		metti_camera(g)
		var r := Rect2(sullo_schermo(punti[0]), Vector2.ZERO)
		for punto in punti:
			r = r.expand(sullo_schermo(punto))
		# sopra ci vanno le icone, sotto i nomi e la riga dei comandi
		r = r.grow_individual(0.0, 40.0, 0.0, 34.0)
		var quanto := maxf(r.size.x / maxf(size.x - margine, 1.0), r.size.y / maxf(size.y, 1.0))
		# e centrata nello spazio libero
		var pixel := 2.0 * float(g["distanza"]) * tan(deg_to_rad(float(g["fov"])) * 0.5) / maxf(size.y, 1.0)
		var scarto := r.get_center() - Vector2((size.x + margine) * 0.5, size.y * 0.5)
		g["bersaglio"] = (g["bersaglio"] as Vector3) + (camera.global_transform.basis.x * scarto.x
				- camera.global_transform.basis.y * scarto.y) * pixel
		g["distanza"] = float(g["distanza"]) * clampf(quanto / 0.92, 0.3, 3.0)
	return g


func metti_camera(guardo: Dictionary) -> void:
	ora = guardo
	var giro := float(guardo["giro"])
	# mai di taglio e mai a piombo: i limiti veri sono quelli di ManoPlastico
	var becc := deg_to_rad(clampf(float(guardo["beccheggio"]), 5.0, 88.0))
	var bersaglio: Vector3 = guardo["bersaglio"]
	camera.fov = float(guardo["fov"])
	camera.position = bersaglio + Vector3(sin(giro) * cos(becc), sin(becc), cos(giro) * cos(becc)) \
			* float(guardo["distanza"])
	camera.look_at(bersaglio, Vector3.UP)


func per_pixel() -> float:
	# quanto e' lungo un pixel della cornice, alla distanza del centro della vista
	return 2.0 * float(ora.get("distanza", 1.0)) * tan(deg_to_rad(camera.fov) * 0.5) / maxf(size.y, 1.0)


func verso_il_cursore(dove: Vector2) -> Variant:
	# dal centro della vista al punto sotto il cursore, all'altezza del centro:
	# e' quello che deve restare fermo avvicinandosi
	var pixel := dove * Vector2(vista.size) / size
	var origine := camera.project_ray_origin(pixel)
	var raggio := camera.project_ray_normal(pixel)
	var quota := float((ora.get("bersaglio", Vector3.ZERO) as Vector3).y)
	if absf(raggio.y) < 0.01 or (quota - origine.y) / raggio.y <= 0.0:
		return null
	var punto := origine + raggio * ((quota - origine.y) / raggio.y)
	return punto - ((cam["bersaglio"] as Vector3) + (mano.voluto["spinta"] as Vector3))


func _process(delta: float) -> void:
	if cam.is_empty():
		return
	mano.aggiorna(delta)
	metti_camera(mano.applica(cam))
	scivola_veli(delta)
	if not camera.transform.is_equal_approx(ultima):
		ultima = camera.transform
		zona.riposiziona()
		scritte.queue_redraw()   # i fili dei piani, i segnalini e la scheda seguono la vista


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


func segni_di(id_stanza: String) -> Rect2:
	# dove MappaZona disegna le icone di una stanza: sopra il tetto, sempre
	# della stessa misura, perche' la stanza a schermo cambia forma girandola
	return Rect2(cima(id_stanza) - Vector2(24.0, 44.0), Vector2(48.0, 48.0))


func distanza(id_stanza: String) -> float:
	return camera.global_position.distance_to(scatole[id_stanza]["centro"])


# --- le porte e i loro nomi -------------------------------------------------------

func metti_porta(porta: PortaStanza, id_stanza: String) -> void:
	# la porta prende il posto e la forma della stanza a schermo, e non disegna
	# niente di suo: la stanza la disegna il plastico. Su un piano spento la
	# porta non c'e': la sua stanza non si clicca e non copre quelle accese
	var r := rettangolo(id_stanza)
	porta.position = r.position
	porta.size = r.size
	var dentro := PackedVector2Array()
	for punto in sagoma(id_stanza):
		dentro.append(punto - r.position)
	porta.sagoma = dentro
	porta.visible = not velata(id_stanza)


func svuota(porte: Control) -> void:
	# le porte non hanno faccia: la stanza la disegna il plastico, e si accende
	# quando la si punta (col mouse o col fuoco della tastiera)
	var niente := StyleBoxEmpty.new()
	for porta in porte.get_children():
		for stato in ["normal", "hover", "pressed", "focus", "disabled"]:
			(porta as Control).add_theme_stylebox_override(stato, niente)
		# il suggerimento di Godot no: copriva la stanza, e lo dice gia' la scheda
		(porta as Control).tooltip_text = ""
		# la manina solo dove il clic porta da qualche parte
		var id_stanza := String(porta.get_meta("stanza", ""))
		(porta as Control).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND \
				if zona.si_puo_andare(id_stanza) and not zona.chiusa(id_stanza) else Control.CURSOR_ARROW
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
	scritte.dirada(porte)
