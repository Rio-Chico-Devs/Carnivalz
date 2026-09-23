class_name Movimento
extends RefCounted

# IL VOCABOLARIO DEL MOVIMENTO. Pochi gesti, ognuno con un nome, e ognuno fa
# sempre la stessa cosa dovunque compaia.
#
# Prima c'erano ventotto tween in sedici file e cinque curve scelte una per
# una: ogni schermata si muoveva a modo suo, e un menu - sette menu - non si
# muoveva per niente. IBM Carbon lo chiama «semantic consistency»: «When
# elements convey the same meaning or perform the same function, use the same
# motion for them, and vice-versa». Material dice la stessa cosa in pratica:
# una durata e una curva DI TEMA, non una per ogni animazione.
#
# I GESTI (lo studio intero e' in docs/animazione.md):
#
#   entrata    arriva in fretta e si posa - curva "entrata", 240 ms
#   uscita     parte piano e se ne va, e dura MENO dell'entrata - 150 ms
#   cascata    gli elementi secondari uno dopo l'altro, 20-40 ms fra l'uno e
#              l'altro, tutto entro mezzo secondo, e L'AZIONE PRINCIPALE PER
#              ULTIMA. E' la regola di Bru («i pulsanti d'azione principale
#              chiudono la sequenza per guidare l'occhio del giocatore»), ed e'
#              la stessa di Carbon: «end with the most important information,
#              such as the primary button»
#   sfioro     il puntatore (o la tastiera) si posa su una cosa: forma e
#              colore su due molle diverse, come fa Material
#   pressione  la gelatina di Juice it or lose it: la X e poi la Y
#   rifiuto    una scossa che si smorza: il clic che non si puo' fare
#
# E OGNI GESTO HA IL SUO SUONO. Tsuchiya, sul menu di Persona 5: «If it moves,
# it'll make a sound». Si passa da suona(), che sa quale suono va con quale
# gesto: chi anima non deve ricordarselo.
#
# LE REGOLE CHE NESSUN GESTO PUO' ROMPERE, ognuna con la sua prova:
#   - non si aspetta mai: un'animazione non tiene fermo un clic (Conto.gd:
#     animare si', sbarrare mai);
#   - niente sopra il mezzo secondo;
#   - il movimento ridotto spegne gli spostamenti ma non le informazioni:
#     quello che compare compare lo stesso, dissolvendosi invece di arrivare.
#
# PERCHE' LE CURVE SONO SCRITTE A MANO. Godot ha le sue (TRANS_CUBIC, ...) ma
# non le cubiche di Bezier con cui Material le pubblica: le quattro cifre di
# "emphasized decelerate" non corrispondono a nessuna delle sue. Sono dieci
# righe di matematica, e la matematica si prova senza aprire una finestra.

const SUONI := {
	"sfioro": "sfiora",
	"pressione": "conferma",
	"rifiuto": "errore",
	"apertura": "apertura",
	"chiusura": "chiusura",
}
# due tocchi piu' vicini di cosi' sono una mitragliata, non due tocchi: succede
# passando col mouse di corsa sopra un elenco
const FRA_DUE_SFIORI := 0.03
# quanto si smorza la scossa: a fine durata ne resta il 2%, cioe' niente
const SMORZA_SCOSSA := 13.0
# DA UN PANNELLO ALL'ALTRO: il vecchio sparisce, POI entra il nuovo. E' la
# «fade through» di Material, che passa il testimone a questa soglia (0,35
# della durata): prima si esce, poi si entra, mai due pannelli a meta'
const SOGLIA_CAMBIO := 0.35
const SCIVOLO_PANNELLO := -24.0

static var ultimo_suono := ""       # le prove chiedono a questo, non all'altoparlante
static var ultimo_sfioro := -1.0


static func dati() -> Dictionary:
	return Stile.dati.get("movimento", {})


static func ridotto() -> bool:
	return Impostazioni.movimento_ridotto


static func durata(nome: String) -> float:
	return float(dati().get("durate", {}).get(nome, 0.15))


static func misura(nome: String) -> float:
	# le misure in pixel del vocabolario: quanto scivola una voce accesa, quanto
	# si spostano le quinte col mouse
	return float(dati().get(nome, 0.0))


# --- le curve ---------------------------------------------------------------

