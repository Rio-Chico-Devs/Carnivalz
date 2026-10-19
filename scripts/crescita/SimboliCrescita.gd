extends RefCounted

# I SIMBOLI DELLA CRESCITA: la schermata vera (SchedaCrescita) e le proposte
# da cui e' nata (prove/ProposteCrescita.gd).
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
#
# Quarta mano, Bru: «devono essere semplici e memorabili». Due prove per
# ognuno: riempito tutto di un colore si riconosce ancora (la sagoma), e non
# si confonde con gli altri (troppi erano «un rombo con qualcosa dentro").
# Quindi un'idea sola, due forme al massimo, niente dettagli minuti (crepe,
# gocce, raggi, segni d'impatto), e sagome diverse fra loro: la Y della
# scelta, il cuore a due punte, la punta dell'attacco, il tetto della difesa,
# la zanna della vendetta, il pettine d'aghi, la girandola che si chiude...

const IS := preload("res://scripts/crescita/IconeStatistiche.gd")
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
const PESO := 1.4       # i tratti, piu' grassi di quelli disegnati sulla griglia
static var senza_tagli := false   # per le ombre: solo la sagoma, niente tagli nel fondo
static var piega := PIEGA


static func punti(c: Vector2, l: float, xy: Array, giro := 0.0) -> PackedVector2Array:
	# coppie x, y sulla griglia di 24 -> punti veri: girati attorno al centro, poi pendenti
	var fuori := PackedVector2Array()
	for i in range(0, xy.size(), 2):
		var q := Vector2(float(xy[i]) - 12.0, float(xy[i + 1]) - 12.0).rotated(giro)
		q.x -= q.y * piega
		fuori.append(c + q * (l / 24.0))
	return fuori


static func pieno(t: CanvasItem, c: Vector2, l: float, xy: Array, tinta: Color, giro := 0.0) -> void:
	if tinta.a > 0.0:
		Manifesto.poligono(t, punti(c, l, xy, giro), tinta)


static func tratto(t: CanvasItem, c: Vector2, l: float, xy: Array, tinta: Color, spessore := 2.0, giro := 0.0) -> void:
	if tinta.a > 0.0:
		t.draw_polyline(punti(c, l, xy, giro), tinta, maxf(spessore * PESO * l / 24.0, 1.0), true)






static func timbro(t: CanvasItem, nome: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		ombra := Color(0, 0, 0, 0), accento := Color(0, 0, 0, 0)) -> void:
	# il simbolo con l'ombra piena spostata in basso a destra, come le etichette
	if ombra.a > 0.0:
		senza_tagli = true
		disegna(t, nome, c + Vector2(1, 1) * l * 0.08, l, ombra, ombra)
		senza_tagli = false
	disegna(t, nome, c, l, tinta, fondo, accento)


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


static func cuore(t: CanvasItem, c: Vector2, l: float, tinta: Color) -> void:
	# il cuore a due punte: sei lati, nessuna curva
	pieno(t, c, l, [12, 7.4, 16.8, 2.2, 22.6, 8.0, 12, 21.8, 1.4, 8.0, 7.2, 2.2], tinta)


static func occhio(t: CanvasItem, c: Vector2, l: float, tinta: Color, fondo: Color, cy := 12.0) -> void:
	# l'occhio a rombo: un rombo lungo e cavo, la pupilla a rombo
	pieno(t, c, l, [0.8, cy, 12, cy - 7.0, 23.2, cy, 12, cy + 7.0], tinta)
	pieno(t, c, l, [4.8, cy, 12, cy - 4.4, 19.2, cy, 12, cy + 4.4], fondo)
	rombo(t, c, l, 12, cy, 3.2, tinta)


static func disallineati(t: CanvasItem, c: Vector2, l: float, tinta: Color, fondo: Color) -> void:
	# il disallineamento: due rombi fuori registro, quello davanti cavo
	rombo(t, c, l, 9.2, 14.2, 7.6, tinta)
	rombo_cavo(t, c, l, 14.8, 9.8, 7.6, tinta, fondo, 2.2)


static func carta(t: CanvasItem, c: Vector2, l: float, giro: float, tinta: Color, fondo: Color) -> void:
	# la carta del nemico: un rettangolo col rombo tagliato al centro
	pieno(t, c, l, [6.0, 2.4, 18.0, 2.4, 18.0, 21.6, 6.0, 21.6], tinta, giro)
	pieno(t, c, l, [12, 7.6, 15.6, 12, 12, 16.4, 8.4, 12], fondo, giro)


static func barra_rotta(t: CanvasItem, c: Vector2, l: float, y: float, tinta: Color) -> void:
	# una barra spezzata in mezzo: il limite che si rompe
	pieno(t, c, l, [1.4, y, 9.6, y, 8.6, y + 3.0, 1.4, y + 3.0], tinta)
	pieno(t, c, l, [14.4, y, 22.6, y, 22.6, y + 3.0, 15.4, y + 3.0], tinta)


