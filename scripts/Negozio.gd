extends Control

# IL NEGOZIO, come l'ha disegnato Bru (schema a 1280x720, docs/interfaccia.md).
#
#   in alto      i negozi aperti, uno per linguetta, e Indietro
#   a sinistra   i Tazo in grande, e sotto la descrizione dell'oggetto scelto
#   in basso     lo scaffale: cinque carte oblique alla volta, che scorrono
#   a destra     la vetrina cremisi con l'oggetto scelto in grande, quanto ti
#                resta, quanti ne hai, e COMPRA
#
# Le tre domande di sempre - che cosa fa, ne ho gia', me lo posso permettere -
# hanno ognuna il suo posto fisso, e le risposte le da' Merce.gd.
#
# COME SI USA. Col mouse: clic su una carta, clic su COMPRA; la rotella scorre
# lo scaffale. Con la tastiera: le frecce scorrono le carte, INVIO sulla carta
# scelta porta su COMPRA, un altro INVIO compra. Comprare non aspetta niente:
# i Tazo se ne vanno subito e il numero li insegue (Conto.gd), e si puo'
# ricomprare mentre il numero sta ancora scendendo.
#
# ENTRA IN CASCATA, COMPRA PER ULTIMO: prima il guscio (la barra, la vetrina),
# poi il contenuto (le carte), per ultima l'azione principale - l'ordine di
# Carbon, lo stesso della pausa.

const SCENA_SEDE := "res://scenes/Sede.tscn"
const VISIBILI := 5
const PRIMA_CARTA := Vector2(40, 400)
const PASSO_CARTA := 129.0
const INIZIO_LINGUETTE := Vector2(180, 10)
const FINE_LINGUETTE := 940.0       # dove comincia la vetrina, in cima

var tavola: Tavola
var vetrina: Vetrina
var etichetta_tazo: Label
var conto_tazo: Conto
var descrizione: TestoCheScorre
var sacca: Cartiglio
var barra: Control
var scaffale: Control
var carte: Array[CartaNegozio] = []
var linguette: Array[TastoObliquo] = []
var indietro: TastoObliquo
var prima: TastoObliquo
var dopo: TastoObliquo
var posizione: Label
var schegge: Schegge
var scivolata: Tween
var negozio_aperto := ""
var fila: Array[Dictionary] = []
var scelta := 0
var inizio := 0


func _ready() -> void:
	costruisci_tavola()
	conto_tazo = Conto.su(etichetta_tazo, "%d")
	conto_tazo.scrivi(GameState.tazo)   # all'apertura il numero c'e' gia', non risale da zero
	negozio_aperto = String(GameState.negozi_sbloccati[0]) if not GameState.negozi_sbloccati.is_empty() else ""
	costruisci_linguette()
	costruisci()
	entra()
	# il fuoco alla prima carta; in un negozio vuoto a Indietro, che senza un
	# fuoco la tastiera non ha da dove partire
	Tavola.fuoco.call_deferred(carte[0] as Control if carte[0].visible else indietro as Control)


# --- la tavola ----------------------------------------------------------------

func costruisci_tavola() -> void:
	tavola = Tavola.su(self)
	var fondo := Fondo.new()
	tavola.add_child(fondo)
	vetrina = Vetrina.new()
	tavola.add_child(vetrina)
	vetrina.compra.scelto.connect(acquista)
	costruisci_sinistra()
	costruisci_scaffale()
	costruisci_barra()
	schegge = Schegge.new()
	schegge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schegge)


func costruisci_barra() -> void:
	barra = Control.new()
	barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tavola.add_child(barra)
	Tavola.metti(barra, Rect2(0, 0, Tavola.LARGO, 60))
	indietro = TastoObliquo.nuovo("INDIETRO", "accento", 20)
	indietro.scelto.connect(_su_indietro)
	barra.add_child(indietro)
	indietro.position = Vector2(16, 10)
	sacca = Cartiglio.nuovo("", Stile.colore("bordo_acceso"), Stile.colore("box_testo"),
			Stile.colore("box_testo"), 20)
	barra.add_child(sacca)


