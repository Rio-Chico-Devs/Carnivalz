extends Control

# Extra: le collezioni (album/bestiario/oggetti, prima sul menu principale),
# il riscatto di un codice, e le informazioni social/ringraziamenti.

const SCENA_MENU := "res://scenes/Menu.tscn"
const SCENA_ALBUM := "res://scenes/Album.tscn"
const SCENA_BESTIARIO := "res://scenes/Bestiario.tscn"
const SCENA_COMPENDIO := "res://scenes/Compendio.tscn"

# TODO(Bru): sostituire con i link veri quando ci sono.
const INSTAGRAM := "@iltuohandle (da confermare)"
const SITO := "iltuosito.it (da confermare)"
const RINGRAZIAMENTI := "I ringraziamenti arriveranno con una prossima versione della demo."

func _ready() -> void:
	AudioManager.musica_chiave("menu")
	var sfondo := ColorRect.new()
	sfondo.color = Stile.colore("sfondo")
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sfondo)

	var margini := MarginContainer.new()
	margini.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margini.add_theme_constant_override("margin_left", 48)
	margini.add_theme_constant_override("margin_top", 32)
	margini.add_theme_constant_override("margin_right", 48)
	margini.add_theme_constant_override("margin_bottom", 32)
	add_child(margini)

	var centro := CenterContainer.new()
	margini.add_child(centro)

	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 12)
	colonna.custom_minimum_size = Vector2(360, 0)
	centro.add_child(colonna)

	var titolo := Label.new()
	titolo.text = "Extra"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Stile.titolo_schermata(titolo)
	colonna.add_child(titolo)

	colonna.add_child(_separatore("Collezioni"))
	_voce_scena(colonna, "Album delle carte", SCENA_ALBUM)
	_voce_scena(colonna, "Bestiario", SCENA_BESTIARIO)
	_voce_scena(colonna, "Oggetti", SCENA_COMPENDIO)

	colonna.add_child(_separatore("Demo"))
	var bottone_codice := Button.new()
	bottone_codice.text = "Carica codice"
	bottone_codice.custom_minimum_size = Vector2(0, 44)
	bottone_codice.pressed.connect(_su_carica_codice)
	colonna.add_child(bottone_codice)
	var bottone_ringraziamenti := Button.new()
	bottone_ringraziamenti.text = "Ringraziamenti"
	bottone_ringraziamenti.custom_minimum_size = Vector2(0, 44)
	bottone_ringraziamenti.pressed.connect(func() -> void:
		_mostra_messaggio("Ringraziamenti", RINGRAZIAMENTI))
	colonna.add_child(bottone_ringraziamenti)

	colonna.add_child(_separatore("Seguici"))
	var instagram := Label.new()
	instagram.text = "Instagram: %s" % INSTAGRAM
	instagram.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instagram.modulate = Color(1, 1, 1, 0.75)
	colonna.add_child(instagram)
	var sito := Label.new()
	sito.text = "Sito: %s" % SITO
	sito.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sito.modulate = Color(1, 1, 1, 0.75)
	colonna.add_child(sito)

	colonna.add_child(_spazio(10))
	var indietro := Button.new()
	indietro.text = "Indietro"
	indietro.custom_minimum_size = Vector2(0, 40)
	indietro.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_MENU))
	colonna.add_child(indietro)

func _voce_scena(colonna: VBoxContainer, testo: String, scena: String) -> void:
	var bottone := Button.new()
	bottone.text = testo
	bottone.custom_minimum_size = Vector2(0, 44)
	bottone.pressed.connect(func() -> void:
		Transizioni.vai(scena))
	colonna.add_child(bottone)

func _su_carica_codice() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(centro)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	colonna.custom_minimum_size = Vector2(360, 0)
	centro.add_child(colonna)
	var titolo := Label.new()
	titolo.text = "Carica codice"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(titolo)
	var campo := LineEdit.new()
	campo.placeholder_text = "Inserisci il codice"
	campo.custom_minimum_size = Vector2(0, 40)
	colonna.add_child(campo)
	var esito := Label.new()
	esito.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esito.autowrap_mode = TextServer.AUTOWRAP_WORD
	esito.visible = false
	colonna.add_child(esito)
	var conferma := Button.new()
	conferma.text = "Conferma"
	conferma.custom_minimum_size = Vector2(0, 44)
	conferma.pressed.connect(func() -> void:
		var risultato := GameState.riscatta_codice(campo.text)
		esito.visible = true
		if not risultato.get("trovato", false):
			esito.text = "Codice non riconosciuto."
		elif risultato.get("gia_riscattato", false):
			esito.text = "Codice già riscattato in precedenza."
		else:
			esito.text = String(risultato.get("testo", "Codice riscattato!")))
	colonna.add_child(conferma)
	campo.text_submitted.connect(func(_testo: String) -> void: conferma.pressed.emit())
	var chiudi := Button.new()
	chiudi.text = "Chiudi"
	chiudi.custom_minimum_size = Vector2(0, 40)
	chiudi.pressed.connect(overlay.queue_free)
	colonna.add_child(chiudi)

func _mostra_messaggio(titolo_testo: String, corpo: String) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(centro)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	colonna.custom_minimum_size = Vector2(420, 0)
	centro.add_child(colonna)
	var titolo := Label.new()
	titolo.text = titolo_testo
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Stile.titolo_schermata(titolo)
	colonna.add_child(titolo)
	var corpo_etichetta := Label.new()
	corpo_etichetta.text = corpo
	corpo_etichetta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	corpo_etichetta.autowrap_mode = TextServer.AUTOWRAP_WORD
	colonna.add_child(corpo_etichetta)
	var chiudi := Button.new()
	chiudi.text = "Chiudi"
	chiudi.custom_minimum_size = Vector2(0, 40)
	chiudi.pressed.connect(overlay.queue_free)
	colonna.add_child(chiudi)

func _separatore(testo: String) -> Control:
	var contenitore := VBoxContainer.new()
	contenitore.add_theme_constant_override("separation", 2)
	var spazio := Control.new()
	spazio.custom_minimum_size = Vector2(0, 8)
	contenitore.add_child(spazio)
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etichetta.modulate = Color(1, 1, 1, 0.5)
	Stile.etichetta_piccola(etichetta)
	contenitore.add_child(etichetta)
	return contenitore

func _spazio(altezza: int) -> Control:
	var vuoto := Control.new()
	vuoto.custom_minimum_size = Vector2(0, altezza)
	return vuoto
