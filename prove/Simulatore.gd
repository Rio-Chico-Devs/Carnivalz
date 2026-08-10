extends Node

# Il giocatore automatico.
#
#   /percorso/godot --headless --path . prove/Simulatore.tscn
#
# Gioca ogni scontro del gioco centinaia di volte, con quattro modi di giocare
# diversi, e scrive quanto e' durato, quante volte si e' morti, quanti danni si
# sono presi. Il risultato finisce in docs/bilanciamento.md.
#
# PERCHE' ESISTE. Fino a ieri il bilanciamento di Carnivalz era indovinato:
# i punti vita e l'attacco di ogni creatura erano stati scritti a occhio e mai
# verificati da nessuno. Un boss puo' avere piu' vita del boss del tutorial e
# fare meno danni - e' successo - senza che nessuno se ne accorga, perche' per
# accorgersene bisognerebbe giocare quello scontro venti volte di fila.
#
# NON E' UNA SIMULAZIONE. Non c'e' nessun modello semplificato del
# combattimento qui dentro: viene istanziata la scena vera, Combattimento.tscn,
# e giocata dal motore vero. L'unica differenza e' che Voce, Campo e Menu sono
# in modalita' muta, quindi non c'e' niente da guardare e niente da aspettare.
# Se cambia una regola nel gioco, cambia qui dentro lo stesso giro dopo. Se
# questi numeri sono sbagliati, sono sbagliati anche quando ci giochi tu.
#
# Le strategie non sono intelligenze artificiali: sono modi di giocare estremi,
# scelti perche' misurano cose diverse.
#   attacca   -> il giocatore che va dritto. E' la misura della durata vera
#   difendi   -> non attacca mai. Se vince, lo scontro e' rotto
#   studia    -> guarda la creatura prima di alzare le mani: e' la strada che
#                il gioco vorrebbe insegnare. Dice se e' davvero percorribile
#   casuale   -> chi non ha capito cosa sta facendo. E' il pavimento: sotto
#                questo risultato non si scende

const SCENA_COMBATTIMENTO := preload("res://scenes/Combattimento.tscn")
const RIPETIZIONI := 150      # per ogni coppia nemico/strategia
# Ogni scontro si gioca per intero dentro add_child, senza mai cedere un frame.
# Godot pero' accoda delle notifiche interne per ogni Control che entra
# nell'albero, e quella coda si svuota solo a fine frame: dopo qualche migliaio
# di scontri di fila esplode. Un frame ogni tanto la libera.
const SCONTRI_PER_FRAME := 30
const LIMITE_GIRI := 60       # oltre questo, lo scontro e' "non finisce"
const LIVELLI := [1, 2, 3, 5, 8, 12, 18, 25]
# I livelli sopra l'8 mancavano, e la mancanza costava esattamente quello che
# doveva costare: nessuno aveva mai misurato il gioco dopo il tutorial. La
# curva dell'attacco si spezzava al livello 9 e la tabella non poteva dirlo,
# perche' non guardava li'. Adesso il contenuto arriva al livello 18 (Jerah) e
# le misure arrivano al 25.
# Attenzione a cosa vuol dire "livello" qui: nel gioco le statistiche non
# salgono col livello, salgono con quello che hai fatto (vedi crescita.json).
# Per mesi il simulatore alzava SOLO il livello, e quindi misurava un
# protagonista arrivato al livello 8 senza aver mai combattuto - un giocatore
# che non esiste. Adesso applica il "profilo_giocatore_tipo" di crescita.json
# (vedi cresci_fino_a): il livello e' un'abbreviazione per "uno che ha giocato
# fin qui".

const STRATEGIE := ["attacca", "difendi", "studia", "casuale"]

var righe: Array[Dictionary] = []

