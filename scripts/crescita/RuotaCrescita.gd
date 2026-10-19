extends "res://scripts/crescita/BaseCrescita.gd"

# LA RUOTA DISEGNATA, e la lastra a sinistra (SchedaCrescita per il resto).
#
# Il tronco come una roulette (prove/ProposteCrescita.gd, approvata): un giro
# di venti tasche, una per livello. La lancetta sta ferma, a sinistra, dove la
# lastra mette il dente; gira la ruota. Le tasche prese piene, da prendere
# chiare, coi simboli timbrati; i numeri grandi sull'anello, e dove arriva
# qualcosa la cella cambia colore; il mozzo col retino, il giro e il livello.

func ruota_giro(t: CanvasItem, tm: Dictionary, g: int, v: float) -> void:
	var c := CENTRO
	var n := spicchi_del_giro(g)
	var primo := primo_del_giro(g)
	var passo := TAU / n
	var mezzo := passo * 0.5 - deg_to_rad(1.1)
	var lato := 42.0 * sqrt(20.0 / n)   # i simboli crescono quando le tasche sono meno
	var vicini: Array[int] = []
	# l'orlo, dal terzo giro: uno spesso, poi coi rombi, nell'ultimo doppio
	if g >= 2:
		t.draw_arc(c, R_ORLO + 9.0, 0.0, TAU, 180, tm["anello"], 6.0, true)
	if g >= 6:
		t.draw_arc(c, R_ORLO + 19.0, 0.0, TAU, 180, tm["anello"], 2.0, true)
	if g >= 4:
		for k in n:
			var su := Vector2.from_angle(PI + passo * (primo + k - v) + passo * 0.5)
			Manifesto.poligono(t, Sagome.rombo(c + su * (R_ORLO + 9.0), 7.0), tm["accento"] if g < 6 else P.CREMA)
	for k in n:
		var livello := primo + k
		var a := PI + passo * (livello - v)
		cella(t, tm, c, a, mezzo, livello)
		if absf(livello - v) < 1.0:
			vicini.append(livello)
			continue
		var preso := livello <= adesso
		var pieno: Color = tm["presa"] if preso else tm["futura"]
		P.spicchio(t, c, R_DENTRO, R_FUORI, a - mezzo, a + mezzo, pieno)
		simbolo_tasca(t, livello, c + Vector2.from_angle(a) * (R_DENTRO + R_FUORI) * 0.5, lato,
				tm["presa_segno"] if preso else tm["futura_segno"], pieno,
				tm["presa_ombra"] if preso else tm["futura_ombra"], preso)
	# quella sotto la lancetta esce dalla ruota (anche a meta' giro: esce di quanto e' vicina)
	vicini.sort_custom(func(x: int, y: int) -> bool: return absf(x - v) > absf(y - v))
	for livello in vicini:
		var fuori := 1.0 - absf(livello - v)
		var a := PI + passo * (livello - v)
		var o := c + Vector2.from_angle(a) * 12.0 * fuori
		var chiara := fuori > 0.5
		var preso := livello <= adesso
		var pieno: Color = tm["esce"] if chiara else (tm["presa"] if preso else tm["futura"])
		var dentro := R_DENTRO + 4.0 * fuori
		var oltre := R_FUORI + 36.0 * fuori
		var largo := mezzo + 0.04 * fuori
		P.spicchio(t, o + Vector2(9, 9) * fuori, dentro, oltre, a - largo, a + largo, velo(tm["anello"], fuori))
		P.spicchio(t, o, dentro, oltre, a - largo, a + largo, pieno, velo(P.NERO, fuori), 3.0)
		var dove := o + Vector2.from_angle(a) * (dentro + oltre) * 0.5
		var segno: Color = tm["esce_segno"] if chiara else (tm["presa_segno"] if preso else tm["futura_segno"])
		var ombra: Color = tm["esce_ombra"] if chiara else (tm["presa_ombra"] if preso else tm["futura_ombra"])
		simbolo_tasca(t, livello, dove + Vector2(0, -18) * fuori, lato + 10.0 * fuori, segno, pieno, ombra, preso)
		P.scritta(t, dove + Vector2(-40, 12 + 28 * fuori), str(livello), roundi(18 + 12 * fuori), segno, null,
				HORIZONTAL_ALIGNMENT_CENTER, 80)


