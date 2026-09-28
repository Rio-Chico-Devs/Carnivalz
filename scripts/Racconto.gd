class_name Racconto
extends Control

# IL RACCONTO A SCHERMO INTERO: come si aprono il gioco e i livelli.
#
# Bru: «non vogliamo il dialogue box per le narrazioni di inizio livello o di
# inizio gioco, vogliamo che siano narrate come nelle introduzioni dei livelli
# di Final Fantasy Crystal Chronicles, ovvero a paragrafi che pero' compaiono
# come se scritti da una macchina da scrivere [...] il testo appare nella zona
# centrale, ci sono o video o immagini in bg a ogni nuovo paragrafo, intorno un
# leggero fade, la narrazione e' dolce e nostalgica come il racconto di una
# favola prima di dormire». E: «ne faremo il fulcro del testo del gioco».
#
# COME E' FATTO, dal fondo verso chi guarda:
#   il nero          sempre: il racconto comincia e finisce nel buio
#   due quadri       l'immagine del paragrafo e quella di prima, per sfumare
#                    dall'una all'altra; si avvicinano piano mentre si legge
#   un video         al posto dei quadri, se il paragrafo ne porta uno
#   la luce          un chiarore caldo che respira, perche' senza immagini il
#                    nero pieno e' uno schermo spento, non una notte
#   la vignetta      i bordi che scuriscono: il «leggero fade» intorno
#   l'ombra          un alone scuro dietro il testo, che si legga sopra qualunque disegno
#   il testo         al centro, in una calligrafia da favola (art/font/fiaba.ttf),
#                    scritto dalla STESSA macchina del box, con lo stesso suono
#                    (MacchinaDaScrivere.gd) ma piu' piano
#   la scritta       CARNIVALZ, alla fine dell'introduzione
#
# UNA BATTUTA, UNO O PIU' PARAGRAFI. Nei dati una battuta e' {"tipo":
# "racconto", "testo", "sfondo" o "video"}; una riga vuota dentro il testo la
# divide in paragrafi che arrivano uno dopo l'altro sulla stessa immagine.
#
# LA MANO: un clic (o Invio, Spazio) completa il paragrafo che si sta
# scrivendo, il successivo porta al paragrafo dopo. Mentre l'immagine cambia la
# mano non conta, e durante la scritta nemmeno: la scritta NON si salta.
#
# Tutti i numeri stanno in data/stile.json, sezione "racconto", e sono miei:
# si girano da li'.

signal avanti            # finita la battuta: chi racconta passa alla prossima
signal scrittura_finita  # l'ultimo paragrafo di una battuta e' scritto
signal chiuso            # il racconto se n'e' andato: la scena torna padrona

const DI_SERIE := {
	"passo": 0.62, "respiro": 1.6, "corpo": 58, "peso": 400, "larghezza": 0.6, "righe_massime": 5,
	"apertura": 1.4, "cambio_sfondo": 1.6, "sparizione": 0.6, "chiusura": 1.2,
	"avvicinamento": 0.05, "durata_avvicinamento": 18.0, "luce": 0.16, "respiro_luce": 4.0,
	"vignetta": 0.92, "ombra": 0.62,
	"logo_buio": 1.8, "logo_silenzio": 1.2, "logo_entrata": 3.4, "logo_tenuta": 3.2,
	"logo_uscita": 3.4, "logo_vuoto": 2.4, "logo_crescita": 0.06, "inchiostro": 0.5, "risalita": 4.0,
}
const SCRITTA_SENZA_DISEGNO := "CARNIVALZ"

