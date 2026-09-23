class_name Descrizione
extends Control

# IN BASSO A SINISTRA, COSA FA LA VOCE SCELTA. Nel riferimento di Bru e' un
# titolo breve e una o due righe («Play Co-Op, Get Better Loot / The more
# players in your game...»), con dietro l'inizio del titolo una pennellata di
# colore chiaro: la voce dice COSA, la descrizione dice PERCHE'.
#
# Segue il fuoco: passando da una voce all'altra la vecchia si spegne in un
# attimo e la nuova sale di qualche pixel mentre si accende. E' qui che vive
# anche quello che prima era la riga di consigli sotto il menu («ESC per la
# pausa, si salva alla Sede»): adesso sta nella voce COME SI GIOCA, e si legge
# quando serve.

const SALITA := 8.0

var titolo: Label
var corpo: Label
var giro: Tween
var macchia: PackedVector2Array
var lampo := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 0)
	colonna.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	colonna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(colonna)
	titolo = Label.new()
	if Caratteri.titolo() != null:
		titolo.add_theme_font_override("font", Caratteri.titolo())
	titolo.add_theme_font_size_override("font_size", Stile.dimensione("corpo"))
	titolo.add_theme_color_override("font_color", Stile.colore("menu_descrizione"))
	Stile.contorno(titolo, Stile.dimensione("corpo"))
	colonna.add_child(titolo)
	corpo = Label.new()
	if Caratteri.tondo(650) != null:
		corpo.add_theme_font_override("font", Caratteri.tondo(650))
	corpo.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	corpo.add_theme_color_override("font_color", Stile.colore("menu_descrizione"))
	Stile.contorno(corpo, Stile.dimensione("minuscolo"))
	corpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	colonna.add_child(corpo)
	macchia = VoceMacchia.macchia(20260923, 24)


func mostra(nuovo_titolo: String, nuovo_corpo: String) -> void:
	if nuovo_titolo == titolo.text and nuovo_corpo == corpo.text:
		return
	if giro != null:
		giro.kill()
	var righe := get_child(0) as Control
	if Movimento.ridotto() or titolo.text == "":
		scrivi(nuovo_titolo, nuovo_corpo)
		modulate.a = 1.0
		righe.position.y = 0.0
		return
	# le righe stanno appese con le ancore, non in un contenitore: la loro y a
	# riposo e' 0, e da li' si parte ogni volta - un cambio interrotto a meta'
	# non lascia la descrizione un po' piu' in basso
	giro = create_tween()
	Movimento.verso(giro, self, "modulate:a", 0.0, "uscita", Movimento.durata("colore"))
	giro.tween_callback(scrivi.bind(nuovo_titolo, nuovo_corpo))
	giro.tween_callback(func() -> void: righe.position.y = SALITA)
	Movimento.verso(giro, self, "modulate:a", 1.0, "entrata", Movimento.durata("voce"))
	Movimento.verso(giro.parallel(), righe, "position:y", 0.0, "entrata", Movimento.durata("voce"))


func scrivi(nuovo_titolo: String, nuovo_corpo: String) -> void:
	titolo.text = nuovo_titolo
	corpo.text = nuovo_corpo
	update_minimum_size()
	queue_redraw()


func _get_minimum_size() -> Vector2:
	# alta quanto le sue righe: e' appesa al fondo dello schermo e cresce verso
	# l'alto, quindi una riga in piu' la alza invece di mandarla fuori
	var righe := get_child(0) as Control
	return Vector2(0.0, righe.get_combined_minimum_size().y) if righe != null else Vector2.ZERO


func sottolinea() -> void:
	# premuta una voce che non porta altrove (i consigli di COME SI GIOCA): la
	# descrizione si fa avanti - la pennellata si accende e ricade
	if Movimento.ridotto():
		return
	lampo = 1.0
	var giu := create_tween()
	giu.tween_method(func(v: float) -> void:
		lampo = v
		queue_redraw(), 1.0, 0.0, Movimento.durata("quinta"))


func _draw() -> void:
	if titolo.text == "":
		return
	# la pennellata chiara in piedi a sinistra del titolo, come nel riferimento:
	# piu' larga in alto, dove il pennello si appoggia
	var punti := PackedVector2Array()
	var alto := titolo.size.y + 30.0
	for p in macchia:
		punti.append(Vector2(-22.0 + p.y * 26.0, -6.0 + p.x * alto))
	draw_colored_polygon(punti, Color(Stile.colore("menu_spruzzo"), 0.55 + 0.35 * lampo))
