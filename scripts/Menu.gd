class_name MenuPrincipale
extends Control

# LA SCHERMATA PRINCIPALE, rifatta sul riferimento che Bru ha scelto: il menu
# di Borderlands 2 («la nostra e' 2/10, questa e' 9/10»). Bru, su cosa guardare:
# «il layout PRECISO di questa schermata. angolazioni, posizione del testo, font
# particolare, effetti dietro il testo per dare piu' visibilita', color theory»,
# e sul come: «e' piu' organizzato, da' accesso a piu' cose, non che ti sbatte
# subito gli slot o la partita salvata, ci vuole piu' steps e organizzazione».
#
# IL LAYOUT, misurato sul riferimento (736x414) e tenuto in frazioni dello
# schermo, cosi' vale a qualunque risoluzione:
#
#   testata «MENU PRINCIPALE»   in alto a sinistra, 7,8% da sinistra e 8% dall'alto,
#                               piccola e tonda, con una scia di luce dietro
#   le voci                     maiuscole strette, una sotto l'altra dal 12,5%,
#                               passo del 5,6% (40 pixel a 720)
#   la descrizione              della voce scelta, in basso a sinistra (dall'83%):
#                               un titolo e una o due righe
#   le tue partite              in alto a destra (dal 71% in orizzontale, 10% in
#                               verticale): dove li' c'e' la squadra
#   i comandi                   in basso a destra: INVIO Seleziona, ESC Indietro
#
# IL COLORE: tutto quello che non e' scelto sta nei blu della notte, e la voce
# scelta e' dell'unico colore caldo, dalla parte opposta del cerchio - li' il
# giallo, qui il cremisi di Carnivalz (vedi _nota_menu in data/stile.json).
#
# I PASSI. Prima un titolo, «premi un tasto», come nel riferimento; poi il menu,
# che NON mostra le partite: le partite stanno dietro CONTINUA (la piu' recente,
# in un tocco), NUOVA PARTITA (dove scriverla, poi chi sei) e CARICA PARTITA
# (quale, o quale cancellare). Ogni passo ha la stessa forma, e ESC torna indietro
# di uno. Il titolo si vede una volta sola per sessione: tornando dalle Opzioni
# si ritrova il menu, non il titolo.
#
# Dentro il gioco dei salvataggi non si parla: il gioco scrive da solo, nella
# partita scelta qui, ogni volta che rientri alla Sede.

const FILE_EVENTI_INTRO := "res://data/events_intro.json"
const SCENA_SEDE := "res://scenes/Sede.tscn"
const SCENA_ALBUM := "res://scenes/Album.tscn"
const SCENA_BESTIARIO := "res://scenes/Bestiario.tscn"
const SCENA_COMPENDIO := "res://scenes/Compendio.tscn"

# il layout, in frazioni dello schermo (vedi sopra)
const X_TESTO := 0.078
const Y_TESTATA := 0.08
const Y_VOCI := 0.125
const Y_DESCRIZIONE := 0.83       # dove comincia nel riferimento, con due righe
# LO SPAZIO DELLA DESCRIZIONE: e' appesa al fondo (FINE_DESCRIZIONE) e cresce
# verso l'alto, dentro una zona tutta sua che comincia a ZONA_DESCRIZIONE. Le
# voci devono finire prima; la descrizione al massimo fa un titolo e tre
# righe, e ci sta anche col testo piu' grande (le prove contano le righe)
const ZONA_DESCRIZIONE := 0.74
const FINE_DESCRIZIONE := 0.965
const RIGHE_DESCRIZIONE := 3
const X_PANNELLO := 0.713       # dove comincia nel riferimento; qui conta dove FINISCE:
const X_FINE_PANNELLO := 0.94   # il pannello e' largo 300 pixel e cresce verso sinistra da qui,
                                # cosi' non esce dallo schermo nemmeno col testo piu' grande
