extends Node

# UN GIOCATORE CHE NON SI STANCA. Parte dallo splash, come chi apre il gioco, e
# gioca con clic e tasti veri: preme quello che vede a schermo, fa scorrere i
# dialoghi, entra nelle stanze, combatte. Non sa niente della storia e non
# chiama nessuna funzione del gioco: tocca solo quello che toccherebbe una
# persona.
#
# Perche' esiste. Le prove guardano lo stato, e lo stato puo' essere giusto
# mentre lo schermo e' sbagliato. I difetti peggiori degli ultimi giorni - il
# testo di fine scontro che scorreva sotto il menu, il KO della raffica che
# ricominciava all'infinito, l'allenamento che ripartiva nel pomeriggio - li
# ha trovati solo giocare. Questo gioca.
#
#   ./prove/automa.sh                     esplora dal menu alla Sede, seme 1
#   ./prove/automa.sh esplora 7           stessa cosa, un altro giro di dadi
#   ./prove/automa.sh scimmia 3 300       clic e tasti a caso per 300 secondi di gioco
#   ./prove/automa.sh scimmia 3 300 negozio
#                                         parte dal negozio, con soldi e una squadra:
#                                         per il negozio e la scheda della squadra
#   ./prove/automa.sh esplora 1 300 veronica_animo
#                                         parte da quel punto della storia, partita
#                                         nuova: per tornare dritti dove si e' rotto
#
# DUE MODI.
#   esplora  sceglie sempre la cosa che ha toccato meno volte in quel punto:
#            cosi' prima o poi apre ogni porta e prova ogni risposta. Non torna
#            mai al menu principale e non esce dal gioco.
#   scimmia  clicca ovunque, anche dove non c'e' niente, preme tasti a caso,
#            apre e chiude la pausa, martella. Cerca quello che una persona
#            nervosa fa senza volerlo.
#
# COSA SEGNALA, e basta: non corregge niente.
#   ERRORE   ogni errore del motore o di uno script, con dove si era e l'ultima
#            azione fatta (serve Godot 4.5+: OS.add_logger)
#   BLOCCO   niente cambia a schermo per un minuto di gioco, per quanto si prema
#   FANTASMA un bottone acceso e visibile che un clic non raggiunge mai
#
# Con una finestra vera (xvfb-run) salva anche uno scatto a ogni segnalazione,
# in scatti/automa/.

const CARTELLA_SCATTI := "res://scatti/automa/"
const FPS := 60
const BLOCCO_SECONDI := 60.0
const ERRORI_MASSIMI := 30
const PASSI_IN_PAUSA := 25        # dopo tanti clic dentro la pausa, si esce
const SCENA_INIZIALE := "res://scenes/Splash.tscn"
const SCENA_COMBATTIMENTO := "res://scenes/Combattimento.tscn"

# mai, in esplora: riportano al titolo o chiudono il gioco
const MAI_IN_ESPLORA := ["ESCI", "Torna al menu principale", "Sì, torna al menu principale"]
# mai, in nessun modo: chiude il gioco e il giro finisce
const MAI := ["ESCI"]


class Registro extends Logger:
	var righe: Array[Dictionary] = []
	var chiave := Mutex.new()

	func _log_error(funzione: String, file: String, riga: int, codice: String, motivo: String,
			_editor: bool, tipo: int, tracce: Array[ScriptBacktrace]) -> void:
		var pila := ""
		for traccia in tracce:
			if traccia != null and not traccia.is_empty():
				pila += traccia.format(0, 2)
		chiave.lock()
		righe.append({"tipo": tipo, "dove": "%s:%d %s" % [file, riga, funzione],
				"testo": motivo if motivo != "" else codice, "pila": pila})
		chiave.unlock()

	func prendi() -> Array[Dictionary]:
		chiave.lock()
		var copia: Array[Dictionary] = righe.duplicate()
		righe.clear()
		chiave.unlock()
		return copia


const FILE_STORIA := ["res://data/events_intro.json", "res://data/events_tutorial.json"]

var modo := "esplora"
var nodo_di_partenza := ""
var seme := 1
var limite_secondi := 1800.0
var fino_a := "res://scenes/Sede.tscn"   # in esplora: arrivati qui, il giro e' riuscito
var dadi := RandomNumberGenerator.new()
var registro: Registro
var con_finestra := false

