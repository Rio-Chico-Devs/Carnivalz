extends "res://prove/mappa/BaseMappa.gd"

# A · LA VETRINA. Il plastico resta un modellino in 3D, come quello di Metroid
# Prime che ha mandato Bru, ma parla la lingua della mappa stellare e del Vuoto
# (Proiezione), che Bru ha approvato: i quattro inchiostri della serigrafia, le
# didascalie a linguetta, la colonna delle schede a destra, il titolo in basso.
# Le due mappe del gioco diventano sorelle.
#
# I PIANI SI APRONO COME UN CASSETTIERA. Quello scelto sta in mezzo, grande, e
# gli altri si allontanano sopra e sotto, spenti: dove oggi i piani si
# sovrappongono (sei piani della Casa Gigante in un modellino solo) qui uno solo
# alla volta si legge, e gli altri dicono soltanto che ci sono e dove le scale
# ci portano. Z e X, o la colonna dei piani, fanno scorrere il cassetto.

const FONDO := Color("#0b0e14")
const INCHIOSTRO := Color("#4a7aa8")
const CARTA := Color("#efd8b2")
const SEGNALE := Color("#f29a2e")
const AREA := Rect2(24, 66, 930, 548)
const X_COLONNA := 970.0
const LARGA_COLONNA := 274.0
const ALTA := 0.3          # l'altezza di una stanza, in lati di stanza
const CELLA_MASSIMA := 96.0
const ARIA := 0.1          # quanto si ritira una stanza dalla sua cella: fra due stanze si vede il corridoio

var gap := 1.0
var alto := 1.0


func costruisci() -> void:
	v.orienta(-0.62, 36.0)
	alto = ALTA * m.lato
	var f := piano_scelto()
	var imp := m.impronta(f)
	var dentro := Rect2(Vector2(AREA.size.x * 0.08, AREA.size.y * 0.3), AREA.size * Vector2(0.84, 0.5))
	v.adatta(v.angoli(imp, 0.0, alto), dentro)
	if v.scala * m.lato > CELLA_MASSIMA:
		# un piano di tre stanze non diventa un piano di tre stanze giganti
		v.scala = CELLA_MASSIMA / m.lato
		v.centro = dentro.get_center() - v.crudo(Vector3(imp.get_center().x, alto * 0.5, imp.get_center().y)) * v.scala
	gap = AREA.size.y * 0.4 / (cos(deg_to_rad(v.altezza)) * v.scala)
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), fondo)
	strato(AREA, modellino, true)
	strato(Rect2(Vector2.ZERO, Vector2(1280, 720)), cornice)


func quota(piano: int) -> float:
	return float(piano - piano_scelto()) * gap


# --- il fondo -------------------------------------------------------------------

func fondo(t: Control) -> void:
	t.draw_rect(Rect2(Vector2.ZERO, t.size), FONDO)
	# il foglio millimetrato della proiezione, appena accennato
	var passo := 24.0
	var y := 0.0
	while y < t.size.y:
		var x := 0.0
		while x < t.size.x:
			var lontano := (Vector2(x, y) - Vector2(480, 360)).length() / 700.0
			t.draw_rect(Rect2(x, y, 1.5, 1.5), Color(INCHIOSTRO, 0.16 * (1.0 - clampf(lontano, 0.0, 1.0))))
			x += passo
		y += passo


# --- il modellino ---------------------------------------------------------------

func modellino(t: Control) -> void:
	occupati.clear()
	var ordine := m.piani_in_ordine()
	ordine.reverse()   # dal piu' basso: e' il piu' lontano da chi guarda
	for piano in ordine:
		lastra(t, piano)
	for piano in ordine:
		if piano != piano_scelto():
			stanze_spente(t, piano)
	pozzi(t)
	corridoi(t)
	var sue := m.del_piano(piano_scelto())
	sue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return v.profondita(centro_3d(a)) < v.profondita(centro_3d(b)))
	for s in sue:
		stanza(t, s)
	for s in sue:
		segni(t, s)
	didascalie(t, sue)


