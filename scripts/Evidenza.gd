class_name Evidenza
extends Control

# COSA TI STA INDICANDO IL GIOCO, in combattimento: il nemico quando la Guida
# spiega la precedenza, BOND quando si accende, la tua scheda, il menu.
#
# PRIMA ERA UN ALONE ROSSO SFOCATO (Bagliore.gd, adesso tolto): una gaussiana
# impilata che respirava. Bru: «l'evidenziamento delle parti che attualmente e'
# un blur rosso e' pessimo, mi piacerebbe ci fosse un effetto tipo quello della
# schermata iniziale quando navighi le voci che c'e' quella macchia sul retro,
# oppure fai una lista di effetti, fammeli vedere e scelgo».
#
# Quindi qui ce ne sono quattro, e quale si vede lo dice data/stile.json
# ("evidenza"): si cambia una parola e non si tocca codice.
#
#   macchia          la macchia d'inchiostro del menu principale (VoceMacchia):
#                    quasi nera, si spande da sinistra con gli schizzi, e resta
#   macchia_cremisi  la stessa, del colore d'accento
#   cornice          un tratteggio cremisi intorno al pezzo, che scorre
#   segno            il triangolo delle voci di menu, accanto al pezzo, che batte
#                    verso di lui
#
# COSA HANNO IN COMUNE, e perche'. Stanno ACCANTO al pezzo, un gradino prima di
# lui fra i suoi fratelli: si disegnano dietro e non lo coprono mai, e lo
# seguono se si sposta o cambia misura. Non gli stanno DENTRO perche' il pezzo
# a volte e' spento - il riquadro del nemico, quando non e' il suo turno, sta a
# 0,65 di trasparenza - e un figlio si spegne con lui: la prima macchia dietro
# il nemico e' uscita grigia. Non prendono il mouse, o si mangerebbero il clic
# sul pezzo che indicano. E non lo tingono: il vecchio modo, modulate,
# moltiplicava i colori, e il pezzo indicato si leggeva peggio proprio mentre
# lo si indicava.
#
# NESSUNO SHADER, per la stessa ragione di tutto il resto dell'interfaccia:
# Godot senza finestra non compila i frammenti, e le prove girano tutte cosi'.

const STILI := ["macchia", "macchia_cremisi", "cornice", "segno"]

# LA MACCHIA E' UNA SUPERELLISSE, non un'ellisse: con l'esponente a dieci ha
# quasi gli angoli del rettangolo, e quindi sta dietro TUTTO il pezzo e ne esce
# un po' tutt'intorno. Un'ellisse lascerebbe fuori gli spigoli, e su un pannello
# grande come quello del nemico si vedrebbe una macchia ai lati e basta. La
# prova controlla che i quattro angoli del pezzo ci stiano dentro.
const ESPONENTE := 10.0
const PUNTI := 120             # tanti: con pochi, agli angoli si vedono gli smussi
const SPORGE := 8.0            # quanto esce oltre il bordo del pezzo, in pixel...
const SPORGE_QUOTA := 0.06     # ...piu' questa frazione del lato piu' corto...
const SPORGE_MASSIMO := 24.0   # ...ma mai oltre: il riquadro del nemico sta a 17
                               # pixel dal bordo dello schermo, e una macchia piu'
                               # larga usciva di li' e sembrava una cornice tagliata
const ONDA := 7.0              # di quanto l'orlo va e viene, in pixel: fisso, non
                               # in proporzione, o intorno al riquadro del nemico
                               # l'onda diventava larga come un dito
const FRANGE := 12.0           # a sinistra, dove batte il pennello, sporge di piu'
const OPACITA := 0.92

const TRATTO := 5.0            # la cornice: spessore, trattino, vuoto, distanza
const TRATTINO := 16.0
const VUOTO := 10.0
const DISTACCO := 9.0
const GIRO_CORNICE := 0.7      # secondi perche' il tratteggio scorra di un passo

# il segno sta nello spazio fra due pezzi: fra MATTANZA e BOND ce ne sono 28
# pixel, e uno piu' grande ci finiva sopra
const LATO_SEGNO := 18.0
const STACCO_SEGNO := 4.0      # quanto resta lontano dal pezzo, al massimo della corsa
const CORSA_SEGNO := 5.0       # quanto batte avanti e indietro
const BATTITO := 0.45          # mezzo battito, in secondi

