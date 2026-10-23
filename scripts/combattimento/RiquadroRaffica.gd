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

const BOTTO := 0.12             # quanto ci mette un pugno a piantarsi: compare di botto
const SCATTO := 0.09            # e quanto ci mette ad accendersi
const TOLLERANZA_MIRA := 8.0    # pixel oltre il bordo del cerchio che contano ancora
const ALTEZZA_TESTATA := 44.0
const MARGINE := 12.0
const DURATA_SEGNO := 0.55      # quanto resta a schermo "PARATA" / "COLPITO"
const SCRITTE := 4              # quante al massimo insieme: create una volta sola
# I RISCONTRI COL CORPO (Bru, sugli esempi animati di docs/vita.md: «bello
# tutto»): il timbro, l'anello della parata, il vetro che si rompe quando il
# pugno ti prende (VetroRotto.gd). Il cerchio che si stringeva e le tacche che
# correvano non ci sono piu': «quando si chiude quelle linee sono brutte da
# vedere e il fatto che si chiuda e' noioso sembra che ti colpisca piano»
const TIMBRO := 0.14            # quanto ci mette la parola a cadere
const VICINO := 0.3             # di quanto si gonfia il pugno acceso arrivandoti addosso
const SCHIANTO := 0.12          # quanto resta il pugno che ti ha preso, schiacciato sul vetro
const ANELLO_PARATA := 1.6      # di quanti raggi si allarga l'anello della parata

var gioco: MinigiocoCombattimento
var testata: ColorRect
var titolo: Label
var contatore: Label
var piano: Control              # dove vivono i pugni, e taglia quello che esce
var avviso: Label               # cosa fare, all'inizio; com'e' andata, alla fine
var scritte: Array[Label] = []
var segni: Array[Dictionary] = []   # i riscontri in volo: {indice, esito, eta}
var vetri: Array[Dictionary] = []   # i vetri rotti dai pugni presi: {vetro (VetroRotto), tele (TeleVetro), eta}
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
	for vetro in vetri:
		(vetro.tele as TeleVetro).misura(piano.size)


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
	# la stessa misura con cui il calendario ha messo i pugni al loro posto
	var quanti := gioco.raffica.size() if gioco != null and not gioco.raffica.is_empty() else 12
	return minf(piano.size.x, piano.size.y) * Collisioni.lato_pugno(quanti, proporzione()) * 0.5


func centro_di(pugno: Dictionary) -> Vector2:
	# IL PUGNO STA TUTTO DENTRO, anche quando si gonfia. Il centro si sceglie
	# nel rettangolo ridotto di Collisioni.INGOMBRO raggi per lato, quindi il
	# cerchio non tocca mai il bordo del piano - e il piano sta dentro il
	# riquadro, che sta dentro il pannello
	var bordo := raggio() * Collisioni.INGOMBRO
	return Vector2(bordo + float(pugno.x) * maxf(piano.size.x - 2.0 * bordo, 0.0),
			bordo + float(pugno.y) * maxf(piano.size.y - 2.0 * bordo, 0.0))


func pugno_sotto(punto: Vector2) -> int:
	# Il bersaglio e' il CERCHIO, non il quadrato che lo contiene: un Button
	# prendeva anche gli angoli, dove non c'e' disegnato niente. Un po' di
	# tolleranza oltre il bordo si', perche' la mano che ci arriva di corsa si
	# ferma spesso un filo corta (e' la legge di Fitts: un bersaglio si prende
	# tanto meglio quanto e' largo). Quello acceso e' piu' grande, e la sua
	# portata cresce con lui.
	#
	# I pugni non si toccano mai (Collisioni.posti), ma la tolleranza si': nel
	# dubbio vince quello acceso, poi il piu' vicino.
	var scelto := -1
	var meglio := INF
	for pugno in gioco.raffica:
		if not gioco.si_vede(pugno):
			continue
		var quanto_lontano := punto.distance_to(centro_di(pugno))
		if quanto_lontano > raggio() * scala_di(pugno) + TOLLERANZA_MIRA:
			continue
		if float(pugno.accesa_da) >= 0.0:
			quanto_lontano -= 10000.0
		if quanto_lontano < meglio:
			meglio = quanto_lontano
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
	for vetro in vetri:
		(vetro.tele as TeleVetro).queue_free()
	vetri.clear()
	for scritta in scritte:
		scritta.visible = false
	titolo.text = nome.to_upper()
	# QUELLO CHE DEVI FARE, DETTO NEL MOMENTO IN CUI SERVE, e dentro il riquadro
	# dove lo farai: e' la regola di ogni buon tutorial - si insegna al punto
	# del bisogno, non prima e non altrove
	avviso.text = "Clicca il pugno che si accende, prima che ti arrivi."
	avviso.visible = true
	aggiorna(0.0)


