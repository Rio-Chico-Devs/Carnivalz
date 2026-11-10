extends RefCounted
# IL GENERATORE DEI MONDI DA ESPLORARE (prove/MondoProva.gd). Da un numero (il
# seme) e da un bioma esce un pianeta intero, sempre lo stesso per lo stesso
# seme. Provvisorio, come la prova che lo usa.
#
# Bru: «mi piacerebbe che esplorassi come in the legend of zelda, i vecchi
# giochi ... ma con la differenza che è solo un gioco di progressi, dove rendi
# autonome le zone spendendo risorse fino a colonizzare tutto il pianeta».
# Poi: «dobbiamo concentrarci per generare le mappe e i mondi da esplorare che
# siano coerenti con il nostro stile».
#
# COME E' FATTO UN PIANETA
#   - un'isola: acqua intorno, spiagge, prati, sentieri;
#   - divisa in REGIONI dai bordi naturali. Fra due regioni c'e' sempre un
#     confine che non si passa: un fiume, un bosco fitto, i rovi del Carnivalz,
#     o una rupe quando una regione sta piu' in alto dell'altra;
#   - le regioni si aprono in fila, come le stanze di uno Zelda: fra una e la
#     successiva c'e' UN passaggio, e si paga (un ponte da riparare, i rovi da
#     bruciare, una scala da rifare);
#   - ogni regione ha il suo CUORE, un faro dell'Organizzazione spento.
#     Riparato, la regione diventa autonoma: produce da sola, la corruzione se
#     ne va, compaiono le case. Tutti i fari accesi: il pianeta e' colonizzato.
#
# Il controllo (controlla()) prova che il pianeta si puo' finire: da dove si
# atterra si arriva solo nella prima regione, e ogni passaggio pagato apre
# esattamente la regione dopo, e nient'altro.

const ACQUA := 0
const SABBIA := 1
const TERRA := 2
const ERBA := 3
const PRATO := 4       # l'erba alta e scura, a macchie: ci si cammina

const NOMI := {
	"pianure": ["La Conca", "Il Prato dei Sassi", "Bosco Tondo", "La Riva Lunga", "Il Pianoro",
		"Le Tre Querce", "Il Guado", "La Collina Muta", "Il Campo Spento", "La Radura",
		"Il Dosso", "Le Canne"],
	"ardente": ["La Piana Rossa", "Le Agavi", "Il Ferro Nero", "La Conca di Cenere", "Il Pianoro dei Tori",
		"La Sella", "Gli Spuntoni", "Il Passo Caldo", "La Plaza", "Le Braci", "Il Sombrero",
		"La Fornace"],
}

# i confini fra due regioni alla stessa altezza; la rupe viene da sola
const CONFINI := ["fiume", "bosco", "rovi"]

var w := 104
var h := 76
var seme := 1
var bioma := "pianure"
var dadi := RandomNumberGenerator.new()

var terreno := PackedByteArray()
var livello := PackedByteArray()
var regione := PackedInt32Array()
var bloccato := PackedByteArray()      # 1: non si passa (alberi, rupi, rovi, acqua, cose)
var riservato := PackedByteArray()     # 1: sentiero o posto di una cosa: niente decori
var confine := PackedByteArray()       # 1: cella di confine fra due regioni
var regioni: Array[Dictionary] = []
var cose: Array[Dictionary] = []        # {tipo, cella, regione, ...}
var capsula := Vector2i.ZERO


func _init(numero: int = 1, quale: String = "pianure", larghezza: int = 104, altezza: int = 76) -> void:
	seme = numero
	bioma = quale if NOMI.has(quale) else "pianure"
	w = larghezza
	h = altezza
	dadi.seed = numero * 7919 + 13


func i(c: Vector2i) -> int:
	return c.y * w + c.x


func dentro(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < w and c.y < h


const QUATTRO: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const OTTO: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]


func genera() -> RefCounted:
	var n := w * h
	terreno.resize(n)
	livello.resize(n)
	regione.resize(n)
	bloccato.resize(n)
	riservato.resize(n)
	confine.resize(n)
	livello.fill(0)
	regione.fill(-1)
	bloccato.fill(0)
	riservato.fill(0)
	confine.fill(0)
	isola()
	dividi_in_regioni()
	ordina_regioni()
	alza_pianori()
	traccia_confini()
	apri_passaggi()
	metti_cuori_e_vene()
	traccia_sentieri()
	vesti_il_terreno()
	metti_decori()
	return self


# ---------------------------------------------------------------- l'isola

