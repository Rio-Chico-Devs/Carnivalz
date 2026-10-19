class_name SchedaCrescita
extends "res://scripts/crescita/MomentiCrescita.gd"


# LA CRESCITA: la ruota di ogni personaggio, e la salita di livello.
#
# Bru, sulle proposte: «approvato quella che sembra una roulette, le passive e
# un punto due strade»; sui film della salita: «mi piacciono molto queste
# animazioni, approvate!»; e poi: «ogni personaggio ha la sua ruota poi le
# customizzaremo quando avrò tutti i disegni finiti». Le proposte da cui nasce
# sono in prove/ (ProposteCrescita, ProposteSalita, FilmSalita), il perche' di
# tutto in docs/salita.md, le regole in Crescita e i numeri in
# data/ruote.json.
#
# UN PUNTO, UNA TASCA, UN LIVELLO. Si spende un punto d'hype (della squadra) su
# chi si vuole, e si va in tre tempi, ognuno a tutto schermo, con una lastra
# nera che passa fra l'uno e l'altro:
#   la ruota   le tasche del personaggio, una per livello: girandola si legge
#              cosa da' ognuna. PRENDI: il punto vola dal contatore alla tasca
#   il bivio   un punto, due strade: si sceglie la statistica
#   il salto   il livello nuovo, enorme, e il perche' di ogni statistica
#              cresciuta: grigio quello che avevi, pieno le azioni (le cose
#              fatte giocando diventano statistiche proprio adesso), arancio la
#              strada presa
#   la carta   per ogni abilita' o passiva che arriva a quel livello
# e poi di nuovo la ruota: il timbro cade sulla tasca, il mozzo rotola, la
# lancetta passa alla prossima. Chiuso un giro (al 20, al 40...) il giro si
# accende, la ruota fa un giro di vittoria, si crepa lungo il taglio del bivio
# e le due meta' volano via: sotto c'e' la ruota del giro nuovo. Nella beta il
# 20 e' il tetto (data/ruote.json).
#
# I TASTI. Sulla ruota: su e giu' la girano, invio prende, destra e sinistra
# cambiano personaggio, ESC torna al menu (lo fa la Pausa). Nel bivio: destra e
# sinistra (o il clic) scelgono, invio prende, ESC ci ripensa (il punto torna
# indietro). Nel salto e sulle carte: invio va avanti (la prima volta finisce
# l'animazione), ESC salta tutto e torna alla ruota. Col mouse: clic sulle
# linguette dei personaggi, su INDIETRO e su PRENDI; la rotella gira la ruota.
#
# I PEZZI: questo file tiene il filo (i momenti, la tendina, i tasti, il
# mouse); sotto, un livello per cosa (scripts/crescita/): BaseCrescita lo
# stato e i conti, RuotaCrescita la ruota e la lastra, MotoCrescita i pezzi
# che si muovono, MomentiCrescita il bivio, il salto e la carta.


static func testo_della_voce() -> String:
	# la voce della pausa dice quanti punti ci sono da spendere: altrimenti
	# l'hype si accumula e nessuno sa dove usarlo
	var punti := GameState.punti_abilita_liberi()
	return "Crescita" + (" · %d %s" % [punti, "punto" if punti == 1 else "punti"] if punti > 0 else "")


static func in_combattimento(albero: SceneTree) -> bool:
	var scena := albero.current_scene
	return scena != null and scena.scene_file_path == "res://scenes/Combattimento.tscn"


func apri(indietro_a: Callable, puo_salire := true) -> void:
	su_indietro = indietro_a
	si_sale = puo_salire
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP     # il foglio copre: sotto non si clicca niente
	squadra = [GameState.id_protagonista]
	for id_classe in GameState.party:
		if String(id_classe) not in squadra:
			squadra.append(String(id_classe))
	tavola = Tavola.su(self)
	sotto = strato(disegna_sotto, true)
	spacco = strato(disegna_spacco)
	sopra = strato(disegna_sopra)
	tasti_qui = Control.new()
	tasti_qui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tavola.add_child(tasti_qui)
	strato(disegna_tendina)
	# la ruota del giro chiuso, disegnata anche a parte: quando si spacca
	# servono i pezzi della sua immagine
	vecchia = SubViewport.new()
	vecchia.size = Vector2i(roundi(Tavola.LARGO), roundi(Tavola.ALTO))
	vecchia.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(vecchia)
	vecchia_tela = Strato.new()
	vecchia_tela.come = disegna_vecchia
	vecchia.add_child(vecchia_tela)
	Manifesto.trama_dietro(vecchia_tela).show_behind_parent = true
	scegli(squadra[0])


