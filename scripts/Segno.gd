class_name Segno
extends Control

# UN SEGNO ACCANTO A UNA VOCE DI MENU, disegnato a mano finche' non c'e' l'arte.
#
# PLAY, l'euristica F4: «Art is recognizable to the player and speaks to its
# function». Le voci della pausa erano sette righe di solo testo, tutte uguali:
# per sapere cosa c'era dietro bisognava leggerle una per una.
#
# PERCHE' GEOMETRICI E NON DISEGNINI. Dai principi della cartografia (Buckley,
# da Map Use): «Geometric symbols are easier to read at smaller sizes, while
# more complex symbols require more space to be legible». Un segno alto venti
# pixel non e' il posto di un teschio dettagliato: e' il posto di un triangolo.
#
# E UN SEGNO NON BASTA DA SOLO. Bertin: la forma e' l'unica delle sue variabili
# che non e' MAI selettiva - non permette di isolare un gruppo a colpo d'occhio.
# Qui non serve che lo faccia, perche' a raggruppare ci pensa la POSIZIONE (le
# voci stanno in blocchi separati), che invece selettiva lo e'. Il segno
# aggiunge riconoscimento, non struttura.
#
# Il giorno che arrivano i disegni: art/segni/<nome>.png e quello vince, come
# gia' succede per le icone della mappa.

const CARTELLA := "res://art/segni/"

var quale := ""
var tinta := Color.WHITE


static func nuovo(nome: String, colore: Color, lato: float) -> Segno:
	var s := Segno.new()
	s.quale = nome
	s.tinta = colore
	s.custom_minimum_size = Vector2(lato, lato)
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


func _draw() -> void:
	var texture := disegno_vero()
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
		return
	var lato := minf(size.x, size.y)
	var centro := size * 0.5
	var raggio := lato * 0.42
	var spessore := maxf(lato * 0.13, 2.0)
	match quale:
		"riprendi":
			traccia_triangolo(centro, raggio)
		"storico":
			traccia_righe(centro, raggio, spessore)
		"diario":
			traccia_quaderno(centro, raggio, spessore)
		"squadra":
			draw_circle(centro + Vector2(-raggio * 0.45, 0.0), raggio * 0.42, tinta)
			draw_circle(centro + Vector2(raggio * 0.45, 0.0), raggio * 0.42, tinta)
		"zaino":
			traccia_zaino(centro, raggio, spessore)
		"opzioni":
			traccia_leva(centro, raggio, spessore)
		"uscita":
			traccia_uscita(centro, raggio, spessore)
		"indietro":
			traccia_indietro(centro, raggio, spessore)
		_:
			draw_arc(centro, raggio, 0.0, TAU, 20, tinta, spessore)


func disegno_vero() -> Texture2D:
	var percorso := CARTELLA + quale + ".png"
	return load(percorso) if ResourceLoader.exists(percorso) else null


func traccia_triangolo(centro: Vector2, raggio: float) -> void:
	draw_colored_polygon(PackedVector2Array([
			centro + Vector2(-raggio * 0.6, -raggio),
			centro + Vector2(raggio, 0.0),
			centro + Vector2(-raggio * 0.6, raggio)]), tinta)


func traccia_righe(centro: Vector2, raggio: float, spessore: float) -> void:
	# tre righe di testo che scendono, l'ultima piu' corta: e' un trascritto
	for i in 3:
		var y := centro.y + (float(i) - 1.0) * raggio * 0.72
		var largo := raggio if i < 2 else raggio * 0.5
		draw_line(Vector2(centro.x - raggio, y), Vector2(centro.x + largo, y),
				tinta, spessore)


func traccia_quaderno(centro: Vector2, raggio: float, spessore: float) -> void:
	draw_rect(Rect2(centro - Vector2(raggio * 0.8, raggio), Vector2(raggio * 1.6, raggio * 2.0)),
			tinta, false, spessore)
	# la costa, che e' quello che lo distingue da un rettangolo qualunque
	draw_line(centro + Vector2(-raggio * 0.35, -raggio),
			centro + Vector2(-raggio * 0.35, raggio), tinta, spessore)


func traccia_zaino(centro: Vector2, raggio: float, spessore: float) -> void:
	draw_rect(Rect2(centro - Vector2(raggio, raggio * 0.55),
			Vector2(raggio * 2.0, raggio * 1.55)), tinta, false, spessore)
	# il manico sopra: senza, e' una scatola
	draw_arc(centro + Vector2(0.0, -raggio * 0.55), raggio * 0.5, PI, TAU, 12, tinta, spessore)


func traccia_leva(centro: Vector2, raggio: float, spessore: float) -> void:
	draw_line(centro - Vector2(raggio, 0.0), centro + Vector2(raggio, 0.0), tinta, spessore)
	draw_circle(centro + Vector2(raggio * 0.35, 0.0), raggio * 0.42, tinta)


func traccia_uscita(centro: Vector2, raggio: float, spessore: float) -> void:
	# una freccia che esce da una parentesi aperta
	draw_line(centro + Vector2(-raggio, -raggio), centro + Vector2(-raggio * 0.35, -raggio),
			tinta, spessore)
	draw_line(centro + Vector2(-raggio, -raggio), centro + Vector2(-raggio, raggio),
			tinta, spessore)
	draw_line(centro + Vector2(-raggio, raggio), centro + Vector2(-raggio * 0.35, raggio),
			tinta, spessore)
	draw_line(centro + Vector2(-raggio * 0.1, 0.0), centro + Vector2(raggio, 0.0),
			tinta, spessore)
	draw_line(centro + Vector2(raggio * 0.45, -raggio * 0.5), centro + Vector2(raggio, 0.0),
			tinta, spessore)
	draw_line(centro + Vector2(raggio * 0.45, raggio * 0.5), centro + Vector2(raggio, 0.0),
			tinta, spessore)


func traccia_indietro(centro: Vector2, raggio: float, spessore: float) -> void:
	# la freccia che torna: la stessa punta dell'uscita, girata, e senza la
	# parentesi - non esci da niente, torni un passo indietro
	draw_line(centro + Vector2(raggio, 0.0), centro + Vector2(-raggio, 0.0), tinta, spessore)
	draw_line(centro + Vector2(-raggio * 0.45, -raggio * 0.55), centro + Vector2(-raggio, 0.0),
			tinta, spessore)
	draw_line(centro + Vector2(-raggio * 0.45, raggio * 0.55), centro + Vector2(-raggio, 0.0),
			tinta, spessore)
