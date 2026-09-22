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
var in_partenza := false   # chiesta, ma il box sta ancora finendo di parlare
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
	# parametri: quanti, intervallo, durata, danno, intervallo_finale
	#
	# UNA RAFFICA ALLA VOLTA, E CHI L'HA CHIESTA DEVE SAPERE COM'E' FINITA.
	#
	# Chi lancia il minigioco aspetta il segnale "finito": e' li' che il
	# combattimento riprende, si applica il danno e si va avanti col tutorial.
	# Avviando una seconda raffica sopra la prima, quel segnale per la prima non
	# arriverebbe MAI - e chi la stava aspettando resterebbe fermo per sempre.
	#
	# Oggi non succede: chi lancia ferma prima l'orologio, quindi nessuno arriva
	# a chiederne un'altra. Ma e' una garanzia di chi chiama, non di questo
	# modulo, e il tutorial e' destinato a crescere. Qui si chiude la prima -
	# cosi' chi aspettava riceve il suo esito - e si dice forte che e' successo.
	if attivo:
		push_error("Minigioco: una raffica e' stata avviata mentre la precedente era ancora in volo. La prima viene chiusa adesso, se no chi la aspettava resterebbe fermo.")
		concludi()
	in_partenza = false
	tempo = 0.0
	danno_per_colpo = int(parametri.get("danno", 0))
	raffica = Collisioni.calendario(
			int(parametri.get("quanti", 10)),
			float(parametri.get("intervallo", 0.42)),
			float(parametri.get("durata", 0.55)),
			dado, proporzione_quadrante(),
			float(parametri.get("intervallo_finale", -1.0)))
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
	# il disco si chiede una volta sola, come dappertutto: qui non e' un disegno
	# per fotogramma, ma e' lo stesso file a ogni raffica
	var disegno := Disegni.texture(DISEGNO_PUGNO)
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

func para_col_tasto() -> bool:
	# LA RAFFICA SI GIOCA ANCHE SENZA MOUSE. Era l'unico pezzo del combattimento
	# che un mouse lo pretendeva davvero: i pugni sono bottoni, ma cercarli col
	# Tab durante una raffica non e' giocare, e' un'altra cosa.
	#
	# Torna false se il tasto e' stato premuto a vuoto - cosi' chi chiama sa se
	# l'evento e' stato consumato o deve passare oltre.
	if not attivo:
		return false
	var quale := Collisioni.piu_urgente(raffica, tempo)
	if quale < 0:
		return false
	colpisci(quale)
	return true

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


static func racconto(esito: Dictionary) -> Dictionary:
	# COME SI RACCONTA UNA RAFFICA FINITA. "parati" e "totali" sono parole di
	# qui: chi conta i pugni sa anche come si dicono. Nel motore dello scontro
	# erano sei righe di formattazione in mezzo alla logica del danno.
	# "forte" vuol dire che il messaggio aspetta un click invece di scorrere
	# via: pararli tutti e' una cosa che merita di essere letta
	var totali := int(esito.get("totali", 0))
	var parati := int(esito.get("parati", 0))
	if totali > 0 and parati == totali:
		return {"forte": true, "testo": "[i]Non te ne arriva addosso nemmeno uno.[/i]"}
	return {"forte": false,
			"testo": "[i]%d colpi su %d ti arrivano addosso.[/i]" % [totali - parati, totali]}


func prenota() -> bool:
	# LA GUARDIA CHE CHIUDE IL BUCO, e sta qui perche' e' una politica di questo
	# modulo - quale raffica vince quando due la chiedono insieme - non un
	# dettaglio di chi la lancia. E' lo stesso motivo per cui Intenzione.gd
	# esiste: nasconde una decisione che cambiera' dopo il primo playtest.
	#
	# Il buco e' l'attesa che chi lancia fa prima di avviare, per lasciar
	# finire la frase "preparati!". Allo stesso passo del tutorial ci arrivano
	# due strade che non si conoscono - il giro dei turni e la via del
	# giocatore - e dentro quell'attesa la seconda entra: nel registro di Bru
	# sono due raffiche a sei millesimi l'una dall'altra.
	#
	# Il guardiano dentro avvia() se ne accorge e chiude la prima, ma e' una
	# rete e basta: chiuderla vuol dire che chi l'aspettava riceve un esito
	# inventato, e il bersaglio nel frattempo e' gia' cambiato - cioe' il danno
	# va addosso a chi non c'entra. Qui invece la seconda non parte proprio.
	#
	# false vuol dire "ce n'e' gia' una": chi la riceve se ne va senza fare
	# niente, che e' esattamente quello che deve fare.
	if attivo or in_partenza:
		return false
	in_partenza = true
	return true


func rinuncia() -> void:
	in_partenza = false
