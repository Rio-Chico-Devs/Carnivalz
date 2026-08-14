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
	righe.append_array(indice_dei_motti())
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
	var righe: Array[String] = [
		"# Il bestiario, e cosa sa fare",
		"",
		"> **Generato dal gioco**, non scritto a mano: `./strumenti/nemici.sh`. I numeri qui sotto",
		"> sono gli stessi che il combattimento usa in campo — escono dalla curva dei ruoli",
		"> (`data/ruoli.json`) e dalle mosse dichiarate in `data/personaggi.json`. Se cambi un",
		"> livello o una quota, rilancia lo strumento e questa pagina si aggiorna da sola.",
		"",
		"> ⚠️ **Non correggere questo file: si riscrive da capo a ogni lancio.** Le fonti sono",
		"> `data/personaggi.json` (mosse e frasi) e `data/tecnolog.json` (le schede di specie). Se ti",
		"> torna comodo scrivere le correzioni qui sopra il testo vecchio, va benissimo — ma mandamele",
		"> prima che qualcuno rilanci lo strumento, se no vanno perse.",
		"",
		"## Come si leggono i numeri",
		"",
		"- Le **statistiche** sono quelle della creatura al suo livello base. In gioco una creatura",
		"  non scende mai troppo sotto il tuo livello (il disallineamento la tira su), e quando",
		"  viene tirata su **rifà il conto sulla stessa curva** — quindi resta la stessa creatura,",
		"  più grande, non una creatura diversa.",
		"- Il **Valore** di una mossa si legge in due pezzi: il `×numero` è quante volte il suo colpo",
		"  normale vale quella mossa, e dopo la freccia c'è lo stesso conto già fatto per questa",
		"  creatura al suo livello. Qui sotto c'è un esempio intero, con tutto quello che succede al",
		"  colpo prima che ti arrivi addosso. Una mossa con un numero fisso è un'eccezione",
		"  dichiarata, e qui è segnata come tale.",
		"- **Cosa fa** è una descrizione che lo strumento ricava dal tipo di mossa: serve a te per",
		"  capirla in un colpo d'occhio, e **in gioco non compare da nessuna parte**. Il grassetto lì",
		"  dentro è solo tipografia di questa pagina (evidenzia la parola che conta: il nome di uno",
		"  stato, «tutta la squadra»). La frase che si legge davvero a schermo quando la mossa parte è",
		"  un'altra cosa, ed è sotto ogni tabella, nel **Motto**: quella si può riscrivere parola per",
		"  parola, ed è raccolta tutta insieme in fondo alla pagina.",
		"- **Quando** dice a quale condizione la mossa esiste. Una mossa fuori condizione non entra",
		"  nemmeno nel sorteggio: non è che «capita di rado», è che non c'è.",
		"- **Scelta** dice che quella mossa non si sorteggia: se la condizione c'è, la creatura la",
		"  *sceglie* (vince la priorità più alta). È lì che vive la sua testa.",
		"- **Ricarica** è quante sue battute deve aspettare prima di rifarla.",
		"- Ogni creatura ha **sei caselle**, anche quando ne usa tre: le libere sono il posto dove",
		"  decidere cosa aggiungere. Una casella libera non è una mossa debole — non esiste: il",
		"  sorteggio non la pesca, e la creatura tira il suo colpo normale come se non ci fosse.",
		"",
	]
	righe.append_array(spiegazione_del_danno())
	righe.append_array([
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
		"La **Filogenesi** è il corpo d'origine: a Meridia la stessa infezione ha preso corpi diversi,",
		"e la scheda lo dice — il Cittadino e l'Infetto Rapido sono tutti e due *umana*, il Divoratore",
		"di Carcasse è *ferina*, la Robo Pattuglia è *meccanica*, l'Oppresso è *rancore*.",
		"",
		"La **Specie** è il nome della cosa, non un aggettivo su come è venuta: *Zombie*, *Slime*,",
		"*Robot*. È il campo che lega creature diverse — Zombie Cittadino, Zombie Mostruoso e Orrore",
		"di Meridia sono la stessa specie a tre **Stadi**, e i due campi si leggono insieme. La",
		"**Classificazione** è il rango sulla scala di quella specie: base → variante base → superiore",
		"→ avanzato → calamità, più le forme che non stanno su nessuna scala (onirica, speciale).",
		"",
		"L'**Areale** è la **regione grande, non la stanza**: l'Oppresso lo incontri nello Squarcio",
		"Industriale, ma la sua regione è *Geodos*, di cui lo Squarcio è solo una frattura. La",
		"traduzione da zona a regione sta in un posto solo (`areale_per_zona`), così ribattezzare un",
		"mondo è una riga; e una specie che vive dove il gioco non ti porta ancora può scriversi",
		"l'areale a mano — lo Slime è su tre pianeti anche se lo incontri in una radura sola.",
		"",
		"**Denominazione** e **Metamorfosi** non si scrivono mai a mano: il nome è quello della",
		"creatura, e la metamorfosi dice «osservata» solo se hai incontrato anche la forma in cui si",
		"trasforma. È il tuo registro, non un'enciclopedia.",
		"",
		"## La regola che vale per tutte",
		"",
		"Sotto il **%d%% della sua vita** una creatura è *alle strette*: colpisce il **%d%% in più**" % [soglia, bonus],
		"e comincia a scegliere le mosse invece di sorteggiarle — chi sa curarsi si cura, chi ha un",
		"ultimo colpo in canna lo tira. Non è scritto creatura per creatura: è una riga sola in",
		"`data/ruoli.json`, così non può mancare a metà bestiario.",
	])
	return righe