const Y_PANNELLO := 0.10
const X_COMANDI := 0.935
const Y_COMANDI := 0.895
const LARGO_DESCRIZIONE := 0.46
const TESTATA_DOPO := 0.0
const CASCATA_DOPO := 0.10
const PANNELLO_DOPO := 0.12
const SPAZIO_DAL_PANNELLO := 48.0   # fra le righe delle opzioni e il pannello
# cosa dicono le voci di EXTRA (erano in Extra.gd, che adesso e' una pagina di
# questo menu). Da confermare con Bru
const INSTAGRAM := "@iltuohandle (da confermare)"
const SITO := "iltuosito.it (da confermare)"
const RINGRAZIAMENTI := "I ringraziamenti arriveranno con una prossima versione della demo."

static var titolo_visto := false
# DOVE TORNARE quando si rientra da una schermata a parte (le collezioni): la
# pagina e la voce da cui si era usciti. «Torna al menu» che ti rimette in cima
# al menu principale e' un indietro che ti fa rifare la strada
static var ritorno: Dictionary = {}

var fondale: LunaPark
var insegna: Control             # il titolo: CARNIVALZ, «premi un tasto»
var menu: Control                # tutto il resto
var testata: Testata
var colonna: VBoxContainer
var descrizione: Descrizione
var pannello: PannelloPartite
var comandi: HBoxContainer
var schegge: Schegge
var voci: Array[VoceMenu] = []
var pagina := ""
var indietro_da_qui := Callable()
var campo_nome: LineEdit
var campo_codice: LineEdit


func _ready() -> void:
	AudioManager.musica_chiave("menu")
	# una partita giocata prima che gli slot esistessero diventa la partita 1:
	# chi stava giocando riapre e ritrova la sua roba, non cinque righe vuote
	GameState.recupera_salvataggio_vecchio()
	fondale = LunaPark.new()
	fondale.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondale)
	costruisci_menu()
	schegge = Schegge.new()
	schegge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schegge)
	if titolo_visto:
		insegna = null
		apri_menu()
	else:
		mostra_titolo()


func costruisci_menu() -> void:
	menu = Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.visible = false
	add_child(menu)
	testata = Testata.new()
	ancora(testata, X_TESTO, Y_TESTATA)
	menu.add_child(testata)
	# LE MISURE SONO FRAZIONI DELLO SPAZIO VERO, non pixel su 1280x720: con
	# «testo piu' grande» l'interfaccia e' ingrandita del 25% e lo spazio che
	# resta e' 1024x576. Una larghezza scritta in pixel li' esce dallo schermo
	descrizione = Descrizione.new()
	ancora(descrizione, X_TESTO, FINE_DESCRIZIONE)
	descrizione.anchor_right = X_TESTO + LARGO_DESCRIZIONE
	descrizione.grow_vertical = Control.GROW_DIRECTION_BEGIN
	menu.add_child(descrizione)
	pannello = PannelloPartite.new()
	ancora(pannello, X_FINE_PANNELLO, Y_PANNELLO)
	pannello.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	menu.add_child(pannello)
	comandi = HBoxContainer.new()
	comandi.add_theme_constant_override("separation", 24)
	ancora(comandi, X_COMANDI, Y_COMANDI)
	comandi.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	menu.add_child(comandi)


func ancora(nodo: Control, x: float, y: float) -> void:
	# appeso a un punto dello schermo in frazioni, non in pixel: a 1920x1080 la
	# testata sta allo stesso 7,8% da sinistra
	nodo.anchor_left = x
	nodo.anchor_right = x
	nodo.anchor_top = y
	nodo.anchor_bottom = y
	nodo.offset_left = 0.0
	nodo.offset_top = 0.0


func _unhandled_input(evento: InputEvent) -> void:
	if insegna != null and is_instance_valid(insegna):
		if (evento is InputEventKey and evento.pressed and not evento.echo) \
				or (evento is InputEventMouseButton and evento.pressed):
			get_viewport().set_input_as_handled()
			entra_dal_titolo()
		return
	if evento.is_action_pressed("ui_cancel") and indietro_da_qui.is_valid():
		get_viewport().set_input_as_handled()
		Movimento.suona("chiusura")
		indietro_da_qui.call()


# --- il titolo ---------------------------------------------------------------------

