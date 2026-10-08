class_name Sonde
extends RefCounted

# LE SONDE SUI PIANETI DELLE RISORSE. Bru: «su questi ogni tanto randomicamente
# arrivano dei dati dalle sonde che ti dicono che ci sono nuove risorse da
# estrarre, cosi' accumuli nel lungo periodo».
#
# Come va:
#   - la sonda si accende la prima volta che vedi il pianeta nel Vuoto: prima
#     non sai nemmeno che esiste, e nessuno ti scrive di lui
#   - da li', mentre giochi, ogni tanto (un'attesa a caso fra i due numeri di
#     "ogni_minuti") trova un giacimento: arriva un messaggio sul data pad, e
#     sul pianeta si accende il segnale
#   - i giacimenti aspettano che tu passi, fino a "massimo": stando via a lungo
#     se ne trovano piu' d'uno, ma non all'infinito
#   - nel Vuoto, puntato il pianeta, «Estrai le risorse» li raccoglie tutti
#
# Le risorse sono tre specie: "tazo" va sul conto, "oggetto" (con l'id di
# data/oggetti.json) va nello zaino, tutto il resto ("minerali",
# "organizzazione"...) va nelle RISERVE, che crescono partita dopo partita e
# aspettano il giorno in cui serviranno. Numeri e risorse stanno in mappa.json,
# "sonda" di ogni pianeta. Lo stato sta in GameState.sonde, e si salva.

const MINUTI := [8.0, 20.0]      # se il pianeta non dice ogni quanto
const MASSIMO := 3               # se il pianeta non dice quanti ne tiene da parte
# quello che una sonda sa trovare. I collezionabili no: ognuno e' unico, e si trova giocando
const NOMI := {"tazo": "tazo", "oggetto": "oggetti", "minerali": "minerali", "organizzazione": "risorse per l'Organizzazione"}

# il dado delle sonde e' suo: quello della partita decide gli scontri, e un
# giacimento trovato mentre giochi non deve cambiare l'esito del prossimo colpo
static var dado := RandomNumberGenerator.new()
static var dado_pronto := false


static func pianeti() -> Dictionary:
	if not GameState.sonde.has("pianeti"):
		GameState.sonde["pianeti"] = {}
	return GameState.sonde["pianeti"]


static func riserve() -> Dictionary:
	if not GameState.sonde.has("riserve"):
		GameState.sonde["riserve"] = {}
	return GameState.sonde["riserve"]


static func accendi(pianeta: Dictionary) -> void:
	# la prima volta che il pianeta si vede; le volte dopo non cambia niente
	var id := String(pianeta.get("id", ""))
	if id == "" or not pianeta.has("sonda") or pianeti().has(id):
		return
	pianeti()[id] = {"nome": String(pianeta.get("nome", "?")), "sonda": pianeta["sonda"],
			"attesa": prossima_attesa(pianeta["sonda"]), "giacimenti": [], "trovati": 0}


static func prossima_attesa(sonda: Dictionary) -> float:
	if not dado_pronto:
		dado.randomize()
		dado_pronto = true
	var minuti: Array = sonda.get("ogni_minuti", MINUTI)
	return dado.randf_range(float(minuti[0]), float(minuti[1])) * 60.0


static func avanza(secondi: float) -> void:
	# il tempo che passa giocando (GameState._process, che con la pausa si ferma)
	for id: String in pianeti():
		var p: Dictionary = pianeti()[id]
		var sonda: Dictionary = p["sonda"]
		if (p["giacimenti"] as Array).size() >= int(sonda.get("massimo", MASSIMO)):
			continue   # il magazzino della sonda e' pieno: aspetta che tu passi
		p["attesa"] = float(p["attesa"]) - secondi
		if float(p["attesa"]) <= 0.0:
			trova(id)
			p["attesa"] = prossima_attesa(sonda)


static func trova(id: String) -> Dictionary:
	# un giacimento nuovo, pescato dalla tabella del pianeta col suo peso
	var p: Dictionary = pianeti()[id]
	var tabella: Array = (p["sonda"] as Dictionary).get("giacimenti", [])
	if tabella.is_empty():
		return {}
	var totale := 0.0
	for voce: Dictionary in tabella:
		totale += float(voce.get("peso", 1.0))
	var tiro := dado.randf() * totale
	var scelto: Dictionary = tabella[0]
	for voce: Dictionary in tabella:
		tiro -= float(voce.get("peso", 1.0))
		if tiro <= 0.0:
			scelto = voce
			break
	var giacimento := {"risorsa": String(scelto.get("risorsa", "minerali")), "oggetto": String(scelto.get("oggetto", "")),
			"quanti": dado.randi_range(int(scelto.get("da", 1)), int(scelto.get("a", 1)))}
	(p["giacimenti"] as Array).append(giacimento)
	p["trovati"] = int(p["trovati"]) + 1
	Messaggi.arriva({"id": "sonda_%s_%d" % [id, int(p["trovati"])], "mittente": "Sonda · %s" % p["nome"],
			"oggetto": "Nuovo giacimento", "testo": "I dati della sonda segnalano %s su %s.\nPer estrarlo, punta il pianeta nel Vuoto." % [
			descrivi(giacimento), p["nome"]]})
	return giacimento


static func giacimenti(id: String) -> Array:
	return (pianeti().get(id, {}) as Dictionary).get("giacimenti", [])


static func descrivi(giacimento: Dictionary) -> String:
	var quanti := int(giacimento["quanti"])
	if String(giacimento["risorsa"]) == "oggetto":
		var nome := String(GameState.dati_oggetto(String(giacimento["oggetto"])).get("nome", giacimento["oggetto"]))
		return "%d × %s" % [quanti, nome]
	return "%d %s" % [quanti, NOMI.get(giacimento["risorsa"], giacimento["risorsa"])]


static func estrai(id: String) -> Array[String]:
	# tutti i giacimenti del pianeta, in un colpo. Un oggetto che nello zaino
	# non ci sta resta dov'e', come un segreto del Vuoto: torni quando hai posto
	var presi: Array[String] = []
	var restano: Array = []
	for giacimento: Dictionary in giacimenti(id):
		var quanti := int(giacimento["quanti"])
		match String(giacimento["risorsa"]):
			"tazo":
				GameState.modifica_tazo(quanti)
			"oggetto":
				var messi := 0
				while messi < quanti and GameState.aggiungi_oggetto(String(giacimento["oggetto"])):
					messi += 1
				if messi < quanti:
					var avanzo := giacimento.duplicate()
					avanzo["quanti"] = quanti - messi
					restano.append(avanzo)
				quanti = messi
			_:
				var specie := String(giacimento["risorsa"])
				riserve()[specie] = int(riserve().get(specie, 0)) + quanti
		if quanti > 0:
			var preso := giacimento.duplicate()
			preso["quanti"] = quanti
			presi.append(descrivi(preso))
	if pianeti().has(id):
		pianeti()[id]["giacimenti"] = restano
	return presi
