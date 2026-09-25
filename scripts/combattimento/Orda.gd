class_name OrdaDiNemici
extends RefCounted

# UN'ORDA E' UN NEMICO SOLO CHE NE VALE TANTI.
#
# Bru: «non abbiamo piu' il nemico zombi ma orda di zombi che puo' presentarsi
# in varie quantita', da 3 a 10 fino a rarissimamente 30 [...] e' un singolo
# disegno, ogni tot hp che perde esce un dialogo: l'orda si indebolisce».
#
# Quindi NON sono trenta combattenti in fila: e' una creatura sola, un disegno
# solo, una barra sola - e un numero di componenti che cala mentre la picchi.
# E' anche l'unico modo di stare dentro l'altro disegno di Bru, quello della
# schermata, dove nel box grande «non ci saranno piu' di un nemico».
#
# Il conto dei componenti non scende di uno alla volta: scende a scalini
# dichiarati. Per l'orda da trenta Bru li ha scritti lui:
#
#     30 - 22 - 17 - 11 - 5 - 3 - 1 - 0        (lo zero e' il KO dell'orda)
#
# Ogni scalino e' una battuta: «l'orda si indebolisce».
#
# DUE NUMERI CHE SI TENGONO. La vita dell'orda cresce coi componenti, e un
# colpo ad area fa danno per quanti componenti ha davanti. Messi insieme, un
# colpo ad area toglie sempre LA STESSA FRAZIONE di orda, che sia da tre o da
# trenta - mentre un colpo singolo, su un'orda grossa, e' una puntura di
# spillo. E' esattamente quello che Bru voleva: «l'attacco ad area e' debole
# sul singolo ma forte su piu' nemici cosi' diamo un senso ed evitiamo lo spam
# di attacchi ad area».

# --- gli scalini ---------------------------------------------------------

const SCALINI_DICHIARATI := {
	# L'UNICA SCRITTA A MANO E' QUELLA DA TRENTA: e' di Bru, parola per parola.
	# Le altre si ricavano (vedi scalini_per), ma questa resta com'e' - e se un
	# giorno ne detta un'altra, si aggiunge qui e vince su tutto.
	30: [30, 22, 17, 11, 5, 3, 1, 0],
}

static func scalini_per(quanti: int) -> Array[int]:
	# QUANTE FASI DI INDEBOLIMENTO. Bru: «a seconda di quanti componenti ha
	# l'orda ci saranno piu' fasi di indebolimento» - piu' e' grossa, piu' volte
	# la senti cedere. Un'orda da tre ha due scalini, quella da trenta ne ha
	# sette.
	#
	# Il conto: si scende dimezzando quello che resta, con un pavimento a uno,
	# e senza mai fare due scalini uguali. Su trenta darebbe una scala diversa
	# da quella di Bru, ed e' giusto cosi': la sua vince (SCALINI_DICHIARATI).
	var quanti_veri := maxi(quanti, 1)
	if SCALINI_DICHIARATI.has(quanti_veri):
		var dichiarati: Array[int] = []
		for passo in SCALINI_DICHIARATI[quanti_veri]:
			dichiarati.append(int(passo))
		return dichiarati
	var scala: Array[int] = [quanti_veri]
	var resta := quanti_veri
	while resta > 1:
		var prossimo := int(floor(float(resta) * 0.66))
		if prossimo >= resta:
			prossimo = resta - 1
		resta = maxi(prossimo, 1)
		scala.append(resta)
	scala.append(0)
	return scala

