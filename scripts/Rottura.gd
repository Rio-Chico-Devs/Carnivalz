class_name Rottura
extends Control

# LA SCELTA A TEMPO CHE VA IN PEZZI, col suo orologio.
#
# Bru, all'inizio: «quando scade il tempo le opzioni hero o evil si frantumano
# come se fosse vetro e scompaiono, i pezzi devono cadere e gradualmente
# svanire verso il trasparente». E poi, sulle bozze: «anche il frantumarsi va
# fatto meglio». Quello di prima (Frantumi.gd, che resta per la Mattanza)
# rompeva un rettangolo di schermo sfondo compreso: meta' delle schegge erano
# pezzi di buio, orologio e scelta una lastra sola tagliata a caso, e la catena
# spariva di colpo. Qui:
#   - L'OROLOGIO SI SPACCA LUNGO LE SUE CREPE, e solo lungo quelle: al disco si
#     tolgono le crepe ingrossate di un capello, e i pezzi sono quelli che le
#     crepe hanno davvero separato. Vicino all'impatto il vetro va in briciole
#   - LA SCELTA SI SPACCA DOPO, dal lato dell'orologio: la crepa la attraversa
#     da sinistra a destra (un filo bianco) e i pezzi si staccano uno dopo
#     l'altro, piu' pesanti del vetro. Solo il suo parallelogramma con l'ombra
#   - i pezzi girano su se stessi (di profilo si vede il taglio), e uno su tre
#     prende la luce una volta, di sfuggita
#   - la catena si spezza e le maglie cadono; un pizzico di polvere di vetro
#
# Il disegno dei pezzi e' una fotografia dello schermo un istante prima; dove
# non c'e' rendering (le prove) restano tinte piatte, e si muovono lo stesso.

signal finito

const FRANTUMI := preload("res://scripts/Frantumi.gd")
const DURATA := 1.4
const GRAVITA := 1500.0
const PIENO := 0.45          # fino a questa quota del tempo i pezzi sono pieni
const CORSA_CREPA := 1400.0  # pixel al secondo: la crepa che attraversa la scelta

var pezzi: Array[Dictionary] = []
var catena: Array[Dictionary] = []
var polvere: Array[Dictionary] = []
var foto: Texture2D = null
var regione := Rect2i()
var scala := Vector2.ONE
var trascorso := 0.0
var dado := RandomNumberGenerator.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)


func rompi(orologio: Control, bottone: Control) -> void:
	# prende il posto dell'orologio e della scelta: chi chiama, dopo, toglie loro
	var forma: Dictionary = orologio.call("forma_della_rottura")
	dado.seed = orologio.get_instance_id()
	var etichetta := parallelogramma_di(bottone)
	var tutto := Rect2(forma["centro"], Vector2.ZERO).grow(float(forma["raggio"]) + 2.0)
	for punto in etichetta + PackedVector2Array(forma["testa"]):
		tutto = tutto.expand(punto)
	await fotografa(tutto.grow(4.0))
	spacca_orologio(forma)
	spacca_etichetta(etichetta)
	spezza_catena(forma["maglie"])
	soffia_polvere(forma["impatto"])
	AudioManager.interfaccia("vetro")
	trascorso = 0.0
	set_process(true)
	queue_redraw()


func fotografa(dove: Rect2) -> void:
	# senza finestra non si aspetta niente: frame_post_draw non arriverebbe mai
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var vista := get_viewport()
	if vista == null or vista.get_texture() == null:
		return
	var schermo := vista.get_texture().get_image()
	if schermo == null or schermo.is_empty():
		return
	scala = Vector2(schermo.get_size()) / vista.get_visible_rect().size
	regione = FRANTUMI.sullo_schermo(dove, schermo.get_size(), vista.get_visible_rect().size)
	if regione.size.x > 0 and regione.size.y > 0:
		foto = ImageTexture.create_from_image(schermo.get_region(regione))


func uv_di(punto: Vector2) -> Vector2:
	if regione.size.x <= 0 or regione.size.y <= 0:
		return Vector2.ZERO
	return (punto * scala - Vector2(regione.position)) / Vector2(regione.size)


