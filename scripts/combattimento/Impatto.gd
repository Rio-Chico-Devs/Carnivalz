class_name ImpattoCombattimento
extends RefCounted

# Quello che il corpo sente quando un colpo arriva.
#
# Fino a ieri un colpo era: un numero che sale dalla scheda di chi lo prende, un
# lampo di colore su quella scheda, e la barra della vita che scende. Tutto
# corretto, tutto leggibile, e tutto INFORMAZIONE. Mancava la parte che non si
# legge: il mondo che si ferma per un istante, lo schermo che si sposta, chi
# colpisce che si sporge in avanti invece di restare immobile mentre qualcun
# altro perde la vita.
#
# E' la differenza fra guardare un tabellone e prendere uno schiaffo. Tre cose,
# e sono le tre che ogni studio sul "game feel" mette in cima:
#
#   il FERMO      -> il tempo rallenta per un decimo di secondo sul colpo
#                    grosso. E' il trucco piu' vecchio e piu' forte: non
#                    aggiunge niente a schermo, e fa sembrare che il colpo abbia
#                    incontrato qualcosa di solido.
#   la SCOSSA     -> l'inquadratura sbanda. Quanto, lo decide il danno rispetto
#                    alla vita massima di chi lo prende: cosi' non si scuote per
#                    un graffio, e quando si scuote vuol dire qualcosa.
#   lo SCATTO     -> chi colpisce si sporge verso chi sta colpendo e torna
#                    indietro. Prima nel campo si muoveva SOLO chi incassava, e
#                    in una fila di sei si capiva chi era stato colpito ma non
#                    chi aveva colpito. Adesso il gesto ha una direzione.
#
# COME E' FATTO QUESTO FILE, e perche' conta.
#
# La parte che DECIDE (quanto scuotere, quanto fermare, se fermare) sono
# funzioni statiche pure: prendono numeri, restituiscono numeri, non toccano un
# solo nodo. Sono quelle che le prove possono misurare, e infatti le misurano.
# La parte che TOCCA i nodi sotto e' volutamente sottile: tween e basta, niente
# decisioni. Un effetto che non si puo' provare e' un effetto che si rompe
# durante una modifica e nessuno se ne accorge fino a quando non ci gioca
# qualcuno.
#
# MODALITA' MUTA. Come Voce, Campo e Menu: con "muta" acceso qui non succede
# assolutamente niente. Non e' un dettaglio di cortesia - il giocatore
# automatico gioca migliaia di scontri, e se toccasse Engine.time_scale anche
# una sola volta rallenterebbe l'intera esecuzione delle prove.

# Il fermo immagine non porta il tempo a zero. Uno stop totale in un
# combattimento in tempo reale - dove le barre si ricaricano da sole - si legge
# come "il gioco si e' piantato", non come "il colpo ha fatto male".
const SCALA_FERMO := 0.12
const FERMO_MASSIMO := 0.16

# sotto questa severita' non succede niente: un colpo che toglie un centesimo
# della vita non deve fermare il mondo, o il mondo si ferma in continuazione e
# il fermo smette di voler dire qualcosa
const SEVERITA_MINIMA_FERMO := 0.12
const SEVERITA_MINIMA_SCOSSA := 0.08

# Un colpo che toglie QUESTA quota della vita massima e' gia' il massimo che si
# possa sentire. Non serve arrivare al 100%: un colpo da un terzo della vita e'
# gia' un disastro, e se la scala arrivasse a 1.0 tutti i colpi veri starebbero
# schiacciati nella parte bassa e non si distinguerebbero fra loro.
const DANNO_PIENO := 0.35

var albero: SceneTree
var nodo_scosso: CanvasItem     # cosa sbanda: il corpo della schermata, non lo sfondo
var muta := false

var base_scossa := Vector2.ZERO
var ho_la_base := false
var tween_scossa: Tween
var fermo_in_corso := false

func _init(albero_scena: SceneTree, silenzioso := false) -> void:
	albero = albero_scena
	muta = silenzioso

func collega(corpo: CanvasItem) -> void:
	nodo_scosso = corpo

# --- la parte che decide: numeri dentro, numeri fuori ---

static func severita(danno: int, vita_massima: int) -> float:
	# Quanto e' stato grosso questo colpo, da 0 a 1. NON e' il danno assoluto:
	# trenta danni a una creatura da quaranta punti vita sono la fine del mondo,
	# trenta danni a un boss da milleduecento sono una zanzara. Un effetto che
	# guardasse il numero e non la proporzione scuoterebbe lo schermo per le
	# zanzare e resterebbe fermo per la fine del mondo.
	if vita_massima <= 0 or danno <= 0:
		return 0.0
	return clampf(float(danno) / (float(vita_massima) * DANNO_PIENO), 0.0, 1.0)