func mostra_titolo() -> void:
	# IL PRIMO PASSO: il nome del gioco sul luna park, e l'invito a entrare. E'
	# la schermata «premi start» del riferimento, e serve a una cosa sola: che
	# il menu arrivi quando lo chiedi, non addosso
	insegna = Control.new()
	insegna.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	insegna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(insegna)
	move_child(insegna, fondale.get_index() + 1)
	var scritta := Control.new()
	scritta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scritta.rotation = Stile.angolo("inclinazione_nastro")
	ancora(scritta, 0.5, 0.36)
	insegna.add_child(scritta)
	# CARNIVALZ a strati, come le fasce della pausa: il bianco sotto, sporgente,
	# il cremisi sopra col bordo nero
	for strato: Array in [[Vector2(9, 9), "testo"], [Vector2.ZERO, "accento"]]:
		var nome := etichetta("CARNIVALZ", Caratteri.titolo(), 132, Stile.colore(String(strato[1])))
		centra(nome, strato[0])
		scritta.add_child(nome)
	var demo := Cartiglio.nuovo("DEMO", Stile.colore("bordo_acceso"), Stile.colore("box_testo"),
			Stile.colore("accento"), Stile.dimensione("corpo"))
	demo.position = Vector2(170, 64)
	scritta.add_child(demo)
	demo.svela(0.35)
	var motto := etichetta("una festa per chi ha subìto ingiustizie", Caratteri.tondo(700),
			Stile.dimensione("piccolo"), Stile.colore("menu_chiaro"))
	motto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	motto.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	motto.offset_top = 720.0 * 0.52
	motto.offset_left = -400
	motto.offset_right = 400
	insegna.add_child(motto)
	var invito := Stile.costruisci_prompt("premi un tasto")
	invito.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	invito.offset_top = -150
	invito.offset_bottom = -110
	invito.offset_left = -300
	invito.offset_right = 300
	insegna.add_child(invito)
	Stile.pulsa(invito)
	insegna.modulate.a = 0.0
	var dentro := insegna.create_tween()
	Movimento.verso(dentro, insegna, "modulate:a", 1.0, "entrata", Movimento.durata("quinta"))


func entra_dal_titolo() -> void:
	titolo_visto = true
	Movimento.suona("apertura")
	var vecchia := insegna
	insegna = null
	Movimento.congeda(vecchia, Movimento.durata("uscita"))
	apri_menu()


func apri_menu() -> void:
	menu.visible = true
	# il menu si dissolve dentro mentre il titolo si dissolve fuori: senza, la
	# descrizione e i comandi comparivano di colpo sotto il titolo ancora acceso
	menu.modulate.a = 0.0
	Movimento.verso(menu.create_tween(), menu, "modulate:a", 1.0, "entrata", Movimento.durata("entrata"))
	pannello.aggiorna()
	pannello.entra(PANNELLO_DOPO)
	var da_dove := ritorno
	ritorno = {}
	if String(da_dove.get("pagina", "")) == "collezioni":
		pagina_collezioni(String(da_dove.get("fuoco", "")))
	else:
		pagina_principale()


func centra(nodo: Control, spostamento: Vector2) -> void:
	# centrato sul punto del genitore, qualunque misura prenda: la misura di una
	# scritta si sa solo quando e' nell'albero, quindi non si calcola, si lascia
	# crescere in tutte e due le direzioni
	nodo.set_anchors_preset(Control.PRESET_CENTER)
	nodo.grow_horizontal = Control.GROW_DIRECTION_BOTH
	nodo.grow_vertical = Control.GROW_DIRECTION_BOTH
	nodo.offset_left = spostamento.x
	nodo.offset_right = spostamento.x
	nodo.offset_top = spostamento.y
	nodo.offset_bottom = spostamento.y


func etichetta(testo: String, carattere: Font, corpo: int, colore: Color) -> Label:
	var e := Label.new()
	e.text = testo
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if carattere != null:
		e.add_theme_font_override("font", carattere)
	e.add_theme_font_size_override("font_size", corpo)
	e.add_theme_color_override("font_color", colore)
	# il bordo scuro e' la regola di tutto il gioco: un sesto del corpo
	Stile.contorno(e, corpo)
	return e


# --- come si fa un passo ----------------------------------------------------------