func strato(come_si_disegna: Callable, col_fondo := false) -> Strato:
	var foglio := Strato.new()
	foglio.come = come_si_disegna
	tavola.add_child(foglio)
	if col_fondo:
		Manifesto.trama_dietro(foglio).show_behind_parent = true
	return foglio


func scegli(id_classe: String) -> void:
	# la ruota di un altro personaggio: si guarda dalla sua prossima tasca
	chi = id_classe
	adesso = GameState.livello_di(chi)
	guardato = mini(adesso + 1, tetto())
	vista = float(guardato)
	spinta_vista = 0.0
	livello_nuovo = 0
	prendi_a = -10.0
	timbro_a = -10.0
	timbrato = false
	rullo_a = -10.0
	accendi_a = -10.0
	vittoria_a = -10.0
	crepa_a = -10.0
	spacca_a = -10.0
	in_coda.clear()
	entra("ruota")


# --- il tempo: i momenti, la tendina, quello che succede da solo ---------------------------

func _process(delta: float) -> void:
	tempo += delta
	avanza_la_tendina()
	while not in_coda.is_empty() and tempo >= float(in_coda[0][0]):
		succede(String((in_coda.pop_front() as Array)[1]))
	batte_il_timbro()
	var ruota := molla(vista, spinta_vista, float(guardato), delta)
	vista = ruota.x
	spinta_vista = ruota.y
	var taglio := molla(peso, spinta_peso, 1.0 if a_destra else 0.0, delta)
	peso = taglio.x
	spinta_peso = taglio.y
	scuoti()
	ridisegna()


func avanza_la_tendina() -> void:
	# a meta' della lastra nera, quando copre tutto, si cambia momento
	if tendina_a < 0.0:
		return
	if prossimo != "" and tempo - tendina_a >= TENDINA * 0.5:
		var dove := prossimo
		prossimo = ""
		entra(dove)
	if tempo - tendina_a >= TENDINA:
		tendina_a = -10.0


func batte_il_timbro() -> void:
	# il timbro tocca la tasca: si sale davvero, e il mozzo rotola
	if timbro_a < 0.0 or timbrato or tempo < timbro_a + CADE:
		return
	timbrato = true
	rullo_da = adesso
	adesso = livello_timbrato
	rullo_a = tempo


func scuoti() -> void:
	# le scosse: quando il timbro batte, e quando la ruota si crepa
	var scossa := 0.0
	if timbrato:
		scossa = 8.0 * (1.0 - clampf((tempo - timbro_a - CADE) / 0.25, 0.0, 1.0))
	if crepa_a >= 0.0 and spacca_a < 0.0:
		scossa = maxf(scossa, 4.0)
	var spinta := Vector2(sin(tempo * 91.0), cos(tempo * 73.0)) * scossa
	sotto.position = spinta
	spacco.position = spinta


func ridisegna() -> void:
	for figlio in tavola.get_children():
		if figlio is Strato:
			(figlio as Control).queue_redraw()
	# la ruota vecchia si disegna solo quando sta per spaccarsi
	var serve := vittoria_a >= 0.0 and (spacca_a < 0.0 or tempo - spacca_a < 1.0)
	vecchia.render_target_update_mode = SubViewport.UPDATE_ALWAYS if serve else SubViewport.UPDATE_DISABLED
	if serve:
		vecchia_tela.queue_redraw()


func vai(dove: String) -> void:
	# la lastra nera passa, e a meta' (quando copre tutto) si cambia momento
	if prossimo != "":
		return
	prossimo = dove
	tendina_a = tempo