var fotogrammi := 0
var passi := 0
var passi_in_pausa := 0
var ultima_azione := "(nessuna)"
var toccati := {}          # chiave del punto -> quante volte
var coperti := {}          # chiave -> quante volte il clic e' finito su un altro
var scene_viste := {}
var nodi_visti := {}
var errori: Array[Dictionary] = []
var avvisi := {}           # testo -> quante volte
var blocchi: Array[String] = []
var fantasmi := {}
var firma_ultima := ""
var firma_da := 0
var scatti := 0
var finito := false


func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	if argomenti.size() > 0:
		modo = String(argomenti[0])
	if argomenti.size() > 1:
		seme = int(argomenti[1])
	if argomenti.size() > 2:
		limite_secondi = float(argomenti[2])
	if argomenti.size() > 3:
		nodo_di_partenza = String(argomenti[3])
	if modo == "scimmia":
		fino_a = ""
	dadi.seed = seme
	con_finestra = DisplayServer.get_name() != "headless"
	metti_al_riparo()
	# senza finestra Godot ne apre una da 64x64 e i clic finiscono nel posto
	# sbagliato: la si porta alla misura del gioco
	get_window().size = Vector2i(1280, 720)
	if ClassDB.class_exists("Logger"):
		registro = Registro.new()
		OS.add_logger(registro)
	else:
		print("AUTOMA: questo Godot non ha OS.add_logger, gli errori si leggono solo nell'uscita")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARTELLA_SCATTI))
	print("AUTOMA: modo %s, seme %d, al massimo %d secondi di gioco%s" % [modo, seme,
			int(limite_secondi), ", fino a " + fino_a.get_file() if fino_a != "" else ""])
	# l'automa non resta la scena corrente: se lo restasse, il primo cambio di
	# scena lo libererebbe. Resta accanto agli autoload, e la scena corrente
	# diventa lo splash - come quando il gioco si apre
	if nodo_di_partenza == "negozio":
		fino_a = ""   # dal negozio si gira finche' c'e' tempo
		parti_dal_negozio.call_deferred()
	elif nodo_di_partenza != "":
		parti_da.call_deferred(nodo_di_partenza)
	else:
		var prima := (load(SCENA_INIZIALE) as PackedScene).instantiate()
		get_tree().root.add_child.call_deferred(prima)
		(func() -> void: get_tree().current_scene = prima).call_deferred()
	gira.call_deferred()


# --- le cose di chi gioca davvero ---------------------------------------------
#
# L'automa preme TUTTO, opzioni comprese: accende il testo grande, l'alto
# contrasto, lo schermo intero - e le opzioni si salvano da sole. La prima
# volta e' successo davvero: dopo un giro il gioco si apriva ingrandito, e gli
# scatti fatti dopo erano tutti a testo grande senza che nessuno l'avesse
# chiesto. Lo stesso per le partite: l'automa ne comincia di nuove e le salva.
#
# Quindi all'inizio si mette da parte quello che c'e', si gioca con le opzioni
# di serie, e alla fine si rimette tutto com'era. Se un giro viene interrotto a
# meta', la copia resta li' e il giro dopo la rimette a posto prima di partire.

const RIPARO := "user://automa_riparo/"
const DA_RIPARARE := ["impostazioni.cfg", "codici_riscattati.cfg", "salvataggio_slot_1.json",
		"salvataggio_slot_2.json", "salvataggio_slot_3.json", "salvataggio_slot_4.json",
		"salvataggio_slot_5.json"]


func metti_al_riparo() -> void:
	if DirAccess.dir_exists_absolute(RIPARO):
		print("AUTOMA: il giro prima non ha finito: rimetto a posto le sue copie")
		rimetti_a_posto()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RIPARO))
	for nome: String in DA_RIPARARE:
		if FileAccess.file_exists("user://" + nome):
			DirAccess.copy_absolute(vero("user://" + nome), vero(RIPARO + nome))
	# si gioca con le opzioni di serie, tranne una: la lezione gia' fatta resta
	# com'era, perche' decide se «Salta la lezione» c'e'
	var lezione := Impostazioni.allenamento_gia_fatto
	Impostazioni.testo_grande = false
	Impostazioni.alto_contrasto = false
	Impostazioni.schermo_intero = false
	Impostazioni.movimento_ridotto = false
	Impostazioni.velocita_testo = 1.0
	Impostazioni.allenamento_gia_fatto = lezione
	Impostazioni.applica_tutto()


