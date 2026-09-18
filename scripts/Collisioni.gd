class_name Collisioni
extends RefCounted

# COLLISIONI INFINITE: la raffica di pugni di Veronica, e il primo minigioco.
#
# Bru: «dovrai cliccare sui disegni dei pugni di veronica per ricevere meno
# danno possibile [...] ovviamente saranno molto veloci, deve essere molto
# difficile pararli tutti senno sei invincibile, se non li pari vai ko».
#
# Quella frase contiene tutto il bilanciamento: parare TUTTO deve restare
# possibile e quasi mai riuscire. Se fosse facile il minigioco regalerebbe
# l'immunita' a ogni raffica del gioco; se fosse impossibile non sarebbe un
# minigioco, sarebbe un filmato con un danno scritto.
#
# QUI NON C'E' NESSUN NODO. Entrano dei parametri e un dado, esce un CALENDARIO:
# quando compare ogni pugno, dove, e per quanto resta parabile. Il disegno, il
# clic e l'orologio stanno nel nodo che lo suona (vedi scripts/combattimento/
# QuadranteMinigioco.gd). La separazione non e' pignoleria: un calendario si
# prova a mano, in un millesimo di secondo e senza aprire una finestra, mentre
# di una raffica che vive dentro _process non si puo' provare niente.
#
# La stessa struttura serve a tutti i minigiochi che verranno: cambia chi
# genera il calendario, non chi lo suona.

# Quanto dura la finestra buona rispetto a quella in cui il pugno si vede. Un
# pugno resta a schermo tutta la sua durata, ma si para solo mentre ARRIVA: la
# coda e' il pugno che ti ha gia' preso e sta rientrando. Senza questo si
# parerebbe tutto cliccando in ritardo.
const QUOTA_PARABILE := 0.62

# I pugni non arrivano a distanza regolare: un metronomo si impara in tre
# battute e poi non sbagli piu'. Questo e' quanto puo' scostarsi un pugno dal
# suo posto nel ritmo, in frazione dell'intervallo.
const SBANDAMENTO := 0.35

# QUANTO E' GROSSO UN PUGNO, in frazione del lato corto del quadrante. Sta qui
# e non nel nodo che lo disegna perche' non e' una scelta grafica: e' la misura
# del bersaglio, cioe' meta' della difficolta'. L'altra meta' e' il tempo.
const LATO_PUGNO := 0.40

# Due pugni non compaiono mai uno sopra l'altro: il secondo resterebbe coperto
# dalla mano che ha appena parato il primo. E per non sovrapporsi la distanza
# minima deve essere piu' grande del pugno stesso - era 0.22 contro un pugno da
# 0.40, cioe' meta': si sovrapponevano e il controllo diceva di no.
const DISTANZA_MINIMA := LATO_PUGNO * 1.15
const TENTATIVI_POSIZIONE := 24

static func calendario(quanti: int, intervallo: float, durata: float,
		dado: RandomNumberGenerator, proporzione := 1.0,
		intervallo_finale := -1.0) -> Array[Dictionary]:
	# LA RAFFICA PUO' STRINGERSI ANDANDO AVANTI. Bru: «la velocita' aumenta
	# verso la fine». Con "intervallo_finale" il tempo fra un pugno e l'altro
	# scivola da "intervallo" a quello, in modo lineare: i primi danno il tempo
	# di capire cosa sta succedendo, gli ultimi no. Sotto zero vuol dire "resta
	# costante", che e' come si comportava prima e come si comportano le
	# raffiche degli scontri veri.
	# Il calendario della raffica. Ogni voce:
	#   istante  quando compare, in secondi dall'inizio
	#   durata   per quanto resta a schermo
	#   scade    l'ultimo istante in cui pararlo vale ancora
	#   x, y     dove, in frazione del quadrante (0..1)
	var raffica: Array[Dictionary] = []
	var quando := 0.0
	var totale := maxi(quanti, 0)
	for i in totale:
		# quanto dura QUESTO passo: all'inizio "intervallo", alla fine
		# "intervallo_finale". Con un pugno solo non c'e' nessuna corsa da fare
		var avanzamento := float(i) / float(maxi(totale - 1, 1))
		var passo_adesso := intervallo
		if intervallo_finale >= 0.0:
			passo_adesso = lerpf(intervallo, intervallo_finale, avanzamento)
		var scarto := dado.randf_range(-SBANDAMENTO, SBANDAMENTO) * passo_adesso
		var istante := maxf(quando + scarto, 0.0)
		var punto := posizione_libera(raffica, dado, proporzione)
		raffica.append({
			"indice": i,
			"istante": istante,
			"durata": durata,
			"scade": istante + durata * QUOTA_PARABILE,
			"x": punto.x,
			"y": punto.y,
			"parato": false,
		})
		quando += passo_adesso
	return raffica

