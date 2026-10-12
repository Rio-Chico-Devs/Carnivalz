extends Node

# LE SCRITTE SI LEGGONO? Bru: «nell'inserimento nome giocatore non si legge la
# scritta, cerca per altri punti dove le scritte non sono visibili,
# specialmente nel menu principale in tutte le sue parti».
#
# Il nome era crema su un fondo crema: il colore della scritta e quello del
# fondo, ognuno giusto da solo, insieme davano zero. Un controllo del genere
# non si fa leggendo i colori nel codice - il fondo vero di una scritta e'
# quello che c'e' DIETRO a schermo, e puo' essere un foglio, una macchia, la
# luce del luna park. Qui si guarda la schermata vera, disegnata:
#
#   1. si fotografa la schermata com'e';
#   2. si rendono trasparenti tutte le scritte e si fotografa di nuovo;
#   3. si fotografa ancora com'era, per sapere cosa si muove da solo.
#
# Dove la prima e la seconda foto differiscono (e la prima e la terza no)
# ci sono le lettere: il colore delle lettere e' nella prima, quello che c'e'
# dietro nella seconda. Il contrasto e' quello delle WCAG 2.2: almeno 4,5:1,
# o 3:1 per il testo grande. Una scritta di cui non cambia nessun pixel non si
# vede: dello stesso colore del fondo, trasparente, coperta, fuori schermo.
#
# Non e' una prova e non fallisce: stampa le scritte che non vanno e salva le
# foto con le scritte cattive cerchiate di rosso, in scatti/leggibilita/.
#
#   ./prove/leggibilita.sh                  tutto il menu principale
#   ./prove/leggibilita.sh pausa            tutti i pannelli della pausa
#   ./prove/leggibilita.sh chi_sei_nome     un passo solo
#   ALTO_CONTRASTO=1 ./prove/leggibilita.sh, TESTO_GRANDE=1 ./prove/leggibilita.sh
#
# Le scritte disegnate a mano (draw_string: il pannello delle partite, i tasti
# disegnati) non si possono spegnere da fuori: quelle si guardano sulle foto.

const CARTELLA := "res://scatti/leggibilita/"
const CONTRASTO_MINIMO := 4.5      # WCAG 2.2 AA, testo normale
const CONTRASTO_GRANDE := 3.0      # AA per il testo grande
const CORPO_GRANDE := 24.0
const CORPO_MINIMO := 14.0         # sotto, su uno schermo 720p, si legge a fatica
const SOGLIA_LETTERA := 0.06       # quanto cambia un pixel che e' una lettera
const SOGLIA_FERMO := 0.02         # quanto puo' cambiare da solo un pixel fermo
const ATTESA := 50                 # fotogrammi perche' le entrate finiscano

const CHIAVI_COLORE := ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color",
		"font_hover_pressed_color", "font_disabled_color", "font_placeholder_color",
		"font_outline_color", "font_shadow_color", "font_selected_color", "font_uneditable_color",
		"default_color", "caret_color"]

const STATI := ["titolo", "menu", "menu_partite", "menu_voce_bassa", "nuova", "sovrascrivi",
		"chi_sei", "chi_sei_nome", "chi_sei_lei", "anonimo", "carica", "cancella", "conferma_cancella",
		"collezioni", "come", "come_storia", "come_scontro", "come_mappa", "come_mosse",
		"opzioni", "audio", "grafica", "accessibilita", "extra", "codice", "codice_scritto",
		"codice_sbagliato", "album", "bestiario", "compendio"]
# i pannelli della pausa sono fatti degli stessi pezzi (fogli, opzioni, voci)
const STATI_PAUSA := ["pausa_menu", "pausa_diario", "pausa_organizzazione", "pausa_messaggi",
		"pausa_zaino", "pausa_opzioni", "pausa_storico", "pausa_uscita", "pausa_squadra", "pausa_bestiario"]

var variante := "normale"
var trovati := 0
var righe_rapporto: Array[String] = []
var partite_create: Array[int] = []