func entra(dove: String) -> void:
	momento = dove
	momento_a = tempo
	match dove:
		"bivio":
			a_destra = true
			peso = 1.0
			spinta_peso = 0.0
			preso_a = -1.0
			valori_bivio.clear()
			for stat in coppia(adesso + 1):
				valori_bivio[stat] = valore(stat)
		"ruota":
			if livello_nuovo > 0 and timbro_a < 0.0:
				# di ritorno da una salita: il timbro cade sulla tasca presa
				timbro_a = tempo + 0.4
				livello_timbrato = livello_nuovo
				timbrato = false
				var fine_giro := livello_nuovo == ultimo_del_giro(giro_di(livello_nuovo))
				poi(1.2 if fine_giro else 1.5, "accendi" if fine_giro else "gira")
			elif livello_nuovo == 0:
				prendi_a = -10.0      # ripensato nel bivio: il punto torna indietro
	tasti()


func succede(cosa: String) -> void:
	match cosa:
		"al_bivio":
			if momento == "ruota" and prendi_a >= 0.0 and livello_nuovo == 0:
				vai("bivio")
		"al_salto":
			vai("salto")
		"gira":
			guardato = mini(adesso + 1, tetto())
			fine_salita()
		"accendi":
			accendi_a = tempo
			fine_salita()
		"crepa":
			crepa_a = tempo
		"spacca":
			# sotto c'e' gia' quella nuova: parte indietro di qualche tasca, e ci arriva girando
			spacca_a = tempo
			guardato = adesso + 1
			vista = float(guardato) - 6.0
			spinta_vista = 0.0
			tasti()


func fine_salita() -> void:
	# la salita e' raccontata tutta: da qui si puo' prendere la prossima
	livello_nuovo = 0
	prendi_a = -10.0


# --- i tasti e il mouse --------------------------------------------------------------------------

