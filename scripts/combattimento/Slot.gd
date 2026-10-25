class_name SlotCompagno
extends Control

# LA SCHEDA DI UNO DELLA SQUADRA, come nella proposta che Bru ha approvato
# (docs/scontro_proposta.md).
#
#    ╱┌────┐ TOCCA A TE              ●
#   ╱ │ A  │ ♥ ▬▬▬▬▬▬▬▬▬▬▬▬  100/100
#  ╱  └────┘ 🜂 ▬▬▬▬▬▬▬▬▬▬▬▬   10/10
#  ──────────♛ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
#
# PRIMA ogni compagno era un ritratto grande quanto una cartolina, nero finche'
# non ci sono i disegni, e la sua vita una barra di otto pixel che galleggiava
# nell'arancio li' sotto, con «HP» scritto a dieci pixel: il posto andava a
# quello che non dice niente, e le cose che contano - quanta vita ti resta, se
# ti basta l'aura - erano le piu' piccole della schermata.
#
# ADESSO la scheda e' un foglio di sbieco sulla diagonale (Spina.gd), col
# ritratto piccolo e le barre lunghe e spesse DENTRO il foglio, ognuna col suo
# segno - il palloncino, il fuoco fatuo, la corona: le icone delle statistiche -
# e la vita sempre scritta. Sul foglio chiaro il pieno e' scuro: la vita nera,
# l'aura ruggine, il dominio rosso, sul vuoto chiaro. Chi ha il turno fa un
# passo avanti verso la creatura: la scheda si allarga, il ritratto esce dal
# foglio inclinato, e al posto del nome c'e' «TOCCA A TE» (FasciaTurno). Il suo
# ECG sta grande in cima ai comandi (Plancia.gd).
#
# Gli status ci sono sempre, piccoli, in un angolo: «se stanno bene ci stara
# l'icona normale» (Bru).
#
# LA SECONDA BARRA E' L'AURA E NON L'HYPE: «hp è hp, la seconda sarà aura non
# hype, la terza sarà la barra dominio [...] e così è deciso definitivamente».

const IS := preload("res://scripts/crescita/IconeStatistiche.gd")
const RIGHE := [
	{"chiave": "hp", "icona": "hp", "colore": "bordo"},
	{"chiave": "aura", "icona": "aura", "colore": "accento_su_carta"},
	{"chiave": "dominio", "icona": "maestria_dominio", "colore": "barra_dominio"},
]
const STATUS_VISIBILI := 3   # quanti gettoni di status stanno nell'angolo
const RUOTA_RITRATTO := -3.5 # gradi: il ritratto di chi ha il turno esce dal foglio inclinato

signal misura_cambiata   # la scheda cresce o cala col turno: chi la dispone la rimette in fila

var cornice: CorniceRitratto     # il bordo del ritratto: si accende a chi ha il turno
var ritratto: Control
var barre: Dictionary = {}       # chiave -> Control che si disegna
var quote: Dictionary = {}       # chiave -> quanto si VEDE adesso, 0..1
# LA VITA NON SALTA, SCENDE. Bru: «quando ricevi danno la linea che scende deve
# essere animata, stessa cosa se si recupera hp».
#
# Ci sono tre valori per barra: dove si e' arrivati (mete), quanto si vede in
# questo istante (quote, che insegue), e LA SCIA - quanto c'era prima, che resta
# indietro e collassa dopo. La scia e' il pezzo che hai appena perso: e' il
# modo standard di raccontare un colpo senza scrivere niente.
var mete: Dictionary = {}        # chiave -> dove deve arrivare
var scie: Dictionary = {}        # chiave -> la coda che insegue, 0..1
var tweens: Dictionary = {}      # chiave -> il tween in volo, da fermare
var mai_impostate: Dictionary = {}   # chiave -> l'ha gia' ricevuta un valore vero?
var numero_vita: Label           # quanti HP, in chiaro, sempre
var etichette: Array[Control] = []   # i segni delle tre barre
var status: Array[Control] = []
var simboli: Array[String] = []  # che status ha addosso, in ordine
var id_dentro := ""              # chi ci sta, o "" se il posto e' libero
var banda_adesso := ""           # quale faccia sta mostrando: serve all'isteresi
var faccia: TextureRect          # il ritratto che cambia con le ferite
var chiave_faccia := ""          # quale condizione sta gia' mostrando
var ricerche := 0                # quante volte ha DAVVERO cercato un disegno su disco
var iniziale: Label              # il ripiego quando non c'e' nessun disegno
var numero_aura: Label           # quanta aura ha, e si vede solo a chi tocca
var nome: Label                  # il nome sull'etichetta nera, in alto
var libero := false              # il posto di un compagno che non c'e'
var tocca_a_lui := false
var pendenza_px := 0.0           # di quanto rientra il lato sinistro per pixel d'altezza (lo mette la plancia)
var scala := 1.0                 # quanto e' grande il foglio della schermata (lo mette la plancia)
var attiva := 0.0:               # 0 a riposo, 1 col turno: si anima, e la plancia rimette in fila
	set(valore):
		attiva = valore
		ridisponi()
		misura_cambiata.emit()
