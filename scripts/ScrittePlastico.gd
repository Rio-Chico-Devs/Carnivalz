class_name ScrittePlastico
extends Control

# QUELLO CHE STA SOPRA IL PLASTICO, in due dimensioni: sopra le stanze e sopra
# le loro porte, perche' si deve leggere e cliccare anche dove una stanza ci
# passa sotto (PlasticoZona.monta_sopra lo mette in cima alla cornice).
#   - i PIANI, a sinistra: un bottone per piano, fermi in colonna come in un
#     ascensore, con un filo che arriva al suo pavimento. Cliccandolo resta solo quel piano (gli altri si
#     spengono e non si cliccano), cliccandolo di nuovo tornano tutti. Il pallino
#     arancio dice su che piano sei
#   - chi c'e': un pallino per personaggio sopra la sua stanza
#   - la SCHEDA della stanza puntata, accanto alla stanza e non in fondo allo
#     schermo: come si chiama, cosa ci si fa, chi c'e' e cosa succede cliccando.
#     Prima lo diceva solo la riga in basso, lontana dal cursore: si cliccava e
#     poi si andava a leggere perche' non era successo niente
#   - la riga dei comandi, in basso a sinistra, come sulla mappa stellare
#   - e fa posto ai nomi delle stanze, che stanno sulle porte (dirada)
# Testi miei.

const CORPO_PIANI := 11
const LARGA_SCHEDA := 210.0
const COMANDI := "TRASCINA · GIRA     TASTO DESTRO · SPOSTA     ROTELLA · AVVICINA     Z  X · PIANI     DOPPIO CLIC · RICENTRA"

var p: PlasticoZona
var bottoni := {}          # piano -> il suo bottone


func _init(plastico: PlasticoZona) -> void:
	p = plastico
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(colloca_piani)


# --- i piani --------------------------------------------------------------------

func prepara_piani() -> void:
	# un bottone per ogni piano che si vede e ha un nome
	for vecchio: Button in bottoni.values():
		remove_child(vecchio)
		vecchio.queue_free()
	bottoni.clear()
	for piano: int in p.piani_visti():
		var nome := nome_del_piano(piano)
		if nome == "":
			continue
		var b := Button.new()
		b.name = "Piano%d" % piano
		b.text = nome.to_upper()
		b.tooltip_text = "Solo questo piano. Di nuovo: tutti i piani"
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.add_theme_font_override("font", DisegnoProiezione.fonte(600, 85, 2))
		b.add_theme_font_size_override("font_size", CORPO_PIANI)
		b.pressed.connect(p.isola.bind(piano))
		add_child(b)
		bottoni[piano] = b
	vesti_piani()
	colloca_piani()


func nome_del_piano(piano: int) -> String:
	# il nome di un piano si sa quando se ne conosce una stanza: un piano di
	# soli «?» si chiama «?», come le sue stanze. «Profondita'» sul bottone,
	# prima di esserci scesi, era gia' uno spoiler
	var nome := String((GameState.mappa_zona.get("piani", {}) as Dictionary).get(str(piano), ""))
	if nome == "":
		return ""
	for id_stanza: String in p.scatole:
		if int(p.scatole[id_stanza]["piano"]) == piano and p.zona.nome_di(id_stanza) not in ["", "?"]:
			return nome
	return "?"


func vesti_piani() -> void:
	# il piano scelto e' pieno di luce, gli altri sono un filo; quello in cui
	# sei ha il pallino arancio (lo disegna _draw)
	var linea: Color = p.tinte["linea"]
	for piano: int in bottoni:
		var b: Button = bottoni[piano]
		var scelto := p.solo == piano
		for stato in ["normal", "hover", "pressed", "focus"]:
			var s := StyleBoxFlat.new()
			s.bg_color = Color(linea, 0.9) if scelto else Color(0.01, 0.03, 0.05, 0.75)
			if stato == "hover" and not scelto:
				s.bg_color = Color(linea, 0.22)
			s.border_color = Color(linea, 1.0 if stato == "focus" or scelto else 0.55)
			s.set_border_width_all(2 if stato == "focus" else 1)
			s.content_margin_left = 8
			s.content_margin_right = 8
			s.content_margin_top = 3
			s.content_margin_bottom = 3
			b.add_theme_stylebox_override(stato, s)
		var scritta := Color(0.02, 0.05, 0.07) if scelto else linea
		for chiave in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(chiave, scritta)


func attacco(piano: int) -> Vector2:
	# dove il filo tocca il piano: l'angolo del pavimento piu' a sinistra a schermo
	var r := p.impronta_del_piano(piano)
	var quota := float(piano) * p.altezza
	var dove := Vector2(INF, 0.0)
	for angolo in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
		var punto := p.sullo_schermo(Vector3(angolo.x, quota, angolo.y))
		dove = punto if punto.x < dove.x else dove
	return dove


