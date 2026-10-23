extends Control
# LA SCHERMATA DI COMBATTIMENTO, UNA PROPOSTA MIA. Provvisorio come le altre
# proposte: se ne va con la scelta di Bru.
#
# Bru: «sapresti aggiustare nel tutto la schermata di combattimento in modo
# migliore? il design era mio ma voglio vederti provare con una tua idea dopo
# tutto quello che abbiamo studiato».
#
# L'IDEA: IL MANIFESTO DI UN INCONTRO. La creatura e' l'attrazione della
# serata, la squadra sono gli sfidanti, e stanno faccia a faccia ai due lati di
# una diagonale sola che taglia lo schermo (prove/scontro/Spina.gd). Tutto il
# resto viene da tre regole, ognuna da una cosa studiata:
#   - LE COSE CHE CONTANO SONO LE PIU' GRANDI. Bertin: solo la posizione e la
#     grandezza dicono «quanto»; la vita e l'aura quindi stanno in barre lunghe
#     e spesse, e i ritratti vuoti si fanno piccoli (Scheda.gd)
#   - QUELLO CHE VA INSIEME STA INSIEME. Chi decide, il suo cuore (l'ECG), la
#     sua aura e i suoi comandi sono una colonna sola, sulla stessa diagonale:
#     oggi sono in quattro angoli diversi (Programma.gd)
#   - OGNI MOMENTO HA UNA COSA DA GUARDARE. Lo scontro e' una macchina a fasi
#     (Combattimento.fase_adesso: comandi, racconto, minigioco, attesa), e la
#     schermata si ricompone con la fase: il minigioco prende lo schermo della
#     creatura, il racconto la sua didascalia, il programma scende quando non
#     tocca a nessuno della squadra. Il quadrante che fa tutto, e per questo e'
#     piccolo per tutto, non c'e' piu' (Cartellone.gd, Racconto.gd)
# E in piu' una cosa che oggi non si vede: la fila del giro (FilaGiro.gd).
#
# Niente di cio' che e' di Bru e' cambiato nel funzionamento: le cinque voci,
# le liste, l'ECG con le sue regole, MATTANZA e BOND che si accendono da soli,
# gli status con l'icona calma, il posto libero, l'orda col suo numero, lo
# studio che scopre. La lingua e' la sua (il manifesto: arancio, nero, grigio
# caldo, ombre piene, etichette inclinate); e' cambiato dove stanno le cose.
#
#   ./prove/film_scontro.sh                     il film e gli scatti, in scatti/proposte_scontro/
#   nell'editor: ProposteScontro.tscn, F6 (il film; TAB salta al momento dopo)

const Spina := preload("res://prove/scontro/Spina.gd")
const Cartellone := preload("res://prove/scontro/Cartellone.gd")
const FasciaCreatura := preload("res://prove/scontro/Fascia.gd")
const Scheda := preload("res://prove/scontro/Scheda.gd")
const Programma := preload("res://prove/scontro/Programma.gd")
const FilaGiro := preload("res://prove/scontro/FilaGiro.gd")
const Didascalia := preload("res://prove/scontro/Racconto.gd")

# IL COPIONE: quando comincia ogni momento, in secondi
const COPIONE := [
	[0.0, "ingresso"], [1.6, "comandi"], [5.4, "lista"], [9.2, "studio"], [11.4, "scoperta"],
	[13.4, "tocca_alla_creatura"], [14.4, "parla_la_creatura"], [17.2, "minigioco"], [31.8, "tocca_a_veronica"],
	[37.3, "fine"],
]
const FINE := 38.0
# gli scatti: il momento e l'istante in cui fotografarlo
const SCATTI := {"comandi": 4.4, "lista": 6.9, "studio": 10.6, "scoperta": 13.0, "racconto": 16.4, "minigioco": 23.2,
		"veronica": 35.8}
const PARATE := [0, 1, 2, 4, 5, 7, 8, 10]   # la mano del film, come in ProposteVita
const REAZIONE := 0.42
const SKILL := [["Studia", -1, "scopri"], ["Sovraccarico", 5, ""], ["Onda psichica", 3, ""], ["Concentrazione", 1, ""],
		["Spezza spazio", 0, ""], ["Mattanza", -1, "tutta la barra"], ["Indietro", -1, ""]]

