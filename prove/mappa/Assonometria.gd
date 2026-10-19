extends RefCounted

# UN PLASTICO GUARDATO IN ASSONOMETRIA: senza prospettiva, come un disegno
# d'architetto. Le stanze lontane restano grandi quanto le vicine, le linee
# parallele restano parallele, e un piano si legge tutto alla stessa misura.
# Nella mappa vera sarebbe una Camera3D ortogonale con gli stessi due angoli: il
# giro (intorno) e l'altezza (quanto dall'alto). Qui si proietta a mano per
# poter disegnare in 2D, con i bordi e i pieni del manifesto.

var giro := -0.6        # radianti
var altezza := 32.0     # gradi: 90 e' la pianta
var scala := 40.0       # pixel per unita'
var centro := Vector2.ZERO
var destra := Vector3.RIGHT
var su := Vector3.UP
var verso := Vector3.BACK   # dal modellino verso chi guarda


func orienta(nuovo_giro: float, nuova_altezza: float) -> void:
	giro = nuovo_giro
	altezza = nuova_altezza
	var b := deg_to_rad(altezza)
	verso = Vector3(sin(giro) * cos(b), sin(b), cos(giro) * cos(b))
	destra = Vector3.UP.cross(verso).normalized()
	su = verso.cross(destra)


func crudo(p: Vector3) -> Vector2:
	return Vector2(p.dot(destra), -p.dot(su))


func a_schermo(p: Vector3) -> Vector2:
	return centro + crudo(p) * scala


func profondita(p: Vector3) -> float:
	# piu' grande = piu' vicino a chi guarda: si disegna dopo
	return p.dot(verso)


func adatta(punti: Array[Vector3], dentro: Rect2) -> void:
	# la scala e il centro che mettono quei punti dentro il riquadro
	if punti.is_empty():
		return
	var r := Rect2(crudo(punti[0]), Vector2.ZERO)
	for p in punti:
		r = r.expand(crudo(p))
	scala = minf(dentro.size.x / maxf(r.size.x, 0.001), dentro.size.y / maxf(r.size.y, 0.001))
	centro = dentro.get_center() - r.get_center() * scala


func angoli(pianta: Rect2, sotto: float, sopra: float) -> Array[Vector3]:
	var tutti: Array[Vector3] = []
	for y: float in [sotto, sopra]:
		tutti.append(Vector3(pianta.position.x, y, pianta.position.y))
		tutti.append(Vector3(pianta.end.x, y, pianta.position.y))
		tutti.append(Vector3(pianta.end.x, y, pianta.end.y))
		tutti.append(Vector3(pianta.position.x, y, pianta.end.y))
	return tutti


func facce(pianta: Rect2, sotto: float, sopra: float) -> Dictionary:
	# le facce di una scatola che si vedono: "tetto" e i fianchi verso chi guarda,
	# ognuna gia' a schermo
	var a := angoli(pianta, sotto, sopra)
	var viste := {}
	viste["tetto"] = PackedVector2Array([a_schermo(a[4]), a_schermo(a[5]), a_schermo(a[6]), a_schermo(a[7])])
	var fianchi := [[0, 1, Vector3.FORWARD], [1, 2, Vector3.RIGHT], [2, 3, Vector3.BACK], [3, 0, Vector3.LEFT]]
	var lati: Array[PackedVector2Array] = []
	for f: Array in fianchi:
		if (f[2] as Vector3).dot(verso) > 0.001:
			var i: int = f[0]
			var j: int = f[1]
			lati.append(PackedVector2Array([a_schermo(a[i]), a_schermo(a[j]), a_schermo(a[j + 4]), a_schermo(a[i + 4])]))
	viste["fianchi"] = lati
	return viste


func sagoma(pianta: Rect2, sotto: float, sopra: float) -> PackedVector2Array:
	var punti := PackedVector2Array()
	for p in angoli(pianta, sotto, sopra):
		punti.append(a_schermo(p))
	return Geometry2D.convex_hull(punti)


func ingombro(pianta: Rect2, sotto: float, sopra: float) -> Rect2:
	var s := sagoma(pianta, sotto, sopra)
	var r := Rect2(s[0], Vector2.ZERO)
	for p in s:
		r = r.expand(p)
	return r
