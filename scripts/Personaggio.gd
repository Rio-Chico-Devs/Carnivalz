class_name SchedaPersonaggio
extends Control

# La scheda della squadra: chi e', cosa porta addosso, quanto vale.
#
# COME E' FATTA. E' lo schema che Bru ha preso dal suo riferimento, specchiato
# come l'ha chiesto lui - il personaggio e le carte a destra, le informazioni a
# sinistra - e ridipinto coi colori del gioco (docs/interfaccia.md):
#
#   in alto        Indietro, il Data pad, e il titolo
#   a sinistra     l'emblema, il nome, il livello; sotto, le statistiche; in
#                  fondo il carosello dell'equipaggiamento
#   al centro      il personaggio a figura intera, sulla fascia cremisi
#   a destra       le carte della squadra; sotto, il dettaglio dello slot - o,
#                  quando ne apri uno, la scelta di cosa metterci
#
# LE TRE REGOLE DI PRIMA RESTANO, perche' sono quelle di chi fa questo mestiere
# da vent'anni:
#   1. TUTTO SU UNA SCHERMATA. Chi cambia un accessorio vede subito cosa
#      succede alle statistiche: stanno a mezzo schermo di distanza.
#   2. SEMPRE LA DIFFERENZA, MAI SOLO IL NUMERO. Ogni candidato dice cosa
#      cambia rispetto a quello che porti; passandoci sopra, le statistiche
#      mostrano dove andresti ("15 → 17").
#   3. QUELLO CHE NON PUOI ANCORA USARE SI VEDE, E SI CAPISCE PERCHE'. Lo slot
#      chiuso sta nel carosello col lucchetto e il livello a cui si apre.
#
# Vive dentro la Pausa (ESC) come un foglio intero sopra tutto: cosi' si apre
# da ovunque - mappa, stanza, Vuoto - senza cambiare scena. I conti (quanto
# vale, cosa cambierebbe) stanno in Corredo.gd; qui si disegna e si risponde.
#
# LA TASTIERA sta tutta sul carosello: destra e sinistra girano gli slot, su e
# giu' cambiano compagno, INVIO apre lo slot al centro, ESC chiude la scelta e
# poi la scheda. Col mouse: clic sulle carte, rotella sulla fila per vedere
# gli altri, clic sulle caselle laterali per girare.

const CARTE := Rect2(1002, 119, 249, 84)
const PASSO_CARTE := 107.0
const QUANTE_CARTE := 3
const CASELLE: Array[Rect2] = [Rect2(44, 513, 123, 154), Rect2(189, 477, 164, 208), Rect2(372, 513, 121, 154)]
const FIGURA := Rect2(500, 62, 490, 658)
const DETTAGLIO := Rect2(1002, 430, 249, 256)

var id_scelto := ""
var slot_aperto := ""          # slot di cui si stanno scegliendo gli oggetti
var indice_aperto := 0         # quale accessorio, se lo slot è "accessori"
var slot_centro := 0           # quale slot sta al centro del carosello
var inizio_carte := 0

var su_indietro := Callable()
var su_diario := Callable()

var tavola: Tavola
var barra: Control
var sinistra: Control
var carosello: Control
var destra: Control
var carte: Array[CartaSquadra] = []
var caselle: Array[SlotScheda] = []
var figura: FiguraIntera
var emblema: Emblema
var nome: Label
var livello: Label
var classe: Label
var psiche: Label
var legame: Label
var barra_legame: Barra
var statistiche: StatisticheScheda
var dove_sei: Label
var solo_un_tratto: Label
var quante_carte: Label
var titolo_dettaglio: Label
var testo_dettaglio: TestoCheScorre
var scorri: ScrollContainer
var elenco: VBoxContainer
var togli: TastoObliquo
var chiudi_scelta: TastoObliquo
var su_carte: TastoObliquo
var giu_carte: TastoObliquo
var giro: Tween


