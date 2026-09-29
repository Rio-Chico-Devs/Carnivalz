class_name Manifesto
extends RefCounted

# LA LINGUA DEL MANIFESTO: i pezzi grafici che tengono insieme le schermate.
#
# Bru ha mandato un'immagine arancio, nera e grigio caldo e ha chiesto di
# uniformare l'interfaccia su quella. Il primo giro ricolorava e basta («non mi
# piacciono molto gli esempi»); il secondo prendeva i PEZZI dell'immagine, e
# quello e' stato approvato: «bene mi piace! approvato, metti questi intanto»
# (29 settembre). I pezzi sono questi, e stanno tutti qui perche' ogni
# schermata li chieda invece di ridisegnarseli:
#
#   Trama      il fondo arancio: anelli larghi appena piu' chiari, e il retino
#              a puntini che si addensa in un angolo
#   Carta      un pannello come un foglio: grigio caldo, contorno nero spesso,
#              un'ombra nera PIENA spostata di lato (non sfumata: stampata) e il
#              retino nell'angolo in basso a destra
#   Cabinato   lo schermo del cabinato: il vetro scuro dentro una cornice chiara
#              arrotondata, il contorno nero, l'ombra piena. Sono due pezzi -
#              il retro sotto quello che si vede nello schermo, il davanti sopra -
#              perche' gli angoli del vetro sono tondi anche sopra un disegno
#   etichetta  la fascia nera inclinata con la scritta chiara (uno StyleBox)
#   pillola    il tondo allungato dei tasti e dei contatori (uno StyleBox)
#   gettone    un segno tondo: gli status sotto le barre
#
# Dall'immagine si prende la LINGUA, non i marchi, i caratteri o i disegni.
# I colori stanno in data/stile.json (manifesto, retino, cornice_turno...).

const OMBRA := Vector2(8, 8)        # l'ombra piena: di quanto sta spostata
const INCLINA := 0.24               # le etichette: per ogni pixel d'altezza, tanto di lato
const PASSO_RETINO := 9.0


# --- i pezzi pronti ------------------------------------------------------------

static func trama_dietro(dove: Control, tinta_fondo := "manifesto") -> Trama:
	# il fondo arancio col suo disegno, sotto tutto quello che c'e' in "dove"
	var fondo := Trama.new()
	fondo.tinta = Stile.colore(tinta_fondo)
	dove.add_child(fondo)
	dove.move_child(fondo, 0)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return fondo


static func stile_etichetta(tinta: Color, largo := 16.0, alto := 4.0) -> StyleBoxFlat:
	# la fascia inclinata. Lo skew di Godot sposta il lato di sopra verso destra
	# e quello di sotto verso sinistra: i margini ne tengono conto, cosi' la
	# scritta sta dentro il parallelogramma e non sul suo spigolo
	var fascia := StyleBoxFlat.new()
	fascia.bg_color = tinta
	fascia.skew = Vector2(INCLINA, 0.0)
	fascia.content_margin_left = largo
	fascia.content_margin_right = largo
	fascia.content_margin_top = alto
	fascia.content_margin_bottom = alto
	fascia.anti_aliasing = true
	return fascia


static func stile_pillola(tinta: Color, margine := 16.0, bordo := Color(0, 0, 0, 0)) -> StyleBoxFlat:
	# gli angoli tondi quanto meta' dell'altezza, qualunque sia: Godot li
	# riduce da solo quando non ci stanno
	var tondo := StyleBoxFlat.new()
	tondo.bg_color = tinta
	tondo.set_corner_radius_all(999)
	tondo.anti_aliasing = true
	tondo.content_margin_left = margine
	tondo.content_margin_right = margine
	if bordo.a > 0.0:
		tondo.border_color = bordo
		tondo.set_border_width_all(3)
	return tondo


