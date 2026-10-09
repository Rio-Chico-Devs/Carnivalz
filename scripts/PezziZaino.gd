class_name PezziZaino
extends RefCounted

# I PEZZI DISEGNATI DELLO ZAINO (Zaino.gd): il fondo con la fascia nera e lo
# schermo della scheda, l'oggetto grande sulla fascia, i riquadri di cosa fa, la barra di
# quanto e' pieno, i rombi sulle linguette. Stanno qui perche' la schermata
# resti la storia di cosa si vede e come ci si muove; le misure sono quelle
# della schermata (SchedaZaino), scritte una volta sola.

class Fondo extends Control:
	# l'arancio del manifesto con la sua trama, la fascia nera storta con la
	# striscia chiara accanto, e lo schermo della scheda. La lista non ha uno
	# schermo: le sue fasce stanno sull'arancio, sotto un filo nero di titolo
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)
		Manifesto.trama_dietro(self).show_behind_parent = true

	func _draw() -> void:
		var striscia := PackedVector2Array()
		var banda := SchedaZaino.BANDA
		for p in [banda[0], banda[0] + Vector2(-5, 0), banda[3] + Vector2(-5, 0), banda[3]]:
			striscia.append(p - Vector2(14, 0))
		Manifesto.poligono(self, striscia, Stile.colore("bordo_acceso"))
		Manifesto.poligono(self, PackedVector2Array(SchedaZaino.BANDA), Stile.colore("bordo"))
		Manifesto.disegna_schermo(self, SchedaZaino.SCHERMO_DETTAGLIO)
		draw_rect(Rect2(SchedaZaino.PRIMA_RIGA.x, 128, SchedaZaino.LARGO_RIGA, 3), Stile.colore("bordo"))


