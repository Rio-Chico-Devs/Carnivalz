class_name SlotCompagno
extends Control

# UNO DEI TRE SLOT DELLA SQUADRA, come sta nel disegno di Bru.
#
#   ┌─────────┐
#   │ ritratto│   quadrato, bordo nero spesso
#   └─────────┘
#    HP   ▬▬▬▬    arancio ambra
#    AURA ▬▬▬▬    lilla chiaro
#    ﹇    ▬▬▬▬    rossa, e la sua etichetta e' un ricciolo, non una parola
#         ▪ ▪     gli status: «quei riquadri vicino alla vita sono gli status»
#
# LE ETICHETTE SONO DUE PAROLE E UN SEGNO. HP e AURA si scrivono; il dominio no,
# perche' nel disegno di Bru quella riga porta un ricciolo rosso disegnato a
# mano. Non e' un vezzo: le prime due sono risorse che spendi e hanno un nome
# che conosci, la terza e' una cosa che si carica addosso e non ha bisogno di
# essere letta - deve solo riempirsi sotto gli occhi.
#
# LA SECONDA BARRA DICE "AURA" E NON "HYPE". Nel disegno c'e' scritto HYPE, ma e'
# piu' vecchio della decisione: «hp è hp, la seconda sarà aura non hype, la
# terza sarà la barra dominio, e l'hype è l'xp come prima [...] e così è deciso
# definitivamente». Le parole stanno in data/stile.json.

const RIGHE := [
	{"chiave": "hp", "testo": "HP", "colore": "barra_hp"},
	{"chiave": "aura", "testo": "AURA", "colore": "barra_aura"},
	{"chiave": "dominio", "testo": "", "colore": "barra_dominio"},
]
const STATUS_VISIBILI := 3   # quanti riquadri di status stanno sotto le barre

# Le quote misurate sul disegno, in frazione dell'altezza dello slot (593px sul
# foglio di Bru): le barre dal 415 al 500, gli status dal 528 in giu'.
const QUOTA_BARRE_DA := 0.658
const QUOTA_BARRE_A := 0.801
const QUOTA_STATUS_DA := 0.848

var cornice: Control
var ritratto: Control
var barre: Dictionary = {}       # chiave -> Control che si disegna
var quote: Dictionary = {}       # chiave -> quanto e' piena, 0..1
var etichette: Array[Control] = []
var status: Array[Control] = []
var simboli: Array[String] = []  # che status ha addosso, in ordine
var id_dentro := ""              # chi ci sta, o "" se il posto e' libero
var banda_adesso := ""           # quale faccia sta mostrando: serve all'isteresi
var faccia: TextureRect          # il ritratto che cambia con le ferite
var chiave_faccia := ""          # quale condizione sta gia' mostrando
var ricerche := 0                # quante volte ha DAVVERO cercato un disegno su disco
var iniziale: Label              # il ripiego quando non c'e' nessun disegno

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	costruisci()
	resized.connect(ridisponi)
	ridisponi()

func costruisci() -> void:
	cornice = ColorRect.new()
	cornice.color = Stile.colore("bordo")
	cornice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cornice)
	ritratto = Control.new()
	ritratto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ritratto)
	var fondo_faccia := ColorRect.new()
	fondo_faccia.color = Stile.colore("pannello_chiaro")
	fondo_faccia.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo_faccia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ritratto.add_child(fondo_faccia)
	faccia = TextureRect.new()
	faccia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	faccia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	faccia.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ritratto.add_child(faccia)
	iniziale = Label.new()
	iniziale.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	iniziale.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	iniziale.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	iniziale.add_theme_color_override("font_color", Stile.colore("testo_smorzato"))
	iniziale.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ritratto.add_child(iniziale)
	for riga in RIGHE:
		# UNA PAROLA, O UN SEGNO. HP e AURA si scrivono; il dominio no - nel
		# disegno quella riga porta un ricciolo rosso disegnato a mano, e un
		# ricciolo non e' una Label.
		var etichetta: Control
		if String(riga.testo) == "":
			etichetta = Control.new()
			etichetta.draw.connect(func() -> void:
				IconeStato.ricciolo(etichetta, Rect2(Vector2.ZERO, etichetta.size),
						Stile.colore("barra_dominio")))
		else:
			var scritta := Label.new()
			scritta.text = String(riga.testo)
			# NERE SUL BIANCO, come nel disegno. Erano bianche - il colore del
			# testo della schermata di dialogo, che ha il fondo nero - e su
			# questa pagina bianca sparivano del tutto: le barre c'erano e
			# nessuno sapeva quale fosse quale.
			scritta.add_theme_color_override("font_color", Stile.colore("box_testo"))
			etichetta = scritta
		etichetta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(etichetta)
		etichette.append(etichetta)
		var barra := barra_colorata(String(riga.chiave), String(riga.colore))
		add_child(barra)
		barre[String(riga.chiave)] = barra
		quote[String(riga.chiave)] = 1.0
	for i in STATUS_VISIBILI:
		var tassello := tassello_status(i)
		add_child(tassello)
		status.append(tassello)

