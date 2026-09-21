class_name TracciatoEcg
extends Control

# LA LINEA CHE SI MUOVE. Disegna quello che EcgCombattimento calcola.
#
# Qui dentro non c'e' nessuna regola: il colore lo decide la quota di vita, il
# nervosismo lo decide lo stress, e tutte e due le decisioni stanno nel modulo
# accanto, dove si possono misurare. Questo nodo sa fare una cosa sola: far
# scorrere una linea da destra a sinistra, come un monitor vero.
#
# SCORRE, NON SI RIDISEGNA. Un tracciato che si rigenera tutto a ogni
# fotogramma non sembra un cuore che batte, sembra un'animazione: quello che lo
# rende vivo e' che il passato resta fermo e il nuovo entra da un lato solo.

const SECONDI_A_SCHERMO := 4.0
const CAMPIONI := 240
var quota_hp := 1.0
var stress := 0
var dado := RandomNumberGenerator.new()

var storia := PackedFloat32Array()
# dove va il PROSSIMO campione, e quindi anche dov'e' il piu' vecchio: la
# storia e' un anello, non una fila che scorre (vedi spingi)
var testa := 0
# quanti campioni sono stati presi davvero. Serve alle prove: e' l'unico modo
# di dire "non sta campionando mentre nessuno lo guarda" con un numero
var campioni_presi := 0
var tempo := 0.0
var prossimo_campione := 0.0
# il monitor era gia' acceso prima che lo guardassi: vedi riempi_lo_schermo
var riempito := false
var battiti: Array[float] = []
var generati_fino_a := 0.0

# --- IL GUASTO. La regola sta in EcgCombattimento.forza_glitch; qui c'e' solo
# come si vede. Tutto sta DENTRO questo Control, e clip_contents lo garantisce:
# Bru, «limita l'animazione al quadrante del ecg».
const DURATA_LAMPO := 0.32   # quanto ci mette a spegnersi il rosso di un battito
var lampo := 0.0             # quanto e' acceso il battito dietro la linea

# --- COME E' FATTA LA LINEA. Il riferimento e' quello che ha mandato Bru: un
# monitor con la griglia dietro, la traccia che si assottiglia e si spegne
# verso la coda, e in testa un punto piu' grosso e piu' acceso. In mezzo il
# bagliore, che e' quello che la fa sembrare accesa invece che disegnata.
const PEZZI := 14            # in quanti tratti si spezza per sfumare la coda
const CODA_SPESSORE := 0.35  # quanto e' sottile in fondo rispetto alla testa
const CODA_LUCE := 0.18      # e quanto e' spenta
const ALONI := 3             # quante passate di bagliore sotto la linea
const GRIGLIA_PASSO := 26.0  # ogni quanti pixel una riga della griglia

func _ready() -> void:
	storia.resize(CAMPIONI)
	# NIENTE ESCE DAL QUADRANTE. Le strisce sbandate e il lampo del battito
	# sono disegnati apposta piu' larghi del riquadro, perche' una striscia che
	# finisce esattamente sul bordo non sembra spostata: il ritaglio e' cio' che
	# li tiene a casa loro
	clip_contents = true
	set_process(true)

func imposta(vita: float, tensione: int) -> void:
	quota_hp = clampf(vita, 0.0, 1.0)
	stress = clampi(tensione, 0, 100)

func _process(delta: float) -> void:
	# NESSUNO LO STA GUARDANDO, NESSUNO LO DISEGNA.
	#
	# Il quadrante fa tre mestieri e ne mostra uno per volta: mentre scegli da
	# una lista, o mentre il box racconta, l'ecg non si vede. Continuava a
	# campionare lo stesso - sessanta volte al secondo, per una linea che non
	# era a schermo. Quando torna visibile riprende da dov'era, che e' anche
	# piu' onesto di un salto.
	if not is_visible_in_tree():
		return
	if not riempito:
		riempi_lo_schermo()
	var passo_campione := SECONDI_A_SCHERMO / float(CAMPIONI)
	tempo += delta
	aggiorna_guasto()
	while prossimo_campione <= tempo:
		spingi(valore_a(prossimo_campione))
		prossimo_campione += passo_campione
	queue_redraw()

