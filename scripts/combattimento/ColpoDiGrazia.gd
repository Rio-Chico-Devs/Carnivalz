class_name ColpoDiGraziaCombattimento
extends RefCounted

# IL COLPO DI GRAZIA: quello che resta quando la barra della Mattanza e' vuota.
#
# Bru: «quando finisce hai un minigioco con una barra che scorre velocemente:
# se clicchi nel momento giusto in cui si allinea con un punto random sulla
# barra infliggi del danno bonus. In quel punto va inserita un'immagine che ti
# forniro' io; se centra quel punto l'immagine si frantuma in mille pezzi,
# parte un effetto sonoro che ti daro', e viene inflitto il danno al nemico».
#
# E' IL ROVESCIO DELLA MATTANZA, apposta. Per secondi hai contato quante volte
# premevi; qui ne conta una sola, e conta QUANDO. La stessa mano deve cambiare
# gesto di colpo, ed e' quello che fa del finale un momento invece di altri
# tre secondi di martello.
#
# COME E' FATTO: una lancetta che va e viene sulla barra, avanti e indietro,
# e un bersaglio messo a caso. Un tiro solo. Dentro il bersaglio: centrato.
# Fuori, o se il tempo finisce senza tiro: mancato. Il bersaglio e' largo
# esattamente quanto l'immagine che lo segna - quello che vedi e' quello che
# vale, al pixel.
#
# I PRIMI ISTANTI SONO SORDI. Chi arriva dalla Mattanza sta ancora martellando,
# e le due o tre pressioni che gli scappano dopo la fine della barra non devono
# sprecare il tiro: per "sordo" secondi la lancetta e' ferma e i tasti non
# contano. E' la stessa cortesia del riepilogo della mazzata (CHIUSURA_SORDA).
#
# I NUMERI (nei dati della Mattanza, sotto "colpo_di_grazia"; quelli qui sotto
# sono solo il ripiego):
#
#   passaggio   quanti secondi ci mette la lancetta da un capo all'altro
#   tolleranza  mezza larghezza del bersaglio, in frazioni di barra
#   tempo       quanto corre la lancetta prima che il tiro sia perso
#   sordo       i secondi in cui la mano che martella non conta
#   dove        tra quali frazioni di barra puo' cadere il bersaglio
#
# NIENTE RALLENTATORE: la velocita' e' quella per tutti. Il movimento ridotto
# toglie gli scossoni e le schegge che volano, non il tempo per prendere la
# mira - quello e' il gioco.

signal centrato
signal finito(esito: Dictionary)

const DI_SERIE := {"passaggio": 0.7, "tolleranza": 0.06, "tempo": 3.2, "sordo": 0.45}
const DOVE_DI_SERIE := [0.25, 0.85]
const CHIUSURA := 1.4              # quanto resta a schermo com'e' andata
const CHIUSURA_SORDA := 0.5        # e per quanto un tasto non la chiude

var muto := false
var plancia: PlanciaCombattimento = null
var riquadro: RiquadroColpoDiGrazia = null

var regole: Dictionary = {}
var testi: Dictionary = {}
var fase := ""            # "sordo", "corsa", "chiusura"; "" a riposo
var tempo_fase := 0.0
var corsa := 0.0          # da quanto corre la lancetta
var punto := 0.5          # il centro del bersaglio, da 0 a 1
var cursore := 0.0        # dov'e' la lancetta, da 0 a 1
var tirato := false
var preso := false
var attivo := false
var giocati := 0          # le prove contano questi, non i pixel

func _init(silenzioso := false) -> void:
	muto = silenzioso

func collega(dove: Control, tabellone: PlanciaCombattimento = null, sopra: Control = null) -> void:
	# "dove" e' l'interno del quadrante, come per la raffica e la mazzata;
	# "sopra" e' lo strato dei numeri volanti: le schegge escono dal quadrante,
	# e dentro il riquadro verrebbero tagliate al suo bordo
	plancia = tabellone
	if dove == null or muto:
		return
	riquadro = RiquadroColpoDiGrazia.new(self, sopra)
	riquadro.visible = false
	riquadro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dove.add_child(riquadro)