func _ready() -> void:
	print("\n=== GIOCATORE AUTOMATICO ===\n")
	var elenco := nemici_da_provare()
	print("%d creature × %d strategie × %d livelli × %d partite = %d scontri\n"
			% [elenco.size(), STRATEGIE.size(), LIVELLI.size(), RIPETIZIONI,
			elenco.size() * STRATEGIE.size() * LIVELLI.size() * RIPETIZIONI])
	var inizio := Time.get_ticks_msec()
	for livello: int in LIVELLI:
		for id_nemico in elenco:
			for nome_strategia: String in STRATEGIE:
				righe.append(await gioca_molte_volte(id_nemico, nome_strategia, livello))
	var durata := (Time.get_ticks_msec() - inizio) / 1000.0
	stampa_tabella()
	scrivi_documento(durata)
	print("\nFatto in %.1f secondi. Tabella completa in docs/bilanciamento.md" % durata)
	get_tree().quit(0)

func nemici_da_provare() -> Array[String]:
	# tutte le creature che danno esperienza, cioe' tutte quelle che si
	# combattono davvero. Fuori solo chi porta uno script del tutorial: quello
	# non e' uno scontro, e' una scena, e va esattamente come e' scritto
	var elenco: Array[String] = []
	for id_creatura in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_creatura]
		if not GameState.e_creatura(id_creatura):
			continue
		if dati.has("tutorial_combattimento"):
			continue
		elenco.append(String(dati.get("id", "")))
	elenco.sort()
	return elenco

# --- una partita ------------------------------------------------------------

func cresci_fino_a(livello: int) -> void:
	# IL GIOCATORE CHE ESISTE DAVVERO.
	#
	# Per mesi questa riga non c'e' stata, e la tabella di bilanciamento ha
	# raccontato una bugia: alzava solo il livello, e nel gioco le statistiche
	# NON salgono col livello - salgono con quello che hai fatto (crescita.json).
	# Il protagonista misurato era quindi uno arrivato al livello 8 senza aver
	# mai sferrato un colpo: un giocatore che non esiste. La tabella diceva
	# "equilibrato" mentre chi ci giocava davvero non scendeva sotto meta' vita.
	#
	# Adesso si simula quello che uno ha in mano DAVVERO a quel livello: quante
	# volte compie ogni azione per ogni livello guadagnato. La stima sta in
	# data/crescita.json ("profilo_giocatore_tipo"), non qui, perche' la usano
	# anche le prove: se sta in due posti, prima o poi dicono due cose diverse.
	var per_livello: Dictionary = GameState.crescita.get("profilo_giocatore_tipo", {})
	for nome_azione: String in per_livello:
		GameState.contatori[nome_azione] = int(per_livello[nome_azione]) * (livello - 1)
	GameState.applica_crescita_livello()

func gioca_una_volta(id_nemico: String, nome_strategia: String, livello: int, seme: int) -> Dictionary:
	GameState.nuova_partita()
	GameState.imposta_seed(seme)
	GameState.livelli[GameState.id_protagonista] = livello
	cresci_fino_a(livello)
	GameState.nemici_combattimento = [id_nemico]
	var scontro := SCENA_COMBATTIMENTO.instantiate()
	# muto PRIMA di entrare nell'albero: e' _ready() a costruire i collaboratori
	scontro.muto = true
	scontro.limite_giri = LIMITE_GIRI
	scontro.strategia = Callable(self, "strategia_" + nome_strategia)
	# in modalita' muta niente aspetta niente: lo scontro intero si gioca dentro
	# add_child, e quando torna e' gia' finito
	add_child(scontro)
	var eroe: Dictionary = {}
	var risparmiato := false
	for combattente in scontro.combattenti:
		if combattente.giocatore and eroe.is_empty():
			eroe = combattente
		if combattente.get("risparmiato", false):
			risparmiato = true
	var esito := {
		"vinto": bool(scontro.giocatore_ha_vinto),
		"fuggito": bool(scontro.giocatore_e_fuggito),
		"infinito": int(scontro.giro_corrente) > LIMITE_GIRI,
		"giri": int(scontro.giro_corrente),
		"hp_finali": int(eroe.get("hp", 0)),
		"hp_max": int(eroe.get("hp_max", 1)),
		"risparmiato": risparmiato,
		"xp": int(scontro.xp_bottino),
	}
	scontro.free()
	return esito

