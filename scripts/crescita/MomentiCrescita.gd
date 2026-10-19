extends "res://scripts/crescita/MotoCrescita.gd"

# I TRE MOMENTI A TUTTO SCHERMO della salita (la B, approvata coi suoi film):
#   il bivio   un punto, due strade. Lo schermo tagliato in due; la strada
#              scelta si allarga e il taglio si sposta. Quello che arriva
#              comunque attraversa il taglio, sulla fascia in basso. Presa la
#              strada, il taglio spazza via l'altra
#   il salto   il livello enorme, e la carta del perche', riga per riga
#   la carta   quello che arriva, sui raggi del luna park

func disegna_bivio(t: CanvasItem) -> void:
	var batte := 0.5 + 0.5 * sin(tempo * 2.0)
	var livello := livello_nuovo if livello_nuovo > 0 else adesso + 1
	var due := coppia(livello)
	var chiude := frena(dopo(preso_a, 0.0, 0.5))
	var entra_qui := -900.0 * (1.0 - frena(entrata(0.0, 0.42)))   # entrando, il nero arriva da sinistra
	var alto := taglio_del_bivio()
	var taglio := lerpf(alto, -200.0 if a_destra else 1480.0, chiude) + entra_qui
	var basso := taglio - 120.0
	t.draw_rect(Rect2(0, 0, 1280, 720), P.CREMA)
	Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.NERO, 0.07), Vector2(1.0, 1.0))
	IS.disegna(t, due[1], Vector2(1010, 450), 640.0, P.CREMA.lerp(P.NERO, 0.06), P.CREMA)
	Manifesto.poligono(t, PackedVector2Array([Vector2(-20, -20), Vector2(taglio, -20), Vector2(basso, 740), Vector2(-20, 740)]),
			P.NERO)
	IS.disegna(t, due[0], Vector2(taglio - 410, 470), 600.0, P.NERO.lerp(P.CREMA, 0.07), P.NERO)
	Manifesto.poligono(t, PackedVector2Array([Vector2(taglio, -20), Vector2(taglio + 14, -20), Vector2(basso + 14, 740),
			Vector2(basso, 740)]), P.ARANCIO)
	# presa la strada, quella scelta va al margine e l'altra se ne va col taglio
	var sinistra := 54.0 + (taglio - alto if a_destra else entra_qui)
	var destra := lerpf(alto + 60.0, 54.0, chiude) + entra_qui if a_destra else taglio + 60.0
	strada(t, Vector2(sinistra, 0), due[0], 1.0 - peso, true, alto - 150.0)
	strada(t, Vector2(destra, 0), due[1], peso, false, 1250.0 - destra)
	var c := Vector2(taglio - 60.0, 362)
	var r := (66.0 + 4.0 * batte) * (1.0 - chiude)
	if r > 1.0:
		P.rombo(t, c + Vector2(8, 8), r, P.NERO)
		P.rombo(t, c, r, P.ARANCIO, P.NERO, 5.0)
		P.scritta(t, c + Vector2(-60, 16), "1", roundi(58 * r / 66.0), P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 120)
		P.scritta(t, c + Vector2(-60, 40), "PUNTO", 14, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 120)
	fascia_comunque(t, livello)
	var titolo := Color(1, 1, 1, 1.0 - (chiude if not a_destra else 0.0))
	var x := alto + 60.0
	P.etichetta(t, Vector2(x, 40), "UN PUNTO, DUE STRADE", 34, P.NERO * titolo, P.CREMA * titolo, P.ARANCIO * titolo)
	P.scritta(t, Vector2(x + 4, 124), "Il punto porta %s al livello %d. La strada la scegli tu." % [nome_di(chi), livello], 16,
			P.NERO * titolo, Caratteri.tondo(800))
	presa(t, due[1] if a_destra else due[0], livello)


