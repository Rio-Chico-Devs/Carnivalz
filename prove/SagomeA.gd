extends RefCounted

# LE SAGOME DELLA STRADA A, PULITE E MISURABILI (le proposte della crescita,
# foto «statistiche»; i file per misurarle in art/interfaccia/statistiche/strada_a,
# il rapporto in docs/sagome_a.md).
#
# Bru, sulla tavola delle tre strade: «queste icone mi piacevano, bisognava solo
# migliorarle e renderle più precise e pulite». E poi: «puliscile e rendile
# perfette, devono passare un'analisi in cui io potrei misurare le geometrie, i
# tratti, i segmenti, la pienezza, lo spessore delle linee».
#
# Le idee sono quelle della strada A, una per una. Cambia la costruzione: ogni
# misura viene da un canone, e il canone si controlla (prove/Prove.gd,
# prova_le_sagome_a_si_misurano).
#
# IL CANONE
# - La griglia: 20 moduli per lato, il centro in 10,10. Il disegno sta fra 1 e
#   19: un modulo di margine. A 480 pixel un modulo e' 24 pixel.
# - Due spessori soli. Ogni vuoto (un taglio, un distacco fra due parti) e' largo
#   C = 1 modulo. Ogni parte sottile (un bordo, un'impugnatura, un raggio) e'
#   larga T = 2 moduli. Quello che separa un taglio dal bordo e' T.
# - Gli angoli: 0°, 90°, 45° e 135°; e, solo per il fulmine e la brace, la
#   pendenza 2 : 1 (63,43° e 116,57°).
# - Dritte. Niente piega del corsivo: la piega e' una deformazione, e
#   deformerebbe gli spessori (a 45° un tratto verrebbe piu' grosso del 10% e
#   quello opposto piu' sottile del 10%). Il manifesto lo da' l'ombra del timbro.
# - Le coordinate stanno sul mezzo modulo. Le uniche che non ci stanno sono
#   quelle fatte rientrando un bordo a 45° di T o di C: li' comanda la distanza
#   (si costruisce con Geometry2D.offset_polygon), come nella griglia fine di Mark
#   Holt per i pittogrammi di Monaco.
#
# COME E' FATTA UNA SAGOMA: anelli annidati, con la regola pari-dispari. Il
# livello 0 e' il pieno (le parti che si toccano sono gia' unite in una), il 1
# sono i tagli dentro il pieno, il 2 i pieni dentro i tagli (l'iride), il 3 i
# tagli dentro quelli (la pupilla). Disegnati in quest'ordine, inchiostro e
# fondo alternati, fanno la sagoma; scritti in un SVG con fill-rule evenodd,
# anche.

const LATO := 20.0          # la griglia, in moduli
const CENTRO := Vector2(10, 10)
const C := 1.0              # il taglio, ogni vuoto
const T := 2.0              # il tratto, ogni parte sottile
const MARGINE := 1.0
const PIXEL_PER_MODULO := 24  # nei file da misurare: 480 x 480
# le direzioni ammesse dei lati, in gradi fra 0 e 180
const ANGOLI := [0.0, 45.0, 63.43494882, 90.0, 116.5650512, 135.0]

const CHIAVI := ["hp", "attacco", "difesa", "velocita", "intelligenza", "forza_mentale", "fattore",
		"maestria_dominio", "aura"]
const NOMI := {"hp": "Punti vita", "attacco": "Attacco", "difesa": "Difesa", "velocita": "Velocità",
		"intelligenza": "Intelligenza", "forza_mentale": "Forza mentale", "fattore": "Fattore",
		"maestria_dominio": "Maestria del dominio", "aura": "Aura"}

static var memoria: Dictionary = {}   # chiave -> anelli: si costruiscono una volta


# --- le figure di base, in moduli ------------------------------------------------------

static func poli(xy: Array) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in range(0, xy.size(), 2):
		p.append(Vector2(float(xy[i]), float(xy[i + 1])))
	return p


static func rett(x0: float, y0: float, x1: float, y1: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x0, y0), Vector2(x1, y0), Vector2(x1, y1), Vector2(x0, y1)])


static func rombo(c: Vector2, r: float) -> PackedVector2Array:
	# r e' la mezza diagonale
	return PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])


