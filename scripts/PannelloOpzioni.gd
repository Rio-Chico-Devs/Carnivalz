class_name PannelloOpzioni
extends RefCounted

# Le opzioni del gioco, definite una volta sola.
#
# PERCHE'. Le opzioni si guardano da due posti: dalla schermata principale
# (Opzioni.tscn) e dalla pausa, mentre si gioca. Sono due schermate diverse ma
# devono essere le STESSE opzioni: se una delle due ne dimentica una, il
# giocatore che ha alzato il contrasto in pausa non lo ritrova nel menu, e
# nessuno capisce perche'.
#
# Fino a ieri la pausa ne mostrava due su sei. Adesso l'elenco sta qui, e le due
# schermate lo chiedono: aggiungerne una la fa comparire in tutti e due i posti,
# perche' non c'e' nessun altro posto dove metterla.
#
# Questo NON e' la gestione dei salvataggi: quella resta prerogativa della
# schermata principale (vedi Menu.gd). Le opzioni si guardano anche in gioco
# perche' alzare il volume a meta' di uno scontro non e' amministrare una
# partita, e' regolare lo schermo che hai davanti.

static func costruisci(colonna: VBoxContainer, larghezza_etichetta := 150) -> void:
	sezione(colonna, "Audio")
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

	sezione(colonna, "Grafica")
	interruttore(colonna, "Schermo intero", Impostazioni.schermo_intero,
			func(attivo: bool) -> void:
				Impostazioni.schermo_intero = attivo
				Impostazioni.applica_schermo()
				Impostazioni.salva())

	sezione(colonna, "Accessibilità")
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
	# 0 = si legge parola per parola, 1 = compare quasi tutto insieme
	cursore(colonna, "Velocità del testo", (Impostazioni.velocita_testo - 0.4) / 2.6,
			larghezza_etichetta,
			func(v: float) -> void:
				Impostazioni.velocita_testo = 0.4 + v * 2.6
				Impostazioni.salva())

static func cursore(colonna: VBoxContainer, testo: String, valore: float,
		larghezza_etichetta: int, su_cambio: Callable) -> void:
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 12)
	colonna.add_child(riga)
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.custom_minimum_size = Vector2(larghezza_etichetta, 0)
	riga.add_child(etichetta)
	var barra := HSlider.new()
	barra.min_value = 0.0
	barra.max_value = 1.0
	barra.step = 0.05
	barra.value = clampf(valore, 0.0, 1.0)
	barra.custom_minimum_size = Vector2(220, 0)
	barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.value_changed.connect(su_cambio)
	riga.add_child(barra)

static func interruttore(colonna: VBoxContainer, testo: String, attivo: bool,
		su_cambio: Callable) -> void:
	var casella := CheckBox.new()
	casella.text = testo
	casella.button_pressed = attivo
	casella.toggled.connect(su_cambio)
	colonna.add_child(casella)

static func sezione(colonna: VBoxContainer, testo: String) -> void:
	var spazio := Control.new()
	spazio.custom_minimum_size = Vector2(0, 8)
	colonna.add_child(spazio)
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.modulate = Color(1, 1, 1, 0.5)
	Stile.etichetta_piccola(etichetta)
	colonna.add_child(etichetta)
