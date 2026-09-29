class_name GiroDataPad
extends CanvasLayer

# IL DATA PAD SPIEGATO APRENDOLO, non raccontandolo.
#
# Bru, 25 settembre: «quando si dovrebbe aprire il data pad durante la
# conversazione in sala non si apre nulla, nessuna interfaccia, qui dovrebbe
# esserci il tutorial che ti spiega il resto delle funzioni del datapad [...]
# invece c'e' solo testo che scorre e non spiega bene, bisogna educare il
# giocatore sul tasto in alto a sinistra, lo faremo a inizio gioco sfruttando
# l'altoparlante [...] qui ti guida a cliccare il tasto, ti spiega tutte le
# voci».
#
# Aveva ragione: la sala diceva «Apri il data pad» e poi descriveva a parole un
# menu che restava chiuso. Una schermata la si impara usandola, con lei aperta
# davanti - e' la stessa ragione per cui la Guida delle Pianure parla sopra la
# mappa vera (GuidaSullaMappa) e non sopra un disegno.
#
# COME FUNZIONA. Una battuta di tipo "data_pad" in una sequenza ferma la scena
# e apre il giro; finito il giro, la scena riprende dalla battuta dopo:
#
#   {"tipo": "data_pad", "passi": [
#     {"testo": "...", "indica": "menu", "aspetta": "apri"},
#     {"testo": "...", "indica": "voce:zaino"},
#     {"testo": "...", "indica": "voce:messaggi", "aspetta": "voce:messaggi"},
#     {"testo": "...", "indica": "sezione:database", "mostra": true},
#     {"testo": "...", "aspetta": "chiudi"}]}
#
#   "indica"   cosa si evidenzia: "menu" (il tasto in alto a sinistra),
#              "voce:<segno>" (una voce del data pad: storico, diario, zaino,
#              squadra, opzioni, uscita, riprendi; e "messaggi", l'iconcina in
#              basso a destra), "voci:<segno>,<segno>" (un gruppo di voci, in
#              una cornice sola), "sezione:<chiave>" (una sezione del Data
#              pad), "tazo" (il cartellino dei Tazo in alto a destra),
#              "chiudi" (quello che lo chiude, dovunque tu sia: «Indietro» o
#              «Riprendi»)
#   "aspetta"  cosa deve fare chi gioca per andare avanti: "apri", "voce:diario",
#              "voce:messaggi", "sezione:<chiave>", "chiudi". Senza, si va avanti
#              col clic, come in un dialogo
#   "mostra"   apre da se' la sezione indicata del Data pad, da qualunque
#              pagina, per fartela vedere mentre la spiega
#   "apri"     apre da se' il data pad (la sala: «Apri il data pad» deve aprirlo)
#
# IL RESTO DELLO SCHERMO E' VELATO E NON SI TOCCA: resta scoperto solo il pezzo
# indicato, e solo quando c'e' da premerlo. E' il tutorial di Veronica applicato
# al menu - «il menu si riduce a quella» - senza bottoni finti: le voci sono
# quelle vere e le preme chi gioca. Chiudere il data pad a meta' (ESC, sempre)
# chiude anche il giro: la scena riprende, e quello che non e' stato spiegato
# resta li' da scoprire.

signal finito

const LIVELLO := 110          # sopra il data pad (Pausa sta a 100)
const SCENA_BOX := "res://scenes/BoxTesto.tscn"
const VELO := Color(0, 0, 0, 0.45)
const MARGINE := 24.0
const LARGHEZZA_BOX := 0.56   # il box sta in basso a destra: a sinistra ci sono le voci
const RIGHE_DEL_BOX := 3
const PANNELLO_DI := {"diario": "diario", "zaino": "inventario", "squadra": "equipaggiamento",
		"storico": "storico", "opzioni": "opzioni", "messaggi": "messaggi"}

var schermata: Node
var passi: Array = []
var quale := -1
var box: Control
var cartiglio: Cartiglio            # «TUTORIAL», appiccicato sopra il box
var cornice: Evidenza
var tende: Array[ColorRect] = []   # il velo, in quattro pezzi intorno al buco
var indicato: Control = null
var zona_indicata := Rect2()       # dove sta quello che si indica: un pezzo, o un gruppo di voci
var gia_aperto := false            # il data pad e' stato aperto: da li' in poi, chiuso vuol dire finito
var chiuso := false
var battuta := -1                  # a che battuta era la scena quando il giro e' partito
var box_in_alto := false


