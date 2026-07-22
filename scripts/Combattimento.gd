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
@onready var fila_nemici: HBoxContainer = %Nemici
@onready var etichetta_speranza: Label = %Speranza
@onready var diario: RichTextLabel = %Diario
@onready var azioni: HBoxContainer = %Azioni

var combattenti: Array[Dictionary] = []
var in_corso := true
var giocatore_ha_vinto := false
var xp_bottino := 0
var tazo_bottino := 0

var fonte: Dictionary = {}
var speranza := 0
var convinto := false
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

func _ready() -> void:
	for id_classe in GameState.party:
		aggiungi_combattente(id_classe, true)
	for id_nemico in GameState.nemici_combattimento:
		aggiungi_combattente(id_nemico, false)
		var dati: Dictionary = GameState.personaggi.get(id_nemico, {})
		if fonte.is_empty() and dati.get("fonte", false):
			fonte = dati
		if portatore_frenesia.is_empty() and dati.has("frenesia"):
			portatore_frenesia = dati
	scrivi("[b]Il Carnivalz fa spazio: si combatte.[/b]")
	if fonte.get("convincibile", false):
		etichetta_speranza.visible = true
		aggiorna_speranza(0)
	applica_leve()
	esegui_scontro()

func aggiungi_combattente(id_personaggio: String, giocatore: bool) -> void:
	var dati: Dictionary = GameState.personaggi.get(id_personaggio, {})
	var hp_max := int(dati.get("hp", GameState.regole.get("hp_base", 5)))
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
		fila_nemici.add_child(scheda)
		ritratto.mostra(id_personaggio)
		if dati.has("xp"):
			# voce nel bestiario al primo incontro (gli oggetti di scena non ne hanno)
			GameState.registra_bestiario(id_personaggio)
	var combattente := {
		"indice": combattenti.size(),
		"id": id_personaggio,
		"nome": dati.get("nome_breve", dati.get("nome", id_personaggio)),
		"hp": hp_max,
		"hp_max": hp_max,
		"attacco": int(dati.get("attacco", 1)),
		"difesa": int(dati.get("difesa", 0)),
		"velocita": int(dati.get("velocita", 3)),
		"psiche": String(dati.get("psiche", "")),
		"fattore": int(dati.get("fattore_base", 0)),
		"stress": GameState.stress_di(id_personaggio) if giocatore else 0,
		"xp": int(dati.get("xp", 10)),
		"tazo": int(dati.get("tazo", 0)),
		"carta": dati.get("carta", {}),
		"bottino_comune": dati.get("bottino_comune", []),
		"mosse": dati.get("mosse", []),
		"peso_attacco_normale": int(dati.get("peso_attacco_normale", 4)),
		"giocatore": giocatore,
		"stati": [],
		"buffs": [],
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
		if presente:
			scrivi("[i]%s[/i]" % leva.get("testo", ""))
			aggiorna_speranza(int(leva.get("speranza", 0)))

func aggiorna_speranza(quantita: int) -> void:
	if not fonte.get("convincibile", false):
		return
	speranza = clampi(speranza + quantita, 0, 100)
	etichetta_speranza.text = "Speranza %d / %d" % [speranza, int(fonte.get("speranza_soglia", 100))]
	if not convinto and speranza >= int(fonte.get("speranza_soglia", 100)):
		convinto = true
		scrivi("[b]%s[/b]" % fonte.get("testo_cedimento", "Qualcosa, nella fonte, ha ceduto."))

func esegui_scontro() -> void:
	while in_corso:
		# il cedimento cambia le velocita': l'iniziativa si ricalcola a ogni giro
		combattenti.sort_custom(func(a, b):
			return a.indice < b.indice if a.velocita == b.velocita else a.velocita > b.velocita)
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
	await get_tree().create_timer(1.4).timeout
	_esci()

func esegui_turno(attaccante: Dictionary) -> void:
	scadenza_buff(attaccante)
	evidenzia(attaccante)
	if attaccante.giocatore:
		attaccante_corrente = attaccante
		mostra_azioni()
		var azione: Dictionary = await azione_scelta
		match azione.get("tipo", ""):
			"attacca":
				attacca(attaccante, azione.bersaglio)
			"difendi":
				difendi(attaccante)
			"studia":
				studia(attaccante)
			"oggetto":
				usa_oggetto(attaccante, azione.id)
			"alleato":
				usa_alleato(azione.id)
	else:
		await get_tree().create_timer(0.8).timeout
		turno_nemico(attaccante)
	var passo := int(GameState.regole.get("stress_per_fattore", 25))
	var costo := floori(attaccante.fattore / float(maxi(passo, 1)))
	if costo > 0:
		attaccante.stress = clampi(attaccante.stress + costo, 0, 100)
		aggiorna_scheda(attaccante)

# --- menu azioni del giocatore ---

func pulisci_azioni() -> void:
	for figlio in azioni.get_children():
		figlio.queue_free()

func bottone_azione(testo: String, richiamo: Callable, spento := false) -> void:
	var bottone := Button.new()
	bottone.text = testo
	bottone.disabled = spento
	bottone.pressed.connect(richiamo)
	azioni.add_child(bottone)

func mostra_azioni() -> void:
	pulisci_azioni()
	bottone_azione("Attacca", _menu_bersagli)
	bottone_azione("Difenditi", _scegli.bind({"tipo": "difendi"}))
	bottone_azione("Abilità", _menu_abilita)
	bottone_azione("Oggetti", _menu_oggetti, GameState.sacca.is_empty())
	bottone_azione("Alleati", _menu_alleati, alleati_disponibili().is_empty())

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
	bottone_azione("Indietro", mostra_azioni)

func _menu_oggetti() -> void:
	pulisci_azioni()
	var conteggio := {}
	for id_oggetto in GameState.sacca:
		conteggio[id_oggetto] = int(conteggio.get(id_oggetto, 0)) + 1
	for id_oggetto in conteggio:
		var nome: String = GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)
		bottone_azione("%s ×%d" % [nome, conteggio[id_oggetto]],
				_scegli.bind({"tipo": "oggetto", "id": id_oggetto}))
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
	chi.buffs.append({
		"stat": "difesa",
		"valore": int(GameState.regole.get("difesa_difenditi", 2)),
		"turni": 1,
	})
	scrivi("%s si mette in guardia." % chi.nome)
	aggiorna_scheda(chi)

