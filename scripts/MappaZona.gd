class_name MappaZona
extends Control

# La mappa di una zona: una figura fatta di quadratini, uno per scena.
#
# PERCHE' NON E' PIU' UN GRAFO DI PALLINI. Prima le stanze stavano a coordinate
# libere in pixel e la mappa era un diagramma: leggibile per chi l'aveva scritta,
# muta per chi ci gioca. Adesso ogni stanza occupa una o piu' CELLE di una
# griglia (campo "cella", e "dimensione" per quelle grandi), e la mappa e' un
# posto: si vede che il salone e' largo, che il vivaio scende, che a est
# c'e' ancora qualcosa da guardare.
#
# I TRE STATI DI UN QUADRATINO, e sono l'unica cosa che conta qui dentro:
#
#   pieno       ci sei stato. Rosso se e' percorso normale; se e' una zona
#               segreta (campo "tipo": "segreta") verde chiaro E tratteggiato,
#               perche' il verde da solo non basta - vedi tinta_stanza()
#   punto di    lo sai raggiungibile ma non ci sei mai andato: e' il "?" che
#   domanda     invita ad andarci. Cliccabile: ci si va
#   spento      sai solo che li' c'e' qualcosa, perche' confina con un posto in
#               cui sei stato. "?" smorzato, e cliccarlo dice perche' non si
#               passa ancora
#
# Una stanza che non confina con niente di noto non viene disegnata affatto:
# la mappa si costruisce camminando, non si consegna gia' fatta.
#
# Le icone (boss, uscita, "sei qui", il punto esclamativo) stanno in
# SegniMappa.gd; i nomi delle stanze non ci stanno dentro e si leggono nella
# legenda di fianco, che e' ElencoPosti.gd. Tranne alla Sede, dove la mappa e'
# la schermata e i nomi stanno sulla pianta (IntelaiaturaZona, SegniPianta).

const SCENA_EVENTI := "res://scenes/Main.tscn"
const DURATA_BATTITO := 1.1   # secondi di un salto completo del punto esclamativo

const LATO_MINIMO := 30.0     # sotto questa misura un quadratino non si legge
const LATO_MASSIMO := 104.0   # sopra, una zona piccola diventa ridicola
const MARGINE_CELLA := 5.0    # aria fra il quadrato e il bordo della sua cella

# QUANTO SI SPEGNE UN POSTO DOVE NON SI ARRIVA. Era 0,45, e portava il rosso a
# 2,03:1 sul nero: sotto la soglia, cioe' un quadrato che c'e' ma non si vede.
# A 0,20 sta a 3,32:1 e resta comunque piu' spento di quello vicino (1,44:1
# fra i due). La differenza fra "ci arrivo" e "non ci arrivo" non la porta piu'
# solo lo spegnimento: la porta anche il bordo, acceso di accento soltanto
# dove si puo' andare. Due variabili invece di una.
const SPENTO_LONTANO := 0.20
# E quanto si schiarisce il verde delle segrete: vedi tinta_stanza()
const SCHIARITA_SEGRETA := 0.40
const SCHIARITA_TRATTEGGIO := 0.45

var battito := 0.0              # dove sta il punto esclamativo nel suo salto
var obiettivo_in_vista := false  # se non c'e', questo strato non si ridisegna mai
var stanze_per_id: Dictionary = {}
var colonne := 1
var righe := 1
var lato := 64.0
var origine := Vector2.ZERO

var disegno: Texture2D = null      # la mappa disegnata da Bru, quando c'e'
var misura_disegno := Vector2.ZERO # quanto e' grande quel disegno, dichiarato nei dati
var riquadro_disegno := Rect2()    # e dove finisce a schermo, dopo averlo adattato

var indicata := ""             # la stanza che l'anello sta cerchiando, se c'e'

# una riga da dire una volta, aprendo: la Sede ci mette com'e' andato il
# salvataggio e com'e' messo il presidio. Si consuma alla nascita della mappa
static var avviso := ""
var detto := ""

var cornice: Control
var plastico: PlasticoZona = null   # la zona in 3D, a piani, se la chiede ("vista": "plastico")
var elenco: ElencoPosti
var strato_sotto: Control      # griglia e collegamenti
var strato_sopra: Control      # icone e "sei qui"
var strato_bottoni: Control
var etichetta_stato: Label

