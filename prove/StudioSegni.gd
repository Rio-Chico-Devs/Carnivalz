extends RefCounted

# LE TAVOLE DI STUDIO DEI SEGNI, provvisorie come le proposte della crescita
# (prove/ProposteCrescita.gd, foto «studio_occhio», «studio_pieno»,
# «studio_astrazione»).
#
# Bru: «dobbiamo studiare di più, ci vogliono più riferimenti grafici e proprio
# cose che ti facciano capire concetti di pulizia del logo, astrazione,
# simbologia e design». Poi ha mandato le letture:
# - Ian Paget (Logo Geek), le correzioni ottiche;
# - Fábio Duarte Martins (Scannerlicker), la sporgenza;
# - l'intervista a Sagi Haviv;
# - Logobook;
# - i 50 simboli AIGA/DOT.
# Queste tavole sono gli esercizi fatti sopra quelle letture, con le nostre
# forme. Cosa dicono le letture e le misure sono in docs/simboli.md.

const P := preload("res://prove/PezziCrescita.gd")
const S := preload("res://prove/SimboliCrescita.gd")

# l'inchiostro dei nove motivi senza anello, nero su bianco, sul quadrato del
# motivo: misurato col banco prima e dopo la pulizia (docs/simboli.md). Le
# frecce AIGA/DOT, misurate allo stesso modo, sono tutte a 0,30
const PESO_PRIMA := [0.38, 0.17, 0.39, 0.26, 0.21, 0.19, 0.17, 0.29, 0.24]
const PESO_DOPO := [0.30, 0.27, 0.31, 0.28, 0.28, 0.29, 0.27, 0.29, 0.27]
const NOMI := ["Vita", "Attacco", "Difesa", "Velocità", "Intelligenza", "Forza m.", "Fattore", "Maestria", "Aura"]


static func fondo_tavola(t: CanvasItem, titolo: String, sotto: Array) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.06), Vector2(1.0, 1.0))
	var largo := P.etichetta(t, Vector2(28, 52), titolo, 36, P.CREMA, P.NERO, P.ARANCIO)
	for i in sotto.size():
		P.scritta(t, Vector2(maxf(372.0, 52.0 + largo), 80 + 20 * i), String(sotto[i]), 15, P.CARTA, Caratteri.tondo(700))


static func foglio(t: CanvasItem, r: Rect2, titolo: String, fonte: String) -> void:
	# il cartoncino chiaro dell'esercizio, col titolo e da dove viene
	P.cartoncino(t, r, P.CARTA, 0.0, P.OMBRA, true)
	P.scritta(t, r.position + Vector2(18, 30), titolo, 18, P.NERO)
	P.scritta(t, r.position + Vector2(18, 48), fonte, 12, P.TRATTO, Caratteri.tondo(800))


static func didascalia(t: CanvasItem, dove: Vector2, testo: String, largo := 160.0, tinta := P.NERO) -> void:
	P.a_capo(t, Rect2(dove, Vector2(largo, 40)), testo, 12, tinta, Caratteri.tondo(800), HORIZONTAL_ALIGNMENT_CENTER, 3)


# --- 1. l'occhio prima della griglia ----------------------------------------------------------

static func occhio(t: CanvasItem) -> void:
	fondo_tavola(t, "L'OCCHIO", ["Le correzioni ottiche: la griglia e' una guida, non una regola. Si corregge a occhio,",
			"e poi si controlla con le misure. Quattro esercizi, l'ultimo su ognuno dei nostri mon."])
	sporgenza(t, Rect2(28, 132, 600, 278))
	irraggiamento(t, Rect2(652, 132, 600, 278))
	peso(t, Rect2(28, 432, 600, 268))
	una_tinta(t, Rect2(652, 432, 600, 268))


static func guida(t: CanvasItem, y: float, da: float, a: float) -> void:
	t.draw_line(Vector2(da, y), Vector2(a, y), Color(P.ARANCIO, 0.9), 1.0)


