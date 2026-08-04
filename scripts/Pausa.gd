extends CanvasLayer

# Autoload: il menu di pausa, disponibile ovunque con ESC (azione "ui_cancel").
#
# Perche' un autoload e non una scena: da dentro uno squarcio non si puo'
# cambiare scena per aprire un menu — la schermata eventi verrebbe distrutta e
# rientrarci rifarebbe partire il nodo corrente (con i suoi agguati). Qui
# invece e' tutto un velo sopra la scena viva, che non tocca niente di quello
# che c'e' sotto.
#
# Tre pannelli, uno alla volta:
#   menu     -> Riprendi / Storico / Diario / Personaggio / Opzioni / Esci
#   storico  -> i messaggi gia' letti (GameState.storico), dal piu' recente
#   diario   -> chi sei diventato: statistiche, come sono cresciute, passive,
#               squadra, creature studiate, valutazione dell'Organizzazione
#
# Mentre e' aperto l'albero e' in pausa (get_tree().paused): i tween si
# fermano, i timer del combattimento si fermano, niente va avanti alle spalle
# del giocatore. Questo nodo e AudioManager restano in PROCESS_MODE_ALWAYS,
# altrimenti si metterebbe in pausa anche la musica e il menu stesso.

const LIVELLO := 100
# schermate dove la pausa non ha senso (o dove ESC ha gia' un suo significato)
const SCENE_ESCLUSE := [
	"res://scenes/Splash.tscn",
	"res://scenes/Menu.tscn",
	"res://scenes/Opzioni.tscn",
	"res://scenes/Extra.tscn",
]
const SCENA_MENU := "res://scenes/Menu.tscn"

var velo: ColorRect
var contenitore: MarginContainer
var colonna: VBoxContainer
var aperta := false
var pannello := "menu"  # menu | storico | diario | equipaggiamento | opzioni | uscita

func _ready() -> void:
	layer = LIVELLO
	process_mode = Node.PROCESS_MODE_ALWAYS
	AudioManager.process_mode = Node.PROCESS_MODE_ALWAYS  # la musica non si interrompe in pausa
	velo = ColorRect.new()
	velo.color = Color(0, 0, 0, 0.86)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.visible = false
	add_child(velo)
	contenitore = MarginContainer.new()
	contenitore.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	contenitore.add_theme_constant_override("margin_left", 90)
	contenitore.add_theme_constant_override("margin_right", 90)
	contenitore.add_theme_constant_override("margin_top", 50)
	contenitore.add_theme_constant_override("margin_bottom", 50)
	velo.add_child(contenitore)

func _unhandled_input(evento: InputEvent) -> void:
	if not evento.is_action_pressed("ui_cancel"):
		return
	if aperta:
		# ESC da un sotto-pannello torna al menu, non butta fuori dalla pausa:
		# chi stava rileggendo lo storico non vuole ritrovarsi in combattimento
		if pannello == "menu":
			chiudi()
		else:
			mostra_menu()
	elif pausabile():
		apri()
	get_viewport().set_input_as_handled()

func pausabile() -> bool:
	# niente pausa a meta' di una dissolvenza tra schermate: si riaprirebbe su
	# una scena che sta gia' sparendo
	if Transizioni.in_corso:
		return false
	var scena := get_tree().current_scene
	if scena == null:
		return false
	return scena.scene_file_path not in SCENE_ESCLUSE

# --- apertura/chiusura ---

func apri() -> void:
	aperta = true
	velo.visible = true
	get_tree().paused = true
	mostra_menu()

func apri_su(quale: String) -> void:
	# Aprire direttamente un pannello, senza passare dal menu di pausa. Serve
	# alla Sede: "Alloggi" e "Archivio" sono stanze di un posto, non voci di un
	# menu, e devono portare dritto dove dicono. Il pannello vive qui perche' e'
	# un velo sopra la scena viva: si chiude e si torna esattamente dov'eri.
	aperta = true
	velo.visible = true
	get_tree().paused = true
	match quale:
		"diario": mostra_diario()
		"equipaggiamento": mostra_equipaggiamento()
		"storico": mostra_storico()
		_: mostra_menu()

func chiudi() -> void:
	aperta = false
	velo.visible = false
	get_tree().paused = false
	svuota()

func svuota() -> void:
	if colonna != null and is_instance_valid(colonna):
		colonna.queue_free()
	colonna = null

func nuova_colonna() -> VBoxContainer:
	svuota()
	colonna = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 14)
	contenitore.add_child(colonna)
	return colonna

