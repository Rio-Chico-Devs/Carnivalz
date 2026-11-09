extends RefCounted
# LE TESSERE DEI MONDI DA ESPLORARE (prove/MondoProva.gd). Provvisorie, ma
# fatte per essere sostituite: ogni pezzo e' un PNG in art/pianeti/<bioma>/,
# e un PNG messo li' a mano (da Bru, o da uno strumento come PixelLab) vince su
# quello disegnato qui. Le misure e l'ordine dei pezzi sono in
# art/pianeti/README.md.
#
# Bru, sulla raccolta stampata: «anche peggio di prima ... hai solo aggiunto
# roba in più». Il guaio era disegnare col codice a misura di schermo, e poi
# coprire con gli effetti. Qui si fa il contrario: pixel art a 16 pixel per
# tessera, ingrandita tre volte, una tavolozza piccola e niente filtri sopra.
# La forma la da' la luce, sempre dall'alto a sinistra.
#
# LA TAVOLOZZA E' NOSTRA. La natura cambia da pianeta a pianeta; due cose no:
#   - l'Organizzazione ha la livrea della mappa stellare (stile.json,
#     "proiezione"): carta crema, segnale arancio, fondo scuro, inchiostro blu.
#     Dove arriva lei, arrivano quei quattro colori;
#   - il Carnivalz e' la corruzione: rovi e macchie del colore della sua fonte.
#     Colonizzare vuol dire mandarla via.
#
# Le ombre virano al freddo e le luci al caldo (hue shifting, la regola dei
# pixel artist): e' quello che tiene viva una tavolozza di pochi colori.

const LATO := 16

const COMUNE := {
	# la livrea dell'Organizzazione: i quattro inchiostri della proiezione
	"carta": ["#6e5a4a", "#a3896a", "#c9ae86", "#efd8b2", "#fff3dc"],
	"segnale": ["#5a2a14", "#a0501a", "#d9781f", "#f29a2e", "#ffc76b"],
	"fondo": ["#07090d", "#0b0e14", "#1a2230", "#2c3a4e", "#4a5a72"],
	"inchiostro": ["#1a2c44", "#2c4a6e", "#4a7aa8", "#7fb2d9", "#c8e6f5"],
	# il contorno degli oggetti, quando la loro rampa non ne ha uno abbastanza scuro
	"china": ["#120e16"],
	# il personaggio: cappotto scuro, sciarpa arancio
	"pelle": ["#7a4a3a", "#c98f6c", "#f1c9a0", "#ffe6c8"],
	"capelli": ["#1a1218", "#2a1e24", "#4a3238"],
}

const TAVOLOZZE := {
	"pianure": {
		"_nota": "Il pianeta delle Pianure: prati, boschi tondi, acqua chiara.",
		"erba": ["#1f3a36", "#2b5a3d", "#3d7a40", "#5e9a44", "#8bb84e", "#c4d86c"],
		"terra": ["#3a2828", "#5c3d33", "#82573f", "#a57a52", "#c99f6c"],
		"sabbia": ["#8a7356", "#b39a6c", "#d4bd86", "#ecdcaa"],
		"acqua": ["#142640", "#1d3d63", "#285a88", "#3a7cad", "#68aad0", "#bfe5ef"],
		"roccia": ["#221e2a", "#37323f", "#544f60", "#777184", "#a09aaa", "#cec7cc"],
		"foglie": ["#12261e", "#1c3b2a", "#2a5831", "#3f7638", "#62974a", "#9cc05e"],
		"legno": ["#24171a", "#46291f", "#6b432f", "#91623d", "#b88a57"],
		"fiori": ["#efe6d6", "#f2c14e", "#e0606e", "#8fb8e0"],
		"corruzione": ["#170c1c", "#321634", "#57204a", "#86305a", "#bf4a72", "#ec94ac"],
		"vena": "quarzo",
	},
	"ardente": {
		"_nota": "Intorno al Vuoto Ardente, il mondo di Jerah: sabbia rossa, erba bruciata, lava al posto dell'acqua, agavi e ferro nero.",
		"erba": ["#33221c", "#56381f", "#7c5426", "#a6762e", "#cc9c3e", "#e8c46c"],
		"terra": ["#34191a", "#5a2a22", "#83402b", "#ab5c37", "#cd8452"],
		"sabbia": ["#2c2729", "#423b3d", "#5f5557", "#80767a"],
		"acqua": ["#240808", "#4a110c", "#7a1d10", "#a8300f", "#f08a2a", "#ffd27a"],
		"roccia": ["#181214", "#2a2023", "#433438", "#604a4e", "#856668", "#b08f86"],
		"foglie": ["#10221e", "#1a3a30", "#285440", "#3a704f", "#5a905f", "#8ab270"],
		"legno": ["#140c0e", "#2a1814", "#45281c", "#663e26", "#8a5a36"],
		"fiori": ["#ffe6b0", "#f2c14e", "#e8402a", "#f29a2e"],
		"corruzione": ["#1c080c", "#3c0e16", "#6c161e", "#a4241e", "#dc462a", "#ff9a5a"],
		"vena": "ferro",
	},
}

var bioma := "pianure"
var tav := {}


func _init(quale: String = "pianure") -> void:
	bioma = quale if TAVOLOZZE.has(quale) else "pianure"
	var scelta: Dictionary = TAVOLOZZE[bioma]
	for nome: String in COMUNE:
		tav[nome] = rampa_da(COMUNE[nome])
	for nome: String in scelta:
		if not nome.begins_with("_") and scelta[nome] is Array:
			tav[nome] = rampa_da(scelta[nome])


func rampa_da(esadecimali: Array) -> PackedColorArray:
	var r := PackedColorArray()
	for e: String in esadecimali:
		r.append(Color(e))
	return r


func col(rampa: String, i: int) -> Color:
	var r: PackedColorArray = tav[rampa]
	return r[clampi(i, 0, r.size() - 1)]


static func dado(x: int, y: int, s: int) -> float:
	# un numero fra 0 e 1 che dipende solo da x, y e s: le tessere escono sempre uguali
	var h := x * 374761393 + y * 668265263 + s * 1442695041
	h = (h ^ (h >> 13)) * 1274126177
	h = h ^ (h >> 16)
	return float(h & 0xFFFF) / 65535.0


static func vuota(w: int, h: int) -> Image:
	return Image.create_empty(w, h, false, Image.FORMAT_RGBA8)


