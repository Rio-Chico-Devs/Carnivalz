class_name Lastra
extends Control

# LA LASTRA: il box dei dialoghi come le etichette nere della pausa.
#
# Bru, sui bozzetti del primo ottobre: «la prima direzione e' fantastica, ci
# stiamo dirigendo verso la parte giusta! approvato la prima». La prima era la
# lastra: un parallelogramma nero che pende come le etichette del manifesto
# (Manifesto.INCLINA), l'ombra piena arancio scuro che gli sta dietro, il filo
# chiaro accanto al lato obliquo come la diagonale della pausa, e un retino
# scuro che si addensa verso il lato opposto.
#
# Qui c'e' solo il fondo: il testo e' quello del box (BoxTesto), che le sta
# davanti. Il resto della lingua della lastra sta pure qui, perche' e' una
# cosa sola: le scelte oblique (vesti_scelta) e il segno per andare avanti.
#
# CHI RISPONDE STA DALL'ALTRA PARTE: quando parli tu la lastra pende al
# contrario (inclina negativa), e il filo passa sull'altro lato. La
# NARRAZIONE e' carta: la voce che racconta non e' nessuno nella stanza.

const FILO := 6.0             # quanto e' largo il filo chiaro
const STACCO_FILO := 10.0     # quanto sta lontano dal nero
const OMBRA := Vector2(10, 10)
const LARGO_RETINO := 420.0   # il retino si addensa su questo tratto
const PASSO_RETINO := 9.0
const PUNTINO := 3.4          # il raggio dei puntini piu' grossi
const OMBRA_SCELTA := Vector2(6, 6)
const RIGHE_DI_SCALINO := 62.0   # le scelte scendono lungo la pendenza: tanto per scelta
# Oltre queste lettere una scelta smette di stringersi sul testo e prende tutta
# la colonna andando a capo. Trenta e' il punto in cui una scritta smette di
# essere un'etichetta e diventa una frase.
const LETTERE_SCELTA_CORTA := 30
const ARRIVO_SCELTA := 40.0   # da quanto piu' a destra arriva una scelta entrando

# >0 pende a destra (chi parla), <0 a sinistra (tu). Si anima: la lastra che si gira
var inclina := Manifesto.INCLINA:
	set(nuova):
		inclina = nuova
		queue_redraw()
var di_carta := false:
	set(nuova):
		di_carta = nuova
		queue_redraw()
# quanto e' staccata l'ombra, da 0 a 1: entrando arriva un attimo dopo la lastra
var ombra := 1.0:
	set(nuova):
		ombra = nuova
		queue_redraw()
# i due rombi arancio ai lati dell'avviso del gioco, come il «premi un tasto»
# della copertina: dove stanno, nelle coordinate della lastra (vuoto: niente)
var rombi := PackedVector2Array():
	set(nuovi):
		rombi = nuovi
		queue_redraw()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _ready() -> void:
	show_behind_parent = true


func tutto() -> Rect2:
	# vive dentro un PanelContainer, che lo stira sul posto del contenuto: la
	# lastra intera, per lei, comincia a -position
	var su := get_parent_control()
	return Rect2(-position, su.size if su != null else size)


func _draw() -> void:
	var r := tutto()
	var forma := Lastra.parallelogramma(r, inclina)
	var a_sinistra := inclina >= 0.0
	# il filo dalla parte che pende
	var lato := [forma[0], forma[3]] if a_sinistra else [forma[1], forma[2]]
	var verso := -1.0 if a_sinistra else 1.0
	var vicino := STACCO_FILO * verso
	var lontano := (STACCO_FILO + FILO) * verso
	Manifesto.poligono(self, PackedVector2Array([Vector2(lato[0]) + Vector2(lontano, 0),
			Vector2(lato[0]) + Vector2(vicino, 0), Vector2(lato[1]) + Vector2(vicino, 0),
			Vector2(lato[1]) + Vector2(lontano, 0)]),
			Stile.colore("bordo") if di_carta else Stile.colore("bordo_acceso"))
	Manifesto.poligono(self, Lastra.sposta(forma, OMBRA * ombra), Stile.colore("manifesto_scuro"))
	Manifesto.poligono(self, forma, Stile.colore("box_fondo") if di_carta else Stile.colore("bordo"))
	retino(forma, r, a_sinistra)
	for centro in rombi:
		Manifesto.poligono(self, PackedVector2Array([centro + Vector2(0, -7), centro + Vector2(7, 0),
				centro + Vector2(0, 7), centro + Vector2(-7, 0)]), Stile.colore("manifesto"))


