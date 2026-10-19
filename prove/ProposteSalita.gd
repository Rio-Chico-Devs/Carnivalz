extends "res://prove/ProposteCrescita.gd"

# LA SALITA VERA, A FOTOGRAMMI. Provvisorio come ProposteCrescita, da cui prende
# tutti i pezzi: se ne va quando la schermata vera nasce da qui.
#
# Bru: «cominciamo a fare la schermata di crescita vera proponimi dei design e
# ci lavoriamo insieme». Le tre approvate (la roulette, il bivio, le passive)
# dicono cosa c'e'; manca il momento in cui si spende un punto. E' il momento
# in cui succedono quattro cose:
#   - si sale di un livello (un punto = una tasca = un livello);
#   - si sceglie una delle due strade del bivio;
#   - le azioni fatte diventano statistiche, col loro perche'
#     (GameState.applica_crescita_livello: «per i colpi che hai tirato (30)»);
#   - a certi livelli arriva un'abilita' o una passiva.
# Oggi il gioco le dice solo come righe di testo nel resoconto (Resoconto.gd),
# e non c'e' nessun posto dove spendere l'hype.
#
# Tre modi di metterle in fila:
#   a  IL BANCO        uno schermo solo. La ruota resta; la lastra a sinistra
#                      cambia: cosa da' -> le due strade -> cosa e' cresciuto
#   b  TRE TEMPI       ogni momento a tutto schermo: la ruota, il bivio
#                      approvato, il salto (il livello e il perche'),
#                      l'abilita' che arriva
#   c  LA RUOTA GIRA   la ruota al centro e basta: il bivio si apre nel mozzo
#
# I numeri sono veri: il protagonista d'esempio passa dal 7 all'8 (il bivio fra
# vita e attacco, e arriva Vendetta), e le azioni sono quelle del giocatore
# tipo di crescita.json (profilo_giocatore_tipo), convertite come le converte
# il gioco.
#
#   ./prove/proposte_salita.sh       le fotografa in scatti/proposte_salita/
#   nell'editor, F6: destra e sinistra cambiano fotogramma

const FOTOGRAMMI := ["a1_ruota", "a2_strade", "a3_cresciuto", "a4_di_nuovo", "b2_bivio", "b3_salto", "b4_abilita",
		"c1_ruota", "c2_mozzo", "c3_cresciuto", "c4_abilita"]
const CARTELLA_SALITA := "res://scatti/proposte_salita"
const STRADA := "attacco"            # la strada presa nel bivio, come nella foto del bivio
const ARRIVA := "vendetta"           # quello che arriva all'8 (abilita.json)
# il protagonista d'esempio al livello 7, e quanto e' lunga la barretta di ognuna
const PRIMA := {"hp": 110, "attacco": 17, "difesa": 2, "velocita": 4, "intelligenza": 3, "forza_mentale": 3, "fattore": 15}
const FONDO := {"hp": 200.0, "attacco": 40.0, "difesa": 10.0, "velocita": 10.0, "intelligenza": 10.0,
		"forza_mentale": 10.0, "fattore": 40.0}
const SPOSTA := Vector2(-378, 0)     # nella c la ruota sta al centro: da CENTRO a (560, 392)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prepara_arrivi()
	foto = "foto" in OS.get_cmdline_user_args()
	fotogramma(0)
	if not foto:
		return
	DirAccess.make_dir_recursive_absolute(CARTELLA_SALITA)
	for i in FOTOGRAMMI.size():
		fotogramma(i)
		for k in 8:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var immagine := get_viewport().get_texture().get_image()
		immagine.save_png(CARTELLA_SALITA.path_join("%s.png" % FOTOGRAMMI[i]))
		print("FOTOGRAMMA %s" % FOTOGRAMMI[i])
	get_tree().quit()


func _process(delta: float) -> void:
	if foto:
		return
	tempo += delta
	if tavola != null:
		for figlio in tavola.get_children():
			if figlio is Disegno:
				(figlio as Control).queue_redraw()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_right"):
		fotogramma((indice + 1) % FOTOGRAMMI.size())
	elif evento.is_action_pressed("ui_left"):
		fotogramma((indice + FOTOGRAMMI.size() - 1) % FOTOGRAMMI.size())


