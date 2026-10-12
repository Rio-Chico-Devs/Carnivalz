extends CanvasLayer

# LA FOTO DELLO SCHERMO, DA DENTRO IL GIOCO: F12.
#
# Bru: «non riesco a farti screen siccome ogni volta che apro lo snipping tool
# il gioco va in menu di pausa». E' giusto che vada in pausa (Pausa.gd: la
# finestra che perde il fuoco ferma il gioco), ma lo Strumento di cattura
# prende il fuoco per forza, e la foto veniva del menu di pausa invece che di
# quello che si voleva mostrare. Da dentro la finestra non perde niente: la
# foto e' esattamente il fotogramma che si sta guardando, senza il cursore e
# senza l'avviso, che compare dopo.
#
# Vanno nella cartella Immagini, in Carnivalz: dove le cerca chi le vuole
# mandare a qualcuno. Se il sistema non sa dire dov'e' Immagini, nella
# cartella dei dati del gioco; l'avviso dice sempre il percorso intero.

const LIVELLO := 129          # sopra il velo delle transizioni: l'avviso si vede sempre
const DURATA_AVVISO := 3.0
const LARGO_MASSIMO := 640.0  # oltre, il percorso va a capo invece di uscire dallo schermo

# chi fa la foto e dove la mette: le prove ne passano di finti (in --headless
# Godot non disegna, e una foto vera non c'e')
var fotografa := func() -> Image:
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()
var cartella := func() -> String:
	var immagini := OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	return immagini.path_join("Carnivalz") if immagini != "" else "user://foto"

var avviso: PanelContainer
var scritta: Label
var giro: Tween
var scattando := false


func _ready() -> void:
	layer = LIVELLO
	# anche a gioco in pausa, e a meta' di una transizione
	process_mode = Node.PROCESS_MODE_ALWAYS
	avviso = PanelContainer.new()
	avviso.add_theme_stylebox_override("panel", Manifesto.stile_etichetta(Stile.colore("bordo"), 14.0, 8.0))
	avviso.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	avviso.grow_vertical = Control.GROW_DIRECTION_BEGIN
	avviso.offset_left = 24.0
	avviso.offset_bottom = -24.0
	avviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avviso.visible = false
	scritta = Label.new()
	scritta.add_theme_color_override("font_color", Stile.colore("testo"))
	scritta.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	scritta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	avviso.add_child(scritta)
	add_child(avviso)


func _input(evento: InputEvent) -> void:
	if evento.is_action_pressed("foto") and not evento.is_echo():
		get_viewport().set_input_as_handled()
		scatta()


func scatta() -> String:
	# il percorso della foto salvata, o "" se non e' riuscita
	if scattando:
		return ""
	scattando = true
	avviso.visible = false   # non deve finire nella foto
	var immagine: Image = await fotografa.call()
	scattando = false
	if immagine == null or immagine.is_empty():
		mostra("La foto non è riuscita")
		return ""
	var dove: String = cartella.call()
	DirAccess.make_dir_recursive_absolute(dove)
	# i due punti non vanno nei nomi dei file di Windows
	var quando := Time.get_datetime_string_from_system(false, true).replace(":", ".")
	var percorso := dove.path_join("Carnivalz %s.png" % quando)
	var doppione := 2
	while FileAccess.file_exists(percorso):   # due foto nello stesso secondo
		percorso = dove.path_join("Carnivalz %s (%d).png" % [quando, doppione])
		doppione += 1
	if immagine.save_png(percorso) != OK:
		mostra("La foto non è riuscita: non si scrive in\n%s" % leggibile(dove))
		return ""
	mostra("Foto salvata in\n%s" % leggibile(percorso))
	return percorso


func leggibile(percorso: String) -> String:
	# il percorso come lo scrive Esplora file
	var vero := ProjectSettings.globalize_path(percorso)
	return vero.replace("/", "\\") if OS.get_name() == "Windows" else vero


func mostra(testo: String) -> void:
	scritta.text = testo
	var font := scritta.get_theme_font("font")
	var corpo := scritta.get_theme_font_size("font_size")
	var largo := 0.0
	for riga in testo.split("\n"):
		largo = maxf(largo, font.get_string_size(riga, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x)
	scritta.custom_minimum_size.x = minf(ceilf(largo) + 2.0, LARGO_MASSIMO)
	avviso.visible = true
	avviso.modulate.a = 1.0
	if giro != null:
		giro.kill()
	giro = create_tween()
	giro.tween_interval(DURATA_AVVISO)
	giro.tween_property(avviso, "modulate:a", 0.0, Stile.tempo("transizione_scena"))
	giro.tween_callback(func() -> void: avviso.visible = false)
