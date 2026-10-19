extends "res://prove/mappa/BaseMappa.gd"

# C · PIANTA E SEZIONE. Come si disegna un edificio da quando si disegnano gli
# edifici: un piano visto dall'alto (la pianta), e di fianco la casa tagliata in
# due (la sezione), dove si vedono tutti i piani uno sopra l'altro e le scale
# che li legano. Nessun piano copre mai un altro, perche' in pianta ce n'e' uno
# solo e in sezione stanno in fila.
#
# Si rinuncia al modellino da girare: e' la proposta piu' leggibile e la meno
# spettacolare. Resta nello schermo del cabinato, come la mappa di oggi, e
# coi colori del vetro (crema, arancio, nero).

const NERO := Color("#0b0908")
const VETRO := Color("#141110")
const CREMA := Color("#ece6df")
const CARTA := Color("#d8cfc7")
const ARANCIO := Color("#f4931b")
const SPENTO := Color("#6b635d")
const SCHERMO := Rect2(34, 128, 1212, 532)
const PIANTA := Rect2(70, 190, 740, 440)
const SEZIONE := Rect2(860, 170, 350, 250)
const SCHEDA := Rect2(860, 452, 350, 176)
const ARIA := 0.06

var scala := 40.0
var centro := Vector2.ZERO
var mezzo := Vector2.ZERO


func costruisci() -> void:
	Manifesto.trama_dietro(self)
	var imp := m.impronta(piano_scelto())
	scala = minf(minf(PIANTA.size.x / imp.size.x, PIANTA.size.y / imp.size.y), 150.0 / m.lato)
	mezzo = imp.get_center()
	centro = PIANTA.get_center()
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), testata)
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), pianta)
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), sezione)
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), scheda)


func a_schermo(p: Vector2) -> Vector2:
	return centro + (p - mezzo) * scala


func riquadro(s: Dictionary) -> Rect2:
	var p := (s["pianta"] as Rect2).grow(-m.lato * ARIA)
	return Rect2(a_schermo(p.position), p.size * scala)


# --- la cornice -----------------------------------------------------------------

func testata(t: Control) -> void:
	var box := StyleBoxFlat.new()
	box.anti_aliasing = true
	box.set_corner_radius_all(14)
	box.bg_color = NERO
	t.draw_style_box(box, Rect2(Vector2(64, 64), Vector2(70, 70)))
	t.draw_style_box(box, Rect2(Vector2(58, 58), Vector2(70, 70)))
	box.bg_color = ARANCIO
	box.set_corner_radius_all(10)
	t.draw_style_box(box, Rect2(Vector2(63, 63), Vector2(60, 60)))
	for i in 3:
		t.draw_rect(Rect2(Vector2(75, 76 + i * 12), Vector2(36, 6)), NERO)
	etichetta(t, Vector2(146, 74), "Torna alla stanza", 22, NERO, CREMA)
	var w := misura_etichetta(m.nome_zona, 34).x
	etichetta(t, Vector2(1248 - w, 64), m.nome_zona, 34, NERO, CREMA)
	Manifesto.disegna_schermo(t, SCHERMO)
	# i tasti sotto lo schermo, sull'arancio
	var x := 50.0
	for coppia: Array in [["▲ ▼", "piano"], ["CLIC", "vai"], ["ESC", "indietro"]]:
		var ww := largo_tondo(String(coppia[0]), 13, 800) + 18.0
		box.bg_color = CREMA
		box.set_corner_radius_all(5)
		t.draw_style_box(box, Rect2(Vector2(x, 676), Vector2(ww, 24)))
		tondo(t, Vector2(x + 9, 693), String(coppia[0]), 13, NERO, 800)
		tondo(t, Vector2(x + ww + 8, 693), String(coppia[1]), 14, NERO, 700)
		x += ww + 30.0 + largo_tondo(String(coppia[1]), 14, 700)


# --- la pianta ------------------------------------------------------------------