func usa_oggetto(chi: Dictionary, id_oggetto: String) -> void:
	var dati := GameState.dati_oggetto(id_oggetto)
	GameState.sacca.erase(id_oggetto)
	scrivi("%s usa: %s." % [chi.nome, dati.get("nome", id_oggetto)])
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
		utente.stress = clampi(utente.stress + int(effetto.stress), 0, 100)
		aggiorna_scheda(utente)
	if effetto.has("speranza"):
		aggiorna_speranza(int(effetto.speranza))
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
	var dati: Dictionary = GameState.personaggi.get(bersaglio.id, {})
	var scambi: Array = dati.get("studio", [])
	if convinto and bersaglio.id == fonte.get("id", "") and dati.has("studio_cedimento"):
		scambi = dati["studio_cedimento"]
	if scambi.is_empty():
		scrivi("%s studia %s: nessuna risposta, solo la musica sbagliata." % [chi.nome, bersaglio.nome])
	else:
		var scambio: Dictionary = scambi[indice_studio % scambi.size()]
		indice_studio += 1
		if scambio.has("osservazione"):
			scrivi("[i]%s[/i]" % scambio["osservazione"])
		else:
			scrivi("%s: \"%s\"" % [chi.nome, scambio.get("domanda", "")])
			scrivi("%s: \"%s\"" % [bersaglio.nome, scambio.get("risposta", "")])
	GameState.segna_studiato(bersaglio.id)
	if bersaglio.id == fonte.get("id", ""):
		aggiorna_speranza(int(GameState.regole.get("speranza_studio", 10)))

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

