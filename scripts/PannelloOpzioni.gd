class_name PannelloOpzioni
extends RefCounted

# Le opzioni del gioco, definite una volta sola.
#
# PERCHE'. Le opzioni si guardano da due posti: dalla schermata principale
# (una pagina del menu, Menu.gd) e dalla pausa, mentre si gioca. Sono due schermate diverse ma
# devono essere le STESSE opzioni: se una delle due ne dimentica una, il
# giocatore che ha alzato il contrasto in pausa non lo ritrova nel menu, e
# nessuno capisce perche'.
#
# Fino a ieri la pausa ne mostrava due su sei. Adesso l'elenco sta qui, e le due
# schermate lo chiedono: aggiungerne una la fa comparire in tutti e due i posti,
# perche' non c'e' nessun altro posto dove metterla.
#
# Lo chiedono in due modi. La pausa le vuole tutte insieme (costruisci). Il
# menu principale una sezione per passo (costruisci_sezione), come le opzioni
# del riferimento di Bru: tutte insieme non ci stavano, e a testo normale
# l'ultima finiva sotto la descrizione, raggiungibile solo scorrendo.
#
# Questo NON e' la gestione dei salvataggi: quella resta prerogativa della
# schermata principale (vedi Menu.gd). Le opzioni si guardano anche in gioco
# perche' alzare il volume a meta' di uno scontro non e' amministrare una
# partita, e' regolare lo schermo che hai davanti.

# le sezioni, in ordine, con quello che il menu principale ne dice: un titolo
# breve e cosa c'e' dentro
const SEZIONI := {
	"Audio": ["Quanto si sente", "Volume generale, musica ed effetti."],
	"Grafica": ["Come si vede", "In una finestra o a schermo intero."],
	"Accessibilità": ["Perché si legga bene",
			"Testo più grande, alto contrasto, meno movimento, e quanto corre il testo."],
}

static var caselle: Dictionary = {}   # le icone delle caselle, fatte una volta per colore

static func costruisci(colonna: VBoxContainer, larghezza_etichetta := 150,
		tinta := Color.WHITE) -> void:
	# "tinta" e' il colore delle intestazioni e delle caselle: cremisi nella
	# pausa, azzurro chiaro nel menu principale - dove l'unico colore caldo deve
	# restare la voce scelta
	for quale: String in SEZIONI:
		costruisci_sezione(colonna, quale, larghezza_etichetta, tinta)


static func costruisci_sezione(colonna: VBoxContainer, quale: String, larghezza_etichetta := 150,
		tinta := Color.WHITE, con_intestazione := true) -> void:
	# senza intestazione quando il nome della sezione e' gia' scritto sopra (la
	# testata del passo, nel menu principale)
	colonna.set_meta("tinta_opzioni", tinta)
	if con_intestazione:
		sezione(colonna, quale)
	match quale:
		"Audio": audio(colonna, larghezza_etichetta)
		"Grafica": grafica(colonna)
		"Accessibilità": accessibilita(colonna, larghezza_etichetta)
		_: push_error("PannelloOpzioni: nessuna sezione '%s'" % quale)


static func audio(colonna: VBoxContainer, larghezza_etichetta: int) -> void:
	cursore(colonna, "Volume generale", Impostazioni.volume_master, larghezza_etichetta,
			func(v: float) -> void:
				Impostazioni.volume_master = v
				Impostazioni.applica_volumi()
				Impostazioni.salva())
	cursore(colonna, "Musica", Impostazioni.volume_musica, larghezza_etichetta,
			func(v: float) -> void:
				Impostazioni.volume_musica = v
				Impostazioni.applica_volumi()
				Impostazioni.salva())
	cursore(colonna, "Effetti", Impostazioni.volume_effetti, larghezza_etichetta,
			func(v: float) -> void:
				Impostazioni.volume_effetti = v
				Impostazioni.applica_volumi()
				Impostazioni.salva())


