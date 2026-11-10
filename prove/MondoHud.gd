extends Control
# LA TASCA, IL CARTELLO E LA MAPPA del pianeta da esplorare
# (prove/MondoProva.gd), sopra il mondo e a misura di schermo. Provvisorio.
#
# Le scritte sono quelle del gioco (Archivo corsivo, le etichette del
# manifesto): il mondo e' pixel art, le parole restano nitide.

const ORDINE := ["quarzo", "ferro", "cristallo", "tazo"]
const ICONE := {"quarzo": "vena_quarzo", "ferro": "vena_ferro", "cristallo": "vena_cristallo", "tazo": "forziere"}
const NOMI := {"quarzo": "QUARZO", "ferro": "FERRO", "cristallo": "CRISTALLO", "tazo": "TAZO"}
const CARTA := Color("#efd8b2")
const SEGNALE := Color("#f29a2e")
const FONDO := Color("#0b0e14")
const INCHIOSTRO := Color("#4a7aa8")
const ROSSO := Color("#e0505a")

var scena: Node2D
var tempo := 0.0
var sobbalzi := {}
var salite: Array[Dictionary] = []      # {testo, da, eta}
var cartello := {}                      # {titolo, sopra, eta}
var mancanza := {}                      # {manca, eta}
var mappa_img: ImageTexture
var mappa_eta := -1.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func entra(r: int) -> void:
	var regioni: Array[Dictionary] = scena.get("m").get("regioni")
	var nostra := bool(regioni[r].get("colonizzata", false))
	cartello = {"titolo": String(regioni[r]["nome"]).to_upper(),
		"sopra": "REGIONE AUTONOMA" if nostra else "REGIONE SELVAGGIA", "eta": 0.0}


func annuncia(titolo: String, sopra: String) -> void:
	cartello = {"titolo": titolo, "sopra": sopra, "eta": 0.0}


func prende(risorsa: String, quanti: int, da: Vector2) -> void:
	salite.append({"testo": "+%d %s" % [quanti, NOMI[risorsa]], "da": da, "eta": 0.0})
	sobbalzi[risorsa] = 0.0


func arriva(risorsa: String) -> void:
	sobbalzi[risorsa] = 0.0


func manca(cosa: Dictionary) -> void:
	mancanza = {"manca": cosa, "eta": 0.0}


func _process(delta: float) -> void:
	tempo += delta
	for chiave: String in sobbalzi:
		sobbalzi[chiave] = float(sobbalzi[chiave]) + delta
	for s in salite:
		s["eta"] = float(s["eta"]) + delta
	salite = salite.filter(func(s: Dictionary) -> bool: return float(s["eta"]) < 1.4)
	if not cartello.is_empty():
		cartello["eta"] = float(cartello["eta"]) + delta
	if not mancanza.is_empty():
		mancanza["eta"] = float(mancanza["eta"]) + delta
	queue_redraw()


func _draw() -> void:
	if scena == null:
		return
	var f := Caratteri.titolo()
	disegna_tasca(f)
	disegna_pianeta(f)
	disegna_invito(f)
	for s in salite:
		var eta := float(s["eta"])
		var a := clampf(1.4 - eta, 0.0, 1.0) * 1.6
		var p: Vector2 = s["da"] + Vector2(0, -30.0 - eta * 40.0)
		draw_string(f, p + Vector2(2, 2), String(s["testo"]), HORIZONTAL_ALIGNMENT_CENTER, 200, 22, Color(FONDO, a))
		draw_string(f, p, String(s["testo"]), HORIZONTAL_ALIGNMENT_CENTER, 200, 22, Color(CARTA, a))
	if not cartello.is_empty() and float(cartello["eta"]) < 3.0:
		disegna_cartello(f)
	var aiuto := "FRECCE O WASD  CAMMINA      E  FAI      M  MAPPA      N  ALTRO PIANETA      B  ALTRO BIOMA      P  LUI / LEI"
	draw_string(f, Vector2(26, 702), aiuto, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(FONDO, 0.8))
	draw_string(f, Vector2(24, 700), aiuto, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CARTA)
	if bool(scena.get("mappa_aperta")):
		disegna_mappa(f)


func icona(dove: Vector2, risorsa: String, grande: float) -> void:
	var trame: Dictionary = scena.get("trame")
	var t: Texture2D = trame[ICONE[risorsa]]
	draw_texture_rect(t, Rect2(dove - Vector2(8, 10) * grande, Vector2(16, 16) * grande), false)


