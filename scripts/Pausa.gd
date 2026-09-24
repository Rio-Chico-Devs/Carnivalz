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
	# le collezioni si aprono dal menu principale, fuori da una partita: li' ESC
	# vuol dire «torna indietro», non «pausa» (che aprirebbe un menu di pausa su
	# una partita che non c'e')
	"res://scenes/Album.tscn",
	"res://scenes/Bestiario.tscn",
	"res://scenes/Compendio.tscn",
]
const SCENA_MENU := "res://scenes/Menu.tscn"
# Di quanto si rimpicciolisce l'istantanea prima di rimetterla a schermo: a un
# decimo i contorni sono andati e la scena si riconosce ancora. Piu' in basso e'
# una macchia, piu' in alto non e' sfocata, e' solo sporca.
const RIDUZIONE_SFOCATURA := 10
const STACCO := 1.0         # l'aria IN PIU' fra un blocco di voci e il prossimo:
                            # il contenitore ci mette gia' la sua spaziatura ai due
                            # lati, quindi qui bastano pochi pixel
const STACCO_TESTATA := 8.0
const MARGINE_DAL_FONDO := 12.0   # la colonna si ferma prima del bordo, non sul bordo
const SPAZIATURA_MINIMA := 2
const MARGINE_STRETTO := 2
const QUANTO_OCCUPA_CHI_GIOCHI := 560   # quanta larghezza si prende il tuo personaggio, a destra
# QUANTO SCHERMO COPRE IL FOGLIO NERO delle quinte. Nel menu meno della meta':
# a destra resta il mondo sfocato, e il tuo personaggio. Negli altri pannelli
# tutto, e oltre - il bordo obliquo esce dallo schermo - perche' li' lo spazio
# serve al contenuto (vedi Quinte.gd)
const COPRE_MENU := 0.5
const COPRE_PANNELLO := 1.25
# l'intestazione entra prima delle voci: il titolo, poi il cartellino, poi la
# cascata. E' l'ordine di Carbon: prima il guscio, poi il contenuto, per
# ultima l'azione principale
const TITOLO_DOPO := 0.04
const CARTELLINO_DOPO := 0.08
const CASCATA_DOPO := 0.10

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
var palco: Control              # dove stanno le colonne: un Control semplice, non un contenitore (vedi nuova_colonna)
var colonna: VBoxContainer
var quinte: Quinte              # i fogli dietro le voci, e la parola grande
var schegge: Schegge            # i ritagli che saltano via da una voce premuta
var dissolvenza: Tween          # l'entrata o l'uscita del velo: una sola alla volta
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
	# NIENTE CHE STA SOTTO LE VOCI PRENDE CLIC: a chiuderli fuori dal gioco
	# mentre sei in pausa ci pensa il velo, e il velo smette nell'istante in cui
	# chiudi. Il contenitore e l'istantanea sfocata invece, lasciati come nascono
	# (i contenitori e le TextureRect lasciano passare), durante i 150 ms della
	# dissolvenza si prendevano il primo clic dato al gioco - proprio quello
	# che «chiudi» prometteva di non rubare. L'ha trovato l'automa
	sfocato.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	contenitore.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenitore.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	contenitore.add_theme_constant_override("margin_left", 90)
	contenitore.add_theme_constant_override("margin_right", 90)
	contenitore.add_theme_constant_override("margin_top", 50)
	contenitore.add_theme_constant_override("margin_bottom", 50)
	quinte = Quinte.new()
	quinte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.add_child(quinte)
	velo.add_child(contenitore)
	palco = Control.new()
	palco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenitore.add_child(palco)
	# le schegge sopra tutto: devono volare anche sopra il pannello che la voce
	# premuta ha appena aperto
	schegge = Schegge.new()
	schegge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schegge)

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
	mostra_velo(COPRE_MENU)
	get_tree().paused = true
	mostra_menu()
	sfoca_la_scena()

