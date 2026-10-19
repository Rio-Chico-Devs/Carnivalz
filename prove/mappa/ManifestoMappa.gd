extends "res://prove/mappa/BaseMappa.gd"

# B · IL MANIFESTO. La mappa parla come la pausa e la crescita: l'arancio col suo
# retino, il nero pieno, la carta grigio caldo, le etichette inclinate, le
# ombre stampate. Il plastico diventa un modellino di carta: ogni piano e' un
# vassoio di cartoncino, le stanze sono blocchi neri, quella in cui sei e'
# arancio. Niente vetro e niente luce: si legge come un cartello stradale.
#
# I PIANI STANNO IN PILA, a sinistra, piccoli e tutti interi: la pila e' la
# pulsantiera (la vecchia colonna dei bottoni), e dice anche com'e' fatto ogni
# piano e su quale sei. Quello scelto esce dalla pila e si apre in grande.
#
# A destra le schede: la stanza (puntata, o quella in cui sei) e da dove si va.

const NERO := Color("#0b0908")
const CARTA := Color("#d8cfc7")
const CHIARO := Color("#ece6df")
const ARANCIO := Color("#f4931b")
const SCURO := Color("#c96f12")
const GRIGIO := Color("#8c847e")
const VISTA := Rect2(318, 118, 612, 500)
const PILA := Rect2(36, 150, 262, 470)
const X_COLONNA := 954.0
const ALTA := 0.32
const SPESSORE := 0.16
const ARIA := 0.12

var alto := 1.0
var pila := Asso.new()


func costruisci() -> void:
	Manifesto.trama_dietro(self)
	alto = ALTA * m.lato
	v.orienta(-0.72, 40.0)
	pila.orienta(-0.72, 40.0)
	var imp := m.impronta(piano_scelto())
	v.adatta(v.angoli(imp, -SPESSORE * m.lato, alto), VISTA.grow(-26.0))
	if v.scala * m.lato > 92.0:
		v.scala = 92.0 / m.lato
		v.centro = VISTA.get_center() - v.crudo(Vector3(imp.get_center().x, 0.0, imp.get_center().y)) * v.scala
	var n := m.piani_in_ordine().size()
	var alta_fetta := minf(PILA.size.y / float(n), 96.0)
	pila.adatta(pila.angoli(m.tutta.grow(m.lato * 0.35), -SPESSORE * m.lato, 0.0), Rect2(0, 0, PILA.size.x - 60.0, alta_fetta - 26.0))
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), testata)
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), piani_in_pila)
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), vassoio)
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), colonna)


func pianta_di(s: Dictionary) -> Rect2:
	return (s["pianta"] as Rect2).grow(-m.lato * ARIA)


# --- la testata -----------------------------------------------------------------

func testata(t: Control) -> void:
	# il menu come in ogni schermata, il ritorno, il nome della zona
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
	etichetta(t, Vector2(146, 74), "Torna alla stanza", 22, NERO, CHIARO)
	var nome := m.nome_zona
	var w := misura_etichetta(nome, 34).x
	etichetta(t, Vector2(1248 - w, 64), nome, 34, NERO, CHIARO)


# --- la pila dei piani ----------------------------------------------------------

