class_name SchedaZaino
extends Control

# LO ZAINO: una lista per scomparto, con l'immagine di ogni oggetto, e quello
# che scegli in grande. Bru: «siccome avremo un'immagine per ogni oggetto ci
# deve essere una lista». Cosa fanno i giochi migliori e cosa ne abbiamo preso
# sta in docs/zaino.md; qui si disegna e si risponde, i conti (cosa c'e', in
# che ordine, cos'e' nuovo) stanno in ElencoZaino.gd, i pezzi disegnati (il
# fondo, l'oggetto grande, i riquadri) in PezziZaino.gd.
#
# COME E' FATTO. E' della stessa famiglia della scheda della squadra
# (Personaggio.gd), perche' si apre dallo stesso menu: l'arancio del manifesto,
# due schermi di cabinato, la fascia nera storta in mezzo.
#
#   in alto        Indietro, e gli scomparti in linguette col loro conto
#                  («CONSUMABILI 3/20»); un rombo arancio su quelle con dentro
#                  qualcosa che non hai ancora guardato
#   a sinistra     la lista: quanto e' pieno lo scomparto, il tasto ORDINA, e
#                  una riga per tipo di oggetto (RigaZaino.gd)
#   al centro      sulla fascia nera, l'oggetto scelto in grande, e quanti
#   a destra       che cos'e', cosa fa in numeri (i riquadri della vetrina del
#                  negozio), la descrizione intera, e chi lo sta usando
#
# QUI SI GUARDA E BASTA. Si equipaggia dalla scheda della squadra, si compra e
# si vende al negozio: una cosa per schermata.
#
# LA TASTIERA: su e giu' scorrono la lista, destra e sinistra cambiano
# scomparto; su dalla prima riga si arriva a ORDINA, e da li' alle linguette.
# ESC torna al menu (lo fa la Pausa). Col mouse: clic sulle righe e sulle
# linguette, rotella sulla lista.

const SCHERMO_ELENCO := Rect2(18, 70, 640, 648)
const SCHERMO_DETTAGLIO := Rect2(986, 62, 282, 656)
const BANDA := [Vector2(800, 62), Vector2(1065, 62), Vector2(790, 720), Vector2(525, 720)]
const PRIMA_RIGA := Vector2(44, 142)
const LARGO_RIGA := 580.0
const PASSO_RIGA := 60.0
const VISIBILI := 9
const IMMAGINE := Rect2(668, 236, 280, 290)
const DETTAGLIO_X := 1004.0
const DETTAGLIO_LARGO := 246.0
const RIQUADRO := Vector2(74, 72)
const PASSO_RIQUADRO := 86.0
const Y_RIQUADRI := 186.0
const IN_USO := Rect2(1004, 636, 246, 42)
const FINE_LINGUETTE := 1040.0

var su_indietro := Callable()
var tavola: Tavola
var barra: Control
var elenco: Control
var lista: Control
var dettaglio: Control
var mostra: PezziZaino.Mostra
var riquadri: PezziZaino.Riquadri
var segni: PezziZaino.SegniNuovi
var binario: PezziZaino.Binario
var indietro: TastoObliquo
var ordina: TastoObliquo
var linguette: Array[TastoObliquo] = []
var righe: Array[RigaZaino] = []
var capienza: Label
var posizione: Label
var vuoto: Label
var tipo: Label
var nome: Label
var valori: Array[Label] = []
var etichette: Array[Label] = []
var descrizione: TestoCheScorre
var portatore: Label

var proposta: TastoObliquo     # PROVVISORIO: gira fra le proposte (ProposteZaino)
# dove sta ogni cosa: dipende dalla proposta (ProposteZaino.misure)
var m: Dictionary = {}

var fila: Array[Dictionary] = []
var scelta := 0
var inizio := 0
# chi era nuovo quando lo zaino si e' aperto: il segno resta sulla riga finche'
# resti qui, anche dopo averla guardata. Il rombo sulla linguetta invece si
# spegne appena li hai guardati tutti
var nuovi := {}