static func voce(testo: String, titolo: String, corpo: String, azione: Callable, inerte := false) -> Dictionary:
	return {"testo": testo, "titolo": titolo, "corpo": corpo, "azione": azione, "inerte": inerte}


static func indice_di(elenco: Array[Dictionary], testo: String, altrimenti := 0) -> int:
	# TORNANDO INDIETRO SI RITROVA LA VOCE DA CUI SI ERA PARTITI: e' lei la
	# principale del passo (col fuoco, e ultima nella cascata)
	for i in elenco.size():
		if String(elenco[i].testo) == testo:
			return i
	return altrimenti


func mostra_pagina(nome: String, titolo: String, elenco: Array[Dictionary], principale: int,
		indietro: Callable, in_testa: Control = null) -> void:
	# UN PASSO: la testata, le voci in cascata (la principale per ultima e col
	# fuoco), la descrizione che segue il fuoco, i comandi. La colonna vecchia
	# si dissolve e non prende piu' clic dall'istante in cui la lasci
	pagina = nome
	indietro_da_qui = indietro
	Movimento.congeda(colonna, Movimento.durata("entrata") * Movimento.SOGLIA_CAMBIO)
	colonna = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 0)
	ancora(colonna, X_TESTO, Y_VOCI)
	colonna.offset_left = -VoceMenu.SPAZIO_SEGNO
	menu.add_child(colonna)
	if in_testa != null:
		colonna.add_child(in_testa)
	voci.clear()
	for dati in elenco:
		var v := VoceMacchia.crea(String(dati.testo))
		v.inerte = bool(dati.inerte)
		v.scoppio.connect(schegge.scoppia)
		v.scelta.connect(dati.azione)
		v.bottone.focus_entered.connect(descrizione.mostra.bind(String(dati.titolo), String(dati.corpo)))
		colonna.add_child(v)
		voci.append(v)
	testata.imposta(titolo, TESTATA_DOPO)
	Movimento.cascata(voci, principale, CASCATA_DOPO)
	metti_comandi(indietro.is_valid())


func metti_comandi(con_indietro: bool) -> void:
	for figlio in comandi.get_children():
		figlio.queue_free()
	comandi.add_child(Tasto.nuovo("INVIO", "Seleziona", premi_voce_col_fuoco))
	if con_indietro:
		comandi.add_child(Tasto.nuovo("ESC", "Indietro", func() -> void:
			Movimento.suona("chiusura")
			indietro_da_qui.call()))


func premi_voce_col_fuoco() -> void:
	# INVIO cliccato col mouse: fa quello che farebbe il tasto sulla cosa che ha
	# il fuoco. Una casella delle opzioni si accende o si spegne (emettere
	# "pressed" non la cambierebbe), una voce si sceglie
	var fuoco := get_viewport().gui_get_focus_owner()
	if fuoco is BaseButton and (fuoco as BaseButton).toggle_mode:
		(fuoco as BaseButton).button_pressed = not (fuoco as BaseButton).button_pressed
	elif fuoco is Button:
		(fuoco as Button).pressed.emit()


func voce_col_fuoco() -> VoceMenu:
	for v in voci:
		if v.bottone.has_focus():
			return v
	return null


# --- i passi ------------------------------------------------------------------------