func rimetti_a_posto() -> void:
	for nome: String in DA_RIPARARE:
		if FileAccess.file_exists("user://" + nome):
			DirAccess.remove_absolute(vero("user://" + nome))
		if FileAccess.file_exists(RIPARO + nome):
			DirAccess.copy_absolute(vero(RIPARO + nome), vero("user://" + nome))
			DirAccess.remove_absolute(vero(RIPARO + nome))
	DirAccess.remove_absolute(vero(RIPARO))


func vero(percorso: String) -> String:
	return ProjectSettings.globalize_path(percorso)


func parti_da(nodo: String) -> void:
	# una partita nuova, messa subito in quel punto della storia: e' come il
	# menu fa partire l'introduzione (Menu.parti), solo con un altro nodo.
	# Prima un segnaposto come scena corrente: il cambio di scena libera quella,
	# e se fosse ancora l'automa liberebbe lui - e' successo, e senza albero
	# ogni suo passo era un errore, che lui stesso registrava: un anello
	var segnaposto := Node.new()
	get_tree().root.add_child(segnaposto)
	get_tree().current_scene = segnaposto
	GameState.nuova_partita()
	for file in FILE_STORIA:
		GameState.avvia_carnivalz("intro" if file.ends_with("intro.json") else "tutorial", file)
		if GameState.eventi.has(nodo):
			IngressoNodo.vai_al_nodo(nodo)
			return
	push_error("AUTOMA: il nodo \"%s\" non c'e' in nessun file della storia" % nodo)


func parti_dal_negozio() -> void:
	# IL NEGOZIO E LA SCHEDA DELLA SQUADRA, con qualcosa da farci: Tazo, i
	# materiali di un baratto, quattro compagni (uno di passaggio, uno oltre la
	# terza carta) e roba da mettersi addosso. Da qui Indietro porta alla Sede,
	# e ESC alla pausa, da cui si apre la scheda
	#   ./prove/automa.sh scimmia 3 300 negozio
	var segnaposto := Node.new()
	get_tree().root.add_child(segnaposto)
	get_tree().current_scene = segnaposto
	GameState.nuova_partita()
	GameState.tazo = 400
	GameState.negozi_sbloccati = ["organizzazione", "nyu", "artigiano"] as Array[String]
	for id_compagno: String in ["sally", "vega"]:
		GameState.recluta(id_compagno)
	GameState.recluta_temporaneo("niru", 3)
	for id_oggetto: String in ["coltello_di_servizio", "mannaia_scheggiata", "amuleto_di_pietra",
			"amuleto_di_ferro", "rottame_di_metallo", "rottame_di_metallo", "convertitore"]:
		GameState.aggiungi_oggetto(id_oggetto)
	Transizioni.vai("res://scenes/Negozio.tscn")


func gira() -> void:
	while not finito:
		await attendi(pausa_fra_azioni())
		if not is_inside_tree():
			return
		raccogli_errori()
		if errori.size() >= ERRORI_MASSIMI:
			chiudi("troppi errori: il resto sarebbe un'eco del primo")
			return
		annota_dove()
		if fotogrammi / float(FPS) > limite_secondi:
			chiudi("tempo scaduto")
			return
		if fino_a != "" and scena_adesso() == fino_a:
			await attendi(FPS * 2)
			raccogli_errori()
			chiudi("arrivato a " + fino_a.get_file())
			return
		controlla_blocco()
		if blocchi.size() >= 3:
			chiudi("bloccato tre volte")
			return
		if Transizioni.in_corso:
			continue
		if modo == "scimmia":
			await mossa_a_caso()
		else:
			await mossa_esplorando()
		passi += 1


func attendi(quanti: int) -> void:
	for i in maxi(quanti, 1):
		await get_tree().process_frame
		fotogrammi += 1


func pausa_fra_azioni() -> int:
	# una persona non preme sessanta volte al secondo; la scimmia quasi
	if modo == "scimmia":
		return dadi.randi_range(1, 18)
	return dadi.randi_range(8, 30)


# --- cosa c'e' da premere -----------------------------------------------------