# ---------------------------------------------------------------- i terreni
# Ogni terreno e' un foglio di 4x4 tessere (64x64). La tessera numero m dice
# in quali dei suoi quattro angoli c'e' quel terreno: 1 alto a sinistra, 2 alto
# a destra, 4 basso a sinistra, 8 basso a destra (m = la somma). E' la «doppia
# griglia»: il mondo sa il terreno di ogni casella, e ogni tessera si disegna
# a cavallo di quattro caselle, cosi' 16 pezzi bastano per tutti i bordi.

func dentro(maschera: int, x: float, y: float, mosso: float) -> bool:
	var a := float(maschera & 1)
	var b := float((maschera >> 1) & 1)
	var c := float((maschera >> 2) & 1)
	var d := float((maschera >> 3) & 1)
	var u := clampf(x / LATO, 0.0, 1.0)
	var v := clampf(y / LATO, 0.0, 1.0)
	var su := smoothstep(0.0, 1.0, u)
	var sv := smoothstep(0.0, 1.0, v)
	var f := lerpf(lerpf(a, b, su), lerpf(c, d, su), sv)
	# il bordo ondeggia un poco, ma mai sul lato della tessera: li' deve
	# combaciare con la vicina
	var finestra := sin(PI * u) * sin(PI * v)
	f += mosso * finestra * (sin(x * 1.3 + y * 0.4 + float(maschera)) * 0.6 + sin(y * 1.1 - x * 0.7) * 0.4)
	return f > 0.5


func terreno(nome: String) -> Image:
	var img := vuota(LATO * 4, LATO * 4)
	for m in 16:
		var ox := (m % 4) * LATO
		var oy := floori(m / 4.0) * LATO
		disegna_tessera(img, ox, oy, nome, m, 0)
	return img


func varianti(nome: String) -> Image:
	# la tessera piena (m = 15) in quattro versioni: il mondo le alterna
	var img := vuota(LATO * 4, LATO)
	for k in 4:
		disegna_tessera(img, k * LATO, 0, nome, 15, k)
	return img


func disegna_tessera(img: Image, ox: int, oy: int, nome: String, m: int, variante: int) -> void:
	var mosso := {"erba": 0.16, "terra": 0.1, "sabbia": 0.05, "prato": 0.22}.get(nome, 0.0) as float
	var piena := {}
	for y in range(-3, LATO + 3):
		for x in range(-3, LATO + 3):
			piena[Vector2i(x, y)] = dentro(m, float(x) + 0.5, float(y) + 0.5, mosso)
	for y in LATO:
		for x in LATO:
			var p := Vector2i(x, y)
			var colore := Color(0, 0, 0, 0)
			if c_e(piena, p):
				colore = pieno(nome, x, y, variante, piena, p)
			else:
				colore = fuori(nome, piena, p)
			if colore.a > 0.0:
				img.set_pixel(ox + x, oy + y, colore)


func c_e(piena: Dictionary, p: Vector2i) -> bool:
	return bool(piena.get(p, false))


func pieno(nome: String, x: int, y: int, variante: int, piena: Dictionary, p: Vector2i) -> Color:
	var su_fuori := not c_e(piena, p + Vector2i(0, -1))
	var giu_fuori := not c_e(piena, p + Vector2i(0, 1))
	var giu2_fuori := not c_e(piena, p + Vector2i(0, 2))
	var lato_fuori := not c_e(piena, p + Vector2i(-1, 0)) or not c_e(piena, p + Vector2i(1, 0))
	match nome:
		"erba":
			# il prato sporge: sotto ha un orlo scuro, sopra una lama di luce
			if giu_fuori:
				return col("erba", 1)
			if giu2_fuori or lato_fuori:
				return col("erba", 2)
			if su_fuori:
				return col("erba", 4)
			return col("erba", trama_erba(x, y, variante))
		"prato":
			# l'erba alta: piu' scura, fitta di ciuffi, e la punta chiara
			if giu_fuori:
				return col("erba", 0)
			if giu2_fuori or lato_fuori:
				return col("erba", 1)
			if su_fuori:
				return col("erba", 3)
			return col("erba", trama_prato(x, y, variante))
		"terra":
			if giu_fuori or lato_fuori:
				return col("terra", 1)
			if su_fuori:
				return col("terra", 1)
			return col("terra", trama_terra(x, y, variante))
		"sabbia":
			# la sabbia bagnata e' piu' scura, vicino all'acqua
			if giu_fuori or su_fuori or lato_fuori:
				return col("sabbia", 1)
			if giu2_fuori:
				return col("sabbia", 1).lerp(col("sabbia", 2), 0.5)
			return col("sabbia", trama_sabbia(x, y, variante))
	return Color.MAGENTA


func fuori(nome: String, piena: Dictionary, p: Vector2i) -> Color:
	match nome:
		"erba":
			# l'ombra che il prato fa su quello che c'e' sotto
			if c_e(piena, p + Vector2i(0, -1)):
				return Color(col("erba", 0), 0.55)
			if c_e(piena, p + Vector2i(0, -2)) or c_e(piena, p + Vector2i(-1, -1)) or c_e(piena, p + Vector2i(1, -1)):
				return Color(col("erba", 0), 0.22)
		"prato":
			if c_e(piena, p + Vector2i(0, -1)):
				return Color(col("erba", 0), 0.5)
		"sabbia":
			# la schiuma dove la sabbia tocca l'acqua
			var vicino := false
			var vicino2 := false
			for d: Vector2i in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
				if c_e(piena, p + d):
					vicino = true
				if c_e(piena, p + d * 2):
					vicino2 = true
			if vicino:
				return Color(col("acqua", 5), 0.9)
			if vicino2 and (p.x + p.y) % 2 == 0:
				return Color(col("acqua", 4), 0.6)
	return Color(0, 0, 0, 0)


# Le trame sono periodiche su 16 pixel: una tessera piena sta bene accanto a
# qualunque altra. Le varianti aggiungono qualcosa solo lontano dai lati.

