extends Node

# FOTOGRAFA UNA SCHERMATA E SE NE VA.
#
# Le prove misurano quello che si puo' misurare: che un numero sia giusto, che
# una porta si apra, che uno scontro finisca. Non sanno dire se una cosa e'
# VENUTA come doveva venire - e da quando l'interfaccia la disegna Bru e io la
# ricostruisco, quella e' esattamente la domanda che conta.
#
# Quindi: apri una scena, aspetta che si assesti, salva un PNG. Non e' una
# prova e non fallisce mai; e' un paio d'occhi.
#
#   ./prove/scatto.sh dialogo
#   ./prove/scatto.sh menu
#
# Vuole un display vero (xvfb-run basta): senza finestra Godot non disegna, e
# uno scatto di un rendering che non e' avvenuto sarebbe nero e bugiardo.

const CARTELLA := "res://scatti/"
const NastroOltre := preload("res://prove/NastroOltre.gd")
const FOTOGRAMMI_DI_ASSESTAMENTO := 45

func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	var quale := String(argomenti[0]) if argomenti.size() > 0 else "dialogo"
	var etichetta := quale if argomenti.size() < 2 else "%s_%s" % [quale, argomenti[1]]
	# TESTO_GRANDE=1 ./prove/scatto.sh ...: la schermata come la vede chi ha
	# acceso «Testo piu' grande» (lo schermo utile scende a 1024x576)
	if OS.has_environment("TESTO_GRANDE"):
		Impostazioni.testo_grande = true
		Impostazioni.applica_scala_testo()
		etichetta += "_testo_grande"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARTELLA))
	await prepara(quale)
	# la rottura si assesta da sola dentro prepara(): aspettare altri quaranta
	# fotogrammi qui vorrebbe dire fotografare il vetro quando e' gia' svanito
	# L'ECG SI FOTOGRAFA SUBITO. Lo scontro gira in tempo reale e decidi_faccia
	# rimette il parlato a ogni fotogramma: aspettare l'assestamento vuol dire
	# fotografare il box del testo. Successo due volte prima che lo capissi.
	if not quale in ["rottura", "nastro", "grazia", "racconto", "scritta", "caratteri", "dialoghi", "nastri", "nomi_eleganti", "nome_in_scena", "laboratorio", "indica"] and not quale.begins_with("ecg"):
		await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
	salva(etichetta)
	get_tree().quit()

func proiezione_piena(dove: String) -> void:
	GameState.nuova_partita()
	GameState.imposta_flag("tutorial_completato")
	if dove == "plastico":
		GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
		for id_stanza: String in ["inizio", "banchetto", "pianura", "albero", "masso", "bivio"]:
			GameState.sblocca_stanza(id_stanza)
			GameState.nodi_visitati.append(id_stanza)
		GameState.nodo_corrente = "masso"
		var pianta: MappaZona = load("res://scenes/MappaZona.tscn").instantiate()
		add_child(pianta)
		await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		pianta.plastico.evidenzia("albero")
		return
	var schermata: Control
	if dove in ["vuoto", "sonde"]:
		for punto: Dictionary in GameState.carica_mappa().get("punti", []):
			if String(punto.get("id", "")) == "carnivalz_del_bosco":
				GameState.punto_mappa_corrente = punto
		schermata = load("res://scenes/Vuoto.tscn").instantiate()
	else:
		schermata = load("res://scenes/Mappa.tscn").instantiate()
	add_child(schermata)
	var p: Proiezione = schermata.get("proiezione")
	p.cursore_finto = Vector2(1, 1)
	await attendi(240)
	# si punta il corpo piu' vicino al centro della griglia, perche' la scheda
	# si riempia come quando ci si passa sopra col mouse
	var meglio := ""
	var dista := INF
	for c: Dictionary in p.corpi:
		var s := p.sullo_schermo(c["pos"])
		if float(c["apertura"]) >= 0.6 and s.x < SchedaProiezione.X - 40.0 and s.distance_to(Vector2(480, 380)) < dista:
			dista = s.distance_to(Vector2(480, 380))
			meglio = String(c["id"])
	if dove == "sonde":
		# "proiezione sonde": le sonde hanno trovato qualcosa su due pianeti, e
		# si punta il primo
		for id_pianeta: String in ["pianeta_esempio_uno", "pianeta_esempio_uno", "pianeta_esempio_quattro"]:
			Sonde.trova(id_pianeta)
		meglio = "pianeta_esempio_uno"
	p.punta(meglio)
	if dove == "sonde":
		(p.corpo(meglio)["bottone"] as Button).pressed.emit()   # scelto: il bottone dice «Estrai le risorse»
	await attendi(150)


func partite_finte() -> void:
	# due partite vere, scritte come le scrive il gioco, per vedere il menu
	# com'e' dopo qualche ora di gioco invece che la prima volta
	for dati: Array in [[2, "Bru", 4, 3030], [4, "Veronica", 2, 450]]:
		GameState.nuova_partita()
		GameState.imposta_nome_protagonista(String(dati[1]))
		GameState.livelli[GameState.id_protagonista] = int(dati[2])
		GameState.tazo = int(dati[3])
		GameState.salva_slot(int(dati[0]))
	GameState.nuova_partita()

func pellicola(dove: String) -> void:
	# LA COREOGRAFIA IN UN FOGLIO SOLO: dodici fotogrammi, uno ogni tre (50 ms
	# con --fixed-fps 60, che rende il tempo del gioco esatto anche se la
	# finestra finta disegna lenta), in una griglia quattro per tre. Si legge
	# da sinistra a destra e dall'alto in basso.
	var foglio := Image.create(1280, 540, false, Image.FORMAT_RGBA8)
	for i in 12:
		await RenderingServer.frame_post_draw
		var fotogramma := get_viewport().get_texture().get_image()
		fotogramma.convert(Image.FORMAT_RGBA8)
		fotogramma.resize(320, 180, Image.INTERPOLATE_BILINEAR)
		foglio.blit_rect(fotogramma, Rect2i(0, 0, 320, 180), Vector2i((i % 4) * 320, floori(i / 4.0) * 180))
		await attendi(2)
	foglio.save_png(ProjectSettings.globalize_path(dove))
	print("pellicola salvata: %s" % dove)

func ferma_dopo(millesimi: int) -> void:
	# il tempo del gioco si ferma quando ne sono passati tanti: i tween e le
	# molle restano dove sono, e lo scatto prende quell'istante. Preciso a un
	# fotogramma, che per guardare una coreografia basta
	var partenza := Time.get_ticks_msec()
	while Time.get_ticks_msec() - partenza < millesimi:
		await get_tree().process_frame
	Engine.time_scale = 0.0

const BATTUTA_LAB := "Non voglio sentire scuse signorino, la prossima volta che ti vedo ridotto così vi dovrò fare una bella lavata di capo!"
const PROVE_LAB := [
	{"nome": "Shantell Sans, formale", "file": "shantellsans/ShantellSans[BNCE,INFM,SPAC,wght].ttf",
		"assi": {"wght": 450, "INFM": 0, "BNCE": 0}},
	{"nome": "lo stesso, informale e saltellante (assi INFM e BNCE)", "file": "shantellsans/ShantellSans[BNCE,INFM,SPAC,wght].ttf",
		"assi": {"wght": 560, "INFM": 100, "BNCE": 100}},
	{"nome": "Bricolage Grotesque, stretto e nero (assi wdth e wght)", "file": "bricolagegrotesque/BricolageGrotesque[opsz,wdth,wght].ttf",
		"assi": {"wght": 760, "wdth": 75}, "corpo": 26},
	{"nome": "lo stesso, largo, leggero e spaziato", "file": "bricolagegrotesque/BricolageGrotesque[opsz,wdth,wght].ttf",
		"assi": {"wght": 360, "wdth": 100}, "spazio": 2},
	{"nome": "Special Elite, inclinato", "file": "../apache/specialelite/SpecialElite-Regular.ttf", "inclina": 0.2},
	{"nome": "Special Elite, lettere ritagliate (effetto a codice)", "file": "../apache/specialelite/SpecialElite-Regular.ttf",
		"effetto": "ritaglio", "corpo": 26},
	{"nome": "Rubik, con l'ombra cremisi", "file": "rubik/Rubik[wght].ttf", "assi": {"wght": 620}, "ombra": true},
	{"nome": "Shantell Sans, che bolle come un disegno animato", "file": "shantellsans/ShantellSans[BNCE,INFM,SPAC,wght].ttf",
		"assi": {"wght": 520, "INFM": 60, "BNCE": 40}, "effetto": "bollore"},
	{"nome": "Rubik, le parole che recitano", "file": "rubik/Rubik[wght].ttf", "assi": {"wght": 500},
		"testo": "Non voglio sentire [shake rate=24 level=7]scuse[/shake] signorino, la prossima volta che ti vedo ridotto così vi dovrò fare una [wave amp=40 freq=5][color=#c8102e]bella lavata di capo![/color][/wave]"},
]


class Ritaglio extends RichTextEffect:
	# ogni lettera un po' storta e un po' fuori riga, sempre la stessa: lettere
	# ritagliate e incollate. Con "passo" > 0 cambiano ogni tanto: il bollore
	# dei disegni animati a mano, dove la linea non sta mai ferma
	var bbcode := "ritaglio"
	var passo := 0.0
	var quanto := 1.0

	func _process_custom_fx(fx: CharFXTransform) -> bool:
		var tempo := floori(fx.elapsed_time / passo) if passo > 0.0 else 0
		var caso := RandomNumberGenerator.new()
		caso.seed = hash(Vector2i(fx.range.x, tempo))
		var angolo := caso.randf_range(-0.1, 0.1) * quanto
		var scala := 1.0 + caso.randf_range(-0.06, 0.08) * quanto
		fx.transform = fx.transform * Transform2D(angolo, Vector2(scala, scala), 0.0,
				Vector2(0.0, caso.randf_range(-2.5, 2.5) * quanto))
		return true


class StrappoDiProva extends PanelContainer:
	# lo stesso nastro rosa, ma con le due estremita' strappate a mano, come un
	# pezzo di scotch di carta vero: il rettangolo liscio si legge digitale
	var colore := Color.PINK
	func _draw() -> void:
		# lo strappo: tanti morsi piccoli e irregolari, non denti uguali. Un
		# passeggio casuale che resta fra 0 e 9 pixel dal bordo, ogni 2,5
		var caso := RandomNumberGenerator.new()
		caso.seed = 7
		var destra := PackedVector2Array()
		var sinistra := PackedVector2Array()
		var d := 4.0
		var s := 4.0
		var y := 0.0
		while y <= size.y + 0.1:
			d = clampf(d + caso.randf_range(-2.6, 2.6), 0.0, 9.0)
			s = clampf(s + caso.randf_range(-2.6, 2.6), 0.0, 9.0)
			destra.append(Vector2(size.x - d, y))
			sinistra.append(Vector2(s, y))
			y += 2.5
		sinistra.reverse()
		draw_colored_polygon(destra + sinistra, colore)


class Rombi extends Control:
	# i rombi d'arlecchino dell'esempio di Bru: una fila chiara e una scura, e
	# dall'alto al basso il grigio sfuma nel lilla
	func _draw() -> void:
		var passo := Vector2(40.0, 56.0)
		for j in int(size.y / (passo.y * 0.5)) + 3:
			var t := clampf(j * passo.y * 0.5 / maxf(size.y, 1.0), 0.0, 1.0)
			var tinta := (Color("#bdbdbd").lerp(Color("#c3bbe2"), t)) if j % 2 == 0 \
					else (Color("#9e9e9e").lerp(Color("#a89fd0"), t))
			for i in int(size.x / passo.x) + 3:
				var c := Vector2(i * passo.x + (passo.x * 0.5 if j % 2 == 1 else 0.0), j * passo.y * 0.5)
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -passo.y * 0.5),
						c + Vector2(passo.x * 0.5, 0), c + Vector2(0, passo.y * 0.5),
						c + Vector2(-passo.x * 0.5, 0)]), tinta)