func strada(t: CanvasItem, dove: Vector2, stat: String, scelta: float, su_nero: bool, spazio: float) -> void:
	# una delle due: la parola grande, quanto da', cosa vuol dire, da quanto a quanto
	var inchiostro := P.CREMA if su_nero else P.NERO
	var piano := P.CARTA if su_nero else Color(P.NERO, 0.75)
	var quanto := Crescita.quanto(stat)
	var prima := int(valori_bivio.get(stat, valore(stat)))
	var x := dove.x
	if scelta > 0.5:
		P.etichetta(t, Vector2(x, 198), "◆ LA SCEGLI", 16, P.ARANCIO, P.NERO, P.CREMA if su_nero else P.NERO)
	P.scritta(t, Vector2(x, 264), "PIÙ", 44, inchiostro)
	var parola := String(PAROLE.get(stat, stat.to_upper()))
	var corpo := P.corpo_che_entra(parola, roundi(lerpf(104.0, 150.0, scelta)), spazio)
	P.ritagliata(t, Vector2(x - 6, 396), parola, corpo, inchiostro, P.NERO, 0, Color(P.ARANCIO, scelta), Vector2(8, 8))
	P.scritta(t, Vector2(x, 444), "%+d %s" % [quanto, nome_stat(stat).to_upper()], 30, P.ARANCIO if su_nero else P.ARANCIO_SCURO)
	P.scritta(t, Vector2(x, 472), detto(stat), 16, piano, Caratteri.tondo(700))
	P.scritta(t, Vector2(x, 520), "%d → %d" % [prima, prima + quanto], 34, inchiostro)
	var fondo := maxf((prima + quanto) * 1.6, 1.0)
	var barra := Rect2(x + 2, 534, 300, 14)
	P.barretta(t, barra, (prima + quanto) / fondo, P.ARANCIO, Color(inchiostro, 0.15))
	P.barretta(t, barra, prima / fondo, inchiostro)


func fascia_comunque(t: CanvasItem, livello: int) -> void:
	# quello che arriva comunque a quel livello: attraversa il taglio
	var qui := arrivi_di(livello)
	if qui.is_empty():
		return
	var arriva: Array = qui[0]
	var tipo := String(arriva[0])
	var dati := dati_di(tipo, String(arriva[1]))
	var entra_qui := frena(entrata(0.35, 0.4))
	P.gira(t, Vector2(-20 - 1400.0 * (1.0 - entra_qui), 604), -1.5)
	t.draw_rect(Rect2(8, 8, 1340, 50), P.NERO)
	t.draw_rect(Rect2(0, 0, 1340, 50), P.ARANCIO)
	t.draw_rect(Rect2(0, 0, 1340, 50), P.NERO, false, 3.0)
	var x := 74.0 + P.scritta_larga(t, Vector2(74, 34), "E IN OGNI CASO, AL LIVELLO %d, ARRIVA" % livello, 20, P.NERO)
	P.rombo(t, Vector2(x + 30, 25), 20.0, P.NERO)
	S.disegna(t, simbolo_di(tipo, String(arriva[1])), Vector2(x + 30, 25), 26.0, P.ARANCIO, P.NERO)
	x += 62.0 + P.scritta_larga(t, Vector2(x + 62, 36), String(dati.get("nome", "")).to_upper(), 28, P.NERO)
	var che_cosa := "nuova passiva: " if tipo == "passiva" else "nuova abilità: "
	P.scritta(t, Vector2(x + 16, 33), che_cosa + String(dati.get("descrizione", "")).get_slice(".", 0).to_lower(),
			15, P.NERO, Caratteri.tondo(800))
	P.dritto(t)


func presa(t: CanvasItem, stat: String, livello: int) -> void:
	# presa la strada: il timbro col livello nuovo, nel posto lasciato dall'altra
	var timbro := dopo(preso_a, 0.45, 0.35)
	if timbro <= 0.0:
		return
	var pieno := P.NERO if a_destra else P.CREMA
	P.gira(t, Vector2(940, 336), -7.0, rimbalza(timbro))
	P.cartoncino(t, Rect2(-190, -90, 380, 170), pieno, 0.0 if a_destra else 5.0, P.OMBRA if a_destra else Vector2(10, 10))
	P.scritta(t, Vector2(-190, -10), "LIVELLO %d" % livello, 64, P.CREMA if a_destra else P.NERO, null,
			HORIZONTAL_ALIGNMENT_CENTER, 380)
	P.scritta(t, Vector2(-190, 48), "%+d %s" % [Crescita.quanto(stat), nome_stat(stat).to_upper()], 30,
			P.ARANCIO if a_destra else P.ARANCIO_SCURO, null, HORIZONTAL_ALIGNMENT_CENTER, 380)
	P.dritto(t)


# --- il salto: il livello nuovo, e il perche' ---------------------------------------------------