func trama_erba(x: int, y: int, variante: int) -> int:
	var base := 3
	# ciuffi a «v»: due lame scure e la punta chiara
	var ciuffi: Array[Vector2i] = [Vector2i(2, 2), Vector2i(10, 1), Vector2i(6, 7), Vector2i(13, 9), Vector2i(1, 12), Vector2i(9, 13)]
	for c in ciuffi:
		var dx := posmod(x - c.x, LATO)
		var dy := posmod(y - c.y, LATO)
		if dy == 0 and (dx == 0 or dx == 2):
			return 2
		if dy == 1 and dx == 1:
			return 2
		if dy == 0 and dx == 1:
			return 4
	match variante:
		1:
			# una macchia di luce
			var d := Vector2(x - 8, (y - 8) * 1.4).length()
			if d < 4.5 and (x + y) % 3 != 0:
				return 4
		2:
			# erba piu' alta: piu' ciuffi
			if dado(x, y, 7) > 0.86 and x > 2 and x < 13 and y > 2 and y < 13:
				return 2
		3:
			var d := Vector2(x - 7, (y - 9) * 1.3).length()
			if d < 4.0 and (x * 3 + y) % 4 != 0:
				return 2
	return base


func trama_prato(x: int, y: int, variante: int) -> int:
	# fili d'erba verticali, a file sfalsate: due pixel scuri e la punta chiara
	var colonna := posmod(x + floori(posmod(y, LATO) / 4.0) * 2, 4)
	var riga := posmod(y + (x % 3), 4)
	if colonna == 0 and riga == 0:
		return 4
	if colonna == 0 and (riga == 1 or riga == 2):
		return 1
	if variante == 1 and colonna == 2 and riga == 1 and x > 2 and x < 13:
		return 5
	return 2


func trama_terra(x: int, y: int, variante: int) -> int:
	# sassolini: un pixel chiaro sopra uno scuro
	var sassi: Array[Vector2i] = [Vector2i(3, 4), Vector2i(11, 2), Vector2i(7, 10), Vector2i(14, 12), Vector2i(1, 14)]
	if variante > 0:
		sassi.append(Vector2i(4 + variante * 2, 6 + variante))
	for s in sassi:
		var dx := posmod(x - s.x, LATO)
		var dy := posmod(y - s.y, LATO)
		if dx == 0 and dy == 0:
			return 3
		if dx == 0 and dy == 1:
			return 1
		if dx == 1 and dy == 1:
			return 1
	if dado(posmod(x, LATO), posmod(y, LATO), 3) > 0.93:
		return 1
	return 2


func trama_sabbia(x: int, y: int, variante: int) -> int:
	# piccole increspature
	var onde: Array[Vector2i] = [Vector2i(2, 3), Vector2i(9, 7), Vector2i(4, 12), Vector2i(12, 14)]
	if variante == 1:
		onde.append(Vector2i(6, 5))
	for o in onde:
		var dx := posmod(x - o.x, LATO)
		var dy := posmod(y - o.y, LATO)
		if dy == 0 and dx < 3:
			return 3
		if dy == 1 and dx > 0 and dx < 4:
			return 1
	return 2


func acqua() -> Image:
	# quattro fotogrammi: le increspature scorrono di quattro pixel a fotogramma
	var img := vuota(LATO * 4, LATO)
	for k in 4:
		for y in LATO:
			for x in LATO:
				var c := col("acqua", 2)
				var onde: Array[Vector2i] = [Vector2i(1, 2), Vector2i(9, 5), Vector2i(4, 9), Vector2i(12, 12), Vector2i(7, 15)]
				for o in onde:
					var dx := posmod(x - o.x - k * 2, LATO)
					var dy := posmod(y - o.y, LATO)
					if dy == 0 and dx < 3:
						c = col("acqua", 4)
					elif dy == 1 and dx > 0 and dx < 4:
						c = col("acqua", 1)
				if (x + y * 3 + k) % 11 == 0 and c == col("acqua", 2):
					c = col("acqua", 3)
				img.set_pixel(k * LATO + x, y, c)
	return img


# ---------------------------------------------------------------- le rupi
# Il mondo ha due altezze. La parete si vede solo dove l'alto finisce verso
# sud, ed e' alta due caselle: la riga di sopra (con l'orlo) e quella di sotto
# (con l'ombra al piede). Ogni riga ha quattro pezzi: sola, inizio a sinistra,
# in mezzo, fine a destra. Poi l'orlo dell'alto, per lato: 16 pezzi, indice =
# 1 se dal lato nord si scende, 2 est, 4 sud, 8 ovest.

func rupe() -> Image:
	var img := vuota(LATO * 4, LATO * 6)
	for riga in 2:
		for k in 4:
			disegna_parete(img, k * LATO, riga * LATO, riga, k)
	for m in 16:
		disegna_orlo(img, (m % 4) * LATO, LATO * 2 + floori(m / 4.0) * LATO, m)
	return img


func disegna_parete(img: Image, ox: int, oy: int, riga: int, pezzo: int) -> void:
	# pezzo: 0 sola, 1 inizio, 2 mezzo, 3 fine
	var inizio := pezzo == 0 or pezzo == 1
	var fine := pezzo == 0 or pezzo == 3
	for y in LATO:
		for x in LATO:
			var yy := y + riga * LATO          # 0..31 sulla parete intera
			# strati di roccia: fasce un poco storte, con crepe verticali
			var fascia := floori((yy + floori(2.0 * sin(float(x + ox) * 0.7))) / 6.0)
			var c := col("roccia", 2 + (fascia % 2))
			var crepa := posmod(x * 5 + fascia * 7, 16) == 0
			if crepa:
				c = col("roccia", 1)
			if posmod(x * 5 + fascia * 7, 16) == 1:
				c = col("roccia", 4)
			if yy == 0:
				c = col("roccia", 5)
			elif yy == 1:
				c = col("roccia", 4)
			elif yy == 2:
				c = col("roccia", 3)
			if yy >= 29:
				c = col("roccia", 1)
			if yy == 31:
				c = col("roccia", 0)
			# le estremita' girano: il lato e' in ombra
			if inizio and x == 0:
				c = col("roccia", 0)
			elif inizio and x == 1:
				c = col("roccia", 3) if yy > 2 else c
			if fine and x == LATO - 1:
				c = col("roccia", 0)
			elif fine and x >= LATO - 3 and yy > 2:
				c = col("roccia", 1)
			img.set_pixel(ox + x, oy + y, c)


