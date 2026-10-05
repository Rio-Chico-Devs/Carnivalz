extends Control

# L'OROLOGIO DA TASCHINO DI UNA SCELTA A TEMPO.
#
# Bru: «quelle eroe e villain sono a tempo, manchi timing non recuperi». Nel suo
# disegno sono due cipolle appese storte a sinistra del riquadro nero, una per
# opzione. Il disegno approvato, dopo sei giri di bozze, e' in Cipolla.gd; le
# crepe in Crepe.gd; la rottura in Rottura.gd. Qui c'e' quello che si muove: il
# tempo, il pendolo, la catena.
#
# Quello che fa e' contare alla rovescia e dire quando e' finita. Non sa cosa
# sia la scelta a cui e' attaccato, non la toglie di mezzo, non decide niente -
# se ne occupa chi l'ha appeso li'. Lo dice DUE volte, e sono due cose diverse:
#   - SCADUTO, quando il tempo finisce: la scelta e' morta adesso, non quando
#     l'animazione lo dice ("manchi timing non recuperi")
#   - ROTTO, dopo i tre colpi in cui il vetro si crepa: adesso si rompe
#
# SI FERMA CON LA PAUSA, e non per gentilezza: senza, aprire l'inventario per
# controllare se hai l'oggetto giusto ti farebbe perdere la scelta mentre
# guardi. Il nodo eredita il modo di processo dall'albero, quindi quando la
# Pausa ferma l'albero si ferma anche lui - non c'e' niente da ricordarsi.
#
# IL PENDOLO. Bru: «possiamo migliorare l'oscillazione? secondo te e'
# possibile?». Prima era un seno, sempre uguale, con l'orologio rigido come un
# cartello. Adesso e' simulato:
#   - l'archetto e' appeso e oscilla col suo periodo, si smorza da solo, ha
#     l'inerzia: rallenta in cima a ogni oscillazione e corre in fondo
#   - LO SCAPPAMENTO: a ogni tic una spinta nel verso in cui sta gia' andando,
#     quanto basta per tenerlo a qualche grado; nell'ultimo quarto i tic
#     accelerano, le spinte crescono e l'orologio si agita
#   - la cassa e' incernierata all'archetto: lo insegue un attimo in ritardo
#   - appeso di colpo cade un poco e rimbalza; a ogni tic un saltino, allo
#     scadere uno strattone, a ogni crepa un sobbalzo
#   - LA CATENA E' UNA CORDA: nodi con la gravita', fra l'archetto e la scelta
# Col movimento ridotto (Impostazioni) non dondola e non salta: resta appeso
# dritto, conta, si crepa e si rompe lo stesso, che sono informazioni.
#
# I numeri che si toccano per provare stanno in data/stile.json, "orologio".

signal scaduto
signal rotto

# Sotto questa frazione la lancetta diventa rossa e suona l'allarme: sono la
# stessa cosa detta in due modi, e vanno cambiate insieme.
const QUOTA_ALLARME := 0.25
const SMORZA := 0.07                 # quanto si calma da solo il pendolo
const PERIODO_CERNIERA := 0.3        # la cassa sull'archetto: piu' rigida, insegue in ritardo
const SMORZA_CERNIERA := 0.3
const PERIODO_SALTO := 0.26          # il su e giu' sull'archetto
const SMORZA_SALTO := 0.22
const CADUTA := 7.0                  # quanto e' sollevato appena appeso
const NODI := 16                     # la catena
const GRAVITA_CATENA := 900.0
const PANCIA := 26.0                 # quanto pende la catena, appena appesa

var durata := 6.0
var rimasto := 0.0
var acceso := false
var tinta_genere := Color("#ed1c24")   # il tempo perso, sul binario: il colore della scelta
var fine := -1.0                     # secondi dallo scadere; < 0 finche' non e' scaduto
var crepe: Crepe = null
var base_rot := 0.0
var al_tic := 1.0
var dado := RandomNumberGenerator.new()
# il pendolo: l'archetto attorno al gancio e la cassa sulla cerniera (rispetto
# alla posa storta), e il su e giu'
var angolo := 0.0
var velocita := 0.0
var corpo := 0.0
var velocita_corpo := 0.0
var salto := 0.0
var velocita_salto := 0.0
# la catena, in coordinate dello schermo
var nodi := PackedVector2Array()
var nodi_prima := PackedVector2Array()
var tratto_catena := 0.0