func barra_colorata(chiave: String, nome_colore: String) -> Control:
	# Piena e squadrata, senza bordo: nel disegno e' un rettangolo di colore
	# pieno sul nero, e basta quello.
	var telaio := Control.new()
	telaio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	telaio.draw.connect(func() -> void:
		var quanto := clampf(float(quote.get(chiave, 0.0)), 0.0, 1.0)
		telaio.draw_rect(Rect2(Vector2.ZERO, telaio.size), Stile.colore("pannello_chiaro"))
		if quanto > 0.0:
			telaio.draw_rect(Rect2(Vector2.ZERO, Vector2(telaio.size.x * quanto, telaio.size.y)),
					Stile.colore(nome_colore)))
	return telaio

func tassello_status(indice: int) -> Control:
	# Un quadrato nero col simbolo dentro. Quando sta bene c'e' l'icona
	# normale, altrimenti quella dello status: «se stanno bene ci stara l'icona
	# normale altrimenti ho fatto esempi per in fiamme, maledetto e paralisi».
	var tassello := Control.new()
	tassello.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tassello.draw.connect(func() -> void:
		tassello.draw_rect(Rect2(Vector2.ZERO, tassello.size), Stile.colore("bordo"))
		var quale := simboli[indice] if indice < simboli.size() else ""
		IconeStato.disegna(tassello, quale, Rect2(Vector2.ZERO, tassello.size)))
	return tassello

# --- quello che si vede ------------------------------------------------------

func abita(id_personaggio: String) -> void:
	# CHI CI STA DENTRO. Da qui in poi lo slot si disegna da solo: la faccia la
	# sceglie la condizione, non chi chiama.
	id_dentro = id_personaggio
	banda_adesso = ""
	chiave_faccia = ""
	visible = true
	for riga in RIGHE:
		(barre[String(riga.chiave)] as Control).visible = true
	aggiorna_faccia(1.0, [])

func lascia_vuoto() -> void:
	# «finché non hai compagni quei riquadri in più per i compagni avranno
	# un'immagine che ti darò». Uno slot libero non sparisce: mostra il suo
	# disegno e spegne barre e status, che non misurano nessuno.
	id_dentro = ""
	banda_adesso = ""
	chiave_faccia = ""
	visible = true
	for riga in RIGHE:
		(barre[String(riga.chiave)] as Control).visible = false
	for etichetta in etichette:
		etichetta.visible = false
	for tassello in status:
		tassello.visible = false
	metti_disegno(RitrattiCombattimento.posto_vuoto(), "")

func aggiorna_faccia(quota_hp: float, stati: Array[String]) -> void:
	# SI CERCA UN DISEGNO SOLO QUANDO CAMBIA LA CONDIZIONE.
	#
	# Questa funzione viene chiamata a ogni aggiornamento di scheda - e ce n'e'
	# uno per colpo, per stato, per battuta - e ogni volta rifaceva l'intera
	# catena di ripiego: fino a sei domande al disco, misurate in 0.10 ms per
	# giro, per tre compagni. Ma la faccia cambia solo quando cambia la banda o
	# quello che ha addosso: il resto delle volte si stava cercando il file che
	# era gia' appeso.
	if id_dentro == "":
		return
	var prima := banda_adesso
	banda_adesso = RitrattiCombattimento.banda(quota_hp, prima)
	var chiave := banda_adesso + "|" + "|".join(stati)
	if chiave == chiave_faccia:
		return
	chiave_faccia = chiave
	ricerche += 1
	var scheda: Dictionary = GameState.personaggi.get(id_dentro, {})
	metti_disegno(RitrattiCombattimento.scegli(id_dentro, quota_hp, stati, prima,
			String(scheda.get("ritratto", ""))), String(scheda.get("nome", id_dentro)))

func metti_disegno(percorso: String, nome: String) -> void:
	if faccia == null:
		return
	if percorso != "" and ResourceLoader.exists(percorso):
		faccia.texture = load(percorso)
		faccia.visible = true
		iniziale.visible = false
		return
	faccia.texture = null
	faccia.visible = false
	# IL RIPIEGO DEVE VEDERSI: l'iniziale su fondo scuro, come nella schermata
	# dei dialoghi. Finche' i disegni non ci sono, uno slot vuoto e uno slot con
	# dentro qualcuno devono restare distinguibili.
	iniziale.text = nome.left(1).to_upper() if nome != "" else ""
	iniziale.visible = true

