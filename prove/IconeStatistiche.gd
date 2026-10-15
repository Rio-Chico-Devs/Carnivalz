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
# (Geometry2D), e si disegnano a strati: + inchiostro, - fondo.
#
# Le correzioni ottiche, misurate (TavolaMisure, la foto «misure»):
#   - il peso (pienezza) entro l'8% dalla media, la grandezza (raggio
#     d'inerzia) entro il 10%, il centro visivo entro 4 unita' dal centro;
#   - niente fili: due contorni o si toccano o stanno ad almeno un taglio;
#   - le fessure di sbieco larghe un taglio misurate di traverso (Holt);
#   - chiare su scuro, i tagli un decimo piu' larghi (l'irraggiamento).
# Piccole (sotto i 32 pixel) hanno i tagli piu' larghi, mai sotto 1,4 pixel; e
# timbrate hanno l'ombra di una sagoma sola, chiusa (taglio_per, chiusa).
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
	"aura": ["il vortice", "la scia", "L'energia che spendi sale dal vortice come una fiamma di spirito."],
}

const PIXEL := 4.8               # nei file da misurare: 100 unita' = 480 pixel

static var memoria: Dictionary = {}
# LE GUIDE DI COSTRUZIONE: mentre si costruisce un'icona a misura piena, i
# cerchi, i centri, le tangenti e i punti di controllo da cui nasce finiscono
# qui (la tavola «costruzione» le disegna sotto l'icona)
static var registra := false
static var guide: Array = []


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


static func posa(p: PackedVector2Array, z: float, gradi: float, d: Vector2) -> PackedVector2Array:
	# rimpicciolita di z attorno al centro, girata, spostata
	return sposta(ruota(scala(p, CENTRO, Vector2(z, z)), CENTRO, gradi), d)


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


static func cifra(v: float) -> String:
	# un numero all'italiana, con la virgola e senza zeri inutili: 20,5; 31; 63,6
	var t := String.num(snappedf(v, 0.1), 1)
	if t.ends_with(".0"):
		t = t.substr(0, t.length() - 2)
	return t.replace(".", ",")


static func guida(cosa: Array) -> void:
	# ["cerchio", centro, raggio] | ["segmento", da, a] | ["punto", p] | ["linea", punti] | ["nota", testo]
	if registra:
		guide.append(cosa)


static func cuore(cx: float, alto: float, basso: float, d: float, r: float) -> PackedVector2Array:
	# due cerchi di raggio r coi centri a d dall'asse e alto di quota, e la punta
	# in basso: i lati sono le tangenti dalla punta ai cerchi
	var sx := Vector2(cx - d, alto)
	var dx := Vector2(cx + d, alto)
	var punta := Vector2(cx, basso)
	var t_sx := tangente(punta, sx, r, -1.0)
	var t_dx := tangente(punta, dx, r, 1.0)
	for centro: Vector2 in [sx, dx]:
		guida(["cerchio", centro, r])
		guida(["punto", centro])
	guida(["segmento", punta, t_sx])
	guida(["segmento", punta, t_dx])
	guida(["punto", t_sx])
	guida(["punto", t_dx])
	guida(["nota", "Due cerchi di raggio %s coi centri a %s dall'asse; i lati sono le tangenti dalla punta." % [cifra(r),
			cifra(d)]])
	return unione([cerchio(sx, r), cerchio(dx, r), PackedVector2Array([punta, t_dx, dx, sx, t_sx])])


# --- le icone: una lista di strati, [+1 inchiostro / -1 fondo, figura] ---------------------------

static func strati(chiave: String, l := LATO) -> Array:
	# gli strati in ordine, l'ultimo sopra. Sono costruiti annidati: ogni taglio sta
	# dentro un pieno, ogni pieno dentro un taglio o sul fondo, e nessuno ne
	# accavalla un altro dello stesso segno; cosi' l'icona e' anche un percorso
	# solo, pari e dispari (svg). "l" e' il lato a cui la si disegna: piccola, i
	# tagli si allargano (taglio_per)
	return progetto(chiave, taglio_per(l))["icona"]


static func due_figure(chiave: String) -> Array:
	# le due figure da cui nasce l'icona, ognuna coi suoi strati: per la tavola
	return [progetto(chiave)["a"], progetto(chiave)["b"]]


