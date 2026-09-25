class_name RiquadroColpoDiGrazia
extends Control

# IL RIQUADRO DEL COLPO DI GRAZIA: una faccia del quadrante, opaca, col suo
# titolo e il suo bordo, come quelli della raffica e della mazzata.
#
# UNA BARRA, UNA LANCETTA, UN BERSAGLIO. Il bersaglio e' il disegno di Bru
# (art/minigiochi/mattanza_bersaglio.png), largo esattamente quanto la zona
# che vale: due tacche ai suoi lati dicono dove comincia e dove finisce, per
# chi ha un disegno tondo e si chiede se vale anche l'angolo. La lancetta gli
# passa SOPRA, non sotto: e' lei la cosa da guardare.
#
# CENTRATO, IL DISEGNO SI FRANTUMA: mille pezzi (Frantumi.gd), il suono
# "frantumi" e il danno sul nemico nello stesso istante. Le schegge non stanno
# nel riquadro - volano sullo strato dei numeri, sopra tutta la schermata -
# perche' dentro verrebbero tagliate al bordo del quadrante, e una rottura
# tagliata a meta' e' un'animazione, non una rottura.
#
# FINCHE' IL DISEGNO NON C'E' c'e' un bersaglio a cerchi coi colori della
# Mattanza, costruito pixel per pixel una volta sola: stessa misura e stessa
# rottura del disegno vero, quindi il minigioco si gioca e si misura da subito.
#
# IL CLIC CONTA COME IL TASTO, e conta quando premi (non al rilascio).

const DISEGNO := "res://art/minigiochi/mattanza_bersaglio.png"
const LATO_SEGNAPOSTO := 128
const ALTEZZA_TESTATA := 44.0
const MARGINE := 12.0
const ARRIVO := 0.3           # il bersaglio che cade sulla barra, dentro i secondi sordi
const LAMPO := 0.18           # il bianco del colpo: un battito, non una nebbia
const INGRANDIMENTO := 1.6    # il disegno salta verso di te mentre si rompe
# (36 tagli + i 4 angoli) per 25 anelli: mille pezzi, come li ha chiesti Bru.
# Contati, non a occhio: vedi prova_il_colpo_di_grazia_si_centra_col_tempismo
const TAGLI_ROTTURA := 36
const ANELLI_ROTTURA := 25
const SPINTA_ROTTURA := 420.0

static var segnaposto: Texture2D = null

var gioco: ColpoDiGraziaCombattimento
var strato: Control              # dove volano le schegge
var testata: ColorRect
var titolo: Label
var avviso: Label
var lampo := 0.0
var rottura: Control = null      # le schegge in volo, se ce ne sono


func _init(chi: ColpoDiGraziaCombattimento, sopra: Control = null) -> void:
	gioco = chi
	strato = sopra


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	testata = ColorRect.new()
	testata.color = Stile.colore("mattanza")
	testata.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(testata)
	titolo = etichetta(Stile.dimensione("corpo"))
	titolo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	testata.add_child(titolo)
	avviso = etichetta(Stile.dimensione("sezione"))
	avviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avviso.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(avviso)
	resized.connect(disponi)
	disponi()


func etichetta(corpo: int) -> Label:
	var fatta := Label.new()
	fatta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fatta.add_theme_color_override("font_color", Stile.colore("testo"))
	Stile.imposta_corpo(fatta, corpo)
	return fatta


func disponi() -> void:
	if testata == null:
		return
	testata.size = Vector2(size.x, ALTEZZA_TESTATA)
	titolo.position = Vector2(MARGINE, 0.0)
	titolo.size = Vector2(maxf(size.x - MARGINE * 2.0, 1.0), ALTEZZA_TESTATA)
	var piano := rettangolo_piano()
	avviso.position = piano.position
	avviso.size = Vector2(piano.size.x, piano.size.y * 0.38)


# --- le misure: tutto dal rettangolo del pannello ---------------------------

func rettangolo_piano() -> Rect2:
	var alto := ALTEZZA_TESTATA + MARGINE
	return Rect2(Vector2(MARGINE, alto), Vector2(maxf(size.x - MARGINE * 2.0, 1.0),
			maxf(size.y - alto - MARGINE, 1.0)))


