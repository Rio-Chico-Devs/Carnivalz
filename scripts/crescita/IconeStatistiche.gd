extends RefCounted

# LE ICONE DELLE STATISTICHE della crescita (SchedaCrescita, e le proposte in
# prove/). Provvisorie: quelle vere le disegna Bru (docs/icone_da_disegnare.md).
#
# Bru, sulle sagome A pulite: «si potrebbe passare un esame di misure ma non di
# design, non ricordano abbastanza quel che devono ricordare e non hanno quel
# qualcosa di design che per esempio combina due icone per crearne una che abbia
# una presenza più tematica invece di generica, poi le forme non sono belle da
# vedere». E poi: «prova adesso a renderle belle».
#
# Ogni icona e' due figure che ne fanno una terza, e le figure vengono dal mondo
# di Carnivalz (docs/storia.md: la fiera, le maschere, il rombo dell'emblema, il
# disallineamento che brucia, il trauma che diventa forza). Quali e perche': IDEE.
#
# Bru, sulla revisione: «le icone che effettivamente sono migliorate sono:
# intelligenza e le frecce [...] come ti viene in mente di mettere la cicatrice
# in mezzo al cuore? [...] l'aura non è perfettamente curvilinea sembra abbia
# bozzi [...] l'icona attacco è totalmente da rifare [...] la lanterna [...] la
# fiamma, non c'è stato impegno». Rifatte da capo: il cuore e' un palloncino, la
# spada ha l'elsa a colombina, la velocita' sono le frecce, la forza mentale un
# brillante, il fattore una bomba, l'aura il segno di Jalhalla misurato e rifatto
# con la curvatura che non salta mai (fuoco_fatuo). La regola nuova: la prima
# figura si legge da sola, la seconda e' il premio di chi guarda (come la
# serratura nell'occhio), e le due si fondono invece di stare una accanto
# all'altra.
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
	"hp": ["il cuore", "il palloncino", "La vita è un palloncino della fiera: ogni colpo che incassi la gonfia un po' di più."],
	"attacco": ["la spada", "la maschera", "L'elsa è una colombina di carnevale: il Carnivalz è la festa di chi ha subito un torto."],
	"difesa": ["lo scudo", "i merli", "L'unità è una struttura da difendere: lo scudo è una fortezza."],
	"velocita": ["il gallone", "il suo doppio", "Il segno dell'avanti veloce: dove gli altri fanno un passo, tu ne fai due."],
	"intelligenza": ["l'occhio", "la serratura", "Vedere la via d'uscita: è la stat che fa fuggire."],
	"forza_mentale": ["il rombo", "il brillante", "La pressione fa i diamanti: la forza mentale cresce con lo stress che reggi."],
	"fattore": ["la bomba", "la scintilla", "La brace corre lungo la miccia, il critico è lo scoppio. Il riflesso è il rombo di Carnivalz."],
	"maestria_dominio": ["la corona", "la barra del dominio", "La fascia della corona sono i tre segmenti della barra."],
	"aura": ["il vortice", "la fiamma", "Il segno sulla pancia di Jalhalla, capovolto: un fuoco fatuo che sale dal vortice."],
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
	# pixel: la sfumatura se lo mangia, e gli occhi della maschera o i tagli del
	# brillante spariscono. Sotto i 32 pixel il taglio cresce fino a restare largo 1,4 pixel
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
			# il cuore e' un palloncino della fiera: il nodo sotto la punta, il filo
			# spesso un taglio, e sul lobo di sinistra il riflesso, una falce sottile
			# alle punte. La vita cresce coi colpi incassati: ogni colpo la gonfia
			var c := cuore(50, 31, 77, 16, 19)
			var nodo := unione([poli([47, 73, 53, 73, 57.5, 81, 42.5, 81]), smussato(42, 78.5, 58, 84, 2.75)])
			var filo := banda(curva3(Vector2(50, 83), Vector2(55.5, 86.5), Vector2(44.5, 90), Vector2(49, 93.5), 40), C, true)
			# piccola, il riflesso si ingrossa con il taglio (ma una falce piu' grossa di
			# cosi' diventa una mandorla)
			var lucido := Vector2(34.5, 31)
			var riflesso := falce(lucido, 11.25, 168, 288, clampf(taglio + 0.5, 4.8, 6.0))
			guida(["cerchio", lucido, 11.25])
			guida(["punto", Vector2(49, 93.5)])
			guida(["nota", "Il nodo è un trapezio coi bordi tondi, il filo è spesso un taglio. Il riflesso: un arco di raggio 11,25 sul centro del lobo e uno più piatto per gli stessi capi."])
			s = [[1, unione([c, nodo, filo])], [-1, riflesso]]
			registra = false
			a = [[1, cuore(50, 34, 86, 18, 22)]]
			var pallone := scala(cerchio(Vector2(50, 36), 26), Vector2(50, 36), Vector2(0.86, 1.0))
			b = [[1, unione([pallone, poli([46, 60, 54, 60, 58, 70, 42, 70]),
					banda(curva3(Vector2(50, 69), Vector2(57, 75), Vector2(43, 82), Vector2(50, 92), 40), 6.0, true)])]]
		"attacco":
			# la spada con l'elsa a colombina, la maschera del carnevale veneziano: la
			# spada si legge per prima, la maschera e' il premio di chi la guarda. Il
			# Carnivalz e' la festa di chi ha subito un torto. Costruita dritta (la
			# punta in su, la maschera a 100), girata di 45° e rimessa in un quadrato
			# di 82: dritta e appesantita sembrava una faccia col cappello a punta
			var k := 1.3
			var mezza := 11.0
			var y_m := 100.0
			var punta := y_m - 80.0
			var spalla := punta + mezza * 1.8
			var lama := poli([50, punta, 50 + mezza, spalla, 50 + mezza, y_m, 50 - mezza, y_m, 50 - mezza, spalla])
			var maschera := colombina(Vector2(50, y_m), k, 11)
			var manico := rett(44, y_m, 56, y_m + 24)
			var pomo_r := 10.5
			var c_pomo := Vector2(50, y_m + 24 + pomo_r * 0.55)
			# il pomo e' il rombo dell'emblema, dritto anche con la spada girata
			var pomo := ruota(rombo(c_pomo, pomo_r, pomo_r), c_pomo, -45.0)
			var tutta := unione([lama, maschera, manico, pomo])
			var spada := ruota(tutta, Vector2(50, y_m), 45.0)
			var box := Rect2(spada[0], Vector2.ZERO)
			for q in spada:
				box = box.expand(q)
			var kk := 82.0 / maxf(box.size.x, box.size.y)
			var al_posto := func(p: PackedVector2Array) -> PackedVector2Array:
				var fuori := PackedVector2Array()
				for q in ruota(p, Vector2(50, y_m), 45.0):
					fuori.append(CENTRO + (q - box.get_center()) * kk)
				return fuori
			s = [[1, al_posto.call(tutta)]]
			# gli occhi a mandorla, con l'angolo di fuori tirato in su; piccola si stringono
			var occhio_k := k * (0.78 - (taglio - C) * 0.065)
			for verso: float in [-1.0, 1.0]:
				s.append([-1, al_posto.call(occhio_gatto(Vector2(50 + 15 * verso * k, y_m - k * 0.5), occhio_k, verso))])
			var asse: PackedVector2Array = al_posto.call(PackedVector2Array([Vector2(50, punta), c_pomo]))
			guida(["segmento", asse[0], asse[1]])
			for q: Vector2 in al_posto.call(PackedVector2Array([Vector2(50, y_m), Vector2(50 - 15 * k, y_m), Vector2(50 + 15 * k, y_m)])):
				guida(["punto", q])
			# il contorno di controllo della colombina (le curve di Bezier, per meta')
			var poligono_c := PackedVector2Array()
			for tratto_c: Array in controlli_colombina(11):
				for q: Vector2 in (tratto_c if poligono_c.is_empty() else tratto_c.slice(1)):
					poligono_c.append(Vector2(50, y_m) + q * k)
			guida(["linea", al_posto.call(poligono_c)])
			guida(["nota", "Dritta: la lama larga 22 con la punta a 58°, la colombina (tre curve di Bézier per metà, specchiate) e il pomo a rombo. Girata di 45°, nel quadrato di 82; il pomo resta un rombo dritto."])
			registra = false
			a = [[1, posa(unione([poli([50, 6, 57, 17, 57, 64, 43, 64, 43, 17]), smussato(28, 61, 72, 69, 3), rett(45.5, 67, 54.5, 86),
					rombo(Vector2(50, 89), 6.5, 6.5)]), 1.05, 45.0, Vector2.ZERO)]]
			b = [[1, colombina(Vector2(50, 54), 1.6, 11)]]
			for verso: float in [-1.0, 1.0]:
				b.append([-1, occhio_gatto(Vector2(50 + 15 * verso * 1.6, 54 - 0.8), 1.6 * 0.8, verso)])
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
			# piccola, il taglio cresce: i 3 in piu' attorno alla cinta calano, se no la
			# cinta si rimpicciolisce e lo scudo perde peso (era a -13% a 16 pixel)
			var cinta := cresci(dentro, -taglio - maxf(0.0, 3.0 - (taglio - C) * 0.6))
			s = [[1, scudo], [-1, dentro], [1, cinta]]
			a = [[1, forma], [-1, dentro], [1, cinta]]
			b = [[1, unione([torre, rett(20, 26, 80, 58)])], [-1, rett(43, 38, 57, 58)]]
		"velocita":
			# due galloni, il segno dell'avanti veloce. Uguali, coi bracci a 45°: quello
			# dietro e' scostato quanto basta perche' fra i due resti un taglio misurato
			# di traverso (piccola, il taglio cresce e i due si allontanano), e la coppia
			# resta al centro
			var spesso := 15.0
			var largo := 35.0
			var passo := (spesso + taglio) * sqrt(2.0)
			var x := 50.0 + (passo - largo - spesso * sqrt(2.0)) * 0.5 - 2.0
			var davanti := gallone(x, largo, spesso)
			var dietro := gallone(x - passo, largo, spesso)
			s = [[1, davanti], [1, dietro]]
			for g: PackedVector2Array in [davanti, dietro]:
				guida(["segmento", g[0], g[5]])
				guida(["segmento", g[1], g[2]])
			guida(["punto", davanti[2]])
			guida(["nota", "Due galloni uguali, spessi 15 di traverso, coi bracci a 45°. Quello dietro è scostato di (15 + un taglio) per radice di 2: fra i due resta un taglio."])
			a = [[1, gallone(20, 34, 16)]]
			b = [[1, gallone(20, 34, 16)]]
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
			# il rombo dell'emblema tagliato come un brillante: la punta di sopra diventa
			# la tavola. La pressione fa i diamanti, e la forza mentale cresce con lo
			# stress che reggi. Le faccette sono un taglio solo: la cintura, due tagli
			# dalla tavola alla cintura, e la V del padiglione che si ferma prima della
			# punta (la punta resta piena)
			var tavola := 16.0
			var cintura := 44.0
			var gemma := PackedVector2Array([Vector2(30, tavola), Vector2(70, tavola), Vector2(96, cintura), Vector2(50, 96),
					Vector2(4, cintura)])
			var tagli: Array = [rett(0, cintura - taglio * 0.5, 100, cintura + taglio * 0.5),
					banda(PackedVector2Array([Vector2(41, cintura - 1), Vector2(50, 82), Vector2(59, cintura - 1)]), taglio)]
			for verso: float in [-1.0, 1.0]:
				tagli.append(banda(PackedVector2Array([Vector2(50 + 19 * verso, tavola - 3), Vector2(50 + 9 * verso, cintura)]), taglio))
			var faccette := comune(unione(tagli), gemma)
			s = [[1, gemma], [-1, faccette]]
			# il rombo intero: i fianchi della corona, prolungati, si incontrano sopra la tavola
			var cima := Vector2(50, tavola - (cintura - tavola) * 20.0 / 26.0)
			guida(["segmento", Vector2(4, cintura), cima])
			guida(["segmento", Vector2(96, cintura), cima])
			guida(["punto", Vector2(50, 82)])
			guida(["nota", "Il rombo dell'emblema, coi fianchi a 47°, tagliato in cima: la tavola. La cintura a 44; le faccette sono un taglio solo, la V si ferma a 14 dalla punta."])
			registra = false
			a = [[1, rombo(CENTRO, 40, 44)]]
			b = [[1, unione(tagli)]]
		"fattore":
			# la bomba: la miccia accesa e' la brace che arde, il critico e' lo scoppio.
			# Il riflesso sulla palla e' il rombo di Carnivalz. La scintilla sta a un
			# taglio dalla miccia: piccola, la miccia si accorcia
			var r := 29.5
			var c := Vector2(44, 61)
			var verso := Vector2(1, -1).normalized()
			var palla := cerchio(c, r, 128)
			var tappo := sposta(ruota(smussato(-8, -7, 8, 7, 2), Vector2.ZERO, 45), c + verso * (r + 1))
			var bocca := c + verso * (r + 6)
			var fine := Vector2(75, 21) - Vector2(0.4, -1).normalized() * (taglio - C) * 1.2
			var curva_m := arco_per(bocca, fine, -4.0, 32)
			var miccia := banda(curva_m, 6.0, true)
			var stella := Vector2(87.5, 12.5)
			var scintilla := unione([rombo(stella, 4, 8.5), rombo(stella, 8.5, 4)])
			# piccola, il riflesso si stringe verso il suo centro: dal bordo deve restare
			# almeno un taglio
			var piccolo := 1.0 - (taglio - C) * 0.06
			s = [[1, unione([palla, tappo, miccia])], [1, scintilla],
					[-1, rombo(c + Vector2(-r * 0.4, -r * 0.36), r * 0.19 * piccolo, r * 0.29 * piccolo)]]
			guida(["cerchio", c, r])
			guida(["punto", c])
			guida(["linea", curva_m])
			guida(["punto", stella])
			guida(["nota", "La palla di raggio 29,5; il tappo girato di 45° sulla diagonale; la miccia è un arco. Il riflesso è il rombo, alto una volta e mezza la sua larghezza."])
			registra = false
			a = [[1, unione([cerchio(Vector2(46, 58), 34, 128), sposta(ruota(smussato(-9, -8, 9, 8, 2), Vector2.ZERO, 45),
					Vector2(46, 58) + verso * 35), banda(arco_per(Vector2(46, 58) + verso * 41, Vector2(86, 10), -5.0, 32), 7.0, true)])]]
			b = [[1, unione([rombo(CENTRO, 14, 34), rombo(CENTRO, 34, 14)])]]
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
			# le fessure sono di sbieco (6 su 13): larghe un taglio misurate di
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
			# il segno sulla pancia di Jalhalla, capovolto (l'idea e' di Bru): un fuoco
			# fatuo che sale da un vortice. La linea di mezzo e' misurata sul segno (lo
			# scheletro della foto) e rifatta liscia: la curvatura cambia senza salti
			# (fuoco_fatuo). Dalla punta in cima: la pancia che gira in senso orario, il
			# flesso, poi una spirale logaritmica, allungata a ovale come nel segno
			s = [[1, fuoco_fatuo(0.0, 1.0)]]
			guida(["pettine", s[0][1]])
			registra = false
			a = [[1, fuoco_fatuo(0.3, 1.0)]]
			b = [[1, fuoco_fatuo(0.0, 0.36)]]
	registra = false
	var pieni: Array = []
	for strato: Array in s:
		if int(strato[0]) > 0:
			pieni.append(strato[1])
	return {"icona": s, "a": a, "b": b, "ombra": chiusa(pieni, taglio * 0.6 + 0.5), "guide": guide.duplicate()}