func isola() -> void:
	var rumore := FastNoiseLite.new()
	rumore.seed = seme
	rumore.frequency = 0.035
	rumore.fractal_octaves = 4
	var centro := Vector2(w, h) * 0.5
	for y in h:
		for x in w:
			var q := (Vector2(x, y) - centro) / (Vector2(w, h) * 0.5)
			var d := q.length()
			var alto := rumore.get_noise_2d(x, y) * 0.5 + 0.62 - pow(d, 2.6) * 0.95
			terreno[y * w + x] = ACQUA if alto < 0.0 else ERBA
	# un orlo d'acqua sempre, e solo l'isola piu' grande
	for y in h:
		for x in w:
			if x < 2 or y < 2 or x >= w - 2 or y >= h - 3:
				terreno[y * w + x] = ACQUA
	var piu_grande := pezzi_di_terra()
	for k in w * h:
		if terreno[k] != ACQUA and not piu_grande.has(k):
			terreno[k] = ACQUA
	# niente lingue di terra larghe una casella: si leviga
	for giro in 2:
		var copia := terreno.duplicate()
		for y in range(1, h - 1):
			for x in range(1, w - 1):
				var di_terra := 0
				for d in OTTO:
					if copia[(y + d.y) * w + x + d.x] != ACQUA:
						di_terra += 1
				if copia[y * w + x] != ACQUA and di_terra <= 2:
					terreno[y * w + x] = ACQUA
				elif copia[y * w + x] == ACQUA and di_terra >= 6:
					terreno[y * w + x] = ERBA


func pezzi_di_terra() -> Dictionary:
	var visto := {}
	var migliore := {}
	for k in w * h:
		if terreno[k] == ACQUA or visto.has(k):
			continue
		var pezzo := {}
		var coda: Array[int] = [k]
		visto[k] = true
		while not coda.is_empty():
			var c: int = coda.pop_back()
			pezzo[c] = true
			var p := Vector2i(c % w, floori(c / float(w)))
			for d in QUATTRO:
				var q := p + d
				if dentro(q) and terreno[i(q)] != ACQUA and not visto.has(i(q)):
					visto[i(q)] = true
					coda.append(i(q))
		if pezzo.size() > migliore.size():
			migliore = pezzo
	return migliore


func terra(c: Vector2i) -> bool:
	return dentro(c) and terreno[i(c)] != ACQUA


func distanza_dall_acqua() -> PackedInt32Array:
	var dist := PackedInt32Array()
	dist.resize(w * h)
	dist.fill(9999)
	var coda: Array[Vector2i] = []
	for y in h:
		for x in w:
			if terreno[y * w + x] == ACQUA:
				dist[y * w + x] = 0
				coda.append(Vector2i(x, y))
	var testa := 0
	while testa < coda.size():
		var p := coda[testa]
		testa += 1
		for d in QUATTRO:
			var q := p + d
			if dentro(q) and dist[i(q)] > dist[i(p)] + 1:
				dist[i(q)] = dist[i(p)] + 1
				coda.append(q)
	return dist


# ---------------------------------------------------------------- le regioni

func dividi_in_regioni() -> void:
	var dall_acqua := distanza_dall_acqua()
	var quante := clampi(floori(float(pezzi_di_terra().size()) / 480.0), 6, 10)
	# il primo seme: la terra piu' a sud, verso il centro (si atterra li')
	var semi: Array[Vector2i] = []
	var migliore := -99999.0
	var primo := Vector2i.ZERO
	for y in h:
		for x in w:
			var c := Vector2i(x, y)
			if dall_acqua[i(c)] >= 4:
				var punti := float(y) - absf(float(x) - w * 0.5) * 0.6
				if punti > migliore:
					migliore = punti
					primo = c
	semi.append(primo)
	# gli altri: ognuno il piu' lontano possibile da quelli gia' scelti
	while semi.size() < quante:
		var lontano := -1.0
		var scelto := Vector2i(-1, -1)
		for y in range(0, h, 2):
			for x in range(0, w, 2):
				var c := Vector2i(x, y)
				if dall_acqua[i(c)] < 4:
					continue
				var vicino := 99999.0
				for s in semi:
					vicino = minf(vicino, Vector2(c - s).length())
				var punti := vicino + minf(float(dall_acqua[i(c)]), 8.0) * 0.6 + dadi.randf() * 2.0
				if punti > lontano:
					lontano = punti
					scelto = c
		if scelto.x < 0:
			break
		semi.append(scelto)
	# ogni casella va al seme piu' vicino camminando, con un costo che ondeggia:
	# cosi' i confini girano come fiumi e non sono righe dritte
	var rumore := FastNoiseLite.new()
	rumore.seed = seme + 101
	rumore.frequency = 0.08
	var costo := PackedFloat32Array()
	costo.resize(w * h)
	for k in w * h:
		costo[k] = 1.0 + (rumore.get_noise_2d(k % w, floori(k / float(w))) + 1.0) * 1.6
	var dist := PackedFloat32Array()
	dist.resize(w * h)
	dist.fill(1e9)
	var mucchio := Mucchio.new()
	for r in semi.size():
		dist[i(semi[r])] = 0.0
		regione[i(semi[r])] = r
		mucchio.metti(0.0, i(semi[r]))
	while not mucchio.vuoto():
		var preso := mucchio.togli()
		var k := int(preso.y)
		if preso.x > dist[k]:
			continue
		var p := Vector2i(k % w, floori(k / float(w)))
		for d in QUATTRO:
			var q := p + d
			if not terra(q):
				continue
			var nuova := dist[k] + costo[i(q)]
			if nuova < dist[i(q)]:
				dist[i(q)] = nuova
				regione[i(q)] = regione[k]
				mucchio.metti(nuova, i(q))
	for r in semi.size():
		regioni.append({"id": r, "seme": semi[r], "celle": 0})
	for k in w * h:
		if regione[k] >= 0:
			regioni[regione[k]]["celle"] = int(regioni[regione[k]]["celle"]) + 1


