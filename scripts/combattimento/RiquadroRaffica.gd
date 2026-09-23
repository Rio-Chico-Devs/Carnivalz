class_name RiquadroRaffica
extends Control

# IL RIQUADRO DELLA RAFFICA: suo, dall'inizio dell'evento alla fine.
#
# Bru: «l'evento deve trovarsi dentro il riquadro, invece vedo apparire cerchi
# rossi sull'interfaccia di combattimento». Ed era proprio cosi': il minigioco
# viveva in uno strato TRASPARENTE che si copiava il rettangolo del box e ci
# si stendeva sopra. Sotto restavano l'ECG, Morale e Stress, MATTANZA e BOND,
# i comandi - e i pugni ci atterravano in mezzo. Non era un riquadro, era una
# manciata di cerchi buttata sopra un'altra schermata.
#
# Adesso e' una faccia del pannello, come i comandi e il parlato: quando parte
# le altre si spengono, e lui e' opaco, con un titolo, un contatore e un bordo.
# Ha un inizio (il titolo e una riga che ti dice cosa fare) e una fine (quanti
# ne hai fermati), e fra i due non c'e' nient'altro a schermo.
#
# UN NODO SOLO, CHE DISEGNA TUTTO. Prima ogni pugno era un Button: dodici nodi
# creati a ogni raffica e distrutti alla fine. La documentazione di Godot
# (CPU optimization) e' netta: «every node has a cost [...] a smaller number of
# nodes with more in each can lead to better performance». Qui i pugni sono
# disegni dentro un nodo solo, e le poche scritte sono create UNA volta quando
# il riquadro nasce e poi riusate: durante la raffica non si crea e non si
# distrugge niente, quindi non c'e' niente che possa far scattare un
# fotogramma nel momento in cui stai mirando.
#
# E IL CLIC VALE QUANDO PREMI. Un Button di Godot per conto suo scatta al
# RILASCIO: action_mode vale di serie ACTION_MODE_BUTTON_RELEASE (e' scritto
# nella sua scheda, BaseButton.xml: «Require a press and a subsequent release
# before considering the button clicked»). In un gioco di tempismo e' un
# ritardo regalato: la parata veniva registrata quando alzavi il dito, cioe'
# tutta la durata del clic dopo il momento in cui avevi deciso. Qui si guarda
# l'evento grezzo e conta la pressione.

const SCALA_ANELLO := 2.6       # osu! parte da 4 (DrawableHitCircle.cs, Scale = 4);
								# il nostro riquadro e' basso e largo, a 4 uscirebbe
								# dal bordo per mezza vita del pugno
const COMPARSA := 0.20          # quanto ci mette un pugno ad accendersi
const TOLLERANZA_MIRA := 8.0    # pixel oltre il bordo del cerchio che contano ancora
const ALTEZZA_TESTATA := 44.0
const MARGINE := 12.0
const DURATA_SEGNO := 0.55      # quanto resta a schermo "PARATA" / "COLPITO"
const SCRITTE := 4              # quante al massimo insieme: create una volta sola

var gioco: MinigiocoCombattimento
var testata: ColorRect
var titolo: Label
var contatore: Label
var piano: Control              # dove vivono i pugni, e taglia quello che esce
var avviso: Label               # cosa fare, all'inizio; com'e' andata, alla fine
var scritte: Array[Label] = []
var segni: Array[Dictionary] = []   # i riscontri in volo: {indice, esito, eta}


func _init(chi: MinigiocoCombattimento) -> void:
	gioco = chi


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true

	testata = ColorRect.new()
	testata.color = Stile.colore("fascia_nemico")
	testata.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(testata)
	titolo = etichetta(Stile.dimensione("corpo"), Stile.colore("testo"))
	testata.add_child(titolo)
	contatore = etichetta(Stile.dimensione("corpo"), Stile.colore("testo"))
	contatore.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	testata.add_child(contatore)

	piano = Control.new()
	piano.clip_contents = true
	piano.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piano.draw.connect(_disegna_piano)
	add_child(piano)

	avviso = etichetta(Stile.dimensione("sezione"), Stile.colore("testo"))
	avviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avviso.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(avviso)

	for i in SCRITTE:
		var scritta := etichetta(Stile.dimensione("piccolo"), Stile.colore("testo"))
		scritta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# col contorno scuro: una scritta che puo' finire sopra un pugno rosso
		# o sopra il lampo di un colpo deve reggere su tutti e due (e' la stessa
		# fasciatura dei segni della mappa, Fascia.gd)
		Stile.contorno(scritta, Stile.dimensione("piccolo"))
		scritta.visible = false
		piano.add_child(scritta)
		scritte.append(scritta)
	resized.connect(disponi)
	disponi()


