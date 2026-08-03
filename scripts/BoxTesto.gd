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
#
# La macchina da scrivere non va a velocita' costante: si ferma dove si
# fermerebbe una voce. Una virgola e' un respiro corto, un punto una pausa
# vera, i puntini di sospensione un silenzio. Il testo arriva a pezzi di
# frase invece che a filo continuo - la stessa frase letta ad alta voce.
# Le durate stanno in data/stile.json, sezione "ritmo".
#
# Altezza SEMPRE fissa (Stile.forma("altezza_box")): "fit_content" e' spento
# apposta. Un messaggio piu' lungo di un altro non deve far crescere il box
# e spingere su/giu' tutto il resto della schermata (i ritratti sopra) - se
# un testo non ci sta, scorre dentro il box (scroll_active), il box stesso
# non si muove mai. Per lo stesso motivo:
#   - il triangolino "vai avanti" NON sta nella colonna: e' un fratello del
#     contenitore, sovrapposto in basso a destra. Se stesse nel flusso, il
#     box crescerebbe di una riga ogni volta che compare.
#   - la targhetta col nome non si nasconde mai: quando non parla nessuno
#     resta li' vuota. Nasconderla toglierebbe la sua riga e farebbe saltare
#     su il testo tra una narrazione e un dialogo.

signal scrittura_finita

# Un colpetto di voce ogni tot lettere, mentre scrive. Tre e' il numero che
# suona come parlato: a una lettera diventa una mitragliata, a cinque sembra
# che il personaggio balbetti. Durante i respiri sulla punteggiatura le lettere
# non avanzano, quindi la voce si ferma da sola dove si fermerebbe una vera.
const LETTERE_PER_BLIP := 3

@onready var targhetta: Label = %Targhetta
@onready var testo: RichTextLabel = %Testo
@onready var indicatore: Label = %Indicatore

var sta_scrivendo := false
var tween_testo: Tween
var tween_indicatore: Tween
var tipo_corrente := "narrazione"
var nome_corrente := ""
var lettere_al_blip := 0

func _ready() -> void:
	add_theme_stylebox_override("panel", Stile.stile_box_testo())
	targhetta.add_theme_color_override("font_color", Stile.colore("accento"))
	targhetta.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	indicatore.add_theme_color_override("font_color", Stile.colore("accento"))
	indicatore.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	indicatore.visible = false
	# la targhetta tiene la sua riga anche quando e' vuota: se collassasse, il
	# testo salterebbe su di una riga passando da un dialogo a una narrazione
	var font_targhetta := targhetta.get_theme_font("font")
	if font_targhetta != null:
		targhetta.custom_minimum_size = Vector2(0, font_targhetta.get_height(Stile.dimensione("nome")))
	imposta_altezza(Stile.forma("altezza_box"))

func imposta_altezza(altezza_testo: int) -> void:
	# l'altezza del box si decide una volta e non cambia piu': testo + riga
	# della targhetta + separazione + i margini della cornice. Il combattimento
	# ne chiede una piu' bassa (messaggi corti, e il campo ha bisogno di spazio)
	var altezza_nome := 0.0
	var font_nome := targhetta.get_theme_font("font")
	if font_nome != null:
		altezza_nome = font_nome.get_height(Stile.dimensione("nome"))
	testo.custom_minimum_size = Vector2(0, altezza_testo)
	var cornice := Stile.stile_box_testo()
	custom_minimum_size = Vector2(0, altezza_testo + altezza_nome + 8
			+ cornice.get_margin(SIDE_TOP) + cornice.get_margin(SIDE_BOTTOM))

