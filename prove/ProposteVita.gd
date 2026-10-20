extends Control
# ESEMPI DI VITA. Provvisorio come ProposteCrescita e FilmSalita: non e' il
# gioco, e' una vetrina girata come film. Bru: «cominciamo a lavorare sui
# minigiochi e gli effetti del gioco ora [...] mi fai degli esempi di
# animazioni che diano più vita e movimento al gioco?»
#
# Ogni esempio sta sulla schermata VERA dello scontro (Combattimento.tscn),
# montata come nello scatto "plancia": le animazioni sono strati e tween messi
# sopra da qui, senza toccare il codice del gioco. Quello che piace si sposta
# nel gioco come dice docs/vita.md.
#
#   respiro     lo scontro a riposo: chi combatte respira, sul vetro dei
#               cabinati passa un riflesso, dal fondo salgono le braci
#   squarcio    l'entrata nello scontro: la scena di prima si strappa e i pezzi
#               dello scontro entrano uno dopo l'altro
#   turno       il turno che passa: lo slot di chi tocca si alza e una fascia lo
#               dice; quando tocca al nemico il suo schermo si accende di rosso
#   mattanza    il taglio a tutto schermo quando parte la Mattanza
#   collisioni  il minigioco col corpo: l'anticipo, la parata, il colpo preso
#
#   ./prove/film_vita.sh             li gira tutti in scatti/proposte_vita/
#   ./prove/film_vita.sh respiro     uno solo
#   nell'editor: ProposteVita.tscn, F6 (fa il respiro)

const DURATE := {"respiro": 7.0, "squarcio": 3.0, "turno": 5.6, "mattanza": 3.0, "collisioni": 8.4}
const ASSESTAMENTO := 90   # fotogrammi prima di cominciare: lo scontro si dispone

var scena: Node
var plancia: PlanciaCombattimento
var sopra: CanvasLayer
var nome := "respiro"
var tempo := -1.0              # secondi dall'inizio dell'esempio; -1 finche' non comincia
var respiranti: Array[Dictionary] = []
var riflessi: Array[Riflesso] = []
var braci: Braci = null
var lampi: Lampi = null
var schegge: Schegge = null
var pezzi: Array[Control] = []     # i pezzi della plancia, nell'ordine in cui entrano
var posti: Array[Vector2] = []     # dove stanno a riposo
var fatti: Dictionary = {}         # i momenti gia' scattati di questo film


func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	if argomenti.size() > 1 and String(argomenti[0]) == "film":
		nome = String(argomenti[1])
	monta_scontro()
	for i in ASSESTAMENTO:
		await get_tree().process_frame
	await prepara()
	tempo = 0.0
	# il film comincia qui: film_vita.sh taglia i fotogrammi di prima
	print("INIZIO_FILM ", Engine.get_frames_drawn())


func monta_scontro() -> void:
	GameState.nuova_partita()
	GameState.party = ["anonimo", "veronica"]
	GameState.nemici_combattimento = ["marionetta"]
	scena = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scena)
	sopra = CanvasLayer.new()
	sopra.layer = 20
	add_child(sopra)


func prepara() -> void:
	# lo scontro e' a tempo reale: fermo il suo orologio, se no a meta' film la
	# marionetta attacca da sola (l'ECG e le barre hanno il loro)
	scena.set_process(false)
	scena.voce.coda.clear()
	for c: Dictionary in scena.combattenti:
		c.hp = c.hp_max
		scena.campo.aggiorna(c)
	scena.arena.imposta_pericolo(0.0)
	scena.campo.evidenzia(scena.combattenti, scena.combattenti[0])
	scena.menu.principale()
	plancia = scena.plancia
	# i pezzi della plancia, nell'ordine in cui entrano: il nemico, la sua
	# scheda, i tre della squadra, il quadrante
	for dentro: Node in [plancia.box_nemico, plancia.scheda_nemico, plancia.slot[0], plancia.slot[1],
			plancia.slot[2], plancia.quadrante]:
		var pezzo := pezzo_di(dentro)
		pezzi.append(pezzo)
		posti.append(pezzo.position)
	schegge = Schegge.new()
	schegge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tela := Control.new()
	tela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sopra.add_child(tela)
	lampi = Lampi.new()
	lampi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tela.add_child(lampi)
	tela.add_child(schegge)
	match nome:
		"respiro":
			metti_braci()
			metti_riflessi()
			metti_respiri()
		"squarcio":
			await prepara_squarcio()
		"turno", "mattanza":
			metti_respiri()
		"collisioni":
			prepara_collisioni()