static func componenti_a(quota_hp: float, iniziali: int) -> int:
	# QUANTI NE RESTANO IN PIEDI ADESSO. La vita dell'orda e' un solo mucchio:
	# quanto ne hai tolto dice quanti ne hai stesi, e lo scalino piu' vicino
	# sotto quel numero e' quello che si legge sulla fascia.
	if iniziali <= 0:
		return 0
	if quota_hp <= 0.0:
		return 0
	# UNA FERITA NON E' UNA RANA STESA. Si contava floor: con quattro rane e
	# mezza di vita l'orda risultava da quattro - e peggio, siccome gli scalini
	# da cinque sono 5-3-1, sotto il 60% restava «l'ultima rana» per piu' di
	# meta' scontro, con un solo colpo al 50% a turno. E' il «sembra che non
	# ricevi danno» di Bru. Una sta in piedi finche' non ha perso tutta la sua
	# parte: si conta per eccesso (il millesimo toglie l'errore dei float, per
	# cui 0,8 x 5 fa 4,0000000001).
	#
	# E FINCHE' L'ORDA E' IN PIEDI, QUALCUNO C'E': almeno uno. Il conto andava a
	# zero con l'orda ancora viva, e un'orda da zero annunciava l'assalto e poi
	# non attaccava, non si indeboliva, e l'onda psichica contava «su 0». Bru:
	# «quando rimane 1 componente sembra che i dialoghi impazziscano». Lo zero
	# e' il KO, e il KO lo decide la vita
	var vivi := maxf(ceilf(float(iniziali) * clampf(quota_hp, 0.0, 1.0) - 0.001), 1.0)
	for passo in scalini_per(iniziali):
		if passo > 0 and float(passo) <= vivi:
			return passo
	return 1   # non ci si arriva: ogni scala scende fino a uno

static func si_indebolisce(prima: int, adesso: int) -> bool:
	# uno scalino sceso, quindi una battuta. Non si annuncia il KO qui: quello
	# lo racconta gia' il combattimento come per qualunque altra creatura
	return adesso < prima and adesso > 0

static func testo_per(mossa: Dictionary, chiave: String, componenti: int) -> String:
	# CON UNA SOLA, AL SINGOLARE. «Le rane ti saltano addosso da ogni parte!»
	# detto dall'ultima rana rimasta e' una bugia che si sente: una mossa
	# d'orda puo' avere la sua riga "_uno" (testo_uno, testo_annuncio_uno), e
	# quando ne resta una vale quella
	if componenti == 1 and mossa.has(chiave + "_uno"):
		return String(mossa[chiave + "_uno"])
	return String(mossa.get(chiave, ""))

# --- quanti ne arrivano addosso -----------------------------------------

static func colpi_a_segno(componenti: int, dado: RandomNumberGenerator,
		probabilita_mancare: float) -> int:
	# «usano un attacco che colpisce x il numero di componenti dell'orda, con un
	# 50% di prob di fallire a colpo» (Bru).
	#
	# Si tira per OGNI componente, non una volta sola moltiplicando: e' la
	# differenza fra un'orda che qualche volta ti sfiora e una che fa sempre
	# esattamente meta' danno. Con trenta addosso la media e' quindici, ma la
	# coda esiste - ed e' quella che fa paura.
	if componenti <= 0 or dado == null:
		return 0
	var quota := clampf(probabilita_mancare, 0.0, 1.0)
	var arrivati := 0
	for i in componenti:
		if dado.randf() >= quota:
			arrivati += 1
	return arrivati

# --- i due numeri che si tengono ----------------------------------------

static func vita_per(hp_di_uno: int, componenti: int) -> int:
	# la vita dell'orda e' quella di uno per quanti sono: e' il numero che
	# rende un colpo singolo una puntura di spillo su un'orda grossa
	return maxi(hp_di_uno, 1) * maxi(componenti, 1)

static func moltiplicatore_area(frazione: float, componenti: int) -> float:
	# UN COLPO AD AREA VALE PER QUANTI NE HA DAVANTI.
	#
	# Su un nemico solo vale la frazione e basta - cioe' MENO di un colpo
	# normale, ed e' il freno allo spam: chi lo usa sempre picchia meno. Su
	# un'orda vale la frazione per i componenti, e diventa l'unica risposta
	# sensata.
	#
	#   nemico solo, frazione 0.6  ->  0.6x   (peggio di un colpo normale)
	#   orda da 3                  ->  1.8x
	#   orda da 10                 ->  6.0x
	#   orda da 30                 -> 18.0x
	return maxf(frazione, 0.0) * float(maxi(componenti, 1))