func mostra_velo(copre: float) -> void:
	# IL VELO ENTRA IN FRETTA E LE QUINTE GLI CORRONO DIETRO. Il velo e la
	# sfocatura sono il guscio (Carbon: «static shell» per primo): 110 ms, il
	# tempo di un tocco. Il gioco si ferma subito, non quando il menu ha finito
	# di entrare - l'animazione non tiene fermo niente
	if dissolvenza != null:
		dissolvenza.kill()
	# nascosto, oppure a meta' dell'uscita (ESC premuto due volte di fila): in
	# tutti e due i casi le quinte devono rientrare da capo
	var era_nascosto := not velo.visible or quinte.uscendo
	velo.visible = true
	velo.mouse_filter = Control.MOUSE_FILTER_STOP
	if era_nascosto:
		Movimento.suona("apertura")
		quinte.entra(copre, "")
		velo.modulate.a = 0.0
		sfocato.modulate.a = 0.0
	dissolvenza = create_tween().set_parallel()
	Movimento.verso(dissolvenza, velo, "modulate:a", 1.0, "entrata", Movimento.durata("sfioro"))
	Movimento.verso(dissolvenza, sfocato, "modulate:a", 1.0, "entrata", Movimento.durata("sfioro"))

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
	var largo := maxi(floori(float(immagine.get_width()) / RIDUZIONE_SFOCATURA), 1)
	var alto := maxi(floori(float(immagine.get_height()) / RIDUZIONE_SFOCATURA), 1)
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
	mostra_velo(COPRE_PANNELLO)
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
	# IL GIOCO RIPARTE SUBITO, il menu se ne va dopo. Per 150 ms le quinte
	# escono e il velo si dissolve mentre sotto si gioca gia': il velo smette di
	# prendere i clic nell'istante in cui chiudi, quindi uscire non costa niente
	# - e' l'uscita piu' breve dell'entrata, come dice Material
	aperta = false
	modo_diretto = false
	get_tree().paused = false
	Movimento.suona("chiusura")
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quinte.esci()
	svuota()
	if dissolvenza != null:
		dissolvenza.kill()
	dissolvenza = create_tween().set_parallel()
	Movimento.verso(dissolvenza, velo, "modulate:a", 0.0, "uscita", Movimento.durata("uscita"))
	Movimento.verso(dissolvenza, sfocato, "modulate:a", 0.0, "uscita", Movimento.durata("uscita"))
	dissolvenza.chain().tween_callback(sparisci)

func sparisci() -> void:
	velo.visible = false
	sfocato.visible = false
	sfocato.texture = null   # l'istantanea di una scena che non c'e' piu' e' solo memoria occupata

func svuota() -> void:
	# IL PANNELLO VECCHIO NON SPARISCE DI COLPO, SI DISSOLVE - ma nell'istante
	# in cui lo lasci non risponde piu' a niente: niente clic, niente fuoco.
	# Per una frazione di secondo si vede ancora, e non si tocca gia' piu'
	Movimento.congeda(colonna, Movimento.durata("entrata") * Movimento.SOGLIA_CAMBIO)
	colonna = null
	# IL PERSONAGGIO GRANDE VALE SOLO PER IL MENU. Non e' un fondale della
	# pausa: nel Diario, nello Zaino e nell'equipaggiamento quello spazio serve
	# tutto, e una figura alta due terzi di schermo dietro un elenco di oggetti
	# non e' un'atmosfera, e' un elenco che non si legge. Vive e muore col
	# pannello che l'ha voluto.
	Movimento.congeda(chi_giochi, Movimento.durata("uscita"))
	chi_giochi = null

func nuova_colonna(entra := true) -> VBoxContainer:
	# LA COLONNA STA SUL PALCO, NON DENTRO IL CONTENITORE. Un contenitore di
	# Godot, a ogni riordino, rimette a posto la posizione dei figli e anche la
	# loro scala (Container::fit_child_in_rect): una colonna che scivola dentro
	# verrebbe rimessa al suo posto a meta' strada. Il palco e' un Control
	# semplice, e la colonna ci sta appesa con le ancore - che rispettano uno
	# spostamento invece di cancellarlo.
	svuota()
	colonna = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 14)
	palco.add_child(colonna)
	colonna.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if entra:
		Movimento.entra_pannello(colonna)
	# a pannello finito: chi chiama la riempie adesso, e la misura vera c'e'
	# solo dopo. Differita vuol dire prima del disegno, quindi non si vede
	stringi_se_serve.call_deferred(colonna)
	return colonna

