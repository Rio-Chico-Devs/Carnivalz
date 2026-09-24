class_name ContrastoCombattimento
extends RefCounted

# IL CONTRASTO: un braccio di ferro fra la tua mano e la mazza del goblin.
#
# Bru, sul goblin arrabbiato: «il minigioco sara' una mazzata che arriva
# all'improvviso, appare la mazzata, devi premere a raffica la barra
# spaziatrice per combattere, se ti batte passa un colpo pesante, altrimenti lo
# pari e subisci pochissimi danni a seconda di quanto ci hai messo per vincere
# lo scontro».
#
# E' IL ROVESCIO DELLA RAFFICA (Minigioco.gd). La' conta il momento giusto e
# dove clicchi; qui conta solo quante volte premi. Due domande diverse alla
# stessa mano, quindi due giochi: farne uno solo con due modalita' avrebbe
# voluto dire un modulo che sa due cose e le mescola.
#
# LA FISICA IN TRE NUMERI (in regole.json, "contrasto"; una mossa puo'
# cambiarli nei suoi dati):
#
#   per_pressione  quanto sposta la barra ogni pressione
#   spinta         quanto la riporta giu' il goblin ogni secondo, all'inizio
#   rincaro        di quanto quella spinta cresce per ogni secondo che passa
#
# Si parte a meta'. Arrivi in cima: la mazza e' respinta. Arrivi in fondo, o
# passa la "durata" senza che tu ce l'abbia fatta: la mazza cala.
#
# PERCHE' LA SPINTA CRESCE. A chiudere il contrasto basterebbe la durata; il
# rincaro serve a un'altra cosa: la mazza e' leggera all'inizio e pesa sempre
# di piu', quindi le prime pressioni valgono piu' delle ultime. Chi reagisce
# subito la respinge mentre e' ancora leggera; chi va piano la sente farsi
# pesante e perde anche a un ritmo che contro una spinta fissa basterebbe (tre
# pressioni al secondo: vedi prova_il_contrasto_si_vince_premendo). E' la
# stessa misura che Bru vuole dietro al danno, «a seconda di quanto ci hai
# messo», detta alla barra.
#
# DA MUTI NON DISEGNA E NON ASPETTA, come la raffica: al giocatore automatico
# si dice quante volte preme al secondo, e il contrasto si gioca tutto in una
# volta con la stessa fisica, a passi fissi. E' la stessa funzione che gira a
# schermo, non una formula che la imita: se la fisica cambia, le misure del
# simulatore cambiano con lei.

signal finito(esito: Dictionary)

# "MAZZATA!" e basta: la mazza comincia a spingere dopo questo mezzo secondo.
# Le pressioni contano gia' - chi reagisce subito parte avanti - ma nessuno
# perde terreno mentre sta ancora capendo cosa gli e' comparso davanti
const REAZIONE := 0.5
const CHIUSURA := 1.6              # quanto resta a schermo com'e' andata
# La mano che sta ancora martellando non deve chiudere il riepilogo per
# sbaglio: chi ha appena respinto la mazza preme ancora due o tre volte prima
# di accorgersene, e senza questa soglia il risultato non lo vedeva mai
const CHIUSURA_SORDA := 0.5
const PASSO_MUTO := 1.0 / 60.0
const DI_SERIE := {"per_pressione": 0.08, "spinta": 0.12, "rincaro": 0.04, "durata": 5.0}

var muto := false
var plancia: PlanciaCombattimento = null
var riquadro: RiquadroContrasto = null

var fisica: Dictionary = {}
var nome := ""
var fase := ""            # "reazione", "spinta", "chiusura"; "" a riposo
var tempo := 0.0          # da quando la mazza spinge
var tempo_fase := 0.0     # quello della reazione e della chiusura
var secondi := 0.0        # da quando e' comparsa: e' questo che pesa sul danno
var forza := 0.5          # 0 = la mazza ti schiaccia, 1 = l'hai respinta
var pressioni := 0
var vinto := false
var attivo := false
var in_partenza := false
var giocati := 0          # le prove contano questi, non i pixel

func _init(silenzioso := false) -> void:
	muto = silenzioso

func collega(dove: Control, tabellone: PlanciaCombattimento = null) -> void:
	# come la raffica: "dove" e' l'interno del quadrante, e il riquadro ci si
	# appende e ne prende la misura
	plancia = tabellone
	if dove == null or muto:
		return
	riquadro = RiquadroContrasto.new(self)
	riquadro.visible = false
	riquadro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dove.add_child(riquadro)

