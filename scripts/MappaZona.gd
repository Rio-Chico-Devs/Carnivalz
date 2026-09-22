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
#   pieno       ci sei stato. Rosso se e' percorso normale, verde se e' una
#               zona segreta (campo "tipo": "segreta")
#   punto di    lo sai raggiungibile ma non ci sei mai andato: e' il "?" che
#   domanda     invita ad andarci. Cliccabile: ci si va
#   spento      sai solo che li' c'e' qualcosa, perche' confina con un posto in
#               cui sei stato. "?" smorzato, e cliccarlo dice perche' non si
#               passa ancora
#
# Una stanza che non confina con niente di noto non viene disegnata affatto:
# la mappa si costruisce camminando, non si consegna gia' fatta.
#
# Le icone (boss, uscita, scontro duro) sono disegnate a mano qui sotto finche'
# non arrivano i disegni: basta mettere art/icone_mappa/<icona>.png e quello
# vince, senza toccare il codice.

const SCENA_EVENTI := "res://scenes/Main.tscn"
const CARTELLA_ICONE := "res://art/icone_mappa/"
const DURATA_BATTITO := 1.1   # secondi di un salto completo del punto esclamativo

const LATO_MINIMO := 30.0     # sotto questa misura un quadratino non si legge
const LATO_MASSIMO := 104.0   # sopra, una zona piccola diventa ridicola
const MARGINE_CELLA := 5.0    # aria fra il quadrato e il bordo della sua cella

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

var cornice: Control
var strato_sotto: Control      # griglia e collegamenti
var strato_sopra: Control      # icone e "sei qui"
var strato_bottoni: Control
var etichetta_stato: Label

func _ready() -> void:
	var sfondo := ColorRect.new()
	sfondo.color = Stile.colore("sfondo")
	sfondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sfondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sfondo)

	carica_disegno()
	for stanza in GameState.mappa_zona.get("stanze", []):
		stanze_per_id[String(stanza.get("id", ""))] = stanza
		var cella := cella_di(stanza)
		var misura := dimensione_di(stanza)
		colonne = maxi(colonne, int(cella.x + misura.x))
		righe = maxi(righe, int(cella.y + misura.y))

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
	obiettivo_in_vista = c_e_un_obiettivo()
	set_process(obiettivo_in_vista)

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

# --- intelaiatura --------------------------------------------------------

func costruisci_intelaiatura() -> void:
	# i margini ci vogliono, se no il titolo tocca il bordo destro e ci esce
	var margini := MarginContainer.new()
	margini.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lato_margine in ["left", "right", "top", "bottom"]:
		margini.add_theme_constant_override("margin_" + lato_margine, Stile.forma("cornice"))
	add_child(margini)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 12)
	margini.add_child(colonna)

	var barra := HBoxContainer.new()
	barra.add_theme_constant_override("separation", 16)
	colonna.add_child(barra)

	var indietro := Button.new()
	indietro.text = "Torna alla stanza corrente"
	indietro.pressed.connect(func() -> void: IngressoNodo.vai_al_nodo(GameState.nodo_corrente))
	barra.add_child(indietro)

	var spazio := Control.new()
	spazio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.add_child(spazio)

	var titolo := Label.new()
	titolo.text = String(GameState.mappa_zona.get("nome", ""))
	titolo.add_theme_color_override("font_color", Stile.colore("accento"))
	titolo.add_theme_font_size_override("font_size", Stile.dimensione("sezione"))
	barra.add_child(titolo)

	# la cornice del disegno di Bru: la porzione di mappa che stai guardando
	cornice = Control.new()
	cornice.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cornice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cornice.clip_contents = true
	colonna.add_child(cornice)

	strato_sotto = Control.new()
	strato_sotto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	strato_sotto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strato_sotto.draw.connect(_disegna_sotto)
	cornice.add_child(strato_sotto)

	strato_bottoni = Control.new()
	strato_bottoni.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	strato_bottoni.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cornice.add_child(strato_bottoni)

	strato_sopra = Control.new()
	strato_sopra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	strato_sopra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strato_sopra.draw.connect(_disegna_sopra)
	cornice.add_child(strato_sopra)

	etichetta_stato = Label.new()
	etichetta_stato.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etichetta_stato.add_theme_color_override("font_color", Stile.colore("testo_smorzato"))
	etichetta_stato.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	etichetta_stato.text = " "
	colonna.add_child(etichetta_stato)

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
	disegna_bottoni()
	strato_sotto.queue_redraw()
	strato_sopra.queue_redraw()

func rettangolo_di(stanza: Dictionary) -> Rect2:
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
	# I PROIETTORI SONO UNA RETE, non un ritorno alla base: si salta da uno
	# all'altro, e solo stando su uno. Se sei in mezzo al niente, cammini.
	return GameState.su_un_proiettore() and GameState.ce_un_proiettore(id_stanza) \
			and visitata(id_stanza)

# --- i quadratini --------------------------------------------------------

