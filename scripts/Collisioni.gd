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
# dove sta ogni pugno, quando compare, in che ordine si accende. Il disegno, il
# clic e l'orologio stanno in chi lo suona (scripts/combattimento/Minigioco.gd
# e RiquadroRaffica.gd). La separazione non e' pignoleria: un calendario si
# prova a mano, in un millesimo di secondo e senza aprire una finestra, mentre
# di una raffica che vive dentro _process non si puo' provare niente.
#
# La stessa struttura serve a tutti i minigiochi che verranno: cambia chi
# genera il calendario, non chi lo suona.

# COME SI GIOCA ADESSO. Prima era osu!: un pugno al secondo, un cerchio che gli
# si stringeva sopra in due secondi, la parata piena quando si chiudeva e di
# striscio prima. Bru, giocandolo: «quando si chiude quelle linee sono brutte
# da vedere e il fatto che si chiuda e' noioso sembra che ti colpisca piano,
# facciamo che compaiono di botto uno ad uno dodici pugni poi devi cliccare
# quando si illuminano, una volta che ci prendi il pugno o viene parato o lo
# ricevi, cosi' e' piu' dinamico, ordine in cui si illuminano e' randomico».
#
#   1. COMPAIONO   uno alla volta, di botto, ognuno in un posto suo: uno ogni
#                  "comparsa" secondi, in un ordine che non dice niente
#   2. ASPETTANO   un attimo tutti insieme, spenti: li vedi, sai dove sono
#   3. SI ACCENDONO uno alla volta, in un ordine tirato a caso. Quello acceso
#                  ti arriva addosso in "finestra" secondi: se lo clicchi prima
#                  e' PARATO, se no ti PRENDE. Deciso uno, dopo una "pausa" si
#                  accende il successivo - piu' sei svelto, piu' corre la raffica
#
# E IL CLIC DECIDE SEMPRE. Cliccare un pugno spento vuol dire andargli incontro:
# ti prende. E' il «o viene parato o lo ricevi» di Bru preso alla lettera, e
# chiude l'unico modo di barare che il gioco avrebbe - cliccare dappertutto
# sperando di prendere quello giusto quando si accende.
#
# Niente piu' "di striscio": un pugno o lo fermi o ti arriva.

const COMPARSA := 0.12   # fra un pugno che compare e il successivo: di botto, a raffica
const ATTESA := 0.6      # tutti a schermo, spenti, prima che si accenda il primo
const FINESTRA := 1.0    # quanto ci mette il pugno acceso ad arrivarti addosso
const PAUSA := 0.2       # deciso un pugno, quanto prima che si accenda il successivo

# QUANTO E' GROSSO UN PUGNO, in frazione del lato corto del quadrante. Sta qui
# e non nel nodo che lo disegna perche' non e' una scelta grafica: e' la misura
# del bersaglio, cioe' meta' della difficolta'. L'altra meta' e' il tempo.
const LATO_PUGNO := 0.36
# e quanto spazio prende al massimo, in raggi: quando compare si pianta un
# filo piu' grande, e acceso si gonfia arrivandoti addosso (RiquadroRaffica).
# I centri stanno almeno cosi' lontani dal bordo, se no il bordo lo taglia
const INGOMBRO := 1.45
# fra due pugni resta sempre almeno questo spazio, in pugni: dodici insieme a
# schermo non si toccano mai, e il clic non puo' cadere fra due
const RESPIRO := 1.12


static func calendario(quanti: int, dado: RandomNumberGenerator, proporzione := 1.0,
		comparsa := COMPARSA, finestra := FINESTRA, finestra_finale := -1.0) -> Array[Dictionary]:
	# Il calendario della raffica, in ordine di comparsa. Ogni voce:
	#   istante    quando compare, in secondi dall'inizio
	#   turno      in che posizione si accende (0 il primo): mescolato a parte,
	#              quindi chi compare per primo non si accende per primo
	#   finestra   quanto resta acceso prima di prenderti
	#   x, y       dove, in frazione del riquadro (0..1)
	#   accesa_da  quando si e' acceso: -1 finche' e' spento
	#   scade      quando ti prende, se nessuno lo ferma: INF finche' e' spento
	#   esito      "" finche' non e' deciso, poi "parata" / "preso"
	#
	# LA RAFFICA PUO' STRINGERSI ANDANDO AVANTI: con "finestra_finale" il tempo
	# per pararlo scivola da "finestra" a quello, nell'ordine in cui si accendono.
	var totale := maxi(quanti, 0)
	var dove := posti(totale, dado, proporzione)
	var turni := mescolati(totale, dado)
	var raffica: Array[Dictionary] = []
	for i in totale:
		var turno: int = turni[i]
		var sua := finestra
		if finestra_finale >= 0.0:
			sua = lerpf(finestra, finestra_finale, float(turno) / float(maxi(totale - 1, 1)))
		raffica.append({"indice": i, "istante": maxf(comparsa, 0.0) * float(i), "turno": turno,
				"finestra": maxf(sua, 0.05), "x": dove[i].x, "y": dove[i].y,
				"accesa_da": -1.0, "scade": INF, "parato": false, "esito": ""})
	return raffica


