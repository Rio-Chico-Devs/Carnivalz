extends Control

# Combattimento a turni. Party e nemici in un'unica fila d'iniziativa
# ordinata per velocità (ricalcolata a ogni giro). Stats: hp, attacco,
# difesa, velocità, fattore. I buff sono temporanei (n turni). I boss hanno
# "mosse" pesate nei dati (attacco forte / a tutti / buff / evoca) che
# rendono ogni scontro unico. Menu azioni del giocatore: Attacca,
# Difenditi, Abilità (Studia sempre disponibile), Oggetti (dalla sacca),
# Alleati (ospiti non combattenti). Esito eroe via speranza e cedimento.
# Numeri in data/regole.json, casualità solo dall'RNG seedato di GameState.

signal azione_scelta(azione: Dictionary)

const SCENA_EVENTI := "res://scenes/Main.tscn"
const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_RITRATTO := preload("res://scenes/Ritratto.tscn")

@onready var fila_party: HBoxContainer = %Party
@onready var nemico_centro: HBoxContainer = %NemicoCentro
@onready var nemici_sinistra: HBoxContainer = %NemiciSinistra
@onready var nemici_destra: HBoxContainer = %NemiciDestra
@onready var etichetta_speranza: Label = %Speranza
@onready var diario: RichTextLabel = %Diario
@onready var azioni: HBoxContainer = %Azioni

var combattenti: Array[Dictionary] = []
var in_corso := true
var giocatore_ha_vinto := false
var giocatore_e_fuggito := false
var xp_bottino := 0
var tazo_bottino := 0

var fonte: Dictionary = {}
var speranza := 0
var convinto := false
var turni_fermo_leva := 0
var testo_fermo_leva := ""
var indice_studio := 0
var alleati_usati: Array[String] = []
var attaccante_corrente: Dictionary = {}

# Frenesia: un nemico (non necessariamente una fonte) puo' avere nei dati
# una chiave "frenesia" - a una soglia di hp innesca un conto alla rovescia:
# se non fermato, maleficio e KO totale. Si ferma studiando il nemico
# (rivela un bersaglio extra, es. un oggetto di scena) e distruggendolo.
var portatore_frenesia: Dictionary = {}
var frenesia_attiva := false
var frenesia_gia_innescata := false
var conteggio_frenesia := 0
var turni_afflitto := 0
var bersaglio_extra_sbloccato := false

# Stati generici (veleno, congelamento, berserk, maledizione...): vedi
# data/stati.json. Provocazione: un compagno forza i nemici a colpire lui.
var bersaglio_provocazione: Dictionary = {}
var turni_provocazione := 0
var ultima_azione_offensiva := false

# Incontro scriptato: un nemico puo' avere "incontro_scriptato" nei dati per
# una sequenza di combattimento interamente scritta - una fase iniziale di
# paralisi, un primo tentativo di fuga che fallisce sempre senza rischio (dal
# secondo in poi funziona normalmente), e una sua escalation di turni inerti
# che finisce in una scena fatale scriptata se non si fugge (o vince) in
# tempo - l'unico modo di perdere questo scontro. Usato per ora solo dalla
# manifestazione di un sogno nel tutorial.
# tutorial guidato: un nemico puo' portare uno script che detta, turno per
# turno, quale azione il giocatore deve compiere. Il menu si riduce a quella
# (piu' Studia, sempre libero), il bottone giusto viene evidenziato, e finche'
# non la si esegue non si va avanti. Nessuna automazione: le azioni le fa il
# giocatore.
var tutorial: Dictionary = {}
var tutorial_passo := 0
var tutorial_finito := false
var tutorial_passi_introdotti: Array[int] = []

var portatore_incontro: Dictionary = {}
var incontro_apertura_mostrata := false
var incontro_tentativi_fuga := 0
var incontro_turni_inerti := 0
var incontro_tentativi_morfeo := 0

# blocca_fuga_turni: un nemico puo' impedire di fuggire per i suoi primi N
# turni (es. l'Immortale, debole ma non lo si puo' davvero sconfiggere:
# l'unica via d'uscita e' resistere e poi scappare). avviso_fuga mostra un
# testo una tantum al turno indicato, se il compagno richiesto e' in squadra
var giro_corrente := 1
var portatore_fuga_bloccata: Dictionary = {}
var avviso_fuga_mostrato := false

# dialogo_soglia_hp: un nemico puo' dichiarare un hp_soglia e un testo che
# compare una sola volta, alla prima discesa sotto quella soglia.
var soglie_dialogo_mostrate: Dictionary = {}  # indice combattente -> bool

# rabbia_su_morte_alleato: un nemico puo' dichiarare che la morte di un
# certo alleato (es. una sua evocazione) ne aumenta l'attacco - il goblin
# arrabbiato del tutorial diventa piu' pericoloso ogni goblin tipico che cade.
var portatore_rabbia: Dictionary = {}

# Accessorio equipaggiato (GameState.accessorio_equipaggiato): effetto
# passivo attivo per l'intero combattimento, letto una volta in _ready().
# "scudo_primo_stato": respinge il primo stato subito nello scontro e
# immunizza da quello stato per il resto (Combattimento.applica_stato()).
# "resurrezione_dimezzata": chi morirebbe torna in vita a meta' hp, una
# sola volta per combattimento (Combattimento._su_ko()).
var effetto_accessorio: Dictionary = {}
var scudo_primo_stato_pronto := false
var resurrezione_pronta := false

# Il primo nemico (il boss, o il primo di un gruppo comune) resta sempre al
# centro del campo; chi si aggiunge dopo (altri della stessa imboscata, o
# un'evocazione) si dispone ai lati, alternando destra e sinistra.
var nemico_centrale_occupato := false
var prossimo_lato_nemico := "destra"

func _ready() -> void:
	if GameState.accessorio_equipaggiato != "":
		effetto_accessorio = GameState.dati_oggetto(GameState.accessorio_equipaggiato).get("effetto_equipaggiato", {})
		scudo_primo_stato_pronto = effetto_accessorio.get("tipo", "") == "scudo_primo_stato"
		resurrezione_pronta = effetto_accessorio.get("tipo", "") == "resurrezione_dimezzata"
	for id_classe in GameState.party:
		aggiungi_combattente(id_classe, true)
	for id_nemico in GameState.nemici_combattimento:
		aggiungi_combattente(id_nemico, false)
		var dati: Dictionary = GameState.personaggi.get(id_nemico, {})
		if fonte.is_empty() and dati.get("fonte", false):
			fonte = dati
		if portatore_frenesia.is_empty() and dati.has("frenesia"):
			portatore_frenesia = dati
		if portatore_incontro.is_empty() and dati.has("incontro_scriptato"):
			portatore_incontro = dati
		if portatore_rabbia.is_empty() and dati.has("rabbia_su_morte_alleato"):
			portatore_rabbia = dati
		if portatore_fuga_bloccata.is_empty() and dati.has("blocca_fuga_turni"):
			portatore_fuga_bloccata = dati
		if tutorial.is_empty() and dati.has("tutorial_combattimento"):
			tutorial = dati["tutorial_combattimento"]
			for id_oggetto in tutorial.get("oggetti_forniti", []):
				if not GameState.possiede_oggetto(String(id_oggetto)):
					GameState.aggiungi_oggetto(String(id_oggetto))
	var categoria_apertura := categoria_migliore_presente()
	if categoria_apertura == "boss" or categoria_apertura == "miniboss":
		scrivi("[b]Il disallineamento fa spazio: si combatte.[/b]")
	else:
		scrivi("[b]Ora di combattere.[/b]")
	avvia_musica_e_voce()
	if fonte.get("convincibile", false):
		etichetta_speranza.visible = true
		aggiorna_speranza(0)
	applica_leve()
	esegui_scontro()

func categoria_di(dati: Dictionary) -> String:
	if dati.get("fonte", false):
		return "boss"
	if dati.has("frenesia"):
		return "miniboss"
	return String(dati.get("categoria", "comune"))

func categoria_migliore_presente() -> String:
	# la categoria più "alta" tra i nemici presenti (per musica e testo d'apertura)
	var ordine := ["boss", "miniboss", "particolare", "comune"]
	var migliore := ordine.size() - 1
	var categoria := "comune"
	for id_nemico in GameState.nemici_combattimento:
		var dati: Dictionary = GameState.personaggi.get(id_nemico, {})
		var idx := ordine.find(categoria_di(dati))
		if idx >= 0 and idx < migliore:
			migliore = idx
			categoria = ordine[idx]
	return categoria

func avvia_musica_e_voce() -> void:
	# musica per la categoria più "alta" tra i nemici; voce d'ingresso per boss/miniboss
	var categoria := categoria_migliore_presente()
	var principale: Dictionary = {}
	for id_nemico in GameState.nemici_combattimento:
		var dati: Dictionary = GameState.personaggi.get(id_nemico, {})
		if categoria_di(dati) == categoria and principale.is_empty():
			principale = dati
	AudioManager.musica_chiave("combattimento_" + categoria)
	if (categoria == "boss" or categoria == "miniboss") and not principale.is_empty():
		AudioManager.voce_boss(String(principale.get("id", "")), principale, "inizio")

func aggiungi_combattente(id_personaggio: String, giocatore: bool) -> void:
	var dati: Dictionary = GameState.personaggi.get(id_personaggio, {})
	var e_protagonista := giocatore and id_personaggio == GameState.id_protagonista
	var hp_max := int(GameState.stat_di("hp")) if e_protagonista \
			else int(dati.get("hp", GameState.regole.get("hp_base", 5)))
	var hp_iniziali := hp_max
	if giocatore and GameState.hp_persistenti.has(id_personaggio):
		# scontri incatenati: si riprende con i punti vita lasciati dal precedente
		hp_iniziali = clampi(int(GameState.hp_persistenti[id_personaggio]), 1, hp_max)
	var scheda := VBoxContainer.new()
	var ritratto := SCENA_RITRATTO.instantiate()
	scheda.add_child(ritratto)
	var vita := Label.new()
	vita.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scheda.add_child(vita)
	var extra := Label.new()
	extra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	extra.add_theme_font_size_override("font_size", 12)
	extra.modulate = Color(1, 1, 1, 0.7)
	scheda.add_child(extra)
	if giocatore:
		fila_party.add_child(scheda)
		ritratto.mostra(id_personaggio, GameState.livello_di(id_personaggio))
	else:
		var e_il_centrale := false
		if not nemico_centrale_occupato:
			nemico_centrale_occupato = true
			e_il_centrale = true
			scheda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			scheda.size_flags_vertical = Control.SIZE_EXPAND_FILL
			nemico_centro.add_child(scheda)
		elif prossimo_lato_nemico == "destra":
			nemici_destra.add_child(scheda)
			prossimo_lato_nemico = "sinistra"
		else:
			nemici_sinistra.add_child(scheda)
			prossimo_lato_nemico = "destra"
		# solo dopo add_child: prima l'@onready interno del ritratto e' ancora nullo
		if e_il_centrale:
			ritratto.imposta_grande(true)  # il nemico principale e' sempre grande, in mezzo
		ritratto.mostra(id_personaggio)
		if dati.has("xp"):
			# voce nel bestiario al primo incontro (gli oggetti di scena non ne hanno)
			GameState.registra_bestiario(id_personaggio)
			AudioManager.verso(id_personaggio, dati, "comparsa")
	var combustione: Dictionary = dati.get("combustione", {})
	var combattente := {
		"indice": combattenti.size(),
		"id": id_personaggio,
		"nome": dati.get("nome_breve", dati.get("nome", id_personaggio)),
		"hp": hp_iniziali,
		"hp_max": hp_max,
		"attacco": GameState.stat_di("attacco") if e_protagonista else int(dati.get("attacco", 1)),
		"difesa": GameState.stat_di("difesa") if e_protagonista else int(dati.get("difesa", 0)),
		"velocita": GameState.stat_di("velocita") if e_protagonista else int(dati.get("velocita", 3)),
		"psiche": String(dati.get("psiche", "")),
		"fattore": GameState.stat_di("fattore") if e_protagonista else int(dati.get("fattore_base", 0)),
		"stress": GameState.stress_di(id_personaggio) if giocatore else 0,
		"xp": int(dati.get("xp", 10)),
		"tazo": int(dati.get("tazo", 0)),
		"carta": dati.get("carta", {}),
		"bottino_comune": dati.get("bottino_comune", []),
		"drop_raro": dati.get("drop_raro", {}),
		"mosse": dati.get("mosse", []),
		"mosse_usate": [],
		"peso_attacco_normale": int(dati.get("peso_attacco_normale", 4)),
		"giocatore": giocatore,
		"stati": [],
		"stati_attivi": {},
		"immunita_temporanea": [],
		"buffs": [],
		"difesa_accumulo": 0.0,
		"mossa_in_carica": {},
		"crisi_turni_rimasti": 0,
		"soglia_gia_scattata": false,
		"ultimo_danno_subito": 0,
		"colpi_incassati": 0,
		"gamba_rotta_turni": 0,
		"gamba_gia_rotta": false,
		"volte_studiato": 0,
		"combustione": combustione,
		"in_fiamme": not combustione.is_empty() and not combustione.has("attiva_da_studio"),
		"hp_nascosti": not giocatore and (categoria_di(dati) == "boss" or dati.has("incontro_scriptato")),
		"scheda": scheda,
		"etichetta_vita": vita,
		"etichetta_extra": extra,
	}
	combattenti.append(combattente)
	aggiorna_scheda(combattente)