func vicine() -> Dictionary:
	# quante caselle di confine ha ogni coppia di regioni: {Vector2i(a, b): n}, a < b
	var coppie := {}
	for y in h:
		for x in w:
			var a := regione[y * w + x]
			if a < 0:
				continue
			for d: Vector2i in [Vector2i(1, 0), Vector2i(0, 1)]:
				var q := Vector2i(x, y) + d
				if not dentro(q):
					continue
				var b := regione[i(q)]
				if b >= 0 and b != a:
					var chiave := Vector2i(mini(a, b), maxi(a, b))
					coppie[chiave] = int(coppie.get(chiave, 0)) + 1
	return coppie


func ordina_regioni() -> void:
	# dalla regione dell'atterraggio, in larghezza: ogni regione ha un
	# genitore, quella da cui ci si arriva. I confini lunghi vengono prima
	var coppie := vicine()
	for r in regioni:
		r["genitore"] = -1
		r["profondita"] = -1
	regioni[0]["profondita"] = 0
	var coda: Array[int] = [0]
	var testa := 0
	var ordine: Array[int] = []
	while testa < coda.size():
		var a := coda[testa]
		testa += 1
		ordine.append(a)
		var figli: Array[Vector2i] = []
		for chiave: Vector2i in coppie:
			if int(coppie[chiave]) < 6:
				continue
			var b := chiave.y if chiave.x == a else (chiave.x if chiave.y == a else -1)
			if b >= 0 and int(regioni[b]["profondita"]) < 0:
				figli.append(Vector2i(b, int(coppie[chiave])))
		figli.sort_custom(func(p: Vector2i, q: Vector2i) -> bool: return p.y > q.y)
		for f in figli:
			if int(regioni[f.x]["profondita"]) >= 0:
				continue
			regioni[f.x]["genitore"] = a
			regioni[f.x]["profondita"] = int(regioni[a]["profondita"]) + 1
			coda.append(f.x)
	# una regione che non si raggiunge (un confine troppo corto) diventa mare
	for r in regioni:
		if int(r["profondita"]) < 0:
			for k in w * h:
				if regione[k] == int(r["id"]):
					regione[k] = -1
					terreno[k] = ACQUA
	var nomi: Array = (NOMI[bioma] as Array).duplicate()
	var mescola := RandomNumberGenerator.new()
	mescola.seed = seme
	for k in range(nomi.size() - 1, 0, -1):
		var j := mescola.randi_range(0, k)
		var t: Variant = nomi[k]
		nomi[k] = nomi[j]
		nomi[j] = t
	for r in regioni:
		r["nome"] = String(nomi[int(r["id"]) % nomi.size()])
		r["ordine"] = ordine.find(int(r["id"]))
		r["colonizzata"] = false


func viva(r: int) -> bool:
	return int(regioni[r]["profondita"]) >= 0


# ---------------------------------------------------------------- le altezze

func alza_pianori() -> void:
	# alcune regioni stanno in alto. Non quella dell'atterraggio, e mai due
	# pianori di seguito nella fila (cosi' ogni pianoro ha una scala)
	for r in regioni:
		r["livello"] = 0
	for r in regioni:
		if not viva(int(r["id"])) or int(r["id"]) == 0:
			continue
		var padre := int(r["genitore"])
		if padre >= 0 and int(regioni[padre]["livello"]) == 1:
			continue
		if dadi.randf() < 0.45:
			r["livello"] = 1
	for k in w * h:
		if regione[k] >= 0:
			livello[k] = int(regioni[regione[k]]["livello"])


func parete(c: Vector2i) -> bool:
	# la parete della rupe sta sotto l'orlo sud dell'alto, alta due caselle
	if not dentro(c) or livello[i(c)] == 1:
		return false
	for su: int in [1, 2]:
		var q := c - Vector2i(0, su)
		if dentro(q) and livello[i(q)] == 1:
			return true
	return false


# ---------------------------------------------------------------- i confini

