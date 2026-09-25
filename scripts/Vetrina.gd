class_name Vetrina
extends Control

# LA FASCIA CREMISI DEL NEGOZIO: l'oggetto scelto, grande.
#
# Nello schema di Bru e' la fascia scura obliqua a destra (F) e il blocco
# accanto (G). Da noi la fascia e' cremisi, l'unico colore caldo di tutta la
# schermata, con la striscia bianca accanto come le quinte della pausa: dice
# "questo e' quello che stai guardando" senza bisogno di una cornice.
#
# Dentro, dall'alto: il prezzo grande, il disegno che sporge dalla fascia a
# sinistra, il nome, e tre riquadri con quello che fa in numeri. A destra,
# fuori dalla fascia, le tre risposte che servono per decidere: quanti Tazo
# ti restano (o ti mancano), quanti ne hai gia', e il tasto COMPRA - che se
# non si puo', dice perche' proprio sotto.
#
# Cambiando carta il disegno arriva scivolando da destra: e' l'unica cosa che
# si muove, il resto cambia e basta. Un negozio in cui tutto balla a ogni
# freccia e' un negozio che si guarda invece di usarlo.

const BANDA := [Vector2(980, 0), Vector2(1295, 0), Vector2(949, 720), Vector2(634, 720)]
const STACCO_STRISCIA := 14.0
const LARGO_STRISCIA := 5.0
const IMMAGINE := Rect2(815, 185, 215, 285)
const LATO_SAGOMA := 190.0
const RIQUADRO := Vector2(74, 72)
const PRIMO_RIQUADRO := Vector2(712, 560)
const PASSO_RIQUADRO := 80.0
const MINIATURA := Rect2(1060, 468, 86, 86)
const SCIVOLO := 28.0