var stile := "macchia"
# ogni passo dei tween ridisegna: sono i due numeri da cui dipende il disegno
var quanto := 0.0:             # l'entrata: la macchia che si spande da sinistra
	set(valore):
		quanto = valore
		queue_redraw()
var fase := 0.0:               # il movimento che resta: cornice e segno
	set(valore):
		fase = valore
		queue_redraw()
var forma := PackedVector2Array()   # la macchia, in frazioni del riquadro (-1..1)
var orli := PackedFloat32Array()    # quanto esce ogni punto oltre la forma, in pixel
var schizzi: Array[Vector3] = []    # x, y in frazioni, raggio in pixel
var arrivo: Tween = null
var giro: Tween = null


var pezzo: Control = null       # quello che indica


static func intorno_a(indicato: Control, quale := "") -> Evidenza:
	var e := Evidenza.new()
	e.stile = quale if quale != "" else Evidenza.stile_scelto()
	e.pezzo = indicato
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var seme := absi(hash(indicato.name))
	e.forma = Evidenza.macchia(PUNTI)
	e.orli = Evidenza.orlo(seme, PUNTI)
	e.schizzi = Evidenza.spruzzi(seme, 9)
	var genitore := indicato.get_parent()
	if genitore is Control and not genitore is Container:
		# accanto al pezzo, subito prima di lui: dietro, e fuori dal suo modulate
		genitore.add_child(e)
		genitore.move_child(e, indicato.get_index())
		indicato.item_rect_changed.connect(e.segui)
		indicato.visibility_changed.connect(e.segui)
		indicato.tree_exiting.connect(e.queue_free)
		e.segui()
	else:
		# un contenitore rimetterebbe in fila anche lei: allora dentro, dietro
		e.show_behind_parent = true
		e.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var fuori := e.sporgenza(indicato.size)
		e.offset_left = -fuori.x
		e.offset_top = -fuori.y
		e.offset_right = fuori.x
		e.offset_bottom = fuori.y
		indicato.add_child(e)
	return e


static func libera(quale: String) -> Evidenza:
	# UN'EVIDENZA CHE NON STA ACCANTO A NESSUN PEZZO: la mette dove serve chi la
	# usa, con inquadra(). Serve al giro del data pad (GiroDataPad), che indica
	# voci di un altro livello dello schermo - il data pad sta sopra tutto, e
	# una cornice accanto alla voce finirebbe sotto il velo del giro
	var e := Evidenza.new()
	e.stile = quale
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	e.forma = Evidenza.macchia(PUNTI)
	e.orli = Evidenza.orlo(1, PUNTI)
	return e


func inquadra(dove: Rect2) -> void:
	var fuori := sporgenza(dove.size)
	position = dove.position - fuori
	size = dove.size + fuori * 2.0


func segui() -> void:
	# dove sta il pezzo, piu' quello che serve intorno
	if pezzo == null or not is_instance_valid(pezzo) or pezzo.get_parent() != get_parent():
		return
	var fuori := sporgenza(pezzo.size)
	position = pezzo.position - fuori
	size = pezzo.size + fuori * 2.0
	visible = pezzo.visible


static func stile_scelto() -> String:
	# UN NOME SBAGLIATO NEI DATI DEVE DIRLO: un'evidenza che non si vede e' uguale
	# a una che nessuno ha chiesto, e chi prova le varianti non se ne accorgerebbe
	var scelto := String(Stile.dati.get("evidenza", {}).get("stile", "macchia"))
	if scelto in STILI:
		return scelto
	push_error("stile.json: l'evidenza '%s' non esiste (ci sono %s)" % [scelto, ", ".join(STILI)])
	return "macchia"


func sporgenza(lato: Vector2) -> Vector2:
	# quanto spazio serve intorno al pezzo: la macchia ne esce, la cornice gli
	# gira intorno, il segno gli sta accanto
	match stile:
		"cornice":
			return Vector2.ONE * (DISTACCO + TRATTO)
		"segno":
			return Vector2(LATO_SEGNO + STACCO_SEGNO + CORSA_SEGNO, 0.0)
	return Vector2.ONE * minf(SPORGE + SPORGE_QUOTA * minf(lato.x, lato.y), SPORGE_MASSIMO)