static func chiusa(figure: Array, g: float) -> Array[PackedVector2Array]:
	# L'OMBRA DEL TIMBRO E' UNA SAGOMA SOLA. Le figure allargate di g finche' si
	# toccano, fuse, e ristrette di g: i vuoti stretti fra un pezzo e l'altro (la
	# fascia della corona, i due galloni, la bomba e la scintilla) si chiudono,
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


static func curva3(a: Vector2, g1: Vector2, g2: Vector2, b: Vector2, lati := 24) -> PackedVector2Array:
	# la curva di Bezier cubica da a a b: parte verso g1, arriva da g2
	var p := PackedVector2Array()
	for i in lati + 1:
		var k := float(i) / lati
		var u := 1.0 - k
		p.append(a * u * u * u + g1 * 3.0 * u * u * k + g2 * 3.0 * u * k * k + b * k * k * k)
	return p


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


static func smussato(x0: float, y0: float, x1: float, y1: float, r: float) -> PackedVector2Array:
	# il rettangolo con gli angoli tondi di raggio r
	var p := PackedVector2Array()
	var centri := [Vector2(x1 - r, y0 + r), Vector2(x1 - r, y1 - r), Vector2(x0 + r, y1 - r), Vector2(x0 + r, y0 + r)]
	for k in 4:
		for i in 13:
			p.append((centri[k] as Vector2) + Vector2.from_angle(deg_to_rad(-90.0 + 90.0 * k + 90.0 * i / 12.0)) * r)
	return p


