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

# --- la barra di dominio: energia, non un contatore --------------------------
#
# Tre segmenti - verde, blu, rossa - che si riempiono combattendo e si spendono
# sugli attacchi speciali. A rossa piena si puo' lanciare il colpo fatale.
# La Maestria del dominio la rende piu' generosa a riempirsi e piu' economica a
# spendersi: e' la statistica di chi gioca sugli speciali invece che sui colpi
# normali.

static func dominio_pieno() -> int:
	var dati: Dictionary = GameState.regole.get("dominio", {})
	return int(dati.get("segmenti", 3)) * int(dati.get("per_segmento", 100))

static func maestria_di(combattente: Dictionary) -> int:
	if not combattente.get("giocatore", false):
		return 0
	var tetto := int(GameState.regole.get("maestria_massima", 100))
	return clampi(GameState.stat_di("maestria_dominio"), 0, tetto)

static func riempi_dominio(combattente: Dictionary, motivo: String) -> int:
	# ritorna quanto e' entrato davvero. Il motivo e' una chiave di regole.json
	# ("per_attacco", "per_critico", ...): cosi' aggiungere una cosa che carica
	# la barra non richiede di toccare questo file
	var dati: Dictionary = GameState.regole.get("dominio", {})
	var base := float(dati.get(motivo, 0))
	if base <= 0.0:
		return 0
	var bonus := 1.0 + maestria_di(combattente) \
			* float(GameState.regole.get("maestria_guadagno_per_punto", 0.006))
	var prima := int(combattente.get("dominio", 0))
	var dopo := clampi(prima + int(round(base * bonus)), 0, dominio_pieno())
	combattente.dominio = dopo
	return dopo - prima

static func segmenti_pieni(combattente: Dictionary) -> int:
	var per_segmento := maxi(int(GameState.regole.get("dominio", {}).get("per_segmento", 100)), 1)
	return int(combattente.get("dominio", 0)) / per_segmento

static func colore_dominio(combattente: Dictionary) -> String:
	var colori: Array = GameState.regole.get("dominio", {}).get("_colori", ["verde", "blu", "rossa"])
	var pieni := segmenti_pieni(combattente)
	if pieni <= 0 or colori.is_empty():
		return ""
	return String(colori[mini(pieni, colori.size()) - 1])

static func costo_in_dominio(combattente: Dictionary, segmenti: float) -> int:
	# quanto costa DAVVERO uno speciale a questo combattente: la Maestria fa
	# sconto, ma non oltre il minimo - altrimenti a cento punti gli speciali
	# sarebbero gratis e la barra smetterebbe di essere una risorsa
	var per_segmento := float(GameState.regole.get("dominio", {}).get("per_segmento", 100))
	# lo sconto non ha un pavimento perche' non gli serve: cento punti tolgono il
	# 40%, e piu' di cento non se ne mettono. Un pavimento che non si raggiunge
	# mai e' codice che non protegge niente e racconta una protezione che non
	# c'e' - se ne era accorta prova_barra_di_dominio_come_energia, che
	# toglierlo non la faceva fallire. Quello che va garantito e' un altro: che
	# uno speciale costi sempre qualcosa, e lo garantisce la prova sul rapporto
	var sconto := 1.0 - maestria_di(combattente) \
			* float(GameState.regole.get("maestria_sconto_per_punto", 0.004))
	return maxi(int(round(segmenti * per_segmento * maxf(sconto, 0.0))), 1)

static func puo_spendere_dominio(combattente: Dictionary, segmenti: float) -> bool:
	return int(combattente.get("dominio", 0)) >= costo_in_dominio(combattente, segmenti)

static func spendi_dominio(combattente: Dictionary, segmenti: float) -> bool:
	var costo := costo_in_dominio(combattente, segmenti)
	if int(combattente.get("dominio", 0)) < costo:
		return false
	combattente.dominio = int(combattente.dominio) - costo
	return true