func _ready() -> void:
	Manifesto.trama_dietro(self)   # l'arancio del manifesto; la mappa sta nel vetro

	carica_disegno()
	for stanza in GameState.mappa_zona.get("stanze", []):
		stanze_per_id[String(stanza.get("id", ""))] = stanza
		var cella := cella_di(stanza)
		var misura := dimensione_di(stanza)
		colonne = maxi(colonne, int(cella.x + misura.x))
		righe = maxi(righe, int(cella.y + misura.y))
	detto = avviso
	avviso = ""

	costruisci_intelaiatura()
	# SI ASPETTA LA CORNICE, NON LO SCHERMO.
	#
	# Prima si stava in ascolto solo del ridimensionamento di QUESTA schermata.
	# Ma quando la schermata nasce gia' della sua misura - e succede - il
	# segnale non arriva mai, e l'unica ricostruzione e' quella qui sotto, che
	# gira quando la cornice dentro il contenitore non ha ancora nessuna
	# dimensione e quindi si arrende. Risultato: una mappa disegnata in un
	# angolo, grande un quarto dello schermo, senza nessun errore da nessuna
	# parte. La cornice invece il suo resized lo manda sempre, perche' e' il
	# contenitore a dargli la misura, e quello succede sempre dopo.
	cornice.resized.connect(ricostruisci)
	resized.connect(ricostruisci)
	ricostruisci()
	# LA LEGENDA SI RIEMPIE QUI E NON DENTRO ricostruisci(), e non e' un
	# dettaglio: ricostruisci() e' agganciata al ridimensionamento della
	# cornice, e aggiungere righe alla legenda cambia la larghezza che la
	# cornice si prende. Chiamandola di li' si innescava un anello infinito -
	# riempi, cambia misura, resized, ricostruisci, riempi - e le prove si
	# piantavano senza stampare niente. I nomi dei posti dipendono da quello
	# che sai, non da quanto e' larga la finestra.
	elenco.riempi(posti_da_elencare())
	_smetti_di_indicare()
	obiettivo_in_vista = c_e_un_obiettivo()
	set_process(obiettivo_in_vista)
	if GuidaSullaMappa.sta_parlando():
		GuidaSullaMappa.accompagna(self)

# --- lettura dei dati ----------------------------------------------------

func carica_disegno() -> void:
	# LA MAPPA PUO' ESSERE UN DISEGNO, non una griglia di quadratini.
	#
	# Bru, guardando il complesso: «la mappa e' pessima, la dovro' disegnare
	# io». Ed e' vero: una griglia va benissimo per un labirinto che si scopre
	# camminando - e' anche il modo giusto di raccontarlo - ma il quartier
	# generale dell'organizzazione non e' un labirinto, e' un edificio. Di un
	# edificio esiste la pianta, e la pianta la disegna chi lo ha immaginato.
	#
	# Quindi due mappe possibili, e la scelta la fa il file dei dati:
	#   con "disegno"  -> l'immagine di Bru, e le stanze sono riquadri sopra
	#   senza          -> la griglia di sempre, per gli squarci e i dungeon
	#
	# LA MISURA DEL DISEGNO SI DICHIARA nei dati e non si chiede all'immagine.
	# Sembra ridondante e non lo e': dichiarata, le prove possono controllare
	# che i riquadri stiano dentro il foglio e non si accavallino SENZA aprire
	# il file - e Bru puo' scrivere le coordinate mentre il disegno e' ancora
	# in lavorazione, invece che dopo.
	var percorso := String(GameState.mappa_zona.get("disegno", ""))
	if percorso == "":
		return
	var misura: Array = GameState.mappa_zona.get("misura_disegno", [])
	if misura.size() < 2:
		push_warning("La mappa dichiara un disegno ma non la sua misura: " + percorso)
		return
	misura_disegno = Vector2(float(misura[0]), float(misura[1]))
	if ResourceLoader.exists(percorso):
		disegno = load(percorso)
	# se il file non c'e' ancora si continua lo stesso: i riquadri si dispongono
	# sulla misura dichiarata, e si vedono le stanze al posto giusto su un foglio
	# vuoto. E' come provare un montaggio con le inquadrature ancora da girare.

func c_e_un_disegno() -> bool:
	return misura_disegno.x > 0.0 and misura_disegno.y > 0.0

func riquadro_dichiarato(stanza: Dictionary) -> Rect2:
	var r: Array = stanza.get("riquadro", [])
	if r.size() < 4:
		return Rect2()
	return Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))

func cella_di(stanza: Dictionary) -> Vector2:
	var cella: Array = stanza.get("cella", [0, 0])
	return Vector2(cella[0], cella[1])

func dimensione_di(stanza: Dictionary) -> Vector2:
	# una stanza grande occupa piu' di un quadratino: e' l'unico modo che ha la
	# mappa di non mentire sulle proporzioni di un posto
	var misura: Array = stanza.get("dimensione", [1, 1])
	return Vector2(maxi(int(misura[0]), 1), maxi(int(misura[1]), 1))

func e_segreta(stanza: Dictionary) -> bool:
	return String(stanza.get("tipo", "normale")) == "segreta"

func e_la_sede() -> bool:
	# la mappa e' la schermata stessa, non uno strumento: vedi IntelaiaturaZona
	return bool(GameState.mappa_zona.get("sede", false))