func intestazione(testo: String) -> void:
	var titolo := Label.new()
	titolo.text = testo
	titolo.add_theme_font_size_override("font_size", Stile.dimensione("sezione"))
	titolo.add_theme_color_override("font_color", Stile.colore("accento"))
	colonna.add_child(titolo)

func bottone(testo: String, richiamo: Callable) -> Button:
	var b := Button.new()
	b.text = testo
	Stile.scelta(b)
	b.pressed.connect(richiamo)
	colonna.add_child(b)
	return b

# --- pannello: menu ---

func mostra_menu() -> void:
	nuova_colonna()
	pannello = "menu"
	intestazione("Pausa")
	var primo := bottone("Riprendi", chiudi)
	bottone("Storico dei dialoghi", mostra_storico)
	bottone("Diario", mostra_diario)
	bottone("Personaggio e squadra", mostra_equipaggiamento)
	bottone("Opzioni", mostra_opzioni)
	bottone("Torna al menu principale", conferma_uscita)
	primo.grab_focus()

# --- pannello: opzioni ---

func mostra_opzioni() -> void:
	# Le opzioni si possono guardare anche mentre giochi: alzare il volume a
	# meta' di uno scontro non e' amministrare una partita. Sono le stesse della
	# schermata principale, perche' l'elenco e' uno solo (PannelloOpzioni) - la
	# pausa non ne mostra piu' due su sei come faceva prima.
	nuova_colonna()
	pannello = "opzioni"
	intestazione("Opzioni")
	PannelloOpzioni.costruisci(colonna, 200)
	bottone("Indietro", mostra_menu).grab_focus()

func conferma_uscita() -> void:
	# uscire da qui butta via i progressi della zona in corso: si salva solo
	# dalla mappa stellare, quindi va detto chiaro prima di farlo
	nuova_colonna()
	pannello = "uscita"
	intestazione("Tornare al menu?")
	var avviso := Label.new()
	avviso.text = "Il gioco si salva da solo quando rientri alla Sede: tutto quello che hai\nfatto dentro questa zona (stanze, oggetti raccolti, Tazo) andrà perso."
	avviso.add_theme_color_override("font_color", Stile.colore("pericolo"))
	colonna.add_child(avviso)
	var primo := bottone("No, resto qui", mostra_menu)
	bottone("Sì, torna al menu principale", func() -> void:
		chiudi()
		GameState.reset_campagna()
		Transizioni.vai(SCENA_MENU))
	primo.grab_focus()

# --- pannello: storico ---

func mostra_storico() -> void:
	nuova_colonna()
	pannello = "storico"
	intestazione("Storico dei dialoghi")
	var scorrevole := ScrollContainer.new()
	scorrevole.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna.add_child(scorrevole)
	var righe := VBoxContainer.new()
	righe.add_theme_constant_override("separation", 12)
	righe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.add_child(righe)
	if GameState.storico.is_empty():
		var vuoto := Label.new()
		vuoto.text = "Non hai ancora letto niente."
		Stile.etichetta_piccola(vuoto)
		righe.add_child(vuoto)
	for voce in GameState.storico:
		righe.add_child(riga_storico(voce))
	bottone("Indietro", mostra_menu).grab_focus()
	# si apre gia' in fondo: l'ultima cosa letta e' quella che interessa di piu'
	await get_tree().process_frame
	if is_instance_valid(scorrevole):
		scorrevole.scroll_vertical = int(scorrevole.get_v_scroll_bar().max_value)

func riga_storico(voce: Dictionary) -> Control:
	var tipo := String(voce.get("tipo", "narrazione"))
	var chi := String(voce.get("chi", ""))
	var testo := String(voce.get("testo", ""))
	var blocco := VBoxContainer.new()
	blocco.add_theme_constant_override("separation", 2)
	if chi != "":
		var nome := Label.new()
		nome.text = chi
		nome.add_theme_color_override("font_color", Stile.colore("accento"))
		nome.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
		blocco.add_child(nome)
	var corpo := RichTextLabel.new()
	corpo.bbcode_enabled = true
	corpo.fit_content = true
	corpo.scroll_active = false
	corpo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corpo.add_theme_font_size_override("normal_font_size", Stile.dimensione("piccolo"))
	corpo.add_theme_font_size_override("italics_font_size", Stile.dimensione("piccolo"))
	corpo.add_theme_font_size_override("bold_font_size", Stile.dimensione("piccolo"))
	match tipo:
		"dialogo":
			corpo.text = testo
			corpo.add_theme_color_override("default_color", Stile.colore("testo"))
		"notifica":
			corpo.text = testo
			corpo.add_theme_color_override("default_color", Stile.colore("accento"))
		"titolo":
			corpo.text = "[b]%s[/b]" % testo
			corpo.add_theme_color_override("default_color", Stile.colore("accento"))
		_:
			corpo.text = "[i]%s[/i]" % testo
			corpo.add_theme_color_override("default_color", Stile.colore("narrazione"))
	blocco.add_child(corpo)
	return blocco

