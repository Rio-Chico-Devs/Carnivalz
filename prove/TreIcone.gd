extends RefCounted

# VITA, ATTACCO, DIFESA: LE STRADE (prove/ProposteCrescita.gd, foto «lezioni»,
# «vita», «attacco», «difesa»), provvisorie come le proposte.
#
# Bru: «molto bene, ma bisogna andare oltre, lavoriamo a fondo su icona
# attacco difesa e vita, tutto l'impegno su queste per ora, ti serve anche
# qualche lezione su composizione, uso di due figure per crearne un altra,
# simbolismo e cura delle geometrie». Le lezioni sono in docs/simboli.md (§6);
# qui come entrano:
# - simbolismo: per ognuna l'icona (somiglia), l'indice (la traccia, l'effetto)
#   e il simbolo (una convenzione), come li distingue Peirce; poi la retorica
#   visiva di Bonsiepe a Ulm: metafora, metonimia, la parte per il tutto;
# - due figure per farne una terza: il mitate giapponese (vedere una cosa
#   come un'altra), Fukuda, lo spazio negativo. Il rombo dell'emblema con un
#   taglio in cima e' un cuore; un quadrato e mezzo rombo sono uno scudo; il
#   rombo allungato e' una lama;
# - la geometria: i bordi nascono dal cuore (paralleli ai lati del rombo
#   arancio, a 45°), poche misure che tornano, una sola eccezione voluta;
# - la composizione: il centro ottico sta un poco sopra quello geometrico, la
#   diagonale e' movimento (l'Attacco), l'orizzontale e la base sono stabilita'
#   (la Difesa), la simmetria e' calma (la Vita).

const P := preload("res://prove/PezziCrescita.gd")
const S := preload("res://prove/SimboliCrescita.gd")

# il cuore dell'emblema, a forma di cuore: il rombo con un taglio in cima
const CUORE_A_CUORE := [8.5, 3.8, 12, 7.3, 15.5, 3.8, 19.6, 7.9, 12, 20.9, 4.4, 7.9]


static func sposta(xy: Array, dx: float, dy: float) -> Array:
	var fuori := []
	for i in xy.size():
		fuori.append(float(xy[i]) + (dx if i % 2 == 0 else dy))
	return fuori


static func scala_su(xy: Array, f: float, cx: float, cy: float) -> Array:
	# ingrandisce attorno a un centro qualunque
	var fuori := []
	for i in xy.size():
		var centro := cx if i % 2 == 0 else cy
		fuori.append(centro + (float(xy[i]) - centro) * f)
	return fuori


static func taglia(t: CanvasItem, c: Vector2, l: float, xy: Array, fondo: Color, giro := 0.0) -> void:
	# un taglio nel colore del fondo (niente nelle ombre)
	if not S.senza_tagli and fondo.a > 0.0:
		S.pieno(t, c, l, xy, fondo, giro)


static func fascia_orizzontale(y: float, alta: float) -> Array:
	return [-2.0, y - alta * 0.5, 26.0, y - alta * 0.5, 26.0, y + alta * 0.5, -2.0, y + alta * 0.5]


static func taglia_dentro(t: CanvasItem, c: Vector2, l: float, xy: Array, sagoma_xy: Array, fondo: Color) -> void:
	# un taglio solo dove c'e' il motivo: la fascia ritagliata sulla sagoma, cosi'
	# non intacca l'anello
	if S.senza_tagli or fondo.a <= 0.0:
		return
	var larga: PackedVector2Array = Geometry2D.offset_polygon(S.griglia(sagoma_xy), 0.6, Geometry2D.JOIN_MITER)[0]
	for pezzo: PackedVector2Array in Geometry2D.intersect_polygons(S.griglia(xy), larga):
		S.pieno(t, c, l, S.piatto(pezzo), fondo)


static func cuore_a_rombi(f := 1.0) -> Array:
	return S.cuore_a_rombi(f)


static func scudo_quadrato(lato: float, cima: float) -> Array:
	return S.scudo_quadrato(lato, cima)


# --- i motivi: ogni strada sulla griglia di 24 -------------------------------------------

