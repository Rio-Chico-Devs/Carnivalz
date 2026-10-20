class_name ArrediPlastico
extends RefCounted

# QUELLO CHE C'E' IN UNA STANZA, quando la stanza si riconosce da quello: il
# masso gigante e' un masso, le pozze sono pozze, il ponte marcio e' un ponte.
# Sta nel "dettaglio" della stanza (data/*.json); AmbientiPlastico ci mette
# sotto la forma del suo ambiente (la radura, la caverna, la stanza della casa),
# tranne per quelli che sono la stanza stessa (SENZA_BASE: un ponte non ha
# pavimento, una fossa e' un buco). Ogni pezzo e' [pieno, linee, quanto si
# accende rispetto alla stanza].

const DETTAGLI := ["alberone", "masso", "pozze", "collina", "tartaruga", "falo", "atterraggio", "cartello", "grotta",
		"ponte", "fossa", "piazza", "sala", "cargo", "varco", "serra", "vasche", "scaffali", "altare", "spiovente",
		"cancello", "fiori"]
const SENZA_BASE := ["ponte", "fossa"]


static func dettaglio(nome: String, r: Rect2, quota: float, id_stanza: String, fra_i_piani: float) -> Array:
	var c := Vector3(r.get_center().x, quota + 0.06, r.get_center().y)
	var rng := FormePlastico.caso(id_stanza + nome)
	match nome:
		"alberone":
			return albero(c, 1.0, rng, true)
		"masso":
			return [masso(c, minf(r.size.x, r.size.y) * 0.3, id_stanza)]
		"pozze":
			return pozze(c, r, rng)
		"collina":
			return [collina(r, quota, fra_i_piani, id_stanza)]
		"tartaruga":
			return tartaruga(c, minf(r.size.x, r.size.y) * 0.38, id_stanza)
		"falo":
			return falo(c)
		"atterraggio":
			return [[null, FormePlastico.linee(cerchi(c + Vector3.UP * 0.01, [0.18, 0.34, 0.5])), 0.9]]
		"cartello":
			return cartello(c)
		"grotta":
			return grotta(c, r, rng)
		"ponte":
			return ponte(r, quota)
		"fossa":
			return [fossa(r, quota, id_stanza)]
	return dettaglio_di_casa(nome, r, quota, c, rng)


static func dettaglio_di_casa(nome: String, r: Rect2, quota: float, c: Vector3, rng: RandomNumberGenerator) -> Array:
	match nome:
		"piazza", "sala":
			return colonne(r, quota, 2 if nome == "piazza" else 1)
		"cargo":
			return cargo(r, quota)
		"varco":
			return varco(c)
		"serra":
			return [serra(r, quota)]
		"vasche":
			return vasche(r, quota)
		"scaffali":
			return scaffali(r, quota)
		"altare":
			return altare(c)
		"spiovente":
			return [spiovente(r, quota + PlasticoZona.ALTEZZA_STANZA)]
		"cancello":
			return cancello(c, r)
		"fiori":
			return fiori(c, r, rng)
	return []


static func albero(base: Vector3, alto: float, rng: RandomNumberGenerator, grande := false) -> Array:
	# un tronco e una chioma: tonda o a punta, a caso
	var tronco := FormePlastico.cilindro(base, 0.035 * (2.0 if grande else 1.0), alto * 0.45, 5)
	var forme: Array = [[tronco[0], tronco[1], 1.0 if grande else 0.6]]
	if not grande and rng.randf() < 0.5:
		var abete := FormePlastico.cilindro(base + Vector3.UP * alto * 0.25, alto * 0.24, alto * 0.75, 6, true)
		forme.append([abete[0], abete[1], 0.75])
	else:
		var largo := alto * (0.55 if grande else 0.26)
		var chioma := FormePlastico.palla(base + Vector3.UP * alto * 0.62, Vector3(largo, alto * 0.3, largo), 8 if grande else 6, 4)
		forme.append([chioma[0], chioma[1], 1.15 if grande else 0.75])
	return forme


