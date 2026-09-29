class_name IndicazioneCombattimento
extends Control

# QUANDO LA LEZIONE INDICA UN PEZZO DELLO SCHERMO.
#
# Com'era: una macchia cremisi dietro al pezzo, quella del menu principale
# (Evidenza.gd). Bru, 29 settembre: «l'idea del evidenziare nel tutorial di
# veronica le parti dalle ui come nel menu principale e' stata pessima [...]
# dobbiamo trovare un altro modo».
#
# E guardando gli scatti c'era di peggio dello stile: mentre Veronica parla, il
# quadrante in basso a destra mostra il suo testo, e il menu, l'ECG, il morale,
# MATTANZA e BOND stanno TUTTI li' sotto. «Al centro la linea che batte» si
# leggeva con la linea coperta dalla frase che la nomina; e la macchia del
# menu diventava un bordo rosso intorno al box. La regola del tutorial - ogni
# cosa quando si vede (docs/tutorial.md, §6.4) - era rotta dallo schermo.
#
# Quindi due cose, e la prima non e' una questione di gusto:
#
#   1. IL PEZZO SI VEDE. Se sta nel quadrante, il box si sposta a sinistra,
#      sopra la scheda del nemico, su un leggio suo; il quadrante torna ai
#      comandi e il pezzo e' li'. Premere non si puo': mentre si legge, il clic
#      lo prende la zona "vai avanti" che copre lo schermo.
#   2. COME LO SI INDICA, e questo lo sceglie Bru (data/stile.json,
#      "indicazione"):
#        riflettore   lo schermo si abbassa e resta acceso solo il pezzo (e il
#                     testo): la luce si stringe su di lui arrivando
#        tratteggio   come nel giro del data pad: un velo leggero e la cornice
#                     tratteggiata che scorre
#        pennarello   un giro di pennarello cremisi intorno al pezzo, tracciato
#                     a mano mentre Veronica parla, come su una lavagna
#        riflettore_pennarello   le due cose insieme
#
# Sta sopra tutta la plancia e non prende il mouse. Si toglie da se' quando la
# plancia spegne l'indicazione, e riporta il box a casa.

const STILI := ["riflettore", "tratteggio", "pennarello", "riflettore_pennarello"]
const SCURO := 0.74          # il riflettore: quanto si abbassa il resto
const ARIA := 8.0            # di quanto il buco nel velo esce intorno al pezzo
const GIRO_LARGO := 10.0     # di quanto il pennarello gira fuori dal pezzo
const TRATTO := 5.0          # lo spessore del pennarello
const PUNTI_GIRO := 96
const OLTRE := 0.14          # il giro non si chiude esatto: la mano va un po' oltre

var plancia: PlanciaCombattimento
var pezzi: Array[Control] = []   # quello che si indica: di solito uno
var stile := "riflettore"
var quanto := 0.0:            # l'arrivo, da 0 a 1: la luce che si stringe, il tratto
	set(valore):
		quanto = valore
		queue_redraw()
var arrivo: Tween = null
var cornici: Array[Evidenza] = []   # solo per il tratteggio, una per pezzo
var leggio: Control = null    # dove va il box quando il pezzo sta sotto di lui
var box_prestato := false
var onde := Vector4.ZERO      # le fasi del tremito del pennarello: per pezzo, sempre uguali


static func su(con: PlanciaCombattimento, indicati: Array[Control]) -> IndicazioneCombattimento:
	var questa := IndicazioneCombattimento.new()
	questa.plancia = con
	questa.pezzi = indicati
	questa.stile = stile_scelto()
	questa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dado := RandomNumberGenerator.new()
	dado.seed = absi(hash(indicati[0].name))
	questa.onde = Vector4(dado.randf_range(0.0, TAU), dado.randf_range(0.0, TAU),
			dado.randf_range(-0.9, -0.6), dado.randf_range(0.0, TAU))
	for indicato in indicati:
		if con.quadrante.is_ancestor_of(indicato) and not questa.box_prestato:
			questa.presta_il_box()
	con.radice.add_child(questa)
	questa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if questa.stile == "tratteggio":
		for indicato in indicati:
			var cornice := Evidenza.libera("cornice")
			questa.add_child(cornice)
			cornice.inquadra(questa.dove_sta(indicato))
			cornice.accendi()
			questa.cornici.append(cornice)
	questa.accendi()
	return questa