var tempo := 0.0
var momento := ""
var fatti := {}
var squadra: Array[Dictionary] = []
var schede: Array = []
var attivo := -1                # quale scheda ha il turno; -1 nessuna
var cartellone: Cartellone
var fascia: FasciaCreatura
var casa_gioco: Control
var programma: Programma
var fila: FilaGiro
var racconto: Didascalia
var sopra: Control              # i numeri dei colpi, sopra tutto
var ecg: TracciatoEcg
var gioco: MinigiocoCombattimento
var presi_visti := {}
var numeri: Array[Dictionary] = []   # {testo, dove, da}
var scossa := 0.0
var film := false
var in_posa := false


func _ready() -> void:
	GameState.nuova_partita()
	Manifesto.trama_dietro(self, "sfondo_combattimento")
	squadra = [
		{"nome": "Tu", "iniziale": "A", "tu": true, "hp": 100, "hp_max": 100, "aura": 10, "aura_max": 10,
				"dominio": 0.35, "stati": [], "morale": 20, "stress": 0},
		{"nome": "Veronica", "iniziale": "V", "hp": 600, "hp_max": 600, "aura": 12, "aura_max": 12,
				"dominio": 0.55, "stati": ["rapidita"], "morale": 20, "stress": 12},
	]
	cartellone = Cartellone.new()
	add_child(cartellone)
	casa_gioco = Control.new()
	casa_gioco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	casa_gioco.clip_contents = true
	add_child(casa_gioco)
	fascia = FasciaCreatura.new()
	add_child(fascia)
	racconto = Didascalia.new()
	add_child(racconto)
	for i in 3:
		var scheda: Scheda = Scheda.new()
		if i < squadra.size():
			scheda.dati = squadra[i]
		else:
			scheda.libero = true
		add_child(scheda)
		schede.append(scheda)
	ecg = TracciatoEcg.new()
	ecg.dado.seed = 20261023
	add_child(ecg)
	programma = Programma.new()
	add_child(programma)
	fila = FilaGiro.new()
	fila.ordine = [["A", false], ["M", true], ["V", false]]
	add_child(fila)
	sopra = Control.new()
	sopra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sopra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sopra.draw.connect(disegna_numeri)
	add_child(sopra)
	gioco = MinigiocoCombattimento.new()
	gioco.dado.seed = 7
	casa_gioco.position = cartellone.vetro().position
	casa_gioco.size = cartellone.vetro().size
	gioco.collega(casa_gioco)
	var argomenti := OS.get_cmdline_user_args()
	film = argomenti.size() > 0 and String(argomenti[0]) == "film"
	if argomenti.size() > 2 and String(argomenti[0]) == "scatto":
		await scatta(String(argomenti[1]), String(argomenti[2]))
		get_tree().quit()
		return
	print("INIZIO_FILM ", Engine.get_frames_drawn())


func scatta(quale: String, cartella: String) -> void:
	# lo scatto di un momento: il copione va avanti a passi fissi fino a lui
	var fino := float(SCATTI.get(quale, 4.0))
	while tempo < fino:
		passo(1.0 / 60.0)
	# IN POSA: mentre si aspetta il disegno il copione non va avanti, se no i
	# primi fotogrammi - lenti - lo portano al momento dopo
	in_posa = true
	for i in 3:
		await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [cartella, quale])


func _process(delta: float) -> void:
	if in_posa:
		return
	passo(delta)
	if film and tempo > FINE:
		get_tree().quit()


func _unhandled_input(evento: InputEvent) -> void:
	# nell'editor: TAB salta al momento dopo
	if evento.is_action_pressed("ui_focus_next"):
		for riga: Array in COPIONE:
			if float(riga[0]) > tempo + 0.05:
				while tempo < float(riga[0]):
					passo(1.0 / 60.0)
				break


func passo(delta: float) -> void:
	tempo += delta
	for riga: Array in COPIONE:
		if tempo >= float(riga[0]):
			momento = String(riga[1])
	recita(delta)
	passa_il_minigioco(delta)
	anima(delta)
	for pezzo in [cartellone, fascia, racconto, programma, fila, sopra]:
		(pezzo as CanvasItem).queue_redraw()
	for scheda: Scheda in schede:
		scheda.queue_redraw()


func una_volta(chiave: String, da: float) -> bool:
	if tempo < da or fatti.has(chiave):
		return false
	fatti[chiave] = true
	return true


# --- il copione --------------------------------------------------------------