func applica_leve() -> void:
	for leva in fonte.get("leve", []):
		var id_leva: String = leva.get("id", "")
		var presente := false
		match leva.get("tipo", ""):
			"oggetto":
				presente = GameState.possiede_oggetto(id_leva)
			"ospite":
				presente = id_leva in GameState.ospiti
			"compagno":
				presente = id_leva in GameState.party
			"flag":
				presente = GameState.ha_flag(id_leva)
		if presente:
			scrivi("[i]%s[/i]" % leva.get("testo", ""))
			aggiorna_speranza(int(leva.get("speranza", 0)))
			if leva.has("turni_fermo"):
				# la fonte resta ferma, senza agire, per un tot di suoi turni:
				# un premio extra per l'esplorazione, non solo un bonus speranza
				turni_fermo_leva = maxi(turni_fermo_leva, int(leva["turni_fermo"]))
				testo_fermo_leva = String(leva.get("testo_fermo", ""))

func aggiorna_speranza(quantita: int) -> void:
	if not fonte.get("convincibile", false):
		return
	speranza = clampi(speranza + quantita, 0, 100)
	etichetta_speranza.text = "Speranza %d / %d" % [speranza, int(fonte.get("speranza_soglia", 100))]
	if not convinto and speranza >= int(fonte.get("speranza_soglia", 100)):
		convinto = true
		scrivi("[b]%s[/b]" % fonte.get("testo_cedimento", "Qualcosa, nella fonte, ha ceduto."))
		AudioManager.voce_boss(String(fonte.get("id", "")), fonte, "cedimento")

func esegui_scontro() -> void:
	while in_corso:
		verifica_avviso_fuga()
		# il cedimento (e ora rapidita'/lentezza) cambiano la velocita':
		# l'iniziativa si ricalcola a ogni giro
		combattenti.sort_custom(func(a, b):
			var va := velocita_effettiva(a)
			var vb := velocita_effettiva(b)
			return a.indice < b.indice if va == vb else va > vb)
		for combattente in combattenti.duplicate():
			if not in_corso:
				break
			if combattente.hp <= 0 or combattente.get("oggetto_scena", false):
				continue  # gli oggetti di scena (es. le lettere) non agiscono mai
			await esegui_turno(combattente)
			var prob_extra := float(GameState.regole.get("probabilita_attacco_extra_rabbia", 0.35))
			if in_corso and combattente.hp > 0 \
					and ha_stato_con_effetto(combattente, "attacco_extra") \
					and GameState.rng.randf() < prob_extra:
				scrivi("%s è in preda alla rabbia e attacca di nuovo!" % combattente.nome)
				await esegui_turno(combattente)
		if in_corso:
			aggiorna_speranza(int(GameState.regole.get("speranza_per_giro", 2)))
			if turni_provocazione > 0:
				turni_provocazione -= 1
			giro_corrente += 1
	mostra_continua_fine()

func verifica_avviso_fuga() -> void:
	if portatore_fuga_bloccata.is_empty() or avviso_fuga_mostrato:
		return
	var avviso: Dictionary = portatore_fuga_bloccata.get("avviso_fuga", {})
	var turno_avviso := int(avviso.get("turno", 0))
	if turno_avviso <= 0 or giro_corrente < turno_avviso:
		return
	var richiede := String(avviso.get("richiede_compagno", ""))
	if richiede != "" and richiede not in GameState.party:
		return
	avviso_fuga_mostrato = true
	scrivi("[i]%s[/i]" % String(avviso.get("testo", "")))

func mostra_continua_fine() -> void:
	# niente si chiude da solo: e' il giocatore a decidere quando lasciare
	# la schermata di fine combattimento
	pulisci_azioni()
	bottone_azione("▸ Continua", _esci)

func esegui_turno(attaccante: Dictionary) -> void:
	scadenza_buff(attaccante)
	evidenzia(attaccante)
	if attaccante.in_fiamme:
		applica_combustione(attaccante)
		if attaccante.hp <= 0:
			return  # bruciato prima di poter agire
	if risolvi_stati_a_inizio_turno(attaccante):
		return  # il turno salta per uno stato (congelamento, sonno, egocentrismo, demotivazione) o la maledizione lo uccide
	ultima_azione_offensiva = false
	if attaccante.giocatore:
		attaccante_corrente = attaccante
		if ha_stato_attivo(attaccante, "berserk"):
			scrivi("[i]%s ha perso il controllo: può solo attaccare.[/i]" % attaccante.nome)
			var nemici := vivi(false)
			if not nemici.is_empty():
				attacca(attaccante, nemici[GameState.rng.randi_range(0, nemici.size() - 1)])
		else:
			var passo_corrente := passo_tutorial()
			if not passo_corrente.is_empty() and tutorial_passo not in tutorial_passi_introdotti:
				tutorial_passi_introdotti.append(tutorial_passo)
				for msg in passo_corrente.get("prima", []):
					scrivi_messaggio_tutorial(msg)
			mostra_azioni()
			var azione: Dictionary = await azione_scelta
			var bersaglio_scelto: Dictionary = azione.get("bersaglio", {})
			if azione.get("tipo", "") == "attacca" and ha_stato_attivo(attaccante, "confusione") \
					and GameState.rng.randf() < 0.5:
				var chiunque: Array[Dictionary] = []
				for c in vivi(true) + vivi(false):
					if c.indice != attaccante.indice:
						chiunque.append(c)
				if not chiunque.is_empty():
					bersaglio_scelto = chiunque[GameState.rng.randi_range(0, chiunque.size() - 1)]
					scrivi("[i]%s è confuso e colpisce %s per sbaglio![/i]" % [attaccante.nome, bersaglio_scelto.nome])
			if azione.get("tipo", "") != "difendi":
				# smette di accumularsi appena si fa altro: o si tiene la
				# guardia, o si rischia attaccando - non si ha tutto insieme
				attaccante.difesa_accumulo = 0.0
			avanza_tutorial(azione)
			match azione.get("tipo", ""):
				"attacca":
					attacca(attaccante, bersaglio_scelto)
				"difendi":
					difendi(attaccante)
				"studia":
					studia(attaccante)
				"oggetto":
					usa_oggetto(attaccante, azione.id)
				"alleato":
					usa_alleato(azione.id)
				"provoca":
					provoca(attaccante)
				"area":
					attacco_area(attaccante)
				"fuggi":
					fuggi(attaccante)
	else:
		await get_tree().create_timer(0.8).timeout
		turno_nemico(attaccante)
	if giocatore_e_fuggito:
		return  # il combattimento e' finito qui, niente altro da risolvere sul turno
	risolvi_dot_condizionale(attaccante, ultima_azione_offensiva)
	var passo := int(GameState.regole.get("stress_per_fattore", 25))
	var costo := floori(attaccante.fattore / float(maxi(passo, 1)))
	if costo > 0:
		aggiungi_stress(attaccante, costo)

# --- menu azioni del giocatore ---

func pulisci_azioni() -> void:
	for figlio in azioni.get_children():
		figlio.queue_free()

func bottone_azione(testo: String, richiamo: Callable, spento := false, evidenziato := false) -> void:
	var bottone := Button.new()
	bottone.text = ("▶  " + testo) if evidenziato else testo
	bottone.disabled = spento
	bottone.pressed.connect(richiamo)
	azioni.add_child(bottone)
	if evidenziato:
		# pulsa finche' non lo premi: e' li' che deve guardare il giocatore
		bottone.modulate = Color(1, 0.95, 0.5)
		var battito: Tween = bottone.create_tween().set_loops()
		battito.tween_property(bottone, "modulate:a", 0.5, 0.45)
		battito.tween_property(bottone, "modulate:a", 1.0, 0.45)

func scrivi_messaggio_tutorial(msg: Dictionary) -> void:
	var testo := String(msg.get("testo", ""))
	if testo.find("{nome}") != -1:
		testo = testo.replace("{nome}", String(GameState.personaggi.get(GameState.id_protagonista, {}).get("nome", "")))
	match String(msg.get("tipo", "narrazione")):
		"dialogo":
			var chi := String(msg.get("chi", GameState.id_protagonista))
			scrivi("%s: \"%s\"" % [String(GameState.personaggi.get(chi, {}).get("nome", chi)), testo])
		"notifica":
			scrivi("[b]%s[/b]" % testo)
		_:
			scrivi("[i]%s[/i]" % testo)

func avanza_tutorial(azione: Dictionary) -> void:
	# il passo si chiude solo se il giocatore ha fatto davvero quello che gli
	# era stato chiesto (Studia non consuma il passo: e' sempre concesso)
	var passo := passo_tutorial()
	if passo.is_empty():
		return
	if String(azione.get("tipo", "")) != String(passo.get("azione", "")):
		return
	if passo.has("oggetto") and String(azione.get("id", "")) != String(passo["oggetto"]):
		return
	for msg in passo.get("dopo", []):
		scrivi_messaggio_tutorial(msg)
	tutorial_passo += 1
	if tutorial_passo >= tutorial.get("passi", []).size():
		concludi_tutorial()

func concludi_tutorial() -> void:
	# lo scontro non si vince: finisce come deve finire, con la sua scena
	tutorial_finito = true
	for msg in tutorial.get("finale", []):
		scrivi_messaggio_tutorial(msg)
	sconfitta_scriptata()

func passo_tutorial() -> Dictionary:
	if tutorial.is_empty() or tutorial_finito:
		return {}
	var passi: Array = tutorial.get("passi", [])
	return passi[tutorial_passo] if tutorial_passo < passi.size() else {}

