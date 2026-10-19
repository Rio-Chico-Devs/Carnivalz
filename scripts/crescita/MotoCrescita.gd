extends "res://scripts/crescita/RuotaCrescita.gd"

# I PEZZI DELLA CRESCITA CHE SI MUOVONO, dai film approvati (prove/FilmSalita.gd):
# il punto che vola dal contatore alla tasca, il timbro che cade e il mozzo che
# rotola, le luci del giro chiuso, la crepa e le due meta' che volano via
# scoprendo la ruota nuova, il nome del giro come un timbro, e la lastra nera
# che passa fra un momento e l'altro.

func ruota_sotto(t: CanvasItem, g: int, v: float) -> void:
	# il campo, la ruota, il mozzo, e sopra i pezzi che si muovono
	var tm := tema(g)
	match String(tm["campo"]):
		"nero":
			t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
			Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.07), Vector2(1.0, 1.0))
		"carta":
			t.draw_rect(Rect2(0, 0, 1280, 720), P.CREMA)
			Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.NERO, 0.07), Vector2(1.0, 1.0))
	ruota_giro(t, tm, g, v)
	luci_del_giro(t, g, v)
	tasca_timbrata(t, tm, g, v)
	bagliore(t)
	mozzo(t, tm, g)
	if accendi_a >= 0.0 and g == giro_di(adesso) and tempo - accendi_a > 0.8 and spacca_a < 0.0:
		var testo := "COMPLETO" if adesso < tetto() or not beta() else "TETTO DELLA BETA"
		P.etichetta(t, CENTRO + Vector2(-(P.larghezza(testo, 18) + 20.0) * 0.5, 84), testo, 18, P.ARANCIO, P.NERO)
	legenda(t)


func centro_della_tasca(g: int, v: float, livello: int) -> Array:
	# dove sta una tasca, come la mette ruota_giro: angolo, quanto esce, centro
	var passo := TAU / spicchi_del_giro(g)
	var a := PI + passo * (livello - v)
	var fuori := maxf(0.0, 1.0 - absf(livello - v))
	var o := CENTRO + Vector2.from_angle(a) * 12.0 * fuori
	return [a, fuori, o, o + Vector2.from_angle(a) * (R_DENTRO + R_FUORI + 40.0 * fuori) * 0.5]


func tasca_timbrata(t: CanvasItem, tm: Dictionary, g: int, v: float) -> void:
	# il timbro: la tasca presa, nei colori delle prese, cade dall'alto (piu'
	# grande e trasparente) e resta. Sotto la lancetta la ruota mostra le tasche
	# chiare, prese o no: il timbro la tiene scura finche' non se ne va
	if timbro_a < 0.0 or tempo < timbro_a or giro_di(livello_timbrato) != g:
		return
	var k := clampf((tempo - timbro_a) / CADE, 0.0, 1.0)
	var dove: Array = centro_della_tasca(g, v, livello_timbrato)
	var a := float(dove[0])
	var fuori := float(dove[1])
	var mezzo := TAU / spicchi_del_giro(g) * 0.5 - deg_to_rad(1.1) + 0.04 * fuori
	var c: Vector2 = dove[3]
	var alfa := clampf(k * 2.5, 0.0, 1.0)
	P.gira(t, c, 0.0, lerpf(2.1, 1.0, k * k))
	var qui: Vector2 = dove[2] - c
	P.spicchio(t, qui, R_DENTRO + 4.0 * fuori, R_FUORI + 36.0 * fuori, a - mezzo, a + mezzo, velo(tm["presa"], alfa),
			velo(P.NERO, alfa), 3.0)
	var lato := 42.0 * sqrt(20.0 / spicchi_del_giro(g))
	simbolo_tasca(t, livello_timbrato, Vector2(0, -18) * fuori, lato + 10.0 * fuori, velo(tm["presa_segno"], alfa),
			tm["presa"], velo(tm["presa_ombra"], alfa), true)
	if fuori > 0.0:
		P.scritta(t, Vector2(-40, 12 + 28 * fuori), str(livello_timbrato), roundi(18 + 12 * fuori),
				velo(tm["presa_segno"], alfa), null, HORIZONTAL_ALIGNMENT_CENTER, 80)
	P.dritto(t)
	if timbrato:
		raggi_del_colpo(t, c, clampf((tempo - timbro_a - CADE) / 0.4, 0.0, 1.0), 70.0, P.CREMA)


func bagliore(t: CanvasItem) -> void:
	# il punto arriva nella tasca: si accende d'arancio
	if prendi_a < 0.0 or livello_nuovo > 0:
		return
	var k := (tempo - prendi_a - VOLA) / 0.5
	if k < 0.0 or k > 1.0:
		return
	var g := giro_di(adesso + 1)
	var dove: Array = centro_della_tasca(g, vista, adesso + 1)
	var a := float(dove[0])
	var fuori := float(dove[1])
	var mezzo := TAU / spicchi_del_giro(g) * 0.5 + 0.04 * fuori
	P.spicchio(t, dove[2], R_DENTRO + 4.0 * fuori, R_FUORI + 36.0 * fuori, a - mezzo, a + mezzo,
			Color(P.ARANCIO, 0.75 * (1.0 - k)))
	raggi_del_colpo(t, dove[3], k, 70.0, P.CREMA)


