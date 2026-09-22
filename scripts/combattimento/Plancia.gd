class_name PlanciaCombattimento
extends RefCounted

# LA SCHERMATA DI COMBATTIMENTO COME L'HA DISEGNATA BRU.
#
# «ecco come voglio la schermata di combattimento, esattamente cosi».
#
#   ┌─────────────────┐  ┌───────┐ ┌───────┐ ┌───────┐
#   │                 │  │ slot1 │ │ slot2 │ │ slot3 │
#   │   BOX NEMICO    │  └───────┘ └───────┘ └───────┘
#   │  (il disegno)   │   HP ▬▬▬    HP ▬▬▬    HP ▬▬▬
#   │                 │   AURA ▬▬   AURA ▬▬   AURA ▬▬
#   │                 │   ﹇ ▬▬▬     ﹇ ▬▬▬     ﹇ ▬▬▬
#   │                 │      ▪          ▪          ▪
#   └─────────────────┘  ┌────────────────────────────┐
#   ┌─────────────────┐  │ ┌──────────┐  ATTACCHI     │
#   │ NOME SU ROSSO   │  │ │   ECG    │  DIFESA       │
#   │ HP: ???         │  │ └──────────┘  SKILL        │
#   └─────────────────┘  │ Morale  Stress OGGETTI     │
#                        │ [MATTANZA][BOND] FUGA      │
#                        └────────────────────────────┘
#
# NIENTE CONTENITORI, E NON E' PIGRIZIA. Un VBox o un HBox decide lui dove
# mettere le cose, e qui dove vanno le cose lo ha deciso Bru con un disegno: la
# prima versione della schermata era una colonna di contenitori, ed e' il
# motivo per cui non somigliava a niente. Ogni pannello si piazza da se' sul
# rettangolo che ha, e il rettangolo arriva dai numeri misurati sul disegno
# (data/stile.json, voce "plancia").
#
# TUTTO IN FRAZIONI. I disegni sono 1920x1080, la finestra e' quello che e', e
# la schermata deve restare quella a qualunque misura.
#
# Qui dentro non succede niente: si costruisce e basta. Chi ci scrive sopra -
# il campo, il menu, la voce - riceve i nodi e non sa dove stanno.

# quante voci ci stanno in una colonna della lista prima di aprirne un'altra.
# E' un tetto, non una promessa: se nella banda sopra MATTANZA e BOND non ce ne
# stanno cinque leggibili, ne entrano meno (vedi adatta_lista)
const RIGHE_LISTA := 5
const COLONNE_LISTA := 3
# sotto i nove punti una voce non si legge piu'; sopra i trentaquattro una lista
# corta diventa un cartellone
const CORPO_MINIMO := 9
const CORPO_MASSIMO := 34

var radice: Control

# quello che serve a chi ci lavora sopra
var box_nemico: Control          # il riquadro grande col disegno della creatura
var posto_nemico: HBoxContainer  # dove il campo mette la creatura
var scheda_nemico: Control       # nome su fascia rossa + quello che hai studiato
var fascia_nome: Label
var righe_studio: VBoxContainer
var slot: Array[SlotCompagno] = []   # i tre della squadra, gia' al loro posto
var quadrante: Control           # il pannello in basso a destra
var faccia_comandi: Control
var faccia_lista: Control
var faccia_parlato: Control
var fondale_ecg: ColorRect
var ecg: TracciatoEcg
var etichetta_morale: Label
var etichetta_stress: Label
var tasto_mattanza: Button
var tasto_bond: Button
var strato_tasselli: Control     # MATTANZA e BOND, sopra tutte le facce
var comandi: VBoxContainer
var griglia_lista: Control   # le voci di attacchi, skill, oggetti
var colonne_lista := 1       # quante ne ha adesso: lo decide adatta_lista
var pagina_lista := 0        # quale pagina di una lista troppo lunga
var tasto_altro: Button      # "Altro ▸": compare solo se non ci stanno tutte
var corpo_comandi := 18
# quali numeri stanno gia' scritti: per non riscriverli a ogni fotogramma
var faccia_adesso := ""   # quale delle tre e' in mostra adesso
# CHI STA PULSANDO ADESSO, e il suo battito. Uno alla volta: due pezzi che
# lampeggiano insieme non indicano niente, indicano "guarda lo schermo"
var evidenziato: CanvasItem = null
var alone_evidenza: Bagliore = null
var stress_scritto := -1
var morale_scritto := -1

