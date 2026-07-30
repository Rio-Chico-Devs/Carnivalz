extends PanelContainer

# Il box del testo: l'unico posto dove il gioco parla al giocatore.
# Lo usano la schermata eventi e (in forma ridotta) le altre schermate che
# devono dire qualcosa. Regole, tutte qui dentro e non sparse nei JSON:
#
#   dialogo     -> targhetta col nome di chi parla, testo dritto, colore pieno
#   narrazione  -> nessuna targhetta, corsivo, colore piu' spento: e' la voce
#                  che racconta dall'esterno, non qualcuno nella stanza
#   notifica    -> nessuna targhetta, centrato, colore accento: e' il gioco
#                  che ti informa (hai raccolto, hai imparato), non la storia
#
# Il testo non compare mai tutto insieme: si scrive a macchina. Un click lo
# completa subito, il successivo passa avanti (comportamento standard delle
# visual novel, e la cosa che i giocatori si aspettano senza doverla imparare).
# Finita la scrittura compare il triangolino che pulsa in basso a destra.

signal scrittura_finita

@onready var targhetta: Label = %Targhetta
@onready var testo: RichTextLabel = %Testo
@onready var indicatore: Label = %Indicatore

var sta_scrivendo := false
var tween_testo: Tween
var tween_indicatore: Tween

func _ready() -> void:
	add_theme_stylebox_override("panel", stile_box())
	targhetta.add_theme_color_override("font_color", Stile.colore("accento"))
	targhetta.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	indicatore.add_theme_color_override("font_color", Stile.colore("accento"))
	indicatore.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	indicatore.visible = false
	testo.custom_minimum_size = Vector2(0, Stile.forma("altezza_box"))

func stile_box() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(Stile.colore("pannello"), 0.94)
	s.border_color = Stile.colore("bordo")
	s.set_border_width_all(Stile.forma("bordo"))
	s.set_corner_radius_all(Stile.forma("raggio"))
	s.content_margin_left = Stile.forma("padding_box_x")
	s.content_margin_right = Stile.forma("padding_box_x")
	s.content_margin_top = Stile.forma("padding_box_y")
	s.content_margin_bottom = Stile.forma("padding_box_y")
	return s

func mostra(tipo: String, contenuto: String, nome_parlante: String) -> void:
	visible = true
	match tipo:
		"dialogo":
			targhetta.visible = nome_parlante != ""
			targhetta.text = nome_parlante
			testo.text = contenuto
			testo.add_theme_color_override("default_color", Stile.colore("testo"))
		"notifica":
			targhetta.visible = false
			testo.text = "[center]%s[/center]" % contenuto
			testo.add_theme_color_override("default_color", Stile.colore("accento"))
		_:
			targhetta.visible = false
			testo.text = "[i]%s[/i]" % contenuto
			testo.add_theme_color_override("default_color", Stile.colore("narrazione"))
	scrivi_a_macchina()

func scrivi_a_macchina() -> void:
	ferma_tween()
	indicatore.visible = false
	var totale := testo.get_total_character_count()
	var velocita := Stile.caratteri_al_secondo() * Impostazioni.velocita_testo
	if totale <= 0 or velocita <= 0.0:
		testo.visible_ratio = 1.0
		conclusione()
		return
	testo.visible_ratio = 0.0
	sta_scrivendo = true
	tween_testo = create_tween()
	tween_testo.tween_property(testo, "visible_ratio", 1.0, float(totale) / velocita)
	tween_testo.finished.connect(conclusione)

func completa() -> void:
	# il giocatore ha fretta: il testo si chiude subito, senza saltare nulla
	if not sta_scrivendo:
		return
	ferma_tween()
	testo.visible_ratio = 1.0
	conclusione()

func conclusione() -> void:
	sta_scrivendo = false
	indicatore.visible = true
	if tween_indicatore != null and tween_indicatore.is_valid():
		tween_indicatore.kill()
	var battito := Stile.tempo("battito_indicatore")
	tween_indicatore = create_tween().set_loops()
	tween_indicatore.tween_property(indicatore, "modulate:a", 0.15, battito)
	tween_indicatore.tween_property(indicatore, "modulate:a", 1.0, battito)
	scrittura_finita.emit()

func nascondi_indicatore() -> void:
	# a coda finita non c'e' piu' niente da far avanzare: comandano le scelte
	indicatore.visible = false
	if tween_indicatore != null and tween_indicatore.is_valid():
		tween_indicatore.kill()

func ferma_tween() -> void:
	if tween_testo != null and tween_testo.is_valid():
		tween_testo.kill()
	sta_scrivendo = false
