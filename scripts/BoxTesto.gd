extends PanelContainer

# Il box del testo: l'unico posto dove il gioco parla al giocatore.
# Lo usano la schermata eventi e (in forma ridotta) le altre schermate che
# devono dire qualcosa. Regole, tutte qui dentro e non sparse nei JSON:
#
#   dialogo     -> targhetta col nome di chi parla, testo dritto, colore pieno
#   narrazione  -> nessuna targhetta, corsivo, colore piu' spento: e' la voce
#                  che racconta dall'esterno, non qualcuno nella stanza
#   notifica    -> nessuna targhetta, centrato, colore accento: e' il gioco
#                  che ti informa (hai raccolto, hai imparato), non la storia
#
# Il testo non compare mai tutto insieme: si scrive a macchina. Un click lo
# completa subito, il successivo passa avanti (comportamento standard delle
# visual novel, e la cosa che i giocatori si aspettano senza doverla imparare).
# Finita la scrittura compare il triangolino che pulsa in basso a destra.
#
# La macchina da scrivere e' MacchinaDaScrivere.gd, la stessa del racconto a
# schermo intero: si ferma dove si fermerebbe una voce, e suona mentre scrive.
#
# Altezza SEMPRE fissa (Stile.forma("altezza_box")): "fit_content" e' spento
# apposta. Un messaggio piu' lungo di un altro non deve far crescere il box
# e spingere su/giu' tutto il resto della schermata (i ritratti sopra). E UN
# TESTO CHE NON CI STA SI DIVIDE IN PAGINE (Impaginatore.gd): prima scorreva
# sotto il bordo, dove nessuno poteva leggerlo - Bru: «alcuni dialoghi sforano
# il container di testo». Si misura il box vero, adesso: la stessa battuta puo'
# stare in una pagina a finestra grande e in due col testo ingrandito. Chi usa
# il box va avanti di pagina con pagina_seguente() prima di passare alla
# battuta dopo. Per lo stesso motivo dell'altezza fissa:
#   - il triangolino "vai avanti" NON sta nella colonna: e' un fratello del
#     contenitore, sovrapposto in basso a destra. Se stesse nel flusso, il
#     box crescerebbe di una riga ogni volta che compare.
#   - la targhetta col nome non si nasconde mai: quando non parla nessuno
#     resta li' vuota. Nasconderla toglierebbe la sua riga e farebbe saltare
#     su il testo tra una narrazione e un dialogo.

signal scrittura_finita

@onready var targhetta: Label = %Targhetta
@onready var testo: RichTextLabel = %Testo
@onready var indicatore: Label = %Indicatore

var macchina: MacchinaDaScrivere
var sta_scrivendo: bool:
	get: return macchina.sta_scrivendo
var tween_indicatore: Tween
var tipo_corrente := "narrazione"
var nome_corrente := ""
# le pagine della battuta in corso, e a quale si e'. Una battuta corta e' una
# pagina sola, ed e' il caso di quasi tutte
var pagine: Array[String] = []
var pagina := 0
var battuta_intera := ""   # la battuta com'e' arrivata, prima di dividerla in pagine
var misuratore: RichTextLabel = null   # un doppione nascosto del testo, per misurare

func _init() -> void:
	# NASCE FIGLIA, non in _ready: un box creato e buttato senza entrare in scena
	# (le prove lo fanno) si lascerebbe dietro una macchina orfana
	macchina = MacchinaDaScrivere.new()
	add_child(macchina)

