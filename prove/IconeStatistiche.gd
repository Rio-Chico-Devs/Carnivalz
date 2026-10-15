extends RefCounted

# LE ICONE DELLE STATISTICHE (proposte della crescita). Provvisorie come le
# proposte.
#
# Bru, sulle sagome A pulite: «si potrebbe passare un esame di misure ma non di
# design, non ricordano abbastanza quel che devono ricordare e non hanno quel
# qualcosa di design che per esempio combina due icone per crearne una che abbia
# una presenza più tematica invece di generica, poi le forme non sono belle da
# vedere». E poi: «prova adesso a renderle belle».
#
# Ogni icona e' due figure che ne fanno una terza, e le figure vengono dal mondo
# di Carnivalz (docs/storia.md: mondi che si deformano, squarci nella realta', il
# disallineamento che brucia, il trauma che diventa forza). Quali e perche': IDEE.
#
# Il disegno: griglia di 100, centro 50,50, area viva da 4 a 96. Curve vere
# dove servono (cerchi, archi, curve di Bezier), e due spessori: C = 5, ogni
# taglio e ogni distacco; T = 10, i bordi. Le figure si sommano e si sottraggono
# (Geometry2D), e si disegnano a strati: + inchiostro, - fondo. Il peso e'
# bilanciato a occhio e a misura (pienezza): tutte entro il 12% dalla media.
#
# I file da misurare (SVG e PNG 480 x 480) li scrive ./prove/icone.sh in
# art/interfaccia/statistiche/proposta/; la tavola e' TavolaIcone.

const LATO := 100.0
const CENTRO := Vector2(50, 50)
const C := 5.0
const T := 10.0
const CHIAVI := ["hp", "attacco", "difesa", "velocita", "intelligenza", "forza_mentale", "fattore",
		"maestria_dominio", "aura"]
const NOMI := {"hp": "Punti vita", "attacco": "Attacco", "difesa": "Difesa", "velocita": "Velocità",
		"intelligenza": "Intelligenza", "forza_mentale": "Forza mentale", "fattore": "Fattore",
		"maestria_dominio": "Maestria del dominio", "aura": "Aura"}
# le due figure, e cosa vogliono dire insieme
const IDEE := {
	"hp": ["il cuore", "la cicatrice cucita", "Chi tocca il confine e torna: il trauma ricucito è forza."],
	"attacco": ["la spada", "il fendente", "Il colpo lascia uno squarcio alle spalle della lama."],
	"difesa": ["lo scudo", "i merli", "L'unità è una struttura da difendere: lo scudo è una fortezza."],
	"velocita": ["il fulmine", "la sua eco", "La stampa slitta fuori registro: la scia è il disallineamento."],
	"intelligenza": ["l'occhio", "la serratura", "Vedere la via d'uscita: è la stat che fa fuggire."],
	"forza_mentale": ["la lanterna", "il fuoco", "La fiamma dietro il vetro, che lo stress non spegne."],
	"fattore": ["il fuoco", "l'emblema", "Nella fiamma, il rombo di Carnivalz: il disallineamento che arde in te."],
	"maestria_dominio": ["la corona", "la barra del dominio", "La fascia della corona sono i tre segmenti della barra."],
	"aura": ["la scintilla", "l'emblema", "L'energia che spendi, col rombo di Carnivalz nel cuore."],
}

const PIXEL := 4.8               # nei file da misurare: 100 unita' = 480 pixel

static var memoria: Dictionary = {}


# --- le figure ------------------------------------------------------------------------------

static func poli(xy: Array) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in range(0, xy.size(), 2):
		p.append(Vector2(float(xy[i]), float(xy[i + 1])))
	return p


static func rett(x0: float, y0: float, x1: float, y1: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x0, y0), Vector2(x1, y0), Vector2(x1, y1), Vector2(x0, y1)])


static func cerchio(c: Vector2, r: float, lati := 96) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in lati:
		p.append(c + Vector2.from_angle(TAU * i / lati) * r)
	return p


