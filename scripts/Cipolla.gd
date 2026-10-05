class_name Cipolla
extends RefCounted

# IL DISEGNO DELL'OROLOGIO DELLE SCELTE A TEMPO: la cipolla approvata da Bru il
# 5 ottobre, dopo sei giri di bozze. Solo il disegno, fermo: chi lo muove (il
# pendolo, la catena, il tempo) e' Orologio.gd, e le crepe sono Crepe.gd.
#
# IL MODELLO E' QUELLO CHE HA MANDATO BRU: quadrante nero, tutto a filo chiaro.
# Il doppio cerchio di fuori con le tacche delle ore in mezzo, i numeri romani
# girati verso il centro, il binario dei minuti, il disco nero in mezzo, le
# lancette a foglia, l'anellino al centro. Nero e crema come la lastra dei
# dialoghi.
#
# UN SOLO SISTEMA DI DISEGNO (Bru: «more clean»): tre spessori di filo crema e
# basta. I numeri romani sono tratti come il resto, col pieno e il filo dei
# numeri incisi e la grazia a barra sopra e sotto - le lettere di un carattere,
# schiacciate per starci, erano macchie.
#
# LA PARTE DI SOPRA come nelle cipolle vere (Bru: «troppo semplice, il cosetto
# con quella linea curva sopra»): il collo su un collarino, la corona a cipolla
# zigrinata col bottoncino in punta, e l'archetto di filo tondo a U rovescia
# che scende ai lati della corona e si infila nel collo con due ribattini.
#
# Tutte le misure sono in pixel del gioco, nel riquadro dell'orologio
# (MISURA). Il quadrante sta in frazioni del suo cerchio, prese dal modello.

const MISURA := Vector2(84, 94)
const CENTRO := Vector2(42, 54)
const CASSA := 34.0
const OMBRA := Vector2(6, 6)          # come l'ombra delle scelte
# i tre fili
const FINE := 0.7
const MEDIO := 1.1
const FORTE := 1.8
# il quadrante, in frazioni del cerchio di fuori
const ORLO := 0.97
const ORLO_DENTRO := 0.87
const NUMERI := 0.745
const BINARIO_FUORI := 0.615
const BINARIO_DENTRO := 0.55
const ALTEZZA_NUMERI := 0.165
# IIII e non IV: come sugli orologi veri, e fa il paio con VIII
const ROMANI := ["XII", "I", "II", "III", "IIII", "V", "VI", "VII", "VIII", "IX", "X", "XI"]
# la parte di sopra
const ARCO := Vector2(42, 7.5)        # il centro del mezzo giro in cima all'archetto
const ARCO_RAGGIO := 6.6              # il raggio dell'archetto, a meta' del filo
const FILO_ARCO := 1.6                # quanto e' grosso il filo dell'archetto
const PERNO_ARCO := 3.6               # i ribattini dell'archetto, ai lati del collo...
const PERNI_Y := 15.6                 # ...a quest'altezza
const CORONA_SOTTO := 14.6            # la corona a cipolla: dove poggia sul collo...
const CORONA_SOPRA := 7.2             # ...dove finisce in punta
const CORONA_LARGA := 3.7             # mezza larghezza nella pancia
const PERNO := Vector2(42, 0.9)       # la cima dell'archetto: e' appeso li'
const CERNIERA := Vector2(42, 15.6)   # i ribattini: la cassa ci gira sopra


static func crema() -> Color:
	return Stile.colore("testo")


static func nero() -> Color:
	return Stile.colore("bordo")


# --- la parte di sopra ---------------------------------------------------------

static func ribattino(lato: float) -> Vector2:
	# dove l'archetto entra nel collo, da una parte (-1) o dall'altra (1)
	return Vector2(ARCO.x + lato * PERNO_ARCO, PERNI_Y)


static func strada_arco() -> PackedVector2Array:
	# l'archetto a U rovescia: dal ribattino di sinistra su per la gamba, il
	# mezzo giro sopra la corona, e giu' per l'altra gamba
	var strada := PackedVector2Array([ribattino(-1.0)])
	for i in 25:
		strada.append(ARCO + Vector2.LEFT.rotated(PI * float(i) / 24.0) * ARCO_RAGGIO)
	strada.append(ribattino(1.0))
	return strada


