extends Node

# IL DOCUMENTO DEI NEMICI, SCRITTO DAL GIOCO.
#
# Bru ha chiesto "un documento con i valori degli attacchi dei nemici". La
# tentazione era scriverlo a mano: una tabella bella, precisa, e sbagliata dopo
# la prima modifica ai dati - perche' un documento scritto a mano racconta il
# gioco del giorno in cui e' stato scritto, e nessuno se ne accorge finche' non
# ci si fida.
#
# Questo invece lo genera il gioco, dagli stessi identici numeri che usa in
# campo: le stat escono da GameState.stat_nemico (la curva dei ruoli), il danno
# di una mossa esce dalla stessa quota che leggera' il motore. Se una creatura
# cambia livello o ruolo, il documento cambia da solo alla prossima esecuzione.
#
#   ./strumenti/nemici.sh      ->  docs/nemici.md
#
# Non e' una prova e non fallisce niente: e' una fotografia. La prova che i
# numeri stiano in piedi e' un'altra cosa (prove/simula.sh).

const USCITA := "res://docs/nemici.md"

# le mosse che non fanno danno: nella tabella al posto del numero va cosa fanno
const SENZA_DANNO := ["difendi", "buff_attacco", "buff_difesa", "buff_fattore",
		"evoca", "sacrificio", "cura", "stato", "incendia"]

func _ready() -> void:
	var righe: Array[String] = []
	righe.append_array(intestazione())
	var per_zona := raggruppa()
	for zona in per_zona:
		righe.append("")
		righe.append("## %s" % zona)
		for id_creatura in per_zona[zona]:
			righe.append_array(scheda(String(id_creatura)))
	var testo := "\n".join(righe) + "\n"
	var file := FileAccess.open(USCITA, FileAccess.WRITE)
	if file == null:
		push_error("SchedaNemici: non riesco a scrivere %s" % USCITA)
		get_tree().quit(1)
		return
	file.store_string(testo)
	file.close()
	print("scritto %s (%d righe, %d creature)" % [USCITA, righe.size(), quante()])
	get_tree().quit()

func quante() -> int:
	var totale := 0
	for id_creatura in GameState.personaggi:
		if combatte(String(id_creatura)):
			totale += 1
	return totale

func combatte(id_creatura: String) -> bool:
	var dati: Dictionary = GameState.personaggi.get(id_creatura, {})
	return dati.has("ruolo") and String(dati.get("ruolo", "")) != "oggetto_scena"

func raggruppa() -> Dictionary:
	# in ordine di livello: e' l'ordine in cui uno le incontra, ed e' l'unico
	# ordine in cui questo documento si legge invece di consultarsi
	var per_fascia := {
		"Livelli 1-5 — il tutorial e le prime crepe": [],
		"Livelli 6-10 — il mestiere": [],
		"Livelli 11-15 — la Rocca e la Casa": [],
		"Livelli 16 e oltre — le fonti": [],
	}
	var ordinate: Array[String] = []
	for id_creatura in GameState.personaggi:
		if combatte(String(id_creatura)):
			ordinate.append(String(id_creatura))
	ordinate.sort_custom(func(a: String, b: String) -> bool:
		var la := GameState.livello_base_nemico(a)
		var lb := GameState.livello_base_nemico(b)
		if la != lb:
			return la < lb
		return a < b)
	for id_creatura in ordinate:
		var livello := GameState.livello_base_nemico(id_creatura)
		if livello <= 5:
			per_fascia["Livelli 1-5 — il tutorial e le prime crepe"].append(id_creatura)
		elif livello <= 10:
			per_fascia["Livelli 6-10 — il mestiere"].append(id_creatura)
		elif livello <= 15:
			per_fascia["Livelli 11-15 — la Rocca e la Casa"].append(id_creatura)
		else:
			per_fascia["Livelli 16 e oltre — le fonti"].append(id_creatura)
	return per_fascia