func traccia_confini() -> void:
	var coppie := vicine()
	for r in regioni:
		r["confini"] = {}
	var tipo_di := {}
	for chiave: Vector2i in coppie:
		var a := chiave.x
		var b := chiave.y
		if not viva(a) or not viva(b):
			continue
		var tipo := "rupe"
		if int(regioni[a]["livello"]) == int(regioni[b]["livello"]):
			tipo = String(CONFINI[dadi.randi_range(0, CONFINI.size() - 1)])
		tipo_di[chiave] = tipo
		(regioni[a]["confini"] as Dictionary)[b] = tipo
		(regioni[b]["confini"] as Dictionary)[a] = tipo
	for y in h:
		for x in w:
			var c := Vector2i(x, y)
			var a := regione[i(c)]
			if a < 0:
				continue
			for d in OTTO:
				var q := c + d
				if not dentro(q):
					continue
				var b := regione[i(q)]
				if b >= 0 and b != a:
					confine[i(c)] = 1
					var tipo := String(tipo_di.get(Vector2i(mini(a, b), maxi(a, b)), "bosco"))
					if tipo == "fiume":
						terreno[i(c)] = ACQUA
					break
	# le pareti delle rupi: anche loro sono confine
	for y in h:
		for x in w:
			if parete(Vector2i(x, y)):
				confine[y * w + x] = 1
	for k in w * h:
		if confine[k] == 1 or terreno[k] == ACQUA:
			bloccato[k] = 1


func tipo_confine(a: int, b: int) -> String:
	return String((regioni[a]["confini"] as Dictionary).get(b, "bosco"))


# ---------------------------------------------------------------- i passaggi

func apri_passaggi() -> void:
	# fra ogni regione e il suo genitore, un varco nel confine, chiuso da una
	# cosa da pagare
	for r in regioni:
		var figlio := int(r["id"])
		var padre := int(r["genitore"])
		if padre < 0 or not viva(figlio):
			continue
		var tipo := tipo_confine(padre, figlio)
		var varco := cerca_varco(padre, figlio, tipo)
		if varco.is_empty():
			continue
		var celle: Array[Vector2i] = []
		celle.assign(varco["celle"])
		for c in celle:
			bloccato[i(c)] = 1
			riservato[i(c)] = 1
		var cosa := {
			"tipo": {"fiume": "ponte", "bosco": "rovi_varco", "rovi": "rovi_varco", "rupe": "scala"}[tipo],
			"cella": celle[0], "celle": celle, "regione": figlio, "da": padre,
			"verso": varco["verso"], "fuori": varco["fuori"], "aperto": false,
			"costo": costo_passaggio(int(r["profondita"])),
		}
		cose.append(cosa)
		r["passaggio"] = cose.size() - 1


func cerca_varco(padre: int, figlio: int, tipo: String) -> Dictionary:
	# una fila di caselle di confine che va dritta da un interno all'altro.
	# Si sceglie quella piu' vicina al centro del confine fra le due regioni
	var centro := Vector2.ZERO
	var quanti := 0
	for y in h:
		for x in w:
			var c := Vector2i(x, y)
			if confine[i(c)] == 1 and (regione[i(c)] == padre or regione[i(c)] == figlio):
				for d in OTTO:
					var q := c + d
					if dentro(q) and (regione[i(q)] == padre or regione[i(q)] == figlio) and regione[i(q)] != regione[i(c)]:
						centro += Vector2(c)
						quanti += 1
						break
	if quanti == 0:
		return {}
	centro /= float(quanti)
	var migliore := {}
	var meglio := 1e9
	var versi: Array[Vector2i] = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	for y in h:
		for x in w:
			var inizio := Vector2i(x, y)
			if regione[i(inizio)] != padre or confine[i(inizio)] == 1 or bloccato[i(inizio)] == 1:
				continue
			for verso in versi:
				var celle: Array[Vector2i] = []
				var c := inizio + verso
				var ok := false
				for passo in 6:
					if not dentro(c):
						break
					if confine[i(c)] == 1:
						celle.append(c)
						c += verso
						continue
					ok = regione[i(c)] == figlio and bloccato[i(c)] == 0
					break
				if not ok or celle.is_empty() or celle.size() > 4:
					continue
				# Niente scorciatoie anche se ai lati del varco c'e' terra: il resto
				# del confine resta bloccato, e il controllo lo prova
				var lati_ok := true
				if tipo == "rupe" and verso.x != 0:
					# di lato si sale solo dove non c'e' parete
					for q in celle:
						if parete(q):
							lati_ok = false
				if not lati_ok:
					continue
				# lontano dalle altre cose e dalle spiagge; vicino al centro del confine
				var punti := Vector2(celle[0]).distance_to(centro)
				punti += float(celle.size()) * 1.5
				if tipo == "rupe" and verso.x != 0:
					# la scala nella parete si vede meglio: di lato solo se non c'e' altro
					punti += 40.0
				for altra in cose:
					if Vector2(altra["cella"] as Vector2i).distance_to(Vector2(celle[0])) < 6.0:
						punti += 50.0
				if punti < meglio:
					meglio = punti
					migliore = {"celle": celle, "verso": verso, "fuori": inizio}
	return migliore