static func archetto(tela: CanvasItem) -> void:
	# il filo tondo, disegnato come un tubo: nero dentro, a due fili, capi tondi
	for tubo in Geometry2D.offset_polyline(strada_arco(), FILO_ARCO * 0.5, Geometry2D.JOIN_ROUND,
			Geometry2D.END_ROUND):
		Manifesto.poligono(tela, tubo, nero())
		var giro := tubo.duplicate()
		giro.append(giro[0])
		tela.draw_polyline(giro, crema(), FINE, true)


static func ribattini(tela: CanvasItem) -> void:
	for lato in [-1.0, 1.0]:
		tela.draw_circle(ribattino(float(lato)), 0.95, crema(), true, -1.0, true)


static func larghezza_corona(y: float) -> float:
	# LA CIPOLLA: stretta dove poggia sul collo, piena nella pancia (a un terzo
	# dell'altezza), poi si chiude in punta come una cupola a cipolla
	var t := clampf((CORONA_SOTTO - y) / (CORONA_SOTTO - CORONA_SOPRA), 0.0, 1.0)
	if t < 0.35:
		return CORONA_LARGA * lerpf(0.6, 1.0, sin(t / 0.35 * PI * 0.5))
	var u := (t - 0.35) / 0.65
	return CORONA_LARGA * maxf(pow(cos(u * PI * 0.5), 1.3), 0.06)


static func a_filo(tela: CanvasItem, forma: PackedVector2Array, spesso: float) -> void:
	# una forma nera col suo filo crema intorno
	Manifesto.poligono(tela, forma, nero())
	var giro := forma.duplicate()
	giro.append(giro[0])
	tela.draw_polyline(giro, crema(), spesso, true)


static func collo_e_corona(tela: CanvasItem) -> void:
	# il collo sale dalla cassa su un collarino; sopra, la corona a cipolla con
	# la zigrinatura che segue la pancia, e in punta il suo bottoncino
	var cima := CENTRO.y - CASSA
	a_filo(tela, PackedVector2Array([Vector2(CENTRO.x - 3.8, cima - 1.6), Vector2(CENTRO.x - 3.0, CORONA_SOTTO),
			Vector2(CENTRO.x + 3.0, CORONA_SOTTO), Vector2(CENTRO.x + 3.8, cima - 1.6)]), FINE + 0.2)
	a_filo(tela, PackedVector2Array([Vector2(CENTRO.x - 4.8, cima + 1.6), Vector2(CENTRO.x - 4.8, cima - 1.6),
			Vector2(CENTRO.x + 4.8, cima - 1.6), Vector2(CENTRO.x + 4.8, cima + 1.6)]), FINE + 0.2)
	var destra := PackedVector2Array()
	var sinistra := PackedVector2Array()
	for i in 17:
		var y := lerpf(CORONA_SOTTO, CORONA_SOPRA, float(i) / 16.0)
		destra.append(Vector2(CENTRO.x + larghezza_corona(y), y))
		sinistra.append(Vector2(CENTRO.x - larghezza_corona(y), y))
	sinistra.reverse()
	destra.append_array(sinistra)
	Manifesto.poligono(tela, destra, nero())
	for k in [-0.62, -0.25, 0.25, 0.62]:
		var riga := PackedVector2Array()
		for i in range(1, 15):
			var y := lerpf(CORONA_SOTTO, CORONA_SOPRA, float(i) / 16.0)
			riga.append(Vector2(CENTRO.x + float(k) * larghezza_corona(y), y))
		tela.draw_polyline(riga, crema(), FINE * 0.7, true)
	destra.append(destra[0])
	tela.draw_polyline(destra, crema(), MEDIO, true)
	var bottone := Vector2(CENTRO.x, CORONA_SOPRA - 0.9)
	tela.draw_circle(bottone, 1.0, nero(), true, -1.0, true)
	tela.draw_arc(bottone, 1.0, 0.0, TAU, 12, crema(), FINE, true)


