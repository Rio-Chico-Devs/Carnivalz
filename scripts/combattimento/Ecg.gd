class_name EcgCombattimento
extends RefCounted

# L'ELETTROCARDIOGRAMMA DI UN COMBATTENTE.
#
# Bru: «vogliamo una sorta di ecg che si muova simulando le condizioni dei
# personaggi, se ha tanto stress ci vuole che sia nervoso con ecg irregolare e
# movimentato, la linea è rossa quando ferito gravemente meno del 25% di hp,
# gialla sopra il 25% ma meno del 75% verde sopra il 75%».
#
# Sono due informazioni diverse dette da una riga sola, ed e' il motivo per cui
# la riga vale la pena:
#
#   IL COLORE dice quanta vita resta. Si legge senza leggere - non devi
#   confrontare due numeri, il verde che diventa giallo lo vedi con la coda
#   dell'occhio mentre guardi altrove.
#   IL MOVIMENTO dice lo stress. Una barra non lo saprebbe dire: lo stress non
#   e' una quantita' che scende, e' uno stato in cui sei, e uno stato si
#   racconta col comportamento. Un tracciato calmo e regolare e uno nervoso e
#   irregolare si distinguono a colpo d'occhio anche senza sapere cosa
#   misurano.
#
# QUI NON C'E' NESSUN NODO. Entra il tempo e lo stato di un combattente, esce
# un numero fra -1 e 1. Chi lo disegna sta altrove: cosi' il tracciato si
# misura - quanti battiti al minuto, quanto sono irregolari - invece di doverlo
# guardare e dire "mi sembra nervoso".

# Le soglie sono quelle di Bru, parola per parola: sotto un quarto e' rossa,
# sopra tre quarti e' verde, in mezzo gialla.
const QUOTA_ROSSA := 0.25
const QUOTA_VERDE := 0.75

# Quanto batte un cuore da fermo e quanto quando sei al massimo dello stress.
# Non sono numeri medici: sono i due estremi fra cui il tracciato deve
# CAMBIARE ABBASTANZA da vedersi senza contare i picchi.
const BATTITI_CALMO := 62.0
const BATTITI_IN_PANICO := 150.0

# Di quanto puo' sbandare un battito rispetto al suo posto nel ritmo, a stress
# pieno. E' l'"irregolare" di Bru: non piu' veloce, IMPREVEDIBILE - un cuore
# che accelera e basta suona come uno sforzo, uno che perde il tempo suona come
# paura.
const SBANDAMENTO_MASSIMO := 0.34

# Quanto trema la linea di base quando sei a pezzi: il "movimentato".
const TREMORE_MASSIMO := 0.13

static func quota_stress(stress: int) -> float:
	return clampf(float(stress) / 100.0, 0.0, 1.0)

static func colore_per(quota_hp: float) -> String:
	# ROSSA SOTTO UN QUARTO, VERDE SOPRA TRE QUARTI, GIALLA IN MEZZO.
	#
	# Gli estremi cadono dove li ha messi Bru: "meno del 25%" e' rossa, quindi a
	# un quarto esatto sei gia' gialla; "sopra il 75%" e' verde, quindi a tre
	# quarti esatti sei ancora gialla. Sembra pedanteria e non lo e': il 25%
	# esatto capita di continuo, perche' e' la stessa soglia che il resto del
	# gioco usa per dire "vita bassa".
	if quota_hp < QUOTA_ROSSA:
		return "rosso"
	if quota_hp > QUOTA_VERDE:
		return "verde"
	return "giallo"

static func spessore_per(quota_hp: float) -> float:
	# IL COLORE NON PUO' ESSERE L'UNICA COSA CHE LO DICE.
	#
	# Otto o dieci maschi su cento non distinguono bene il rosso dal verde, e un
	# segnale costruito su "verde = tutto bene / rosso = stai per morire" per
	# loro non esiste. Misurato: fra il verde e il giallo di questa schermata
	# passano 0.086 di luminosita' - cioe' senza il colore sono lo stesso grigio.
	#
	# Quindi la linea dice la stessa cosa DUE volte: col colore e con lo
	# spessore. Piu' sei messo male, piu' e' grossa - e una linea grossa si vede
	# anche in bianco e nero, anche con la coda dell'occhio, anche su uno schermo
	# sbiadito. Non toglie niente a chi i colori li vede: li' dove il colore
	# funziona, le due cose si sommano.
	#
	# Vale la stessa regola delle icone di stato, che sono simboli diversi e non
	# tre cerchi di tre colori.
	if quota_hp <= 0.0:
		return 1.0
	if quota_hp < QUOTA_ROSSA:
		return 3.4
	if quota_hp > QUOTA_VERDE:
		return 1.6
	return 2.4

