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
# clic e l'orologio stanno in chi lo suona (scripts/combattimento/Minigioco.gd
# e RiquadroRaffica.gd). La separazione non e' pignoleria: un calendario si
# prova a mano, in un millesimo di secondo e senza aprire una finestra, mentre
# di una raffica che vive dentro _process non si puo' provare niente.
#
# La stessa struttura serve a tutti i minigiochi che verranno: cambia chi
# genera il calendario, non chi lo suona.

# LEGGERE E PARARE SONO DUE NUMERI DIVERSI, e fino a ieri erano uno.
#
# Il pugno si parava per l'80% del tempo in cui si vedeva: allungare il tempo
# per leggerlo voleva dire allungare anche quello per pararlo, e l'unico modo
# di renderlo difficile era farlo sparire in fretta. Bru, provando: «i pugni
# scompaiono troppo velocemente». Quindi o leggibile e facile, o difficile e
# illeggibile.
#
# osu! ha risolto esattamente questo quasi vent'anni fa, e lo tiene in due
# impostazioni separate (dalla loro wiki, Beatmap/Approach_rate e
# Beatmap/Overall_difficulty, e dal sorgente, OsuHitObject.cs e
# OsuHitWindows.cs):
#
#   APPROACH RATE  quanto si vede un cerchio prima del momento giusto: da 1800
#                  ms (AR0) a 450 ms (AR10). E' il tempo per LEGGERE.
#   OVERALL        quanto puoi sbagliare quel momento: la finestra piu' larga
#   DIFFICULTY     e' +/-200 ms a OD0, la piu' stretta +/-20 ms a OD10. E' il
#                  tempo per PARARE.
#
# E fra i due c'e' il cerchio di avvicinamento, che parte a quattro volte il
# bersaglio e ci si stringe sopra in esattamente il tempo di lettura: quando
# si chiude, e' il momento. Non devi indovinarlo, lo vedi arrivare.
#
# Qui adesso e' uguale. Bru: «ogni pugno deve rimanere visibile per 2 secondi,
# e ne deve apparire un altro ogni secondo» - due secondi e' piu' di AR0, cioe'
# piu' leggibile di qualunque mappa di osu!. E la difficolta' non sta piu'
# nella fretta: sta nel prenderlo QUANDO ARRIVA.
#
#   prima della finestra   lo fermi, ma di striscio: meta' danno
#   dentro la finestra     parata piena: zero danno
#   dopo                   ti ha preso
#
# Cosi' cliccare un pugno fa SEMPRE qualcosa - non esiste il clic che non
# succede niente - e pararli tutti senza un graffio resta difficile, che e' il
# «senno sei invincibile» di Bru.
#
# LA FINESTRA NON E' SIMMETRICA, e il perche' sta nella documentazione di
# Godot (Sync the gameplay with audio and music): «Graphics APIs display two
# or three frames late». Quello che vedi e' gia' vecchio di 33-50 ms, quindi
# chi preme quando VEDE il cerchio chiudersi preme sempre un po' tardi.
# Dopo l'impatto si concede quel tanto, non di piu'.
const FINESTRA_PRIMA := 0.20   # il "meh" di OD0, la finestra piu' larga di osu!
const FINESTRA_DOPO := 0.12    # due-tre fotogrammi di schermo, piu' uno di input

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
		intervallo_finale := -1.0, sbandamento := 0.0) -> Array[Dictionary]:
	# Il calendario della raffica. Ogni voce:
	#   istante   quando compare, in secondi dall'inizio
	#   durata    quanto ci mette ad arrivare: il cerchio si chiude in questo tempo
	#   impatto   quando arriva, cioe' istante + durata
	#   piena_da  da quando la parata e' piena (impatto - FINESTRA_PRIMA)
	#   scade     l'ultimo istante in cui fermarlo vale ancora
	#   x, y      dove, in frazione del riquadro (0..1)
	#   esito     "" finche' non e' giudicato, poi "piena" / "striscio"
	#
	# UN PUGNO OGNI "intervallo", E BASTA. Prima i pugni sbandavano sempre del
	# 35% dal loro posto, perche' «un metronomo si impara in tre battute». Ma
	# Bru adesso chiede il metronomo: «ne deve apparire un altro ogni secondo»
	# - e ha ragione, col cerchio di avvicinamento il ritmo non si deve
	# indovinare, si vede. Lo sbandamento resta, ma e' un parametro della
	# raffica: chi lo vuole lo chiede, di serie e' zero.
	#
	# LA RAFFICA PUO' STRINGERSI ANDANDO AVANTI: con "intervallo_finale" il
	# tempo fra un pugno e l'altro scivola da "intervallo" a quello.
	var raffica: Array[Dictionary] = []
	var quando := 0.0
	var totale := maxi(quanti, 0)
	for i in totale:
		var avanzamento := float(i) / float(maxi(totale - 1, 1))
		var passo_adesso := intervallo
		if intervallo_finale >= 0.0:
			passo_adesso = lerpf(intervallo, intervallo_finale, avanzamento)
		var scarto := dado.randf_range(-sbandamento, sbandamento) * passo_adesso
		var istante := maxf(quando + scarto, 0.0)
		var punto := posizione_libera(raffica, dado, proporzione)
		var pugno := {"indice": i, "istante": istante, "durata": durata,
				"x": punto.x, "y": punto.y, "parato": false, "esito": ""}
		raffica.append(pugno)
		quando += passo_adesso
	imposta_finestre(raffica, FINESTRA_PRIMA, FINESTRA_DOPO)
	return raffica

