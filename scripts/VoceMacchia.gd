class_name VoceMacchia
extends VoceMenu

# UNA VOCE DEL MENU PRINCIPALE, com'e' fatta nel riferimento di Bru (il menu
# di Borderlands 2): nessuna lastra, nessun riquadro. La voce spenta e' una
# scritta maiuscola, condensata, blu notte smorzato col contorno scuro; quella
# scelta diventa dell'unico colore caldo della schermata, prende il segno a
# sinistra e ha dietro una MACCHIA D'INCHIOSTRO quasi nera, con gli schizzi.
#
# La macchia non e' decorazione, e si vede misurando: il cremisi dritto sul
# luna park sta fra 2,6 e 3,5:1 a seconda della riga - sotto il 3:1 del testo
# grande proprio nelle righe in basso; sulla macchia sta a 4,3:1 su tutte. E'
# lei a dare al colore scelto il contrasto che il colore da solo non ha - come
# il nero dietro il giallo, nel riferimento. (La prima versione di questo
# commento diceva 4,6: era il conto col nero puro e pieno. La macchia e' quasi
# nera e al 90%, e il conto giusto l'ha fatto la prova.)
#
# Il movimento e' quello di tutte le voci (VoceMenu, Movimento): la macchia si
# spande da sinistra sulla molla della forma, il colore gira sulla sua, il
# segno compare col colore. Non scivola: nel riferimento la voce scelta resta
# esattamente dov'era, ed e' giusto - in un elenco lungo, una voce che si sposta
# fa sembrare storto tutto l'elenco.

const CORPO := 31
const PUNTI := 28
const SPORGE_MACCHIA := 34.0         # la macchia comincia a sinistra del segno
const QUOTA_TESTO_COPERTO := 0.72    # e copre il segno e quasi tre quarti della scritta
const OPACITA_MACCHIA := 0.9

var forma: PackedVector2Array = PackedVector2Array()   # in frazioni: x 0..1, y -0.5..0.5
var schizzi: Array[Vector3] = []                      # x, y (frazioni), raggio (pixel)


static func crea(testo: String, corpo := 0) -> VoceMacchia:
	var voce := VoceMacchia.new()
	voce.costruisci("emblema", testo, corpo if corpo > 0 else CORPO)
	voce.vesti()
	return voce


func vesti() -> void:
	tinta_spenta = Stile.colore("menu_voce")
	tinta_accesa = Stile.colore("accento")
	scivolo = 0.0
	var carattere := Caratteri.voce()
	if carattere != null:
		bottone.add_theme_font_override("font", carattere)
	for stato in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		var scatola := bottone.get_theme_stylebox(stato) as StyleBoxEmpty
		if scatola != null:
			scatola.content_margin_top = 2
			scatola.content_margin_bottom = 2
	Stile.contorno(bottone, bottone.get_theme_font_size("font_size"))
	ultima_tinta = Color(0, 0, 0, 0)
	colora(0.0)
	var seme := absi(hash(bottone.text))
	forma = macchia(seme, PUNTI)
	schizzi = spruzzi(seme, 7)
	update_minimum_size()


func colora(quanto: float) -> void:
	super.colora(quanto)
	# il segno c'e' solo sulla voce scelta, e arriva col colore
	segno.tinta = Color(Stile.colore("accento"), clampf(tinta.valore * entrata, 0.0, 1.0))
	segno.queue_redraw()


func colore_del_lampo() -> Color:
	# premuta, la scritta diventa bianca per un istante: sulla macchia nera si vede
	return Stile.colore("testo")


func _draw() -> void:
	var quanto := clampf(accesa.valore * entrata, 0.0, 1.0)
	if quanto <= 0.002 and lampo <= 0.0:
		return
	if lampo > 0.0:
		quanto = 1.0
	var h := bottone.size.y
	var centro_y := bottone.position.y + h * 0.5
	var testo := maxf(bottone.size.x - SPAZIO_SEGNO - MARGINE_DESTRO, 0.0)
	var larga := SPORGE_MACCHIA + SPAZIO_SEGNO + testo * QUOTA_TESTO_COPERTO
	var nero := Stile.colore("menu_macchia")
	var punti := PackedVector2Array()
	for p in forma:
		# si spande da sinistra: la x si allunga con la molla, la y no
		punti.append(Vector2(-SPORGE_MACCHIA + p.x * larga * quanto, centro_y + p.y * h * 1.45))
	draw_colored_polygon(punti, Color(nero, OPACITA_MACCHIA * quanto))
	# gli schizzi arrivano per ultimi, quando la macchia e' quasi tutta fuori
	var schizzo := clampf((quanto - 0.6) / 0.4, 0.0, 1.0)
	for s in schizzi:
		draw_circle(Vector2(-SPORGE_MACCHIA + s.x * larga, centro_y + s.y * h), s.z, Color(nero, 0.85 * schizzo))


static func macchia(seme: int, quanti: int) -> PackedVector2Array:
	# UNA PENNELLATA D'INCHIOSTRO, sempre la stessa per la stessa voce (il seme
	# e' la scritta): larga e sfrangiata a sinistra, dove batte il pennello, che
	# si assottiglia verso destra. E' un'ellisse deformata attorno al suo
	# centro, quindi il poligono non si incrocia mai - e si puo' riempire.
	var dado := RandomNumberGenerator.new()
	dado.seed = seme
	var punti := PackedVector2Array()
	for i in quanti:
		var angolo := TAU * float(i) / float(quanti)
		var x := 0.5 + 0.5 * cos(angolo)
		var raggio := 1.0 + dado.randf_range(-0.1, 0.1)
		# a sinistra le frange: un punto su tre sporge
		if cos(angolo) < -0.2 and i % 3 == 0:
			raggio += dado.randf_range(0.15, 0.45)
		var spessore := lerpf(1.0, 0.45, x)
		punti.append(Vector2(0.5 + 0.5 * cos(angolo) * raggio, 0.5 * sin(angolo) * raggio * spessore))
	return punti


static func spruzzi(seme: int, quanti: int) -> Array[Vector3]:
	var dado := RandomNumberGenerator.new()
	dado.seed = seme + 1
	var elenco: Array[Vector3] = []
	for i in quanti:
		# attorno alla testa della pennellata, piu' fitti a sinistra
		elenco.append(Vector3(dado.randf_range(-0.12, 0.3), dado.randf_range(-0.75, 0.75),
				dado.randf_range(1.2, 3.4)))
	return elenco