static func svuota_dominio(combattente: Dictionary) -> int:
	# LA MATTANZA NON HA UN PREZZO: HA UN SERBATOIO. Prende tutto quello che c'e'
	# nella barra e lo brucia, e quanto ce n'era decide quanto dura. Per questo
	# non passa da costo_in_dominio: uno sconto su "tutto" non vuol dire niente -
	# la Maestria l'ha gia' aiutato a riempirla piu' in fretta, ed e' li' che
	# conviene averla. Ritorna quanto c'era.
	var quanto := int(combattente.get("dominio", 0))
	combattente.dominio = 0
	return quanto

static func moltiplicatore_scatti(scatti: int) -> float:
	# LA TABELLA DI POKEMON, e Bru l'ha chiesta per nome. Uno scatto in su vale
	# meno del precedente, uno in giu' fa piu' male del precedente, e sopra il
	# tetto non si va: e' quello che rende "difenditi" una tattica invece che
	# un modo di non perdere mai.
	var tetto := int(GameState.regole.get("difesa_scatti_massimi", 6))
	var n := clampi(scatti, -tetto, tetto)
	return (2.0 + n) / 2.0 if n >= 0 else 2.0 / (2.0 - n)

static func scatti_difesa(combattente: Dictionary) -> int:
	var tetto := int(GameState.regole.get("difesa_scatti_massimi", 6))
	return clampi(int(combattente.get("scatti_difesa", 0)), -tetto, tetto)

static func difesa_di(combattente: Dictionary) -> int:
	# LA GUARDIA SI ACCUMULA E RESTA, fino alla fine dello scontro.
	#
	# Prima era un buff che durava un turno e si azzerava appena facevi altro:
	# difendersi cinque volte non valeva piu' che difendersi una volta, perche'
	# fra una e l'altra dovevi pur combattere. Bru: "se mi difendo 5 volte
	# dovrei poter ridurre i danni degli attacchi dei nemici... bisogna fare
	# come in pokemon".
	#
	# Il piatto per scatto c'e' perche' qui la difesa base puo' essere ZERO (il
	# protagonista al livello 1 non ne ha: se la guadagna parando), e qualunque
	# moltiplicatore per zero resta zero. Cosi' i primi scatti si sentono anche
	# a mani nude, e piu' avanti comanda il moltiplicatore.
	var scatti := scatti_difesa(combattente)
	var base: int = combattente.difesa
	for buff in combattente.buffs:
		if buff.get("stat", "") == "difesa":
			base += int(buff.get("valore", 0))
	var totale := int(round(base * moltiplicatore_scatti(scatti)))
	if scatti > 0:
		totale += scatti * int(GameState.regole.get("difesa_scatto_piatto", 2))
	return maxi(totale, 0)

static func attacco_di(combattente: Dictionary) -> int:
	var totale: int = combattente.attacco
	for buff in combattente.buffs:
		if buff.get("stat", "") == "attacco":
			totale += int(buff.get("valore", 0))
	if e_disperata(combattente):
		totale = int(round(totale * (1.0 + float(dati_disperazione().get("bonus_attacco", 0.3)))))
	return totale

# --- alle strette: una creatura ferita e' una creatura peggiore --------------
#
# Bru: "quando i nemici sono a fin di vita diventano piu' ostici". Non e' una
# mossa scritta creatura per creatura: e' una regola sola, in ruoli.json, che
# vale per tutte. Sotto una frazione della sua vita una creatura colpisce piu'
# forte, e - questa e' la parte che si sente giocando - comincia a scegliere
# meglio cosa fare (vedi "quando" e "priorita" nelle mosse).
#
# E' DEDOTTA, non memorizzata: "disperata" e' una cosa che si guarda, non uno
# stato da accendere e spegnere. Cosi' non esiste il caso di una creatura
# disperata a vita piena, o curata e ancora furiosa - non c'e' nessun posto in
# cui quel disallineamento possa nascere.

static func dati_disperazione() -> Dictionary:
	return GameState.ruoli.get("disperazione", {})

static func e_disperata(combattente: Dictionary) -> bool:
	if combattente.get("giocatore", false):
		return false   # vale sulle creature: il panico del party e' lo stress
	var massimo := float(combattente.get("hp_max", 0))
	if massimo <= 0.0 or int(combattente.get("hp", 0)) <= 0:
		return false
	return float(combattente.get("hp", 0)) / massimo \
			<= float(dati_disperazione().get("soglia", 0.3))

