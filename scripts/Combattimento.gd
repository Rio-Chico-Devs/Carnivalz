extends Control

# Combattimento in tempo reale: il MOTORE, e solo quello.
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
# del giocatore, cinque fisse: Attacca, Difendi, Abilita' (Studia sempre
# disponibile, e i colpi d'arma), Oggetti (dalla sacca), Fuggi. Due condizionali
# in fondo: Aiutante (ospiti non combattenti) e Mediazione. Esito eroe via
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

# Stati generici (veleno, sonno, berserk, maledizione...): vedi
# data/stati.json. Provocazione: un compagno forza i nemici a colpire lui.
var bersaglio_provocazione: Dictionary = {}
var turni_provocazione := 0

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
	# MENTRE E' MATTANZA, SPAZIO E' UN COLPO. Viene prima di tutto il resto: in
	# quei secondi la barra spaziatrice non fa scorrere il testo, pesta.
	# is_echo() esclusa apposta - tenere premuto non deve valere come martellare,
	# se no la finestra la vince la ripetizione automatica della tastiera
	if mattanza_attiva and evento.is_action_pressed("ui_accept") and not evento.is_echo():
		colpo_di_mattanza()
		get_viewport().set_input_as_handled()
		return
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
	if not giocatore and GameState.e_da_bestiario(id_personaggio):
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
		# la forma in cui si e' chiusa (Ouroboros, Autoriciclaggio) e il conto
		# alla rovescia verso quello che diventera'. Vuoti = e' se' stessa
		"modalita": {},
		"trasformazione": {},
		# quante volte ha mosso (le mosse possono chiedere "non prima della
		# terza") e quali sue mosse sono ancora in ricarica
		"battute": 0,
		"ricariche_mosse": {},
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
		# la Copertura di Veronica: chi ti para davanti, e per quante tue battute
		"coperto_da": -1,
		"copertura_turni": 0,
		# "Finche' respiro": una sola volta, quando cadrebbe resta a 1
		"ultima_resistenza": false,
		# chi ti ha provocato, letto da applica_stato quando arriva "provocato"
		"id_provocatore": "",
		# chi cade per maledizione non si rialza fino a fine scontro
		"non_rianimabile": false,
		# Pieta': quanto in piu' lascera' cadere questo qui
		"bonus_drop": 0.0,
		"gamba_rotta_turni": 0,
		"gamba_gia_rotta": false,
		"volte_studiato": 0,
		# LA MEDIAZIONE SI DECIDE ALL'INGRESSO, non quando la chiedi. Bru: "in
		# quelli che mediano e' randomico se vogliono o meno". Il tiro va fatto
		# una volta sola, qui: se lo tirassimo alla pressione del bottone, il
		# giocatore ripremerebbe finche' non passa e il caso diventerebbe una
		# formalita' - due click invece di uno. Deciso adesso, invece, la stessa
		# specie e' mediabile stasera e non domani, e questo lo scopri studiando.
		# Chi non ha il campo "mediazione" non media MAI: e' la sua natura, non
		# un tiro andato male
		"vuole_mediare": tira_volonta_di_mediare(dati),
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
	# IL RIFERIMENTO E' IL PROTAGONISTA, non un numero fisso.
	#
	# Con un riferimento fisso (6) al livello 1 le velocita' vere sono 2 o 3, e
	# tutte le ricariche finivano schiacciate contro il limite lento: ogni
	# creatura si muoveva uguale, e i ruoli - il veloce, il corazzato - non si
	# sentivano affatto. Rapportandola a chi giochi tu, un "veloce" e' sempre il
	# doppio di te e un "corazzato" sempre la meta', al livello 1 come al 30.
	var dati: Dictionary = GameState.regole.get("tempo", {})
	var riferimento := float(dati.get("velocita_riferimento", 6))
	for altro in combattenti:
		if altro.giocatore and String(altro.get("id", "")) == GameState.id_protagonista:
			riferimento = float(RegoleCombattimento.velocita_effettiva(altro))
			break
	riferimento = maxf(riferimento, 1.0)
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
	avanza_mattanza(delta)   # la barra si scarica anche mentre il mondo e' fermo
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
		# va detto adesso chi sta usando il menu, se no la prima versione nasce
		# senza le tue abilita' e senza la tua arma
		attaccante_corrente = combattente_comandato()
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
	var scheda = combattente.get("bersaglio_cliccabile", null)
	if scheda == null or not is_instance_valid(scheda):
		return
	if not scheda.gui_input.is_connected(_su_input_nemico):
		scheda.gui_input.connect(_su_input_nemico.bind(combattente))

func _su_input_nemico(evento: InputEvent, bersaglio: Dictionary) -> void:
	if evento is InputEventMouseButton and evento.pressed \
			and evento.button_index == MOUSE_BUTTON_LEFT:
		_su_click_nemico(bersaglio)

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

func giocatore_pronto() -> bool:
	var tu := combattente_comandato()
	return not tu.is_empty() and puo_agire(tu)

func aggiorna_pronto_giocatore() -> void:
	# IL MENU NON SPARISCE MAI, SI SPEGNE. Prima si cancellava mentre ricaricavi
	# e si ricostruiva quando eri pronto: per meta' dello scontro, sotto, non
	# c'era niente. Bru: "il menu sotto non e' sempre consultabile". Adesso i
	# bottoni restano al loro posto e diventano grigi - si vede lo stesso che la
	# ricarica non e' finita, ma si legge sempre cosa si potra' fare
	if menu == null:
		return
	var tu := combattente_comandato()
	var pronto := giocatore_pronto()
	if pronto != menu_acceso:
		menu_acceso = pronto
		attaccante_corrente = tu
		menu.principale()

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
	# il menu resta a schermo e si spegne: lo ricostruisce chi ha chiamato (vedi
	# MenuCombattimento.scegli), e aggiorna_pronto_giocatore lo riaccende quando
	# la ricarica e' di nuovo finita
	menu_acceso = false

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
	attaccante.battute = int(attaccante.get("battute", 0)) + 1
	scala_ricariche(attaccante)
	risolvi_rigenerazione_frammento(attaccante)
	RegoleCombattimento.scadenza_buff(attaccante)
	scala_astio(attaccante)
	avanza_modalita(attaccante)
	avanza_trasformazione(attaccante)
	if int(attaccante.get("turni_immune", 0)) > 0:
		# l'immunita' di Mantra copre il giro fino al tuo turno successivo: si
		# consuma qui, quando torni a muovere, non a fine giro
		attaccante.turni_immune = int(attaccante.turni_immune) - 1
	if int(attaccante.get("copertura_turni", 0)) > 0:
		# stessa regola per la copertura di Veronica: "tre battute" vuol dire
		# tre battute di CHI E' COPERTO, non tre di chi copre
		attaccante.copertura_turni = int(attaccante.copertura_turni) - 1
		if int(attaccante.copertura_turni) <= 0:
			attaccante.coperto_da = -1
	aggiorna_scheda(attaccante)
	recupera_aura(attaccante)
	campo.evidenzia(combattenti, attaccante)
	if attaccante.in_fiamme:
		applica_combustione(attaccante)
		if attaccante.hp <= 0:
			return  # bruciato prima di poter agire
	if risolvi_stati_a_inizio_turno(attaccante):
		return  # il turno salta (Sonno) o la maledizione arriva a zero e lo porta via
	if attaccante.giocatore:
		attaccante_corrente = attaccante
		if RegoleCombattimento.solo_attacchi(attaccante):
			# Rabbia e Frastornato tolgono il menu, non solo una voce: chi ha
			# perso la testa non sceglie. Il bersaglio lo decide chi ti ha
			# provocato, se c'e' - altrimenti e' a caso, che e' il punto di
			# tutti e due gli stati
			scrivi("[i]%s ha perso il controllo: può solo attaccare.[/i]" % attaccante.nome)
			var nemici := bersagli_ammessi(attaccante, vivi(false))
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
		if bool(dati.get("consuma_tutto", false)):
			segmenti = float(dati.get("dominio_minimo", 1.0))
		if segmenti > 0.0 and not dominio_sufficiente(chi, dati):
			continue
		if segmenti > 0.0 and GameState.rng.randf() < 0.6:
			if abilita_vuole_bersaglio(String(id_abilita)):
				return {"tipo": "abilita", "id": String(id_abilita),
						"bersaglio": nemici[GameState.rng.randi_range(0, nemici.size() - 1)]}
			return {"tipo": "abilita", "id": String(id_abilita)}
	return {"tipo": "attacca",
			"bersaglio": nemici[GameState.rng.randi_range(0, nemici.size() - 1)]}

func esegui_azione(attaccante: Dictionary, azione: Dictionary) -> void:
	if true:
		if true:
			var bersaglio_scelto: Dictionary = azione.get("bersaglio", {})
			if azione.get("tipo", "") == "attacca" and RegoleCombattimento.ha_stato_attivo(attaccante, "frastornato") \
					and GameState.rng.randf() < 0.5:
				var chiunque: Array[Dictionary] = []
				for c in vivi(true) + vivi(false):
					if c.indice != attaccante.indice:
						chiunque.append(c)
				if not chiunque.is_empty():
					bersaglio_scelto = chiunque[GameState.rng.randi_range(0, chiunque.size() - 1)]
					scrivi("[i]%s è frastornato e colpisce %s per sbaglio![/i]" % [attaccante.nome, bersaglio_scelto.nome])
			var obbligato := RegoleCombattimento.bersaglio_obbligato(attaccante)
			if azione.get("tipo", "") == "attacca" and obbligato != "" \
					and String(bersaglio_scelto.get("id", "")) != obbligato:
				# Provocato: il colpo va dove ha deciso chi ti ha provocato,
				# non dove avevi puntato tu
				for c in vivi(not attaccante.giocatore):
					if String(c.id) == obbligato:
						bersaglio_scelto = c
						scrivi("[i]%s non riesce a colpire altri che %s.[/i]" % [attaccante.nome, c.nome])
						break
			match azione.get("tipo", ""):
				"attacca":
					colpo_darma(attaccante, bersaglio_scelto, azione.get("arma", {}))
				"difendi":
					difendi(attaccante)
				"studia":
					studia(attaccante, bersaglio_scelto)
				"media":
					media(bersaglio_scelto)
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
	rileva_tecnolog(bersaglio)
	GameState.segna_studiato(bersaglio.id)
	if chi.giocatore and chi.id == GameState.id_protagonista:
		GameState.registra_azione("studi")
	if bersaglio.id == fonte.get("id", ""):
		aggiorna_speranza(int(GameState.regole.get("speranza_studio", 10)))
	verifica_innesco_combustione(bersaglio)
	annuncia_mediazione(bersaglio)