static func arco(c: Vector2, r: float, da_gradi: float, a_gradi: float, lati := 48) -> PackedVector2Array:
	# i punti di un arco, da un angolo all'altro (in gradi, in senso orario sullo schermo)
	var p := PackedVector2Array()
	for i in lati + 1:
		p.append(c + Vector2.from_angle(deg_to_rad(lerpf(da_gradi, a_gradi, float(i) / lati))) * r)
	return p


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


static func scala(p: PackedVector2Array, perno: Vector2, f: Vector2) -> PackedVector2Array:
	var fuori := PackedVector2Array()
	for q in p:
		fuori.append(perno + (q - perno) * f)
	return fuori


static func cresci(p: PackedVector2Array, d: float, tondo := false) -> PackedVector2Array:
	# la figura allargata (d > 0) o ristretta (d < 0)
	var r: Array[PackedVector2Array] = Geometry2D.offset_polygon(p, d,
			Geometry2D.JOIN_ROUND if tondo else Geometry2D.JOIN_MITER)
	var migliore := PackedVector2Array()
	for q in r:
		if not Geometry2D.is_polygon_clockwise(q) and area(q) > area(migliore):
			migliore = q
	return migliore


static func banda(linea: PackedVector2Array, larga: float, tondo := false) -> PackedVector2Array:
	# una linea spessa: la polilinea allargata di meta' spessore per parte
	var r: Array[PackedVector2Array] = Geometry2D.offset_polyline(linea, larga * 0.5,
			Geometry2D.JOIN_ROUND if tondo else Geometry2D.JOIN_MITER,
			Geometry2D.END_ROUND if tondo else Geometry2D.END_BUTT)
	return r[0] if not r.is_empty() else PackedVector2Array()


static func unione(figure: Array) -> PackedVector2Array:
	# figure che si toccano, una sola sagoma (la piu' grande, se ne restano di staccate)
	var tutto: PackedVector2Array = figure[0]
	for i in range(1, figure.size()):
		var r: Array[PackedVector2Array] = Geometry2D.merge_polygons(tutto, figure[i])
		var migliore := PackedVector2Array()
		for q in r:
			if not Geometry2D.is_polygon_clockwise(q) and area(q) > area(migliore):
				migliore = q
		tutto = migliore
	return tutto


static func meno(a: PackedVector2Array, b: PackedVector2Array) -> Array[PackedVector2Array]:
	# a senza b: i pezzi che restano (senza buchi: b deve toccare il bordo di a)
	var fuori: Array[PackedVector2Array] = []
	for q in Geometry2D.clip_polygons(a, b):
		if not Geometry2D.is_polygon_clockwise(q):
			fuori.append(q)
	return fuori


static func area(p: PackedVector2Array) -> float:
	var s := 0.0
	for i in p.size():
		s += p[i].cross(p[(i + 1) % p.size()])
	return absf(s) * 0.5


static func tangente(da: Vector2, centro: Vector2, r: float, verso: float) -> Vector2:
	# il punto del cerchio dove arriva la tangente da "da"; verso +1 o -1 sceglie il lato
	var d := da.distance_to(centro)
	var lungo := sqrt(maxf(d * d - r * r, 0.0))
	var angolo := asin(clampf(r / d, -1.0, 1.0)) * verso
	return da + (centro - da).normalized().rotated(angolo) * lungo


static func cuore(cx: float, alto: float, basso: float, d: float, r: float) -> PackedVector2Array:
	# due cerchi di raggio r coi centri a d dall'asse e alto di quota, e la punta
	# in basso: i lati sono le tangenti dalla punta ai cerchi
	var sx := Vector2(cx - d, alto)
	var dx := Vector2(cx + d, alto)
	var punta := Vector2(cx, basso)
	var t_sx := tangente(punta, sx, r, -1.0)
	var t_dx := tangente(punta, dx, r, 1.0)
	return unione([cerchio(sx, r), cerchio(dx, r), PackedVector2Array([punta, t_dx, dx, sx, t_sx])])


# --- le icone: una lista di strati, [+1 inchiostro / -1 fondo, figura] ---------------------------

static func strati(chiave: String) -> Array:
	# gli strati in ordine, l'ultimo sopra. Sono costruiti annidati: ogni taglio sta
	# dentro un pieno, ogni pieno dentro un taglio o sul fondo, e nessuno ne
	# accavalla un altro dello stesso segno; cosi' l'icona e' anche un percorso
	# solo, pari e dispari (svg)
	return progetto(chiave)["icona"]