static func battiti_al_minuto(stress: int) -> float:
	return lerpf(BATTITI_CALMO, BATTITI_IN_PANICO, quota_stress(stress))

static func intervallo(stress: int) -> float:
	# quanti secondi fra un battito e il successivo, in media
	return 60.0 / maxf(battiti_al_minuto(stress), 1.0)

static func istanti_dei_battiti(durata: float, stress: int,
		dado: RandomNumberGenerator) -> Array[float]:
	# QUANDO BATTE. Da fermo e' un metronomo; sotto stress ogni battito arriva
	# un po' prima o un po' dopo di dove lo aspettavi, ed e' proprio quella
	# attesa tradita che si legge come nervosismo.
	var quando: Array[float] = []
	var passo := intervallo(stress)
	var sbando := SBANDAMENTO_MASSIMO * quota_stress(stress)
	var adesso := 0.0
	while adesso < durata:
		var scarto := dado.randf_range(-sbando, sbando) * passo
		quando.append(maxf(adesso + scarto, 0.0))
		adesso += passo
	quando.sort()
	return quando

static func onda(distanza_dal_battito: float, passo: float) -> float:
	# LA FORMA DI UN BATTITO. Non e' un picco e basta: un picco solo sembra un
	# segnale digitale. Qui c'e' la gobbetta che viene prima, la punta, il
	# contraccolpo sotto e la gobba lunga che chiude - quel tanto che basta
	# perche' a occhio si legga "cuore" e non "onda quadra".
	var t := distanza_dal_battito / maxf(passo, 0.001)
	if t < 0.0 or t > 1.0:
		return 0.0
	if t < 0.12:                      # P: il preavviso
		return 0.16 * sin(t / 0.12 * PI)
	if t < 0.18:                      # tratto piatto
		return 0.0
	if t < 0.23:                      # Q: il tuffo prima della punta
		return -0.22 * sin((t - 0.18) / 0.05 * PI)
	if t < 0.29:                      # R: la punta
		return sin((t - 0.23) / 0.06 * PI)
	if t < 0.36:                      # S: il contraccolpo
		return -0.34 * sin((t - 0.29) / 0.07 * PI)
	if t < 0.50:
		return 0.0
	if t < 0.78:                      # T: la gobba lunga
		return 0.26 * sin((t - 0.50) / 0.28 * PI)
	return 0.0

static func traccia(durata: float, campioni: int, quota_hp: float, stress: int,
		dado: RandomNumberGenerator) -> PackedFloat32Array:
	# Il tracciato intero, da -1 a 1. Chi lo disegna ci mette sopra solo la
	# scala e il colore.
	var punti := PackedFloat32Array()
	if campioni <= 0 or durata <= 0.0:
		return punti
	# CHI E' A TERRA FA UNA RIGA DRITTA. Non e' una scelta di stile: e' l'unica
	# cosa che un elettrocardiogramma sa dire di qualcuno che non c'e' piu', e
	# dirla con un tracciato che balla sarebbe dire una bugia in una schermata
	# dove tutto il resto e' vero.
	if quota_hp <= 0.0:
		punti.resize(campioni)
		return punti
	var battiti := istanti_dei_battiti(durata, stress, dado)
	var passo := intervallo(stress)
	var tremore := TREMORE_MASSIMO * quota_stress(stress)
	for i in campioni:
		var quando := durata * float(i) / float(campioni - 1 if campioni > 1 else 1)
		var valore := 0.0
		for istante in battiti:
			if quando < istante:
				break
			valore += onda(quando - istante, passo)
		if tremore > 0.0:
			valore += dado.randf_range(-tremore, tremore)
		punti.append(clampf(valore, -1.0, 1.0))
	return punti

static func picchi(punti: PackedFloat32Array, soglia := 0.5) -> int:
	# QUANTI BATTITI SI VEDONO DAVVERO nel tracciato. Serve alle prove, che
	# devono poter dire "sotto stress ne passano di piu'" contandoli, invece di
	# fidarsi del numero che gli abbiamo dato in ingresso.
	#
	# CONTA CON L'ISTERESI: un battito nuovo si conta solo dopo che la linea e'
	# ridiscesa BEN sotto la soglia, non appena la tocca. Senza, il tremore di
	# chi e' nel panico faceva ballare un campione attorno alla soglia e ogni
	# oscillazione veniva contata come un battito in piu': il contatore diceva
	# "cuore piu' veloce" anche quando il cuore andava identico, e una prova che
	# si fidava di lui restava verde pure spegnendo l'accelerazione.
	var riarmo := soglia * 0.4
	var quanti := 0
	var dentro := false
	for valore in punti:
		if valore >= soglia and not dentro:
			quanti += 1
			dentro = true
		elif valore < riarmo:
			dentro = false
	return quanti