static func prende(dove: Node, msg: Dictionary) -> bool:
	# la schermata dei dialoghi chiede, battuta per battuta, se questa e' un
	# giro: se lo e', parte, e la coda si ferma qui finche' il giro non finisce
	if String(msg.get("tipo", "")) != "data_pad":
		return false
	avvia(dove, msg)
	return true


static func avvia(dove: Node, msg: Dictionary) -> GiroDataPad:
	var giro := GiroDataPad.new()
	giro.schermata = dove
	giro.passi = msg.get("passi", [])
	dove.add_child(giro)
	return giro


func _ready() -> void:
	layer = LIVELLO
	# il data pad mette in pausa il mondo: il giro deve andare avanti lo stesso
	process_mode = Node.PROCESS_MODE_ALWAYS
	var contatore: Variant = schermata.get("contatore_messaggi")
	battuta = int(contatore) if contatore != null else -1
	zittisci_la_scena()
	for i in 4:
		var tenda := ColorRect.new()
		tenda.color = VELO
		tenda.mouse_filter = Control.MOUSE_FILTER_STOP
		tenda.gui_input.connect(_su_input)
		add_child(tenda)
		tende.append(tenda)
	cornice = Evidenza.libera("cornice")
	cornice.visible = false
	add_child(cornice)
	box = (load(SCENA_BOX) as PackedScene).instantiate()
	add_child(box)
	box.anchor_left = 1.0 - LARGHEZZA_BOX
	box.anchor_right = 1.0
	box.anchor_top = 1.0
	box.anchor_bottom = 1.0
	box.offset_left = 0.0
	box.offset_right = -MARGINE
	box.offset_bottom = -MARGINE
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.gui_input.connect(_su_input)
	# IL BOX HA UNA FORMA SUA. Era il box bianco dei dialoghi col bordo nero, e
	# sul nero del menu il bordo spariva: restava una lastra bianca, con in cima
	# la riga vuota del nome - Bru: «il box di dialogo e' amorfo». Adesso parla
	# la lingua del menu che spiega: pende come le sue fasce, ha il bordo
	# cremisi e la sfoglia dietro, e sopra un cartiglio che dice cos'e'
	box.nome_fuori_dal_box()
	# TRE RIGHE, non due come il box dei dialoghi: questo e' largo poco piu' di
	# meta' schermo, e col carattere dei dialoghi a 28 meta' dei passi andava su
	# una seconda pagina - una spiegazione spezzata a meta' mentre indichi una voce
	var interlinea := float(Stile.dati.get("interlinee", {}).get("lettura", 1.5))
	box.imposta_altezza(ceili(RIGHE_DEL_BOX * Caratteri.corpo_dialoghi() * interlinea))
	box.add_theme_stylebox_override("panel", cornice_del_box())
	cartiglio = Cartiglio.nuovo("TUTORIAL", Stile.colore("accento"), Stile.colore("testo"),
			Stile.colore("bordo_acceso"), Stile.dimensione("corpo"))
	cartiglio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cartiglio)
	cartiglio.size = cartiglio.get_combined_minimum_size()
	cartiglio.svela(0.05)
	# IL TRIANGOLINO HA IL SUO POSTO. In un box largo poco piu' di meta'
	# schermo l'ultima parola della riga ci finiva sotto; e dove c'e' da premere
	# una voce non c'e' proprio, perche' un clic sul box li' non va avanti
	box.posto_al_triangolo(true)
	box.scrittura_finita.connect(func() -> void:
		if String(passo().get("aspetta", "")) != "":
			box.nascondi_indicatore())
	avanti()


static func cornice_del_box() -> StyleBox:
	var forma := Stile.stile_box_testo()
	if forma is StyleBoxFlat:
		var piatta := forma as StyleBoxFlat
		piatta.border_color = Stile.colore("accento")
		piatta.skew = Vector2(-0.06, 0.0)
		piatta.shadow_color = Stile.colore("accento").darkened(0.45)
		piatta.shadow_size = 1
		piatta.shadow_offset = Vector2(9, 8)
	return forma