func apri(indietro: Callable, diario: Callable) -> void:
	su_indietro = indietro
	su_diario = diario
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP     # il foglio copre: sotto non si clicca niente
	costruisci_tavola()
	id_scelto = GameState.party[0] if not GameState.party.is_empty() else GameState.id_protagonista
	inizio_carte = 0
	ridisegna()
	entra()
	Tavola.fuoco.call_deferred(caselle[1] as Control if caselle[1].visible else carte[0] as Control)


func _unhandled_input(evento: InputEvent) -> void:
	# ESC mentre scegli cosa mettere chiude la scelta, non la scheda: prima si
	# torna indietro di un passo, poi di una schermata. Una scheda che se ne
	# sta andando (Movimento.congeda la fa sorda) non risponde piu'
	if mouse_filter == Control.MOUSE_FILTER_IGNORE:
		return
	if slot_aperto != "" and evento.is_action_pressed("ui_cancel"):
		chiudi_la_scelta()
		get_viewport().set_input_as_handled()


# --- la tavola ------------------------------------------------------------------

func costruisci_tavola() -> void:
	tavola = Tavola.su(self)
	tavola.add_child(Fondo.new())
	figura = FiguraIntera.new()
	tavola.add_child(figura)
	Tavola.metti(figura, FIGURA)
	sinistra = gruppo()
	carosello = gruppo()
	destra = gruppo()
	barra = gruppo()
	costruisci_identita()
	costruisci_carosello()
	costruisci_destra()
	costruisci_barra()


func gruppo() -> Control:
	var g := Control.new()
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tavola.add_child(g)
	Tavola.metti(g, Rect2(0, 0, Tavola.LARGO, Tavola.ALTO))
	return g


