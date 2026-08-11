extends Control

# Combattimento a turni: il MOTORE dei turni, e solo quello.
#
# Chi fa cosa, dopo lo scorporo:
#
#   Combattimento.gd  -> l'ordine dei fatti. Chi agisce, in che sequenza, con
#                        quali conseguenze. Questo file.
#   Regole.gd         -> la matematica. Danno, difesa, critici, esperienza.
#                        Nessun messaggio, nessuna scheda: solo numeri.
#   Voce.gd           -> come il combattimento parla e quando aspetta: la coda
#                        dei messaggi, il box, i numeri che volano.
#   Campo.gd          -> le schede dei combattenti: vita, aura, stati, chi
#                        tocca adesso.
#   Menu.gd           -> i bottoni delle azioni.
#
# Non e' pulizia: e' una capacita'. Voce, Campo e Menu hanno una modalita'
# MUTA in cui non creano niente e non aspettano niente, e allora questo stesso
# motore - identico, non una sua imitazione - puo' giocare uno scontro intero
# in un millesimo di secondo senza uno schermo. E' cosi' che prove/Simulatore.gd
# gioca ogni nemico del gioco migliaia di volte e dice se e' bilanciato.
# Vedi "strategia": se e' impostata, decide lei al posto del menu.
#
# Party e nemici in un'unica fila d'iniziativa ordinata per velocita'
# (ricalcolata a ogni giro). Stats: hp, attacco, difesa, velocita', fattore. I
# buff sono temporanei (n turni). I boss hanno "mosse" pesate nei dati (attacco
# forte / a tutti / buff / evoca) che rendono ogni scontro unico. Menu azioni
# del giocatore: Attacca, Difenditi, Abilita' (Studia sempre disponibile),
# Oggetti (dalla sacca), Alleati (ospiti non combattenti). Esito eroe via
# speranza e cedimento. Numeri in data/regole.json, casualita' solo dall'RNG
# seedato di GameState.


const SCENA_EVENTI := "res://scenes/Main.tscn"
const SCENA_SEDE := "res://scenes/Sede.tscn"

@onready var sfondo: ColorRect = %Sfondo
@onready var fila_party: HBoxContainer = %Party
@onready var nemico_centro: HBoxContainer = %NemicoCentro
@onready var nemici_sinistra: HBoxContainer = %NemiciSinistra
@onready var nemici_destra: HBoxContainer = %NemiciDestra
@onready var etichetta_speranza: Label = %Speranza
@onready var box = %Box
@onready var azioni: HBoxContainer = %Azioni
@onready var volanti: Control = %Volanti
@onready var area_avanza: Button = %AreaAvanza

# I tre collaboratori. In modalita' muta non toccano nessun nodo.
var voce: VoceCombattimento
var campo: CampoCombattimento
var menu: MenuCombattimento

# Muto: nessuno guarda: niente box, niente schede, niente attese. Va impostato
# PRIMA che la scena entri nell'albero (vedi Simulatore.gd).
var muto := false

# Se impostata, sceglie lei le azioni del giocatore al posto del menu. Riceve
# (scontro, combattente) e restituisce lo stesso dizionario che emetterebbe un
# bottone: {"tipo": "attacca", "bersaglio": ...}. E' l'unico aggancio di cui il
# giocatore automatico ha bisogno.
var strategia := Callable()

# Tetto ai giri (0 = nessun tetto). Un giocatore vero prima o poi smette o
# muore; un giocatore automatico con una strategia sbagliata contro un nemico
# invincibile no. "Questo scontro non finisce" e' un risultato, non un blocco.
var limite_giri := 0

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
var leve_giocate: Array[String] = []  # leve "oggetto" gia' usate in questo scontro
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

# Leva di tipo "bersaglio": studiando la fonte abbastanza volte, qualcosa che
# sta nella stanza comincia a reagire e diventa attaccabile. Distruggerlo e' la
# leva. E' il caso delle lettere sull'altare: non si bruciano piu' prima dello
# scontro, si scoprono durante - studiando si nota che vibrano, e che la
# bambola ne soffre l'influenza.
var leve_bersaglio_comparse: Array[String] = []
var leve_bersaglio_riscosse: Array[String] = []

# Stati generici (veleno, congelamento, berserk, maledizione...): vedi
# data/stati.json. Provocazione: un compagno forza i nemici a colpire lui.
var bersaglio_provocazione: Dictionary = {}
var turni_provocazione := 0
var ultima_azione_offensiva := false

# quanto passa fra un numero e il successivo in una raffica: abbastanza poco da
# leggersi come una scarica sola, abbastanza da vederli tutti
const PASSO_RAFFICA := 0.055

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
var tutorial_id := ""  # id del nemico che porta lo script del tutorial

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
var battute_del_giocatore := 0   # quante volte hai mosso: il "limite_giri" conta queste
var id_comandato := ""           # chi stai giocando adesso; vuoto = il protagonista
var menu_acceso := false         # la tua ricarica e' finita e il menu e' aperto
var studio_in_corso := false     # il tempo e' fermo perche' stai studiando
var portatore_fuga_bloccata: Dictionary = {}
var avviso_fuga_mostrato := false

# dialogo_soglia_hp: un nemico puo' dichiarare un hp_soglia e un testo che
# compare una sola volta, alla prima discesa sotto quella soglia.
var soglie_dialogo_mostrate: Dictionary = {}  # indice combattente -> bool

# rabbia_su_morte_alleato: un nemico puo' dichiarare che la morte di un
# certo alleato (es. una sua evocazione) ne aumenta l'attacco - il goblin
# arrabbiato del tutorial diventa piu' pericoloso ogni goblin tipico che cade.
var portatore_rabbia: Dictionary = {}

# Equipaggiamento: ognuno porta il suo, e quello che porta vale solo per lui.
# I bonus numerici (attacco, difesa, velocita', hp_max, aura) entrano nelle
# statistiche quando il combattente viene costruito; le protezioni speciali
# restano attaccate al singolo combattente, non alla squadra:
# "scudo_primo_stato" (respinge il primo stato che LUI subisce e lo immunizza
# per il resto dello scontro) e "resurrezione_dimezzata" (LUI torna in piedi a
# meta' vita invece di cadere). Entrambe si consumano, una volta sola.


func _ready() -> void:
	voce = VoceCombattimento.new(get_tree(), muto)
	campo = CampoCombattimento.new(muto)
	menu = MenuCombattimento.new(self, muto)
	if not muto:
		voce.collega(box, area_avanza, volanti)
		campo.collega(fila_party, nemico_centro, nemici_sinistra, nemici_destra)
		menu.collega(azioni)
		applica_stile()
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
			tutorial_id = id_nemico
			for id_oggetto in tutorial.get("oggetti_forniti", []):
				if not GameState.possiede_oggetto(String(id_oggetto)):
					GameState.aggiungi_oggetto(String(id_oggetto))
	if not tutorial.is_empty():
		# un tutorial e' una scena scritta: deve andare esattamente come
		# previsto, quindi niente equipaggiamento ci mette bocca (niente scudo
		# contro gli stati, niente resurrezione, niente ultima risorsa)
		for combattente in combattenti:
			combattente.scudo_stato = ""
			combattente.resurrezione = ""
			combattente.ultima_risorsa_usata = true
	var categoria_apertura := categoria_migliore_presente()
	if categoria_apertura == "boss" or categoria_apertura == "miniboss":
		scrivi_forte("Il disallineamento fa spazio: si combatte.")
	else:
		scrivi("Ora di combattere.")
	mostra_apertura()
	if not muto:
		avvia_musica_e_voce()
	if fonte.get("convincibile", false):
		if not muto:
			etichetta_speranza.visible = true
		aggiorna_speranza(0)
	applica_leve()
	esegui_scontro()

func applica_stile() -> void:
	# il combattimento e' un'altra stanza dello stesso gioco: stessi colori,
	# stesso font, stessi bordi della schermata eventi
	sfondo.color = Stile.colore("sfondo_combattimento")
	etichetta_speranza.add_theme_color_override("font_color", Stile.colore("accento"))
	etichetta_speranza.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	# il box e' lo stesso componente della schermata eventi: non c'e' niente da
	# impostare qui, si porta dietro corpo del testo, cornice e macchina da
	# scrivere. Il combattimento parla con la stessa voce del resto del gioco
	area_avanza.focus_mode = Control.FOCUS_NONE
	area_avanza.pressed.connect(voce.avanza)
	# in combattimento i messaggi sono corti e il campo ha bisogno di spazio:
	# stesso box della schermata eventi, ma piu' basso
	box.imposta_altezza(Stile.forma("altezza_box_combattimento"))

func _unhandled_input(evento: InputEvent) -> void:
	# da tastiera si salta avanti come col mouse
	if area_avanza.visible and evento.is_action_pressed("ui_accept"):
		voce.avanza()
		get_viewport().set_input_as_handled()

func categoria_migliore_presente() -> String:
	# la categoria più "alta" tra i nemici presenti (per musica e testo d'apertura)
	var ordine := ["boss", "miniboss", "particolare", "comune"]
	var migliore := ordine.size() - 1
	var categoria := "comune"
	for id_nemico in GameState.nemici_combattimento:
		var dati: Dictionary = GameState.personaggi.get(id_nemico, {})
		var idx := ordine.find(RegoleCombattimento.categoria_di(dati))
		if idx >= 0 and idx < migliore:
			migliore = idx
			categoria = ordine[idx]
	return categoria

func mostra_apertura() -> void:
	# Ogni scontro cominciava con un menu. Adesso comincia con la CREATURA: un
	# gesto, una frase, uno sguardo, prima che tu possa fare qualsiasi cosa. La
	# tartaruga ritira la testa, il goblin ti insulta, la manifestazione non
	# dice niente e ti guarda.
	#
	# Costa un campo nei dati ("apertura") e cambia come ci si sente entrando in
	# un combattimento: due scontri diversi non cominciano piu' allo stesso modo.
	# Parla solo la creatura principale - in un'imboscata da tre, tre battute di
	# presentazione sarebbero un'attesa, non un'entrata.
	var principale := creatura_principale()
	var apertura: Variant = principale.get("apertura", null)
	if apertura == null:
		return
	if apertura is String:
		scrivi_forte("[i]%s[/i]" % String(apertura))
		return
	if apertura is Dictionary:
		var testo := String(apertura.get("testo", ""))
		if String(apertura.get("tipo", "narrazione")) == "dialogo":
			scrivi_forte(testo, "dialogo", String(principale.get("nome_breve", principale.get("nome", ""))))
		else:
			scrivi_forte("[i]%s[/i]" % testo)

func creatura_principale() -> Dictionary:
	# la piu' "alta" in campo: il boss se c'e', altrimenti il primo del gruppo.
	# La stessa che decide la musica e il testo d'apertura
	var categoria := categoria_migliore_presente()
	for id_nemico in GameState.nemici_combattimento:
		var dati: Dictionary = GameState.personaggi.get(id_nemico, {})
		if RegoleCombattimento.categoria_di(dati) == categoria:
			return dati
	return {}

func avvia_musica_e_voce() -> void:
	# musica per la categoria più "alta" tra i nemici; voce d'ingresso per boss/miniboss
	var categoria := categoria_migliore_presente()
	var principale: Dictionary = {}
	for id_nemico in GameState.nemici_combattimento:
		var dati: Dictionary = GameState.personaggi.get(id_nemico, {})
		if RegoleCombattimento.categoria_di(dati) == categoria and principale.is_empty():
			principale = dati
	AudioManager.musica_chiave("combattimento_" + categoria)
	if (categoria == "boss" or categoria == "miniboss") and not principale.is_empty():
		AudioManager.voce_boss(String(principale.get("id", "")), principale, "inizio")