func centro_3d(s: Dictionary) -> Vector3:
	var p: Rect2 = s["pianta"]
	return Vector3(p.get_center().x, quota(int(s["piano"])) + alto * 0.5, p.get_center().y)


func tetto(s: Dictionary) -> Vector2:
	var p: Rect2 = s["pianta"]
	return v.a_schermo(Vector3(p.get_center().x, quota(int(s["piano"])) + alto, p.get_center().y))


func lastra(t: Control, piano: int) -> void:
	var scelto := piano == piano_scelto()
	var imp := m.impronta(piano)
	var y := quota(piano)
	var faccia := v.facce(imp, y - 0.06 * m.lato, y)
	Manifesto.poligono(t, faccia["tetto"], Color(INCHIOSTRO, 0.10 if scelto else 0.05))
	for fianco: PackedVector2Array in faccia["fianchi"]:
		Manifesto.poligono(t, fianco, Color(INCHIOSTRO, 0.3 if scelto else 0.12))
	t.draw_polyline(chiuso(faccia["tetto"]), Color(INCHIOSTRO, 0.85 if scelto else 0.3), 1.5 if scelto else 1.0, true)
	if scelto:
		# il reticolo del piano: una cella per lato di stanza
		var x := imp.position.x
		while x < imp.end.x:
			t.draw_line(v.a_schermo(Vector3(x, y, imp.position.y)), v.a_schermo(Vector3(x, y, imp.end.y)), Color(INCHIOSTRO, 0.13), 1.0)
			x += m.lato * 0.5
		var z := imp.position.y
		while z < imp.end.y:
			t.draw_line(v.a_schermo(Vector3(imp.position.x, y, z)), v.a_schermo(Vector3(imp.end.x, y, z)), Color(INCHIOSTRO, 0.13), 1.0)
			z += m.lato * 0.5
	# il nome del piano sull'angolo sinistro della lastra
	var angolo := v.a_schermo(Vector3(imp.position.x, y, imp.end.y))
	for p in faccia["tetto"]:
		angolo = p if p.x < angolo.x else angolo
	var nome := m.nome_del_piano(piano).to_upper()
	var tinta := CARTA if scelto else Color(INCHIOSTRO, 0.8)
	scrivi(t, angolo + Vector2(-misura_testo(nome, 10, 600, 85, 2) * 0.5, 22.0), nome, 10, tinta, 600, 85, 2)
	if piano == m.piano_qui and not scelto:
		t.draw_circle(angolo + Vector2(-misura_testo(nome, 10, 600, 85, 2) * 0.5 - 9.0, 18.0), 3.5, SEGNALE)


func stanze_spente(t: Control, piano: int) -> void:
	# GLI ALTRI PIANI SONO SOLO IMPRONTE: le stanze piatte sulla loro lastra, a
	# filo. Dicono che il piano c'e' e com'e' fatto, e non si fanno leggere
	# prima di quello scelto. La tua si vede anche da li'
	for s in m.del_piano(piano):
		var y := quota(piano)
		var faccia := v.facce(pianta_di(s), y, y)
		var qui_sta: bool = s["stato"] == "qui"
		if qui_sta:
			Manifesto.poligono(t, faccia["tetto"], Color(SEGNALE, 0.55))
		var tinta := SEGNALE if qui_sta else Color(INCHIOSTRO, 0.5 if s["stato"] != "intravista" else 0.25)
		t.draw_polyline(chiuso(faccia["tetto"]), tinta, 1.0, true)


func pianta_di(s: Dictionary) -> Rect2:
	return (s["pianta"] as Rect2).grow(-m.lato * ARIA)