func e_un_plastico() -> bool:
	# la zona come un modellino a piani invece che una pianta: vedi PlasticoZona
	return String(GameState.mappa_zona.get("vista", "")) == "plastico"

func chi_c_e(id_stanza: String) -> Array[String]:
	# i personaggi che stanno in una stanza ("personaggi"), se la stanza la conosci
	var chi: Array[String] = []
	if not stanze_per_id.has(id_stanza) or nome_di(id_stanza) == "?":
		return chi
	for id_personaggio in IngressoNodo.lista_id(stanze_per_id[id_stanza].get("personaggi", [])):
		chi.append(String(GameState.personaggi.get(id_personaggio, {}).get("nome", id_personaggio)))
	return chi

func chiusa(id_stanza: String) -> bool:
	# UNA PORTA CHIUSA A CHIAVE si vede, ci si arriva davanti, e non si apre: il
	# corridoio c'e', e' la stanza che aspetta il suo flag ("richiede_flag")
	var serve := String(stanze_per_id.get(id_stanza, {}).get("richiede_flag", ""))
	return serve != "" and not GameState.ha_flag(serve)

# --- la tavolozza della mappa -------------------------------------------
#
# STA TUTTA QUI, IN TRE FUNZIONI CHE NON TOCCANO NIENTE, per un motivo solo:
# cosi' una prova puo' chiederle tutte e misurarle, senza aprire la schermata
# e senza guardare un pixel. Ogni segno che porta un'informazione - un posto
# dove sei stato, un "?" che invita, un corridoio - deve stare sopra 3:1
# contro lo sfondo, e adesso c'e' scritto dove chiederlo.
#
# IL DIFETTO CHE E' COSTATO DI PIU' NON ERA IL BUIO, ERA IL ROSSO E IL VERDE.
# Stanza normale rossa, stanza segreta verde: l'una dall'altra stanno a
# 1,07:1. Due tinte diversissime alla stessa identica luminosita', cioe' lo
# stesso quadrato per chi non distingue le due tinte - e sono circa otto
# uomini su cento. La tinta da sola non ha mai potuto portare una distinzione
# che conta; e' esattamente quello che Bertin classifica come variabile
# associativa ma non ordinata, buona per dire "diverso", inutile per dire
# "quale".
#
# Quindi due variabili anche li':
#   1. il verde si schiarisce - 1,98:1 di stacco dal rosso, che in bianco e
#      nero e' due grigi diversi e non uno solo
#   2. e sopra ci va un tratteggio, che e' TESSITURA: si vede a colori, in
#      bianco e nero, e con qualunque daltonismo
#
# Nessuna delle due da sola basterebbe. Insieme, la segreta si riconosce
# anche in una fotografia sbiadita.

func tinta_stanza(segreta: bool, raggiungibile: bool) -> Color:
	var tinta: Color = Stile.colore("positivo").lightened(SCHIARITA_SEGRETA) \
			if segreta else Stile.colore("pericolo")
	return tinta if raggiungibile else tinta.darkened(SPENTO_LONTANO)

func tinta_domanda(noto: bool, raggiungibile: bool) -> Color:
	# il "?" e' il segno che INVITA ad andare da qualche parte: era la cosa
	# piu' spenta della mappa (1,34:1 per un posto solo intravisto, 1,80:1 per
	# uno noto ma lontano). Un invito che non si vede non e' un invito.
	if not noto:
		return Stile.colore("tratto").lightened(0.08)   # 3,62:1
	return Stile.colore("accento") if raggiungibile \
			else Stile.colore("accento").darkened(0.15)

func tinta_corridoio(percorso: bool) -> Color:
	# "tratto" pieno sta a 2,95:1: mancava per un pelo, e col velo di 0,95 che
	# ci stava sopra scendeva a 2,75:1. Adesso quello percorso sta a 5,44:1 e
	# quello soltanto noto a 3,79:1, e non si distinguono piu' per opacita' -
	# che e' l'unica variabile che spegnendosi scompare - ma per SPESSORE
	# (vedi larghezza_corridoio) oltre che per chiarezza.
	return Stile.colore("tratto").lightened(0.25 if percorso else 0.10)

func larghezza_corridoio(percorso: bool) -> float:
	return maxf(lato * (0.09 if percorso else 0.055), 3.0 if percorso else 2.0)

# --- i segni che stanno SOPRA una stanza --------------------------------
#
# Un segno sopra un quadrato non si misura contro lo sfondo della pagina: si
# misura contro il quadrato. Come si fa perche' regga su tutti e quattro i
# pieni sta in Fascia.gd, insieme al difetto da cui e' nato.

func tinta_segno() -> Color:
	return Stile.colore("testo")

func tinta_fascia() -> Color:
	return Stile.colore("sfondo")

# --- intelaiatura --------------------------------------------------------