static func posizione_libera(raffica: Array[Dictionary],
		dado: RandomNumberGenerator, proporzione := 1.0) -> Vector2:
	# Un punto lontano dall'ultimo pugno piazzato. Si guarda solo l'ultimo e non
	# tutti: con pugni che si accavallano a due a due, pretendere che il
	# quindicesimo stia lontano anche dal primo non lascia piu' posto dove
	# metterlo, e il ciclo finirebbe sempre per arrendersi al tentativo numero
	# ventiquattro - cioe' per piazzare a caso, che e' quello che si voleva
	# evitare.
	#
	# LA DISTANZA SI MISURA IN PIXEL, NON IN FRAZIONI, e serve a tenere la
	# raffica FITTA.
	#
	# Il quadrante e' largo e basso: mille per centosettanta. Misurando in
	# frazioni, chiedere "0.46 di distanza" vuol dire ottanta pixel se ci si
	# sposta in verticale e CINQUECENTO se ci si sposta in orizzontale: la
	# stessa richiesta, sei volte piu' severa per il lungo. I pugni finivano
	# buttati mezzo schermo l'uno dall'altro, e una raffica di pugni sparpagliati
	# non e' una raffica.
	#
	# La proporzione (largo diviso alto) rimette le due direzioni sulla stessa
	# scala: da qualunque parte ci si sposti, "lontano" vuol dire gli stessi
	# pixel. A non farli sovrapporre ci pensa DISTANZA_MINIMA, che e' piu'
	# grande del pugno - sono due mestieri diversi e conviene non confonderli.
	var ultimo := Vector2(-1.0, -1.0)
	if not raffica.is_empty():
		ultimo = Vector2(float(raffica[-1].x), float(raffica[-1].y))
	var scala := Vector2(maxf(proporzione, 0.001), 1.0)
	for _prova in TENTATIVI_POSIZIONE:
		var punto := Vector2(dado.randf_range(0.08, 0.92), dado.randf_range(0.12, 0.88))
		if ultimo.x < 0.0 or (punto * scala).distance_to(ultimo * scala) >= DISTANZA_MINIMA:
			return punto
	return Vector2(dado.randf_range(0.08, 0.92), dado.randf_range(0.12, 0.88))

static func durata_totale(raffica: Array[Dictionary]) -> float:
	# quanto vive la raffica per intero: serve a chi la suona per sapere quando
	# ha finito, e alle prove per non aspettare a occhio
	var fine := 0.0
	for pugno in raffica:
		fine = maxf(fine, float(pugno.istante) + float(pugno.durata))
	return fine

static func para(raffica: Array[Dictionary], indice: int, adesso: float) -> bool:
	# Un clic su un pugno. Vale solo se arriva entro la sua finestra: dopo
	# "scade" il pugno si vede ancora ma ti ha gia' preso.
	if indice < 0 or indice >= raffica.size():
		return false
	var pugno: Dictionary = raffica[indice]
	if bool(pugno.parato):
		return false
	if adesso < float(pugno.istante) or adesso > float(pugno.scade):
		return false
	pugno.parato = true
	return true

static func parati(raffica: Array[Dictionary]) -> int:
	var quanti := 0
	for pugno in raffica:
		if bool(pugno.parato):
			quanti += 1
	return quanti

static func danno(raffica: Array[Dictionary], danno_per_colpo: int) -> int:
	# Ogni pugno non parato picchia. Pararli tutti azzera il danno, ed e'
	# esattamente il "senno sei invincibile" di Bru: e' concesso, ma la finestra
	# e' cosi' stretta che riuscirci e' l'eccezione.
	return maxi(raffica.size() - parati(raffica), 0) * maxi(danno_per_colpo, 0)

static func esito(raffica: Array[Dictionary], danno_per_colpo: int) -> Dictionary:
	return {
		"totali": raffica.size(),
		"parati": parati(raffica),
		"danno": danno(raffica, danno_per_colpo),
		"perfetto": raffica.size() > 0 and parati(raffica) == raffica.size(),
	}