func zittisci_la_scena() -> void:
	# la schermata sotto si ferma: il suo testo, il nome, e l'area che fa andare
	# avanti - un clic li' salterebbe il giro. Tornano da soli alla battuta dopo
	for nome in ["box", "nastro", "area_avanza"]:
		var pezzo: Variant = schermata.get(nome)
		if pezzo is CanvasItem:
			(pezzo as CanvasItem).visible = false
	if schermata.has_method("nascondi_comandi"):
		schermata.call("nascondi_comandi")


func passo() -> Dictionary:
	return passi[quale] if quale >= 0 and quale < passi.size() else {}


func avanti() -> void:
	quale += 1
	if quale >= passi.size():
		finisci()
		return
	var adesso := passo()
	if bool(adesso.get("apri", false)) and not Pausa.aperta:
		Pausa.apri()
		gia_aperto = true
	if bool(adesso.get("mostra", false)):
		var sezione := String(adesso.get("indica", "")).trim_prefix("sezione:")
		if Pausa.aperta and (Pausa.pannello != "diario" or Pausa.sezione_diario != sezione):
			Pausa.sezione_diario = sezione
			Pausa.mostra_diario()
	var testo := Testi.accorda(String(adesso.get("testo", "")), GameState.sesso_protagonista)
	GameState.registra_storico("narrazione", "", testo)
	# dritto e nero, non il corsivo della narrazione: non racconta, spiega
	box.mostra("dialogo", testo, "")


func _process(_delta: float) -> void:
	# il cartiglio sta attaccato all'angolo del box, anche quando il box sale
	cartiglio.position = box.position + Vector2(28.0, -cartiglio.size.y * 0.75)
	if chiuso or quale < 0 or quale >= passi.size():
		return
	if scena_andata_avanti():
		abbandona()
		return
	if Pausa.aperta:
		gia_aperto = true
	elif gia_aperto:
		# CHI CHIUDE IL DATA PAD A META', CHIUDE ANCHE IL GIRO: non lo si riapre a
		# forza. La scena riprende, e il resto lo trovera' da se'
		finisci()
		return
	if fatto(String(passo().get("aspetta", ""))):
		avanti()
		return
	var pezzi := pezzi_indicati(String(passo().get("indica", "")))
	indicato = pezzi[0] if not pezzi.is_empty() else null
	zona_indicata = Rect2()
	for pezzo in pezzi:
		zona_indicata = pezzo.get_global_rect() if not zona_indicata.has_area() else zona_indicata.merge(pezzo.get_global_rect())
	sposta_il_box()
	sistema_il_velo()


func sposta_il_box() -> void:
	# IL BOX NON COPRE QUELLO CHE INDICA. Sta in basso a destra, e in basso a
	# destra c'e' l'iconcina dei messaggi: il giro chiedeva di premerla e il box
	# ci stava sopra, prendendosi il clic. Se si toccano, il box sale in alto.
	# Il confronto e' col posto in basso, non con dove il box e' adesso: se no,
	# salito, non toccherebbe piu' niente e riscenderebbe al fotogramma dopo
	var schermo := get_viewport().get_visible_rect().size
	var in_basso := Rect2(schermo.x * (1.0 - LARGHEZZA_BOX), schermo.y - MARGINE - box.size.y,
			schermo.x * LARGHEZZA_BOX - MARGINE, box.size.y)
	var su := zona_indicata.has_area() and zona_indicata.intersects(in_basso)
	if su == box_in_alto:
		return
	box_in_alto = su
	box.anchor_top = 0.0 if su else 1.0
	box.anchor_bottom = box.anchor_top
	# in alto si mette SOTTO la testata del menu, non sopra: i Tazo in alto a
	# destra restano sempre visibili (la sala ne parla), e lascia il posto al
	# cartiglio, che sporge sopra l'angolo
	box.offset_top = sotto_la_testata() + cartiglio.size.y if su else 0.0
	box.offset_bottom = box.offset_top if su else -MARGINE
	box.grow_vertical = Control.GROW_DIRECTION_END if su else Control.GROW_DIRECTION_BEGIN


