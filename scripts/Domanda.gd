class_name Domanda
extends Control

# UNA DOMANDA CHE ASPETTA UNA RISPOSTA, sopra quello che c'era.
#
# Bru: «se non è immesso un nome deve esserci un pop up che chiede: vuoi
# rimanere anonimo?». Non e' un passo del menu - non si va da nessuna parte, si
# resta dove si era e si risponde - quindi non cambia la pagina: la copre. Un
# velo scuro sopra tutto, e al centro la domanda con due voci, fatte come
# quelle del menu (la macchia, il cremisi della scelta).
#
# Finche' e' aperta e' l'unica cosa che si tocca: il velo si prende il mouse,
# il fuoco gira fra le due voci e non scappa sotto, ESC vuol dire «no».
# Chiusa, sparisce e dice cosa si e' risposto (il segnale "risposta").

signal risposta(si: bool)

const LARGA := 460.0
const MARGINE_MACCHIA := 92

var voci: Array[VoceMacchia] = []
var chiusa := false


static func apri(sopra: Control, titolo: String, corpo: String, si: String, no: String) -> Domanda:
	var domanda := Domanda.new()
	domanda.costruisci(titolo, corpo, si, no)
	sopra.add_child(domanda)
	domanda.lega_il_fuoco()
	# il fuoco va sul si': chi ha premuto COMINCIA voleva cominciare, e la
	# domanda gli chiede solo di confermarlo
	domanda.voci[0].bottone.grab_focus()
	domanda.compari()
	return domanda


func costruisci(titolo: String, corpo: String, si: String, no: String) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var velo := ColorRect.new()
	velo.color = Color(Stile.colore("menu_macchia"), 0.72)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(velo)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)
	var scatola := PanelContainer.new()
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color(Stile.colore("menu_riga"), 0.96)
	fondo.set_border_width_all(2)
	fondo.border_color = Stile.colore("menu_riga_accesa_bordo")
	fondo.set_corner_radius_all(4)
	# a sinistra c'e' la corsia della macchia: la voce scelta la spande fin
	# oltre il suo segno, e deve restare dentro la scatola
	fondo.content_margin_left = MARGINE_MACCHIA
	fondo.content_margin_right = 40
	fondo.content_margin_top = 26
	fondo.content_margin_bottom = 22
	scatola.add_theme_stylebox_override("panel", fondo)
	centro.add_child(scatola)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 6)
	scatola.add_child(colonna)
	# la domanda e la spiegazione partono dove parte il testo delle voci, dopo la
	# corsia del segno: come nel menu, dove testata e voci stanno sulla stessa riga
	var parole := MarginContainer.new()
	parole.add_theme_constant_override("margin_left", VoceMenu.SPAZIO_SEGNO)
	colonna.add_child(parole)
	var righe := VBoxContainer.new()
	righe.add_theme_constant_override("separation", 6)
	parole.add_child(righe)
	var domanda := Label.new()
	domanda.text = titolo
	if Caratteri.titolo() != null:
		domanda.add_theme_font_override("font", Caratteri.titolo())
	domanda.add_theme_font_size_override("font_size", VoceMacchia.CORPO)
	domanda.add_theme_color_override("font_color", Stile.colore("menu_descrizione"))
	Stile.contorno(domanda, VoceMacchia.CORPO)
	righe.add_child(domanda)
	var spiega := Label.new()
	spiega.text = corpo
	if Caratteri.tondo(650) != null:
		spiega.add_theme_font_override("font", Caratteri.tondo(650))
	spiega.add_theme_font_size_override("font_size", Stile.dimensione("minuscolo"))
	spiega.add_theme_color_override("font_color", Stile.colore("menu_descrizione"))
	spiega.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spiega.custom_minimum_size = Vector2(LARGA, 0)
	righe.add_child(spiega)
	var aria := Control.new()
	aria.custom_minimum_size = Vector2(0, 14)
	colonna.add_child(aria)
	var elenco := VBoxContainer.new()
	elenco.add_theme_constant_override("separation", 0)
	colonna.add_child(elenco)
	for dati: Array in [[si, true], [no, false]]:
		var voce := VoceMacchia.crea(String(dati[0]))
		voce.scelta.connect(rispondi.bind(bool(dati[1])))
		elenco.add_child(voce)
		voci.append(voce)


func lega_il_fuoco() -> void:
	# IL FUOCO NON SCAPPA SOTTO IL VELO: dalle due voci le frecce portano solo
	# all'altra, mai alle voci della pagina coperta
	for i in voci.size():
		var questa := voci[i].bottone
		var altra := voci[1 - i].bottone
		for lato in [SIDE_TOP, SIDE_BOTTOM, SIDE_LEFT, SIDE_RIGHT]:
			questa.set_focus_neighbor(lato, questa.get_path_to(altra))
		questa.focus_next = questa.get_path_to(altra)
		questa.focus_previous = questa.get_path_to(altra)


func compari() -> void:
	if Movimento.ridotto():
		return
	modulate.a = 0.0
	var giro := create_tween()
	Movimento.verso(giro, self, "modulate:a", 1.0, "entrata", Movimento.durata("colore"))


func rispondi(si: bool) -> void:
	if chiusa:
		return
	chiusa = true
	risposta.emit(si)
	queue_free()


func _unhandled_input(evento: InputEvent) -> void:
	# e' l'ultima cosa aggiunta, quindi ESC arriva a lei prima che al menu sotto:
	# vuol dire «no», e non «torna al passo prima»
	if chiusa:
		return
	if evento.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		Movimento.suona("chiusura")
		rispondi(false)
