class_name Inchiostro
extends RichTextEffect

# L'INCHIOSTRO CHE AFFIORA: come compaiono le lettere del racconto.
#
# Bru, 28 settembre: «nelle narrazioni o introduzioni a livello, puoi fare in
# modo che il testo appaia in modo piu' morbido? non so tipo con un po' di
# fade mentre viene scritto». La macchina da scrivere decide QUANDO arriva una
# lettera (MacchinaDaScrivere, la stessa del box); qui si decide COME: invece
# di accendersi di colpo, ogni lettera sfuma dentro in un attimo, sale di
# qualche pixel come se si posasse sulla carta, e nasce del colore caldo della
# luce per poi asciugarsi nel crema del testo. Dietro la penna resta una scia
# di tre o quattro lettere ancora fresche: e' quella a dare l'idea della mano.
#
# Il tempo e' per lettera, non per posizione: quando la macchina respira sulla
# punteggiatura le ultime lettere finiscono di asciugarsi lo stesso, e un clic
# che completa il paragrafo le fa affiorare tutte insieme, non comparire.
#
# Chi lo usa (Racconto) gli dice che ore sono e quante lettere si vedono; i
# numeri stanno in data/stile.json, sezione "racconto": inchiostro, risalita.

var bbcode := "inchiostro"
var durata := 0.5                     # quanto ci mette una lettera ad asciugarsi
var risalita := 4.0                   # da quanti pixel piu' in basso arriva
var fresco := Color(0.91, 0.72, 0.45) # il colore dell'inchiostro appena posato
var adesso := 0.0
var comparsa: PackedFloat64Array = [] # quando e' comparsa ogni lettera


func ricomincia() -> void:
	comparsa.clear()


func segna(visibili: int) -> void:
	# le lettere appena scoperte dalla macchina da scrivere nascono adesso
	while comparsa.size() < visibili:
		comparsa.append(adesso)


func quanto_asciutta(indice: int) -> float:
	# 0 appena posata, 1 asciutta. Una lettera che la macchina ha appena
	# scoperto ma che non e' ancora segnata (succede nel fotogramma in cui
	# compare: la macchina scrive dopo che Racconto ha contato) e' fresca, non
	# asciutta - se no ogni lettera lampeggiava piena per un istante prima di
	# sfumare. Quelle ancora da scrivere le nasconde la macchina
	if indice < 0 or durata <= 0.0:
		return 1.0
	if indice >= comparsa.size():
		return 0.0
	return clampf((adesso - comparsa[indice]) / durata, 0.0, 1.0)


func _process_custom_fx(fx: CharFXTransform) -> bool:
	var t := quanto_asciutta(fx.range.x)
	if t >= 1.0:
		return true
	var morbido := t * t * (3.0 - 2.0 * t)   # smoothstep: parte e arriva piano
	var colore := fresco.lerp(fx.color, morbido)
	colore.a = fx.color.a * morbido
	fx.color = colore
	fx.offset.y += (1.0 - morbido) * risalita
	return true
