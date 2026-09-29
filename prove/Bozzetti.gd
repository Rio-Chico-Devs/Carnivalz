extends RefCounted

# BOZZETTI DELL'INTERFACCIA NELLA LINGUA DELL'IMMAGINE DI BRU: anteprime, non
# il gioco.
#
# Il primo giro (prove/Temi.gd) ricolorava le schermate com'erano. Bru: «non mi
# piacciono molto gli esempi... potresti fare meglio?». Aveva ragione: un tema
# di colori non e' uno stile grafico. Nell'immagine lo stile e' fatto di pezzi
# precisi, e qui ci sono quei pezzi:
#
#   - le ETICHETTE NERE, inclinate, con la scritta chiara in un grottesco nero
#     e corsivo; sotto, una striscia piu' sottile con la scritta arancio
#   - i PANNELLI COME CARTA: grigio caldo, contorno nero spesso, un'ombra nera
#     piena spostata di lato, e il retino a puntini nell'angolo
#   - lo SCHERMO NERO DENTRO UNA CORNICE CHIARA, come il cabinato
#   - le PILLOLE arrotondate per i tasti e i contatori
#   - la BANDA NERA in basso
#   - il fondo arancio con gli anelli appena visibili
#
# Le disposizioni sono quelle delle schermate vere (le misure della plancia,
# le voci della pausa e del menu), i testi sono quelli del gioco. Nomi (Fell,
# nastro strappato) e dialoghi (Bricolage) restano quelli approvati; cambia
# solo il colore del nastro. Il carattere dei titoli e' Archivo corsivo (OFL,
# The Archivo Project Authors): per le anteprime si legge da
# CARNIVALZ_BOZZETTI_FONT, e se Bru sceglie questa strada entra in art/font
# con la sua licenza. Senza, i bozzetti usano il carattere dei titoli di oggi.
#
#   CARNIVALZ_BOZZETTI_FONT=/percorso/Archivo-Italic.ttf ./prove/scatto.sh bozzetto combattimento

const Temi := preload("res://prove/Temi.gd")

const ARANCIO := Color("#f4931b")
const ARANCIO_SCURO := Color("#c96f12")
const NERO := Color("#0b0908")
const CREMA := Color("#d8cfc7")
const CREMA_CHIARA := Color("#ece6df")
const RETINO := Color("#b9b2ac")
const GRIGIO := Color("#3a3430")
const SPENTO := Color("#8c847e")
const ROSSO := Color("#c8281e")
const VETRO := Color("#141110")

const NOMI := ["combattimento", "dialogo_banda", "dialogo_carta", "dialogo_cornice", "pausa", "menu"]

static var file_titoli: FontFile = null


static func titoli(peso := 820.0, larghezza := 86.0) -> Font:
	# il grottesco nero e corsivo delle etichette
	if file_titoli == null:
		var percorso := OS.get_environment("CARNIVALZ_BOZZETTI_FONT")
		if percorso == "" or not FileAccess.file_exists(percorso):
			return Caratteri.titolo()
		file_titoli = FontFile.new()
		file_titoli.load_dynamic_font(percorso)
	var variante := FontVariation.new()
	variante.base_font = file_titoli
	var ts := TextServerManager.get_primary_interface()
	variante.variation_opentype = {ts.name_to_tag("wght"): peso, ts.name_to_tag("wdth"): larghezza}
	return variante


static func largo(testo: String, corpo: int, carattere: Font = null) -> float:
	var con := carattere if carattere != null else titoli()
	return con.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x


static func crea(nome: String) -> Control:
	var tela := Control.new()
	tela.size = Vector2(1280, 720)
	match nome:
		"combattimento": combattimento(tela)
		"dialogo_banda": dialogo(tela, "banda")
		"dialogo_carta": dialogo(tela, "carta")
		"dialogo_cornice": dialogo(tela, "cornice")
		"pausa": pausa(tela)
		"menu": menu(tela)
		_: push_error("bozzetto '%s' sconosciuto (ci sono %s)" % [nome, ", ".join(NOMI)])
	return tela


# --- i pezzi ---------------------------------------------------------------------

