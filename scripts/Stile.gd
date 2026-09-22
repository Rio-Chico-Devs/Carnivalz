extends Node

# Autoload: il linguaggio visivo del gioco, costruito una volta sola da
# data/stile.json e applicato alla radice dell'albero. Da quel momento ogni
# schermata eredita font, colori, bordi e spaziature senza doverseli
# ridichiarare: le scene non contengono piu' font_size o colori a occhio.
#
# Chi disegna qualcosa a mano (menu, mappa, combattimento) chiede qui i suoi
# valori - Stile.colore("accento"), Stile.dimensione("piccolo"),
# Stile.tempo("comparsa_box") - invece di scriverseli in giro.
#
# Deve stare negli autoload PRIMA di Impostazioni: l'alto contrasto e' una
# variante di questo tema, non un tema che lo sostituisce.

const PERCORSO := "res://data/stile.json"
# Oltre queste lettere una scelta smette di stringersi sul testo e prende tutta
# la colonna andando a capo. Trenta e' il punto in cui una scritta smette di
# essere un'etichetta e diventa una frase.
const LETTERE_SCELTA_CORTA := 30
# Un sesto del corpo: e' il rapporto che i tre contorni scelti a occhio avevano
# gia', misurato. Vedi contorno()
const QUOTA_CONTORNO := 0.167
# Sopra questo corpo le lettere vanno strette, e di questa frazione: -0,02 em,
# che e' il valore di partenza per le intestazioni. Vedi crenatura()
const CORPO_DA_STRINGERE := 36
const QUOTA_CRENATURA := 0.02

var dati: Dictionary = {}
var tema: Theme
var alto_contrasto := false

func _ready() -> void:
	carica()
	applica()

func carica() -> void:
	if not FileAccess.file_exists(PERCORSO):
		push_error("File stile mancante: " + PERCORSO)
		return
	var letto: Variant = JSON.parse_string(FileAccess.get_file_as_string(PERCORSO))
	dati = letto if letto is Dictionary else {}

# --- accesso ai valori (usato anche da chi costruisce controlli a mano) ---

func colore(nome: String) -> Color:
	var esadecimale := String(dati.get("colori", {}).get(nome, ""))
	if esadecimale == "":
		return Color.MAGENTA  # colore "manca un valore": si nota subito
	if alto_contrasto and nome in ["testo", "narrazione", "testo_smorzato"]:
		return Color(1.0, 0.92, 0.2)
	return Color.html(esadecimale)

func dimensione(nome: String) -> int:
	return int(dati.get("dimensioni", {}).get(nome, 20))

# --- quanto si stacca un colore da quello che ha dietro --------------------
#
# SE UN SEGNO PORTA UN'INFORMAZIONE, SI DEVE VEDERE. Non "si vede se guardi
# bene": si deve vedere. La soglia e' quella delle WCAG 1.4.11, che riguarda
# proprio i comandi e i loro stati - non il testo, i SEGNI - e dice 3:1.
#
# Il conto non e' "quanto e' chiaro" a occhio: e' la luminanza relativa,
# che pesa il verde piu' del rosso e il rosso piu' del blu perche' l'occhio
# fa cosi'. Ed e' per quello che il rosso #ed1c24 e il verde #2a8f4a della
# nostra tavolozza - che sembrano lontanissimi - stanno a 1,07:1 l'uno
# dall'altro: due tinte diverse alla STESSA luminosita'. Su una foto in
# bianco e nero sono lo stesso grigio, e per chi non distingue il rosso dal
# verde lo sono sempre.
#
# Da qui non si ricava un colore: si ricava un numero da mettere in una
# prova. Il colore lo sceglie chi disegna, il numero dice se ha funzionato.

const CONTRASTO_MINIMO := 3.0   # WCAG 1.4.11, comandi e stati

func luminanza(c: Color) -> float:
	return 0.2126 * canale_lineare(c.r) + 0.7152 * canale_lineare(c.g) \
			+ 0.0722 * canale_lineare(c.b)

func canale_lineare(v: float) -> float:
	return v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4)

func contrasto(a: Color, b: Color) -> float:
	var la := luminanza(a)
	var lb := luminanza(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)

func sopra(c: Color, fondo: Color) -> Color:
	# UN COLORE TRASPARENTE NON E' IL COLORE CHE SI VEDE, e misurare quello
	# scritto invece di quello composto e' il modo piu' facile per avere una
	# prova che passa su una schermata illeggibile: l'accento a 0,4 di opacita'
	# sul nero da' 1,80:1, ma se guardi l'accento e basta leggi 4,58:1. Qui si
	# spegne l'alfa mettendo il colore davvero sopra il suo fondo.
	return Color(lerpf(fondo.r, c.r, c.a), lerpf(fondo.g, c.g, c.a),
			lerpf(fondo.b, c.b, c.a))