func mostra_azioni() -> void:
	pulisci_azioni()
	var passo := passo_tutorial()
	if not passo.is_empty():
		# tutorial: si puo' fare solo quello che ti viene chiesto (e Studia,
		# sempre libero: guardare non e' mai un errore)
		var richiesta := String(passo.get("azione", ""))
		bottone_azione("Attacca", _menu_bersagli, richiesta != "attacca", richiesta == "attacca")
		bottone_azione("Difenditi", _scegli.bind({"tipo": "difendi"}), richiesta != "difendi", richiesta == "difendi")
		bottone_azione("Abilità", _menu_abilita)
		bottone_azione("Oggetti", _menu_oggetti, richiesta != "oggetto", richiesta == "oggetto")
		return
	bottone_azione("Attacca", _menu_bersagli)
	bottone_azione("Difenditi", _scegli.bind({"tipo": "difendi"}))
	bottone_azione("Abilità", _menu_abilita)
	bottone_azione("Oggetti", _menu_oggetti, GameState.sacca.is_empty())
	bottone_azione("Alleati", _menu_alleati, alleati_disponibili().is_empty())
	bottone_azione("Fuggi", _scegli.bind({"tipo": "fuggi"}), not fuga_possibile())

func _menu_bersagli() -> void:
	var nemici := vivi(false)
	if nemici.size() == 1:
		_scegli({"tipo": "attacca", "bersaglio": nemici[0]})
		return
	pulisci_azioni()
	for nemico in nemici:
		bottone_azione("Attacca %s" % nemico.nome, _scegli.bind({"tipo": "attacca", "bersaglio": nemico}))
	bottone_azione("Indietro", mostra_azioni)

func _menu_abilita() -> void:
	pulisci_azioni()
	bottone_azione("Studia", _scegli.bind({"tipo": "studia"}))
	if "provocazione" in GameState.classi.get(attaccante_corrente.id, {}).get("abilita", []):
		bottone_azione("Provoca", _scegli.bind({"tipo": "provoca"}))
	if "attacco_area" in GameState.classi.get(attaccante_corrente.id, {}).get("abilita", []):
		bottone_azione("Colpo d'area", _scegli.bind({"tipo": "area"}))
	bottone_azione("Indietro", mostra_azioni)

func _menu_oggetti() -> void:
	pulisci_azioni()
	var conteggio := {}
	for id_oggetto in GameState.sacca:
		conteggio[id_oggetto] = int(conteggio.get(id_oggetto, 0)) + 1
	var passo := passo_tutorial()
	var solo_questo := String(passo.get("oggetto", "")) if not passo.is_empty() else ""
	for id_oggetto in conteggio:
		var nome: String = GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)
		var richiesto: bool = solo_questo != "" and String(id_oggetto) == solo_questo
		bottone_azione("%s ×%d" % [nome, conteggio[id_oggetto]],
				_scegli.bind({"tipo": "oggetto", "id": id_oggetto}),
				solo_questo != "" and not richiesto, richiesto)
	bottone_azione("Indietro", mostra_azioni)

func _menu_alleati() -> void:
	pulisci_azioni()
	for id_ospite in alleati_disponibili():
		var nome: String = GameState.personaggi.get(id_ospite, {}).get("nome", id_ospite)
		bottone_azione(nome, _scegli.bind({"tipo": "alleato", "id": id_ospite}))
	bottone_azione("Indietro", mostra_azioni)

func alleati_disponibili() -> Array[String]:
	var risultato: Array[String] = []
	for id_ospite in GameState.ospiti:
		if GameState.personaggi.get(id_ospite, {}).has("assist") and id_ospite not in alleati_usati:
			risultato.append(id_ospite)
	return risultato

func _scegli(azione: Dictionary) -> void:
	pulisci_azioni()
	azione_scelta.emit(azione)

# --- azioni ---

func difendi(chi: Dictionary) -> void:
	# cumulativa ma a rendimento decrescente: ogni uso in piu' si avvicina
	# a un tetto senza mai raggiungerlo (si azzera se sul turno successivo
	# si fa altro - vedi esegui_turno) - premia chi si difende con
	# continuita', ma non rende mai il danno subito davvero pari a zero
	var tetto := float(GameState.regole.get("difesa_difenditi_tetto", 6))
	var decadimento := float(GameState.regole.get("difesa_difenditi_decadimento", 0.5))
	chi.difesa_accumulo = float(chi.difesa_accumulo) + (tetto - float(chi.difesa_accumulo)) * decadimento
	var bonus := int(round(chi.difesa_accumulo))
	chi.buffs.append({
		"stat": "difesa",
		"valore": bonus,
		"turni": 1,
	})
	scrivi("%s si mette in guardia (difesa +%d)." % [chi.nome, bonus])
	if chi.giocatore and chi.id == GameState.id_protagonista:
		GameState.registra_azione("difese")
	aggiorna_scheda(chi)

func usa_oggetto(chi: Dictionary, id_oggetto: String) -> void:
	var dati := GameState.dati_oggetto(id_oggetto)
	GameState.sacca.erase(id_oggetto)
	scrivi("%s usa: %s." % [chi.nome, dati.get("nome", id_oggetto)])
	if chi.giocatore and chi.id == GameState.id_protagonista:
		GameState.registra_azione("oggetti_usati")
	applica_effetto(chi, dati.get("effetto", {}))

func usa_alleato(id_ospite: String) -> void:
	var assist: Dictionary = GameState.personaggi.get(id_ospite, {}).get("assist", {})
	alleati_usati.append(id_ospite)
	scrivi("[i]%s[/i]" % assist.get("testo", ""))
	applica_effetto(attaccante_corrente, assist.get("effetto", {}))

func applica_effetto(utente: Dictionary, effetto: Dictionary) -> void:
	if effetto.has("hp") and not utente.is_empty():
		utente.hp = clampi(utente.hp + int(effetto.hp), 0, utente.hp_max)
		aggiorna_scheda(utente)
	if effetto.has("stress") and not utente.is_empty():
		aggiungi_stress(utente, int(effetto.stress))
	if effetto.has("speranza"):
		aggiorna_speranza(int(effetto.speranza))
	if effetto.has("difesa_incontro") and not utente.is_empty():
		# dura per il resto dello scontro, non solo un turno come "Difenditi"
		utente.buffs.append({"stat": "difesa", "valore": int(effetto.difesa_incontro), "turni": 900})
		aggiorna_scheda(utente)
	if effetto.get("cura_stati", false) and not utente.is_empty():
		utente.stati_attivi.clear()
		aggiorna_scheda(utente)
	if effetto.has("danno"):
		var bersaglio := primo_nemico()
		if not bersaglio.is_empty():
			colpisci_diretto(bersaglio, int(effetto.danno))

func studia(chi: Dictionary) -> void:
	var bersaglio := primo_nemico()
	if bersaglio.is_empty():
		return
	if not portatore_frenesia.is_empty() and bersaglio.id == portatore_frenesia.id \
			and frenesia_attiva and not bersaglio_extra_sbloccato:
		bersaglio_extra_sbloccato = true
		var dati_frenesia: Dictionary = portatore_frenesia.get("frenesia", {})
		scrivi("%s: \"%s\"" % [bersaglio.nome, dati_frenesia.get("testo_sblocco_bersaglio", "")])
		attiva_bersaglio_extra()
		GameState.segna_studiato(bersaglio.id)
		return
	bersaglio.volte_studiato += 1
	if bersaglio.get("hp_nascosti", false) and "studio_compulsivo" in GameState.classi.get(chi.id, {}).get("abilita", []):
		# solo chi ha questa passiva riesce a strappare gli hp esatti a un
		# nemico che di norma non li mostra (i boss, o i nemici scriptati)
		bersaglio.hp_nascosti = false
		aggiorna_scheda(bersaglio)
		scrivi("[i]Studio compulsivo: %s scopre i punti vita esatti di %s.[/i]" % [chi.nome, bersaglio.nome])
	var dati: Dictionary = GameState.personaggi.get(bersaglio.id, {})
	var scambi: Array = dati.get("studio", [])
	if convinto and bersaglio.id == fonte.get("id", "") and dati.has("studio_cedimento"):
		scambi = dati["studio_cedimento"]
	if scambi.is_empty():
		scrivi("[i]%s non sembra rispondere ad alcun quesito.[/i]" % bersaglio.nome)
	elif dati.has("testo_studio_esaurito") and int(bersaglio.volte_studiato) > scambi.size():
		# il pool di scambi e' finito: non si ricomincia da capo all'infinito.
		# Se pero' il suo colpo fatale e' gia' stato respinto, non e' piu' lei a
		# confondere te: sei tu a vedere lei per quello che e' diventata
		var testo_esaurito := String(dati["testo_studio_esaurito"])
		if incontro_tentativi_morfeo > 0 and dati.get("incontro_scriptato", {}).has("testo_studio_dopo_scudo"):
			testo_esaurito = String(dati["incontro_scriptato"]["testo_studio_dopo_scudo"])
		scrivi("[i]%s[/i]" % testo_esaurito)
	else:
		var scambio: Dictionary = scambi[indice_studio % scambi.size()]
		indice_studio += 1
		if scambio.has("osservazione"):
			scrivi("[i]%s[/i]" % scambio["osservazione"])
		else:
			# le domande dei nemici generici sono pescate a caso da un pool
			# condiviso; solo boss e creature particolari hanno una domanda
			# scritta apposta
			var domanda: String = scambio.get("domanda", "")
			if domanda == "":
				domanda = GameState.domanda_studio_casuale()
			scrivi("%s: \"%s\"" % [chi.nome, domanda])
			scrivi("%s: \"%s\"" % [bersaglio.nome, scambio.get("risposta", "")])
	GameState.segna_studiato(bersaglio.id)
	if chi.giocatore and chi.id == GameState.id_protagonista:
		GameState.registra_azione("studi")
	if bersaglio.id == fonte.get("id", ""):
		aggiorna_speranza(int(GameState.regole.get("speranza_studio", 10)))
	verifica_innesco_combustione(bersaglio)
	if dati.has("risparmio") and bersaglio.hp > 0:
		risparmia(bersaglio, dati["risparmio"])

func risparmia(bersaglio: Dictionary, dati_risparmio: Dictionary) -> void:
	# studiare certi nemici rivela che non meritano di essere uccisi: escono
	# dal combattimento senza dare xp/tazo/drop, ma il legame sale e lo
	# stress della squadra scende. Gli altri nemici del combattimento restano.
	scrivi("[b]%s[/b]" % String(dati_risparmio.get("testo", "Decidi di risparmiarlo.")))
	if dati_risparmio.has("legame"):
		GameState.modifica_legame(int(dati_risparmio.legame))
	if dati_risparmio.has("stress"):
		for alleato in vivi(true):
			alleato.stress = clampi(alleato.stress + int(dati_risparmio.stress), 0, 100)
			aggiorna_scheda(alleato)
	if dati_risparmio.has("oggetto"):
		var id_oggetto := String(dati_risparmio.oggetto)
		if GameState.aggiungi_oggetto(id_oggetto):
			scrivi("[b]Ottieni:[/b] %s." % String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)))
	bersaglio.risparmiato = true
	bersaglio.hp = 0
	aggiorna_scheda(bersaglio)
	_su_ko(bersaglio)

func attiva_bersaglio_extra() -> void:
	var dati_frenesia: Dictionary = portatore_frenesia.get("frenesia", {})
	var id_bersaglio: String = dati_frenesia.get("bersaglio_extra", "")
	if id_bersaglio == "":
		return
	aggiungi_combattente(id_bersaglio, false)
	var oggetto: Dictionary = combattenti.back()
	oggetto.oggetto_scena = true
	oggetto.hp = int(dati_frenesia.get("bersaglio_extra_hp", 2))
	oggetto.hp_max = oggetto.hp
	oggetto.attacco = 0
	oggetto.difesa = 0
	oggetto.velocita = 0
	oggetto.xp = 0
	oggetto.tazo = 0
	aggiorna_scheda(oggetto)