func fotogramma(quale: int) -> void:
	indice = quale
	schermata = String(FOTOGRAMMI[quale])
	if tavola != null:
		tavola.queue_free()
	tavola = Tavola.su(self)
	inizio = tempo - 20.0          # ogni fotogramma e' a entrata finita
	# prima di prendere il punto il protagonista e' al 7, dopo all'8
	adesso = LIVELLO + 1 if schermata in ["a3_cresciuto", "a4_di_nuovo", "c3_cresciuto", "c4_abilita"] else LIVELLO
	guardato = adesso + 1 if adesso == LIVELLO or schermata == "a4_di_nuovo" else adesso
	vista = float(guardato)
	spinta_vista = 0.0
	beta = false
	cambio_giro_a = -10.0
	cambiato_a = -10.0
	a_destra = true
	peso = 1.0
	preso_a = -1.0
	match schermata.left(1):
		"a":
			strato(disegna_quadrante)
		"b":
			match schermata:
				"b2_bivio":
					strato(disegna_bivio)
				"b3_salto":
					strato(disegna_salto)
				_:
					strato(disegna_arriva)
		_:
			strato(c_sotto)
			strato(c_ruota, SPOSTA)
			strato(c_sopra)
	tasti()
	grana()


func strato(come_si_disegna: Callable, dove := Vector2.ZERO) -> void:
	# un foglio da disegno; il primo ha sotto il fondo arancio del manifesto
	var foglio := Disegno.new()
	foglio.come = come_si_disegna
	foglio.position = dove
	var primo := tela == null or not is_instance_valid(tela) or tela.get_parent() != tavola
	tavola.add_child(foglio)
	if primo:
		Manifesto.trama_dietro(foglio).show_behind_parent = true
	tela = foglio


func tasti() -> void:
	match schermata:
		"a1_ruota", "a4_di_nuovo":
			tasti_quadrante()
		"a2_strade":
			comandi(Vector2(30, 686), [["SU", "cambia"], ["INVIO", "prendi"], ["ESC", "annulla"]], P.CARTA)
		"a3_cresciuto":
			comandi(Vector2(30, 686), [["INVIO", "avanti"], ["ESC", "basta così"]], P.CARTA)
		"b2_bivio":
			tasti_bivio()
		"b3_salto", "b4_abilita":
			comandi(Vector2(40, 676), [["INVIO", "avanti"], ["ESC", "salta tutto"]], P.CARTA)
		"c1_ruota":
			comandi(Vector2(930, 676), [["SU", "gira"], ["INVIO", "prendi"]], P.NERO)
		"c2_mozzo":
			comandi(Vector2(930, 676), [["CLIC", "scegli"], ["INVIO", "prendi"]], P.NERO)
		_:
			comandi(Vector2(930, 676), [["INVIO", "avanti"], ["ESC", "basta"]], P.NERO)


# --- i dati: cosa cresce passando all'8 ---------------------------------------------------

static func motivi_tipo() -> Array[Dictionary]:
	# le azioni di un livello del giocatore tipo, convertite come le converte
	# GameState.applica_crescita_livello (stessi conti, stesso racconto)
	var motivi: Array[Dictionary] = []
	var profilo: Dictionary = GameState.crescita.get("profilo_giocatore_tipo", {})
	var regole: Dictionary = GameState.crescita.get("crescita", {})
	for fatto: String in regole:
		var regola: Dictionary = regole[fatto]
		var ogni := maxi(int(regola.get("ogni", 1)), 1)
		var volte := int(profilo.get(fatto, 0))
		var guadagno := floori(float(volte) / ogni) * int(regola.get("punti", 1))
		if guadagno > 0:
			motivi.append({"stat": String(regola.get("stat", "")), "guadagno": guadagno,
					"racconto": String(regola.get("racconto", "")), "quante": volte - volte % ogni})
	return motivi


static func cresciute() -> Array[Dictionary]:
	# per ogni statistica: da quanto parte, quanto da' la strada presa, quanto le
	# azioni, e il perche' (come Resoconto.perche_di)
	var motivi := motivi_tipo()
	var righe: Array[Dictionary] = []
	for chiave: String in ["attacco", "hp", "difesa", "forza_mentale", "velocita", "intelligenza", "fattore"]:
		var scelta := int(potenziamento(chiave).get("quanto", 0)) if chiave == STRADA else 0
		var fatte := 0
		var perche := PackedStringArray()
		for m: Dictionary in motivi:
			if String(m["stat"]) == chiave:
				fatte += int(m["guadagno"])
				perche.append("%s (%d)" % [String(m["racconto"]), int(m["quante"])])
		if scelta + fatte > 0:
			righe.append({"stat": chiave, "prima": int(PRIMA.get(chiave, 0)), "scelta": scelta, "fatte": fatte,
					"perche": " e ".join(perche)})
	return righe


static func virgola(x: float) -> String:
	return ("%.1f" % x).trim_suffix(".0").replace(".", ",")


# --- i pezzi nuovi -----------------------------------------------------------------------

static func segnapunti(t: CanvasItem, dove: Vector2, quanti: int, resto: int, inchiostro: Color, vuoto: Color,
		r := 15.0) -> void:
	# come gettoni, ma coi punti che restano: speso uno, ne restano due
	for i in quanti + 1:
		P.gettone(t, dove + Vector2(r * 2.6 * i, 0), r, 1.0 if i < quanti else float(resto) / per_punto(), inchiostro, vuoto)
	var x := dove.x + r * 2.6 * (quanti + 1) - 4.0
	P.scritta(t, Vector2(x, dove.y + 6), "%d PUNTI" % quanti, 18, inchiostro)
	P.scritta(t, Vector2(x, dove.y + 26), "%s/%s al prossimo" % [migliaia(resto), migliaia(per_punto())], 13, inchiostro,
			Caratteri.tondo(900))


