class_name RigaZaino
extends Button

# UNA RIGA DELLO ZAINO: l'immagine, il nome, cosa fa, quanti, e i due segni.
#
# L'immagine sta su una piastrella scura uguale per tutti, a sinistra: quando
# arriveranno i disegni di Bru (art/oggetti/<id>.png) staranno tutti sullo
# stesso fondo e la colonna delle immagini si leggera' da sola, come la
# colonna dei nomi. Finche' il disegno non c'e', la sagoma del tipo (Sagome).
#
# I DUE SEGNI sono pieni, mai solo una parola grigia: IN USO arancio (l'arma
# in mano a qualcuno), NUOVO chiaro (un oggetto che non hai ancora guardato).
# In Metaphor l'arma addosso era «E:1», e nessuno capiva cosa volesse dire.
#
# La riga scelta e' un foglio chiaro scritto in nero, con la sfoglia nera
# sotto e il filo arancio a sinistra: la stessa carta scelta del negozio.
#
# LE FRECCE LE PRENDE LA RIGA prima che Godot sposti il fuoco da solo: su e
# giu' scorrono la lista (che e' una finestra di righe fisse: si sposta la
# finestra, non il fuoco), destra e sinistra cambiano scomparto. La rotella fa
# come su e giu'.

signal presa(riga: RigaZaino)
signal sposta(verso: int)
signal scomparto(verso: int)

const ALTO := 56.0
const PIASTRELLA := Rect2(8, 5, 46, 46)
const SFOGLIA := Vector2(4, 4)
const X_TESTO := 68.0
const CORPO_NOME := 17
const CORPO_EFFETTO := 13
const CORPO_QUANTI := 24
const CORPO_SEGNO := 11

var voce: Dictionary = {}
var scelta := false
var nuova := false
var accesa: Movimento.Molla


func _init() -> void:
	accesa = Movimento.molla("colore")
	flat = true
	clip_text = true      # la misura la decide la tavola, non la scritta nel carattere del tema
	focus_mode = Control.FOCUS_ALL
	for stato in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		add_theme_stylebox_override(stato, StyleBoxEmpty.new())
	for chiave in TastoObliquo.COLORI_TESTO:
		add_theme_color_override(chiave, Color(0, 0, 0, 0))
	set_process(false)


func _ready() -> void:
	mouse_entered.connect(accendi)
	mouse_exited.connect(spegni_se_libera)
	focus_entered.connect(accendi)
	focus_exited.connect(spegni_se_libera)
	gui_input.connect(_su_input)
	pressed.connect(func() -> void: presa.emit(self))


func carica(nuova_voce: Dictionary, e_scelta: bool, e_nuova: bool) -> void:
	voce = nuova_voce
	scelta = e_scelta
	nuova = e_nuova
	# il nome resta nel Button, trasparente: l'automa e le prove trovano la riga
	# col nome che si legge
	text = Merce.nome_di(String(voce.get("oggetto", "")))
	visible = not voce.is_empty()
	queue_redraw()