static func motivo(t: CanvasItem, quale: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		accento := Color(0, 0, 0, 0)) -> void:
	if S.senza_tagli:
		fondo = Color(0, 0, 0, 0)
	var prima := S.piega
	S.piega = 0.0
	var tg := S.taglio_ora
	match quale:
		# --- la Vita ---
		"vita_rombo":
			# com'era: il simbolo coi nostri pezzi, due lobi a rombo e la punta
			S.pieno(t, c, l, S.scala(CUORE_A_CUORE, 0.93), tinta)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"vita_emblema":
			# il gioco di parole: il cuore dell'emblema e' un cuore. Il contorno del
			# cuore grande, e dentro, acceso, il cuore piccolo
			S.banda(t, c, l, S.scala(CUORE_A_CUORE, 0.97), tinta, fondo)
			var piccolo := scala_su(CUORE_A_CUORE, 0.42, 12, 10.4)
			S.pieno(t, c, l, sposta(piccolo, 0, 1.4), accento if accento.a > 0.0 else tinta)
		"vita_tacche":
			# due figure: il cuore e la barra della vita, che si consuma a tacche
			var cuore := cuore_a_rombi(0.95)
			S.pieno(t, c, l, cuore, tinta)
			taglia_dentro(t, c, l, fascia_orizzontale(8.9, tg), cuore, fondo)
			taglia_dentro(t, c, l, fascia_orizzontale(15.1, tg), cuore, fondo)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"vita_due":
			# due lobi che si incrociano: dove si sovrappongono, il cuore
			var sinistro := [7.8, 3.6, 13.4, 9.2, 12, 20.8, 3.6, 7.8]
			var destro := [16.2, 3.6, 20.4, 7.8, 12, 20.8, 10.6, 9.2]
			S.pieno(t, c, l, sinistro, tinta)
			S.pieno(t, c, l, destro, tinta)
			var dentro: Array = Geometry2D.intersect_polygons(S.griglia(sinistro), S.griglia(destro))
			for pezzo: PackedVector2Array in dentro:
				S.pieno(t, c, l, S.piatto(pezzo), accento if accento.a > 0.0 else fondo)
		"vita_costruito":
			# due rombi e un cuneo equilatero, il cuore dell'emblema nel mezzo
			S.pieno(t, c, l, cuore_a_rombi(0.93), tinta)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"vita_cuore":
			# il cuore nel cuore: solo qui il rombo arancio prende la forma di un cuore
			S.pieno(t, c, l, cuore_a_rombi(0.93), tinta)
			S.nucleo_a_cuore(t, c, l, tinta, fondo, accento)
		"vita_goccia":
			# l'indice: la goccia di sangue
			S.pieno(t, c, l, [12, 2.8, 17.4, 12.4, 15.2, 18.6, 8.8, 18.6, 6.6, 12.4], tinta)
			S.nucleo(t, c, l, 12, 13.4, tinta, fondo, accento)
		"vita_battito":
			# l'indice: il battito che passa nel rombo
			S.banda(t, c, l, [12, 4.6, 19.4, 12, 12, 19.4, 4.6, 12], tinta, fondo)
			S.tratto(t, c, l, [2.6, 12, 8.4, 12, 10.2, 7.2, 13.6, 16.8, 15.4, 12, 21.4, 12], tinta, 1.4)
		"vita_tre":
			# tre rombi: due lobi e la punta
			S.rombo(t, c, l, 8.2, 9.0, 4.6, tinta)
			S.rombo(t, c, l, 15.8, 9.0, 4.6, tinta)
			S.rombo(t, c, l, 12, 15.6, 4.6, tinta)
			S.nucleo(t, c, l, 12, 15.6, tinta, fondo, accento)
		"vita_spezzato":
			# il cuore diviso in due meta'
			S.pieno(t, c, l, S.scala(CUORE_A_CUORE, 0.93), tinta)
			taglia(t, c, l, [12 - tg * 0.5, 2, 12 + tg * 0.5, 2, 12 + tg * 0.5, 22, 12 - tg * 0.5, 22], fondo)
		# --- l'Attacco ---
		"att_larga":
			# l'icona: la spada larga di sbieco, il cuore alla base della lama; la lama
			# e' 0,618 della spada
			var sbieco := PI * 0.25
			S.pieno(t, c, l, [12, 2.6, 15.4, 6.0, 15.4, 14.4, 8.6, 14.4, 8.6, 6.0], tinta, sbieco)
			S.pieno(t, c, l, [7.0, 15.6, 17.0, 15.6, 18.2, 16.8, 17.0, 18.0, 7.0, 18.0, 5.8, 16.8], tinta, sbieco)
			S.pieno(t, c, l, [10.7, 18.0, 13.3, 18.0, 13.3, 19.3, 10.7, 19.3], tinta, sbieco)
			S.pieno(t, c, l, [12, 18.7, 13.3, 20.0, 12, 21.3, 10.7, 20.0], tinta, sbieco)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"att_rombo":
			# il mitate: il rombo dell'emblema allungato e' la lama, il cuore ci sta
			# dentro; sotto la guardia, l'impugnatura e il pomo, sempre a rombi
			var sbieco := PI * 0.25
			S.pieno(t, c, l, [12, 2.6, 16.2, 12, 12, 16.2, 7.8, 12], tinta, sbieco)
			S.pieno(t, c, l, [8.2, 17.0, 15.8, 17.0, 15.8, 18.6, 8.2, 18.6], tinta, sbieco)
			S.pieno(t, c, l, [11.1, 18.6, 12.9, 18.6, 12.9, 20.0, 11.1, 20.0], tinta, sbieco)
			S.pieno(t, c, l, [12, 19.4, 13.0, 20.4, 12, 21.4, 11.0, 20.4], tinta, sbieco)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"att_colpo":
			# il colpo al cuore: la lama passa sul rombo arancio e lo spacca in due
			var sbieco := PI * 0.25
			S.rombo(t, c, l, 12, 12, 4.4, accento if accento.a > 0.0 else tinta)
			S.scosta(t, c, l, [12, 2.6, 13.9, 4.5, 13.9, 14.6, 10.1, 14.6, 10.1, 4.5], fondo, sbieco)
			S.pieno(t, c, l, [12, 2.6, 13.9, 4.5, 13.9, 14.6, 10.1, 14.6, 10.1, 4.5], tinta, sbieco)
			S.pieno(t, c, l, [7.4, 15.8, 16.6, 15.8, 17.8, 17.0, 16.6, 18.2, 7.4, 18.2, 6.2, 17.0], tinta, sbieco)
			S.pieno(t, c, l, [10.9, 18.2, 13.1, 18.2, 13.1, 19.5, 10.9, 19.5], tinta, sbieco)
			S.pieno(t, c, l, [12, 18.9, 13.3, 20.2, 12, 21.5, 10.7, 20.2], tinta, sbieco)
		"att_esce":
			# l'attacco esce dalla cornice: la punta buca l'anello
			S.spada_che_esce(t, c, l, tinta, fondo)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"att_fendente":
			# l'indice: il taglio che il colpo lascia, il rombo tagliato di netto
			var sbieco := PI * 0.25
			S.pieno(t, c, l, [12, 3.4, 20.6, 12, 12, 20.6, 3.4, 12], tinta)
			taglia(t, c, l, [12 - 1.0, 0.0, 12 + 1.0, 0.0, 12 + 1.0, 24.0, 12 - 1.0, 24.0], fondo, sbieco)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"att_punta":
			# la parte per il tutto: la punta
			S.pieno(t, c, l, [12, 2.6, 18.2, 19.4, 12, 15.4, 5.8, 19.4], tinta, PI * 0.25)
			S.nucleo(t, c, l, 12, 12.6, tinta, fondo, accento)
		"att_incrociate":
			# due lame incrociate
			for giro: float in [PI * 0.25, -PI * 0.25]:
				S.pieno(t, c, l, [12, 2.8, 13.6, 4.4, 13.6, 15.6, 10.4, 15.6, 10.4, 4.4], tinta, giro)
				S.pieno(t, c, l, [8.6, 15.6, 15.4, 15.6, 15.4, 17.0, 8.6, 17.0], tinta, giro)
				S.pieno(t, c, l, [11.2, 17.0, 12.8, 17.0, 12.8, 20.6, 11.2, 20.6], tinta, giro)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"att_stampo":
			# la spada a stampo: lama, guardia e impugnatura staccate da tagli uguali
			var sbieco := PI * 0.25
			S.pieno(t, c, l, [12, 2.6, 14.8, 5.4, 14.8, 13.0, 9.2, 13.0, 9.2, 5.4], tinta, sbieco)
			S.pieno(t, c, l, [7.0, 14.2, 17.0, 14.2, 18.2, 15.4, 17.0, 16.6, 7.0, 16.6, 5.8, 15.4], tinta, sbieco)
			S.pieno(t, c, l, [10.8, 17.8, 13.2, 17.8, 13.2, 21.2, 10.8, 21.2], tinta, sbieco)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		# --- la Difesa ---
		"dif_scudo":
			# l'icona, coi nostri pezzi: un quadrato e mezzo rombo. La punta a 45°,
			# parallela ai lati del cuore
			S.pieno(t, c, l, S.scala([6.4, 4.8, 17.6, 4.8, 17.6, 15.4, 12, 21.0, 6.4, 15.4], 0.89), tinta)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"dif_quadrato":
			# un quadrato e mezzo rombo: lo scudo alto una volta e mezza la larghezza
			S.pieno(t, c, l, scudo_quadrato(9.6, 5.9), tinta)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"dif_piastre":
			# le due figure staccate da un taglio: il quadrato sopra, il mezzo rombo
			# sotto; il cuore le inchioda insieme
			var m := 5.8
			S.pieno(t, c, l, [12 - m, 4.9, 12 + m, 4.9, 12 + m, 12 - tg * 0.5, 12 - m, 12 - tg * 0.5], tinta)
			S.pieno(t, c, l, [12 - m, 12 + tg * 0.5, 12 + m, 12 + tg * 0.5, 12, 12 + tg * 0.5 + m], tinta)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"dif_kikko":
			# il simbolo giapponese: il guscio della tartaruga (kikko'), protezione e
			# lunga vita; il guscio pieno con la piastra in mezzo staccata da un taglio
			var guscio := [12, 2.6, 20.1, 7.3, 20.1, 16.7, 12, 21.4, 3.9, 16.7, 3.9, 7.3]
			S.pieno(t, c, l, guscio, tinta)
			for dentro: PackedVector2Array in Geometry2D.offset_polygon(S.griglia(guscio), -S.linea_ora * 1.3,
					Geometry2D.JOIN_MITER):
				taglia(t, c, l, S.piatto(dentro), fondo)
			for piastra: PackedVector2Array in Geometry2D.offset_polygon(S.griglia(guscio), -S.linea_ora * 1.3 - tg,
					Geometry2D.JOIN_MITER):
				S.pieno(t, c, l, S.piatto(piastra), tinta)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"dif_lamelle":
			# due figure: lo scudo e la corazza a lamelle dei samurai
			var scudo := scudo_quadrato(10.4, 4.6)
			S.pieno(t, c, l, scudo, tinta)
			taglia_dentro(t, c, l, fascia_orizzontale(8.4, tg), scudo, fondo)
			taglia_dentro(t, c, l, fascia_orizzontale(15.6, tg), scudo, fondo)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"dif_tetto":
			# il riparo: il tetto sopra il cuore
			S.pieno(t, c, l, [12, 3.4, 21.0, 12.4, 17.6, 12.4, 12, 6.8, 6.4, 12.4, 3.0, 12.4], tinta)
			S.pieno(t, c, l, [6.4, 14.6, 17.6, 14.6, 17.6, 17.0, 6.4, 17.0], tinta)
			S.nucleo(t, c, l, 12, 10.8, tinta, fondo, accento)
		"dif_strati":
			# lo scudo a due strati: il bordo e il campo
			var scudo := S.scala([6.4, 4.8, 17.6, 4.8, 17.6, 15.4, 12, 21.0, 6.4, 15.4], 0.95)
			S.banda(t, c, l, scudo, tinta, fondo)
			for campo: PackedVector2Array in Geometry2D.offset_polygon(S.griglia(scudo), -S.linea_ora - tg,
					Geometry2D.JOIN_MITER):
				S.pieno(t, c, l, S.piatto(campo), tinta)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"dif_abbraccio":
			# due braccia che chiudono il cuore
			S.pieno(t, c, l, [9.4, 3.4, 11.4, 5.4, 4.8, 12, 11.4, 18.6, 9.4, 20.6, 0.8, 12], tinta)
			S.pieno(t, c, l, [14.6, 3.4, 23.2, 12, 14.6, 20.6, 12.6, 18.6, 19.2, 12, 12.6, 5.4], tinta)
			S.nucleo(t, c, l, 12, 12, tinta, fondo, accento)
		"dif_muro":
			# il muro di mattoni
			for riga in 3:
				var y := 6.0 + 4.4 * riga
				var da := 4.6 if riga % 2 == 0 else 2.6
				for k in 3:
					var x := da + 5.6 * k
					S.pieno(t, c, l, [x, y, x + 4.8, y, x + 4.8, y + 3.6, x, y + 3.6], tinta)
	S.piega = prima


