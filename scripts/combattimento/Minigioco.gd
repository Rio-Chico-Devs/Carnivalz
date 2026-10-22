class_name MinigiocoCombattimento
extends RefCounted

# IL QUADRANTE. Sta dove sta il box del combattimento, e per un momento prende
# il suo posto.
#
# Bru, sul disegno della schermata: «quel quadrante sotto avrà varie funzioni
# durante il turno del nemico dovrai completare dei minigiochi per salvarti dai
# suoi colpi», e «il suo dialogo appare dove mettiamo i minigiochi e cosi anche
# quelli dei nemici e protagonisti più la narrazione del combattimento».
#
# Cioe': una superficie sola, il pannello in basso a destra, che a turno
# racconta e gioca. Quando finisce lo restituisce.
#
# UNA FACCIA DEL PANNELLO, NON UNO STRATO SOPRA. Fino a ieri il minigioco si
# copiava il rettangolo del box e ci si stendeva sopra, trasparente: i pugni
# atterravano sull'ECG, su Morale e Stress, su MATTANZA e BOND. Bru: «vedo
# apparire cerchi rossi sull'interfaccia di combattimento». Adesso si prende
# il pannello per intero - le altre facce si spengono - e ci disegna dentro un
# riquadro suo (RiquadroRaffica.gd), dall'inizio dell'evento alla fine.
#
# TRE FASI, e il riquadro resta suo per tutte e tre:
#
#   apertura  il titolo e la riga che dice cosa fare. Un clic la salta
#   raffica   i pugni: compaiono di botto uno alla volta, poi si accendono a
#             caso uno alla volta (Collisioni.gd dice come e perche')
#   chiusura  quanti ne hai fermati. Si chiude da sola, e un clic prima
#
# Animare si', sbarrare mai: ne' l'inizio ne' la fine ti tengono fermo.
#
# DA MUTI NON DISEGNA E NON ASPETTA. Il giocatore automatico non ha un mouse:
# gli si dice quanto e' bravo (una quota fra 0 e 1), la raffica si risolve in
# un colpo solo e lo scontro prosegue. Cosi' il simulatore puo' misurare quanto
# vale saper parare senza che nessuno debba cliccare duecentomila volte.

signal finito(esito: Dictionary)

const DISEGNO_PUGNO := "res://art/minigiochi/pugno.png"
const APERTURA := 1.8   # quanto si legge "clicca il pugno quando si accende"
const CHIUSURA := 2.2   # quanto resta il conto, se nessuno clicca prima
const CODA := 0.45      # deciso l'ultimo pugno, quanto resta il suo riscontro
const FERMO := 0.07     # il colpo preso ferma tutto per un attimo: si sente arrivare
const BLOCCO_TASTO := 0.3   # premuto a vuoto, il tasto non para per questo tempo

var muto := false
var plancia: PlanciaCombattimento = null
var riquadro: RiquadroRaffica = null
var impatto: ImpattoCombattimento = null   # il colpo preso fa sbandare lo scontro
var dado := RandomNumberGenerator.new()

var raffica: Array[Dictionary] = []
var fase := ""            # "apertura", "raffica", "chiusura"; "" a riposo
var tempo := 0.0          # l'orologio dei pugni: gira solo durante la raffica
var tempo_fase := 0.0     # quello dell'apertura e della chiusura
var prossima_luce := 0.0  # quando si accende il prossimo pugno, sull'orologio dei pugni
var pausa := Collisioni.PAUSA
var fermo := 0.0          # quanto resta del fermo del colpo preso
var tasto_libero_da := 0.0
var attivo := false
var in_partenza := false   # chiesta, ma il box sta ancora finendo di parlare
var danno_per_colpo := 0
# quante raffiche sono state suonate: le prove contano queste, non i pixel
var suonate := 0

func _init(silenzioso := false) -> void:
	muto = silenzioso

func collega(dove: Control, tabellone: PlanciaCombattimento = null, scossa: ImpattoCombattimento = null) -> void:
	# "dove" e' l'interno del pannello: il riquadro ci si appende e ne prende la
	# misura, come le altre facce. La plancia serve a spegnere le altre facce
	# quando la raffica parte - senza (nelle prove) il riquadro fa da solo.
	plancia = tabellone
	impatto = scossa
	if dove == null or muto:
		return
	riquadro = RiquadroRaffica.new(self)
	riquadro.visible = false
	riquadro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dove.add_child(riquadro)
	# il disegno del pugno si chiede adesso e non al primo pugno: caricarlo nel
	# momento in cui stai mirando e' l'ultimo posto in cui volere uno scatto
	Disegni.texture(DISEGNO_PUGNO)

