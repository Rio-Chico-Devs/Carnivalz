class_name ArrediPlastico
extends RefCounted

# LA FORMA DI UNA STANZA, QUANDO NON E' QUELLA DEL SUO AMBIENTE. Bru: «non c'era
# bisogno di mettere alberi ed erbetta, troppi dettagli creano confusione,
# l'importante è avere una resa delle altezze e di come è conformato lo spazio,
# non degli elementi al suo interno». Quindi niente oggetti (alberi, massi,
# fuochi, mobili): il "dettaglio" di una stanza (data/*.json) dice solo com'e'
# fatto il suo spazio, e soprattutto quanto e' alto o profondo:
#   collina    la stanza sta in cima, e sotto la collina scende fino al piano
#              di sotto (il promontorio delle Pianure)
#   fossa      un buco: tutto scende verso il fondo
#   ponte      niente pavimento: un'asse sopra il vuoto
#   spiovente  il tetto a due falde sopra la stanza (l'attico)
#   serra      la volta a botte sopra la stanza
#   cumuli     il terreno fa dei monti (la grande discarica: «una montagna di lamiere»)
#   tondo      un edificio rotondo con la cupola (il Padiglione, «la struttura tonda»)
#   sala, piazza  una caverna scavata: il contorno piu' regolare (AmbientiPlastico)
# AmbientiPlastico ci mette sotto la forma del suo ambiente, tranne per quelli
# che sono la stanza stessa (SENZA_BASE). Ogni pezzo e' [pieno, linee, quanto si
# accende rispetto alla stanza].

const DETTAGLI := ["collina", "fossa", "ponte", "spiovente", "serra", "cumuli", "tondo", "sala", "piazza"]
const SENZA_BASE := ["ponte", "fossa", "tondo"]


static func dettaglio(nome: String, r: Rect2, quota: float, id_stanza: String, fra_i_piani: float, alto: float) -> Array:
	match nome:
		"collina":
			return [collina(r, quota, fra_i_piani, id_stanza)]
		"fossa":
			return [fossa(r, quota, id_stanza)]
		"ponte":
			return ponte(r, quota)
		"spiovente":
			return [spiovente(r, quota + alto)]
		"serra":
			return [serra(r, quota)]
		"cumuli":
			return cumuli(r, quota, id_stanza)
		"tondo":
			return tondo(r, quota, alto)
	return []


static func cumuli(r: Rect2, quota: float, seme: String) -> Array:
	# MONTI DI ROTTAMI: tre gobbe sul terreno, ognuna col suo piede storto
	var rng := FormePlastico.caso(seme + "cumuli")
	var forme: Array = []
	var lato := minf(r.size.x, r.size.y)
	for k in 3:
		var c := r.get_center() + Vector2((float(k) - 1.0) * r.size.x * 0.28, (rng.randf() - 0.5) * r.size.y * 0.3)
		var raggio := lato * (0.22 + rng.randf() * 0.1)
		var piede := FormePlastico.chiazza(Rect2(c - Vector2.ONE * raggio, Vector2.ONE * raggio * 2.0), seme + str(k), 0.25, 2.0, 12)
		var monte := FormePlastico.dosso(piede, quota + 0.18, quota + 0.18 + lato * (0.25 + rng.randf() * 0.2), 0.2, 3)
		forme.append([monte[0], monte[1], 0.9])
	return forme


static func tondo(r: Rect2, quota: float, alto: float) -> Array:
	# IL PADIGLIONE: un muro tondo e sopra la cupola
	var giro := FormePlastico.chiazza(r.grow(-0.05), "tondo", 0.0, 2.0, 24)
	var muro := quota + alto * 0.55
	var parete := FormePlastico.prisma(giro, quota, FormePlastico.piane(giro.size(), muro), 4)
	var cupola := FormePlastico.dosso(giro, muro, quota + alto, 0.15, 4)
	return [[parete[0], parete[1], 1.0], [cupola[0], cupola[1], 0.9]]