static func sporgenza(t: CanvasItem, r: Rect2) -> void:
	# quadrato, cerchio e triangolo: alti uguali sembrano diversi; corretti a
	# occhio sembrano uguali. Il cerchio sporge sopra e sotto, il triangolo
	# poggia sulla riga e sporge con la punta
	foglio(t, r, "LA SPORGENZA", "Scannerlicker, «The Art of Eyeballing III»")
	var o := r.position
	var lato := 64.0
	for riga in 2:
		var y := o.y + 92.0 + riga * 106.0
		var su := y
		var giu := y + lato
		guida(t, su, o.x + 18, o.x + 300)
		guida(t, giu, o.x + 18, o.x + 300)
		t.draw_rect(Rect2(o.x + 30, su, lato, lato), P.NERO)
		var sporge := 0.0 if riga == 0 else 3.5
		t.draw_circle(Vector2(o.x + 150, su + lato * 0.5), lato * 0.5 + sporge, P.NERO, true, -1.0, true)
		var punta := 0.0 if riga == 0 else 9.0
		var base := lato * 0.58 + (0.0 if riga == 0 else 4.0)
		Manifesto.poligono(t, PackedVector2Array([Vector2(o.x + 252, su - punta), Vector2(o.x + 252 + base, giu),
				Vector2(o.x + 252 - base, giu)]), P.NERO)
		P.scritta(t, Vector2(o.x + 18, su - 8), "uguali per il righello" if riga == 0 else "uguali per l'occhio", 12,
				P.TRATTO, Caratteri.tondo(900))
	# nei mon: le parti piatte al raggio 9, le punte fino a 9,4
	var c := o + Vector2(462, 142)
	var l := 150.0
	var k := l / 24.0
	S.mon(t, "difesa", c, l, P.NERO, P.CARTA)
	t.draw_arc(c, 9.0 * k, 0.0, TAU, 96, P.ARANCIO, 1.5, true)
	t.draw_arc(c, 9.4 * k, 0.0, TAU, 96, Color(P.ARANCIO, 0.6), 1.0, true)
	didascalia(t, o + Vector2(342, 226), "nei mon le parti piatte arrivano al raggio 9, le punte fino a 9,4", 240)


static func irraggiamento(t: CanvasItem, r: Rect2) -> void:
	# lo stesso mon nero su carta, chiaro su nero com'e', e chiaro su nero
	# corretto: piu' sottile nelle linee, piu' largo nei tagli
	foglio(t, r, "L'IRRAGGIAMENTO", "Logo Geek, «Optical corrections every logo designer should know about»")
	var o := r.position
	var l := 124.0
	var centri := [o + Vector2(104, 150), o + Vector2(300, 150), o + Vector2(496, 150)]
	S.mon(t, "forza_mentale", centri[0], l, P.NERO, P.CARTA)
	for i in [1, 2]:
		var q := Rect2(centri[i] - Vector2(80, 80), Vector2(160, 160))
		t.draw_rect(q, P.NERO)
		S.correggi = i == 2
		S.mon(t, "forza_mentale", centri[i], l, P.CREMA, P.NERO, P.ARANCIO)
		S.correggi = true
	didascalia(t, o + Vector2(14, 236), "nero su carta: lo spessore W", 180)
	didascalia(t, o + Vector2(210, 236), "chiaro su nero, uguale: sembra piu' grasso", 180)
	didascalia(t, o + Vector2(406, 236), "chiaro su nero, corretto: linee ×0,88, tagli ×1,18", 180)


static func peso(t: CanvasItem, r: Rect2) -> void:
	# l'inchiostro dei nove motivi, prima e dopo: la fascia fra 0,27 e 0,33
	foglio(t, r, "IL PESO", "misurato: l'inchiostro sul quadrato del motivo, nero su bianco")
	var o := r.position
	var basso := o.y + 214.0
	var alto := 260.0   # pixel per 1,0 di inchiostro
	var fascia := Rect2(o.x + 18, basso - 0.33 * alto, r.size.x - 36, 0.06 * alto)
	t.draw_rect(fascia, Color(P.ARANCIO, 0.25))
	t.draw_line(Vector2(o.x + 18, basso - 0.30 * alto), Vector2(o.x + r.size.x - 18, basso - 0.30 * alto), P.ARANCIO, 1.5)
	P.scritta(t, Vector2(o.x + r.size.x - 230, basso - 0.30 * alto - 26), "le frecce AIGA/DOT: 0,30 tutte", 12,
			P.ARANCIO_SCURO, Caratteri.tondo(900))
	for i in S.STATISTICHE.size():
		var x := o.x + 52.0 + 61.0 * i
		var prima: float = PESO_PRIMA[i]
		var dopo: float = PESO_DOPO[i]
		t.draw_rect(Rect2(x - 16, basso - prima * alto, 14, prima * alto), Color(P.TRATTO, 0.55))
		t.draw_rect(Rect2(x + 2, basso - dopo * alto, 14, dopo * alto), P.NERO)
		S.mon(t, String(S.STATISTICHE[i]), Vector2(x, basso + 26), 30.0, P.NERO, P.CARTA, Color(0, 0, 0, 0), false)
	t.draw_line(Vector2(o.x + 18, basso), Vector2(o.x + r.size.x - 18, basso), P.NERO, 1.5)
	P.scritta(t, Vector2(o.x + 18, o.y + 74), "grigio prima: da 0,17 a 0,39", 12, P.TRATTO, Caratteri.tondo(900))
	P.scritta(t, Vector2(o.x + 220, o.y + 74), "nero dopo: da 0,27 a 0,31", 12, P.NERO, Caratteri.tondo(900))