static func mescolati(quanti: int, dado: RandomNumberGenerator) -> Array[int]:
	# 0..quanti-1 in un ordine a caso, ma dal dado della raffica: Array.shuffle
	# userebbe il dado di tutto il gioco, e la stessa raffica non tornerebbe uguale
	var ordine: Array[int] = []
	for i in quanti:
		ordine.append(i)
	for i in range(quanti - 1, 0, -1):
		var j := dado.randi_range(0, i)
		var tenuto := ordine[i]
		ordine[i] = ordine[j]
		ordine[j] = tenuto
	return ordine


# --- dove stanno -------------------------------------------------------------

static func posti(quanti: int, dado: RandomNumberGenerator, proporzione := 1.0) -> Array[Vector2]:
	# DODICI A SCHERMO INSIEME, E NESSUNO SOPRA UN ALTRO. Tirarli a caso e
	# scartare quelli che si toccano funzionava con due pugni alla volta; con
	# dodici nel quadrante largo e basso, a caso non c'e' posto. Quindi una
	# griglia a mattoni (le righe dispari sfalsate di mezzo passo, come i
	# mattoni di un muro), con le righe scelte perche' i pugni stiano il piu'
	# lontano possibile; i posti si pescano a caso, e ognuno scarta un poco dal
	# suo - mai tanto da toccare un vicino.
	#
	# Le misure sono in lati corti del piano, cosi' "lontano" vuol dire gli
	# stessi pixel in orizzontale e in verticale. "campo" e' dove possono stare i
	# CENTRI: centro_di (RiquadroRaffica) li tiene INGOMBRO raggi dentro il bordo.
	var largo := maxf(proporzione, 0.001)
	var corto := minf(largo, 1.0)
	var bordi := LATO_PUGNO * INGOMBRO
	var campo := Vector2(largo / corto - bordi, 1.0 / corto - bordi).max(Vector2.ZERO)
	var righe := righe_migliori(quanti, campo)
	var colonne := ceili(float(quanti) / float(maxi(righe, 1)))
	var scarto := maxf(passo_griglia(righe, colonne, campo) - LATO_PUGNO * RESPIRO, 0.0) * 0.5 * 0.85
	var liberi: Array[Vector2] = []
	for riga in righe:
		for colonna in colonne:
			liberi.append(posto_in_griglia(riga, colonna, righe, colonne))
	var ordine := mescolati(liberi.size(), dado)
	var scelti: Array[Vector2] = []
	for i in mini(quanti, liberi.size()):
		var spinta := Vector2(dado.randf_range(-1.0, 1.0), dado.randf_range(-1.0, 1.0)) * scarto
		var su_campo := Vector2(spinta.x / campo.x if campo.x > 0.0 else 0.0, spinta.y / campo.y if campo.y > 0.0 else 0.0)
		scelti.append((liberi[ordine[i]] + su_campo).clamp(Vector2.ZERO, Vector2.ONE))
	return scelti


static func posto_in_griglia(riga: int, colonna: int, righe: int, colonne: int) -> Vector2:
	if righe <= 1:
		return Vector2(0.5 if colonne <= 1 else float(colonna) / float(colonne - 1), 0.5)
	var x := (float(colonna) + 0.5 * float(riga % 2)) / maxf(float(colonne) - 0.5, 0.5)
	return Vector2(clampf(x, 0.0, 1.0), float(riga) / float(righe - 1))


static func passo_griglia(righe: int, colonne: int, campo: Vector2) -> float:
	# la distanza fra i due centri piu' vicini, in lati corti
	if righe <= 1:
		return maxf(campo.x, campo.y) if colonne <= 1 else campo.x / float(colonne - 1)
	var dx := campo.x / maxf(float(colonne) - 0.5, 0.5)
	var dy := campo.y / float(righe - 1)
	var piu_vicini := minf(dx, Vector2(dx * 0.5, dy).length())
	if righe > 2:
		piu_vicini = minf(piu_vicini, dy * 2.0)
	return piu_vicini


