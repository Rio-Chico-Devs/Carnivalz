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
	etichetta.add_theme_font_size_override("font_size",
			corpo_che_entra(etichetta.get_theme_font("font"), etichetta.text, etichetta.size.x, corpo, minimo))


static func corpo_che_entra(f: Font, testo: String, largo: float, corpo: int, minimo: int) -> int:
	# il corpo piu' grande, tra corpo e minimo, a cui la scritta sta in largo.
	# Per chi scrive con draw_string, che altrimenti taglia ("PROTAGONIST")
	var c := corpo
	while f != null and c > minimo and f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, c).x > largo:
		c -= 1
	return c


static func stringi_a_capo(etichetta: Label, corpo: int, minimo: int) -> void:
	# COME stringi, PER UNA SCRITTA CHE VA A CAPO: si rimpicciolisce finche'
	# sta nella sua altezza e nessuna parola va spezzata a meta' - "CONVERTITO /
	# RE" e' peggio di un corpo in meno
	var f := etichetta.get_theme_font("font")
	var c := corpo
	while f != null and c > minimo and not ci_sta_a_capo(f, etichetta.text, etichetta.size, c):
		c -= 1
	etichetta.add_theme_font_size_override("font_size", c)


static func ci_sta_a_capo(f: Font, testo: String, spazio: Vector2, corpo: int) -> bool:
	for parola in testo.split(" ", false):
		if f.get_string_size(parola, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x > spazio.x:
			return false
	return f.get_multiline_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, spazio.x, corpo).y <= spazio.y


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
	# lontano. Col movimento ridotto si dissolve e basta.
	#
	# UN'ENTRATA ALLA VOLTA, e sempre verso casa. Cambiando linguetta due volte
	# di fila la seconda entrata partiva mentre la prima era a meta' strada, e
	# prendeva come arrivo il punto in cui le carte si trovavano in quel
	# momento: restavano storte di qualche pixel per sempre. Adesso la casa di
	# un pezzo si segna la prima volta, e l'entrata vecchia si ferma
	if nodo == null:
		return
	ferma_entrata(nodo)
	nodo.modulate.a = 0.0
	var t := nodo.create_tween().set_parallel()
	nodo.set_meta("entrata", t)
	Movimento.verso(t, nodo, "modulate:a", 1.0, "entrata", Movimento.durata("entrata")).set_delay(ritardo)
	if Movimento.ridotto() or da == Vector2.ZERO or not nodo is Control:
		return
	var arrivo: Vector2 = nodo.get_meta("casa")
	(nodo as Control).position = arrivo + da
	Movimento.verso(t, nodo, "position", arrivo, "entrata", Movimento.durata("entrata")).set_delay(ritardo)


static func ferma_entrata(nodo: CanvasItem) -> void:
	# l'entrata in corso finisce subito, al suo posto e tutta visibile: per chi
	# deve muovere il pezzo adesso (il carosello che gira) o farlo rientrare
	# (get_meta con null come riserva non basta: null vuol dire "nessuna riserva")
	var vecchia: Variant = nodo.get_meta("entrata") if nodo.has_meta("entrata") else null
	if vecchia is Tween and (vecchia as Tween).is_valid():
		(vecchia as Tween).kill()
		nodo.modulate.a = 1.0
	if nodo is Control:
		if not nodo.has_meta("casa"):
			nodo.set_meta("casa", (nodo as Control).position)
		(nodo as Control).position = nodo.get_meta("casa")
