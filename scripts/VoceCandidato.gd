class_name VoceCandidato
extends Button

# UNA COSA CHE SI PUO' METTERE NELLO SLOT APERTO, nella lista a destra.
#
# Il nome, e sotto la differenza con quello che porti adesso ("difesa +2,
# velocità −1"). Passandoci sopra, o arrivandoci con le frecce, il pannello
# delle statistiche mostra dove andresti: la differenza si legge due volte, a
# parole qui e in numeri la', perche' e' tutta la decisione.
#
# Un oggetto addosso a un altro compagno non si nasconde: si dice chi ce l'ha.
# Un oggetto che sparisce dall'elenco sembra perso.

signal presa(voce: VoceCandidato)
signal sopra(voce: VoceCandidato)

const ALTO := 50.0

var id_oggetto := ""
var nota := ""                  # "in uso", "addosso a Veronica"
var differenza := ""
var verso := 0                  # 1 tutto meglio, -1 tutto peggio, 0 misto o niente
var accesa: Movimento.Molla


func _init() -> void:
	accesa = Movimento.molla("colore")
	flat = true
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(0, ALTO)
	for stato in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		add_theme_stylebox_override(stato, StyleBoxEmpty.new())
	for chiave in TastoObliquo.COLORI_TESTO:
		add_theme_color_override(chiave, Color(0, 0, 0, 0))
	set_process(false)


static func nuova(id: String, scritta: String, annotazione: String, scarto: String,
		quale_verso: int) -> VoceCandidato:
	var v := VoceCandidato.new()
	v.id_oggetto = id
	v.text = scritta
	v.nota = annotazione
	v.differenza = scarto
	v.verso = quale_verso
	return v


func _ready() -> void:
	mouse_entered.connect(accendi)
	mouse_exited.connect(spegni_se_libera)
	focus_entered.connect(accendi)
	focus_exited.connect(spegni_se_libera)
	pressed.connect(func() -> void:
		Movimento.suona("pressione")
		presa.emit(self))


func accendi() -> void:
	sopra.emit(self)
	if accesa.obiettivo >= 1.0:
		return
	accesa.obiettivo = 1.0
	if Movimento.ridotto():
		accesa.salta_a(1.0)
	Movimento.suona("sfioro")
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


func _draw() -> void:
	var q := clampf(accesa.valore, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(Stile.colore("pannello_chiaro"), q))
	draw_rect(Rect2(0, 4, 4.0 * q, size.y - 8), Stile.colore("accento"))
	var tondo := Caratteri.tondo(800)
	if tondo == null:
		return
	var riga := text if nota == "" else "%s  ·  %s" % [text, nota]
	draw_string(tondo, Vector2(12, 21), riga, HORIZONTAL_ALIGNMENT_LEFT, size.x - 20, 15, Stile.colore("testo"))
	# verde solo se e' tutto meglio, rosso solo se e' tutto peggio: uno
	# scambio (piu' difesa, meno velocita') resta grigio, perche' e' una scelta
	var colore := Stile.colore("testo_smorzato")
	if verso > 0:
		colore = Stile.colore("positivo").lightened(0.3)
	elif verso < 0:
		colore = Stile.colore("pericolo").lightened(0.3)
	draw_string(Caratteri.tondo(700), Vector2(12, 40), differenza, HORIZONTAL_ALIGNMENT_LEFT,
			size.x - 20, 13, colore)