func primo_nemico() -> Dictionary:
	# la fonte ha la precedenza, altrimenti il primo nemico vivo
	for combattente in vivi(false):
		if combattente.id == fonte.get("id", ""):
			return combattente
	var nemici := vivi(false)
	return nemici[0] if not nemici.is_empty() else {}

# --- turno nemico e mosse ---

func turno_nemico(nemico: Dictionary) -> void:
	if not portatore_frenesia.is_empty() and nemico.id == portatore_frenesia.id:
		gestisci_turno_frenesia(nemico)
		return
	turno_nemico_normale(nemico)

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

func turno_nemico_normale(nemico: Dictionary) -> void:
	if convinto and nemico.id == fonte.get("id", "") \
			and GameState.rng.randf() < float(GameState.regole.get("probabilita_cedimento", 0.5)):
		cedimento(nemico)
		return
	var mosse: Array = nemico.mosse
	if not mosse.is_empty():
		var totale: int = int(nemico.peso_attacco_normale)
		for mossa in mosse:
			totale += int(mossa.get("peso", 1))
		var estratto := GameState.rng.randi_range(1, maxi(totale, 1))
		for mossa in mosse:
			estratto -= int(mossa.get("peso", 1))
			if estratto <= 0:
				esegui_mossa(nemico, mossa)
				return
	var possibili := vivi(true)
	attacca(nemico, possibili[GameState.rng.randi_range(0, possibili.size() - 1)])

func esegui_mossa(nemico: Dictionary, mossa: Dictionary) -> void:
	scrivi("[i]%s[/i]" % mossa.get("testo", ""))
	match mossa.get("tipo", ""):
		"attacco_forte":
			var possibili := vivi(true)
			attacca(nemico, possibili[GameState.rng.randi_range(0, possibili.size() - 1)],
					int(mossa.get("valore", nemico.attacco)))
		"attacco_tutti":
			for bersaglio in vivi(true):
				attacca(nemico, bersaglio, int(mossa.get("valore", 1)))
			if mossa.has("stress"):
				for bersaglio in vivi(true):
					bersaglio.stress = clampi(bersaglio.stress + int(mossa.stress), 0, 100)
					aggiorna_scheda(bersaglio)
		"autolesione":
			# si ferisce da sola: il dolore riverbera sullo stress della squadra
			nemico.hp = maxi(nemico.hp - int(mossa.get("valore", 1)), 0)
			aggiorna_scheda(nemico)
			for bersaglio in vivi(true):
				bersaglio.stress = clampi(bersaglio.stress + int(mossa.get("stress", 10)), 0, 100)
				aggiorna_scheda(bersaglio)
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
			if vivi(false).size() < 3:
				aggiungi_combattente(String(mossa.get("valore", "")), false)
			else:
				scrivi("[i]...ma nessuno risponde al richiamo.[/i]")

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

# --- risoluzione dei colpi ---

func difesa_di(combattente: Dictionary) -> int:
	var totale: int = combattente.difesa
	for buff in combattente.buffs:
		if buff.get("stat", "") == "difesa":
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
	var danno: int
	if valore_attacco >= 0:
		danno = valore_attacco  # mossa a valore fisso (es. faena, gran finale)
	else:
		danno = attaccante.attacco
		if attaccante.giocatore:
			# il danno del party scala col livello: farmare ed equipaggiarsi conta
			danno += floori((GameState.livello_di(attaccante.id) - 1)
					* float(GameState.regole.get("bonus_attacco_per_livello", 0.5)))
	if fattore_attivo(attaccante) and GameState.rng.randf() < attaccante.fattore / 100.0:
		danno += 1
		scrivi("Il fattore Carnivalz arde in %s!" % attaccante.nome)
	danno -= difesa_di(bersaglio)
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
	scrivi("%s attacca %s: %d danno." % [attaccante.nome, bersaglio.nome, danno])
	aggiorna_scheda(bersaglio)
	if not bersaglio.giocatore:
		verifica_innesco_frenesia(bersaglio)
	if bersaglio.hp <= 0:
		_su_ko(bersaglio)
	elif bersaglio.giocatore:
		aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))

