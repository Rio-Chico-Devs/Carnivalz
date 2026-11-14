extends Node2D
# L'ERBA AI PIEDI. Quando lei cammina sull'erba, l'erba le copre le scarpe e a
# ogni passo saltano su dei fili, come nei vecchi Zelda.
#
# I ciuffi davanti ai piedi sono i pixel della mappa stessa, presi sotto i
# piedi e ritagliati a punte (alte da 2 a 5 pixel, frastagliate), con la punta
# di ogni filo un poco piu' chiara: hanno i colori dell'erba di quel punto,
# qualunque erba sia. Si disegnano solo sopra di lei (sopra i pixel pieni del
# suo fotogramma), cosi' attorno ai piedi non resta nessun alone. Camminando
# ondeggiano (le punte si spostano di un pixel a ogni mezzo passo); da ferma,
# piano, ogni tanto.
# I fili che saltano nascono a ogni appoggio del piede (ogni 20 pixel di
# strada: il passo ha otto tempi da 5 pixel, il piede tocca terra al primo e al
# quinto): giallo-verdi, piu' chiari dell'erba piu' chiara li' attorno, saltano
# all'indietro e ricadono sparendo.
#
# Cos'e' erba lo dice la regola del livello (nella pianta, "erba"): tinta,
# saturazione minima e luce del colore della mappa sotto i piedi. Su strade,
# pietra, sabbia e acqua non succede niente; dove l'erba finisce (al bordo di
# una strada) i ciuffi ci sono solo sui pixel d'erba.
#
# Chi lo usa: un nodo nel mondo ordinato per piede (y_sort), accanto a lei;
# prepara() una volta, aggiorna() a ogni fotogramma con lo sprite di lei.

const LARGO := 18                # i ciuffi: larghi 18 pixel del mondo,
const MEZZO := 9                 # (meta' a sinistra dei piedi)
const ALTO := 7                  # alti 7, fino a 2 sotto la linea dei piedi
const SOTTO := 2
const ALTEZZE := [2, 4, 3, 5, 2, 3, 4, 2, 4, 3, 5, 2, 3, 4, 2, 5, 3, 2]   # le punte, colonna per colonna
const PUNTA := 0.28              # quanto e' piu' chiara la punta di ogni filo
const PASSO_PIEDE := 20.0        # la strada fra un appoggio e l'altro
const FILI_PER_PASSO := 4
const GRAVITA := 190.0
const RESPIRO_ERBA := 0.9        # da ferma, ogni quanto ondeggia

var mappa: Image
var scala := 1.0                 # pixel del mondo per pixel della mappa
var tinta := Vector2(0.2, 0.47)
var saturazione := 0.42
var luce := Vector2(0.1, 0.85)
var attiva := false

var su_erba := false
var trama: ImageTexture
var foto: Image
var angolo := Vector2i.ZERO      # dove sono stati presi i ciuffi (pixel del mondo)
var oscilla := 0
var fermo := 0.0
var ultimo_appoggio := -1
var fili: Array[Dictionary] = []             # {p, v, eta, vita, colore, lungo}
var caso := RandomNumberGenerator.new()
var foglio: Image                # il foglio di lei, per sapere dove e' piena
var foglio_di: Texture2D


func prepara(immagine: Image, scala_mappa: float, regola: Dictionary) -> void:
	mappa = immagine
	scala = scala_mappa
	attiva = mappa != null and not regola.is_empty()
	if not attiva:
		return
	var t: Array = regola.get("tinta", [0.2, 0.47])
	tinta = Vector2(float(t[0]), float(t[1]))
	saturazione = float(regola.get("saturazione", 0.42))
	var l: Array = regola.get("luce", [0.1, 0.85])
	luce = Vector2(float(l[0]), float(l[1]))
	foto = Image.create_empty(LARGO, ALTO, false, Image.FORMAT_RGBA8)
	trama = ImageTexture.create_from_image(foto)
	caso.seed = 7


func e_erba_qui(mx: int, my: int) -> bool:
	if mx < 0 or my < 0 or mx >= mappa.get_width() or my >= mappa.get_height():
		return false
	var c: Color = mappa.get_pixel(mx, my)
	return c.a > 0.5 and c.h >= tinta.x and c.h <= tinta.y and c.s >= saturazione \
		and c.v >= luce.x and c.v <= luce.y


func e_erba(p: Vector2) -> bool:
	return e_erba_qui(floori(p.x / scala), floori(p.y / scala))


