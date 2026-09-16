extends CanvasLayer

# Autoload: il menu di pausa, disponibile ovunque con ESC (azione "ui_cancel").
#
# Perche' un autoload e non una scena: da dentro uno squarcio non si puo'
# cambiare scena per aprire un menu — la schermata eventi verrebbe distrutta e
# rientrarci rifarebbe partire il nodo corrente (con i suoi agguati). Qui
# invece e' tutto un velo sopra la scena viva, che non tocca niente di quello
# che c'e' sotto.
#
# Un pannello alla volta, mai due cose insieme:
#   menu          -> Riprendi / Storico / Diario / Personaggio / Inventario /
#                    Opzioni / Esci
#   storico       -> i messaggi gia' letti (GameState.storico), dal piu' recente
#   diario        -> chi sei diventato. NON e' piu' un muro solo: ha un indice a
#                    sinistra e una sezione alla volta a destra (vedi sotto)
#   inventario    -> lo zaino, uno scomparto alla volta, con la sua capienza
#   equipaggiamento -> la scheda del personaggio (scripts/Personaggio.gd)
#
# In ogni pannello, in alto a destra: Tazo e livello. Sempre, senza doverli
# andare a cercare - sono le due cose che si guardano piu' spesso, e le disegna
# intestazione(), cosi' nessun pannello puo' dimenticarsele.
#
# Mentre e' aperto l'albero e' in pausa (get_tree().paused): i tween si
# fermano, i timer del combattimento si fermano, niente va avanti alle spalle
# del giocatore. Questo nodo e AudioManager restano in PROCESS_MODE_ALWAYS,
# altrimenti si metterebbe in pausa anche la musica e il menu stesso.

const LIVELLO := 100
# schermate dove la pausa non ha senso (o dove ESC ha gia' un suo significato)
const SCENE_ESCLUSE := [
	"res://scenes/Splash.tscn",
	"res://scenes/Menu.tscn",
	"res://scenes/Opzioni.tscn",
	"res://scenes/Extra.tscn",
]
const SCENA_MENU := "res://scenes/Menu.tscn"
# Di quanto si rimpicciolisce l'istantanea prima di rimetterla a schermo: a un
# decimo i contorni sono andati e la scena si riconosce ancora. Piu' in basso e'
# una macchia, piu' in alto non e' sfocata, e' solo sporca.
const RIDUZIONE_SFOCATURA := 10
const QUANTO_OCCUPA_CHI_GIOCHI := 560   # quanta larghezza si prende il tuo personaggio, a destra

# Le sezioni del Diario, in ordine. Prima erano impilate tutte in un unico
# scorrevole: sette titoli uno sotto l'altro, e per arrivare all'ultimo si
# rotolava per due schermate. Adesso una alla volta, con l'indice a sinistra.
const SEZIONI_DIARIO := [
	["appunti", "Appunti"],
	["messaggi", "Messaggi"],
	["stato", "Stato"],
	["crescita", "Cosa ti sta cambiando"],
	["passive", "Abilità passive"],
	["squadra", "Squadra"],
	["osservazioni", "Osservazioni"],
	["organizzazione", "Organizzazione"],
]

# Gli scomparti dello zaino: gli stessi di GameState (contenuto_zaino), piu' i
# collezionabili, che non sono zaino ma nemmeno vanno persi di vista.
const SCOMPARTI := [
	["consumabili", "Consumabili"],
	["armi", "Armi"],
	["accessori", "Accessori"],
	["speciali", "Oggetti speciali"],
	["collezionabili", "Ricordi e chiavi"],
]