func sotto_la_testata() -> float:
	# dove finisce il cartellino dei Tazo, cioe' la testata del menu
	var tazo := cartellino_dei_tazo()
	return maxf(MARGINE, tazo.get_global_rect().end.y + MARGINE * 0.5) if tazo != null else MARGINE


func cartellino_dei_tazo() -> Control:
	if not Pausa.aperta or Pausa.colonna == null:
		return null
	for cartello in Pausa.colonna.find_children("*", "Cartiglio", true, false):
		if String(cartello.get("testo")).begins_with("TAZO") and (cartello as Control).is_visible_in_tree():
			return cartello as Control
	return null


func fatto(aspetta: String) -> bool:
	# la condizione del passo: se c'e', e' il gesto di chi gioca a mandarlo avanti
	if aspetta == "":
		return false
	if aspetta == "apri":
		return Pausa.aperta
	if aspetta == "chiudi":
		return not Pausa.aperta
	if aspetta.begins_with("voce:"):
		return Pausa.aperta and Pausa.pannello == String(PANNELLO_DI.get(aspetta.trim_prefix("voce:"), ""))
	if aspetta.begins_with("sezione:"):
		return Pausa.aperta and Pausa.pannello == "diario" \
				and Pausa.sezione_diario == aspetta.trim_prefix("sezione:")
	push_error("GiroDataPad: un passo aspetta '%s', che non so riconoscere" % aspetta)
	return true


func pezzi_indicati(indica: String) -> Array[Control]:
	# quello che il passo indica: di solito un pezzo solo, ma "voci:" ne da' un
	# gruppo - «nel primo gruppo si consulta» evidenziava la sola voce di mezzo,
	# e il testo ne nominava tre
	var pezzi: Array[Control] = []
	var chiavi := indica.trim_prefix("voci:").split(",") if indica.begins_with("voci:") else PackedStringArray([indica])
	for chiave in chiavi:
		var pezzo := pezzo_indicato(("voce:" + chiave.strip_edges()) if indica.begins_with("voci:") else chiave)
		if pezzo != null:
			pezzi.append(pezzo)
	return pezzi


func pezzo_indicato(indica: String) -> Control:
	if indica == "menu":
		var icona: Variant = schermata.get("icona_menu")
		return icona as Control if icona is Control and not Pausa.aperta else null
	if indica == "tazo":
		return cartellino_dei_tazo()
	if not Pausa.aperta or Pausa.colonna == null:
		return null
	if indica == "chiudi":
		indica = "voce:riprendi" if Pausa.pannello == "menu" else "voce:indietro"
	var chiave := indica.trim_prefix("voce:")
	if chiave == "messaggi":
		return Pausa.icona_messaggi if Pausa.icona_messaggi.is_visible_in_tree() else null
	for voce in Pausa.colonna.find_children("*", "VoceMenu", true, false):
		if String(voce.get_meta("chiave", "")) == chiave and (voce as Control).is_visible_in_tree():
			return voce as Control
	return null


func sistema_il_velo() -> void:
	# UN BUCO NEL VELO dove c'e' da premere, e il velo intero dove si legge e
	# basta. Il buco c'e' solo se il passo aspetta un gesto: se si sta solo
	# spiegando, anche la voce indicata resta sotto il velo e il clic manda
	# avanti il testo, come in un dialogo
	var schermo := get_viewport().get_visible_rect()
	var aspetta := String(passo().get("aspetta", "")) != ""
	var buco := Rect2()
	if zona_indicata.has_area():
		buco = zona_indicata
		cornice.inquadra(buco)
		if not cornice.visible:
			cornice.visible = true
			cornice.accendi()
	else:
		cornice.visible = false
	if not aspetta:
		# si legge e basta: un velo leggero su tutto, e un clic dovunque va avanti
		tende[0].color = Color(VELO, VELO.a * 0.35)
		metti(tende[0], schermo)
		for i in range(1, 4):
			metti(tende[i], Rect2())
		return
	if buco.size == Vector2.ZERO:
		# c'e' da premere qualcosa che adesso non si vede (sei in un'altra pagina
		# del data pad): niente velo, o non ci si potrebbe piu' muovere
		for tenda in tende:
			metti(tenda, Rect2())
		return
	tende[0].color = VELO
	metti(tende[0], Rect2(schermo.position, Vector2(schermo.size.x, buco.position.y)))
	metti(tende[1], Rect2(Vector2(0.0, buco.end.y), Vector2(schermo.size.x, schermo.end.y - buco.end.y)))
	metti(tende[2], Rect2(Vector2(0.0, buco.position.y), Vector2(buco.position.x, buco.size.y)))
	metti(tende[3], Rect2(Vector2(buco.end.x, buco.position.y), Vector2(schermo.end.x - buco.end.x, buco.size.y)))


