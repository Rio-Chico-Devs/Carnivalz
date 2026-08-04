extends Control

# La schermata principale. Qui si fa UNA cosa: si sceglie con quale partita
# giocare. Poi si gioca, e questa schermata non serve piu' finche' non si esce.
#
# PERCHE' E' STATA RIFATTA. Prima c'era un bottone "Start" che apriva un
# sotto-menu che chiedeva "nuova partita o altro?", e in mezzo alla partita un
# bottone "Salva" apriva un selettore di slot. Erano due pezzi della stessa
# confusione: roba che appartiene alla schermata principale sparsa dentro il
# gioco, e una domanda in piu' fra il giocatore e la voglia di giocare.
#
# Adesso la gerarchia e' netta, e vale in tutte e due le direzioni:
#
#   SCHERMATA PRINCIPALE  ->  quale partita, e se cominciarla o continuarla.
#                             Cancellare una partita. Opzioni. Extra. Uscire.
#   DENTRO IL GIOCO       ->  si gioca. Le opzioni si possono guardare (pausa),
#                             ma dei salvataggi non si parla piu': il gioco
#                             scrive da solo, sempre nella partita che hai
#                             scelto qui, ogni volta che rientri alla Sede.
#
# Cinque partite, ognuna un file suo. Una riga vuota si comincia, una riga
# piena si continua: nessun passaggio intermedio, nessuna domanda.

const SCENA_INTRO := "res://scenes/Intro.tscn"
const SCENA_SEDE := "res://scenes/Sede.tscn"
const SCENA_OPZIONI := "res://scenes/Opzioni.tscn"
const SCENA_EXTRA := "res://scenes/Extra.tscn"

var colonna_partite: VBoxContainer

func _ready() -> void:
	AudioManager.musica_chiave("menu")
	# una partita giocata prima che gli slot esistessero diventa la partita 1:
	# chi stava giocando riapre e ritrova la sua roba, non cinque righe vuote
	GameState.recupera_salvataggio_vecchio()

	var sfondo := ColorRect.new()
	sfondo.color = Stile.colore("sfondo")
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sfondo)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 12)
	colonna.custom_minimum_size = Vector2(460, 0)
	centro.add_child(colonna)

	var titolo := Label.new()
	titolo.text = "CARNIVALZ"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titolo.add_theme_font_size_override("font_size", Stile.dimensione("titolo"))
	titolo.add_theme_color_override("font_color", Stile.colore("accento"))
	colonna.add_child(titolo)

	var sottotitolo := Label.new()
	sottotitolo.text = "una festa per chi ha subìto ingiustizie"
	sottotitolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sottotitolo.modulate = Color(1, 1, 1, 0.6)
	colonna.add_child(sottotitolo)

	var demo := Label.new()
	demo.text = "— demo —"
	demo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	demo.modulate = Color(1, 1, 1, 0.4)
	colonna.add_child(demo)

	colonna.add_child(_spazio(18))
	colonna_partite = VBoxContainer.new()
	colonna_partite.add_theme_constant_override("separation", 8)
	colonna.add_child(colonna_partite)
	colonna.add_child(_spazio(14))

	_bottone(colonna, "Opzioni", func() -> void: Transizioni.vai(SCENA_OPZIONI))
	_bottone(colonna, "Extra", func() -> void: Transizioni.vai(SCENA_EXTRA))
	_bottone(colonna, "Esci dal gioco", _su_esci)

	colonna.add_child(_spazio(12))
	var suggerimento := Label.new()
	suggerimento.text = "In gioco: ESC per pausa, storico, Diario e scheda del personaggio.\nLa partita si salva da sola ogni volta che rientri alla Sede."
	suggerimento.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Stile.etichetta_piccola(suggerimento)
	colonna.add_child(suggerimento)

	riempi_partite()

# --- le cinque partite ---