func candidati() -> Array[Control]:
	# con la pausa aperta si guarda solo la pausa: quello che sta sotto il velo
	# non si puo' premere per costruzione, e contarlo «coperto» era rumore
	var trovati: Array[Control] = []
	raccogli((Pausa as Node) if Pausa.aperta else (get_tree().root as Node), trovati)
	return trovati


func raccogli(nodo: Node, dentro: Array[Control]) -> void:
	for figlio in nodo.get_children():
		if figlio == self:
			continue
		if figlio is CanvasItem and not (figlio as CanvasItem).visible:
			continue
		if figlio is CanvasLayer and not (figlio as CanvasLayer).visible:
			continue
		if figlio is Control and premibile(figlio as Control):
			dentro.append(figlio as Control)
		raccogli(figlio, dentro)


func premibile(c: Control) -> bool:
	if c.mouse_filter == Control.MOUSE_FILTER_IGNORE or not c.is_visible_in_tree():
		return false
	if c.size.x < 2.0 or c.size.y < 2.0:
		return false
	if not Rect2(Vector2.ZERO, Vector2(1280, 720)).has_point(centro_di(c)):
		return false
	if fuori_dal_ritaglio(c):
		return false   # scorso via in un elenco: prima si fa scorrere, poi si preme
	if c is BaseButton:
		return not (c as BaseButton).disabled
	if c is LineEdit:
		return (c as LineEdit).editable
	if c.mouse_filter != Control.MOUSE_FILTER_STOP:
		return false
	return not c.gui_input.get_connections().is_empty() or ha_input_suo(c)


func fuori_dal_ritaglio(c: Control) -> bool:
	var n := c.get_parent()
	while n != null:
		if n is Control and (n as Control).clip_contents:
			var dentro := n as Control
			var xf := dentro.get_viewport().get_final_transform() * dentro.get_global_transform_with_canvas()
			if not Rect2(xf.origin, dentro.size * xf.get_scale()).has_point(centro_di(c)):
				return true
		n = n.get_parent()
	return false


func centro_di(c: Control) -> Vector2:
	# dove sta DAVVERO il centro, nella finestra: con le rotazioni, le scale, il
	# CanvasLayer in cui vive, e l'ingrandimento di «Testo piu' grande» (che
	# scala tutto il disegno del 25%). Col solo get_global_rect() l'automa, a
	# testo grande, cliccava sempre la voce sopra quella che voleva
	return c.get_viewport().get_final_transform() * (c.get_global_transform_with_canvas() * (c.size * 0.5))


func ha_input_suo(c: Control) -> bool:
	var s := c.get_script() as Script
	while s != null:
		for m in s.get_script_method_list():
			if String(m.get("name", "")) == "_gui_input":
				return true
		s = s.get_base_script()
	return false


func nome_di(c: Control) -> String:
	if c is Button and (c as Button).text.strip_edges() != "":
		return (c as Button).text.strip_edges().replace("\n", " ")
	if c is LineEdit:
		return "campo \"%s\"" % (c as LineEdit).placeholder_text
	# i nomi fatti da Godot (@Button@17) cambiano a ogni apertura: per l'automa
	# sarebbe sempre una cosa mai vista, e ci resterebbe incollato
	var nome := String(c.name)
	return c.get_class() if nome.begins_with("@") else "%s %s" % [c.get_class(), nome]


func chiave_di(c: Control, schermata := "") -> String:
	# la cosa, DENTRO la schermata in cui sta. «ESC» nella pagina EXTRA e «ESC»
	# nella pagina del codice sono due uscite diverse: contate insieme, l'automa
	# girava in tondo fra le due per dieci minuti. Con una memoria per
	# schermata, su ogni pagina prova a turno ogni voce - e un giro cosi' prima
	# o poi le percorre tutte
	return "%s|%s" % [schermata, nome_di(c)]


func schermata_di(tutti: Array[Control]) -> String:
	var nomi: Array[String] = []
	for c in tutti:
		nomi.append(nome_di(c))
	nomi.sort()
	return "%s|%s|%s" % [scena_adesso().get_file(), GameState.nodo_corrente, ",".join(nomi)]


# --- esplora ------------------------------------------------------------------

