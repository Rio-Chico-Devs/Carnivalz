class_name SegretiVuoto
extends Control

# I SEGRETI DEL VUOTO. Bru: «sarebbe possibile nascondere degli easter egg?
# tipo se navighi con cursore nel vuoto, e passi sopra un determinato punto
# esce un puntino esclamativo, potrebbero essere meteoriti, inizi di frattura
# o segnali audio».
#
# Un segreto (mappa.json, "segreti" del punto) non si vede e col Tab non si
# raggiunge: c'e' solo un punto sulla griglia. Quando il cursore ci passa a
# meno di FIUTO pixel compare il «!», e il segreto diventa un corpo come gli
# altri della proiezione: si sceglie, la scheda lo racconta, si conferma e si
# prende quello che c'e' (tazo, un oggetto, un flag). Preso, non torna piu'.
#   - meteorite: un sasso a retino
#   - crepa: l'inizio di una frattura, una lente piccola e spenta
#   - segnale: non si vede, si SENTE. Un bip che accelera quanto piu' il
#     cursore si avvicina, e un'eco intorno al cursore per chi non ha l'audio
# Prima di essere trovati, meteoriti e crepe mandano ogni tanto un luccichio:
# chi guarda bene li vede. I numeri sono miei, da provare.

signal trovato(id: String)
signal preso(id: String)

const FIUTO := 30.0           # quanto vicino deve passare il cursore, in pixel
const ASCOLTO := 260.0        # da quanto lontano si sente un segnale
const BIP_LENTO := 1.1        # secondi fra due bip al limite dell'ascolto...
const BIP_SVELTO := 0.14      # ...e proprio sopra
const OGNI_LUCCICHIO := 5.0   # secondi fra due luccichii dello stesso segreto
const PREFISSO := "segreto_"  # il flag che ricorda un segreto preso
const COME := {
	"meteorite": {"forma": "sfera", "raggio": 0.16, "spento": 0.45, "parola": "METEORITE", "azione": "Raccogli"},
	"crepa": {"forma": "lente", "raggio": 0.2, "spento": 0.55, "parola": "INIZIO DI FRATTURA", "azione": "Esamina"},
	"segnale": {"forma": "nessuna", "raggio": 0.14, "spento": 0.0, "parola": "SEGNALE", "azione": "Registra"},
}

var proiezione: Proiezione
var nascosti: Array[Dictionary] = []   # {"voce": la voce in mappa.json, "xz": dove sta sulla griglia}
var trovati := {}                      # id -> la sua voce in mappa.json
var al_prossimo_bip := 0.0
var bip := 0                           # quanti ne ha suonati: le prove li contano
var eco := 0.0
var t := 0.0


static func preso_gia(id: String) -> bool:
	return GameState.ha_flag(PREFISSO + id)


func prepara(p: Proiezione) -> void:
	proiezione = p
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func nascondi(voce: Dictionary, xz: Vector2) -> void:
	if not preso_gia(String(voce.get("id", ""))):
		nascosti.append({"voce": voce, "xz": xz})


func dove(nascosto: Dictionary, lista: Array[Vector4]) -> Vector2:
	var xz: Vector2 = nascosto["xz"]
	return proiezione.sullo_schermo(Vector3(xz.x, proiezione.altezza(xz, lista) * 0.5 + 0.2, xz.y))


func _process(delta: float) -> void:
	t += delta
	eco = maxf(eco - delta * 2.0, 0.0)
	al_prossimo_bip -= delta
	if proiezione == null or not proiezione.pronta:
		return
	var cursore := proiezione.cursore()
	var lista := proiezione.pozzi()
	var vicino := INF   # il segnale nascosto piu' vicino al cursore
	for n in range(nascosti.size() - 1, -1, -1):
		var s := dove(nascosti[n], lista)
		var distanza := s.distance_to(cursore)
		# dietro la colonna delle schede non si cerca: non si vedrebbe niente
		if distanza <= FIUTO and s.x < SchedaProiezione.X - 8.0:
			svela(nascosti.pop_at(n))
		elif String(nascosti[n]["voce"].get("tipo", "")) == "segnale":
			vicino = minf(vicino, distanza)
	ascolta(vicino)
	queue_redraw()


static func intervallo(distanza: float) -> float:
	# piu' vicino, piu' svelto: come un rilevatore
	return lerpf(BIP_SVELTO, BIP_LENTO, clampf(distanza / ASCOLTO, 0.0, 1.0))


