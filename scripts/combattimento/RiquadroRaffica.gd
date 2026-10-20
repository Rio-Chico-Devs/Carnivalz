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
# I RISCONTRI COL CORPO (Bru, sugli esempi animati di docs/vita.md: «bello
# tutto»): l'anticipo, il timbro, l'anello della parata, la crepa del colpo preso
const ANTICIPO := 0.5           # nell'ultimo mezzo secondo le tacche corrono verso il pugno
const TACCHE := 8
const TIMBRO := 0.14            # quanto ci mette la parola a cadere
const ANELLO_PARATA := 1.6      # di quanti raggi si allarga l'anello della parata
const RAMI_CREPA := 6

var gioco: MinigiocoCombattimento
var testata: ColorRect
var titolo: Label
var contatore: Label
var piano: Control              # dove vivono i pugni, e taglia quello che esce
var avviso: Label               # cosa fare, all'inizio; com'e' andata, alla fine
var scritte: Array[Label] = []
var segni: Array[Dictionary] = []   # i riscontri in volo: {indice, esito, eta}
var schegge: Schegge                # la parata fa saltare via i ritagli di carta
var stile_nero: StyleBoxFlat        # il timbro: fascia nera (la parata) o rossa (il colpo preso)
var stile_rosso: StyleBoxFlat


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

	# LA PAROLA E' UN TIMBRO: una fascia storta, come le etichette del
	# manifesto, che cade sul pugno. La fascia regge la scritta su qualunque
	# cosa ci sia sotto, il pugno rosso o il lampo del colpo
	var corpo := Stile.dimensione("corpo")
	stile_nero = Manifesto.stile_etichetta(Stile.colore("bordo"), corpo * 0.5, corpo * 0.12)
	stile_rosso = Manifesto.stile_etichetta(Stile.colore("pericolo"), corpo * 0.5, corpo * 0.12)
	for i in SCRITTE:
		var scritta := etichetta(corpo, Stile.colore("testo"))
		scritta.add_theme_font_override("font", Caratteri.titolo())
		scritta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scritta.rotation_degrees = -8.0
		scritta.visible = false
		piano.add_child(scritta)
		scritte.append(scritta)
	schegge = Schegge.new()
	schegge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schegge)
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
	if esito != "preso" and indice >= 0 and indice < gioco.raffica.size():
		para_col_corpo(centro_di(gioco.raffica[indice]))