static func parallelogramma_di(bottone: Control) -> PackedVector2Array:
	# la scelta com'e' disegnata: lo skew dello StyleBox sposta il lato di
	# sopra a destra e quello di sotto a sinistra di mezza pendenza ciascuno, e
	# dietro c'e' l'ombra piena; la forma e' l'unione delle due
	var r := bottone.get_global_rect()
	var mezzo := Manifesto.INCLINA * r.size.y * 0.5
	var fascia := PackedVector2Array([r.position + Vector2(mezzo, 0), Vector2(r.end.x + mezzo, r.position.y),
			r.end - Vector2(mezzo, 0), Vector2(r.position.x - mezzo, r.end.y)])
	var unite := Geometry2D.merge_polygons(fascia, Lastra.sposta(fascia, Lastra.OMBRA_SCELTA))
	return unite[0] if unite.size() > 0 else fascia


static func cerchio(centro: Vector2, raggio: float, lati := 40) -> PackedVector2Array:
	var punti := PackedVector2Array()
	for i in lati:
		punti.append(centro + Vector2.RIGHT.rotated(TAU * float(i) / float(lati)) * raggio)
	return punti


static func senza(parti: Array, taglio: PackedVector2Array) -> Array:
	# le parti, col taglio tolto; i buchi (in senso orario) non sono pezzi
	var restano: Array = []
	for parte in parti:
		for resto in Geometry2D.clip_polygons(parte, taglio):
			if not Geometry2D.is_polygon_clockwise(resto):
				restano.append(resto)
	return restano


static func dentro_e_fuori(pezzo: PackedVector2Array, taglio: PackedVector2Array) -> Array:
	# un pezzo diviso da un taglio: quel che sta dentro e quel che sta fuori
	var parti: Array = Geometry2D.intersect_polygons(pezzo, taglio)
	parti.append_array(senza([pezzo], taglio))
	return parti


func spacca_orologio(forma: Dictionary) -> void:
	var impatto: Vector2 = forma["impatto"]
	var raggio: float = forma["raggio"]
	var parti: Array = [cerchio(forma["centro"], raggio, 56)]
	# vicino all'impatto il vetro va in briciole: un giro di tagli storto
	# attorno al punto, che si vede solo quando si rompe
	var briciole := PackedVector2Array()
	for i in 10:
		briciole.append(impatto + Vector2.RIGHT.rotated(TAU * float(i) / 10.0 + dado.randf_range(-0.2, 0.2))
				* raggio * dado.randf_range(0.16, 0.27))
	briciole.append(briciole[0])
	var tagli: Array = (forma["crepe"] as Array).duplicate()
	tagli.append(briciole)
	for crepa in tagli:
		for taglio in Geometry2D.offset_polyline(crepa, 0.45, Geometry2D.JOIN_MITER, Geometry2D.END_SQUARE):
			parti = senza(parti, taglio)
	for parte in parti:
		aggiungi(parte, impatto, "vetro")
	aggiungi(forma["testa"], impatto, "vetro")


func spacca_etichetta(etichetta: PackedVector2Array) -> void:
	# la crepa entra dal lato dell'orologio, a meta' altezza, e si apre a
	# ventaglio; un taglio quasi dritto a meta' strada spezza i pezzi lunghi
	var riquadro := Rect2(etichetta[0], Vector2.ZERO)
	for punto in etichetta:
		riquadro = riquadro.expand(punto)
	var entrata := Vector2(riquadro.position.x - 6.0, riquadro.get_center().y + dado.randf_range(-6.0, 6.0))
	var angoli: Array[float] = [PI * 0.5, -PI * 0.5]
	for k in 6:
		angoli.append(lerpf(-0.55, 0.55, float(k) / 5.0) + dado.randf_range(-0.08, 0.08))
	var x_taglio := riquadro.position.x + riquadro.size.x * dado.randf_range(0.45, 0.6)
	var taglio := PackedVector2Array([riquadro.position - Vector2(50, 50),
			Vector2(x_taglio + 6.0, riquadro.position.y - 50.0), Vector2(x_taglio - 6.0, riquadro.end.y + 50.0),
			Vector2(riquadro.position.x - 50.0, riquadro.end.y + 50.0)])
	for settore in spicchi(entrata, angoli, riquadro.size.x * 3.0):
		for pezzo in Geometry2D.intersect_polygons(settore, etichetta):
			for parte in dentro_e_fuori(pezzo, taglio):
				aggiungi(parte, entrata, "scelta")


