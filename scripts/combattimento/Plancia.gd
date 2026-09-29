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
var fondale_ecg: Panel
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
var alone_evidenza: Evidenza = null                  # a scontro aperto: la cornice
var indicazione: IndicazioneCombattimento = null     # a lezione (Indicazione.gd)
var box_testo: Control = null
var stress_scritto := -1
var morale_scritto := -1

func costruisci(dentro: Control) -> void:
	radice = dentro
	radice.resized.connect(ridisponi)
	# IL FONDO E' IL MANIFESTO (Manifesto.Trama): l'arancio, gli anelli, il retino.
	# Il riquadro del nemico e' lo schermo di un cabinato, nero dentro: gli
	# altri pannelli contengono testo, questo contiene un disegno
	Manifesto.trama_dietro(radice, "sfondo_combattimento")
	box_nemico = schermo()
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
	# UN PANNELLO E' UN FOGLIO DEL MANIFESTO: grigio caldo, contorno nero spesso,
	# l'ombra piena e il retino (Manifesto.Carta). Il contenuto sta in "Dentro"
	var fuori := Control.new()
	fuori.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var carta := Manifesto.Carta.new()
	carta.tinta = Stile.colore(tinta_dentro)
	carta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fuori.add_child(carta)
	fuori.add_child(margini_dentro(Stile.forma("bordo_plancia")))
	radice.add_child(fuori)
	return fuori

func schermo() -> Control:
	# LO SCHERMO DEL CABINATO: il vetro scuro dentro la cornice chiara, e il
	# vetro davanti che ne arrotonda gli angoli anche sopra la creatura
	var fuori := Control.new()
	fuori.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var retro := Manifesto.Cabinato.new()
	retro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fuori.add_child(retro)
	var margini := margini_dentro(int(retro.bordo))
	fuori.add_child(margini)
	var vetro := ColorRect.new()
	vetro.color = Stile.colore("quadro_vuoto")
	vetro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margini.add_child(vetro)
	retro.davanti = Manifesto.Vetro.new()
	retro.color = Stile.colore("bordo_acceso")
	fuori.add_child(retro.davanti)
	retro.davanti.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lato in ["left", "top"]:
		retro.davanti.set("offset_" + lato, retro.bordo)
	for lato in ["right", "bottom"]:
		retro.davanti.set("offset_" + lato, -retro.bordo)
	radice.add_child(fuori)
	return fuori

func margini_dentro(spessore: int) -> MarginContainer:
	var margini := MarginContainer.new()
	margini.name = "Dentro"
	margini.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margini.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for lato in ["left", "right", "top", "bottom"]:
		margini.add_theme_constant_override("margin_" + lato, spessore)
	return margini

func interno_di(pannello_nodo: Control) -> Control:
	return pannello_nodo.get_node("Dentro")

func costruisci_scheda_nemico() -> Control:
	# «nel box del boss ci vanno le info che si scoprono con lo studio». Il nome
	# sta su un'etichetta nera, e sotto - sulle strisce - quello che sai.
	# All'inizio non sai niente: "HP: ???"
	var fuori := Control.new()
	fuori.mouse_filter = Control.MOUSE_FILTER_IGNORE
	radice.add_child(fuori)
	var colonna := VBoxContainer.new()
	colonna.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	colonna.add_theme_constant_override("separation", 6)
	colonna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fuori.add_child(colonna)
	fascia_nome = Label.new()
	fascia_nome.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	colonna.add_child(fascia_nome)
	# le strisce stanno un passo piu' in dentro, come le righe sotto le
	# etichette dell'immagine; chi le scrive (il campo) non sa di che colore sono
	var rientro := margini_dentro(0)
	rientro.add_theme_constant_override("margin_left", 24)
	rientro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna.add_child(rientro)
	righe_studio = VBoxContainer.new()
	righe_studio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	righe_studio.child_entered_tree.connect(func(riga: Node) -> void:
		if riga is Label:
			Manifesto.vesti_striscia(riga as Label, 16)
			(riga as Label).size_flags_horizontal = Control.SIZE_FILL if (riga as Label).autowrap_mode \
					!= TextServer.AUTOWRAP_OFF else Control.SIZE_SHRINK_BEGIN)
	rientro.add_child(righe_studio)
	return fuori

func costruisci_quadrante() -> Control:
	var fuori := pannello()
	var dentro := interno_di(fuori)

	faccia_comandi = Control.new()
	faccia_comandi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia_comandi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dentro.add_child(faccia_comandi)

	# L'ECG STA DENTRO UN VETRINO SCURO, tondo e col bordo nero: sulla carta una
	# linea gialla non si leggerebbe
	fondale_ecg = Panel.new()
	var vetrino := StyleBoxFlat.new()
	vetrino.bg_color = Stile.colore("ecg_fondo")
	vetrino.border_color = Stile.colore("bordo")
	vetrino.set_border_width_all(4)
	vetrino.set_corner_radius_all(12)
	fondale_ecg.add_theme_stylebox_override("panel", vetrino)
	fondale_ecg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	faccia_comandi.add_child(fondale_ecg)
	ecg = TracciatoEcg.new()
	faccia_comandi.add_child(ecg)

	etichetta_morale = Label.new()
	etichetta_stress = Label.new()
	for misura in [etichetta_morale, etichetta_stress]:
		misura.uppercase = true
		misura.add_theme_color_override("font_color", Stile.colore("box_testo"))
		misura.add_theme_font_override("font", Caratteri.titolo())
		faccia_comandi.add_child(misura)

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
	# quella». Una pillola nera, scritta colorata quando e' pronto e spenta
	# quando non lo e' - si accendono quando la cosa c'e', non a comando.
	var tasto := Button.new()
	tasto.text = testo
	tasto.focus_mode = Control.FOCUS_NONE
	tasto.add_theme_font_override("font", Caratteri.titolo())
	var fondo := Manifesto.stile_pillola(Stile.colore("bordo"))
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
	scrivi_nome(fascia_nome.text)

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

