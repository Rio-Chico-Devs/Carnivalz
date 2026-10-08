class_name ElencoZaino
extends RefCounted

# COSA C'E' NELLO ZAINO, in che ordine, e cosa e' nuovo. Senza disegnare niente:
# la schermata (Zaino.gd) chiede le righe e le mette in fila, le prove le
# chiedono senza aprire niente. Perche' e' fatto cosi': docs/zaino.md.
#
# UN OGGETTO STA IN UNO SCOMPARTO SOLO. Nel salvataggio i ricordi e le chiavi
# stanno sia nella loro lista sia fra gli oggetti speciali, e lo zaino di prima
# li mostrava due volte, in due scomparti. Qui gli speciali sono quello che
# resta: gli stigmi, e quello che verra'.

# [chiave, nome della linguetta, cosa ci va (si legge quando lo scomparto e'
# vuoto), la sagoma che resta spenta sulla fascia quando non c'e' niente]
const SCOMPARTI := [
	["consumabili", "Consumabili", "La sacca: l'unico scomparto che si spende in combattimento.", "consumabile"],
	["armi", "Armi", "Quante armi puoi portare, non quante ne impugni: quella in mano resta qui, segnata IN USO.", "arma"],
	["accessori", "Accessori", "I piccoli aggiustamenti. Si mettono addosso dalla scheda della squadra.", "accessorio"],
	["speciali", "Speciali", "Gli stigmi: patti che danno e tolgono. Nessun limite.", "stigma"],
	["ricordi", "Ricordi e chiavi", "Quello che ti porti dietro della storia, e i materiali dell'Artigiano. Nessun limite.", "speciale"],
	["bottino", "Bottino", "Quello che lasciano i nemici: si vende o si scambia, e intanto si accumula.", "materiale"],
]
# gli ordini del tasto ORDINA, nel giro in cui si presentano
const ORDINI := ["tipo", "nome", "quantita", "arrivo"]
const NOMI_ORDINI := {"tipo": "TIPO", "nome": "NOME", "quantita": "QUANTITÀ", "arrivo": "ARRIVO"}
# nell'ordine per tipo: prima i tipi, e dentro un tipo quello che fa (l'ordine
# degli effetti e' quello di Merce.EFFETTI: vita, aura, stress, danno...)
const TIPI := ["consumabile", "arma", "accessorio", "stigma", "collezionabile", "chiave", "pila"]
const NOMI_TIPI := {"consumabile": "Consumabile", "arma": "Arma", "accessorio": "Accessorio",
		"stigma": "Stigma", "collezionabile": "Materiale", "chiave": "Oggetto chiave", "pila": "Bottino"}

# lo zaino si ricorda dove l'hai lasciato e come l'hai ordinato, finche' giochi
static var aperto := "consumabili"
static var ordine := "tipo"


# --- cosa c'e' dentro --------------------------------------------------------

static func pezzi(chiave: String) -> Array:
	# un id per ogni pezzo, nell'ordine in cui sono arrivati
	match chiave:
		"speciali":
			var ricordi := GameState.collezionabili + GameState.chiavi
			return GameState.oggetti_speciali.filter(func(id: String) -> bool: return id not in ricordi)
		"ricordi":
			return GameState.collezionabili + GameState.chiavi
		"bottino":
			var tutti: Array = []
			for id_oggetto in GameState.pila:
				for i in int(GameState.pila[id_oggetto]):
					tutti.append(String(id_oggetto))
			return tutti
	return GameState.contenuto_zaino(chiave)


static func voci(chiave: String, quale_ordine := "") -> Array[Dictionary]:
	# UNA RIGA PER TIPO DI OGGETTO, col conto: tre fiale sono una riga ×3.
	# {oggetto, quanti, arrivo (l'ultima volta che ne e' entrato uno), in_uso}
	var righe: Array[Dictionary] = []
	var dove := {}
	var elenco := pezzi(chiave)
	for i in elenco.size():
		var id_oggetto := String(elenco[i])
		if not dove.has(id_oggetto):
			dove[id_oggetto] = righe.size()
			righe.append({"oggetto": id_oggetto, "quanti": 0, "in_uso": GameState.portatore_di(id_oggetto)})
		var riga: Dictionary = righe[int(dove[id_oggetto])]
		riga["quanti"] = int(riga["quanti"]) + 1
		riga["arrivo"] = i
	ordina(righe, quale_ordine if quale_ordine != "" else ordine)
	return righe