func disegna_orlo(img: Image, ox: int, oy: int, m: int) -> void:
	var nord := m & 1 != 0
	var est := m & 2 != 0
	var sud := m & 4 != 0
	var ovest := m & 8 != 0
	for y in LATO:
		for x in LATO:
			var c := Color(0, 0, 0, 0)
			if nord and y <= 2:
				# a nord si vede la cima della parete che scende dietro
				c = col("roccia", 1) if y == 0 else (col("roccia", 3) if y == 1 else Color(col("roccia", 5), 0.7))
			if ovest and x <= 2:
				c = col("roccia", 0) if x == 0 else (col("roccia", 2) if x == 1 else Color(col("roccia", 4), 0.6))
			if est and x >= LATO - 3:
				c = col("roccia", 0) if x == LATO - 1 else (col("roccia", 1) if x == LATO - 2 else Color(col("roccia", 2), 0.6))
			if sud and y >= LATO - 2:
				c = Color(col("roccia", 5), 0.85) if y == LATO - 1 else Color(1, 1, 1, 0.18)
			if c.a > 0.0:
				img.set_pixel(ox + x, oy + y, c)


# ---------------------------------------------------------------- le forme tonde
# Chiome, cespugli, rocce: palle di luce. Ogni lobo e' una mezza sfera; il
# pixel prende il lobo che sta piu' in alto, la sua normale, e la luce che
# viene dall'alto a sinistra. Poi la luce si taglia in fasce della rampa.

func palle(img: Image, lobi: Array[Vector4], rampa: String, livelli: int, ruvido: float, s: int) -> void:
	# lobo: x, y, raggio, quota (chi ha la quota piu' alta sta davanti)
	var luce := Vector3(-0.55, -0.75, 0.75).normalized()
	var w := img.get_width()
	var h := img.get_height()
	var alto := 9999.0
	var basso := -9999.0
	for l in lobi:
		alto = minf(alto, l.y - l.z)
		basso = maxf(basso, l.y + l.z)
	for y in h:
		for x in w:
			var migliore := -1.0
			var n := Vector3.ZERO
			for l in lobi:
				var dx := float(x) + 0.5 - l.x
				var dy := float(y) + 0.5 - l.y
				var d2 := dx * dx + dy * dy
				if d2 < l.z * l.z:
					var z := sqrt(l.z * l.z - d2)
					if z + l.w > migliore:
						migliore = z + l.w
						n = Vector3(dx, dy, z).normalized()
			if migliore < 0.0:
				continue
			var b := n.dot(luce)
			# in basso c'e' meno luce (la chioma si fa ombra da sola)
			b -= 0.35 * clampf((float(y) - alto) / maxf(basso - alto, 1.0), 0.0, 1.0)
			# a ciuffi di 2x2: la superficie non e' liscia
			b += (dado(floori(x / 2.0), floori(y / 2.0), s) - 0.5) * ruvido
			var i := clampi(floori((b + 0.55) / 1.25 * float(livelli)) + 1, 1, livelli)
			img.set_pixel(x, y, col(rampa, i))
	contorno(img, col(rampa, 0))


func contorno(img: Image, c: Color) -> void:
	# un pixel scuro intorno a cio' che e' disegnato (non dentro)
	var w := img.get_width()
	var h := img.get_height()
	var segnati: Array[Vector2i] = []
	for y in h:
		for x in w:
			if img.get_pixel(x, y).a > 0.5:
				continue
			for d: Vector2i in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
				var q := Vector2i(x, y) + d
				if q.x >= 0 and q.y >= 0 and q.x < w and q.y < h and img.get_pixel(q.x, q.y).a > 0.5:
					segnati.append(Vector2i(x, y))
					break
	for p in segnati:
		img.set_pixel(p.x, p.y, c)


func ombra_a_terra(img: Image, centro: Vector2, raggi: Vector2) -> void:
	# l'ombra sotto le cose: un ovale pieno, scuro, mezzo trasparente
	for y in img.get_height():
		for x in img.get_width():
			var q := (Vector2(x, y) + Vector2(0.5, 0.5) - centro) / raggi
			if q.length_squared() < 1.0 and img.get_pixel(x, y).a == 0.0:
				img.set_pixel(x, y, Color(col("china", 0), 0.32))


func sopra(img: Image, pezzo: Image, dove: Vector2i) -> void:
	# incolla un'immagine sopra un'altra, rispettando la trasparenza
	img.blend_rect(pezzo, Rect2i(Vector2i.ZERO, pezzo.get_size()), dove)


# ---------------------------------------------------------------- gli oggetti

func oggetti() -> Dictionary:
	var tutti := {}
	if bioma == "ardente":
		tutti["albero_1"] = agave(0)
		tutti["albero_2"] = albero_secco()
		tutti["cespuglio"] = agave(1)
	else:
		tutti["albero_1"] = albero(0)
		tutti["albero_2"] = albero(1)
		tutti["cespuglio"] = cespuglio()
	tutti["sasso"] = sasso(16, 16, 0)
	tutti["masso"] = sasso(32, 28, 1)
	tutti["fiori"] = fiori()
	tutti["rovi"] = rovi(0)
	tutti["rovi_2"] = rovi(1)
	tutti["vena_quarzo"] = vena("quarzo", true)
	tutti["vena_ferro"] = vena("ferro", true)
	tutti["vena_cristallo"] = vena("cristallo", true)
	tutti["vena_vuota"] = vena("quarzo", false)
	tutti["faro_rotto"] = faro(false)
	tutti["faro"] = faro(true)
	tutti["modulo"] = modulo()
	tutti["lampione"] = lampione()
	tutti["capsula"] = capsula()
	tutti["forziere"] = forziere()
	tutti["campo"] = campo()
	tutti["ponte_rotto_o"] = ponte(true, false)
	tutti["ponte_o"] = ponte(true, true)
	tutti["ponte_rotto_v"] = ponte(false, false)
	tutti["ponte_v"] = ponte(false, true)
	tutti["scala_rotta"] = scala(false)
	tutti["scala"] = scala(true)
	return tutti


func albero(variante: int) -> Image:
	# 32x40: la chioma tonda a lobi, il tronco, l'ombra. La base del tronco e'
	# il punto (16, 36), che sta sulla casella dell'albero.
	var img := vuota(32, 40)
	var chioma := vuota(32, 40)
	var lobi: Array[Vector4] = [Vector4(16, 15, 12.5, 2)]
	var giro := 0.6 + float(variante) * 1.1
	for k in 6:
		var a := giro + float(k) * TAU / 6.0
		lobi.append(Vector4(16 + cos(a) * 8.5, 15 + sin(a) * 7.0, 6.5 + float((k + variante) % 3), -2.0 + sin(a) * -3.0))
	lobi.append(Vector4(12, 9, 6, 6))
	lobi.append(Vector4(19, 10 + variante, 5, 5))
	palle(chioma, lobi, "foglie", 5, 0.38, 11 + variante)
	ombra_a_terra(img, Vector2(16, 36), Vector2(12, 4))
	tronco(img, 16, 36, 9)
	sopra(img, chioma, Vector2i.ZERO)
	return img