func piani_in_pila(t: Control) -> void:
	# ogni piano e' lo stesso vassoio, della misura di tutta la zona: le stanze
	# di un piano stanno sopra quelle del piano di sotto, come nella casa vera
	var ordine := m.piani_in_ordine()
	var alta_fetta := minf(PILA.size.y / float(ordine.size()), 96.0)
	var vassoio_intero := m.tutta.grow(m.lato * 0.35)
	for i in ordine.size():
		var piano := ordine[i]
		var scelto := piano == piano_scelto()
		var y0 := PILA.position.y + alta_fetta * float(i)
		var spinta := Vector2(26.0 if scelto else 0.0, y0 + 22.0)
		pila.centro += spinta + Vector2(PILA.position.x + 34.0, 0.0)
		var faccia := pila.facce(vassoio_intero, -SPESSORE * m.lato, 0.0)
		var ombra := PackedVector2Array()
		for p in pila.sagoma(vassoio_intero, -SPESSORE * m.lato, 0.0):
			ombra.append(p + Vector2(5, 5))
		Manifesto.poligono(t, ombra, NERO)
		Manifesto.poligono(t, faccia["tetto"], CHIARO if scelto else CARTA)
		for fianco: PackedVector2Array in faccia["fianchi"]:
			Manifesto.poligono(t, fianco, NERO)
		t.draw_polyline(chiuso(faccia["tetto"]), ARANCIO.darkened(0.2) if scelto else NERO, 3.0 if scelto else 2.0, true)
		for s in m.del_piano(piano):
			var f := pila.facce(pianta_di(s), 0.0, 0.0)
			var tinta := ARANCIO if s["stato"] == "qui" else (NERO if s["stato"] != "intravista" else Color(NERO, 0.35))
			if s["stato"] in ["nota", "intravista"]:
				tratteggio(t, f["tetto"], tinta, 1.0, 3.0, 2.0)
			else:
				Manifesto.poligono(t, f["tetto"], tinta)
		pila.centro -= spinta + Vector2(PILA.position.x + 34.0, 0.0)
		var nome := m.nome_del_piano(piano)
		var sopra := Vector2(PILA.position.x + spinta.x, y0)
		if scelto:
			etichetta(t, sopra, nome, 15, NERO, ARANCIO)
		else:
			etichetta(t, sopra, nome, 13, Color(NERO, 0.85), CHIARO)
		if piano == m.piano_qui:
			var dopo := sopra + Vector2(misura_etichetta(nome, 15 if scelto else 13).x + 4.0, 2.0)
			etichetta(t, dopo, "SEI QUI", 11, ARANCIO.darkened(0.15), NERO)
	tasto(t, PILA.position + Vector2(0, PILA.size.y + 12.0), "Z X", "piani")


func tasto(t: Control, dove: Vector2, chiave: String, cosa: String) -> float:
	# il tasto come nella crescita: la chiave in una pillola chiara, e cosa fa
	var w := largo_tondo(chiave, 13, 800) + 18.0
	var box := StyleBoxFlat.new()
	box.anti_aliasing = true
	box.bg_color = CHIARO
	box.set_corner_radius_all(5)
	t.draw_style_box(box, Rect2(dove, Vector2(w, 24)))
	tondo(t, dove + Vector2(9, 17), chiave, 13, NERO, 800)
	tondo(t, dove + Vector2(w + 8, 17), cosa, 14, NERO, 700)
	return w + 16.0 + largo_tondo(cosa, 14, 700) + 22.0


# --- il vassoio del piano scelto ---------------------------------------------------

func vassoio(t: Control) -> void:
	occupati.clear()
	var piano := piano_scelto()
	var imp := m.impronta(piano)
	var sotto := -SPESSORE * m.lato
	var faccia := v.facce(imp, sotto, 0.0)
	var ombra := PackedVector2Array()
	for p in v.sagoma(imp, sotto, 0.0):
		ombra.append(p + Manifesto.OMBRA * 1.4)
	Manifesto.poligono(t, ombra, NERO)
	Manifesto.poligono(t, faccia["tetto"], CARTA)
	for fianco: PackedVector2Array in faccia["fianchi"]:
		Manifesto.poligono(t, fianco, NERO)
	t.draw_polyline(chiuso(faccia["tetto"]), NERO, 3.0, true)
	retino_nel(t, faccia["tetto"])
	corridoi(t, piano)
	var sue := m.del_piano(piano)
	sue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return v.profondita(centro_3d(a)) < v.profondita(centro_3d(b)))
	for s in sue:
		occupati.append(v.ingombro(pianta_di(s), 0.0, alto).grow(-4.0))
	for s in sue:
		blocco(t, s)
	for s in sue:
		segni(t, s)
	for s in sue:
		if s["stato"] in ["qui", "vicina"] or String(s["id"]) == puntata():
			cartellino(t, s)
	for s in sue:
		if s["stato"] in ["vista", "nota"] and String(s["id"]) != puntata():
			nome_a_terra(t, s)


