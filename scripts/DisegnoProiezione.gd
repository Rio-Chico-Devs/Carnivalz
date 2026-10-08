class_name DisegnoProiezione
extends RefCounted

# QUELLO CHE STA SOPRA LA GRIGLIA della proiezione (Proiezione.gd): la
# cornice e il righello, il titolo spaziato, i segnali dei Carnivalz in
# corso, le etichette a didascalia, il mirino,
# la frattura nuova che si strappa. La colonna delle
# schede a destra e' SchedaProiezione.
#
# IL CARATTERE E LE FORME SONO QUELLI DEL MANIFESTO, come nel resto del gioco.
# Bru: «piu' che ingrandire le scritte uniformare i font alla grafica generale
# del gioco». Prima c'era il carattere dei dialoghi (Bricolage) stretto e
# leggerissimo, maiuscolo e spaziato come le scritte piccole di un poster:
# l'unico posto del gioco che scriveva cosi'. Fra quattro proposte (vetro,
# Archivo, manifesto, Archivo coi racconti del box) Bru ha scelto la terza:
# Archivo corsivo, il carattere delle etichette, e il titolo, i nomi dei corpi,
# le linguette della scheda e i bottoni sulle etichette del manifesto.

# l'intestazione comincia dopo l'iconcina del menu (IconaMenu), che sta
# nell'angolo in alto a sinistra in ogni schermata
const INIZIO_INTESTAZIONE := 148.0
# quanto sale una didascalia sopra il suo corpo, nell'ordine in cui si prova
# (sotto zero: scende sotto il corpo). Con quattro pianeti in orbita sette non
# bastavano: girando, prima o poi chiudevano ogni posto intorno a una frattura
const GRADINI: Array[float] = [16.0, 42.0, 68.0, 94.0, -40.0, -66.0, 120.0, -92.0, 146.0, -118.0, 172.0]
# dove una didascalia si puo' scrivere: fuori ci sono la colonna e l'intestazione
const CORNICE := Rect2(24, 64, SchedaProiezione.X - 30.0, 620)

static var fonti := {}


static func fonte(peso: float, largo: float, spazio: int) -> Font:
	# I NUMERI DEI DISEGNI DI PRIMA, LETTI PER ARCHIVO. Ogni scritta dice
	# ancora peso, larghezza e spaziatura come li diceva per Bricolage; qui
	# diventano Archivo, che a parita' di numeri e' piu' chiaro e piu' largo:
	# un gradino di peso in piu', e la spaziatura dimezzata (un corsivo
	# spaziato come un tondo si sfalda)
	var chiave := "%d_%d_%d" % [roundi(peso), roundi(largo), spazio]
	if not fonti.has(chiave):
		var v := FontVariation.new()
		var ts := TextServerManager.get_primary_interface()
		var base := Stile.font_da("titolo")
		if base != null:
			v.base_font = base
		v.variation_opentype = {ts.name_to_tag("wght"): clampf(peso + 250.0, 450.0, 900.0),
				ts.name_to_tag("wdth"): clampf(largo + 8.0, 62.0, 125.0)}
		v.spacing_glyph = roundi(spazio * 0.5)
		fonti[chiave] = v
	return fonti[chiave]


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


static func vesti(b: Button) -> void:
	# i bottoni di servizio (Torna alla Sede, Mappa stellare): l'uscita di ogni
	# altra schermata, l'etichetta nera del manifesto
	Stile.ritorno(b)


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
	# il nome grande in basso a sinistra, che si scrive lettera per lettera
	# quando si apre il livello. Sta su un'etichetta, come il nome di una zona:
	# arancio, perche' sul vetro scuro un'etichetta nera non si vedrebbe
	var lettere := roundi(float(p.titolo_grande.length()) * liscio(p.t_livello * 0.8))
	if Movimento.ridotto():
		lettere = p.titolo_grande.length()
	scrivi(tela, Vector2(38, 626), p.sopratitolo, 11, Stile.colore("manifesto"), 400, 85, 3)
	if lettere > 0:
		Manifesto.etichetta_tinta(tela, Vector2(30, 636), p.titolo_grande.substr(0, lettere), 34,
				Stile.colore("manifesto"), Stile.colore("bordo"))


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
	# c'e' posto prima della colonna, se no a sinistra; due non si coprono mai.
	# E NON COPRONO I CORPI: da quando le fratture stanno ferme, un nome finito
	# sopra l'anomalia ci restava per sempre (i «Cunicoli» nel Vuoto Ardente)
	for d in didascalie(p):
		etichetta(p, tela, d)


static func didascalie(p: Proiezione) -> Array[Dictionary]:
	# DOVE VA OGNI DIDASCALIA, decisa prima di disegnare: e' quello che si vede,
	# e la prova guarda qui che non copra niente
	var occupati: Array[Rect2] = []
	for c in p.corpi:
		if float(c["apertura"]) >= 0.6:
			occupati.append(ingombro_del_corpo(p, c))
	var tutte: Array[Dictionary] = []
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
		if compare <= 0.0 or not CORNICE.has_point(s):
			continue
		var r := p.raggio_sullo_schermo(c)
		# la didascalia e' larga quanto la sua riga piu' lunga: il nome o lo stato
		var lungo := maxf(larghezza(String(c["nome"]).to_upper(), 12, 500, 85, 2),
				larghezza(parola_di_stato(String(c["stato"])), 10, 420, 85, 2) + 13.0)
		var posto := posto_libero(s, r, lungo, occupati, ingombro_del_corpo(p, c))
		tutte.append({"corpo": c, "s": s, "r": r, "compare": compare, "lungo": lungo, "posto": posto,
				"spazio": spazio_della_didascalia(s, r, lungo, posto.x, posto.y)})
	return tutte


