class_name Testi
extends RefCounted

# MASCHILE O FEMMINILE, DENTRO UNA FRASE SOLA.
#
# Bru: «a seconda del sesso che si sceglie cambiamo i dialoghi al femminile o
# maschile, anche se scrivo in maschile tieni in conto questa cosa».
#
# Il modo ovvio sarebbe scrivere ogni battuta due volte, una per sesso. Non si
# fa, e non per pigrizia: due copie della stessa frase si separano al primo
# ritocco - se ne corregge una e l'altra resta com'era - e nessuno se ne
# accorge, perche' meta' dei giocatori non vede mai meta' dei testi. Sono
# ventitremila parole: non si puo' rileggere due volte tutto ogni volta.
#
# Quindi la differenza sta DENTRO la frase, dove si vede mentre la si scrive:
#
#   "spero si sia {goduto|goduta} il suo periodo di riposo"
#   "Sei {pronto|pronta}?"
#   "il {dominatore|la dominatrice} e' arrivat{o|a}"
#
# Maschile prima, femminile dopo, sempre. Chi scrive vede tutte e due le
# versioni sulla stessa riga e non puo' aggiustarne una sola.
#
# QUI NON C'E' NESSUN NODO E NESSUNO STATO: entra una stringa e un sesso, esce
# una stringa. Si prova senza aprire niente, e la si puo' chiamare da qualunque
# schermata - il box dei dialoghi, il diario di combattimento, il menu.

const MASCHILE := "m"
const FEMMINILE := "f"

static func accorda(testo: String, sesso: String) -> String:
	# Sostituisce ogni {maschile|femminile} con la meta' giusta.
	#
	# Scorre a mano invece di usare una RegEx apposta: le parentesi graffe le
	# usa gia' {nome}, e una RegEx che prenda "{a|b}" e lasci stare "{nome}"
	# e' piu' facile da sbagliare che da scrivere. Cosi' invece la regola e'
	# esplicita: una graffa aperta senza barra dentro non e' affar nostro.
	if testo.find("{") == -1:
		return testo
	var femmina := sesso == FEMMINILE
	var risultato := ""
	var i := 0
	while i < testo.length():
		var apre := testo.find("{", i)
		if apre == -1:
			risultato += testo.substr(i)
			break
		var chiude := testo.find("}", apre)
		if chiude == -1:
			risultato += testo.substr(i)   # graffa mai chiusa: si lascia com'e'
			break
		var dentro := testo.substr(apre + 1, chiude - apre - 1)
		var barra := dentro.find("|")
		risultato += testo.substr(i, apre - i)
		if barra == -1:
			# non e' un accordo: e' {nome} o qualcos'altro, e non ci si tocca
			risultato += testo.substr(apre, chiude - apre + 1)
		else:
			risultato += dentro.substr(barra + 1) if femmina else dentro.substr(0, barra)
		i = chiude + 1
	return risultato