func _ready() -> void:
	macchina.finita.connect(conclusione)
	add_theme_stylebox_override("panel", Stile.stile_box_testo())
	Manifesto.decora_box(self)
	targhetta.add_theme_color_override("font_color", Stile.colore("accento_su_carta"))
	if Caratteri.nomi() != null:   # chi parla si scrive col carattere dei nomi
		targhetta.add_theme_font_override("font", Caratteri.nomi())
	targhetta.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	# L'INVITO AD ANDARE AVANTI: prima un triangolino nero (sulla pagina chiara il
	# colore d'accento tirava l'occhio piu' del testo); dal manifesto e' il rombo
	# del bozzetto approvato, contornato di nero perche' si stacchi dalla carta.
	# un rombo arancio contornato di nero, come quelli sui fianchi del box
	indicatore.text = "◆"
	indicatore.add_theme_color_override("font_color", Stile.colore("manifesto"))
	indicatore.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	Stile.contorno(indicatore, Stile.dimensione("piccolo"))
	indicatore.visible = false
	usa_il_carattere_dei_dialoghi()
	# IL TESTO DA LEGGERE VUOLE ARIA FRA LE RIGHE. Il box tiene paragrafi, non
	# una riga sola, e finche' nessuno decideva l'interlinea la decideva il font
	# DI SISTEMA - quindi diversa su ogni macchina, e non c'era modo di
	# accorgersene provando su una sola
	Stile.interlinea(testo, "lettura", Caratteri.corpo_dialoghi())
	# la targhetta tiene la sua riga anche quando e' vuota: se collassasse, il
	# testo salterebbe su di una riga passando da un dialogo a una narrazione
	var font_targhetta := targhetta.get_theme_font("font")
	if font_targhetta != null:
		targhetta.custom_minimum_size = Vector2(0, font_targhetta.get_height(Stile.dimensione("nome")))
	imposta_altezza(Stile.forma("altezza_box"))
	# la misura vera arriva col primo giro di impaginazione dei contenitori, e
	# puo' cambiare (finestra, testo piu' grande): a ogni cambio si rimisura
	testo.resized.connect(_al_cambio_di_misura)

func usa_il_carattere_dei_dialoghi() -> void:
	# IL CARATTERE DEI DIALOGHI, scelto da Bru (Caratteri.dialoghi, misure in
	# data/stile.json sezione "dialoghi"): dritto per chi parla, inclinato per
	# la narrazione che e' in corsivo, col tratto ispessito per il grassetto.
	# Solo qui dentro: il resto dell'interfaccia tiene il carattere del tema
	var corpo := Caratteri.corpo_dialoghi()
	for coppia: Array in [["normal", "dritto"], ["italics", "corsivo"],
			["bold", "grassetto"], ["bold_italics", "grassetto_corsivo"]]:
		var carattere := Caratteri.dialoghi(String(coppia[1]))
		if carattere != null:
			testo.add_theme_font_override(String(coppia[0]) + "_font", carattere)
		testo.add_theme_font_size_override(String(coppia[0]) + "_font_size", corpo)

func nome_fuori_dal_box() -> void:
	# IL NOME DI CHI PARLA ESCE DAL BOX. Nel disegno di Bru sta su un pezzo di
	# nastro rosa appiccicato storto sopra l'angolo, fuori dalla pagina bianca -
	# e allora dentro non deve restare ne' la targhetta ne' la riga vuota che le
	# teneva il posto, o il box resterebbe alto per niente.
	#
	# Lo chiede chi usa il box, e non lo decide il box: il diario del
	# combattimento e' lo stesso nodo e li' la targhetta serve dov'e'.
	targhetta.visible = false
	targhetta.custom_minimum_size = Vector2.ZERO
	imposta_altezza(Stile.forma("altezza_box"))

func posto_al_triangolo(si: bool) -> void:
	# IL TRIANGOLINO HA IL SUO POSTO, quando il box e' stretto: l'ultima parola
	# della riga ci finiva sotto. Il doppione che misura le pagine si rifa': fatto
	# prima del margine, misurava righe piu' larghe del vero, una battuta di
	# quattro righe stava "in una pagina" e scorreva sotto il bordo
	if si:
		var margine := StyleBoxEmpty.new()
		margine.content_margin_right = 40.0
		testo.add_theme_stylebox_override("normal", margine)
	else:
		testo.remove_theme_stylebox_override("normal")
	if misuratore != null:
		misuratore.queue_free()
		misuratore = null
	_al_cambio_di_misura()