var nero: ColorRect
var quadri: Array[TextureRect] = []
var acceso := 0                  # quale dei due quadri si sta guardando
var video: VideoStreamPlayer = null
var luce: TextureRect
var vignetta: TextureRect
var ombra: TextureRect
var testo: RichTextLabel
var segno: Label                 # il triangolino che respira quando si puo' andare avanti
var logo: Control
var macchina: MacchinaDaScrivere
var inchiostro: Inchiostro       # come affiorano le lettere che la macchina scopre
var paragrafi: PackedStringArray = []
var paragrafo := 0
# "" chiuso, "cambio" l'immagine sta cambiando, "scrive", "legge" il paragrafo
# e' scritto e aspetta la mano, "scritta" e "vuoto" il titolo e il nero dopo,
# "chiusura" sta sfumando via. La mano conta solo in "scrive" e "legge"
var fase := ""
var tween_luce: Tween
var tween_segno: Tween
var tween_paragrafo: Tween       # il passaggio da un paragrafo all'altro, finche' e' in volo


func _init() -> void:
	macchina = MacchinaDaScrivere.new()   # figlia da subito, come nel box
	add_child(macchina)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	nero = ColorRect.new()
	nero.color = Color.BLACK
	a_tutto_schermo(nero)
	for i in 2:
		var quadro := TextureRect.new()
		quadro.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		quadro.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		quadro.modulate.a = 0.0
		a_tutto_schermo(quadro)
		quadri.append(quadro)
	luce = sfumatura(colore("colore_luce", "#e9b872"), Color(0, 0, 0, 0), 0.0, 0.7)
	luce.modulate.a = 0.0
	vignetta = sfumatura(Color(0, 0, 0, 0), Color(0, 0, 0, numero("vignetta")), 0.42, 1.0)
	ombra = sfumatura(Color(0, 0, 0, numero("ombra")), Color(0, 0, 0, 0), 0.0, 0.72)
	ombra.anchor_top = 0.22
	ombra.anchor_bottom = 0.78
	prepara_testo()
	prepara_segno()
	macchina.passo = numero("passo")
	macchina.respiro = numero("respiro")
	macchina.finita.connect(_scritto)
	resized.connect(_al_cambio_di_misura)


func numero(nome: String) -> float:
	return float(Stile.dati.get("racconto", {}).get(nome, DI_SERIE.get(nome, 0.0)))


func colore(nome: String, ripiego: String) -> Color:
	return Color.html(String(Stile.dati.get("racconto", {}).get(nome, ripiego)))


func a_tutto_schermo(nodo: Control) -> void:
	nodo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	nodo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(nodo)


func sfumatura(dentro: Color, fuori: Color, da: float, a: float) -> TextureRect:
	# un cerchio sfumato grande quanto lo schermo: da "dentro" al centro a
	# "fuori" sui bordi. Serve tre volte - la luce, la vignetta, l'ombra
	var gradiente := Gradient.new()
	gradiente.set_offset(0, da)
	gradiente.set_color(0, dentro)
	gradiente.set_offset(1, a)
	gradiente.set_color(1, fuori)
	var disegno := GradientTexture2D.new()
	disegno.gradient = gradiente
	disegno.fill = GradientTexture2D.FILL_RADIAL
	disegno.fill_from = Vector2(0.5, 0.5)
	disegno.fill_to = Vector2(1.0, 0.5)
	disegno.width = 256
	disegno.height = 256
	var rettangolo := TextureRect.new()
	rettangolo.texture = disegno
	rettangolo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rettangolo.stretch_mode = TextureRect.STRETCH_SCALE
	a_tutto_schermo(rettangolo)
	return rettangolo