# --- pannello: diario ---

func mostra_diario() -> void:
	nuova_colonna()
	pannello = "diario"
	intestazione("Diario — unità Pk09")
	var scorrevole := ScrollContainer.new()
	scorrevole.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna.add_child(scorrevole)
	var corpo := VBoxContainer.new()
	corpo.add_theme_constant_override("separation", 18)
	corpo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrevole.add_child(corpo)
	sezione_appunti(corpo)
	sezione_stato(corpo)
	sezione_crescita(corpo)
	sezione_passive(corpo)
	sezione_squadra(corpo)
	sezione_osservazioni(corpo)
	sezione_organizzazione(corpo)
	bottone("Indietro", mostra_menu).grab_focus()

func sezione_appunti(genitore: VBoxContainer) -> void:
	# la prima cosa che si legge aprendo il Diario: dove devo andare adesso.
	# Non sono obiettivi con la spunta, sono pensieri del protagonista, quindi
	# stanno in corsivo e per esteso — la spunta e' solo un promemoria di
	# quello che ha gia' risolto
	titolo_sezione(genitore, "Appunti")
	if GameState.task_attivi.is_empty() and GameState.task_chiusi.is_empty():
		var vuoto := Label.new()
		vuoto.text = "Niente da segnare, per ora."
		Stile.etichetta_piccola(vuoto)
		genitore.add_child(vuoto)
		return
	for id_task in GameState.task_attivi:
		genitore.add_child(riga_appunto(GameState.dati_task(id_task)))
	if GameState.task_chiusi.is_empty():
		return
	var separatore := Label.new()
	separatore.text = "Già risolti"
	Stile.etichetta_piccola(separatore)
	genitore.add_child(separatore)
	for id_task in GameState.task_chiusi:
		var voce := GameState.dati_task(id_task)
		var fatto := Label.new()
		fatto.text = "✓  " + String(voce.get("titolo", id_task))
		Stile.etichetta_piccola(fatto)
		fatto.modulate = Color(1, 1, 1, 0.55)
		genitore.add_child(fatto)

func riga_appunto(voce: Dictionary) -> Control:
	var blocco := VBoxContainer.new()
	blocco.add_theme_constant_override("separation", 4)
	var intestazione_riga := Label.new()
	intestazione_riga.text = "◆  " + String(voce.get("titolo", ""))
	intestazione_riga.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	intestazione_riga.add_theme_color_override("font_color", Stile.colore("bordo_acceso"))
	blocco.add_child(intestazione_riga)
	var chi := String(voce.get("da", ""))
	if chi != "":
		# chi ha chiesto la cosa puo' essere un png (personaggi.json) o un
		# compagno giocabile (classes.json): si guarda in tutt'e due
		var scheda: Dictionary = GameState.personaggi.get(chi, {})
		var nome := String(scheda.get("nome", ""))
		if nome == "":
			var classe: Dictionary = GameState.classi.get(chi, {})
			nome = String(classe.get("nome", chi))
		var firma := Label.new()
		firma.text = "chiesto da " + nome
		Stile.etichetta_piccola(firma)
		blocco.add_child(firma)
	var corpo := RichTextLabel.new()
	corpo.bbcode_enabled = true
	corpo.fit_content = true
	corpo.scroll_active = false
	corpo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corpo.text = "[i]%s[/i]" % String(voce.get("testo", ""))
	corpo.add_theme_color_override("default_color", Stile.colore("narrazione"))
	corpo.add_theme_font_size_override("normal_font_size", Stile.dimensione("piccolo"))
	corpo.add_theme_font_size_override("italics_font_size", Stile.dimensione("piccolo"))
	blocco.add_child(corpo)
	return blocco

# --- pannello: equipaggiamento ---
#
# Gli slot non sono numeri, sono ruoli diversi: un'arma decide come colpisci,
# uno stigma e' un patto (da' e toglie), i quattro accessori sono i piccoli
# aggiustamenti, l'ultima risorsa e' la rete che scatta quando stai per cadere.
# Ogni personaggio ha i suoi, e quello che porta vale solo per lui.

const NOMI_SLOT := {
	"arma": "Arma",
	"stigma": "Stigma",
	"accessori": "Accessori",
	"ultima_risorsa": "Ultima risorsa",
}

