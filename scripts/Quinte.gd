class_name Quinte
extends Control

# LE QUINTE DI UN MENU: quello che sta dietro le voci, a strati.
#
# Davanti al mondo sfocato si posano, uno sull'altro, tre fogli tagliati in
# obliquo - bianco, cremisi, nero - come carta ritagliata e incollata: il nero
# e' il piano su cui stanno le voci, il cremisi e il bianco sporgono dal suo
# bordo. E' il linguaggio del disegno di Bru (nero pieno, bordi spessi, il
# rosso dove conta) messo in piedi come una scenografia.
#
# Dietro, grande e vuota, c'e' la PAROLA del pannello - PAUSA, DIARIO, ZAINO -
# ripetuta quattro volte, ogni copia un po' piu' in fondo della precedente.
#
# LA PARALLASSE, E IL FINTO 3D CHE NE ESCE. Muovendo il mouse gli strati si
# spostano di quantita' diverse: piu' uno strato e' lontano, piu' si sposta
# (le voci, che sono il piano di riferimento, stanno ferme - un bersaglio che
# scappa sotto il puntatore e' un bersaglio che si manca). Le quattro copie
# della parola stanno a quattro profondita' diverse, quindi quando il mouse si
# muove non scorrono insieme: si aprono e si chiudono come le facce di una
# lettera scolpita. E' un'estrusione vera, ricavata dalla parallasse, senza
# una riga di 3D. In Hollow Knight i piani disegnati stanno su un vero asse Z
# di una camera prospettica; qui una camera non c'e', e la profondita' si
# scrive a mano: (posizione del mouse - centro) x profondita', su una molla.
#
# ENTRATA: i tre fogli arrivano da sinistra uno dopo l'altro - il nero per
# primo, poi il cremisi e il bianco che scattano fuori dal suo bordo. USCITA:
# se ne vanno insieme, e piu' in fretta.
#
# Con il movimento ridotto non c'e' parallasse e i fogli non corrono: ci sono.

const TAGLIO_BORDO := 0.18        # l'obliquo del bordo: quanto si sposta in tutta l'altezza
const FOGLI := [
	# colore, di quanto sporge dal nero, quanto arriva dopo, profondita'
	["bordo_acceso", 26.0, 0.08, 0.40],
	["accento", 14.0, 0.04, 0.34],
	["sfondo", 0.0, 0.0, 0.28],
]
# LA PAROLA E' CARTA A STRATI, non un contorno: la copia davanti e' nera col
# filo cremisi, quelle dietro sono piene, sempre piu' scure - i fogli di una
# scritta ritagliata e impilata. Da ferma sembra spessa; col mouse le copie si
# spostano di quantita' diverse e lo spessore gira
const COPIE_PAROLA := 5
const SCURO_COPIE := [0.0, 0.62, 0.48, 0.36, 0.26]   # quanto cremisi c'e' in ogni copia (0 = nero)
const ALFA_PAROLA := 0.85
const PASSO_COPIE := Vector2(6, 6)    # quanto sta dietro ogni copia, da fermo
const QUOTA_CORPO_PAROLA := 0.36      # il corpo della parola, in altezze di schermo
const OLTRE := 48.0                    # i fogli sbordano: la parallasse non deve scoprire il margine

var parola := ""
var quota: Movimento.Molla            # quanta parte dello schermo copre il foglio nero
var mira_x: Movimento.Molla
var mira_y: Movimento.Molla
var alfa_parola: Movimento.Molla
var font: Font
var orologio := -1.0
var uscendo := false
var puntatore_finto := Vector2(-1.0, -1.0)   # le prove muovono il mouse da qui


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	quota = Movimento.molla("quinte", 0.5)
	mira_x = Movimento.molla("quinte")
	mira_y = Movimento.molla("quinte")
	alfa_parola = Movimento.molla("colore")
	font = Stile.font_da("titolo")
	set_process(false)


func carattere() -> Font:
	return font if font != null else get_theme_default_font()


func entra(quanto_copre: float, scritta: String) -> void:
	uscendo = false
	orologio = 0.0
	quota.salta_a(quanto_copre)
	mira_x.salta_a(0.0)
	mira_y.salta_a(0.0)
	mostra_parola(scritta)
	set_process(true)
	queue_redraw()


func copri(quanto_copre: float, scritta: String) -> void:
	# da un pannello all'altro: il foglio nero si allarga o si stringe (su una
	# molla lenta: e' la scenografia che si sposta, non una voce che si accende)
	quota.obiettivo = quanto_copre
	if Movimento.ridotto():
		quota.salta_a(quanto_copre)
	if scritta != parola:
		mostra_parola(scritta)
	set_process(true)


func mostra_parola(scritta: String) -> void:
	parola = scritta
	alfa_parola.salta_a(0.0)
	alfa_parola.obiettivo = 1.0
	if Movimento.ridotto():
		alfa_parola.salta_a(1.0)


func esci() -> void:
	uscendo = true
	orologio = 0.0
	set_process(true)


func _process(delta: float) -> void:
	avanza(delta)


