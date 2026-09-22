class_name Resoconto
extends RefCounted

# COME SI RACCONTA UNA SALITA DI LIVELLO.
#
# In Carnivalz le statistiche NON salgono col livello: salgono con quello che
# hai fatto davvero - i colpi tirati, quelli incassati, le volte che ti sei
# coperto, i posti in cui sei entrato. La salita di livello e' l'unico momento
# in cui il giocatore lo scopre.
#
# E fino a ieri quel momento diceva:
#
#     forza 12 → 14 (+2)
#     resistenza 30 → 35 (+5)
#
# Cioe' il risultato senza la causa, che e' esattamente la meta' che non conta.
# Il perche' il codice lo sapeva - GameState.applica_crescita_livello() calcola
# quante volte hai fatto ogni cosa e quanti punti ne escono - e lo buttava via
# un istante dopo averlo calcolato. Adesso sopravvive, e si legge:
#
#     forza 12 → 14  (+2)
#     per i colpi che hai tirato (41)
#
# STA QUI E NON DENTRO Main.gd perche' Main e' il direttore della storia -
# dialoghi, scelte, cambi di scena - non il posto dove si decide come si
# formatta una riga di statistica. Erano quarantanove righe di presentazione in
# mezzo alla navigazione.
#
# E NON E' UN VELO CHE SBARRA. Le righe entrano nella coda normale dei
# messaggi: il giocatore le fa scorrere al suo passo, e chiudere non aspetta
# nessuna animazione. E' la stessa regola di Conto.gd, e viene dallo stesso
# posto - Durczok chiama "peccato capitale" la schermata di fine scontro che
# non si chiude finche' il contatore non ha finito.


static func salite_di_livello() -> Array[Dictionary]:
	var righe: Array[Dictionary] = []
	for salita in GameState.salite_di_livello:
		righe.append(nota("[b]Livello %d.[/b]" % int(salita.get("livello", 0))))
		var cresciute: Array = salita.get("stat", [])
		var motivi: Array = salita.get("motivi", [])
		if cresciute.is_empty():
			righe.append(nota("Nessuna statistica è cresciuta: crescono con " +
					"quello che fai, e in quest'ultimo tratto non hai fatto " +
					"abbastanza di niente."))
		for voce in cresciute:
			righe.append(nota(riga_di_crescita(voce, motivi)))
		var punti := int(salita.get("punti_abilita", 0))
		if punti > 0:
			righe.append(nota("Hai %d %s da spendere sulle abilità." % [punti,
					"punto" if punti == 1 else "punti"]))
	GameState.salite_di_livello.clear()
	return righe


static func nota(testo: String) -> Dictionary:
	return {"tipo": "notifica", "testo": testo}


static func riga_di_crescita(voce: Dictionary, motivi: Array) -> String:
	# UNA PER RIGA, non tutte in blocco. Prima uscivano incolonnate in un
	# messaggio solo e si leggevano come una tabella; sono quattro o cinque
	# frasi vere, e separate si leggono come un resoconto.
	var salto := int(voce.get("dopo", 0)) - int(voce.get("prima", 0))
	var testo := "[b]%s[/b] %d → %d  (+%d)" % [String(voce.get("nome", "")),
			int(voce.get("prima", 0)), int(voce.get("dopo", 0)), salto]
	var suoi := perche_di(String(voce.get("stat", "")), motivi)
	return testo if suoi == "" else "%s\nper %s" % [testo, suoi]


static func perche_di(nome_stat: String, motivi: Array) -> String:
	# PIU' AZIONI POSSONO ALIMENTARE LA STESSA STATISTICA: la vita cresce sia
	# coi colpi incassati sia con gli oggetti che ti sei curato addosso, e
	# dirne una sola sarebbe dire una mezza verita'
	var pezzi: Array[String] = []
	for m in motivi:
		var racconto := String(m.get("racconto", ""))
		if String(m.get("stat", "")) == nome_stat and racconto != "":
			pezzi.append("%s (%d)" % [racconto, int(m.get("quante", 0))])
	return " e ".join(pezzi)
