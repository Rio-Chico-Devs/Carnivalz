class_name ElencoPosti
extends ScrollContainer

# LA LEGENDA: I POSTI CHE CONOSCI, SCRITTI PER ESTESO.
#
# Fino a ieri il nome di una stanza si leggeva in un modo solo: passandoci
# sopra col mouse. Uno alla volta, e solo col mouse - col tasto non si leggeva
# niente, perche' in Godot il suggerimento non compare quando un bottone
# prende il fuoco da tastiera. Una mappa su cui devi strisciare il cursore per
# sapere cosa stai guardando non e' una mappa, e' un indovinello.
#
# PERCHE' UNA LEGENDA E NON LE ETICHETTE SUI QUADRATI. Ci ho provato coi
# numeri veri prima di decidere: i nomi delle nostre stanze arrivano a 27
# caratteri ("Vecchio centro di controllo") e i quadratini stanno fra 30 e 104
# pixel di lato. Per farci entrare 27 caratteri ci vorrebbe un corpo di
# quattro pixel. Non e' una questione di trovare la disposizione giusta: non
# ci stanno, e nessuna tipografia li fa entrare.
#
# Quando le etichette non ci stanno, la cartografia ha una risposta sola ed e'
# vecchia di secoli: la legenda. Si mette di fianco, si scrive alla misura in
# cui si legge, e si lega alla figura.
#
# LEGARLA E' LA PARTE CHE CONTA. Una legenda che non si lega alla mappa e' una
# tabella: leggi un nome, e poi devi cercartelo. Qui il legame e' in tutt'e
# due i versi - passi su una riga e il quadrato si illumina, passi su un
# quadrato e si illumina la riga - ed e' l'unica cosa che trasforma un elenco
# in una chiave di lettura.
#
# E SI CAMMINA ANCHE DA QUI. Ogni riga fa esattamente quello che fa il suo
# quadrato: ci vai, o ti dice perche' non ci si va. Non e' una comodita' in
# piu', e' l'unico modo di girare la mappa senza mouse.
#
# I POSTI DI CUI NON SAI IL NOME NON CI SONO. Un posto che hai solo intravisto
# - sai che di la' c'e' qualcosa perche' confina con dove sei stato - sulla
# mappa e' un "?", e un "?" in una lista di nomi sarebbe una riga vuota che
# occupa un posto. Quelli si scoprono camminando, ed e' giusto cosi'.

signal indicato(id_stanza: String)   # ci sei sopra, o ci sei arrivato col tasto
signal lasciato()
signal scelto(id_stanza: String)

const LARGHEZZA := 400   # "Vecchio centro di controllo" a corpo 22 ne chiede 349
const LATO_QUADRATINO := 26

var colonna: VBoxContainer
var righe_per_id: Dictionary = {}


func _ready() -> void:
	custom_minimum_size.x = LARGHEZZA
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	colonna = VBoxContainer.new()
	colonna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	colonna.add_theme_constant_override("separation", 4)
	add_child(colonna)


func riempi(posti: Array) -> void:
	# "posti" arriva gia' deciso dalla mappa: cosa si sa, cosa si raggiunge,
	# di che tipo e'. Qui dentro non si interroga il mondo, si disegna - se no
	# sarebbero due posti diversi che decidono la stessa cosa, e prima o poi
	# uno dei due la decide in modo diverso.
	Albero.svuota(colonna)
	righe_per_id.clear()
	if posti.is_empty():
		colonna.add_child(nota("Non conosci ancora nessun posto di qui."))
		return
	colonna.add_child(nota("I posti che conosci"))
	for posto in posti:
		var riga := costruisci_riga(posto)
		colonna.add_child(riga)
		righe_per_id[String(posto.get("id", ""))] = riga


func nota(testo: String) -> Label:
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.add_theme_color_override("font_color", Stile.colore("testo_smorzato"))
	Stile.imposta_corpo(etichetta, Stile.dimensione("corpo"))
	return etichetta


func costruisci_riga(posto: Dictionary) -> Button:
	var id_stanza := String(posto.get("id", ""))
	var raggiungibile := bool(posto.get("raggiungibile", false))
	var riga := Button.new()
	riga.flat = false   # la stessa trappola della mappa: piatto non disegna niente
	riga.text = "   " + String(posto.get("nome", id_stanza))
	riga.alignment = HORIZONTAL_ALIGNMENT_LEFT
	riga.tooltip_text = "" if raggiungibile else "Troppo lontano per andarci da qui."
	Stile.imposta_corpo(riga, Stile.dimensione("piccolo"))
	riga.add_theme_color_override("font_color",
			Stile.colore("testo") if raggiungibile else Stile.colore("testo_smorzato"))
	vesti_riga(riga)
	metti_quadratino(riga, posto)
	riga.pressed.connect(func() -> void: scelto.emit(id_stanza))
	riga.mouse_entered.connect(func() -> void: indicato.emit(id_stanza))
	riga.focus_entered.connect(func() -> void: indicato.emit(id_stanza))
	riga.mouse_exited.connect(func() -> void: lasciato.emit())
	riga.focus_exited.connect(func() -> void: lasciato.emit())
	return riga


func vesti_riga(riga: Button) -> void:
	for stato in ["normal", "hover", "pressed", "focus"]:
		var scatola := StyleBoxFlat.new()
		scatola.bg_color = Color(Stile.colore("tratto"), 0.0 if stato == "normal" else 0.30)
		scatola.content_margin_left = LATO_QUADRATINO + 10
		scatola.content_margin_right = 8
		scatola.content_margin_top = 4
		scatola.content_margin_bottom = 4
		scatola.set_corner_radius_all(3)
		riga.add_theme_stylebox_override(stato, scatola)


func metti_quadratino(riga: Button, posto: Dictionary) -> void:
	# IL QUADRATINO DELLA RIGA E' LO STESSO DELLA MAPPA, tinta e tratteggio
	# compresi. Una legenda che disegna il suo simbolo diverso da come lo
	# disegna la figura non e' una legenda: e' un secondo disegno che dice
	# un'altra cosa, e il lettore deve indovinare quale delle due vale.
	var tinta: Color = posto.get("tinta", Color.MAGENTA)
	var segreta := bool(posto.get("segreta", false))
	var visitata := bool(posto.get("visitata", false))
	var bollo := Control.new()
	# ancorato a meta' altezza della riga: un Button non e' un contenitore e
	# non sistema i figli, quindi la posizione gliela si dice per intero
	bollo.anchor_top = 0.5
	bollo.anchor_bottom = 0.5
	bollo.offset_left = 6.0
	bollo.offset_right = 6.0 + LATO_QUADRATINO
	bollo.offset_top = -LATO_QUADRATINO * 0.5
	bollo.offset_bottom = LATO_QUADRATINO * 0.5
	bollo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bollo.draw.connect(func() -> void:
		var dentro := Rect2(Vector2.ZERO, bollo.size)
		if visitata:
			bollo.draw_rect(dentro, tinta)
			if segreta:
				Tratteggio.dentro(bollo, dentro, tinta.lightened(0.45))
		else:
			bollo.draw_rect(dentro, Color(tinta, 0.12))
		bollo.draw_rect(dentro, tinta, false, 2.0))
	riga.add_child(bollo)


func evidenzia(id_stanza: String) -> void:
	# il verso opposto del legame: il mouse sta sulla mappa, e qui si accende
	# la riga che parla di quel quadrato
	for id_riga in righe_per_id:
		var riga: Button = righe_per_id[id_riga]
		riga.modulate.a = 1.0 if (id_stanza == "" or id_riga == id_stanza) else 0.45