func disegna_salto(t: CanvasItem) -> void:
	# il livello enorme a sinistra (il vecchio cade, il nuovo arriva e trema),
	# a destra la carta del perche', una riga alla volta
	var p := tempo - momento_a
	P.lastra(t, PackedVector2Array([Vector2(-20, -20), Vector2(560, -20), Vector2(420, 740), Vector2(-20, 740)]), P.NERO,
			P.CREMA, 16.0)
	retino_a_salire(t, Rect2(0, 330, 470, 390), Color(P.ARANCIO, 0.5))
	P.etichetta(t, Vector2(36 + entra_da_sinistra(p, 0.05), 40), nome_di(chi).to_upper(), 22, P.ARANCIO, P.NERO, P.CREMA)
	P.scritta(t, Vector2(40 + entra_da_sinistra(p, 0.12), 140), "SALE AL", 30, P.CARTA)
	P.scritta(t, Vector2(40 + entra_da_sinistra(p, 0.2), 208), "LIVELLO", 72, P.CREMA)
	var numero := str(livello_nuovo)
	var corpo := 430 if numero.length() < 2 else (300 if numero.length() < 3 else 210)
	var cade := clampf((p - 0.5) / 0.28, 0.0, 1.0)
	if cade < 1.0:
		P.ritagliata(t, Vector2(26, 610 + 760.0 * cade * cade), str(livello_nuovo - 1), corpo, P.CREMA, P.NERO, 14, P.TRATTO,
				Vector2(16, 16))
	var arriva := clampf((p - 0.62) / 0.4, 0.0, 1.0)
	if arriva > 0.0:
		var trema := Vector2(sin(p * 83.0), cos(p * 71.0)) * 10.0 * (1.0 - clampf((p - 1.02) / 0.3, 0.0, 1.0)) \
				if p >= 1.02 else Vector2.ZERO
		P.ritagliata(t, Vector2(26, 610 - 760.0 * (1.0 - rimbalza(arriva))) + trema, numero, corpo, P.ARANCIO, P.NERO,
				14, P.CREMA, Vector2(16, 16))
		raggi_del_colpo(t, Vector2(150, 455), clampf((p - 1.02) / 0.45, 0.0, 1.0), 170.0, P.CREMA)
	P.scritta(t, Vector2(26 + P.larghezza(numero, corpo) + 14.0, 600), "DI %d" % tetto(), 26,
			velo(P.CARTA, clampf((p - 1.1) / 0.3, 0.0, 1.0)))
	# la carta del perche', da destra
	# la carta del perche', da destra: alta quanto le sue righe
	var righe := righe_della_salita()
	var alto := 72.0
	for voce in righe:
		alto += riga_cresciuta(t, voce, Vector2.ZERO, 580.0, 0.0, 0.0, 0.0) + 4.0
	var foglio := rimbalza(clampf((p - 0.4) / 0.55, 0.0, 1.0))
	P.gira(t, Vector2(598 + 820.0 * (1.0 - foglio), 92), lerpf(-16.0, -2.5, foglio))
	P.cartoncino(t, Rect2(0, 0, 640, maxf(alto, 200.0)), P.CREMA, 5.0, Vector2(12, 12), true)
	P.etichetta(t, Vector2(22, -22), "COSA HAI FATTO, E COSA TI HA DATO", 18, P.NERO, P.CREMA)
	var y := 52.0
	var i := 0
	for voce in righe:
		# ogni riga: compare, crescono le azioni, poi (se c'e') la strada
		var da := 1.15 + 0.5 * i
		var comparsa := clampf((p - da) / 0.22, 0.0, 1.0)
		var azioni_fatte := frena(clampf((p - da - 0.12) / 0.4, 0.0, 1.0))
		var strada_fatta := frena(clampf((p - da - 0.5) / 0.3, 0.0, 1.0))
		y += riga_cresciuta(t, voce, Vector2(30, y), 580.0, azioni_fatte, strada_fatta, comparsa) + 4.0
		i += 1
	P.dritto(t)
	if carte.is_empty():
		return
	var fascia := frena(clampf((p - 3.4) / 0.35, 0.0, 1.0))
	if fascia <= 0.0:
		return
	var arriva_poi: Array = carte[0]
	var dati := dati_di(String(arriva_poi[0]), String(arriva_poi[1]))
	P.gira(t, Vector2(760 + 700.0 * (1.0 - fascia), 618), -2.5)
	t.draw_rect(Rect2(6, 6, 480, 44), P.NERO)
	t.draw_rect(Rect2(0, 0, 480, 44), P.ARANCIO)
	t.draw_rect(Rect2(0, 0, 480, 44), P.NERO, false, 3.0)
	var x := 16.0 + P.scritta_larga(t, Vector2(16, 31), "POI ARRIVA", 20, P.NERO)
	P.rombo(t, Vector2(x + 26, 22), 17.0, P.NERO)
	S.disegna(t, simbolo_di(String(arriva_poi[0]), String(arriva_poi[1])), Vector2(x + 26, 22), 22.0, P.ARANCIO, P.NERO)
	var nome := String(dati.get("nome", arriva_poi[1])).to_upper() + "  ▸"
	P.scritta(t, Vector2(x + 52, 32), nome, P.corpo_che_entra(nome, 24, 480.0 - x - 64.0), P.NERO)
	P.dritto(t)


