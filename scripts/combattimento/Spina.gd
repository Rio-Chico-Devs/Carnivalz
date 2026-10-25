class_name SpinaPlancia
extends RefCounted
# LA DIAGONALE DELLA SCHERMATA DI COMBATTIMENTO, e i mattoni per disegnarci
# sopra (Plancia.gd).
#
# Bru, sulla proposta «il manifesto di un incontro» (docs/scontro_proposta.md):
# «non è male», poi, rifatta coi tre personaggi, i pugni radi e l'ECG grande,
# «sì mi piace», e «sì dai» a portarla nel gioco.
#
# LA DIAGONALE E' LA SPINA DELLA SCHERMATA. Il lato destro del cartellone della
# creatura, il lato sinistro delle schede della squadra e del programma dei
# comandi corrono paralleli, a una gola l'uno dall'altro: una riga sola che
# taglia lo schermo dall'alto a destra al basso a sinistra, fra la creatura e
# chi la sfida. E' il «faccia a faccia» dei manifesti degli incontri, ed e' il
# metodo di Bru per un set: prima il tema, poi angoli e geometrie coerenti per
# tutti i pezzi.
#
# LE MISURE SONO SU UN FOGLIO DI 1280x720 (data/stile.json, "plancia"), e la
# plancia le porta alla finestra che c'e' moltiplicando per una scala: un
# foglio di numeri leggibili invece di frazioni a tre cifre, e la stessa
# regola di prima - a qualunque misura, il disegno resta quello. Una scala
# diversa in largo e in alto inclina la diagonale ma la lascia una retta: i
# pezzi restano paralleli.

const FOGLIO := Vector2(1280, 720)
# il vuoto delle barre sui fogli chiari: il chiaro del box. Col grigio del
# retino l'aura color ruggine ci stava a 2,7 di contrasto, e il pieno si
# confondeva col vuoto
const VUOTO_SU_CARTA := "box_fondo"


static func misura(nome: String) -> Variant:
	return Stile.plancia(nome)


static func numero(gruppo: String, nome: String, ripiego: float) -> float:
	var dati: Variant = misura(gruppo)
	if dati is Dictionary:
		return float((dati as Dictionary).get(nome, ripiego))
	return ripiego


static func pendenza() -> float:
	# di quanto rientra la diagonale per ogni pixel che scende, sul foglio
	return numero("spina", "pendenza", 0.13)


static func gola() -> float:
	return numero("spina", "gola", 26.0)


static func alto() -> float:
	return numero("spina", "alto", 24.0)


static func diagonale(y: float, scarto := 0.0) -> float:
	# la x della spina all'altezza y, sul foglio: il lato destro del cartellone,
	# o (scarto = gola) il lato sinistro di quello che sta dall'altra parte
	return numero("spina", "destra", 806.0) + scarto - pendenza() * (y - alto())


# --- i mattoni del disegno, in pixel della tela ------------------------------

static func sbieco(r: Rect2, pendenza_px: float) -> PackedVector2Array:
	# un rettangolo col lato sinistro sulla diagonale: in alto sta dove dice r,
	# in basso rientra di pendenza_px per ogni pixel d'altezza
	return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end,
			Vector2(r.position.x - pendenza_px * r.size.y, r.end.y)])


static func sposta(punti: PackedVector2Array, di: Vector2) -> PackedVector2Array:
	var spostati := PackedVector2Array()
	for p in punti:
		spostati.append(p + di)
	return spostati


static func carta(tela: CanvasItem, punti: PackedVector2Array, tinta: Color, spessore := 4.0, ombra := true) -> void:
	# IL FOGLIO DEL MANIFESTO SU UNA FORMA QUALUNQUE: l'ombra piena spostata, il
	# contorno nero, il pieno. Come Manifesto.Carta, ma di sbieco
	var nero := Stile.colore("bordo")
	if ombra:
		Manifesto.poligono(tela, sposta(punti, Manifesto.OMBRA), nero)
	Manifesto.poligono(tela, punti, nero)
	Manifesto.poligono(tela, Manifesto.scosta(punti, -spessore), tinta)


static func barra(tela: CanvasItem, r: Rect2, quota: float, tinta: Color, coda := -1.0, ignota := false,
		prenota := 0.0, vuoto_tinta := VUOTO_SU_CARTA) -> void:
	# UNA BARRA SUL FOGLIO CHIARO: il telaio nero, il vuoto chiaro, il pieno
	# scuro. Sull'arancio il vuoto era quasi nero e il pieno chiaro; su un foglio
	# chiaro una barra piena e chiara si legge vuota - e' la prima cosa che si e'
	# vista nello scatto della proposta.
	# "coda": la scia di quello che hai appena perso (Slot.gd); "ignota": la vita
	# di chi non hai ancora studiato, coperta da un tratteggio che lo studio
	# toglie; "prenota": quanto costerebbe la mossa che stai guardando, in
	# quota; "vuoto_tinta": il vuoto di una barra che non sta su un foglio (la
	# vita della creatura sta sull'arancio, e li' il vuoto e' scuro)
	var nero := Stile.colore("bordo")
	tela.draw_rect(r.grow(3.0), nero)
	var vuoto := Stile.colore(vuoto_tinta)
	var dentro := r.grow(-1.5)
	tela.draw_rect(dentro, vuoto)
	if ignota:
		tratteggio(tela, dentro, Stile.colore("tratto"))
		return
	var pieno := clampf(quota, 0.0, 1.0)
	if coda > pieno:
		tela.draw_rect(Rect2(dentro.position + Vector2(dentro.size.x * pieno, 0.0),
				Vector2(dentro.size.x * (minf(coda, 1.0) - pieno), dentro.size.y)), Stile.colore("negativo"))
	var parte := Rect2(dentro.position, Vector2(dentro.size.x * pieno, dentro.size.y))
	if pieno > 0.0:
		tela.draw_rect(parte, tinta)
	if prenota > 0.0:
		var quanto := minf(prenota, pieno) * dentro.size.x
		# il pezzo che spenderesti: il pieno a righe, che si legge "questo se ne va"
		var pezzo := Rect2(Vector2(parte.end.x - quanto, dentro.position.y), Vector2(quanto, dentro.size.y))
		tela.draw_rect(pezzo, vuoto)
		tratteggio(tela, pezzo, tinta)


static func tratteggio(tela: CanvasItem, r: Rect2, tinta: Color) -> void:
	# righe di sbieco, parallele alla spina, dentro r
	var passo := maxf(r.size.y * 0.55, 5.0)
	var x := r.position.x - r.size.y
	while x < r.end.x:
		var a := Vector2(x, r.end.y)
		var b := Vector2(x + r.size.y, r.position.y)
		# la riga tagliata ai lati del rettangolo
		if a.x < r.position.x:
			a = Vector2(r.position.x, r.end.y - (r.position.x - a.x))
		if b.x > r.end.x:
			b = Vector2(r.end.x, r.position.y + (b.x - r.end.x))
		if b.x > a.x:
			tela.draw_line(a, b, tinta, maxf(r.size.y * 0.16, 1.5), true)
		x += passo


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


# --- un foglio di sbieco, come nodo ------------------------------------------

class FoglioSbieco extends Control:
	# IL FOGLIO SU CUI STA UN PEZZO (il programma, una scheda): "punti" e' la sua
	# forma nelle coordinate del nodo, la mette chi lo dispone
	var punti := PackedVector2Array()
	var tinta := Color.WHITE
	var spessore := 5.0
	var ombra := true

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if punti.size() >= 3:
			SpinaPlancia.carta(self, punti, tinta, spessore, ombra)
