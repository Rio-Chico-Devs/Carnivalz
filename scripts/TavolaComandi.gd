class_name TavolaComandi
extends PanelContainer

# I COMANDI, DISEGNATI. Bru: «il come si gioca non deve essere cosi' ma avere
# una spiegazione grafica con i tasti da tastiera o mouse sui comandi come in un
# gioco professionale».
#
# Prima COME SI GIOCA erano quattro consigli scritti: «Invio para il pugno piu'
# vicino» in mezzo a una frase. Nei giochi fatti bene i comandi non si leggono,
# si guardano: a sinistra il tasto disegnato come un tasto, a destra cosa fa.
# Qui le categorie sono le voci del menu (MENU, STORIA, COMBATTIMENTO, MOSSE
# SPECIALI), e questa tavola - a destra, dove di solito stanno le partite -
# mostra i comandi di quella accesa.
#
# I TASTI NON SONO SCRITTI A OCCHIO. Ognuno corrisponde a un'azione dell'elenco
# dei comandi di Godot (AZIONE_DI), e una prova controlla che quel tasto sia
# davvero legato a quell'azione: se un giorno INVIO smette di accettare, la
# tavola non puo' continuare a dire che accetta.
#
# Quello che non e' un tasto - dove si salva, la barra del turno - non sta qui:
# sta nella descrizione in basso, che per ogni categoria dice il resto.

const LARGA_TASTI := 236.0      # la colonna dei tasti, a destra allineata
const ALTA_RIGA := 44.0
const MARGINE := 16

# tasto disegnato -> azione di Godot che lo ascolta, e quale tasto fisico
const AZIONE_DI := {
	"INVIO": ["ui_accept", KEY_ENTER],
	"SPAZIO": ["ui_accept", KEY_SPACE],
	"ESC": ["ui_cancel", KEY_ESCAPE],
	"SU": ["ui_up", KEY_UP],
	"GIU": ["ui_down", KEY_DOWN],
}

# "tasti" e' un elenco di ALTERNATIVE, separate da «o»; ogni alternativa e' un
# elenco di tasti che vanno insieme (le due frecce, per esempio)
const CATEGORIE := {
	"MENU": {
		"titolo": "Muoversi nei menu",
		"corpo": "Il mouse fa tutto quello che fa la tastiera: si punta e si clicca. In basso a destra ci sono sempre i comandi di quel passo.",
		"righe": [
			{"tasti": [["SU", "GIU"]], "azione": "Passa da una voce all'altra"},
			{"tasti": [["INVIO"], ["CLIC"]], "azione": "Sceglie la voce accesa"},
			{"tasti": [["ESC"]], "azione": "Torna al passo prima, sulla voce di partenza"},
			{"tasti": [["ROTELLA"]], "azione": "Scorre gli elenchi lunghi: carte, creature, oggetti"},
		],
	},
	"STORIA": {
		"titolo": "Leggere, rispondere, girare",
		"corpo": "Si salva da solo ogni volta che rientri alla Sede. Dentro una zona no: se esci a metà, quello che hai fatto lì va perso.",
		"righe": [
			{"tasti": [["CLIC"], ["INVIO"], ["SPAZIO"]], "azione": "Mostra la frase intera; ancora una volta, va avanti"},
			{"tasti": [["SU", "GIU"], ["CLIC"]], "azione": "Sceglie una risposta"},
			{"tasti": [["ESC"]], "azione": "Pausa: diario, zaino, squadra, opzioni, storico dei dialoghi"},
			{"tasti": [["CLIC"]], "azione": "Sulla mappa, porta in una stanza collegata"},
		],
	},
	"COMBATTIMENTO": {
		"titolo": "Lo scontro non ti aspetta",
		"corpo": "Il nemico agisce mentre tu scegli: quando la barra sotto il tuo riquadro è piena, tocca a te. Se la linea dell'ECG è rossa sei sotto un quarto della vita.",
		"righe": [
			{"tasti": [["CLIC"]], "azione": "Sulla creatura: il colpo normale"},
			{"tasti": [["SU", "GIU"], ["CLIC"]], "azione": "Attacchi, difesa, skill, oggetti, fuga"},
			{"tasti": [["INVIO"], ["CLIC"]], "azione": "Fa andare avanti il racconto dello scontro"},
			{"tasti": [["ESC"]], "azione": "Pausa, anche a metà scontro"},
		],
	},
	"MOSSE SPECIALI": {
		"titolo": "Mattanza e Collisioni",
		"corpo": "La Mattanza dura quanto la barra del dominio che le dai. Nelle Collisioni un pugno preso in pieno non ti fa niente, di striscio metà.",
		"righe": [
			{"tasti": [["SPAZIO"]], "ripeti": true, "azione": "Mattanza: ogni pressione è un colpo, più in fretta più colpi"},
			{"tasti": [["CLIC"]], "azione": "Collisioni: sul pugno, quando il cerchio si chiude"},
			{"tasti": [["INVIO"], ["SPAZIO"]], "azione": "Collisioni: para il pugno più vicino"},
		],
	},
}