static func fondo(tela: Control, tinta := ARANCIO) -> void:
	var piatto := ColorRect.new()
	piatto.color = tinta
	piatto.size = tela.size
	tela.add_child(piatto)
	var trama: Control = Temi.Trama.new()
	trama.set("tinta", tinta)
	trama.size = tela.size
	piatto.add_child(trama)


static func etichetta(tela: Control, testo: String, corpo: int, dove: Vector2, inchiostro := CREMA,
		tinta := NERO, carattere: Font = null) -> Etichetta:
	var tag := Etichetta.new()
	tag.testo = testo
	tag.corpo = corpo
	tag.inchiostro = inchiostro
	tag.tinta = tinta
	tag.carattere = carattere if carattere != null else titoli()
	tag.position = dove
	tag.size = tag.misura()
	tela.add_child(tag)
	return tag


static func striscia(tela: Control, testo: String, dove: Vector2, corpo := 15) -> Etichetta:
	# la riga sottile sotto le etichette: largo, spaziato, arancio sul nero
	return etichetta(tela, testo, corpo, dove, ARANCIO, NERO, titoli(700.0, 125.0))


static func scritta(tela: Control, testo: String, corpo: int, dove: Vector2, tinta := NERO,
		carattere: Font = null) -> Label:
	var riga := Label.new()
	riga.text = testo
	riga.add_theme_font_override("font", carattere if carattere != null else titoli())
	riga.add_theme_font_size_override("font_size", corpo)
	riga.add_theme_color_override("font_color", tinta)
	riga.position = dove
	tela.add_child(riga)
	return riga


static func pillola(tela: Control, testo: String, dove: Vector2, corpo: int, tinta := NERO,
		inchiostro := CREMA, alto := 0.0) -> Pillola:
	var tasto := Pillola.new()
	tasto.testo = testo
	tasto.corpo = corpo
	tasto.tinta = tinta
	tasto.inchiostro = inchiostro
	tasto.carattere = titoli()
	tasto.position = dove
	tasto.size = tasto.misura(alto)
	tela.add_child(tasto)
	return tasto


static func pannello(tela: Control, dove: Rect2, tinta := CREMA, ombra := Vector2(10, 10)) -> Pannello:
	var carta := Pannello.new()
	carta.tinta = tinta
	carta.ombra = ombra
	carta.position = dove.position
	carta.size = dove.size
	tela.add_child(carta)
	return carta


static func schermo(tela: Control, dove: Rect2, lettera: String, cornice := CREMA) -> Schermo:
	var monitor := Schermo.new()
	monitor.lettera = lettera
	monitor.cornice = cornice
	monitor.carattere = titoli()
	monitor.position = dove.position
	monitor.size = dove.size
	tela.add_child(monitor)
	return monitor


static func disegno(tela: Control, quale: Control, dove: Rect2) -> Control:
	quale.position = dove.position
	quale.size = dove.size
	tela.add_child(quale)
	return quale


static func banda_in_fondo(tela: Control, tasti: Array, alta := 64.0) -> void:
	# la banda nera dell'immagine, coi tasti a pillola allineati a destra come
	# nel menu vero
	var nero := ColorRect.new()
	nero.color = NERO
	nero.position = Vector2(0, 720.0 - alta)
	nero.size = Vector2(1280, alta)
	tela.add_child(nero)
	var x := 1232.0
	for i in range(tasti.size() - 1, -1, -1):
		var cosa := String(tasti[i][1])
		x -= largo(cosa, 22)
		scritta(tela, cosa, 22, Vector2(x, 720.0 - alta * 0.5 - 16.0), CREMA)
		var tasto := pillola(tela, String(tasti[i][0]), Vector2.ZERO, 17, ARANCIO, NERO, 34)
		x -= tasto.size.x + 12.0
		tasto.position = Vector2(x, 720.0 - alta * 0.5 - 17.0)
		x -= 36.0


# --- il combattimento --------------------------------------------------------------

