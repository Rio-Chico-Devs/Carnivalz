class_name PlanciaCombattimento
extends RefCounted

# LA SCHERMATA DI COMBATTIMENTO: IL MANIFESTO DI UN INCONTRO.
#
# Bru, sulla proposta (docs/scontro_proposta.md): «sì mi piace», e «sì dai» a
# portarla nel gioco. La creatura e' l'attrazione della serata, la squadra sono
# gli sfidanti, e una diagonale sola li divide (Spina.gd):
#
#   ┌───────────────────────╱  GIRO 1  (Y)▸(A)▸(M)▸(V)
#   │                      ╱ ╱┌──┐ TOCCA A TE ▬▬▬▬▬▬ 100/100
#   │      LA CREATURA    ╱ ╱ └──┘           ▬▬▬▬▬   10/10
#   │   (il cartellone)  ╱ ╱─────────────────────────────
#   │                   ╱ ╱  ┌─┐ VERONICA  ▬▬▬▬▬▬ 160/160
#   │                  ╱ ╱───────────────────────────────
#   ├──────────────── ╱ ╱  ┌─┐ YHVINA    ▬▬▬▬▬▬ 130/130
#  ╱ MARIONETTA     ╱ ╱  ───────────────────────────────
# ╱═══════════════╱ ╱ ┌─────────── ECG ──────────────┐
#  ▬▬▬▬▬▬▬▬▬▬ ???   ╱  │ MORALE 20   STRESS 0       │
#  TETRO           ╱    ATTACCHI   COSA FA
#                 ╱     DIFESA     Il colpo normale...
#                ╱      SKILL ...
#               ╱      [MATTANZA] [BOND]
#
# Ogni pezzo fa un mestiere solo, e la schermata si ricompone secondo il
# momento (mostra_faccia):
#
#   comandi, lista   il programma sale: chi decide, il suo ECG e i suoi comandi
#                    sono una colonna sola, e l'occhio scende invece di
#                    attraversare lo schermo
#   parlato          il racconto prende il posto della fascia, sotto la
#                    creatura: e' la sua didascalia. Il programma scende
#   minigioco        il programma scende, la creatura si ritira, e il
#                    minigioco si stende sul suo schermo (il palco)
#
# NIENTE CONTENITORI PER LA DISPOSIZIONE, e non e' pigrizia: un VBox decide lui
# dove mettere le cose, e qui dove vanno le cose l'ha deciso un disegno. Ogni
# pezzo si piazza da se' sul rettangolo che ha, e il rettangolo arriva dalle
# misure (data/stile.json, "plancia"), su un foglio di 1280x720 portato alla
# finestra che c'e'.
#
# Qui dentro non succede niente: si costruisce e basta. Chi ci scrive sopra -
# il campo, il menu, la voce, i minigiochi - riceve i nodi e non sa dove stanno.

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
var scala := Vector2.ONE         # quanto e' grande la finestra rispetto al foglio di 1280x720
var pendenza_px := 0.13          # la diagonale, in pixel della finestra