func stanza(t: Control, s: Dictionary) -> void:
	var p: Rect2 = s["pianta"]
	var y := quota(int(s["piano"]))
	var faccia := v.facce(pianta_di(s), y, y + alto)
	var stato := String(s["stato"])
	var puntata_qui := String(s["id"]) == puntata()
	var tinta := CARTA
	var pieno := 0.0
	var bordo := 1.5
	match stato:
		"qui":
			tinta = SEGNALE
			pieno = 0.95
			bordo = 2.0
		"vicina":
			pieno = 0.9
			bordo = 2.0
		"vista":
			pieno = 0.32
		"chiusa":
			tinta = INCHIOSTRO
			pieno = 0.3
		"intravista":
			tinta = INCHIOSTRO
	if puntata_qui:
		pieno = maxf(pieno, 0.5)
	for fianco: PackedVector2Array in faccia["fianchi"]:
		if pieno > 0.0:
			Manifesto.poligono(t, fianco, Color(tinta.darkened(0.55), pieno))
	if pieno > 0.0:
		Manifesto.poligono(t, faccia["tetto"], Color(tinta, pieno))
		if stato == "vista":
			retino(t, faccia["tetto"], Color(CARTA, 0.5))
	var linea := Color(tinta.lightened(0.25) if stato == "qui" else tinta, 1.0 if pieno > 0.5 else 0.75)
	if stato in ["nota", "intravista"]:
		tratteggio(t, faccia["tetto"], linea, bordo, 5.0, 4.0)
		for fianco: PackedVector2Array in faccia["fianchi"]:
			tratteggio(t, fianco, Color(linea, 0.45), 1.0, 4.0, 4.0)
	else:
		t.draw_polyline(chiuso(faccia["tetto"]), linea, bordo, true)
		for fianco: PackedVector2Array in faccia["fianchi"]:
			t.draw_polyline(chiuso(fianco), Color(linea, 0.7), 1.0, true)
	if puntata_qui:
		var sagoma := v.sagoma(p.grow(m.lato * 0.06), y, y + alto)
		t.draw_polyline(chiuso(sagoma), Color(1, 1, 1, 0.95), 2.5, true)
	if stato == "intravista":
		var c := v.a_schermo(Vector3(p.get_center().x, y + alto, p.get_center().y))
		scrivi(t, c + Vector2(-5, 7), "?", 18, Color(INCHIOSTRO.lightened(0.3), 0.9), 700, 85, 0)


func retino(t: Control, tetto_stanza: PackedVector2Array, tinta: Color) -> void:
	# i puntini della serigrafia dentro il tetto di una stanza in cui sei stato
	var r := Rect2(tetto_stanza[0], Vector2.ZERO)
	for p in tetto_stanza:
		r = r.expand(p)
	var y := r.position.y + 3.0
	var riga := 0
	while y < r.end.y:
		var x := r.position.x + (3.0 if riga % 2 else 0.0)
		while x < r.end.x:
			if Geometry2D.is_point_in_polygon(Vector2(x, y), tetto_stanza):
				t.draw_circle(Vector2(x, y), 0.9, tinta)
			x += 6.0
		y += 5.0
		riga += 1


func corridoi(t: Control) -> void:
	# i corridoi del piano scelto: strisce sulla lastra, arancio quelli che
	# partono da dove sei verso dove puoi andare
	for c in m.corridoi:
		var a: Dictionary = m.per_id[c["a"]]
		var b: Dictionary = m.per_id[c["b"]]
		if int(a["piano"]) != int(b["piano"]) or int(a["piano"]) != piano_scelto():
			continue
		var pa: Rect2 = a["pianta"]
		var pb: Rect2 = b["pianta"]
		var y := quota(int(a["piano"])) + 0.01
		var da := m.porta(pa, pb.get_center())
		var al := m.porta(pb, pa.get_center())
		var s_da := v.a_schermo(Vector3(da.x, y, da.y))
		var s_al := v.a_schermo(Vector3(al.x, y, al.y))
		var tinta := Color(INCHIOSTRO, 0.7)
		var spesso := 3.0
		if c["da_qui"]:
			tinta = SEGNALE
			spesso = 5.0
		elif c["percorso"]:
			tinta = Color(CARTA, 0.55)
		t.draw_line(s_da, s_al, tinta, spesso, true)
		if c["da_qui"]:
			var verso := s_al if String(c["a"]) == m.qui else s_da
			var dal := s_da if String(c["a"]) == m.qui else s_al
			freccina(t, dal, dal.lerp(verso, 0.75), SEGNALE, 3.0)