func prepara_testo() -> void:
	testo = RichTextLabel.new()
	testo.bbcode_enabled = true
	testo.fit_content = true
	testo.scroll_active = false
	testo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# LE RIGHE NON SI SPOSTANO MENTRE SI SCRIVONO. Col comportamento di serie
	# una riga centrata si ricentra a ogni lettera, e il testo ondeggia: qui la
	# pagina si impagina tutta prima, e le lettere compaiono al loro posto
	testo.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	var margine := (1.0 - numero("larghezza")) * 0.5
	testo.anchor_left = margine
	testo.anchor_right = 1.0 - margine
	testo.anchor_top = 0.5
	testo.anchor_bottom = 0.5
	testo.grow_vertical = Control.GROW_DIRECTION_BOTH
	var corpo := int(numero("corpo"))
	# IL CARATTERE DELLE FAVOLE: Bru lo vuole «piu' elegante e fiabesco», e il
	# tondo del menu non lo era. E' in art/font/fiaba.ttf (vedi font.fiaba)
	var carattere := Caratteri.fiaba(int(numero("peso")))
	if carattere != null:
		testo.add_theme_font_override("normal_font", carattere)
	# il corpo e basta, senza la crenatura dei titoli: questo e' testo da leggere,
	# e stringerlo lo renderebbe solo piu' faticoso (vedi Stile.crenatura)
	testo.add_theme_font_size_override("normal_font_size", corpo)
	# righe compatte: una calligrafia ha l'occhio piccolo, e a 1,5 volte il
	# corpo le righe galleggiavano lontane come frasi separate
	Stile.interlinea(testo, "compatta", corpo)
	testo.add_theme_color_override("default_color", colore("colore_testo", "#f3ead7"))
	# LE LETTERE AFFIORANO invece di accendersi (Bru: «un po' di fade mentre
	# viene scritto»): vedi Inchiostro.gd
	inchiostro = Inchiostro.new()
	inchiostro.durata = numero("inchiostro")
	inchiostro.risalita = numero("risalita")
	inchiostro.fresco = colore("colore_luce", "#e9b872")
	testo.install_effect(inchiostro)
	Stile.contorno(testo, corpo)
	add_child(testo)


func prepara_segno() -> void:
	segno = Label.new()
	segno.text = "▼"
	segno.mouse_filter = Control.MOUSE_FILTER_IGNORE
	segno.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	segno.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	segno.add_theme_color_override("font_color", colore("colore_testo", "#f3ead7"))
	segno.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	segno.offset_top = -96
	segno.offset_bottom = -64
	segno.offset_left = -40
	segno.offset_right = 40
	segno.visible = false
	add_child(segno)


func _al_cambio_di_misura() -> void:
	# i quadri si avvicinano dal centro, non dall'angolo in alto a sinistra
	for quadro in quadri:
		quadro.pivot_offset = size * 0.5


# --- la mano ------------------------------------------------------------------

func _gui_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.pressed \
			and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		premi()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		premi()


func premi() -> void:
	match fase:
		"scrive":
			macchina.completa()
		"legge":
			if paragrafo < paragrafi.size() - 1:
				paragrafo += 1
				mostra_paragrafo(0.0)
			else:
				nascondi_segno()
				avanti.emit()
		_:
			pass   # l'immagine che cambia, la scritta, il vuoto: la mano aspetta


# --- i paragrafi -----------------------------------------------------------------

static func dividi(contenuto: String) -> PackedStringArray:
	var pezzi := PackedStringArray()
	for pezzo in contenuto.split("\n\n", false):
		if pezzo.strip_edges() != "":
			pezzi.append(pezzo.strip_edges())
	if pezzi.is_empty():
		pezzi.append("")
	return pezzi


func impagina(pezzi: PackedStringArray) -> PackedStringArray:
	# UN PARAGRAFO TROPPO LUNGO GIRA PAGINA. Una calligrafia si scrive grande, e
	# il paragrafo di Meridia (340 lettere) faceva sette righe: arrivava fin
	# sotto il triangolino. Non si rimpicciolisce: si divide dove finisce una
	# frase, come si gira pagina in un libro, e le parole restano quelle
	var massimo := int(numero("righe_massime"))
	if massimo <= 0 or testo.size.x < 1.0:
		return pezzi
	var scritto_prima := testo.text   # misurare non cambia quello che si vede
	var visibile_prima := testo.visible_ratio
	var pagine := PackedStringArray()
	for pezzo in pezzi:
		var pagina := ""
		for frase in frasi(pezzo):
			var con_questa := frase if pagina == "" else pagina + " " + frase
			if pagina != "" and righe(con_questa) > massimo:
				pagine.append(pagina)
				pagina = frase
			else:
				pagina = con_questa
		pagine.append(pagina)
	testo.text = scritto_prima
	testo.visible_ratio = visibile_prima
	return pagine


func righe(pagina: String) -> int:
	testo.text = "[center]%s[/center]" % pagina
	return testo.get_line_count()