func contrasto_su_sfondo(c: Color) -> float:
	var fondo := colore("sfondo")
	return contrasto(sopra(c, fondo), fondo)

func forma(nome: String) -> int:
	return int(dati.get("forme", {}).get(nome, 0))

func interlinea(etichetta: Control, quale: String, corpo: int) -> void:
	# QUANTO SPAZIO C'E' FRA UNA RIGA E L'ALTRA, e prima non lo decideva nessuno.
	#
	# Non c'era una sola riga in tutto il progetto che impostasse l'interlinea:
	# ogni etichetta si teneva quella del font, e il font e' quello di SISTEMA -
	# quindi lo stesso dialogo si leggeva diverso su Windows, su Mac e su Linux,
	# e non c'era modo di accorgersene provando su una macchina sola.
	#
	# La regola di mestiere: 1,4-1,6 per il testo da leggere, 1,5 va bene quasi
	# sempre; righe piu' lunghe vogliono piu' aria, e - questa e' quella che si
	# sbaglia - piu' il testo e' GRANDE meno spazio vuole fra le righe, non di
	# piu'. Per questo "titolo" sta a 1,1.
	#
	# SI CALCOLA SULLE METRICHE VERE, non a occhio. In Godot line_spacing e'
	# quanto si AGGIUNGE all'altezza naturale della riga, non l'altezza totale:
	# scriverci dentro 1,5 * corpo darebbe righe larghe il doppio. Si chiede al
	# font quanto e' alta una riga a questo corpo e si mette la differenza.
	# IL CORPO SI PASSA, NON SI CHIEDE AL TEMA. Chiederlo qui vuol dire
	# fotografare quello che c'e' in questo istante: l'interlinea resta poi
	# scritta addosso all'etichetta, e se il tema cambia - succede, l'alto
	# contrasto lo ricostruisce - lo spazio fra le righe resta quello di prima,
	# calcolato su un corpo che non c'e' piu'. Misurato: calcolata su 26 e letta
	# su 16, la riga risultava alta tre volte il carattere.
	var quanto := float(dati.get("interlinee", {}).get(quale, 1.5))
	# E I DUE NODI NON CHIAMANO LE STESSE COSE CON LO STESSO NOME. Una Label ha
	# "font" e aggiunge spazio con "line_spacing"; una RichTextLabel ha
	# "normal_font" e usa "line_separation". Chiedendo "font" a una
	# RichTextLabel si riceve null, si esce di qui, e non si imposta NIENTE -
	# senza nessun errore. E' successo: l'interlinea del dialogo era ancora
	# quella che capitava al font di sistema.
	var ricco := etichetta is RichTextLabel
	var carattere := etichetta.get_theme_font("normal_font" if ricco else "font")
	if carattere == null:
		push_warning("Stile.interlinea: nessun carattere su %s, l'interlinea resta quella del font" % etichetta.name)
		return
	var naturale := carattere.get_height(corpo)
	var voluta := float(corpo) * quanto
	etichetta.add_theme_constant_override("line_separation" if ricco else "line_spacing",
			int(round(maxf(voluta - naturale, 0.0))))

func contorno(etichetta: Label, corpo: int) -> void:
	# IL CONTORNO NERO INTORNO A UN NUMERO CHE ESCE SOPRA QUALUNQUE COSA.
	#
	# Serve dove il fondo non si sa: un numero di danno esce sopra il ritratto di
	# qualcuno e un ritratto puo' essere di qualunque colore; il numero di una
	# barra sta meta' sull'arancione e meta' sul nero. Chiaro dentro, scuro
	# intorno, e si stacca da tutto.
	#
	# ERA SCELTO A OCCHIO, tre volte: 5, 7 e 10, in tre file diversi. Messi in
	# rapporto ai corpi su cui stavano facevano 0,167 e 0,184 - cioe' erano
	# proporzionali PER CASO, e il primo corpo che avessimo cambiato avrebbe
	# rotto il rapporto senza che nessuno se ne accorgesse. Adesso e' una regola
	# sola: un sesto del corpo, e mai meno di due pixel, che sotto i due non si
	# vede piu' niente.
	etichetta.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.92))
	etichetta.add_theme_constant_override("outline_size", maxi(2, int(round(float(corpo) * QUOTA_CONTORNO))))