func imposta_barra(chiave: String, quanto: float) -> void:
	quote[chiave] = clampf(quanto, 0.0, 1.0)
	if barre.has(chiave):
		(barre[chiave] as Control).queue_redraw()

func quanto(chiave: String) -> float:
	# quanto e' piena una delle tre barre, 0..1. Serve a chi guarda da fuori -
	# le prove - per non dover frugare dentro il dizionario
	return float(quote.get(chiave, -1.0))

func imposta_status(elenco: Array[String]) -> void:
	# UNO SOLO, quando sta bene. Nel disegno di Bru accanto a ogni personaggio
	# c'e' UN riquadro: «se stanno bene ci stara l'icona normale altrimenti ho
	# fatto esempi per in fiamme, maledetto e paralisi». Tre riquadri sempre
	# accesi direbbero che ha tre cose addosso anche quando non ha niente.
	#
	# E SI RIMETTE IN RIGA SOLO SE CAMBIA QUANTI SONO. Prima si rifaceva tutta la
	# disposizione dello slot - ritratto, tre barre, tre riquadri - a ogni
	# aggiornamento di scheda, cioe' a ogni colpo e a ogni battuta, per tre
	# compagni. Ma i riquadri si spostano solo quando cambia il LORO NUMERO: se
	# ne avevi uno addosso e ne hai ancora uno, stanno gia' dove devono.
	var quanti_prima := maxi(simboli.size(), 1)
	simboli = elenco
	for i in status.size():
		status[i].visible = i < maxi(elenco.size(), 1)
		status[i].queue_redraw()
	if maxi(elenco.size(), 1) != quanti_prima:
		ridisponi()

# --- la disposizione, dal disegno --------------------------------------------

func ridisponi() -> void:
	# LE PROPORZIONI SONO QUELLE MISURATE SUL DISEGNO, non stimate a occhio.
	#
	# Sul foglio di Bru uno slot e' alto 593 pixel: il ritratto ne prende 375,
	# le tre barre stanno fra il 415 e il 500, i riquadri degli status fra il
	# 528 e il 618. Qui sotto sono le stesse quote in frazione dello slot.
	#
	# Al primo tentativo le distribuivo "quello che avanza dopo il ritratto", e
	# agli status avanzavano venti pixel: tre puntini invece di tre tasselli.
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var lato := size.x
	cornice.position = Vector2.ZERO
	cornice.size = Vector2(lato, lato)
	var bordo := float(Stile.forma("bordo_plancia"))
	ritratto.position = Vector2(bordo, bordo)
	ritratto.size = Vector2(lato - bordo * 2.0, lato - bordo * 2.0)
	if iniziale != null:
		iniziale.add_theme_font_size_override("font_size", maxi(int(lato * 0.42), 12))

	var da_barre := size.y * QUOTA_BARRE_DA
	var a_barre := size.y * QUOTA_BARRE_A
	var alto_riga := (a_barre - da_barre) / float(RIGHE.size()) * 0.72
	var passo := (a_barre - da_barre) / float(RIGHE.size())
	var corpo := maxi(int(alto_riga * 1.05), 8)
	var largo_etichetta := lato * 0.27
	var y := da_barre
	for i in RIGHE.size():
		var etichetta: Control = etichette[i]
		if etichetta is Label:
			(etichetta as Label).add_theme_font_size_override("font_size", corpo)
			etichetta.position = Vector2(0.0, y + alto_riga * 0.5 - corpo * 0.72)
			etichetta.size = Vector2(largo_etichetta, corpo * 1.4)
		else:
			etichetta.position = Vector2(0.0, y - alto_riga * 0.35)
			etichetta.size = Vector2(largo_etichetta * 0.58, alto_riga * 1.7)
			etichetta.queue_redraw()
		var barra: Control = barre[String(RIGHE[i].chiave)]
		barra.position = Vector2(largo_etichetta * 1.06, y)
		barra.size = Vector2(size.x - largo_etichetta * 1.06, alto_riga)
		barra.queue_redraw()
		y += passo

	# GLI STATUS, ALLINEATI A DESTRA come nel disegno
	var da_status := size.y * QUOTA_STATUS_DA
	var lato_status := size.y * (1.0 - QUOTA_STATUS_DA)
	var x := size.x
	for i in range(status.size() - 1, -1, -1):
		if not status[i].visible:
			continue
		x -= lato_status
		status[i].position = Vector2(x, da_status)
		status[i].size = Vector2(lato_status, lato_status)
		x -= lato_status * 0.16
		status[i].queue_redraw()
