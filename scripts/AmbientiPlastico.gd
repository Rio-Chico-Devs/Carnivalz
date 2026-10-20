class_name AmbientiPlastico
extends RefCounted

# OGNI ZONA SOMIGLIA AL SUO POSTO. Bru, guardando il plastico: «volevo solo che
# le parti della mappa somigliassero di più alle ambientazioni tipo nelle
# pianure del risveglio siamo nella natura nella grande magione in una magione
# enorme con ai fianchi i giardini e i laboratori dall'altra parte, nei cunicoli
# deve proprio sembrare cunicoli». Il plastico resta quello (vetro, luce,
# bottoni dei piani, scheda): cambia la forma dei pezzi.
#
# LA FORMA DELLO SPAZIO, NON LE COSE DENTRO. Al primo giro c'erano alberi, erba,
# siepi e finestre; Bru: «non c'era bisogno di mettere alberi ed erbetta, troppi
# dettagli creano confusione, l'importante è avere una resa delle altezze e di
# come è conformato lo spazio, non degli elementi al suo interno». Qui si
# disegnano solo contorni, spessori, quote e passaggi.
#
# L'"ambiente" sta nei dati: sulla mappa della zona quello di tutte le stanze,
# su una stanza quello suo se e' diverso. Ognuno ha la sua stanza e il suo
# modo di andare da una stanza all'altra:
#   edificio     la scatola di sempre, e i corridoi a tubo (la Sede)
#   magione      scatole attaccate una all'altra come le stanze di una casa
#                vera, le porte fra una stanza e l'altra e le scale fra un
#                piano e quello sopra
#   laboratorio  come la magione: un altro edificio
#   giardino     un'aiuola dal contorno regolare, alzata da terra
#   natura       una radura dal bordo storto, alzata da terra; da una all'altra
#                un sentiero che serpeggia (e sale, se sale)
#   cunicoli     una caverna dalla volta storta; da una all'altra una galleria
#                che si allarga e si stringe
# Il "dettaglio" di una stanza (la collina, la fossa, il ponte...) sta in
# ArrediPlastico. "percorsi" sulla mappa dice per dove passa un sentiero che non
# deve tagliare in mezzo a qualcosa: punti in quadratini, come le celle.

const AMBIENTI := ["edificio", "magione", "laboratorio", "giardino", "natura", "cunicoli"]
const ALL_APERTO := ["natura", "giardino"]
const MURATI := ["magione", "laboratorio"]
const ARIA_MURATA := 0.03   # fra due stanze della stessa casa: un muro, non un vicolo
const SCARTO := 0.15        # di quanto una radura esce dalla sua cella, a caso: la natura non sta in fila


static func ambiente_di(stanza: Dictionary, mappa := {}) -> String:
	var zona: Dictionary = mappa if not mappa.is_empty() else GameState.mappa_zona
	return String(stanza.get("ambiente", zona.get("ambiente", "edificio")))


static func aria(stanza: Dictionary) -> float:
	# quanto si ritira una stanza dalla sua cella
	return ARIA_MURATA if ambiente_di(stanza) in MURATI else 0.18


static func scarto(stanza: Dictionary) -> Vector2:
	if not ambiente_di(stanza) in ALL_APERTO:
		return Vector2.ZERO
	var rng := FormePlastico.caso(String(stanza.get("id", "")))
	return Vector2(rng.randf() * 2.0 - 1.0, rng.randf() * 2.0 - 1.0) * SCARTO * PlasticoZona.LATO_CELLA


static func pianta(s: Dictionary) -> Rect2:
	return Rect2(Vector2(s["centro"].x, s["centro"].z) - Vector2(s["misura"].x, s["misura"].z) * 0.5,
			Vector2(s["misura"].x, s["misura"].z))


# --- le stanze ------------------------------------------------------------------

static func monta_stanza(p: PlasticoZona, id_stanza: String, stato: Dictionary) -> ShaderMaterial:
	# monta la stanza e torna il suo pieno (quello che si accende puntandola);
	# tutti i pezzi vanno in p.parti, perche' si accendano insieme
	var dati: Dictionary = p.zona.stanze_per_id.get(id_stanza, {})
	var s: Dictionary = p.scatole[id_stanza]
	var ambiente := ambiente_di(dati)
	if ambiente == "edificio" and String(dati.get("dettaglio", "")) == "":
		return p.volume(s["centro"], s["misura"], Basis(), stato, [s["piano"]])
	var r := pianta(s)
	var quota := float(s["centro"].y) - float(s["misura"].y) * 0.5
	var dettaglio := String(dati.get("dettaglio", ""))
	var forme: Array = []
	if not dettaglio in ArrediPlastico.SENZA_BASE:
		forme = base(id_stanza, ambiente, dettaglio, r, quota, float(s["misura"].y))
	forme.append_array(ArrediPlastico.dettaglio(dettaglio, r, quota, id_stanza, p.altezza))
	var tutte: Array[ShaderMaterial] = []
	for forma: Array in forme:
		tutte.append_array(p.getto(forma[0], forma[1], stato, [s["piano"]], float(forma[2])))
	p.parti[id_stanza] = tutte
	return tutte[0] if not tutte.is_empty() else null