func riempi_lo_schermo() -> void:
	# IL MONITOR ERA GIA' ACCESO PRIMA CHE LO GUARDASSI.
	#
	# La storia nasce piena di zeri, e uno zero si disegna come una riga dritta:
	# per i primi quattro secondi di ogni scontro meta' quadrante era una linea
	# PIATTA che arretrava mentre il tracciato vero entrava da destra. Su un
	# monitor una linea piatta vuol dire una cosa sola, ed e' il contrario di
	# quello che l'ecg deve dire quando lo scontro comincia. Si vedeva in ogni
	# scatto e non l'avevo mai guardato.
	#
	# Si riempie facendo girare il SEGNALE VERO per i quattro secondi
	# precedenti, non disegnando una finta onda: quello che si vede all'apertura
	# e' esattamente la linea che ci sarebbe stata se qualcuno avesse guardato
	# prima. Una volta sola, al primo fotogramma in cui il quadrante e' a
	# schermo - cioe' quando imposta() ha gia' detto vita e stress veri.
	riempito = true
	var passo_campione := SECONDI_A_SCHERMO / float(CAMPIONI)
	tempo = SECONDI_A_SCHERMO
	while prossimo_campione <= tempo:
		spingi(valore_a(prossimo_campione))
		prossimo_campione += passo_campione

func aggiorna_guasto() -> void:
	# L'IRREGOLARITA' SI E' RIDOTTA A UNA COSA SOLA: il battito.
	#
	# Prima qui c'erano anche le strisce sbandate (datamosh) e la linea che si
	# impiantava per qualche fotogramma. Bru, guardandola: «e' fatta in modo
	# superficiale e poco realistico, SEMBRA LAGGI, l'effetto deve essere
	# ordinato e ben fatto». Aveva ragione, ed e' una distinzione che vale la
	# pena tenere scritta: un'interfaccia che si spezza a caso non si legge come
	# "il personaggio sta male", si legge come "il gioco e' rotto". Il
	# nervosismo lo raccontano gia' il ritmo irregolare dei battiti e il tremore
	# della linea di base, che sono nel SEGNALE - cioe' veri - e non nel disegno.
	#
	# Quello che resta e' il cuore che batte dietro la linea, che e' la cosa che
	# Bru aveva chiesto per prima.
	aggiorna_lampo()

func aggiorna_lampo() -> void:
	# IL BATTITO, agganciato ai battiti veri che genera il modulo: il lampo e la
	# punta della linea succedono NELLO STESSO ISTANTE. A riposo sono 62 al
	# minuto, cioe' circa uno al secondo come chiede Bru; sotto stress
	# accelerano insieme al cuore.
	#
	# Si guarda QUANTO E' VECCHIO l'ultimo battito, non se ne e' successo uno in
	# questo fotogramma: la prima versione cercava dentro una finestra larga un
	# delta, e coi battiti che sbandano quella finestra la mancava quasi sempre.
	lampo = 0.0
	if not EcgCombattimento.batte_il_cuore(quota_hp):
		return
	var ultimo := -1.0
	for istante in battiti:
		if istante <= tempo and istante > ultimo:
			ultimo = istante
	if ultimo >= 0.0:
		lampo = clampf(1.0 - (tempo - ultimo) / DURATA_LAMPO, 0.0, 1.0)

func spingi(valore: float) -> void:
	# IL PIU' VECCHIO ESCE DA SINISTRA, IL NUOVO ENTRA DA DESTRA - ma senza
	# spostare niente.
	#
	# Prima questa riga faceva scorrere tutto l'array di un posto: 239 scritture
	# per campione, sessanta campioni al secondo, per tutta la durata di ogni
	# scontro. Fa la stessa identica cosa muovere il punto di partenza invece
	# dei dati: la storia e' un anello, e "il piu' vecchio" e' semplicemente
	# quello dove scriveremo il prossimo.
	if storia.is_empty():
		return
	storia[testa] = valore
	testa = (testa + 1) % storia.size()
	campioni_presi += 1