static func riga_cresciuta(t: CanvasItem, voce: Dictionary, dove: Vector2, largo: float, su_nero: bool,
		grande := false) -> float:
	# una statistica cresciuta: l'icona, il nome, da quanto a quanto, la
	# barretta in tre pezzi (quello che avevi, grigio; le azioni, nel colore del
	# testo; la strada, arancio) e il perche', negli stessi colori. Restituisce
	# quanto e' alta
	var inchiostro := P.CREMA if su_nero else P.NERO
	var grigio := P.TRATTO if su_nero else P.CREMA.lerp(P.NERO, 0.3)
	var arancio := P.ARANCIO if su_nero else P.ARANCIO_SCURO
	var chiave := String(voce["stat"])
	var prima := int(voce["prima"])
	var scelta := int(voce["scelta"])
	var fatte := int(voce["fatte"])
	var corpo := 24 if grande else 19
	var lato := 34.0 if grande else 27.0
	IS.timbro(t, chiave, dove + Vector2(lato * 0.5, 2), lato, inchiostro, P.NERO if su_nero else P.CREMA, P.ARANCIO)
	var x := dove.x + lato + 12.0
	P.scritta(t, Vector2(x, dove.y + 10), nome_stat(chiave).to_upper(), corpo, inchiostro)
	P.scritta(t, Vector2(dove.x, dove.y + 12), "%d → %d" % [prima, prima + scelta + fatte], corpo + 6, inchiostro, null,
			HORIZONTAL_ALIGNMENT_RIGHT, largo)
	var barra := Rect2(x, dove.y + 22, dove.x + largo - x, 10 if grande else 8)
	var fondo := float(FONDO.get(chiave, 100.0))
	P.barretta(t, barra, (prima + scelta + fatte) / fondo, arancio, Color(inchiostro, 0.12))
	P.barretta(t, barra, (prima + fatte) / fondo, inchiostro)
	P.barretta(t, barra, prima / fondo, grigio)
	var y := dove.y + (56.0 if grande else 50.0)
	var corpo_perche := 15 if grande else 13
	if scelta > 0:
		P.scritta(t, Vector2(x, y), "%+d la strada che hai preso" % scelta, corpo_perche, arancio, Caratteri.tondo(900))
		y += corpo_perche + 4.0
	if fatte > 0:
		var testo := "%+d per %s" % [fatte, String(voce["perche"])]
		var spazio := dove.x + largo - x
		var righe := 1 if P.larghezza(testo, corpo_perche, Caratteri.tondo(800)) <= spazio else 2
		P.a_capo(t, Rect2(x, y - corpo_perche, spazio, 40), testo, corpo_perche, inchiostro, Caratteri.tondo(800),
				HORIZONTAL_ALIGNMENT_LEFT, 2)
		y += (corpo_perche + 4.0) * righe
	return y - dove.y + 4.0


static func carta_abilita(t: CanvasItem, c: Vector2, gradi: float, quanto_grande := 1.0) -> void:
	# l'abilita' che arriva, come una carta: il simbolo, il nome, cosa fa, e in
	# fondo quanto costa e quanto pesa (abilita.json)
	var dati := abilita(ARRIVA)
	P.gira(t, c, gradi, quanto_grande)
	# il bordo chiaro, come un adesivo ritagliato: sul nero la carta resta intera
	t.draw_rect(Rect2(-192, -242, 412, 512), P.NERO)
	t.draw_rect(Rect2(-206, -256, 412, 512), P.CREMA)
	P.cartoncino(t, Rect2(-200, -250, 400, 500), P.ARANCIO, 6.0, Vector2.ZERO)
	t.draw_rect(Rect2(-182, -232, 364, 410), Color(P.NERO, 0.5), false, 2.0)
	P.etichetta(t, Vector2(-186, -282), "NUOVA ABILITÀ", 22, P.NERO, P.CREMA, P.CREMA)
	P.rombo(t, Vector2(10, -78), 108.0, P.NERO)
	P.rombo(t, Vector2(0, -88), 108.0, P.CREMA, P.NERO, 6.0)
	S.timbro(t, simbolo_di("abilita", ARRIVA), Vector2(0, -88), 140.0, P.NERO, P.CREMA, P.ARANCIO)
	var nome := String(dati.get("nome", ARRIVA)).to_upper()
	P.ritagliata(t, Vector2(-200, 92), nome, P.corpo_che_entra(nome, 66, 360.0), P.CREMA, P.NERO, 12, P.NERO, Vector2(6, 6),
			null, HORIZONTAL_ALIGNMENT_CENTER, 400)
	P.a_capo(t, Rect2(-172, 110, 344, 70), String(dati.get("descrizione", "")), 17, P.NERO, Caratteri.tondo(800),
			HORIZONTAL_ALIGNMENT_CENTER, 3)
	t.draw_rect(Rect2(-200, 190, 400, 60), P.NERO)
	P.scritta(t, Vector2(-200, 216), "COSTA %d AURA" % int(dati.get("aura", 0)), 20, P.ARANCIO, null,
			HORIZONTAL_ALIGNMENT_CENTER, 400)
	P.scritta(t, Vector2(-200, 238), "×%s a vita piena · ×%s quasi a terra" % [virgola(float(dati.get("moltiplicatore_pieno", 1.0))),
			virgola(float(dati.get("moltiplicatore_vuoto", 1.0)))], 14, P.CREMA, Caratteri.tondo(800),
			HORIZONTAL_ALIGNMENT_CENTER, 400)
	P.dritto(t)