func cella(t: CanvasItem, tm: Dictionary, o: Vector2, a: float, mezzo: float, livello: int) -> void:
	# la cella del numero, sull'anello: dove arriva qualcosa cambia colore, come
	# lo zero sulla ruota vera. Oltre il tetto il numero si spegne. Il numero
	# segue il cerchio: sopra con la testa fuori, sotto con la testa dentro
	var speciale := not arrivi_di(livello).is_empty()
	P.spicchio(t, o, R_CELLE, R_ORLO, a - mezzo, a + mezzo, tm["speciale"] if speciale else tm["anello"])
	var colore: Color = tm["speciale_segno"] if speciale else (tm["numero_preso"] if livello <= adesso else tm["numero"])
	if livello > tetto():
		colore = velo(colore, 0.35)
	var giro := a + PI * 0.5 if sin(a) <= 0.0 else a - PI * 0.5
	P.gira(t, o + Vector2.from_angle(a) * (R_CELLE + R_ORLO) * 0.5, rad_to_deg(giro))
	P.scritta(t, Vector2(-40, 9), str(livello), 24 if livello < 100 else 20, colore, null, HORIZONTAL_ALIGNMENT_CENTER, 80)
	P.dritto(t)


func simbolo_tasca(t: CanvasItem, livello: int, c: Vector2, l: float, tinta: Color, fondo: Color, ombra: Color,
		preso: bool) -> void:
	# cosa da' (o ha dato) la tasca: quello che arriva, se arriva qualcosa; se no
	# la statistica scelta, o la strada che si divide della scelta che verra'
	var qui := arrivi_di(livello)
	if not qui.is_empty():
		var primo: Array = qui[0]
		var id := String(primo[1])
		if String(primo[0]) == "passiva":
			S.passiva_timbro(t, id, c, l * 1.05, tinta, fondo, ombra)
		else:
			S.timbro(t, simbolo_di("abilita", id), c, l, tinta, fondo, ombra)
			var grado := int(GameState.abilita_combattimento(id).get("grado", 1))
			if grado > 1:
				S.gradi(t, grado, c + Vector2(0, l * 0.7), l, tinta)
		if qui.size() > 1:
			P.scritta(t, c + Vector2(l * 0.44, -l * 0.34), "+%d" % (qui.size() - 1), 13, tinta)
	elif livello == 1:
		S.rombo(t, c, l, 12, 12, 3.4, tinta)
	elif preso and scelta_di(livello) != "":
		IS.timbro(t, scelta_di(livello), c, l * 1.1, tinta, fondo, ombra)
	elif preso:
		S.rombo(t, c, l, 12, 12, 3.4, tinta)
	else:
		# la scelta che verra', piu' quieta: senza ombra, un colore a meta' fra segno e tasca
		S.disegna(t, "biforca", c, l * 0.78, Color(Color(fondo, 1.0).lerp(Color(tinta, 1.0), 0.6), tinta.a), fondo)


func mozzo(t: CanvasItem, tm: Dictionary, g: int) -> void:
	# il centro: il retino del manifesto, il giro, e il livello enorme
	var c := CENTRO
	t.draw_circle(c, R_MOZZO, tm["mozzo"], true, -1.0, true)
	var centri: Array[Vector2] = []
	var raggi: Array[float] = []
	var passo := 10.0
	var y := -R_MOZZO
	while y <= R_MOZZO:
		var x := -R_MOZZO
		while x <= R_MOZZO:
			var q := Vector2(x + (passo * 0.5 if roundi(y / passo) % 2 == 0 else 0.0), y)
			# i punti crescono verso il basso a destra, come nelle ombre del manifesto
			var quanto := clampf((q.x + q.y) / (R_MOZZO * 1.7) + 0.3, 0.0, 1.0)
			if q.length() < R_MOZZO - 8.0 and quanto > 0.2:
				centri.append(c + q)
				raggi.append(3.9 * quanto * quanto)
			x += passo
		y += passo
	Manifesto.puntini(t, centri, raggi, tm["retino"])
	var giro := "GIRO %s" % ROMANI[mini(g, ROMANI.size() - 1)]
	P.etichetta(t, c + Vector2(-(P.larghezza(giro, 18) + 20.0) * 0.5, -122), giro, 18, tm["accento"],
			tm["mozzo"] if tm["accento"] != tm["mozzo"] else tm["mozzo_numero"])
	# quando il timbro batte il numero rotola: il vecchio cade, il nuovo
	# arriva dall'alto e rimbalza
	var k := clampf((tempo - rullo_a) / 0.5, 0.0, 1.0) if rullo_a >= 0.0 else 1.0
	if k >= 1.0:
		numero_nel_mozzo(t, tm, str(adesso), Vector2.ZERO, 1.0)
		return
	var via := clampf(k * 2.2, 0.0, 1.0)
	if via < 1.0:
		numero_nel_mozzo(t, tm, str(rullo_da), Vector2(0, 150.0 * via * via), 1.0 - via)
	var arriva := clampf((k - 0.2) / 0.8, 0.0, 1.0)
	if arriva > 0.0:
		numero_nel_mozzo(t, tm, str(adesso), Vector2(0, -110.0 * (1.0 - rimbalza(arriva))), clampf(arriva * 3.0, 0.0, 1.0))


