class_name LastreVetro
extends RefCounted
# I PEZZI DEL VETRO ROTTO (VetroRotto.gd), cioe' il vetro fra le crepe.
#
# Bru, sul vetro: «migliora ancora di più l'effetto di quando vieni colpito
# che si spacca il vetro», e poi, sul primo tentativo: «non ci siamo, non è
# ancora di qualità sembra quasi fatto su paint». Era vero: le schegge erano
# poligoni bianchi piatti, i buchi macchie scure, la luce una tinta uguale su
# tutto il pezzo. Disegni sopra lo schermo, non un vetro.
#
# UN VETRO SI RICONOSCE DA QUELLO CHE C'E' DIETRO. Quindi:
#   - il vetro si taglia in pezzi lungo le crepe: ogni SPICCHIO fra due crepe
#     principali, dall'impatto fino al bordo, e dentro lo spicchio un pezzo per
#     ogni giro di ragnatela che lo attraversa (dove il giro ha un buco, i due
#     pezzi sono uno solo: non c'e' crepa che li separi). I pezzi coprono il
#     vetro tutto, senza buchi e senza sovrapporsi
#   - ogni pezzo fermo mostra quello che c'e' dietro spostato di qualche pixel,
#     per conto suo (lo shader, vetro_lastre.gdshader), e ci passa sopra un
#     riflesso SFUMATO, non una tinta: ogni pezzo e' inclinato a modo suo e la
#     luce gli scivola addosso da un lato all'altro
#   - nel colpo i pezzi STRAPPANO: per un attimo si spostano molto di piu', poi
#     si assestano
#   - i pezzi attaccati all'impatto SALTANO: si portano dietro il loro pezzo di
#     immagine, ti vengono addosso ingrandendosi, girano anche in profondita'
#     (si schiacciano e si rovesciano), e quando si girano verso la luce
#     lampeggiano. Hanno uno SPESSORE - il vetro di taglio, verdino come il
#     vetro vero - e il bordo che prende la luce chiaro, quello in ombra scuro
#   - dove c'erano resta un BUCO: buio, col bordo vivo del vetro intorno
#
# Col movimento ridotto i pezzi sono spostati e fermi: niente strappo, niente
# pezzi che saltano, niente buchi.

const SPINTA := 4.5            # quanto si sposta di serie un pezzo vicino all'impatto
const STRAPPO := 0.9           # quanto di piu' nel colpo
const SCOSSONE := 0.2          # quanto ci mette lo strappo ad assestarsi
const CADE_DA := 0.1           # quando i pezzi dell'impatto si staccano
const CADUTA := 0.55           # quanto ci mettono a volare via
const PIENO := Vector2(9999.0, 9999.0)   # per lo shader: questo non guarda dietro, e' un colore
const TAGLIO := Color(0.72, 0.93, 0.88)  # il vetro visto di taglio: verdino

# del vetro si tengono i numeri, non il vetro: il vetro tiene i suoi pezzi, e
# se i pezzi tenessero il vetro nessuno dei due verrebbe mai liberato
var impatto := Vector2.ZERO
var r := 30.0
var bordo := Rect2()
# {punti, indici, spinta, luce, inclina, distanza, cade, stretto, centro, lontano,
#  vola, rotola, asse, capriola}
var pezzi: Array[Dictionary] = []


func _init(vetro: VetroRotto, d: RandomNumberGenerator) -> void:
	impatto = vetro.impatto
	r = vetro.r
	bordo = vetro.vetro
	for k in vetro.principali.size():
		taglia_spicchio(d, vetro, k)
	# almeno un pezzo si stacca: e' il colpo che sfonda
	var staccati := pezzi.filter(func(pezzo: Dictionary) -> bool: return bool(pezzo["cade"]))
	if staccati.is_empty():
		for pezzo in pezzi:
			if float(pezzo["distanza"]) == 0.0 and bool(pezzo["stretto"]):
				pezzo["cade"] = true
				break