func imposta_altezza(altezza_testo: int) -> void:
	# l'altezza del box si decide una volta e non cambia piu': testo + riga
	# della targhetta + separazione + i margini della cornice. Il combattimento
	# ne chiede una piu' bassa (messaggi corti, e il campo ha bisogno di spazio)
	var altezza_nome := 0.0
	var font_nome := targhetta.get_theme_font("font")
	if font_nome != null and targhetta.visible:
		altezza_nome = font_nome.get_height(Stile.dimensione("nome"))
	testo.custom_minimum_size = Vector2(0, altezza_testo)
	var cornice := Stile.stile_box_testo()
	custom_minimum_size = Vector2(0, altezza_testo + altezza_nome + 8
			+ cornice.get_margin(SIDE_TOP) + cornice.get_margin(SIDE_BOTTOM))

func mostra(tipo: String, contenuto: String, nome_parlante: String) -> void:
	visible = true
	tipo_corrente = tipo
	nome_corrente = nome_parlante
	if tipo == "notifica":
		# la notifica non e' qualcuno che parla, e' il gioco che ti dice che hai
		# qualcosa in piu': ha un suono suo, e arriva prima delle parole
		AudioManager.interfaccia("raccolta")
	targhetta.text = nome_parlante if tipo == "dialogo" else ""
	battuta_intera = contenuto
	pagine = impagina(contenuto)
	pagina = 0
	scrivi_pagina()

func ha_altre_pagine() -> bool:
	return pagina < pagine.size() - 1

func consuma_click() -> bool:
	# IL CLICK CHE RESTA DENTRO LA BATTUTA: completa il testo che si sta
	# scrivendo, o gira pagina. false = la battuta e' finita tutta, e il click
	# e' di chi usa il box (la battuta dopo, le scelte)
	if sta_scrivendo:
		completa()
		return true
	return pagina_seguente()

func pagina_seguente() -> bool:
	# true = si e' girata pagina, e chi chiama non deve passare alla battuta dopo
	if sta_scrivendo or not ha_altre_pagine():
		return false
	pagina += 1
	scrivi_pagina()
	return true

func impagina(contenuto: String) -> Array[String]:
	var misura := spazio_per_il_testo()
	if misura.x < 2.0 or misura.y < 2.0:
		# non si sa ancora quanto e' grande (il primo messaggio arriva prima che
		# i contenitori abbiano dato le misure): si rimisura appena si sa
		var intera: Array[String] = [contenuto]
		return intera
	return Impaginatore.dividi(contenuto, func(pezzo: String) -> bool: return entra(pezzo, misura))

func spazio_per_il_testo() -> Vector2:
	return Vector2(testo.size.x, testo.size.y if testo.size.y > 0.0 else testo.custom_minimum_size.y)

func entra(pezzo: String, misura: Vector2) -> bool:
	if misuratore == null:
		# IL DOPPIONE MISURA COME L'ORIGINALE: stessi caratteri, stessa interlinea,
		# stesso bbcode. Resta nascosto, fuori dal giro dei contenitori
		# duplicate(0): proprieta' e basta. Coi segnali il doppione si porterebbe
		# dietro anche "resized", e misurare lo farebbe rimisurare all'infinito
		misuratore = testo.duplicate(0) as RichTextLabel
		misuratore.visible = false
		misuratore.fit_content = false
		add_child(misuratore)
	misuratore.size = misura
	misuratore.text = formattato(tipo_corrente, pezzo)
	return misuratore.get_content_height() <= misura.y + 0.5