func imposta_corpo(etichetta: Control, corpo: int) -> void:
	# IL CORPO E LA CRENATURA INSIEME, perche' l'una dipende dall'altro e
	# tenerle separate vuol dire prima o poi cambiarne una sola
	etichetta.add_theme_font_size_override(
			"normal_font_size" if etichetta is RichTextLabel else "font_size", corpo)
	crenatura(etichetta, corpo)

func crenatura(etichetta: Control, corpo: int) -> void:
	# LO SPAZIO FRA LE LETTERE, e serve solo ai corpi grandi.
	#
	# La regola di mestiere: piu' il corpo e' grande, MENO spazio vuole fra una
	# lettera e l'altra. Un carattere e' disegnato per essere letto a corpo di
	# testo; ingrandito, quello stesso spazio diventa sciolto e la parola si
	# sfilaccia. Sopra i sessanta pixel si parte da -0,02/-0,03 em, e sulle
	# intestazioni da -0,01/-0,02. Sotto, non si tocca: stringere il testo da
	# leggere lo rende solo piu' difficile.
	#
	# In Godot non c'e' una costante di tema per questo: si avvolge il carattere
	# in una FontVariation e le si dice quanto togliere fra un glifo e l'altro.
	if corpo < CORPO_DA_STRINGERE:
		return
	var ricco := etichetta is RichTextLabel
	var base: Font = etichetta.get_theme_font("normal_font" if ricco else "font")
	if base == null:
		return
	var stretta := FontVariation.new()
	stretta.base_font = base
	stretta.spacing_glyph = -maxi(1, int(round(float(corpo) * QUOTA_CRENATURA)))
	etichetta.add_theme_font_override("normal_font" if ricco else "font", stretta)

func plancia(nome: String) -> Variant:
	# UNA MISURA DELLA SCHERMATA DI COMBATTIMENTO, come l'ha disegnata Bru.
	#
	# Tutte in frazioni e non in pixel: i disegni sono 1920x1080, la finestra
	# puo' essere di qualunque misura, e il disegno deve restare quello. Le
	# voci con quattro numeri sono rettangoli [x, y, largo, alto].
	return dati.get("plancia", {}).get(nome, null)

func riquadro(nome: String, dentro: Vector2) -> Rect2:
	# la stessa misura, ma gia' moltiplicata per il rettangolo che la contiene
	var r: Variant = plancia(nome)
	if not (r is Array) or (r as Array).size() < 4:
		return Rect2()
	var a: Array = r
	return Rect2(dentro.x * float(a[0]), dentro.y * float(a[1]),
			dentro.x * float(a[2]), dentro.y * float(a[3]))

func quota(nome: String) -> float:
	var v: Variant = plancia(nome)
	return float(v) if v != null and not (v is Array) else 0.0

func tempo(nome: String) -> float:
	return float(dati.get("tempi", {}).get(nome, 0.3))

func caratteri_al_secondo() -> float:
	return float(dati.get("tempi", {}).get("caratteri_al_secondo", 45))

func ritmo(nome: String) -> float:
	# le pause della macchina da scrivere sulla punteggiatura
	return float(dati.get("ritmo", {}).get(nome, 0.0))

# --- font ---

func font_da(chiave: String) -> Font:
	# priorita': un .ttf messo dentro il progetto > un font di sistema >
	# niente (e Godot usa il suo font incorporato)
	var config: Dictionary = dati.get("font", {})
	var percorso := String(config.get("file_" + chiave, ""))
	if percorso != "" and ResourceLoader.exists(percorso):
		return load(percorso)
	if not bool(config.get("usa_font_di_sistema", true)):
		return null
	var nomi: Array = config.get(chiave, [])
	if nomi.is_empty():
		return null
	var famiglia := SystemFont.new()
	var elenco := PackedStringArray()
	for nome in nomi:
		elenco.append(String(nome))
	famiglia.font_names = elenco
	return famiglia

# --- costruzione del tema ---

func applica() -> void:
	tema = costruisci_tema()
	get_tree().root.theme = tema

func imposta_alto_contrasto(attivo: bool) -> void:
	alto_contrasto = attivo
	applica()

