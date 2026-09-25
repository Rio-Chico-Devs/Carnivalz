extends Control

# QUANDO IL TEMPO SCADE, L'OPZIONE SI FRANTUMA COME VETRO.
#
# Bru: «quando scade il tempo le opzioni hero o evil si frantumano come se fosse
# vetro e scompaiono, i pezzi devono cadere e gradualmente svanire verso il
# trasparente».
#
# PERCHE' UN EFFETTO E NON UNA DISSOLVENZA. Una scelta che si spegne piano si
# legge come "il gioco l'ha tolta"; una che si rompe si legge come "l'hai persa
# tu". E' la stessa differenza fra un oggetto che sparisce dall'inventario e un
# oggetto che si spacca in mano. Il tempo scaduto deve fare rumore, o la seconda
# volta il giocatore non correra' di piu' - non avra' proprio capito che c'era
# da correre.
#
# COME SI ROMPE IL VETRO VERO: non a quadretti. Parte da un punto d'impatto e si
# apre a raggiera, con le schegge piccole al centro e grandi verso il bordo. E'
# esattamente come sono costruite qui: un punto, dei tagli radiali, e un anello
# a meta' strada che spezza ogni spicchio in due. Dieci righe di geometria che
# valgono piu' di qualunque animazione disegnata a mano, perche' ogni rottura e'
# diversa dalla precedente.
#
# IL DISEGNO DEL PEZZO CHE SI ROMPE viene fotografato dallo schermo un istante
# prima di romperlo: cosi' le schegge portano addosso il testo vero, il colore
# vero, il bordo vero. Dove non c'e' rendering (le prove girano senza finestra)
# la fotografia non esiste e le schegge restano tinte piatte: si muovono, cadono
# e svaniscono lo stesso, ed e' quello che le prove devono poter misurare.

signal finito

const SPICCHI := 11          # quanti tagli radiali: sotto gli 8 sembra una torta, sopra i 14 polvere
# a che frazione del raggio passano gli anelli che spezzano ogni spicchio: con
# due (la scelta a tempo) l'anello sta a 0.46, poco prima di meta'; con
# venticinque (il bersaglio della Mattanza) i giri si stringono verso il centro,
# dove il colpo e' arrivato
const CURVA_ANELLI := 1.12
const DURATA := 1.15         # quanto ci mettono a sparire del tutto
const GRAVITA := 1750.0
const SPINTA := 105.0        # quanto schizzano via dal punto d'impatto
const GIRO_MASSIMO := 5.0    # radianti al secondo

var schegge: Array[Dictionary] = []
var trascorso := 0.0
var foto: Texture2D = null
var misura := Vector2.ZERO
var spinta := SPINTA
var fili := true      # il filo di luce sui tagli: su un disegno scontornato
                      # disegnerebbe la griglia anche dove non c'e' niente

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)

func frantuma(sorgente: Control, seme: RandomNumberGenerator = null) -> void:
	# Prende il posto di quello che rompe: stessa posizione, stessa misura, e da
	# quel momento l'originale non serve piu'.
	var dado := seme if seme != null else GameState.rng
	misura = sorgente.size
	if misura.x <= 0.0 or misura.y <= 0.0:
		finito.emit()
		return
	global_position = sorgente.global_position
	size = misura
	await fotografa(sorgente)
	costruisci_schegge(dado)
	trascorso = 0.0
	# UNA ROTTURA MUTA E' MEZZA ROTTURA. Il suono arriva adesso e non prima:
	# fra lo scadere del tempo e questo istante c'e' la fotografia, e far
	# suonare il vetro mentre a schermo l'opzione e' ancora intera sarebbe
	# peggio del silenzio.
	AudioManager.interfaccia("vetro")
	set_process(true)
	queue_redraw()

func frantuma_immagine(immagine: Texture2D, dove: Rect2, forma: Dictionary = {},
		suono := "vetro", seme: RandomNumberGenerator = null) -> void:
	# UN DISEGNO, NON UN PEZZO DI SCHERMO: il bersaglio della Mattanza si rompe
	# da quello che e', non da una fotografia - la fotografia aspetterebbe un
	# fotogramma, e il suono e il danno non possono aspettare. "dove" e' in
	# coordinate dello schermo; "forma" dice quanti tagli, quanti anelli e con
	# che forza volano. Tagli piu' i quattro angoli, per gli anelli: i pezzi
	misura = dove.size
	if immagine == null or misura.x <= 0.0 or misura.y <= 0.0:
		finito.emit()
		return
	global_position = dove.position
	size = misura
	foto = immagine
	fili = false
	spinta = float(forma.get("spinta", SPINTA))
	costruisci_schegge(seme if seme != null else GameState.rng,
			int(forma.get("tagli", SPICCHI)), int(forma.get("anelli", 2)))
	trascorso = 0.0
	AudioManager.interfaccia(suono)
	set_process(true)
	queue_redraw()

