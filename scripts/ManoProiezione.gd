class_name ManoProiezione
extends RefCounted

# LA MANO SULLA PROIEZIONE. Bru: «possiamo far manipolare un po' di piu' la
# mappa all'utente come se fosse un piano 3d? non troppo pero', il giusto per
# visualizzare al meglio le varie parti e aggiungere uno zoom in zoom out ma
# non esageriamo con lo zoom».
#
# E' quello che il giocatore aggiunge all'inquadratura che decide il gioco
# (riposo, scelta, caduta): quanto ha girato, quanto ha inclinato, quanto si e'
# avvicinato e verso dove. Sempre dentro limiti stretti (stile.json,
# "proiezione" -> "mano"): si guarda meglio, non ci si perde.
#   - trascinare sul vuoto gira (in orizzontale) e inclina (in verticale)
#   - la rotella, il pizzico sul trackpad o Pag su/giu' avvicinano, verso il
#     punto sotto il cursore: avvicinandosi a una frattura si va li'
#   - Q/E girano, R/F inclinano, la levetta destra del pad fa le due cose
#   - doppio clic sul vuoto, o Inizio, ricentra
# I comandi da tastiera e da pad sono azioni del progetto (project.godot,
# "mappa_..."): si cambiano dall'editor come tutti gli altri.
# Col movimento ridotto la mano resta: e' il giocatore che muove, non il gioco;
# solo, arriva subito invece di scivolare.

const PREDEFINITI := {"giro": 0.75, "su": 30.0, "giu": 14.0, "vicino": 0.62, "lontano": 1.2, "spinta": 7.0}
const SOGLIA := 4.0          # pixel prima che un clic diventi un trascinamento
const PASSO_ROTELLA := 0.9   # ogni scatto di rotella moltiplica la distanza per questo

var giro := 0.0              # radianti in piu' rispetto all'inquadratura del gioco
var becc := 0.0              # gradi in piu'
var zoom := 1.0              # moltiplica la distanza
var spinta := Vector3.ZERO   # quanto si sposta il centro, verso dove ci si e' avvicinati
var voluto := {"giro": 0.0, "becc": 0.0, "zoom": 1.0, "spinta": Vector3.ZERO}
var premuto := false         # il tasto sinistro e' giu' sul vuoto
var trascinando := false
var da := Vector2.ZERO


static func limiti() -> Dictionary:
	var scritti: Variant = CieloProiezione.dati().get("mano", {})
	var l := PREDEFINITI.duplicate()
	if scritti is Dictionary:
		l.merge(scritti, true)
	return l


func centra() -> void:
	voluto = {"giro": 0.0, "becc": 0.0, "zoom": 1.0, "spinta": Vector3.ZERO}


func azzera() -> void:
	# subito, senza scivolare: chi chiama ha gia' messo la vista dove serve
	centra()
	giro = 0.0
	becc = 0.0
	zoom = 1.0
	spinta = Vector3.ZERO


func gira(di: float, inclina: float) -> void:
	var l := limiti()
	voluto["giro"] = clampf(float(voluto["giro"]) + di, -float(l["giro"]), float(l["giro"]))
	voluto["becc"] = clampf(float(voluto["becc"]) + inclina, -float(l["giu"]), float(l["su"]))


func avvicina(fattore: float, verso: Variant) -> void:
	# fattore < 1 avvicina. 'verso' e' quanto dista dal centro della vista il
	# punto della griglia sotto il cursore (o null): avvicinandosi, il centro
	# scivola verso di lui di quel tanto che lo tiene sotto il cursore, come in
	# una carta geografica
	var l := limiti()
	var prima := float(voluto["zoom"])
	var dopo := clampf(prima * fattore, float(l["vicino"]), float(l["lontano"]))
	if verso is Vector3 and dopo < prima:
		voluto["spinta"] = (voluto["spinta"] as Vector3) + (verso as Vector3) * (1.0 - dopo / prima)
	voluto["zoom"] = dopo
	voluto["spinta"] = (voluto["spinta"] as Vector3).limit_length(spinta_massima(dopo, l))