func riempi_partite() -> void:
	for figlio in colonna_partite.get_children():
		colonna_partite.remove_child(figlio)
		figlio.queue_free()
	var primo: Button = null
	for slot in range(1, GameState.SLOT_MASSIMO + 1):
		var riga := HBoxContainer.new()
		riga.add_theme_constant_override("separation", 8)
		colonna_partite.add_child(riga)
		var occupato := GameState.ha_salvataggio_slot(slot)
		var bottone := Button.new()
		bottone.custom_minimum_size = Vector2(0, occupato_altezza(occupato))
		bottone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bottone.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if occupato:
			bottone.text = "  %d.  %s\n      %s" % [slot, GameState.nome_slot(slot), GameState.anteprima_slot(slot)]
			bottone.pressed.connect(_su_continua.bind(slot))
		else:
			bottone.text = "  %d.  Nuova partita" % slot
			bottone.add_theme_color_override("font_color", Stile.colore("testo_smorzato"))
			bottone.pressed.connect(_su_nuova_partita.bind(slot))
		riga.add_child(bottone)
		if primo == null:
			primo = bottone
		if occupato:
			# cancellare una partita e' una cosa da schermata principale, e sta
			# qui: piccola, in fondo alla riga, e con una conferma davanti
			var cestino := Button.new()
			cestino.text = "✕"
			cestino.tooltip_text = "Cancella questa partita"
			cestino.custom_minimum_size = Vector2(44, 0)
			cestino.pressed.connect(_su_cancella.bind(slot))
			riga.add_child(cestino)
	if primo != null:
		primo.grab_focus()

func occupato_altezza(occupato: bool) -> float:
	return 58.0 if occupato else 44.0

# --- azioni ---

func _su_continua(slot: int) -> void:
	if not GameState.carica_slot(slot):
		return
	Transizioni.vai(SCENA_SEDE)

func _su_nuova_partita(slot: int) -> void:
	GameState.imposta_slot(slot)
	GameState.nuova_partita()
	var overlay := _velo()
	var colonna := _colonna_velo(overlay, 380)
	var titolo := Label.new()
	titolo.text = "Come ti chiami?"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(titolo)
	var sottotitolo := Label.new()
	sottotitolo.text = "Lascia vuoto per restare l'Anonimo."
	sottotitolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sottotitolo.modulate = Color(1, 1, 1, 0.6)
	colonna.add_child(sottotitolo)
	var campo := LineEdit.new()
	campo.placeholder_text = "Anonimo"
	campo.custom_minimum_size = Vector2(0, 40)
	colonna.add_child(campo)
	var conferma := Button.new()
	conferma.text = "Comincia"
	conferma.custom_minimum_size = Vector2(0, 44)
	conferma.pressed.connect(func() -> void:
		GameState.imposta_nome_protagonista(campo.text)
		Transizioni.vai(SCENA_INTRO))
	colonna.add_child(conferma)
	var annulla := Button.new()
	annulla.text = "Indietro"
	annulla.custom_minimum_size = Vector2(0, 40)
	annulla.pressed.connect(overlay.queue_free)
	colonna.add_child(annulla)
	campo.text_submitted.connect(func(_testo: String) -> void: conferma.pressed.emit())
	campo.grab_focus()

func _su_cancella(slot: int) -> void:
	var overlay := _velo()
	var colonna := _colonna_velo(overlay, 420)
	var titolo := Label.new()
	titolo.text = "Cancellare la partita %d?" % slot
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(titolo)
	var avviso := Label.new()
	avviso.text = "%s\n%s\n\nNon si torna indietro." % [GameState.nome_slot(slot), GameState.anteprima_slot(slot)]
	avviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avviso.add_theme_color_override("font_color", Stile.colore("pericolo"))
	colonna.add_child(avviso)
	var no := Button.new()
	no.text = "No, lasciala stare"
	no.custom_minimum_size = Vector2(0, 44)
	no.pressed.connect(overlay.queue_free)
	colonna.add_child(no)
	var si := Button.new()
	si.text = "Sì, cancella"
	si.custom_minimum_size = Vector2(0, 44)
	si.pressed.connect(func() -> void:
		GameState.elimina_slot(slot)
		overlay.queue_free()
		riempi_partite())
	colonna.add_child(si)
	no.grab_focus()

func _su_esci() -> void:
	get_tree().quit()

# --- pezzetti ---

func _bottone(colonna: VBoxContainer, testo: String, richiamo: Callable) -> Button:
	var bottone := Button.new()
	bottone.text = testo
	bottone.custom_minimum_size = Vector2(0, 44)
	bottone.pressed.connect(richiamo)
	colonna.add_child(bottone)
	return bottone

func _velo() -> ColorRect:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	return overlay

func _colonna_velo(overlay: ColorRect, larghezza: int) -> VBoxContainer:
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(centro)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	colonna.custom_minimum_size = Vector2(larghezza, 0)
	centro.add_child(colonna)
	return colonna

func _spazio(altezza: int) -> Control:
	var vuoto := Control.new()
	vuoto.custom_minimum_size = Vector2(0, altezza)
	return vuoto