static func una_tinta(t: CanvasItem, r: Rect2) -> void:
	# il cuore come buco (prima) e il cuore pieno nel suo taglio (dopo)
	foglio(t, r, "UNA TINTA", "Logobook: i marchi migliori stanno bene in bianco e nero")
	var o := r.position
	var quali := ["intelligenza", "forza_mentale", "attacco", "hp"]
	var frasi := ["PRIMA il cuore era un buco: nel vuoto spariva (l'occhio senza pupilla), sulla lama la spezzava",
			"DOPO il cuore resta pieno, staccato dal suo taglio: si vede sempre"]
	for riga in 2:
		var y := o.y + 72.0 + riga * 96.0
		P.scritta(t, Vector2(o.x + 18, y + 4), String(frasi[riga]), 12, P.NERO, Caratteri.tondo(800))
		for i in quali.size():
			var c := Vector2(o.x + 110.0 + 128.0 * i, y + 48)
			S.mon(t, String(quali[i]), c, 68.0, P.NERO, P.CARTA)
			if riga == 0:
				# il cuore che era un buco: sparito nel vuoto, o un buco che spezza
				S.rombo(t, c, 68.0, 12, 12, S.CUORE + S.INCASTRO, P.CARTA)


# --- 2. pieno e vuoto ------------------------------------------------------------------------

static func pieno_mon(t: CanvasItem, chiave: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		accento := Color(0, 0, 0, 0)) -> void:
	# il disco pieno col motivo tagliato in negativo: come i marchi di Logobook,
	# una massa sola e i tagli che portano l'idea
	t.draw_circle(c, 12.0 * l / 24.0, tinta, true, -1.0, true)
	S.ottica(tinta, fondo)
	S.sagoma(t, chiave, c, l * 1.06, fondo, tinta, accento)
	S.linea_ora = S.W
	S.taglio_ora = S.TAGLIO


static func pieno(t: CanvasItem) -> void:
	fondo_tavola(t, "PIENO E VUOTO", ["Logobook: una massa e pochi tagli decisivi, e il vuoto disegna quanto il pieno.",
			"Haviv: «non conta cosa piace, conta cosa funziona». Tre trattamenti dello stesso mon, da scegliere."])
	var righe := [["IL TRATTO", "com'e' ora: l'anello e il motivo, chiari sul nero"],
			["IL PIENO", "il disco pieno, il motivo tagliato in negativo"],
			["IL NUDO", "il motivo da solo, senza anello"]]
	for riga in 3:
		var y := 196.0 + riga * 150.0
		P.etichetta(t, Vector2(28, y - 66), String(righe[riga][0]), 14, P.ARANCIO, P.NERO)
		P.scritta(t, Vector2(28 + P.larghezza(String(righe[riga][0]), 14) + 34, y - 51), String(righe[riga][1]), 13, P.CARTA,
				Caratteri.tondo(800))
		for i in S.STATISTICHE.size():
			var chiave := String(S.STATISTICHE[i])
			var c := Vector2(72.0 + 92.0 * i, y)
			disegna_trattamento(t, riga, chiave, c, 74.0)
		# e piccoli, come nella scheda
		for j in 3:
			var chiave := String(["hp", "attacco", "fattore"][j])
			disegna_trattamento(t, riga, chiave, Vector2(946.0 + 40.0 * j, y - 14), 26.0)
			disegna_trattamento(t, riga, chiave, Vector2(946.0 + 40.0 * j, y + 22), 18.0)
	P.etichetta(t, Vector2(920, 130), "PICCOLI", 14, P.ARANCIO, P.NERO)
	P.a_capo(t, Rect2(1080, 150, 180, 400), "Il pieno e' la strada dei marchi: la massa grande regge le misure "
			+ "piccole e i timbri, e l'idea sta nel vuoto (il panda del WWF, Macel Pin, Frontier di Saul Bass). Il "
			+ "tratto e' la strada dei kamon: delicato, ma a 18 pixel l'anello si toglie. Il nudo e' quello che resta "
			+ "quando la cornice non serve.", 13, P.CARTA)
	P.a_capo(t, Rect2(28, 600, 1000, 60), "Haviv: «la presentazione e' tutto». Il marchio di A/X fu rifiutato su un foglio "
			+ "bianco e approvato nelle applicazioni. Per questo i mon si giudicano anche nella roulette, nella scheda e "
			+ "nel bivio, non solo nel catalogo.", 13, P.CARTA)


