class_name ManoPlastico
extends Node

# LA MANO SUL PLASTICO (PlasticoZona). Bru, guardandolo la prima volta: «molto
# carino ma va migliorato, anche in termini di interazione e manipolazione».
#
# Prima il plastico usava la mano della mappa stellare (ManoProiezione), che e'
# fatta per non perdersi in un cielo: gira di poco, avvicina di poco, e il
# centro si sposta solo avvicinandosi. Bru l'aveva chiesta cosi' per quella
# («non troppo pero'»); sul plastico voleva dire un modellino che si guarda da
# un lato solo, che non si avvicina abbastanza da leggere una stanza e che non
# si sposta per guardarne un angolo. E si trascinava solo partendo dal vuoto:
# sopra una stanza la pressione se la prendeva la sua porta. Un plastico e' un
# oggetto da tenere in mano, quindi adesso:
#   - TASTO SINISTRO, trascinando: gira e inclina, anche partendo da una
#     stanza. Se la mano si muove il clic diventa un giro, e nella stanza non
#     si entra; se resta ferma, e' un clic e si entra come sempre
#   - TASTO DESTRO O CENTRALE (o il sinistro con Maiusc): sposta il plastico
#     sotto la mano, come una carta sul tavolo
#   - ROTELLA o pizzico: avvicina e allontana tenendo fermo il punto sotto il
#     cursore, fino a una stanza sola
#   - Q/E girano, R/F inclinano, PagSu/PagGiu' avvicinano, W/A/S/D spostano,
#     Z/X passano di piano in piano, Inizio o doppio clic sul vuoto rimettono
#     tutto com'era (azioni "mappa_..." di project.godot)
#   - si gira tutto intorno, senza fine corsa, e si inclina fin quasi a
#     guardarlo dall'alto come una pianta; il centro della vista non esce dal
#     plastico
#   - lasciato andare di slancio gira ancora un poco e si ferma, come un
#     modellino su un piatto girevole (col movimento ridotto no: si ferma dove
#     lo lasci)
# I limiti stanno in stile.json, "plastico" -> "mano". Numeri miei, da provare.

const PREDEFINITI := {"vicino": 0.3, "lontano": 1.5, "basso": 12.0, "alto": 85.0,
		"attrito": 4.0, "slancio": 4.0}
const SOGLIA := 4.0            # pixel prima che un clic diventi un trascinamento
const PASSO_ROTELLA := 0.88    # ogni scatto di rotella moltiplica la distanza per questo
const PRONTEZZA := 14.0        # quanto in fretta la vista raggiunge quella voluta (piu' alto, piu' secca)

var p: PlasticoZona
var giro := 0.0                # radianti in piu' rispetto alla vista di partenza
var becc := 0.0                # gradi in piu'
var zoom := 1.0                # moltiplica la distanza
var spinta := Vector3.ZERO     # di quanto si e' spostato il centro della vista
var voluto := {"giro": 0.0, "becc": 0.0, "zoom": 1.0, "spinta": Vector3.ZERO}
var abbrivio := 0.0            # radianti al secondo che restano dopo averlo lasciato andare
var velocita := 0.0            # quanto stava girando la mano, per l'abbrivio
var ultimo_giro := 0           # quando la mano l'ha girato l'ultima volta (microsecondi)
var base := {}                 # la vista di partenza (PlasticoZona.cam): i limiti si contano da li'
var confini := AABB()          # dove puo' stare il centro della vista: il plastico e un po' d'aria
var presa := MOUSE_BUTTON_NONE # il tasto del mouse che tiene il plastico
var sposto := false            # quella presa lo sposta invece di girarlo
var trascinando := false
var da := Vector2.ZERO


func _init(plastico: PlasticoZona = null) -> void:
	p = plastico


static func limiti() -> Dictionary:
	var l := PREDEFINITI.duplicate()
	var plastico: Variant = Stile.dati.get("plastico", {})
	if plastico is Dictionary and (plastico as Dictionary).get("mano") is Dictionary:
		l.merge((plastico as Dictionary)["mano"], true)
	return l