func _unhandled_input(evento: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var preso := false
	match momento:
		"ruota":
			preso = tasto_sulla_ruota(evento)
		"bivio":
			preso = tasto_nel_bivio(evento)
		_:
			preso = tasto_nel_racconto(evento)
	if preso:
		get_viewport().set_input_as_handled()


func occupato() -> bool:
	# a meta' di un passaggio i tasti aspettano: la lastra che passa, il punto
	# che vola, il timbro che deve ancora battere, la ruota che si spacca
	return prossimo != "" or (momento == "ruota" and (livello_nuovo > 0 and not timbrato
			or prendi_a >= 0.0 and livello_nuovo == 0 or vittoria_a >= 0.0 and spacca_a < 0.0
			or accendi_a >= 0.0 and tempo - accendi_a < 1.5))


func tasto_sulla_ruota(evento: InputEvent) -> bool:
	if occupato():
		return evento.is_action_pressed("ui_accept") or evento.is_action_pressed("ui_cancel")
	if evento.is_action_pressed("ui_up") or evento.is_action_pressed("ui_down"):
		gira_la_ruota(-1 if evento.is_action_pressed("ui_up") else 1)
		return true
	if evento.is_action_pressed("ui_left") or evento.is_action_pressed("ui_right"):
		var verso := -1 if evento.is_action_pressed("ui_left") else 1
		if squadra.size() > 1:
			scegli(squadra[posmod(squadra.find(chi) + verso, squadra.size())])
		return true
	if evento.is_action_pressed("ui_accept"):
		invio_sulla_ruota()
		return true
	return false


func gira_la_ruota(verso: int) -> void:
	# si gira nel giro di adesso, e mai oltre il tetto
	var g := giro_di(guardato)
	guardato = clampi(guardato + verso, primo_del_giro(g), mini(ultimo_del_giro(g), tetto()))


func invio_sulla_ruota() -> void:
	if chiuso_e_si_va_oltre():
		# AL SECONDO GIRO: un giro di vittoria, la crepa, e la ruota nuova
		vittoria_a = tempo
		poi(1.05, "crepa")
		poi(1.4, "spacca")
		return
	if guardato != adesso + 1:
		# si torna sulla prossima tasca: e' l'unica che si prende
		guardato = mini(adesso + 1, tetto())
		return
	if not si_sale or not Crescita.prendibile(chi):
		return
	# il punto vola, la tasca si accende, poi passa la lastra
	punti_prima = GameState.punti_abilita_liberi()
	prendi_a = tempo
	poi(VOLA + 0.35, "al_bivio")


func poi(fra: float, cosa: String) -> void:
	in_coda.append([tempo + fra, cosa])
	in_coda.sort_custom(func(x: Array, y: Array) -> bool: return float(x[0]) < float(y[0]))


func tasto_nel_bivio(evento: InputEvent) -> bool:
	if prossimo != "" or preso_a >= 0.0:
		return evento.is_action_pressed("ui_accept") or evento.is_action_pressed("ui_cancel")
	if evento.is_action_pressed("ui_left") or evento.is_action_pressed("ui_right"):
		a_destra = evento.is_action_pressed("ui_right")
		return true
	if evento.is_action_pressed("ui_accept"):
		prendi_la_strada()
		return true
	if evento.is_action_pressed("ui_cancel"):
		vai("ruota")
		return true
	return false


func prendi_la_strada() -> void:
	# QUI SI SPENDE DAVVERO: Crescita.prendi. Per il protagonista il
	# racconto lo scrive GameState (le azioni diventano statistiche proprio
	# adesso); per un compagno conta solo la strada
	var due := coppia(adesso + 1)
	var stat := due[1] if a_destra else due[0]
	var prima := valore(stat)
	if not Crescita.prendi(chi, stat):
		vai("ruota")
		return
	preso_a = tempo
	livello_nuovo = adesso + 1
	if chi == GameState.id_protagonista and not GameState.salite_di_livello.is_empty():
		# la racconta questa schermata: il resoconto di fine scontro non la ripete
		salita = GameState.salite_di_livello.pop_back()
	else:
		salita = {"stat": [{"stat": stat, "prima": prima, "dopo": valore(stat)}], "motivi": [],
				"strada": {"stat": stat, "quanto": Crescita.quanto(stat)}}
	carte = Crescita.arriva(chi, livello_nuovo)
	carta = 0
	# il timbro e il passaggio di giro sono di questa salita, non della precedente
	timbro_a = -10.0
	timbrato = false
	rullo_a = -10.0
	accendi_a = -10.0
	vittoria_a = -10.0
	crepa_a = -10.0
	spacca_a = -10.0
	poi(1.3, "al_salto")


func tasto_nel_racconto(evento: InputEvent) -> bool:
	if prossimo != "":
		return evento.is_action_pressed("ui_accept") or evento.is_action_pressed("ui_cancel")
	if evento.is_action_pressed("ui_cancel"):
		vai("ruota")
		return true
	if not evento.is_action_pressed("ui_accept"):
		return false
	var fine := FINE_SALTO if momento == "salto" else FINE_CARTA
	if tempo - momento_a < fine:
		momento_a = tempo - fine - 10.0     # la prima volta finisce l'animazione
	elif momento == "salto" and not carte.is_empty():
		vai("carta")
	elif momento == "carta" and carta < carte.size() - 1:
		carta += 1
		momento_a = tempo
	else:
		vai("ruota")
	return true


func _gui_input(evento: InputEvent) -> void:
	# il mouse: le coordinate della tavola, che il foglio scala alla finestra
	if not evento is InputEventMouseButton or not (evento as InputEventMouseButton).pressed:
		return
	var bottone := evento as InputEventMouseButton
	var q := tavola.get_global_transform().affine_inverse() * bottone.global_position
	match bottone.button_index:
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
			if momento == "ruota" and not occupato():
				gira_la_ruota(-1 if bottone.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		MOUSE_BUTTON_LEFT:
			clic(q)
	accept_event()


func clic(q: Vector2) -> void:
	match momento:
		"ruota":
			clic_sulla_ruota(q)
		"bivio":
			clic_nel_bivio(q)
		_:
			var finto := InputEventAction.new()
			finto.action = "ui_accept"
			finto.pressed = true
			tasto_nel_racconto(finto)


func clic_sulla_ruota(q: Vector2) -> void:
	if occupato():
		return
	if indietro_qui.has_point(q):
		su_indietro.call()
		return
	for i in mini(linguette.size(), squadra.size()):
		if linguette[i].has_point(q):
			scegli(squadra[i])
			return
	if Rect2(PRENDI_A, Vector2(420, 40)).has_point(q):
		invio_sulla_ruota()


func clic_nel_bivio(q: Vector2) -> void:
	# il taglio e' storto: a destra di lui c'e' la strada di destra
	if prossimo != "" or preso_a >= 0.0:
		return
	var scelto := q.x > taglio_del_bivio() - (q.y / 760.0) * 120.0
	if scelto == a_destra:
		prendi_la_strada()
	else:
		a_destra = scelto


func tasti() -> void:
	# i tasti di ogni momento, disegnati come quelli veri, in un contenitore
	# loro: sotto la tendina
	if tasti_qui == null:
		return
	Albero.svuota(tasti_qui)
	match momento:
		"ruota":
			comandi(Vector2(30, 686), [["SU", "gira"], ["INVIO", "prendi"], ["ESC", "indietro"]], P.CARTA)
		"bivio":
			comandi(Vector2(54, 672), [["CLIC", "scegli"]], P.CARTA)
			comandi(Vector2(704, 672), [["INVIO", "prendi"], ["ESC", "ci penso"]], P.NERO)
		_:
			comandi(Vector2(40, 676), [["INVIO", "avanti"], ["ESC", "salta tutto"]], P.CARTA)


func comandi(dove: Vector2, coppie: Array, inchiostro: Color) -> void:
	var x := dove.x
	for voce: Array in coppie:
		var tappo := TappoTasto.nuovo(String(voce[0]))
		tasti_qui.add_child(tappo)
		tappo.position = Vector2(x, dove.y)
		tappo.size = tappo.get_combined_minimum_size()
		x += tappo.size.x + 8.0
		var parola := Tavola.scritta(String(voce[1]), 16, inchiostro, Caratteri.tondo(850))
		tasti_qui.add_child(parola)
		parola.position = Vector2(x, dove.y - 2.0)
		parola.size = Vector2(parola.get_combined_minimum_size().x, tappo.size.y + 4.0)
		x += parola.size.x + 24.0


# --- i fogli: chi disegna cosa ----------------------------------------------------------------

func disegna_sotto(t: CanvasItem) -> void:
	match momento:
		"bivio":
			disegna_bivio(t)
		"salto":
			disegna_salto(t)
		"carta":
			disegna_carta(t)
		_:
			# prima che si spacchi c'e' la ruota di adesso; dopo, quella nuova
			if spacca_a >= 0.0:
				ruota_sotto(t, giro_di(guardato), vista)
			else:
				ruota_sotto(t, giro_di(adesso if timbrato else guardato), vista_della_vecchia())


func disegna_vecchia(t: CanvasItem) -> void:
	ruota_sotto(t, giro_di(adesso), vista_della_vecchia())


func disegna_spacco(t: CanvasItem) -> void:
	if momento != "ruota":
		return
	if crepa_a >= 0.0 and spacca_a < 0.0:
		crepa(t, clampf((tempo - crepa_a) / 0.3, 0.0, 1.0))
	if spacca_a >= 0.0:
		meta_che_volano(t, clampf((tempo - spacca_a) / 0.8, 0.0, 1.0))


func disegna_sopra(t: CanvasItem) -> void:
	if momento != "ruota":
		return
	fascia_del_giro(t)
	lastra(t)
	punto_che_vola(t)
	if prendi_a >= 0.0:
		scatto(t, testo_prendi(), clampf((tempo - prendi_a) / 0.35, 0.0, 1.0))
	if vittoria_a >= 0.0:
		scatto(t, testo_prendi(), clampf((tempo - vittoria_a) / 0.35, 0.0, 1.0))