static func disegna_trattamento(t: CanvasItem, riga: int, chiave: String, c: Vector2, l: float) -> void:
	match riga:
		0:
			S.statistica(t, chiave, c, l, P.CREMA, P.NERO, P.ARANCIO)
		1:
			pieno_mon(t, chiave, c, l, P.CREMA, P.NERO, P.ARANCIO)
		2:
			S.statistica(t, chiave, c, l, P.CREMA, P.NERO, P.ARANCIO, Color(0, 0, 0, 0), false)


# --- 3. la scala dell'astrazione ---------------------------------------------------------------

static func astrazione(t: CanvasItem) -> void:
	fondo_tavola(t, "DAL DISEGNO AL SEGNO", ["McCloud: «amplificare semplificando». Kare: facile da capire e da ricordare.",
			"Haviv: ridurre all'essenza e' la cosa piu' difficile. Ogni passo toglie una cosa sola."])
	var passi := [["IL DISEGNO", "tutto: contorno, luci, ombre, dettagli"],
			["LA SAGOMA", "via i dettagli: si riconosce ancora"],
			["IL RIGHELLO", "via le curve: 0, 45 e 90 gradi"],
			["IL SEGNO", "dentro, il cuore dell'emblema: ora e' nostro"],
			["IL MON", "nell'anello, con gli altri: una famiglia"]]
	for i in passi.size():
		var x := 140.0 + 250.0 * i
		P.etichetta(t, Vector2(x - 76, 128), String(passi[i][0]), 14, P.ARANCIO, P.NERO)
		didascalia(t, Vector2(x - 95, 160), String(passi[i][1]), 190, P.CARTA)
		if i > 0:
			for y: float in [310.0, 540.0]:
				Manifesto.poligono(t, PackedVector2Array([Vector2(x - 133, y - 10), Vector2(x - 117, y), Vector2(x - 133, y + 10)]),
						Color(P.ARANCIO, 0.8))
	# il disegno e la sagoma sono immagini trovate: stanno sulla carta. Dal
	# righello in poi si entra nel nostro mondo, sul nero
	for i in 2:
		var x := 140.0 + 250.0 * i
		P.cartoncino(t, Rect2(x - 105, 212, 210, 428), P.CARTA, 0.0, Vector2(6, 6))
	for i in passi.size():
		var x := 140.0 + 250.0 * i
		gradino(t, "hp", i, Vector2(x, 310), 150.0)
		gradino(t, "attacco", i, Vector2(x, 540), 150.0)
	P.a_capo(t, Rect2(28, 664, 1220, 40), "Ogni passo toglie una cosa sola. Solo alla fine se ne aggiungono due nostre: "
			+ "il cuore dell'emblema e l'anello. Il disegno e la sagoma sono di tutti; dal righello in poi e' Carnivalz.", 13,
			P.CARTA)


static func gradino(t: CanvasItem, chiave: String, passo: int, c: Vector2, l: float) -> void:
	match passo:
		0:
			if chiave == "hp":
				cuore_disegnato(t, c, l, true)
			else:
				spada_disegnata(t, c, l * 1.1, true)
		1:
			if chiave == "hp":
				cuore_disegnato(t, c, l, false)
			else:
				spada_disegnata(t, c, l * 1.1, false)
		2:
			S.senza_tagli = true
			S.sagoma(t, chiave, c, l * 1.2, P.CREMA, P.NERO)
			S.senza_tagli = false
		3:
			S.mon(t, chiave, c, l, P.CREMA, P.NERO, Color(0, 0, 0, 0), false)
		4:
			S.statistica(t, chiave, c, l * 0.92, P.CREMA, P.NERO, P.ARANCIO, P.ARANCIO_SCURO)


