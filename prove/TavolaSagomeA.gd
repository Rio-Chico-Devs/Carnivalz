extends RefCounted

# LA TAVOLA DELLE STATISTICHE (proposte della crescita, foto «statistiche»): le
# sagome della strada A pulite (SagomeA), come un foglio di specifica.
#   - il catalogo: le nove sulla loro griglia di 20, con la pienezza;
#   - la costruzione: l'occhio grande, con le quote di T e di C in pixel;
#   - timbrate, sul nero, come nella tavola che Bru ha scelto;
#   - nella scheda, e piccole.
# Le misure di tutto sono in docs/sagome_a.md; i file da misurare in
# art/interfaccia/statistiche/strada_a.

const P := preload("res://prove/PezziCrescita.gd")
const A := preload("res://prove/SagomeA.gd")


static func disegna(t: CanvasItem) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.06), Vector2(1.0, 1.0))
	P.etichetta(t, Vector2(28, 52), "LE STATISTICHE", 36, P.CREMA, P.NERO, P.ARANCIO)
	P.scritta(t, Vector2(372, 80), "La strada A, pulita. Griglia di 20 moduli; ogni vuoto è C = 1 modulo, ogni parte sottile è T = 2;",
			15, P.CARTA, Caratteri.tondo(700))
	P.scritta(t, Vector2(372, 100), "lati a 0°, 45°, 90° (e 2 : 1 per fulmine e brace). Dritte, timbrate. Misure: docs/sagome_a.md.",
			15, P.CARTA, Caratteri.tondo(700))
	catalogo(t, Rect2(28, 132, 728, 372))
	costruzione(t, Rect2(780, 132, 472, 360))
	timbrate(t, Rect2(28, 522, 728, 180))
	P.etichetta(t, Vector2(780, 512), "NELLA SCHEDA", 14, P.ARANCIO, P.NERO)
	scheda(t, Rect2(784, 544, 222, 150))
	P.etichetta(t, Vector2(1036, 512), "PICCOLE", 14, P.ARANCIO, P.NERO)
	var misure := [14.0, 18.0, 24.0, 32.0]
	for r in 3:
		var chiave := String(["hp", "attacco", "difesa"][r])
		var x := 1040.0
		for m: float in misure:
			A.timbro(t, chiave, Vector2(x + m * 0.5, 566 + 42 * r), m * 1.1, P.CREMA, P.NERO, P.ARANCIO)
			x += m + 18.0
	P.scritta(t, Vector2(1040, 694), "14 · 18 · 24 · 32 px", 12, P.CARTA, Caratteri.tondo(900))


static func catalogo(t: CanvasItem, r: Rect2) -> void:
	# il foglio chiaro: ogni sagoma sulla sua griglia, l'area viva in arancio
	P.cartoncino(t, r, P.CARTA, 0.0, P.OMBRA, true)
	P.scritta(t, r.position + Vector2(18, 30), "LE NOVE, SULLA GRIGLIA", 18, P.NERO)
	P.scritta(t, r.position + Vector2(r.size.x - 248, 30), "sotto, la pienezza", 13, P.TRATTO, Caratteri.tondo(800),
			HORIZONTAL_ALIGNMENT_RIGHT, 230)
	var lato := 110.0
	for i in A.CHIAVI.size():
		var chiave: String = A.CHIAVI[i]
		var c := r.position + Vector2(76 + 143 * (i % 5), 112 + 160 * floori(i / 5.0))
		griglia(t, c, lato, Color(P.NERO, 0.07))
		A.disegna(t, chiave, c, lato, P.NERO, P.CARTA)
		var nome := "Maestria" if chiave == "maestria_dominio" else String(A.NOMI[chiave])
		P.scritta(t, c + Vector2(-lato * 0.5, lato * 0.5 + 18), nome.to_upper(), 11, P.NERO,
				Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER, lato)
		P.scritta(t, c + Vector2(-lato * 0.5, lato * 0.5 + 33), "%.3f" % A.pienezza(chiave), 11, P.TRATTO,
				Caratteri.tondo(800), HORIZONTAL_ALIGNMENT_CENTER, lato)
	P.a_capo(t, Rect2(r.position + Vector2(18 + 143 * 4, 232), Vector2(124, 120)),
			"La pienezza è l'inchiostro sull'area viva (il quadrato arancio). Tutte entro il 10% dalla media.", 11,
			P.NERO, Caratteri.tondo(800))