func tronco(img: Image, cx: int, base: int, alto: int) -> void:
	for y in range(base - alto, base + 1):
		var largo := 3 if y < base - 1 else 4
		for x in range(cx - largo, cx + largo):
			var c := col("legno", 2)
			if x == cx - largo:
				c = col("legno", 0)
			elif x == cx + largo - 1:
				c = col("legno", 0)
			elif x == cx - largo + 1:
				c = col("legno", 3)
			elif x >= cx + largo - 2:
				c = col("legno", 1)
			if y == base:
				c = col("legno", 0)
			img.set_pixel(x, y, c)


func cespuglio() -> Image:
	var img := vuota(16, 16)
	var foglie := vuota(16, 16)
	var lobi: Array[Vector4] = [Vector4(8, 9, 6, 0), Vector4(4.5, 10, 4, -1), Vector4(11.5, 10, 4, -1), Vector4(7, 6.5, 4, 2), Vector4(10, 7, 3.5, 1)]
	palle(foglie, lobi, "foglie", 5, 0.3, 5)
	ombra_a_terra(img, Vector2(8, 14), Vector2(7, 2.5))
	sopra(img, foglie, Vector2i.ZERO)
	return img


func agave(variante: int) -> Image:
	# nel deserto: foglie a punta che partono dal centro
	var w := 32 if variante == 0 else 16
	var h := 40 if variante == 0 else 16
	var img := vuota(w, h)
	var piante := vuota(w, h)
	var base := Vector2(w * 0.5, h - 4.0)
	var foglie := 9 if variante == 0 else 6
	var lungo := 22.0 if variante == 0 else 10.0
	for k in foglie:
		var a := -PI * 0.5 + (float(k) / float(foglie - 1) - 0.5) * 2.6
		var punta := base + Vector2(cos(a), sin(a)) * lungo * (0.75 + 0.25 * sin(float(k) * 2.1))
		var passi := 40
		for t in passi:
			var f := float(t) / float(passi)
			var p := base.lerp(punta, f)
			var largo := (1.0 - f) * (3.2 if variante == 0 else 2.0)
			for dy in range(-3, 4):
				for dx in range(-3, 4):
					var q := p + Vector2(dx, dy)
					if Vector2(dx, dy).length() <= largo and q.x >= 0 and q.y >= 0 and q.x < w and q.y < h:
						var luce := 4 if dx < 0 else (3 if dx == 0 else 2)
						if f > 0.8:
							luce = 5
						piante.set_pixel(int(q.x), int(q.y), col("foglie", luce))
	contorno(piante, col("foglie", 0))
	ombra_a_terra(img, base + Vector2(0, 1), Vector2(w * 0.35, 3))
	sopra(img, piante, Vector2i.ZERO)
	return img


func albero_secco() -> Image:
	# ferro nero e rami: un albero morto, il segno del mondo di Jerah
	var img := vuota(32, 40)
	var rami := vuota(32, 40)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	ramo(rami, Vector2(16, 36), -PI * 0.5, 15.0, 3.0, 0, rng)
	contorno(rami, col("china", 0))
	ombra_a_terra(img, Vector2(16, 36), Vector2(9, 3))
	sopra(img, rami, Vector2i.ZERO)
	return img


func ramo(img: Image, da: Vector2, angolo: float, lungo: float, spesso: float, livello: int, rng: RandomNumberGenerator) -> void:
	var a := da + Vector2(cos(angolo), sin(angolo)) * lungo
	var passi := int(lungo * 2.0)
	for t in passi + 1:
		var p := da.lerp(a, float(t) / float(passi))
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				if Vector2(dx, dy).length() <= spesso * 0.5:
					var q := Vector2i(p) + Vector2i(dx, dy)
					if q.x >= 0 and q.y >= 0 and q.x < img.get_width() and q.y < img.get_height():
						img.set_pixel(q.x, q.y, col("legno", 3 if dx < 0 else 1))
	if livello < 3:
		ramo(img, a, angolo - 0.5 - rng.randf() * 0.3, lungo * 0.62, maxf(spesso - 1.0, 1.0), livello + 1, rng)
		ramo(img, a, angolo + 0.45 + rng.randf() * 0.3, lungo * 0.58, maxf(spesso - 1.0, 1.0), livello + 1, rng)


func sasso(w: int, h: int, variante: int) -> Image:
	var img := vuota(w, h)
	var pietra := vuota(w, h)
	var lobi: Array[Vector4] = []
	if variante == 0:
		lobi = [Vector4(8, 10, 5.5, 0), Vector4(10.5, 11, 4, -1)]
	else:
		lobi = [Vector4(15, 17, 11, 0), Vector4(8, 19, 7, -2), Vector4(23, 19, 7, -2), Vector4(13, 12, 7, 2)]
	palle(pietra, lobi, "roccia", 5, 0.15, 21 + variante)
	ombra_a_terra(img, Vector2(w * 0.5, h - 2.5), Vector2(w * 0.42, 2.5))
	sopra(img, pietra, Vector2i.ZERO)
	# una crepa
	if variante == 1:
		for k in 5:
			pietra.set_pixel(17 + k, 14 + floori(k * 0.6), col("roccia", 1))
		sopra(img, pietra, Vector2i.ZERO)
	return img


func fiori() -> Image:
	# un ciuffo di fiori: non ferma il cammino, e' solo bello
	var img := vuota(16, 16)
	var posti: Array[Vector2i] = [Vector2i(4, 5), Vector2i(10, 4), Vector2i(7, 10), Vector2i(12, 11), Vector2i(3, 12)]
	for k in posti.size():
		var p := posti[k]
		var tinta := col("fiori", k % 4)
		img.set_pixel(p.x, p.y + 2, col("erba", 1))
		for d: Vector2i in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
			img.set_pixel(p.x + d.x, p.y + d.y, tinta)
		img.set_pixel(p.x, p.y, col("fiori", 1) if k % 4 != 1 else col("segnale", 4))
		img.set_pixel(p.x + 1, p.y + 1, col("erba", 1))
	return img