static func taglio_per(l: float) -> float:
	# LE PICCOLE HANNO I TAGLI PIU' LARGHI. A 16 pixel un taglio di C e' 0,8
	# pixel: la sfumatura se lo mangia, e la spada col fendente diventa una
	# macchia. Sotto i 32 pixel il taglio cresce fino a restare largo 1,4 pixel
	# (a mezze unita', per non rifare il disegno a ogni misura)
	return maxf(C, ceilf(1.4 * LATO / maxf(l, 1.0) * 2.0) * 0.5)


static func progetto(chiave: String, taglio := C) -> Dictionary:
	var nome := "%s@%s" % [chiave, taglio]
	if not memoria.has(nome):
		memoria[nome] = costruisci(chiave, taglio)
	return memoria[nome]


static func costruisci(chiave: String, taglio := C) -> Dictionary:
	var s: Array = []           # l'icona
	var a: Array = []           # la prima figura
	var b: Array = []           # la seconda
	registra = taglio == C
	guide = []
	match chiave:
		"hp":
			# il cuore e la cicatrice cucita: il taglio in diagonale, tre punti di traverso
			var c := cuore(50, 37.5, 87, 18.5, 20.5)
			# piccola (taglio piu' largo) la cicatrice si accorcia: fra lei e il bordo
			# del cuore deve restare almeno un taglio d'inchiostro
			var di_piu := taglio - C
			var da := Vector2(33, 31) + Vector2(1, 1) * di_piu * 0.5
			var fino := Vector2(63, 61) - Vector2(1, 1) * di_piu * 0.5
			var mezzo_punto := 6.0 - di_piu * 0.5
			var cicatrice: Array = [banda(PackedVector2Array([da, fino]), taglio)]
			for k: float in [0.2, 0.5, 0.8]:
				var q := da.lerp(fino, k)
				cicatrice.append(banda(PackedVector2Array([q + Vector2(-1, 1) * mezzo_punto,
						q + Vector2(1, -1) * mezzo_punto]), taglio))
			var cucitura := unione(cicatrice)
			guida(["segmento", da, fino])
			guida(["nota", "La cicatrice a 45°, tre punti di traverso a 1/5, 1/2 e 4/5; tutta ad almeno un taglio dal bordo."])
			s = [[1, c], [-1, cucitura]]
			a = [[1, c]]
			b = [[1, scala(cucitura, CENTRO, Vector2(1.3, 1.3))]]
		"attacco":
			# la spada di sbieco e il fendente: la mezzaluna del colpo alle sue spalle.
			# Costruita dritta (punta in su), rimpicciolita di "z", girata di 45° e
			# spostata di "d": la falce sta in alto a sinistra e tirava la massa da
			# quella parte (il centro visivo era a -6,6, -4,9). I tagli non si
			# rimpiccioliscono
			var z := 0.9
			var d := Vector2(5.5, 4.0)
			var mezza := 11.0                   # mezza lama, prima di z
			var lama := poli([50, -10, 50 + mezza, 8, 50 + mezza, 62, 50 - mezza, 62, 50 - mezza, 8])
			var guardia := poli([27, 59, 73, 59, 68, 75, 32, 75])
			var manico := rett(44.5, 70, 55.5, 90)
			var pomo := rett(42.5, 87, 57.5, 102)
			var spada := posa(unione([lama, guardia, manico, pomo]), z, 45.0, d)
			var sguscio := sposta(ruota(banda(scala(poli([50, 9, 50, 56]), CENTRO, Vector2(z, z)), taglio), CENTRO, 45.0), d)
			# la mezzaluna: il cerchio di fuori meno uno piu' grande spostato verso la
			# spada. Il cerchio di dentro passa per i due punti di quello di fuori che
			# stanno a mezza lama + un taglio dall'asse: le punte finiscono a un taglio
			# dal filo della lama
			# la falce si scosta dall'asse di "e" verso l'alto a sinistra: senza, la
			# guardia (che sporge di traverso proprio verso di lei) le arrivava a 2
			var e := 5.5 + (taglio - C) * 0.6
			var fuori_r := 44.0 * z
			var dall_asse := mezza * z + taglio - e
			var spessa := 18.0
			var lungo := sqrt(fuori_r * fuori_r - dall_asse * dall_asse)
			var dentro_r := fuori_r - spessa
			var k := (lungo * lungo + dall_asse * dall_asse - dentro_r * dentro_r) / (2.0 * (dentro_r - dall_asse))
			var luna := CENTRO + d - Vector2(1, 1).normalized() * e
			var dentro := cerchio(luna + Vector2(1, 1).normalized() * k, dentro_r + k, 192)
			var asse := posa(poli([50, -10, 50, 102]), z, 45.0, d)
			guida(["segmento", asse[0], asse[1]])
			guida(["cerchio", luna, fuori_r])
			guida(["punto", luna])
			guida(["cerchio", luna + Vector2(1, 1).normalized() * k, dentro_r + k])
			guida(["punto", luna + Vector2(1, 1).normalized() * k])
			var lungo_asse := (asse[0] - asse[1]).normalized()
			var di_traverso := Vector2(-1, -1).normalized()
			for verso: float in [-1.0, 1.0]:
				guida(["punto", luna + lungo_asse * lungo * verso + di_traverso * dall_asse])
			guida(["nota", "La spada costruita dritta e girata di 45°. La falce: un cerchio di raggio %s meno uno di %s; le punte a un taglio dal filo della lama, il centro scostato di %s dall'asse."
					% [cifra(fuori_r), cifra(dentro_r + k), cifra(e)]])
			for pezzo in meno(cerchio(luna, fuori_r, 192), dentro):
				s.append([1, pezzo])
				b.append([1, pezzo])
			# la scanalatura e' un dettaglio da grande: piccola, il filo di lama ai suoi
			# lati scenderebbe sotto il pixel
			s.append([1, spada])
			if taglio <= 7.0:
				s.append([-1, sguscio])
			a = [[1, spada], [-1, sguscio]]
		"difesa":
			# lo scudo e la fortezza: tre merli in cima, e la cinta (la sagoma rientrata
			# di T, staccata di C)
			# tre merli uguali di 14 e due feritoie di 9 su una larghezza di 60. La
			# sagoma dello scudo parte da 20, cosi' sotto le feritoie il muro e' alto
			# T come i fianchi (partiva da 24: in cima il muro era 14)
			var forma := scudo_a_punta(20, 80, 20, 92, 0.25)
			var torre := rett(20, 10, 80, 26)
			var scudo := unione([forma, torre])
			for x: float in [34.0, 57.0]:
				scudo = meno(scudo, rett(x, 0, x + 9, 10 + T))[0]
				torre = meno(torre, rett(x, 0, x + 9, 10 + T))[0]
			var dentro := cresci(forma, -T)
			var cinta := cresci(dentro, -taglio - 3)
			s = [[1, scudo], [-1, dentro], [1, cinta]]
			a = [[1, forma], [-1, dentro], [1, cinta]]
			b = [[1, unione([torre, rett(20, 26, 80, 58)])], [-1, rett(43, 38, 57, 58)]]
		"velocita":
			# il fulmine fuori registro: la copia spostata e' la scia, la stampa che
			# slitta come slitta la realta'. Della copia resta il pezzo grande che
			# sporge dal fulmine allargato di un taglio: la lama sottile che sporgeva
			# sotto, a 16 pixel, era una sbavatura
			# i fianchi lunghi tutti alla stessa pendenza; il gradino di destra piu'
			# alto di quello di sinistra, come nel fulmine classico. La punta in basso
			# tira la massa in alto: il fulmine parte da 8 e non da 4, e si allarga
			# (x 1,12) per non sembrare piu' piccolo degli altri
			var fulmine := scala(poli([46, 8, 77, 8, 64.33, 46, 86, 46, 38, 96, 50.67, 58, 29.33, 58]), CENTRO,
					Vector2(1.16, 1.0))
			s = [[1, fulmine]]
			a = [[1, fulmine]]
			# i fianchi lunghi, prolungati: sono paralleli
			for lato: Array in [[0, 6], [1, 2], [4, 5], [3, 4]]:
				var p0: Vector2 = fulmine[lato[0]]
				var p1: Vector2 = fulmine[lato[1]]
				var verso := (p1 - p0).normalized()
				guida(["segmento", p0 - verso * 12.0, p1 + verso * 12.0])
			guida(["segmento", fulmine[0], fulmine[0] + Vector2(-15, 0)])
			guida(["nota", "I fianchi lunghi paralleli. La copia spostata di 15 a sinistra; ne resta il pezzo grande, staccato di un taglio."])
			var scia := PackedVector2Array()
			for resto in meno(sposta(fulmine, Vector2(-15, 0)), cresci(fulmine, taglio)):
				if area(resto) > area(scia):
					scia = resto
			s.append([1, scia])
			b.append([1, scia])
		"intelligenza":
			# l'occhio e la serratura: vedere la via d'uscita (alza la fuga)
			# l'iride tocca le palpebre: il bianco dell'occhio sono due pezzi, a
			# sinistra e a destra, e iride e palpebre un pieno solo (un filo fra
			# l'iride e le palpebre, da piccola, si impasta)
			var occhio := lente(CENTRO, 92, 60)
			var serratura := scala(unione([cerchio(Vector2(50, 46), 6), poli([46, 48, 54, 48, 57, 63, 43, 63])]),
					Vector2(50, 54), Vector2.ONE * (1.0 - (taglio - C) * 0.05))
			guida(["cerchio", CENTRO, 21])
			guida(["cerchio", Vector2(50, 46), 6])
			guida(["nota", "La mandorla: due archi di cerchio; il bordo spesso T; l'iride di raggio 21 tocca le palpebre, la serratura è un cerchio di 6 e un trapezio."])
			s = [[1, occhio]]
			for bianco in meno(cresci(occhio, -T), cerchio(CENTRO, 21)):
				s.append([-1, bianco])
			a = s.duplicate()
			s.append([-1, serratura])
			b = [[1, scala(serratura, Vector2(50, 54), Vector2(4, 4))]]
		"forza_mentale":
			# la lanterna e il fuoco: la fiamma che lo stress non spegne
			var tetto := poli([41, 17, 59, 17, 79, 30, 21, 30])
			var corpo := rett(26, 29, 74, 79)
			var base := poli([22, 78, 78, 78, 72, 91, 28, 91])
			var lanterna := unione([corpo, tetto, base, cerchio(Vector2(50, 12), 8, 96)])
			# l'anello e' spesso un taglio: piccola diventa una palla piena
			var vuoti: Array = [[-1, rett(26 + T, 29 + C + 1, 74 - T, 78 - C)]]
			if taglio <= 7.0:
				vuoti.push_front([-1, cerchio(Vector2(50, 12), 3, 96)])
			# la fiamma sta a C dal vetro; se il taglio cresce (piccola) si stringe lei
			var alta := 28.0 - 2.0 * (taglio - C)
			guida(["linea", corpo + PackedVector2Array([corpo[0]])])
			guida(["cerchio", Vector2(50, 12), 8])
			guida(["linea", rett(26 + T, 29 + C + 1, 74 - T, 78 - C) + PackedVector2Array([Vector2(26 + T, 29 + C + 1)])])
			guida(["nota", "I montanti spessi T, i traversi C. L'anello spesso un taglio. La fiamma a un taglio dal vetro."])
			registra = false
			s = [[1, lanterna]] + vuoti + [[1, fuoco(Vector2(50, 54 + alta * 0.5), alta, 1.2)]]
			registra = false
			a = [[1, lanterna]] + vuoti
			b = [[1, fuoco(Vector2(50, 92), 84)]]
		"fattore":
			# il fuoco e, nel suo ventre, il rombo dell'emblema: il disallineamento che
			# arde. (Il rombo pieno col fuoco in negativo si confondeva con l'Aura)
			var fiamma := fuoco(Vector2(50, 92), 88, 1.25)
			var piccolo := 1.0 - (taglio - C) * 0.04          # piccola, il rombo si stringe
			guida(["punto", Vector2(50, 70)])
			guida(["nota", "Il fuoco: quattro curve cubiche (in arancio i loro punti di controllo) e il piede tondo; il rombo dell'emblema al centro del piede."])
			s = [[1, fiamma], [-1, rombo(Vector2(50, 70), 10 * piccolo, 13 * piccolo)]]
			registra = false
			a = [[1, fiamma]]
			b = [[1, rombo(CENTRO, 30, 40)]]
		"maestria_dominio":
			# la corona, e la sua fascia e' la barra del dominio: tre segmenti di sbieco
			var punte := poli([14, 62, 14, 28, 32, 44, 50, 18, 68, 44, 86, 28, 86, 62])
			var corona := unione([punte, cerchio(Vector2(14, 24), 5, 32), cerchio(Vector2(50, 14), 5, 32),
					cerchio(Vector2(86, 24), 5, 32)])
			for centro: Vector2 in [Vector2(14, 24), Vector2(50, 14), Vector2(86, 24)]:
				guida(["cerchio", centro, 5])
			guida(["linea", poli([14, 28, 32, 44, 50, 18, 68, 44, 86, 28])])
			guida(["nota", "Tre punte con le palle di raggio 5. La fascia in tre segmenti uguali; le fessure di sbieco (6 su 13) sono larghe un taglio misurate di traverso."])
			s = [[1, corona]]
			a = [[1, corona]]
			# le fessure sono di sbieco (3 su 13 per parte): larghe un taglio misurate di
			# traverso, non in orizzontale (la regola di Holt), quindi un po' di piu'
			var alta := 80.0 - 62.0 - taglio
			var fessura := taglio * Vector2(6.0, alta).length() / alta
			for i in 3:
				var x0 := 14.0 + i * (72.0 + fessura) / 3.0
				var x1 := x0 + (72.0 - 2.0 * fessura) / 3.0
				var sx := 3.0 if i > 0 else 0.0           # i fianchi della corona restano dritti
				var dx := 3.0 if i < 2 else 0.0
				var segmento := poli([x0 + sx, 62 + taglio, x1 + dx, 62 + taglio, x1 - dx, 80, x0 - sx, 80])
				if i < 2:
					guida(["segmento", Vector2(x1 + dx, 62 + taglio) + Vector2(6, -alta) * 0.6, Vector2(x1 - dx, 80) - Vector2(6, -alta) * 0.6])
				s.append([1, segmento])
				b.append([1, scala(sposta(segmento, Vector2(0, -24)), CENTRO, Vector2(1.0, 1.6))])
		"aura":
			# il vortice e la scia: un tratto solo che si avvolge in basso e sale a
			# punta, come una fiamma di spirito (lo hitodama). L'idea e' di Bru: il
			# segno sulla pancia di Jalhalla, capovolto; qui ridisegnato da capo
			var r := ricciolo(Vector2(64, 55), 31, 10, 295, Vector2(50, 4), 33, 3, 0.42)
			s = [[1, r]]
			registra = false
			a = [[1, ricciolo(Vector2(54, 58), 30, 10, 330, Vector2(30, 38), 22, 4, 0.12)]]
			var sx := curva3(Vector2(62, 4), Vector2(44, 30), Vector2(30, 60), Vector2(38, 94))
			var dx := curva3(Vector2(58, 94), Vector2(52, 62), Vector2(56, 30), Vector2(62, 4))
			b = [[1, sx.slice(0, sx.size() - 1) + dx.slice(0, dx.size() - 1)]]
	registra = false
	var pieni: Array = []
	for strato: Array in s:
		if int(strato[0]) > 0:
			pieni.append(strato[1])
	return {"icona": s, "a": a, "b": b, "ombra": chiusa(pieni, taglio * 0.6 + 0.5), "guide": guide.duplicate()}


