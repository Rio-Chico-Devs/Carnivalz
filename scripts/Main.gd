extends Control

# Motore eventi: mostra il nodo corrente, filtra le scelte per requisiti
# e applica gli effetti (recluta / oggetto / lascia / reset). I contenuti
# vivono solo nei JSON.
#
# --- come si legge questa schermata ---
# Il box in basso (scenes/BoxTesto.tscn) mostra UN messaggio alla volta, preso
# da una coda (coda_messaggi). Il testo si scrive a macchina: un click lo
# completa, il successivo passa avanti. Non c'e' piu' un bottone "Continua"
# in mezzo alle scelte: si clicca dove si vuole (AreaAvanza copre lo schermo
# mentre si legge) oppure si preme Invio/Spazio. Le scelte vere compaiono solo
# quando la coda e' finita E il testo ha finito di scriversi: cosi' non si
# clicca mai per sbaglio su un'opzione mentre si sta ancora leggendo.
#
# Quattro tipi di messaggio, quattro trattamenti diversi (le regole grafiche
# stanno in BoxTesto.gd, non qui):
#   - "narrazione": la voce narrante che descrive la scena in seconda persona
#     ("ti nota", "il tuo compito"), in corsivo e senza nome — non è Anonimo
#     che parla, è chi racconta la storia dall'esterno
#   - "dialogo": un personaggio parla (incluso Anonimo, in prima persona), col
#     suo nome nella targhetta del box
#   - "notifica": oggetti/Tazo/passive, centrato e color accento: è il gioco
#     che ti informa, non la storia
#   - "titolo": il nome di un luogo — non entra nel box, prende tutto lo
#     schermo come una carta da film e poi si scioglie
# Un nodo può avere "sequenza" (lista di messaggi) oppure, in alternativa,
# il vecchio campo "testo" (diventa un'unica narrazione, per compatibilità
# con i contenuti non ancora convertiti).
#
# Schermata a tre fasce che non si muovono mai: barra di stato in alto, in
# mezzo il palco dei ritratti con a destra la colonna delle scelte (larghezza
# sempre riservata, anche vuota), e il box del testo inchiodato in basso a
# un'altezza fissa. Niente di quello che compare o sparisce - triangolino,
# scelte, bottoni - puo' far muovere il resto: era la cosa piu' fastidiosa
# della vecchia disposizione, dove ogni click faceva ballare mezza schermata.
#
# Palco dei ritratti sopra il box: a sinistra il protagonista (o un
# alternativo indicato dal nodo), a destra l'interlocutore. Se il nodo indica
# "centro", parla un solo personaggio al centro e i due spazi laterali
# spariscono. Chi non ha la battuta in quel momento resta in scena ma
# attenuato: l'occhio va da solo su chi sta parlando.

const SCENA_SEDE := "res://scenes/Sede.tscn"
const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_COMBATTIMENTO := "res://scenes/Combattimento.tscn"
const SCENA_MAPPA_ZONA := "res://scenes/MappaZona.tscn"
const SCENA_EVENTI := "res://scenes/Main.tscn"
const EVENTI_DEBUG := "res://data/events.json"
# Da che angolo entra il nastro col nome. Nel disegno di Bru il primo fotogramma
# lo ha quasi in verticale, oltre il bordo sinistro.
const ANGOLO_NASTRO_IN_ARRIVO := -58.0
const CARTELLA_NASTRI := "res://art/nastri/"
const APPUNTI_LETTI_A_VOCE := 2  # quanti appunti nuovi il protagonista pensa a voce prima di rimandare al Diario

@onready var sfondo: ColorRect = %Sfondo
@onready var slot_sinistra = %SlotSinistra
@onready var slot_centro = %SlotCentro
@onready var slot_destra = %SlotDestra
@onready var box = %BoxTesto
@onready var contenitore_scelte: VBoxContainer = %Scelte
@onready var bottone_dialoga: Button = %BottoneDialoga
@onready var bottone_mappa: Button = %BottoneMappa
@onready var menu_compagni: VBoxContainer = %MenuCompagni
@onready var colonna_azioni: VBoxContainer = %ColonnaAzioni
@onready var etichetta_party: Label = %Party
@onready var etichetta_risorse: Label = %Risorse
@onready var etichetta_stat: Label = %BarraStat
@onready var carta_titolo: Control = %CartaTitolo
@onready var colonna_titolo: VBoxContainer = %ColonnaTitolo
@onready var testo_titolo: Label = %TestoTitolo
var immagine_titolo: TextureRect
@onready var area_avanza: Button = %AreaAvanza
@onready var quadro: Control = %Quadro
@onready var scena_sfondo: TextureRect = %Scena
@onready var tinta_scena: ColorRect = %TintaScena
@onready var palco: HBoxContainer = %Palco
@onready var nastro: Control = %Targhetta
@onready var fondo_nastro: TextureRect = %FondoNastro
@onready var nome_nastro: Label = %NomeNastro
@onready var icona_menu: Button = %IconaMenu

var nodo_in_corso: Dictionary = {}
var coda_messaggi: Array[Dictionary] = []
# un messaggio con "attesa" non aspetta il click: finito di scriversi si conta
# il tempo indicato e si passa avanti da soli (il conto alla rovescia del
# lancio, un silenzio che deve pesare). Il contatore serve a non avanzare due
# volte se nel frattempo il giocatore clicca lo stesso.
var attesa_messaggio := 0.0
var contatore_messaggi := 0
var azione_dopo_coda: Callable = Callable()     # eseguita a coda vuota al posto delle scelte normali (es. mediazione)
var azione_a_fine_testo: Callable = Callable()  # eseguita appena il box ha finito di scrivere
var mostrando_scena := false  # true quando il nodo sta mostrando la sua descrizione di ritorno
var azione_dopo_titolo: Callable = Callable()  # ripresa in sospeso mentre la carta del titolo e' a schermo
var orologi_appesi := 0   # serve solo a far pendere le cipolle da due parti alterne
var nome_sul_nastro := ""  # chi c'e' scritto adesso: il nastro rientra solo quando cambia
var tween_nastro: Tween
var tween_sfondo: Tween

func _ready() -> void:
	if GameState.eventi.is_empty():
		# scena avviata direttamente dall'editor: carica la campagna di prova
		GameState.avvia_carnivalz("debug", EVENTI_DEBUG)
	AudioManager.musica(GameState.musica_ambiente)
	applica_stile()
	for slot in [slot_sinistra, slot_centro, slot_destra]:
		slot.imposta_grande(true)  # ritratto cinematografico, riempie lo schermo sopra il box
	box.scrittura_finita.connect(_su_testo_pronto)
	area_avanza.focus_mode = Control.FOCUS_NONE
	area_avanza.pressed.connect(_su_avanza)
	bottone_dialoga.pressed.connect(_su_dialoga)
	bottone_mappa.visible = GameState.stanza_nella_mappa(GameState.nodo_corrente)
	bottone_mappa.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_MAPPA_ZONA))
	# Alla nascita non si decide piu' niente: chi ci ha mandati qui e' gia'
	# entrato nel nodo (IngressoNodo.vai_al_nodo) e ha stabilito che c'era
	# qualcosa da mostrare. Questa schermata esiste solo in quel caso.
	disegna_nodo(IngressoNodo.raccogli(GameState.nodo_corrente), [])

func applica_stile() -> void:
	# LA CORNICE NERA. Non e' un bordo decorativo: e' quello che rende la scena
	# un'inquadratura invece di uno sfondo, ed e' il motivo per cui chi parla
	# puo' SBORDARE. Veronica esce dal quadro, passa sopra il nero e finisce
	# dietro il box - e se non ci fosse un quadro da cui uscire, quel gesto non
	# vorrebbe dire niente.
	sfondo.color = Stile.colore("sfondo")
	var bordo := Stile.forma("cornice")
	quadro.offset_left = bordo
	quadro.offset_top = bordo
	quadro.offset_right = -bordo
	quadro.offset_bottom = -bordo
	# PRIMA SI TOGLIE LA TARGHETTA, POI SI MISURA IL BOX. In quest'ordine e non
	# nell'altro: il box si calcola l'altezza da solo, e finche' dentro c'e' la
	# riga del nome quell'altezza comprende anche quella. Misurarlo prima
	# voleva dire inchiodarlo a un'altezza che un istante dopo non era piu' la
	# sua, con una striscia di bianco in piu' in fondo allo schermo.
	box.nome_fuori_dal_box()
	prepara_quadro()
	prepara_nastro()
	prepara_icona_menu()
	prepara_colonna_scelte()
	Stile.etichetta_piccola(etichetta_party)
	Stile.etichetta_piccola(etichetta_risorse)
	# LE STATISTICHE NON STANNO QUI. Bru: "le stats sono consultabili nel diario,
	# inutile metterle nella schermata dei dialoghi". Ed e' vero anche di piu'
	# per la barra di dominio: e' una prerogativa del combattimento, si riempie
	# li' e si azzera a ogni scontro. Tenerla in vista mentre parli con qualcuno
	# raccontava una risorsa che in quel momento non esiste.
	etichetta_stat.visible = false
	testo_titolo.add_theme_font_size_override("font_size", Stile.dimensione("titolo"))
	testo_titolo.add_theme_color_override("font_color", Stile.colore("accento"))
	# Una scena puo' fermarsi su un'illustrazione: usa lo stesso velo a schermo
	# intero della carta del titolo, perche' fa la stessa cosa - prende lo
	# schermo, aspetta, e poi la scena riprende. L'immagine sta SOPRA il testo,
	# che diventa la sua didascalia.
	immagine_titolo = TextureRect.new()
	immagine_titolo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	immagine_titolo.custom_minimum_size = Vector2(760, 460)
	immagine_titolo.visible = false
	colonna_titolo.add_child(immagine_titolo)
	colonna_titolo.move_child(immagine_titolo, 0)
	var suggerimento_titolo := Stile.costruisci_prompt("continua")
	colonna_titolo.add_child(suggerimento_titolo)
	Stile.pulsa(suggerimento_titolo)