func costruisci_tema() -> Theme:
	var t := Theme.new()
	var corpo := font_da("corpo")
	if corpo != null:
		t.default_font = corpo
	t.default_font_size = dimensione("corpo")

	# Label: il testo semplice dell'interfaccia
	t.set_color("font_color", "Label", colore("testo"))
	t.set_font_size("font_size", "Label", dimensione("corpo"))

	# RichTextLabel: narrazione, dialoghi, diario di combattimento
	t.set_color("default_color", "RichTextLabel", colore("testo"))
	for chiave in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		t.set_font_size(chiave, "RichTextLabel", dimensione("corpo"))

	# Bottoni: un solo aspetto in tutto il gioco, quattro stati leggibili
	t.set_stylebox("normal", "Button", stile_bottone("normale"))
	t.set_stylebox("hover", "Button", stile_bottone("sopra"))
	t.set_stylebox("pressed", "Button", stile_bottone("premuto"))
	t.set_stylebox("disabled", "Button", stile_bottone("spento"))
	t.set_stylebox("focus", "Button", stile_bottone("fuoco"))
	t.set_color("font_color", "Button", colore("testo"))
	t.set_color("font_hover_color", "Button", colore("accento"))
	t.set_color("font_pressed_color", "Button", colore("accento"))
	t.set_color("font_focus_color", "Button", colore("accento"))
	t.set_color("font_disabled_color", "Button", colore("testo_smorzato"))
	t.set_font_size("font_size", "Button", dimensione("corpo"))

	# CheckBox e slider delle Opzioni: stessi colori del resto
	t.set_color("font_color", "CheckBox", colore("testo"))
	t.set_color("font_hover_color", "CheckBox", colore("accento"))
	t.set_font_size("font_size", "CheckBox", dimensione("corpo"))
	t.set_color("font_color", "LineEdit", colore("testo"))

	# Pannelli
	t.set_stylebox("panel", "PanelContainer", stile_pannello())
	t.set_stylebox("panel", "Panel", stile_pannello())
	return t

func stile_pannello() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = colore("pannello")
	s.border_color = colore("bordo")
	s.set_border_width_all(forma("bordo"))
	s.set_corner_radius_all(forma("raggio"))
	return s

func stile_box_testo() -> StyleBox:
	# il box dove parla il gioco (dialogo/narrazione/notifica) e il diario di
	# combattimento condividono questa stessa cornice. Se Bru fornisce
	# un'immagine (sezione "box" di data/stile.json: usa_texture + texture +
	# margini) la si usa a nove riquadri - i bordi/angoli restano nitidi alla
	# dimensione disegnata, il centro si allunga per adattarsi a qualunque
	# testo. Senza immagine resta il box piatto coi colori di questo file:
	# cambiare uno dei due non richiede toccare nessuno script.
	var config: Dictionary = dati.get("box", {})
	var percorso := String(config.get("texture", ""))
	if bool(config.get("usa_texture", false)) and percorso != "" and ResourceLoader.exists(percorso):
		var s := StyleBoxTexture.new()
		s.texture = load(percorso)
		s.texture_margin_left = float(config.get("margine_sinistro", 24))
		s.texture_margin_right = float(config.get("margine_destro", 24))
		s.texture_margin_top = float(config.get("margine_alto", 20))
		s.texture_margin_bottom = float(config.get("margine_basso", 20))
		s.content_margin_left = float(config.get("padding_sinistro", s.texture_margin_left))
		s.content_margin_right = float(config.get("padding_destro", s.texture_margin_right))
		s.content_margin_top = float(config.get("padding_alto", s.texture_margin_top))
		s.content_margin_bottom = float(config.get("padding_basso", s.texture_margin_bottom))
		return s
	# IL BOX E' BIANCO COL BORDO NERO SPESSO, come nel disegno di Bru. E' l'unica
	# cosa chiara di tutta la schermata, ed e' apposta: dove si legge si guarda,
	# e una pagina bianca in mezzo al nero non ha bisogno di nessun'altra
	# indicazione per dire "qui c'e' da leggere".
	var piatto := StyleBoxFlat.new()
	piatto.bg_color = colore("box_fondo")
	piatto.border_color = colore("bordo")
	piatto.set_border_width_all(forma("bordo_box"))
	piatto.set_corner_radius_all(forma("raggio"))
	piatto.content_margin_left = forma("padding_box_x")
	piatto.content_margin_right = forma("padding_box_x")
	piatto.content_margin_top = forma("padding_box_y")
	piatto.content_margin_bottom = forma("padding_box_y")
	return piatto

func stile_bottone(stato: String) -> StyleBox:
	var texture := stile_bottone_texture(stato)
	if texture != null:
		return texture
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(forma("raggio"))
	s.set_border_width_all(forma("bordo"))
	s.content_margin_left = forma("padding_bottone_x")
	s.content_margin_right = forma("padding_bottone_x")
	s.content_margin_top = forma("padding_bottone_y")
	s.content_margin_bottom = forma("padding_bottone_y")
	match stato:
		"sopra":
			s.bg_color = colore("pannello_chiaro")
			s.border_color = colore("bordo_acceso")
		"premuto":
			s.bg_color = colore("bordo")
			s.border_color = colore("bordo_acceso")
		"spento":
			s.bg_color = Color(colore("pannello"), 0.35)
			s.border_color = Color(colore("bordo"), 0.4)
		"fuoco":
			s.bg_color = colore("pannello_chiaro")
			s.border_color = colore("bordo_acceso")
			s.set_border_width_all(forma("bordo_acceso"))
		_:
			s.bg_color = colore("pannello")
			s.border_color = colore("bordo")
	return s