static func comune(a: PackedVector2Array, b: PackedVector2Array) -> PackedVector2Array:
	# la parte di a che sta anche in b (la piu' grande, se sono piu' d'una)
	var migliore := PackedVector2Array()
	for q in Geometry2D.intersect_polygons(a, b):
		if not Geometry2D.is_polygon_clockwise(q) and area(q) > area(migliore):
			migliore = q
	return migliore


static func arco_per(a: Vector2, b: Vector2, freccia: float, lati := 40) -> PackedVector2Array:
	# l'arco di cerchio da a a b che si scosta di "freccia" dalla corda, verso la
	# normale (b - a).orthogonal() se freccia > 0
	var m := (a + b) * 0.5
	return arco_tre(a, m + (b - a).normalized().orthogonal() * freccia, b, lati)


static func arco_tre(a: Vector2, m: Vector2, b: Vector2, lati := 32) -> PackedVector2Array:
	# l'arco di cerchio che parte da a, passa per m e arriva in b
	var d := 2.0 * (a.x * (m.y - b.y) + m.x * (b.y - a.y) + b.x * (a.y - m.y))
	if absf(d) < 1e-9:
		return PackedVector2Array([a, b])
	var c := Vector2((a.length_squared() * (m.y - b.y) + m.length_squared() * (b.y - a.y) + b.length_squared() * (a.y - m.y)) / d,
			(a.length_squared() * (b.x - m.x) + m.length_squared() * (a.x - b.x) + b.length_squared() * (m.x - a.x)) / d)
	var r := c.distance_to(a)
	var aa := (a - c).angle()
	var d1 := wrapf((m - c).angle() - aa, -PI, PI)
	var d2 := wrapf((b - c).angle() - (m - c).angle(), -PI, PI)
	if signf(d1) != signf(d2):
		d2 += TAU * signf(d1)
	var p := PackedVector2Array()
	for i in lati + 1:
		p.append(c + Vector2.from_angle(aa + (d1 + d2) * i / lati) * r)
	return p