func rileva_tecnolog(bersaglio: Dictionary) -> void:
	# QUELLO CHE LO STUDIO SCRIVE. Bru: "lo studio deve dare questi aspetti di
	# descrizione della specie: filogenesi, ovvero il corpo d'origine".
	#
	# Escono solo i campi di QUESTO strato, non tutta la scheda da capo: il primo
	# studio dice chi e' e da dove viene, il secondo com'e' fatta, il terzo come
	# si comporta. Ristampare ogni volta l'intera pagina avrebbe tolto il senso
	# di studiare la seconda volta - e sarebbero venti righe in mezzo a uno
	# scontro. La pagina intera si rilegge nel Bestiario, che e' il posto giusto:
	# li' non c'e' nessuno che ti picchia mentre leggi.
	if bersaglio.get("oggetto_scena", false):
		return
	var strato := int(bersaglio.get("volte_studiato", 0))
	var nuove: Array[String] = []
	for riga in GameState.tecnolog_di(String(bersaglio.id)):
		if int(riga.get("strato", 1)) == strato:
			nuove.append("%s: %s" % [String(riga.get("etichetta", "")), String(riga.get("valore", ""))])
	if nuove.is_empty():
		return
	scrivi("[i]TECNO LOG — %s[/i]" % String(bersaglio.nome))
	for riga in nuove:
		scrivi("[i]%s[/i]" % riga)

# --- la mediazione ---
#
# LA SESTA VOCE, quella che di solito non c'e'. Bru: "in alcuni casi rari
# apparira' mediazione, solo dopo che dallo studio sei riuscito a capire che
# quel determinato nemico vuole ascoltarti".
#
# Tre filtri in fila, e servono tutti e tre:
#   1. la creatura ha un campo "mediazione"? Se no non media mai, per natura.
#      Non e' sfortuna: certe cose non ti ascoltano e basta.
#   2. stasera vuole? Tirato una volta all'ingresso (vedi "vuole_mediare").
#   3. l'hai studiata abbastanza da accorgertene?
# Solo quando passano tutti e tre il bottone compare. Un bottone che compare e
# poi ti risponde "no" sarebbe un bottone che ha mentito - la stessa regola
# della Mattanza spenta quando la barra non basta.

static func tira_volonta_di_mediare(dati: Dictionary) -> bool:
	var mediazione: Dictionary = dati.get("mediazione", dati.get("risparmio", {}))
	if mediazione.is_empty():
		return false
	# le creature che non si possono lasciare andare per copione (i boss, gli
	# scriptati) non mediano nemmeno se qualcuno gli scrive il campo per sbaglio
	if dati.get("invincibile", false) or dati.has("incontro_scriptato"):
		return false
	# GameState.rng e non randf(): il simulatore gira con un seme, e una partita
	# rigiocata con lo stesso seme deve dare lo stesso esito. Un randf() qui
	# renderebbe irriproducibili le 187.200 partite di ./prove/simula.sh.
	# Senza "probabilita" dichiarata media sempre: le creature scritte a mano
	# prima che esistesse il tiro (la Tartaruga) devono continuare a funzionare
	return GameState.rng.randf() < float(mediazione.get("probabilita", 1.0))

func dati_mediazione(bersaglio: Dictionary) -> Dictionary:
	return GameState.mediazione_di(String(bersaglio.get("id", "")))

func mediabile(bersaglio: Dictionary) -> bool:
	if int(bersaglio.get("hp", 0)) <= 0 or bersaglio.get("oggetto_scena", false):
		return false
	if not bool(bersaglio.get("vuole_mediare", false)):
		return false
	var mediazione := dati_mediazione(bersaglio)
	if mediazione.is_empty():
		return false
	return int(bersaglio.get("volte_studiato", 0)) \
			>= maxi(int(mediazione.get("studi_richiesti", 1)), 1)

func bersagli_mediabili() -> Array[Dictionary]:
	var risultato: Array[Dictionary] = []
	for nemico in vivi(false):
		if mediabile(nemico):
			risultato.append(nemico)
	return risultato

func annuncia_mediazione(bersaglio: Dictionary) -> void:
	# lo studio e' l'unico posto da cui puoi sapere che questa qui ti ascolta.
	# Si dice una volta sola: ripeterlo a ogni studio successivo sarebbe
	# rumore, e il bottone intanto e' li' a ricordarlo da solo
	if bersaglio.get("mediazione_annunciata", false) or not mediabile(bersaglio):
		return
	bersaglio.mediazione_annunciata = true
	var mediazione := dati_mediazione(bersaglio)
	scrivi_forte("[i]%s[/i]" % String(mediazione.get("testo_apertura",
			"%s ti sta ascoltando. Si può mediare." % String(bersaglio.nome))))

func media(bersaglio: Dictionary) -> void:
	# esce dal combattimento senza dare Tazo ne' drop, ma rende piu' xp di
	# quanta ne renderebbe da morto, il legame sale e lo stress della squadra
	# scende. Gli altri nemici in campo restano dove sono.
	#
	# Mediare e' una decisione, non un'azione: si legge con calma, e si vede
	# subito cosa comporta. Prima costava xp e Tazo in silenzio, e il giocatore
	# non poteva sapere che scambio stesse facendo
	var dati_risparmio := dati_mediazione(bersaglio)
	if dati_risparmio.is_empty():
		return
	scrivi_forte(String(dati_risparmio.get("testo", "Decidi di lasciarlo andare.")))
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
		"provoca": provoca(chi, [] if bool(dati.get("tutti", false)) else [primo_nemico()])
		"area": attacco_area(chi, dati)
		"raffica": raffica(chi, dati)
		"carica": carica(chi, dati)
		"astio": astio(chi, dati)
		"mantra": mantra(chi, dati)
		"flagello": flagello(chi, dati)
		"guardia": guardia(chi, dati)
		"copertura": copertura(chi, dati)
		"immunita": immunita(chi, dati)
		"rianima": rianima(chi, dati)
		"ultima_resistenza": ultima_resistenza(chi, dati)
		"evoca_alleato": evoca_alleato(chi, dati)
		"passiva": passiva(chi, dati)

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
		"mattanza": mattanza(chi, bersaglio, dati)

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
	if bool(dati.get("consuma_tutto", false)):
		# LA MATTANZA NON PAGA UN PREZZO: SVUOTA. Bru: "quando riempi almeno una
		# barra puoi andare in mattanza, SOLO in quel momento, la mattanza consuma
		# tutta la barra". Quindi la soglia e' a segmenti PIENI - mezza barra non
		# apre niente - e quello che entra nel serbatoio e' tutto il resto
		var minimo := float(dati.get("dominio_minimo", 1.0))
		if float(RegoleCombattimento.segmenti_pieni(chi)) < minimo:
			scrivi("[i]%s non ha abbastanza dominio: serve almeno %d barra piena.[/i]"
					% [chi.nome, int(ceil(minimo))])
			return false
		return true
	var segmenti := float(dati.get("dominio", 0.0))
	if segmenti <= 0.0:
		return true
	if not RegoleCombattimento.spendi_dominio(chi, segmenti):
		scrivi("[i]%s non ha abbastanza dominio: servono %.1f barre.[/i]" % [chi.nome, segmenti])
		return false
	return true

func dominio_sufficiente(chi: Dictionary, dati: Dictionary) -> bool:
	# la stessa domanda che fa paga_il_dominio, ma senza spendere niente e senza
	# scrivere: serve al menu per far vedere spento quello che non si puo' ancora
	# chiamare. Se fossero due conti separati, prima o poi direbbero due cose
	# diverse e ci sarebbe un bottone acceso che non fa niente
	if bool(dati.get("consuma_tutto", false)):
		return float(RegoleCombattimento.segmenti_pieni(chi)) >= float(dati.get("dominio_minimo", 1.0))
	var segmenti := float(dati.get("dominio", 0.0))
	return segmenti <= 0.0 or RegoleCombattimento.puo_spendere_dominio(chi, segmenti)

func categoria_del_combattente(chi: Dictionary) -> String:
	# categoria_di legge il record di personaggi.json, non la scheda in campo
	return RegoleCombattimento.categoria_di(GameState.personaggi.get(String(chi.get("id", "")), {}))

func abilita_vuole_bersaglio(id_abilita: String) -> bool:
	return String(GameState.abilita_combattimento(id_abilita).get("tipo", "")) \
			in ["vendetta", "annichilazione", "pieta", "mattanza"]

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

# --- MATTANZA: la barra si svuota, e finche' si svuota tu batti --------------
#
# Bru: "quando riempi almeno una barra, puoi andare in mattanza, SOLO in quel
# momento; la mattanza consuma tutta la barra e finche' non e' consumata potrai
# premere spazio per colpire numerose volte il nemico, con un valore di ogni
# colpo pari a 1/10 del tuo attacco attuale".
#
# Tre cose, e sono tutte e tre la stessa cosa vista da angoli diversi:
#
#   la SOGLIA e' a segmenti pieni - mezza barra non apre niente. E' quello che
#   rende la barra una cosa che si aspetta invece di un contatore che sale;
#
#   il COSTO e' tutto quello che c'e'. Non e' un prezzo, e' un serbatoio: quanta
#   barra avevi decide quanto dura la finestra, quindi tenerla da parte e'
#   davvero una scelta e non solo pazienza;
#
#   la DURATA e' la barra stessa che si scarica. Non c'e' un secondo contatore
#   accanto a quello vero: guardi la barra scendere e sai quanto ti resta. Per
#   questo il dominio viene riscritto ogni frame dal residuo - se un colpo
#   incassato lo ricaricasse mentre martelli, la mattanza non finirebbe piu'.
#
# Quanti colpi entrano lo decidi tu con le mani. Il giocatore automatico le mani
# non ce l'ha: nelle prove batte a "pressioni_al_secondo", che sta nei dati
# accanto al resto perche' e' una stima dichiarata, non un numero nascosto.

var mattanza_attiva := false
var mattanza_chi: Dictionary = {}
var mattanza_bersaglio: Dictionary = {}
var mattanza_rimasto := 0.0      # quanto dominio resta da bruciare
var mattanza_scarico := 0.0      # quanto ne brucia al secondo
var mattanza_colpi := 0
var mattanza_dati: Dictionary = {}

func mattanza(chi: Dictionary, bersaglio: Dictionary, dati: Dictionary) -> void:
	var serbatoio := RegoleCombattimento.svuota_dominio(chi)
	if serbatoio <= 0:
		return
	var per_segmento := maxf(float(GameState.regole.get("dominio", {}).get("per_segmento", 100)), 1.0)
	var durata := float(dati.get("secondi_per_segmento", 2.2)) * (float(serbatoio) / per_segmento)
	scrivi(String(dati.get("testo_uso", "[i]%s non smette più.[/i]")) % chi.nome)
	mattanza_chi = chi
	mattanza_bersaglio = bersaglio
	mattanza_dati = dati
	mattanza_colpi = 0
	mattanza_rimasto = float(serbatoio)
	mattanza_scarico = float(serbatoio) / maxf(durata, 0.01)
	chi.dominio = serbatoio
	aggiorna_scheda(chi)
	if not tempo_reale or muto:
		# NESSUNA MANO DA QUESTA PARTE. Nell'orologio virtuale non esiste una
		# barra spaziatrice e non esiste un frame: la finestra si risolve tutta
		# adesso, con le battute che ci batterebbe una persona. Se qui non
		# succedesse niente, il simulatore direbbe che la Mattanza non fa danno -
		# e ricalibreremmo il gioco intero su un'abilita' che non ha mai colpito
		var quante := maxi(int(round(durata * float(dati.get("pressioni_al_secondo", 6.0)))), 1)
		for volta in quante:
			if not colpo_di_mattanza():
				break
		chiudi_mattanza()
		return
	mattanza_attiva = true
	if bool(dati.get("ferma_il_tempo", false)):
		ferma_il_tempo()
	if not muto:
		menu.principale()   # sotto compare "MARTELLA SPAZIO", e nient'altro