func pozzi(t: Control) -> void:
	# LE SCALE: un pozzo dritto dalla porta della stanza fino al piano dove porta,
	# e li' un passo fino alla stanza. Arancio se e' un'uscita di dove sei
	for c in m.corridoi:
		var a: Dictionary = m.per_id[c["a"]]
		var b: Dictionary = m.per_id[c["b"]]
		if int(a["piano"]) == int(b["piano"]) or piano_scelto() not in [int(a["piano"]), int(b["piano"])]:
			continue
		if int(b["piano"]) == piano_scelto():
			var scambio := a
			a = b
			b = scambio
		var tinta := SEGNALE if c["da_qui"] else Color(INCHIOSTRO.lightened(0.2), 0.85)
		var da := m.porta(pianta_di(a), pianta_di(b).get_center())
		var al := m.porta(pianta_di(b), pianta_di(a).get_center())
		var ya := quota(int(a["piano"])) + (alto if int(b["piano"]) > int(a["piano"]) else 0.0)
		var yb := quota(int(b["piano"]))
		var punti := PackedVector2Array([v.a_schermo(Vector3(da.x, ya, da.y)), v.a_schermo(Vector3(da.x, yb, da.y)),
				v.a_schermo(Vector3(al.x, yb, al.y))])
		a_tratti(t, punti, tinta, 2.0 if c["da_qui"] else 1.2)
		t.draw_circle(punti[2], 3.0, tinta)


func segni(t: Control, s: Dictionary) -> void:
	var cima := tetto(s)
	if s["stato"] == "qui":
		Pitto.disegna(t, "sei_qui", cima + Vector2(0, -34), 13.0, SEGNALE, FONDO, 3.0)
	var icona := String(s["icona"])
	if icona != "":
		var dove := cima + Vector2(0, -22 if s["stato"] != "qui" else -62)
		Pitto.disegna(t, icona, dove, 9.0, CARTA, FONDO, 3.0)
		occupati.append(Rect2(dove - Vector2(14, 14), Vector2(28, 28)))
	if s["stato"] == "chiusa":
		Pitto.disegna(t, "chiusa", cima + Vector2(0, -2), 8.0, INCHIOSTRO.lightened(0.4), FONDO, 2.0)
	if not (s["chi"] as Array).is_empty():
		Pitto.disegna(t, "personaggio", cima + Vector2(16, -8), 7.0, SEGNALE, FONDO, 2.5)
	if s["stato"] == "qui":
		occupati.append(Rect2(cima + Vector2(-16, -50), Vector2(32, 46)))


func didascalie(t: Control, sue: Array[Dictionary]) -> void:
	# LINGUETTE SOLO DOVE SI AGISCE: dove sei, dove arrivi adesso, e la stanza
	# puntata. Le altre hanno il nome piccolo, se c'e' posto; quelle che non
	# conosci un «?» dentro il tetto. Oggi ogni stanza ha il suo nome alla stessa
	# misura, e sulla Casa Gigante si coprono a vicenda
	for s in sue:
		occupati.append(v.ingombro(s["pianta"], quota(int(s["piano"])), quota(int(s["piano"])) + alto).grow(-6.0))
	var prima: Array[Dictionary] = []
	var poi: Array[Dictionary] = []
	for s in sue:
		if s["stato"] in ["qui", "vicina"] or String(s["id"]) == puntata():
			prima.append(s)
		elif s["stato"] in ["vista", "nota"]:
			poi.append(s)
	for s in prima:
		linguetta(t, s)
	for s in poi:
		nome_piccolo(t, s)