func provoca(chi: Dictionary) -> void:
	bersaglio_provocazione = chi
	turni_provocazione = int(GameState.regole.get("forza_azione_durata", 2))
	scrivi("[i]%s si mette in mostra: i nemici non vedono altro che lui.[/i]" % chi.nome)

func attacco_area(chi: Dictionary) -> void:
	scrivi("[i]%s scatena un colpo che si abbatte su tutti i nemici![/i]" % chi.nome)
	var valore := int(round(attacco_di(chi) * float(GameState.regole.get("moltiplicatore_attacco_area", 0.6))))
	for nemico in vivi(false):
		attacca(chi, nemico, valore)

func fuggi(chi: Dictionary) -> void:
	if not portatore_incontro.is_empty():
		var dati_incontro: Dictionary = portatore_incontro.get("incontro_scriptato", {})
		if dati_incontro.get("prima_fuga_fallisce", false) and incontro_tentativi_fuga == 0:
			# il primo tentativo fallisce sempre, ma senza nessun rischio: non e'
			# questo a poterti far morire, solo il suo copione se non scappi in tempo
			incontro_tentativi_fuga += 1
			scrivi("[i]%s[/i]" % String(dati_incontro.get("testo_fuga_fallita", "")))
			return  # il tentativo fallisce: il combattimento continua
	if chi.giocatore and chi.id == GameState.id_protagonista:
		# l'Intelligenza rende la fuga piu' affidabile: sotto una certa soglia
		# puo' non riuscire, e il turno e' perso
		var probabilita := minf(0.5 + GameState.stat_di("intelligenza") * 0.05, 1.0)
		if GameState.rng.randf() >= probabilita:
			scrivi("[i]%s prova a fuggire, ma non trova il varco giusto.[/i]" % chi.nome)
			return
	# nessuna penalita': solo si esce dal combattimento, senza bottino
	scrivi("[i]%s fugge dal combattimento![/i]" % chi.nome)
	if chi.giocatore and chi.id == GameState.id_protagonista:
		GameState.registra_azione("fughe")
	giocatore_e_fuggito = true
	in_corso = false

func bersaglio_giocatore_casuale() -> Dictionary:
	# la provocazione forza i nemici a colpire chi ha provocato, finche' dura
	if not bersaglio_provocazione.is_empty() and turni_provocazione > 0 and bersaglio_provocazione.hp > 0:
		return bersaglio_provocazione
	var possibili := vivi(true)
	return possibili[GameState.rng.randi_range(0, possibili.size() - 1)] if not possibili.is_empty() else {}

func squadra_ha_terrore() -> bool:
	for personaggio in vivi(true):
		if ha_stato_attivo(personaggio, "terrore"):
			return true
	return false

func aggiungi_stress(chi: Dictionary, quantita: int) -> void:
	# la Forza mentale del protagonista attutisce lo stress in arrivo; quello
	# che passa comunque allena la stat per il prossimo livello
	if quantita > 0 and chi.giocatore and chi.id == GameState.id_protagonista:
		var riduzione := mini(GameState.stat_di("forza_mentale"), 90) / 100.0
		quantita = maxi(int(round(quantita * (1.0 - riduzione))), 1)
		GameState.registra_azione("stress_accumulato", quantita)
	chi.stress = clampi(chi.stress + quantita, 0, 100)
	aggiorna_scheda(chi)

func fuga_possibile() -> bool:
	# non si fugge dai boss veri, ne' quando il terrore ha paralizzato qualcuno;
	# un nemico con blocca_fuga_turni lo impedisce solo per i suoi primi turni
	if not fonte.is_empty() or squadra_ha_terrore():
		return false
	if not portatore_fuga_bloccata.is_empty():
		return giro_corrente >= int(portatore_fuga_bloccata.get("blocca_fuga_turni", 999))
	return true

func primo_nemico() -> Dictionary:
	# la fonte ha la precedenza, altrimenti il primo nemico vivo
	for combattente in vivi(false):
		if combattente.id == fonte.get("id", ""):
			return combattente
	var nemici := vivi(false)
	return nemici[0] if not nemici.is_empty() else {}

# --- turno nemico e mosse ---

func turno_nemico(nemico: Dictionary) -> void:
	if not tutorial.is_empty() and not tutorial_finito \
			and GameState.personaggi.get(nemico.id, {}).has("tutorial_combattimento"):
		return  # durante il tutorial le sue reazioni sono scritte nei passi, non tirate a caso

	if not portatore_incontro.is_empty() and nemico.id == portatore_incontro.id:
		if not incontro_apertura_mostrata:
			# il giocatore, piu' veloce, ha gia' agito normalmente questo giro:
			# questa e' la sua unica battuta di apertura, non un secondo turno
			scrivi("[i]%s[/i]" % String(portatore_incontro.get("incontro_scriptato", {}).get("testo_paralisi_nemico", "")))
			incontro_apertura_mostrata = true
			return
		esegui_turno_inerte(nemico, portatore_incontro.get("incontro_scriptato", {}))
		return
	if not portatore_frenesia.is_empty() and nemico.id == portatore_frenesia.id:
		gestisci_turno_frenesia(nemico)
		return
	turno_nemico_normale(nemico)

func esegui_turno_inerte(nemico: Dictionary, dati_incontro: Dictionary) -> void:
	# fuori dalle fasi scriptate lei non attacca mai per danno: ogni turno e'
	# solo la narrazione di un suo gesto, sempre piu' inquietante. Chi non
	# fugge (o vince) in tempo arriva alla scena finale, letale
	var testi: Array = dati_incontro.get("testi_inerti", [])
	if incontro_turni_inerti < testi.size():
		scrivi("[i]%s[/i]" % String(testi[incontro_turni_inerti]))
		incontro_turni_inerti += 1
		return
	esegui_scena_fatale(dati_incontro)

func esegui_scena_fatale(dati_incontro: Dictionary) -> void:
	# "Chiamata di Morfeo": il suo gesto finale, letale, a meno che qualcosa
	# non ti protegga dal sonno che porta con se' (es. la Pietra Quieta)
	incontro_tentativi_morfeo += 1
	scrivi("[i]%s[/i]" % String(dati_incontro.get("testo_fatale_manifestazione", "")))
	var protagonisti_vivi := vivi(true)
	if protagonisti_vivi.is_empty():
		return
	var bersaglio: Dictionary = protagonisti_vivi[0]
	var nome_protagonista: String = String(bersaglio.nome)
	# la scena si vede sempre per intero, fino al bacio: e' solo dopo che il
	# destino si divide, a seconda che qualcosa ti protegga dal sonno o no
	scrivi("%s: \"%s\"" % [nome_protagonista, String(dati_incontro.get("testo_fatale_protagonista", ""))])
	scrivi("[i]%s[/i]" % String(dati_incontro.get("testo_fatale_bacio", "")))
	var scudo_prima := scudo_primo_stato_pronto
	applica_stato(bersaglio, "sonno")
	if ha_stato_attivo(bersaglio, "sonno"):
		# niente ha fermato il sonno: game over
		sconfitta_scriptata()
		return
	# respinto: o lo scudo l'ha appena consumato adesso, o l'immunita' era
	# gia' attiva da un tentativo precedente
	if scudo_prima and not scudo_primo_stato_pronto:
		scrivi("[i]%s[/i]" % String(dati_incontro.get("testo_scudo_rotto", "")))
	if incontro_tentativi_morfeo >= 2:
		esegui_vortice_di_rabbia(dati_incontro)
	else:
		scrivi("[i]%s[/i]" % String(dati_incontro.get("testo_morfeo_fallito", "")))

func esegui_vortice_di_rabbia(dati_incontro: Dictionary) -> void:
	# secondo tentativo respinto: si dissolve in un vortice di rabbia - una
	# vittoria alternativa, mai raggiunta a forza di colpi
	scrivi("[b]%s[/b]" % String(dati_incontro.get("testo_vortice_rabbia", "")))
	var bersaglio := primo_nemico()
	if bersaglio.is_empty():
		return
	bersaglio.xp = int(dati_incontro.get("xp_vittoria_alternativa", bersaglio.xp))
	bersaglio.hp = 0
	aggiorna_scheda(bersaglio)
	var oggetto_premio := String(dati_incontro.get("oggetto_vittoria_alternativa", ""))
	if oggetto_premio != "":
		GameState.aggiungi_oggetto(oggetto_premio)
	_su_ko(bersaglio)

func sconfitta_scriptata() -> void:
	# il party viene azzerato sul colpo: usato dagli epiloghi letali degli
	# incontri scriptati (incubo, scena fatale), sempre instradati come una
	# qualunque sconfitta (se_perdi)
	var vittime := vivi(true)
	for vittima in vittime:
		vittima.hp = 0
		aggiorna_scheda(vittima)
	if not vittime.is_empty():
		_su_ko(vittime[0])

func gestisci_turno_frenesia(nemico: Dictionary) -> void:
	var dati_frenesia: Dictionary = portatore_frenesia.get("frenesia", {})
	if turni_afflitto > 0:
		var linee: Array = dati_frenesia.get("testo_fermata", [])
		var indice: int = linee.size() - turni_afflitto
		if indice >= 0 and indice < linee.size():
			scrivi("%s: \"%s\"" % [nemico.nome, linee[indice]])
		turni_afflitto -= 1
		return
	if not frenesia_attiva:
		turno_nemico_normale(nemico)
		return
	conteggio_frenesia -= 1
	if conteggio_frenesia <= 0:
		scrivi("[b]%s[/b]" % dati_frenesia.get("testo_maleficio", "Il maleficio si abbatte su di voi."))
		for personaggio in vivi(true):
			personaggio.hp = 0
			aggiorna_scheda(personaggio)
		in_corso = false
		return
	scrivi(String(dati_frenesia.get("testo_conteggio", "%d...")) % conteggio_frenesia)

func verifica_mossa_soglia(nemico: Dictionary) -> bool:
	# alcuni boss cambiano marcia a meta' vita: una mossa forzata, una volta sola
	var dati: Dictionary = GameState.personaggi.get(nemico.id, {}).get("mossa_soglia_hp", {})
	if dati.is_empty() or nemico.get("soglia_gia_scattata", false):
		return false
	if float(nemico.hp) / float(nemico.hp_max) > float(dati.get("frazione_hp", 0.5)):
		return false
	nemico.soglia_gia_scattata = true
	esegui_mossa(nemico, dati)
	return true

func verifica_dialogo_soglia(bersaglio: Dictionary) -> void:
	var dati: Dictionary = GameState.personaggi.get(bersaglio.id, {}).get("dialogo_soglia_hp", {})
	if dati.is_empty() or bersaglio.hp <= 0 or soglie_dialogo_mostrate.get(bersaglio.indice, false):
		return
	if bersaglio.hp <= int(dati.get("hp_soglia", 0)):
		soglie_dialogo_mostrate[bersaglio.indice] = true
		scrivi("[b]%s[/b]" % String(dati.get("testo", "")))

func esegui_mossa_disperazione(nemico: Dictionary, dati: Dictionary) -> void:
	# mossa forzata (non pesata) sotto una soglia di hp: danno diverso a
	# seconda che il bersaglio si sia difeso nel turno precedente o no
	scrivi("[i]%s[/i]" % String(dati.get("testo", "")))
	var bersaglio := bersaglio_giocatore_casuale()
	if bersaglio.is_empty():
		return
	var si_difende := false
	for buff in bersaglio.buffs:
		if buff.get("stat", "") == "difesa":
			si_difende = true
			break
	var valore := int(dati.get("valore_normale", 1)) if si_difende else int(dati.get("valore_alto", 1))
	attacca(nemico, bersaglio, valore)