func mostra(tipo: String, contenuto: String, nome_parlante: String) -> void:
	visible = true
	tipo_corrente = tipo
	nome_corrente = nome_parlante
	lettere_al_blip = 0
	if tipo == "notifica":
		# la notifica non e' qualcuno che parla, e' il gioco che ti dice che hai
		# qualcosa in piu': ha un suono suo, e arriva prima delle parole
		AudioManager.interfaccia("raccolta")
	testo.scroll_to_line(0)  # nuovo messaggio: si riparte sempre dall'inizio del testo
	match tipo:
		"dialogo":
			targhetta.text = nome_parlante
			testo.text = contenuto
			testo.add_theme_color_override("default_color", Stile.colore("testo"))
		"notifica":
			targhetta.text = ""
			testo.text = "[center]%s[/center]" % contenuto
			testo.add_theme_color_override("default_color", Stile.colore("accento"))
		_:
			targhetta.text = ""
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
	set_process(true)
	tween_testo = create_tween()
	# un pezzo di tween per ogni pezzo di frase, con in mezzo il respiro
	var scritti := 0
	for respiro in respiri(testo.get_parsed_text()):
		var fino_a: int = mini(int(respiro[0]), totale)
		var pausa: float = float(respiro[1])
		if fino_a <= scritti or fino_a >= totale:
			continue
		tween_testo.tween_property(testo, "visible_ratio", float(fino_a) / float(totale),
				float(fino_a - scritti) / velocita)
		if pausa > 0.0:
			# chi ha alzato la velocita' del testo vuole meno attesa anche qui
			tween_testo.tween_interval(pausa / maxf(Impostazioni.velocita_testo, 0.1))
		scritti = fino_a
	if scritti < totale:
		tween_testo.tween_property(testo, "visible_ratio", 1.0,
				float(totale - scritti) / velocita)
	tween_testo.finished.connect(conclusione)

func respiri(grezzo: String) -> Array:
	# [[indice a cui fermarsi, secondi di pausa], ...]. "grezzo" e' il testo
	# senza bbcode: gli indici combaciano con quelli di visible_ratio.
	var punti: Array = []
	var lunghezza := grezzo.length()
	var i := 0
	while i < lunghezza:
		var c := grezzo[i]
		if c == ".":
			# quanti punti di fila: uno e' un punto fermo, tre sono un silenzio
			var fine := i
			while fine < lunghezza and grezzo[fine] == ".":
				fine += 1
			var quanti := fine - i
			if _c_e_altro_dopo(grezzo, fine):
				punti.append([fine, Stile.ritmo("pausa_sospensione") if quanti >= 2 else Stile.ritmo("pausa_punto")])
			i = fine
			continue
		if c == "!" or c == "?":
			var fine_forte := i
			while fine_forte < lunghezza and (grezzo[fine_forte] == "!" or grezzo[fine_forte] == "?"):
				fine_forte += 1
			if _c_e_altro_dopo(grezzo, fine_forte):
				punti.append([fine_forte, Stile.ritmo("pausa_punto")])
			i = fine_forte
			continue
		if c == "," or c == ";" or c == ":":
			if _c_e_altro_dopo(grezzo, i + 1):
				punti.append([i + 1, Stile.ritmo("pausa_virgola")])
		i += 1
	return punti

func _c_e_altro_dopo(grezzo: String, da: int) -> bool:
	# non ha senso respirare sull'ultima punteggiatura della frase: il
	# messaggio finisce li' e la pausa la fa gia' il giocatore
	return grezzo.substr(da).strip_edges() != ""

func completa() -> void:
	# il giocatore ha fretta: il testo si chiude subito, senza saltare nulla
	if not sta_scrivendo:
		return
	ferma_tween()
	testo.visible_ratio = 1.0
	conclusione()

func _process(_delta: float) -> void:
	# quante lettere sono comparse da quando ha suonato l'ultima volta
	if not sta_scrivendo:
		set_process(false)
		return
	var scritte := int(testo.visible_ratio * testo.get_total_character_count())
	if scritte - lettere_al_blip < LETTERE_PER_BLIP:
		return
	lettere_al_blip = scritte
	AudioManager.blip(nome_corrente, tipo_corrente)

func conclusione() -> void:
	sta_scrivendo = false
	set_process(false)
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
