extends RefCounted

# I SIMBOLI DELLA CRESCITA (prove/ProposteCrescita.gd), provvisori come loro.
#
# Terza mano. Bru: «dobbiamo personalizzare di più i simboli per evitare
# problemi di copyright». Le forme semplici in se' non sono di nessuno, ma un
# cuore tondo, un pugnale, uno scudo, l'occhio a mandorla, la fiamma, il
# simbolo dell'infinito o il cerchio barrato del divieto somigliano per forza
# ai set di icone che girano; e la mezzaluna con la stella (un simbolo
# religioso e nazionale) e lo scudo con la croce (ricorda la Croce Rossa, il
# cui emblema e' tutelato per legge) e' meglio non usarli proprio.
#
# Allora una grammatica nostra, la stessa per tutti:
# - solo barre dritte, rombi e triangoli: nessun cerchio, nessuna curva;
# - una griglia di 24, centrata su 12,12 (la misura "l" e' il lato);
# - pendono come le scritte del manifesto (PIEGA), il tratto e' grasso (PESO),
#   e il timbro mette dietro l'ombra piena spostata;
# - i dettagli sono tagli nel colore del fondo;
# - le metafore vengono dal gioco, non dal catalogo: il Fattore e' il
#   disallineamento (due rombi fuori registro), la Vita un cuore sfaccettato
#   come una gemma, l'Attacco un cuneo che colpisce un rombo, la Difesa due
#   piastre, l'Intelligenza l'occhio a rombo;
# - le passive stanno dentro la cornice a rombo, le abilita' no.

const NOMI := {
	"biforca": "Una a scelta", "hp": "Vita", "attacco": "Attacco", "difesa": "Difesa", "velocita": "Velocità",
	"intelligenza": "Intelligenza", "fattore": "Fattore",
	"astio": "Astio", "vendetta": "Vendetta", "pieta": "Pietà", "flagello": "Flagello",
	"annichilazione": "Annichilazione", "mantra": "Mantra",
}


# Seconda mano, dopo «già meglio ma sa ancora di ai»: un set di icone sottili e
# dritte e' quello che fa qualunque generatore. Questi sono timbri del
# manifesto: pendono come le sue scritte (PIEGA), il tratto e' piu' pesante
# (PESO), e dietro hanno l'ombra piena spostata (timbro), come le etichette.

const PIEGA := 0.2      # quanto pende tutto, verso destra, come il corsivo del titolo
const PESO := 1.3       # i tratti, piu' grassi di quelli disegnati sulla griglia
static var senza_tagli := false   # per le ombre: solo la sagoma, niente tagli nel fondo


static func punti(c: Vector2, l: float, xy: Array, giro := 0.0) -> PackedVector2Array:
	# coppie x, y sulla griglia di 24 -> punti veri: girati attorno al centro, poi pendenti
	var fuori := PackedVector2Array()
	for i in range(0, xy.size(), 2):
		var q := Vector2(float(xy[i]) - 12.0, float(xy[i + 1]) - 12.0).rotated(giro)
		q.x -= q.y * PIEGA
		fuori.append(c + q * (l / 24.0))
	return fuori


static func pieno(t: CanvasItem, c: Vector2, l: float, xy: Array, tinta: Color, giro := 0.0) -> void:
	if tinta.a > 0.0:
		Manifesto.poligono(t, punti(c, l, xy, giro), tinta)


static func tratto(t: CanvasItem, c: Vector2, l: float, xy: Array, tinta: Color, spessore := 2.0, giro := 0.0) -> void:
	if tinta.a > 0.0:
		t.draw_polyline(punti(c, l, xy, giro), tinta, maxf(spessore * PESO * l / 24.0, 1.0), true)






static func timbro(t: CanvasItem, nome: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		ombra := Color(0, 0, 0, 0)) -> void:
	# il simbolo con l'ombra piena spostata in basso a destra, come le etichette
	if ombra.a > 0.0:
		senza_tagli = true
		disegna(t, nome, c + Vector2(1, 1) * l * 0.08, l, ombra, ombra)
		senza_tagli = false
	disegna(t, nome, c, l, tinta, fondo)