func rovi(variante: int) -> Image:
	# i rovi del Carnivalz: un groviglio scuro del colore della fonte, con le
	# spine chiare che escono. Fermano il cammino; quando la regione e' tua,
	# quelli dentro se ne vanno e quelli sul confine tornano cespugli
	var img := vuota(16, 16)
	var groviglio := vuota(16, 16)
	var lobi: Array[Vector4] = [Vector4(8, 9.5, 5.5, 0), Vector4(4.5, 10.5, 3.5, -1), Vector4(11.5, 10.5, 3.5, -1),
		Vector4(6.5 + variante, 6.5, 3.5, 2), Vector4(10, 7.5 - variante, 3, 1)]
	palle(groviglio, lobi, "corruzione", 4, 0.5, 40 + variante)
	# le spine: punte di un pixel che escono dal contorno
	var spine: Array[Vector2i] = [Vector2i(2, 8), Vector2i(13, 9), Vector2i(7, 2), Vector2i(10, 3), Vector2i(1, 12), Vector2i(14, 12)]
	if variante == 1:
		spine = [Vector2i(3, 6), Vector2i(12, 6), Vector2i(8, 2), Vector2i(1, 11), Vector2i(14, 11)]
	for p in spine:
		groviglio.set_pixel(p.x, p.y, col("corruzione", 5))
	# i tralci dentro: righe scure storte
	for t in 6:
		var x := 4 + floori(t * 1.4) + variante
		var y := 8 + (t % 3)
		if x < 15:
			groviglio.set_pixel(x, y, col("corruzione", 1))
	ombra_a_terra(img, Vector2(8, 14), Vector2(7, 2))
	sopra(img, groviglio, Vector2i.ZERO)
	return img


func vena(quale: String, piena: bool) -> Image:
	# una roccia con dentro la risorsa: schegge che escono dalla pietra
	var img := sasso(16, 16, 0)
	if not piena:
		return img
	var tinte := {
		"quarzo": ["carta", 4, 3, "inchiostro", 3],
		"ferro": ["fondo", 4, 3, "segnale", 2],
		"cristallo": ["segnale", 4, 3, "segnale", 1],
	}
	var t: Array = tinte[quale]
	var schegge: Array[Vector3] = [Vector3(6, 9, 6), Vector3(9, 8, 7), Vector3(11, 10, 4)]
	for s in schegge:
		for y in int(s.z):
			var largo := 1 if y < int(s.z) - 2 else 2
			if y == 0:
				largo = 0
			for dx in range(-largo, largo + 1):
				var x := int(s.x) + dx
				var yy := int(s.y) - y
				var c: Color = col(String(t[0]), int(t[1])) if dx <= 0 else col(String(t[3]), int(t[4]))
				if dx == 0 and y > 0:
					c = col(String(t[0]), int(t[2]))
				img.set_pixel(x, yy, c)
	var pezzi := vuota(16, 16)
	sopra(pezzi, img, Vector2i.ZERO)
	return pezzi


# ---------------------------------------------------------------- l'Organizzazione
# Forme dure, rettangoli e fasce: si capisce a colpo d'occhio che non sono
# nate li'. Carta, segnale, fondo, inchiostro.

func riempi(img: Image, r: Rect2i, c: Color) -> void:
	img.fill_rect(r, c)


func faro(acceso: bool) -> Image:
	# 32x48: il cuore della regione. Spento e storto finche' non lo ripari;
	# acceso, la regione diventa autonoma. La base sta a (16, 44).
	var img := vuota(32, 48)
	ombra_a_terra(img, Vector2(16, 44), Vector2(12, 3.5))
	var corpo := vuota(32, 48)
	# basamento di ferro scuro
	riempi(corpo, Rect2i(8, 38, 16, 7), col("fondo", 2))
	riempi(corpo, Rect2i(8, 38, 16, 1), col("fondo", 4))
	riempi(corpo, Rect2i(9, 40, 2, 4), col("fondo", 3))
	if acceso:
		# il fusto: carta, con la fascia arancio
		riempi(corpo, Rect2i(11, 14, 10, 24), col("carta", 3))
		riempi(corpo, Rect2i(11, 14, 3, 24), col("carta", 4))
		riempi(corpo, Rect2i(18, 14, 3, 24), col("carta", 2))
		riempi(corpo, Rect2i(11, 24, 10, 4), col("segnale", 3))
		riempi(corpo, Rect2i(18, 24, 3, 4), col("segnale", 2))
		riempi(corpo, Rect2i(11, 28, 10, 1), col("segnale", 1))
		# la lanterna: vetro blu acceso
		riempi(corpo, Rect2i(10, 12, 12, 2), col("fondo", 2))
		riempi(corpo, Rect2i(12, 5, 8, 7), col("inchiostro", 3))
		riempi(corpo, Rect2i(13, 6, 2, 4), col("inchiostro", 4))
		riempi(corpo, Rect2i(18, 5, 2, 7), col("inchiostro", 2))
		riempi(corpo, Rect2i(11, 3, 10, 2), col("fondo", 2))
		riempi(corpo, Rect2i(14, 1, 4, 2), col("segnale", 3))
	else:
		# rotto: il fusto spezzato a meta', storto, sporco
		for y in range(22, 38):
			var storto := floori((38 - y) / 6.0)
			riempi(corpo, Rect2i(11 + storto, y, 10, 1), col("carta", 1))
			corpo.set_pixel(11 + storto, y, col("carta", 2))
			corpo.set_pixel(20 + storto, y, col("carta", 0))
		riempi(corpo, Rect2i(13, 28, 10, 3), col("segnale", 1))
		for x in range(13, 24):
			if x % 2 == 0:
				corpo.set_pixel(x, 21 + (x % 3), col("carta", 0))
		# la lanterna caduta a terra
		riempi(corpo, Rect2i(22, 39, 7, 5), col("fondo", 2))
		riempi(corpo, Rect2i(23, 40, 4, 3), col("inchiostro", 1))
	contorno(corpo, col("china", 0))
	sopra(img, corpo, Vector2i.ZERO)
	return img