func recita(delta: float) -> void:
	match momento:
		"comandi":
			attivo = 0
			programma.modo = "comandi"
			if una_volta("difesa", 2.8):
				programma.scelta = 1
			if una_volta("skill", 3.7):
				programma.scelta = 2
		"lista":
			if una_volta("apri", 5.4):
				programma.modo = "lista"
				programma.lista = SKILL
				programma.scelta = 0
			if una_volta("sovraccarico", 6.4):
				programma.scelta = 1
			if una_volta("onda", 7.5):
				programma.scelta = 2
			if una_volta("torna_su", 8.4):
				programma.scelta = 0
			var mossa: Array = SKILL[programma.scelta]
			schede[0].prenota_aura = maxi(int(mossa[1]), 0)
		"studio":
			recita_studio()
		"scoperta":
			fascia.svela = minf(fascia.svela + delta / 1.1, 1.0) if tempo > 11.8 else 0.0
		"tocca_alla_creatura":
			attivo = -1
		"parla_la_creatura":
			if una_volta("parla", 14.4):
				racconto.dici("Marionetta", "Ballate con me. Tutti insieme, che i fili sono tanti.")
		"minigioco":
			recita_minigioco()
		"tocca_a_veronica":
			attivo = 1
			programma.modo = "comandi"
			programma.scelta = 0
			if tempo > 33.2:
				squadra[1].dominio = minf(float(squadra[1].dominio) + delta * 0.5, 1.0)


func recita_studio() -> void:
	if una_volta("studia", 9.2):
		schede[0].prenota_aura = 0
		racconto.dici("", "Studi la marionetta. I fili salgono nel buio e non finiscono da nessuna parte.")
		fascia.nota = true
		fascia.hp_scritto = "120/120"
		fascia.studio = ["TETRO", "COLPISCE A RAFFICA"]


func recita_minigioco() -> void:
	if una_volta("raffica", 17.2):
		racconto.dici("", "")
		gioco.avvia({"nome": "Collisioni infinite", "quanti": 12, "comparsa": 0.12, "attesa": 0.6,
				"finestra": 1.1, "finestra_finale": 0.75, "pausa": 0.22, "danno": 9})
		gioco.salta()
	if gioco.attivo and gioco.fase == "raffica":
		var acceso := Collisioni.accesa(gioco.raffica)
		if acceso >= 0 and int(gioco.raffica[acceso].turno) in PARATE \
				and gioco.tempo - float(gioco.raffica[acceso].accesa_da) >= REAZIONE:
			gioco.colpisci(acceso)


func passa_il_minigioco(delta: float) -> void:
	# il minigioco va avanti finche' e' attivo, anche quando il copione e'
	# passato oltre: il conto finale resta il suo tempo e poi se ne va
	if not gioco.attivo:
		return
	gioco.passa(delta)
	# OGNI COLPO PRESO SI VEDE DOVE FA MALE: sulla scheda di chi lo prende, che
	# trema e perde la vita, col numero che salta fuori dalla barra
	for i in gioco.raffica.size():
		if String(gioco.raffica[i].esito) == "preso" and not presi_visti.has(i):
			presi_visti[i] = true
			var chi := i % 2
			squadra[chi].hp = maxi(int(squadra[chi].hp) - 9, 0)
			schede[chi].colpo = 1.0
			scossa = 1.0
			numeri.append({"testo": "-9", "dove": schede[chi].dove.position + Vector2(schede[chi].dove.size.x - 70.0, 30.0), "da": tempo})


# --- il movimento ------------------------------------------------------------

func avvicina(da: float, a: float, delta: float, quanto := 10.0) -> float:
	return lerpf(da, a, 1.0 - exp(-quanto * delta))