static func base(id_stanza: String, ambiente: String, dettaglio: String, r: Rect2, quota: float, alto: float) -> Array:
	match ambiente:
		"natura":
			return radura(id_stanza, r, quota, false)
		"giardino":
			return radura(id_stanza, r, quota, true)
		"cunicoli":
			return caverna(id_stanza, r, quota, dettaglio)
	# la magione e i laboratori sono scatole: la casa la fanno le stanze attaccate
	var c := FormePlastico.cassa(Vector3(r.get_center().x, quota + alto * 0.5, r.get_center().y), Vector3(r.size.x, alto, r.size.y))
	return [[c[0], c[1], 1.0]]


static func radura(id_stanza: String, r: Rect2, quota: float, giardino: bool) -> Array:
	# IL TERRENO: un contorno morbido (regolare se e' un giardino) alzato da
	# terra quanto basta perche' si veda il suo spessore, con qualche montante
	# sul bordo. Niente dentro: conta la forma, non le cose
	var contorno := FormePlastico.chiazza(r, id_stanza, 0.05 if giardino else 0.16, 3.6 if giardino else 2.2)
	var prato := FormePlastico.prisma(contorno, quota, FormePlastico.piane(contorno.size(), quota + 0.18), 3)
	return [[prato[0], prato[1], 1.25]]


static func caverna(id_stanza: String, r: Rect2, quota: float, dettaglio: String) -> Array:
	# LA CAVERNA: un contorno storto e una volta che sale e scende come la
	# roccia. Una sala scavata (la piazza, le sale) e' piu' regolare
	var scavata := dettaglio in ["sala", "piazza"]
	var contorno := FormePlastico.chiazza(r.grow(-0.04), id_stanza, 0.1 if scavata else 0.32, 3.2 if scavata else 2.0, 16)
	var rng := FormePlastico.caso(id_stanza + "volta")
	var volta := PackedFloat32Array()
	for i in contorno.size():
		volta.append(quota + (0.55 if scavata else 0.32 + rng.randf() * 0.42))
	var roccia := FormePlastico.prisma(contorno, quota, volta, 2 if not scavata else 4)
	return [[roccia[0], roccia[1], 1.1]]


# --- da una stanza all'altra ------------------------------------------------------

static func passo(p: PlasticoZona, a: String, b: String) -> String:
	# COME SI VA DA UNA STANZA ALL'ALTRA: per una galleria se una delle due e'
	# sotto terra, per un sentiero se una e' all'aperto, per una porta o una
	# scala fra due stanze della stessa casa, se no il corridoio di sempre
	var ambienti := [ambiente_di(p.zona.stanze_per_id.get(a, {})), ambiente_di(p.zona.stanze_per_id.get(b, {}))]
	if "cunicoli" in ambienti:
		return "galleria"
	if ambienti[0] in ALL_APERTO or ambienti[1] in ALL_APERTO:
		return "sentiero"
	if ambienti[0] in MURATI and ambienti[1] in MURATI:
		return "porta" if int(p.scatole[a]["piano"]) == int(p.scatole[b]["piano"]) else "scala"
	return "corridoio"


static func corridoio(p: PlasticoZona, a: String, b: String) -> void:
	var sa: Dictionary = p.scatole[a]
	var sb: Dictionary = p.scatole[b]
	var percorso := p.zona.visitata(a) and p.zona.visitata(b)
	var stato := {"tinta": p.tinte["linea"], "pieno": 0.16 if percorso else 0.08, "linea": 0.7 if percorso else 0.38, "pulsa": 0.0}
	var piani := [sa["piano"], sb["piano"]]
	var forma: Array = []
	match passo(p, a, b):
		"galleria":
			forma = FormePlastico.tubo(cammino(p, a, b, 0.24), 0.17, a + b)
		"sentiero":
			forma = FormePlastico.nastro(cammino(p, a, b, 0.02), 0.15)
		"porta", "scala":
			forma = [null, FormePlastico.linee(passaggio(sa, sb)), 1.0]
		_:
			dritto(p, a, b, stato, piani)
			return
	p.getto(forma[0], forma[1], stato, piani)


