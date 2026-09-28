class_name PaginePausa
extends RefCounted

# LE PAGINE DEL DATA PAD: cosa c'e' scritto dentro il Data pad, i Messaggi, lo
# Storico e lo Zaino. Stavano in Pausa.gd, che le mostrava; adesso Pausa decide
# QUANDO si apre un pannello e come ci si muove dentro, e qui sta COSA c'e'
# scritto. Sono due domande diverse, e la seconda cresce con la storia (un
# messaggio nuovo, una collezione nuova, un oggetto nuovo) senza che il menu
# debba saperlo.
#
# Il file di pausa era oltre le ottocentosettanta righe e nell'elenco dei file
# troppo grandi c'era scritto «E' il taglio piu' facile di tutto il progetto».
# Lo era: nessuna di queste funzioni toccava lo stato del menu.

static func riempi(genitore: VBoxContainer, sezione: String) -> void:
	# Bru, 28 settembre: «organizziamo meglio il data pad». Chi sei e come stai
	# crescendo sta in «Personaggio e squadra» (Stato, Sviluppo, passive,
	# squadra: «averlo anche su datapad e' disorganizzazione»); gli appunti se ne
	# sono andati («come voce non serve»); i messaggi sono l'iconcina in basso a
	# destra (IconaMessaggi). Qui restano il Database e l'Organizzazione
	match sezione:
		"database": sezione_database(genitore)
		"organizzazione": sezione_organizzazione(genitore)

static func sezione_database(genitore: VBoxContainer) -> void:
	# «la voce osservazioni e' inutile, dobbiamo sostituirlo con database,
	# cliccando su database puoi accedere a quello che vedi in collezioni dalla
	# schermata principale, ma in questo caso in game dal datapad» (Bru). Sono
	# le stesse tre schermate del menu principale (MenuPrincipale.COLLEZIONI):
	# si aprono sopra la scena viva, e «Indietro» torna qui
	titolo_sezione(genitore, "Database")
	for c: Array in MenuPrincipale.COLLEZIONI:
		var nome := String(c[0]).to_lower()
		var voce := Pausa.voce("", "%s  %s" % [nome.left(1).to_upper() + nome.substr(1), conto_di(String(c[3]))],
				Pausa.apri_collezione.bind(String(c[3])), genitore, Stile.dimensione("corpo"))
		voce.set_meta("chiave", "collezione:" + String(c[3]).get_file().get_basename().to_lower())
		# la spiegazione parte dove parte il nome della voce, non dal bordo
		var rientro := MarginContainer.new()
		rientro.add_theme_constant_override("margin_left", VoceMenu.SPAZIO_SEGNO)
		genitore.add_child(rientro)
		var spiega := Label.new()
		spiega.text = String(c[2])
		spiega.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		Stile.etichetta_piccola(spiega)
		rientro.add_child(spiega)

static func conto_di(scena: String) -> String:
	# quanti ne hai, come li conta la collezione stessa nel suo titolo: «(3 / 20)»
	var collezione := (load(scena) as PackedScene).instantiate() as Collezione
	var titolo := collezione.titolo_schermata()
	collezione.free()
	return titolo.substr(titolo.find("(")) if titolo.contains("(") else ""

static func sezione_messaggi(genitore: VBoxContainer) -> void:
	# «c'e' anche una sezione messaggi dove l'organizzazione ti ha versato 3000
	# tazo come quota di benvenuto» (Bru). Si aprono dall'iconcina in basso a
	# destra, in un pannello loro.
	#
	# Sono voci di altri, e si vede: mittente e oggetto in testa, il corpo
	# sotto, e aprendo il pannello si considerano letti tutti.
	if GameState.messaggi_ricevuti.is_empty():
		var vuoto := Label.new()
		vuoto.text = "Nessun messaggio."
		Stile.etichetta_piccola(vuoto)
		genitore.add_child(vuoto)
		return
	# i piu' recenti in cima: un messaggio vecchio non deve coprire quello nuovo
	var ordine := GameState.messaggi_ricevuti.duplicate()
	ordine.reverse()
	for id_messaggio in ordine:
		var dati := GameState.dati_messaggio(String(id_messaggio))
		if dati.is_empty():
			continue
		var nuovo := String(id_messaggio) not in GameState.messaggi_letti
		var intestazione := Label.new()
		intestazione.text = "%s%s — %s" % ["● " if nuovo else "",
				String(dati.get("mittente", "?")), String(dati.get("oggetto", ""))]
		if nuovo:
			intestazione.add_theme_color_override("font_color", Stile.colore("accento"))
		genitore.add_child(intestazione)
		var corpo := RichTextLabel.new()
		corpo.bbcode_enabled = true
		corpo.fit_content = true
		corpo.scroll_active = false
		corpo.text = Testi.accorda(String(dati.get("testo", "")), GameState.sesso_protagonista)
		genitore.add_child(corpo)
		var spazio := Control.new()
		spazio.custom_minimum_size = Vector2(0, 12)
		genitore.add_child(spazio)
		GameState.segna_messaggio_letto(String(id_messaggio))
		# letto qui, non serve piu' che una notifica dica che e' arrivato: il
		# messaggio di Veronica si legge nel giro del mattino, e senza questa
		# riga l'avviso sarebbe arrivato dopo, in palestra
		GameState.messaggi_da_notificare.erase(String(id_messaggio))