func costruisci(dentro: Control) -> void:
	radice = dentro
	radice.resized.connect(ridisponi)
	# IL RIQUADRO DEL NEMICO E' NERO DENTRO, non bianco: nel disegno di Bru la
	# creatura sta su un fondo nero, ed e' l'unico pannello della schermata che
	# non e' bianco. Ha senso: gli altri contengono testo, questo contiene un
	# disegno.
	box_nemico = pannello("sfondo")
	# SUL NEMICO SI CLICCA, ed e' il colpo normale. Il riquadro grande e' il
	# bersaglio: un pannello che ignora il mouse lascerebbe passare il click
	# attraverso, e il modo piu' diretto di picchiare sparirebbe.
	box_nemico.mouse_filter = Control.MOUSE_FILTER_STOP
	box_nemico.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	posto_nemico = HBoxContainer.new()
	posto_nemico.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	posto_nemico.alignment = BoxContainer.ALIGNMENT_CENTER
	posto_nemico.mouse_filter = Control.MOUSE_FILTER_PASS
	interno_di(box_nemico).add_child(posto_nemico)

	scheda_nemico = costruisci_scheda_nemico()
	for i in 3:
		var uno := SlotCompagno.new()
		uno.visible = false   # uno slot vuoto non si disegna: nel party puoi essere in due
		radice.add_child(uno)
		slot.append(uno)
	quadrante = costruisci_quadrante()
	ridisponi()

# --- i mattoni ---------------------------------------------------------------

func pannello(tinta_dentro := "plancia_pannello") -> Control:
	# UN PANNELLO E' UN BORDO NERO SPESSO CON DENTRO IL BIANCO. E' lo stesso
	# linguaggio della schermata di dialogo, ed e' quello che tiene insieme le
	# due schermate: sono lo stesso gioco visto da due stanze diverse.
	var fuori := Control.new()
	fuori.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var nero := ColorRect.new()
	nero.color = Stile.colore("bordo")
	nero.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	nero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fuori.add_child(nero)
	var margini := MarginContainer.new()
	margini.name = "Dentro"
	margini.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margini.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var spessore := Stile.forma("bordo_plancia")
	for lato in ["left", "right", "top", "bottom"]:
		margini.add_theme_constant_override("margin_" + lato, spessore)
	fuori.add_child(margini)
	var bianco := ColorRect.new()
	bianco.color = Stile.colore(tinta_dentro)
	bianco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margini.add_child(bianco)
	radice.add_child(fuori)
	return fuori

func interno_di(pannello_nodo: Control) -> Control:
	return pannello_nodo.get_node("Dentro")

func costruisci_scheda_nemico() -> Control:
	# «nel box del boss ci vanno le info che si scoprono con lo studio». Il nome
	# sta su una fascia rossa, e sotto - su bianco - quello che sai. All'inizio
	# non sai niente, e infatti c'e' scritto "HP: ???" col punto interrogativo
	# rosso.
	var fuori := pannello()
	var colonna := VBoxContainer.new()
	colonna.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	colonna.add_theme_constant_override("separation", 0)
	colonna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	interno_di(fuori).add_child(colonna)

	var fascia := PanelContainer.new()
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Stile.colore("fascia_nemico")
	fascia.add_theme_stylebox_override("panel", fondo)
	fascia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	colonna.add_child(fascia)
	fascia_nome = Label.new()
	fascia_nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fascia_nome.add_theme_color_override("font_color", Stile.colore("testo"))
	fascia.add_child(fascia_nome)

	var corpo := MarginContainer.new()
	corpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for lato in ["left", "right", "top", "bottom"]:
		corpo.add_theme_constant_override("margin_" + lato, 8)
	colonna.add_child(corpo)
	righe_studio = VBoxContainer.new()
	righe_studio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	corpo.add_child(righe_studio)
	return fuori

