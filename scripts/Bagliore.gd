class_name Bagliore
extends Control

# UN ALONE INTORNO A UN PEZZO DELLO SCHERMO, fatto a mano come in After Effects.
#
# COS'ERA PRIMA. Un tween su modulate: il pezzo diventava rosso in 0,45s,
# tornava bianco in 0,45s, all'infinito, con interpolazione LINEARE. Tre difetti
# in tre righe:
#
#   1. non e' un alone, e' una TINTA. modulate moltiplica i colori del nodo,
#      quindi il testo bianco diventava rosso e il riquadro si scuriva: il pezzo
#      che stiamo indicando si legge PEGGIO proprio mentre lo indichiamo.
#   2. lineare. Disney lo chiama "slow in and slow out" e la ragione e'
#      meccanica: a spaziatura costante il valore inverte di colpo agli
#      estremi. "Even spacing = robotic. Eased spacing = organic."
#   3. 0,9 secondi a ciclo, da zero a tutto. Bru: "troppo rapido e non e'
#      piacevole da vedere".
#
# COME FUNZIONA UN GLOW VERO. In After Effects sono tre parametri: SOGLIA (quali
# pixel si accendono), RAGGIO (quanto si allarga: "Glow Radius creates the
# layer's Gaussian blur and adds it to the layer"), INTENSITA' (quanto e'
# luminoso), e una fusione additiva.
#
# Qui non c'e' nessuna sfocatura vera - e non ci sara', perche' uno shader in
# questo progetto vuol dire un pezzo di interfaccia che nessuna prova puo'
# attraversare: Godot senza finestra non compila i frammenti. Pero' una
# gaussiana si puo' IMPILARE: tanti rettangoli concentrici, ognuno piu' grande e
# piu' spento, e la somma delle loro trasparenze disegna la stessa curva a
# campana. E' quello che fa gia' la linea dell'ECG con le sue tre passate.
#
# LA CURVA E' QUELLA VERA, non una rampa lineare: exp(-t^2 / 2s^2). Con la
# rampa l'alone finisce con un bordo netto - si vede il contorno dell'ultima
# passata - e sembra un bordo colorato, non luce.
#
# PERCHE' NON ADDITIVO PURO. Additivo satura: dove le passate si sovrappongono
# si arriva al bianco e l'alone si "brucia". Il modo classico di evitarlo e' lo
# screen, Source + (1 - Source) * Dest, che Godot non ha fra le fusioni dei
# CanvasItem. Ci si arriva uguale tenendo le passate BASSE e lasciandole sommare
# in trasparenza normale: la campana ci mette un po' piu' a salire, ma non
# brucia mai, e quello che importa e' che non bruci mai.

const PASSATE := 16       # quanti gradini: sotto i dieci si contano a occhio
const RAGGIO := 34.0      # quanto si allarga oltre il bordo del pezzo
const INTENSITA := 0.44   # quanto si vede in TOTALE contro il bordo del pezzo
const LARGHEZZA_CAMPANA := 0.58   # la sigma della gaussiana, in frazione di raggio
const ANGOLO := 6.0       # gli spigoli dell'alone, che seguono quelli del pezzo

# IL RESPIRO. Un ciclo intero dura il doppio di prima e non arriva mai a zero.
#
# «The key is in the timing: easing should be gentle and continuous so that the
# effect feels natural rather than mechanical. Too sharp of a pulse can feel
# stressful, while too slow can lose its impact.» Due secondi sono il passo di
# un respiro tranquillo senza diventare un'attesa; e restando fra 0,42 e 1,0 il
# pezzo non si spegne mai del tutto - un invito che sparisce e torna e' un
# lampeggio, e i lampeggi danno fastidio a chi li guarda a lungo.
const RESPIRO := 1.0      # secondi per mezzo ciclo: 2,0 in tutto
const MINIMO := 0.42      # quanto resta acceso nel punto piu' basso

var tinta := Color.WHITE
var respiro: Tween = null