func esempio_del_danno() -> Dictionary:
	# La creatura piu' bassa di livello che abbia una mossa a quota: e' l'esempio
	# piu' semplice possibile, e siccome lo si sceglie qui invece di scriverlo a
	# mano non puo' diventare falso quando si cambia una quota o un livello.
	var scelto := {}
	for chiave in GameState.personaggi:
		var id_creatura := String(chiave)
		if not combatte(id_creatura):
			continue
		var dati: Dictionary = GameState.personaggi.get(id_creatura, {})
		var livello := GameState.livello_base_nemico(id_creatura)
		if not scelto.is_empty() and int(scelto["livello"]) <= livello:
			continue
		for voce in dati.get("mosse", []):
			var mossa: Dictionary = voce
			if not mossa.has("quota"):
				continue
			var attacco := stat_di(id_creatura, "attacco", 1)
			var quota := float(mossa["quota"])
			scelto = {
				"livello": livello,
				"nome": String(dati.get("nome", id_creatura)),
				"mossa": String(mossa.get("nome", "?")),
				"quota": quota,
				"attacco": attacco,
				"colpo": maxi(int(round(attacco * quota)), 1),
			}
			break
	return scelto

func spiegazione_del_danno() -> Array[String]:
	# Il "→ 10" della colonna Valore e' il pezzo che si legge male: sembra IL
	# danno, ed e' solo il colpo prima che qualcuno lo fermi. Qui si dice cosa
	# gli succede dopo, con i numeri veri di data/regole.json invece che a
	# memoria: se Bru cambia il pavimento o la riduzione, cambia anche la pagina.
	var pavimento := int(round(float(GameState.regole.get("danno_minimo_percentuale", 0.1)) * 100))
	var per_livello := float(GameState.regole.get("riduzione_danno_per_livello", 0.02)) * 100.0
	var riduzione_max := int(round(float(GameState.regole.get("riduzione_danno_massima", 0.35)) * 100))
	var critico := numero(float(GameState.regole.get("critico_moltiplicatore", 1.5)))
	var meta_difesa := int(round(float(GameState.regole.get("critico_riduzione_difesa", 0.5)) * 100))
	var esempio := esempio_del_danno()
	var righe: Array[String] = []
	if esempio.is_empty():
		righe.append_array(["### Da «×quota → numero» a quanto fa male davvero", ""])
		righe.append("Il **×quota** è la regola vera, il numero dopo la freccia è lo stesso conto già fatto.")
	else:
		# la quota si scrive come la scrive la tabella, non "meglio": chi legge
		# deve poter ritrovare questa riga identica nella colonna Valore
		var quota := "%.2f" % float(esempio["quota"])
		righe.append_array([
			"### Da «×%s → %d» a quanto fa male davvero" % [quota, int(esempio["colpo"])],
			"",
			"Le due metà dicono la stessa cosa in due lingue.",
			"",
			"**%s** ha attacco %d. La sua «%s» vale `×%s`, cioè %s volte"
					% [String(esempio["nome"]), int(esempio["attacco"]),
					String(esempio["mossa"]), quota, quota],
			"il suo colpo normale: %d × %s fa **%d**, ed è il numero dopo la freccia."
					% [int(esempio["attacco"]), quota, int(esempio["colpo"])],
			"",
			"Il `×%s` è la regola, e vale **a qualunque livello**: è una frazione dell'attacco che la"
					% quota,
			"creatura ha *in quel momento*, quindi se lei cresce cresce anche il colpo. Il numero dopo",
			"la freccia è solo lo stesso conto già fatto per questa creatura al suo livello base.",
		])
	righe.append_array([
		"",
		"E soprattutto: quello è **il colpo che parte, non quello che ti arriva**. Prima di",
		"toccarti passa da qui, in quest'ordine:",
		"",
		"1. **se coglie in pieno** (critico) il colpo si moltiplica per **×%s** e la tua difesa"
				% critico,
		"   conta il %d%% di meno;" % meta_difesa,
		"2. **si toglie la tua difesa** — punto per punto, dal colpo;",
		"3. **sotto il pavimento non si scende.** Se la tua difesa regge il colpo intero passa **1**:",
		"   un graffio, mai zero, così un numero vola sempre. Se non lo regge, passa quel che resta",
		"   ma **mai meno del %d%% del colpo pieno** — la corazza riduce, non cancella;" % pavimento,
		"4. **il tuo livello smorza il resto**: %s%% in meno per ogni livello oltre il primo, fino a un"
				% numero(per_livello),
		"   massimo del %d%%. Vale solo per la tua squadra: è il premio per aver giocato." % riduzione_max,
		"",
	])
	if not esempio.is_empty():
		righe.append_array([
			"Quindi quel **%d** è il colpo su un bersaglio nudo. Addosso a te arriva quasi sempre più"
					% int(esempio["colpo"]),
			"piccolo, e più grosso solo in due casi: quando coglie in pieno, e quando la creatura è",
			"alle strette — la regola qui sotto, che la fa colpire più forte proprio mentre muore.",
			"",
		])
	return righe