func _ready() -> void:
	custom_minimum_size = Cipolla.MISURA
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot_offset = Cipolla.PERNO
	# ACCESO PRIMA DI ESSERE APPESO: Main lo avvia mentre la riga non e' ancora
	# a schermo, e qui un set_process(false) secco lo spegneva di nuovo - il
	# tempo non passava, e la scelta non scadeva mai
	set_process(acceso)


static func misura(chiave: String, predefinita: float) -> float:
	return float((Stile.dati.get("orologio", {}) as Dictionary).get(chiave, predefinita))


func avvia(secondi: float, inclinazione_gradi: float) -> void:
	durata = maxf(secondi, 0.1)
	rimasto = durata
	acceso = true
	fine = -1.0
	rotation = deg_to_rad(inclinazione_gradi)
	base_rot = rotation
	dado.seed = get_instance_id()
	crepe = Crepe.new(dado.seed)
	al_tic = misura("tic", 1.0)
	angolo = 0.0
	velocita = 0.0
	corpo = 0.0
	velocita_corpo = 0.0
	salto = 0.0
	velocita_salto = 0.0
	nodi.clear()
	if not Movimento.ridotto():
		# appeso di colpo: lo si lascia andare da un lato, un po' sollevato
		angolo = deg_to_rad(misura("partenza", 17.0)) * (1.0 if dado.randf() < 0.5 else -1.0)
		corpo = angolo * 0.5
		salto = -CADUTA
	set_process(true)
	queue_redraw()


func ferma() -> void:
	acceso = false
	set_process(false)


func quota_rimasta() -> float:
	return clampf(rimasto / durata, 0.0, 1.0) if durata > 0.0 else 0.0


func nervoso() -> float:
	# 0 fino all'ultimo quarto, 1 allo scadere
	return clampf((QUOTA_ALLARME - quota_rimasta()) / QUOTA_ALLARME, 0.0, 1.0)


func _process(delta: float) -> void:
	if fine >= 0.0:
		si_crepa(delta)
	elif acceso:
		conta(delta)
	pendolo(delta)
	muovi_catena(delta)
	rotation = base_rot + angolo
	scale = Vector2.ONE * (1.0 + trattiene())
	queue_redraw()


func conta(delta: float) -> void:
	var prima := quota_rimasta()
	rimasto = maxf(rimasto - delta, 0.0)
	# L'ULTIMO QUARTO SI SENTE, e suona una volta sola: due orologi a schermo
	# insieme, con due ticchettii sfasati, farebbero rumore e non tensione
	if prima > QUOTA_ALLARME and quota_rimasta() <= QUOTA_ALLARME:
		AudioManager.interfaccia("allarme")
	al_tic -= delta
	if al_tic <= 0.0:
		tic()
		al_tic += lerpf(misura("tic", 1.0), misura("tic_allarme", 0.22), nervoso())
	if rimasto <= 0.0:
		acceso = false
		fine = 0.0
		sobbalza(0.6, 1.0, 20.0)   # le lancette si fermano di colpo: uno strattone
		scaduto.emit()


func si_crepa(delta: float) -> void:
	# dallo scadere: tre colpi, e il vetro cede
	var prima := fine
	fine += delta
	for colpo in Crepe.COLPI:
		if prima < float(colpo) and fine >= float(colpo):
			sobbalza(dado.randf_range(0.3, 0.45), 1.4, 18.0)
	var cede := misura("rotto_a", 0.46)
	if prima < cede and fine >= cede:
		set_process(false)
		rotto.emit()


func trattiene() -> float:
	# prima di andare in pezzi trattiene il fiato: si gonfia di un soffio
	if Movimento.ridotto() or fine < 0.0:
		return 0.0
	var dal_terzo := float(Crepe.COLPI[2])
	return 0.045 * clampf((fine - dal_terzo) / (misura("rotto_a", 0.46) - dal_terzo), 0.0, 1.0)