static func righe_migliori(quanti: int, campo: Vector2) -> int:
	# quante righe tengono i pugni piu' lontani fra loro: a parita', meno righe
	var scelte := 1
	var migliore := -1.0
	for righe in range(1, maxi(quanti, 1) + 1):
		var passo := passo_griglia(righe, ceili(float(quanti) / float(righe)), campo)
		if passo > migliore + 0.0001:
			migliore = passo
			scelte = righe
	return scelte


# --- quando si accendono -----------------------------------------------------

static func tutti_fuori(raffica: Array[Dictionary]) -> float:
	# quando compare l'ultimo
	var fine := 0.0
	for pugno in raffica:
		fine = maxf(fine, float(pugno.istante))
	return fine


static func accesa(raffica: Array[Dictionary]) -> int:
	# il pugno acceso adesso, -1 se nessuno: se ne accende uno alla volta
	for pugno in raffica:
		if String(pugno.esito) == "" and float(pugno.accesa_da) >= 0.0:
			return int(pugno.indice)
	return -1


static func prossima(raffica: Array[Dictionary]) -> int:
	# il prossimo da accendere: il turno piu' basso fra quelli ancora in piedi
	var scelto := -1
	var primo := 1 << 30
	for pugno in raffica:
		if String(pugno.esito) == "" and float(pugno.accesa_da) < 0.0 and int(pugno.turno) < primo:
			primo = int(pugno.turno)
			scelto = int(pugno.indice)
	return scelto


static func accendi(raffica: Array[Dictionary], indice: int, adesso: float) -> void:
	if indice < 0 or indice >= raffica.size():
		return
	var pugno: Dictionary = raffica[indice]
	pugno.accesa_da = adesso
	pugno.scade = adesso + float(pugno.finestra)


static func scaduti(raffica: Array[Dictionary], adesso: float) -> Array[int]:
	# gli accesi che nessuno ha fermato in tempo: ti hanno preso
	var presi: Array[int] = []
	for pugno in raffica:
		if String(pugno.esito) == "" and float(pugno.accesa_da) >= 0.0 and adesso > float(pugno.scade):
			presi.append(int(pugno.indice))
	return presi


static func giudica(raffica: Array[Dictionary], indice: int, adesso: float) -> String:
	# UN CLIC SU UN PUGNO, e cosa vale:
	#   acceso, in tempo      "parata"
	#   spento                "preso": gli sei andato incontro
	#   "" se non conta: non e' ancora comparso, o e' gia' deciso. Un pugno si
	#   decide UNA volta sola
	if indice < 0 or indice >= raffica.size():
		return ""
	var pugno: Dictionary = raffica[indice]
	if String(pugno.esito) != "" or adesso < float(pugno.istante):
		return ""
	var acceso := float(pugno.accesa_da) >= 0.0 and adesso >= float(pugno.accesa_da) and adesso <= float(pugno.scade)
	pugno.parato = acceso
	pugno.esito = "parata" if acceso else "preso"
	return String(pugno.esito)


static func piu_urgente(raffica: Array[Dictionary], adesso: float) -> int:
	# QUALE PUGNO PARA UN TASTO. Col mouse scegli tu quale colpire; da tastiera
	# no, e adesso la risposta e' facile: QUELLO ACCESO, che e' l'unico che si
	# para. -1 se in questo istante non ce n'e' uno acceso e ancora in tempo.
	var quale := accesa(raffica)
	if quale < 0:
		return -1
	var pugno: Dictionary = raffica[quale]
	return quale if adesso >= float(pugno.accesa_da) and adesso <= float(pugno.scade) else -1


# --- com'e' andata ------------------------------------------------------------

static func parati(raffica: Array[Dictionary]) -> int:
	return conta(raffica, "parata")


static func conta(raffica: Array[Dictionary], quale: String) -> int:
	var quanti := 0
	for pugno in raffica:
		if String(pugno.get("esito", "")) == quale:
			quanti += 1
	return quanti


static func danno(raffica: Array[Dictionary], danno_per_colpo: int) -> int:
	# Ogni pugno che non hai parato picchia per intero. Pararli tutti azzera il
	# danno, ed e' esattamente il «senno sei invincibile» di Bru: e' concesso,
	# ma chiede di prenderli tutti, e in fretta.
	var colpo := maxi(danno_per_colpo, 0)
	return maxi(raffica.size() - parati(raffica), 0) * colpo


static func esito(raffica: Array[Dictionary], danno_per_colpo: int) -> Dictionary:
	var fermati := parati(raffica)
	return {
		"totali": raffica.size(),
		"parati": fermati,
		"danno": danno(raffica, danno_per_colpo),
		"perfetto": raffica.size() > 0 and fermati == raffica.size(),
	}
