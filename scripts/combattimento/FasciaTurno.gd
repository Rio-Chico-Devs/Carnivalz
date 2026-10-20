class_name FasciaTurno
extends RefCounted
# IL TURNO CHE PASSA, col corpo. Bru, sugli esempi animati (docs/vita.md):
# «bello tutto».
#
# Di chi e' il turno lo diceva gia' la cornice che si accende (Slot.gd,
# imposta_turno). In piu': lo slot di chi tocca si alza e si inclina appena,
# con un rimbalzo corto, e gli altri tornano giu'; sotto il suo schermo entra
# una fascia col nome - «TOCCA A VERONICA», «TOCCA A TE», nera con la scritta
# arancio come le etichette del manifesto. Quando tocca al nemico il suo
# schermo si accende di rosso due volte e la fascia e' rossa.
#
# La fascia resta finche' il turno e' suo: e' la stessa informazione della
# cornice, detta a parole. Col movimento ridotto niente inclinazione e niente
# rimbalzo, e la fascia compare sul posto.

const ALZA := 1.035          # quanto si ingrandisce lo slot di chi tocca
const INCLINA := -1.2        # gradi
const SALE := 0.22           # quanto ci mette a salire
const SCENDE := 0.16
const META := "fascia_turno" # dove un nodo tiene la sua fascia
const META_LAMPO := "lampo_turno"
const META_ALZA := "alza_turno"   # il tween che sta alzando o abbassando lo slot


static func alza(slot: Control, si: bool) -> void:
	if not is_instance_valid(slot) or not slot.is_inside_tree() or Movimento.ridotto():
		return
	slot.pivot_offset = Vector2(slot.size.x * 0.5, slot.size.y * 0.6)
	# DUE TURNI DI FILA IN FRETTA: il tween di prima si ferma, se no quello che
	# sale e quello che scende si contendono lo slot e puo' restare alzato
	if slot.has_meta(META_ALZA):
		var prima: Variant = slot.get_meta(META_ALZA)
		if prima is Tween and (prima as Tween).is_valid():
			(prima as Tween).kill()
	var verso := slot.create_tween().set_parallel(true)
	slot.set_meta(META_ALZA, verso)
	var quanto := SALE if si else SCENDE
	verso.tween_property(slot, "scale", Vector2.ONE * (ALZA if si else 1.0), quanto) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	verso.tween_property(slot, "rotation_degrees", INCLINA if si else 0.0, quanto) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func testo_per(id_personaggio: String) -> String:
	# il protagonista e' il primo della squadra, e a lui si dice "tu"
	if not GameState.party.is_empty() and id_personaggio == String(GameState.party[0]):
		return "TOCCA A TE"
	var dati: Dictionary = GameState.personaggi.get(id_personaggio, {})
	return "TOCCA A %s" % String(dati.get("nome_breve", dati.get("nome", id_personaggio))).to_upper()


static func metti(sopra: Control, testo: String, tinta: String, dove: Vector2, largo_massimo := 0.0) -> Label:
	# la fascia entra da sinistra e si ferma in "dove" (coordinate di "sopra").
	# Un nome lungo stringe la scritta invece di uscire dallo schermo
	togli(sopra)
	if not is_instance_valid(sopra):
		return null
	var fascia := Label.new()
	fascia.text = testo
	fascia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var corpo := Stile.dimensione("corpo")
	Manifesto.vesti_etichetta(fascia, corpo, "manifesto" if tinta == "bordo" else "testo", tinta)
	sopra.add_child(fascia)
	fascia.reset_size()
	if largo_massimo > 0.0 and fascia.size.x > largo_massimo:
		fascia.add_theme_font_size_override("font_size", maxi(int(corpo * largo_massimo / fascia.size.x), 8))
		fascia.size = Vector2.ZERO
		fascia.reset_size()
	sopra.set_meta(META, fascia)
	var fermo := dove - Vector2(0.0, fascia.size.y)
	if Movimento.ridotto() or not sopra.is_inside_tree():
		fascia.position = fermo
		return fascia
	fascia.position = fermo - Vector2(sopra.size.x * 0.5, 0.0)
	fascia.modulate.a = 0.0
	var entra := fascia.create_tween().set_parallel(true)
	entra.tween_property(fascia, "position", fermo, Movimento.durata("entrata")) \
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	entra.tween_property(fascia, "modulate:a", 1.0, 0.08)
	return fascia


static func di(sopra: Control) -> Label:
	if not is_instance_valid(sopra) or not sopra.has_meta(META):
		return null
	var fascia: Variant = sopra.get_meta(META)
	return fascia as Label if is_instance_valid(fascia) else null


static func togli(sopra: Control) -> void:
	# la fascia di prima esce dall'altra parte e sparisce
	var vecchia := di(sopra)
	if vecchia == null:
		return
	sopra.remove_meta(META)
	if Movimento.ridotto() or not vecchia.is_inside_tree():
		vecchia.queue_free()
		return
	var via := vecchia.create_tween().set_parallel(true)
	via.tween_property(vecchia, "position:x", vecchia.position.x + 90.0, Movimento.durata("uscita")) \
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	via.tween_property(vecchia, "modulate:a", 0.0, Movimento.durata("uscita"))
	via.chain().tween_callback(vecchia.queue_free)


static func accendi_nemico(schermo: Control) -> void:
	# lo schermo del nemico si accende di rosso due volte, e sobbalza appena
	if not is_instance_valid(schermo) or not schermo.is_inside_tree():
		return
	var lampo: ColorRect = schermo.get_meta(META_LAMPO) if schermo.has_meta(META_LAMPO) else null
	if lampo == null or not is_instance_valid(lampo):
		lampo = ColorRect.new()
		lampo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lampo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		schermo.add_child(lampo)
		schermo.set_meta(META_LAMPO, lampo)
	lampo.color = Color(Stile.colore("pericolo"), 0.0)
	var accende := lampo.create_tween()
	for volta in 2:
		accende.tween_property(lampo, "color:a", 0.32, 0.07)
		accende.tween_property(lampo, "color:a", 0.0, 0.22)
	if Movimento.ridotto():
		return
	schermo.pivot_offset = schermo.size * 0.5
	var sobbalza := schermo.create_tween()
	sobbalza.tween_property(schermo, "scale", Vector2.ONE * 1.025, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	sobbalza.tween_property(schermo, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