static func curva(nome: String, u: float) -> float:
	var c: Array = dati().get("curve", {}).get(nome, [0.0, 0.0, 1.0, 1.0])
	return bezier(float(c[0]), float(c[1]), float(c[2]), float(c[3]), u)


static func bezier(x1: float, y1: float, x2: float, y2: float, u: float) -> float:
	# LA CUBICA DI BEZIER DEL CSS, cioe' quella con cui Material pubblica le sue
	# curve: estremi fissi in (0,0) e (1,1), due punti di controllo. Data la
	# frazione di TEMPO trascorsa (u, la x) si cerca il parametro t che ci
	# arriva, e si restituisce la y - la frazione di STRADA fatta.
	#
	# E' la stessa risoluzione dei browser: Newton, che converge in tre o
	# quattro passi, e la bisezione se Newton si perde (succede dove la curva e'
	# quasi piatta).
	if u <= 0.0:
		return 0.0
	if u >= 1.0:
		return 1.0
	var cx := 3.0 * x1
	var bx := 3.0 * (x2 - x1) - cx
	var ax := 1.0 - cx - bx
	var cy := 3.0 * y1
	var by := 3.0 * (y2 - y1) - cy
	var ay := 1.0 - cy - by
	var t := u
	for passo in 8:
		var errore := ((ax * t + bx) * t + cx) * t - u
		if absf(errore) < 1e-6:
			return ((ay * t + by) * t + cy) * t
		var pendenza := (3.0 * ax * t + 2.0 * bx) * t + cx
		if absf(pendenza) < 1e-6:
			break
		t -= errore / pendenza
	var basso := 0.0
	var alto := 1.0
	t = u
	for passo in 40:
		var x := ((ax * t + bx) * t + cx) * t
		if absf(x - u) < 1e-6:
			break
		if x < u:
			basso = t
		else:
			alto = t
		t = (basso + alto) * 0.5
	return ((ay * t + by) * t + cy) * t


static func elastico(u: float) -> float:
	# easeOutElastic: arriva, supera, torna indietro, si posa. E' il ritorno
	# della gelatina
	if u <= 0.0:
		return 0.0
	if u >= 1.0:
		return 1.0
	return pow(2.0, -10.0 * u) * sin((u * 10.0 - 0.75) * TAU / 3.0) + 1.0


# --- la cascata -------------------------------------------------------------

static func ritardi_cascata(quanti: int, principale := -1, dopo := 0.0) -> Array[float]:
	# QUANDO PARTE OGNI ELEMENTO DI UN ELENCO, in secondi. I secondari in ordine
	# di lettura, dall'alto; il principale (se c'e') per ULTIMO, anche se sta in
	# cima - e' lui che deve chiudere la sequenza, cosi' l'occhio finisce dove
	# deve cliccare.
	#
	# "dopo" e' quanto e' gia' passato quando la cascata comincia (l'intestazione
	# e' entrata prima). Il tetto vale per tutto: se l'elenco e' lungo il passo
	# si stringe, e sotto i 20 ms arrivano quasi insieme - meglio questo che un
	# menu che finisce di entrare dopo un secondo.
	var ritardi: Array[float] = []
	if quanti <= 0:
		return ritardi
	var c: Dictionary = dati().get("cascata", {})
	var passo := clampf(float(c.get("passo", 0.03)),
			float(c.get("passo_minimo", 0.02)), float(c.get("passo_massimo", 0.04)))
	var spazio := float(c.get("tetto", 0.5)) - durata("voce") - dopo
	if quanti > 1:
		passo = minf(passo, maxf(spazio, 0.0) / float(quanti - 1))
	ritardi.resize(quanti)
	var posto := 0
	for i in quanti:
		if i == principale:
			continue
		ritardi[i] = dopo + passo * float(posto)
		posto += 1
	if principale >= 0 and principale < quanti:
		ritardi[principale] = dopo + passo * float(quanti - 1)
	return ritardi


# --- la pressione e il rifiuto -----------------------------------------------