var passo_turno: Tween = null
var aura_massima := 1
var prenota_aura := 0:           # l'aura della mossa che stai guardando nella lista (Plancia.prenota_per)
	set(valore):
		if valore == prenota_aura:
			return
		prenota_aura = valore
		if barre.has("aura"):
			(barre["aura"] as Control).queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	costruisci()
	resized.connect(ridisponi)
	ridisponi()

func costruisci() -> void:
	ritratto = Control.new()
	ritratto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ritratto)
	cornice = CorniceRitratto.new()
	cornice.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ritratto.add_child(cornice)
	faccia = TextureRect.new()
	faccia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	faccia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	faccia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ritratto.add_child(faccia)
	iniziale = Label.new()
	iniziale.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	iniziale.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	iniziale.add_theme_color_override("font_color", Stile.colore("tratto"))
	iniziale.add_theme_font_override("font", Caratteri.titolo())
	iniziale.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ritratto.add_child(iniziale)
	nome = Label.new()
	nome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nome.uppercase = true
	add_child(nome)
	for riga in RIGHE:
		# UN SEGNO PER BARRA, non una parola: «HP» e «AURA» a dieci pixel non li
		# leggeva nessuno, e le icone delle statistiche sono quelle che Bru ha
		# visto nella crescita
		var segno := Control.new()
		segno.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var chiave_icona := String(riga.icona)
		segno.draw.connect(func() -> void:
			IS.disegna(segno, chiave_icona, segno.size * 0.5, minf(segno.size.x, segno.size.y),
					Stile.colore("bordo"), colore_carta()))
		add_child(segno)
		etichette.append(segno)
		var barra := barra_colorata(String(riga.chiave), String(riga.colore))
		add_child(barra)
		barre[String(riga.chiave)] = barra
		quote[String(riga.chiave)] = 1.0
	# IL NUMERO DELL'AURA, E SOLO SU CHI HA IL TURNO.
	#
	# Per gli HP la forma della barra basta: guardi quanto ne resta e sai come
	# stai. Per l'aura no - una mossa costa CINQUE, e una barra a meta' non ti
	# dice se cinque ce li hai. E' l'unica delle tre che serve contare, perche'
	# e' l'unica che si spende a prezzo fisso.
	numero_aura = Label.new()
	numero_aura.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	numero_aura.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	numero_aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vesti_numero(numero_aura)
	numero_aura.visible = false
	add_child(numero_aura)
	numero_vita = Label.new()
	numero_vita.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	numero_vita.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	numero_vita.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vesti_numero(numero_vita)
	add_child(numero_vita)
	for i in STATUS_VISIBILI:
		var tassello := tassello_status(i)
		add_child(tassello)
		status.append(tassello)

func vesti_numero(etichetta: Label) -> void:
	# NERO SUL FOGLIO CHIARO, accanto alla barra e non sopra: sopra una barra
	# che cambia colore un numero fisso e' illeggibile su una delle due parti
	etichetta.add_theme_color_override("font_color", Stile.colore("bordo"))
	etichetta.add_theme_font_override("font", Caratteri.titolo())

func colore_carta() -> Color:
	# il foglio di chi ha il turno e' il chiaro del box, quello degli altri il
	# grigio caldo dei pannelli
	return Stile.colore("plancia_pannello").lerp(Stile.colore("box_fondo"), attiva)