func _ready() -> void:
	# le foto si fanno col mondo fermo (vedi misura_stato): questo nodo no
	process_mode = Node.PROCESS_MODE_ALWAYS
	var argomenti := OS.get_cmdline_user_args()
	var stati: Array = Array(argomenti) if not argomenti.is_empty() else STATI
	if argomenti.size() == 1 and argomenti[0] == "pausa":
		stati = STATI_PAUSA
	if OS.has_environment("ALTO_CONTRASTO"):
		Impostazioni.alto_contrasto = true
		Impostazioni.applica_alto_contrasto()
		variante = "alto_contrasto"
	if OS.has_environment("TESTO_GRANDE"):
		Impostazioni.testo_grande = true
		Impostazioni.applica_scala_testo()
		variante = "testo_grande" if variante == "normale" else variante + "_testo_grande"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARTELLA))
	partite_finte()
	for stato: String in stati:
		await misura_stato(stato)
	for slot in partite_create:
		GameState.elimina_slot(slot)
	righe_rapporto.append("")
	righe_rapporto.append("LEGGIBILITA' (%s): %d scritte da sistemare in %d schermate"
			% [variante, trovati, stati.size()])
	var testo := "\n".join(righe_rapporto)
	print(testo)
	var file := FileAccess.open(ProjectSettings.globalize_path(CARTELLA + "rapporto_%s.txt" % variante), FileAccess.WRITE)
	if file != null:
		file.store_string(testo + "\n")
	get_tree().quit()


func partite_finte() -> void:
	# due partite, come nelle foto del menu: servono a CARICA, CANCELLA, SOVRASCRIVI
	for dati: Array in [[2, "Bru", 4, 3030], [4, "Veronica", 2, 450]]:
		if GameState.ha_salvataggio_slot(int(dati[0])):
			continue
		GameState.nuova_partita()
		GameState.imposta_nome_protagonista(String(dati[1]))
		GameState.livelli[GameState.id_protagonista] = int(dati[2])
		GameState.tazo = int(dati[3])
		GameState.salva_slot(int(dati[0]))
		partite_create.append(int(dati[0]))
	GameState.nuova_partita()


func attendi(quanti: int) -> void:
	for i in quanti:
		await get_tree().process_frame


func prepara(stato: String) -> Dictionary:
	# la schermata, nel passo richiesto e assestata: "scena" e' quello da
	# togliere dopo, "radice" quello che si misura - con una domanda o la pausa
	# aperta, solo loro: quello che sta sotto il velo e' scurito apposta
	if stato.begins_with("pausa_"):
		return await prepara_pausa(stato.trim_prefix("pausa_"))
	match stato:
		"album", "bestiario", "compendio":
			var scena: Node = load("res://scenes/%s.tscn" % stato.capitalize()).instantiate()
			scena.process_mode = Node.PROCESS_MODE_PAUSABLE   # sotto un nodo che non si ferma mai
			add_child(scena)
			await attendi(ATTESA)
			return {"scena": scena, "radice": scena}
	MenuPrincipale.titolo_visto = false
	var schermo: MenuPrincipale = load("res://scenes/Menu.tscn").instantiate()
	schermo.process_mode = Node.PROCESS_MODE_PAUSABLE   # si ferma per le foto anche se questo nodo no
	add_child(schermo)
	await attendi(3)
	if stato != "titolo":
		schermo.entra_dal_titolo()
	match stato:
		"menu_voce_bassa":
			await attendi(ATTESA)
			(schermo.voci[4] as VoceMenu).bottone.grab_focus()
		"nuova": schermo.pagina_nuova()
		"sovrascrivi": schermo.pagina_sovrascrivi(2)
		"chi_sei", "chi_sei_nome", "chi_sei_lei":
			schermo.pagina_chi_sei(1)
			if stato == "chi_sei_lei":
				schermo.scegli_sesso("f")
			if stato == "chi_sei_nome":
				schermo.campo_nome.text = "Bruno"
				schermo.campo_nome.caret_column = 5
		"anonimo":
			schermo.pagina_chi_sei(1)
			schermo.al_via = func() -> void: pass
			await attendi(ATTESA)
			schermo.comincia()
			await attendi(ATTESA)
			return {"scena": schermo, "radice": schermo.domanda}
		"carica": schermo.pagina_carica()
		"cancella": schermo.pagina_cancella()
		"conferma_cancella": schermo.pagina_conferma_cancella(2)
		"collezioni": schermo.pagina_collezioni()
		"come": schermo.pagina_come_si_gioca()
		"come_storia": schermo.pagina_come_si_gioca("STORIA")
		"come_scontro": schermo.pagina_come_si_gioca("COMBATTIMENTO")
		"come_mappa": schermo.pagina_come_si_gioca("MAPPA")
		"come_mosse": schermo.pagina_come_si_gioca("MOSSE SPECIALI")
		"opzioni": schermo.pagina_opzioni()
		"audio": schermo.pagina_opzioni_di("Audio")
		"grafica": schermo.pagina_opzioni_di("Grafica")
		"accessibilita": schermo.pagina_opzioni_di("Accessibilità")
		"extra": schermo.pagina_extra()
		"codice", "codice_scritto", "codice_sbagliato":
			schermo.pagina_codice()
			if stato != "codice":
				schermo.campo_codice.text = "ABC123"
			if stato == "codice_sbagliato":
				schermo.riscatta()
	await attendi(ATTESA)
	if stato == "titolo":
		await aspetta_il_piu_spento(schermo.insegna)
	return {"scena": schermo, "radice": schermo}