static func intorno_a(pezzo: Control, colore: Color) -> Bagliore:
	# STA DENTRO IL PEZZO MA SI DISEGNA DIETRO. show_behind_parent lo mette
	# sotto senza doverlo tenere allineato a mano: se il pezzo si sposta o
	# cambia misura, l'alone ci va dietro da solo.
	var b := Bagliore.new()
	b.tinta = colore
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.show_behind_parent = true
	b.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	b.offset_left = -RAGGIO
	b.offset_top = -RAGGIO
	b.offset_right = RAGGIO
	b.offset_bottom = RAGGIO
	pezzo.add_child(b)
	return b


func _draw() -> void:
	# DAL DI FUORI VERSO IL DENTRO, e ogni passata sa quanto hanno gia' messo
	# quelle prima di lei.
	#
	# Qui stava il difetto della prima versione. Davo a ogni rettangolo la sua
	# trasparenza secondo la campana e li sovrapponevo: ma sovrapporre in
	# trasparenza normale non SOMMA, moltiplica quello che resta. L'opacita' che
	# si vede a una certa distanza e' 1 - (1-a1)(1-a2)...(1-an), quindi appena
	# fuori dal bordo - dove passano quasi tutti i rettangoli - si arrivava
	# all'ottantacinque per cento: una fascia rosa accesa attaccata al pezzo,
	# che si legge come un bordo colorato e non come luce. E fra una passata e
	# l'altra si vedevano i gradini.
	#
	# Adesso la campana e' l'obiettivo CUMULATIVO, non il contributo di ognuna:
	# si calcola quanto si deve vedere a quella distanza, si guarda quanto c'e'
	# gia', e si mette solo la differenza - (voluta - gia_messa) / (1 - gia_messa).
	# Il profilo che ne esce e' la gaussiana vera, quella che in After Effects
	# fa il raggio del glow.
	var gia_messa := 0.0
	for i in range(PASSATE, 0, -1):
		var quanto := float(i) / float(PASSATE)   # 1 = il bordo piu' esterno
		var voluta := forza_a(quanto)
		var questa := (voluta - gia_messa) / maxf(1.0 - gia_messa, 0.001)
		gia_messa = voluta
		if questa <= 0.002:
			continue
		var scatola := StyleBoxFlat.new()
		scatola.bg_color = Color(tinta.r, tinta.g, tinta.b, clampf(questa, 0.0, 1.0))
		scatola.set_corner_radius_all(int(ANGOLO + RAGGIO * quanto))
		var stretta := RAGGIO * (1.0 - quanto)
		scatola.draw(get_canvas_item(), Rect2(Vector2.ONE * stretta,
				size - Vector2.ONE * stretta * 2.0))


func forza_a(quanto: float) -> float:
	# quanto si deve vedere in TOTALE a questa distanza dal pezzo: la campana,
	# piena contro il bordo del pezzo e spenta all'orlo esterno. Si toglie la
	# coda oltre l'orlo, se no l'ultima passata ha un gradino invece di zero
	var s := LARGHEZZA_CAMPANA
	var campana := exp(-(quanto * quanto) / (2.0 * s * s))
	var orlo := exp(-1.0 / (2.0 * s * s))
	return INTENSITA * maxf(campana - orlo, 0.0) / maxf(1.0 - orlo, 0.001)


func respira() -> void:
	ferma()
	if Impostazioni.movimento_ridotto:
		# CHI RIDUCE IL MOVIMENTO VEDE L'ALONE, NON IL RESPIRO. L'informazione
		# e' "guarda qui", e sta tutta nell'esserci: il battito e' il di piu'.
		modulate.a = 1.0
		return
	modulate.a = MINIMO
	respiro = create_tween().set_loops()
	respiro.tween_property(self, "modulate:a", 1.0, RESPIRO) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	respiro.tween_property(self, "modulate:a", MINIMO, RESPIRO) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func ferma() -> void:
	if respiro != null and respiro.is_valid():
		respiro.kill()
	respiro = null