func chiudi(esito: Dictionary) -> void:
	# LA FINE DELL'EVENTO, nello stesso riquadro. Non e' una schermata che
	# aspetta: si chiude da sola, e un clic la chiude prima
	var totali := int(esito.get("totali", 0))
	var passati := totali - int(esito.get("parati", 0))
	avviso.text = "Tutti e %d, parati" % totali if bool(esito.get("perfetto", false)) \
			else "Fermati %d su %d\n%d a segno" % [int(esito.get("parati", 0)), totali, passati]


func segna(indice: int, esito: String) -> void:
	# il riscontro di un pugno: si ricicla la scritta piu' vecchia, non se ne
	# crea una nuova
	segni.append({"indice": indice, "esito": esito, "eta": 0.0})
	if segni.size() > SCRITTE:
		segni.pop_front()
	if esito == "preso" and indice >= 0 and indice < gioco.raffica.size():
		rompi_il_vetro(indice)
	if esito != "preso" and indice >= 0 and indice < gioco.raffica.size():
		para_col_corpo(centro_di(gioco.raffica[indice]))


func rompi_il_vetro(indice: int) -> void:
	# il pugno ti ha preso: il vetro dello schermo si rompe da li', ogni volta
	# in un modo suo. Sopra i pugni e sotto i timbri: COLPITO si deve leggere
	var vetro := VetroRotto.new(7919 * (indice + 1), centro_di(gioco.raffica[indice]),
			Rect2(Vector2.ZERO, piano.size), raggio())
	var tele := TeleVetro.new(vetro)
	piano.add_child(tele)
	piano.move_child(tele, scritte[0].get_index())
	tele.misura(piano.size)
	tele.mostra(0.0, Impostazioni.movimento_ridotto)
	vetri.append({"vetro": vetro, "tele": tele, "eta": 0.0})


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
	contatore.text = "%d / %d" % [gioco.decisi(), gioco.raffica.size()]
	for segno in segni:
		segno.eta = float(segno.eta) + delta
	while not segni.is_empty() and float(segni[0].eta) > DURATA_SEGNO:
		segni.pop_front()
	for vetro in vetri:
		vetro.eta = float(vetro.eta) + delta
		(vetro.tele as TeleVetro).mostra(float(vetro.eta), Impostazioni.movimento_ridotto)
	while not vetri.is_empty() and float(vetri[0].eta) > VetroRotto.DURATA:
		(vetri.pop_front().tele as TeleVetro).queue_free()
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
		# e resta dentro il piano: vicino al bordo un timbro tagliato non si legge.
		# COLPITO cade di fianco, verso il centro del riquadro: sopra coprirebbe
		# il punto in cui il vetro si spacca
		var sopra := Vector2(r * 0.4, -r * 1.5)
		if String(segno.esito) == "preso":
			var verso := -1.0 if centro_di(pugno).x > piano.size.x * 0.5 else 1.0
			sopra = Vector2(verso * (r * 1.7 + scritta.size.x * 0.5), -r * 0.2)
		var dove := centro_di(pugno) + sopra - scritta.size * 0.5
		scritta.position = dove.clamp(Vector2.ONE * 4.0, (piano.size - scritta.size - Vector2.ONE * 4.0).max(Vector2.ONE * 4.0))
		scritta.modulate.a = 1.0 - quanto * quanto


static func testo_del_segno(esito: String) -> String:
	return "PARATA" if esito == "parata" else "COLPITO"


static func tinta_della_scritta(esito: String) -> Color:
	# sulla fascia nera la parata e' arancio; COLPITO e' bianco sulla fascia rossa
	return Stile.colore("manifesto") if esito == "parata" else Stile.colore("testo")


static func tinta_spento() -> Color:
	# SPENTO E' IN PENOMBRA, acceso e' il rosso pieno col bordo bianco: dodici
	# a schermo, e quello giusto si deve trovare con la coda dell'occhio
	return Stile.colore("pericolo").darkened(0.58)


static func tinta_acceso() -> Color:
	return Stile.colore("pericolo").lightened(0.08)


static func tinta_del_segno(esito: String) -> Color:
	return Stile.colore("testo") if esito == "parata" else Stile.colore("pericolo")


# --- il disegno ------------------------------------------------------------

func _draw() -> void:
	# il fondo del riquadro: scuro come quello dell'ECG, che e' gia' il
	# linguaggio del pannello per "qui dentro succede una cosa a parte"
	draw_rect(Rect2(Vector2.ZERO, size), Stile.colore("ecg_fondo"))


func _disegna_piano() -> void:
	var r := raggio()
	# prima quelli spenti, poi quello acceso: il suo alone ci passa sopra
	var acceso: Dictionary = {}
	for pugno in gioco.raffica:
		if not gioco.si_vede(pugno):
			continue
		if float(pugno.accesa_da) >= 0.0:
			acceso = pugno
		else:
			disegna_pugno(pugno, r)
	if not acceso.is_empty():
		disegna_pugno(acceso, r)
	if Impostazioni.movimento_ridotto:
		return
	for segno in segni:
		disegna_scoppio(segno, r)


