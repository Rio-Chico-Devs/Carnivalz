class_name FormePlastico
extends RefCounted

# LE FORME DEL PLASTICO, oltre alla scatola: quello con cui una zona somiglia al
# suo posto (AmbientiPlastico decide quale forma va dove). Ogni funzione torna
# due mesh, [pieno, linee]: il pieno e' il velo di luce, le linee gli spigoli
# accesi, come per le stanze di sempre (PlasticoZona.getto le monta).
#
# LE FORME STORTE SONO STORTE SEMPRE ALLO STESSO MODO. Il caso viene da un seme
# (il nome della stanza): la mappa si rifa' ogni volta che la si apre, e una
# radura che cambia sagoma a ogni apertura sembrerebbe un errore.


static func caso(seme: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(seme)
	return rng


static func linee(segmenti: PackedVector3Array) -> ArrayMesh:
	# coppie di punti: ogni coppia e' un tratto
	var m := ArrayMesh.new()
	if segmenti.size() < 2:
		return m
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = segmenti
	m.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return m


static func giro(punti: PackedVector3Array, chiuso := true) -> PackedVector3Array:
	# una spezzata come coppie di tratti
	var tratti := PackedVector3Array()
	var n := punti.size()
	for i in (n if chiuso else n - 1):
		tratti.append(punti[i])
		tratti.append(punti[(i + 1) % n])
	return tratti


static func a_tratti(punti: PackedVector3Array, pieno: float, vuoto: float, chiuso := true) -> PackedVector3Array:
	# la stessa spezzata, ma tratteggiata: il terreno sotto terra, i bordi incerti
	var tratti := PackedVector3Array()
	var n := punti.size()
	var resto := 0.0
	for i in (n if chiuso else n - 1):
		var da := punti[i]
		var a := punti[(i + 1) % n]
		var lungo := da.distance_to(a)
		var k := -resto
		while k < lungo:
			var inizio := maxf(k, 0.0)
			var fine := minf(k + pieno, lungo)
			if fine > inizio and lungo > 0.0:
				tratti.append(da.lerp(a, inizio / lungo))
				tratti.append(da.lerp(a, fine / lungo))
			k += pieno + vuoto
		resto = k - lungo
	return tratti


static func chiazza(r: Rect2, seme: String, storto := 0.12, tondo := 2.2, lati := 18) -> PackedVector2Array:
	# UN CONTORNO MORBIDO DENTRO UN RETTANGOLO: tondo 2 e' un'ellisse, 4 quasi un
	# quadrato coi lati smussati; storto e' quanto il bordo va e viene
	var rng := caso(seme)
	var raggi: Array[float] = []
	for i in lati:
		raggi.append(1.0 - storto + rng.randf() * storto)
	var c := r.get_center()
	var meta := r.size * 0.5
	var punti := PackedVector2Array()
	for i in lati:
		var k := (raggi[(i - 1 + lati) % lati] + raggi[i] * 2.0 + raggi[(i + 1) % lati]) * 0.25
		var d := Vector2.from_angle(TAU * float(i) / float(lati))
		var fino := pow(pow(absf(d.x), tondo) + pow(absf(d.y), tondo), -1.0 / tondo)
		punti.append(c + d * meta * fino * k)
	return punti


static func smussa(punti: PackedVector2Array, volte := 2) -> PackedVector2Array:
	# Chaikin: ogni spigolo diventa due, e il contorno si ammorbidisce
	var fuori := punti
	for v in volte:
		var nuovi := PackedVector2Array()
		var n := fuori.size()
		for i in n:
			var a := fuori[i]
			var b := fuori[(i + 1) % n]
			nuovi.append(a.lerp(b, 0.25))
			nuovi.append(a.lerp(b, 0.75))
		fuori = nuovi
	return fuori


static func prisma(contorno: PackedVector2Array, sotto: float, sopra: PackedFloat32Array, verticali := 0) -> Array:
	# UN CONTORNO TIRATO SU: il tetto alla quota di ogni vertice (tutte uguali
	# per una radura, storte per una caverna), i fianchi fino a "sotto". Linee:
	# il bordo di sopra, quello di sotto e un montante ogni "verticali" vertici
	var n := contorno.size()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tri := Geometry2D.triangulate_polygon(contorno)
	for k in tri:
		st.add_vertex(Vector3(contorno[k].x, sopra[k], contorno[k].y))
	var su := PackedVector3Array()
	var giu := PackedVector3Array()
	for i in n:
		su.append(Vector3(contorno[i].x, sopra[i], contorno[i].y))
		giu.append(Vector3(contorno[i].x, sotto, contorno[i].y))
	for i in n:
		var j := (i + 1) % n
		for p: Vector3 in [giu[i], giu[j], su[j], giu[i], su[j], su[i]]:
			st.add_vertex(p)
	st.generate_normals()
	var tratti := giro(su)
	if absf(sopra[0] - sotto) > 0.02:
		tratti.append_array(giro(giu))
	if verticali > 0:
		for i in range(0, n, verticali):
			tratti.append(giu[i])
			tratti.append(su[i])
	return [st.commit(), linee(tratti)]


static func piane(n: int, quota: float) -> PackedFloat32Array:
	var q := PackedFloat32Array()
	q.resize(n)
	q.fill(quota)
	return q


static func cupola(contorno: PackedVector2Array, sotto: float, bordo: float, apice: Vector3, seme := "") -> Array:
	# UN MUCCHIO: i fianchi fino al bordo, e da li' tutto converge in una punta.
	# Un masso, una collina, il guscio di una tartaruga; con la punta sotto il
	# bordo e' un imbuto (la fossa)
	var rng := caso(seme)
	var n := contorno.size()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var giu := PackedVector3Array()
	var su := PackedVector3Array()
	for i in n:
		giu.append(Vector3(contorno[i].x, sotto, contorno[i].y))
		su.append(Vector3(contorno[i].x, bordo + (rng.randf() - 0.5) * absf(bordo - sotto) * 0.5, contorno[i].y))
	var tratti := giro(giu)
	tratti.append_array(giro(su))
	for i in n:
		var j := (i + 1) % n
		for p: Vector3 in [giu[i], giu[j], su[j], giu[i], su[j], su[i], su[i], su[j], apice]:
			st.add_vertex(p)
		tratti.append(su[i])
		tratti.append(apice)
	st.generate_normals()
	return [st.commit(), linee(tratti)]


static func dosso(contorno: PackedVector2Array, piede: float, cima: float, in_cima := 0.6, anelli := 5) -> Array:
	# UNA COLLINA: anelli che si stringono salendo, ripidi in basso e piatti in
	# cima, dove si appoggia la radura. Il contorno e' il piede
	var centro := Vector2.ZERO
	for v in contorno:
		centro += v / float(contorno.size())
	var giri: Array[PackedVector3Array] = []
	for k in anelli + 1:
		var t := float(k) / float(anelli)
		var stringe := lerpf(1.0, in_cima, t)
		var y := lerpf(piede, cima, sin(t * PI * 0.5))
		var giro_k := PackedVector3Array()
		for v in contorno:
			var dove := centro + (v - centro) * stringe
			giro_k.append(Vector3(dove.x, y, dove.y))
		giri.append(giro_k)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tratti := PackedVector3Array()
	var n := contorno.size()
	for k in anelli:
		tratti.append_array(giro(giri[k]))
		for i in n:
			var j := (i + 1) % n
			for p: Vector3 in [giri[k][i], giri[k][j], giri[k + 1][j], giri[k][i], giri[k + 1][j], giri[k + 1][i]]:
				st.add_vertex(p)
			if i % 3 == 0:
				tratti.append(giri[k][i])
				tratti.append(giri[k + 1][i])
	st.generate_normals()
	return [st.commit(), linee(tratti)]


static func nastro(punti: PackedVector3Array, largo: float) -> Array:
	# UN SENTIERO: una striscia che segue la spezzata, coi due bordi accesi
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var sinistra := PackedVector3Array()
	var destra := PackedVector3Array()
	for i in punti.size():
		var avanti := (punti[mini(i + 1, punti.size() - 1)] - punti[maxi(i - 1, 0)])
		var lato := Vector3(avanti.z, 0.0, -avanti.x).normalized() * largo * 0.5
		sinistra.append(punti[i] + lato)
		destra.append(punti[i] - lato)
	for i in punti.size() - 1:
		for p: Vector3 in [sinistra[i], destra[i], destra[i + 1], sinistra[i], destra[i + 1], sinistra[i + 1]]:
			st.add_vertex(p)
	st.generate_normals()
	var tratti := giro(sinistra, false)
	tratti.append_array(giro(destra, false))
	return [st.commit(), linee(tratti)]


static func tubo(punti: PackedVector3Array, raggio: float, seme: String, storto := 0.25, lati := 7) -> Array:
	# UNA GALLERIA: anelli lungo la spezzata, ognuno un po' piu' largo o piu'
	# stretto dell'altro. Linee: un anello ogni due e tre fili per il lungo
	var anelli := anelli_del_tubo(punti, raggio, seme, storto, lati)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tratti := PackedVector3Array()
	for i in anelli.size():
		if i % 2 == 0:
			tratti.append_array(giro(anelli[i]))
		if i == anelli.size() - 1:
			continue
		for k in lati:
			var j := (k + 1) % lati
			for p: Vector3 in [anelli[i][k], anelli[i][j], anelli[i + 1][j], anelli[i][k], anelli[i + 1][j], anelli[i + 1][k]]:
				st.add_vertex(p)
			if k % maxi(floori(lati / 3.0), 1) == 0:
				tratti.append(anelli[i][k])
				tratti.append(anelli[i + 1][k])
	st.generate_normals()
	return [st.commit(), linee(tratti)]


static func anelli_del_tubo(punti: PackedVector3Array, raggio: float, seme: String, storto: float, lati: int) -> Array[PackedVector3Array]:
	# un anello per punto, di traverso alla direzione in cui va il tubo
	var rng := caso(seme)
	var anelli: Array[PackedVector3Array] = []
	for i in punti.size():
		var avanti := (punti[mini(i + 1, punti.size() - 1)] - punti[maxi(i - 1, 0)]).normalized()
		var su := Vector3.UP if absf(avanti.y) < 0.9 else Vector3.RIGHT
		var n := avanti.cross(su).normalized()
		var b := avanti.cross(n).normalized()
		var r := raggio * (1.0 + (rng.randf() - 0.5) * storto * 2.0)
		var anello := PackedVector3Array()
		for k in lati:
			var a := TAU * float(k) / float(lati)
			anello.append(punti[i] + (n * cos(a) + b * sin(a)) * r)
		anelli.append(anello)
	return anelli


static func curva(punti: PackedVector3Array, passi := 6) -> PackedVector3Array:
	# Catmull-Rom: una spezzata di pochi punti diventa una curva morbida che ci passa
	if punti.size() < 3:
		var dritta := PackedVector3Array()
		for k in passi + 1:
			dritta.append(punti[0].lerp(punti[punti.size() - 1], float(k) / float(passi)))
		return dritta
	var fuori := PackedVector3Array()
	for i in punti.size() - 1:
		var p0 := punti[maxi(i - 1, 0)]
		var p1 := punti[i]
		var p2 := punti[i + 1]
		var p3 := punti[mini(i + 2, punti.size() - 1)]
		for k in passi:
			var t := float(k) / float(passi)
			fuori.append(0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t * t
					+ (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t * t * t))
	fuori.append(punti[punti.size() - 1])
	return fuori


static func serpeggia(da: Vector3, a: Vector3, seme: String, quanto := 0.22) -> PackedVector3Array:
	# fra due punti, una curva che non va dritta: due gomiti di lato, a caso
	var rng := caso(seme)
	var piatto := Vector3(a.x - da.x, 0.0, a.z - da.z)
	var lato := Vector3(piatto.z, 0.0, -piatto.x).normalized() * piatto.length() * quanto
	var uno := da.lerp(a, 0.33) + lato * (rng.randf() * 2.0 - 1.0)
	var due := da.lerp(a, 0.66) + lato * (rng.randf() * 2.0 - 1.0)
	return curva(PackedVector3Array([da, uno, due, a]), 5)


static func cilindro(base: Vector3, raggio: float, alto: float, lati := 8, punta := false) -> Array:
	# una colonna, una vasca, un tronco; con la punta e' un cono (un abete)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var giu := PackedVector3Array()
	var su := PackedVector3Array()
	var cima := base + Vector3.UP * alto
	for k in lati:
		var d := Vector3(cos(TAU * float(k) / float(lati)), 0.0, sin(TAU * float(k) / float(lati))) * raggio
		giu.append(base + d)
		su.append(cima if punta else cima + d)
	var tratti := giro(giu)
	if not punta:
		tratti.append_array(giro(su))
	for k in lati:
		var j := (k + 1) % lati
		for p: Vector3 in [giu[k], giu[j], su[j], giu[k], su[j], su[k]]:
			st.add_vertex(p)
		if punta or k % 2 == 0:
			tratti.append(giu[k])
			tratti.append(su[k])
		if not punta:
			for p: Vector3 in [cima, su[k], su[j]]:
				st.add_vertex(p)
	st.generate_normals()
	return [st.commit(), linee(tratti)]


static func palla(centro: Vector3, raggio: Vector3, lati := 8, strati := 4) -> Array:
	# una chioma, un cespuglio: una sfera schiacciata a pochi lati
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var anelli: Array[PackedVector3Array] = []
	for s in strati + 1:
		var fi := PI * float(s) / float(strati)
		var anello := PackedVector3Array()
		for k in lati:
			var te := TAU * float(k) / float(lati)
			anello.append(centro + Vector3(sin(fi) * cos(te) * raggio.x, cos(fi) * raggio.y, sin(fi) * sin(te) * raggio.z))
		anelli.append(anello)
	var tratti := PackedVector3Array()
	for s in strati:
		for k in lati:
			var j := (k + 1) % lati
			for p: Vector3 in [anelli[s][k], anelli[s][j], anelli[s + 1][j], anelli[s][k], anelli[s + 1][j], anelli[s + 1][k]]:
				st.add_vertex(p)
			if k % 2 == 0:
				tratti.append(anelli[s][k])
				tratti.append(anelli[s + 1][k])
		if s > 0:
			tratti.append_array(giro(anelli[s]))
	st.generate_normals()
	return [st.commit(), linee(tratti)]


static func cassa(centro: Vector3, misura: Vector3) -> Array:
	var forma := BoxMesh.new()
	forma.size = misura
	var tratti := PackedVector3Array()
	var spigoli := PlasticoZona.spigoli_di(misura)
	for p in (spigoli.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array):
		tratti.append(p + centro)
	var pieno := ArrayMesh.new()
	var arrays := forma.get_mesh_arrays()
	var vertici: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	for i in vertici.size():
		vertici[i] += centro
	arrays[Mesh.ARRAY_VERTEX] = vertici
	pieno.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return [pieno, linee(tratti)]