func pianta(t: Control) -> void:
	occupati.clear()
	var piano := piano_scelto()
	# il reticolo del foglio, mezzo lato di stanza
	var passo := m.lato * 0.5 * scala
	var x := fmod(centro.x - mezzo.x * scala, passo)
	while x < SCHERMO.end.x - 20.0:
		if x > SCHERMO.position.x + 20.0:
			t.draw_line(Vector2(x, SCHERMO.position.y + 20), Vector2(x, SCHERMO.end.y - 20), Color(CREMA, 0.04), 1.0)
		x += passo
	var y := fmod(centro.y - mezzo.y * scala, passo)
	while y < SCHERMO.end.y - 20.0:
		if y > SCHERMO.position.y + 20.0:
			t.draw_line(Vector2(SCHERMO.position.x + 20, y), Vector2(820, y), Color(CREMA, 0.04), 1.0)
		y += passo
	var nome := m.nome_del_piano(piano)
	titolo(t, Vector2(70, 178), nome, 26, CREMA)
	var quante := m.del_piano(piano)
	var viste := quante.filter(func(s: Dictionary) -> bool: return s["visitata"]).size()
	scrivi(t, Vector2(80 + largo_titolo(nome, 26), 176), "%d STANZE  ·  %d VISTE" % [quante.size(), viste], 10, Color(CREMA, 0.6), 500, 85, 2)
	for s in quante:
		occupati.append(riquadro(s))
	for c in m.corridoi:
		corridoio(t, c)
	for s in quante:
		stanza(t, s)
	for s in quante:
		scritta(t, s)


func corridoio(t: Control, c: Dictionary) -> void:
	var a: Dictionary = m.per_id[c["a"]]
	var b: Dictionary = m.per_id[c["b"]]
	if int(a["piano"]) != piano_scelto() or int(b["piano"]) != piano_scelto():
		return
	var pa := (a["pianta"] as Rect2).grow(-m.lato * ARIA)
	var pb := (b["pianta"] as Rect2).grow(-m.lato * ARIA)
	var da := a_schermo(m.porta(pa, pb.get_center()))
	var al := a_schermo(m.porta(pb, pa.get_center()))
	if c["da_qui"]:
		t.draw_line(da, al, ARANCIO, 9.0, true)
		var dal := da if String(c["a"]) == m.qui else al
		var verso := al if String(c["a"]) == m.qui else da
		freccina(t, dal, dal.lerp(verso, 0.7), NERO, 2.5)
	else:
		t.draw_line(da, al, Color(CREMA, 0.75 if c["percorso"] else 0.3), 7.0 if c["percorso"] else 4.0, true)


func stanza(t: Control, s: Dictionary) -> void:
	var r := riquadro(s)
	var stato := String(s["stato"])
	var muro := 3.0
	match stato:
		"qui":
			t.draw_rect(r, ARANCIO)
			t.draw_rect(r, NERO, false, muro)
		"vicina":
			t.draw_rect(r, Color("#2a2420"))
			t.draw_rect(r, CREMA, false, muro)
		"vista":
			t.draw_rect(r, Color("#1e1a18"))
			t.draw_rect(r, Color(CREMA, 0.5), false, 2.0)
		"chiusa":
			t.draw_rect(r, Color(SPENTO, 0.3))
			t.draw_rect(r, SPENTO, false, 2.0)
		_:
			var angoli := PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
			tratteggio(t, angoli, Color(CREMA, 0.55 if stato == "nota" else 0.3), 2.0, 7.0, 5.0)
	if String(s["id"]) == puntata():
		t.draw_rect(r.grow(5.0), ARANCIO, false, 3.0)
	# le scale, nell'angolo della stanza: dove portano lo dice la scritta
	var su_giu := ponte(s)
	if su_giu != 0 and stato in ["qui", "vicina", "vista"]:
		var inchiostro := NERO if stato == "qui" else CREMA
		Pitto.disegna(t, "scala", r.end - Vector2(10, 10), 5.5, inchiostro, NERO if stato != "qui" else ARANCIO, 0.0)
	var icona := String(s["icona"])
	if icona != "":
		Pitto.disegna(t, icona, r.position + Vector2(16, 16), 9.0, NERO if stato == "qui" else CREMA,
				ARANCIO if stato == "qui" else NERO, 2.0)
	if not (s["chi"] as Array).is_empty():
		Pitto.disegna(t, "personaggio", Vector2(r.end.x - 16, r.position.y + 16), 9.0, ARANCIO, NERO, 2.0)
	if stato == "qui":
		# niente freccia: la stanza arancio e' gia' il segno, e la freccia sopra
		# finiva sui corridoi. Basta la linguetta sul muro
		var w := misura_testo("SEI QUI", 9, 600, 85, 2) + 12.0
		t.draw_rect(Rect2(Vector2(r.position.x + 6.0, r.position.y - 8.0), Vector2(w, 16)), NERO)
		scrivi(t, Vector2(r.position.x + 12.0, r.position.y + 4.0), "SEI QUI", 9, ARANCIO, 600, 85, 2)
	if stato == "intravista":
		titolo(t, r.get_center() + Vector2(-7, 10), "?", 26, Color(CREMA, 0.45))


