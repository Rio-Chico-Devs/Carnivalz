class_name RiflessoVetro
extends Control
# IL RIFLESSO SUL VETRO dei cabinati: ogni tanto passa una lama di luce di
# traverso, come su uno schermo vero quando ti muovi. Bru, sugli esempi animati
# (docs/vita.md): «bello tutto tranne le particelle che si muovono nello sfondo
# e le immagini che galleggiano» - il riflesso resta, il resto no.
#
# Ogni vetro ha il suo tempo: il primo passa dopo poco, gli altri sfalsati, mai
# due insieme. Tre quarti di secondo di luce ogni quattro secondi e mezzo, e
# leggera (un decimo di bianco): si vede di sfuggita, non si guarda.
#
# Sta DENTRO il vetro e ne prende la misura; taglia quello che esce. Disegna
# solo mentre passa: fermo non costa niente. Col movimento ridotto non passa.

const PERIODO := 4.6
const PASSA := 0.75
const LUCE := 0.11

static var quanti := 0     # quanti vetri sono nati: serve a sfalsarli

var orologio := 0.0
var ritardo := 0.0
var acceso := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ritardo = 0.4 + 0.9 * float(quanti % 5)
	quanti += 1


func _process(delta: float) -> void:
	orologio += delta
	var adesso := passaggio() >= 0.0
	if adesso or acceso:
		queue_redraw()
	acceso = adesso


func passaggio() -> float:
	# a che punto e' la lama, da 0 a 1; -1 se adesso non passa
	if Movimento.ridotto() or orologio < ritardo:
		return -1.0
	var u := fposmod(orologio - ritardo, PERIODO) / PASSA
	return u if u <= 1.0 else -1.0


func _draw() -> void:
	var u := passaggio()
	if u < 0.0:
		return
	var largo := size.x * 0.2
	var storto := size.y * 0.5
	var x := lerpf(-largo - storto, size.x + storto, Movimento.curva("standard", u))
	var a := LUCE * sin(PI * u)
	draw_colored_polygon(PackedVector2Array([Vector2(x + storto, 0), Vector2(x + storto + largo, 0),
			Vector2(x + largo, size.y), Vector2(x, size.y)]), Color(1, 1, 1, a))
	var filo := x + largo * 1.3
	draw_colored_polygon(PackedVector2Array([Vector2(filo + storto, 0), Vector2(filo + storto + largo * 0.18, 0),
			Vector2(filo + largo * 0.18, size.y), Vector2(filo, size.y)]), Color(1, 1, 1, a * 0.9))
