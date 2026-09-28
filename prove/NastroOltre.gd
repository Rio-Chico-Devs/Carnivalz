extends RefCounted

# OLTRE IL NASTRO APPROVATO: proposte per Bru, non il gioco.
#
# Bru ha approvato il nastro strappato col fregio (scripts/NastroStrappato.gd)
# e poi: «per curiosita' voglio vedere quale e' il tuo limite, vediamo se sai
# fare ancora meglio». Queste sono le risposte, messe SOPRA il nastro vero del
# gioco per fotografarle:
#
#   ./prove/scatto.sh nodo infermeria_risveglio 5 oltre=carta,impresso
#
# Nel gioco non c'e' niente di tutto questo finche' Bru non ne sceglie
# qualcosa: allora quel pezzo passa in NastroStrappato, con le sue prove.
#
#   carta       la carta vera: la grana, le fibre, e lungo lo strappo l'anima
#               bianca della carta che esce dal colore, con qualche fibra fuori
#   impresso    il nome stampato a caratteri mobili: la lettera entra nella
#               carta (un filo di luce sotto ogni asta) e l'inchiostro non
#               copre tutto uguale
#   arlecchino  i rombi d'arlecchino dell'esempio di Bru, rosa su rosa, e il
#               filetto dei manifesti teatrali (uno grosso e uno fine)
#   fregi       ognuno il suo fregio, dai caratteri dei tipografi
#   ombra       il nastro fa ombra, e l'ombra si stringe quando si posa
#   arrivo      rifa' entrare il nastro e ne fa una pellicola a grandezza vera
#               (scatti/nastro_oltre_arrivo.png)
#   nome:X      scrive X sul nastro, per fotografare un altro personaggio

# IL FREGIO DI CIASCUNO. Non a caso: la foglia ❧ e' chi e' in scena; il cuore
# fiorito ❦ e' Veronica; la foglia girata ☙ e' chi non si conosce ancora; la
# manina ☞ dei tipografi (quella che nei margini dei libri indica "guarda qui")
# e' chi annuncia - altoparlante, computer, Guida
const FREGI := {"Veronica": "❦", "???": "☙", "Altoparlante": "☞", "Computer": "☞", "Guida": "☞"}

const GRANA := """
shader_type canvas_item;
// la carta: mai dello stesso colore da un punto all'altro, con la grana fine
// e le fibre lunghe della carta giapponese dei nastri (washi)
varying vec2 posto;
float caso(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float rumore(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(caso(i), caso(i + vec2(1.0, 0.0)), u.x), mix(caso(i + vec2(0.0, 1.0)), caso(i + vec2(1.0, 1.0)), u.x), u.y);
}
void vertex() { posto = VERTEX; }
void fragment() {
	float nuvola = rumore(posto * 0.05) - 0.5;
	float punto = caso(floor(posto)) - 0.5;
	// le fibre non sono dritte: il posto si torce un po' prima di cercarle
	vec2 torto = posto + 9.0 * vec2(rumore(posto * 0.035), rumore(posto * 0.035 + 5.0));
	mat2 storto = mat2(vec2(0.6, 0.8), vec2(-0.8, 0.6));
	float fibra = max(smoothstep(0.76, 0.97, rumore(torto * vec2(0.1, 0.75))),
			smoothstep(0.78, 0.97, rumore((storto * torto) * vec2(0.75, 0.08) + 11.0)));
	vec3 c = COLOR.rgb * (1.0 + nuvola * 0.07 + punto * 0.045);
	COLOR.rgb = mix(c, vec3(1.0, 0.97, 0.98), fibra * 0.2);
}
"""

const INCHIOSTRO := """
shader_type canvas_item;
// l'inchiostro dei caratteri mobili: dove il piombo ha preso meno inchiostro
// il nero e' piu' magro, e qua e la' un puntino di carta resta scoperto
varying vec2 posto;
float caso(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float rumore(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(caso(i), caso(i + vec2(1.0, 0.0)), u.x), mix(caso(i + vec2(0.0, 1.0)), caso(i + vec2(1.0, 1.0)), u.x), u.y);
}
void vertex() { posto = VERTEX; }
void fragment() {
	float magro = rumore(posto * 0.09);
	float scoperto = step(0.93, caso(floor(posto / 1.5)));
	COLOR.a *= (0.9 + 0.1 * magro) * (1.0 - 0.55 * scoperto);
}
"""


