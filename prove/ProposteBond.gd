extends Control
# TRE PROPOSTE PER IL BOND. Provvisorio come le altre vetrine: non e' il gioco.
#
# Bru, dopo aver approvato il taglio della Mattanza: «per il bond ci vuole
# qualcosa di più felice e tranquillo». Il BOND e' la mediazione: la creatura
# la lasci vivere, la raggiungi (docs/mediazione.md). Quindi il contrario della
# Mattanza in ogni scelta:
#
#   la Mattanza                     il BOND
#   fasce di traverso               linee orizzontali e cerchi
#   entra di scatto, esce di scatto si muove piano, comincia e finisce morbido
#   nero e rosso                    crema, oro, l'arancio del gioco
#   lampo, scossa, schegge          niente di tutto questo
#   uno solo che colpisce           due che si avvicinano
#
#   filo     su una fascia chiara i due si guardano, un filo li unisce
#            ondeggiando e al centro si fa il nodo: il rombo del gioco
#   alba     un sole sale dietro l'orizzonte, e i due ci camminano incontro
#   anello   due meta' d'anello scivolano una verso l'altra e si chiudono
#            intorno ai due (l'anello aperto del mon, che qui si chiude)
#
# Ognuna sullo scontro vero, a riposo; un secondo e mezzo e poco piu', e come
# la Mattanza un clic la salterebbe. Al posto delle lettere andrebbero gli
# artwork dei due: chi media e la creatura.
#
#   ./prove/film_bond.sh            le gira tutte in scatti/proposte_bond/
#   nell'editor: ProposteBond.tscn, F6 (fa il filo)

const PARTE := 0.6        # quando comincia, dentro il film
const ASSESTAMENTO := 90

var scena: Node
var nome := "filo"
var tempo := -1.0
var legame: Legame


func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	if argomenti.size() > 1 and String(argomenti[0]) == "film":
		nome = String(argomenti[1])
	GameState.nuova_partita()
	GameState.party = ["anonimo", "veronica"]
	GameState.nemici_combattimento = ["marionetta"]
	scena = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scena)
	for i in ASSESTAMENTO:
		await get_tree().process_frame
	scena.set_process(false)
	scena.voce.coda.clear()
	scena.campo.evidenzia(scena.combattenti, scena.combattenti[0])
	scena.menu.principale()
	var sopra := CanvasLayer.new()
	sopra.layer = 20
	add_child(sopra)
	legame = Legame.new()
	legame.stile = nome
	legame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sopra.add_child(legame)
	tempo = 0.0
	print("INIZIO_FILM ", Engine.get_frames_drawn())


func _process(delta: float) -> void:
	if tempo < 0.0:
		return
	tempo += delta
	legame.orologio = tempo - PARTE
	legame.queue_redraw()
	if tempo > PARTE + Legame.DURA + 1.0:
		get_tree().quit()