func scritta(t: Control, s: Dictionary) -> void:
	# IL NOME DENTRO LA STANZA, se ci sta (anche su due righe); se no sotto
	if s["stato"] == "intravista":
		return
	var r := riquadro(s)
	var nome := String(s["nome"])
	var stato := String(s["stato"])
	var forte := stato in ["qui", "vicina"] or String(s["id"]) == puntata()
	var corpo := 15 if forte else 13
	var tinta := NERO if stato == "qui" else (CREMA if forte else Color(CREMA, 0.6))
	var peso := 800 if forte else 600
	var righe := a_capo(nome, corpo, peso, r.size.x - 14.0)
	if righe.size() > 2 or (righe.size() * (corpo + 2.0)) >= r.size.y - 14.0:
		corpo = 12
		righe = a_capo(nome, corpo, peso, r.size.x - 10.0)
	if righe.size() > 2 or (righe.size() * (corpo + 1.0)) >= r.size.y - 12.0:
		corpo = 11
		righe = a_capo(nome, corpo, peso, r.size.x - 8.0)
	var alto := righe.size() * (corpo + 1.0)
	var dentro := righe.size() <= 3 and alto < r.size.y - 12.0 and r.size.x > 44.0
	if dentro:
		var y0 := r.get_center().y - alto * 0.5 + corpo - 1.0
		for i in righe.size():
			var w := largo_tondo(righe[i], corpo, peso)
			tondo(t, Vector2(r.get_center().x - w * 0.5, y0 + i * (corpo + 1.0)), righe[i], corpo, tinta, peso)
	else:
		var w := largo_tondo(nome, corpo, peso)
		var prove: Array[Rect2] = [Rect2(Vector2(r.get_center().x - w * 0.5, r.end.y + 10.0), Vector2(w, corpo + 4.0)),
				Rect2(Vector2(r.get_center().x - w * 0.5, r.position.y - corpo - 10.0), Vector2(w, corpo + 4.0)),
				Rect2(Vector2(r.end.x + 6.0, r.get_center().y - corpo * 0.5), Vector2(w, corpo + 4.0)),
				Rect2(Vector2(r.position.x - w - 6.0, r.get_center().y - corpo * 0.5), Vector2(w, corpo + 4.0))]
		var posto := posto_libero(prove)
		occupati.append(posto)
		var fondo_nome := Rect2(posto.position - Vector2(4, 0), posto.size + Vector2(8, 2))
		t.draw_rect(fondo_nome, Color(VETRO, 0.9))
		tondo(t, posto.position + Vector2(0, corpo), nome, corpo, CREMA if forte else Color(CREMA, 0.6), peso)
	var scalini := ""
	for altra in m.uscite(String(s["id"])):
		if int(altra["piano"]) != int(s["piano"]):
			scalini += "%s %s  " % [freccia_del_piano(int(s["piano"]), int(altra["piano"])), m.nome_del_piano(int(altra["piano"])).to_upper()]
	if scalini != "" and (stato in ["qui", "vicina"] or String(s["id"]) == puntata()):
		var w := misura_testo(scalini.strip_edges(), 9, 600, 85, 2) + 12.0
		var dove := Vector2(r.get_center().x - w * 0.5, r.end.y - 9.0)
		t.draw_rect(Rect2(dove, Vector2(w, 16)), NERO if stato == "qui" else ARANCIO)
		scrivi(t, dove + Vector2(6, 12), scalini.strip_edges(), 9, ARANCIO if stato == "qui" else NERO, 600, 85, 2)