func apri(indietro_a: Callable) -> void:
	su_indietro = indietro_a
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP     # il foglio copre: sotto non si clicca niente
	m = ProposteZaino.misure(ProposteZaino.scelta)
	for scomparto in ElencoZaino.SCOMPARTI:
		for id_oggetto in ElencoZaino.pezzi(String(scomparto[0])):
			if ElencoZaino.e_nuovo(String(id_oggetto)):
				nuovi[String(id_oggetto)] = true
	costruisci_tavola()
	apri_scomparto(ElencoZaino.aperto)
	entra()
	Tavola.fuoco.call_deferred(dove_va_il_fuoco())


func dove_va_il_fuoco() -> Control:
	# sulla riga scelta; in uno scomparto vuoto sulla sua linguetta, che da
	# li' destra e sinistra continuano a girare gli scomparti
	if not fila.is_empty():
		return righe[scelta - inizio] as Control
	return linguette[indice_aperto()] as Control


# --- la tavola ------------------------------------------------------------------

func costruisci_tavola() -> void:
	tavola = Tavola.su(self)
	var fondo := PezziZaino.Fondo.new()
	fondo.m = m
	tavola.add_child(fondo)
	mostra = PezziZaino.Mostra.new()
	mostra.m = m
	tavola.add_child(mostra)
	elenco = gruppo()
	dettaglio = gruppo()
	barra = gruppo()
	costruisci_elenco()
	costruisci_dettaglio()
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


func a_capo(etichetta: Label, righe_al_massimo: int) -> void:
	etichetta.clip_text = false
	etichetta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etichetta.max_lines_visible = righe_al_massimo
	etichetta.vertical_alignment = VERTICAL_ALIGNMENT_TOP


func costruisci_barra() -> void:
	indietro = TastoObliquo.nuovo("INDIETRO", "nero", 20)
	indietro.scelto.connect(func() -> void:
		if su_indietro.is_valid():
			su_indietro.call())
	barra.add_child(indietro)
	indietro.position = Vector2(16, 10)
	var titolo := Cartiglio.nuovo("ZAINO", Stile.colore("bordo"), Stile.colore("testo"),
			Color(0, 0, 0, 0), Stile.dimensione("sezione"))
	barra.add_child(titolo)
	titolo.size = titolo.get_combined_minimum_size()
	titolo.position = Vector2(Tavola.LARGO - titolo.size.x - 18.0, 4.0)
	titolo.svela(0.05)
	# PROVVISORIO: le proposte da far scegliere a Bru, a sinistra del titolo
	proposta = TastoObliquo.nuovo(ProposteZaino.etichetta(), "chiaro", 12)
	# differita: il tasto sta dentro la tavola che si rifa', e liberarlo mentre
	# sta ancora dicendo «scelto» e' un errore (e un crash, prima o poi)
	proposta.scelto.connect(func() -> void: cambia_proposta.call_deferred())
	barra.add_child(proposta)
	proposta.position = Vector2(titolo.position.x - proposta.misura_voluta().x - 8.0, 16.0)
	costruisci_linguette(24.0 + indietro.misura_voluta().x, minf(proposta.position.x - 8.0, FINE_LINGUETTE))
	segni = PezziZaino.SegniNuovi.new()
	segni.scheda = self
	barra.add_child(segni)


func costruisci_linguette(da: float, fino: float) -> void:
	# UNA LINGUETTA PER SCOMPARTO, col suo conto: si vede quanto e' pieno ogni
	# scomparto senza aprirlo. Se i nomi non ci stanno si stringono tutte dello
	# stesso tanto, come le linguette dei negozi
	for corpo in range(17, 11, -1):
		for vecchia in linguette:
			vecchia.free()
		linguette.clear()
		var x := da
		for scomparto in ElencoZaino.SCOMPARTI:
			var chiave := String(scomparto[0])
			var linguetta := TastoObliquo.nuovo("%s %s" % [String(scomparto[1]).to_upper(), ElencoZaino.conto(chiave)],
					"inchiostro", corpo)
			linguetta.set_meta("scomparto", chiave)
			linguetta.scelto.connect(scegli_linguetta.bind(chiave))
			# dove sta il fuoco sta lo scomparto: destra e sinistra sulle
			# linguette girano gli scomparti anche quando la lista e' vuota
			linguetta.focus_entered.connect(scegli_linguetta.bind(chiave))
			barra.add_child(linguetta)
			linguetta.position = Vector2(x, 12.0)
			x += linguetta.misura_voluta().x + 6.0
			linguette.append(linguetta)
		if x <= fino:
			return


