class_name SegniPianta
extends RefCounted

# QUELLO CHE SI DISEGNA SU UNA PIANTA, cioe' su una mappa di zona fatta col
# "disegno" invece che a quadratini: il foglio provvisorio finche' il disegno
# di Bru non c'e', con i corridoi fra le stanze, e i nomi delle stanze dentro i
# riquadri quando la mappa e' la Sede.
#
# I CORRIDOI SI VEDONO SOLO FINCHE' IL DISEGNO MANCA. Su una pianta disegnata i
# corridoi ci sono gia' (vedi MappaZona._disegna_sotto); su un foglio vuoto dei
# riquadri sparsi non dicono dove si passa, e alla Sede erano dodici scatole
# senza una strada fra l'una e l'altra. Una linea per ogni corridoio aperto,
# da porta a porta: dal centro attraverserebbe le stanze.
#
# I NOMI STANNO IN BASSO NEL RIQUADRO, perche' al centro ci sono gia' la
# freccia del «sei qui» e le icone (SegniMappa), e di sopra la freccia sale.


static func foglio(zona: MappaZona, tela: Control) -> void:
	var tratto := Stile.colore("tratto")
	tela.draw_rect(zona.riquadro_disegno, Color(tratto, 0.10))
	tela.draw_rect(zona.riquadro_disegno, Color(tratto, 0.45), false, 2.0)
	for coppia in GameState.collegamenti_aperti():
		if coppia.size() < 2:
			continue
		var a := String(coppia[0])
		var b := String(coppia[1])
		if not (zona.stanze_per_id.has(a) and zona.stanze_per_id.has(b)):
			continue
		if not (zona.si_vede(a) and zona.si_vede(b)):
			continue   # un corridoio verso un posto che non sai che c'e' non si vede
		var da := zona.rettangolo_di(zona.stanze_per_id[a])
		var verso := zona.rettangolo_di(zona.stanze_per_id[b])
		var pieno := zona.visitata(a) and zona.visitata(b)
		tela.draw_line(porta(da, verso.get_center()), porta(verso, da.get_center()),
				zona.tinta_corridoio(pieno), zona.larghezza_corridoio(pieno))


static func porta(stanza: Rect2, verso: Vector2) -> Vector2:
	# dove la retta dal centro della stanza verso un punto esce dal suo bordo
	var centro := stanza.get_center()
	var d := verso - centro
	var mezzo := stanza.size * 0.5
	var t := 1.0
	if absf(d.x) > 0.0:
		t = minf(t, mezzo.x / absf(d.x))
	if absf(d.y) > 0.0:
		t = minf(t, mezzo.y / absf(d.y))
	return centro + d * t


static func nome(bottone: Button, testo: String, corpo: int) -> Label:
	var scritta := Label.new()
	scritta.name = "Nome"
	scritta.text = testo
	scritta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scritta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scritta.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	scritta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scritta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scritta.offset_left = 6
	scritta.offset_right = -6
	scritta.offset_bottom = -4
	Stile.imposta_corpo(scritta, corpo)
	scritta.add_theme_color_override("font_color", Stile.colore("testo"))
	Stile.contorno(scritta, corpo)
	bottone.add_child(scritta)
	return scritta