func fotografa(sorgente: Control) -> void:
	# SENZA FINESTRA NON SI ASPETTA NIENTE, e questa riga e' costata dieci minuti.
	#
	# frame_post_draw e' il segnale del fotogramma finito di disegnare: senza
	# rendering non arriva MAI. Non da' errore, non fallisce - l'attesa resta
	# li' per sempre, e con lei la funzione che l'ha chiesta. Nelle prove, che
	# girano tutte senza finestra, l'intera esecuzione si e' piantata: nessun
	# verde, nessun rosso, solo il tempo massimo che scade. E' esattamente il
	# guasto che prove/esegui.sh sorveglia da mesi, arrivato da una porta nuova.
	#
	# Quindi si chiede prima se c'e' qualcuno che disegna. Se non c'e' non c'e'
	# niente da fotografare, e le schegge restano tinte piatte: cadono e
	# svaniscono lo stesso, che e' quello che le prove devono poter misurare.
	if DisplayServer.get_name() == "headless":
		return
	# UN ISTANTE PRIMA DI ROMPERLO. Va aspettato il fotogramma disegnato, se no
	# si fotografa quello di prima - e il pezzo che si rompe sarebbe il pezzo
	# com'era un sedicesimo di secondo fa, che in un'interfaccia ferma non si
	# nota e in una che si muove si', tantissimo.
	await RenderingServer.frame_post_draw
	if not is_instance_valid(sorgente):
		return
	var vista := get_viewport()
	if vista == null or vista.get_texture() == null:
		return
	var schermo := vista.get_texture().get_image()
	if schermo == null or schermo.is_empty():
		return
	var riquadro := Rect2i(Vector2i(sorgente.global_position), Vector2i(misura.ceil()))
	riquadro = riquadro.intersection(Rect2i(Vector2i.ZERO, schermo.get_size()))
	if riquadro.size.x <= 0 or riquadro.size.y <= 0:
		return
	foto = ImageTexture.create_from_image(schermo.get_region(riquadro))

func costruisci_schegge(dado: RandomNumberGenerator, tagli := SPICCHI, anelli := 2) -> void:
	schegge.clear()
	# il punto d'impatto non e' il centro esatto: un vetro che si rompe sempre in
	# mezzo si riconosce come un'animazione, uno che si rompe ogni volta in un
	# punto diverso si riconosce come una cosa che succede
	var impatto := Vector2(
			misura.x * dado.randf_range(0.30, 0.70),
			misura.y * dado.randf_range(0.30, 0.70))
	var bordo := punti_sul_bordo(dado, tagli)
	# GLI ANELLI spezzano ogni spicchio in pezzi: piccoli attaccati al punto
	# d'impatto, grandi verso il bordo, che e' come si rompe. I punti di un
	# anello si tirano una volta sola e li usano tutti e due gli spicchi che ci
	# confinano: tirati per spicchio, fra un pezzo e l'altro resterebbero
	# fessure - con due anelli non si vedono, con venticinque si'
	#
	# E OGNI ANELLO RESTA FRA I SUOI VICINI. Il punto si sposta di un quinto della
	# distanza dall'anello dopo, non di una quota fissa: con venticinque anelli
	# fitti uno spostamento fisso scavalcava l'anello accanto, il pezzo si
	# incrociava su se stesso e il motore rifiutava di disegnarlo
	var giri := maxi(anelli, 1)
	var raggi: Array = []
	for punto_bordo in bordo:
		var raggio := PackedVector2Array()
		for k in giri - 1:
			var quota := pow(float(k + 1) / float(giri), CURVA_ANELLI)
			var dopo := pow(float(k + 2) / float(giri), CURVA_ANELLI)
			quota += (dopo - quota) * dado.randf_range(-0.2, 0.2)
			raggio.append(impatto.lerp(punto_bordo, quota))
		raggio.append(punto_bordo)
		raggi.append(raggio)
	for i in bordo.size():
		var qui: PackedVector2Array = raggi[i]
		var la: PackedVector2Array = raggi[(i + 1) % bordo.size()]
		aggiungi_scheggia([impatto, qui[0], la[0]], impatto, dado)
		for k in range(1, giri):
			aggiungi_scheggia([qui[k - 1], qui[k], la[k], la[k - 1]], impatto, dado)

