extends Control
# IL CARTELLONE (ProposteScontro.gd): lo schermo della creatura.
#
# La creatura e' l'attrazione della serata: lo schermo piu' grande della
# schermata, in alto a sinistra, col lato destro sulla spina (Spina.gd). E'
# ancora il cabinato del manifesto - l'ombra piena, il contorno nero, la
# cornice chiara, il vetro scuro - perche' quella lingua Bru l'ha approvata; e'
# cambiata la misura, e la forma che taglia lo schermo in due.
#
# Quando la creatura attacca lo schermo lo usa il minigioco (si stende sul
# vetro(), la creatura si ritira dietro), e i pugni ti arrivano addosso da
# dove arriva lei: e' il suo schermo che si spacca.

const Spina := preload("res://prove/scontro/Spina.gd")
const CORNICE := 13.0
const BASSO := 548.0

var iniziale := "M"
var lampo := 0.0      # il suo turno: il vetro si accende di rosso (FasciaTurno lo fa due volte)
var ritirata := 0.0   # 1 quando lo schermo lo usa un minigioco
var scossa := Vector2.ZERO


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func fuori() -> PackedVector2Array:
	var a := Spina.ALTO
	return Spina.sposta(PackedVector2Array([Vector2(24, a), Vector2(Spina.diagonale(a), a),
			Vector2(Spina.diagonale(BASSO), BASSO), Vector2(24, BASSO)]), scossa)


func vetro() -> Rect2:
	# il rettangolo piu' grande che sta dentro il vetro: e' dove si gioca il
	# minigioco. Il lato destro del vetro e' di sbieco, quindi conta quello in basso
	var dentro := CORNICE + 10.0
	var alto := Spina.ALTO + dentro
	var basso := BASSO - dentro - 52.0   # sotto, la fascia col nome entra nello schermo
	return Rect2(Vector2(24.0 + dentro, alto), Vector2(Spina.diagonale(basso) - dentro - 24.0 - dentro, basso - alto))


func _draw() -> void:
	var contorno := fuori()
	Spina.carta(self, contorno, Stile.colore("cornice_turno"), 4.0)
	var vetro_scuro := Manifesto.scosta(contorno, -CORNICE)
	Manifesto.poligono(self, Manifesto.scosta(vetro_scuro, 3.0), Stile.colore("bordo"))
	Manifesto.poligono(self, vetro_scuro, Stile.colore("quadro_vuoto"))
	# finche' i disegni non ci sono, la creatura e' la sua iniziale: grande,
	# come sara' grande lei
	var centro := Vector2(390, 300) + scossa
	var tinta := Color(Stile.colore("tratto"), 1.0 - 0.85 * ritirata)
	Spina.scritta(self, Caratteri.titolo(), centro + Vector2(0, 90), iniziale, 260, tinta, HORIZONTAL_ALIGNMENT_CENTER)
	if lampo > 0.0:
		Manifesto.poligono(self, vetro_scuro, Color(Stile.colore("pericolo"), 0.45 * lampo))