func stile_bottone_texture(stato: String) -> StyleBoxTexture:
	# se Bru disegna UN SOLO frame di bottone (sezione "bottone_texture" di
	# data/stile.json), i cinque stati derivano tutti da quella stessa
	# immagine, ricolorata (modulate_color): non serve disegnare cinque
	# varianti. Senza immagine questa funzione non ritorna nulla, e
	# stile_bottone() ripiega sul bottone piatto qui sopra.
	var config: Dictionary = dati.get("bottone_texture", {})
	var percorso := String(config.get("texture", ""))
	if not bool(config.get("usa_texture", false)) or percorso == "" or not ResourceLoader.exists(percorso):
		return null
	var s := StyleBoxTexture.new()
	s.texture = load(percorso)
	s.texture_margin_left = float(config.get("margine_sinistro", 16))
	s.texture_margin_right = float(config.get("margine_destro", 16))
	s.texture_margin_top = float(config.get("margine_alto", 10))
	s.texture_margin_bottom = float(config.get("margine_basso", 10))
	s.content_margin_left = forma("padding_bottone_x")
	s.content_margin_right = forma("padding_bottone_x")
	s.content_margin_top = forma("padding_bottone_y")
	s.content_margin_bottom = forma("padding_bottone_y")
	match stato:
		"sopra":
			s.modulate_color = Color(1.18, 1.14, 1.05)
		"premuto":
			s.modulate_color = Color(0.78, 0.78, 0.8)
		"spento":
			s.modulate_color = Color(1, 1, 1, 0.4)
		"fuoco":
			s.modulate_color = Color(1.1, 1.02, 0.85)
		_:
			s.modulate_color = Color.WHITE
	return s

# --- aiutanti per i controlli costruiti a mano ---

func scelta(bottone: Button, genere := "") -> void:
	# LE SCELTE SONO RIQUADRI NERI CHE SI STRINGONO SUL LORO TESTO, appoggiati
	# al bordo destro sopra l'illustrazione. Nel disegno di Bru non c'e' nessuna
	# colonna: non e' una barra laterale, sono cartelli attaccati sulla scena, e
	# ognuno e' largo quanto le sue parole.
	#
	# Prima invece riempivano una colonna riservata larga sempre uguale. Serviva
	# a non far ballare i ritratti quando le scelte comparivano - problema che
	# qui non esiste piu', perche' le scelte stanno SOPRA la scena e non di
	# fianco: niente che compare puo' spostare niente.
	bottone.alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottone.clip_text = false
	bottone.add_theme_font_size_override("font_size", dimensione("sezione"))
	# QUANDO SI STRINGE E QUANDO VA A CAPO. Un Control in Godot non ha una
	# larghezza massima: o fa la misura del suo contenuto, o riempie quello che
	# gli danno. Quindi la decisione si prende qui, sulla lunghezza del testo -
	# le scritte corte ("Choice 1", "Hero option") si stringono come nel
	# disegno, una frase lunga prende tutta la colonna e va a capo invece di
	# uscire dallo schermo.
	if bottone.text.length() > LETTERE_SCELTA_CORTA:
		bottone.size_flags_horizontal = Control.SIZE_FILL
		bottone.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		bottone.size_flags_horizontal = Control.SIZE_SHRINK_END
		bottone.autowrap_mode = TextServer.AUTOWRAP_OFF
	var tinta := colore_scelta(genere)
	for stato in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		bottone.add_theme_color_override(stato, tinta)