func tic() -> void:
	# LO SCAPPAMENTO: una spinta nel verso in cui sta gia' andando, quanta ne
	# serve per riportarlo ai suoi gradi (che nell'ultimo quarto crescono), mai
	# esattamente uguale; e il clic del meccanismo, un saltino
	if Movimento.ridotto():
		return
	var n := nervoso()
	var w := TAU / misura("periodo", 1.35)
	var ampiezza := sqrt(angolo * angolo + pow(velocita / w, 2.0))
	var voluta := deg_to_rad(lerpf(misura("ampiezza", 4.0), misura("ampiezza_allarme", 11.0), n)) \
			* dado.randf_range(0.85, 1.15)
	var spinta := clampf((voluta - ampiezza) * w * 0.7, -0.15, 0.5)
	var verso := signf(velocita) if absf(velocita) > 0.01 else (1.0 if dado.randf() < 0.5 else -1.0)
	velocita += verso * spinta + dado.randf_range(-0.04, 0.04) * (1.0 + 3.0 * n)
	velocita_salto += lerpf(15.0, 34.0, n)


func sobbalza(forza: float, cerniera: float, su: float) -> void:
	# un colpo: lo strattone allo scadere, e ogni crepa
	if Movimento.ridotto():
		return
	var verso := 1.0 if dado.randf() < 0.5 else -1.0
	velocita += verso * forza
	velocita_corpo -= verso * cerniera
	velocita_salto -= su


func pendolo(delta: float) -> void:
	# IL PENDOLO, a piccoli passi: l'archetto torna verso la posa e si smorza;
	# la cassa insegue l'archetto su una cerniera piu' rigida; il su e giu' e'
	# una molla. Passi piccoli perche' una molla rigida a passi lunghi esplode
	var passi := maxi(1, ceili(delta * 240.0))
	var h := delta / float(passi)
	var w := TAU / misura("periodo", 1.35)
	var wc := TAU / PERIODO_CERNIERA
	var ws := TAU / PERIODO_SALTO
	for i in passi:
		velocita += (-w * w * angolo - 2.0 * SMORZA * w * velocita) * h
		angolo += velocita * h
		velocita_corpo += (wc * wc * (angolo - corpo) - 2.0 * SMORZA_CERNIERA * wc * (velocita_corpo - velocita)) * h
		corpo += velocita_corpo * h
		velocita_salto += (-ws * ws * salto - 2.0 * SMORZA_SALTO * ws * velocita_salto) * h
		salto += velocita_salto * h


func corpo_locale() -> Transform2D:
	# la cassa: girata sulla cerniera di quanto non segue l'archetto, e calata
	# del suo su e giu'
	return Transform2D(0.0, Vector2(0, salto)) * Transform2D(corpo - angolo, Cipolla.CERNIERA) \
			* Transform2D(0.0, -Cipolla.CERNIERA)


func _draw() -> void:
	catena()
	# l'ombra piena cade sullo schermo come quella delle scelte, non sull'orologio storto
	draw_set_transform_matrix(corpo_locale())
	var giu := (Cipolla.OMBRA / maxf(scale.x, 0.01)).rotated(-(rotation + corpo - angolo))
	draw_circle(Cipolla.CENTRO + giu, Cipolla.CASSA, Stile.colore("manifesto_scuro"), true, -1.0, true)
	draw_set_transform(Vector2(0, salto))
	Cipolla.archetto(self)
	draw_set_transform_matrix(corpo_locale())
	Cipolla.collo_e_corona(self)
	# rossa sull'ultimo quarto: la lancetta e' l'avviso che si e' quasi senza tempo
	var lancette := Stile.colore("pericolo") if quota_rimasta() <= QUOTA_ALLARME else Cipolla.crema()
	Cipolla.quadrante(self, quota_rimasta(), tinta_genere, lancette)
	if fine >= 0.0 and crepe != null:
		crepe.disegna(self, fine)
	draw_set_transform(Vector2(0, salto))
	Cipolla.ribattini(self)
	draw_set_transform(Vector2.ZERO)


# --- la catena -------------------------------------------------------------------

func aggancio_sullo_schermo() -> Vector2:
	# dove la catena si infila: un po' dentro il lato sinistro della scelta
	var riga := get_parent()
	if riga == null:
		return Vector2.INF
	for figlio in riga.get_children():
		if figlio is Button:
			var bottone := figlio as Button
			return bottone.get_global_transform() * Vector2(30.0, bottone.size.y * 0.3)
	return Vector2.INF