static func due_figure(chiave: String) -> Array:
	# le due figure da cui nasce l'icona, ognuna coi suoi strati: per la tavola
	return [progetto(chiave)["a"], progetto(chiave)["b"]]


static func progetto(chiave: String) -> Dictionary:
	if not memoria.has(chiave):
		memoria[chiave] = costruisci(chiave)
	return memoria[chiave]


static func costruisci(chiave: String) -> Dictionary:
	var s: Array = []           # l'icona
	var a: Array = []           # la prima figura
	var b: Array = []           # la seconda
	match chiave:
		"hp":
			# il cuore e la cicatrice cucita: il taglio in diagonale, tre punti di traverso
			var c := cuore(50, 37, 88, 19, 21)
			var cicatrice: Array = [banda(poli([30, 30, 68, 68]), C)]
			for k: float in [0.2, 0.5, 0.8]:
				var q := Vector2(30, 30).lerp(Vector2(68, 68), k)
				cicatrice.append(banda(PackedVector2Array([q + Vector2(-7, 7), q + Vector2(7, -7)]), C))
			var cucitura := unione(cicatrice)
			s = [[1, c], [-1, cucitura]]
			a = [[1, c]]
			b = [[1, scala(cucitura, CENTRO, Vector2(1.3, 1.3))]]
		"attacco":
			# la spada di sbieco e il fendente: la mezzaluna del colpo alle sue spalle.
			# Costruita dritta (punta in su) e girata di 45°
			var lama := poli([50, -6, 59, 6, 59, 62, 41, 62, 41, 6])
			var guardia := poli([22, 62, 78, 62, 73, 72, 27, 72])
			var manico := rett(45, 70, 55, 90)
			var pomo := rett(43, 87, 57, 101)
			var spada := ruota(unione([lama, guardia, manico, pomo]), CENTRO, 45.0)
			var sguscio := ruota(banda(poli([50, 8, 50, 56]), C), CENTRO, 45.0)
			# la mezzaluna: il cerchio di fuori meno uno piu' grande spostato verso la
			# spada. Il cerchio di dentro passa per i due punti di quello di fuori che
			# stanno a 9 + C dall'asse: le punte finiscono a C dal filo della lama
			var fuori_r := 46.0
			var dall_asse := 9.0 + C
			var spessa := 14.0
			var lungo := sqrt(fuori_r * fuori_r - dall_asse * dall_asse)
			var dentro_r := fuori_r - spessa
			var k := (lungo * lungo + dall_asse * dall_asse - dentro_r * dentro_r) / (2.0 * (dentro_r - dall_asse))
			var dentro := cerchio(CENTRO + Vector2(1, 1).normalized() * k, dentro_r + k, 192)
			for pezzo in meno(cerchio(CENTRO, fuori_r, 192), dentro):
				s.append([1, pezzo])
				b.append([1, pezzo])
			s.append_array([[1, spada], [-1, sguscio]])
			a = [[1, spada], [-1, sguscio]]
		"difesa":
			# lo scudo e la fortezza: tre merli in cima, e la cinta (la sagoma rientrata
			# di T, staccata di C)
			var forma := scudo_a_punta(18, 82, 22, 94, 0.25)
			var torre := rett(18, 8, 82, 24)
			var scudo := unione([forma, torre])
			for x: float in [33.0, 57.0]:
				scudo = meno(scudo, rett(x, 0, x + 10, 8 + T))[0]
				torre = meno(torre, rett(x, 0, x + 10, 8 + T))[0]
			var dentro := cresci(forma, -T)
			var cinta := cresci(dentro, -C - 3)
			s = [[1, scudo], [-1, dentro], [1, cinta]]
			a = [[1, forma], [-1, dentro], [1, cinta]]
			b = [[1, unione([torre, rett(18, 24, 82, 56)])], [-1, rett(43, 36, 57, 56)]]
		"velocita":
			# il fulmine fuori registro: la copia spostata e' la scia, la stampa che
			# slitta come slitta la realta'. Della copia resta quello che sporge dal
			# fulmine allargato di C
			var fulmine := poli([48, 4, 78, 4, 64, 37, 82, 37, 42, 96, 52, 55, 32, 55])
			s = [[1, fulmine]]
			a = [[1, fulmine]]
			for resto in meno(sposta(fulmine, Vector2(-14, 0)), cresci(fulmine, C)):
				s.append([1, resto])
				b.append([1, resto])
		"intelligenza":
			# l'occhio e la serratura: vedere la via d'uscita (alza la fuga)
			var occhio := lente(CENTRO, 92, 62)
			var serratura := unione([cerchio(Vector2(50, 46), 6), poli([46, 48, 54, 48, 57, 63, 43, 63])])
			s = [[1, occhio], [-1, cresci(occhio, -T)], [1, cerchio(CENTRO, 21)], [-1, serratura]]
			a = [[1, occhio], [-1, cresci(occhio, -T)], [1, cerchio(CENTRO, 21)]]
			b = [[1, scala(serratura, Vector2(50, 54), Vector2(4, 4))]]
		"forza_mentale":
			# la lanterna e il fuoco: la fiamma che lo stress non spegne
			var tetto := poli([42, 18, 58, 18, 78, 30, 22, 30])
			var corpo := rett(27, 29, 73, 79)
			var base := poli([23, 78, 77, 78, 71, 90, 29, 90])
			var lanterna := unione([corpo, tetto, base, cerchio(Vector2(50, 12), 7, 48)])
			var vuoti: Array = [[-1, cerchio(Vector2(50, 12), 3, 32)], [-1, rett(27 + T, 29 + C + 1, 73 - T, 78 - C)]]
			s = [[1, lanterna]] + vuoti + [[1, fuoco(Vector2(50, 68), 28, 1.2)]]
			a = [[1, lanterna]] + vuoti
			b = [[1, fuoco(Vector2(50, 92), 84)]]
		"fattore":
			# il fuoco e, nel suo ventre, il rombo dell'emblema: il disallineamento che
			# arde. (Il rombo pieno col fuoco in negativo si confondeva con l'Aura)
			var fiamma := fuoco(Vector2(50, 94), 90, 1.25)
			s = [[1, fiamma], [-1, rombo(Vector2(50, 70), 10, 13)]]
			a = [[1, fiamma]]
			b = [[1, rombo(CENTRO, 30, 40)]]
		"maestria_dominio":
			# la corona, e la sua fascia e' la barra del dominio: tre segmenti di sbieco
			var punte := poli([14, 62, 14, 28, 32, 44, 50, 18, 68, 44, 86, 28, 86, 62])
			var corona := unione([punte, cerchio(Vector2(14, 24), 5.5, 32), cerchio(Vector2(50, 13.5), 5.5, 32),
					cerchio(Vector2(86, 24), 5.5, 32)])
			s = [[1, corona]]
			a = [[1, corona]]
			for i in 3:
				var x0 := 14.0 + i * (72.0 + C) / 3.0
				var x1 := x0 + (72.0 - 2.0 * C) / 3.0
				var sx := 3.0 if i > 0 else 0.0           # i fianchi della corona restano dritti
				var dx := 3.0 if i < 2 else 0.0
				var segmento := poli([x0 + sx, 62 + C, x1 + dx, 62 + C, x1 - dx, 81, x0 - sx, 81])
				s.append([1, segmento])
				b.append([1, scala(sposta(segmento, Vector2(0, -24)), CENTRO, Vector2(1.0, 1.6))])
		"aura":
			# la scintilla e, nel cuore, il rombo dell'emblema. I fianchi della
			# scintilla sono curve da punta a punta, tirate verso il centro
			var stella := PackedVector2Array()
			for i in 4:
				var da := CENTRO + Vector2.from_angle(deg_to_rad(-90.0 + i * 90.0)) * 46.0
				var verso := CENTRO + Vector2.from_angle(deg_to_rad(i * 90.0)) * 46.0
				var tratto := curva(da, CENTRO + Vector2.from_angle(deg_to_rad(-45.0 + i * 90.0)) * 18.0, verso)
				tratto.remove_at(tratto.size() - 1)
				stella.append_array(tratto)
			s = [[1, stella], [-1, rombo(CENTRO, 8, 11)]]
			a = [[1, stella]]
			b = [[1, rombo(CENTRO, 30, 40)]]
	return {"icona": s, "a": a, "b": b}


