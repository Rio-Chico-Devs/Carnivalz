class_name Partite
extends RefCounted

# LE CINQUE PARTITE VISTE DA FUORI: quale c'e', quale e' la piu' recente,
# quando e' stata salvata, come si chiama. Sono domande del menu principale, e
# si rispondono leggendo solo la testata dei file (GameState.dati_slot), senza
# toccare la partita in corso.
#
# «CONTINUA» carica la piu' recente, e la piu' recente e' quella scritta per
# ultima: la data del file. Non serve salvarla dentro il file - il sistema la
# tiene gia', e non puo' sbagliarla.

static func piena(slot: int) -> bool:
	return GameState.ha_salvataggio_slot(slot)


static func occupate() -> Array[int]:
	var elenco: Array[int] = []
	for slot in range(1, GameState.SLOT_MASSIMO + 1):
		if GameState.ha_salvataggio_slot(slot):
			elenco.append(slot)
	return elenco


static func quando(slot: int) -> int:
	# secondi dal 1970, come li conta il sistema; 0 se la partita non c'e'
	if not GameState.ha_salvataggio_slot(slot):
		return 0
	return FileAccess.get_modified_time(GameState.percorso_slot(slot))


static func piu_recente() -> int:
	var migliore := 0
	var ultima := -1
	for slot in occupate():
		if quando(slot) > ultima:
			ultima = quando(slot)
			migliore = slot
	return migliore


static func data(slot: int) -> String:
	# «il 22/09 alle 18:40», nell'ora di chi gioca: il file ha l'ora di
	# Greenwich, il fuso lo aggiunge il sistema
	var secondi := quando(slot)
	if secondi <= 0:
		return ""
	var fuso := int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	var d := Time.get_datetime_dict_from_unix_time(secondi + fuso)
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