static func chiusa(figure: Array, g: float) -> Array[PackedVector2Array]:
	# L'OMBRA DEL TIMBRO E' UNA SAGOMA SOLA. Le figure allargate di g finche' si
	# toccano, fuse, e ristrette di g: i vuoti stretti fra un pezzo e l'altro (la
	# fascia della corona, la falce e la spada, la scia del fulmine) si chiudono,
	# e nei vuoti non lampeggia l'arancio a righe. Il contorno di fuori resta quello
	var pezzi: Array[PackedVector2Array] = []
	for f: PackedVector2Array in figure:
		pezzi.append(cresci(f, g))
	var fuso := true
	while fuso:
		fuso = false
		for i in pezzi.size():
			for j in range(i + 1, pezzi.size()):
				if not Geometry2D.intersect_polygons(pezzi[i], pezzi[j]).is_empty():
					pezzi[i] = unione([pezzi[i], pezzi[j]])
					pezzi.remove_at(j)
					fuso = true
					break
			if fuso:
				break
	var fuori: Array[PackedVector2Array] = []
	for p in pezzi:
		var stretta := cresci(p, -g)
		if stretta.size() >= 3:
			fuori.append(stretta)
	return fuori


static func curva(a: Vector2, tira: Vector2, b: Vector2, lati := 24) -> PackedVector2Array:
	# la curva di Bezier quadratica da a a b, tirata verso "tira"
	var p := PackedVector2Array()
	for i in lati + 1:
		var k := float(i) / lati
		p.append(a.lerp(tira, k).lerp(tira.lerp(b, k), k))
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
	# le guide: i poligoni di controllo delle quattro cubiche e il cerchio del piede
	var qui := func(q: Vector2) -> Vector2: return c + q * k * Vector2(largo, 1.0)
	for controllo: Array in [[piede + Vector2(r, 0), Vector2(r, -46), Vector2(20, -74), punta],
			[punta, Vector2(2, -74), Vector2(-6, -58), tacca], [tacca, Vector2(-8, -50), Vector2(-12, -58), lingua],
			[lingua, Vector2(-21, -56), Vector2(-r, -40), piede + Vector2(-r, 0)]]:
		guida(["segmento", qui.call(controllo[0]), qui.call(controllo[1])])
		guida(["segmento", qui.call(controllo[2]), qui.call(controllo[3])])
		guida(["punto", qui.call(controllo[1])])
		guida(["punto", qui.call(controllo[2])])
	if is_equal_approx(largo, 1.0):
		guida(["cerchio", qui.call(piede), r * k])
	# nel verso delle altre figure: Geometry2D allarga e restringe solo quelle
	if Geometry2D.is_polygon_clockwise(fuori):
		fuori.reverse()
	return fuori