func aggiungi_combattente(id_personaggio: String, giocatore: bool) -> void:
	var dati: Dictionary = GameState.personaggi.get(id_personaggio, {})
	var e_protagonista := giocatore and id_personaggio == GameState.id_protagonista
	# quello che ha addosso questo personaggio: vale solo per lui
	var eq := func(chiave: String) -> int:
		return GameState.bonus_equipaggiamento(id_personaggio, chiave) if giocatore else 0
	# Per una creatura i numeri buoni non sono quelli scritti nel suo file: sono
	# quelli del suo livello di ADESSO. Il file dice quanto vale al suo livello
	# base, GameState.stat_nemico dice quanto vale davanti a te (vedi la nota sul
	# fattore Carnivalz in GameState).
	var stat := func(chiave: String, difetto: int) -> int:
		if giocatore:
			return int(dati.get(chiave, difetto))
		return GameState.stat_nemico(id_personaggio, chiave, difetto)
	var hp_max: int = GameState.stat_di("hp") if e_protagonista \
			else int(stat.call("hp", int(GameState.regole.get("hp_base", 25))))
	hp_max = maxi(hp_max + eq.call("hp_max"), 1)
	var hp_iniziali := hp_max
	if giocatore and GameState.hp_persistenti.has(id_personaggio):
		# scontri incatenati: si riprende con i punti vita lasciati dal precedente
		hp_iniziali = clampi(int(GameState.hp_persistenti[id_personaggio]), 1, hp_max)
	var nodi := campo.crea_scheda(id_personaggio, giocatore)
	if not giocatore and GameState.e_creatura(id_personaggio):
		# voce nel bestiario al primo incontro (gli oggetti di scena non ne hanno)
		GameState.registra_bestiario(id_personaggio)
		if not muto:
			AudioManager.verso(id_personaggio, dati, "comparsa")
	var combustione: Dictionary = dati.get("combustione", {})
	var combattente := {
		"indice": combattenti.size(),
		"id": id_personaggio,
		"nome": dati.get("nome_breve", dati.get("nome", id_personaggio)),
		"hp": hp_iniziali,
		"hp_max": hp_max,
		"attacco": maxi((GameState.stat_di("attacco") if e_protagonista else int(stat.call("attacco", 1))) + eq.call("attacco"), 0),
		"difesa": maxi((GameState.stat_di("difesa") if e_protagonista else int(stat.call("difesa", 0))) + eq.call("difesa"), 0),
		"velocita": maxi((GameState.stat_di("velocita") if e_protagonista else int(stat.call("velocita", 3))) + eq.call("velocita"), 1),
		"psiche": String(dati.get("psiche", "")),
		"fattore": GameState.stat_di("fattore") if e_protagonista else int(dati.get("fattore_base", 0)),
		"stress": GameState.stress_di(id_personaggio) if giocatore else 0,
		"xp": int(stat.call("xp", 10)),
		"tazo": int(stat.call("tazo", 0)),
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
		# LA GUARDIA A SCATTI, stile Pokemon: si alza difendendosi, certi colpi
		# la aprono, e resta com'e' fino alla fine dello scontro
		"scatti_difesa": 0,
		# il frammento di vita: quante battute di rigenerazione restano, e quanta
		# vita rimette a posto ognuna
		# la barra di dominio come energia: tre segmenti che si riempiono
		# combattendo e si spendono sugli speciali
		"dominio": 0,
		"rigenerazione_battute": 0,
		"rigenerazione_quota": 0.0,
		"mossa_in_carica": {},
		# quanto vale il prossimo colpo di chi ha passato un turno a caricare:
		# 0 = niente in canna (vedi abilita' di tipo "carica")
		"carica_pronta": 0.0,
		"crisi_turni_rimasti": 0,
		"soglia_gia_scattata": false,
		"ultimo_danno_subito": 0,
		"colpi_incassati": 0,
		# Astio: finche' e' acceso, ogni colpo incassato alza l'attacco
		"astio_turni": 0,
		"astio_frazione": 0.0,
		"astio_testo": "",
		# Mantra IV in su: un turno in cui non ti scalfiscono
		"turni_immune": 0,
		# Pieta': quanto in piu' lascera' cadere questo qui
		"bonus_drop": 0.0,
		"gamba_rotta_turni": 0,
		"gamba_gia_rotta": false,
		"volte_studiato": 0,
		# l'aura e' quello che spendi per forzare il mondo: le abilita' costano,
		# e torna piano da sola a ogni turno. I nemici non ne hanno bisogno
		"aura": GameState.aura_massima(id_personaggio) if giocatore else 0,
		"aura_max": GameState.aura_massima(id_personaggio) if giocatore else 0,
		"aura_per_turno": int(GameState.regole.get("aura_recupero_per_turno", 1)) + eq.call("aura_per_turno"),
		# un solo scudo e una sola resurrezione per chi li porta addosso, non
		# piu' uno per tutta la squadra
		"scudo_stato": "" if not giocatore else id_accessorio_con(id_personaggio, "scudo_primo_stato"),
		"resurrezione": "" if not giocatore else id_accessorio_con(id_personaggio, "resurrezione_dimezzata"),
		"resistenza_maledizione": eq.call("resistenza_maledizione"),
		"ultima_risorsa_usata": false,
		"combustione": combustione,
		"in_fiamme": not combustione.is_empty() and not combustione.has("attiva_da_studio"),
		"hp_nascosti": not giocatore and (RegoleCombattimento.categoria_di(dati) == "boss" or dati.has("incontro_scriptato")),
		"scheda": nodi["scheda"],
		"etichetta_vita": nodi["etichetta_vita"],
		"etichetta_extra": nodi["etichetta_extra"],
		"barra_dominio": nodi.get("barra_dominio", null),
		"bersaglio_cliccabile": nodi.get("bersaglio", null),
	}
	combattenti.append(combattente)
	aggiorna_scheda(combattente)

func id_accessorio_con(id_classe: String, tipo_effetto: String) -> String:
	# quale oggetto addosso a questo personaggio fa quella cosa (lo scudo che
	# respinge il primo stato, l'accessorio che ti rimette in piedi). Vuoto se
	# non ne ha nessuno: sono protezioni personali, non di squadra
	var slots := GameState.slot_di(id_classe)
	var addosso: Array[String] = []
	for slot in ["arma", "stigma"]:
		var id_oggetto := String(slots.get(slot, ""))
		if id_oggetto != "":
			addosso.append(id_oggetto)
	for id_oggetto in slots.get("accessori", []):
		addosso.append(String(id_oggetto))
	for id_oggetto in addosso:
		var effetto: Dictionary = GameState.dati_oggetto(id_oggetto).get("effetto_equipaggiato", {})
		if String(effetto.get("tipo", "")) == tipo_effetto:
			return id_oggetto
	return ""

func applica_leve() -> void:
	# le leve "oggetto" NON scattano da sole: averle in tasca non basta, vanno
	# usate dal menu Oggetti durante lo scontro (vedi leve_utilizzabili/usa_leva).
	# Compagni, ospiti e flag invece pesano gia' per il solo fatto di esserci.
	for leva in fonte.get("leve", []):
		var id_leva: String = leva.get("id", "")
		var presente := false
		match leva.get("tipo", ""):
			"ospite":
				presente = id_leva in GameState.ospiti
			"compagno":
				presente = id_leva in GameState.party
			"flag":
				presente = GameState.ha_flag(id_leva)
		if presente:
			scrivi_forte("[i]%s[/i]" % String(leva.get("testo", "")))
			aggiorna_speranza(int(leva.get("speranza", 0)))
			if leva.has("turni_fermo"):
				# la fonte resta ferma, senza agire, per un tot di suoi turni:
				# un premio extra per l'esplorazione, non solo un bonus speranza
				turni_fermo_leva = maxi(turni_fermo_leva, int(leva["turni_fermo"]))
				testo_fermo_leva = String(leva.get("testo_fermo", ""))

func leve_utilizzabili() -> Array[Dictionary]:
	# le leve "oggetto" che possiedi e non hai ancora giocato in questo scontro
	var risultato: Array[Dictionary] = []
	for leva in fonte.get("leve", []):
		if String(leva.get("tipo", "")) != "oggetto":
			continue
		var id_leva := String(leva.get("id", ""))
		if id_leva in leve_giocate or not GameState.possiede_oggetto(id_leva):
			continue
		risultato.append(leva)
	return risultato

func usa_leva(chi: Dictionary, id_leva: String) -> void:
	# mostrare al nemico l'oggetto giusto: e' un'azione vera, costa il turno,
	# e vale molto piu' di un attacco contro chi si puo' ancora convincere
	for leva in fonte.get("leve", []):
		if String(leva.get("tipo", "")) != "oggetto" or String(leva.get("id", "")) != id_leva:
			continue
		leve_giocate.append(id_leva)
		var nome_oggetto := String(GameState.dati_oggetto(id_leva).get("nome", id_leva))
		scrivi("%s mostra %s." % [chi.nome, nome_oggetto])
		scrivi_forte("[i]%s[/i]" % String(leva.get("testo", "")))
		aggiorna_speranza(int(leva.get("speranza", 0)))
		if leva.has("turni_fermo"):
			turni_fermo_leva = maxi(turni_fermo_leva, int(leva["turni_fermo"]))
			testo_fermo_leva = String(leva.get("testo_fermo", ""))
		return

func aggiorna_speranza(quantita: int) -> void:
	if not fonte.get("convincibile", false):
		return
	speranza = clampi(speranza + quantita, 0, 100)
	if not muto:
		etichetta_speranza.text = "Speranza %d / %d" % [speranza, int(fonte.get("speranza_soglia", 100))]
	if not convinto and speranza >= int(fonte.get("speranza_soglia", 100)):
		var obbligatoria := String(fonte.get("leva_obbligatoria", ""))
		if obbligatoria != "" and obbligatoria not in leve_giocate:
			# la speranza da sola non basta: certe creature cedono solo davanti a
			# una cosa precisa, e finche' non gliela mostri non cedono e basta
			return
		convinto = true
		scrivi_forte(String(fonte.get("testo_cedimento", "Qualcosa, nella fonte, ha ceduto.")))
		if not muto:
			AudioManager.voce_boss(String(fonte.get("id", "")), fonte, "cedimento")

# --- IL TEMPO: UN MOTORE, DUE OROLOGI ----------------------------------------
#
# Via i turni. Ogni combattente ha una RICARICA che scorre da sola: quando
# finisce, quello agisce, e la ricarica riparte. I nemici non aspettano che tu
# scelga - se stai fermo, ti arrivano addosso lo stesso. E' questo che rende il
# gioco frenetico pur restando una schermata ferma.
#
# UNA BATTUTA E' UN CICLO DI RICARICA TUO. Non un tempo globale: il tuo. Cosi'
# "tre turni di veleno" vuol dire tre tue battute, esattamente come prima, e
# tutto quello che contava i turni - stati, Astio, guardia, rigenerazione -
# continua a funzionare senza sapere che il mondo e' cambiato sotto. Era la
# traduzione giusta: un turno E' sempre stato "la prossima volta che tocca a te".
#
# I DUE OROLOGI. In gioco il tempo lo da' _process(delta). Nelle prove e nel
# giocatore automatico non si puo' aspettare quarantamila secondi veri, quindi
# c'e' un orologio virtuale che SALTA al prossimo momento in cui qualcuno
# agisce. Non e' una scorciatoia che misura un gioco diverso: l'ordine delle
# azioni e' lo stesso, perche' e' calcolato dalle stesse ricariche. Cambia solo
# se il tempo lo conta un cronometro o l'aritmetica.
#
# IL TEMPO SI FERMA quando il gioco ha qualcosa da dirti, e solo allora: mentre
# studi una creatura, e mentre un boss esegue uno script. Bru: "se un nemico
# viene colpito da studio, il combattimento si ferma solo mentre i dialoghi di
# studio avvengono".

var tempo_reale := true      # false nelle prove e nel simulatore: orologio virtuale
var tempo_fermo := 0         # > 0 il tempo non scorre (studio, script di boss)
var orologio := 0.0          # secondi trascorsi nello scontro
var scontro_avviato := false

func ferma_il_tempo() -> void:
	tempo_fermo += 1

func riprendi_il_tempo() -> void:
	tempo_fermo = maxi(tempo_fermo - 1, 0)

func il_tempo_scorre() -> bool:
	return in_corso and tempo_fermo <= 0

func ricarica_di(combattente: Dictionary) -> float:
	# quanto ci mette a rimuoversi. Piu' sei veloce, meno aspetti
	var dati: Dictionary = GameState.regole.get("tempo", {})
	var riferimento := maxf(float(dati.get("velocita_riferimento", 6)), 1.0)
	var mia := maxf(float(RegoleCombattimento.velocita_effettiva(combattente)), 1.0)
	var secondi := float(dati.get("ricarica_base", 1.6)) * (riferimento / mia)
	return clampf(secondi, float(dati.get("ricarica_minima", 0.45)),
			float(dati.get("ricarica_massima", 4.0)))

func puo_agire(combattente: Dictionary) -> bool:
	return in_corso and int(combattente.hp) > 0 \
			and not combattente.get("oggetto_scena", false) \
			and float(combattente.get("ricarica", 1.0)) <= 0.0

func riarma(combattente: Dictionary) -> void:
	combattente.ricarica = ricarica_di(combattente)

func prossimo_evento() -> float:
	# fra quanti secondi qualcuno si muove. INF se non si muove piu' nessuno
	var minimo := INF
	for combattente in combattenti:
		if int(combattente.hp) <= 0 or combattente.get("oggetto_scena", false):
			continue
		minimo = minf(minimo, maxf(float(combattente.get("ricarica", 0.0)), 0.0))
	return minimo

func avanza_orologio(delta: float) -> void:
	# IL BATTITO DEL MONDO. Scorre per tutti insieme; chi arriva a zero agisce.
	if not il_tempo_scorre():
		return
	orologio += delta
	for combattente in combattenti:
		if int(combattente.hp) <= 0 or combattente.get("oggetto_scena", false):
			continue
		combattente.ricarica = float(combattente.get("ricarica", 0.0)) - delta
	# agisce chi e' piu' in ritardo: se due ricariche scadono insieme, decide la
	# velocita', come faceva l'iniziativa
	var pronti: Array[Dictionary] = []
	for combattente in combattenti:
		if puo_agire(combattente) and not (combattente.giocatore and comandi_tu(combattente)):
			pronti.append(combattente)
	pronti.sort_custom(func(a, b):
		var ra := float(a.get("ricarica", 0.0))
		var rb := float(b.get("ricarica", 0.0))
		if not is_equal_approx(ra, rb):
			return ra < rb
		return RegoleCombattimento.velocita_effettiva(a) > RegoleCombattimento.velocita_effettiva(b))
	for combattente in pronti:
		if not in_corso or int(combattente.hp) <= 0:
			continue
		riarma(combattente)
		battuta_di(combattente)
		if not tempo_reale:
			# orologio virtuale: la coda si legge subito, non c'e' nessuno che guarda
			continue
	verifica_avviso_fuga()
	if limite_giri > 0 and battute_del_giocatore >= limite_giri:
		in_corso = false

func comandi_tu(combattente: Dictionary) -> bool:
	# CHI GIOCHI TU. Bru: "il party agira' da solo come i nemici, ma tu avrai la
	# possibilita' di usare tutti i combattenti: scegli tu chi utilizzare, gli
	# altri andranno sempre in automatico". Quindi comandato ce n'e' uno solo, e
	# se non lo dici e' il protagonista
	if not combattente.get("giocatore", false):
		return false
	if strategia.is_valid():
		return false   # il giocatore automatico li muove tutti
	var comandato := id_comandato if id_comandato != "" else GameState.id_protagonista
	return String(combattente.get("id", "")) == comandato

func _process(delta: float) -> void:
	if not tempo_reale or not scontro_avviato or muto:
		return
	# IL TEMPO RIPARTE DA SOLO quando non c'e' piu' niente da leggere. Sbloccare
	# dentro studia() sarebbe stato piu' diretto e sbagliato: quella funzione ha
	# quattro uscite anticipate, e una sola dimenticata lascerebbe il mondo
	# fermo per sempre. Qui invece la condizione e' una cosa che si guarda, non
	# una cosa da ricordarsi
	if studio_in_corso and voce != null and voce.coda.is_empty():
		studio_in_corso = false
		riprendi_il_tempo()
	avanza_orologio(delta)
	aggiorna_pronto_giocatore()