func costruisci_quadrante() -> Control:
	var fuori := pannello()
	var dentro := interno_di(fuori)

	faccia_comandi = Control.new()
	faccia_comandi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia_comandi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dentro.add_child(faccia_comandi)

	# L'ECG STA DENTRO UN RIQUADRO SCURO. Nel disegno e' un rettangolo
	# grigio-bruno col bordo nero, e la linea ci corre dentro: sul bianco del
	# pannello una linea gialla non si leggerebbe.
	fondale_ecg = ColorRect.new()
	fondale_ecg.color = Stile.colore("ecg_fondo")
	fondale_ecg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	faccia_comandi.add_child(fondale_ecg)
	ecg = TracciatoEcg.new()
	faccia_comandi.add_child(ecg)

	etichetta_morale = Label.new()
	etichetta_morale.add_theme_color_override("font_color", Stile.colore("box_testo"))
	faccia_comandi.add_child(etichetta_morale)
	etichetta_stress = Label.new()
	etichetta_stress.add_theme_color_override("font_color", Stile.colore("box_testo"))
	faccia_comandi.add_child(etichetta_stress)

	# I DUE TASSELLI NON STANNO DENTRO UNA FACCIA SOLA.
	#
	# Sono l'unico avviso che il giocatore riceve quando la Mattanza o il Bond
	# diventano pronti. Se vivono dentro la faccia dei comandi, spariscono
	# proprio mentre scegli un attacco da una lista - cioe' nei secondi in cui
	# stai guardando altrove e il segnale arriva. Stanno un gradino piu' su, e
	# li nasconde solo il parlato: mentre il box racconta non stai scegliendo
	# niente, e sotto ci passa il testo.
	# NON DENTRO IL CONTENITORE: "Dentro" e' un MarginContainer, e un contenitore
	# riposiziona e ridimensiona i suoi figli. Appesi li', i due tasselli si sono
	# presi tutto il pannello - un rettangolo nero con BOND in mezzo, e l'ECG e i
	# comandi scomparsi sotto. Ci vuole uno strato semplice in mezzo: il
	# contenitore stira LUI, e i tasselli dentro restano dove li metti.
	strato_tasselli = Control.new()
	strato_tasselli.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dentro.add_child(strato_tasselli)
	tasto_mattanza = tasto_acceso("MATTANZA", "mattanza")
	strato_tasselli.add_child(tasto_mattanza)
	tasto_bond = tasto_acceso("BOND", "bond")
	strato_tasselli.add_child(tasto_bond)

	# LA LISTA DEI COMANDI LA RIEMPIE IL MENU, non la plancia. Qui c'e' solo il
	# posto dove va: quali voci ci stanno dentro lo decide lo scontro (Aiutante
	# e Mediazione compaiono e spariscono), e due elenchi della stessa cosa in
	# due file diversi prima o poi dicono due cose diverse.
	comandi = VBoxContainer.new()
	comandi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	faccia_comandi.add_child(comandi)

	faccia_lista = Control.new()
	faccia_lista.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia_lista.visible = false
	dentro.add_child(faccia_lista)
	# LE VOCI DI UN COMANDO CHE NE HA UNA. Nel secondo disegno di Bru il
	# quadrante si riempie di voci su piu' colonne: gli attacchi, le skill, gli
	# oggetti. Quante colonne lo decide quante ne sono (vedi adatta_lista).
	#
	# E NON E' UN GridContainer, per lo stesso motivo per cui qui non c'e'
	# nessun contenitore (vedi in cima al file). Un contenitore non scende mai
	# sotto la misura minima dei suoi figli, e quella misura Godot la ricalcola
	# al fotogramma dopo: gli si chiedevano 122 pixel di altezza e se ne
	# prendeva 242, cioe' le ultime voci finivano sotto MATTANZA e BOND. Tenerle
	# dentro si poteva fare solo litigando col contenitore a ogni voce
	# aggiunta. Qui le voci si piazzano a mano, come tutto il resto della
	# schermata, e stanno esattamente dove diciamo noi.
	griglia_lista = Control.new()
	griglia_lista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	faccia_lista.add_child(griglia_lista)

	faccia_parlato = Control.new()
	faccia_parlato.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia_parlato.visible = false
	dentro.add_child(faccia_parlato)
	return fuori

func tasto_acceso(testo: String, tinta: String) -> Button:
	# MATTANZA e BOND: «quando uno dei personaggi è pronto per legare col nemico
	# il tasto bond si illumina, quando la mattanza è pronta si illumina
	# quella». Tassello nero, scritta colorata quando e' pronto e spenta quando
	# non lo e' - non si accendono a comando, si accendono quando la cosa c'e'.
	var tasto := Button.new()
	tasto.text = testo
	tasto.focus_mode = Control.FOCUS_NONE
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Stile.colore("bordo")
	for stato in ["normal", "hover", "pressed", "disabled"]:
		tasto.add_theme_stylebox_override(stato, fondo)
	tasto.set_meta("tinta", tinta)
	accendi(tasto, false)
	return tasto

func accendi(tasto: Button, pronto: bool) -> void:
	var tinta := Stile.colore(String(tasto.get_meta("tinta", "accento"))) if pronto \
			else Stile.colore("spento")
	for stato in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
		tasto.add_theme_color_override(stato, tinta)
	tasto.disabled = not pronto

# --- la disposizione ---------------------------------------------------------