func barra_colorata(chiave: String, nome_colore: String) -> Control:
	var telaio := Control.new()
	telaio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	telaio.draw.connect(func() -> void:
		var pieno := clampf(float(quote.get(chiave, 0.0)), 0.0, 1.0)
		var coda := clampf(float(scie.get(chiave, pieno)), 0.0, 1.0)
		var prenota := float(prenota_aura) / maxf(float(aura_massima), 1.0) if chiave == "aura" else 0.0
		var dove := Rect2(Vector2.ZERO, telaio.size)
		SpinaPlancia.barra(telaio, dove, pieno, Stile.colore(nome_colore), coda, false, prenota)
		if prenota > 0.0:
			# QUANTO TI COSTA, in rosso sul pezzo a righe che se ne andrebbe
			var testo := "-%d" % prenota_aura
			var corpo := maxi(int(round(15.0 * scala)), 8)
			var largo := Caratteri.titolo().get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x + corpo
			var mezzo := dove.size.x * (pieno - minf(prenota, pieno) * 0.5)
			Manifesto.etichetta_tinta(telaio, Vector2(mezzo - largo * 0.5, dove.size.y * 0.5 - corpo * 0.65), testo, corpo,
					Stile.colore("pericolo"), Stile.colore("testo")))
	return telaio

func tassello_status(indice: int) -> Control:
	# Un gettone tondo col simbolo dentro (Manifesto.gettone). Quando sta bene
	# c'e' l'icona normale, altrimenti quella dello status: «se stanno bene ci
	# stara l'icona normale altrimenti ho fatto esempi per in fiamme, maledetto
	# e paralisi».
	var tassello := Control.new()
	tassello.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tassello.draw.connect(func() -> void:
		Manifesto.gettone(tassello, Rect2(Vector2.ZERO, tassello.size))
		var quale := simboli[indice] if indice < simboli.size() else ""
		IconeStato.disegna(tassello, quale, Rect2(Vector2.ZERO, tassello.size).grow(-tassello.size.x * 0.14)))
	return tassello

# --- quello che si vede ------------------------------------------------------

func abita(id_personaggio: String) -> void:
	# CHI CI STA DENTRO. Da qui in poi lo slot si disegna da solo: la faccia la
	# sceglie la condizione, non chi chiama.
	id_dentro = id_personaggio
	libero = false
	# CHI ARRIVA NON EREDITA IL MOVIMENTO DI CHI C'ERA PRIMA: se lo slot cambia
	# inquilino, le barre del nuovo non devono animarsi dai valori del vecchio
	mai_impostate.clear()
	for chiave_tween in tweens:
		if is_instance_valid(tweens[chiave_tween]):
			(tweens[chiave_tween] as Tween).kill()
	tweens.clear()
	banda_adesso = ""
	chiave_faccia = ""
	visible = true
	var scheda: Dictionary = GameState.personaggi.get(id_personaggio, {})
	nome.text = String(scheda.get("nome_breve", scheda.get("nome", id_personaggio)))
	if not GameState.party.is_empty() and id_personaggio == String(GameState.party[0]):
		nome.text = "TU"
	for riga in RIGHE:
		(barre[String(riga.chiave)] as Control).visible = true
	for segno in etichette:
		segno.visible = true
	nome.visible = true
	numero_vita.visible = true
	aggiorna_faccia(1.0, [])
	ridisponi()
	misura_cambiata.emit()

func lascia_vuoto() -> void:
	# «finché non hai compagni quei riquadri in più per i compagni avranno
	# un'immagine che ti darò». Un posto libero non sparisce: e' una striscia
	# bassa col suo disegno, e spegne barre e status, che non misurano nessuno.
	id_dentro = ""
	libero = true
	banda_adesso = ""
	chiave_faccia = ""
	visible = true
	for riga in RIGHE:
		(barre[String(riga.chiave)] as Control).visible = false
	for segno in etichette:
		segno.visible = false
	for tassello in status:
		tassello.visible = false
	nome.visible = false
	numero_vita.visible = false
	numero_aura.visible = false
	metti_disegno(RitrattiCombattimento.posto_vuoto(), "")
	ridisponi()
	misura_cambiata.emit()

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

