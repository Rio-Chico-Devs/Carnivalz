extends Collezione

# Compendio degli oggetti: una voce per ogni oggetto definito. La voce si
# svela quando lo si ottiene almeno una volta (GameState.oggetti_catalogo).
# Gli accessori posseduti (GameState.accessori) mostrano anche un bottone
# per equipaggiarli: un solo accessorio alla volta, effetto passivo attivo
# per l'intero prossimo combattimento.

func titolo_schermata() -> String:
	return "Oggetti  (%d / %d)" % [GameState.oggetti_catalogo.size(), GameState.oggetti.size()]

func popola() -> void:
	for id_oggetto in GameState.oggetti:
		var dati: Dictionary = GameState.oggetti[id_oggetto]
		if id_oggetto in GameState.oggetti_catalogo:
			var tipo: String = dati.get("tipo", "consumabile")
			var extra: Control = null
			if tipo == "accessorio" and id_oggetto in GameState.accessori:
				extra = _bottone_equip(id_oggetto)
			aggiungi_scheda(dati.get("nome", id_oggetto), tipo,
					dati.get("descrizione", ""), colore_tipo(tipo), true, extra)
		else:
			aggiungi_scheda("??? ", "mai trovato", "", Color(0.6, 0.6, 0.6), false)

func _bottone_equip(id_oggetto: String) -> Button:
	var equipaggiato := GameState.accessorio_equipaggiato == id_oggetto
	var bottone := Button.new()
	bottone.text = "Equipaggiato — tocca per togliere" if equipaggiato else "Equipaggia"
	bottone.pressed.connect(func() -> void:
		if equipaggiato:
			GameState.rimuovi_accessorio()
		else:
			GameState.equipaggia_accessorio(id_oggetto)
		for figlio in lista.get_children():
			figlio.queue_free()
		popola())
	return bottone

func colore_tipo(tipo: String) -> Color:
	match tipo:
		"consumabile": return Color(0.6, 0.85, 0.6)
		"chiave": return Color(1.0, 0.8, 0.4)
		"collezionabile": return Color(0.6, 0.75, 1.0)
		"accessorio": return Color(0.85, 0.65, 1.0)
		_: return Color(0.8, 0.8, 0.8)