func esegui_scontro() -> void:
	await svuota_coda()   # l'apertura si legge prima che qualcuno si muova
	# nessuno parte a ricarica zero: c'e' il tempo di guardare chi hai davanti
	var apertura := float(GameState.regole.get("tempo", {}).get("apertura_secondi", 1.2))
	for combattente in combattenti:
		combattente.ricarica = ricarica_di(combattente) * 0.5 + apertura
	scontro_avviato = true
	if tempo_reale and not muto:
		# da qui in poi comanda _process per il tempo, e la pompa per le parole.
		#
		# SENZA LA POMPA NON SI VEDEVA NIENTE. Nel motore a turni era il ciclo a
		# svuotare la coda dopo ogni azione; togliendolo, i messaggi si
		# accumulavano e non arrivava a schermo un solo numero di danno - e lo
		# scontro non si chiudeva mai, perche' anche la fine stava li'. Bru:
		# "non sto subendo danni ne' riesco ad infliggerli, il primo
		# combattimento blocca tutto". Succedeva tutto: non si vedeva.
		for combattente in combattenti:
			collega_bersaglio(combattente)
		menu.principale()
		pompa_messaggi()
		return
	# --- orologio virtuale: le prove e il giocatore automatico ---
	#
	# IL TETTO NON E' PRUDENZA, E' LA DIAGNOSI. Un ciclo che fa girare il mondo
	# non deve poter girare a vuoto: se la condizione d'uscita si rompe, senza
	# tetto il gioco non fallisce - si pianta, e chi guarda vede solo che "e'
	# lento". Con il tetto diventa un errore con scritto cosa non e' scattato,
	# e si trova in un secondo invece che in un pomeriggio.
	var giri_di_sicurezza := int(GameState.regole.get("tempo", {}).get("battute_massime", 4000))
	var giri := 0
	while in_corso:
		giri += 1
		if giri > giri_di_sicurezza:
			push_error("Combattimento: l'orologio virtuale ha fatto %d giri senza che lo scontro finisse (battute del protagonista: %d, limite: %d). Qualcosa non fa piu' scattare la fine."
					% [giri, battute_del_giocatore, limite_giri])
			in_corso = false
			break
		var salto := prossimo_evento()
		if salto == INF:
			break
		avanza_orologio(maxf(salto, 0.0001))
		if not in_corso:
			break
		for combattente in combattenti:
			if puo_agire(combattente) and combattente.giocatore and comandi_tu(combattente):
				riarma(combattente)
				battuta_di(combattente)
		await svuota_coda()
	await svuota_coda()
	mostra_continua_fine()

func collega_bersaglio(combattente: Dictionary) -> void:
	var bottone = combattente.get("bersaglio_cliccabile", null)
	if bottone == null or not is_instance_valid(bottone):
		return
	if not bottone.pressed.is_connected(_su_click_nemico):
		bottone.pressed.connect(_su_click_nemico.bind(combattente))

func _su_click_nemico(bersaglio: Dictionary) -> void:
	# IL COLPO NORMALE E' IL NEMICO, non una voce di menu. Si martella li'
	# sopra: se la ricarica non e' pronta il click non fa niente, e la scheda
	# del protagonista lo dice gia' con la sua barra
	if int(bersaglio.get("hp", 0)) <= 0 or not il_tempo_scorre():
		return
	agisci_ora({"tipo": "attacca", "bersaglio": bersaglio})

func pompa_messaggi() -> void:
	# LE PAROLE SCORRONO, IL MONDO NON SI FERMA. In tempo reale la coda non puo'
	# essere un'attesa: si legge quello che si fa in tempo di leggerlo, e intanto
	# i nemici continuano. Quando lo scontro finisce, si finisce di leggere e
	# solo allora compare "Continua".
	voce.tempo_reale = true
	while in_corso:
		if voce.coda.is_empty():
			await get_tree().process_frame
			continue
		await svuota_coda()
	await svuota_coda()
	mostra_continua_fine()

func aggiorna_pronto_giocatore() -> void:
	# il menu si accende quando la tua ricarica e' finita, e si spegne mentre
	# ricarichi: e' l'unico modo di far vedere il tempo in una schermata ferma
	if menu == null:
		return
	var tu := combattente_comandato()
	var pronto := not tu.is_empty() and puo_agire(tu)
	if pronto != menu_acceso:
		menu_acceso = pronto
		attaccante_corrente = tu
		if pronto:
			menu.principale()
		else:
			menu.pulisci()

func combattente_comandato() -> Dictionary:
	for combattente in combattenti:
		if comandi_tu(combattente) and int(combattente.hp) > 0:
			return combattente
	return {}

func agisci_ora(azione: Dictionary) -> void:
	# L'AZIONE DEL GIOCATORE, presa quando la prende lui. Non c'e' piu' nessuno
	# che aspetta: se la tua ricarica non e' finita, il click non fa niente -
	# e il menu spento lo dice gia'
	var tu := combattente_comandato()
	if tu.is_empty() or not puo_agire(tu):
		return
	riarma(tu)
	attaccante_corrente = tu
	esegui_azione(tu, azione)
	menu_acceso = false
	menu.pulisci()

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
	menu.pulisci()
	menu.bottone("▸ Continua", _esci)

func risolvi_rigenerazione_frammento(chi: Dictionary) -> void:
	if int(chi.get("rigenerazione_battute", 0)) <= 0 or int(chi.hp) <= 0:
		return
	chi.rigenerazione_battute = int(chi.rigenerazione_battute) - 1
	var quanto := maxi(int(round(int(chi.hp_max) * float(chi.get("rigenerazione_quota", 0.10)))), 1)
	var prima := int(chi.hp)
	chi.hp = mini(int(chi.hp) + quanto, int(chi.hp_max))
	var recuperati := int(chi.hp) - prima
	if recuperati > 0:
		var scheda_curato: Control = chi.scheda
		scrivi("[i]%s si rimette insieme: +%d.[/i]" % [chi.nome, recuperati])
		voce.accoda_effetto(func() -> void:
			voce.suono("cura")
			voce.numero_volante(scheda_curato, "+%d" % recuperati, Stile.colore("positivo"))
			aggiorna_scheda(chi))

func esegui_turno(attaccante: Dictionary) -> void:
	# resta per l'orologio virtuale e per chi la chiamava: una battuta e' quello
	# che prima era un turno
	battuta_di(attaccante)

func battuta_di(attaccante: Dictionary) -> void:
	# TOCCA A LUI. La ricarica e' finita: prima si paga quello che si paga a
	# ogni battuta (stati, fuoco addosso, aura che torna), poi si agisce.
	# LE BATTUTE DEL PROTAGONISTA SI CONTANO SEMPRE, chiunque lo muova.
	#
	# QUI STAVA IL CICLO INFINITO. Contarle solo quando lo comanda una persona
	# sembrava equivalente - e' il giocatore in tutti e due i casi - ma col
	# giocatore automatico "comandi_tu" e' falso per definizione: il contatore
	# restava a zero, "limite_giri" non scattava mai, e l'orologio virtuale
	# girava a vuoto per sempre. Il gioco non si rompeva: semplicemente non
	# tornava. E' la sostituzione di quello che prima faceva "giro_corrente",
	# che si alzava a ogni giro senza chiedere niente a nessuno.
	if attaccante.giocatore and String(attaccante.get("id", "")) == GameState.id_protagonista:
		battute_del_giocatore += 1
	risolvi_rigenerazione_frammento(attaccante)
	RegoleCombattimento.scadenza_buff(attaccante)
	scala_astio(attaccante)
	if int(attaccante.get("turni_immune", 0)) > 0:
		# l'immunita' di Mantra copre il giro fino al tuo turno successivo: si
		# consuma qui, quando torni a muovere, non a fine giro
		attaccante.turni_immune = int(attaccante.turni_immune) - 1
	aggiorna_scheda(attaccante)
	recupera_aura(attaccante)
	campo.evidenzia(combattenti, attaccante)
	if attaccante.in_fiamme:
		applica_combustione(attaccante)
		if attaccante.hp <= 0:
			return  # bruciato prima di poter agire
	if risolvi_stati_a_inizio_turno(attaccante):
		return  # il turno salta per uno stato (congelamento, sonno, egocentrismo, demotivazione) o la maledizione lo uccide
	ultima_azione_offensiva = false
	if attaccante.giocatore:
		attaccante_corrente = attaccante
		if RegoleCombattimento.ha_stato_attivo(attaccante, "berserk"):
			scrivi("[i]%s ha perso il controllo: può solo attaccare.[/i]" % attaccante.nome)
			var nemici := vivi(false)
			if not nemici.is_empty():
				attacca(attaccante, nemici[GameState.rng.randi_range(0, nemici.size() - 1)],
						-1, consuma_carica(attaccante))
		else:
			var passo_corrente := passo_tutorial()
			if not passo_corrente.is_empty() and tutorial_passo not in tutorial_passi_introdotti:
				tutorial_passi_introdotti.append(tutorial_passo)
				for msg in passo_corrente.get("prima", []):
					scrivi_messaggio_tutorial(msg)
			var azione: Dictionary = {}
			if strategia.is_valid():
				# nessuno sta guardando: decide il giocatore automatico
				azione = strategia.call(self, attaccante)
			elif comandi_tu(attaccante):
				# LO DECIDI TU, E NON ADESSO. In tempo reale la battuta non
				# aspetta nessuno: il menu si accende e il mondo continua a
				# girare finche' non clicchi (vedi agisci_ora)
				menu_acceso = true
				attaccante_corrente = attaccante
				attaccante.ricarica = 0.0   # resta pronto finche' non agisce
				if not muto:
					menu.principale()
				return
			else:
				# un compagno che non stai comandando se la cava da solo
				azione = azione_automatica(attaccante)
			esegui_azione(attaccante, azione)
			return
	else:
		turno_nemico(attaccante)
	coda_di_battuta(attaccante)

func azione_automatica(chi: Dictionary) -> Dictionary:
	# UN COMPAGNO CHE NON STAI COMANDANDO SE LA CAVA DA SOLO. Non e' un'IA
	# raffinata e non deve esserlo: deve fare la cosa ovvia in fretta, perche'
	# la testa del giocatore e' su chi sta comandando lui. Si cura se sta per
	# cadere, spende la barra se e' carica, altrimenti picchia.
	var nemici := vivi(false)
	if nemici.is_empty():
		return {"tipo": "difendi"}
	if float(chi.hp) / maxf(float(chi.get("hp_max", 1)), 1.0) < 0.3 \
			and GameState.rng.randf() < 0.5:
		return {"tipo": "difendi"}
	for id_abilita in GameState.abilita_usabili(String(chi.get("id", ""))):
		var dati := GameState.abilita_combattimento(String(id_abilita))
		if dati.is_empty() or int(dati.get("aura", 0)) > int(chi.get("aura", 0)):
			continue
		var segmenti := float(dati.get("dominio", 0.0))
		if segmenti > 0.0 and not RegoleCombattimento.puo_spendere_dominio(chi, segmenti):
			continue
		if segmenti > 0.0 and GameState.rng.randf() < 0.6:
			if abilita_vuole_bersaglio(String(id_abilita)):
				return {"tipo": "abilita", "id": String(id_abilita),
						"bersaglio": nemici[GameState.rng.randi_range(0, nemici.size() - 1)]}
			return {"tipo": "abilita", "id": String(id_abilita)}
	return {"tipo": "attacca",
			"bersaglio": nemici[GameState.rng.randi_range(0, nemici.size() - 1)]}

func esegui_azione(attaccante: Dictionary, azione: Dictionary) -> void:
	ultima_azione_offensiva = false
	if true:
		if true:
			var bersaglio_scelto: Dictionary = azione.get("bersaglio", {})
			if azione.get("tipo", "") == "attacca" and RegoleCombattimento.ha_stato_attivo(attaccante, "confusione") \
					and GameState.rng.randf() < 0.5:
				var chiunque: Array[Dictionary] = []
				for c in vivi(true) + vivi(false):
					if c.indice != attaccante.indice:
						chiunque.append(c)
				if not chiunque.is_empty():
					bersaglio_scelto = chiunque[GameState.rng.randi_range(0, chiunque.size() - 1)]
					scrivi("[i]%s è confuso e colpisce %s per sbaglio![/i]" % [attaccante.nome, bersaglio_scelto.nome])
			match azione.get("tipo", ""):
				"attacca":
					colpo_darma(attaccante, bersaglio_scelto, azione.get("arma", {}))
				"difendi":
					difendi(attaccante)
				"studia":
					studia(attaccante, bersaglio_scelto)
				"oggetto":
					usa_oggetto(attaccante, azione.id)
				"alleato":
					usa_alleato(azione.id)
				"abilita":
					var su: Dictionary = azione.get("bersaglio", {})
					if su.is_empty():
						usa_abilita(attaccante, String(azione.get("id", "")))
					else:
						usa_abilita_su(attaccante, String(azione.get("id", "")), su)
				"fuggi":
					fuggi(attaccante)
				"leva":
					usa_leva(attaccante, String(azione.get("id", "")))
			# il passo del tutorial si chiude solo a azione risolta: cosi' le
			# battute "dopo" commentano quel che e' appena successo, non lo anticipano
			avanza_tutorial(azione)
	coda_di_battuta(attaccante)

func coda_di_battuta(attaccante: Dictionary) -> void:
	if giocatore_e_fuggito:
		return  # il combattimento e' finito qui, niente altro da risolvere sul turno
	risolvi_dot_condizionale(attaccante, ultima_azione_offensiva)
	var passo := int(GameState.regole.get("stress_per_fattore", 25))
	var costo := floori(attaccante.fattore / float(maxi(passo, 1)))
	if costo > 0:
		aggiungi_stress(attaccante, costo)

func scrivi_messaggio_tutorial(msg: Dictionary) -> void:
	var testo := String(msg.get("testo", ""))
	if testo.find("{nome}") != -1:
		testo = testo.replace("{nome}", String(GameState.personaggi.get(GameState.id_protagonista, {}).get("nome", "")))
	match String(msg.get("tipo", "narrazione")):
		"dialogo":
			var chi := String(msg.get("chi", GameState.id_protagonista))
			var scheda_chi: Dictionary = GameState.personaggi.get(chi, {})
			scrivi_forte(testo, "dialogo", String(scheda_chi.get("nome", chi)))
		"notifica":
			scrivi_forte(testo, "notifica")
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
	applica_hp_scriptati(passo)
	tutorial_passo += 1
	if tutorial_passo >= tutorial.get("passi", []).size():
		concludi_tutorial()

func applica_hp_scriptati(passo: Dictionary) -> void:
	# il tutorial e' una scena: certi colpi devono lasciare esattamente i punti
	# vita che il copione prevede, non quelli che verrebbero dai numeri veri
	if passo.has("hp_protagonista"):
		for c in combattenti:
			if c.giocatore and c.id == GameState.id_protagonista:
				c.hp = clampi(int(passo["hp_protagonista"]), 1, int(c.hp_max))
				aggiorna_scheda(c)
	if passo.has("hp_nemico") and tutorial_id != "":
		for c in combattenti:
			if not c.giocatore and c.id == tutorial_id:
				c.hp = clampi(int(passo["hp_nemico"]), 1, int(c.hp_max))
				aggiorna_scheda(c)

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