func costruisci_sinistra() -> void:
	etichetta_tazo = Tavola.scritta("", 104, Stile.colore("testo"), Caratteri.titolo())
	tavola.add_child(etichetta_tazo)
	Tavola.metti(etichetta_tazo, Rect2(108, 104, 520, 124))
	Tavola.ombra(etichetta_tazo, Stile.colore("accento"), Vector2(5, 5))
	var sotto := Tavola.scritta("TAZO IN TASCA", 18, Stile.colore("testo"), Caratteri.tondo(900))
	tavola.add_child(sotto)
	Tavola.metti(sotto, Rect2(148, 234, 320, 28))
	descrizione = TestoCheScorre.nuovo(16, Stile.colore("testo_smorzato"), Stile.colore("sfondo"))
	tavola.add_child(descrizione)
	Tavola.metti(descrizione, Rect2(115, 276, 460, 100))


func costruisci_scaffale() -> void:
	scaffale = Control.new()
	scaffale.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tavola.add_child(scaffale)
	Tavola.metti(scaffale, Rect2(0, 0, Tavola.LARGO, Tavola.ALTO))
	for i in VISIBILI:
		var carta := CartaNegozio.new()
		scaffale.add_child(carta)
		carta.position = PRIMA_CARTA + Vector2(PASSO_CARTA * i, 0)
		carta.presa.connect(_su_carta_presa)
		carta.sposta.connect(sposta)
		carta.focus_entered.connect(func() -> void: seleziona(inizio + i, false))
		carte.append(carta)
	prima = TastoObliquo.nuovo("<", "chiaro", 22)
	dopo = TastoObliquo.nuovo(">", "chiaro", 22)
	prima.freccia = Vector2.LEFT
	dopo.freccia = Vector2.RIGHT
	prima.scelto.connect(func() -> void: sposta(-VISIBILI))
	dopo.scelto.connect(func() -> void: sposta(VISIBILI))
	for i in 2:
		var freccia: TastoObliquo = [prima, dopo][i]
		tavola.add_child(freccia)
		# una accanto all'altra, e la scritta dopo: dalla misura vera, non a occhio
		freccia.position = Vector2(40.0 if i == 0 else 44.0 + prima.misura_voluta().x, 640.0)
	posizione = Tavola.scritta("", 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900))
	tavola.add_child(posizione)
	var dopo_le_frecce := dopo.position.x + dopo.misura_voluta().x + 10.0
	Tavola.metti(posizione, Rect2(dopo_le_frecce, 642, 600.0 - dopo_le_frecce, 36))


# --- cosa si vede ---------------------------------------------------------------

func costruisci() -> void:
	# TUTTO DA CAPO, e costa poco: la chiama chi ha appena comprato qualcosa,
	# perche' dopo un acquisto cambiano i Tazo, la sacca, e cosa ti puoi
	# permettere su ogni carta
	conto_tazo.vai_a(GameState.tazo)
	fila = Merce.voci(GameState.negozi.get(negozio_aperto, {}))
	scelta = clampi(scelta, 0, maxi(fila.size() - 1, 0))
	inizio = clampi(inizio, 0, maxi(fila.size() - VISIBILI, 0))
	aggiorna_linguette()
	aggiorna_sacca()
	mostra_scelta(false)


func costruisci_linguette() -> void:
	# UNA VOLTA SOLA, all'apertura: i negozi aperti non cambiano mentre sei
	# dentro. Rifatte a ogni acquisto, la linguetta appena premuta spariva
	# sotto il dito - con la sua gelatina a meta' e il fuoco della tastiera
	# con lei, che non tornava piu' da nessuna parte.
	#
	# Stanno tra Indietro e la vetrina: se i nomi non ci stanno, si stringono
	# tutte insieme dello stesso tanto
	for corpo in range(20, 13, -1):
		for vecchia in linguette:
			vecchia.free()
		linguette.clear()
		var x := INIZIO_LINGUETTE.x
		for id_negozio in GameState.negozi_sbloccati:
			var nome := String(GameState.negozi.get(id_negozio, {}).get("nome", id_negozio)).to_upper()
			var linguetta := TastoObliquo.nuovo(nome, "spoglio", corpo)
			linguetta.scelto.connect(apri_negozio.bind(String(id_negozio)))
			linguetta.set_meta("negozio", String(id_negozio))
			barra.add_child(linguetta)
			linguetta.position = Vector2(x, INIZIO_LINGUETTE.y)
			x += linguetta.misura_voluta().x + 8.0
			linguette.append(linguetta)
		if x <= FINE_LINGUETTE:
			return