# --- quanto si muove la vista ---------------------------------------------------

func centra() -> void:
	voluto = {"giro": 0.0, "becc": 0.0, "zoom": 1.0, "spinta": Vector3.ZERO}
	abbrivio = 0.0


func azzera() -> void:
	# subito, senza scivolare
	centra()
	giro = 0.0
	becc = 0.0
	zoom = 1.0
	spinta = Vector3.ZERO


func gira(di: float, inclina: float) -> void:
	# il giro non ha fine corsa; l'inclinazione si', contata dalla vista di partenza
	var l := limiti()
	var partenza := float(base.get("beccheggio", 0.0))
	voluto["giro"] = float(voluto["giro"]) + di
	voluto["becc"] = clampf(float(voluto["becc"]) + inclina, float(l["basso"]) - partenza,
			float(l["alto"]) - partenza)


func gira_a_mano(di: float, inclina: float) -> void:
	# come gira(), e in piu' ci si ricorda quanto in fretta: e' l'abbrivio
	var adesso := Time.get_ticks_usec()
	var passati := clampf(float(adesso - ultimo_giro) / 1000000.0, 1.0 / 240.0, 0.25)
	velocita = lerpf(velocita, di / passati, 0.5)
	ultimo_giro = adesso
	abbrivio = 0.0
	gira(di, inclina)


func lascia_andare() -> void:
	# se la mano era ferma da un attimo il plastico resta fermo: si lascia
	# andare di slancio solo un giro che stava ancora girando
	var fermo := float(Time.get_ticks_usec() - ultimo_giro) / 1000000.0 > 0.08
	var tetto := float(limiti()["slancio"])
	abbrivio = 0.0 if fermo or Movimento.ridotto() else clampf(velocita, -tetto, tetto)
	velocita = 0.0


func avvicina(fattore: float, verso: Variant) -> void:
	# fattore < 1 avvicina. 'verso' va dal centro della vista al punto sotto il
	# cursore (o e' null): il centro scivola verso di lui di quel tanto che lo
	# tiene fermo sotto il cursore, avvicinandosi come allontanandosi
	var l := limiti()
	var prima := float(voluto["zoom"])
	var dopo := clampf(prima * fattore, float(l["vicino"]), float(l["lontano"]))
	if verso is Vector3:
		sposta((verso as Vector3) * (1.0 - dopo / prima))
	voluto["zoom"] = dopo


func sposta(di: Vector3) -> void:
	# il centro della vista non esce dal plastico: spostandolo si guarda un
	# angolo, non il vuoto
	var centro: Vector3 = base.get("bersaglio", Vector3.ZERO)
	var dove: Vector3 = (centro + (voluto["spinta"] as Vector3) + di).clamp(confini.position, confini.end)
	voluto["spinta"] = dove - centro


func guarda(dove: Vector3, quanto_vicino: float, almeno: float) -> void:
	# porta la vista su un punto (il centro di un piano, una stanza), a quella
	# distanza, e da non meno di 'almeno' gradi d'altezza
	voluto["spinta"] = Vector3.ZERO
	sposta(dove - (base.get("bersaglio", Vector3.ZERO) as Vector3))
	var l := limiti()
	voluto["zoom"] = clampf(quanto_vicino, float(l["vicino"]), float(l["lontano"]))
	var partenza := float(base.get("beccheggio", 0.0))
	voluto["becc"] = maxf(float(voluto["becc"]), almeno - partenza)
	gira(0.0, 0.0)   # e dentro i limiti


func per_terra(schermo: Vector2) -> Vector3:
	# uno spostamento a schermo (x a destra, y in giu') portato sul pavimento,
	# per come lo si guarda adesso: in su sullo schermo e' lontano da chi guarda
	var g := float(base.get("giro", 0.0)) + giro
	var destra := Vector3(cos(g), 0.0, -sin(g))
	var verso_di_me := Vector3(sin(g), 0.0, cos(g))
	return destra * schermo.x + verso_di_me * schermo.y