static func vesti_etichetta(scritta: Label, corpo: int, inchiostro := "testo", tinta := "bordo") -> void:
	# una Label diventa un'etichetta: il grottesco nero e corsivo, chiaro sulla
	# fascia nera
	scritta.add_theme_stylebox_override("normal", stile_etichetta(Stile.colore(tinta), corpo * 0.5, corpo * 0.12))
	scritta.add_theme_font_override("font", Caratteri.titolo())
	scritta.add_theme_font_size_override("font_size", corpo)
	scritta.add_theme_color_override("font_color", Stile.colore(inchiostro))


static func vesti_striscia(scritta: Label, corpo: int) -> void:
	# la riga sottile sotto un'etichetta: largo e spaziato, arancio sul nero
	scritta.add_theme_stylebox_override("normal", stile_etichetta(Stile.colore("bordo"), corpo * 0.6, corpo * 0.1))
	scritta.add_theme_font_override("font", Caratteri.striscia())
	scritta.add_theme_font_size_override("font_size", corpo)
	scritta.add_theme_color_override("font_color", Stile.colore("manifesto"))


static func vesti_voce(tasto: Button, corpo: int) -> void:
	# UNA VOCE DI MENU SULLA CARTA (il quadrante del combattimento): nera, e
	# quella scelta su un'etichetta nera con la scritta chiara. La scelta e' una
	# FORMA, non solo un colore: si vede anche da chi i colori non li distingue.
	# SI GIOCA ANCHE DA TASTIERA: le frecce scorrono le voci e INVIO sceglie.
	#
	# L'ETICHETTA NON E' LO STILE "focus": Godot lo disegna SOPRA la scritta, e
	# una fascia nera piena la coprirebbe (e' successo, col riquadro di prima).
	# Quando la voce prende il fuoco cambia il suo fondo normale; tutti gli
	# stati hanno gli stessi margini, cosi' la scritta non salta di lato
	tasto.flat = false   # un bottone "flat" non disegna i suoi fondi, e l'etichetta e' un fondo
	tasto.focus_mode = Control.FOCUS_ALL
	tasto.alignment = HORIZONTAL_ALIGNMENT_LEFT
	tasto.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN   # l'etichetta si stringe sulla parola
	tasto.custom_minimum_size = Vector2.ZERO
	tasto.set_meta("corpo_voce", corpo)
	tasto.add_theme_font_override("font", Caratteri.voci_strette())
	tasto.add_theme_font_size_override("font_size", corpo)
	tasto.add_theme_color_override("font_pressed_color", Stile.colore("box_testo"))
	for stato in ["font_hover_color", "font_hover_pressed_color"]:
		tasto.add_theme_color_override(stato, Stile.colore("testo"))
	tasto.add_theme_color_override("font_disabled_color", Stile.colore("comando_spento"))
	var acceso := stile_etichetta(Stile.colore("bordo"), corpo * 0.4, 0.0)
	for stato in ["hover", "hover_pressed"]:
		tasto.add_theme_stylebox_override(stato, acceso)
	for stato in ["pressed", "disabled"]:
		tasto.add_theme_stylebox_override(stato, spento_come(acceso))
	tasto.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var prima_volta := not tasto.has_meta("voce_accesa")
	accendi_voce(tasto, tasto.has_focus())
	if prima_volta:
		tasto.focus_entered.connect(func() -> void: accendi_voce(tasto, true))
		tasto.focus_exited.connect(func() -> void: accendi_voce(tasto, false))


static func accendi_voce(tasto: Button, si: bool) -> void:
	tasto.set_meta("voce_accesa", si)
	var corpo := int(tasto.get_meta("corpo_voce", 20))
	var acceso := stile_etichetta(Stile.colore("bordo"), corpo * 0.4, 0.0)
	if si:
		tasto.add_theme_stylebox_override("normal", acceso)
	else:
		tasto.add_theme_stylebox_override("normal", spento_come(acceso))
	var tinta := Stile.colore("testo") if si else Stile.colore("box_testo")
	for stato in ["font_color", "font_focus_color"]:
		tasto.add_theme_color_override(stato, tinta)