func costruisci_elenco() -> void:
	# sullo schermo si scrive chiaro, sull'arancio e sul foglio in nero
	var su_carta := bool(m["su_carta"])
	var chiaro := Stile.colore("box_testo") if su_carta else Stile.colore("testo")
	var smorzato := Color(Stile.colore("box_testo"), 0.75) if su_carta else Stile.colore("testo_smorzato")
	var area: Rect2 = m["elenco"]
	capienza = scritta(elenco, Rect2(48, 92, minf(330.0, area.size.x - 220.0), 24), 16, chiaro, Caratteri.titolo())
	binario = PezziZaino.Binario.new()
	binario.m = m
	elenco.add_child(binario)
	Tavola.metti(binario, Rect2(0, 0, Tavola.LARGO, Tavola.ALTO))
	ordina = TastoObliquo.nuovo("", "nero" if su_carta else "spoglio", 14)
	ordina.scelto.connect(cambia_ordine)
	elenco.add_child(ordina)
	scrivi_ordine()
	lista = Control.new()
	lista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elenco.add_child(lista)
	Tavola.metti(lista, Rect2(0, 0, Tavola.LARGO, Tavola.ALTO))
	var prima: Rect2 = m["riga"]
	for i in int(m["visibili"]):
		var riga := RigaZaino.new()
		riga.stile = ProposteZaino.scelta
		lista.add_child(riga)
		Tavola.metti(riga, Rect2(prima.position + Vector2(0, float(m["passo"]) * i), prima.size))
		riga.presa.connect(func(_r: RigaZaino) -> void: seleziona(inizio + i, true))
		riga.focus_entered.connect(func() -> void: seleziona(inizio + i, false))
		riga.sposta.connect(sposta)
		riga.scomparto.connect(cambia_scomparto)
		righe.append(riga)
	vuoto = scritta(elenco, Rect2(48, 150, area.size.x - 80.0, 60), 16, smorzato, Caratteri.tondo(700))
	a_capo(vuoto, 2)
	posizione = scritta(elenco, Rect2(48, 682, area.size.x - 60.0, 18), 12, smorzato, Caratteri.tondo(900))