func prepara_quadro() -> void:
	# Dentro la cornice c'e' il posto in cui sei, disegnato. Finche' quel
	# disegno non esiste resta un fondo scuro, e non si rompe niente: e' la
	# stessa regola dei ritratti, che il gioco si gioca anche senza.
	# FINCHE' IL DISEGNO DEL POSTO NON C'E', l'inquadratura ha un fondo suo -
	# scuro, ma non nero come la cornice. Se fosse nero uguale non si vedrebbe
	# che c'e' un'inquadratura, e tutto il disegno di Bru sta in quella
	# differenza: una scena dentro una cornice, non uno sfondo.
	tinta_scena.color = Stile.colore("quadro_vuoto")
	# il box e' inchiodato in basso e largo quanto il quadro, meno un morso a
	# destra: nel disegno non arriva a toccare il bordo, e quel vuoto e' quello
	# che fa sembrare il box appoggiato sopra invece che incastrato dentro.
	#
	# L'ALTEZZA LA DICE IL BOX, non questo conto. Provando a ricostruirla qui -
	# testo + margini + bordi - veniva sbagliata di sessanta pixel e il box
	# usciva dallo schermo: il box sa gia' quanto e' alto, perche' se l'e'
	# calcolata lui in imposta_altezza().
	var bordo := Stile.forma("cornice")
	box.offset_left = bordo
	box.offset_right = -bordo * 3
	box.offset_bottom = -bordo * 0.8
	box.offset_top = box.offset_bottom - box.get_combined_minimum_size().y
	# il palco dei ritratti arriva fin sotto il box: e' cosi' che chi parla
	# risulta tagliato dal box invece che appoggiato sopra
	palco.offset_left = bordo * 3
	palco.offset_top = bordo
	palco.offset_right = -bordo * 3
	palco.offset_bottom = -bordo * 0.75

func mostra_scena_di(contenitore: Dictionary) -> void:
	# L'ILLUSTRAZIONE DEL POSTO, se c'e'.
	#
	# La dichiara col campo "sfondo" o il nodo o la singola battuta. Bru: «in
	# ogni dialogo avremmo un'immagine che caricherà da una repo dove abbiamo
	# tutte le nostre immagini, poi sceglierò con cura quali mettere e dove».
	# Quindi il posto dove si dichiara deve essere la battuta, non solo la
	# stanza: nell'introduzione l'immagine cambia in mezzo a una narrazione, e
	# spezzarla in cinque nodi per cambiare disegno vorrebbe dire cinque nodi
	# che non sono cinque posti.
	#
	# Vale finche' non ne arriva un'altra: le battute che non dicono niente
	# tengono quella di prima, ed e' cosi' che tre frasi di fila condividono lo
	# stesso disegno senza ripeterlo tre volte.
	var percorso := String(contenitore.get("sfondo", ""))
	if percorso == "":
		return
	if not ResourceLoader.exists(percorso):
		# un disegno non ancora fatto non e' un errore: resta quello di prima e
		# la scena si gioca lo stesso. E' la stessa regola dei ritratti.
		push_warning("Sfondo di scena mancante: " + percorso)
		return
	var arrivata: Texture2D = load(percorso)
	if scena_sfondo.texture == arrivata:
		return
	dissolvi_sfondo(arrivata)

func dissolvi_sfondo(arrivata: Texture2D) -> void:
	# UN'IMMAGINE NON SCATTA, SFUMA. Nell'introduzione i cambi di sfondo cadono
	# in mezzo a un discorso: uno stacco netto li farebbe leggere come un taglio
	# di montaggio, e quella narrazione non e' montata, scorre.
	if scena_sfondo.texture == null:
		scena_sfondo.texture = arrivata
		return
	if tween_sfondo != null and tween_sfondo.is_valid():
		tween_sfondo.kill()
	scena_sfondo.texture = arrivata
	scena_sfondo.modulate.a = 0.0
	tween_sfondo = create_tween()
	tween_sfondo.tween_property(scena_sfondo, "modulate:a", 1.0, Stile.tempo("cambio_sfondo"))

func prepara_nastro() -> void:
	# IL NASTRO COL NOME. Un'etichetta rosa appiccicata storta sopra l'angolo
	# del box - come un pezzo di scotch con su scritto a mano chi sta parlando.
	#
	# Sta FUORI dai contenitori apposta: un Control dentro un contenitore si fa
	# riscrivere posizione e rotazione a ogni riordino, e il nastro tornerebbe
	# dritto da solo. E' lo stesso motivo per cui le carte del combattimento si
	# animano di scala e non di posizione.
	#
	# ED E' UN CONTENITORE, NON UNA SCRITTA, e non e' un dettaglio di struttura.
	# Finche' era una Label, era la Label a decidere quanto fosse alto il
	# nastro: l'altezza del carattere e' la sua misura minima e non si puo'
	# scendere sotto, nemmeno svuotandola. Col disegno di Bru addosso veniva
	# alto 98 pixel invece dei 78 chiesti, e il disegno ci ballava dentro.
	# Adesso il nastro e' un riquadro che decide lui la propria misura, e dentro
	# ci sta o il disegno o la scritta di ripiego.
	nome_nastro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nome_nastro.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nome_nastro.add_theme_stylebox_override("normal", stile_nastro_piatto())
	nome_nastro.add_theme_color_override("font_color", Stile.colore("nastro_testo"))
	nome_nastro.add_theme_font_size_override("font_size", Stile.dimensione("titolo"))
	nastro.rotation = deg_to_rad(Stile.forma("inclinazione_nastro"))

func stile_nastro_piatto() -> StyleBoxFlat:
	# Il ripiego: il rettangolo rosa. Vive finche' il disegno di quel
	# personaggio non c'e', e per qualcuno durera' a lungo.
	var stile := StyleBoxFlat.new()
	stile.bg_color = Stile.colore("nastro")
	stile.set_corner_radius_all(0)
	stile.content_margin_left = 30
	stile.content_margin_right = 30
	stile.content_margin_top = 4
	stile.content_margin_bottom = 6
	return stile

func aggiorna_nastro(nome: String, id_chi := "") -> void:
	nastro.visible = nome != ""
	if nome == "":
		nome_sul_nastro = ""
		return
	# SOLO QUANDO CAMBIA CHI PARLA. Un dialogo e' fatto di dieci battute della
	# stessa persona: rifare l'entrata a ognuna vorrebbe dire un nastro che
	# entra e rientra dieci volte di fila, che dopo la seconda e' un tic. Il
	# nastro si appiccica quando qualcuno prende la parola, e resta li' finche'
	# non parla qualcun altro.
	if nome == nome_sul_nastro:
		return
	nome_sul_nastro = nome
	# minuscolo come nel disegno: "veronica", non "Veronica". E' una scelta di
	# carattere, non un errore - il nastro e' scritto a mano, non stampato
	nome_nastro.text = nome.to_lower()
	vesti_il_nastro(id_chi)
	await get_tree().process_frame   # la misura giusta si sa dopo che il testo c'e'
	# SI GUARDA nome_sul_nastro E NON IL TESTO DELLA LABEL. Sembrava lo stesso
	# controllo e non lo e': quando il nastro e' un disegno di Bru la Label non
	# ha nessun testo - il nome e' dentro l'immagine - e il confronto avrebbe
	# detto "ha parlato qualcun altro" a ogni singola battuta, lasciando il
	# nastro fermo fuori dallo schermo per sempre.
	if not is_instance_valid(nastro) or nome_sul_nastro != nome:
		return   # nel frattempo ha gia' parlato qualcun altro
	lancia_il_nastro()

func vesti_il_nastro(id_chi: String) -> void:
	# IL NASTRO DI CHI PARLA, DISEGNATO DA BRU. Uno per personaggio, col nome
	# gia' scritto dentro: «ogni personaggio avra' il suo, te li forniro' appena
	# li avro' finiti».
	#
	#   res://art/nastri/<id>.png
	#
	# Quando c'e' non gli si scrive sopra niente - il lettering e' suo, e un
	# nome stampato sopra un nome disegnato sarebbe due nomi. Quando non c'e'
	# resta il rettangolo rosa col nome scritto dal gioco: sono quarantotto
	# personaggi e arriveranno alla spicciolata, quindi il ripiego deve reggere
	# per mesi, non per un pomeriggio.
	#
	# L'ALTEZZA LA DECIDE IL GIOCO, la larghezza il disegno. Cosi' non importa a
	# che misura Bru lo disegna - piu' grande e' meglio e' - e due nastri
	# disegnati in due giorni diversi restano alti uguali invece di ballare uno
	# rispetto all'altro.
	var disegno: Texture2D = null
	if id_chi != "":
		var percorso := "%s%s.png" % [CARTELLA_NASTRI, id_chi]
		if ResourceLoader.exists(percorso):
			disegno = load(percorso)
	applica_nastro(disegno)