static func vesti(schermata: Node, quali: PackedStringArray) -> void:
	for quale in quali:
		if quale.begins_with("nome:"):
			schermata.nome_sul_nastro = ""
			await schermata.aggiorna_nastro(quale.trim_prefix("nome:"))
			for i in 50:
				await schermata.get_tree().process_frame
	var carta: NastroStrappato = schermata.carta_nastro
	var scritta: Label = schermata.nome_nastro
	# in quest'ordine, qualunque sia quello chiesto: la copia di luce del nome
	# impresso va fatta dopo che il fregio ha deciso dove comincia il nome
	for quale in ["fregi", "carta", "arlecchino", "impresso", "ombra"]:
		if not quale in quali:
			continue
		match quale:
			"carta": carta_vera(carta)
			"impresso": impresso(scritta)
			"arlecchino": arlecchino(carta)
			"fregi": fregio_di_ciascuno(schermata, carta, scritta.text)
			"ombra": ombra(schermata, carta)


static func pellicola_dell_arrivo(schermata: Node, dove: String) -> void:
	# IL NASTRO CHE ENTRA, ritagliato a grandezza vera: otto fotogrammi, uno
	# ogni tre, due per riga. L'entrata e' quella disegnata da Bru; si guarda
	# l'ombra, che da lontana e larga si stringe quando il nastro si posa
	schermata.lancia_il_nastro()
	var ritaglio := Rect2i(0, 360, 620, 230)
	var foglio := Image.create(ritaglio.size.x * 2, ritaglio.size.y * 4, false, Image.FORMAT_RGBA8)
	for i in 8:
		await RenderingServer.frame_post_draw
		var fotogramma := schermata.get_viewport().get_texture().get_image()
		fotogramma.convert(Image.FORMAT_RGBA8)
		foglio.blit_rect(fotogramma, ritaglio, Vector2i((i % 2) * ritaglio.size.x, floori(i / 2.0) * ritaglio.size.y))
		for attesa in 3:
			await schermata.get_tree().process_frame
	foglio.save_png(ProjectSettings.globalize_path(dove))


static func carta_vera(carta: NastroStrappato) -> void:
	var grana := ShaderMaterial.new()
	grana.shader = Shader.new()
	grana.shader.code = GRANA
	carta.material = grana
	var bordi := BordiStrappati.new()
	bordi.carta = carta
	carta.add_sibling(bordi)
	bordi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	carta.draw.connect(bordi.queue_redraw)


static func impresso(scritta: Label) -> void:
	# la luce sotto le aste: una copia del nome, chiara, un pixel e mezzo piu'
	# in basso, dietro. E' quello che si vede di una lettera premuta nella carta
	var luce := scritta.duplicate() as Label
	luce.material = null
	luce.add_theme_color_override("font_color", Color(1.0, 0.95, 0.97, 0.55))
	luce.add_theme_color_override("font_shadow_color", Color(1.0, 1.0, 1.0, 0.0))
	scritta.add_sibling(luce)
	scritta.get_parent().move_child(luce, scritta.get_index())
	luce.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	luce.position.y += 1.5
	var inchiostro := ShaderMaterial.new()
	inchiostro.shader = Shader.new()
	inchiostro.shader.code = INCHIOSTRO
	scritta.material = inchiostro


static func arlecchino(carta: NastroStrappato) -> void:
	var stampa := Arlecchino.new()
	stampa.colore = carta.colore
	carta.add_child(stampa)
	carta.move_child(stampa, 0)
	stampa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# la stampa sta sulla carta e non fuori: si ritaglia sulla forma strappata
	carta.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW


static func fregio_di_ciascuno(schermata: Node, carta: NastroStrappato, nome: String) -> void:
	carta.fregio.text = String(FREGI.get(nome, NastroStrappato.misura("fregio", "❧")))
	carta.vesti_la_scritta(carta.scritta)
	schermata.applica_nastro(null)
	carta._al_cambio_di_misura()


