class_name RigaZaino
extends Button

# UNA RIGA DELLO ZAINO: l'immagine, il nome, cosa fa, quanti, e i due segni.
#
# E' UNA FASCIA NERA STORTA, come le voci della pausa: la lista sta
# sull'arancio, una fascia per tipo di oggetto. Bru, fra quattro proposte:
# «la numero 2 mi convince, approvata». La fascia scelta e' chiara, scritta in
# nero, ed esce dalla fila di quattordici pixel con la sfoglia nera sotto.
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
# LE FRECCE LE PRENDE LA RIGA prima che Godot sposti il fuoco da solo: su e
# giu' scorrono la lista (che e' una finestra di righe fisse: si sposta la
# finestra, non il fuoco), destra e sinistra cambiano scomparto. La rotella fa
# come su e giu'.

signal presa(riga: RigaZaino)
signal sposta(verso: int)
signal scomparto(verso: int)

const ALTO := 50.0
const SFOGLIA := Vector2(6, 5)
const ESCE := 14.0            # di quanto la fascia scelta esce dalla fila
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
	if scelta:
		draw_set_transform(Vector2(ESCE, 0))
	disegna_fascia()
	disegna_piastrella()
	# il numero a destra in basso, IN USO sopra di lui: il nome si ferma prima
	# dell'etichetta, cosa fa prima del numero
	var dopo_quanti := disegna_quanti()
	disegna_testi(disegna_in_uso(dopo_quanti), dopo_quanti)


func storto() -> float:
	return size.y * Manifesto.INCLINA


func sagoma() -> PackedVector2Array:
	# la fascia: pende come le voci della pausa, alta quanto la riga
	return PackedVector2Array([Vector2(storto(), 0), Vector2(size.x, 0), Vector2(size.x - storto(), size.y),
			Vector2(0, size.y)])


func _has_point(punto: Vector2) -> bool:
	# I CLIC SI PRENDONO DENTRO LA FASCIA, anche quando la scelta esce dalla
	# fila: negli angoli fuori dalla pendenza c'e' l'arancio, non la riga
	return Geometry2D.is_point_in_polygon(punto - Vector2(ESCE if scelta else 0.0, 0.0), sagoma())


func disegna_fascia() -> void:
	var forma := sagoma()
	if scelta:
		var sfoglia := forma.duplicate()
		for i in sfoglia.size():
			sfoglia[i] += SFOGLIA
		Manifesto.poligono(self, sfoglia, Stile.colore("bordo"))
	var tinta := Stile.colore("bordo_acceso") if scelta \
			else Stile.colore("bordo").lerp(Stile.colore("pannello_chiaro"), clampf(accesa.valore, 0.0, 1.0))
	Manifesto.poligono(self, forma, tinta)


func piastrella() -> Rect2:
	# il quadrato dell'immagine, alto quanto la riga e spostato di quanto la
	# fascia pende: se no ne uscirebbe in alto a sinistra
	var lato := size.y - 10.0
	return Rect2(8.0 + storto(), 5.0, lato, lato)


func x_testo() -> float:
	return piastrella().end.x + 14.0


func inchiostro() -> Color:
	return Stile.colore("box_testo") if scelta else Stile.colore("testo")


func disegna_piastrella() -> void:
	var r := piastrella()
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
	var x := size.x - 14.0 - storto()
	if quanti <= 1 and tipo not in ["consumabile", "pila"]:
		return x
	var f := Caratteri.titolo()
	if f == null:
		return x
	var scritta := "×%d" % quanti
	var largo := f.get_string_size(scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, CORPO_QUANTI).x
	draw_string(f, Vector2(x - largo, size.y * 0.66), scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, CORPO_QUANTI, inchiostro())
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
	var y := 7.0
	var pende := alto * Manifesto.INCLINA
	var fascia := PackedVector2Array([Vector2(x + pende, y), Vector2(x + largo + pende, y),
			Vector2(x + largo, y + alto), Vector2(x, y + alto)])
	Manifesto.poligono(self, fascia, fondo)
	draw_string(f, Vector2(x + 7.0 + pende * 0.5, y + 13.0), scritta, HORIZONTAL_ALIGNMENT_LEFT, -1, CORPO_SEGNO, colore)
	return x - 8.0 if da_destra else x + largo + pende + 8.0


func disegna_testi(destra: float, destra_sotto: float) -> void:
	# il nome nel carattere dei titoli, maiuscolo, come le voci della pausa;
	# cosa fa sotto, nel tondo, piu' piccolo
	var f := Caratteri.titolo()
	if f == null:
		return
	var x := x_testo()
	var largo := destra - x
	var nome := text.to_upper()
	var corpo := Tavola.corpo_che_entra(f, nome, largo - (64.0 if nuova else 0.0), CORPO_NOME, 13)
	draw_string(f, Vector2(x, size.y * 0.45), nome, HORIZONTAL_ALIGNMENT_LEFT, largo, corpo, inchiostro())
	if nuova:
		var fine := x + minf(f.get_string_size(nome, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x, largo - 64.0) + 10.0
		segno(fine, "NUOVO", Stile.colore("bordo") if scelta else Stile.colore("bordo_acceso"),
				Stile.colore("bordo_acceso") if scelta else Stile.colore("box_testo"), false)
	var effetto := Merce.riassunto_effetto(GameState.dati_oggetto(String(voce.get("oggetto", ""))), "")
	if effetto == "":
		effetto = String(ElencoZaino.NOMI_TIPI.get(Merce.tipo_oggetto(String(voce.get("oggetto", ""))), ""))
	var sotto := Color(Stile.colore("box_testo"), 0.75) if scelta else Stile.colore("testo_smorzato")
	draw_string(Caratteri.tondo(700), Vector2(x, size.y * 0.8), effetto, HORIZONTAL_ALIGNMENT_LEFT,
			destra_sotto - x, CORPO_EFFETTO, sotto)