func aggiorna(piedi: Vector2, verso: Vector2i, passo: float, delta: float, lei: Sprite2D) -> void:
	if not attiva:
		return
	var qui := piedi.round()
	position = qui + Vector2(0, 1)           # nell'ordine per piede: subito dopo di lei
	var quanti := 0
	for o: Vector2 in [Vector2(-4, -1), Vector2(4, -1), Vector2.ZERO, Vector2(-3, 2), Vector2(3, 2)]:
		if e_erba(qui + o):
			quanti += 1
	su_erba = quanti >= 3
	# gli appoggi del piede: i fili saltano
	if passo <= 0.0:
		ultimo_appoggio = -1
		fermo += delta
		oscilla = int(fermo / RESPIRO_ERBA) % 2
	else:
		fermo = 0.0
		oscilla = floori(passo / (PASSO_PIEDE * 0.5)) % 2
		var appoggio := floori(passo / PASSO_PIEDE)
		if appoggio != ultimo_appoggio:
			ultimo_appoggio = appoggio
			if su_erba:
				fai_saltare(qui, verso, appoggio)
	# i ciuffi davanti ai piedi (a ogni fotogramma: lei cambia posa)
	if su_erba:
		prendi_i_ciuffi(Vector2i(int(qui.x) - MEZZO, int(qui.y) - (ALTO - SOTTO)), lei)
	# i fili in aria
	for f in fili:
		f["eta"] = float(f["eta"]) + delta
		var v: Vector2 = f["v"]
		v.y += GRAVITA * delta
		f["v"] = v
		f["p"] = (f["p"] as Vector2) + v * delta
	fili = fili.filter(func(f: Dictionary) -> bool: return float(f["eta"]) < float(f["vita"]))
	queue_redraw()


func pieno_di_lei(lei: Sprite2D, w: Vector2i) -> bool:
	# il pixel w (del mondo) e' pieno nel fotogramma di lei?
	if lei == null or lei.texture == null:
		return true
	if foglio_di != lei.texture:
		foglio_di = lei.texture
		foglio = lei.texture.get_image()
		if foglio != null and foglio.is_compressed():
			foglio.decompress()
	if foglio == null:
		return true
	var largo := floori(foglio.get_width() / float(lei.hframes))
	var alto := floori(foglio.get_height() / float(lei.vframes))
	var dentro := Vector2(w) + Vector2(0.5, 0.5) - lei.position - lei.offset
	var x := int(floor(dentro.x)); var y := int(floor(dentro.y))
	if x < 0 or y < 0 or x >= largo or y >= alto:
		return false
	if lei.flip_h:
		x = largo - 1 - x
	return foglio.get_pixel((lei.frame % lei.hframes) * largo + x, floori(lei.frame / float(lei.hframes)) * alto + y).a > 0.5


func prendi_i_ciuffi(da: Vector2i, lei: Sprite2D) -> void:
	angolo = da
	foto.fill(Color(0, 0, 0, 0))
	for i in LARGO:
		var alto: int = ALTEZZE[(i + oscilla) % ALTEZZE.size()]
		for j in range(ALTO - alto, ALTO):
			var w := Vector2i(da.x + i, da.y + j)
			var mx := floori(w.x / scala)
			var my := floori(w.y / scala)
			if e_erba_qui(mx, my) and pieno_di_lei(lei, w):
				var c: Color = mappa.get_pixel(mx, my)
				foto.set_pixel(i, j, c.lightened(PUNTA) if j == ALTO - alto else c)
	trama.update(foto)


func fai_saltare(qui: Vector2, verso: Vector2i, appoggio: int) -> void:
	# il piede che si appoggia: uno e l'altro a turno
	var lato := -1.0 if appoggio % 2 == 0 else 1.0
	var piede := qui + (Vector2(lato * 3.0, 0.0) if verso.x == 0 else Vector2(float(verso.x) * (2.0 if appoggio % 2 == 0 else -1.0), lato))
	var chiaro := colore_chiaro(qui)
	for k in FILI_PER_PASSO:
		var v := Vector2(caso.randf_range(-22.0, 22.0), caso.randf_range(-70.0, -48.0))
		v -= Vector2(verso) * 14.0           # l'erba schizza un poco indietro
		var c := chiaro.lightened(caso.randf_range(0.25, 0.45))
		fili.append({"p": piede + Vector2(caso.randf_range(-2.0, 2.0), caso.randf_range(-1.0, 1.0)), "v": v,
			"eta": 0.0, "vita": caso.randf_range(0.40, 0.55), "colore": c, "lungo": 2})


func colore_chiaro(qui: Vector2) -> Color:
	# il colore d'erba piu' chiaro attorno ai piedi
	var meglio := Color(0.3, 0.55, 0.25)
	var lum := -1.0
	for dy in range(-4, 4):
		for dx in range(-8, 9, 2):
			var mx := floori((qui.x + dx) / scala)
			var my := floori((qui.y + dy) / scala)
			if e_erba_qui(mx, my):
				var c: Color = mappa.get_pixel(mx, my)
				if c.get_luminance() > lum:
					lum = c.get_luminance(); meglio = c
	return meglio


func _draw() -> void:
	if not attiva:
		return
	if su_erba:
		draw_texture(trama, Vector2(angolo) - position)
	for f in fili:
		var eta := float(f["eta"]) / float(f["vita"])
		var c: Color = f["colore"]
		c.a = 1.0 if eta < 0.6 else 1.0 - (eta - 0.6) / 0.4
		draw_rect(Rect2(((f["p"] as Vector2) - position).round(), Vector2(1, int(f["lungo"]))), c)