func nome_composto(scritta: RichTextLabel, prova: Dictionary, colore: Color) -> void:
	# IL NOME FATTO A PEZZI, ognuno col suo carattere: la «V» gotica e
	# «eronica» in Cinzel, come una capolettera di un libro di fiabe
	scritta.clear()
	for parte: Dictionary in prova.get("parti", []):
		var corpo := int(parte.get("corpo", 40))
		var misurato := carattere_con_misure(String(parte.file), corpo, 400)
		var variante: FontVariation = misurato[0]
		var assi: Dictionary = parte.get("assi", {})
		if not assi.is_empty():
			var opentype := {}
			for asse: String in assi:
				opentype[TextServerManager.get_primary_interface().name_to_tag(asse)] = assi[asse]
			variante.variation_opentype = opentype
		variante.spacing_glyph = int(parte.get("spazio", 0))
		# le varianti che il carattere ha dentro: "swsh" lo svolazzo, "fina" le
		# forme finali, "dlig" le legature rare, "smcp" il maiuscoletto...
		var tratti := {}
		for tratto: String in (parte.get("tratti", {}) as Dictionary):
			tratti[TextServerManager.get_primary_interface().name_to_tag(tratto)] = int(parte.tratti[tratto])
		variante.opentype_features = tratti
		scritta.push_font(variante, corpo)
		scritta.push_color(Stile.colore("accento") if String(parte.get("colore", "")) == "accento" else colore)
		if bool(parte.get("storto", false)):
			# ogni lettera un po' fuori posto, sempre lo stesso: il gotico storto
			scritta.push_customfx(Ritaglio.new(), {})
		scritta.add_text(String(parte.get("testo", "")))
		if bool(parte.get("storto", false)):
			scritta.pop()
		scritta.pop()
		scritta.pop()


func scritta_del_nome() -> RichTextLabel:
	var scritta := RichTextLabel.new()
	scritta.bbcode_enabled = false
	scritta.fit_content = true
	scritta.autowrap_mode = TextServer.AUTOWRAP_OFF
	scritta.scroll_active = false
	scritta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return scritta


func box_elegante(scritta: RichTextLabel, radice_ofl: String) -> Control:
	# UN BOX COME L'ESEMPIO DI BRU, fatto a codice solo per provarci sopra i
	# nomi: rombi d'arlecchino, bordo nero arrotondato, due volute nere sugli
	# angoli (i fregi di EB Garamond), e la targhetta color pesca in cima
	var tutto := Control.new()
	tutto.size = Vector2(600, 196)
	var alto := 46.0
	var dentro := Rect2(Vector2(0, alto), Vector2(600, 150))
	var maschera := Panel.new()
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color("#aaa8b8")
	fondo.set_corner_radius_all(14)
	maschera.add_theme_stylebox_override("panel", fondo)
	maschera.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	maschera.position = dentro.position
	maschera.size = dentro.size
	tutto.add_child(maschera)
	var rombi := Rombi.new()
	rombi.size = dentro.size
	maschera.add_child(rombi)
	var bordo := Panel.new()
	var linea := StyleBoxFlat.new()
	linea.draw_center = false
	linea.border_color = Color.BLACK
	linea.set_border_width_all(5)
	linea.set_corner_radius_all(14)
	bordo.add_theme_stylebox_override("panel", linea)
	bordo.position = dentro.position
	bordo.size = dentro.size
	tutto.add_child(bordo)
	var fregi := FontFile.new()
	fregi.load_dynamic_font(radice_ofl.path_join("ebgaramond/EBGaramond[wght].ttf"))
	for dove: Array in [["❦", Vector2(528, alto - 34), 0.0], ["❧", Vector2(-6, alto + 92), 0.0]]:
		var fregio := Label.new()
		fregio.text = String(dove[0])
		fregio.add_theme_font_override("font", fregi)
		fregio.add_theme_font_size_override("font_size", 62)
		fregio.add_theme_color_override("font_color", Color.BLACK)
		fregio.position = dove[1]
		tutto.add_child(fregio)
	var battuta := Label.new()
	battuta.text = "Non voglio sentire scuse, signorino: la prossima volta che ti vedo ridotto così..."
	battuta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	battuta.add_theme_font_override("font", Caratteri.dialoghi())
	battuta.add_theme_font_size_override("font_size", 24)
	battuta.add_theme_color_override("font_color", Color("#1f1b2b"))
	battuta.position = Vector2(30, alto + 26)
	battuta.size = Vector2(470, 90)
	tutto.add_child(battuta)
	var targhetta := PanelContainer.new()
	var pesca := StyleBoxFlat.new()
	pesca.bg_color = Color("#e6c3a0")
	pesca.set_corner_radius_all(12)
	pesca.content_margin_left = 22
	pesca.content_margin_right = 60
	pesca.content_margin_top = 0
	pesca.content_margin_bottom = 2
	pesca.shadow_color = Color(0, 0, 0, 0.25)
	pesca.shadow_size = 3
	targhetta.add_theme_stylebox_override("panel", pesca)
	targhetta.position = Vector2(0, 0)
	targhetta.custom_minimum_size = Vector2(0, alto + 10)
	scritta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	targhetta.add_child(scritta)
	tutto.add_child(targhetta)
	# il fiore chiaro sulla destra della targhetta, come nell'esempio
	var fiore := Label.new()
	fiore.name = "Fiore"
	fiore.text = "❦"
	fiore.add_theme_font_override("font", fregi)
	fiore.add_theme_font_size_override("font_size", 44)
	fiore.add_theme_color_override("font_color", Color("#f3dcc4"))
	fiore.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutto.add_child(fiore)
	return tutto


func nastro_liscio() -> StyleBoxFlat:
	# il nastro rosa di prima, liscio: quello su cui si sono provati i nomi
	var stile := StyleBoxFlat.new()
	stile.bg_color = Stile.colore("nastro")
	stile.content_margin_left = 30
	stile.content_margin_right = 30
	stile.content_margin_top = 4
	stile.content_margin_bottom = 6
	return stile


func nomi_in_scena(prove: Array) -> void:
	# UN NOME PER SCHERMATA, NON UN CATALOGO. Bru, sui cataloghi: «non sono
	# timeless e sanno di ai e pigrizia». Ogni prova (lo stesso json di
	# nomi_eleganti) sul nastro della scena vera, Reika in infermeria, a
	# schermo intero: nome_in_scena_<n>.png
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	GameState.imposta_flag("rientro_infermeria")
	GameState.nodo_corrente = "infermeria_risveglio"
	IngressoNodo.ultimo_esito = {}
	var scena: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(scena)
	await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
	for clic in 5:
		scena._su_avanza()
		await attendi(2)
		scena._su_avanza()
		await attendi(2)
	for attesa in 200:
		if scena.box.sta_scrivendo:
			scena.box.completa()
		await attendi(1)
		if attesa > 40 and not scena.box.sta_scrivendo:
			break
	scena.nastro.visible = false
	var nastro: PanelContainer = null
	for n in prove.size():
		var prova: Dictionary = prove[n]
		if nastro != null:
			nastro.queue_free()
		nastro = StrappoDiProva.new() if String(prova.get("nastro", "")) == "strappato" else PanelContainer.new()
		var liscio := nastro_liscio()
		if nastro is StrappoDiProva:
			var vuoto := StyleBoxEmpty.new()
			for lato in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
				vuoto.set_content_margin(lato, liscio.get_content_margin(lato))
			nastro.add_theme_stylebox_override("panel", vuoto)
			(nastro as StrappoDiProva).colore = liscio.bg_color
		else:
			nastro.add_theme_stylebox_override("panel", liscio)
		var scritta := scritta_del_nome()
		nastro.add_child(scritta)
		scena.add_child(nastro)
		nastro.rotation = Stile.angolo("inclinazione_nastro")
		var inchiostro := Color(String(prova.get("inchiostro", "#1b1417")))
		if bool(prova.get("inchiostro_steso", false)):
			# l'inchiostro che si allarga appena nella carta: un alone dello
			# stesso colore, trasparente, tutto intorno alla lettera
			scritta.add_theme_color_override("font_shadow_color", Color(inchiostro, 0.28))
			scritta.add_theme_constant_override("shadow_offset_x", 0)
			scritta.add_theme_constant_override("shadow_offset_y", 0)
			scritta.add_theme_constant_override("shadow_outline_size", 2)
		nome_composto(scritta, prova, inchiostro)
		nastro.size = Vector2.ZERO
		await attendi(4)
		nastro.pivot_offset = Vector2(0.0, nastro.size.y * 0.5)
		nastro.position = Vector2(Stile.forma("cornice") * 0.6, scena.box.position.y - nastro.size.y + 6)
		await attendi(3)
		await RenderingServer.frame_post_draw
		var foto := get_viewport().get_texture().get_image()
		foto.save_png(ProjectSettings.globalize_path(CARTELLA + "nome_in_scena_%d.png" % (n + 1)))
		print("scatto salvato: %snome_in_scena_%d.png  (%s)" % [CARTELLA, n + 1, (prove[n] as Dictionary).nome])


func nomi_a_confronto(prove: Array) -> void:
	# I NOMI, SECONDA SERIE. Bru: «per i nomi non mi piace nessuno dei font,
	# abbiamo bisogno di qualcosa di piu' originale e che rimane in testa», con
	# l'esempio di un box elegante. Ogni prova (un json: [{nome, parti: [{file,
	# corpo, assi, testo, colore}]}]) due volte: sul nastro rosa com'e' nel
	# gioco, e sulla targhetta di un box come quello dell'esempio
	await apri_dialogo(nodo_di_prova())
	await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
	var schermata: Node = get_child(0)
	schermata.nastro.visible = false
	var nastro := PanelContainer.new()
	nastro.add_theme_stylebox_override("panel", nastro_liscio())
	var sul_nastro := scritta_del_nome()
	nastro.add_child(sul_nastro)
	schermata.add_child(nastro)
	nastro.rotation = Stile.angolo("inclinazione_nastro")
	var cartello := Label.new()
	cartello.position = Vector2(330, 575)
	cartello.add_theme_font_size_override("font_size", 20)
	cartello.add_theme_color_override("font_color", Color.BLACK)
	schermata.add_child(cartello)
	var sopra := CanvasLayer.new()
	sopra.layer = 200
	add_child(sopra)
	var buio := ColorRect.new()
	buio.color = Color("#15131f")
	buio.size = Vector2(640, 280)
	sopra.add_child(buio)
	var sulla_targhetta := scritta_del_nome()
	var radice_ofl := String((prove[0] as Dictionary).parti[0].file).get_base_dir().get_base_dir()
	var elegante := box_elegante(sulla_targhetta, radice_ofl)
	elegante.position = Vector2(20, 44)
	sopra.add_child(elegante)
	var cartello_elegante := Label.new()
	cartello_elegante.position = Vector2(24, 244)
	cartello_elegante.add_theme_font_size_override("font_size", 18)
	cartello_elegante.add_theme_color_override("font_color", Color("#d8d4e8"))
	sopra.add_child(cartello_elegante)
	for f in ceili(prove.size() / 10.0):
		var quanti := mini(10, prove.size() - f * 10)
		var foglio := Image.create(1280, 272 * quanti, false, Image.FORMAT_RGBA8)
		for k in quanti:
			var prova: Dictionary = prove[f * 10 + k]
			nome_composto(sul_nastro, prova, Stile.colore("nastro_testo"))
			nome_composto(sulla_targhetta, prova, Color(String(prova.get("inchiostro", "#3b2418"))))
			# la targhetta dell'esempio e' pesca; una prova puo' chiederne un'altra,
			# per esempio nera col bordo cremisi per i gotici scuri
			var pelle := (sulla_targhetta.get_parent() as Control).get_theme_stylebox("panel") as StyleBoxFlat
			pelle.bg_color = Color(String(prova.get("targhetta", "#e6c3a0")))
			pelle.border_color = Color(String(prova.get("bordo", "#00000000")))
			pelle.set_border_width_all(2 if prova.has("bordo") else 0)
			(elegante.get_node("Fiore") as Label).add_theme_color_override("font_color",
					Color(String(prova.get("fiore", "#f3dcc4"))))
			cartello.text = String(prova.nome)
			cartello_elegante.text = String(prova.nome)
			nastro.size = Vector2.ZERO
			(sulla_targhetta.get_parent() as Control).size = Vector2.ZERO
			await attendi(4)
			nastro.pivot_offset = Vector2(0.0, nastro.size.y * 0.5)
			nastro.position = Vector2(Stile.forma("cornice") * 0.6, schermata.box.position.y - nastro.size.y + 6)
			# la targhetta cresce verso l'alto, come nell'esempio: il fondo resta
			# appoggiato sul bordo del box, e un nome alto non copre la battuta
			var targhetta := sulla_targhetta.get_parent() as Control
			targhetta.position.y = 56.0 - targhetta.size.y
			(elegante.get_node("Fiore") as Control).position = Vector2(targhetta.size.x - 54, targhetta.position.y - 6)
			await attendi(3)
			await RenderingServer.frame_post_draw
			var foto := get_viewport().get_texture().get_image()
			foto.convert(Image.FORMAT_RGBA8)
			foglio.blit_rect(foto, Rect2i(0, 368, 640, 272), Vector2i(0, 272 * k))
			foglio.blit_rect(foto, Rect2i(0, 0, 640, 272), Vector2i(640, 272 * k))
		foglio.save_png(ProjectSettings.globalize_path(CARTELLA + "nomi_eleganti_%d.png" % (f + 1)))
		print("foglio salvato: %snomi_eleganti_%d.png" % [CARTELLA, f + 1])