func linguetta(t: Control, s: Dictionary) -> void:
	var nome := String(s["nome"]).to_upper()
	var sotto := parola_dello_stato(s)
	if not (s["chi"] as Array).is_empty():
		sotto = "C'È %s  ·  %s" % [", ".join(s["chi"]).to_upper(), sotto]
	var w := maxf(misura_testo(nome, 12, 600, 85, 1) + 14.0, misura_testo(sotto, 9, 500, 85, 2) + 14.0)
	var cima := tetto(s)
	var prove := intorno(cima, w, 32.0)
	var r := posto_libero(prove)
	occupati.append(r.grow(3.0))
	var qui_sei: bool = s["stato"] == "qui"
	var attacco := Vector2(r.position.x if r.position.x > cima.x else r.end.x, r.position.y + 9.0)
	t.draw_line(cima, attacco, Color(CARTA, 0.8), 1.0, true)
	t.draw_circle(cima, 2.0, CARTA)
	t.draw_rect(Rect2(r.position, Vector2(w, 18)), SEGNALE if qui_sei else CARTA)
	scrivi(t, r.position + Vector2(7, 13.5), nome, 12, FONDO, 600, 85, 1)
	t.draw_line(r.position + Vector2(0, 19), r.position + Vector2(w, 19), Color(INCHIOSTRO, 0.9), 1.0)
	var tinta := SEGNALE if qui_sei else (CARTA if s["stato"] == "vicina" else INCHIOSTRO.lightened(0.3))
	t.draw_circle(r.position + Vector2(4, 27), 2.0, tinta)
	scrivi(t, r.position + Vector2(10, 30.5), sotto, 9, tinta, 500, 85, 2)


func nome_piccolo(t: Control, s: Dictionary) -> void:
	var nome := String(s["nome"])
	var p: Rect2 = s["pianta"]
	var y := quota(int(s["piano"]))
	var basso := v.ingombro(p, y, y + alto)
	var w := misura_testo(nome, 10, 400, 85, 1)
	var prove: Array[Rect2] = [Rect2(Vector2(basso.get_center().x - w * 0.5, basso.end.y + 2.0), Vector2(w, 12)),
			Rect2(Vector2(basso.end.x + 4.0, basso.get_center().y - 6.0), Vector2(w, 12)),
			Rect2(Vector2(basso.position.x - w - 4.0, basso.get_center().y - 6.0), Vector2(w, 12))]
	for r in prove:
		if not occupati.any(func(o: Rect2) -> bool: return o.intersects(r)):
			occupati.append(r)
			scrivi(t, r.position + Vector2(0, 10), nome, 10, Color(CARTA, 0.6 if s["stato"] == "vista" else 0.45), 400, 85, 1)
			return


# --- la cornice: intestazione, colonna, titolo ------------------------------------

func cornice(t: Control) -> void:
	var f := piano_scelto()
	# gli angoli della proiezione e il menu
	for angolo: Vector2 in [Vector2(16, 16), Vector2(1264, 16), Vector2(16, 704), Vector2(1264, 704)]:
		var sx := 1.0 if angolo.x < 640 else -1.0
		var sy := 1.0 if angolo.y < 360 else -1.0
		t.draw_line(angolo, angolo + Vector2(sx * 14, 0), Color(CARTA, 0.7), 2.0)
		t.draw_line(angolo, angolo + Vector2(0, sy * 14), Color(CARTA, 0.7), 2.0)
	menu(t, Vector2(62, 62))
	var briciole := "CARNIVALZ  ·  %s  ·  %s" % [m.nome_zona.to_upper(), m.nome_del_piano(f).to_upper()]
	scrivi(t, Vector2(148, 44), briciole, 11, Color(CARTA, 0.85), 500, 85, 3)
	t.draw_line(Vector2(148, 56), Vector2(940, 56), Color(INCHIOSTRO, 0.6), 1.0)
	var x := 148.0
	while x <= 940.0:
		t.draw_line(Vector2(x, 56), Vector2(x, 60 if int(x) % 40 == 28 else 58), Color(INCHIOSTRO, 0.6), 1.0)
		x += 8.0
	var esplorata := "VISTE %d DI %d" % [m.conta_visitate(), GameState.mappa_zona.get("stanze", []).size()]
	scrivi(t, Vector2(X_COLONNA + 2, 44), "PROIEZIONE", 11, Color(CARTA, 0.85), 500, 85, 3)
	t.draw_circle(Vector2(X_COLONNA + 100, 40), 3.0, SEGNALE)
	scrivi(t, Vector2(1244 - misura_testo(esplorata, 11, 500, 85, 3), 44), esplorata, 11, Color(CARTA, 0.85), 500, 85, 3)
	var y := scheda_stanza(t, 74.0)
	y = scheda_uscite(t, y + 8.0)
	y = scheda_piani(t, y + 8.0)
	comandi(t)
	# il titolo in basso a sinistra, come IL SETTORE e IL VUOTO ARDENTE
	var sopra := "PROIEZIONE DELLA ZONA  ·  %d PIANI" % m.piani_in_ordine().size()
	scrivi(t, Vector2(38, 628), sopra, 11, SEGNALE, 600, 85, 3)
	var nome := m.nome_zona.to_upper()
	var w := largo_titolo(nome, 34) + 30.0
	Manifesto.poligono(t, PackedVector2Array([Vector2(40, 638), Vector2(40 + w, 638), Vector2(30 + w, 682), Vector2(30, 682)]), SEGNALE)
	titolo(t, Vector2(46, 673), nome, 34, FONDO)