func campione(indice: int) -> float:
	# dal piu' vecchio al piu' recente, che e' l'ordine in cui si disegna
	if storia.is_empty():
		return 0.0
	return storia[(testa + indice) % storia.size()]

func valore_a(quando: float) -> float:
	# CHI E' A TERRA FA UNA RIGA DRITTA: la stessa regola del modulo, e vale
	# prima di generare qualunque battito
	if quota_hp <= 0.0:
		return 0.0
	var passo := EcgCombattimento.intervallo(stress)
	# i battiti si generano man mano, non tutti all'inizio: lo scontro dura
	# quanto dura, e lo stress cambia mentre va
	while generati_fino_a < quando + passo:
		var sbando := EcgCombattimento.SBANDAMENTO_MASSIMO * EcgCombattimento.quota_stress(stress)
		battiti.append(maxf(generati_fino_a + dado.randf_range(-sbando, sbando) * passo, 0.0))
		generati_fino_a += passo
	# SI BUTTANO VIA I BATTITI VECCHI, e non e' pulizia: e' una perdita.
	#
	# Un battito piu' vecchio di "passo" non contribuisce piu' niente - onda()
	# gli risponde zero - ma restava nell'elenco per sempre, e l'elenco veniva
	# riletto PER OGNI CAMPIONE, sessanta volte al secondo. Dopo cinque minuti
	# di scontro erano settecento battiti morti riletti quarantamila volte al
	# secondo: uno scontro lungo rallentava, e rallentava sempre di piu'.
	while not battiti.is_empty() and quando - battiti[0] > passo:
		battiti.remove_at(0)
	var valore := 0.0
	for istante in battiti:
		if istante > quando:
			continue
		valore += EcgCombattimento.onda(quando - istante, passo)
	var tremore := EcgCombattimento.TREMORE_MASSIMO * EcgCombattimento.quota_stress(stress)
	if tremore > 0.0:
		valore += dado.randf_range(-tremore, tremore)
	return clampf(valore, -1.0, 1.0)

func scala_spessore() -> float:
	# una linea spessa due pixel dentro un riquadro alto trecento non si vede:
	# lo spessore segue l'altezza del riquadro, come tutto il resto della plancia
	return maxf(size.y / 110.0, 0.6)

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var tinta := Stile.colore("ecg_" + EcgCombattimento.colore_per(quota_hp))
	var mezzo := size.y * 0.5
	var spessore := EcgCombattimento.spessore_per(quota_hp) * scala_spessore()
	disegna_griglia(tinta)
	# IL BATTITO DIETRO LA LINEA: un lampo su tutto il riquadro che svanisce.
	# Sta sotto al tracciato - davanti lo sporcherebbe invece di accompagnarlo
	if lampo > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size),
				Color(tinta.r, tinta.g, tinta.b, 0.12 * lampo))
	# IL PUNTO IN TESTA DEVE STARCI DENTRO. La traccia arrivava esattamente al
	# bordo destro, quindi meta' del punto finiva fuori e il ritaglio se la
	# mangiava: si vedeva un mezzo disco tagliato, che e' peggio di niente.
	# Adesso la linea si ferma un po' prima, quel tanto che basta al punto e al
	# suo alone.
	var punti := tutta_la_linea(mezzo, spessore * 3.4)
	if punti.size() < 2:
		return
	disegna_coda(punti, tinta, spessore)
	disegna_testa(punti[punti.size() - 1], tinta, spessore)