static func stile_scelto() -> String:
	# un nome sbagliato nei dati deve dirlo: un'indicazione che non si vede e'
	# uguale a una che nessuno ha chiesto
	var scelto := String((Stile.dati.get("indicazione", {}) as Dictionary).get("stile", "riflettore"))
	if scelto in STILI:
		return scelto
	push_error("stile.json: l'indicazione '%s' non esiste (ci sono %s)" % [scelto, ", ".join(STILI)])
	return "riflettore"


func accendi() -> void:
	if Movimento.ridotto():
		quanto = 1.0
		return
	quanto = 0.0
	# il pennarello ha bisogno di un po' piu' di tempo: e' un gesto, non un lampo
	var tempo := Movimento.durata("entrata") * (2.2 if "pennarello" in stile else 1.4)
	arrivo = create_tween()
	arrivo.tween_property(self, "quanto", 1.0, tempo).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func togli() -> void:
	if arrivo != null and arrivo.is_valid():
		arrivo.kill()
	for cornice in cornici:
		cornice.ferma()
	restituisci_il_box()
	queue_free()


# --- il box che si sposta ------------------------------------------------------

func presta_il_box() -> void:
	# IL BOX VA SOPRA LA SCHEDA DEL NEMICO, alto quanto il quadrante: e' l'unico
	# posto dove non copre niente di quello che la lezione nomina (la terza barra,
	# quella del Dominio, sta nella squadra in alto; la scheda si spiega col box
	# ancora al suo posto)
	var box := plancia.box_testo
	if box == null:
		return
	leggio = plancia.pannello()
	leggio.name = "Leggio"
	var sopra := plancia.scheda_nemico.get_rect()
	var alto := plancia.quadrante.get_rect()
	leggio.position = Vector2(sopra.position.x, alto.position.y)
	leggio.size = Vector2(sopra.size.x, alto.size.y)
	box.get_parent().remove_child(box)
	plancia.interno_di(leggio).add_child(box)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if box.has_method("posto_al_triangolo"):
		box.posto_al_triangolo(true)   # il leggio e' stretto: l'ultima parola ci finiva sotto
	box_prestato = true


func restituisci_il_box() -> void:
	if not box_prestato:
		return
	box_prestato = false
	var box := plancia.box_testo
	if box != null:
		if box.has_method("posto_al_triangolo"):
			box.posto_al_triangolo(false)
		plancia.ospita_box(box)
	if leggio != null:
		leggio.queue_free()
		leggio = null


# --- il disegno ------------------------------------------------------------------

func dove_sta(nodo: Control) -> Rect2:
	# il rettangolo di un pezzo nelle coordinate di questo strato
	var globale := nodo.get_global_rect()
	return Rect2(globale.position - get_global_rect().position, globale.size)


func dove_si_legge() -> Rect2:
	return dove_sta(leggio if leggio != null else plancia.quadrante)


func _process(_delta: float) -> void:
	# i pezzi e il box possono muoversi (la finestra cambia misura): si segue
	for k in mini(cornici.size(), pezzi.size()):
		if is_instance_valid(pezzi[k]):
			cornici[k].inquadra(dove_sta(pezzi[k]))
	queue_redraw()


func _draw() -> void:
	var veri: Array[Control] = []
	for indicato in pezzi:
		if is_instance_valid(indicato):
			veri.append(indicato)
	if veri.is_empty():
		return
	if stile in ["riflettore", "riflettore_pennarello"]:
		velo(SCURO, veri, true)
	elif stile == "tratteggio":
		velo(0.28, veri, false)
	if "pennarello" in stile:
		for indicato in veri:
			pennarello(dove_sta(indicato))


func velo(scuro: float, indicati: Array[Control], stringe: bool) -> void:
	var tinta := Color(0, 0, 0, scuro * clampf(quanto * 1.5, 0.0, 1.0))
	for pezzo_di_velo in fuori_dai_buchi(Rect2(Vector2.ZERO, size), buchi(indicati, stringe)):
		draw_rect(pezzo_di_velo, tinta)