static func mon(t: CanvasItem, quale: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		accento := Color(0, 0, 0, 0), anello := true) -> void:
	# come SimboliCrescita.mon, per le strade: l'anello e il motivo
	S.ottica(tinta, fondo)
	if anello:
		if not S.senza_tagli and fondo.a > 0.0:
			t.draw_circle(c, (12.0 - S.linea_ora * 0.5) * l / 24.0, fondo, true, -1.0, true)
		S.maru(t, c, l, tinta)
		motivo(t, quale, c, l, tinta, fondo, accento)
	else:
		motivo(t, quale, c, l * 1.22, tinta, fondo, accento)
	S.linea_ora = S.W
	S.taglio_ora = S.TAGLIO


static func timbro(t: CanvasItem, quale: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		accento := Color(0, 0, 0, 0), ombra := Color(0, 0, 0, 0), anello := true) -> void:
	anello = anello and l >= 20.0
	if ombra.a > 0.0:
		S.senza_tagli = true
		mon(t, quale, c + Vector2(1, 1) * l * 0.08, l, ombra, ombra, ombra, anello)
		S.senza_tagli = false
	mon(t, quale, c, l, tinta, fondo, accento, anello)


# --- le tavole ----------------------------------------------------------------------------

const TAVOLE := {
	"vita": {
		"titolo": "VITA",
		"sotto": ["Icona: il corpo, troppo letterale. Indice: il battito, la goccia, che hanno tutti. Simbolo: il cuore,",
				"una convenzione che tutti leggono. Si tiene il simbolo, e lo si fa nostro."],
		"strade": [
			["vita_cuore", "IL CUORE NEL CUORE", "il simbolo e un gioco di parole: il cuore dell'emblema e' un cuore", true],
			["vita_costruito", "DUE ROMBI E UN CUNEO", "due figure per una terza: i rombi dell'emblema e un cuneo a 60°", true],
			["vita_tacche", "A TACCHE", "il cuore e la barra della vita, che cala a tacche", true],
			["vita_emblema", "IL CONTORNO", "il cuore vuoto e dentro quello pieno: da piccolo e' un groviglio", false],
			["vita_goccia", "LA GOCCIA", "l'indice, il sangue: l'HP di troppi giochi, e sembra una gemma", false],
			["vita_battito", "IL BATTITO", "l'indice, il polso: l'icona della salute di ogni app", false],
			["vita_tre", "TRE ROMBI", "troppo vicina al marchio di un'automobile", false],
			["vita_spezzato", "IN DUE", "un cuore diviso dice la fine, non la vita", false],
		],
		"finali": [
			["vita_cuore", "IL CUORE NEL CUORE", "La proposta. Solo nella Vita il rombo arancio dell'emblema diventa un cuore: "
					+ "e' il gioco di parole dei kamon, e il sorriso di Susan Kare. Da piccolo resta un punto arancio, come negli altri."],
			["vita_costruito", "DUE ROMBI E UN CUNEO", "La stessa costruzione senza il gioco: due rombi di raggio 4 e un triangolo "
					+ "equilatero. Il cuore resta un rombo, come in tutta la famiglia."],
			["vita_tacche", "A TACCHE", "Il cuore e la barra della vita insieme: due tagli lo dividono in tre tacche, come la "
					+ "vita che si consuma in combattimento."],
		],
	},
	"attacco": {
		"titolo": "ATTACCO",
		"sotto": ["Icona: la spada. Indice: il fendente, il taglio che resta. Simbolo: la punta, la freccia. Si tiene",
				"l'icona; la diagonale da' il movimento, e la punta che esce dall'anello e' l'attacco stesso."],
		"strade": [
			["att_esce", "LA SPADA CHE ESCE", "l'unica che rompe la cornice: l'attacco esce", true],
			["att_larga", "LA SPADA NELL'ANELLO", "la stessa, tutta dentro: piu' calma", true],
			["att_stampo", "A STAMPO", "lama, guardia e impugnatura staccate da tagli uguali", true],
			["att_rombo", "LA LAMA A ROMBO", "il rombo per lama: sembra un pennino, o una lancia", false],
			["att_colpo", "IL COLPO AL CUORE", "la lama copre tutto il cuore: per vedersi dovrebbe essere piu' grande", false],
			["att_fendente", "IL FENDENTE", "un anello con una barra di traverso e' il divieto", false],
			["att_punta", "LA PUNTA", "la punta da sola e' un cursore, un aeroplanino di carta", false],
			["att_incrociate", "LE SPADE INCROCIATE", "si legge subito, ma e' l'icona della battaglia di ogni gioco", false],
		],
		"finali": [
			["att_esce", "LA SPADA CHE ESCE", "La proposta. L'unico mon che rompe la cornice: la punta buca l'anello. La lama "
					+ "e' 0,618 della spada (la sezione aurea), la punta e' l'angolo del rombo, a 90°."],
			["att_larga", "LA SPADA NELL'ANELLO", "La stessa spada tutta dentro l'anello: piu' calma, uguale alle altre otto."],
			["att_stampo", "A STAMPO", "Lama, guardia e impugnatura staccate da tagli uguali, come nei kamon: piu' disegnata, "
					+ "meno forte da piccola."],
		],
	},
	"difesa": {
		"titolo": "DIFESA",
		"sotto": ["Icona: lo scudo. Indice: quasi niente, la difesa si vede da quello che non succede. Simbolo: il guscio",
				"della tartaruga, il kikko' giapponese. Si tiene l'icona, costruita: un quadrato e mezzo rombo."],
		"strade": [
			["dif_quadrato", "UN QUADRATO E MEZZO ROMBO", "due figure per una terza; la punta parallela ai lati del cuore", true],
			["dif_lamelle", "A LAMELLE", "lo scudo e la corazza a lamelle dei samurai", true],
			["dif_scudo", "COM'ERA", "la punta piu' lunga dei 45°, non parallela a niente", true],
			["dif_piastre", "DUE PIASTRE", "staccate, le due figure sembrano l'icona di scarica", false],
			["dif_kikko", "IL GUSCIO", "il simbolo giapponese della protezione: sembra un dado da bullone", false],
			["dif_strati", "IL BORDO", "lo scudo col bordo e' il distintivo dell'antivirus", false],
			["dif_tetto", "IL RIPARO", "il tetto sopra il cuore: e' la casa", false],
			["dif_abbraccio", "L'ABBRACCIO", "le due braccia attorno al cuore: sono il simbolo del codice", false],
		],
		"finali": [
			["dif_quadrato", "UN QUADRATO E MEZZO ROMBO", "La proposta. Il quadrato (la stabilita') e la meta' bassa del rombo "
					+ "dell'emblema, largo quanto il quadrato: alto una volta e mezza la larghezza, la punta a 45° parallela ai "
					+ "lati del cuore, il cuore nel baricentro."],
			["dif_lamelle", "A LAMELLE", "Lo stesso scudo in tre piastre, come la corazza a lamelle dei samurai: piu' "
					+ "racconto, ma da piccolo i tagli si chiudono."],
			["dif_scudo", "COM'ERA", "Lo scudo di prima, per confronto: la punta a 55°, e il cuore sopra il baricentro."],
		],
	},
}