var velo: ColorRect
var sfocato: TextureRect        # l'istantanea sfocata della scena rimasta sotto
var chi_giochi: TextureRect     # il tuo personaggio, grande a destra, a fuoco
var contenitore: MarginContainer
var colonna: VBoxContainer
var aperta := false
var pannello := "menu"  # menu | storico | diario | inventario | equipaggiamento | opzioni | uscita
var sezione_diario := "appunti"
var scomparto_aperto := "consumabili"
# Aperta da una stanza della Sede (Alloggi, Archivio) invece che con ESC: allora
# "Indietro" deve CHIUDERE e riportare alla Sede, non aprire il menu di pausa.
# Senza questa riga succedeva davvero: cliccavi Alloggi, tornavi indietro, e ti
# ritrovavi in pausa in mezzo alla Sede senza aver premuto ESC.
var modo_diretto := false

func _ready() -> void:
	layer = LIVELLO
	process_mode = Node.PROCESS_MODE_ALWAYS
	AudioManager.process_mode = Node.PROCESS_MODE_ALWAYS  # la musica non si interrompe in pausa
	# LA SCENA RESTA DIETRO, SFOCATA. Nel disegno di Bru il menu non cancella il
	# gioco: Veronica e' ancora li' dov'era, fuori fuoco, e davanti c'e' il
	# personaggio che stai giocando. Vuol dire "ti sei fermato un attimo", non
	# "sei uscito" - che e' quello che diceva il velo nero di prima.
	sfocato = TextureRect.new()
	sfocato.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sfocato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sfocato.stretch_mode = TextureRect.STRETCH_SCALE
	sfocato.visible = false
	add_child(sfocato)
	velo = ColorRect.new()
	# appena scuro: la sfocatura fa gia' tutto il lavoro di mandare indietro la
	# scena, e un velo pesante sopra la cancellerebbe di nuovo - rendendo inutile
	# averla sfocata invece che coperta
	velo.color = Color(0, 0, 0, 0.42)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.visible = false
	add_child(velo)
	contenitore = MarginContainer.new()
	contenitore.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	contenitore.add_theme_constant_override("margin_left", 90)
	contenitore.add_theme_constant_override("margin_right", 90)
	contenitore.add_theme_constant_override("margin_top", 50)
	contenitore.add_theme_constant_override("margin_bottom", 50)
	velo.add_child(contenitore)

func _unhandled_input(evento: InputEvent) -> void:
	if not evento.is_action_pressed("ui_cancel"):
		return
	if aperta:
		# ESC da un sotto-pannello torna al menu, non butta fuori dalla pausa:
		# chi stava rileggendo lo storico non vuole ritrovarsi in combattimento.
		# A meno che il pannello non sia stato aperto da fuori (una stanza della
		# Sede): li' non esiste nessun menu di pausa da cui si sia passati, e
		# tornare indietro vuol dire tornare alla stanza.
		if pannello == "menu" or modo_diretto:
			chiudi()
		else:
			mostra_menu()
	elif pausabile():
		apri()
	get_viewport().set_input_as_handled()

func pausabile() -> bool:
	# niente pausa a meta' di una dissolvenza tra schermate: si riaprirebbe su
	# una scena che sta gia' sparendo
	if Transizioni.in_corso:
		return false
	var scena := get_tree().current_scene
	if scena == null:
		return false
	return scena.scene_file_path not in SCENE_ESCLUSE

# --- apertura/chiusura ---

func apri() -> void:
	aperta = true
	modo_diretto = false
	velo.visible = true
	get_tree().paused = true
	mostra_menu()
	sfoca_la_scena()