func colpo_di_mattanza() -> bool:
	# un colpo, e dice se ha senso continuare. Va DIRITTO: un decimo dell'attacco
	# senza passare dalla difesa, cosi' la Mattanza e' la risposta ai corazzati
	# invece dell'ennesima cosa che contro un corazzato non serve
	if mattanza_chi.is_empty() or int(mattanza_chi.get("hp", 0)) <= 0 or not in_corso:
		return false
	if mattanza_bersaglio.is_empty() or int(mattanza_bersaglio.get("hp", 0)) <= 0:
		# il bersaglio e' caduto sotto i colpi: si passa al prossimo, non ci si
		# ferma. Chi sta martellando non ha il tempo di riscegliere
		var restanti := vivi(false)
		if restanti.is_empty():
			return false
		mattanza_bersaglio = restanti[0]
	var danno := maxi(int(round(RegoleCombattimento.attacco_di(mattanza_chi)
			* float(mattanza_dati.get("frazione_attacco", 0.1)))), 1)
	mattanza_colpi += 1
	colpisci_diretto(mattanza_bersaglio, danno, String(mattanza_dati.get("elemento", "")))
	return in_corso

func avanza_mattanza(delta: float) -> void:
	if not mattanza_attiva:
		return
	mattanza_rimasto -= mattanza_scarico * delta
	# la barra E' il cronometro: si riscrive dal residuo, cosi' niente di quello
	# che succede intorno (un colpo incassato che ricarica) puo' allungare la
	# finestra all'infinito
	mattanza_chi.dominio = maxi(int(round(mattanza_rimasto)), 0)
	aggiorna_scheda(mattanza_chi)
	if mattanza_rimasto <= 0.0 or not in_corso or int(mattanza_chi.get("hp", 0)) <= 0:
		chiudi_mattanza()

func chiudi_mattanza() -> void:
	var era_attiva := mattanza_attiva
	mattanza_attiva = false
	if not mattanza_chi.is_empty():
		mattanza_chi.dominio = 0
		aggiorna_scheda(mattanza_chi)
		scrivi(String(mattanza_dati.get("testo_fine", "[i]%s si ferma: %d colpi.[/i]"))
				% [mattanza_chi.nome, mattanza_colpi])
	if era_attiva and bool(mattanza_dati.get("ferma_il_tempo", false)):
		riprendi_il_tempo()
	mattanza_rimasto = 0.0
	mattanza_scarico = 0.0
	mattanza_chi = {}
	mattanza_bersaglio = {}
	mattanza_dati = {}
	if era_attiva and not muto and in_corso:
		menu.principale()

func provoca(chi: Dictionary, bersagli: Array[Dictionary] = []) -> void:
	# LA PROVOCAZIONE ADESSO E' UNO STATO SUBITO, non solo una calamita globale.
	# Bru: "puoi attaccare solo il nemico che ti ha provocato... togliamolo dal
	# personaggio principale, sara' una mossa speciale di determinati
	# personaggi" - cioe' la linea Richiamo di Veronica.
	#
	# Le due cose convivono: bersaglio_provocazione resta perche' la usa l'IA
	# nemica per scegliere chi picchiare, e "provocato" e' quello che si vede
	# addosso a chi l'ha subita, con la sua durata e il suo nome nella scheda.
	bersaglio_provocazione = chi
	turni_provocazione = int(GameState.stati.get("provocato", {}).get("durata", 3))
	scrivi("[i]%s si mette in mostra: i nemici non vedono altro che lui.[/i]" % chi.nome)
	for vittima in (bersagli if not bersagli.is_empty() else vivi(not chi.giocatore)):
		# chi l'ha provocata va scritto PRIMA di applicare lo stato: applica_stato
		# legge id_provocatore per sapere a chi resti inchiodato
		vittima.id_provocatore = String(chi.id)
		applica_stato(vittima, "provocato")

# --- le abilita' di Veronica e Yhvina ---
#
# Sette tipi nuovi, e sono POCHI apposta: le trentasei mosse dei due personaggi
# sono trentasei tarature di questi sette, non trentasei funzioni. Una mossa che
# ha bisogno di una funzione sua e' una mossa che nessun'altra potra' mai
# riusare, e ne restano ancora nove personaggi da scrivere.

func smista_la_copertura(bersaglio: Dictionary, danno: int) -> int:
	# Se qualcuno lo sta coprendo, meta' del colpo va a chi copre. Ritorna
	# quanto ne resta per il bersaglio.
	#
	# Chi copre incassa DIRETTAMENTE, senza ripassare da attacca(): se ci
	# ripassasse, la sua stessa copertura si applicherebbe di nuovo e due
	# personaggi che si coprono a vicenda si rimpallerebbero il colpo per sempre
	if int(bersaglio.get("copertura_turni", 0)) <= 0 or danno <= 1:
		return danno
	var indice_scudo := int(bersaglio.get("coperto_da", -1))
	if indice_scudo < 0 or indice_scudo >= combattenti.size():
		return danno
	var scudo: Dictionary = combattenti[indice_scudo]
	if int(scudo.hp) <= 0:
		bersaglio.copertura_turni = 0
		return danno
	var quota := danno / 2
	scudo.hp = maxi(int(scudo.hp) - quota, 0)
	trattieni_a_un_punto(scudo)
	registra_danno_subito(scudo, quota)
	scrivi("[i]%s si prende metà del colpo al posto di %s.[/i]" % [scudo.nome, bersaglio.nome])
	mostra_colpo(scudo, quota, "")
	aggiorna_scheda(scudo)
	if int(scudo.hp) <= 0:
		_su_ko(scudo)
	return danno - quota

func trattieni_a_un_punto(chi: Dictionary) -> void:
	# "Finche' respiro": quando cadrebbe resta a 1, una volta per scontro. Sta
	# qui e non in _su_ko perche' deve agire PRIMA che il KO succeda: da _su_ko
	# in poi ci sono gia' andati di mezzo il diario, i premi e la scheda
	if int(chi.hp) > 0 or not bool(chi.get("ultima_resistenza", false)):
		return
	chi.ultima_resistenza = false
	chi.hp = 1
	scrivi_forte("[i]%s resta in piedi con un soffio di vita.[/i]" % chi.nome)
	aggiorna_scheda(chi)

func guardia(chi: Dictionary, dati: Dictionary) -> void:
	# Il Baluardo di Veronica: alza la guardia di uno o piu' scatti, e gli
	# scatti restano fino a fine scontro come tutti gli altri. Diverso da
	# "Difendi" del menu solo per quanti ne alza in un colpo
	var quanti := int(dati.get("scatti", 1))
	var alzati := 0
	for volta in range(quanti):
		var tetto := int(GameState.regole.get("difesa_scatti_massimi", 6))
		if RegoleCombattimento.scatti_difesa(chi) >= tetto:
			break
		RegoleCombattimento.alza_guardia(chi)
		alzati += 1
	if alzati == 0:
		scrivi("[i]%s è già chiuso quanto può.[/i]" % chi.nome)
		return
	scrivi(String(dati.get("testo_uso", "[i]%s si pianta e non si sposta.[/i]")) % chi.nome)
	scrivi("Guardia +%d (difesa ora %d)." % [alzati, RegoleCombattimento.difesa_di(chi)])
	aggiorna_scheda(chi)

func copertura(chi: Dictionary, dati: Dictionary) -> void:
	# "un compagno prende meta' danno, l'altra meta' la prende lei". Si copre
	# chi sta peggio: e' quello che farebbe qualsiasi giocatore, e chiederglielo
	# ogni volta sarebbe una domanda con una risposta sola
	var piu_malmesso: Dictionary = {}
	for alleato in vivi(chi.giocatore):
		if alleato.indice == chi.indice:
			continue
		if piu_malmesso.is_empty() \
				or float(alleato.hp) / maxf(float(alleato.hp_max), 1.0) \
					< float(piu_malmesso.hp) / maxf(float(piu_malmesso.hp_max), 1.0):
			piu_malmesso = alleato
	if piu_malmesso.is_empty():
		scrivi("[i]%s non ha nessuno da coprire.[/i]" % chi.nome)
		return
	piu_malmesso.coperto_da = int(chi.indice)
	piu_malmesso.copertura_turni = int(dati.get("turni", 3))
	scrivi(String(dati.get("testo_uso", "[i]%s si mette davanti a %s.[/i]")) % piu_malmesso.nome)
	aggiorna_scheda(piu_malmesso)

func immunita(chi: Dictionary, dati: Dictionary) -> void:
	# "per due battute e' intoccabile". Usa turni_immune, che e' la stessa
	# macchina del Mantra IV: un colpo che si vede arrivare e non arriva
	chi.turni_immune = int(dati.get("turni", 2))
	scrivi(String(dati.get("testo_uso", "[i]Addosso a %s non passa piu' niente.[/i]")) % chi.nome)
	aggiorna_scheda(chi)

func rianima(chi: Dictionary, dati: Dictionary) -> void:
	# rimette in piedi un compagno caduto. NON tocca chi e' caduto per
	# maledizione: quello e' il senso della maledizione, e un'abilita' che la
	# aggira la cancella
	for alleato in combattenti:
		if alleato.giocatore != chi.giocatore or int(alleato.hp) > 0:
			continue
		if alleato.get("non_rianimabile", false):
			continue
		alleato.hp = maxi(int(round(float(alleato.hp_max) * float(dati.get("quota", 0.30)))), 1)
		scrivi(String(dati.get("testo_uso", "[i]%s rimette in piedi chi era caduto.[/i]")) % chi.nome)
		scrivi("%s torna in piedi con %d punti vita." % [alleato.nome, int(alleato.hp)])
		aggiorna_scheda(alleato)
		return
	scrivi("[i]Non c'è nessuno da rialzare.[/i]")

func ultima_resistenza(chi: Dictionary, dati: Dictionary) -> void:
	# "quando cadrebbe resta a 1 punto vita, una volta per scontro"
	chi.ultima_resistenza = true
	scrivi(String(dati.get("testo_uso", "[i]%s decide che non cade oggi.[/i]")) % chi.nome)
	aggiorna_scheda(chi)

