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
#   - nel punto in cui il pugno ti prende il vetro e' SCHIACCIATO: una fitta di
#     crepoline e granelli, e un bagliore
#   - da li' corrono le crepe PRINCIPALI, ad angoli disuguali, fino al bordo
#     del vetro; qualcuna si biforca; intorno all'impatto, le crepe minute
#   - fra due principali vicine, gli ANELLI della ragnatela: tre giri, a tratti
#     quasi dritti e con qualche buco
#   - i PEZZI fra crepe e anelli (LastreVetro.gd) spostano quello che c'e'
#     dietro ognuno per conto suo, strappano nel colpo, e quelli attaccati
#     all'impatto si staccano e ti volano addosso lasciando un buco
#   - un'ONDA parte dall'impatto e spinge in fuori quello che c'e' dietro, e
#     qualche SCHEGGIA salta via luccicando
#
# RIFATTO DA CAPO. Bru: «non ci siamo, non è ancora di qualità sembra quasi
# fatto su paint». Erano disegni sopra lo schermo: un disco bianco per
# cratere, un cerchio bianco per onda, schegge bianche piatte. Adesso, come la
# crepa dello squarcio che Bru ha approvato, le crepe appena rotte BRUCIANO
# (un cuore quasi bianco e un alone del colore della luce, sommati a quello
# che c'e' sotto) e poi si raffreddano; e sono INCISE: un taglio con una
# parete in ombra e una in luce, coi denti fini. Il resto lo fanno i pezzi
# che guardano dietro. Si disegna su quattro tele (TeleVetro.gd).
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
# PIU' CURA. Bru: «ok siamo sulla strada giusta impegniamoci di più spendici
# più tempo». Guardato fotogramma per fotogramma, restavano cinque difetti
# (docs/vita.md §5): il colpo era una macchia con un anello arcobaleno; le
# crepe accese erano laser uguali fino al bordo (vicino_al_colpo); la
# ragnatela un bersaglio di giri tondi e allineati (anello_fra, e le
# raggiere in minute); i pezzi che saltavano grandi triangoli grigi opachi
# (LastreVetro: schegge, ombra, costa) e la polvere coriandoli (aghi); il
# vetro schiacciato uno scarabocchio (tira_frantumi).
#
# TUTTO DAL SEME E DALL'ETA': la stessa crepa a ogni ridisegno, un'altra a ogni
# pugno, e nessuno stato da far avanzare fotogramma per fotogramma. Col
# movimento ridotto la crepa c'e' subito, intera, senza lampo, senza luccichio
# e senza schegge, e se ne va sfumando come le altre.

const DURATA := 1.0          # quanto resta il vetro rotto: poco, i pugni dopo vanno letti
const SVANISCE := 0.4        # gli ultimi secondi, in cui sfuma
const CORSA := 0.11          # quanto ci mettono le principali ad arrivare al bordo
const VITA_SCHEGGE := 0.55
const GRAVITA := 900.0
const RIFLESSO := 0.28       # quanto ci mette il riflesso a percorrere una crepa
const ONDA := 0.22           # quanto ci mette l'onda dell'impatto ad allargarsi e sparire
const CALORE := 0.13         # quanto ci mettono le crepe appena rotte a spegnersi
const VETRO_CHIARO := Color(0.94, 0.97, 1.0)
const LUCE := Vector2(-0.6, -0.8)        # da dove arriva la luce: dall'alto a sinistra
# LA LUCE DEL VETRO: fredda, quella di un vetro vero. Fra le due proposte -
# l'altra era calda, l'arancio della crepa dello squarcio - Bru: «la seconda e'
# quella che mi e' piaciuta di piu»
const TINTA := Color(0.6, 0.86, 1.0)

