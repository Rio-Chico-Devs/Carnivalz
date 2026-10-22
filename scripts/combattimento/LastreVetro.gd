class_name LastreVetro
extends RefCounted
# I PEZZI DEL VETRO ROTTO (VetroRotto.gd), cioe' il vetro fra le crepe.
#
# Bru, sul vetro con le linee nuove: «migliora ancora di più l'effetto di
# quando vieni colpito che si spacca il vetro». Le crepe da sole sono un
# disegno sopra lo schermo; un vetro rotto si riconosce perche' quello che c'e'
# DIETRO non combacia piu'. Quindi il vetro si taglia in pezzi lungo le crepe:
#   - ogni SPICCHIO fra due crepe principali, dall'impatto fino al bordo, e
#     dentro lo spicchio un pezzo per ogni giro di ragnatela che lo attraversa
#     (dove il giro ha un buco, i due pezzi sono uno solo: non c'e' crepa che
#     li separi)
#   - ogni pezzo sposta di qualche pixel quello che c'e' dietro, in fuori e un
#     poco di sbieco, di piu' vicino all'impatto; e prende la luce a modo suo.
#     Lo fa lo shader (shaders/vetro_lastre.gdshader), che scompone anche un
#     filo la luce ai bordi
#   - nel colpo i pezzi STRAPPANO: per un attimo si spostano molto di piu', poi
#     si assestano
#   - i pezzi attaccati all'impatto si STACCANO: volano verso di te, girando e
#     cadendo, e dove c'erano resta un buco scuro
# I pezzi coprono il vetro tutto, senza buchi e senza sovrapporsi: e' quello
# che fa combaciare lo spostamento con le crepe disegnate sopra.
#
# Col movimento ridotto i pezzi sono spostati e fermi: niente strappo, niente
# pezzi che volano, niente buchi.

const SPINTA_MASSIMA := 16.0   # pixel: quanto vale 0 o 1 nel colore (la stessa dello shader)
const SPINTA := 5.0            # quanto si sposta di serie un pezzo vicino all'impatto
const STRAPPO := 1.6           # quanto di piu' nel colpo
const SCOSSONE := 0.2          # quanto ci mette lo strappo ad assestarsi
const CADE_DA := 0.12          # quando i pezzi dell'impatto si staccano
const CADUTA := 0.5            # quanto ci mettono a volare via

# del vetro si tengono i numeri, non il vetro: il vetro tiene i suoi pezzi, e
# se i pezzi tenessero il vetro nessuno dei due verrebbe mai liberato
var impatto := Vector2.ZERO
var r := 30.0
var bordo := Rect2()
# {punti, spinta, luce, distanza, cade, stretto, centro, vola, rotola}
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
	for p in punti:
		centro += p
	centro /= maxf(float(punti.size()), 1.0)
	var lontano := clampf(centro.distance_to(impatto) / (r * 8.0), 0.0, 1.0)
	var verso := (centro - impatto).normalized().rotated(d.randf_range(-0.7, 0.7))
	# la luce cambia poco, e quasi niente nei pezzi grandi lontano
	# dall'impatto: uno spicchio che arriva al bordo e' mezzo riquadro, e un
	# mezzo riquadro piu' scuro o piu' chiaro non e' un vetro, e' un'ombra
	pezzi.append({"punti": punti, "distanza": distanza, "centro": centro, "stretto": stretto, "lontano": lontano,
			"spinta": verso * SPINTA * lerpf(1.0, 0.3, lontano) * d.randf_range(0.6, 1.0),
			"luce": d.randf_range(-0.25, 0.25) * (1.0 - lontano),
			"cade": stretto and d.randf() < 0.5,
			"vola": Vector2(d.randf_range(-1.0, 1.0), d.randf_range(-1.6, -0.6)) * r * 2.5,
			"rotola": d.randf_range(-6.0, 6.0)})


# --- il disegno -------------------------------------------------------------

static func strappo(eta: float, ridotto: bool) -> float:
	# quanto di piu' sono spostati i pezzi: molto nel colpo, poi si assestano
	if ridotto:
		return 1.0
	return 1.0 + STRAPPO * (1.0 - smoothstep(0.0, SCOSSONE, eta))