func porta_via(rel: Vector2, per_pixel: float) -> void:
	# il pavimento segue la mano: quello che era sotto il cursore ci resta. Piu'
	# lo si guarda di sbieco, piu' un pixel in verticale e' lungo per terra
	var sbieco := maxf(sin(deg_to_rad(float(base.get("beccheggio", 0.0)) + becc)), 0.3)
	sposta(-per_terra(Vector2(rel.x, rel.y / sbieco)) * per_pixel)


func aggiorna(delta: float) -> void:
	# i tasti tenuti premuti, l'abbrivio, e la vista che raggiunge quella voluta
	var ruota := Input.get_axis("mappa_ruota_sinistra", "mappa_ruota_destra")
	var alza := Input.get_axis("mappa_abbassa", "mappa_alza")
	if ruota != 0.0 or alza != 0.0:
		abbrivio = 0.0
		gira(-ruota * 1.6 * delta, alza * 50.0 * delta)
	var avvicinare := Input.get_axis("mappa_allontana", "mappa_avvicina")
	if avvicinare != 0.0:
		avvicina(pow(0.5, avvicinare * delta), null)
	var passo := Input.get_vector("mappa_sposta_sinistra", "mappa_sposta_destra", "mappa_sposta_su", "mappa_sposta_giu")
	if passo != Vector2.ZERO:
		sposta(per_terra(passo) * float(base.get("distanza", 10.0)) * zoom * 0.7 * delta)
	if abbrivio != 0.0:
		gira(abbrivio * delta, 0.0)
		abbrivio *= exp(-float(limiti()["attrito"]) * delta)
		abbrivio = 0.0 if absf(abbrivio) < 0.02 else abbrivio
	var k := 1.0 if Movimento.ridotto() else 1.0 - exp(-delta * PRONTEZZA)
	giro = lerpf(giro, float(voluto["giro"]), k)
	becc = lerpf(becc, float(voluto["becc"]), k)
	zoom = lerpf(zoom, float(voluto["zoom"]), k)
	spinta = spinta.lerp(voluto["spinta"], k)


func applica(cam: Dictionary) -> Dictionary:
	# la vista di partenza, piu' la mano
	var vista := cam.duplicate()
	vista["giro"] = float(cam["giro"]) + giro
	vista["beccheggio"] = float(cam["beccheggio"]) + becc
	vista["distanza"] = float(cam["distanza"]) * zoom
	vista["bersaglio"] = (cam["bersaglio"] as Vector3) + spinta
	return vista


# --- il mouse e i tasti ---------------------------------------------------------

func _input(evento: InputEvent) -> void:
	# TUTTO IL MOUSE PASSA DI QUI, anche sopra le stanze: le porte sono bottoni
	# veri, e un trascinamento partito da una porta al plastico non arriverebbe
	# mai. Un clic che resta un clic va alla sua porta come sempre; qui ci si
	# prende solo la rotella e il trascinamento
	if p == null or not p.is_visible_in_tree() or p.cam.is_empty():
		return
	if evento is InputEventMouseButton:
		pulsante(evento as InputEventMouseButton)
	elif evento is InputEventMouseMotion and presa != MOUSE_BUTTON_NONE:
		muovi(evento as InputEventMouseMotion)
	elif evento is InputEventMagnifyGesture and e_per_me():
		var pizzico := evento as InputEventMagnifyGesture
		avvicina(1.0 / maxf(pizzico.factor, 0.01), p.verso_il_cursore(locale(pizzico.position)))
		get_viewport().set_input_as_handled()
	elif evento is InputEventPanGesture and e_per_me():
		var due_dita := evento as InputEventPanGesture
		gira(-due_dita.delta.x * 0.03, due_dita.delta.y * 0.9)
		get_viewport().set_input_as_handled()