func ridisponi() -> void:
	if radice == null or radice.size.x <= 0.0 or radice.size.y <= 0.0:
		return
	var tutto := radice.size
	piazza(box_nemico, Stile.riquadro("box_nemico", tutto))
	piazza(scheda_nemico, Stile.riquadro("scheda_nemico", tutto))
	fascia_nome.add_theme_font_size_override("font_size",
			maxi(int(scheda_nemico.size.y * Stile.quota("quota_fascia") * 0.62), 10))

	var slot_largo := tutto.x * Stile.quota("slot_largo")
	var stacco := tutto.x * Stile.quota("slot_stacco")
	var slot_y := tutto.y * Stile.quota("slot_y")
	var slot_alto := tutto.y * (Stile.quota("status_y") + Stile.quota("status_lato")) - slot_y
	for i in slot.size():
		piazza(slot[i], Rect2(
				tutto.x * Stile.quota("slot_x") + float(i) * (slot_largo + stacco), slot_y,
				slot_largo, slot_alto))

	piazza(quadrante, Stile.riquadro("quadrante", tutto))
	disponi_quadrante()

func piazza(nodo: Control, dove: Rect2) -> void:
	if nodo == null:
		return
	nodo.position = dove.position
	nodo.size = dove.size

func disponi_quadrante() -> void:
	var dentro := interno_di(quadrante).size
	if dentro.x <= 0.0 or dentro.y <= 0.0:
		return
	var casa_ecg := riquadro_dentro("ecg", dentro)
	piazza(fondale_ecg, casa_ecg)
	var respiro := casa_ecg.size.y * 0.12
	piazza(ecg, Rect2(casa_ecg.position + Vector2(respiro, respiro),
			casa_ecg.size - Vector2(respiro, respiro) * 2.0))
	var y_misure := dentro.y * Stile.quota("misure_y")
	var corpo := maxi(int(dentro.y * 0.11), 10)
	etichetta_morale.position = Vector2(dentro.x * 0.036, y_misure)
	etichetta_stress.position = Vector2(dentro.x * 0.30, y_misure)
	for etichetta in [etichetta_morale, etichetta_stress]:
		etichetta.add_theme_font_size_override("font_size", corpo)
	piazza(tasto_mattanza, riquadro_dentro("mattanza", dentro))
	piazza(tasto_bond, riquadro_dentro("bond", dentro))
	for tasto in [tasto_mattanza, tasto_bond]:
		tasto.add_theme_font_size_override("font_size", maxi(int(tasto.size.y * 0.52), 10))
	comandi.position = Vector2(dentro.x * Stile.quota("comandi_x"), dentro.y * Stile.quota("comandi_y"))
	comandi.size = Vector2(dentro.x * (1.0 - Stile.quota("comandi_x")) - 8.0,
			dentro.y * (1.0 - Stile.quota("comandi_y") * 2.0))
	adatta_comandi()

func riquadro_dentro(nome: String, dentro: Vector2) -> Rect2:
	return Stile.riquadro(nome, dentro)

# --- quello che ci scrive sopra ----------------------------------------------

func primo_comando_utile() -> Button:
	for voce in comandi.get_children():
		if voce is Button and not (voce as Button).disabled:
			return voce
	return null

func dai_il_fuoco() -> void:
	# QUANDO IL MENU SI ACCENDE, il fuoco va sulla prima voce che si puo' usare:
	# se non ci va, premere una freccia non fa niente e da fuori sembra che la
	# tastiera non funzioni affatto.
	var primo := primo_comando_utile()
	if primo != null:
		primo.grab_focus()

func corpo_che_ci_sta(campione: Control, alto_riga: float) -> int:
	# QUANTO PUO' ESSERE GRANDE IL TESTO PER STARE IN UNA RIGA ALTA COSI'.
	#
	# Non si ricava da una proporzione scritta a mano, e ci abbiamo sbattuto la
	# testa: quanto e' alta una riga di testo lo decide IL FONT, non il numero
	# che gli chiediamo. Misurato qui dentro: il font di sistema rende 2 pixel
	# per ogni punto di corpo, quello di ripiego - che e' quello che si usa
	# quando i font di sistema non ci sono, cioe' in tutte le prove - ne rende
	# 3. Con un rapporto fisso le voci stavano dentro con un font e sbordavano
	# sui tasselli con l'altro, e i .ttf che Bru deve ancora disegnare avrebbero
	# fatto un numero loro ancora.
	#
	# Si chiede al font e basta.
	if campione == null:
		return CORPO_MINIMO
	var font := campione.get_theme_font("font")
	if font == null:
		return CORPO_MINIMO
	var corpo := CORPO_MASSIMO
	while corpo > CORPO_MINIMO and font.get_height(corpo) > alto_riga:
		corpo -= 1
	return corpo

func alto_riga_minima(campione: Control) -> float:
	# quanto occupa una riga scritta col corpo piu' piccolo che accettiamo: e'
	# il numero che dice quante voci ci stanno davvero in una banda
	if campione == null:
		return float(CORPO_MINIMO)
	var font := campione.get_theme_font("font")
	return font.get_height(CORPO_MINIMO) if font != null else float(CORPO_MINIMO)