func pagina_principale(fuoco := "") -> void:
	var recente := Partite.piu_recente()
	var elenco: Array[Dictionary] = []
	if recente > 0:
		elenco.append(voce("CONTINUA", "%s, livello %d" % [Partite.nome(recente), Partite.livello(recente)],
				"Partita %d, salvata %s. Si riparte dalla Sede.\n%s" % [recente, Partite.data(recente),
				GameState.anteprima_slot(recente)], continua.bind(recente)))
	elenco.append(voce("NUOVA PARTITA", "Un'altra festa",
			"Prima scegli dove scriverla - le partite sono cinque - poi chi sei.",
			pagina_nuova))
	elenco.append(voce("CARICA PARTITA", "Le tue partite" if recente > 0 else "Ancora niente da caricare",
			"Riprendi una partita qualsiasi, o cancellane una." if recente > 0
			else "Qui arrivano le partite, la prima volta che rientri alla Sede.", pagina_carica, recente <= 0))
	elenco.append(voce("COME SI GIOCA", "Prima di scendere",
			"Il menu di pausa, dove si salva, come si combatte e come si parano i pugni.", pagina_come_si_gioca))
	elenco.append(voce("COLLEZIONI", "Quello che hai trovato",
			"Le carte, le creature che hai studiato, gli oggetti che hai visto.", pagina_collezioni))
	elenco.append(voce("OPZIONI", "Come lo senti, come lo leggi",
			"Volume, schermo, testo più grande, alto contrasto, movimento ridotto.", pagina_opzioni))
	elenco.append(voce("EXTRA", "Fuori dal gioco", "I codici della demo, i ringraziamenti, dove seguirci.",
			pagina_extra))
	elenco.append(voce("ESCI", "Alla prossima",
			"Non si perde niente: il gioco si è già salvato l'ultima volta che sei rientrato alla Sede.",
			func() -> void: get_tree().quit()))
	mostra_pagina("principale", "MENU PRINCIPALE", elenco, indice_di(elenco, fuoco), torna_al_titolo)


func torna_al_titolo() -> void:
	titolo_visto = false
	indietro_da_qui = Callable()
	menu.visible = false
	mostra_titolo()


func pagina_nuova() -> void:
	var elenco: Array[Dictionary] = []
	var principale := -1
	for slot in range(1, GameState.SLOT_MASSIMO + 1):
		if GameState.ha_salvataggio_slot(slot):
			elenco.append(voce(Partite.etichetta(slot), "Qui c'è già una partita",
					"Sceglierla vuol dire ricominciarla da zero: quella di adesso viene sovrascritta al primo salvataggio.",
					pagina_sovrascrivi.bind(slot)))
		else:
			if principale < 0:
				principale = elenco.size()
			elenco.append(voce(Partite.etichetta(slot), "Una partita libera",
					"Qui non c'è niente: si comincia dall'inizio.", pagina_chi_sei.bind(slot)))
	mostra_pagina("nuova", "NUOVA PARTITA", elenco, maxi(principale, 0), pagina_principale.bind("NUOVA PARTITA"))


func pagina_sovrascrivi(slot: int) -> void:
	var elenco: Array[Dictionary] = [
		voce("NO, TORNA INDIETRO", "Lasciala stare", "La partita %d resta com'è." % slot, pagina_nuova),
		voce("SÌ, RICOMINCIA DA ZERO", "%s, livello %d" % [Partite.nome(slot), Partite.livello(slot)],
				"Questa partita verrà sovrascritta la prima volta che rientri alla Sede.", pagina_chi_sei.bind(slot)),
	]
	mostra_pagina("sovrascrivi", "RICOMINCIARE LA PARTITA %d?" % slot, elenco, 0, pagina_nuova)


func pagina_chi_sei(slot: int) -> void:
	# L'ULTIMO PASSO PRIMA DI GIOCARE: il nome e chi sei. Sono le due cose che
	# cambiano come il mondo ti parla, e si decidono una volta prima di
	# cominciare invece di essere chieste in mezzo a una scena
	GameState.imposta_slot(slot)
	GameState.nuova_partita()
	mostra_chi_sei("")


func mostra_chi_sei(nome: String) -> void:
	# si ridisegna ogni volta che scegli lui o lei («SCELTO» si sposta), senza
	# rifare la partita da capo e senza perdere il nome gia' scritto
	campo_nome = campo(nome)
	var elenco: Array[Dictionary] = []
	for chi: Array in [["LUI", "m"], ["LEI", "f"]]:
		var scelto := GameState.sesso_protagonista == String(chi[1])
		elenco.append(voce(String(chi[0]) + ("  — SCELTO" if scelto else ""), "Come ti parla il mondo",
				"Cambia gli accordi dei dialoghi: «sei arrivato» o «sei arrivata».",
				scegli_sesso.bind(String(chi[1])), scelto))
	elenco.append(voce("COMINCIA", "Si scende",
			"Il nome lo scrivi qui sopra; lasciato vuoto, resti l'Anonimo.", comincia))
	mostra_pagina("chi_sei", "CHI SEI", elenco, 2, pagina_nuova, campo_nome)
	campo_nome.text_submitted.connect(func(_testo: String) -> void: comincia())
	campo_nome.grab_focus()