static func disegna(t: CanvasItem, nome: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		_accento := Color(0, 0, 0, 0)) -> void:
	if senza_tagli:
		fondo = Color(0, 0, 0, 0)
	match nome:
		# --- le statistiche, e la scelta fra due ---
		"biforca":
			# la Y: la strada che si divide, un esito pieno e uno da scegliere
			pieno(t, c, l, [10.8, 13.0, 13.2, 13.0, 13.2, 22.4, 10.8, 22.4], tinta)
			tratto(t, c, l, [5.8, 7.4, 12, 13.6, 18.2, 7.4], tinta, 2.2)
			rombo(t, c, l, 5.2, 6.2, 4.0, tinta)
			rombo_cavo(t, c, l, 18.8, 6.2, 4.0, tinta, fondo, 1.8)
		"hp", "attacco", "difesa", "velocita", "intelligenza", "forza_mentale", "fattore", "maestria_dominio", "aura":
			IS.disegna(t, nome, c, l, tinta, fondo, senza_tagli)
		# --- le abilita' del protagonista ---
		"astio":
			# il conto: ogni colpo che incassi e' un debito (abilita.json), e si segna
			for i in 4:
				var x := 5.0 + 4.0 * i
				pieno(t, c, l, [x - 1.2, 3.6, x + 1.2, 3.6, x + 1.2, 20.4, x - 1.2, 20.4], tinta)
			pieno(t, c, l, [1.2, 16.8, 21.6, 5.0, 22.8, 7.2, 2.4, 19.0], fondo)
			pieno(t, c, l, [2.0, 16.0, 22.0, 5.8, 22.8, 7.2, 2.8, 17.4], tinta)
		"vendetta":
			# il morso: chi ti ha morso si ritrova morso, e piu' ti ha fatto male piu' affonda
			pieno(t, c, l, [1.4, 1.6, 22.6, 1.6, 22.6, 4.6, 1.4, 4.6], tinta)
			pieno(t, c, l, [2.6, 4.4, 12.2, 4.4, 7.0, 22.6], tinta)
			pieno(t, c, l, [13.4, 4.4, 21.4, 4.4, 17.0, 16.0], tinta)
		"pieta":
			# il rombo vuoto di chi sta per cadere, e quello che gli scivola via
			rombo_cavo(t, c, l, 12, 8.6, 7.8, tinta, fondo, 2.0)
			rombo(t, c, l, 12, 20.4, 3.2, tinta)
		"flagello":
			# il pettine d'aghi: il buio che si chiude in una pioggia
			pieno(t, c, l, [1.8, 2.2, 22.2, 2.2, 22.2, 5.0, 1.8, 5.0], tinta)
			var aghi := [[4.6, 7.0], [8.3, 12.6], [12.0, 17.0], [15.7, 11.0], [19.4, 6.4]]
			for ago: Array in aghi:
				var x := float(ago[0])
				pieno(t, c, l, [x - 1.4, 5.0, x + 1.4, 5.0, x, 5.0 + float(ago[1])], tinta)
		"annichilazione":
			# la girandola che si chiude: quattro lame che girano verso il vuoto in mezzo
			for i in 4:
				var a := PI * 0.25 + PI * 0.5 * i
				var su := Vector2.from_angle(a)
				var lato := su.orthogonal() * 4.2
				var base := Vector2(12, 12) + su * 11.0
				var punta := Vector2(12, 12) + Vector2.from_angle(a + 0.55) * 2.6
				pieno(t, c, l, [base.x + lato.x, base.y + lato.y, punta.x, punta.y, base.x - lato.x, base.y - lato.y], tinta)
		"mantra":
			# il respiro: il rombo aperto in cima, e il punto fermo
			tratto(t, c, l, [9.4, 4.2, 3.2, 12, 12, 20.8, 20.8, 12, 14.6, 4.2], tinta, 2.6)
			rombo(t, c, l, 12, 12, 3.2, tinta)
		# --- le passive (dentro la cornice a rombo, vedi passiva) ---
		"non_ce_tempo":
			# la clessidra di due triangoli: sopra vuota, sotto piena
			tratto(t, c, l, [5.2, 3.0, 18.8, 3.0, 12, 11.4, 5.2, 3.0], tinta, 1.8)
			pieno(t, c, l, [12, 12.6, 18.8, 21.0, 5.2, 21.0], tinta)
		"immondizia_tesoro":
			# lo scarto storto, e sopra quello che luccica
			pieno(t, c, l, [2.0, 17.0, 21.8, 14.6, 22.4, 19.4, 2.6, 21.8], tinta)
			rombo(t, c, l, 12, 7.6, 5.4, tinta)
		"battito_dell_eroe":
			cuore(t, c, l, tinta)
			tratto(t, c, l, [0.8, 12.6, 7.0, 12.6, 9.0, 8.0, 12.4, 17.4, 14.2, 12.6, 23.2, 12.6], fondo, 1.8)
		"trinita":
			rombo(t, c, l, 12, 6.0, 5.0, tinta)
			rombo(t, c, l, 6.4, 16.0, 5.0, tinta)
			rombo(t, c, l, 17.6, 16.0, 5.0, tinta)
		"presenza_minacciosa":
			# il rombo grande che incombe su quello piccolo
			rombo(t, c, l, 12, 8.4, 8.2, tinta)
			rombo(t, c, l, 12, 20.4, 2.8, tinta)
		"crudelta":
			# il triangolo che schiaccia chi e' piu' piccolo
			pieno(t, c, l, [1.8, 2.6, 22.2, 2.6, 12, 15.4], tinta)
			rombo(t, c, l, 12, 20.2, 2.8, tinta)
		"illuminazione_1":
			carta(t, c, l, 0.0, tinta, fondo)
		"illuminazione_2":
			carta(t, c, l, -0.34, Color(tinta, tinta.a * 0.45), fondo)
			carta(t, c, l, 0.18, tinta, fondo)
		"charm":
			# due rombi incatenati: il legame
			tratto(t, c, l, [8.2, 4.8, 15.4, 12, 8.2, 19.2, 1.0, 12, 8.2, 4.8], tinta, 2.2)
			tratto(t, c, l, [15.8, 4.8, 23.0, 12, 15.8, 19.2, 8.6, 12, 15.8, 4.8], tinta, 2.2)
		"negazione":
			# il colpo annullato: il rombo spaccato in due meta' che si allontanano
			pieno(t, c, l, [10.2, 1.6, 10.2, 22.4, 0.6, 12], tinta)
			pieno(t, c, l, [13.8, 1.6, 23.4, 12, 13.8, 22.4], tinta)
		"infinito":
			# ogni turno un po' di piu': tre rombi che salgono e crescono
			rombo(t, c, l, 5.4, 18.6, 2.6, tinta)
			rombo(t, c, l, 11.2, 12.8, 3.8, tinta)
			rombo(t, c, l, 18.0, 6.0, 5.0, tinta)
		"oltre_il_limite":
			barra_rotta(t, c, l, 15.0, tinta)
			rombo(t, c, l, 12, 7.8, 5.6, tinta)
		"ancora_oltre_il_limite":
			barra_rotta(t, c, l, 12.2, tinta)
			barra_rotta(t, c, l, 17.8, tinta)
			rombo(t, c, l, 12, 5.4, 4.6, tinta)
		"tryharder":
			# i gradini dello sforzo
			pieno(t, c, l, [1.8, 17.2, 22.2, 17.2, 22.2, 21.6, 1.8, 21.6], tinta)
			pieno(t, c, l, [6.0, 10.6, 18.0, 10.6, 18.0, 15.0, 6.0, 15.0], tinta)
			pieno(t, c, l, [10.0, 4.0, 14.0, 4.0, 14.0, 8.4, 10.0, 8.4], tinta)
		"pressione_ultraterrena":
			# il rombo che preme dall'alto, e il piano che si piega
			rombo(t, c, l, 12, 7.4, 7.0, tinta)
			pieno(t, c, l, [1.2, 17.0, 11.0, 15.2, 11.4, 18.2, 1.6, 20.0], tinta)
			pieno(t, c, l, [13.0, 15.2, 22.8, 17.0, 22.4, 20.0, 12.6, 18.2], tinta)
		"una_nuova_alba":
			# meta' rombo sopra l'orizzonte
			pieno(t, c, l, [3.6, 15.6, 20.4, 15.6, 12, 6.4], tinta)
			pieno(t, c, l, [1.2, 16.8, 22.8, 16.8, 22.8, 19.6, 1.2, 19.6], tinta)
		"furia":
			disallineati(t, c, l, tinta, fondo)
			pieno(t, c, l, [17.4, 16.4, 23.4, 16.4, 23.4, 18.6, 17.4, 18.6], tinta)
		"perspicacia_acuta":
			occhio(t, c, l, tinta, fondo, 14.2)
			rombo(t, c, l, 12, 3.2, 2.8, tinta)
		_:
			stella(t, c, l, 12, 12, 9.0, tinta)


# --- le statistiche -------------------------------------------------------------------------
#
# Le icone delle statistiche stanno in IconeStatistiche, con le loro idee. Qui si
# chiamano soltanto.

static func statistica(t: CanvasItem, chiave: String, c: Vector2, l: float, tinta: Color, fondo: Color,
		ombra := Color(0, 0, 0, 0)) -> void:
	IS.timbro(t, chiave, c, l, tinta, fondo, ombra)


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