func a_capo(testo: String, corpo: int, peso: int, larghezza: float) -> Array[String]:
	var righe: Array[String] = []
	var riga := ""
	for parola in testo.split(" "):
		var prova := parola if riga == "" else riga + " " + parola
		if largo_tondo(prova, corpo, peso) > larghezza and riga != "":
			righe.append(riga)
			riga = parola
		else:
			riga = prova
	righe.append(riga)
	return righe


# --- la sezione -----------------------------------------------------------------

func sezione(t: Control) -> void:
	# LA CASA TAGLIATA IN DUE: una riga per piano, dal tetto alle fondamenta. Le
	# stanze stanno dove stanno in pianta (da sinistra a destra), le scale sono
	# i fili verticali. La riga del piano in pianta ha la cornice arancio
	var ordine := m.piani_in_ordine()
	var alta := minf(SEZIONE.size.y / float(ordine.size()), 52.0)
	scrivi(t, SEZIONE.position + Vector2(0, -6), "SEZIONE  ·  %d PIANI" % ordine.size(), 10, Color(CREMA, 0.7), 600, 85, 3)
	var x0 := SEZIONE.position.x + 112.0
	var largo_barra := SEZIONE.size.x - 116.0
	var da_x := func(x: float) -> float: return x0 + (x - m.tutta.position.x) / m.tutta.size.x * largo_barra
	var quota_di := {}
	for i in ordine.size():
		quota_di[ordine[i]] = SEZIONE.position.y + 14.0 + alta * float(i)
	# le scale prima, sotto le stanze
	for c in m.corridoi:
		var a: Dictionary = m.per_id[c["a"]]
		var b: Dictionary = m.per_id[c["b"]]
		if int(a["piano"]) == int(b["piano"]):
			continue
		var xa: float = da_x.call((a["pianta"] as Rect2).get_center().x)
		var xb: float = da_x.call((b["pianta"] as Rect2).get_center().x)
		var ya: float = quota_di[int(a["piano"])] + alta * 0.45
		var yb: float = quota_di[int(b["piano"])] + alta * 0.45
		var tinta := ARANCIO if c["da_qui"] else Color(CREMA, 0.5)
		t.draw_polyline(PackedVector2Array([Vector2(xa, ya), Vector2(xa, (ya + yb) * 0.5), Vector2(xb, (ya + yb) * 0.5), Vector2(xb, yb)]),
				tinta, 2.0 if c["da_qui"] else 1.5, true)
	for i in ordine.size():
		var piano := ordine[i]
		var y: float = quota_di[piano]
		var scelto := piano == piano_scelto()
		if scelto:
			t.draw_rect(Rect2(SEZIONE.position.x - 8.0, y - 6.0, SEZIONE.size.x + 12.0, alta - 2.0), Color(ARANCIO, 0.14))
			t.draw_rect(Rect2(SEZIONE.position.x - 8.0, y - 6.0, SEZIONE.size.x + 12.0, alta - 2.0), ARANCIO, false, 2.0)
		# il solaio
		t.draw_line(Vector2(x0 - 4.0, y + alta * 0.45 + 9.0), Vector2(x0 + largo_barra + 4.0, y + alta * 0.45 + 9.0), Color(CREMA, 0.35), 2.0)
		var nome := m.nome_del_piano(piano).to_upper()
		scrivi(t, Vector2(SEZIONE.position.x + 10.0, y + alta * 0.45 + 6.0), nome, 10, ARANCIO if scelto else Color(CREMA, 0.75), 600, 85, 2)
		if piano == m.piano_qui:
			t.draw_circle(Vector2(SEZIONE.position.x + 2.0, y + alta * 0.45 + 2.0), 4.0, ARANCIO)
		for s in m.del_piano(piano):
			var p: Rect2 = s["pianta"]
			var sinistra := float(da_x.call(p.position.x + m.lato * 0.08))
			var r := Rect2(Vector2(sinistra, y + alta * 0.45 - 9.0),
					Vector2(maxf(float(da_x.call(p.end.x - m.lato * 0.08)) - sinistra, 4.0), 18.0))
			match String(s["stato"]):
				"qui":
					t.draw_rect(r, ARANCIO)
				"vicina", "vista":
					t.draw_rect(r, CREMA if s["stato"] == "vicina" else Color(CREMA, 0.55))
				"chiusa":
					t.draw_rect(r, SPENTO)
				_:
					t.draw_rect(r, Color(CREMA, 0.4), false, 1.0)
			if String(s["icona"]) in ["boss", "obiettivo"]:
				Pitto.disegna(t, String(s["icona"]), Vector2(r.get_center().x, r.position.y - 8.0), 6.0, CREMA, NERO, 2.0)