static func spicchi(da: Vector2, angoli: Array[float], lungo: float) -> Array[PackedVector2Array]:
	# i settori fra un angolo e il successivo, a partire da un punto
	angoli.sort()
	var lista: Array[PackedVector2Array] = []
	for i in angoli.size():
		var a0 := angoli[i]
		var a1 := angoli[(i + 1) % angoli.size()] + (TAU if i == angoli.size() - 1 else 0.0)
		var settore := PackedVector2Array([da])
		for k in 5:
			settore.append(da + Vector2.RIGHT.rotated(lerpf(a0, a1, float(k) / 4.0)) * lungo)
		lista.append(settore)
	return lista


func aggiungi(punti: PackedVector2Array, impatto: Vector2, razza: String) -> void:
	if punti.size() < 3:
		return
	var centro := Vector2.ZERO
	for p in punti:
		centro += p
	centro /= float(punti.size())
	var relativi := PackedVector2Array()
	var uv := PackedVector2Array()
	for p in punti:
		relativi.append(p - centro)
		uv.append(uv_di(p))
	var verso := (centro - impatto).normalized() if centro.distance_to(impatto) > 0.5 else Vector2.UP
	# la luce la prende uno su tre, una volta sola: se la prendono tutti
	# insieme il vetro diventa una nuvola grigia
	var pezzo := {"punti": relativi, "uv": uv, "pos": centro, "rot": 0.0, "razza": razza, "flip": 0.0,
			"luce": dado.randf_range(1.2, 3.0) if dado.randf() < 0.35 else -1.0}
	if razza == "vetro":
		# il vetro schizza dal punto d'impatto: i pezzi piccoli forte, i grandi
		# si staccano appena e cadono
		var leggero := clampf(1.0 - area(punti) / 900.0, 0.2, 1.0)
		pezzo["vel"] = (verso * dado.randf_range(70.0, 200.0) + Vector2(0.0, dado.randf_range(-110.0, -30.0))) * leggero
		pezzo["giro"] = dado.randf_range(-6.0, 6.0)
		pezzo["vflip"] = dado.randf_range(4.0, 9.0)
		pezzo["ritardo"] = 0.0
	else:
		# la scelta cede: pezzi pesanti che si staccano mentre la crepa la
		# attraversa, e cadono con poca spinta
		pezzo["vel"] = verso * dado.randf_range(20.0, 70.0) + Vector2(0.0, dado.randf_range(0.0, 60.0))
		pezzo["giro"] = dado.randf_range(-2.5, 2.5)
		pezzo["vflip"] = dado.randf_range(1.0, 3.0)
		pezzo["ritardo"] = maxf(0.0, centro.x - impatto.x) / CORSA_CREPA
	pezzi.append(pezzo)


static func area(punti: PackedVector2Array) -> float:
	var doppia := 0.0
	for k in punti.size():
		doppia += punti[k].cross(punti[(k + 1) % punti.size()])
	return absf(doppia) * 0.5


func spezza_catena(maglie: Array) -> void:
	for k in maglie.size():
		var maglia: Array = maglie[k]
		catena.append({"pos": Vector2(maglia[0]), "verso": Vector2(maglia[1]), "piatta": k % 2 == 0,
				"vel": Vector2(dado.randf_range(-50.0, 50.0), dado.randf_range(-120.0, -10.0)),
				"giro": dado.randf_range(-12.0, 12.0), "rot": 0.0})


func soffia_polvere(impatto: Vector2) -> void:
	for i in 12:
		polvere.append({"pos": impatto, "vel": Vector2.RIGHT.rotated(dado.randf() * TAU) * dado.randf_range(90.0, 300.0),
				"vita": dado.randf_range(0.2, 0.4), "misura": dado.randf_range(0.6, 1.3)})