func vesti_le_voci() -> void:
	# il menu ha finito di riempire: si rimettono in riga quelle del pannello che
	# sta in mostra, che e' l'unico che ha voci dentro
	if faccia_adesso == "lista":
		adatta_lista()
	else:
		adatta_comandi()

func adatta_comandi() -> void:
	# LA LISTA SI RESTRINGE QUANDO LE VOCI SONO TANTE. Le fisse sono cinque, ma
	# Aiutante e Mediazione compaiono quando ci sono: con un corpo fisso la
	# sesta voce usciva dal pannello e la settima dallo schermo.
	if comandi == null or quadrante == null:
		return
	# LO STESSO RESPIRO SOPRA E SOTTO. La colonna partiva sotto il bordo e
	# arrivava ESATTAMENTE al bordo di sotto: l'ultima voce - FUGA - restava
	# tagliata a meta' dal bordo nero del pannello. Si vedeva nello scatto e
	# nessuna prova la misurava.
	var quota := Stile.quota("comandi_y")
	var alto := interno_di(quadrante).size.y * (1.0 - quota * 2.0)
	var quante := maxi(comandi.get_child_count(), 5)
	# STESSO CONTO DELLA LISTA, e per lo stesso motivo: quanto occupa una riga
	# lo dice il font, non una proporzione scritta a mano. Qui il difetto non si
	# vedeva perche' i comandi sono cinque e lo spazio abbonda - ma con
	# Aiutante e Mediazione in campo diventano sette, ed era la stessa trappola
	# che ha fatto uscire le voci della lista dal pannello.
	var campione := comandi.get_child(0) as Control if comandi.get_child_count() > 0 else null
	var per_riga := alto / float(quante)
	corpo_comandi = corpo_che_ci_sta(campione, per_riga) if campione != null \
			else clampi(int(per_riga * 0.62), CORPO_MINIMO, CORPO_MASSIMO)
	comandi.add_theme_constant_override("separation", maxi(int(corpo_comandi * 0.12), 0))
	for voce in comandi.get_children():
		if voce is Control:
			vesti_comando(voce as Control)

func vesti_comando(voce: Control) -> void:
	# UNA VOCE DEL MENU COME NEL DISEGNO: nera, grande, allineata a sinistra e
	# senza nessuna cornice. Nel disegno di Bru ATTACCHI DIFESA SKILL OGGETTI
	# FUGA sono scritte sul bianco, non bottoni - e un bottone che sembra un
	# bottone qui dentro spezzerebbe il pannello in cinque scatolette.
	if not (voce is Button):
		return
	var tasto := voce as Button
	tasto.flat = true
	# SI GIOCA ANCHE DA TASTIERA. Prima ogni voce aveva il fuoco spento: il menu
	# di combattimento si poteva usare SOLO col mouse, e in uno scontro in tempo
	# reale spostare la mano sul mouse per ogni battuta e' una tassa. Adesso le
	# frecce scorrono le voci e INVIO sceglie - e chi il mouse non lo puo' usare
	# bene puo' giocare.
	tasto.focus_mode = Control.FOCUS_ALL
	tasto.alignment = HORIZONTAL_ALIGNMENT_LEFT
	tasto.custom_minimum_size = Vector2(0, 0)
	tasto.add_theme_font_size_override("font_size", corpo_comandi)
	tasto.add_theme_color_override("font_color", Stile.colore("box_testo"))
	tasto.add_theme_color_override("font_hover_color", Stile.colore("accento"))
	tasto.add_theme_color_override("font_pressed_color", Stile.colore("accento"))
	tasto.add_theme_color_override("font_disabled_color", Stile.colore("comando_spento"))
	# E ANCHE QUELLO DEL FUOCO. Manca questo e la voce selezionata da tastiera
	# sparisce: Godot per un bottone che ha il fuoco usa font_focus_color, che
	# viene dal tema generale - fatto per il fondo scuro del resto del gioco, e
	# qui il fondo e' bianco. Si vedeva solo la barretta rossa a sinistra, e la
	# parola ATTACCHI non c'era piu'.
	tasto.add_theme_color_override("font_focus_color", Stile.colore("box_testo"))
	for stato in ["normal", "hover", "pressed", "disabled"]:
		tasto.add_theme_stylebox_override(stato, StyleBoxEmpty.new())
	# IL FUOCO SI DEVE VEDERE, e non puo' essere solo un cambio di colore del
	# testo: sarebbe la stessa cosa che gia' fa il passaggio del mouse. E' una
	# barretta accesa a sinistra della voce - una forma, che si vede anche da
	# chi i colori non li distingue.
	# SOLO LA BARRETTA, NIENTE RIQUADRO. Il primo tentativo dipingeva anche il
	# fondo della voce col fuoco: il riquadro finiva sopra la scritta e la voce
	# spariva - ATTACCHI diventava un trattino rosso e basta. Qui il fondo e'
	# trasparente e i margini sono dichiarati tutti, cosi' Godot non ci mette i
	# suoi: resta un segno a sinistra, che e' una forma e non un colore.
	var segno := StyleBoxFlat.new()
	segno.bg_color = Color(0, 0, 0, 0)
	segno.border_color = Stile.colore("accento")
	segno.border_width_left = maxi(int(corpo_comandi * 0.22), 3)
	segno.content_margin_left = 0.0
	segno.content_margin_right = 0.0
	segno.content_margin_top = 0.0
	segno.content_margin_bottom = 0.0
	tasto.add_theme_stylebox_override("focus", segno)