func anima(delta: float) -> void:
	var entrata := clampf(tempo / 1.4, 0.0, 1.0)
	var e := 1.0 - pow(1.0 - entrata, 3.0)
	scossa = maxf(scossa - delta * 4.0, 0.0)
	var trema := Vector2(sin(tempo * 90.0), cos(tempo * 77.0)) * 6.0 * scossa * scossa
	cartellone.position = Vector2(-820.0 * (1.0 - e), 0.0) + trema
	fascia.position = cartellone.position
	casa_gioco.position = cartellone.vetro().position + cartellone.position
	fila.position = Vector2(0.0, -90.0 * (1.0 - e))
	var nel_minigioco := gioco.attivo or (momento == "minigioco" and tempo < 17.4)
	cartellone.ritirata = avvicina(cartellone.ritirata, 1.0 if nel_minigioco else 0.0, delta)
	var lampeggia := momento == "tocca_alla_creatura" and fmod(tempo - 13.4, 0.5) < 0.22
	cartellone.lampo = avvicina(cartellone.lampo, 1.0 if lampeggia else 0.0, delta, 22.0)
	var della_creatura := momento in ["tocca_alla_creatura", "parla_la_creatura", "minigioco"]
	fascia.turno = avvicina(fascia.turno, 1.0 if della_creatura else 0.0, delta)
	var parla := momento in ["studio", "parla_la_creatura"]
	racconto.su = avvicina(racconto.su, 1.0 if parla else 0.0, delta, 12.0)
	racconto.da += delta
	fascia.giu = avvicina(fascia.giu, 1.0 if parla else 0.0, delta, 12.0)
	fila.adesso = avvicina(fila.adesso, {"tocca_alla_creatura": 1.0, "parla_la_creatura": 1.0, "minigioco": 1.0,
			"tocca_a_veronica": 2.0, "fine": 2.0}.get(momento, 0.0), delta, 8.0)
	# il programma c'e' quando qualcuno della squadra sta scegliendo; scelto, si
	# ritira mentre la mossa si compie
	var squadra_agisce := attivo >= 0 and momento in ["comandi", "lista", "tocca_a_veronica", "fine"]
	programma.su = avvicina(programma.su, 1.0 if squadra_agisce else 0.0, delta, 9.0) * e
	programma.mattanza = avvicina(programma.mattanza, 1.0 if attivo >= 0 and float(squadra[attivo].dominio) >= 1.0 else 0.0, delta, 6.0)
	disponi_destra(delta, e)


func disponi_destra(delta: float, e: float) -> void:
	# LE SCHEDE SULLA SPINA: una sotto l'altra, il lato sinistro sulla diagonale.
	# Chi ha il turno e' alta 196 e fa un passo avanti verso la creatura; le
	# altre 92; il posto libero 52. Il totale non cambia col turno: il programma
	# sotto non si muove mai
	var y := 80.0
	for i in schede.size():
		var scheda: Scheda = schede[i]
		scheda.attiva = avvicina(scheda.attiva, 1.0 if i == attivo else 0.0, delta, 9.0)
		scheda.colpo = maxf(scheda.colpo - delta * 2.5, 0.0)
		var alta := 52.0 if scheda.libero else lerpf(92.0, 196.0, scheda.attiva)
		var avanti := 22.0 * scheda.attiva
		var x := Spina.diagonale(y, Spina.GOLA) - avanti
		var trema := Vector2(sin(tempo * 80.0 + i), 0.0) * 7.0 * scheda.colpo * scheda.colpo
		scheda.dove = Rect2(Vector2(x + 520.0 * (1.0 - e) * (1.0 + 0.3 * i), y) + trema, Vector2(1256.0 - x + avanti, alta))
		y += alta + 14.0
	var basso := 704.0
	var alto := 466.0
	programma.dove = Rect2(Vector2(Spina.diagonale(alto, Spina.GOLA), alto), Vector2(1256.0 - Spina.diagonale(alto, Spina.GOLA), basso - alto))
	# L'ECG DI CHI DECIDE, nella sua scheda
	if attivo >= 0 and (schede[attivo] as Scheda).attiva > 0.6:
		var casa: Rect2 = (schede[attivo] as Scheda).casa_ecg()
		ecg.position = casa.position + Vector2(6, 4)
		ecg.size = casa.size - Vector2(12, 8)
		ecg.visible = true
		var dati: Dictionary = squadra[attivo]
		ecg.imposta(float(dati.hp) / float(dati.hp_max), int(dati.stress))
	else:
		ecg.visible = false


func disegna_numeri() -> void:
	for numero: Dictionary in numeri:
		var eta := tempo - float(numero.da)
		if eta > 0.9:
			continue
		var su := Vector2(0, -40.0 * (1.0 - pow(1.0 - minf(eta / 0.5, 1.0), 3.0)))
		var alfa := 1.0 - clampf((eta - 0.6) / 0.3, 0.0, 1.0)
		var dove := (numero.dove as Vector2) + su
		Spina.scritta(sopra, Caratteri.titolo(), dove + Vector2(3, 3), String(numero.testo), 34, Color(Stile.colore("bordo"), alfa))
		Spina.scritta(sopra, Caratteri.titolo(), dove, String(numero.testo), 34, Color(Stile.colore("pericolo"), alfa))