class Legame extends Control:
	const DURA := 1.85
	const CREMA := Color("#f4ead9")
	const ORO := Color("#f6c560")
	const NERO := Color("#0b0908")
	var stile := "filo"
	var orologio := -1.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	# --- le curve morbide: comincia piano e finisce piano ---
	static func morbido(u: float) -> float:
		return 0.5 - 0.5 * cos(PI * clampf(u, 0.0, 1.0))

	func fase(da: float, quanto: float) -> float:
		return morbido((orologio - da) / quanto)

	func uscita() -> float:
		# tutto se ne va insieme, piano, alla fine
		return 1.0 - fase(DURA - 0.35, 0.35)

	func _draw() -> void:
		if orologio < 0.0 or orologio > DURA:
			return
		match stile:
			"filo":
				disegna_filo()
			"alba":
				disegna_alba()
			"anello":
				disegna_anello()

	func parola(testo: String, centro: Vector2, corpo: int, tinta: Color) -> void:
		var font := Caratteri.titolo()
		var largo := font.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
		draw_string(font, centro + Vector2(-largo * 0.5, corpo * 0.35), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, tinta)

	func rombo(centro: Vector2, largo: float, tinta: Color) -> void:
		draw_colored_polygon(PackedVector2Array([centro + Vector2(0, -largo * 0.65), centro + Vector2(largo * 0.5, 0),
				centro + Vector2(0, largo * 0.65), centro + Vector2(-largo * 0.5, 0)]), tinta)

	# --- IL FILO ------------------------------------------------------------
	func disegna_filo() -> void:
		var w := size.x
		var h := size.y
		var via := uscita()
		draw_rect(Rect2(Vector2.ZERO, size), Color(NERO, 0.35 * fase(0.0, 0.3) * via))
		# la fascia chiara entra piano da sinistra, dritta
		var entra := fase(0.0, 0.4)
		var fascia := Rect2(Vector2(-w + w * entra + w * 0.1 * (1.0 - via), h * 0.32), Vector2(w, h * 0.36))
		draw_rect(fascia, Color(CREMA, via))
		draw_rect(Rect2(fascia.position - Vector2(0, 8), Vector2(w, 4)), Color(Stile.colore("manifesto"), via))
		draw_rect(Rect2(fascia.position + Vector2(0, fascia.size.y + 4), Vector2(w, 4)), Color(Stile.colore("manifesto"), via))
		# i due, uno per parte, che salgono appena
		var c1 := fase(0.25, 0.35)
		parola("A", Vector2(w * 0.2, h * 0.52 - 12.0 * c1), int(h * 0.24), Color(Stile.colore("manifesto"), c1 * via))
		parola("M", Vector2(w * 0.8, h * 0.52 - 12.0 * c1), int(h * 0.24), Color(NERO, c1 * via))
		# il filo che li unisce, ondeggiando
		var tira := fase(0.5, 0.5)
		var punti := PackedVector2Array()
		var da := Vector2(w * 0.2 + h * 0.1, h * 0.5)
		var a := Vector2(w * 0.8 - h * 0.1, h * 0.5)
		for k in 61:
			var u := float(k) / 60.0
			if u > tira:
				break
			punti.append(da.lerp(a, u) + Vector2(0, sin(u * TAU * 1.5) * 20.0 * (1.0 - absf(u - 0.5) * 1.2)))
		if punti.size() > 1:
			draw_polyline(punti, Color(Stile.colore("manifesto"), via), 9.0, true)
		# al centro si fa il nodo: il rombo del gioco, e una luce che si allarga
		var nodo := fase(1.0, 0.3)
		if nodo > 0.0:
			var centro := (da + a) * 0.5
			for giro in 2:
				var onda := clampf((orologio - 1.0 - giro * 0.35) / 0.7, 0.0, 1.0)
				if onda > 0.0:
					draw_arc(centro, lerpf(20.0, 80.0, onda), 0.0, TAU, 48, Color(ORO, 0.5 * (1.0 - onda) * via), 3.0, true)
			rombo(centro, 44.0 * (nodo + 0.15 * sin(PI * nodo)), Color(Stile.colore("manifesto"), via))
		var scritta := fase(1.0, 0.3)
		parola("BOND", Vector2(w * 0.5, h * 0.4 - 8.0 * scritta), int(h * 0.075), Color(NERO, scritta * via))

	# --- L'ALBA -------------------------------------------------------------
	func disegna_alba() -> void:
		var w := size.x
		var h := size.y
		var via := uscita()
		draw_rect(Rect2(Vector2.ZERO, size), Color(Color("#2a1a10"), 0.45 * fase(0.0, 0.3) * via))
		# il sole sale, coi raggi che girano piano
		var sale := fase(0.0, 0.8)
		var centro := Vector2(w * 0.5, lerpf(h * 1.0, h * 0.6, sale))
		var r := h * 0.3
		for k in 16:
			var ang := TAU * float(k) / 16.0 + orologio * 0.18
			var largo := 0.07
			draw_colored_polygon(PackedVector2Array([centro + Vector2.from_angle(ang - largo) * r * 1.12,
					centro + Vector2.from_angle(ang) * r * 2.1, centro + Vector2.from_angle(ang + largo) * r * 1.12]),
					Color(ORO, 0.28 * sale * via))
		draw_circle(centro, r, Color(ORO, via), true, -1.0, true)
		for anello in 3:
			draw_arc(centro, r * (0.45 + 0.17 * anello), 0.0, TAU, 64, Color(CREMA, 0.35 * via), 3.0, true)
		# l'orizzonte sale dal basso, dritto
		var orizzonte := h * lerpf(1.0, 0.68, fase(0.1, 0.4))
		draw_rect(Rect2(Vector2(0, orizzonte), Vector2(w, h)), Color(NERO, via))
		# i due camminano uno verso l'altro sull'orizzonte, e la parola e' nel sole
		var vicini := fase(0.35, 0.9)
		var c1 := fase(0.25, 0.3)
		parola("A", Vector2(lerpf(w * 0.16, w * 0.42, vicini), orizzonte + h * 0.085), int(h * 0.15), Color(Stile.colore("manifesto"), c1 * via))
		parola("M", Vector2(lerpf(w * 0.84, w * 0.58, vicini), orizzonte + h * 0.085), int(h * 0.15), Color(CREMA, c1 * via))
		var scritta := fase(1.0, 0.3)
		parola("BOND", centro - Vector2(0, r * 0.25 + 6.0 * scritta), int(h * 0.085), Color(NERO, scritta * via))

	# --- L'ANELLO -----------------------------------------------------------
	func disegna_anello() -> void:
		var w := size.x
		var h := size.y
		var via := uscita()
		draw_rect(Rect2(Vector2.ZERO, size), Color(CREMA, 0.9 * fase(0.0, 0.3) * via))
		var centro := Vector2(w * 0.5, h * 0.46)
		var r := h * 0.27
		# le due meta' scivolano una verso l'altra e si chiudono
		var chiude := fase(0.15, 0.7)
		var stacco := w * 0.36 * (1.0 - chiude)
		var unite := clampf((orologio - 0.85) / 0.45, 0.0, 1.0)
		var spesso := h * 0.04 * (1.0 + 0.6 * sin(PI * unite))
		draw_arc(centro - Vector2(stacco, 0), r, PI * 0.5, PI * 1.5, 48, Color(Stile.colore("manifesto"), via), spesso, true)
		draw_arc(centro + Vector2(stacco, 0), r, -PI * 0.5, PI * 0.5, 48, Color(NERO, via), spesso, true)
		if unite > 0.0:
			draw_arc(centro, r * lerpf(1.0, 1.5, unite), 0.0, TAU, 64, Color(ORO, 0.45 * (1.0 - unite) * via), 4.0, true)
		# dentro, i due fianco a fianco
		var c1 := fase(0.5, 0.35)
		parola("A", centro + Vector2(-r * 0.36, -4.0 * c1), int(h * 0.16), Color(Stile.colore("manifesto"), c1 * via))
		parola("M", centro + Vector2(r * 0.36, -4.0 * c1), int(h * 0.16), Color(NERO, c1 * via))
		var scritta := fase(0.9, 0.3)
		parola("BOND", Vector2(w * 0.5, h * 0.84 - 8.0 * scritta), int(h * 0.08), Color(NERO, scritta * via))
