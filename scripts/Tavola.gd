class_name Tavola
extends Control

# IL FOGLIO DA 1280x720 SU CUI SONO DISEGNATI IL NEGOZIO E LA SQUADRA.
#
# Bru disegna le schermate a 1280x720, la misura del gioco, e vuole che i
# pezzi stiano esattamente dove li ha messi. Qui dentro quindi si ragiona in
# pixel del suo disegno: una carta sta a 131,400 perche' nello schema sta a
# 131,400, e chi apre lo schema e questo codice legge gli stessi numeri.
#
# Il foglio poi si adatta alla finestra tutto intero, come una fotografia:
# si scala finche' ci sta, e si centra. E' la stessa cosa che fa Godot con
# tutto il gioco (stretch "canvas_items"), fatta una seconda volta per un
# motivo solo: «testo piu' grande» rimpicciolisce lo schermo utile a 1024x576,
# e un disegno a pixel fissi ci uscirebbe di sotto e di lato. Scalato, resta
# intero - al prezzo che in queste due schermate il testo grande non ingrandisce
# niente. I corpi qui non scendono mai sotto i 13 pixel apposta.

const LARGO := 1280.0
const ALTO := 720.0


static func su(genitore: Node) -> Tavola:
	var t := Tavola.new()
	genitore.add_child(t)
	return t


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(LARGO, ALTO)
	get_viewport().size_changed.connect(adatta)
	adatta()


func adatta() -> void:
	var vista := get_viewport_rect().size
	var quanto := minf(vista.x / LARGO, vista.y / ALTO)
	scale = Vector2(quanto, quanto)
	# la posizione e' quella nel genitore: chi ospita la tavola sta a tutto schermo
	position = (vista - Vector2(LARGO, ALTO) * quanto) * 0.5


static func metti(nodo: Control, dove: Rect2) -> Control:
	# un pezzo al suo posto nel disegno. Si scrive come nello schema: x, y,
	# larghezza, altezza
	nodo.position = dove.position
	nodo.size = dove.size
	return nodo


static func scritta(testo: String, corpo: int, colore: Color, font: Font = null,
		allinea := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	# un'etichetta coi soli attributi che servono qui: il resto lo da' il tema
	var e := Label.new()
	e.text = testo
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	e.horizontal_alignment = allinea
	e.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	e.add_theme_color_override("font_color", colore)
	if font != null:
		e.add_theme_font_override("font", font)
	Stile.imposta_corpo(e, corpo)
	return e


static func fuoco(nodo: Control) -> void:
	# IL FUOCO DATO DOPO, MA SOLO SE C'E' ANCORA A CHI DARLO. Il fuoco si da'
	# in differita (il nodo appena creato non e' ancora pronto), e nel frattempo
	# la schermata puo' essersi ridisegnata: grab_focus su un nodo gia' tolto
	# dall'albero e' un errore in console a ogni giro
	if is_instance_valid(nodo) and nodo.is_inside_tree() and nodo.is_visible_in_tree():
		nodo.grab_focus()


static func stringi(etichetta: Label, corpo: int, minimo: int) -> void:
	# UN NOME LUNGO NON ESCE DAL SUO POSTO e non va a capo: si rimpicciolisce,
	# fino a un minimo sotto cui non si legge piu'. Solo il corpo: la crenatura
	# l'ha messa scritta(), e rimetterla avvolgerebbe il carattere un'altra volta
	var f := etichetta.get_theme_font("font")
	var c := corpo
	while f != null and c > minimo \
			and f.get_string_size(etichetta.text, HORIZONTAL_ALIGNMENT_LEFT, -1, c).x > etichetta.size.x:
		c -= 1
	etichetta.add_theme_font_size_override("font_size", c)


static func ombra(etichetta: Label, colore: Color, spostamento := Vector2(3, 3)) -> void:
	# la sfoglia sotto una scritta: la stessa carta spostata dei cartigli, fatta
	# col testo. Non e' un contorno (quelli li fa solo Stile.contorno): e' uno
	# strato di carta dietro
	etichetta.add_theme_color_override("font_shadow_color", colore)
	etichetta.add_theme_constant_override("shadow_offset_x", int(spostamento.x))
	etichetta.add_theme_constant_override("shadow_offset_y", int(spostamento.y))
	etichetta.add_theme_constant_override("shadow_outline_size", 0)


static func entra(nodo: CanvasItem, ritardo: float, da := Vector2.ZERO) -> void:
	# l'entrata di un pezzo della tavola: si dissolve dentro arrivando da poco
	# lontano. Col movimento ridotto si dissolve e basta
	if nodo == null:
		return
	nodo.modulate.a = 0.0
	var t := nodo.create_tween().set_parallel()
	Movimento.verso(t, nodo, "modulate:a", 1.0, "entrata", Movimento.durata("entrata")).set_delay(ritardo)
	if Movimento.ridotto() or da == Vector2.ZERO or not nodo is Control:
		return
	var arrivo: Vector2 = (nodo as Control).position
	(nodo as Control).position = arrivo + da
	Movimento.verso(t, nodo, "position", arrivo, "entrata", Movimento.durata("entrata")).set_delay(ritardo)