func _su_input(evento: InputEvent) -> void:
	for coppia in [["ui_up", -1], ["ui_down", 1]]:
		if evento.is_action_pressed(String(coppia[0]), true):
			sposta.emit(int(coppia[1]))
			accept_event()
			return
	for coppia in [["ui_left", -1], ["ui_right", 1]]:
		if evento.is_action_pressed(String(coppia[0])):
			scomparto.emit(int(coppia[1]))
			accept_event()
			return
	if evento is InputEventMouseButton and evento.pressed \
			and evento.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		sposta.emit(-1 if evento.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		accept_event()


# --- i gesti ------------------------------------------------------------------

func accendi() -> void:
	if accesa.obiettivo >= 1.0:
		return
	accesa.obiettivo = 1.0
	if Movimento.ridotto():
		accesa.salta_a(1.0)
	sveglia()


func spegni_se_libera() -> void:
	if has_focus() or is_hovered():
		return
	accesa.obiettivo = 0.0
	if Movimento.ridotto():
		accesa.salta_a(0.0)
	sveglia()


func sveglia() -> void:
	queue_redraw()
	set_process(true)


func _process(delta: float) -> void:
	accesa.passo(delta)
	queue_redraw()
	set_process(not accesa.ferma())


# --- il disegno ---------------------------------------------------------------

func _draw() -> void:
	if voce.is_empty():
		return
	var fondo := Rect2(Vector2.ZERO, size)
	if scelta:
		draw_rect(Rect2(fondo.position + SFOGLIA, fondo.size), Stile.colore("bordo"))
		draw_rect(fondo, Stile.colore("bordo_acceso"))
		draw_rect(Rect2(0, 0, 6, size.y), Stile.colore("accento"))
	else:
		draw_rect(fondo, Color(Stile.colore("pannello_chiaro"), clampf(accesa.valore, 0.0, 1.0)))
		draw_rect(Rect2(X_TESTO, size.y - 1.0, size.x - X_TESTO, 1.0), Color(Stile.colore("tratto"), 0.45))
	disegna_piastrella()
	# il numero a destra in basso, IN USO sopra di lui: il nome si ferma prima
	# dell'etichetta, cosa fa prima del numero
	var dopo_quanti := disegna_quanti()
	disegna_testi(disegna_in_uso(dopo_quanti), dopo_quanti)


func inchiostro() -> Color:
	return Stile.colore("box_testo") if scelta else Stile.colore("testo")


func disegna_piastrella() -> void:
	var r := PIASTRELLA
	draw_rect(r, Stile.colore("quadro_vuoto"))
	draw_rect(r, Stile.colore("tratto"), false, 1.0)
	var id_oggetto := String(voce.get("oggetto", ""))
	var disegno := Sagome.immagine_oggetto(id_oggetto)
	if disegno != null:
		Sagome.disegna_dentro(self, disegno, r.grow(-3.0))
		return
	Sagome.icona_oggetto(self, r.get_center(), r.size.x * 0.82, Sagome.tipo_icona(id_oggetto),
			Stile.colore("testo"), Stile.colore("quadro_vuoto"))


func disegna_quanti() -> float:
	# il conto, a destra in grande: dove c'e' da contare (la sacca, il
	# bottino) sempre, altrove solo se ne hai piu' di uno. Torna dove finisce
	# il posto libero a sinistra del numero
	var quanti := int(voce.get("quanti", 1))
	var tipo := Merce.tipo_oggetto(String(voce.get("oggetto", "")))
	var x := size.x - 14.0
	if quanti <= 1 and tipo not in ["consumabile", "pila"]:
		return x
	var f := Caratteri.titolo()
	if f == null:
		return x
	var scritta := "×%d" % quanti
	var largo := f.get_string_size(scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, CORPO_QUANTI).x
	draw_string(f, Vector2(x - largo, 37.0), scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, CORPO_QUANTI, inchiostro())
	return x - largo - 12.0


func disegna_in_uso(destra: float) -> float:
	if String(voce.get("in_uso", "")) == "":
		return destra
	return segno(destra, "IN USO", Stile.colore("accento"), Stile.colore("box_testo"), true)


func segno(dove: float, scritta: String, fondo: Color, colore: Color, da_destra: bool) -> float:
	# un'etichetta piena, storta come le fasce del manifesto. Torna il bordo
	# libero dalla parte opposta a quella da cui e' stata messa
	var f := Caratteri.tondo(900)
	if f == null:
		return dove
	var largo := f.get_string_size(scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, CORPO_SEGNO).x + 14.0
	var x := dove - largo if da_destra else dove
	var alto := 18.0
	var y := 9.0
	var storto := alto * Manifesto.INCLINA
	var fascia := PackedVector2Array([Vector2(x + storto, y), Vector2(x + largo + storto, y),
			Vector2(x + largo, y + alto), Vector2(x, y + alto)])
	Manifesto.poligono(self, fascia, fondo)
	draw_string(f, Vector2(x + 7.0 + storto * 0.5, y + 13.0), scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, CORPO_SEGNO, colore)
	return x - 8.0 if da_destra else x + largo + storto + 8.0


func disegna_testi(destra: float, destra_sotto: float) -> void:
	var f := Caratteri.tondo(800)
	if f == null:
		return
	var largo := destra - X_TESTO
	var nome := text
	var corpo := Tavola.corpo_che_entra(f, nome, largo - (64.0 if nuova else 0.0), CORPO_NOME, 13)
	draw_string(f, Vector2(X_TESTO, 25.0), nome, HORIZONTAL_ALIGNMENT_LEFT, largo, corpo, inchiostro())
	if nuova:
		var fine := X_TESTO + minf(f.get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x, largo - 64.0) + 10.0
		segno(fine, "NUOVO", Stile.colore("bordo") if scelta else Stile.colore("bordo_acceso"),
				Stile.colore("bordo_acceso") if scelta else Stile.colore("box_testo"), false)
	var effetto := Merce.riassunto_effetto(GameState.dati_oggetto(String(voce.get("oggetto", ""))), "")
	if effetto == "":
		effetto = String(ElencoZaino.NOMI_TIPI.get(Merce.tipo_oggetto(String(voce.get("oggetto", ""))), ""))
	var sotto := Color(Stile.colore("box_testo"), 0.75) if scelta else Stile.colore("testo_smorzato")
	draw_string(Caratteri.tondo(700), Vector2(X_TESTO, 45.0), effetto, HORIZONTAL_ALIGNMENT_LEFT,
			destra_sotto - X_TESTO, CORPO_EFFETTO, sotto)
