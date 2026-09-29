class_name Caratteri
extends RefCounted

# I CARATTERI DEL GIOCO, pronti all'uso e fatti una volta sola: i due del menu
# principale, la calligrafia del racconto (fiaba), quello del box dei
# dialoghi (dialoghi) e quello dei nomi di chi parla (nomi).
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


static func fiaba(peso := 400) -> Font:
	# LA CALLIGRAFIA DEL RACCONTO (Italianno). Il peso passa come per Nunito, ma
	# conta solo se il carattere e' a peso variabile: Italianno non lo e', e se
	# un giorno al suo posto ne torna uno che lo e' il peso e' gia' qui
	var chiave := "fiaba_%d" % peso
	if gia_fatti.has(chiave):
		return gia_fatti[chiave]
	var base := Stile.font_da("fiaba")
	if base == null:
		return null
	var variante := FontVariation.new()
	variante.base_font = base
	variante.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): peso}
	gia_fatti[chiave] = variante
	return variante


static func dialoghi(stile := "dritto") -> Font:
	# IL CARATTERE DEL BOX DEI DIALOGHI (Bricolage Grotesque), in quattro stili:
	# "dritto", "corsivo" (la narrazione), "grassetto" e "grassetto_corsivo"
	# (un grassetto dentro la narrazione). Bricolage non ha un
	# corsivo ne' un peso oltre 800, che e' gia' quello del dritto: il corsivo
	# e' il dritto inclinato, il grassetto e' il dritto col tratto ispessito.
	# Le misure stanno in data/stile.json, sezione "dialoghi"
	var chiave := "dialoghi_" + stile
	if gia_fatti.has(chiave):
		return gia_fatti[chiave]
	var misure: Dictionary = Stile.dati.get("dialoghi", {})
	var variante := con_le_sue_misure("dialoghi", misure)
	if variante == null:
		return null
	if "corsivo" in stile:
		variante.variation_transform = Transform2D(Vector2(1, 0), Vector2(-float(misure.get("inclinazione", 0.2)), 1), Vector2.ZERO)
	if "grassetto" in stile:
		variante.variation_embolden = float(misure.get("grassetto", 0.6))
	gia_fatti[chiave] = variante
	return variante


static func corpo_dialoghi() -> int:
	return int((Stile.dati.get("dialoghi", {}) as Dictionary).get("corpo", Stile.dimensione("corpo")))


static func nomi() -> Font:
	# I NOMI DI CHI PARLA (IM Fell English, maiuscoletto): il nastro rosa, la
	# riga del nome nel box, lo storico. Bru l'ha scelto dopo diversi giri di
	# prove - come i nomi di chi parla nei testi teatrali stampati. Misure in
	# data/stile.json, sezione "nomi"
	if not gia_fatti.has("nomi"):
		gia_fatti["nomi"] = con_le_sue_misure("nomi", Stile.dati.get("nomi", {}))
	return gia_fatti["nomi"]


static func corpo_nomi() -> int:
	return int((Stile.dati.get("nomi", {}) as Dictionary).get("corpo", Stile.dimensione("titolo")))


static func con_le_sue_misure(chiave: String, misure: Dictionary) -> FontVariation:
	# il file di font.file_<chiave>, con gli assi scritti per nome ("wght",
	# "opsz", "INFM"...) e lo spazio in piu' fra le lettere. Un asse che il
	# file non ha non fa niente: cambiando carattere non si rompe nulla
	var base := Stile.font_da(chiave)
	if base == null:
		return null
	var variante := FontVariation.new()
	variante.base_font = base
	var assi := {}
	var scritti: Dictionary = misure.get("assi", {})
	for asse: String in scritti:
		assi[TextServerManager.get_primary_interface().name_to_tag(asse)] = float(scritti[asse])
	variante.variation_opentype = assi
	variante.spacing_glyph = int(misure.get("spaziatura", 0))
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