# --- la scheda ------------------------------------------------------------------

func scheda(t: Control) -> void:
	var s: Dictionary = m.per_id.get(guardata(), {})
	var y := SCHEDA.position.y
	t.draw_line(Vector2(SCHEDA.position.x - 8, y - 12), Vector2(SCHEDA.end.x + 4, y - 12), Color(CREMA, 0.2), 1.0)
	scrivi(t, Vector2(SCHEDA.position.x, y + 4), m.nome_del_piano(int(s.get("piano", 0))).to_upper(), 10, Color(CREMA, 0.6), 600, 85, 3)
	titolo(t, Vector2(SCHEDA.position.x, y + 34), String(s.get("nome", "?")), 26, CREMA)
	var ry := y + 56.0
	if String(s.get("cosa", "")) != "":
		tondo(t, Vector2(SCHEDA.position.x, ry), String(s["cosa"]), 14, Color(CREMA, 0.85), 600)
		ry += 18.0
	if not (s.get("chi", []) as Array).is_empty():
		tondo(t, Vector2(SCHEDA.position.x, ry), "c'è " + ", ".join(s["chi"]), 14, ARANCIO, 800)
		ry += 18.0
	var parola := parola_dello_stato(s)
	var w := misura_testo(parola, 11, 600, 85, 2) + 16.0
	var vai: bool = s.get("stato") in ["qui", "vicina"]
	t.draw_rect(Rect2(SCHEDA.position.x, ry - 2.0, w, 20), ARANCIO if vai else SPENTO)
	scrivi(t, Vector2(SCHEDA.position.x + 8, ry + 13), parola, 11, NERO, 600, 85, 2)
	ry += 34.0
	var fuori := m.uscite(guardata())
	var da := int(s.get("piano", 0))
	tondo(t, Vector2(SCHEDA.position.x, ry), "Da qui si va:", 13, Color(CREMA, 0.6), 600)
	var x := SCHEDA.position.x + largo_tondo("Da qui si va:", 13, 600) + 10.0
	for u in fuori:
		var voce := "%s %s" % [freccia_del_piano(da, int(u["piano"])), String(u["nome"])]
		var largo_voce := largo_tondo(voce, 13, 700) + 14.0
		if x + largo_voce > SCHEDA.end.x:
			x = SCHEDA.position.x
			ry += 18.0
		var si_va: bool = u["stato"] == "vicina" and guardata() == m.qui
		tondo(t, Vector2(x, ry), voce, 13, CREMA if si_va else Color(CREMA, 0.55), 700)
		x += largo_voce