static func combattimento(tela: Control) -> void:
	# LA PLANCIA, alle sue misure: il nemico a sinistra dentro il suo schermo,
	# la squadra in alto (chi ha il turno ha la cornice chiara, gli altri nera),
	# il quadrante in basso come un foglio di carta. La marionetta con Veronica
	# in squadra, come nello scatto della plancia di oggi
	fondo(tela)
	schermo(tela, Rect2(27, 17, 476, 468), "M")
	etichetta(tela, "MARIONETTA", 46, Vector2(22, 506))
	striscia(tela, "HP ???   ·   NON L'HAI ANCORA GUARDATA", Vector2(46, 574), 16)
	var chi := ["A", "V", ""]
	for i in 3:
		schermo(tela, Rect2(521 + i * 252, 17, 240, 218), chi[i], CREMA if i == 0 else NERO)
	var numeri := [["100/100", "10/10"], ["600/600", ""]]
	for i in 2:
		var x := 521.0 + i * 252.0
		barra(tela, Rect2(x, 258, 240, 16), "HP", 1.0, CREMA_CHIARA, numeri[i][0])
		barra(tela, Rect2(x, 282, 240, 16), "AURA", 1.0, SPENTO, numeri[i][1])
		barra(tela, Rect2(x, 306, 240, 16), "", [0.06, 0.0][i], ROSSO, "")
		disegno(tela, Tondo.new(), Rect2(x + 52, 342, 46, 46))
	quadrante(pannello(tela, Rect2(524, 436, 733, 256)))


static func barra(tela: Control, dove: Rect2, nome: String, quota: float, tinta: Color, numero: String) -> void:
	var tacca := Barra.new()
	tacca.quota = quota
	tacca.tinta = tinta
	tacca.numero = numero
	tacca.carattere = titoli(700.0, 100.0)
	disegno(tela, tacca, Rect2(dove.position + Vector2(52, 0), dove.size - Vector2(52, 0)))
	if nome != "":
		scritta(tela, nome, 15, dove.position + Vector2(0, -3))


static func quadrante(carta: Control) -> void:
	# la faccia dei comandi: l'ECG, morale e stress, MATTANZA e BOND, le voci
	disegno(carta, Ecg.new(), Rect2(24, 22, 384, 94))
	scritta(carta, "MORALE: 20", 25, Vector2(28, 126))
	scritta(carta, "STRESS: 0", 25, Vector2(226, 126))
	pillola(carta, "MATTANZA", Vector2(24, 176), 26, NERO, ARANCIO, 54)
	pillola(carta, "BOND", Vector2(230, 176), 26, NERO, SPENTO, 54)
	var linea := ColorRect.new()
	linea.color = NERO
	linea.position = Vector2(428, 18)
	linea.size = Vector2(4, 220)
	carta.add_child(linea)
	var voci := ["ATTACCHI", "DIFESA", "SKILL", "OGGETTI", "FUGA"]
	for i in voci.size():
		var y := 14.0 + i * 46.0
		if i == 0:
			etichetta(carta, "▶ " + voci[i], 30, Vector2(446, y - 3), CREMA)
		else:
			scritta(carta, voci[i], 30, Vector2(466, y), SPENTO if voci[i] == "OGGETTI" else NERO)


# --- i dialoghi --------------------------------------------------------------------

static func dialogo(tela: Control, come: String) -> void:
	# IL DIALOGO: l'immagine della scena dentro lo schermo del cabinato (dove
	# oggi c'e' la cornice nera), il tasto del data pad in alto a sinistra, e il
	# box in tre modi: la banda nera dell'immagine, un foglio di carta, o la
	# cornice arrotondata coi rombi - l'esempio elegante che Bru aveva mandato
	# per il box, detto nella stessa lingua
	fondo(tela)
	schermo(tela, Rect2(24, 20, 1232, 536 if come == "banda" else 516), "D")
	var tasto := disegno(tela, TastoPad.new(), Rect2(50, 46, 62, 62))
	tasto.set("tinta", ARANCIO)
	match come:
		"banda":
			var nero := ColorRect.new()
			nero.color = NERO
			nero.position = Vector2(0, 586)
			nero.size = Vector2(1280, 134)
			tela.add_child(nero)
			var riga := battuta(CREMA, 1060)
			riga.position = Vector2(84, 626)
			tela.add_child(riga)
			scritta(tela, "▼", 26, Vector2(1200, 672), ARANCIO)
			nome_sul_nastro(tela, Vector2(58, 522), ARANCIO)
		"carta":
			var foglio := pannello(tela, Rect2(44, 552, 1188, 146))
			var riga := battuta(NERO, 1040)
			riga.position = Vector2(42, 34)
			foglio.add_child(riga)
			scritta(foglio, "▼", 26, Vector2(1128, 96), NERO)
			nome_sul_nastro(tela, Vector2(70, 488), ARANCIO)
		"cornice":
			var box := disegno(tela, Cornice.new(), Rect2(44, 552, 1188, 146))
			var riga := battuta(NERO, 1030)
			riga.position = Vector2(56, 34)
			box.add_child(riga)
			nome_sul_nastro(tela, Vector2(84, 488), ARANCIO)