func taglia_spicchio(d: RandomNumberGenerator, vetro: VetroRotto, k: int) -> void:
	# lo spicchio fra la crepa k e la successiva, tagliato dai giri che lo
	# attraversano. Ogni pezzo: un tratto della crepa di sinistra, il giro di
	# fuori, lo stesso tratto della crepa di destra all'indietro, il giro di
	# dentro all'indietro
	var sinistra := vetro.principali[k]
	var destra := vetro.principali[(k + 1) % vetro.principali.size()]
	var giri: Array[Dictionary] = []
	for anello in vetro.anelli:
		if int(anello["k"]) == k:
			giri.append(anello)
	giri.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["giro"]) < int(b["giro"]))
	var da_s := 0
	var da_d := 1   # l'impatto e' il primo punto di tutte e due: lo si mette una volta
	var dentro := PackedVector2Array()
	var distanza := 0.0
	for giro in giri:
		var gomito: Vector2 = (giro["punti"] as PackedVector2Array)[1]
		var a_s := int(giro["ia"])
		var a_d := int(giro["ib"])
		if a_s < da_s or a_d < da_d:
			continue
		aggiungi(d, cuci(sinistra, da_s, a_s, PackedVector2Array([gomito]), destra, da_d, a_d, dentro),
				distanza, int(giro["giro"]) == 0)
		da_s = a_s
		da_d = a_d
		dentro = PackedVector2Array([gomito])
		distanza = float(giro["distanza"])
	var fine_s := sinistra.size() - 1
	var fine_d := destra.size() - 1
	aggiungi(d, cuci(sinistra, da_s, fine_s, angoli_fra(sinistra[fine_s], destra[fine_d]), destra, mini(da_d, fine_d),
			fine_d, dentro), distanza, false)


static func cuci(sinistra: PackedVector2Array, da_s: int, a_s: int, fuori: PackedVector2Array,
		destra: PackedVector2Array, da_d: int, a_d: int, dentro: PackedVector2Array) -> PackedVector2Array:
	var punti := sinistra.slice(da_s, a_s + 1)
	punti.append_array(fuori)
	var ritorno := destra.slice(da_d, a_d + 1)
	ritorno.reverse()
	punti.append_array(ritorno)
	punti.append_array(dentro)
	return punti


func angoli_fra(da: Vector2, a: Vector2) -> PackedVector2Array:
	# gli angoli del vetro che si incontrano girando lungo il bordo da 'da' ad
	# 'a', nel verso in cui sono ordinate le crepe. L'impatto sta dentro il
	# vetro, quindi visto da li' il bordo si percorre in ordine di angolo
	var c := impatto
	var parte := (da - c).angle()
	var arco := wrapf((a - c).angle() - parte, 0.0, TAU)
	var v := bordo
	var trovati: Array = []
	for angolo: Vector2 in [v.position, Vector2(v.end.x, v.position.y), v.end, Vector2(v.position.x, v.end.y)]:
		var quanto := wrapf((angolo - c).angle() - parte, 0.0, TAU)
		if quanto > 0.0 and quanto < arco:
			trovati.append([quanto, angolo])
	trovati.sort_custom(func(x: Array, y: Array) -> bool: return float(x[0]) < float(y[0]))
	var angoli := PackedVector2Array()
	for trovato: Array in trovati:
		angoli.append(trovato[1])
	return angoli