static func ordina(righe: Array[Dictionary], quale: String) -> void:
	match quale:
		"nome":
			righe.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return prima_per_nome(a, b))
		"quantita":
			righe.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				return int(a["quanti"]) > int(b["quanti"]) if a["quanti"] != b["quanti"] else prima_per_nome(a, b))
		"arrivo":
			righe.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["arrivo"]) > int(b["arrivo"]))
		_:
			righe.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				var ka := chiave_del_tipo(String(a["oggetto"]))
				var kb := chiave_del_tipo(String(b["oggetto"]))
				return ka < kb if ka != kb else prima_per_nome(a, b))


static func prima_per_nome(a: Dictionary, b: Dictionary) -> bool:
	return Merce.nome_di(String(a["oggetto"])).naturalnocasecmp_to(Merce.nome_di(String(b["oggetto"]))) < 0


static func chiave_del_tipo(id_oggetto: String) -> int:
	# il tipo pesa cento, quello che fa uno: gli oggetti che curano stanno
	# insieme, e prima di quelli che fanno danno
	var tipo := TIPI.find(Merce.tipo_oggetto(id_oggetto))
	var effetto := Merce.effetto_di(GameState.dati_oggetto(id_oggetto))
	var primo := Merce.EFFETTI.size()
	for chiave in effetto:
		var dove := Merce.EFFETTI.keys().find(String(chiave))
		if dove >= 0:
			primo = mini(primo, dove)
	return (tipo if tipo >= 0 else TIPI.size()) * 100 + primo


static func gira_ordine() -> String:
	ordine = ORDINI[posmod(ORDINI.find(ordine) + 1, ORDINI.size())]
	return ordine


# --- quanto posto c'e' -------------------------------------------------------

static func tetto(chiave: String) -> int:
	# -1: nessun tetto. Gli speciali, i ricordi e il bottino non si amministrano
	# (il bottino ha un tetto per tipo, non per scomparto: vedi aggiungi_alla_pila)
	if chiave in ["consumabili", "armi", "accessori"]:
		return GameState.capacita_zaino(chiave)
	return -1


static func conto(chiave: String) -> String:
	# «3/20» dove c'e' un tetto, il numero e basta dove non c'e': un tetto
	# finto e' peggio di nessun tetto
	var quanti := pezzi(chiave).size()
	return "%d/%d" % [quanti, tetto(chiave)] if tetto(chiave) >= 0 else "%d" % quanti


static func nome_scomparto(chiave: String) -> String:
	return String(dati_scomparto(chiave)[1])


static func spiegazione(chiave: String) -> String:
	return String(dati_scomparto(chiave)[2])


static func sagoma(chiave: String) -> String:
	return String(dati_scomparto(chiave)[3])


static func dati_scomparto(chiave: String) -> Array:
	for scomparto in SCOMPARTI:
		if scomparto[0] == chiave:
			return scomparto
	return [chiave, chiave, "", "speciale"]


# --- il segno NUOVO ----------------------------------------------------------
#
# Diablo 3 mette una stella sull'oggetto e sullo scomparto; e chi ci ha
# lavorato e' d'accordo che il segno se ne va quando l'oggetto LO GUARDI, non
# quando apri il menu (docs/zaino.md). Qui: quando la sua riga viene scelta.

static func e_nuovo(id_oggetto: String) -> bool:
	return id_oggetto not in GameState.oggetti_visti


static func segna_visto(id_oggetto: String) -> void:
	if id_oggetto != "" and e_nuovo(id_oggetto):
		GameState.oggetti_visti.append(id_oggetto)


static func ha_nuovi(chiave: String) -> bool:
	for id_oggetto in pezzi(chiave):
		if e_nuovo(String(id_oggetto)):
			return true
	return false


static func riprendi(d: Dictionary) -> void:
	# UN SALVATAGGIO DI PRIMA NON SA COSA HAI GUARDATO: tutto quello che hai e'
	# gia' visto, se no lo zaino si aprirebbe coperto di NUOVO
	if d.get("oggetti_visti") is Array:
		GameState.oggetti_visti.assign((d["oggetti_visti"] as Array).map(func(x: Variant) -> String: return str(x)))
		return
	GameState.oggetti_visti.clear()
	for scomparto in SCOMPARTI:
		for id_oggetto in pezzi(String(scomparto[0])):
			segna_visto(String(id_oggetto))
