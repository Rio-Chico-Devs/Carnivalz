extends RefCounted
# I MATTONI DELLA PROPOSTA DI SCHERMATA (ProposteScontro.gd): la diagonale, la
# carta di sbieco, le barre, le scritte. Provvisorio come la proposta.
#
# LA DIAGONALE E' LA SPINA DELLA SCHERMATA. Il lato destro del cartellone, il
# lato sinistro delle schede e del programma corrono tutti paralleli, a
# GOLA pixel l'uno dall'altro: una riga sola che taglia lo schermo dall'alto a
# destra al basso a sinistra, fra la creatura e chi la sfida. E' il «faccia a
# faccia» dei manifesti degli incontri, ed e' anche il metodo di Bru per un
# set: prima il tema, poi angoli e geometrie coerenti per tutti i pezzi.

const PENDENZA := 0.13       # di quanto rientra la diagonale per ogni pixel che scende
const GOLA := 26.0           # lo stacco fra il cartellone e la squadra, in orizzontale
const ALTO := 24.0           # dove comincia tutto, in alto
const DESTRA_CARTELLONE := 806.0   # dove sta, in alto, il lato destro del cartellone
# il vuoto delle barre sui fogli: il chiaro del box. Col grigio del retino
# l'aura color ruggine gli stava a 2,7 di contrasto, e il pieno si confondeva
const VUOTO_SU_CARTA := "box_fondo"


static func diagonale(y: float, scarto := 0.0) -> float:
	# la x della spina all'altezza y: il lato destro del cartellone, o (scarto =
	# GOLA) il lato sinistro di quello che sta dall'altra parte
	return DESTRA_CARTELLONE + scarto - PENDENZA * (y - ALTO)


static func sbieco(r: Rect2) -> PackedVector2Array:
	# un rettangolo col lato sinistro sulla diagonale: in alto sta dove dice r,
	# in basso rientra di PENDENZA per l'altezza
	return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end,
			Vector2(r.position.x - PENDENZA * r.size.y, r.end.y)])


static func sposta(punti: PackedVector2Array, di: Vector2) -> PackedVector2Array:
	var spostati := PackedVector2Array()
	for p in punti:
		spostati.append(p + di)
	return spostati


static func carta(tela: CanvasItem, punti: PackedVector2Array, tinta: Color, spessore := 4.0, ombra := true) -> void:
	# IL FOGLIO DEL MANIFESTO SU UNA FORMA QUALUNQUE: l'ombra piena spostata, il
	# contorno nero, il pieno. Come Manifesto.carta, ma di sbieco
	var nero := Stile.colore("bordo")
	if ombra:
		Manifesto.poligono(tela, sposta(punti, Manifesto.OMBRA), nero)
	Manifesto.poligono(tela, punti, nero)
	Manifesto.poligono(tela, Manifesto.scosta(punti, -spessore), tinta)


static func scritta(tela: CanvasItem, font: Font, dove: Vector2, testo: String, corpo: int, tinta: Color,
		allinea := HORIZONTAL_ALIGNMENT_LEFT) -> float:
	# una riga di testo con la linea di base in "dove"; centrata o a destra
	# rispetto a dove. Torna quanto e' larga
	var largo := font.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
	var x := dove.x
	if allinea == HORIZONTAL_ALIGNMENT_CENTER:
		x -= largo * 0.5
	elif allinea == HORIZONTAL_ALIGNMENT_RIGHT:
		x -= largo
	tela.draw_string(font, Vector2(x, dove.y), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, tinta)
	return largo


static func barra(tela: CanvasItem, r: Rect2, quota: float, tinta: Color, ignota := false, prenota := 0.0,
		su_carta := false) -> void:
	# UNA BARRA DEL MANIFESTO: il telaio nero, il vuoto, il pieno.
	# "ignota": la vita di chi non hai ancora studiato. La barra c'e' - sai che
	# una vita ce l'ha - ma il pieno e' coperto da un tratteggio: e' lo studio a
	# toglierlo. "prenota": quanto costerebbe la mossa che stai guardando, in
	# quota della barra (chi chiama ci mette il suo battito).
	# "su_carta": SUL FOGLIO CHIARO IL PIENO E' SCURO. Sull'arancio il vuoto e'
	# quasi nero e il pieno chiaro; su un foglio chiaro una barra piena e chiara
	# si legge vuota - e' la prima cosa che si e' vista nello scatto. Li' il vuoto
	# e' il chiaro del foglio (VUOTO_SU_CARTA) e il pieno ha la tinta
	var nero := Stile.colore("bordo")
	tela.draw_rect(r.grow(3.0), nero)
	var vuoto := Stile.colore(VUOTO_SU_CARTA) if su_carta else Stile.colore("barra_vuota")
	var dentro := r.grow(-1.5) if su_carta else r
	tela.draw_rect(dentro, vuoto)
	if ignota:
		tratteggio(tela, dentro, Stile.colore("tratto"))
		return
	var pieno := Rect2(dentro.position, Vector2(dentro.size.x * clampf(quota, 0.0, 1.0), dentro.size.y))
	tela.draw_rect(pieno, tinta)
	if prenota > 0.0:
		var quanto := minf(prenota, quota) * dentro.size.x
		# il pezzo che spenderesti: il pieno a righe, che si legge "questo se ne va"
		var pezzo := Rect2(Vector2(pieno.end.x - quanto, dentro.position.y), Vector2(quanto, dentro.size.y))
		tela.draw_rect(pezzo, vuoto)
		tratteggio(tela, pezzo, tinta)


static func tratteggio(tela: CanvasItem, r: Rect2, tinta: Color) -> void:
	# righe di sbieco, parallele alla spina della schermata, dentro r
	var passo := maxf(r.size.y * 0.8, 7.0)
	var x := r.position.x - r.size.y
	while x < r.end.x:
		var a := Vector2(x, r.end.y)
		var b := Vector2(x + r.size.y, r.position.y)
		var taglio_a := a
		var taglio_b := b
		if taglio_a.x < r.position.x:
			taglio_a = a.lerp(b, (r.position.x - a.x) / (b.x - a.x))
		if taglio_b.x > r.end.x:
			taglio_b = a.lerp(b, (r.end.x - a.x) / (b.x - a.x))
		if taglio_b.x > taglio_a.x:
			tela.draw_line(taglio_a, taglio_b, tinta, maxf(r.size.y * 0.22, 2.0), true)
		x += passo


static func etichetta(tela: CanvasItem, dove: Vector2, testo: String, corpo: int, fondo := Color(0, 0, 0, 0),
		inchiostro := Color(0, 0, 0, 0)) -> Vector2:
	# l'etichetta del manifesto (Manifesto.etichetta_tinta) che dice anche quanto
	# e' venuta grande: serve a mettergli accanto la cosa dopo
	var f := Caratteri.titolo()
	var nero := Stile.colore("bordo") if fondo.a <= 0.0 else fondo
	var chiaro := Stile.colore("manifesto") if inchiostro.a <= 0.0 else inchiostro
	Manifesto.etichetta_tinta(tela, dove, testo, corpo, nero, chiaro)
	return Vector2(f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo, corpo * 1.3)