func scala_di(pugno: Dictionary) -> float:
	# QUANTO E' GROSSO ADESSO. Compare DI BOTTO: piantato un filo piu' grande, e
	# rientra in un attimo. Acceso, scatta in avanti e poi si gonfia sempre piu'
	# in fretta - e' un pugno che ti arriva in faccia, e quando e' grosso del
	# tutto ti ha preso. E' il tempo che resta, detto senza un cerchio. Col
	# movimento ridotto non scatta e non si gonfia: lo dice la luce
	if Impostazioni.movimento_ridotto:
		return 1.0
	var botto := clampf((gioco.tempo - float(pugno.istante)) / BOTTO, 0.0, 1.0)
	var scala := lerpf(1.4, 1.0, 1.0 - pow(1.0 - botto, 3.0))
	if float(pugno.accesa_da) >= 0.0:
		var da := gioco.tempo - float(pugno.accesa_da)
		var arriva := clampf(da / maxf(float(pugno.finestra), 0.001), 0.0, 1.0)
		scala = (1.08 + VICINO * arriva * arriva) * lerpf(1.18, 1.0, clampf(da / SCATTO, 0.0, 1.0))
	return scala


func disegna_pugno(pugno: Dictionary, r: float) -> void:
	var centro := centro_di(pugno)
	var acceso := float(pugno.accesa_da) >= 0.0
	var lampo := 1.0 - clampf((gioco.tempo - float(pugno.istante)) / BOTTO, 0.0, 1.0)
	var arriva := 0.0
	if acceso:
		arriva = clampf((gioco.tempo - float(pugno.accesa_da)) / maxf(float(pugno.finestra), 0.001), 0.0, 1.0)
		if not Impostazioni.movimento_ridotto:
			# trema sempre di piu': sta per arrivare
			var da := gioco.tempo - float(pugno.accesa_da)
			centro += Vector2(sin(da * 61.0), cos(da * 47.0)) * r * 0.07 * arriva
	var grande := r * scala_di(pugno)
	var rosso := Stile.colore("pericolo")
	if acceso:
		# l'alone: tre giri sempre piu' larghi e piu' tenui, e pulsa
		var pulsa := 0.75 + 0.25 * sin((gioco.tempo - float(pugno.accesa_da)) * TAU * 6.0)
		for k in 3:
			piano.draw_circle(centro, grande * (1.12 + 0.13 * float(k)),
					Color(rosso.lightened(0.25), (0.22 - 0.06 * float(k)) * pulsa), true, -1.0, true)
	var texture := Disegni.texture(MinigiocoCombattimento.DISEGNO_PUGNO)
	if texture != null:
		var tinta := Color.WHITE if acceso else Color(0.42, 0.42, 0.46)
		piano.draw_texture_rect(texture, Rect2(centro - Vector2(grande, grande), Vector2(grande, grande) * 2.0),
				false, tinta.lerp(Color.WHITE, lampo))
	else:
		var pieno := tinta_acceso() if acceso else tinta_spento()
		piano.draw_circle(centro, grande, pieno.lerp(Color.WHITE, lampo * 0.85), true, -1.0, true)
		var bordo := Color(1, 1, 1, 0.95) if acceso else Color(rosso, 0.55)
		piano.draw_arc(centro, grande * 0.93, 0.0, TAU, 48, bordo, maxf(r * (0.13 if acceso else 0.06), 1.5), true)
	if acceso and arriva > 0.6 and not Impostazioni.movimento_ridotto:
		# l'ultimo tratto: il bianco gli sale dentro
		piano.draw_circle(centro, grande * 0.93, Color(1, 1, 1, (arriva - 0.6) * 0.6), true, -1.0, true)


func disegna_scoppio(segno: Dictionary, r: float) -> void:
	var pugno: Dictionary = gioco.raffica[int(segno.indice)]
	var quanto := clampf(float(segno.eta) / DURATA_SEGNO, 0.0, 1.0)
	var tinta := tinta_del_segno(String(segno.esito))
	var centro := centro_di(pugno)
	if String(segno.esito) == "preso":
		# preso: il pugno si schianta sul vetro - si allarga di colpo e se ne
		# va in un attimo, dietro le crepe; il vetro, il rosso e il resto li
		# disegna VetroRotto. Restava un quinto di secondo col bordo bianco, e
		# il vetro lo scomponeva in un anello arcobaleno
		var u := clampf(float(segno.eta) / SCHIANTO, 0.0, 1.0)
		if u < 1.0:
			piano.draw_circle(centro, r * (1.08 + VICINO) * lerpf(1.0, 1.15, sqrt(u)),
					Color(tinta_acceso(), (1.0 - u) * (1.0 - u)), true, -1.0, true)
		return
	# la parata: un anello che si allarga e sparisce
	piano.draw_arc(centro, r * (1.0 + quanto * ANELLO_PARATA), 0.0, TAU, 48,
			Color(tinta, 1.0 - quanto), maxf(r * 0.22 * (1.0 - quanto), 1.0), true)

