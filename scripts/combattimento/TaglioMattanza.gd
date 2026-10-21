class_name TaglioMattanza
extends Control
# IL TAGLIO DELLA MATTANZA: il momento in cui parte si vede a tutto schermo.
#
# Bru, sugli esempi animati (docs/vita.md): «mattanza approvata, bellissima ma
# vogliamo che la barra sia più grande dentro ci metteremo un artwork». Quindi:
# un lampo, tre fasce di traverso che entrano da parti opposte - la nera alta
# meta' schermo, perche' dentro ci va il disegno di chi la fa -, la parola che
# cade come un timbro, le schegge, e tutto che esce dall'altra parte.
#
# L'ARTWORK: art/mattanza/<id del personaggio>.png. Sta nella parte sinistra
# della fascia nera, tagliato dai suoi bordi storti, e scivola piano mentre
# tutto e' fermo. Finche' non c'e', al suo posto c'e' l'iniziale grande.
#
# NON FA ASPETTARE. Il suo orologio e' quello dello scontro: lo fa avanzare
# Mattanza.passa, e intanto il mondo e la barra stanno fermi - la finestra
# comincia quando il taglio e' finito, non sotto di lui. Il primo tasto o clic
# lo salta. Col movimento ridotto niente fasce in volo: la fascia nera con la
# parola compare e sparisce sul posto.

signal finito

const DURATA := 1.12            # dal lampo a quando l'ultima fascia e' uscita
const DURATA_RIDOTTA := 0.6
const ESCE := 0.95              # quando le fasce cominciano a uscire
const ENTRA := 0.15             # quanto ci mette una fascia a entrare
const ARTWORK := "res://art/mattanza/%s.png"
const INCLINA := -7.0           # gradi delle fasce
const ALTA := 0.5               # la fascia nera, in frazione dell'altezza dello schermo
const ARTE_LARGA := 0.46        # quanta parte della fascia prende l'artwork, da sinistra

var orologio := 0.0
var in_corso := false
var ridotto := false
var velo: ColorRect
var bianco: ColorRect
var fasce: Array[Node2D] = []   # la nera, la rossa, l'arancio
var arte: Polygon2D = null      # l'artwork tagliato dalla fascia
var orlo: Carta = null          # il suo bordo, liscio (sotto)
var iniziale: Label = null      # al posto dell'artwork, finche' non c'e'
var parola: Label
var schegge: Schegge
var scoppiate := false


static func apri(dove: Control, chi: Dictionary) -> TaglioMattanza:
	var taglio := TaglioMattanza.new()
	taglio.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dove.add_child(taglio)
	taglio.size = dove.size
	taglio.costruisci(String(chi.get("id", "")), String(chi.get("nome", "?")))
	return taglio


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP   # il clic che lo salta e' suo
	ridotto = Movimento.ridotto()


func costruisci(id_personaggio: String, nome: String) -> void:
	in_corso = true
	velo = rettangolo(Color(Stile.colore("sfondo"), 0.0))
	var alto := size.y * ALTA
	var centro := size * 0.5
	fasce.append(fascia(centro, alto, Stile.colore("sfondo")))
	fasce.append(fascia(centro + Vector2(0, alto * 0.5 + size.y * 0.035), size.y * 0.045, Stile.colore("pericolo")))
	fasce.append(fascia(centro - Vector2(0, alto * 0.5 + size.y * 0.025), size.y * 0.022, Stile.colore("manifesto")))
	fasce[0].add_child(Corse.new(size.x, alto))
	metti_arte(id_personaggio, nome, alto)
	parola = Label.new()
	parola.text = "MATTANZA"
	parola.add_theme_font_override("font", Caratteri.titolo())
	var corpo := int(size.y * 0.135)
	parola.add_theme_font_size_override("font_size", corpo)
	parola.add_theme_color_override("font_color", Stile.colore("pericolo"))
	# il contorno della regola (un sesto del corpo), ma chiaro: sulla fascia
	# nera un contorno nero non si vedrebbe, e il rosso sul nero ha bisogno di
	# staccarsi
	Stile.contorno(parola, corpo)
	parola.add_theme_color_override("font_outline_color", Stile.colore("testo"))
	fasce[0].add_child(parola)
	parola.reset_size()
	parola.pivot_offset = parola.size * 0.5
	# nella meta' destra della fascia, col bordo destro dentro lo schermo
	parola.position = Vector2(minf(size.x * 0.43 - parola.size.x, size.x * 0.06), -parola.size.y * 0.5)
	parola.modulate.a = 0.0
	bianco = rettangolo(Color(1, 1, 1, 0.0))
	schegge = Schegge.new()
	schegge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schegge)
	avanza(0.0)