func accendi() -> void:
	# LA MACCHIA ARRIVA E RESTA. Si spande da sinistra come quella del menu, nel
	# tempo di un'entrata, e poi sta ferma: e' l'arrivo a portare l'occhio li', e
	# una cosa che continua a muoversi per minuti accanto a un testo da leggere
	# da' fastidio. Cornice e segno invece si muovono sempre: sono sottili, e
	# fermi si perderebbero.
	ferma()
	if Movimento.ridotto():
		completa()
		return
	quanto = 0.0
	arrivo = create_tween()
	arrivo.tween_property(self, "quanto", 1.0, Movimento.durata("entrata")) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if stile == "cornice" or stile == "segno":
		giro = create_tween().set_loops()
		var passo := GIRO_CORNICE if stile == "cornice" else BATTITO
		giro.tween_property(self, "fase", 1.0, passo).from(0.0) \
				.set_trans(Tween.TRANS_SINE if stile == "segno" else Tween.TRANS_LINEAR)


func completa() -> void:
	# tutta fuori, subito: per chi riduce il movimento, e per gli scatti
	quanto = 1.0


func ferma() -> void:
	for t in [arrivo, giro]:
		if t != null and (t as Tween).is_valid():
			(t as Tween).kill()
	arrivo = null
	giro = null


func _draw() -> void:
	match stile:
		"cornice": disegna_cornice()
		"segno": disegna_segno()
		_: disegna_macchia()


func tinta() -> Color:
	return Stile.colore("menu_macchia") if stile == "macchia" else Stile.colore("accento")


func poligono(pieno: float) -> PackedVector2Array:
	# la macchia in pixel, spansa per "pieno": la x si allunga da sinistra, la y
	# no - come quella del menu
	var centro := size * 0.5
	var punti := PackedVector2Array()
	for i in forma.size():
		var p := forma[i]
		var fuori := p.normalized() * (orli[i] if i < orli.size() else 0.0)
		var x := centro.x + p.x * centro.x + fuori.x
		punti.append(Vector2(lerpf(0.0, x, pieno), centro.y + p.y * centro.y + fuori.y))
	return punti


func disegna_macchia() -> void:
	var pieno := clampf(quanto, 0.0, 1.2)
	if pieno <= 0.01:
		return
	draw_colored_polygon(poligono(pieno), Color(tinta(), OPACITA))
	# gli schizzi arrivano per ultimi, quando la macchia e' quasi tutta fuori
	var schizzo := clampf((quanto - 0.6) / 0.4, 0.0, 1.0)
	if schizzo <= 0.0:
		return
	var centro := size * 0.5
	for s in schizzi:
		draw_circle(Vector2(centro.x + s.x * centro.x, centro.y + s.y * centro.y), s.z,
				Color(tinta(), 0.85 * schizzo))


func disegna_cornice() -> void:
	# il tratteggio gira intorno al pezzo: i trattini scivolano lungo il bordo di
	# un passo a ogni giro, come le formiche di una selezione
	var r := Rect2(Vector2.ONE * TRATTO * 0.5, size - Vector2.ONE * TRATTO)
	var angoli := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	var passo := TRATTINO + VUOTO
	var lungo := 0.0
	var colore := Color(Stile.colore("accento"), clampf(quanto, 0.0, 1.0))
	for i in 4:
		var da: Vector2 = angoli[i]
		var a: Vector2 = angoli[(i + 1) % 4]
		var tratto := da.distance_to(a)
		var verso := (a - da) / maxf(tratto, 0.001)
		# dove comincia il primo trattino su questo lato, perche' il disegno
		# continui dall'angolo senza strappi
		var inizio := fmod(passo - fmod(lungo - fase * passo, passo), passo) - passo
		var t := inizio
		while t < tratto:
			var t0 := maxf(t, 0.0)
			var t1 := minf(t + TRATTINO, tratto)
			if t1 > t0:
				draw_line(da + verso * t0, da + verso * t1, colore, TRATTO)
			t += passo
		lungo += tratto