func aggiungi(d: RandomNumberGenerator, punti: PackedVector2Array, distanza: float, stretto: bool) -> void:
	# "stretto": il pezzo attaccato all'impatto, chiuso dal primo giro. Solo
	# quelli possono staccarsi: un pezzo che arriva al bordo che vola via
	# porterebbe mezzo riquadro con se'
	var centro := Vector2.ZERO
	var fin_dove := 0.0
	for p in punti:
		centro += p
		fin_dove = maxf(fin_dove, p.distance_to(impatto))
	centro /= maxf(float(punti.size()), 1.0)
	var lontano := clampf(centro.distance_to(impatto) / (r * 8.0), 0.0, 1.0)
	var verso := (centro - impatto).normalized().rotated(d.randf_range(-0.7, 0.7))
	# la luce cambia poco, e quasi niente nei pezzi grandi lontano
	# dall'impatto: uno spicchio che arriva al bordo e' mezzo riquadro, e un
	# mezzo riquadro piu' scuro o piu' chiaro non e' un vetro, e' un'ombra
	pezzi.append({"punti": punti, "indici": Geometry2D.triangulate_polygon(punti), "distanza": distanza,
			"fin_dove": fin_dove,
			"centro": centro, "stretto": stretto, "lontano": lontano,
			"spinta": verso * SPINTA * lerpf(1.0, 0.3, lontano) * d.randf_range(0.6, 1.0),
			"luce": d.randf_range(-0.2, 0.2) * (1.0 - lontano),
			"inclina": Vector2.from_angle(d.randf() * TAU) * d.randf_range(0.5, 1.0),
			"cade": stretto and d.randf() < 0.5,
			"vola": Vector2(d.randf_range(-1.0, 1.0), d.randf_range(-1.7, -0.7)) * r * 2.6,
			"rotola": d.randf_range(-4.0, 4.0),
			"asse": Vector2.from_angle(d.randf() * TAU),
			"capriola": d.randf_range(5.0, 11.0) * (1.0 if d.randf() < 0.5 else -1.0)})


# --- il disegno -------------------------------------------------------------

static func strappo(eta: float, ridotto: bool) -> float:
	# quanto di piu' sono spostati i pezzi: molto nel colpo, poi si assestano
	if ridotto:
		return 1.0
	return 1.0 + STRAPPO * (1.0 - smoothstep(0.0, SCOSSONE, eta))


static func grigio(luce: float, alfa: float) -> Color:
	# la luce come la legge lo shader: 0.5 e' com'e'
	return Color(0.5 + luce * 0.5, 0.5 + luce * 0.5, 0.5 + luce * 0.5, alfa)


static func lastra(tela: CanvasItem, punti: PackedVector2Array, indici: PackedInt32Array,
		spostamenti: PackedVector2Array, colori: PackedColorArray) -> void:
	# un pezzo sulla tela con lo shader: ogni vertice dice da dove guarda dietro
	if indici.is_empty() or punti.size() < 3:
		return
	RenderingServer.canvas_item_add_triangle_array(tela.get_canvas_item(), indici, punti, colori, spostamenti)


func disegna(tela: CanvasItem, eta: float, ridotto: bool, fino: float, arrivate: float, quanto: float) -> void:
	# i pezzi fermi, sulla tela che ha lo shader. Un pezzo si sposta solo
	# quando le crepe intorno l'hanno tagliato tutto: "arrivate" e' fin dove
	# sono arrivate, in pixel dall'impatto, "fino" quanto della loro strada
	# hanno fatto. Prima, un pezzo grande spostato tagliava i pugni lungo una
	# crepa che non c'era ancora. Un pezzo saltato via non c'e' piu'
	var quanto_strappa := strappo(eta, ridotto)
	var verso_luce := VetroRotto.LUCE
	for pezzo in pezzi:
		if not tagliato(pezzo, fino, arrivate) or staccato(pezzo, eta, ridotto):
			continue
		var punti: PackedVector2Array = pezzo["punti"]
		var spostamenti := PackedVector2Array()
		spostamenti.resize(punti.size())
		spostamenti.fill((pezzo["spinta"] as Vector2) * quanto_strappa)
		# il riflesso scivola sul pezzo: piu' chiaro dalla parte dove il pezzo,
		# inclinato, guarda la luce. E appena rotto un lampo lo attraversa
		var lampo := 0.0
		if not ridotto:
			lampo = 0.35 * (1.0 - float(pezzo["lontano"])) \
					* exp(-pow((eta - float(pezzo["distanza"]) / (r * 18.0) - 0.05) / 0.05, 2.0))
		var inclina: Vector2 = pezzo["inclina"]
		var colori := PackedColorArray()
		for p in punti:
			var di_qua := clampf((p - (pezzo["centro"] as Vector2)).dot(inclina) / (r * 3.0), -1.0, 1.0)
			var sulla_luce := 0.5 + 0.5 * inclina.dot(-verso_luce)
			colori.append(grigio(float(pezzo["luce"]) + 0.12 * di_qua * sulla_luce * (1.0 - float(pezzo["lontano"])) + lampo,
					quanto))
		lastra(tela, punti, pezzo["indici"], spostamenti, colori)