func _process(delta: float) -> void:
	if tempo < 0.0:
		return
	tempo += delta
	aggiorna_respiri()
	if braci != null:
		braci.avanza(delta)
	for r in riflessi:
		r.avanza(delta)
	lampi.avanza(delta)
	match nome:
		"squarcio":
			passa_squarcio()
		"turno":
			passa_turno()
		"mattanza":
			passa_mattanza()
		"collisioni":
			passa_collisioni(delta)
	if tempo > float(DURATE.get(nome, 5.0)) + 0.5:
		get_tree().quit()


func pezzo_di(n: Node) -> Control:
	# il figlio della plancia che contiene n: la cornice si muove col contenuto
	var su := n
	while su != null and su.get_parent() != plancia.radice:
		su = su.get_parent()
	return su as Control


func una_volta(chiave: String, da: float) -> bool:
	# vero una volta sola, al primo fotogramma dopo "da" secondi
	if tempo < da or fatti.has(chiave):
		return false
	fatti[chiave] = true
	return true


# --- IL RESPIRO ----------------------------------------------------------------
# Chi combatte non sta fermo come una figurina: si gonfia e si sgonfia piano,
# ognuno col suo passo. Il nemico di piu' e ondeggia appena: e' una creatura.
# Si muove il disegno dentro lo schermo, non la cornice.

func metti_respiri() -> void:
	respira(plancia.posto_nemico, 3.4, 0.0, 0.022, 0.5)
	var passi := [3.0, 3.3, 2.8]
	for i in plancia.slot.size():
		var s := plancia.slot[i]
		for disegno: Control in [s.iniziale, s.faccia]:
			respira(disegno, float(passi[i]), 1.7 * i + 0.6, 0.014, 0.0)


func respira(nodo: Control, periodo: float, fase: float, quanto: float, ondeggia: float) -> void:
	if nodo == null:
		return
	respiranti.append({"nodo": nodo, "periodo": periodo, "fase": fase, "quanto": quanto, "ondeggia": ondeggia})


func aggiorna_respiri() -> void:
	for r in respiranti:
		var nodo: Control = r["nodo"]
		if not is_instance_valid(nodo):
			continue
		nodo.pivot_offset = Vector2(nodo.size.x * 0.5, nodo.size.y)
		var onda := sin(TAU * tempo / float(r["periodo"]) + float(r["fase"]))
		var quanto: float = r["quanto"]
		nodo.scale = Vector2(1.0 - quanto * 0.4 * onda, 1.0 + quanto * onda)
		nodo.rotation_degrees = float(r["ondeggia"]) * sin(TAU * tempo / 5.1)


func metti_braci() -> void:
	# dietro i cabinati, sopra la trama del fondo
	braci = Braci.new()
	braci.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plancia.radice.add_child(braci)
	plancia.radice.move_child(braci, 1)
	braci.size = plancia.radice.size
	braci.riempi(64)


func metti_riflessi() -> void:
	var i := 0
	for cabinato in cabinati(plancia.radice):
		var vetro := cabinato.get_global_rect().grow(-cabinato.bordo - 2.0)
		var r := Riflesso.new()
		r.position = vetro.position
		r.size = vetro.size
		r.periodo = 4.2 + 0.35 * i
		r.ritardo = 0.4 + 0.9 * i
		sopra.add_child(r)
		riflessi.append(r)
		i += 1


func cabinati(da: Node) -> Array[Manifesto.Cabinato]:
	var trovati: Array[Manifesto.Cabinato] = []
	for figlio in da.get_children():
		if figlio is Manifesto.Cabinato:
			trovati.append(figlio as Manifesto.Cabinato)
		trovati.append_array(cabinati(figlio))
	return trovati


# --- LO SQUARCIO ---------------------------------------------------------------
# Lo scontro non comincia con un taglio secco: la scena di prima si crepa lungo
# una linea storta (lo squarcio dei Carnivalz), le due meta' volano via e sotto
# lo scontro entra a pezzi: prima il nemico, poi la squadra dall'alto, per
# ultimo il quadrante dei comandi, che e' dove devi guardare. Dalla crepa
# all'ultimo pezzo fermo passa poco piu' di mezzo secondo.

var meta_su: Polygon2D
var meta_giu: Polygon2D
var crepa_luce: Line2D
var crepa_anima: Line2D
var linea_crepa: PackedVector2Array

const CREPA := 0.6       # quando comincia a crepare
const APRE := 0.8        # quando le meta' partono


