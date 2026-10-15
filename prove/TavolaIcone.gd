extends RefCounted

# LA TAVOLA DELLE STATISTICHE (proposte della crescita, foto «statistiche»): le
# icone di IconeStatistiche.
#   - le nove: ognuna con le due figure da cui nasce, e cosa vogliono dire;
#   - timbrate, sul nero, come nella tavola che Bru ha scelto;
#   - nella scheda, e piccole.
# I file da misurare sono in art/interfaccia/statistiche/proposta.

const P := preload("res://prove/PezziCrescita.gd")
const I := preload("res://prove/IconeStatistiche.gd")


static func disegna(t: CanvasItem) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.06), Vector2(1.0, 1.0))
	P.etichetta(t, Vector2(28, 52), "LE STATISTICHE", 36, P.CREMA, P.NERO, P.ARANCIO)
	P.scritta(t, Vector2(372, 80), "Due figure del mondo di Carnivalz, una icona sola. Curve vere, due spessori (taglio 5, bordo 10",
			15, P.CARTA, Caratteri.tondo(700))
	P.scritta(t, Vector2(372, 100), "su 100), il peso entro il 12% dalla media. I file da misurare: art/interfaccia/statistiche/proposta.",
			15, P.CARTA, Caratteri.tondo(700))
	catalogo(t, Rect2(28, 132, 846, 560))
	P.etichetta(t, Vector2(900, 132), "TIMBRATE", 14, P.ARANCIO, P.NERO)
	for i in I.CHIAVI.size():
		var c := Vector2(952 + 116 * (i % 3), 206 + 92 * floori(i / 3.0))
		I.timbro(t, I.CHIAVI[i], c, 74.0, P.CREMA, P.NERO, P.ARANCIO)
	P.etichetta(t, Vector2(900, 488), "NELLA SCHEDA", 14, P.ARANCIO, P.NERO)
	scheda(t, Rect2(904, 520, 196, 172))
	P.etichetta(t, Vector2(1126, 488), "PICCOLE", 14, P.ARANCIO, P.NERO)
	for r in 4:
		var chiave := String(["hp", "attacco", "velocita", "aura"][r])
		var x := 1130.0
		for m: float in [16.0, 20.0, 26.0]:
			I.timbro(t, chiave, Vector2(x + m * 0.5, 538 + 38 * r), m, P.CREMA, P.NERO, P.ARANCIO)
			x += m + 14.0
	P.scritta(t, Vector2(1130, 694), "16 · 20 · 26 px", 12, P.CARTA, Caratteri.tondo(900))


static func catalogo(t: CanvasItem, r: Rect2) -> void:
	# il foglio chiaro: ogni icona grande, e accanto la sua somma
	P.cartoncino(t, r, P.CARTA, 0.0, P.OMBRA, true)
	for i in I.CHIAVI.size():
		var chiave: String = I.CHIAVI[i]
		var cella := Rect2(r.position + Vector2(282 * (i % 3), 186.67 * floori(i / 3.0)), Vector2(282, 186.67))
		if i % 3 > 0:
			t.draw_line(cella.position + Vector2(0, 18), cella.position + Vector2(0, cella.size.y - 18), Color(P.NERO, 0.12), 1.0)
		if i >= 3:
			t.draw_line(cella.position + Vector2(18, 0), cella.position + Vector2(cella.size.x - 18, 0), Color(P.NERO, 0.12), 1.0)
		I.disegna(t, chiave, cella.position + Vector2(76, 94), 118.0, P.NERO, P.CARTA)
		var x := cella.position.x + 148
		var nome := "Maestria" if chiave == "maestria_dominio" else String(I.NOMI[chiave])
		P.scritta(t, Vector2(x, cella.position.y + 34), nome.to_upper(), 15, P.NERO)
		# la somma: la prima figura, piu', la seconda
		var due := I.due_figure(chiave)
		var y := cella.position.y + 64
		figure(t, due[0], Vector2(x + 20, y), 40.0)
		P.scritta(t, Vector2(x + 44, y + 7), "+", 20, P.ARANCIO_SCURO, Caratteri.tondo(900))
		figure(t, due[1], Vector2(x + 82, y), 40.0)
		var idea: Array = I.IDEE[chiave]
		var largo := cella.end.x - x - 12
		var somma := "%s + %s" % [idea[0], idea[1]]
		var righe := 1 if P.larghezza(somma, 11, Caratteri.tondo(900)) <= largo else 2
		P.a_capo(t, Rect2(Vector2(x, y + 26), Vector2(largo, 30)), somma, 11, P.ARANCIO_SCURO, Caratteri.tondo(900))
		P.a_capo(t, Rect2(Vector2(x, y + 30 + 14 * righe), Vector2(largo, 70)), String(idea[2]), 11, P.NERO,
				Caratteri.tondo(800))


static func figure(t: CanvasItem, strati: Array, c: Vector2, l: float) -> void:
	for strato: Array in strati:
		I.figura(t, c, l, strato[1], P.NERO if int(strato[0]) > 0 else P.CARTA)


static func scheda(t: CanvasItem, r: Rect2) -> void:
	# la lista delle statistiche della scheda, come la disegna StatisticheScheda
	t.draw_rect(Rect2(r.position + Vector2(6, 6), r.size), P.ARANCIO_SCURO)
	t.draw_rect(r, Color("#1a1512"))
	var valori := {"hp": 100, "attacco": 15, "difesa": 0, "velocita": 3, "intelligenza": 4, "aura": 10}
	var i := 0
	for chiave: String in valori:
		var y := r.position.y + 10.0 + 26.5 * i
		I.timbro(t, chiave, Vector2(r.position.x + 20, y + 11), 22.0, P.CREMA, Color("#1a1512"), P.ARANCIO)
		P.scritta(t, Vector2(r.position.x + 40, y + 17), String(I.NOMI[chiave]), 13, P.CREMA, Caratteri.tondo(800))
		P.scritta(t, Vector2(r.end.x - 70, y + 19), str(int(valori[chiave])), 18, P.CREMA, null, HORIZONTAL_ALIGNMENT_RIGHT, 60)
		t.draw_line(Vector2(r.position.x + 40, y + 24), Vector2(r.end.x - 10, y + 24), Color(P.CREMA, 0.1), 1.0)
		i += 1