func sfoca_la_scena() -> void:
	# SFOCARE SENZA UNO SHADER, e non per virtuosismo.
	#
	# Godot senza finestra non compila i frammenti, e in questo progetto le prove
	# girano tutte cosi': uno shader qui vorrebbe dire una parte di interfaccia
	# che nessuna prova puo' attraversare. Ci siamo gia' passati con la vignetta
	# del combattimento, disegnata a poligoni per la stessa ragione.
	#
	# E comunque uno shader qui sarebbe lo strumento sbagliato: la scena sotto e'
	# FERMA - il gioco e' in pausa - quindi non c'e' niente da sfocare sessanta
	# volte al secondo. Si fa una fotografia, la si rimpicciolisce e la si
	# ringrandisce: ridurre a un decimo e tornare su e' esattamente una sfocatura,
	# costa una volta sola, e la fa la CPU senza chiedere niente a nessuno.
	if sfocato == null:
		return
	sfocato.visible = false
	# SENZA FINESTRA frame_post_draw NON ARRIVA MAI: l'attesa qui sotto resterebbe
	# appesa per sempre, e ogni apertura del menu ne lascerebbe un'altra. Qui non
	# pianta niente perche' nessuno aspetta questa funzione - ma e' la stessa
	# trappola che ha piantato un'esecuzione intera delle prove dentro Frantumi,
	# e vale la pena chiuderla in tutte e due i posti nello stesso momento.
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw   # senza, si fotografa il fotogramma prima
	if not aperta or sfocato == null or not is_instance_valid(sfocato):
		return
	var ritratto := get_viewport().get_texture()
	if ritratto == null:
		return
	var immagine := ritratto.get_image()
	# senza rendering (prove headless) non c'e' nessuna immagine da sfocare: il
	# menu resta quello che era, col suo velo, e non si rompe niente
	if immagine == null or immagine.is_empty():
		return
	var largo := maxi(immagine.get_width() / RIDUZIONE_SFOCATURA, 1)
	var alto := maxi(immagine.get_height() / RIDUZIONE_SFOCATURA, 1)
	immagine.resize(largo, alto, Image.INTERPOLATE_BILINEAR)
	sfocato.texture = ImageTexture.create_from_image(immagine)
	sfocato.visible = true

func apri_su(quale: String) -> void:
	# Aprire direttamente un pannello, senza passare dal menu di pausa. Serve
	# alla Sede: "Alloggi" e "Archivio" sono stanze di un posto, non voci di un
	# menu, e devono portare dritto dove dicono. Il pannello vive qui perche' e'
	# un velo sopra la scena viva: si chiude e si torna esattamente dov'eri.
	#
	# modo_diretto e' quello che fa la differenza a tornare indietro: da qui si
	# esce alla stanza, non al menu di pausa (che non si e' mai aperto).
	aperta = true
	modo_diretto = true
	velo.visible = true
	get_tree().paused = true
	match quale:
		"diario": mostra_diario()
		"equipaggiamento": mostra_equipaggiamento()
		"inventario": mostra_inventario()
		"storico": mostra_storico()
		_:
			modo_diretto = false
			mostra_menu()

func indietro() -> Callable:
	# dove porta "Indietro" da un sotto-pannello: al menu di pausa se ci si e'
	# arrivati da li', fuori del tutto se il pannello e' stato aperto da una
	# stanza. Una funzione sola, cosi' non c'e' un pannello che se lo ricorda e
	# uno che se lo dimentica
	return chiudi if modo_diretto else mostra_menu

func chiudi() -> void:
	aperta = false
	modo_diretto = false
	velo.visible = false
	if sfocato != null:
		sfocato.visible = false
		sfocato.texture = null   # l'istantanea di una scena che non c'e' piu' e' solo memoria occupata
	get_tree().paused = false
	svuota()

func svuota() -> void:
	if colonna != null and is_instance_valid(colonna):
		colonna.queue_free()
	colonna = null
	# IL PERSONAGGIO GRANDE VALE SOLO PER IL MENU. Non e' un fondale della
	# pausa: nel Diario, nello Zaino e nell'equipaggiamento quello spazio serve
	# tutto, e una figura alta due terzi di schermo dietro un elenco di oggetti
	# non e' un'atmosfera, e' un elenco che non si legge. Vive e muore col
	# pannello che l'ha voluto.
	if chi_giochi != null and is_instance_valid(chi_giochi):
		chi_giochi.queue_free()
	chi_giochi = null

