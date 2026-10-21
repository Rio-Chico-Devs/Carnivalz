class_name LetteraBond
extends Node2D
# UNA LETTERA DEL BOND (LuceBond.gd): bianca, perche' il colore glielo da' la
# doratura del suo CanvasGroup, e col suo contorno VERO, letto dal font. La luce
# ci sale sopra prima che la lettera si riempia: due punte partono dal punto
# piu' basso di ogni giro del contorno (anche i buchi della B, della O e della
# D) e si incontrano dall'altra parte.
#
# Il font scrive il contorno a punti sulla curva e punti di controllo, curve di
# secondo grado: qui diventa una spezzata, che parte dal punto piu' basso, con
# la strada fatta fino a ogni punto per sapere dove sono le punte.

var font: Font
var segno := ""
var corpo := 100
var largo := 0.0
var posto := Vector2.ZERO       # dove sta, posata
var luce := 1.0                 # quanto c'e'
var traccia := 0.0              # quanto e' salita la luce lungo il contorno (0..1)
var traccia_luce := 1.0         # e quanto si vede
var contorni: Array[PackedVector2Array] = []   # attorno al centro della lettera
var lunghezze: Array[PackedFloat32Array] = []  # la strada fino a ogni punto


func _init(carattere: Font, quale: String, grande: int, dove: Vector2, larghezza: float) -> void:
	font = carattere
	segno = quale
	corpo = grande
	posto = dove
	largo = larghezza
	position = dove
	leggi_contorni()


func origine() -> Vector2:
	# dove comincia il glifo, rispetto al centro della lettera: le maiuscole
	# sono alte sette decimi del corpo
	return Vector2(-largo * 0.5, corpo * 0.35)


func _draw() -> void:
	if luce > 0.0:
		draw_string(font, origine(), segno, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Color(1, 1, 1, luce))


func leggi_contorni() -> void:
	if font == null or segno == "":
		return
	var ts := TextServerManager.get_primary_interface()
	var rid: RID = font.get_rids()[0]
	var glifo := ts.font_get_glyph_index(rid, corpo, segno.unicode_at(0), 0)
	var dati := ts.font_get_glyph_contours(rid, corpo, glifo)
	var punti: PackedVector3Array = dati.get("points", PackedVector3Array())
	var fini: PackedInt32Array = dati.get("contours", PackedInt32Array())
	var da := 0
	for fine in fini:
		var giro := dal_basso(appiattisci(punti, da, fine))
		for k in giro.size():
			giro[k] += origine()
		if giro.size() >= 2:
			contorni.append(giro)
			lunghezze.append(misura(giro))
		da = fine + 1


static func appiattisci(punti: PackedVector3Array, da: int, a: int) -> PackedVector2Array:
	# fra due punti di controllo di fila c'e' un punto sulla curva sottinteso,
	# a meta'. Il terzo numero di ogni punto dice di che tipo e' (1 sulla curva)
	var quanti := a - da + 1
	var fuori := PackedVector2Array()
	var primo := -1
	for k in quanti:
		if (int(punti[da + k].z) & 1) == 1:
			primo = k
			break
	if primo < 0:
		return fuori
	var corrente := Vector2(punti[da + primo].x, punti[da + primo].y)
	fuori.append(corrente)
	var controllo := Vector2.ZERO
	var in_sospeso := false
	for passo in range(1, quanti + 1):
		var p := punti[da + (primo + passo) % quanti]
		var q := Vector2(p.x, p.y)
		if (int(p.z) & 1) == 1:
			fuori.append_array(curva(corrente, controllo, q) if in_sospeso else PackedVector2Array([q]))
			in_sospeso = false
			corrente = q
		elif in_sospeso:
			var mezzo := (controllo + q) * 0.5
			fuori.append_array(curva(corrente, controllo, mezzo))
			corrente = mezzo
			controllo = q
		else:
			controllo = q
			in_sospeso = true
	if fuori.size() > 1 and fuori[0].is_equal_approx(fuori[fuori.size() - 1]):
		fuori.remove_at(fuori.size() - 1)
	return fuori


static func curva(a: Vector2, c: Vector2, b: Vector2) -> PackedVector2Array:
	var fatto := PackedVector2Array()
	for k in range(1, 7):
		var t := float(k) / 6.0
		fatto.append(a.lerp(c, t).lerp(c.lerp(b, t), t))
	return fatto


static func dal_basso(giro: PackedVector2Array) -> PackedVector2Array:
	# il giro comincia dal punto piu' basso, e si chiude tornandoci
	if giro.is_empty():
		return giro
	var basso := 0
	for k in giro.size():
		if giro[k].y > giro[basso].y:
			basso = k
	var fatto := giro.slice(basso)
	fatto.append_array(giro.slice(0, basso))
	fatto.append(giro[basso])
	return fatto


static func misura(giro: PackedVector2Array) -> PackedFloat32Array:
	var fatto := PackedFloat32Array()
	var strada := 0.0
	for k in giro.size():
		if k > 0:
			strada += giro[k].distance_to(giro[k - 1])
		fatto.append(strada)
	return fatto


static func punto_a(giro: PackedVector2Array, strada: PackedFloat32Array, s: float) -> Vector2:
	# il punto del giro a quella strada dalla partenza
	var k := clampi(strada.bsearch(s), 1, giro.size() - 1)
	var t := (s - strada[k - 1]) / maxf(strada[k] - strada[k - 1], 0.001)
	return giro[k - 1].lerp(giro[k], clampf(t, 0.0, 1.0))


static func tratto(giro: PackedVector2Array, strada: PackedFloat32Array, da: float, a: float) -> PackedVector2Array:
	# il pezzo di giro fra due strade
	var fatto := PackedVector2Array([punto_a(giro, strada, da)])
	for k in giro.size():
		if strada[k] > da and strada[k] < a:
			fatto.append(giro[k])
	fatto.append(punto_a(giro, strada, a))
	return fatto


func punte(c: int) -> Array[Vector2]:
	# dove sono adesso le due punte di luce sul giro c
	var giro := contorni[c]
	var strada := lunghezze[c]
	var tutta := strada[strada.size() - 1]
	var fin_qui := tutta * 0.5 * traccia
	return [punto_a(giro, strada, fin_qui), punto_a(giro, strada, tutta - fin_qui)]


func tratti(c: int) -> Array[PackedVector2Array]:
	# la luce gia' salita sul giro c: due pezzi, uno per verso
	var giro := contorni[c]
	var strada := lunghezze[c]
	var tutta := strada[strada.size() - 1]
	var fin_qui := tutta * 0.5 * traccia
	return [tratto(giro, strada, 0.0, fin_qui), tratto(giro, strada, tutta - fin_qui, tutta)]