static func fondo_tavola(t: CanvasItem, titolo: String, sotto: Array) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.06), Vector2(1.0, 1.0))
	var largo := P.etichetta(t, Vector2(28, 52), titolo, 36, P.CREMA, P.NERO, P.ARANCIO)
	for i in sotto.size():
		P.scritta(t, Vector2(maxf(330.0, 52.0 + largo), 80 + 20 * i), String(sotto[i]), 15, P.CARTA, Caratteri.tondo(700))


static func tavola_icona(t: CanvasItem, quale: String) -> void:
	var dati: Dictionary = TAVOLE[quale]
	fondo_tavola(t, String(dati["titolo"]), dati["sotto"])
	# le strade: tenute chiare, scartate spente, e perche'
	P.etichetta(t, Vector2(28, 128), "LE STRADE", 14, P.ARANCIO, P.NERO)
	var strade: Array = dati["strade"]
	for i in strade.size():
		var s: Array = strade[i]
		var o := Vector2(28 + 152 * (i % 4), 160 + 276 * floori(i / 4.0))
		var tenuta: bool = s[3]
		var tinta := P.CREMA if tenuta else P.CREMA.lerp(P.NERO, 0.62)
		var accento := P.ARANCIO if tenuta else P.ARANCIO.lerp(P.NERO, 0.62)
		timbro(t, String(s[0]), o + Vector2(70, 62), 100.0, tinta, P.NERO, accento)
		P.etichetta(t, o + Vector2(0, 124), "TENUTA" if tenuta else "SCARTATA", 11, P.CREMA if tenuta else P.TRATTO, P.NERO)
		P.a_capo(t, Rect2(o + Vector2(0, 146), Vector2(140, 20)), String(s[1]), 12, P.CREMA, Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_LEFT, 2)
		P.a_capo(t, Rect2(o + Vector2(0, 182), Vector2(140, 70)), String(s[2]), 12, P.CARTA, Caratteri.tondo(700),
				HORIZONTAL_ALIGNMENT_LEFT, 5)
	# le tre tenute, grandi, piccole e nella tasca
	P.etichetta(t, Vector2(650, 128), "LE TRE", 14, P.ARANCIO, P.NERO)
	var finali: Array = dati["finali"]
	for i in finali.size():
		var f: Array = finali[i]
		var y := 168.0 + 182.0 * i
		if i == 0:
			t.draw_rect(Rect2(644, y - 8, 612, 172), Color(P.ARANCIO, 0.08))
			t.draw_rect(Rect2(644, y - 8, 4, 172), P.ARANCIO)
		timbro(t, String(f[0]), Vector2(730, y + 70), 132.0, P.CREMA, P.NERO, P.ARANCIO, P.ARANCIO_SCURO)
		P.scritta(t, Vector2(820, y + 18), String(f[1]), 17, P.CREMA)
		P.a_capo(t, Rect2(820, y + 30, 270, 130), String(f[2]), 12, P.CARTA, Caratteri.tondo(700), HORIZONTAL_ALIGNMENT_LEFT, 7)
		# piccole, e nella tasca della roulette
		var x := 1112.0
		for m: float in [32.0, 24.0, 18.0]:
			timbro(t, String(f[0]), Vector2(x + m * 0.5, y + 40), m, P.CREMA, P.NERO, P.ARANCIO)
			x += m + 10.0
		t.draw_rect(Rect2(1110, y + 76, 132, 70), P.NERO.lerp(P.CREMA, 0.04))
		t.draw_rect(Rect2(1110, y + 76, 132, 70), P.ARANCIO, false, 3.0)
		timbro(t, String(f[0]), Vector2(1176, y + 111), 46.0, P.CREMA, P.NERO, P.ARANCIO, P.ARANCIO_SCURO)