func nuova_colonna() -> VBoxContainer:
	svuota()
	colonna = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 14)
	contenitore.add_child(colonna)
	return colonna

func intestazione(testo: String) -> void:
	# Titolo a sinistra, Tazo e livello a destra. Sempre: sono le due cose che si
	# guardano piu' spesso, e finche' erano sepolte dentro una sezione del Diario
	# bisognava navigare per sapere quanti soldi si avevano. Stanno qui dentro e
	# non in ogni pannello proprio perche' nessuno se le possa dimenticare.
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 20)
	colonna.add_child(riga)
	var titolo := Label.new()
	titolo.text = testo
	titolo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titolo.add_theme_font_size_override("font_size", Stile.dimensione("sezione"))
	titolo.add_theme_color_override("font_color", Stile.colore("accento"))
	riga.add_child(titolo)
	var risorse := Label.new()
	risorse.text = "Tazo %d     Lv %d" % [
			GameState.tazo, GameState.livello_di(GameState.id_protagonista)]
	risorse.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	risorse.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	risorse.add_theme_color_override("font_color", Stile.colore("bordo_acceso"))
	riga.add_child(risorse)

func bottone(testo: String, richiamo: Callable) -> Button:
	var b := Button.new()
	b.text = testo
	Stile.scelta(b)
	b.pressed.connect(richiamo)
	colonna.add_child(b)
	return b

# --- pannello: menu ---

func mostra_menu() -> void:
	nuova_colonna()
	pannello = "menu"
	intestazione("Pausa")
	var primo := bottone("Riprendi", chiudi)
	bottone("Storico dei dialoghi", mostra_storico)
	bottone(GameState.nome_diario(), mostra_diario)
	bottone("Personaggio e squadra", mostra_equipaggiamento)
	bottone("Zaino", mostra_inventario)
	bottone("Opzioni", mostra_opzioni)
	bottone("Torna al menu principale", conferma_uscita)
	# LE VOCI STANNO A SINISTRA, IN ROSSO. E' cosi' nel disegno, e non e' un
	# capriccio: le scelte di un dialogo stanno a destra, e se anche il menu
	# stesse a destra e in bianco per un istante sarebbero la stessa cosa. Da
	# che parte dello schermo guardi ti dice gia' se stai giocando o ti sei
	# fermato.
	allinea_a_sinistra(colonna)
	mostra_chi_giochi()
	primo.grab_focus()

func allinea_a_sinistra(quale: VBoxContainer) -> void:
	for figlio in quale.get_children():
		if figlio is Button:
			var b: Button = figlio
			b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			for stato in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
				b.add_theme_color_override(stato, Stile.colore("accento"))

func mostra_chi_giochi() -> void:
	# IL TUO PERSONAGGIO, GRANDE A DESTRA, A FUOCO. E' l'unica cosa nitida in
	# tutta la schermata: la scena e' sfocata dietro, e lui no. E' anche a cosa
	# serve l'iconcina in alto a sinistra - quella e' la sua faccia in piccolo, e
	# il menu e' dove diventa grande.
	if chi_giochi != null and is_instance_valid(chi_giochi):
		chi_giochi.queue_free()
	var percorso := ritratto_del_protagonista()
	if percorso == "":
		return
	chi_giochi = TextureRect.new()
	chi_giochi.texture = load(percorso)
	chi_giochi.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chi_giochi.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chi_giochi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chi_giochi.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	chi_giochi.offset_left = -QUANTO_OCCUPA_CHI_GIOCHI
	chi_giochi.offset_top = 40
	velo.add_child(chi_giochi)
	# sotto i bottoni, o coprirebbe le voci quando la finestra e' stretta
	velo.move_child(chi_giochi, 0)

func ritratto_del_protagonista() -> String:
	var id := GameState.id_protagonista
	var espressione := "res://art/personaggi/%s/neutra.png" % id
	if ResourceLoader.exists(espressione):
		return espressione
	var singolo := String(GameState.personaggi.get(id, {}).get("ritratto", ""))
	return singolo if singolo != "" and ResourceLoader.exists(singolo) else ""