func metti_disegno(percorso: String, chi: String) -> void:
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
	iniziale.text = chi.left(1).to_upper() if chi != "" else ""
	iniziale.visible = true

func imposta_turno(suo: bool) -> void:
	# DI CHI E' IL TURNO SI VEDE ACCENDENDO LUI, non spegnendo gli altri: sul
	# chiaro, sbiadire si legge "fuori combattimento". Chi tocca fa un passo
	# avanti verso la creatura e si allarga; la cornice del ritratto si accende;
	# al posto del nome, «TOCCA A TE». E' anche la risposta a "di chi sono
	# l'ECG, il morale e lo stress": di quello che ha fatto il passo.
	if suo == tocca_a_lui:
		return
	tocca_a_lui = suo
	cornice.color = Stile.colore("cornice_turno") if suo else Stile.colore("bordo")
	if numero_aura != null:
		numero_aura.visible = suo and id_dentro != ""
	if passo_turno != null and passo_turno.is_valid():
		passo_turno.kill()
	var verso := 1.0 if suo else 0.0
	if Movimento.ridotto() or not is_inside_tree():
		attiva = verso
	else:
		passo_turno = create_tween()
		passo_turno.tween_property(self, "attiva", verso, Movimento.durata("entrata")) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if suo and id_dentro != "":
		FasciaTurno.metti(self, FasciaTurno.testo_per(id_dentro), "bordo", posto_del_nome(1.0), largo_del_nome(1.0))
		nome.visible = false
	else:
		FasciaTurno.togli(self)
		nome.visible = id_dentro != ""

func mostra_aura(adesso: int, massimo: int) -> void:
	# IL NUMERO SI SCRIVE SEMPRE, SI VEDE QUANDO TOCCA: se il valore passa PRIMA
	# che il turno si accenda - e succede - la scritta non deve restare vuota
	aura_massima = maxi(massimo, 1)
	if numero_aura == null:
		return
	numero_aura.text = "%d/%d" % [adesso, maxi(massimo, 1)]

const DISCESA := 0.30     # quanto ci mette la barra a raggiungere il valore nuovo
const CODA := 0.55        # e quanto ci mette la scia a richiudersi dietro

func imposta_barra(chiave: String, valore: float) -> void:
	var obiettivo := clampf(valore, 0.0, 1.0)
	var prima := float(quote.get(chiave, obiettivo))
	mete[chiave] = obiettivo
	if not barre.has(chiave):
		quote[chiave] = obiettivo
		return
	var barra: Control = barre[chiave]
	# LA PRIMA VOLTA NON SI ANIMA. Non c'e' nessun "prima" da raccontare: senza
	# questo, la barra del dominio parte piena (il valore di costruzione) e si
	# svuota a vista a ogni inizio di scontro
	if not mai_impostate.has(chiave):
		mai_impostate[chiave] = true
		quote[chiave] = obiettivo
		scie[chiave] = obiettivo
		barra.queue_redraw()
		return
	# SENZA MOVIMENTO, SUBITO: "riduci il movimento" nelle opzioni
	if Impostazioni.movimento_ridotto or is_equal_approx(prima, obiettivo):
		quote[chiave] = obiettivo
		scie[chiave] = obiettivo
		barra.queue_redraw()
		return
	if tweens.has(chiave) and is_instance_valid(tweens[chiave]):
		(tweens[chiave] as Tween).kill()
	var t := barra.create_tween()
	tweens[chiave] = t
	# la barra vera si muove per prima, con la frenata: e' il colpo
	t.tween_method(func(v: float) -> void:
			quote[chiave] = v
			barra.queue_redraw(),
			prima, obiettivo, DISCESA).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if obiettivo < prima:
		# PERDENDO: la scia resta dov'era e si richiude dopo, piu' lenta. E'
		# quella che fa vedere QUANTO e' stato tolto
		scie[chiave] = prima
		t.tween_method(func(v: float) -> void:
				scie[chiave] = v
				barra.queue_redraw(),
				prima, obiettivo, CODA).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	else:
		# CURANDO: la scia va AVANTI e la barra la raggiunge
		scie[chiave] = obiettivo
		barra.queue_redraw()