# --- la tavola delle lezioni ---------------------------------------------------------------

static func foglio(t: CanvasItem, r: Rect2, titolo: String, fonte: String) -> void:
	P.cartoncino(t, r, P.CARTA, 0.0, P.OMBRA, true)
	P.scritta(t, r.position + Vector2(18, 30), titolo, 18, P.NERO)
	P.scritta(t, r.position + Vector2(18, 48), fonte, 12, P.TRATTO, Caratteri.tondo(800))


static func guida(t: CanvasItem, c: Vector2, l: float, xy: Array, giro := 0.0) -> void:
	# il contorno di una figura di costruzione, sottile e arancio
	var p := S.punti(c, l, xy, giro)
	p.append(p[0])
	t.draw_polyline(p, P.ARANCIO, 1.5, true)


static func lezioni(t: CanvasItem) -> void:
	fondo_tavola(t, "LE LEZIONI", ["Quattro cose da sapere prima di disegnare un segno: che tipo di segno e', come due figure",
			"ne fanno una terza, dove l'occhio mette il centro, e quali misure tornano."])
	S.piega = 0.0
	segni(t, Rect2(28, 132, 600, 278))
	due_figure(t, Rect2(652, 132, 600, 278))
	centro_ottico(t, Rect2(28, 432, 600, 268))
	geometria(t, Rect2(652, 432, 600, 268))
	S.piega = S.PIEGA


