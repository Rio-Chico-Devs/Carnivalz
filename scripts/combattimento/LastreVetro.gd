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
#   - i pezzi attaccati all'impatto SALTANO, e saltando si spezzano in due,
#     tre, quattro SCHEGGE che partono quasi insieme. Ogni scheggia si porta
#     dietro il suo pezzo di immagine, ti viene addosso ingrandendosi, gira
#     anche in profondita' (si schiaccia e si rovescia) e quando si gira verso
#     la luce lampeggia. Si vede appena - e' vetro: quello che c'e' dietro, un
#     velo freddo, la luce sui bordi - e fa un'OMBRA che resta indietro. Ha uno
#     SPESSORE - il vetro di taglio, verdino come il vetro vero - che si vede
#     quando la scheggia e' girata di costa
#   - dove c'erano resta un BUCO: dietro si vede meglio, non peggio. Lo si
#     riconosce dal bordo vivo del vetro intorno e dall'ombra appena dentro
#
# Col movimento ridotto i pezzi sono spostati e fermi: niente strappo, niente
# pezzi che saltano, niente buchi.

const SPINTA := 4.5            # quanto si sposta di serie un pezzo vicino all'impatto
const STRAPPO := 0.9           # quanto di piu' nel colpo
const SCOSSONE := 0.2          # quanto ci mette lo strappo ad assestarsi
const CADE_DA := 0.1           # quando i pezzi dell'impatto si staccano
const CADUTA := 0.55           # quanto ci mettono a volare via
const PICCOLO := 2.5           # in raggi: fin dove arriva uno spicchio che puo' cadere anche senza giro
const BUIO := 0.22             # quanto e' scuro un buco: poco, dietro si deve vedere
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
	# almeno due pezzi si staccano, se ce ne sono: e' il colpo che sfonda. Uno
	# solo, piccolo, era un buco col compasso
	var attaccati := pezzi.filter(func(pezzo: Dictionary) -> bool: return puo_cadere(pezzo) and not bool(pezzo["cade"]))
	var staccati := pezzi.filter(func(pezzo: Dictionary) -> bool: return bool(pezzo["cade"])).size()
	while staccati < 2 and not attaccati.is_empty():
		(attaccati.pop_at(d.randi() % attaccati.size()) as Dictionary)["cade"] = true
		staccati += 1
	for pezzo in pezzi:
		if bool(pezzo["cade"]):
			pezzo["frammenti"] = frammenta(d, pezzo)


func puo_cadere(pezzo: Dictionary) -> bool:
	# solo un pezzo attaccato all'impatto, e piccolo: chiuso dal primo giro,
	# o - vicino a un angolo, dove il primo giro non ci sta - uno spicchio che
	# arriva al bordo dopo pochi passi. Uno spicchio lungo che vola via
	# porterebbe mezzo riquadro con se'
	return float(pezzo["distanza"]) == 0.0 and (bool(pezzo["stretto"]) or float(pezzo["fin_dove"]) <= r * PICCOLO)


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
		# il giro e' un arco: i suoi punti di mezzo chiudono il pezzo di dentro
		# andando da sinistra a destra, e aprono quello di fuori all'indietro
		var arco := giro["punti"] as PackedVector2Array
		var interni := arco.slice(1, arco.size() - 1)
		var a_s := int(giro["ia"])
		var a_d := int(giro["ib"])
		if a_s < da_s or a_d < da_d:
			continue
		aggiungi(d, cuci(sinistra, da_s, a_s, interni, destra, da_d, a_d, dentro),
				distanza, int(giro["giro"]) == 0)
		da_s = a_s
		da_d = a_d
		dentro = interni.duplicate()
		dentro.reverse()
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
			"cade": stretto and d.randf() < 0.55,
			"vola": Vector2(d.randf_range(-1.0, 1.0), d.randf_range(-1.7, -0.7)) * r * 2.6,
			"rotola": d.randf_range(-4.0, 4.0),
			"asse": Vector2.from_angle(d.randf() * TAU),
			"capriola": d.randf_range(5.0, 11.0) * (1.0 if d.randf() < 0.5 else -1.0)})