func avanza(dt: float) -> void:
	if orologio >= 0.0:
		orologio += dt
		var fine := Movimento.durata("uscita") if uscendo else Movimento.durata("entrata") + 0.08
		if orologio >= fine:
			orologio = -1.0
	quota.passo(dt)
	var mira := dove_mira()
	mira_x.obiettivo = mira.x
	mira_y.obiettivo = mira.y
	mira_x.passo(dt)
	mira_y.passo(dt)
	alfa_parola.passo(dt)
	queue_redraw()
	set_process(is_visible_in_tree() and (orologio >= 0.0 or not fermo()))


func fermo() -> bool:
	return quota.ferma() and mira_x.ferma() and mira_y.ferma() and alfa_parola.ferma()


func dove_mira() -> Vector2:
	# dove guarda il giocatore, da -1 a 1 su ogni asse. Col movimento ridotto
	# sempre al centro: la parallasse e' movimento e basta, non dice niente
	if Movimento.ridotto() or size.x <= 0.0 or size.y <= 0.0:
		return Vector2.ZERO
	var dove := puntatore_finto
	if dove.x < 0.0:
		dove = get_local_mouse_position()
	var mezzo := size * 0.5
	return ((dove - mezzo) / mezzo).clamp(Vector2(-1, -1), Vector2(1, 1))


func _input(evento: InputEvent) -> void:
	# il mouse che si muove sveglia la parallasse; da ferma non costa niente
	if evento is InputEventMouseMotion and is_visible_in_tree() and not is_processing():
		set_process(true)


# --- quanto e' arrivato ogni foglio ---------------------------------------------

func arrivo(dopo: float) -> float:
	# 0 = fuori a sinistra, 1 = al suo posto
	if Movimento.ridotto() or orologio < 0.0:
		return 0.0 if uscendo else 1.0
	if uscendo:
		return 1.0 - Movimento.curva("uscita", orologio / Movimento.durata("uscita"))
	return Movimento.curva("entrata", (orologio - dopo) / Movimento.durata("entrata"))


func spostamento(profondita: float) -> Vector2:
	return Vector2(mira_x.valore, mira_y.valore) * Movimento.misura("parallasse") * profondita


# --- il disegno ---------------------------------------------------------------------

func _draw() -> void:
	if size.x <= 0.0:
		return
	# la parola sta DIETRO i fogli: e' il fondale, e dove c'e' il foglio nero
	# ci sono le voci da leggere
	disegna_parola()
	for foglio in FOGLI:
		var quanto := arrivo(float(foglio[2]))
		var fuori := -(size.x * quota.valore + OLTRE * 4.0) * (1.0 - quanto)
		var dove := spostamento(float(foglio[3])) + Vector2(fuori, 0.0)
		draw_colored_polygon(foglio_nero(float(foglio[1]), dove), Stile.colore(String(foglio[0])))


func foglio_nero(sporge: float, dove: Vector2) -> PackedVector2Array:
	# il foglio va da fuori a sinistra fino al bordo obliquo, e sborda sopra e
	# sotto: e' cosi' che la parallasse non scopre mai un angolo
	var alto := -OLTRE
	var basso := size.y + OLTRE
	return PackedVector2Array([
		Vector2(-OLTRE * 4.0, alto) + dove, Vector2(bordo(alto) + sporge, alto) + dove,
		Vector2(bordo(basso) + sporge, basso) + dove, Vector2(-OLTRE * 4.0, basso) + dove])


func bordo(y: float) -> float:
	# dove sta il bordo obliquo a quest'altezza: piu' a destra in alto, piu' a
	# sinistra in basso, come il taglio dei lati delle lastre
	var obliquo := TAGLIO_BORDO * size.y
	return size.x * quota.valore + obliquo * (0.5 - y / size.y)


func disegna_parola() -> void:
	var f := carattere()
	if parola == "" or f == null:
		return
	var corpo := int(size.y * QUOTA_CORPO_PAROLA)
	var larga := f.get_string_size(parola, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
	var base := Vector2(size.x - larga + OLTRE * 0.5, size.y * 0.93)
	var arrivata := arrivo(0.06)
	var alfa := ALFA_PAROLA * alfa_parola.valore * arrivata
	var tinta := Stile.colore("accento")
	var nero := Stile.colore("sfondo")
	var spessore := maxi(3, int(float(corpo) * 0.014))
	for i in range(COPIE_PAROLA - 1, -1, -1):
		# la copia piu' in fondo per prima: quella davanti le passa sopra
		var profondita := 1.0 + float(i) * 0.3
		var dove := base + PASSO_COPIE * float(i) + spostamento(profondita) \
				+ Vector2(OLTRE * 2.0 * (1.0 - arrivata), 0.0)
		draw_set_transform(dove, Stile.angolo("inclinazione_nastro"))
		var pieno := nero.lerp(tinta, float(SCURO_COPIE[i]))
		draw_string(f, Vector2.ZERO, parola, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Color(pieno, alfa))
		if i == 0:
			draw_string_outline(f, Vector2.ZERO, parola, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo,
					spessore, Color(tinta, alfa))
	draw_set_transform(Vector2.ZERO)