static func passiva_timbro(t: CanvasItem, id: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		ombra := Color(0, 0, 0, 0)) -> void:
	if ombra.a > 0.0:
		senza_tagli = true
		passiva(t, id, c + Vector2(1, 1) * l * 0.07, l, ombra, ombra)
		senza_tagli = false
	passiva(t, id, c, l, tinta, fondo)


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


static func cuore(t: CanvasItem, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	# il cuore sfaccettato: tagliato come una gemma, la cintura e lo spigolo
	pieno(t, c, l, [12, 8.2, 15.0, 3.8, 19.8, 3.8, 22.2, 8.4, 12, 21.4, 1.8, 8.4, 4.2, 3.8, 9.0, 3.8], tinta)
	tratto(t, c, l, [2.6, 8.6, 21.4, 8.6], fondo, 0.7)
	tratto(t, c, l, [12, 9.0, 12, 19.6], fondo, 0.7)


static func occhio(t: CanvasItem, c: Vector2, l: float, tinta: Color, fondo: Color, cy := 12.0) -> void:
	# l'occhio a rombo: un rombo lungo e cavo, la pupilla a rombo
	pieno(t, c, l, [1.2, cy, 12, cy - 6.6, 22.8, cy, 12, cy + 6.6], tinta)
	pieno(t, c, l, [4.4, cy, 12, cy - 4.4, 19.6, cy, 12, cy + 4.4], fondo)
	rombo(t, c, l, 12, cy, 3.0, tinta)


static func disallineati(t: CanvasItem, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	# il disallineamento: due rombi fuori registro, quello davanti cavo
	rombo(t, c, l, 9.2, 14.2, 7.6, tinta)
	rombo_cavo(t, c, l, 14.8, 9.8, 7.6, tinta, fondo, 2.0)


static func cuneo(t: CanvasItem, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	# il colpo: un cuneo largo che arriva su un rombo e lo spacca
	rombo(t, c, l, 7.6, 16.4, 6.0, tinta)
	tratto(t, c, l, [7.6, 11.2, 6.4, 15.6, 8.8, 17.0, 7.6, 21.6], fondo, 1.0)
	pieno(t, c, l, [23.0, 4.6, 19.4, 1.0, 11.8, 12.2], tinta)


static func carta(t: CanvasItem, c: Vector2, l: float, giro: float, tinta: Color, fondo: Color) -> void:
	# la carta del nemico: un rettangolo con la cornice tagliata e il rombo al centro
	pieno(t, c, l, [6.5, 3, 17.5, 3, 17.5, 21, 6.5, 21], tinta, giro)
	tratto(t, c, l, [8.3, 4.8, 15.7, 4.8, 15.7, 19.2, 8.3, 19.2, 8.3, 4.8], fondo, 0.7, giro)
	pieno(t, c, l, [12, 8.6, 15, 12, 12, 15.4, 9, 12], fondo, giro)


static func barra_rotta(t: CanvasItem, c: Vector2, l: float, y: float, tinta: Color) -> void:
	# una barra spezzata in mezzo: il limite che si rompe
	pieno(t, c, l, [1.6, y, 9.8, y, 9.0, y + 2.6, 1.6, y + 2.6], tinta)
	pieno(t, c, l, [14.2, y, 22.4, y, 22.4, y + 2.6, 15.0, y + 2.6], tinta)


static func disegna(t: CanvasItem, nome: String, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	if senza_tagli:
		fondo = Color(0, 0, 0, 0)
	match nome:
		# --- le statistiche, e la scelta fra due ---
		"biforca":
			# la strada che si divide: un esito pieno, uno da scegliere
			pieno(t, c, l, [10.9, 13.4, 13.1, 13.4, 13.1, 22, 10.9, 22], tinta)
			tratto(t, c, l, [5.8, 7.4, 12, 13.6, 18.2, 7.4], tinta)
			rombo(t, c, l, 5.4, 6.4, 3.6, tinta)
			rombo_cavo(t, c, l, 18.6, 6.4, 3.6, tinta, fondo, 1.6)
		"hp":
			cuore(t, c, l, tinta, fondo)
		"attacco":
			cuneo(t, c, l, tinta, fondo)
		"difesa":
			# la guardia: un tetto a cuneo sopra il rombo, che para quello che cade
			pieno(t, c, l, [1.4, 13.6, 12, 2.0, 22.6, 13.6, 22.6, 18.4, 12, 6.8, 1.4, 18.4], tinta)
			rombo(t, c, l, 12, 17.4, 4.4, tinta)
		"velocita":
			# il rombo in corsa, con le scie
			rombo(t, c, l, 15.4, 12, 6.6, tinta)
			rombo(t, c, l, 15.4, 12, 2.2, fondo)
			pieno(t, c, l, [0.6, 10.9, 7.4, 10.9, 7.4, 13.1, 0.6, 13.1], tinta)
			pieno(t, c, l, [4.4, 7.3, 10.6, 7.3, 10.6, 9.1, 4.4, 9.1], tinta)
			pieno(t, c, l, [4.4, 14.9, 10.6, 14.9, 10.6, 16.7, 4.4, 16.7], tinta)
		"intelligenza":
			occhio(t, c, l, tinta, fondo)
		"fattore":
			disallineati(t, c, l, tinta, fondo)
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
			# dalla crepa, il colpo che torna indietro: piu' sei ridotto male, piu' pesa
			rombo(t, c, l, 9.6, 14.4, 7.6, tinta)
			tratto(t, c, l, [9.6, 7.2, 8.0, 11.4, 11.0, 13.6, 8.4, 17.8, 9.6, 21.6], fondo, 1.1)
			pieno(t, c, l, [11.0, 14.8, 14.6, 11.2, 22.8, 1.2], tinta)
		"pieta":
			# il rombo vuoto di chi sta per cadere, e quello che lascia
			rombo_cavo(t, c, l, 12, 8.4, 7.4, tinta, fondo, 1.5)
			rombo(t, c, l, 6.6, 18.0, 2.2, tinta)
			rombo(t, c, l, 12.0, 20.6, 2.8, tinta)
			rombo(t, c, l, 17.2, 17.4, 2.0, tinta)
		"flagello":
			# il buio che si chiude in una pioggia d'aghi
			pieno(t, c, l, [2.0, 2.4, 22.0, 2.4, 22.0, 4.8, 2.0, 4.8], tinta)
			var aghi := [[4.6, 6.5], [8.3, 12.0], [12.0, 16.0], [15.7, 10.5], [19.4, 6.0]]
			for ago: Array in aghi:
				var x := float(ago[0])
				pieno(t, c, l, [x - 1.2, 5.2, x + 1.2, 5.2, x, 5.2 + float(ago[1])], tinta)
		"annichilazione":
			# tre rombi che si stringono: dove c'era qualcuno non c'e' piu' niente
			rombo_cavo(t, c, l, 12, 12, 11.4, tinta, fondo, 1.0)
			rombo_cavo(t, c, l, 12, 12, 7.8, tinta, fondo, 2.0)
			rombo_cavo(t, c, l, 12, 12, 3.8, tinta, fondo, 1.0)
			for i in 4:
				var su := Vector2.from_angle(PI * 0.25 + PI * 0.5 * i)
				var lato := su.orthogonal() * 1.8
				var base := Vector2(12, 12) + su * 9.4
				var punta := Vector2(12, 12) + su * 6.0
				pieno(t, c, l, [base.x + lato.x, base.y + lato.y, punta.x, punta.y, base.x - lato.x, base.y - lato.y], tinta)
		"mantra":
			# il respiro: il rombo aperto in cima, il punto fermo, il fiato che esce
			tratto(t, c, l, [9.6, 4.6, 3.6, 12, 12, 20.4, 20.4, 12, 14.4, 4.6], tinta, 2.4)
			rombo(t, c, l, 12, 12, 2.8, tinta)
			pieno(t, c, l, [11.1, 0.8, 12.9, 0.8, 12.9, 5.2, 11.1, 5.2], tinta)
		# --- le passive (dentro la cornice a rombo, vedi passiva) ---
		"non_ce_tempo":
			# la clessidra fatta rombo: sopra resta un granello, sotto e' pieno
			rombo_cavo(t, c, l, 12, 12, 10.6, tinta, fondo, 1.8)
			pieno(t, c, l, [5.0, 13.2, 19.0, 13.2, 12, 20.2], tinta)
			rombo(t, c, l, 12, 7.2, 2.0, tinta)
			pieno(t, c, l, [3.4, 11.2, 20.6, 11.2, 20.6, 12.4, 3.4, 12.4], tinta)
		"immondizia_tesoro":
			# un mucchio di scarti storti, e sopra quello che luccica
			pieno(t, c, l, [2.4, 19.0, 21.6, 18.0, 21.8, 21.6, 2.6, 22.4], tinta)
			pieno(t, c, l, [4.6, 13.6, 16.8, 15.0, 16.4, 17.4, 4.2, 16.2], tinta)
			pieno(t, c, l, [9.4, 10.6, 19.6, 9.8, 19.8, 12.4, 9.6, 13.0], tinta)
			rombo(t, c, l, 12.6, 4.8, 3.8, tinta)
			rombo(t, c, l, 12.6, 4.8, 1.4, fondo)
		"battito_dell_eroe":
			cuore(t, c, l, tinta, fondo)
			tratto(t, c, l, [1.0, 13, 7.0, 13, 9.0, 8.4, 12.2, 17.6, 14.0, 13, 23.0, 13], fondo, 1.6)
		"trinita":
			rombo(t, c, l, 12, 6.2, 4.6, tinta)
			rombo(t, c, l, 6.6, 15.6, 4.6, tinta)
			rombo(t, c, l, 17.4, 15.6, 4.6, tinta)
		"presenza_minacciosa":
			# il rombo che incombe su uno piccolo, e la paura che gocciola
			rombo(t, c, l, 12, 7.6, 7.4, tinta)
			for x in [7.6, 12.0, 16.4]:
				pieno(t, c, l, [x - 0.9, 14.6, x + 0.9, 14.6, x, 17.6], tinta)
			rombo(t, c, l, 12, 20.6, 2.4, tinta)
		"crudelta":
			# il rombo affettato
			rombo(t, c, l, 12, 12, 10.4, tinta)
			for i in 3:
				var x := 4.0 * (i - 1)
				pieno(t, c, l, [14.6 + x, 1.0, 16.0 + x, 1.0, 9.4 + x, 23.0, 8.0 + x, 23.0], fondo)
		"illuminazione_1":
			carta(t, c, l, 0.0, tinta, fondo)
		"illuminazione_2":
			carta(t, c, l, -0.32, Color(tinta, tinta.a * 0.45), fondo)
			carta(t, c, l, 0.18, tinta, fondo)
		"charm":
			# due rombi incatenati: il legame
			tratto(t, c, l, [8.4, 5.2, 15.2, 12, 8.4, 18.8, 1.6, 12, 8.4, 5.2], tinta, 2.0)
			tratto(t, c, l, [15.6, 5.2, 22.4, 12, 15.6, 18.8, 8.8, 12, 15.6, 5.2], tinta, 2.0)
			pieno(t, c, l, [10.6, 7.0, 13.0, 7.0, 13.6, 9.6, 11.2, 9.6], fondo)
			tratto(t, c, l, [10.2, 7.0, 13.4, 10.2], tinta, 2.0)
		"negazione":
			# il colpo annullato: il rombo spaccato, le due meta' che si allontanano
			pieno(t, c, l, [10.4, 2.4, 10.4, 21.6, 0.8, 12], tinta)
			pieno(t, c, l, [13.6, 2.4, 23.2, 12, 13.6, 21.6], tinta)
			pieno(t, c, l, [11.4, 9.8, 12.6, 9.8, 12.6, 14.2, 11.4, 14.2], tinta)
		"infinito":
			# ogni turno un po' di piu': rombi che salgono e crescono
			rombo(t, c, l, 4.6, 19.4, 1.8, tinta)
			rombo(t, c, l, 8.8, 15.2, 2.6, tinta)
			rombo(t, c, l, 13.6, 10.4, 3.4, tinta)
			rombo(t, c, l, 19.0, 5.0, 4.2, tinta)
		"oltre_il_limite":
			barra_rotta(t, c, l, 14.4, tinta)
			rombo(t, c, l, 12, 7.0, 4.6, tinta)
			pieno(t, c, l, [10.6, 21.6, 13.4, 21.6, 12, 13.0], tinta)
		"ancora_oltre_il_limite":
			barra_rotta(t, c, l, 11.8, tinta)
			barra_rotta(t, c, l, 16.6, tinta)
			rombo(t, c, l, 12, 5.4, 4.0, tinta)
			pieno(t, c, l, [10.6, 22.6, 13.4, 22.6, 12, 10.6], tinta)
		"tryharder":
			# i gradini dello sforzo, in cima quello che cade in piu'
			pieno(t, c, l, [2.6, 19.2, 21.4, 19.2, 21.4, 22.2, 2.6, 22.2], tinta)
			pieno(t, c, l, [5.6, 13.8, 18.4, 13.8, 18.4, 16.8, 5.6, 16.8], tinta)
			pieno(t, c, l, [8.6, 8.4, 15.4, 8.4, 15.4, 11.4, 8.6, 11.4], tinta)
			rombo(t, c, l, 12, 3.6, 2.6, tinta)
		"pressione_ultraterrena":
			# il rombo che preme dall'alto, e il piano che si piega
			rombo(t, c, l, 12, 7.2, 6.6, tinta)
			pieno(t, c, l, [1.6, 16.6, 11.0, 15.0, 11.4, 17.6, 2.0, 19.2], tinta)
			pieno(t, c, l, [13.0, 15.0, 22.4, 16.6, 22.0, 19.2, 12.6, 17.6], tinta)
			pieno(t, c, l, [10.8, 20.6, 13.2, 20.6, 12, 23.0], tinta)
		"una_nuova_alba":
			# meta' rombo sopra l'orizzonte, e i raggi dritti
			pieno(t, c, l, [5.0, 15.8, 19.0, 15.8, 12, 8.8], tinta)
			pieno(t, c, l, [1.6, 15.8, 22.4, 15.8, 22.4, 18.0, 1.6, 18.0], tinta)
			pieno(t, c, l, [3.6, 20.4, 20.4, 20.4, 20.4, 21.6, 3.6, 21.6], tinta)
			pieno(t, c, l, [11.1, 1.8, 12.9, 1.8, 12.9, 6.2, 11.1, 6.2], tinta)
			tratto(t, c, l, [4.6, 5.6, 7.2, 8.8], tinta, 1.6)
			tratto(t, c, l, [19.4, 5.6, 16.8, 8.8], tinta, 1.6)
		"furia":
			disallineati(t, c, l, tinta, fondo)
			tratto(t, c, l, [19.4, 15.0, 23.0, 15.0], tinta, 1.6)
			tratto(t, c, l, [18.0, 18.6, 22.2, 18.6], tinta, 1.6)
		"perspicacia_acuta":
			occhio(t, c, l, tinta, fondo, 14.0)
			rombo(t, c, l, 12, 3.4, 2.6, tinta)
		_:
			stella(t, c, l, 12, 12, 9.0, tinta)


static func passiva(t: CanvasItem, id: String, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	# le passive dentro la cornice a rombo, tagliata per sottrazione
	if senza_tagli:
		fondo = Color(0, 0, 0, 0)
	rombo(t, c, l, 12, 12, 12, tinta)
	rombo(t, c, l, 12, 12, 9.4, fondo)
	disegna(t, id, c, l * 0.54, tinta, fondo)


static func gradi(t: CanvasItem, quanti: int, c: Vector2, l: float, tinta: Color) -> void:
	# il grado di una linea (II, III...): tanti rombini quanti i gradi, in fila
	for i in quanti:
		var q := c + Vector2((i - (quanti - 1) * 0.5) * l * 0.2, 0)
		Manifesto.poligono(t, Sagome.rombo(q, l * 0.07), tinta)