class Mostra extends Control:
	# L'OGGETTO SCELTO, GRANDE, sulla fascia nera: il disegno di Bru quando
	# c'e', se no la sagoma del suo tipo. Sopra, quanti ne hai. Cambiando riga
	# arriva scivolando di poco, come in vetrina: e' l'unica cosa che si muove
	const SCIVOLO := 24.0
	var id_oggetto := ""
	var sagoma_vuota := ""         # lo scomparto vuoto: la sua sagoma, spenta
	var arrivo := 1.0
	var orologio := -1.0
	var quanti: Label
	var quanti_cosa: Label

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)
		quanti = Tavola.scritta("", 60, Stile.colore("testo"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER)
		add_child(quanti)
		Tavola.metti(quanti, Rect2(800, 80, 180, 76))
		Tavola.ombra(quanti, Color(Stile.colore("box_testo"), 0.9), Vector2(4, 4))
		quanti_cosa = Tavola.scritta("", 13, Stile.colore("testo"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER)
		add_child(quanti_cosa)
		Tavola.metti(quanti_cosa, Rect2(800, 156, 180, 20))

	func mostra(voce: Dictionary, sagoma_dello_scomparto: String) -> void:
		var nuovo := String(voce.get("oggetto", ""))
		var cambia := nuovo != id_oggetto
		id_oggetto = nuovo
		sagoma_vuota = sagoma_dello_scomparto
		quanti.text = "×%d" % int(voce.get("quanti", 0)) if nuovo != "" else ""
		quanti_cosa.text = ("NEL BOTTINO" if Merce.tipo_oggetto(nuovo) == "pila" else "NELLO ZAINO") if nuovo != "" else ""
		if cambia and nuovo != "":
			arrivo = 0.0
			orologio = 0.0
			set_process(true)
		queue_redraw()

	func _process(delta: float) -> void:
		if orologio < 0.0:
			set_process(false)
			return
		orologio += delta
		var durata := Movimento.durata("colore" if Movimento.ridotto() else "entrata")
		arrivo = Movimento.curva("entrata", clampf(orologio / durata, 0.0, 1.0))
		if orologio >= durata:
			orologio = -1.0
			arrivo = 1.0
		queue_redraw()

	func _draw() -> void:
		if id_oggetto == "":
			Sagome.icona_oggetto(self, SchedaZaino.IMMAGINE.get_center(), 210.0, sagoma_vuota,
					Stile.colore("pannello_chiaro"), Stile.colore("bordo"))
			return
		var spostato := Vector2(0.0 if Movimento.ridotto() else SCIVOLO * (1.0 - arrivo), 0.0)
		var r := Rect2(SchedaZaino.IMMAGINE.position + spostato, SchedaZaino.IMMAGINE.size)
		var disegno := Sagome.immagine_oggetto(id_oggetto)
		if disegno != null:
			Sagome.disegna_dentro(self, disegno, r, Color(1, 1, 1, arrivo))
			return
		# la sagoma ha la sua sfoglia nera sotto: sulla fascia e sull'arancio
		# si legge lo stesso
		var forma := Sagome.tipo_icona(id_oggetto)
		var nero := Color(Stile.colore("box_testo"), arrivo)
		Sagome.icona_oggetto(self, r.get_center() + Vector2(8, 8), 210.0, forma, nero, nero)
		Sagome.icona_oggetto(self, r.get_center(), 210.0, forma, Color(Stile.colore("testo"), arrivo), nero)


class Riquadri extends Control:
	# i riquadri chiari sotto i numeri di cosa fa, e la fascia arancio di chi
	# lo sta usando
	var quanti := 0
	var in_uso := false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)

	func _draw() -> void:
		for i in quanti:
			var r := Rect2(Vector2(SchedaZaino.DETTAGLIO_X + SchedaZaino.PASSO_RIQUADRO * i, SchedaZaino.Y_RIQUADRI),
					SchedaZaino.RIQUADRO)
			draw_rect(r, Stile.colore("pannello_chiaro"))
			draw_rect(Rect2(r.position.x, r.end.y - 3.0, r.size.x, 3.0), Stile.colore("bordo_acceso"))
		if in_uso:
			var r := SchedaZaino.IN_USO
			var storto := r.size.y * Manifesto.INCLINA
			Manifesto.poligono(self, PackedVector2Array([r.position + Vector2(storto, 0), Vector2(r.end.x, r.position.y),
					r.end - Vector2(storto, 0), Vector2(r.position.x, r.end.y)]), Stile.colore("accento"))


class Binario extends Control:
	# QUANTO E' PIENO LO SCOMPARTO, sotto il conto dei posti: una barra, perche'
	# «17/20» si legge, ma una barra quasi piena si vede. E sul bordo destro
	# della lista, se le righe non ci stanno tutte, dove sei nella lista
	var pieno := -1.0
	var finestra := Vector2.ZERO
	var quante := 0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		# sull'arancio: la barra vuota e' un'ombra, quella piena nera (arancio
		# su arancio non si vedeva), rossa quando lo scomparto e' pieno
		var vuota := Color(Stile.colore("box_testo"), 0.2)
		if pieno >= 0.0:
			var r := Rect2(48, 120, 300, 5)
			draw_rect(r, vuota)
			draw_rect(Rect2(r.position, Vector2(r.size.x * pieno, r.size.y)),
					Stile.colore("pericolo") if pieno >= 1.0 else Stile.colore("bordo"))
		if quante <= SchedaZaino.VISIBILI:
			return
		var alto := SchedaZaino.PASSO_RIGA * SchedaZaino.VISIBILI - 8.0
		var x := SchedaZaino.PRIMA_RIGA.x + SchedaZaino.LARGO_RIGA + 26.0
		draw_rect(Rect2(x, SchedaZaino.PRIMA_RIGA.y, 3, alto), vuota)
		var da := alto * finestra.x / float(quante)
		var a := alto * finestra.y / float(quante)
		draw_rect(Rect2(x - 1.0, SchedaZaino.PRIMA_RIGA.y + da, 5, a - da), Stile.colore("bordo"))


class SegniNuovi extends Control:
	# UN ROMBO SULLA LINGUETTA di uno scomparto che ha dentro qualcosa di mai
	# guardato: la stella di Diablo 3 sullo scomparto. Si spegne quando li hai
	# guardati tutti. Chiaro con la sfoglia nera, come il segno NUOVO delle
	# righe: arancio sull'arancio della pagina non si vedeva
	var scheda: SchedaZaino

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, 60)

	func _draw() -> void:
		if scheda == null:
			return
		for linguetta in scheda.linguette:
			if not ElencoZaino.ha_nuovi(String(linguetta.get_meta("scomparto"))):
				continue
			var c := linguetta.position + Vector2(linguetta.size.x - 2.0, 4.0)
			Manifesto.poligono(self, Sagome.rombo(c + Vector2(2, 2), 7.0), Stile.colore("bordo"))
			Manifesto.poligono(self, Sagome.rombo(c, 7.0), Stile.colore("bordo_acceso"))