static func numero_nel_mozzo(t: CanvasItem, tm: Dictionary, numero: String, spinta: Vector2, alfa: float) -> void:
	var corpo := 150 if numero.length() < 3 else 112
	P.ritagliata(t, CENTRO + spinta + Vector2(-170, 54 if numero.length() < 3 else 40), numero, corpo,
			velo(tm["mozzo_numero"], alfa), P.NERO, 0, velo(tm["mozzo_ombra"], alfa), Vector2(9, 9), null,
			HORIZONTAL_ALIGNMENT_CENTER, 340)


static func legenda(t: CanvasItem) -> void:
	# su un cartellino nero, cosi' si legge su tutti i fondi
	var dove := Vector2(1196, 670)
	Manifesto.poligono(t, P.storta(Rect2(dove + Vector2(-18, -22), Vector2(110, 74)), 0.1), P.NERO)
	S.disegna(t, "biforca", dove + Vector2(4, -6), 18.0, P.CREMA, P.NERO)
	P.scritta(t, dove + Vector2(20, -1), "A SCELTA", 12, P.CREMA, Caratteri.tondo(900))
	S.disegna(t, "flagello", dove + Vector2(4, 17), 18.0, P.CREMA, P.NERO)
	P.scritta(t, dove + Vector2(20, 22), "ABILITÀ", 12, P.CREMA, Caratteri.tondo(900))
	S.passiva(t, "non_ce_tempo", dove + Vector2(4, 40), 18.0, P.CREMA, P.NERO)
	P.scritta(t, dove + Vector2(20, 45), "PASSIVA", 12, P.CREMA, Caratteri.tondo(900))


# --- la lastra a sinistra, con la testata e il contatore dei punti -----------------------------

func lastra(t: CanvasItem) -> void:
	var tm := tema(giro_di(guardato))
	P.lastra(t, PackedVector2Array(LASTRA), P.NERO, P.CREMA, 16.0)
	# il dente della lastra e' la lancetta
	var bordo := lerpf(606.0, 440.0, (CENTRO.y + 20.0) / 760.0) + 14.0
	Manifesto.poligono(t, PackedVector2Array([Vector2(bordo, CENTRO.y - 22), Vector2(bordo + 34, CENTRO.y),
			Vector2(bordo, CENTRO.y + 22)]), P.CREMA)
	pannello(t, guardato)
	testata(t, tm["campo"] == "nero")