static func durata_fermo(grado: float, critico := false) -> float:
	# Quanti secondi dura il fermo immagine. Zero sotto la soglia: e' la regola
	# piu' importante di tutte, perche' un fermo che succede sempre e' solo un
	# gioco che va a scatti.
	if grado < SEVERITA_MINIMA_FERMO and not critico:
		return 0.0
	var secondi := 0.045 + grado * 0.075
	if critico:
		# il critico si ferma comunque, e si ferma di piu': e' l'eccezione, e
		# deve interrompere la lettura come fa gia' il numero grande
		secondi = maxf(secondi, 0.07) * 1.6
	return minf(secondi, FERMO_MASSIMO)

static func ampiezza_scossa(grado: float, critico := false) -> float:
	# Di quanti pixel sbanda l'inquadratura. Sopra i dodici pixel non si legge
	# piu' niente a schermo e comincia a dare fastidio invece che emozione.
	if grado < SEVERITA_MINIMA_SCOSSA and not critico:
		return 0.0
	var pixel := 2.0 + grado * 9.0
	if critico:
		pixel = maxf(pixel, 5.0) * 1.35
	return minf(pixel, 12.0)

static func marchio_efficacia(efficacia: float) -> String:
	# IL TIPO DEVE VEDERSI SUL COLPO. Prima l'efficacia esisteva solo come
	# moltiplicatore e come una riga di testo che scorreva via: il giocatore
	# vedeva un numero piu' grosso e non aveva modo di collegarlo all'arma che
	# aveva in mano.
	#
	# Un segno e non solo un colore, per la stessa ragione per cui i posti gia'
	# visitati hanno un pallino e non solo una tinta (vedi Stile.segna_visita):
	# chi non distingue bene i colori deve poter leggere lo stesso cosa e'
	# successo.
	if efficacia <= 0.0:
		return "✕"
	if efficacia > 1.0:
		return " ▲"
	if efficacia < 1.0:
		return " ▼"
	return ""

static func testo_del_numero(danno: int, critico := false, efficacia := 1.0) -> String:
	# Il numero che vola, scritto per intero: il danno, il punto esclamativo del
	# critico, il segno dell'efficacia. Sta qui e non dentro chi lo mostra per
	# una ragione sola: dentro Combattimento.gd finirebbe in una Callable che le
	# prove non possono guardare - da muti il numero non nasce nemmeno - e una
	# riga che nessuno puo' misurare e' una riga che un giorno perde il segno
	# dell'efficacia senza che se ne accorga nessuno.
	var testo := ("−%d!" % danno) if critico else ("−%d" % danno)
	return testo + marchio_efficacia(efficacia)

static func verso_scatto(chi_e_a_sinistra: bool) -> Vector2:
	# La squadra sta a sinistra del campo, i nemici a destra (vedi Campo.gd):
	# sporgersi verso il nemico vuol dire andare a destra se sei della squadra,
	# a sinistra se sei una creatura. Passa un booleano e non due schede perche'
	# cosi' si puo' provare senza costruire mezza schermata.
	return Vector2(1, 0) if chi_e_a_sinistra else Vector2(-1, 0)

# --- la parte che tocca i nodi: tween, e nessuna decisione ---

func colpo(scheda_attaccante: Control, scheda_bersaglio: Control,
		danno: int, vita_massima: int, critico := false) -> void:
	# Tutto quello che si sente quando un colpo arriva, in un posto solo. Chi
	# chiama non deve sapere che esistono tre effetti diversi ne' in che ordine
	# vanno: passa chi ha colpito, chi ha incassato e quanto ha fatto male.
	if muta:
		return
	var grado := severita(danno, vita_massima)
	scatto(scheda_attaccante, scheda_bersaglio)
	contraccolpo(scheda_bersaglio, grado)
	scossa(ampiezza_scossa(grado, critico))
	fermo(durata_fermo(grado, critico))

func scatto(scheda_attaccante: Control, scheda_bersaglio: Control) -> void:
	# Chi colpisce si sporge verso chi sta colpendo e torna al suo posto. La
	# direzione esce dalle posizioni vere delle due schede, non da "e' del
	# party": cosi' funziona anche quando a colpire e' una creatura evocata che
	# sta dall'altra parte del campo.
	if muta or not valido(scheda_attaccante):
		return
	var verso := Vector2(1, 0)
	if valido(scheda_bersaglio):
		var differenza := scheda_bersaglio.global_position.x - scheda_attaccante.global_position.x
		verso = verso_scatto(differenza >= 0.0)
	sposta_e_torna(scheda_attaccante, verso * 14.0, 0.09, 0.13)

func contraccolpo(scheda_bersaglio: Control, grado: float) -> void:
	# Chi incassa viene spinto indietro. Poco: e' un cenno, non un volo. Il
	# lampo di colore continua a farlo Voce.lampeggia - qui c'e' solo il
	# movimento, cosi' le due cose restano separabili
	if muta or not valido(scheda_bersaglio) or grado <= 0.0:
		return
	sposta_e_torna(scheda_bersaglio, Vector2(0, 1) * (3.0 + grado * 7.0), 0.06, 0.16)