func applica_nastro(disegno: Texture2D) -> void:
	# CERCARE IL DISEGNO E METTERLO SONO DUE COSE, e stanno separate per un
	# motivo pratico: la prima non si puo' provare e la seconda si'.
	#
	# Un .png scritto durante una prova dentro res:// non viene importato, e
	# load() non lo vede - quindi "il file c'e' e si carica" non e' misurabile
	# senza mettere un disegno finto nel repo. Tutto il resto pero' lo e'
	# eccome: quanto diventa alto il nastro, se il disegno lo copre, se la
	# scritta di ripiego si toglie di mezzo. Tenerle insieme voleva dire che
	# quelle verifiche misuravano il mio finto al posto del codice - e
	# infatti, rompendo apposta le due righe qui sotto, la prova restava verde.
	fondo_nastro.texture = disegno
	fondo_nastro.visible = disegno != null
	nome_nastro.visible = disegno == null
	if disegno == null:
		nastro.custom_minimum_size = nome_nastro.get_combined_minimum_size()
	else:
		var alto := float(Stile.forma("altezza_nastro"))
		var misura := disegno.get_size()
		nastro.custom_minimum_size = Vector2(alto * (misura.x / maxf(misura.y, 1.0)), alto)
	nastro.size = nastro.custom_minimum_size

func posto_del_nastro() -> Vector2:
	return Vector2(Stile.forma("cornice") * 0.6, box.position.y - nastro.size.y + 6)