# quello che serve a chi ci lavora sopra
var box_nemico: CartelloneNemico  # lo schermo della creatura
var posto_nemico: HBoxContainer  # dove il campo mette la creatura
var palco: Control               # dove giocano i minigiochi: il vetro del cartellone
var scheda_nemico: FasciaNemico  # il nome sulla fascia rossa, la vita, quello che sai
var fascia_nome: Label
var posto_vita: Control          # dove il campo mette il numero della vita della creatura
var righe_studio: VBoxContainer
var slot: Array[SlotCompagno] = []   # i tre della squadra, gia' al loro posto
var quadrante: Control           # il programma: i comandi di chi decide
var programma: ProgrammaCombattimento   # chi lo costruisce e lo riempie (Programma.gd)
var foglio_programma: SpinaPlancia.FoglioSbieco
var faccia_comandi: Control
var faccia_lista: Control
var faccia_parlato: Control      # vive nella didascalia, non nel programma
var didascalia: Control          # dove si racconta: sotto la creatura, al posto della fascia
var fila: FilaDelGiro            # chi tocca dopo
var fondale_ecg: Panel
var ecg: TracciatoEcg
var etichetta_morale: Label
var etichetta_stress: Label
var tasto_mattanza: Button
var tasto_bond: Button
var strato_tasselli: Control     # MATTANZA e BOND, sopra tutte le facce
var comandi: VBoxContainer
var cosa_fa: Label               # l'etichetta «COSA FA» accanto ai comandi
var spiegazione: Label           # e le due righe su quello che stai guardando
var griglia_lista: Control   # le voci di attacchi, skill, oggetti
var zona_lista := Rect2()    # dove possono stare, nelle coordinate della faccia
var colonne_lista := 1       # quante ne ha adesso: lo decide adatta_lista
var pagina_lista := 0        # quale pagina di una lista troppo lunga
var tasto_altro: Button      # "Altro ▸": compare solo se non ci stanno tutte
var corpo_comandi := 18
var faccia_adesso := ""   # quale e' in mostra adesso
var stato_adesso := ""    # e come: la faccia, piu' se il box e' prestato a una lezione
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
	# IL FONDO E' IL MANIFESTO (Manifesto.Trama): l'arancio, gli anelli, il retino
	Manifesto.trama_dietro(radice, "sfondo_combattimento")
	box_nemico = CartelloneNemico.new()
	radice.add_child(box_nemico)
	# SUL NEMICO SI CLICCA, ed e' il colpo normale. Lo schermo grande e' il
	# bersaglio: un pannello che ignora il mouse lascerebbe passare il click
	# attraverso, e il modo piu' diretto di picchiare sparirebbe.
	box_nemico.mouse_filter = Control.MOUSE_FILTER_STOP
	box_nemico.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	posto_nemico = HBoxContainer.new()
	posto_nemico.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	posto_nemico.alignment = BoxContainer.ALIGNMENT_CENTER
	posto_nemico.mouse_filter = Control.MOUSE_FILTER_PASS
	box_nemico.dentro.add_child(posto_nemico)
	palco = box_nemico.palco

	scheda_nemico = costruisci_scheda_nemico()
	for i in 3:
		var uno := SlotCompagno.new()
		uno.visible = false   # uno slot vuoto non si disegna: nel party puoi essere in due
		radice.add_child(uno)
		slot.append(uno)
		uno.misura_cambiata.connect(disponi_schede)
	programma = ProgrammaCombattimento.new(self)
	quadrante = programma.costruisci()
	quadrante.add_child(programma)
	didascalia = Control.new()
	didascalia.name = "Didascalia"
	didascalia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	radice.add_child(didascalia)
	faccia_parlato = Control.new()
	faccia_parlato.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia_parlato.visible = false
	didascalia.add_child(faccia_parlato)
	fila = FilaDelGiro.new()
	radice.add_child(fila)
	ridisponi()

# --- i mattoni ---------------------------------------------------------------

func pannello(tinta_dentro := "plancia_pannello") -> Control:
	# UN PANNELLO E' UN FOGLIO DEL MANIFESTO: grigio caldo, contorno nero spesso,
	# l'ombra piena e il retino (Manifesto.Carta). Il contenuto sta in "Dentro".
	# Lo usa la lezione per il suo leggio (Indicazione.gd)
	var fuori := Control.new()
	fuori.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var carta := Manifesto.Carta.new()
	carta.tinta = Stile.colore(tinta_dentro)
	carta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fuori.add_child(carta)
	fuori.add_child(margini_dentro(Stile.forma("bordo_plancia")))
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

