class_name ProgrammaCombattimento
extends Node
# IL PROGRAMMA: I COMANDI DI CHI DECIDE (Plancia.gd).
#
# Un foglio di sbieco sulla diagonale, sotto le schede della squadra. Fa un
# mestiere solo, scegliere: chi decide, il suo ECG e i suoi comandi sono una
# colonna sola, e l'occhio scende invece di attraversare lo schermo.
#
#   ┌──────────── ECG (per tutta la larghezza) ───────┐
#   │ MORALE 20   STRESS 0                            │
#   └─────────────────────────────────────────────────┘
#     ATTACCHI      COSA FA
#     DIFESA        Il colpo normale e le mosse d'arma.
#     SKILL         Si sceglie poi chi colpire.
#     OGGETTI
#     FUGA          (oppure la lista, su piu' colonne)
#    [MATTANZA] [BOND]
#
# Si e' staccato dalla plancia quando la schermata e' diventata quella della
# proposta approvata (docs/scontro_proposta.md): la plancia sa dove stanno i
# pezzi, il programma come si dispongono dentro e come si riempiono. I nodi
# restano della plancia - il menu, la voce e le prove li chiedono a lei.
#
# E' UN NODO, appeso al suo pannello, e non un oggetto qualunque: la plancia
# tiene lui e lui tiene la plancia, e due oggetti che si tengono a vicenda non
# se ne vanno mai (la suite lo ha visto: tre risorse ancora in uso all'uscita).
# Un nodo se ne va con la schermata.

const RIGHE_LISTA := PlanciaCombattimento.RIGHE_LISTA
const COLONNE_LISTA := PlanciaCombattimento.COLONNE_LISTA
const CORPO_MINIMO := PlanciaCombattimento.CORPO_MINIMO
const CORPO_MASSIMO := PlanciaCombattimento.CORPO_MASSIMO
const META_SPIEGA := "spiega_collegata"   # la voce del menu racconta gia' cosa fa
const META_PRENOTA := "prenota_collegata" # la voce della lista mostra gia' quanto costa

var plancia: PlanciaCombattimento


func _init(di: PlanciaCombattimento) -> void:
	plancia = di