func _process(delta: float) -> void:
	trascorso += delta
	if trascorso >= DURATA:
		set_process(false)
		finito.emit()
		queue_free()
		return
	for pezzo in pezzi:
		if trascorso >= float(pezzo["ritardo"]):
			cade(pezzo, delta)
	for maglia in catena:
		cade(maglia, delta)
	for granello in polvere:
		granello["vel"] *= 0.9
		granello["pos"] += granello["vel"] * delta
	queue_redraw()


static func cade(cosa: Dictionary, delta: float) -> void:
	cosa["vel"] += Vector2(0.0, GRAVITA) * delta
	cosa["pos"] += cosa["vel"] * delta
	cosa["rot"] += float(cosa["giro"]) * delta
	if cosa.has("flip"):
		cosa["flip"] += float(cosa["vflip"]) * delta


func opacita() -> float:
	# pieni per il primo tratto, poi verso il trasparente: il momento della
	# rottura e' quello che conta, e una dissolvenza lineare se lo mangerebbe
	return clampf(1.0 - maxf(trascorso / DURATA - PIENO, 0.0) / (1.0 - PIENO), 0.0, 1.0)


func _draw() -> void:
	var alfa := opacita()
	if alfa <= 0.0:
		return
	var verso_locale := get_global_transform().affine_inverse()
	var crema := Cipolla.crema()
	for granello in polvere:
		var vita := 1.0 - trascorso / float(granello["vita"])
		if vita > 0.0:
			draw_circle(verso_locale * Vector2(granello["pos"]), float(granello["misura"]), Color(crema, vita),
					true, -1.0, true)
	for maglia in catena:
		draw_set_transform_matrix(verso_locale * Transform2D(float(maglia["rot"]), Vector2(maglia["pos"])))
		Cipolla.maglia(self, Vector2.ZERO, Vector2(maglia["verso"]), maglia["piatta"], Color(crema, alfa),
				Cipolla.FINE + 0.2)
	for pezzo in pezzi:
		disegna_pezzo(pezzo, verso_locale, alfa, crema)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func disegna_pezzo(pezzo: Dictionary, verso_locale: Transform2D, alfa: float, crema: Color) -> void:
	# GIRA SU SE STESSO: la larghezza segue il coseno del giro, e di profilo si
	# vede quasi solo il taglio. Ogni tanto la faccia prende la luce
	var flip := float(pezzo["flip"])
	var largo := cos(flip)
	if absf(largo) < 0.12:
		largo = 0.12 if largo >= 0.0 else -0.12
	draw_set_transform_matrix(verso_locale * Transform2D(float(pezzo["rot"]), Vector2(pezzo["pos"]))
			* Transform2D.IDENTITY.scaled(Vector2(largo, 1.0)))
	var punti: PackedVector2Array = pezzo["punti"]
	if foto != null:
		draw_colored_polygon(punti, Color(1, 1, 1, alfa), pezzo["uv"], foto)
	else:
		Manifesto.poligono(self, punti, Color(Stile.colore("pannello"), alfa))
	var in_attesa := trascorso < float(pezzo["ritardo"])
	var luce := float(pezzo["luce"])
	if luce > 0.0 and not in_attesa and flip < luce + PI:
		var lampo := pow(maxf(0.0, cos(flip - luce)), 30.0)
		if lampo > 0.02:
			Manifesto.poligono(self, punti, Color(1, 1, 1, lampo * 0.6 * alfa))
	var contorno := punti.duplicate()
	contorno.append(contorno[0])
	if pezzo["razza"] == "vetro":
		# il taglio ha lo stesso filo delle crepe da cui viene
		draw_polyline(contorno, Color(crema, 0.5 * alfa), 0.6, true)
	elif absf(trascorso - float(pezzo["ritardo"]) + 0.02) < 0.1:
		# la crepa che corre nella scelta: il filo bianco si accende sul pezzo
		# un attimo prima che si stacchi
		draw_polyline(contorno, Color(1, 1, 1, 0.9 * alfa), 1.2, true)