static func raggiera(t: CanvasItem, c: Vector2, quanti: int, chiaro: Color, scuro: Color) -> void:
	# i raggi dei manifesti del luna park, dietro a quello che arriva
	t.draw_rect(Rect2(0, 0, 1280, 720), scuro)
	var passo := TAU / quanti
	for i in quanti:
		if i % 2 == 1:
			Manifesto.poligono(t, PackedVector2Array([c, c + Vector2.from_angle(passo * i) * 1700.0,
					c + Vector2.from_angle(passo * (i + 1)) * 1700.0]), chiaro)


func arriva_comunque(t: CanvasItem, dove: Vector2, su_nero: bool) -> void:
	# la riga di quello che arriva comunque a questo livello
	var dati := abilita(ARRIVA)
	P.rombo(t, dove + Vector2(20, 0), 20.0, P.ARANCIO, P.NERO if not su_nero else Color(0, 0, 0, 0), 3.0)
	S.disegna(t, simbolo_di("abilita", ARRIVA), dove + Vector2(20, 0), 25.0, P.NERO, P.ARANCIO)
	var inchiostro := P.CREMA if su_nero else P.NERO
	var x := dove.x + 52.0
	x += P.scritta_larga(t, Vector2(x, dove.y - 2), "E ARRIVA ", 18, inchiostro)
	P.scritta(t, Vector2(x, dove.y - 2), String(dati.get("nome", ARRIVA)).to_upper(), 18, P.ARANCIO if su_nero else P.ARANCIO_SCURO)
	P.scritta(t, Vector2(dove.x + 52, dove.y + 17), "nuova abilità: " + String(dati.get("descrizione", "")).get_slice(".", 0).to_lower(),
			13, P.CARTA if su_nero else Color(P.NERO, 0.72), Caratteri.tondo(800))


# --- a. il banco: la lastra cambia, la ruota resta ------------------------------------------

func pannello_quadrante(t: CanvasItem, livello: int) -> void:
	match schermata:
		"a2_strade":
			lastra_strade(t)
		"a3_cresciuto":
			lastra_cresciuto(t)
		"a4_di_nuovo":
			super(t, livello)
			# speso un punto ne restano due: i gettoni di dopo sopra quelli di prima
			t.draw_rect(Rect2(26, 80, 420, 60), P.NERO)
			segnapunti(t, Vector2(46, 104), punti() - 1, HYPE % per_punto(), P.CREMA, Color(P.CREMA, 0.14))
		_:
			super(t, livello)


func lastra_strade(t: CanvasItem) -> void:
	# premuto PRENDI: le due strade, una sopra l'altra, al posto di cosa da'
	gettoni(t, Vector2(46, 104), P.CREMA, Color(P.CREMA, 0.14))
	P.scritta(t, Vector2(34, 184), "UN PUNTO, DUE STRADE", 30, P.CREMA)
	P.scritta(t, Vector2(36, 208), "Il punto ti porta al livello %d. La strada la scegli tu." % (LIVELLO + 1), 14, P.CARTA,
			Caratteri.tondo(800))
	var due: Array = coppia(LIVELLO + 1)
	scheda_strada(t, Rect2(30, 232, 404, 118), String(due[0]), false)
	scheda_strada(t, Rect2(50, 376, 404, 118), String(due[1]), true)
	arriva_comunque(t, Vector2(36, 540), true)
	P.etichetta(t, Vector2(30, 624), "PRENDI · PIÙ %s" % PAROLE[STRADA], 26, P.ARANCIO, P.NERO, P.CREMA)


