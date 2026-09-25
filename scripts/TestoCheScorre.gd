class_name TestoCheScorre
extends Control

# UNA DESCRIZIONE PIU' LUNGA DEL SUO POSTO, che scorre da sola.
#
# Bru l'ha chiesta cosi' per il negozio («descrizione che scorre»), e serve
# uguale nel dettaglio della scheda: il posto e' fisso, i testi degli oggetti
# no, e una riga tagliata a meta' sotto le carte si legge come un errore.
#
# COME SCORRE. Prima sta ferma il tempo di leggere quello che si vede; poi sale
# piano, alla velocita' di chi legge; arrivata in fondo si ferma ancora, e
# torna in cima dissolvendosi - non riavvolgendo, che e' un movimento che
# nessuno ha chiesto. Un testo che ci sta non si muove mai.
#
# CHI LEGGE COMANDA. Col mouse sopra si ferma dov'e'; la rotella la sposta a
# mano, e da li' non riparte da sola finche' il testo non cambia. Col
# movimento ridotto non scorre: gira pagina dissolvendosi, una pagina alla
# volta, coi tempi di lettura.
#
# I TEMPI sono in stile.json (movimento.lettura) e si contano in righe: quanto
# ci vuole a leggerne una. Da li' vengono tutti gli altri - la velocita' e'
# una riga per quel tempo, l'attesa prima di partire e' una riga e mezza (chi
# legge e' alla seconda quando il testo comincia a salire, e poi resta li'), la
# pagina ridotta resta ferma quanto le sue righe meno una.

enum Fase {FERMA, ATTESA, SCORRE, SOSTA, SPARISCE, RIAPPARE, A_MANO}

const PASSO_ROTELLA := 22.0

var testo: RichTextLabel
var sfumatura: Control
var fase := Fase.FERMA
var orologio := 0.0
var scostamento := 0.0
var meta := 0.0                 # dove va la pagina dopo, col movimento ridotto
var colore_fondo := Color.BLACK
var sopra := false              # il mouse ci sta sopra: chi legge si e' fermato


func _init() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	testo = RichTextLabel.new()
	testo.bbcode_enabled = true
	testo.scroll_active = false
	testo.fit_content = true
	testo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(testo)
	sfumatura = Control.new()
	sfumatura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sfumatura.draw.connect(disegna_sfumatura)
	add_child(sfumatura)
	set_process(false)


static func nuovo(corpo: int, colore: Color, fondo: Color) -> TestoCheScorre:
	var t := TestoCheScorre.new()
	t.colore_fondo = fondo
	t.testo.add_theme_font_override("normal_font", Caratteri.tondo(600))
	t.testo.add_theme_font_override("bold_font", Caratteri.tondo(900))
	t.testo.add_theme_font_size_override("normal_font_size", corpo)
	t.testo.add_theme_font_size_override("bold_font_size", corpo)
	t.testo.add_theme_color_override("default_color", colore)
	return t


func _ready() -> void:
	resized.connect(adatta)
	mouse_entered.connect(func() -> void: sopra = true)
	mouse_exited.connect(func() -> void: sopra = false)
	adatta()


func adatta() -> void:
	testo.size.x = size.x
	sfumatura.position = Vector2(0, size.y - altezza_sfumatura())
	sfumatura.size = Vector2(size.x, altezza_sfumatura())
	sfumatura.queue_redraw()


# --- cosa dice ----------------------------------------------------------------

func scrivi(bbcode: String) -> void:
	# un testo nuovo riparte da capo: dall'alto, fermo, col tempo di leggerlo
	if bbcode == testo.text:
		return
	testo.text = bbcode
	scostamento = 0.0
	orologio = 0.0
	testo.modulate.a = 1.0
	fase = Fase.ATTESA
	sposta_testo()
	set_process(true)


func eccedenza() -> float:
	# quanto testo sta sotto il bordo: zero se ci sta tutto
	return maxf(testo.get_content_height() - size.y, 0.0)


func altezza_riga() -> float:
	var f := testo.get_theme_font("normal_font")
	var corpo := testo.get_theme_font_size("normal_font_size")
	return f.get_height(corpo) if f != null else 20.0


func altezza_sfumatura() -> float:
	return altezza_riga() * 0.9


# --- come scorre --------------------------------------------------------------