func laboratorio(radice: String, prove: Array) -> void:
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	GameState.imposta_flag("rientro_infermeria")
	GameState.nodo_corrente = "infermeria_risveglio"
	IngressoNodo.ultimo_esito = {}
	var parla: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(parla)
	await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
	for clic in 5:
		parla._su_avanza()
		await attendi(2)
		parla._su_avanza()
		await attendi(2)
	await attendi(30)
	parla.box.completa()
	var testo: RichTextLabel = parla.box.testo
	var ritaglio := Ritaglio.new()
	var bollore := Ritaglio.new()
	bollore.bbcode = "bollore"
	bollore.passo = 0.13
	bollore.quanto = 0.6
	testo.install_effect(ritaglio)
	testo.install_effect(bollore)
	var cartello := Label.new()
	cartello.position = Vector2(300, 432)
	cartello.add_theme_font_size_override("font_size", 26)
	cartello.add_theme_color_override("font_color", Color.WHITE)
	parla.add_child(cartello)
	var righe_per_foglio := 5
	for f in ceili(prove.size() / float(righe_per_foglio)):
		var quante := mini(righe_per_foglio, prove.size() - f * righe_per_foglio)
		var foglio := Image.create(1280, 300 * quante, false, Image.FORMAT_RGBA8)
		for k in quante:
			var prova: Dictionary = prove[f * righe_per_foglio + k]
			prepara_prova_lab(testo, radice, prova)
			cartello.text = "%d  %s" % [f * righe_per_foglio + k + 1, String(prova.nome)]
			await attendi(8)
			await RenderingServer.frame_post_draw
			var foto := get_viewport().get_texture().get_image()
			foto.convert(Image.FORMAT_RGBA8)
			foglio.blit_rect(foto, Rect2i(0, 420, 1280, 300), Vector2i(0, 300 * k))
		foglio.save_png(ProjectSettings.globalize_path(CARTELLA + "laboratorio_%d.png" % (f + 1)))
		print("foglio salvato: %slaboratorio_%d.png" % [CARTELLA, f + 1])


func prepara_prova_lab(testo: RichTextLabel, radice: String, prova: Dictionary) -> void:
	var misurato := carattere_con_misure(radice.path_join(String(prova.file)), int(prova.get("corpo", 24)), 400)
	var variante: FontVariation = misurato[0]
	var assi: Dictionary = prova.get("assi", {})
	var opentype := {}
	for asse: String in assi:
		opentype[TextServerManager.get_primary_interface().name_to_tag(asse)] = assi[asse]
	if not opentype.is_empty():
		variante.variation_opentype = opentype
	variante.spacing_glyph = int(prova.get("spazio", 0))
	variante.variation_transform = Transform2D(Vector2(1, 0), Vector2(-float(prova.get("inclina", 0.0)), 1), Vector2.ZERO)
	for chiave in ["normal_font", "italics_font", "bold_font"]:
		testo.add_theme_font_override(chiave, variante)
	for chiave in ["normal_font_size", "italics_font_size", "bold_font_size"]:
		testo.add_theme_font_size_override(chiave, misurato[1])
	var ombra := bool(prova.get("ombra", false))
	testo.add_theme_color_override("font_shadow_color", Color("#c8102e") if ombra else Color(0, 0, 0, 0))
	testo.add_theme_constant_override("shadow_offset_x", 2 if ombra else 0)
	testo.add_theme_constant_override("shadow_offset_y", 2 if ombra else 0)
	var effetto := String(prova.get("effetto", ""))
	var battuta := String(prova.get("testo", BATTUTA_LAB))
	testo.text = battuta if effetto == "" else "[%s]%s[/%s]" % [effetto, battuta, effetto]
	testo.visible_ratio = 1.0


func nastri_a_confronto(cartella: String) -> void:
	# IL CARATTERE DEI NOMI A CONFRONTO. Bru: «nei nomi va usato un altro font
	# piu' particolare e alla moda». Il nastro rosa vero, entrato e fermo, con
	# "veronica" scritto sopra, per ogni .ttf di una cartella: "nastri
	# /percorso/cartella". Misure nel nome del file fra graffe, come in
	# "caratteri". Fogli da dieci, due per riga; e per ciascuno si stampa quanto
	# viene largo il nome piu' lungo del gioco
	await apri_dialogo(nodo_di_prova())
	await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
	var schermata: Node = get_child(0)
	var file: Array = Array(DirAccess.get_files_at(cartella)).filter(
			func(f: String) -> bool: return f.ends_with(".ttf"))
	file.sort()
	var cartello := Label.new()
	cartello.position = Vector2(330, 575)
	cartello.add_theme_font_size_override("font_size", 22)
	cartello.add_theme_color_override("font_color", Color.BLACK)
	schermata.add_child(cartello)
	var cella := Rect2i(0, 440, 640, 180)
	for f in ceili(file.size() / 10.0):
		var quanti := mini(10, file.size() - f * 10)
		var foglio := Image.create(1280, 180 * ceili(quanti / 2.0), false, Image.FORMAT_RGBA8)
		for k in quanti:
			var misurato := carattere_con_misure(cartella.path_join(String(file[f * 10 + k])), Stile.dimensione("titolo"), 400)
			schermata.nome_nastro.add_theme_font_override("font", misurato[0])
			schermata.nome_nastro.add_theme_font_size_override("font_size", misurato[1])
			cartello.text = misurato[2]
			schermata.nome_sul_nastro = ""
			schermata.aggiorna_nastro("Un goblin terribilmente arrabbiato")
			await attendi(3)
			print("%s: il nome piu' lungo fa un nastro largo %d" % [misurato[2], int(schermata.nastro.size.x)])
			schermata.nome_sul_nastro = ""
			schermata.aggiorna_nastro("Veronica")
			await attendi(70)   # entrato e fermo
			await RenderingServer.frame_post_draw
			var foto := get_viewport().get_texture().get_image()
			foto.convert(Image.FORMAT_RGBA8)
			foglio.blit_rect(foto, cella, Vector2i((k % 2) * 640, floori(k / 2.0) * 180))
		foglio.save_png(ProjectSettings.globalize_path(CARTELLA + "nastri_%d.png" % (f + 1)))
		print("foglio salvato: %snastri_%d.png" % [CARTELLA, f + 1])


func carattere_con_misure(percorso: String, corpo: int, peso: int) -> Array:
	# [Font, corpo, nome]. Nel nome del file, fra graffe, le sue misure:
	# "Italianno {corpo=58}.ttf", "Fraunces {SOFT=100;wght=450}.ttf"
	var carattere := FontFile.new()
	carattere.load_dynamic_font(percorso)
	var assi := {"wght": peso}
	var corpo_suo := corpo
	var nome := percorso.get_file().get_basename()
	if nome.contains("{"):
		for coppia in nome.get_slice("{", 1).trim_suffix("}").split(";"):
			if coppia.get_slice("=", 0) == "corpo":
				corpo_suo = int(coppia.get_slice("=", 1))
			else:
				assi[coppia.get_slice("=", 0)] = float(coppia.get_slice("=", 1))
		nome = nome.get_slice("{", 0).strip_edges()
	var pesato := FontVariation.new()
	pesato.base_font = carattere
	var opentype := {}
	for asse: String in assi:
		opentype[TextServerManager.get_primary_interface().name_to_tag(asse)] = assi[asse]
	pesato.variation_opentype = opentype
	return [pesato, corpo_suo, nome]


func attendi(quanti: int) -> void:
	for i in quanti:
		await get_tree().process_frame

func fotografa_la_mazzata(contrasto: ContrastoCombattimento, momento: String) -> void:
	# una mano che preme sei volte al secondo (o nessuna, per "colpo"), a passi
	# di un fotogramma: "spinta" si ferma a meta' gara, le altre alla fine
	contrasto.avvia({})
	var passo := 1.0 / 60.0
	var fotogramma := 0
	while contrasto.fase == "reazione" or contrasto.fase == "spinta":
		if momento == "reazione" and contrasto.secondi >= 0.12:
			break
		if momento == "spinta" and contrasto.secondi >= 1.0:
			break
		if momento != "colpo" and fotogramma % 10 == 0:
			contrasto.premi_col_tasto()
		contrasto.passa(passo)
		fotogramma += 1
	contrasto.passa(passo)
	await attendi(2)
	if not contrasto.attivo:
		push_error("la mazzata non e' a schermo: non c'e' niente da fotografare")

