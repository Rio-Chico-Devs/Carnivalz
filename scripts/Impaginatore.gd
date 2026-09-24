class_name Impaginatore
extends RefCounted

# UN TESTO LUNGO SI DIVIDE IN PAGINE, E OGNI PAGINA ENTRA NEL BOX.
#
# Bru: «alcuni dialoghi sforano il container di testo, bisogna dividere i testi
# piu' lunghi affinche' entrino sempre nel box». Il box ha un'altezza fissa (e
# deve averla: vedi BoxTesto.gd), e quello che non ci stava scorreva sotto il
# bordo, dove nessuno poteva leggerlo.
#
# DIVIDERE QUI, NON NEI DATI. Quanto ci sta in un box dipende dalla finestra,
# da «Testo piu' grande», da chi parla (la targhetta ruba una riga), dal box
# (quello del combattimento e' piu' stretto). Un testo tagliato a mano nel file
# entrerebbe in un caso e sforerebbe nell'altro. Qui si misura il box vero,
# adesso, e si taglia di conseguenza.
#
# DOVE SI TAGLIA, in ordine di preferenza:
#
#   4  dove Bru ha gia' andato a capo: un paragrafo nuovo e' una pagina nuova
#   3  alla fine di una frase: . ! ? e i puntini, ma solo se dopo si ricomincia
#      con la maiuscola - «non e' recisa... finche' ogni porcellana» e' una
#      frase sola che prende fiato, e tagliarla li' la spezza a meta'
#   2  dopo una virgola, un punto e virgola, i due punti (e quei puntini)
#   1  fra due parole
#
# Si prende sempre il taglio piu' lontano che entra, al livello piu' alto che
# ne ha uno: una pagina finisce su un paragrafo intero se ce n'e' uno che ci
# sta, se no su una frase intera, e cosi' via.
#
# E I TAG RESTANO CHIUSI. Un testo puo' avere del bbcode ([i], [b], [color=...])
# e un taglio puo' cadere in mezzo: ogni pagina richiude i tag rimasti aperti e
# la successiva li riapre, cosi' un corsivo resta corsivo anche a pagina nuova.
#
# "entra" e' chi misura: riceve una pagina e dice se ci sta. Qui dentro non c'e'
# nessun nodo, e si prova con un misuratore finto (vedi Prove.gd).

const PARAGRAFO := 4
const FRASE := 3
const VIRGOLA := 2
const PAROLA := 1
const PAGINE_MASSIME := 200   # la rete: un misuratore rotto non deve girare per sempre

static func dividi(testo: String, entra: Callable) -> Array[String]:
	var pagine: Array[String] = []
	if testo.strip_edges() == "" or entra.call(testo):
		pagine.append(testo)
		return pagine
	var tagli := punti_di_taglio(testo)
	var inizio := 0
	while inizio < testo.length() and pagine.size() < PAGINE_MASSIME:
		var resto := pagina(testo, inizio, testo.length())
		if entra.call(resto):
			pagine.append(resto)
			break
		var fine := taglio_migliore(testo, tagli, inizio, entra)
		pagine.append(pagina(testo, inizio, fine))
		inizio = dopo_gli_spazi(testo, fine)
	return pagine

static func taglio_migliore(testo: String, tagli: Array, inizio: int, entra: Callable) -> int:
	for forza in [PARAGRAFO, FRASE, VIRGOLA, PAROLA]:
		var migliore := -1
		for taglio in tagli:
			var dove := int(taglio[0])
			if dove <= inizio or int(taglio[1]) < forza:
				continue
			if not entra.call(pagina(testo, inizio, dove)):
				break   # piu' in la' e' ancora piu' lungo: non entra nemmeno quello
			migliore = dove
		if migliore > inizio:
			return migliore
	# nemmeno una parola ci sta da sola: la si mette lo stesso, intera, invece
	# di spezzarla a meta' - meglio una parola che sborda di una parola rotta
	for taglio in tagli:
		if int(taglio[0]) > inizio:
			return int(taglio[0])
	return testo.length()

static func punti_di_taglio(testo: String) -> Array:
	# [[indice, forza], ...] in ordine. L'indice e' dove FINISCE la pagina: la
	# punteggiatura resta con la frase che chiude, lo spazio passa alla dopo
	var tagli: Array = []
	var i := 0
	while i < testo.length():
		i = guarda(testo, i, tagli)
	return tagli

