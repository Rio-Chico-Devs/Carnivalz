class_name VetroRotto
extends RefCounted
# IL VETRO CHE SI ROMPE QUANDO UN PUGNO TI PRENDE (la raffica, RiquadroRaffica).
#
# Bru: «concentriamoci più che altro sull'effetto vetro rotto quando ricevi i
# colpi nel videogioco attualmente è abbastanza brutto». Prima erano sei rami
# storti rossi e bianchi, corti, intorno al pugno: uno scarabocchio, non un
# vetro. Adesso e' la stessa lingua delle crepe dell'orologio che Bru ha
# approvato (Crepe.gd: impatto, principali quasi dritte con lo strappo secco, il
# filo che si assottiglia), portata sul vetro dello schermo del cabinato:
#   - nel punto in cui il pugno ti prende il vetro e' SCHIACCIATO: un piccolo
#     cratere chiaro, con un lampo
#   - da li' corrono le crepe PRINCIPALI, ad angoli disuguali, fino al bordo
#     del vetro; qualcuna si biforca; intorno all'impatto, le crepe minute
#   - fra due principali vicine, gli ANELLI della ragnatela: due giri, a tratti
#     storti e con qualche buco
#   - le FACCE fra crepe e anelli prendono la luce ognuna a modo suo (un velo
#     chiaro o scuro, appena), e un luccichio le attraversa dal centro
#   - qualche SCHEGGIA salta via e cade
# Il filo ha l'ombra: una riga scura accanto a quella chiara, e' cosi' che un
# taglio nel vetro si legge sopra qualunque cosa ci sia dietro.
#
# TUTTO DAL SEME E DALL'ETA': la stessa crepa a ogni ridisegno, un'altra a ogni
# pugno, e nessuno stato da far avanzare fotogramma per fotogramma. Col
# movimento ridotto la crepa c'e' subito, intera, senza lampo, senza luccichio
# e senza schegge, e se ne va sfumando come le altre.

const DURATA := 1.15         # quanto resta il vetro rotto: poco, i pugni dopo vanno letti
const SVANISCE := 0.45       # gli ultimi secondi, in cui sfuma
const CORSA := 0.11          # quanto ci mettono le principali ad arrivare al bordo
const LAMPO := 0.14
const VITA_SCHEGGE := 0.55
const GRAVITA := 900.0

var impatto := Vector2.ZERO
var vetro := Rect2()          # fin dove arriva il vetro (il piano della raffica)
var r := 30.0                 # il raggio del pugno: la misura di tutto
var principali: Array[PackedVector2Array] = []
var rami: Array[Dictionary] = []      # {punti, nasce, pieno}: biforcazioni e crepe minute
var anelli: Array[Dictionary] = []    # {punti, distanza}
var facce: Array[Dictionary] = []     # {punti, tinta, distanza}
var cratere := PackedVector2Array()
var schegge: Array[Dictionary] = []   # {velocita, giro, lato, angolo}


func _init(seme: int, dove: Vector2, piano: Rect2, raggio: float) -> void:
	var d := RandomNumberGenerator.new()
	d.seed = seme
	impatto = dove
	vetro = piano.grow(-2.0)
	r = maxf(raggio, 6.0)
	tira_principali(d)
	for punti in principali:
		biforca(d, punti)
	minute(d)
	tira_anelli(d)
	tira_cratere(d)
	tira_schegge(d)


# --- la rete ----------------------------------------------------------------

func tira_principali(d: RandomNumberGenerator) -> void:
	# da cinque a sette, ad angoli disuguali ma senza buchi grandi: in ordine
	# di angolo, cosi' due vicine nella lista sono vicine nel vetro
	var quante := 5 + d.randi() % 3
	var angolo := d.randf() * TAU
	var spicchio := TAU / float(quante)
	for i in quante:
		var verso := angolo + spicchio * (float(i) + d.randf_range(-0.32, 0.32))
		principali.append(cammina(d, impatto, verso, INF))


func cammina(d: RandomNumberGenerator, da: Vector2, angolo: float, massimo: float) -> PackedVector2Array:
	# una crepa che corre fino al bordo del vetro (o per 'massimo' pixel): quasi
	# dritta, con un filo di tremito, e ogni tanto uno strappo secco
	var punti := PackedVector2Array([da])
	var verso := angolo
	var fatta := 0.0
	for passo in 400:
		verso += d.randf_range(-0.045, 0.045)
		if d.randf() < 0.08:
			verso += d.randf_range(0.15, 0.35) * (1.0 if d.randf() < 0.5 else -1.0)
		var lungo := r * d.randf_range(0.12, 0.2)
		var dopo := punti[punti.size() - 1] + Vector2.from_angle(verso) * lungo
		fatta += lungo
		if not vetro.has_point(dopo):
			punti.append(sul_bordo(punti[punti.size() - 1], dopo))
			break
		punti.append(dopo)
		if fatta >= massimo:
			break
	return punti


func sul_bordo(dentro: Vector2, fuori: Vector2) -> Vector2:
	# dove il passo esce dal vetro
	for k in 12:
		var mezzo := dentro.lerp(fuori, 0.5)
		if vetro.has_point(mezzo):
			dentro = mezzo
		else:
			fuori = mezzo
	return dentro