func gioca_molte_volte(id_nemico: String, nome_strategia: String, livello: int) -> Dictionary:
	var vittorie := 0
	var sconfitte := 0
	var fughe := 0
	var infiniti := 0
	var risparmi := 0
	var somma_giri := 0
	var somma_danno := 0
	var xp_totale := 0
	for i in range(RIPETIZIONI):
		# un seme diverso per ogni partita, ma sempre gli stessi: due esecuzioni
		# del simulatore danno lo stesso identico risultato, quindi una
		# differenza nella tabella e' sempre una differenza nel gioco
		if i % SCONTRI_PER_FRAME == 0:
			await get_tree().process_frame
		var esito := gioca_una_volta(id_nemico, nome_strategia, livello, 1000 + i)
		if esito.infinito:
			infiniti += 1
		elif esito.vinto:
			vittorie += 1
		elif esito.fuggito:
			fughe += 1
		else:
			sconfitte += 1
		if esito.risparmiato:
			risparmi += 1
		somma_giri += int(esito.giri)
		somma_danno += int(esito.hp_max) - int(esito.hp_finali)
		xp_totale += int(esito.xp)
	return {
		"nemico": id_nemico,
		"nome": String(GameState.personaggi.get(id_nemico, {}).get("nome", id_nemico)),
		# non piu' dal file: le stat di una creatura escono dal suo ruolo, e
		# leggerle dal record dava zero per tutte tranne le cinque eccezioni
		"hp": GameState.stat_base_nemico(id_nemico, "hp"),
		"att": GameState.stat_base_nemico(id_nemico, "attacco"),
		"strategia": nome_strategia,
		"livello": livello,
		"vittorie": 100.0 * vittorie / RIPETIZIONI,
		"sconfitte": 100.0 * sconfitte / RIPETIZIONI,
		"fughe": 100.0 * fughe / RIPETIZIONI,
		"infiniti": 100.0 * infiniti / RIPETIZIONI,
		"risparmi": 100.0 * risparmi / RIPETIZIONI,
		"giri": float(somma_giri) / RIPETIZIONI,
		"danno": float(somma_danno) / RIPETIZIONI,
		"xp": float(xp_totale) / RIPETIZIONI,
	}

# --- i modi di giocare ------------------------------------------------------

func primo_bersaglio(scontro) -> Dictionary:
	var nemici: Array[Dictionary] = scontro.vivi(false)
	return nemici[0] if not nemici.is_empty() else {}

func strategia_attacca(scontro, _chi: Dictionary) -> Dictionary:
	var bersaglio := primo_bersaglio(scontro)
	return {"tipo": "difendi"} if bersaglio.is_empty() \
			else {"tipo": "attacca", "bersaglio": bersaglio}

func strategia_difendi(_scontro, _chi: Dictionary) -> Dictionary:
	return {"tipo": "difendi"}

func strategia_studia(scontro, chi: Dictionary) -> Dictionary:
	# guarda la creatura finche' c'e' qualcosa da capire, poi alza le mani.
	# Se e' risparmiabile insiste fino al numero di studi che serve: e' cosi'
	# che si scopre se quella strada e' percorribile senza morire nel mentre
	var bersaglio := primo_bersaglio(scontro)
	if bersaglio.is_empty():
		return {"tipo": "difendi"}
	var dati: Dictionary = GameState.personaggi.get(bersaglio.id, {})
	var studi_fatti := int(bersaglio.get("volte_studiato", 0))
	if dati.has("risparmio"):
		var richiesti := maxi(int(dati["risparmio"].get("studi_richiesti", 1)), 1)
		if studi_fatti < richiesti:
			return {"tipo": "studia", "bersaglio": bersaglio}
	elif studi_fatti < 3:
		return {"tipo": "studia", "bersaglio": bersaglio}
	return strategia_attacca(scontro, chi)