func menu(t: Control, dove: Vector2) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = SEGNALE
	box.set_corner_radius_all(10)
	box.anti_aliasing = true
	t.draw_style_box(box, Rect2(dove, Vector2(64, 64)))
	for i in 3:
		t.draw_rect(Rect2(dove + Vector2(14, 18 + i * 12), Vector2(36, 5)), FONDO)


func scatola(t: Control, y: float, alta: float, numero: String, voce: String) -> void:
	t.draw_rect(Rect2(X_COLONNA, y, LARGA_COLONNA, alta), Color(FONDO, 0.92))
	t.draw_rect(Rect2(X_COLONNA, y, LARGA_COLONNA, alta), Color(INCHIOSTRO, 0.9), false, 1.0)
	var linguetta_testo := "%s / %s" % [numero, voce]
	var w := misura_testo(linguetta_testo, 9, 600, 85, 1) + 14.0
	Manifesto.poligono(t, PackedVector2Array([Vector2(X_COLONNA, y - 6), Vector2(X_COLONNA + w + 4, y - 6),
			Vector2(X_COLONNA + w, y + 8), Vector2(X_COLONNA, y + 8)]), SEGNALE)
	scrivi(t, Vector2(X_COLONNA + 5, y + 5), linguetta_testo, 9, FONDO, 600, 85, 1)


func scheda_stanza(t: Control, y: float) -> float:
	var s: Dictionary = m.per_id.get(guardata(), {})
	var righe := []
	if String(s.get("cosa", "")) != "":
		righe.append(String(s["cosa"]))
	if not (s.get("chi", []) as Array).is_empty():
		righe.append("c'è " + ", ".join(s["chi"]))
	if String(s.get("icona", "")) != "":
		righe.append(String(Pitto.NOMI.get(s["icona"], "")))
	var alta := 64.0 + righe.size() * 16.0
	scatola(t, y, alta, "01", "STANZA")
	scrivi(t, Vector2(X_COLONNA + 12, y + 34), String(s.get("nome", "?")).to_upper(), 20, CARTA, 600, 85, 2)
	var sotto := "%s  ·  %s" % [m.nome_del_piano(int(s.get("piano", 0))).to_upper(), parola_dello_stato(s)]
	scrivi(t, Vector2(X_COLONNA + 12, y + 52), sotto, 9, SEGNALE if s.get("stato") == "qui" else INCHIOSTRO.lightened(0.3), 600, 85, 2)
	for i in righe.size():
		tondo(t, Vector2(X_COLONNA + 12, y + 72 + i * 16), String(righe[i]), 12, Color(CARTA, 0.85), 500)
	return y + alta


