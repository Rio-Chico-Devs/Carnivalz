class_name ArenaCombattimento
extends RefCounted

# Lo spazio in cui succede lo scontro.
#
# Finora era un rettangolo di un colore solo, lo stesso per ogni creatura del
# gioco: si combatteva il primo goblin e l'ultimo boss dentro la stessa identica
# stanza vuota. In un gioco senza un solo disegno - e Carnivalz oggi non ne ha
# nessuno - quel rettangolo e' TUTTO lo sfondo che esiste, e sprecarlo su un
# grigio piatto e' buttare via l'unico spazio disponibile.
#
# Due cose, e nessuna delle due ha bisogno che qualcuno disegni niente:
#
#   LA TINTA. Il fondo prende una traccia del colore del tipo della creatura che
#   hai davanti (i cinque di tipi.json). Poca: non e' un cambio di scena, e' una
#   temperatura. Combattere una cosa Tetra e combattere una cosa di Natura
#   smettono di somigliarsi, e - senza una riga di spiegazione - il tipo
#   comincia a essere qualcosa che si respira prima ancora di studiarlo.
#
#   IL VELO. Quando la squadra sta per cadere i bordi dello schermo si
#   chiudono. E' il modo piu' vecchio del mondo di dire "adesso" senza scrivere
#   "adesso", e risolve un problema vero: il pericolo era un numero in una riga
#   di sei voci, e si passava da "sto giocando" a "e' a terra" senza nessun
#   momento in cui il gioco avesse alzato la voce.
#
# COME E' DISEGNATO IL VELO, e perche' non e' uno shader.
#
# Uno shader sarebbe la strada ovvia e qui sarebbe la strada sbagliata: in
# headless Godot non compila i frammenti, quindi un errore dentro lo shader non
# lo troverebbe nessuna prova e uscirebbe fuori solo giocando. Il velo e' fatto
# di quattro poligoni con i colori sui vertici - opachi sul bordo dello schermo,
# trasparenti verso il centro - che e' la stessa tecnica con cui Stile.barra
# disegna la barra del dominio: nessuna risorsa, nessuna compilazione, niente
# che possa rompersi in silenzio.
#
# In modalita' muta non esiste niente di tutto questo.

# Quanto del colore del tipo entra nel fondo. Basso apposta: sopra il quindici
# per cento il fondo comincia a essere il colore del nemico invece che il colore
# del gioco, e le schermate smettono di sembrare lo stesso gioco.
const PESO_TINTA := 0.14
# quanto e' spesso il velo ai bordi, in quota dello schermo
const SPESSORE_VELO := 0.28

var muta := false
var velo: Control
var pericolo := 0.0

func _init(silenziosa := false) -> void:
	muta = silenziosa

static func tinta_piena(tipo: String, colore_base: Color) -> Color:
	# Dove ARRIVEREBBE il fondo se la tinta del tipo fosse pura, senza dosaggio.
	# Non la usa nessuno per disegnare: esiste perche' il punto di arrivo abbia
	# un nome, e perche' una prova possa chiedere "quanta strada ne ha fatta il
	# fondo?" invece di fidarsi che il dosaggio sia rimasto basso.
	#
	# Scurita' prima di mescolare: i colori dei tipi sono nati per essere letti
	# su testo piccolo, quindi sono chiari, e mescolati cosi' com'erano
	# schiarirebbero il fondo invece di tingerlo.
	if tipo == "":
		return colore_base
	var dati_tipo: Dictionary = GameState.tipi.get(tipo, {})
	var esadecimale := String(dati_tipo.get("colore", ""))
	if esadecimale == "":
		return colore_base
	return Color.html(esadecimale).darkened(0.55)

static func tinta_di_scontro(colore_base: Color, tipo: String) -> Color:
	# Il fondo con dentro una traccia del tipo che hai davanti. Statica e pura:
	# entra un colore ed esce un colore, quindi si puo' misurare senza costruire
	# mezza schermata - ed e' l'unico modo di accorgersi se un giorno smette di
	# cambiare niente.
	var arrivo := tinta_piena(tipo, colore_base)
	if arrivo == colore_base:
		return colore_base
	return colore_base.lerp(arrivo, PESO_TINTA)

