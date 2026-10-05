class_name Crepe
extends RefCounted

# LE CREPE DEL VETRO DELL'OROLOGIO, quando il tempo e' finito.
#
# Bru, su due giri di bozze: «the fracture lines have to be more elegant and in
# line with the hole clock design», e poi «il tratto della frattura e' troppo
# denso e la forma non mi piace, troppo prevedibile». La ruota di raggi dal
# perno, uguale su ogni orologio, era elegante ma si indovinava. Questa e' la
# rete di un vetro vero, diversa per ogni orologio:
#   - un punto d'impatto fuori centro, con una stellina di incrinature minute
#   - tre o quattro crepe principali ad angoli disuguali, quasi dritte, con un
#     filo di tremito e ogni tanto uno strappo secco (il tremito continuo le
#     faceva sembrare scarabocchiate)
#   - qualche biforcazione, e un paio di tratti di ragnatela fra due vicine
#   - il filo e' un capello: pieno un soffio vicino all'impatto, quasi niente
#     in punta
#
# Il vetro si crepa in tre COLPI: a ogni colpo le crepe corrono un po' piu' in
# la' (si vede il fronte che avanza, in CORSA secondi), appena passate sono
# bianche e poi si posano sul crema del quadrante. Al terzo le principali sono
# arrivate al bordo, e la Rottura spacca il vetro proprio lungo di loro.
#
# Tutto in coordinate dell'orologio (Cipolla), e tutto dal seme: la stessa
# rete a ogni ridisegno, e un'altra per ogni orologio.

const COLPI := [0.0, 0.13, 0.27]    # quando arrivano i tre colpi, dallo scadere
const CORSA := 0.1                  # quanto ci mette una crepa a correre fin dove arriva
const VETRO := 0.95                 # fin dove arriva il vetro, in frazioni della cassa
const CAPELLO := 0.85               # il filo di una crepa principale, dove e' piu' pieno

var impatto := Vector2.ZERO
# ogni crepa: "punti", "nasce" (il colpo), "arriva" (fin dove, a ogni colpo,
# in frazioni della sua lunghezza), "pieno" (quanto e' grosso il suo filo)
var rete: Array[Dictionary] = []


func _init(seme: int) -> void:
	var d := RandomNumberGenerator.new()
	d.seed = seme
	var c := Cipolla.CENTRO
	impatto = c + Vector2.RIGHT.rotated(d.randf() * TAU) * Cipolla.CASSA * d.randf_range(0.18, 0.5)
	for i in 7:
		var corta := PackedVector2Array([impatto, impatto + Vector2.RIGHT.rotated(d.randf() * TAU)
				* d.randf_range(1.5, 4.5)])
		rete.append({"punti": corta, "nasce": 0, "arriva": [1.0, 1.0, 1.0], "pieno": 0.55})
	var principali := tira_principali(d)
	for punti in principali:
		biforca(d, punti)
	for k in 2:
		ragnatela(d, principali)


func tira_principali(d: RandomNumberGenerator) -> Array[PackedVector2Array]:
	# tre o quattro, ad angoli disuguali: le prime due al primo colpo
	var principali: Array[PackedVector2Array] = []
	var angolo := d.randf() * TAU
	for i in 3 + d.randi() % 2:
		var punti := cammina(d, impatto, angolo)
		principali.append(punti)
		var arriva := [d.randf_range(0.35, 0.55), d.randf_range(0.65, 0.85), 1.0] if i < 2 \
				else [0.0, d.randf_range(0.4, 0.6), 1.0]
		rete.append({"punti": punti, "nasce": 0 if i < 2 else 1, "arriva": arriva, "pieno": 1.0})
		angolo += d.randf_range(1.0, 2.3)
	return principali


func biforca(d: RandomNumberGenerator, punti: PackedVector2Array) -> void:
	# da un punto a meta' di una principale, di sbieco; non sempre arriva al bordo
	if d.randf() < 0.3 or punti.size() < 6:
		return
	var da := d.randi_range(int(punti.size() * 0.3), int(punti.size() * 0.65))
	var verso := (punti[da + 1] - punti[da]).angle() + d.randf_range(0.4, 0.85) * (1.0 if d.randf() < 0.5 else -1.0)
	var fin_dove := 1.0 if d.randf() < 0.6 else d.randf_range(0.4, 0.7)
	rete.append({"punti": cammina(d, punti[da], verso), "nasce": 1, "arriva": [0.0, fin_dove * 0.5, fin_dove],
			"pieno": 0.7})


func ragnatela(d: RandomNumberGenerator, principali: Array[PackedVector2Array]) -> void:
	# un tratto di ragnatela fra due principali vicine, all'ultimo colpo
	var i := d.randi() % principali.size()
	var a := sulla_crepa(principali[i], d.randf_range(0.25, 0.45) * Cipolla.CASSA)
	var b := sulla_crepa(principali[(i + 1) % principali.size()], d.randf_range(0.25, 0.5) * Cipolla.CASSA)
	if a == Vector2.INF or b == Vector2.INF or a.distance_to(b) > Cipolla.CASSA * 0.9:
		return
	var tratto := PackedVector2Array([a])
	for s in range(1, 4):
		tratto.append(a.lerp(b, float(s) / 4.0) + (b - a).orthogonal().normalized() * d.randf_range(-1.6, 1.6))
	tratto.append(b)
	rete.append({"punti": tratto, "nasce": 2, "arriva": [0.0, 0.0, 1.0], "pieno": 0.6})


