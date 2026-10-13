extends RefCounted

# I SIMBOLI DELLA CRESCITA (prove/ProposteCrescita.gd), provvisori come loro.
#
# Bru, sulla roulette: «bisogna migliorare i simboli [...] sono troppo basici e
# non sono creativi». Rifatti come una famiglia sola, con le stesse regole:
# - una griglia di 24 per tutti, centrata su 12,12 (la misura "l" e' il lato);
# - un tratto solo, 2 su 24, angoli vivi, nessun contorno: i dettagli sono
#   tagli nel colore del fondo, come un timbro;
# - il rombo dell'emblema ritorna dove ha un senso (la velocita', la pupilla,
#   il bottino della Pieta', i due esiti della scelta);
# - ogni abilita' racconta quello che fa (Flagello e' una pioggia d'aghi,
#   Annichilazione tre anelli che si stringono, Mantra il cerchio del respiro);
# - le passive stanno dentro una cornice a rombo e le abilita' no: si
#   distinguono a colpo d'occhio anche piccoli.

const NOMI := {
	"biforca": "Una a scelta", "hp": "Vita", "attacco": "Attacco", "difesa": "Difesa", "velocita": "Velocità",
	"intelligenza": "Intelligenza", "fattore": "Fattore",
	"astio": "Astio", "vendetta": "Vendetta", "pieta": "Pietà", "flagello": "Flagello",
	"annichilazione": "Annichilazione", "mantra": "Mantra",
}


static func punti(c: Vector2, l: float, xy: Array, giro := 0.0) -> PackedVector2Array:
	# coppie x, y sulla griglia di 24 -> punti veri, girati attorno al centro
	var fuori := PackedVector2Array()
	for i in range(0, xy.size(), 2):
		fuori.append(c + Vector2(float(xy[i]) - 12.0, float(xy[i + 1]) - 12.0).rotated(giro) * (l / 24.0))
	return fuori


static func punto(c: Vector2, l: float, x: float, y: float) -> Vector2:
	return c + Vector2(x - 12.0, y - 12.0) * (l / 24.0)


static func pieno(t: CanvasItem, c: Vector2, l: float, xy: Array, tinta: Color, giro := 0.0) -> void:
	Manifesto.poligono(t, punti(c, l, xy, giro), tinta)


static func tratto(t: CanvasItem, c: Vector2, l: float, xy: Array, tinta: Color, spessore := 2.0, giro := 0.0) -> void:
	t.draw_polyline(punti(c, l, xy, giro), tinta, maxf(spessore * l / 24.0, 1.0), true)


static func tondo(t: CanvasItem, c: Vector2, l: float, x: float, y: float, r: float, tinta: Color) -> void:
	t.draw_circle(punto(c, l, x, y), r * l / 24.0, tinta, true, -1.0, true)


static func arco(t: CanvasItem, c: Vector2, l: float, x: float, y: float, r: float, tinta: Color, spessore := 2.0,
		da := 0.0, a := TAU) -> void:
	t.draw_arc(punto(c, l, x, y), r * l / 24.0, da, a, 64, tinta, maxf(spessore * l / 24.0, 1.0), true)


static func rombo(t: CanvasItem, c: Vector2, l: float, x: float, y: float, r: float, tinta: Color) -> void:
	pieno(t, c, l, [x, y - r, x + r, y, x, y + r, x - r, y], tinta)


static func rombo_cavo(t: CanvasItem, c: Vector2, l: float, x: float, y: float, r: float, tinta: Color, fondo: Color,
		spessore := 1.8) -> void:
	# il contorno di un rombo fatto per sottrazione: gli angoli restano vivi
	rombo(t, c, l, x, y, r, tinta)
	rombo(t, c, l, x, y, r - spessore * 1.41, fondo)


