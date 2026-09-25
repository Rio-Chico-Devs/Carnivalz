class_name PaginePausa
extends RefCounted

# LE PAGINE DEL DATA PAD: cosa c'e' scritto dentro il Diario, lo Storico e lo
# Zaino. Stavano in Pausa.gd, che le mostrava; adesso Pausa decide QUANDO si
# apre un pannello e come ci si muove dentro, e qui sta COSA c'e' scritto. Sono
# due domande diverse, e la seconda cresce con la storia (una missione nuova,
# un contatore nuovo, un oggetto nuovo) senza che il menu debba saperlo.
#
# Il file di pausa era oltre le ottocentosettanta righe e nell'elenco dei file
# troppo grandi c'era scritto «E' il taglio piu' facile di tutto il progetto».
# Lo era: nessuna di queste funzioni toccava lo stato del menu.

static func riempi(genitore: VBoxContainer, sezione: String) -> void:
	match sezione:
		"appunti": sezione_appunti(genitore)
		"messaggi": sezione_messaggi(genitore)
		"stato": sezione_stato(genitore)
		"crescita": sezione_crescita(genitore)
		"passive": sezione_passive(genitore)
		"squadra": sezione_squadra(genitore)
		"osservazioni": sezione_osservazioni(genitore)
		"organizzazione": sezione_organizzazione(genitore)

static func sezione_messaggi(genitore: VBoxContainer) -> void:
	# «c'e' anche una sezione messaggi dove l'organizzazione ti ha versato 3000
	# tazo come quota di benvenuto» (Bru).
	#
	# Non sono gli appunti: quelli sono pensieri del protagonista, questi sono
	# voci di altri - e si vede. Mittente e oggetto in testa, il corpo sotto, e
	# aprendo la sezione si considerano letti tutti.
	titolo_sezione(genitore, "Messaggi")
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

static func sezione_appunti(genitore: VBoxContainer) -> void:
	# la prima cosa che si legge aprendo il Diario: dove devo andare adesso.
	# Non sono obiettivi con la spunta, sono pensieri del protagonista, quindi
	# stanno in corsivo e per esteso — la spunta e' solo un promemoria di
	# quello che ha gia' risolto
	titolo_sezione(genitore, "Appunti")
	if GameState.task_attivi.is_empty() and GameState.task_chiusi.is_empty():
		var vuoto := Label.new()
		vuoto.text = "Niente da segnare, per ora."
		Stile.etichetta_piccola(vuoto)
		genitore.add_child(vuoto)
		return
	for id_task in GameState.task_attivi:
		genitore.add_child(riga_appunto(GameState.dati_task(id_task)))
	if GameState.task_chiusi.is_empty():
		return
	var separatore := Label.new()
	separatore.text = "Già risolti"
	Stile.etichetta_piccola(separatore)
	genitore.add_child(separatore)
	for id_task in GameState.task_chiusi:
		var voce := GameState.dati_task(id_task)
		var fatto := Label.new()
		fatto.text = "✓  " + String(voce.get("titolo", id_task))
		Stile.etichetta_piccola(fatto)
		fatto.modulate = Color(1, 1, 1, 0.55)
		genitore.add_child(fatto)

static func riga_appunto(voce: Dictionary) -> Control:
	var blocco := VBoxContainer.new()
	blocco.add_theme_constant_override("separation", 4)
	var intestazione_riga := Label.new()
	intestazione_riga.text = "◆  " + String(voce.get("titolo", ""))
	intestazione_riga.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	intestazione_riga.add_theme_color_override("font_color", Stile.colore("bordo_acceso"))
	blocco.add_child(intestazione_riga)
	var chi := String(voce.get("da", ""))
	if chi != "":
		# chi ha chiesto la cosa puo' essere un png (personaggi.json) o un
		# compagno giocabile (classes.json): si guarda in tutt'e due
		var scheda: Dictionary = GameState.personaggi.get(chi, {})
		var nome := String(scheda.get("nome", ""))
		if nome == "":
			var classe: Dictionary = GameState.classi.get(chi, {})
			nome = String(classe.get("nome", chi))
		var firma := Label.new()
		firma.text = "chiesto da " + nome
		Stile.etichetta_piccola(firma)
		blocco.add_child(firma)
	var corpo := RichTextLabel.new()
	corpo.bbcode_enabled = true
	corpo.fit_content = true
	corpo.scroll_active = false
	corpo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# gli appunti li pensa il protagonista: si accordano come le sue battute
	corpo.text = "[i]%s[/i]" % Testi.accorda(String(voce.get("testo", "")), GameState.sesso_protagonista)
	# NON IL COLORE DELLA NARRAZIONE: quello e' quasi nero da quando il box dei
	# dialoghi e' una pagina bianca, e qui il fondo e' nero - gli appunti erano
	# righe invisibili. Visto facendo il giro guidato del data pad
	corpo.add_theme_color_override("default_color", Stile.colore("testo_smorzato"))
	corpo.add_theme_font_size_override("normal_font_size", Stile.dimensione("piccolo"))
	corpo.add_theme_font_size_override("italics_font_size", Stile.dimensione("piccolo"))
	blocco.add_child(corpo)
	return blocco

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