# --- la parte che decide: numeri dentro, numeri fuori -------------------------

static func posizione(t: float, passaggio: float) -> float:
	# AVANTI E INDIETRO, a velocita' costante: da 0 a 1 in "passaggio" secondi,
	# poi da 1 a 0. Costante apposta - una lancetta che rallenta ai bordi si
	# prende da ferma, e il tempismo diventerebbe aspettare
	var giri := fposmod(t / maxf(passaggio, 0.01), 2.0)
	return giri if giri <= 1.0 else 2.0 - giri

static func dentro(dove_e: float, centro: float, tolleranza: float) -> bool:
	return absf(dove_e - centro) <= tolleranza

# --- a schermo ----------------------------------------------------------------

func avvia(parametri: Dictionary) -> bool:
	# false = non c'e' nessun riquadro dove giocarlo: chi chiama se la sbriga
	# da solo (vedi MattanzaCombattimento.centra_da_solo)
	if muto or riquadro == null or attivo:
		return false
	regole = {}
	for chiave in DI_SERIE:
		regole[chiave] = float(parametri.get(chiave, DI_SERIE[chiave]))
	var dove: Array = parametri.get("dove", DOVE_DI_SERIE)
	var da := float(dove[0]) if dove.size() > 0 else 0.25
	var a := float(dove[1]) if dove.size() > 1 else 0.85
	punto = GameState.rng.randf_range(minf(da, a), maxf(da, a))
	testi = parametri
	fase = "sordo"
	tempo_fase = 0.0
	corsa = 0.0
	cursore = 0.0
	tirato = false
	preso = false
	attivo = true
	giocati += 1
	if plancia != null:
		plancia.mostra_faccia("minigioco")
	riquadro.visible = true
	riquadro.comincia()
	return true

func passa(delta: float) -> void:
	# ha un orologio suo: mentre gira, quello dello scontro e' fermo
	if not attivo:
		return
	tempo_fase += delta
	match fase:
		"sordo":
			if tempo_fase >= float(regole.get("sordo", 0.45)):
				fase = "corsa"
				tempo_fase = 0.0
		"corsa":
			corsa += delta
			cursore = posizione(corsa, float(regole.get("passaggio", 0.7)))
			if corsa >= float(regole.get("tempo", 3.2)):
				tira()   # il tempo e' finito: il tiro e' perso
		"chiusura":
			if tempo_fase >= CHIUSURA:
				concludi()
				return
	if riquadro != null:
		riquadro.aggiorna(delta)

func premi_col_tasto() -> bool:
	# SPAZIO, INVIO, un clic sul riquadro o sul nemico: e' il tiro. Torna false
	# se il colpo di grazia non c'e', cosi' chi chiama sa se l'evento e' suo
	if not attivo:
		return false
	match fase:
		"corsa":
			tira(true)
		"chiusura":
			if tempo_fase >= CHIUSURA_SORDA:
				concludi()
	return true   # anche da sordo: la pressione e' sua, e non va da nessun'altra parte

func tira(dalla_mano := false) -> void:
	tirato = dalla_mano
	preso = dalla_mano and dentro(cursore, punto, float(regole.get("tolleranza", 0.06)))
	fase = "chiusura"
	tempo_fase = 0.0
	if riquadro != null:
		riquadro.tiro(preso)
	if preso:
		centrato.emit()

func esito() -> Dictionary:
	return {"centrato": preso, "tirato": tirato, "dove": cursore, "punto": punto}

func concludi() -> void:
	attivo = false
	fase = ""
	if riquadro != null:
		riquadro.visible = false
	finito.emit(esito())

func interrompi() -> void:
	# lo scontro e' finito sotto (una fuga, un KO dall'altra parte): si spegne
	# senza dire com'e' andata, perche' non e' andata
	if not attivo:
		return
	attivo = false
	fase = ""
	if riquadro != null:
		riquadro.visible = false