func intestazione() -> Array[String]:
	var disperazione: Dictionary = GameState.ruoli.get("disperazione", {})
	var soglia := int(round(float(disperazione.get("soglia", 0.3)) * 100))
	var bonus := int(round(float(disperazione.get("bonus_attacco", 0.3)) * 100))
	return [
		"# Il bestiario, e cosa sa fare",
		"",
		"> **Generato dal gioco**, non scritto a mano: `./strumenti/nemici.sh`. I numeri qui sotto",
		"> sono gli stessi che il combattimento usa in campo — escono dalla curva dei ruoli",
		"> (`data/ruoli.json`) e dalle mosse dichiarate in `data/personaggi.json`. Se cambi un",
		"> livello o una quota, rilancia lo strumento e questa pagina si aggiorna da sola.",
		"",
		"## Come si leggono i numeri",
		"",
		"- Le **statistiche** sono quelle della creatura al suo livello base. In gioco una creatura",
		"  non scende mai troppo sotto il tuo livello (il disallineamento la tira su), e quando",
		"  viene tirata su **rifà il conto sulla stessa curva** — quindi resta la stessa creatura,",
		"  più grande, non una creatura diversa.",
		"- Il **danno di una mossa** è una *quota* dell'attacco che la creatura ha in quel momento.",
		"  «×1,4» vuol dire una volta e mezza scarsa il suo colpo normale, a qualunque livello.",
		"  Una mossa con un numero fisso è un'eccezione dichiarata, e qui è segnata come tale.",
		"- **Quando** dice a quale condizione la mossa esiste. Una mossa fuori condizione non entra",
		"  nemmeno nel sorteggio: non è che «capita di rado», è che non c'è.",
		"- **Scelta** dice che quella mossa non si sorteggia: se la condizione c'è, la creatura la",
		"  *sceglie* (vince la priorità più alta). È lì che vive la sua testa.",
		"- **Ricarica** è quante sue battute deve aspettare prima di rifarla.",
		"- Ogni creatura ha **sei caselle**, anche quando ne usa tre: le libere sono il posto dove",
		"  decidere cosa aggiungere. Una casella libera non è una mossa debole — non esiste: il",
		"  sorteggio non la pesca, e la creatura tira il suo colpo normale come se non ci fosse.",
		"",
		"### Cos'è una «battuta»",
		"",
		"Non ci sono più i turni: ogni creatura ha una **ricarica** che scorre da sola, e quando",
		"finisce quella creatura agisce. Una *battuta* è un suo ciclo di ricarica — «per 3 battute»",
		"vuol dire **tre volte che tocca a lei**, non tre secondi e non tre tue mosse.",
		"",
		"Il che vuol dire due cose che vale la pena avere in testa:",
		"",
		"- **dura più a lungo su una creatura lenta.** La ricarica esce dalla velocità: un corazzato",
		"  che si irrigidisce «per 3 battute» resta chiuso cinque o sei secondi buoni, un veloce che",
		"  fa la stessa cosa poco più di due. È coerente — sono anche tre sue azioni in tutti e due",
		"  i casi — ma a schermo si sente come una durata diversa;",
		"- **il conto scala all'inizio del suo turno, non alla fine.** Una mossa lanciata alla sua",
		"  battuta N protegge per tutta la N, la N+1 e la N+2, e all'inizio della N+3 è già scaduta:",
		"  copre le sue due azioni successive e tutto il tempo che ci sta in mezzo, compreso quello",
		"  in cui la stai colpendo tu.",
		"",
		"Lo stesso potenziamento **non si somma con se stesso**: rifarlo rinnova la durata, non",
		"raddoppia il numero. Due mosse *diverse* che alzano la stessa statistica si sommano ancora.",
		"",
		"## Il tecno log",
		"",
		"Di ogni creatura c'è una **scheda di specie** che lo Studio riempie a strati, uno per",
		"volta: il primo studio dice chi è e da dove viene, il secondo com'è fatta, il terzo come si",
		"comporta. In gioco si legge nel Bestiario; qui sotto c'è già tutta, perché è il documento",
		"su cui si correggono i testi — e i testi non si correggono tre righe per volta.",
		"",
		"La **Filogenesi** è il campo che Bru ha chiesto per primo: il corpo d'origine. A Meridia la",
		"stessa infezione ha preso corpi diversi, e la scheda lo dice — il Cittadino e l'Infetto",
		"Rapido sono tutti e due *umana*, il Divoratore di Carcasse è *ferina*, la Robo Pattuglia è",
		"*meccanica*. **Denominazione**, **Areale** e **Metamorfosi** non sono scritti a mano: il",
		"nome è quello della creatura, l'areale esce da dove compare davvero nei file delle zone, e",
		"la metamorfosi dice «osservata» solo se hai incontrato anche la forma in cui si trasforma.",
		"",
		"## La regola che vale per tutte",
		"",
		"Sotto il **%d%% della sua vita** una creatura è *alle strette*: colpisce il **%d%% in più**" % [soglia, bonus],
		"e comincia a scegliere le mosse invece di sorteggiarle — chi sa curarsi si cura, chi ha un",
		"ultimo colpo in canna lo tira. Non è scritto creatura per creatura: è una riga sola in",
		"`data/ruoli.json`, così non può mancare a metà bestiario.",
	]

