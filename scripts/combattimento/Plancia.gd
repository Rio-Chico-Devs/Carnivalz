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

const COMANDI := ["ATTACCHI", "DIFESA", "SKILL", "OGGETTI", "FUGA"]

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
var comandi: VBoxContainer
var corpo_comandi := 18

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

	tasto_mattanza = tasto_acceso("MATTANZA", "mattanza")
	faccia_comandi.add_child(tasto_mattanza)
	tasto_bond = tasto_acceso("BOND", "bond")
	faccia_comandi.add_child(tasto_bond)

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
			dentro.y * (1.0 - Stile.quota("comandi_y")))
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

func adatta_comandi() -> void:
	# LA LISTA SI RESTRINGE QUANDO LE VOCI SONO TANTE. Le fisse sono cinque, ma
	# Aiutante e Mediazione compaiono quando ci sono: con un corpo fisso la
	# sesta voce usciva dal pannello e la settima dallo schermo.
	if comandi == null or quadrante == null:
		return
	var alto := interno_di(quadrante).size.y * (1.0 - Stile.quota("comandi_y"))
	var quante := maxi(comandi.get_child_count(), 5)
	corpo_comandi = clampi(int(alto / float(quante) * 0.62), 9, 44)
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

func mostra_comandi() -> void:
	mostra_faccia("comandi")

func mostra_faccia(quale: String) -> void:
	faccia_comandi.visible = quale == "comandi"
	faccia_lista.visible = quale == "lista"
	faccia_parlato.visible = quale == "parlato"

func aggiorna_condizione(quota_hp: float, stress: int, morale: int) -> void:
	ecg.imposta(quota_hp, stress)
	etichetta_morale.text = "Morale: %d" % morale
	etichetta_stress.text = "Stress: %d" % stress
