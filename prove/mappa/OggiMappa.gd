extends Control

# LA MAPPA DI OGGI, CON I NUMERI SOPRA: la stessa Casa Gigante delle proposte,
# disegnata dal gioco vero (MappaZona col suo plastico) dentro uno schermo a
# parte, rimpicciolita, e accanto cosa non va. I numeri si mettono dove il
# plastico dice che stanno le stanze, non a mano: cambiando la mappa, seguono.

const NERO := Color("#0b0908")
const CHIARO := Color("#ece6df")
const ARANCIO := Color("#f4931b")
const VISTA := Rect2(36, 118, 816, 459)
const X_ELENCO := 884.0
const PROBLEMI := [
	["Sei piani in un modellino solo", "le lastre si coprono: cosa sta sopra cosa?"],
	["Il modellino è piccolo", "27 stanze in un terzo dello schermo"],
	["I nomi si coprono", "tutti uguali, tutti insieme"],
	["Dove arrivo adesso?", "le stanze vicine sembrano le altre"],
	["Due anelli uguali", "il boss e chi ti aspetta"],
	["Le scale sono fili", "un capello fra un piano e l'altro"],
	["La riga in fondo ripete", "«Sei in: La scala» lo dice già la freccia"],
]

var schermo: SubViewport
var pianta: MappaZona
var sopra: Control


func prepara(_modello: RefCounted, _opz: Dictionary) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Manifesto.trama_dietro(self)
	schermo = SubViewport.new()
	schermo.size = Vector2i(1280, 720)
	schermo.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(schermo)
	pianta = load("res://scenes/MappaZona.tscn").instantiate()
	pianta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	schermo.add_child(pianta)
	var foto := TextureRect.new()
	foto.texture = schermo.get_texture()
	foto.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	foto.stretch_mode = TextureRect.STRETCH_SCALE
	foto.position = VISTA.position
	foto.size = VISTA.size
	foto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cornice := Control.new()
	cornice.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cornice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cornice.draw.connect(func() -> void:
		cornice.draw_rect(Rect2(VISTA.position + Vector2(10, 10), VISTA.size), NERO)
		cornice.draw_rect(VISTA.grow(5.0), NERO))
	add_child(cornice)
	add_child(foto)
	sopra = Control.new()
	sopra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sopra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sopra.draw.connect(numeri)
	add_child(sopra)


func _process(_delta: float) -> void:
	if sopra != null:
		sopra.queue_redraw()


func sul_foglio(punto: Vector2) -> Vector2:
	return VISTA.position + punto * VISTA.size / Vector2(1280, 720)


func della_stanza(id_stanza: String) -> Vector2:
	var p := pianta.plastico
	if p == null or not p.scatole.has(id_stanza):
		return Vector2(-100, -100)
	return sul_foglio(p.get_global_rect().position + p.cima(id_stanza))


func numeri() -> void:
	Manifesto.etichetta_tinta(sopra, Vector2(36, 62), "La mappa di oggi: cosa non va", 30, NERO, CHIARO)
	var p := pianta.plastico
	if p == null:
		return
	var vetro := sul_foglio(p.get_global_rect().position)
	var dove := [della_stanza("stanza_studi") + Vector2(-92, -26), vetro + Vector2(70, 70),
			della_stanza("ala_sinistra") + Vector2(-10, 18), della_stanza("grande_bagno") + Vector2(20, -6),
			(della_stanza("altare") + della_stanza("attico")) * 0.5 + Vector2(-60, 0), della_stanza("soffitta") + Vector2(-34, 16),
			sul_foglio(pianta.etichetta_stato.get_global_rect().get_center()) + Vector2(-110, 0)]
	for i in dove.size():
		bollo(sopra, dove[i], i + 1)
	# i due anelli: uno sul boss, uno su chi ti aspetta
	for id_stanza: String in ["altare", "camera_da_letto"]:
		var c := della_stanza(id_stanza) + Vector2(0, -16) * VISTA.size.x / 1280.0
		sopra.draw_arc(c, 13.0, 0.0, TAU, 32, ARANCIO, 3.0, true)
	var y := 128.0
	for i in PROBLEMI.size():
		bollo(sopra, Vector2(X_ELENCO + 14, y + 12), i + 1)
		sopra.draw_string(Caratteri.titolo(), Vector2(X_ELENCO + 36, y + 14), String(PROBLEMI[i][0]), HORIZONTAL_ALIGNMENT_LEFT, -1, 19, NERO)
		sopra.draw_string(Caratteri.tondo(700), Vector2(X_ELENCO + 36, y + 34), String(PROBLEMI[i][1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, NERO)
		y += 62.0


static func bollo(t: CanvasItem, c: Vector2, n: int) -> void:
	t.draw_circle(c + Vector2(2, 2), 13.0, NERO)
	t.draw_circle(c, 13.0, ARANCIO)
	t.draw_arc(c, 13.0, 0.0, TAU, 32, NERO, 2.5, true)
	var testo := str(n)
	var w := Caratteri.titolo().get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
	t.draw_string(Caratteri.titolo(), c + Vector2(-w * 0.5 - 1.0, 6.5), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, NERO)