func rettangolo_barra() -> Rect2:
	# nella parte bassa del piano, sottile: la barra e' il binario, le cose da
	# guardare sono il bersaglio e la lancetta che ci corrono sopra
	var piano := rettangolo_piano()
	var alta := clampf(piano.size.y * 0.14, 12.0, 30.0)
	var y := piano.position.y + piano.size.y * 0.69 - alta * 0.5
	return Rect2(Vector2(piano.position.x, y), Vector2(piano.size.x, alta))


func rettangolo_zona(barra: Rect2) -> Rect2:
	# quello che vale, in pixel: il centro del bersaglio piu' o meno la tolleranza
	var mezza := float(gioco.regole.get("tolleranza", 0.06)) * barra.size.x
	var centro := barra.position.x + gioco.punto * barra.size.x
	return Rect2(Vector2(centro - mezza, barra.position.y), Vector2(mezza * 2.0, barra.size.y))


func rettangolo_bersaglio(barra: Rect2) -> Rect2:
	# largo quanto la zona, alto quanto ci sta fra l'avviso e il fondo
	var zona := rettangolo_zona(barra)
	var piano := rettangolo_piano()
	var lato := minf(zona.size.x, (piano.end.y - barra.get_center().y) * 2.0 - 4.0)
	return Rect2(Vector2(zona.get_center().x - zona.size.x * 0.5, barra.get_center().y - lato * 0.5),
			Vector2(zona.size.x, lato))


# --- cosa si dice ----------------------------------------------------------

func testo(chiave: String, se_manca: String) -> String:
	return String(gioco.testi.get(chiave, se_manca))


func comincia() -> void:
	titolo.text = testo("titolo", "COLPO DI GRAZIA")
	avviso.text = testo("avviso", "Premi quando la lancetta è sul bersaglio!")
	lampo = 0.0
	AudioManager.interfaccia("apertura")
	aggiorna(0.0)


func tiro(centrato: bool) -> void:
	if centrato:
		avviso.text = testo("testo_centrato", "CENTRATO!")
		if not Impostazioni.movimento_ridotto:
			lampo = LAMPO
		frantuma()
	else:
		avviso.text = testo("testo_mancato", "MANCATO") if gioco.tirato \
				else testo("testo_tardi", "TROPPO TARDI")
		AudioManager.interfaccia("annulla")
	queue_redraw()


func frantuma() -> void:
	# il disegno com'e' a schermo adesso, ingrandito attorno al suo centro, e da
	# li' in mille pezzi. Il suono lo fa partire Frantumi nello stesso istante
	var immagine := disegno_bersaglio()
	var visto := Sagome.dentro(immagine.get_size(), rettangolo_bersaglio(rettangolo_barra()))
	var grande := Rect2(visto.get_center() - visto.size * INGRANDIMENTO * 0.5, visto.size * INGRANDIMENTO)
	grande.position += global_position
	rottura = load("res://scripts/Frantumi.gd").new()
	(strato if is_instance_valid(strato) else self).add_child(rottura)
	rottura.frantuma_immagine(immagine, grande,
			{"tagli": TAGLI_ROTTURA, "anelli": ANELLI_ROTTURA, "spinta": SPINTA_ROTTURA}, "frantumi")


func aggiorna(delta: float) -> void:
	lampo = maxf(lampo - delta, 0.0)
	queue_redraw()


func _gui_input(evento: InputEvent) -> void:
	var premuto := evento is InputEventMouseButton \
			and (evento as InputEventMouseButton).pressed \
			and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	if not premuto:
		return
	accept_event()
	gioco.premi_col_tasto()


# --- il disegno ------------------------------------------------------------

static func disegno_bersaglio() -> Texture2D:
	var suo := Disegni.texture(DISEGNO)
	if suo != null:
		return suo
	if segnaposto == null:
		segnaposto = fai_segnaposto()
	return segnaposto