func appendi_catena(a: Vector2, b: Vector2) -> void:
	# appena appesa pende a pancia, e la sua lunghezza resta quella
	var pancia := (a + b) * 0.5 + Vector2(0, PANCIA)
	var lungo := 0.0
	for i in NODI:
		var t := float(i) / float(NODI - 1)
		nodi.append(a.lerp(pancia, t).lerp(pancia.lerp(b, t), t))
		if i > 0:
			lungo += nodi[i].distance_to(nodi[i - 1])
	nodi_prima = nodi.duplicate()
	tratto_catena = lungo / float(NODI - 1)


func muovi_catena(delta: float) -> void:
	# LA CATENA E' UNA CORDA (Verlet): un capo all'archetto e l'altro sotto la
	# scelta, la gravita' sui nodi in mezzo, e fra un nodo e l'altro una
	# distanza che non cambia. Pende, oscilla in ritardo, sobbalza da sola
	var a := get_global_transform() * (Cipolla.PERNO + Vector2(0, salto))
	var b := aggancio_sullo_schermo()
	if b == Vector2.INF:
		nodi.clear()
		return
	if nodi.is_empty():
		appendi_catena(a, b)
	var passi := maxi(1, ceili(delta * 120.0))
	var h := delta / float(passi)
	for passo in passi:
		for i in range(1, NODI - 1):
			var v := (nodi[i] - nodi_prima[i]) * 0.99
			nodi_prima[i] = nodi[i]
			nodi[i] += v + Vector2(0, GRAVITA_CATENA) * h * h
		nodi[0] = a
		nodi[NODI - 1] = b
		for giro in 8:
			tendi_catena()


func tendi_catena() -> void:
	# ogni tratto torna alla sua lunghezza; i capi non si muovono
	for i in NODI - 1:
		var d := nodi[i + 1] - nodi[i]
		var l := d.length()
		if l < 0.0001:
			continue
		var tira := d * (1.0 - tratto_catena / l)
		if i == 0:
			nodi[i + 1] -= tira
		elif i + 1 == NODI - 1:
			nodi[i] += tira
		else:
			nodi[i] += tira * 0.5
			nodi[i + 1] -= tira * 0.5


func maglie_sullo_schermo() -> Array[Array]:
	# le maglie lungo la corda, ogni 4,6 pixel: [dove, verso] sullo schermo
	var lista: Array[Array] = []
	var avanzo := 2.0
	for i in range(1, nodi.size()):
		var a := nodi[i - 1]
		var b := nodi[i]
		var lungo := a.distance_to(b)
		while avanzo < lungo:
			lista.append([a.lerp(b, avanzo / lungo), (b - a).normalized()])
			avanzo += 4.6
		avanzo -= lungo
	return lista


func catena() -> void:
	var verso_locale := get_global_transform().affine_inverse()
	draw_set_transform(Vector2.ZERO)
	var lista := maglie_sullo_schermo()
	for k in lista.size():
		Cipolla.maglia(self, verso_locale * Vector2(lista[k][0]),
				verso_locale.basis_xform(Vector2(lista[k][1])).normalized(), k % 2 == 0, Cipolla.crema(),
				Cipolla.FINE + 0.2)


func forma_della_rottura() -> Dictionary:
	# TUTTO QUELLO CHE SERVE A ROMPERLO, nelle coordinate dello schermo: il
	# cerchio del vetro, il punto d'impatto, le crepe come sono adesso (il vetro
	# si spacca proprio lungo di loro), il profilo della testa, e la catena
	var t := get_global_transform() * corpo_locale()
	if crepe == null:
		crepe = Crepe.new(get_instance_id())
	var tagli: Array[PackedVector2Array] = []
	for punti in crepe.per_la_rottura(fine):
		tagli.append(t * punti)
	return {"centro": t * Cipolla.CENTRO, "raggio": Cipolla.CASSA * t.get_scale().x,
			"impatto": t * crepe.impatto, "crepe": tagli, "testa": t * Cipolla.testa(),
			"maglie": maglie_sullo_schermo()}