# --- pannello: opzioni ---

func mostra_opzioni() -> void:
	# Le opzioni si possono guardare anche mentre giochi: alzare il volume a
	# meta' di uno scontro non e' amministrare una partita. Sono le stesse della
	# schermata principale, perche' l'elenco e' uno solo (PannelloOpzioni) - la
	# pausa non ne mostra piu' due su sei come faceva prima.
	nuova_colonna()
	pannello = "opzioni"
	intestazione("Opzioni")
	PannelloOpzioni.costruisci(colonna, 200)
	bottone("Indietro", indietro()).grab_focus()

func conferma_uscita() -> void:
	# uscire da qui butta via i progressi della zona in corso: si salva solo
	# dalla mappa stellare, quindi va detto chiaro prima di farlo
	nuova_colonna()
	pannello = "uscita"
	intestazione("Tornare al menu?")
	var avviso := Label.new()
	avviso.text = "Il gioco si salva da solo quando rientri alla Sede: tutto quello che hai\nfatto dentro questa zona (stanze, oggetti raccolti, Tazo) andrà perso."
	avviso.add_theme_color_override("font_color", Stile.colore("pericolo"))
	colonna.add_child(avviso)
	var primo := bottone("No, resto qui", mostra_menu if not modo_diretto else chiudi)
	bottone("Sì, torna al menu principale", func() -> void:
		chiudi()
		GameState.reset_campagna()
		Transizioni.vai(SCENA_MENU))
	primo.grab_focus()

# --- pannello: storico ---

func mostra_storico() -> void:
	nuova_colonna()
	pannello = "storico"
	intestazione("Storico dei dialoghi")
	var scorrevole := ScrollContainer.new()
	scorrevole.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna.add_child(scorrevole)
	var righe := VBoxContainer.new()
	righe.add_theme_constant_override("separation", 12)
	righe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.add_child(righe)
	if GameState.storico.is_empty():
		var vuoto := Label.new()
		vuoto.text = "Non hai ancora letto niente."
		Stile.etichetta_piccola(vuoto)
		righe.add_child(vuoto)
	for voce in GameState.storico:
		righe.add_child(riga_storico(voce))
	bottone("Indietro", indietro()).grab_focus()
	# si apre gia' in fondo: l'ultima cosa letta e' quella che interessa di piu'
	await get_tree().process_frame
	if is_instance_valid(scorrevole):
		scorrevole.scroll_vertical = int(scorrevole.get_v_scroll_bar().max_value)

func riga_storico(voce: Dictionary) -> Control:
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
			corpo.add_theme_color_override("default_color", Stile.colore("narrazione"))
	blocco.add_child(corpo)
	return blocco

# --- pannello: diario ---