static func titolo_sezione(genitore: VBoxContainer, testo: String) -> void:
	var t := Label.new()
	t.text = testo
	t.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	t.add_theme_color_override("font_color", Stile.colore("accento"))
	genitore.add_child(t)

static func voce_diario(genitore: VBoxContainer, etichetta: String, valore: String) -> void:
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 12)
	genitore.add_child(riga)
	var sinistra := Label.new()
	sinistra.text = etichetta
	sinistra.custom_minimum_size = Vector2(280, 0)
	Stile.etichetta_piccola(sinistra)
	riga.add_child(sinistra)
	var destra := Label.new()
	destra.text = valore
	destra.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	riga.add_child(destra)

static func sezione_organizzazione(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Organizzazione")
	voce_diario(genitore, "Fonti estinte", "%d" % GameState.fonti_estinte)
	voce_diario(genitore, "Valutazione", valutazione_organizzazione())

static func valutazione_organizzazione() -> String:
	# l'Organizzazione parla per gradi, non per percentuali: e' un giudizio,
	# non una barra. Sale con le fonti estinte
	match GameState.fonti_estinte:
		0: return "In osservazione."
		1: return "Prestazione conforme alle attese."
		2: return "Rendimento soddisfacente."
		3: return "Elemento affidabile."
		_: return "Elemento di valore. Aspettative in aumento."

static func riga_storico(voce: Dictionary) -> Control:
	var tipo := String(voce.get("tipo", "narrazione"))
	var chi := String(voce.get("chi", ""))
	var testo := String(voce.get("testo", ""))
	var blocco := VBoxContainer.new()
	blocco.add_theme_constant_override("separation", 2)
	if chi != "":
		var nome := Label.new()
		nome.text = chi
		nome.add_theme_color_override("font_color", Stile.colore("accento"))
		nome.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
		blocco.add_child(nome)
	var corpo := RichTextLabel.new()
	corpo.bbcode_enabled = true
	corpo.fit_content = true
	corpo.scroll_active = false
	corpo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corpo.add_theme_font_size_override("normal_font_size", Stile.dimensione("piccolo"))
	corpo.add_theme_font_size_override("italics_font_size", Stile.dimensione("piccolo"))
	corpo.add_theme_font_size_override("bold_font_size", Stile.dimensione("piccolo"))
	match tipo:
		"dialogo":
			corpo.text = testo
			corpo.add_theme_color_override("default_color", Stile.colore("testo"))
		"notifica":
			corpo.text = testo
			corpo.add_theme_color_override("default_color", Stile.colore("accento"))
		"titolo":
			corpo.text = "[b]%s[/b]" % testo
			corpo.add_theme_color_override("default_color", Stile.colore("accento"))
		_:
			corpo.text = "[i]%s[/i]" % testo
			# sul nero del data pad: il colore della narrazione e' quasi nero da
			# quando il box dei dialoghi e' una pagina bianca, e qui spariva
			corpo.add_theme_color_override("default_color", Stile.colore("testo_smorzato"))
	blocco.add_child(corpo)
	return blocco

static func contenuto_scomparto(chiave: String) -> Array:
	if chiave == "collezionabili":
		return GameState.collezionabili + GameState.chiavi
	return GameState.contenuto_zaino(chiave)

static func capienza_testo(chiave: String, quanti: int) -> String:
	# gli scomparti senza tetto non devono mostrarne uno finto: gli oggetti
	# speciali sono la storia che ti porti dietro, non zavorra da amministrare
	if chiave in ["speciali", "collezionabili"]:
		return "%d" % quanti
	return "%d / %d" % [quanti, GameState.capacita_zaino(chiave)]

static func disegna_scomparto(genitore: VBoxContainer, chiave: String) -> void:
	var elenco := contenuto_scomparto(chiave)
	if elenco.is_empty():
		var vuoto := Label.new()
		vuoto.text = "Questo scomparto è vuoto."
		Stile.etichetta_piccola(vuoto)
		genitore.add_child(vuoto)
		return
	# quanti ne hai dello stesso tipo: tre fiale sono una riga con un x3, non tre
	# righe uguali una sotto l'altra
	var conteggio := {}
	var ordine: Array[String] = []
	for id_oggetto in elenco:
		var id_stringa := String(id_oggetto)
		if not conteggio.has(id_stringa):
			conteggio[id_stringa] = 0
			ordine.append(id_stringa)
		conteggio[id_stringa] = int(conteggio[id_stringa]) + 1
	for id_oggetto in ordine:
		genitore.add_child(SchedaOggetto.riga(id_oggetto, int(conteggio[id_oggetto]),
				Merce.riassunto_effetto(GameState.dati_oggetto(id_oggetto), "nessun effetto")))