static func masso(c: Vector3, raggio: float, seme: String) -> Array:
	var giro := FormePlastico.chiazza(Rect2(Vector2(c.x, c.z) - Vector2.ONE * raggio, Vector2.ONE * raggio * 2.0), seme + "masso", 0.35, 2.0, 7)
	var forma := FormePlastico.cupola(giro, c.y, c.y + raggio * 0.7, c + Vector3(raggio * 0.15, raggio * 1.6, -raggio * 0.1), seme)
	return [forma[0], forma[1], 0.95]


static func pozze(c: Vector3, r: Rect2, rng: RandomNumberGenerator) -> Array:
	# due o tre specchi d'acqua piatti, coi cerchi dell'acqua dentro
	var forme: Array = []
	for k in 2 + rng.randi() % 2:
		var dove := c + Vector3((rng.randf() - 0.5) * r.size.x * 0.5, 0.01, (rng.randf() - 0.5) * r.size.y * 0.5)
		var raggio := minf(r.size.x, r.size.y) * (0.12 + rng.randf() * 0.08)
		var giro := FormePlastico.chiazza(Rect2(Vector2(dove.x, dove.z) - Vector2(raggio * 1.4, raggio), Vector2(raggio * 2.8, raggio * 2.0)),
				str(k), 0.1, 2.0, 14)
		var acqua := FormePlastico.prisma(giro, dove.y, FormePlastico.piane(giro.size(), dove.y))
		forme.append([acqua[0], FormePlastico.linee(cerchi(dove, [raggio * 0.5])), 1.2])
		forme.append([null, acqua[1], 1.0])
	return forme


static func collina(r: Rect2, quota: float, fra_i_piani: float, seme: String) -> Array:
	# IL PROMONTORIO: la stanza sta in cima, e sotto la collina scende fino al
	# piano di sotto, larga il doppio
	var piede := FormePlastico.chiazza(r.grow(minf(r.size.x, r.size.y) * 1.05), seme + "collina", 0.18, 2.0, 18)
	var forma := FormePlastico.dosso(piede, quota - fra_i_piani, quota, 0.36)
	return [forma[0], forma[1], 0.55]


static func tartaruga(c: Vector3, raggio: float, seme: String) -> Array:
	var guscio := FormePlastico.chiazza(Rect2(Vector2(c.x, c.z) - Vector2(raggio, raggio * 0.8), Vector2(raggio * 2.0, raggio * 1.6)),
			seme, 0.03, 2.0, 10)
	# IL GUSCIO: una collinetta a anelli, la testa e quattro zampe
	var dorso := FormePlastico.dosso(guscio, c.y, c.y + raggio * 0.75, 0.35, 4)
	var forme: Array = [[dorso[0], dorso[1], 1.1]]
	var testa := FormePlastico.palla(c + Vector3(raggio * 1.15, raggio * 0.22, 0.0), Vector3.ONE * raggio * 0.24, 6, 3)
	forme.append([testa[0], testa[1], 1.0])
	for zampa: Vector2 in [Vector2(0.6, 0.7), Vector2(-0.6, 0.7), Vector2(0.6, -0.7), Vector2(-0.6, -0.7)]:
		var piede := FormePlastico.palla(c + Vector3(zampa.x * raggio, raggio * 0.06, zampa.y * raggio * 0.8), Vector3(raggio * 0.16, raggio * 0.1, raggio * 0.16), 5, 2)
		forme.append([piede[0], piede[1], 0.9])
	return forme


static func falo(c: Vector3) -> Array:
	# il fuoco del goblin: una fiamma e un giro di sassi
	var fiamma := FormePlastico.cilindro(c, 0.09, 0.26, 5, true)
	var forme: Array = [[fiamma[0], fiamma[1], 1.1]]
	for k in 6:
		var sasso := FormePlastico.palla(c + Vector3(cos(TAU * k / 6.0) * 0.16, 0.02, sin(TAU * k / 6.0) * 0.16), Vector3.ONE * 0.035, 5, 2)
		forme.append([sasso[0], sasso[1], 0.7])
	return forme