func strategia_casuale(scontro, _chi: Dictionary) -> Dictionary:
	var nemici: Array[Dictionary] = scontro.vivi(false)
	if nemici.is_empty():
		return {"tipo": "difendi"}
	var bersaglio: Dictionary = nemici[GameState.rng.randi_range(0, nemici.size() - 1)]
	match GameState.rng.randi_range(0, 2):
		0:
			return {"tipo": "attacca", "bersaglio": bersaglio}
		1:
			return {"tipo": "difendi"}
		_:
			return {"tipo": "studia", "bersaglio": bersaglio}

# --- il referto -------------------------------------------------------------

const SOGLIA_GIUSTO := 80.0   # sotto questa percentuale di vittorie, lo scontro non e' ancora alla portata

func livello_in_cui_diventa_giusto(id_nemico: String) -> int:
	# il numero piu' utile di tutta la tabella: da che livello in poi questo
	# scontro si vince andandoci dritto. 0 = mai, in nessuno dei livelli provati
	for livello: int in LIVELLI:
		for r in righe:
			if r.nemico == id_nemico and r.strategia == "attacca" \
					and int(r.livello) == livello and float(r.vittorie) >= SOGLIA_GIUSTO:
				return livello
	return 0

func stampa_tabella() -> void:
	print("A CHE LIVELLO OGNI SCONTRO DIVENTA GIUSTO")
	print("(livello minimo a cui si vince almeno l'%d%% delle volte andandoci dritto)\n" % int(SOGLIA_GIUSTO))
	var visti: Array[String] = []
	var mai: Array[String] = []
	for r in righe:
		if r.nemico in visti:
			continue
		visti.append(String(r.nemico))
		var livello := livello_in_cui_diventa_giusto(String(r.nemico))
		if livello == 0:
			mai.append("%s (%d hp, att %d)" % [r.nome, int(r.hp), int(r.att)])
		else:
			print("  L%-2d  %-30s %3d hp, att %d" % [livello, String(r.nome).substr(0, 30), int(r.hp), int(r.att)])
	if not mai.is_empty():
		print("\n  MAI, fino al livello %d:" % LIVELLI[LIVELLI.size() - 1])
		for nome in mai:
			print("    - " + nome)
	print("\nDA GUARDARE")
	for r in righe:
		# gli scontri che non finiscono, quelli che si vincono senza mai
		# attaccare (se "difendi" vince, quel nemico non e' una minaccia) e
		# quelli che durano una vita
		var motivo := ""
		if r.infiniti >= 50.0 and r.strategia == "attacca":
			motivo = "non finisce nemmeno attaccando"
		elif r.strategia == "difendi" and r.vittorie >= 50.0:
			motivo = "si vince senza mai attaccare"
		elif r.strategia == "attacca" and r.giri >= 20.0 and r.vittorie > 0.0:
			motivo = "%.0f giri per vincerlo" % r.giri
		if motivo != "":
			print("  L%-2d  %-30s %s" % [int(r.livello), String(r.nome).substr(0, 30), motivo])

func stat_di_prova(chiave: String, nome_ruolo: String, livello: int) -> int:
	# quanto vale una stat per un dato ruolo a un dato livello. Passa da una
	# creatura vera messa li' per un istante invece di rifare il conto: un
	# documento che si ricalcola i numeri per conto suo racconta i numeri suoi,
	# non quelli del gioco
	const FINTA := "__creatura_di_prova__"
	GameState.personaggi[FINTA] = {"id": FINTA, "ruolo": nome_ruolo, "livello": livello,
			"scala_col_giocatore": false}
	var valore := GameState.stat_di_ruolo(FINTA, chiave)
	GameState.personaggi.erase(FINTA)
	return valore

