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
# RIDUCI IL MOVIMENTO. Le linee guida sull'accessibilita' dei giochi lo mettono
# fra le opzioni che vanno offerte, non fra quelle carine da avere: la scossa
# dell'inquadratura e i lampi sono fra i motivi per cui una persona che soffre
# di mal di movimento, di emicrania o di epilessia fotosensibile smette di
# giocare. Il gioco aveva gia' testo grande, alto contrasto e velocita' del
# testo; questa mancava, e il combattimento trema a ogni colpo.
#
# Non toglie l'informazione, toglie il MOVIMENTO: il lampo di un colpo diventa
# un cambio di colore che resta, invece di un battito.
var movimento_ridotto := false
var velocita_testo := 1.0  # moltiplica i caratteri al secondo del box (0.5 lento, 3 = quasi istantaneo)

# HAI GIA' FATTO L'ALLENAMENTO, ALMENO UNA VOLTA.
#
# Sta qui e non nei flag della partita per una ragione precisa: dentro una
# partita l'allenamento si fa UNA volta sola, quindi un flag di salvataggio non
# comparirebbe mai a nessuno. La domanda e' «l'hai gia' visto, in qualunque
# partita?», e quella sopravvive alla partita nuova - come il volume.
#
# Serve a far comparire "Salta la lezione" a chi rigioca, e a nessun altro.
# NON e' un pulsante di aiuto: Andersen (docs/fonti/chi2012-tutorial-
# complessita.pdf) ha misurato che aggiungerne uno in Refraction ha RIDOTTO i
# progressi del 12% e il tempo di gioco del 15%. Saltare e' un'altra cosa -
# e' la stessa lezione, non piu' offerta a chi l'ha gia' avuta.
var allenamento_gia_fatto := false

# NELL'EDITOR, DENTRO LA VISTA «GAME», la finestra del gioco e' un pezzo della
# finestra dell'editor: Godot non la mette a schermo intero e non la sposta
# (scrive solo «Embedded window only supports Windowed mode.» nell'output).
# L'interruttore dello schermo intero li' non poteva fare niente, e sembrava
# rotto. Si prova avviando il gioco in una finestra sua.
var incorporato := Engine.is_embedded_in_editor()
var schermo: Object = DisplayServer   # le prove ne passano uno finto: in --headless quello vero non fa niente

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
	movimento_ridotto = bool(cfg.get_value("accessibilita", "movimento_ridotto", false))
	allenamento_gia_fatto = bool(cfg.get_value("progressi", "allenamento_gia_fatto", false))

func salva() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", volume_master)
	cfg.set_value("audio", "musica", volume_musica)
	cfg.set_value("audio", "effetti", volume_effetti)
	cfg.set_value("grafica", "schermo_intero", schermo_intero)
	cfg.set_value("accessibilita", "testo_grande", testo_grande)
	cfg.set_value("accessibilita", "alto_contrasto", alto_contrasto)
	cfg.set_value("accessibilita", "movimento_ridotto", movimento_ridotto)
	cfg.set_value("accessibilita", "velocita_testo", velocita_testo)
	cfg.set_value("progressi", "allenamento_gia_fatto", allenamento_gia_fatto)
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
	if incorporato:
		return
	DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if schermo_intero else DisplayServer.WINDOW_MODE_WINDOWED)
	if not schermo_intero:
		entra_nello_schermo()

func entra_nello_schermo() -> void:
	var dentro: Vector2i = schermo.window_get_size()
	var cornice: Vector2i = schermo.window_get_size_with_decorations() - dentro
	var giusta := finestra_che_entra(dentro, cornice, schermo.screen_get_usable_rect(schermo.window_get_current_screen()))
	if giusta.has_area():
		schermo.window_set_size(giusta.size)
		schermo.window_set_position(giusta.position)

func finestra_che_entra(dentro: Vector2i, cornice: Vector2i, utile: Rect2i) -> Rect2i:
	# LA FINESTRA STA NELLO SCHERMO. 1280x720, piu' la barra del titolo, su
	# uno schermo 1366x768 con la barra delle applicazioni non ci sta: Godot la
	# centra lo stesso, e la barra del titolo finisce sopra il bordo, dove non
	# la si puo' afferrare. Se non ci sta, si rimpicciolisce (stesse
	# proporzioni) e si centra con la cornice dentro. Rect2i() = va gia' bene
	var posto := utile.size - cornice
	if posto.x <= 0 or posto.y <= 0 or (dentro.x <= posto.x and dentro.y <= posto.y):
		return Rect2i()
	var k := minf(float(posto.x) / float(dentro.x), float(posto.y) / float(dentro.y))
	var nuova := Vector2i(Vector2(dentro) * k)
	var bordo := floori(cornice.x * 0.5)   # il bordo di lato; sopra c'e' anche la barra del titolo
	return Rect2i(utile.position + Vector2i(bordo, cornice.y - bordo) + Vector2i(Vector2(posto - nuova) * 0.5), nuova)

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