func modulo() -> Image:
	# 32x32: la casetta che compare quando la regione e' tua
	var img := vuota(32, 32)
	ombra_a_terra(img, Vector2(16, 28), Vector2(14, 3))
	var corpo := vuota(32, 32)
	riempi(corpo, Rect2i(4, 12, 24, 15), col("carta", 3))
	riempi(corpo, Rect2i(4, 12, 24, 2), col("carta", 4))
	riempi(corpo, Rect2i(22, 14, 6, 13), col("carta", 2))
	riempi(corpo, Rect2i(4, 20, 24, 2), col("segnale", 3))
	riempi(corpo, Rect2i(22, 20, 6, 2), col("segnale", 2))
	# il tetto scuro, a botte
	for x in range(3, 29):
		var curva := floori(3.0 * sin(float(x - 3) / 25.0 * PI))
		riempi(corpo, Rect2i(x, 10 - curva, 1, curva + 3), col("fondo", 3) if x < 16 else col("fondo", 2))
	# finestra e porta
	riempi(corpo, Rect2i(8, 15, 6, 4), col("inchiostro", 3))
	riempi(corpo, Rect2i(9, 15, 2, 2), col("inchiostro", 4))
	riempi(corpo, Rect2i(17, 18, 4, 9), col("fondo", 2))
	riempi(corpo, Rect2i(18, 22, 1, 1), col("segnale", 4))
	contorno(corpo, col("china", 0))
	sopra(img, corpo, Vector2i.ZERO)
	return img


func lampione() -> Image:
	var img := vuota(16, 32)
	ombra_a_terra(img, Vector2(8, 29), Vector2(4, 1.5))
	var corpo := vuota(16, 32)
	riempi(corpo, Rect2i(7, 8, 2, 21), col("fondo", 3))
	riempi(corpo, Rect2i(7, 8, 1, 21), col("fondo", 4))
	riempi(corpo, Rect2i(5, 27, 6, 2), col("fondo", 2))
	riempi(corpo, Rect2i(5, 4, 6, 4), col("segnale", 4))
	riempi(corpo, Rect2i(5, 3, 6, 1), col("fondo", 2))
	riempi(corpo, Rect2i(6, 5, 2, 2), Color.WHITE)
	contorno(corpo, col("china", 0))
	sopra(img, corpo, Vector2i.ZERO)
	return img


func capsula() -> Image:
	# 32x32: la capsula con cui si arriva sul pianeta
	var img := vuota(32, 32)
	ombra_a_terra(img, Vector2(16, 29), Vector2(13, 3))
	var corpo := vuota(32, 32)
	var lobi: Array[Vector4] = [Vector4(16, 14, 10, 0)]
	palle(corpo, lobi, "carta", 4, 0.0, 1)
	riempi(corpo, Rect2i(7, 16, 18, 3), col("segnale", 3))
	riempi(corpo, Rect2i(19, 16, 6, 3), col("segnale", 2))
	riempi(corpo, Rect2i(12, 8, 7, 5), col("inchiostro", 3))
	riempi(corpo, Rect2i(13, 9, 2, 2), col("inchiostro", 4))
	for g: int in [8, 22]:
		for y in range(22, 29):
			corpo.set_pixel(g + floori((y - 22) * (-0.4 if g < 16 else 0.4)), y, col("fondo", 3))
	contorno(corpo, col("china", 0))
	sopra(img, corpo, Vector2i.ZERO)
	return img


func forziere() -> Image:
	var img := vuota(16, 16)
	ombra_a_terra(img, Vector2(8, 14), Vector2(7, 2))
	var corpo := vuota(16, 16)
	riempi(corpo, Rect2i(2, 6, 12, 8), col("fondo", 3))
	riempi(corpo, Rect2i(2, 6, 12, 2), col("fondo", 4))
	riempi(corpo, Rect2i(2, 9, 12, 1), col("segnale", 2))
	riempi(corpo, Rect2i(6, 8, 4, 4), col("segnale", 3))
	riempi(corpo, Rect2i(7, 9, 2, 2), col("segnale", 4))
	contorno(corpo, col("china", 0))
	sopra(img, corpo, Vector2i.ZERO)
	return img


func campo() -> Image:
	# un campo coltivato: file di piantine su terra smossa (non ferma il cammino)
	var img := vuota(16, 16)
	for y in range(1, 15):
		for x in range(1, 15):
			var fila := y % 4
			var c := col("terra", 2 if fila != 0 else 1)
			if fila == 2 and x % 3 == 1:
				c = col("foglie", 4)
			elif fila == 1 and x % 3 == 1:
				c = col("foglie", 5)
			elif fila == 2 and x % 3 == 2:
				c = col("foglie", 2)
			img.set_pixel(x, y, c)
	return img


func ponte(orizzontale: bool, intero: bool) -> Image:
	# una casella di ponte: assi di legno. Rotto, mancano le assi
	var img := vuota(16, 16)
	for i in LATO:
		var asse := floori(i / 3.0)
		var manca := not intero and (asse % 2 == 1 or asse == 3)
		if manca:
			continue
		for j in range(2, 14):
			var x := i if orizzontale else j
			var y := j if orizzontale else i
			var c := col("legno", 3)
			if i % 3 == 2:
				c = col("legno", 1)
			elif i % 3 == 0:
				c = col("legno", 4)
			if j == 2 or j == 13:
				c = col("legno", 0)
			img.set_pixel(x, y, c)
	# le corde ai lati
	for i in LATO:
		var a := Vector2i(i, 1) if orizzontale else Vector2i(1, i)
		var b := Vector2i(i, 14) if orizzontale else Vector2i(14, i)
		if intero or i < 4 or i > 11:
			img.set_pixel(a.x, a.y, col("legno", 0))
			img.set_pixel(b.x, b.y, col("legno", 0))
	return img


func scala(intera: bool) -> Image:
	# 16x32: la scala nella parete della rupe. Rotta: gradini spaccati
	var img := vuota(16, 32)
	for y in 32:
		for x in range(2, 14):
			var gradino := floori(y / 4.0)
			var c := col("roccia", 4) if y % 4 == 0 else col("roccia", 2)
			if y % 4 == 3:
				c = col("roccia", 1)
			if not intera and (gradino % 3 == 1 or (gradino % 3 == 2 and x > 7)):
				c = col("roccia", 0) if y % 4 != 0 else col("roccia", 1)
			if x == 2 or x == 13:
				c = col("roccia", 0)
			img.set_pixel(x, y, c)
	return img