static func falce(c: Vector2, r: float, da: float, a: float, spessa: float) -> PackedVector2Array:
	# la falce di un riflesso: fuori l'arco del cerchio (c, r) fra gli angoli da e a,
	# dentro un arco piu' piatto per gli stessi due capi. Grossa "spessa" nel mezzo,
	# a punta ai capi
	var fuori := arco(c, r, da, a, 32)
	var mezzo := c + Vector2.from_angle(deg_to_rad((da + a) * 0.5)) * (r - spessa)
	var dentro_a := arco_tre(fuori[fuori.size() - 1], mezzo, fuori[0], 32)
	var p := fuori + dentro_a.slice(1, dentro_a.size() - 1)
	if Geometry2D.is_polygon_clockwise(p):
		p.reverse()
	return p


static func controlli_colombina(guance: float) -> Array:
	# i punti di controllo della meta' sinistra della colombina, tre curve di Bezier:
	# il bordo di sopra (che sale verso la punta, a occhio di gatto), il fianco che
	# scende sulla guancia, l'arco del naso
	return [[Vector2(0, -8), Vector2(-9, -8.5), Vector2(-19, -10), Vector2(-29, -17)],
			[Vector2(-29, -17), Vector2(-28, -6), Vector2(-24, guance - 2), Vector2(-14, guance)],
			[Vector2(-14, guance), Vector2(-8, guance + 1), Vector2(-5, 3), Vector2(0, 3)]]