var impatto := Vector2.ZERO
var vetro := Rect2()          # fin dove arriva il vetro (il piano della raffica)
var r := 30.0                 # il raggio del pugno: la misura di tutto
var principali: Array[PackedVector2Array] = []
var lucentezze: Array[float] = []     # ogni principale prende la luce a modo suo
var rami: Array[Dictionary] = []      # {punti, nasce, pieno}: biforcazioni e crepe minute
var anelli: Array[Dictionary] = []    # {punti (a, gomito, b), distanza, k, giro, ia, ib}
var lastre: LastreVetro               # i pezzi fra le crepe
var fini: Array[PackedVector2Array] = []   # le principali come si disegnano: col dente fine
var frantumi: Array[PackedVector2Array] = []   # le crepoline del vetro schiacciato
var brina: Array[Vector2] = []        # e i granelli
var granelli: Array[float] = []
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
	tira_frantumi(d)
	tira_schegge(d)
	for punti in principali:
		fini.append(dentellata(d, punti))
	for ramo in rami:
		ramo["fini"] = dentellata(d, ramo["punti"])
	for anello in anelli:
		anello["fini"] = dentellata(d, anello["punti"])
	lastre = LastreVetro.new(self, d)


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
	# E LE RAGGIERE CHE NON ARRIVANO AL BORDO: in mezzo a ogni spicchio una
	# crepa che parte dal colpo come le principali e si ferma dopo uno o due
	# giri. Il vetro vero ne ha a decine; con le sole principali la ragnatela
	# era vuota, cinque raggi e tre giri
	for k in principali.size():
		if d.randf() < 0.25:
			continue
		var una := (principali[k][1] - impatto).angle()
		var altra := (principali[(k + 1) % principali.size()][1] - impatto).angle()
		var verso := una + wrapf(altra - una, 0.0, TAU) * d.randf_range(0.35, 0.65)
		rami.append({"punti": cammina(d, impatto + Vector2.from_angle(verso) * r * 0.2, verso, r * d.randf_range(1.6, 3.6)),
				"nasce": 0.0, "pieno": 0.7})


func tira_anelli(d: RandomNumberGenerator) -> void:
	# tre giri di ragnatela: fra due principali vicine, un arco intorno
	# all'impatto
	var giri: Array[float] = [r * d.randf_range(1.25, 1.6), r * d.randf_range(2.6, 3.3), r * d.randf_range(4.6, 5.6)]
	for j in giri.size():
		for k in principali.size():
			anello_fra(d, k, j, giri[j])


func anello_fra(d: RandomNumberGenerator, k: int, giro: int, distanza: float) -> void:
	# il tratto del giro fra la crepa k e la successiva. Parte e arriva su un
	# punto delle crepe, e se ne ricorda quale: i pezzi del vetro si tagliano
	# lungo questi tratti (LastreVetro)
	var una := principali[k]
	var altra := principali[(k + 1) % principali.size()]
	# I TRATTI DI DUE SPICCHI VICINI NON SI DANNO LA MANO: ognuno sta un poco
	# piu' in qua o piu' in la', e attacca alle due crepe ad altezze diverse.
	# Allineati, i tratti chiudevano un cerchio intorno al colpo: un bersaglio
	# disegnato, non un vetro
	var suo := distanza * d.randf_range(0.86, 1.14)
	var ia := sulla_crepa(una, suo * d.randf_range(0.88, 1.12))
	var ib := sulla_crepa(altra, suo * d.randf_range(0.88, 1.12))
	if ia < 0 or ib < 0:
		return
	# un buco nella ragnatela, piu' spesso lontano dall'impatto
	if d.randf() < clampf(distanza / (r * 14.0), 0.15, 0.4):
		return
	# IL TRATTO GIRA INTORNO ALL'IMPATTO, ma non e' un arco di compasso: una
	# curva dolce che si gonfia in fuori o si incava verso il colpo, ognuna a
	# modo suo. Le corde tutte uguali col gomito verso il centro chiudevano un
	# poligono regolare; gli archi lisci, allineati, un cerchio; i tratti a
	# gomiti, celle d'alveare
	var a := una[ia]
	var b := altra[ib]
	var da_a := a - impatto
	var da_b := b - impatto
	var arco := wrapf(da_b.angle() - da_a.angle(), 0.0, TAU)
	var passi := maxi(3, int(arco * suo / (r * 0.5)))
	var gonfio := d.randf_range(-0.08, 0.06)
	var storto := d.randf_range(-0.03, 0.03)
	var punti := PackedVector2Array([a])
	for s in range(1, passi):
		var t := float(s) / float(passi)
		var lontano := lerpf(da_a.length(), da_b.length(), t) \
				* (1.0 + gonfio * sin(PI * t) + storto * sin(TAU * t) + d.randf_range(-0.008, 0.008))
		var p := impatto + Vector2.from_angle(da_a.angle() + arco * t) * lontano
		# vicino a un angolo l'arco uscirebbe dal vetro: li' la ragnatela ha un buco
		if not vetro.has_point(p):
			return
		punti.append(p)
	punti.append(b)
	anelli.append({"punti": punti, "distanza": suo, "k": k, "giro": giro, "ia": ia, "ib": ib})