static func testa() -> PackedVector2Array:
	# il profilo di archetto, corona e collo, per la rottura: un mezzo disco
	# sopra la cassa
	var profilo := PackedVector2Array()
	for i in 17:
		profilo.append(ARCO + Vector2.LEFT.rotated(PI * float(i) / 16.0) * (ARCO_RAGGIO + FILO_ARCO))
	profilo.append(Vector2(CENTRO.x + 6.0, CENTRO.y - CASSA + 1.0))
	profilo.append(Vector2(CENTRO.x - 6.0, CENTRO.y - CASSA + 1.0))
	return profilo


# --- il quadrante ---------------------------------------------------------------

static func quadrante(tela: CanvasItem, quota: float, tinta_tempo: Color, tinta_lancette: Color) -> void:
	# la cassa nera e tutto quello che c'e' sopra, da quota (1 = pieno, 0 =
	# scaduto); il tempo perso si accende sul binario in tinta_tempo
	tela.draw_circle(CENTRO, CASSA, nero(), true, -1.0, true)
	orlo(tela)
	for ora in 12:
		var angolo := TAU * float(ora) / 12.0
		numero(tela, ROMANI[ora], CENTRO + Vector2.UP.rotated(angolo) * CASSA * NUMERI, angolo,
				CASSA * ALTEZZA_NUMERI)
	binario(tela, quota, tinta_tempo)
	lancette(tela, quota, tinta_lancette)
	tela.draw_circle(CENTRO, 2.6, crema(), true, -1.0, true)
	tela.draw_circle(CENTRO, 1.4, nero(), true, -1.0, true)


static func orlo(tela: CanvasItem) -> void:
	# il doppio cerchio di fuori e, fra i due, le tacche delle ore
	tela.draw_arc(CENTRO, CASSA * ORLO, 0.0, TAU, 72, crema(), FORTE, true)
	tela.draw_arc(CENTRO, CASSA * ORLO_DENTRO, 0.0, TAU, 72, crema(), FINE, true)
	for ora in 12:
		var verso := Vector2.UP.rotated(TAU * float(ora) / 12.0)
		tela.draw_line(CENTRO + verso * CASSA * ORLO_DENTRO, CENTRO + verso * CASSA * ORLO, crema(), FORTE, true)


static func numero(tela: CanvasItem, romano: String, centro: Vector2, angolo: float, alto: float) -> void:
	# UN NUMERO ROMANO A TRATTI, coi piedi verso il perno: l'asta che scende
	# da sinistra piena, quella che sale fina, e la grazia a barra sopra e sotto
	var su := Vector2.UP.rotated(angolo)
	var destra := Vector2.RIGHT.rotated(angolo)
	var largo_v := alto * 0.62
	var stacco := alto * 0.27
	var totale := -stacco
	for lettera in romano:
		totale += (0.0 if lettera == "I" else largo_v) + stacco
	var h := alto * 0.5
	var x := -totale * 0.5
	for lettera in romano:
		if lettera == "I":
			tela.draw_line(centro + destra * x - su * h, centro + destra * x + su * h, crema(), MEDIO, true)
		else:
			# V e X: la piena scende da sinistra, la fina sale
			var basso := 0.5 if lettera == "V" else 1.0
			tela.draw_line(centro + destra * x + su * h, centro + destra * (x + largo_v * basso) - su * h,
					crema(), MEDIO, true)
			var da := x + largo_v * (0.5 if lettera == "V" else 0.0)
			tela.draw_line(centro + destra * da - su * h, centro + destra * (x + largo_v) + su * h,
					crema(), FINE * 0.8, true)
			x += largo_v
		x += stacco
	var grazia := totale * 0.5 + alto * 0.16
	for y in [h, -h]:
		tela.draw_line(centro - destra * grazia + su * float(y), centro + destra * grazia + su * float(y),
				crema(), FINE * 0.8, true)


