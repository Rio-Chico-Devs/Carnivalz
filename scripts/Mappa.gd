class_name MappaStellare
extends Control

# LA MAPPA STELLARE: la proiezione del settore, guardata dal tavolo tattico
# della Sala operativa (vedi Sede.gd). Legge data/mappa.json e mostra i
# sistemi: dove un Carnivalz sta avendo luogo c'e' un pozzo profondo e il
# «!»; dove non c'e', un pianeta spento, che non si apre. Il disegno e i
# gesti sono in Proiezione.gd: qui ci sono le regole.
#
# Non e' il posto in cui si vive fra una missione e l'altra, ed e' per questo
# che qui non si salva e non si compra: la Sede fa quelle cose. Qui si guarda
# dove andare, e si va. Il primo clic su un sistema lo sceglie (la nave ci
# va, la scheda lo racconta); il secondo, o «Scendi nel Vuoto», o Invio, ci
# fa cadere dentro.
#
# Un sistema dove non hai ancora messo piede chiama: gli anelli si allargano
# e la didascalia dice «non ci sei ancora stato». Uno gia' battuto resta li'
# senza chiamarti. E' la stessa regola del Vuoto e della mappa di zona.
#
# LA PRIMA VOLTA LA APRE VERONICA, in sala di proiezione: «vedi questa mappa?
# devi selezionare il punto d'interesse che appare su di essa [...] adesso hai
# a disposizione solo la tua prima missione». Allora (missione_da_scegliere)
# sulla mappa c'e' solo quella frattura - i punti "prima_missione" - non si
# torna alla Sede, e scelta la meta si torna da Veronica per partire.

signal partita   # la meta e' decisa e il cambio di schermata e' chiesto

# aperta da Veronica per la prima missione: il nodo a cui tornare scelta la
# meta. "" = la mappa di sempre. Sta qui e non in GameState perche' e' una cosa
# di questa schermata sola, come MenuPrincipale.ritorno
static var missione_da_scegliere := ""

const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_SEDE := "res://scenes/Sede.tscn"
const SCALA := 42.0   # i "pos" di mappa.json sono pixel di un vecchio 1280x720: tanti fanno un'unita'

@onready var strato_punti: Control = %Punti
@onready var bottone_sede: Button = %BottoneSede

var proiezione: Proiezione
var punti_per_id := {}
var partendo := false


func _ready() -> void:
	AudioManager.musica_chiave("mappa")
	# e solo se quel nodo c'e' davvero: una partita caricata a meta' scelta non
	# deve riaprire la mappa della prima missione dalla Sede
	if not GameState.eventi.has(missione_da_scegliere):
		missione_da_scegliere = ""
	var scegliendo := missione_da_scegliere != ""
	proiezione = Proiezione.new()
	proiezione.livello = "settore"
	proiezione.strato = strato_punti
	proiezione.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(proiezione)
	move_child(proiezione, 0)
	proiezione.nota_destra = "TAZO %d" % GameState.tazo
	var mappa: Dictionary = GameState.carica_mappa()
	var percorso_sfondo := String(mappa.get("sfondo", ""))
	if percorso_sfondo != "" and ResourceLoader.exists(percorso_sfondo):
		proiezione.immagine_di_fondo(load(percorso_sfondo))
	crea_punti(mappa.get("punti", []), scegliendo)
	proiezione.aggiungi_stelle_lontane(14, 404)
	proiezione.confermato.connect(_su_conferma)
	DisegnoProiezione.vesti(bottone_sede, proiezione.tinte)
	bottone_sede.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_SEDE))
	if scegliendo:
		# dalla sala di proiezione non si va alla Sede: si sceglie la meta e basta.
		# E il titolo dice dove sei davvero: non la sala operativa della Sede, che
		# non hai ancora visto, ma la piattaforma di Veronica
		bottone_sede.visible = false
		proiezione.intestazione = "CARNIVALZ  ·  SALA DI PROIEZIONE"
		proiezione.titolo_grande = "LA PRIMA MISSIONE"
		proiezione.sopratitolo = "SELEZIONA IL PUNTO D'INTERESSE"
	else:
		proiezione.titolo_grande = "IL SETTORE"
		proiezione.sopratitolo = "PROIEZIONE DEL SETTORE  ·  %d SISTEMI" % punti_per_id.size()
	proiezione.accendi(Vector2.ZERO)
	IconaMenu.metti(self)


func crea_punti(punti: Array, prima_missione := false) -> void:
	for punto: Dictionary in punti:
		# la prima missione si vede solo quando la si sceglie, e allora si vede
		# solo lei: dopo, quella frattura e' storia
		if bool(punto.get("prima_missione", false)) != prima_missione:
			continue
		if punto.has("richiede_flag") and not GameState.ha_flag(String(punto["richiede_flag"])):
			continue  # sbloccato solo dopo un'altra campagna (es. il tutorial)
		var id_punto := String(punto.get("id", ""))
		var attivo := bool(punto.get("attivo", false))
		var stato := GameState.stato_visita(id_punto, String(punto.get("flag_completato", ""))) if attivo else "spento"
		var pos: Array = punto.get("pos", [640, 360])
		punti_per_id[id_punto] = punto
		proiezione.aggiungi({"id": id_punto, "nome": String(punto.get("nome", id_punto)), "tipo": "sistema",
				"xz": Vector2((float(pos[0]) - 640.0) / SCALA, (float(pos[1]) - 360.0) / SCALA),
				"profondita": 5.0 if attivo else 1.4, "largo": 1.3 if attivo else 0.7,
				"raggio": 0.85 if attivo else 0.45, "stato": stato, "segnale": attivo, "chiama": stato == "nuovo",
				"bande": 1.0 if attivo else 0.0, "spento": 0.0 if attivo else 1.0,
				"epoca": String(punto.get("epoca", "Carnivalz in corso" if attivo else "Nessun segnale")),
				"testo": String(punto.get("descrizione", "")),
				"azione": "Scendi nel Vuoto" if attivo else "Nessun segnale", "attiva": attivo})


func _su_conferma(id: String) -> void:
	var punto: Dictionary = punti_per_id.get(id, {})
	if punto.is_empty() or partendo:
		return
	partendo = true
	if missione_da_scegliere != "":
		# la meta e' scelta: si torna in sala di proiezione, dove Veronica fa
		# partire il resto
		var ritorno := missione_da_scegliere
		missione_da_scegliere = ""
		await proiezione.cadi_nel_pozzo(id)
		IngressoNodo.vai_al_nodo(ritorno)
		partita.emit()
		return
	# si cade nel pozzo del sistema: dall'altra parte c'e' il suo Vuoto
	GameState.punto_mappa_corrente = punto
	GameState.segna_visitata(id)
	await proiezione.cadi_nel_pozzo(id)
	Transizioni.vai(SCENA_VUOTO)
	partita.emit()
