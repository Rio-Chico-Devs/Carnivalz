class_name Caratteri
extends RefCounted

# I DUE CARATTERI DEL MENU PRINCIPALE, pronti all'uso e fatti una volta sola.
#
# Anton per le voci e i titoli, Nunito per le scritte piccole: e' la coppia del
# riferimento di Bru (Borderlands 2), dove le voci sono maiuscole pesanti e
# strette e tutto il resto - la testata, la descrizione, i comandi - e'
# tondo. Due voci di carattere diverse per due mestieri diversi: quello che si
# sceglie e quello che si legge.
#
# Nunito e' a peso variabile: lo stesso file fa il normale e il grassetto, e il
# peso si chiede qui (wght, da 200 a 1000).

static var gia_fatti: Dictionary = {}


static func titolo() -> Font:
	if not gia_fatti.has("titolo"):
		gia_fatti["titolo"] = Stile.font_da("titolo")
	return gia_fatti["titolo"]


static func tondo(peso := 400) -> Font:
	var chiave := "tondo_%d" % peso
	if gia_fatti.has(chiave):
		return gia_fatti[chiave]
	var base := Stile.font_da("arrotondato")
	if base == null:
		return null
	var variante := FontVariation.new()
	variante.base_font = base
	variante.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): peso}
	gia_fatti[chiave] = variante
	return variante


static func voce() -> Font:
	# ANTON STRETTO IN ALTEZZA, per le voci del menu principale. Anton ha tanto
	# spazio sopra le maiuscole (per gli accenti) e sotto (per le discendenti),
	# e le voci sono tutte maiuscole: a 31 pixel la riga sarebbe alta 48, e nel
	# riferimento il passo fra una voce e l'altra e' il 5,6% dello schermo,
	# cioe' 40. Si toglie l'aria, non si rimpiccioliscono le lettere
	if gia_fatti.has("voce"):
		return gia_fatti["voce"]
	var base := titolo()
	if base == null:
		return null
	var stretto := FontVariation.new()
	stretto.base_font = base
	stretto.spacing_top = -7
	stretto.spacing_bottom = -7
	gia_fatti["voce"] = stretto
	return stretto
