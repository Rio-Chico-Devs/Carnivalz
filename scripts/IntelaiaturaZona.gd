class_name IntelaiaturaZona
extends RefCounted

# COME E' MONTATA LA SCHERMATA DELLA MAPPA DI ZONA: la barra in alto, la figura
# con la sua chiave di fianco, la riga che dice dove sei. Sta fuori da
# MappaZona.gd perche' quella deve sapere cosa si sa e dove si puo' andare;
# dove stanno i pezzi sullo schermo non la riguarda.
#
# IN ALTO A SINISTRA C'E' IL MENU, come in ogni schermata (IconaMenu). Per
# questo la cornice comincia dove comincia l'iconcina, e non trenta pixel
# prima: la barra le sta di fianco invece di finirle sotto.
#
# LA MAPPA DELLA SEDE ("sede": true nei dati) e' la schermata stessa, non uno
# strumento che si consulta da una stanza: quindi non c'e' nessuna «stanza
# corrente» a cui tornare, e i nomi stanno sulla pianta invece che in una
# legenda di fianco (vedi SegniPianta). Bru, sulla Sede: «se ci sono alloggi,
# emporio e le cose riportate qui le vorrei vedere sulla mappa piuttosto che
# in questa schermata noiosa».


static func costruisci(zona: MappaZona) -> void:
	var margini := MarginContainer.new()
	margini.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bordo := Stile.forma("cornice")
	var angolo := IconaMenu.posto()
	margini.add_theme_constant_override("margin_left", int(angolo.x))
	margini.add_theme_constant_override("margin_top", int(angolo.y))
	margini.add_theme_constant_override("margin_right", bordo)
	margini.add_theme_constant_override("margin_bottom", bordo)
	zona.add_child(margini)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 12)
	margini.add_child(colonna)
	colonna.add_child(barra(zona))

	# LA FIGURA E LA SUA CHIAVE, una di fianco all'altra. I nomi delle stanze
	# arrivano a 27 caratteri e i quadratini a 104 pixel: dentro non ci stanno
	# e sotto nemmeno, quindi vanno letti qui di fianco. Vedi ElencoPosti.gd.
	var fianco := HBoxContainer.new()
	fianco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fianco.add_theme_constant_override("separation", Stile.forma("separazione"))
	colonna.add_child(fianco)
	# la mappa e la sua chiave sono una proiezione: stanno nel vetro scuro di un
	# cabinato, e li' valgono i colori e i contrasti pensati per il nero
	Manifesto.in_schermo(fianco)

	# la cornice del disegno di Bru: la porzione di mappa che stai guardando
	zona.cornice = Control.new()
	zona.cornice.size_flags_vertical = Control.SIZE_EXPAND_FILL
	zona.cornice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zona.cornice.clip_contents = true
	fianco.add_child(zona.cornice)

	zona.elenco = ElencoPosti.new()
	zona.elenco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	zona.elenco.indicato.connect(zona._indica_stanza)
	zona.elenco.lasciato.connect(zona._smetti_di_indicare)
	zona.elenco.scelto.connect(zona._su_stanza_per_id)
	# alla Sede i nomi sono sulla pianta: la stessa lista una seconda volta, di
	# fianco, era proprio la «schermata di opzioni» da cui si voleva uscire
	zona.elenco.visible = not zona.e_la_sede()
	fianco.add_child(zona.elenco)

	zona.strato_sotto = strato(zona.cornice)
	zona.strato_sotto.draw.connect(zona._disegna_sotto)
	zona.strato_bottoni = strato(zona.cornice)
	zona.strato_sopra = strato(zona.cornice)
	zona.strato_sopra.draw.connect(zona._disegna_sopra)

	# LA RIGA CHE DICE SEMPRE DOVE SEI. Era a corpo 37 - piu' grande della
	# legenda e quasi quanto il nome della zona - e da sola rovesciava la
	# gerarchia: una riga di stato in fondo e' la voce piu' bassa della
	# schermata, non la piu' alta. A 26 si legge da lontano e non grida.
	zona.etichetta_stato = Label.new()
	zona.etichetta_stato.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zona.etichetta_stato.add_theme_color_override("font_color", Stile.colore("box_testo"))   # sull'arancio
	Stile.imposta_corpo(zona.etichetta_stato, Stile.dimensione("corpo"))
	zona.etichetta_stato.text = " "
	colonna.add_child(zona.etichetta_stato)


static func barra(zona: MappaZona) -> HBoxContainer:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 16)
	# l'iconcina del menu apre la fila, alla stessa altezza in ogni schermata
	var icona := IconaMenu.metti(fila)
	icona.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if not zona.e_la_sede():
		var indietro := Button.new()
		# con la Guida sopra, questo e' il «tasto di chiusura» del testo di Bru: si
		# torna dove dice lei (vedi GuidaSullaMappa.dove_tornare)
		indietro.text = "Chiudi la mappa" if GuidaSullaMappa.sta_parlando() else "Torna alla stanza corrente"
		Stile.ritorno(indietro)
		indietro.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		indietro.pressed.connect(func() -> void: IngressoNodo.vai_al_nodo(GuidaSullaMappa.dove_tornare()))
		fila.add_child(indietro)

	var spazio := Control.new()
	spazio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(spazio)

	var titolo := Label.new()
	titolo.text = String(GameState.mappa_zona.get("nome", ""))
	Manifesto.vesti_etichetta(titolo, Stile.dimensione("sezione"))
	titolo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(titolo)
	return fila


static func strato(cornice: Control) -> Control:
	# uno strato trasparente grande quanto la cornice: non prende il mouse, i
	# bottoni delle stanze stanno nel loro
	var foglio := Control.new()
	foglio.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	foglio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cornice.add_child(foglio)
	return foglio
