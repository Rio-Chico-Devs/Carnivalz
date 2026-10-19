extends RefCounted

# QUELLO CHE LA MAPPA SA, per le tre proposte (prove/ProposteMappa.gd). Provvisorio
# come loro: se ne va quando Bru ne sceglie una e la mappa vera nasce da li'.
#
# Le regole sono quelle del gioco, chieste al gioco: dove si va lo dice
# IngressoNodo.raggiungibile, cosa si sa GameState, la pianta di una stanza
# PlasticoZona.pianta_di. Qui si mettono in fila in un modo solo, cosi' le tre
# proposte disegnano la stessa zona con le stesse informazioni e si confrontano
# per come la dicono, non per cosa dicono.
#
# GLI STATI DI UNA STANZA, dal piu' forte al piu' debole:
#   qui         ci sei
#   vicina      ci arrivi adesso con un clic (confina con la tua)
#   vista       ci sei stato, ma da qui non ci arrivi
#   nota        la storia te l'ha nominata, non ci sei mai stato
#   intravista  confina con un posto noto: sai che c'e' qualcosa, non cosa
#   chiusa      ci arrivi davanti, e la porta non si apre

var nome_zona := ""
var piani := {}                    # piano -> il suo nome
var stanze: Array[Dictionary] = [] # {id, nome, piano, pianta, icona, cosa, stato, visitata, chi}
var per_id := {}
var corridoi: Array[Dictionary] = []   # {a, b, percorso, da_qui}
var qui := ""
var piano_qui := 0
var tutta := Rect2()               # la pianta di tutti i piani insieme, in unita' del modellino
var lato := 1.0                    # una stanza tipo, in unita': per misurare il resto


func leggi(chi_c_e := {}) -> void:
	var m := GameState.mappa_zona
	nome_zona = String(m.get("nome", ""))
	piani.clear()
	var nomi: Dictionary = m.get("piani", {})
	for chiave: Variant in nomi:
		piani[int(String(chiave))] = String(nomi[chiave])
	qui = GameState.nodo_corrente
	stanze.clear()
	per_id.clear()
	var lati: Array[float] = []
	var prima := true
	for s: Dictionary in m.get("stanze", []):
		var id_stanza := String(s.get("id", ""))
		var stato := stato_di(id_stanza)
		if stato == "":
			continue
		var pianta := PlasticoZona.pianta_di(s)
		var voce := {"id": id_stanza, "nome": nome_di(id_stanza, s, stato), "piano": int(s.get("piano", 0)),
				"pianta": pianta, "icona": String(s.get("icona", "")) if stato in ["qui", "vicina", "vista"] or String(s.get("icona", "")) == "obiettivo" else "",
				"cosa": String(s.get("cosa", "")), "stato": stato, "visitata": id_stanza in GameState.nodi_visitati,
				"chi": chi_c_e.get(id_stanza, [])}
		stanze.append(voce)
		per_id[id_stanza] = voce
		lati.append(minf(pianta.size.x, pianta.size.y))
		tutta = pianta if prima else tutta.merge(pianta)
		prima = false
		if not piani.has(voce["piano"]):
			piani[voce["piano"]] = "Piano %d" % voce["piano"]
	lati.sort()
	lato = lati[floori(lati.size() / 2.0)] if not lati.is_empty() else 1.0
	piano_qui = int(per_id.get(qui, {}).get("piano", 0))
	corridoi.clear()
	for coppia: Array in GameState.collegamenti_aperti():
		var a := String(coppia[0])
		var b := String(coppia[1])
		if per_id.has(a) and per_id.has(b):
			corridoi.append({"a": a, "b": b, "percorso": per_id[a]["visitata"] and per_id[b]["visitata"],
					"da_qui": a == qui or b == qui})


func stato_di(id_stanza: String) -> String:
	if id_stanza == GameState.nodo_corrente:
		return "qui"
	var visitata := id_stanza in GameState.nodi_visitati
	var nota := GameState.stanza_sbloccata(id_stanza)
	if not (visitata or nota or intravista(id_stanza)):
		return ""
	if IngressoNodo.chiusa_a_chiave(id_stanza):
		return "chiusa"
	if IngressoNodo.raggiungibile(id_stanza):
		return "vicina"
	if visitata:
		return "vista"
	return "nota" if nota else "intravista"


func intravista(id_stanza: String) -> bool:
	for coppia: Array in GameState.collegamenti_aperti():
		for k in 2:
			var altra := String(coppia[1 - k])
			if String(coppia[k]) == id_stanza and (altra in GameState.nodi_visitati or GameState.stanza_sbloccata(altra)):
				return true
	return false


func nome_di(id_stanza: String, s: Dictionary, stato: String) -> String:
	if stato == "chiusa" or not (id_stanza in GameState.nodi_visitati or GameState.stanza_sbloccata(id_stanza)):
		return "?"
	return String(s.get("nome", id_stanza))


func del_piano(piano: int) -> Array[Dictionary]:
	var sue: Array[Dictionary] = []
	for s in stanze:
		if int(s["piano"]) == piano:
			sue.append(s)
	return sue


func piani_in_ordine() -> Array[int]:
	# dal piu' alto al piu' basso, come si leggono su un cartello d'ascensore
	var tutti: Array[int] = []
	for piano: int in piani:
		if not del_piano(piano).is_empty():
			tutti.append(piano)
	tutti.sort()
	tutti.reverse()
	return tutti


func nome_del_piano(piano: int) -> String:
	# un piano di cui non sai il nome di nessuna stanza e' un «?», come le sue stanze
	for s in del_piano(piano):
		if String(s["nome"]) != "?":
			return String(piani.get(piano, "?"))
	return "?"


func impronta(piano: int) -> Rect2:
	var r := Rect2()
	var primo := true
	for s in del_piano(piano):
		r = s["pianta"] if primo else r.merge(s["pianta"])
		primo = false
	return r.grow(lato * 0.35)


func uscite(id_stanza: String) -> Array[Dictionary]:
	# dove si va da una stanza: le confinanti che si vedono, con il loro piano
	var fuori: Array[Dictionary] = []
	for c in corridoi:
		var altra := ""
		if String(c["a"]) == id_stanza:
			altra = String(c["b"])
		elif String(c["b"]) == id_stanza:
			altra = String(c["a"])
		if altra != "":
			fuori.append(per_id[altra])
	return fuori


func porta(da: Rect2, verso: Vector2) -> Vector2:
	# il punto del bordo di una stanza da cui esce il corridoio verso un'altra
	return SegniPianta.porta(da, verso)


func conta_visitate() -> int:
	var n := 0
	for s in stanze:
		if s["visitata"]:
			n += 1
	return n