func mossa_esplorando() -> void:
	if Pausa.aperta:
		passi_in_pausa += 1
		if passi_in_pausa > PASSI_IN_PAUSA:
			await premi_tasto(KEY_ESCAPE)
			return
	else:
		passi_in_pausa = 0
		# ogni tanto una pausa, come chi controlla il diario a meta' strada
		if dadi.randf() < 0.02 and scena_adesso() != "res://scenes/Menu.tscn":
			await premi_tasto(KEY_ESCAPE)
			return
	var tutti := candidati()
	var scelti: Array[Control] = []
	for c in tutti:
		if nome_di(c) in MAI_IN_ESPLORA:
			continue
		# la fuga si prova, ma di rado: altrimenti ogni scontro finiva li', e
		# l'automa non arrivava mai dove la storia continua
		if nome_di(c) == "FUGA" and dadi.randf() < 0.9:
			continue
		scelti.append(c)
	if scelti.is_empty():
		# niente da cliccare: forse e' un momento da tastiera (la raffica, le
		# collisioni) o una scritta che aspetta
		await premi_tasto(KEY_SPACE if dadi.randf() < 0.5 else KEY_ENTER)
		return
	# IN COMBATTIMENTO SI COMBATTE. Esplorando e basta, l'automa passava lo
	# scontro ad aprire liste e pause, e il primo goblin lo batteva ogni volta:
	# non era il goblin a essere difficile, era l'automa a non attaccare. Il
	# colpo normale e' un clic sulla creatura - la cosa che non e' un bottone
	if scena_adesso() == SCENA_COMBATTIMENTO and dadi.randf() < 0.6:
		var creature: Array[Control] = []
		for c in scelti:
			if not c is BaseButton:
				creature.append(c)
		if not creature.is_empty():
			await tocca(creature[dadi.randi_range(0, creature.size() - 1)])
			return
	var schermata := schermata_di(scelti)
	var meno := -1
	var pari: Array[Control] = []
	for c in scelti:
		var volte := int(toccati.get(chiave_di(c, schermata), 0))
		if meno < 0 or volte < meno:
			meno = volte
			pari.clear()
		if volte == meno:
			pari.append(c)
	# fra quelli toccati meno, uno a caso: altrimenti vince sempre il primo in
	# ordine d'albero e l'automa gioca sempre la stessa partita
	await tocca(pari[dadi.randi_range(0, pari.size() - 1)], schermata)


func tocca(c: Control, schermata := "") -> void:
	var chiave := chiave_di(c, schermata)
	# UN BOTTONE CHE STA ANCORA ENTRANDO NON SI MIRA. Le scelte arrivano
	# scivolando: il centro calcolato adesso, fra due fotogrammi e' altrove, e
	# il clic finiva sul contenitore - un «fantasma» che era solo fretta
	var prima := centro_di(c)
	await attendi(3)
	if not is_instance_valid(c) or centro_di(c).distance_to(prima) > 1.0:
		return
	toccati[chiave] = int(toccati.get(chiave, 0)) + 1
	var centro := centro_di(c)
	await muovi(centro)
	if not is_instance_valid(c):
		return
	var sotto := get_viewport().gui_get_hovered_control()
	if sotto != c and (sotto == null or not c.is_ancestor_of(sotto)):
		coperti[chiave] = int(coperti.get(chiave, 0)) + 1
		if int(coperti[chiave]) == 12:
			fantasmi[chiave] = "coperto da %s" % (nome_di(sotto) if sotto != null else "niente")
		return
	ultima_azione = "clic su \"%s\" (%s)" % [nome_di(c), scena_adesso().get_file()]
	racconta()
	await clic(centro)
	if is_instance_valid(c) and c is LineEdit and (c as LineEdit).text == "" and dadi.randf() < 0.6:
		await scrivi("Bru")
		await premi_tasto(KEY_ENTER)


# --- scimmia ------------------------------------------------------------------