static func colombina(c: Vector2, k: float, guance: float) -> PackedVector2Array:
	# la colombina, la maschera del carnevale veneziano, larga 58 per k: la meta'
	# sinistra dalle sue tre curve, la destra e' lo specchio
	var mezza := PackedVector2Array()
	for q: Array in controlli_colombina(guance):
		var tratto_c := curva3(q[0], q[1], q[2], q[3], 24)
		mezza.append_array(tratto_c if mezza.is_empty() else tratto_c.slice(1))
	var p := PackedVector2Array()
	for q in mezza:
		p.append(c + q * k)
	for i in range(mezza.size() - 2, 0, -1):
		p.append(c + Vector2(-mezza[i].x, mezza[i].y) * k)
	if Geometry2D.is_polygon_clockwise(p):
		p.reverse()
	return p


static func occhio_gatto(c: Vector2, k: float, verso: float) -> PackedVector2Array:
	# l'occhio della maschera: una mandorla con l'angolo di fuori tirato in su
	var dentro_p := Vector2(-7.5, 1.0)
	var fuori_p := Vector2(8.5, -3.0)
	var su := curva3(dentro_p, Vector2(-4, -4.5), Vector2(3, -6), fuori_p, 16)
	var giu := curva3(fuori_p, Vector2(4, 2.5), Vector2(-2, 4.5), dentro_p, 16)
	var p := PackedVector2Array()
	for q in su + giu.slice(1, giu.size() - 1):
		p.append(c + Vector2(q.x * verso, q.y) * k)
	if Geometry2D.is_polygon_clockwise(p):
		p.reverse()
	return p