func ritorno(bottone: Button) -> void:
	# LA VIA D'USCITA, E DEV'ESSERE LA STESSA OVUNQUE. La Sede e la mappa di
	# zona hanno tutt'e due un bottone per tornare indietro, e fino a ieri erano
	# due bottoni diversi: uno grande in fondo a una colonna, uno piccolo e
	# grigio del tema di serie. Non e' un dettaglio di gusto - una cosa che fa
	# sempre lo stesso mestiere deve avere sempre la stessa faccia, se no
	# ognuna va riconosciuta da capo. Qui e' quieta: e' l'uscita, non l'invito.
	bottone.alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottone.clip_text = false
	bottone.autowrap_mode = TextServer.AUTOWRAP_OFF
	bottone.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	imposta_corpo(bottone, dimensione("piccolo"))
	bottone.add_theme_color_override("font_color", colore("testo_smorzato"))
	for acceso in ["font_hover_color", "font_focus_color", "font_pressed_color"]:
		bottone.add_theme_color_override(acceso, colore("accento"))
	for stato in ["normal", "hover", "pressed", "focus"]:
		var scatola := StyleBoxFlat.new()
		scatola.bg_color = Color(colore("tratto"), 0.0 if stato == "normal" else 0.30)
		scatola.set_border_width_all(1)
		scatola.border_color = colore("accento") if stato != "normal" \
				else Color(colore("tratto"), 0.8)
		scatola.set_corner_radius_all(3)
		scatola.content_margin_left = 16
		scatola.content_margin_right = 16
		scatola.content_margin_top = 8
		scatola.content_margin_bottom = 8
		bottone.add_theme_stylebox_override(stato, scatola)

func voce_di_elenco(bottone: Button, gutter: int) -> void:
	# UNA RIGA DI ELENCO, E NON E' UNA SCELTA DI DIALOGO.
	#
	# scelta() qui sopra mette SIZE_SHRINK_END, ed e' giusto per quello che fa:
	# nel disegno di Bru le scelte sono cartelli appoggiati al bordo destro
	# sopra l'illustrazione, ognuno largo quanto le sue parole. Ma la Sede la
	# riusava per una COLONNA A SINISTRA, e allora quello stesso SHRINK_END
	# diventa il difetto che si vede subito: sei riquadri di sei larghezze
	# diverse, incolonnati a destra, con il margine sinistro a zigzag. Bru:
	# «siamo ancora disordinati».
	#
	# Una riga di elenco vuole il contrario di una scelta: tutte della stessa
	# larghezza, testo a filo a sinistra, e IL MARCATORE IN UNA CORSIA SUA. Se
	# il pallino sta dentro al testo - "•  Alloggi" contro "Archivio" - i nomi
	# partono da due x diverse a seconda che tu ci sia gia' stato o no, e
	# l'occhio non ha piu' nessuna linea da seguire. Il "gutter" e' quella
	# corsia: il testo comincia sempre dopo, il marcatore ci sta dentro.
	bottone.alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottone.clip_text = false
	bottone.autowrap_mode = TextServer.AUTOWRAP_OFF
	bottone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	imposta_corpo(bottone, dimensione("corpo"))
	for stato in ["normal", "hover", "pressed", "focus", "disabled"]:
		var scatola := StyleBoxFlat.new()
		scatola.bg_color = Color(colore("tratto"), 0.0 if stato == "normal"
				or stato == "disabled" else 0.32)
		scatola.content_margin_left = gutter
		scatola.content_margin_right = 12
		scatola.content_margin_top = 6
		scatola.content_margin_bottom = 6
		# il filetto acceso a sinistra: dice dove sei nell'elenco senza spostare
		# niente, che e' la ragione per cui non e' un bordo su tutti e quattro i
		# lati - un bordo che compare sposterebbe il testo di due pixel
		scatola.border_width_left = 3
		scatola.border_color = colore("accento") if stato == "hover" \
				or stato == "focus" or stato == "pressed" else Color(colore("tratto"), 0.5)
		bottone.add_theme_stylebox_override(stato, scatola)

func colore_scelta(genere: String) -> Color:
	# IL COLORE DICE CHE RAZZA DI SCELTA E'. Bru le ha disegnate cosi': il rosso
	# e' quella da villain, il blu quella da eroe, il bianco tutte le altre. Non
	# e' decorazione - sono le uniche due che scadono, e il colore e' come si
	# riconoscono prima di leggerle.
	match genere:
		"malvagio": return colore("malvagio")
		"eroe": return colore("eroe")
		_: return colore("testo")

func colore_danno(elemento: String) -> Color:
	# Il colore di un numero che vola. "critico" e "cura" sono due elementi come
	# gli altri: chi mostra il numero sa gia' cosa sta mostrando, e chiede il
	# colore per nome invece di sceglierselo. Un elemento che nessuno ha
	# dichiarato (o una mossa senza elemento) torna al rosso del colpo normale.
	var tabella: Dictionary = dati.get("colori_danno", {})
	var esadecimale := String(tabella.get(elemento, tabella.get("normale", "#c04a4d")))
	if alto_contrasto:
		return Color(1.0, 0.92, 0.2)
	return Color.html(esadecimale)