static func spento_come(acceso: StyleBox) -> StyleBoxEmpty:
	var vuoto := StyleBoxEmpty.new()
	for lato in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		vuoto.set_content_margin(lato, acceso.get_content_margin(lato))
	return vuoto


static func retino(tela: CanvasItem, dove: Rect2, tinta: Color, da := Vector2(0.5, 0.4)) -> void:
	# I PUNTINI DELLE OMBRE: nulli lontano dall'angolo in basso a destra, sempre
	# piu' grossi verso l'angolo. "da" e' dove cominciano, in frazioni
	var y := dove.size.y * da.y
	var riga := 0
	while y < dove.size.y - 3.0:
		riga_di_retino(tela, dove, y, riga % 2 == 1, tinta, da)
		y += PASSO_RETINO * 0.87
		riga += 1


static func riga_di_retino(tela: CanvasItem, dove: Rect2, y: float, sfalsata: bool, tinta: Color,
		da: Vector2) -> void:
	var x := dove.size.x * da.x + (PASSO_RETINO * 0.5 if sfalsata else 0.0)
	while x < dove.size.x - 3.0:
		var quanto := clampf((x / dove.size.x - da.x) * 2.4 + (y / dove.size.y - da.y) * 2.0 - 0.9, 0.0, 1.0)
		if quanto > 0.05:
			tela.draw_circle(dove.position + Vector2(x, y), PASSO_RETINO * 0.42 * quanto, tinta)
		x += PASSO_RETINO


# --- i disegni ------------------------------------------------------------------

class Trama extends Control:
	# IL FONDO ARANCIO: il colore pieno, gli anelli larghi centrati fuori
	# schermo a destra, appena piu' chiari, e il retino che si addensa verso
	# l'angolo in basso a sinistra. Si disegna una volta e basta
	var tinta := Color.ORANGE:
		set(nuova):
			tinta = nuova
			queue_redraw()

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), tinta)
		var chiaro := tinta.lightened(0.028)
		var centro := Vector2(size.x * 1.05, size.y * 0.45)
		var raggio := size.x * 0.18
		while raggio < size.x * 1.3:
			draw_arc(centro, raggio, 0.0, TAU, 160, chiaro, size.x * 0.03, true)
			raggio += size.x * 0.11
		var scuro := tinta.darkened(0.09)
		var passo := 11.0
		var y := 0.0
		var riga := 0
		while y < size.y + passo:
			var x := (passo * 0.5) if riga % 2 == 1 else 0.0
			while x < size.x + passo:
				var quanto := clampf((y / size.y) * 1.3 - (x / size.x) * 1.1 - 0.25, 0.0, 1.0)
				if quanto > 0.05:
					draw_circle(Vector2(x, y), passo * 0.42 * quanto, scuro)
				x += passo
			y += passo * 0.87
			riga += 1


class Carta extends Control:
	# UN PANNELLO COME UN FOGLIO: l'ombra nera piena spostata, il grigio caldo,
	# il retino nell'angolo, il contorno spesso. Sta DIETRO il contenuto (e' il
	# primo figlio del pannello), quindi il contorno lo disegna sopra il retino
	var tinta := Color.WHITE:
		set(nuova):
			tinta = nuova
			queue_redraw()
	var spessore := 5.0
	var con_retino := true

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)

	func _draw() -> void:
		Manifesto.carta(self, Rect2(Vector2.ZERO, size), tinta, spessore, con_retino)


static func carta(tela: CanvasItem, dove: Rect2, tinta: Color, spessore := 5.0, con_retino := true) -> void:
	# il foglio disegnato a mano, per chi disegna in _draw invece che coi nodi
	var nero := Stile.colore("bordo")
	tela.draw_rect(Rect2(dove.position + OMBRA, dove.size), nero)
	tela.draw_rect(dove, tinta)
	if con_retino:
		retino(tela, dove, Stile.colore("retino"))
	tela.draw_rect(dove.grow(-spessore * 0.5), nero, false, spessore)