static func battuta(inchiostro: Color, larghezza: float) -> Label:
	var testo := Label.new()
	testo.text = "Non voglio sentire scuse signorino, la prossima volta che ti vedo ridotto così vi dovrò fare una bella lavata di capo!"
	testo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	testo.add_theme_font_override("font", Caratteri.dialoghi())
	testo.add_theme_font_size_override("font_size", Caratteri.corpo_dialoghi())
	testo.add_theme_constant_override("line_spacing", 10)
	testo.add_theme_color_override("font_color", inchiostro)
	testo.size = Vector2(larghezza, 90)
	return testo


static func nome_sul_nastro(tela: Control, dove: Vector2, tinta: Color) -> void:
	# il nastro vero del gioco (NastroStrappato), col suo carattere e il suo
	# strappo; cambia solo il colore della carta
	var nastro := MarginContainer.new()
	var scritta_nome := Label.new()
	scritta_nome.text = "Dr. Reika"
	nastro.add_child(scritta_nome)
	var carta := NastroStrappato.dentro(nastro, scritta_nome)
	carta.colore = tinta
	carta.strappa("Dr. Reika")
	nastro.position = dove
	nastro.rotation = deg_to_rad(-3.5)
	tela.add_child(nastro)


# --- la pausa ----------------------------------------------------------------------

static func pausa(tela: Control) -> void:
	# LA PAUSA, con le sue voci e i suoi gruppi: a sinistra le voci su una
	# colonna, il taglio obliquo, a destra la parola grande a scalini (oggi e'
	# cremisi su nero), i Tazo in alto e la busta dei messaggi in basso
	fondo(tela)
	var grande := LetteraGrande.new()
	grande.testo = "PAUSA"
	grande.carattere = titoli(900.0, 100.0)
	disegno(tela, grande, Rect2(640, 404, 700, 300))
	grande.rotation = deg_to_rad(-5.0)
	disegno(tela, Taglio.new(), Rect2(560, 0, 200, 720))
	etichetta(tela, "PAUSA", 60, Vector2(78, 42))
	var voci := [["RIPRENDI", 172], ["STORICO DEI DIALOGHI", 262], ["DATA PAD", 330], ["ZAINO", 398],
			["PERSONAGGIO E SQUADRA", 488], ["OPZIONI", 556], ["TORNA AL MENU PRINCIPALE", 646]]
	for voce: Array in voci:
		if voce[0] == "RIPRENDI":
			etichetta(tela, "▶ RIPRENDI", 34, Vector2(70, float(voce[1]) - 6.0), CREMA)
		else:
			scritta(tela, String(voce[0]), 32, Vector2(96, float(voce[1])))
	var tazo := pillola(tela, "TAZO 30   ·   LV 1", Vector2.ZERO, 24, NERO, CREMA, 50)
	tazo.position = Vector2(1232.0 - tazo.size.x, 52)
	disegno(tela, Busta.new(), Rect2(1162, 604, 66, 66))


# --- il menu principale ------------------------------------------------------------

