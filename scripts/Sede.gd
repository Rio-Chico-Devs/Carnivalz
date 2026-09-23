extends Control

# La Sede: dove sei quando non sei dentro un Carnivalz.
#
# PERCHE' ESISTE. Prima il gioco non aveva un "dove sei": si usciva dal menu e
# ci si trovava su una mappa stellare, sospesi nel vuoto, senza che nessuno
# avesse mai detto da dove la stessi guardando. Adesso la guardi dal tavolo
# tattico della Sala operativa, che sta dentro un'unita' dell'Organizzazione,
# che e' un presidio e va difeso. La mappa non e' piu' il posto in cui vivi: e'
# una cosa che si consulta.
#
# E' anche il posto sicuro del gioco, l'unico. Qui si salva - da solo, senza
# chiedere niente a nessuno: quale file venga scritto e' una faccenda della
# schermata principale, non tua mentre giochi (vedi GameState.slot_corrente).
#
# Tutto quello che c'e' dentro sta in data/sede.json: aggiungere una stanza e'
# una voce in un file, non una riga di codice.

const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_NEGOZIO := "res://scenes/Negozio.tscn"
const SCENA_MENU := "res://scenes/Menu.tscn"
const PERCORSO_SEDE := "res://data/sede.json"

const GUTTER := 34   # la corsia del marcatore: i nomi partono tutti da qui

var dati: Dictionary = {}
var colonna_stanze: VBoxContainer
var etichetta_titolo_scheda: Label
var etichetta_descrizione: Label
var etichetta_stato: Label
var salvata := true   # com'e' andato il salvataggio di quando sei rientrato

func _ready() -> void:
	AudioManager.musica_chiave("mappa")
	# Il salvataggio sta qui e in nessun altro posto. Rientrare alla Sede E' il
	# salvataggio: non c'e' un bottone, non c'e' una domanda, non c'e' un modo di
	# scrivere sul file sbagliato.
	salvata = GameState.salva()
	var letto: Variant = GameState.carica_json(PERCORSO_SEDE)
	dati = letto if letto is Dictionary else {}

	var sfondo := ColorRect.new()
	sfondo.color = Stile.colore("sfondo")
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sfondo)
	var percorso_sfondo := String(dati.get("sfondo", ""))
	if percorso_sfondo != "" and ResourceLoader.exists(percorso_sfondo):
		var immagine := TextureRect.new()
		immagine.texture = load(percorso_sfondo)
		immagine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		immagine.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		immagine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(immagine)

	var margini := MarginContainer.new()
	margini.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# tutti e quattro i lati sulla stessa misura della griglia, non 70 e 40 a
	# occhio: e' la cornice che usano le altre schermate
	for lato in ["left", "right", "top", "bottom"]:
		margini.add_theme_constant_override("margin_" + lato, Stile.forma("cornice"))
	add_child(margini)

	var tutto := VBoxContainer.new()
	tutto.add_theme_constant_override("separation", 24)
	margini.add_child(tutto)

	# L'USCITA STA IN ALTO, e non e' un gusto: e' dov'e' sulla mappa di zona,
	# ed era l'unica cosa fuori inquadratura. In fondo alla colonna delle
	# stanze, con un'etichetta di trentuno lettere, andava a capo su due righe
	# e la seconda finiva sotto il bordo dello schermo. Bru: «altre fuori
	# inquadratura». Una via d'uscita che esce dallo schermo e' la sola che non
	# puoi permetterti di perdere.
	var barra := HBoxContainer.new()
	tutto.add_child(barra)
	var uscita := Button.new()
	uscita.text = "Torna alla schermata principale"
	Stile.ritorno(uscita)
	uscita.pressed.connect(_su_uscita)
	barra.add_child(uscita)

	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 40)
	riga.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tutto.add_child(riga)

	var sinistra := VBoxContainer.new()
	sinistra.add_theme_constant_override("separation", 8)
	sinistra.custom_minimum_size = Vector2(420, 0)
	riga.add_child(sinistra)
	var titolo := Label.new()
	titolo.text = String(dati.get("nome", "Sede"))
	Stile.titolo_schermata(titolo)
	sinistra.add_child(titolo)
	var sottotitolo := Label.new()
	sottotitolo.text = String(dati.get("sottotitolo", ""))
	Stile.etichetta_piccola(sottotitolo)
	sinistra.add_child(sottotitolo)
	sinistra.add_child(spazio(16))

	# LE STANZE SCORRONO. Oggi sono sei e ci stanno; ma aggiungerne una e' una
	# voce in sede.json, e il giorno che diventano dodici la colonna uscirebbe
	# dallo schermo in silenzio - che e' esattamente com'e' uscito il bottone.
	var scorrevole := ScrollContainer.new()
	scorrevole.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scorrevole.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sinistra.add_child(scorrevole)
	colonna_stanze = VBoxContainer.new()
	colonna_stanze.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	colonna_stanze.add_theme_constant_override("separation", 8)
	scorrevole.add_child(colonna_stanze)

	sinistra.add_child(spazio(16))
	sinistra.add_child(Stile.legenda_visite())

	costruisci_pannello(riga)
	riempi_stanze()