func scheda_uscite(t: Control, y: float) -> float:
	# DA QUI SI VA: la domanda a cui la mappa risponde a ogni passo, scritta
	var fuori := m.uscite(guardata())
	var alta := 30.0 + fuori.size() * 22.0
	scatola(t, y, alta, "02", "DA QUI SI VA")
	var da := int(m.per_id.get(guardata(), {}).get("piano", 0))
	for i in fuori.size():
		var s: Dictionary = fuori[i]
		var ry := y + 30.0 + i * 22.0
		var si_va: bool = s["stato"] in ["vicina", "qui"] and guardata() == m.qui
		var tinta := CARTA if si_va else Color(INCHIOSTRO.lightened(0.25), 0.9)
		scrivi(t, Vector2(X_COLONNA + 12, ry), freccia_del_piano(da, int(s["piano"])), 13, SEGNALE if si_va else tinta, 600, 85, 0)
		tondo(t, Vector2(X_COLONNA + 32, ry), String(s["nome"]), 13, tinta, 700 if si_va else 500)
		if int(s["piano"]) != da:
			var piano := m.nome_del_piano(int(s["piano"])).to_upper()
			scrivi(t, Vector2(X_COLONNA + LARGA_COLONNA - 10 - misura_testo(piano, 8, 500, 85, 2), ry - 1), piano, 8,
					Color(INCHIOSTRO.lightened(0.3), 0.9), 500, 85, 2)
	return y + alta


func scheda_piani(t: Control, y: float) -> float:
	var ordine := m.piani_in_ordine()
	var alta := 30.0 + ordine.size() * 22.0
	scatola(t, y, alta, "03", "PIANI  ·  Z X")
	for i in ordine.size():
		var piano := ordine[i]
		var ry := y + 28.0 + i * 22.0
		var scelto := piano == piano_scelto()
		if scelto:
			t.draw_rect(Rect2(X_COLONNA + 1, ry - 14, LARGA_COLONNA - 2, 20), Color(INCHIOSTRO, 0.35))
		if piano == m.piano_qui:
			t.draw_circle(Vector2(X_COLONNA + 12, ry - 4), 3.5, SEGNALE)
		scrivi(t, Vector2(X_COLONNA + 22, ry), m.nome_del_piano(piano).to_upper(), 10, CARTA if scelto else Color(CARTA, 0.6), 600, 85, 2)
		# una tacca per stanza: piena dove sei stato, vuota dove no, «?» dove non sai
		var x := X_COLONNA + LARGA_COLONNA - 12.0
		for s in m.del_piano(piano):
			var c := Vector2(x, ry - 4)
			if s["visitata"] or s["stato"] == "qui":
				t.draw_rect(Rect2(c - Vector2(3, 3), Vector2(6, 6)), SEGNALE if s["stato"] == "qui" else CARTA)
			elif s["stato"] == "intravista":
				t.draw_rect(Rect2(c - Vector2(3, 3), Vector2(6, 6)), Color(INCHIOSTRO, 0.9), false, 1.0)
			else:
				t.draw_rect(Rect2(c - Vector2(3, 3), Vector2(6, 6)), CARTA, false, 1.0)
			x -= 9.0
	return y + alta


func comandi(t: Control) -> void:
	var righe := ["CLIC  ·  VAI          DOPPIO CLIC  ·  RICENTRA", "Z X  ·  PIANI          TRASCINA  ·  GIRA",
			"ROTELLA  ·  AVVICINA          ESC  ·  TORNA"]
	for i in righe.size():
		scrivi(t, Vector2(X_COLONNA + 2, 590 + i * 13), righe[i], 8, Color(INCHIOSTRO.lightened(0.3), 0.9), 500, 85, 2)
	var r := Rect2(X_COLONNA, 634, LARGA_COLONNA, 38)
	t.draw_rect(r, Color(0.02, 0.02, 0.03))
	var testo := "Torna alla stanza"
	titolo(t, Vector2(r.get_center().x - largo_titolo(testo, 20) * 0.5, r.position.y + 27), testo, 20, CARTA)