func ospita_box(box: Control) -> void:
	# il box del testo viene dalla scena e va a vivere dentro il quadrante: e'
	# la faccia che parla
	if box == null:
		return
	if box.get_parent() != null:
		box.get_parent().remove_child(box)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia_parlato.add_child(box)

func pannello_per_menu(modo: String) -> Control:
	# IL MENU NON SA IN CHE PANNELLO STA, e non deve saperlo: chiede "mi serve
	# il posto per i comandi" oppure "per una lista", e riceve il contenitore
	# giusto con la sua faccia gia' aperta.
	#
	# Bru: «se premi su attacco vedi una lista degli attacchi disponibili,
	# stessa cosa le skill [...] per oggetti invece la lista di oggetti
	# utilizzabili». La colonna verticale e la griglia sono due posti diversi
	# dello stesso rettangolo.
	if modo == "comandi":
		mostra_faccia("comandi")
		return comandi
	mostra_faccia("lista")
	return griglia_lista

func adatta_lista() -> void:
	# QUANTE COLONNE, E QUANTO GRANDI. Una lista di tre voci su tre colonne
	# sarebbe una riga sola sperduta in mezzo al pannello; una di venti su una
	# colonna uscirebbe di sotto. Si riempie per colonne, fino a tre.
	if griglia_lista == null or quadrante == null:
		return
	var quante := griglia_lista.get_child_count()
	if quante == 0:
		# il menu ha appena svuotato: si riparte dalla prima pagina
		pagina_lista = 0
		if tasto_altro != null:
			tasto_altro.visible = false
		return
	var dentro := interno_di(quadrante).size
	if dentro.x <= 0.0 or dentro.y <= 0.0:
		return
	var margine := float(maxi(int(dentro.y * 0.07), 2))
	# LA LISTA SI FERMA DOVE COMINCIANO MATTANZA E BOND.
	#
	# I due tasselli stanno sopra tutte le facce apposta - sono l'unico avviso
	# che arriva, e non devono sparire proprio mentre scegli da una lista. Ma
	# "sopra" voleva dire anche SOPRA LE VOCI: la lista si prendeva tutto il
	# pannello e le ultime finivano sotto i tasselli, illeggibili e non
	# cliccabili. Con SKILL l'ultima voce e' "Indietro" - cioe' l'unico modo di
	# uscire dalla lista, coperto da un tassello nero. Lo ha trovato uno scatto,
	# non una prova.
	#
	# I tasselli sono il punto fermo, la lista e' quella che cambia: si stringe
	# lei. Il numero non e' scritto qui - viene da dove stanno davvero
	# (data/stile.json), cosi' se un giorno i tasselli si spostano la lista li
	# segue da sola.
	var alto := maxf(riquadro_dentro("mattanza", dentro).position.y - margine * 2.0,
			dentro.y * 0.25)
	var largo := dentro.x - margine * 2.0
	griglia_lista.position = Vector2(margine, margine)
	griglia_lista.size = Vector2(largo, alto)
	var distacco := maxf(alto * 0.03, 2.0)

	# QUANTE RIGHE CI STANNO DAVVERO. Non RIGHE_LISTA per decreto: quante ne
	# entrano nella banda scrivendole col corpo piu' piccolo che accettiamo. A
	# 720p col font di ripiego sono quattro, non cinque - e cinque righe finte
	# sono esattamente il modo in cui l'ultima voce finisce fuori.
	var campione := griglia_lista.get_child(0) as Control
	var minima := alto_riga_minima(campione)
	var righe_utili := clampi(int((alto + distacco) / (minima + distacco)), 1, RIGHE_LISTA)
	var capienza := righe_utili * COLONNE_LISTA

	# SE NON CI STANNO TUTTE, SI VOLTA PAGINA - non si nascondono le ultime.
	# La sacca tiene venti scomparti e i consumabili del gioco sono ventinove:
	# una lista di oggetti puo' benissimo essere piu' lunga di quello che il
	# quadrante regge. Meglio una voce in piu' che dice "ce n'e' dell'altro" che
	# tre oggetti spariti senza dirlo.
	var a_pagine := quante > capienza
	var per_pagina := (capienza - 1) if a_pagine else quante
	var pagine := int(ceil(float(quante) / float(maxi(per_pagina, 1))))
	pagina_lista = wrapi(pagina_lista, 0, maxi(pagine, 1))
	var da := pagina_lista * per_pagina
	var a := mini(da + per_pagina, quante)
	var mostrate := a - da
	var celle := mostrate + (1 if a_pagine else 0)

	colonne_lista = clampi(int(ceil(float(celle) / float(righe_utili))), 1, COLONNE_LISTA)
	var righe := maxi(int(ceil(float(celle) / float(colonne_lista))), 1)
	var per_riga := (alto - distacco * float(righe - 1)) / float(righe)
	var per_colonna := largo / float(colonne_lista)
	var corpo := corpo_che_ci_sta(campione, per_riga)

	var posto := 0
	for i in quante:
		var voce := griglia_lista.get_child(i) as Control
		if voce == null:
			continue
		voce.visible = i >= da and i < a
		if not voce.visible:
			continue
		vesti_voce_di_lista(voce, posto, righe, per_riga, per_colonna, distacco, corpo, margine)
		posto += 1

	prepara_tasto_altro(a_pagine, pagina_lista + 1, pagine)
	if a_pagine:
		vesti_voce_di_lista(tasto_altro, posto, righe, per_riga, per_colonna,
				distacco, corpo, margine)
		# "Altro" NON E' FIGLIO DELLA GRIGLIA, quindi le sue coordinate partono
		# da un altro angolo: vive nella faccia, la griglia sta piu' dentro. Con
		# la sola posizione della cella finiva mezzo margine piu' su e piu' a
		# sinistra - cioe' addosso all'ultima voce.
		tasto_altro.position += griglia_lista.position

