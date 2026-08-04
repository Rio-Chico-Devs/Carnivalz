class_name RegoleCombattimento
extends RefCounted

# La matematica del combattimento, e nient'altro.
#
# Qui dentro non si scrive niente a schermo, non si tocca nessuna scheda, non
# muore nessuno: si ricevono dei numeri e se ne restituiscono altri. E' la
# parte del combattimento che si puo' verificare senza aprire una finestra, e
# quella che il giocatore automatico (prove/Simulatore.gd) esegue centinaia di
# migliaia di volte per dire se uno scontro e' giusto o no.
#
# Regola unica, e vale la pena tenerla: se una funzione qui dentro avesse
# bisogno di dire qualcosa al giocatore, e' nel posto sbagliato. Chi chiama
# riceve l'esito e decide lui come raccontarlo.
#
# Tutte statiche: non c'e' stato da tenere, solo i dizionari dei combattenti
# che arrivano da fuori.

# --- letture sui combattenti ---

static func categoria_di(dati: Dictionary) -> String:
	if dati.get("fonte", false):
		return "boss"
	if dati.has("frenesia"):
		return "miniboss"
	return String(dati.get("categoria", "comune"))

static func resistenza_di(combattente: Dictionary, chiave: String) -> String:
	# "immune" annulla, "ipersensibile" amplifica, "invertito" (solo stress)
	# capovolge. Assente = "normale".
	if chiave in combattente.get("immunita_temporanea", []):
		return "immune"  # respinto in questo stesso scontro (es. scudo_primo_stato)
	if combattente.giocatore and combattente.id == GameState.id_protagonista \
			and GameState.resistenza_stato_di(chiave) >= int(GameState.crescita.get("resistenze", {}).get("massimo", 100)):
		return "immune"  # allenato fino in fondo: quello stato non ti tocca piu'
	var dati: Dictionary = GameState.personaggi.get(combattente.id, {})
	return String(dati.get("resistenze", {}).get(chiave, "normale"))

static func ha_stato_attivo(combattente: Dictionary, id_stato: String) -> bool:
	return combattente.stati_attivi.has(id_stato)

static func ha_stato_con_effetto(combattente: Dictionary, effetto: String) -> bool:
	if combattente.psiche not in combattente.stati:
		return false
	return GameState.psichi.get(combattente.psiche, {}).get("effetto", "") == effetto

static func fattore_attivo(combattente: Dictionary) -> bool:
	var soglia := int(GameState.regole.get("soglia_stress_sopraffatto", 80))
	return combattente.fattore > 0 and combattente.stress < soglia

# --- statistiche effettive (base + buff + stati) ---

static func difesa_di(combattente: Dictionary) -> int:
	var totale: int = combattente.difesa
	for buff in combattente.buffs:
		if buff.get("stat", "") == "difesa":
			totale += int(buff.get("valore", 0))
	return totale

static func attacco_di(combattente: Dictionary) -> int:
	var totale: int = combattente.attacco
	for buff in combattente.buffs:
		if buff.get("stat", "") == "attacco":
			totale += int(buff.get("valore", 0))
	return totale

static func velocita_effettiva(combattente: Dictionary) -> int:
	var totale: int = int(combattente.velocita)
	for id_stato in ["rapidita", "lentezza"]:
		if combattente.stati_attivi.has(id_stato):
			totale += int(GameState.stati.get(id_stato, {}).get("valore", 0))
	return maxi(totale, 0)

static func scadenza_buff(combattente: Dictionary) -> void:
	var rimasti: Array = []
	for buff in combattente.buffs:
		buff.turni = int(buff.turni) - 1
		if int(buff.turni) > 0:
			rimasti.append(buff)
	combattente.buffs = rimasti

static func bonus_difesa_guardia(combattente: Dictionary) -> int:
	# "Difenditi" e' cumulativa ma a rendimento decrescente: ogni uso in piu' si
	# avvicina a un tetto senza mai raggiungerlo. Si azzera appena si fa altro
	# (vedi esegui_turno): o si tiene la guardia, o si rischia attaccando.
	var tetto := float(GameState.regole.get("difesa_difenditi_tetto", 6))
	var decadimento := float(GameState.regole.get("difesa_difenditi_decadimento", 0.5))
	combattente.difesa_accumulo = float(combattente.difesa_accumulo) \
			+ (tetto - float(combattente.difesa_accumulo)) * decadimento
	return int(round(combattente.difesa_accumulo))

# --- risoluzione di un colpo ---

static func tenta_critico(bersaglio: Dictionary) -> bool:
	# lo stress alza la probabilita' di SUBIRE un critico; per chi ha una
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

static func puo_subire_slaughter(bersaglio: Dictionary) -> bool:
	# il colpo di fortuna non uccide mai il party, e non liquida mai boss,
	# miniboss, creature particolari o incontri scriptati: le loro scene devono
	# poter arrivare fino in fondo
	if bersaglio.hp <= 0 or bersaglio.giocatore:
		return false
	var dati: Dictionary = GameState.personaggi.get(bersaglio.id, {})
	if categoria_di(dati) != "comune" or dati.has("incontro_scriptato") \
			or dati.get("invincibile", false):
		return false
	var resistenza := resistenza_di(bersaglio, "stress")
	return resistenza != "immune" and resistenza != "invertito"

