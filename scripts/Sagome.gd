class_name Sagome
extends RefCounted

# LE IMMAGINI CHE ANCORA NON CI SONO, disegnate a forme.
#
# Il negozio e la squadra sono fatti per le grafiche di Bru: l'oggetto in
# vetrina, il personaggio intero, l'emblema, le icone delle statistiche.
# Finche' il file non c'e', al suo posto c'e' un disegno fatto di poligoni,
# bianco e nero, con la stessa sagoma per tutti gli oggetti dello stesso tipo:
# una fiala e' una fiala, una lama e' una lama. Non vuole essere bello quanto
# il disegno vero: vuole dire subito COSA e' quella cosa, e tenere il posto
# della misura giusta.
#
# Il file vince sempre: basta metterlo dove dice art/interfaccia/LEGGIMI.md e
# il disegno a forme non si vede piu'. A chiedere i file al disco e' Disegni
# (una volta sola per percorso): qui ci sono solo le sagome.

const TIPI_ICONA := ["consumabile", "arma", "stigma", "accessorio", "materiale", "speciale"]


static func immagine_oggetto(id_oggetto: String) -> Texture2D:
	# il disegno vero di un oggetto, se Bru l'ha messo: Disegni lo chiede al
	# disco una volta sola, anche quando la risposta e' "non c'e'"
	return Disegni.texture("res://art/oggetti/%s.png" % id_oggetto)


static func tipo_icona(id_oggetto: String) -> String:
	# che sagoma ha un oggetto: quella del suo tipo. I materiali dell'Artigiano
	# (i collezionabili) sono schegge, e tutto il resto - chiavi, spazio nello
	# zaino, pile - una stella: e' roba che non si usa in combattimento
	var tipo := String(GameState.dati_oggetto(id_oggetto).get("tipo", ""))
	if tipo in TIPI_ICONA:
		return tipo
	return "materiale" if tipo == "collezionabile" else "speciale"


# --- le forme della tavola --------------------------------------------------

static func obliquo(x_alto: float, y_alto: float, largo: float, alto: float,
		pendenza := 0.48) -> PackedVector2Array:
	# un parallelogramma che pende come tutte le fasce del gioco: il lato di
	# sopra sta a destra di quello di sotto
	var s := pendenza * alto
	return PackedVector2Array([Vector2(x_alto, y_alto), Vector2(x_alto + largo, y_alto),
			Vector2(x_alto + largo - s, y_alto + alto), Vector2(x_alto - s, y_alto + alto)])


static func smussato(r: Rect2, taglio: float) -> PackedVector2Array:
	# un rettangolo con due angoli tagliati, in alto a sinistra e in basso a destra
	return PackedVector2Array([r.position + Vector2(taglio, 0), Vector2(r.end.x, r.position.y),
			r.end - Vector2(0, taglio), r.end - Vector2(taglio, 0),
			Vector2(r.position.x, r.end.y), r.position + Vector2(0, taglio)])


static func chiudi(p: PackedVector2Array) -> PackedVector2Array:
	var q := p.duplicate()
	q.append(p[0])
	return q


static func puntinato(ci: CanvasItem, r: Rect2, passo: float, colore: Color) -> void:
	# la trama a puntini del fondo: si vede appena, e dice "carta" e non "vuoto"
	var y := r.position.y + passo * 0.5
	while y < r.end.y:
		var x := r.position.x + passo * 0.5
		while x < r.end.x:
			ci.draw_rect(Rect2(x - 1.0, y - 1.0, 2.0, 2.0), colore)
			x += passo
		y += passo


static func rombo(centro: Vector2, raggio: float) -> PackedVector2Array:
	return PackedVector2Array([centro + Vector2(0, -raggio), centro + Vector2(raggio, 0),
			centro + Vector2(0, raggio), centro + Vector2(-raggio, 0)])


static func stella(centro: Vector2, fuori: float, dentro: float, punte := 4) -> PackedVector2Array:
	var p := PackedVector2Array()
	for i in punte * 2:
		var a := -PI * 0.5 + PI * float(i) / float(punte)
		p.append(centro + Vector2(cos(a), sin(a)) * (fuori if i % 2 == 0 else dentro))
	return p


# --- gli oggetti -------------------------------------------------------------

static func icona_oggetto(ci: CanvasItem, centro: Vector2, lato: float, tipo: String,
		chiaro: Color, scuro: Color) -> void:
	match tipo:
		"consumabile": fiala(ci, centro, lato, chiaro, scuro)
		"arma": lama(ci, centro, lato, chiaro, scuro)
		"stigma": occhio(ci, centro, lato, chiaro, scuro)
		"accessorio": anello(ci, centro, lato, chiaro, scuro)
		"materiale": scheggia(ci, centro, lato, chiaro, scuro)
		_: ci.draw_colored_polygon(stella(centro, lato * 0.45, lato * 0.12), chiaro)


