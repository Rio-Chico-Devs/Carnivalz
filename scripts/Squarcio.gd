class_name Squarcio
extends Node2D
# LO SQUARCIO: come si entra in uno scontro.
#
# Bru, sugli esempi animati (docs/vita.md): «bello anche lo spacco che ti
# introduce al combattimento». La schermata da cui arrivi si crepa lungo una
# linea storta - lo squarcio dei Carnivalz, che e' anche il modo in cui si
# aprono le zone -, la crepa si accende, le due meta' volano via girando un
# poco, e sotto lo scontro entra a pezzi: il nemico e la sua scheda da sinistra,
# la squadra dall'alto, per ultimo il quadrante dei comandi, che e' dove devi
# guardare (la cascata di docs/animazione.md: la cosa principale chiude).
#
# CHI FA COSA. Transizioni, che fa tutti i cambi di scena, al posto del velo
# nero fotografa lo schermo, ci mette sopra questo nodo con la foto - quindi non
# si vede niente cambiare -, cambia scena sotto, e lascia che la foto si rompa.
# Lo scontro, nel suo _ready, chiama entra_a_pezzi: i pezzi entrano solo se
# stanno arrivando da qui, e mai nelle prove che aprono lo scontro a mano.
#
# NON FA ASPETTARE: dalla crepa all'ultimo pezzo fermo passa poco piu' di mezzo
# secondo, meno della dissolvenza che sostituisce (andata e ritorno, 0,7 s).
# Col movimento ridotto, o senza una finestra da fotografare, resta la
# dissolvenza di sempre.

signal finito

const SCENA := "res://scenes/Combattimento.tscn"
const CREPA := 0.05      # quando comincia a crepare
const DISEGNA := 0.12    # quanto ci mette la crepa ad attraversare lo schermo
const APRE := 0.2        # quando le due meta' partono
const VOLA := 0.34       # quanto volano
const PEZZI_DOPO := 0.26 # quando i pezzi dello scontro cominciano a entrare

static var in_arrivo := false   # lo scontro che sta per nascere arriva da uno squarcio

var orologio := 0.0
var lato := Vector2.ZERO
var linea := PackedVector2Array()
var meta_su: Polygon2D
var meta_giu: Polygon2D
var luce: Line2D
var anima: Line2D


static func per(percorso: String) -> bool:
	# lo squarcio si apre solo verso uno scontro, e solo se c'e' qualcosa da
	# fotografare e nessuno ha chiesto meno movimento
	return percorso == SCENA and not Movimento.ridotto() and DisplayServer.get_name() != "headless"


func _init(foto: Image, schermo: Vector2) -> void:
	lato = schermo
	var texture := ImageTexture.create_from_image(foto)
	var scala_foto := Vector2(foto.get_size()) / schermo
	var dado := RandomNumberGenerator.new()
	dado.randomize()
	# la crepa: da sinistra in basso a destra in alto, a denti
	var passi := 18
	for k in passi + 1:
		var u := float(k) / float(passi)
		var dente := dado.randf_range(-0.03, 0.03) * lato.y if k % passi != 0 else 0.0
		linea.append(Vector2(lerpf(-20.0, lato.x + 20.0, u), lerpf(lato.y * 0.66, lato.y * 0.3, u) + dente))
	var al_contrario := linea.duplicate()
	al_contrario.reverse()
	var su := PackedVector2Array([Vector2(-20, -20), Vector2(lato.x + 20, -20)])
	su.append_array(al_contrario)
	var giu := linea.duplicate()
	giu.append_array(PackedVector2Array([Vector2(lato.x + 20, lato.y + 20), Vector2(-20, lato.y + 20)]))
	meta_su = meta(texture, su, scala_foto)
	meta_giu = meta(texture, giu, scala_foto)
	luce = filo(lato.y * 0.025, Color(1.0, 0.62, 0.15, 0.85))
	anima = filo(lato.y * 0.007, Color(1.0, 0.97, 0.9))