func aspetta_il_piu_spento(insegna: Control) -> void:
	# l'invito pulsa: si legge quando e' al suo piu' spento, non per caso
	var invito: CanvasItem = null
	for figlio in insegna.get_children():
		if figlio is HBoxContainer:
			invito = figlio
	if invito == null:
		return
	var minimo := 1.0
	for i in 240:
		minimo = minf(minimo, invito.modulate.a)
		await get_tree().process_frame
	for i in 240:
		if invito.modulate.a <= minimo + 0.02:
			return
		await get_tree().process_frame


func prepara_pausa(pannello: String) -> Dictionary:
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	IngressoNodo.ultimo_esito = {}
	var scena: Node = load("res://scenes/Main.tscn").instantiate()
	scena.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(scena)
	await attendi(10)
	Pausa.apri()
	await attendi(5)
	match pannello:
		"messaggi": Pausa.mostra_messaggi()
		"organizzazione":
			Pausa.sezione_diario = "organizzazione"
			Pausa.mostra_diario()
		"diario": Pausa.mostra_diario()
		"zaino": Pausa.mostra_inventario()
		"opzioni": Pausa.mostra_opzioni()
		"storico": Pausa.mostra_storico()
		"uscita": Pausa.conferma_uscita()
		"squadra": Pausa.mostra_equipaggiamento()
		"bestiario": Pausa.apri_collezione(MenuPrincipale.SCENA_BESTIARIO)
	await attendi(ATTESA)
	return {"scena": scena, "radice": Pausa, "pausa": true}


func misura_stato(stato: String) -> void:
	var pronta := await prepara(stato)
	var scena: Node = pronta["scena"]
	var scritte := scritte_in(pronta["radice"])
	# IL MONDO FERMO: il luna park, le luci e gli inviti pulsano, e fra una foto
	# e l'altra cambierebbero da soli. Fermo l'albero (la pausa e' gia' ferma)
	var era_fermo := get_tree().paused
	get_tree().paused = true
	# il cursore del campo lampeggia: spento per tutte e tre le foto
	var spenti := {}
	for c: Control in scritte:
		if c is LineEdit:
			spenti[c] = (c as LineEdit).get_theme_color("caret_color")
			c.add_theme_color_override("caret_color", Color(0, 0, 0, 0))
	var com_era := await foto()
	var ricordo := nascondi(scritte)
	var senza := await foto()
	rimetti(ricordo)
	var di_nuovo := await foto()
	get_tree().paused = era_fermo
	for c: Control in spenti:
		if is_instance_valid(c):
			c.add_theme_color_override("caret_color", spenti[c])
	var cattive: Array[Rect2i] = []
	var righe: Array[String] = []
	for c: Control in scritte:
		if not is_instance_valid(c):
			continue
		var esito := giudica(c, com_era, senza, di_nuovo)
		if esito.is_empty():
			continue
		trovati += 1
		cattive.append(esito["riquadro"])
		righe.append("  - %s «%s»: %s" % [esito["dove"], esito["testo"], esito["perche"]])
	righe_rapporto.append("[%s] %d scritte, %d da sistemare" % [stato, scritte.size(), righe.size()])
	righe_rapporto.append_array(righe)
	cerchia(com_era, cattive)
	com_era.save_png(ProjectSettings.globalize_path(CARTELLA + "%s_%s.png" % [variante, stato]))
	if pronta.get("pausa", false):
		Pausa.chiudi()
	scena.queue_free()
	await attendi(3)