func alleati_disponibili() -> Array[String]:
	var risultato: Array[String] = []
	for id_ospite in GameState.ospiti:
		if GameState.personaggi.get(id_ospite, {}).has("assist") and id_ospite not in alleati_usati:
			risultato.append(id_ospite)
	return risultato

# --- azioni ---

func difendi(chi: Dictionary) -> void:
	# LA GUARDIA RESTA. Si alza di uno scatto e non si azzera piu' fino alla
	# fine dello scontro: difendersi cinque volte vale cinque volte, non una.
	# Il tetto agli scatti e' quello che impedisce di diventare inattaccabili
	# stando fermi (vedi RegoleCombattimento.moltiplicatore_scatti).
	var tetto := int(GameState.regole.get("difesa_scatti_massimi", 6))
	if RegoleCombattimento.scatti_difesa(chi) >= tetto:
		scrivi("[i]%s è già chiuso quanto può: la guardia non sale oltre.[/i]" % chi.nome)
		if chi.giocatore and chi.id == GameState.id_protagonista:
			GameState.registra_azione("difese")
		aggiorna_scheda(chi)
		return
	var guadagno := RegoleCombattimento.alza_guardia(chi)
	scrivi("%s si mette in guardia (difesa +%d, ora %d)." % [
			chi.nome, guadagno, RegoleCombattimento.difesa_di(chi)])
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

func spendi_aura(chi: Dictionary, quanta: int) -> void:
	chi.aura = maxi(int(chi.aura) - quanta, 0)
	aggiorna_scheda(chi)

func recupera_aura(chi: Dictionary) -> void:
	# l'aura torna piano da sola: a fine scontro non e' mai un problema, ma
	# dentro un turno lungo bisogna sceglierne l'uso
	if int(chi.get("aura_max", 0)) <= 0:
		return
	var prima := int(chi.aura)
	chi.aura = mini(prima + int(chi.get("aura_per_turno", 1)), int(chi.aura_max))
	if chi.aura != prima:
		aggiorna_scheda(chi)

func applica_effetto(utente: Dictionary, effetto: Dictionary, moltiplicatore := 1.0) -> void:
	# "moltiplicatore" > 1 quando l'oggetto e' scattato dallo slot Ultima
	# risorsa: la stessa fiala, tenuta li' per quando serve davvero, rende di piu'
	var scala := func(quanto: int) -> int:
		return int(round(float(quanto) * moltiplicatore))
	if effetto.has("hp") and not utente.is_empty():
		var prima := int(utente.hp)
		utente.hp = clampi(utente.hp + scala.call(int(effetto.hp)), 0, utente.hp_max)
		var recuperati := int(utente.hp) - prima
		if recuperati > 0:
			# la cura si vede come si vede il danno: un numero che sale, verde
			var scheda_curato: Control = utente.scheda
			voce.accoda_effetto(func() -> void:
				voce.suono("cura")
				voce.numero_volante(scheda_curato, "+%d" % recuperati, Stile.colore("positivo"))
				aggiorna_scheda(utente))
		else:
			aggiorna_scheda(utente)
	if effetto.has("rigenerazione_battute") and not utente.is_empty():
		# IL FRAMMENTO DI VITA. Non ridà una cifra: apre una rigenerazione che
		# dura qualche battuta e rimette a posto una frazione di quello che hai.
		# È poca apposta - un decimo per battuta - perché il valore non sta nel
		# quanto, sta nel QUANDO lo prendi: preso al momento giusto ti tiene in
		# piedi tre battute, preso a caso non cambia niente.
		utente.rigenerazione_battute = int(effetto.rigenerazione_battute)
		utente.rigenerazione_quota = float(effetto.get("rigenerazione_percentuale", 0.10)) * moltiplicatore
		scrivi("[i]%s comincia a rimettersi insieme.[/i]" % utente.nome)
	if effetto.has("aura") and not utente.is_empty():
		var aura_prima := int(utente.get("aura", 0))
		utente.aura = mini(aura_prima + scala.call(int(effetto.aura)), int(utente.get("aura_max", 0)))
		var recuperata := int(utente.aura) - aura_prima
		if recuperata > 0:
			var scheda_aura: Control = utente.scheda
			voce.accoda_effetto(func() -> void:
				voce.numero_volante(scheda_aura, "+%d aura" % recuperata, Stile.colore("accento"))
				aggiorna_scheda(utente))
	if effetto.has("stress") and not utente.is_empty():
		aggiungi_stress(utente, scala.call(int(effetto.stress)))
	if effetto.has("speranza"):
		aggiorna_speranza(scala.call(int(effetto.speranza)))
	if effetto.has("difesa_incontro") and not utente.is_empty():
		# dura per il resto dello scontro, non solo un turno come "Difenditi"
		utente.buffs.append({"stat": "difesa", "valore": scala.call(int(effetto.difesa_incontro)), "turni": 900})
		aggiorna_scheda(utente)
	if effetto.has("cura_stato") and not utente.is_empty():
		# cura mirata: toglie un solo male, quello scritto nell'oggetto
		var id_stato := String(effetto.cura_stato)
		var nome_stato := String(GameState.stati.get(id_stato, {}).get("nome", id_stato))
		if utente.stati_attivi.has(id_stato):
			utente.stati_attivi.erase(id_stato)
			scrivi("[i]%s si libera di %s.[/i]" % [utente.nome, nome_stato.to_lower()])
			aggiorna_scheda(utente)
		else:
			scrivi("[i]%s non ne aveva bisogno: niente %s addosso.[/i]" % [utente.nome, nome_stato.to_lower()])
	if effetto.get("cura_stati", false) and not utente.is_empty():
		utente.stati_attivi.clear()
		aggiorna_scheda(utente)
	if effetto.has("danno"):
		var bersaglio := primo_nemico()
		if not bersaglio.is_empty():
			# un petardo fa fuoco, una fiala d'acido fa veleno: lo dice l'oggetto
			colpisci_diretto(bersaglio, scala.call(int(effetto.danno)),
					String(effetto.get("elemento", "")))

func studia(chi: Dictionary, scelto: Dictionary = {}) -> void:
	# IL TEMPO SI FERMA MENTRE STUDI, e solo qui. Bru: "se un nemico viene
	# colpito da studio, il combattimento si ferma solo mentre i dialoghi di
	# studio avvengono".
	#
	# Senza questo, studiare in tempo reale sarebbe una punizione: apri una
	# pagina di testo e intanto ti picchiano tre creature. Ma lo Studio e' il
	# cuore del gioco - e' cosi' che si scoprono le leve - quindi non puo'
	# costare il fatto di non poter leggere. Il tempo riparte da solo appena
	# l'ultima riga e' stata letta (vedi riprendi_dopo_studio).
	if tempo_reale and not muto:
		ferma_il_tempo()
		studio_in_corso = true
	# il bersaglio arriva dal menu; se e' caduto nel frattempo (o se qualcuno
	# chiama studia() senza sceglierlo) si ripiega sulla fonte
	var bersaglio := scelto if not scelto.is_empty() and int(scelto.get("hp", 0)) > 0 else primo_nemico()
	if bersaglio.is_empty():
		return
	if not portatore_frenesia.is_empty() and bersaglio.id == portatore_frenesia.id \
			and frenesia_attiva and not bersaglio_extra_sbloccato:
		bersaglio_extra_sbloccato = true
		var dati_frenesia: Dictionary = portatore_frenesia.get("frenesia", {})
		scrivi_forte(String(dati_frenesia.get("testo_sblocco_bersaglio", "")), "dialogo", String(bersaglio.nome))
		attiva_bersaglio_extra()
		GameState.segna_studiato(bersaglio.id)
		return
	bersaglio.volte_studiato += 1
	verifica_leve_bersaglio(bersaglio)
	if bersaglio.get("hp_nascosti", false) and "studio_compulsivo" in GameState.classi.get(chi.id, {}).get("abilita", []):
		# solo chi ha questa passiva riesce a strappare gli hp esatti a un
		# nemico che di norma non li mostra (i boss, o i nemici scriptati)
		bersaglio.hp_nascosti = false
		aggiorna_scheda(bersaglio)
		scrivi_forte("[i]Studio compulsivo: %s scopre i punti vita esatti di %s.[/i]" % [chi.nome, bersaglio.nome])
	var dati: Dictionary = GameState.personaggi.get(bersaglio.id, {})
	var scambi: Array = dati.get("studio", [])
	if convinto and bersaglio.id == fonte.get("id", "") and dati.has("studio_cedimento"):
		scambi = dati["studio_cedimento"]
	if scambi.is_empty():
		scrivi_forte("[i]%s non sembra rispondere ad alcun quesito.[/i]" % bersaglio.nome)
	elif dati.has("testo_studio_esaurito") and int(bersaglio.volte_studiato) > scambi.size():
		# il pool di scambi e' finito: non si ricomincia da capo all'infinito.
		# Se pero' il suo colpo fatale e' gia' stato respinto, non e' piu' lei a
		# confondere te: sei tu a vedere lei per quello che e' diventata
		var testo_esaurito := String(dati["testo_studio_esaurito"])
		if incontro_tentativi_morfeo > 0 and dati.get("incontro_scriptato", {}).has("testo_studio_dopo_scudo"):
			testo_esaurito = String(dati["incontro_scriptato"]["testo_studio_dopo_scudo"])
		scrivi_forte("[i]%s[/i]" % testo_esaurito)
	else:
		var scambio: Dictionary = scambi[indice_studio % scambi.size()]
		indice_studio += 1
		if scambio.has("osservazione"):
			scrivi_forte("[i]%s[/i]" % String(scambio["osservazione"]))
		else:
			# le domande dei nemici generici sono pescate a caso da un pool
			# condiviso; solo boss e creature particolari hanno una domanda
			# scritta apposta
			var domanda: String = scambio.get("domanda", "")
			if domanda == "":
				domanda = GameState.domanda_studio_casuale()
			scrivi_forte(domanda, "dialogo", String(chi.nome))
			scrivi_forte(String(scambio.get("risposta", "")), "dialogo", String(bersaglio.nome))
	GameState.segna_studiato(bersaglio.id)
	if chi.giocatore and chi.id == GameState.id_protagonista:
		GameState.registra_azione("studi")
	if bersaglio.id == fonte.get("id", ""):
		aggiorna_speranza(int(GameState.regole.get("speranza_studio", 10)))
	verifica_innesco_combustione(bersaglio)
	if dati.has("risparmio") and bersaglio.hp > 0:
		# certe creature cedono al primo sguardo, altre vanno ascoltate a lungo:
		# "studi_richiesti" dice quante volte va studiata prima che si possa
		# lasciarla andare (1 se non specificato)
		var dati_risparmio: Dictionary = dati["risparmio"]
		if int(bersaglio.volte_studiato) >= maxi(int(dati_risparmio.get("studi_richiesti", 1)), 1):
			risparmia(bersaglio, dati_risparmio)

func risparmia(bersaglio: Dictionary, dati_risparmio: Dictionary) -> void:
	# studiare certi nemici rivela che non meritano di essere uccisi: escono
	# dal combattimento senza dare xp/tazo/drop, ma il legame sale e lo
	# stress della squadra scende. Gli altri nemici del combattimento restano.
	# risparmiare e' una decisione, non un'azione: si legge con calma, e si
	# vede subito cosa comporta. Prima costava xp e Tazo in silenzio, e il
	# giocatore non poteva sapere che scambio stesse facendo
	scrivi_forte(String(dati_risparmio.get("testo", "Decidi di risparmiarlo.")))
	var conseguenze: Array[String] = []
	if dati_risparmio.has("legame"):
		GameState.modifica_legame(int(dati_risparmio.legame))
		conseguenze.append("il legame della squadra sale di %d" % absi(int(dati_risparmio.legame)))
	if dati_risparmio.has("stress"):
		for alleato in vivi(true):
			alleato.stress = clampi(alleato.stress + int(dati_risparmio.stress), 0, 100)
			aggiorna_scheda(alleato)
		var quanto := int(dati_risparmio.stress)
		conseguenze.append(("lo stress cala di %d" if quanto < 0 else "lo stress sale di %d") % absi(quanto))
	var xp_uccidendo := RegoleCombattimento.xp_effettiva(bersaglio)
	var xp_lasciandolo := RegoleCombattimento.xp_da_risparmio(bersaglio)
	if xp_lasciandolo > xp_uccidendo:
		conseguenze.append("ne ricavi %d esperienza invece dei %d che ti avrebbe dato da morto"
				% [xp_lasciandolo, xp_uccidendo])
	if int(bersaglio.tazo) > 0:
		conseguenze.append("niente Tazo: non si fruga addosso a chi hai lasciato vivo")
	scrivi_forte("Lo lasci andare: " + ", ".join(conseguenze) + ".")
	if dati_risparmio.has("oggetto"):
		var id_oggetto := String(dati_risparmio.oggetto)
		if GameState.aggiungi_oggetto(id_oggetto):
			scrivi_forte("Prima di sparire ti lascia una cosa: %s."
					% String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)), "notifica")
	bersaglio.risparmiato = true
	bersaglio.hp = 0
	aggiorna_scheda(bersaglio)
	_su_ko(bersaglio)

func verifica_leve_bersaglio(bersaglio: Dictionary) -> void:
	# studiare la fonte abbastanza volte fa comparire quello che le sta accanto
	if bersaglio.id != fonte.get("id", ""):
		return
	for leva in fonte.get("leve", []):
		if String(leva.get("tipo", "")) != "bersaglio":
			continue
		var id_leva := String(leva.get("id", ""))
		if id_leva in leve_bersaglio_comparse:
			continue
		if int(bersaglio.volte_studiato) < int(leva.get("dopo_studi", 3)):
			continue
		leve_bersaglio_comparse.append(id_leva)
		scrivi_forte("[i]%s[/i]" % String(leva.get("testo_comparsa", "")))
		crea_oggetto_scena(id_leva, int(leva.get("hp", 30)))

func leva_bersaglio_di(id_combattente: String) -> Dictionary:
	for leva in fonte.get("leve", []):
		if String(leva.get("tipo", "")) == "bersaglio" and String(leva.get("id", "")) == id_combattente:
			return leva
	return {}

