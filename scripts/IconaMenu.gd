class_name IconaMenu
extends RefCounted

# L'ICONCINA DEL MENU, IN ALTO A SINISTRA: la faccia di chi stai giocando, e
# si apre il menu (pausa, Data pad, squadra, opzioni). Bru l'ha disegnata come
# un quadrato rosso col muso dentro.
#
# STA DAPPERTUTTO, NON SOLO NEI DIALOGHI. Era di Main: sulla mappa stellare,
# nel Vuoto, sulla mappa di zona, alla Sede, nell'emporio il menu c'era lo
# stesso (con ESC) ma non si vedeva. Bru: «le opzioni devono essere sempre
# presenti». Quindi una sola iconcina, vestita in un posto solo, che ogni
# schermata del gioco si mette nello stesso angolo.

static func vesti(icona: Button) -> void:
	var lato := Stile.forma("icona_menu")
	icona.custom_minimum_size = Vector2(lato, lato)
	icona.size = Vector2(lato, lato)
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Stile.colore("manifesto")
	fondo.set_corner_radius_all(14)
	fondo.set_border_width_all(4)
	fondo.border_color = Stile.colore("bordo")
	fondo.shadow_color = Stile.colore("bordo")   # l'ombra piena del manifesto:
	fondo.shadow_size = 1                        # quasi senza sfumatura
	fondo.shadow_offset = Manifesto.OMBRA * 0.6
	for stato in ["normal", "hover", "pressed", "focus", "disabled"]:
		icona.add_theme_stylebox_override(stato, fondo)
	icona.tooltip_text = "Menu"
	icona.accessibility_name = "Menu"
	var faccia := TextureRect.new()
	faccia.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia.offset_left = 4
	faccia.offset_top = 4
	faccia.offset_right = -4
	faccia.offset_bottom = -4
	faccia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	faccia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	faccia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ritratto := ritratto_del_giocato()
	if ritratto != "":
		faccia.texture = load(ritratto)
	else:
		Manifesto.tre_righe(icona)   # finche' la faccia non c'e', il segno del menu
	icona.add_child(faccia)
	# come ESC: non a meta' di una dissolvenza, ne' due volte
	icona.pressed.connect(func() -> void:
		if not Pausa.aperta and Pausa.pausabile():
			Pausa.apri())


static func posto() -> Vector2:
	# lo stesso angolo in ogni schermata: dentro la cornice, in alto a sinistra
	var bordo := Stile.forma("cornice")
	return Vector2(bordo * 1.8, bordo * 1.8)


static func metti(dove: Control) -> Button:
	# un'iconcina nuova, gia' al suo posto, sopra tutto quello che c'e' in "dove"
	var icona := Button.new()
	icona.name = "IconaMenu"
	vesti(icona)
	icona.position = posto()
	dove.add_child(icona)
	return icona


static func ritratto_del_giocato() -> String:
	var id := GameState.id_protagonista
	var per_espressione := "res://art/personaggi/%s/neutra.png" % id
	if ResourceLoader.exists(per_espressione):
		return per_espressione
	var singolo := String(GameState.personaggi.get(id, {}).get("ritratto", ""))
	return singolo if singolo != "" and ResourceLoader.exists(singolo) else ""