static func fiala(ci: CanvasItem, c: Vector2, l: float, chiaro: Color, scuro: Color) -> void:
	var corpo := Rect2(c.x - l * 0.22, c.y - l * 0.08, l * 0.44, l * 0.4)
	ci.draw_rect(corpo, chiaro)
	ci.draw_circle(Vector2(c.x, corpo.end.y), l * 0.22, chiaro)
	# il liquido: la meta' bassa, scura, con la linea di superficie
	ci.draw_rect(Rect2(corpo.position.x + l * 0.05, c.y + l * 0.12, corpo.size.x - l * 0.1, l * 0.2), scuro)
	ci.draw_circle(Vector2(c.x, corpo.end.y), l * 0.15, scuro)
	ci.draw_rect(Rect2(c.x - l * 0.09, c.y - l * 0.3, l * 0.18, l * 0.23), chiaro)
	ci.draw_rect(Rect2(c.x - l * 0.13, c.y - l * 0.42, l * 0.26, l * 0.12), scuro)
	ci.draw_line(Vector2(corpo.position.x + l * 0.08, c.y - l * 0.02),
			Vector2(corpo.position.x + l * 0.08, c.y + l * 0.08), scuro, maxf(l * 0.03, 1.0))


static func lama(ci: CanvasItem, c: Vector2, l: float, chiaro: Color, scuro: Color) -> void:
	var d := Vector2(1, -1).normalized()
	var p := Vector2(1, 1).normalized()
	var base := c - d * l * 0.08
	var punta := c + d * l * 0.46
	ci.draw_colored_polygon(PackedVector2Array([base + p * l * 0.09, punta, base - p * l * 0.09]), chiaro)
	ci.draw_line(base, punta - d * l * 0.06, scuro, maxf(l * 0.02, 1.0))
	ci.draw_line(base + p * l * 0.2, base - p * l * 0.2, chiaro, l * 0.07)
	ci.draw_line(base, base - d * l * 0.28, scuro, l * 0.09)
	ci.draw_line(base, base - d * l * 0.28, chiaro, l * 0.05)
	ci.draw_circle(base - d * l * 0.32, l * 0.06, chiaro)


static func occhio(ci: CanvasItem, c: Vector2, l: float, chiaro: Color, scuro: Color) -> void:
	ci.draw_colored_polygon(rombo(c, l * 0.46), chiaro)
	var mandorla := PackedVector2Array()
	for i in 17:
		var t := -1.0 + 2.0 * float(i) / 16.0
		mandorla.append(c + Vector2(t * l * 0.3, -l * 0.15 * (1.0 - t * t)))
	for i in range(15, 0, -1):
		var t := -1.0 + 2.0 * float(i) / 16.0
		mandorla.append(c + Vector2(t * l * 0.3, l * 0.15 * (1.0 - t * t)))
	ci.draw_colored_polygon(mandorla, scuro)
	ci.draw_circle(c, l * 0.07, chiaro)


static func anello(ci: CanvasItem, c: Vector2, l: float, chiaro: Color, scuro: Color) -> void:
	var centro := c + Vector2(0, l * 0.08)
	ci.draw_arc(centro, l * 0.27, 0.0, TAU, 40, chiaro, l * 0.1, true)
	var gemma := c + Vector2(0, -l * 0.24)
	ci.draw_colored_polygon(rombo(gemma, l * 0.16), chiaro)
	ci.draw_colored_polygon(rombo(gemma, l * 0.08), scuro)


static func scheggia(ci: CanvasItem, c: Vector2, l: float, chiaro: Color, scuro: Color) -> void:
	var p := PackedVector2Array([c + Vector2(-l * 0.05, -l * 0.44), c + Vector2(l * 0.26, -l * 0.1),
			c + Vector2(l * 0.14, l * 0.42), c + Vector2(-l * 0.22, l * 0.3),
			c + Vector2(-l * 0.28, -l * 0.08)])
	ci.draw_colored_polygon(p, chiaro)
	ci.draw_line(c + Vector2(-l * 0.05, -l * 0.44), c + Vector2(l * 0.02, l * 0.36), scuro, maxf(l * 0.03, 1.0))


# --- la squadra ---------------------------------------------------------------

