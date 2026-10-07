class_name DisegnoProiezione
extends RefCounted

# QUELLO CHE STA SOPRA LA GRIGLIA della proiezione (Proiezione.gd): la
# cornice e il righello, il titolo spaziato, i segnali dei Carnivalz in
# corso, le etichette a didascalia, il mirino,
# la frattura nuova che si strappa. La colonna delle
# schede a destra e' SchedaProiezione.
#
# Il carattere e' quello dei dialoghi (Bricolage) stretto e leggero, tutto
# maiuscolo e spaziato: le scritte piccole dei poster di Bru.

# l'intestazione comincia dopo l'iconcina del menu (IconaMenu), che sta
# nell'angolo in alto a sinistra in ogni schermata
const INIZIO_INTESTAZIONE := 148.0

static var fonti := {}

# CON CHE VOCE PARLA LA PROIEZIONE. Bru: «piu' che ingrandire le scritte
# uniformare i font alla grafica generale del gioco». Finche' non sceglie, le
# proposte stanno tutte qui (proiezione.voce in data/stile.json; per gli scatti
# VOCE_PROIEZIONE):
#   vetro      quella di prima: Bricolage stretto e leggero, maiuscolo spaziato
#   archivo    lo stesso disegno, col carattere delle etichette (Archivo corsivo)
#   manifesto  Archivo, e titolo, nomi e bottoni sulle etichette nere del manifesto
#   dialoghi   Archivo per le etichette, e i racconti col carattere del box
const VOCI := ["vetro", "archivo", "manifesto", "dialoghi"]
static var voce := ""


static func voce_scelta() -> String:
	if voce == "":
		voce = String((Stile.dati.get("proiezione", {}) as Dictionary).get("voce", "vetro"))
	return voce


static func fonte(peso: float, largo: float, spazio: int) -> Font:
	var chiave := "%s_%d_%d_%d" % [voce_scelta(), roundi(peso), roundi(largo), spazio]
	if not fonti.has(chiave):
		var v := FontVariation.new()
		var ts := TextServerManager.get_primary_interface()
		var vetro := voce_scelta() == "vetro"
		var base := Stile.font_da("dialoghi" if vetro else "titolo")
		if base != null:
			v.base_font = base
		if vetro:
			v.variation_opentype = {ts.name_to_tag("wght"): peso, ts.name_to_tag("wdth"): largo,
					ts.name_to_tag("opsz"): 14.0}
			v.spacing_glyph = spazio
		else:
			# Archivo e' piu' chiaro e piu' largo a parita' di numeri: un gradino
			# di peso in piu', e la spaziatura dimezzata (un corsivo spaziato
			# come un tondo si sfalda)
			v.variation_opentype = {ts.name_to_tag("wght"): clampf(peso + 250.0, 450.0, 900.0),
					ts.name_to_tag("wdth"): clampf(largo + 8.0, 62.0, 125.0)}
			v.spacing_glyph = roundi(spazio * 0.5)
		fonti[chiave] = v
	return fonti[chiave]


static func sul_manifesto() -> bool:
	return voce_scelta() == "manifesto"


static func scrivi(tela: Control, dove: Vector2, testo: String, corpo: int, tinta: Color, peso := 300.0,
		largo := 80.0, spazio := 2) -> void:
	tela.draw_string(fonte(peso, largo, spazio), dove, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, tinta)


static func larghezza(testo: String, corpo: int, peso := 300.0, largo := 80.0, spazio := 2) -> float:
	return fonte(peso, largo, spazio).get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x


static func elastico(x: float) -> float:
	# arriva, supera di un soffio e torna: la frattura che si apre
	if x <= 0.0:
		return 0.0
	if x >= 1.0:
		return 1.0
	var c1 := 1.70158
	return 1.0 + (c1 + 1.0) * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0)


static func liscio(x: float) -> float:
	var k := clampf(x, 0.0, 1.0)
	return k * k * (3.0 - 2.0 * k)


static func trasparente(b: Button) -> void:
	# un Button che si preme ma non si vede: lo disegna la proiezione
	for stato in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		b.add_theme_stylebox_override(stato, StyleBoxEmpty.new())
	b.focus_mode = Control.FOCUS_ALL
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


