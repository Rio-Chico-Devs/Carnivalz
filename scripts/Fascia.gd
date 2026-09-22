class_name Fascia
extends RefCounted

# DISEGNARE UN SEGNO CHE SI VEDE SOPRA QUALUNQUE COSA.
#
# Sulle carte stradali una strada chiara non si disegna e basta: si disegna
# con un filo scuro intorno. Serve perche' quella stessa strada deve reggere
# sul verde dei campi, sul grigio della citta' e sul bianco della neve, e
# nessun colore solo ce la fa su tutti e tre. Col filo intorno invece: dove
# non si vede il corpo si vede il contorno, e viceversa.
#
# E' arrivata qui da un difetto vero. Sulla mappa delle zone la freccia "sei
# qui" era disegnata in accento (#e8123c) sopra il pieno rosso di una stanza
# (#ed1c24): fra loro 1,05:1. Il segno che dice al giocatore DOVE SI TROVA -
# l'unica cosa che su una mappa non si puo' sbagliare - era invisibile. E
# nessuna misura l'aveva preso, perche' tutte misuravano contro il nero della
# pagina: un segno sopra un pieno non si misura contro la pagina, si misura
# contro il pieno.
#
# LA REGOLA, e vale ovunque si disegni un segno sopra qualcosa di colorato:
#
#   1. su qualunque fondo, o arriva a 3:1 il corpo o ci arriva la fascia
#   2. fra corpo e fascia ci dev'essere stacco, se no e' una macchia sola
#
# Col bianco come corpo e il nero come fascia il punto 2 fa 21:1, che e' il
# massimo che esista fra due colori, e il punto 1 non puo' fallire.
#
# STA FUORI DALLA MAPPA perche' non e' della mappa: e' un modo di disegnare.
# La prossima schermata che deve metterci sopra un'icona non deve riscoprirlo.

const QUOTA := 0.55      # quanto e' grossa la fascia rispetto al segno
const MINIMA := 1.5      # ...ma sotto un pixel e mezzo non fascia piu' niente


static func spessore_di(spessore: float) -> float:
	return maxf(spessore * QUOTA, MINIMA)


static func linea(dove: CanvasItem, da: Vector2, a: Vector2, spessore: float,
		tinta: Color, fascia: Color) -> void:
	dove.draw_line(da, a, fascia, spessore + spessore_di(spessore) * 2.0)
	dove.draw_line(da, a, tinta, spessore)


static func cerchio(dove: CanvasItem, centro: Vector2, raggio: float,
		tinta: Color, fascia: Color) -> void:
	dove.draw_circle(centro, raggio + spessore_di(raggio * 0.4), fascia)
	dove.draw_circle(centro, raggio, tinta)


static func arco(dove: CanvasItem, centro: Vector2, raggio: float,
		spessore: float, tinta: Color, fascia: Color) -> void:
	dove.draw_arc(centro, raggio, 0.0, TAU, 24, fascia,
			spessore + spessore_di(spessore) * 2.0)
	dove.draw_arc(centro, raggio, 0.0, TAU, 24, tinta, spessore)


static func poligono(dove: CanvasItem, punti: PackedVector2Array, spessore: float,
		tinta: Color, fascia: Color) -> void:
	if punti.size() < 3:
		return
	var giro := punti.duplicate()
	giro.append(punti[0])   # draw_polyline non chiude da sola
	dove.draw_polyline(giro, fascia, spessore * 2.0)
	dove.draw_colored_polygon(punti, tinta)