static func binario(tela: CanvasItem, quota: float, tinta_tempo: Color) -> void:
	# il binario dei minuti; il tempo perso ci si accende sopra dalle dodici
	# fino alla lancetta
	var fuori := CASSA * BINARIO_FUORI
	var dentro := CASSA * BINARIO_DENTRO
	var perso := minf(TAU * (1.0 - quota), TAU - 0.001)
	if perso > 0.01:
		tela.draw_arc(CENTRO, (fuori + dentro) * 0.5, -PI * 0.5, -PI * 0.5 + perso,
				maxi(int(64.0 * perso / TAU), 2), tinta_tempo, fuori - dentro, true)
	for minuto in 60:
		var angolo := TAU * float(minuto) / 60.0
		if angolo <= perso:
			continue
		var verso := Vector2.UP.rotated(angolo)
		var quinto := minuto % 5 == 0
		tela.draw_line(CENTRO + verso * (dentro - (1.2 if quinto else 0.0)), CENTRO + verso * fuori,
				crema(), MEDIO if quinto else FINE * 0.8, true)
	tela.draw_arc(CENTRO, fuori, 0.0, TAU, 64, crema(), FINE, true)
	tela.draw_arc(CENTRO, dentro, 0.0, TAU, 64, crema(), FINE, true)


static func lancetta(tela: CanvasItem, angolo: float, coda: float, foglia_da: float, foglia_a: float,
		punta: float, largo: float, tinta: Color) -> void:
	# UNA LANCETTA A LANCIA, in un poligono solo: la coda, l'asta fina, la
	# foglia che si allarga in fretta e si stringe piano fino alla punta
	var v := Vector2.UP.rotated(angolo)
	var o := v.orthogonal()
	var asta := MEDIO * 0.5
	var destra := PackedVector2Array([CENTRO - v * coda + o * asta, CENTRO + v * foglia_da + o * asta])
	for i in range(1, 10):
		var t := float(i) / 10.0
		var quanto := sin(t / 0.3 * PI * 0.5) if t < 0.3 else 1.0 - (t - 0.3) / 0.7
		destra.append(CENTRO + v * lerpf(foglia_da, foglia_a, t) + o * maxf(asta * 0.7, largo * quanto))
	var punti := destra.duplicate()
	punti.append(CENTRO + v * punta)
	for i in range(destra.size() - 1, -1, -1):
		var p := destra[i] - CENTRO
		punti.append(CENTRO + v * p.dot(v) - o * p.dot(o))
	Manifesto.poligono(tela, punti, tinta)


static func lancette(tela: CanvasItem, quota: float, tinta: Color) -> void:
	# la grande fa il giro intero nel tempo della scelta; la piccola, da
	# meno dieci, avanza di un'ora
	var grande := TAU * (1.0 - quota)
	var piccola := deg_to_rad(-60.0) + grande / 12.0
	lancetta(tela, piccola, CASSA * 0.08, CASSA * 0.16, CASSA * 0.5, CASSA * 0.5, 2.3, tinta)
	lancetta(tela, grande, CASSA * 0.16, CASSA * 0.3, CASSA * 0.56, CASSA * BINARIO_FUORI, 1.8, tinta)
	# il contrappeso della grande: un anellino sulla coda
	tela.draw_arc(CENTRO - Vector2.UP.rotated(grande) * CASSA * 0.13, 1.6, 0.0, TAU, 12, tinta, FINE, true)


# --- la catena -------------------------------------------------------------------

static func maglia(tela: CanvasItem, su: Vector2, verso: Vector2, di_piatto: bool, tinta: Color,
		spesso: float) -> void:
	# una maglia vista di piatto e' un anellino, vista di taglio un trattino
	if di_piatto:
		var anello := PackedVector2Array()
		for s in 13:
			var giro := TAU * float(s) / 12.0
			anello.append(su + verso * cos(giro) * 2.9 + verso.orthogonal() * sin(giro) * 1.7)
		tela.draw_polyline(anello, tinta, spesso, true)
	else:
		tela.draw_line(su - verso * 2.6, su + verso * 2.6, tinta, spesso + 0.3, true)
