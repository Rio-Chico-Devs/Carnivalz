class_name PezziZaino
extends RefCounted

# I PEZZI DISEGNATI DELLO ZAINO (Zaino.gd): il fondo coi due schermi e la
# fascia, l'oggetto grande sulla fascia, i riquadri di cosa fa, la barra di
# quanto e' pieno, i rombi sulle linguette. Stanno qui perche' la schermata
# resti la storia di cosa si vede e come ci si muove; le misure sono quelle
# della schermata (SchedaZaino), scritte una volta sola.

class Fondo extends Control:
	# l'arancio del manifesto con la sua trama, la fascia nera storta con la
	# striscia chiara accanto, e lo spazio della lista e della scheda: come
	# sono disegnati lo dice la proposta (ProposteZaino.fondo)
	var m: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)
		Manifesto.trama_dietro(self).show_behind_parent = true

	func _draw() -> void:
		ProposteZaino.fondo(self, ProposteZaino.scelta, m)


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
	var nome: Label                # il nome sulla fascia, nella vetrina grande
	var m: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)
		var dove: Rect2 = m["quanti"]
		quanti = Tavola.scritta("", 60 if dove.size.y >= 70.0 else 34, Stile.colore("testo"), Caratteri.titolo(),
				HORIZONTAL_ALIGNMENT_CENTER)
		add_child(quanti)
		Tavola.metti(quanti, dove)
		Tavola.ombra(quanti, Color(Stile.colore("box_testo"), 0.9), Vector2(4, 4))
		quanti_cosa = Tavola.scritta("", 13, Stile.colore("testo"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER)
		add_child(quanti_cosa)
		Tavola.metti(quanti_cosa, Rect2(dove.position.x, dove.end.y, dove.size.x, 20))
		nome = Tavola.scritta("", 40, Stile.colore("testo"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER)
		add_child(nome)
		Tavola.metti(nome, m["nome_sulla_fascia"])
		Tavola.ombra(nome, Color(Stile.colore("box_testo"), 0.9), Vector2(4, 4))
		nome.clip_text = true

	func mostra(voce: Dictionary, sagoma_dello_scomparto: String) -> void:
		var nuovo := String(voce.get("oggetto", ""))
		var cambia := nuovo != id_oggetto
		id_oggetto = nuovo
		sagoma_vuota = sagoma_dello_scomparto
		quanti.text = "×%d" % int(voce.get("quanti", 0)) if nuovo != "" else ""
		quanti_cosa.text = ("NEL BOTTINO" if Merce.tipo_oggetto(nuovo) == "pila" else "NELLO ZAINO") if nuovo != "" else ""
		nome.text = Merce.nome_di(nuovo).to_upper() if nuovo != "" else ""
		Tavola.stringi(nome, 40, 24)
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
		var immagine: Rect2 = m["immagine"]
		var lato := float(m["lato_sagoma"])
		if id_oggetto == "":
			Sagome.icona_oggetto(self, immagine.get_center(), lato, sagoma_vuota,
					Stile.colore("pannello_chiaro"), Stile.colore("bordo"))
			return
		var spostato := Vector2(0.0 if Movimento.ridotto() else SCIVOLO * (1.0 - arrivo), 0.0)
		var r := Rect2(immagine.position + spostato, immagine.size)
		var disegno := Sagome.immagine_oggetto(id_oggetto)
		if disegno != null:
			Sagome.disegna_dentro(self, disegno, r, Color(1, 1, 1, arrivo))
			return
		# la sagoma ha la sua sfoglia nera sotto: sulla fascia e sull'arancio
		# si legge lo stesso
		var forma := Sagome.tipo_icona(id_oggetto)
		var nero := Color(Stile.colore("box_testo"), arrivo)
		Sagome.icona_oggetto(self, r.get_center() + Vector2(8, 8), lato, forma, nero, nero)
		Sagome.icona_oggetto(self, r.get_center(), lato, forma, Color(Stile.colore("testo"), arrivo), nero)


class Riquadri extends Control:
	# i riquadri chiari sotto i numeri di cosa fa, e la fascia arancio di chi
	# lo sta usando
	var quanti := 0
	var in_uso := false
	var y := SchedaZaino.Y_RIQUADRI

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)

	func _draw() -> void:
		for i in quanti:
			var r := Rect2(Vector2(SchedaZaino.DETTAGLIO_X + SchedaZaino.PASSO_RIQUADRO * i, y),
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
	var m: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		# sullo schermo chiaro su scuro; sul foglio e sull'arancio scuro su chiaro
		# (e sull'arancio la barra piena e' nera: arancio su arancio non si vede)
		var su_carta := bool(m["su_carta"])
		var vuota := Color(Stile.colore("box_testo"), 0.2) if su_carta else Stile.colore("barra_vuota")
		var piena := Stile.colore("bordo") if ProposteZaino.scelta == "fasce" else Stile.colore("accento")
		if pieno >= 0.0:
			var r := Rect2(48, 120, minf(300.0, (m["elenco"] as Rect2).size.x - 140.0), 5)
			draw_rect(r, vuota)
			draw_rect(Rect2(r.position, Vector2(r.size.x * pieno, r.size.y)),
					Stile.colore("pericolo") if pieno >= 1.0 else piena)
		var visibili := int(m["visibili"])
		if quante <= visibili:
			return
		var riga: Rect2 = m["riga"]
		var alto := float(m["passo"]) * visibili - 4.0
		var x := riga.end.x + 8.0
		draw_rect(Rect2(x, riga.position.y, 3, alto), vuota if su_carta else Stile.colore("pannello_chiaro"))
		var da := alto * finestra.x / float(quante)
		var a := alto * finestra.y / float(quante)
		draw_rect(Rect2(x - 1.0, riga.position.y + da, 5, a - da),
				Stile.colore("bordo") if su_carta else Stile.colore("bordo_acceso"))


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