func scheda_strada(t: CanvasItem, r: Rect2, stat: String, scelta: bool) -> void:
	# una strada sulla lastra: quella scelta arancio, sporgente; l'altra spenta
	var dati := potenziamento(stat)
	var quanto := int(dati.get("quanto", 1))
	var prima := int(PRIMA.get(stat, 0))
	var inchiostro := P.NERO if scelta else P.CREMA
	if scelta:
		t.draw_rect(Rect2(r.position + Vector2(8, 8), r.size), P.CREMA)
		P.cartoncino(t, r, P.ARANCIO, 4.0, Vector2.ZERO)
		P.etichetta(t, r.position + Vector2(14, -16), "◆ LA SCEGLI", 13, P.NERO, P.ARANCIO)
	else:
		t.draw_rect(r, P.BRUNO)
	IS.disegna(t, stat, r.position + Vector2(48, 58), 58.0, inchiostro, P.ARANCIO if scelta else P.BRUNO)
	var x := r.position.x + 92.0
	P.scritta(t, Vector2(x, r.position.y + 42), "PIÙ " + String(PAROLE[stat]), 30, inchiostro)
	P.scritta(t, Vector2(x, r.position.y + 64), "%+d · «%s»" % [quanto, String(dati.get("nome", ""))], 14,
			inchiostro if scelta else P.CARTA, Caratteri.tondo(800))
	P.scritta(t, Vector2(x, r.position.y + 100), "%d → %d" % [prima, prima + quanto], 22, inchiostro)
	var barra := Rect2(x + 120, r.position.y + 88, r.end.x - x - 136, 10)
	var fondo := float(FONDO.get(stat, 100.0))
	P.barretta(t, barra, (prima + quanto) / fondo, P.CREMA if scelta else P.ARANCIO, Color(inchiostro, 0.15))
	P.barretta(t, barra, prima / fondo, inchiostro)


func lastra_cresciuto(t: CanvasItem) -> void:
	# preso: la tasca e' timbrata sulla ruota, e la lastra dice cosa e'
	# cresciuto e perche'. Le azioni sono di tutto quello che hai fatto dal
	# livello prima: e' l'unico momento in cui lo scopri
	segnapunti(t, Vector2(46, 104), punti() - 1, HYPE % per_punto(), P.CREMA, Color(P.CREMA, 0.14))
	# (il numero grande sta gia' nel mozzo: qui basta una riga)
	var x := 34.0 + P.scritta_larga(t, Vector2(34, 200), "SEI AL LIVELLO ", 30, P.CREMA)
	P.ritagliata(t, Vector2(x, 206), str(adesso), 62, P.ARANCIO, P.NERO, 0, P.ARANCIO_SCURO, Vector2(5, 5))
	P.scritta(t, Vector2(36, 230), "%d DI 20 · COSA È CRESCIUTO, E PERCHÉ" % adesso, 14, P.CARTA, Caratteri.tondo(900))
	var y := 256.0
	for voce: Dictionary in cresciute():
		y += riga_cresciuta(t, voce, Vector2(36, y), 410.0 - (y - 256.0) * 0.16, true) + 6.0
	# al posto di PRENDI, quello che arriva: avanti lo dicono i tasti
	arriva_comunque(t, Vector2(36, maxf(y + 22.0, 600.0)), true)


# --- b. tre tempi: il salto e quello che arriva, a tutto schermo ------------------------------

func disegna_salto(t: CanvasItem) -> void:
	# dopo il bivio: il livello enorme a sinistra, il perche' a destra
	P.lastra(t, PackedVector2Array([Vector2(-20, -20), Vector2(560, -20), Vector2(420, 740), Vector2(-20, 740)]), P.NERO,
			P.CREMA, 16.0)
	retino_a_salire(t, Rect2(0, 330, 470, 390), Color(P.ARANCIO, 0.5))
	P.etichetta(t, Vector2(36, 40), "ANONIMO", 22, P.ARANCIO, P.NERO, P.CREMA)
	P.scritta(t, Vector2(40, 140), "SALE AL", 30, P.CARTA)
	P.scritta(t, Vector2(40, 208), "LIVELLO", 72, P.CREMA)
	P.ritagliata(t, Vector2(26, 610), str(LIVELLO + 1), 430, P.ARANCIO, P.NERO, 14, P.CREMA, Vector2(16, 16))
	P.scritta(t, Vector2(320, 600), "DI 20", 26, P.CARTA)
	P.gira(t, Vector2(598, 92), -2.5)
	P.cartoncino(t, Rect2(0, 0, 640, 470), P.CREMA, 5.0, Vector2(12, 12), true)
	P.etichetta(t, Vector2(22, -22), "COSA HAI FATTO, E COSA TI HA DATO", 18, P.NERO, P.CREMA)
	var y := 52.0
	for voce: Dictionary in cresciute():
		y += riga_cresciuta(t, voce, Vector2(30, y), 580.0, false, true) + 4.0
	P.dritto(t)
	P.gira(t, Vector2(760, 618), -2.5)
	t.draw_rect(Rect2(6, 6, 480, 44), P.NERO)
	t.draw_rect(Rect2(0, 0, 480, 44), P.ARANCIO)
	t.draw_rect(Rect2(0, 0, 480, 44), P.NERO, false, 3.0)
	var x := 16.0 + P.scritta_larga(t, Vector2(16, 31), "POI ARRIVA", 20, P.NERO)
	P.rombo(t, Vector2(x + 26, 22), 17.0, P.NERO)
	S.disegna(t, simbolo_di("abilita", ARRIVA), Vector2(x + 26, 22), 22.0, P.ARANCIO, P.NERO)
	P.scritta(t, Vector2(x + 52, 32), String(abilita(ARRIVA).get("nome", ARRIVA)).to_upper() + "  ▸", 24, P.NERO)
	P.dritto(t)


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