func metti(tenda: ColorRect, dove: Rect2) -> void:
	tenda.position = dove.position
	tenda.size = dove.size
	tenda.visible = dove.size.x > 0.0 and dove.size.y > 0.0


func _su_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and (evento as InputEventMouseButton).pressed \
			and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		clic()


func clic() -> void:
	# come nel dialogo: il primo clic completa la frase, il secondo va avanti. Ma
	# solo dove non c'e' niente da premere: li' si va avanti premendolo
	if box.consuma_click():
		return
	if String(passo().get("aspetta", "")) == "":
		avanti()


func _input(evento: InputEvent) -> void:
	# INVIO NON SCAVALCA IL GIRO. Nel data pad il fuoco sta su una voce, e INVIO
	# la premerebbe: mentre si legge, INVIO manda avanti il testo; quando c'e' da
	# premere, passa solo se il fuoco e' sulla voce giusta.
	#
	# ESC INVECE FA QUELLO CHE FA SEMPRE. La prima versione lo fermava mentre si
	# leggeva, per non buttare via la spiegazione con un tasto premuto per
	# sbaglio: l'automa (prove/automa.sh) e' rimasto tre minuti a premere ESC
	# sul data pad senza che succedesse niente - ed e' quello che farebbe chi
	# vuole uscire. ESC chiude il data pad, e chiuderlo chiude il giro
	if chiuso or quale < 0 or not evento.is_action_pressed("ui_accept"):
		return
	var aspetta := String(passo().get("aspetta", ""))
	var fuoco := get_viewport().gui_get_focus_owner()
	if aspetta == "" or indicato == null or fuoco == null \
			or not (fuoco == indicato or indicato.is_ancestor_of(fuoco)):
		get_viewport().set_input_as_handled()
		if aspetta == "":
			clic()


func _exit_tree() -> void:
	# SE SE NE VA LA SCHERMATA, IL GIRO SE NE VA CON LEI - e il data pad che
	# aveva aperto non deve restare aperto da solo. Pausa e' un autoload: senza
	# questa riga restava sopra tutto, col gioco in pausa, anche quando la
	# schermata che l'aveva chiesto non c'era piu' (l'ha trovato una prova che
	# apre la sala e poi la libera)
	if not chiuso:
		chiuso = true
		if Pausa.aperta:
			Pausa.chiudi()


func scena_andata_avanti() -> bool:
	# LA SCENA E' ANDATA AVANTI SENZA IL GIRO. Giocando non succede: finche' il
	# giro e' aperto l'area che fa avanzare e' spenta. Ma chi fa andare avanti la
	# scena da fuori (la prova della giornata intera) lo scavalcava - e il giro
	# della sala, che il data pad lo apre da se', restava li' col gioco in pausa:
	# venti prove dopo, un timer che in pausa non scatta ha fermato la suite
	var contatore: Variant = schermata.get("contatore_messaggi") if is_instance_valid(schermata) else null
	return battuta >= 0 and contatore != null and int(contatore) != battuta


func abbandona() -> void:
	# il giro non serve piu': si toglie di mezzo, e chiude il data pad se era
	# aperto. La scena non va ripresa, e' gia' ripartita
	chiuso = true
	if Pausa.aperta:
		Pausa.chiudi()
	queue_free()


func finisci() -> void:
	if chiuso:
		return
	chiuso = true
	if Pausa.aperta:
		Pausa.chiudi()
	finito.emit()
	# la scena riprende dalla battuta dopo questa: e' lei che rimette a posto
	# box, nome e area d'avanzamento
	if is_instance_valid(schermata) and schermata.has_method("avanza_messaggio"):
		schermata.call_deferred("avanza_messaggio")
	queue_free()