static func sezione_stato(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Stato")
	var livello := GameState.livello_di(GameState.id_protagonista)
	var xp_ora := int(GameState.xp.get(GameState.id_protagonista, 0))
	voce_diario(genitore, "Livello", "%d  (%d / %d esperienza)" % [livello, xp_ora, GameState.fabbisogno_xp(livello)])
	var tabella_stat: Dictionary = GameState.crescita.get("stat", {})
	for chiave in tabella_stat:
		var nome_stat := String(chiave)
		var info: Dictionary = tabella_stat[chiave]
		var guadagnati := int(GameState.punti_stat.get(nome_stat, 0))
		var testo := str(GameState.stat_di(nome_stat))
		if guadagnati > 0:
			testo += "   (base %d + %d guadagnati)" % [GameState.stat_base_di(nome_stat), guadagnati]
		voce_diario(genitore, String(info.get("nome", nome_stat)), testo)

static func sezione_crescita(genitore: VBoxContainer) -> void:
	# la parte piu' utile del diario: non "quanto vali", ma COSA ti sta facendo
	# crescere. Ogni riga dice quanto manca al prossimo punto di quella stat.
	titolo_sezione(genitore, "Cosa ti sta cambiando")
	var regole_crescita: Dictionary = GameState.crescita.get("crescita", {})
	if regole_crescita.is_empty():
		return
	var tabella_stat: Dictionary = GameState.crescita.get("stat", {})
	for chiave in regole_crescita:
		var nome_azione := String(chiave)
		var regola: Dictionary = regole_crescita[chiave]
		var ogni := maxi(int(regola.get("ogni", 1)), 1)
		var fatte := int(GameState.contatori.get(nome_azione, 0))
		var nome_stat := String(regola.get("stat", ""))
		var info_stat: Dictionary = tabella_stat.get(nome_stat, {})
		var nome_leggibile := String(info_stat.get("nome", nome_stat))
		voce_diario(genitore, etichetta_azione(nome_azione),
				"%d / %d verso +%d %s" % [fatte % ogni, ogni, int(regola.get("punti", 1)), nome_leggibile])

static func etichetta_azione(nome_azione: String) -> String:
	match nome_azione:
		"attacchi_sferrati": return "Colpi che hai sferrato"
		"danni_subiti": return "Danni che hai incassato"
		"difese": return "Volte che hai tenuto la guardia"
		"studi": return "Creature che hai studiato"
		"fughe": return "Volte che sei scappato"
		"oggetti_usati": return "Oggetti che hai usato"
		"stanze_esplorate": return "Stanze che hai esplorato"
		"stress_accumulato": return "Stress che hai retto"
		"critici_inflitti": return "Colpi critici che hai messo a segno"
		_: return nome_azione

static func sezione_passive(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Abilità passive")
	if GameState.passive_sbloccate.is_empty():
		var vuoto := Label.new()
		vuoto.text = "Nessuna, per ora."
		Stile.etichetta_piccola(vuoto)
		genitore.add_child(vuoto)
		return
	for gruppo in ["passive_livello", "passive_soglia", "passive_rare"]:
		var elenco: Array = GameState.crescita.get(gruppo, [])
		for elemento in elenco:
			var voce: Dictionary = elemento
			if not GameState.ha_passiva(String(voce.get("id", ""))):
				continue
			voce_diario(genitore, String(voce.get("nome", "")), String(voce.get("descrizione", "")))

static func sezione_squadra(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Squadra")
	voce_diario(genitore, "Legame", "%d / 100" % GameState.legame)
	for id_classe in GameState.party:
		if id_classe == GameState.id_protagonista:
			continue
		var definizione: Dictionary = GameState.classi.get(id_classe, {})
		var nome := String(definizione.get("nome", id_classe))
		var temporaneo := " (temporaneo)" if id_classe in GameState.alleati_temporanei else ""
		voce_diario(genitore, nome + temporaneo, "Lv %d   ·   stress %d" % [
			GameState.livello_di(id_classe), GameState.stress_di(id_classe)])

static func sezione_osservazioni(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Osservazioni")
	voce_diario(genitore, "Creature studiate", "%d" % GameState.studiati.size())
	voce_diario(genitore, "Creature incontrate", "%d" % GameState.bestiario.size())
	voce_diario(genitore, "Oggetti catalogati", "%d / %d" % [
		GameState.oggetti_catalogo.size(), GameState.oggetti.size()])
	if GameState.resistenze_stato.is_empty():
		return
	for chiave in GameState.resistenze_stato:
		var definizione: Dictionary = GameState.stati.get(chiave, {})
		var nome := String(definizione.get("nome", chiave))
		voce_diario(genitore, "Resistenza — " + nome, "+%d" % int(GameState.resistenze_stato[chiave]))

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
			# sul nero del data pad, come gli appunti (vedi riga_appunto)
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