func costruisci_intelaiatura() -> void:
	# la barra, la cornice, la legenda e la riga di stato: IntelaiaturaZona.gd
	IntelaiaturaZona.costruisci(self)

# --- geometria -----------------------------------------------------------

func ricostruisci() -> void:
	if cornice == null:
		return
	var spazio := cornice.size
	if spazio.x <= 0.0 or spazio.y <= 0.0:
		return
	if c_e_un_disegno():
		# il foglio di Bru sta dentro la cornice intero, senza deformarsi: una
		# pianta stiracchiata non e' piu' una pianta
		var fattore := minf(spazio.x / misura_disegno.x, spazio.y / misura_disegno.y)
		var grande := misura_disegno * fattore
		riquadro_disegno = Rect2(((spazio - grande) * 0.5).floor(), grande)
	else:
		lato = clampf(minf(spazio.x / float(colonne), spazio.y / float(righe)),
				LATO_MINIMO, LATO_MASSIMO)
		origine = (spazio - Vector2(colonne, righe) * lato) * 0.5
	if plastico != null:
		plastico.inquadra()
		plastico.aggiorna()
	disegna_bottoni()
	strato_sotto.queue_redraw()
	strato_sopra.queue_redraw()

func rettangolo_di(stanza: Dictionary) -> Rect2:
	if plastico != null:
		# dove la stanza finisce a schermo, vista dalla camera del plastico
		return plastico.rettangolo(String(stanza.get("id", "")))
	if c_e_un_disegno():
		# le coordinate sono quelle del disegno di Bru, in pixel del SUO file:
		# qui si riportano alla misura a cui il foglio e' finito a schermo
		var suo := riquadro_dichiarato(stanza)
		var fattore := riquadro_disegno.size.x / misura_disegno.x
		return Rect2(riquadro_disegno.position + suo.position * fattore, suo.size * fattore)
	var alto_sinistra := origine + cella_di(stanza) * lato + Vector2.ONE * MARGINE_CELLA
	var misura := dimensione_di(stanza) * lato - Vector2.ONE * MARGINE_CELLA * 2.0
	return Rect2(alto_sinistra, misura)

func centro_di(id_stanza: String) -> Vector2:
	return rettangolo_di(stanze_per_id[id_stanza]).get_center()

# --- cosa si sa di una stanza -------------------------------------------

func visitata(id_stanza: String) -> bool:
	return id_stanza in GameState.nodi_visitati

func intravista(id_stanza: String) -> bool:
	# confina con un posto in cui sei stato: sai che c'e' qualcosa, non cosa
	for coppia in GameState.collegamenti_aperti():
		if coppia.size() < 2:
			continue
		var a := String(coppia[0])
		var b := String(coppia[1])
		if a == id_stanza and (visitata(b) or GameState.stanza_sbloccata(b)):
			return true
		if b == id_stanza and (visitata(a) or GameState.stanza_sbloccata(a)):
			return true
	return false

func si_vede(id_stanza: String) -> bool:
	return visitata(id_stanza) or GameState.stanza_sbloccata(id_stanza) or intravista(id_stanza)

func si_puo_andare(id_stanza: String) -> bool:
	# DALLA MAPPA CI SI CAMMINA, E SI CAMMINA ANCHE NEL BUIO.
	#
	# Qui c'era il difetto che rendeva la mappa inutilizzabile: si pretendeva
	# che la stanza fosse GIA' sbloccata. Ma una stanza si sblocca solo se un
	# evento la nomina, quindi i punti interrogativi invitavano ad andarci e
	# poi rispondevano "da questa parte non si passa". Una mappa su cui non si
	# puo' esplorare non e' una mappa, e' un disegno.
	#
	# Adesso: nei posti confinanti ci si va sempre, scoperti o no - andarci E'
	# il modo di scoprirli. Il resto della mappa resta guardabile e non
	# raggiungibile, tranne i proiettori (vedi sotto).
	if id_stanza == GameState.nodo_corrente:
		return true
	if id_stanza in GameState.stanze_confinanti(GameState.nodo_corrente):
		return true
	# IN CASA TUA SI VA DRITTI. Una frattura si scopre un passo alla volta, e li'
	# il passo e' il gioco. Il complesso no: e' dove vivi, i corridoi li conosci,
	# e dopo i soldati in palestra la sala comunicazioni col punto esclamativo
	# rispondeva «troppo lontano» - si passava solo facendo tappa in camera, e
	# niente lo diceva. Bru: «dopo il dialogo in sala non riesco ad andare
	# avanti». Con "corridoi_liberi" si arriva in ogni stanza a cui porta un
	# corridoio aperto, quante che siano in mezzo; i corridoi chiusi restano
	# chiusi (la mattina dall'alloggio si va solo in palestra)
	if bool(GameState.mappa_zona.get("corridoi_liberi", false)) \
			and id_stanza in raggiungibili_a_piedi(GameState.nodo_corrente):
		return true
	# I PROIETTORI SONO UNA RETE, non un ritorno alla base: si salta da uno
	# all'altro, e solo stando su uno. Se sei in mezzo al niente, cammini.
	return GameState.su_un_proiettore() and GameState.ce_un_proiettore(id_stanza) \
			and visitata(id_stanza)