static func stella(t: CanvasItem, c: Vector2, l: float, x: float, y: float, r: float, tinta: Color) -> void:
	var xy := []
	for i in 8:
		var a := -PI * 0.5 + PI * i / 4.0
		var raggio := r if i % 2 == 0 else r * 0.3
		xy.append_array([x + cos(a) * raggio, y + sin(a) * raggio])
	pieno(t, c, l, xy, tinta)


static func mandorla(t: CanvasItem, c: Vector2, l: float, cx: float, cy: float, largo: float, alto: float, tinta: Color) -> void:
	# l'occhio: due archi che si toccano in punta
	var xy := []
	for i in 17:
		var s := -1.0 + 2.0 * i / 16.0
		xy.append_array([cx + largo * s, cy - alto * (1.0 - s * s)])
	for i in range(15, 0, -1):
		var s := -1.0 + 2.0 * i / 16.0
		xy.append_array([cx + largo * s, cy + alto * (1.0 - s * s)])
	pieno(t, c, l, xy, tinta)


static func cuore(t: CanvasItem, c: Vector2, l: float, tinta: Color) -> void:
	# il cuore geometrico: un quadrato a rombo e due cerchi sui lati di sopra
	pieno(t, c, l, [12, 6, 19.2, 13.2, 12, 20.4, 4.8, 13.2], tinta)
	tondo(t, c, l, 8.4, 9.6, 5.09, tinta)
	tondo(t, c, l, 15.6, 9.6, 5.09, tinta)


