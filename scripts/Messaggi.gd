class_name Messaggi
extends RefCounted

# LA SEZIONE MESSAGGI DEL DATA PAD: le regole. Lo stato - quali sono arrivati,
# quali letti - sta in GameState, perche' si salva con la partita.
#
# Stava dentro GameState, ed e' uscito quando le sonde dei pianeti hanno
# cominciato a mandare messaggi scritti a partita in corso (Sonde.gd). Un
# messaggio del catalogo (data/messaggi.json) e' un id: il testo si rilegge dal
# catalogo. Uno delle sonde non c'e' in nessun catalogo - dice cosa ha trovato
# quel giorno - quindi si ricorda tutto intero (GameState.messaggi_scritti).

const PERCORSO := "res://data/messaggi.json"


static func carica() -> void:
	GameState.messaggi_catalogo.clear()
	var dati_file: Variant = GameState.carica_json(PERCORSO)
	if not (dati_file is Dictionary):
		return
	for voce in (dati_file as Dictionary).get("messaggi", []):
		if voce is Dictionary:
			GameState.messaggi_catalogo.append(voce)


static func dati(id_messaggio: String) -> Dictionary:
	for voce in GameState.messaggi_catalogo:
		if String(voce.get("id", "")) == id_messaggio:
			return voce
	return GameState.messaggi_scritti.get(id_messaggio, {})


static func aggiorna() -> void:
	# UN MESSAGGIO ARRIVA UNA VOLTA SOLA, e quello che porta si applica quando
	# arriva - non quando lo apri. I 3000 tazo sono sul conto anche se il data
	# pad non lo guardi mai: e' un accredito, non un regalo da scartare.
	for voce in GameState.messaggi_catalogo:
		var id_messaggio := String(voce.get("id", ""))
		if id_messaggio == "" or id_messaggio in GameState.messaggi_ricevuti:
			continue
		var richiesti: Array = voce.get("richiede_flags", [])
		if richiesti.is_empty() or not GameState._tutti_i_flag(richiesti):
			continue
		GameState.messaggi_ricevuti.append(id_messaggio)
		GameState.messaggi_da_notificare.append(id_messaggio)
		applica_effetto(voce.get("effetto", {}))


static func riprendi(d: Dictionary) -> void:
	# da un salvataggio: quali sono arrivati, quali letti, e il testo di quelli
	# scritti a partita in corso (da annunciare non c'e' niente: lo svuota chi carica)
	GameState.messaggi_ricevuti = GameState._lista_str(d.get("messaggi_ricevuti", []))
	GameState.messaggi_letti = GameState._lista_str(d.get("messaggi_letti", []))
	GameState.messaggi_scritti = d["messaggi_scritti"] if d.get("messaggi_scritti") is Dictionary else {}


static func arriva(voce: Dictionary) -> void:
	# un messaggio scritto adesso, fuori dal catalogo (le sonde): arriva come gli
	# altri - fa numero sul data pad e squilla - e si ricorda col suo testo
	var id_messaggio := String(voce.get("id", ""))
	if id_messaggio == "" or id_messaggio in GameState.messaggi_ricevuti:
		return
	GameState.messaggi_scritti[id_messaggio] = voce
	GameState.messaggi_ricevuti.append(id_messaggio)
	GameState.messaggi_da_notificare.append(id_messaggio)


static func applica_effetto(effetto: Dictionary) -> void:
	if effetto.is_empty():
		return
	if bool(effetto.get("azzera_tazo", false)):
		# «IL MIO CONTO E' A ZERO...». Non si sottrae una cifra: si svuota. Con
		# una sottrazione il conto finirebbe a trenta - quelli con cui si comincia
		# la partita - e la battuta sarebbe una bugia di trenta tazo.
		GameState.tazo = 0
	if effetto.has("tazo"):
		GameState.modifica_tazo(int(effetto["tazo"]))
	if effetto.has("oggetto"):
		GameState.aggiungi_oggetto(String(effetto["oggetto"]))


static func non_letti() -> int:
	var quanti := 0
	for id_messaggio in GameState.messaggi_ricevuti:
		if id_messaggio not in GameState.messaggi_letti:
			quanti += 1
	return quanti


static func segna_letto(id_messaggio: String) -> void:
	if id_messaggio in GameState.messaggi_ricevuti and id_messaggio not in GameState.messaggi_letti:
		GameState.messaggi_letti.append(id_messaggio)