static func curva(a: Vector2, guida: Vector2, b: Vector2, lati := 24) -> PackedVector2Array:
	# la curva di Bezier quadratica da a a b, tirata verso "guida"
	var p := PackedVector2Array()
	for i in lati + 1:
		var k := float(i) / lati
		p.append(a.lerp(guida, k).lerp(guida.lerp(b, k), k))
	return p


static func curva3(a: Vector2, g1: Vector2, g2: Vector2, b: Vector2, lati := 24) -> PackedVector2Array:
	# la curva di Bezier cubica da a a b: parte verso g1, arriva da g2
	var p := PackedVector2Array()
	for i in lati + 1:
		var k := float(i) / lati
		var u := 1.0 - k
		p.append(a * u * u * u + g1 * 3.0 * u * u * k + g2 * 3.0 * u * k * k + b * k * k * k)
	return p


static func fuoco(c: Vector2, alto: float, largo := 1.0) -> PackedVector2Array:
	# il fuoco a due lingue, alto "alto", col fondo in c: il piede tondo, la lingua
	# grande che sale e si piega a destra, la piccola a sinistra, e fra le due la
	# tacca. Disegnato su un'altezza di 90 e poi scalato
	var k := alto / 90.0
	var r := 22.0
	var piede := Vector2(0, -r)
	var punta := Vector2(9, -90)
	var tacca := Vector2(-4, -42)
	var lingua := Vector2(-17, -65)
	var tratti: Array[PackedVector2Array] = [
		curva3(piede + Vector2(r, 0), Vector2(r, -46), Vector2(20, -74), punta),
		curva3(punta, Vector2(2, -74), Vector2(-6, -58), tacca),
		curva3(tacca, Vector2(-8, -50), Vector2(-12, -58), lingua),
		curva3(lingua, Vector2(-21, -56), Vector2(-r, -40), piede + Vector2(-r, 0)),
		arco(piede, r, 180.0, 0.0, 32),
	]
	var fuori := PackedVector2Array()
	for tratto in tratti:
		for i in tratto.size() - 1:
			fuori.append(c + tratto[i] * k * Vector2(largo, 1.0))
	return fuori


