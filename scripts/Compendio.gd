extends Collezione

# Compendio degli oggetti: una voce per ogni oggetto definito. La voce si
# svela quando lo si ottiene almeno una volta (GameState.oggetti_catalogo).

func titolo_schermata() -> String:
	return "Oggetti  (%d / %d)" % [GameState.oggetti_catalogo.size(), GameState.oggetti.size()]

func popola() -> void:
	for id_oggetto in GameState.oggetti:
		var dati: Dictionary = GameState.oggetti[id_oggetto]
		if id_oggetto in GameState.oggetti_catalogo:
			var tipo: String = dati.get("tipo", "consumabile")
			aggiungi_scheda(dati.get("nome", id_oggetto), tipo,
					dati.get("descrizione", ""), colore_tipo(tipo), true)
		else:
			aggiungi_scheda("??? ", "mai trovato", "", Color(0.6, 0.6, 0.6), false)

func colore_tipo(tipo: String) -> Color:
	match tipo:
		"consumabile": return Color(0.6, 0.85, 0.6)
		"chiave": return Color(1.0, 0.8, 0.4)
		"collezionabile": return Color(0.6, 0.75, 1.0)
		_: return Color(0.8, 0.8, 0.8)