func evoca_alleato(chi: Dictionary, dati: Dictionary) -> void:
	# il Richiamo di Yhvina. Passa dalla stessa macchina che usano i nemici per
	# evocare - aggiungi_combattente - solo dal lato della squadra.
	#
	# QUALE creatura evochi non e' deciso: e' la domanda aperta piu' grossa su
	# Yhvina ("cosa evoca?"). Finche' non arriva la risposta il campo "valore"
	# dice quale, e si cambia da li' senza toccare il motore
	var chi_arriva := String(dati.get("valore", ""))
	if chi_arriva == "" or not GameState.personaggi.has(chi_arriva):
		scrivi("[i]%s chiama, ma non risponde nessuno.[/i]" % chi.nome)
		return
	var arrivati := 0
	for volta in range(int(dati.get("quantita", 1))):
		if vivi(chi.giocatore).size() >= int(GameState.regole.get("evocati_massimi_squadra", 4)):
			break
		aggiungi_combattente(chi_arriva, chi.giocatore)
		arrivati += 1
	if arrivati == 0:
		scrivi("[i]...ma non c'è più posto.[/i]")
		return
	scrivi(String(dati.get("testo_uso", "[i]%s chiama, e qualcosa risponde.[/i]")) % chi.nome)

func passiva(_chi: Dictionary, dati: Dictionary) -> void:
	# LA VEGLIA DI YHVINA, e tutte quelle come lei. Una passiva non si "usa":
	# vale sempre, e l'effetto lo legge chi di dovere (le immunita' le legge
	# resistenza_di, il recupero d'aura la ricarica).
	#
	# Esiste come tipo lo stesso, invece di non essere niente, per una ragione
	# sola: cosi' la prova che verifica che ogni abilita' dichiarata sia
	# eseguibile continua a coprirla. Un'abilita' senza tipo sarebbe un'abilita'
	# che nessuno controlla piu'
	scrivi("[i]%s[/i]" % String(dati.get("descrizione", "Vale sempre, non si usa.")))

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
	RegoleCombattimento.applica_buff(nemico, "difesa",
			-int(dati.get("riduzione_difesa", 3)), 1, "crisi_gelosia")
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
	# PRIMA IL GIUDIZIO, POI IL CASO. Una creatura ferita che ha di che curarsi
	# si cura: non e' una possibilita' fra le altre, e' quello che fa
	var scelta := mossa_saggia(nemico)
	if not scelta.is_empty():
		lancia_mossa(nemico, scelta)
		return
	var mosse: Array = []
	for mossa in nemico.mosse:
		if not mossa_disponibile(nemico, mossa):
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
				lancia_mossa(nemico, mossa)
				return
	attacca(nemico, bersaglio_giocatore_casuale())

func lancia_mossa(nemico: Dictionary, mossa: Dictionary) -> void:
	# una mossa telegrafata non parte adesso: si annuncia e arriva al prossimo
	# giro, garantita. Passa di qui qualunque strada l'abbia scelta - il
	# sorteggio o il giudizio - se no una mossa "telegrafata" scelta per
	# saggezza partirebbe senza avviso, e l'avviso e' meta' della sua ragione
	if mossa.get("telegrafata", false):
		nemico.mossa_in_carica = mossa
		scrivi_forte(String(mossa.get("testo_annuncio", "Qualcosa si sta caricando...")))
		return
	esegui_mossa(nemico, mossa)

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
	# UNA CREATURA NON SPRECA MAI LA SUA BATTUTA.
	#
	# Bru: "se si parla di ricarica della mossa e' ok - non puo' usare QUELLA
	# mossa per tre battute - ma se il nemico rimane fermo per tre battute non
	# va bene". Ed e' la stessa cosa detta due volte: una mossa che non puo'
	# fare quello che dice non deve partire, perche' se parte quella e' una
	# battuta buttata. Meglio un colpo normale che una scena che smentisce se'
	# stessa - e meglio un colpo normale che niente.
	#
	# Un solo posto che lo decide, perche' i modi di arrivare a una mossa sono
	# cinque (sorteggio pesato, giudizio, soglia di vita, disperazione, mossa
	# annunciata la battuta prima) e finche' il controllo stava solo dentro il
	# sorteggio gli altri quattro lo scavalcavano. Quello che qui torna false
	# non toglie il turno alla creatura: la fa cadere sul suo colpo normale
	# (vedi il fondo di turno_nemico_normale).
	match String(mossa.get("tipo", "")):
		"sacrificio":
			return not vivi_alleati_di(nemico).is_empty()
		"cura":
			# non ci si cura da pieni: e' la prima cosa che fa sembrare stupida
			# una creatura che dovrebbe sembrare astuta
			if String(mossa.get("bersaglio", "se_stesso")) == "alleato":
				return not alleato_piu_ferito(nemico).is_empty()
			return int(nemico.hp) < int(nemico.hp_max)
		"evoca":
			# il campo tiene tre creature: chiamarne una quarta stampava
			# "...ma nessuno risponde al richiamo" e buttava via la battuta
			return vivi(false).size() < 3
		"difendi":
			# guardia gia' al massimo: "e' gia' chiuso quanto puo'" e basta
			return RegoleCombattimento.scatti_difesa(nemico) \
					< int(GameState.regole.get("difesa_scatti_massimi", 6))
		"modalita", "trasformazione":
			# non ci si chiude due volte, e non si annuncia due volte la stessa
			# trasformazione: sarebbe una battuta buttata a dire una cosa gia'
			# detta
			return Dictionary(nemico.get("modalita", {})).is_empty() \
					and Dictionary(nemico.get("trasformazione", {})).is_empty()
		"scena":
			# NON ALLE STRETTE. Una mossa che non fa niente e' una scelta di
			# regia finche' la creatura sta bene: sotto la soglia della
			# disperazione diventa il contrario di quello che Bru ha chiesto -
			# "quando sono a fin di vita devono capire la loro condizione e usare
			# le mosse saggiamente" - perche' guardarsi intorno mentre si muore
			# non e' capire niente
			return not RegoleCombattimento.e_disperata(nemico)
		"potenziamento":
			# stessa regola dei buff singoli: finche' e' su, rifarlo non aggiunge
			# niente. Basta che UNO dei bersagli non ce l'abbia gia'
			for chi in bersagli_del_potenziamento(nemico, mossa):
				var gia_addosso := false
				for buff in chi.buffs:
					if String(buff.get("fonte", "")) == chiave_mossa(mossa):
						gia_addosso = true
						break
				if not gia_addosso:
					return true
			return false
		"tormento":
			# se il vento c'e' gia', rilanciarlo e' una battuta buttata
			for combattente in vivi(true):
				if String(combattente.get("combustione", {}).get("fonte", "")) \
						!= String(nemico.get("id", "")):
					return true
			return false
		"buff_attacco", "buff_difesa":
			# QUESTO E' NUOVO, ED E' COLPA DEL RIMEDIO PRECEDENTE. Da quando lo
			# stesso potenziamento si rinnova invece di sommarsi, rifarlo mentre
			# e' ancora acceso non aggiunge piu' niente: prima era una somma
			# senza tetto, adesso sarebbe una battuta a vuoto. Finche' e' su, la
			# mossa non c'e'
			for buff in nemico.buffs:
				if String(buff.get("fonte", "")) == chiave_mossa(mossa):
					return false
			return true
		"stato":
			# se sono gia' tutti conciati cosi' (o tutti immuni), non fa niente
			var id_stato := String(mossa.get("stato", ""))
			for chiunque in vivi(true):
				if RegoleCombattimento.resistenza_di(chiunque, id_stato) == "immune":
					continue
				if not RegoleCombattimento.ha_stato_attivo(chiunque, id_stato):
					return true
			return false
		"incendia":
			# da quando le Fiamme sono uno status, la domanda "c'e' qualcuno da
			# incendiare" si fa agli stati e non piu' al vecchio in_fiamme, che
			# nessuno accende piu'. Guardando il posto sbagliato la mossa
			# risultava sempre disponibile e Jerah passava sette battute su
			# ventiquattro a dare fuoco a chi bruciava gia'
			for chiunque in vivi(true):
				if not RegoleCombattimento.ha_stato_attivo(chiunque, "fiamme") \
						and RegoleCombattimento.resistenza_di(chiunque, "fiamme") != "immune":
					return true
			return false
	return true

# --- LE MOSSE SI SCELGONO, NON SI SORTEGGIANO SOLTANTO ------------------------
#
# Bru: "dobbiamo dare un set di attacchi a ogni nemico che o fanno danno o fanno
# cose... quando i nemici sono a fin di vita diventano piu' ostici, devono capire
# la loro condizione e usare le mosse a loro disposizione saggiamente, per
# esempio se hanno pochi punti vita devono capirlo e se hanno attacchi che li
# curano o abilita' le attivano".
#
# Il sorteggio pesato resta - e' quello che rende uno scontro diverso dal
# precedente - ma sopra ci sta un giudizio. Ogni mossa puo' dichiarare:
#
#   "quando"    le condizioni perche' sia anche solo possibile. Una mossa fuori
#               condizione non entra nemmeno nel sorteggio, quindi non serve
#               sperare che il caso non la peschi al momento sbagliato.
#   "priorita"  se e' > 0 e le condizioni ci sono, la mossa si SCEGLIE invece di
#               sorteggiarla (vince la piu' alta). E' qui che vive la saggezza:
#               una cura a priorita' alta sotto il 30% di vita non e' una
#               possibilita' su cinque, e' quello che una creatura ferita FA.
#   "ricarica"  quante sue battute deve aspettare prima di rifarla. Senza, una
#               cura con priorita' alta si ricurerebbe all'infinito e lo scontro
#               non finirebbe mai - e non "sarebbe difficile": non finirebbe.
#
# Tutto quello che decide se una mossa e' disponibile sta in mossa_disponibile,
# e ci passano sia il giudizio sia il sorteggio. Erano due elenchi di controlli
# somiglianti, e i due elenchi divergevano.

func chiave_mossa(mossa: Dictionary) -> String:
	return String(mossa.get("id", mossa.get("nome", mossa.get("tipo", "?"))))

const CASELLA_LIBERA := "-"

func casella_libera(mossa: Dictionary) -> bool:
	# SEI CASELLE PER OGNI CREATURA, anche a chi ne servono tre. Bru: "voglio
	# vedere nel file 6 mosse di cui 3 tutte '-', non perche' sia una mossa ma
	# per ordine mentale mio, cosi' decido quante ne ha ognuno alla fine".
	#
	# Una casella libera non e' una mossa debole: NON ESISTE. Se il sorteggio
	# potesse pescarla, quella creatura passerebbe una battuta a non fare niente
	# - che e' esattamente la cosa che abbiamo appena tolto di mezzo. Si riconosce
	# dal tipo, che e' un trattino: nessun ramo di esegui_mossa lo esegue, e
	# mossa_disponibile lo scarta prima di guardare qualunque altra cosa.
	return String(mossa.get("tipo", "")) == CASELLA_LIBERA