static func cuore_disegnato(t: CanvasItem, c: Vector2, l: float, dettagli: bool) -> void:
	# il cuore classico, col compasso: due cerchi e il triangolo. Nel disegno ha
	# il contorno, la meta' destra in ombra e due luci; nella sagoma e' solo nero
	var r := l * 0.24
	var lobi := [c + Vector2(-l * 0.2, -l * 0.12), c + Vector2(l * 0.2, -l * 0.12)]
	var punta := c + Vector2(0, l * 0.4)
	var corpo := PackedVector2Array([c + Vector2(-l * 0.425, -l * 0.04), c + Vector2(l * 0.425, -l * 0.04), punta])
	if not dettagli:
		for q: Vector2 in lobi:
			t.draw_circle(q, r, P.NERO, true, -1.0, true)
		Manifesto.poligono(t, corpo, P.NERO)
		return
	for q: Vector2 in lobi:
		t.draw_circle(q, r + 4.0, P.NERO, true, -1.0, true)
	var fuori: PackedVector2Array = Geometry2D.offset_polygon(corpo, 4.0, Geometry2D.JOIN_MITER)[0]
	Manifesto.poligono(t, fuori, P.NERO)
	var chiaro := P.ARANCIO
	var scuro := P.ARANCIO_SCURO.darkened(0.15)
	t.draw_circle(lobi[0], r, chiaro, true, -1.0, true)
	t.draw_circle(lobi[1], r, scuro, true, -1.0, true)
	Manifesto.poligono(t, PackedVector2Array([corpo[0], c + Vector2(0, -l * 0.04), punta]), chiaro)
	Manifesto.poligono(t, PackedVector2Array([c + Vector2(0, -l * 0.04), corpo[1], punta]), scuro)
	Manifesto.poligono(t, PackedVector2Array([c + Vector2(-l * 0.02, -l * 0.2), c + Vector2(0, -l * 0.04),
			c + Vector2(-l * 0.06, -l * 0.04)]), chiaro)
	t.draw_circle(c + Vector2(-l * 0.26, -l * 0.17), l * 0.055, P.CREMA, true, -1.0, true)
	t.draw_circle(c + Vector2(-l * 0.16, -l * 0.26), l * 0.022, P.CREMA, true, -1.0, true)
	t.draw_line(c + Vector2(-l * 0.33, l * 0.0), c + Vector2(-l * 0.13, l * 0.2), Color(P.CREMA, 0.8), 2.5, true)


static func spada_disegnata(t: CanvasItem, c: Vector2, l: float, dettagli: bool) -> void:
	# la spada illustrata, di sbieco: la lama con la scanalatura e il filo di
	# luce, la guardia coi riccioli, l'impugnatura fasciata, il pomo tondo. Nella
	# sagoma le stesse forme, piene e senza niente dentro
	P.gira(t, c, 45.0)
	var lama := PackedVector2Array([Vector2(0, -l * 0.47), Vector2(l * 0.055, -l * 0.38), Vector2(l * 0.055, l * 0.1),
			Vector2(-l * 0.055, l * 0.1), Vector2(-l * 0.055, -l * 0.38)])
	var guardia := Rect2(-l * 0.2, l * 0.1, l * 0.4, l * 0.05)
	var manico := Rect2(-l * 0.032, l * 0.15, l * 0.064, l * 0.2)
	var pomo := Vector2(0, l * 0.39)
	if dettagli:
		Manifesto.poligono(t, Geometry2D.offset_polygon(lama, 3.0, Geometry2D.JOIN_MITER)[0], P.NERO)
		t.draw_rect(guardia.grow(3.0), P.NERO)
		t.draw_rect(manico.grow(3.0), P.NERO)
		t.draw_circle(pomo, l * 0.05 + 3.0, P.NERO, true, -1.0, true)
		for x: float in [-l * 0.2, l * 0.2]:
			t.draw_circle(Vector2(x, l * 0.125), l * 0.04 + 3.0, P.NERO, true, -1.0, true)
	Manifesto.poligono(t, lama, P.CREMA if dettagli else P.NERO)
	var metallo := P.ARANCIO_SCURO if dettagli else P.NERO
	t.draw_rect(guardia, metallo)
	t.draw_rect(manico, P.BRUNO.lightened(0.15) if dettagli else P.NERO)
	t.draw_circle(pomo, l * 0.05, metallo, true, -1.0, true)
	if dettagli:
		for x: float in [-l * 0.2, l * 0.2]:
			t.draw_circle(Vector2(x, l * 0.125), l * 0.04, metallo, true, -1.0, true)
			t.draw_circle(Vector2(x, l * 0.125), l * 0.015, P.NERO, true, -1.0, true)
		t.draw_line(Vector2(0, -l * 0.36), Vector2(0, l * 0.08), P.TRATTO, 2.0, true)
		t.draw_line(Vector2(-l * 0.04, -l * 0.37), Vector2(-l * 0.04, l * 0.08), Color.WHITE, 1.5, true)
		for i in 5:
			var y := l * 0.16 + l * 0.04 * i
			t.draw_line(Vector2(-l * 0.032, y), Vector2(l * 0.032, y + l * 0.025), Color(P.CREMA, 0.6), 1.5, true)
	P.dritto(t)