func retino_nel(t: Control, forma: PackedVector2Array) -> void:
	# il retino del manifesto, nell'angolo del vassoio piu' vicino a chi guarda
	var r := Rect2(forma[0], Vector2.ZERO)
	for p in forma:
		r = r.expand(p)
	var y := r.position.y
	var riga := 0
	while y < r.end.y:
		var x := r.position.x + (4.5 if riga % 2 else 0.0)
		while x < r.end.x:
			var quanto := clampf(((x - r.position.x) / r.size.x - 0.5) * 2.2 + ((y - r.position.y) / r.size.y - 0.45) * 2.0 - 0.6, 0.0, 1.0)
			if quanto > 0.05 and Geometry2D.is_point_in_polygon(Vector2(x, y), forma):
				t.draw_circle(Vector2(x, y), 3.6 * quanto, Color("#b9b2ac"))
			x += 9.0
		y += 7.8
		riga += 1


func centro_3d(s: Dictionary) -> Vector3:
	var p := pianta_di(s)
	return Vector3(p.get_center().x, alto * 0.5, p.get_center().y)


func tetto(s: Dictionary) -> Vector2:
	var p := pianta_di(s)
	return v.a_schermo(Vector3(p.get_center().x, alto, p.get_center().y))


func corridoi(t: Control, piano: int) -> void:
	for c in m.corridoi:
		var a: Dictionary = m.per_id[c["a"]]
		var b: Dictionary = m.per_id[c["b"]]
		if int(a["piano"]) != piano or int(b["piano"]) != piano:
			continue
		var da := m.porta(pianta_di(a), pianta_di(b).get_center())
		var al := m.porta(pianta_di(b), pianta_di(a).get_center())
		var s_da := v.a_schermo(Vector3(da.x, 0.0, da.y))
		var s_al := v.a_schermo(Vector3(al.x, 0.0, al.y))
		if c["da_qui"]:
			t.draw_line(s_da, s_al, NERO, 11.0, true)
			t.draw_line(s_da, s_al, ARANCIO, 6.0, true)
		else:
			t.draw_line(s_da, s_al, NERO if c["percorso"] else Color(NERO, 0.45), 5.0 if c["percorso"] else 3.0, true)


func blocco(t: Control, s: Dictionary) -> void:
	var stato := String(s["stato"])
	var p := pianta_di(s)
	if stato in ["nota", "intravista"]:
		var f0 := v.facce(p, 0.0, 0.0)
		Manifesto.poligono(t, f0["tetto"], Color(CHIARO, 0.5))
		tratteggio(t, f0["tetto"], Color(NERO, 0.85 if stato == "nota" else 0.5), 2.0, 6.0, 4.0)
		if stato == "intravista":
			var c := v.a_schermo(Vector3(p.get_center().x, 0.0, p.get_center().y))
			titolo(t, c + Vector2(-7, 9), "?", 24, Color(NERO, 0.7))
		return
	var f := v.facce(p, 0.0, alto)
	var cima := NERO
	match stato:
		"qui":
			cima = ARANCIO
		"chiusa":
			cima = GRIGIO
	for fianco: PackedVector2Array in f["fianchi"]:
		Manifesto.poligono(t, fianco, NERO)
	Manifesto.poligono(t, f["tetto"], cima)
	if stato == "vicina" or String(s["id"]) == puntata():
		# dove arrivi: il tetto nero col filo chiaro dentro, come un tasto
		var dentro := v.facce(p.grow(-m.lato * 0.07), alto, alto)
		t.draw_polyline(chiuso(dentro["tetto"]), CHIARO, 2.5, true)
	elif stato == "vista":
		punteggia(t, f["tetto"])
	t.draw_polyline(chiuso(f["tetto"]), NERO, 2.0, true)
	for fianco: PackedVector2Array in f["fianchi"]:
		t.draw_polyline(chiuso(fianco), CHIARO if stato != "qui" else NERO, 1.0, true)
	if String(s["id"]) == puntata():
		var giro := v.sagoma(p.grow(m.lato * 0.08), 0.0, alto)
		t.draw_polyline(chiuso(giro), ARANCIO, 4.0, true)