func colore_tipo(nome_tipo: String) -> Color:
	# Il colore di uno dei cinque tipi, preso da data/tipi.json e non da qui.
	# Una seconda copia delle tinte dentro stile.json sarebbe comoda e sbagliata:
	# il giorno che Bru cambia il colore di Spirituale lo cambia dove i tipi sono
	# descritti, e questo file non ne saprebbe niente.
	var dati_tipo: Dictionary = GameState.tipi.get(nome_tipo, {})
	var esadecimale := String(dati_tipo.get("colore", ""))
	if esadecimale == "":
		return colore_danno("normale")
	if alto_contrasto:
		return Color(1.0, 0.92, 0.2)
	return Color.html(esadecimale)

func colore_colpo(elemento: String, tipo_colpo: String, critico := false) -> Color:
	# DI CHE COLORE E' QUESTO COLPO. Tre voci, in quest'ordine, e l'ordine e' il
	# ragionamento:
	#
	#   1. un critico e' oro, sempre. E' l'eccezione piu' forte che ci sia e non
	#      deve mai confondersi con nient'altro
	#   2. l'ELEMENTO, se la mossa ne dichiara uno. Il fuoco e' arancione e il
	#      veleno e' verde acido da prima che i tipi esistessero, sono colori che
	#      funzionano, e cancellarli per far posto ai tipi sarebbe stato buttare
	#      via una cosa buona per farne entrare un'altra
	#   3. il TIPO di chi colpisce, per tutto il resto. Ed e' la novita': la
	#      stragrande maggioranza dei colpi non dichiara nessun elemento, quindi
	#      fino a ieri erano tutti dello stesso rosso. Adesso un colpo di
	#      Artificio e uno di Natura si distinguono a occhio anche senza leggere
	#      niente, e cambiare arma si VEDE
	if critico:
		return colore_danno("critico")
	if elemento != "":
		return colore_danno(elemento)
	if tipo_colpo != "":
		return colore_tipo(tipo_colpo)
	return colore_danno("normale")

# --- dove sei gia' stato ---
#
# Tre stati, tre colori, uguali in tutto il gioco: la mappa stellare, il Vuoto,
# la mappa di una zona, le stanze della Sede e persino le scelte di un dialogo
# che portano da qualche parte. Un posto nuovo chiama (ottone, e un pallino che
# lo stacca dagli altri); uno gia' visto non deve piu' chiamare (smorzato); uno
# chiuso si toglie di mezzo (verde).
#
# Perche' un pallino e non solo il colore: chi non distingue bene i colori deve
# poter vedere lo stesso quali posti gli restano da battere.
const VISITA_NUOVO := "nuovo"
const VISITA_VISTO := "visto"
const VISITA_CHIUSO := "chiuso"

func colore_visita(stato: String) -> Color:
	match stato:
		VISITA_NUOVO: return colore("accento")
		VISITA_CHIUSO: return colore("positivo")
		_: return colore("testo_smorzato")

func segna_visita(bottone: Button, stato: String) -> void:
	var tinta := colore_visita(stato)
	for chiave in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		bottone.add_theme_color_override(chiave, tinta)
	if stato == VISITA_NUOVO:
		bottone.text = "•  " + bottone.text
	elif stato == VISITA_CHIUSO:
		bottone.text = "✓  " + bottone.text

func legenda_visite() -> Label:
	# senza questa riga i colori sono un indovinello: si scrive una volta, in
	# fondo a ogni schermata che li usa
	var etichetta := Label.new()
	etichetta.text = "•  non ci sei ancora stato        ✓  chiuso"
	etichetta_piccola(etichetta)
	return etichetta

func barra(larghezza := 120, altezza := 8) -> Control:
	# UNA BARRA, non un numero. "Dominio 15" e' un'informazione; una barra che
	# si riempie e poi si svuota e' una cosa che GUARDI mentre gioca. Il
	# dominio e' uno sfogo che si carica e si scarica, e senza vederlo salire
	# non c'e' niente da aspettare.
	#
	# Disegnata col segnale draw invece che con una ProgressBar: cosi' non serve
	# ne' uno script suo ne' un tema a parte, e il pieno puo' cambiare colore
	# quando la barra e' carica - che e' l'unico momento che conta.
	var telaio := Control.new()
	telaio.custom_minimum_size = Vector2(larghezza, altezza)
	telaio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	telaio.set_meta("quota", 0.0)
	telaio.draw.connect(func() -> void:
		var quota := clampf(float(telaio.get_meta("quota", 0.0)), 0.0, 1.0)
		var dentro := Rect2(Vector2.ZERO, telaio.size)
		telaio.draw_rect(dentro, colore("pannello"))
		if quota > 0.0:
			var piena := quota >= 0.999
			telaio.draw_rect(Rect2(Vector2.ZERO, Vector2(telaio.size.x * quota, telaio.size.y)),
					colore("accento") if piena else colore("bordo_acceso"))
		telaio.draw_rect(dentro, colore("tratto"), false, 1.0))
	return telaio