func buchi(indicati: Array[Control], stringe: bool) -> Array[Rect2]:
	# IL RIFLETTORE: tutto si abbassa tranne i pezzi e il testo che li spiega.
	# Arrivando la luce parte da tutto lo schermo e si stringe su di loro -
	# l'occhio la segue, ed e' quello che lo porta li'
	var tutto := Rect2(Vector2.ZERO, size)
	var aperti: Array[Rect2] = [dove_si_legge()]
	var q := clampf(quanto, 0.0, 1.0)
	for indicato in indicati:
		var luce := dove_sta(indicato).grow(ARIA)
		if plancia.quadrante.is_ancestor_of(indicato):
			# dentro il quadrante la luce non esce dal suo bordo nero
			luce = luce.intersection(dove_sta(plancia.interno_di(plancia.quadrante)))
		if stringe:
			luce = Rect2(tutto.position.lerp(luce.position, q), tutto.size.lerp(luce.size, q))
		aperti.append(luce)
	return aperti


func pennarello(sul_pezzo: Rect2) -> void:
	# UN GIRO A MANO: una forma a meta' fra il rettangolo e l'ellisse, che trema
	# piano e che alla fine va un po' oltre dove era partita, come fa una mano
	# vera. Parte dall'angolo in alto a sinistra e gira in senso orario
	# UN PEZZO GRANDE SI SEGNA DA DENTRO: intorno al riquadro del nemico il giro
	# passava sopra lo slot di chi ha il turno, e due segni rossi vicini non
	# indicano niente
	var grande := minf(sul_pezzo.size.x, sul_pezzo.size.y) > size.y * 0.3
	var giro := giro_di_pennarello(sul_pezzo.grow(-GIRO_LARGO * 2.0 if grande else GIRO_LARGO), onde)
	var quanti := int(clampf(quanto, 0.0, 1.0) * float(giro.size() - 1)) + 1
	if quanti < 2:
		return
	draw_polyline(giro.slice(0, quanti), Stile.colore("accento"), TRATTO, true)


static func giro_di_pennarello(intorno: Rect2, fasi: Vector4) -> PackedVector2Array:
	var centro := intorno.get_center()
	var mezzo := intorno.size * 0.5
	var punti := PackedVector2Array()
	var quanti := int(PUNTI_GIRO * (1.0 + OLTRE))
	for i in quanti + 1:
		var t := float(i) / float(PUNTI_GIRO)
		var angolo := fasi.z * PI + t * TAU
		var c := cos(angolo)
		var s := sin(angolo)
		# la superellisse con l'esponente a 4 abbraccia un rettangolo senza
		# toccarne gli spigoli
		var raggio := pow(pow(absf(c), 4.0) + pow(absf(s), 4.0), -0.25)
		var tremito := 2.6 * sin(3.0 * angolo + fasi.x) + 1.6 * sin(7.0 * angolo + fasi.y)
		# il ritorno passa un po' piu' fuori dell'andata: il tratto non si ricalca
		var fuori := tremito + 5.0 * t
		punti.append(centro + Vector2(c * raggio * mezzo.x, s * raggio * mezzo.y)
				+ Vector2(c, s) * fuori)
	return punti


static func fuori_dai_buchi(tutto: Rect2, buchi: Array) -> Array[Rect2]:
	# IL VELO CON I BUCHI, fatto di rettangoli: a fasce orizzontali, e in ogni
	# fascia i pezzi fra un buco e l'altro. Un poligono con due buchi dentro
	# Godot non lo riempie
	var tagli: Array[float] = [tutto.position.y, tutto.end.y]
	var dentro: Array[Rect2] = []
	for buco: Rect2 in buchi:
		var b := buco.intersection(tutto)
		if b.has_area():
			dentro.append(b)
			tagli.append(b.position.y)
			tagli.append(b.end.y)
	tagli.sort()
	var strisce: Array[Rect2] = []
	for k in tagli.size() - 1:
		var y0 := tagli[k]
		var y1 := tagli[k + 1]
		if y1 - y0 <= 0.0:
			continue
		var x := tutto.position.x
		var aperti: Array[Rect2] = []
		for b in dentro:
			if b.position.y <= y0 and b.end.y >= y1:
				aperti.append(b)
		aperti.sort_custom(func(a: Rect2, b: Rect2) -> bool: return a.position.x < b.position.x)
		for b in aperti:
			if b.position.x > x:
				strisce.append(Rect2(x, y0, b.position.x - x, y1 - y0))
			x = maxf(x, b.end.x)
		if x < tutto.end.x:
			strisce.append(Rect2(x, y0, tutto.end.x - x, y1 - y0))
	return strisce