func _al_cambio_di_misura() -> void:
	if pagine.is_empty() or not visible:
		return
	var misura := spazio_per_il_testo()
	if misura.x < 2.0:
		return
	# ALLA PRIMA PAGINA LA BATTUTA SI RIFA' DA CAPO, INTERA. Un box che parla
	# appena nato (il giro del data pad, la Guida sulla mappa) misura la prima
	# battuta prima che i contenitori gli abbiano dato la larghezza: largo 41
	# pixel, la divideva in una pagina per parola - Bru: «l'inizio della
	# spiegazione mostra parola per parola». Arrivata la misura vera, prima si
	# guardava solo se la pagina corrente ci stava ancora: «Il» ci sta sempre, e
	# le pagine restavano di una parola. Se non cambia niente non si riscrive
	if pagina == 0:
		var rifatte := impagina(battuta_intera)
		if rifatte != pagine:
			pagine = rifatte
			scrivi_pagina()
		return
	# piu' avanti non si torna indietro: la pagina che si sta leggendo, se non
	# ci sta piu' (la finestra si e' stretta), si divide adesso
	if entra(pagine[pagina], misura):
		return
	var nuove := impagina(pagine[pagina])
	pagine.remove_at(pagina)
	for k in nuove.size():
		pagine.insert(pagina + k, nuove[k])
	scrivi_pagina()

func formattato(tipo: String, contenuto: String) -> String:
	match tipo:
		"notifica":
			return "[center]%s[/center]" % contenuto
		"dialogo":
			return contenuto
	return "[i]%s[/i]" % contenuto

func scrivi_pagina() -> void:
	var contenuto := pagine[pagina]
	testo.scroll_to_line(0)  # pagina nuova: si riparte sempre dall'inizio del testo
	testo.text = formattato(tipo_corrente, contenuto)
	# IL TESTO DEL BOX E' NERO, perche' il box e' una pagina bianca. Tutti i
	# colori qui sotto sono quelli che si leggono SU BIANCO - e non sono gli
	# stessi che si leggono sul nero delle scelte: il rosso di una notifica su
	# fondo chiaro va scurito, o vibra.
	match tipo_corrente:
		"dialogo":
			testo.add_theme_color_override("default_color", Stile.colore("box_testo"))
		"notifica":
			testo.add_theme_color_override("default_color", Stile.colore("accento_su_carta"))
		"vista":
			# QUELLO CHE SI VEDE DA QUI, e non e' la stanza in cui sei.
			#
			# Una riga di vista parla di un posto LONTANO: il vivaio in fondo al
			# giardino, la torre oltre il ponte. Se avesse lo stesso colore della
			# descrizione del posto in cui ti trovi, sarebbe solo un'altra frase
			# di ambiente - e invece e' l'unica cosa in tutto il gioco che ti dice
			# dove SEI rispetto al resto. Quindi ha un colore suo, e si impara a
			# riconoscerlo: quando compare questo, stai guardando lontano.
			testo.add_theme_color_override("default_color", Stile.colore("eroe"))
		_:
			testo.add_theme_color_override("default_color", Stile.colore("narrazione"))
	scrivi_a_macchina()

func scrivi_a_macchina() -> void:
	indicatore.visible = false
	macchina.scrivi(testo, nome_corrente, tipo_corrente)

func completa() -> void:
	# il giocatore ha fretta: il testo si chiude subito, senza saltare nulla
	macchina.completa()

func conclusione() -> void:
	indicatore.visible = true
	if tween_indicatore != null and tween_indicatore.is_valid():
		tween_indicatore.kill()
	var battito := Stile.tempo("battito_indicatore")
	tween_indicatore = create_tween().set_loops()
	tween_indicatore.tween_property(indicatore, "modulate:a", 0.15, battito)
	tween_indicatore.tween_property(indicatore, "modulate:a", 1.0, battito)
	# "finita" vuol dire la battuta, non la pagina: chi aspetta la fine del
	# testo (le scelte, l'andare avanti da soli) aspetta l'ultima
	if not ha_altre_pagine():
		scrittura_finita.emit()

func nascondi_indicatore() -> void:
	# a coda finita non c'e' piu' niente da far avanzare: comandano le scelte
	indicatore.visible = false
	if tween_indicatore != null and tween_indicatore.is_valid():
		tween_indicatore.kill()
