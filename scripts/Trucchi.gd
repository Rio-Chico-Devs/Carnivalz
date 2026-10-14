class_name Trucchi
extends RefCounted

# I TRUCCHI, PROVVISORI. Bru: «metti nel gioco un tasto provvisorio tra le
# opzioni che sia tipo un cheat code dove posso scegliere di riempirmi di xp o
# tazo o degli spendibili cosi' da testare».
#
# Stanno in fondo alle Opzioni della pausa, e solo li': servono a una partita
# aperta, e dal menu principale una partita non c'e'. Ogni tasto aggiunge e
# basta, si puo' premere quante volte si vuole; si salva come sempre, dalla
# mappa stellare.
#   xp           -> l'hype, che e' l'xp del gioco: va su tutti e due i
#                   contatori, quello da spendere e quello accumulato
#   tazo         -> la moneta
#   spendibili   -> la sacca piena di consumabili, uno per tipo a giro
#
# PER TOGLIERLI: ACCESI = false. O si cancella questo file e la riga che lo
# chiama in Pausa.mostra_opzioni. Prima che la beta esca vanno spenti.

const ACCESI := true
const HYPE := [1000, 10000, 100000]     # 1000 hype = un punto (regole.json, hype_per_punto)
const TAZO := [100, 1000, 10000]


static func dai_hype(quanto: int) -> void:
	GameState.hype_disponibile += quanto
	GameState.hype_accumulato += quanto


static func dai_tazo(quanto: int) -> void:
	GameState.modifica_tazo(quanto)


static func consumabili() -> Array[String]:
	# tutto quello che finisce nella sacca: i consumabili, non gli spazi (che
	# allargano lo zaino) ne' la cianfrusaglia (che va nella pila)
	var fuori: Array[String] = []
	for id_oggetto: String in GameState.oggetti:
		var tipo := String(GameState.dati_oggetto(id_oggetto).get("tipo", "consumabile"))
		if tipo not in ["spazio", "pila"] and GameState.categoria_zaino(id_oggetto) == "consumabili":
			fuori.append(id_oggetto)
	fuori.sort()
	return fuori


static func riempi_sacca() -> int:
	# un consumabile per tipo, a giro, finche' la sacca ha posto: quanti ne sono entrati
	var tipi := consumabili()
	var messi := 0
	while not tipi.is_empty() and GameState.spazio_libero("consumabili") > 0:
		if not GameState.aggiungi_oggetto(tipi[messi % tipi.size()]):
			break
		messi += 1
	return messi


# --- nelle opzioni della pausa ---------------------------------------------------------

static func costruisci(colonna: VBoxContainer, larghezza_etichetta: int) -> void:
	if not ACCESI:
		return
	PannelloOpzioni.sezione(colonna, "Trucchi, provvisori: per le prove")
	var esito := Label.new()
	esito.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	esito.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var hype: Array[Array] = []
	for quanto: int in HYPE:
		hype.append(["+%s" % migliaia(quanto), func() -> void:
			dai_hype(quanto)
			fatto(esito, "+%s hype: ora ne hai %s da spendere." % [migliaia(quanto), migliaia(GameState.hype_disponibile)])])
	riga(colonna, "Hype (l'xp)", larghezza_etichetta, hype)
	var tazo: Array[Array] = []
	for quanto: int in TAZO:
		tazo.append(["+%s" % migliaia(quanto), func() -> void:
			dai_tazo(quanto)
			fatto(esito, "+%s tazo: ora ne hai %s." % [migliaia(quanto), migliaia(GameState.tazo)])])
	riga(colonna, "Tazo", larghezza_etichetta, tazo)
	riga(colonna, "Spendibili", larghezza_etichetta, [["Riempi la sacca", func() -> void:
		var messi := riempi_sacca()
		fatto(esito, ("%d consumabili nella sacca, uno per tipo a giro." % messi) if messi > 0
				else "La sacca è già piena.")]])
	colonna.add_child(esito)


static func fatto(esito: Label, testo: String) -> void:
	# cosa e' appena successo, e il cartellino in alto a destra (Tazo e livello)
	# riscritto: lo scrive il pannello quando si apre, e restava vecchio
	esito.text = testo
	aggiorna_cartellino()


static func aggiorna_cartellino() -> void:
	var nuovo := Pausa.testo_risorse()
	for nodo in Pausa.colonna.find_children("*", "", true, false):
		if nodo is Cartiglio and (nodo as Cartiglio).testo.begins_with("TAZO ") and (nodo as Cartiglio).testo != nuovo:
			(nodo as Cartiglio).testo = nuovo
			(nodo as Cartiglio).update_minimum_size()
			(nodo as Cartiglio).queue_redraw()


static func riga(colonna: VBoxContainer, testo: String, larghezza_etichetta: int, tasti: Array) -> void:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 10)
	colonna.add_child(fila)
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.custom_minimum_size = Vector2(larghezza_etichetta, 0)
	fila.add_child(etichetta)
	for coppia: Array in tasti:
		fila.add_child(tasto(String(coppia[0]), coppia[1] as Callable))


static func tasto(testo: String, richiamo: Callable) -> Button:
	# la pillola del manifesto, come i tasti in basso a destra (Tasto.gd): arancio
	# con la scritta nera; col mouse sopra o col fuoco si accende il bordo
	var bottone := Button.new()
	bottone.text = testo
	bottone.add_theme_font_override("font", Caratteri.titolo())
	bottone.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	for colore in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		bottone.add_theme_color_override(colore, Stile.colore("box_testo"))
	for stato in ["normal", "hover", "pressed", "hover_pressed"]:
		var tappo := Manifesto.stile_pillola(Stile.colore("manifesto"), 12.0,
				Stile.colore("bordo") if stato != "normal" else Color(0, 0, 0, 0))
		tappo.content_margin_top = 2
		tappo.content_margin_bottom = 2
		bottone.add_theme_stylebox_override(stato, tappo)
	# il fuoco e' disegnato sopra la scritta: solo il bordo, senza fondo
	bottone.add_theme_stylebox_override("focus", Manifesto.stile_pillola(Color(0, 0, 0, 0), 12.0, Stile.colore("bordo")))
	bottone.pressed.connect(richiamo)
	return bottone


static func migliaia(n: int) -> String:
	# 10000 -> 10.000
	var cifre := str(absi(n))
	var fuori := ""
	while cifre.length() > 3:
		fuori = "." + cifre.substr(cifre.length() - 3) + fuori
		cifre = cifre.substr(0, cifre.length() - 3)
	return ("-" if n < 0 else "") + cifre + fuori