static func fai_segnaposto() -> Texture2D:
	# UN BERSAGLIO A CERCHI, coi colori della Mattanza, col bordo scuro che lo
	# stacca dalla barra. Pixel per pixel e una volta sola: una texture vera, e
	# non un disegno fatto a ogni fotogramma, perche' e' una texture che si
	# frantuma - e cosi' il segnaposto si rompe per la stessa strada del disegno
	# di Bru, e quando arriva quello non c'e' niente da rifare
	var lato := LATO_SEGNAPOSTO
	var immagine := Image.create(lato, lato, false, Image.FORMAT_RGBA8)
	var colori := [Stile.colore("testo"), Stile.colore("mattanza"), Stile.colore("testo"),
			Stile.colore("mattanza")]
	var bordo := Stile.colore("ecg_fondo")
	var raggio := lato * 0.5
	for y in lato:
		for x in lato:
			var d := Vector2(x + 0.5 - raggio, y + 0.5 - raggio).length() / raggio
			if d > 1.0:
				continue
			var tinta: Color = bordo if d > 0.9 else colori[mini(int(d / 0.225), 3)]
			tinta.a = clampf((1.0 - d) * raggio, 0.0, 1.0)   # il bordo sfuma di un pixel
			immagine.set_pixel(x, y, tinta)
	return ImageTexture.create_from_image(immagine)


func arrivo() -> float:
	# da 0 a 1 nei primi istanti: il bersaglio cade sulla barra mentre la mano
	# che martella non conta ancora
	if gioco.fase != "sordo":
		return 1.0
	return clampf(gioco.tempo_fase / ARRIVO, 0.0, 1.0)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Stile.colore("ecg_fondo"))
	var barra := rettangolo_barra()
	var quanto := arrivo()
	draw_rect(barra, Color(Stile.colore("barra_vuota"), quanto))
	draw_rect(rettangolo_zona(barra), Color(Stile.colore("mattanza"), 0.6 * quanto))
	draw_rect(barra, Color(Stile.colore("testo"), quanto), false, 2.0)
	disegna_bersaglio(barra, quanto)
	disegna_lancetta(barra)
	disegna_tempo(barra)
	if lampo > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(Stile.colore("testo"), 0.35 * lampo / LAMPO))


func disegna_bersaglio(barra: Rect2, quanto: float) -> void:
	if gioco.fase == "chiusura" and gioco.preso:
		return   # e' in pezzi, sullo strato di sopra
	var r := rettangolo_bersaglio(barra)
	if not Impostazioni.movimento_ridotto and quanto < 1.0:
		# cade dall'alto e rimbalza un soffio: si nota che e' arrivato
		var scala: float = Tween.interpolate_value(0.0, 1.0, quanto, 1.0, Tween.TRANS_BACK, Tween.EASE_OUT)
		r = Rect2(r.get_center() - r.size * scala * 0.5, r.size * scala)
	var tinta := Color(1, 1, 1, quanto)
	if gioco.fase == "chiusura":
		tinta = Color(0.55, 0.55, 0.55, 0.6)   # mancato: resta li', spento
	Sagome.disegna_dentro(self, disegno_bersaglio(), r, tinta)
	# le due tacche: dove comincia e dove finisce quello che vale
	var zona := rettangolo_zona(barra)
	var sopra := minf(r.position.y, barra.position.y) - 4.0
	var sotto := maxf(r.end.y, barra.end.y) + 4.0
	for x in [zona.position.x, zona.end.x]:
		draw_line(Vector2(x, sopra), Vector2(x, sotto), Color(Stile.colore("testo"), 0.7 * quanto), 2.0)


func disegna_lancetta(barra: Rect2) -> void:
	var x := barra.position.x + gioco.cursore * barra.size.x
	var r := rettangolo_bersaglio(barra)
	var sopra := minf(r.position.y, barra.position.y) - 10.0
	var sotto := maxf(r.end.y, barra.end.y) + 6.0
	var tinta := Stile.colore("ecg_giallo")
	draw_line(Vector2(x, sopra), Vector2(x, sotto), tinta, 4.0)
	draw_colored_polygon(PackedVector2Array([Vector2(x - 8.0, sopra - 8.0), Vector2(x + 8.0, sopra - 8.0),
			Vector2(x, sopra + 2.0)]), tinta)


func disegna_tempo(barra: Rect2) -> void:
	# il tempo che resta per tirare: pieno finche' la lancetta non parte, poi si
	# accorcia verso sinistra. Come quello della mazzata
	if gioco.fase == "chiusura":
		return
	var tempo := maxf(float(gioco.regole.get("tempo", 3.2)), 0.001)
	var resta := clampf(1.0 - gioco.corsa / tempo, 0.0, 1.0)
	var y := rettangolo_piano().end.y - 2.0
	draw_line(Vector2(barra.position.x, y), Vector2(barra.position.x + barra.size.x * resta, y),
			Stile.colore("testo_smorzato"), 3.0)
