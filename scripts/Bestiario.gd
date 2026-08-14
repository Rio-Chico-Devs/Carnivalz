extends Collezione

# Bestiario: una voce per ogni nemico (personaggio con "xp"). La voce appare
# al primo incontro. Alcuni nemici hanno una descrizione extra sbloccata da
# un oggetto (o flag/quest) posseduto.

func titolo_schermata() -> String:
	var totali := 0
	for id_pers in GameState.personaggi:
		if GameState.e_da_bestiario(id_pers):
			totali += 1
	return "Bestiario  (%d / %d)" % [GameState.bestiario.size(), totali]

func popola() -> void:
	for id_pers in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_pers]
		if not GameState.e_da_bestiario(id_pers):
			continue  # solo creature affrontabili
		if id_pers not in GameState.bestiario:
			aggiungi_scheda("??? ", "mai incontrato", "", Color(0.6, 0.6, 0.6), false)
			continue
		var corpo: String = dati.get("descrizione", "")
		corpo += tecnolog(id_pers)
		if dati.has("descrizione_extra"):
			corpo += "\n\n" + testo_extra(dati["descrizione_extra"])
		aggiungi_scheda(dati.get("nome", id_pers), "", corpo, Color.WHITE, true)

func tecnolog(id_creatura: String) -> String:
	# LA PAGINA CHE LO STUDIO RIEMPIE, e il posto giusto per rileggerla: qui non
	# c'e' nessuno che ti picchia mentre leggi. In combattimento escono solo le
	# righe nuove, una manciata per studio (vedi Combattimento.rileva_tecnolog).
	#
	# Quello che non hai ancora rilevato NON si nasconde: si mostra vuoto. Una
	# scheda con dei buchi dice "ci sono altre due cose da sapere su di lei"; una
	# scheda accorciata dice soltanto che hai finito.
	var studi := GameState.volte_studiato(id_creatura)
	if studi <= 0:
		return "\n\n[ TECNO LOG — nessun rilevamento. Studiala in combattimento. ]"
	var righe: Array[String] = ["", "[ TECNO LOG — rilevamenti: %d / %d ]"
			% [mini(studi, GameState.strati_tecnolog()), GameState.strati_tecnolog()]]
	for riga in GameState.tecnolog_di(id_creatura, studi):
		righe.append("%s: %s" % [String(riga.get("etichetta", "")), String(riga.get("valore", ""))])
	return "\n" + "\n".join(righe)

func testo_extra(extra: Dictionary) -> String:
	var sbloccato := true
	if extra.has("richiede_oggetto"):
		sbloccato = GameState.possiede_oggetto(extra["richiede_oggetto"]) \
				or extra["richiede_oggetto"] in GameState.oggetti_catalogo
	elif extra.has("richiede_flag"):
		sbloccato = GameState.ha_flag(extra["richiede_flag"])
	if sbloccato:
		return "» " + String(extra.get("testo", ""))
	return "» [voce nascosta — c'è ancora qualcosa da scoprire su di lui]"