func avvia(parametri: Dictionary, bravura := -1.0) -> void:
	# parametri: quanti, danno, e facoltativi nome, comparsa, attesa,
	# finestra, finestra_finale, pausa (di serie, quelli di Collisioni)
	#
	# UNA RAFFICA ALLA VOLTA, E CHI L'HA CHIESTA DEVE SAPERE COM'E' FINITA.
	# Chi lancia aspetta il segnale "finito": se ne partisse una seconda sopra
	# la prima, quel segnale per la prima non arriverebbe MAI. La guardia vera
	# e' prenota(), qui sotto; questa e' la rete, e dice forte che e' servita.
	if attivo:
		push_error("Minigioco: una raffica e' stata avviata mentre la precedente era ancora in volo. La prima viene chiusa adesso, se no chi la aspettava resterebbe fermo.")
		concludi()
	in_partenza = false
	tempo = 0.0
	tempo_fase = 0.0
	fermo = 0.0
	tasto_libero_da = 0.0
	danno_per_colpo = int(parametri.get("danno", 0))
	raffica = Collisioni.calendario(int(parametri.get("quanti", 12)), dado,
			riquadro.proporzione() if riquadro != null else 1.0,
			float(parametri.get("comparsa", Collisioni.COMPARSA)),
			float(parametri.get("finestra", Collisioni.FINESTRA)),
			float(parametri.get("finestra_finale", -1.0)))
	pausa = maxf(float(parametri.get("pausa", Collisioni.PAUSA)), 0.0)
	prossima_luce = Collisioni.tutti_fuori(raffica) + maxf(float(parametri.get("attesa", Collisioni.ATTESA)), 0.0)
	suonate += 1
	if muto or riquadro == null:
		risolvi_da_solo(bravura)
		return
	attivo = true
	fase = "apertura"
	if plancia != null:
		plancia.mostra_faccia("minigioco")
	riquadro.visible = true
	riquadro.comincia(String(parametri.get("nome", "Raffica")))

func risolvi_da_solo(bravura: float) -> void:
	# Nessuno sta guardando. "Bravura" e' la quota di pugni che una mano para:
	# sotto zero vuol dire "non ci prova nemmeno", ed e' il caso del giocatore
	# automatico di oggi, che un mouse non ce l'ha.
	if bravura > 0.0:
		for pugno in raffica:
			if dado.randf() < bravura:
				Collisioni.accendi(raffica, int(pugno.indice), float(pugno.istante))
				Collisioni.giudica(raffica, int(pugno.indice), float(pugno.istante))
	attivo = false
	fase = ""
	finito.emit(Collisioni.esito(raffica, danno_per_colpo))

func si_vede(pugno: Dictionary) -> bool:
	# a schermo da quando compare a quando e' deciso, e non un istante di piu':
	# al suo posto resta il riscontro (PARATA, COLPITO)
	return fase == "raffica" and String(pugno.get("esito", "")) == "" and tempo >= float(pugno.istante)

func decisi() -> int:
	# per il contatore in alto: quanti pugni sono gia' parati o andati a segno
	if fase == "chiusura":
		return raffica.size()
	return 0 if fase != "raffica" else raffica.size() - Collisioni.conta(raffica, "")

func colpisci(indice: int) -> void:
	# il clic su un pugno: acceso lo pari, spento non fa niente (Collisioni.giudica)
	if not attivo or fase != "raffica":
		return
	if Collisioni.giudica(raffica, indice, tempo) == "":
		return
	prossima_luce = tempo + pausa
	if riquadro != null:
		riquadro.segna(indice, "parata")
	AudioManager.interfaccia("parata")

func subisci(indice: int) -> void:
	# il pugno ti ha preso: lo si dice una volta sola, nel momento in cui
	# succede. E per un attimo si ferma tutto - il vetro gia' rotto, il pugno
	# ancora li': e' il fermo sul colpo dei picchiaduro, e dice "ti ha preso"
	# prima ancora delle crepe
	if riquadro != null:
		riquadro.segna(indice, "preso")
	if impatto != null:
		impatto.scossa(12.0)   # il colpo preso si sente: lo scontro sbanda forte
	fermo = FERMO
	AudioManager.interfaccia("incrinato")

func para_col_tasto() -> bool:
	# LA RAFFICA SI GIOCA ANCHE SENZA MOUSE: il tasto para il pugno acceso.
	# Premuto a vuoto non fa niente, come il clic su uno spento - ma per un
	# attimo il tasto non para piu', e ogni pressione a vuoto ricomincia
	# l'attimo: se no pestando INVIO senza guardare si parerebbe tutta la
	# raffica. Fuori dalla raffica fa andare avanti (salta l'apertura, chiude
	# il conto).
	#
	# Torna false se il tasto non ha parato niente - cosi' chi chiama sa se
	# l'evento e' stato consumato o deve passare oltre.
	if not attivo:
		return false
	if fase != "raffica":
		salta()
		return true
	var quale := Collisioni.piu_urgente(raffica, tempo)
	if quale < 0 or tempo < tasto_libero_da:
		tasto_libero_da = tempo + BLOCCO_TASTO
		return false
	colpisci(quale)
	return true