static func ottagono(c: Vector2, apotema: float) -> PackedVector2Array:
	# l'ottagono regolare coi lati a 0, 45 e 90 gradi: l'apotema e' la distanza
	# dal centro a ogni lato
	var s := apotema * tan(PI / 8.0)
	return PackedVector2Array([c + Vector2(-s, -apotema), c + Vector2(s, -apotema), c + Vector2(apotema, -s),
			c + Vector2(apotema, s), c + Vector2(s, apotema), c + Vector2(-s, apotema), c + Vector2(-apotema, s),
			c + Vector2(-apotema, -s)])


static func ruota(p: PackedVector2Array, perno: Vector2, gradi: float) -> PackedVector2Array:
	var fuori := PackedVector2Array()
	for q in p:
		fuori.append(perno + (q - perno).rotated(deg_to_rad(gradi)))
	return fuori


static func sposta(p: PackedVector2Array, d: Vector2) -> PackedVector2Array:
	var fuori := PackedVector2Array()
	for q in p:
		fuori.append(q + d)
	return fuori


static func rientra(p: PackedVector2Array, d: float) -> PackedVector2Array:
	# la stessa figura coi lati spostati verso l'interno di d, gli spigoli vivi
	var dentro: Array[PackedVector2Array] = Geometry2D.offset_polygon(p, -d, Geometry2D.JOIN_MITER)
	return dentro[0] if not dentro.is_empty() else PackedVector2Array()


static func comune(a: PackedVector2Array, b: PackedVector2Array) -> PackedVector2Array:
	var pezzi: Array[PackedVector2Array] = Geometry2D.intersect_polygons(a, b)
	return pezzi[0] if not pezzi.is_empty() else PackedVector2Array()


static func banda(da: Vector2, a: Vector2, distanza_dal_bordo: float, larga: float, lunga: float) -> PackedVector2Array:
	# un taglio dritto parallelo al lato da -> a, rientrato di distanza_dal_bordo
	# verso destra del verso da -> a, centrato sul lato
	var lungo := (a - da).normalized()
	var verso_dentro := Vector2(-lungo.y, lungo.x)
	var meta := (da + a) * 0.5 + verso_dentro * (distanza_dal_bordo + larga * 0.5)
	var mezzo := lunga * 0.5
	return PackedVector2Array([meta - lungo * mezzo - verso_dentro * larga * 0.5,
			meta + lungo * mezzo - verso_dentro * larga * 0.5, meta + lungo * mezzo + verso_dentro * larga * 0.5,
			meta - lungo * mezzo + verso_dentro * larga * 0.5])


static func unisci(figure: Array) -> Array[PackedVector2Array]:
	# le figure che si toccano diventano una; quelle staccate restano staccate
	var fuori: Array[PackedVector2Array] = []
	for nuova: PackedVector2Array in figure:
		var corrente := nuova
		var restano: Array[PackedVector2Array] = []
		for altra in fuori:
			var unite: Array[PackedVector2Array] = Geometry2D.merge_polygons(corrente, altra)
			if unite.size() == 1:
				corrente = unite[0]
			else:
				restano.append(altra)
		restano.append(corrente)
		fuori = restano
	return fuori


# --- le nove sagome ----------------------------------------------------------------------
#
# Ognuna da' {livello: [figure]} e le parti col loro spessore, per il rapporto.

