class_name MinigiocoCombattimento
extends RefCounted

# IL QUADRANTE. Sta dove sta il box del combattimento, e per un momento prende
# il suo posto.
#
# Bru, sul disegno della schermata: «quel quadrante sotto avrà varie funzioni
# durante il turno del nemico dovrai completare dei minigiochi per salvarti dai
# suoi colpi», e «il suo dialogo appare dove mettiamo i minigiochi e cosi anche
# quelli dei nemici e protagonisti più la narrazione del combattimento».
#
# Cioe': una superficie sola, che a turno racconta e gioca. Non serviva
# inventarla - il box del combattimento e' gia' quella superficie, ci passano
# gia' narrazione e dialoghi. Il minigioco ci si stende sopra, stesso
# rettangolo, e quando finisce lo restituisce.
#
# NON E' UN CONTENITORE. I pugni hanno una posizione loro e un contenitore
# gliela riscriverebbe al primo ridisegno: il quadrante vive attaccato alla
# radice della scena e si copia il rettangolo del box quando parte.
#
# DA MUTI NON DISEGNA E NON ASPETTA. Il giocatore automatico non ha un mouse:
# gli si dice quanto e' bravo (una quota fra 0 e 1), la raffica si risolve in
# un colpo solo e lo scontro prosegue. Cosi' il simulatore puo' misurare quanto
# vale saper parare senza che nessuno debba cliccare duecentomila volte.

signal finito(esito: Dictionary)

const COLORE_PUGNO := Color(0.93, 0.11, 0.14)
const DISEGNO_PUGNO := "res://art/minigiochi/pugno.png"

var muto := false
var quadrante: Control
var box: Control
var dado := RandomNumberGenerator.new()

var raffica: Array[Dictionary] = []
var pugni: Array[Control] = []
var tempo := 0.0
var attivo := false
var danno_per_colpo := 0
# quante raffiche sono state suonate: le prove contano queste, non i pixel
var suonate := 0

func _init(silenzioso := false) -> void:
	muto = silenzioso

func collega(dove: Control, riferimento: Control) -> void:
	quadrante = dove
	box = riferimento
	if quadrante != null:
		quadrante.visible = false
		quadrante.mouse_filter = Control.MOUSE_FILTER_IGNORE

func avvia(parametri: Dictionary, bravura := -1.0) -> void:
	# parametri: quanti, intervallo, durata, danno
	tempo = 0.0
	danno_per_colpo = int(parametri.get("danno", 0))
	raffica = Collisioni.calendario(
			int(parametri.get("quanti", 10)),
			float(parametri.get("intervallo", 0.42)),
			float(parametri.get("durata", 0.55)),
			dado, proporzione_quadrante())
	suonate += 1
	if muto or quadrante == null:
		risolvi_da_solo(bravura)
		return
	attivo = true
	stendi_sul_box()
	quadrante.visible = true
	quadrante.mouse_filter = Control.MOUSE_FILTER_STOP
	costruisci_pugni()

func proporzione_quadrante() -> float:
	# quanto e' largo rispetto a quanto e' alto. Da muti non c'e' nessun
	# rettangolo da misurare e vale uno: la raffica va risolta lo stesso, e
	# dove sarebbero comparsi i pugni non interessa nessuno.
	if box == null or box.size.y <= 0.0:
		return 1.0
	return box.size.x / box.size.y

func risolvi_da_solo(bravura: float) -> void:
	# Nessuno sta guardando. "Bravura" e' la quota di pugni che una mano para:
	# sotto zero vuol dire "non ci prova nemmeno", ed e' il caso del giocatore
	# automatico di oggi, che un mouse non ce l'ha.
	if bravura > 0.0:
		for pugno in raffica:
			if dado.randf() < bravura:
				pugno.parato = true
	attivo = false
	finito.emit(Collisioni.esito(raffica, danno_per_colpo))

func stendi_sul_box() -> void:
	# il rettangolo del box, preso adesso: la finestra puo' essere stata
	# ridimensionata da quando la scena e' nata
	if box == null:
		return
	var rettangolo := box.get_global_rect()
	quadrante.set_anchors_preset(Control.PRESET_TOP_LEFT)
	quadrante.global_position = rettangolo.position
	quadrante.size = rettangolo.size

func costruisci_pugni() -> void:
	for vecchio in pugni:
		if is_instance_valid(vecchio):
			vecchio.queue_free()
	pugni.clear()
	var disegno: Texture2D = null
	if ResourceLoader.exists(DISEGNO_PUGNO):
		disegno = load(DISEGNO_PUGNO)
	for pugno in raffica:
		var bottone := crea_pugno(pugno, disegno)
		quadrante.add_child(bottone)
		pugni.append(bottone)

func crea_pugno(pugno: Dictionary, disegno: Texture2D) -> Control:
	# Finche' i disegni di Bru non ci sono, un pugno e' un cerchio pieno del
	# rosso del gioco. Non e' un segnaposto per modo di dire: ha la misura e il
	# tempo che avra' il disegno vero, quindi il minigioco si puo' provare, e
	# soprattutto si puo' BILANCIARE, prima che esista un solo pixel.
	var lato := minf(quadrante.size.x, quadrante.size.y) * Collisioni.LATO_PUGNO
	var bottone := Button.new()
	bottone.flat = true
	bottone.focus_mode = Control.FOCUS_NONE
	bottone.custom_minimum_size = Vector2(lato, lato)
	bottone.size = Vector2(lato, lato)
	bottone.position = Vector2(
			float(pugno.x) * (quadrante.size.x - lato),
			float(pugno.y) * (quadrante.size.y - lato))
	bottone.visible = false
	if disegno != null:
		bottone.icon = disegno
		bottone.expand_icon = true
	else:
		bottone.draw.connect(disegna_cerchio.bind(bottone, lato))
	var indice := int(pugno.indice)
	bottone.pressed.connect(func() -> void: colpisci(indice))
	return bottone

func disegna_cerchio(bottone: Control, lato: float) -> void:
	var raggio := lato * 0.5
	bottone.draw_circle(Vector2(raggio, raggio), raggio, COLORE_PUGNO)
	bottone.draw_arc(Vector2(raggio, raggio), raggio * 0.94, 0.0, TAU, 28,
			Color(1, 1, 1, 0.75), raggio * 0.12)

func colpisci(indice: int) -> void:
	if not attivo:
		return
	if Collisioni.para(raffica, indice, tempo):
		if indice < pugni.size() and is_instance_valid(pugni[indice]):
			pugni[indice].visible = false
		AudioManager.interfaccia("parata")

func passa(delta: float) -> void:
	# il minigioco ha un orologio suo: mentre gira, quello dello scontro e' fermo
	if not attivo:
		return
	tempo += delta
	for pugno in raffica:
		var indice := int(pugno.indice)
		if indice >= pugni.size() or not is_instance_valid(pugni[indice]):
			continue
		var vivo := tempo >= float(pugno.istante) \
				and tempo <= float(pugno.istante) + float(pugno.durata) \
				and not bool(pugno.parato)
		pugni[indice].visible = vivo
	if tempo >= Collisioni.durata_totale(raffica):
		concludi()

func concludi() -> void:
	attivo = false
	for bottone in pugni:
		if is_instance_valid(bottone):
			bottone.queue_free()
	pugni.clear()
	if quadrante != null:
		quadrante.visible = false
		quadrante.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finito.emit(Collisioni.esito(raffica, danno_per_colpo))