func foto() -> Image:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var immagine := get_viewport().get_texture().get_image()
	immagine.convert(Image.FORMAT_RGBA8)
	return immagine


func scritte_in(radice: Node) -> Array[Control]:
	# ogni controllo che mostra una scritta e che si vede
	var elenco: Array[Control] = []
	for n in radice.find_children("*", "Control", true, false):
		var c := n as Control
		if not c.is_visible_in_tree() or testo_di(c).strip_edges() == "" or tagliata_da_uno_scorrimento(c):
			continue
		if c is Label or c is Button or c is LineEdit or c is RichTextLabel:
			elenco.append(c)
	return elenco


func testo_di(c: Control) -> String:
	if c is LineEdit:
		var riga := c as LineEdit
		return riga.text if riga.text != "" else riga.placeholder_text
	if c is RichTextLabel:
		return (c as RichTextLabel).get_parsed_text()
	if c is Label:
		return (c as Label).text
	if c is Button:
		return (c as Button).text
	return ""


func nascondi(scritte: Array[Control]) -> Array:
	# lettere trasparenti, riquadri e disegni intatti: niente si sposta
	var ricordo: Array = []
	for c: Control in scritte:
		var prima := {}
		for chiave: String in CHIAVI_COLORE:
			if c.has_theme_color_override(chiave):
				prima[chiave] = c.get_theme_color(chiave)
			c.add_theme_color_override(chiave, Color(0, 0, 0, 0))
		var voce := {"c": c, "colori": prima}
		if c is Label and (c as Label).label_settings != null:
			var vere := (c as Label).label_settings
			var vuote := vere.duplicate() as LabelSettings
			vuote.font_color = Color(0, 0, 0, 0)
			vuote.outline_color = Color(0, 0, 0, 0)
			vuote.shadow_color = Color(0, 0, 0, 0)
			(c as Label).label_settings = vuote
			voce["impostazioni"] = vere
		if c is RichTextLabel:
			voce["quante"] = (c as RichTextLabel).visible_ratio
			(c as RichTextLabel).visible_ratio = 0.0
		ricordo.append(voce)
	return ricordo


func rimetti(ricordo: Array) -> void:
	for voce: Dictionary in ricordo:
		var c := voce["c"] as Control
		if not is_instance_valid(c):
			continue
		for chiave: String in CHIAVI_COLORE:
			c.remove_theme_color_override(chiave)
		for chiave: String in voce["colori"]:
			c.add_theme_color_override(chiave, voce["colori"][chiave])
		if voce.has("impostazioni"):
			(c as Label).label_settings = voce["impostazioni"]
		if voce.has("quante"):
			(c as RichTextLabel).visible_ratio = voce["quante"]


func riquadro_a_schermo(c: Control, immagine: Image) -> Rect2i:
	var r := Rect2i(a_schermo(c)).intersection(Rect2i(0, 0, immagine.get_width(), immagine.get_height()))
	# un elenco che scorre taglia quello che ha fuori vista: si guarda solo la
	# parte che si vede davvero
	var su := c.get_parent()
	while su != null:
		if su is Control and (su as Control).clip_contents and (su as Control).is_visible_in_tree():
			r = r.intersection(Rect2i(a_schermo(su as Control)))
		su = su.get_parent()
	return r


func a_schermo(c: Control) -> Rect2:
	var trasformata := get_viewport().get_final_transform() * c.get_global_transform_with_canvas()
	return trasformata * Rect2(Vector2.ZERO, c.size)