func sulla_crepa(punti: PackedVector2Array, distanza: float) -> int:
	# il primo punto della crepa a quella distanza dall'impatto; -1 se non ci arriva
	for i in punti.size():
		if punti[i].distance_to(impatto) >= distanza:
			return i
	return -1


func tira_frantumi(d: RandomNumberGenerator) -> void:
	# DOVE IL PUGNO HA PRESO IL VETRO E' SCHIACCIATO: non un disco chiaro, ma
	# una fitta di crepoline che scappano dal centro - quasi tutte a raggiera,
	# poche di traverso a legarle - e granelli che prendono la luce, piu' fitti
	# nel mezzo, dove il vetro e' polvere. A caso in tutte le direzioni era
	# uno scarabocchio
	for k in 34:
		var angolo := d.randf() * TAU
		var dove := impatto + Vector2.from_angle(angolo) * r * (0.05 + 0.5 * pow(d.randf(), 0.8))
		var radiale := d.randf() < 0.82
		var verso := angolo + (d.randf_range(-0.22, 0.22) if radiale else PI * 0.5 + d.randf_range(-0.3, 0.3))
		var lungo := r * (d.randf_range(0.08, 0.22) if radiale else d.randf_range(0.04, 0.1))
		var gomito := dove + Vector2.from_angle(verso) * lungo * 0.55
		frantumi.append(PackedVector2Array([dove, gomito,
				gomito + Vector2.from_angle(verso + d.randf_range(-0.25, 0.25)) * lungo * 0.45]))
	for k in 46:
		var lontano := r * (0.3 * pow(d.randf(), 1.5) if k < 30 else 0.6 * sqrt(d.randf()))
		brina.append(impatto + Vector2.from_angle(d.randf() * TAU) * lontano)
		granelli.append(d.randf_range(0.4, 1.1))


func dentellata(d: RandomNumberGenerator, punti: PackedVector2Array) -> PackedVector2Array:
	# LA CREPA DA VICINO NON E' UNA RIGA: ogni tre pixel un dente di mezzo
	# pixel, di qua o di la'. A colpo d'occhio resta dritta; da vicino e' vetro
	var fine := PackedVector2Array()
	for i in range(1, punti.size()):
		var a := punti[i - 1]
		var b := punti[i]
		var passi := maxi(int(a.distance_to(b) / 3.0), 1)
		var di_traverso := (b - a).normalized().orthogonal()
		for k in passi:
			var dente := 0.0 if k == 0 else d.randf_range(-0.55, 0.55)
			fine.append(a.lerp(b, float(k) / float(passi)) + di_traverso * dente)
	fine.append(punti[punti.size() - 1])
	return fine


func tira_schegge(d: RandomNumberGenerator) -> void:
	# la polvere di vetro che schizza via dal colpo: aghi sottili, non
	# triangoli. Erano nove triangolini bianchi: coriandoli
	for k in 14:
		var verso := d.randf() * TAU
		schegge.append({"velocita": Vector2.from_angle(verso) * r * d.randf_range(4.0, 10.0) + Vector2(0.0, -r * 3.0),
				"giro": d.randf_range(-14.0, 14.0), "lato": r * d.randf_range(0.07, 0.17), "angolo": d.randf() * TAU,
				"fase": d.randf() * TAU})


# --- il tempo ---------------------------------------------------------------

static func corsa(eta: float, ridotto: bool) -> float:
	# fin dove sono arrivate le principali (0..1): arrivano frenando
	if ridotto:
		return 1.0
	return 1.0 - pow(1.0 - clampf(eta / CORSA, 0.0, 1.0), 3.0)