func verifica_innesco_frenesia(bersaglio: Dictionary) -> void:
	if portatore_frenesia.is_empty() or bersaglio.id != portatore_frenesia.id \
			or frenesia_gia_innescata or bersaglio.hp <= 0:
		return
	var dati_frenesia: Dictionary = portatore_frenesia.get("frenesia", {})
	var soglia := float(dati_frenesia.get("soglia_hp", 0.5))
	if float(bersaglio.hp) / float(bersaglio.hp_max) <= soglia:
		frenesia_attiva = true
		frenesia_gia_innescata = true
		conteggio_frenesia = int(dati_frenesia.get("conteggio", 3))
		scrivi("[b]%s[/b]" % dati_frenesia.get("testo_inizio", "Qualcosa cambia."))

func verifica_rabbia_su_morte(caduto: Dictionary) -> void:
	if portatore_rabbia.is_empty():
		return
	var dati_rabbia: Dictionary = portatore_rabbia.get("rabbia_su_morte_alleato", {})
	if caduto.id != String(dati_rabbia.get("id_alleato", "")):
		return
	var capo := vivo_con_id(String(portatore_rabbia.get("id", "")))
	if capo.is_empty():
		return
	capo.attacco += int(dati_rabbia.get("valore_attacco", 1))
	aggiorna_scheda(capo)
	scrivi("[i]%s[/i]" % String(dati_rabbia.get("testo", "La rabbia cresce.")))

func vivo_con_id(id_personaggio: String) -> Dictionary:
	for combattente in vivi(false):
		if combattente.id == id_personaggio:
			return combattente
	return {}

func verifica_crisi_gelosia(nemico: Dictionary) -> bool:
	# nata da invidia e gelosia: piu' il legame del party e' curato, piu' in
	# fretta arriva - un paio di turni destabilizzato (difesa giu', rischio
	# di restare inerte), non un cedimento definitivo come "convinto"
	var dati: Dictionary = GameState.personaggi.get(nemico.id, {}).get("crisi_gelosia", {})
	if dati.is_empty():
		return false
	if int(nemico.get("crisi_turni_rimasti", 0)) <= 0:
		var moltiplicatore := float(dati.get("moltiplicatore_probabilita", 0.005))
		if GameState.rng.randf() >= GameState.legame * moltiplicatore:
			return false
		nemico.crisi_turni_rimasti = int(dati.get("durata_turni", 2))
		scrivi("[b]%s[/b]" % String(dati.get("testo_inizio", "")))
	nemico.crisi_turni_rimasti = int(nemico.crisi_turni_rimasti) - 1
	nemico.buffs.append({
		"stat": "difesa",
		"valore": -int(dati.get("riduzione_difesa", 3)),
		"turni": 1,
	})
	aggiorna_scheda(nemico)
	if GameState.rng.randf() < float(dati.get("probabilita_inerte", 0.4)):
		scrivi("[i]%s[/i]" % String(dati.get("testo_turno_inerte", "")))
		return true
	return false

func risolvi_rigenerazione(nemico: Dictionary) -> bool:
	# "rigenerazione": a ogni turno recupera meta' del danno che ha subito
	# nell'ultimo turno in cui ne ha subito (se in un turno non ne subisce,
	# recupera sempre meta' dell'ultimo valore registrato). Dopo un certo
	# numero di colpi incassati gli cede una gamba: resta fermo a recuperare
	# per qualche turno, senza attaccare. Ritorna true se il turno e' consumato.
	var dati: Dictionary = GameState.personaggi.get(nemico.id, {}).get("rigenerazione", {})
	if dati.is_empty():
		return false
	var cura := int(floor(float(nemico.ultimo_danno_subito) / 2.0))
	if cura > 0 and nemico.hp < nemico.hp_max:
		nemico.hp = mini(nemico.hp + cura, nemico.hp_max)
		aggiorna_scheda(nemico)
		scrivi("[i]%s[/i]" % String(dati.get("testo_rigenera", "La carne si richiude su se stessa.")).replace("%d", str(cura)))
	if int(nemico.gamba_rotta_turni) > 0:
		nemico.gamba_rotta_turni = int(nemico.gamba_rotta_turni) - 1
		scrivi("[i]%s[/i]" % String(dati.get("testo_gamba_rotta_turno", "Resta a terra, e continua a ricucirsi.")))
		return true
	var soglia := int(dati.get("colpi_prima_della_gamba", 6))
	if soglia > 0 and int(nemico.colpi_incassati) >= soglia and not nemico.gamba_gia_rotta:
		nemico.gamba_gia_rotta = true
		nemico.gamba_rotta_turni = int(dati.get("turni_fermo", 2))
		scrivi("[b]%s[/b]" % String(dati.get("testo_gamba_si_rompe", "Una gamba cede sotto il suo stesso peso.")))
		return true
	return false

func turno_nemico_normale(nemico: Dictionary) -> void:
	if risolvi_rigenerazione(nemico):
		return
	if turni_fermo_leva > 0 and nemico.id == fonte.get("id", ""):
		turni_fermo_leva -= 1
		scrivi("[i]%s[/i]" % testo_fermo_leva)
		return
	if convinto and nemico.id == fonte.get("id", "") \
			and GameState.rng.randf() < float(GameState.regole.get("probabilita_cedimento", 0.5)):
		cedimento(nemico)
		return
	if verifica_crisi_gelosia(nemico):
		return
	if verifica_mossa_soglia(nemico):
		return
	if not nemico.mossa_in_carica.is_empty():
		# la mossa annunciata il turno scorso arriva ora, garantita: chi ha
		# avuto l'avviso ha avuto anche il tempo di reagire
		var mossa_pronta: Dictionary = nemico.mossa_in_carica
		nemico.mossa_in_carica = {}
		esegui_mossa(nemico, mossa_pronta)
		return
	var dati_disperazione: Dictionary = GameState.personaggi.get(nemico.id, {}).get("mossa_disperazione", {})
	if not dati_disperazione.is_empty() and nemico.hp <= int(dati_disperazione.get("hp_soglia", 0)):
		esegui_mossa_disperazione(nemico, dati_disperazione)
		return
	var mosse_usate: Array = nemico.mosse_usate
	var mosse: Array = []
	for mossa in nemico.mosse:
		if mossa.get("una_tantum", false) and String(mossa.get("id", "")) in mosse_usate:
			continue
		if String(mossa.get("tipo", "")) == "sacrificio" and vivi_alleati_di(nemico).is_empty():
			continue  # non c'e' nessuno da sacrificare: la mossa non parte proprio
		if mossa.has("richiede_non_flag") and GameState.ha_flag(String(mossa["richiede_non_flag"])):
			continue  # qualcosa, nella storia, gli ha tolto questa possibilita'
		if mossa.has("richiede_flag") and not GameState.ha_flag(String(mossa["richiede_flag"])):
			continue
		mosse.append(mossa)
	if not mosse.is_empty():
		var totale: int = int(nemico.peso_attacco_normale)
		for mossa in mosse:
			totale += int(mossa.get("peso", 1))
		var estratto := GameState.rng.randi_range(1, maxi(totale, 1))
		for mossa in mosse:
			estratto -= int(mossa.get("peso", 1))
			if estratto <= 0:
				if mossa.get("telegrafata", false):
					# si "carica": niente danno questo turno, ma la mossa e'
					# ormai annunciata e arrivera' di sicuro al prossimo
					nemico.mossa_in_carica = mossa
					scrivi("[b]%s[/b]" % String(mossa.get("testo_annuncio", "Qualcosa si sta caricando...")))
				else:
					esegui_mossa(nemico, mossa)
				return
	nemico.difesa_accumulo = 0.0  # attacco normale: la guardia accumulata si perde
	attacca(nemico, bersaglio_giocatore_casuale())

func esegui_mossa(nemico: Dictionary, mossa: Dictionary) -> void:
	scrivi("[i]%s[/i]" % mossa.get("testo", ""))
	if mossa.get("una_tantum", false):
		nemico.mosse_usate.append(String(mossa.get("id", "")))
	if String(mossa.get("tipo", "")) != "difendi":
		# stessa regola del giocatore: la guardia accumulata si perde appena
		# si fa altro (vedi difendi()/esegui_turno)
		nemico.difesa_accumulo = 0.0
	match mossa.get("tipo", ""):
		"difendi":
			difendi(nemico)
		"attacco_forte":
			var vittima_forte := bersaglio_giocatore_casuale()
			attacca(nemico, vittima_forte, int(mossa.get("valore", nemico.attacco)))
			if mossa.has("stato") and not vittima_forte.is_empty() and vittima_forte.hp > 0:
				applica_stato(vittima_forte, String(mossa["stato"]))
		"meta_vita":
			# toglie sempre meta' dei punti vita attuali del bersaglio, ignorando
			# difese e livello; sotto una soglia minima e' invece un KO secco
			var vittima := bersaglio_giocatore_casuale()
			if not vittima.is_empty():
				var soglia_ko := int(mossa.get("hp_soglia_ko", 5))
				if vittima.hp < soglia_ko:
					scrivi("[b]%s non regge il colpo.[/b]" % vittima.nome)
					vittima.hp = 0
				else:
					vittima.hp = maxi(vittima.hp - int(floor(float(vittima.hp) / 2.0)), 1)
				aggiorna_scheda(vittima)
				if vittima.hp <= 0:
					_su_ko(vittima)
		"attacco_multiplo":
			for volta in range(int(mossa.get("colpi", 2))):
				if vivi(true).is_empty():
					break
				attacca(nemico, bersaglio_giocatore_casuale(), int(mossa.get("valore", nemico.attacco)))
		"buff_attacco":
			nemico.buffs.append({
				"stat": "attacco",
				"valore": int(mossa.get("valore", 1)),
				"turni": int(mossa.get("turni", 2)),
			})
			aggiorna_scheda(nemico)
		"incendia":
			# appicca il fuoco a un membro del party a caso: da qui in poi
			# brucia a ogni suo turno, come la combustione dei nemici
			var possibili_bersagli := vivi(true)
			if not possibili_bersagli.is_empty():
				var bersaglio: Dictionary = possibili_bersagli[GameState.rng.randi_range(0, possibili_bersagli.size() - 1)]
				bersaglio.combustione = {
					"danno_per_turno": int(mossa.get("valore", 1)),
					"testo_turno": String(mossa.get("testo_combustione", "Le fiamme ti divorano un altro po'.")),
				}
				bersaglio.in_fiamme = true
				aggiorna_scheda(bersaglio)
		"attacco_tutti":
			for bersaglio in vivi(true):
				attacca(nemico, bersaglio, int(mossa.get("valore", 1)))
			if mossa.has("stress"):
				for bersaglio in vivi(true):
					aggiungi_stress(bersaglio, int(mossa.stress))
			if mossa.has("legame"):
				GameState.modifica_legame(int(mossa.legame))
			if mossa.has("maledizione"):
				for bersaglio in vivi(true):
					applica_stato(bersaglio, "maledizione", int(mossa.maledizione))
			if mossa.get("terrore", false):
				for bersaglio in vivi(true):
					applica_stato(bersaglio, "terrore")
		"autolesione":
			# si ferisce da sola: il dolore riverbera sullo stress della squadra
			nemico.hp = maxi(nemico.hp - int(mossa.get("valore", 1)), 0)
			aggiorna_scheda(nemico)
			for bersaglio in vivi(true):
				aggiungi_stress(bersaglio, int(mossa.get("stress", 10)))
			if mossa.has("legame"):
				GameState.modifica_legame(int(mossa.legame))
			if mossa.has("maledizione"):
				for bersaglio in vivi(true):
					applica_stato(bersaglio, "maledizione", int(mossa.maledizione))
			if nemico.hp <= 0:
				_su_ko(nemico)
		"buff_difesa":
			nemico.buffs.append({
				"stat": "difesa",
				"valore": int(mossa.get("valore", 1)),
				"turni": int(mossa.get("turni", 2)),
			})
			aggiorna_scheda(nemico)
		"buff_fattore":
			nemico.fattore = clampi(nemico.fattore + int(mossa.get("valore", 10)), 0, 100)
			aggiorna_scheda(nemico)
		"evoca":
			var evocati := 0
			for volta in range(int(mossa.get("quantita", 1))):
				if vivi(false).size() >= 3:
					break
				aggiungi_combattente(String(mossa.get("valore", "")), false)
				evocati += 1
			if evocati == 0:
				scrivi("[i]...ma nessuno risponde al richiamo.[/i]")
		"sacrificio":
			# "un piccolo sacrificio per un grande risultato": si potenzia
			# uccidendo un suo stesso alleato evocato, se ce n'è uno vivo
			var alleati := vivi_alleati_di(nemico)
			if alleati.is_empty():
				scrivi("[i]Non ha nessuno da sacrificare, per ora. Colpisce lui stesso.[/i]")
				attacca(nemico, bersaglio_giocatore_casuale())
			else:
				var vittima: Dictionary = alleati[GameState.rng.randi_range(0, alleati.size() - 1)]
				scrivi("[i]%s lo colpisce lui stesso, senza esitare.[/i]" % nemico.nome)
				vittima.hp = 0
				aggiorna_scheda(vittima)
				nemico.fattore = clampi(nemico.fattore + int(mossa.get("valore", 15)), 0, 100)
				aggiorna_scheda(nemico)
				_su_ko(vittima)

