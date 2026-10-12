class_name Partite
extends RefCounted

# LE CINQUE PARTITE VISTE DA FUORI: quale c'e', quale e' la piu' recente,
# quando e' stata salvata, come si chiama. Sono domande del menu principale, e
# si rispondono leggendo solo la testata dei file (GameState.dati_slot), senza
# toccare la partita in corso.
#
# «CONTINUA» carica la piu' recente, e la piu' recente e' quella GIOCATA per
# ultima. All'inizio era la data del file, «che il sistema tiene gia' e non
# puo' sbagliare». La sbaglia: e' la data dell'ultima volta che il file e'
# stato TOCCATO, e lo tocca anche chi lo copia - un backup rimesso a posto, un
# computer nuovo, una cartella sincronizzata con OneDrive o simili. Una
# partita vecchia ricopiata diventava «la piu' recente», e CONTINUA caricava
# quella. Adesso l'ora la scrive il gioco dentro il salvataggio (timbro); la
# data del file resta solo per i salvataggi fatti prima.
#
# E con l'ora, il FUSO DI QUEL MOMENTO. Il sistema da' il fuso di adesso: una
# partita salvata d'estate (ora legale, +2) e guardata d'inverno (+1)
# risultava salvata un'ora prima di quando l'avevi salvata davvero.

static func piena(slot: int) -> bool:
	return GameState.ha_salvataggio_slot(slot)


static func occupate() -> Array[int]:
	var elenco: Array[int] = []
	for slot in range(1, GameState.SLOT_MASSIMO + 1):
		if GameState.ha_salvataggio_slot(slot):
			elenco.append(slot)
	return elenco


static func timbro() -> Dictionary:
	# quello che il salvataggio si porta dietro: quando (secondi dal 1970, ora
	# di Greenwich) e il fuso di quel momento, in minuti
	return {"utc": int(Time.get_unix_time_from_system()),
			"fuso": int(Time.get_time_zone_from_system().get("bias", 0))}


static func timbro_di(slot: int) -> Dictionary:
	# il timbro del salvataggio; per uno fatto prima che il timbro esistesse,
	# la data del file e il fuso di adesso. Vuoto se la partita non c'e'
	if not GameState.ha_salvataggio_slot(slot):
		return {}
	var t: Variant = GameState.dati_slot(slot).get("salvata", null)
	if t is Dictionary and (t as Dictionary).has("utc"):
		return t
	return {"utc": FileAccess.get_modified_time(GameState.percorso_slot(slot)),
			"fuso": int(Time.get_time_zone_from_system().get("bias", 0))}


static func quando(slot: int) -> int:
	# secondi dal 1970; 0 se la partita non c'e'
	return int(timbro_di(slot).get("utc", 0))


static func piu_recente() -> int:
	var migliore := 0
	var ultima := -1
	for slot in occupate():
		var q := quando(slot)
		if q > ultima:
			ultima = q
			migliore = slot
	return migliore


static func data(slot: int) -> String:
	# «il 22/09 alle 18:40», nell'ora che segnava l'orologio quando hai salvato
	var t := timbro_di(slot)
	if int(t.get("utc", 0)) <= 0:
		return ""
	var d := Time.get_datetime_dict_from_unix_time(int(t["utc"]) + int(t.get("fuso", 0)) * 60)
	return "il %02d/%02d alle %02d:%02d" % [int(d.day), int(d.month), int(d.hour), int(d.minute)]


static func livello(slot: int) -> int:
	var livelli: Dictionary = GameState.dati_slot(slot).get("livelli", {})
	return int(livelli.get(GameState.id_protagonista, 1))


static func nome(slot: int) -> String:
	var n := String(GameState.dati_slot(slot).get("nome_protagonista", ""))
	return n if n != "" else GameState.nome_anonimo_default


static func etichetta(slot: int) -> String:
	# come si chiama una partita in un elenco: «PARTITA 2 — ANONIMO, LV 3»
	if not GameState.ha_salvataggio_slot(slot):
		return "PARTITA %d — LIBERA" % slot
	return "PARTITA %d — %s, LV %d" % [slot, nome(slot).to_upper(), livello(slot)]