static func gallone(x: float, largo: float, spesso: float) -> PackedVector2Array:
	# una freccia » sola: i bracci a 45°, spessi "spesso" di traverso, il vertice a destra
	var punta := Vector2(x + largo, 50)
	var p := PackedVector2Array([Vector2(x, 50 - largo), Vector2(x + spesso * sqrt(2.0), 50 - largo),
			punta + Vector2(spesso * sqrt(2.0), 0), Vector2(x + spesso * sqrt(2.0), 50 + largo), Vector2(x, 50 + largo), punta])
	if Geometry2D.is_polygon_clockwise(p):
		p.reverse()
	return p


static func liscio(x: float) -> float:
	# il passo liscio di secondo ordine: da 0 a 1 senza salti ne' di pendenza ne' di curvatura
	return x * x * x * (x * (x * 6.0 - 15.0) + 10.0)


static func fuoco_fatuo(da_u: float, a_u: float) -> PackedVector2Array:
	# IL FUOCO FATUO DELL'AURA. La linea di mezzo e' data dalla sua curvatura lungo
	# la lunghezza, che cambia senza salti: sulla coda (lunga 81,8) una gobba oraria
	# (la pancia) che sfuma nella curvatura del ricciolo; poi la spirale
	# logaritmica, il cui raggio di curvatura cala dritto da 31,8 a 9,3 in 416,6°.
	# Questi numeri vengono dalla misura del segno di Jalhalla (lo scheletro della
	# foto, e una ricerca che ne ricalca la linea con uno scarto del 2%
	# dell'altezza). Poi la linea e' allargata in orizzontale di 1,24 (il ricciolo
	# del segno e' un ovale) e prende lo spessore, in frazioni dell'altezza: nasce
	# dalla punta, si gonfia nella pancia (0,36), corre nel ricciolo (0,185) e
	# chiude in tondo. Le normali sono quelle vere della curva, non stimate dai
	# punti: niente bozzi. da_u e a_u tengono solo un pezzo (le due figure)
	var giro := deg_to_rad(416.6)
	var r1 := 31.8
	var re := 9.3
	var coda := 81.8
	var pancia_k := 0.0411
	var ricciolo := giro * (r1 - re) / log(r1 / re)
	var lungo := coda + ricciolo
	var allarga := 1.241
	var n := 2800
	var punti := PackedVector2Array()
	var dir := PackedFloat32Array()
	var th := deg_to_rad(50.3)
	var pos := Vector2.ZERO
	var ds := lungo / n
	var kappa := func(s: float) -> float:
		if s < coda:
			var x := s / coda
			return pancia_k * x * (1.0 - x) * (1.0 - x) * 6.75 - liscio(x) / r1
		return -1.0 / (r1 - (r1 - re) * (s - coda) / ricciolo)
	for i in n + 1:
		punti.append(Vector2(pos.x * allarga, pos.y))
		dir.append(atan2(sin(th), cos(th) * allarga))
		# il passo a meta' (secondo ordine)
		var th_mezzo := th + float(kappa.call(i * ds)) * ds * 0.5
		pos += Vector2.from_angle(th_mezzo) * ds
		th += float(kappa.call((i + 0.5) * ds)) * ds
	var y0 := INF
	var y1 := -INF
	for q in punti:
		y0 = minf(y0, q.y)
		y1 = maxf(y1, q.y)
	var alto := y1 - y0
	var lunghezze := PackedFloat32Array([0.0])
	for i in range(1, punti.size()):
		lunghezze.append(lunghezze[i - 1] + punti[i].distance_to(punti[i - 1]))
	var tot := lunghezze[lunghezze.size() - 1]
	var sx := PackedVector2Array()
	var dx := PackedVector2Array()
	var mezzo := PackedVector2Array()
	for i in punti.size():
		var u := lunghezze[i] / tot
		if u < da_u or u > a_u:
			continue
		var punta := 1.0 - exp(-u / 0.07)
		var gobba := exp(-pow((u - 0.19) / 0.09, 2.0))
		var fine := 1.0 - 0.25 * liscio(clampf((u - 0.7) / 0.3, 0.0, 1.0))
		# la fine tonda: radice di 1 - x^6, che parte senza gomiti (piatta fino alla
		# derivata quinta) e chiude in tondo. Con 1 - x^2 il bordo faceva un gomito
		# dove la fine comincia
		var tondo_f := sqrt(maxf(1.0 - pow(maxf(u - 0.86, 0.0) / 0.14, 6.0), 0.0))
		var w := alto * punta * tondo_f * (0.185 * fine + 0.175 * gobba)
		var nrm := Vector2.from_angle(dir[i]).orthogonal()
		sx.append(punti[i] + nrm * w * 0.5)
		dx.append(punti[i] - nrm * w * 0.5)
		mezzo.append(punti[i])
	dx.reverse()
	var p := sx + dx
	if Geometry2D.is_polygon_clockwise(p):
		p.reverse()
	# nella scatola: tutta, alta da 4 a 92 (il ricciolo pesa in basso, la si alza
	# un poco); un pezzo, grande quanto puo'
	var scatola := Rect2(6, 4, 88, 88) if da_u <= 0.0 and a_u >= 1.0 else Rect2(8, 8, 84, 84)
	var box := Rect2(p[0], Vector2.ZERO)
	for q in p:
		box = box.expand(q)
	var k := minf(scatola.size.x / box.size.x, scatola.size.y / box.size.y)
	var fuori := PackedVector2Array()
	for q in p:
		fuori.append(scatola.get_center() + (q - box.get_center()) * k)
	if registra:
		var linea := PackedVector2Array()
		for i in range(0, mezzo.size(), 24):
			linea.append(scatola.get_center() + (mezzo[i] - box.get_center()) * k)
		guida(["linea", linea])
		guida(["punto", linea[0]])
		var attacco_ricciolo := roundi(coda / lungo * (mezzo.size() - 1))
		guida(["punto", scatola.get_center() + (mezzo[attacco_ricciolo] - box.get_center()) * k])
		guida(["punto", scatola.get_center() + (mezzo[mezzo.size() - 1] - box.get_center()) * k])
		guida(["nota", "La linea di mezzo del segno di Jalhalla, misurata e rifatta liscia: la pancia, il flesso, la spirale logaritmica allungata a ovale. In arancio il pettine della curvatura: la cresta è liscia, niente bozzi."])
	return fuori


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