func retino(forma: PackedVector2Array, r: Rect2, verso_destra: bool) -> void:
	# il retino che si addensa verso il lato che non pende, dentro la lastra e
	# lontano dai bordi
	var centri: Array[Vector2] = []
	var raggi: Array[float] = []
	var da := r.end.x - LARGO_RETINO if verso_destra else r.position.x
	var stretta_a := Lastra.sposta(forma, Vector2(-6, 0))
	var stretta_b := Lastra.sposta(forma, Vector2(6, 0))
	var y := r.position.y + 8.0
	var riga := 0
	while y < r.end.y - 4.0:
		var x := da + (PASSO_RETINO * 0.5 if riga % 2 == 1 else 0.0)
		while x < da + LARGO_RETINO:
			var quanto := (x - da) / LARGO_RETINO
			var raggio := PUNTINO * clampf(quanto if verso_destra else 1.0 - quanto, 0.0, 1.0)
			var p := Vector2(x, y)
			if raggio > 0.6 and Geometry2D.is_point_in_polygon(p, stretta_a) \
					and Geometry2D.is_point_in_polygon(p, stretta_b):
				centri.append(p)
				raggi.append(raggio)
			x += PASSO_RETINO
		y += PASSO_RETINO * 0.866
		riga += 1
	Manifesto.puntini(self, centri, raggi,
			Stile.colore("retino") if di_carta else Stile.colore("pannello_chiaro"))


static func parallelogramma(r: Rect2, pendenza: float) -> PackedVector2Array:
	# pendenza > 0: il lato di sopra spostato a destra, come lo skew delle etichette
	var s := r.size.y * absf(pendenza)
	if pendenza >= 0.0:
		return PackedVector2Array([r.position + Vector2(s, 0), Vector2(r.end.x, r.position.y),
				r.end - Vector2(s, 0), Vector2(r.position.x, r.end.y)])
	return PackedVector2Array([r.position, Vector2(r.end.x - s, r.position.y),
			r.end, Vector2(r.position.x + s, r.end.y)])


static func sposta(punti: PackedVector2Array, di: Vector2) -> PackedVector2Array:
	var nuovi := PackedVector2Array()
	for p in punti:
		nuovi.append(p + di)
	return nuovi


# --- le scelte ---------------------------------------------------------------

static func vesti_scelta(bottone: Button, genere := "") -> void:
	# LE SCELTE SONO ETICHETTE OBLIQUE, chiare, con l'ombra arancio scuro; quella
	# accesa (col fuoco o col mouse sopra) diventa arancio e ha il triangolo
	# davanti. Il colore dice dove sei, il triangolo lo dice anche a chi i
	# colori non li distingue.
	#
	# Eroe e villain hanno la loro fascia sul lato obliquo: blu e rosso, i
	# colori di Bru. La scritta resta nera, perche' deve leggersi.
	bottone.flat = false
	bottone.focus_mode = Control.FOCUS_ALL
	bottone.alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottone.clip_text = false
	# accanto all'orologio di una scelta a tempo resta alta quanto la sua scritta
	bottone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if bottone.text.length() > LETTERE_SCELTA_CORTA:
		bottone.size_flags_horizontal = Control.SIZE_FILL
		bottone.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		bottone.size_flags_horizontal = Control.SIZE_SHRINK_END
		bottone.autowrap_mode = TextServer.AUTOWRAP_OFF
	if Caratteri.dialoghi() != null:
		bottone.add_theme_font_override("font", Caratteri.dialoghi())
	bottone.add_theme_font_size_override("font_size", Stile.dimensione("piccolo") + 2)
	bottone.add_theme_constant_override("h_separation", 12)
	bottone.add_theme_constant_override("icon_max_width", 14)
	bottone.set_meta("genere_scelta", genere)
	var spenta := fondo_scelta(Stile.colore("bordo_acceso"), genere)
	var accesa := fondo_scelta(Stile.colore("manifesto"), genere)
	bottone.add_theme_stylebox_override("normal", spenta)
	bottone.add_theme_stylebox_override("disabled", spenta)
	for stato in ["hover", "pressed", "hover_pressed"]:
		bottone.add_theme_stylebox_override(stato, accesa)
	# il fuoco e' gia' il fondo arancio: niente riquadro disegnato sopra
	bottone.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for chiave in Foglio.COLORI_SCRITTA:
		bottone.add_theme_color_override(chiave, Stile.colore("box_testo"))
	for chiave in ["icon_normal_color", "icon_focus_color", "icon_hover_color",
			"icon_pressed_color", "icon_hover_pressed_color"]:
		bottone.add_theme_color_override(chiave, Stile.colore("box_testo"))
	var accendi := func() -> void: Lastra.accendi_scelta(bottone)
	bottone.focus_entered.connect(accendi)
	bottone.focus_exited.connect(accendi)
	bottone.mouse_entered.connect(accendi)
	bottone.mouse_exited.connect(accendi)
	accendi_scelta(bottone)