func salta() -> void:
	if fase == "apertura":
		fase = "raffica"
	elif fase == "chiusura":
		concludi()

func passa(delta: float) -> void:
	# il minigioco ha un orologio suo: mentre gira, quello dello scontro e' fermo
	if not attivo:
		return
	if fermo > 0.0:
		# il fermo sul colpo: niente avanza, niente si ridisegna
		fermo -= delta
		return
	match fase:
		"apertura":
			passa_apertura(delta)
		"raffica":
			passa_raffica(delta)
		"chiusura":
			passa_chiusura(delta)
	if attivo and riquadro != null:
		riquadro.aggiorna(delta)

func passa_apertura(delta: float) -> void:
	tempo_fase += delta
	if tempo_fase >= APERTURA:
		fase = "raffica"

func passa_raffica(delta: float) -> void:
	var prima := tempo
	tempo += delta
	for pugno in raffica:
		# compare di botto, e si sente
		if float(pugno.istante) >= prima and float(pugno.istante) < tempo:
			AudioManager.interfaccia("pugno")
	segna_i_mancati()
	if Collisioni.accesa(raffica) >= 0 or tempo < prossima_luce:
		return
	var quale := Collisioni.prossima(raffica)
	if quale >= 0:
		# si accende all'istante giusto, non al fotogramma che se ne accorge: la
		# finestra e' la stessa a 30 e a 144 fotogrammi al secondo
		Collisioni.accendi(raffica, quale, prossima_luce)
		AudioManager.interfaccia("acceso")
		return
	if tempo < prossima_luce + CODA:
		return
	fase = "chiusura"
	tempo_fase = 0.0
	if riquadro != null:
		riquadro.chiudi(Collisioni.esito(raffica, danno_per_colpo))

func passa_chiusura(delta: float) -> void:
	tempo_fase += delta
	if tempo_fase >= CHIUSURA:
		concludi()

func segna_i_mancati() -> void:
	# un pugno acceso che nessuno ha fermato in tempo ti ha preso; il prossimo
	# si accende una pausa dopo l'istante in cui e' arrivato
	for indice in Collisioni.scaduti(raffica, tempo):
		var pugno: Dictionary = raffica[indice]
		pugno.esito = "preso"
		prossima_luce = float(pugno.scade) + pausa
		subisci(indice)

func concludi() -> void:
	attivo = false
	fase = ""
	if riquadro != null:
		riquadro.visible = false
	finito.emit(Collisioni.esito(raffica, danno_per_colpo))


static func racconto(esito: Dictionary) -> Dictionary:
	# COME SI RACCONTA UNA RAFFICA FINITA. "parati" e "totali" sono parole di
	# qui: chi conta i pugni sa anche come si dicono.
	# "forte" vuol dire che il messaggio aspetta un click invece di scorrere
	# via: pararli tutti in pieno e' una cosa che merita di essere letta
	var totali := int(esito.get("totali", 0))
	var parati := int(esito.get("parati", 0))
	if totali > 0 and bool(esito.get("perfetto", parati == totali)):
		return {"forte": true, "testo": "[i]Non te ne arriva addosso nemmeno uno.[/i]"}
	return {"forte": false, "testo": "[i]%d colpi su %d ti arrivano addosso.[/i]" % [totali - parati, totali]}


func prenota() -> bool:
	# LA GUARDIA CHE CHIUDE IL BUCO, e sta qui perche' e' una politica di questo
	# modulo - quale raffica vince quando due la chiedono insieme - non un
	# dettaglio di chi la lancia. E' lo stesso motivo per cui Intenzione.gd
	# esiste: nasconde una decisione che cambiera' dopo il primo playtest.
	#
	# Il buco e' l'attesa che chi lancia fa prima di avviare, per lasciar
	# finire la frase "preparati!". Allo stesso passo del tutorial ci arrivano
	# due strade che non si conoscono - il giro dei turni e la via del
	# giocatore - e dentro quell'attesa la seconda entra: nel registro di Bru
	# sono due raffiche a sei millesimi l'una dall'altra.
	#
	# Il guardiano dentro avvia() se ne accorge e chiude la prima, ma e' una
	# rete e basta: chiuderla vuol dire che chi l'aspettava riceve un esito
	# inventato, e il bersaglio nel frattempo e' gia' cambiato - cioe' il danno
	# va addosso a chi non c'entra. Qui invece la seconda non parte proprio.
	#
	# false vuol dire "ce n'e' gia' una": chi la riceve se ne va senza fare
	# niente, che e' esattamente quello che deve fare.
	if attivo or in_partenza:
		return false
	in_partenza = true
	return true


func rinuncia() -> void:
	in_partenza = false