func condizioni_mossa(nemico: Dictionary, mossa: Dictionary) -> bool:
	var quando: Dictionary = mossa.get("quando", {})
	if quando.is_empty():
		return true
	var vita := float(nemico.hp) / maxf(float(nemico.get("hp_max", 1)), 1.0)
	if quando.has("vita_sotto") and vita > float(quando["vita_sotto"]):
		return false
	if quando.has("vita_sopra") and vita < float(quando["vita_sopra"]):
		return false
	if quando.has("alleati_almeno") \
			and vivi_alleati_di(nemico).size() < int(quando["alleati_almeno"]):
		return false
	if quando.has("alleati_al_massimo") \
			and vivi_alleati_di(nemico).size() > int(quando["alleati_al_massimo"]):
		return false
	if quando.has("battuta_almeno") \
			and int(nemico.get("battute", 0)) < int(quando["battuta_almeno"]):
		return false
	if quando.has("dopo_mossa") and String(quando["dopo_mossa"]) not in nemico.get("mosse_usate", []):
		# "solo se ha attaccato con Simulazione Ouroboros": una mossa che esiste
		# soltanto come SEGUITO di un'altra. Il Divoratore si consuma da solo per
		# rimettersi in piedi, ma solo dopo essersi chiuso - se no e' un gesto
		# senza la scena che lo precede
		return false
	if quando.has("dopo_rinascita") \
			and bool(nemico.get("gia_rinato", false)) != bool(quando["dopo_rinascita"]):
		# "dopo essere rinato": la Benedizione del colosso non esiste finche' non
		# lo hai gia' abbattuto una volta. E' la seconda meta' dello scontro che
		# si apre solo dopo la prima
		return false
	if quando.has("senza_stato") and RegoleCombattimento.ha_stato_attivo(
			nemico, String(quando["senza_stato"])):
		return false
	if quando.has("bersaglio_vita_sotto"):
		# finire un ferito e' una decisione, non un caso: la mossa esiste solo
		# quando qualcuno di la' e' davvero a terra
		var trovato := false
		for chiunque in vivi(true):
			if float(chiunque.hp) / maxf(float(chiunque.get("hp_max", 1)), 1.0) \
					<= float(quando["bersaglio_vita_sotto"]):
				trovato = true
				break
		if not trovato:
			return false
	return true

func mossa_disponibile(nemico: Dictionary, mossa: Dictionary) -> bool:
	if casella_libera(mossa):
		return false   # e' un posto vuoto nell'elenco, non una mossa
	if mossa.get("una_tantum", false) and chiave_mossa(mossa) in nemico.mosse_usate:
		return false
	# "MASSIMO 2 VOLTE PER COMBATTIMENTO": una_tantum e' il caso N=1 di questo, e
	# il Bis di rottami e' il motivo per cui serviva il caso generale - due volte
	# ha senso ("one more time" detto due volte e' una gag), tre no
	if mossa.has("massimo_usi") and usi_della_mossa(nemico, mossa) >= int(mossa["massimo_usi"]):
		return false
	if int(nemico.get("ricariche_mosse", {}).get(chiave_mossa(mossa), 0)) > 0:
		return false
	if mossa.has("richiede_non_flag") and GameState.ha_flag(String(mossa["richiede_non_flag"])):
		return false  # qualcosa, nella storia, gli ha tolto questa possibilita'
	if mossa.has("richiede_flag") and not GameState.ha_flag(String(mossa["richiede_flag"])):
		return false
	if not mossa_eseguibile(nemico, mossa):
		return false
	return condizioni_mossa(nemico, mossa)

func mossa_saggia(nemico: Dictionary) -> Dictionary:
	# quello che una creatura in QUELLA condizione sceglie di fare. Fra pari
	# priorita' decide il caso: due risposte ugualmente sensate non devono
	# diventare una sequenza che si impara a memoria
	var migliori: Array[Dictionary] = []
	var massima := 0
	for mossa in nemico.mosse:
		var quanto := int(mossa.get("priorita", 0))
		if quanto <= 0 or not mossa_disponibile(nemico, mossa):
			continue
		if quanto > massima:
			massima = quanto
			migliori = [mossa]
		elif quanto == massima:
			migliori.append(mossa)
	if migliori.is_empty():
		return {}
	return migliori[GameState.rng.randi_range(0, migliori.size() - 1)]

func scala_ricariche(nemico: Dictionary) -> void:
	var ricariche: Dictionary = nemico.get("ricariche_mosse", {})
	for chiave in ricariche.keys():
		ricariche[chiave] = maxi(int(ricariche[chiave]) - 1, 0)

func alleato_piu_ferito(nemico: Dictionary) -> Dictionary:
	var scelto: Dictionary = {}
	var peggio := 1.0
	for alleato in vivi_alleati_di(nemico):
		var quota := float(alleato.hp) / maxf(float(alleato.get("hp_max", 1)), 1.0)
		if quota < peggio and quota < 1.0:
			peggio = quota
			scelto = alleato
	return scelto

func stati_di(mossa: Dictionary) -> Array[String]:
	# "stato": uno solo, com'e' sempre stato. "stati": una lista. Le due forme
	# convivono perche' riscrivere trenta mosse per farne funzionare una sarebbe
	# stato un modo di introdurre difetti dove non ce n'erano
	var elenco: Array[String] = []
	for voce in mossa.get("stati", []):
		if String(voce) != "":
			elenco.append(String(voce))
	if elenco.is_empty() and String(mossa.get("stato", "")) != "":
		elenco.append(String(mossa["stato"]))
	return elenco

func usi_della_mossa(nemico: Dictionary, mossa: Dictionary) -> int:
	var quanti := 0
	for usata in nemico.get("mosse_usate", []):
		if String(usata) == chiave_mossa(mossa):
			quanti += 1
	return quanti

func avanza_modalita(chi: Dictionary) -> void:
	# UNA BATTUTA DELLA MODALITA'. Scorre all'inizio del suo turno, come tutto
	# il resto che si misura in battute: cosi' "per 3 turni" vuol dire tre volte
	# che tocca a lui, e non tre secondi - la stessa regola dei potenziamenti
	var modalita: Dictionary = chi.get("modalita", {})
	if modalita.is_empty():
		return
	for stat in modalita.get("stat", {}):
		RegoleCombattimento.applica_buff(chi, String(stat),
				int(modalita["stat"][stat]) * (int(modalita.get("passate", 0)) + 1),
				99, "modalita_%s" % String(modalita.get("id", "")))
	var quota: float = float(modalita.get("cura_quota", 0.0))
	if quota > 0.0 and int(chi.hp) > 0:
		var quanto := maxi(int(round(float(chi.hp_max) * quota)), 1)
		var prima := int(chi.hp)
		chi.hp = mini(prima + quanto, int(chi.hp_max))
		if int(chi.hp) > prima:
			scrivi("[i]%s si rimette insieme: +%d.[/i]" % [chi.nome, int(chi.hp) - prima])
	if String(modalita.get("testo_battuta", "")) != "":
		scrivi("[i]%s[/i]" % String(modalita["testo_battuta"]))
	modalita.passate = int(modalita.get("passate", 0)) + 1
	modalita.battute = int(modalita.get("battute", 1)) - 1
	if int(modalita.battute) <= 0:
		# I POTENZIAMENTI DELLA MODALITA' SE NE VANNO CON LEI. Restano attaccati
		# alla fonte "modalita_<id>", quindi si tolgono per nome: se restassero,
		# una forma "per tre turni" sarebbe per sempre
		var rimasti: Array = []
		for buff in chi.buffs:
			if not String(buff.get("fonte", "")).begins_with("modalita_"):
				rimasti.append(buff)
		chi.buffs = rimasti
		if String(modalita.get("testo_fine", "")) != "":
			scrivi_forte("[i]%s[/i]" % String(modalita["testo_fine"]))
		chi.modalita = {}
	aggiorna_scheda(chi)

func avanza_trasformazione(chi: Dictionary) -> void:
	var conto: Dictionary = chi.get("trasformazione", {})
	if conto.is_empty():
		return
	conto.battute = int(conto.get("battute", 1)) - 1
	if int(conto.battute) > 0:
		return
	chi.trasformazione = {}
	var diventa := String(conto.get("diventa", ""))
	if diventa == "" or not GameState.personaggi.has(diventa):
		return
	scrivi_forte("[i]%s[/i]" % String(conto.get("testo", "Non è più quello di prima.")))
	# quello che teneva acceso se ne va con lui, come quando cade: trasformarsi
	# e' uscire di scena, e _su_ko qui non passa
	spegni_tormento_di(chi)
	# ESCE DI SCENA E NE ENTRA UN'ALTRA. Non e' una cura e non e' una rinascita:
	# la creatura che avevi davanti non c'e' piu', e quella nuova entra intera.
	# La vecchia si toglie senza dare esperienza, perche' non l'hai battuta
	chi.hp = 0
	chi.trasformato = true
	aggiorna_scheda(chi)
	aggiungi_combattente(diventa, false)

func bersagli_del_potenziamento(nemico: Dictionary, mossa: Dictionary) -> Array:
	# "se_stesso" (il difetto), "alleati" (i suoi compagni, non lui), "tutti"
	if String(mossa.get("bersaglio", "se_stesso")) == "se_stesso":
		return [nemico]
	var squadra := vivi_alleati_di(nemico)
	if String(mossa.get("bersaglio", "")) == "tutti":
		squadra.append(nemico)
	return squadra

func paga_di_persona(chi: Dictionary, mossa: Dictionary) -> void:
	# Il colpo che costa a chi lo tira: "un colpo pesante su uno solo E SE
	# STESSO". Si paga in frazione della propria vita massima, non in punti, se
	# no a livello alto il prezzo sparisce. Non si suicida: resta sempre a 1,
	# perche' una mossa che ti uccide da sola la creatura non dovrebbe sceglierla
	if not mossa.has("costo_vita"):
		return
	var prezzo := maxi(int(round(float(chi.get("hp_max", 1))
			* float(mossa["costo_vita"]))), 1)
	var pagato := mini(prezzo, maxi(int(chi.hp) - 1, 0))
	if pagato <= 0:
		return
	chi.hp = int(chi.hp) - pagato
	scrivi_con_colpo("[i]%s ci rimette anche di suo.[/i]" % chi.nome, chi, pagato)
	aggiorna_scheda(chi)

func spegni_tormento_di(chi: Dictionary) -> void:
	# IL TORMENTO MUORE CON CHI LA TIENE ACCESA. Bru: "infligge danni a ogni inizio
	# turno di ogni avversario finche' non viene sconfitto l'utilizzatore".
	# Senza questo, il vento tagliente dell'Emblema restava addosso alla squadra
	# per tutto il resto dello scontro - e nello scontro dopo sarebbe sembrato
	# un bug del veleno
	var fonte := String(chi.get("id", ""))
	if fonte == "":
		return
	for combattente in combattenti:
		var comb: Dictionary = combattente.get("combustione", {})
		if String(comb.get("fonte", "")) != fonte:
			continue
		combattente.combustione = {}
		combattente.in_fiamme = false
		aggiorna_scheda(combattente)
	scrivi("[i]Il vento si ferma.[/i]")