static func rombo(c: Vector2, mezzo_largo: float, mezzo_alto: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -mezzo_alto), c + Vector2(mezzo_largo, 0),
			c + Vector2(0, mezzo_alto), c + Vector2(-mezzo_largo, 0)])


static func lente(c: Vector2, largo: float, alto: float) -> PackedVector2Array:
	# la mandorla: due archi di cerchio che si incontrano nelle punte
	var mezzo := largo * 0.5
	var h := alto * 0.5
	var r := (mezzo * mezzo + h * h) / (2.0 * h)
	var giu := Vector2(c.x, c.y + r - h)
	var su := Vector2(c.x, c.y - r + h)
	var a := rad_to_deg(asin(mezzo / r))
	var p := arco(giu, r, -90.0 - a, -90.0 + a, 40)
	p.remove_at(p.size() - 1)
	var b := arco(su, r, 90.0 - a, 90.0 + a, 40)
	b.remove_at(b.size() - 1)
	p.append_array(b)
	return p


static func scudo_a_punta(x0: float, x1: float, alto: float, basso: float, dritto := 0.5) -> PackedVector2Array:
	# lo scudo: i fianchi dritti per la parte "dritto" dell'altezza, poi due archi
	# che continuano il fianco senza spigolo e si chiudono nella punta. Il centro di
	# ogni arco sta alla quota dove il fianco finisce, cosi' l'arco parte tangente
	var meta := lerpf(alto, basso, dritto)
	var asse := (x0 + x1) * 0.5
	var h := basso - meta
	var mezzo := (x1 - x0) * 0.5
	# il cerchio passa per (x1, meta) e per la punta (asse, basso)
	var dal_fianco := (mezzo * mezzo + h * h) / (2.0 * mezzo)
	var c_dx := Vector2(x1 - dal_fianco, meta)
	var c_sx := Vector2(x0 + dal_fianco, meta)
	var a := rad_to_deg((Vector2(asse, basso) - c_dx).angle())
	var p := PackedVector2Array([Vector2(x0, alto), Vector2(x1, alto)])
	p.append_array(arco(c_dx, dal_fianco, 0.0, a, 40))
	var sx := arco(c_sx, dal_fianco, 180.0 - a, 180.0, 40)
	sx.remove_at(0)
	p.append_array(sx)
	return p