func prepara_squarcio() -> void:
	var prima: Texture2D = await foto_di_prima()
	var largo := plancia.radice.size.x
	var alto := plancia.radice.size.y
	# la crepa: da sinistra in basso a destra in alto, a denti
	var dado := RandomNumberGenerator.new()
	dado.seed = 5
	linea_crepa = PackedVector2Array()
	var passi := 18
	for k in passi + 1:
		var u := float(k) / float(passi)
		var y := lerpf(alto * 0.66, alto * 0.30, u) + (dado.randf_range(-22.0, 22.0) if k % passi != 0 else 0.0)
		linea_crepa.append(Vector2(lerpf(-20.0, largo + 20.0, u), y))
	var su := PackedVector2Array([Vector2(-20, -20), Vector2(largo + 20, -20)])
	var linea_al_contrario := linea_crepa.duplicate()
	linea_al_contrario.reverse()
	su.append_array(linea_al_contrario)
	var giu := PackedVector2Array(linea_crepa)
	giu.append_array(PackedVector2Array([Vector2(largo + 20, alto + 20), Vector2(-20, alto + 20)]))
	meta_su = meta(prima, su)
	meta_giu = meta(prima, giu)
	crepa_luce = filo(18.0, Color(1.0, 0.62, 0.15, 0.85))
	crepa_anima = filo(5.0, Color(1.0, 0.97, 0.9))
	# i pezzi dello scontro aspettano fuori
	for i in pezzi.size():
		pezzi[i].position = posti[i] + da_dove(i)


func meta(texture: Texture2D, contorno: PackedVector2Array) -> Polygon2D:
	var p := Polygon2D.new()
	p.texture = texture
	p.polygon = contorno
	p.uv = contorno
	sopra.add_child(p)
	return p


func filo(spesso: float, tinta: Color) -> Line2D:
	var l := Line2D.new()
	l.width = spesso
	l.default_color = tinta
	l.joint_mode = Line2D.LINE_JOINT_SHARP
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	sopra.add_child(l)
	return l


func foto_di_prima() -> Texture2D:
	# LA SCENA DI PRIMA: qui il luna park del racconto, fotografato in un
	# SubViewport. Nel gioco sarebbe la foto della schermata da cui arrivi
	var vista := SubViewport.new()
	vista.size = Vector2i(plancia.radice.size)
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var fondale := LunaPark.new()
	fondale.size = plancia.radice.size
	vista.add_child(fondale)
	add_child(vista)
	# il SubViewport si disegna nei prossimi giri del server
	for i in 4:
		await RenderingServer.frame_post_draw
	var immagine := vista.get_texture().get_image()
	vista.queue_free()
	return ImageTexture.create_from_image(immagine)


func da_dove(i: int) -> Vector2:
	# il nemico e la sua scheda da sinistra, la squadra dall'alto, il quadrante dal basso
	match i:
		0, 1:
			return Vector2(-620.0, 0.0)
		2, 3, 4:
			return Vector2(0.0, -460.0)
	return Vector2(0.0, 360.0)


func passa_squarcio() -> void:
	var largo := plancia.radice.size.x
	# la crepa si disegna da sinistra a destra in un decimo di secondo
	var u := clampf((tempo - CREPA) / 0.12, 0.0, 1.0)
	var fino := int(round(u * float(linea_crepa.size() - 1)))
	var tratto := PackedVector2Array()
	if tempo >= CREPA:
		for k in fino + 1:
			tratto.append(linea_crepa[k])
	crepa_luce.points = tratto
	crepa_anima.points = tratto
	crepa_luce.width = 18.0 + 10.0 * sin(clampf((tempo - CREPA) / 0.2, 0.0, 1.0) * PI)
	# le due meta' volano via, girando un poco
	var v := Movimento.curva("uscita", clampf((tempo - APRE) / 0.34, 0.0, 1.0))
	meta_su.position = Vector2(-80.0, -largo * 0.42) * v
	meta_su.rotation = -0.07 * v
	meta_giu.position = Vector2(80.0, largo * 0.42) * v
	meta_giu.rotation = 0.07 * v
	var spegne := 1.0 - clampf((tempo - APRE) / 0.18, 0.0, 1.0)
	crepa_luce.modulate.a = spegne
	crepa_anima.modulate.a = spegne
	# i pezzi entrano: il nemico per primo, il quadrante per ultimo
	var ritardi := Movimento.ritardi_cascata(pezzi.size(), pezzi.size() - 1)
	for i in pezzi.size():
		var w := clampf((tempo - APRE - 0.06 - ritardi[i]) / Movimento.durata("entrata"), 0.0, 1.0)
		pezzi[i].position = posti[i] + da_dove(i) * (1.0 - Movimento.curva("entrata", w))


# --- IL TURNO ------------------------------------------------------------------
# Di chi e' il turno oggi lo dice la cornice che si accende. Qui ci si aggiunge
# il corpo: lo slot di chi tocca si alza e si inclina appena, gli altri tornano
# giu', e sotto lo schermo passa una fascia col nome. Quando tocca al nemico il
# suo schermo si accende di rosso due volte.