func mostra_diario() -> void:
	# Indice a sinistra, UNA sezione alla volta a destra.
	#
	# Prima erano tutte impilate nello stesso scorrevole: sette titoli uno sotto
	# l'altro, e per arrivare alla valutazione dell'Organizzazione bisognava
	# rotolare per due schermate passando in mezzo a tutto il resto. Un diario
	# non e' un tabulato: e' un posto dove si va a cercare una cosa precisa.
	nuova_colonna()
	pannello = "diario"
	intestazione(GameState.nome_diario())
	var corpo := HBoxContainer.new()
	corpo.add_theme_constant_override("separation", 24)
	corpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna.add_child(corpo)

	var indice := VBoxContainer.new()
	indice.add_theme_constant_override("separation", 6)
	indice.custom_minimum_size = Vector2(280, 0)
	corpo.add_child(indice)
	var primo: Button = null
	for voce in SEZIONI_DIARIO:
		var chiave := String(voce[0])
		var b := Button.new()
		b.text = String(voce[1])
		# QUANTI NON NE HAI ANCORA LETTI, sull'indice. Una sezione che non dice
		# se dentro c'e' qualcosa di nuovo e' una sezione che non si apre: i 3000
		# tazo di benvenuto resterebbero una riga che nessuno va a cercare.
		if chiave == "messaggi":
			var non_letti := GameState.messaggi_non_letti()
			if non_letti > 0:
				b.text = "%s  (%d)" % [b.text, non_letti]
		Stile.scelta(b)
		if chiave == sezione_diario:
			# dove sei si vede: senza questo l'indice e' sette bottoni uguali
			b.add_theme_color_override("font_color", Stile.colore("accento"))
			b.text = "▸  " + b.text
		else:
			b.pressed.connect(func() -> void:
				sezione_diario = chiave
				mostra_diario())
			if primo == null:
				primo = b
		indice.add_child(b)

	var scorrevole := ScrollContainer.new()
	scorrevole.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.size_flags_vertical = Control.SIZE_EXPAND_FILL
	corpo.add_child(scorrevole)
	var dentro := VBoxContainer.new()
	dentro.add_theme_constant_override("separation", 10)
	dentro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.add_child(dentro)
	match sezione_diario:
		"appunti": sezione_appunti(dentro)
		"messaggi": sezione_messaggi(dentro)
		"stato": sezione_stato(dentro)
		"crescita": sezione_crescita(dentro)
		"passive": sezione_passive(dentro)
		"squadra": sezione_squadra(dentro)
		"osservazioni": sezione_osservazioni(dentro)
		"organizzazione": sezione_organizzazione(dentro)
	bottone("Indietro", indietro()).grab_focus()

# --- pannello: inventario ---

func mostra_inventario() -> void:
	# Lo zaino, uno scomparto alla volta. Mancava del tutto dal menu di pausa:
	# per sapere cosa si aveva addosso bisognava aprire la scheda di un
	# personaggio e guardare cosa si poteva equipaggiare - che e' un'altra
	# domanda. Qui si guarda e basta.
	nuova_colonna()
	pannello = "inventario"
	intestazione("Zaino")
	var corpo := HBoxContainer.new()
	corpo.add_theme_constant_override("separation", 24)
	corpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna.add_child(corpo)

	var indice := VBoxContainer.new()
	indice.add_theme_constant_override("separation", 6)
	indice.custom_minimum_size = Vector2(280, 0)
	corpo.add_child(indice)
	for voce in SCOMPARTI:
		var chiave := String(voce[0])
		var quanti := contenuto_scomparto(chiave).size()
		var b := Button.new()
		b.text = "%s  (%s)" % [String(voce[1]), capienza_testo(chiave, quanti)]
		Stile.scelta(b)
		if chiave == scomparto_aperto:
			b.add_theme_color_override("font_color", Stile.colore("accento"))
			b.text = "▸  " + b.text
		else:
			b.pressed.connect(func() -> void:
				scomparto_aperto = chiave
				mostra_inventario())
		indice.add_child(b)

	var scorrevole := ScrollContainer.new()
	scorrevole.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.size_flags_vertical = Control.SIZE_EXPAND_FILL
	corpo.add_child(scorrevole)
	var dentro := VBoxContainer.new()
	dentro.add_theme_constant_override("separation", 12)
	dentro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.add_child(dentro)
	disegna_scomparto(dentro, scomparto_aperto)
	bottone("Indietro", indietro()).grab_focus()

func contenuto_scomparto(chiave: String) -> Array:
	if chiave == "collezionabili":
		return GameState.collezionabili + GameState.chiavi
	return GameState.contenuto_zaino(chiave)

func capienza_testo(chiave: String, quanti: int) -> String:
	# gli scomparti senza tetto non devono mostrarne uno finto: gli oggetti
	# speciali sono la storia che ti porti dietro, non zavorra da amministrare
	if chiave in ["speciali", "collezionabili"]:
		return "%d" % quanti
	return "%d / %d" % [quanti, GameState.capacita_zaino(chiave)]