func disegna_griglia(tinta: Color) -> void:
	# LA GRIGLIA DIETRO, come su un monitor vero: righe sottilissime dello
	# stesso colore della traccia, quasi spente. Non e' decorazione - e' quello
	# che da' la scala, ed e' il motivo per cui una linea che oscilla sembra uno
	# strumento invece di uno scarabocchio.
	# LA GRIGLIA SI ACCENDE COL BATTITO. Bru: «it would be awesome that the line
	# was slightly glow and illuminates a grid background». Non e' solo dietro:
	# quando il cuore batte, la griglia prende luce anche lei - e' quello che fa
	# sembrare il vetro illuminato dalla traccia invece che stampato.
	var riga := Color(tinta.r, tinta.g, tinta.b, 0.085 + 0.10 * lampo)
	var x := GRIGLIA_PASSO
	while x < size.x:
		draw_line(Vector2(x, 0.0), Vector2(x, size.y), riga, 1.0)
		x += GRIGLIA_PASSO
	var y := GRIGLIA_PASSO
	while y < size.y:
		draw_line(Vector2(0.0, y), Vector2(size.x, y), riga, 1.0)
		y += GRIGLIA_PASSO

func tutta_la_linea(mezzo: float, margine: float) -> PackedVector2Array:
	var punti := PackedVector2Array()
	var largo := maxf(size.x - margine, 1.0)
	for i in storia.size():
		var x := largo * float(i) / float(maxi(storia.size() - 1, 1))
		punti.append(Vector2(x, mezzo - campione(i) * mezzo * 0.86))
	return punti

func disegna_coda(punti: PackedVector2Array, tinta: Color, spessore: float) -> void:
	# SI ASSOTTIGLIA E SI SPEGNE VERSO IL FONDO. Nel riferimento di Bru la
	# traccia e' sottile e smorta in coda e piena in testa: e' quello che fa
	# leggere la direzione del tempo senza dover guardare due volte.
	#
	# Si disegna a TRATTI e non campione per campione: duecentoquaranta
	# segmenti, moltiplicati per le passate di bagliore, sarebbero
	# millequattrocento chiamate di disegno a fotogramma per una riga sola.
	# Quattordici tratti si vedono uguale.
	var per_tratto := int(ceil(float(punti.size()) / float(PEZZI)))
	for p in PEZZI:
		var da := p * per_tratto
		var a := mini(da + per_tratto + 1, punti.size())
		if a - da < 2:
			continue
		var quanto_avanti := float(p) / float(maxi(PEZZI - 1, 1))
		var tratto := PackedVector2Array()
		for i in range(da, a):
			tratto.append(punti[i])
		var largo := spessore * lerpf(CODA_SPESSORE, 1.0, quanto_avanti)
		var luce := lerpf(CODA_LUCE, 1.0, quanto_avanti)
		# IL BAGLIORE: la stessa linea ripassata piu' larga e quasi trasparente.
		# E' un bloom da poveri e non serve nessuno shader: tre passate bastano
		# perche' la linea sembri ACCESA invece che disegnata
		for alone in ALONI:
			var quanto_alone := float(alone + 1)
			draw_polyline(tratto, Color(tinta.r, tinta.g, tinta.b,
					luce * 0.20 / quanto_alone),
					largo * (1.0 + quanto_alone * 2.0), true)
		draw_polyline(tratto, Color(tinta.r, tinta.g, tinta.b, luce), largo, true)

func disegna_testa(dove: Vector2, tinta: Color, spessore: float) -> void:
	# IL PUNTO IN TESTA. Nel riferimento c'e', ed e' la cosa che fa capire dove
	# sta scrivendo adesso: senza, la linea e' un grafico; con, e' uno strumento
	# acceso che sta misurando qualcosa in questo momento.
	var raggio := spessore * 1.15
	for alone in ALONI:
		var quanto := float(alone + 1)
		draw_circle(dove, raggio * (1.0 + quanto * 1.6),
				Color(tinta.r, tinta.g, tinta.b, 0.13 / quanto))
	draw_circle(dove, raggio, tinta)
	# un cuore dentro piu' chiaro: e' il riflesso del vetro
	draw_circle(dove, raggio * 0.45, Color(1, 1, 1, 0.75))