func scheda(id_creatura: String) -> Array[String]:
	var dati: Dictionary = GameState.personaggi.get(id_creatura, {})
	var righe: Array[String] = []
	var livello := GameState.livello_base_nemico(id_creatura)
	righe.append("")
	righe.append("### %s — livello %d, %s" % [
			String(dati.get("nome", id_creatura)), livello, String(dati.get("ruolo", "?"))])
	var descrizione := String(dati.get("descrizione", ""))
	if descrizione != "":
		righe.append("*%s*" % descrizione)
	righe.append("")
	var voci: Array[String] = []
	voci.append("`%s`" % id_creatura)
	voci.append("♥ %d" % stat_di(id_creatura, "hp", 25))
	voci.append("attacco %d" % stat_di(id_creatura, "attacco", 1))
	voci.append("difesa %d" % stat_di(id_creatura, "difesa", 0))
	voci.append("velocità %d" % stat_di(id_creatura, "velocita", 3))
	voci.append("xp %d" % stat_di(id_creatura, "xp", 10))
	if String(dati.get("elemento", "")) != "":
		voci.append("elemento %s" % String(dati["elemento"]))
	righe.append(" · ".join(voci))
	righe.append("")
	var mosse: Array = dati.get("mosse", [])
	var piene := 0
	for mossa in mosse:
		if String(mossa.get("tipo", "")) != "-":
			piene += 1
	if piene == 0:
		righe.append("Sei caselle, tutte libere: il suo turno lo detta un copione (tutorial o incontro scriptato).")
		righe.append_array(scheda_tecnolog(id_creatura))
		return righe
	righe.append("**Mosse: %d su %d caselle.**" % [piene, mosse.size()])
	righe.append("")
	righe.append("| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |")
	righe.append("| --: | --- | --- | --- | --- | --- | --- |")
	var casella := 0
	for mossa in mosse:
		casella += 1
		if String(mossa.get("tipo", "")) == "-":
			# LA CASELLA LIBERA SI VEDE. E' il motivo per cui ce ne sono sei
			# anche a chi ne usa tre: sono il posto dove Bru decidera' cosa
			# aggiungere, e un posto che non si vede non e' un posto
			righe.append("| %d | — | *casella libera* | — | — | — | — |" % casella)
			continue
		righe.append("| %d | %s | %s | %s | %s | %s | %s |" % [
			casella,
			String(mossa.get("nome", mossa.get("id", "?"))),
			effetto_di(mossa),
			valore_di(id_creatura, mossa),
			condizione_di(mossa),
			("priorità %d" % int(mossa["priorita"])) if int(mossa.get("priorita", 0)) > 0 else "sorteggio",
			("%d battute" % int(mossa["ricarica"])) if int(mossa.get("ricarica", 0)) > 0 else "—",
		])
	for chiave in ["mossa_soglia_hp", "mossa_disperazione", "rigenerazione", "frenesia"]:
		if dati.has(chiave):
			righe.append("")
			righe.append("Ha anche **%s** (scritta a mano nei suoi dati, non nella tabella)." % chiave)
	righe.append_array(scheda_tecnolog(id_creatura))
	return righe

func scheda_tecnolog(id_creatura: String) -> Array[String]:
	# IL TECNO LOG COM'E' SCRITTO, tutto insieme. In gioco si vede a strati - uno
	# per studio - ma qui serve la pagina intera: e' il documento su cui Bru
	# corregge i testi, e non si correggono tre righe per volta.
	var righe: Array[String] = ["", "**Tecno log**", ""]
	righe.append("| Campo | Rilevamento |")
	righe.append("| --- | --- |")
	for riga in GameState.tecnolog_di(id_creatura):
		righe.append("| %s | %s |" % [String(riga.get("etichetta", "")),
				String(riga.get("valore", "")).replace("|", "/")])
	righe.append("")
	righe.append("*Studi necessari per la pagina intera: %d.*" % GameState.strati_tecnolog())
	return righe

