class_name Merce
extends RefCounted

# COSA C'E' SUGLI SCAFFALI, e se lo puoi prendere. Senza disegnare niente.
#
# Stava dentro Negozio.gd, mescolato ai bottoni. Adesso che il negozio e' una
# vetrina con le carte (vedi Negozio.gd) le domande sono le stesse di prima -
# che cosa fa, ne ho gia', me lo posso permettere - ma le risposte servono in
# quattro posti diversi della schermata: la carta, la vetrina, la descrizione e
# il tasto COMPRA. Stanno qui una volta sola, e si provano senza aprire niente.

# l'ordine conta: prima quello che serve adesso, poi quello che serve dopo
const CATEGORIE := [
	{"tipi": ["consumabile"], "titolo": "Da usare in combattimento"},
	{"tipi": ["arma", "stigma"], "titolo": "Armi e stigmi"},
	{"tipi": ["accessorio"], "titolo": "Accessori"},
]
const ALTRO := "Altro"
const BARATTO := "Baratti"

# L'EFFETTO DI UN OGGETTO, detto in due modi: la frase per la descrizione
# ("+8 vita") e il pezzo corto per i riquadri della vetrina (+8 / VITA). Una
# tabella sola, cosi' le due cose non si contraddicono mai.
const EFFETTI := {
	"hp": ["%+d vita", "VITA"],
	"aura": ["%+d aura", "AURA"],
	"stress": ["stress %+d", "STRESS"],
	"danno": ["%d danni%s, ignora le difese", "DANNI"],
	"speranza": ["speranza %+d", "SPERANZA"],
	"difesa_incontro": ["difesa %+d per tutto lo scontro", "DIFESA"],
	"attacco": ["attacco %+d", "ATTACCO"],
	"difesa": ["difesa %+d", "DIFESA"],
	"velocita": ["velocità %+d", "VELOCITÀ"],
	"hp_max": ["vita massima %+d", "VITA MAX"],
	"aura_max": ["aura massima %+d", "AURA MAX"],
	"aura_per_turno": ["aura per turno %+d", "AURA / TURNO"],
	"resistenza_maledizione": ["maledizione: %+d rintocchi prima della fine", "MALEDIZIONE"],
}
# l'elemento del danno detto come aggettivo: "6 danni da fuoco"
const ELEMENTI := {"fuoco": "da fuoco", "veleno": "da veleno", "elettrico": "elettrici",
		"psico": "psichici", "oscuro": "oscuri"}
# perche' un oggetto non ti arriverebbe: [la frase sotto il tasto, la parola
# sotto la carta, se e' un problema (cremisi) o solo un fatto (grigio)]
const RIFIUTI := {
	"gia_tuo": ["ce l'hai già", "GIÀ TUO", false],
	"al_massimo": ["più spazio di così non c'è", "AL MASSIMO", false],
	"sacca_piena": ["la sacca è piena", "SACCA PIENA", true],
	"niente_posto": ["non hai più posto per tenerlo", "NIENTE POSTO", true],
}
# i tipi che si hanno una volta sola: il secondo non si aggiunge
const UNICI := ["arma", "accessorio", "stigma", "chiave"]
const PROTEZIONI := {
	"scudo_primo_stato": ["respinge il primo male che ti prende", "1°", "SCUDO"],
	"resurrezione_dimezzata": ["ti rimette in piedi una volta, a metà vita", "½", "RINASCITA"],
}


# --- lo scaffale -------------------------------------------------------------

static func voci(negozio: Dictionary) -> Array[Dictionary]:
	# TUTTO QUELLO CHE UN NEGOZIO OFFRE, in fila come sta sullo scaffale: per
	# mestiere (CATEGORIE), poi il resto, poi i baratti. Ogni voce e' un
	# dizionario solo, che la carta e la vetrina leggono allo stesso modo
	var in_vendita := stock_disponibile(negozio)
	var fila: Array[Dictionary] = []
	for categoria in CATEGORIE:
		for voce in in_vendita:
			if tipo_di(voce) in categoria["tipi"]:
				fila.append(vendita(voce, String(categoria["titolo"])))
	for voce in in_vendita:
		if categoria_di(tipo_di(voce)) == ALTRO:
			fila.append(vendita(voce, ALTRO))
	for baratto in negozio.get("baratti", []):
		fila.append({"tipo": "baratto", "oggetto": String(baratto.get("produce", "")),
				"richiede": baratto.get("richiede", []), "categoria": BARATTO})
	return fila