static func cartello(c: Vector3) -> Array:
	var palo := FormePlastico.cilindro(c, 0.025, 0.55, 4)
	var su := FormePlastico.cassa(c + Vector3(0.1, 0.48, 0.0), Vector3(0.26, 0.08, 0.02))
	var giu := FormePlastico.cassa(c + Vector3(-0.08, 0.36, 0.02), Vector3(0.24, 0.08, 0.02))
	return [[palo[0], palo[1], 0.8], [su[0], su[1], 0.9], [giu[0], giu[1], 0.9]]


static func grotta(c: Vector3, r: Rect2, rng: RandomNumberGenerator) -> Array:
	# stalagmiti: punte di roccia che salgono dal fondo
	var forme: Array = []
	for k in 4:
		var dove := c + Vector3((rng.randf() - 0.5) * r.size.x * 0.6, -0.06, (rng.randf() - 0.5) * r.size.y * 0.6)
		var punta := FormePlastico.cilindro(dove, 0.05 + rng.randf() * 0.04, 0.2 + rng.randf() * 0.25, 5, true)
		forme.append([punta[0], punta[1], 0.9])
	return forme


static func ponte(r: Rect2, quota: float) -> Array:
	# IL PONTE MARCIO: un'asse lunga sopra il vuoto, i corrimano e i pali; sotto,
	# il bordo del baratro tratteggiato
	var lungo := r.size.x * 1.25
	var c := Vector3(r.get_center().x, quota + 0.3, r.get_center().y)
	var asse := FormePlastico.cassa(c, Vector3(lungo, 0.04, 0.24))
	var tratti := PackedVector3Array()
	for z: float in [-0.12, 0.12]:
		tratti.append_array([c + Vector3(-lungo * 0.5, 0.18, z), c + Vector3(lungo * 0.5, 0.18, z)])
		for k in 5:
			var x := -lungo * 0.5 + lungo * float(k) / 4.0
			tratti.append_array([c + Vector3(x, 0.0, z), c + Vector3(x, 0.18, z)])
	var baratro := PackedVector3Array()
	for v in FormePlastico.chiazza(r.grow(0.1), "baratro", 0.2, 2.0, 16):
		baratro.append(Vector3(v.x, quota - 0.3, v.y))
	return [[asse[0], asse[1], 1.0], [null, FormePlastico.linee(tratti), 0.9],
			[null, FormePlastico.linee(FormePlastico.a_tratti(baratro, 0.12, 0.1)), 0.7]]


static func fossa(r: Rect2, quota: float, seme: String) -> Array:
	# LA FOSSA: un bordo, e tutto scende verso il fondo, che non si vede
	var bocca := FormePlastico.chiazza(r.grow(-0.08), seme, 0.25, 2.0, 14)
	var imbuto := FormePlastico.cupola(bocca, quota + 0.08, quota + 0.04, Vector3(r.get_center().x, quota - 0.9, r.get_center().y), seme)
	return [imbuto[0], imbuto[1], 0.85]


static func colonne(r: Rect2, quota: float, per_lato: int) -> Array:
	var forme: Array = []
	for i in per_lato + 1:
		for k in 2:
			var x := r.position.x + r.size.x * (0.25 + 0.5 * float(i) / float(maxi(per_lato, 1)))
			var z := r.position.y + r.size.y * (0.3 + 0.4 * float(k))
			var colonna := FormePlastico.cilindro(Vector3(x, quota, z), 0.06, 0.55, 6)
			forme.append([colonna[0], colonna[1], 0.8])
	return forme


static func cargo(r: Rect2, quota: float) -> Array:
	# un container abbandonato, con le costole
	var c := Vector3(r.get_center().x, quota + 0.22, r.get_center().y)
	var scafo := FormePlastico.cassa(c, Vector3(r.size.x * 0.85, 0.4, r.size.y * 0.4))
	var costole := PackedVector3Array()
	for k in 5:
		var x := c.x - r.size.x * 0.42 + r.size.x * 0.84 * float(k) / 4.0
		costole.append_array([Vector3(x, quota + 0.02, c.z + r.size.y * 0.2 + 0.005), Vector3(x, quota + 0.42, c.z + r.size.y * 0.2 + 0.005)])
	return [[scafo[0], scafo[1], 1.0], [null, FormePlastico.linee(costole), 0.8]]