static func ombra(schermata: Node, carta: NastroStrappato) -> void:
	var sotto := Ombra.new()
	sotto.carta = carta
	sotto.schermata = schermata
	carta.add_sibling(sotto)
	carta.get_parent().move_child(sotto, carta.get_index())
	sotto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


class BordiStrappati extends Control:
	# L'ANIMA BIANCA DELLA CARTA. Il colore di una carta colorata sta in
	# superficie: dove si strappa esce il bianco di dentro, una striscia
	# irregolare larga uno, due, tre pixel, e qualche fibra che resta fuori
	var carta: NastroStrappato

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if carta == null or not carta.visible:
			return
		var bordo := carta.contorno()
		var meta := int(bordo.size() / 2.0)
		var caso := RandomNumberGenerator.new()
		caso.seed = carta.seme + 1
		for lato in 2:
			var fuori := bordo.slice(0, meta) if lato == 0 else bordo.slice(meta)
			var verso := -1.0 if lato == 0 else 1.0   # verso l'interno della carta
			var dentro := PackedVector2Array()
			var largo := 1.6
			for punto in fuori:
				largo = clampf(largo + caso.randf_range(-0.7, 0.7), 0.6, 3.4)
				dentro.append(punto + Vector2(verso * largo, 0.0))
				# qualche fibra resta fuori dallo strappo
				if caso.randf() < 0.22:
					var lunga := caso.randf_range(1.5, 4.5)
					var fine := punto + Vector2(-verso * lunga, caso.randf_range(-2.0, 2.0))
					draw_line(punto, fine, Color(1.0, 0.97, 0.98, 0.55), 1.0, true)
			dentro.reverse()
			draw_colored_polygon(fuori + dentro, Color(1.0, 0.95, 0.96, 0.8))


class Arlecchino extends Control:
	# I ROMBI D'ARLECCHINO, rosa su rosa come un nastro di carta stampato: tutti
	# i rombi, a due toni vicinissimi, che si vedono solo guardandoli. E lungo
	# i due bordi dritti un filetto fine, come quelli dei manifesti teatrali
	var colore := Color.PINK

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var passo := Vector2(22.0, 30.0)
		var toni := [colore.darkened(0.07), colore.lightened(0.08)]
		for j in int(size.y / (passo.y * 0.5)) + 3:
			for i in int(size.x / passo.x) + 3:
				var c := Vector2(i * passo.x + (passo.x * 0.5 if j % 2 == 1 else 0.0), j * passo.y * 0.5)
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -passo.y * 0.5),
						c + Vector2(passo.x * 0.5, 0), c + Vector2(0, passo.y * 0.5),
						c + Vector2(-passo.x * 0.5, 0)]), toni[j % 2])
		var filetto := Color(colore.darkened(0.45), 0.8)
		draw_line(Vector2(0, 5.5), Vector2(size.x, 5.5), filetto, 1.0)
		draw_line(Vector2(0, size.y - 6.5), Vector2(size.x, size.y - 6.5), filetto, 1.0)


class Ombra extends Control:
	# IL NASTRO FA OMBRA, e l'ombra dice quanto e' alto: in volo e' lontana e
	# larga, quando si posa si stringe sotto la carta. Il movimento resta
	# quello disegnato da Bru, l'ombra lo segue
	var carta: NastroStrappato
	var schermata: Node

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		if carta == null or not carta.visible:
			return
		var arrivo: Vector2 = schermata.posto_del_nastro()
		var nastro := carta.get_parent() as Control
		var alto := clampf(nastro.position.distance_to(arrivo) / 220.0, 0.0, 1.0)
		var bordo := carta.contorno()
		for k in 6:
			var spinta := Vector2(1.5, 2.5) + Vector2(k * 0.7, k * 0.8) + Vector2(8.0, 16.0) * alto
			var passato := PackedVector2Array()
			for punto in bordo:
				passato.append(punto + spinta)
			draw_colored_polygon(passato, Color(0.0, 0.0, 0.0, lerpf(0.09, 0.035, alto)))
