class_name GuidaSullaMappa
extends Control

# LA GUIDA CHE PARLA SOPRA LA MAPPA. Bru, all'arrivo nelle Pianure di Redenna:
# «qui si apre la mappa e si spiega come funziona il livello e le fratture».
# La Guida dice «ti trovi nel settore delle Pianure di Redenna, vedi?» - e per
# dirlo la mappa dev'essere li', aperta, con dentro il posto in cui sei.
#
# Quindi non e' una didascalia nel dialogo e non e' un'immagine: e' la mappa di
# zona vera, la stessa del tasto «Mappa», con sopra il box della Guida. Le
# battute stanno nei dati della zona (mappa_dungeon.guida), perche' parlano
# della zona e non di una scena: le ridice uguali quando premi la sua icona.
#
# IL TASTO DI CHIUSURA LO PREME CHI GIOCA. Nel testo di Bru c'e' «Protagonista:
# preme sul tasto di chiusura», e lei risponde «Ma che maniere sono!». Il tasto
# e' quello della mappa, e la protesta arriva comunque tu lo prema: alla fine
# della spiegazione, o a meta', che e' anche piu' divertente.
#
#   GuidaSullaMappa.apri({"ritorno": "inizio_guida", "solo_chiudere": true})
#
# "ritorno" e' il nodo a cui si va chiudendo la mappa (se manca, la stanza in
# cui sei); "solo_chiudere" spegne le stanze finche' lei parla: andandosene di
# li' si salterebbe il resto della scena.

const SCENA_MAPPA_ZONA := "res://scenes/MappaZona.tscn"
const SCENA_BOX := "res://scenes/BoxTesto.tscn"
const MARGINE := 24.0

# la visita in corso: {"righe": [...], "ritorno": id, "solo_chiudere": bool}.
# Vive fra due schermate - la decide il dialogo, la legge la mappa - come
# MappaStellare.missione_da_scegliere
static var in_corso: Dictionary = {}

var righe: Array = []
var quale := -1
var box: Node
var mappa: Node


static func apri(dati: Dictionary) -> void:
	in_corso = {
		"zona": GameState.carnivalz_corrente,
		"righe": GameState.mappa_zona.get("guida", []),
		"ritorno": String(dati.get("ritorno", GameState.nodo_corrente)),
		"solo_chiudere": bool(dati.get("solo_chiudere", false)),
	}
	Transizioni.vai(SCENA_MAPPA_ZONA)


static func sta_parlando() -> bool:
	# e solo nella zona in cui ha cominciato: una partita caricata, o una zona
	# nuova, non deve ritrovarsi addosso la spiegazione delle Pianure
	if not in_corso.is_empty() and String(in_corso.get("zona", "")) != GameState.carnivalz_corrente:
		in_corso = {}
	return not in_corso.is_empty()


static func solo_chiudere() -> bool:
	return bool(in_corso.get("solo_chiudere", false))


static func dove_tornare() -> String:
	# chiudendo la mappa: il nodo che la Guida aveva in mente, o la tua stanza.
	# E si scorda la visita, o la prossima mappa riaprirebbe la spiegazione
	var dove := String(in_corso.get("ritorno", GameState.nodo_corrente))
	in_corso = {}
	return dove


static func accompagna(schermata: Node) -> GuidaSullaMappa:
	var guida := GuidaSullaMappa.new()
	guida.mappa = schermata
	guida.righe = in_corso.get("righe", [])
	schermata.add_child(guida)
	return guida


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	box = (load(SCENA_BOX) as PackedScene).instantiate()
	add_child(box)
	# in basso, largo come quello del dialogo: e' lo stesso box, e deve sembrarlo
	(box as Control).set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	(box as Control).offset_left = MARGINE
	(box as Control).offset_right = -MARGINE
	(box as Control).offset_bottom = -MARGINE
	(box as Control).grow_vertical = Control.GROW_DIRECTION_BEGIN
	(box as Control).gui_input.connect(_su_input_box)
	fai_posto()
	avanti()


func fai_posto() -> void:
	# LA MAPPA SI FERMA SOPRA IL BOX. Messo sopra e basta, il box copriva la
	# riga piu' in basso della mappa - e nelle Pianure la riga piu' in basso e'
	# il punto d'atterraggio, cioe' proprio il posto di «vedi?». L'ha fatto
	# vedere il primo scatto
	var alto := (box as Control).get_combined_minimum_size().y + MARGINE * 2.0
	for figlio in mappa.get_children():
		if figlio is MarginContainer:
			(figlio as MarginContainer).add_theme_constant_override("margin_bottom", int(alto))


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_su_clic()


func _su_input_box(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and (evento as InputEventMouseButton).pressed \
			and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		_su_clic()


func _su_clic() -> void:
	# come nel dialogo: il primo clic completa la frase, il secondo va avanti
	if box.sta_scrivendo:
		box.completa()
		return
	avanti()


func avanti() -> void:
	# all'ultima battuta ci si ferma: la Guida ha fatto la sua domanda, e la
	# risposta e' il tasto di chiusura
	if quale >= righe.size() - 1:
		return
	quale += 1
	var riga: Dictionary = righe[quale]
	var chi := String(riga.get("chi", "guida"))
	var nome := String(GameState.personaggi.get(chi, {}).get("nome", chi))
	var testo := Testi.accorda(String(riga.get("testo", "")), GameState.sesso_protagonista)
	GameState.registra_storico("dialogo", nome, testo)
	box.mostra("dialogo", testo, nome)
	# «vedi?»: l'anello si accende sul posto in cui sei, e si spegne alla dopo
	if String(riga.get("indica", "")) == "qui":
		mappa.call("_indica_stanza", GameState.nodo_corrente)
	else:
		mappa.call("_smetti_di_indicare")