var voce: Dictionary = {}
var prezzo: Label
var unita: Label
var nome: Label
var valori: Array[Label] = []
var etichette: Array[Label] = []
var restano: Label
var restano_cosa: Label
var quanti: Label
var quanti_cosa: Label
var compra: TastoObliquo
var motivo: Label
var arrivo := 1.0              # 0..1: il disegno che entra
var orologio := -1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(Tavola.LARGO, Tavola.ALTO)
	var bianco := Stile.colore("testo")
	var nero := Stile.colore("box_testo")
	prezzo = aggiungi(Tavola.scritta("", 76, bianco, Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER), Rect2(930, 70, 270, 92))
	Tavola.ombra(prezzo, Color(nero, 0.9), Vector2(4, 4))
	unita = aggiungi(Tavola.scritta("TAZO", 16, nero, Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER), Rect2(965, 166, 200, 22))
	nome = aggiungi(Tavola.scritta("", 30, bianco, Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER), Rect2(724, 496, 330, 44))
	Tavola.ombra(nome, Color(nero, 0.9))
	for i in 3:
		var x := PRIMO_RIQUADRO.x + PASSO_RIQUADRO * i
		valori.append(aggiungi(Tavola.scritta("", 26, bianco, Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER),
				Rect2(x, PRIMO_RIQUADRO.y + 8, RIQUADRO.x, 44)))
		etichette.append(aggiungi(Tavola.scritta("", 12, bianco, Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER),
				Rect2(x - 4, PRIMO_RIQUADRO.y + RIQUADRO.y + 6, RIQUADRO.x + 8, 16)))
	restano = aggiungi(Tavola.scritta("", 44, bianco, Caratteri.titolo(), HORIZONTAL_ALIGNMENT_RIGHT), Rect2(1070, 372, 180, 56))
	restano_cosa = aggiungi(Tavola.scritta("", 13, Stile.colore("testo_smorzato"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_RIGHT), Rect2(1070, 428, 180, 18))
	quanti = aggiungi(Tavola.scritta("", 30, bianco, Caratteri.titolo()), Rect2(1154, 484, 110, 36))
	quanti_cosa = aggiungi(Tavola.scritta("", 12, Stile.colore("testo_smorzato"), Caratteri.tondo(900)), Rect2(1154, 518, 120, 16))
	compra = TastoObliquo.nuovo("COMPRA", "chiaro", 26)
	add_child(compra)
	Tavola.metti(compra, Rect2(1030, 566, 240, 50))
	motivo = aggiungi(Tavola.scritta("", 12, Stile.colore("accento"), Caratteri.tondo(900), HORIZONTAL_ALIGNMENT_CENTER), Rect2(1020, 620, 250, 18))


func aggiungi(etichetta: Label, dove: Rect2) -> Label:
	add_child(etichetta)
	Tavola.metti(etichetta, dove)
	etichetta.clip_text = true
	return etichetta


# --- cosa c'e' in vetrina -----------------------------------------------------

func mostra(nuova: Dictionary, entra := true) -> void:
	var cambia := String(nuova.get("oggetto", "")) != String(voce.get("oggetto", "")) \
			or String(nuova.get("tipo", "")) != String(voce.get("tipo", ""))
	voce = nuova
	var id_oggetto := String(voce.get("oggetto", ""))
	var baratto := String(voce.get("tipo", "")) == "baratto"
	prezzo.text = "BARATTO" if baratto else "%d" % int(voce.get("prezzo", 0))
	# solo il corpo: la crenatura l'ha gia' messa Tavola.scritta, e rimetterla
	# a ogni carta avvolgerebbe il carattere in un'altra variante ogni volta
	prezzo.add_theme_font_size_override("font_size", 56 if baratto else 76)
	unita.text = "IN CAMBIO DI" if baratto else "TAZO"
	nome.text = Merce.nome_di(id_oggetto).to_upper()
	Tavola.stringi(nome, 30, 20)
	riempi_riquadri(baratto)
	riempi_conti(baratto, id_oggetto)
	var no := Merce.perche_no(voce)
	compra.text = "BARATTA" if baratto else "COMPRA"
	compra.inerte = no != ""
	compra.adatta_misura()
	compra.queue_redraw()
	motivo.text = no.to_upper()
	if cambia and entra:
		arrivo = 0.0
		orologio = 0.0
		set_process(true)
	queue_redraw()


func riempi_riquadri(baratto: bool) -> void:
	var pezzi: Array[Dictionary] = []
	if baratto:
		pezzi = pezzi_del_baratto()
	else:
		pezzi = Merce.pezzi_effetto(GameState.dati_oggetto(String(voce.get("oggetto", ""))))
	for i in 3:
		var presente := i < pezzi.size()
		valori[i].text = String(pezzi[i]["valore"]) if presente else ""
		etichette[i].text = String(pezzi[i]["nome"]) if presente else ""
		Tavola.stringi(etichette[i], 12, 9)


func pezzi_del_baratto() -> Array[Dictionary]:
	# i materiali che chiede, uno per riquadro: segnato se ce l'hai
	var pezzi: Array[Dictionary] = []
	var disponibili: Array = GameState.collezionabili.duplicate()
	for materiale in (voce.get("richiede", []) as Array).slice(0, 3):
		var ce := String(materiale) in disponibili
		if ce:
			disponibili.erase(String(materiale))
		# SI' e NO, non segni: il carattere dei titoli ha le lettere, non i simboli
		pezzi.append({"valore": "SÌ" if ce else "NO", "nome": Merce.nome_di(String(materiale)).to_upper()})
	return pezzi


func riempi_conti(baratto: bool, id_oggetto: String) -> void:
	if baratto:
		var richiesti: Array = voce.get("richiede", [])
		var hai := richiesti.size() - Merce.mancanti(richiesti).size()
		restano.text = "%d/%d" % [clampi(hai, 0, richiesti.size()), richiesti.size()]
		restano_cosa.text = "MATERIALI"
	else:
		var dopo := GameState.tazo - int(voce.get("prezzo", 0))
		restano.text = "%d" % absi(dopo)
		restano_cosa.text = "TI RESTANO" if dopo >= 0 else "TI MANCANO"
	restano.add_theme_color_override("font_color",
			Stile.colore("accento") if restano_cosa.text == "TI MANCANO" else Stile.colore("testo"))
	var consumabile := String(GameState.dati_oggetto(id_oggetto).get("tipo", "consumabile")) == "consumabile"
	if consumabile:
		quanti.text = "×%d" % Merce.quanti_in_sacca(id_oggetto)
		quanti_cosa.text = "IN SACCA"
	else:
		quanti.text = "×%d" % (1 if GameState.posseduto_equipaggiabile(id_oggetto) else 0)
		quanti_cosa.text = "GIÀ TUOI"


# --- il movimento -------------------------------------------------------------

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


# --- il disegno ---------------------------------------------------------------

func _draw() -> void:
	var banda := PackedVector2Array(BANDA)
	var striscia := PackedVector2Array()
	for p in [BANDA[0], BANDA[3]]:
		striscia.append(p - Vector2(STACCO_STRISCIA + LARGO_STRISCIA, 0))
	striscia.append(BANDA[3] - Vector2(STACCO_STRISCIA, 0))
	striscia.append(BANDA[0] - Vector2(STACCO_STRISCIA, 0))
	draw_colored_polygon(striscia, Stile.colore("bordo_acceso"))
	draw_colored_polygon(banda, Stile.colore("accento"))
	disegna_riquadri()
	if voce.is_empty():
		return
	disegna_oggetto(IMMAGINE, LATO_SAGOMA, Vector2(SCIVOLO * (1.0 - arrivo), 0.0), arrivo, Vector2(8, 8))
	disegna_oggetto(MINIATURA, MINIATURA.size.x * 0.8, Vector2.ZERO, 1.0, Vector2(4, 4))


func disegna_riquadri() -> void:
	for i in 3:
		if valori.size() <= i or valori[i].text == "":
			continue
		var r := Rect2(PRIMO_RIQUADRO + Vector2(PASSO_RIQUADRO * i, 0), RIQUADRO)
		draw_rect(r, Stile.colore("box_testo"))
		draw_rect(Rect2(r.position.x, r.end.y - 3.0, r.size.x, 3.0), Stile.colore("bordo_acceso"))


func disegna_oggetto(dove: Rect2, lato: float, spostato: Vector2, alfa: float, ombra: Vector2) -> void:
	var id_oggetto := String(voce.get("oggetto", ""))
	var disegno := Sagome.immagine_oggetto(id_oggetto)
	var r := Rect2(dove.position + spostato, dove.size)
	if disegno != null:
		var misura := disegno.get_size()
		var quanto := minf(r.size.x / misura.x, r.size.y / misura.y)
		var dentro := Rect2(r.get_center() - misura * quanto * 0.5, misura * quanto)
		draw_texture_rect(disegno, dentro, false, Color(1, 1, 1, alfa))
		return
	# la sagoma ha la sua sfoglia nera sotto: sulla fascia cremisi e sul nero
	# della pagina si legge lo stesso
	var tipo := Sagome.tipo_icona(id_oggetto)
	var nero := Color(Stile.colore("box_testo"), alfa)
	Sagome.icona_oggetto(self, r.get_center() + ombra, lato, tipo, nero, nero)
	Sagome.icona_oggetto(self, r.get_center(), lato, tipo, Color(Stile.colore("testo"), alfa), nero)