func punteggia(t: Control, forma: PackedVector2Array) -> void:
	# dove sei stato ma non arrivi: il nero si apre in puntini grigi
	var r := Rect2(forma[0], Vector2.ZERO)
	for p in forma:
		r = r.expand(p)
	var y := r.position.y + 3.0
	var riga := 0
	while y < r.end.y:
		var x := r.position.x + (3.0 if riga % 2 else 0.0)
		while x < r.end.x:
			if Geometry2D.is_point_in_polygon(Vector2(x, y), forma):
				t.draw_circle(Vector2(x, y), 1.4, GRIGIO)
			x += 6.0
		y += 5.2
		riga += 1


func segni(t: Control, s: Dictionary) -> void:
	var cima := tetto(s)
	if s["stato"] == "qui":
		Pitto.disegna(t, "sei_qui", cima + Vector2(0, -30), 15.0, ARANCIO, NERO, 3.5)
		occupati.append(Rect2(cima + Vector2(-18, -48), Vector2(36, 40)))
	var icona := String(s["icona"])
	if icona != "" and s["stato"] not in ["nota", "intravista"]:
		Pitto.disegna(t, icona, cima + Vector2(0, -1), 9.0, CHIARO if s["stato"] != "qui" else NERO, NERO if s["stato"] != "qui" else ARANCIO, 0.0)
	if not (s["chi"] as Array).is_empty():
		var dove := cima + Vector2(20, -14)
		Pitto.disegna(t, "personaggio", dove, 9.0, NERO, ARANCIO, 3.0)
		occupati.append(Rect2(dove - Vector2(12, 12), Vector2(24, 24)))
	if s["stato"] == "chiusa":
		Pitto.disegna(t, "chiusa", cima + Vector2(0, -2), 8.0, NERO, GRIGIO, 0.0)


func cartellino(t: Control, s: Dictionary) -> void:
	# L'ETICHETTA NERA COL NOME, attaccata alla stanza con un filo: solo dove sei,
	# dove arrivi adesso e quella puntata. Le scale le dice una seconda fascia
	var nome := String(s["nome"])
	var qui_sei: bool = s["stato"] == "qui"
	var corpo := 15 if qui_sei or s["stato"] == "vicina" else 13
	var misura := misura_etichetta(nome, corpo)
	var scalini := scale_di(s)
	var w := maxf(misura.x, misura_etichetta(scalini, 11).x if scalini != "" else 0.0)
	var h := misura.y + (17.0 if scalini != "" else 0.0)
	var cima := tetto(s)
	var r := posto_libero(intorno(cima, w, h))
	occupati.append(r.grow(4.0))
	var attacco := Vector2(clampf(cima.x, r.position.x + 8.0, r.end.x - 8.0), r.position.y + misura.y * 0.5)
	if attacco.y < cima.y:
		attacco.y = r.end.y - 3.0
	t.draw_line(cima, attacco, NERO, 2.5, true)
	t.draw_circle(cima, 4.0, NERO)
	etichetta(t, r.position, nome, corpo, NERO, ARANCIO if qui_sei else CHIARO)
	if scalini != "":
		etichetta(t, r.position + Vector2(10, misura.y + 1.0), scalini, 11, CHIARO, NERO)


func scale_di(s: Dictionary) -> String:
	# «↑ SOFFITTA», «↓ PIANO TERRA»: dove portano le scale di questa stanza
	var dove: Array[String] = []
	for altra in m.uscite(String(s["id"])):
		if int(altra["piano"]) != int(s["piano"]):
			dove.append("%s %s" % [freccia_del_piano(int(s["piano"]), int(altra["piano"])), m.nome_del_piano(int(altra["piano"]))])
	return "  ".join(dove)


func nome_a_terra(t: Control, s: Dictionary) -> void:
	# il nome scritto sul cartoncino, sotto la stanza: piccolo e nero, se c'e' posto
	var nome := String(s["nome"])
	var base := v.ingombro(pianta_di(s), 0.0, alto)
	var w := largo_tondo(nome, 12, 800)
	for r: Rect2 in [Rect2(Vector2(base.get_center().x - w * 0.5, base.end.y + 1.0), Vector2(w, 14)),
			Rect2(Vector2(base.end.x + 3.0, base.get_center().y - 7.0), Vector2(w, 14)),
			Rect2(Vector2(base.position.x - w - 3.0, base.get_center().y - 7.0), Vector2(w, 14))]:
		if not occupati.any(func(o: Rect2) -> bool: return o.intersects(r)):
			occupati.append(r)
			tondo(t, r.position + Vector2(0, 11), nome, 12, NERO, 800)
			return