static func tagliato(pezzo: Dictionary, fino: float, arrivate: float) -> bool:
	# le crepe intorno l'hanno tagliato tutto: sono arrivate al suo punto piu'
	# lontano, o fino in fondo
	return fino >= 0.999 or arrivate >= float(pezzo["fin_dove"])


static func staccato(pezzo: Dictionary, eta: float, ridotto: bool) -> bool:
	return bool(pezzo["cade"]) and not ridotto and eta >= CADE_DA


func posa_in_volo(pezzo: Dictionary, t: float) -> PackedVector2Array:
	# dove sono adesso i vertici di un pezzo saltato via, t secondi dopo il
	# distacco: vola verso di te (si ingrandisce), gira nel piano, fa la
	# capriola in profondita' (si schiaccia lungo il suo asse, fino a
	# rovesciarsi) e la gravita' se lo porta giu'
	var centro: Vector2 = pezzo["centro"]
	var dove := centro + (pezzo["vola"] as Vector2) * t + Vector2(0.0, VetroRotto.GRAVITA) * t * t * 0.5
	var giro := float(pezzo["rotola"]) * t
	var grande := lerpf(1.0, 1.7, t / CADUTA)
	var asse: Vector2 = pezzo["asse"]
	var schiaccia := cos(float(pezzo["capriola"]) * t)
	var punti := PackedVector2Array()
	for p: Vector2 in pezzo["punti"]:
		var q := p - centro
		q += asse * q.dot(asse) * (schiaccia - 1.0)
		punti.append(dove + q.rotated(giro) * grande)
	return punti


func in_volo(eta: float, ridotto: bool) -> Array[PackedVector2Array]:
	# i pezzi saltati via, dove sono adesso
	var volano: Array[PackedVector2Array] = []
	var t := eta - CADE_DA
	if ridotto or t < 0.0 or t >= CADUTA:
		return volano
	for pezzo in pezzi:
		if bool(pezzo["cade"]):
			volano.append(posa_in_volo(pezzo, t))
	return volano