func riempi_barra(telaio: Control, quota: float) -> void:
	if telaio == null or not is_instance_valid(telaio):
		return
	telaio.set_meta("quota", clampf(quota, 0.0, 1.0))
	telaio.queue_redraw()

func etichetta_piccola(etichetta: Label) -> void:
	etichetta.add_theme_font_size_override("font_size", dimensione("piccolo"))
	etichetta.add_theme_color_override("font_color", colore("testo_smorzato"))

func titolo_schermata(etichetta: Label) -> void:
	etichetta.add_theme_font_size_override("font_size", dimensione("sezione"))
	etichetta.add_theme_color_override("font_color", colore("accento"))

func lampeggia(nodo: CanvasItem, tinta: Color) -> void:
	# un colpo si deve vedere sul ritratto, non solo leggere nel diario
	if nodo == null or not is_instance_valid(nodo):
		return
	var durata := tempo("lampeggio_colpo")
	# CON IL MOVIMENTO RIDOTTO IL COLPO NON LAMPEGGIA, TINGE. L'informazione
	# resta tutta - hai preso un colpo, e di che elemento era - ma arriva senza
	# un battito: e' il lampeggio, non il colore, quello che da' fastidio a chi
	# soffre di emicrania o di epilessia fotosensibile.
	if Impostazioni.movimento_ridotto:
		var tinta_calma := Color.WHITE.lerp(tinta, 0.45)
		var lento := nodo.create_tween()
		lento.tween_property(nodo, "modulate", tinta_calma, durata * 0.6)
		lento.tween_property(nodo, "modulate", Color.WHITE, durata * 1.4)
		return
	var battito := nodo.create_tween()
	battito.tween_property(nodo, "modulate", tinta, durata * 0.35)
	battito.tween_property(nodo, "modulate", Color.WHITE, durata * 0.65)

func pulsa(nodo: CanvasItem, durata_battito := 0.0) -> Tween:
	# battito lento e infinito di opacita': l'invito a proseguire non deve
	# mai restare immobile, o si perde tra tutto il resto che e' fermo a
	# schermo. Il nodo deve gia' essere dentro l'albero quando si chiama
	# questo (create_tween() lo richiede) - va chiamato dopo add_child().
	#
	# Restituisce il tween perche' un battito che non si puo' SPEGNERE e' meta'
	# meccanica: l'allarme della vita bassa deve smettere quando ti curi, e senza
	# un riferimento da fermare resterebbe acceso per tutto lo scontro.
	if nodo == null or not is_instance_valid(nodo):
		return null
	var durata := durata_battito if durata_battito > 0.0 else tempo("battito_indicatore")
	var battito: Tween = nodo.create_tween().set_loops()
	battito.tween_property(nodo, "modulate:a", 0.35, durata)
	battito.tween_property(nodo, "modulate:a", 1.0, durata)
	return battito

func costruisci_prompt(testo: String) -> HBoxContainer:
	# la riga "◆  premi per continuare  ◆": lo stesso identico invito a
	# proseguire ovunque compaia nel gioco (crawl introduttivo, carta del
	# titolo di un luogo). Centrata per costruzione (allineamento del
	# contenitore, non offset calcolati a mano): non puo' sfasarsi quando
	# cambia la larghezza dello schermo. Non pulsa da sola: chiamare
	# Stile.pulsa() dopo averla aggiunta all'albero.
	var riga := HBoxContainer.new()
	riga.alignment = BoxContainer.ALIGNMENT_CENTER
	riga.mouse_filter = Control.MOUSE_FILTER_IGNORE
	riga.add_theme_constant_override("separation", 14)
	riga.add_child(_rombo_prompt())
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etichetta.add_theme_color_override("font_color", colore("testo_smorzato"))
	etichetta.add_theme_font_size_override("font_size", dimensione("piccolo"))
	riga.add_child(etichetta)
	riga.add_child(_rombo_prompt())
	return riga

func _rombo_prompt() -> Label:
	var rombo := Label.new()
	rombo.text = "◆"
	rombo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rombo.add_theme_color_override("font_color", colore("bordo_acceso"))
	rombo.add_theme_font_size_override("font_size", dimensione("minuscolo"))
	return rombo