func meta(texture: Texture2D, contorno: PackedVector2Array, scala_foto: Vector2) -> Polygon2D:
	var pezzo := Polygon2D.new()
	pezzo.texture = texture
	pezzo.polygon = contorno
	var uv := PackedVector2Array()
	for p in contorno:
		uv.append(p * scala_foto)
	pezzo.uv = uv
	add_child(pezzo)
	return pezzo


func filo(spesso: float, tinta: Color) -> Line2D:
	var tratto := Line2D.new()
	tratto.width = spesso
	tratto.default_color = tinta
	tratto.begin_cap_mode = Line2D.LINE_CAP_ROUND
	tratto.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(tratto)
	return tratto


func _process(delta: float) -> void:
	avanza(delta)


func avanza(delta: float) -> void:
	orologio += delta
	# la crepa si disegna da sinistra a destra
	var u := clampf((orologio - CREPA) / DISEGNA, 0.0, 1.0)
	var tratto := PackedVector2Array()
	if orologio >= CREPA:
		tratto = linea.slice(0, int(round(u * float(linea.size() - 1))) + 1)
	luce.points = tratto
	anima.points = tratto
	luce.width = lato.y * (0.025 + 0.014 * sin(clampf((orologio - CREPA) / 0.2, 0.0, 1.0) * PI))
	# le due meta' volano via girando un poco, e la crepa si spegne
	var v := Movimento.curva("uscita", clampf((orologio - APRE) / VOLA, 0.0, 1.0))
	meta_su.position = Vector2(-lato.x * 0.06, -lato.y * 0.75) * v
	meta_su.rotation = -0.07 * v
	meta_giu.position = Vector2(lato.x * 0.06, lato.y * 0.75) * v
	meta_giu.rotation = 0.07 * v
	var spegne := 1.0 - clampf((orologio - APRE) / 0.18, 0.0, 1.0)
	luce.modulate.a = spegne
	anima.modulate.a = spegne
	if orologio >= APRE + VOLA:
		set_process(false)
		finito.emit()
		queue_free()


static func entra_a_pezzi(plancia: PlanciaCombattimento) -> void:
	# I PEZZI DELLO SCONTRO ENTRANO, se si arriva da uno squarcio: il nemico e
	# la sua scheda da sinistra, la squadra dall'alto, il quadrante dal basso e
	# per ultimo. Le posizioni si leggono al primo fotogramma, quando la plancia
	# si e' gia' disposta
	if not in_arrivo or plancia == null:
		return
	in_arrivo = false
	var radice := plancia.radice
	radice.get_tree().process_frame.connect(func() -> void: fai_entrare(plancia), CONNECT_ONE_SHOT)


static func fai_entrare(plancia: PlanciaCombattimento) -> void:
	if not is_instance_valid(plancia.radice):
		return
	var dentro: Array[Node] = [plancia.box_nemico, plancia.scheda_nemico]
	for slot in plancia.slot:
		dentro.append(slot)
	dentro.append(plancia.quadrante)
	var lato_radice := plancia.radice.size
	var ritardi := Movimento.ritardi_cascata(dentro.size(), dentro.size() - 1)
	for i in dentro.size():
		var pezzo := pezzo_di(dentro[i], plancia.radice)
		if pezzo == null:
			continue
		var fermo := pezzo.position
		var da_dove := Vector2(0.0, lato_radice.y * 0.5) if i == dentro.size() - 1 else Vector2(0.0, -lato_radice.y * 0.65)
		if i < 2:
			da_dove = Vector2(-lato_radice.x * 0.5, 0.0)
		pezzo.position = fermo + da_dove
		var entra := pezzo.create_tween()
		entra.tween_interval(PEZZI_DOPO + ritardi[i])
		entra.tween_property(pezzo, "position", fermo, Movimento.durata("entrata")) \
				.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


static func pezzo_di(n: Node, radice: Control) -> Control:
	# il figlio della plancia che contiene n: la cornice si muove col contenuto
	var su := n
	while su != null and su.get_parent() != radice:
		su = su.get_parent()
	return su as Control