static func gelatina(t: float) -> Vector2:
	# DI QUANTO SI DEFORMA UNA COSA PREMUTA, t secondi dopo: da aggiungere a una
	# scala di 1. La X si allarga, e 50 ms dopo la Y si schiaccia - e' lo
	# sfasamento a farla sembrare una cosa molle invece di una che si ingrandisce
	var g: Dictionary = dati().get("gelatina", {})
	var quanto := float(g.get("quanto", 0.08))
	var salita := float(g.get("salita", 0.05))
	var ritorno := float(g.get("ritorno", 0.45))
	var sfasamento := float(g.get("ritardo_y", 0.05))
	return Vector2(battito(t, quanto, salita, ritorno),
			-battito(t - sfasamento, quanto, salita, ritorno))


static func battito(t: float, quanto: float, salita: float, ritorno: float) -> float:
	if t <= 0.0:
		return 0.0
	if t < salita:
		return quanto * t / salita
	var u := (t - salita) / ritorno
	if u >= 1.0:
		return 0.0
	return quanto * (1.0 - elastico(u))


static func durata_gelatina() -> float:
	var g: Dictionary = dati().get("gelatina", {})
	return float(g.get("ritardo_y", 0.05)) + float(g.get("salita", 0.05)) \
			+ float(g.get("ritorno", 0.45))


static func scossa(t: float) -> float:
	# IL NO: di quanti pixel sta spostata di lato una cosa rifiutata, t secondi
	# dopo. Un seno che si spegne - la testa che dice di no, non un terremoto
	var r: Dictionary = dati().get("rifiuto", {})
	if t <= 0.0 or t >= float(r.get("durata", 0.3)):
		return 0.0
	return float(r.get("ampiezza", 8)) * exp(-SMORZA_SCOSSA * t) \
			* sin(TAU * float(r.get("frequenza", 18)) * t)


static func durata_scossa() -> float:
	return float(dati().get("rifiuto", {}).get("durata", 0.3))


# --- i gesti di un pannello intero ------------------------------------------------
#
# Servono a ogni menu (pausa, menu principale, Sede, negozio): stanno qui perche'
# uno stesso gesto deve essere lo stesso ovunque.

static func verso(tween: Tween, nodo: Object, proprieta: String, valore: Variant,
		quale_curva: String, secondi: float) -> PropertyTweener:
	# un passo di tween con una curva del vocabolario. Godot ha le sue curve,
	# non queste: la cubica passa di qui (set_custom_interpolator)
	return tween.tween_property(nodo, proprieta, valore, secondi).set_custom_interpolator(
			func(u: float) -> float: return curva(quale_curva, u))


static func cascata(voci: Array[VoceMenu], principale: int, dopo := 0.0) -> void:
	# fa entrare un elenco di voci in cascata, e da' il fuoco (in silenzio: non
	# l'ha sfiorata nessuno) a quella principale, che arriva per ultima
	var ritardi := ritardi_cascata(voci.size(), principale, dopo)
	for i in voci.size():
		voci[i].entra(ritardi[i])
	if principale >= 0 and principale < voci.size():
		voci[principale].prendi_il_fuoco_in_silenzio()


static func entra_pannello(nodo: Control) -> void:
	# il pannello nuovo aspetta che il vecchio se ne sia andato, poi arriva da
	# sinistra dissolvendosi dentro. Il nodo non deve stare dentro un
	# contenitore: a ogni riordino gli rimetterebbe a posto la posizione
	var attesa := durata("entrata") * SOGLIA_CAMBIO
	var resto := durata("entrata") - attesa
	nodo.modulate.a = 0.0
	var dentro := nodo.create_tween().set_parallel()
	verso(dentro, nodo, "modulate:a", 1.0, "entrata", resto).set_delay(attesa)
	if ridotto():
		return
	nodo.position.x = SCIVOLO_PANNELLO
	verso(dentro, nodo, "position:x", 0.0, "entrata", resto).set_delay(attesa)


static func congeda(nodo: Control, secondi: float) -> void:
	# IL PANNELLO VECCHIO SI DISSOLVE, ma dall'istante in cui lo lasci non
	# risponde piu' a niente: per una frazione di secondo si vede ancora, e non
	# si tocca gia' piu'. Poi si libera da solo
	if nodo == null or not is_instance_valid(nodo):
		return
	sordo(nodo)
	var via := nodo.create_tween()
	verso(via, nodo, "modulate:a", 0.0, "uscita", secondi)
	via.tween_callback(nodo.queue_free)