static func codice(spinta: Vector2, luce: float, alfa: float) -> Color:
	# lo spostamento e la luce, scritti nel colore come li legge lo shader
	var su := (spinta / (2.0 * SPINTA_MASSIMA)).clamp(Vector2(-0.5, -0.5), Vector2(0.5, 0.5))
	return Color(0.5 + su.x, 0.5 + su.y, clampf(0.5 + luce * 0.5, 0.0, 1.0), alfa)


func disegna(tela: CanvasItem, eta: float, ridotto: bool, arrivate: float, quanto: float) -> void:
	# i pezzi, sulla tela che ha lo shader. "arrivate": fin dove sono arrivate
	# le crepe, in pixel dall'impatto - un pezzo c'e' quando le crepe ci sono
	# arrivate. Un pezzo che si e' staccato non c'e' piu'
	var quanto_strappa := strappo(eta, ridotto)
	for pezzo in pezzi:
		if arrivate < float(pezzo["distanza"]):
			continue
		if staccato(pezzo, eta, ridotto):
			continue
		# un luccichio attraversa i pezzi dal centro in fuori, appena rotti
		var luccica := 0.0
		if not ridotto:
			luccica = 0.4 * (1.0 - float(pezzo["lontano"])) \
					* exp(-pow((eta - float(pezzo["distanza"]) / (r * 18.0) - 0.05) / 0.05, 2.0))
		Manifesto.poligono(tela, pezzo["punti"], codice((pezzo["spinta"] as Vector2) * quanto_strappa,
				float(pezzo["luce"]) + luccica, quanto))


static func staccato(pezzo: Dictionary, eta: float, ridotto: bool) -> bool:
	return bool(pezzo["cade"]) and not ridotto and eta >= CADE_DA


func in_volo(eta: float, ridotto: bool) -> Array[PackedVector2Array]:
	# i pezzi che si sono staccati, dove sono adesso: volano verso di te (si
	# ingrandiscono), girano, e la gravita' se li porta giu'
	var volano: Array[PackedVector2Array] = []
	var t := eta - CADE_DA
	if ridotto or t < 0.0 or t >= CADUTA:
		return volano
	for pezzo in pezzi:
		if not bool(pezzo["cade"]):
			continue
		var centro: Vector2 = pezzo["centro"]
		var dove := centro + (pezzo["vola"] as Vector2) * t + Vector2(0.0, VetroRotto.GRAVITA) * t * t * 0.5
		var giro := float(pezzo["rotola"]) * t
		var grande := lerpf(1.0, 1.6, t / CADUTA)
		var punti := PackedVector2Array()
		for p: Vector2 in pezzo["punti"]:
			punti.append(dove + (p - centro).rotated(giro) * grande)
		volano.append(punti)
	return volano


func disegna_buchi(tela: CanvasItem, eta: float, ridotto: bool, quanto: float) -> void:
	# dove un pezzo si e' staccato resta un buco: dietro il vetro e' buio
	for pezzo in pezzi:
		if staccato(pezzo, eta, ridotto):
			Manifesto.poligono(tela, pezzo["punti"], Color(0.03, 0.0, 0.02, 0.7 * quanto))


func disegna_in_volo(tela: CanvasItem, eta: float, ridotto: bool) -> void:
	# i pezzi in volo: vetro chiaro col bordo che brilla, e sfumano andando
	var t := clampf((eta - CADE_DA) / CADUTA, 0.0, 1.0)
	for punti in in_volo(eta, ridotto):
		Manifesto.poligono(tela, punti, Color(VetroRotto.VETRO_CHIARO, 0.4 * (1.0 - t)))
		var giro := punti.duplicate()
		giro.append(punti[0])
		var larghi := PackedFloat32Array()
		larghi.resize(giro.size())
		larghi.fill(1.6)
		var luci := PackedFloat32Array()
		luci.resize(giro.size())
		luci.fill(1.2)
		VetroRotto.striscia(tela, giro, larghi, luci, Color(VetroRotto.VETRO_CHIARO, 1.0 - t))