static func griglia(t: CanvasItem, c: Vector2, lato: float, tinta: Color) -> void:
	for k in 21:
		var forte := Color(tinta, tinta.a * (2.2 if k % 5 == 0 else 1.0))
		t.draw_line(A.punto(c, lato, Vector2(k, 0)), A.punto(c, lato, Vector2(k, 20)), forte, 1.0)
		t.draw_line(A.punto(c, lato, Vector2(0, k)), A.punto(c, lato, Vector2(20, k)), forte, 1.0)
	t.draw_rect(Rect2(A.punto(c, lato, Vector2(1, 1)), Vector2(18, 18) * lato / 20.0), Color(P.ARANCIO, 0.7), false, 1.0)


static func quota(t: CanvasItem, c: Vector2, lato: float, da: Vector2, a: Vector2, testo: String) -> void:
	# una quota: la linea fra due punti, i due tacchetti, e la misura accanto
	var p0 := A.punto(c, lato, da)
	var p1 := A.punto(c, lato, a)
	var lungo := (p1 - p0).normalized()
	var di_lato := Vector2(-lungo.y, lungo.x) * 5.0
	t.draw_line(p0, p1, P.ARANCIO, 2.0, true)
	t.draw_line(p0 - di_lato, p0 + di_lato, P.ARANCIO, 2.0, true)
	t.draw_line(p1 - di_lato, p1 + di_lato, P.ARANCIO, 2.0, true)
	P.scritta(t, (p0 + p1) * 0.5 + Vector2(10, 5), testo, 13, P.ARANCIO, Caratteri.tondo(900))


static func costruzione(t: CanvasItem, r: Rect2) -> void:
	# l'occhio grande, con le sue quote: il bordo T, il distacco C, l'iride, la pupilla
	P.etichetta(t, r.position, "LA COSTRUZIONE", 14, P.ARANCIO, P.NERO)
	var lato := 300.0
	var c := r.position + Vector2(160, 196)
	griglia(t, c, lato, Color(P.CREMA, 0.06))
	A.disegna(t, "intelligenza", c, lato, P.CREMA, P.NERO)
	quota(t, c, lato, Vector2(10, 4), Vector2(10, 6), "T · 48 px")
	quota(t, c, lato, Vector2(12.2, 6), Vector2(12.2, 7), "C · 24 px")
	quota(t, c, lato, Vector2(13.4, 7), Vector2(13.4, 10), "iride · 3")
	quota(t, c, lato, Vector2(10, 10), Vector2(10, 11.5), "1,5")
	P.a_capo(t, Rect2(r.position + Vector2(332, 50), Vector2(140, 300)),
			"Un modulo è 24 px nei file da misurare (480 × 480).\n\nIl bordo della lente è T, il distacco dall'iride è C, la "
			+ "pupilla è un rombo largo 3.\n\nLa lente ha i lati a 45°: il bordo è rientrato di T esatto, non approssimato "
			+ "sulla griglia.", 12, P.CARTA, Caratteri.tondo(800))


static func timbrate(t: CanvasItem, r: Rect2) -> void:
	P.etichetta(t, r.position, "TIMBRATE", 14, P.ARANCIO, P.NERO)
	for i in A.CHIAVI.size():
		var chiave: String = A.CHIAVI[i]
		var c := r.position + Vector2(44 + 80 * i, 82)
		A.timbro(t, chiave, c, 72.0, P.CREMA, P.NERO, P.ARANCIO)
		A.timbro(t, chiave, c + Vector2(18, 58), 26.0, P.ARANCIO, P.NERO, P.ARANCIO_SCURO)


static func scheda(t: CanvasItem, r: Rect2) -> void:
	# la lista delle statistiche della scheda, come la disegna StatisticheScheda
	t.draw_rect(Rect2(r.position + Vector2(6, 6), r.size), P.ARANCIO_SCURO)
	t.draw_rect(r, Color("#1a1512"))
	var valori := {"hp": 100, "attacco": 15, "difesa": 0, "velocita": 3, "aura": 10}
	var i := 0
	for chiave: String in valori:
		var y := r.position.y + 14.0 + 27.0 * i
		A.timbro(t, chiave, Vector2(r.position.x + 20, y + 11), 24.0, P.CREMA, Color("#1a1512"), P.ARANCIO)
		P.scritta(t, Vector2(r.position.x + 40, y + 17), String(A.NOMI[chiave]), 13, P.CREMA, Caratteri.tondo(800))
		P.scritta(t, Vector2(r.end.x - 70, y + 19), str(int(valori[chiave])), 19, P.CREMA, null, HORIZONTAL_ALIGNMENT_RIGHT, 60)
		t.draw_line(Vector2(r.position.x + 40, y + 25), Vector2(r.end.x - 10, y + 25), Color(P.CREMA, 0.1), 1.0)
		i += 1