func mostra_vita(adesso: int, massimo: int) -> void:
	# I NUMERI CI VOGLIONO. Bru: «quantifichiamo anche i valori, non ci sono
	# numeri per ora». Una barra dice "quanto ne resta in proporzione"; senza
	# cifre non si puo' decidere se una cura da 30 ti serve adesso o fra un turno
	if numero_vita == null:
		return
	numero_vita.text = "%d/%d" % [maxi(adesso, 0), maxi(massimo, 1)]

func quanto(chiave: String) -> float:
	# QUANTO E' PIENA: il valore VERO, non quello che si sta ancora disegnando
	return float(mete.get(chiave, quote.get(chiave, -1.0)))

func imposta_status(elenco: Array[String]) -> void:
	# UNO SOLO, quando sta bene: «se stanno bene ci stara l'icona normale». E
	# si rimette in riga solo se cambia QUANTI sono
	var quanti_prima := maxi(simboli.size(), 1)
	simboli = elenco
	for i in status.size():
		status[i].visible = not libero and i < maxi(elenco.size(), 1)
		status[i].queue_redraw()
	if maxi(elenco.size(), 1) != quanti_prima:
		ridisponi()

# --- la disposizione -----------------------------------------------------------

func alta_per(quanto_attiva: float) -> float:
	# quanto e' alta la scheda sul foglio della schermata (1280x720)
	if libero:
		return SpinaPlancia.numero("schede", "libero", 52.0)
	return lerpf(SpinaPlancia.numero("schede", "riposo", 84.0), SpinaPlancia.numero("schede", "turno", 118.0),
			quanto_attiva)

func sinistra_in_alto() -> float:
	# il lato sinistro, in alto, nelle coordinate dello slot: il nodo e' largo
	# quanto il foglio di sbieco, e in alto il foglio rientra
	return pendenza_px * size.y

func foglio() -> PackedVector2Array:
	return SpinaPlancia.sbieco(Rect2(Vector2(sinistra_in_alto(), 0.0), Vector2(size.x - sinistra_in_alto(), size.y)),
			pendenza_px)

func dove_ritratto() -> Rect2:
	var lato := lerpf(68.0, 112.0, attiva) * scala
	return Rect2(Vector2(sinistra_in_alto() + 18.0 * scala, lerpf(12.0, -20.0, attiva) * scala), Vector2(lato, lato))

func posto_del_nome(quanto_attiva: float) -> Vector2:
	# dove sta il nome (e la fascia del turno, che ne prende il posto): accanto
	# al ritratto, in alto. Il punto e' l'angolo in basso a sinistra
	var lato := lerpf(68.0, 112.0, quanto_attiva) * scala
	var corpo := lerpf(16.0, 19.0, quanto_attiva) * scala
	return Vector2(sinistra_in_alto() + (18.0 + 16.0 + 6.0) * scala + lato, lerpf(8.0, 10.0, quanto_attiva) * scala + corpo * 1.3)

func largo_del_nome(quanto_attiva: float) -> float:
	return size.x - posto_del_nome(quanto_attiva).x - 40.0 * scala - STATUS_VISIBILI * 28.0 * scala

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var punti := foglio()
	if libero:
		SpinaPlancia.carta(self, punti, Color(Stile.colore("plancia_pannello"), 0.55), 3.0, false)
		var font := Caratteri.titolo()
		var corpo := int(round(20.0 * scala))
		SpinaPlancia.scritta(self, font, Vector2(size.x * 0.5 + 40.0 * scala, size.y * 0.5 + corpo * 0.36),
				"POSTO LIBERO", corpo, Stile.colore("tratto"), HORIZONTAL_ALIGNMENT_CENTER)
		return
	SpinaPlancia.carta(self, punti, colore_carta(), lerpf(4.0, 5.0, attiva))