func vesti_voce_di_lista(voce: Control, posto: int, righe: int, per_riga: float,
		per_colonna: float, distacco: float, corpo: int, margine: float) -> void:
	vesti_comando(voce)
	if voce is Button:
		(voce as Button).add_theme_font_size_override("font_size", corpo)
	# LA MISURA MINIMA VA DETTA, non lasciata a quella che c'era. Il menu da' a
	# ogni voce 44 pixel di altezza minima - giusti per la colonna dei comandi,
	# troppi per una lista: un Control non scende mai sotto il proprio minimo, e
	# l'ultima voce restava alta 44 e sbordava sui tasselli anche dopo averle
	# assegnato l'altezza giusta.
	voce.custom_minimum_size = Vector2(0, per_riga)
	# SI RIEMPIE PER COLONNE, non per righe: una lista si legge dall'alto in
	# basso, e "Indietro" - che e' sempre l'ultima - deve stare in fondo a una
	# colonna, non sparsa in mezzo alla prima riga
	var colonna := posto / righe
	var riga := posto % righe
	voce.position = Vector2(float(colonna) * per_colonna,
			float(riga) * (per_riga + distacco))
	voce.size = Vector2(per_colonna - margine, per_riga)

func prepara_tasto_altro(serve: bool, quale: int, quante_pagine: int) -> void:
	# LA VOCE CHE NON VIENE DAL MENU. Le altre le mette lo scontro; questa la
	# mette la schermata, perche' e' la schermata a sapere quanto ci sta. Vive
	# fuori dalla griglia apposta: dentro sarebbe una voce da contare, e il
	# conto delle voci e' quello che decide se serve.
	if not serve:
		if tasto_altro != null:
			tasto_altro.visible = false
		return
	if tasto_altro == null:
		tasto_altro = Button.new()
		tasto_altro.pressed.connect(func() -> void:
			pagina_lista += 1
			adatta_lista())
		faccia_lista.add_child(tasto_altro)
	tasto_altro.text = "Altro  (%d/%d)  \u25b8" % [quale, quante_pagine]
	tasto_altro.visible = true