static func frasi(pezzo: String) -> PackedStringArray:
	# dove finisce una frase: . ! ? o i puntini (anche dentro le virgolette che
	# la chiudono), poi uno spazio e una maiuscola. «lente... la terra trema»
	# e' una frase sola: dopo i puntini viene la minuscola
	var fuori := PackedStringArray()
	var inizio := 0
	for i in range(1, pezzo.length() - 1):
		var dopo := pezzo[i + 1]
		if pezzo[i] != " " or (dopo == dopo.to_lower() and not dopo in "«\"“"):
			continue
		var prima := pezzo[i - 1]
		if prima in "»\"”" and i > 1:
			prima = pezzo[i - 2]
		if prima in ".!?…":
			fuori.append(pezzo.substr(inizio, i - inizio))
			inizio = i + 1
	fuori.append(pezzo.substr(inizio))
	return fuori


func racconta(msg: Dictionary, contenuto: String) -> void:
	# UNA BATTUTA DEL RACCONTO. Se il racconto non c'era si apre nel buio, e
	# l'immagine arriva prima delle parole
	if String(msg.get("tipo", "")) == "scritta":
		scritta(String(msg.get("file", "")), float(msg.get("attesa", 0.0)))
		return
	var appena_aperto := not visible
	if appena_aperto:
		apri()
	paragrafi = impagina(dividi(contenuto))
	paragrafo = 0
	var attesa := cambia_sfondo(msg)
	mostra_paragrafo(maxf(attesa, numero("apertura")) if appena_aperto else attesa)


func apri() -> void:
	visible = true
	modulate.a = 1.0
	testo.text = ""
	testo.modulate.a = 0.0
	if logo != null:
		logo.modulate.a = 0.0
	for quadro in quadri:
		quadro.modulate.a = 0.0
	respira_la_luce()


func mostra_paragrafo(aspetta: float) -> void:
	fase = "cambio"
	nascondi_segno()
	ferma_il_passaggio()
	tween_paragrafo = create_tween()
	if testo.text != "" and testo.modulate.a > 0.01:
		tween_paragrafo.tween_property(testo, "modulate:a", 0.0, numero("sparizione"))
	if aspetta > 0.0:
		tween_paragrafo.tween_interval(aspetta)
	tween_paragrafo.tween_callback(scrivi_paragrafo)


func ferma_il_passaggio() -> void:
	# UN PARAGRAFO IN ARRIVO NON ARRIVA SOPRA LA SCRITTA. Se la scritta (o la
	# chiusura) comincia mentre un paragrafo aspetta la sua immagine, quel
	# paragrafo non si deve piu' scrivere: si vedeva il triangolino sul logo
	if tween_paragrafo != null and tween_paragrafo.is_valid():
		tween_paragrafo.kill()


func _process(delta: float) -> void:
	# l'orologio dell'inchiostro, e le lettere che la macchina ha appena scoperto
	inchiostro.adesso += delta
	if fase == "scrive" or fase == "legge":
		var visibili := testo.visible_characters
		inchiostro.segna(visibili if visibili >= 0 else testo.get_total_character_count())


func scrivi_paragrafo() -> void:
	if fase != "cambio":
		return
	testo.text = "[center][inchiostro]%s[/inchiostro][/center]" % paragrafi[paragrafo]
	testo.visible_ratio = 0.0
	testo.modulate.a = 1.0
	inchiostro.ricomincia()
	fase = "scrive"
	macchina.scrivi(testo, "", "narrazione")


func _scritto() -> void:
	if fase != "scrive":
		return
	fase = "legge"
	mostra_segno()
	if paragrafo >= paragrafi.size() - 1:
		scrittura_finita.emit()


func mostra_segno() -> void:
	segno.visible = true
	segno.modulate.a = 0.0
	if tween_segno != null and tween_segno.is_valid():
		tween_segno.kill()
	var battito := Stile.tempo("battito_indicatore") * 1.6
	tween_segno = create_tween().set_loops()
	tween_segno.tween_property(segno, "modulate:a", 0.7, battito)
	tween_segno.tween_property(segno, "modulate:a", 0.1, battito)