static func raggi_del_colpo(t: CanvasItem, c: Vector2, k: float, r: float, tinta: Color) -> void:
	# il colpo: tratti che scappano dal centro e si spengono
	if k <= 0.0 or k >= 1.0:
		return
	for i in 12:
		var verso := Vector2.from_angle(TAU * i / 12.0 + 0.2)
		var da := c + verso * (r + 60.0 * frena(k))
		var fino := c + verso * (r + 26.0 + 110.0 * frena(k))
		t.draw_line(da, fino, Color(P.NERO, 1.0 - k), 9.0, true)
		t.draw_line(da, fino, Color(tinta, 1.0 - k), 4.0, true)


func luci_del_giro(t: CanvasItem, g: int, v: float) -> void:
	# il giro chiuso si accende: una luce fa il giro delle tasche, come le
	# lampadine della ruota vera, poi lampeggiano tutte insieme
	if accendi_a < 0.0 or g != giro_di(adesso) or spacca_a >= 0.0:
		return
	var tc := tempo - accendi_a
	if tc < 0.0 or tc > 1.5:
		return
	var n := spicchi_del_giro(g)
	var passo := TAU / n
	var mezzo := passo * 0.5 - deg_to_rad(1.1)
	for k in n:
		var livello := primo_del_giro(g) + k
		var luce := clampf(1.0 - absf(tc - k * 0.035) / 0.09, 0.0, 1.0)
		if tc > 0.8:
			luce = maxf(luce, (0.5 + 0.5 * cos((tc - 0.8) * TAU * 2.5)) * (1.0 - (tc - 0.8) / 0.7))
		if luce <= 0.0:
			continue
		var a := PI + passo * (livello - v)
		P.spicchio(t, CENTRO, R_DENTRO, R_ORLO, a - mezzo, a + mezzo, Color(P.ARANCIO, 0.9 * luce))


func punto_che_vola(t: CanvasItem) -> void:
	# PRENDI: il punto lascia il contatore e vola nella tasca sotto la lancetta
	if prendi_a < 0.0 or livello_nuovo > 0:
		return
	var k := (tempo - prendi_a) / VOLA
	if k < 0.0 or k >= 1.0:
		return
	var e := k * k * (3.0 - 2.0 * k)
	var da := GETTONI + Vector2(PASSO_GETTONE * (punti_prima - 1), 0)
	var fino: Vector2 = centro_della_tasca(giro_di(adesso + 1), vista, adesso + 1)[3]
	var arco := Vector2(430, -70)
	for scia in 3:
		var s := maxf(e - 0.07 * (scia + 1), 0.0)
		var q := da.lerp(arco, s).lerp(arco.lerp(fino, s), s)
		P.rombo(t, q, 10.0 + 8.0 * s, Color(P.ARANCIO, 0.45 - 0.13 * scia))
	var dove := da.lerp(arco, e).lerp(arco.lerp(fino, e), e)
	P.gira(t, dove, 360.0 * e)
	P.rombo(t, Vector2(5, 5), 15.0 + 13.0 * sin(e * PI), P.NERO)
	P.rombo(t, Vector2.ZERO, 15.0 + 13.0 * sin(e * PI), P.ARANCIO, P.NERO, 3.0)
	P.dritto(t)


func scatto(t: CanvasItem, testo: String, k: float) -> void:
	# il tasto premuto: un contorno che si allarga dall'etichetta e si spegne
	if k <= 0.0 or k >= 1.0:
		return
	var r := Rect2(PRENDI_A, Vector2(P.larghezza(testo, 26) + 26.0 * 1.1, 26.0 * 1.35))
	t.draw_rect(r.grow(4.0 + 26.0 * frena(k)), Color(P.ARANCIO, 1.0 - k), false, 4.0)


# --- oltre il giro: la ruota si spacca -----------------------------------------------------------

func crepa(t: CanvasItem, k: float) -> void:
	# la crepa parte dal mozzo e corre lungo il taglio del bivio, nei due versi
	var a_lato := Vector2(-TAGLIO.y, TAGLIO.x)
	var lungo := 460.0 * frena(k)
	for verso: float in [-1.0, 1.0]:
		var linea := PackedVector2Array([CENTRO])
		var s := 0.0
		var i := 0
		while s < lungo:
			s = minf(s + 22.0, lungo)
			i += 1
			linea.append(CENTRO + TAGLIO * s * verso + a_lato * (6.0 if i % 2 == 0 else -6.0))
		if linea.size() > 1:
			t.draw_polyline(linea, P.NERO, 11.0, true)
			t.draw_polyline(linea, P.CREMA, 4.0, true)