static func rombo(c: Vector2, mezzo_largo: float, mezzo_alto: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -mezzo_alto), c + Vector2(mezzo_largo, 0),
			c + Vector2(0, mezzo_alto), c + Vector2(-mezzo_largo, 0)])


static func ricciolo(occhio: Vector2, r0: float, r1: float, giro: float, punta: Vector2, largo: float,
		fine: float, coda := 0.5) -> PackedVector2Array:
	# IL RICCIOLO CON LA CODA: un tratto solo, largo "largo", che nasce a punta in
	# "punta", scende e si avvolge attorno a "occhio". La linea di mezzo e' la coda
	# (una cubica che arriva tangente all'attacco, a sinistra dell'occhio) e poi una
	# spirale logaritmica che gira di "giro" gradi, da sinistra verso il basso, a
	# destra e su, stringendosi da r0 a r1. Lo spessore cresce in fretta lungo la
	# coda, poi cala fino a "fine", e il tratto finisce tondo. "coda" e' quanto
	# della lunghezza tocca alla coda
	var spirale := PackedVector2Array()
	for i in 97:
		var k := i / 96.0
		spirale.append(occhio + Vector2.from_angle(deg_to_rad(180.0 - giro * k)) * r0 * pow(r1 / r0, k))
	# la coda arriva nella direzione in cui la spirale parte: niente gomito
	var attacco := spirale[0]
	var parte := (spirale[1] - spirale[0]).normalized()
	var linea := curva3(punta, punta + Vector2(r0 * 0.35, (attacco.y - punta.y) * 0.4),
			attacco - parte * r0 * 1.1, attacco, 40)
	linea.append_array(spirale.slice(1))
	var lungo := PackedFloat32Array([0.0])
	for i in range(1, linea.size()):
		lungo.append(lungo[i - 1] + linea[i].distance_to(linea[i - 1]))
	var tutto := lungo[lungo.size() - 1]
	var sx := PackedVector2Array()
	var dx := PackedVector2Array()
	var ultima := Vector2.ZERO
	for i in linea.size():
		var u := lungo[i] / tutto
		# lo spessore sale e scende senza spigoli: un gomito nella sua crescita
		# diventa un gomito nel contorno (si vedeva dove la coda entra nel ricciolo)
		var spesso := 0.0
		if u < coda:
			spesso = largo * pow(sin(u / coda * PI * 0.5), 1.5)
		else:
			spesso = lerpf(largo, fine, smoothstep(0.0, 1.0, (u - coda) / (1.0 - coda)))
		var verso := (linea[mini(i + 1, linea.size() - 1)] - linea[maxi(i - 1, 0)]).normalized()
		ultima = verso.orthogonal()
		sx.append(linea[i] + ultima * spesso * 0.5)
		dx.append(linea[i] - ultima * spesso * 0.5)
	guida(["linea", linea])
	guida(["punto", occhio])
	guida(["cerchio", occhio, r0])
	guida(["segmento", punta, punta + Vector2(r0 * 0.35, (attacco.y - punta.y) * 0.4)])
	guida(["segmento", attacco - parte * r0 * 1.1, attacco])
	guida(["nota", "La linea di mezzo: una cubica e una spirale logaritmica (da raggio %s a %s in %s°). Lo spessore sale fino a %s e cala liscio."
			% [cifra(r0), cifra(r1), cifra(giro), cifra(largo)]])
	var p := sx
	var testa := arco(linea[linea.size() - 1], fine * 0.5, rad_to_deg(ultima.angle()), rad_to_deg(ultima.angle()) + 180.0, 16)
	p.append_array(testa.slice(1, testa.size() - 1))
	dx.reverse()
	p.append_array(dx.slice(0, dx.size() - 1))
	if Geometry2D.is_polygon_clockwise(p):
		p.reverse()
	return p