static func entra_da_sinistra(p: float, da: float) -> float:
	return -460.0 * (1.0 - frena(clampf((p - da) / 0.3, 0.0, 1.0)))


static func retino_a_salire(t: CanvasItem, r: Rect2, tinta: Color) -> void:
	# il retino del manifesto, coi punti che crescono verso il basso a sinistra
	var centri: Array[Vector2] = []
	var raggi: Array[float] = []
	var passo := 12.0
	var y := r.position.y
	while y <= r.end.y:
		var x := r.position.x + (passo * 0.5 if roundi(y / passo) % 2 == 0 else 0.0)
		while x <= r.end.x:
			var quanto := clampf(1.0 - (x - r.position.x) / r.size.x * 0.8 + (y - r.end.y) / r.size.y * 0.9, 0.0, 1.0)
			if quanto > 0.15:
				centri.append(Vector2(x, y))
				raggi.append(4.6 * quanto * quanto)
			x += passo
		y += passo
	Manifesto.puntini(t, centri, raggi, tinta)


static func riga_cresciuta(t: CanvasItem, voce: Dictionary, dove: Vector2, largo: float, azioni_fatte: float,
		strada_fatta: float, comparsa: float) -> float:
	# una statistica cresciuta: l'icona, il nome, da quanto a quanto, la
	# barretta in tre pezzi (quello che avevi, grigio; le azioni, nel colore del
	# testo; la strada, arancio) e il perche', negli stessi colori. Restituisce
	# quanto e' alta: sempre la stessa, anche a meta', cosi' la colonna non salta
	var inchiostro := P.NERO
	var grigio := P.CREMA.lerp(P.NERO, 0.3)
	var arancio := P.ARANCIO_SCURO
	var chiave := String(voce["stat"])
	var prima := int(voce["prima"])
	var scelta := int(voce["scelta"])
	var fatte := int(voce["fatte"])
	var lato := 34.0
	var x := dove.x + lato + 12.0
	var y := dove.y + 56.0
	var corpo_perche := 15
	var testo := "%+d per %s" % [fatte, String(voce["perche"])] if String(voce["perche"]) != "" else "%+d" % fatte
	var spazio := dove.x + largo - x
	var righe := 1 if P.larghezza(testo, corpo_perche, Caratteri.tondo(800)) <= spazio else 2
	var alto := y - dove.y + 4.0 + (corpo_perche + 4.0) * ((1 if scelta > 0 else 0) + (righe if fatte > 0 else 0))
	if comparsa <= 0.0:
		return alto
	if comparsa > 0.2:
		IS.timbro(t, chiave, dove + Vector2(lato * 0.5, 2), lato * rimbalza(comparsa), inchiostro, P.CREMA, P.ARANCIO)
	P.scritta(t, Vector2(x, dove.y + 10), nome_stat(chiave).to_upper(), 24, velo(inchiostro, comparsa))
	var adesso_vale := prima + roundi(fatte * azioni_fatte) + roundi(scelta * strada_fatta)
	P.scritta(t, Vector2(dove.x, dove.y + 12), "%d → %d" % [prima, adesso_vale], 30, velo(inchiostro, comparsa), null,
			HORIZONTAL_ALIGNMENT_RIGHT, largo)
	var barra := Rect2(x, dove.y + 22, dove.x + largo - x, 10)
	var fondo := maxf((prima + scelta + fatte) * 1.25, 1.0)
	P.barretta(t, barra, (prima + scelta * strada_fatta + fatte * azioni_fatte) / fondo, arancio,
			Color(inchiostro, 0.12 * comparsa))
	P.barretta(t, barra, (prima + fatte * azioni_fatte) / fondo, inchiostro)
	P.barretta(t, barra, prima / fondo, grigio)
	if scelta > 0:
		P.scritta(t, Vector2(x, y), "%+d la strada che hai preso" % scelta, corpo_perche, velo(arancio, strada_fatta),
				Caratteri.tondo(900))
		y += corpo_perche + 4.0
	if fatte > 0:
		P.a_capo(t, Rect2(x, y - corpo_perche, spazio, 40), testo, corpo_perche, velo(inchiostro, azioni_fatte),
				Caratteri.tondo(800), HORIZONTAL_ALIGNMENT_LEFT, 2)
	return alto


