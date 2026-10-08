class_name SchedaZaino
extends Control

# LO ZAINO: una lista per scomparto, con l'immagine di ogni oggetto, e quello
# che scegli in grande. Bru: «siccome avremo un'immagine per ogni oggetto ci
# deve essere una lista». Cosa fanno i giochi migliori e cosa ne abbiamo preso
# sta in docs/zaino.md; qui si disegna e si risponde, i conti (cosa c'e', in
# che ordine, cos'e' nuovo) stanno in ElencoZaino.gd.
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
var mostra: Mostra
var riquadri: Riquadri
var segni: SegniNuovi
var binario: Binario
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
	tavola.add_child(Fondo.new())
	mostra = Mostra.new()
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
	costruisci_linguette(24.0 + indietro.misura_voluta().x, minf(titolo.position.x - 12.0, FINE_LINGUETTE))
	segni = SegniNuovi.new()
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
	capienza = scritta(elenco, Rect2(48, 92, 330, 24), 16, Stile.colore("testo"), Caratteri.titolo())
	binario = Binario.new()
	elenco.add_child(binario)
	Tavola.metti(binario, Rect2(0, 0, Tavola.LARGO, Tavola.ALTO))
	ordina = TastoObliquo.nuovo("", "spoglio", 14)
	ordina.scelto.connect(cambia_ordine)
	elenco.add_child(ordina)
	scrivi_ordine()
	lista = Control.new()
	lista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elenco.add_child(lista)
	Tavola.metti(lista, Rect2(0, 0, Tavola.LARGO, Tavola.ALTO))
	for i in VISIBILI:
		var riga := RigaZaino.new()
		lista.add_child(riga)
		Tavola.metti(riga, Rect2(PRIMA_RIGA + Vector2(0, PASSO_RIGA * i), Vector2(LARGO_RIGA, RigaZaino.ALTO)))
		riga.presa.connect(func(_r: RigaZaino) -> void: seleziona(inizio + i, true))
		riga.focus_entered.connect(func() -> void: seleziona(inizio + i, false))
		riga.sposta.connect(sposta)
		riga.scomparto.connect(cambia_scomparto)
		righe.append(riga)
	vuoto = scritta(elenco, Rect2(48, 150, 560, 60), 16, Stile.colore("testo_smorzato"), Caratteri.tondo(700))
	a_capo(vuoto, 2)
	posizione = scritta(elenco, Rect2(48, 682, 580, 18), 12, Stile.colore("testo_smorzato"), Caratteri.tondo(900))


