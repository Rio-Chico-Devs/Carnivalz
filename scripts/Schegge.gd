class_name Schegge
extends Control

# LE SCHEGGE DI UNA SCELTA. Quando premi una voce, dal suo segno saltano via
# sette triangoli di carta - cremisi, bianchi, neri - che volano lungo la
# diagonale del nastro, rallentano e spariscono in un terzo di secondo.
#
# Bru: «Ogni click o pressione di tasto innesca minuscole reazioni visive
# (rimbalzi, cambi di colore, particelle) che rendono il gioco vivo». Le
# particelle sono queste, e sono triangoli e non puntini per la stessa ragione
# per cui le lastre hanno i lati tagliati: il gioco e' fatto di carta
# ritagliata, e anche i suoi ritagli devono esserlo.
#
# UN NODO SOLO CHE DISEGNA TUTTO, come i pugni della raffica: niente nodi
# creati e distrutti per ogni scheggia (la documentazione di Godot: «every
# node has a cost»). Non servono nemmeno le CPUParticles2D: sette triangoli
# sono sette poligoni. E vive fuori dalla voce che le ha fatte scoppiare,
# perche' premere una voce di solito la distrugge - si apre un altro pannello -
# e le schegge devono finire il loro volo lo stesso.
#
# Col movimento ridotto non scoppia niente: la pressione la dicono il lampo e
# il suono.

const PER_SCOPPIO := 7
const MASSIME := 28          # quattro scoppi insieme; oltre, i vecchi lasciano il posto
const VITA := 0.34
const VELOCITA := Vector2(380.0, 640.0)
const FRENO := 7.0            # quanto rallentano: in un terzo di secondo quasi fermi
const LATO := Vector2(7.0, 15.0)
const APERTURA := 0.9         # di quanto si allarga il ventaglio attorno alla diagonale (radianti)
const COLORI := ["accento", "accento", "bordo_acceso", "accento", "sfondo", "bordo_acceso", "accento"]

var pezzi: Array[Dictionary] = []
var dado := RandomNumberGenerator.new()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)


func scoppia(dove_globale: Vector2) -> void:
	if Movimento.ridotto():
		return
	var dove := get_global_transform().affine_inverse() * dove_globale
	var diagonale := Stile.angolo("inclinazione_nastro")
	for i in PER_SCOPPIO:
		if pezzi.size() >= MASSIME:
			pezzi.pop_front()
		# meta' verso destra e meta' verso sinistra, lungo la diagonale: un
		# ventaglio che si apre di lato, non una stella
		var verso := diagonale + (PI if i % 2 == 1 else 0.0) \
				+ dado.randf_range(-APERTURA, APERTURA)
		pezzi.append({
			"dove": dove,
			"velocita": Vector2.from_angle(verso) * dado.randf_range(VELOCITA.x, VELOCITA.y),
			"angolo": dado.randf_range(0.0, TAU),
			"giro": dado.randf_range(-14.0, 14.0),
			"lato": dado.randf_range(LATO.x, LATO.y),
			"vita": VITA,
			"colore": String(COLORI[i % COLORI.size()]),
		})
	set_process(true)


func _process(delta: float) -> void:
	avanza(delta)


func avanza(dt: float) -> void:
	var frenata := exp(-FRENO * dt)
	var vivi: Array[Dictionary] = []
	for pezzo in pezzi:
		pezzo.dove += pezzo.velocita * dt
		pezzo.velocita *= frenata
		pezzo.angolo += float(pezzo.giro) * dt
		pezzo.vita = float(pezzo.vita) - dt
		if float(pezzo.vita) > 0.0:
			vivi.append(pezzo)
	pezzi = vivi
	queue_redraw()
	set_process(not pezzi.is_empty())


func _draw() -> void:
	for pezzo in pezzi:
		var quanto := clampf(float(pezzo.vita) / VITA, 0.0, 1.0)
		var lato := float(pezzo.lato) * (0.5 + 0.5 * quanto)
		var giro := float(pezzo.angolo)
		var centro: Vector2 = pezzo.dove
		# un triangolo lungo e stretto: una scheggia, non un coriandolo
		draw_colored_polygon(PackedVector2Array([
			centro + Vector2.from_angle(giro) * lato,
			centro + Vector2.from_angle(giro + 2.5) * lato * 0.45,
			centro + Vector2.from_angle(giro - 2.5) * lato * 0.45]),
			Color(Stile.colore(String(pezzo.colore)), quanto))