class Cabinato extends Control:
	# IL RETRO DELLO SCHERMO: l'ombra piena, il contorno nero, la cornice chiara.
	# Quello che si vede nello schermo ci va sopra, e sopra ancora il Vetro (il
	# davanti), che arrotonda gli angoli e traccia il filo nero intorno.
	#
	# "color" come un ColorRect: la cornice di chi ha il turno si accende
	# scrivendo lo stesso campo di prima (Slot.gd, imposta_turno)
	var color := Color.WHITE:
		set(nuovo):
			color = nuovo
			queue_redraw()
			if davanti != null and is_instance_valid(davanti):
				davanti.color = nuovo
	var raggio := 22.0
	var bordo := 14.0           # quanto e' spessa la cornice chiara, contorno compreso
	var davanti: Vetro = null

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)

	func dentro() -> Rect2:
		# dove si vede lo schermo, nelle coordinate di chi contiene il cabinato
		return Rect2(position + Vector2.ONE * bordo, size - Vector2.ONE * bordo * 2.0)

	func _draw() -> void:
		var tondo := StyleBoxFlat.new()
		tondo.bg_color = Stile.colore("bordo")
		tondo.set_corner_radius_all(int(raggio))
		tondo.anti_aliasing = true
		draw_style_box(tondo, Rect2(OMBRA, size))
		draw_style_box(tondo, Rect2(Vector2.ZERO, size))
		tondo.bg_color = color
		tondo.set_corner_radius_all(int(raggio - 4.0))
		draw_style_box(tondo, Rect2(Vector2(4, 4), size - Vector2(8, 8)))


class Vetro extends Control:
	# IL DAVANTI DELLO SCHERMO: un anello del colore della cornice che copre gli
	# spigoli del disegno (cosi' il vetro ha gli angoli tondi) e il filo nero
	# che lo separa dalla cornice. Tutto quello che disegna e' FUORI dal vetro,
	# o proprio sul suo bordo: in mezzo non copre niente
	var color := Color.WHITE:
		set(nuovo):
			color = nuovo
			queue_redraw()
	var raggio := 12.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)

	func _draw() -> void:
		var anello := StyleBoxFlat.new()
		anello.draw_center = false
		anello.border_color = color
		anello.set_border_width_all(int(raggio))
		anello.set_corner_radius_all(int(raggio * 2.0))
		anello.anti_aliasing = true
		draw_style_box(anello, Rect2(-Vector2.ONE * raggio, size + Vector2.ONE * raggio * 2.0))
		var filo := StyleBoxFlat.new()
		filo.draw_center = false
		filo.border_color = Stile.colore("bordo")
		filo.set_border_width_all(3)
		filo.set_corner_radius_all(int(raggio))
		filo.anti_aliasing = true
		draw_style_box(filo, Rect2(Vector2.ZERO, size))


static func cabinato(dove: Control, schermo: Control, cornice := "bordo_acceso") -> Cabinato:
	# lo schermo "schermo", gia' figlio di "dove", va dentro un cabinato: il
	# retro gli va sotto, il vetro sopra. Chi chiama piazza il cabinato (il suo
	# rettangolo e' quello esterno) e mette lo schermo in cabinato.dentro()
	var retro := Cabinato.new()
	retro.color = Stile.colore(cornice)
	dove.add_child(retro)
	dove.move_child(retro, schermo.get_index())
	var vetro := Vetro.new()
	vetro.color = retro.color
	dove.add_child(vetro)
	dove.move_child(vetro, schermo.get_index() + 1)
	retro.davanti = vetro
	return retro


static func gettone(tela: CanvasItem, dove: Rect2) -> void:
	# UN SEGNO TONDO: nero, col suo fondo scuro e l'ombra piena. Chi lo usa ci
	# disegna sopra il simbolo (IconeStato), dopo: il segnale draw arriva prima
	# di _draw, e un gettone disegnato in _draw coprirebbe il simbolo
	var centro := dove.get_center()
	var r := minf(dove.size.x, dove.size.y) * 0.5
	var nero := Stile.colore("bordo")
	tela.draw_circle(centro + OMBRA * 0.5, r, nero, true, -1.0, true)
	tela.draw_circle(centro, r, nero, true, -1.0, true)
	tela.draw_circle(centro, r - 4.0, Stile.colore("pannello_chiaro"), true, -1.0, true)