func disegna_in_volo(tela: CanvasItem, eta: float, ridotto: bool) -> void:
	# i pezzi in volo, sulla tela con lo shader: lo spessore, il pezzo con la
	# sua immagine, il bordo che prende la luce
	var t := eta - CADE_DA
	if ridotto or t < 0.0 or t >= CADUTA:
		return
	var u := t / CADUTA
	var alfa := 1.0 - u * u
	for pezzo in pezzi:
		if not bool(pezzo["cade"]):
			continue
		var punti := posa_in_volo(pezzo, t)
		var origine: PackedVector2Array = pezzo["punti"]
		var indici: PackedInt32Array = pezzo["indici"]
		# lo spessore: il vetro di taglio, che spunta dalla parte in ombra
		var spessore := PackedVector2Array()
		for p in punti:
			spessore.append(p + VetroRotto.LUCE * -3.0)
		lastra(tela, spessore, indici, pieni(punti.size()), tinte(punti.size(), Color(TAGLIO, 0.9 * alfa)))
		# il pezzo: guarda dietro da dove veniva ogni vertice; la luce ci scivola
		# sopra da un lato all'altro, e lampeggia quando la capriola lo gira
		# verso di lei
		var spostamenti := PackedVector2Array()
		var colori := PackedColorArray()
		var lampo := pow(absf(cos(float(pezzo["capriola"]) * t * 0.5 + 0.6)), 8.0)
		var centro := centro_di(punti)
		var grande := 1.0
		for p in punti:
			grande = maxf(grande, p.distance_to(centro))
		for i in punti.size():
			spostamenti.append(origine[i] - punti[i])
			var di_qua := clampf((punti[i] - centro).dot(-VetroRotto.LUCE) / grande, -1.0, 1.0)
			colori.append(grigio(0.3 + 0.35 * di_qua + 0.6 * lampo, alfa))
		lastra(tela, punti, indici, spostamenti, colori)
		bordo_in_luce(tela, punti, alfa)


func bordo_in_luce(tela: CanvasItem, punti: PackedVector2Array, alfa: float) -> void:
	# il bordo del pezzo: chiaro dove guarda la luce, scuro dove no
	var area := 0.0
	for i in punti.size():
		area += punti[i].cross(punti[(i + 1) % punti.size()])
	var fuori := 1.0 if area > 0.0 else -1.0
	for i in punti.size():
		var a := punti[i]
		var b := punti[(i + 1) % punti.size()]
		var normale := (b - a).normalized().orthogonal() * -fuori
		var verso_luce := normale.dot(-VetroRotto.LUCE)
		var tinta := Color(1.0, 1.0, 1.0, alfa * clampf(verso_luce + 0.35, 0.0, 1.0)) if verso_luce > -0.2 \
				else Color(0.0, 0.0, 0.0, alfa * 0.6 * clampf(-verso_luce + 0.2, 0.0, 1.0))
		VetroRotto.striscia(tela, PackedVector2Array([a, b]), PackedFloat32Array([1.9, 1.9]),
				PackedFloat32Array([1.0, 1.0]), tinta, true)


static func centro_di(punti: PackedVector2Array) -> Vector2:
	var somma := Vector2.ZERO
	for p in punti:
		somma += p
	return somma / maxf(float(punti.size()), 1.0)


static func pieni(quanti: int) -> PackedVector2Array:
	var tutti := PackedVector2Array()
	tutti.resize(quanti)
	tutti.fill(PIENO)
	return tutti


static func tinte(quante: int, tinta: Color) -> PackedColorArray:
	var tutte := PackedColorArray()
	tutte.resize(quante)
	tutte.fill(tinta)
	return tutte


func disegna_buchi(tela: CanvasItem, eta: float, ridotto: bool, quanto: float) -> void:
	# dove un pezzo e' saltato via resta un buco: dietro il vetro e' buio, e
	# intorno si vede il vetro di taglio - chiaro dalla parte in ombra, che e'
	# quella che la luce prende di fronte - e sotto un filo d'ombra
	for pezzo in pezzi:
		if not staccato(pezzo, eta, ridotto):
			continue
		var punti: PackedVector2Array = pezzo["punti"]
		Manifesto.poligono(tela, punti, Color(0.03, 0.0, 0.02, 0.82 * quanto))
		var dentro := Manifesto.scosta(punti, -1.6)
		for i in dentro.size():
			var a := dentro[i]
			var b := dentro[(i + 1) % dentro.size()]
			var verso := (b - a).normalized().orthogonal()
			var luce := absf(verso.dot(VetroRotto.LUCE))
			VetroRotto.striscia(tela, PackedVector2Array([a, b]), PackedFloat32Array([2.2, 2.2]),
					PackedFloat32Array([1.0, 1.0]), Color(TAGLIO, (0.35 + 0.55 * luce) * quanto))
