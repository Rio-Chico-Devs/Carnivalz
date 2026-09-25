class_name CartaSquadra
extends Button

# UNA CARTA DELLA SQUADRA, a destra nella scheda (B1-B3 dello schema).
#
# Il ritratto sta sul bordo esterno, il nome e la classe verso il centro: e'
# la carta del riferimento di Bru specchiata, come l'ha chiesta lui. Gli
# angoli tagliati (in alto a sinistra e in basso a destra) sono il nostro
# modo di non fare un rettangolo: le fasce del gioco sono tutte storte, e una
# carta dritta qui sarebbe l'unica cosa dritta della schermata.
#
# Quella scelta e' cremisi con la sfoglia bianca sotto, come la voce accesa
# della pausa. Passandoci sopra il bordo si accende e la carta si sporge di
# qualche pixel verso il centro dello schermo: e' la direzione in cui "entra".

signal presa(carta: CartaSquadra)

const TAGLIO := 14.0
const SFOGLIA := Vector2(-6, 5)
const SPORGE := 8.0
const LARGO_RITRATTO := 121.0
const RITRATTO := preload("res://scripts/Ritratto.gd")   # dove stanno i ritratti: lo sa lui

var id_classe := ""
var scelta := false
var di_passaggio := false
var accesa: Movimento.Molla
var sporta: Movimento.Molla


func _init() -> void:
	accesa = Movimento.molla("colore")
	sporta = Movimento.molla("forma")
	flat = true
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
	pressed.connect(func() -> void:
		Movimento.suona("pressione")
		presa.emit(self))


func carica(id: String, e_scelta: bool) -> void:
	id_classe = id
	scelta = e_scelta
	di_passaggio = id != "" and not GameState.e_definitivo(id)
	text = SchedaOggetto.nome_di_classe(id) if id != "" else ""
	disabled = id == ""
	focus_mode = Control.FOCUS_NONE if id == "" else Control.FOCUS_ALL
	queue_redraw()


func accendi() -> void:
	if id_classe == "" or accesa.obiettivo >= 1.0:
		return
	accesa.obiettivo = 1.0
	sporta.obiettivo = 1.0
	if Movimento.ridotto():
		accesa.salta_a(1.0)
	Movimento.suona("sfioro")
	sveglia()


func spegni_se_libera() -> void:
	if has_focus() or is_hovered():
		return
	accesa.obiettivo = 0.0
	sporta.obiettivo = 0.0
	if Movimento.ridotto():
		accesa.salta_a(0.0)
	sveglia()


func sveglia() -> void:
	queue_redraw()
	set_process(true)


func _process(delta: float) -> void:
	accesa.passo(delta)
	sporta.passo(delta)
	queue_redraw()
	set_process(not accesa.ferma() or not sporta.ferma())


func _draw() -> void:
	var fuori := Vector2(-SPORGE * clampf(sporta.valore, 0.0, 1.5), 0.0)
	var r := Rect2(fuori, size)
	var forma := Sagome.smussato(r, TAGLIO)
	if id_classe == "":
		# un posto libero nella squadra: si vede che c'e', e che e' vuoto
		draw_polyline(Sagome.chiudi(forma), Color(Stile.colore("testo"), 0.18), 2.0, true)
		return
	if scelta:
		var sfoglia := forma.duplicate()
		for i in sfoglia.size():
			sfoglia[i] += SFOGLIA
		draw_colored_polygon(sfoglia, Stile.colore("bordo_acceso"))
	draw_colored_polygon(forma, Stile.colore("accento") if scelta else Stile.colore("pannello_chiaro"))
	disegna_ritratto(Rect2(r.end.x - LARGO_RITRATTO, r.position.y, LARGO_RITRATTO, r.size.y))
	var bordo := Stile.colore("spento").lerp(Stile.colore("bordo_acceso"), clampf(accesa.valore, 0.0, 1.0))
	draw_polyline(Sagome.chiudi(forma), bordo, 2.0, true)
	disegna_scritte(r)


func disegna_ritratto(r: Rect2) -> void:
	var percorso: String = RITRATTO.percorso_immagine(id_classe, GameState.personaggi.get(id_classe, {}), "neutra")
	var disegno := Disegni.texture("res://art/personaggi/%s/carta.png" % id_classe)
	if disegno == null:
		disegno = Disegni.texture(percorso)
	var dentro := r.grow(-4.0)
	if disegno != null:
		# riempie il riquadro tagliando quello che avanza, come una fototessera
		var misura := disegno.get_size()
		var quanto := maxf(dentro.size.x / misura.x, dentro.size.y / misura.y)
		var sorgente := Rect2((misura - dentro.size / quanto) * 0.5, dentro.size / quanto)
		draw_texture_rect_region(disegno, dentro, sorgente)
		return
	draw_rect(dentro, Stile.colore("sfondo"))
	var copie: Array[Color] = [Stile.colore("accento").darkened(0.35), Stile.colore("accento").darkened(0.6)]
	Sagome.iniziale(self, dentro, text, 64, Stile.colore("testo"), copie)


func disegna_scritte(r: Rect2) -> void:
	var titolo := Caratteri.titolo()
	var tondo := Caratteri.tondo(800)
	if titolo == null or tondo == null:
		return
	var x := r.position.x + 18.0
	var largo := r.size.x - LARGO_RITRATTO - 28.0
	draw_string(titolo, Vector2(x, r.position.y + 44.0), text.to_upper(), HORIZONTAL_ALIGNMENT_LEFT,
			largo, 26, Stile.colore("testo"))
	var classe: Dictionary = GameState.classi.get(id_classe, {})
	var sotto := String(classe.get("classe", "")).to_upper()
	var colore := Stile.colore("testo") if scelta else Stile.colore("testo_smorzato")
	draw_string(tondo, Vector2(x, r.position.y + 66.0), sotto, HORIZONTAL_ALIGNMENT_LEFT, largo, 13, colore)
	if di_passaggio:
		draw_string(tondo, Vector2(x, r.position.y + 80.0), "DI PASSAGGIO", HORIZONTAL_ALIGNMENT_LEFT,
				largo, 11, Stile.colore("bordo_acceso") if scelta else Stile.colore("accento"))