static func costruisci(chiave: String) -> Dictionary:
	var pieni: Array = []
	var tagli: Array = []
	var dentro: Array = []
	var fori: Array = []
	var parti: Array = []   # [cosa, quanto e' larga]
	match chiave:
		"hp":
			# il cuore coi lobi a spigoli: smusso 2,5, piano 2,5, fianco 2,5, la punta
			# a 45°. La luce e' un taglio C parallelo allo smusso sinistro, a T dal
			# bordo, lunga 1,5: cosi' anche i suoi capi stanno a T dal fianco e dal piano
			pieni.append(poli([10, 6, 12.5, 3.5, 15, 3.5, 17.5, 6, 17.5, 8.5, 10, 16, 2.5, 8.5, 2.5, 6, 5, 3.5, 7.5, 3.5]))
			tagli.append(banda(Vector2(2.5, 6), Vector2(5, 3.5), T, C, 1.5))
			parti.append_array([["luce (taglio)", C], ["luce, lunga", 1.5], ["fra la luce e il bordo", T]])
		"attacco":
			# la spada, costruita dritta e girata di 45°: la lama e' T + C + T (due
			# fili di T e la scanalatura di C) con la punta a 90°, la guardia larga
			# 11 e spessa T, l'impugnatura larga T, il pomo un rombo largo 5
			var spada: Array[PackedVector2Array] = [
				# i pezzi entrano un poco l'uno nell'altro, cosi' diventano una sagoma sola
				poli([0, -12.5, 2.5, -10, 2.5, 4, -2.5, 4, -2.5, -10]),
				rett(-5.5, 3, 5.5, 3 + T),
				rett(-T * 0.5, 4, T * 0.5, 8),
				rombo(Vector2(0, 9.5), 2.5),
			]
			var scanalatura := rett(-C * 0.5, -10 + T, C * 0.5, 3 - T)
			var mezzo_asse := Vector2(0, (-12.5 + 12.0) * 0.5)
			for pezzo in spada:
				pieni.append(sposta(ruota(sposta(pezzo, -mezzo_asse), Vector2.ZERO, 45.0), CENTRO))
			tagli.append(sposta(ruota(sposta(scanalatura, -mezzo_asse), Vector2.ZERO, 45.0), CENTRO))
			parti.append_array([["lama", T + C + T], ["scanalatura (taglio)", C], ["filo della lama", T],
					["guardia", T], ["impugnatura", T]])
		"difesa":
			# lo scudo: largo 12, smussi 1 in cima, i fianchi dritti, la punta a 45°. Lo
			# scaglione e' un taglio C a V, parallelo ai lati della punta e a 2T da
			# loro, che si ferma a T dai fianchi
			pieni.append(poli([5, 3, 15, 3, 16, 4, 16, 11, 10, 17, 4, 11, 4, 4]))
			var d1 := 2.0 * T * sqrt(2.0)
			var d2 := (2.0 * T + C) * sqrt(2.0)
			# la V fra le rette x+y = 27-d (a destra) e x-y = -7+d (a sinistra): i
			# lati della punta sono x+y = 27 e x-y = -7
			var v := PackedVector2Array([Vector2(10, 17 - d2), Vector2(30, -3 - d2), Vector2(30, -3 - d1),
					Vector2(10, 17 - d1), Vector2(-10, -3 - d1), Vector2(-10, -3 - d2)])
			tagli.append(comune(v, rett(4 + T, -5, 16 - T, 25)))
			parti.append_array([["scaglione (taglio)", C], ["fra lo scaglione e la punta", 2 * T],
					["fra lo scaglione e i fianchi", T]])
		"velocita":
			# il fulmine, simmetrico attorno al centro: i lati lunghi a 45°, quelli
			# corti a 2 : 1, i gradini orizzontali; le punte tronche larghe T + C,
			# le braccia larghe 7 al gradino
			pieni.append(poli([11, 1, 14, 1, 10, 9, 19, 9, 9, 19, 6, 19, 10, 11, 1, 11]))
			parti.append_array([["punta tronca", T + C], ["braccio, in orizzontale al gradino", 7.0]])
		"intelligenza":
			# l'occhio: la lente a 45°, il bordo T, il distacco C, l'iride un ottagono,
			# la pupilla un rombo
			var lente := poli([1, 10, 7, 4, 13, 4, 19, 10, 13, 16, 7, 16])
			pieni.append(lente)
			tagli.append(rientra(lente, T))
			dentro.append(ottagono(CENTRO, 6.0 - T - C))
			fori.append(rombo(CENTRO, 1.5))
			parti.append_array([["bordo della lente", T], ["fra il bordo e l'iride", C], ["iride, apotema", 6.0 - T - C],
					["pupilla, mezza diagonale", 1.5]])
		"forza_mentale":
			# la testa di profilo: la nuca, la fronte e il naso a 45°, e dentro il
			# rombo fermo della mente
			pieni.append(poli([7, 17, 7, 15, 4.5, 12.5, 4.5, 6, 8, 2.5, 12, 2.5, 15.5, 6, 15.5, 7.5, 17.5, 9.5,
					15.5, 9.5, 15.5, 12, 14, 13.5, 13, 13.5, 13, 17]))
			tagli.append(rombo(Vector2(10, 7.5), 2.5))
			parti.append_array([["la mente (taglio), mezza diagonale", 2.5]])
		"fattore":
			# la brace: due lingue a 2 : 1 e 45°, la base smussata; il cuore piu' caldo
			# e' la brace stessa rientrata di T, chiusa in cima da un cuneo a 2 : 1
			var brace := poli([10, 1, 13, 7, 15, 5, 17, 9, 17, 13, 12, 18, 8, 18, 3, 13, 3, 10.5, 5, 6.5, 6.5, 8])
			pieni.append(brace)
			var cuneo := PackedVector2Array([Vector2(10, 8.5), Vector2(20, 28.5), Vector2(0, 28.5)])
			tagli.append(comune(rientra(brace, T), cuneo))
			parti.append_array([["fra il cuore e il bordo", T]])
		"maestria_dominio":
			# la barra del dominio: tre segmenti larghi 5 e alti 7, distanti C; il
			# terzo, da riempire, e' un contorno di T con dentro un taglio di C; il
			# segno di dove sei, un triangolo a 45°, sta sopra il terzo, a C
			for i in 3:
				pieni.append(rett(1.5 + 6.0 * i, 8, 6.5 + 6.0 * i, 15))
			tagli.append(rett(13.5 + T, 8 + T, 18.5 - T, 15 - T))
			pieni.append(poli([14, 5, 18, 5, 16, 7]))
			parti.append_array([["segmento", 5.0], ["fra i segmenti", C], ["contorno del terzo", T],
					["dentro il terzo (taglio)", C], ["fra il segno e la barra", C]])
		"aura":
			# il rombo e la luce: quattro raggi lunghi sugli assi e quattro corti in
			# diagonale, tutti larghi T e staccati dal rombo di C
			var r := 5.0
			pieni.append(rombo(CENTRO, r))
			for i in 4:
				var lungo := rett(-T * 0.5, -9.0, T * 0.5, -(r + C))
				pieni.append(sposta(ruota(lungo, Vector2.ZERO, 90.0 * i), CENTRO))
				var da := r / sqrt(2.0) + C
				var corto := rett(-T * 0.5, -(da + 3.5), T * 0.5, -da)
				pieni.append(sposta(ruota(corto, Vector2.ZERO, 45.0 + 90.0 * i), CENTRO))
			parti.append_array([["raggio", T], ["fra i raggi e il rombo", C]])
	return {"0": unisci(pieni), "1": tagli, "2": dentro, "3": fori, "parti": parti}