func valore_mossa(nemico: Dictionary, mossa: Dictionary) -> int:
	# QUANTO PICCHIA UNA MOSSA, E DA DOVE ESCE IL NUMERO.
	#
	# "quota" e' una frazione dell'attacco che quella creatura ha ADESSO: cosi'
	# una mossa resta calibrata a ogni livello, anche quando il disallineamento
	# tira su la creatura di dieci livelli sopra il suo - e ricalibrare il gioco
	# resta una riga in ruoli.json, che era tutto il punto della curva dei ruoli.
	# Un "valore" scritto a mano vince lo stesso, ma e' un'eccezione dichiarata:
	# il documento dei nemici la segnala una per una.
	if mossa.has("valore"):
		return int(mossa["valore"])
	if mossa.has("quota_a_terra"):
		# PIU' E' RIDOTTA MALE, PIU' FA MALE. Bru: "un colpo pesante su uno solo
		# che e' piu' potente quanto piu' bassa e' la vita". La quota va da
		# "quota" a piena vita a "quota_a_terra" a zero, per gradi: non e' un
		# interruttore alla soglia della disperazione, e' una rampa - cosi' la
		# creatura diventa piu' pericolosa mentre la stai battendo, e si sente
		var pieno := maxf(float(nemico.get("hp_max", 1)), 1.0)
		var quanto_manca := clampf(1.0 - float(nemico.get("hp", 0)) / pieno, 0.0, 1.0)
		var minima := float(mossa.get("quota", 1.0))
		var massima := float(mossa["quota_a_terra"])
		return maxi(int(round(RegoleCombattimento.attacco_di(nemico)
				* (minima + (massima - minima) * quanto_manca))), 1)
	if mossa.has("quota"):
		return maxi(int(round(RegoleCombattimento.attacco_di(nemico) * float(mossa["quota"]))), 1)
	return -1   # come un colpo normale suo