func mostra_equipaggiamento() -> void:
	# La scheda del personaggio: chi e', cosa porta addosso, quanto vale, e la
	# stessa cosa per ogni compagno. Vive qui dentro invece che come schermata a
	# se' perche' cosi' si apre da ovunque - mappa, stanza, Vuoto, combattimento -
	# senza cambiare scena e senza perdere il posto in cui si era.
	# Come e' fatta e perche': vedi scripts/Personaggio.gd.
	nuova_colonna()
	pannello = "equipaggiamento"
	var scheda := SchedaPersonaggio.new()
	colonna.add_child(scheda)
	scheda.apri(mostra_menu, mostra_diario)

func etichetta_bonus(chiave: String) -> String:
	match chiave:
		"attacco": return "attacco"
		"difesa": return "difesa"
		"velocita": return "velocità"
		"hp_max": return "vita massima"
		"aura_max": return "aura massima"
		"aura_per_turno": return "aura per turno"
		"resistenza_maledizione": return "rintocchi di maledizione"
		_: return chiave

func oggetti_per(slot: String) -> Array[String]:
	# cosa si puo' mettere in questo slot: del tipo giusto, posseduto, e non
	# gia' addosso a qualcun altro
	var risultato: Array[String] = []
	var magazzino: Array = GameState.magazzino_per_slot(slot)
	for id_oggetto in magazzino:
		var id_stringa := String(id_oggetto)
		if id_stringa in risultato or GameState.e_equipaggiato(id_stringa):
			continue
		var tipo := String(GameState.dati_oggetto(id_stringa).get("tipo", ""))
		var atteso := "consumabile"
		if slot == "accessori":
			atteso = "accessorio"
		elif slot != "ultima_risorsa":
			atteso = slot
		if tipo == atteso:
			risultato.append(id_stringa)
	return risultato

func riassunto_effetto(dati: Dictionary) -> String:
	# cosa fa davvero, in numeri: la descrizione poetica sta nel Compendio
	var effetto: Dictionary = dati.get("effetto_equipaggiato", dati.get("effetto", {}))
	var voci: Array[String] = []
	for chiave in effetto:
		var nome_chiave := String(chiave)
		match nome_chiave:
			"tipo":
				continue
			"cura_stato":
				var definizione: Dictionary = GameState.stati.get(effetto[chiave], {})
				voci.append("toglie " + String(definizione.get("nome", effetto[chiave])).to_lower())
			"cura_stati":
				voci.append("toglie ogni male")
			"hp":
				voci.append("+%d vita" % int(effetto[chiave]))
			"aura":
				voci.append("+%d aura" % int(effetto[chiave]))
			"danno":
				voci.append("%d danni al nemico" % int(effetto[chiave]))
			_:
				voci.append("%s %+d" % [etichetta_bonus(nome_chiave), int(effetto[chiave])])
	if String(effetto.get("tipo", "")) == "scudo_primo_stato":
		voci.append("respinge il primo male che ti prende")
	if String(effetto.get("tipo", "")) == "resurrezione_dimezzata":
		voci.append("ti rimette in piedi una volta")
	return ", ".join(voci) if not voci.is_empty() else "nessun effetto"

func titolo_sezione(genitore: VBoxContainer, testo: String) -> void:
	var t := Label.new()
	t.text = testo
	t.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	t.add_theme_color_override("font_color", Stile.colore("accento"))
	genitore.add_child(t)

func voce_diario(genitore: VBoxContainer, etichetta: String, valore: String) -> void:
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 12)
	genitore.add_child(riga)
	var sinistra := Label.new()
	sinistra.text = etichetta
	sinistra.custom_minimum_size = Vector2(280, 0)
	Stile.etichetta_piccola(sinistra)
	riga.add_child(sinistra)
	var destra := Label.new()
	destra.text = valore
	destra.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	riga.add_child(destra)