func costruisci() -> Control:
	# IL PROGRAMMA: un foglio di sbieco sulla diagonale, sotto le schede. Fa un
	# mestiere solo, scegliere. In cima il monitor di chi decide, sotto i comandi
	# e accanto due righe su quello che stai guardando; in fondo MATTANZA e BOND
	var fuori := Control.new()
	fuori.name = "Programma"
	fuori.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plancia.foglio_programma = SpinaPlancia.FoglioSbieco.new()
	plancia.foglio_programma.tinta = Stile.colore("box_fondo")
	plancia.foglio_programma.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fuori.add_child(plancia.foglio_programma)
	fuori.add_child(plancia.margini_dentro(0))
	plancia.radice.add_child(fuori)
	var dentro := plancia.interno_di(fuori)

	plancia.faccia_comandi = Control.new()
	plancia.faccia_comandi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plancia.faccia_comandi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dentro.add_child(plancia.faccia_comandi)

	# IL MONITOR DI CHI DECIDE. Bru, sulla prima proposta: «non si vede l'ecg» -
	# era una striscia di trenta pixel dentro la scheda. Qui la linea corre per
	# tutta la larghezza del programma, e sotto, nello stesso vetro scuro, il
	# morale e lo stress. Sta un gradino piu' su delle facce: si vede coi
	# comandi e con la lista, perche' e' il cuore di chi sta scegliendo
	var monitor := Control.new()
	monitor.name = "Monitor"
	monitor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	monitor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dentro.add_child(monitor)
	plancia.fondale_ecg = Panel.new()
	var vetrino := StyleBoxFlat.new()
	vetrino.bg_color = Stile.colore("ecg_fondo")
	vetrino.border_color = Stile.colore("bordo")
	vetrino.set_border_width_all(3)
	plancia.fondale_ecg.add_theme_stylebox_override("panel", vetrino)
	plancia.fondale_ecg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	monitor.add_child(plancia.fondale_ecg)
	plancia.ecg = TracciatoEcg.new()
	monitor.add_child(plancia.ecg)
	plancia.etichetta_morale = Label.new()
	plancia.etichetta_stress = Label.new()
	for misura in [plancia.etichetta_morale, plancia.etichetta_stress]:
		misura.uppercase = true
		misura.add_theme_color_override("font_color", Stile.colore("testo"))
		misura.add_theme_font_override("font", Caratteri.titolo())
		monitor.add_child(misura)

	# I DUE TASSELLI NON STANNO DENTRO UNA FACCIA SOLA.
	#
	# Sono l'unico avviso che il giocatore riceve quando la Mattanza o il Bond
	# diventano pronti. Se vivono dentro la faccia dei comandi, spariscono
	# proprio mentre scegli un attacco da una lista - cioe' nei secondi in cui
	# stai guardando altrove e il segnale arriva. Stanno un gradino piu' su.
	# NON DIRETTAMENTE NEL CONTENITORE: "Dentro" e' un MarginContainer, e un
	# contenitore stira i suoi figli. Ci vuole uno strato semplice in mezzo.
	plancia.strato_tasselli = Control.new()
	plancia.strato_tasselli.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dentro.add_child(plancia.strato_tasselli)
	plancia.tasto_mattanza = tasto_acceso("MATTANZA", "mattanza")
	plancia.strato_tasselli.add_child(plancia.tasto_mattanza)
	plancia.tasto_bond = tasto_acceso("BOND", "bond")
	plancia.strato_tasselli.add_child(plancia.tasto_bond)

	# LA LISTA DEI COMANDI LA RIEMPIE IL MENU, non la plancia. Qui c'e' solo il
	# posto dove va: quali voci ci stanno dentro lo decide lo scontro (Aiutante
	# e Mediazione compaiono e spariscono)
	plancia.comandi = VBoxContainer.new()
	plancia.comandi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# LE VOCI SEGUONO LA DIAGONALE: ognuna rientra quanto rientra il lato del
	# foglio alla sua altezza, come le righe di un manifesto di sbieco
	plancia.comandi.sort_children.connect(sbieca_le_voci)
	plancia.faccia_comandi.add_child(plancia.comandi)
	# DUE RIGHE SU QUELLO CHE STAI GUARDANDO: un nuovo giocatore non sa cos'e'
	# SKILL. Le scrive il carattere del racconto
	plancia.cosa_fa = Label.new()
	plancia.cosa_fa.text = "COSA FA"
	plancia.cosa_fa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plancia.faccia_comandi.add_child(plancia.cosa_fa)
	plancia.spiegazione = Label.new()
	plancia.spiegazione.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plancia.spiegazione.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plancia.spiegazione.add_theme_color_override("font_color", Stile.colore("box_testo"))
	plancia.spiegazione.add_theme_font_override("font", Caratteri.dialoghi())
	plancia.faccia_comandi.add_child(plancia.spiegazione)

	plancia.faccia_lista = Control.new()
	plancia.faccia_lista.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plancia.faccia_lista.visible = false
	dentro.add_child(plancia.faccia_lista)
	dentro.move_child(plancia.faccia_lista, plancia.faccia_comandi.get_index() + 1)
	# LE VOCI DI UN COMANDO CHE NE HA UNA: gli attacchi, le skill, gli oggetti,
	# su piu' colonne. E NON E' UN GridContainer: un contenitore non scende mai
	# sotto la misura minima dei suoi figli, e le ultime voci finivano sotto
	# MATTANZA e BOND. Qui le voci si piazzano a mano (adatta_lista)
	plancia.griglia_lista = Control.new()
	plancia.griglia_lista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plancia.faccia_lista.add_child(plancia.griglia_lista)
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
	plancia.accendi(tasto, false)
	return tasto