func tempo(nome: String, se_manca: float) -> float:
	return float(Movimento.dati().get("lettura", {}).get(nome, se_manca))


func attesa() -> float:
	var riga := tempo("riga", 2.5)
	if not Movimento.ridotto():
		return riga * 1.5
	return riga * maxf(floorf(size.y / altezza_riga()) - 1.0, 1.0)


func _process(delta: float) -> void:
	var fondo := eccedenza()
	if fondo <= 0.0 and fase in [Fase.ATTESA, Fase.SCORRE]:
		# ci sta tutto: non c'e' niente da far scorrere, e non si ricontrolla
		# finche' il testo non cambia
		fase = Fase.FERMA
	if fase == Fase.FERMA or fase == Fase.A_MANO:
		set_process(false)
		sfumatura.queue_redraw()
		return
	if sopra and fase in [Fase.ATTESA, Fase.SCORRE, Fase.SOSTA]:
		return   # chi ci tiene sopra il mouse sta leggendo: si aspetta lui
	orologio += delta
	match fase:
		Fase.ATTESA:
			if orologio >= attesa():
				comincia_a_scorrere(fondo)
		Fase.SCORRE:
			scorri(delta, fondo)
		Fase.SOSTA:
			if orologio >= tempo("sosta", 3.0):
				cambia(Fase.SPARISCE)
		Fase.SPARISCE:
			sparisci()
		Fase.RIAPPARE:
			riappari(fondo)


func sparisci() -> void:
	var d := Movimento.durata("uscita")
	testo.modulate.a = 1.0 - clampf(orologio / d, 0.0, 1.0)
	if orologio < d:
		return
	# col movimento ridotto si gira pagina; se no si torna in cima
	scostamento = meta if Movimento.ridotto() and meta > scostamento else 0.0
	sposta_testo()
	cambia(Fase.RIAPPARE)


func riappari(fondo: float) -> void:
	var d := Movimento.durata("entrata")
	testo.modulate.a = clampf(orologio / d, 0.0, 1.0)
	if orologio < d:
		return
	testo.modulate.a = 1.0
	cambia(Fase.SOSTA if Movimento.ridotto() and scostamento >= fondo else Fase.ATTESA)


func comincia_a_scorrere(fondo: float) -> void:
	if not Movimento.ridotto():
		cambia(Fase.SCORRE)
		return
	# a pagine: la pagina dopo tiene l'ultima riga di questa, per non perdere il filo
	meta = minf(scostamento + size.y - altezza_riga(), fondo)
	cambia(Fase.SPARISCE)


func scorri(delta: float, fondo: float) -> void:
	scostamento = minf(scostamento + altezza_riga() / tempo("riga", 2.5) * delta, fondo)
	sposta_testo()
	if scostamento >= fondo:
		cambia(Fase.SOSTA)


func cambia(nuova: Fase) -> void:
	fase = nuova
	orologio = 0.0


func sposta_testo() -> void:
	testo.position.y = -scostamento
	sfumatura.queue_redraw()


func _gui_input(evento: InputEvent) -> void:
	# la rotella sposta il testo a mano; da li' lo scorrimento aspetta il testo dopo
	if not (evento is InputEventMouseButton and evento.pressed):
		return
	var verso := 0.0
	if evento.button_index == MOUSE_BUTTON_WHEEL_UP:
		verso = -1.0
	elif evento.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		verso = 1.0
	if verso == 0.0 or eccedenza() <= 0.0:
		return
	scostamento = clampf(scostamento + verso * PASSO_ROTELLA, 0.0, eccedenza())
	testo.modulate.a = 1.0
	fase = Fase.A_MANO
	sposta_testo()
	accept_event()


# --- la sfumatura in fondo -------------------------------------------------------

func disegna_sfumatura() -> void:
	# C'E' ALTRO SOTTO: l'ultima riga visibile sfuma nel fondo finche' il testo
	# non e' arrivato in fondo. Arrivato, la sfumatura sparisce - e' finito
	if eccedenza() - scostamento <= 0.5:
		return
	var s := sfumatura.size
	var chiaro := Color(colore_fondo, 0.0)
	sfumatura.draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(s.x, 0), s, Vector2(0, s.y)]),
			PackedColorArray([chiaro, chiaro, colore_fondo, colore_fondo]))