static func anelli(chiave: String) -> Dictionary:
	if not memoria.has(chiave):
		memoria[chiave] = costruisci(chiave)
	return memoria[chiave]


# --- disegnarle --------------------------------------------------------------------------

static func punto(c: Vector2, l: float, q: Vector2) -> Vector2:
	# dai moduli ai pixel: l e' il lato della griglia di 20
	return c + (q - CENTRO) * (l / LATO)


static func figura(t: CanvasItem, c: Vector2, l: float, p: PackedVector2Array, tinta: Color) -> void:
	var fuori := PackedVector2Array()
	for q in p:
		fuori.append(punto(c, l, q))
	Manifesto.poligono(t, fuori, tinta)


static func disegna(t: CanvasItem, chiave: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		solo_sagoma := false) -> void:
	# l'inchiostro e il fondo alternati, livello per livello. Senza fondo (o per
	# l'ombra) solo il pieno: la sagoma
	var a := anelli(chiave)
	for livello in 4:
		if livello > 0 and (solo_sagoma or fondo.a <= 0.0):
			return
		for p: PackedVector2Array in a[str(livello)]:
			figura(t, c, l, p, tinta if livello % 2 == 0 else fondo)


static func timbro(t: CanvasItem, chiave: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		ombra := Color(0, 0, 0, 0)) -> void:
	# timbrata: l'ombra piena spostata in basso a destra di un modulo, poi la sagoma
	if ombra.a > 0.0:
		disegna(t, chiave, c + Vector2(1, 1) * l / LATO, l, ombra, ombra, true)
	disegna(t, chiave, c, l, tinta, fondo)


# --- misurarle -----------------------------------------------------------------------------

static func area(p: PackedVector2Array) -> float:
	var s := 0.0
	for i in p.size():
		s += p[i].cross(p[(i + 1) % p.size()])
	return absf(s) * 0.5


static func inchiostro(chiave: String) -> float:
	# l'area piena, in moduli quadrati: i pieni meno i tagli piu' i pieni dentro meno i fori
	var a := anelli(chiave)
	var totale := 0.0
	for livello in 4:
		for p: PackedVector2Array in a[str(livello)]:
			totale += area(p) * (1.0 if livello % 2 == 0 else -1.0)
	return totale