func testata(t: CanvasItem, destra_su_nero: bool) -> void:
	# in alto a sinistra INDIETRO e la squadra, una linguetta per personaggio
	# (l'hype e' di tutti: si sceglie su chi spenderlo); a destra il titolo
	var largo := P.etichetta(t, Vector2(16, 12), "INDIETRO", 20, P.CREMA, P.NERO)
	indietro_qui = Rect2(16, 12, largo, 27)
	var x := 16.0 + largo + 16.0
	linguette.clear()
	for id_classe in squadra:
		var testo := "%s · LV %d" % [nome_di(id_classe).to_upper(), GameState.livello_di(id_classe)]
		if id_classe == chi:
			testo = "%s · LV %d" % [nome_di(id_classe).to_upper(), adesso]
			var quanto := P.etichetta(t, Vector2(x, 14), testo, 17, P.ARANCIO, P.NERO, P.CREMA)
			linguette.append(Rect2(x, 10, quanto, 30))
			x += quanto + 20.0
		else:
			P.scritta(t, Vector2(x + 6, 37), testo, 17, P.CREMA)
			linguette.append(Rect2(x, 10, P.larghezza(testo, 17) + 12.0, 30))
			x += P.larghezza(testo, 17) + 32.0
	var titolo := "CRESCITA"
	var lungo := P.larghezza(titolo, 40) + 44.0
	P.etichetta(t, Vector2(1262 - lungo, 8), titolo, 40, P.CREMA if destra_su_nero else P.NERO,
			P.NERO if destra_su_nero else P.CREMA, P.ARANCIO)


func gettoni(t: CanvasItem) -> void:
	# i punti da spendere: un rombo pieno per punto, e quello che si sta
	# riempiendo. Quando prendi, l'ultimo pieno parte (punto_che_vola) e quello
	# che si riempie scivola al suo posto
	var r := 15.0
	var partito := prendi_a >= 0.0 and livello_nuovo == 0
	var quanti := punti_prima if partito else GameState.punti_abilita_liberi()
	var resto := GameState.hype_disponibile % per_punto()
	var scorre := frena(clampf((tempo - prendi_a - VOLA) / 0.25, 0.0, 1.0)) if partito else 0.0
	var pieni := quanti - 1 if partito else quanti
	for i in pieni:
		P.gettone(t, GETTONI + Vector2(PASSO_GETTONE * i, 0), r, 1.0, P.CREMA, Color(P.CREMA, 0.14))
	if partito and r * (1.0 - scorre) > 1.5:
		P.gettone(t, GETTONI + Vector2(PASSO_GETTONE * pieni, 0), r * (1.0 - scorre), 0.0, P.CREMA, Color(P.CREMA, 0.14))
	var dove_resto := float(pieni) + (1.0 - scorre if partito else 0.0)
	P.gettone(t, GETTONI + Vector2(PASSO_GETTONE * dove_resto, 0), r, float(resto) / per_punto(), P.CREMA,
			Color(P.CREMA, 0.14))
	var x := GETTONI.x + PASSO_GETTONE * (dove_resto + 1.0) - 4.0
	var restano := quanti - 1 if partito else quanti
	P.scritta(t, Vector2(x, GETTONI.y + 6), "%d %s" % [restano, "PUNTO" if restano == 1 else "PUNTI"], 18, P.CREMA)
	P.scritta(t, Vector2(x, GETTONI.y + 26), "%s/%s hype al prossimo" % [migliaia(resto), migliaia(per_punto())], 13,
			P.CREMA, Caratteri.tondo(900))


func pannello(t: CanvasItem, livello: int) -> void:
	# quello che dice la lastra cambia con la tasca sotto la lancetta
	var stato := stato_della_tasca(livello)
	gettoni(t)
	pannello_testa(t, livello, stato)
	if stato == "chiuso":
		pannello_chiuso(t, giro_di(livello))
		return
	P.scritta(t, Vector2(36, 390), "COSA TI HA DATO" if stato == "preso" else "COSA TI DÀ", 14, P.CARTA, Caratteri.tondo(900))
	var y := pannello_strade(t, livello, stato, 404.0)
	pannello_arrivo(t, livello, stato, y)
	pannello_piede(t, stato)