static func luce(eta: float) -> float:
	# quanto si vede: tutto, poi sfuma negli ultimi SVANISCE secondi
	return 1.0 - clampf((eta - (DURATA - SVANISCE)) / SVANISCE, 0.0, 1.0)


func dove_scheggia(s: Dictionary, eta: float) -> Vector2:
	return impatto + (s["velocita"] as Vector2) * eta + Vector2(0.0, GRAVITA) * eta * eta * 0.5


func schegge_vive(eta: float, ridotto: bool) -> Array[PackedVector2Array]:
	# gli aghi in volo adesso, gia' al loro posto: lunghi e stretti, una punta
	# avanti e due dietro vicine
	var vive: Array[PackedVector2Array] = []
	if ridotto or eta >= VITA_SCHEGGE:
		return vive
	for s in schegge:
		var dove := dove_scheggia(s, eta)
		var verso := Vector2.from_angle(float(s["angolo"]) + float(s["giro"]) * eta)
		var lato := float(s["lato"])
		vive.append(PackedVector2Array([dove + verso * lato * 1.3,
				dove - verso * lato * 0.6 + verso.orthogonal() * lato * 0.24, dove - verso * lato * 0.6 - verso.orthogonal() * lato * 0.16]))
	return vive


# --- il disegno -------------------------------------------------------------
# Quattro tele, una sopra l'altra (TeleVetro): i pezzi che guardano dietro, il
# vetro (crepe, buchi, il rosso), i pezzi che saltano, e la luce che si somma
# (le crepe accese, il bagliore, l'onda, le scintille).

static func calore(eta: float, ridotto: bool) -> float:
	# quanto sono accese le crepe: appena rotte bruciano, poi si raffreddano
	if ridotto:
		return 0.0
	return exp(-maxf(eta, 0.0) / CALORE)


func disegna_lastre(tela: CanvasItem, eta: float, ridotto: bool) -> void:
	var quanto := luce(eta)
	if quanto > 0.0:
		lastre.disegna(tela, eta, ridotto, corsa(eta, ridotto), corsa(eta, ridotto) * lunghezza_tipica(), quanto)


func disegna_schegge(tela: CanvasItem, eta: float, ridotto: bool) -> void:
	lastre.disegna_in_volo(tela, eta, ridotto)


func disegna(tela: CanvasItem, eta: float, ridotto: bool) -> void:
	var quanto := luce(eta)
	if quanto <= 0.0:
		return
	var fino := corsa(eta, ridotto)
	disegna_rosso(tela, eta)
	lastre.disegna_buchi(tela, eta, ridotto, quanto)
	disegna_frantumi(tela, quanto)
	var riflesso := -1.0 if ridotto else (eta - CORSA - 0.03) / RIFLESSO
	var bollente := calore(eta, ridotto)
	for k in principali.size():
		var punti := fini[k]
		incisa(tela, Crepe.taglia(punti, fino), Crepe.lunghezza(punti), r * 0.07,
				quanto * lucentezze[k], riflesso, bollente, k)
	for ramo in rami:
		var suo := di_ramo(ramo, fino)
		if suo > 0.0:
			var punti: PackedVector2Array = ramo["fini"]
			incisa(tela, Crepe.taglia(punti, suo), Crepe.lunghezza(punti), r * 0.06 * float(ramo["pieno"]),
					quanto * 0.75, -1.0, bollente, 7)
	for anello in anelli:
		# un giro c'e' quando le principali ci sono arrivate
		if fino * lunghezza_tipica() >= float(anello["distanza"]):
			var punti: PackedVector2Array = anello["fini"]
			incisa(tela, punti, Crepe.lunghezza(punti) * 3.0, r * 0.04, quanto * 0.6, -1.0, bollente, 3)


static func di_ramo(ramo: Dictionary, fino: float) -> float:
	# fin dove e' arrivato un ramo: parte quando la sua principale gli passa accanto
	return clampf((fino - float(ramo["nasce"])) / maxf(1.0 - float(ramo["nasce"]), 0.2), 0.0, 1.0)