func pillola(r: Rect2, tinta: Color) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = tinta
	s.set_corner_radius_all(int(r.size.y * 0.5))
	s.shadow_color = Color(0, 0, 0, 0.4)
	s.shadow_offset = Vector2(3, 4)
	s.shadow_size = 1
	draw_style_box(s, r)


func disegna_tasca(f: Font) -> void:
	var borsa: Dictionary = scena.get("borsa")
	var x := 24.0
	for risorsa: String in ORDINE:
		if int(borsa[risorsa]) == 0 and risorsa != "quarzo":
			continue
		var dopo := float(sobbalzi.get(risorsa, 9.0))
		var salto := 1.0 + 0.4 * exp(-dopo * 9.0)
		pillola(Rect2(x, 22, 112, 44), Color(FONDO, 0.86))
		icona(Vector2(x + 24, 46), risorsa, 2.0 * salto)
		var tinta := CARTA.lerp(SEGNALE, exp(-dopo * 5.0))
		draw_string(f, Vector2(x + 48, 54), str(int(borsa[risorsa])), HORIZONTAL_ALIGNMENT_LEFT, -1, int(24.0 * salto), tinta)
		x += 124.0


func disegna_pianeta(f: Font) -> void:
	var quanto := int(scena.call("percentuale"))
	var nome := "PIANETA %s  ·  %d" % [String(scena.get("bioma")).to_upper(), int(scena.get("seme"))]
	var r := Rect2(1280 - 24 - 300, 22, 300, 58)
	pillola(r, Color(FONDO, 0.86))
	draw_string(f, r.position + Vector2(20, 24), nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(CARTA, 0.75))
	draw_string(f, r.position + Vector2(20, 46), "COLONIZZATO %d%%" % quanto, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, CARTA)
	var barra := Rect2(r.position + Vector2(196, 34), Vector2(84, 8))
	draw_rect(barra, Color(CARTA, 0.18))
	draw_rect(Rect2(barra.position, Vector2(barra.size.x * quanto / 100.0, barra.size.y)), SEGNALE)


func disegna_cartello(f: Font) -> void:
	var eta := float(cartello["eta"])
	var a := clampf(minf(eta * 5.0, (3.0 - eta) * 2.5), 0.0, 1.0)
	var entra_x := (1.0 - pow(1.0 - clampf(eta * 3.5, 0.0, 1.0), 3.0))
	var testo := String(cartello["titolo"])
	var corpo := 34
	var largo := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo
	var dove := Vector2(640 - largo * 0.5 + (1.0 - entra_x) * 50.0, 118)
	Manifesto.etichetta_tinta(self, dove + Vector2(6, 6), testo, corpo, Color(0, 0, 0, 0.4 * a), Color(0, 0, 0, 0))
	Manifesto.etichetta_tinta(self, dove, testo, corpo, Color(SEGNALE, a), Color(FONDO, a))
	Manifesto.etichetta_tinta(self, dove + Vector2(10, -22), String(cartello["sopra"]), 12, Color(FONDO, a), Color(CARTA, a))