func stringi_se_serve(quale: VBoxContainer) -> void:
	# LA COLONNA NON ESCE DI SOTTO. Con «testo piu' grande» tutto cresce del
	# 25% e lo schermo utile scende a 576 pixel: il menu perdeva «Opzioni» e
	# «Torna al menu principale» - cioe' proprio il posto dove il testo grande
	# si spegne - e il Diario le sue ultime sezioni e «Indietro». Anche a scala
	# normale l'ultima voce sporgeva di cinque pixel. Si stringe l'aria, non le
	# lettere: prima quanto basta della spaziatura fra le voci, poi, se non
	# basta ancora, il margine dentro ogni voce. Trovato dalla sonda dei bordi.
	if quale != colonna or not is_instance_valid(quale):
		return
	var posto := get_viewport().get_visible_rect().size.y - palco.get_global_rect().position.y - MARGINE_DAL_FONDO
	var troppo := quale.get_combined_minimum_size().y - posto
	if troppo <= 0.0:
		return
	var spazi := maxi(quale.get_child_count() - 1, 1)
	var passo := quale.get_theme_constant("separation")
	var nuovo := maxi(passo - ceili(troppo / spazi), SPAZIATURA_MINIMA)
	quale.add_theme_constant_override("separation", nuovo)
	if troppo - (passo - nuovo) * spazi <= 0.0:
		return
	for riga in quale.find_children("*", "VoceMenu", true, false):
		(riga as VoceMenu).stringi(MARGINE_STRETTO)

func intestazione(testo: String) -> void:
	# Titolo a sinistra, Tazo e livello a destra. Sempre: sono le due cose che si
	# guardano piu' spesso, e finche' erano sepolte dentro una sezione del Diario
	# bisognava navigare per sapere quanti soldi si avevano. Stanno qui dentro e
	# non in ogni pannello proprio perche' nessuno se le possa dimenticare.
	#
	# Sono due cartigli, fasce storte come il nastro dei nomi: il titolo e' una
	# fascia cremisi con la scritta bianca, il cartellino una fascia bianca con
	# la scritta nera - il box del dialogo in piccolo. Entrano srotolandosi, il
	# titolo per primo.
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 24)
	colonna.add_child(riga)
	var titolo := Cartiglio.nuovo(testo.to_upper(), Stile.colore("accento"),
			Stile.colore("testo"), Stile.colore("bordo_acceso"), Stile.dimensione("titolo"))
	titolo.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_BEGIN
	riga.add_child(titolo)
	var risorse := Cartiglio.nuovo("TAZO %d   ·   LV %d" % [GameState.tazo,
			GameState.livello_di(GameState.id_protagonista)], Stile.colore("bordo_acceso"),
			Stile.colore("box_testo"), Stile.colore("accento"), Stile.dimensione("corpo"))
	risorse.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	riga.add_child(risorse)
	titolo.svela(TITOLO_DOPO)
	risorse.svela(CARTELLINO_DOPO)
	# un po' d'aria sotto: la prima lastra e' storta, e senza toccherebbe la
	# sfoglia del titolo
	var aria := Control.new()
	aria.custom_minimum_size = Vector2(0.0, STACCO_TESTATA)
	aria.mouse_filter = Control.MOUSE_FILTER_IGNORE
	colonna.add_child(aria)
	# col testo grande le voci sono piu' larghe del 25%, e il foglio le deve
	# coprire lo stesso: altrimenti «Torna al menu principale» finisce sulla
	# striscia rossa. Si allarga della stessa scala
	var scala := get_tree().root.content_scale_factor
	quinte.copri(COPRE_MENU * scala if pannello == "menu" else COPRE_PANNELLO, testo.to_upper())

# --- pannello: menu ---