func cedimento(combattente: Dictionary) -> void:
	# la fonte convinta perde pezzi di spettacolo: statistiche giu', fino alla fine
	combattente.fattore = maxi(combattente.fattore - int(GameState.regole.get("cedimento_fattore", 10)), 0)
	combattente.velocita = maxi(combattente.velocita - int(GameState.regole.get("cedimento_velocita", 1)), 1)
	combattente.attacco = maxi(combattente.attacco - int(GameState.regole.get("cedimento_attacco", 1)), 0)
	combattente.hp = maxi(combattente.hp - int(GameState.regole.get("cedimento_hp", 1)), 0)
	scrivi("[i]Lo spettacolo di %s si spegne un po' di più.[/i]" % combattente.nome)
	aggiorna_scheda(combattente)
	if combattente.hp <= 0:
		_su_ko(combattente)

# --- combustione: alcuni nemici bruciano a ogni loro turno (danno, a volte
# anche un bonus attacco che cresce turno dopo turno). Puo' essere attiva
# fin dall'inizio (nessun "attiva_da_studio" nei dati) o innescarsi dopo
# essere stato studiato un certo numero di volte.

func verifica_innesco_combustione(bersaglio: Dictionary) -> void:
	var comb: Dictionary = bersaglio.combustione
	if comb.is_empty() or bersaglio.in_fiamme or not comb.has("attiva_da_studio"):
		return
	if bersaglio.volte_studiato >= int(comb["attiva_da_studio"]):
		bersaglio.in_fiamme = true
		scrivi("[b]%s[/b]" % comb.get("testo_innesco", "Qualcosa in lui prende fuoco."))

func applica_combustione(combattente: Dictionary) -> void:
	var comb: Dictionary = combattente.combustione
	var danno := int(comb.get("danno_per_turno", 1))
	combattente.hp = maxi(combattente.hp - danno, 0)
	scrivi("[i]%s[/i]" % String(comb.get("testo_turno", "Brucia ancora un po'.")))
	if comb.has("bonus_attacco"):
		combattente.attacco += int(comb["bonus_attacco"])
	aggiorna_scheda(combattente)
	if combattente.hp <= 0:
		_su_ko(combattente)

# --- stati generici (data/stati.json): veleno, congelamento, sonno,
# egocentrismo, demotivazione (contagiosa), berserk, confusione, rapidita'/
# lentezza, maledizione. Ogni personaggio puo' dichiarare nei dati una chiave
# "resistenze" (es. {"stress": "invertito", "oscuro": "ipersensibile"}):
# "immune" annulla lo stato, "ipersensibile" lo amplifica, "invertito" (solo
# per stress) ne capovolge l'effetto. Assente = "normale".

func resistenza_di(combattente: Dictionary, chiave: String) -> String:
	if chiave in combattente.get("immunita_temporanea", []):
		return "immune"  # respinto in questo stesso combattimento (es. scudo_primo_stato)
	if combattente.giocatore and combattente.id == GameState.id_protagonista \
			and GameState.resistenza_stato_di(chiave) >= int(GameState.crescita.get("resistenze", {}).get("massimo", 100)):
		return "immune"  # allenato fino in fondo: quello stato non ti tocca piu'
	var dati: Dictionary = GameState.personaggi.get(combattente.id, {})
	return String(dati.get("resistenze", {}).get(chiave, "normale"))

func ha_stato_attivo(combattente: Dictionary, id_stato: String) -> bool:
	return combattente.stati_attivi.has(id_stato)

func applica_stato(bersaglio: Dictionary, id_stato: String, valore := 1) -> void:
	var resistenza := resistenza_di(bersaglio, id_stato)
	if resistenza == "immune":
		return
	if bersaglio.giocatore and scudo_primo_stato_pronto:
		# l'accessorio equipaggiato respinge il primo stato subito in questo
		# combattimento, e immunizza da quello stesso stato per il resto dello
		# scontro; si consuma qui, una volta sola
		scudo_primo_stato_pronto = false
		bersaglio.immunita_temporanea.append(id_stato)
		var nome_accessorio := String(GameState.dati_oggetto(GameState.accessorio_equipaggiato).get("nome", "Il tuo accessorio"))
		var nome_stato := String(GameState.stati.get(id_stato, {}).get("nome", id_stato))
		scrivi("[b]%s si spezza, respingendo %s: sarai immune per il resto dello scontro.[/b]" % [nome_accessorio, nome_stato])
		GameState.consuma_accessorio_equipaggiato()
		return
	if bersaglio.giocatore and bersaglio.id == GameState.id_protagonista:
		GameState.registra_stato_subito(id_stato)
	var amplificato := resistenza == "ipersensibile"
	var info_stato: Dictionary = GameState.stati.get(id_stato, {})
	var tipo := String(info_stato.get("tipo", ""))
	match tipo:
		"countdown":
			var attivo: Dictionary = bersaglio.stati_attivi.get(id_stato, {})
			if attivo.is_empty():
				var iniziale := int(GameState.regole.get("maledizione_countdown_iniziale", 9))
				bersaglio.stati_attivi[id_stato] = {"turni_rimasti": iniziale}
				scrivi("[b]%s %s[/b]" % [bersaglio.nome, info_stato.get("testo_applicazione", "viene colpito da una forza oscura.")])
			else:
				var accelerazione := int(GameState.regole.get("maledizione_accelerazione_per_stack", 1))
				if amplificato:
					accelerazione *= 2
				attivo.turni_rimasti = maxi(int(attivo.turni_rimasti) - accelerazione, 1)
		"salta_turno", "forza_attacco", "colpisci_a_caso":
			var durata: int
			if tipo == "salta_turno":
				durata = GameState.rng.randi_range(1, int(GameState.regole.get("salta_turno_durata_massima", 3)))
			else:
				durata = int(GameState.regole.get("forza_azione_durata", 2))
			if amplificato:
				durata += 1
			bersaglio.stati_attivi[id_stato] = {"turni_rimasti": durata}
			scrivi("[i]%s %s[/i]" % [bersaglio.nome, info_stato.get("testo_applicazione", "subisce uno stato.")])
			if info_stato.get("contagiosa", false):
				for altro in vivi(bersaglio.giocatore):
					if altro.indice != bersaglio.indice and resistenza_di(altro, id_stato) != "immune":
						altro.stati_attivi[id_stato] = {"turni_rimasti": durata}
						scrivi("[i]%s ne è contagiato.[/i]" % altro.nome)
		"dot_crescente":
			var attivo2: Dictionary = bersaglio.stati_attivi.get(id_stato, {})
			var base := int(valore) * (2 if amplificato else 1)
			bersaglio.stati_attivi[id_stato] = {"danno": int(attivo2.get("danno", 0)) + base}
		"dot", "dot_condizionale":
			bersaglio.stati_attivi[id_stato] = {"danno": int(valore) * (2 if amplificato else 1)}
		"velocita":
			bersaglio.stati_attivi[id_stato] = {"valore": int(info_stato.get("valore", 0))}
		"terrore":
			bersaglio.stati_attivi[id_stato] = {}
			var incremento_stress := int(GameState.regole.get("terrore_stress_incremento", 40))
			var decremento_legame := int(GameState.regole.get("terrore_legame_decremento", -15))
			if amplificato:
				incremento_stress *= 2
				decremento_legame *= 2
			aggiungi_stress(bersaglio, incremento_stress)
			GameState.modifica_legame(decremento_legame)
			scrivi("[b]%s %s[/b]" % [bersaglio.nome, info_stato.get("testo_applicazione", "è paralizzato dal terrore.")])
	aggiorna_scheda(bersaglio)

func velocita_effettiva(combattente: Dictionary) -> int:
	var totale: int = int(combattente.velocita)
	for id_stato in ["rapidita", "lentezza"]:
		if combattente.stati_attivi.has(id_stato):
			totale += int(GameState.stati.get(id_stato, {}).get("valore", 0))
	return maxi(totale, 0)

func risolvi_stati_a_inizio_turno(combattente: Dictionary) -> bool:
	# esegue countdown/salta-turno/dot a inizio turno; ritorna true se il
	# turno va saltato (congelamento, sonno, egocentrismo, demotivazione) o
	# se il personaggio muore prima di poter agire (maledizione, veleno)
	var salta := false
	for id_stato in combattente.stati_attivi.keys().duplicate():
		var attivo: Dictionary = combattente.stati_attivi[id_stato]
		var info_stato: Dictionary = GameState.stati.get(id_stato, {})
		match String(info_stato.get("tipo", "")):
			"countdown":
				attivo.turni_rimasti = int(attivo.turni_rimasti) - 1
				if int(attivo.turni_rimasti) <= 0:
					scrivi("[b]La maledizione si compie: %s non resiste oltre.[/b]" % combattente.nome)
					combattente.hp = 0
					aggiorna_scheda(combattente)
					_su_ko(combattente)
					return true
			"salta_turno":
				scrivi("[i]%s non riesce ad agire: %s.[/i]" % [combattente.nome, String(info_stato.get("nome", id_stato))])
				salta = true
				attivo.turni_rimasti = int(attivo.turni_rimasti) - 1
				if int(attivo.turni_rimasti) <= 0:
					combattente.stati_attivi.erase(id_stato)
			"forza_attacco", "colpisci_a_caso":
				attivo.turni_rimasti = int(attivo.turni_rimasti) - 1
				if int(attivo.turni_rimasti) <= 0:
					combattente.stati_attivi.erase(id_stato)
			"dot", "dot_crescente":
				var danno := int(attivo.get("danno", 1))
				combattente.hp = maxi(combattente.hp - danno, 0)
				scrivi("[i]%s: %s[/i]" % [combattente.nome, String(info_stato.get("testo_turno", "Il male si fa sentire ancora."))])
				if String(info_stato.get("tipo", "")) == "dot_crescente":
					attivo.danno = danno + 1
				aggiorna_scheda(combattente)
				if combattente.hp <= 0:
					_su_ko(combattente)
					return true
	return salta