func disegna_rosso(tela: CanvasItem, eta: float) -> void:
	# IL COLPO SI SENTE AI BORDI: il riquadro si arrossa da fuori verso dentro,
	# come quando si stringono gli occhi, e torna. Non un velo piatto su tutto
	var forza := 0.55 * exp(-eta / 0.3)
	if forza < 0.01:
		return
	var rosso := Stile.colore("pericolo")
	var fuori := vetro.grow(2.0)
	var dentro := fuori.grow(-minf(fuori.size.x, fuori.size.y) * 0.42)
	var angoli_fuori := [fuori.position, Vector2(fuori.end.x, fuori.position.y), fuori.end, Vector2(fuori.position.x, fuori.end.y)]
	var angoli_dentro := [dentro.position, Vector2(dentro.end.x, dentro.position.y), dentro.end, Vector2(dentro.position.x, dentro.end.y)]
	var vertici := PackedVector2Array()
	var colori := PackedColorArray()
	for k in 4:
		vertici.append(angoli_fuori[k])
		colori.append(Color(rosso, forza))
		vertici.append(angoli_dentro[k])
		colori.append(Color(rosso, 0.0))
	var indici := PackedInt32Array()
	for k in 4:
		var a := k * 2
		var b := ((k + 1) % 4) * 2
		indici.append_array([a, b, a + 1, b, b + 1, a + 1])
	RenderingServer.canvas_item_add_triangle_array(tela.get_canvas_item(), indici, vertici, colori)


func disegna_frantumi(tela: CanvasItem, quanto: float) -> void:
	# il vetro schiacciato: un velo appena chiaro, nel mezzo la polvere di
	# vetro quasi bianca, le crepoline, i granelli
	ventaglio(tela, impatto, r * 0.62, Color(VETRO_CHIARO, 0.12 * quanto), Color(VETRO_CHIARO, 0.0))
	ventaglio(tela, impatto, r * 0.3, Color(VETRO_CHIARO, 0.42 * quanto), Color(VETRO_CHIARO, 0.0))
	for punti in frantumi:
		var larghi := PackedFloat32Array([0.9, 0.75, 0.5])
		var luci := PackedFloat32Array([1.0, 1.0, 1.0])
		striscia(tela, scostata(punti, 0.6), larghi, luci, Color(0.02, 0.0, 0.03, 0.4 * quanto))
		striscia(tela, punti, larghi, luci, Color(VETRO_CHIARO, 0.65 * quanto))
	Manifesto.puntini(tela, brina, granelli, Color(1, 1, 1, 0.6 * quanto))


func incisa(tela: CanvasItem, vivi: PackedVector2Array, totale: float, pieno: float, quanto: float,
		riflesso: float, bollente: float, seme: int) -> void:
	# UNA CREPA E' UN TAGLIO NEL VETRO, CON DUE PARETI. La parete girata verso
	# la luce e' chiara, l'altra fa ombra: un filo scuro da una parte, uno
	# chiaro dall'altra, e in mezzo il taglio, che si assottiglia andando in
	# fuori e non e' uguale dappertutto - dove la crepa gira un poco, prende
	# la luce. Appena rotto il taglio brucia (bollente), poi torna vetro. Il
	# riflesso - da 0 a 1 mentre percorre la crepa, -1 se non c'e' - la
	# accende per un tratto
	if vivi.size() < 2:
		return
	var larghi := PackedFloat32Array()
	var luci := PackedFloat32Array()
	var piatte := PackedFloat32Array()
	var corso := 0.0
	for i in vivi.size():
		if i > 0:
			corso += vivi[i].distance_to(vivi[i - 1])
		var u := corso / maxf(totale, 0.001)
		larghi.append(lerpf(pieno, pieno * 0.2, u))
		var chiaro := (0.72 + 0.38 * sin(corso * 0.21 + float(seme) * 1.7) * sin(corso * 0.067 + float(seme))) \
				* lerpf(1.0, 0.5, clampf(u, 0.0, 1.0))
		if riflesso >= 0.0 and riflesso <= 1.3:
			chiaro += 0.7 * exp(-pow((u - riflesso) / 0.1, 2.0))
		luci.append(chiaro)
		piatte.append(1.0)
	var di_lato := (vivi[vivi.size() - 1] - vivi[0]).normalized().orthogonal()
	var verso := 1.0 if di_lato.dot(-LUCE) > 0.0 else -1.0
	var parete := PackedFloat32Array()
	for largo in larghi:
		parete.append(largo * 0.8 + 0.5)
	striscia(tela, scostata(vivi, -verso * (pieno * 0.45 + 0.8)), parete, piatte, Color(0.02, 0.0, 0.03, 0.62 * quanto))
	striscia(tela, scostata(vivi, verso * (pieno * 0.45 + 0.7)), parete, piatte, Color(VETRO_CHIARO, 0.42 * quanto))
	var cuore := VETRO_CHIARO.lerp(Color(1.0, 0.97, 0.88), bollente)
	striscia(tela, vivi, larghi, luci, Color(cuore, quanto))