func mossa_a_caso() -> void:
	var dado := dadi.randf()
	if dado < 0.45:
		var tutti := candidati()
		var buoni: Array[Control] = []
		for c in tutti:
			if nome_di(c) not in MAI:
				buoni.append(c)
		if not buoni.is_empty():
			var c: Control = buoni[dadi.randi_range(0, buoni.size() - 1)]
			ultima_azione = "clic su \"%s\"" % nome_di(c)
			await clic(centro_di(c))
			return
	if dado < 0.7:
		var dove := Vector2(dadi.randf_range(0, 1280), dadi.randf_range(0, 720))
		ultima_azione = "clic a vuoto in %s" % dove
		await clic(dove, dadi.randf() < 0.15)
		return
	if dado < 0.78:
		# martellare: la stessa cosa sei volte di fila, subito
		var dove := Vector2(dadi.randf_range(0, 1280), dadi.randf_range(0, 720))
		ultima_azione = "martello in %s" % dove
		for i in 6:
			await clic(dove)
		return
	if dado < 0.82:
		ultima_azione = "rotella"
		await rotella(Vector2(dadi.randf_range(0, 1280), dadi.randf_range(0, 720)), dadi.randf() < 0.5)
		return
	var tasti: Array[Key] = [KEY_ENTER, KEY_SPACE, KEY_ESCAPE, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT,
			KEY_TAB, KEY_A, KEY_Z]
	await premi_tasto(tasti[dadi.randi_range(0, tasti.size() - 1)])


# --- le mani ------------------------------------------------------------------