func frammenta(d: RandomNumberGenerator, pezzo: Dictionary) -> Array[Dictionary]:
	# UN PEZZO CHE SALTA NON RESTA INTERO: si spezza in due, tre, quattro
	# schegge, e ognuna va per conto suo. Interi, i pezzi erano quattro o cinque
	# triangoli grigi grandi che giravano insieme come le pale di un mulino.
	# Si taglia ogni volta la scheggia piu' grande, di traverso al suo verso
	# lungo, cosi' non escono aghi
	var parti: Array[PackedVector2Array] = [pezzo["punti"]]
	var quante := d.randi_range(2, 4)
	while parti.size() < quante:
		parti.sort_custom(func(a: PackedVector2Array, b: PackedVector2Array) -> bool: return absf(superficie(a)) > absf(superficie(b)))
		var spezzate := spezza(d, parti[0])
		if spezzate.is_empty():
			break
		parti.pop_front()
		parti.append_array(spezzate)
	var frammenti: Array[Dictionary] = []
	var da: Vector2 = pezzo["centro"]
	for parte in parti:
		var centro := centro_di(parte)
		# ognuna scappa dal centro del pezzo, oltre che verso di te
		var fuori := (centro - da).normalized() * r * d.randf_range(0.8, 2.2)
		frammenti.append({"punti": parte, "indici": Geometry2D.triangulate_polygon(parte), "centro": centro,
				"vola": (pezzo["vola"] as Vector2) * d.randf_range(0.75, 1.2) + fuori,
				"rotola": d.randf_range(-7.0, 7.0),
				"asse": Vector2.from_angle(d.randf() * TAU),
				"capriola": d.randf_range(6.0, 14.0) * (1.0 if d.randf() < 0.5 else -1.0),
				"parte": d.randf_range(0.0, 0.05),
				"fase": d.randf() * TAU})
	return frammenti


static func spezza(d: RandomNumberGenerator, grande: PackedVector2Array) -> Array[PackedVector2Array]:
	# una scheggia tagliata in due da una retta di traverso al suo verso lungo,
	# vicino al mezzo. Un pezzo lungo e stretto puo' venire male (una delle due
	# meta' quasi niente): si riprova un poco piu' in mezzo e piu' di traverso.
	# Vuoto se non si spezza: una briciola resta intera
	var centro := centro_di(grande)
	var lungo := Vector2.RIGHT
	for p in grande:
		if p.distance_to(centro) > lungo.length():
			lungo = p - centro
	for prova in 4:
		var stretta := 1.0 - float(prova) / 4.0
		var taglio := lungo.normalized().orthogonal().rotated(d.randf_range(-0.45, 0.45) * stretta)
		var dove := centro + lungo * d.randf_range(-0.2, 0.2) * stretta
		var spezzate := meta_di(grande, dove, taglio, 1.0)
		spezzate.append_array(meta_di(grande, dove, taglio, -1.0))
		if spezzate.size() >= 2:
			return spezzate
	return []


static func meta_di(grande: PackedVector2Array, dove: Vector2, taglio: Vector2, verso: float) -> Array[PackedVector2Array]:
	# quello che di 'grande' sta da una parte della retta per 'dove' lungo
	# 'taglio' (verso: quale parte). Le briciole si buttano
	var lato := taglio.orthogonal() * 2000.0 * verso
	var meta := PackedVector2Array([dove - taglio * 2000.0, dove + taglio * 2000.0, dove + taglio * 2000.0 + lato, dove - taglio * 2000.0 + lato])
	var parti: Array[PackedVector2Array] = []
	for parte in Geometry2D.intersect_polygons(grande, meta):
		if absf(superficie(parte)) > 4.0 and not Geometry2D.triangulate_polygon(parte).is_empty():
			parti.append(parte)
	return parti