func costo_passaggio(profondita: int) -> Dictionary:
	match profondita:
		1:
			return {"quarzo": 8}
		2:
			return {"quarzo": 10, "ferro": 4}
		3:
			return {"quarzo": 12, "ferro": 8}
		4:
			return {"ferro": 10, "cristallo": 3}
	return {"ferro": 12, "cristallo": 5}


# ---------------------------------------------------------------- cuori e vene

func distanza_dai_bordi() -> PackedInt32Array:
	var dist := PackedInt32Array()
	dist.resize(w * h)
	dist.fill(9999)
	var coda: Array[Vector2i] = []
	for y in h:
		for x in w:
			if bloccato[y * w + x] == 1 or regione[y * w + x] < 0:
				dist[y * w + x] = 0
				coda.append(Vector2i(x, y))
	var testa := 0
	while testa < coda.size():
		var p := coda[testa]
		testa += 1
		for d in QUATTRO:
			var q := p + d
			if dentro(q) and dist[i(q)] > dist[i(p)] + 1:
				dist[i(q)] = dist[i(p)] + 1
				coda.append(q)
	return dist


func metti_cuori_e_vene() -> void:
	var dai_bordi := distanza_dai_bordi()
	for r in regioni:
		var id := int(r["id"])
		if not viva(id):
			continue
		# il cuore: il punto piu' interno, un po' a caso fra i migliori
		var migliore := -1.0
		var cuore := Vector2i(r["seme"])
		for y in h:
			for x in w:
				if regione[y * w + x] == id:
					var punti := float(mini(dai_bordi[y * w + x], 9)) + dadi.randf() * 1.5
					if punti > migliore:
						migliore = punti
						cuore = Vector2i(x, y)
		r["cuore"] = cuore
		var zona := raggiunte_in(cuore, id)
		occupa(cuore, {"tipo": "faro", "regione": id, "aperto": false,
			"costo": costo_cuore(int(r["profondita"]))}, 2)
		# le vene: lontane dal cuore e fra loro, mai sul bordo
		var risorse := vene_di(int(r["profondita"]))
		var messe: Array[Vector2i] = [cuore]
		for risorsa in risorse:
			var posto := Vector2i(-1, -1)
			var lontano := -1.0
			for prova in 160:
				var c := Vector2i(dadi.randi_range(2, w - 3), dadi.randi_range(2, h - 3))
				if regione[i(c)] != id or dai_bordi[i(c)] < 3 or riservato[i(c)] == 1 or not zona.has(c):
					continue
				var vicino := 1e9
				for m in messe:
					vicino = minf(vicino, Vector2(c - m).length())
				if vicino > lontano:
					lontano = vicino
					posto = c
			if posto.x >= 0 and lontano >= 4.0:
				messe.append(posto)
				occupa(posto, {"tipo": "vena", "risorsa": risorsa, "regione": id, "scorta": 5, "ricresce": 0.0}, 1)
		# un forziere nell'angolo piu' nascosto, una regione si' e una no
		if id % 2 == 1:
			var nascosto := Vector2i(-1, -1)
			var lontano := -1.0
			for y in h:
				for x in w:
					var c := Vector2i(x, y)
					if regione[i(c)] == id and dai_bordi[i(c)] >= 2 and riservato[i(c)] == 0 and zona.has(c):
						var d := Vector2(c - cuore).length()
						if d > lontano:
							lontano = d
							nascosto = c
			if nascosto.x >= 0:
				occupa(nascosto, {"tipo": "forziere", "regione": id, "aperto": false}, 1)
	# la capsula, nella prima regione, a sud del cuore
	var primo: Vector2i = regioni[0]["cuore"]
	capsula = primo
	var meglio := -1.0
	for y in h:
		for x in w:
			var c := Vector2i(x, y)
			if regione[i(c)] == 0 and dai_bordi[i(c)] >= 3 and riservato[i(c)] == 0:
				var d := Vector2(c - primo).length()
				var punti := float(c.y - primo.y) - absf(d - 7.0) * 2.0
				if d > 4.0 and punti > meglio:
					meglio = punti
					capsula = c
	occupa(capsula, {"tipo": "capsula", "regione": 0}, 2)


func raggiunte_in(da: Vector2i, id: int) -> Dictionary:
	# le caselle libere della regione in cui si arriva a piedi da "da"
	var visto := {da: true}
	var coda: Array[Vector2i] = [da]
	var testa := 0
	while testa < coda.size():
		var p := coda[testa]
		testa += 1
		for d in QUATTRO:
			var q := p + d
			if dentro(q) and not visto.has(q) and regione[i(q)] == id and bloccato[i(q)] == 0:
				visto[q] = true
				coda.append(q)
	return visto


func occupa(c: Vector2i, cosa: Dictionary, largo: int) -> void:
	# la cosa ferma il cammino sulla sua casella; intorno, niente decori
	cosa["cella"] = c
	cose.append(cosa)
	bloccato[i(c)] = 1
	for y in range(-largo, largo + 1):
		for x in range(-largo, largo + 1):
			var q := c + Vector2i(x, y)
			if dentro(q):
				riservato[i(q)] = 1