static func stock_disponibile(negozio: Dictionary) -> Array:
	var in_vendita: Array = []
	for voce in negozio.get("stock", []):
		if int(voce.get("da_fonti", 0)) > GameState.fonti_estinte:
			continue  # lo stock evolve man mano che estingui fonti
		in_vendita.append(voce)
	return in_vendita


static func vendita(voce: Dictionary, categoria: String) -> Dictionary:
	return {"tipo": "vendita", "oggetto": String(voce.get("oggetto", "")),
			"prezzo": int(voce.get("prezzo", 0)), "categoria": categoria}


static func tipo_di(voce: Dictionary) -> String:
	return tipo_oggetto(String(voce.get("oggetto", "")))


static func categoria_di(tipo: String) -> String:
	for categoria in CATEGORIE:
		if tipo in categoria["tipi"]:
			return String(categoria["titolo"])
	return ALTRO


# --- me lo posso permettere --------------------------------------------------

static func perche_no(voce: Dictionary) -> String:
	# "" se si puo' prendere; se no, il motivo in due o tre parole. E' quello
	# che si legge sotto il tasto spento: un tasto grigio senza un perche' e'
	# un tasto rotto
	var ostacolo := ostacolo_di(voce)
	if ostacolo.is_empty():
		return ""
	return String(ostacolo["frase"])


static func stato_breve(voce: Dictionary) -> Dictionary:
	# LA RIGA SOTTO LA CARTA: due o tre parole, e se sono un problema (in
	# cremisi) o un'informazione (in grigio). E' la risposta a "posso?" e "ne
	# ho gia'?" senza aprire niente
	var ostacolo := ostacolo_di(voce)
	if not ostacolo.is_empty():
		return {"testo": String(ostacolo["corto"]), "problema": bool(ostacolo["problema"])}
	if String(voce.get("tipo", "")) == "baratto":
		return {"testo": "SI PUÒ FARE", "problema": false}
	var quanti := quanti_in_sacca(String(voce.get("oggetto", "")))
	return {"testo": "IN SACCA ×%d" % quanti if quanti > 0 else "", "problema": false}


static func ostacolo_di(voce: Dictionary) -> Dictionary:
	# COSA IMPEDISCE DI PRENDERLA, detto in due modi: la frase sotto il tasto e
	# la parola sotto la carta. {} se niente. L'ordine e' quello in cui si
	# risolve: prima se l'oggetto ti arriverebbe davvero, poi se lo paghi
	var id_oggetto := String(voce.get("oggetto", ""))
	var no := non_ci_sta(id_oggetto)
	if no != "":
		return {"frase": String(RIFIUTI[no][0]), "corto": String(RIFIUTI[no][1]), "problema": bool(RIFIUTI[no][2])}
	if String(voce.get("tipo", "")) == "baratto":
		# quanti, non quali: i quali li dicono i riquadri della vetrina, e una
		# fila di nomi sotto il tasto non ci stava
		var richiesti: Array = voce.get("richiede", [])
		var mancano := pezzi_mancanti(richiesti)
		if mancano == 0:
			return {}
		return {"frase": "ti manca un materiale" if mancano == 1 else "ti mancano %d materiali" % mancano,
				"corto": "%d/%d MATERIALI" % [richiesti.size() - mancano, richiesti.size()], "problema": true}
	var prezzo := int(voce.get("prezzo", 0))
	if GameState.tazo < prezzo:
		return {"frase": "ti mancano %d Tazo" % (prezzo - GameState.tazo),
				"corto": "MANCANO %d" % (prezzo - GameState.tazo), "problema": true}
	return {}


static func non_ci_sta(id_oggetto: String) -> String:
	# PERCHE' L'OGGETTO NON TI ARRIVEREBBE, anche pagandolo: le regole di
	# GameState.aggiungi_oggetto lette prima di chiamarlo. Senza, un'arma che
	# avevi gia' si pagava e non arrivava niente (aggiungi_oggetto dice di si'
	# e non aggiunge), e la sacca allargata restava piena a 20 per il negozio.
	# Una chiave di RIFIUTI, o "" se c'e' posto
	var tipo := tipo_oggetto(id_oggetto)
	if tipo == "pila":
		return ""
	if tipo == "spazio":
		var categoria := String(GameState.dati_oggetto(id_oggetto).get("categoria", "consumabili"))
		var scala: Array = GameState.regole.get("zaino", {}).get(categoria, {}).get("scala", [])
		return "al_massimo" if GameState.spazi_comprati(categoria) >= scala.size() else ""
	if gia_tuo(id_oggetto):
		return "gia_tuo"
	var scomparto := GameState.categoria_zaino(id_oggetto)
	if GameState.capacita_zaino(scomparto) >= 0 and GameState.spazio_libero(scomparto) <= 0:
		return "sacca_piena" if scomparto == "consumabili" else "niente_posto"
	return ""


