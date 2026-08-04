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

var dati: Dictionary = {}
var colonna_stanze: VBoxContainer
var etichetta_descrizione: Label
var etichetta_stato: Label

func _ready() -> void:
	AudioManager.musica_chiave("mappa")
	# Il salvataggio sta qui e in nessun altro posto. Rientrare alla Sede E' il
	# salvataggio: non c'e' un bottone, non c'e' una domanda, non c'e' un modo di
	# scrivere sul file sbagliato.
	GameState.salva()
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
	for lato in ["left", "right"]:
		margini.add_theme_constant_override("margin_" + lato, 70)
	for lato in ["top", "bottom"]:
		margini.add_theme_constant_override("margin_" + lato, 40)
	add_child(margini)

	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 40)
	margini.add_child(riga)

	var sinistra := VBoxContainer.new()
	sinistra.add_theme_constant_override("separation", 10)
	sinistra.custom_minimum_size = Vector2(380, 0)
	riga.add_child(sinistra)
	var titolo := Label.new()
	titolo.text = String(dati.get("nome", "Sede"))
	Stile.titolo_schermata(titolo)
	sinistra.add_child(titolo)
	var sottotitolo := Label.new()
	sottotitolo.text = String(dati.get("sottotitolo", ""))
	Stile.etichetta_piccola(sottotitolo)
	sinistra.add_child(sottotitolo)
	sinistra.add_child(spazio(14))
	colonna_stanze = VBoxContainer.new()
	colonna_stanze.add_theme_constant_override("separation", 10)
	sinistra.add_child(colonna_stanze)
	sinistra.add_child(spazio(10))
	sinistra.add_child(Stile.legenda_visite())
	sinistra.add_child(spazio(10))
	var uscita := Button.new()
	uscita.text = "Torna alla schermata principale"
	Stile.scelta(uscita)
	uscita.pressed.connect(_su_uscita)
	sinistra.add_child(uscita)

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
	Stile.scelta(bottone)
	var aperta := not stanza.has("richiede_flag") or GameState.ha_flag(String(stanza["richiede_flag"]))
	if not aperta:
		bottone.text = "— chiuso —"
		bottone.disabled = true
		bottone.tooltip_text = String(stanza.get("testo_chiusa", ""))
		return bottone
	bottone.text = String(stanza.get("nome", "?"))
	# le stanze in cui non hai ancora messo piede si fanno notare: e' lo stesso
	# linguaggio della mappa stellare, non un'invenzione di questa schermata
	Stile.segna_visita(bottone, GameState.stato_visita(id_stanza(stanza)))
	bottone.pressed.connect(_su_stanza.bind(stanza))
	bottone.focus_entered.connect(_su_sguardo.bind(stanza))
	bottone.mouse_entered.connect(_su_sguardo.bind(stanza))
	return bottone

func id_stanza(stanza: Dictionary) -> String:
	return "sede__" + String(stanza.get("id", ""))

# --- la colonna di destra ---

func costruisci_pannello(riga: HBoxContainer) -> void:
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 16)
	colonna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(colonna)

	etichetta_descrizione = Label.new()
	etichetta_descrizione.text = String(dati.get("descrizione", ""))
	etichetta_descrizione.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etichetta_descrizione.add_theme_color_override("font_color", Stile.colore("narrazione"))
	etichetta_descrizione.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna.add_child(etichetta_descrizione)

	etichetta_stato = Label.new()
	etichetta_stato.text = riga_di_stato()
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
	return testo

# --- interazione ---

func _su_sguardo(stanza: Dictionary) -> void:
	if is_instance_valid(etichetta_descrizione):
		etichetta_descrizione.text = String(stanza.get("descrizione", ""))

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