func crea_oggetto_scena(id_bersaglio: String, punti_vita: int) -> void:
	# un oggetto di scena non agisce mai e non vale niente: sta li' per essere
	# colpito. Vive nella fila dei nemici solo perche' e' li' che si prende la mira
	aggiungi_combattente(id_bersaglio, false)
	var oggetto: Dictionary = combattenti.back()
	oggetto.oggetto_scena = true
	oggetto.hp = punti_vita
	oggetto.hp_max = punti_vita
	oggetto.attacco = 0
	oggetto.difesa = 0
	oggetto.velocita = 0
	oggetto.xp = 0
	oggetto.tazo = 0
	aggiorna_scheda(oggetto)

func attiva_bersaglio_extra() -> void:
	var dati_frenesia: Dictionary = portatore_frenesia.get("frenesia", {})
	var id_bersaglio: String = dati_frenesia.get("bersaglio_extra", "")
	if id_bersaglio == "":
		return
	if id_bersaglio in leve_bersaglio_comparse:
		return   # e' gia' in campo: l'ha fatto comparire lo studio, prima
	leve_bersaglio_comparse.append(id_bersaglio)
	crea_oggetto_scena(id_bersaglio, int(dati_frenesia.get("bersaglio_extra_hp", 2)))

# --- abilita' di combattimento ---
#
# Le abilita' non stanno nel codice: stanno in regole.json, e una classe le
# prende scrivendone l'id nel suo campo "abilita". Qui si sa solo come si
# comportano i quattro TIPI che il motore conosce - provoca, area, raffica,
# carica - e aggiungere "Fiammata dei Tre Cancelli" non richiede di toccare
# questo file, solo di dire di che tipo e' e quanto costa.

func usa_abilita(chi: Dictionary, id_abilita: String) -> void:
	var dati := GameState.abilita_combattimento(id_abilita)
	if dati.is_empty():
		return
	if not paga_il_dominio(chi, dati):
		return
	spendi_aura(chi, int(dati.get("aura", 0)))
	match String(dati.get("tipo", "")):
		"provoca": provoca(chi)
		"area": attacco_area(chi, dati)
		"raffica": raffica(chi, dati)
		"carica": carica(chi, dati)
		"astio": astio(chi, dati)
		"mantra": mantra(chi, dati)
		"flagello": flagello(chi, dati)

func usa_abilita_su(chi: Dictionary, id_abilita: String, bersaglio: Dictionary) -> void:
	# le abilita' che chiedono un bersaglio passano di qui: il menu le fa
	# scegliere come un attacco normale
	var dati := GameState.abilita_combattimento(id_abilita)
	if dati.is_empty() or bersaglio.is_empty():
		return
	if not paga_il_dominio(chi, dati):
		return
	spendi_aura(chi, int(dati.get("aura", 0)))
	match String(dati.get("tipo", "")):
		"vendetta": vendetta(chi, bersaglio, dati)
		"annichilazione": annichilazione(chi, bersaglio, dati)
		"pieta": pieta(chi, bersaglio, dati)

func colpo_darma(chi: Dictionary, bersaglio: Dictionary, attacco: Dictionary) -> void:
	# IL DANNO DI UN ATTACCO D'ARMA, come l'ha descritto Bru: l'attacco base del
	# personaggio piu' il bonus che l'arma da' a quell'attacco. Non un
	# moltiplicatore: una somma, perche' cosi' un'arma resta leggibile - "+4" e'
	# +4, e non cambia significato salendo di livello.
	if attacco.is_empty():
		attacca(chi, bersaglio, -1, consuma_carica(chi))
		return
	spendi_aura(chi, int(attacco.get("aura", 0)))
	var testo := String(attacco.get("testo", ""))
	if testo != "":
		scrivi(testo % chi.nome)
	attacca(chi, bersaglio, -1, consuma_carica(chi), String(attacco.get("elemento", "")),
			int(attacco.get("bonus", 0)))

func paga_il_dominio(chi: Dictionary, dati: Dictionary) -> bool:
	# Un'abilita' che costa barra non parte se la barra non c'e'. E deve DIRLO:
	# un bottone che si preme e non succede niente si legge come rotto
	var segmenti := float(dati.get("dominio", 0.0))
	if segmenti <= 0.0:
		return true
	if not RegoleCombattimento.spendi_dominio(chi, segmenti):
		scrivi("[i]%s non ha abbastanza dominio: servono %.1f barre.[/i]" % [chi.nome, segmenti])
		return false
	return true

func categoria_del_combattente(chi: Dictionary) -> String:
	# categoria_di legge il record di personaggi.json, non la scheda in campo
	return RegoleCombattimento.categoria_di(GameState.personaggi.get(String(chi.get("id", "")), {}))

func abilita_vuole_bersaglio(id_abilita: String) -> bool:
	return String(GameState.abilita_combattimento(id_abilita).get("tipo", "")) \
			in ["vendetta", "annichilazione", "pieta"]

# --- Astio: piu' ti fanno male, piu' fai male -------------------------------

func astio(chi: Dictionary, dati: Dictionary) -> void:
	# Non e' un buff che sale e basta: sale SE incassi. Chi la usa e poi para
	# per tre turni non ha guadagnato niente, e questo e' il punto - e' un patto
	# con chi ti sta picchiando, non uno scudo.
	chi.astio_turni = int(dati.get("turni", 3))
	chi.astio_frazione = float(dati.get("frazione_attacco", 0.12))
	chi.astio_testo = String(dati.get("testo_accumulo", "L'astio di %s cresce: attacco +%d."))
	scrivi(String(dati.get("testo_uso", "[i]%s si incattivisce.[/i]")) % chi.nome)

func alimenta_astio(chi: Dictionary) -> void:
	# chiamata quando chi ha l'astio addosso incassa un colpo
	if int(chi.get("astio_turni", 0)) <= 0:
		return
	var quanto := maxi(int(round(RegoleCombattimento.attacco_di(chi)
			* float(chi.get("astio_frazione", 0.12)))), 1)
	chi.attacco = int(chi.attacco) + quanto
	scrivi(String(chi.get("astio_testo", "L'astio di %s cresce: attacco +%d.")) % [chi.nome, quanto])

func scala_astio(chi: Dictionary) -> void:
	if int(chi.get("astio_turni", 0)) <= 0:
		return
	chi.astio_turni = int(chi.astio_turni) - 1
	if int(chi.astio_turni) <= 0:
		scrivi("[i]L'astio di %s si spegne. Resta quello che ha guadagnato.[/i]" % chi.nome)

# --- Vendetta: quanto sei ridotto male ---------------------------------------

func vendetta(chi: Dictionary, bersaglio: Dictionary, dati: Dictionary) -> void:
	var pieno := float(dati.get("moltiplicatore_pieno", 0.8))
	var vuoto := float(dati.get("moltiplicatore_vuoto", 3.0))
	var quota := float(chi.hp) / maxf(float(chi.get("hp_max", 1)), 1.0)
	var moltiplicatore := pieno + (vuoto - pieno) * (1.0 - clampf(quota, 0.0, 1.0))
	scrivi(String(dati.get("testo_uso", "[i]%s si scaglia su %s.[/i]")) % [chi.nome, bersaglio.nome])
	attacca(chi, bersaglio, -1, moltiplicatore, String(dati.get("elemento", "")))

# --- Annichilazione: il vuoto attorno a chi e' gia' a terra ------------------

func annichilazione(chi: Dictionary, bersaglio: Dictionary, dati: Dictionary) -> void:
	# Fa MENO danno di un colpo normale, sempre. Quello che compra e' un'altra
	# cosa: se il bersaglio e' gia' sotto la soglia, meta' delle volte (e con i
	# gradi alti quasi due su tre) non si rialza affatto.
	scrivi(String(dati.get("testo_uso", "[i]Attorno a %s l'aria si chiude.[/i]")) % bersaglio.nome)
	var quota := float(bersaglio.hp) / maxf(float(bersaglio.get("hp_max", 1)), 1.0)
	var basso := quota <= float(dati.get("soglia_hp", 0.25))
	if basso and not bersaglio.get("invincibile", false) \
			and GameState.rng.randf() < float(dati.get("probabilita_ko", 0.5)):
		ultima_azione_offensiva = true
		if chi.giocatore and chi.id == GameState.id_protagonista:
			GameState.registra_azione("attacchi_sferrati")
		bersaglio.hp = 0
		scrivi_forte(String(dati.get("testo_ko", "[b]Dove c'era %s non c'è più niente.[/b]")) % bersaglio.nome)
		_su_ko(bersaglio)
		return
	attacca(chi, bersaglio, -1, float(dati.get("frazione_danno", 0.75)),
			String(dati.get("elemento", "")))

# --- Pieta': non e' misericordia -------------------------------------------

func pieta(chi: Dictionary, bersaglio: Dictionary, dati: Dictionary) -> void:
	# Costa il turno e non fa danno. Bru: non e' una morale, e' che a un
	# moribondo si cava di piu'.
	var quota := float(bersaglio.hp) / maxf(float(bersaglio.get("hp_max", 1)), 1.0)
	if quota > float(dati.get("soglia_hp", 0.3)):
		scrivi(String(dati.get("testo_inutile", "[i]%s è ancora troppo in piedi.[/i]")) % bersaglio.nome)
		return
	bersaglio.bonus_drop = float(bersaglio.get("bonus_drop", 0.0)) + float(dati.get("bonus_drop", 0.35))
	scrivi(String(dati.get("testo_uso", "[i]%s si ferma un attimo.[/i]")) % chi.nome)

# --- Mantra: si svuota la barra di dominio e si spende su di se' ------------

func mantra(chi: Dictionary, dati: Dictionary) -> void:
	# La barra di dominio non e' un contatore morale ed e' uno sfogo: qui lo
	# sfogo lo tieni dentro invece di scaricarlo addosso a qualcuno, e ti
	# torna in difesa, attacco e testa a posto. Quanto? Quanto era piena.
	var quanta := int(chi.get("fattore", 0))
	if quanta <= 0:
		scrivi(String(dati.get("testo_niente", "[i]%s non ha niente da bruciare.[/i]")) % chi.nome)
		return
	chi.fattore = 0
	var difesa := maxi(int(round(quanta * float(dati.get("difesa_per_dominio", 0.35)))), 1)
	var attacco := maxi(int(round(quanta * float(dati.get("attacco_per_dominio", 0.20)))), 1)
	chi.difesa = int(chi.difesa) + difesa
	chi.attacco = int(chi.attacco) + attacco
	scrivi(String(dati.get("testo_uso", "[i]%s si ferma e respira.[/i]")) % chi.nome)
	scrivi("Difesa +%d, attacco +%d." % [difesa, attacco])
	if chi.giocatore:
		var sollievo := int(round(quanta * float(dati.get("stress_per_dominio", 0.40))))
		if sollievo > 0:
			GameState.modifica_stress(String(chi.id), -sollievo)
			scrivi("Lo stress di %s cala di %d." % [chi.nome, sollievo])
	var legame := int(dati.get("legame", 0))
	if legame > 0 and chi.giocatore:
		GameState.modifica_legame(legame)
		scrivi("[i]Chi gli sta intorno respira con lui.[/i]")
	if bool(dati.get("provoca", false)):
		provoca(chi)
	var immune := int(dati.get("turni_immune", 0))
	if immune > 0:
		chi.turni_immune = maxi(int(chi.get("turni_immune", 0)), immune)
		scrivi("[i]Per un momento non c'è niente che possa toccarlo.[/i]")
	var veloce := int(dati.get("velocita", 0))
	if veloce > 0:
		chi.velocita = int(chi.velocita) + veloce
	if bool(dati.get("cura_stati", false)):
		var incurabili: Array = dati.get("stati_incurabili", [])
		var tolti: Array[String] = []
		for id_stato in chi.get("stati_attivi", {}).keys():
			if String(id_stato) in incurabili:
				continue
			tolti.append(String(id_stato))
		for id_stato in tolti:
			chi.stati_attivi.erase(id_stato)
		if not tolti.is_empty():
			scrivi("[i]Tutto quello che gli avevano messo addosso scivola via.[/i]")

# --- Flagello: una pioggia di aghi, e cosa diventa ---------------------------

func flagello(chi: Dictionary, dati: Dictionary) -> void:
	# La linea intera passa di qui: cambiano solo i numeri che legge nei dati.
	# Il totale e' il danno di UN attacco normale, spezzato in venti o
	# venticinque colpi - non venti attacchi normali. Da Terra bruciata in poi
	# il totale cresce con quanto e' piena la barra di dominio, e dal grado
	# Maelstrom in poi anche di suo.
	var nemici := vivi(false)
	if nemici.is_empty():
		return
	var colpi := maxi(int(dati.get("colpi", 20)), 1)
	var totale_previsto := float(RegoleCombattimento.attacco_di(chi))
	totale_previsto *= 1.0 + float(dati.get("bonus_attacco", 0.0))
	var pieno := float(chi.get("fattore", 0)) / 100.0
	totale_previsto *= 1.0 + float(dati.get("bonus_dominio", 0.0)) * clampf(pieno, 0.0, 1.0)
	var danno_colpo := maxi(int(round(totale_previsto / float(colpi))), 1)
	scrivi(String(dati.get("testo_uso", "[i]Il buio si chiude su %s.[/i]"))
			% (nemici[0].nome if nemici.size() == 1 else "loro"))
	ultima_azione_offensiva = true
	if chi.giocatore and chi.id == GameState.id_protagonista:
		GameState.registra_azione("attacchi_sferrati")
	var elenco: Array = []
	var totale := 0
	var falliti := 0
	var critici := 0
	var prob_fallimento := float(GameState.regole.get("flagello_probabilita_fallimento", 0.12))
	var prob_terrore := float(dati.get("probabilita_terrore", 0.0))
	for colpo in colpi:
		var in_piedi := vivi(false)
		if in_piedi.is_empty():
			break
		var bersaglio: Dictionary = in_piedi[GameState.rng.randi_range(0, in_piedi.size() - 1)]
		# ogni ago per conto suo: puo' andare a vuoto o entrare male. Il critico
		# si chiede alla stessa funzione del resto del gioco, non a una regola
		# scritta qui: se un giorno lo stress smette di far male, smette di far
		# male anche qui, senza che nessuno se ne debba ricordare
		if GameState.rng.randf() < prob_fallimento:
			falliti += 1
			continue
		var quanto := danno_colpo
		if RegoleCombattimento.tenta_critico(bersaglio):
			quanto = int(round(quanto * float(GameState.regole.get("critico_moltiplicatore", 1.5))))
			critici += 1
		var passato := mini(quanto, int(bersaglio.hp))
		bersaglio.hp = maxi(int(bersaglio.hp) - quanto, 0)
		registra_danno_subito(bersaglio, passato)
		totale += passato
		elenco.append({"scheda": bersaglio.scheda, "danno": passato})
		# il terrore non attecchisce su chi comanda la stanza
		if prob_terrore > 0.0 and bersaglio.hp > 0 \
				and not categoria_del_combattente(bersaglio) in ["boss", "miniboss"] \
				and GameState.rng.randf() < prob_terrore:
			applica_stato(bersaglio, "terrore")
		if bersaglio.hp <= 0:
			_su_ko(bersaglio)
	var coda := ""
	if critici > 0:
		coda += "  %d a segno in pieno." % critici
	if falliti > 0:
		coda += "  %d a vuoto." % falliti
	scrivi_forte("[b]%s: %d colpi.[/b] In tutto, %d danni.%s" % [
			String(dati.get("nome", "Flagello")), colpi - falliti, totale, coda])
	var bonus := int(dati.get("bonus_statistiche", 0))
	if bonus > 0:
		for chiave in ["attacco", "difesa", "velocita"]:
			chi[chiave] = int(chi.get(chiave, 0)) + bonus
		chi.hp_max = int(chi.get("hp_max", 1)) + bonus
		chi.hp = int(chi.hp) + bonus
		scrivi(String(dati.get("testo_statistiche",
				"Tutte le statistiche di %s salgono di %d.")) % [chi.nome, bonus])
	voce.accoda_effetto(effetto_raffica(elenco, String(dati.get("elemento", ""))))