func lancia_il_nastro() -> void:
	# IL NASTRO ARRIVA DA FUORI, e non compare.
	#
	# Bru l'ha disegnato in tre fotogrammi: prima e' oltre il bordo sinistro,
	# quasi in verticale; poi e' a meta' strada, ancora storto; poi e' al suo
	# posto, quasi dritto. La freccia rossa che ha tracciato sopra e' una curva,
	# non una retta - entra andando verso destra e poi piega in giu'.
	#
	# Quindi tre cose, e servono tutte e tre:
	#   1. una CURVA e non una linea: una linea retta si legge come un pannello
	#      che scorre, una curva come un oggetto lanciato;
	#   2. la ROTAZIONE che si raddrizza strada facendo: e' quello che fa
	#      leggere "pezzo di nastro appiccicato" invece di "etichetta";
	#   3. un rimbalzo in coda sull'angolo: la carta che si posa non si ferma
	#      di colpo. Mezzo grado di troppo e poi indietro, e si sente.
	var arrivo := posto_del_nastro()
	var angolo_finale := deg_to_rad(Stile.forma("inclinazione_nastro"))
	# fuori dal bordo sinistro e piu' in alto: e' da li' che entra nel disegno
	var partenza := arrivo + Vector2(-nastro.size.x - 60.0, -150.0)
	var controllo := arrivo + Vector2(nastro.size.x * 0.25, -200.0)
	# GIRA ATTORNO AL SUO LATO SINISTRO, non attorno allo spigolo in alto.
	#
	# Con il perno sull'angolo, a cinquantotto gradi il nastro schizzava su
	# nell'angolo dello schermo: ruotando attorno a un vertice tutto il corpo
	# gli si allontana. Perno a meta' del lato corto e il nastro pendola come
	# un pezzo di carta tenuto per un capo - che e' quello che e'.
	nastro.pivot_offset = Vector2(0.0, nastro.size.y * 0.5)
	nastro.position = partenza
	nastro.rotation = deg_to_rad(ANGOLO_NASTRO_IN_ARRIVO)
	if tween_nastro != null and tween_nastro.is_valid():
		tween_nastro.kill()
	tween_nastro = create_tween()
	tween_nastro.set_parallel(true)
	tween_nastro.tween_method(
			func(t: float) -> void: nastro.position = curva(partenza, controllo, arrivo, t),
			0.0, 1.0, Stile.tempo("nastro")
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# LA ROTAZIONE ARRIVA DOPO LA POSIZIONE, ed e' la differenza fra "entra
	# storto" e "entra dritto". Con la stessa curva della posizione (veloce
	# subito, lenta alla fine) a meta' volo era gia' quasi orizzontale: nei
	# fotogrammi di Bru invece resta inclinato quasi fino a terra, e si
	# raddrizza solo appoggiandosi. Quindi lenta all'inizio e con un rimbalzo in
	# coda: il nastro si posa, non atterra.
	tween_nastro.tween_property(nastro, "rotation", angolo_finale, Stile.tempo("nastro")) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

func curva(da: Vector2, verso: Vector2, a: Vector2, t: float) -> Vector2:
	# Bezier quadratica: due interpolazioni in fila, ed e' tutta la curva che
	# serve. Il punto di controllo e' dove il nastro "punterebbe" se non dovesse
	# atterrare - e' quello a dare l'arco della freccia disegnata da Bru.
	return da.lerp(verso, t).lerp(verso.lerp(a, t), t)

func prepara_icona_menu() -> void:
	# L'ICONCINA IN ALTO A SINISTRA: la faccia di chi stai giocando, e si apre
	# il menu. Bru l'ha disegnata come un quadrato rosso col muso dentro.
	var lato := Stile.forma("icona_menu")
	var bordo := Stile.forma("cornice")
	icona_menu.position = Vector2(bordo * 1.8, bordo * 1.8)
	icona_menu.custom_minimum_size = Vector2(lato, lato)
	icona_menu.size = Vector2(lato, lato)
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Stile.colore("pericolo")
	fondo.set_corner_radius_all(0)
	fondo.set_border_width_all(3)
	fondo.border_color = Stile.colore("bordo")
	for stato in ["normal", "hover", "pressed", "focus", "disabled"]:
		icona_menu.add_theme_stylebox_override(stato, fondo)
	icona_menu.tooltip_text = "Menu"
	var faccia := TextureRect.new()
	faccia.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	faccia.offset_left = 4
	faccia.offset_top = 4
	faccia.offset_right = -4
	faccia.offset_bottom = -4
	faccia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	faccia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	faccia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ritratto := ritratto_del_giocato()
	if ritratto != "":
		faccia.texture = load(ritratto)
	icona_menu.add_child(faccia)
	icona_menu.pressed.connect(func() -> void: Pausa.apri())

func ritratto_del_giocato() -> String:
	var id := GameState.id_protagonista
	var per_espressione := "res://art/personaggi/%s/neutra.png" % id
	if ResourceLoader.exists(per_espressione):
		return per_espressione
	var singolo := String(GameState.personaggi.get(id, {}).get("ritratto", ""))
	return singolo if singolo != "" and ResourceLoader.exists(singolo) else ""

func prepara_colonna_scelte() -> void:
	# Le scelte stanno appoggiate al bordo destro del quadro, sopra
	# l'illustrazione. Nel disegno cominciano circa a un sesto dell'altezza.
	var bordo := Stile.forma("cornice")
	colonna_azioni.offset_left = -Stile.forma("larghezza_scelte")
	colonna_azioni.offset_right = -bordo * 2
	colonna_azioni.offset_top = bordo * 4
	colonna_azioni.alignment = BoxContainer.ALIGNMENT_BEGIN

func _unhandled_input(evento: InputEvent) -> void:
	# la tastiera fa esattamente quello che fa il mouse: avanza
	if area_avanza.visible and evento.is_action_pressed("ui_accept"):
		_su_avanza()
		get_viewport().set_input_as_handled()

func mostra_nodo(id_nodo: String, notifiche_precedenti: Array[Dictionary] = []) -> void:
	# ENTRARE e MOSTRARE sono due cose diverse, e adesso si vede.
	#
	# IngressoNodo decide: quale nodo sia davvero, cosa cambia nel mondo per il
	# solo fatto di essere entrati, se qui scatta un agguato, e se da qui si
	# riparte per un'altra schermata. Non tocca niente di visibile.
	#
	# Se il verdetto dice di andarsene, questa funzione non disegna: non c'e'
	# niente da disegnare. Se dice di restare, disegna - e allora c'e' sempre
	# qualcosa da mostrare. Non esiste piu' una terza possibilita': era li' che
	# viveva la schermata vuota.
	# Chiamata da DENTRO la schermata (una scelta, un ritorno): qui restare un
	# istante in mezzo non e' un problema, perche' la stanza precedente e' ancora
	# sotto gli occhi finche' la transizione non l'ha portata via.
	# Dalle ALTRE schermate non si passa di qui: si passa da
	# IngressoNodo.vai_al_nodo(), che decide PRIMA che questa scena nasca.
	var esito := IngressoNodo.entra(id_nodo)
	if String(esito.scena) != "":
		Transizioni.vai(String(esito.scena))
		return
	disegna_nodo(esito, notifiche_precedenti)

func disegna_nodo(esito: Dictionary, notifiche_precedenti: Array[Dictionary]) -> void:
	# Da qui in giu' si disegna e basta: nessuna decisione, nessuna navigazione,
	# nessun modo di uscire senza aver messo qualcosa sullo schermo.
	if String(esito.get("scena", "")) != "":
		# ci si arriva solo se questa scena e' stata aperta a mano mentre il nodo
		# mandava altrove (editor): non succede nel gioco
		Transizioni.vai(String(esito.scena))
		return
	var nodo: Dictionary = esito.nodo
	nodo_in_corso = nodo
	mostra_scena_di(nodo)
	aggiorna_palco(nodo)
	aggiorna_stato()
	# i dialoghi di un posto si sentono una volta sola: da li' in avanti il nodo
	# mostra la sua "scena", cioe' com'e' quel posto adesso
	mostrando_scena = not bool(esito.prima_visita) and nodo.has("scena")
	if nodo.get("espulsione_automatica", false):
		# non c'e' niente da scegliere: il posto stesso ti rigetta fuori. Il testo
		# si legge lo stesso - questa non e' un'uscita muta, e' una scena corta
		var seq := contenuto_nodo(nodo)
		azione_a_fine_testo = Callable()
		nascondi_comandi()
		mostra_messaggio(seq[0] if not seq.is_empty() else {"tipo": "narrazione", "testo": ""})
		area_avanza.visible = false
		await get_tree().create_timer(2.2, false).timeout  # false = rispetta la pausa
		GameState.congeda_tutti_temporanei()
		Transizioni.vai(SCENA_VUOTO)
		return
	# gli appunti chiudono la coda, non la aprono: prima si vive la scena che li
	# ha fatti nascere, poi il protagonista ci ragiona sopra
	# la salita di livello viene PRIMA delle passive: e' la causa, quelle sono
	# la conseguenza, e leggerle nell'ordine opposto non si capisce
	coda_messaggi = notifiche_precedenti + notifiche_salite_di_livello() \
			+ notifiche_passive() + contenuto_nodo(nodo) + notifiche_task() + notifiche_messaggi()
	avanza_messaggio()

func contenuto_nodo(nodo: Dictionary) -> Array[Dictionary]:
	# prima visita: la scena si gioca per intero (dialoghi compresi). Dalla
	# seconda in poi resta solo la descrizione del posto, cosi' tornare
	# indietro non ti rifa' sentire le stesse battute
	var base: Array[Dictionary] = messaggi_scena(nodo) if mostrando_scena else sequenza_di(nodo)
	# e in fondo, sempre, quello che da qui si vede (vedi viste_di)
	for vista in viste_di(nodo):
		base.append(vista)
	return base

func messaggi_scena(nodo: Dictionary) -> Array[Dictionary]:
	# "scena" puo' essere una stringa (una narrazione sola) o una sequenza
	var risultato: Array[Dictionary] = []
	var scena: Variant = nodo.get("scena", "")
	if scena is Array:
		for msg in scena:
			risultato.append(msg)
	else:
		risultato.append({"tipo": "narrazione", "testo": String(scena)})
	return risultato

func viste_di(nodo: Dictionary) -> Array[Dictionary]:
	# I PUNTI DI RIFERIMENTO. Quello che da qui si VEDE, e che sta da un'altra
	# parte.
	#
	# Fino a ieri nel gioco non esisteva un solo posto che si vedesse da un
	# altro. Ogni stanza era un'isola: ci entravi, leggevi cos'era, sceglievi una
	# porta. Nessuna frase diceva mai dove ti trovavi rispetto al resto - e senza
	# quello nessuno si costruisce in testa la mappa di niente, per quanto bene
	# siano collegate le stanze.
	#
	# E' la cosa piu' economica che ci sia, perche' e' solo testo: basta che una
	# stanza ne nomini un'altra. «Dalla finestra del ballatoio si vede il vivaio,
	# laggiu' in fondo al giardino» costa una riga e fa tre mestieri insieme:
	# dice che quel posto esiste, dice dov'e', e la seconda volta che ci passi
	# dice quanta strada hai fatto.
	#
	# PERCHE' UN CAMPO E NON SEMPLICE PROSA. Per una regola sola, che e' la
	# quinta di Romero: se il giocatore lo vede, ci deve poter arrivare. Scritto
	# dentro la descrizione, un posto nominato e mai raggiungibile e' una bugia
	# che nessuno scopre; dichiarato qui col suo "verso", c'e' una prova che
	# pretende che quella stanza esista e sia raggiungibile davvero.
	#
	# Arrivano SEMPRE in fondo alla scena, mai in mezzo: prima dov'e' che sei,
	# poi cosa vedi da qui.
	var risultato: Array[Dictionary] = []
	for vista in nodo.get("vista", []):
		var testo := String(vista.get("testo", ""))
		if testo == "":
			continue
		risultato.append({"tipo": "vista", "testo": testo})
	return risultato

func sequenza_di(nodo: Dictionary) -> Array[Dictionary]:
	if nodo.has("sequenza"):
		var seq: Array[Dictionary] = []
		for msg in nodo["sequenza"]:
			seq.append(msg)
		return seq
	return [{"tipo": "narrazione", "testo": nodo.get("testo", "")}]

# --- coda dei messaggi ---

func avanza_messaggio() -> void:
	contatore_messaggi += 1
	if not coda_messaggi.is_empty():
		var msg: Dictionary = coda_messaggi.pop_front()
		if msg.has("suono"):
			# UNA BATTUTA PUO' SUONARE. Bru, sull'avviso del data pad: «qui
			# metteremo un suono che creo io tipo allert». Il nome e' quello del
			# file in res://audio/ui/: finche' non c'e', Sintesi ne fa uno
			# provvisorio, e il giorno che Bru lo registra basta copiarlo li'.
			AudioManager.interfaccia(String(msg["suono"]))
		if msg.has("flag"):
			# UN FLAG A META' SCENA. Fino a ieri una scena poteva cambiare il
			# mondo solo entrando o uscendo; una battuta no. Ma il momento in cui
			# il mondo cambia e' spesso UNA battuta precisa - «acquistato!?» - e
			# far arrivare la ricevuta venti righe prima rovina la scoperta.
			GameState.imposta_flag(String(msg["flag"]))
		attesa_messaggio = float(msg.get("attesa", 0.0))
		nascondi_comandi()
		# se questo e' l'ultimo messaggio e non c'e' nessuna transizione in
		# sospeso, appena finisce di scriversi compaiono le scelte vere
		var ultimo: bool = coda_messaggi.is_empty() and not azione_dopo_coda.is_valid() \
				and not nodo_in_corso.has("combattimento_automatico") \
				and not nodo_in_corso.has("avvio_automatico")
		azione_a_fine_testo = _apri_scelte if ultimo else Callable()
		mostra_messaggio(msg)
		area_avanza.visible = true
		return
	if azione_dopo_coda.is_valid():
		var richiamo := azione_dopo_coda
		azione_dopo_coda = Callable()
		richiamo.call()
		return
	if nodo_in_corso.has("combattimento_automatico"):
		# non c'e' nulla da scegliere: il combattimento parte da solo a fine sequenza
		avvia_combattimento_automatico(nodo_in_corso["combattimento_automatico"])
		return
	if nodo_in_corso.has("avvio_automatico"):
		# fine di un mini-evento (es. l'introduzione): parte in automatico una
		# nuova campagna, senza che il giocatore debba scegliere nulla
		avvia_automatico(nodo_in_corso["avvio_automatico"])
		return
	_apri_scelte()

func _su_avanza() -> void:
	# primo click: il testo si completa subito. Secondo click: si va avanti.
	if box.sta_scrivendo:
		box.completa()
		return
	if carta_titolo.visible:
		chiudi_carta_titolo()
		return
	avanza_messaggio()

func _su_testo_pronto() -> void:
	if attesa_messaggio > 0.0:
		# si va avanti da soli: quello che sarebbe successo a fine testo lo fa
		# comunque avanza_messaggio() quando la coda si svuota
		var quanto := attesa_messaggio
		attesa_messaggio = 0.0
		azione_a_fine_testo = Callable()
		_avanza_fra(quanto, contatore_messaggi)
		return
	if azione_a_fine_testo.is_valid():
		var richiamo := azione_a_fine_testo
		azione_a_fine_testo = Callable()
		richiamo.call()

func _avanza_fra(secondi: float, atteso: int) -> void:
	# false = il timer rispetta la pausa: aprendo ESC il conto si ferma
	await get_tree().create_timer(secondi, false).timeout
	if not is_inside_tree():
		return
	if contatore_messaggi != atteso:
		return  # il giocatore ha cliccato prima: e' gia' andato avanti da solo
	avanza_messaggio()

func _apri_scelte() -> void:
	box.nascondi_indicatore()
	area_avanza.visible = false
	aggiorna_palco(nodo_in_corso)
	ricostruisci_scelte(nodo_in_corso)
	aggiorna_dialoga()

func nascondi_comandi() -> void:
	# mentre si legge non c'e' niente da premere: i comandi tornano a coda vuota
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	bottone_dialoga.visible = false
	bottone_mappa.visible = false
	for figlio in menu_compagni.get_children():
		figlio.queue_free()

func avvia_combattimento_automatico(dati: Dictionary) -> void:
	if dati.has("salta_se_flag") and GameState.ha_flag(String(dati["salta_se_flag"])):
		# zona gia' ripulita (boss sconfitto): non ci sono piu' nemici qui
		mostra_nodo(String(dati.get("se_vinci", "")))
		return
	GameState.prepara_combattimento(dati.get("nemici", []), dati.get("se_vinci", ""),
			dati.get("se_vinci_eroe", ""), dati.get("se_perdi", ""), dati.get("se_fuggi", ""))
	Transizioni.vai(SCENA_COMBATTIMENTO)

func avvia_automatico(dati: Dictionary) -> void:
	GameState.avvia_carnivalz(String(dati.get("id_punto", "")), String(dati.get("file_eventi", "")))
	mostra_nodo(GameState.nodo_corrente)

# --- messaggi a schermo ---

func mostra_messaggio(msg: Dictionary) -> void:
	var tipo := String(msg.get("tipo", "narrazione"))
	var contenuto := sostituisci_nome(String(msg.get("testo", "")))
	if tipo == "titolo":
		GameState.registra_storico(tipo, "", contenuto)
		mostra_carta_titolo(contenuto)
		return
	if tipo == "immagine":
		GameState.registra_storico("narrazione", "", contenuto)
		mostra_carta_titolo(contenuto, String(msg.get("file", "")))
		return
	if tipo == "scritta":
		mostra_scritta_dal_buio(String(msg.get("file", "")), float(msg.get("attesa", 2.0)))
		return
	carta_titolo.visible = false
	box.visible = true
	mostra_scena_di(msg)   # la battuta puo' portarsi dietro la sua immagine
	var nome_parlante := ""
	var id_parlante := ""
	if tipo == "dialogo":
		id_parlante = String(msg.get("chi", GameState.id_protagonista))
		nome_parlante = String(GameState.personaggi.get(id_parlante, {}).get("nome", id_parlante))
		if msg.has("espr"):
			aggiorna_espressione(id_parlante, String(msg["espr"]))
		evidenzia_parlante(id_parlante)
	else:
		evidenzia_parlante("")
	GameState.registra_storico(tipo, nome_parlante, contenuto)
	box.mostra(tipo, contenuto, nome_parlante)
	aggiorna_nastro(nome_parlante, id_parlante)

func mostra_carta_titolo(contenuto: String, percorso_immagine := "") -> void:
	# il nome di un luogo non e' una riga di narrazione: si prende lo schermo,
	# resta finche' non lo si chiude, e solo dopo la scena riprende. Quello che
	# sarebbe dovuto succedere a fine testo (aprire le scelte) resta in attesa:
	# altrimenti i bottoni comparirebbero dietro il velo della carta.
	azione_dopo_titolo = azione_a_fine_testo
	azione_a_fine_testo = Callable()
	box.visible = false
	# un'illustrazione che non c'e' ancora non blocca niente: resta la didascalia,
	# e la scena si legge lo stesso. I disegni si fanno a poco a poco
	var c_e_immagine := percorso_immagine != "" and ResourceLoader.exists(percorso_immagine)
	immagine_titolo.visible = c_e_immagine
	if c_e_immagine:
		immagine_titolo.texture = load(percorso_immagine)
	testo_titolo.text = contenuto
	testo_titolo.add_theme_font_size_override("font_size",
			Stile.dimensione("corpo") if percorso_immagine != "" else Stile.dimensione("titolo"))
	testo_titolo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# UNA LARGHEZZA MINIMA CI VUOLE SEMPRE, e senza era il bug che si vedeva
	# nello screenshot: "Pianure di Redenna" scritto una lettera per riga.
	#
	# Con l'autowrap acceso, la larghezza minima di una Label collassa a quella
	# del carattere piu' largo - e' la sua dimensione "minima" nel senso letterale.
	# Dentro un CenterContainer, che dimensiona il figlio proprio sul suo minimo,
	# il risultato e' una colonna di lettere. Con l'immagine il minimo c'era
	# (760), senza no: e la carta del titolo senza immagine e' il caso normale.
	testo_titolo.custom_minimum_size = Vector2(760, 0)
	carta_titolo.visible = true
	carta_titolo.modulate.a = 0.0
	var comparsa := create_tween()
	comparsa.tween_property(carta_titolo, "modulate:a", 1.0, Stile.tempo("carta_titolo"))

func mostra_scritta_dal_buio(percorso: String, quanto_resta: float) -> void:
	# LA SCRITTA DI CARNIVALZ. Bru: «apparirà la scritta che disegnerò di
	# carnivalz, appare centrale dal buio, poi scompare piano piano e dal buio
	# troviamo il primo dialog box».
	#
	# Non e' una carta del titolo, ed e' proprio la differenza che conta: la
	# carta del titolo aspetta un click, questa NO. Un titolo di testa che
	# chiede il permesso per andarsene non e' un titolo di testa, e' un
	# messaggio. Compare, resta il tempo che deve, se ne va da sola.
	#
	# E dietro c'e' il nero, non la scena: "dal buio" vuol dire che prima di
	# lei non c'e' niente e dopo di lei non c'e' niente, e la prima cosa che si
	# rivede e' il box che parla.
	azione_dopo_titolo = azione_a_fine_testo
	azione_a_fine_testo = Callable()
	box.visible = false
	nastro.visible = false
	nascondi_comandi()
	area_avanza.visible = false
	testo_titolo.text = ""
	var c_e := percorso != "" and ResourceLoader.exists(percorso)
	immagine_titolo.visible = c_e
	if c_e:
		immagine_titolo.texture = load(percorso)
	else:
		# finche' il disegno non c'e', il nome scritto: la scena esiste lo
		# stesso e si puo' provare il ritmo, che e' l'unica cosa che conta qui
		testo_titolo.text = "CARNIVALZ"
		testo_titolo.custom_minimum_size = Vector2(760, 0)
		testo_titolo.add_theme_font_size_override("font_size", Stile.dimensione("titolo") * 2)
	carta_titolo.visible = true
	carta_titolo.modulate.a = 0.0
	var velo: ColorRect = carta_titolo.get_node("VeloTitolo")
	velo.color = Color(Stile.colore("velo"), 1.0)   # buio pieno, non un velo
	var durata := Stile.tempo("scritta_dal_buio")
	var passaggio := create_tween()
	passaggio.tween_property(carta_titolo, "modulate:a", 1.0, durata)
	passaggio.tween_interval(maxf(quanto_resta, 0.0))
	passaggio.tween_property(carta_titolo, "modulate:a", 0.0, durata)
	passaggio.finished.connect(func() -> void:
		if not is_instance_valid(self):
			return
		velo.color = Color(Stile.colore("velo"), 0.82)   # com'era per le altre carte
		_dopo_carta_titolo())

func chiudi_carta_titolo() -> void:
	var uscita := create_tween()
	uscita.tween_property(carta_titolo, "modulate:a", 0.0, Stile.tempo("carta_titolo") * 0.6)
	uscita.finished.connect(_dopo_carta_titolo)

func _dopo_carta_titolo() -> void:
	carta_titolo.visible = false
	if azione_dopo_titolo.is_valid():
		var richiamo := azione_dopo_titolo
		azione_dopo_titolo = Callable()
		richiamo.call()
		return
	avanza_messaggio()

func sostituisci_nome(testo: String) -> String:
	# permette a narrazione/dialogo di citare il nome scelto dal giocatore
	# per il protagonista, es. "Benvenuto, {nome}." (distinto dal "%s" di
	# dialoghi.json, gia' risolto altrove per i nomi dei compagni)
	var risultato := testo
	if risultato.find("{nome}") != -1:
		var nome := String(GameState.personaggi.get(GameState.id_protagonista, {}).get("nome", "Anonimo"))
		risultato = risultato.replace("{nome}", nome)
	return Testi.accorda(risultato, GameState.sesso_protagonista)

# --- scelte ---

func ricostruisci_scelte(nodo: Dictionary) -> void:
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	var primo: Button = null
	for scelta in nodo.get("scelte", []):
		if scelta.has("richiede") and not GameState.party_ha_abilita(scelta["richiede"]):
			continue  # requisito non soddisfatto: la scelta non appare proprio
		if scelta.has("richiede_legame") and GameState.legame < int(scelta["richiede_legame"]):
			continue  # evento raro: serve un legame abbastanza coltivato
		if scelta.has("richiede_ospite") and scelta["richiede_ospite"] not in GameState.ospiti:
			continue
		if scelta.has("richiede_compagno") and scelta["richiede_compagno"] not in GameState.party:
			continue  # serve un alleato specifico in squadra (es. un compagno temporaneo reclutato)
		if scelta.has("richiede_flag") and not GameState.ha_flag(scelta["richiede_flag"]):
			continue
		if scelta.has("richiede_non_flag") and GameState.ha_flag(scelta["richiede_non_flag"]):
			continue
		if scelta.has("richiede_oggetti") and not GameState.possiede_tutti(scelta["richiede_oggetti"]):
			continue  # servono tutti i pezzi (es. la Fontana)
		if scelta.get("piazza_proiettore", false) \
				and GameState.proiettore_qui() == GameState.nodo_corrente:
			continue  # e' gia' qui: piantarlo di nuovo non farebbe niente
		if scelta.has("una_tantum") and GameState.ha_flag(scelta["una_tantum"]):
			continue  # gia' raccolto/fatto: la scelta non torna
		if int(scelta.get("tazo", 0)) < 0 and GameState.tazo < -int(scelta.get("tazo", 0)):
			continue  # non puoi pagare cio' che non hai
		# IL KARMA DECIDE QUALE DELLE DUE TI COMPARE. Bru: «ci sara' magari solo
		# 1 o l'altra, a seconda del tuo karma, e in alcune anche entrambe».
		#
		# Servono tutte e quattro le forme, non due. Con i soli minimi si puo'
		# dire "questa la vede chi e' stato eroe almeno tre volte", ma non si
		# puo' NASCONDERE niente a nessuno - e "solo l'opzione da villain,
		# perche' ormai sei quello" e' esattamente una cosa da nascondere.
		if scelta.has("richiede_eroe") and GameState.scelte_eroe < int(scelta["richiede_eroe"]):
			continue  # la puo' dire solo chi si e' comportato da eroe abbastanza volte
		if scelta.has("richiede_malvagio") and GameState.scelte_malvagie < int(scelta["richiede_malvagio"]):
			continue
		if scelta.has("richiede_eroe_max") and GameState.scelte_eroe > int(scelta["richiede_eroe_max"]):
			continue  # chi e' stato troppo eroe questa non se la sente piu' dire
		if scelta.has("richiede_malvagio_max") and GameState.scelte_malvagie > int(scelta["richiede_malvagio_max"]):
			continue
		var bottone := bottone_scelta(String(scelta.get("testo", "…")),
				String(scelta.get("genere", "")))
		segna_destinazione(bottone, scelta)
		bottone.pressed.connect(_su_scelta.bind(scelta))
		contenitore_scelte.add_child(riga_di_scelta(bottone, scelta))
		if primo == null:
			primo = bottone
	if mostrando_scena:
		# la descrizione del posto resta sempre a portata di mano: dopo qualche
		# scelta il box ha gia' cambiato testo, e riguardarsi intorno e' gratis
		var bottone_osserva := bottone_scelta("Osserva la scena")
		bottone_osserva.pressed.connect(_su_osserva)
		contenitore_scelte.add_child(bottone_osserva)
		if primo == null:
			primo = bottone_osserva
	if primo != null:
		# la prima scelta parte gia' selezionata: si puo' giocare da tastiera
		primo.grab_focus()

func bottone_scelta(testo: String, genere := "") -> Button:
	var bottone := Button.new()
	bottone.text = testo
	Stile.scelta(bottone, genere)
	return bottone

func tempo_della_scelta(scelta: Dictionary) -> float:
	# QUANTO DURA UNA SCELTA A TEMPO.
	#
	# Bru: «il tempo dipende dal dialogo, quando vedro' tutti i dialoghi daro' io
	# il tempo su un file come abbiamo fatto per tutto il resto. Per adesso
	# randomizzalo, minimo 3 secondi massimo 7».
	#
	# Quindi: se la scena lo dice, vince la scena - sempre, e senza che io debba
	# tornare qui il giorno in cui quel file esiste. Se non lo dice, e la scelta
	# e' da eroe o da villain, il tempo se lo tira il dado. Il caso e' un
	# ripiego dichiarato, non una regola: sta scritto in data/regole.json con
	# dentro le sue parole, cosi' quando i tempi veri arrivano si vede subito
	# cosa stava tappando il buco.
	if scelta.has("tempo"):
		return float(scelta["tempo"])
	var genere := String(scelta.get("genere", ""))
	if genere != "eroe" and genere != "malvagio":
		return 0.0
	var dati: Dictionary = GameState.regole.get("scelta_a_tempo", {})
	# dal dado seedato della partita, non da randf(): due partite con lo stesso
	# seme devono dare gli stessi secondi, o non si puo' riprodurre un guaio
	return GameState.rng.randf_range(
			float(dati.get("secondi_minimo", 3.0)),
			float(dati.get("secondi_massimo", 7.0)))

func riga_di_scelta(bottone: Button, scelta: Dictionary) -> Control:
	# UNA SCELTA A TEMPO E' UNA SCELTA CON UN OROLOGIO ATTACCATO.
	#
	# Bru: «quelle eroe e villain sono a tempo, manchi timing non recuperi». Nel
	# disegno l'orologio e' appeso storto a sinistra del riquadro nero.
	#
	# Le due cose restano separate: il "genere" (eroe, malvagio) dice di che
	# razza e' la scelta e quindi di che colore; "tempo" dice che scade. Sono
	# campi indipendenti perche' non e' detto che le due cose vadano sempre
	# insieme - una decisione da villain puo' aspettare quanto vuole, e una
	# scelta qualunque puo' scadere lo stesso ("scappa adesso o mai piu'").
	var secondi := tempo_della_scelta(scelta)
	if secondi <= 0.0:
		return bottone
	var riga := HBoxContainer.new()
	riga.alignment = BoxContainer.ALIGNMENT_END
	riga.size_flags_horizontal = Control.SIZE_SHRINK_END
	riga.add_theme_constant_override("separation", 10)
	var orologio: Control = load("res://scripts/Orologio.gd").new()
	riga.add_child(orologio)
	riga.add_child(bottone)
	# scaduta: si rompe LEI, e le altre restano. "Non recuperi" vuol dire che
	# quella strada si e' chiusa, non che hai perso il turno - se sparisse tutto
	# il giocatore non capirebbe di aver perso qualcosa, capirebbe di aver
	# aspettato troppo e basta
	orologio.scaduto.connect(func() -> void: rompi_la_scelta(riga, bottone))
	# inclinazioni alternate: nel disegno le due cipolle pendono da due parti
	var inclinazione := 12.0 if orologi_appesi % 2 == 0 else -14.0
	orologi_appesi += 1
	orologio.avvia(secondi, inclinazione)
	return riga

func rompi_la_scelta(riga: Control, bottone: Button) -> void:
	# SCADUTA, SI FRANTUMA COME VETRO. Bru: «le opzioni hero o evil si frantumano
	# come se fosse vetro e scompaiono, i pezzi devono cadere e gradualmente
	# svanire verso il trasparente».
	#
	# L'ordine conta, ed e' controintuitivo: prima si mettono i frantumi al posto
	# della riga, POI si toglie la riga. Facendo il contrario - via la riga e poi
	# i frantumi - il contenitore riordinerebbe le scelte rimaste un fotogramma
	# prima che il vetro compaia, e le schegge partirebbero da dove la scelta non
	# e' piu': si romperebbe il posto sbagliato.
	if not is_instance_valid(riga):
		return
	var era_selezionata: bool = is_instance_valid(bottone) and bottone.has_focus()
	# MORTA SUBITO, ROTTA DOPO. Fra lo scadere del tempo e il vetro che si
	# frantuma passano una manciata di fotogrammi - la fotografia del pezzo che
	# si rompe si prende alla fine di un disegno, non a meta'. In quei fotogrammi
	# l'opzione era ancora li' e ancora cliccabile: si poteva prendere una
	# scelta scaduta, ed e' esattamente quello che "non recuperi" non deve
	# permettere. Il tempo e' finito adesso, non quando l'animazione lo dice.
	if is_instance_valid(bottone):
		bottone.disabled = true
		bottone.focus_mode = Control.FOCUS_NONE
	var vetro: Control = load("res://scripts/Frantumi.gd").new()
	# fuori dal contenitore delle scelte, o verrebbe messo in colonna con le
	# altre e riordinato insieme a loro: i frantumi non sono una scelta, sono
	# quello che resta di una
	add_child(vetro)
	await vetro.frantuma(riga)
	if is_instance_valid(riga):
		riga.queue_free()
	if era_selezionata:
		# il fuoco non deve restare su una cosa che non c'e' piu', o da tastiera
		# si continua a premere invio nel vuoto
		sposta_fuoco_sulla_prima_scelta()

func sposta_fuoco_sulla_prima_scelta() -> void:
	for figlio in contenitore_scelte.get_children():
		var bottone := primo_bottone_in(figlio)
		if bottone != null:
			bottone.grab_focus()
			return

func primo_bottone_in(nodo: Node) -> Button:
	if nodo is Button:
		return nodo
	for figlio in nodo.get_children():
		var trovato := primo_bottone_in(figlio)
		if trovato != null:
			return trovato
	return null

func segna_destinazione(bottone: Button, scelta: Dictionary) -> void:
	# Quando da una stanza si va in piu' posti, quelli dove non sei ancora stato
	# si vedono: pallino e ottone. Vale solo per le scelte che portano davvero
	# altrove ("vai") - una battuta o un'azione non e' un posto, e colorarla
	# racconterebbe una bugia.
	#
	# Non e' uno spoiler: dice che quella porta non l'hai aperta, non cosa c'e'
	# dietro. Serve a non rifare tre volte lo stesso corridoio cercando l'unica
	# via che manca.
	if not scelta.has("vai"):
		return
	var destinazione := String(scelta["vai"])
	if destinazione == "" or destinazione == GameState.nodo_corrente:
		return
	Stile.segna_visita(bottone, Stile.VISITA_VISTO \
			if destinazione in GameState.nodi_visitati else Stile.VISITA_NUOVO)

func notifiche_task() -> Array[Dictionary]:
	# un appunto nuovo non e' una riga di sistema: e' il protagonista che si
	# ferma un attimo e mette a fuoco dove deve andare. Quindi una notifica
	# sola a fare da intestazione, e poi il pensiero vero come narrazione.
	var righe: Array[Dictionary] = []
	if GameState.task_da_notificare.is_empty():
		return righe
	var quanti := GameState.task_da_notificare.size()
	var intestazione := "%s si è aggiornato." % GameState.nome_diario()
	if quanti > 1:
		intestazione = "%s si è aggiornato: %d nuovi appunti." % [GameState.nome_diario(), quanti]
	righe.append({"tipo": "notifica", "testo": intestazione})
	# quando ne arrivano tanti insieme (la fine del tutorial ne apre quattro)
	# non si scaricano tutti addosso al giocatore: due si leggono qui, il
	# resto lo trova nel Diario quando decide da dove cominciare
	var letti := 0
	for id_task in GameState.task_da_notificare:
		if letti >= APPUNTI_LETTI_A_VOCE:
			righe.append({"tipo": "narrazione",
					"testo": "Il resto me lo sono segnato. Ci ripenso quando decido da dove cominciare."})
			break
		var voce := GameState.dati_task(id_task)
		var testo := String(voce.get("testo", ""))
		if testo != "":
			righe.append({"tipo": "narrazione", "testo": testo})
			letti += 1
	GameState.task_da_notificare.clear()
	return righe

func notifiche_messaggi() -> Array[Dictionary]:
	# UN MESSAGGIO CHE ARRIVA IN SILENZIO NON E' ARRIVATO.
	#
	# messaggi_da_notificare esisteva gia' - lo riempivo a ogni messaggio nuovo -
	# ma non lo leggeva nessuno: mezza funzione, cioe' una trappola. I 3000 tazo
	# di benvenuto si vedevano solo perche' la scena del data pad se li scriveva
	# a mano; qualunque altro messaggio sarebbe arrivato senza che niente lo
	# dicesse, e il giocatore non ha nessun motivo di aprire una sezione che non
	# lo ha mai chiamato.
	#
	# Qui non si legge il messaggio: si dice che c'e'. Leggerlo e' un gesto che
	# spetta al giocatore, e la sezione Messaggi porta il conto dei non letti.
	var righe: Array[Dictionary] = []
	if GameState.messaggi_da_notificare.is_empty():
		return righe
	var quanti := GameState.messaggi_da_notificare.size()
	if quanti == 1:
		var voce := GameState.dati_messaggio(String(GameState.messaggi_da_notificare[0]))
		righe.append({"tipo": "notifica", "testo": "%s: nuovo messaggio — %s"
				% [GameState.nome_diario(), String(voce.get("oggetto", "senza oggetto"))]})
	else:
		righe.append({"tipo": "notifica", "testo": "%s: %d nuovi messaggi."
				% [GameState.nome_diario(), quanti]})
	GameState.messaggi_da_notificare.clear()
	return righe

func notifiche_salite_di_livello() -> Array[Dictionary]:
	# SALIRE DI LIVELLO SI DEVE VEDERE, e si deve capire cosa e' cambiato.
	#
	# In Carnivalz le statistiche non salgono col livello: salgono con quello
	# che hai fatto, e diventano punti proprio qui. Quindi questo e' l'unico
	# momento in cui il giocatore scopre a cosa e' servito giocare come ha
	# giocato - se ha incassato molto, se ha parato, se ha studiato. Prima dei
	# numeri cambiavano da qualche parte e nessuno lo diceva: il livello saliva
	# e il gioco taceva.
	var righe: Array[Dictionary] = []
	for salita in GameState.salite_di_livello:
		righe.append({"tipo": "notifica",
				"testo": "[b]Livello %d.[/b]" % int(salita.get("livello", 0))})
		var cresciute: Array = salita.get("stat", [])
		if cresciute.is_empty():
			righe.append({"tipo": "notifica",
					"testo": "Nessuna statistica è cresciuta: crescono con quello che fai, e in quest'ultimo tratto non hai fatto abbastanza di niente."})
		else:
			var pezzi: Array[String] = []
			for voce in cresciute:
				pezzi.append("%s %d → %d (+%d)" % [String(voce.get("nome", "")),
						int(voce.get("prima", 0)), int(voce.get("dopo", 0)),
						int(voce.get("dopo", 0)) - int(voce.get("prima", 0))])
			righe.append({"tipo": "notifica", "testo": "\n".join(pezzi)})
		var punti := int(salita.get("punti_abilita", 0))
		if punti > 0:
			righe.append({"tipo": "notifica",
					"testo": "Hai %d %s da spendere sulle abilità." % [punti,
					"punto" if punti == 1 else "punti"]})
	GameState.salite_di_livello.clear()
	return righe

func notifiche_passive() -> Array[Dictionary]:
	# abilita' passive sbloccate salendo di livello: si annunciano appena si
	# torna a una schermata di eventi, insieme alle altre notifiche
	var righe: Array[Dictionary] = []
	for nome in GameState.passive_da_notificare:
		righe.append({"tipo": "notifica", "testo": "Nuova abilità passiva: %s" % nome})
	GameState.passive_da_notificare.clear()
	return righe

func pickup(id_oggetto: String) -> Array[Dictionary]:
	# notifiche sequenziali: "hai raccolto X" e' un messaggio a se',
	# ordinato insieme agli altri, non un testo mescolato o un elemento minore.
	# Per gli oggetti chiave (di solito indizi/lore, come le pagine di
	# giornale di Meridia) la descrizione diventa una seconda pagina.
	var dati := GameState.dati_oggetto(id_oggetto)
	var nome: String = String(dati.get("nome", id_oggetto))
	if not GameState.aggiungi_oggetto(id_oggetto):
		return [{"tipo": "notifica", "testo": "%s: la sacca è piena, non c'è posto per lui." % nome}]
	var tipo := String(dati.get("tipo", "consumabile"))
	var luogo := "nella sacca"
	match tipo:
		"collezionabile":
			luogo = "tra i collezionabili"
		"chiave":
			luogo = "tra gli oggetti chiave"
	var risultato: Array[Dictionary] = [{"tipo": "notifica", "testo": "Hai raccolto: %s (%s)." % [nome, luogo]}]
	if tipo == "chiave":
		risultato.append({"tipo": "narrazione", "testo": String(dati.get("descrizione", ""))})
	return risultato

# --- palco dei ritratti ---

func aggiorna_palco(nodo: Dictionary) -> void:
	# IL PALCO PUO' ESSERE VUOTO, e ci vuole un modo di dirlo.
	#
	# Di suo questa schermata mette sempre il protagonista a sinistra, perche'
	# quasi sempre e' lui che sta vivendo la scena. Ma l'introduzione parla
	# dell'universo e delle creature che lo abitano - lui li' dentro non c'e'
	# ancora - e vederlo in piedi accanto a "nell'universo la vita prende varie
	# forme" lo trasforma in uno che sta guardando un documentario.
	if String(nodo.get("palco", "")) == "nessuno":
		slot_sinistra.visible = false
		slot_centro.visible = false
		slot_destra.visible = false
		return
	if nodo.has("centro"):
		slot_sinistra.visible = false
		slot_destra.visible = false
		slot_centro.visible = true
		mostra_slot(slot_centro, nodo["centro"], nodo.get("espr_centro", ""))
		return
	slot_centro.visible = false
	slot_sinistra.visible = true
	mostra_slot(slot_sinistra, nodo.get("sinistra", GameState.id_protagonista), nodo.get("espr_sinistra", ""))
	slot_destra.visible = nodo.has("destra")
	if nodo.has("destra"):
		mostra_slot(slot_destra, nodo["destra"], nodo.get("espr_destra", ""))

func evidenzia_parlante(id_personaggio: String) -> void:
	# chi parla resta pieno, gli altri si attenuano: si capisce a colpo d'occhio
	# di chi e' la voce nel box, senza doverne leggere il nome
	for slot in [slot_sinistra, slot_centro, slot_destra]:
		if not slot.visible:
			continue
		var suo: bool = id_personaggio == "" or String(slot.id_mostrato) == id_personaggio
		slot.imposta_attenuato(not suo)

func aggiorna_espressione(id_personaggio: String, espressione: String) -> void:
	# OGNI BATTUTA PUO' AVERE LA SUA FACCIA.
	#
	# "espr" su un messaggio cambia il ritratto di chi sta parlando, su qualunque
	# lato del palco si trovi. E' quello che rende una conversazione una scena e
	# non una sequenza di didascalie: la stessa persona dice tre righe e cambia
	# espressione tre volte, come farebbe un attore.
	#
	# Prima funzionava SOLO nelle scene a un personaggio solo ("centro"): in un
	# dialogo a due il campo veniva letto e buttato via senza un errore, e chi
	# scriveva i dialoghi non aveva modo di accorgersene se non guardando.
	#
	# Chi non ha "espr" tiene la faccia che aveva: un'espressione dura finche'
	# qualcuno non la cambia, come in scena.
	if id_personaggio == "" or espressione == "":
		return
	for slot in [slot_sinistra, slot_centro, slot_destra]:
		if slot.visible and String(slot.id_mostrato) == id_personaggio:
			slot.mostra(id_personaggio, 0, espressione)

func mostra_slot(slot, valore: Variant, espr_nodo: String) -> void:
	# valore: id stringa, oppure {id, espr}. L'espressione può anche venire
	# dalla chiave espr_<lato> del nodo.
	var id_personaggio := ""
	var espressione := "neutra"
	if valore is Dictionary:
		id_personaggio = String(valore.get("id", ""))
		espressione = String(valore.get("espr", "neutra"))
	else:
		id_personaggio = String(valore)
	if espr_nodo != "":
		espressione = espr_nodo
	slot.mostra(id_personaggio, 0, espressione)

# --- azioni del giocatore ---

func _su_osserva() -> void:
	# guardarsi intorno non e' una scelta: non consuma niente, non muove il
	# legame, non fa scattare agguati. Ridescrive e basta.
	var da_mostrare: Array[Dictionary] = messaggi_scena(nodo_in_corso)
	# guardarsi intorno vuol dire anche guardare LONTANO: se da qui si vede
	# qualcosa, riguardarsi intorno deve farlo rivedere
	for vista in viste_di(nodo_in_corso):
		da_mostrare.append(vista)
	coda_messaggi = da_mostrare
	avanza_messaggio()

func _su_scelta(scelta: Dictionary) -> void:
	GameState.modifica_legame(-1)  # il legame respira: cala se non lo curi
	# IL CONTO DI CHI SEI. Due contatori separati, non un asse solo: qui c'e'
	# soltanto quante volte hai scelto in un modo e quante nell'altro. Cosa
	# voglia dire lo decidono le scene, chiedendo "richiede_eroe" o
	# "richiede_malvagio" - qui non c'e' nessun giudizio scritto nel codice.
	match String(scelta.get("genere", "")):
		"eroe": GameState.scelte_eroe += 1
		"malvagio": GameState.scelte_malvagie += 1
	if scelta.has("flag"):
		GameState.imposta_flag(scelta["flag"])
	if scelta.has("una_tantum"):
		GameState.imposta_flag(scelta["una_tantum"])
	if scelta.has("recluta"):
		GameState.recluta(scelta["recluta"])
	var notifiche: Array[Dictionary] = []
	if scelta.get("piazza_proiettore", false):
		# il proiettore e' uno solo: piantarlo qui lo toglie da dove stava
		var dove_stava := GameState.proiettore_qui()
		GameState.piazza_proiettore(GameState.nodo_corrente)
		notifiche.append({"tipo": "notifica", "testo":
				"Proiettore piantato. Da qualunque punto della zona, la mappa riporta qui."
				if dove_stava == "" else
				"Proiettore spostato qui. Dove stava prima non c'e' piu'."})
	# "oggetto" ne da' uno, "oggetti" ne da' quanti se ne scrivono - anche lo
	# stesso due volte, per un ritrovamento che vale il doppio. Le due forme
	# convivono: i contenuti gia' scritti usano la prima e non vanno ritoccati.
	for id_oggetto in IngressoNodo.lista_id(scelta.get("oggetto", scelta.get("oggetti", []))):
		notifiche.append_array(pickup(id_oggetto))
	if scelta.has("lascia"):
		GameState.rimuovi_classe(scelta["lascia"])
	if scelta.has("ospite"):
		GameState.aggiungi_ospite(scelta["ospite"])
	if scelta.has("recluta_temporaneo"):
		GameState.recluta_temporaneo(scelta["recluta_temporaneo"], int(scelta.get("livello_alleato", 1)))
	if scelta.has("congeda"):
		GameState.congeda(scelta["congeda"])
	if scelta.has("tazo"):
		var quantita := int(scelta["tazo"])
		GameState.modifica_tazo(quantita)
		if quantita > 0:
			notifiche.append({"tipo": "notifica", "testo": "Hai ottenuto %d Tazo." % quantita})
	if scelta.has("sblocca_negozio"):
		GameState.sblocca_negozio(scelta["sblocca_negozio"])
	IngressoNodo.applica_task_di(scelta)
	if scelta.has("stress"):
		for id_classe in GameState.party:
			GameState.modifica_stress(id_classe, int(scelta["stress"]))
	if scelta.has("legame"):
		GameState.modifica_legame(int(scelta["legame"]))
	if scelta.has("combatti"):
		GameState.prepara_combattimento(scelta["combatti"], scelta.get("se_vinci", ""),
				scelta.get("se_vinci_eroe", ""), scelta.get("se_perdi", ""), scelta.get("se_fuggi", ""))
		Transizioni.vai(SCENA_COMBATTIMENTO)
		return
	if scelta.get("torna_vuoto", false):
		# uscita da uno squarcio: lo stato resta, ma gli alleati temporanei
		# non ti seguono fuori
		GameState.congeda_tutti_temporanei()
		Transizioni.vai(SCENA_VUOTO)
		return
	if scelta.get("reset", false):
		# fine campagna: si rientra alla Sede, che e' anche dove il gioco salva
		GameState.reset_campagna()
		Transizioni.vai(SCENA_SEDE)
		return
	if scelta.get("game_over", false):
		# "Riprendi dall'ultimo salvataggio" ricarica davvero il file della
		# partita: si torna com'eri, oggetti compresi. Se un salvataggio non
		# c'e' ancora (sei nel tutorial) si rifa' la zona, che e' l'unica cosa
		# sensata: da fuori il tutorial non ci si rientra piu'.
		match GameState.game_over():
			"zona": Transizioni.vai(SCENA_EVENTI)
			_: Transizioni.vai(SCENA_SEDE)
		return
	if scelta.get("torna_a_mappa", false):
		# mappa dungeon di zona: si torna li' a scegliere la prossima stanza,
		# invece di proseguire dritti verso un altro nodo
		Transizioni.vai(SCENA_MAPPA_ZONA)
		return
	if scelta.has("vai"):
		mostra_nodo(scelta["vai"], notifiche)
	elif not notifiche.is_empty():
		# si resta sullo stesso nodo: si mostrano solo le notifiche in coda
		coda_messaggi = notifiche
		avanza_messaggio()

func aggiorna_dialoga() -> void:
	# senza compagni non c'e' nessuno con cui parlare: il bottone sparisce
	bottone_dialoga.visible = GameState.party.size() > 1
	# "Mappa" compare solo dentro la sezione esplorabile della zona
	bottone_mappa.visible = GameState.stanza_nella_mappa(GameState.nodo_corrente)
	for figlio in menu_compagni.get_children():
		figlio.queue_free()

func _su_dialoga() -> void:
	for figlio in menu_compagni.get_children():
		figlio.queue_free()
	# se due compagni presenti stanno discutendo tra loro in questo punto,
	# l'opzione per assistere (e mediare) compare prima delle chiacchiere singole
	var conversazione: Dictionary = GameState.conversazioni.get(GameState.nodo_corrente, {})
	var tra: Array = conversazione.get("tra", [])
	var conv_gia_vista: bool = conversazione.has("una_tantum") and GameState.ha_flag(conversazione["una_tantum"])
	if not conversazione.is_empty() and not conv_gia_vista and tra.size() == 2 \
			and tra[0] in GameState.party and tra[1] in GameState.party:
		var nome_a: String = String(GameState.classi.get(tra[0], {}).get("nome", tra[0]))
		var nome_b: String = String(GameState.classi.get(tra[1], {}).get("nome", tra[1]))
		var bottone_conv := bottone_scelta("%s e %s stanno parlando..." % [nome_a, nome_b])
		bottone_conv.pressed.connect(_su_conversazione.bind(conversazione))
		menu_compagni.add_child(bottone_conv)
	for id_classe in GameState.party:
		if id_classe == GameState.id_protagonista:
			continue
		var bottone := bottone_scelta(String(GameState.classi.get(id_classe, {}).get("nome", id_classe)))
		bottone.pressed.connect(_su_compagno.bind(id_classe))
		menu_compagni.add_child(bottone)

func _su_conversazione(conversazione: Dictionary) -> void:
	for figlio in menu_compagni.get_children():
		figlio.queue_free()
	var tra: Array = conversazione.get("tra", [])
	slot_centro.visible = false
	slot_sinistra.visible = true
	slot_destra.visible = true
	mostra_slot(slot_sinistra, tra[0], "")
	mostra_slot(slot_destra, tra[1], "")
	if conversazione.has("flag"):
		GameState.imposta_flag(conversazione["flag"])
	if conversazione.has("una_tantum"):
		GameState.imposta_flag(conversazione["una_tantum"])
	IngressoNodo.applica_task_di(conversazione)
	coda_messaggi = sequenza_di(conversazione) + notifiche_task() + notifiche_messaggi()
	azione_dopo_coda = _mostra_mediazione.bind(conversazione) if conversazione.has("mediazione") else Callable()
	avanza_messaggio()

func _mostra_mediazione(conversazione: Dictionary) -> void:
	# il giocatore puo' intervenire nella discussione: alcune opzioni sono
	# sbloccate solo se ha in sacca l'oggetto giusto per dare peso alle sue parole
	var mediazione: Dictionary = conversazione.get("mediazione", {})
	nascondi_comandi()
	azione_a_fine_testo = _opzioni_mediazione.bind(mediazione)
	box.mostra("narrazione", String(mediazione.get("testo", "Puoi intervenire.")), "")
	area_avanza.visible = false

func _opzioni_mediazione(mediazione: Dictionary) -> void:
	box.nascondi_indicatore()
	var primo: Button = null
	for opzione in mediazione.get("opzioni", []):
		if opzione.has("richiede_oggetto") and not GameState.possiede_oggetto(opzione["richiede_oggetto"]):
			continue
		var bottone := bottone_scelta(String(opzione.get("testo", "…")))
		bottone.pressed.connect(_su_mediazione.bind(opzione))
		contenitore_scelte.add_child(bottone)
		if primo == null:
			primo = bottone
	if primo != null:
		primo.grab_focus()

func _su_mediazione(opzione: Dictionary) -> void:
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	if opzione.has("legame"):
		GameState.modifica_legame(int(opzione["legame"]))
	coda_messaggi = []
	if opzione.has("battuta"):
		# cio' che dice Anonimo e' una battuta vera, non l'etichetta del bottone:
		# compare come pagina di dialogo a se', mai nascosta dentro la scelta
		coda_messaggi.append({"tipo": "dialogo", "chi": GameState.id_protagonista, "testo": String(opzione["battuta"])})
	if opzione.has("risposta"):
		var risposta: Dictionary = opzione["risposta"]
		coda_messaggi.append({"tipo": "dialogo", "chi": String(risposta.get("chi", "")), "testo": String(risposta.get("testo", ""))})
	avanza_messaggio()

func _su_compagno(id_classe: String) -> void:
	for figlio in menu_compagni.get_children():
		figlio.queue_free()
	slot_sinistra.visible = false
	slot_destra.visible = false
	slot_centro.visible = true
	mostra_slot(slot_centro, id_classe, "")
	var nome: String = String(GameState.classi.get(id_classe, {}).get("nome", id_classe))
	var voce: Dictionary = GameState.dialoghi.get(GameState.nodo_corrente, {})
	var gia_detta: bool = voce.has("una_tantum") and GameState.ha_flag(voce["una_tantum"])
	if voce.is_empty() or gia_detta:
		coda_messaggi = [{"tipo": "narrazione", "testo": "%s non ha altro da dirti, qui." % nome}]
	else:
		# le narrazioni sono scritte in terza persona col nome del compagno da
		# sostituire nel "%s"; i "dialogo" senza "chi" sono la battuta del
		# compagno con cui stai parlando in quel momento (dinamico, non fisso)
		coda_messaggi = []
		for msg in sequenza_di(voce):
			var testo_msg := String(msg.get("testo", ""))
			if String(msg.get("tipo", "narrazione")) == "dialogo":
				coda_messaggi.append({"tipo": "dialogo", "chi": msg.get("chi", id_classe), "testo": testo_msg})
			else:
				coda_messaggi.append({"tipo": "narrazione", "testo": testo_msg % nome if testo_msg.find("%s") != -1 else testo_msg})
		if voce.has("flag"):
			GameState.imposta_flag(voce["flag"])
		if voce.has("una_tantum"):
			GameState.imposta_flag(voce["una_tantum"])
		IngressoNodo.applica_task_di(voce)
		coda_messaggi += notifiche_task() + notifiche_messaggi()
	avanza_messaggio()
	# la battuta puo' aver sbloccato una scelta gated da richiede_flag: la
	# prossima volta che la coda si svuota, ricostruisci_scelte() la rilegge

# --- barra di stato ---

func aggiorna_stato() -> void:
	var nomi: Array[String] = []
	for id_classe in GameState.party:
		nomi.append(String(GameState.classi.get(id_classe, {}).get("nome", id_classe)))
	etichetta_party.text = ", ".join(nomi) if not nomi.is_empty() else "solo tu"
	etichetta_risorse.text = "Lv %d   ·   Tazo %d   ·   Sacca %d/%d   ·   Legame %d" % [
		GameState.livello_di(GameState.id_protagonista), GameState.tazo,
		GameState.sacca.size(), int(GameState.regole.get("sacca_massima", 20)), GameState.legame,
	]