func scegli_sesso(sesso: String) -> void:
	GameState.sesso_protagonista = sesso
	mostra_chi_sei(campo_nome.text)


func campo(testo: String, segnaposto := "ANONIMO") -> LineEdit:
	# il nome si scrive in una riga come quelle del pannello delle partite:
	# stesso fondo, stesso bordo, e le lettere delle voci
	var riga := LineEdit.new()
	riga.text = testo
	riga.placeholder_text = segnaposto
	riga.max_length = 24
	riga.custom_minimum_size = Vector2(360, 44)
	riga.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	if Caratteri.voce() != null:
		riga.add_theme_font_override("font", Caratteri.voce())
	riga.add_theme_font_size_override("font_size", VoceMacchia.CORPO)
	riga.add_theme_color_override("font_color", Stile.colore("testo"))
	riga.add_theme_color_override("font_placeholder_color", Color(Stile.colore("menu_voce"), 0.8))
	riga.add_theme_color_override("caret_color", Stile.colore("accento"))
	for stato in ["normal", "focus"]:
		var fondo := StyleBoxFlat.new()
		fondo.bg_color = Color(Stile.colore("menu_riga"), 0.85)
		fondo.set_border_width_all(2)
		fondo.border_color = Stile.colore("menu_riga_accesa_bordo" if stato == "focus" else "menu_riga_bordo")
		fondo.set_corner_radius_all(4)
		fondo.content_margin_left = VoceMenu.SPAZIO_SEGNO
		fondo.content_margin_right = 12
		riga.add_theme_stylebox_override(stato, fondo)
	return riga


func comincia() -> void:
	GameState.imposta_nome_protagonista(campo_nome.text)
	# L'INTRODUZIONE E' CONTENUTO, non una schermata a parte: vive in
	# data/events_intro.json come tutto il resto. La musica la prende chi comincia
	AudioManager.musica_chiave("intro")
	GameState.avvia_carnivalz("intro", FILE_EVENTI_INTRO)
	IngressoNodo.vai_al_nodo(GameState.nodo_corrente)


func continua(slot: int) -> void:
	if not GameState.carica_slot(slot):
		var v := voce_col_fuoco()
		if v != null:
			v.rifiuta()
		return
	Transizioni.vai(SCENA_SEDE)


func pagina_carica(fuoco := "") -> void:
	var elenco: Array[Dictionary] = []
	var principale := 0
	for slot in range(1, GameState.SLOT_MASSIMO + 1):
		var piena := GameState.ha_salvataggio_slot(slot)
		if slot == Partite.piu_recente():
			principale = elenco.size()
		elenco.append(voce(Partite.etichetta(slot),
				"%s, livello %d" % [Partite.nome(slot), Partite.livello(slot)] if piena else "Una partita libera",
				"Salvata %s.\n%s" % [Partite.data(slot), GameState.anteprima_slot(slot)] if piena
				else "Non c'è niente da caricare: le partite nuove si cominciano da NUOVA PARTITA.",
				continua.bind(slot), not piena))
	elenco.append(voce("CANCELLA UNA PARTITA", "Fare spazio", "Scegli quale partita cancellare. Te lo richiede prima di farlo.",
			pagina_cancella, Partite.occupate().is_empty()))
	mostra_pagina("carica", "CARICA PARTITA", elenco, indice_di(elenco, fuoco, principale),
			pagina_principale.bind("CARICA PARTITA"))


func pagina_cancella() -> void:
	var elenco: Array[Dictionary] = []
	for slot in range(1, GameState.SLOT_MASSIMO + 1):
		var piena := GameState.ha_salvataggio_slot(slot)
		elenco.append(voce(Partite.etichetta(slot), "Cancellare questa?" if piena else "Una partita libera",
				"Te lo chiede ancora una volta prima di farlo." if piena else "Qui non c'è niente da cancellare.",
				pagina_conferma_cancella.bind(slot), not piena))
	var occupate := Partite.occupate()
	mostra_pagina("cancella", "CANCELLA UNA PARTITA", elenco, occupate[0] - 1 if not occupate.is_empty() else 0,
			pagina_carica.bind("CANCELLA UNA PARTITA"))