func costruisci_scheda_nemico() -> FasciaNemico:
	# «nel box del boss ci vanno le info che si scoprono con lo studio». Il nome
	# sta sulla fascia rossa, sotto la sua vita (coperta finche' non la studi), e
	# sotto ancora - sulle strisce - quello che sai
	var fuori := FasciaNemico.new()
	radice.add_child(fuori)
	fascia_nome = Label.new()
	fascia_nome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fascia_nome.uppercase = true
	fuori.add_child(fascia_nome)
	posto_vita = Control.new()
	posto_vita.mouse_filter = Control.MOUSE_FILTER_IGNORE
	posto_vita.child_entered_tree.connect(func(numero: Node) -> void:
		if numero is Label:
			vesti_vita(numero as Label))
	fuori.add_child(posto_vita)
	righe_studio = VBoxContainer.new()
	righe_studio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	righe_studio.add_theme_constant_override("separation", 6)
	# le strisce: chi le scrive (il campo) non sa di che colore sono
	righe_studio.child_entered_tree.connect(func(riga: Node) -> void:
		if riga is Label:
			vesti_striscia(riga as Label))
	fuori.add_child(righe_studio)
	return fuori

func vesti_vita(numero: Label) -> void:
	# il numero della vita accanto alla barra, sull'etichetta nera
	Manifesto.vesti_etichetta(numero, maxi(int(round(17.0 * scala.y)), 9), "testo", "bordo")

func vesti_striscia(riga: Label) -> void:
	Manifesto.vesti_striscia(riga, maxi(int(round(15.0 * scala.y)), 9))
	riga.size_flags_horizontal = Control.SIZE_FILL if riga.autowrap_mode != TextServer.AUTOWRAP_OFF \
			else Control.SIZE_SHRINK_BEGIN

func accendi(tasto: Button, pronto: bool) -> void:
	var tinta := Stile.colore(String(tasto.get_meta("tinta", "accento"))) if pronto \
			else Stile.colore("spento")
	for stato in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
		tasto.add_theme_color_override(stato, tinta)
	tasto.disabled = not pronto

# --- la disposizione ---------------------------------------------------------

func in_pixel(r: Rect2) -> Rect2:
	# un rettangolo del foglio (1280x720), sulla finestra
	return Rect2(r.position * scala, r.size * scala)

func rettangolo(nome: String) -> Rect2:
	var a: Variant = SpinaPlancia.misura(nome)
	if not (a is Array) or (a as Array).size() < 4:
		return Rect2()
	return Rect2(float(a[0]), float(a[1]), float(a[2]), float(a[3]))

func ridisponi() -> void:
	if radice == null or radice.size.x <= 0.0 or radice.size.y <= 0.0:
		return
	scala = radice.size / SpinaPlancia.FOGLIO
	pendenza_px = SpinaPlancia.pendenza() * scala.x / scala.y
	disponi_cartellone()
	disponi_fascia()
	disponi_schede()
	programma.disponi()
	disponi_didascalia()
	var alla_fila: Variant = SpinaPlancia.misura("fila")
	if alla_fila is Array and (alla_fila as Array).size() >= 2:
		piazza(fila, in_pixel(Rect2(float(alla_fila[0]), float(alla_fila[1]), 1256.0 - float(alla_fila[0]), 44.0)))
	fila.scala = scala.y
	fila.queue_redraw()

func disponi_cartellone() -> void:
	# LO SCHERMO DELLA CREATURA: da sinistra alla diagonale, il piu' grande della
	# schermata. Dentro, la creatura; sul palco, i minigiochi
	var sinistra := SpinaPlancia.numero("cartellone", "sinistra", 24.0)
	var basso := SpinaPlancia.numero("cartellone", "basso", 548.0)
	var alto := SpinaPlancia.alto()
	var cornice := SpinaPlancia.numero("cartellone", "cornice", 13.0)
	var scatola := Rect2(sinistra, alto, SpinaPlancia.diagonale(alto) - sinistra, basso - alto)
	piazza(box_nemico, in_pixel(scatola))
	box_nemico.cornice = cornice * minf(scala.x, scala.y)
	var forma := PackedVector2Array()
	for p in [Vector2(sinistra, alto), Vector2(SpinaPlancia.diagonale(alto), alto),
			Vector2(SpinaPlancia.diagonale(basso), basso), Vector2(sinistra, basso)]:
		forma.append((p - scatola.position) * scala)
	box_nemico.forma = forma
	# il rettangolo piu' grande che sta nel vetro: il lato destro e' di sbieco,
	# quindi conta quello in basso
	# e si ferma sopra la fascia col nome, che entra nello schermo: la creatura,
	# i suoi gregari e il minigioco stanno tutti li' sopra
	var aria := cornice + 10.0
	var giu := basso - aria - SpinaPlancia.numero("cartellone", "sotto_la_fascia", 52.0)
	var vetro := Rect2(sinistra + aria, alto + aria, SpinaPlancia.diagonale(giu) - aria - sinistra - aria, giu - alto - aria)
	var dentro := Rect2((vetro.position - scatola.position) * scala, vetro.size * scala)
	piazza(box_nemico.dentro, dentro)
	piazza(palco, dentro)