func aggiorna_linguette() -> void:
	for linguetta in linguette:
		linguetta.stile = "accento" if String(linguetta.get_meta("negozio")) == negozio_aperto else "spoglio"
		linguetta.queue_redraw()


func aggiorna_sacca() -> void:
	sacca.testo = "SACCA %d/%d" % [GameState.sacca.size(), Merce.capienza_sacca()]
	sacca.update_minimum_size()
	sacca.size = sacca.get_combined_minimum_size()
	sacca.position = Vector2(Tavola.LARGO - sacca.size.x - 18.0, 12.0)
	sacca.queue_redraw()


func mostra_scelta(entra_il_disegno := true) -> void:
	for i in VISIBILI:
		var indice := inizio + i
		carte[i].carica(fila[indice] if indice < fila.size() else {}, indice == scelta)
	var voce: Dictionary = fila[scelta] if scelta < fila.size() else {}
	vetrina.visible = not voce.is_empty()
	vetrina.mostra(voce, entra_il_disegno)
	descrizione.scrivi(testo_descrizione(voce))
	prima.inerte = inizio <= 0
	dopo.inerte = inizio + VISIBILI >= fila.size()
	punta_alla_scelta()
	prima.queue_redraw()
	dopo.queue_redraw()
	posizione.text = testo_posizione(voce)


func punta_alla_scelta() -> void:
	# DA FUORI DELLO SCAFFALE SI TORNA ALLA CARTA SCELTA: da COMPRA con la
	# freccia a sinistra, dalle linguette e da Indietro con quella in giu',
	# dalle frecce di pagina con quella in su. La carta piu' vicina a occhio e'
	# un'altra, e arrivarci col fuoco la sceglieva - cambiando l'oggetto sotto
	# il dito
	if scelta - inizio < 0 or scelta - inizio >= VISIBILI:
		return
	var carta := carte[scelta - inizio]
	vetrina.compra.focus_neighbor_left = vetrina.compra.get_path_to(carta)
	for sopra: Control in linguette + [indietro]:
		sopra.focus_neighbor_bottom = sopra.get_path_to(carta)
	for sotto: Control in [prima, dopo]:
		sotto.focus_neighbor_top = sotto.get_path_to(carta)


func testo_descrizione(voce: Dictionary) -> String:
	if voce.is_empty():
		return "Qui oggi non c'è niente da comprare."
	var id_oggetto := String(voce.get("oggetto", ""))
	var dati := GameState.dati_oggetto(id_oggetto)
	var righe: Array[String] = []
	if String(voce.get("tipo", "")) == "baratto":
		var materiali: Array[String] = []
		for materiale in voce.get("richiede", []):
			materiali.append(Merce.nome_di(String(materiale)))
		righe.append("[b][color=#%s]In cambio di: %s[/color][/b]" % [Stile.colore("testo").to_html(false), ", ".join(materiali)])
	else:
		righe.append("[b][color=#%s]%s[/color][/b]" % [Stile.colore("testo").to_html(false), Merce.riassunto_effetto(dati)])
	righe.append(String(dati.get("descrizione", "")))
	var gia := Merce.quanti_ne_hai(id_oggetto)
	if gia != "":
		righe.append("[b][color=#%s]%s[/color][/b]" % [Stile.colore("accento").to_html(false), gia])
	return "\n".join(righe)


func testo_posizione(voce: Dictionary) -> String:
	if fila.is_empty():
		return ""
	return "%s   ·   %d DI %d" % [String(voce.get("categoria", "")).to_upper(), scelta + 1, fila.size()]


# --- i gesti ------------------------------------------------------------------

func seleziona(indice: int, col_fuoco: bool) -> void:
	if fila.is_empty():
		return
	var nuovo := clampi(indice, 0, fila.size() - 1)
	var prima_di := inizio
	if nuovo < inizio:
		inizio = nuovo
	elif nuovo >= inizio + VISIBILI:
		inizio = nuovo - VISIBILI + 1
	var cambiata := nuovo != scelta or inizio != prima_di
	scelta = nuovo
	if inizio != prima_di:
		scorri_scaffale(signi(inizio - prima_di))
	if cambiata:
		mostra_scelta()
	if col_fuoco:
		carte[scelta - inizio].grab_focus()