static func superficie(punti: PackedVector2Array) -> float:
	var somma := 0.0
	for i in punti.size():
		somma += punti[i].cross(punti[(i + 1) % punti.size()])
	return somma * 0.5


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


func posa_in_volo(scheggia: Dictionary, t: float) -> PackedVector2Array:
	# dove sono adesso i vertici di una scheggia saltata via, t secondi dopo
	# che e' partita: vola verso di te (si ingrandisce), gira nel piano, fa la
	# capriola in profondita' (si schiaccia lungo il suo asse, fino a
	# rovesciarsi) e la gravita' se la porta giu'
	var centro: Vector2 = scheggia["centro"]
	var dove := centro + (scheggia["vola"] as Vector2) * t + Vector2(0.0, VetroRotto.GRAVITA) * t * t * 0.5
	var giro := float(scheggia["rotola"]) * t
	var grande := lerpf(1.0, 1.5, t / CADUTA)
	var asse: Vector2 = scheggia["asse"]
	var schiaccia := cos(float(scheggia["capriola"]) * t)
	var punti := PackedVector2Array()
	for p: Vector2 in scheggia["punti"]:
		var q := p - centro
		q += asse * q.dot(asse) * (schiaccia - 1.0)
		punti.append(dove + q.rotated(giro) * grande)
	return punti


func schegge_in_volo(eta: float, ridotto: bool) -> Array[Dictionary]:
	# le schegge in aria adesso, ognuna col suo tempo: {scheggia, t, punti}.
	# Partono quasi insieme - ognuna un attimo dopo l'altra - e finiscono
	# insieme; prima di partire stanno ferme al loro posto
	var volano: Array[Dictionary] = []
	var dal_distacco := eta - CADE_DA
	if ridotto or dal_distacco < 0.0 or dal_distacco >= CADUTA:
		return volano
	for pezzo in pezzi:
		if not bool(pezzo["cade"]):
			continue
		for scheggia: Dictionary in pezzo["frammenti"]:
			var t := maxf(dal_distacco - float(scheggia["parte"]), 0.0)
			volano.append({"scheggia": scheggia, "t": t, "punti": posa_in_volo(scheggia, t)})
	return volano


func in_volo(eta: float, ridotto: bool) -> Array[PackedVector2Array]:
	# le schegge saltate via, dove sono adesso
	var volano: Array[PackedVector2Array] = []
	for volante in schegge_in_volo(eta, ridotto):
		volano.append(volante["punti"])
	return volano


static func lampo_di(scheggia: Dictionary, t: float) -> float:
	# quando la capriola gira la scheggia verso la luce, lampeggia: per un
	# attimo, non sempre
	return pow(absf(cos(float(scheggia["capriola"]) * t * 0.5 + float(scheggia["fase"]))), 10.0)


static func freddo(luce: float, alfa: float) -> Color:
	# come grigio(), ma il vetro schiarisce un poco verso l'azzurro: e' vetro,
	# non carta
	return Color(0.5 + luce * 0.42, 0.5 + luce * 0.48, 0.5 + luce * 0.5, alfa)