func sezione_stato(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Stato")
	var livello := GameState.livello_di(GameState.id_protagonista)
	var xp_ora := int(GameState.xp.get(GameState.id_protagonista, 0))
	voce_diario(genitore, "Livello", "%d  (%d / %d esperienza)" % [livello, xp_ora, GameState.fabbisogno_xp(livello)])
	var tabella_stat: Dictionary = GameState.crescita.get("stat", {})
	for chiave in tabella_stat:
		var nome_stat := String(chiave)
		var info: Dictionary = tabella_stat[chiave]
		var guadagnati := int(GameState.punti_stat.get(nome_stat, 0))
		var testo := str(GameState.stat_di(nome_stat))
		if guadagnati > 0:
			testo += "   (base %d + %d guadagnati)" % [GameState.stat_base_di(nome_stat), guadagnati]
		voce_diario(genitore, String(info.get("nome", nome_stat)), testo)

func sezione_crescita(genitore: VBoxContainer) -> void:
	# la parte piu' utile del diario: non "quanto vali", ma COSA ti sta facendo
	# crescere. Ogni riga dice quanto manca al prossimo punto di quella stat.
	titolo_sezione(genitore, "Cosa ti sta cambiando")
	var regole_crescita: Dictionary = GameState.crescita.get("crescita", {})
	if regole_crescita.is_empty():
		return
	var tabella_stat: Dictionary = GameState.crescita.get("stat", {})
	for chiave in regole_crescita:
		var nome_azione := String(chiave)
		var regola: Dictionary = regole_crescita[chiave]
		var ogni := maxi(int(regola.get("ogni", 1)), 1)
		var fatte := int(GameState.contatori.get(nome_azione, 0))
		var nome_stat := String(regola.get("stat", ""))
		var info_stat: Dictionary = tabella_stat.get(nome_stat, {})
		var nome_leggibile := String(info_stat.get("nome", nome_stat))
		voce_diario(genitore, etichetta_azione(nome_azione),
				"%d / %d verso +%d %s" % [fatte % ogni, ogni, int(regola.get("punti", 1)), nome_leggibile])

func etichetta_azione(nome_azione: String) -> String:
	match nome_azione:
		"attacchi_sferrati": return "Colpi che hai sferrato"
		"danni_subiti": return "Danni che hai incassato"
		"difese": return "Volte che hai tenuto la guardia"
		"studi": return "Creature che hai studiato"
		"fughe": return "Volte che sei scappato"
		"oggetti_usati": return "Oggetti che hai usato"
		"stanze_esplorate": return "Stanze che hai esplorato"
		"stress_accumulato": return "Stress che hai retto"
		"critici_inflitti": return "Colpi critici che hai messo a segno"
		_: return nome_azione

func sezione_passive(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Abilità passive")
	if GameState.passive_sbloccate.is_empty():
		var vuoto := Label.new()
		vuoto.text = "Nessuna, per ora."
		Stile.etichetta_piccola(vuoto)
		genitore.add_child(vuoto)
		return
	for gruppo in ["passive_livello", "passive_soglia", "passive_rare"]:
		var elenco: Array = GameState.crescita.get(gruppo, [])
		for elemento in elenco:
			var voce: Dictionary = elemento
			if not GameState.ha_passiva(String(voce.get("id", ""))):
				continue
			voce_diario(genitore, String(voce.get("nome", "")), String(voce.get("descrizione", "")))

func sezione_squadra(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Squadra")
	voce_diario(genitore, "Legame", "%d / 100" % GameState.legame)
	for id_classe in GameState.party:
		if id_classe == GameState.id_protagonista:
			continue
		var definizione: Dictionary = GameState.classi.get(id_classe, {})
		var nome := String(definizione.get("nome", id_classe))
		var temporaneo := " (temporaneo)" if id_classe in GameState.alleati_temporanei else ""
		voce_diario(genitore, nome + temporaneo, "Lv %d   ·   stress %d" % [
			GameState.livello_di(id_classe), GameState.stress_di(id_classe)])

func sezione_osservazioni(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Osservazioni")
	voce_diario(genitore, "Creature studiate", "%d" % GameState.studiati.size())
	voce_diario(genitore, "Creature incontrate", "%d" % GameState.bestiario.size())
	voce_diario(genitore, "Oggetti catalogati", "%d / %d" % [
		GameState.oggetti_catalogo.size(), GameState.oggetti.size()])
	if GameState.resistenze_stato.is_empty():
		return
	for chiave in GameState.resistenze_stato:
		var definizione: Dictionary = GameState.stati.get(chiave, {})
		var nome := String(definizione.get("nome", chiave))
		voce_diario(genitore, "Resistenza — " + nome, "+%d" % int(GameState.resistenze_stato[chiave]))

func sezione_organizzazione(genitore: VBoxContainer) -> void:
	titolo_sezione(genitore, "Organizzazione")
	voce_diario(genitore, "Fonti estinte", "%d" % GameState.fonti_estinte)
	voce_diario(genitore, "Valutazione", valutazione_organizzazione())

func valutazione_organizzazione() -> String:
	# l'Organizzazione parla per gradi, non per percentuali: e' un giudizio,
	# non una barra. Sale con le fonti estinte
	match GameState.fonti_estinte:
		0: return "In osservazione."
		1: return "Prestazione conforme alle attese."
		2: return "Rendimento soddisfacente."
		3: return "Elemento affidabile."
		_: return "Elemento di valore. Aspettative in aumento."