func colpisci_diretto(bersaglio: Dictionary, danno: int) -> void:
	# oggetti e assist ignorano le difese
	bersaglio.hp = maxi(bersaglio.hp - danno, 0)
	scrivi("%s subisce %d danno." % [bersaglio.nome, danno])
	aggiorna_scheda(bersaglio)
	if bersaglio.hp <= 0:
		_su_ko(bersaglio)

func _su_ko(caduto: Dictionary) -> void:
	if caduto.get("oggetto_scena", false):
		scrivi("[i]%s vengono distrutte.[/i]" % caduto.nome)
		if not portatore_frenesia.is_empty() \
				and caduto.id == portatore_frenesia.get("frenesia", {}).get("bersaglio_extra", ""):
			frenesia_attiva = false
			turni_afflitto = portatore_frenesia.get("frenesia", {}).get("testo_fermata", []).size()
	else:
		scrivi("[i]%s è a terra![/i]" % caduto.nome)
	for alleato in vivi(caduto.giocatore):
		reagisci(alleato)
	if vivi(false).is_empty():
		giocatore_ha_vinto = true
		in_corso = false
		for combattente in combattenti:
			if not combattente.giocatore and not combattente.get("oggetto_scena", false):
				xp_bottino += combattente.xp
				tazo_bottino += combattente.tazo
		scrivi("[b]Vittoria![/b] Bottino: %d esperienza, %d Tazo." % [xp_bottino, tazo_bottino])
		risolvi_drop()
	elif vivi(true).is_empty():
		in_corso = false
		scrivi("[b]Il party è a terra. Il Carnivalz ha vinto.[/b]")

func risolvi_drop() -> void:
	# drop dei nemici sconfitti: carta (rara, garantita solo per unici/boss)
	# e bottino comune (consumabili). Tutto dall'RNG seedato.
	var righe: Array[String] = []
	for c in combattenti:
		if c.giocatore or c.get("oggetto_scena", false):
			continue
		var carta: Dictionary = c.carta
		if not carta.is_empty():
			var chance := float(carta.get("chance", 1.0))
			if GameState.rng.randf() < chance and GameState.ottieni_carta(String(carta.get("id", ""))):
				righe.append("carta \"%s\" [%s]" % [carta.get("nome", ""), carta.get("rarita", "")])
		for voce in c.bottino_comune:
			if GameState.rng.randf() < float(voce.get("chance", 0.0)):
				var id_oggetto := String(voce.get("oggetto", ""))
				if GameState.aggiungi_oggetto(id_oggetto):
					righe.append(String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)))
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
			scrivi("%s si concentra: il fattore Carnivalz sale." % alleato.nome)
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
	else:
		combattente.etichetta_vita.text = "♥ %d/%d" % [combattente.hp, combattente.hp_max]
	var dettagli := "Stress %d · Fattore %d" % [combattente.stress, combattente.fattore]
	var scudo := difesa_di(combattente)
	if scudo > 0:
		dettagli += " · Dif %d" % scudo
	if combattente.stress >= int(GameState.regole.get("soglia_stress_sopraffatto", 80)):
		dettagli += " · sopraffatto"
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
	# le destinazioni vanno lette PRIMA di premia/annulla, che le azzerano
	var dopo_vittoria := GameState.nodo_se_vinci
	var dopo_vittoria_eroe := GameState.nodo_se_vinci_eroe
	var dopo_sconfitta := GameState.nodo_se_perdi
	if giocatore_ha_vinto:
		GameState.premia_vittoria(xp_bottino, tazo_bottino, not fonte.is_empty())
		var eroe := convinto and dopo_vittoria_eroe != ""
		GameState.nodo_corrente = dopo_vittoria_eroe if eroe else dopo_vittoria
		get_tree().change_scene_to_file(SCENA_EVENTI)
	elif dopo_sconfitta != "":
		GameState.annulla_combattimento()
		GameState.nodo_corrente = dopo_sconfitta
		get_tree().change_scene_to_file(SCENA_EVENTI)
	else:
		GameState.reset_campagna()
		get_tree().change_scene_to_file(SCENA_MAPPA)