static func grafica(colonna: VBoxContainer) -> void:
	interruttore(colonna, "Schermo intero", Impostazioni.schermo_intero,
			func(attivo: bool) -> void:
				Impostazioni.schermo_intero = attivo
				Impostazioni.applica_schermo()
				Impostazioni.salva())


static func accessibilita(colonna: VBoxContainer, larghezza_etichetta: int) -> void:
	interruttore(colonna, "Testo più grande", Impostazioni.testo_grande,
			func(attivo: bool) -> void:
				Impostazioni.testo_grande = attivo
				Impostazioni.applica_scala_testo()
				Impostazioni.salva())
	interruttore(colonna, "Alto contrasto", Impostazioni.alto_contrasto,
			func(attivo: bool) -> void:
				Impostazioni.alto_contrasto = attivo
				Impostazioni.applica_alto_contrasto()
				Impostazioni.salva())
	# RIDUCI IL MOVIMENTO: la schermata smette di sbandare a ogni colpo e i lampi
	# diventano tinte che restano. Non toglie nessuna informazione - il numero
	# del danno, il colore dell'elemento e il suono ci sono lo stesso - toglie
	# solo il movimento, che e' la parte che da' fastidio a chi soffre di mal di
	# movimento, emicrania o epilessia fotosensibile.
	interruttore(colonna, "Riduci il movimento", Impostazioni.movimento_ridotto,
			func(attivo: bool) -> void:
				Impostazioni.movimento_ridotto = attivo
				Impostazioni.salva())
	# 0 = si legge parola per parola, 1 = compare quasi tutto insieme
	cursore(colonna, "Velocità del testo", (Impostazioni.velocita_testo - 0.4) / 2.6,
			larghezza_etichetta,
			func(v: float) -> void:
				Impostazioni.velocita_testo = 0.4 + v * 2.6
				Impostazioni.salva())


static func cursore(colonna: VBoxContainer, testo: String, valore: float,
		larghezza_etichetta: int, su_cambio: Callable) -> void:
	# la riga e' un pannello vuoto, che col fuoco sulla barra prende la banda:
	# la barra da sola non disegna il suo fuoco
	var riga := PanelContainer.new()
	riga.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	colonna.add_child(riga)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	riga.add_child(fila)
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.custom_minimum_size = Vector2(larghezza_etichetta, 0)
	fila.add_child(etichetta)
	var barra := HSlider.new()
	vesti_barra(barra, tinta_di(colonna))
	barra.min_value = 0.0
	barra.max_value = 1.0
	barra.step = 0.05
	barra.value = clampf(valore, 0.0, 1.0)
	barra.custom_minimum_size = Vector2(220, 0)
	barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.value_changed.connect(su_cambio)
	fila.add_child(barra)
	# col fuoco sulla barra si accende anche il suo nome: e' il nome che si
	# legge, non il pallino
	var tinta := tinta_di(colonna)
	barra.focus_entered.connect(func() -> void:
		riga.add_theme_stylebox_override("panel", fuoco())
		etichetta.add_theme_color_override("font_color", tinta))
	barra.focus_exited.connect(func() -> void:
		riga.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		etichetta.remove_theme_color_override("font_color"))

static func interruttore(colonna: VBoxContainer, testo: String, attivo: bool,
		su_cambio: Callable) -> void:
	var casella := CheckBox.new()
	casella.text = testo
	var tinta := tinta_di(colonna)
	casella.add_theme_icon_override("checked", icona_casella(true, tinta))
	casella.add_theme_icon_override("unchecked", icona_casella(false, tinta))
	casella.add_theme_color_override("font_color", Stile.colore("testo"))
	casella.add_theme_color_override("font_hover_color", tinta)
	casella.add_theme_color_override("font_focus_color", tinta)
	casella.add_theme_color_override("font_pressed_color", Stile.colore("testo"))
	casella.add_theme_stylebox_override("focus", fuoco())
	casella.button_pressed = attivo
	casella.toggled.connect(su_cambio)
	colonna.add_child(casella)