func biforca(d: RandomNumberGenerator, punti: PackedVector2Array) -> void:
	# da un punto a meta' di una principale, di sbieco; non sempre, e non
	# sempre fino al bordo
	if d.randf() < 0.45 or punti.size() < 8:
		return
	var da := d.randi_range(int(punti.size() * 0.25), int(punti.size() * 0.6))
	var verso := (punti[da + 1] - punti[da]).angle() + d.randf_range(0.35, 0.8) * (1.0 if d.randf() < 0.5 else -1.0)
	var quando := Crepe.lunghezza(punti.slice(0, da + 1)) / maxf(Crepe.lunghezza(punti), 1.0)
	rami.append({"punti": cammina(d, punti[da], verso, r * d.randf_range(2.0, 5.0)), "nasce": quando, "pieno": 0.62})


func minute(d: RandomNumberGenerator) -> void:
	# la stellina di crepe minute intorno all'impatto
	for i in 8:
		var verso := d.randf() * TAU
		rami.append({"punti": cammina(d, impatto + Vector2.from_angle(verso) * r * 0.12, verso, r * d.randf_range(0.3, 0.75)),
				"nasce": 0.0, "pieno": 0.45})


func tira_anelli(d: RandomNumberGenerator) -> void:
	# tre giri di ragnatela: fra due principali vicine, un tratto storto alla
	# stessa distanza dall'impatto, che si piega un poco verso il centro
	var giri: Array[float] = [r * d.randf_range(1.25, 1.6), r * d.randf_range(2.6, 3.3), r * d.randf_range(4.6, 5.6)]
	for j in giri.size():
		var dentro := r * 0.22 if j == 0 else giri[j - 1]
		for k in principali.size():
			anello_fra(d, principali[k], principali[(k + 1) % principali.size()], giri[j], dentro)


func anello_fra(d: RandomNumberGenerator, una: PackedVector2Array, altra: PackedVector2Array,
		distanza: float, dentro: float) -> void:
	var a := sulla_crepa(una, distanza * d.randf_range(0.92, 1.08))
	var b := sulla_crepa(altra, distanza * d.randf_range(0.92, 1.08))
	if a == Vector2.INF or b == Vector2.INF:
		return
	# la faccia fra questo giro e quello dentro: un velo chiaro o scuro, appena
	var a0 := sulla_crepa(una, dentro)
	var b0 := sulla_crepa(altra, dentro)
	var chiara := d.randf() < 0.55
	if a0 != Vector2.INF and b0 != Vector2.INF:
		facce.append({"punti": PackedVector2Array([a0, a, b, b0]), "distanza": distanza,
				"tinta": Color(Color.WHITE if chiara else Color.BLACK, d.randf_range(0.05, 0.14))})
	# un buco nella ragnatela, piu' spesso lontano dall'impatto
	if d.randf() < clampf(distanza / (r * 14.0), 0.15, 0.4):
		return
	var tratto := PackedVector2Array([a])
	for s in range(1, 3):
		var su := a.lerp(b, float(s) / 3.0)
		su += (impatto - su).normalized() * r * d.randf_range(0.0, 0.12)
		su += (b - a).orthogonal().normalized() * r * d.randf_range(-0.05, 0.05)
		tratto.append(su)
	tratto.append(b)
	anelli.append({"punti": tratto, "distanza": distanza})


func sulla_crepa(punti: PackedVector2Array, distanza: float) -> Vector2:
	# il primo punto della crepa a quella distanza dall'impatto; INF se non ci arriva
	for p in punti:
		if p.distance_to(impatto) >= distanza:
			return p
	return Vector2.INF


func tira_cratere(d: RandomNumberGenerator) -> void:
	for k in 9:
		cratere.append(impatto + Vector2.from_angle(TAU * float(k) / 9.0 + d.randf_range(-0.2, 0.2))
				* r * d.randf_range(0.14, 0.26))


func tira_schegge(d: RandomNumberGenerator) -> void:
	for k in 9:
		var verso := d.randf() * TAU
		schegge.append({"velocita": Vector2.from_angle(verso) * r * d.randf_range(4.0, 9.0) + Vector2(0.0, -r * 3.0),
				"giro": d.randf_range(-12.0, 12.0), "lato": r * d.randf_range(0.1, 0.24), "angolo": d.randf() * TAU})


# --- il tempo ---------------------------------------------------------------

static func corsa(eta: float, ridotto: bool) -> float:
	# fin dove sono arrivate le principali (0..1): arrivano frenando
	if ridotto:
		return 1.0
	return 1.0 - pow(1.0 - clampf(eta / CORSA, 0.0, 1.0), 3.0)


static func luce(eta: float) -> float:
	# quanto si vede: tutto, poi sfuma negli ultimi SVANISCE secondi
	return 1.0 - clampf((eta - (DURATA - SVANISCE)) / SVANISCE, 0.0, 1.0)