static func tre_righe(tasto: Control) -> void:
	# il segno del menu: tre righe nere, al centro del tasto
	tasto.draw.connect(func() -> void:
		for i in 3:
			var y := tasto.size.y * (0.32 + i * 0.18)
			tasto.draw_line(Vector2(tasto.size.x * 0.27, y), Vector2(tasto.size.x * 0.73, y),
					Stile.colore("bordo"), maxf(tasto.size.y * 0.075, 3.0)))


static func cabinato_intorno(schermo: Control, cornice := "bordo_acceso") -> Cabinato:
	# LO STESSO, per uno schermo disposto con le ancore (il quadro dei dialoghi):
	# il retro prende le sue ancore ed e' piu' grande della cornice, il vetro
	# le prende com'e'. Cosi' seguono lo schermo a qualunque misura di finestra
	var retro := cabinato(schermo.get_parent(), schermo, cornice)
	for pezzo: Control in [retro, retro.davanti]:
		for lato in ["anchor_left", "anchor_top", "anchor_right", "anchor_bottom",
				"offset_left", "offset_top", "offset_right", "offset_bottom"]:
			pezzo.set(lato, schermo.get(lato))
	retro.offset_left -= retro.bordo
	retro.offset_top -= retro.bordo
	retro.offset_right += retro.bordo
	retro.offset_bottom += retro.bordo
	return retro


static func decora_box(box: Control) -> void:
	# IL BOX DEI DIALOGHI COME L'ESEMPIO ELEGANTE DI BRU, nella lingua del
	# manifesto: il bordo nero spesso e arrotondato (lo fa lo StyleBox), l'ombra
	# piena dietro, un filo sottile dentro e i rombi sui due lati
	var ombra := FregioBox.new()
	ombra.dietro = true
	box.add_child(ombra)
	var fregio := FregioBox.new()
	box.add_child(fregio)
	box.move_child(fregio, 0)   # sotto il testo


class FregioBox extends Control:
	# vive dentro un PanelContainer, che lo stira sul posto del contenuto: il
	# box intero, per lui, comincia a -position
	var dietro := false

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)

	func _ready() -> void:
		show_behind_parent = dietro

	func _draw() -> void:
		var tutto := Rect2(-position, get_parent_control().size)
		var raggio := Stile.forma("raggio_box")
		var forma := StyleBoxFlat.new()
		forma.anti_aliasing = true
		if dietro:
			forma.bg_color = Stile.colore("bordo")
			forma.set_corner_radius_all(raggio)
			draw_style_box(forma, Rect2(tutto.position + OMBRA, tutto.size))
			return
		forma.draw_center = false
		forma.border_color = Stile.colore("bordo")
		forma.set_border_width_all(2)
		forma.set_corner_radius_all(maxi(raggio - 10, 4))
		var bordo := float(Stile.forma("bordo_box"))
		draw_style_box(forma, tutto.grow(-bordo - 6.0))
		for x in [tutto.position.x + bordo * 0.5, tutto.end.x - bordo * 0.5]:
			rombo(Vector2(x, tutto.get_center().y), 15.0)

	func rombo(centro: Vector2, r: float) -> void:
		var punte := PackedVector2Array([centro + Vector2(0, -r), centro + Vector2(r, 0),
				centro + Vector2(0, r), centro + Vector2(-r, 0)])
		draw_colored_polygon(punte, Stile.colore("bordo"))
		var dentro := PackedVector2Array()
		for punta in punte:
			dentro.append(centro + (punta - centro) * 0.5)
		draw_colored_polygon(dentro, Stile.colore("manifesto"))