static func estremo(s: Dictionary, verso: Vector3, sopra: float) -> Vector3:
	# dove il sentiero o la galleria lascia la stanza: sul suo bordo, verso dove va
	var r := pianta(s)
	var quota := float(s["centro"].y) - float(s["misura"].y) * 0.5 + sopra
	var c := Vector3(r.get_center().x, quota, r.get_center().y)
	var d := Vector2(verso.x - c.x, verso.z - c.z)
	if d.length() < 0.001:
		return c
	var fino := minf(r.size.x * 0.5 / maxf(absf(d.normalized().x), 0.001), r.size.y * 0.5 / maxf(absf(d.normalized().y), 0.001))
	var bordo := Vector2(c.x, c.z) + d.normalized() * fino * 0.8
	return Vector3(bordo.x, quota, bordo.y)


static func cammino(p: PlasticoZona, a: String, b: String, sopra: float) -> PackedVector3Array:
	# il sentiero o la galleria: per i punti di "percorsi" se ci sono, se no
	# serpeggiando; sale o scende piano piano se le due stanze stanno a quote diverse
	var sa: Dictionary = p.scatole[a]
	var sb: Dictionary = p.scatole[b]
	var via := punti_di_passaggio(a, b)
	var primo: Vector3 = via[0] if not via.is_empty() else sb["centro"]
	var ultimo: Vector3 = via[via.size() - 1] if not via.is_empty() else sa["centro"]
	var da := estremo(sa, primo, sopra)
	var al := estremo(sb, ultimo, sopra)
	if via.is_empty():
		return FormePlastico.serpeggia(da, al, a + b)
	var punti := PackedVector3Array([da])
	for i in via.size():
		var t := float(i + 1) / float(via.size() + 1)
		punti.append(Vector3(via[i].x, lerpf(da.y, al.y, t), via[i].z))
	punti.append(al)
	return FormePlastico.curva(punti, 5)


static func punti_di_passaggio(a: String, b: String) -> Array[Vector3]:
	var tutti: Dictionary = GameState.mappa_zona.get("percorsi", {})
	var punti: Array = tutti.get("%s|%s" % [a, b], [])
	var al_contrario := punti.is_empty()
	if al_contrario:
		punti = tutti.get("%s|%s" % [b, a], [])
	var fuori: Array[Vector3] = []
	for punto: Array in punti:
		fuori.append(Vector3(float(punto[0]), 0.0, float(punto[1])) * PlasticoZona.LATO_CELLA)
	if al_contrario:
		fuori.reverse()
	return fuori


static func passaggio(sa: Dictionary, sb: Dictionary) -> PackedVector3Array:
	# DENTRO CASA: fra due stanze dello stesso piano una porta nel muro che
	# hanno in comune; fra una e quella sopra, una scala che sale a gradini
	var ra := pianta(sa)
	var rb := pianta(sb)
	var ya := float(sa["centro"].y) - float(sa["misura"].y) * 0.5
	var yb := float(sb["centro"].y) - float(sb["misura"].y) * 0.5
	if absf(ya - yb) < 0.01:
		return porta(ra, rb, ya)
	var sotto := ra if ya < yb else rb
	var sopra := rb if ya < yb else ra
	var comune := sotto.intersection(sopra) if sotto.intersects(sopra) else sotto
	return scala(comune, minf(ya, yb), maxf(ya, yb))


static func porta(ra: Rect2, rb: Rect2, quota: float) -> PackedVector3Array:
	var da := SegniPianta.porta(ra, rb.get_center())
	var al := SegniPianta.porta(rb, ra.get_center())
	var c := (da + al) * 0.5
	var lungo := Vector2(absf(al.y - da.y), absf(al.x - da.x)).normalized()
	if lungo.length() < 0.5:
		lungo = Vector2(0.0, 1.0) if absf(rb.get_center().x - ra.get_center().x) > absf(rb.get_center().y - ra.get_center().y) else Vector2(1.0, 0.0)
	var mezza := lungo * 0.14
	var su := quota + 0.5
	return PackedVector3Array([Vector3(c.x - mezza.x, quota, c.y - mezza.y), Vector3(c.x - mezza.x, su, c.y - mezza.y),
			Vector3(c.x - mezza.x, su, c.y - mezza.y), Vector3(c.x + mezza.x, su, c.y + mezza.y),
			Vector3(c.x + mezza.x, su, c.y + mezza.y), Vector3(c.x + mezza.x, quota, c.y + mezza.y)])