func pulsante(b: InputEventMouseButton) -> void:
	if b.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		if b.pressed and e_per_me():
			var su := b.button_index == MOUSE_BUTTON_WHEEL_UP
			avvicina(PASSO_ROTELLA if su else 1.0 / PASSO_ROTELLA, p.verso_il_cursore(locale(b.position)))
			get_viewport().set_input_as_handled()
		return
	if not b.pressed:
		if b.button_index == presa:
			lascia()
		return
	if presa != MOUSE_BUTTON_NONE or not e_per_me() \
			or b.button_index not in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		return
	if b.button_index == MOUSE_BUTTON_LEFT and b.double_click \
			and get_viewport().gui_get_hovered_control() == p:
		p.ricentra()
		return
	presa = b.button_index
	sposto = b.button_index != MOUSE_BUTTON_LEFT or b.shift_pressed
	trascinando = false
	da = b.position


func muovi(m: InputEventMouseMotion) -> void:
	# IL TASTO NON E' PIU' GIU': lo si e' lasciato dove questa mano non sentiva
	# (in pausa, col plastico nascosto, fuori dalla finestra). Prima la presa
	# restava, e il plastico girava dietro al mouse a tasti alzati finche' non
	# si cliccava di nuovo
	if not m.button_mask & (1 << (presa - 1)):
		lascia()
		return
	if not trascinando:
		if m.position.distance_to(da) < SOGLIA:
			return
		trascinando = true
		annulla_il_clic()
		Input.set_default_cursor_shape(Input.CURSOR_MOVE if sposto else Input.CURSOR_DRAG)
	if sposto:
		porta_via(m.relative, p.per_pixel())
	else:
		gira_a_mano(-m.relative.x * 0.008, m.relative.y * 0.25)
	get_viewport().set_input_as_handled()


func lascia() -> void:
	if trascinando:
		if not sposto:
			lascia_andare()
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	presa = MOUSE_BUTTON_NONE
	trascinando = false


func _notification(cosa: int) -> void:
	# la pausa (o l'uscita dalla schermata) a meta' di un trascinamento: si
	# lascia subito, e il cursore torna la freccia invece di restare la manina
	# sopra il menu di pausa
	if (cosa == NOTIFICATION_PAUSED or cosa == NOTIFICATION_EXIT_TREE) and presa != MOUSE_BUTTON_NONE:
		lascia()


func annulla_il_clic() -> void:
	# IL CLIC CHE DIVENTA UN GIRO NON ENTRA. La porta su cui si e' premuto
	# aspetta il rilascio per dire «premuta»; spegnerla e riaccenderla le fa
	# dimenticare la pressione (BaseButton.set_disabled), e il rilascio non
	# porta piu' da nessuna parte
	for porta in p.zona.strato_bottoni.get_children():
		var b := porta as BaseButton
		if b != null and not b.disabled:
			b.disabled = true
			b.disabled = false


func e_per_me() -> bool:
	# il mouse e' sul plastico o su una sua stanza, e non su qualcosa che gli
	# sta sopra: la Guida, l'icona del menu, i bottoni dei piani
	var sotto := get_viewport().gui_get_hovered_control()
	return sotto == p or (sotto is PortaStanza and p.zona.strato_bottoni.is_ancestor_of(sotto))


func locale(dove: Vector2) -> Vector2:
	return p.get_global_transform_with_canvas().affine_inverse() * dove


func _unhandled_input(evento: InputEvent) -> void:
	if p == null or not p.is_visible_in_tree():
		return
	if evento.is_action_pressed("mappa_centra"):
		p.ricentra()
	elif evento.is_action_pressed("mappa_piano_su"):
		p.cambia_piano(1)
	elif evento.is_action_pressed("mappa_piano_giu"):
		p.cambia_piano(-1)
	else:
		return
	get_viewport().set_input_as_handled()
