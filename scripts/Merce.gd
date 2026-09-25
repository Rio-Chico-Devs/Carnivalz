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
	"danno": ["%d danni, ignora le difese", "DANNI"],
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
	return String(GameState.dati_oggetto(String(voce.get("oggetto", ""))).get("tipo", "consumabile"))


static func categoria_di(tipo: String) -> String:
	for categoria in CATEGORIE:
		if tipo in categoria["tipi"]:
			return String(categoria["titolo"])
	return ALTRO


# --- me lo posso permettere --------------------------------------------------

static func perche_no(voce: Dictionary) -> String:
	# "" se si puo' prendere; se no, il motivo in due o tre parole. E' quello
	# che si legge sotto la carta e sul tasto spento: un tasto grigio senza un
	# perche' e' un tasto rotto
	if String(voce.get("tipo", "")) == "baratto":
		var mancano := mancanti(voce.get("richiede", []))
		return "" if mancano.is_empty() else "ti manca: " + ", ".join(mancano)
	if sacca_piena_per(String(voce.get("oggetto", ""))):
		return "la sacca è piena"
	var prezzo := int(voce.get("prezzo", 0))
	if GameState.tazo < prezzo:
		return "ti mancano %d Tazo" % (prezzo - GameState.tazo)
	return ""


static func stato_breve(voce: Dictionary) -> Dictionary:
	# LA RIGA SOTTO LA CARTA: due o tre parole, e se sono un problema (in
	# cremisi) o un'informazione (in grigio). E' la risposta a "posso?" e "ne
	# ho gia'?" senza aprire niente
	var id_oggetto := String(voce.get("oggetto", ""))
	if String(voce.get("tipo", "")) == "baratto":
		return {"testo": "MATERIALI MANCANTI", "problema": true} \
				if not mancanti(voce.get("richiede", [])).is_empty() else {"testo": "SI PUÒ FARE", "problema": false}
	if sacca_piena_per(id_oggetto):
		return {"testo": "SACCA PIENA", "problema": true}
	if GameState.tazo < int(voce.get("prezzo", 0)):
		return {"testo": "MANCANO %d" % (int(voce.get("prezzo", 0)) - GameState.tazo), "problema": true}
	if gia_tuo(id_oggetto):
		return {"testo": "GIÀ TUO", "problema": false}
	var quanti := quanti_in_sacca(id_oggetto)
	return {"testo": "IN SACCA ×%d" % quanti if quanti > 0 else "", "problema": false}


static func sacca_piena_per(id_oggetto: String) -> bool:
	var tipo := String(GameState.dati_oggetto(id_oggetto).get("tipo", "consumabile"))
	return tipo == "consumabile" and GameState.sacca.size() >= int(GameState.regole.get("sacca_massima", 20))


static func mancanti(richiesti: Array) -> Array[String]:
	# un materiale richiesto due volte va posseduto due volte: si scala la copia
	var disponibili: Array = GameState.collezionabili.duplicate()
	var fuori: Array[String] = []
	for materiale in richiesti:
		var id_materiale := String(materiale)
		if id_materiale in disponibili:
			disponibili.erase(id_materiale)
			continue
		var nome := nome_di(id_materiale)
		if nome not in fuori:
			fuori.append(nome)
	return fuori


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
	var tipo := String(GameState.dati_oggetto(id_oggetto).get("tipo", "consumabile"))
	if tipo == "consumabile":
		var quanti := quanti_in_sacca(id_oggetto)
		return "" if quanti == 0 else "ne hai già %d in sacca" % quanti
	if not GameState.posseduto_equipaggiabile(id_oggetto):
		return ""
	var id_portatore := GameState.portatore_di(id_oggetto)
	if id_portatore == "":
		return "ne hai già uno, nell'armadio"
	return "ne hai già uno, addosso a %s" % SchedaOggetto.nome_di_classe(id_portatore)


static func gia_tuo(id_oggetto: String) -> bool:
	# il timbro sulla carta: un equipaggiabile che hai gia'. Un consumabile no -
	# di quelli se ne comprano dieci, e dieci timbri non dicono niente
	var tipo := String(GameState.dati_oggetto(id_oggetto).get("tipo", "consumabile"))
	return tipo != "consumabile" and GameState.posseduto_equipaggiabile(id_oggetto)


# --- che cosa fa -------------------------------------------------------------

static func effetto_di(oggetto: Dictionary) -> Dictionary:
	return oggetto.get("effetto_equipaggiato", oggetto.get("effetto", {}))


static func riassunto_effetto(oggetto: Dictionary) -> String:
	# l'effetto in numeri. Le chiavi sono le stesse che legge il combattimento,
	# quindi un oggetto nuovo si racconta da solo senza toccare questo file
	var voci_testo: Array[String] = []
	var effetto := effetto_di(oggetto)
	for chiave in effetto:
		var frase := frase_di(String(chiave), effetto[chiave])
		if frase != "":
			voci_testo.append(frase)
	var protezione: Array = PROTEZIONI.get(String(effetto.get("tipo", "")), [])
	if not protezione.is_empty():
		voci_testo.append(String(protezione[0]))
	return ", ".join(voci_testo) if not voci_testo.is_empty() else "—"


static func frase_di(chiave: String, valore: Variant) -> String:
	match chiave:
		"tipo":
			return ""
		"cura_stato":
			return "toglie %s" % nome_stato(String(valore)).to_lower()
		"cura_stati":
			return "toglie ogni male"
	if EFFETTI.has(chiave):
		return String(EFFETTI[chiave][0]) % int(valore)
	return "%s %+d" % [chiave, int(valore)]


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
		elif nome_chiave == "cura_stati":
			pezzi.append({"valore": "CURA", "nome": "OGNI MALE"})
	var protezione: Array = PROTEZIONI.get(String(effetto.get("tipo", "")), [])
	if not protezione.is_empty():
		pezzi.append({"valore": String(protezione[1]), "nome": String(protezione[2])})
	return pezzi.slice(0, 3)


static func nome_stato(id_stato: String) -> String:
	return String(GameState.stati.get(id_stato, {}).get("nome", id_stato))


static func nome_di(id_oggetto: String) -> String:
	return String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto))