func numero(valore: float) -> String:
	# 1.2 -> "1,2" e 2.0 -> "2": in un documento italiano la virgola, e niente
	# zeri di coda che facciano sembrare preciso quello che preciso non e'
	var testo := ("%.2f" % valore).replace(".", ",")
	while testo.ends_with("0"):
		testo = testo.substr(0, testo.length() - 1)
	if testo.ends_with(","):
		testo = testo.substr(0, testo.length() - 1)
	return testo

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
	righe.append_array(frasi_in_campo(mosse))
	for chiave in ["mossa_soglia_hp", "mossa_disperazione", "rigenerazione", "frenesia"]:
		if dati.has(chiave):
			righe.append("")
			righe.append("Ha anche **%s** (scritta a mano nei suoi dati, non nella tabella)." % chiave)
	righe.append_array(scheda_tecnolog(id_creatura))
	return righe

func motti_di(mosse: Array) -> Array[String]:
	# IL MOTTO: la riga che si legge davvero a schermo quando la mossa parte.
	# E' il campo "testo" della mossa, e prima non compariva da nessuna parte in
	# questa pagina. Bru l'aveva cercata, non l'aveva trovata, e aveva provato a
	# scriverla nel grassetto della colonna "Cosa fa" - che pero' e' solo
	# tipografia. Se il posto giusto non si vede, uno se ne inventa uno sbagliato
	var elenco: Array[String] = []
	var casella := 0
	for voce in mosse:
		var mossa: Dictionary = voce
		casella += 1
		if String(mossa.get("tipo", "")) == "-":
			continue
		var testo := String(mossa.get("testo", "")).strip_edges()
		if testo == "" or testo == "-":
			elenco.append("%d. *(nessun motto: parte in silenzio)*" % casella)
		else:
			elenco.append("%d. %s" % [casella, testo])
	return elenco

func frasi_in_campo(mosse: Array) -> Array[String]:
	var righe: Array[String] = []
	var elenco := motti_di(mosse)
	if elenco.is_empty():
		return righe
	righe.append("")
	righe.append("**Motto** — quello che si legge in campo quando la mossa parte:")
	righe.append("")
	righe.append_array(elenco)
	return righe

func indice_dei_motti() -> Array[String]:
	# Tutte le frasi salienti dei mostri in un posto solo. Sparse una per
	# creatura si correggono male: una accanto all'altra si sente subito chi
	# parla come chi, e chi non ha ancora niente da dire
	var righe: Array[String] = [
		"",
		"## Tutti i motti",
		"",
		"Ogni frase che una creatura dice in campo, tutte di fila. È la pagina su cui si sente se",
		"parlano con voci diverse — e quali creature non hanno ancora niente da dire.",
		"",
	]
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
		var dati: Dictionary = GameState.personaggi.get(id_creatura, {})
		var elenco := motti_di(dati.get("mosse", []))
		if elenco.is_empty():
			continue
		righe.append("**%s**" % String(dati.get("nome", id_creatura)))
		righe.append("")
		righe.append_array(elenco)
		righe.append("")
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