func disegna_arriva(t: CanvasItem) -> void:
	# l'abilita' che arriva: la carta, sui raggi
	raggiera(t, Vector2(640, 380), 28, P.BRUNO, P.NERO)
	P.scritta(t, Vector2(46, 300), "ARRIVA", 62, P.CREMA)
	P.ritagliata(t, Vector2(46, 362), "UN'ABILITÀ", 46, P.ARANCIO, P.NERO, 10, P.NERO, Vector2(5, 5))
	P.scritta(t, Vector2(48, 398), "al livello %d, con qualunque strada" % (LIVELLO + 1), 16, P.CARTA, Caratteri.tondo(800))
	carta_abilita(t, Vector2(650, 384), -4.0)
	P.scritta(t, Vector2(916, 300), "DOVE LA TROVI", 14, P.CARTA, Caratteri.tondo(900))
	P.a_capo(t, Rect2(916, 308, 330, 80), "In combattimento, fra le abilità di Anonimo. Da adesso c'è sempre.", 18, P.CREMA,
			Caratteri.tondo(800))
	P.scritta(t, Vector2(916, 420), "PERCHÉ È ARRIVATA", 14, P.CARTA, Caratteri.tondo(900))
	P.a_capo(t, Rect2(916, 428, 330, 80), "Non si sceglie e non costa punti: arriva da sola, al suo livello.", 18, P.CREMA,
			Caratteri.tondo(800))


# --- c. la ruota gira: la ruota al centro, il bivio nel mozzo ---------------------------------

func c_sotto(t: CanvasItem) -> void:
	testata(t, "CRESCITA", false, false, adesso)
	if schermata in ["c3_cresciuto", "c4_abilita"]:
		segnapunti(t, Vector2(46, 104), punti() - 1, HYPE % per_punto(), P.NERO, Color(P.NERO, 0.14))
	else:
		gettoni(t, Vector2(46, 104), P.NERO, Color(P.NERO, 0.14))


func c_ruota(t: CanvasItem) -> void:
	# la ruota della a, spostata al centro (la sposta il foglio, non lei)
	var tm := tema(0)
	ruota_giro(t, tm, 0, vista, 20.0)
	if schermata == "c2_mozzo":
		mozzo_aperto(t)
		return
	mozzo(t, tm, 0)
	if schermata == "c1_ruota":
		var testo := "INVIO · PRENDI L'%d" % (adesso + 1)
		P.etichetta(t, CENTRO + Vector2(-(P.larghezza(testo, 17) + 19.0) * 0.5, 88), testo, 17, P.ARANCIO, P.NERO)
	else:
		# appena preso: il mozzo timbrato
		t.draw_arc(CENTRO, R_MOZZO - 7.0, 0.0, TAU, 120, P.ARANCIO, 8.0, true)
		var testo := "SALITO!"
		P.etichetta(t, CENTRO + Vector2(-(P.larghezza(testo, 20) + 22.0) * 0.5, 84), testo, 20, P.ARANCIO, P.NERO)