func costruisci_dettaglio() -> void:
	riquadri = Riquadri.new()
	dettaglio.add_child(riquadri)
	tipo = scritta(dettaglio, Rect2(DETTAGLIO_X, 84, DETTAGLIO_LARGO, 18), 13, Stile.colore("accento"), Caratteri.tondo(900))
	nome = scritta(dettaglio, Rect2(DETTAGLIO_X, 106, DETTAGLIO_LARGO, 68), 26, Stile.colore("testo"), Caratteri.titolo())
	a_capo(nome, 2)
	for i in 3:
		var x := DETTAGLIO_X + PASSO_RIQUADRO * i
		valori.append(scritta(dettaglio, Rect2(x, Y_RIQUADRI + 8, RIQUADRO.x, 44), 24, Stile.colore("testo"),
				Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER))
		var sotto := scritta(dettaglio, Rect2(x - 4, Y_RIQUADRI + RIQUADRO.y + 4, RIQUADRO.x + 8, 30), 11,
				Stile.colore("testo_smorzato"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER)
		a_capo(sotto, 2)
		etichette.append(sotto)
	descrizione = TestoCheScorre.nuovo(14, Stile.colore("testo_smorzato"), Stile.colore("sfondo"))
	dettaglio.add_child(descrizione)
	portatore = scritta(dettaglio, IN_USO, 17, Stile.colore("box_testo"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER)


# --- cosa si vede ---------------------------------------------------------------

func apri_scomparto(chiave: String) -> void:
	ElencoZaino.aperto = chiave
	fila = ElencoZaino.voci(chiave)
	scelta = 0
	inizio = 0
	for linguetta in linguette:
		linguetta.stile = "nero" if String(linguetta.get_meta("scomparto")) == chiave else "inchiostro"
		linguetta.queue_redraw()
	mostra_scelta()


func indice_aperto() -> int:
	for i in ElencoZaino.SCOMPARTI.size():
		if ElencoZaino.SCOMPARTI[i][0] == ElencoZaino.aperto:
			return i
	return 0


func mostra_scelta() -> void:
	for i in VISIBILI:
		var indice := inizio + i
		var voce: Dictionary = fila[indice] if indice < fila.size() else {}
		righe[i].carica(voce, indice == scelta, nuovi.has(String(voce.get("oggetto", ""))))
	var voce_scelta: Dictionary = fila[scelta] if scelta < fila.size() else {}
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
	binario.finestra = Vector2(float(inizio), float(mini(inizio + VISIBILI, fila.size())))
	binario.quante = fila.size()
	binario.queue_redraw()
	# ordinare una riga sola non vuol dire niente: il tasto c'e' quando serve
	ordina.visible = fila.size() > 1
	vuoto.visible = fila.is_empty()
	vuoto.text = "Qui non c'è niente." if fila.is_empty() else ""
	posizione.text = "%d DI %d   ·   ORDINATI PER %s" % [scelta + 1, fila.size(),
			String(ElencoZaino.NOMI_ORDINI[ElencoZaino.ordine])] if not fila.is_empty() else ""


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
	var sotto := Y_RIQUADRI + RIQUADRO.y + 46.0 if not pezzi.is_empty() else Y_RIQUADRI
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
	if not fila.is_empty():
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
	var prima_di := inizio
	inizio = clampi(inizio, maxi(nuova - VISIBILI + 1, 0), nuova)
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
	var arrivo := scelta + verso
	if arrivo < 0:
		# su dalla prima riga: il tasto ORDINA, e sopra le linguette
		var sopra: TastoObliquo = ordina if ordina.visible else linguette[indice_aperto()]
		sopra.grab_focus()
		return
	if arrivo >= fila.size():
		Movimento.suona("rifiuto")   # in fondo alla lista: dice di no
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
	var id_oggetto := String(fila[scelta].get("oggetto", "")) if scelta < fila.size() else ""
	ElencoZaino.gira_ordine()
	scrivi_ordine()
	fila = ElencoZaino.voci(ElencoZaino.aperto)
	scelta = 0
	for i in fila.size():
		if String(fila[i]["oggetto"]) == id_oggetto:
			scelta = i
	# la riga scelta a meta' della finestra, dove l'occhio la ritrova
	inizio = clampi(scelta - floori(VISIBILI * 0.5), 0, maxi(fila.size() - VISIBILI, 0))
	mostra_scelta()
	entra_lista()


func scrivi_ordine() -> void:
	ordina.text = "ORDINA · %s" % String(ElencoZaino.NOMI_ORDINI[ElencoZaino.ordine])
	ordina.adatta_misura()
	ordina.position = Vector2(SCHERMO_ELENCO.end.x - 30.0 - ordina.misura_voluta().x, 90.0)
	ordina.queue_redraw()


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


# --- i pezzi disegnati ---------------------------------------------------------

class Fondo extends Control:
	# l'arancio del manifesto con la sua trama, la fascia nera storta con la
	# striscia chiara accanto, e i due schermi: la lista e la scheda
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)
		Manifesto.trama_dietro(self).show_behind_parent = true

	func _draw() -> void:
		var striscia := PackedVector2Array()
		for p in [BANDA[0], BANDA[0] + Vector2(-5, 0), BANDA[3] + Vector2(-5, 0), BANDA[3]]:
			striscia.append(p - Vector2(14, 0))
		Manifesto.poligono(self, striscia, Stile.colore("bordo_acceso"))
		Manifesto.poligono(self, PackedVector2Array(BANDA), Stile.colore("bordo"))
		for schermo in [SCHERMO_ELENCO, SCHERMO_DETTAGLIO]:
			Manifesto.disegna_schermo(self, schermo)


class Mostra extends Control:
	# L'OGGETTO SCELTO, GRANDE, sulla fascia nera: il disegno di Bru quando
	# c'e', se no la sagoma del suo tipo. Sopra, quanti ne hai. Cambiando riga
	# arriva scivolando di poco, come in vetrina: e' l'unica cosa che si muove
	const SCIVOLO := 24.0
	var id_oggetto := ""
	var sagoma_vuota := ""         # lo scomparto vuoto: la sua sagoma, spenta
	var arrivo := 1.0
	var orologio := -1.0
	var quanti: Label
	var quanti_cosa: Label

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)
		quanti = Tavola.scritta("", 60, Stile.colore("testo"), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER)
		add_child(quanti)
		Tavola.metti(quanti, Rect2(800, 80, 180, 76))
		Tavola.ombra(quanti, Color(Stile.colore("box_testo"), 0.9), Vector2(4, 4))
		quanti_cosa = Tavola.scritta("", 13, Stile.colore("testo"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER)
		add_child(quanti_cosa)
		Tavola.metti(quanti_cosa, Rect2(800, 156, 180, 20))

	func mostra(voce: Dictionary, sagoma_dello_scomparto: String) -> void:
		var nuovo := String(voce.get("oggetto", ""))
		var cambia := nuovo != id_oggetto
		id_oggetto = nuovo
		sagoma_vuota = sagoma_dello_scomparto
		quanti.text = "×%d" % int(voce.get("quanti", 0)) if nuovo != "" else ""
		quanti_cosa.text = ("NEL BOTTINO" if Merce.tipo_oggetto(nuovo) == "pila" else "NELLO ZAINO") if nuovo != "" else ""
		if cambia and nuovo != "":
			arrivo = 0.0
			orologio = 0.0
			set_process(true)
		queue_redraw()

	func _process(delta: float) -> void:
		if orologio < 0.0:
			set_process(false)
			return
		orologio += delta
		var durata := Movimento.durata("colore" if Movimento.ridotto() else "entrata")
		arrivo = Movimento.curva("entrata", clampf(orologio / durata, 0.0, 1.0))
		if orologio >= durata:
			orologio = -1.0
			arrivo = 1.0
		queue_redraw()

	func _draw() -> void:
		if id_oggetto == "":
			Sagome.icona_oggetto(self, IMMAGINE.get_center(), 210.0, sagoma_vuota,
					Stile.colore("pannello_chiaro"), Stile.colore("bordo"))
			return
		var spostato := Vector2(0.0 if Movimento.ridotto() else SCIVOLO * (1.0 - arrivo), 0.0)
		var r := Rect2(IMMAGINE.position + spostato, IMMAGINE.size)
		var disegno := Sagome.immagine_oggetto(id_oggetto)
		if disegno != null:
			Sagome.disegna_dentro(self, disegno, r, Color(1, 1, 1, arrivo))
			return
		# la sagoma ha la sua sfoglia nera sotto: sulla fascia e sull'arancio
		# si legge lo stesso
		var forma := Sagome.tipo_icona(id_oggetto)
		var nero := Color(Stile.colore("box_testo"), arrivo)
		Sagome.icona_oggetto(self, r.get_center() + Vector2(8, 8), 210.0, forma, nero, nero)
		Sagome.icona_oggetto(self, r.get_center(), 210.0, forma, Color(Stile.colore("testo"), arrivo), nero)


class Riquadri extends Control:
	# i riquadri chiari sotto i numeri di cosa fa, e la fascia arancio di chi
	# lo sta usando
	var quanti := 0
	var in_uso := false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)

	func _draw() -> void:
		for i in quanti:
			var r := Rect2(Vector2(DETTAGLIO_X + PASSO_RIQUADRO * i, Y_RIQUADRI), RIQUADRO)
			draw_rect(r, Stile.colore("pannello_chiaro"))
			draw_rect(Rect2(r.position.x, r.end.y - 3.0, r.size.x, 3.0), Stile.colore("bordo_acceso"))
		if in_uso:
			var storto := IN_USO.size.y * Manifesto.INCLINA
			Manifesto.poligono(self, PackedVector2Array([IN_USO.position + Vector2(storto, 0),
					Vector2(IN_USO.end.x, IN_USO.position.y), IN_USO.end - Vector2(storto, 0),
					Vector2(IN_USO.position.x, IN_USO.end.y)]), Stile.colore("accento"))


