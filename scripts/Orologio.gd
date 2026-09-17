extends Control

# L'OROLOGIO DA TASCHINO DI UNA SCELTA A TEMPO.
#
# Bru: «quelle eroe e villain sono a tempo, manchi timing non recuperi». Nel suo
# disegno sono due cipolle appese storte a sinistra del riquadro nero, una per
# opzione.
#
# Quello che fa e' una cosa sola: contare alla rovescia e dire quando e' finita.
# Non sa cosa sia la scelta a cui e' attaccato, non la toglie di mezzo, non
# decide niente - se ne occupa chi l'ha appeso li'. Cosi' si puo' provare da
# solo, e soprattutto si puo' mettere anche altrove (una porta che si chiude, un
# boss che carica) senza portarsi dietro i dialoghi.
#
# SI FERMA CON LA PAUSA, e non per gentilezza: senza, aprire l'inventario per
# controllare se hai l'oggetto giusto ti farebbe perdere la scelta mentre
# guardi. Il nodo eredita il modo di processo dall'albero, quindi quando la
# Pausa ferma l'albero si ferma anche lui - non c'e' niente da ricordarsi.

signal scaduto

const LATO := 74
const PERCORSO_DISEGNO := "res://art/interfaccia/orologio.png"
# Sotto questa frazione la lancetta diventa rossa e suona l'allarme: sono la
# stessa cosa detta in due modi, e vanno cambiate insieme.
const QUOTA_ALLARME := 0.25

var durata := 6.0
var rimasto := 0.0
var acceso := false
var disegno: Texture2D = null

func _ready() -> void:
	custom_minimum_size = Vector2(LATO, LATO)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot_offset = Vector2(LATO, LATO) * 0.5
	# una volta sola al disco, come dappertutto: di orologi ne compaiono due per
	# scelta a tempo, e il file e' sempre lo stesso
	disegno = Disegni.texture(PERCORSO_DISEGNO)
	set_process(false)

func avvia(secondi: float, inclinazione_gradi: float) -> void:
	durata = maxf(secondi, 0.1)
	rimasto = durata
	acceso = true
	rotation = deg_to_rad(inclinazione_gradi)
	set_process(true)
	queue_redraw()

func ferma() -> void:
	acceso = false
	set_process(false)

func quota_rimasta() -> float:
	return clampf(rimasto / durata, 0.0, 1.0) if durata > 0.0 else 0.0

func _process(delta: float) -> void:
	if not acceso:
		return
	var quota_prima := quota_rimasta()
	rimasto -= delta
	if rimasto <= 0.0:
		rimasto = 0.0
		ferma()
		scaduto.emit()
		return
	# L'ULTIMO QUARTO SI SENTE, e suona una volta sola.
	#
	# NIENTE TICCHETTIO A OGNI SECONDO, che sarebbe la scelta ovvia: sullo
	# schermo possono esserci due orologi insieme (l'opzione da eroe e quella da
	# villain), partiti in momenti diversi e con durate diverse. Due ticchettii
	# sfasati non fanno tensione, fanno rumore - e non si capirebbe nemmeno
	# quale dei due sta per scadere. Un colpo solo, quando la lancetta diventa
	# rossa, dice la stessa cosa senza sovrapporsi a niente.
	if quota_prima > QUOTA_ALLARME and quota_rimasta() <= QUOTA_ALLARME:
		AudioManager.interfaccia("allarme")
	queue_redraw()

func _draw() -> void:
	var centro := Vector2(LATO, LATO) * 0.5
	var raggio := LATO * 0.40
	if disegno != null:
		draw_texture_rect(disegno, Rect2(Vector2.ZERO, Vector2(LATO, LATO)), false)
	else:
		# LA CIPOLLA, finche' il disegno vero non c'e'. Quadrante bianco, cassa
		# nera, e l'anellino sopra: bastano tre primitive perche' si capisca che
		# e' un orologio e non un pallino.
		draw_circle(centro, raggio, Stile.colore("box_fondo"))
		draw_arc(centro, raggio, 0.0, TAU, 48, Stile.colore("bordo"), 4.0, true)
		draw_arc(centro + Vector2(0, -raggio - 5), 5.0, 0.0, TAU, 16, Stile.colore("bordo"), 4.0, true)
		for ora in 12:
			var verso := Vector2.UP.rotated(TAU * float(ora) / 12.0)
			draw_line(centro + verso * (raggio * 0.78), centro + verso * (raggio * 0.92),
					Stile.colore("bordo"), 2.0)
	# LA LANCETTA E' IL TEMPO CHE RESTA, e gira in senso orario partendo dall'alto
	# come qualunque orologio: se girasse al contrario si leggerebbe benissimo
	# lo stesso, e non sarebbe un orologio.
	var quota := quota_rimasta()
	var angolo := TAU * (1.0 - quota)
	var lancetta := Vector2.UP.rotated(angolo) * (raggio * 0.82)
	# rossa sull'ultimo quarto: e' l'unico avviso che si e' quasi senza tempo
	var tinta := Stile.colore("pericolo") if quota <= QUOTA_ALLARME else Stile.colore("bordo")
	draw_line(centro, centro + lancetta, tinta, 5.0)
	# E LA FETTA GIA' PERSA, in trasparenza: il colpo d'occhio vale piu' della
	# lancetta.
	#
	# L'ARCO NON ARRIVA MAI AL GIRO INTERO. Quando il tempo finisce la quota e'
	# zero e l'angolo e' TAU: l'ultimo punto dell'arco torna esattamente sul
	# primo, e un poligono che si chiude su se stesso non si puo' tagliare in
	# triangoli. Godot lo diceva - "Invalid polygon data, triangulation failed" -
	# e con una scelta a tempo a schermo la console si riempiva, tanto che un
	# errore vero ci sarebbe finito in mezzo senza farsi notare.
	#
	# Un centesimo di radiante in meno e il cerchio resta aperto di un capello
	# che nessuno vede. (Cercato per esclusione: ne' una soglia sull'angolo
	# minimo ne' un punto in piu' sull'arco cambiavano niente - era solo questo.)
	if quota < 1.0:
		var punti := PackedVector2Array([centro])
		var passi := maxi(int(48.0 * (1.0 - quota)), 1)
		var spicchio := minf(angolo, TAU - 0.01)
		for i in passi + 1:
			punti.append(centro + Vector2.UP.rotated(spicchio * float(i) / float(passi)) * raggio)
		draw_colored_polygon(punti, Color(Stile.colore("pericolo"), 0.22))