func tagliata_da_uno_scorrimento(c: Control) -> bool:
	# fuori dalla parte visibile di un elenco che scorre, o con meno di meta'
	# dentro: non e' un difetto, basta scorrere
	var mia := a_schermo(c)
	var su := c.get_parent()
	while su != null:
		if su is ScrollContainer:
			var vista := a_schermo(su as Control).intersection(mia)
			if not vista.has_area() or vista.size.y < mia.size.y * 0.5:
				return true
		su = su.get_parent()
	return false


func scritta_a_mano(c: Control) -> bool:
	# un controllo che la scritta la disegna da se' (draw_string): i colori del
	# tema non la toccano, e la seconda foto la trova ancora li'
	var copione := c.get_script() as Script
	return copione != null and copione.source_code.contains("draw_string(")


func corpo_a_schermo(c: Control) -> float:
	var chiave := "normal_font_size" if c is RichTextLabel else "font_size"
	var corpo := float(c.get_theme_font_size(chiave))
	if c is Label and (c as Label).label_settings != null:
		corpo = float((c as Label).label_settings.font_size)
	var trasformata := get_viewport().get_final_transform() * c.get_global_transform_with_canvas()
	return corpo * trasformata.get_scale().y


func giudica(c: Control, com_era: Image, senza: Image, di_nuovo: Image) -> Dictionary:
	# vuoto se la scritta si legge; altrimenti dove, cosa, e perche'
	var r := riquadro_a_schermo(c, com_era)
	var dove := String(get_tree().root.get_path_to(c)).replace("@", "")
	var testo := testo_di(c).strip_edges().replace("\n", " ").left(40)
	var esito := {"riquadro": r, "dove": dove.right(60), "testo": testo}
	if r.size.x < 2 or r.size.y < 2:
		esito["perche"] = "fuori dallo schermo"
		return esito
	var lettere: Array[Vector2i] = []
	var forza: Array[float] = []
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var a := com_era.get_pixel(x, y)
			var b := senza.get_pixel(x, y)
			var d := maxf(maxf(absf(a.r - b.r), absf(a.g - b.g)), absf(a.b - b.b))
			if d < SOGLIA_LETTERA:
				continue
			var ferma := di_nuovo.get_pixel(x, y)
			if maxf(maxf(absf(a.r - ferma.r), absf(a.g - ferma.g)), absf(a.b - ferma.b)) > SOGLIA_FERMO:
				continue   # si muove da solo: non e' una lettera
			lettere.append(Vector2i(x, y))
			forza.append(d)
	if lettere.size() < 12 and scritta_a_mano(c):
		# la stima regge sui bottoni alti una riga; su una carta grande dentro
		# c'e' soprattutto fondo e disegno, e quella si guarda sulla foto
		return stima_dai_colori(c, com_era, r, esito) if r.size.y <= 60 else {}
	if lettere.size() < 12:
		esito["perche"] = "non si vede (stesso colore del fondo, trasparente o coperta)"
		return esito
	# il cuore delle lettere: i pixel che cambiano di piu', non i bordi sfumati
	var ordine := range(lettere.size())
	ordine.sort_custom(func(i: int, j: int) -> bool: return forza[i] > forza[j])
	var cuore := ordine.slice(0, maxi(6, floori(ordine.size() * 0.25)))
	var inchiostro := mediana(cuore.map(func(i: int) -> Color: return com_era.get_pixelv(lettere[i])))
	var fondo := mediana(cuore.map(func(i: int) -> Color: return senza.get_pixelv(lettere[i])))
	var contrasto := rapporto_di_contrasto(inchiostro, fondo)
	var corpo := corpo_a_schermo(c)
	var serve := CONTRASTO_GRANDE if corpo >= CORPO_GRANDE else CONTRASTO_MINIMO
	var difetti: Array[String] = []
	if contrasto < serve:
		difetti.append("contrasto %.1f:1 (ne serve %.1f) - scritta %s su %s" % [contrasto, serve,
				inchiostro.to_html(false), fondo.to_html(false)])
	if corpo < CORPO_MINIMO:
		difetti.append("piccola (%.0f px)" % corpo)
	var esce := esce_dal_riquadro(c)
	if esce != "":
		difetti.append(esce)
	if difetti.is_empty():
		return {}
	esito["perche"] = "; ".join(difetti)
	return esito