func scrivi_nome(testo: String) -> void:
	# IL NOME SULL'ETICHETTA, piu' piccolo finche' non ci sta: mai fuori dalla
	# scheda. Un'etichetta si stringe sul suo testo, quindi il testo non si taglia
	fascia_nome.text = testo
	var corpo := maxi(int(scheda_nemico.size.y * Stile.quota("quota_fascia")), 12)
	while corpo > 12 and Caratteri.titolo().get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x \
			+ corpo * 1.3 > scheda_nemico.size.x:
		corpo -= 2
	Manifesto.vesti_etichetta(fascia_nome, corpo)

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
	corpo_comandi = corpo_che_ci_sta_in_largo(corpo_comandi)
	comandi.add_theme_constant_override("separation", maxi(int(corpo_comandi * 0.12), 0))
	for voce in comandi.get_children():
		if voce is Control:
			vesti_comando(voce as Control)

func corpo_che_ci_sta_in_largo(corpo: int) -> int:
	# E IN LARGO: la voce piu' lunga, col triangolo davanti, dentro la colonna
	for voce in comandi.get_children():
		while voce is Button and corpo > CORPO_MINIMO and Caratteri.titolo().get_string_size(
				(voce as Button).text, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo * 1.6 > comandi.size.x:
			corpo -= 1
	return corpo

func vesti_comando(voce: Control) -> void:
	# UNA VOCE DEL MENU, scritta sulla carta del quadrante: nera, e quella col
	# fuoco sull'etichetta (Manifesto.vesti_voce)
	if voce is Button:
		Manifesto.vesti_voce(voce as Button, corpo_comandi)

func ospita_box(box: Control) -> void:
	# il box del testo viene dalla scena e va a vivere dentro il quadrante: e'
	# la faccia che parla
	if box == null:
		return
	if box.get_parent() != null:
		box.get_parent().remove_child(box)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia_parlato.add_child(box)
	box_testo = box

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
		(voce as Button).add_theme_font_override("font", Caratteri.voci_strette())   # le liste sono lunghe
		(voce as Button).add_theme_font_size_override("font_size", corpo)
		(voce as Button).text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS   # mai fuori dalla cella
	# LA MISURA MINIMA VA DETTA, non lasciata a quella che c'era. Il menu da' a
	# ogni voce 44 pixel di altezza minima - giusti per la colonna dei comandi,
	# troppi per una lista: un Control non scende mai sotto il proprio minimo, e
	# l'ultima voce restava alta 44 e sbordava sui tasselli anche dopo averle
	# assegnato l'altezza giusta.
	voce.custom_minimum_size = Vector2(0, per_riga)
	# SI RIEMPIE PER COLONNE, non per righe: una lista si legge dall'alto in
	# basso, e "Indietro" - che e' sempre l'ultima - deve stare in fondo a una
	# colonna, non sparsa in mezzo alla prima riga
	var colonna := floori(float(posto) / righe)
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
	if quale == "parlato" and indicazione != null and indicazione.box_prestato:
		quale = "comandi"   # il box e' sul leggio: il quadrante mostra il pezzo indicato
	if quale == faccia_adesso:
		return
	faccia_adesso = quale
	faccia_comandi.visible = quale == "comandi"
	faccia_lista.visible = quale == "lista"
	faccia_parlato.visible = quale == "parlato"
	# i tasselli stanno coi comandi e con la lista; col parlato e con la raffica no
	var si_vedono := quale == "comandi" or quale == "lista"
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
# Una battuta del tutorial dice QUALE pezzo nomina: a lezione il pezzo si scopre
# e si indica (IndicazioneCombattimento); a scontro aperto basta la cornice.

func pezzo(nome: String) -> CanvasItem:
	# il nome scritto nei dati -> il nodo: lo sa la plancia, non il motore
	var primo: SlotCompagno = slot[0] if not slot.is_empty() else null
	return {"nemico": box_nemico, "scheda": scheda_nemico, "squadra": primo, "ecg": fondale_ecg,
			"dominio": primo.barre.get("dominio") if primo != null else null, "morale": etichetta_morale,
			"stress": etichetta_stress, "mattanza": tasto_mattanza, "bond": tasto_bond, "menu": comandi}.get(nome)

func evidenzia_pezzo(nomi: String, a_lezione := false) -> void:
	# uno o piu' pezzi: "dominio,mattanza" - la barra e il tasto che accende
	spegni_evidenza()
	var nodi: Array[Control] = []
	for nome in nomi.split(",", false):
		var nodo := pezzo(nome.strip_edges())
		if nodo == null or not is_instance_valid(nodo):
			# UN NOME SBAGLIATO NEI DATI DEVE DIRLO: se no non si vede e basta
			push_error("Plancia: la battuta chiede di evidenziare '%s', che non e' un pezzo dello schermo" % nome)
			return
		nodi.append(nodo as Control)
	if nodi.is_empty():
		return
	evidenziato = nodi[0]
	if a_lezione:
		indicazione = IndicazioneCombattimento.su(self, nodi)
	else:
		alone_evidenza = Evidenza.intorno_a(nodi[0], "cornice")
		alone_evidenza.accendi()

func spegni_evidenza() -> void:
	if alone_evidenza != null and is_instance_valid(alone_evidenza):
		alone_evidenza.ferma()
		alone_evidenza.queue_free()
	alone_evidenza = null
	if indicazione != null and is_instance_valid(indicazione):
		indicazione.togli()   # e il box torna nel quadrante
	indicazione = null
	evidenziato = null
