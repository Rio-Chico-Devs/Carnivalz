class_name IconaGuida
extends Button

# «SE HAI BISOGNO PUOI PREMERE SULLA MIA ICONA. ADDIO.» La Guida lo dice
# arrivando nelle Pianure di Redenna, offesa, e da quel momento l'icona c'e':
# accanto a quella del menu, in alto a sinistra. Premuta, riapre la mappa di
# zona con lei sopra che ripete la sua spiegazione - l'unico aiuto che per ora
# ha scritto. Il giorno che avra' altro da dire, si cambia GuidaSullaMappa e
# non questa.
#
# SI PREME SOLO QUANDO TOCCA A TE. Porta via dalla scena, e a meta' di un
# dialogo se ne perderebbe il resto: finche' il testo scorre l'icona sta
# sotto l'area che lo fa avanzare, come tutti i comandi, e si vede spenta.
# Compare pero' sulla battuta che la nomina, non dopo: e' li' che il giocatore
# alza gli occhi a cercarla.

const FLAG := "guida_conosciuta"
const SPENTA := 0.45
const DISEGNO := "res://art/personaggi/guida.png"

var schermata: Node   # la scena dei dialoghi, per sapere se il testo scorre


static func metti(dialogo: Node, sotto: Control, accanto: Control) -> void:
	# solo dove la Guida ha qualcosa da dire sulla mappa di questa zona. Sta in
	# "sotto" - l'interfaccia, che l'area del testo copre - e non in cima alla
	# scena come l'icona del menu: quella apre una pausa, questa porta via
	if (GameState.mappa_zona.get("guida", []) as Array).is_empty():
		return
	var icona := IconaGuida.new()
	icona.schermata = dialogo
	icona.position = accanto.position + Vector2(accanto.size.x + 12.0, 0.0)
	icona.custom_minimum_size = accanto.size
	icona.size = accanto.size
	sotto.add_child(icona)


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	tooltip_text = "Guida"
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Stile.colore("box_testo")
	fondo.set_border_width_all(3)
	fondo.border_color = Stile.colore("accento")
	fondo.set_corner_radius_all(int(size.x * 0.5))
	for stato in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(stato, fondo)
	if ResourceLoader.exists(DISEGNO):
		icon = load(DISEGNO)
		expand_icon = true
	else:
		# finche' non c'e' il suo ritratto, un punto di domanda: e' l'aiuto
		text = "?"
		add_theme_font_size_override("font_size", Stile.dimensione("sezione"))
		add_theme_color_override("font_color", Stile.colore("accento"))
	pressed.connect(func() -> void: GuidaSullaMappa.apri({}))
	aggiorna()


func _process(_delta: float) -> void:
	aggiorna()


func aggiorna() -> void:
	visible = GameState.ha_flag(FLAG)
	var area: Variant = schermata.get("area_avanza") if schermata != null else null
	var si_legge: bool = area is Control and (area as Control).visible
	modulate.a = SPENTA if si_legge else 1.0