func disegna_segno() -> void:
	# IL TRIANGOLO DELLE VOCI DI MENU, dalla parte dove c'e' spazio: a sinistra
	# del pezzo se lo schermo lo permette, se no a destra, sempre puntato verso
	# di lui. Batte avanti e indietro: e' un dito che indica, non una decorazione
	var sul_bordo := get_global_rect().position.x < 0.0
	var batte := sin(fase * PI) * CORSA_SEGNO
	var y := size.y * 0.5
	var dal_bordo := LATO_SEGNO + CORSA_SEGNO   # la punta, a riposo: il pezzo e' a +STACCO
	var punta := Vector2(dal_bordo + batte, y) if not sul_bordo \
			else Vector2(size.x - dal_bordo - batte, y)
	var dietro := -1.0 if not sul_bordo else 1.0
	var mezzo := LATO_SEGNO * 0.5
	var triangolo := PackedVector2Array([punta,
			punta + Vector2(dietro * LATO_SEGNO, -mezzo),
			punta + Vector2(dietro * LATO_SEGNO, mezzo)])
	draw_colored_polygon(triangolo, Color(Stile.colore("accento"), clampf(quanto, 0.0, 1.0)))


static func macchia(quanti: int) -> PackedVector2Array:
	# LA FORMA DI FONDO E' UNA SUPERELLISSE, e da sola copre gia' tutto il pezzo
	# (vedi ESPONENTE). L'orlo si aggiunge sopra, solo in fuori: cosi' quello che
	# copre lei lo copre anche la macchia. Il poligono resta stellato intorno al
	# centro, quindi non si incrocia mai e si puo' riempire
	var punti := PackedVector2Array()
	for i in quanti:
		var angolo := TAU * float(i) / float(quanti)
		var c := cos(angolo)
		var s := sin(angolo)
		var raggio := pow(pow(absf(c), ESPONENTE) + pow(absf(s), ESPONENTE), -1.0 / ESPONENTE)
		punti.append(Vector2(c, s) * raggio)
	return punti


static func orlo(seme: int, quanti: int) -> PackedFloat32Array:
	# L'ORLO ONDEGGIA, NON TREMA, sempre uguale per lo stesso pezzo (il seme e' il
	# suo nome). Con uno scarto a caso per ogni punto il bordo veniva peloso, e
	# la macchia si leggeva come una cornice smussata: l'inchiostro ha un orlo
	# che va e viene piano. Tre onde lente con la fase a caso, e a sinistra,
	# dove il pennello ha battuto, qualche frangia
	var dado := RandomNumberGenerator.new()
	dado.seed = seme
	var onde: Array[Vector3] = []   # quante volte gira, fase, peso
	for k in [3.0, 5.0, 9.0]:
		onde.append(Vector3(k, dado.randf_range(0.0, TAU), dado.randf_range(0.25, 0.45)))
	var fuori := PackedFloat32Array()
	for i in quanti:
		var angolo := TAU * float(i) / float(quanti)
		var quanto_esce := 0.0
		for onda in onde:
			quanto_esce += onda.z * (1.0 + sin(onda.x * angolo + onda.y)) * 0.5
		quanto_esce *= ONDA
		if cos(angolo) < -0.4 and i % 5 == 0:
			quanto_esce += dado.randf_range(FRANGE * 0.3, FRANGE)
		fuori.append(quanto_esce)
	return fuori


static func spruzzi(seme: int, quanti: int) -> Array[Vector3]:
	# attorno alla macchia, piu' fitti a sinistra dove il pennello ha battuto
	var dado := RandomNumberGenerator.new()
	dado.seed = seme + 1
	var elenco: Array[Vector3] = []
	for i in quanti:
		var angolo := dado.randf_range(PI * 0.55, PI * 1.45) if i % 3 != 0 else dado.randf_range(0.0, TAU)
		var lontano := dado.randf_range(1.06, 1.22)
		elenco.append(Vector3(cos(angolo) * lontano, sin(angolo) * lontano, dado.randf_range(1.6, 4.2)))
	return elenco