func disegna_scomparto(genitore: VBoxContainer, chiave: String) -> void:
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
		genitore.add_child(riga_oggetto(id_oggetto, int(conteggio[id_oggetto])))

func riga_oggetto(id_oggetto: String, quanti: int) -> Control:
	var dati := GameState.dati_oggetto(id_oggetto)
	var blocco := VBoxContainer.new()
	blocco.add_theme_constant_override("separation", 2)
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 10)
	blocco.add_child(riga)
	var nome := Label.new()
	nome.text = String(dati.get("nome", id_oggetto))
	if quanti > 1:
		nome.text += "  ×%d" % quanti
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nome.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	riga.add_child(nome)
	# un'arma equipaggiata resta nello zaino, segnata: e' una regola dello zaino,
	# e qui e' l'unico posto dove si vede
	var portatore := GameState.portatore_di(id_oggetto)
	if portatore != "":
		var uso := Label.new()
		uso.text = "in uso — %s" % nome_di_classe(portatore)
		uso.add_theme_color_override("font_color", Stile.colore("bordo_acceso"))
		uso.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
		riga.add_child(uso)
	var effetto := riassunto_effetto(dati)
	var descrizione := String(dati.get("descrizione", ""))
	var sotto := Label.new()
	sotto.text = descrizione if descrizione != "" else effetto
	if descrizione != "" and effetto != "" and effetto != "nessun effetto":
		sotto.text = "%s  —  %s" % [descrizione, effetto]
	sotto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Stile.etichetta_piccola(sotto)
	blocco.add_child(sotto)
	return blocco

func nome_di_classe(id_classe: String) -> String:
	var definizione: Dictionary = GameState.classi.get(id_classe, {})
	if not definizione.is_empty():
		return String(definizione.get("nome", id_classe))
	return String(GameState.personaggi.get(id_classe, {}).get("nome", id_classe))

func sezione_messaggi(genitore: VBoxContainer) -> void:
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

func sezione_appunti(genitore: VBoxContainer) -> void:
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

func riga_appunto(voce: Dictionary) -> Control:
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
	corpo.text = "[i]%s[/i]" % String(voce.get("testo", ""))
	corpo.add_theme_color_override("default_color", Stile.colore("narrazione"))
	corpo.add_theme_font_size_override("normal_font_size", Stile.dimensione("piccolo"))
	corpo.add_theme_font_size_override("italics_font_size", Stile.dimensione("piccolo"))
	blocco.add_child(corpo)
	return blocco

# --- pannello: equipaggiamento ---
#
# Gli slot non sono numeri, sono ruoli diversi: un'arma decide come colpisci,
# uno stigma e' un patto (da' e toglie), i quattro accessori sono i piccoli
# aggiustamenti, l'ultima risorsa e' la rete che scatta quando stai per cadere.
# Ogni personaggio ha i suoi, e quello che porta vale solo per lui.

const NOMI_SLOT := {
	"arma": "Arma",
	"stigma": "Stigma",
	"accessori": "Accessori",
	"ultima_risorsa": "Ultima risorsa",
}

func mostra_equipaggiamento() -> void:
	# La scheda del personaggio: chi e', cosa porta addosso, quanto vale, e la
	# stessa cosa per ogni compagno. Vive qui dentro invece che come schermata a
	# se' perche' cosi' si apre da ovunque - mappa, stanza, Vuoto, combattimento -
	# senza cambiare scena e senza perdere il posto in cui si era.
	# Come e' fatta e perche': vedi scripts/Personaggio.gd.
	nuova_colonna()
	pannello = "equipaggiamento"
	var scheda := SchedaPersonaggio.new()
	colonna.add_child(scheda)
	scheda.apri(indietro(), mostra_diario)