func disegna_luce(tela: CanvasItem, eta: float, ridotto: bool) -> void:
	# la luce che si somma, sulla tela che somma: nel colpo un lampo su tutto,
	# il bagliore dove il pugno ha preso, le crepe che bruciano mentre corrono,
	# la punta che corre, l'onda, le scintille
	var quanto := luce(eta)
	if quanto <= 0.0 or ridotto:
		return
	var bollente := calore(eta, ridotto)
	if eta < 0.05:
		tela.draw_rect(vetro.grow(2.0), Color(1, 1, 1, 0.18 * (1.0 - eta / 0.05)))
	disegna_impatto(tela, eta, bollente)
	var fino := corsa(eta, ridotto)
	for k in principali.size():
		var punti := Crepe.taglia(fini[k], fino)
		accesa(tela, punti, r * 0.07, bollente * lucentezze[k])
		if fino < 1.0 and punti.size() > 1:
			# la punta che corre: una scia corta e chiara dietro il fronte della
			# crepa, non un pallino
			var punta := punti[punti.size() - 1]
			var dietro := punta - (punta - punti[punti.size() - 2]).normalized() * r * 0.45
			striscia_morbida(tela, PackedVector2Array([dietro, punta.lerp(dietro, 0.3), punta]),
					PackedFloat32Array([0.5, 3.5, 2.5]), Color(TINTA.lerp(Color.WHITE, 0.8), 0.95))
	for ramo in rami:
		var suo := di_ramo(ramo, fino)
		if suo > 0.0:
			accesa(tela, Crepe.taglia(ramo["fini"], suo), r * 0.05, bollente * 0.7)
	disegna_onda(tela, eta)
	lastre.disegna_lampi(tela, eta, ridotto)
	# gli aghi: quasi spenti, finche' girando prendono la luce e brillano; e
	# dietro una scia corta, dove erano un attimo fa
	var vive := schegge_vive(eta, ridotto)
	for k in vive.size():
		var s := schegge[k]
		var luccica := 0.2 + 0.8 * pow(absf(cos(float(s["fase"]) + float(s["giro"]) * eta)), 8.0)
		var resta := 1.0 - eta / VITA_SCHEGGE
		striscia_morbida(tela, PackedVector2Array([dove_scheggia(s, maxf(eta - 0.035, 0.0)), dove_scheggia(s, eta)]),
				PackedFloat32Array([0.5, float(s["lato"]) * 0.5 + 1.0]), Color(TINTA, 0.4 * luccica * resta))
		Manifesto.poligono(tela, vive[k], Color(TINTA.lerp(Color.WHITE, 0.7), luccica * resta))


func disegna_impatto(tela: CanvasItem, eta: float, bollente: float) -> void:
	# LA LUCE DEL COLPO, com'e' in una lente: un nocciolo piccolo e duro, un
	# alone largo e tenue e una riga orizzontale che si allunga e si spegne in
	# un attimo, il lampo delle lenti del cinema. Era un bagliore grande e
	# morbido: una macchia, non una luce. (Una stella di raggi, provata, era
	# un asterisco: graffi sopra le crepe)
	ventaglio(tela, impatto, r * (0.3 + 0.25 * bollente), Color(1, 1, 1, 0.95 * bollente), Color(TINTA.lerp(Color.WHITE, 0.5), 0.0))
	ventaglio(tela, impatto, r * 2.0, Color(TINTA, 0.32 * bollente), Color(TINTA, 0.0))
	var u := clampf(eta / 0.16, 0.0, 1.0)
	if u >= 1.0:
		return
	var spegne := (1.0 - u) * (1.0 - u)
	var lungo := r * lerpf(3.5, 6.0, u)
	striscia_morbida(tela, PackedVector2Array([impatto - Vector2(lungo, 0.0), impatto, impatto + Vector2(lungo, 0.0)]),
			PackedFloat32Array([0.6, 5.0, 0.6]), Color(TINTA.lerp(Color.WHITE, 0.35), 0.6 * spegne))