static func collina(r: Rect2, quota: float, fra_i_piani: float, seme: String) -> Array:
	# IL PROMONTORIO: la stanza sta in cima, e sotto la collina scende fino al
	# piano di sotto, larga il doppio
	var piede := FormePlastico.chiazza(r.grow(minf(r.size.x, r.size.y) * 1.05), seme + "collina", 0.18, 2.0, 18)
	var forma := FormePlastico.dosso(piede, quota - fra_i_piani, quota, 0.36)
	return [forma[0], forma[1], 0.55]


static func fossa(r: Rect2, quota: float, seme: String) -> Array:
	# LA FOSSA: un bordo, e tutto scende verso il fondo, che non si vede
	var bocca := FormePlastico.chiazza(r.grow(-0.08), seme, 0.25, 2.0, 14)
	var imbuto := FormePlastico.cupola(bocca, quota + 0.08, quota + 0.04, Vector3(r.get_center().x, quota - 0.9, r.get_center().y), seme)
	return [imbuto[0], imbuto[1], 0.85]


static func ponte(r: Rect2, quota: float) -> Array:
	# IL PONTE MARCIO: un'asse lunga sopra il vuoto; sotto, il bordo del baratro
	# tratteggiato
	var asse := FormePlastico.cassa(Vector3(r.get_center().x, quota + 0.3, r.get_center().y), Vector3(r.size.x * 1.25, 0.05, 0.26))
	var baratro := PackedVector3Array()
	for v in FormePlastico.chiazza(r.grow(0.1), "baratro", 0.2, 2.0, 16):
		baratro.append(Vector3(v.x, quota - 0.3, v.y))
	return [[asse[0], asse[1], 1.0], [null, FormePlastico.linee(FormePlastico.a_tratti(baratro, 0.12, 0.1)), 0.7]]


static func spiovente(r: Rect2, sopra: float) -> Array:
	# IL TETTO: due falde sopra la stanza, «sotto lo spiovente»
	var colmo := sopra + minf(r.size.x, r.size.y) * 0.45
	var z := r.get_center().y
	var x0 := r.position.x
	var x1 := r.end.x
	var a := [Vector3(x0, sopra, r.position.y), Vector3(x0, colmo, z), Vector3(x0, sopra, r.end.y)]
	var b := [Vector3(x1, sopra, r.position.y), Vector3(x1, colmo, z), Vector3(x1, sopra, r.end.y)]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for p: Vector3 in [a[0], b[0], b[1], a[0], b[1], a[1], a[1], b[1], b[2], a[1], b[2], a[2], a[0], a[1], a[2], b[0], b[2], b[1]]:
		st.add_vertex(p)
	st.generate_normals()
	var tratti := PackedVector3Array([a[0], a[1], a[1], a[2], b[0], b[1], b[1], b[2], a[1], b[1]])
	return [st.commit(), FormePlastico.linee(tratti), 0.9]


static func serra(r: Rect2, quota: float) -> Array:
	# LA SERRA: una volta a botte sopra la stanza, coi due archi di testa e uno in mezzo
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var archi: Array[PackedVector3Array] = []
	var tratti := PackedVector3Array()
	for k in 3:
		var x := r.position.x + r.size.x * float(k) / 2.0
		var arco := PackedVector3Array()
		for s in 9:
			var a := PI * float(s) / 8.0
			arco.append(Vector3(x, quota + 0.06 + sin(a) * r.size.y * 0.42, r.get_center().y + cos(a) * r.size.y * 0.45))
		archi.append(arco)
		tratti.append_array(FormePlastico.giro(arco, false))
	for k in archi.size() - 1:
		for s in 8:
			for p: Vector3 in [archi[k][s], archi[k + 1][s], archi[k + 1][s + 1], archi[k][s], archi[k + 1][s + 1], archi[k][s + 1]]:
				st.add_vertex(p)
	tratti.append_array([archi[0][4], archi[archi.size() - 1][4]])
	st.generate_normals()
	return [st.commit(), FormePlastico.linee(tratti), 0.8]