func esegui_mossa(nemico: Dictionary, mossa: Dictionary) -> void:
	scrivi("[i]%s[/i]" % mossa.get("testo", ""))
	# QUALE MOSSA HA APPENA FATTO. Serve a chi guarda da fuori (le prove) per
	# distinguere le due battute che a schermo si somigliano: quella in cui non
	# e' successo niente perche' la creatura ha scelto una scena, e quella in cui
	# non e' successo niente perche' una mossa ha promesso e non ha mantenuto.
	# La seconda e' un difetto, la prima e' regia - e senza questa riga sono
	# indistinguibili, perche' tutte e due scrivono la loro frase e basta
	nemico.ultima_mossa_tipo = String(mossa.get("tipo", ""))
	if mossa.get("una_tantum", false) or mossa.has("massimo_usi"):
		# il conto serve anche a "massimo_usi", e a "dopo_mossa": una condizione
		# che chiede "solo se ha gia' fatto quella" ha bisogno che quella si sia
		# lasciata dietro una traccia
		nemico.mosse_usate.append(chiave_mossa(mossa))
	if int(mossa.get("ricarica", 0)) > 0:
		# la rimette in canna fra tante sue battute. Senza, una cura scelta per
		# priorita' tornerebbe a essere la scelta migliore anche il giro dopo, e
		# quello dopo ancora: lo scontro non diventerebbe difficile, diventerebbe
		# infinito
		var ricariche: Dictionary = nemico.get("ricariche_mosse", {})
		ricariche[chiave_mossa(mossa)] = int(mossa["ricarica"])
		nemico.ricariche_mosse = ricariche
	match mossa.get("tipo", ""):
		"difendi":
			difendi(nemico)
		"attacco_forte":
			var vittima_forte := bersaglio_giocatore_casuale()
			attacca(nemico, vittima_forte, valore_mossa(nemico, mossa),
					1.0, String(mossa.get("elemento", "")))
			if mossa.has("stato") and not vittima_forte.is_empty() and vittima_forte.hp > 0:
				applica_stato(vittima_forte, String(mossa["stato"]))
			apri_la_guardia(vittima_forte, mossa)
			paga_di_persona(nemico, mossa)
		"spezza_guardia":
			# un colpo che non fa piu' male degli altri, ma ti apre: e' la
			# risposta del gioco a chi si chiude e non si muove piu'
			var vittima_guardia := bersaglio_giocatore_casuale()
			attacca(nemico, vittima_guardia, valore_mossa(nemico, mossa),
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
				attacca(nemico, bersaglio_giocatore_casuale(), valore_mossa(nemico, mossa),
						1.0, String(mossa.get("elemento", "")))
		"buff_attacco":
			RegoleCombattimento.applica_buff(nemico, "attacco", int(mossa.get("valore", 1)),
					int(mossa.get("turni", 2)), chiave_mossa(mossa))
			aggiorna_scheda(nemico)
		"potenziamento":
			# UN POTENZIAMENTO CHE TOCCA PIU' COSE INSIEME, e puo' anche togliere.
			# buff_attacco e buff_difesa sanno alzare una statistica sola, e le
			# mosse che Bru ha scritto ne muovono due o tre per volta ("Ultima
			# risorsa: aumenta velocita' difesa attacco", "Moan: aumenta attacco
			# considerevolmente, diminuisce leggermente la velocita'"). Spezzarle
			# in tre mosse avrebbe voluto dire tre battute per fare una cosa sola.
			#
			# Puo' anche potenziare GLI ALTRI ("Incitamento delle masse: aumenta
			# la velocita' degli altri suoi compagni"), ed e' la prima mossa del
			# bestiario che guarda la squadra invece di se' stessa
			for chi in bersagli_del_potenziamento(nemico, mossa):
				for stat in mossa.get("stat", {}):
					RegoleCombattimento.applica_buff(chi, String(stat),
							int(mossa["stat"][stat]), int(mossa.get("turni", 3)),
							chiave_mossa(mossa))
				aggiorna_scheda(chi)
		"modalita":
			# SI CHIUDE IN UNA FORMA, E PER QUALCHE BATTUTA E' UN'ALTRA COSA.
			# Bru, sulla Simulazione Ouroboros: "immune per 3 turni, ogni turno
			# aumenta attacco e difesa, diminuisce velocita' e ripristina il 15%
			# di vita". E sull'Autoriciclaggio, che e' la stessa macchina al
			# contrario: "per quattro turni comincia a perdere attacco e difesa
			# ma recupera il 25% di vita".
			#
			# Non e' un potenziamento, che si applica una volta e scade: e' uno
			# STATO CHE LAVORA, una battuta per volta. Il conto scorre in
			# avanza_modalita, all'inizio di ogni sua battuta
			nemico.modalita = {
				"id": chiave_mossa(mossa),
				"nome": String(mossa.get("nome", "")),
				"battute": int(mossa.get("durata", 3)),
				"stat": mossa.get("per_battuta", {}).get("stat", {}),
				"cura_quota": float(mossa.get("per_battuta", {}).get("cura_quota", 0.0)),
				"testo_battuta": String(mossa.get("testo_battuta", "")),
				"testo_fine": String(mossa.get("testo_fine", "")),
			}
			if bool(mossa.get("immune", false)):
				# ESATTAMENTE quanto dura la forma, non una battuta di piu'.
				# Modalita' e immunita' scorrono nella stessa battuta - prima
				# avanza_modalita, subito dopo il conto dell'immunita' - quindi
				# con "durata" tutte e due finiscono insieme. Con "durata + 1"
				# restava intoccabile per una battuta dopo essersi riaperta, e a
				# schermo era solo un colpo che spariva senza motivo
				nemico.turni_immune = int(mossa.get("durata", 3))
			aggiorna_scheda(nemico)
		"trasformazione":
			# NON DIVENTA SUBITO: annuncia, e il conto parte. "Hai 5 turni prima
			# che si trasformi in un altro nemico" - cinque battute per decidere
			# se abbatterlo prima o prepararsi a un'altra cosa
			nemico.trasformazione = {
				"diventa": String(mossa.get("diventa", "")),
				"battute": int(mossa.get("battute", 5)),
				"testo": String(mossa.get("testo_trasforma", "Non è più quello di prima.")),
			}
			aggiorna_scheda(nemico)
		"scena":
			# NON FA NIENTE, E LO FA APPOSTA. Una casella che esiste solo per il
			# suo motto: lo Zombie Cittadino che si guarda intorno senza scopo,
			# l'Orrore che si ferma a guardare il cielo. E' l'unico modo che ha
			# il gioco di dire "questa cosa non ti sta pensando".
			#
			# Non e' la battuta sprecata da cui ci si guardava: quella era una
			# mossa che PROMETTEVA un effetto e non riusciva a farlo. Questa non
			# promette niente. Ma alle strette non si sceglie mai - vedi
			# mossa_eseguibile - perche' una creatura che sta per morire e si
			# guarda intorno smentisce la regola che la fa diventare pericolosa
			pass
		"tormento":
			# Colpisce tutta la squadra a ogni loro battuta, e NON SMETTE finche'
			# non cade chi l'ha lanciata: e' quello che Bru ha chiesto per l'Astio
			# Infinito. Passa per la combustione, che e' la macchina che gia'
			# esisteva per "qualcosa ti fa male a ogni tuo turno": non ne serviva
			# una seconda, serviva solo dirle chi la tiene accesa
			var quanto_tormento := maxi(int(round(RegoleCombattimento.attacco_di(nemico)
					* float(mossa.get("quota_per_turno", 0.25)))), 1)
			for bersaglio_tormento in vivi(true):
				bersaglio_tormento.combustione = {
					"danno_per_turno": quanto_tormento,
					"testo_turno": String(mossa.get("testo_turno", "Il vento tagliente non passa.")),
					"elemento": String(mossa.get("elemento", "oscuro")),
					"fonte": String(nemico.get("id", "")),
				}
				bersaglio_tormento.in_fiamme = true
				aggiorna_scheda(bersaglio_tormento)
		"incendia":
			# LE FIAMME SONO UNO STATUS, adesso. Prima appiccavano una combustione
			# a mano: un danno che nessuno poteva curare, a cui nessuno poteva
			# essere immune, e che non compariva nella scheda. Bru le voleva fra
			# gli otto - "danno continuo ogni turno, e' il danno nel tempo piu'
			# forte" - e da status prende tutto il resto gratis: durata, cura,
			# resistenze, e il nome scritto addosso a chi brucia.
			#
			# La combustione resta dov'era, ma solo per chi brucia di suo
			# (Fomentado): quella non e' una cosa che subisci, e' quello che sei
			var possibili_bersagli := vivi(true)
			if not possibili_bersagli.is_empty():
				applica_stato(possibili_bersagli[GameState.rng.randi_range(0, possibili_bersagli.size() - 1)], "fiamme")
		"attacco_tutti":
			if mossa.has("quota_vita_bersaglio"):
				# UNA FRAZIONE DI QUELLO CHE TI RESTA, non del suo attacco: e' la
				# Discesa colossale, che si annuncia una battuta prima e poi si
				# porta via quasi tutto. Non passa dalla difesa - contro un colpo
				# grosso quanto una casa la corazza non c'entra - ma non uccide:
				# lascia sempre un punto, perche' un colpo che azzera la squadra
				# senza che tu possa farci niente non e' una boss fight, e' un
				# filmato
				var frazione := clampf(float(mossa["quota_vita_bersaglio"]), 0.0, 0.99)
				for bersaglio_vita in vivi(true):
					var tolto := maxi(int(round(float(bersaglio_vita.hp) * frazione)), 1)
					bersaglio_vita.hp = maxi(int(bersaglio_vita.hp) - tolto, 1)
					scrivi_con_colpo("[i]%s viene travolto.[/i]" % bersaglio_vita.nome,
							bersaglio_vita, tolto, String(mossa.get("elemento", "")))
					aggiorna_scheda(bersaglio_vita)
				paga_di_persona(nemico, mossa)
				return
			for bersaglio in vivi(true):
				attacca(nemico, bersaglio, valore_mossa(nemico, mossa),
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
		"cura":
			# SE SA CURARSI, QUANDO STA PER CADERE SI CURA. Bru: "se hanno pochi
			# punti vita devono capirlo, e se hanno attacchi che li curano o
			# abilita' le attivano". Il capirlo sta in "quando" e "priorita";
			# qui c'e' solo il gesto. Cura una quota della vita MASSIMA di chi
			# la riceve, non un numero fisso: cosi' vale uguale a ogni livello
			var curato := nemico
			if String(mossa.get("bersaglio", "se_stesso")) == "alleato":
				curato = alleato_piu_ferito(nemico)
			if curato.is_empty():
				return
			var quanto := maxi(int(round(float(curato.hp_max)
					* float(mossa.get("quota_vita", 0.25)))), 1)
			var prima_cura := int(curato.hp)
			curato.hp = mini(prima_cura + quanto, int(curato.hp_max))
			var rimesso := int(curato.hp) - prima_cura
			if rimesso > 0:
				var scheda_curato: Control = curato.scheda
				scrivi("[i]%s si rimette insieme: +%d.[/i]" % [curato.nome, rimesso])
				voce.accoda_effetto(func() -> void:
					voce.suono("cura")
					voce.numero_volante(scheda_curato, "+%d" % rimesso, Stile.colore("positivo"))
					aggiorna_scheda(curato))
		"rubavita":
			# colpisce e si rimette in piedi con quello che ha tolto: e' la mossa
			# che rende davvero pericolosa una creatura ferita, perche' picchiarla
			# e basta smette di bastare
			var vittima_furto := bersaglio_giocatore_casuale()
			if vittima_furto.is_empty():
				return
			var vita_prima := int(vittima_furto.hp)
			attacca(nemico, vittima_furto, valore_mossa(nemico, mossa),
					1.0, String(mossa.get("elemento", "")))
			var rubato := int(round((vita_prima - int(vittima_furto.hp))
					* float(mossa.get("quota_furto", 0.5))))
			if rubato > 0 and int(nemico.hp) > 0:
				var scheda_ladro: Control = nemico.scheda
				nemico.hp = mini(int(nemico.hp) + rubato, int(nemico.hp_max))
				scrivi("[i]%s se ne nutre: +%d.[/i]" % [nemico.nome, rubato])
				voce.accoda_effetto(func() -> void:
					voce.numero_volante(scheda_ladro, "+%d" % rubato, Stile.colore("positivo"))
					aggiorna_scheda(nemico))
		"stato":
			# nessun danno: solo quello che ti lascia addosso. Una mossa che "fa
			# cose" invece di fare male, ed e' meta' di quello che Bru ha chiesto
			var vittima_stato := bersaglio_giocatore_casuale()
			if not vittima_stato.is_empty():
				# UNA MOSSA PUO' LASCIARE PIU' DI UNA COSA ADDOSSO. L'Assolo
				# metallico "infligge confusione E berserk": due mosse separate
				# sarebbero due battute per fare una cosa sola, e a schermo due
				# righe per un suono solo
				for id_stato in stati_di(mossa):
					applica_stato(vittima_stato, id_stato,
							int(mossa.get("valore_stato", 1)))
			if mossa.has("stress"):
				for chiunque in vivi(true):
					aggiungi_stress(chiunque, int(mossa.stress))
		"buff_difesa":
			RegoleCombattimento.applica_buff(nemico, "difesa", int(mossa.get("valore", 1)),
					int(mossa.get("turni", 2)), chiave_mossa(mossa))
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

# --- stati generici (data/stati.json): veleno, sonno,
# GLI OTTO STATUS: Terrore, Fiamme, Tossina, Sonno, Maledizione, Rabbia,
# Provocato, Frastornato. Piu' Rapidita'/Lentezza, che non sono status subiti
# ma modificatori di velocita' e servono alle armi. Ogni personaggio puo' dichiarare nei dati una chiave
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
		"riserva":
			# LA MALEDIZIONE NON E' PIU' UN CONTO ALLA ROVESCIA. Bru: "conto alla
			# rovescia basato sulla resistenza. Parte da 10, un attacco che da' 3
			# punti ti porta a 7. A zero vai KO e non puoi essere rianimato con
			# oggetti fino alla fine del combattimento".
			#
			# Prima scendeva DA SOLA di un punto a turno: bastava aspettare e
			# morivi, e i colpi maledetti erano decorazione. Adesso la riserva sta
			# ferma finche' qualcuno non la morde: e' l'attacco che la consuma,
			# e senza attacchi non succede niente.
			var attivo: Dictionary = bersaglio.stati_attivi.get(id_stato, {})
			var punti := maxi(int(valore), 1)
			if amplificato:
				punti *= 2
			if attivo.is_empty():
				# la resistenza alza il tetto, non riduce i punti: chi resiste ne
				# incassa altrettanti ma parte da piu' in alto
				var iniziale := int(info_stato.get("riserva_iniziale", 10)) \
						+ int(bersaglio.get("resistenza_maledizione", 0))
				attivo = {"riserva": iniziale, "iniziale": iniziale}
				bersaglio.stati_attivi[id_stato] = attivo
				scrivi_forte("%s %s" % [bersaglio.nome, String(info_stato.get("testo_applicazione", "viene maledetto."))])
			attivo.riserva = maxi(int(attivo.riserva) - punti, 0)
			scrivi("[i]%s (%d/%d)[/i]" % [String(info_stato.get("testo_consumo", "La maledizione morde.")),
					int(attivo.riserva), int(attivo.iniziale)])
			if int(attivo.riserva) <= 0:
				scrivi_forte("La maledizione si compie: %s non resiste oltre." % bersaglio.nome)
				bersaglio.hp = 0
				if bool(info_stato.get("ko_non_rianimabile", false)):
					# e resta giu'. Nessun oggetto lo rimette in piedi fino alla
					# fine dello scontro: e' quello che rende la maledizione una
					# minaccia invece di un danno con un nome lungo
					bersaglio.non_rianimabile = true
				aggiorna_scheda(bersaglio)
				_su_ko(bersaglio)
				return
		"sonno":
			# Bru: "immobile per massimo 3 turni... piu' subisci attacchi piu'
			# probabilita' hai di svegliarti". I colpi incassati mentre dorme si
			# contano qui sotto (vedi risolvi_stati_a_inizio_turno) e alzano il
			# tiro del risveglio: scuotere chi dorme funziona
			bersaglio.stati_attivi[id_stato] = {
				"turni_rimasti": int(info_stato.get("durata_massima", 3)) + (1 if amplificato else 0),
				"colpi_nel_sonno": 0}
			scrivi("[i]%s %s[/i]" % [bersaglio.nome, info_stato.get("testo_applicazione", "cade addormentato.")])
		"forza_attacco", "frastornato", "provocato":
			var durata := durata_dichiarata(info_stato)
			if amplificato:
				durata += 1
			var stato_nuovo := {"turni_rimasti": durata}
			if tipo == "provocato":
				# chi ti ha provocato: senza questo "solo lui" non vuol dire niente
				stato_nuovo["provocatore"] = String(bersaglio.get("id_provocatore", ""))
			bersaglio.stati_attivi[id_stato] = stato_nuovo
			scrivi("[i]%s %s[/i]" % [bersaglio.nome, info_stato.get("testo_applicazione", "subisce uno stato.")])
		"dot":
			# FIAMME E TOSSINA SONO LO STESSO MECCANISMO CON DUE TARATURE, non due
			# meccanismi. Il danno e' una quota della vita massima e non un numero
			# fisso: un 5 fisso e' letale al livello 1 e invisibile al 130.
			# Durata 0 = fino a fine scontro (la Tossina: "guarisci solo a fine
			# combattimento o se ti curi").
			var quota := float(info_stato.get("quota_vita_massima", 0.05))
			if amplificato:
				quota *= 2.0
			var danno_turno := maxi(int(round(int(bersaglio.get("hp_max", 1)) * quota)), 1)
			bersaglio.stati_attivi[id_stato] = {
				"danno": danno_turno,
				"turni_rimasti": durata_dichiarata(info_stato)}
			scrivi("[i]%s %s[/i]" % [bersaglio.nome, info_stato.get("testo_applicazione", "subisce uno stato.")])
		"velocita":
			bersaglio.stati_attivi[id_stato] = {"valore": int(info_stato.get("valore", 0))}
		"terrore":
			# Bru: "indebolimento temporaneo del personaggio e impossibilita' di
			# fare critico". Prima faceva solo stress e legame - due numeri fuori
			# dallo scontro - e in campo non cambiava niente
			var durata_terrore := durata_dichiarata(info_stato)
			if amplificato:
				durata_terrore += 1
			bersaglio.stati_attivi[id_stato] = {"turni_rimasti": durata_terrore}
			var incremento_stress := int(GameState.regole.get("terrore_stress_incremento", 40))
			var decremento_legame := int(GameState.regole.get("terrore_legame_decremento", -15))
			if amplificato:
				incremento_stress *= 2
				decremento_legame *= 2
			aggiungi_stress(bersaglio, incremento_stress)
			GameState.modifica_legame(decremento_legame)
			scrivi_forte("%s %s" % [bersaglio.nome, String(info_stato.get("testo_applicazione", "è paralizzato dal terrore."))])
	aggiorna_scheda(bersaglio)

func bersagli_ammessi(chi: Dictionary, candidati: Array[Dictionary]) -> Array[Dictionary]:
	# se qualcuno ti ha provocato, l'elenco si riduce a lui solo. Se e' caduto
	# nel frattempo torni libero: restare inchiodato a un morto bloccherebbe il
	# turno per tre battute
	var obbligato := RegoleCombattimento.bersaglio_obbligato(chi)
	if obbligato == "":
		return candidati
	var ristretto: Array[Dictionary] = []
	for c in candidati:
		if String(c.get("id", "")) == obbligato:
			ristretto.append(c)
	return ristretto if not ristretto.is_empty() else candidati

static func durata_dichiarata(info_stato: Dictionary) -> int:
	# uno stato dichiara "durata" fissa, oppure "durata_minima"/"durata_massima"
	# e la si tira. Zero vuol dire fino alla fine dello scontro
	if info_stato.has("durata"):
		return int(info_stato["durata"])
	var minimo := int(info_stato.get("durata_minima", 1))
	var massimo := int(info_stato.get("durata_massima", minimo))
	return GameState.rng.randi_range(minimo, maxi(massimo, minimo))

func risolvi_stati_a_inizio_turno(combattente: Dictionary) -> bool:
	# esegue countdown/salta-turno/dot a inizio turno; ritorna true se il
	# turno va saltato (Sonno) o se il personaggio muore prima di poter agire
	# (Fiamme e Tossina lo consumano, la Maledizione arriva a zero)
	var salta := false
	for id_stato in combattente.stati_attivi.keys().duplicate():
		var attivo: Dictionary = combattente.stati_attivi[id_stato]
		var info_stato: Dictionary = GameState.stati.get(id_stato, {})
		match String(info_stato.get("tipo", "")):
			"riserva":
				# non scende da sola: la consumano i colpi (vedi applica_stato).
				# Qui non c'e' niente da fare, ed e' voluto
				pass
			"sonno":
				# IL RISVEGLIO E' UN TIRO, e i colpi incassati lo alzano. Bru:
				# "piu' subisci attacchi piu' probabilita' hai di svegliarti".
				# Si tira PRIMA di saltare il turno: chi si sveglia adesso agisce
				# subito, invece di perdere anche la battuta del risveglio
				var soglia := float(info_stato.get("risveglio_base", 0.25)) \
						+ int(attivo.get("colpi_nel_sonno", 0)) * float(info_stato.get("risveglio_per_colpo", 0.30))
				if GameState.rng.randf() < soglia:
					combattente.stati_attivi.erase(id_stato)
					scrivi("[i]%s %s[/i]" % [combattente.nome, String(info_stato.get("testo_fine", "si sveglia."))])
					continue
				scrivi("[i]%s %s[/i]" % [combattente.nome, String(info_stato.get("testo_turno", "dorme."))])
				salta = true
				attivo.turni_rimasti = int(attivo.turni_rimasti) - 1
				if int(attivo.turni_rimasti) <= 0:
					combattente.stati_attivi.erase(id_stato)
					scrivi("[i]%s %s[/i]" % [combattente.nome, String(info_stato.get("testo_fine", "si sveglia."))])
			"forza_attacco", "frastornato", "provocato", "terrore":
				attivo.turni_rimasti = int(attivo.turni_rimasti) - 1
				if int(attivo.turni_rimasti) <= 0:
					combattente.stati_attivi.erase(id_stato)
					if info_stato.has("testo_fine"):
						scrivi("[i]%s %s[/i]" % [combattente.nome, String(info_stato["testo_fine"])])
			"dot":
				var danno := int(attivo.get("danno", 1))
				combattente.hp = maxi(combattente.hp - danno, 0)
				scrivi_con_colpo("[i]%s: %s[/i]" % [combattente.nome,
						String(info_stato.get("testo_turno", "Il male si fa sentire ancora."))],
						combattente, danno, String(info_stato.get("elemento", "")))
				if combattente.hp <= 0:
					_su_ko(combattente)
					return true
				# durata 0 = non scade: la Tossina resta finche' non ti curi o
				# finche' lo scontro non finisce
				if int(attivo.get("turni_rimasti", 0)) > 0:
					attivo.turni_rimasti = int(attivo.turni_rimasti) - 1
					if int(attivo.turni_rimasti) <= 0:
						combattente.stati_attivi.erase(id_stato)
						if info_stato.has("testo_fine"):
							scrivi("[i]%s[/i]" % String(info_stato["testo_fine"]))
	return salta

# --- risoluzione dei colpi ---

func attacca(attaccante: Dictionary, bersaglio: Dictionary, valore_attacco := -1,
		moltiplicatore := 1.0, elemento := "", bonus := 0) -> void:
	if elemento == "":
		elemento = elemento_di(attaccante)
	if attaccante.giocatore and attaccante.id == GameState.id_protagonista:
		GameState.registra_azione("attacchi_sferrati")
	# ogni colpo dato carica la barra: e' il modo piu' diretto di riempirla,
	# e il motivo per cui martellare sul nemico non e' solo danno
	RegoleCombattimento.riempi_dominio(attaccante, "per_attacco")
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
	if critico:
		RegoleCombattimento.riempi_dominio(attaccante, "per_critico")
	if esito.fattore:
		scrivi("Il dominio di %s arde!" % attaccante.nome)
	# L'EFFICACIA VA DETTA, o il tipo resta una scritta sulla scheda. Un colpo
	# che pesa il cinquanta per cento in piu' senza una riga che lo dica e' solo
	# un numero piu' grande, e il giocatore non ha modo di capire che e' stata
	# l'arma che ha in mano a farlo
	var efficacia := float(esito.get("efficacia", 1.0))
	if efficacia > 1.0:
		scrivi("[i]È il colpo giusto: %s lo incassa male.[/i]" % bersaglio.nome)
	elif efficacia <= 0.0:
		scrivi("[i]Non gli fa niente: %s non è fatto per essere colpito così.[/i]" % bersaglio.nome)
	if danno <= 0:
		# questo invece va detto: un colpo che non passa e' un'informazione,
		# non un evento da guardare
		scrivi("%s para il colpo di %s." % [bersaglio.nome, attaccante.nome])
		if bersaglio.giocatore:
			aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))
		return
	danno = smista_la_copertura(bersaglio, danno)
	bersaglio.hp = maxi(bersaglio.hp - danno, 0)
	trattieni_a_un_punto(bersaglio)
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
		# SCUOTERE CHI DORME FUNZIONA. Bru: "piu' subisci attacchi piu'
		# probabilita' hai di svegliarti". Il conto sta qui e non dentro il
		# Sonno perche' qui passa OGNI colpo incassato - attacco, veleno,
		# raffica - e svegliarsi solo per certi tipi di danno sarebbe una regola
		# che il giocatore non puo' vedere
		var sonno_attivo: Dictionary = bersaglio.stati_attivi.get("sonno", {})
		if not sonno_attivo.is_empty():
			sonno_attivo.colpi_nel_sonno = int(sonno_attivo.get("colpi_nel_sonno", 0)) + 1
		if bersaglio.giocatore and bersaglio.id == GameState.id_protagonista:
			GameState.registra_azione("danni_subiti", danno)
		# l'Astio si alimenta qui, e solo qui: un colpo incassato e' un colpo
		# incassato, che arrivi da un attacco, da un veleno o da una raffica
		alimenta_astio(bersaglio)
		# E ANCHE LA BARRA DI DOMINIO. Bru: "si riempie man mano che attacchi,
		# fai critici, uccidi nemici, VIENI COLPITO". Incassare carica: e' la
		# parte che rende sensato restare in mezzo invece di scappare
		RegoleCombattimento.riempi_dominio(bersaglio, "per_colpo_subito")
		segnala_disperazione(bersaglio)