func prepara(quale: String) -> void:
	match quale:
		"menu":
			# IL MENU DI PAUSA, e con un secondo argomento anche a meta' della sua
			# entrata: "menu 120" lo ferma 120 millesimi dopo l'apertura, "menu
			# sopra" lo lascia assestare con il fuoco sul Diario e il mouse in
			# alto a destra (la parallasse e l'estrusione della parola)
			await apri_dialogo()
			await attendi(10)
			Pausa.apri()
			var argomenti := OS.get_cmdline_user_args()
			var quando := String(argomenti[1]) if argomenti.size() > 1 else ""
			if quando.is_valid_int():
				await ferma_dopo(int(quando))
			elif quando == "film":
				await pellicola("res://scatti/menu_pellicola.png")
			elif quando == "sopra":
				Pausa.quinte.puntatore_finto = Vector2(1240.0, 60.0)
				await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
				var voci := Pausa.colonna.get_children().filter(
						func(n: Node) -> bool: return n is VoceMenu)
				(voci[2] as VoceMenu).bottone.grab_focus()
		"scena":
			# una schermata qualunque di scenes/, com'e' appena aperta:
			# "scena Compendio", "scena Album"...
			var argomenti := OS.get_cmdline_user_args()
			var nome_scena := String(argomenti[1]) if argomenti.size() > 1 else "Compendio"
			add_child(load("res://scenes/%s.tscn" % nome_scena).instantiate())
		"principale":
			# IL MENU PRINCIPALE: "principale titolo", "principale menu", e i passi
			# "nuova", "carica", "chi_sei", "come", "film" (la pellicola
			# dell'entrata). Con "partite" in fondo ci sono due partite salvate,
			# che alla fine si cancellano
			var argomenti := OS.get_cmdline_user_args()
			var passo := String(argomenti[1]) if argomenti.size() > 1 else "titolo"
			var con_partite := "partite" in argomenti
			if "grande" in argomenti:
				# il caso peggiore per lo spazio: «testo piu' grande» acceso
				Impostazioni.testo_grande = true
				Impostazioni.applica_scala_testo()
			if con_partite:
				partite_finte()
			var schermo: Control = load("res://scenes/Menu.tscn").instantiate()
			add_child(schermo)
			await attendi(3)
			if passo != "titolo":
				schermo.entra_dal_titolo()
			match passo:
				"nuova": schermo.pagina_nuova()
				"carica": schermo.pagina_carica()
				"chi_sei": schermo.pagina_chi_sei(1)
				"anonimo":
					# la domanda sul nome vuoto, aperta come la apre COMINCIA
					schermo.pagina_chi_sei(1)
					schermo.al_via = func() -> void: pass
					await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
					schermo.comincia()
				"come": schermo.pagina_come_si_gioca()
				"come_storia": schermo.pagina_come_si_gioca("STORIA")
				"come_scontro": schermo.pagina_come_si_gioca("COMBATTIMENTO")
				"come_mosse": schermo.pagina_come_si_gioca("MOSSE SPECIALI")
				"come_mappa": schermo.pagina_come_si_gioca("MAPPA")
				"opzioni": schermo.pagina_opzioni()
				"audio": schermo.pagina_opzioni_di("Audio")
				"grafica": schermo.pagina_opzioni_di("Grafica")
				"accessibilita": schermo.pagina_opzioni_di("Accessibilità")
				"extra": schermo.pagina_extra()
				"codice": schermo.pagina_codice()
				"collezioni": schermo.pagina_collezioni()
				"film": await pellicola("res://scatti/principale_pellicola.png")
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			if passo == "menu" and con_partite:
				# e una voce scelta a meta' elenco, come EXTRAS nel riferimento
				(schermo.voci[4] as VoceMenu).bottone.grab_focus()
				await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			if con_partite:
				salva("principale_%s_partite" % passo)
				for slot in [2, 4]:
					GameState.elimina_slot(slot)
		"pausa":
			# un pannello della pausa: "pausa menu", "pausa diario", "pausa
			# organizzazione", "pausa messaggi", "pausa bestiario", "pausa
			# sviluppo", "pausa zaino", "pausa opzioni", "pausa storico", "pausa
			# uscita". Con "nuovi" dopo, arriva prima un messaggio da leggere
			await apri_dialogo()
			await attendi(10)
			var argomenti := OS.get_cmdline_user_args()
			if argomenti.size() > 2 and String(argomenti[2]) == "nuovi":
				GameState.imposta_flag("ordini_ricevuti")
			Pausa.apri()
			await attendi(5)
			match String(argomenti[1]) if argomenti.size() > 1 else "diario":
				"menu": pass
				"messaggi": Pausa.mostra_messaggi()
				"organizzazione":
					Pausa.sezione_diario = "organizzazione"
					Pausa.mostra_diario()
				"bestiario": Pausa.apri_collezione(MenuPrincipale.SCENA_BESTIARIO)
				"sviluppo":
					Pausa.mostra_equipaggiamento()
					await attendi(5)
					(Pausa.foglio as SchedaPersonaggio).scegli_linguetta("sviluppo")
				"zaino":
					# "pausa zaino armi" apre uno scomparto preciso, "pausa
					# zaino vuoto" lo zaino di chi ha appena cominciato
					var scomparto := String(argomenti[2]) if argomenti.size() > 2 else "consumabili"
					if scomparto != "vuoto":
						riempi_lo_zaino(scomparto)
					# "pausa zaino consumabili fasce": una delle proposte (ProposteZaino)
					if argomenti.size() > 3:
						ProposteZaino.scelta = String(argomenti[3])
					Pausa.mostra_inventario()
				"opzioni": Pausa.mostra_opzioni()
				"storico": Pausa.mostra_storico()
				"uscita": Pausa.conferma_uscita()
				"squadra": Pausa.mostra_equipaggiamento()
				_: Pausa.mostra_diario()
		"nodo":
			# UN NODO VERO DI events_intro, portato avanti di N clic: "nodo
			# infermeria_risveglio 12" fotografa la dodicesima battuta. Con
			# "fine" al posto del numero si clicca finche' non ci sono le scelte
			var argomenti_nodo := OS.get_cmdline_user_args()
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			GameState.imposta_flag("rientro_infermeria")
			GameState.nodo_corrente = String(argomenti_nodo[1]) if argomenti_nodo.size() > 1 else "infermeria_risveglio"
			# un nodo che non e' dell'introduzione e' del livello dei goblin
			if not GameState.eventi.has(GameState.nodo_corrente):
				var cercato := GameState.nodo_corrente
				GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
				GameState.nodo_corrente = cercato
			IngressoNodo.ultimo_esito = {}
			var dialogo: Node = load("res://scenes/Main.tscn").instantiate()
			add_child(dialogo)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var quanti := String(argomenti_nodo[2]) if argomenti_nodo.size() > 2 else "0"
			var clic := 0
			while clic < (400 if quanti == "fine" else int(quanti)):
				if quanti == "fine" and dialogo.contenitore_scelte.get_child_count() > 0 \
						and dialogo.coda_messaggi.is_empty():
					break
				# un clic completa la frase, il secondo va avanti: come un giocatore
				dialogo._su_avanza()
				await attendi(2)
				dialogo._su_avanza()
				await attendi(2)
				clic += 1
			# la battuta intera, non le prime due parole della macchina da scrivere:
			# la battuta arriva qualche fotogramma dopo il clic, e puo' ripartire
			# (la prima misura del box la reimpagina): si completa finche' per
			# venti fotogrammi di fila non scrive piu' niente
			var ferma := 0
			for attesa in 600:
				if dialogo.box.sta_scrivendo:
					dialogo.box.completa()
					ferma = 0
				else:
					ferma += 1
					if ferma >= 20:
						break
				await attendi(1)
			# LE PROPOSTE OLTRE IL NASTRO APPROVATO, messe sopra quello vero:
			# "nodo infermeria_risveglio 5 oltre=carta,impresso" (prove/NastroOltre.gd)
			for argomento: String in argomenti_nodo:
				if argomento.begins_with("oltre="):
					await NastroOltre.vesti(dialogo, argomento.trim_prefix("oltre=").split(","))
					await attendi(3)
					if "arrivo" in argomento:
						await NastroOltre.pellicola_dell_arrivo(dialogo, "res://scatti/nastro_oltre_arrivo.png")
		"giro_data_pad":
			# IL GIRO GUIDATO DEL DATA PAD, portato fino a un passo: "giro_data_pad
			# alloggio 0" e' il tasto in alto a sinistra da premere, "giro_data_pad
			# data_pad_istruzioni 4" il messaggio da aprire in sala. I gesti che il
			# giro aspetta li fa lo scatto al posto del giocatore
			var argomenti_giro := OS.get_cmdline_user_args()
			var nodo_giro := String(argomenti_giro[1]) if argomenti_giro.size() > 1 else "alloggio"
			var fino_al := int(argomenti_giro[2]) if argomenti_giro.size() > 2 else 0
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			if nodo_giro != "alloggio":
				GameState.imposta_flag("rientro_infermeria")
				GameState.imposta_flag("ordini_ricevuti")
			GameState.nodo_corrente = nodo_giro
			IngressoNodo.ultimo_esito = {}
			var con_giro: Node = load("res://scenes/Main.tscn").instantiate()
			add_child(con_giro)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var giro: GiroDataPad = null
			for i in 60:
				giro = con_giro.find_children("*", "GiroDataPad", true, false).pop_back() as GiroDataPad
				if giro != null:
					break
				con_giro.box.completa()
				con_giro.avanza_messaggio()
				await attendi(2)
			while giro != null and giro.quale < fino_al and not giro.chiuso:
				var aspetta := String(giro.passo().get("aspetta", ""))
				if aspetta == "apri":
					Pausa.apri()
				elif aspetta == "voce:diario":
					Pausa.mostra_diario()
				elif aspetta == "voce:messaggi":
					Pausa.mostra_messaggi()
				elif aspetta.begins_with("sezione:"):
					Pausa.sezione_diario = aspetta.trim_prefix("sezione:")
					Pausa.mostra_diario()
				elif aspetta == "":
					giro.clic()
					giro.clic()
				else:
					break
				await attendi(12)
			await attendi(40)
			if giro != null:
				giro.box.completa()
		"guida_mappa":
			# la Guida che parla sopra la mappa delle Pianure, all'arrivo:
			# "guida_mappa 2" fotografa la seconda battuta
			GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
			GameState.nodi_visitati.append("inizio")
			GuidaSullaMappa.in_corso = {"zona": GameState.carnivalz_corrente,
					"righe": GameState.mappa_zona.get("guida", []), "ritorno": "inizio_guida", "solo_chiudere": true}
			var mappa: Node = load(GuidaSullaMappa.SCENA_MAPPA_ZONA).instantiate()
			add_child(mappa)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var argomenti_guida := OS.get_cmdline_user_args()
			var battute := int(argomenti_guida[1]) if argomenti_guida.size() > 1 else 1
			var guida: GuidaSullaMappa = mappa.find_children("*", "GuidaSullaMappa", true, false)[0] as GuidaSullaMappa
			for i in battute - 1:
				guida._su_clic()
				await attendi(2)
				guida._su_clic()
				await attendi(2)
		"pianure_scontro":
			# UNO SCONTRO DELLE PIANURE CON LA SUA REGIA, fermato sulla battuta
			# che si vuole guardare: "pianure_scontro banchetto precedenza" e' la
			# Guida che spiega la precedenza, "pianure_scontro pozze gracchiare"
			# l'annuncio dell'orda, "pianure_scontro tartaruga bond" BOND acceso
			var argomenti_s := OS.get_cmdline_user_args()
			var id_nodo := String(argomenti_s[1]) if argomenti_s.size() > 1 else "banchetto"
			var cercato := String(argomenti_s[2]) if argomenti_s.size() > 2 else ""
			GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
			var dati_scontro: Dictionary = GameState.eventi[id_nodo]["combattimento_automatico"]
			GameState.prepara_combattimento(dati_scontro["nemici"], "", "", "", "", dati_scontro.get("regia", {}))
			var scontro_p: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(scontro_p)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var giri := 0
			if id_nodo == "tartaruga" and cercato != "bond":
				# la scena della tartaruga parte alla tua seconda azione
				for azione in 2:
					scontro_p.regia.dopo_di_te(scontro_p.combattente_comandato())
			if cercato == "skill":
				# la lista SKILL di chi comincia, col mondo fermo: e' quella che
				# deve reggere Onda psichica e Concentrazione accanto al resto
				while giri < 600 and (not scontro_p.voce.coda.is_empty() or scontro_p.voce.sta_facendo_leggere):
					scontro_p.voce.salta_messaggio = true
					await attendi(4)
					giri += 1
				scontro_p.set_process(false)
				scontro_p.attaccante_corrente = scontro_p.combattente_comandato()
				scontro_p.menu.abilita()
				await attendi(10)
			elif cercato == "bond":
				scontro_p.regia.apri_il_bond()
				while giri < 600 and (not scontro_p.voce.coda.is_empty() or scontro_p.voce.sta_facendo_leggere):
					scontro_p.voce.salta_messaggio = true
					await attendi(4)
					giri += 1
				scontro_p.turni.passa_a(scontro_p.combattente_comandato())
				await attendi(30)
			elif cercato == "turno":
				# IL TUO TURNO, arrivato giocando: si legge tutto quello che c'e' da
				# leggere (l'imboscata, la Guida, il colpo del goblin) finche' il
				# giro non arriva a te e il menu si accende
				var tu_p: Dictionary = scontro_p.combattente_comandato()
				while giri < 900 and not (scontro_p.puo_agire(tu_p) and scontro_p.fase_adesso() == "comandi"):
					if scontro_p.area_avanza.visible:
						scontro_p.voce.avanza()
					await attendi(2)
					giri += 1
				await attendi(30)
				print("giro %d, tocca a te" % scontro_p.turni.giro)
			else:
				var testo_box: RichTextLabel = scontro_p.box.get("testo")
				while giri < 600 and not cercato in testo_box.get_parsed_text():
					scontro_p.voce.salta_messaggio = true
					await attendi(4)
					giri += 1
				await attendi(20)
		"zona_pianure":
			# la mappa delle Pianure a meta' strada: sei al bivio, la caverna
			# l'hai vista e visitata, le pozze e il promontorio no
			GameState.avvia_carnivalz("tutorial", "res://data/events_tutorial.json")
			GameState.imposta_flag("tut_caverna_vista")
			for id_stanza in ["inizio", "banchetto", "pianura", "albero", "caverna", "masso", "bivio"]:
				GameState.nodi_visitati.append(id_stanza)
				GameState.sblocca_stanza(id_stanza)
			GameState.nodo_corrente = "bivio"
			var pianure: Control = load("res://scenes/MappaZona.tscn").instantiate()
			pianure.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(pianure)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"proiezione":
			# LE SCRITTE DELLE PROIEZIONI, con una scheda piena: "proiezione mappa"
			# la mappa stellare a meta' gioco col cursore su un sistema,
			# "proiezione vuoto" il Vuoto Ardente col cursore su una frattura,
			# "proiezione plastico" le Pianure con la scheda di una stanza
			var dove := String(OS.get_cmdline_user_args()[1]) if OS.get_cmdline_user_args().size() > 1 else "mappa"
			await proiezione_piena(dove)
		"mappa_prima":
			# la mappa stellare aperta da Veronica: solo la prima missione
			MappaStellare.missione_da_scegliere = "proiezione_partenza"
			add_child(load("res://scenes/Mappa.tscn").instantiate())
		"scelte":
			await apri_dialogo(nodo_di_prova())
		"lastra":
			# LA LASTRA DEI DIALOGHI (Lastra.gd) in ogni situazione, con battute
			# vere: "lastra parla", "lastra tu", "lastra narrazione", "lastra
			# avviso", "lastra scelte"
			var argomenti_l := OS.get_cmdline_user_args()
			var come := String(argomenti_l[1]) if argomenti_l.size() > 1 else "parla"
			await apri_dialogo(nodo_lastra(come))
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 20)
			var con_lastra := get_child(0)
			con_lastra.box.completa()
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"nastro":
			# IL NASTRO A META' VOLO. Dura meno di mezzo secondo: a occhio nudo
			# non si ferma, e senza fermarlo non si puo' dire se la curva e'
			# quella che ha disegnato Bru o un'altra.
			await apri_dialogo(nodo_di_prova())
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			var schermata := get_child(0)
			schermata.nome_sul_nastro = ""
			schermata.aggiorna_nastro("Veronica")
			var argomenti := OS.get_cmdline_user_args()
			var quando := int(argomenti[1]) if argomenti.size() > 1 else 11
			await attendi(quando)
		"intro":
			# la vera introduzione, non un nodo finto: si guarda che il testo di
			# Bru ci stia nel box e che lo sfondo non copra niente
			await apri_dialogo()
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"racconto":
			# IL RACCONTO A SCHERMO INTERO (Racconto.gd): "racconto intro 3" e' il
			# quarto paragrafo dell'introduzione, scritto tutto; "racconto tutorial
			# 0 meta" il primo delle Pianure a meta' della macchina da scrivere
			var argomenti_r := OS.get_cmdline_user_args()
			var campagna := String(argomenti_r[1]) if argomenti_r.size() > 1 else "intro"
			var fino_al := int(argomenti_r[2]) if argomenti_r.size() > 2 else 0
			var a_meta := argomenti_r.size() > 3 and String(argomenti_r[3]) == "meta"
			GameState.avvia_carnivalz(campagna, "res://data/events_intro.json" if campagna == "intro"
					else "res://data/events_tutorial.json")
			IngressoNodo.ultimo_esito = {}
			var col_racconto: Node = load("res://scenes/Main.tscn").instantiate()
			add_child(col_racconto)
			var fatti := 0
			for giro in 6000:
				await attendi(1)
				var r: Racconto = col_racconto.racconto
				if r == null or r.fase != "scrive":
					continue
				if fatti < fino_al:
					r.premi()   # completa
					r.premi()   # e va avanti
					fatti += 1
					continue
				if a_meta:
					while r.testo.visible_ratio < 0.55:
						await attendi(1)
				else:
					r.premi()
					await attendi(40)
				break
		"caratteri":
			# I CARATTERI DA FAVOLA A CONFRONTO. Bru: «il font delle narrazioni [...]
			# deve essere piu' elegante e fiabesco». Lo stesso paragrafo del racconto
			# scritto con ogni .ttf di una cartella, anche fuori dal progetto, in un
			# foglio solo: "caratteri /percorso/cartella [corpo] [peso] [intero]".
			# Un carattere che vuole misure sue le porta nel nome del file, fra
			# graffe: "Italianno {corpo=58}.ttf", "Fraunces {SOFT=100;wght=450}.ttf".
			var argomenti_c := OS.get_cmdline_user_args()
			var cartella := String(argomenti_c[1])
			var corpo_c := int(argomenti_c[2]) if argomenti_c.size() > 2 and argomenti_c[2].is_valid_int() else 34
			var peso_c := int(argomenti_c[3]) if argomenti_c.size() > 3 and argomenti_c[3].is_valid_int() else 500
			GameState.avvia_carnivalz("magione", "res://data/vuoti/casa_gigante.json")
			IngressoNodo.ultimo_esito = {}
			var col_fiaba: Node = load("res://scenes/Main.tscn").instantiate()
			add_child(col_fiaba)
			var fiaba: Racconto = null
			for giro in 3000:
				await attendi(1)
				fiaba = col_fiaba.racconto
				if fiaba != null and fiaba.fase == "scrive":
					fiaba.premi()
					break
			await attendi(20)
			var nomi: Array = Array(DirAccess.get_files_at(cartella)).filter(
					func(f: String) -> bool: return f.ends_with(".ttf"))
			nomi.sort()
			var foglio := Image.create(1280, 360 * ceili(nomi.size() / 2.0), false, Image.FORMAT_RGBA8)
			var cartello := Label.new()
			cartello.position = Vector2(40, 30)
			cartello.add_theme_font_size_override("font_size", 40)
			fiaba.add_child(cartello)
			for i in nomi.size():
				var misurato := carattere_con_misure(cartella.path_join(String(nomi[i])), corpo_c, peso_c)
				fiaba.testo.add_theme_font_override("normal_font", misurato[0])
				fiaba.testo.add_theme_font_size_override("normal_font_size", misurato[1])
				cartello.text = misurato[2]
				await attendi(6)
				await RenderingServer.frame_post_draw
				var foto := get_viewport().get_texture().get_image()
				foto.convert(Image.FORMAT_RGBA8)
				if "intero" in argomenti_c:   # ognuno a grandezza vera, in un file suo
					foto.save_png(ProjectSettings.globalize_path(CARTELLA + "carattere_%d.png" % (i + 1)))
				foto.resize(640, 360, Image.INTERPOLATE_BILINEAR)
				foglio.blit_rect(foto, Rect2i(0, 0, 640, 360), Vector2i((i % 2) * 640, floori(i / 2.0) * 360))
			foglio.save_png(ProjectSettings.globalize_path(CARTELLA + "caratteri_confronto.png"))
			print("foglio salvato: %scaratteri_confronto.png" % CARTELLA)
		"dialoghi":
			# IL CARATTERE DEI DIALOGHI A CONFRONTO. Bru: «dobbiamo anche scegliere
			# un bel font generale per i dialoghi, quello attuale non mi piace». La
			# stessa battuta, nel box vero col nastro del nome, con ogni .ttf di una
			# cartella: "dialoghi /percorso/cartella [nodo] [clic] [corpo]". Misure
			# nel nome del file fra graffe, come in "caratteri". Fogli da sette
			var argomenti_d := OS.get_cmdline_user_args()
			var cartella_d := String(argomenti_d[1])
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			GameState.imposta_flag("rientro_infermeria")
			GameState.nodo_corrente = String(argomenti_d[2]) if argomenti_d.size() > 2 else "infermeria_risveglio"
			IngressoNodo.ultimo_esito = {}
			var parla: Node = load("res://scenes/Main.tscn").instantiate()
			add_child(parla)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			for clic in (int(argomenti_d[3]) if argomenti_d.size() > 3 else 3):
				parla._su_avanza()
				await attendi(2)
				parla._su_avanza()
				await attendi(2)
			await attendi(30)
			var corpo_d := int(argomenti_d[4]) if argomenti_d.size() > 4 else Stile.dimensione("corpo")
			var file_d: Array = Array(DirAccess.get_files_at(cartella_d)).filter(
					func(f: String) -> bool: return f.ends_with(".ttf"))
			file_d.sort()
			var cartello_d := Label.new()
			cartello_d.position = Vector2(760, 432)
			cartello_d.add_theme_font_size_override("font_size", 30)
			cartello_d.add_theme_color_override("font_color", Color.WHITE)
			parla.add_child(cartello_d)
			var striscia := Rect2i(0, 420, 1280, 300)
			var fogli := ceili(file_d.size() / 7.0)
			for f in fogli:
				var quanti := mini(7, file_d.size() - f * 7)
				var foglio_d := Image.create(1280, 300 * quanti, false, Image.FORMAT_RGBA8)
				for k in quanti:
					var misurato := carattere_con_misure(cartella_d.path_join(String(file_d[f * 7 + k])), corpo_d, 400)
					for chiave in ["normal_font", "italics_font", "bold_font"]:
						parla.box.testo.add_theme_font_override(chiave, misurato[0])
					for chiave in ["normal_font_size", "italics_font_size", "bold_font_size"]:
						parla.box.testo.add_theme_font_size_override(chiave, misurato[1])
					cartello_d.text = misurato[2]
					parla.box.completa()   # la battuta intera, non a meta' macchina da scrivere
					await attendi(6)
					await RenderingServer.frame_post_draw
					var foto_d := get_viewport().get_texture().get_image()
					foto_d.convert(Image.FORMAT_RGBA8)
					foglio_d.blit_rect(foto_d, striscia, Vector2i(0, 300 * k))
				foglio_d.save_png(ProjectSettings.globalize_path(CARTELLA + "dialoghi_rosa_%d.png" % (f + 1)))
				print("foglio salvato: %sdialoghi_rosa_%d.png" % [CARTELLA, f + 1])
		"nastri":
			await nastri_a_confronto(String(OS.get_cmdline_user_args()[1]))
		"nome_in_scena":
			await nomi_in_scena(JSON.parse_string(FileAccess.get_file_as_string(String(OS.get_cmdline_user_args()[1]))))
		"nomi_eleganti":
			await nomi_a_confronto(JSON.parse_string(FileAccess.get_file_as_string(String(OS.get_cmdline_user_args()[1]))))
		"laboratorio":
			# UN CARATTERE PIEGATO A CODICE. Bru: «c'e' modo di usare un font e con
			# qualche stratagemma personalizzarlo a codice?». La stessa battuta nel
			# box vero, con quello che Godot lascia fare a un carattere senza
			# ridisegnarlo: "laboratorio /percorso/google-fonts/ofl [prove.json]".
			# Il json e' una lista di prove come PROVE_LAB, per provarne altre
			var argomenti_l := OS.get_cmdline_user_args()
			var prove_l: Array = PROVE_LAB
			if argomenti_l.size() > 2:
				prove_l = JSON.parse_string(FileAccess.get_file_as_string(String(argomenti_l[2])))
			await laboratorio(String(argomenti_l[1]), prove_l)
		"scritta":
			# LA SCRITTA DI CARNIVALZ nel momento in cui e' tutta accesa
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			IngressoNodo.ultimo_esito = {}
			var col_logo: Node = load("res://scenes/Main.tscn").instantiate()
			add_child(col_logo)
			await attendi(5)
			var r_logo: Racconto = col_logo.racconto
			r_logo.scritta("res://art/interfaccia/carnivalz.png", 2.4)
			while r_logo.logo == null or r_logo.logo.modulate.a < 0.99:
				await attendi(1)
			await attendi(30)
		"collisioni":
			# LA RAFFICA FERMATA IN UN MOMENTO PRECISO. Il secondo argomento dice
			# quale: "apertura", "chiusura", oppure i secondi dall'inizio dei
			# pugni (di serie 2.3: un pugno appena parato, uno a meta' strada,
			# uno appena comparso - le tre cose che si devono leggere insieme).
			#
			# L'orologio del minigioco si muove a mano, a passi di un
			# fotogramma: aspettare fotogrammi veri sotto xvfb vuol dire
			# fotografare un istante diverso a ogni prova.
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["veronica"]
			var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(scontro)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			scontro.voce.coda.clear()
			scontro.set_process(false)
			var gioco: MinigiocoCombattimento = scontro.minigioco
			gioco.avvia({"nome": "Collisioni infinite", "quanti": 12,
					"intervallo": 1.0, "durata": 2.0, "danno": 9})
			var argomenti := OS.get_cmdline_user_args()
			var quando := String(argomenti[1]) if argomenti.size() > 1 else "2.3"
			if quando != "apertura":
				gioco.salta()
				var fino_a := 99.0 if quando == "chiusura" else float(quando)
				var parato := false
				while gioco.fase == "raffica" and gioco.tempo < fino_a:
					gioco.passa(1.0 / 60.0)
					# una mano che prende il primo pugno quando il cerchio si chiude
					if not parato and gioco.tempo >= 1.95:
						gioco.colpisci(0)
						parato = true
			# alla chiusura il conto compare quando l'ultimo riscontro e' svanito
			for i in (50 if quando == "chiusura" else 1):
				gioco.passa(1.0 / 60.0)
			await attendi(3)
			if not gioco.attivo:
				push_error("la raffica non e' a schermo: non c'e' niente da fotografare")
		"mazzata", "gregari":
			# IL GOBLIN ARRABBIATO. "mazzata <momento>" ferma il contrasto in uno
			# dei suoi istanti ("reazione", "spinta", "parata", "colpo");
			# "gregari" mostra i due goblin che ha chiamato, nei quadratini in
			# basso a sinistra del suo riquadro. Anche qui l'orologio si muove a
			# mano, come per la raffica
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["goblin_arrabbiato"]
			var boss: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(boss)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			for volta in 2:
				boss.aggiungi_combattente("goblin_tipico", false)
			var ferito: Dictionary = boss.combattenti[boss.combattenti.size() - 1]
			ferito.hp = int(ferito.hp_max * 0.4)
			boss.aggiorna_scheda(ferito)
			boss.voce.coda.clear()
			boss.set_process(false)
			if quale == "gregari":
				boss.plancia.mostra_faccia("comandi")
			else:
				var argomenti_m := OS.get_cmdline_user_args()
				await fotografa_la_mazzata(boss.mazzata.contrasto,
						String(argomenti_m[1]) if argomenti_m.size() > 1 else "spinta")
			await attendi(3)
		"ecgrosso", "ecggiallo":
			# L'ECG IN AVARIA. Un tracciato a occhio non si giudica da fermo:
			# serve vederlo col guasto acceso, e per vederlo bisogna portare il
			# protagonista sotto la soglia rossa o in mezzo a quella gialla.
			GameState.nuova_partita()
			GameState.party = ["anonimo", "veronica"]
			GameState.nemici_combattimento = ["marionetta"]
			var malmesso: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(malmesso)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			for c in malmesso.combattenti:
				c.hp = c.hp_max
				malmesso.campo.aggiorna(c)
			malmesso.arena.imposta_pericolo(0.0)
			malmesso.campo.evidenzia(malmesso.combattenti, malmesso.combattenti[0])
			# LA VITA SI ABBASSA DAVVERO, non si racconta alla plancia. Lo
			# scontro gira e aggiorna_pronto_giocatore riscrive la condizione
			# con gli hp VERI di chi ha il turno a ogni fotogramma: chiamare
			# aggiorna_condizione a mano dura un fotogramma e poi viene
			# sovrascritto. Successo: chiedevo rosso e fotografavo giallo.
			var quota := 0.12 if quale == "ecgrosso" else 0.50
			for c in malmesso.combattenti:
				if c.giocatore:
					c.hp = maxi(int(float(c.hp_max) * quota), 1)
					c.stress = 70 if quale == "ecgrosso" else 25
					malmesso.campo.aggiorna(c)
			malmesso.aggiorna_pronto_giocatore()
			malmesso.menu.principale()
			# tanti fotogrammi: il guasto va a scatti, e va beccato acceso
			var argomenti_ecg := OS.get_cmdline_user_args()
			await attendi(int(argomenti_ecg[1]) if argomenti_ecg.size() > 1 else 90)
			# LA FACCIA SI FORZA PER ULTIMA. Lo scontro gira in tempo reale e
			# rimette il parlato appena arriva una battuta: senza questa riga lo
			# scatto dell'ecg fotografa il box del testo, che e' esattamente
			# quello che e' successo al primo tentativo.
			# E POI SI FERMA IL MOTORE. Forzare la faccia non basta: _process
			# gira a ogni fotogramma e decidi_faccia la rimette sul parlato
			# appena arriva una battuta. Spegnendo il process il quadrante
			# resta dove l'ho messo, e l'ecg - che ha un process suo - continua
			# a disegnarsi. Tre tentativi prima di capirlo.
			malmesso.voce.coda.clear()
			malmesso.set_process(false)
			# E LA VITA SI RIMETTE DOVE L'AVEVO CHIESTA. Nei novanta fotogrammi
			# qui sopra lo scontro e' VIVO: la marionetta picchia, e chiedendo
			# giallo mi sono ritrovato 13/100 e un tracciato rosso. Adesso che
			# il motore e' fermo nessuno la riscrive piu': si rimette il numero
			# e si aggiorna la condizione una volta sola.
			for c in malmesso.combattenti:
				if c.giocatore:
					c.hp = maxi(int(float(c.hp_max) * quota), 1)
					malmesso.campo.aggiorna(c)
			malmesso.aggiorna_pronto_giocatore()
			malmesso.plancia.mostra_faccia("comandi")
			# E DUE FOTOGRAMMI PER RIDISEGNARE. mostra_faccia cambia solo
			# .visible: chi guarda subito dopo vede ancora il fotogramma di
			# prima, cioe' il box del testo. Col motore fermo aspettare non
			# costa piu' niente - e' il motivo per cui tre scatti di fila
			# hanno fotografato il parlato invece del quadrante.
			await attendi(2)
		"plancia":
			# LA SCHERMATA DI COMBATTIMENTO INTERA, come l'ha disegnata Bru.
			# Non c'e' altro modo di controllare che sia quella: le prove sanno
			# dire che i pezzi ci sono, non che il disegno e' quello.
			GameState.nuova_partita()
			GameState.party = ["anonimo", "veronica"]
			GameState.nemici_combattimento = ["marionetta"]
			var scena: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(scena)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			# la faccia dei comandi: e' quella del terzo disegno di Bru
			for c in scena.combattenti:
				c.hp = c.hp_max   # a riposo: il disegno di Bru e' una squadra intera
				scena.campo.aggiorna(c)
			scena.arena.imposta_pericolo(0.0)
			# chi ha il turno: cornice accesa e numero dell'aura
			scena.campo.evidenzia(scena.combattenti, scena.combattenti[0])
			for c in scena.combattenti:
				if c.giocatore:
					scena.campo.aggiorna(c)
			scena.plancia.aggiorna_condizione(0.18, 70, 68)
			scena.plancia.accendi(scena.plancia.tasto_mattanza, true)
			scena.plancia.accendi(scena.plancia.tasto_bond, true)
			scena.menu.principale()
			await attendi(60)
		"lista":
			# LA SECONDA FACCIA DEL QUADRANTE. Bru: «se premi su attacco vedi una
			# lista degli attacchi disponibili, stessa cosa le skill [...] per
			# oggetti invece la lista di oggetti utilizzabili».
			#
			# SKILL e' la piu' affollata delle tre - Studia, i colpi d'arma, le
			# abilita', Indietro - ed e' quella che dice se le colonne reggono.
			GameState.nuova_partita()
			GameState.party = ["anonimo", "veronica"]
			GameState.nemici_combattimento = ["marionetta"]
			var scontro_lista: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(scontro_lista)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			for c in scontro_lista.combattenti:
				c.hp = c.hp_max
				scontro_lista.campo.aggiorna(c)
			scontro_lista.arena.imposta_pericolo(0.0)
			scontro_lista.campo.evidenzia(scontro_lista.combattenti, scontro_lista.combattenti[0])
			scontro_lista.plancia.aggiorna_condizione(0.62, 30, 68)
			scontro_lista.plancia.accendi(scontro_lista.plancia.tasto_mattanza, true)
			# LA LISTA SI APRE PER ULTIMA. Lo scontro gira in tempo reale e rifa'
			# il menu principale quando torni pronto: aprendola prima
			# dell'attesa, al momento dello scatto era gia' tornata la colonna
			# dei comandi - ed e' esattamente quello che era successo.
			scontro_lista.menu.principale()
			await attendi(60)
			scontro_lista.menu.abilita()
			await attendi(3)
			if scontro_lista.plancia.griglia_lista.get_child_count() == 0:
				push_error("la griglia e' vuota: non c'e' nessuna lista da fotografare")
			if scontro_lista.plancia.faccia_adesso != "lista":
				push_error("al momento dello scatto il quadrante mostra '%s', non la lista"
						% scontro_lista.plancia.faccia_adesso)
		"mattanza":
			# LA MATTANZA APERTA: il tassello, la barra che si scarica, e sotto
			# come si batte. Bru: «la mattanza non causa mai alcun danno»
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["goblin_tipico"]
			var pesta: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(pesta)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			var eroe: Dictionary = pesta.combattenti[0]
			var goblin: Dictionary = pesta.vivi(false)[0]
			goblin.hp_max = 100000
			goblin.hp = 100000
			eroe.dominio = 300
			pesta.usa_abilita_su(eroe, "mattanza", goblin)
			while not pesta.voce.coda.is_empty() or pesta.voce.sta_facendo_leggere:
				pesta.voce.avanza()
				await attendi(2)
			for colpo in 5:
				pesta.mattanza.colpo(goblin)
				await attendi(4)
		"grazia":
			# IL COLPO DI GRAZIA a barra vuota: "mira" con la lancetta che arriva
			# sul bersaglio, "rotto" pochi fotogrammi dopo averlo centrato (i
			# mille pezzi in volo, fuori dal quadrante), "mancato" dopo un tiro a
			# vuoto. L'orologio lo tiene lo scatto, non lo scontro: a fotogrammi
			# veri la lancetta sarebbe dove capita
			var argomenti := OS.get_cmdline_user_args()
			var momento := String(argomenti[1]) if argomenti.size() > 1 else "mira"
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["goblin_tipico"]
			var mira: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(mira)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			var chi_batte: Dictionary = mira.combattenti[0]
			var bersaglio: Dictionary = mira.vivi(false)[0]
			bersaglio.hp_max = 100000
			bersaglio.hp = 100000
			chi_batte.dominio = 200
			mira.usa_abilita_su(chi_batte, "mattanza", bersaglio)
			mira.voce.coda.clear()
			mira.voce.sta_facendo_leggere = false
			mira.set_process(false)
			mira.mattanza.chiudi_finestra()
			var grazia: ColpoDiGraziaCombattimento = mira.mattanza.grazia
			if momento == "ora":
				# la prima volta, nell'allenamento: la lancetta ferma sul
				# bersaglio che aspetta la mano
				grazia.interrompi()
				grazia.avvia(mira.mattanza.dati.get("colpo_di_grazia", {}), true)
			var distanza := {"mira": 0.07, "rotto": 0.005, "mancato": 0.3, "ora": -1.0}.get(momento, 0.07) as float
			var giri := 0
			while giri < 5000 and grazia.fase != "ferma" \
					and (grazia.fase != "corsa" or absf(grazia.cursore - grazia.punto) > distanza):
				grazia.passa(1.0 / 480.0)
				giri += 1
			if momento != "mira" and momento != "ora":
				grazia.premi_col_tasto()
			# l'orologio del minigioco va avanti coi fotogrammi: il lampo si spegne,
			# e i pezzi volano col loro
			for fotogramma in (8 if momento == "rotto" else 2):
				grazia.passa(1.0 / 60.0)
				await attendi(1)
		"lezione":
			# LA LEZIONE DI VERONICA, FOTOGRAFATA MENTRE PARLA.
			#
			# E' la cosa che Bru non riusciva a vedere: il testo del tutorial
			# finiva dietro al menu e si sentiva solo il rumore. Una prova puo'
			# dire che il pannello mostra la faccia "parlato"; solo uno scatto
			# dice se quel testo si LEGGE davvero.
			#
			# Adesso e' anche uno scatto stabile: mentre il tutorial parla il
			# mondo e' fermo, quindi non c'e' nessuna corsa contro la ricarica.
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["veronica"]
			var lezione: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(lezione)
			var attesa := 0
			while attesa < 900 and (lezione.voce.coda.is_empty() or lezione.il_tempo_scorre()):
				await attendi(1)
				attesa += 1
			if lezione.voce.coda.is_empty():
				push_error("il tutorial non ha messo in coda nessuna battuta: non c'e' niente da fotografare")
			if lezione.plancia.faccia_adesso != "parlato":
				push_error("il quadrante mostra '%s' invece del box: il testo starebbe ancora dietro al menu"
						% lezione.plancia.faccia_adesso)
			# si avanza fino alla battuta che indica un pezzo: l'evidenziazione
			# si fotografa solo mentre e' accesa
			var avanzate := 0
			while avanzate < 12 and lezione.plancia.evidenziato == null:
				lezione.voce.salta_messaggio = true
				await attendi(6)
				avanzate += 1
			if lezione.plancia.evidenziato == null:
				push_error("in dodici battute non si e' acceso nessun pezzo dello schermo")
			await attendi(20)
		"ecg":
			# I QUATTRO STATI DELLA LINEA, uno sotto l'altro. Il colore dice la
			# vita, il movimento dice lo stress: sono due informazioni diverse
			# nella stessa riga, e l'unico modo di controllare che si leggano
			# davvero e' guardarle insieme.
			GameState.nuova_partita()
			var casi := [
				["vita piena, sereno", 1.0, 0],
				["mezza vita, teso", 0.5, 55],
				["a pezzi, nel panico", 0.15, 100],
				["a terra", 0.0, 0],
			]
			var colonna := VBoxContainer.new()
			colonna.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			colonna.add_theme_constant_override("separation", 18)
			add_child(colonna)
			for caso in casi:
				var etichetta := Label.new()
				etichetta.text = String(caso[0])
				etichetta.add_theme_color_override("font_color", Stile.colore("testo_smorzato"))
				colonna.add_child(etichetta)
				var riga := TracciatoEcg.new()
				riga.custom_minimum_size = Vector2(0, 110)
				riga.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				riga.dado.seed = 20260915
				riga.imposta(float(caso[1]), int(caso[2]))
				colonna.add_child(riga)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 260)
		"complesso_dopo":
			# LA MAPPA DEL POMERIGGIO: tutta visibile, i corridoi aperti, e il
			# punto esclamativo che si e' spostato sulla sala comunicazioni.
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			GameState.imposta_flag("rientro_infermeria")
			GameState.nodo_corrente = "infermeria"
			for id_stanza in ["alloggio", "sala_allenamento", "sala_comunicazioni",
					"infermeria", "archivio", "mensa", "sala_proiezione", "hangar"]:
				GameState.sblocca_stanza(id_stanza)
			var dopo: Control = load("res://scenes/MappaZona.tscn").instantiate()
			dopo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(dopo)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"complesso":
			# la mappa del complesso: tutte le aree visibili, una sola aperta,
			# e il punto esclamativo che salta
			GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
			GameState.nodo_corrente = "alloggio"
			for id_stanza in ["alloggio", "sala_allenamento", "sala_comunicazioni",
					"infermeria", "archivio", "mensa", "sala_proiezione", "hangar"]:
				GameState.sblocca_stanza(id_stanza)
			if not "alloggio" in GameState.nodi_visitati:
				GameState.nodi_visitati.append("alloggio")
			# SENZA DIRGLI QUANTO E' GRANDE, una schermata non si dispone: in
			# gioco ci pensa Transizioni, che la mette come scena corrente. Qui
			# no, e la prima foto usciva con la mappa schiacciata in un angolo -
			# un difetto del fotografo scambiabile per un difetto della mappa.
			var schermo: Control = load("res://scenes/MappaZona.tscn").instantiate()
			schermo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(schermo)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"paragrafo":
			# UN PARAGRAFO VERO, per guardare la forma del testo: l'interlinea,
			# la lunghezza della riga, i margini del box. Su una battuta di
			# quattro parole non si giudica niente - e le schermate che
			# avevamo mostravano tutte una riga sola.
			await apri_dialogo(nodo_di_prova())
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			var pagina := get_child(0)
			pagina.box.mostra("narrazione",
					"Nell'universo la vita prende forme che nessuno aveva " +
					"previsto, e ognuna di loro si porta dietro una fame che " +
					"non sa di avere. Le Fratture si aprono dove quella fame " +
					"diventa piu' forte del posto che la contiene.", "")
			pagina.box.completa()
			await attendi(4)
		"pagine":
			# UN TESTO LUNGO DIVISO IN PAGINE (vedi Impaginatore.gd): "pagine
			# eventi 1" e' la seconda pagina nel box degli eventi, "pagine
			# combattimento 0" la prima nel quadrante dello scontro. Il testo e'
			# la soglia della Casa Gigante, il piu' lungo del gioco
			var argomenti_p := OS.get_cmdline_user_args()
			var dove := String(argomenti_p[1]) if argomenti_p.size() > 1 else "eventi"
			var quale_pagina := int(argomenti_p[2]) if argomenti_p.size() > 2 else 0
			var casa: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/vuoti/casa_gigante.json"))
			var lungo := String(casa["nodi"]["soglia"]["sequenza"][0]["testo"])
			var con_box: Node
			if dove == "combattimento":
				GameState.nuova_partita()
				GameState.nemici_combattimento = ["goblin_tipico"]
				con_box = load("res://scenes/Combattimento.tscn").instantiate()
				add_child(con_box)
				await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
				con_box.set_process(false)
				con_box.voce.coda.clear()
				con_box.plancia.mostra_faccia("parlato")
			else:
				await apri_dialogo(nodo_di_prova())
				con_box = get_child(0)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			con_box.box.mostra("narrazione", lungo, "")
			for volta in quale_pagina + 1:
				con_box.box.completa()
				if volta < quale_pagina:
					con_box.box.pagina_seguente()
			await attendi(4)
			print("pagina %d di %d" % [con_box.box.pagina + 1, con_box.box.pagine.size()])
		"indica":
			# COME LA LEZIONE INDICA UN PEZZO: la battuta vera del tutorial di
			# Veronica che lo nomina, con lo stile chiesto - "indica ecg pennarello"
			# (gli stili in IndicazioneCombattimento.STILI). Con "film" in fondo, la
			# pellicola dell'arrivo invece dello scatto fermo
			var arg_i := OS.get_cmdline_user_args()
			var quale_i := String(arg_i[1]) if arg_i.size() > 1 else "ecg"
			if arg_i.size() > 2:
				Stile.dati["indicazione"] = {"stile": String(arg_i[2])}
			GameState.nuova_partita()
			GameState.nemici_combattimento = ["veronica"]
			var con_lezione: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(con_lezione)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			# le battute d'apertura si saltano: si vuole quella che indica
			for i in 40:
				if con_lezione.voce.niente_da_leggere():
					break
				con_lezione.voce.coda.clear()
				con_lezione.voce.avanza()
				await attendi(3)
			con_lezione.scrivi_messaggio_tutorial(battuta_che_indica(quale_i))
			if "film" in arg_i:
				await pellicola("res://scatti/indica_%s_pellicola.png" % quale_i)
			else:
				await attendi(30)
				con_lezione.box.completa()
				await attendi(20)
		"evidenza":
			# L'EVIDENZA CHE INDICA UN PEZZO, arrivata tutta: "evidenza bond
			# cornice" fotografa BOND con lo stile cornice (gli stili stanno in
			# Evidenza.STILI; senza, quello di stile.json). Si ferma l'entrata e
			# la si mette a mano tutta fuori, cosi' la foto e' sempre lo stesso
			# istante e due stili si possono confrontare.
			GameState.nuova_partita()
			GameState.party = ["anonimo", "veronica"]
			GameState.nemici_combattimento = ["marionetta"]
			var indicato: Node = load("res://scenes/Combattimento.tscn").instantiate()
			add_child(indicato)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			indicato.voce.coda.clear()
			indicato.set_process(false)
			indicato.plancia.mostra_faccia("comandi")
			var quale_pezzo := "mattanza"
			var argomenti_alone := OS.get_cmdline_user_args()
			if argomenti_alone.size() > 1:
				quale_pezzo = String(argomenti_alone[1])
			if argomenti_alone.size() > 2:
				Stile.dati["evidenza"] = {"stile": String(argomenti_alone[2])}
			indicato.plancia.evidenzia_pezzo(quale_pezzo)
			if indicato.plancia.alone_evidenza != null:
				indicato.plancia.alone_evidenza.ferma()
				indicato.plancia.alone_evidenza.completa()
				indicato.plancia.alone_evidenza.fase = 0.5
			if argomenti_alone.size() > 3 and String(argomenti_alone[3]) == "col_nome":
				# IL NOME DELLO STILE SULLA FOTO, per il foglio di confronto: Bru
				# sceglie guardando, e sotto ogni foto deve leggere cosa sta guardando
				var cartello := Cartiglio.nuovo(Evidenza.stile_scelto().replace("_", " ").to_upper(),
						Stile.colore("accento"), Stile.colore("testo"), Stile.colore("bordo_acceso"), 40)
				add_child(cartello)
				cartello.size = cartello.get_combined_minimum_size()
				cartello.position = Vector2(640.0 - cartello.size.x * 0.5, 300.0)
				cartello.svela(0.0)
				await attendi(20)
			await attendi(2)
		"zona":
			# LA MAPPA A QUADRETTI, quella che non aspetta nessun disegno.
			#
			# Il complesso e' una pianta e la pianta la disegna Bru; una zona
			# invece si costruisce da se', e quindi e' l'unica delle due che si
			# puo' guardare adesso. Casa Gigante e' la piu' grande che abbiamo -
			# ventisette stanze - ed e' il caso in cui una mappa o regge o non
			# regge: su sei stanze qualunque disposizione sembra buona.
			# "zona meridia", "zona rocca_ossidiana tutto": un'altra zona di
			# data/vuoti, e con "tutto" visitata da cima a fondo
			var argomenti_zona := OS.get_cmdline_user_args()
			var quale_zona := String(argomenti_zona[1]) if argomenti_zona.size() > 1 else "casa_gigante"
			var tutta := argomenti_zona.size() > 2 and String(argomenti_zona[2]) == "tutto"
			GameState.nuova_partita()
			GameState.avvia_carnivalz(quale_zona, "res://data/vuoti/%s.json" % quale_zona)
			# "inizio": appena arrivati, una stanza sola e quello che le confina
			if argomenti_zona.size() > 2 and String(argomenti_zona[2]) == "inizio":
				GameState.nodi_visitati.append(GameState.nodo_corrente)
				var appena: Control = load("res://scenes/MappaZona.tscn").instantiate()
				appena.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				add_child(appena)
				await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
				return
			# MEZZA ESPLORATA, non tutta: una mappa tutta accesa non dice niente
			# di come si legge mentre ci stai dentro. Si sbloccano tutte (cosi'
			# si vedono) ma se ne visitano solo le prime, che e' la situazione
			# vera di chi ci sta girando.
			var stanze_zona: Array = GameState.mappa_zona.get("stanze", [])
			for stanza in stanze_zona:
				GameState.sblocca_stanza(String(stanza.get("id", "")))
			for i in (stanze_zona.size() if tutta else mini(floori(stanze_zona.size() / 2.0), stanze_zona.size())):
				var id_visitata := String(stanze_zona[i].get("id", ""))
				if not id_visitata in GameState.nodi_visitati:
					GameState.nodi_visitati.append(id_visitata)
			if not stanze_zona.is_empty():
				GameState.nodo_corrente = String(stanze_zona[2].get("id", ""))
			var quadretti: Control = load("res://scenes/MappaZona.tscn").instantiate()
			quadretti.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(quadretti)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
		"negozio":
			# IL NEGOZIO NUOVO, sullo schema di Bru: "negozio" col primo negozio,
			# "negozio artigiano" coi baratti, "negozio povero" senza un Tazo
			GameState.nuova_partita()
			var argomenti_negozio := OS.get_cmdline_user_args()
			var variante := String(argomenti_negozio[1]) if argomenti_negozio.size() > 1 else ""
			GameState.negozi_sbloccati = ["organizzazione", "nyu", "artigiano"] as Array[String]
			GameState.tazo = 0 if variante == "povero" else 140
			GameState.sacca.append("razione_del_circo")
			GameState.sacca.append("razione_del_circo")
			var bottega: Control = load("res://scenes/Negozio.tscn").instantiate()
			add_child(bottega)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			if variante == "artigiano":
				bottega.apri_negozio("artigiano")
				bottega.seleziona(bottega.fila.size() - 1, true)
			elif variante != "povero":
				bottega.seleziona(1, true)
			await attendi(40)
		"scheda":
			# LA SCHEDA DELLA SQUADRA CON UNA SQUADRA VERA: quattro compagni (le
			# carte scorrono), uno solo di passaggio, qualcosa addosso e qualcosa
			# da mettere. "scheda scelta" apre l'arma e passa sulla mannaia;
			# "scheda passaggio" guarda chi e' con te solo per un tratto
			GameState.nuova_partita()
			for id_compagno in ["sally", "vega"]:
				GameState.recluta(id_compagno)
			GameState.recluta_temporaneo("niru", 3)
			for id_oggetto in ["coltello_di_servizio", "mannaia_scheggiata", "amuleto_di_pietra",
					"amuleto_di_ferro", "stigma_del_muto", "benda_stretta"]:
				GameState.aggiungi_oggetto(id_oggetto)
			GameState.equipaggia(GameState.id_protagonista, "arma", "coltello_di_servizio")
			GameState.equipaggia("sally", "accessori", "amuleto_di_ferro")
			var argomenti_scheda := OS.get_cmdline_user_args()
			var variante_scheda := String(argomenti_scheda[1]) if argomenti_scheda.size() > 1 else ""
			var scheda := SchedaPersonaggio.new()
			add_child(scheda)
			scheda.apri(Callable(), Callable())
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			if variante_scheda == "scelta":
				scheda._su_casella(scheda.caselle[1])
				await attendi(5)
				var voci := scheda.elenco.get_children().filter(func(v: Node) -> bool: return v is VoceCandidato)
				if voci.size() > 1:
					(voci[1] as VoceCandidato).grab_focus()
			elif variante_scheda == "passaggio":
				scheda.cambia_compagno("niru")
			await attendi(20)
		"sede":
			# LA SEDE, che e' la schermata su cui si torna piu' volte di tutte:
			# ci si passa dopo ogni Carnivalz, ed e' li' che si salva. Bru:
			# «siamo ancora disordinati e l'interfaccia non e' accattivante,
			# alcune cose sono illeggibili, altre fuori inquadratura».
			# Adesso e' il complesso (events_sede.json): "sede girata" ci arriva
			# dopo aver gia' visto qualche stanza, e indica l'emporio
			GameState.nuova_partita()
			var argomenti_sede := OS.get_cmdline_user_args()
			if argomenti_sede.size() > 1 and String(argomenti_sede[1]) == "girata":
				GameState.nodi_visitati.append_array(["alloggio", "sala_operativa", "mensa", "archivio"])
			var casa: Control = load("res://scenes/Sede.tscn").instantiate()
			casa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(casa)
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO)
			if argomenti_sede.size() > 1 and String(argomenti_sede[1]) == "girata":
				(casa.get_child(-1) as MappaZona)._indica_stanza("emporio")
				await attendi(4)
			# "sede piano": il piano terra da solo, gli altri spenti
			if argomenti_sede.size() > 1 and String(argomenti_sede[1]) == "piano":
				var pianta := casa.get_child(-1) as MappaZona
				pianta.plastico.isola(0)
				await attendi(40)
				pianta._indica_stanza("emporio")
				await attendi(4)
		"rottura":
			# il vetro a meta' caduta: e' l'unico modo di guardarlo, perche'
			# dura poco piu' di un secondo e a occhio nudo non si ferma
			await apri_dialogo(nodo_di_prova())
			# LE SCELTE NON CI SONO FINCHE' IL TESTO NON HA FINITO DI SCRIVERSI.
			# Aspettando poco si cercava un orologio che non era ancora nato, non
			# si rompeva niente, e lo scatto veniva identico a quello di prima -
			# una foto verde di una cosa che non era successa.
			await attendi(FOTOGRAMMI_DI_ASSESTAMENTO + 40)
			var orologio := cerca_orologio(self)
			if orologio == null:
				push_error("Scatto 'rottura': nessun orologio in campo, non c'e' niente da rompere")
				return
			orologio._process(99.0)   # il tempo scade
			orologio._process(1.0)    # il vetro si crepa in tre colpi, e cede
			await attendi(22)   # a meta' caduta: i pezzi sono in aria e ancora visibili
		_:
			await apri_dialogo()