func etichetta(corpo: int, tinta: Color) -> Label:
	var fatta := Label.new()
	fatta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fatta.add_theme_color_override("font_color", tinta)
	Stile.imposta_corpo(fatta, corpo)
	return fatta


func disponi() -> void:
	# tutto si ricalcola dal rettangolo del pannello: la finestra puo' cambiare
	# misura, e un pugno piazzato in pixel assoluti finirebbe fuori
	if testata == null:
		return
	testata.position = Vector2.ZERO
	testata.size = Vector2(size.x, ALTEZZA_TESTATA)
	titolo.position = Vector2(MARGINE, 0.0)
	titolo.size = Vector2(size.x * 0.6, ALTEZZA_TESTATA)
	titolo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	contatore.position = Vector2(size.x * 0.4, 0.0)
	contatore.size = Vector2(size.x * 0.6 - MARGINE, ALTEZZA_TESTATA)
	contatore.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	piano.position = Vector2(MARGINE, ALTEZZA_TESTATA + MARGINE)
	piano.size = Vector2(maxf(size.x - MARGINE * 2.0, 1.0),
			maxf(size.y - ALTEZZA_TESTATA - MARGINE * 2.0, 1.0))
	avviso.position = piano.position
	avviso.size = piano.size


# --- geometria: dove sta un pugno, e se il clic l'ha preso ------------------

func proporzione() -> float:
	# largo diviso alto del piano dove vivono i pugni: al calendario serve per
	# misurare le distanze in pixel veri. Al momento del via il riquadro puo'
	# essere ancora spento e senza misura: allora vale quella del pannello
	var misura := size
	if (misura.x <= 0.0 or misura.y <= 0.0) and get_parent_control() != null:
		misura = get_parent_control().size
	var largo := misura.x - MARGINE * 2.0
	var alto := misura.y - ALTEZZA_TESTATA - MARGINE * 2.0
	return 1.0 if largo <= 0.0 or alto <= 0.0 else largo / alto


func raggio() -> float:
	return minf(piano.size.x, piano.size.y) * Collisioni.LATO_PUGNO * 0.5


func centro_di(pugno: Dictionary) -> Vector2:
	# IL PUGNO STA TUTTO DENTRO. Il centro si sceglie nel rettangolo ridotto di
	# un raggio per lato, quindi il cerchio non tocca mai il bordo del piano -
	# e il piano sta dentro il riquadro, che sta dentro il pannello
	var r := raggio()
	return Vector2(r + float(pugno.x) * maxf(piano.size.x - 2.0 * r, 0.0),
			r + float(pugno.y) * maxf(piano.size.y - 2.0 * r, 0.0))


func pugno_sotto(punto: Vector2) -> int:
	# Il bersaglio e' il CERCHIO, non il quadrato che lo contiene: un Button
	# prendeva anche gli angoli, dove non c'e' disegnato niente. Un po' di
	# tolleranza oltre il bordo si', perche' la mano che ci arriva di corsa si
	# ferma spesso un filo corta (e' la legge di Fitts: un bersaglio si prende
	# tanto meglio quanto e' largo).
	#
	# Se due si toccano vince quello che arriva prima: e' lo stesso criterio del
	# tasto, e la regola di osu! per due cerchi sovrapposti (Notelock: il
	# secondo aspetta che il primo sia giudicato).
	var scelto := -1
	var prima := INF
	var portata := raggio() + TOLLERANZA_MIRA
	for pugno in gioco.raffica:
		if not gioco.si_vede(pugno):
			continue
		if punto.distance_to(centro_di(pugno)) > portata:
			continue
		if float(pugno.impatto) < prima:
			prima = float(pugno.impatto)
			scelto = int(pugno.indice)
	return scelto