func disegna_in_volo(tela: CanvasItem, eta: float, ridotto: bool) -> void:
	# le schegge in volo, sulla tela con lo shader. Prima le ombre, tutte:
	# un'ombra sopra un'altra scheggia la sporcherebbe. Poi per ognuna lo
	# spessore, la scheggia con la sua immagine, il bordo che prende la luce.
	# Erano pezzi grigi chiari, opachi come cartone: il vetro si vede appena -
	# quello che c'e' dietro, spostato, un velo freddo, e la luce sui bordi
	var volano := schegge_in_volo(eta, ridotto)
	if volano.is_empty():
		return
	var u := (eta - CADE_DA) / CADUTA
	var alfa := 1.0 - u * u * u
	# L'OMBRA: la scheggia ti viene incontro, e la sua ombra sul vetro resta
	# indietro, sempre piu' lontana e piu' tenue
	for volante: Dictionary in volano:
		var ombra := PackedVector2Array()
		for p: Vector2 in volante["punti"]:
			ombra.append(p - VetroRotto.LUCE * (2.0 + r * 0.5 * u))
		var scheggia: Dictionary = volante["scheggia"]
		lastra(tela, ombra, scheggia["indici"], pieni(ombra.size()), tinte(ombra.size(), Color(0.02, 0.0, 0.03, 0.3 * (1.0 - u))))
	for volante: Dictionary in volano:
		disegna_costa(tela, volante["scheggia"], volante["punti"], float(volante["t"]), alfa)
		disegna_scheggia(tela, volante["scheggia"], volante["punti"], float(volante["t"]), alfa)


func disegna_costa(tela: CanvasItem, scheggia: Dictionary, punti: PackedVector2Array, t: float, alfa: float) -> void:
	# LO SPESSORE: il vetro di taglio. Si vede di piu' quando la scheggia e'
	# girata di costa, e spunta dalla parte verso cui si gira
	var giro := float(scheggia["rotola"]) * t
	var schiaccia := cos(float(scheggia["capriola"]) * t)
	var costa := (scheggia["asse"] as Vector2).rotated(giro) * (1.0 + 2.6 * (1.0 - absf(schiaccia))) \
			* signf(sin(float(scheggia["capriola"]) * t) + 0.001)
	var con_spessore := punti.duplicate()
	for p in punti:
		con_spessore.append(p + costa)
	# solo la costa che spunta fuori dalla scheggia: tutta, si vedeva verde
	# attraverso la scheggia quando sfuma
	var guscio := Geometry2D.convex_hull(con_spessore)
	if guscio.size() < 4:
		return
	guscio.resize(guscio.size() - 1)
	# (se la scheggia stesse tutta dentro, il ritaglio darebbe il guscio
	# intero e il suo buco: troppo grandi per essere la costa, si saltano)
	var costa_massima := absf(superficie(guscio)) - absf(superficie(punti)) * 0.5
	for fuori in Geometry2D.clip_polygons(guscio, punti):
		if absf(superficie(fuori)) < costa_massima:
			lastra(tela, fuori, Geometry2D.triangulate_polygon(fuori), pieni(fuori.size()),
					tinte(fuori.size(), Color(TAGLIO.darkened(0.35), 0.7 * alfa)))


func disegna_scheggia(tela: CanvasItem, scheggia: Dictionary, punti: PackedVector2Array, t: float, alfa: float) -> void:
	# la scheggia: guarda dietro da dove veniva ogni vertice; un riflesso le
	# scivola sopra mentre gira, e quando si volta verso la luce lampeggia
	var origine: PackedVector2Array = scheggia["punti"]
	var lampo := lampo_di(scheggia, t)
	var centro := centro_di(punti)
	var grande := 1.0
	for p in punti:
		grande = maxf(grande, p.distance_to(centro))
	var riflesso := Vector2.from_angle(float(scheggia["fase"]) + float(scheggia["capriola"]) * t * 0.5)
	var spostamenti := PackedVector2Array()
	var colori := PackedColorArray()
	for i in punti.size():
		spostamenti.append(origine[i] - punti[i])
		var di_qua := clampf((punti[i] - centro).dot(riflesso) / grande, -1.0, 1.0)
		colori.append(freddo(0.06 + 0.22 * di_qua + 0.3 * lampo * (0.6 + 0.4 * di_qua), alfa))
	lastra(tela, punti, scheggia["indici"], spostamenti, colori)
	bordo_in_luce(tela, punti, alfa * (0.7 + 0.3 * lampo))