func cammina(d: RandomNumberGenerator, da: Vector2, angolo: float) -> PackedVector2Array:
	# una crepa che corre fino al bordo del vetro: quasi dritta, con un filo di
	# tremito, e ogni tanto uno strappo secco
	var punti := PackedVector2Array([da])
	var verso := angolo
	var bordo := Cipolla.CASSA * VETRO
	for passo in 80:
		verso += d.randf_range(-0.05, 0.05)
		if d.randf() < 0.09:
			verso += d.randf_range(0.2, 0.42) * (1.0 if d.randf() < 0.5 else -1.0)
		var dopo := punti[punti.size() - 1] + Vector2.RIGHT.rotated(verso) * d.randf_range(2.0, 3.4)
		if dopo.distance_to(Cipolla.CENTRO) >= bordo:
			punti.append(Cipolla.CENTRO + (dopo - Cipolla.CENTRO).normalized() * bordo)
			break
		punti.append(dopo)
	return punti


func sulla_crepa(punti: PackedVector2Array, distanza: float) -> Vector2:
	# il primo punto della crepa a quella distanza dall'impatto
	for p in punti:
		if p.distance_to(impatto) >= distanza:
			return p
	return Vector2.INF


static func arrivata(crepa: Dictionary, fine: float) -> float:
	# fin dove e' arrivata, 'fine' secondi dopo lo scadere: a ogni colpo corre,
	# in CORSA secondi, da dov'era a dove arriva quel colpo
	var arriva: Array = crepa["arriva"]
	var fino := 0.0
	for colpo in COLPI.size():
		var da_quando := fine - float(COLPI[colpo])
		if da_quando < 0.0:
			break
		var t := clampf(da_quando / CORSA, 0.0, 1.0)
		fino = lerpf(fino, float(arriva[colpo]), 1.0 - pow(1.0 - t, 2.0))
	return fino


static func lunghezza(punti: PackedVector2Array) -> float:
	var totale := 0.0
	for i in range(1, punti.size()):
		totale += punti[i].distance_to(punti[i - 1])
	return totale


static func taglia(punti: PackedVector2Array, fino: float) -> PackedVector2Array:
	# la crepa fin dove e' arrivata: 'fino' della sua lunghezza
	var resta := lunghezza(punti) * fino
	var vivi := PackedVector2Array([punti[0]])
	var fatto := 0.0
	for i in range(1, punti.size()):
		var pezzo := punti[i].distance_to(punti[i - 1])
		if fatto + pezzo >= resta:
			vivi.append(punti[i - 1].lerp(punti[i], (resta - fatto) / maxf(pezzo, 0.001)))
			break
		vivi.append(punti[i])
		fatto += pezzo
	return vivi


func disegna(tela: CanvasItem, fine: float) -> void:
	for crepa in rete:
		var fino := arrivata(crepa, fine)
		if fino <= 0.0:
			continue
		# appena passato il fronte la crepa e' bianca, poi si posa sul crema
		var acceso := 1.0 - clampf((fine - float(COLPI[int(crepa["nasce"])]) - CORSA) / 0.15, 0.0, 1.0)
		var tinta := Color(Cipolla.crema().lerp(Color(1, 1, 1), acceso), 0.92)
		var punti: PackedVector2Array = crepa["punti"]
		filo(tela, taglia(punti, fino), lunghezza(punti), CAPELLO * float(crepa["pieno"]), tinta)


static func filo(tela: CanvasItem, vivi: PackedVector2Array, totale: float, pieno: float, tinta: Color) -> void:
	# un filo che si assottiglia da 'pieno' a quasi niente lungo 'totale'
	if vivi.size() < 2 or lunghezza(vivi) <= 0.3:
		return
	var sinistra := PackedVector2Array()
	var destra := PackedVector2Array()
	var corso := 0.0
	for i in vivi.size():
		if i > 0:
			corso += vivi[i].distance_to(vivi[i - 1])
		var verso := (vivi[mini(i + 1, vivi.size() - 1)] - vivi[maxi(i - 1, 0)]).normalized()
		var largo := lerpf(pieno, 0.12, corso / maxf(totale, 0.001)) * 0.5
		sinistra.append(vivi[i] + verso.orthogonal() * largo)
		destra.append(vivi[i] - verso.orthogonal() * largo)
	destra.reverse()
	sinistra.append_array(destra)
	Manifesto.poligono(tela, sinistra, tinta)


func per_la_rottura(fine: float) -> Array[PackedVector2Array]:
	# LE CREPE COME SONO ADESSO, per spaccarci il vetro. Quelle arrivate al
	# bordo del vetro proseguono oltre l'orlo: se no il disco resterebbe
	# intero, coi tagli dentro come buchi
	var tagli: Array[PackedVector2Array] = []
	for crepa in rete:
		var fino := arrivata(crepa, fine)
		if fino <= 0.0:
			continue
		var punti := taglia(crepa["punti"], fino)
		var ultimo := punti[punti.size() - 1]
		if fino >= 0.999 and ultimo.distance_to(Cipolla.CENTRO) >= Cipolla.CASSA * VETRO - 0.01:
			punti.append(ultimo + (ultimo - Cipolla.CENTRO).normalized() * Cipolla.CASSA * 0.3)
		if punti.size() > 1:
			tagli.append(punti)
	return tagli
