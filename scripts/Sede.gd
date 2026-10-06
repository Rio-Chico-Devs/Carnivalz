class_name Sede
extends Control

# La Sede: dove sei quando non sei dentro un Carnivalz.
#
# PERCHE' ESISTE. Prima il gioco non aveva un "dove sei": si usciva dal menu e
# ci si trovava su una mappa stellare, sospesi nel vuoto, senza che nessuno
# avesse mai detto da dove la stessi guardando. Adesso la guardi dal tavolo
# tattico della Sala operativa, che sta dentro un'unita' dell'Organizzazione,
# che e' un presidio e va difeso. La mappa non e' piu' il posto in cui vivi: e'
# una cosa che si consulta.
#
# E' anche il posto sicuro del gioco, l'unico. Qui si salva - da solo, senza
# chiedere niente a nessuno: quale file venga scritto e' una faccenda della
# schermata principale, non tua mentre giochi (vedi GameState.slot_corrente).
#
# NON E' PIU' UNA LISTA. Era una colonna di voci - Sala operativa, Emporio,
# Alloggi, Archivio - con una scheda di fianco. Bru: «quando mi ritrovo nella
# sede mi sento confuso, dove vado? cosa faccio? perche' non posso esplorare la
# mappa dell'organizzazione? [...] e' come restare intrappolati in una
# schermata di opzioni». E aveva ragione anche sul perche': la lista era nata
# prima che il complesso avesse una mappa, e nessuno l'aveva piu' rimessa in
# discussione. Adesso la Sede e' il complesso, lo stesso della prima giornata
# (data/events_sede.json): si cammina per le stanze sulla pianta, e le stanze
# che fanno qualcosa - la sala operativa, l'emporio, l'alloggio, l'archivio -
# lo fanno da dentro, con una scelta "apre" (vedi apri()).
#
# Questa schermata quindi fa due cose e poi lascia il posto alla mappa: salva,
# e prepara la Sede come una zona in cui si cammina.

const ZONA := "sede"
const PERCORSO := "res://data/events_sede.json"
const SCENA_PIANTA := "res://scenes/MappaZona.tscn"
const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_NEGOZIO := "res://scenes/Negozio.tscn"

var salvata := true   # com'e' andato il salvataggio di quando sei rientrato


func _ready() -> void:
	AudioManager.musica_chiave("mappa")
	# Il salvataggio sta qui e in nessun altro posto. Rientrare alla Sede E' il
	# salvataggio: non c'e' un bottone, non c'e' una domanda, non c'e' un modo di
	# scrivere sul file sbagliato.
	salvata = GameState.salva()
	entra()
	add_child(load(SCENA_PIANTA).instantiate())


func entra() -> void:
	# DOVE TI RITROVI. Tornando dall'emporio o dalla sala operativa sei ancora
	# li', non all'ingresso: la stanza da cui eri uscito c'e' ancora, perche'
	# ne' l'emporio ne' la mappa stellare cambiano zona. Da una missione, o da
	# una partita appena caricata, si arriva nel tuo alloggio
	var dove := GameState.nodo_corrente if GameState.carnivalz_corrente == ZONA else ""
	GameState.avvia_carnivalz(ZONA, PERCORSO)
	# la Sede la conosci tutta: ogni stanza ha il suo nome sulla pianta
	GameState.imposta_flag(String(GameState.mappa_zona.get("flag_completamento", "")))
	if GameState.stanza_nella_mappa(dove):
		GameState.nodo_corrente = dove
	MappaZona.avviso = riga_di_stato()


func riga_di_stato() -> String:
	# se il disco non ha scritto, lo si dice qui, dove il gioco promette di
	# salvare: tacerlo vorrebbe dire lasciar credere che la partita sia al sicuro
	if not salvata:
		return "Salvataggio non riuscito: la partita di adesso non è su disco."
	# Ogni unita' deve tenere in casa un numero minimo di dominatori. Non e'
	# ancora una regola di gioco: e' una riga che dice che questo posto e' un
	# presidio, e che quando esci lo lasci piu' scoperto di com'era.
	var letto: Variant = GameState.carica_json(PERCORSO)
	var richiesti := int((letto as Dictionary).get("presidio_richiesto", 0)) if letto is Dictionary else 0
	var in_forza := GameState.classi_sbloccate.size()
	var testo := "Dominatori in forza: %d di %d" % [in_forza, richiesti]
	return testo + ("  —  sotto organico" if in_forza < richiesti else "")


static func avviso_di_uscita() -> String:
	# cosa si perde tornando al menu principale. Dentro una zona tutto quello
	# che non e' passato dalla Sede; alla Sede niente, ci sei appena rientrato.
	# Lo diceva sempre nel primo modo, anche nell'alloggio: spaventava per
	# niente proprio nel posto in cui si e' al sicuro
	if GameState.carnivalz_corrente == ZONA:
		return "La partita si è salvata quando sei rientrato alla Sede:\npuoi tornare al menu senza perdere niente."
	return "Il gioco si salva da solo quando rientri alla Sede: tutto quello che hai\nfatto dentro questa zona (stanze, oggetti raccolti, Tazo) andrà perso."


static func apri(cosa: String) -> void:
	# QUELLO CHE LE STANZE DELLA SEDE FANNO, quando le si chiede ("apre" in una
	# scelta di events_sede.json). La mappa stellare e l'emporio sono schermate
	# loro, e se ne torna alla Sede (che salva); la squadra e il data pad vivono
	# nel velo della pausa, e chiudendoli si e' di nuovo nella stanza
	match cosa:
		"mappa_stellare":
			Transizioni.vai(SCENA_MAPPA)
		"negozio":
			Transizioni.vai(SCENA_NEGOZIO)
		"squadra":
			Pausa.apri_su("equipaggiamento")
		"diario":
			Pausa.apri_su("diario")
		_:
			push_error("Una stanza della Sede apre '%s', che non esiste" % cosa)