func battuta_che_indica(quale: String) -> Dictionary:
	# la prima battuta del tutorial di Veronica che nomina quel pezzo
	for passo in (GameState.personaggi.get("veronica", {}) as Dictionary).get("tutorial_combattimento", {}).get("passi", []):
		for dove in ["prima", "dopo"]:
			for msg in (passo as Dictionary).get(dove, []):
				if quale in String((msg as Dictionary).get("evidenzia", "")).split(","):
					return msg
	return {"tipo": "narrazione", "testo": "(nessuna battuta indica «%s»)" % quale, "evidenzia": quale}


func nodo_di_prova() -> Dictionary:
	# La stanza finta del disegno di Bru: qualcuno che parla, due scelte a tempo
	# (una da villain e una da eroe) e tre normali. Non e' contenuto del gioco -
	# e' il metro su cui si misura se la schermata e' venuta come il disegno.
	return {
		"sequenza": [
			{"tipo": "dialogo", "chi": "brawler", "testo": "So what's your choice?"},
		],
		"scelte": [
			{"testo": "Evil option", "genere": "malvagio", "tempo": 6.0, "vai": "scatto_prova"},
			{"testo": "Hero option", "genere": "eroe", "tempo": 6.0, "vai": "scatto_prova"},
			{"testo": "Choice 1", "vai": "scatto_prova"},
			{"testo": "Choice 2", "vai": "scatto_prova"},
			{"testo": "Choice 3", "vai": "scatto_prova"},
		],
		"destra": {"id": "brawler", "espr": "decisa"},
	}