func punti_sul_bordo(dado: RandomNumberGenerator, tagli := SPICCHI) -> Array[Vector2]:
	# i quattro angoli restano angoli - una scheggia con l'angolo del riquadro e'
	# quello che fa riconoscere COSA si e' rotto - e in mezzo si sparge il resto
	var punti: Array[Vector2] = []
	var perimetro := 2.0 * (misura.x + misura.y)
	var passi := maxi(tagli, 4)
	for i in passi:
		var quota := (float(i) / float(passi) + dado.randf_range(-0.035, 0.035))
		punti.append(sul_perimetro(fposmod(quota, 1.0) * perimetro))
	for angolo in [Vector2.ZERO, Vector2(misura.x, 0.0), misura, Vector2(0.0, misura.y)]:
		punti.append(angolo)
	# in giro attorno al riquadro, o i poligoni verrebbero incrociati
	var centro := misura * 0.5
	punti.sort_custom(func(a: Vector2, b: Vector2) -> bool:
		return (a - centro).angle() < (b - centro).angle())
	return punti

func sul_perimetro(distanza: float) -> Vector2:
	var d := distanza
	if d < misura.x:
		return Vector2(d, 0.0)
	d -= misura.x
	if d < misura.y:
		return Vector2(misura.x, d)
	d -= misura.y
	if d < misura.x:
		return Vector2(misura.x - d, misura.y)
	d -= misura.x
	return Vector2(0.0, misura.y - d)

func aggiungi_scheggia(punti: Array, impatto: Vector2, dado: RandomNumberGenerator) -> void:
	var centro := Vector2.ZERO
	for p in punti:
		centro += p
	centro /= float(punti.size())
	var relativi := PackedVector2Array()
	var uvi := PackedVector2Array()
	for p in punti:
		relativi.append(p - centro)
		uvi.append(Vector2(p.x / misura.x, p.y / misura.y))
	# schizza via dal punto d'impatto, e chi era piu' vicino schizza piu' forte:
	# e' da li' che e' arrivato il colpo
	var verso := (centro - impatto).normalized() if centro.distance_to(impatto) > 0.5 else Vector2.UP
	var vicinanza := 1.0 - clampf(centro.distance_to(impatto) / maxf(misura.length() * 0.5, 1.0), 0.0, 1.0)
	schegge.append({
		"punti": relativi,
		"uv": uvi,
		"posizione": centro,
		"velocita": verso * spinta * (0.45 + vicinanza) + Vector2(0.0, dado.randf_range(-70.0, -15.0)),
		"giro": dado.randf_range(-GIRO_MASSIMO, GIRO_MASSIMO),
		"rotazione": 0.0,
	})

func _process(delta: float) -> void:
	trascorso += delta
	if trascorso >= DURATA:
		set_process(false)
		finito.emit()
		queue_free()
		return
	for scheggia in schegge:
		var velocita: Vector2 = scheggia.velocita
		velocita.y += GRAVITA * delta
		scheggia.velocita = velocita
		scheggia.posizione = scheggia.posizione as Vector2 + velocita * delta
		scheggia.rotazione = float(scheggia.rotazione) + float(scheggia.giro) * delta
	queue_redraw()

func opacita() -> float:
	# RESTANO VISIBILI E POI SE NE VANNO. Una dissolvenza lineare le fa sembrare
	# gia' mezze sparite mentre stanno ancora cadendo, e il momento della rottura
	# - che e' quello che conta - si perde. Cosi' invece il primo terzo e' pieno.
	var quota := clampf(trascorso / DURATA, 0.0, 1.0)
	return clampf(1.0 - maxf(quota - 0.30, 0.0) / 0.70, 0.0, 1.0)

func _draw() -> void:
	var alfa := opacita()
	if alfa <= 0.0:
		return
	var tinta := Color(1, 1, 1, alfa)
	var tinta_piatta := Color(Stile.colore("pannello"), alfa)
	for scheggia in schegge:
		draw_set_transform(scheggia.posizione, scheggia.rotazione, Vector2.ONE)
		if foto != null:
			draw_colored_polygon(scheggia.punti, tinta, scheggia.uv, foto)
		else:
			draw_colored_polygon(scheggia.punti, tinta_piatta)
		if not fili:
			continue
		# il filo di luce sul taglio: e' l'unica cosa che fa leggere "vetro"
		# invece di "pezzi di carta"
		var contorno: PackedVector2Array = scheggia.punti.duplicate()
		contorno.append(contorno[0])
		draw_polyline(contorno, Color(Stile.colore("box_fondo"), alfa * 0.42), 1.5, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
