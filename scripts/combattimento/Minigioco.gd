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
#   raffica   i pugni: uno ogni "intervallo", ognuno visibile per "durata"
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
const APERTURA := 1.8   # quanto si legge "clicca quando il cerchio si chiude"
const CHIUSURA := 2.2   # quanto resta il conto, se nessuno clicca prima

var muto := false
var plancia: PlanciaCombattimento = null
var riquadro: RiquadroRaffica = null
var dado := RandomNumberGenerator.new()

var raffica: Array[Dictionary] = []
var fase := ""            # "apertura", "raffica", "chiusura"; "" a riposo
var tempo := 0.0          # l'orologio dei pugni: gira solo durante la raffica
var tempo_fase := 0.0     # quello dell'apertura e della chiusura
var attivo := false
var in_partenza := false   # chiesta, ma il box sta ancora finendo di parlare
var danno_per_colpo := 0
# quante raffiche sono state suonate: le prove contano queste, non i pixel
var suonate := 0

func _init(silenzioso := false) -> void:
	muto = silenzioso

func collega(dove: Control, tabellone: PlanciaCombattimento = null) -> void:
	# "dove" e' l'interno del pannello: il riquadro ci si appende e ne prende la
	# misura, come le altre facce. La plancia serve a spegnere le altre facce
	# quando la raffica parte - senza (nelle prove) il riquadro fa da solo.
	plancia = tabellone
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
	# parametri: quanti, intervallo, durata, danno, e facoltativi nome,
	# intervallo_finale, sbandamento, finestra_prima, finestra_dopo
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
	danno_per_colpo = int(parametri.get("danno", 0))
	# di serie sono i tempi di Bru: «ogni pugno deve rimanere visibile per 2
	# secondi, e ne deve apparire un altro ogni secondo»
	raffica = Collisioni.calendario(
			int(parametri.get("quanti", 10)),
			float(parametri.get("intervallo", 1.0)),
			float(parametri.get("durata", 2.0)),
			dado, riquadro.proporzione() if riquadro != null else 1.0,
			float(parametri.get("intervallo_finale", -1.0)),
			float(parametri.get("sbandamento", 0.0)))
	Collisioni.imposta_finestre(raffica,
			float(parametri.get("finestra_prima", Collisioni.FINESTRA_PRIMA)),
			float(parametri.get("finestra_dopo", Collisioni.FINESTRA_DOPO)))
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
	# Nessuno sta guardando. "Bravura" e' la quota di pugni che una mano para in
	# pieno: sotto zero vuol dire "non ci prova nemmeno", ed e' il caso del
	# giocatore automatico di oggi, che un mouse non ce l'ha.
	if bravura > 0.0:
		for pugno in raffica:
			if dado.randf() < bravura:
				Collisioni.giudica(raffica, int(pugno.indice), float(pugno.impatto))
	attivo = false
	fase = ""
	finito.emit(Collisioni.esito(raffica, danno_per_colpo))

func si_vede(pugno: Dictionary) -> bool:
	# a schermo da quando compare a quando la sua finestra si chiude, e non un
	# istante di piu': un pugno gia' giudicato sparisce, e al suo posto resta
	# il riscontro (PARATA, DI STRISCIO, COLPITO)
	return fase == "raffica" and String(pugno.get("esito", "")) == "" \
			and tempo >= float(pugno.istante) and tempo <= float(pugno.scade)

func arrivati() -> int:
	# per il contatore in alto: quanti pugni sono gia' comparsi
	if fase == "chiusura":
		return raffica.size()
	if fase != "raffica":
		return 0
	var quanti := 0
	for pugno in raffica:
		if tempo >= float(pugno.istante):
			quanti += 1
	return quanti

func colpisci(indice: int) -> void:
	if not attivo or fase != "raffica":
		return
	var esito := Collisioni.giudica(raffica, indice, tempo)
	if esito == "":
		return
	if riquadro != null:
		riquadro.segna(indice, esito)
	AudioManager.interfaccia("parata")

func para_col_tasto() -> bool:
	# LA RAFFICA SI GIOCA ANCHE SENZA MOUSE: il tasto para il pugno che sta per
	# arrivare, con le stesse finestre del clic. Fuori dalla raffica fa andare
	# avanti (salta l'apertura, chiude il conto).
	#
	# Torna false se il tasto e' stato premuto a vuoto - cosi' chi chiama sa se
	# l'evento e' stato consumato o deve passare oltre.
	if not attivo:
		return false
	if fase != "raffica":
		salta()
		return true
	var quale := Collisioni.piu_urgente(raffica, tempo)
	if quale < 0:
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
	tempo += delta
	segna_i_mancati()
	if tempo < Collisioni.durata_totale(raffica):
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
	# un pugno la cui finestra si e' chiusa senza che nessuno lo fermasse ti ha
	# preso: lo si dice una volta sola, nel momento in cui succede
	for pugno in raffica:
		if String(pugno.get("esito", "")) != "" or tempo <= float(pugno.scade):
			continue
		pugno.esito = "preso"
		if riquadro != null:
			riquadro.segna(int(pugno.indice), "preso")
		AudioManager.interfaccia("colpo")

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
	var striscio := int(esito.get("striscio", 0))
	if totali > 0 and bool(esito.get("perfetto", parati == totali and striscio == 0)):
		return {"forte": true, "testo": "[i]Non te ne arriva addosso nemmeno uno.[/i]"}
	var testo := "%d colpi su %d ti arrivano addosso" % [totali - parati, totali]
	if striscio > 0:
		testo += ", e %d li fermi solo di striscio" % striscio
	return {"forte": false, "testo": "[i]%s.[/i]" % testo}


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