func disegna_lampi(tela: CanvasItem, eta: float, ridotto: bool) -> void:
	# sulla tela che somma: quando una scheggia lampeggia, i suoi bordi verso
	# la luce si accendono
	var volano := schegge_in_volo(eta, ridotto)
	var u := (eta - CADE_DA) / CADUTA
	for volante: Dictionary in volano:
		var lampo := lampo_di(volante["scheggia"], float(volante["t"]))
		if lampo < 0.15:
			continue
		var punti: PackedVector2Array = volante["punti"]
		var giro := punti.duplicate()
		giro.append(punti[0])
		var larghi := PackedFloat32Array()
		var luci := PackedFloat32Array()
		for i in giro.size():
			larghi.append(5.0)
			var dopo := giro[mini(i + 1, giro.size() - 1)] - giro[maxi(i - 1, 0)]
			luci.append(clampf(dopo.normalized().orthogonal().dot(VetroRotto.LUCE) * -1.0, 0.0, 1.0) + 0.15)
		VetroRotto.striscia_morbida(tela, giro, larghi, Color(VetroRotto.TINTA.lerp(Color.WHITE, 0.5), 0.55 * lampo * (1.0 - u)), luci)


func bordo_in_luce(tela: CanvasItem, punti: PackedVector2Array, alfa: float) -> void:
	# il bordo del pezzo: chiaro dove guarda la luce, scuro dove no
	var giro := 0.0
	for i in punti.size():
		giro += punti[i].cross(punti[(i + 1) % punti.size()])
	var fuori := 1.0 if giro > 0.0 else -1.0
	for i in punti.size():
		var a := punti[i]
		var b := punti[(i + 1) % punti.size()]
		var normale := (b - a).normalized().orthogonal() * -fuori
		var verso_luce := normale.dot(-VetroRotto.LUCE)
		var tinta := Color(1.0, 1.0, 1.0, alfa * clampf(verso_luce + 0.35, 0.0, 1.0)) if verso_luce > -0.2 \
				else Color(0.0, 0.0, 0.0, alfa * 0.6 * clampf(-verso_luce + 0.2, 0.0, 1.0))
		VetroRotto.striscia(tela, PackedVector2Array([a, b]), PackedFloat32Array([1.5, 1.5]),
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
	# DOVE UN PEZZO E' SALTATO VIA, IL VETRO NON C'E' PIU': dietro si vede
	# meglio, non peggio. Il buco si riconosce dal suo bordo - il vetro di
	# taglio, chiaro, tutto intorno - e dall'ombra che il bordo fa appena dentro.
	# Era un buco nero quasi pieno: copriva i pugni che si accendevano sotto
	for pezzo in pezzi:
		if not staccato(pezzo, eta, ridotto):
			continue
		var punti: PackedVector2Array = pezzo["punti"]
		Manifesto.poligono(tela, punti, Color(0.03, 0.0, 0.02, BUIO * quanto))
		var dentro := Manifesto.scosta(punti, -3.0)
		dentro.append(dentro[0])
		var larghi := PackedFloat32Array()
		var luci := PackedFloat32Array()
		for i in dentro.size():
			larghi.append(6.0)
			luci.append(1.0)
		VetroRotto.striscia_morbida(tela, dentro, larghi, Color(0.02, 0.0, 0.03, 0.55 * quanto), luci)
		var orlo := Manifesto.scosta(punti, -1.2)
		for i in orlo.size():
			var a := orlo[i]
			var b := orlo[(i + 1) % orlo.size()]
			var verso := (b - a).normalized().orthogonal()
			var luce := absf(verso.dot(VetroRotto.LUCE))
			VetroRotto.striscia(tela, PackedVector2Array([a, b]), PackedFloat32Array([2.0, 2.0]),
					PackedFloat32Array([1.0, 1.0]), Color(TAGLIO, (0.4 + 0.55 * luce) * quanto))