static func curvatura(p: PackedVector2Array, passo := 0.5, campata := 2.0) -> Array:
	# IL PETTINE DELLA CURVATURA, come nei programmi per disegnare caratteri: il
	# contorno chiuso ripreso a punti equidistanti, e in ogni punto quanto gira la
	# tangente fra "campata" prima e "campata" dopo, diviso la strada. Ritorna
	# [punti, curvature con segno]
	var q := PackedVector2Array()
	var resto := 0.0
	for i in p.size():
		var a := p[i]
		var b := p[(i + 1) % p.size()]
		var l := a.distance_to(b)
		var s := resto
		while s < l:
			q.append(a.lerp(b, s / l))
			s += passo
		resto = s - l
	var k := PackedFloat32Array()
	var n := q.size()
	var m := maxi(1, roundi(campata / passo))
	for i in n:
		var t1 := (q[i] - q[(i - m + n) % n]).normalized()
		var t2 := (q[(i + m) % n] - q[i]).normalized()
		k.append(t1.angle_to(t2) / (passo * m))
	return [q, k]


static func bozzi(p: PackedVector2Array, soglia := 0.004, vicini := 3.0) -> int:
	# I BOZZI: le increspature del contorno. Si segue la curvatura lungo il bordo e
	# si contano le volte che smette di crescere e cala (o il contrario) di piu' di
	# "soglia" a meno di "vicini" unita' dal cambio precedente. Le gobbe vere di
	# una figura (la pancia, il flesso, i capi di un ovale) stanno lontane una
	# dall'altra; un bordo a bozzi cambia verso ogni unita' o due
	var ck: Array = curvatura(p)
	var k: PackedFloat32Array = ck[1]
	var passo := (ck[0] as PackedVector2Array)[0].distance_to((ck[0] as PackedVector2Array)[1])
	var conta := 0
	var verso := 0
	var rif := k[0]
	var ultimo := -INF
	for i in range(1, k.size()):
		var d := k[i] - rif
		if absf(d) < soglia:
			continue
		var v := 1 if d > 0.0 else -1
		if verso != 0 and v != verso:
			if (i - ultimo) * passo < vicini:
				conta += 1
			ultimo = i
		verso = v
		rif = k[i]
	return conta


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