func scritta(dove: Control, rettangolo: Rect2, corpo: int, colore: Color, font: Font,
		allinea := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var e := Tavola.scritta("", corpo, colore, font, allinea)
	dove.add_child(e)
	Tavola.metti(e, rettangolo)
	e.clip_text = true
	return e


func costruisci_barra() -> void:
	var indietro := TastoObliquo.nuovo("INDIETRO", "accento", 20)
	indietro.scelto.connect(func() -> void:
		if su_indietro.is_valid():
			su_indietro.call())
	barra.add_child(indietro)
	indietro.position = Vector2(16, 10)
	var diario := TastoObliquo.nuovo(GameState.nome_diario().to_upper(), "spoglio", 20)
	diario.scelto.connect(func() -> void:
		if su_diario.is_valid():
			su_diario.call())
	barra.add_child(diario)
	diario.position = Vector2(24 + indietro.misura_voluta().x, 10)
	var titolo := Cartiglio.nuovo("SQUADRA", Stile.colore("accento"), Stile.colore("testo"),
			Stile.colore("bordo_acceso"), Stile.dimensione("sezione"))
	barra.add_child(titolo)
	titolo.size = titolo.get_combined_minimum_size()
	titolo.position = Vector2(Tavola.LARGO - titolo.size.x - 18.0, 4.0)
	titolo.svela(0.05)


func costruisci_identita() -> void:
	emblema = Emblema.new()
	sinistra.add_child(emblema)
	Tavola.metti(emblema, Rect2(38, 102, 97, 103))
	nome = scritta(sinistra, Rect2(153, 116, 280, 56), 44, Stile.colore("testo"), Caratteri.titolo())
	livello = scritta(sinistra, Rect2(420, 110, 70, 66), 60, Stile.colore("accento"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_RIGHT)
	scritta(sinistra, Rect2(158, 180, 64, 20), 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900)).text = "CLASSE"
	classe = scritta(sinistra, Rect2(222, 178, 180, 22), 15, Stile.colore("accento"), Caratteri.tondo(900))
	scritta(sinistra, Rect2(393, 180, 96, 20), 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_RIGHT).text = "LIVELLO"
	barra_legame = Barra.new()
	sinistra.add_child(barra_legame)
	Tavola.metti(barra_legame, Rect2(40, 210, 453, 6))
	psiche = scritta(sinistra, Rect2(40, 220, 280, 18), 12, Stile.colore("testo_smorzato"), Caratteri.tondo(900))
	legame = scritta(sinistra, Rect2(293, 220, 200, 18), 12, Stile.colore("testo_smorzato"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_RIGHT)
	scritta(sinistra, Rect2(60, 243, 240, 26), 20, Stile.colore("testo"), Caratteri.titolo()).text = "STATISTICHE"
	statistiche = StatisticheScheda.new()
	sinistra.add_child(statistiche)
	Tavola.metti(statistiche, Rect2(45, 272, 440, StatisticheScheda.MARGINE * 2.0 + StatisticheScheda.PASSO * Corredo.STATISTICHE.size()))


func costruisci_carosello() -> void:
	for i in 3:
		var casella := SlotScheda.new()
		carosello.add_child(casella)
		Tavola.metti(casella, CASELLE[i])
		casella.presa.connect(_su_casella)
		casella.gira.connect(gira)
		casella.compagno.connect(cambia_compagno_di)
		caselle.append(casella)
	dove_sei = scritta(carosello, Rect2(150, 690, 242, 20), 12, Stile.colore("testo_smorzato"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER)
	solo_un_tratto = scritta(carosello, Rect2(44, 540, 450, 60), 16, Stile.colore("testo_smorzato"), Caratteri.tondo(700))
	solo_un_tratto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	solo_un_tratto.clip_text = false
	solo_un_tratto.text = "È con te solo per un tratto: non gli si affida ancora niente."


func costruisci_destra() -> void:
	for i in QUANTE_CARTE:
		var carta := CartaSquadra.new()
		destra.add_child(carta)
		Tavola.metti(carta, Rect2(CARTE.position + Vector2(0, PASSO_CARTE * i), CARTE.size))
		carta.presa.connect(func(c: CartaSquadra) -> void: cambia_compagno(c.id_classe))
		# come sullo scaffale del negozio: dove sta il fuoco, sta la scelta
		carta.focus_entered.connect(func() -> void: cambia_compagno(carta.id_classe))
		carta.sposta.connect(cambia_compagno_di)
		carta.focus_neighbor_left = carta.get_path_to(caselle[1])
		carte.append(carta)
	# QUANDO LA SQUADRA NON CI STA IN TRE CARTE: due frecce e il conto sopra
	# la fila, e la fila segue chi scegli. Senza, il quarto compagno non si
	# raggiungeva ne' col mouse ne' con la tastiera
	su_carte = TastoObliquo.nuovo("SU", "chiaro", 12)
	giu_carte = TastoObliquo.nuovo("GIÙ", "chiaro", 12)
	su_carte.freccia = Vector2.UP
	giu_carte.freccia = Vector2.DOWN
	su_carte.scelto.connect(cambia_compagno_di.bind(-1))
	giu_carte.scelto.connect(cambia_compagno_di.bind(1))
	for k in 2:
		var freccia: TastoObliquo = [su_carte, giu_carte][k]
		destra.add_child(freccia)
		freccia.position = Vector2(CARTE.position.x + 40.0 * k, 80.0)
	quante_carte = scritta(destra, Rect2(1100, 86, 151, 22), 12, Stile.colore("testo_smorzato"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_RIGHT)
	titolo_dettaglio = scritta(destra, Rect2(DETTAGLIO.position, Vector2(DETTAGLIO.size.x, 30)), 22, Stile.colore("testo"), Caratteri.titolo())
	testo_dettaglio = TestoCheScorre.nuovo(14, Stile.colore("testo_smorzato"), Stile.colore("sfondo"))
	destra.add_child(testo_dettaglio)
	Tavola.metti(testo_dettaglio, Rect2(DETTAGLIO.position + Vector2(0, 34), DETTAGLIO.size - Vector2(0, 34)))
	scorri = ScrollContainer.new()
	scorri.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scorri.follow_focus = true    # la freccia porta sotto il bordo: l'elenco la segue
	destra.add_child(scorri)
	Tavola.metti(scorri, Rect2(DETTAGLIO.position + Vector2(0, 34), Vector2(DETTAGLIO.size.x, 172)))
	elenco = VBoxContainer.new()
	elenco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	elenco.add_theme_constant_override("separation", 2)
	scorri.add_child(elenco)
	togli = TastoObliquo.nuovo("TOGLI", "spoglio", 18)
	togli.scelto.connect(togli_attuale)
	destra.add_child(togli)
	togli.position = Vector2(DETTAGLIO.position.x, DETTAGLIO.end.y - 42)
	chiudi_scelta = TastoObliquo.nuovo("CHIUDI", "chiaro", 18)
	chiudi_scelta.scelto.connect(chiudi_la_scelta)
	destra.add_child(chiudi_scelta)
	chiudi_scelta.position = Vector2(DETTAGLIO.end.x - 110, DETTAGLIO.end.y - 42)


# --- disegno ---------------------------------------------------------------------

func ridisegna() -> void:
	var slot := slot_elenco()
	allinea_al_centro(slot)
	mostra_nella_fila(id_scelto)
	disegna_carte()
	disegna_identita()
	disegna_statistiche()
	disegna_carosello(slot)
	disegna_dettaglio(slot)


func slot_elenco() -> Array[Dictionary]:
	# gli slot nell'ordine del carosello: arma, stigma, ultima risorsa, poi gli
	# accessori - quelli aperti, e UNO chiuso in piu', che dice che la strada
	# continua. Oltre non si va: una fila di lucchetti non e' una promessa, e' rumore
	var elenco_slot: Array[Dictionary] = []
	if not GameState.e_definitivo(id_scelto):
		return elenco_slot
	for coppia in [["arma", "ARMA"], ["stigma", "STIGMA"], ["ultima_risorsa", "ULTIMA RISORSA"]]:
		elenco_slot.append(dati_slot(String(coppia[0]), 0, String(coppia[1])))
	var quanti := GameState.slot_accessori_di(id_scelto)
	for indice in range(maxi(quanti, prossimo_slot_da_aprire(quanti))):
		elenco_slot.append(dati_slot("accessori", indice, "ACCESSORIO %d" % (indice + 1)))
	return elenco_slot


func dati_slot(slot: String, indice: int, etichetta: String) -> Dictionary:
	var aperto := slot != "accessori" or indice < GameState.slot_accessori_di(id_scelto)
	return {"slot": slot, "indice": indice, "etichetta": etichetta, "aperto": aperto,
			"oggetto": GameState.equipaggiato_in(id_scelto, slot, indice) if aperto else "",
			"livello": GameState.livello_slot_accessorio(indice) if not aperto else 0,
			"talento": GameState.talento_dello_slot(id_scelto, indice) if aperto and slot == "accessori" else ""}


func prossimo_slot_da_aprire(gia_aperti: int) -> int:
	return gia_aperti + 1 if GameState.livello_slot_accessorio(gia_aperti) > 0 else gia_aperti


func allinea_al_centro(slot: Array[Dictionary]) -> void:
	# chi apre uno slot da fuori (le prove, o un giorno un altro pannello) lo
	# trova al centro del carosello, dove si sceglie
	if slot.is_empty():
		slot_centro = 0
		slot_aperto = ""
		return
	for i in slot.size():
		if String(slot[i]["slot"]) == slot_aperto and int(slot[i]["indice"]) == indice_aperto:
			slot_centro = i
	slot_centro = posmod(slot_centro, slot.size())


func disegna_carte() -> void:
	var squadra := GameState.party
	inizio_carte = clampi(inizio_carte, 0, maxi(squadra.size() - QUANTE_CARTE, 0))
	for i in QUANTE_CARTE:
		var indice := inizio_carte + i
		var id := String(squadra[indice]) if indice < squadra.size() else ""
		carte[i].carica(id, id == id_scelto)
	var troppi := squadra.size() > QUANTE_CARTE
	quante_carte.text = "%d–%d DI %d" % [inizio_carte + 1, mini(inizio_carte + QUANTE_CARTE, squadra.size()),
			squadra.size()] if troppi else ""
	for k in 2:
		var freccia: TastoObliquo = [su_carte, giu_carte][k]
		freccia.visible = troppi
		var dove := squadra.find(id_scelto)
		freccia.inerte = dove <= 0 if k == 0 else dove >= squadra.size() - 1
		freccia.queue_redraw()


func mostra_nella_fila(id: String) -> void:
	# la finestra delle carte si sposta quel tanto che basta a far vedere id
	var dove := GameState.party.find(id)
	if dove >= 0:
		inizio_carte = clampi(inizio_carte, maxi(dove - QUANTE_CARTE + 1, 0), dove)


func disegna_identita() -> void:
	figura.mostra(id_scelto)
	emblema.id_classe = id_scelto
	emblema.queue_redraw()
	nome.text = Corredo.nome_di(id_scelto).to_upper()
	Tavola.stringi(nome, 44, 26)
	livello.text = "%d" % GameState.livello_di(id_scelto)
	var dati_classe: Dictionary = GameState.classi.get(id_scelto, {})
	classe.text = Corredo.classe_di(id_scelto).to_upper() if Corredo.classe_di(id_scelto) != "" else "—"
	var id_psiche := String(GameState.personaggi.get(id_scelto, dati_classe).get("psiche", dati_classe.get("psiche", "")))
	psiche.text = "PSICHE · %s" % String(GameState.psichi.get(id_psiche, {}).get("nome", id_psiche)).to_upper() if id_psiche != "" else ""
	legame.text = "LEGAME DELLA SQUADRA %d" % GameState.legame
	barra_legame.quota = clampf(float(GameState.legame) / 100.0, 0.0, 1.0)
	barra_legame.queue_redraw()


func disegna_statistiche() -> void:
	statistiche.imposta(Corredo.righe(id_scelto))


func disegna_carosello(slot: Array[Dictionary]) -> void:
	solo_un_tratto.visible = slot.is_empty()
	for k in 3:
		# con due soli slot ai lati ci sarebbe lo stesso slot due volte
		var serve := not slot.is_empty() and (k == 1 or slot.size() > 2 or (k == 2 and slot.size() == 2))
		if not serve:
			caselle[k].carica({}, false, false)
			continue
		var d: Dictionary = slot[posmod(slot_centro + k - 1, slot.size())]
		caselle[k].carica(d, k == 1, k == 1 and slot_aperto != "")
	if slot.is_empty():
		dove_sei.text = ""
		return
	dove_sei.text = "%s   ·   %d DI %d" % [String(slot[slot_centro]["etichetta"]), slot_centro + 1, slot.size()]


func disegna_dettaglio(slot: Array[Dictionary]) -> void:
	var scegliendo := slot_aperto != ""
	scorri.visible = scegliendo
	togli.visible = false
	chiudi_scelta.visible = scegliendo
	testo_dettaglio.visible = not scegliendo
	Albero.svuota(elenco)
	if scegliendo:
		titolo_dettaglio.text = "COSA METTERCI"
		riempi_scelta()
		return
	var d: Dictionary = slot[slot_centro] if not slot.is_empty() else {}
	var id_oggetto := String(d.get("oggetto", ""))
	titolo_dettaglio.text = Merce.nome_di(id_oggetto).to_upper() if id_oggetto != "" \
			else String(d.get("etichetta", "DI PASSAGGIO"))
	testo_dettaglio.scrivi(testo_del_dettaglio(d))


func testo_del_dettaglio(d: Dictionary) -> String:
	var righe: Array[String] = []
	var bianco := Stile.colore("testo").to_html(false)
	var id_oggetto := String(d.get("oggetto", ""))
	if d.is_empty():
		righe.append("Quando resterà con te, qui vedrai cosa porta addosso.")
	elif not bool(d.get("aperto", true)):
		righe.append("[b][color=#%s]Si apre al livello %d.[/color][/b]" % [bianco, int(d.get("livello", 0))])
	elif id_oggetto == "":
		righe.append("Vuoto. Premi la casella al centro per vedere cosa puoi metterci.")
	else:
		righe.append("[b][color=#%s]%s[/color][/b]" % [bianco, Merce.riassunto_effetto(GameState.dati_oggetto(id_oggetto))])
		righe.append(String(GameState.dati_oggetto(id_oggetto).get("descrizione", "")))
	if String(d.get("talento", "")) != "":
		# uno slot aperto da un talento lo dice: un premio che non sai di aver
		# vinto non e' un premio
		righe.append("Aperto grazie al tuo talento: %s" % String(d["talento"]))
	for protezione in Corredo.elenco_protezioni(id_scelto):
		righe.append("[color=#%s]· %s[/color]" % [Stile.colore("accento").to_html(false), protezione])
	return "\n".join(righe)


func riempi_scelta() -> void:
	# La regola che conta: ogni candidato mostra la DIFFERENZA rispetto a quello
	# che porti adesso in quello slot, non il suo valore assoluto
	var attuale := GameState.equipaggiato_in(id_scelto, slot_aperto, indice_aperto)
	togli.visible = attuale != ""
	var candidati := Corredo.oggetti_per_slot(slot_aperto)
	if candidati.is_empty():
		var niente := Tavola.scritta("Non hai niente da mettere qui.", 14, Stile.colore("testo_smorzato"), Caratteri.tondo(700))
		elenco.add_child(niente)
	var prima: VoceCandidato = null
	for id_oggetto in candidati:
		var scarti := Corredo.scarti_di(id_oggetto, attuale)
		var voce := VoceCandidato.nuova(id_oggetto, Merce.nome_di(id_oggetto), nota_di(id_oggetto),
				Corredo.differenza_testo(id_oggetto, attuale), Corredo.verso_di(scarti))
		voce.sopra.connect(func(_v: VoceCandidato) -> void: statistiche.mostra_anteprima(scarti))
		voce.lascia.connect(func(_v: VoceCandidato) -> void: anteprima_di_chi_resta())
		voce.presa.connect(func(v: VoceCandidato) -> void: metti(v.id_oggetto, attuale))
		elenco.add_child(voce)
		if prima == null:
			prima = voce
	tieni_il_fuoco_nella_scelta()
	if prima != null:
		Tavola.fuoco.call_deferred(prima)


func tieni_il_fuoco_nella_scelta() -> void:
	# MENTRE SI SCEGLIE, LE FRECCE RESTANO NELLA SCELTA: su dal primo candidato
	# finiva sulla carta di sopra - che cambiava compagno e chiudeva tutto. Si
	# esce con CHIUDI, con ESC o col mouse
	var voci: Array[Control] = []
	for figlio in elenco.get_children():
		if figlio is VoceCandidato:
			voci.append(figlio)
	var tasti: Array[Control] = [chiudi_scelta]
	if togli.visible:
		tasti.push_front(togli)
	for i in voci.size():
		var voce := voci[i]
		voce.focus_neighbor_left = voce.get_path_to(voce)
		voce.focus_neighbor_right = voce.get_path_to(voce)
		voce.focus_neighbor_top = voce.get_path_to(voci[i - 1] if i > 0 else voce)
		voce.focus_neighbor_bottom = voce.get_path_to(voci[i + 1] if i < voci.size() - 1 else tasti[0])
	for tasto in tasti:
		tasto.focus_neighbor_top = tasto.get_path_to(voci[-1] if not voci.is_empty() else tasto)
		tasto.focus_neighbor_bottom = tasto.get_path_to(tasto)
	tasti[0].focus_neighbor_left = tasti[0].get_path_to(tasti[0])
	tasti[-1].focus_neighbor_right = tasti[-1].get_path_to(tasti[-1])


func anteprima_di_chi_resta() -> void:
	# il mouse ha lasciato un candidato: l'anteprima torna a quello che ha il
	# fuoco, o sparisce. Restava quella dell'ultimo sfiorato, e le statistiche
	# dicevano "→ 24" di un oggetto che non stavi piu' guardando
	var chi := get_viewport().gui_get_focus_owner() as VoceCandidato
	statistiche.mostra_anteprima(Corredo.scarti_di(chi.id_oggetto,
			GameState.equipaggiato_in(id_scelto, slot_aperto, indice_aperto)) if chi != null else {})


func nota_di(id_oggetto: String) -> String:
	var portatore := GameState.portatore_di(id_oggetto)
	if portatore == id_scelto:
		# le armi non escono dallo zaino quando le impugni: restano li', segnate
		return "in uso"
	if portatore != "":
		return "addosso a %s" % Corredo.nome_di(portatore)
	return ""


# --- i gesti ----------------------------------------------------------------------

func cambia_compagno(id: String) -> void:
	if id == "" or id == id_scelto:
		return
	id_scelto = id
	slot_aperto = ""
	slot_centro = 0
	ridisegna()


func cambia_compagno_di(verso: int) -> void:
	# IL COMPAGNO PRIMA O DOPO NELLA FILA: su e giu' dal carosello o da una
	# carta, la rotella sulla fila, le due frecce. In cima e in fondo dice di
	# no, come lo scaffale del negozio.
	#
	# Il fuoco resta dov'era, se c'e' ancora. Due casi in cui non c'e': era su
	# una carta (la carta giusta adesso e' un'altra), o era sul carosello e il
	# compagno nuovo e' di passaggio - il carosello sparisce, e senza un fuoco
	# la tastiera non avrebbe piu' da dove tornare indietro
	var dove := GameState.party.find(id_scelto) + verso
	if dove < 0 or dove >= GameState.party.size():
		Movimento.suona("rifiuto")
		return
	var prima := get_viewport().gui_get_focus_owner()
	Movimento.suona("sfioro")
	cambia_compagno(String(GameState.party[dove]))
	var adesso := get_viewport().gui_get_focus_owner()
	if prima is CartaSquadra or adesso == null or not adesso.is_visible_in_tree():
		carte[dove - inizio_carte].grab_focus()


func _su_casella(casella: SlotScheda) -> void:
	var k := caselle.find(casella)
	if k != 1:
		gira(k - 1)
		return
	if slot_aperto != "":
		chiudi_la_scelta()
		return
	var slot := slot_elenco()
	if slot.is_empty():
		return
	slot_aperto = String(slot[slot_centro]["slot"])
	indice_aperto = int(slot[slot_centro]["indice"])
	ridisegna()


func gira(verso: int) -> void:
	var slot := slot_elenco()
	if slot.size() < 2:
		Movimento.suona("rifiuto")
		return
	slot_centro = posmod(slot_centro + verso, slot.size())
	slot_aperto = ""
	Movimento.suona("sfioro")
	ridisegna()
	caselle[1].grab_focus()
	if Movimento.ridotto():
		return
	# una scivolata alla volta: tenendo giu' la freccia ogni giro ferma quello
	# prima (e l'entrata, se la scheda si sta ancora aprendo)
	Tavola.ferma_entrata(carosello)
	if giro != null and giro.is_valid():
		giro.kill()
	carosello.position.x = 36.0 * float(verso)
	giro = carosello.create_tween()
	Movimento.verso(giro, carosello, "position:x", 0.0, "entrata", Movimento.durata("voce"))


func metti(id_oggetto: String, attuale: String) -> void:
	if attuale != "":
		GameState.togli_oggetto_equipaggiato(attuale)
	# AL POSTO DI QUELLO CHE C'ERA, non in fondo alla fila: gli accessori sono
	# una fila senza buchi, e chi cambia il primo lo vuole ancora primo
	if not GameState.equipaggia(id_scelto, slot_aperto, id_oggetto, indice_aperto) and attuale != "":
		# non e' entrato: quello di prima torna dov'era, invece di sparire
		GameState.equipaggia(id_scelto, slot_aperto, attuale, indice_aperto)
	chiudi_la_scelta(id_oggetto)


func togli_attuale() -> void:
	var attuale := GameState.equipaggiato_in(id_scelto, slot_aperto, indice_aperto)
	if attuale != "":
		GameState.togli_oggetto_equipaggiato(attuale)
	chiudi_la_scelta()


func chiudi_la_scelta(appena_messo := "") -> void:
	slot_aperto = ""
	# il carosello va dove l'oggetto e' finito davvero: aperto il terzo
	# accessorio con uno solo addosso, il nuovo diventa il secondo, e restare
	# sul terzo vuoto direbbe che non e' successo niente
	var slot := slot_elenco()
	for i in slot.size():
		if appena_messo != "" and String(slot[i]["oggetto"]) == appena_messo:
			slot_centro = i
	ridisegna()
	caselle[1].grab_focus()


func entra() -> void:
	Tavola.entra(barra, 0.0, Vector2(0, -12))
	Tavola.entra(sinistra, 0.03, Vector2(-24, 0))
	Tavola.entra(destra, 0.06, Vector2(24, 0))
	Tavola.entra(carosello, 0.1, Vector2(0, 24))


# --- i pezzi disegnati ---------------------------------------------------------

class Fondo extends Control:
	# nero con la trama a puntini, e la fascia cremisi dietro al personaggio:
	# pende come tutte le fasce del gioco, con la striscia bianca accanto
	const BANDA := [Vector2(760, 62), Vector2(1025, 62), Vector2(750, 720), Vector2(485, 720)]

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Stile.colore("sfondo"))
		Sagome.puntinato(self, Rect2(Vector2.ZERO, size), 24.0, Color(Stile.colore("testo"), 0.07))
		var striscia := PackedVector2Array()
		for p in [BANDA[0], BANDA[0] + Vector2(-5, 0), BANDA[3] + Vector2(-5, 0), BANDA[3]]:
			striscia.append(p - Vector2(14, 0))
		draw_colored_polygon(striscia, Stile.colore("bordo_acceso"))
		draw_colored_polygon(PackedVector2Array(BANDA), Stile.colore("accento"))
		draw_line(Vector2(0, 58), Vector2(Tavola.LARGO, 58), Color(Stile.colore("testo"), 0.12), 1.0)
		draw_line(Vector2(40, 96), Vector2(493, 96), Color(Stile.colore("testo"), 0.25), 2.0)
		draw_rect(Rect2(40, 92, 10, 4), Stile.colore("accento"))
		draw_rect(Rect2(483, 92, 10, 4), Stile.colore("accento"))
		draw_rect(Rect2(49, 247, 4, 20), Stile.colore("accento"))


class Emblema extends Control:
	var id_classe := ""

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var disegno := Corredo.disegno(id_classe, "emblema")
		if disegno != null:
			Sagome.disegna_dentro(self, disegno, Rect2(Vector2.ZERO, size))
			return
		var centro := size * 0.5
		Sagome.emblema(self, centro + Vector2(4, 4), size.y, Stile.colore("accento").darkened(0.5), Stile.colore("sfondo"))
		Sagome.emblema(self, centro, size.y, Stile.colore("testo"), Stile.colore("accento"))


class Barra extends Control:
	var quota := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Stile.colore("barra_vuota"))
		draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * quota, size.y)), Stile.colore("accento"))