func pagina_conferma_cancella(slot: int) -> void:
	var elenco: Array[Dictionary] = [
		voce("NO, LASCIALA STARE", "Non si tocca niente", "La partita %d resta dov'è." % slot, pagina_cancella),
		voce("SÌ, CANCELLALA", "%s, livello %d" % [Partite.nome(slot), Partite.livello(slot)],
				"Non si torna indietro: la partita %d sparisce per sempre." % slot, cancella.bind(slot)),
	]
	mostra_pagina("conferma_cancella", "CANCELLARE LA PARTITA %d?" % slot, elenco, 0, pagina_cancella)


func cancella(slot: int) -> void:
	GameState.elimina_slot(slot)
	pannello.aggiorna()
	if Partite.occupate().is_empty():
		pagina_principale()
	else:
		pagina_carica()


func pagina_collezioni(fuoco := "") -> void:
	var elenco: Array[Dictionary] = [
		voce("ALBUM DELLE CARTE", "Le carte", "Quelle che hai raccolto, e i posti vuoti di quelle che mancano.",
				vai_a_collezione.bind(SCENA_ALBUM, "ALBUM DELLE CARTE")),
		voce("BESTIARIO", "Le creature", "Tutto quello che sai di chi hai incontrato, e di chi hai studiato.",
				vai_a_collezione.bind(SCENA_BESTIARIO, "BESTIARIO")),
		voce("OGGETTI", "Gli oggetti", "Ogni oggetto che ti è passato fra le mani, e cosa fa davvero.",
				vai_a_collezione.bind(SCENA_COMPENDIO, "OGGETTI")),
	]
	mostra_pagina("collezioni", "COLLEZIONI", elenco, indice_di(elenco, fuoco),
			pagina_principale.bind("COLLEZIONI"))


func vai_a_collezione(scena: String, da_voce: String) -> void:
	# la collezione e' una schermata a parte (e' lunga, scorre): uscendo ci si
	# segna da dove, e il suo «Indietro» riporta qui, su questa voce
	ritorno = {"pagina": "collezioni", "fuoco": da_voce}
	Transizioni.vai(scena)


func pagina_come_si_gioca() -> void:
	# I CONSIGLI SONO LE DESCRIZIONI. Ogni voce e' un argomento, e la
	# spiegazione e' la descrizione in basso: passandoci sopra si legge, e
	# premendo la descrizione si fa avanti. Non serve un'altra schermata
	var leggi := func() -> void: descrizione.sottolinea()
	var elenco: Array[Dictionary] = [
		voce("IL MENU DI PAUSA", "ESC, in qualunque momento",
				"Storico dei dialoghi, Diario, zaino, squadra e opzioni. Il gioco si ferma finché non riprendi.", leggi),
		voce("SI SALVA ALLA SEDE", "Da solo, ogni volta che rientri",
				"Dentro una zona no: se esci dal gioco a metà, quello che hai fatto lì dentro va perso.", leggi),
		voce("LO SCONTRO", "Non ti aspetta",
				"Il nemico agisce mentre tu scegli. Quando la linea dell'ECG diventa rossa sei sotto un quarto della vita.", leggi),
		voce("LE COLLISIONI", "Clicca quando il cerchio si chiude",
				"In pieno il pugno non ti fa niente, di striscio ti fa metà. Invio para il pugno più vicino.", leggi),
	]
	mostra_pagina("come_si_gioca", "COME SI GIOCA", elenco, 0, pagina_principale.bind("COME SI GIOCA"))


# --- opzioni ed extra: pagine di questo menu, non schermate a parte ----------------
#
# ERANO DUE SCENE, e in tutte e due tornare indietro era un problema: nelle
# Opzioni il bottone stava contro il bordo in basso, e bastava un carattere un
# po' piu' alto (o «testo piu' grande») per mandarlo fuori dallo schermo; ESC non
# faceva niente; e «Indietro» ti rimetteva in cima al menu. Come pagine di
# questo menu hanno lo stesso indietro di tutto il resto: ESC, o «ESC Indietro»
# in basso a destra, e si torna sulla voce da cui si era partiti.

