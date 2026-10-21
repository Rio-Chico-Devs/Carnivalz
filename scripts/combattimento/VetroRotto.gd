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
#
# LE LINEE, rifatte. Bru: «va fatto ancora meglio sono le linee da migliorare».
# Erano tre difetti insieme:
#   - TREMAVANO: passi di cinque pixel, ognuno storto di un poco, e il poco si
#     sommava - un filo di lana, non un taglio. Un vetro si rompe a tratti
#     DRITTI con qualche strappo secco: adesso i passi sono lunghi, il tremito
#     quasi niente, e la crepa tiene la sua direzione
#   - ERANO DOPPIE: l'ombra era la stessa riga spostata di un pixel in basso a
#     destra, e da vicino si leggevano due righe sfocate. Adesso l'alone scuro
#     sta sotto, centrato, e sopra corre un filo solo, nitido
#   - IL BORDO: il filo era un poligono che si ritirava di mezzo pixel, e sotto
#     i due pixel di larghezza si rovesciava. Adesso e' una striscia di
#     triangoli che sfuma di traverso (striscia(), qui sotto): liscia a
#     qualunque larghezza, anche a meno di un pixel
# E il filo si muove: la punta che corre e' piu' chiara, e appena le crepe
# sono arrivate al bordo un riflesso le percorre dall'impatto in fuori.
#
# TUTTO DAL SEME E DALL'ETA': la stessa crepa a ogni ridisegno, un'altra a ogni
# pugno, e nessuno stato da far avanzare fotogramma per fotogramma. Col
# movimento ridotto la crepa c'e' subito, intera, senza lampo, senza luccichio
# e senza schegge, e se ne va sfumando come le altre.

const DURATA := 1.0          # quanto resta il vetro rotto: poco, i pugni dopo vanno letti
const SVANISCE := 0.4        # gli ultimi secondi, in cui sfuma
const CORSA := 0.11          # quanto ci mettono le principali ad arrivare al bordo
const LAMPO := 0.14
const VITA_SCHEGGE := 0.55
const GRAVITA := 900.0
const RIFLESSO := 0.28       # quanto ci mette il riflesso a percorrere una crepa
const VETRO_CHIARO := Color(0.94, 0.97, 1.0)

var impatto := Vector2.ZERO
var vetro := Rect2()          # fin dove arriva il vetro (il piano della raffica)
var r := 30.0                 # il raggio del pugno: la misura di tutto
var principali: Array[PackedVector2Array] = []
var lucentezze: Array[float] = []     # ogni principale prende la luce a modo suo
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
		lucentezze.append(d.randf_range(0.62, 0.95))