func provoca(chi: Dictionary) -> void:
	bersaglio_provocazione = chi
	turni_provocazione = int(GameState.regole.get("forza_azione_durata", 2))
	scrivi("[i]%s si mette in mostra: i nemici non vedono altro che lui.[/i]" % chi.nome)

func attacco_area(chi: Dictionary, dati: Dictionary = {}) -> void:
	scrivi("[i]%s scatena un colpo che si abbatte su tutti i nemici![/i]" % chi.nome)
	var frazione := float(dati.get("moltiplicatore",
			GameState.regole.get("moltiplicatore_attacco_area", 0.6)))
	var valore := int(round(RegoleCombattimento.attacco_di(chi) * frazione))
	for nemico in vivi(false):
		attacca(chi, nemico, valore, 1.0, String(dati.get("elemento", "")))

func raffica(chi: Dictionary, dati: Dictionary) -> void:
	# Tanti colpi piccoli invece di uno grosso. Il danno totale e' paragonabile a
	# quello di un colpo caricato, ma quello che si VEDE e' diverso: una scarica
	# di numeri addosso a tutto quello che hai davanti. E' il punto dell'abilita' -
	# un bombardamento deve sembrare un bombardamento.
	#
	# Il numero di colpi cresce col livello: al primo sono una dozzina, a fine
	# gioco sono cinquanta. Il danno del singolo colpo resta piccolo apposta.
	var nemici := vivi(false)
	if nemici.is_empty():
		return
	var livello := GameState.livello_di(String(chi.id)) if chi.giocatore else 1
	var colpi := mini(
			int(dati.get("colpi", 10)) + floori((livello - 1) * float(dati.get("colpi_per_livello", 0.0))),
			int(dati.get("colpi_massimi", 99)))
	var danno_colpo := maxi(int(round(RegoleCombattimento.attacco_di(chi)
			* float(dati.get("frazione_danno", 0.25)))), 1)
	ultima_azione_offensiva = true
	if chi.giocatore and chi.id == GameState.id_protagonista:
		GameState.registra_azione("attacchi_sferrati")
	var elenco: Array = []
	var totale := 0
	for colpo in colpi:
		var in_piedi := vivi(false)
		if in_piedi.is_empty():
			break
		var bersaglio: Dictionary = in_piedi[GameState.rng.randi_range(0, in_piedi.size() - 1)]
		# la raffica passa le difese: sono schegge, non un fendente da parare
		var passato := mini(danno_colpo, int(bersaglio.hp))
		bersaglio.hp = maxi(int(bersaglio.hp) - danno_colpo, 0)
		registra_danno_subito(bersaglio, passato)
		totale += passato
		elenco.append({"scheda": bersaglio.scheda, "danno": passato})
		if bersaglio.hp <= 0:
			_su_ko(bersaglio)
	scrivi_forte("[b]%s: %d colpi.[/b] In tutto, %d danni." % [
			String(dati.get("nome", "Raffica")), colpi, totale])
	voce.accoda_effetto(effetto_raffica(elenco, String(dati.get("elemento", ""))))

func effetto_raffica(colpi: Array, elemento := "") -> Callable:
	# Venti messaggi in coda sarebbero venti attese, e il "casino" si perderebbe
	# nell'attesa. Cosi' invece parte tutto da un effetto solo: i numeri si
	# accendono uno dietro l'altro, in fretta, come una scarica - e sbandano di
	# lato a turno, o venti numeri sulla stessa verticale sarebbero una colonna
	# illeggibile invece di un macello.
	var tinta := Stile.colore_danno(elemento)
	return func() -> void:
		for combattente in combattenti:
			aggiorna_scheda(combattente)
		if muto or colpi.is_empty():
			return
		voce.suono("colpo")
		for indice in colpi.size():
			var colpo: Dictionary = colpi[indice]
			var scheda: Control = colpo["scheda"]
			var quanto := int(colpo["danno"])
			var lato := (-1.0 if indice % 2 == 0 else 1.0) * (12.0 + (indice % 5) * 9.0)
			var mostra := func() -> void:
				if not is_instance_valid(scheda):
					return
				voce.numero_volante(scheda, "−%d" % quanto, tinta, false, lato)
				voce.lampeggia(scheda, tinta)
			if indice == 0:
				mostra.call()
			else:
				get_tree().create_timer(indice * PASSO_RAFFICA, false).timeout.connect(mostra)

func carica(chi: Dictionary, dati: Dictionary) -> void:
	# Un turno buttato via per farne valere quattro. E' una scommessa: mentre
	# carichi incassi, e se cadi prima di scaricare non hai fatto niente.
	chi.carica_pronta = float(dati.get("moltiplicatore", 3.0))
	var testo := String(dati.get("testo_carica", "%s si carica."))
	scrivi_forte("[i]%s[/i]" % (testo % chi.nome))
	aggiorna_scheda(chi)

func consuma_carica(chi: Dictionary) -> float:
	# quanto vale questo colpo. Si spende sul primo attacco vero: non su un'area,
	# non su una raffica - quelli hanno gia' il loro modo di essere grossi
	var moltiplicatore_carica := float(chi.get("carica_pronta", 0.0))
	if moltiplicatore_carica <= 0.0:
		return 1.0
	chi.carica_pronta = 0.0
	scrivi("[b]%s scarica tutto quello che ha accumulato.[/b]" % chi.nome)
	return moltiplicatore_carica

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
	scrivi_forte("[i]%s fugge dal combattimento.[/i]" % chi.nome)
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
		if RegoleCombattimento.ha_stato_attivo(personaggio, "terrore"):
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

func corazza_che_cresce(nemico: Dictionary) -> void:
	# Una creatura puo' irrobustirsi a ogni suo turno, e non tornare piu'
	# indietro: "difesa_per_turno" nel suo file. Non e' un buff a scadenza, e'
	# la sua difesa base che sale e resta.
	#
	# E' la Tartaruga Innocente: si chiude nel guscio, e ogni volta si chiude un
	# po' di piu'. Prima o poi la sua corazza supera il tuo colpo e da li' in poi
	# le fai 1 (vedi RegoleCombattimento.calcola_danno); con la vita che ha, a
	# mani nude non la abbatti in nessun modo. Non e' un muro ingiusto: e' il
	# gioco che dice, con i numeri invece che con una riga di testo, che quella
	# creatura non va picchiata - va capita.
	var passo := int(GameState.personaggi.get(nemico.id, {}).get("difesa_per_turno", 0))
	if passo <= 0 or nemico.hp <= 0:
		return
	nemico.difesa = int(nemico.difesa) + passo
	var testo := String(GameState.personaggi.get(nemico.id, {}).get("testo_corazza",
			"%s si chiude ancora un po'. La sua corazza è più spessa di prima."))
	scrivi("[i]%s[/i]" % (testo % nemico.nome))
	aggiorna_scheda(nemico)

func turno_nemico(nemico: Dictionary) -> void:
	corazza_che_cresce(nemico)
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

func esegui_turno_inerte(_nemico: Dictionary, dati_incontro: Dictionary) -> void:
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
	var protagonisti_vivi := vivi(true)
	if protagonisti_vivi.is_empty():
		return
	var bersaglio: Dictionary = protagonisti_vivi[0]
	var nome_protagonista: String = String(bersaglio.nome)
	if incontro_tentativi_morfeo > 1:
		# la scena e' un ricordo che affiora mentre stai per addormentarti: una
		# volta che non puoi piu' dormire non puo' ripetersi. Ci riprova, non le
		# riesce, e a quel punto si sfalda
		scrivi("[i]%s[/i]" % String(dati_incontro.get("testo_morfeo_fallito", "")))
		esegui_vortice_di_rabbia(dati_incontro)
		return
	scrivi("[i]%s[/i]" % String(dati_incontro.get("testo_fatale_manifestazione", "")))
	# la scena si vede sempre per intero, fino al bacio: e' solo dopo che il
	# destino si divide, a seconda che qualcosa ti protegga dal sonno o no
	scrivi_forte(String(dati_incontro.get("testo_fatale_protagonista", "")), "dialogo", nome_protagonista)
	scrivi_forte("[i]%s[/i]" % String(dati_incontro.get("testo_fatale_bacio", "")))
	var scudo_prima := String(bersaglio.get("scudo_stato", "")) != ""
	applica_stato(bersaglio, "sonno")
	if RegoleCombattimento.ha_stato_attivo(bersaglio, "sonno"):
		# niente ha fermato il sonno: game over
		sconfitta_scriptata()
		return
	# respinto: o lo scudo l'ha appena consumato adesso, o l'immunita' era
	# gia' attiva da un tentativo precedente
	if scudo_prima and String(bersaglio.get("scudo_stato", "")) == "":
		scrivi_forte("[i]%s[/i]" % String(dati_incontro.get("testo_scudo_rotto", "")))
	else:
		# immune per altre ragioni: il sonno non attecchisce e basta
		scrivi("[i]%s[/i]" % String(dati_incontro.get("testo_morfeo_fallito", "")))

func esegui_vortice_di_rabbia(dati_incontro: Dictionary) -> void:
	# secondo tentativo respinto: si dissolve in un vortice di rabbia - una
	# vittoria alternativa, mai raggiunta a forza di colpi
	scrivi_forte(String(dati_incontro.get("testo_vortice_rabbia", "")))
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
	# Il colpo che chiude una scena scritta: l'epilogo letale di un incontro
	# scriptato (l'incubo, la Chiamata di Morfeo) o la fine dell'allenamento con
	# Veronica. Instradato sempre come una sconfitta qualunque (se_perdi).
	#
	# I punti vita vanno a zero SUBITO - il motore deve sapere com'e' finita -
	# ma il ritratto si spegne quando la coda arriva fin qui, non un istante
	# prima. Senza questa distinzione succedeva una cosa precisa e sbagliata:
	# nell'allenamento tiri la bomba a Veronica, e il tuo ritratto diventa KO
	# all'istante, SETTE messaggi prima che il box racconti la Meteora di
	# Atlante che ti mette davvero a terra. Il giocatore legge il nesso di causa
	# che ha davanti agli occhi - "ho tirato la bomba e sono morto io" - e ha
	# ragione a leggerlo, perche' e' quello che lo schermo gli sta mostrando.
	#
	# E' la stessa regola di effetto_colpo(): i numeri cambiano quando devono,
	# quello che si vede cambia quando lo si racconta.
	var vittime := vivi(true)
	for vittima in vittime:
		vittima.hp = 0
	for vittima in vittime:
		var caduta := vittima
		voce.accoda_effetto(func() -> void: aggiorna_scheda(caduta))
	if not vittime.is_empty():
		_su_ko(vittime[0])

func gestisci_turno_frenesia(nemico: Dictionary) -> void:
	var dati_frenesia: Dictionary = portatore_frenesia.get("frenesia", {})
	if turni_afflitto > 0:
		var linee: Array = dati_frenesia.get("testo_fermata", [])
		var indice: int = linee.size() - turni_afflitto
		if indice >= 0 and indice < linee.size():
			scrivi_forte(String(linee[indice]), "dialogo", String(nemico.nome))
		turni_afflitto -= 1
		return
	if not frenesia_attiva:
		turno_nemico_normale(nemico)
		return
	conteggio_frenesia -= 1
	if conteggio_frenesia <= 0:
		scrivi_forte(String(dati_frenesia.get("testo_maleficio", "Il maleficio si abbatte su di voi.")))
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
	if not mossa_eseguibile(nemico, dati):
		return false  # la aspetta: la soglia non si consuma per una mossa che non parte
	nemico.soglia_gia_scattata = true
	esegui_mossa(nemico, dati)
	return true

func verifica_dialogo_soglia(bersaglio: Dictionary) -> void:
	var dati: Dictionary = GameState.personaggi.get(bersaglio.id, {}).get("dialogo_soglia_hp", {})
	if dati.is_empty() or bersaglio.hp <= 0 or soglie_dialogo_mostrate.get(bersaglio.indice, false):
		return
	if bersaglio.hp <= int(dati.get("hp_soglia", 0)):
		soglie_dialogo_mostrate[bersaglio.indice] = true
		scrivi_forte(String(dati.get("testo", "")))
		if dati.has("danno_fisso_dopo"):
			# da qui in poi i suoi colpi passano sempre, sempre uguali: la
			# guardia non serve piu' a niente. Al giocatore non si dice: se ne
			# accorge dai numeri, ed e' proprio quello il senso di "preparati"
			bersaglio["danno_fisso_attacco"] = int(dati["danno_fisso_dopo"])

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
	# Se quello che alimentava la frenesia e' gia' stato distrutto, la frenesia
	# non parte proprio. Altrimenti chi scopre le lettere studiando e le
	# distrugge subito si ritroverebbe punito: al conto alla rovescia non
	# resterebbe piu' niente da colpire per fermarlo.
	var id_ancora := String(dati_frenesia.get("bersaglio_extra", ""))
	if id_ancora != "" and id_ancora in leve_bersaglio_riscosse:
		frenesia_gia_innescata = true
		return
	var soglia := float(dati_frenesia.get("soglia_hp", 0.5))
	if float(bersaglio.hp) / float(bersaglio.hp_max) <= soglia:
		frenesia_attiva = true
		frenesia_gia_innescata = true
		conteggio_frenesia = int(dati_frenesia.get("conteggio", 3))
		scrivi_forte(String(dati_frenesia.get("testo_inizio", "Qualcosa cambia.")))

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