static func fiamma(t: CanvasItem, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	pieno(t, c, l, [12, 1.6, 14.6, 5.2, 17.4, 8.6, 18.8, 12.6, 18.4, 16.4, 16.4, 19.6, 12, 21.8, 7.6, 19.6, 5.6, 16.4,
			5.2, 12.6, 6.6, 9.2, 8.6, 6.8, 9.4, 10.2, 11, 6.4], tinta)
	pieno(t, c, l, [12, 10.4, 14.6, 14.2, 14.8, 17.2, 13.4, 19.4, 12, 20, 10.6, 19.4, 9.2, 17.2, 9.4, 14.2], fondo)


static func occhio(t: CanvasItem, c: Vector2, l: float, tinta: Color, fondo: Color, cy := 12.0) -> void:
	mandorla(t, c, l, 12, cy, 10.6, 6.4, tinta)
	mandorla(t, c, l, 12, cy, 8.4, 4.4, fondo)
	tondo(t, c, l, 12, cy, 3.9, tinta)
	rombo(t, c, l, 12, cy, 1.9, fondo)


static func carta(t: CanvasItem, c: Vector2, l: float, giro: float, tinta: Color, fondo: Color) -> void:
	# la carta del nemico: un rettangolo con la cornice tagliata e il rombo al centro
	pieno(t, c, l, [6.5, 3, 17.5, 3, 17.5, 21, 6.5, 21], tinta, giro)
	tratto(t, c, l, [8.3, 4.8, 15.7, 4.8, 15.7, 19.2, 8.3, 19.2, 8.3, 4.8], fondo, 0.9, giro)
	pieno(t, c, l, [12, 8.6, 15, 12, 12, 15.4, 9, 12], fondo, giro)


static func freccia_su(t: CanvasItem, c: Vector2, l: float, tinta: Color) -> void:
	tratto(t, c, l, [12, 21.5, 12, 7.5], tinta, 2.2)
	pieno(t, c, l, [7, 9.4, 12, 2.2, 17, 9.4], tinta)


static func disegna(t: CanvasItem, nome: String, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	match nome:
		# --- le statistiche, e la scelta fra due ---
		"biforca":
			# la strada che si divide: un esito pieno, uno da scegliere
			tratto(t, c, l, [12, 21.6, 12, 13.6], tinta)
			tratto(t, c, l, [5.8, 7.4, 12, 13.6, 18.2, 7.4], tinta)
			tondo(t, c, l, 12, 13.6, 1.3, tinta)
			rombo(t, c, l, 5.4, 6.4, 3.6, tinta)
			rombo_cavo(t, c, l, 18.6, 6.4, 3.6, tinta, fondo, 1.6)
		"hp":
			cuore(t, c, l, tinta)
			arco(t, c, l, 8.4, 9.6, 2.9, fondo, 1.3, deg_to_rad(195), deg_to_rad(262))
		"attacco":
			# il pugnale, di sbieco: lama scanalata, guardia a rombo, pomo a rombo
			var sbieco := PI * 0.25
			pieno(t, c, l, [12, 1.2, 14.4, 5.2, 13.6, 14.4, 10.4, 14.4, 9.6, 5.2], tinta, sbieco)
			tratto(t, c, l, [12, 4.2, 12, 12.8], fondo, 0.9, sbieco)
			pieno(t, c, l, [5.6, 15.8, 12, 14.2, 18.4, 15.8, 12, 17.4], tinta, sbieco)
			pieno(t, c, l, [10.9, 17.2, 13.1, 17.2, 13.1, 20.4, 10.9, 20.4], tinta, sbieco)
			pieno(t, c, l, [12, 20.2, 13.8, 22, 12, 23.8, 10.2, 22], tinta, sbieco)
		"difesa":
			# lo scudo inquartato, come in araldica
			pieno(t, c, l, [4.4, 3.2, 19.6, 3.2, 19.6, 10.4, 18.6, 14.4, 15.8, 17.9, 12, 21, 8.2, 17.9, 5.4, 14.4, 4.4, 10.4], tinta)
			tratto(t, c, l, [12, 5.2, 12, 18.8], fondo, 1.3)
			tratto(t, c, l, [6.4, 9.4, 17.6, 9.4], fondo, 1.3)
		"velocita":
			# il rombo in corsa, con le scie
			rombo(t, c, l, 15.4, 12, 6.6, tinta)
			rombo(t, c, l, 15.4, 12, 2.2, fondo)
			tratto(t, c, l, [0.8, 12, 7.2, 12], tinta, 2.0)
			tratto(t, c, l, [4.6, 8.2, 10.6, 8.2], tinta, 1.6)
			tratto(t, c, l, [4.6, 15.8, 10.6, 15.8], tinta, 1.6)
		"intelligenza":
			occhio(t, c, l, tinta, fondo)
		"fattore":
			fiamma(t, c, l, tinta, fondo)
		# --- le abilita' del protagonista: raccontano quello che fanno ---
		"astio":
			# il conto: ogni colpo che incassi e' un debito (abilita.json), e si segna
			for i in 4:
				var x := 5.0 + 4.0 * i
				pieno(t, c, l, [x - 1.1, 4.2, x + 1.1, 4.2, x + 1.1, 19.8, x - 1.1, 19.8], tinta)
			pieno(t, c, l, [1.6, 16.4, 21.4, 5.6, 22.4, 7.6, 2.6, 18.4], fondo)
			pieno(t, c, l, [2.4, 15.6, 21.8, 6.4, 22.4, 7.6, 3.0, 16.8], tinta)
			rombo(t, c, l, 21.0, 18.6, 2.4, tinta)
		"vendetta":
			# la falce di luna, e la stella che non perdona
			tondo(t, c, l, 11.4, 12.8, 9.4, tinta)
			tondo(t, c, l, 15.2, 9.6, 7.9, fondo)
			stella(t, c, l, 17.4, 7.6, 4.0, tinta)
		"pieta":
			# la lacrima, e dentro quello che lascera'
			var xy := [12.0, 1.6]
			for i in 21:
				var a := deg_to_rad(-31.0 + 242.0 * i / 20.0)
				xy.append_array([12.0 + cos(a) * 6.8, 14.6 + sin(a) * 6.8])
			pieno(t, c, l, xy, tinta)
			rombo(t, c, l, 12, 14.8, 2.9, fondo)
		"flagello":
			# il buio che si chiude in una pioggia d'aghi
			tratto(t, c, l, [2.4, 3.6, 21.6, 3.6], tinta, 2.4)
			var aghi := [[4.6, 6.5], [8.3, 12.0], [12.0, 16.0], [15.7, 10.5], [19.4, 6.0]]
			for ago: Array in aghi:
				var x := float(ago[0])
				pieno(t, c, l, [x - 1.2, 5.2, x + 1.2, 5.2, x, 5.2 + float(ago[1])], tinta)
		"annichilazione":
			# tre anelli che si stringono: dove c'era qualcuno non c'e' piu' niente
			arco(t, c, l, 12, 12, 10.4, tinta, 1.2)
			arco(t, c, l, 12, 12, 7.0, tinta, 2.4)
			arco(t, c, l, 12, 12, 3.3, tinta, 1.2)
			for i in 4:
				var su := Vector2.from_angle(PI * 0.25 + PI * 0.5 * i)
				var lato := su.orthogonal() * 1.9
				var base := Vector2(12, 12) + su * 12.0
				var punta := Vector2(12, 12) + su * 8.6
				pieno(t, c, l, [base.x + lato.x, base.y + lato.y, punta.x, punta.y, base.x - lato.x, base.y - lato.y], tinta)
		"mantra":
			# il cerchio del respiro, aperto, e il punto fermo
			arco(t, c, l, 12, 12, 8.8, tinta, 2.6, deg_to_rad(-48), deg_to_rad(250))
			var inizio := Vector2(12, 12) + Vector2.from_angle(deg_to_rad(-48)) * 8.8
			rombo(t, c, l, inizio.x, inizio.y, 2.4, tinta)
			tondo(t, c, l, 12, 12, 2.8, tinta)
		# --- le passive (dentro la cornice a rombo, vedi passiva) ---
		"non_ce_tempo":
			tratto(t, c, l, [5, 2.6, 19, 2.6], tinta, 2.2)
			tratto(t, c, l, [5, 21.4, 19, 21.4], tinta, 2.2)
			tratto(t, c, l, [6.6, 4, 17.4, 4, 12.9, 12, 17.4, 20, 6.6, 20, 11.1, 12, 6.6, 4], tinta, 1.6)
			pieno(t, c, l, [9.6, 7.6, 14.4, 7.6, 12, 10.8], tinta)
			pieno(t, c, l, [7.8, 20, 16.2, 20, 12, 15.4], tinta)
		"immondizia_tesoro":
			pieno(t, c, l, [3.6, 9, 7.8, 3.6, 16.2, 3.6, 20.4, 9, 12, 21], tinta)
			tratto(t, c, l, [3.6, 9, 20.4, 9], fondo, 1.0)
			tratto(t, c, l, [7.8, 3.6, 9.8, 9, 12, 21, 14.2, 9, 16.2, 3.6], fondo, 1.0)
		"battito_dell_eroe":
			cuore(t, c, l, tinta)
			tratto(t, c, l, [1.5, 13, 7.6, 13, 9.4, 8.6, 12.4, 17.6, 14.2, 13, 22.5, 13], fondo, 1.6)
		"trinita":
			rombo(t, c, l, 12, 6.2, 4.6, tinta)
			rombo(t, c, l, 6.6, 15.6, 4.6, tinta)
			rombo(t, c, l, 17.4, 15.6, 4.6, tinta)
		"presenza_minacciosa":
			occhio(t, c, l, tinta, fondo, 14.0)
			tratto(t, c, l, [12, 1.6, 12, 5.2], tinta, 1.8)
			tratto(t, c, l, [5.4, 3.2, 7.4, 6.4], tinta, 1.8)
			tratto(t, c, l, [18.6, 3.2, 16.6, 6.4], tinta, 1.8)
		"crudelta":
			for i in 3:
				var x := 4.0 * i
				pieno(t, c, l, [9.4 + x, 2.4, 11.6 + x, 2.4, 6.2 + x, 21.6, 4.6 + x, 21.6], tinta)
		"illuminazione_1":
			carta(t, c, l, 0.0, tinta, fondo)
		"illuminazione_2":
			carta(t, c, l, -0.32, Color(tinta, tinta.a * 0.45), fondo)
			carta(t, c, l, 0.18, tinta, fondo)
		"charm":
			arco(t, c, l, 8.6, 12, 5.8, tinta, 2.2)
			arco(t, c, l, 15.4, 12, 5.8, tinta, 2.2)
		"negazione":
			arco(t, c, l, 12, 12, 8.6, tinta, 2.4)
			tratto(t, c, l, [5.2, 18.8, 18.8, 5.2], tinta, 2.4)
		"infinito":
			var xy := []
			for i in 65:
				var a := TAU * i / 64.0
				var giu := 1.0 + sin(a) * sin(a)
				xy.append_array([12.0 + 10.0 * cos(a) / giu, 12.0 + 10.0 * sin(a) * cos(a) / giu])
			tratto(t, c, l, xy, tinta, 2.4)
		"oltre_il_limite":
			tratto(t, c, l, [2.6, 14, 21.4, 14], tinta, 1.6)
			freccia_su(t, c, l, tinta)
		"ancora_oltre_il_limite":
			tratto(t, c, l, [2.6, 12.4, 21.4, 12.4], tinta, 1.6)
			tratto(t, c, l, [2.6, 16.6, 21.4, 16.6], tinta, 1.6)
			freccia_su(t, c, l, tinta)
		"tryharder":
			for i in 3:
				var y := 4.0 + 6.0 * i
				pieno(t, c, l, [4, y + 5, 12, y - 1, 20, y + 5, 20, y + 8, 12, y + 2, 4, y + 8], tinta)
		"pressione_ultraterrena":
			pieno(t, c, l, [4, 2.6, 20, 2.6, 12, 13.4], tinta)
			tratto(t, c, l, [2.4, 17, 21.6, 17], tinta, 2.2)
			tratto(t, c, l, [5.6, 20.6, 10, 20.6], tinta, 1.4)
			tratto(t, c, l, [14, 20.6, 18.4, 20.6], tinta, 1.4)
		"una_nuova_alba":
			var xy := []
			for i in 17:
				var a := PI + PI * i / 16.0
				xy.append_array([12.0 + cos(a) * 6.4, 17.0 + sin(a) * 6.4])
			pieno(t, c, l, xy, tinta)
			tratto(t, c, l, [1.6, 17, 22.4, 17], tinta, 1.8)
			tratto(t, c, l, [4, 20.6, 20, 20.6], tinta, 1.2)
			for i in 5:
				var su := Vector2.from_angle(PI + PI * (i + 1) / 6.0)
				var da := Vector2(12, 17) + su * 8.6
				var a := Vector2(12, 17) + su * 11.4
				tratto(t, c, l, [da.x, da.y, a.x, a.y], tinta, 1.6)
		"furia":
			fiamma(t, c, l, tinta, fondo)
			stella(t, c, l, 19, 4.6, 3.4, tinta)
		"perspicacia_acuta":
			occhio(t, c, l, tinta, fondo, 14.0)
			rombo(t, c, l, 12, 3.4, 2.6, tinta)
		_:
			stella(t, c, l, 12, 12, 9.0, tinta)


static func passiva(t: CanvasItem, id: String, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	# le passive dentro la cornice a rombo, tagliata per sottrazione
	rombo(t, c, l, 12, 12, 12, tinta)
	rombo(t, c, l, 12, 12, 9.8, fondo)
	disegna(t, id, c, l * 0.54, tinta, fondo)


static func gradi(t: CanvasItem, quanti: int, c: Vector2, l: float, tinta: Color) -> void:
	# il grado di una linea (II, III...): tanti rombini quanti i gradi, in fila
	for i in quanti:
		var q := c + Vector2((i - (quanti - 1) * 0.5) * l * 0.2, 0)
		Manifesto.poligono(t, Sagome.rombo(q, l * 0.07), tinta)