func cammina(d: RandomNumberGenerator, da: Vector2, angolo: float, massimo: float) -> PackedVector2Array:
	# una crepa che corre fino al bordo del vetro (o per 'massimo' pixel): a
	# tratti lunghi e dritti, ogni tanto uno strappo secco, e torna sempre un
	# poco verso la sua direzione - una crepa non torna indietro
	var punti := PackedVector2Array([da])
	var verso := angolo
	var fatta := 0.0
	for passo in 200:
		verso = lerp_angle(verso, angolo, 0.12) + d.randf_range(-0.012, 0.012)
		if d.randf() < 0.28:
			verso += d.randf_range(0.07, 0.24) * (1.0 if d.randf() < 0.5 else -1.0)
		var lungo := r * d.randf_range(0.35, 0.8)
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
	# la stellina di crepe minute intorno all'impatto: poche, corte, dritte
	for i in 6:
		var verso := (float(i) + d.randf_range(-0.3, 0.3)) * TAU / 6.0
		rami.append({"punti": cammina(d, impatto + Vector2.from_angle(verso) * r * 0.16, verso, r * d.randf_range(0.25, 0.6)),
				"nasce": 0.0, "pieno": 0.5})


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
				"tinta": Color(Color.WHITE if chiara else Color.BLACK, d.randf_range(0.03, 0.08))})
	# un buco nella ragnatela, piu' spesso lontano dall'impatto
	if d.randf() < clampf(distanza / (r * 14.0), 0.15, 0.4):
		return
	# il tratto e' una corda quasi dritta, con un solo gomito appena verso
	# l'impatto: a tre gomiti storti sembrava disegnato a mano
	var gomito := a.lerp(b, d.randf_range(0.4, 0.6))
	gomito += (impatto - gomito).normalized() * a.distance_to(b) * d.randf_range(0.02, 0.08)
	anelli.append({"punti": PackedVector2Array([a, gomito, b]), "distanza": distanza})


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
	var riflesso := -1.0 if ridotto else (eta - CORSA - 0.03) / RIFLESSO
	for k in principali.size():
		var punti := principali[k]
		taglio(tela, Crepe.taglia(punti, fino), Crepe.lunghezza(punti), r * 0.075,
				quanto * lucentezze[k], fino, riflesso)
	for ramo in rami:
		var suo := clampf((fino - float(ramo["nasce"])) / maxf(1.0 - float(ramo["nasce"]), 0.2), 0.0, 1.0)
		if suo > 0.0:
			var punti: PackedVector2Array = ramo["punti"]
			taglio(tela, Crepe.taglia(punti, suo), Crepe.lunghezza(punti), r * 0.07 * float(ramo["pieno"]),
					quanto * 0.75, suo, -1.0)
	for anello in anelli:
		# un giro c'e' quando le principali ci sono arrivate
		if fino * lunghezza_tipica() >= float(anello["distanza"]):
			var punti: PackedVector2Array = anello["punti"]
			taglio(tela, punti, Crepe.lunghezza(punti) * 3.0, r * 0.04, quanto * 0.6, 1.0, -1.0)
	disegna_cratere(tela, eta, quanto, ridotto)
	for scheggia in schegge_vive(eta, ridotto):
		Manifesto.poligono(tela, scheggia, Color(VETRO_CHIARO, 0.85 * (1.0 - eta / VITA_SCHEGGE)))


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
			luccica = 0.16 * exp(-pow((eta - quando - 0.04) / 0.05, 2.0))
		var vista := Color(tinta.lerp(Color(1, 1, 1, tinta.a), luccica * 4.0), (tinta.a + luccica) * quanto)
		Manifesto.poligono(tela, faccia["punti"], vista)


func disegna_cratere(tela: CanvasItem, eta: float, quanto: float, ridotto: bool) -> void:
	# dove il pugno ha preso: il vetro schiacciato, chiaro, e il lampo
	if not ridotto and eta < LAMPO:
		var u := eta / LAMPO
		tela.draw_circle(impatto, r * lerpf(0.5, 1.4, u), Color(1, 1, 1, 0.8 * (1.0 - u)), true, -1.0, true)
	var acceso := 0.0 if ridotto else 1.0 - clampf(eta / 0.3, 0.0, 1.0)
	Manifesto.poligono(tela, cratere, Color(VETRO_CHIARO, (0.28 + 0.3 * acceso) * quanto))
	var giro := cratere.duplicate()
	giro.append(cratere[0])
	var larghi := PackedFloat32Array()
	larghi.resize(giro.size())
	larghi.fill(maxf(r * 0.035, 0.8))
	var luci := PackedFloat32Array()
	luci.resize(giro.size())
	luci.fill(1.0)
	striscia(tela, giro, larghi, luci, Color(VETRO_CHIARO, 0.75 * quanto))