func schegge_vive(eta: float, ridotto: bool) -> Array[PackedVector2Array]:
	# i triangoli in volo adesso, gia' al loro posto
	var vive: Array[PackedVector2Array] = []
	if ridotto or eta >= VITA_SCHEGGE:
		return vive
	for s in schegge:
		var dove := impatto + (s["velocita"] as Vector2) * eta + Vector2(0.0, GRAVITA) * eta * eta * 0.5
		var giro := float(s["angolo"]) + float(s["giro"]) * eta
		var lato := float(s["lato"])
		vive.append(PackedVector2Array([dove + Vector2.from_angle(giro) * lato,
				dove + Vector2.from_angle(giro + 2.3) * lato * 0.7, dove + Vector2.from_angle(giro + 4.1) * lato * 0.85]))
	return vive


# --- il disegno -------------------------------------------------------------

func disegna(tela: CanvasItem, eta: float, ridotto: bool) -> void:
	var quanto := luce(eta)
	if quanto <= 0.0:
		return
	var fino := corsa(eta, ridotto)
	disegna_facce(tela, eta, fino, quanto, ridotto)
	for punti in principali:
		taglio(tela, Crepe.taglia(punti, fino), Crepe.lunghezza(punti), r * 0.085, quanto, fino)
	for ramo in rami:
		var suo := clampf((fino - float(ramo["nasce"])) / maxf(1.0 - float(ramo["nasce"]), 0.2), 0.0, 1.0)
		if suo > 0.0:
			var punti: PackedVector2Array = ramo["punti"]
			taglio(tela, Crepe.taglia(punti, suo), Crepe.lunghezza(punti), r * 0.075 * float(ramo["pieno"]), quanto, suo)
	for anello in anelli:
		# un giro c'e' quando le principali ci sono arrivate
		if fino * lunghezza_tipica() >= float(anello["distanza"]):
			var punti: PackedVector2Array = anello["punti"]
			taglio(tela, punti, Crepe.lunghezza(punti) * 2.5, r * 0.05, quanto * 0.85, 1.0)
	disegna_cratere(tela, eta, quanto, ridotto)
	for scheggia in schegge_vive(eta, ridotto):
		Manifesto.poligono(tela, scheggia, Color(0.92, 0.96, 1.0, 0.85 * (1.0 - eta / VITA_SCHEGGE)))


func lunghezza_tipica() -> float:
	# la distanza dall'impatto a cui arrivano le principali, in media
	var totale := 0.0
	for punti in principali:
		totale += punti[punti.size() - 1].distance_to(impatto)
	return totale / maxf(float(principali.size()), 1.0)


func disegna_facce(tela: CanvasItem, eta: float, fino: float, quanto: float, ridotto: bool) -> void:
	# ogni faccia prende la luce a modo suo; il luccichio corre dal centro
	for faccia in facce:
		var distanza := float(faccia["distanza"])
		if fino * lunghezza_tipica() < distanza:
			continue
		var tinta: Color = faccia["tinta"]
		var luccica := 0.0
		if not ridotto:
			var quando := distanza / (r * 18.0)
			luccica = 0.24 * exp(-pow((eta - quando - 0.04) / 0.05, 2.0))
		var vista := Color(tinta.lerp(Color(1, 1, 1, tinta.a), luccica * 4.0), (tinta.a + luccica) * quanto)
		Manifesto.poligono(tela, faccia["punti"], vista)


func disegna_cratere(tela: CanvasItem, eta: float, quanto: float, ridotto: bool) -> void:
	# dove il pugno ha preso: il vetro schiacciato, chiaro, e il lampo
	if not ridotto and eta < LAMPO:
		var u := eta / LAMPO
		tela.draw_circle(impatto, r * lerpf(0.5, 1.4, u), Color(1, 1, 1, 0.8 * (1.0 - u)), true, -1.0, true)
	var acceso := 0.0 if ridotto else 1.0 - clampf(eta / 0.3, 0.0, 1.0)
	Manifesto.poligono(tela, cratere, Color(1, 1, 1, (0.3 + 0.3 * acceso) * quanto))
	var giro := cratere.duplicate()
	giro.append(cratere[0])
	tela.draw_polyline(giro, Color(1, 1, 1, 0.8 * quanto), maxf(r * 0.04, 1.0), true)


func taglio(tela: CanvasItem, vivi: PackedVector2Array, totale: float, pieno: float, quanto: float, fronte: float) -> void:
	# il filo chiaro con la sua ombra accanto: e' cosi' che un taglio nel vetro
	# si legge sopra qualunque cosa ci sia dietro. Appena passato il fronte e'
	# bianco pieno, poi si posa
	if vivi.size() < 2:
		return
	var ombra := PackedVector2Array()
	for p in vivi:
		ombra.append(p + Vector2(0.9, 1.1))
	Crepe.filo(tela, ombra, totale, pieno * 1.2, Color(0, 0, 0, 0.5 * quanto))
	var bianco := lerpf(1.0, 0.82, clampf(fronte, 0.0, 1.0))
	Crepe.filo(tela, vivi, totale, pieno, Color(1, 1, 1, bianco * quanto))