static func etichetta(p: Proiezione, tela: Control, d: Dictionary) -> void:
	var c: Dictionary = d["corpo"]
	var s: Vector2 = d["s"]
	var r: float = d["r"]
	var compare: float = d["compare"]
	var lungo: float = d["lungo"]
	var stato := String(c["stato"])
	var tinta := Color(p.tinte["inchiostro"] if stato in ["spento", "visto"] else p.tinte["carta"], compare)
	var nome := String(c["nome"]).to_upper()
	var verso: float = d["posto"].x
	var su: float = d["posto"].y
	var a := s + Vector2((r * 0.72 + 3.0) * verso, -r * 0.72 - 3.0)
	var b := a + Vector2(16.0 * verso, -su)
	var fine := b + Vector2((lungo + 10.0) * verso, 0)
	var da := b + Vector2(4, 0) if verso > 0.0 else fine + Vector2(4, 0)
	# una lastrina scura sotto la scritta: sopra la griglia si legge sempre
	tela.draw_rect(Rect2(da + Vector2(-4, -19), Vector2(lungo + 8.0, 35)), Color(p.tinte["fondo"], 0.72 * compare))
	tela.draw_polyline(PackedVector2Array([a, b, fine]), Color(tinta, 0.8 * compare), 1.0)
	tela.draw_circle(a, 1.8, tinta)
	# il nome su un'etichetta piena del manifesto, chiara o spenta come il corpo
	Manifesto.etichetta_tinta(tela, da + Vector2(-4, -20), nome, 12, tinta, Color(p.tinte["fondo"], compare))
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


static func ingombro_del_corpo(p: Proiezione, c: Dictionary) -> Rect2:
	# quanto spazio prende un corpo a schermo: una frattura e' piu' larga del
	# suo punto, perche' la si disegna intorno
	var r := p.raggio_sullo_schermo(c) * (2.0 if String(c["forma"]) == "lente" else 1.1)
	return Rect2(p.sullo_schermo(c["pos"]) - Vector2(r, r), Vector2(r, r) * 2.0)


static func posto_libero(s: Vector2, r: float, lungo: float, occupati: Array[Rect2], proprio := Rect2()) -> Vector2:
	# DOVE VA UNA DIDASCALIA: (verso, quanto sale). Prima dal lato dove c'e'
	# posto prima della colonna, salendo un gradino alla volta; se quel lato e'
	# pieno, l'altro lato, e poi anche sotto il corpo. Con i pianeti e i segreti
	# i corpi sono tanti, e un lato solo non bastava piu'. Se non c'e' un posto
	# libero si prende quello che copre meno superficie: un filo di un'altra
	# didascalia e' meglio di mezzo pianeta
	var posti := posti_da_provare(s, r, lungo)
	var meglio: Vector2 = posti[0]
	var meno := INF
	for posto: Vector2 in posti:
		var costo := costo_del_posto(spazio_della_didascalia(s, r, lungo, posto.x, posto.y), occupati, proprio)
		if costo < meno:
			meno = costo
			meglio = posto
		if meno <= 0.0:
			break
	occupati.append(spazio_della_didascalia(s, r, lungo, meglio.x, meglio.y))
	return meglio


static func costo_del_posto(spazio: Rect2, occupati: Array[Rect2], proprio: Rect2) -> float:
	# la superficie degli altri che finisce sotto la didascalia, e quella della
	# didascalia che esce dalla cornice (e andrebbe sotto la colonna o l'intestazione)
	var costo := (spazio.get_area() - CORNICE.intersection(spazio).get_area()) * 4.0
	for o in occupati:
		if o != proprio and o.intersects(spazio):
			costo += o.intersection(spazio).get_area()
	return costo


static func posti_da_provare(s: Vector2, r: float, lungo: float) -> Array[Vector2]:
	# i posti in ordine: tutti i gradini del lato buono, poi quelli dell'altro
	# lato se anche li' la didascalia sta prima della colonna e dentro la cornice
	var posti: Array[Vector2] = []
	for lato in lati_liberi(s.x, r + 30.0 + lungo):
		for su in GRADINI:
			posti.append(Vector2(lato, su))
	return posti


static func lati_liberi(x: float, largo: float) -> Array[float]:
	# a destra se la didascalia finisce prima della colonna; a sinistra se ci
	# sta, o se a destra non c'e' posto (meglio tagliata che sotto la colonna)
	var a_destra := x + largo < SchedaProiezione.X - 12.0
	var lati: Array[float] = []
	if a_destra:
		lati.append(1.0)
	if x - largo > 24.0 or not a_destra:
		lati.append(-1.0)
	return lati


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