func mostra_menu() -> void:
	# SETTE VOCI PIATTE NON SONO UN MENU, SONO UN ELENCO. PLAY, euristica G1:
	# «Navigation is consistent, logical and minimalist». Adesso sono tre
	# blocchi separati - quello che si consulta, quello che si amministra,
	# quello che esce - e ogni voce ha un segno accanto (F4, «Art is
	# recognizable to the player and speaks to its function»). Vedi docs/menu.md.
	#
	# LE VOCI STANNO A SINISTRA, IN ROSSO. E' cosi' nel disegno, e non e' un
	# capriccio: le scelte di un dialogo stanno a destra, e se anche il menu
	# stesse a destra e in bianco per un istante sarebbero la stessa cosa. Da
	# che parte dello schermo guardi ti dice gia' se stai giocando o ti sei
	# fermato.
	#
	# E ENTRANO IN CASCATA, CON RIPRENDI PER ULTIMA. Sta in cima ed e' quella
	# che ha il fuoco, ma arriva dopo tutte le altre: Bru, «i pulsanti d'azione
	# principale chiudono la sequenza per guidare l'occhio del giocatore».
	# L'occhio scende con la cascata e risale dove deve cliccare.
	nuova_colonna(false)
	pannello = "menu"
	intestazione("Pausa")
	var voci: Array[VoceMenu] = []
	voci.append(voce("riprendi", "Riprendi", chiudi))
	stacco()
	voci.append(voce("storico", "Storico dei dialoghi", mostra_storico))
	voci.append(voce("diario", GameState.nome_diario(), mostra_diario))
	voci.append(voce("zaino", "Zaino", mostra_inventario))
	stacco()
	voci.append(voce("squadra", "Personaggio e squadra", mostra_equipaggiamento))
	voci.append(voce("opzioni", "Opzioni", mostra_opzioni))
	stacco()
	voci.append(voce("uscita", "Torna al menu principale", conferma_uscita))
	mostra_chi_giochi()
	cascata(voci, 0)

func voce(segno: String, testo: String, richiamo: Callable, dove: Control = null,
		corpo := 0) -> VoceMenu:
	var v := VoceMenu.nuova(segno, testo, corpo)
	# prima le schegge, poi quello che la voce fa: se apre un altro pannello,
	# questa voce sta per sparire, e le schegge devono essere gia' partite
	v.scoppio.connect(schegge.scoppia)
	v.scelta.connect(richiamo)
	(dove if dove != null else colonna).add_child(v)
	return v

func voce_d_indice(dove: Control, testo: String, attuale: bool, richiamo: Callable) -> VoceMenu:
	# UNA VOCE DELL'INDICE del Diario o dello Zaino. Quella in cui sei ha il
	# segno davanti ed e' inerte: premerla non riapre la stessa pagina, dice di no
	var v := voce("riprendi" if attuale else "", testo, richiamo, dove, Stile.dimensione("corpo"))
	v.inerte = attuale
	return v

func cascata(voci: Array[VoceMenu], principale: int) -> void:
	Movimento.cascata(voci, principale, CASCATA_DOPO)

func ritorno(col_fuoco := true) -> void:
	# «Indietro», in fondo a ogni pannello: e' una voce come le altre, con la
	# sua freccia, e ha il fuoco appena il pannello si apre - tranne dove c'e'
	# un indice, che il fuoco lo tiene sulla pagina aperta
	var v := voce("indietro", "Indietro", indietro())
	if col_fuoco:
		v.prendi_il_fuoco_in_silenzio()

