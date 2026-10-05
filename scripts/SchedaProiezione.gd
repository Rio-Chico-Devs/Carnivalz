class_name SchedaProiezione
extends RefCounted

# LA COLONNA DELLE SCHEDE della proiezione (Proiezione.gd), a destra: come la
# colonna di diagrammi del poster di Interstellar. Mostra il corpo puntato
# (o, se non punti niente, quello scelto) in cinque scatole numerate:
#   01 il nome e l'epoca
#   02 il pozzo e l'orbita, al tratto, che girano piano
#   03 lo stato e quanto attira
#   04 il testo, a blocco
#   05 il bottone: entra, scendi, oppure perche' non si puo'
# Sotto, i comandi. Il bottone e' un Button vero (Proiezione.bottone_entra):
# qui se ne disegna solo l'aspetto.

const X := 972.0
const LARGO := 272.0


static func posto_del_bottone() -> Rect2:
	return Rect2(X, 502, LARGO, 40)


static func scatola(tela: Control, r: Rect2, etichetta: String, tinte: Dictionary) -> void:
	tela.draw_rect(r, Color(tinte["fondo"], 0.88))
	tela.draw_rect(r, Color(tinte["inchiostro"], 0.9), false, 1.0)
	var w := DisegnoProiezione.larghezza(etichetta, 9, 600, 85, 2) + 10.0
	tela.draw_rect(Rect2(r.position, Vector2(w, 14)), tinte["inchiostro"])
	DisegnoProiezione.scrivi(tela, r.position + Vector2(5, 11), etichetta, 9, tinte["fondo"], 600, 85, 2)


static func mostrato(p: Proiezione) -> Dictionary:
	return p.corpo(p.sotto if p.sotto != "" else p.scelto)


static func disegna(p: Proiezione, tela: Control) -> void:
	var entra := 1.0 if Movimento.ridotto() else DisegnoProiezione.liscio(p.t_livello * 1.5 - 0.6)
	if entra <= 0.0:
		return
	var c := mostrato(p)
	# il testo si scrive da quando il corpo e' comparso nella scheda
	var da := p.da_quando_sotto if p.sotto != "" else p.da_quando_scelto + 9.0
	if Movimento.ridotto():
		da = 99.0
	var dx := (1.0 - entra) * 300.0
	nome(tela, Rect2(X + dx, 76, LARGO, 64), c, da, p.tinte)
	var r2 := Rect2(X + dx, 148, LARGO, 124)
	scatola(tela, r2, "02 / POZZO  ·  ORBITA", p.tinte)
	pozzo_al_tratto(tela, Rect2(r2.position + Vector2(6, 16), Vector2(128, 104)), c, p.t, p.tinte)
	orbita_al_tratto(tela, Rect2(r2.position + Vector2(138, 16), Vector2(128, 104)), c, p.t, p.tinte)
	dati(tela, Rect2(X + dx, 280, LARGO, 74), c, da, p.tinte)
	var r4 := Rect2(X + dx, 362, LARGO, 132)
	scatola(tela, r4, "04 / RILEVAMENTO", p.tinte)
	if not c.is_empty():
		var testo := String(c["testo"]).to_upper()
		testo = testo.substr(0, roundi(minf(da * 140.0, float(testo.length()))))
		giustificato(tela, Rect2(r4.position + Vector2(10, 28), Vector2(LARGO - 20, 100)), testo, 10, p.tinte["carta"])
	bottone(tela, posto_del_bottone().grow_side(SIDE_LEFT, -dx).grow_side(SIDE_RIGHT, dx), p)
	suggerimenti(tela, Vector2(X + dx, 566), p.tinte)


static func nome(tela: Control, r: Rect2, c: Dictionary, da: float, tinte: Dictionary) -> void:
	scatola(tela, r, "01 / SCHEDA", tinte)
	var testo := "NESSUN BERSAGLIO" if c.is_empty() else String(c["nome"]).to_upper()
	var corpo := 20
	while corpo > 11 and DisegnoProiezione.larghezza(testo, corpo, 260, 75, 4) > LARGO - 20.0:
		corpo -= 1
	var visibili := roundi(minf(da * 60.0, float(testo.length())))
	DisegnoProiezione.scrivi(tela, r.position + Vector2(10, 40), testo.substr(0, visibili), corpo, tinte["carta"],
			260, 75, 4)
	var epoca := "PUNTA UN SISTEMA O UNA FRATTURA" if c.is_empty() else String(c["epoca"]).to_upper()
	DisegnoProiezione.scrivi(tela, r.position + Vector2(10, 56), epoca, 9, tinte["inchiostro"], 450, 85, 2)