static func guarda(testo: String, i: int, tagli: Array) -> int:
	# il carattere in "i": se li' si puo' tagliare lo segna, e dice da dove
	# ripartire
	var c := testo[i]
	if c == "[" and testo.find("]", i) > i:
		return testo.find("]", i) + 1   # un tag non si guarda dentro
	if c == "\n":
		segna(tagli, i, PARAGRAFO)
		return dopo_gli_spazi(testo, i)
	if c in ".!?…":
		var fine := dopo_i_tag(testo, fine_della_punteggiatura(testo, i))
		if fine < testo.length() and testo[fine] in " \n":
			segna(tagli, fine, forza_dopo(testo, fine))
		return fine
	if c in ",;:" and i + 1 < testo.length() and testo[i + 1] == " ":
		segna(tagli, i + 1, VIRGOLA)
	elif c == " ":
		segna(tagli, i, PAROLA)
	return i + 1

static func segna(tagli: Array, dove: int, forza: int) -> void:
	# lo stesso punto trovato due volte (un punto seguito da un a capo) vale
	# quanto il piu' forte dei due
	if not tagli.is_empty() and int(tagli[-1][0]) == dove:
		tagli[-1][1] = maxi(int(tagli[-1][1]), forza)
		return
	tagli.append([dove, forza])

static func fine_della_punteggiatura(testo: String, da: int) -> int:
	# «...», «?!», e le virgolette o la parentesi che chiudono con la frase
	var i := da + 1
	while i < testo.length() and testo[i] in ".!?…»”\"')":
		i += 1
	return i

static func forza_dopo(testo: String, fine: int) -> int:
	# dopo un punto: e' una frase nuova solo se riparte con la maiuscola (o con
	# un discorso diretto, un numero, un trattino)
	if testo[fine] == "\n":
		return PARAGRAFO
	var dopo := dopo_i_tag(testo, dopo_gli_spazi(testo, fine))
	if dopo >= testo.length():
		return FRASE
	var prossimo := testo[dopo]
	if prossimo != prossimo.to_lower() or prossimo in "«\"'—-0123456789":
		return FRASE
	return VIRGOLA

static func dopo_i_tag(testo: String, da: int) -> int:
	# un [/i] subito dopo un punto chiude la frase anche lui: la pagina finisce
	# dopo il tag, non prima
	var i := da
	while i < testo.length() and testo[i] == "[":
		var chiusa := testo.find("]", i)
		if chiusa < 0:
			break
		i = chiusa + 1
	return i

static func dopo_gli_spazi(testo: String, da: int) -> int:
	var i := da
	while i < testo.length() and testo[i] in " \n":
		i += 1
	return i

static func pagina(testo: String, da: int, a: int) -> String:
	# il pezzo, con davanti i tag che erano aperti e in fondo le chiusure di
	# quelli che restano aperti
	var aperti_prima := tag_aperti(testo, da)
	var aperti_dopo := tag_aperti(testo, a)
	var pezzo := testo.substr(da, a - da).strip_edges()
	var davanti := ""
	for tag in aperti_prima:
		davanti += String(tag[1])
	var dietro := ""
	for k in range(aperti_dopo.size() - 1, -1, -1):
		dietro += "[/%s]" % String(aperti_dopo[k][0])
	return davanti + pezzo + dietro

static func tag_aperti(testo: String, fino_a: int) -> Array:
	# [[nome, tag intero], ...] dei tag aperti prima di "fino_a" e non ancora chiusi
	var pila: Array = []
	var i := 0
	while i < fino_a:
		if testo[i] != "[":
			i += 1
			continue
		var chiusa := testo.find("]", i)
		if chiusa < 0:
			break
		var dentro := testo.substr(i + 1, chiusa - i - 1)
		if dentro.begins_with("/"):
			var nome_chiuso := dentro.substr(1)
			for k in range(pila.size() - 1, -1, -1):
				if String(pila[k][0]) == nome_chiuso:
					pila.remove_at(k)
					break
		else:
			var nome := dentro.split("=")[0].split(" ")[0]
			pila.append([nome, testo.substr(i, chiusa - i + 1)])
		i = chiusa + 1
	return pila