static func fondo_scelta(tinta: Color, genere: String) -> StyleBoxFlat:
	var fondo := Manifesto.stile_etichetta(tinta, 26.0, 9.0)
	fondo.content_margin_left = 34.0
	fondo.content_margin_right = 30.0
	fondo.shadow_color = Stile.colore("manifesto_scuro")
	fondo.shadow_size = 1   # quasi senza sfumatura: l'ombra piena del manifesto
	fondo.shadow_offset = OMBRA_SCELTA
	if genere == "eroe" or genere == "malvagio":
		fondo.border_color = Stile.colore_scelta(genere)
		fondo.border_width_left = 8
	return fondo


static func accendi_scelta(bottone: Button) -> void:
	# accesa = col fuoco o col mouse sopra: e allora ha il triangolo davanti
	if not is_instance_valid(bottone):
		return
	var accesa := bottone.has_focus() or bottone.is_hovered()
	bottone.set_meta("scelta_accesa", accesa)
	bottone.icon = Manifesto.freccia() if accesa else null
	bottone.add_theme_stylebox_override("normal", fondo_scelta(
			Stile.colore("manifesto") if accesa else Stile.colore("bordo_acceso"),
			String(bottone.get_meta("genere_scelta", ""))))


static func ritingi_scelta(bottone: Button) -> void:
	# una scelta segnata come posto nuovo o gia' visto ha i colori del vetro
	# scuro (Stile.segna_visita): sull'etichetta chiara diventano quelli della
	# carta, e accesa - sull'arancio - torna nera
	for chiave in ["font_color", "font_disabled_color"]:
		bottone.add_theme_color_override(chiave, Foglio.su_carta(bottone.get_theme_color(chiave)))
	for chiave in ["font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		bottone.add_theme_color_override(chiave, Stile.colore("box_testo"))


static func in_colonna(colonna: Container, nodo: Control) -> void:
	# LE SCELTE SCENDONO LUNGO LA PENDENZA DELLA LASTRA: ognuna rientra un po'
	# piu' della precedente, cosi' la colonna pende come le etichette. Una
	# frase lunga va a capo e prende la colonna: il gradino con lei, o la
	# scritta andrebbe a capo a ogni lettera
	var gradino := MarginContainer.new()
	gradino.size_flags_horizontal = nodo.size_flags_horizontal
	gradino.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rientro := roundi(scalino(colonna.get_child_count()))
	gradino.set_meta("rientro", rientro)
	gradino.add_theme_constant_override("margin_right", rientro)
	gradino.add_child(nodo)
	colonna.add_child(gradino)
	in_cascata(gradino, colonna.get_child_count() - 1)


static func in_cascata(gradino: MarginContainer, k: int) -> void:
	# LE SCELTE ARRIVANO UNA DOPO L'ALTRA, lungo la stessa pendenza: da destra,
	# dissolvendosi dentro, a un passo di cascata l'una dall'altra (i tempi
	# del vocabolario del movimento, come le voci dei menu)
	if Movimento.ridotto():
		return
	var rientro := int(gradino.get_meta("rientro", 0))
	var durata := Movimento.durata("entrata")
	var ritardo := float(k) * float((Movimento.dati().get("cascata", {}) as Dictionary).get("passo", 0.03))
	gradino.modulate.a = 0.0
	gradino.add_theme_constant_override("margin_right", rientro - roundi(ARRIVO_SCELTA))
	var arrivo := gradino.create_tween().set_parallel()
	Movimento.verso(arrivo, gradino, "modulate:a", 1.0, "entrata", durata).set_delay(ritardo)
	Movimento.verso(arrivo, gradino, "theme_override_constants/margin_right", rientro, "entrata", durata) \
			.set_delay(ritardo)


static func fuori_dalla_colonna(nodo: Control, colonna: Container) -> void:
	# via una scelta, col suo gradino: un gradino vuoto terrebbe il posto per niente
	var su := nodo.get_parent()
	nodo.queue_free()
	if su is MarginContainer and su.get_parent() == colonna:
		su.queue_free()


static func scalino(k: int) -> float:
	# di quanto rientra la scelta numero k, perche' la colonna segua la pendenza
	return float(k) * RIGHE_DI_SCALINO * Manifesto.INCLINA