func rettangolo(tinta: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = tinta
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(r)
	return r


func fascia(centro: Vector2, alto: float, tinta: Color) -> Node2D:
	# una fascia di carta di traverso: un parallelogramma, girato di INCLINA,
	# col bordo liscio (Carta, sotto)
	var perno := Node2D.new()
	perno.position = centro
	perno.rotation_degrees = INCLINA
	var carta := Carta.new()
	carta.polygon = bordo_fascia(size.x * 1.6, alto)
	carta.color = tinta
	perno.add_child(carta)
	add_child(perno)
	return perno


static func bordo_fascia(largo: float, alto: float) -> PackedVector2Array:
	var storto := alto * 0.35
	return PackedVector2Array([Vector2(-largo * 0.5 + storto, -alto * 0.5), Vector2(largo * 0.5 + storto, -alto * 0.5),
			Vector2(largo * 0.5 - storto, alto * 0.5), Vector2(-largo * 0.5 - storto, alto * 0.5)])


func metti_arte(id_personaggio: String, nome: String, alto: float) -> void:
	var disegno: Texture2D = null
	if id_personaggio != "":
		disegno = Disegni.texture(ARTWORK % id_personaggio)
	if disegno != null:
		arte = Polygon2D.new()
		arte.texture = disegno
		fasce[0].add_child(arte)
		orlo = Carta.new()
		orlo.color = Stile.colore("sfondo")
		orlo.solo_bordo = true
		fasce[0].add_child(orlo)
		return
	iniziale = Label.new()
	iniziale.text = nome.left(1).to_upper()
	iniziale.add_theme_font_override("font", Caratteri.titolo())
	iniziale.add_theme_font_size_override("font_size", int(alto * 0.9))
	iniziale.add_theme_color_override("font_color", Stile.colore("manifesto"))
	fasce[0].add_child(iniziale)
	iniziale.reset_size()


func dove_sta_l_arte(scivola: float) -> Rect2:
	# il rettangolo dell'artwork nelle coordinate della fascia: alto quanto la
	# fascia, largo quanto chiede il disegno, e scivola da sinistra
	var alto := size.y * ALTA
	var largo := alto
	if arte != null and arte.texture != null:
		var misura := arte.texture.get_size()
		largo = alto * misura.x / maxf(misura.y, 1.0)
	var sinistra := -size.x * 0.5 + size.x * 0.06 + scivola
	return Rect2(Vector2(sinistra, -alto * 0.5), Vector2(largo, alto))


func taglia_l_arte(dove: Rect2) -> void:
	# l'artwork tagliato dai bordi storti della fascia e dalla sua parte sinistra
	var finestra := PackedVector2Array([dove.position, Vector2(dove.end.x, dove.position.y), dove.end,
			Vector2(dove.position.x, dove.end.y)])
	var spazio := bordo_fascia(size.x * 1.6, size.y * ALTA)
	var limite := -size.x * 0.5 + size.x * ARTE_LARGA + size.x * 0.06
	var sinistra := PackedVector2Array([spazio[0], Vector2(limite + size.y * ALTA * 0.35, spazio[0].y),
			Vector2(limite - size.y * ALTA * 0.35, spazio[3].y), spazio[3]])
	var nella_fascia := Geometry2D.intersect_polygons(finestra, spazio)
	var dentro: Array[PackedVector2Array] = []
	if not nella_fascia.is_empty():
		dentro = Geometry2D.intersect_polygons(nella_fascia[0], sinistra)
	if dentro.is_empty():
		arte.polygon = PackedVector2Array()
		orlo.polygon = PackedVector2Array()
		return
	var contorno: PackedVector2Array = dentro[0]
	var uv := PackedVector2Array()
	var misura := arte.texture.get_size()
	for p in contorno:
		uv.append((p - dove.position) / dove.size * misura)
	arte.polygon = contorno
	arte.uv = uv
	orlo.polygon = contorno


func _gui_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and (evento as InputEventMouseButton).pressed:
		salta()
		accept_event()


func salta() -> void:
	# il primo tasto o clic lo chiude subito: si vede una volta per scontro, e
	# chi l'ha gia' visto non deve aspettarlo
	if in_corso:
		chiudi()


func chiudi() -> void:
	in_corso = false
	finito.emit()
	queue_free()


func avanza(delta: float) -> void:
	if not in_corso:
		return
	orologio += delta
	if ridotto:
		avanza_ridotto()
	else:
		avanza_in_volo()
	if orologio >= (DURATA_RIDOTTA if ridotto else DURATA):
		chiudi()


func avanza_ridotto() -> void:
	# la fascia nera con la parola, ferma: compare e sparisce in un decimo di secondo
	var luce := clampf(orologio / 0.1, 0.0, 1.0) * (1.0 - clampf((orologio - DURATA_RIDOTTA + 0.1) / 0.1, 0.0, 1.0))
	velo.color.a = 0.5 * luce
	fasce[0].modulate.a = luce
	fasce[0].position.x = size.x * 0.5
	for k in range(1, fasce.size()):
		fasce[k].visible = false
	parola.modulate.a = luce
	sistema_arte(0.0)


func avanza_in_volo() -> void:
	var esce := clampf((orologio - ESCE) / 0.16, 0.0, 1.0)
	bianco.color.a = 0.75 * (1.0 - clampf(orologio / 0.12, 0.0, 1.0))
	velo.color.a = 0.5 * clampf(orologio / 0.08, 0.0, 1.0) * (1.0 - esce)
	# le tre fasce: la nera da sinistra, le sottili da parti opposte; escono
	# dall'altra parte
	var versi := [-1.0, 1.0, -1.0]
	var ritardi := [0.0, 0.03, 0.05]
	for k in fasce.size():
		var u := Movimento.curva("entrata", clampf((orologio - float(ritardi[k])) / ENTRA, 0.0, 1.0))
		var verso := float(versi[k])
		fasce[k].visible = orologio >= float(ritardi[k])
		fasce[k].position.x = size.x * 0.5 + verso * size.x * 1.4 * (1.0 - u) \
				- verso * size.x * 1.4 * Movimento.curva("uscita", esce)
	# l'artwork scivola dentro e continua piano a scivolare
	var arriva := Movimento.curva("entrata", clampf((orologio - 0.04) / 0.18, 0.0, 1.0))
	sistema_arte(lerpf(-size.x * 0.4, 0.0, arriva) + size.x * 0.03 * clampf(orologio, 0.0, 1.0))
	# la parola cade come un timbro
	var caduta := clampf((orologio - 0.14) / 0.16, 0.0, 1.0)
	var rimbalzo: float = Tween.interpolate_value(0.0, 1.0, caduta, 1.0, Tween.TRANS_BACK, Tween.EASE_OUT)
	parola.modulate.a = clampf(caduta * 3.0, 0.0, 1.0)
	parola.scale = Vector2.ONE * lerpf(2.2, 1.0, rimbalzo)
	if not scoppiate and orologio >= 0.26:
		scoppiate = true
		var centro := parola.get_global_rect().get_center()
		schegge.scoppia(centro)
		schegge.scoppia(centro + Vector2(parola.size.x * 0.3, 0.0))


func sistema_arte(scivola: float) -> void:
	if arte != null:
		taglia_l_arte(dove_sta_l_arte(scivola))
	elif iniziale != null:
		var dove := dove_sta_l_arte(scivola)
		iniziale.position = Vector2(dove.position.x + dove.size.x * 0.2, -iniziale.size.y * 0.52)


class Carta extends Node2D:
	# UN POLIGONO COL BORDO LISCIO (Manifesto.poligono): un Polygon2D inclinato
	# ha il bordo a scalini, e l'antialiasing di Polygon2D qui non fa niente
	# (provato). Pieno, per le fasce; o solo il bordo, per l'artwork, che e' un
	# Polygon2D con la texture e il suo taglio storto va lisciato da sopra
	var polygon := PackedVector2Array():
		set(nuovo):
			polygon = nuovo
			queue_redraw()
	var color := Color.BLACK
	var solo_bordo := false

	func _draw() -> void:
		if polygon.size() < 3:
			return
		if not solo_bordo:
			Manifesto.poligono(self, polygon, color)
			return
		var chiuso := polygon.duplicate()
		chiuso.append(polygon[0])
		draw_polyline(chiuso, color, 2.0, true)


class Corse extends Node2D:
	# LE LINEE DI CORSA sulla fascia nera: tratti chiari che scorrono verso
	# sinistra, perche' la fascia ferma sembri ancora in volo
	var orologio := 0.0
	var largo := 1280.0
	var tratti: Array[Vector3] = []   # x, y, lunghezza

	func _init(largo_schermo: float, alto: float) -> void:
		largo = largo_schermo
		var dado := RandomNumberGenerator.new()
		dado.seed = 3
		for i in 18:
			tratti.append(Vector3(dado.randf_range(-largo, largo), dado.randf_range(-alto * 0.45, alto * 0.45),
					dado.randf_range(largo * 0.05, largo * 0.17)))

	func _process(delta: float) -> void:
		orologio += delta
		queue_redraw()

	func _draw() -> void:
		for v in tratti:
			var x := fposmod(v.x - orologio * largo * 1.9 + largo, largo * 2.0) - largo
			draw_line(Vector2(x, v.y), Vector2(x + v.z, v.y), Color(1, 1, 1, 0.2), 2.0)