static func menu(tela: Control) -> void:
	# IL MENU PRINCIPALE: il luna park vero (scripts/LunaPark.gd) coi colori
	# del tema arcade - le sagome nere sul cielo arancio - e sopra le voci come
	# etichette nere a scalini, le partite su un foglio, la banda dei tasti
	Temi.applica("arcade")
	var fondale := LunaPark.new()
	fondale.size = tela.size
	tela.add_child(fondale)
	striscia(tela, "MENU PRINCIPALE", Vector2(64, 50), 16)
	var voci := ["NUOVA PARTITA", "CARICA PARTITA", "COME SI GIOCA", "COLLEZIONI", "OPZIONI", "EXTRA", "ESCI"]
	for i in voci.size():
		var dove := Vector2(52.0 + i * 7.0, 92.0 + i * 54.0)
		if i == 0:
			etichetta(tela, "▶ " + voci[i], 34, dove, NERO, CREMA)
		else:
			etichetta(tela, voci[i], 34, dove, CREMA)
	etichetta(tela, "LE TUE PARTITE", 24, Vector2(890, 58))
	pillola(tela, "0 / 5", Vector2(1136, 60), 18, CREMA, NERO, 32)
	var foglio := pannello(tela, Rect2(900, 110, 316, 250))
	for i in 5:
		var riga := disegno(foglio, Riga.new(), Rect2(16, 18 + i * 44, 284, 36))
		riga.set("carattere", titoli(600.0, 100.0))
	banda_in_fondo(tela, [["INVIO", "Seleziona"], ["ESC", "Indietro"]])


# --- i disegni ---------------------------------------------------------------------

class Etichetta extends Control:
	# un parallelogramma nero con la scritta chiara: l'etichetta dell'immagine
	var testo := ""
	var corpo := 30
	var inchiostro := Color.WHITE
	var tinta := Color.BLACK
	var carattere: Font
	var inclina := 0.24

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func misura() -> Vector2:
		var alto := corpo * 1.34
		var largo := carattere.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
		return Vector2(largo + corpo * 0.9 + alto * inclina, alto)

	func _draw() -> void:
		var scarto := size.y * inclina
		draw_colored_polygon(PackedVector2Array([Vector2(scarto, 0), Vector2(size.x, 0),
				Vector2(size.x - scarto, size.y), Vector2(0, size.y)]), tinta)
		var base := (size.y + carattere.get_ascent(corpo) - carattere.get_descent(corpo)) * 0.5
		draw_string(carattere, Vector2(corpo * 0.45 + scarto * 0.5, base), testo,
				HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, inchiostro)


class Pillola extends Control:
	var testo := ""
	var corpo := 20
	var tinta := Color.BLACK
	var inchiostro := Color.WHITE
	var carattere: Font

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func misura(alto: float) -> Vector2:
		var h := alto if alto > 0.0 else corpo * 1.6
		return Vector2(carattere.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + h * 1.1, h)

	func _draw() -> void:
		var tondo := StyleBoxFlat.new()
		tondo.bg_color = tinta
		tondo.set_corner_radius_all(int(size.y * 0.5))
		draw_style_box(tondo, Rect2(Vector2.ZERO, size))
		var base := (size.y + carattere.get_ascent(corpo) - carattere.get_descent(corpo)) * 0.5
		draw_string(carattere, Vector2(0, base), testo, HORIZONTAL_ALIGNMENT_CENTER, size.x, corpo, inchiostro)


class Pannello extends Control:
	# la carta: ombra nera piena spostata, il grigio caldo, il contorno spesso,
	# e il retino a puntini che si addensa verso l'angolo in basso a destra
	var tinta := Color.WHITE
	var ombra := Vector2(10, 10)

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_rect(Rect2(ombra, size), NERO)
		draw_rect(Rect2(Vector2.ZERO, size), tinta)
		var passo := 9.0
		var y := size.y * 0.4
		while y < size.y - 3.0:
			var x := size.x * 0.5
			while x < size.x - 3.0:
				var quanto := clampf((x / size.x - 0.5) * 2.4 + (y / size.y - 0.4) * 2.0 - 0.9, 0.0, 1.0)
				if quanto > 0.05:
					draw_circle(Vector2(x, y), passo * 0.42 * quanto, RETINO)
				x += passo
			y += passo * 0.87
		draw_rect(Rect2(Vector2.ZERO, size), NERO, false, 5.0)