static func sordo(nodo: Node) -> void:
	# niente clic e niente fuoco della tastiera, per questo nodo e tutto quello
	# che ha dentro: un pannello che se ne va non deve prendersi un clic
	# destinato a quello che arriva
	if nodo is Control:
		var c := nodo as Control
		if c.has_focus():
			c.release_focus()
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.focus_mode = Control.FOCUS_NONE
	for figlio in nodo.get_children():
		sordo(figlio)


# --- il suono -----------------------------------------------------------------

static func suona(gesto: String) -> void:
	var nome := String(SUONI.get(gesto, ""))
	if nome == "":
		push_error("Movimento: il gesto '%s' non ha un suono. Ogni cosa che si muove ne ha uno." % gesto)
		return
	if gesto == "sfioro":
		var adesso := Time.get_ticks_msec() / 1000.0
		if ultimo_sfioro >= 0.0 and adesso - ultimo_sfioro < FRA_DUE_SFIORI:
			return
		ultimo_sfioro = adesso
		ultimo_suono = gesto
		# il tocco ha un lettore suo: passando sopra la voce successiva non deve
		# tagliare il suono della conferma di quella appena premuta
		AudioManager.tocco(nome)
		return
	ultimo_suono = gesto
	AudioManager.interfaccia(nome)


# --- le molle -----------------------------------------------------------------

static func molla(nome: String, partenza := 0.0) -> Molla:
	var m: Dictionary = dati().get("molle", {}).get(nome, {})
	var nuova := Molla.new()
	nuova.rigidita = float(m.get("rigidita", 700.0))
	nuova.smorzamento = float(m.get("smorzamento", 0.9))
	nuova.salta_a(partenza)
	return nuova


class Molla:
	# UNA MOLLA VERA, non un tween che ci somiglia. Material le descrive con due
	# numeri, quanto e' rigida e quanto e' smorzata (SpringForce), e Godot non
	# ha niente di simile: TRANS_SPRING non prende parametri.
	#
	# Il passo e' la soluzione esatta dell'equazione, non un'approssimazione un
	# fotogramma alla volta: la molla fa la stessa strada a 30 e a 240
	# fotogrammi al secondo. Col metodo di Eulero a 60 fps, con la rigidita' di
	# FastEffects (3800), ogni passo sarebbe gia' al limite della stabilita'.
	#
	# Una molla ha una cosa che un tween non ha: se l'obiettivo cambia a meta'
	# strada, riparte da dov'e' E CON LA VELOCITA' CHE HA. Il puntatore che
	# entra ed esce di corsa da una voce non fa scattare niente.
	var valore := 0.0
	var obiettivo := 0.0
	var velocita := 0.0
	var rigidita := 700.0
	var smorzamento := 0.9
	var soglia := 0.001

	func salta_a(v: float) -> void:
		valore = v
		obiettivo = v
		velocita = 0.0

	func ferma() -> bool:
		return absf(valore - obiettivo) < soglia and absf(velocita) < soglia * 10.0

	func passo(dt: float) -> void:
		if ferma():
			valore = obiettivo
			velocita = 0.0
			return
		if dt <= 0.0:
			return
		var w := sqrt(rigidita)
		var z := smorzamento
		var x0 := valore - obiettivo
		var v0 := velocita
		var x := 0.0
		var v := 0.0
		if z < 1.0:
			var wd := w * sqrt(1.0 - z * z)
			var e := exp(-z * w * dt)
			var c := cos(wd * dt)
			var s := sin(wd * dt)
			var b := (v0 + z * w * x0) / wd
			x = e * (x0 * c + b * s)
			v = -z * w * x + e * wd * (b * c - x0 * s)
		elif is_equal_approx(z, 1.0):
			var e := exp(-w * dt)
			var b := v0 + w * x0
			x = (x0 + b * dt) * e
			v = (v0 - w * b * dt) * e
		else:
			var radice := sqrt(z * z - 1.0)
			var r1 := -w * (z - radice)
			var r2 := -w * (z + radice)
			var c2 := (v0 - r1 * x0) / (r2 - r1)
			var c1 := x0 - c2
			x = c1 * exp(r1 * dt) + c2 * exp(r2 * dt)
			v = c1 * r1 * exp(r1 * dt) + c2 * r2 * exp(r2 * dt)
		valore = obiettivo + x
		velocita = v