class Binario extends Control:
	# QUANTO E' PIENO LO SCOMPARTO, sotto il conto dei posti: una barra, perche'
	# «17/20» si legge, ma una barra quasi piena si vede. E sul bordo destro
	# della lista, se le righe non ci stanno tutte, dove sei nella lista
	var pieno := -1.0
	var finestra := Vector2.ZERO
	var quante := 0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if pieno >= 0.0:
			var r := Rect2(48, 120, 300, 5)
			draw_rect(r, Stile.colore("barra_vuota"))
			draw_rect(Rect2(r.position, Vector2(r.size.x * pieno, r.size.y)),
					Stile.colore("pericolo") if pieno >= 1.0 else Stile.colore("accento"))
		if quante <= VISIBILI:
			return
		var alto := PASSO_RIGA * VISIBILI - 4.0
		var x := PRIMA_RIGA.x + LARGO_RIGA + 8.0
		draw_rect(Rect2(x, PRIMA_RIGA.y, 3, alto), Stile.colore("pannello_chiaro"))
		var da := alto * finestra.x / float(quante)
		var a := alto * finestra.y / float(quante)
		draw_rect(Rect2(x - 1.0, PRIMA_RIGA.y + da, 5, a - da), Stile.colore("bordo_acceso"))


class SegniNuovi extends Control:
	# UN ROMBO SULLA LINGUETTA di uno scomparto che ha dentro qualcosa di mai
	# guardato: la stella di Diablo 3 sullo scomparto. Si spegne quando li hai
	# guardati tutti. Chiaro con la sfoglia nera, come il segno NUOVO delle
	# righe: arancio sull'arancio della pagina non si vedeva
	var scheda: SchedaZaino

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, 60)

	func _draw() -> void:
		if scheda == null:
			return
		for linguetta in scheda.linguette:
			if not ElencoZaino.ha_nuovi(String(linguetta.get_meta("scomparto"))):
				continue
			var c := linguetta.position + Vector2(linguetta.size.x - 2.0, 4.0)
			Manifesto.poligono(self, Sagome.rombo(c + Vector2(2, 2), 7.0), Stile.colore("bordo"))
			Manifesto.poligono(self, Sagome.rombo(c, 7.0), Stile.colore("bordo_acceso"))