func costo_cuore(profondita: int) -> Dictionary:
	match profondita:
		0:
			return {"quarzo": 6}
		1:
			return {"quarzo": 10, "ferro": 2}
		2:
			return {"quarzo": 8, "ferro": 6}
		3:
			return {"ferro": 10, "cristallo": 2}
	return {"ferro": 10, "cristallo": 4}


func vene_di(profondita: int) -> Array[String]:
	match profondita:
		0:
			return ["quarzo", "quarzo", "quarzo"]
		1:
			return ["quarzo", "quarzo", "ferro"]
		2:
			return ["ferro", "ferro", "quarzo"]
	return ["ferro", "cristallo", "cristallo"]


# ---------------------------------------------------------------- i sentieri

func traccia_sentieri() -> void:
	# dal cuore a ogni cosa della regione e a ogni varco: terra battuta, e li'
	# non cresce niente (cosi' ogni cosa si raggiunge sempre)
	for r in regioni:
		var id := int(r["id"])
		if not viva(id):
			continue
		var cuore: Vector2i = r["cuore"]
		var mete: Array[Vector2i] = []
		var solo_riservate: Array[Vector2i] = []
		for cosa in cose:
			if int(cosa["regione"]) == id and cosa["tipo"] != "faro" and not cosa.has("celle"):
				if cosa["tipo"] == "capsula":
					mete.append(Vector2i(cosa["cella"]))
				else:
					solo_riservate.append(Vector2i(cosa["cella"]))
			if cosa.has("fuori") and int(cosa["da"]) == id:
				mete.append(Vector2i(cosa["fuori"]))
			if cosa.has("celle") and int(cosa["regione"]) == id:
				# dall'altra parte del varco: la prima casella libera dopo
				var celle: Array = cosa["celle"]
				mete.append(Vector2i(celle[celle.size() - 1]) + Vector2i(cosa["verso"]))
		for meta in mete:
			var strada := cammino(cuore, meta, id)
			for c in strada:
				riservato[i(c)] = 1
				if terreno[i(c)] != ACQUA and bloccato[i(c)] == 0:
					terreno[i(c)] = TERRA
		# alle vene e ai forzieri si arriva lo stesso, ma senza sentiero: li'
		# non cresce niente e basta
		for meta in solo_riservate:
			for c in cammino(cuore, meta, id):
				riservato[i(c)] = 1


var curve := FastNoiseLite.new()


func cammino(da: Vector2i, a: Vector2i, id: int) -> Array[Vector2i]:
	# il piu' corto dentro la regione, fra le caselle libere (o la partenza e
	# l'arrivo, che sono cose e quindi bloccate). Il costo ondeggia, cosi' i
	# sentieri girano un po' invece di andare a squadra; e un sentiero gia'
	# tracciato costa meno, cosi' le strade si uniscono
	curve.seed = seme + 31
	curve.frequency = 0.15
	var costo := {da: 0.0}
	var venuto := {da: da}
	var mucchio := Mucchio.new()
	mucchio.metti(0.0, i(da))
	while not mucchio.vuoto():
		var preso := mucchio.togli()
		var p := Vector2i(int(preso.y) % w, floori(preso.y / float(w)))
		if p == a:
			break
		# il mucchio tiene i costi a 32 bit: un costo arrotondato in su non e'
		# un costo vecchio
		if preso.x > float(costo[p]) + 0.01:
			continue
		for d in QUATTRO:
			var q := p + d
			if not dentro(q) or regione[i(q)] != id:
				continue
			if q != a and bloccato[i(q)] == 1:
				continue
			var passo := 0.4 if terreno[i(q)] == TERRA and riservato[i(q)] == 1 else 1.0 + (curve.get_noise_2d(q.x, q.y) + 1.0) * 1.3
			var nuovo := float(costo[p]) + passo
			if not costo.has(q) or nuovo < float(costo[q]):
				costo[q] = nuovo
				venuto[q] = p
				mucchio.metti(nuovo, i(q))
	if not venuto.has(a):
		return []
	var strada: Array[Vector2i] = []
	var c := a
	while c != da:
		strada.append(c)
		c = venuto[c]
	return strada


# ---------------------------------------------------------------- il terreno