# --- la carta: quello che arriva -----------------------------------------------------------------

func disegna_carta(t: CanvasItem) -> void:
	# i raggi girano piano, la carta sale dal basso girando, batte (un lampo), e
	# un riflesso la attraversa
	if carte.is_empty():
		return
	var p := tempo - momento_a
	var voce: Array = carte[mini(carta, carte.size() - 1)]
	var tipo := String(voce[0])
	raggiera(t, Vector2(640, 380), 28, P.BRUNO, P.NERO, p * 0.12)
	P.scritta(t, Vector2(46 + entra_da_sinistra(p, 0.25), 300), "ARRIVA", 62, P.CREMA)
	P.ritagliata(t, Vector2(46 + entra_da_sinistra(p, 0.33), 362), "UNA PASSIVA" if tipo == "passiva" else "UN'ABILITÀ", 46,
			P.ARANCIO, P.NERO, 10, P.NERO, Vector2(5, 5))
	P.scritta(t, Vector2(48 + entra_da_sinistra(p, 0.41), 398), "al livello %d, con qualunque strada" % livello_nuovo, 16,
			P.CARTA, Caratteri.tondo(800))
	var vola := rimbalza(clampf((p - 0.15) / 0.55, 0.0, 1.0))
	carta_che_arriva(t, voce, Vector2(650, lerpf(1120.0, 384.0, vola)), lerpf(26.0, -4.0, vola), lerpf(0.7, 1.0, vola),
			clampf((p - 0.95) / 0.55, 0.0, 1.0))
	var lampo := clampf((p - 0.7) / 0.2, 0.0, 1.0)
	if lampo > 0.0 and lampo < 1.0:
		t.draw_rect(Rect2(0, 0, 1280, 720), Color(P.CREMA, 0.22 * (1.0 - lampo)))
	var destra := clampf((p - 1.1) / 0.3, 0.0, 1.0)
	P.scritta(t, Vector2(916, 300), "DOVE LA TROVI", 14, velo(P.CARTA, destra), Caratteri.tondo(900))
	var dove := "Lavora da sola, da adesso." if tipo == "passiva" \
			else "In combattimento, fra le abilità di %s. Da adesso c'è sempre." % nome_di(chi)
	P.a_capo(t, Rect2(916, 308, 330, 80), dove, 18, velo(P.CREMA, destra), Caratteri.tondo(800))
	var ancora := clampf((p - 1.3) / 0.3, 0.0, 1.0)
	P.scritta(t, Vector2(916, 420), "PERCHÉ È ARRIVATA", 14, velo(P.CARTA, ancora), Caratteri.tondo(900))
	P.a_capo(t, Rect2(916, 428, 330, 80), "Non si sceglie e non costa punti: arriva da sola, al suo livello.", 18,
			velo(P.CREMA, ancora), Caratteri.tondo(800))
	if carte.size() > 1:
		P.scritta(t, Vector2(916, 560), "%d DI %d" % [carta + 1, carte.size()], 18, velo(P.ARANCIO, destra))


static func raggiera(t: CanvasItem, c: Vector2, quanti: int, chiaro: Color, scuro: Color, giro := 0.0) -> void:
	# i raggi dei manifesti del luna park, dietro a quello che arriva
	t.draw_rect(Rect2(0, 0, 1280, 720), scuro)
	var passo := TAU / quanti
	for i in quanti:
		if i % 2 == 1:
			Manifesto.poligono(t, PackedVector2Array([c, c + Vector2.from_angle(giro + passo * i) * 1700.0,
					c + Vector2.from_angle(giro + passo * (i + 1)) * 1700.0]), chiaro)