var fascia: Label
var lampo_nemico: ColorRect


func passa_turno() -> void:
	if una_volta("veronica", 0.4):
		tocca(1, "TOCCA A VERONICA", "bordo")
	if una_volta("nemico", 2.2):
		tocca(-1, "TOCCA A MARIONETTA", "pericolo")
	if una_volta("tu", 3.9):
		tocca(0, "TOCCA A TE", "bordo")


func tocca(indice: int, scritta: String, tinta: String) -> void:
	var attivo: Dictionary = scena.combattenti[0]
	for c: Dictionary in scena.combattenti:
		var su_slot: bool = indice >= 0 and c.get("scheda") == plancia.slot[indice]
		var e_nemico: bool = indice < 0 and not bool(c.get("giocatore", false))
		if su_slot or e_nemico:
			attivo = c
	scena.campo.evidenzia(scena.combattenti, attivo)
	for i in plancia.slot.size():
		alza(plancia.slot[i], i == indice)
	var sotto: Control = plancia.slot[indice] if indice >= 0 else pezzi[0]
	passa_fascia(sotto, scritta, tinta)
	if indice < 0:
		accendi_nemico()


func alza(slot: Control, si: bool) -> void:
	slot.pivot_offset = Vector2(slot.size.x * 0.5, slot.size.y * 0.6)
	var t := create_tween().set_parallel(true)
	var quanto := 0.22 if si else 0.16
	t.tween_property(slot, "scale", Vector2.ONE * (1.035 if si else 1.0), quanto) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(slot, "rotation_degrees", -1.2 if si else 0.0, quanto) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(slot, "modulate", Color.WHITE if si else Color(0.86, 0.86, 0.86), quanto)


func passa_fascia(sotto: Control, scritta: String, tinta: String) -> void:
	if fascia != null:
		var vecchia := fascia
		var via := create_tween().set_parallel(true)
		via.tween_property(vecchia, "position:x", vecchia.position.x + 90.0, 0.15) \
				.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		via.tween_property(vecchia, "modulate:a", 0.0, 0.15)
		via.chain().tween_callback(vecchia.queue_free)
	fascia = Label.new()
	fascia.text = scritta
	Manifesto.vesti_etichetta(fascia, 26, "manifesto" if tinta == "bordo" else "testo", tinta)
	sopra.add_child(fascia)
	fascia.reset_size()
	var vetro := sotto.get_global_rect()
	var fermo := Vector2(vetro.position.x + 10.0, vetro.position.y + minf(vetro.size.y, 226.0) - fascia.size.y)
	if sotto == pezzi[0]:
		fermo = Vector2(vetro.position.x + 30.0, vetro.end.y - fascia.size.y - 30.0)
	fascia.position = fermo - Vector2(140.0, 0.0)
	fascia.modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.tween_property(fascia, "position", fermo, Movimento.durata("entrata")) \
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t.tween_property(fascia, "modulate:a", 1.0, 0.08)