static func segni(t: CanvasItem, r: Rect2) -> void:
	# icona, indice, simbolo (Peirce) per le tre statistiche; cerchiata quella scelta
	foglio(t, r, "ICONA, INDICE, SIMBOLO", "Peirce; e Gui Bonsiepe, la retorica visiva a Ulm")
	var o := r.position
	var colonne := ["ICONA: somiglia", "INDICE: e' una traccia", "SIMBOLO: e' un'intesa"]
	for k in 3:
		P.scritta(t, o + Vector2(150 + 150 * k, 76), String(colonne[k]), 12, P.NERO, Caratteri.tondo(900))
	var righe := [["VITA", "", "vita_battito", "vita_costruito", 2], ["ATTACCO", "att_larga", "att_fendente", "att_punta", 0],
			["DIFESA", "dif_quadrato", "", "dif_kikko", 0]]
	for i in 3:
		var y := o.y + 110 + 48 * i
		var riga: Array = righe[i]
		P.scritta(t, Vector2(o.x + 18, y + 6), String(riga[0]), 14, P.NERO)
		for k in 3:
			var c := Vector2(o.x + 190 + 150 * k, y)
			var chiave := String(riga[k + 1])
			if chiave == "":
				P.scritta(t, c + Vector2(-60, 5), "il corpo" if i == 0 else "quello che non succede", 12, P.TRATTO,
						Caratteri.tondo(800))
			else:
				mon(t, chiave, c, 30.0, P.NERO, P.CARTA, Color(0, 0, 0, 0), false)
			if k == int(riga[4]):
				t.draw_arc(c, 23.0, 0.0, TAU, 48, P.ARANCIO, 2.0, true)
	P.a_capo(t, Rect2(o + Vector2(18, 240), Vector2(560, 30)), "Per una statistica servono segni che si capiscono subito: "
			+ "l'icona o il simbolo piu' noto. L'indice racconta un momento, non una qualita'.", 12, P.NERO, Caratteri.tondo(800),
			HORIZONTAL_ALIGNMENT_LEFT, 2)