func pannello_testa(t: CanvasItem, livello: int, stato: String) -> void:
	# sopra: arrivi al / gia' preso / piu' avanti, il numero grande, e quanti
	var g := giro_di(livello)
	var sopra_scritto := {"prossimo": "ARRIVI AL", "preso": "GIÀ PRESO", "dopo": "PIÙ AVANTI", "chiuso": "HAI CHIUSO IL GIRO AL"}
	P.scritta(t, Vector2(36, 172), String(sopra_scritto[stato]), 18, P.CARTA)
	var numero := str(livello)
	var corpo := 170 if numero.length() < 3 else 128
	var arancio := stato in ["prossimo", "chiuso"]
	P.ritagliata(t, Vector2(30, 348), numero, corpo, P.ARANCIO if arancio else P.CREMA, P.NERO, 0,
			P.ARANCIO_SCURO if arancio else P.TRATTO, Vector2(10, 10))
	var x := 40.0 + P.larghezza(numero, corpo)
	P.scritta(t, Vector2(x, 226), "LIVELLO", 34, P.CREMA)
	var quanti := {"prossimo": "%d DI %d · 1 PUNTO" % [livello - primo_del_giro(g) + 1, spicchi_del_giro(g)],
			"preso": "%d DI %d" % [livello - primo_del_giro(g) + 1, spicchi_del_giro(g)],
			"dopo": "SERVONO %d PUNTI · NE HAI %d" % [livello - adesso, GameState.punti_abilita_liberi()],
			"chiuso": detto_del_giro_chiuso(g)}
	P.scritta(t, Vector2(x, 254), String(quanti[stato]), 15, P.ARANCIO if stato == "chiuso" else P.CARTA,
			Caratteri.tondo(900))


func detto_del_giro_chiuso(g: int) -> String:
	if adesso < tetto():
		return "%s COMPLETO" % tema(g)["nome"]
	return "TETTO DELLA BETA" if beta() else "IL MASSIMO"


func pannello_strade(t: CanvasItem, livello: int, stato: String, y: float) -> float:
	# le due strade di quella tasca, o quella presa; restituisce dove continuare
	if livello == 1:
		P.scritta(t, Vector2(36, y + 26), "IL PUNTO DI PARTENZA", 22, P.CREMA)
		return y + 60.0
	var due := coppia(livello)
	var scelta_qui := scelta_di(livello) if stato == "preso" else ""
	if scelta_qui != "":
		IS.timbro(t, scelta_qui, Vector2(56, y + 20), 34.0, P.CREMA, P.NERO, P.ARANCIO)
		P.scritta(t, Vector2(90, y + 26), "PIÙ " + String(PAROLE.get(scelta_qui, scelta_qui.to_upper())), 22, P.CREMA)
		var lasciata := due[1] if due[0] == scelta_qui else due[0]
		P.scritta(t, Vector2(90, y + 46), "l'hai scelta tu, invece di %s" % nome_stat(lasciata).to_lower(), 14,
				P.CARTA, Caratteri.tondo(700))
	elif stato == "preso":
		S.rombo(t, Vector2(56, y + 18), 34.0, 12, 12, 3.4, P.CREMA)
		P.scritta(t, Vector2(90, y + 26), "UN LIVELLO", 22, P.CREMA)
		P.scritta(t, Vector2(90, y + 46), "venuto prima della ruota", 14, P.CARTA, Caratteri.tondo(700))
	else:
		S.disegna(t, "biforca", Vector2(56, y + 18), 34.0, P.CREMA, P.NERO)
		var detta := "PIÙ %s O PIÙ %s" % [PAROLE.get(due[0], due[0]), PAROLE.get(due[1], due[1])]
		P.scritta(t, Vector2(90, y + 26), detta, P.corpo_che_entra(detta, 22, 390.0), P.CREMA)
		var come := "%+d %s o %+d %s: la scegli quando lo prendi" % [Crescita.quanto(due[0]),
				nome_stat(due[0]).to_lower(), Crescita.quanto(due[1]), nome_stat(due[1]).to_lower()]
		P.scritta(t, Vector2(90, y + 46), come, P.corpo_che_entra(come, 14, 380.0, Caratteri.tondo(700)), P.CARTA,
				Caratteri.tondo(700))
	return y + 70.0


