extends Collezione

# Compendio degli oggetti: una voce per ogni oggetto definito. La voce si
# svela quando lo si ottiene almeno una volta (GameState.oggetti_catalogo).
# Qui si guarda, non si equipaggia: l'equipaggiamento e' per personaggio e ha
# i suoi slot, quindi si mette addosso dal Diario (ESC > Equipaggiamento).
# Il compendio dice solo, di un oggetto che si puo' indossare, chi ce l'ha.

func titolo_schermata() -> String:
	return "Oggetti  (%d / %d)" % [GameState.oggetti_catalogo.size(), GameState.oggetti.size()]

func popola() -> void:
	for id_oggetto in GameState.oggetti:
		var dati: Dictionary = GameState.oggetti[id_oggetto]
		if id_oggetto in GameState.oggetti_catalogo:
			var tipo: String = dati.get("tipo", "consumabile")
			var extra: Control = null
			if id_oggetto in GameState.accessori:
				extra = _etichetta_portatore(id_oggetto)
			aggiungi_scheda(dati.get("nome", id_oggetto), tipo,
					dati.get("descrizione", ""), colore_tipo(tipo), true, extra)
		else:
			aggiungi_scheda("??? ", "mai trovato", "", Color(0.6, 0.6, 0.6), false)

func _etichetta_portatore(id_oggetto: String) -> Label:
	var etichetta := Label.new()
	var id_portatore := GameState.portatore_di(id_oggetto)
	if id_portatore == "":
		etichetta.text = "Nell'armadio — si mette addosso dal Diario (ESC)"
	else:
		var classe: Dictionary = GameState.classi.get(id_portatore, {})
		etichetta.text = "Addosso a %s" % String(classe.get("nome", id_portatore))
	Stile.etichetta_piccola(etichetta)
	return etichetta

func colore_tipo(tipo: String) -> Color:
	match tipo:
		"consumabile": return Color(0.6, 0.85, 0.6)
		"chiave": return Color(1.0, 0.8, 0.4)
		"collezionabile": return Color(0.6, 0.75, 1.0)
		"accessorio": return Color(0.85, 0.65, 1.0)
		"arma": return Color(1.0, 0.6, 0.6)
		"stigma": return Color(0.9, 0.5, 0.9)
		_: return Color(0.8, 0.8, 0.8)