static func due_figure(t: CanvasItem, r: Rect2) -> void:
	# tre somme: le figure semplici e il rombo dell'emblema danno le tre icone
	foglio(t, r, "DUE FIGURE, UNA TERZA", "il mitate giapponese; Fukuda; lo spazio negativo di FedEx")
	var o := r.position
	var l := 56.0
	var somme := [
		[[[8.4, 4.4, 12.4, 8.4, 8.4, 12.4, 4.4, 8.4], [15.6, 4.4, 19.6, 8.4, 15.6, 12.4, 11.6, 8.4],
				[4.4, 8.4, 19.6, 8.4, 12, 21.6]], "vita_costruito"],
		[[[7.2, 5.9, 16.8, 5.9, 16.8, 15.5, 7.2, 15.5], [12, 10.7, 16.8, 15.5, 12, 20.3, 7.2, 15.5]], "dif_quadrato"],
		[[[8.6, 6.0, 15.4, 6.0, 15.4, 14.4, 8.6, 14.4], [12, 2.6, 15.4, 6.0, 12, 9.4, 8.6, 6.0]], "att_larga"],
	]
	for i in somme.size():
		var y := o.y + 100 + 64 * i
		var pezzi: Array = somme[i][0]
		var x := o.x + 44
		for k in pezzi.size():
			var giro := PI * 0.25 if i == 2 else 0.0
			# ogni pezzo da solo, centrato, alla stessa scala del risultato
			var b := S.griglia(pezzi[k])
			var centro := Vector2.ZERO
			for q in b:
				centro += q
			centro /= b.size()
			S.pieno(t, Vector2(x, y), l, sposta(pezzi[k], 12.0 - centro.x, 12.0 - centro.y), P.NERO, giro)
			x += 66
			P.scritta(t, Vector2(x - 40, y + 8), "+" if k < pezzi.size() - 1 else "=", 22, P.ARANCIO)
		mon(t, String(somme[i][1]), Vector2(x + 8, y), l, P.NERO, P.CARTA, Color(0, 0, 0, 0), false)
	P.a_capo(t, Rect2(o + Vector2(330, 72), Vector2(250, 190)), "Il mitate: vedere una cosa come un'altra (un ventaglio per "
			+ "le nuvole, una coppa per la luna). Fukuda, Victory 1945: il proiettile che rientra nel cannone. FedEx: la "
			+ "freccia nel vuoto fra due lettere. Qui: due rombi e un cuneo fanno il cuore; un quadrato e mezzo rombo, lo "
			+ "scudo; un rettangolo e l'angolo del rombo, la lama.", 12, P.NERO, Caratteri.tondo(800), HORIZONTAL_ALIGNMENT_LEFT, 12)