func _gui_input(evento: InputEvent) -> void:
	var premuto := evento is InputEventMouseButton \
			and (evento as InputEventMouseButton).pressed \
			and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	if not premuto:
		return
	accept_event()
	clic((evento as InputEventMouseButton).position)


func clic(punto: Vector2) -> void:
	# dentro la raffica si para; prima e dopo, il clic fa andare avanti (vedi
	# MinigiocoCombattimento.salta: animare si', sbarrare mai)
	if gioco.fase != "raffica":
		gioco.salta()
		return
	var quale := pugno_sotto(punto - piano.position)
	if quale >= 0:
		gioco.colpisci(quale)


# --- cosa si dice ----------------------------------------------------------

func comincia(nome: String) -> void:
	segni.clear()
	for scritta in scritte:
		scritta.visible = false
	titolo.text = nome.to_upper()
	# QUELLO CHE DEVI FARE, DETTO NEL MOMENTO IN CUI SERVE, e dentro il riquadro
	# dove lo farai: e' la regola di ogni buon tutorial - si insegna al punto
	# del bisogno, non prima e non altrove
	avviso.text = "Clicca ogni pugno quando il cerchio si chiude su di lui."
	avviso.visible = true
	aggiorna(0.0)


func chiudi(esito: Dictionary) -> void:
	# LA FINE DELL'EVENTO, nello stesso riquadro. Non e' una schermata che
	# aspetta: si chiude da sola, e un clic la chiude prima
	var totali := int(esito.get("totali", 0))
	var testo := "Fermati %d su %d" % [int(esito.get("parati", 0)), totali]
	if bool(esito.get("perfetto", false)):
		testo = "Tutti e %d, in pieno" % totali
	var dettagli: Array[String] = []
	if int(esito.get("piene", 0)) > 0 and not bool(esito.get("perfetto", false)):
		dettagli.append("%d in pieno" % int(esito.get("piene", 0)))
	if int(esito.get("striscio", 0)) > 0:
		dettagli.append("%d di striscio" % int(esito.get("striscio", 0)))
	var passati := totali - int(esito.get("parati", 0))
	if passati > 0:
		dettagli.append("%d a segno" % passati)
	avviso.text = testo if dettagli.is_empty() else "%s\n%s" % [testo, "  ·  ".join(dettagli)]


func segna(indice: int, esito: String) -> void:
	# il riscontro di un pugno: si ricicla la scritta piu' vecchia, non se ne
	# crea una nuova
	segni.append({"indice": indice, "esito": esito, "eta": 0.0})
	if segni.size() > SCRITTE:
		segni.pop_front()


func aggiorna(delta: float) -> void:
	if titolo == null:
		return
	# il conto finale aspetta che l'ultimo riscontro sia finito: comparendo
	# subito ci si scriveva sopra, e "COLPITO" e il riepilogo si leggevano
	# tutti e due male
	avviso.visible = gioco.fase == "apertura" or (gioco.fase == "chiusura" and segni.is_empty())
	contatore.text = "%d / %d" % [gioco.arrivati(), gioco.raffica.size()]
	for segno in segni:
		segno.eta = float(segno.eta) + delta
	while not segni.is_empty() and float(segni[0].eta) > DURATA_SEGNO:
		segni.pop_front()
	metti_scritte()
	piano.queue_redraw()


func metti_scritte() -> void:
	var r := raggio()
	for i in scritte.size():
		var scritta := scritte[i]
		if i >= segni.size():
			scritta.visible = false
			continue
		var segno: Dictionary = segni[i]
		var quanto := clampf(float(segno.eta) / DURATA_SEGNO, 0.0, 1.0)
		var pugno: Dictionary = gioco.raffica[int(segno.indice)]
		scritta.visible = true
		scritta.text = testo_del_segno(String(segno.esito))
		scritta.add_theme_color_override("font_color", tinta_della_scritta(String(segno.esito)))
		scritta.size = Vector2(r * 4.0, r)
		# sale un poco mentre sparisce: tranne per chi ha chiesto meno movimento,
		# a cui resta ferma - la parola e' l'informazione, il volo no
		var salita := 0.0 if Impostazioni.movimento_ridotto else quanto * r * 0.6
		scritta.position = centro_di(pugno) - Vector2(r * 2.0, r * 0.5 + salita)
		scritta.modulate.a = 1.0 - quanto * quanto