func mozzo_aperto(t: CanvasItem) -> void:
	# il bivio dentro la ruota: il mozzo si spacca lungo il taglio storto del
	# bivio approvato, e la meta' scelta esce di un passo, arancio
	var c := CENTRO
	var r := R_MOZZO + 8.0      # fin dove arrivano le tasche, non oltre
	var su := Vector2(0.16, -1.0).normalized()
	var a_lato := Vector2(-su.y, su.x)
	var due: Array = coppia(LIVELLO + 1)
	for lato in 2:
		var verso := -1.0 if lato == 0 else 1.0
		var scelto := lato == 1
		var o := c + a_lato * verso * (18.0 if scelto else 4.0)
		var meta := PackedVector2Array()
		for i in 49:
			meta.append(o + Vector2.from_angle(su.angle() + PI * float(i) / 48.0 * verso) * r)
		var ombra := PackedVector2Array()
		for q in meta:
			ombra.append(q + Vector2(9, 9))
		Manifesto.poligono(t, ombra, P.NERO)
		Manifesto.poligono(t, meta, P.ARANCIO if scelto else P.NERO)
		meta.append(meta[0])
		t.draw_polyline(meta, P.NERO if scelto else P.CREMA, 4.0, true)
		var stat := String(due[lato])
		var inchiostro := P.NERO if scelto else P.CREMA
		var prima := int(PRIMA.get(stat, 0))
		var quanto := int(potenziamento(stat).get("quanto", 1))
		var x := o.x + (22.0 if scelto else -160.0)
		IS.disegna(t, stat, o + Vector2(96.0 * verso, -86), 64.0, inchiostro, P.ARANCIO if scelto else P.NERO)
		if scelto:
			P.etichetta(t, Vector2(x + 6, o.y - 162), "◆ LA SCEGLI", 13, P.NERO, P.ARANCIO)
		var parola := String(PAROLE[stat])
		P.scritta(t, Vector2(x, o.y + 4), parola, P.corpo_che_entra(parola, 40, 146.0), inchiostro)
		P.ritagliata(t, Vector2(x, o.y + 44), "%+d" % quanto, 34, P.CREMA if scelto else P.ARANCIO, P.NERO, 8 if scelto else 0)
		P.scritta(t, Vector2(x, o.y + 72), "%d → %d" % [prima, prima + quanto], 17, inchiostro if scelto else P.CARTA)
	var punta := c - su * 128.0
	P.rombo(t, punta + Vector2(6, 6), 32.0, P.NERO)
	P.rombo(t, punta, 32.0, P.CREMA, P.NERO, 4.0)
	P.scritta(t, punta + Vector2(-32, 4), "1", 30, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 64)
	P.scritta(t, punta + Vector2(-32, 18), "PUNTO", 10, P.NERO, null, HORIZONTAL_ALIGNMENT_CENTER, 64)


func c_sopra(t: CanvasItem) -> void:
	# la lancetta, e a destra la colonna che dice
	var punta := Vector2(CENTRO.x + SPOSTA.x - R_ORLO - 8.0, CENTRO.y)
	var freccia := PackedVector2Array([punta + Vector2(-56, -32), punta, punta + Vector2(-56, 32)])
	var ombra := PackedVector2Array()
	for q in freccia:
		ombra.append(q + Vector2(7, 7))
	Manifesto.poligono(t, ombra, P.NERO)
	Manifesto.poligono(t, freccia, P.CREMA)
	freccia.append(freccia[0])
	t.draw_polyline(freccia, P.NERO, 4.0, true)
	match schermata:
		"c1_ruota":
			colonna_prossima(t)
		"c2_mozzo":
			colonna_strada(t)
		"c3_cresciuto":
			colonna_cresciuto(t)
		_:
			t.draw_rect(Rect2(0, 0, 1280, 720), Color(P.NERO, 0.62))
			# la carta esce dalla tasca, sotto la lancetta: la scia, poi lei
			var da := punta + Vector2(40, 0)
			var a := Vector2(760, 372)
			for i in 3:
				var scosta := (i - 1) * 84.0
				Manifesto.poligono(t, PackedVector2Array([da + Vector2(0, scosta * 0.06 - 3.0), a + Vector2(-170, scosta - 20),
						a + Vector2(-170, scosta + 20), da + Vector2(0, scosta * 0.06 + 3.0)]),
						Color(P.ARANCIO, 0.6 - absf(i - 1) * 0.25))
			carta_abilita(t, a, -7.0, 0.92)
			P.scritta(t, Vector2(990, 200), "ARRIVA", 44, P.CREMA)
			P.ritagliata(t, Vector2(990, 244), "DALLA", 34, P.ARANCIO, P.NERO, 8)
			P.ritagliata(t, Vector2(990, 284), "TASCA %d" % adesso, 34, P.ARANCIO, P.NERO, 8)
			P.a_capo(t, Rect2(992, 300, 260, 90), "Non si sceglie e non costa punti: arriva da sola, al suo livello.", 16,
					P.CREMA, Caratteri.tondo(800))