func raggiungibili_a_piedi(da: String) -> Array[String]:
	# tutte le stanze in fondo a un corridoio aperto, anche passando per altre
	var viste: Array[String] = [da]
	var da_guardare: Array[String] = [da]
	while not da_guardare.is_empty():
		for vicina in GameState.stanze_confinanti(da_guardare.pop_front()):
			if vicina not in viste:
				viste.append(vicina)
				da_guardare.append(vicina)
	return viste

# --- i quadratini --------------------------------------------------------

func disegna_bottoni() -> void:
	Albero.svuota(strato_bottoni)
	for stanza in GameState.mappa_zona.get("stanze", []):
		var id_stanza := String(stanza.get("id", ""))
		if not si_vede(id_stanza):
			continue   # non se ne conosce nemmeno l'esistenza
		var rettangolo := rettangolo_di(stanza)
		var bottone := PortaStanza.new()
		bottone.set_meta("stanza", id_stanza)
		# NON PIATTO, MAI. Un Button con flat = true in Godot NON DISEGNA il suo
		# StyleBox: salta il fondo e disegna solo il testo. Qui sotto ci sono
		# quaranta righe che costruiscono una scatola per ogni stato - fondo,
		# bordo, angoli, il rosso spento per i posti lontani - e questa riga le
		# buttava via tutte, in silenzio. La mappa veniva fuori come una manciata
		# di "?" e di trattini sul nero: le stanze VISITATE, quelle che dovevano
		# essere quadrati rossi pieni, non si vedevano proprio. Bru, guardandola:
		# «la mappa e' pessima». Non era il disegno che mancava, era questo.
		bottone.flat = false
		bottone.position = rettangolo.position
		bottone.size = rettangolo.size
		bottone.tooltip_text = nome_di(id_stanza)   # «?» finche' non la conosci: il nome vero sarebbe uno spoiler
		bottone.mouse_filter = Control.MOUSE_FILTER_STOP
		var noto := GameState.stanza_sbloccata(id_stanza)
		var raggiungibile := si_puo_andare(id_stanza)
		if visitata(id_stanza):
			vesti_pieno(bottone, e_segreta(stanza), raggiungibile)
		else:
			# il punto di domanda: quello che invita ad andarci. NON dove c'e'
			# gia' il punto esclamativo: quello dice "vai qui" molto meglio di
			# un "?", e i due sovrapposti erano solo due segni uno sull'altro.
			if icona_di(stanza) != "obiettivo" and not (e_la_sede() or plastico != null):
				bottone.text = "?"
				bottone.add_theme_font_size_override("font_size", int(lato * 0.5))
			vesti_vuoto(bottone, noto, raggiungibile)
		if e_la_sede() or plastico != null:
			# alla Sede e sul plastico il nome sta sulla stanza, non in una legenda
			SegniPianta.nome(bottone, nome_di(id_stanza), corpo_dei_nomi())
		bottone.pressed.connect(_su_stanza.bind(id_stanza, noto, raggiungibile))
		# ANCHE COL TASTO, NON SOLO COL MOUSE. In Godot il suggerimento non
		# compare quando un bottone prende il fuoco da tastiera: chi gira la
		# mappa senza mouse passava da un quadrato all'altro senza che nessuno
		# gli dicesse mai cosa stava guardando.
		bottone.mouse_entered.connect(_indica_stanza.bind(id_stanza))
		bottone.focus_entered.connect(_indica_stanza.bind(id_stanza))
		bottone.mouse_exited.connect(_smetti_di_indicare)
		bottone.focus_exited.connect(_smetti_di_indicare)
		strato_bottoni.add_child(bottone)
	if plastico != null:
		plastico.svuota(strato_bottoni)   # le stanze le disegna il plastico: le porte non hanno faccia
		riposiziona()

func riposiziona() -> void:
	# il plastico si e' mosso: le porte e le icone lo seguono
	for porta in strato_bottoni.get_children():
		plastico.metti_porta(porta as PortaStanza, String(porta.get_meta("stanza", "")))
	plastico.ordina(strato_bottoni)
	strato_sopra.queue_redraw()