var testata: Label
var righe: VBoxContainer
var categoria := ""


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color(Stile.colore("menu_macchia"), 0.7)
	fondo.set_border_width_all(1)
	fondo.border_color = Color(Stile.colore("menu_riga_bordo"), 0.6)
	fondo.set_corner_radius_all(4)
	fondo.content_margin_left = MARGINE
	fondo.content_margin_right = MARGINE
	fondo.content_margin_top = 12
	fondo.content_margin_bottom = MARGINE
	add_theme_stylebox_override("panel", fondo)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 6)
	colonna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(colonna)
	testata = Label.new()
	if Caratteri.titolo() != null:
		testata.add_theme_font_override("font", Caratteri.titolo())
	testata.add_theme_font_size_override("font_size", 20)
	testata.add_theme_color_override("font_color", Stile.colore("menu_chiaro"))
	Stile.contorno(testata, 20)
	colonna.add_child(testata)
	righe = VBoxContainer.new()
	righe.add_theme_constant_override("separation", 6)
	righe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	colonna.add_child(righe)


func mostra(quale: String) -> void:
	if quale == categoria or not CATEGORIE.has(quale):
		return
	categoria = quale
	testata.text = "COMANDI — %s" % quale
	for vecchia in righe.get_children():
		righe.remove_child(vecchia)
		vecchia.queue_free()
	var elenco: Array = (CATEGORIE[quale] as Dictionary).get("righe", [])
	for i in elenco.size():
		var riga := riga_di(elenco[i])
		righe.add_child(riga)
		# le righe arrivano una dopo l'altra, come le voci del menu
		if not Movimento.ridotto():
			riga.modulate.a = 0.0
			var giro := riga.create_tween()
			giro.tween_interval(0.035 * i)
			Movimento.verso(giro, riga, "modulate:a", 1.0, "entrata", Movimento.durata("colore"))


func riga_di(dati: Dictionary) -> Control:
	var riga := PanelContainer.new()
	riga.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color(Stile.colore("menu_riga"), 0.72)
	fondo.set_border_width_all(1)
	fondo.border_color = Color(Stile.colore("menu_riga_bordo"), 0.5)
	fondo.set_corner_radius_all(4)
	fondo.content_margin_left = 10
	fondo.content_margin_right = 12
	fondo.content_margin_top = 5
	fondo.content_margin_bottom = 5
	riga.add_theme_stylebox_override("panel", fondo)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 16)
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	riga.add_child(fila)
	var tasti := HBoxContainer.new()
	tasti.alignment = BoxContainer.ALIGNMENT_END
	tasti.custom_minimum_size = Vector2(LARGA_TASTI, ALTA_RIGA - 10.0)
	tasti.add_theme_constant_override("separation", 6)
	tasti.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(tasti)
	var alternative: Array = dati.get("tasti", [])
	for a in alternative.size():
		if a > 0:
			tasti.add_child(parola("o"))
		for nome in (alternative[a] as Array):
			tasti.add_child(TappoTasto.nuovo(String(nome)))
	if bool(dati.get("ripeti", false)):
		tasti.add_child(parola("× tante"))
	var azione := Label.new()
	azione.text = String(dati.get("azione", ""))
	azione.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	azione.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	azione.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if Caratteri.tondo(700) != null:
		azione.add_theme_font_override("font", Caratteri.tondo(700))
	azione.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	azione.add_theme_color_override("font_color", Stile.colore("menu_descrizione"))
	fila.add_child(azione)
	return riga


static func parola(testo: String) -> Label:
	# «o» fra due modi di fare la stessa cosa: piccola e spenta, perche' si
	# guardano i tasti, non lei
	var scritta := Label.new()
	scritta.text = testo
	scritta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if Caratteri.tondo(700) != null:
		scritta.add_theme_font_override("font", Caratteri.tondo(700))
	scritta.add_theme_font_size_override("font_size", 15)
	scritta.add_theme_color_override("font_color", Color(Stile.colore("menu_chiaro"), 0.7))
	return scritta


static func tasti_usati() -> Array[String]:
	# tutti i tasti che la tavola disegna, una volta ciascuno: le prove li
	# confrontano con l'elenco dei comandi di Godot
	var visti: Array[String] = []
	for nome in tutti_i_tasti():
		if nome not in visti:
			visti.append(nome)
	return visti


static func tutti_i_tasti() -> Array[String]:
	var tasti: Array[String] = []
	for quale: String in CATEGORIE:
		for dati: Dictionary in (CATEGORIE[quale] as Dictionary).get("righe", []):
			for alternativa: Array in dati.get("tasti", []):
				tasti.append_array(alternativa)
	return tasti