func disponi_fascia() -> void:
	var banda := PackedVector2Array()
	var dati: Variant = SpinaPlancia.misura("fascia")
	if dati is Array:
		for p in dati:
			banda.append(Vector2(float(p[0]), float(p[1])))
	if banda.size() < 3:
		return
	var vita := rettangolo("vita_nemico")
	var studio := rettangolo("studio")
	var scatola := Rect2(banda[0], Vector2.ZERO)
	for p in banda:
		scatola = scatola.expand(p)
	scatola = scatola.merge(vita.grow(4.0)).merge(studio)
	piazza(scheda_nemico, in_pixel(scatola))
	var locale := PackedVector2Array()
	for p in banda:
		locale.append((p - scatola.position) * scala)
	scheda_nemico.banda = locale
	scheda_nemico.barra = Rect2((vita.position - scatola.position) * scala, vita.size * scala)
	piazza(posto_vita, Rect2((Vector2(vita.end.x + 14.0, vita.position.y - 3.0) - scatola.position) * scala,
			Vector2(scatola.end.x - vita.end.x - 14.0, 26.0) * scala))
	for numero in posto_vita.get_children():
		if numero is Label:
			vesti_vita(numero as Label)
			(numero as Label).position = Vector2.ZERO
	piazza(righe_studio, Rect2((studio.position - scatola.position) * scala, studio.size * scala))
	for riga in righe_studio.get_children():
		if riga is Label:
			vesti_striscia(riga as Label)
	scrivi_nome(fascia_nome.text)

