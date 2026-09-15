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
const SPESSORE := 2.0   # lo spessore di riferimento, per un riquadro alto 110

var quota_hp := 1.0
var stress := 0
var dado := RandomNumberGenerator.new()

var storia := PackedFloat32Array()
var tempo := 0.0
var prossimo_campione := 0.0
var battiti: Array[float] = []
var generati_fino_a := 0.0

func _ready() -> void:
	storia.resize(CAMPIONI)
	set_process(true)

func imposta(vita: float, tensione: int) -> void:
	quota_hp = clampf(vita, 0.0, 1.0)
	stress = clampi(tensione, 0, 100)

func _process(delta: float) -> void:
	var passo_campione := SECONDI_A_SCHERMO / float(CAMPIONI)
	tempo += delta
	while prossimo_campione <= tempo:
		spingi(valore_a(prossimo_campione))
		prossimo_campione += passo_campione
	queue_redraw()

func spingi(valore: float) -> void:
	# il piu' vecchio esce da sinistra, il nuovo entra da destra
	for i in range(storia.size() - 1):
		storia[i] = storia[i + 1]
	storia[storia.size() - 1] = valore

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
	var valore := 0.0
	for istante in battiti:
		if istante > quando:
			continue
		if quando - istante > passo:
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
	var punti := PackedVector2Array()
	for i in storia.size():
		var x := size.x * float(i) / float(maxi(storia.size() - 1, 1))
		punti.append(Vector2(x, mezzo - storia[i] * mezzo * 0.86))
	# lo spessore dice la stessa cosa del colore: vedi Ecg.spessore_per()
	var spessore := EcgCombattimento.spessore_per(quota_hp) * scala_spessore()
	draw_polyline(punti, tinta, spessore, true)