func disegna_bottoni() -> void:
	Albero.svuota(strato_bottoni)
	for stanza in GameState.mappa_zona.get("stanze", []):
		var id_stanza := String(stanza.get("id", ""))
		if not si_vede(id_stanza):
			continue   # non se ne conosce nemmeno l'esistenza
		var rettangolo := rettangolo_di(stanza)
		var bottone := Button.new()
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
		bottone.tooltip_text = String(stanza.get("nome", id_stanza))
		bottone.mouse_filter = Control.MOUSE_FILTER_STOP
		var noto := GameState.stanza_sbloccata(id_stanza)
		var raggiungibile := si_puo_andare(id_stanza)
		if visitata(id_stanza):
			vesti_pieno(bottone, e_segreta(stanza), raggiungibile)
		else:
			# il punto di domanda: quello che invita ad andarci. NON dove c'e'
			# gia' il punto esclamativo: quello dice "vai qui" molto meglio di
			# un "?", e i due sovrapposti erano solo due segni uno sull'altro.
			if icona_di(stanza) != "obiettivo":
				bottone.text = "?"
				bottone.add_theme_font_size_override("font_size", int(lato * 0.5))
			vesti_vuoto(bottone, noto, raggiungibile)
		bottone.pressed.connect(_su_stanza.bind(id_stanza, noto, raggiungibile))
		bottone.mouse_entered.connect(func() -> void:
			etichetta_stato.text = String(stanza.get("nome", id_stanza)) if noto or visitata(id_stanza) else "?")
		strato_bottoni.add_child(bottone)

func vesti_pieno(bottone: Button, segreta: bool, raggiungibile: bool) -> void:
	# un posto dove sei stato ma da cui sei lontano resta rosso, ma spento: si
	# vede che c'e' e si vede che non ci si salta
	var tinta := Stile.colore("positivo") if segreta else Stile.colore("pericolo")
	if not raggiungibile:
		tinta = tinta.darkened(0.45)
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
		scatola.border_color = Stile.colore("accento") if raggiungibile else tinta.darkened(0.3)
		bottone.add_theme_stylebox_override(stato, scatola)

func vesti_vuoto(bottone: Button, noto: bool, raggiungibile: bool) -> void:
	var tinta := Stile.colore("accento") if noto else Stile.colore("tratto")
	var forza := 0.95 if raggiungibile else (0.5 if noto else 0.4)
	bottone.add_theme_color_override("font_color", Color(tinta, forza))
	for stato in ["normal", "hover", "pressed", "focus"]:
		var scatola := StyleBoxFlat.new()
		scatola.bg_color = Color(tinta, 0.10 if stato == "normal" else 0.20)
		scatola.set_corner_radius_all(3)
		scatola.set_border_width_all(2)
		scatola.border_color = Color(tinta, 0.9 if raggiungibile else 0.35)
		bottone.add_theme_stylebox_override(stato, scatola)

func _su_stanza(id_stanza: String, _noto: bool, raggiungibile: bool) -> void:
	# un click che non porta da nessuna parte deve comunque dire perche': il
	# silenzio si legge come un bottone rotto
	if not raggiungibile:
		if GameState.ce_un_proiettore(id_stanza):
			etichetta_stato.text = "C'è un proiettore, ma per usarlo devi essere su un altro proiettore."
		else:
			etichetta_stato.text = "Troppo lontano. Da qui si va solo dove si arriva a piedi."
		return
	GameState.nodo_corrente = id_stanza
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
			# il foglio in attesa: si vede dove starebbe la mappa
			strato_sotto.draw_rect(riquadro_disegno, Color(Stile.colore("tratto"), 0.10))
			strato_sotto.draw_rect(riquadro_disegno, Color(Stile.colore("tratto"), 0.45), false, 2.0)
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
				Color(Stile.colore("tratto"), 0.95 if pieno else 0.5),
				maxf(lato * 0.09, 3.0))

# --- strato di sopra: icone e "sei qui" ---------------------------------

func _disegna_sopra() -> void:
	for stanza in GameState.mappa_zona.get("stanze", []):
		var id_stanza := String(stanza.get("id", ""))
		if not si_vede(id_stanza):
			continue
		var rettangolo := rettangolo_di(stanza)
		var icona := icona_di(stanza)
		# IL PUNTO ESCLAMATIVO E' L'ECCEZIONE, e per il motivo piu' ovvio: le
		# altre icone raccontano cosa hai trovato in un posto, quindi si vedono
		# solo dove sei gia' stato. Questa racconta dove DEVI andare, e un
		# segnale che compare solo dopo che ci sei arrivato non e' un segnale.
		if icona == "obiettivo":
			disegna_obiettivo(rettangolo)
		elif visitata(id_stanza):
			disegna_icona(icona, rettangolo)
		if id_stanza == GameState.proiettore_qui():
			disegna_proiettore(rettangolo)
		if id_stanza == GameState.nodo_corrente:
			disegna_sei_qui(rettangolo)