class Schermo extends Control:
	# lo schermo del cabinato: il nero dentro, la cornice chiara arrotondata, il
	# contorno nero fuori, e un velo di puntini in basso sul vetro
	var lettera := ""
	var cornice := Color.WHITE
	var carattere: Font

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var fuori := StyleBoxFlat.new()
		fuori.bg_color = NERO
		fuori.set_corner_radius_all(24)
		draw_style_box(fuori, Rect2(Vector2(8, 8), size))   # l'ombra piena
		draw_style_box(fuori, Rect2(Vector2.ZERO, size))
		var bordo := StyleBoxFlat.new()
		bordo.bg_color = cornice
		bordo.set_corner_radius_all(20)
		draw_style_box(bordo, Rect2(Vector2(5, 5), size - Vector2(10, 10)))
		var vetro := StyleBoxFlat.new()
		vetro.bg_color = VETRO
		vetro.set_corner_radius_all(14)
		vetro.border_color = NERO
		vetro.set_border_width_all(3)
		var dentro := Rect2(Vector2(18, 18), size - Vector2(36, 36))
		draw_style_box(vetro, dentro)
		var passo := 8.0
		var y := dentro.position.y + dentro.size.y * 0.55
		while y < dentro.end.y - 6.0:
			var x := dentro.position.x + 8.0
			while x < dentro.end.x - 6.0:
				var quanto := clampf((y - dentro.position.y) / dentro.size.y * 2.0 - 1.1, 0.0, 1.0)
				draw_circle(Vector2(x, y), passo * 0.3 * quanto, Color("#2a2420"))
				x += passo
			y += passo * 0.87
		if lettera != "":
			var corpo := int(minf(size.x, size.y) * 0.34)
			draw_string(carattere, Vector2(0, size.y * 0.5 + corpo * 0.36), lettera,
					HORIZONTAL_ALIGNMENT_CENTER, size.x, corpo, Color("#5e5751"))


class Barra extends Control:
	var quota := 1.0
	var tinta := Color.WHITE
	var numero := ""
	var carattere: Font

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), NERO)
		draw_rect(Rect2(Vector2(3, 3), Vector2((size.x - 6.0) * quota, size.y - 6.0)), tinta)
		if numero != "":
			draw_string(carattere, Vector2(0, size.y - 3.0), numero, HORIZONTAL_ALIGNMENT_RIGHT,
					size.x - 6.0, 12, NERO)


class Tondo extends Control:
	# un segno di stato: un tondo nero col suo pallino chiaro
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var centro := size * 0.5
		draw_circle(centro + Vector2(4, 4), size.x * 0.5, NERO)
		draw_circle(centro, size.x * 0.5, NERO)
		draw_circle(centro, size.x * 0.5 - 4.0, GRIGIO)
		draw_circle(centro, size.x * 0.18, CREMA)


class TastoPad extends Control:
	# il tasto del data pad in alto a sinistra: arrotondato, tre righe nere
	var tinta := Color.BLACK

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var tondo := StyleBoxFlat.new()
		tondo.bg_color = NERO
		tondo.set_corner_radius_all(16)
		draw_style_box(tondo, Rect2(Vector2(5, 5), size))
		tondo.bg_color = tinta
		tondo.border_color = NERO
		tondo.set_border_width_all(4)
		draw_style_box(tondo, Rect2(Vector2.ZERO, size))
		for i in 3:
			var y := size.y * (0.32 + i * 0.18)
			draw_line(Vector2(size.x * 0.27, y), Vector2(size.x * 0.73, y), NERO, 5.0)


class Busta extends Control:
	# la busta dei messaggi, in basso a destra
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var tondo := StyleBoxFlat.new()
		tondo.bg_color = NERO
		tondo.set_corner_radius_all(14)
		draw_style_box(tondo, Rect2(Vector2(5, 5), size))
		draw_style_box(tondo, Rect2(Vector2.ZERO, size))
		var foglio := Rect2(size * Vector2(0.2, 0.28), size * Vector2(0.6, 0.44))
		draw_rect(foglio, CREMA)
		draw_polyline(PackedVector2Array([foglio.position, foglio.get_center() + Vector2(0, 2),
				Vector2(foglio.end.x, foglio.position.y)]), NERO, 4.0)