func risolvi_dot_condizionale(combattente: Dictionary, azione_offensiva: bool) -> void:
	# la decomposizione fa danno solo se il personaggio ha scelto un'azione
	# offensiva quel turno; difendersi o studiare la evita
	if combattente.hp <= 0 or not azione_offensiva:
		return
	for id_stato in combattente.stati_attivi.keys().duplicate():
		var info_stato: Dictionary = GameState.stati.get(id_stato, {})
		if String(info_stato.get("tipo", "")) != "dot_condizionale":
			continue
		var attivo: Dictionary = combattente.stati_attivi[id_stato]
		var danno := int(attivo.get("danno", 1))
		combattente.hp = maxi(combattente.hp - danno, 0)
		scrivi("[i]%s: %s[/i]" % [combattente.nome, String(info_stato.get("testo_turno", "Il male si fa sentire ancora."))])
		aggiorna_scheda(combattente)
		if combattente.hp <= 0:
			_su_ko(combattente)
			return

# --- risoluzione dei colpi ---

func difesa_di(combattente: Dictionary) -> int:
	var totale: int = combattente.difesa
	for buff in combattente.buffs:
		if buff.get("stat", "") == "difesa":
			totale += int(buff.get("valore", 0))
	return totale

func attacco_di(combattente: Dictionary) -> int:
	var totale: int = combattente.attacco
	for buff in combattente.buffs:
		if buff.get("stat", "") == "attacco":
			totale += int(buff.get("valore", 0))
	return totale

func scadenza_buff(combattente: Dictionary) -> void:
	var rimasti: Array = []
	for buff in combattente.buffs:
		buff.turni = int(buff.turni) - 1
		if int(buff.turni) > 0:
			rimasti.append(buff)
	combattente.buffs = rimasti
	aggiorna_scheda(combattente)

func attacca(attaccante: Dictionary, bersaglio: Dictionary, valore_attacco := -1) -> void:
	ultima_azione_offensiva = true
	if attaccante.giocatore and attaccante.id == GameState.id_protagonista:
		GameState.registra_azione("attacchi_sferrati")
	if tenta_slaughter(attaccante, bersaglio):
		return
	var dati_bersaglio: Dictionary = GameState.personaggi.get(bersaglio.id, {})
	if valore_attacco < 0 and dati_bersaglio.has("danno_fisso_su_attacco"):
		# alcuni nemici scriptati ignorano interamente difesa/critico/fattore:
		# ogni attacco vale sempre lo stesso, fisso, danno
		var danno_forzato := int(dati_bersaglio["danno_fisso_su_attacco"])
		bersaglio.hp = maxi(bersaglio.hp - danno_forzato, 0)
		scrivi("%s attacca %s: %d danno." % [attaccante.nome, bersaglio.nome, danno_forzato])
		aggiorna_scheda(bersaglio)
		if not bersaglio.giocatore:
			verifica_innesco_frenesia(bersaglio)
			verifica_dialogo_soglia(bersaglio)
		if bersaglio.hp <= 0:
			_su_ko(bersaglio)
		elif bersaglio.giocatore:
			aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))
		return
	var danno: int
	if valore_attacco >= 0:
		danno = valore_attacco  # mossa a valore fisso (es. faena, gran finale)
	else:
		danno = attacco_di(attaccante)
		if attaccante.giocatore:
			# il danno del party scala col livello: farmare ed equipaggiarsi conta
			danno += floori((GameState.livello_di(attaccante.id) - 1)
					* float(GameState.regole.get("bonus_attacco_per_livello", 0.5)))
	if fattore_attivo(attaccante) and GameState.rng.randf() < attaccante.fattore / 100.0:
		danno += 1
		scrivi("Il fattore di disallineamento arde in %s!" % attaccante.nome)
	var difesa_bersaglio: float = float(difesa_di(bersaglio))
	var critico := tenta_critico(bersaglio)
	if critico:
		danno = int(round(danno * float(GameState.regole.get("critico_moltiplicatore", 1.5))))
		difesa_bersaglio *= 1.0 - float(GameState.regole.get("critico_riduzione_difesa", 0.5))
	danno -= int(difesa_bersaglio)
	if ha_stato_con_effetto(bersaglio, "difesa_giu"):
		danno += int(GameState.regole.get("malus_danno_depressione", 1))
	danno = maxi(danno, 0)
	if danno > 0 and bersaglio.giocatore:
		# il danno subìto cala in proporzione al livello (e col fattore acceso)
		var riduzione := minf(
			(GameState.livello_di(bersaglio.id) - 1)
				* float(GameState.regole.get("riduzione_danno_per_livello", 0.1)),
			float(GameState.regole.get("riduzione_danno_massima", 0.5)))
		if fattore_attivo(bersaglio):
			riduzione += bersaglio.fattore / 200.0
		if GameState.rng.randf() < riduzione:
			danno = 0
	if danno <= 0:
		scrivi("%s attacca %s, ma il colpo non passa." % [attaccante.nome, bersaglio.nome])
		if bersaglio.giocatore:
			aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))
		return
	bersaglio.hp = maxi(bersaglio.hp - danno, 0)
	registra_danno_subito(bersaglio, danno)
	if critico:
		if attaccante.giocatore and attaccante.id == GameState.id_protagonista:
			GameState.registra_azione("critici_inflitti")
		scrivi("[b]Colpo critico![/b] %s attacca %s: %d danno." % [attaccante.nome, bersaglio.nome, danno])
	else:
		scrivi("%s attacca %s: %d danno." % [attaccante.nome, bersaglio.nome, danno])
	aggiorna_scheda(bersaglio)
	if not bersaglio.giocatore:
		verifica_innesco_frenesia(bersaglio)
		verifica_dialogo_soglia(bersaglio)
	if bersaglio.hp <= 0:
		_su_ko(bersaglio)
	elif bersaglio.giocatore:
		aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))

func tenta_critico(bersaglio: Dictionary) -> bool:
	# lo stress alza la probabilita' di subire un critico; per chi ha una
	# resistenza "invertita" (es. Sally) vale il contrario, per chi e' immune
	# allo stress non conta nulla
	var resistenza := resistenza_di(bersaglio, "stress")
	var bonus_stress := float(bersaglio.stress) / 100.0 * float(GameState.regole.get("critico_bonus_per_stress", 0.15))
	if resistenza == "invertito":
		bonus_stress = -bonus_stress
	elif resistenza == "immune":
		bonus_stress = 0.0
	var chance := clampf(float(GameState.regole.get("critico_chance_base", 0.05)) + bonus_stress, 0.0, 1.0)
	return GameState.rng.randf() < chance

func tenta_slaughter(attaccante: Dictionary, bersaglio: Dictionary) -> bool:
	# probabilita' bassissima di KO istantaneo, anche su un attacco normale;
	# chi trae forza dallo stress (resistenza "invertita") o ne e' immune non puo' essere finito cosi'
	if bersaglio.hp <= 0:
		return false
	if bersaglio.giocatore:
		return false  # il colpo di fortuna non uccide mai il party: solo i nemici comuni
	if not bersaglio.giocatore:
		# solo i nemici comuni: boss, miniboss, creature particolari e incontri
		# scriptati (la manifestazione) non si liquidano mai con un colpo di
		# fortuna - le loro scene devono poter arrivare fino in fondo
		var dati_bersaglio: Dictionary = GameState.personaggi.get(bersaglio.id, {})
		if categoria_di(dati_bersaglio) != "comune" or dati_bersaglio.has("incontro_scriptato") \
				or dati_bersaglio.get("invincibile", false):
			return false
	var resistenza := resistenza_di(bersaglio, "stress")
	if resistenza == "immune" or resistenza == "invertito":
		return false
	var probabilita := float(GameState.regole.get("slaughter_probabilita_base", 0.01))
	if attaccante.giocatore and not bersaglio.giocatore:
		var scarto: int = GameState.livello_di(attaccante.id) - int(GameState.personaggi.get(bersaglio.id, {}).get("livello", 1))
		for voce in GameState.crescita.get("passive_livello", []):
			if voce.has("slaughter_bonus") and GameState.ha_passiva(String(voce.get("id", ""))) \
					and scarto >= int(voce.get("slaughter_scarto_livelli", 0)):
				probabilita *= 1.0 + float(voce["slaughter_bonus"])
	if GameState.rng.randf() >= probabilita:
		return false
	scrivi("[b]SLAUGHTER![/b] %s attacca %s, e non si rialzerà." % [attaccante.nome, bersaglio.nome])
	bersaglio.hp = 0
	aggiorna_scheda(bersaglio)
	mostra_slaughter(bersaglio)  # animazione a parte: non blocca la risoluzione del colpo
	if not bersaglio.giocatore:
		verifica_innesco_frenesia(bersaglio)
	_su_ko(bersaglio)
	return true

func mostra_slaughter(bersaglio: Dictionary) -> void:
	# overlay a schermo intero con l'illustrazione e la scritta "SLAUGHTER"
	# (art/fx/slaughter.png, ancora da disegnare): appare e sparisce in fade,
	# senza mettere in pausa il combattimento
	var overlay := TextureRect.new()
	if ResourceLoader.exists("res://art/fx/slaughter.png"):
		overlay.texture = load("res://art/fx/slaughter.png")
	overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.modulate = Color(1, 1, 1, 0)
	add_child(overlay)
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.2)
	tween.tween_interval(0.6)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.4)
	tween.tween_callback(overlay.queue_free)

func registra_danno_subito(bersaglio: Dictionary, danno: int) -> void:
	# serve a chi si rigenera in proporzione ai colpi presi (vedi risolvi_rigenerazione)
	if danno > 0:
		bersaglio.ultimo_danno_subito = danno
		bersaglio.colpi_incassati = int(bersaglio.colpi_incassati) + 1
		if bersaglio.giocatore and bersaglio.id == GameState.id_protagonista:
			GameState.registra_azione("danni_subiti", danno)

func colpisci_diretto(bersaglio: Dictionary, danno: int) -> void:
	# oggetti e assist ignorano le difese
	bersaglio.hp = maxi(bersaglio.hp - danno, 0)
	registra_danno_subito(bersaglio, danno)
	scrivi("%s subisce %d danno." % [bersaglio.nome, danno])
	aggiorna_scheda(bersaglio)
	if bersaglio.hp <= 0:
		_su_ko(bersaglio)