func vesti_pieno(bottone: Button, segreta: bool, raggiungibile: bool) -> void:
	# un posto dove sei stato ma da cui sei lontano resta rosso, ma spento: si
	# vede che c'e' e si vede che non ci si salta
	var tinta := tinta_stanza(segreta, raggiungibile)
	# SOPRA UN DISEGNO NON SI SPALMA. Su una griglia il quadrato pieno E' la
	# stanza, e deve essere pieno; sopra la pianta disegnata da Bru la stessa
	# tinta opaca coprirebbe proprio quello che si e' andati a disegnare. La
	# stanza resta segnata, ma si vede attraverso.
	var velo := 0.42 if c_e_un_disegno() else 1.0
	for stato in ["normal", "hover", "pressed", "focus"]:
		var scatola := StyleBoxFlat.new()
		var fondo := tinta.lightened(0.12) if stato != "normal" and raggiungibile else tinta
		scatola.bg_color = Color(fondo, velo)
		scatola.set_corner_radius_all(3)
		scatola.set_border_width_all(2)
		# IL BORDO NON SI SPEGNE PIU' SOTTO IL FONDO. Era tinta.darkened(0.3)
		# sopra una tinta gia' spenta: un filo a 1,4:1, cioe' niente. Dove non
		# si arriva il bordo e' il fondo stesso - un blocco solo, spento - e
		# dove si arriva e' accento, che e' un'altra tinta e si vede.
		scatola.border_color = Stile.colore("accento") if raggiungibile else tinta
		bottone.add_theme_stylebox_override(stato, scatola)

func vesti_vuoto(bottone: Button, noto: bool, raggiungibile: bool) -> void:
	# IL SEGNO E' OPACO, IL FONDO NO. Il "?" e il bordo portano l'informazione
	# e stanno sopra la soglia; il velo dentro al riquadro e' soltanto lo
	# sfondo su cui si appoggiano, e quello puo' e deve restare quasi niente -
	# e' figura contro fondo, e il fondo non deve competere.
	var tinta := tinta_domanda(noto, raggiungibile)
	bottone.add_theme_color_override("font_color", tinta)
	for stato in ["normal", "hover", "pressed", "focus"]:
		var scatola := StyleBoxFlat.new()
		scatola.bg_color = Color(tinta, 0.10 if stato == "normal" else 0.20)
		scatola.set_corner_radius_all(3)
		scatola.set_border_width_all(2)
		scatola.border_color = tinta
		bottone.add_theme_stylebox_override(stato, scatola)

func _indica_stanza(id_stanza: String) -> void:
	indicata = id_stanza
	if plastico != null:
		plastico.evidenzia(id_stanza)
	# e cosa ci si fa, se la stanza lo dice ("cosa"): «dove vado? cosa faccio?»
	var cosa := String(stanze_per_id.get(id_stanza, {}).get("cosa", ""))
	etichetta_stato.text = nome_di(id_stanza) if cosa == "" or chiusa(id_stanza) \
			else "%s  ·  %s" % [nome_di(id_stanza), cosa]
	# e chi ci trovi, se ci sta qualcuno
	if not chi_c_e(id_stanza).is_empty():
		etichetta_stato.text += "  ·  " + ", ".join(chi_c_e(id_stanza))
	elenco.evidenzia(id_stanza)
	strato_sopra.queue_redraw()

func _smetti_di_indicare() -> void:
	if plastico != null:
		plastico.evidenzia("")
	# SI TORNA A DIRE DOVE SEI, non si torna al vuoto. Prima qui restava una
	# riga bianca, e la schermata smetteva di rispondere alla sola domanda a
	# cui una mappa deve rispondere sempre.
	indicata = ""
	etichetta_stato.text = dove_sei()
	elenco.evidenzia("")
	strato_sopra.queue_redraw()

func dove_sei() -> String:
	var nome := nome_di(GameState.nodo_corrente)
	var qui := "" if nome == "" else "Sei in: %s" % nome
	if detto == "":
		return qui
	return detto if qui == "" else "%s  ·  %s" % [qui, detto]

func nome_di(id_stanza: String) -> String:
	# il nome si sa se ci sei stato o se la storia te l'ha nominato; se no e'
	# un "?", ed e' giusto che resti un "?"
	if not stanze_per_id.has(id_stanza):
		return ""
	if chiusa(id_stanza) or not (visitata(id_stanza) or GameState.stanza_sbloccata(id_stanza)):
		return "?"
	return String(stanze_per_id[id_stanza].get("nome", id_stanza))

func posti_da_elencare() -> Array:
	# LA LEGENDA LA COMPILA LA MAPPA, non se la costruisce da se'. Chi decide
	# cosa si sa e dove si arriva dev'essere uno solo: due posti che decidono
	# la stessa cosa prima o poi la decidono in modo diverso.
	var posti: Array = []
	for stanza in GameState.mappa_zona.get("stanze", []):
		var id_stanza := String(stanza.get("id", ""))
		if not si_vede(id_stanza):
			continue
		if not (visitata(id_stanza) or GameState.stanza_sbloccata(id_stanza)):
			continue   # di questo non sai nemmeno il nome: sulla mappa e' un "?"
		var raggiungibile := si_puo_andare(id_stanza)
		posti.append({
			"id": id_stanza,
			"nome": String(stanza.get("nome", id_stanza)),
			"visitata": visitata(id_stanza),
			"segreta": e_segreta(stanza),
			"raggiungibile": raggiungibile,
			"tinta": tinta_stanza(e_segreta(stanza), raggiungibile),
		})
	return posti

