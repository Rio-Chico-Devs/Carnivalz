extends Control
# LA TASCA E L'OBIETTIVO DELLA RACCOLTA (prove/RaccoltaProva.gd), sopra il
# mondo. Provvisorio come lei.
#
# Quello che scavi non compare nel numero di colpo: CI VOLA. Dalla vena parte
# una manciata di cristalli, in arco, fino al contatore; il numero sale quando
# arrivano, e il contatore sobbalza. Quando spendi, il numero scende subito e
# il contatore lampeggia di rosso.

const Disegno := preload("res://prove/RaccoltaDisegno.gd")
const ORDINE := ["quarzo", "ferro", "cristallo", "tazo"]
const VOLO := 0.75
const SEMPRE := ["quarzo", "ferro"]

var mostrati := {"quarzo": 0, "ferro": 0, "cristallo": 0, "tazo": 0}
var sobbalzi := {}
var spese := {}
var voli: Array[Dictionary] = []
var obiettivo := ""
var fatti := 0
var totale := 5
var annuncio := {}
var tempo := 0.0
# le parole del mondo, scritte qui sopra la stampa (RaccoltaProva.parole_sopra_la_stampa)
var inviti: Array[Dictionary] = []
var scritte: Array[Dictionary] = []
var cartelli: Array[Dictionary] = []
var borsa := {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func vola(quale: String, da: Vector2, quanti: int) -> void:
	# al piu' sei pezzi in volo: ognuno porta la sua parte del totale
	var pezzi := clampi(quanti, 1, 6)
	for k in pezzi:
		var porta := floori(float(quanti) / float(pezzi)) + (1 if k < quanti % pezzi else 0)
		var scarto := Vector2(sin(float(k) * 2.3) * 18.0, cos(float(k) * 1.7) * 10.0)
		voli.append({"quale": quale, "da": da + scarto, "eta": -0.07 * float(k), "porta": porta, "giro": float(k)})


func spendi(quale: String, quanti: int) -> void:
	mostrati[quale] = int(mostrati[quale]) - quanti
	spese[quale] = 0.0


func _process(delta: float) -> void:
	tempo += delta
	var restano: Array[Dictionary] = []
	for v in voli:
		v["eta"] = float(v["eta"]) + delta
		if float(v["eta"]) >= VOLO:
			mostrati[v["quale"]] = int(mostrati[v["quale"]]) + int(v["porta"])
			sobbalzi[v["quale"]] = 0.0
		else:
			restano.append(v)
	voli = restano
	for chiave: String in sobbalzi:
		sobbalzi[chiave] = float(sobbalzi[chiave]) + delta
	for chiave: String in spese:
		spese[chiave] = float(spese[chiave]) + delta
	if not annuncio.is_empty():
		annuncio["eta"] = float(annuncio["eta"]) + delta
	queue_redraw()


func visibili() -> Array[String]:
	var lista: Array[String] = []
	for quale: String in ORDINE:
		var in_volo := voli.any(func(v: Dictionary) -> bool: return String(v["quale"]) == quale)
		if quale in SEMPRE or int(mostrati[quale]) > 0 or in_volo:
			lista.append(quale)
	return lista


func posto(quale: String) -> Vector2:
	# dove sta l'icona del contatore: e' li' che arrivano i pezzi in volo
	var i := visibili().find(quale)
	return Vector2(24.0 + 130.0 * float(maxi(i, 0)) + 26.0, 44.0)


func _draw() -> void:
	var f := Caratteri.titolo()
	for c in cartelli:
		Disegno.cifre_del_cartello(self, c["p"], c["costo"], borsa)
	for s in scritte:
		Disegno.sale(self, s["p"], String(s["testo"]), float(s["eta"]), s["tinta"])
	for i in inviti:
		Disegno.invito(self, i["p"], String(i["testo"]), bool(i["puoi"]), String(i["manca"]), tempo)
	for quale: String in visibili():
		var c := posto(quale)
		var r := Rect2(c + Vector2(-26, -22), Vector2(120, 44))
		ombra_e_scatola(r, Color(Disegno.INK, 0.92), 22)
		var dopo_arrivo := float(sobbalzi.get(quale, 9.0))
		var salto := 1.0 + 0.45 * exp(-dopo_arrivo * 9.0)
		draw_circle(c, 19.0 * salto, Color("#2a2433"))
		draw_circle(c, 19.0 * salto, Color(Disegno.CARTA, 0.5), false, 1.5)
		Disegno.risorsa(self, c, quale, 8.5 * salto)
		var rosso := clampf(1.0 - float(spese.get(quale, 9.0)) * 2.5, 0.0, 1.0)
		var tinta := Disegno.CARTA.lerp(Stile.colore("pericolo"), rosso).lerp(Disegno.ARANCIO, exp(-dopo_arrivo * 6.0))
		var corpo := int(24.0 * (1.0 + 0.25 * exp(-dopo_arrivo * 9.0)))
		draw_string(f, c + Vector2(30, 9), str(int(mostrati[quale])), HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, tinta)
	for v in voli:
		var t := clampf(float(v["eta"]) / VOLO, 0.0, 1.0)
		if float(v["eta"]) < 0.0:
			continue
		var da: Vector2 = v["da"]
		var a := posto(String(v["quale"]))
		var alto := da.lerp(a, 0.5) + Vector2(60.0 * sin(float(v["giro"])), -140.0)
		var e := t * t * (3.0 - 2.0 * t)
		var p := da.lerp(alto, e).lerp(alto.lerp(a, e), e)
		Disegno.risorsa(self, p, String(v["quale"]), 9.0 * (1.15 - 0.3 * t))
	disegna_obiettivo(f)
	var aiuto := "FRECCE O WASD  ·  CAMMINA        E  ·  SCAVA, RIPARA, COSTRUISCI        CLIC  ·  VAI LÌ"
	ombra_e_scatola(Rect2(24, 670, 640, 30), Color(Disegno.INK, 0.85), 15)
	DisegnoProiezione.scrivi(self, Vector2(40, 690), aiuto, 10, Disegno.CARTA, 450, 85, 2)
	if not annuncio.is_empty() and float(annuncio["eta"]) < 3.2:
		disegna_annuncio(f)


func disegna_obiettivo(f: Font) -> void:
	# l'obiettivo di adesso, su un cartoncino: uno alla volta, come le cose da
	# fare di un giardino
	var r := Rect2(24, 82, 360, 50)
	draw_rect(Rect2(r.position + Vector2(6, 6), r.size), Color(0, 0, 0, 0.35))
	draw_rect(r, Disegno.CARTA)
	draw_rect(r, Disegno.INK, false, 2.5)
	var testo := "OBIETTIVO  %d / %d" % [mini(fatti + 1, totale), totale] if obiettivo != "" else "FATTO"
	Manifesto.etichetta_tinta(self, r.position + Vector2(-2, -12), testo, 11, Disegno.ARANCIO, Disegno.INK)
	var scritta := obiettivo if obiettivo != "" else "Il pianeta è tuo: torna quando vuoi"
	draw_string(f, r.position + Vector2(16, 33), scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Disegno.INK)
	for k in totale:
		var c := r.position + Vector2(r.size.x - 16.0 - 14.0 * float(totale - 1 - k), r.size.y - 12.0)
		draw_circle(c, 4.5, Disegno.INK)
		draw_circle(c, 3.0, Disegno.ARANCIO if k < fatti else Disegno.CARTA)


func disegna_annuncio(f: Font) -> void:
	var eta := float(annuncio["eta"])
	var a := clampf(minf(eta * 4.0, (3.2 - eta) * 2.0), 0.0, 1.0)
	var entra := 1.0 - pow(1.0 - clampf(eta * 3.0, 0.0, 1.0), 3.0)
	var testo := String(annuncio["testo"])
	var corpo := 36
	var largo := f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo
	var dove := Vector2(640 - largo * 0.5 + (1.0 - entra) * 60.0, 150)
	Manifesto.etichetta_tinta(self, dove + Vector2(7, 7), testo, corpo, Color(0, 0, 0, 0.4 * a), Color(0, 0, 0, 0))
	Manifesto.etichetta_tinta(self, dove, testo, corpo, Color(Disegno.ARANCIO, a), Color(Disegno.INK, a))
	var sopra := String(annuncio.get("sopra", ""))
	if sopra != "":
		Manifesto.etichetta_tinta(self, dove + Vector2(10, -24), sopra, 12, Color(Disegno.INK, a), Color(Disegno.CARTA, a))


func ombra_e_scatola(r: Rect2, tinta: Color, raggio: int) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = tinta
	s.set_corner_radius_all(raggio)
	s.border_color = Color(Disegno.CARTA, 0.25)
	s.set_border_width_all(1)
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_offset = Vector2(4, 5)
	s.shadow_size = 2
	draw_style_box(s, r)