func _su_ko(caduto: Dictionary) -> void:
	if not caduto.giocatore and GameState.personaggi.get(caduto.id, {}).get("invincibile", false):
		# non muore mai davvero: "sconfiggerlo" non basta, si rialza sempre
		caduto.hp = caduto.hp_max
		aggiorna_scheda(caduto)
		scrivi("[i]%s si rialza, come se nulla fosse.[/i]" % caduto.nome)
		return
	if caduto.giocatore and resurrezione_pronta and caduto.hp <= 0:
		# l'accessorio equipaggiato si spezza al posto tuo: si torna in vita
		# a meta' hp, una volta sola per combattimento, invece del KO
		resurrezione_pronta = false
		caduto.hp = maxi(int(ceil(float(caduto.hp_max) / 2.0)), 1)
		aggiorna_scheda(caduto)
		var nome_accessorio := String(GameState.dati_oggetto(GameState.accessorio_equipaggiato).get("nome", "Il tuo accessorio"))
		scrivi("[b]%s si spezza: %s torna in piedi con metà dei suoi punti vita.[/b]" % [nome_accessorio, caduto.nome])
		GameState.consuma_accessorio_equipaggiato()
		return
	if caduto.get("oggetto_scena", false):
		scrivi("[i]%s vengono distrutte.[/i]" % caduto.nome)
		if not portatore_frenesia.is_empty() \
				and caduto.id == portatore_frenesia.get("frenesia", {}).get("bersaglio_extra", ""):
			frenesia_attiva = false
			turni_afflitto = portatore_frenesia.get("frenesia", {}).get("testo_fermata", []).size()
	elif caduto.get("risparmiato", false):
		scrivi("[i]%s si allontana, risparmiato.[/i]" % caduto.nome)
	else:
		scrivi("[i]%s è a terra![/i]" % caduto.nome)
		if not caduto.giocatore:
			# la fonte ha una voce di sconfitta; gli altri il verso di morte
			if caduto.id == fonte.get("id", ""):
				AudioManager.voce_boss(caduto.id, fonte, "sconfitta")
			else:
				AudioManager.verso(caduto.id, GameState.personaggi.get(caduto.id, {}), "morte")
			verifica_rabbia_su_morte(caduto)
	for alleato in vivi(caduto.giocatore):
		reagisci(alleato)
	if vivi(false).is_empty():
		giocatore_ha_vinto = true
		in_corso = false
		for combattente in combattenti:
			if not combattente.giocatore and not combattente.get("oggetto_scena", false) \
					and not combattente.get("risparmiato", false):
				xp_bottino += xp_effettiva(combattente)
				tazo_bottino += combattente.tazo
		scrivi("[b]Vittoria![/b] Bottino: %d esperienza, %d Tazo." % [xp_bottino, tazo_bottino])
		risolvi_drop()
	elif vivi(true).is_empty():
		in_corso = false
		scrivi("[b]Il party è a terra. Il disallineamento ha vinto.[/b]")

func xp_effettiva(nemico: Dictionary) -> int:
	# rendimento decrescente sul farming: piu' il party supera il livello
	# consigliato del nemico, meno esperienza rende - senza mai azzerarsi,
	# cosi' una farm zone resta utile a lungo ma smette di essere la scorciatoia
	# migliore. Il livello del nemico sta nei dati ("livello", 1 di default).
	var xp_base := int(nemico.xp)
	var livello_nemico := int(GameState.personaggi.get(nemico.id, {}).get("livello", 1))
	var livello_party := 1
	for id_classe in GameState.party:
		livello_party = maxi(livello_party, GameState.livello_di(id_classe))
	var scarto := livello_party - livello_nemico
	if scarto <= 0:
		return xp_base
	var penalita := float(GameState.regole.get("xp_penalita_per_livello_extra", 0.15))
	var minimo := float(GameState.regole.get("xp_minimo_percentuale", 0.1))
	var fattore := maxf(1.0 - scarto * penalita, minimo)
	return maxi(int(round(xp_base * fattore)), 1)

func risolvi_drop() -> void:
	# drop dei nemici sconfitti: carta (rara, garantita solo per unici/boss),
	# bottino comune (consumabili/materiali) e drop_raro (grosso Tazo o un
	# oggetto speciale, a scelta pesata). "Il mondo è il mio Tesoro" raddoppia
	# tutte le chance rare. Tutto dall'RNG seedato.
	var moltiplicatore := 2.0 if GameState.possiede_oggetto("il_mondo_e_il_mio_tesoro") else 1.0
	moltiplicatore += GameState.bonus_passiva("bonus_drop")   # "La tua immondizia e' il mio tesoro", "Tryharder"
	var molt_carta := moltiplicatore + GameState.bonus_passiva("bonus_carta")  # "Illuminazione" 1 e 2
	var righe: Array[String] = []
	for c in combattenti:
		if c.giocatore or c.get("oggetto_scena", false) or c.get("risparmiato", false):
			continue
		var carta: Dictionary = c.carta
		if not carta.is_empty():
			var chance_carta := minf(float(carta.get("chance", 1.0)) * molt_carta, 1.0)
			if GameState.rng.randf() < chance_carta and GameState.ottieni_carta(String(carta.get("id", ""))):
				righe.append("carta \"%s\" [%s]" % [carta.get("nome", ""), carta.get("rarita", "")])
		for voce in c.bottino_comune:
			if GameState.rng.randf() < float(voce.get("chance", 0.0)):
				var id_oggetto := String(voce.get("oggetto", ""))
				if GameState.aggiungi_oggetto(id_oggetto):
					righe.append(String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)))
		var raro: Dictionary = c.drop_raro
		if not raro.is_empty():
			var chance_rara := minf(float(raro.get("chance", 0.0)) * moltiplicatore, 1.0)
			if GameState.rng.randf() < chance_rara:
				var peso_tazo := int(raro.get("peso_tazo", 1))
				var peso_oggetto := int(raro.get("peso_oggetto", 1))
				if GameState.rng.randi_range(1, maxi(peso_tazo + peso_oggetto, 1)) <= peso_tazo:
					var bonus := int(raro.get("tazo", 0))
					tazo_bottino += bonus
					righe.append("%d Tazo extra" % bonus)
				else:
					var id_oggetto := String(raro.get("oggetto", ""))
					if GameState.aggiungi_oggetto(id_oggetto):
						righe.append(String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)))
	# alcuni alleati temporanei danno un piccolo bottino garantito solo per
	# essere stati presenti nello scontro (es. il Vecchio Proprietario del
	# teatro e la sua bottiglia di liquore), vivi o caduti che siano
	for c in combattenti:
		if not c.giocatore:
			continue
		var presenza: Dictionary = GameState.personaggi.get(c.id, {}).get("bottino_presenza", {})
		if not presenza.is_empty() and GameState.rng.randf() < float(presenza.get("chance", 1.0)):
			var id_oggetto_presenza := String(presenza.get("oggetto", ""))
			if GameState.aggiungi_oggetto(id_oggetto_presenza):
				righe.append(String(GameState.dati_oggetto(id_oggetto_presenza).get("nome", id_oggetto_presenza)))
	if not righe.is_empty():
		scrivi("[b]Ottieni:[/b] %s." % ", ".join(righe))

func reagisci(alleato: Dictionary) -> void:
	# ognuno accusa il colpo secondo la propria psiche
	var effetto: String = GameState.psichi.get(alleato.psiche, {}).get("effetto", "")
	if effetto == "" or alleato.psiche in alleato.stati:
		return
	alleato.stati.append(alleato.psiche)
	match effetto:
		"attacco_extra":
			scrivi("%s ribolle di rabbia!" % alleato.nome)
		"difesa_giu":
			scrivi("%s si chiude in sé: la sua difesa cala." % alleato.nome)
		"fattore_su":
			var bonus := int(GameState.regole.get("fattore_bonus_concentrazione", 25))
			alleato.fattore = clampi(alleato.fattore + bonus, 0, 100)
			scrivi("%s si concentra: il fattore di disallineamento sale." % alleato.nome)
	aggiorna_scheda(alleato)

func ha_stato_con_effetto(combattente: Dictionary, effetto: String) -> bool:
	if combattente.psiche not in combattente.stati:
		return false
	return GameState.psichi.get(combattente.psiche, {}).get("effetto", "") == effetto

func fattore_attivo(combattente: Dictionary) -> bool:
	var soglia := int(GameState.regole.get("soglia_stress_sopraffatto", 80))
	return combattente.fattore > 0 and combattente.stress < soglia

func vivi(giocatore: bool) -> Array[Dictionary]:
	var risultato: Array[Dictionary] = []
	for combattente in combattenti:
		if combattente.giocatore == giocatore and combattente.hp > 0:
			risultato.append(combattente)
	return risultato

func vivi_alleati_di(nemico: Dictionary) -> Array[Dictionary]:
	# altri nemici vivi (es. evocazioni), escluso il nemico stesso
	var risultato: Array[Dictionary] = []
	for combattente in vivi(false):
		if combattente.indice != nemico.indice:
			risultato.append(combattente)
	return risultato

func evidenzia(attivo: Dictionary) -> void:
	for combattente in combattenti:
		if combattente.hp <= 0:
			continue
		var suo_turno: bool = combattente.indice == attivo.indice
		combattente.scheda.modulate = Color.WHITE if suo_turno else Color(1, 1, 1, 0.65)

func aggiorna_scheda(combattente: Dictionary) -> void:
	if combattente.hp <= 0:
		combattente.etichetta_vita.text = "KO"
		combattente.scheda.modulate = Color(0.5, 0.4, 0.4, 0.5)
	elif combattente.get("hp_nascosti", false):
		# i boss (e i nemici scriptati come la manifestazione) non mostrano
		# il conteggio esatto degli hp: mantiene l'incertezza sullo scontro
		combattente.etichetta_vita.text = "♥ ???"
	else:
		combattente.etichetta_vita.text = "♥ %d/%d" % [combattente.hp, combattente.hp_max]
	var dettagli := "Stress %d · Fattore %d" % [combattente.stress, combattente.fattore]
	var scudo := difesa_di(combattente)
	if scudo > 0:
		dettagli += " · Dif %d" % scudo
	if combattente.stress >= int(GameState.regole.get("soglia_stress_sopraffatto", 80)):
		dettagli += " · sopraffatto"
	if combattente.get("in_fiamme", false):
		dettagli += " · in fiamme"
	for id_stato in combattente.stati_attivi:
		var info_stato: Dictionary = GameState.stati.get(id_stato, {})
		var nome_stato: String = String(info_stato.get("nome", id_stato))
		var attivo: Dictionary = combattente.stati_attivi[id_stato]
		if attivo.has("turni_rimasti"):
			dettagli += " · %s (%d)" % [nome_stato, int(attivo.turni_rimasti)]
		else:
			dettagli += " · %s" % nome_stato
	if combattente.psiche in combattente.stati:
		dettagli += " · " + String(GameState.psichi.get(combattente.psiche, {}).get("nome", combattente.psiche))
	combattente.etichetta_extra.text = dettagli

func scrivi(riga: String) -> void:
	diario.append_text(riga + "\n")

func _esci() -> void:
	# lo stress accumulato resta addosso ai personaggi
	for combattente in combattenti:
		if combattente.giocatore:
			GameState.modifica_stress(combattente.id,
					combattente.stress - GameState.stress_di(combattente.id))
			# i punti vita rimasti valgono per l'eventuale scontro incatenato
			# subito dopo; Main li azzera appena si respira in una stanza
			GameState.hp_persistenti[combattente.id] = maxi(int(combattente.hp), 1)
	# le destinazioni vanno lette PRIMA di premia/annulla, che le azzerano
	var dopo_vittoria := GameState.nodo_se_vinci
	var dopo_vittoria_eroe := GameState.nodo_se_vinci_eroe
	var dopo_sconfitta := GameState.nodo_se_perdi
	var dopo_fuga := GameState.nodo_se_fuggi if GameState.nodo_se_fuggi != "" else GameState.nodo_se_perdi
	# nessun salvataggio qui: si salva solo dalla mappa stellare, mai dentro
	# un carnivalz/squarcio o in combattimento
	if giocatore_ha_vinto:
		GameState.premia_vittoria(xp_bottino, tazo_bottino, not fonte.is_empty())
		var eroe := convinto and dopo_vittoria_eroe != ""
		GameState.nodo_corrente = dopo_vittoria_eroe if eroe else dopo_vittoria
		get_tree().change_scene_to_file(SCENA_EVENTI)
	elif giocatore_e_fuggito and dopo_fuga != "":
		GameState.annulla_combattimento()
		GameState.nodo_corrente = dopo_fuga
		get_tree().change_scene_to_file(SCENA_EVENTI)
	elif dopo_sconfitta != "":
		GameState.annulla_combattimento()
		GameState.nodo_corrente = dopo_sconfitta
		get_tree().change_scene_to_file(SCENA_EVENTI)
	else:
		GameState.reset_campagna()
		get_tree().change_scene_to_file(SCENA_MAPPA)