func etichetta_bonus(chiave: String) -> String:
	match chiave:
		"attacco": return "attacco"
		"difesa": return "difesa"
		"velocita": return "velocità"
		"hp_max": return "vita massima"
		"aura_max": return "aura massima"
		"aura_per_turno": return "aura per turno"
		"resistenza_maledizione": return "rintocchi di maledizione"
		_: return chiave

func oggetti_per(slot: String) -> Array[String]:
	# cosa si puo' mettere in questo slot: del tipo giusto, posseduto, e non
	# gia' addosso a qualcun altro
	var risultato: Array[String] = []
	var magazzino: Array = GameState.magazzino_per_slot(slot)
	for id_oggetto in magazzino:
		var id_stringa := String(id_oggetto)
		if id_stringa in risultato or GameState.e_equipaggiato(id_stringa):
			continue
		var tipo := String(GameState.dati_oggetto(id_stringa).get("tipo", ""))
		var atteso := "consumabile"
		if slot == "accessori":
			atteso = "accessorio"
		elif slot != "ultima_risorsa":
			atteso = slot
		if tipo == atteso:
			risultato.append(id_stringa)
	return risultato

func riassunto_effetto(dati: Dictionary) -> String:
	# cosa fa davvero, in numeri: la descrizione poetica sta nel Compendio
	var effetto: Dictionary = dati.get("effetto_equipaggiato", dati.get("effetto", {}))
	var voci: Array[String] = []
	for chiave in effetto:
		var nome_chiave := String(chiave)
		match nome_chiave:
			"tipo":
				continue
			"cura_stato":
				var definizione: Dictionary = GameState.stati.get(effetto[chiave], {})
				voci.append("toglie " + String(definizione.get("nome", effetto[chiave])).to_lower())
			"cura_stati":
				voci.append("toglie ogni male")
			"hp":
				voci.append("+%d vita" % int(effetto[chiave]))
			"aura":
				voci.append("+%d aura" % int(effetto[chiave]))
			"danno":
				voci.append("%d danni al nemico" % int(effetto[chiave]))
			_:
				voci.append("%s %+d" % [etichetta_bonus(nome_chiave), int(effetto[chiave])])
	if String(effetto.get("tipo", "")) == "scudo_primo_stato":
		voci.append("respinge il primo male che ti prende")
	if String(effetto.get("tipo", "")) == "resurrezione_dimezzata":
		voci.append("ti rimette in piedi una volta")
	return ", ".join(voci) if not voci.is_empty() else "nessun effetto"

func titolo_sezione(genitore: VBoxContainer, testo: String) -> void:
	var t := Label.new()
	t.text = testo
	t.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	t.add_theme_color_override("font_color", Stile.colore("accento"))
	genitore.add_child(t)

func voce_diario(genitore: VBoxContainer, etichetta: String, valore: String) -> void:
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

func sezione_stato(genitore: VBoxContainer) -> void:
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

func sezione_crescita(genitore: VBoxContainer) -> void:
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

func etichetta_azione(nome_azione: String) -> String:
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

func sezione_passive(genitore: VBoxContainer) -> void:
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

func sezione_squadra(genitore: VBoxContainer) -> void:
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

func sezione_osservazioni(genitore: VBoxContainer) -> void:
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

func sezione_organizzazione(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Organizzazione")
	voce_diario(genitore, "Fonti estinte", "%d" % GameState.fonti_estinte)
	voce_diario(genitore, "Valutazione", valutazione_organizzazione())

func valutazione_organizzazione() -> String:
	# l'Organizzazione parla per gradi, non per percentuali: e' un giudizio,
	# non una barra. Sale con le fonti estinte
	match GameState.fonti_estinte:
		0: return "In osservazione."
		1: return "Prestazione conforme alle attese."
		2: return "Rendimento soddisfacente."
		3: return "Elemento affidabile."
		_: return "Elemento di valore. Aspettative in aumento."