# ---------------------------------------------------------------- il personaggio
# 16x24, disegnato a mano pixel per pixel: tre direzioni (giu', su, destra; la
# sinistra e' la destra allo specchio) e tre pose (fermo, passo, altro passo).

const LETTERE := {
	"o": ["china", 0], "h": ["capelli", 1], "H": ["capelli", 2], "s": ["pelle", 2],
	"S": ["pelle", 1], "l": ["pelle", 3], "e": ["china", 0], "c": ["fondo", 2],
	"C": ["fondo", 3], "L": ["fondo", 4], "r": ["segnale", 3], "R": ["segnale", 2],
	"y": ["segnale", 4], "b": ["fondo", 1], "w": ["carta", 4],
}

const TESTA_GIU := [
	"................",
	".....oooooo.....",
	"....ohhhhhho....",
	"...ohhHHhhhho...",
	"..ohhHhhhhhhho..",
	"..ohhhhhhhhhho..",
	"..ohhsssssshho..",
	"..ohslsssssSho..",
	"..oSsesssesSSo..",
	"..oSsesssesSSo..",
	"...oSsssssSSo...",
	"....oSSSSSSo....",
]
const TESTA_SU := [
	"................",
	".....oooooo.....",
	"....ohhhhhho....",
	"...ohhHHhhhho...",
	"..ohhHhhhhhhho..",
	"..ohhhhhhhhhho..",
	"..ohhhhhhhhhho..",
	"..ohhhhhhhhhho..",
	"..ohhhhhhhhhho..",
	"..oShhhhhhhhSo..",
	"...oShhhhhhSo...",
	"....oSSSSSSo....",
]
const TESTA_DESTRA := [
	"................",
	".....oooooo.....",
	"....ohhhhhhoo...",
	"...ohhHHhhhhho..",
	"...ohHhhhhhhhho.",
	"...ohhhhhhhhhho.",
	"...ohhhhhsssso..",
	"...ohhhhslssso..",
	"...ohhhhsssesso.",
	"...oShhhssses.o.",
	"....oShhsssso...",
	".....oSSSSSo....",
]
const CORPO_GIU := [
	"...oorRrrRroo...",
	"..ocRrryrrRCco..",
	"..ocCRrrrRCLco..",
	".oscCLcRcCLCcso.",
	".oSccLCCCCLCcSo.",
	"..ocCLCCCCLCco..",
	"..occCCCCCCcco..",
	"...occccccccoo..",
]
const CORPO_SU := [
	"...oorrrrrrroo..",
	"..ocCRrrrRCCco..",
	"..ocCCRRRRCLco..",
	".oscCCCCCCCLcso.",
	".oSccCCCCCCLcSo.",
	"..occCCCCCCCco..",
	"..occCCCCCCcco..",
	"...occccccccoo..",
]
const CORPO_DESTRA := [
	"....oorrrRRoo...",
	"....ocRrryRco...",
	"....ocCCRrLco...",
	"....occCCLLco...",
	"....occCsCLco...",
	"....occCSCLco...",
	"....occCCCLco...",
	".....occccco....",
]
const GAMBE := {
	"giu": [
		["...obbo..obbo...", "...obbo..obbo...", "...oooo..oooo..."],
		["...obbo..obbo...", "...obbo...ooo...", "...oooo.........."],
		["...obbo..obbo...", "....ooo..obbo...", ".........oooo..."],
	],
	"su": [
		["...obbo..obbo...", "...obbo..obbo...", "...oooo..oooo..."],
		["...obbo..obbo...", "...ooo...obbo...", ".........oooo..."],
		["...obbo..obbo...", "...obbo...ooo...", "...oooo........."],
	],
	"destra": [
		[".....obbbo......", ".....obbbo......", ".....ooooo......"],
		["....obbo.obbo...", "...obbo...obbo..", "...ooo.....ooo.."],
		[".....obbbo......", "....obbbbo......", "....oooooo......"],
	],
}


func personaggio() -> Image:
	# il foglio: righe giu', su, destra; colonne fermo, passo, altro passo
	var img := vuota(LATO * 3, 24 * 3)
	var direzioni := ["giu", "su", "destra"]
	for r in 3:
		var dir: String = direzioni[r]
		var testa: Array = TESTA_GIU if dir == "giu" else (TESTA_SU if dir == "su" else TESTA_DESTRA)
		var corpo: Array = CORPO_GIU if dir == "giu" else (CORPO_SU if dir == "su" else CORPO_DESTRA)
		for k in 3:
			var gambe: Array = (GAMBE[dir] as Array)[k]
			var righe: Array = []
			righe.append_array(testa)
			righe.append_array(corpo)
			righe.append_array(gambe)
			# nel passo il corpo sobbalza di un pixel
			var su := 1 if k > 0 else 0
			for y in righe.size():
				var riga: String = righe[y]
				for x in mini(riga.length(), LATO):
					var lettera := riga[x]
					if not LETTERE.has(lettera):
						continue
					var dove: Array = LETTERE[lettera]
					var yy := y - (su if y < 20 else 0) + 1
					if yy >= 0 and yy < 24:
						img.set_pixel(k * LATO + x, r * 24 + yy, col(String(dove[0]), int(dove[1])))
	return img


# ---------------------------------------------------------------- tutto, su file

func tutte() -> Dictionary:
	var fogli := {
		"sabbia": terreno("sabbia"),
		"terra": terreno("terra"),
		"erba": terreno("erba"),
		"prato": terreno("prato"),
		"prato_varianti": varianti("prato"),
		"sabbia_varianti": varianti("sabbia"),
		"terra_varianti": varianti("terra"),
		"erba_varianti": varianti("erba"),
		"acqua": acqua(),
		"rupe": rupe(),
		"personaggio": personaggio(),
	}
	var cose := oggetti()
	for nome: String in cose:
		fogli[nome] = cose[nome]
	return fogli


func carica() -> Dictionary:
	# i PNG della cartella del bioma vincono; quelli che mancano si disegnano qui
	var disegnate := tutte()
	var cartella := "res://art/pianeti/".path_join(bioma)
	var fogli := {}
	for nome: String in disegnate:
		var percorso := cartella.path_join(nome + ".png")
		var img: Image = disegnate[nome]
		if FileAccess.file_exists(percorso):
			var letta := Image.load_from_file(percorso)
			if letta != null and not letta.is_empty():
				letta.convert(Image.FORMAT_RGBA8)
				img = letta
		fogli[nome] = img
	return fogli