static func lente(c: Vector2, largo: float, alto: float) -> PackedVector2Array:
	# la mandorla: due archi di cerchio che si incontrano nelle punte
	var mezzo := largo * 0.5
	var h := alto * 0.5
	var r := (mezzo * mezzo + h * h) / (2.0 * h)
	var giu := Vector2(c.x, c.y + r - h)
	var su := Vector2(c.x, c.y - r + h)
	var a := rad_to_deg(asin(mezzo / r))
	guida(["cerchio", giu, r])
	guida(["cerchio", su, r])
	guida(["punto", giu])
	guida(["punto", su])
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
	guida(["cerchio", c_dx, dal_fianco])
	guida(["cerchio", c_sx, dal_fianco])
	guida(["punto", Vector2(x0, meta)])
	guida(["punto", Vector2(x1, meta)])
	guida(["punto", Vector2(asse, basso)])
	guida(["nota", "I fianchi dritti, poi due archi di raggio %s che partono tangenti e si chiudono nella punta." % cifra(dal_fianco)])
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


static func taglio_a_colori(l: float, tinta: Color, fondo: Color) -> float:
	# L'IRRAGGIAMENTO: chiaro su scuro, l'inchiostro chiaro sembra allargarsi e i
	# tagli scuri stringersi (Paget, le correzioni ottiche: la versione chiara va
	# assottigliata). Qui i tagli crescono di un decimo, a mezze unita'
	var taglio := taglio_per(l)
	if fondo.a > 0.0 and tinta.get_luminance() > fondo.get_luminance():
		taglio = ceilf(taglio * 1.1 * 2.0) * 0.5
	return taglio