static func velocita_effettiva(combattente: Dictionary) -> int:
	var totale: int = int(combattente.velocita)
	for id_stato in ["rapidita", "lentezza"]:
		if combattente.stati_attivi.has(id_stato):
			totale += int(GameState.stati.get(id_stato, {}).get("valore", 0))
	return maxi(totale, 0)

static func scadenza_buff(combattente: Dictionary) -> void:
	# UN GIRO DI CLESSIDRA, ALL'INIZIO DELLA SUA BATTUTA. Non e' un tempo
	# globale: e' il SUO ritmo. "Difesa +3 per 3 battute" vuol dire tre suoi
	# cicli di ricarica, quindi su una creatura lenta dura il doppio dei secondi
	# che dura su una veloce - ed e' giusto cosi', perche' e' anche il doppio
	# del tempo in cui quella creatura agisce.
	var rimasti: Array = []
	for buff in combattente.buffs:
		buff.turni = int(buff.turni) - 1
		if int(buff.turni) > 0:
			rimasti.append(buff)
	combattente.buffs = rimasti

static func applica_buff(combattente: Dictionary, stat: String, valore: int,
		turni: int, fonte: String) -> void:
	# LO STESSO POTENZIAMENTO NON SI ACCUMULA CON SE STESSO: si rinnova.
	#
	# Prima ogni uso appendeva un buff nuovo, e chi aveva una mossa di
	# potenziamento senza ricarica poteva rifarla ogni battuta: il goblin
	# arrabbiato si sommava +9 di attacco all'infinito, Jerah +14 di difesa
	# finche' non lo si scalfiva piu'. Non era una scelta di design, era una
	# somma senza tetto - e non si vedeva da nessuna parte, perche' a schermo
	# compare solo il totale.
	#
	# Due mosse DIVERSE che alzano la stessa stat si sommano ancora: e' un modo
	# di dire "questa creatura sta mettendo insieme due cose". Una mossa con se
	# stessa no: rinnova la durata, e tiene il valore piu' alto dei due.
	for buff in combattente.buffs:
		if String(buff.get("fonte", "")) == fonte and String(buff.get("stat", "")) == stat:
			# vince il piu' forte NEL SUO VERSO: un potenziamento tiene il valore
			# piu' alto, un malus (la crisi di gelosia abbassa la difesa) il piu'
			# basso. Prendere sempre il massimo avrebbe ammorbidito i malus
			buff.valore = maxi(int(buff.get("valore", 0)), valore) if valore >= 0 \
					else mini(int(buff.get("valore", 0)), valore)
			buff.turni = maxi(int(buff.get("turni", 0)), turni)
			return
	combattente.buffs.append({
		"stat": stat, "valore": valore, "turni": turni, "fonte": fonte,
	})

static func alza_guardia(combattente: Dictionary) -> int:
	# uno scatto in su, e resta fino alla fine dello scontro. Ritorna quanto e'
	# cambiata la difesa davvero, che e' l'unica cosa che ha senso dire al
	# giocatore: "+1 scatto" non vuol dire niente, "+4" si'
	var prima := difesa_di(combattente)
	var tetto := int(GameState.regole.get("difesa_scatti_massimi", 6))
	combattente.scatti_difesa = mini(scatti_difesa(combattente) + 1, tetto)
	return difesa_di(combattente) - prima