func curva_di_riferimento() -> String:
	# DOVE STANNO I NUMERI DELLE CREATURE, adesso che non stanno piu' nei file.
	#
	# Fino a poco fa qui c'era un "metro" scritto a mano per accorgersi di chi
	# era fuori scala, e serviva perche' le stat erano scritte una per una in
	# momenti diversi: un Ghoul di livello 8 con 350 hp accanto a un Oppresso di
	# livello 4 con 270. Adesso quel problema non esiste piu' - una creatura
	# dichiara livello e ruolo e i numeri escono da ruoli.json - e il metro non
	# serve. Serve il contrario: vedere che numeri sono usciti.
	var testo := "## Da dove escono i numeri delle creature\n\n"
	testo += "Nessuna creatura ha piu' hp, attacco, difesa, xp e tazo scritti a mano: dichiara a\n"
	testo += "che **livello** sta e che **ruolo** ha, e i numeri escono da `data/ruoli.json`. E\n"
	testo += "ruoli.json a sua volta non ha numeri suoi: ha **quote del protagonista**. La riga\n"
	testo += "\"protagonista\" qui sotto e' calcolata da `crescita.json` esattamente come la calcola\n"
	testo += "il gioco, quindi le due curve non possono divergere: e' una sola curva.\n\n"
	testo += "### Il metro: un nemico comune al tuo livello\n\n"
	testo += "| livello | il protagonista ha | un comune ha | scontri per salire | xp a scontro |\n"
	testo += "|--:|---|---|--:|--:|\n"
	for livello: int in [1, 2, 3, 5, 8, 12, 16, 20, 25, 30]:
		GameState.nuova_partita()
		GameState.livelli[GameState.id_protagonista] = livello
		cresci_fino_a(livello)
		testo += "| %d | %d hp, %d att, %d dif, %d vel | %d hp, %d att, %d dif, %d vel | %.1f | %d |\n" % [
				livello, GameState.stat_di("hp"), GameState.stat_di("attacco"),
				GameState.stat_di("difesa"), GameState.stat_di("velocita"),
				stat_di_prova("hp", "comune", livello), stat_di_prova("attacco", "comune", livello),
				stat_di_prova("difesa", "comune", livello), stat_di_prova("velocita", "comune", livello),
				GameState.scontri_per_livello(livello), stat_di_prova("xp", "comune", livello)]
	testo += "\n**\"Scontri per salire\"** e' la manopola del ritmo del gioco intero: l'esperienza di\n"
	testo += "una creatura non e' scelta, e' il fabbisogno del livello diviso per quel numero.\n"
	testo += "Prima l'esperienza era una retta e il fabbisogno una potenza, quindi al livello 1\n"
	testo += "bastavano 4 scontri e al livello 20 ne servivano 26 - e nessuno l'aveva mai misurato,\n"
	testo += "perche' nessuna prova guardava sopra il livello 8.\n\n"
	testo += "### Cosa cambia il ruolo (a livello 10)\n\n"
	testo += "| ruolo | hp | attacco | difesa | velocita | xp | tazo | cos'e' |\n"
	testo += "|---|--:|--:|--:|--:|--:|--:|---|\n"
	for nome_ruolo in GameState.ruoli.get("ruoli", {}):
		var descrizione: Dictionary = GameState.ruoli["ruoli"][nome_ruolo]
		testo += "| **%s** | %d | %d | %d | %d | %d | %d | %s |\n" % [nome_ruolo,
				stat_di_prova("hp", nome_ruolo, 10), stat_di_prova("attacco", nome_ruolo, 10),
				stat_di_prova("difesa", nome_ruolo, 10), stat_di_prova("velocita", nome_ruolo, 10),
				stat_di_prova("xp", nome_ruolo, 10), stat_di_prova("tazo", nome_ruolo, 10),
				String(descrizione.get("_cosa_e", ""))]
	testo += "\n### Le eccezioni dichiarate\n\n"
	testo += "Una creatura puo' ancora scrivere un numero a mano, e quel numero vince. Ma deve\n"
	testo += "dire perche' (campo `fuori_curva`), e `prova_curva_creature` fallisce se non lo fa:\n"
	testo += "cosi' un'eccezione resta un'eccezione invece di tornare a essere la regola.\n\n"
	testo += "| creatura | livello | ruolo | scritto a mano | perche' |\n|---|--:|---|---|---|\n"
	var fuori := 0
	for id_creatura in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_creatura]
		if not dati.has("ruolo"):
			continue
		var a_mano: Array[String] = []
		for chiave: String in ["hp", "attacco", "difesa", "velocita", "xp", "tazo"]:
			if dati.has(chiave):
				a_mano.append("%s %d" % [chiave, int(dati[chiave])])
		if a_mano.is_empty():
			continue
		fuori += 1
		testo += "| %s | %d | %s | %s | %s |\n" % [String(dati.get("nome", id_creatura)),
				int(dati.get("livello", 1)), String(dati.get("ruolo", "")),
				", ".join(a_mano), String(dati.get("fuori_curva", ""))]
	if fuori == 0:
		testo += "| — | | | | |\n"
	testo += "\n"
	GameState.nuova_partita()
	return testo