func _su_stanza_per_id(id_stanza: String) -> void:
	_su_stanza(id_stanza, GameState.stanza_sbloccata(id_stanza), si_puo_andare(id_stanza))

func _su_stanza(id_stanza: String, _noto: bool, raggiungibile: bool) -> void:
	# un click che non porta da nessuna parte deve comunque dire perche': il
	# silenzio si legge come un bottone rotto
	if GuidaSullaMappa.solo_chiudere():
		etichetta_stato.text = "La Guida sta ancora parlando."
		return
	if chiusa(id_stanza):
		etichetta_stato.text = String(stanze_per_id[id_stanza].get("testo_chiusa", "La porta è chiusa."))
		return
	if not raggiungibile:
		if GameState.ce_un_proiettore(id_stanza):
			etichetta_stato.text = "C'è un proiettore, ma per usarlo devi essere su un altro proiettore."
		else:
			etichetta_stato.text = "Troppo lontano. Da qui si va solo dove si arriva a piedi."
		return
	# DOVE SEI LO DECIDE CHI ENTRA, non chi clicca. Qui si scriveva la stanza
	# cliccata in nodo_corrente prima di entrarci; IngressoNodo.entra lo fa
	# comunque, e meglio (sa quale stanza e' davvero). Ma c'e' una scena che non
	# ti sposta - il promontorio dopo la fuga, «Se ne occupera'
	# l'organizzazione» - e con la stanza gia' scritta qui ti ritrovavi in cima
	# a un posto in cui ti eri appena rifiutato di salire
	IngressoNodo.vai_al_nodo(id_stanza)

# --- strato di sotto: la griglia e i collegamenti -----------------------

func _disegna_sotto() -> void:
	if c_e_un_disegno():
		# SUL DISEGNO NON SI DISEGNA SOPRA. Niente reticolo e niente linee di
		# collegamento: i corridoi in una pianta ci sono gia', ed erano proprio
		# quello che le linee stavano cercando di dire. I collegamenti
		# continuano a decidere DOVE si puo' andare - quella e' logica, non
		# grafica - semplicemente non si vedono piu', perche' si vedono meglio.
		if disegno != null:
			strato_sotto.draw_texture_rect(disegno, riquadro_disegno, false)
		else:
			# il foglio in attesa: si vede dove starebbe la mappa, e i corridoi
			# fra le stanze finche' non li disegna Bru (SegniPianta)
			SegniPianta.foglio(self, strato_sotto)
		return
	# il reticolo si deve VEDERE sul buio: "bordo" e' il nero della cornice
	var reticolo := Color(Stile.colore("tratto"), 0.30)
	for c in colonne + 1:
		var x := origine.x + c * lato
		strato_sotto.draw_line(Vector2(x, origine.y),
				Vector2(x, origine.y + righe * lato), reticolo, 1.0)
	for r in righe + 1:
		var y := origine.y + r * lato
		strato_sotto.draw_line(Vector2(origine.x, y),
				Vector2(origine.x + colonne * lato, y), reticolo, 1.0)

	for coppia in GameState.collegamenti_aperti():
		if coppia.size() < 2:
			continue
		var a := String(coppia[0])
		var b := String(coppia[1])
		if not (stanze_per_id.has(a) and stanze_per_id.has(b)):
			continue
		if not (si_vede(a) or si_vede(b)):
			continue   # nessuno dei due capi e' noto: la linea non esiste
		var pieno := visitata(a) and visitata(b)
		strato_sotto.draw_line(centro_di(a), centro_di(b),
				tinta_corridoio(pieno), larghezza_corridoio(pieno))

# --- strato di sopra: icone e "sei qui" ---------------------------------

func _disegna_sopra() -> void:
	for stanza in GameState.mappa_zona.get("stanze", []):
		var id_stanza := String(stanza.get("id", ""))
		if not si_vede(id_stanza) or (plastico != null and plastico.velata(id_stanza)):
			continue   # sul plastico, un piano spento non ha icone
		var rettangolo := rettangolo_di(stanza)
		var segni := rettangolo_dei_segni(id_stanza, rettangolo)
		var icona := icona_di(stanza)
		# IL PUNTO ESCLAMATIVO E' L'ECCEZIONE, e per il motivo piu' ovvio: le
		# altre icone raccontano cosa hai trovato in un posto, quindi si vedono
		# solo dove sei gia' stato. Questa racconta dove DEVI andare, e un
		# segnale che compare solo dopo che ci sei arrivato non e' un segnale.
		tratteggia(stanza, rettangolo)
		if icona == "obiettivo":
			SegniMappa.obiettivo(strato_sopra, segni, battito,
					tinta_segno(), tinta_fascia())
		elif visitata(id_stanza):
			SegniMappa.icona(strato_sopra, icona, segni,
					tinta_segno(), tinta_fascia())
		if id_stanza == GameState.proiettore_qui():
			SegniMappa.proiettore(strato_sopra, segni, tinta_segno(), tinta_fascia())
		if id_stanza == GameState.nodo_corrente:
			SegniMappa.sei_qui(strato_sopra, segni, tinta_segno(), tinta_fascia())
		if id_stanza == indicata:
			disegna_anello(rettangolo)