static func capienza_sacca() -> int:
	# la sacca vera, con lo spazio comprato: non il numero scritto nelle regole
	return GameState.capacita_zaino("consumabili")


static func materiali(richiesti: Array) -> Array[Dictionary]:
	# I MATERIALI DI UN BARATTO, raggruppati: {id, nome, servono, hai}. Due
	# rottami richiesti sono una riga sola che dice 1/2, e un materiale chiesto
	# due volte va posseduto due volte: si scala la copia, non l'originale
	var disponibili: Array = GameState.collezionabili.duplicate()
	var righe: Array[Dictionary] = []
	var dove := {}
	for materiale in richiesti:
		var id_materiale := String(materiale)
		if not dove.has(id_materiale):
			dove[id_materiale] = righe.size()
			righe.append({"id": id_materiale, "nome": nome_di(id_materiale), "servono": 0, "hai": 0})
		var riga: Dictionary = righe[int(dove[id_materiale])]
		riga["servono"] = int(riga["servono"]) + 1
		if id_materiale in disponibili:
			disponibili.erase(id_materiale)
			riga["hai"] = int(riga["hai"]) + 1
	return righe


static func pezzi_mancanti(richiesti: Array) -> int:
	# quanti pezzi mancano in tutto, contando i doppioni: e' il numero che
	# decide se il baratto si fa
	var mancano := 0
	for riga in materiali(richiesti):
		mancano += int(riga["servono"]) - int(riga["hai"])
	return mancano


static func prendi(voce: Dictionary) -> bool:
	# l'acquisto o il baratto, per davvero. I Tazo se ne vanno ADESSO: il numero
	# a schermo li insegue dopo (vedi Conto.gd)
	var id_oggetto := String(voce.get("oggetto", ""))
	if String(voce.get("tipo", "")) == "baratto":
		return GameState.baratta(voce.get("richiede", []), id_oggetto)
	return GameState.compra(id_oggetto, int(voce.get("prezzo", 0)))


# --- ne ho gia' --------------------------------------------------------------

static func quanti_in_sacca(id_oggetto: String) -> int:
	return GameState.sacca.count(id_oggetto)


static func quanti_ne_hai(id_oggetto: String) -> String:
	# comprare il secondo uguale dev'essere una scelta, non una distrazione
	if tipo_oggetto(id_oggetto) == "consumabile":
		var quanti := quanti_in_sacca(id_oggetto)
		return "" if quanti == 0 else "ne hai già %d in sacca" % quanti
	if not GameState.posseduto_equipaggiabile(id_oggetto):
		return ""
	var id_portatore := GameState.portatore_di(id_oggetto)
	if id_portatore == "":
		return "ne hai già uno, nell'armadio"
	return "ne hai già uno, addosso a %s" % SchedaOggetto.nome_di_classe(id_portatore)


static func quanti_ne_possiedi(id_oggetto: String) -> Array[String]:
	# IL NUMERO ACCANTO ALLA MINIATURA e cosa conta: le copie in sacca, gli
	# allargamenti gia' fatti, o se l'hai. ["", ""] per quello che non si conta
	match tipo_oggetto(id_oggetto):
		"consumabile":
			return ["×%d" % quanti_in_sacca(id_oggetto), "IN SACCA"]
		"spazio":
			var categoria := String(GameState.dati_oggetto(id_oggetto).get("categoria", "consumabili"))
			var scala: Array = GameState.regole.get("zaino", {}).get(categoria, {}).get("scala", [])
			return ["%d/%d" % [GameState.spazi_comprati(categoria), scala.size()], "ALLARGATO"]
		"pila", "collezionabile":
			return ["", ""]
	return ["×%d" % (1 if gia_tuo(id_oggetto) else 0), "POSSEDUTI"]


static func gia_tuo(id_oggetto: String) -> bool:
	# il timbro sulla carta: un oggetto che si ha una volta sola, e che hai. Un
	# consumabile no - di quelli se ne comprano dieci, e dieci timbri non
	# dicono niente
	return tipo_oggetto(id_oggetto) in UNICI and GameState.posseduto_equipaggiabile(id_oggetto)