func nascondi_segno() -> void:
	segno.visible = false
	if tween_segno != null and tween_segno.is_valid():
		tween_segno.kill()


# --- le immagini --------------------------------------------------------------------

func cambia_sfondo(msg: Dictionary) -> float:
	# quanto aspettare prima di scrivere: il tempo che l'immagine nuova ci mette
	# ad arrivare, o niente se resta quella di prima. Un disegno che non c'e'
	# ancora non ferma niente: resta quello che c'era, come in tutto il gioco
	var filmato := String(msg.get("video", ""))
	if filmato != "":
		if ResourceLoader.exists(filmato):
			metti_video(load(filmato) as VideoStream)
			return numero("cambio_sfondo")
		push_warning("Sfondo di scena mancante: " + filmato)
	var percorso := String(msg.get("sfondo", ""))
	if percorso == "":
		return 0.0
	if not ResourceLoader.exists(percorso):
		push_warning("Sfondo di scena mancante: " + percorso)
		return 0.0
	var immagine: Texture2D = load(percorso)
	if quadri[acceso].texture == immagine and quadri[acceso].modulate.a > 0.5:
		return 0.0
	togli_video()
	sfuma_verso(immagine)
	return numero("cambio_sfondo")


func sfuma_verso(immagine: Texture2D) -> void:
	var vecchio := quadri[acceso]
	acceso = 1 - acceso
	var nuovo := quadri[acceso]
	nuovo.texture = immagine
	nuovo.scale = Vector2.ONE
	nuovo.modulate.a = 0.0
	move_child(nuovo, vecchio.get_index())   # il nuovo sotto, il vecchio sfuma via sopra
	var durata := numero("cambio_sfondo")
	var sfumo := create_tween().set_parallel(true)
	sfumo.tween_property(nuovo, "modulate:a", 1.0, durata)
	sfumo.tween_property(vecchio, "modulate:a", 0.0, durata)
	if not Impostazioni.movimento_ridotto:
		# LA PAGINA SI AVVICINA mentre la leggi: piano, perche' si senta e non
		# si veda. E' il movimento dei libri illustrati al cinema
		var crescita := 1.0 + numero("avvicinamento")
		create_tween().tween_property(nuovo, "scale", Vector2(crescita, crescita),
				numero("durata_avvicinamento")).set_trans(Tween.TRANS_SINE)


func metti_video(filmato: VideoStream) -> void:
	if video == null:
		video = VideoStreamPlayer.new()
		video.expand = true
		video.loop = true
		video.mouse_filter = Control.MOUSE_FILTER_IGNORE
		video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(video)
		move_child(video, maxi(quadri[0].get_index(), quadri[1].get_index()) + 1)
	video.stream = filmato
	video.modulate.a = 0.0
	video.play()
	create_tween().tween_property(video, "modulate:a", 1.0, numero("cambio_sfondo"))


func togli_video() -> void:
	if video != null:
		video.stop()
		video.modulate.a = 0.0


func respira_la_luce() -> void:
	if tween_luce != null and tween_luce.is_valid():
		tween_luce.kill()
	var piena := numero("luce")
	if Impostazioni.movimento_ridotto:
		luce.modulate.a = piena
		return
	tween_luce = create_tween().set_loops()
	tween_luce.tween_property(luce, "modulate:a", piena, numero("respiro_luce")).set_trans(Tween.TRANS_SINE)
	tween_luce.tween_property(luce, "modulate:a", piena * 0.55, numero("respiro_luce")).set_trans(Tween.TRANS_SINE)


# --- la scritta ------------------------------------------------------------------