func stima_dai_colori(c: Control, com_era: Image, r: Rect2i, esito: Dictionary) -> Dictionary:
	# LA SCRITTA DISEGNATA A MANO non si spegne da fuori: si guarda la foto.
	# Dentro il riquadro (senza i bordi, dove stanno le forme oblique) il colore
	# piu' comune e' il fondo; i pixel piu' lontani da lui sono le lettere
	var dentro := r.grow_individual(-int(r.size.x * 0.12), -int(r.size.y * 0.2),
			-int(r.size.x * 0.12), -int(r.size.y * 0.2))
	if dentro.size.x < 4 or dentro.size.y < 4:
		return {}
	var tutti: Array = []
	for y in range(dentro.position.y, dentro.end.y):
		for x in range(dentro.position.x, dentro.end.x):
			tutti.append(com_era.get_pixel(x, y))
	var fondo := mediana(tutti)
	tutti.sort_custom(func(a: Color, b: Color) -> bool: return distanza(a, fondo) > distanza(b, fondo))
	var inchiostro := mediana(tutti.slice(0, maxi(6, floori(tutti.size() * 0.1))))
	var contrasto := rapporto_di_contrasto(inchiostro, fondo)
	var serve := CONTRASTO_GRANDE if corpo_a_schermo(c) >= CORPO_GRANDE else CONTRASTO_MINIMO
	if contrasto >= serve:
		return {}
	esito["perche"] = "contrasto %.1f:1 (ne serve %.1f, stimato dalla foto: la scritta e' disegnata a mano) - %s su %s" % [
			contrasto, serve, inchiostro.to_html(false), fondo.to_html(false)]
	return esito


static func distanza(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)


func esce_dal_riquadro(c: Control) -> String:
	# una riga sola piu' larga del suo posto: tagliata, coi puntini, o fuori
	if c is Label:
		var l := c as Label
		if l.autowrap_mode != TextServer.AUTOWRAP_OFF:
			return "tagliata (%d righe su %d)" % [l.get_visible_line_count(), l.get_line_count()] \
					if l.get_visible_line_count() < l.get_line_count() else ""
		var font := l.label_settings.font if l.label_settings != null and l.label_settings.font != null else l.get_theme_font("font")
		var corpo := l.label_settings.font_size if l.label_settings != null else l.get_theme_font_size("font_size")
		var largo := 0.0
		for riga in l.text.split("\n"):
			largo = maxf(largo, font.get_string_size(riga, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x)
		if largo > l.size.x + 2.0:
			return "piu' larga del suo posto (%.0f su %.0f px)" % [largo, l.size.x]
	return ""


static func luminanza(c: Color) -> float:
	var canali: Array[float] = []
	for v: float in [c.r, c.g, c.b]:
		canali.append(v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4))
	return 0.2126 * canali[0] + 0.7152 * canali[1] + 0.0722 * canali[2]


static func rapporto_di_contrasto(a: Color, b: Color) -> float:
	var la := luminanza(a)
	var lb := luminanza(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


static func mediana(colori: Array) -> Color:
	var r: Array[float] = []
	var g: Array[float] = []
	var b: Array[float] = []
	for c: Color in colori:
		r.append(c.r)
		g.append(c.g)
		b.append(c.b)
	r.sort()
	g.sort()
	b.sort()
	var m := floori(r.size() * 0.5)
	return Color(r[m], g[m], b[m])


func cerchia(immagine: Image, riquadri: Array[Rect2i]) -> void:
	var rosso := Color(1, 0, 0)
	for r in riquadri:
		var fuori := r.grow(2).intersection(Rect2i(0, 0, immagine.get_width(), immagine.get_height()))
		if fuori.size.x < 1 or fuori.size.y < 1:
			continue
		for lato in [Rect2i(fuori.position, Vector2i(fuori.size.x, 2)),
				Rect2i(Vector2i(fuori.position.x, fuori.end.y - 2), Vector2i(fuori.size.x, 2)),
				Rect2i(fuori.position, Vector2i(2, fuori.size.y)),
				Rect2i(Vector2i(fuori.end.x - 2, fuori.position.y), Vector2i(2, fuori.size.y))]:
			immagine.fill_rect(lato, rosso)