static func tipo_oggetto(id_oggetto: String) -> String:
	return String(GameState.dati_oggetto(id_oggetto).get("tipo", "consumabile"))


# --- che cosa fa -------------------------------------------------------------

static func effetto_di(oggetto: Dictionary) -> Dictionary:
	return oggetto.get("effetto_equipaggiato", oggetto.get("effetto", {}))


static func riassunto_effetto(oggetto: Dictionary, se_niente := "—") -> String:
	# l'effetto in numeri. Le chiavi sono le stesse che legge il combattimento,
	# quindi un oggetto nuovo si racconta da solo senza toccare questo file. E'
	# l'unico posto che lo dice: negozio, scheda e zaino leggono tutti da qui
	var voci_testo: Array[String] = []
	var effetto := effetto_di(oggetto)
	for chiave in effetto:
		var frase := frase_di(String(chiave), effetto)
		if frase != "":
			voci_testo.append(frase)
	var protezione: Array = PROTEZIONI.get(String(effetto.get("tipo", "")), [])
	if not protezione.is_empty():
		voci_testo.append(String(protezione[0]))
	return ", ".join(voci_testo) if not voci_testo.is_empty() else se_niente


static func frase_di(chiave: String, effetto: Dictionary) -> String:
	# UNA CHIAVE, UNA FRASE. Le chiavi che accompagnano un'altra (l'elemento
	# del danno, la quota della rigenerazione) non parlano da sole: le dice la
	# chiave che accompagnano. Prima dicevano "elemento +0" sul Petardo
	var valore: Variant = effetto[chiave]
	match chiave:
		"tipo", "elemento", "rigenerazione_percentuale":
			return ""
		"cura_stato":
			return "toglie %s" % nome_stato(String(valore)).to_lower()
		"cura_stati":
			return "toglie ogni male" if bool(valore) else ""
		"danno":
			var elemento := String(ELEMENTI.get(String(effetto.get("elemento", "")), ""))
			return String(EFFETTI["danno"][0]) % [int(valore), " " + elemento if elemento != "" else ""]
		"rigenerazione_battute":
			return "rigenera il %d%% della vita a battuta, per %d battute" % [quota_rigenerata(effetto), int(valore)]
	if EFFETTI.has(chiave):
		return String(EFFETTI[chiave][0]) % int(valore)
	# una chiave nuova che nessuno ha ancora scritto qui: meglio le sue parole
	# che niente, ma senza trattini bassi e senza inventare un numero
	if not (valore is int or valore is float):
		return ""
	return "%s %+d" % [chiave.replace("_", " "), int(valore)]


static func quota_rigenerata(effetto: Dictionary) -> int:
	# lo stesso 10% che il combattimento usa se l'oggetto non lo dice
	return roundi(float(effetto.get("rigenerazione_percentuale", 0.10)) * 100.0)


static func pezzi_effetto(oggetto: Dictionary) -> Array[Dictionary]:
	# I RIQUADRI DELLA VETRINA: un numero grande e una parola. Tre al massimo,
	# perche' tre ce ne stanno; la frase intera e' nella descrizione
	var pezzi: Array[Dictionary] = []
	var effetto := effetto_di(oggetto)
	for chiave in effetto:
		var nome_chiave := String(chiave)
		if EFFETTI.has(nome_chiave):
			var formato := "%d" if nome_chiave == "danno" else "%+d"
			pezzi.append({"valore": formato % int(effetto[chiave]), "nome": String(EFFETTI[nome_chiave][1])})
		elif nome_chiave == "cura_stato":
			pezzi.append({"valore": "CURA", "nome": nome_stato(String(effetto[chiave])).to_upper()})
		elif nome_chiave == "cura_stati" and bool(effetto[chiave]):
			pezzi.append({"valore": "CURA", "nome": "OGNI MALE"})
		elif nome_chiave == "rigenerazione_battute":
			pezzi.append({"valore": "%d%%" % quota_rigenerata(effetto), "nome": "VITA A BATTUTA"})
			pezzi.append({"valore": "%d" % int(effetto[chiave]), "nome": "BATTUTE"})
	var protezione: Array = PROTEZIONI.get(String(effetto.get("tipo", "")), [])
	if not protezione.is_empty():
		pezzi.append({"valore": String(protezione[1]), "nome": String(protezione[2])})
	return pezzi.slice(0, 3)


static func nome_stato(id_stato: String) -> String:
	return String(GameState.stati.get(id_stato, {}).get("nome", id_stato))


static func nome_di(id_oggetto: String) -> String:
	return String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto))