func scrivi_documento(durata: float) -> void:
	var testo := "# Bilanciamento (generato, non scrivere qui a mano)\n\n"
	testo += "Prodotto da `prove/Simulatore.gd`: **%d partite** giocate dal motore vero in %.0f secondi.\n\n" \
			% [righe.size() * RIPETIZIONI, durata]
	testo += "Non e' una stima e non e' un modello: e' `Combattimento.tscn` istanziata e giocata,\n"
	testo += "con Voce/Campo/Menu muti. Se questi numeri sono sbagliati, sono sbagliati anche\n"
	testo += "quando ci giochi tu.\n\n"
	testo += "Ogni riga e' la media su %d partite con semi fissi: due esecuzioni danno lo stesso\n" % RIPETIZIONI
	testo += "risultato, quindi una differenza qui e' sempre una differenza nel gioco.\n\n"
	testo += "**Il protagonista e' quello vero.** Nel gioco le stat non salgono col livello, salgono\n"
	testo += "con quello che hai fatto: per mesi qui saliva solo il livello, e la tabella misurava\n"
	testo += "uno arrivato al livello 8 senza aver mai combattuto. Adesso si applica il\n"
	testo += "`profilo_giocatore_tipo` di crescita.json prima di ogni scontro. Se quella stima e'\n"
	testo += "sbagliata, tutta questa tabella e' sbagliata: e' il numero piu' importante del file.\n\n"
	testo += "- **vinte / perse / ∞** — percentuale di partite. `∞` = non finisce entro %d giri\n" % LIMITE_GIRI
	testo += "- **giri** — durata media (un giro = tutti agiscono una volta)\n"
	testo += "- **danno** — punti vita persi in media dal protagonista (ne ha %d)\n" % int(GameState.stat_di("hp"))
	testo += "- **risp.** — percentuale di partite in cui la creatura e' stata risparmiata\n\n"
	testo += "## A che livello ogni scontro diventa giusto\n\n"
	testo += "Livello minimo a cui si vince almeno l'%d%% delle volte andandoci dritto.\n\n" % int(SOGLIA_GIUSTO)
	testo += "| creatura | id | hp | att | livello |\n|---|---|--:|--:|--:|\n"
	var visti: Array[String] = []
	for r in righe:
		if r.nemico in visti:
			continue
		visti.append(String(r.nemico))
		var livello := livello_in_cui_diventa_giusto(String(r.nemico))
		testo += "| %s | `%s` | %d | %d | %s |\n" % [r.nome, r.nemico, int(r.hp), int(r.att),
				("**mai**" if livello == 0 else str(livello))]
	testo += curva_di_riferimento()
	for livello: int in LIVELLI:
		testo += "## Protagonista di livello %d\n\n" % livello
		testo += "| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |\n"
		testo += "|---|---|---|--:|--:|--:|--:|--:|--:|--:|\n"
		for r in righe:
			if int(r.livello) != livello:
				continue
			testo += "| %s | `%s` | %s | %.0f%% | %.0f%% | %.0f%% | %.1f | %.1f | %.0f%% | %.0f |\n" % [
				r.nome, r.nemico, r.strategia, r.vittorie, r.sconfitte, r.infiniti,
				r.giri, r.danno, r.risparmi, r.xp]
		testo += "\n"
	var file := FileAccess.open("res://docs/bilanciamento.md", FileAccess.WRITE)
	if file != null:
		file.store_string(testo)
		file.close()