func accendi_nemico() -> void:
	var vetro := pezzi[0].get_global_rect().grow(-16.0)
	if lampo_nemico == null:
		lampo_nemico = ColorRect.new()
		lampo_nemico.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sopra.add_child(lampo_nemico)
		sopra.move_child(lampo_nemico, 0)
	lampo_nemico.position = vetro.position
	lampo_nemico.size = vetro.size
	lampo_nemico.color = Color(Stile.colore("pericolo"), 0.0)
	var t := create_tween()
	for k in 2:
		t.tween_property(lampo_nemico, "color:a", 0.32, 0.07)
		t.tween_property(lampo_nemico, "color:a", 0.0, 0.22)
	var su := create_tween()
	pezzi[0].pivot_offset = pezzi[0].size * 0.5
	su.tween_property(pezzi[0], "scale", Vector2.ONE * 1.025, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	su.tween_property(pezzi[0], "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


# --- LA MATTANZA ---------------------------------------------------------------
# Il taglio a tutto schermo: un lampo, una fascia nera e una rossa che entrano
# di traverso da parti opposte, l'iniziale di chi la fa che scivola, la parola
# che cade come un timbro, le schegge. Poi tutto se ne va com'e' venuto e lo
# scontro sbanda. Dal lampo alla fine, un secondo: si vede una volta per
# scontro, e un clic lo salta.

const PARTE := 0.6
var velo: ColorRect
var bianco: ColorRect
var fascia_nera: Node2D
var fascia_rossa: Node2D
var fascia_chiara: Node2D
var iniziale: Label
var parola: Label
var corse: Corse


func prepara_mattanza() -> void:
	var largo := plancia.radice.size.x
	var alto := plancia.radice.size.y
	velo = ColorRect.new()
	velo.color = Color(Stile.colore("sfondo"), 0.0)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sopra.add_child(velo)
	var centro := Vector2(largo * 0.5, alto * 0.5)
	fascia_chiara = banda(centro + Vector2(0, -128), largo * 1.6, 16.0, Stile.colore("manifesto"))
	fascia_nera = banda(centro, largo * 1.6, 230.0, Stile.colore("sfondo"))
	fascia_rossa = banda(centro + Vector2(0, 138), largo * 1.6, 34.0, Stile.colore("pericolo"))
	corse = Corse.new()
	fascia_nera.add_child(corse)
	iniziale = Label.new()
	iniziale.text = String(plancia.slot[0].iniziale.text)
	iniziale.add_theme_font_override("font", Caratteri.titolo())
	iniziale.add_theme_font_size_override("font_size", 300)
	iniziale.add_theme_color_override("font_color", Stile.colore("manifesto"))
	sopra.add_child(iniziale)
	parola = Label.new()
	parola.text = "MATTANZA"
	parola.add_theme_font_override("font", Caratteri.titolo())
	parola.add_theme_font_size_override("font_size", 128)
	parola.add_theme_color_override("font_color", Stile.colore("pericolo"))
	parola.add_theme_color_override("font_outline_color", Stile.colore("testo"))
	parola.add_theme_constant_override("outline_size", 10)
	sopra.add_child(parola)
	parola.reset_size()
	iniziale.reset_size()
	parola.pivot_offset = parola.size * 0.5
	parola.position = centro - parola.size * 0.5 + Vector2(110, 0)
	parola.rotation_degrees = -7.0
	parola.modulate.a = 0.0
	iniziale.position = Vector2(-500, centro.y - iniziale.size.y * 0.55)
	bianco = ColorRect.new()
	bianco.color = Color(1, 1, 1, 0.0)
	bianco.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bianco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sopra.add_child(bianco)
	sopra.move_child(schegge.get_parent(), -1)


func banda(centro: Vector2, largo: float, alto: float, tinta: Color) -> Node2D:
	# una fascia di carta di traverso: un parallelogramma, ruotato di 7 gradi
	var perno := Node2D.new()
	perno.position = centro
	perno.rotation_degrees = -7.0
	var p := Polygon2D.new()
	var s := alto * 0.35
	p.polygon = PackedVector2Array([Vector2(-largo * 0.5 + s, -alto * 0.5), Vector2(largo * 0.5 + s, -alto * 0.5),
			Vector2(largo * 0.5 - s, alto * 0.5), Vector2(-largo * 0.5 - s, alto * 0.5)])
	p.color = tinta
	perno.add_child(p)
	perno.visible = false
	sopra.add_child(perno)
	return perno


func passa_mattanza() -> void:
	if una_volta("prepara", 0.0):
		prepara_mattanza()
	var largo := plancia.radice.size.x
	var centro := plancia.radice.size * 0.5
	var dentro := tempo - PARTE
	if dentro < 0.0:
		return
	# il lampo e il velo
	bianco.color.a = 0.75 * (1.0 - clampf(dentro / 0.12, 0.0, 1.0))
	var esce := clampf((dentro - 0.95) / 0.16, 0.0, 1.0)
	velo.color.a = 0.5 * clampf(dentro / 0.08, 0.0, 1.0) * (1.0 - esce)
	# le tre fasce: entrano da parti opposte, ed escono dall'altra parte
	entra_banda(fascia_nera, -1.0, dentro, 0.0, esce, largo)
	entra_banda(fascia_rossa, 1.0, dentro, 0.03, esce, largo)
	entra_banda(fascia_chiara, -1.0, dentro, 0.05, esce, largo)
	# l'iniziale scivola sulla fascia nera, e continua piano a scivolare
	var w := Movimento.curva("entrata", clampf((dentro - 0.04) / 0.18, 0.0, 1.0))
	iniziale.position.x = lerpf(-520.0, 150.0, w) + 40.0 * clampf(dentro / 1.0, 0.0, 1.0) + esce * largo
	iniziale.visible = true
	# la parola cade come un timbro
	var caduta := clampf((dentro - 0.14) / 0.16, 0.0, 1.0)
	parola.modulate.a = clampf(caduta * 3.0, 0.0, 1.0) * (1.0 - esce)
	var rimbalzo: float = Tween.interpolate_value(0.0, 1.0, caduta, 1.0, Tween.TRANS_BACK, Tween.EASE_OUT)
	parola.scale = Vector2.ONE * lerpf(2.2, 1.0, rimbalzo)
	parola.position.x = centro.x - parola.size.x * 0.5 + 110.0 - esce * largo * 1.1
	if una_volta("schegge", PARTE + 0.26):
		schegge.scoppia(parola.get_global_rect().get_center())
		schegge.scoppia(parola.get_global_rect().get_center() + Vector2(160, -20))
	if una_volta("scossa", PARTE + 1.12):
		scena.impatto.scossa(10.0)


func entra_banda(b: Node2D, verso: float, dentro: float, ritardo: float, esce: float, largo: float) -> void:
	var u := Movimento.curva("entrata", clampf((dentro - ritardo) / 0.15, 0.0, 1.0))
	b.visible = dentro >= ritardo
	var centro_x := largo * 0.5
	b.position.x = centro_x + verso * largo * 1.4 * (1.0 - u) - verso * largo * 1.4 * Movimento.curva("uscita", esce)


# --- IL MINIGIOCO --------------------------------------------------------------
# Le Collisioni infinite di oggi, con il corpo intorno: quando un pugno sta per
# arrivare il suo anello si riempie di tacche che corrono verso il centro (dice
# "adesso" anche con la coda dell'occhio); la parata fa un anello bianco che si
# allarga, PARATA! come un timbro e le schegge, e il quadrante sobbalza; il
# colpo preso crepa lo schermo, lo fa sbandare forte e accende di rosso chi l'ha
# preso. Il gioco sotto e' quello vero: qui si guarda solo cosa succede.

var gioco: MinigiocoCombattimento
const PARATE := [0, 1, 3, 4, 6]
var giudicati: Dictionary = {}


func prepara_collisioni() -> void:
	gioco = scena.minigioco
	gioco.avvia({"nome": "Collisioni infinite", "quanti": 7, "intervallo": 0.85, "durata": 1.4, "danno": 9})
	gioco.salta()


func passa_collisioni(delta: float) -> void:
	if gioco.fase != "raffica":
		return
	gioco.passa(delta)
	# il timbro prende il posto della scritta di oggi sul pugno
	for scritta in gioco.riquadro.scritte:
		scritta.visible = false
	var piano: Control = gioco.riquadro.piano
	var r: float = gioco.riquadro.raggio()
	for pugno: Dictionary in gioco.raffica:
		var i := int(pugno.indice)
		var dove: Vector2 = piano.get_global_transform() * gioco.riquadro.centro_di(pugno)
		var manca := float(pugno.impatto) - gioco.tempo
		# l'anticipo: le tacche che corrono verso il pugno nell'ultimo mezzo secondo
		if String(pugno.esito) == "" and manca < 0.5 and manca > -0.05 and gioco.tempo >= float(pugno.istante):
			lampi.anticipo(i, dove, r, 1.0 - manca / 0.5)
		else:
			lampi.anticipo(i, dove, r, -1.0)
		if i in PARATE and String(pugno.esito) == "" and manca <= 0.03:
			gioco.colpisci(i)
		if String(pugno.esito) != "" and not giudicati.has(i):
			giudicati[i] = true
			if String(pugno.esito) == "preso":
				preso(dove, r)
			else:
				parato(dove, r)


func parato(dove: Vector2, r: float) -> void:
	lampi.anello(dove, r)
	schegge.scoppia(dove)
	timbro("PARATA!", dove + Vector2(r * 1.2, -r * 1.4), "bordo", "manifesto")
	sobbalza(pezzi[pezzi.size() - 1], 4.0)
	gelatina(gioco.riquadro.contatore)


func preso(dove: Vector2, r: float) -> void:
	lampi.crepa(dove, r)
	scena.impatto.scossa(12.0)
	var quadrante := pezzi[pezzi.size() - 1]
	lampi.rosso(quadrante.get_global_rect().grow(-10.0))
	var chi: Control = plancia.slot[0].iniziale
	var t := create_tween()
	t.tween_property(chi, "modulate", Color(1.0, 0.25, 0.2), 0.05)
	t.tween_property(chi, "modulate", Color.WHITE, 0.4)
	timbro("PRESO", dove + Vector2(r * 1.2, -r * 1.4), "pericolo", "testo")


func timbro(scritta: String, dove: Vector2, tinta: String, inchiostro: String) -> void:
	var l := Label.new()
	l.text = scritta
	Manifesto.vesti_etichetta(l, 30, inchiostro, tinta)
	sopra.add_child(l)
	l.reset_size()
	l.pivot_offset = l.size * 0.5
	l.position = dove - l.size * 0.5
	l.rotation_degrees = -8.0
	l.scale = Vector2.ONE * 1.8
	var t := create_tween()
	t.tween_property(l, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_interval(0.35)
	t.tween_property(l, "modulate:a", 0.0, 0.2)
	t.tween_callback(l.queue_free)


func sobbalza(nodo: Control, quanto: float) -> void:
	var base := nodo.position
	var t := create_tween()
	t.tween_property(nodo, "position", base + Vector2(0, quanto), 0.04)
	t.tween_property(nodo, "position", base, 0.18).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func gelatina(nodo: Control) -> void:
	if nodo == null:
		return
	nodo.pivot_offset = nodo.size * 0.5
	var t := create_tween()
	t.tween_property(nodo, "scale", Vector2(1.35, 0.8), 0.05)
	t.tween_property(nodo, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


# --- I PEZZI CHE DISEGNANO -----------------------------------------------------

class Braci extends Control:
	# LE BRACI: i Carnivalz «sono mondi in fiamme». Rombi piccoli (il rombo e'
	# il segno del gioco) che salgono piano dal fondo, ondeggiano e girano; un
	# po' chiari come scintille, un po' scuri come cenere
	var semi: Array[Dictionary] = []
	var dado := RandomNumberGenerator.new()

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		dado.seed = 11

	func riempi(quante: int) -> void:
		for i in quante:
			semi.append(nuova(true))

	func nuova(ovunque: bool) -> Dictionary:
		var campo := size if size.x > 1.0 else Vector2(1280.0, 720.0)
		return {"p": Vector2(dado.randf() * campo.x, dado.randf() * campo.y if ovunque else campo.y + 12.0),
				"v": dado.randf_range(16.0, 46.0), "onda": dado.randf_range(6.0, 22.0),
				"freq": dado.randf_range(0.3, 0.8), "fase": dado.randf() * TAU,
				"lato": dado.randf_range(2.6, 6.2), "giro": dado.randf() * TAU,
				"vel_giro": dado.randf_range(-1.2, 1.2), "eta": dado.randf() * 5.0 if ovunque else 0.0,
				"vita": dado.randf_range(7.0, 12.0), "scura": dado.randf() < 0.4}

	func avanza(dt: float) -> void:
		for i in semi.size():
			var s: Dictionary = semi[i]
			var p: Vector2 = s["p"]
			p.y -= float(s["v"]) * dt
			s["p"] = p
			s["eta"] = float(s["eta"]) + dt
			s["giro"] = float(s["giro"]) + float(s["vel_giro"]) * dt
			if p.y < -12.0 or float(s["eta"]) > float(s["vita"]):
				semi[i] = nuova(false)
		queue_redraw()

	func _draw() -> void:
		for s in semi:
			var u := clampf(float(s["eta"]) / float(s["vita"]), 0.0, 1.0)
			var a := sin(PI * u)
			var p: Vector2 = s["p"]
			var x := p.x + sin(float(s["eta"]) * TAU * float(s["freq"]) + float(s["fase"])) * float(s["onda"])
			var tinta := Color(0.06, 0.04, 0.03, 0.45 * a) if bool(s["scura"]) else Color(1.0, 0.9, 0.62, 0.85 * a)
			var l := float(s["lato"])
			var g := float(s["giro"])
			if not bool(s["scura"]):
				# l'alone delle scintille
				draw_colored_polygon(rombo(Vector2(x, p.y), g, l * 2.4), Color(1.0, 0.95, 0.75, 0.16 * a))
			draw_colored_polygon(rombo(Vector2(x, p.y), g, l), tinta)

	func rombo(centro: Vector2, giro: float, l: float) -> PackedVector2Array:
		var punti := PackedVector2Array()
		for k in 4:
			punti.append(centro + Vector2.from_angle(giro + k * PI * 0.5) * l * (1.8 if k % 2 == 0 else 1.0))
		return punti


class Riflesso extends Control:
	# IL RIFLESSO SUL VETRO: ogni tanto passa una lama di luce di traverso, come
	# su uno schermo vero quando ti muovi. Ognuno col suo tempo, mai insieme
	const PASSA := 0.75
	var periodo := 4.6
	var ritardo := 0.0
	var orologio := 0.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip_contents = true

	func avanza(dt: float) -> void:
		orologio += dt
		queue_redraw()

	func _draw() -> void:
		if orologio < ritardo:
			return
		var u := fposmod(orologio - ritardo, periodo) / PASSA
		if u > 1.0:
			return
		var largo := size.x * 0.2
		var storto := size.y * 0.5
		var x := lerpf(-largo - storto, size.x + storto, Movimento.curva("standard", u))
		var a := 0.11 * sin(PI * u)
		draw_colored_polygon(PackedVector2Array([Vector2(x + storto, 0), Vector2(x + storto + largo, 0),
				Vector2(x + largo, size.y), Vector2(x, size.y)]), Color(1, 1, 1, a))
		var f := x + largo * 1.3
		draw_colored_polygon(PackedVector2Array([Vector2(f + storto, 0), Vector2(f + storto + largo * 0.18, 0),
				Vector2(f + largo * 0.18, size.y), Vector2(f, size.y)]), Color(1, 1, 1, a * 0.9))


class Corse extends Node2D:
	# LE LINEE DI CORSA sulla fascia della Mattanza: tratti chiari che scorrono
	# verso sinistra, perche' la fascia ferma sembri ancora in volo
	var orologio := 0.0
	var dado := RandomNumberGenerator.new()
	var tratti: Array[Vector3] = []   # x, y, lunghezza

	func _init() -> void:
		dado.seed = 3
		for i in 16:
			tratti.append(Vector3(dado.randf_range(-900, 900), dado.randf_range(-100, 100), dado.randf_range(60, 220)))

	func _process(delta: float) -> void:
		orologio += delta
		queue_redraw()

	func _draw() -> void:
		for v in tratti:
			var x := fposmod(v.x - orologio * 2400.0 + 900.0, 1800.0) - 900.0
			draw_line(Vector2(x, v.y), Vector2(x + v.z, v.y), Color(1, 1, 1, 0.22), 2.0)


class Lampi extends Control:
	# I RISCONTRI DEL MINIGIOCO, disegnati in un nodo solo: l'anticipo (tacche
	# che corrono verso il pugno), l'anello della parata, la crepa del colpo
	# preso, il velo rosso
	var segni: Array[Dictionary] = []
	var attese: Dictionary = {}     # indice del pugno -> [dove, raggio, quanto]

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func anticipo(indice: int, dove: Vector2, r: float, quanto: float) -> void:
		if quanto < 0.0:
			attese.erase(indice)
		else:
			attese[indice] = [dove, r, quanto]

	func anello(dove: Vector2, r: float) -> void:
		segni.append({"tipo": "anello", "dove": dove, "r": r, "eta": 0.0, "vita": 0.3})

	func crepa(dove: Vector2, r: float) -> void:
		var dado := RandomNumberGenerator.new()
		dado.seed = int(dove.x * 7.0 + dove.y)
		var rami: Array[PackedVector2Array] = []
		for k in 6:
			var verso := TAU * float(k) / 6.0 + dado.randf_range(-0.3, 0.3)
			var p := dove
			var ramo := PackedVector2Array([p])
			for passo in 4:
				p += Vector2.from_angle(verso + dado.randf_range(-0.5, 0.5)) * r * dado.randf_range(0.35, 0.7)
				ramo.append(p)
			rami.append(ramo)
		segni.append({"tipo": "crepa", "dove": dove, "r": r, "eta": 0.0, "vita": 0.7, "rami": rami})

	func rosso(dove: Rect2) -> void:
		segni.append({"tipo": "rosso", "rett": dove, "eta": 0.0, "vita": 0.35})

	func avanza(dt: float) -> void:
		var restano: Array[Dictionary] = []
		for s in segni:
			s["eta"] = float(s["eta"]) + dt
			if float(s["eta"]) < float(s["vita"]):
				restano.append(s)
		segni = restano
		queue_redraw()

	func _draw() -> void:
		for valore: Array in attese.values():
			var dove: Vector2 = valore[0]
			var r: float = valore[1]
			var q: float = valore[2]
			for k in 8:
				var verso := Vector2.from_angle(TAU * float(k) / 8.0 + 0.2)
				var fuori := r * lerpf(2.4, 1.25, q)
				draw_line(dove + verso * fuori, dove + verso * (fuori + r * 0.35), Color(1, 1, 1, 0.75 * q), 3.0, true)
		for s in segni:
			var u := float(s["eta"]) / float(s["vita"])
			match String(s["tipo"]):
				"anello":
					var dove: Vector2 = s["dove"]
					var r: float = s["r"]
					draw_arc(dove, r * lerpf(1.0, 2.6, u), 0.0, TAU, 48, Color(1, 1, 1, 1.0 - u), r * 0.22 * (1.0 - u) + 1.0, true)
				"crepa":
					var spegne := 1.0 - clampf((u - 0.6) / 0.4, 0.0, 1.0)
					var cresce := clampf(u / 0.12, 0.0, 1.0)
					var rami: Array[PackedVector2Array] = s["rami"]
					for ramo in rami:
						var fino := maxi(2, int(round(cresce * float(ramo.size()))))
						var tratto := ramo.slice(0, fino)
						draw_polyline(tratto, Color(1.0, 0.3, 0.25, 0.9 * spegne), 4.0, true)
						draw_polyline(tratto, Color(1, 1, 1, spegne), 1.5, true)
				"rosso":
					var rett: Rect2 = s["rett"]
					draw_rect(rett, Color(0.93, 0.11, 0.14, 0.32 * (1.0 - u)))