func disegna_obiettivo(rettangolo: Rect2) -> void:
	# DOVE DEVI ANDARE, e si muove. Bru: «puoi andare solo nella sala
	# allenamento che ha un punto esclamativo animato che si muove».
	#
	# Si muove perche' su una mappa ferma, fatta di quadrati tutti uguali, l'
	# unica cosa che l'occhio trova da solo e' quella che si muove. Saltella e
	# respira: due movimenti diversi insieme, perche' uno solo sembra un errore
	# di disegno e due sembrano una cosa viva.
	var centro := rettangolo.get_center()
	var raggio := minf(rettangolo.size.x, rettangolo.size.y) * 0.5
	var salto := sin(battito * TAU) * raggio * 0.14
	var respiro := 1.0 + sin(battito * TAU * 2.0) * 0.06
	centro.y += salto
	# il disco si interroga una volta sola, non a ogni fotogramma: questo
	# disegno si rifa' sessanta volte al secondo finche' il punto pulsa
	var texture := Disegni.texture(CARTELLA_ICONE + "obiettivo.png")
	if texture != null:
		var misura := Vector2.ONE * raggio * 1.24 * respiro
		strato_sopra.draw_texture_rect(texture, Rect2(centro - misura * 0.5, misura), false)
		return
	# il punto esclamativo disegnato a mano finche' non arriva quello vero:
	# un'asta e un punto, che e' tutto quello che serve perche' si legga
	var tinta := Stile.colore("accento")
	var alto := raggio * 0.62 * respiro
	var spessore := maxf(raggio * 0.17, 3.0)
	strato_sopra.draw_line(centro + Vector2(0.0, -alto), centro + Vector2(0.0, alto * 0.25),
			tinta, spessore)
	strato_sopra.draw_circle(centro + Vector2(0.0, alto * 0.72), spessore * 0.58, tinta)

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

func disegna_icona(icona: String, rettangolo: Rect2) -> void:
	if icona == "":
		return
	# se il disegno c'e' vince lui: aggiungere un'icona e' aggiungere un file
	var texture := Disegni.texture(CARTELLA_ICONE + icona + ".png")
	if texture != null:
		var misura := Vector2.ONE * minf(rettangolo.size.x, rettangolo.size.y) * 0.62
		strato_sopra.draw_texture_rect(texture,
				Rect2(rettangolo.get_center() - misura * 0.5, misura), false)
		return
	var centro := rettangolo.get_center()
	var raggio := minf(rettangolo.size.x, rettangolo.size.y) * 0.5
	var tinta := Stile.colore("testo")
	match icona:
		"boss":
			strato_sopra.draw_arc(centro, raggio * 0.58, 0.0, TAU, 24, tinta, maxf(raggio * 0.14, 2.0))
		"forte":
			strato_sopra.draw_circle(centro, raggio * 0.26, tinta)
		"uscita":
			var d := raggio * 0.44
			var spessore := maxf(raggio * 0.16, 2.0)
			strato_sopra.draw_line(centro - Vector2(d, d), centro + Vector2(d, d), tinta, spessore)
			strato_sopra.draw_line(centro + Vector2(d, -d), centro - Vector2(d, -d), tinta, spessore)
		_:
			strato_sopra.draw_arc(centro, raggio * 0.4, 0.0, TAU, 16, tinta, 2.0)

func disegna_proiettore(rettangolo: Rect2) -> void:
	# il proiettore piantato: un anello nell'angolo, per non coprire l'icona
	# della stanza e per non farsi confondere con la freccia
	var misura := minf(rettangolo.size.x, rettangolo.size.y) * 0.3
	var angolo := rettangolo.position + Vector2(rettangolo.size.x - misura * 1.2, misura * 0.2)
	var disegno := Disegni.texture(CARTELLA_ICONE + "proiettore.png")
	if disegno != null:
		strato_sopra.draw_texture_rect(disegno, Rect2(angolo, Vector2.ONE * misura), false)
		return
	var centro := angolo + Vector2.ONE * misura * 0.5
	var tinta := Stile.colore("accento")
	strato_sopra.draw_arc(centro, misura * 0.45, 0.0, TAU, 20, tinta, maxf(misura * 0.16, 2.0))
	strato_sopra.draw_circle(centro, misura * 0.13, tinta)

func disegna_sei_qui(rettangolo: Rect2) -> void:
	# la freccia: dove sei adesso. Sta sopra il quadrato, non dentro, cosi' non
	# copre la sua icona
	var centro := rettangolo.get_center()
	var misura := minf(rettangolo.size.x, rettangolo.size.y)
	var punta := centro + Vector2(0, misura * 0.16)
	var larghezza := misura * 0.20
	var altezza := misura * 0.24
	var tinta := Stile.colore("accento")
	strato_sopra.draw_colored_polygon(PackedVector2Array([
		punta,
		punta + Vector2(-larghezza, -altezza),
		punta + Vector2(-larghezza * 0.45, -altezza),
		punta + Vector2(-larghezza * 0.45, -altezza - misura * 0.22),
		punta + Vector2(larghezza * 0.45, -altezza - misura * 0.22),
		punta + Vector2(larghezza * 0.45, -altezza),
		punta + Vector2(larghezza, -altezza),
	]), tinta)