static func dati(tela: Control, r: Rect2, c: Dictionary, da: float, tinte: Dictionary) -> void:
	scatola(tela, r, "03 / DATI", tinte)
	if c.is_empty():
		return
	riga(tela, r.position + Vector2(10, 32), "STATO", DisegnoProiezione.parola_di_stato(String(c["stato"])), tinte)
	var attrazione := clampf(float(c["profondita"]) / 5.5, 0.0, 1.0)
	riga(tela, r.position + Vector2(10, 50), "ATTRAZIONE", "%d%%" % roundi(attrazione * 100.0), tinte)
	var barra := Rect2(r.position + Vector2(10, 58), Vector2(LARGO - 20, 5))
	tela.draw_rect(barra, Color(tinte["inchiostro"], 0.35))
	tela.draw_rect(Rect2(barra.position, Vector2(barra.size.x * attrazione * DisegnoProiezione.liscio(da * 2.0), 5)),
			tinte["carta"])


static func riga(tela: Control, dove: Vector2, chiave: String, valore: String, tinte: Dictionary) -> void:
	DisegnoProiezione.scrivi(tela, dove, chiave, 9, tinte["inchiostro"], 450, 85, 2)
	var w := DisegnoProiezione.larghezza(valore, 10, 450, 85, 2)
	DisegnoProiezione.scrivi(tela, dove + Vector2(LARGO - 20 - w, 0), valore, 10, tinte["carta"], 450, 85, 2)


static func bottone(tela: Control, r: Rect2, p: Proiezione) -> void:
	# il bottone parla del corpo SCELTO: e' quello che si conferma
	var c := p.corpo(p.scelto)
	var carta: Color = p.tinte["carta"]
	var vivo := not c.is_empty() and bool(c["attiva"])
	var parola := "SCEGLI UN BERSAGLIO"
	if not c.is_empty():
		parola = String(c["azione"]).to_upper()
	var batte := 1.0 if Movimento.ridotto() else 0.82 + 0.18 * sin(p.t * 6.0)
	tela.draw_rect(r, Color(carta, batte) if vivo else Color(p.tinte["fondo"], 0.88))
	var a_fuoco := p.bottone_entra != null and p.bottone_entra.has_focus()
	tela.draw_rect(r, carta if vivo or a_fuoco else Color(p.tinte["inchiostro"], 0.9), false, 2.0 if a_fuoco else 1.0)
	var tinta: Color = p.tinte["fondo"] if vivo else p.tinte["inchiostro"]
	DisegnoProiezione.scrivi(tela, r.position + Vector2(14, 26), parola, 13, tinta, 500, 80, 3)
	if not vivo:
		return
	for k in 3:
		var x := r.end.x - 44.0 + float(k) * 11.0 + (0.0 if Movimento.ridotto() else fmod(p.t * 2.0, 1.0) * 4.0)
		var y := r.position.y + 20.0
		tela.draw_colored_polygon(PackedVector2Array([Vector2(x, y - 6), Vector2(x + 7, y), Vector2(x, y + 6)]), tinta)


static func suggerimenti(tela: Control, dove: Vector2, tinte: Dictionary) -> void:
	var tinta: Color = tinte["inchiostro"]
	DisegnoProiezione.scrivi(tela, dove, "CLIC  ·  LA NAVE CI VA", 9, tinta, 450, 85, 2)
	DisegnoProiezione.scrivi(tela, dove + Vector2(0, 15), "CLIC DI NUOVO O INVIO  ·  ENTRA", 9, tinta, 450, 85, 2)
	DisegnoProiezione.scrivi(tela, dove + Vector2(0, 30), "ESC O TASTO DESTRO  ·  ANNULLA", 9, tinta, 450, 85, 2)