func verifica_cura_su_morte(caduto: Dictionary) -> void:
	# certi padroni si nutrono dei propri sottoposti: ogni evocazione che cade
	# li rimette in sesto (Jongo Dongo e i suoi ghoul)
	for nemico in vivi(false):
		var dati: Dictionary = GameState.personaggi.get(nemico.id, {}).get("cura_su_morte_alleato", {})
		if dati.is_empty() or caduto.id != String(dati.get("id_alleato", "")):
			continue
		var cura := mini(int(dati.get("valore", 0)), int(nemico.hp_max) - int(nemico.hp))
		if cura <= 0:
			continue
		nemico.hp += cura
		aggiorna_scheda(nemico)
		scrivi("[i]%s[/i]" % String(dati.get("testo", "Si rimette in sesto.")).replace("%d", str(cura)))

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
		scrivi_forte(String(dati.get("testo_inizio", "")))
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
		scrivi_forte(String(dati.get("testo_gamba_si_rompe", "Una gamba cede sotto il suo stesso peso.")))
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
		if mossa_eseguibile(nemico, mossa_pronta):
			esegui_mossa(nemico, mossa_pronta)
		else:
			# annunciata quando si poteva, impossibile adesso: niente scena
			# inventata, tira un colpo e basta
			attacca(nemico, bersaglio_giocatore_casuale())
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
		if not mossa_eseguibile(nemico, mossa):
			continue
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
					scrivi_forte(String(mossa.get("testo_annuncio", "Qualcosa si sta caricando...")))
				else:
					esegui_mossa(nemico, mossa)
				return
	attacca(nemico, bersaglio_giocatore_casuale())

func apri_la_guardia(vittima: Dictionary, mossa: Dictionary) -> void:
	# CERTI COLPI LA GUARDIA TE LA APRONO. Serve perche' la guardia adesso resta
	# fino a fine scontro: senza qualcosa che la faccia scendere, chiudersi
	# sarebbe una strada senza rischio, e una strada senza rischio non e' una
	# scelta - e' l'unica cosa sensata da fare.
	var quanti := int(mossa.get("abbassa_difesa", 0))
	if quanti <= 0 or vittima.is_empty() or int(vittima.hp) <= 0:
		return
	var perso := RegoleCombattimento.abbassa_guardia(vittima, quanti)
	scrivi(String(mossa.get("testo_guardia", "[i]La guardia di %s si apre.[/i]")) % vittima.nome)
	if perso > 0:
		scrivi("Difesa −%d, ora %d." % [perso, RegoleCombattimento.difesa_di(vittima)])

func mossa_eseguibile(nemico: Dictionary, mossa: Dictionary) -> bool:
	# Se una mossa non puo' fare quello che dice, non deve partire: meglio un
	# colpo normale che una scena che smentisce sé stessa.
	#
	# Un solo posto che lo decide, perche' i modi di arrivare a una mossa sono
	# quattro (sorteggio pesato, soglia di vita, disperazione, mossa annunciata
	# il turno prima) e finche' il controllo stava solo dentro il sorteggio gli
	# altri tre lo scavalcavano.
	if String(mossa.get("tipo", "")) == "sacrificio":
		return not vivi_alleati_di(nemico).is_empty()
	return true

func esegui_mossa(nemico: Dictionary, mossa: Dictionary) -> void:
	scrivi("[i]%s[/i]" % mossa.get("testo", ""))
	if mossa.get("una_tantum", false):
		nemico.mosse_usate.append(String(mossa.get("id", "")))
	match mossa.get("tipo", ""):
		"difendi":
			difendi(nemico)
		"attacco_forte":
			var vittima_forte := bersaglio_giocatore_casuale()
			attacca(nemico, vittima_forte, int(mossa.get("valore", nemico.attacco)),
					1.0, String(mossa.get("elemento", "")))
			if mossa.has("stato") and not vittima_forte.is_empty() and vittima_forte.hp > 0:
				applica_stato(vittima_forte, String(mossa["stato"]))
			apri_la_guardia(vittima_forte, mossa)
		"spezza_guardia":
			# un colpo che non fa piu' male degli altri, ma ti apre: e' la
			# risposta del gioco a chi si chiude e non si muove piu'
			var vittima_guardia := bersaglio_giocatore_casuale()
			attacca(nemico, vittima_guardia, int(mossa.get("valore", -1)),
					1.0, String(mossa.get("elemento", "")))
			apri_la_guardia(vittima_guardia, mossa)
		"meta_vita":
			# toglie sempre meta' dei punti vita attuali del bersaglio, ignorando
			# difese e livello; sotto una soglia minima e' invece un KO secco
			var vittima := bersaglio_giocatore_casuale()
			if not vittima.is_empty():
				var soglia_ko := int(mossa.get("hp_soglia_ko", 5))
				if vittima.hp < soglia_ko:
					scrivi_forte("%s non regge il colpo." % vittima.nome)
					vittima.hp = 0
				else:
					var meta := int(floor(float(vittima.hp) / 2.0))
					vittima.hp = maxi(vittima.hp - meta, 1)
					voce.accoda_effetto(effetto_colpo(vittima, meta))
				aggiorna_scheda(vittima)
				if vittima.hp <= 0:
					_su_ko(vittima)
		"attacco_multiplo":
			for volta in range(int(mossa.get("colpi", 2))):
				if vivi(true).is_empty():
					break
				attacca(nemico, bersaglio_giocatore_casuale(), int(mossa.get("valore", nemico.attacco)),
						1.0, String(mossa.get("elemento", "")))
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
				attacca(nemico, bersaglio, int(mossa.get("valore", 1)),
						1.0, String(mossa.get("elemento", "")))
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
			var male := int(mossa.get("valore", 1))
			nemico.hp = maxi(nemico.hp - male, 0)
			voce.accoda_effetto(effetto_colpo(nemico, male))
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
			# uccidendo un suo stesso alleato evocato.
			#
			# Se non ne ha, NON LA FA. Qui c'era un ripiego - "non ha nessuno da
			# sacrificare, colpisce lui stesso" - che raccontava una scena che
			# non doveva esistere: uno che annuncia un rito e poi tira un pugno.
			# Adesso e' esegui_turno a non sceglierla mai senza alleati (vedi
			# turno_nemico_normale e mossa_eseguibile), e questo ramo non puo'
			# piu' essere raggiunto a mani vuote.
			var alleati := vivi_alleati_di(nemico)
			if alleati.is_empty():
				return
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
		scrivi_forte(String(comb.get("testo_innesco", "Qualcosa in lui prende fuoco.")))

func applica_combustione(combattente: Dictionary) -> void:
	var comb: Dictionary = combattente.combustione
	var danno := int(comb.get("danno_per_turno", 1))
	combattente.hp = maxi(combattente.hp - danno, 0)
	if comb.has("bonus_attacco"):
		combattente.attacco += int(comb["bonus_attacco"])
	scrivi_con_colpo("[i]%s[/i]" % String(comb.get("testo_turno", "Brucia ancora un po'.")),
			combattente, danno, String(comb.get("elemento", "fuoco")))
	if combattente.hp <= 0:
		_su_ko(combattente)

# --- stati generici (data/stati.json): veleno, congelamento, sonno,
# egocentrismo, demotivazione (contagiosa), berserk, confusione, rapidita'/
# lentezza, maledizione. Ogni personaggio puo' dichiarare nei dati una chiave
# "resistenze" (es. {"stress": "invertito", "oscuro": "ipersensibile"}):
# "immune" annulla lo stato, "ipersensibile" lo amplifica, "invertito" (solo
# per stress) ne capovolge l'effetto. Assente = "normale".

func applica_stato(bersaglio: Dictionary, id_stato: String, valore := 1) -> void:
	var resistenza := RegoleCombattimento.resistenza_di(bersaglio, id_stato)
	if resistenza == "immune":
		return
	if bersaglio.giocatore and String(bersaglio.get("scudo_stato", "")) != "":
		# l'accessorio addosso a QUESTO personaggio respinge il primo stato che
		# subisce, e lo immunizza da quello stesso stato per il resto dello
		# scontro; si consuma qui, una volta sola, e protegge solo lui
		var id_scudo := String(bersaglio.scudo_stato)
		bersaglio.scudo_stato = ""
		bersaglio.immunita_temporanea.append(id_stato)
		var nome_accessorio := String(GameState.dati_oggetto(id_scudo).get("nome", "Il tuo accessorio"))
		var nome_stato := String(GameState.stati.get(id_stato, {}).get("nome", id_stato))
		scrivi_forte("%s si spezza respingendo %s: per il resto dello scontro %s ne sarà immune."
				% [nome_accessorio, nome_stato, bersaglio.nome])
		GameState.consuma_equipaggiato(id_scudo)
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
				# chi porta addosso una resistenza alla maledizione parte con
				# qualche rintocco in piu': quando gli altri arrivano a zero lui
				# e' ancora a uno, e serve un colpo in piu' per portarlo via
				var iniziale := int(GameState.regole.get("maledizione_countdown_iniziale", 9)) \
						+ int(bersaglio.get("resistenza_maledizione", 0))
				bersaglio.stati_attivi[id_stato] = {"turni_rimasti": iniziale}
				scrivi_forte("%s %s" % [bersaglio.nome, String(info_stato.get("testo_applicazione", "viene colpito da una forza oscura."))])
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
					if altro.indice != bersaglio.indice and RegoleCombattimento.resistenza_di(altro, id_stato) != "immune":
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
			scrivi_forte("%s %s" % [bersaglio.nome, String(info_stato.get("testo_applicazione", "è paralizzato dal terrore."))])
	aggiorna_scheda(bersaglio)

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
					scrivi_forte("La maledizione si compie: %s non resiste oltre." % combattente.nome)
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
				if String(info_stato.get("tipo", "")) == "dot_crescente":
					attivo.danno = danno + 1
				scrivi_con_colpo("[i]%s: %s[/i]" % [combattente.nome,
						String(info_stato.get("testo_turno", "Il male si fa sentire ancora."))],
						combattente, danno, String(info_stato.get("elemento", "")))
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
		scrivi_con_colpo("[i]%s: %s[/i]" % [combattente.nome,
				String(info_stato.get("testo_turno", "Il male si fa sentire ancora."))],
				combattente, danno, String(info_stato.get("elemento", "")))
		if combattente.hp <= 0:
			_su_ko(combattente)
			return

# --- risoluzione dei colpi ---

func attacca(attaccante: Dictionary, bersaglio: Dictionary, valore_attacco := -1,
		moltiplicatore := 1.0, elemento := "", bonus := 0) -> void:
	ultima_azione_offensiva = true
	if elemento == "":
		elemento = elemento_di(attaccante)
	if attaccante.giocatore and attaccante.id == GameState.id_protagonista:
		GameState.registra_azione("attacchi_sferrati")
	if int(bersaglio.get("turni_immune", 0)) > 0:
		# Mantra IV in su: per un turno non lo scalfiscono. Il colpo si vede
		# arrivare e non arriva - e' l'unica cosa in tutto il gioco che annulla
		# un danno del tutto, quindi deve dirlo chiaramente
		scrivi("[i]Il colpo su %s si ferma a un dito dalla pelle.[/i]" % bersaglio.nome)
		return
	# chi ha superato la sua soglia colpisce sempre uguale: niente difesa,
	# niente critico, niente riduzione da livello. Nessun messaggio lo annuncia
	var fisso := int(attaccante.get("danno_fisso_attacco", 0))
	if fisso > 0:
		bersaglio.hp = maxi(bersaglio.hp - fisso, 0)
		registra_danno_subito(bersaglio, fisso)
		mostra_colpo(bersaglio, fisso, elemento)
		if not bersaglio.giocatore:
			verifica_innesco_frenesia(bersaglio)
			verifica_dialogo_soglia(bersaglio)
		if bersaglio.hp <= 0:
			_su_ko(bersaglio)
		elif bersaglio.giocatore:
			aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))
		return
	if tenta_slaughter(attaccante, bersaglio):
		return
	var dati_bersaglio: Dictionary = GameState.personaggi.get(bersaglio.id, {})
	if valore_attacco < 0 and dati_bersaglio.has("danno_fisso_su_attacco"):
		# alcuni nemici scriptati ignorano interamente difesa/critico/fattore:
		# ogni attacco vale sempre lo stesso, fisso, danno
		var danno_forzato := int(dati_bersaglio["danno_fisso_su_attacco"])
		bersaglio.hp = maxi(bersaglio.hp - danno_forzato, 0)
		mostra_colpo(bersaglio, danno_forzato, elemento)
		if not bersaglio.giocatore:
			verifica_innesco_frenesia(bersaglio)
			verifica_dialogo_soglia(bersaglio)
		if bersaglio.hp <= 0:
			_su_ko(bersaglio)
		elif bersaglio.giocatore:
			aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))
		return
	var esito := RegoleCombattimento.calcola_danno(attaccante, bersaglio, valore_attacco, moltiplicatore, bonus)
	var danno := int(esito.danno)
	var critico := bool(esito.critico)
	if esito.fattore:
		scrivi("Il dominio di %s arde!" % attaccante.nome)
	if danno <= 0:
		# questo invece va detto: un colpo che non passa e' un'informazione,
		# non un evento da guardare
		scrivi("%s para il colpo di %s." % [bersaglio.nome, attaccante.nome])
		if bersaglio.giocatore:
			aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))
		return
	bersaglio.hp = maxi(bersaglio.hp - danno, 0)
	registra_danno_subito(bersaglio, danno)
	if critico:
		if attaccante.giocatore and attaccante.id == GameState.id_protagonista:
			GameState.registra_azione("critici_inflitti")
		# un critico merita una parola: e' l'eccezione, non la regola
		scrivi("[b]Colpo critico![/b] %s coglie %s in pieno." % [attaccante.nome, bersaglio.nome])
	mostra_colpo(bersaglio, danno, elemento, critico)
	if not bersaglio.giocatore:
		verifica_innesco_frenesia(bersaglio)
		verifica_dialogo_soglia(bersaglio)
	if bersaglio.hp <= 0:
		_su_ko(bersaglio)
	elif bersaglio.giocatore:
		aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))