func disegna_invito(f: Font) -> void:
	var n := int(scena.call("cosa_davanti"))
	if n < 0:
		return
	var invito: Dictionary = scena.call("invito", n)
	var costo: Dictionary = invito["costo"]
	var manca_ora: Dictionary = invito["manca"]
	var testo := "E  ·  " + String(invito["verbo"])
	var corpo := 18
	var largo := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + 36.0 + 70.0 * costo.size()
	var r := Rect2(640 - largo * 0.5, 600, largo, 46)
	pillola(r, Color(FONDO, 0.9))
	draw_string(f, r.position + Vector2(18, 30), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, CARTA if manca_ora.is_empty() else Color(CARTA, 0.6))
	var x := r.position.x + 30.0 + f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
	for risorsa: String in costo:
		icona(Vector2(x + 12, r.position.y + 25), risorsa, 1.5)
		var tinta := ROSSO if manca_ora.has(risorsa) else SEGNALE
		draw_string(f, Vector2(x + 26, r.position.y + 31), str(int(costo[risorsa])), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, tinta)
		x += 70.0
	if not mancanza.is_empty() and float(mancanza["eta"]) < 1.6:
		var parti: Array[String] = []
		var m: Dictionary = mancanza["manca"]
		for risorsa: String in m:
			parti.append("%d %s" % [int(m[risorsa]), NOMI[risorsa]])
		var dice := "MANCANO " + ", ".join(parti)
		var w := f.get_string_size(dice, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		Manifesto.etichetta_tinta(self, Vector2(640 - w * 0.5 - 8, 566), dice, 16, ROSSO, FONDO)


func disegna_mappa(f: Font) -> void:
	# la mappa del pianeta: quello che hai visto, le regioni tue accese, le
	# altre spente; i fari; dove sei
	var m: RefCounted = scena.get("m")
	var w: int = m.get("w")
	var h: int = m.get("h")
	if mappa_eta != scena.get("tempo") or mappa_img == null:
		mappa_img = ImageTexture.create_from_image(immagine_mappa(m))
		mappa_eta = scena.get("tempo")
	draw_rect(Rect2(Vector2.ZERO, size), Color(FONDO, 0.82))
	var scala := 7.0
	var r := Rect2(Vector2(640, 380) - Vector2(w, h) * scala * 0.5, Vector2(w, h) * scala)
	draw_rect(r.grow(10), Color(CARTA, 0.12))
	draw_texture_rect(mappa_img, r, false)
	Manifesto.etichetta_tinta(self, r.position + Vector2(-6, -44), "LA MAPPA DEL PIANETA", 22, SEGNALE, FONDO)
	var regioni: Array[Dictionary] = m.get("regioni")
	var visti: Dictionary = scena.get("visti")
	for reg in regioni:
		if int(reg["profondita"]) < 0 or not reg.has("cuore"):
			continue
		var c: Vector2i = reg["cuore"]
		if not visti.has(c):
			continue
		var p := r.position + (Vector2(c) + Vector2(0.5, 0.5)) * scala
		var nostra := bool(reg["colonizzata"])
		draw_circle(p, 6.0, FONDO)
		draw_circle(p, 4.0, SEGNALE if nostra else Color(CARTA, 0.5))
		var nome := String(reg["nome"]).to_upper()
		draw_string(f, p + Vector2(-80, 22), nome, HORIZONTAL_ALIGNMENT_CENTER, 160, 13, FONDO)
		draw_string(f, p + Vector2(-81, 21), nome, HORIZONTAL_ALIGNMENT_CENTER, 160, 13, CARTA)
	var io: Vector2 = scena.get("piedi")
	var qui := r.position + io / 16.0 * scala
	var battito := 0.5 + 0.5 * sin(tempo * 6.0)
	draw_circle(qui, 7.0 + battito * 3.0, Color(SEGNALE, 0.35))
	draw_circle(qui, 5.0, SEGNALE)
	draw_circle(qui, 5.0, FONDO, false, 2.0)


func immagine_mappa(m: RefCounted) -> Image:
	var w: int = m.get("w")
	var h: int = m.get("h")
	var ter: PackedByteArray = m.get("terreno")
	var reg: PackedInt32Array = m.get("regione")
	var blo: PackedByteArray = m.get("bloccato")
	var lv: PackedByteArray = m.get("livello")
	var regioni: Array[Dictionary] = m.get("regioni")
	var visti: Dictionary = scena.get("visti")
	var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	var tinte := [INCHIOSTRO.darkened(0.35), CARTA.darkened(0.1), Color("#a57a52"), Color("#5e9a44"), Color("#3d7a40")]
	for y in h:
		for x in w:
			var q := y * w + x
			if not visti.has(Vector2i(x, y)):
				img.set_pixel(x, y, FONDO.lightened(0.04))
				continue
			var c: Color = tinte[ter[q]]
			if lv[q] == 1:
				c = c.lightened(0.15)
			if blo[q] == 1 and ter[q] != 0:
				c = c.darkened(0.3)
			if reg[q] >= 0 and not bool(regioni[reg[q]].get("colonizzata", false)):
				var l := c.get_luminance()
				c = Color(l, l, l).lerp(c, 0.3).darkened(0.3)
			# i confini fra regioni, una riga scura
			if reg[q] >= 0 and x + 1 < w and reg[q + 1] >= 0 and reg[q + 1] != reg[q]:
				c = FONDO
			if reg[q] >= 0 and y + 1 < h and reg[q + w] >= 0 and reg[q + w] != reg[q]:
				c = FONDO
			img.set_pixel(x, y, c)
	return img