static func pienezza(chiave: String) -> float:
	# l'inchiostro sul quadrato dell'area viva (18 x 18)
	return inchiostro(chiave) / pow(LATO - 2.0 * MARGINE, 2.0)


static func ingombro(chiave: String) -> Rect2:
	var a := anelli(chiave)
	var r := Rect2()
	var primo := true
	for p: PackedVector2Array in a["0"]:
		for q in p:
			if primo:
				r = Rect2(q, Vector2.ZERO)
				primo = false
			else:
				r = r.expand(q)
	return r


static func tutti_gli_anelli(chiave: String) -> Array[PackedVector2Array]:
	var fuori: Array[PackedVector2Array] = []
	var a := anelli(chiave)
	for livello in 4:
		for p: PackedVector2Array in a[str(livello)]:
			fuori.append(p)
	return fuori


static func direzioni(chiave: String) -> Array[float]:
	# le direzioni dei lati, in gradi fra 0 e 180, senza ripetizioni (al centesimo)
	var viste: Array[float] = []
	for p in tutti_gli_anelli(chiave):
		for i in p.size():
			var d := p[(i + 1) % p.size()] - p[i]
			if d.length() < 1e-6:
				continue
			var g := fposmod(rad_to_deg(atan2(d.y, d.x)), 180.0)
			if absf(g - 180.0) < 0.005:
				g = 0.0
			var tondo := snappedf(g, 0.01)
			if tondo not in viste:
				viste.append(tondo)
	viste.sort()
	return viste


static func angolo_ammesso(g: float) -> bool:
	for a: float in ANGOLI:
		if absf(g - a) < 0.02:
			return true
	return false


static func distanza(a: PackedVector2Array, b: PackedVector2Array) -> float:
	# la distanza minima fra i bordi di due figure
	var minima := INF
	for i in a.size():
		var a0 := a[i]
		var a1 := a[(i + 1) % a.size()]
		for j in b.size():
			var b0 := b[j]
			var b1 := b[(j + 1) % b.size()]
			var punti_ab := Geometry2D.get_closest_points_between_segments(a0, a1, b0, b1)
			minima = minf(minima, punti_ab[0].distance_to(punti_ab[1]))
	return minima


static func spessori(chiave: String) -> Array:
	# le distanze misurate: ogni anello dal suo contenitore (lo spessore della
	# parete che li separa) e ogni pezzo dagli altri dello stesso livello (il
	# distacco). [descrizione, misura]
	var a := anelli(chiave)
	var fuori: Array = []
	var nomi := ["pieno", "taglio", "pieno dentro", "foro"]
	for livello in range(1, 4):
		for p: PackedVector2Array in a[str(livello)]:
			var vicino := INF
			for q: PackedVector2Array in a[str(livello - 1)]:
				vicino = minf(vicino, distanza(p, q))
			fuori.append(["%s dal %s che lo contiene" % [nomi[livello], nomi[livello - 1]], vicino])
	for livello in 4:
		var lista: Array = a[str(livello)]
		for i in lista.size():
			for j in range(i + 1, lista.size()):
				fuori.append(["fra due %s staccati" % nomi[livello], distanza(lista[i], lista[j])])
	return fuori


# --- scriverle -----------------------------------------------------------------------------

static func svg(chiave: String, colore := "#000000") -> String:
	# l'SVG da misurare: 480 x 480, un modulo 24 pixel, gli anelli in un percorso
	# solo con la regola pari-dispari
	var px := float(PIXEL_PER_MODULO)
	var lato := int(LATO * px)
	var d := ""
	for p in tutti_gli_anelli(chiave):
		for i in p.size():
			d += ("M" if i == 0 else "L") + "%s %s " % [numero(p[i].x * px), numero(p[i].y * px)]
		d += "Z "
	return ("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\">\n"
			+ "  <title>%s</title>\n"
			+ "  <path fill=\"%s\" fill-rule=\"evenodd\" d=\"%s\"/>\n</svg>\n") \
			% [lato, lato, lato, lato, NOMI[chiave], colore, d.strip_edges()]


static func numero(v: float) -> String:
	# al millesimo, senza zeri inutili
	var s := "%.3f" % v
	while s.ends_with("0"):
		s = s.left(-1)
	if s.ends_with("."):
		s = s.left(-1)
	return "0" if s == "-0" else s