func sposta_e_torna(nodo: Control, spostamento: Vector2, andata: float, ritorno: float) -> void:
	# Va e torna AL PUNTO DA CUI E' PARTITO, letto adesso. Se due colpi si
	# accavallano il secondo parte da dove si trova il nodo in quel momento e
	# rimette le cose a posto da li': non esiste nessuna posizione "giusta"
	# memorizzata che possa restare disallineata.
	var partenza := nodo.position
	var gesto := nodo.create_tween()
	gesto.tween_property(nodo, "position", partenza + spostamento, andata) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	gesto.tween_property(nodo, "position", partenza, ritorno) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func scossa(pixel: float) -> void:
	# L'inquadratura sbanda e si rimette a posto. Sbanda il CORPO della
	# schermata, non lo sfondo: se si muovesse anche lo sfondo si vedrebbero i
	# bordi neri dello schermo per tutta la durata.
	#
	# QUANDO SI LEGGE LA POSIZIONE DI PARTENZA, e perche' non e' ovvio.
	#
	# Rileggerla sempre e' il bug ovvio: due colpi ravvicinati, il secondo legge
	# la posizione GIA' spostata dal primo e la prende per buona, e da li' in poi
	# la schermata resta storta per sempre.
	#
	# Leggerla una volta sola per tutto lo scontro pero' e' il bug opposto, solo
	# piu' difficile da incontrare: se il giocatore ridimensiona la finestra, gli
	# ancoraggi rimettono il corpo dove va, e la base memorizzata punta a dove
	# stava PRIMA - la scossa successiva rimetterebbe la schermata al posto
	# vecchio.
	#
	# La risposta sta in mezzo: si rilegge ogni volta, tranne quando una scossa
	# e' ancora in corso - che e' esattamente il caso in cui la posizione attuale
	# non e' quella buona.
	if muta or pixel <= 0.0 or not valido(nodo_scosso):
		return
	var corpo := nodo_scosso as Control
	if corpo == null:
		return
	var gia_in_moto: bool = tween_scossa != null and tween_scossa.is_valid()
	if not gia_in_moto or not ho_la_base:
		base_scossa = corpo.position
		ho_la_base = true
	if gia_in_moto:
		tween_scossa.kill()
	tween_scossa = corpo.create_tween()
	# quattro sbandate che calano, e l'ultima riporta esattamente alla base
	var passi := 4
	for passo in passi:
		var quota := pixel * (1.0 - float(passo) / float(passi))
		var dove := base_scossa + Vector2(
				GameState.rng.randf_range(-quota, quota),
				GameState.rng.randf_range(-quota, quota) * 0.6)
		tween_scossa.tween_property(corpo, "position", dove, 0.045)
	tween_scossa.tween_property(corpo, "position", base_scossa, 0.05)

func fermo(secondi: float) -> void:
	# IL FERMO IMMAGINE, e la ragione per cui e' scritto con tanta prudenza.
	#
	# Engine.time_scale e' globale e non appartiene a nessuna scena: se si
	# abbassa e qualcosa va storto prima di rialzarlo - la scena viene liberata,
	# lo scontro finisce, il giocatore esce dal menu - il gioco INTERO resta al
	# rallentatore per sempre, e non c'e' niente a schermo che spieghi perche'.
	#
	# Tre difese, tutte necessarie:
	#   1. il timer che rimette a posto ignora time_scale (ultimo parametro) e
	#      gira anche in pausa: se dipendesse dal tempo rallentato impiegherebbe
	#      otto volte tanto, e in pausa non arriverebbe mai
	#   2. un fermo alla volta: due colpi ravvicinati non moltiplicano il
	#      rallentamento ne' si rubano il ripristino a vicenda
	#   3. sblocca(), che chi ci gioca chiama quando la scena esce dall'albero
	if muta or secondi <= 0.0 or albero == null or fermo_in_corso:
		return
	fermo_in_corso = true
	Engine.time_scale = SCALA_FERMO
	var sveglia := albero.create_timer(secondi, true, false, true)
	sveglia.timeout.connect(func() -> void:
		Engine.time_scale = 1.0
		fermo_in_corso = false)

func sblocca() -> void:
	# La rete di sicurezza. Va chiamata quando la schermata di combattimento
	# esce dall'albero, comunque sia finita: vinta, persa, fuggita, o perche' il
	# giocatore ha chiuso tutto. Rimettere a posto una cosa che era gia' a posto
	# non costa niente; non rimetterla a posto costa l'intera partita.
	fermo_in_corso = false
	if not is_equal_approx(Engine.time_scale, 1.0):
		Engine.time_scale = 1.0
	if ho_la_base and valido(nodo_scosso):
		var corpo := nodo_scosso as Control
		if corpo != null:
			if tween_scossa != null and tween_scossa.is_valid():
				tween_scossa.kill()
			corpo.position = base_scossa

func valido(nodo: Object) -> bool:
	return nodo != null and is_instance_valid(nodo)