func disponi() -> void:
	var r := plancia.rettangolo_programma()
	var rientro := SpinaPlancia.pendenza() * r.size.y
	var scatola := Rect2(r.position.x - rientro, r.position.y, r.size.x + rientro, r.size.y)
	plancia.piazza(plancia.quadrante, plancia.in_pixel(scatola))
	plancia.foglio_programma.punti = SpinaPlancia.sbieco(Rect2(Vector2(rientro * plancia.scala.x, 0.0),
			Vector2(r.size.x * plancia.scala.x, r.size.y * plancia.scala.y)), plancia.pendenza_px)
	plancia.foglio_programma.queue_redraw()
	# DENTRO il foglio: dal lato sinistro in alto, con un margine
	var dentro := plancia.interno_di(plancia.quadrante)
	dentro.add_theme_constant_override("margin_left", int((rientro + 14.0) * plancia.scala.x))
	dentro.add_theme_constant_override("margin_right", int(14.0 * plancia.scala.x))
	dentro.add_theme_constant_override("margin_top", int(10.0 * plancia.scala.y))
	dentro.add_theme_constant_override("margin_bottom", int(10.0 * plancia.scala.y))
	dentro.position = Vector2.ZERO
	dentro.size = plancia.quadrante.size
	disponi_quadrante()

func disponi_quadrante() -> void:
	# LE MISURE DENTRO IL PROGRAMMA, sul foglio (1280x720), dal suo angolo in alto
	# a sinistra. "Dentro" non e' ancora stato rimesso in misura dal suo
	# contenitore: la misura si calcola, non si legge
	var r := plancia.rettangolo_programma()
	var largo := r.size.x - 28.0
	var alto := r.size.y - 20.0
	var monitor := SpinaPlancia.numero("programma", "monitor", 64.0)
	var letture := SpinaPlancia.numero("programma", "letture", 22.0)
	var sotto_monitor := SpinaPlancia.numero("programma", "sotto_monitor", 110.0) - 10.0
	# il monitor: la linea per tutta la larghezza, le letture sotto
	var vetro := Rect2(4.0, 4.0, largo - 8.0, monitor + letture)
	plancia.piazza(plancia.fondale_ecg, plancia.in_pixel(vetro))
	plancia.piazza(plancia.ecg, plancia.in_pixel(Rect2(vetro.position + Vector2(8.0, 6.0), Vector2(vetro.size.x - 16.0, monitor - 10.0))))
	var corpo_letture := maxi(int(round(15.0 * plancia.scala.y)), 9)
	for etichetta in [plancia.etichetta_morale, plancia.etichetta_stress]:
		etichetta.add_theme_font_size_override("font_size", corpo_letture)
		etichetta.reset_size()
	var riga_letture := vetro.position.y + monitor + (letture - 18.0) * 0.5
	plancia.etichetta_morale.position = Vector2(vetro.position.x + 12.0, riga_letture) * plancia.scala
	plancia.etichetta_stress.position = Vector2(vetro.position.x + 150.0, riga_letture) * plancia.scala
	# MATTANZA e BOND in fondo, sempre al loro posto
	var tasti_y := alto - 40.0
	plancia.piazza(plancia.tasto_mattanza, plancia.in_pixel(Rect2(4.0, tasti_y, 160.0, 36.0)))
	plancia.piazza(plancia.tasto_bond, plancia.in_pixel(Rect2(174.0, tasti_y, 160.0, 36.0)))
	for tasto in [plancia.tasto_mattanza, plancia.tasto_bond]:
		tasto.add_theme_font_size_override("font_size", maxi(int(tasto.size.y * 0.52), 10))
	# i comandi a sinistra, e accanto le due righe su quello che stai guardando
	var fino := tasti_y - 6.0
	plancia.piazza(plancia.comandi, plancia.in_pixel(Rect2(10.0, sotto_monitor, 190.0, fino - sotto_monitor)))
	var x_spiega := 206.0
	Manifesto.vesti_etichetta(plancia.cosa_fa, maxi(int(round(13.0 * plancia.scala.y)), 8), "box_fondo", "bordo")
	plancia.cosa_fa.reset_size()
	plancia.cosa_fa.position = Vector2(x_spiega, sotto_monitor + 2.0) * plancia.scala
	plancia.spiegazione.add_theme_font_size_override("font_size", maxi(int(round(17.0 * plancia.scala.y)), 9))
	plancia.piazza(plancia.spiegazione, plancia.in_pixel(Rect2(x_spiega, sotto_monitor + 30.0, largo - x_spiega - 4.0, fino - sotto_monitor - 30.0)))
	# la lista: tutta la larghezza, fra il monitor e i tasti
	plancia.zona_lista = plancia.in_pixel(Rect2(4.0, sotto_monitor - 4.0, largo - 8.0, fino - sotto_monitor + 4.0))
	adatta_comandi()
	if plancia.faccia_adesso == "lista":
		adatta_lista()