static func testo_del_segno(esito: String) -> String:
	match esito:
		"piena": return "PARATA"
		"striscio": return "DI STRISCIO"
	return "COLPITO"


static func tinta_della_scritta(esito: String) -> Color:
	# COLPITO e' bianco e non rosso: sta sopra il lampo rosso del colpo, e
	# rosso su rosso non si legge. Il rosso lo dice gia' il lampo
	return Stile.colore("ecg_giallo") if esito == "striscio" else Stile.colore("testo")


static func tinta_del_segno(esito: String) -> Color:
	match esito:
		"piena": return Stile.colore("testo")
		"striscio": return Stile.colore("ecg_giallo")
	return Stile.colore("pericolo")


# --- il disegno ------------------------------------------------------------

func _draw() -> void:
	# il fondo del riquadro: scuro come quello dell'ECG, che e' gia' il
	# linguaggio del pannello per "qui dentro succede una cosa a parte"
	draw_rect(Rect2(Vector2.ZERO, size), Stile.colore("ecg_fondo"))


func _disegna_piano() -> void:
	var r := raggio()
	for pugno in gioco.raffica:
		if gioco.si_vede(pugno):
			disegna_pugno(pugno, r)
	if Impostazioni.movimento_ridotto:
		return
	for segno in segni:
		disegna_scoppio(segno, r)


func disegna_pugno(pugno: Dictionary, r: float) -> void:
	var centro := centro_di(pugno)
	var eta := gioco.tempo - float(pugno.istante)
	var acceso := clampf(eta / COMPARSA, 0.0, 1.0)
	var quanto := clampf(eta / maxf(float(pugno.durata), 0.001), 0.0, 1.0)
	var texture := Disegni.texture(MinigiocoCombattimento.DISEGNO_PUGNO)
	if texture != null:
		piano.draw_texture_rect(texture, Rect2(centro - Vector2(r, r), Vector2(r, r) * 2.0),
				false, Color(1, 1, 1, acceso))
	else:
		piano.draw_circle(centro, r, Color(Stile.colore("pericolo"), acceso))
		piano.draw_arc(centro, r * 0.94, 0.0, TAU, 40, Color(1, 1, 1, 0.75 * acceso),
				maxf(r * 0.10, 2.0), true)
	# IL CERCHIO DI AVVICINAMENTO. Parte largo e si stringe sul pugno in
	# esattamente il tempo che il pugno ci mette ad arrivare: quando lo tocca,
	# e' il momento. Nella finestra piena si fa piu' spesso - e' l'unico
	# cambiamento di forma, e dice "adesso" a chi non ha ancora imparato a
	# leggere la velocita' del cerchio.
	var anello := r * lerpf(SCALA_ANELLO, 1.0, quanto)
	var nella_finestra := gioco.tempo >= float(pugno.piena_da)
	var spessore := maxf(r * (0.14 if nella_finestra else 0.07), 2.0)
	piano.draw_arc(centro, anello, 0.0, TAU, 56, Color(1, 1, 1, 0.9 * acceso), spessore, true)


func disegna_scoppio(segno: Dictionary, r: float) -> void:
	var pugno: Dictionary = gioco.raffica[int(segno.indice)]
	var quanto := clampf(float(segno.eta) / DURATA_SEGNO, 0.0, 1.0)
	var tinta := tinta_del_segno(String(segno.esito))
	var centro := centro_di(pugno)
	if String(segno.esito) == "preso":
		# preso: il pugno si accende di rosso pieno e sparisce, senza allargarsi
		piano.draw_circle(centro, r * (1.0 + quanto * 0.15), Color(tinta, 0.7 * (1.0 - quanto)))
		return
	piano.draw_arc(centro, r * (1.0 + quanto * 0.8), 0.0, TAU, 48,
			Color(tinta, 1.0 - quanto), maxf(r * 0.12 * (1.0 - quanto), 1.0), true)