static func abbassa_guardia(combattente: Dictionary, quanti := 1) -> int:
	# certi colpi la guardia te la aprono: scende di uno o piu' scatti, e
	# scendere sotto zero vuol dire incassare piu' del normale
	var prima := difesa_di(combattente)
	var tetto := int(GameState.regole.get("difesa_scatti_massimi", 6))
	combattente.scatti_difesa = maxi(scatti_difesa(combattente) - quanti, -tetto)
	return prima - difesa_di(combattente)

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
	if dati.has("risparmio") or dati.has("difesa_per_turno"):
		# Una creatura che si puo' risparmiare, o che si chiude e non si abbatte,
		# e' li' per insegnare che non tutto si risolve picchiando. Un colpo di
		# fortuna all'1% che la liquida non e' una variazione: e' il gioco che
		# smentisce sé stesso. La Tartaruga moriva cosi' nella meta' delle prove.
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
		moltiplicatore := 1.0, bonus := 0) -> Dictionary:
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
	# IL BONUS DELL'ARMA SI SOMMA, non sostituisce. Passarlo come valore fisso
	# sembrava equivalente e non lo era: un valore fisso salta il bonus di
	# livello, quindi un attacco d'arma da "+5" a livello 10 faceva SEI DANNI IN
	# MENO di un colpo normale. Se ne e' accorta prova_attacchi_darma misurando
	# i due colpi in campo con lo stesso seme, non leggendo il codice
	danno += bonus
	if moltiplicatore != 1.0:
		# un colpo caricato moltiplica il colpo INTERO, bonus di livello compreso:
		# altrimenti a livello alto caricare sarebbe un modo di picchiare meno
		danno = int(round(danno * moltiplicatore))
	if fattore_attivo(attaccante) and GameState.rng.randf() < attaccante.fattore / 100.0:
		danno += 1
		esito.fattore = true
	var danno_pieno := danno   # quanto valeva il colpo prima che qualcuno lo fermasse
	if danno_pieno <= 0:
		esito.danno = 0
		return esito   # chi ha 0 di attacco non fa male: la Tartaruga resta la Tartaruga
	var difesa_bersaglio := float(difesa_di(bersaglio))
	esito.critico = tenta_critico(bersaglio)
	if esito.critico:
		danno = int(round(danno * float(GameState.regole.get("critico_moltiplicatore", 1.5))))
		danno_pieno = danno
		difesa_bersaglio *= 1.0 - float(GameState.regole.get("critico_riduzione_difesa", 0.5))
	danno -= int(difesa_bersaglio)
	if ha_stato_con_effetto(bersaglio, "difesa_giu"):
		danno += int(GameState.regole.get("malus_danno_depressione", 1))
	# LA DIFESA RIDUCE, NON CANCELLA. MAI ZERO.
	#
	# Prima si sottraeva la difesa e si teneva il massimo con zero: bastava una
	# difesa alta quanto l'attacco e il colpo spariva. Con "Difenditi" che
	# accumula, e con l'equipaggiamento addosso, quasi tutti i colpi finivano in
	# "X para il colpo di Y" - una riga di testo al posto di un numero, decine di
	# volte per scontro. Un colpo che non fa niente non e' un evento: e' un buco
	# nel ritmo, e chi gioca smette di sentirsi in pericolo.
	#
	# Due regole, e insieme dicono tutto quello che c'e' da sapere:
	#
	#   la corazza VINCE  (difesa >= colpo)  ->  passa 1. Un graffio, non niente.
	#   la corazza PERDE                     ->  passa quel che resta, ma mai meno
	#                                            di una frazione del colpo pieno
	#
	# Il primo caso e' quello che rende possibile una creatura come la Tartaruga
	# Innocente, che a ogni turno alza la guardia di tre punti e non se li toglie
	# piu': arriva il momento in cui a mani nude le fai 1, e con quella vita non
	# la abbatti in nessun modo. Non e' un muro ingiusto - e' il gioco che ti dice
	# che quella creatura non va picchiata, va capita.
	if danno <= 0:
		danno = 1
	else:
		var pavimento := maxi(int(ceil(danno_pieno
				* float(GameState.regole.get("danno_minimo_percentuale", 0.1)))), 1)
		danno = maxi(danno, pavimento)
	if bersaglio.giocatore:
		# Il livello (e il fattore acceso) tolgono una PERCENTUALE al colpo. Prima
		# era una probabilita' di annullarlo del tutto - fino a meta' dei colpi
		# subiti spariva nel nulla, a caso, e a schermo non succedeva niente.
		# Adesso il colpo arriva sempre, e arriva piu' leggero.
		var riduzione := minf(
			(GameState.livello_di(bersaglio.id) - 1)
				* float(GameState.regole.get("riduzione_danno_per_livello", 0.02)),
			float(GameState.regole.get("riduzione_danno_massima", 0.35)))
		if fattore_attivo(bersaglio):
			riduzione += bersaglio.fattore / 400.0
		danno = maxi(int(round(danno * (1.0 - clampf(riduzione, 0.0, 0.9)))), 1)
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