func scrivi_nome(testo: String) -> void:
	# IL NOME SULLA FASCIA ROSSA, grande come un titolo e inclinato come lei; piu'
	# piccolo finche' non ci sta: mai fuori dalla fascia. Un'etichetta si
	# stringe sul suo testo, quindi il testo non si taglia
	fascia_nome.text = testo
	var banda := scheda_nemico.banda
	if banda.size() < 4:
		return
	var largo := banda[1].x - banda[0].x - 50.0 * scala.x
	var corpo := maxi(int(round(56.0 * scala.y)), 12)
	while corpo > 12 and Caratteri.titolo().get_string_size(testo.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x > largo:
		corpo -= 2
	fascia_nome.add_theme_font_override("font", Caratteri.titolo())
	fascia_nome.add_theme_font_size_override("font_size", corpo)
	fascia_nome.add_theme_color_override("font_color", Stile.colore("testo"))
	fascia_nome.add_theme_color_override("font_shadow_color", Stile.colore("bordo"))
	fascia_nome.add_theme_constant_override("shadow_offset_x", maxi(int(4.0 * scala.y), 1))
	fascia_nome.add_theme_constant_override("shadow_offset_y", maxi(int(4.0 * scala.y), 1))
	fascia_nome.reset_size()
	# in mezzo alla fascia, alla sua pendenza
	var sopra := banda[0].lerp(banda[1], 0.04)
	var sotto := banda[3].lerp(banda[2], 0.04)
	fascia_nome.rotation = (banda[1] - banda[0]).angle()
	fascia_nome.position = sopra.lerp(sotto, 0.5) - Vector2(0.0, fascia_nome.size.y * 0.5) + Vector2(18.0 * scala.x, 0.0)

func disponi_schede() -> void:
	# LE SCHEDE SULLA DIAGONALE: una sotto l'altra, il lato sinistro a una gola
	# dal cartellone. Chi ha il turno e' piu' alta e fa un passo avanti verso la
	# creatura; gli altri restano dove sono. Si rifa' a ogni passo del turno
	if radice == null or scala.x <= 0.0:
		return
	var y := SpinaPlancia.numero("schede", "y", 78.0)
	var destra := SpinaPlancia.numero("schede", "destra", 1256.0)
	var stacco := SpinaPlancia.numero("schede", "stacco", 12.0)
	var passo := SpinaPlancia.numero("schede", "passo", 22.0)
	var pendenza := SpinaPlancia.pendenza()
	for uno in slot:
		if not uno.visible:
			continue
		uno.pendenza_px = pendenza_px
		uno.scala = scala.y
		var alta := uno.alta_per(uno.attiva)
		var x := SpinaPlancia.diagonale(y, SpinaPlancia.gola()) - (0.0 if uno.libero else passo * uno.attiva)
		var sinistra := x - pendenza * alta
		piazza(uno, in_pixel(Rect2(sinistra, y, destra - sinistra, alta)))
		y += alta + stacco

func rettangolo_programma() -> Rect2:
	# il rettangolo del foglio del programma che sta tutto dentro la carta: il
	# lato sinistro in alto (sotto la carta si allarga). Sul foglio 1280x720
	var alto := SpinaPlancia.numero("programma", "alto", 400.0)
	var basso := SpinaPlancia.numero("programma", "basso", 704.0)
	var x := SpinaPlancia.diagonale(alto, SpinaPlancia.gola())
	return Rect2(x, alto, SpinaPlancia.numero("programma", "destra", 1256.0) - x, basso - alto)

func disponi_didascalia() -> void:
	# IL RACCONTO prende il posto della fascia, sotto la creatura: largo quanto
	# il cartellone, col lato destro sulla diagonale
	var alto := SpinaPlancia.numero("didascalia", "alto", 512.0)
	var basso := SpinaPlancia.numero("didascalia", "basso", 712.0)
	var sinistra := SpinaPlancia.numero("didascalia", "sinistra", 16.0)
	var dove := in_pixel(Rect2(sinistra, alto, SpinaPlancia.diagonale(basso) - 6.0 - sinistra, basso - alto))
	# IL BOX NON SI SCHIACCIA: e' alto quello che e' (BoxTesto.imposta_altezza),
	# e se la finestra e' piccola - o il testo e' grande - la didascalia sale
	# quanto serve invece di farlo sbordare sotto lo schermo
	if box_testo != null:
		var serve := box_testo.get_combined_minimum_size().y
		if serve > dove.size.y:
			dove = Rect2(dove.position - Vector2(0.0, serve - dove.size.y), Vector2(dove.size.x, serve))
	piazza(didascalia, dove)

func piazza(nodo: Control, dove: Rect2) -> void:
	if nodo == null:
		return
	nodo.position = dove.position
	nodo.size = dove.size

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
	programma.adatta_comandi()

func adatta_lista() -> void:
	programma.adatta_lista()

func vesti_le_voci() -> void:
	# il menu ha finito di riempire: si rimettono in riga quelle del pannello che
	# sta in mostra, che e' l'unico che ha voci dentro
	if faccia_adesso == "lista":
		adatta_lista()
	else:
		adatta_comandi()

func ospita_box(box: Control) -> void:
	# il box del testo viene dalla scena e va a vivere nella didascalia: e' la
	# faccia che parla
	if box == null:
		return
	if box.get_parent() != null:
		box.get_parent().remove_child(box)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia_parlato.add_child(box)
	box_testo = box
	if not box.minimum_size_changed.is_connected(disponi_didascalia):
		box.minimum_size_changed.connect(disponi_didascalia)
	disponi_didascalia()
	# la didascalia e' stretta come il leggio di una volta: il triangolino ha
	# il suo posto, se no l'ultima parola della riga ci finisce sotto
	if box.has_method("posto_al_triangolo"):
		box.posto_al_triangolo(true)

func pannello_per_menu(modo: String) -> Control:
	# IL MENU NON SA IN CHE PANNELLO STA, e non deve saperlo: chiede "mi serve
	# il posto per i comandi" oppure "per una lista", e riceve il contenitore
	# giusto con la sua faccia gia' aperta.
	if modo == "comandi":
		mostra_faccia("comandi")
		return comandi
	mostra_faccia("lista")
	return griglia_lista

static func faccia_da_mostrare(puoi_agire: bool, da_leggere: bool, modo_menu: String) -> String:
	# CHI SI PRENDE LA SCHERMATA, IN UNA REGOLA SOLA.
	#
	# Chi decide non puo' essere ne' il menu ne' il box: lo vogliono tutti e due
	# e nessuno dei due sa cosa sta facendo l'altro. Il primo tentativo dava al
	# racconto un lucchetto sulla faccia, e bastava una ricarica che finiva nel
	# momento sbagliato per restare chiusi fuori dal proprio turno.
	#
	#   puoi agire      -> IL MENU, sempre. Un menu nascosto non si vede e non
	#                      prende il fuoco da tastiera: tenerlo sotto una frase
	#                      non e' una scelta di stile, e' toglierti il turno.
	#   c'e' da leggere -> IL RACCONTO, nella didascalia. Mentre ricarichi non
	#                      stai scegliendo niente, ed e' quasi tutto il tempo.
	#   altrimenti      -> il menu, spento.
	if puoi_agire:
		return modo_menu
	return "parlato" if da_leggere else modo_menu

func mostra_faccia(quale: String) -> void:
	# LA SCHERMATA SI RICOMPONE SECONDO IL MOMENTO (vedi in cima). Il box puo'
	# essere prestato a una lezione (Indicazione.gd): se la lezione indica un
	# pezzo del programma, il programma sale e il racconto resta li' sotto la
	# creatura; se indica la fascia, il racconto va su un leggio al posto del
	# programma
	var prestato := indicazione != null and is_instance_valid(indicazione) and indicazione.box_prestato
	var al_leggio := prestato and indicazione.leggio != null
	var leggendo := quale == "parlato" and not al_leggio
	if quale == "parlato" and prestato and not al_leggio:
		quale = "comandi"   # il pezzo indicato sta nel programma: sale anche lui
	var stato := "%s|%s|%s" % [quale, leggendo, al_leggio]
	if stato == stato_adesso:
		return
	stato_adesso = stato
	faccia_adesso = quale
	if quale != "lista":
		for uno in slot:
			uno.prenota_aura = 0
	faccia_comandi.visible = quale == "comandi"
	faccia_lista.visible = quale == "lista"
	faccia_parlato.visible = leggendo
	var sceglie := quale == "comandi" or quale == "lista"
	entra(quadrante, sceglie, Vector2(0.0, 1.0))
	entra(didascalia, leggendo, Vector2(-1.0, 0.0))
	# la fascia col nome esce mentre si racconta: il racconto e' la didascalia
	# della creatura, e ne prende il posto
	scheda_nemico.visible = not leggendo
	# il minigioco si prende lo schermo della creatura: lei si ritira dietro
	box_nemico.dentro.modulate.a = 0.15 if quale == "minigioco" else 1.0
	# i tasselli stanno coi comandi e con la lista; col racconto e coi minigiochi no
	if tasto_mattanza != null:
		tasto_mattanza.visible = sceglie
	if tasto_bond != null:
		tasto_bond.visible = sceglie

func entra(nodo: Control, si: bool, da_dove: Vector2) -> void:
	# UN PEZZO CHE COMPARE ENTRA DAL SUO LATO (il programma dal basso, il
	# racconto da sinistra), uno che se ne va sparisce subito: quello che si
	# legge e si clicca deve esserci appena serve, non a meta' di un'animazione
	if nodo == null:
		return
	if nodo.visible == si:
		return
	nodo.visible = si
	if not si or Movimento.ridotto() or not nodo.is_inside_tree():
		return
	var fermo := nodo.position
	nodo.position = fermo + da_dove * 60.0 * scala
	nodo.modulate.a = 0.0
	var arriva := nodo.create_tween().set_parallel(true)
	arriva.tween_property(nodo, "position", fermo, Movimento.durata("entrata")) \
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	arriva.tween_property(nodo, "modulate:a", 1.0, 0.1)

func aggiorna_condizione(quota_hp: float, stress: int, morale: int) -> void:
	# QUELLO CHE SI LEGGE E' LA CONDIZIONE DI CHI HA IL TURNO. L'ECG, il morale
	# e lo stress sono uno solo mentre i personaggi sono tre: e' il cuore di chi
	# sta per muoversi, ed e' il motivo per cui la sua scheda fa il passo avanti.
	#
	# SI SCRIVE SOLO QUANDO CAMBIA: queste due etichette venivano aggiornate a
	# ogni fotogramma, e riscrivere il testo di una Label rifa' la disposizione
	# anche quando il numero e' identico.
	ecg.imposta(quota_hp, stress)
	if stress != stress_scritto:
		stress_scritto = stress
		etichetta_stress.text = "Stress: %d" % stress
		# lo stress alto si legge in giallo, come la linea che si agita
		etichetta_stress.add_theme_color_override("font_color",
				Stile.colore("ecg_giallo") if stress >= 50 else Stile.colore("testo"))
	if morale != morale_scritto:
		morale_scritto = morale
		etichetta_morale.text = "Morale: %d" % morale

func vita_nemico(quota: float, nota: bool) -> void:
	# LA VITA DELLA CREATURA SULLA SUA FASCIA: piena e coperta finche' non la
	# studi, poi il pieno vero
	if scheda_nemico == null:
		return
	scheda_nemico.quota = clampf(quota, 0.0, 1.0)
	scheda_nemico.nota = nota

func mostra_fila(ordine: Array[Dictionary], adesso: Dictionary, giro: int) -> void:
	# LA FILA DEL GIRO, dall'ordine che i turni hanno messo insieme all'inizio
	# del giro: chi tocca adesso, chi ha gia' agito, chi viene dopo
	if fila == null:
		return
	var dove := -1
	for i in ordine.size():
		if is_same(ordine[i], adesso):
			dove = i
	var gettoni: Array[Dictionary] = []
	for i in ordine.size():
		var chi: Dictionary = ordine[i]
		gettoni.append({"iniziale": String(chi.get("nome", "?")).left(1).to_upper(),
				"nemico": not bool(chi.get("giocatore", false)),
				"adesso": i == dove,
				"fatto": (dove >= 0 and i < dove) or int(chi.get("hp", 1)) <= 0})
	fila.scala = scala.y
	fila.mostra(giro, gettoni)

func posto_turno_nemico() -> Vector2:
	# dove entra «TOCCA A <creatura>»: appoggiata sulla fascia, verso la
	# diagonale, nelle coordinate dello schermo della creatura (FasciaTurno.metti
	# ci appoggia il fondo). Sta sullo schermo e non sulla fascia: mentre lei
	# parla la fascia esce, e il turno resta suo
	var banda := scheda_nemico.banda
	if banda.size() < 2:
		return Vector2.ZERO
	return banda[0].lerp(banda[1], 0.6) + scheda_nemico.position - box_nemico.position + Vector2(0.0, -6.0 * scala.y)

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
		# LA SCHERMATA SI RICOMPONE SUBITO, non al prossimo giro dello scontro:
		# se la battuta nomina l'ECG, il programma sale mentre la si legge
		var leggeva := faccia_parlato.visible
		stato_adesso = ""
		mostra_faccia("parlato" if leggeva else faccia_adesso)
	else:
		alone_evidenza = Evidenza.intorno_a(nodi[0], "cornice")
		alone_evidenza.accendi()

func spegni_evidenza() -> void:
	if alone_evidenza != null and is_instance_valid(alone_evidenza):
		alone_evidenza.ferma()
		alone_evidenza.queue_free()
	alone_evidenza = null
	if indicazione != null and is_instance_valid(indicazione):
		indicazione.togli()   # e il box torna nella didascalia
	indicazione = null
	evidenziato = null
	stato_adesso = ""   # la prossima faccia si ricompone da capo, senza il prestito
