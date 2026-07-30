extends Node

# Impostazioni utente (audio, grafica, accessibilità), persistite a parte dal
# salvataggio di partita: user://impostazioni.cfg, non uno slot.
# Autoload dopo AudioManager (deve trovare i bus "Musica"/"Effetti" già creati).

const PERCORSO := "user://impostazioni.cfg"

var volume_master := 1.0
var volume_musica := 1.0
var volume_effetti := 1.0
var schermo_intero := false
var testo_grande := false
var alto_contrasto := false
var velocita_testo := 1.0  # moltiplica i caratteri al secondo del box (0.5 lento, 3 = quasi istantaneo)

func _ready() -> void:
	carica()
	applica_tutto()

func carica() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PERCORSO) != OK:
		return
	volume_master = float(cfg.get_value("audio", "master", 1.0))
	volume_musica = float(cfg.get_value("audio", "musica", 1.0))
	volume_effetti = float(cfg.get_value("audio", "effetti", 1.0))
	schermo_intero = bool(cfg.get_value("grafica", "schermo_intero", false))
	testo_grande = bool(cfg.get_value("accessibilita", "testo_grande", false))
	alto_contrasto = bool(cfg.get_value("accessibilita", "alto_contrasto", false))
	velocita_testo = float(cfg.get_value("accessibilita", "velocita_testo", 1.0))

func salva() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", volume_master)
	cfg.set_value("audio", "musica", volume_musica)
	cfg.set_value("audio", "effetti", volume_effetti)
	cfg.set_value("grafica", "schermo_intero", schermo_intero)
	cfg.set_value("accessibilita", "testo_grande", testo_grande)
	cfg.set_value("accessibilita", "alto_contrasto", alto_contrasto)
	cfg.set_value("accessibilita", "velocita_testo", velocita_testo)
	cfg.save(PERCORSO)

func applica_tutto() -> void:
	applica_volumi()
	applica_schermo()
	applica_scala_testo()
	applica_alto_contrasto()

func applica_volumi() -> void:
	_imposta_bus("Master", volume_master)
	_imposta_bus("Musica", volume_musica)
	_imposta_bus("Effetti", volume_effetti)

func _imposta_bus(nome: String, valore: float) -> void:
	var indice := AudioServer.get_bus_index(nome)
	if indice == -1:
		return
	AudioServer.set_bus_mute(indice, valore <= 0.0)
	if valore > 0.0:
		AudioServer.set_bus_volume_db(indice, linear_to_db(clampf(valore, 0.0, 1.0)))

func applica_schermo() -> void:
	DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if schermo_intero else DisplayServer.WINDOW_MODE_WINDOWED)

func applica_scala_testo() -> void:
	# raddoppia (circa) la scala dell'interfaccia: leggibile per chi ha
	# difficoltà visive, senza bisogno di un tema dedicato per ogni schermata
	get_tree().root.content_scale_factor = 1.25 if testo_grande else 1.0

func applica_alto_contrasto() -> void:
	# non e' un tema che sostituisce quello del gioco: e' una variante dello
	# stesso tema, ricostruita da Stile con i colori del testo portati al
	# giallo ad alta visibilita'. Tutto il resto (font, bordi, spaziature)
	# resta identico, cosi' l'accessibilita' non fa sembrare un altro gioco.
	Stile.imposta_alto_contrasto(alto_contrasto)