static func imposta_finestre(raffica: Array[Dictionary], prima: float, dopo: float) -> void:
	# le finestre si scrivono dentro ogni pugno, non si rileggono dalle costanti
	# al momento del clic: cosi' una raffica di un boss puo' chiederle piu'
	# strette dai dati, e chi giudica non deve sapere chi l'ha lanciata
	for pugno in raffica:
		var impatto := float(pugno.istante) + float(pugno.durata)
		pugno["impatto"] = impatto
		pugno["piena_da"] = impatto - maxf(prima, 0.0)
		pugno["scade"] = impatto + maxf(dopo, 0.0)

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
	# quanto vive la raffica per intero: fino all'ultima finestra che si chiude
	var fine := 0.0
	for pugno in raffica:
		fine = maxf(fine, float(pugno.get("scade", float(pugno.istante) + float(pugno.durata))))
	return fine

static func giudica(raffica: Array[Dictionary], indice: int, adesso: float) -> String:
	# UN CLIC SU UN PUGNO, e cosa vale. "" vuol dire che non conta: non e'
	# ancora comparso, ti ha gia' preso, o e' gia' stato giudicato. Un pugno si
	# giudica UNA volta sola - e' la regola che rende inutile cliccare a
	# ripetizione sperando di cadere nella finestra.
	if indice < 0 or indice >= raffica.size():
		return ""
	var pugno: Dictionary = raffica[indice]
	if bool(pugno.parato):
		return ""
	if adesso < float(pugno.istante) or adesso > float(pugno.scade):
		return ""
	var esito := "piena" if adesso >= float(pugno.get("piena_da", pugno.istante)) else "striscio"
	pugno.parato = true
	pugno.esito = esito
	return esito

static func para(raffica: Array[Dictionary], indice: int, adesso: float) -> bool:
	# fermato, in un modo o nell'altro
	return giudica(raffica, indice, adesso) != ""

static func piu_urgente(raffica: Array[Dictionary], adesso: float) -> int:
	# QUALE PUGNO PARA UN TASTO. Col mouse scegli tu quale colpire; da tastiera
	# no, quindi bisogna decidere per conto del giocatore - e l'unica scelta che
	# non lo tradisce e' QUELLO CHE STA PER SCADERE. E' quello che un giocatore
	# col mouse punterebbe: gli altri hanno ancora tempo.
	#
	# Torna -1 se in questo istante non c'e' nessun pugno parabile: un tasto
	# premuto a vuoto non deve prendere il pugno sbagliato.
	var scelto := -1
	var scadenza := INF
	for i in raffica.size():
		var pugno: Dictionary = raffica[i]
		if bool(pugno.parato):
			continue
		if adesso < float(pugno.istante) or adesso > float(pugno.scade):
			continue
		if float(pugno.scade) < scadenza:
			scadenza = float(pugno.scade)
			scelto = i
	return scelto

static func parati(raffica: Array[Dictionary]) -> int:
	# fermati, in pieno o di striscio: quelli che NON ti sono arrivati addosso
	var quanti := 0
	for pugno in raffica:
		if bool(pugno.parato):
			quanti += 1
	return quanti

static func conta(raffica: Array[Dictionary], esito: String) -> int:
	var quanti := 0
	for pugno in raffica:
		if String(pugno.get("esito", "")) == esito:
			quanti += 1
	return quanti

static func danno(raffica: Array[Dictionary], danno_per_colpo: int) -> int:
	# Ogni pugno che passa picchia per intero, ogni pugno fermato di striscio
	# per meta' (arrotondata per eccesso: di striscio fa male lo stesso).
	# Pararli tutti in pieno azzera il danno, ed e' esattamente il «senno sei
	# invincibile» di Bru: e' concesso, ma chiede di prenderli tutti quando
	# arrivano, non quando compaiono.
	var colpo := maxi(danno_per_colpo, 0)
	var passati := maxi(raffica.size() - parati(raffica), 0)
	return passati * colpo + conta(raffica, "striscio") * int(ceil(colpo / 2.0))

static func esito(raffica: Array[Dictionary], danno_per_colpo: int) -> Dictionary:
	var piene := conta(raffica, "piena")
	return {
		"totali": raffica.size(),
		"parati": parati(raffica),
		"piene": piene,
		"striscio": conta(raffica, "striscio"),
		"danno": danno(raffica, danno_per_colpo),
		"perfetto": raffica.size() > 0 and piene == raffica.size(),
	}
