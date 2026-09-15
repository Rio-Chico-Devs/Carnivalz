class_name IconeStato
extends RefCounted

# I RIQUADRI DEGLI STATUS, quelli accanto alla vita.
#
# Bru: «quei riquadri vicino alla vita sono gli status, se stanno bene ci stara
# l'icona normale altrimenti ho fatto esempi per in fiamme, maledetto e
# paralisi».
#
# Nel suo disegno sono tre tasselli neri quadrati con dentro un simbolo pieno e
# colorato: una fiamma rossa, un fantasmino viola, una saetta gialla. Qui sotto
# sono disegnati col codice - un poligono e basta - per la stessa ragione delle
# icone della mappa: cosi' esistono subito e si puo' guardare la schermata vera
# prima che ci sia un solo pixel disegnato.
#
# QUANDO IL DISEGNO ARRIVA, VINCE IL DISEGNO: basta mettere
# art/icone_stato/<id>.png e questo file smette di disegnare quello status,
# senza che nessuno debba venire a togliere il poligono.

const CARTELLA := "res://art/icone_stato/"

# QUALE DISEGNO C'E', CHIESTO UNA VOLTA SOLA.
#
# disegna() gira dentro un _draw, cioe' potenzialmente a ogni fotogramma e per
# ogni riquadro di stato: con tre compagni e tre riquadri a testa sono nove
# domande al disco per fotogramma. Misurato, un controllo d'esistenza costa
# 0.024 ms - moltiplicato per nove e per sessanta fa quattordici millisecondi al
# secondo buttati a chiedere al disco una cosa che non cambia mai mentre il
# gioco gira.
#
# Le risposte non scadono: dentro un gioco compilato i file non compaiono da
# soli. Se un domani si aggiungessero a caldo, basta svuotare.
static var disegni_trovati: Dictionary = {}

static func percorso_di(id_stato: String) -> String:
	var chiave := id_stato if id_stato != "" else "normale"
	if disegni_trovati.has(chiave):
		return String(disegni_trovati[chiave])
	var percorso := CARTELLA + chiave + ".png"
	var risposta := percorso if ResourceLoader.exists(percorso) else ""
	disegni_trovati[chiave] = risposta
	return risposta

static func svuota_cache() -> void:
	disegni_trovati.clear()

static func disegna(dove: CanvasItem, id_stato: String, riquadro: Rect2) -> void:
	var percorso := percorso_di(id_stato)
	if percorso != "":
		var disegno: Texture2D = load(percorso)
		dove.draw_texture_rect(disegno, riquadro, false)
		return
	var centro := riquadro.position + riquadro.size * 0.5
	var raggio := minf(riquadro.size.x, riquadro.size.y) * 0.34
	match id_stato:
		"fiamme":
			fiamma(dove, centro, raggio, Stile.colore("barra_dominio"))
		"maledizione", "terrore":
			fantasma(dove, centro, raggio, Color(0.45, 0.33, 0.62))
		"lentezza", "frastornato", "sonno":
			saetta(dove, centro, raggio, Stile.colore("barra_hp"))
		"":
			# «se stanno bene ci stara l'icona normale»: un cerchio pieno e
			# calmo. Sta bene vuol dire che non c'e' niente da leggere, e
			# l'icona deve dirlo stando zitta.
			dove.draw_circle(centro, raggio * 0.62, Stile.colore("testo_smorzato"))
		_:
			dove.draw_circle(centro, raggio * 0.72, Stile.colore("accento"))

static func fiamma(dove: CanvasItem, centro: Vector2, raggio: float, tinta: Color) -> void:
	var punti := PackedVector2Array([
		centro + Vector2(0.0, -raggio * 1.25),
		centro + Vector2(raggio * 0.72, -raggio * 0.05),
		centro + Vector2(raggio * 0.82, raggio * 0.55),
		centro + Vector2(0.0, raggio * 1.05),
		centro + Vector2(-raggio * 0.82, raggio * 0.55),
		centro + Vector2(-raggio * 0.55, -raggio * 0.25),
		centro + Vector2(-raggio * 0.12, -raggio * 0.62),
	])
	dove.draw_colored_polygon(punti, tinta)

static func fantasma(dove: CanvasItem, centro: Vector2, raggio: float, tinta: Color) -> void:
	var punti := PackedVector2Array()
	# la cupola sopra
	for i in 13:
		var angolo := PI + PI * float(i) / 12.0
		punti.append(centro + Vector2(cos(angolo), sin(angolo)) * raggio)
	# e il bordo ondulato sotto
	punti.append(centro + Vector2(raggio, raggio * 0.75))
	punti.append(centro + Vector2(raggio * 0.55, raggio * 0.35))
	punti.append(centro + Vector2(raggio * 0.1, raggio * 0.8))
	punti.append(centro + Vector2(-raggio * 0.4, raggio * 0.35))
	punti.append(centro + Vector2(-raggio * 0.8, raggio * 0.8))
	punti.append(centro + Vector2(-raggio, raggio * 0.35))
	dove.draw_colored_polygon(punti, tinta)
	for lato in [-1.0, 1.0]:
		dove.draw_circle(centro + Vector2(raggio * 0.38 * lato, -raggio * 0.22),
				raggio * 0.17, Stile.colore("bordo"))

static func saetta(dove: CanvasItem, centro: Vector2, raggio: float, tinta: Color) -> void:
	var punti := PackedVector2Array([
		centro + Vector2(raggio * 0.35, -raggio * 1.15),
		centro + Vector2(-raggio * 0.75, raggio * 0.18),
		centro + Vector2(-raggio * 0.08, raggio * 0.18),
		centro + Vector2(-raggio * 0.35, raggio * 1.15),
		centro + Vector2(raggio * 0.78, -raggio * 0.22),
		centro + Vector2(raggio * 0.05, -raggio * 0.22),
	])
	dove.draw_colored_polygon(punti, tinta)

static func ricciolo(dove: CanvasItem, riquadro: Rect2, tinta: Color) -> void:
	# IL SEGNO DELLA BARRA DI DOMINIO. Nel disegno di Bru quella riga non porta
	# una parola ma un ricciolo rosso: un gancio che si arrotola. Le altre due
	# barre sono risorse con un nome che conosci; questa e' una cosa che ti si
	# carica addosso, e non ha bisogno di essere letta - deve solo riempirsi.
	var centro := riquadro.position + riquadro.size * 0.5
	var raggio := minf(riquadro.size.x, riquadro.size.y) * 0.42
	var spessore := maxf(raggio * 0.42, 1.5)
	dove.draw_arc(centro, raggio, PI * 0.15, PI * 1.55, 20, tinta, spessore)
	dove.draw_circle(centro + Vector2(cos(PI * 0.15), sin(PI * 0.15)) * raggio,
			spessore * 0.5, tinta)