static func vesti(b: Button, tinte: Dictionary) -> void:
	# i bottoni di servizio (Torna alla Sede, Mappa stellare): una scatola al
	# tratto come quelle della colonna. Sul manifesto, l'uscita di ogni altra
	# schermata: l'etichetta nera (Stile.ritorno)
	if sul_manifesto():
		Stile.ritorno(b)
		return
	for stato in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
		var s := StyleBoxFlat.new()
		s.bg_color = Color(tinte["fondo"], 0.88) if stato in ["normal", "focus"] else Color(tinte["carta"], 0.92)
		s.border_color = tinte["carta"] if stato != "normal" else tinte["inchiostro"]
		s.set_border_width_all(2 if stato == "focus" else 1)
		s.set_content_margin_all(8)
		b.add_theme_stylebox_override(stato, s)
	b.text = b.text.to_upper()
	b.add_theme_font_override("font", fonte(500, 80, 3))
	b.add_theme_font_size_override("font_size", 12)
	for chiave in ["font_color", "font_focus_color"]:
		b.add_theme_color_override(chiave, tinte["carta"])
	for chiave in ["font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(chiave, tinte["fondo"])


static func disegna(p: Proiezione, tela: Control) -> void:
	if not p.pronta:
		return
	cornice(p, tela)
	segnali(p, tela)
	etichette(p, tela)
	mirino(p, tela)
	crepa(p, tela)
	SchedaProiezione.disegna(p, tela)
	titolo(p, tela)
	if p.lampo > 0.0:
		tela.draw_rect(Rect2(Vector2.ZERO, tela.size), Color(p.tinte["carta"], p.lampo * 0.55))


static func cornice(p: Proiezione, tela: Control) -> void:
	var carta: Color = p.tinte["carta"]
	var inchiostro: Color = p.tinte["inchiostro"]
	tela.draw_rect(Rect2(18, 18, 1244, 684), Color(inchiostro, 0.7), false, 1.0)
	for angolo: Vector2 in [Vector2(18, 18), Vector2(1262, 18), Vector2(18, 702), Vector2(1262, 702)]:
		var sx := 1.0 if angolo.x < 640.0 else -1.0
		var sy := 1.0 if angolo.y < 360.0 else -1.0
		tela.draw_polyline(PackedVector2Array([angolo + Vector2(0, 14 * sy), angolo, angolo + Vector2(14 * sx, 0)]),
				carta, 2.0)
	# l'intestazione parte dopo l'iconcina del menu (IconaMenu), che sta nell'angolo
	scrivi(tela, Vector2(INIZIO_INTESTAZIONE, 44), p.intestazione, 11, Color(carta, 0.85), 350, 85, 3)
	# il righello sotto l'intestazione, come nei diagrammi del poster
	tela.draw_line(Vector2(INIZIO_INTESTAZIONE, 54), Vector2(940, 54), Color(inchiostro, 0.8), 1.0)
	for i in 41:
		var x := INIZIO_INTESTAZIONE + float(i) * 19.65
		tela.draw_line(Vector2(x, 54), Vector2(x, 58 if i % 5 else 62), Color(inchiostro, 0.8), 1.0)
	scrivi(tela, Vector2(972, 44), "SCANSIONE", 11, Color(carta, 0.85), 350, 85, 3)
	if fmod(p.t, 1.2) < 0.7 or Movimento.ridotto():
		tela.draw_circle(Vector2(1062, 40), 3.5, p.tinte["segnale"])
	var w := larghezza(p.nota_destra, 11, 350, 85, 3)
	scrivi(tela, Vector2(1244 - w, 44), p.nota_destra, 11, Color(carta, 0.85), 350, 85, 3)


static func titolo(p: Proiezione, tela: Control) -> void:
	# il nome grande in basso a sinistra, spaziato come INTERSTELLAR, che si
	# scrive lettera per lettera quando si apre il livello
	var lettere := roundi(float(p.titolo_grande.length()) * liscio(p.t_livello * 0.8))
	if Movimento.ridotto():
		lettere = p.titolo_grande.length()
	if sul_manifesto():
		# il nome del settore su un'etichetta, come il nome di una zona: arancio,
		# perche' sul vetro scuro un'etichetta nera non si vedrebbe
		scrivi(tela, Vector2(38, 626), p.sopratitolo, 11, Stile.colore("manifesto"), 400, 85, 3)
		if lettere > 0:
			Manifesto.etichetta_tinta(tela, Vector2(30, 636), p.titolo_grande.substr(0, lettere), 34,
					Stile.colore("manifesto"), Stile.colore("bordo"))
		return
	scrivi(tela, Vector2(38, 640), p.sopratitolo, 11, p.tinte["inchiostro"], 400, 85, 3)
	scrivi(tela, Vector2(34, 684), p.titolo_grande.substr(0, lettere), 42, p.tinte["carta"], 220, 75, 16)


static func segnali(p: Proiezione, tela: Control) -> void:
	# UN CARNIVALZ IN CORSO chiama: anelli che si allargano sulla griglia, e il «!»
	for c in p.corpi:
		if not bool(c["segnale"]):
			continue
		var pos: Vector3 = c["pos"]
		# gli anelli chiamano solo dove non sei ancora stato; il «!» resta
		for k in (3 if bool(c.get("chiama", true)) else 0):
			var fase := 0.5 if Movimento.ridotto() else fmod(p.t * 0.6 + float(k) / 3.0, 1.0)
			# il pezzo di anello che passa dietro il pianeta non si vede
			for tratto in a_tratti(p, giro_del_segnale(c, fase)):
				tela.draw_polyline(tratto, Color(p.tinte["segnale"], (1.0 - fase) * 0.8), 1.5, true)
		var s := p.sullo_schermo(pos)
		var su := s + Vector2(0, -p.raggio_sullo_schermo(c) - 30)
		# il «!» salta fuori con lo stesso elastico delle fratture che si aprono
		var k := elastico(float(c["apertura"]))
		var rombo := PackedVector2Array([su + Vector2(0, -12) * k, su + Vector2(10, 0) * k, su + Vector2(0, 12) * k,
				su + Vector2(-10, 0) * k])
		tela.draw_colored_polygon(rombo, p.tinte["segnale"])
		scrivi(tela, su + Vector2(-2.5, 6), "!", 16, p.tinte["fondo"], 800, 100, 0)
		tela.draw_line(su + Vector2(0, 12), s + Vector2(0, -p.raggio_sullo_schermo(c) - 2),
				Color(p.tinte["segnale"], 0.8), 1.0)


static func giro_del_segnale(c: Dictionary, fase: float) -> Array[Vector3]:
	# un anello del segnale, sulla griglia sotto il corpo: piu' la fase avanza piu' e' largo
	var pos: Vector3 = c["pos"]
	var punti: Array[Vector3] = []
	for i in 41:
		var a := TAU * float(i) / 40.0
		var punto := pos + Vector3(cos(a), 0, sin(a)) * (0.8 + fase * 3.4)
		punto.y = pos.y - float(c["raggio"]) * 0.6
		punti.append(punto)
	return punti


static func a_tratti(p: Proiezione, punti: Array[Vector3]) -> Array[PackedVector2Array]:
	# UNA LINEA CHE GIRA INTORNO A UN PIANETA, sullo schermo. Bru: «vanno sopra
	# il pianeta e sembra brutto». Quello che sta sopra la griglia non ha la
	# profondita' del 3D, quindi la si fa a mano: i pezzi dietro una sfera non
	# si disegnano, e il taglio cade sul bordo vero della sfera
	var tratti: Array[PackedVector2Array] = []
	var tratto := PackedVector2Array()
	var prima_coperto := false
	for i in punti.size():
		var coperto := p.coperto(punti[i])
		if i > 0 and coperto != prima_coperto:
			tratto.append(p.sullo_schermo(bordo_della_sfera(p, punti[i - 1], punti[i], prima_coperto)))
			if coperto:
				tratti.append(tratto)
				tratto = PackedVector2Array()
		if not coperto:
			tratto.append(p.sullo_schermo(punti[i]))
		prima_coperto = coperto
	tratti.append(tratto)
	return tratti.filter(func(t: PackedVector2Array) -> bool: return t.size() >= 2)


static func bordo_della_sfera(p: Proiezione, da: Vector3, a: Vector3, da_coperto: bool) -> Vector3:
	# fra un punto coperto e uno no c'e' il bordo: lo si trova dimezzando
	var qui := da
	var li := a
	for n in 10:
		var mezzo := qui.lerp(li, 0.5)
		if p.coperto(mezzo) == da_coperto:
			qui = mezzo
		else:
			li = mezzo
	return qui.lerp(li, 0.5)


static func parola_di_stato(stato: String) -> String:
	match stato:
		"nuovo": return "NON CI SEI ANCORA STATO"
		"chiuso": return "CHIUSA"
		"visto": return "VISITATA"
		"sigillato": return "SIGILLATA"
		"aperto": return "APERTA"
		"spento": return "NESSUN SEGNALE"
		"trovato": return "TROVATO"
		"preso": return "PRESO"
	return stato.to_upper()


static func etichette(p: Proiezione, tela: Control) -> void:
	# didascalie col filo, come nei diagrammi del poster: a destra del corpo se
	# c'e' posto prima della colonna, se no a sinistra; due non si coprono mai
	var occupati: Array[Rect2] = []
	var indice := 0
	for c in p.corpi:
		indice += 1
		var compare := liscio((p.t_livello - 0.9 - float(indice) * 0.18) * 3.0) \
				* liscio((float(c["apertura"]) - 0.6) * 2.5)
		if Movimento.ridotto():
			compare = 1.0 if float(c["apertura"]) >= 0.6 else 0.0
		var s := p.sullo_schermo(c["pos"])
		# girando o avvicinando la mappa un corpo puo' finire dietro la colonna, o
		# fuori dalla cornice: li' niente didascalia
		if compare <= 0.0 or not Rect2(24, 64, SchedaProiezione.X - 30.0, 620).has_point(s):
			continue
		etichetta(p, tela, c, s, compare, occupati)


static func etichetta(p: Proiezione, tela: Control, c: Dictionary, s: Vector2, compare: float,
		occupati: Array[Rect2]) -> void:
	var r := p.raggio_sullo_schermo(c)
	var stato := String(c["stato"])
	var tinta := Color(p.tinte["inchiostro"] if stato in ["spento", "visto"] else p.tinte["carta"], compare)
	var nome := String(c["nome"]).to_upper()
	# la didascalia e' larga quanto la sua riga piu' lunga: il nome o lo stato
	var lungo := maxf(larghezza(nome, 12, 500, 85, 2), larghezza(parola_di_stato(stato), 10, 420, 85, 2) + 13.0)
	var posto := posto_libero(s, r, lungo, occupati)
	var verso := posto.x
	var su := posto.y
	var a := s + Vector2((r * 0.72 + 3.0) * verso, -r * 0.72 - 3.0)
	var b := a + Vector2(16.0 * verso, -su)
	var fine := b + Vector2((lungo + 10.0) * verso, 0)
	var da := b + Vector2(4, 0) if verso > 0.0 else fine + Vector2(4, 0)
	# una lastrina scura sotto la scritta: sopra la griglia si legge sempre
	tela.draw_rect(Rect2(da + Vector2(-4, -19), Vector2(lungo + 8.0, 35)), Color(p.tinte["fondo"], 0.72 * compare))
	tela.draw_polyline(PackedVector2Array([a, b, fine]), Color(tinta, 0.8 * compare), 1.0)
	tela.draw_circle(a, 1.8, tinta)
	if sul_manifesto():
		# il nome su un'etichetta piena, del colore che aveva la scritta
		Manifesto.etichetta_tinta(tela, da + Vector2(-4, -20), nome, 12, tinta, Color(p.tinte["fondo"], compare))
	else:
		scrivi(tela, da + Vector2(0, -5), nome, 12, tinta, 500, 85, 2)
	var riga := da + Vector2(0, 12)
	if stato == "nuovo":
		var batte := 1.0 if Movimento.ridotto() else 0.55 + 0.45 * sin(p.t * 5.0)
		tela.draw_circle(riga + Vector2(3, -4), 3.0, Color(p.tinte["segnale"], batte * compare))
		riga.x += 10.0
	elif stato == "chiuso":
		tela.draw_polyline(PackedVector2Array([riga + Vector2(0, -4), riga + Vector2(3, -1), riga + Vector2(9, -8)]),
				Color(p.tinte["carta"], compare), 1.5)
		riga.x += 13.0
	scrivi(tela, riga, parola_di_stato(stato), 10, Color(p.tinte["inchiostro"], compare), 420, 85, 2)


static func spazio_della_didascalia(s: Vector2, r: float, lungo: float, verso: float, su: float) -> Rect2:
	var b := s + Vector2((r * 0.72 + 19.0) * verso, -r * 0.72 - 3.0 - su)
	return Rect2(b.x if verso > 0.0 else b.x - lungo - 14.0, b.y - 16.0, lungo + 14.0, 32.0)


static func posto_libero(s: Vector2, r: float, lungo: float, occupati: Array[Rect2]) -> Vector2:
	# DOVE VA UNA DIDASCALIA: (verso, quanto sale). Prima dal lato dove c'e'
	# posto prima della colonna, salendo un gradino alla volta; se quel lato e'
	# pieno, l'altro lato. Con i pianeti e i segreti i corpi sono tanti, e
	# un lato solo non bastava piu'
	var a_destra := s.x + r + 30.0 + lungo < SchedaProiezione.X - 12.0
	var a_sinistra := s.x - r - 30.0 - lungo > 24.0
	var verso := 1.0 if a_destra else -1.0
	for lato: float in [verso, -verso]:
		if (lato > 0.0 and not a_destra) or (lato != verso and not a_sinistra):
			continue
		for gradino in 4:
			var su := 16.0 + 26.0 * float(gradino)
			var spazio := spazio_della_didascalia(s, r, lungo, lato, su)
			if not occupati.any(func(o: Rect2) -> bool: return o.intersects(spazio)):
				occupati.append(spazio)
				return Vector2(lato, su)
	return Vector2(verso, 120.0)


static func mirino(p: Proiezione, tela: Control) -> void:
	var carta: Color = p.tinte["carta"]
	var scelto := p.corpo(p.scelto)
	if not scelto.is_empty():
		var dove := p.sullo_schermo(scelto["pos"])
		var giro := p.raggio_sullo_schermo(scelto)
		tela.draw_arc(dove, giro + 10.0, 0, TAU, 48, Color(carta, 0.9), 1.0, true)
		tela.draw_arc(dove, giro + 14.0, 0, TAU, 48, Color(p.tinte["inchiostro"], 0.9), 1.0, true)
	var sotto := p.corpo(p.sotto)
	if sotto.is_empty() or p.sotto == p.scelto:
		return
	# il mirino si stringe sul corpo puntato, e gli gira intorno un anello a tratti
	var s := p.sullo_schermo(sotto["pos"])
	var r := p.raggio_sullo_schermo(sotto)
	var stringe := 0.0 if Movimento.ridotto() else 1.0 - liscio(p.da_quando_sotto * 4.0)
	var lato := r + 10.0 + 22.0 * stringe
	for k in 4:
		var dir := Vector2(1 if k % 2 == 0 else -1, 1 if k < 2 else -1)
		var angolo := s + dir * lato
		tela.draw_polyline(PackedVector2Array([angolo - Vector2(dir.x * 9, 0), angolo, angolo - Vector2(0, dir.y * 9)]),
				carta, 1.5)
	for k in 8:
		var a0 := (0.0 if Movimento.ridotto() else p.t * 0.8) + TAU * float(k) / 8.0
		tela.draw_arc(s, r + 5.0, a0, a0 + 0.42, 6, Color(carta, 0.7), 1.0, true)


static func crepa(p: Proiezione, tela: Control) -> void:
	# la frattura nuova: raggi che si aprono dal suo mondo, e l'avviso
	if p.crepa_dove == "" or p.nuova_t < 0.0:
		return
	var c := p.corpo(p.crepa_dove)
	if c.is_empty():
		return
	var dt := p.t - p.nuova_t
	var s := p.sullo_schermo(c["pos"])
	if dt < 1.0 and not Movimento.ridotto():
		var d := RandomNumberGenerator.new()
		d.seed = 77
		for raggio in 7:
			var a := d.randf() * TAU
			var punti := PackedVector2Array([s])
			var lungo := (30.0 + d.randf() * 50.0) * liscio(dt * 3.0)
			var punto := s
			for k in 5:
				a += d.randf_range(-0.5, 0.5)
				punto += Vector2.RIGHT.rotated(a) * lungo / 5.0
				punti.append(punto)
			tela.draw_polyline(punti, Color(p.tinte["carta"], 1.0 - dt), 1.4)
	# l'avviso non lampeggia: entra, resta qualche secondo col suo puntino che
	# batte, e se ne va. Sta sotto a sinistra: sopra c'e' la didascalia
	var presenza := liscio(dt * 3.0) * (1.0 - liscio((dt - 4.4) / 0.8))
	if presenza <= 0.0:
		return
	var r := p.raggio_sullo_schermo(c)
	var tag := s + Vector2(-r - 136.0, r + 14.0)
	var segnale: Color = p.tinte["segnale"]
	tela.draw_line(s + Vector2(-r, r) * 0.7, tag + Vector2(124, 9), Color(segnale, presenza), 1.0)
	tela.draw_rect(Rect2(tag, Vector2(124, 20)), Color(segnale, presenza))
	var batte := 1.0 if Movimento.ridotto() else 0.6 + 0.4 * sin(dt * 6.0)
	tela.draw_circle(tag + Vector2(10, 10), 3.0, Color(p.tinte["fondo"], presenza * batte))
	scrivi(tela, tag + Vector2(20, 14), "NUOVA FRATTURA", 10, Color(p.tinte["fondo"], presenza), 650, 85, 2)