func tenta_slaughter(attaccante: Dictionary, bersaglio: Dictionary) -> bool:
	# probabilita' bassissima di KO istantaneo, anche su un attacco normale;
	# chi trae forza dallo stress (resistenza "invertita") o ne e' immune non puo' essere finito cosi'
	if not RegoleCombattimento.puo_subire_slaughter(bersaglio):
		return false
	if GameState.rng.randf() >= RegoleCombattimento.probabilita_slaughter(attaccante, bersaglio):
		return false
	scrivi_forte("[b]SLAUGHTER.[/b] %s colpisce %s una volta sola, e non si rialzerà." % [attaccante.nome, bersaglio.nome])
	bersaglio.hp = 0
	aggiorna_scheda(bersaglio)
	mostra_slaughter(bersaglio)  # animazione a parte: non blocca la risoluzione del colpo
	if not bersaglio.giocatore:
		verifica_innesco_frenesia(bersaglio)
	_su_ko(bersaglio)
	return true

func mostra_slaughter(_bersaglio: Dictionary) -> void:
	# overlay a schermo intero con l'illustrazione e la scritta "SLAUGHTER"
	# (art/fx/slaughter.png, ancora da disegnare): appare e sparisce in fade,
	# senza mettere in pausa il combattimento
	if muto:
		return
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

func verifica_ultima_risorsa(chi: Dictionary) -> void:
	# lo slot "Ultima risorsa" tiene un consumabile che non scegli di usare:
	# scatta da solo quando stai per cadere, una volta sola per scontro, e
	# rende piu' di quanto renderebbe usato a mano. E' una rete, e come tutte
	# le reti si strappa: l'oggetto viene consumato davvero
	if not chi.giocatore or bool(chi.get("ultima_risorsa_usata", false)):
		return
	if int(chi.hp) <= 0:
		return
	var soglia := float(GameState.regole.get("ultima_risorsa_soglia", 0.25))
	if float(chi.hp) > float(chi.hp_max) * soglia:
		return
	var id_oggetto := GameState.equipaggiato_in(String(chi.id), "ultima_risorsa")
	if id_oggetto == "" or id_oggetto not in GameState.sacca:
		return
	chi.ultima_risorsa_usata = true
	var dati := GameState.dati_oggetto(id_oggetto)
	var bonus := 1.0 + float(GameState.regole.get("ultima_risorsa_bonus", 0.2))
	scrivi_forte("Ultima risorsa: %s scatta da sola, e rende più del solito."
			% String(dati.get("nome", id_oggetto)), "notifica")
	GameState.consuma_equipaggiato(id_oggetto)
	applica_effetto(chi, dati.get("effetto", {}), bonus)

func registra_danno_subito(bersaglio: Dictionary, danno: int) -> void:
	# serve a chi si rigenera in proporzione ai colpi presi (vedi risolvi_rigenerazione)
	if danno > 0:
		bersaglio.ultimo_danno_subito = danno
		bersaglio.colpi_incassati = int(bersaglio.colpi_incassati) + 1
		if bersaglio.giocatore and bersaglio.id == GameState.id_protagonista:
			GameState.registra_azione("danni_subiti", danno)
		# l'Astio si alimenta qui, e solo qui: un colpo incassato e' un colpo
		# incassato, che arrivi da un attacco, da un veleno o da una raffica
		alimenta_astio(bersaglio)

func colpisci_diretto(bersaglio: Dictionary, danno: int, elemento := "") -> void:
	# oggetti e assist ignorano le difese
	bersaglio.hp = maxi(bersaglio.hp - danno, 0)
	registra_danno_subito(bersaglio, danno)
	mostra_colpo(bersaglio, danno, elemento)
	if bersaglio.hp <= 0:
		_su_ko(bersaglio)

func elemento_di(combattente: Dictionary) -> String:
	# Di che colore e' il colpo normale di questo combattente. Per una creatura
	# lo dice il suo file; per un membro del party lo dice l'arma che ha in mano
	# - cambiare arma cambia il colore dei numeri che fai, ed e' il modo piu'
	# diretto di far vedere che l'arma nuova e' un'altra cosa.
	if not combattente.giocatore:
		return String(GameState.personaggi.get(combattente.id, {}).get("elemento", ""))
	var id_arma := GameState.equipaggiato_in(String(combattente.id), "arma")
	if id_arma == "":
		return ""
	return String(GameState.dati_oggetto(id_arma).get("elemento", ""))

func effetto_colpo(bersaglio: Dictionary, danno: int, elemento := "", critico := false) -> Callable:
	# quello che si vede quando qualcuno incassa: il numero che sale dalla sua
	# scheda, il lampo, la barra della vita che scende. Tutto insieme e al
	# momento giusto della sequenza, non tre messaggi prima.
	#
	# Il numero ha un colore e una taglia, e vogliono dire qualcosa: rosso e'
	# un colpo normale, oro e grosso e' un critico, arancione e' fuoco, verde
	# acido e' veleno. Guardando lo scontro si capisce COSA sta succedendo senza
	# leggere una riga (vedi colori_danno in stile.json).
	var scheda: Control = bersaglio.scheda
	var vivo: bool = int(bersaglio.hp) > 0
	var tinta := Stile.colore_danno("critico" if critico else elemento)
	var testo := ("−%d!" % danno) if critico else ("−%d" % danno)
	return func() -> void:
		voce.suono("colpo")
		voce.numero_volante(scheda, testo, tinta, critico)
		if vivo:
			voce.lampeggia(scheda, tinta)
		aggiorna_scheda(bersaglio)

func mostra_colpo(bersaglio: Dictionary, danno: int, elemento := "", critico := false) -> void:
	# un colpo normale non ha bisogno di parole: si vede e basta. Cosi' il box
	# resta libero per le cose che vanno dette davvero
	voce.accoda_effetto(effetto_colpo(bersaglio, danno, elemento, critico))
	verifica_ultima_risorsa(bersaglio)

func scrivi_con_colpo(riga: String, bersaglio: Dictionary, danno: int, elemento := "") -> void:
	# una riga che racconta un danno (veleno, fiamme, una mossa con un nome):
	# il numero vola insieme alla frase, non prima e non dopo
	voce.accoda(riga, "narrazione", "", false, effetto_colpo(bersaglio, danno, elemento))
	verifica_ultima_risorsa(bersaglio)

func _su_ko(caduto: Dictionary) -> void:
	if not caduto.giocatore and GameState.personaggi.get(caduto.id, {}).get("invincibile", false):
		# non muore mai davvero: "sconfiggerlo" non basta, si rialza sempre
		caduto.hp = caduto.hp_max
		aggiorna_scheda(caduto)
		scrivi_forte("[i]%s si rialza, come se nulla fosse.[/i]" % caduto.nome)
		return
	if caduto.giocatore and String(caduto.get("resurrezione", "")) != "" and caduto.hp <= 0:
		# l'accessorio addosso a lui si spezza al posto suo: torna in vita a
		# meta' hp, una volta sola, e vale solo per chi lo portava
		var id_resurrezione := String(caduto.resurrezione)
		caduto.resurrezione = ""
		caduto.hp = maxi(int(ceil(float(caduto.hp_max) / 2.0)), 1)
		aggiorna_scheda(caduto)
		var nome_accessorio := String(GameState.dati_oggetto(id_resurrezione).get("nome", "Il tuo accessorio"))
		scrivi_forte("%s si spezza: %s torna in piedi con metà della vita." % [nome_accessorio, caduto.nome])
		GameState.consuma_equipaggiato(id_resurrezione)
		return
	if caduto.get("oggetto_scena", false):
		scrivi_forte("[i]%s vengono distrutte.[/i]" % caduto.nome)
		var leva := leva_bersaglio_di(String(caduto.id))
		if not leva.is_empty() and String(caduto.id) not in leve_bersaglio_riscosse:
			leve_bersaglio_riscosse.append(String(caduto.id))
			scrivi_forte("[i]%s[/i]" % String(leva.get("testo", "")))
			aggiorna_speranza(int(leva.get("speranza", 0)))
		if not portatore_frenesia.is_empty() \
				and caduto.id == portatore_frenesia.get("frenesia", {}).get("bersaglio_extra", ""):
			frenesia_attiva = false
			turni_afflitto = portatore_frenesia.get("frenesia", {}).get("testo_fermata", []).size()
	elif caduto.get("risparmiato", false):
		scrivi_forte("[i]%s si allontana. Vivo.[/i]" % caduto.nome)
	else:
		# un tuo compagno che cade, o la fonte che cede, sono momenti: aspettano
		# un click. Un nemico qualunque che va giu' scorre col resto
		var pesa: bool = bool(caduto.giocatore) or caduto.id == fonte.get("id", "")
		var riga := "[i]%s è a terra.[/i]" % caduto.nome
		if pesa:
			scrivi_forte(riga)
		else:
			scrivi(riga)
		if not caduto.giocatore:
			# la fonte ha una voce di sconfitta; gli altri il verso di morte
			if muto:
				pass
			elif caduto.id == fonte.get("id", ""):
				AudioManager.voce_boss(caduto.id, fonte, "sconfitta")
			else:
				AudioManager.verso(caduto.id, GameState.personaggi.get(caduto.id, {}), "morte")
			verifica_rabbia_su_morte(caduto)
			verifica_cura_su_morte(caduto)
	for alleato in vivi(caduto.giocatore):
		reagisci(alleato)
	if vivi(false).is_empty():
		giocatore_ha_vinto = true
		in_corso = false
		for combattente in combattenti:
			if combattente.giocatore or combattente.get("oggetto_scena", false):
				continue
			if combattente.get("risparmiato", false):
				# lasciare andare qualcuno insegna piu' che abbatterlo: rende
				# piu' esperienza di quanta ne avrebbe data da morto. Niente
				# Tazo pero': non si fruga addosso a chi hai lasciato vivo
				xp_bottino += RegoleCombattimento.xp_da_risparmio(combattente)
			else:
				xp_bottino += RegoleCombattimento.xp_effettiva(combattente)
				tazo_bottino += combattente.tazo
		scrivi_forte("Vittoria.", "notifica")
		if xp_bottino > 0 or tazo_bottino > 0:
			scrivi_forte("%d esperienza · %d Tazo" % [xp_bottino, tazo_bottino], "notifica")
		risolvi_drop()
	elif vivi(true).is_empty():
		in_corso = false
		scrivi_forte("Il party è a terra. Il disallineamento ha vinto.", "notifica")

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
		# IL DROP C'E' SEMPRE, e viene prima di tutti i tiri di dado: non e' una
		# probabilita' in piu', e' il pavimento. Chi hai abbattuto lascia
		# qualcosa, punto - pochi tazo, un frammento di vita o cianfrusaglia
		var garantito := GameState.drop_garantito_di(String(c.id))
		if not garantito.is_empty():
			if String(garantito.get("tipo", "")) == "tazo":
				var quanti_tazo := int(garantito.get("quanti", 1))
				GameState.modifica_tazo(quanti_tazo)
				righe.append("%d Tazo" % quanti_tazo)
			else:
				var id_lasciato := String(garantito.get("oggetto", ""))
				var quanti := int(garantito.get("quanti", 1))
				var nome_lasciato := String(GameState.dati_oggetto(id_lasciato).get("nome", id_lasciato))
				if GameState.e_da_pila(id_lasciato):
					var entrati := GameState.aggiungi_alla_pila(id_lasciato, quanti)
					if entrati > 0:
						righe.append("%s ×%d" % [nome_lasciato, entrati])
					else:
						righe.append("%s (la pila è piena)" % nome_lasciato)
				elif GameState.aggiungi_oggetto(id_lasciato):
					righe.append(nome_lasciato)
		# Pieta' usata su questo qui mentre era quasi finito: vale solo per lui,
		# non per tutta la stanza. E' il senso dell'abilita' - hai speso un turno
		# su UN nemico, e quel nemico lascia di piu'
		var suo := moltiplicatore + float(c.get("bonus_drop", 0.0))
		var sua_carta := molt_carta + float(c.get("bonus_drop", 0.0))
		var carta: Dictionary = c.carta
		if not carta.is_empty():
			var chance_carta := minf(float(carta.get("chance", 1.0)) * sua_carta, 1.0)
			if GameState.rng.randf() < chance_carta and GameState.ottieni_carta(String(carta.get("id", ""))):
				righe.append("carta \"%s\" [%s]" % [carta.get("nome", ""), carta.get("rarita", "")])
		for voce_bottino in c.bottino_comune:
			if GameState.rng.randf() < float(voce_bottino.get("chance", 0.0)) * suo:
				var id_oggetto := String(voce_bottino.get("oggetto", ""))
				if GameState.aggiungi_oggetto(id_oggetto):
					righe.append(String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)))
		var raro: Dictionary = c.drop_raro
		if not raro.is_empty():
			var chance_rara := minf(float(raro.get("chance", 0.0)) * suo, 1.0)
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
		var elenco := ", ".join(righe)
		scrivi_forte(("Raccogli dal campo: %s." if righe.size() > 1 else "Raccogli dal campo: %s.") % elenco,
				"notifica")

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
			scrivi("%s si concentra: la barra di dominio sale." % alleato.nome)
	aggiorna_scheda(alleato)

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

# --- il vocabolario del motore ------------------------------------------
# Quattro parole, una riga ciascuna. Il motore dice "scrivi" e "aggiorna la
# scheda" senza sapere se dall'altra parte c'e' uno schermo o il giocatore
# automatico: e' esattamente questo che rende lo stesso codice giocabile e
# simulabile.

func scrivi(riga: String, tipo := "narrazione", chi := "") -> void:
	voce.scrivi(riga, tipo, chi)

func scrivi_forte(riga: String, tipo := "narrazione", chi := "") -> void:
	voce.scrivi_forte(riga, tipo, chi)

func svuota_coda() -> void:
	await voce.svuota_coda()

func aggiorna_scheda(combattente: Dictionary) -> void:
	campo.aggiorna(combattente)

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
		IngressoNodo.vai_al_nodo(GameState.nodo_corrente)
	elif giocatore_e_fuggito and dopo_fuga != "":
		GameState.annulla_combattimento()
		GameState.nodo_corrente = dopo_fuga
		IngressoNodo.vai_al_nodo(GameState.nodo_corrente)
	elif dopo_sconfitta != "":
		GameState.annulla_combattimento()
		GameState.nodo_corrente = dopo_sconfitta
		IngressoNodo.vai_al_nodo(GameState.nodo_corrente)
	else:
		GameState.reset_campagna()
		Transizioni.vai(SCENA_SEDE)