func meta_che_volano(t: CanvasItem, k: float) -> void:
	# le due meta' della ruota vecchia (la sua immagine, dal SubViewport): una
	# vola in alto a sinistra, l'altra in basso a destra, e sotto c'e' la nuova
	if k >= 1.0:
		return
	var e := k * k
	var a_lato := Vector2(-TAGLIO.y, TAGLIO.x)
	var cima := CENTRO + TAGLIO * (-CENTRO.y / TAGLIO.y)
	var fondo_taglio := CENTRO + TAGLIO * ((Tavola.ALTO - CENTRO.y) / TAGLIO.y)
	var pezzi := [PackedVector2Array([Vector2(0, 0), cima, fondo_taglio, Vector2(0, Tavola.ALTO)]),
			PackedVector2Array([cima, Vector2(Tavola.LARGO, 0), Vector2(Tavola.LARGO, Tavola.ALTO), fondo_taglio])]
	var immagine := vecchia.get_texture()
	for lato in 2:
		var verso := -1.0 if lato == 0 else 1.0
		var via := (a_lato * 950.0 - TAGLIO * 330.0) * verso * e
		var giro := deg_to_rad(10.0) * verso * e
		var uv := PackedVector2Array()
		var dove := PackedVector2Array()
		var ombra := PackedVector2Array()
		for punto: Vector2 in pezzi[lato]:
			uv.append(punto / Vector2(Tavola.LARGO, Tavola.ALTO))
			var q := CENTRO + (punto - CENTRO).rotated(giro) + via
			dove.append(q)
			ombra.append(q + Vector2(16, 16))
		Manifesto.poligono(t, ombra, Color(P.NERO, 0.45))
		t.draw_colored_polygon(dove, Color.WHITE, uv, immagine)
		# il bordo del taglio, come cartone tagliato
		t.draw_line(dove[1] if lato == 0 else dove[0], dove[2] if lato == 0 else dove[3], P.ARANCIO, 8.0, true)


func fascia_del_giro(t: CanvasItem) -> void:
	# scoperta la ruota nuova, il suo nome arriva come un timbro, poi se ne va
	if spacca_a < 0.0:
		return
	var k := tempo - spacca_a - 0.75
	if k < 0.0 or k > 1.95:
		return
	var g := giro_di(guardato)
	var tm := tema(g)
	var entra_qui := rimbalza(clampf(k / 0.35, 0.0, 1.0))
	var esce := frena(clampf((k - 1.6) / 0.35, 0.0, 1.0))
	P.gira(t, CENTRO + Vector2(40 + 1100.0 * esce, 10), -6.0, lerpf(1.8, 1.0, entra_qui))
	var fascia := PackedVector2Array([Vector2(-420, -120), Vector2(460, -120), Vector2(420, 130), Vector2(-460, 130)])
	var ombra := PackedVector2Array()
	for punto in fascia:
		ombra.append(punto + Vector2(12, 12))
	Manifesto.poligono(t, ombra, P.ARANCIO)
	P.lastra(t, fascia, P.NERO, P.CREMA, 14.0)
	P.scritta(t, Vector2(-440, -40), ROMANI[mini(g, ROMANI.size() - 1)], 96, Color(P.ARANCIO, 0.9), Caratteri.titolo(),
			HORIZONTAL_ALIGNMENT_CENTER, 880)
	var nome := String(tm["nome"])
	P.ritagliata(t, Vector2(-440, 30), nome, P.corpo_che_entra(nome, 80, 780.0), P.CREMA, P.NERO, 0, P.ARANCIO,
			Vector2(8, 8), null, HORIZONTAL_ALIGNMENT_CENTER, 880)
	P.scritta(t, Vector2(-440, 74), "LIVELLI %d–%d" % [primo_del_giro(g), ultimo_del_giro(g)], 26, P.ARANCIO, null,
			HORIZONTAL_ALIGNMENT_CENTER, 880)
	var accende := rimbalza(clampf((k - 0.3) / 0.25, 0.0, 1.0))
	for i in giri():
		var q := Vector2((i - (giri() - 1) * 0.5) * 30.0, 106)
		if i < g:
			P.rombo(t, q, 9.0, P.CREMA)
		elif i == g:
			P.rombo(t, q, 12.0 * accende, P.ARANCIO, P.CREMA, 2.0)
		else:
			P.rombo(t, q, 8.0, Color(0, 0, 0, 0), Color(P.CREMA, 0.3), 2.0)
	P.dritto(t)


func disegna_tendina(t: CanvasItem) -> void:
	# la lastra nera che passa da sinistra a destra: a meta' copre tutto
	if tendina_a < 0.0:
		return
	var q := (tempo - tendina_a) / TENDINA
	if q <= 0.0 or q >= 1.0:
		return
	var x := lerpf(-1900.0, 1500.0, smoothstep(0.0, 1.0, q))
	var forma := PackedVector2Array([Vector2(x, -20), Vector2(x + 1700, -20), Vector2(x + 1500, 740), Vector2(x - 200, 740)])
	var dietro := PackedVector2Array()
	for punto in forma:
		dietro.append(punto + Vector2(-26, 0))
	Manifesto.poligono(t, dietro, P.ARANCIO)
	P.lastra(t, forma, P.NERO, P.CREMA, 18.0)