func rettangolo_dei_segni(id_stanza: String, rettangolo: Rect2) -> Rect2:
	# sul plastico le icone stanno sopra il tetto della stanza, sempre della
	# stessa misura: la stanza a schermo cambia forma girando la vista
	if plastico != null:
		return plastico.segni_di(id_stanza)
	# alla Sede in fondo al riquadro c'e' il nome: icone e freccia stanno sopra
	if not e_la_sede():
		return rettangolo
	return rettangolo.grow_side(SIDE_BOTTOM, -corpo_dei_nomi() * 1.3)

func corpo_dei_nomi() -> int:
	# uno solo per tutta la pianta, che segue quanto e' grande il foglio: con un
	# corpo per stanza le stanze grandi gridavano e le piccole sussurravano
	return clampi(int(riquadro_disegno.size.y / 30.0), 13, 18)

func tratteggia(stanza: Dictionary, rettangolo: Rect2) -> void:
	# solo una segreta gia' vista; sul plastico e' di un altro colore (PlasticoZona.stato_di)
	var id_stanza := String(stanza.get("id", ""))
	if plastico != null or not (visitata(id_stanza) and e_segreta(stanza)):
		return
	# le righe oblique delle stanze segrete: come si tracciano e perche' sta
	# in Tratteggio.gd, che disegna anche il quadratino della legenda - se i
	# due segni non fossero identici la legenda direbbe un'altra cosa
	Tratteggio.dentro(strato_sopra, rettangolo,
			tinta_stanza(true, si_puo_andare(id_stanza)).lightened(SCHIARITA_TRATTEGGIO))

func disegna_anello(rettangolo: Rect2) -> void:
	if plastico != null:
		return   # sul plastico la stanza puntata si accende (PlasticoZona.evidenzia)
	# L'ANELLO E' IL FILO CHE LEGA LA LEGENDA ALLA MAPPA. Senza, un elenco di
	# nomi di fianco e' una tabella: leggi "Sala del lamento" e poi devi
	# andartela a cercare fra ventisette quadrati uguali.
	var fuori := rettangolo.grow(maxf(lato * 0.06, 3.0))
	strato_sopra.draw_rect(fuori, tinta_fascia(), false, maxf(lato * 0.09, 5.0))
	strato_sopra.draw_rect(fuori, Stile.colore("accento"), false, maxf(lato * 0.05, 3.0))


func icona_di(stanza: Dictionary) -> String:
	# L'ICONA DI UNA STANZA PUO' AVERE UN ORARIO.
	#
	# Il punto esclamativo dice dove devi andare ADESSO, e "adesso" cambia. La
	# mattina sta sulla sala di allenamento; quando torni in piedi
	# dall'infermeria quella lezione e' finita e il segnale sta da un'altra
	# parte. Un'icona scritta fissa nei dati direbbe per sempre la stessa cosa,
	# e dopo la prima volta sarebbe una bugia.
	#
	#   "icona_da":     compare solo DOPO che il flag c'e'
	#   "icona_fino_a": smette di comparire APPENA il flag c'e'
	#
	# Vale per tutte le icone, non solo per l'obiettivo: anche un negozio apre
	# un giorno e chiude un altro.
	var da := String(stanza.get("icona_da", ""))
	if da != "" and not GameState.ha_flag(da):
		return ""
	var fino_a := String(stanza.get("icona_fino_a", ""))
	if fino_a != "" and GameState.ha_flag(fino_a):
		return ""
	return String(stanza.get("icona", ""))

func c_e_un_obiettivo() -> bool:
	for stanza in GameState.mappa_zona.get("stanze", []):
		if icona_di(stanza) == "obiettivo" and si_vede(String(stanza.get("id", ""))):
			return true
	return false

func _process(delta: float) -> void:
	# IL TEMPO SCORRE SOLO SE C'E' QUALCOSA CHE SI MUOVE. Una mappa che si
	# ridisegna sessanta volte al secondo per niente e' una ventola che gira
	# per niente: qui di solito non si muove nulla, e quando non si muove nulla
	# questo strato sta fermo.
	if not obiettivo_in_vista:
		return
	battito = fmod(battito + delta / DURATA_BATTITO, 1.0)
	strato_sopra.queue_redraw()