func segnala_disperazione(creatura: Dictionary) -> void:
	# QUANDO UNA CREATURA PASSA IL CONFINE, SI DEVE VEDERE. Da qui in poi
	# colpisce piu' forte e comincia a scegliere invece di sorteggiare (vedi
	# mossa_saggia): se succedesse in silenzio, il giocatore sentirebbe solo che
	# "ha cominciato a fare piu' male" e lo scriverebbe alla sfortuna. Una volta
	# sola, alla prima discesa: e' un cambio di stato, non un ritornello
	if creatura.giocatore or bool(creatura.get("disperazione_detta", false)) \
			or not RegoleCombattimento.e_disperata(creatura):
		return
	creatura.disperazione_detta = true
	var testo := String(RegoleCombattimento.dati_disperazione().get("testo", ""))
	if testo != "":
		scrivi(testo % creatura.nome)

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
	if not caduto.giocatore:
		spegni_tormento_di(caduto)
	var rinascita: Dictionary = GameState.personaggi.get(caduto.id, {}).get("rinascita", {})
	if not caduto.giocatore and not rinascita.is_empty() \
			and not caduto.get("gia_rinato", false):
		# ANCORA QUI. Non e' l'invincibile, che non muore mai e trasforma lo
		# scontro in un muro: questa e' UNA VOLTA SOLA, e si vede. Torna su con
		# una fetta di vita, e da li' in poi e' mortale come chiunque - ma tu hai
		# gia' speso tutto per abbatterla la prima volta, ed e' li' che lo scontro
		# cambia faccia
		caduto.gia_rinato = true
		caduto.hp = maxi(int(round(float(caduto.hp_max)
				* float(rinascita.get("quota_vita", 0.25)))), 1)
		aggiorna_scheda(caduto)
		scrivi_forte(String(rinascita.get("testo", "[i]%s si rimette in piedi.[/i]")) % caduto.nome)
		return
	if not caduto.giocatore and GameState.personaggi.get(caduto.id, {}).get("invincibile", false):
		# non muore mai davvero: "sconfiggerlo" non basta, si rialza sempre
		caduto.hp = caduto.hp_max
		aggiorna_scheda(caduto)
		scrivi_forte("[i]%s si rialza, come se nulla fosse.[/i]" % caduto.nome)
		return
	if caduto.get("non_rianimabile", false):
		# CHI CADE PER MALEDIZIONE RESTA GIU'. Bru: "a zero vai KO e non puoi
		# essere rianimato con oggetti fino alla fine del combattimento". Il
		# controllo sta prima dell'accessorio apposta: se stesse dopo, la
		# resurrezione lo rimetterebbe in piedi e la maledizione sarebbe un
		# modo lento di fare danno invece che una minaccia
		scrivi_forte("[i]%s non si rialza: la maledizione lo tiene giù.[/i]" % caduto.nome)
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
	# abbattere qualcuno riempie la barra di chi resta in piedi dall'altra parte.
	#
	# La barra si alza e basta: NON si aggiorna la scheda qui. Farlo sembrava
	# innocuo e invece riaccendeva i ritratti prima che il box avesse raccontato
	# cosa era successo - il bug della bomba di Veronica, che una prova sorveglia
	# da mesi. Quello che si vede passa sempre dalla coda, mai da qui.
	for vincitore in vivi(not caduto.giocatore):
		RegoleCombattimento.riempi_dominio(vincitore, "per_uccisione")
	for alleato in vivi(caduto.giocatore):
		reagisci(alleato)
	if vivi(false).is_empty():
		giocatore_ha_vinto = true
		in_corso = false
		for combattente in combattenti:
			if combattente.giocatore or combattente.get("oggetto_scena", false):
				continue
			if combattente.get("trasformato", false):
				# NON L'HAI BATTUTA: SE N'E' ANDATA. Chi si trasforma lascia il
				# campo con zero punti vita, ed e' proprio la forma in cui la
				# battaglia la conta come caduta - quindi senza questa riga
				# abbattere il Golem pagava anche i Rottami da cui era nato:
				# esperienza doppia, Tazo doppi e due bottini per un nemico solo
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
		if c.get("trasformato", false):
			continue   # se n'e' andata trasformandosi: non c'e' niente da raccogliere
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
