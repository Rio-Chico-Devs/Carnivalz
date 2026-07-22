extends Collezione

# Bestiario: una voce per ogni nemico (personaggio con "xp"). La voce appare
# al primo incontro. Alcuni nemici hanno una descrizione extra sbloccata da
# un oggetto (o flag/quest) posseduto.

func titolo_schermata() -> String:
	var totali := 0
	for id_pers in GameState.personaggi:
		if GameState.personaggi[id_pers].has("xp"):
			totali += 1
	return "Bestiario  (%d / %d)" % [GameState.bestiario.size(), totali]

func popola() -> void:
	for id_pers in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_pers]
		if not dati.has("xp"):
			continue  # solo creature affrontabili
		if id_pers not in GameState.bestiario:
			aggiungi_scheda("??? ", "mai incontrato", "", Color(0.6, 0.6, 0.6), false)
			continue
		var corpo: String = dati.get("descrizione", "")
		if dati.has("descrizione_extra"):
			corpo += "\n\n" + testo_extra(dati["descrizione_extra"])
		aggiungi_scheda(dati.get("nome", id_pers), "", corpo, Color.WHITE, true)

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