static func giustificato(tela: Control, r: Rect2, testo: String, corpo: int, tinta: Color) -> void:
	# TESTO A BLOCCO, come sul poster ciano: le righe piene si allargano fino al bordo
	var righe := a_capo(testo, corpo, r.size.x)
	var y := r.position.y
	for i in righe.size():
		var parole := righe[i]
		var piene := 0.0
		for parola in parole:
			piene += DisegnoProiezione.larghezza(parola, corpo, 420, 85, 2)
		var buco := DisegnoProiezione.larghezza(" ", corpo, 420, 85, 2)
		if i < righe.size() - 1 and parole.size() > 1:
			buco = (r.size.x - piene) / float(parole.size() - 1)
		var x := r.position.x
		for parola in parole:
			DisegnoProiezione.scrivi(tela, Vector2(x, y), parola, corpo, tinta, 420, 85, 2)
			x += DisegnoProiezione.larghezza(parola, corpo, 420, 85, 2) + buco
		y += float(corpo) + 5.0


static func a_capo(testo: String, corpo: int, largo: float) -> Array[PackedStringArray]:
	var righe: Array[PackedStringArray] = []
	var adesso := PackedStringArray()
	for parola in testo.split(" ", false):
		var prova := " ".join(adesso + PackedStringArray([parola]))
		if DisegnoProiezione.larghezza(prova, corpo, 420, 85, 2) > largo and adesso.size() > 0:
			righe.append(adesso)
			adesso = PackedStringArray()
		adesso.append(parola)
	if adesso.size() > 0:
		righe.append(adesso)
	return righe


static func pozzo_al_tratto(tela: Control, r: Rect2, c: Dictionary, t: float, tinte: Dictionary) -> void:
	# il pozzo della scheda, al tratto, che gira piano: anelli e raggi
	var centro := r.get_center() + Vector2(0, -8)
	var fondo := 1.6 if c.is_empty() else float(c["profondita"])
	var giro := 0.0 if Movimento.ridotto() else t * 0.3
	var anelli: Array[PackedVector2Array] = []
	for i in range(1, 8):
		var raggio := float(i) * 7.5
		var giu := fondo * 9.0 / (1.0 + pow(raggio / 12.0, 1.6))
		var linea := PackedVector2Array()
		for k in 33:
			var a := TAU * float(k) / 32.0 + giro
			linea.append(centro + Vector2(cos(a) * raggio, sin(a) * raggio * 0.32 + giu))
		anelli.append(linea)
		tela.draw_polyline(linea, Color(tinte["carta"], 0.35 + 0.08 * i), 1.0, true)
	for k in 12:
		var raggi := PackedVector2Array()
		for linea in anelli:
			raggi.append(linea[int(float(k) * 32.0 / 12.0) % 32])
		tela.draw_polyline(raggi, Color(tinte["inchiostro"], 0.9), 1.0, true)
	DisegnoProiezione.scrivi(tela, r.position + Vector2(2, r.size.y - 4), "δ %.1f" % fondo, 9, tinte["inchiostro"],
			450, 85, 1)


static func orbita_al_tratto(tela: Control, r: Rect2, c: Dictionary, t: float, tinte: Dictionary) -> void:
	var centro := r.get_center() + Vector2(0, -4)
	var tinta: Color = tinte["carta"]
	tela.draw_circle(centro, 3.5, tinta)
	for k in 3:
		var raggi := Vector2(18 + k * 16, (18 + k * 16) * 0.38)
		var linea := PackedVector2Array()
		for i in 49:
			linea.append(centro + Vector2(cos(TAU * float(i) / 48.0), sin(TAU * float(i) / 48.0)) * raggi)
		tela.draw_polyline(linea, Color(tinte["inchiostro"], 0.9), 1.0, true)
	if c.is_empty():
		return
	if float(c["orbita"]) > 0.0:
		var a := float(c["angolo"])
		var raggi := Vector2(50, 50 * 0.38) * clampf(float(c["orbita"]) / 9.0, 0.5, 1.15)
		var dove := centro + Vector2(cos(a), sin(a)) * raggi
		tela.draw_arc(dove, 5, 0, TAU, 16, tinta, 1.2, true)
		tela.draw_circle(dove, 2.0, tinta)
		DisegnoProiezione.scrivi(tela, r.position + Vector2(2, r.size.y - 4), "r %.1f" % float(c["orbita"]), 9,
				tinte["inchiostro"], 450, 85, 1)
		return
	# un sistema, o il centro del Vuoto: le sue fratture, come puntini in giro
	var giro := 0.0 if Movimento.ridotto() else t * 0.4
	for k in 5:
		var a := giro + TAU * float(k) / 5.0
		tela.draw_circle(centro + Vector2(cos(a), sin(a) * 0.38) * 50.0, 1.8, tinta)