func colloca_piani() -> void:
	# UNA PULSANTIERA FERMA, come quella di un ascensore: il piano piu' alto in
	# cima, al centro dell'altezza della cornice. Prima ogni bottone seguiva il
	# suo pavimento, e cliccandolo la vista andava su quel piano e il bottone
	# scappava da sotto il cursore: il secondo clic, quello che fa tornare
	# tutti i piani, finiva nel vuoto. Il filo lo lega comunque al suo pavimento
	var ordine: Array = bottoni.keys()
	ordine.sort()
	ordine.reverse()
	var alto := 0.0
	for piano: int in ordine:
		var b: Button = bottoni[piano]
		b.size = b.get_combined_minimum_size()
		alto += b.size.y + 10.0
	var y := maxf((size.y - alto) * 0.5, 6.0)
	for piano: int in ordine:
		var b: Button = bottoni[piano]
		b.position = Vector2(18.0, y)
		y += b.size.y + 10.0


func larghezza_piani() -> float:
	var largo := 0.0
	for b: Button in bottoni.values():
		largo = maxf(largo, b.get_combined_minimum_size().x)
	return largo


# --- i nomi delle stanze ----------------------------------------------------------

func dirada(porte: Control) -> void:
	# I NOMI NON SI COPRONO. Prima «Mensa» finiva sotto la freccia del «sei
	# qui» e mezza dentro «Il tuo alloggio». Adesso, dalla stanza che conta di
	# piu' (quella puntata e quella in cui sei, poi dalla piu' vicina alla piu'
	# lontana) ogni nome va sotto la sua stanza; se li' c'e' gia' un nome o
	# un'icona prova appena sotto o appena sopra, e se non c'e' posto si
	# nasconde: avvicinandosi le stanze si allargano e i nomi tornano
	var presi := icone_a_schermo()
	for porta: Control in in_ordine_di_importanza(porte):
		var nome := porta.get_node_or_null("Nome") as Label
		if nome != null:
			nome.visible = posa_il_nome(porta, nome, presi)


func in_ordine_di_importanza(porte: Control) -> Array[Control]:
	var primi: Array[Control] = []
	var resto: Array[Control] = []
	var elenco := porte.get_children()
	elenco.reverse()   # PlasticoZona.ordina mette la piu' vicina in fondo
	for porta: Control in elenco:
		var id_stanza := String(porta.get_meta("stanza", ""))
		if not porta.visible:
			continue
		if id_stanza == p.puntata or id_stanza == GameState.nodo_corrente:
			primi.append(porta)
		else:
			resto.append(porta)
	primi.append_array(resto)
	return primi


func posa_il_nome(porta: Control, nome: Label, presi: Array[Rect2]) -> bool:
	var misura := nome.get_minimum_size()
	var sotto := porta.position + Vector2(porta.size.x * 0.5, porta.size.y - 4.0)
	var id_stanza := String(porta.get_meta("stanza", ""))
	var conta := id_stanza == p.puntata or id_stanza == GameState.nodo_corrente
	for scarto: float in [0.0, misura.y + 2.0, -(misura.y + 2.0), 2.0 * (misura.y + 2.0)]:
		var r := Rect2(sotto + Vector2(-misura.x * 0.5, scarto - misura.y), misura)
		if not presi.any(func(altro: Rect2) -> bool: return altro.intersects(r)):
			nome.offset_bottom = -4.0 + scarto
			presi.append(r)
			return true
	if not conta:
		return false
	# la stanza puntata e la tua il nome lo dicono comunque: prima pero' hanno
	# provato i posti liberi, invece di finire sotto la freccia del «sei qui»
	nome.offset_bottom = -4.0
	presi.append(Rect2(sotto + Vector2(-misura.x * 0.5, -misura.y), misura))
	return true


func icone_a_schermo() -> Array[Rect2]:
	# dove stanno le icone che MappaZona disegna sopra le stanze: li' i nomi no
	var presi: Array[Rect2] = []
	for id_stanza: String in p.scatole:
		if p.velata(id_stanza) or not p.zona.si_vede(id_stanza):
			continue
		var icona := p.zona.icona_di(p.zona.stanze_per_id.get(id_stanza, {}))
		if id_stanza == GameState.nodo_corrente or id_stanza == GameState.proiettore_qui() \
				or icona == "obiettivo" or (icona != "" and p.zona.visitata(id_stanza)):
			presi.append(p.segni_di(id_stanza).grow(-8.0))
		if id_stanza == GameState.nodo_corrente:
			presi.append(p.freccia_di(id_stanza).grow(-8.0))
	return presi


# --- il disegno -----------------------------------------------------------------

func _draw() -> void:
	var linea: Color = p.tinte["linea"]
	var qui := int(p.scatole.get(GameState.nodo_corrente, {}).get("piano", 9999))
	for piano: int in bottoni:
		var b: Button = bottoni[piano]
		var da := b.position + Vector2(b.size.x, b.size.y * 0.5)
		# il filo arriva solo a un piano acceso: a uno spento puntava nel vuoto
		if p.solo == PlasticoZona.NESSUNO or p.solo == piano:
			draw_line(da, attacco(piano), Color(linea, 0.6 if p.solo == piano else 0.25), 1.0)
		if piano == qui:
			draw_circle(Vector2(9.0, da.y), 4.0, p.tinte["qui"])
	for id_stanza in p.scatole:
		if p.velata(id_stanza) or not p.zona.si_vede(id_stanza):
			continue
		var chi := p.zona.chi_c_e(id_stanza)
		for i in chi.size():
			var dove := p.cima(id_stanza) + Vector2(-8.0 * float(chi.size() - 1) + 16.0 * float(i), -26)
			draw_circle(dove, 6.5, Color(0, 0, 0, 0.85))
			draw_circle(dove, 4.5, p.tinte["qui"])
	DisegnoProiezione.scrivi(self, Vector2(18.0, size.y - 12.0), COMANDI, 9, Color(linea, 0.6), 450, 85, 2)
	scheda(p.puntata)