func accesa(tela: CanvasItem, punti: PackedVector2Array, pieno: float, quanto: float) -> void:
	# il bagliore di una crepa che brucia: largo e del colore della luce, e
	# dentro uno piu' stretto e quasi bianco. Brucia vicino al colpo e si
	# spegne andando in fuori: accesa uguale fino al bordo era un laser
	if quanto < 0.01 or punti.size() < 2:
		return
	var largo := PackedFloat32Array()
	var stretto := PackedFloat32Array()
	var vicino := PackedFloat32Array()
	for p in punti:
		largo.append(pieno * 7.0 + 6.0)
		stretto.append(pieno * 2.5 + 2.0)
		vicino.append(vicino_al_colpo(p))
	striscia_morbida(tela, punti, largo, Color(TINTA, 0.5 * quanto), vicino)
	striscia_morbida(tela, punti, stretto, Color(TINTA.lerp(Color.WHITE, 0.6), 0.7 * quanto), vicino)


func vicino_al_colpo(p: Vector2) -> float:
	# quanto brucia una crepa in quel punto: tutta vicino al colpo, poco
	# lontano. Non si spegne mai del tutto: la crepa e' una sola
	return 0.12 + 0.88 * exp(-p.distance_to(impatto) / (r * 3.0))


static func onda(eta: float, ridotto: bool) -> float:
	# fin dove e' arrivata l'onda dell'impatto (0..1); -1 se non c'e'
	if ridotto or eta < 0.0 or eta >= ONDA:
		return -1.0
	return eta / ONDA


func raggio_onda(eta: float, ridotto: bool) -> float:
	# in pixel dall'impatto: per lo shader, che con l'onda spinge in fuori
	# quello che c'e' dietro. Sotto zero: non c'e'
	var u := onda(eta, ridotto)
	return -1.0 if u < 0.0 else r * lerpf(0.6, 7.5, 1.0 - pow(1.0 - u, 2.0))


func disegna_onda(tela: CanvasItem, eta: float) -> void:
	# sopra la deformazione, un velo di luce sull'onda: un anello morbido, non
	# una riga
	var raggio := raggio_onda(eta, false)
	if raggio < 0.0:
		return
	var u := onda(eta, false)
	var spesso := r * 0.6 * (1.0 - u) + 4.0
	var punti := PackedVector2Array()
	var colori := PackedColorArray()
	var indici := PackedInt32Array()
	var giri := 72
	for k in giri:
		var verso := Vector2.from_angle(TAU * float(k) / float(giri))
		punti.append_array([impatto + verso * maxf(raggio - spesso, 0.0), impatto + verso * raggio, impatto + verso * (raggio + spesso)])
		colori.append_array([Color(TINTA, 0.0), Color(TINTA.lerp(Color.WHITE, 0.4), 0.28 * (1.0 - u)), Color(TINTA, 0.0)])
		var a := k * 3
		var b := ((k + 1) % giri) * 3
		indici.append_array([a, b, a + 1, b, b + 1, a + 1, a + 1, b + 1, a + 2, b + 1, b + 2, a + 2])
	RenderingServer.canvas_item_add_triangle_array(tela.get_canvas_item(), indici, punti, colori)


func lunghezza_tipica() -> float:
	# la distanza dall'impatto a cui arrivano le principali, in media
	var totale := 0.0
	for punti in principali:
		totale += punti[punti.size() - 1].distance_to(impatto)
	return totale / maxf(float(principali.size()), 1.0)