func sbieca_le_voci() -> void:
	# ogni voce rientra quanto rientra il lato sinistro del foglio alla sua
	# altezza: la colonna dei comandi corre parallela alla diagonale
	for voce in plancia.comandi.get_children():
		if voce is Control:
			(voce as Control).position.x = -plancia.pendenza_px * ((voce as Control).position.y + plancia.comandi.position.y)

func corpo_che_ci_sta(campione: Control, alto_riga: float) -> int:
	# QUANTO PUO' ESSERE GRANDE IL TESTO PER STARE IN UNA RIGA ALTA COSI'.
	#
	# Non si ricava da una proporzione scritta a mano: quanto e' alta una riga di
	# testo lo decide IL FONT, non il numero che gli chiediamo. Con un rapporto
	# fisso le voci stavano dentro con un font e sbordavano con l'altro.
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

func adatta_comandi() -> void:
	# LA COLONNA SI RESTRINGE QUANDO LE VOCI SONO TANTE. Le fisse sono cinque, ma
	# Aiutante e Mediazione compaiono quando ci sono: con un corpo fisso la sesta
	# voce usciva dal programma e la settima finiva sopra MATTANZA.
	if plancia.comandi == null or plancia.quadrante == null:
		return
	var quante := maxi(plancia.comandi.get_child_count(), 5)
	# quanto occupa una riga lo dice il font, non una proporzione scritta a mano
	var campione := plancia.comandi.get_child(0) as Control if plancia.comandi.get_child_count() > 0 else null
	var per_riga := plancia.comandi.size.y / float(quante)
	plancia.corpo_comandi = corpo_che_ci_sta(campione, per_riga) if campione != null \
			else clampi(int(per_riga * 0.62), CORPO_MINIMO, CORPO_MASSIMO)
	plancia.corpo_comandi = corpo_che_ci_sta_in_largo(plancia.corpo_comandi)
	plancia.comandi.add_theme_constant_override("separation", 0)
	for voce in plancia.comandi.get_children():
		if voce is Control:
			vesti_comando(voce as Control)
			# LA MISURA MINIMA VA DETTA: il menu da' a ogni voce 44 pixel di
			# altezza minima, e un Control non scende mai sotto il suo minimo.
			# Nel programma una riga e' piu' bassa: cinque da 44 finivano sotto i
			# tasti
			(voce as Control).custom_minimum_size = Vector2(0, floorf(per_riga))
		if voce is Button and not (voce as Button).has_meta(META_SPIEGA):
			var tasto := voce as Button
			tasto.set_meta(META_SPIEGA, true)
			tasto.focus_entered.connect(spiega.bind(tasto))
			tasto.mouse_entered.connect(spiega.bind(tasto))
	var col_fuoco := plancia.radice.get_viewport().gui_get_focus_owner() if plancia.radice != null and plancia.radice.is_inside_tree() else null
	if col_fuoco is Button and plancia.comandi.is_ancestor_of(col_fuoco):
		spiega(col_fuoco as Button)
	elif plancia.primo_comando_utile() != null:
		spiega(plancia.primo_comando_utile())
	else:
		# nessuna voce da scegliere (la Mattanza scrive i suoi avvisi qui): niente
		# da spiegare, e «COSA FA» da solo sarebbe una domanda senza risposta
		plancia.spiegazione.text = ""
		plancia.cosa_fa.visible = false

func prenota_per(voce: Control) -> void:
	# LA MOSSA CHE STAI GUARDANDO, SULLA BARRA DI CHI LA FAREBBE: il pezzo
	# d'aura che spenderesti si fa a righe, col costo in rosso sopra. «Una mossa
	# costa CINQUE» si legge li' dove sta l'aura, non nel testo della voce
	var costo := int(voce.get_meta("aura", 0)) if is_instance_valid(voce) else 0
	for uno in plancia.slot:
		uno.prenota_aura = costo if uno.tocca_a_lui and plancia.faccia_adesso == "lista" else 0