# --- la colonna delle stanze ---

func riempi_stanze() -> void:
	# si ricostruisce da sola dopo ogni visita: una stanza appena vista deve
	# spegnere il suo pallino subito, non alla prossima apertura della schermata
	for figlio in colonna_stanze.get_children():
		colonna_stanze.remove_child(figlio)
		figlio.queue_free()
	var primo: Button = null
	for stanza in dati.get("stanze", []):
		var bottone := costruisci_stanza(stanza)
		colonna_stanze.add_child(bottone)
		if primo == null and not bottone.disabled:
			primo = bottone
	if primo != null:
		primo.grab_focus()

func costruisci_stanza(stanza: Dictionary) -> Button:
	var bottone := Button.new()
	Stile.voce_di_elenco(bottone, GUTTER)
	var aperta := not stanza.has("richiede_flag") or GameState.ha_flag(String(stanza["richiede_flag"]))
	if not aperta:
		bottone.text = "— chiuso —"
		bottone.disabled = true
		bottone.add_theme_color_override("font_disabled_color", Stile.colore("testo_smorzato"))
		# IL PERCHE' NON STA PIU' SOLO NEL SUGGERIMENTO. Il testo della porta
		# chiusa era in tooltip_text, cioe' visibile soltanto tenendoci sopra
		# il mouse - e un bottone disabilitato in Godot non prende nemmeno il
		# fuoco da tastiera. Adesso si legge nel pannello, come tutto il resto.
		bottone.mouse_entered.connect(_su_sguardo.bind(stanza))
		return bottone
	bottone.text = String(stanza.get("nome", "?"))
	var stato := GameState.stato_visita(id_stanza(stanza))
	bottone.add_theme_color_override("font_color", Stile.colore("testo"))
	for acceso in ["font_hover_color", "font_focus_color", "font_pressed_color"]:
		bottone.add_theme_color_override(acceso, Stile.colore("accento"))
	# IL MARCATORE VA NELLA SUA CORSIA, non davanti al nome. Stile.segna_visita
	# lo infila nel testo ("•  Alloggi"), e allora i nomi delle stanze in cui
	# sei gia' stato partono da un'altra x: sei righe, tre margini sinistri
	# diversi, e nessuna linea che l'occhio possa seguire.
	if stato != Stile.VISITA_VISTO:
		metti_marcatore(bottone, "•" if stato == Stile.VISITA_NUOVO else "✓",
				Stile.colore_visita(stato))
	bottone.pressed.connect(_su_stanza.bind(stanza))
	bottone.focus_entered.connect(_su_sguardo.bind(stanza))
	bottone.mouse_entered.connect(_su_sguardo.bind(stanza))
	return bottone

func metti_marcatore(bottone: Button, segno: String, tinta: Color) -> void:
	var marchio := Label.new()
	marchio.text = segno
	marchio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marchio.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marchio.add_theme_color_override("font_color", tinta)
	Stile.imposta_corpo(marchio, Stile.dimensione("corpo"))
	marchio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# un Button non e' un contenitore e non sistema i figli: le misure gliele
	# si danno per intero, ancorate all'altezza della riga
	marchio.anchor_top = 0.0
	marchio.anchor_bottom = 1.0
	marchio.offset_left = 10.0
	marchio.offset_right = float(GUTTER)
	bottone.add_child(marchio)

func id_stanza(stanza: Dictionary) -> String:
	return "sede__" + String(stanza.get("id", ""))

# --- la colonna di destra ---