func pagina_opzioni(fuoco := "") -> void:
	# LE OPZIONI SONO UN PASSO COME GLI ALTRI, e ogni sezione e' un passo suo,
	# come nel riferimento di Bru. Tutte insieme non ci stavano: a testo normale
	# l'ultima finiva sotto la descrizione e ci si arrivava solo scorrendo
	var elenco: Array[Dictionary] = []
	for quale: String in PannelloOpzioni.SEZIONI:
		var detto: Array = PannelloOpzioni.SEZIONI[quale]
		elenco.append(voce(quale.to_upper(), String(detto[0]), String(detto[1]),
				pagina_opzioni_di.bind(quale)))
	mostra_pagina("opzioni", "OPZIONI", elenco, indice_di(elenco, fuoco), pagina_principale.bind("OPZIONI"))


func pagina_opzioni_di(quale: String) -> void:
	# le righe di una sezione, sotto la testata che ne dice il nome. La colonna
	# arriva fino al pannello delle partite con le ancore, non con una misura:
	# se «testo piu' grande» si accende da qui, si stringe da sola
	var margine := MarginContainer.new()
	margine.add_theme_constant_override("margin_left", VoceMenu.SPAZIO_SEGNO)
	var dentro := VBoxContainer.new()
	dentro.add_theme_constant_override("separation", 10)
	margine.add_child(dentro)
	PannelloOpzioni.costruisci_sezione(dentro, quale, 220, Stile.colore("menu_chiaro"), false)
	var nessuna: Array[Dictionary] = []
	mostra_pagina("opzioni " + quale, quale.to_upper(), nessuna, 0, pagina_opzioni.bind(quale.to_upper()), margine)
	colonna.anchor_right = X_FINE_PANNELLO
	colonna.offset_right = -(PannelloPartite.LARGO + SPAZIO_DAL_PANNELLO)
	descrizione.mostra("Valgono anche in gioco", "Le ritrovi nel menu di pausa (ESC), e si salvano da sole.")
	for figlio in dentro.find_children("*", "Control", true, false):
		if (figlio as Control).focus_mode != Control.FOCUS_NONE:
			(figlio as Control).grab_focus()
			break


func pagina_extra(fuoco := "") -> void:
	var leggi := func() -> void: descrizione.sottolinea()
	var elenco: Array[Dictionary] = [
		voce("CARICA UN CODICE", "Un regalo per chi ha il codice",
				"Alcuni codici della demo sbloccano qualcosa. Si scrive nella pagina dopo.", pagina_codice),
		voce("RINGRAZIAMENTI", "Grazie", RINGRAZIAMENTI, leggi),
		voce("INSTAGRAM", "Seguici", INSTAGRAM, leggi),
		voce("IL SITO", "Il sito", SITO, leggi),
	]
	mostra_pagina("extra", "EXTRA", elenco, indice_di(elenco, fuoco), pagina_principale.bind("EXTRA"))


func pagina_codice() -> void:
	campo_codice = campo("", "IL CODICE")
	var elenco: Array[Dictionary] = [
		voce("CONFERMA", "Riscatta il codice", "Scrivilo qui sopra e premi Invio.", riscatta),
	]
	mostra_pagina("codice", "CARICA UN CODICE", elenco, 0, pagina_extra.bind("CARICA UN CODICE"), campo_codice)
	campo_codice.text_submitted.connect(func(_testo: String) -> void: riscatta())
	campo_codice.grab_focus()


func riscatta() -> void:
	# l'esito si legge nella descrizione, dove si legge tutto il resto
	var risultato := GameState.riscatta_codice(campo_codice.text)
	if not bool(risultato.get("trovato", false)):
		descrizione.mostra("Codice non riconosciuto", "Controlla di averlo scritto giusto, e riprova.")
		if not voci.is_empty():
			voci[0].rifiuta()
	elif bool(risultato.get("gia_riscattato", false)):
		descrizione.mostra("Già riscattato", "Questo codice l'hai già usato in precedenza.")
	else:
		descrizione.mostra("Codice riscattato", String(risultato.get("testo", "Fatto.")))

