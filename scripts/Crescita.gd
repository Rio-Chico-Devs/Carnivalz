class_name Crescita
extends RefCounted

# LA RUOTA: UN PUNTO, UNA TASCA, UN LIVELLO.
#
# Bru: «approvato quella che sembra una roulette, le passive e un punto due
# strade», e poi «ogni personaggio ha la sua ruota poi le customizzaremo quando
# avrò tutti i disegni finiti». Ogni personaggio sale una tasca alla volta. Una
# tasca costa un punto d'hype (l'hype e' della squadra: si sceglie su chi
# spenderlo) e a ogni tasca c'e' un bivio fra due statistiche. Quello che
# arriva a quel livello, un'abilita' o una passiva, arriva comunque.
#
# Qui le regole; lo stato sta in GameState (tasche: le strade prese), i numeri
# in data/ruote.json, la schermata in SchedaCrescita, il perche' in
# docs/salita.md. E qui sta anche come la crescita torna dal salvataggio
# (riprendi), come i messaggi e lo zaino.

const PERCORSO := "res://data/ruote.json"

static var dati: Dictionary = {}


static func ruote() -> Dictionary:
	if dati.is_empty():
		var letti: Variant = GameState.carica_json(PERCORSO)
		dati = letti if letti is Dictionary else {}
	return dati


static func tasche_di(id_classe: String) -> Array:
	var prese: Variant = GameState.tasche.get(id_classe, [])
	return prese if prese is Array else []


static func tetto() -> int:
	# Bru: «nella beta il cap e' 20» (data/ruote.json); mai oltre il massimo del gioco
	return mini(int(ruote().get("tetto", 20)), int(GameState.regole.get("livello_massimo", 130)))


static func coppia(id_classe: String, livello: int) -> Array[String]:
	# le due strade di quel livello: ogni personaggio ha le sue, a giro
	var tutte: Dictionary = ruote().get("coppie", {})
	var sue: Variant = tutte.get(id_classe, tutte.get("_altri", []))
	var due: Array[String] = ["hp", "attacco"]
	if sue is Array and not (sue as Array).is_empty():
		var questa: Variant = (sue as Array)[posmod(livello, (sue as Array).size())]
		if questa is Array and (questa as Array).size() == 2:
			due = [String(questa[0]), String(questa[1])]
	return due


static func quanto(nome_stat: String) -> int:
	return int(ruote().get("quanto", {}).get(nome_stat, 1))


static func bonus(id_classe: String, nome_stat: String) -> int:
	# quanto hanno dato a quella statistica le strade prese sulla sua ruota
	var quante := 0
	for presa in tasche_di(id_classe):
		if String(presa) == nome_stat:
			quante += 1
	return quante * quanto(nome_stat)


static func prendibile(id_classe: String) -> bool:
	# c'e' un punto da spendere, e la ruota non e' arrivata al tetto
	return GameState.livello_di(id_classe) < tetto() and GameState.punti_abilita_liberi() >= 1


static func prendi(id_classe: String, nome_stat: String) -> bool:
	# Si prende sempre la prossima tasca: la ruota non salta. La strada deve
	# essere una delle due di quel livello
	var g := GameState
	if id_classe == "":
		id_classe = g.id_protagonista
	if not prendibile(id_classe) or not nome_stat in coppia(id_classe, g.livello_di(id_classe) + 1):
		return false
	g.hype_disponibile = maxi(g.hype_disponibile - g.costo_in_hype(1), 0)
	var prese: Array[String] = g._lista_str(tasche_di(id_classe))
	prese.append(nome_stat)
	g.tasche[id_classe] = prese
	if id_classe == g.id_protagonista:
		# le azioni diventano statistiche (e arrivano le passive del livello),
		# e al racconto si aggiunge la strada: e' una delle cose cresciute
		g.racconta_la_salita()
		aggiungi_la_strada(g.salite_di_livello.back(), nome_stat)
	return true


static func aggiungi_la_strada(salita: Dictionary, nome_stat: String) -> void:
	# racconta_la_salita guarda le statistiche a strada gia' presa: la sua parte
	# va tolta da "prima", o aggiunta come riga se le azioni non l'hanno toccata
	var vale := quanto(nome_stat)
	salita["strada"] = {"stat": nome_stat, "quanto": vale}
	for voce: Dictionary in salita.get("stat", []):
		if String(voce.get("stat", "")) == nome_stat:
			voce["prima"] = int(voce.get("prima", 0)) - vale
			return
	var adesso := GameState.stat_di(nome_stat)
	(salita["stat"] as Array).append({"stat": nome_stat, "prima": adesso - vale, "dopo": adesso,
			"nome": String(GameState.crescita.get("stat", {}).get(nome_stat, {}).get("nome", nome_stat))})


static func arriva(id_classe: String, livello: int) -> Array:
	# QUELLO CHE ARRIVA COMUNQUE a quel livello, qualunque strada prendi:
	# [[tipo, id], ...], prima le abilita' poi le passive. Le abilita' sono
	# quelle che abilita_del_personaggio da' da sole al livello (stesse regole:
	# lo controlla una prova); le passive, quelle di crescita.json
	var qui: Array = []
	var g := GameState
	if id_classe != g.id_protagonista or livello <= 1:
		return qui
	var della_classe: Array = g.classi.get(id_classe, {}).get("abilita", [])
	for id_abilita in g.abilita.get("abilita", {}):
		var dati_abilita := g.abilita_combattimento(String(id_abilita))
		if int(dati_abilita.get("livello", 0)) == livello and int(dati_abilita.get("costo", 0)) <= 0 \
				and not String(id_abilita) in della_classe and g.linea_sua(String(dati_abilita.get("linea", "")), id_classe):
			qui.append(["abilita", String(id_abilita)])
	for voce: Dictionary in g.crescita.get("passive_livello", []):
		if int(voce.get("livello", 0)) == livello:
			qui.append(["passiva", String(voce.get("id", ""))])
	return qui


static func riprendi(d: Dictionary) -> void:
	# LO STATO DELLA CRESCITA, dal salvataggio: i punti guadagnati giocando, i
	# nodi, le ruote, l'hype, le azioni ancora da convertire, le resistenze, le
	# passive. Sta qui come Messaggi.riprendi e ElencoZaino.riprendi
	var g := GameState
	g.punti_stat = d.get("punti_stat", {})
	g.nodi_abilita = g._lista_str(d.get("nodi_abilita", []))
	g.nodi_per_personaggio = d.get("nodi_per_personaggio", {})
	g.tasche = {}
	var salvate: Variant = d.get("tasche", {})
	if salvate is Dictionary:
		for id_classe: Variant in salvate:
			g.tasche[String(id_classe)] = g._lista_str(salvate[id_classe])
	g.hype_disponibile = int(d.get("hype_disponibile", 0))
	g.hype_accumulato = int(d.get("hype_accumulato", 0))
	g.contatori = d.get("contatori", {})
	g.resistenze_stato = d.get("resistenze_stato", {})
	g.volte_stato_subito = d.get("volte_stato_subito", {})
	g.passive_sbloccate = g._lista_str(d.get("passive_sbloccate", []))