# --- disegnarle -------------------------------------------------------------------------------

static func punto(c: Vector2, l: float, q: Vector2) -> Vector2:
	return c + (q - CENTRO) * (l / LATO)


static func figura(t: CanvasItem, c: Vector2, l: float, p: PackedVector2Array, tinta: Color) -> void:
	if p.size() < 3:
		return
	var fuori := PackedVector2Array()
	for q in p:
		fuori.append(punto(c, l, q))
	Manifesto.poligono(t, fuori, tinta)


static func disegna(t: CanvasItem, chiave: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		solo_sagoma := false) -> void:
	for strato: Array in strati(chiave):
		var segno := int(strato[0])
		if segno < 0 and (solo_sagoma or fondo.a <= 0.0):
			continue
		figura(t, c, l, strato[1], tinta if segno > 0 else fondo)


static func timbro(t: CanvasItem, chiave: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		ombra := Color(0, 0, 0, 0)) -> void:
	if ombra.a > 0.0:
		disegna(t, chiave, c + Vector2(1, 1) * l * 0.045, l, ombra, ombra, true)
	disegna(t, chiave, c, l, tinta, fondo)


# --- misurarle --------------------------------------------------------------------------------

static func inchiostro_in(chiave: String, q: Vector2) -> bool:
	# il punto e' d'inchiostro? Vince l'ultimo strato che lo contiene
	var pieno := false
	for strato: Array in strati(chiave):
		if Geometry2D.is_point_in_polygon(q, strato[1]):
			pieno = int(strato[0]) > 0
	return pieno


static func pari_e_dispari(chiave: String, q: Vector2) -> bool:
	# lo stesso punto letto come lo legge l'SVG: dentro un numero dispari di contorni
	var dentro := 0
	for strato: Array in strati(chiave):
		if Geometry2D.is_point_in_polygon(q, strato[1]):
			dentro += 1
	return dentro % 2 == 1


static func pienezza(chiave: String, passo := 0.5) -> float:
	# l'inchiostro sul quadrato di 100, contato su una griglia di punti
	var pieni := 0
	var tutti := 0
	var y := passo * 0.5
	while y < LATO:
		var x := passo * 0.5
		while x < LATO:
			tutti += 1
			if inchiostro_in(chiave, Vector2(x, y)):
				pieni += 1
			x += passo
		y += passo
	return float(pieni) / tutti


static func ingombro(chiave: String) -> Rect2:
	var r := Rect2()
	var primo := true
	for strato: Array in strati(chiave):
		if int(strato[0]) < 0:
			continue
		for q: Vector2 in strato[1]:
			if primo:
				r = Rect2(q, Vector2.ZERO)
				primo = false
			else:
				r = r.expand(q)
	return r


static func svg(chiave: String) -> String:
	# un percorso solo, pari e dispari, 480 x 480, nero su trasparente
	var d: Array[String] = []
	for strato: Array in strati(chiave):
		var p: PackedVector2Array = strato[1]
		var pezzi: Array[String] = []
		for i in p.size():
			pezzi.append("%s %s" % [String.num(p[i].x * PIXEL, 2), String.num(p[i].y * PIXEL, 2)])
		d.append("M" + " L".join(pezzi) + " Z")
	var lato := int(LATO * PIXEL)
	return ("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\">\n"
			+ "<title>%s</title>\n<path fill=\"#000\" fill-rule=\"evenodd\" d=\"%s\"/>\n</svg>\n") % [lato, lato,
			lato, lato, NOMI[chiave], " ".join(d)]