static func virgola(x: float) -> String:
	return ("%.1f" % x).trim_suffix(".0").replace(".", ",")


static func carta_che_arriva(t: CanvasItem, voce: Array, c: Vector2, gradi: float, quanto_grande: float,
		lucido: float) -> void:
	# l'abilita' o la passiva, come una carta: il simbolo, il nome, cosa fa, e
	# in fondo cosa costa. "lucido", fra 0 e 1: il riflesso che la attraversa
	var tipo := String(voce[0])
	var id := String(voce[1])
	var dati := dati_di(tipo, id)
	P.gira(t, c, gradi, quanto_grande)
	# il bordo chiaro, come un adesivo ritagliato: sul nero la carta resta intera
	t.draw_rect(Rect2(-192, -242, 412, 512), P.NERO)
	t.draw_rect(Rect2(-206, -256, 412, 512), P.CREMA)
	P.cartoncino(t, Rect2(-200, -250, 400, 500), P.ARANCIO, 6.0, Vector2.ZERO)
	t.draw_rect(Rect2(-182, -232, 364, 410), Color(P.NERO, 0.5), false, 2.0)
	P.etichetta(t, Vector2(-186, -282), "NUOVA PASSIVA" if tipo == "passiva" else "NUOVA ABILITÀ", 22, P.NERO, P.CREMA, P.CREMA)
	P.rombo(t, Vector2(10, -78), 108.0, P.NERO)
	P.rombo(t, Vector2(0, -88), 108.0, P.CREMA, P.NERO, 6.0)
	if tipo == "passiva":
		S.passiva_timbro(t, id, Vector2(0, -88), 150.0, P.NERO, P.CREMA, P.ARANCIO)
	else:
		S.timbro(t, simbolo_di(tipo, id), Vector2(0, -88), 140.0, P.NERO, P.CREMA, P.ARANCIO)
	var nome := String(dati.get("nome", id)).to_upper()
	P.ritagliata(t, Vector2(-200, 92), nome, P.corpo_che_entra(nome, 66, 360.0), P.CREMA, P.NERO, 12, P.NERO, Vector2(6, 6),
			null, HORIZONTAL_ALIGNMENT_CENTER, 400)
	P.a_capo(t, Rect2(-172, 110, 344, 70), String(dati.get("descrizione", "")), 17, P.NERO, Caratteri.tondo(800),
			HORIZONTAL_ALIGNMENT_CENTER, 3)
	t.draw_rect(Rect2(-200, 190, 400, 60), P.NERO)
	var costo := "PASSIVA" if tipo == "passiva" else ("COSTA %d AURA" % int(dati.get("aura", 0)) if int(dati.get("aura", 0)) > 0
			else "SENZA COSTO")
	P.scritta(t, Vector2(-200, 216), costo, 20, P.ARANCIO, null, HORIZONTAL_ALIGNMENT_CENTER, 400)
	var sotto_costo := "da adesso lavora da sola" if tipo == "passiva" else "si usa in combattimento"
	if dati.has("moltiplicatore_pieno") and dati.has("moltiplicatore_vuoto"):
		sotto_costo = "×%s a vita piena · ×%s quasi a terra" % [virgola(float(dati["moltiplicatore_pieno"])),
				virgola(float(dati["moltiplicatore_vuoto"]))]
	P.scritta(t, Vector2(-200, 238), sotto_costo, 14, P.CREMA, Caratteri.tondo(800), HORIZONTAL_ALIGNMENT_CENTER, 400)
	if lucido > 0.0 and lucido < 1.0:
		var x := lerpf(-560.0, 420.0, lucido)
		var riflesso := PackedVector2Array([Vector2(x, -260), Vector2(x + 90, -260), Vector2(x - 50, 260), Vector2(x - 140, 260)])
		for pezzo: PackedVector2Array in Geometry2D.intersect_polygons(riflesso, PackedVector2Array([Vector2(-200, -250),
				Vector2(200, -250), Vector2(200, 250), Vector2(-200, 250)])):
			Manifesto.poligono(t, pezzo, Color(1, 1, 1, 0.28))
	P.dritto(t)