static func sezione(colonna: VBoxContainer, testo: String) -> void:
	var spazio := Control.new()
	spazio.custom_minimum_size = Vector2(0, 8)
	colonna.add_child(spazio)
	# L'INTESTAZIONE SI LEGGE. Era il grigio smorzato a meta' opacita': sul nero
	# circa 2,3:1, cioe' un'intestazione che non si vede. Adesso e' del colore
	# dell'elenco (cremisi nella pausa, azzurro nel menu), piena
	var etichetta := Label.new()
	etichetta.text = testo.to_upper()
	etichetta.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	etichetta.add_theme_color_override("font_color", tinta_di(colonna))
	colonna.add_child(etichetta)


static func tinta_di(colonna: Control) -> Color:
	return colonna.get_meta("tinta_opzioni", Color.WHITE)


static func icona_casella(piena: bool, tinta: Color) -> ImageTexture:
	# LE CASELLE SI VEDONO. Quelle di serie di Godot sono quadratini scuri: sul
	# nero della pausa e sul blu del menu sparivano, e un'opzione che non si
	# vede se e' accesa o spenta non e' un'opzione. Qui un quadrato col bordo
	# del colore dell'elenco, pieno quando e' accesa
	var chiave := "%s_%s" % [piena, tinta.to_html()]
	if caselle.has(chiave):
		return caselle[chiave]
	var lato := 22
	var immagine := Image.create(lato, lato, false, Image.FORMAT_RGBA8)
	immagine.fill(Color(0, 0, 0, 0.35))
	immagine.fill_rect(Rect2i(0, 0, lato, 2), tinta)
	immagine.fill_rect(Rect2i(0, lato - 2, lato, 2), tinta)
	immagine.fill_rect(Rect2i(0, 0, 2, lato), tinta)
	immagine.fill_rect(Rect2i(lato - 2, 0, 2, lato), tinta)
	if piena:
		immagine.fill_rect(Rect2i(5, 5, lato - 10, lato - 10), tinta)
	var icona := ImageTexture.create_from_image(immagine)
	caselle[chiave] = icona
	return icona


static func fuoco() -> StyleBoxFlat:
	# DOVE SEI, SENZA MOUSE: la stessa grammatica delle voci del menu - una
	# banda scura come la macchia d'inchiostro e il cremisi della scelta, qui un
	# filo a sinistra. Non il riquadro bianco di serie, che nel menu sembrava un
	# campo da riempire; e non una banda azzurra, che sul cielo spariva
	var banda := StyleBoxFlat.new()
	banda.bg_color = Color(Stile.colore("menu_macchia"), 0.7)
	banda.border_color = Stile.colore("accento")
	banda.border_width_left = 3
	banda.set_corner_radius_all(2)
	banda.expand_margin_left = 8.0
	banda.expand_margin_right = 8.0
	banda.expand_margin_top = 2.0
	banda.expand_margin_bottom = 2.0
	# il filo non sposta niente: senza questo la riga prenderebbe il fuoco
	# scivolando di tre pixel a destra
	banda.content_margin_left = 0.0
	banda.content_margin_right = 0.0
	banda.content_margin_top = 0.0
	banda.content_margin_bottom = 0.0
	return banda


static func vesti_barra(barra: HSlider, tinta: Color) -> void:
	# la barra: il binario visibile, la parte piena del colore dell'elenco
	var binario := StyleBoxFlat.new()
	binario.bg_color = Color(Stile.colore("testo_smorzato"), 0.45)
	binario.content_margin_top = 3
	binario.content_margin_bottom = 3
	binario.set_corner_radius_all(3)
	barra.add_theme_stylebox_override("slider", binario)
	var piena := StyleBoxFlat.new()
	piena.bg_color = tinta
	piena.content_margin_top = 3
	piena.content_margin_bottom = 3
	piena.set_corner_radius_all(3)
	barra.add_theme_stylebox_override("grabber_area", piena)
	barra.add_theme_stylebox_override("grabber_area_highlight", piena)