func stat_di(id_creatura: String, chiave: String, difetto: int) -> int:
	# stessa strada che fa aggiungi_combattente: il numero scritto a mano nella
	# creatura vince (e' un'eccezione dichiarata), se no lo da' la curva del suo
	# ruolo al suo livello. Se la curva non ha niente da dire resta il difetto,
	# che e' lo stesso che userebbe il combattimento
	var dati: Dictionary = GameState.personaggi.get(id_creatura, {})
	if dati.has(chiave):
		return int(dati[chiave])
	var da_curva := GameState.stat_di_ruolo(id_creatura, chiave,
			GameState.livello_base_nemico(id_creatura))
	return da_curva if da_curva > 0 else difetto

func effetto_di(mossa: Dictionary) -> String:
	var tipo := String(mossa.get("tipo", ""))
	match tipo:
		"difendi": return "alza la guardia"
		"attacco_forte": return "un colpo pesante su uno solo"
		"spezza_guardia": return "colpisce e **apre la guardia**"
		"meta_vita": return "toglie **metà** della vita che ti resta"
		"attacco_multiplo": return "%d colpi su bersagli a caso" % int(mossa.get("colpi", 2))
		"attacco_tutti": return "colpisce **tutta la squadra**"
		"buff_attacco": return "si potenzia l'attacco (+%d per %d battute)" % [int(mossa.get("valore", 1)), int(mossa.get("turni", 2))]
		"buff_difesa": return "si chiude (difesa +%d per %d battute)" % [int(mossa.get("valore", 1)), int(mossa.get("turni", 2))]
		"buff_fattore": return "si alza il Fattore di %d" % int(mossa.get("valore", 10))
		"evoca": return "chiama %d × `%s`" % [int(mossa.get("quantita", 1)), String(mossa.get("valore", "?"))]
		"sacrificio": return "uccide un suo alleato per farsi più forte"
		"autolesione": return "si ferisce da sola, e la cosa vi pesa addosso"
		"incendia": return "ti dà fuoco (%d a battuta)" % int(mossa.get("valore", 1))
		"cura": return "**si rimette in piedi** (+%d%% della vita massima%s)" % [
				int(round(float(mossa.get("quota_vita", 0.25)) * 100)),
				", su un alleato" if String(mossa.get("bersaglio", "se_stesso")) == "alleato" else ""]
		"rubavita": return "colpisce e **si nutre** (il %d%% del danno torna a lei)" % int(round(float(mossa.get("quota_furto", 0.5)) * 100))
		"stato": return "nessun danno: lascia addosso **%s**" % String(
				GameState.stati.get(String(mossa.get("stato", "")), {}).get("nome", mossa.get("stato", "?")))
	return tipo

func valore_di(id_creatura: String, mossa: Dictionary) -> String:
	if String(mossa.get("tipo", "")) in SENZA_DANNO:
		return "—"
	if mossa.has("valore"):
		return "**%d fisso**" % int(mossa["valore"])
	if mossa.has("quota"):
		var attacco := stat_di(id_creatura, "attacco", 1)
		var colpo := maxi(int(round(attacco * float(mossa["quota"]))), 1)
		var quante := maxi(int(mossa.get("colpi", 1)), 1)
		if quante > 1:
			return "×%.2f → %d a colpo (%d totali)" % [float(mossa["quota"]), colpo, colpo * quante]
		return "×%.2f → %d" % [float(mossa["quota"]), colpo]
	return "come il suo colpo normale"

func condizione_di(mossa: Dictionary) -> String:
	var quando: Dictionary = mossa.get("quando", {})
	if quando.is_empty():
		return "sempre"
	var pezzi: Array[String] = []
	if quando.has("vita_sotto"):
		pezzi.append("sotto il %d%% di vita" % int(round(float(quando["vita_sotto"]) * 100)))
	if quando.has("vita_sopra"):
		pezzi.append("sopra il %d%% di vita" % int(round(float(quando["vita_sopra"]) * 100)))
	if quando.has("bersaglio_vita_sotto"):
		pezzi.append("se qualcuno di voi è sotto il %d%%" % int(round(float(quando["bersaglio_vita_sotto"]) * 100)))
	if quando.has("alleati_almeno"):
		pezzi.append("con almeno %d alleati in piedi" % int(quando["alleati_almeno"]))
	if quando.has("alleati_al_massimo"):
		pezzi.append("con al più %d alleati" % int(quando["alleati_al_massimo"]))
	if quando.has("battuta_almeno"):
		pezzi.append("dalla sua %da battuta" % int(quando["battuta_almeno"]))
	if quando.has("senza_stato"):
		pezzi.append("se non ha già %s" % String(quando["senza_stato"]))
	return ", ".join(pezzi)