static func varco(c: Vector3) -> Array:
	# lo squarcio da cui si entra: un anello in piedi
	var giro := PackedVector3Array()
	for k in 19:
		var a := TAU * float(k) / 18.0
		giro.append(c + Vector3(cos(a) * 0.32, 0.4 + sin(a) * 0.36, 0.0))
	var anello := FormePlastico.tubo(giro, 0.04, "varco", 0.0, 5)
	return [[anello[0], anello[1], 1.1]]


static func serra(r: Rect2, quota: float) -> Array:
	# LA SERRA: archi di vetro sopra la stanza, uno dietro l'altro
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var archi: Array[PackedVector3Array] = []
	var tratti := PackedVector3Array()
	for k in 5:
		var x := r.position.x + r.size.x * float(k) / 4.0
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


static func vasche(r: Rect2, quota: float) -> Array:
	var forme: Array = []
	for k in 3:
		var x := r.position.x + r.size.x * (0.22 + 0.28 * float(k))
		var vasca := FormePlastico.cilindro(Vector3(x, quota, r.get_center().y), r.size.x * 0.11, PlasticoZona.ALTEZZA_STANZA * 0.8, 8)
		forme.append([vasca[0], vasca[1], 0.8])
	return forme


static func scaffali(r: Rect2, quota: float) -> Array:
	var forme: Array = []
	for k in 3:
		var z := r.position.y + r.size.y * (0.25 + 0.25 * float(k))
		var scaffale := FormePlastico.cassa(Vector3(r.get_center().x, quota + 0.25, z), Vector3(r.size.x * 0.7, 0.5, 0.06))
		forme.append([scaffale[0], scaffale[1], 0.8])
	return forme


static func altare(c: Vector3) -> Array:
	var gradino := FormePlastico.cassa(c + Vector3.UP * 0.05, Vector3(0.5, 0.1, 0.36))
	var pietra := FormePlastico.cassa(c + Vector3.UP * 0.2, Vector3(0.32, 0.2, 0.2))
	return [[gradino[0], gradino[1], 0.9], [pietra[0], pietra[1], 1.0]]


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


static func cancello(c: Vector3, r: Rect2) -> Array:
	# l'ingresso del parco: due pilastri e l'arco, dalla parte della casa
	var dove := Vector3(c.x, c.y, r.position.y + r.size.y * 0.2)
	var forme: Array = []
	for x: float in [-0.22, 0.22]:
		var pilastro := FormePlastico.cassa(dove + Vector3(x, 0.25, 0.0), Vector3(0.08, 0.5, 0.08))
		forme.append([pilastro[0], pilastro[1], 0.9])
	var arco := PackedVector3Array()
	for k in 9:
		var a := PI * float(k) / 8.0
		arco.append(dove + Vector3(cos(a) * 0.22, 0.5 + sin(a) * 0.12, 0.0))
	forme.append([null, FormePlastico.linee(FormePlastico.giro(arco, false)), 0.9])
	return forme


static func fiori(c: Vector3, r: Rect2, rng: RandomNumberGenerator) -> Array:
	var forme: Array = []
	for k in 9:
		var dove := c + Vector3((rng.randf() - 0.5) * r.size.x * 0.6, 0.04, (rng.randf() - 0.5) * r.size.y * 0.6)
		var fiore := FormePlastico.palla(dove, Vector3.ONE * 0.045, 5, 2)
		forme.append([fiore[0], fiore[1], 1.1])
	return forme


static func cerchi(c: Vector3, raggi: Array) -> PackedVector3Array:
	var tratti := PackedVector3Array()
	for raggio: float in raggi:
		var giro := PackedVector3Array()
		for k in 20:
			giro.append(c + Vector3(cos(TAU * k / 20.0), 0.0, sin(TAU * k / 20.0)) * raggio)
		tratti.append_array(FormePlastico.giro(giro))
	return tratti