# --- la colonna delle schede ------------------------------------------------------

func colonna(t: Control) -> void:
	var s: Dictionary = m.per_id.get(guardata(), {})
	var y := 130.0
	var alta := 150.0 + (18.0 if String(s.get("cosa", "")) != "" else 0.0) + (18.0 if not (s.get("chi", []) as Array).is_empty() else 0.0)
	Manifesto.carta(t, Rect2(X_COLONNA, y, 292, alta), CARTA, 4.0, true)
	etichetta(t, Vector2(X_COLONNA - 8, y - 14), m.nome_del_piano(int(s.get("piano", 0))).to_upper(), 12, NERO, CHIARO)
	titolo(t, Vector2(X_COLONNA + 18, y + 54), String(s.get("nome", "?")), 30, NERO)
	var ry := y + 82.0
	if String(s.get("cosa", "")) != "":
		tondo(t, Vector2(X_COLONNA + 18, ry), String(s["cosa"]), 15, NERO, 700)
		ry += 20.0
	if not (s.get("chi", []) as Array).is_empty():
		tondo(t, Vector2(X_COLONNA + 18, ry), "c'è " + ", ".join(s["chi"]), 15, Color("#a0520a"), 800)
		ry += 20.0
	var parola := parola_dello_stato(s)
	var fondo_parola := ARANCIO if s.get("stato") == "qui" else (NERO if s.get("stato") == "vicina" else GRIGIO)
	etichetta(t, Vector2(X_COLONNA + 16, ry + 6), parola, 17, fondo_parola, NERO if s.get("stato") == "qui" else CHIARO)
	y += alta + 30.0
	var fuori := m.uscite(guardata())
	var alta_uscite := 52.0 + fuori.size() * 26.0
	Manifesto.carta(t, Rect2(X_COLONNA, y, 292, alta_uscite), CARTA, 4.0, false)
	etichetta(t, Vector2(X_COLONNA - 8, y - 14), "DA QUI SI VA", 12, NERO, CHIARO)
	var da := int(s.get("piano", 0))
	for i in fuori.size():
		var u: Dictionary = fuori[i]
		var uy := y + 40.0 + i * 26.0
		var si_va: bool = u["stato"] == "vicina" and guardata() == m.qui
		titolo(t, Vector2(X_COLONNA + 18, uy), freccia_del_piano(da, int(u["piano"])), 18, ARANCIO.darkened(0.25) if si_va else GRIGIO)
		tondo(t, Vector2(X_COLONNA + 44, uy), String(u["nome"]), 16, NERO if si_va else Color(NERO, 0.55), 800 if si_va else 600)
	# i tasti, in basso come nella crescita
	var x := 40.0
	x += tasto(t, Vector2(x, 672), "CLIC", "vai")
	x += tasto(t, Vector2(x, 672), "TRASCINA", "gira")
	x += tasto(t, Vector2(x, 672), "ESC", "indietro")
	legenda(t)


func legenda(t: Control) -> void:
	var voci := [["sei_qui", "sei qui"], ["obiettivo", "dove devi andare"], ["boss", "il boss"], ["forte", "scontro duro"],
			["personaggio", "qualcuno"], ["uscita", "uscita"]]
	var y := 560.0
	var x := X_COLONNA
	for i in voci.size():
		var dove := Vector2(x + float(i % 2) * 150.0, y + floorf(i / 2.0) * 30.0)
		var box := StyleBoxFlat.new()
		box.anti_aliasing = true
		box.bg_color = NERO
		box.set_corner_radius_all(14)
		t.draw_style_box(box, Rect2(dove, Vector2(140, 26)))
		Pitto.disegna(t, String(voci[i][0]), dove + Vector2(16, 13), 7.5, ARANCIO if voci[i][0] == "sei_qui" else CHIARO, NERO, 0.0)
		tondo(t, dove + Vector2(32, 18), String(voci[i][1]), 13, CHIARO, 700)