class Ecg extends Control:
	# la finestra della linea che batte: nera, arrotondata, la traccia verde
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var vetro := StyleBoxFlat.new()
		vetro.bg_color = VETRO
		vetro.set_corner_radius_all(12)
		vetro.border_color = NERO
		vetro.set_border_width_all(4)
		draw_style_box(vetro, Rect2(Vector2.ZERO, size))
		var punti := PackedVector2Array()
		var mezzo := size.y * 0.55
		for i in 120:
			var x := 12.0 + (size.x - 24.0) * i / 119.0
			var fase := fmod(i, 30.0)
			var y := mezzo
			if fase == 12.0:
				y -= size.y * 0.36
			elif fase == 13.0:
				y += size.y * 0.16
			elif fase > 18.0 and fase < 24.0:
				y -= size.y * 0.08 * sin((fase - 18.0) / 6.0 * PI)
			punti.append(Vector2(x, y))
		draw_polyline(punti, Color("#3fd67a"), 2.5, true)


class Cornice extends Control:
	# il box elegante di Bru nella lingua dell'immagine: il bordo nero spesso e
	# arrotondato, un filo sottile dentro, i rombi sui due lati, l'ombra piena
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var tondo := StyleBoxFlat.new()
		tondo.bg_color = NERO
		tondo.set_corner_radius_all(26)
		draw_style_box(tondo, Rect2(Vector2(9, 9), size))
		tondo.bg_color = CREMA_CHIARA
		tondo.border_color = NERO
		tondo.set_border_width_all(6)
		draw_style_box(tondo, Rect2(Vector2.ZERO, size))
		var filo := StyleBoxFlat.new()
		filo.draw_center = false
		filo.border_color = NERO
		filo.set_border_width_all(2)
		filo.set_corner_radius_all(16)
		draw_style_box(filo, Rect2(Vector2(13, 13), size - Vector2(26, 26)))
		for x: float in [0.0, size.x]:
			rombo(Vector2(x, size.y * 0.5), 17.0)
		rombo(Vector2(size.x - 52.0, size.y - 36.0), 11.0)   # il "vai avanti"

	func rombo(centro: Vector2, r: float) -> void:
		var punte := PackedVector2Array([centro + Vector2(0, -r), centro + Vector2(r, 0),
				centro + Vector2(0, r), centro + Vector2(-r, 0)])
		draw_colored_polygon(punte, NERO)
		var dentro := PackedVector2Array()
		for p in punte:
			dentro.append(centro + (p - centro) * 0.5)
		draw_colored_polygon(dentro, ARANCIO)


class LetteraGrande extends Control:
	# la parola grande della pausa: nera, con gli scalini arancio scuro dietro
	# (oggi sono cremisi)
	var testo := ""
	var carattere: Font

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var corpo := 236
		for k in range(7, 0, -1):
			draw_string(carattere, Vector2(k * 5.0, 240.0 + k * 5.0), testo, HORIZONTAL_ALIGNMENT_LEFT,
					-1, corpo, ARANCIO_SCURO.darkened(k * 0.03))
		draw_string(carattere, Vector2(0, 240), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, NERO)


class Taglio extends Control:
	# il taglio obliquo fra le voci e la parola grande: una fascia nera e un
	# filo crema, come le righe dell'immagine
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_colored_polygon(PackedVector2Array([Vector2(150, 0), Vector2(176, 0), Vector2(26, size.y),
				Vector2(0, size.y)]), NERO)
		draw_colored_polygon(PackedVector2Array([Vector2(184, 0), Vector2(192, 0), Vector2(42, size.y),
				Vector2(34, size.y)]), CREMA)


class Riga extends Control:
	# una partita libera sul foglio: la riga tratteggiata dove andra' scritta
	var carattere: Font

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), CREMA_CHIARA)
		var x := 0.0
		while x < size.x:
			draw_line(Vector2(x, size.y - 1.0), Vector2(minf(x + 8.0, size.x), size.y - 1.0), NERO, 2.0)
			x += 14.0
		draw_string(carattere, Vector2(12, size.y * 0.5 + 7.0), "Partita libera…", HORIZONTAL_ALIGNMENT_LEFT,
				-1, 19, SPENTO)
