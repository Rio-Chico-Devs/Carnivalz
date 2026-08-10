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

const LATO_MINIMO := 30.0     # sotto questa misura un quadratino non si legge
const LATO_MASSIMO := 104.0   # sopra, una zona piccola diventa ridicola
const MARGINE_CELLA := 5.0    # aria fra il quadrato e il bordo della sua cella

var stanze_per_id: Dictionary = {}
var colonne := 1
var righe := 1
var lato := 64.0
var origine := Vector2.ZERO

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

	for stanza in GameState.mappa_zona.get("stanze", []):
		stanze_per_id[String(stanza.get("id", ""))] = stanza
		var cella := cella_di(stanza)
		var misura := dimensione_di(stanza)
		colonne = maxi(colonne, int(cella.x + misura.x))
		righe = maxi(righe, int(cella.y + misura.y))

	costruisci_intelaiatura()
	resized.connect(ricostruisci)
	ricostruisci()

# --- lettura dei dati ----------------------------------------------------

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
	var colonna := VBoxContainer.new()
	colonna.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	colonna.add_theme_constant_override("separation", 12)
	add_child(colonna)

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
	lato = clampf(minf(spazio.x / float(colonne), spazio.y / float(righe)),
			LATO_MINIMO, LATO_MASSIMO)
	origine = (spazio - Vector2(colonne, righe) * lato) * 0.5
	disegna_bottoni()
	strato_sotto.queue_redraw()
	strato_sopra.queue_redraw()

func rettangolo_di(stanza: Dictionary) -> Rect2:
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
	for coppia in GameState.mappa_zona.get("connessioni", []):
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

# --- i quadratini --------------------------------------------------------

func disegna_bottoni() -> void:
	for figlio in strato_bottoni.get_children():
		figlio.queue_free()
	for stanza in GameState.mappa_zona.get("stanze", []):
		var id_stanza := String(stanza.get("id", ""))
		if not si_vede(id_stanza):
			continue   # non se ne conosce nemmeno l'esistenza
		var rettangolo := rettangolo_di(stanza)
		var bottone := Button.new()
		bottone.flat = true
		bottone.position = rettangolo.position
		bottone.size = rettangolo.size
		bottone.tooltip_text = String(stanza.get("nome", id_stanza))
		bottone.mouse_filter = Control.MOUSE_FILTER_STOP
		var noto := GameState.stanza_sbloccata(id_stanza)
		if visitata(id_stanza):
			vesti_pieno(bottone, e_segreta(stanza))
		else:
			# il punto di domanda del disegno di Bru: quello che invita ad andarci
			bottone.text = "?"
			bottone.add_theme_font_size_override("font_size", int(lato * 0.5))
			vesti_vuoto(bottone, noto)
		bottone.pressed.connect(_su_stanza.bind(id_stanza, noto))
		bottone.mouse_entered.connect(func() -> void:
			etichetta_stato.text = String(stanza.get("nome", id_stanza)) if noto or visitata(id_stanza) else "?")
		strato_bottoni.add_child(bottone)

func vesti_pieno(bottone: Button, segreta: bool) -> void:
	var tinta := Stile.colore("positivo") if segreta else Stile.colore("pericolo")
	for stato in ["normal", "hover", "pressed", "focus"]:
		var scatola := StyleBoxFlat.new()
		scatola.bg_color = tinta.lightened(0.12) if stato != "normal" else tinta
		scatola.set_corner_radius_all(3)
		scatola.set_border_width_all(2)
		scatola.border_color = tinta.darkened(0.35)
		bottone.add_theme_stylebox_override(stato, scatola)

func vesti_vuoto(bottone: Button, noto: bool) -> void:
	var tinta := Stile.colore("accento") if noto else Stile.colore("bordo")
	bottone.add_theme_color_override("font_color", Color(tinta, 0.95 if noto else 0.5))
	for stato in ["normal", "hover", "pressed", "focus"]:
		var scatola := StyleBoxFlat.new()
		scatola.bg_color = Color(tinta, 0.10 if stato == "normal" else 0.20)
		scatola.set_corner_radius_all(3)
		scatola.set_border_width_all(2)
		scatola.border_color = Color(tinta, 0.9 if noto else 0.45)
		bottone.add_theme_stylebox_override(stato, scatola)

func _su_stanza(id_stanza: String, noto: bool) -> void:
	if not noto:
		# un vicolo cieco per ora: non si finge che il click non sia successo
		etichetta_stato.text = "Da questa parte non si passa, per ora."
		return
	GameState.nodo_corrente = id_stanza
	IngressoNodo.vai_al_nodo(id_stanza)

# --- strato di sotto: la griglia e i collegamenti -----------------------

func _disegna_sotto() -> void:
	var reticolo := Color(Stile.colore("bordo"), 0.22)
	for c in colonne + 1:
		var x := origine.x + c * lato
		strato_sotto.draw_line(Vector2(x, origine.y),
				Vector2(x, origine.y + righe * lato), reticolo, 1.0)
	for r in righe + 1:
		var y := origine.y + r * lato
		strato_sotto.draw_line(Vector2(origine.x, y),
				Vector2(origine.x + colonne * lato, y), reticolo, 1.0)

	for coppia in GameState.mappa_zona.get("connessioni", []):
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
				Color(Stile.colore("bordo"), 0.95 if pieno else 0.5),
				maxf(lato * 0.09, 3.0))

# --- strato di sopra: icone e "sei qui" ---------------------------------

func _disegna_sopra() -> void:
	for stanza in GameState.mappa_zona.get("stanze", []):
		var id_stanza := String(stanza.get("id", ""))
		if not si_vede(id_stanza):
			continue
		var rettangolo := rettangolo_di(stanza)
		if visitata(id_stanza):
			disegna_icona(String(stanza.get("icona", "")), rettangolo)
		if id_stanza == GameState.nodo_corrente:
			disegna_sei_qui(rettangolo)

func disegna_icona(icona: String, rettangolo: Rect2) -> void:
	if icona == "":
		return
	# se il disegno c'e' vince lui: aggiungere un'icona e' aggiungere un file
	var percorso := CARTELLA_ICONE + icona + ".png"
	if ResourceLoader.exists(percorso):
		var texture: Texture2D = load(percorso)
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
