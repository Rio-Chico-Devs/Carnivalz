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
var battiti: Array[float] = []
var generati_fino_a := 0.0

# --- IL GUASTO. La regola sta in EcgCombattimento.forza_glitch; qui c'e' solo
# come si vede. Tutto sta DENTRO questo Control, e clip_contents lo garantisce:
# Bru, «limita l'animazione al quadrante del ecg».
const LAG_OGNI := 1.7        # ogni quanto, circa, la linea si impianta
const LAG_QUANTO := 0.16     # e per quanto resta impiantata
const FETTE := 5             # in quante strisce si spezza quando sbanda
const DURATA_LAMPO := 0.32   # quanto ci mette a spegnersi il rosso di un battito
var prossimo_lag := 0.0
var fine_lag := 0.0
var sbandi := PackedFloat32Array()   # di quanto e' spostata ogni striscia
var prossimo_sbando := 0.0
var lampo := 0.0             # quanto e' acceso il battito dietro la linea

func _ready() -> void:
	storia.resize(CAMPIONI)
	# NIENTE ESCE DAL QUADRANTE. Le strisce sbandate e il lampo del battito
	# sono disegnati apposta piu' larghi del riquadro, perche' una striscia che
	# finisce esattamente sul bordo non sembra spostata: il ritaglio e' cio' che
	# li tiene a casa loro
	clip_contents = true
	sbandi.resize(FETTE)
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
	var passo_campione := SECONDI_A_SCHERMO / float(CAMPIONI)
	tempo += delta
	aggiorna_guasto()
	# IL LAG E' UNA RIGA SOLA: mentre e' impiantata non si campiona. La linea
	# resta ferma e poi recupera di colpo, che e' come si comporta uno schermo
	# che perde i fotogrammi - non un rallentamento, un buco.
	if tempo >= fine_lag:
		while prossimo_campione <= tempo:
			spingi(valore_a(prossimo_campione))
			prossimo_campione += passo_campione
	queue_redraw()

func aggiorna_guasto() -> void:
	# TRE COSE SEPARATE, e le tengo separate: il battito dietro la linea, le
	# strisce che sbandano, e la linea che si impianta. Erano una funzione sola
	# e il tetto sul garbuglio l'ha bocciata a 18 su 15 - aveva ragione: non
	# avevano niente in comune tranne il fotogramma in cui succedono.
	var forza := EcgCombattimento.forza_glitch(quota_hp)
	if forza <= 0.0:
		spegni_il_guasto()
		return
	aggiorna_lampo()
	aggiorna_sbandi(forza)
	aggiorna_lag(forza)

func spegni_il_guasto() -> void:
	lampo = 0.0
	fine_lag = 0.0
	for i in sbandi.size():
		sbandi[i] = 0.0

func aggiorna_lampo() -> void:
	# IL BATTITO. Non e' un timer da un secondo: e' agganciato ai battiti veri
	# che genera il modulo, quindi il lampo e la punta della linea succedono
	# NELLO STESSO ISTANTE. A riposo sono 62 al minuto, cioe' circa uno al
	# secondo come chiede Bru; sotto stress accelerano insieme al cuore.
	#
	# Si guarda QUANTO E' VECCHIO l'ultimo battito, non se ne e' successo uno in
	# questo fotogramma: la prima versione cercava dentro una finestra larga un
	# delta, e coi battiti che sbandano quella finestra la mancava quasi sempre -
	# il lampo non si accendeva mai.
	lampo = 0.0
	if not EcgCombattimento.batte_il_cuore(quota_hp):
		return
	var ultimo := -1.0
	for istante in battiti:
		if istante <= tempo and istante > ultimo:
			ultimo = istante
	if ultimo >= 0.0:
		lampo = clampf(1.0 - (tempo - ultimo) / DURATA_LAMPO, 0.0, 1.0)

func aggiorna_sbandi(forza: float) -> void:
	# LE STRISCE CAMBIANO A SCATTI, non di continuo: una distorsione che scivola
	# sembra un'onda, una che salta sembra un guasto.
	#
	# QUANTE strisce sbandano dipende dal guasto; DI QUANTO, molto meno. Tenendo
	# anche l'ampiezza proporzionale il giallo faceva strappi larghi un pixel,
	# invisibili: "attenuato" era diventato "assente". Misurato su uno scatto.
	if tempo < prossimo_sbando:
		return
	prossimo_sbando = tempo + dado.randf_range(0.08, 0.30) / forza
	for i in sbandi.size():
		sbandi[i] = 0.0 if dado.randf() > forza * 0.6 \
				else dado.randf_range(-1.0, 1.0) * size.x * 0.05 \
						* lerpf(0.55, 1.0, forza)

func aggiorna_lag(forza: float) -> void:
	# E LA LINEA CHE SI IMPIANTA, ogni tanto.
	if prossimo_lag <= 0.0:
		prossimo_lag = tempo + LAG_OGNI / forza
	if tempo < prossimo_lag:
		return
	fine_lag = tempo + LAG_QUANTO * forza
	prossimo_lag = tempo + dado.randf_range(LAG_OGNI * 0.6, LAG_OGNI * 1.6) / forza

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
	# lo spessore dice la stessa cosa del colore: vedi Ecg.spessore_per()
	var spessore := EcgCombattimento.spessore_per(quota_hp) * scala_spessore()
	var forza := EcgCombattimento.forza_glitch(quota_hp)
	# IL BATTITO DIETRO LA LINEA: un lampo rosso su tutto il riquadro, che
	# svanisce. Sta SOTTO al tracciato - davanti lo sporcherebbe invece di
	# accompagnarlo
	if lampo > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size),
				Color(tinta.r, tinta.g, tinta.b, 0.20 * lampo))
	if forza <= 0.0:
		draw_polyline(linea(0, storia.size(), mezzo, 0.0), tinta, spessore, true)
		return
	# A STRISCE, E OGNUNA SBANDA PER CONTO SUO: la stessa immagine tagliata e
	# rimessa insieme storta
	var per_striscia := int(ceil(float(storia.size()) / float(FETTE)))
	for f in FETTE:
		var da := f * per_striscia
		var a := mini(da + per_striscia + 1, storia.size())
		if a - da < 2:
			continue
		var scarto := float(sbandi[f]) if f < sbandi.size() else 0.0
		var punti := linea(da, a, mezzo, scarto)
		# LO SDOPPIAMENTO DI COLORE, solo dove il guasto e' forte: una copia
		# sbiadita spostata di poco, come un segnale che perde la sincronia
		if forza > 0.5 and not is_zero_approx(scarto):
			var fantasma := PackedVector2Array()
			for punto in punti:
				fantasma.append(punto + Vector2(-scarto * 0.6, 0.0))
			draw_polyline(fantasma, Color(tinta.r, tinta.g, tinta.b, 0.35),
					spessore * 0.8, true)
		draw_polyline(punti, tinta, spessore, true)

func linea(da: int, a: int, mezzo: float, scarto: float) -> PackedVector2Array:
	var punti := PackedVector2Array()
	for i in range(da, a):
		var x := size.x * float(i) / float(maxi(storia.size() - 1, 1))
		punti.append(Vector2(x + scarto, mezzo - campione(i) * mezzo * 0.86))
	return punti