static func disegna(t: CanvasItem, chiave: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		solo_sagoma := false) -> void:
	for strato: Array in progetto(chiave, taglio_a_colori(l, tinta, fondo))["icona"]:
		var segno := int(strato[0])
		if segno < 0 and (solo_sagoma or fondo.a <= 0.0):
			continue
		figura(t, c, l, strato[1], tinta if segno > 0 else fondo)


static func timbro(t: CanvasItem, chiave: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		ombra := Color(0, 0, 0, 0)) -> void:
	# l'ombra e' la sagoma chiusa, spostata; sopra, la stessa sagoma col colore del
	# fondo: i vuoti fra i pezzi restano del fondo come i tagli, e l'arancio si
	# vede solo fuori dal contorno
	var chiusa_qui: Array = progetto(chiave, taglio_a_colori(l, tinta, fondo))["ombra"]
	if ombra.a > 0.0:
		for p: PackedVector2Array in chiusa_qui:
			figura(t, c + Vector2(1, 1) * l * 0.045, l, p, ombra)
		if fondo.a > 0.0:
			for p: PackedVector2Array in chiusa_qui:
				figura(t, c, l, p, fondo)
	disegna(t, chiave, c, l, tinta, fondo)


# --- misurarle --------------------------------------------------------------------------------

