class_name SegniMappa
extends RefCounted

# I SEGNI CHE STANNO SOPRA UNA STANZA: dove sei, dove devi andare, cosa c'e'.
#
# Sono disegnati a mano finche' non arrivano i disegni di Bru: basta mettere
# art/icone_mappa/<nome>.png e quello vince, senza toccare una riga di codice.
#
# DUE REGOLE, E VENGONO DA DUE POSTI DIVERSI.
#
# La prima e' di Bertin: la forma non e' mai selettiva. Si puo' riconoscere un
# simbolo, ma non si possono trovare a colpo d'occhio tutti quelli uguali fra
# venti quadrati. Quindi questi segni dicono "qui c'e' questo" quando ci
# guardi, e non provano a dire nient'altro - il "dove andare" lo porta il
# movimento, il "dove sei" la posizione.
#
# La seconda e' la fasciatura (vedi Fascia.gd): tutti passano di li', perche'
# un segno sopra un pieno colorato non si misura contro la pagina ma contro il
# pieno, e nessuna tinta sola regge su tutti e quattro i nostri.
#
# STANNO FUORI DA MappaZona.gd perche' quella deve sapere cosa si sa e dove si
# puo' andare; come si disegna un punto esclamativo non la riguarda.

const CARTELLA := "res://art/icone_mappa/"


static func obiettivo(dove: CanvasItem, r: Rect2, battito: float,
		corpo: Color, fascia: Color) -> void:
	# DOVE DEVI ANDARE, e si muove. Bru: «puoi andare solo nella sala
	# allenamento che ha un punto esclamativo animato che si muove».
	#
	# Si muove perche' su una mappa ferma, fatta di quadrati tutti uguali,
	# l'unica cosa che l'occhio trova da solo e' quella che si muove. Saltella
	# e respira: due movimenti diversi insieme, perche' uno solo sembra un
	# errore di disegno e due sembrano una cosa viva.
	var centro := r.get_center()
	var raggio := minf(r.size.x, r.size.y) * 0.5
	var respiro := 1.0 + sin(battito * TAU * 2.0) * 0.06
	centro.y += sin(battito * TAU) * raggio * 0.14
	# il disco si interroga una volta sola, non a ogni fotogramma: questo
	# disegno si rifa' sessanta volte al secondo finche' il punto pulsa
	var texture := Disegni.texture(CARTELLA + "obiettivo.png")
	if texture != null:
		var misura := Vector2.ONE * raggio * 1.24 * respiro
		dove.draw_texture_rect(texture, Rect2(centro - misura * 0.5, misura), false)
		return
	# un'asta e un punto, che e' tutto quello che serve perche' si legga.
	#
	# BIANCO E NON ACCENTO, e ci e' voluto un sabotaggio per capirlo: il punto
	# esclamativo e' il richiamo, quindi la tentazione era dargli la tinta dei
	# richiami. Ma l'obiettivo puo' stare su una stanza gia' visitata - la sala
	# di allenamento in cui torni - e li' accento e rosso pieno sono la stessa
	# cosa: restava in piedi solo grazie alla fascia scura, cioe' si leggeva
	# come un contorno vuoto invece che come un segno. Ed e' l'unico segno
	# della mappa che si muove: il rosso non gli serviva.
	var alto := raggio * 0.62 * respiro
	var spessore := maxf(raggio * 0.17, 3.0)
	Fascia.linea(dove, centro + Vector2(0.0, -alto), centro + Vector2(0.0, alto * 0.25),
			spessore, corpo, fascia)
	Fascia.cerchio(dove, centro + Vector2(0.0, alto * 0.72), spessore * 0.58, corpo, fascia)


static func icona(dove: CanvasItem, quale: String, r: Rect2,
		corpo: Color, fascia: Color) -> void:
	if quale == "":
		return
	# se il disegno c'e' vince lui: aggiungere un'icona e' aggiungere un file
	var texture := Disegni.texture(CARTELLA + quale + ".png")
	if texture != null:
		var misura := Vector2.ONE * minf(r.size.x, r.size.y) * 0.62
		dove.draw_texture_rect(texture, Rect2(r.get_center() - misura * 0.5, misura), false)
		return
	var centro := r.get_center()
	var raggio := minf(r.size.x, r.size.y) * 0.5
	match quale:
		"boss":
			Fascia.arco(dove, centro, raggio * 0.58, maxf(raggio * 0.14, 2.0), corpo, fascia)
		"forte":
			Fascia.cerchio(dove, centro, raggio * 0.26, corpo, fascia)
		"uscita":
			var d := raggio * 0.44
			var spessore := maxf(raggio * 0.16, 2.0)
			Fascia.linea(dove, centro - Vector2(d, d), centro + Vector2(d, d),
					spessore, corpo, fascia)
			Fascia.linea(dove, centro + Vector2(d, -d), centro - Vector2(d, -d),
					spessore, corpo, fascia)
		_:
			Fascia.arco(dove, centro, raggio * 0.4, 2.0, corpo, fascia)


static func proiettore(dove: CanvasItem, r: Rect2, corpo: Color, fascia: Color) -> void:
	# il proiettore piantato: un anello nell'angolo, per non coprire l'icona
	# della stanza e per non farsi confondere con la freccia
	var misura := minf(r.size.x, r.size.y) * 0.3
	var angolo := r.position + Vector2(r.size.x - misura * 1.2, misura * 0.2)
	var texture := Disegni.texture(CARTELLA + "proiettore.png")
	if texture != null:
		dove.draw_texture_rect(texture, Rect2(angolo, Vector2.ONE * misura), false)
		return
	var centro := angolo + Vector2.ONE * misura * 0.5
	Fascia.arco(dove, centro, misura * 0.45, maxf(misura * 0.16, 2.0), corpo, fascia)
	Fascia.cerchio(dove, centro, misura * 0.13, corpo, fascia)


static func sei_qui(dove: CanvasItem, r: Rect2, corpo: Color, fascia: Color) -> void:
	# la freccia: dove sei adesso. Sta sopra il quadrato, non dentro, cosi' non
	# copre la sua icona
	var centro := r.get_center()
	var misura := minf(r.size.x, r.size.y)
	var punta := centro + Vector2(0, misura * 0.16)
	var larghezza := misura * 0.20
	var altezza := misura * 0.24
	Fascia.poligono(dove, PackedVector2Array([
		punta,
		punta + Vector2(-larghezza, -altezza),
		punta + Vector2(-larghezza * 0.45, -altezza),
		punta + Vector2(-larghezza * 0.45, -altezza - misura * 0.22),
		punta + Vector2(larghezza * 0.45, -altezza - misura * 0.22),
		punta + Vector2(larghezza * 0.45, -altezza),
		punta + Vector2(larghezza, -altezza),
	]), maxf(misura * 0.05, 2.0), corpo, fascia)
