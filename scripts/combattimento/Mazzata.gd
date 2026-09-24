class_name MazzataCombattimento
extends RefCounted

# LA MAZZATA: una mossa che non si subisce e basta, si contrasta con la mano.
#
# Bru: «se ti batte passa un colpo pesante, altrimenti lo pari e subisci
# pochissimi danni a seconda di quanto ci hai messo per vincere lo scontro».
#
# Il braccio di ferro sta in Contrasto.gd, ed e' un gioco che non sa niente di
# goblin. Qui c'e' il resto: su chi cala, quando il riquadro puo' prendersi il
# quadrante, e cosa resta addosso dopo. E' un modulo a parte per la stessa
# ragione della Regia: Combattimento.gd e' gia' il file piu' grande del gioco,
# e questa e' una cosa che si capisce da sola.
#
# NEI DATI DELLA MOSSA:
#
#   "tipo": "mazzata",
#   "quota": 2.6,                  il colpo pieno, se ti batte: quote del suo attacco
#   "danno_parato": [1, 5],        se la pari: dal piu' svelto al piu' lento
#   "testo_parata", "testo_colpo"  come va a finire, detto nel box
#   "contrasto": {...}             facoltativo: cambia la fisica di regole.json
#
# DOVE NON C'E' NESSUNO A PREMERE, preme una mano automatica: "mano_automatica"
# in regole.json, pressioni al secondo. Serve al simulatore e alle prove - una
# mazzata che nessuno contrasta mai e' un'altra creatura, e le misure del
# bilanciamento parlerebbero di quella.

var scontro: Combattimento
var contrasto: ContrastoCombattimento
var chi_cala: Dictionary = {}
var su_chi: Dictionary = {}
var mossa: Dictionary = {}
var tempo_fermato := false

func _init(nodo_scontro: Combattimento, muto: bool) -> void:
	scontro = nodo_scontro
	contrasto = ContrastoCombattimento.new(muto)
	contrasto.finito.connect(_finita)

func collega(dove: Control, plancia: PlanciaCombattimento) -> void:
	contrasto.collega(dove, plancia)

func in_corso() -> bool:
	return contrasto.attivo

func passa(delta: float) -> bool:
	# true = il contrasto si e' preso questo fotogramma, e il mondo aspetta
	if not contrasto.attivo:
		return false
	contrasto.passa(delta)
	return true

func prende(evento: InputEvent) -> bool:
	# SPAZIO E' SUO finche' dura: viene prima della Mattanza e del testo da
	# far scorrere, perche' in quei secondi l'unica cosa da fare e' spingere
	return contrasto.attivo and evento.is_action_pressed("ui_accept") \
			and contrasto.premi_col_tasto()

static func mano_automatica() -> float:
	return float(GameState.regole.get("contrasto", {}).get("mano_automatica", -1.0))

func cala(nemico: Dictionary, dati: Dictionary) -> void:
	var vittima: Dictionary = scontro.bersaglio_giocatore_casuale()
	if vittima.is_empty():
		return
	if not contrasto.prenota():
		# ce n'e' gia' uno in volo (due goblin che calano insieme): il secondo
		# colpo arriva pieno e basta - una mano sola, un contrasto solo
		colpo_pieno(nemico, vittima, dati)
		return
	chi_cala = nemico
	su_chi = vittima
	mossa = dati
	var parametri: Dictionary = dati.get("contrasto", {})
	if not scontro.fase_governa_il_tempo():
		# senza schermo: nessuno legge e nessuno guarda, si gioca subito
		contrasto.avvia(parametri, mano_automatica(), false)
		return
	# la riga che la annuncia si legge prima che il riquadro copra il box: e'
	# la stessa attesa della raffica, e per la stessa ragione
	scontro.ferma_il_tempo()
	tempo_fermato = true
	await scontro.svuota_coda()
	if not scontro.in_corso:
		contrasto.rinuncia()
		riprendi()
		return
	contrasto.avvia(parametri)

func riprendi() -> void:
	if tempo_fermato:
		tempo_fermato = false
		scontro.riprendi_il_tempo()

func _finita(esito: Dictionary) -> void:
	riprendi()
	var nemico := chi_cala
	var vittima := su_chi
	var dati := mossa
	chi_cala = {}
	su_chi = {}
	mossa = {}
	if not scontro.in_corso or vittima.is_empty() or int(vittima.get("hp", 0)) <= 0:
		return
	if bool(esito.get("vinto", false)):
		parata(vittima, dati, float(esito.get("quota", 1.0)))
	elif not nemico.is_empty() and int(nemico.get("hp", 0)) > 0:
		colpo_pieno(nemico, vittima, dati)

func parata(vittima: Dictionary, dati: Dictionary, quota: float) -> void:
	# «subisci pochissimi danni a seconda di quanto ci hai messo»: passa lo
	# stesso, ma poco, e tanto meno quanto prima l'hai respinta. Non passa dalla
	# difesa - e' la mano ad averla fermata, non la corazza
	var danno := danno_parato(dati, quota)
	scontro.scrivi("[i]%s[/i]" % String(dati.get("testo_parata", "La respingi.")))
	scontro.colpisci_diretto(vittima, danno)

static func danno_parato(dati: Dictionary, quota: float) -> int:
	var forbice: Array = dati.get("danno_parato", [1, 5])
	var minimo := float(forbice[0]) if forbice.size() > 0 else 1.0
	var massimo := float(forbice[1]) if forbice.size() > 1 else minimo
	return maxi(int(round(lerpf(minimo, massimo, clampf(quota, 0.0, 1.0)))), 1)

func colpo_pieno(nemico: Dictionary, vittima: Dictionary, dati: Dictionary) -> void:
	# «se ti batte passa un colpo pesante»: il suo attacco per la quota della
	# mossa, e da li' la strada di un colpo qualunque (difesa, critico, KO)
	scontro.scrivi("[i]%s[/i]" % String(dati.get("testo_colpo", "La mazza cala.")))
	var valore := maxi(int(round(RegoleCombattimento.attacco_di(nemico)
			* float(dati.get("quota", 2.5)))), 1)
	scontro.attacca(nemico, vittima, valore, 1.0, String(dati.get("elemento", "")))