static func inchiostro_in(chiave: String, q: Vector2, l := LATO) -> bool:
	# il punto e' d'inchiostro? Vince l'ultimo strato che lo contiene
	var pieno := false
	for strato: Array in strati(chiave, l):
		if Geometry2D.is_point_in_polygon(q, strato[1]):
			pieno = int(strato[0]) > 0
	return pieno


static func pari_e_dispari(chiave: String, q: Vector2, l := LATO) -> bool:
	# lo stesso punto letto come lo legge l'SVG: dentro un numero dispari di contorni
	var dentro := 0
	for strato: Array in strati(chiave, l):
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


static func griglia_inchiostro(chiave: String, passo := 1.0) -> PackedByteArray:
	# l'inchiostro su una griglia di punti (al centro di ogni cella), riga per riga
	var nome := "griglia %s %s" % [chiave, passo]
	if not memoria.has(nome):
		var celle := PackedByteArray()
		var lato := int(LATO / passo)
		for y in lato:
			for x in lato:
				celle.append(1 if inchiostro_in(chiave, Vector2(x + 0.5, y + 0.5) * passo) else 0)
		memoria[nome] = celle
	return memoria[nome]


static func baricentro(chiave: String, passo := 1.0) -> Vector2:
	# il centro della massa d'inchiostro
	var celle := griglia_inchiostro(chiave, passo)
	var lato := int(LATO / passo)
	var somma := Vector2.ZERO
	var n := 0
	for i in celle.size():
		if celle[i] == 1:
			somma += Vector2(i % lato + 0.5, floorf(float(i) / lato) + 0.5) * passo
			n += 1
	return somma / maxf(n, 1.0)