func ascolta(vicino: float) -> void:
	if vicino > ASCOLTO:
		return
	# avvicinandosi di colpo non si aspetta il bip lento di prima
	al_prossimo_bip = minf(al_prossimo_bip, intervallo(vicino))
	if al_prossimo_bip > 0.0:
		return
	AudioManager.tocco("segnale")
	bip += 1
	eco = 1.0 - clampf(vicino / ASCOLTO, 0.0, 1.0) * 0.6
	al_prossimo_bip = intervallo(vicino)


func svela(nascosto: Dictionary) -> void:
	var voce: Dictionary = nascosto["voce"]
	var id := String(voce.get("id", ""))
	var tipo := String(voce.get("tipo", "meteorite"))
	var come: Dictionary = COME.get(tipo, COME["meteorite"])
	trovati[id] = voce
	var c := proiezione.aggiungi({"id": id, "nome": String(voce.get("nome", "?")), "tipo": "segreto",
			"xz": nascosto["xz"], "profondita": 0.0, "raggio": come["raggio"], "forma": come["forma"],
			"spento": come["spento"], "segnale": true, "chiama": tipo == "segnale", "stato": "trovato",
			"epoca": String(voce.get("epoca", "")), "testo": String(voce.get("descrizione", "")),
			"azione": come["azione"], "attiva": true, "apertura": 1.0 if Movimento.ridotto() else 0.0,
			"dati": [["TIPO", come["parola"]], ["CONTIENE", contenuto(voce.get("premio", {}))]]})
	if not Movimento.ridotto():
		var esce := create_tween()
		esce.tween_method(func(v: float) -> void: c["apertura"] = v, 0.0, 1.0, 0.5)
	AudioManager.interfaccia("scoperta")
	proiezione.punta(id)
	trovato.emit(id)


static func contenuto(premio: Dictionary) -> String:
	var parti := PackedStringArray()
	if int(premio.get("tazo", 0)) > 0:
		parti.append("%d TAZO" % int(premio["tazo"]))
	var id_oggetto := String(premio.get("oggetto", ""))
	if id_oggetto != "":
		parti.append(String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)).to_upper())
	return " · ".join(parti) if not parti.is_empty() else "UN INDIZIO"


func prendi(id: String) -> bool:
	# quello che c'e' dentro, una volta sola. L'oggetto per primo: se lo
	# zaino e' pieno non si prende niente, e il segreto resta li'
	var voce: Dictionary = trovati.get(id, {})
	if voce.is_empty() or preso_gia(id):
		return false
	var premio: Dictionary = voce.get("premio", {})
	var id_oggetto := String(premio.get("oggetto", ""))
	if id_oggetto != "" and not GameState.aggiungi_oggetto(id_oggetto):
		AudioManager.interfaccia("errore")
		proiezione.corpo(id)["azione"] = "Zaino pieno"
		return false
	GameState.modifica_tazo(int(premio.get("tazo", 0)))
	if String(premio.get("flag", "")) != "":
		GameState.imposta_flag(String(premio["flag"]))
	GameState.imposta_flag(PREFISSO + id)
	AudioManager.interfaccia("raccolta")
	var c := proiezione.corpo(id)
	c["stato"] = "preso"
	c["attiva"] = false
	c["segnale"] = false
	c["azione"] = "Gia' preso"
	preso.emit(id)
	return true


func _draw() -> void:
	if proiezione == null or not proiezione.pronta:
		return
	var carta: Color = proiezione.tinte["carta"]
	if eco > 0.0:
		# l'eco del segnale intorno al cursore: dice "vicino", non "dove"
		var r := 12.0 + (1.0 - eco) * 26.0
		draw_arc(proiezione.cursore(), r, 0, TAU, 32, Color(proiezione.tinte["segnale"], eco * 0.7), 1.5, true)
	if Movimento.ridotto():
		return
	var lista := proiezione.pozzi()
	for nascosto in nascosti:
		var voce: Dictionary = nascosto["voce"]
		if String(voce.get("tipo", "")) == "segnale":
			continue
		# un luccichio breve ogni OGNI_LUCCICHIO secondi, ognuno al suo momento
		var fase := fmod(t + float(hash(String(voce.get("id", ""))) % 100) / 20.0, OGNI_LUCCICHIO)
		var k := sin(clampf(fase / 0.6, 0.0, 1.0) * PI)
		if k <= 0.0:
			continue
		var s := dove(nascosto, lista)
		draw_line(s - Vector2(5 * k, 0), s + Vector2(5 * k, 0), Color(carta, k * 0.8), 1.0, true)
		draw_line(s - Vector2(0, 5 * k), s + Vector2(0, 5 * k), Color(carta, k * 0.8), 1.0, true)
		draw_circle(s, 1.2, Color(carta, k))