func vesti_il_terreno() -> void:
	# sabbia lungo l'acqua (non lungo i fiumi di confine: li' l'erba arriva
	# all'acqua), chiazze di terra dove e' secco
	var secco := FastNoiseLite.new()
	secco.seed = seme + 7
	secco.frequency = 0.06
	var dall_acqua := distanza_dall_acqua()
	for y in h:
		for x in w:
			var k := y * w + x
			if terreno[k] == ACQUA or terreno[k] == TERRA:
				continue
			if dall_acqua[k] <= 1 and not vicino_a_confine(Vector2i(x, y)):
				terreno[k] = SABBIA
			elif dall_acqua[k] == 2 and secco.get_noise_2d(x, y) > 0.1 and not vicino_a_confine(Vector2i(x, y)):
				terreno[k] = SABBIA
			elif secco.get_noise_2d(x * 1.3, y * 1.3) > 0.58 and confine[k] == 0:
				terreno[k] = TERRA
	# l'erba alta: macchie larghe, mai sui sentieri
	var alta := FastNoiseLite.new()
	alta.seed = seme + 17
	alta.frequency = 0.09
	for y in h:
		for x in w:
			var k := y * w + x
			if terreno[k] == ERBA and alta.get_noise_2d(x, y) > 0.12:
				terreno[k] = PRATO


func vicino_a_confine(c: Vector2i) -> bool:
	for y in range(-2, 3):
		for x in range(-2, 3):
			var q := c + Vector2i(x, y)
			if dentro(q) and confine[i(q)] == 1 and terreno[i(q)] == ACQUA:
				return true
	return false


# ---------------------------------------------------------------- i decori

