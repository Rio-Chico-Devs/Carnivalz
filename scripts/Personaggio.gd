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
# da ovunque - mappa, stanza, Vuoto - senza cambiare scena.

const STATISTICHE := [
	["hp", "Punti vita"],
	["attacco", "Attacco"],
	["difesa", "Difesa"],
	["velocita", "Velocità"],
	["aura", "Aura"],
]
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
var testo_dettaglio: RichTextLabel
var scorri: ScrollContainer
var elenco: VBoxContainer
var togli: TastoObliquo
var chiudi_scelta: TastoObliquo


func apri(indietro: Callable, diario: Callable) -> void:
	su_indietro = indietro
	su_diario = diario
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP     # il foglio copre: sotto non si clicca niente
	costruisci_tavola()
	id_scelto = GameState.party[0] if not GameState.party.is_empty() else GameState.id_protagonista
	ridisegna()
	entra()
	if not caselle.is_empty() and caselle[1].visible:
		Tavola.fuoco.call_deferred(caselle[1])


func _unhandled_input(evento: InputEvent) -> void:
	# ESC mentre scegli cosa mettere chiude la scelta, non la scheda: prima si
	# torna indietro di un passo, poi di una schermata
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
	Tavola.metti(statistiche, Rect2(45, 272, 440, StatisticheScheda.MARGINE * 2.0 + StatisticheScheda.PASSO * STATISTICHE.size()))