func prenota() -> bool:
	# UNO ALLA VOLTA, e chi l'ha chiesto deve sapere com'e' finito: e' la stessa
	# guardia della raffica (vedi MinigiocoCombattimento.prenota)
	if attivo or in_partenza:
		return false
	in_partenza = true
	return true

func rinuncia() -> void:
	in_partenza = false

func avvia(parametri: Dictionary, al_secondo := -1.0, dal_vivo := true) -> void:
	# "dal_vivo" false: c'e' un riquadro, ma nessuno che guardi l'orologio (le
	# prove a orologio virtuale). Si gioca da solo come da muti
	in_partenza = false
	var regole: Dictionary = GameState.regole.get("contrasto", {})
	fisica = {}
	for chiave in DI_SERIE:
		fisica[chiave] = float(parametri.get(chiave, regole.get(chiave, DI_SERIE[chiave])))
	nome = String(parametri.get("nome", "Mazzata"))
	fase = "reazione"
	tempo = 0.0
	tempo_fase = 0.0
	secondi = 0.0
	forza = 0.5
	pressioni = 0
	vinto = false
	giocati += 1
	if muto or riquadro == null or not dal_vivo:
		risolvi_da_solo(al_secondo)
		return
	attivo = true
	if plancia != null:
		plancia.mostra_faccia("minigioco")
	riquadro.visible = true
	riquadro.comincia(nome)

func risolvi_da_solo(al_secondo: float) -> void:
	# una mano regolare, "al_secondo" pressioni ogni secondo. Sotto zero non ci
	# prova nemmeno, ed e' la mano che non c'e'
	var orologio := 0.0
	var prossima := 0.0 if al_secondo > 0.0 else INF
	while in_gara():
		while in_gara() and orologio >= prossima:
			premi()
			prossima += 1.0 / al_secondo
		if in_gara():
			scorri(PASSO_MUTO)
		orologio += PASSO_MUTO
	attivo = false
	fase = ""
	finito.emit(esito())

func in_gara() -> bool:
	return fase == "reazione" or fase == "spinta"

func premi() -> void:
	if not in_gara():
		return
	pressioni += 1
	forza = minf(forza + float(fisica.get("per_pressione", 0.0)), 1.0)
	if forza >= 1.0:
		chiudi_la_gara(true)

func scorri(delta: float) -> void:
	secondi += delta
	if fase == "reazione":
		tempo_fase += delta
		if tempo_fase >= REAZIONE:
			fase = "spinta"
		return
	tempo += delta
	var spinta := float(fisica.get("spinta", 0.0)) + float(fisica.get("rincaro", 0.0)) * tempo
	forza = maxf(forza - spinta * delta, 0.0)
	if forza <= 0.0 or tempo >= float(fisica.get("durata", 1.0)):
		chiudi_la_gara(false)

func chiudi_la_gara(vittoria: bool) -> void:
	vinto = vittoria
	fase = "chiusura"
	tempo_fase = 0.0
	if attivo:
		# il suono solo dal vivo: il simulatore ne gioca migliaia
		AudioManager.interfaccia("parata" if vittoria else "colpo")
		riquadro.chiudi(esito())

func esito() -> Dictionary:
	# "quota" e' quanto del tempo concesso ci hai messo: 0 subito, 1 allo
	# scadere. E' su questa che si pesa il danno della parata
	var concesso := REAZIONE + float(fisica.get("durata", 1.0))
	return {
		"vinto": vinto,
		"secondi": secondi,
		"pressioni": pressioni,
		"quota": clampf(secondi / maxf(concesso, 0.001), 0.0, 1.0),
	}

# --- dal vivo --------------------------------------------------------------

func passa(delta: float) -> void:
	# ha un orologio suo: mentre gira, quello dello scontro e' fermo
	if not attivo:
		return
	if fase == "chiusura":
		tempo_fase += delta
		if tempo_fase >= CHIUSURA:
			concludi()
			return
	else:
		scorri(delta)
	if riquadro != null:
		riquadro.aggiorna(delta)

func premi_col_tasto() -> bool:
	# SPAZIO, INVIO o un clic sul riquadro: ogni pressione e' una spinta. Torna
	# false se il contrasto non c'e', cosi' chi chiama sa se l'evento e' suo
	if not attivo:
		return false
	if fase == "chiusura":
		if tempo_fase >= CHIUSURA_SORDA:
			concludi()
		return true
	premi()
	if riquadro != null:
		riquadro.pressione()
	return true

func concludi() -> void:
	attivo = false
	fase = ""
	if riquadro != null:
		riquadro.visible = false
	finito.emit(esito())
