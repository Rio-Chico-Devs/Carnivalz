extends Collezione

# Album delle carte: una carta per ogni personaggio che ne ha una nei dati.
# Le carte non ancora ottenute restano slot bloccati "???".

func titolo_schermata() -> String:
	var totali := 0
	for id_pers in GameState.personaggi:
		if GameState.personaggi[id_pers].has("carta"):
			totali += 1
	return "Album delle carte  (%d / %d)" % [GameState.carte.size(), totali]

func popola() -> void:
	for id_pers in GameState.personaggi:
		var dati: Dictionary = GameState.personaggi[id_pers]
		if not dati.has("carta"):
			continue
		var carta: Dictionary = dati["carta"]
		var rarita: String = carta.get("rarita", "comune")
		var posseduta: bool = String(carta.get("id", "")) in GameState.carte
		if posseduta:
			aggiungi_scheda(carta.get("nome", "?"), rarita.to_upper(),
					carta.get("testo", ""), colore_rarita(rarita), true)
		else:
			aggiungi_scheda("??? ", "carta non ottenuta",
					"Sconfiggi questo nemico per averne la carta.", Color(0.6, 0.6, 0.6), false)