func scritta(percorso: String, tenuta: float) -> void:
	# LA SCRITTA DI CARNIVALZ, alla fine dell'introduzione. Bru: «non deve essere
	# skippabile, deve apparire in fade in fade out maestosamente e lasciare
	# spazio scenico, vuoto cinematografico, proprio da preludio».
	#
	# Quindi: tutto torna nel buio, un silenzio, poi la scritta sale piano,
	# resta, se ne va piano - e dopo resta il nero, ancora un poco, prima che
	# si apra la stanza. Nessun tasto la accorcia: in "scritta" e in "vuoto" la
	# mano non conta (vedi premi)
	if not visible:
		apri()
	fase = "scritta"
	ferma_il_passaggio()
	macchina.ferma()
	nascondi_segno()
	prepara_logo(percorso)
	var buio := numero("logo_buio")
	var spegni := create_tween().set_parallel(true)
	for cosa: CanvasItem in [testo, luce, quadri[0], quadri[1]]:
		spegni.tween_property(cosa, "modulate:a", 0.0, buio)
	if tween_luce != null and tween_luce.is_valid():
		tween_luce.kill()
	togli_video()
	var entrata := numero("logo_entrata")
	var resta := maxf(tenuta, numero("logo_tenuta"))
	var uscita := numero("logo_uscita")
	var titolo := create_tween()
	titolo.tween_interval(buio + numero("logo_silenzio"))
	titolo.tween_property(logo, "modulate:a", 1.0, entrata).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	titolo.tween_interval(resta)
	titolo.tween_property(logo, "modulate:a", 0.0, uscita).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	titolo.tween_callback(func() -> void: fase = "vuoto")
	titolo.tween_interval(numero("logo_vuoto"))
	titolo.tween_callback(func() -> void: avanti.emit())
	if not Impostazioni.movimento_ridotto:
		# e intanto cresce, di pochissimo, per tutto il tempo in cui si vede
		var cresce := create_tween()
		cresce.tween_interval(buio + numero("logo_silenzio"))
		cresce.tween_property(logo, "scale", Vector2.ONE * (1.0 + numero("logo_crescita")),
				entrata + resta + uscita).set_trans(Tween.TRANS_SINE)


func prepara_logo(percorso: String) -> void:
	# il disegno di Bru, quando c'e'; finche' manca, il nome scritto - la scena
	# esiste lo stesso e se ne prova il ritmo, che e' la cosa che conta qui
	if logo != null:
		logo.queue_free()
	if percorso != "" and ResourceLoader.exists(percorso):
		var disegno := TextureRect.new()
		disegno.texture = load(percorso)
		disegno.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		disegno.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		disegno.anchor_left = 0.2
		disegno.anchor_right = 0.8
		disegno.anchor_top = 0.28
		disegno.anchor_bottom = 0.72
		logo = disegno
	else:
		var nome := Label.new()
		nome.text = SCRITTA_SENZA_DISEGNO
		if Caratteri.titolo() != null:
			nome.add_theme_font_override("font", Caratteri.titolo())
		var corpo := Stile.dimensione("titolo") * 3
		nome.add_theme_font_size_override("font_size", corpo)
		nome.add_theme_color_override("font_color", Stile.colore("accento"))
		Stile.contorno(nome, corpo)
		nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nome.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		nome.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		logo = nome
	var fatto := logo
	fatto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fatto.modulate.a = 0.0
	add_child(fatto)
	# cresce dal suo centro, non dall'angolo in alto a sinistra
	fatto.resized.connect(func() -> void: fatto.pivot_offset = fatto.size * 0.5)
	fatto.pivot_offset = fatto.size * 0.5


# --- la fine ----------------------------------------------------------------------

func chiudi(poi: Callable) -> void:
	# IL RACCONTO SE NE VA SFUMANDO, e dietro c'e' gia' la scena: e' cosi' che
	# dal buio si trova il primo box. Mentre sfuma la mano non conta
	fase = "chiusura"
	ferma_il_passaggio()
	macchina.ferma()
	nascondi_segno()
	var via := create_tween()
	via.tween_property(self, "modulate:a", 0.0, numero("chiusura"))
	via.tween_callback(func() -> void:
		visible = false
		modulate.a = 1.0
		fase = ""
		togli_video()
		if tween_luce != null and tween_luce.is_valid():
			tween_luce.kill()
		chiuso.emit()
		poi.call())