func costruisci_dettaglio() -> void:
	riquadri = PezziZaino.Riquadri.new()
	riquadri.y = float(m["y_riquadri"])
	dettaglio.add_child(riquadri)
	tipo = scritta(dettaglio, Rect2(DETTAGLIO_X, 84, DETTAGLIO_LARGO, 18), 13, Stile.colore("accento"), Caratteri.tondo(900))
	nome = scritta(dettaglio, Rect2(DETTAGLIO_X, 106, DETTAGLIO_LARGO, 68), 26, Stile.colore("testo"), Caratteri.titolo())
	a_capo(nome, 2)
	# nella vetrina grande il nome sta gia' sulla fascia, in grande
	nome.visible = (m["nome_sulla_fascia"] as Rect2).size == Vector2.ZERO
	var y_riquadri := float(m["y_riquadri"])
	for i in 3:
		var x := DETTAGLIO_X + PASSO_RIQUADRO * i
		valori.append(scritta(dettaglio, Rect2(x, y_riquadri + 8, RIQUADRO.x, 44), 24, Stile.colore("testo"),
				Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER))
		var sotto := scritta(dettaglio, Rect2(x - 4, y_riquadri + RIQUADRO.y + 4, RIQUADRO.x + 8, 30), 11,
				Stile.colore("testo_smorzato"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER)
		a_capo(sotto, 2)
		etichette.append(sotto)
	descrizione = TestoCheScorre.nuovo(14, Stile.colore("testo_smorzato"), Stile.colore("sfondo"))
	dettaglio.add_child(descrizione)
	portatore = scritta(dettaglio, IN_USO, 17, Stile.colore("box_testo"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER)


# --- cosa si vede ---------------------------------------------------------------

func apri_scomparto(chiave: String) -> void:
	ElencoZaino.aperto = chiave
	fila = fila_di(chiave)
	scelta = selezionabile(0, 1)
	inizio = 0
	for linguetta in linguette:
		linguetta.stile = "nero" if String(linguetta.get_meta("scomparto")) == chiave else "inchiostro"
		linguetta.queue_redraw()
	mostra_scelta()


func fila_di(chiave: String) -> Array[Dictionary]:
	# le righe dello scomparto; nel taccuino, ordinate per tipo, coi titoli
	# delle sezioni in mezzo (ProposteZaino.con_i_gruppi)
	var righe_dello_scomparto := ElencoZaino.voci(chiave)
	if bool(m.get("gruppi", false)) and ElencoZaino.ordine == "tipo":
		return ProposteZaino.con_i_gruppi(righe_dello_scomparto)
	return righe_dello_scomparto


func selezionabile(da: int, verso: int) -> int:
	# la prima riga che si puo' scegliere da "da" in poi, nel verso dato: i
	# titoli delle sezioni si saltano. -1 se non ce n'e'
	var i := da
	while i >= 0 and i < fila.size() and fila[i].has("gruppo"):
		i += verso
	return i if i >= 0 and i < fila.size() else -1


func indice_aperto() -> int:
	for i in ElencoZaino.SCOMPARTI.size():
		if ElencoZaino.SCOMPARTI[i][0] == ElencoZaino.aperto:
			return i
	return 0


func mostra_scelta() -> void:
	for i in righe.size():
		var indice := inizio + i
		var voce: Dictionary = fila[indice] if indice < fila.size() else {}
		righe[i].carica(voce, indice == scelta, nuovi.has(String(voce.get("oggetto", ""))))
	var voce_scelta: Dictionary = fila[scelta] if scelta >= 0 and scelta < fila.size() else {}
	# GUARDATO VUOL DIRE SCELTO: il segno NUOVO se ne va quando la riga e' tua,
	# non quando apri lo zaino (docs/zaino.md)
	ElencoZaino.segna_visto(String(voce_scelta.get("oggetto", "")))
	disegna_elenco()
	disegna_dettaglio(voce_scelta)
	mostra.mostra(voce_scelta, ElencoZaino.sagoma(ElencoZaino.aperto))
	segni.queue_redraw()
	punta_i_vicini()


func disegna_elenco() -> void:
	var chiave := ElencoZaino.aperto
	var tetto := ElencoZaino.tetto(chiave)
	var quanti := ElencoZaino.pezzi(chiave).size()
	capienza.text = "%d / %d POSTI" % [quanti, tetto] if tetto >= 0 \
			else "%d %s" % [quanti, "PEZZI" if chiave == "bottino" else ("OGGETTO" if quanti == 1 else "OGGETTI")]
	binario.pieno = clampf(float(quanti) / float(tetto), 0.0, 1.0) if tetto > 0 else -1.0
	binario.finestra = Vector2(float(inizio), float(mini(inizio + righe.size(), fila.size())))
	binario.quante = fila.size()
	binario.queue_redraw()
	# ordinare una riga sola non vuol dire niente: il tasto c'e' quando serve
	ordina.visible = fila.size() > 1
	vuoto.visible = fila.is_empty()
	vuoto.text = "Qui non c'è niente." if fila.is_empty() else ""
	var oggetti := fila.filter(func(v: Dictionary) -> bool: return not v.has("gruppo"))
	posizione.text = "%d DI %d   ·   ORDINATI PER %s" % [oggetti.find(fila[scelta]) + 1, oggetti.size(),
			String(ElencoZaino.NOMI_ORDINI[ElencoZaino.ordine])] if scelta >= 0 and not fila.is_empty() else ""


func disegna_dettaglio(voce: Dictionary) -> void:
	var id_oggetto := String(voce.get("oggetto", ""))
	var dati := GameState.dati_oggetto(id_oggetto)
	var pezzi: Array[Dictionary] = []
	if id_oggetto != "":
		pezzi = Merce.pezzi_effetto(dati)
	for i in 3:
		valori[i].text = String(pezzi[i]["valore"]) if i < pezzi.size() else ""
		etichette[i].text = String(pezzi[i]["nome"]) if i < pezzi.size() else ""
		Tavola.stringi_a_capo(etichette[i], 11, 9)
	riquadri.quanti = pezzi.size()
	var chi := String(voce.get("in_uso", ""))
	riquadri.in_uso = chi != ""
	riquadri.queue_redraw()
	portatore.text = "IN USO · %s" % Corredo.nome_di(chi).to_upper() if chi != "" else ""
	Tavola.stringi(portatore, 17, 12)
	var y_riquadri := float(m["y_riquadri"])
	var sotto := y_riquadri + RIQUADRO.y + 46.0 if not pezzi.is_empty() else y_riquadri
	Tavola.metti(descrizione, Rect2(DETTAGLIO_X, sotto, DETTAGLIO_LARGO, IN_USO.position.y - 14.0 - sotto))
	if id_oggetto == "":
		# lo scomparto vuoto dice a cosa serve: e' l'unico momento in cui
		# serve saperlo, e il posto c'e'
		tipo.text = "SCOMPARTO"
		nome.text = ElencoZaino.nome_scomparto(ElencoZaino.aperto).to_upper()
		descrizione.scrivi(ElencoZaino.spiegazione(ElencoZaino.aperto))
	else:
		tipo.text = String(ElencoZaino.NOMI_TIPI.get(Merce.tipo_oggetto(id_oggetto), "")).to_upper()
		nome.text = Merce.nome_di(id_oggetto).to_upper()
		descrizione.scrivi(testo_della_descrizione(dati))
	Tavola.stringi_a_capo(nome, 26, 17)


func testo_della_descrizione(dati: Dictionary) -> String:
	var righe_testo: Array[String] = []
	var effetto := Merce.riassunto_effetto(dati, "")
	if effetto != "":
		righe_testo.append("[b][color=#%s]%s[/color][/b]" % [Stile.colore("testo").to_html(false),
				effetto.left(1).to_upper() + effetto.substr(1) + "."])
	righe_testo.append(String(dati.get("descrizione", "")))
	return "\n".join(righe_testo)


func punta_i_vicini() -> void:
	# DA FUORI DELLA LISTA SI TORNA ALLA RIGA SCELTA: giu' da una linguetta, da
	# Indietro o da ORDINA. La riga piu' vicina a occhio e' un'altra, e
	# arrivarci col fuoco la sceglieva - cambiando l'oggetto sotto il dito
	var giu: Control = linguette[indice_aperto()]
	if scelta >= 0 and not fila.is_empty():
		giu = righe[scelta - inizio]
	for sopra: Control in linguette + [indietro]:
		sopra.focus_neighbor_bottom = sopra.get_path_to(giu)
	ordina.focus_neighbor_bottom = ordina.get_path_to(giu)
	ordina.focus_neighbor_top = ordina.get_path_to(linguette[indice_aperto()])
	ordina.focus_neighbor_left = ordina.get_path_to(ordina)
	ordina.focus_neighbor_right = ordina.get_path_to(ordina)


# --- i gesti ----------------------------------------------------------------------

func seleziona(indice: int, col_fuoco: bool) -> void:
	if fila.is_empty():
		return
	var nuova := clampi(indice, 0, fila.size() - 1)
	if fila[nuova].has("gruppo"):
		return
	var prima_di := inizio
	inizio = clampi(inizio, maxi(nuova - righe.size() + 1, 0), nuova)
	# il titolo della sezione resta in vista sopra la sua prima riga
	if nuova > 0 and inizio == nuova and fila[nuova - 1].has("gruppo"):
		inizio -= 1
	var cambiata := nuova != scelta or inizio != prima_di
	scelta = nuova
	if cambiata:
		Movimento.suona("sfioro")
		mostra_scelta()
	if col_fuoco:
		righe[scelta - inizio].grab_focus()


func sposta(verso: int) -> void:
	if fila.is_empty():
		return
	var arrivo := selezionabile(scelta + verso, verso)
	if arrivo < 0 and verso > 0:
		Movimento.suona("rifiuto")   # in fondo alla lista: dice di no
		return
	if arrivo < 0:
		# su dalla prima riga: il tasto ORDINA, e sopra le linguette
		var sopra: TastoObliquo = ordina if ordina.visible else linguette[indice_aperto()]
		sopra.grab_focus()
		return
	seleziona(arrivo, true)


func cambia_scomparto(verso: int) -> void:
	var dove := indice_aperto() + verso
	if dove < 0 or dove >= ElencoZaino.SCOMPARTI.size():
		Movimento.suona("rifiuto")
		return
	Movimento.suona("sfioro")
	apri_scomparto(String(ElencoZaino.SCOMPARTI[dove][0]))
	entra_lista()
	dove_va_il_fuoco().grab_focus()


func scegli_linguetta(chiave: String) -> void:
	if chiave == ElencoZaino.aperto:
		return
	Movimento.suona("sfioro")
	apri_scomparto(chiave)
	entra_lista()


func cambia_ordine() -> void:
	# IL TASTO GIRA FRA GLI ORDINI E DICE QUALE STA USANDO (la proposta di
	# Amped-UX per Breath of the Wild). L'oggetto scelto resta scelto: cambia
	# il suo posto nella lista, non quello che stai guardando
	var id_oggetto := String(fila[scelta].get("oggetto", "")) if scelta >= 0 and scelta < fila.size() else ""
	ElencoZaino.gira_ordine()
	scrivi_ordine()
	fila = fila_di(ElencoZaino.aperto)
	scelta = selezionabile(0, 1)
	for i in fila.size():
		if String(fila[i].get("oggetto", "")) == id_oggetto:
			scelta = i
	# la riga scelta a meta' della finestra, dove l'occhio la ritrova
	inizio = clampi(scelta - floori(righe.size() * 0.5), 0, maxi(fila.size() - righe.size(), 0))
	mostra_scelta()
	entra_lista()


func scrivi_ordine() -> void:
	ordina.text = "ORDINA · %s" % String(ElencoZaino.NOMI_ORDINI[ElencoZaino.ordine])
	ordina.adatta_misura()
	ordina.position = Vector2((m["elenco"] as Rect2).end.x - 30.0 - ordina.misura_voluta().x, 90.0)
	ordina.queue_redraw()


func cambia_proposta() -> void:
	# PROVVISORIO: la stessa schermata disegnata con la proposta dopo. Si
	# rifa' da capo, sullo stesso scomparto e con lo stesso oggetto scelto
	ProposteZaino.gira()
	var id_oggetto := String(fila[scelta].get("oggetto", "")) if scelta >= 0 and scelta < fila.size() else ""
	tavola.free()
	linguette.clear()
	righe.clear()
	valori.clear()
	etichette.clear()
	m = ProposteZaino.misure(ProposteZaino.scelta)
	costruisci_tavola()
	apri_scomparto(ElencoZaino.aperto)
	for i in fila.size():
		if String(fila[i].get("oggetto", "")) == id_oggetto:
			seleziona(i, false)
	proposta.grab_focus()


# --- l'entrata -----------------------------------------------------------------

func entra() -> void:
	Tavola.entra(barra, 0.0, Vector2(0, -12))
	Tavola.entra(elenco, 0.03, Vector2(-24, 0))
	Tavola.entra(mostra, 0.05, Vector2(0, 24))
	Tavola.entra(dettaglio, 0.07, Vector2(24, 0))


func entra_lista() -> void:
	# cambiando scomparto o ordine entra solo la lista, dall'alto di poco: il
	# resto della schermata e' lo stesso, e ballare tutto a ogni freccia
	# sarebbe una schermata che si guarda invece di usarla
	Tavola.entra(lista, 0.0, Vector2(0, 10))
