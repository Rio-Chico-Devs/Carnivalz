class_name VoceMacchia
extends VoceMenu

# UNA VOCE DEL MENU PRINCIPALE. Il nome viene dalla prima versione (il menu di
# Borderlands 2 che Bru aveva preso come riferimento): la voce scelta aveva
# dietro una macchia d'inchiostro. Dai bozzetti del manifesto approvati il 29
# settembre ogni voce e' un'ETICHETTA: nera con la scritta chiara, e quella
# scelta chiara con la scritta nera e l'ombra piena che si scopre sotto.
#
# L'etichetta non e' decorazione, e si vede misurando: una scritta dritta sul
# luna park cambia contrasto a ogni riga (il cielo schiarisce verso
# l'orizzonte), su un'etichetta piena no - crema sul nero 12,9:1, nero sul
# crema lo stesso, su tutte le righe.
#
# Il movimento e' quello di tutte le voci (VoceMenu, Movimento): l'etichetta
# chiara si allunga a sinistra sulla molla della forma, il colore gira sulla
# sua, il segno compare col colore. Non scivola: in un elenco lungo una voce
# che si sposta fa sembrare storto tutto l'elenco.

const CORPO := 34
# IL PASSO FRA LE VOCI E' FISSO: 40 pixel, il 5,6% dello schermo come nel
# riferimento. Non lo decide l'altezza del carattere - che fra un sistema e
# l'altro cambia, e senza finestra Godot la sbaglia del tutto (Anton risulta
# alto 93 invece di 48) - quindi l'elenco occupa sempre lo stesso spazio, e la
# prova che misura se ci sta dice il vero
const PASSO := 40.0


static func crea(testo: String, corpo := 0) -> VoceMacchia:
	var voce := VoceMacchia.new()
	voce.costruisci("riprendi", testo, corpo if corpo > 0 else CORPO)
	voce.vesti()
	return voce


func vesti() -> void:
	# SUL MANIFESTO (Bru, bozzetti approvati il 29 settembre): ogni voce e'
	# un'etichetta nera con la scritta chiara, e quella scelta un'etichetta
	# chiara con la scritta nera. Si legge su qualunque punto del luna park
	tinta_spenta = Stile.colore("testo")
	tinta_accesa = Stile.colore("box_testo")
	scivolo = 0.0
	var carattere := Caratteri.voce()
	if carattere != null:
		bottone.add_theme_font_override("font", carattere)
	for stato in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		var scatola := bottone.get_theme_stylebox(stato) as StyleBoxEmpty
		if scatola != null:
			scatola.content_margin_top = 2
			scatola.content_margin_bottom = 2
	ultima_tinta = Color(0, 0, 0, 0)
	colora(0.0)
	update_minimum_size()


func _get_minimum_size() -> Vector2:
	return Vector2(super._get_minimum_size().x, PASSO)


func colora(quanto: float) -> void:
	super.colora(quanto)
	# il segno c'e' solo sulla voce scelta, e arriva col colore
	segno.tinta = Color(Stile.colore("box_testo"), clampf(tinta.valore * entrata, 0.0, 1.0))
	segno.queue_redraw()


func colore_del_lampo() -> Color:
	# premuta, la scritta diventa arancio per un istante
	return Stile.colore("manifesto")


func _draw() -> void:
	# L'ETICHETTA: nera da spenta, chiara da scelta, e la sfoglia nera sotto
	# che si scopre quando la voce si accende (l'ombra piena del manifesto)
	var quanto := clampf(accesa.valore * entrata, 0.0, 1.0)
	if lampo > 0.0:
		quanto = 1.0
	var h := bottone.size.y
	var alto := bottone.position.y
	var destra := bottone.position.x + bottone.size.x
	var sinistra := bottone.position.x + SPAZIO_SEGNO * (1.0 - quanto) - 10.0
	var nero := Stile.colore("bordo")
	var ombra := Vector2(5, 4) * quanto
	Manifesto.poligono(self, VoceMenu.lastra(sinistra + ombra.x, destra + ombra.x, alto + ombra.y, h),
			Color(nero, entrata))
	var fondo := nero.lerp(Stile.colore("bordo_acceso"), clampf(tinta.valore, 0.0, 1.0))
	Manifesto.poligono(self, VoceMenu.lastra(sinistra, destra, alto, h), Color(fondo, entrata))


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