static func ventaglio(tela: CanvasItem, centro: Vector2, raggio: float, dentro: Color, fuori: Color) -> void:
	# un cerchio sfumato dal centro al bordo, liscio: un ventaglio di triangoli
	# col colore che scivola dal centro al giro
	if raggio <= 0.5:
		return
	var punti := PackedVector2Array([centro])
	var colori := PackedColorArray([dentro])
	var indici := PackedInt32Array()
	var giri := 40
	for k in giri:
		punti.append(centro + Vector2.from_angle(TAU * float(k) / float(giri)) * raggio)
		colori.append(fuori)
		indici.append_array([0, 1 + k, 1 + (k + 1) % giri])
	RenderingServer.canvas_item_add_triangle_array(tela.get_canvas_item(), indici, punti, colori)


static func scostata(punti: PackedVector2Array, quanto: float) -> PackedVector2Array:
	# la stessa linea spostata di traverso di "quanto" pixel (a sinistra del
	# verso in cui corre se positivo), coi gomiti a spigolo
	var vertici := traverso(punti, PackedFloat32Array())
	var spostata := PackedVector2Array()
	for i in punti.size():
		var normale := (vertici[i * 4] - vertici[i * 4 + 3]).normalized()
		spostata.append(punti[i] + normale * quanto)
	return spostata


static func striscia_morbida(tela: CanvasItem, punti: PackedVector2Array, larghi: PackedFloat32Array, tinta: Color,
		luci := PackedFloat32Array()) -> void:
	# una striscia che sfuma dal centro ai bordi per tutta la sua larghezza: e'
	# il bagliore, non il filo. "luci", se c'e', dice quanto e' accesa punto
	# per punto
	var n := punti.size()
	if n < 2:
		return
	var vertici := PackedVector2Array()
	var colori := PackedColorArray()
	var indici := PackedInt32Array()
	var meta := PackedFloat32Array()
	for largo in larghi:
		meta.append(largo)
	var di_traverso := traverso(punti, meta)
	for i in n:
		var fuori_a := di_traverso[i * 4]
		var fuori_b := di_traverso[i * 4 + 3]
		vertici.append_array([fuori_a, (fuori_a + fuori_b) * 0.5, fuori_b])
		var acceso := Color(tinta, tinta.a * (luci[i] if i < luci.size() else 1.0))
		colori.append_array([Color(tinta, 0.0), acceso, Color(tinta, 0.0)])
		if i > 0:
			var a := (i - 1) * 3
			var b := i * 3
			indici.append_array([a, b, a + 1, b, b + 1, a + 1, a + 1, b + 1, a + 2, b + 1, b + 2, a + 2])
	RenderingServer.canvas_item_add_triangle_array(tela.get_canvas_item(), indici, vertici, colori)


static func striscia(tela: CanvasItem, punti: PackedVector2Array, larghi: PackedFloat32Array,
		luci: PackedFloat32Array, tinta: Color, pieno_uv := false) -> void:
	# UN FILO LISCIO DI LARGHEZZA VARIABILE, in un disegno solo. Di traverso a
	# ogni punto quattro vertici: fuori trasparente, dentro pieno, dentro pieno,
	# fuori trasparente - la sfumatura e' la geometria stessa, quindi non si
	# rovescia mai, nemmeno sotto il pixel: li' il filo resta largo un pixel e
	# si fa piu' tenue invece che piu' stretto. Negli angoli i vertici si
	# allungano (giunto a spigolo), cosi' il filo non si strozza nei gomiti.
	# "luci" moltiplica la tinta punto per punto. "pieno_uv": sulla tela con lo
	# shader del vetro, dice allo shader di non guardare dietro (LastreVetro.PIENO)
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
	if pieno_uv:
		var uv := PackedVector2Array()
		uv.resize(vertici.size())
		uv.fill(LastreVetro.PIENO)
		RenderingServer.canvas_item_add_triangle_array(tela.get_canvas_item(), indici, vertici, colori, uv)
	else:
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
		var largo := larghi[i] if i < larghi.size() else 1.0
		var pieno := maxf(largo * 0.5 - 0.5, 0.0) * spigolo
		var fuori := pieno + spigolo
		var p := punti[i]
		vertici.append_array([p + normale * fuori, p + normale * pieno, p - normale * pieno, p - normale * fuori])
	return vertici
