class_name Tratteggio
extends RefCounted

# RIGHE OBLIQUE DENTRO UN RETTANGOLO.
#
# Serve a dire "questa cosa e' di un altro tipo" senza usare la tinta. Nella
# lista di Bertin e' TESSITURA, ed e' una delle poche variabili che si vedono
# a colpo d'occhio su tutta una figura insieme: guardi la mappa e sai subito
# quante stanze segrete hai trovato, senza cercarle una per una. Soprattutto
# non dipende da QUALE tinta sia, quindi regge dove la tinta non regge - in
# bianco e nero, e per chi non distingue il rosso dal verde.
#
# Su Carnivalz e' nato per le stanze segrete della mappa, che erano verdi
# contro il rosso di quelle normali a 1,07:1 di luminosita': due tinte
# diversissime e lo stesso identico grigio.
#
# STA FUORI DALLA MAPPA perche' lo usa anche la legenda di fianco, e una
# legenda che disegna il suo quadratino in modo diverso dalla mappa non e' una
# legenda: e' un secondo disegno che dice un'altra cosa.

const QUOTA_PASSO := 0.26   # quanto distano le righe, rispetto al lato corto
const PASSO_MINIMO := 6.0   # a 30 pixel tre righe sono tessitura, otto una macchia
const QUOTA_SPESSORE := 0.22


static func dentro(dove: CanvasItem, r: Rect2, tinta: Color) -> void:
	var corto := minf(r.size.x, r.size.y)
	var passo := maxf(corto * QUOTA_PASSO, PASSO_MINIMO)
	var spessore := maxf(passo * QUOTA_SPESSORE, 1.5)
	var k := r.position.x + r.position.y + passo * 0.5
	var fine := r.end.x + r.end.y
	while k < fine:
		var estremi := taglio_obliquo(r, k)
		if estremi.size() == 2:
			dove.draw_line(estremi[0], estremi[1], tinta, spessore)
		k += passo


static func taglio_obliquo(r: Rect2, k: float) -> PackedVector2Array:
	# la retta x + y = k tagliata sui quattro lati: i punti buoni sono al
	# massimo due, e stanno agli estremi in x perche' la retta scende sempre
	var dentro_al_bordo: Array[Vector2] = []
	var allargato := r.grow(0.01)
	for p in [Vector2(r.position.x, k - r.position.x), Vector2(r.end.x, k - r.end.x),
			Vector2(k - r.position.y, r.position.y), Vector2(k - r.end.y, r.end.y)]:
		if allargato.has_point(p):
			dentro_al_bordo.append(p)
	if dentro_al_bordo.size() < 2:
		return PackedVector2Array()
	dentro_al_bordo.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var primo: Vector2 = dentro_al_bordo[0]
	var ultimo: Vector2 = dentro_al_bordo[dentro_al_bordo.size() - 1]
	if primo.distance_to(ultimo) < 1.0:
		return PackedVector2Array()   # ha toccato solo un angolo
	return PackedVector2Array([primo, ultimo])