static func centro_ottico(t: CanvasItem, r: Rect2) -> void:
	# lo stesso rombo nell'anello: al centro esatto, un poco sopra, troppo sopra
	foglio(t, r, "IL CENTRO OTTICO", "l'occhio pesa di piu' l'alto: un poco sopra il centro sembra al centro")
	var o := r.position
	var spostamenti := [0.0, -0.9, -2.4]
	var nomi := ["al centro: sembra basso", "un poco sopra: sembra centrato", "troppo sopra: sale"]
	for i in 3:
		var c := o + Vector2(110 + 190 * i, 134)
		var k := 104.0 / 24.0
		t.draw_circle(c, 12.0 * k, P.CARTA)
		t.draw_arc(c, (12.0 - S.W * 0.5) * k, 0.0, TAU, 96, P.NERO, S.W * k, true)
		S.rombo(t, c + Vector2(0, float(spostamenti[i]) * k), 104.0, 12, 12, 4.0, P.NERO)
		t.draw_line(c + Vector2(-56, 0), c + Vector2(56, 0), Color(P.ARANCIO, 0.7), 1.0)
		P.a_capo(t, Rect2(c + Vector2(-95, 60), Vector2(190, 40)), String(nomi[i]), 12, P.NERO, Caratteri.tondo(800),
				HORIZONTAL_ALIGNMENT_CENTER, 2)
	P.a_capo(t, Rect2(o + Vector2(18, 222), Vector2(560, 40)), "Nei mon il cuore resta al centro esatto, sempre nello "
			+ "stesso punto (le teste di Holt); sono i motivi attorno a portare il peso un poco in alto.", 12, P.NERO,
			Caratteri.tondo(800), HORIZONTAL_ALIGNMENT_LEFT, 2)


static func geometria(t: CanvasItem, r: Rect2) -> void:
	# le tre icone con la costruzione sopra, in arancio
	foglio(t, r, "LA GEOMETRIA", "poche misure che tornano: 45°, 60°, 1 : 1,5, 0,618")
	var o := r.position
	var l := 124.0
	var centri := [o + Vector2(110, 140), o + Vector2(300, 140), o + Vector2(490, 140)]
	mon(t, "vita_costruito", centri[0], l, P.NERO, P.CARTA, Color(0, 0, 0, 0), false)
	guida(t, centri[0], l * 1.22, S.scala([8.4, 3.9, 12.4, 7.9, 8.4, 11.9, 4.4, 7.9], 0.93))
	guida(t, centri[0], l * 1.22, S.scala([15.6, 3.9, 19.6, 7.9, 15.6, 11.9, 11.6, 7.9], 0.93))
	guida(t, centri[0], l * 1.22, S.scala([4.4, 7.9, 19.6, 7.9, 12, 7.9 + 7.6 * sqrt(3.0)], 0.93))
	mon(t, "dif_quadrato", centri[1], l, P.NERO, P.CARTA, Color(0, 0, 0, 0), false)
	guida(t, centri[1], l * 1.22, [7.2, 5.9, 16.8, 5.9, 16.8, 15.5, 7.2, 15.5])
	guida(t, centri[1], l * 1.22, [12, 10.7, 16.8, 15.5, 12, 20.3, 7.2, 15.5])
	mon(t, "att_larga", centri[2], l, P.NERO, P.CARTA, Color(0, 0, 0, 0), false)
	var k := l * 1.22 / 24.0
	var asse := Vector2(1, -1).normalized()
	var punta: Vector2 = centri[2] + asse * 9.4 * k
	var fondo_spada: Vector2 = centri[2] - asse * 9.3 * k
	t.draw_line(fondo_spada, punta, P.ARANCIO, 1.5, true)
	var aureo := punta.lerp(fondo_spada, 0.618)
	t.draw_line(aureo - asse.orthogonal() * 22.0, aureo + asse.orthogonal() * 22.0, P.ARANCIO, 2.0, true)
	var didascalie := ["due rombi di raggio 4, la punta a 60°", "un quadrato e mezzo rombo: 1 : 1,5", "la lama: 0,618 della spada"]
	for i in 3:
		P.a_capo(t, Rect2(centri[i] + Vector2(-90, 80), Vector2(180, 30)), String(didascalie[i]), 12, P.NERO,
				Caratteri.tondo(800), HORIZONTAL_ALIGNMENT_CENTER, 2)