static func emblema(ci: CanvasItem, c: Vector2, l: float, chiaro: Color, accento: Color) -> void:
	# l'emblema di una classe: un rombo grande col cuore acceso, due piccoli
	# sopra e sotto, e due fantasmi ai lati. Finche' Bru non disegna quello vero
	var fantasma := Color(chiaro, chiaro.a * 0.18)
	ci.draw_colored_polygon(rombo(c + Vector2(-l * 0.3, l * 0.04), l * 0.24), fantasma)
	ci.draw_colored_polygon(rombo(c + Vector2(l * 0.3, l * 0.04), l * 0.24), fantasma)
	ci.draw_colored_polygon(rombo(c, l * 0.32), chiaro)
	ci.draw_colored_polygon(rombo(c, l * 0.13), accento)
	ci.draw_colored_polygon(rombo(c + Vector2(0, -l * 0.43), l * 0.08), chiaro)
	ci.draw_colored_polygon(rombo(c + Vector2(0, l * 0.43), l * 0.08), chiaro)


static func icona_statistica(ci: CanvasItem, r: Rect2, chiave: String, colore: Color) -> void:
	var c := r.get_center()
	var l := minf(r.size.x, r.size.y)
	match chiave:
		"hp": cuore(ci, c, l, colore)
		"attacco": lama(ci, c, l, colore, Color(0, 0, 0, 0))
		"difesa": ci.draw_colored_polygon(scudo(c, l), colore)
		"velocita": ci.draw_colored_polygon(fulmine(c, l), colore)
		_: ci.draw_colored_polygon(stella(c, l * 0.42, l * 0.14), colore)


static func cuore(ci: CanvasItem, c: Vector2, l: float, colore: Color) -> void:
	ci.draw_circle(c + Vector2(-l * 0.14, -l * 0.08), l * 0.17, colore)
	ci.draw_circle(c + Vector2(l * 0.14, -l * 0.08), l * 0.17, colore)
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-l * 0.3, -l * 0.02),
			c + Vector2(l * 0.3, -l * 0.02), c + Vector2(0, l * 0.34)]), colore)


static func scudo(c: Vector2, l: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(-l * 0.32, -l * 0.34), c + Vector2(0, -l * 0.4),
			c + Vector2(l * 0.32, -l * 0.34), c + Vector2(l * 0.28, l * 0.08),
			c + Vector2(0, l * 0.4), c + Vector2(-l * 0.28, l * 0.08)])


static func fulmine(c: Vector2, l: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(l * 0.08, -l * 0.42), c + Vector2(-l * 0.24, l * 0.06),
			c + Vector2(-l * 0.02, l * 0.06), c + Vector2(-l * 0.1, l * 0.42),
			c + Vector2(l * 0.24, -l * 0.08), c + Vector2(l * 0.02, -l * 0.08)])


static func lucchetto(ci: CanvasItem, c: Vector2, l: float, colore: Color) -> void:
	ci.draw_arc(c + Vector2(0, -l * 0.08), l * 0.2, PI, TAU, 16, colore, l * 0.08, true)
	ci.draw_rect(Rect2(c.x - l * 0.28, c.y - l * 0.08, l * 0.56, l * 0.44), colore)


static func timbro(ci: CanvasItem, c: Vector2, raggio: float, colore: Color) -> void:
	# il "gia' tuo": un cerchio e un segno, come il timbro sulle carte di Bru
	ci.draw_arc(c, raggio, 0.0, TAU, 40, colore, maxf(raggio * 0.1, 2.0), true)
	ci.draw_polyline(PackedVector2Array([c + Vector2(-raggio * 0.42, 0), c + Vector2(-raggio * 0.1, raggio * 0.32),
			c + Vector2(raggio * 0.46, -raggio * 0.34)]), colore, maxf(raggio * 0.16, 2.0), true)


static func freccia(ci: CanvasItem, c: Vector2, l: float, verso: int, colore: Color) -> void:
	var s := float(verso)
	ci.draw_polyline(PackedVector2Array([c + Vector2(-l * 0.2 * s, -l * 0.4), c + Vector2(l * 0.2 * s, 0),
			c + Vector2(-l * 0.2 * s, l * 0.4)]), colore, maxf(l * 0.16, 2.0), true)


static func iniziale(ci: CanvasItem, r: Rect2, nome: String, corpo: int, chiaro: Color,
		copie: Array[Color]) -> void:
	# la lettera grande al posto di un ritratto che non c'e': la stessa parola
	# a copie sfalsate delle quinte della pausa, in piccolo
	var f := Caratteri.titolo()
	if f == null or nome == "":
		return
	var lettera := nome.substr(0, 1).to_upper()
	var misura := f.get_string_size(lettera, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo)
	var base := r.get_center() + Vector2(-misura.x * 0.5, f.get_ascent(corpo) * 0.5 - f.get_descent(corpo) * 0.5)
	var passo := Vector2(corpo, corpo) * 0.02
	for i in range(copie.size(), 0, -1):
		ci.draw_string(f, base + passo * i, lettera, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, copie[i - 1])
	ci.draw_string(f, base, lettera, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, chiaro)