func costruisci_carosello() -> void:
	for i in 3:
		var casella := SlotScheda.new()
		carosello.add_child(casella)
		Tavola.metti(casella, CASELLE[i])
		casella.presa.connect(_su_casella)
		casella.gira.connect(gira)
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
		carte.append(carta)
	quante_carte = scritta(destra, Rect2(1002, 420, 249, 16), 12, Stile.colore("testo_smorzato"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_RIGHT)
	titolo_dettaglio = scritta(destra, Rect2(DETTAGLIO.position, Vector2(DETTAGLIO.size.x, 30)), 22, Stile.colore("testo"), Caratteri.titolo())
	testo_dettaglio = RichTextLabel.new()
	testo_dettaglio.bbcode_enabled = true
	testo_dettaglio.scroll_active = false
	testo_dettaglio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	testo_dettaglio.add_theme_font_override("normal_font", Caratteri.tondo(600))
	testo_dettaglio.add_theme_font_override("bold_font", Caratteri.tondo(900))
	testo_dettaglio.add_theme_font_size_override("normal_font_size", 14)
	testo_dettaglio.add_theme_font_size_override("bold_font_size", 14)
	testo_dettaglio.add_theme_color_override("default_color", Stile.colore("testo_smorzato"))
	destra.add_child(testo_dettaglio)
	Tavola.metti(testo_dettaglio, Rect2(DETTAGLIO.position + Vector2(0, 34), DETTAGLIO.size - Vector2(0, 34)))
	scorri = ScrollContainer.new()
	scorri.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
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
	var dove := squadra.find(id_scelto)
	if dove >= 0:
		inizio_carte = clampi(inizio_carte, maxi(dove - QUANTE_CARTE + 1, 0), dove)
	for i in QUANTE_CARTE:
		var indice := inizio_carte + i
		var id := String(squadra[indice]) if indice < squadra.size() else ""
		carte[i].carica(id, id == id_scelto)
	quante_carte.text = "%d–%d DI %d" % [inizio_carte + 1, mini(inizio_carte + QUANTE_CARTE, squadra.size()),
			squadra.size()] if squadra.size() > QUANTE_CARTE else ""


func disegna_identita() -> void:
	figura.mostra(id_scelto)
	emblema.id_classe = id_scelto
	emblema.queue_redraw()
	nome.text = nome_di(id_scelto).to_upper()
	Tavola.stringi(nome, 44, 26)
	livello.text = "%d" % GameState.livello_di(id_scelto)
	var dati_classe: Dictionary = GameState.classi.get(id_scelto, {})
	classe.text = String(dati_classe.get("classe", dati_classe.get("nome", ""))).to_upper()
	var id_psiche := String(GameState.personaggi.get(id_scelto, dati_classe).get("psiche", dati_classe.get("psiche", "")))
	psiche.text = "PSICHE · %s" % String(GameState.psichi.get(id_psiche, {}).get("nome", id_psiche)).to_upper() if id_psiche != "" else ""
	legame.text = "LEGAME DELLA SQUADRA %d" % GameState.legame
	barra_legame.quota = clampf(float(GameState.legame) / 100.0, 0.0, 1.0)
	barra_legame.queue_redraw()


func disegna_statistiche() -> void:
	var righe: Array[Dictionary] = []
	for voce in STATISTICHE:
		var chiave := String(voce[0])
		righe.append({"chiave": chiave, "nome": String(voce[1]),
				"base": statistica_base(id_scelto, chiave), "bonus": bonus_di(id_scelto, chiave)})
	statistiche.imposta(righe)


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
	titolo_dettaglio.text = nome_oggetto(id_oggetto).to_upper() if id_oggetto != "" else String(d.get("etichetta", "PROTEZIONI"))
	testo_dettaglio.text = testo_del_dettaglio(d)


func testo_del_dettaglio(d: Dictionary) -> String:
	var righe: Array[String] = []
	var bianco := Stile.colore("testo").to_html(false)
	var id_oggetto := String(d.get("oggetto", ""))
	if d.is_empty():
		righe.append("Le cose si affidano a chi resta.")
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
	for protezione in elenco_protezioni():
		righe.append("[color=#%s]· %s[/color]" % [Stile.colore("accento").to_html(false), protezione])
	return "\n".join(righe)


func riempi_scelta() -> void:
	# La regola che conta: ogni candidato mostra la DIFFERENZA rispetto a quello
	# che porti adesso in quello slot, non il suo valore assoluto
	var attuale := GameState.equipaggiato_in(id_scelto, slot_aperto, indice_aperto)
	togli.visible = attuale != ""
	var candidati := oggetti_per_slot(slot_aperto)
	if candidati.is_empty():
		var niente := Tavola.scritta("Non hai niente da mettere qui.", 14, Stile.colore("testo_smorzato"), Caratteri.tondo(700))
		elenco.add_child(niente)
	var prima: VoceCandidato = null
	for id_oggetto in candidati:
		var scarti := scarti_di(id_oggetto, attuale)
		var voce := VoceCandidato.nuova(id_oggetto, nome_oggetto(id_oggetto), nota_di(id_oggetto),
				differenza_testo(id_oggetto, attuale), verso_di(scarti))
		voce.sopra.connect(func(_v: VoceCandidato) -> void: statistiche.mostra_anteprima(scarti))
		voce.presa.connect(func(v: VoceCandidato) -> void: metti(v.id_oggetto, attuale))
		elenco.add_child(voce)
		if prima == null:
			prima = voce
	if prima != null:
		Tavola.fuoco.call_deferred(prima)


func nota_di(id_oggetto: String) -> String:
	var portatore := GameState.portatore_di(id_oggetto)
	if portatore == id_scelto:
		# le armi non escono dallo zaino quando le impugni: restano li', segnate
		return "in uso"
	if portatore != "":
		return "addosso a %s" % nome_di(portatore)
	return ""


# --- i gesti ----------------------------------------------------------------------

func cambia_compagno(id: String) -> void:
	if id == "" or id == id_scelto:
		return
	id_scelto = id
	slot_aperto = ""
	slot_centro = 0
	ridisegna()


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
		return
	slot_centro = posmod(slot_centro + verso, slot.size())
	slot_aperto = ""
	ridisegna()
	caselle[1].grab_focus()
	if not Movimento.ridotto():
		carosello.position.x = 36.0 * float(verso)
		Movimento.verso(carosello.create_tween(), carosello, "position:x", 0.0, "entrata", Movimento.durata("voce"))


func metti(id_oggetto: String, attuale: String) -> void:
	if attuale != "":
		GameState.togli_oggetto_equipaggiato(attuale)
	GameState.equipaggia(id_scelto, slot_aperto, id_oggetto)
	chiudi_la_scelta()


func togli_attuale() -> void:
	var attuale := GameState.equipaggiato_in(id_scelto, slot_aperto, indice_aperto)
	if attuale != "":
		GameState.togli_oggetto_equipaggiato(attuale)
	chiudi_la_scelta()


func chiudi_la_scelta() -> void:
	slot_aperto = ""
	ridisegna()
	caselle[1].grab_focus()


func entra() -> void:
	Tavola.entra(barra, 0.0, Vector2(0, -12))
	Tavola.entra(sinistra, 0.03, Vector2(-24, 0))
	Tavola.entra(destra, 0.06, Vector2(24, 0))
	Tavola.entra(carosello, 0.1, Vector2(0, 24))


# --- conti ------------------------------------------------------------------------

func statistica_base(id_classe: String, chiave: String) -> int:
	# il protagonista cresce con quello che fa (crescita.json); i compagni hanno
	# le loro statistiche scritte nei dati
	if chiave == "aura":
		return GameState.aura_massima(id_classe) - GameState.bonus_equipaggiamento(id_classe, "aura_max")
	if id_classe == GameState.id_protagonista:
		return GameState.stat_di(chiave)
	var dati: Dictionary = GameState.personaggi.get(id_classe, {})
	return int(dati.get(chiave, 0))


func bonus_di(id_classe: String, chiave: String) -> int:
	return GameState.bonus_equipaggiamento(id_classe, chiave_interna(chiave))


static func chiave_interna(chiave: String) -> String:
	if chiave == "hp":
		return "hp_max"
	return "aura_max" if chiave == "aura" else chiave


func scarti_di(id_candidato: String, id_attuale: String) -> Dictionary:
	# Il conto e' PURO: si sottrae quello che dava il vecchio e si somma quello
	# che da' il nuovo, senza mettere niente addosso a nessuno. La prima
	# versione equipaggiava davvero e poi rimetteva a posto - e non lo rimetteva
	# a posto: bastava SCORRERE l'elenco per spogliare un compagno. Le prove
	# l'hanno preso al primo giro (prova_scheda_personaggio).
	var scarti := {}
	for voce in STATISTICHE:
		var chiave := String(voce[0])
		var scarto := GameState.bonus_oggetto(id_candidato, chiave_interna(chiave)) \
				- GameState.bonus_oggetto(id_attuale, chiave_interna(chiave))
		if scarto != 0:
			scarti[chiave] = scarto
	return scarti


static func verso_di(scarti: Dictionary) -> int:
	var su := false
	var giu := false
	for scarto in scarti.values():
		su = su or int(scarto) > 0
		giu = giu or int(scarto) < 0
	return 0 if su == giu else (1 if su else -1)


func differenza_testo(id_candidato: String, id_attuale: String) -> String:
	var scarti := scarti_di(id_candidato, id_attuale)
	var pezzi: Array[String] = []
	for voce in STATISTICHE:
		if scarti.has(String(voce[0])):
			pezzi.append("%s %+d" % [String(voce[1]).to_lower(), int(scarti[String(voce[0])])])
	if pezzi.is_empty():
		return "nessun cambiamento nelle statistiche"
	return ", ".join(pezzi)


func oggetti_per_slot(slot: String) -> Array[String]:
	var risultato: Array[String] = []
	var visti := {}
	for id_oggetto in GameState.magazzino_per_slot(slot):
		var chiave := String(id_oggetto)
		if visti.has(chiave):
			continue
		visti[chiave] = true
		var tipo := String(GameState.dati_oggetto(chiave).get("tipo", ""))
		var va_bene := tipo == "consumabile" if slot == "ultima_risorsa" \
				else (tipo == "accessorio" if slot == "accessori" else tipo == slot)
		if va_bene:
			risultato.append(chiave)
	return risultato


func elenco_protezioni() -> Array[String]:
	# le protezioni non sono numeri e sparirebbero dalla tabella: si dicono a parole
	var risultato: Array[String] = []
	var slots := GameState.slot_di(id_scelto)
	var addosso: Array[String] = []
	for slot in ["arma", "stigma", "ultima_risorsa"]:
		if String(slots.get(slot, "")) != "":
			addosso.append(String(slots[slot]))
	for id_oggetto in slots.get("accessori", []):
		addosso.append(String(id_oggetto))
	for id_oggetto in addosso:
		var effetto: Dictionary = GameState.dati_oggetto(id_oggetto).get("effetto_equipaggiato", {})
		match String(effetto.get("tipo", "")):
			"scudo_primo_stato":
				risultato.append("%s respinge il primo stato che subisci" % nome_oggetto(id_oggetto))
			"resurrezione_dimezzata":
				risultato.append("%s ti rimette in piedi una volta sola" % nome_oggetto(id_oggetto))
	var maledizione := GameState.bonus_equipaggiamento(id_scelto, "resistenza_maledizione")
	if maledizione > 0:
		risultato.append("il conto della maledizione parte da %d rintocchi più in alto" % maledizione)
	return risultato


# --- utilità -----------------------------------------------------------------

func nome_di(id_classe: String) -> String:
	return String(GameState.personaggi.get(id_classe, {}).get("nome",
			GameState.classi.get(id_classe, {}).get("nome", id_classe)))


func nome_oggetto(id_oggetto: String) -> String:
	return String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto))


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
		var disegno := Disegni.texture("res://art/personaggi/%s/emblema.png" % id_classe)
		if disegno != null:
			draw_texture_rect(disegno, Rect2(Vector2.ZERO, size), false)
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
