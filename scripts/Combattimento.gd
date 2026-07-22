extends Control

# Combattimento a turni. Party e nemici in un'unica fila d'iniziativa
# ordinata per velocità: il più veloce di tutti agisce per primo, 1 attacco
# a testa per giro. Quando un compagno va a terra ogni sopravvissuto
# reagisce secondo la propria psiche (rabbia / depressione /
# concentrazione, definite in data/psiche.json). Il fattore Carnivalz
# potenzia attacco e difesa ma fa salire lo stress; oltre la soglia il
# personaggio è sopraffatto e il fattore si spegne. Numeri in
# data/regole.json, casualità solo dall'RNG seedato di GameState.

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

# Esito eroe: se tra i nemici c'è una fonte convincibile, la speranza può
# farla cedere. Sale con le leve (oggetti/ospiti/compagni nei dati della
# fonte), con l'abilità "studio" (dialoghi con risposta), sopportando i
# colpi e prolungando lo scontro. Una fonte convinta NON smette di
# attaccare: le sue statistiche cedono a poco a poco, fino alla sconfitta.
# Cambia solo come muore. I boss malvagi hanno convincibile: false.
var fonte: Dictionary = {}
var speranza := 0
var convinto := false
var indice_studio := 0

func _ready() -> void:
	for id_classe in GameState.party:
		aggiungi_combattente(id_classe, true)
	for id_nemico in GameState.nemici_combattimento:
		aggiungi_combattente(id_nemico, false)
		var dati: Dictionary = GameState.personaggi.get(id_nemico, {})
		if fonte.is_empty() and dati.get("fonte", false):
			fonte = dati
	scrivi("[b]Il Carnivalz fa spazio: si combatte.[/b]")
	if fonte.get("convincibile", false):
		etichetta_speranza.visible = true
		aggiorna_speranza(0)
	applica_leve()
	esegui_scontro()

func applica_leve() -> void:
	for leva in fonte.get("leve", []):
		var id_leva: String = leva.get("id", "")
		var presente := false
		match leva.get("tipo", ""):
			"oggetto":
				presente = id_leva in GameState.inventario
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
	var combattente := {
		"indice": combattenti.size(),
		"id": id_personaggio,
		"nome": dati.get("nome_breve", dati.get("nome", id_personaggio)),
		"hp": hp_max,
		"hp_max": hp_max,
		"velocita": int(dati.get("velocita", 3)),
		"psiche": String(dati.get("psiche", "")),
		"fattore": int(dati.get("fattore_base", 0)),
		"stress": GameState.stress_di(id_personaggio) if giocatore else 0,
		"xp": int(dati.get("xp", 10)),
		"giocatore": giocatore,
		"stati": [],
		"scheda": scheda,
		"etichetta_vita": vita,
		"etichetta_extra": extra,
	}
	combattenti.append(combattente)
	aggiorna_scheda(combattente)

func esegui_scontro() -> void:
	while in_corso:
		# il cedimento puo' cambiare le velocita': l'iniziativa si ricalcola
		combattenti.sort_custom(func(a, b):
			return a.indice < b.indice if a.velocita == b.velocita else a.velocita > b.velocita)
		for combattente in combattenti:
			if not in_corso:
				break
			if combattente.hp <= 0:
				continue
			await esegui_turno(combattente)
			var prob_extra := float(GameState.regole.get("probabilita_attacco_extra_rabbia", 0.35))
			if in_corso and combattente.hp > 0 \
					and ha_stato_con_effetto(combattente, "attacco_extra") \
					and GameState.rng.randf() < prob_extra:
				scrivi("%s è in preda alla rabbia e attacca di nuovo!" % combattente.nome)
				await esegui_turno(combattente)
		if in_corso:
			# prolungare lo scontro fa breccia nella fonte
			aggiorna_speranza(int(GameState.regole.get("speranza_per_giro", 2)))
	await get_tree().create_timer(1.4).timeout
	_esci()

func esegui_turno(attaccante: Dictionary) -> void:
	evidenzia(attaccante)
	if attaccante.giocatore:
		mostra_azioni(attaccante)
		var azione: Dictionary = await azione_scelta
		if azione.get("studia", false):
			studia(attaccante)
		else:
			attacca(attaccante, azione.bersaglio)
	else:
		await get_tree().create_timer(0.8).timeout
		if convinto and attaccante.id == fonte.get("id", "") \
				and GameState.rng.randf() < float(GameState.regole.get("probabilita_cedimento", 0.5)):
			cedimento(attaccante)
		else:
			var possibili := vivi(true)
			attacca(attaccante, possibili[GameState.rng.randi_range(0, possibili.size() - 1)])
	# tenere acceso il fattore costa: lo stress sale a ogni azione
	var passo := int(GameState.regole.get("stress_per_fattore", 25))
	var costo := floori(attaccante.fattore / float(maxi(passo, 1)))
	if costo > 0:
		attaccante.stress = clampi(attaccante.stress + costo, 0, 100)
		aggiorna_scheda(attaccante)

