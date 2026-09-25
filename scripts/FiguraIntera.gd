class_name FiguraIntera
extends Control

# IL PERSONAGGIO A FIGURA INTERA, al centro della scheda (C nello schema).
#
# Il disegno vero sta in art/personaggi/<id>/intero.png: si appoggia in basso,
# centrato, e se e' piu' alto del riquadro esce dal fondo come nel riferimento
# di Bru. Finche' non c'e', al suo posto c'e' l'iniziale gigante con le copie
# cremisi sfalsate dietro - la stessa parola grande delle quinte della pausa.
# Non finge di essere un ritratto: tiene il posto, e dice di chi e'.
#
# Cambiando compagno la figura nuova arriva da destra dissolvendosi, sulla
# curva d'entrata: e' il gesto che dice "adesso guardi un altro".

const SCIVOLO := 40.0
const CORPO_INIZIALE := 520
const COPIE := 4

var id_classe := ""
var arrivo := 1.0
var orologio := -1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)


func mostra(id: String) -> void:
	if id == id_classe:
		return
	id_classe = id
	arrivo = 0.0
	orologio = 0.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	orologio += delta
	var durata := Movimento.durata("colore" if Movimento.ridotto() else "entrata")
	arrivo = Movimento.curva("entrata", clampf(orologio / durata, 0.0, 1.0))
	if orologio >= durata:
		arrivo = 1.0
		set_process(false)
	queue_redraw()


func _draw() -> void:
	if id_classe == "":
		return
	var spostato := Vector2(0.0 if Movimento.ridotto() else SCIVOLO * (1.0 - arrivo), 0.0)
	var alfa := arrivo
	var disegno := Disegni.texture("res://art/personaggi/%s/intero.png" % id_classe)
	if disegno != null:
		var misura := disegno.get_size()
		var quanto := size.x / misura.x
		var alto := misura.y * quanto
		var dove := Rect2(Vector2(0.0, size.y - minf(alto, size.y * 1.08)) + spostato, misura * quanto)
		draw_texture_rect(disegno, dove, false, Color(1, 1, 1, alfa))
		return
	var copie: Array[Color] = []
	for i in COPIE:
		copie.append(Color(Stile.colore("accento").darkened(0.25 + 0.15 * i), alfa))
	var r := Rect2(Vector2(0, size.y * 0.1) + spostato, size)
	Sagome.iniziale(self, r, SchedaOggetto.nome_di_classe(id_classe), CORPO_INIZIALE,
			Color(Stile.colore("testo"), alfa), copie)