func costruisci_pannello(riga: HBoxContainer) -> void:
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 16)
	colonna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(colonna)

	# LA SCHEDA: un riquadro, non del testo appeso al buio. Prima la
	# descrizione galleggiava in alto a destra senza intestazione, e sotto
	# restavano cinquecento pixel di nero: non si sapeva nemmeno di cosa si
	# stesse leggendo. Adesso ha un titolo - il nome della stanza che stai
	# guardando - e un bordo che dice dove comincia e dove finisce.
	var scheda := PanelContainer.new()
	# SI STRINGE SUL TESTO, non riempie mezzo schermo. Espandendola, quattro
	# righe di descrizione si portavano dietro cinquecento pixel di riquadro
	# vuoto: non e' una scheda, e' una parete con una frase sopra.
	scheda.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var vestito := StyleBoxFlat.new()
	vestito.bg_color = Color(Stile.colore("tratto"), 0.14)
	vestito.border_width_left = 3
	vestito.border_color = Stile.colore("accento")
	vestito.content_margin_left = 24
	vestito.content_margin_right = 24
	vestito.content_margin_top = 20
	vestito.content_margin_bottom = 20
	scheda.add_theme_stylebox_override("panel", vestito)
	colonna.add_child(scheda)

	var dentro := VBoxContainer.new()
	dentro.add_theme_constant_override("separation", 16)
	scheda.add_child(dentro)

	etichetta_titolo_scheda = Label.new()
	etichetta_titolo_scheda.text = String(dati.get("nome", ""))
	etichetta_titolo_scheda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etichetta_titolo_scheda.add_theme_color_override("font_color", Stile.colore("testo"))
	Stile.imposta_corpo(etichetta_titolo_scheda, Stile.dimensione("sezione"))
	dentro.add_child(etichetta_titolo_scheda)

	etichetta_descrizione = Label.new()
	etichetta_descrizione.text = String(dati.get("descrizione", ""))
	etichetta_descrizione.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# ERA "narrazione", CIOE' #1a1a1a SUL NERO: 1,21:1, invisibile. Quel colore
	# e' fatto per il testo scuro dentro il box chiaro dei dialoghi, e qui
	# finiva dritto sul fondo della schermata. Bru: «alcune cose sono
	# illeggibili» - e non era un modo di dire, era letteralmente nero su nero.
	# "testo_smorzato" sta a 7,65:1: si legge, e resta un gradino sotto il
	# titolo della scheda, che e' quello che deve fare un testo di contorno.
	etichetta_descrizione.add_theme_color_override("font_color", Stile.colore("testo_smorzato"))
	Stile.imposta_corpo(etichetta_descrizione, Stile.dimensione("corpo"))
	Stile.interlinea(etichetta_descrizione, "lettura", Stile.dimensione("corpo"))
	dentro.add_child(etichetta_descrizione)

	# e la riga di stato resta in fondo: in mezzo ci va il vuoto, non la scheda
	var respiro := Control.new()
	respiro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna.add_child(respiro)

	etichetta_stato = Label.new()
	etichetta_stato.text = riga_di_stato()
	# VA A CAPO. Con «testo piu' grande» lo schermo utile scende a 1024 pixel,
	# e questa riga lunga, che non andava a capo, allargava la colonna oltre il
	# bordo: si trascinava fuori anche la scheda, titolo e descrizione tagliati
	etichetta_stato.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Stile.etichetta_piccola(etichetta_stato)
	colonna.add_child(etichetta_stato)

func riga_di_stato() -> String:
	# Ogni unita' deve tenere in casa un numero minimo di dominatori. Non e'
	# ancora una regola di gioco: e' una riga che dice che questo posto e' un
	# presidio, e che quando esci lo lasci piu' scoperto di com'era.
	var in_forza := GameState.classi_sbloccate.size()
	var richiesti := int(dati.get("presidio_richiesto", 0))
	var testo := "Dominatori in forza: %d di %d richiesti" % [in_forza, richiesti]
	if in_forza < richiesti:
		testo += "  —  l'unità è sotto organico."
	testo += "\nTazo: %d  ·  Fonti estinte: %d" % [GameState.tazo, GameState.fonti_estinte]
	# se il disco non ha scritto, lo si dice qui, dove il gioco promette di
	# salvare: tacerlo vorrebbe dire lasciar credere che la partita sia al sicuro
	if not salvata:
		testo += "\nSalvataggio non riuscito: la partita di adesso non è su disco."
	return testo

# --- interazione ---

func _su_sguardo(stanza: Dictionary) -> void:
	if not is_instance_valid(etichetta_descrizione):
		return
	var aperta := not stanza.has("richiede_flag") or GameState.ha_flag(String(stanza["richiede_flag"]))
	etichetta_titolo_scheda.text = String(stanza.get("nome", "?")) if aperta else "Una porta chiusa"
	etichetta_descrizione.text = String(stanza.get("descrizione", "")) if aperta \
			else String(stanza.get("testo_chiusa", "Non si apre."))

func _su_stanza(stanza: Dictionary) -> void:
	GameState.segna_visitata(id_stanza(stanza))
	match String(stanza.get("azione", "testo")):
		"mappa":
			Transizioni.vai(SCENA_MAPPA)
		"negozio":
			Transizioni.vai(SCENA_NEGOZIO)
		"squadra":
			# non cambia schermata: la scheda e il Diario vivono nel velo della
			# pausa, e da li' si torna esattamente dove si era
			Pausa.apri_su("equipaggiamento")
			riempi_stanze()
		"diario":
			Pausa.apri_su("diario")
			riempi_stanze()
		_:
			# una stanza che si guarda e basta: il suo testo resta a destra, e il
			# pallino "non ci sei ancora stato" si spegne
			riempi_stanze()

func _su_uscita() -> void:
	GameState.reset_campagna()
	Transizioni.vai(SCENA_MENU)

func spazio(altezza: int) -> Control:
	var vuoto := Control.new()
	vuoto.custom_minimum_size = Vector2(0, altezza)
	return vuoto