func mostra_azioni(attaccante: Dictionary) -> void:
	for figlio in azioni.get_children():
		figlio.queue_free()
	for nemico in vivi(false):
		var bottone := Button.new()
		bottone.text = "Attacca %s" % nemico.nome
		bottone.pressed.connect(_scegli.bind({"bersaglio": nemico}))
		azioni.add_child(bottone)
	if "studio" in GameState.classi.get(attaccante.id, {}).get("abilita", []):
		var bottone_studia := Button.new()
		bottone_studia.text = "Studia"
		bottone_studia.pressed.connect(_scegli.bind({"studia": true}))
		azioni.add_child(bottone_studia)

func _scegli(azione: Dictionary) -> void:
	for figlio in azioni.get_children():
		figlio.queue_free()
	azione_scelta.emit(azione)

func studia(chi: Dictionary) -> void:
	var bersaglio := bersaglio_studio()
	if bersaglio.is_empty():
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
		scrivi("%s: \"%s\"" % [chi.nome, scambio.get("domanda", "")])
		scrivi("%s: \"%s\"" % [bersaglio.nome, scambio.get("risposta", "")])
	GameState.segna_studiato(bersaglio.id)
	if bersaglio.id == fonte.get("id", ""):
		aggiorna_speranza(int(GameState.regole.get("speranza_studio", 10)))

func bersaglio_studio() -> Dictionary:
	# si studia prima di tutto la fonte, altrimenti il primo nemico vivo
	for combattente in vivi(false):
		if combattente.id == fonte.get("id", ""):
			return combattente
	var nemici := vivi(false)
	return nemici[0] if not nemici.is_empty() else {}

func cedimento(combattente: Dictionary) -> void:
	# la fonte convinta perde pezzi di spettacolo: statistiche giu', fino alla fine
	combattente.fattore = maxi(combattente.fattore - int(GameState.regole.get("cedimento_fattore", 10)), 0)
	combattente.velocita = maxi(combattente.velocita - int(GameState.regole.get("cedimento_velocita", 1)), 1)
	combattente.hp = maxi(combattente.hp - int(GameState.regole.get("cedimento_hp", 1)), 0)
	scrivi("[i]Lo spettacolo di %s si spegne un po' di più.[/i]" % combattente.nome)
	aggiorna_scheda(combattente)
	if combattente.hp <= 0:
		_su_ko(combattente)

func attacca(attaccante: Dictionary, bersaglio: Dictionary) -> void:
	var danno := int(GameState.regole.get("danno_attacco", 1))
	if fattore_attivo(attaccante) and GameState.rng.randf() < attaccante.fattore / 100.0:
		danno += 1
		scrivi("Il fattore Carnivalz arde in %s!" % attaccante.nome)
	if ha_stato_con_effetto(bersaglio, "difesa_giu"):
		danno += int(GameState.regole.get("malus_danno_depressione", 1))
	if bersaglio.giocatore:
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
		scrivi("%s attacca %s, che assorbe il colpo!" % [attaccante.nome, bersaglio.nome])
		if bersaglio.giocatore:
			aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))
		return
	bersaglio.hp = maxi(bersaglio.hp - danno, 0)
	scrivi("%s attacca %s: %d danno." % [attaccante.nome, bersaglio.nome, danno])
	aggiorna_scheda(bersaglio)
	if bersaglio.hp <= 0:
		_su_ko(bersaglio)
	elif bersaglio.giocatore:
		# reggere in piedi sotto i colpi dimostra alla fonte che si può
		aggiorna_speranza(int(GameState.regole.get("speranza_per_colpo_subito", 3)))

func _su_ko(caduto: Dictionary) -> void:
	scrivi("[i]%s è a terra![/i]" % caduto.nome)
	for alleato in vivi(caduto.giocatore):
		reagisci(alleato)
	if vivi(false).is_empty():
		giocatore_ha_vinto = true
		in_corso = false
		scrivi("[b]Vittoria! Il party guadagna esperienza.[/b]")
	elif vivi(true).is_empty():
		in_corso = false
		scrivi("[b]Il party è a terra. Il Carnivalz ha vinto.[/b]")

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
		var xp_totale := 0
		for combattente in combattenti:
			if not combattente.giocatore:
				xp_totale += combattente.xp
		GameState.premia_vittoria(xp_totale)
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