func nodo_lastra(come: String) -> Dictionary:
	# una battuta vera per ogni situazione della lastra: Veronica e il
	# protagonista in events_intro, la sala di proiezione in events_tutorial,
	# la convocazione e la Dr. Reika in events_intro
	var battute := {
		"parla": {"tipo": "dialogo", "chi": "veronica", "testo": "Ricordo ancora la mia prima missione, evidentemente ero troppo forte, non rimase nulla di quella povera creatura..."},
		"tu": {"tipo": "dialogo", "chi": "anonimo", "testo": "Non ci si può far niente vero? D'altronde questo è il nostro ultimo allenamento..."},
		"narrazione": {"tipo": "narrazione", "testo": "La piattaforma della sala di proiezione, e l'odore di metallo freddo che non avevi notato all'andata."},
		"avviso": {"tipo": "notifica", "testo": "Hai una nuova convocazione. Aprire il canale?"},
		"scelte": {"tipo": "dialogo", "chi": "reika", "testo": "Hey ciao di nuovo, hai dimenticato qualcosa?"},
	}
	var scelte := {
		"avviso": [{"testo": "Sì", "vai": "scatto_prova"}, {"testo": "No", "vai": "scatto_prova"}],
		"scelte": [{"testo": "Volevo chiederti cosa ne pensi dell'organizzazione", "vai": "scatto_prova"},
				{"testo": "Sei mai andata in missione?", "vai": "scatto_prova"},
				{"testo": "Mi sono sbagliato, vado.", "vai": "scatto_prova"}],
	}
	return {"sequenza": [battute.get(come, battute["parla"])], "scelte": scelte.get(come, [])}