static func raggio_inerzia(chiave: String, passo := 1.0) -> float:
	# quanto la massa e' sparsa attorno al suo centro: la radice della distanza
	# quadra media. Due icone con la stessa pienezza e raggi diversi non
	# sembrano grandi uguali
	var celle := griglia_inchiostro(chiave, passo)
	var lato := int(LATO / passo)
	var g := baricentro(chiave, passo)
	var somma := 0.0
	var n := 0
	for i in celle.size():
		if celle[i] == 1:
			somma += (Vector2(i % lato + 0.5, floorf(float(i) / lato) + 0.5) * passo - g).length_squared()
			n += 1
	return sqrt(somma / maxf(n, 1.0))


static func centro_visivo(chiave: String) -> Vector2:
	# dove l'occhio mette il centro: a meta' fra il centro dell'ingombro (che
	# conta le punte) e il baricentro (che conta la massa). Una regola di mestiere,
	# non una legge: serve a vedere chi e' fuori posto, poi decide l'occhio
	return ingombro(chiave).get_center().lerp(baricentro(chiave), 0.5)


static func distanza(a: PackedVector2Array, b: PackedVector2Array) -> float:
	# la distanza piu' corta fra i due contorni (0 se si toccano o si tagliano)
	var meglio := INF
	for i in a.size():
		var a0 := a[i]
		var a1 := a[(i + 1) % a.size()]
		for j in b.size():
			var vicini := Geometry2D.get_closest_points_between_segments(a0, a1, b[j], b[(j + 1) % b.size()])
			meglio = minf(meglio, vicini[0].distance_to(vicini[1]))
	return meglio


static func distacchi(chiave: String, taglio := C) -> Array:
	# TUTTE LE DISTANZE FRA I PEZZI, come [descrizione, distanza]: ogni strato dal
	# contorno di segno opposto che lo contiene, e i pezzi dello stesso segno che
	# stanno uno accanto all'altro. Servono a una regola sola: due contorni o si
	# toccano (0) o stanno ad almeno un taglio. Nel mezzo c'e' il filo sottile che
	# da piccola si impasta
	var s: Array = progetto(chiave, taglio)["icona"]
	var fuori: Array = []
	for i in s.size():
		var p: PackedVector2Array = s[i][1]
		var segno := int(s[i][0])
		for j in range(i - 1, -1, -1):
			if int(s[j][0]) != segno and Geometry2D.is_point_in_polygon(p[0], s[j][1]):
				fuori.append(["%d dentro %d" % [i, j], distanza(p, s[j][1])])
				break
		for j in range(i):
			if int(s[j][0]) == segno and not Geometry2D.is_point_in_polygon(p[0], s[j][1]) \
					and not Geometry2D.is_point_in_polygon((s[j][1] as PackedVector2Array)[0], p):
				fuori.append(["%d accanto a %d" % [i, j], distanza(p, s[j][1])])
	return fuori


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