static func probabilita_slaughter(attaccante: Dictionary, bersaglio: Dictionary) -> float:
	var probabilita := float(GameState.regole.get("slaughter_probabilita_base", 0.01))
	if attaccante.giocatore and not bersaglio.giocatore:
		var scarto: int = GameState.livello_di(attaccante.id) \
				- GameState.livello_nemico(bersaglio.id)
		for voce in GameState.crescita.get("passive_livello", []):
			if voce.has("slaughter_bonus") and GameState.ha_passiva(String(voce.get("id", ""))) \
					and scarto >= int(voce.get("slaughter_scarto_livelli", 0)):
				probabilita *= 1.0 + float(voce["slaughter_bonus"])
	return probabilita

static func calcola_danno(attaccante: Dictionary, bersaglio: Dictionary, valore_attacco := -1,
		moltiplicatore := 1.0) -> Dictionary:
	# Tutta la matematica di un colpo in un posto solo. Restituisce cosa e'
	# successo; chi chiama decide cosa raccontarne e chi far cadere.
	#   danno    -> quanto passa davvero
	#   critico  -> ha colto in pieno (danno x moltiplicatore, meta' difesa)
	#   fattore  -> il disallineamento ha aggiunto il suo punto
	#   schivato -> il livello del bersaglio ha annullato un colpo che passava
	var esito := {"danno": 0, "critico": false, "fattore": false, "schivato": false}
	var danno: int
	if valore_attacco >= 0:
		danno = valore_attacco  # mossa a valore fisso (es. faena, gran finale)
	else:
		danno = attacco_di(attaccante)
		if attaccante.giocatore:
			# il danno del party scala col livello: farmare ed equipaggiarsi conta
			danno += floori((GameState.livello_di(attaccante.id) - 1)
					* float(GameState.regole.get("bonus_attacco_per_livello", 0.5)))
	if moltiplicatore != 1.0:
		# un colpo caricato moltiplica il colpo INTERO, bonus di livello compreso:
		# altrimenti a livello alto caricare sarebbe un modo di picchiare meno
		danno = int(round(danno * moltiplicatore))
	if fattore_attivo(attaccante) and GameState.rng.randf() < attaccante.fattore / 100.0:
		danno += 1
		esito.fattore = true
	var difesa_bersaglio := float(difesa_di(bersaglio))
	esito.critico = tenta_critico(bersaglio)
	if esito.critico:
		danno = int(round(danno * float(GameState.regole.get("critico_moltiplicatore", 1.5))))
		difesa_bersaglio *= 1.0 - float(GameState.regole.get("critico_riduzione_difesa", 0.5))
	danno -= int(difesa_bersaglio)
	if ha_stato_con_effetto(bersaglio, "difesa_giu"):
		danno += int(GameState.regole.get("malus_danno_depressione", 1))
	danno = maxi(danno, 0)
	if danno > 0 and bersaglio.giocatore:
		# il danno subito cala in proporzione al livello (e col fattore acceso)
		var riduzione := minf(
			(GameState.livello_di(bersaglio.id) - 1)
				* float(GameState.regole.get("riduzione_danno_per_livello", 0.1)),
			float(GameState.regole.get("riduzione_danno_massima", 0.5)))
		if fattore_attivo(bersaglio):
			riduzione += bersaglio.fattore / 200.0
		if GameState.rng.randf() < riduzione:
			danno = 0
			esito.schivato = true
	esito.danno = danno
	return esito

# --- ricompense ---

static func xp_effettiva(nemico: Dictionary) -> int:
	# rendimento decrescente sul farming: piu' il party supera il livello
	# consigliato del nemico, meno esperienza rende - senza mai azzerarsi, cosi'
	# una farm zone resta utile a lungo ma smette di essere la scorciatoia migliore
	var xp_base := int(nemico.xp)
	var livello_creatura := GameState.livello_nemico(String(nemico.id))
	var livello_party := 1
	for id_classe in GameState.party:
		livello_party = maxi(livello_party, GameState.livello_di(id_classe))
	var scarto := livello_party - livello_creatura
	if scarto <= 0:
		return xp_base
	var penalita := float(GameState.regole.get("xp_penalita_per_livello_extra", 0.15))
	var minimo := float(GameState.regole.get("xp_minimo_percentuale", 0.1))
	var fattore := maxf(1.0 - scarto * penalita, minimo)
	return maxi(int(round(xp_base * fattore)), 1)

static func xp_da_risparmio(nemico: Dictionary) -> int:
	# quanto rende una creatura risparmiata: piu' di quanto renderebbe morta.
	# Il perche' e' di design, non di bilancio - capire una creatura fino a non
	# doverla uccidere e' la cosa difficile
	return int(round(xp_effettiva(nemico)
			* float(GameState.regole.get("xp_risparmio_moltiplicatore", 1.25))))
