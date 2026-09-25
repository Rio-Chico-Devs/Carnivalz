class_name StatisticheScheda
extends Control

# QUANTO VALE UN PERSONAGGIO: le cinque statistiche, nel pannello E della scheda.
#
# Una riga per statistica: l'icona, il nome, il valore. Quello che viene
# dall'equipaggiamento si legge a parte, tra parentesi e col suo colore - non
# si confonde col talento. E quando stai scegliendo un oggetto, passandoci
# sopra la riga dice dove andresti: "15 → 17", verde se sale, rosso se scende.
# E' la regola della scheda (vedi Personaggio.gd): SEMPRE LA DIFFERENZA, MAI
# SOLO IL NUMERO. Una scelta deve costare un secondo, non un calcolo.

const PASSO := 32.0
const MARGINE := 8.0
const LATO_ICONA := 26.0
const DESTRA := 423.0          # dove finiscono i valori, allineati a destra

var righe: Array[Dictionary] = []      # chiave, nome, base, bonus
var anteprima: Dictionary = {}         # chiave -> di quanto cambierebbe


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func imposta(nuove: Array[Dictionary]) -> void:
	righe = nuove
	anteprima = {}
	queue_redraw()


func mostra_anteprima(scarti: Dictionary) -> void:
	anteprima = scarti
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(Stile.colore("pannello_chiaro"), 0.85))
	draw_rect(Rect2(Vector2.ZERO, size), Color(Stile.colore("testo"), 0.1), false, 1.0)
	var titolo := Caratteri.titolo()
	var tondo := Caratteri.tondo(800)
	if titolo == null or tondo == null:
		return
	for i in righe.size():
		disegna_riga(righe[i], MARGINE + PASSO * i, titolo, tondo)


func disegna_riga(riga: Dictionary, y: float, titolo: Font, tondo: Font) -> void:
	var chiave := String(riga["chiave"])
	var icona := Rect2(13, y + 3, LATO_ICONA, LATO_ICONA)
	draw_rect(icona, Stile.colore("sfondo"))
	var disegno := Disegni.texture("res://art/interfaccia/statistiche/%s.png" % chiave)
	if disegno != null:
		draw_texture_rect(disegno, icona, false)
	else:
		Sagome.icona_statistica(self, icona.grow(-4.0), chiave, Stile.colore("testo"))
	draw_string(tondo, Vector2(50, y + 23), String(riga["nome"]), HORIZONTAL_ALIGNMENT_LEFT, 200, 17,
			Stile.colore("testo"))
	draw_line(Vector2(50, y + PASSO - 3.0), Vector2(DESTRA, y + PASSO - 3.0), Color(Stile.colore("testo"), 0.1), 1.0)
	var valore := int(riga["base"]) + int(riga["bonus"])
	var scarto := int(anteprima.get(chiave, 0))
	var x := DESTRA
	if scarto != 0:
		var nuovo := "→ %d" % (valore + scarto)
		var colore := Stile.colore("positivo") if scarto > 0 else Stile.colore("pericolo")
		x -= titolo.get_string_size(nuovo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
		draw_string(titolo, Vector2(x, y + 25), nuovo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, colore.lightened(0.25))
		x -= 10.0
	var testo := "%d" % valore
	x -= titolo.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	draw_string(titolo, Vector2(x, y + 25), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24,
			Stile.colore("testo") if scarto == 0 else Stile.colore("testo_smorzato"))
	var bonus := int(riga["bonus"])
	if bonus != 0:
		# quanto viene da quello che porti addosso, a parte e col suo colore
		var quota := "(%+d)" % bonus
		x -= tondo.get_string_size(quota, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x + 8.0
		draw_string(tondo, Vector2(x, y + 23), quota, HORIZONTAL_ALIGNMENT_LEFT, -1, 14,
				(Stile.colore("positivo") if bonus > 0 else Stile.colore("pericolo")).lightened(0.25))