func muovi(dove: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = dove
	m.global_position = dove
	Input.parse_input_event(m)
	await attendi(1)


func clic(dove: Vector2, destro := false) -> void:
	await muovi(dove)
	var giu := InputEventMouseButton.new()
	giu.button_index = MOUSE_BUTTON_RIGHT if destro else MOUSE_BUTTON_LEFT
	giu.position = dove
	giu.global_position = dove
	giu.pressed = true
	Input.parse_input_event(giu)
	await attendi(dadi.randi_range(1, 4))
	var su := giu.duplicate() as InputEventMouseButton
	su.pressed = false
	Input.parse_input_event(su)
	await attendi(1)


func rotella(dove: Vector2, verso_giu: bool) -> void:
	await muovi(dove)
	for premuto in [true, false]:
		var r := InputEventMouseButton.new()
		r.button_index = MOUSE_BUTTON_WHEEL_DOWN if verso_giu else MOUSE_BUTTON_WHEEL_UP
		r.position = dove
		r.global_position = dove
		r.pressed = premuto
		Input.parse_input_event(r)
	await attendi(1)


func premi_tasto(tasto: Key) -> void:
	ultima_azione = "tasto %s (%s)" % [OS.get_keycode_string(tasto), scena_adesso().get_file()]
	racconta()
	for premuto in [true, false]:
		var k := InputEventKey.new()
		k.keycode = tasto
		k.physical_keycode = tasto
		k.pressed = premuto
		Input.parse_input_event(k)
		await attendi(dadi.randi_range(1, 3))


func scrivi(testo: String) -> void:
	for lettera in testo:
		for premuto in [true, false]:
			var k := InputEventKey.new()
			k.keycode = OS.find_keycode_from_string(lettera.to_upper())
			k.unicode = lettera.unicode_at(0)
			k.pressed = premuto
			Input.parse_input_event(k)
			await attendi(1)


# --- gli occhi ----------------------------------------------------------------

func scena_adesso() -> String:
	var s := get_tree().current_scene
	return s.scene_file_path if s != null else ""


func annota_dove() -> void:
	scene_viste[scena_adesso()] = true
	if GameState.nodo_corrente != "":
		nodi_visti[GameState.nodo_corrente] = true


func firma() -> String:
	# tutto quello che un giocatore vede cambiare: la scena, il punto della
	# storia, il testo nel box, le voci premibili, la pausa, la vita in campo
	var pezzi: Array[String] = [scena_adesso(), GameState.nodo_corrente, str(Pausa.aperta)]
	var scena := get_tree().current_scene
	if scena != null:
		var box := scena.get_node_or_null("%BoxTesto")
		if box != null and box.get("testo") is RichTextLabel:
			pezzi.append((box.get("testo") as RichTextLabel).get_parsed_text().left(80))
			pezzi.append(str((box.get("testo") as RichTextLabel).visible_characters))
		if scena.has_method("fase_adesso"):
			pezzi.append(String(scena.call("fase_adesso")))
			var in_campo: Variant = scena.get("combattenti")
			if in_campo is Array:
				for chi: Variant in in_campo:
					if chi is Dictionary:
						pezzi.append(str((chi as Dictionary).get("hp", "")))
	for c in candidati():
		pezzi.append(nome_di(c))
	return "¦".join(pezzi)


func controlla_blocco() -> void:
	var adesso := firma()
	if adesso != firma_ultima:
		firma_ultima = adesso
		firma_da = fotogrammi
		return
	if (fotogrammi - firma_da) / float(FPS) < BLOCCO_SECONDI:
		return
	var voci: Array[String] = []
	for c in candidati():
		voci.append(nome_di(c))
	var testo := "BLOCCO dopo %s: %s, nodo \"%s\", fermo da %d s. Ultima azione: %s. Premibili: %s" % [
			orologio(), scena_adesso().get_file(), GameState.nodo_corrente, int(BLOCCO_SECONDI),
			ultima_azione, ", ".join(voci) if not voci.is_empty() else "nessuno"]
	blocchi.append(testo)
	print(testo)
	scatta("blocco")
	firma_da = fotogrammi


func raccogli_errori() -> void:
	if registro == null:
		return
	for e in registro.prendi():
		var testo := String(e["testo"])
		if int(e["tipo"]) == Logger.ERROR_TYPE_WARNING:
			avvisi[testo] = int(avvisi.get(testo, 0)) + 1
			continue
		e["quando"] = orologio()
		e["scena"] = scena_adesso().get_file()
		e["nodo"] = GameState.nodo_corrente
		e["azione"] = ultima_azione
		errori.append(e)
		print("ERRORE dopo %s in %s, nodo \"%s\", dopo %s:\n  %s\n  %s\n%s" % [e["quando"], e["scena"],
				e["nodo"], ultima_azione, testo, e["dove"], e["pila"]])
		scatta("errore")


func scatta(perche: String) -> void:
	if not con_finestra or scatti >= 40:
		return
	scatti += 1
	await RenderingServer.frame_post_draw
	var immagine := get_viewport().get_texture().get_image()
	var nome := "%s_%d_%02d_%s.png" % [modo, seme, scatti, perche]
	immagine.save_png(ProjectSettings.globalize_path(CARTELLA_SCATTI + nome))
	print("  scatto: scatti/automa/" + nome)


func racconta() -> void:
	# il diario delle azioni: con DIARIO=1 nell'ambiente, una riga per azione
	if OS.has_environment("DIARIO"):
		print("  %s %s · nodo \"%s\"" % [orologio(), ultima_azione, GameState.nodo_corrente])


func orologio() -> String:
	var s := int(fotogrammi / float(FPS))
	return "%d:%02d" % [int(s / 60.0), s % 60]


func chiudi(perche: String) -> void:
	finito = true
	raccogli_errori()
	# LA CRESCITA SI LEGGE ANCHE DA QUI, prima di rimettere a posto: finche'
	# nessuno schermo spende l'hype, la partita finisce al livello 1 con l'hype
	# in tasca e le azioni mai convertite in stat (docs/albero.md)
	var in_attesa := 0
	for azione in GameState.contatori:
		in_attesa += int(GameState.contatori[azione])
	var crescita := "  crescita: livello %d · hype guadagnato %d, da spendere %d · azioni mai convertite %d" \
			% [GameState.livello_di(GameState.id_protagonista), GameState.hype_accumulato,
			GameState.hype_disponibile, in_attesa]
	rimetti_a_posto()
	print("")
	print("AUTOMA FINITO (%s) dopo %s di gioco e %d azioni" % [perche, orologio(), passi])
	print("  scene viste: %s" % ", ".join(scene_viste.keys().map(func(s: String) -> String: return s.get_file())))
	print("  punti della storia visti: %d" % nodi_visti.size())
	print("  cose diverse toccate: %d" % toccati.size())
	print(crescita)
	print("  errori: %d · blocchi: %d · fantasmi: %d" % [errori.size(), blocchi.size(), fantasmi.size()])
	for f in fantasmi:
		print("  FANTASMA %s: %s" % [f, fantasmi[f]])
	var elenco := avvisi.keys()
	elenco.sort()
	for a in elenco:
		print("  avviso x%d: %s" % [int(avvisi[a]), a])
	print("ESITO AUTOMA: %s" % ("PULITO" if errori.is_empty() and blocchi.is_empty() else "DA GUARDARE"))
	get_tree().quit(0 if errori.is_empty() and blocchi.is_empty() else 1)
