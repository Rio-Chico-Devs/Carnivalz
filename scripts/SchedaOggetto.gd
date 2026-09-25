class_name SchedaOggetto
extends RefCounted

# COME SI MOSTRA UN OGGETTO, in un posto solo.
#
# Nome, quanti ne hai, chi lo sta usando, cosa fa. Stava dentro Pausa.gd, ma
# non e' roba della pausa: e' roba dell'oggetto, e la stessa riga serve allo
# zaino, al negozio e a qualunque schermata li elenchi.
#
# L'EFFETTO ARRIVA GIA' SCRITTO, non lo calcola questa scheda: lo scrive
# Merce.riassunto_effetto, l'unico posto che lo dice. Erano due versioni
# diverse, una nello zaino e una nel negozio, e lo stesso oggetto si
# raccontava in modi diversi a seconda di dove lo guardavi (PLAY, euristica
# F2: «The player experiences the user interface as consistent»). Adesso le
# parole sono quelle del negozio dappertutto; la prova
# prova_il_negozio_non_fa_pagare_per_niente guarda che non si sdoppino di nuovo.

static func riga(id_oggetto: String, quanti: int, effetto: String) -> Control:
	var dati := GameState.dati_oggetto(id_oggetto)
	var blocco := VBoxContainer.new()
	blocco.add_theme_constant_override("separation", 2)
	var testata := HBoxContainer.new()
	testata.add_theme_constant_override("separation", 10)
	blocco.add_child(testata)
	var nome := Label.new()
	nome.text = String(dati.get("nome", id_oggetto))
	if quanti > 1:
		nome.text += "  ×%d" % quanti
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nome.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	testata.add_child(nome)
	# un'arma equipaggiata resta nello zaino, segnata: e' una regola dello zaino,
	# e qui e' l'unico posto dove si vede
	var portatore := GameState.portatore_di(id_oggetto)
	if portatore != "":
		var uso := Label.new()
		uso.text = "in uso — %s" % nome_di_classe(portatore)
		uso.add_theme_color_override("font_color", Stile.colore("bordo_acceso"))
		uso.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
		testata.add_child(uso)
	var descrizione := String(dati.get("descrizione", ""))
	var sotto := Label.new()
	sotto.text = descrizione if descrizione != "" else effetto
	if descrizione != "" and effetto != "" and effetto != "nessun effetto":
		sotto.text = "%s  —  %s" % [descrizione, effetto]
	sotto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Stile.etichetta_piccola(sotto)
	blocco.add_child(sotto)
	return blocco

static func nome_di_classe(id_classe: String) -> String:
	var definizione: Dictionary = GameState.classi.get(id_classe, {})
	if not definizione.is_empty():
		return String(definizione.get("nome", id_classe))
	return String(GameState.personaggi.get(id_classe, {}).get("nome", id_classe))