func metti_decori() -> void:
	var bosco := FastNoiseLite.new()
	bosco.seed = seme + 3
	bosco.frequency = 0.07
	# sul confine: alberi fitti o rovi, secondo il tipo; sulle pareti niente
	for y in h:
		for x in w:
			var c := Vector2i(x, y)
			var k := i(c)
			if confine[k] == 0 or terreno[k] == ACQUA or riservato[k] == 1 or parete(c):
				continue
			var a := regione[k]
			var tipo := "bosco"
			for d in OTTO:
				var q := c + d
				if dentro(q) and regione[i(q)] >= 0 and regione[i(q)] != a:
					tipo = tipo_confine(a, regione[i(q)])
					break
			if tipo == "rovi":
				cose.append({"tipo": "rovi", "cella": c, "regione": a, "confine": true})
			elif tipo == "rupe":
				# dalla parte bassa una fila di massi e cespugli, dall'alta niente
				if livello[k] == 0:
					cose.append({"tipo": "sasso" if (x + y) % 3 == 0 else "cespuglio", "cella": c, "regione": a, "confine": true})
			elif (x + y * 2) % 2 == 0 or dadi.randf() < 0.35:
				cose.append({"tipo": "albero", "cella": c, "regione": a, "confine": true})
			else:
				cose.append({"tipo": "cespuglio", "cella": c, "regione": a, "confine": true})
	# dentro: boschetti dove il rumore lo dice, sassi e fiori qua e la',
	# i rovi della corruzione (se ne vanno quando la regione e' colonizzata)
	for y in range(1, h - 1):
		for x in range(1, w - 1):
			var c := Vector2i(x, y)
			var k := i(c)
			if bloccato[k] == 1 or riservato[k] == 1 or regione[k] < 0 or terreno[k] == ACQUA:
				continue
			var b := bosco.get_noise_2d(x, y)
			var caso := dadi.randf()
			if b > 0.32 and caso < 0.55 and terreno[k] >= ERBA:
				cose.append({"tipo": "albero", "cella": c, "regione": regione[k]})
				bloccato[k] = 1
			elif b > 0.18 and caso < 0.12:
				cose.append({"tipo": "cespuglio", "cella": c, "regione": regione[k]})
				bloccato[k] = 1
			elif caso < 0.016:
				cose.append({"tipo": "sasso", "cella": c, "regione": regione[k]})
				bloccato[k] = 1
			elif caso < 0.028 and regione[k] != 0:
				cose.append({"tipo": "rovi", "cella": c, "regione": regione[k], "corruzione": true})
				bloccato[k] = 1
			elif caso < 0.11 and terreno[k] >= ERBA:
				cose.append({"tipo": "fiori", "cella": c, "regione": regione[k]})
	# i posti delle case: intorno al cuore, compaiono quando la regione e' tua
	for r in regioni:
		var id := int(r["id"])
		if not viva(id):
			continue
		var cuore: Vector2i = r["cuore"]
		var messi := 0
		for prova: Vector2i in [Vector2i(-2, -1), Vector2i(2, -1), Vector2i(-2, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(-1, -2), Vector2i(1, -2)]:
			var c := cuore + prova
			if not dentro(c) or regione[i(c)] != id or (bloccato[i(c)] == 1 and c != cuore):
				continue
			var tipo := ["modulo", "lampione", "campo", "lampione", "campo", "modulo", "campo"][messi % 7] as String
			cose.append({"tipo": tipo, "cella": c, "regione": id, "colonia": true})
			messi += 1


# ---------------------------------------------------------------- il controllo

func passabile(c: Vector2i, aperti: Dictionary) -> bool:
	if not dentro(c):
		return false
	if bloccato[i(c)] == 0:
		return true
	return aperti.has(c)


func raggiunte(da: Vector2i, aperti: Dictionary) -> Dictionary:
	# le caselle in cui si arriva a piedi, coi varchi in "aperti" passabili
	var visto := {da: true}
	var coda: Array[Vector2i] = [da]
	var testa := 0
	while testa < coda.size():
		var p := coda[testa]
		testa += 1
		for d in QUATTRO:
			var q := p + d
			if not visto.has(q) and passabile(q, aperti):
				visto[q] = true
				coda.append(q)
	return visto


func partenza() -> Vector2i:
	# la prima casella libera sotto la capsula, meglio tre che una: il
	# personaggio e' alto tre caselle, e non deve partire con la testa dentro
	for d: Vector2i in [Vector2i(0, 3), Vector2i(1, 3), Vector2i(-1, 3), Vector2i(0, 2), Vector2i(1, 2), Vector2i(-1, 2),
			Vector2i(0, 1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		var q := capsula + d
		if dentro(q) and bloccato[i(q)] == 0:
			return q
	return capsula


func controlla() -> Array[String]:
	var guai: Array[String] = []
	var vive := 0
	for r in regioni:
		if viva(int(r["id"])):
			vive += 1
			if not r.has("cuore"):
				guai.append("%s senza cuore" % r["nome"])
			if int(r["id"]) != 0 and not r.has("passaggio"):
				guai.append("%s senza passaggio" % r["nome"])
	if vive < 4:
		guai.append("solo %d regioni" % vive)
	# si apre un passaggio alla volta, nell'ordine della fila: a ogni passo si
	# deve arrivare in tutte le regioni aperte e in nessun'altra
	var aperti := {}
	var aperte := {0: true}
	var da := partenza()
	var fila: Array[Dictionary] = regioni.duplicate()
	fila.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["ordine"]) < int(b["ordine"]))
	for r in fila:
		var id := int(r["id"])
		if not viva(id):
			continue
		if id != 0:
			if not r.has("passaggio"):
				continue
			var p: Dictionary = cose[int(r["passaggio"])]
			for c: Vector2i in p["celle"]:
				aperti[c] = true
			aperte[id] = true
		var arrivo := raggiunte(da, aperti)
		var toccate := {}
		for c: Vector2i in arrivo:
			if regione[i(c)] >= 0 and confine[i(c)] == 0:
				toccate[regione[i(c)]] = true
		for t: int in toccate:
			if not aperte.has(t):
				guai.append("con %d regioni aperte si arriva in %s senza pagare" % [aperte.size(), regioni[t]["nome"]])
		for a: int in aperte:
			if not toccate.has(a):
				guai.append("pagato il passaggio, %s non si raggiunge" % regioni[a]["nome"])
		# ogni cosa della regione si deve poter toccare da una casella raggiunta
		for cosa in cose:
			if int(cosa.get("regione", -1)) != id or cosa.has("confine") or cosa.has("colonia"):
				continue
			if not ["faro", "vena", "forziere"].has(cosa["tipo"]):
				continue
			var vicina := false
			for d in QUATTRO:
				if arrivo.has(Vector2i(cosa["cella"]) + d):
					vicina = true
			if not vicina:
				guai.append("in %s un %s non si raggiunge" % [r["nome"], cosa["tipo"]])
	return guai


static func buono(numero: int, quale: String) -> RefCounted:
	# un seme su quindici non viene (un confine senza varco possibile): si
	# prova il successivo, sempre nello stesso ordine, cosi' il pianeta di un
	# numero resta sempre quello
	var generatore: GDScript = load("res://prove/MondoGenera.gd")
	var ultimo: RefCounted = null
	for tentativo in 8:
		var m: RefCounted = generatore.new(numero + tentativo * 1000, quale)
		m.call("genera")
		var guai: Array[String] = m.call("controlla")
		if guai.is_empty():
			return m
		ultimo = m
	return ultimo


# ---------------------------------------------------------------- la coda con priorita'

class Mucchio:
	# un mucchio binario: x = priorita', y = cosa
	var dati: Array[Vector2] = []

	func vuoto() -> bool:
		return dati.is_empty()

	func metti(priorita: float, cosa: int) -> void:
		dati.append(Vector2(priorita, cosa))
		var k := dati.size() - 1
		while k > 0:
			var su := floori((k - 1) / 2.0)
			if dati[su].x <= dati[k].x:
				break
			var t := dati[su]
			dati[su] = dati[k]
			dati[k] = t
			k = su

	func togli() -> Vector2:
		var primo := dati[0]
		var ultimo: Vector2 = dati.pop_back()
		if not dati.is_empty():
			dati[0] = ultimo
			var k := 0
			while true:
				var a := k * 2 + 1
				var b := a + 1
				var m := k
				if a < dati.size() and dati[a].x < dati[m].x:
					m = a
				if b < dati.size() and dati[b].x < dati[m].x:
					m = b
				if m == k:
					break
				var t := dati[m]
				dati[m] = dati[k]
				dati[k] = t
				k = m
		return primo