func para_col_corpo(centro: Vector2) -> void:
	# LA PARATA SI SENTE: le schegge, il piano che sobbalza, il contatore che fa
	# la gelatina. Col movimento ridotto resta solo l'anello
	if Impostazioni.movimento_ridotto:
		return
	schegge.scoppia(piano.get_global_transform() * centro)
	var sobbalzo := piano.create_tween()
	sobbalzo.tween_property(piano, "position:y", ALTEZZA_TESTATA + MARGINE + 4.0, 0.04)
	sobbalzo.tween_property(piano, "position:y", ALTEZZA_TESTATA + MARGINE, 0.18) \
			.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	contatore.pivot_offset = contatore.size * Vector2(0.9, 0.5)
	var gelatina := contatore.create_tween()
	gelatina.tween_property(contatore, "scale", Vector2(1.3, 0.82), 0.05)
	gelatina.tween_property(contatore, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


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
		scritta.add_theme_stylebox_override("normal", stile_rosso if String(segno.esito) == "preso" else stile_nero)
		scritta.size = Vector2.ZERO
		scritta.reset_size()
		scritta.pivot_offset = scritta.size * 0.5
		# cade come un timbro, un poco sopra e a destra del pugno: tranne per chi
		# ha chiesto meno movimento, a cui compare ferma - la parola e'
		# l'informazione, la caduta no
		var caduta := 1.0
		if not Impostazioni.movimento_ridotto:
			caduta = Tween.interpolate_value(0.0, 1.0, clampf(float(segno.eta) / TIMBRO, 0.0, 1.0), 1.0,
					Tween.TRANS_BACK, Tween.EASE_OUT)
		scritta.scale = Vector2.ONE * lerpf(1.8, 1.0, caduta)
		# e resta dentro il piano: vicino al bordo un timbro tagliato non si legge
		var dove := centro_di(pugno) + Vector2(r * 0.4, -r * 1.5) - scritta.size * 0.5
		scritta.position = dove.clamp(Vector2.ONE * 4.0, (piano.size - scritta.size - Vector2.ONE * 4.0).max(Vector2.ONE * 4.0))
		scritta.modulate.a = 1.0 - quanto * quanto


static func testo_del_segno(esito: String) -> String:
	match esito:
		"piena": return "PARATA"
		"striscio": return "DI STRISCIO"
	return "COLPITO"


static func tinta_della_scritta(esito: String) -> Color:
	# sulla fascia nera la parata e' arancio e lo striscio giallo; COLPITO e'
	# bianco sulla fascia rossa
	match esito:
		"piena": return Stile.colore("manifesto")
		"striscio": return Stile.colore("ecg_giallo")
	return Stile.colore("testo")


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
		piano.draw_circle(centro, r, Color(Stile.colore("pericolo"), acceso), true, -1.0, true)
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
	disegna_anticipo(pugno, centro, r)


static func anticipo(pugno: Dictionary, adesso: float) -> float:
	# quanto e' vicino il pugno, da 0 (mezzo secondo prima) a 1 (adesso); -1 se
	# le tacche non vanno disegnate: troppo presto, gia' giudicato, gia' passato
	var manca := float(pugno.impatto) - adesso
	if Impostazioni.movimento_ridotto or String(pugno.get("esito", "")) != "" or manca < 0.0 or manca > ANTICIPO:
		return -1.0
	return 1.0 - manca / ANTICIPO


func disegna_anticipo(pugno: Dictionary, centro: Vector2, r: float) -> void:
	# L'ANTICIPO: nell'ultimo mezzo secondo otto tacche corrono verso il pugno.
	# Dicono «adesso» anche con la coda dell'occhio, mentre guardi un altro
	# pugno. Col movimento ridotto non corrono: lo dice gia' l'anello
	var q := anticipo(pugno, gioco.tempo)
	if q < 0.0:
		return
	var fuori := r * lerpf(2.4, 1.25, q)
	for k in TACCHE:
		var verso := Vector2.from_angle(TAU * float(k) / float(TACCHE) + 0.2)
		piano.draw_line(centro + verso * fuori, centro + verso * (fuori + r * 0.35), Color(1, 1, 1, 0.75 * q),
				maxf(r * 0.08, 2.0), true)


func disegna_scoppio(segno: Dictionary, r: float) -> void:
	var pugno: Dictionary = gioco.raffica[int(segno.indice)]
	var quanto := clampf(float(segno.eta) / DURATA_SEGNO, 0.0, 1.0)
	var tinta := tinta_del_segno(String(segno.esito))
	var centro := centro_di(pugno)
	if String(segno.esito) == "preso":
		# preso: il riquadro si accende di rosso, il pugno si accende e sparisce,
		# e lo schermo si crepa dal punto in cui ti ha preso
		piano.draw_rect(Rect2(Vector2.ZERO, piano.size), Color(tinta, 0.3 * (1.0 - quanto)))
		piano.draw_circle(centro, r * (1.0 + quanto * 0.15), Color(tinta, 0.7 * (1.0 - quanto)), true, -1.0, true)
		disegna_crepa(int(segno.indice), centro, r, quanto)
		return
	# la parata: un anello che si allarga e sparisce
	piano.draw_arc(centro, r * (1.0 + quanto * ANELLO_PARATA), 0.0, TAU, 48,
			Color(tinta, 1.0 - quanto), maxf(r * 0.22 * (1.0 - quanto), 1.0), true)


func disegna_crepa(indice: int, centro: Vector2, r: float, quanto: float) -> void:
	# sei rami storti, sempre gli stessi per lo stesso pugno: crescono nel primo
	# decimo e si spengono nell'ultimo terzo
	var dado := RandomNumberGenerator.new()
	dado.seed = 7919 * (indice + 1)
	var cresce := clampf(quanto / 0.12, 0.0, 1.0)
	var spegne := 1.0 - clampf((quanto - 0.6) / 0.4, 0.0, 1.0)
	for k in RAMI_CREPA:
		var verso := TAU * float(k) / float(RAMI_CREPA) + dado.randf_range(-0.3, 0.3)
		var punto := centro
		var ramo := PackedVector2Array([punto])
		for passo in 4:
			punto += Vector2.from_angle(verso + dado.randf_range(-0.5, 0.5)) * r * dado.randf_range(0.35, 0.7)
			ramo.append(punto)
		var tratto := ramo.slice(0, maxi(2, int(round(cresce * float(ramo.size())))))
		piano.draw_polyline(tratto, Color(Stile.colore("pericolo"), 0.9 * spegne), maxf(r * 0.09, 2.0), true)
		piano.draw_polyline(tratto, Color(1, 1, 1, spegne), maxf(r * 0.035, 1.0), true)