func ridisponi() -> void:
	if size.x <= 0.0 or size.y <= 0.0 or ritratto == null:
		return
	queue_redraw()
	# IL RITRATTO: piccolo a riposo, grande e inclinato quando tocca
	var r := dove_ritratto()
	if libero:
		r = Rect2(Vector2(sinistra_in_alto() + 14.0 * scala, 6.0 * scala), Vector2(size.y - 12.0 * scala, size.y - 12.0 * scala))
	ritratto.position = r.position
	ritratto.size = r.size
	ritratto.pivot_offset = r.size * 0.5
	ritratto.rotation = deg_to_rad(RUOTA_RITRATTO * attiva)
	cornice.ombra = attiva
	var bordo := 6.0 * scala
	for dentro: Control in [faccia, iniziale]:
		dentro.position = Vector2(bordo, bordo)
		dentro.size = r.size - Vector2(bordo, bordo) * 2.0
	iniziale.add_theme_font_size_override("font_size", maxi(int(r.size.y * 0.7), 10))
	# IL NOME
	var corpo_nome := maxi(int(round(lerpf(16.0, 19.0, attiva) * scala)), 8)
	Manifesto.vesti_etichetta(nome, corpo_nome, "manifesto", "bordo")
	nome.reset_size()
	nome.position = posto_del_nome(attiva) - Vector2(0.0, nome.size.y)
	# LE TRE BARRE, coi loro segni a sinistra e i numeri a destra
	var x0 := r.end.x + 16.0 * scala
	var x1 := size.x - 16.0 * scala
	var y := lerpf(32.0, 46.0, attiva) * scala
	var altezze := [lerpf(14.0, 20.0, attiva), lerpf(9.0, 13.0, attiva), lerpf(6.0, 8.0, attiva)]
	var corpo_numero := maxi(int(round(lerpf(17.0, 20.0, attiva) * scala)), 8)
	for i in RIGHE.size():
		var alta: float = float(altezze[i]) * scala
		var lato_segno := alta + lerpf(6.0, 10.0, attiva) * scala
		var segno: Control = etichette[i]
		segno.position = Vector2(x0, y + alta * 0.5 - lato_segno * 0.5)
		segno.size = Vector2(lato_segno, lato_segno)
		segno.queue_redraw()
		# il numero dell'aura c'e' solo per chi ha il turno: agli altri la barra
		# arriva fino in fondo
		var spazio_numero := 84.0 * scala if i == 0 or (i == 1 and tocca_a_lui) else 0.0
		var barra: Control = barre[String(RIGHE[i].chiave)]
		barra.position = Vector2(x0 + lato_segno + 8.0 * scala, y)
		barra.size = Vector2(maxf(x1 - barra.position.x - spazio_numero, 4.0), alta)
		barra.queue_redraw()
		var numero: Label = numero_vita if i == 0 else (numero_aura if i == 1 else null)
		if numero != null:
			numero.add_theme_font_size_override("font_size", corpo_numero)
			numero.position = Vector2(x1 - spazio_numero, y + alta * 0.5 - corpo_numero * 0.75)
			numero.size = Vector2(spazio_numero, corpo_numero * 1.5)
		y += alta + lerpf(7.0, 11.0, attiva) * scala
	# GLI STATUS, piccoli, in alto a destra
	var lato_status := 22.0 * scala
	var xs := size.x - 14.0 * scala - lato_status
	for i in status.size():
		if not status[i].visible:
			continue
		status[i].position = Vector2(xs, 9.0 * scala)
		status[i].size = Vector2(lato_status, lato_status)
		status[i].queue_redraw()
		xs -= lato_status + 6.0 * scala


class CorniceRitratto extends Control:
	# IL BORDO DEL RITRATTO: nero, con dentro un filo che si accende a chi ha il
	# turno (color), e l'ombra piena quando esce dal foglio
	var color := Color(0, 0, 0, 1):
		set(nuovo):
			color = nuovo
			queue_redraw()
	var ombra := 0.0:
		set(nuova):
			ombra = nuova
			queue_redraw()

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		color = Stile.colore("bordo")

	func _draw() -> void:
		var tutto := Rect2(Vector2.ZERO, size)
		if ombra > 0.0:
			Manifesto.rettangolo(self, Rect2(tutto.position + Manifesto.OMBRA * ombra, tutto.size), Stile.colore("bordo"))
		Manifesto.rettangolo(self, tutto, Stile.colore("bordo"))
		Manifesto.rettangolo(self, tutto.grow(-3.0), color)
		Manifesto.rettangolo(self, tutto.grow(-6.0), Stile.colore("quadro_vuoto"))