func stacco() -> void:
	# lo spazio che separa un blocco dall'altro: e' la POSIZIONE a raggruppare,
	# e la posizione e' l'unica variabile che l'occhio isola a colpo d'occhio
	var vuoto := Control.new()
	vuoto.custom_minimum_size = Vector2(0.0, STACCO)
	vuoto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	colonna.add_child(vuoto)

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
	# davanti alle quinte (e' a fuoco, la parola grande sta dietro di lui) ma
	# sotto le voci, o le coprirebbe quando la finestra e' stretta
	velo.move_child(chi_giochi, quinte.get_index() + 1)
	# arriva da destra, piu' lento delle voci: e' la cosa piu' pesante a schermo
	chi_giochi.modulate.a = 0.0
	var arrivo := chi_giochi.create_tween().set_parallel()
	Movimento.verso(arrivo, chi_giochi, "modulate:a", 1.0, "entrata", Movimento.durata("quinta"))
	if not Movimento.ridotto():
		chi_giochi.position.x += 32.0
		Movimento.verso(arrivo, chi_giochi, "position:x", chi_giochi.position.x - 32.0,
				"entrata", Movimento.durata("quinta"))

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
	# dentro uno scorrevole: le opzioni sono tante, e senza «Indietro» finiva
	# sotto il bordo dello schermo
	var scorrevole := ScrollContainer.new()
	scorrevole.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scorrevole.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	colonna.add_child(scorrevole)
	var dentro := VBoxContainer.new()
	dentro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.add_child(dentro)
	PannelloOpzioni.costruisci(dentro, 200, Stile.colore("accento"))
	ritorno()

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
	var voci: Array[VoceMenu] = []
	voci.append(voce("riprendi", "No, resto qui", mostra_menu if not modo_diretto else chiudi))
	voci.append(voce("uscita", "Sì, torna al menu principale", func() -> void:
		chiudi()
		GameState.reset_campagna()
		Transizioni.vai(SCENA_MENU)))
	# la scelta sicura e' quella principale: ha il fuoco, e chiude la sequenza
	cascata(voci, 0)

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
	for letta in GameState.storico:
		righe.add_child(PaginePausa.riga_storico(letta))
	ritorno()
	# si apre gia' in fondo: l'ultima cosa letta e' quella che interessa di piu'
	await get_tree().process_frame
	if is_instance_valid(scorrevole):
		scorrevole.scroll_vertical = int(scorrevole.get_v_scroll_bar().max_value)

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
	indice.add_theme_constant_override("separation", 0)
	indice.custom_minimum_size = Vector2(280, 0)
	corpo.add_child(indice)
	var voci: Array[VoceMenu] = []
	var qui := 0
	for sezione in SEZIONI_DIARIO:
		var chiave := String(sezione[0])
		var testo := String(sezione[1])
		# QUANTI NON NE HAI ANCORA LETTI, sull'indice. Una sezione che non dice
		# se dentro c'e' qualcosa di nuovo e' una sezione che non si apre: i 3000
		# tazo di benvenuto resterebbero una riga che nessuno va a cercare.
		if chiave == "messaggi" and GameState.messaggi_non_letti() > 0:
			testo = "%s  (%d)" % [testo, GameState.messaggi_non_letti()]
		# dove sei si vede: senza il segno l'indice e' sette voci uguali
		if chiave == sezione_diario:
			qui = voci.size()
		voci.append(voce_d_indice(indice, testo, chiave == sezione_diario, func() -> void:
			sezione_diario = chiave
			mostra_diario()))

	var scorrevole := ScrollContainer.new()
	scorrevole.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.size_flags_vertical = Control.SIZE_EXPAND_FILL
	corpo.add_child(scorrevole)
	var dentro := VBoxContainer.new()
	dentro.add_theme_constant_override("separation", 10)
	dentro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.add_child(dentro)
	PaginePausa.riempi(dentro, sezione_diario)
	ritorno(false)
	cascata(voci, qui)

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
	indice.add_theme_constant_override("separation", 0)
	indice.custom_minimum_size = Vector2(280, 0)
	corpo.add_child(indice)
	var voci: Array[VoceMenu] = []
	var qui := 0
	for scomparto in SCOMPARTI:
		var chiave := String(scomparto[0])
		var quanti := PaginePausa.contenuto_scomparto(chiave).size()
		if chiave == scomparto_aperto:
			qui = voci.size()
		voci.append(voce_d_indice(indice, "%s  (%s)" % [String(scomparto[1]),
				PaginePausa.capienza_testo(chiave, quanti)], chiave == scomparto_aperto,
				func() -> void:
					scomparto_aperto = chiave
					mostra_inventario()))

	var scorrevole := ScrollContainer.new()
	scorrevole.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.size_flags_vertical = Control.SIZE_EXPAND_FILL
	corpo.add_child(scorrevole)
	var dentro := VBoxContainer.new()
	dentro.add_theme_constant_override("separation", 12)
	dentro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.add_child(dentro)
	PaginePausa.disegna_scomparto(dentro, scomparto_aperto)
	ritorno(false)
	cascata(voci, qui)

# --- pannello: equipaggiamento ---
#
# Gli slot non sono numeri, sono ruoli diversi: un'arma decide come colpisci,
# uno stigma e' un patto (da' e toglie), i quattro accessori sono i piccoli
# aggiustamenti, l'ultima risorsa e' la rete che scatta quando stai per cadere.
# Ogni personaggio ha i suoi, e quello che porta vale solo per lui.

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
