class_name TappoTasto
extends Control

# UN TASTO COME SI VEDE SOTTO LE DITA: il tappo col bordo chiaro e il labbro
# piu' scuro sotto, che lo fa sembrare in rilievo. Le frecce sono triangoli e
# non caratteri (non tutti i caratteri le hanno), il mouse e' un mouse col
# tasto sinistro - o la rotella - acceso.

const ALTO := 32.0
const CORPO := 15

var nome := ""

static func nuovo(quale: String) -> TappoTasto:
	var tappo := TappoTasto.new()
	tappo.nome = quale
	tappo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tappo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return tappo

func _get_minimum_size() -> Vector2:
	match nome:
		"CLIC", "ROTELLA":
			return Vector2(26, ALTO + 6.0)
		"SU", "GIU":
			return Vector2(ALTO, ALTO)
	var carattere := Caratteri.tondo(850)
	var largo := 0.0
	if carattere != null:
		largo = carattere.get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, CORPO).x
	return Vector2(maxf(largo + 22.0, ALTO + 6.0), ALTO)

func _draw() -> void:
	match nome:
		"CLIC", "ROTELLA":
			mouse()
		_:
			tasto()

func tasto() -> void:
	var chiaro := Stile.colore("menu_chiaro")
	var corpo := Rect2(Vector2.ZERO, size)
	# il labbro sotto: lo stesso tappo, piu' scuro, spostato di tre pixel
	var labbro := StyleBoxFlat.new()
	labbro.bg_color = Stile.colore("menu_macchia")
	labbro.set_corner_radius_all(6)
	draw_style_box(labbro, Rect2(corpo.position + Vector2(0, 3), corpo.size))
	var faccia := StyleBoxFlat.new()
	faccia.bg_color = Stile.colore("menu_riga_accesa")
	faccia.set_border_width_all(2)
	faccia.border_color = chiaro
	faccia.set_corner_radius_all(6)
	draw_style_box(faccia, Rect2(corpo.position, corpo.size - Vector2(0, 2)))
	var centro := Vector2(size.x * 0.5, (size.y - 2.0) * 0.5)
	if nome == "SU" or nome == "GIU":
		var punta := -1.0 if nome == "SU" else 1.0
		draw_colored_polygon(PackedVector2Array([
			centro + Vector2(0, 7.0 * punta),
			centro + Vector2(-7.0, -5.0 * punta),
			centro + Vector2(7.0, -5.0 * punta)]), Stile.colore("menu_descrizione"))
		return
	var carattere := Caratteri.tondo(850)
	if carattere == null:
		return
	var base := Vector2(0.0, centro.y + carattere.get_ascent(CORPO) * 0.36)
	draw_string(carattere, base, nome, HORIZONTAL_ALIGNMENT_CENTER, size.x, CORPO,
			Stile.colore("menu_descrizione"))

func mouse() -> void:
	# il corpo arrotondato, la riga fra i due tasti, e acceso il pezzo che si
	# usa: il tasto sinistro per il clic, la rotella per scorrere
	var chiaro := Stile.colore("menu_chiaro")
	var acceso := Stile.colore("menu_descrizione")
	var corpo := Rect2(Vector2(1, 1), size - Vector2(2, 2))
	var raggio := int(corpo.size.x * 0.5)
	var guscio := StyleBoxFlat.new()
	guscio.bg_color = Stile.colore("menu_riga_accesa")
	guscio.set_border_width_all(2)
	guscio.border_color = chiaro
	guscio.set_corner_radius_all(raggio)
	draw_style_box(guscio, corpo)
	var meta := corpo.position.y + corpo.size.y * 0.44
	var centro_x := corpo.position.x + corpo.size.x * 0.5
	if nome == "CLIC":
		# il tasto sinistro pieno: lo stesso angolo tondo del guscio, solo in
		# alto a sinistra, dentro il bordo
		var tasto_sinistro := StyleBoxFlat.new()
		tasto_sinistro.bg_color = acceso
		tasto_sinistro.corner_radius_top_left = raggio - 2
		draw_style_box(tasto_sinistro, Rect2(corpo.position + Vector2(3, 3),
				Vector2(centro_x - corpo.position.x - 4.0, meta - corpo.position.y - 4.0)))
	draw_line(Vector2(corpo.position.x + 2.0, meta), Vector2(corpo.end.x - 2.0, meta), chiaro, 2.0)
	draw_line(Vector2(centro_x, corpo.position.y + 2.0), Vector2(centro_x, meta), chiaro, 2.0)
	if nome == "ROTELLA":
		# la rotella, piena, con un filo di scuro intorno perche' si stacchi
		# dalla riga che divide i tasti; e due frecce: su e giu'
		var rotella := Rect2(centro_x - 3.5, corpo.position.y + 5.0, 7.0, 12.0)
		draw_rect(rotella.grow(1.5), Stile.colore("menu_riga_accesa"))
		var ruota := StyleBoxFlat.new()
		ruota.bg_color = acceso
		ruota.set_corner_radius_all(3)
		draw_style_box(ruota, rotella)
		var sotto := corpo.end.y - 7.0
		draw_colored_polygon(PackedVector2Array([Vector2(centro_x, sotto - 9.0),
				Vector2(centro_x - 3.5, sotto - 5.0), Vector2(centro_x + 3.5, sotto - 5.0)]), chiaro)
		draw_colored_polygon(PackedVector2Array([Vector2(centro_x, sotto),
				Vector2(centro_x - 3.5, sotto - 4.0), Vector2(centro_x + 3.5, sotto - 4.0)]), chiaro)