static func spinta_massima(z: float, l: Dictionary) -> float:
	# da lontano il centro torna al suo posto; piu' vicino, piu' si puo' spostare
	return float(l["spinta"]) * clampf((1.0 - z) / maxf(1.0 - float(l["vicino"]), 0.01), 0.0, 1.0)


func aggiorna(delta: float) -> void:
	# i comandi tenuti premuti, e la vista che raggiunge quella voluta
	var l := limiti()
	var ruota := Input.get_axis("mappa_ruota_sinistra", "mappa_ruota_destra")
	var alza := Input.get_axis("mappa_abbassa", "mappa_alza")
	if ruota != 0.0 or alza != 0.0:
		gira(-ruota * 1.1 * delta, alza * 40.0 * delta)
	var avvicinare := Input.get_axis("mappa_allontana", "mappa_avvicina")
	if avvicinare != 0.0:
		avvicina(pow(0.5, avvicinare * delta), null)
	var k := 1.0 if Movimento.ridotto() else 1.0 - exp(-delta * 9.0)
	giro = lerpf(giro, float(voluto["giro"]), k)
	becc = lerpf(becc, float(voluto["becc"]), k)
	zoom = lerpf(zoom, float(voluto["zoom"]), k)
	spinta = spinta.lerp(voluto["spinta"], k)
	zoom = clampf(zoom, float(l["vicino"]), float(l["lontano"]))


func applica(cam: Dictionary) -> Dictionary:
	# l'inquadratura del gioco, piu' la mano
	var vista := cam.duplicate()
	vista["giro"] = float(cam["giro"]) + giro
	vista["beccheggio"] = float(cam["beccheggio"]) + becc
	vista["distanza"] = float(cam["distanza"]) * zoom
	vista["bersaglio"] = (cam["bersaglio"] as Vector3) + spinta
	return vista


func gestisci(evento: InputEvent, p: Proiezione) -> bool:
	# true se l'evento era per la mano
	if evento is InputEventMouseButton:
		return pulsante(evento as InputEventMouseButton, p)
	if evento is InputEventMouseMotion and premuto:
		var spostato := (evento as InputEventMouseMotion).position - da
		if not trascinando and spostato.length() >= SOGLIA:
			trascinando = true
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		if trascinando:
			var rel := (evento as InputEventMouseMotion).relative
			gira(-rel.x * 0.006, rel.y * 0.18)
			return true
	if evento is InputEventMagnifyGesture:
		avvicina(1.0 / maxf((evento as InputEventMagnifyGesture).factor, 0.01),
				dal_centro(p, (evento as InputEventMagnifyGesture).position))
		return true
	if evento is InputEventPanGesture:
		gira(-(evento as InputEventPanGesture).delta.x * 0.03, (evento as InputEventPanGesture).delta.y * 0.9)
		return true
	if evento.is_action_pressed("mappa_centra"):
		centra()
		return true
	return false


func dal_centro(p: Proiezione, dove: Vector2) -> Variant:
	# dal centro della vista al punto della griglia sotto il cursore, in piano
	var punto: Variant = p.sul_piano(dove)
	if not punto is Vector3:
		return null
	var rel := (punto as Vector3) - ((p.cam["bersaglio"] as Vector3) + (voluto["spinta"] as Vector3))
	return Vector3(rel.x, 0.0, rel.z)


func pulsante(b: InputEventMouseButton, p: Proiezione) -> bool:
	if b.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		if b.pressed:
			var su := b.button_index == MOUSE_BUTTON_WHEEL_UP
			avvicina(PASSO_ROTELLA if su else 1.0 / PASSO_ROTELLA, dal_centro(p, b.position) if su else null)
		return true
	if b.button_index != MOUSE_BUTTON_LEFT:
		return false
	if b.pressed:
		# dalla colonna delle schede non si gira la mappa
		if b.position.x >= SchedaProiezione.X - 8.0:
			return false
		if b.double_click:
			centra()
			return true
		premuto = true
		trascinando = false
		da = b.position
		return true
	var era := trascinando
	premuto = false
	trascinando = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	return era
