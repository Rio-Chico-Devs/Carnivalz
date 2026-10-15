extends RefCounted

# LA TAVOLA DELLE COSTRUZIONI (proposte della crescita, foto «costruzione»): le
# icone di IconeStatistiche con sotto i cerchi, i centri, le tangenti e i punti
# di controllo da cui nascono. Come il «Mon Mandala» dei Hatoba (docs/simboli.md
# §1): i cerchi di costruzione che di solito si cancellano. Servono a vedere che
# ogni curva viene da qualcosa, e a misurarla.

const P := preload("res://prove/PezziCrescita.gd")
const I := preload("res://prove/IconeStatistiche.gd")


static func disegna(t: CanvasItem) -> void:
	t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.06), Vector2(1.0, 1.0))
	P.etichetta(t, Vector2(28, 52), "LA COSTRUZIONE", 36, P.CREMA, P.NERO, P.ARANCIO)
	P.scritta(t, Vector2(400, 80), "I cerchi, i centri, le tangenti e i punti di controllo di ogni icona: i segni che di solito",
			15, P.CARTA, Caratteri.tondo(700))
	P.scritta(t, Vector2(400, 100), "si cancellano. La griglia è di 10 su 100; in arancio chiaro l'area viva.",
			15, P.CARTA, Caratteri.tondo(700))
	var foglio := Rect2(28, 132, 1224, 560)
	P.cartoncino(t, foglio, P.CARTA, 0.0, P.OMBRA, true)
	for i in I.CHIAVI.size():
		var chiave: String = I.CHIAVI[i]
		var cella := Rect2(foglio.position + Vector2(408 * (i % 3), 186.67 * floori(i / 3.0)), Vector2(408, 186.67))
		if i % 3 > 0:
			t.draw_line(cella.position + Vector2(0, 14), cella.position + Vector2(0, cella.size.y - 14), Color(P.NERO, 0.12), 1.0)
		if i >= 3:
			t.draw_line(cella.position + Vector2(14, 0), cella.position + Vector2(cella.size.x - 14, 0), Color(P.NERO, 0.12), 1.0)
		var c := cella.position + Vector2(98, cella.size.y * 0.5)
		pannello(t, chiave, c, 168.0)
		var nome := "Maestria" if chiave == "maestria_dominio" else String(I.NOMI[chiave])
		var x := cella.position.x + 192
		P.scritta(t, Vector2(x, cella.position.y + 34), nome.to_upper(), 15, P.NERO)
		var note: Array[String] = []
		for g: Array in I.progetto(chiave)["guide"]:
			if String(g[0]) == "nota":
				note.append(String(g[1]))
		P.a_capo(t, Rect2(Vector2(x, cella.position.y + 44), Vector2(cella.end.x - x - 14, 130)),
				" ".join(note), 12, P.NERO, Caratteri.tondo(800))


static func pannello(t: CanvasItem, chiave: String, c: Vector2, l: float) -> void:
	var k := l / I.LATO
	var origine := c - Vector2(l, l) * 0.5
	for n in 11:
		var riga := Color(P.NERO, 0.14 if n % 5 == 0 else 0.07)
		t.draw_line(origine + Vector2(n * 10, 0) * k, origine + Vector2(n * 10, 100) * k, riga, 1.0)
		t.draw_line(origine + Vector2(0, n * 10) * k, origine + Vector2(100, n * 10) * k, riga, 1.0)
	t.draw_rect(Rect2(origine + Vector2(4, 4) * k, Vector2(92, 92) * k), Color(P.ARANCIO, 0.35), false, 1.0)
	for strato: Array in I.strati(chiave):
		I.figura(t, c, l, strato[1], Color(P.NERO, 0.2) if int(strato[0]) > 0 else P.CARTA)
	var tinta := Color(P.ARANCIO_SCURO, 0.9)
	for g: Array in I.progetto(chiave)["guide"]:
		match String(g[0]):
			"cerchio":
				arco_nel_riquadro(t, c, l, g[1], float(g[2]), tinta)
			"segmento":
				var da: Vector2 = g[1]
				var a: Vector2 = g[2]
				for n in 48:
					var p0 := da.lerp(a, n / 48.0)
					var p1 := da.lerp(a, (n + 1) / 48.0)
					if dentro(p0) and dentro(p1):
						t.draw_line(I.punto(c, l, p0), I.punto(c, l, p1), tinta, 1.2, true)
			"linea":
				var punti := PackedVector2Array()
				for q: Vector2 in g[1]:
					punti.append(I.punto(c, l, q))
				t.draw_polyline(punti, Color(tinta, 0.75), 1.2, true)
			"punto":
				t.draw_circle(I.punto(c, l, g[1]), 2.6, P.ARANCIO)


static func arco_nel_riquadro(t: CanvasItem, c: Vector2, l: float, centro: Vector2, r: float, tinta: Color) -> void:
	# il cerchio di costruzione, ma solo dentro il riquadro dell'icona: i cerchi
	# grandi dei fianchi dello scudo uscirebbero dalla cella
	var lati := 192
	for i in lati:
		var a := centro + Vector2.from_angle(TAU * i / lati) * r
		var b := centro + Vector2.from_angle(TAU * (i + 1) / lati) * r
		if dentro(a) and dentro(b):
			t.draw_line(I.punto(c, l, a), I.punto(c, l, b), tinta, 1.2, true)


static func dentro(q: Vector2) -> bool:
	return q.x >= 0.0 and q.x <= 100.0 and q.y >= 0.0 and q.y <= 100.0