static func quota_di_pericolo(combattenti: Array[Dictionary]) -> float:
	# Quanto sta messa male la squadra, da 0 a 1. Guarda il compagno piu' ferito
	# ancora in piedi, non la media: con una media, tre compagni sani e uno in
	# fin di vita darebbero "va tutto bene" - ed e' esattamente il momento in cui
	# il gioco deve alzare la voce. Chi e' gia' a terra non conta: quello non e'
	# piu' pericolo, e' gia' successo.
	var peggio := 0.0
	for combattente in combattenti:
		if not bool(combattente.get("giocatore", false)):
			continue
		var vita := int(combattente.get("hp", 0))
		var massimo := int(combattente.get("hp_max", 0))
		if vita <= 0 or massimo <= 0:
			continue
		var soglia := float(GameState.regole.get("soglia_vita_bassa", 0.25))
		if soglia <= 0.0:
			continue
		var quota := float(vita) / float(massimo)
		if quota >= soglia:
			continue
		# dentro la soglia: 0 appena la tocchi, 1 a un passo dal KO
		peggio = maxf(peggio, 1.0 - (quota / soglia))
	return clampf(peggio, 0.0, 1.0)

func collega(sfondo: ColorRect, sopra: Control) -> void:
	# Il velo sta SOPRA lo sfondo e SOTTO tutto il resto: le schede e il box
	# devono restare leggibili anche quando i bordi si chiudono. Chi chiama passa
	# il nodo giusto, qui non si cerca niente nell'albero.
	if muta or sfondo == null or not is_instance_valid(sopra):
		return
	velo = Control.new()
	velo.name = "Velo"
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	velo.draw.connect(disegna_velo)
	sopra.add_child(velo)
	# SUBITO SOPRA LO SFONDO, non in fondo alla pila. In Godot l'ordine dei figli
	# e' l'ordine in cui si disegnano: a indice 0 il velo finirebbe SOTTO lo
	# sfondo, che e' un rettangolo pieno a tutto schermo, e non si vedrebbe mai -
	# un effetto che funziona benissimo e che nessuno guarda
	sopra.move_child(velo, sfondo.get_index() + 1)

func disegna_velo() -> void:
	if velo == null or not is_instance_valid(velo) or pericolo <= 0.0:
		return
	var larghezza := velo.size.x
	var altezza := velo.size.y
	if larghezza <= 0.0 or altezza <= 0.0:
		return
	var tinta := Stile.colore_danno("normale")
	var fuori := Color(tinta.r, tinta.g, tinta.b, clampf(pericolo, 0.0, 1.0) * 0.5)
	var dentro := Color(tinta.r, tinta.g, tinta.b, 0.0)
	var colori := PackedColorArray([fuori, fuori, dentro, dentro])
	var spessore_x := larghezza * SPESSORE_VELO
	var spessore_y := altezza * SPESSORE_VELO
	# quattro fasce, una per lato: il bordo dello schermo e' pieno, il lato
	# rivolto al centro e' trasparente, e i vertici fanno il resto
	velo.draw_polygon(PackedVector2Array([
			Vector2(0, 0), Vector2(larghezza, 0),
			Vector2(larghezza, spessore_y), Vector2(0, spessore_y)]), colori)
	velo.draw_polygon(PackedVector2Array([
			Vector2(0, altezza), Vector2(larghezza, altezza),
			Vector2(larghezza, altezza - spessore_y), Vector2(0, altezza - spessore_y)]), colori)
	velo.draw_polygon(PackedVector2Array([
			Vector2(0, 0), Vector2(0, altezza),
			Vector2(spessore_x, altezza), Vector2(spessore_x, 0)]), colori)
	velo.draw_polygon(PackedVector2Array([
			Vector2(larghezza, 0), Vector2(larghezza, altezza),
			Vector2(larghezza - spessore_x, altezza), Vector2(larghezza - spessore_x, 0)]), colori)

func imposta_pericolo(quota: float) -> void:
	# Si ridisegna solo quando cambia davvero qualcosa. Senza questo controllo il
	# velo si ridisegnerebbe a ogni aggiornamento di scheda - e ce n'e' uno per
	# colpo, per stato, per battuta - per finire a disegnare esattamente la
	# stessa cosa di prima
	if muta or velo == null or not is_instance_valid(velo):
		return
	var nuova := clampf(quota, 0.0, 1.0)
	if is_equal_approx(nuova, pericolo):
		return
	pericolo = nuova
	velo.queue_redraw()