static func scala(dove: Rect2, giu: float, su: float, gradini := 7) -> PackedVector3Array:
	var x0 := dove.position.x + dove.size.x * 0.18
	var x1 := dove.end.x - dove.size.x * 0.18
	var z := dove.position.y + dove.size.y * 0.25
	var punti := PackedVector3Array()
	for k in gradini:
		var x := lerpf(x0, x1, float(k) / float(gradini))
		var y := lerpf(giu, su, float(k) / float(gradini))
		var y_dopo := lerpf(giu, su, float(k + 1) / float(gradini))
		punti.append_array([Vector3(x, y, z), Vector3(x, y_dopo, z), Vector3(x, y_dopo, z),
				Vector3(lerpf(x0, x1, float(k + 1) / float(gradini)), y_dopo, z)])
	return punti


static func dritto(p: PlasticoZona, a: String, b: String, stato: Dictionary, piani: Array) -> void:
	# il corridoio di sempre: da porta a porta; fra due piani, il tratto in piano
	# arriva sopra (o sotto) l'altra stanza e da li' un pozzo scende (o sale)
	var sa: Dictionary = p.scatole[a]
	var sb: Dictionary = p.scatole[b]
	var porta_a := SegniPianta.porta(pianta(sa), pianta(sb).get_center())
	var porta_b := SegniPianta.porta(pianta(sb), pianta(sa).get_center())
	var quota_a := float(sa["centro"].y) - PlasticoZona.ALTEZZA_STANZA * 0.25
	var quota_b := float(sb["centro"].y) - PlasticoZona.ALTEZZA_STANZA * 0.25
	var da_qui := Vector3(porta_a.x, quota_a, porta_a.y)
	var a_li := Vector3(porta_b.x, quota_a, porta_b.y)
	if da_qui.distance_to(a_li) > 0.05:
		tubo(p, da_qui, a_li, PlasticoZona.TUBO, stato, piani)
	if absf(quota_a - quota_b) > 0.05:
		tubo(p, a_li, Vector3(porta_b.x, quota_b, porta_b.y), PlasticoZona.POZZO, stato, piani)


static func tubo(p: PlasticoZona, da_dove: Vector3, a_dove: Vector3, spessore: float, stato: Dictionary, piani: Array) -> void:
	var lungo := da_dove.distance_to(a_dove)
	var asse := (a_dove - da_dove) / lungo
	var su := Vector3.UP if absf(asse.y) < 0.9 else Vector3.FORWARD
	var lato := asse.cross(su).normalized()
	p.volume((da_dove + a_dove) * 0.5, Vector3(lungo, spessore, spessore), Basis(asse, lato.cross(asse), lato), stato, piani)


# --- il pavimento di un piano -------------------------------------------------------

static func lastra(p: PlasticoZona, piano: int) -> void:
	# IL PAVIMENTO DI UN PIANO: in un edificio un rettangolo sottile; dove ci sono
	# prati o caverne il contorno morbido del terreno, e sotto terra tratteggiato
	var quota := float(piano) * p.altezza - 0.02
	var stato := {"tinta": p.tinte["linea"], "pieno": 0.035, "linea": 0.4, "pulsa": 0.0}
	var sue: Array[String] = []
	var aperte := 0
	var scavate := 0
	for id_stanza: String in p.scatole:
		if int(p.scatole[id_stanza]["piano"]) == piano and p.zona.si_vede(id_stanza):
			sue.append(id_stanza)
			var ambiente := ambiente_di(p.zona.stanze_per_id.get(id_stanza, {}))
			aperte += 1 if ambiente in ALL_APERTO else 0
			scavate += 1 if ambiente == "cunicoli" else 0
	if aperte + scavate == 0:
		var r := p.impronta_del_piano(piano)
		p.volume(Vector3(r.get_center().x, quota, r.get_center().y), Vector3(r.size.x, 0.02, r.size.y), Basis(), stato, [piano])
		return
	var punti := PackedVector2Array()
	for id_stanza in sue:
		var r := pianta(p.scatole[id_stanza]).grow(0.55)
		punti.append_array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	var terreno := FormePlastico.smussa(Geometry2D.convex_hull(punti).slice(0, -1), 3)
	var piatto := FormePlastico.prisma(terreno, quota, FormePlastico.piane(terreno.size(), quota))
	var bordo := PackedVector3Array()
	for v in terreno:
		bordo.append(Vector3(v.x, quota, v.y))
	var tratti := FormePlastico.a_tratti(bordo, 0.35, 0.25) if scavate > aperte else FormePlastico.giro(bordo)
	p.getto(piatto[0], FormePlastico.linee(tratti), stato, [piano])