static func faccia_da_mostrare(puoi_agire: bool, da_leggere: bool, modo_menu: String) -> String:
	# CHI SI PRENDE IL QUADRANTE, IN UNA REGOLA SOLA.
	#
	# Il pannello fa tre mestieri e ne puo' mostrare uno per volta. Chi decide
	# non puo' essere ne' il menu ne' il box: lo vogliono tutti e due e nessuno
	# dei due sa cosa sta facendo l'altro. Il primo tentativo dava al racconto un
	# lucchetto sulla faccia, e bastava una ricarica che finiva nel momento
	# sbagliato per restare chiusi fuori dal proprio turno.
	#
	#   puoi agire      -> IL MENU, sempre. Un menu nascosto non si vede e non
	#                      prende il fuoco da tastiera: tenerlo sotto una frase
	#                      non e' una scelta di stile, e' toglierti il turno.
	#   c'e' da leggere -> IL BOX. Bru: «il suo dialogo appare dove mettiamo i
	#                      minigiochi e cosi' anche quelli dei nemici e
	#                      protagonisti piu' la narrazione del combattimento».
	#                      Mentre ricarichi non stai scegliendo niente, ed e'
	#                      quasi tutto il tempo.
	#   altrimenti      -> il menu, spento.
	if puoi_agire:
		return modo_menu
	return "parlato" if da_leggere else modo_menu

func mostra_faccia(quale: String) -> void:
	if quale == faccia_adesso:
		return
	faccia_adesso = quale
	faccia_comandi.visible = quale == "comandi"
	faccia_lista.visible = quale == "lista"
	faccia_parlato.visible = quale == "parlato"
	# i due tasselli seguono TUTTE le facce tranne il parlato (vedi sopra)
	var si_vedono := quale != "parlato"
	if tasto_mattanza != null:
		tasto_mattanza.visible = si_vedono
	if tasto_bond != null:
		tasto_bond.visible = si_vedono

func aggiorna_condizione(quota_hp: float, stress: int, morale: int) -> void:
	# QUELLO CHE SI LEGGE E' LA CONDIZIONE DI CHI HA IL TURNO. L'ECG, il morale
	# e lo stress sono uno solo mentre i personaggi sono tre: e' il cuore di chi
	# sta per muoversi, ed e' il motivo per cui il suo slot deve essere marcato.
	#
	# SI SCRIVE SOLO QUANDO CAMBIA: queste due etichette venivano aggiornate a
	# ogni fotogramma, e riscrivere il testo di una Label rifa' la disposizione
	# anche quando il numero e' identico.
	ecg.imposta(quota_hp, stress)
	if stress != stress_scritto:
		stress_scritto = stress
		etichetta_stress.text = "Stress: %d" % stress
	if morale != morale_scritto:
		morale_scritto = morale
		etichetta_morale.text = "Morale: %d" % morale

# --- indicare un pezzo dello schermo ----------------------------------------
#
# Bru: «bisogna rendere piu' accattivante la segnalazione degli elementi
# dell'interfaccia evidenziandoli con animazioni».
#
# Una battuta del tutorial puo' dire QUALE pezzo sta nominando, e quel pezzo
# pulsa finche' si parla di lui. Non e' decorazione: e' la differenza fra "le
# barre, dall'alto: HP e' quanto reggi" letto nel vuoto, e la stessa frase con
# la barra che batte sotto gli occhi. Chi legge non deve cercare.

func pezzo(nome: String) -> CanvasItem:
	# il nome che si scrive nei dati -> il nodo che pulsa. Sta qui e non nel
	# motore: e' la plancia a sapere com'e' fatta
	match nome:
		"nemico": return box_nemico
		"scheda": return scheda_nemico
		"squadra": return slot[0] if not slot.is_empty() else null
		"ecg": return fondale_ecg
		"morale": return etichetta_morale
		"stress": return etichetta_stress
		"mattanza": return tasto_mattanza
		"bond": return tasto_bond
		"menu": return faccia_comandi
	return null

func evidenzia_pezzo(nome: String) -> void:
	spegni_evidenza()
	if nome == "":
		return
	var nodo := pezzo(nome)
	if nodo == null or not is_instance_valid(nodo):
		# UN NOME SBAGLIATO NEI DATI DEVE DIRLO. Un'evidenziazione che non si
		# vede e' indistinguibile da una che non e' stata chiesta, e chi scrive
		# i dialoghi non ha modo di accorgersene se non guardando
		push_error("Plancia: la battuta chiede di evidenziare '%s', che non e' un pezzo dello schermo" % nome)
		return
	evidenziato = nodo
	# l'alone sta INTORNO, non sopra: il perche' sta in Bagliore.gd
	if nodo is Control:
		alone_evidenza = Bagliore.intorno_a(nodo as Control, Stile.colore("accento"))
		alone_evidenza.respira()

func spegni_evidenza() -> void:
	if alone_evidenza != null and is_instance_valid(alone_evidenza):
		alone_evidenza.ferma()
		alone_evidenza.queue_free()
	alone_evidenza = null
	evidenziato = null   # modulate non lo tocca piu' nessuno: niente da rimettere