func spiega(voce: Button) -> void:
	# QUELLO CHE FA LA VOCE CHE STAI GUARDANDO, in due righe
	if not is_instance_valid(voce) or plancia.spiegazione == null:
		return
	var chiave := voce.text.replace("▶", "").strip_edges()
	var testi: Variant = SpinaPlancia.misura("cosa_fa")
	var testo := String((testi as Dictionary).get(chiave, "")) if testi is Dictionary else ""
	plancia.spiegazione.text = testo
	plancia.cosa_fa.visible = testo != ""

func corpo_che_ci_sta_in_largo(corpo: int) -> int:
	# E IN LARGO: la voce piu' lunga, col triangolo davanti, dentro la colonna
	for voce in plancia.comandi.get_children():
		while voce is Button and corpo > CORPO_MINIMO and Caratteri.titolo().get_string_size(
				(voce as Button).text, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo * 1.6 > plancia.comandi.size.x:
			corpo -= 1
	return corpo

func vesti_comando(voce: Control) -> void:
	# UNA VOCE DEL MENU, scritta sulla carta del programma: nera, e quella col
	# fuoco sull'etichetta (Manifesto.vesti_voce)
	if voce is Button:
		Manifesto.vesti_voce(voce as Button, plancia.corpo_comandi)

func adatta_lista() -> void:
	# QUANTE COLONNE, E QUANTO GRANDI. Una lista di tre voci su tre colonne
	# sarebbe una riga sola sperduta in mezzo al pannello; una di venti su una
	# colonna uscirebbe di sotto. Si riempie per colonne, fino a tre.
	if plancia.griglia_lista == null or plancia.quadrante == null:
		return
	var quante := plancia.griglia_lista.get_child_count()
	if quante == 0:
		# il menu ha appena svuotato: si riparte dalla prima pagina
		plancia.pagina_lista = 0
		if plancia.tasto_altro != null:
			plancia.tasto_altro.visible = false
		return
	if plancia.zona_lista.size.x <= 0.0 or plancia.zona_lista.size.y <= 0.0:
		return
	var margine := maxf(4.0 * plancia.scala.y, 2.0)
	# LA LISTA SI FERMA DOVE COMINCIANO MATTANZA E BOND, e sotto il monitor:
	# zona_lista e' quello che resta in mezzo (disponi_quadrante). I tasselli
	# stanno sopra tutte le facce apposta, e coprivano le ultime voci - con
	# SKILL l'ultima e' "Indietro", cioe' l'unico modo di uscire
	var alto := plancia.zona_lista.size.y - margine * 2.0
	var largo := plancia.zona_lista.size.x - margine * 2.0
	plancia.griglia_lista.position = plancia.zona_lista.position + Vector2(margine, margine)
	plancia.griglia_lista.size = Vector2(largo, alto)
	var distacco := maxf(alto * 0.03, 2.0)

	# QUANTE RIGHE CI STANNO DAVVERO: quante ne entrano nella banda scrivendole
	# col corpo piu' piccolo che accettiamo
	var campione := plancia.griglia_lista.get_child(0) as Control
	var minima := alto_riga_minima(campione)
	var righe_utili := clampi(int((alto + distacco) / (minima + distacco)), 1, RIGHE_LISTA)
	var capienza := righe_utili * COLONNE_LISTA

	# SE NON CI STANNO TUTTE, SI VOLTA PAGINA - non si nascondono le ultime.
	var a_pagine := quante > capienza
	var per_pagina := (capienza - 1) if a_pagine else quante
	var pagine := int(ceil(float(quante) / float(maxi(per_pagina, 1))))
	plancia.pagina_lista = wrapi(plancia.pagina_lista, 0, maxi(pagine, 1))
	var da := plancia.pagina_lista * per_pagina
	var a := mini(da + per_pagina, quante)
	var mostrate := a - da
	var celle := mostrate + (1 if a_pagine else 0)

	plancia.colonne_lista = clampi(int(ceil(float(celle) / float(righe_utili))), 1, COLONNE_LISTA)
	var righe := maxi(int(ceil(float(celle) / float(plancia.colonne_lista))), 1)
	var per_riga := (alto - distacco * float(righe - 1)) / float(righe)
	var per_colonna := largo / float(plancia.colonne_lista)
	var corpo := corpo_in_largo(corpo_che_ci_sta(campione, per_riga), da, a, per_colonna - margine)

	var posto := 0
	for i in quante:
		var voce := plancia.griglia_lista.get_child(i) as Control
		if voce == null:
			continue
		voce.visible = i >= da and i < a
		if not voce.visible:
			continue
		vesti_voce_di_lista(voce, posto, righe, per_riga, per_colonna, distacco, corpo, margine)
		posto += 1

	prepara_tasto_altro(a_pagine, plancia.pagina_lista + 1, pagine)
	if a_pagine:
		vesti_voce_di_lista(plancia.tasto_altro, posto, righe, per_riga, per_colonna,
				distacco, corpo, margine)
		# "Altro" NON E' FIGLIO DELLA GRIGLIA, quindi le sue coordinate partono
		# da un altro angolo: vive nella faccia, la griglia sta piu' dentro
		plancia.tasto_altro.position += plancia.griglia_lista.position
	collega_i_costi()


func corpo_in_largo(corpo: int, da: int, a: int, per_colonna: float) -> int:
	# E IN LARGO: il programma e' piu' stretto del quadrante di prima, e
	# «Sovraccarico (5 aura)» finiva in «Sovraccarico (5 ...». Si stringe la
	# scritta finche' la voce piu' lunga della pagina sta nella sua colonna -
	# ma non sotto una misura che si legge ancora da divano: per stare intera,
	# «Spezza spazio (0 aura) (1.0 barre)» faceva scendere tutte le altre a
	# tredici pixel. Sotto quella misura, i puntini sono il male minore
	var stretto := Caratteri.voci_strette()
	var minimo := maxi(CORPO_MINIMO, int(round(17.0 * plancia.scala.y)))
	for i in range(da, a):
		var voce := plancia.griglia_lista.get_child(i) as Button
		while voce != null and corpo > minimo and stretto.get_string_size(voce.text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo * 1.6 > per_colonna:
			corpo -= 1
	return corpo


func collega_i_costi() -> void:
	# OGNI VOCE DELLA LISTA, GUARDATA, MOSTRA IL SUO COSTO sulla barra di chi
	# la farebbe (prenota_per). Il fuoco e' gia' su una voce - il menu lo da'
	# alla prima mentre la mette: il suo costo si vede subito, non al primo
	# movimento
	for voce in plancia.griglia_lista.get_children():
		if voce is Button and not voce.has_meta(META_PRENOTA):
			voce.set_meta(META_PRENOTA, true)
			(voce as Button).focus_entered.connect(prenota_per.bind(voce))
			(voce as Button).mouse_entered.connect(prenota_per.bind(voce))
	var col_fuoco := plancia.radice.get_viewport().gui_get_focus_owner() if plancia.radice.is_inside_tree() else null
	if col_fuoco != null and plancia.griglia_lista.is_ancestor_of(col_fuoco):
		prenota_per(col_fuoco)

func vesti_voce_di_lista(voce: Control, posto: int, righe: int, per_riga: float,
		per_colonna: float, distacco: float, corpo: int, margine: float) -> void:
	vesti_comando(voce)
	if voce is Button:
		(voce as Button).add_theme_font_override("font", Caratteri.voci_strette())   # le liste sono lunghe
		(voce as Button).add_theme_font_size_override("font_size", corpo)
		(voce as Button).text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS   # mai fuori dalla cella
	# LA MISURA MINIMA VA DETTA, non lasciata a quella che c'era: il menu da' a
	# ogni voce 44 pixel di altezza minima, troppi per una lista
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
	# mette la schermata, perche' e' la schermata a sapere quanto ci sta
	if not serve:
		if plancia.tasto_altro != null:
			plancia.tasto_altro.visible = false
		return
	if plancia.tasto_altro == null:
		plancia.tasto_altro = Button.new()
		plancia.tasto_altro.pressed.connect(func() -> void:
			plancia.pagina_lista += 1
			adatta_lista())
		plancia.faccia_lista.add_child(plancia.tasto_altro)
	plancia.tasto_altro.text = "Altro  (%d/%d)  ▸" % [quale, quante_pagine]
	plancia.tasto_altro.visible = true