func colonna_prossima(t: CanvasItem) -> void:
	# cosa da' la tasca sotto la lancetta: la lastra della a, in piccolo
	var livello := adesso + 1
	P.gira(t, Vector2(930, 120), -2.0)
	P.cartoncino(t, Rect2(0, 0, 326, 420), P.NERO, 0.0, Vector2(10, 10))
	P.etichetta(t, Vector2(14, -18), "LA PROSSIMA TASCA", 15, P.ARANCIO, P.NERO)
	P.ritagliata(t, Vector2(18, 142), str(livello), 120, P.ARANCIO, P.NERO, 0, P.ARANCIO_SCURO, Vector2(8, 8))
	P.scritta(t, Vector2(110, 82), "LIVELLO", 30, P.CREMA)
	P.scritta(t, Vector2(110, 104), "%d DI 20 · 1 PUNTO" % livello, 14, P.CARTA, Caratteri.tondo(900))
	var due: Array = coppia(livello)
	S.disegna(t, "biforca", Vector2(34, 196), 30.0, P.CREMA, P.NERO)
	var detta := "PIÙ %s O PIÙ %s" % [PAROLE[due[0]], PAROLE[due[1]]]
	P.scritta(t, Vector2(62, 202), detta, P.corpo_che_entra(detta, 19, 250.0), P.CREMA)
	P.scritta(t, Vector2(62, 222), "la scegli quando lo prendi", 13, P.CARTA, Caratteri.tondo(700))
	var dati := abilita(ARRIVA)
	P.rombo(t, Vector2(34, 276), 21.0, P.ARANCIO)
	S.disegna(t, simbolo_di("abilita", ARRIVA), Vector2(34, 276), 26.0, P.NERO, P.ARANCIO)
	P.etichetta(t, Vector2(60, 250), "ARRIVA UN'ABILITÀ", 11, P.ARANCIO, P.NERO)
	P.scritta(t, Vector2(62, 290), String(dati.get("nome", ARRIVA)).to_upper(), 22, P.CREMA)
	P.a_capo(t, Rect2(62, 298, 250, 60), String(dati.get("descrizione", "")), 13, P.CARTA, null, HORIZONTAL_ALIGNMENT_LEFT, 3)
	P.etichetta(t, Vector2(14, 372), "PRENDI · 1 PUNTO", 22, P.ARANCIO, P.NERO, P.CREMA)
	P.dritto(t)


func colonna_strada(t: CanvasItem) -> void:
	# la strada guardata, per esteso, e quello che arriva comunque
	var dati := potenziamento(STRADA)
	P.gira(t, Vector2(930, 120), -2.0)
	P.cartoncino(t, Rect2(0, 0, 326, 420), P.CREMA, 5.0, Vector2(10, 10), true)
	P.etichetta(t, Vector2(14, -18), "UN PUNTO, DUE STRADE", 15, P.NERO, P.CREMA)
	P.scritta(t, Vector2(20, 66), "PIÙ " + String(PAROLE[STRADA]), 34, P.NERO)
	P.scritta(t, Vector2(20, 96), "%+d %s" % [int(dati.get("quanto", 1)), nome_stat(STRADA).to_upper()], 22, P.ARANCIO_SCURO)
	P.a_capo(t, Rect2(20, 108, 290, 70), "«%s» · %s" % [String(dati.get("nome", "")), String(dati.get("descrizione", ""))], 14,
			Color(P.NERO, 0.75), Caratteri.tondo(700), HORIZONTAL_ALIGNMENT_LEFT, 3)
	var prima := int(PRIMA.get(STRADA, 0))
	var quanto := int(dati.get("quanto", 1))
	P.scritta(t, Vector2(20, 222), "%d → %d" % [prima, prima + quanto], 30, P.NERO)
	var barra := Rect2(22, 236, 280, 12)
	P.barretta(t, barra, (prima + quanto) / float(FONDO[STRADA]), P.ARANCIO, Color(P.NERO, 0.15))
	P.barretta(t, barra, prima / float(FONDO[STRADA]), P.NERO)
	t.draw_line(Vector2(20, 280), Vector2(306, 280), Color(P.NERO, 0.2), 2.0)
	P.scritta(t, Vector2(20, 306), "E IN OGNI CASO, AL LIVELLO %d" % (LIVELLO + 1), 13, Color(P.NERO, 0.75), Caratteri.tondo(900))
	arriva_comunque(t, Vector2(16, 340), false)
	P.dritto(t)


func colonna_cresciuto(t: CanvasItem) -> void:
	# preso: cosa e' cresciuto, e perche'
	P.gira(t, Vector2(924, 104), -2.0)
	P.cartoncino(t, Rect2(0, 0, 336, 470), P.CREMA, 5.0, Vector2(10, 10), true)
	P.etichetta(t, Vector2(14, -18), "SEI AL LIVELLO %d" % adesso, 18, P.NERO, P.CREMA)
	P.scritta(t, Vector2(18, 44), "COSA È CRESCIUTO, E PERCHÉ", 13, Color(P.NERO, 0.75), Caratteri.tondo(900))
	var y := 70.0
	for voce: Dictionary in cresciute():
		y += riga_cresciuta(t, voce, Vector2(16, y), 300.0, false) + 4.0
	t.draw_line(Vector2(16, y + 4), Vector2(320, y + 4), Color(P.NERO, 0.2), 2.0)
	P.scritta(t, Vector2(18, y + 32), "POI ARRIVA " + String(abilita(ARRIVA).get("nome", ARRIVA)).to_upper() + "  ▸", 18,
			P.ARANCIO_SCURO)
	P.dritto(t)
