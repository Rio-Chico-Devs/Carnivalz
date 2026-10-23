extends Control
# LA FASCIA DELLA CREATURA (ProposteScontro.gd): il nome, la vita, quello che
# ne sai.
#
# Il nome sta su una fascia rossa di traverso che entra nel cartellone, come il
# titolo di un manifesto: e' rossa perche' in questa schermata il rosso vuol
# dire una cosa sola, il pericolo, e il pericolo e' lei. Sotto, la sua vita:
# prima era «HP: ???» scritto, adesso e' una barra vera - sai che una vita ce
# l'ha e quanto e' lunga - col pieno coperto da un tratteggio finche' non la
# studi. Studiandola il tratteggio se ne va. Sotto ancora, quello che hai
# scoperto, sulle strisce nere del manifesto.

const Spina := preload("res://prove/scontro/Spina.gd")

var nome := "MARIONETTA"
var quanti := 0            # un'orda: quanti sono. Si vede sempre, senza studiare
var quota_hp := 1.0
var nota := false          # se l'hai studiata: la vita si legge
var hp_scritto := ""
var studio: Array[String] = ["NON L'HAI ANCORA GUARDATA"]
var giu := 0.0             # 1: la fascia e' scesa fuori dallo schermo (parla qualcuno)
var turno := 0.0           # 1: tocca a lei
var svela := 0.0           # lo studio che toglie il tratteggio, 0..1


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	if giu >= 0.999:
		return
	var giu_px := Vector2(0, 260.0 * giu * giu)
	# LA FASCIA: un quadrilatero, non un rettangolo girato. Il lato di sopra sale
	# verso la spina, quello di sotto un poco meno: la fascia si allarga dove
	# comincia il nome, come una bandiera tesa
	var fascia := Spina.sposta(PackedVector2Array([Vector2(8, 514), Vector2(612, 488),
			Vector2(624, 562), Vector2(18, 590)]), giu_px)
	Spina.carta(self, fascia, Stile.colore("pericolo"), 4.0)
	var angolo := (fascia[1] - fascia[0]).angle()
	var corpo := 54
	var font := Caratteri.titolo()
	draw_set_transform(fascia[0] + Vector2(30, 60), angolo)
	var largo := Spina.scritta(self, font, Vector2(4, 4), nome, corpo, Stile.colore("bordo"))
	Spina.scritta(self, font, Vector2.ZERO, nome, corpo, Stile.colore("testo"))
	if quanti > 0:
		# L'ORDA: quanti sono si vede subito (docs/schermata_combattimento.md §12)
		Spina.etichetta(self, Vector2(largo + 22, -46), "×%d" % quanti, 34, Stile.colore("bordo"), Stile.colore("testo"))
	draw_set_transform(Vector2.ZERO)
	if turno > 0.0:
		var tag := Vector2(380, 470) + giu_px + Vector2(0, -12.0 * (1.0 - turno))
		draw_set_transform(tag, angolo)
		Spina.etichetta(self, Vector2.ZERO, "TOCCA A %s" % nome, 20, Color(Stile.colore("bordo"), turno),
				Color(Stile.colore("pericolo"), turno))
		draw_set_transform(Vector2.ZERO)
	# LA VITA
	var barra := Rect2(Vector2(44, 610) + giu_px, Vector2(520, 20))
	Spina.barra(self, barra, quota_hp, Stile.colore("pericolo"), not nota)
	if nota and svela < 1.0:
		# il tratteggio che se ne va, da sinistra a destra
		var resta := Rect2(barra.position + Vector2(barra.size.x * svela, 0), Vector2(barra.size.x * (1.0 - svela), barra.size.y))
		draw_rect(resta, Stile.colore("barra_vuota"))
		Spina.tratteggio(self, resta, Stile.colore("tratto"))
	var scritto := hp_scritto if nota and svela >= 1.0 else "???"
	Spina.etichetta(self, Vector2(barra.end.x + 14, barra.position.y - 4), scritto, 18,
			Stile.colore("bordo"), Stile.colore("testo"))
	var y := barra.end.y + 14.0
	for riga in studio:
		Spina.etichetta(self, Vector2(44, y), riga, 15)
		y += 26.0