func pannello_arrivo(t: CanvasItem, livello: int, stato: String, y: float) -> void:
	# quello che arriva comunque a quel livello
	var qui := arrivi_di(livello)
	if qui.is_empty():
		return
	var primo: Array = qui[0]
	var tipo := String(primo[0])
	var id := String(primo[1])
	var dati := dati_di(tipo, id)
	if tipo == "passiva":
		S.passiva(t, id, Vector2(56, y + 30), 50.0, P.ARANCIO, P.NERO)
	else:
		P.rombo(t, Vector2(56, y + 30), 25.0, P.ARANCIO)
		S.disegna(t, simbolo_di(tipo, id), Vector2(56, y + 30), 28.0, P.NERO, P.ARANCIO)
	var cosa := ("ARRIVA UNA PASSIVA" if tipo == "passiva" else "ARRIVA UN'ABILITÀ") if stato != "preso" \
			else ("PASSIVA" if tipo == "passiva" else "ABILITÀ")
	P.etichetta(t, Vector2(88, y), cosa, 12, P.ARANCIO, P.NERO)
	var nome := String(dati.get("nome", id)).to_upper()
	P.scritta(t, Vector2(90, y + 44), nome, P.corpo_che_entra(nome, 22, 380.0), P.CREMA)
	P.a_capo(t, Rect2(90, y + 52, 370, 56), String(dati.get("descrizione", "")), 13, P.CARTA, null,
			HORIZONTAL_ALIGNMENT_LEFT, 3)
	if qui.size() > 1:
		var altri := PackedStringArray()
		for voce: Array in qui.slice(1):
			altri.append(String(dati_di(String(voce[0]), String(voce[1])).get("nome", voce[1])))
		P.scritta(t, Vector2(90, y + 124), "E ANCHE: " + ", ".join(altri).to_upper(), 14, P.ARANCIO, Caratteri.tondo(900))


func pannello_piede(t: CanvasItem, stato: String) -> void:
	# in fondo: PRENDI se si puo', se no perche' no
	var testo := testo_prendi()
	if stato == "prossimo" and testo.begins_with("PRENDI"):
		P.etichetta(t, PRENDI_A, testo, 26, P.ARANCIO, P.NERO, P.CREMA)
	elif stato in ["prossimo", "dopo"]:
		P.etichetta(t, PRENDI_A + Vector2(0, 4), testo, 20, P.SPENTO, P.TRATTO)


func pannello_chiuso(t: CanvasItem, g: int) -> void:
	# il giro chiuso: nella beta, al tetto, ci si ferma; nel gioco intero si passa al prossimo
	P.scritta(t, Vector2(36, 390), "E ADESSO", 14, P.CARTA, Caratteri.tondo(900))
	if adesso >= tetto():
		if beta():
			Sagome.lucchetto(t, Vector2(56, 424), 34.0, P.CREMA)
			P.scritta(t, Vector2(90, 430), "IL GIRO DOPO (%d–%d)" % [primo_del_giro(g + 1), ultimo_del_giro(g + 1)], 22, P.CREMA)
			P.scritta(t, Vector2(90, 450), "arriva col gioco intero: nella beta il %d è il tetto" % tetto(), 14, P.CARTA,
					Caratteri.tondo(700))
			P.gettone(t, Vector2(56, 504), 14.0, 1.0, P.CREMA, Color(P.CREMA, 0.14))
			P.scritta(t, Vector2(90, 500), "L'HYPE NON SI BUTTA", 22, P.CREMA)
			P.scritta(t, Vector2(90, 520), "i punti restano: li spendi sugli altri, o quando arriva", 14, P.CARTA,
					Caratteri.tondo(700))
		else:
			S.disegna(t, "biforca", Vector2(56, 424), 34.0, P.CREMA, P.NERO)
			P.scritta(t, Vector2(90, 430), "LA RUOTA È TUTTA TUA", 22, P.CREMA)
			P.scritta(t, Vector2(90, 450), "%d livelli: non c'è un giro dopo" % tetto(), 14, P.CARTA, Caratteri.tondo(700))
		P.etichetta(t, PRENDI_A + Vector2(0, 4), testo_prendi(), 20, P.SPENTO, P.TRATTO)
		return
	var dopo_questo := tema(g + 1)
	P.rombo(t, Vector2(56, 424), 16.0, P.ARANCIO, P.CREMA, 2.0)
	P.scritta(t, Vector2(90, 430), "SI RICOMINCIA DAL %d" % primo_del_giro(g + 1), 22, P.CREMA)
	P.scritta(t, Vector2(90, 450), "%s, con un altro aspetto" % String(dopo_questo["nome"]).to_lower(), 14, P.CARTA,
			Caratteri.tondo(700))
	P.etichetta(t, PRENDI_A, testo_prendi(), 26, P.ARANCIO, P.NERO, P.CREMA)