func taglio(tela: CanvasItem, vivi: PackedVector2Array, totale: float, pieno: float, quanto: float,
		fronte: float, riflesso: float) -> void:
	# UN TAGLIO NEL VETRO: sotto un alone scuro centrato, che lo stacca da
	# qualunque cosa ci sia dietro (il pugno rosso, il fondo, il lampo); sopra il
	# filo chiaro, che si assottiglia andando in fuori. La punta che sta ancora
	# correndo e' piu' chiara, e il riflesso - da 0 a 1 mentre percorre la
	# crepa, -1 se non c'e' - la accende per un tratto
	if vivi.size() < 2:
		return
	var larghi := PackedFloat32Array()
	var luci := PackedFloat32Array()
	var corso := 0.0
	var fatto := Crepe.lunghezza(vivi)
	for i in vivi.size():
		if i > 0:
			corso += vivi[i].distance_to(vivi[i - 1])
		var u := corso / maxf(totale, 0.001)
		larghi.append(lerpf(pieno, pieno * 0.18, u))
		var chiaro := 1.0
		if fronte < 1.0:
			chiaro += 0.6 * clampf(1.0 - (fatto - corso) / (r * 1.2), 0.0, 1.0)
		if riflesso >= 0.0 and riflesso <= 1.3:
			chiaro += 0.7 * exp(-pow((u - riflesso) / 0.1, 2.0))
		luci.append(chiaro)
	var alone := PackedFloat32Array()
	for largo in larghi:
		alone.append(largo * 2.6 + 1.0)
	var piatte := PackedFloat32Array()
	piatte.resize(luci.size())
	piatte.fill(1.0)
	striscia(tela, vivi, alone, piatte, Color(0.05, 0.02, 0.04, 0.32 * quanto))
	striscia(tela, vivi, larghi, luci, Color(VETRO_CHIARO, quanto))
	if fronte < 1.0:
		tela.draw_circle(vivi[vivi.size() - 1], maxf(pieno * 0.9, 1.2), Color(1, 1, 1, quanto * (1.0 - fronte)), true, -1.0, true)


static func striscia(tela: CanvasItem, punti: PackedVector2Array, larghi: PackedFloat32Array,
		luci: PackedFloat32Array, tinta: Color) -> void:
	# UN FILO LISCIO DI LARGHEZZA VARIABILE, in un disegno solo. Di traverso a
	# ogni punto quattro vertici: fuori trasparente, dentro pieno, dentro pieno,
	# fuori trasparente - la sfumatura e' la geometria stessa, quindi non si
	# rovescia mai, nemmeno sotto il pixel: li' il filo resta largo un pixel e
	# si fa piu' tenue invece che piu' stretto. Negli angoli i vertici si
	# allungano (giunto a spigolo), cosi' il filo non si strozza nei gomiti.
	# "luci" moltiplica la tinta punto per punto
	var n := punti.size()
	if n < 2:
		return
	var vertici := traverso(punti, larghi)
	var colori := PackedColorArray()
	var indici := PackedInt32Array()
	for i in n:
		var alfa := clampf(tinta.a * minf(larghi[i], 1.0) * luci[i], 0.0, 1.0)
		var vivo := Color(tinta.lerp(Color.WHITE, clampf(luci[i] - 1.0, 0.0, 1.0)), alfa)
		colori.append_array([Color(vivo, 0.0), vivo, vivo, Color(vivo, 0.0)])
		if i > 0:
			var a := (i - 1) * 4
			var b := i * 4
			for k in 3:
				indici.append_array([a + k, a + k + 1, b + k, a + k + 1, b + k + 1, b + k])
	RenderingServer.canvas_item_add_triangle_array(tela.get_canvas_item(), indici, vertici, colori)


static func traverso(punti: PackedVector2Array, larghi: PackedFloat32Array) -> PackedVector2Array:
	# i quattro vertici di traverso a ogni punto della striscia: fuori, dentro,
	# dentro, fuori. Il pieno e' largo meno un pixel, la sfumatura un pixel per
	# parte
	var n := punti.size()
	var vertici := PackedVector2Array()
	for i in n:
		var prima := (punti[i] - punti[maxi(i - 1, 0)]).normalized()
		var dopo := (punti[mini(i + 1, n - 1)] - punti[i]).normalized()
		if i == 0:
			prima = dopo
		if i == n - 1:
			dopo = prima
		var normale := (prima + dopo).normalized().orthogonal()
		var spigolo := 1.0 / maxf(normale.dot(dopo.orthogonal()), 0.5)
		var pieno := maxf(larghi[i] * 0.5 - 0.5, 0.0) * spigolo
		var fuori := pieno + spigolo
		var p := punti[i]
		vertici.append_array([p + normale * fuori, p + normale * pieno, p - normale * pieno, p - normale * fuori])
	return vertici