func sposta(quanto: int) -> void:
	if fila.is_empty():
		return
	var arrivo := clampi(scelta + quanto, 0, fila.size() - 1)
	if arrivo == scelta:
		Movimento.suona("rifiuto")   # in fondo allo scaffale: dice di no
		return
	seleziona(arrivo, true)


func scorri_scaffale(verso: int) -> void:
	# lo scaffale scivola di una carta: il contenuto cambia subito, e la fila
	# arriva al suo posto da dove stava. Non si aspetta la fine per premere:
	# tenendo giu' la freccia ogni scivolata ferma quella prima, se no due
	# tween si contendono la stessa x
	if Movimento.ridotto():
		return
	if scivolata != null and scivolata.is_valid():
		scivolata.kill()
	scaffale.position.x = PASSO_CARTA * 0.5 * float(verso)
	scivolata = scaffale.create_tween()
	Movimento.verso(scivolata, scaffale, "position:x", 0.0, "entrata", Movimento.durata("voce"))


func _su_carta_presa(carta: CartaNegozio, da_tastiera: bool) -> void:
	var indice := inizio + carte.find(carta)
	if da_tastiera and indice == scelta:
		vetrina.compra.grab_focus()   # INVIO sulla carta scelta: si va a COMPRA
		return
	seleziona(indice, false)


func apri_negozio(id_negozio: String) -> void:
	if id_negozio == negozio_aperto:
		return
	negozio_aperto = id_negozio
	scelta = 0
	inizio = 0
	costruisci()
	entra_carte(0.0)


func acquista() -> void:
	if scelta >= fila.size():
		return
	# il tasto spento non arriva qui (dice di no da solo), ma chi chiama
	# acquista() da fuori - l'automa, una prova - trova la stessa regola
	if Merce.perche_no(fila[scelta]) != "" or not Merce.prendi(fila[scelta]):
		vetrina.compra.rifiuta()
		return
	schegge.scoppia(vetrina.compra.get_global_rect().get_center())
	costruisci()


func _su_indietro() -> void:
	Transizioni.vai(SCENA_SEDE)


# --- l'entrata -----------------------------------------------------------------

func entra() -> void:
	Tavola.entra(barra, 0.0, Vector2(0, -12))
	Tavola.entra(vetrina, 0.03, Vector2(48, 0))
	Tavola.entra(etichetta_tazo, 0.05, Vector2(-24, 0))
	Tavola.entra(descrizione, 0.07, Vector2(-24, 0))
	entra_carte(0.1)


func entra_carte(dopo_quanto: float) -> void:
	# le carte in cascata, e COMPRA per ultimo
	var ritardi := Movimento.ritardi_cascata(VISIBILI + 1, VISIBILI, dopo_quanto)
	for i in VISIBILI:
		Tavola.entra(carte[i], ritardi[i], Vector2(0, 24))
	Tavola.entra(vetrina.compra, ritardi[VISIBILI], Vector2(24, 0))


# --- il fondo --------------------------------------------------------------------

class Fondo extends Control:
	# nero, con la trama a puntini e una fascia chiarissima parallela alla
	# vetrina: la pagina dello schema di Bru, al buio
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Stile.colore("sfondo"))
		Sagome.puntinato(self, Rect2(Vector2.ZERO, size), 24.0, Color(Stile.colore("testo"), 0.07))
		var chiaro := PackedVector2Array([Vector2(760, 0), Vector2(860, 0), Vector2(514, 720), Vector2(414, 720)])
		draw_colored_polygon(chiaro, Color(Stile.colore("testo"), 0.035))
		draw_line(Vector2(0, 58), Vector2(980, 58), Color(Stile.colore("testo"), 0.12), 1.0)
		var riga := 40.0
		while riga < 700.0:
			draw_rect(Rect2(riga, 600, 3, 2), Color(Stile.colore("testo"), 0.25))
			riga += 7.0
		draw_colored_polygon(Sagome.rombo(Vector2(126, 248), 10.0), Stile.colore("accento"))