func riempi_lo_zaino(scomparto: String) -> void:
	# UNO ZAINO DA META' PARTITA: qualcosa in ogni scomparto, l'arma in mano,
	# e tre cose arrivate da poco (NUOVO), il resto gia' guardato
	for id_oggetto in ["razione_del_circo", "razione_del_circo", "razione_del_circo", "tonico_calmante",
			"tonico_calmante", "benda_stretta", "petardo", "molotov", "fiala_aura", "fiore_di_luna",
			"carbone_attivo", "frammento_di_vita", "coltello_di_servizio", "mannaia_scheggiata",
			"pietra_quieta", "amuleto_di_ferro", "stigma_del_veglio", "spilla_margherita",
			"rottame_di_metallo", "ricordi_felici"]:
		GameState.aggiungi_oggetto(id_oggetto)
	GameState.equipaggia(GameState.id_protagonista, "arma", "coltello_di_servizio")
	GameState.aggiungi_alla_pila("cianfrusaglia", 12)
	GameState.oggetti_visti.clear()
	for scomparto_qualunque in ElencoZaino.SCOMPARTI:
		for id_oggetto in ElencoZaino.pezzi(String(scomparto_qualunque[0])):
			if String(id_oggetto) not in ["molotov", "frammento_di_vita", "mannaia_scheggiata", "ricordi_felici"]:
				ElencoZaino.segna_visto(String(id_oggetto))
	ElencoZaino.aperto = scomparto

func apri_dialogo(finto: Dictionary = {}) -> void:
	GameState.avvia_carnivalz("intro", "res://data/events_intro.json")
	if not finto.is_empty():
		GameState.eventi["scatto_prova"] = finto
		GameState.nodo_corrente = "scatto_prova"
	IngressoNodo.ultimo_esito = {}
	var scena: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(scena)
	await attendi(2)

func cerca_orologio(radice: Node) -> Node:
	for figlio in radice.get_children():
		if figlio.has_signal("scaduto"):
			return figlio
		var dentro := cerca_orologio(figlio)
		if dentro != null:
			return dentro
	return null

func salva(quale: String) -> void:
	var immagine := get_viewport().get_texture().get_image()
	var percorso := "%s%s.png" % [CARTELLA, quale]
	immagine.save_png(ProjectSettings.globalize_path(percorso))
	print("scatto salvato: %s  (%dx%d)" % [percorso, immagine.get_width(), immagine.get_height()])