func righe_della_scheda(id_stanza: String) -> Array:
	# [testo, corpo, tinta, peso]: il nome, cosa ci si fa, chi c'e', e il clic
	var z := p.zona
	var stanza: Dictionary = z.stanze_per_id.get(id_stanza, {})
	var carta := Color(0.86, 0.97, 1.0)
	var righe: Array = [[z.nome_di(id_stanza), 15, carta, 600.0]]
	var cosa := String(stanza.get("cosa", ""))
	if cosa != "" and not z.chiusa(id_stanza):
		righe.append([cosa, 12, Color(carta, 0.8), 400.0])
	var chi := z.chi_c_e(id_stanza)
	if not chi.is_empty():
		righe.append([", ".join(chi), 12, p.tinte["qui"], 500.0])
	righe.append(cosa_fa_il_clic(id_stanza))
	return righe


func cosa_fa_il_clic(id_stanza: String) -> Array:
	var linea: Color = p.tinte["linea"]
	if id_stanza == GameState.nodo_corrente:
		return ["SEI QUI", 10, p.tinte["qui"], 600.0]
	if p.zona.chiusa(id_stanza):
		return ["CHIUSA", 10, p.tinte["chiusa"], 600.0]
	if not p.zona.si_puo_andare(id_stanza):
		return ["TROPPO LONTANO", 10, Color(linea, 0.6), 600.0]
	return ["CLIC · ENTRA", 10, linea, 600.0]


func scheda(id_stanza: String) -> void:
	if id_stanza == "" or not p.scatole.has(id_stanza) or p.velata(id_stanza) or p.alle_spalle(id_stanza):
		return
	var righe := righe_della_scheda(id_stanza)
	var largo := 0.0
	var alto := 26.0
	for riga: Array in righe:
		largo = maxf(largo, DisegnoProiezione.larghezza(String(riga[0]), int(riga[1]), float(riga[3]), 85, 1))
		alto += float(riga[1]) + 7.0
	var misura := Vector2(clampf(largo + 24.0, 140.0, LARGA_SCHEDA + 80.0), alto)
	var dove := posto_della_scheda(occupato_da(id_stanza), misura)
	var linea: Color = p.tinte["linea"]
	draw_rect(Rect2(dove, misura), Color(0.01, 0.03, 0.05, 0.9))
	draw_rect(Rect2(dove, misura), Color(linea, 0.9), false, 1.0)
	# la linguetta col piano, come le scatole della mappa stellare
	var piano := nome_del_piano(int(p.scatole[id_stanza]["piano"])).to_upper()
	if piano != "":
		var w := DisegnoProiezione.larghezza(piano, 9, 600, 85, 2) + 10.0
		draw_rect(Rect2(dove, Vector2(w, 14)), linea)
		DisegnoProiezione.scrivi(self, dove + Vector2(5, 11), piano, 9, Color(0.02, 0.05, 0.07), 600, 85, 2)
	var y := dove.y + 22.0
	for riga: Array in righe:
		y += float(riga[1]) + 3.0
		DisegnoProiezione.scrivi(self, Vector2(dove.x + 12.0, y), String(riga[0]), int(riga[1]), riga[2], float(riga[3]), 85, 1)
		y += 4.0


func occupato_da(id_stanza: String) -> Rect2:
	# la stanza e il suo nome, che e' spesso piu' largo di lei: la scheda sta
	# lontana da tutti e due. Lo ripete, ma coprirlo a meta' («Punto
	# d'atterragg») era disordine
	var occupato := p.rettangolo(id_stanza)
	var porta := p.porta_di(id_stanza)
	var nome := porta.get_node_or_null("Nome") as Label if porta != null else null
	if nome != null and nome.is_visible_in_tree():
		occupato = occupato.merge(Rect2(nome.get_global_rect().position - get_global_rect().position, nome.size))
	return occupato


func posto_della_scheda(stanza: Rect2, misura: Vector2) -> Vector2:
	# a destra della stanza; se non ci sta, a sinistra; e sempre dentro la cornice
	var x := stanza.end.x + 14.0
	if x + misura.x > size.x - 8.0:
		x = stanza.position.x - 14.0 - misura.x
	x = clampf(x, 8.0, maxf(size.x - misura.x - 8.0, 8.0))
	var y := clampf(stanza.position.y, 8.0, maxf(size.y - misura.y - 30.0, 8.0))
	return Vector2(x, y)
