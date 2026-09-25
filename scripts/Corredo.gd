class_name Corredo
extends RefCounted

# QUANTO VALE UN PERSONAGGIO E COSA GLI CAMBIA UN OGGETTO. Senza disegnare niente.
#
# E' la meta' della scheda della squadra che fa i conti: le statistiche con e
# senza quello che porta addosso, la differenza che farebbe un candidato, cosa
# si puo' mettere in uno slot, le protezioni dette a parole. Stava dentro
# Personaggio.gd, mescolata ai bottoni, come le domande del negozio stavano in
# Negozio.gd prima di Merce.gd: qui si provano senza aprire nessuna schermata.

# I DISEGNI DELLA SCHEDA, nella cartella di ogni compagno, quella delle sue
# espressioni: art/personaggi/<id>/<nome>.png. L'id, non il nome del ritratto:
# i disegni di Yhvina stanno in art/personaggi/insonne/. Misure e sagome in
# docs/interfaccia.md; l'elenco di chi manca in docs/immagini.md
const DISEGNI := ["intero", "carta", "emblema"]

const STATISTICHE := [
	["hp", "Punti vita"],
	["attacco", "Attacco"],
	["difesa", "Difesa"],
	["velocita", "Velocità"],
	["aura", "Aura"],
]


static func statistica_base(id_classe: String, chiave: String) -> int:
	# il protagonista cresce con quello che fa (crescita.json); i compagni hanno
	# le loro statistiche scritte nei dati
	if chiave == "aura":
		return GameState.aura_massima(id_classe) - GameState.bonus_equipaggiamento(id_classe, "aura_max")
	if id_classe == GameState.id_protagonista:
		return GameState.stat_di(chiave)
	var dati: Dictionary = GameState.personaggi.get(id_classe, {})
	return int(dati.get(chiave, 0))


static func bonus_di(id_classe: String, chiave: String) -> int:
	return GameState.bonus_equipaggiamento(id_classe, chiave_interna(chiave))


static func chiave_interna(chiave: String) -> String:
	if chiave == "hp":
		return "hp_max"
	return "aura_max" if chiave == "aura" else chiave


static func righe(id_classe: String) -> Array[Dictionary]:
	# le righe del pannello delle statistiche: {chiave, nome, base, bonus}
	var elenco: Array[Dictionary] = []
	for voce in STATISTICHE:
		var chiave := String(voce[0])
		elenco.append({"chiave": chiave, "nome": String(voce[1]),
				"base": statistica_base(id_classe, chiave), "bonus": bonus_di(id_classe, chiave)})
	return elenco


# --- la differenza ------------------------------------------------------------

static func scarti_di(id_candidato: String, id_attuale: String) -> Dictionary:
	# Il conto e' PURO: si sottrae quello che dava il vecchio e si somma quello
	# che da' il nuovo, senza mettere niente addosso a nessuno. La prima
	# versione equipaggiava davvero e poi rimetteva a posto - e non lo rimetteva
	# a posto: bastava SCORRERE l'elenco per spogliare un compagno. Le prove
	# l'hanno preso al primo giro (prova_scheda_personaggio).
	var scarti := {}
	for voce in STATISTICHE:
		var chiave := String(voce[0])
		var scarto := GameState.bonus_oggetto(id_candidato, chiave_interna(chiave)) \
				- GameState.bonus_oggetto(id_attuale, chiave_interna(chiave))
		if scarto != 0:
			scarti[chiave] = scarto
	return scarti


static func verso_di(scarti: Dictionary) -> int:
	# 1 se e' tutto meglio, -1 se e' tutto peggio, 0 se e' uno scambio (o niente)
	var su := false
	var giu := false
	for scarto in scarti.values():
		su = su or int(scarto) > 0
		giu = giu or int(scarto) < 0
	return 0 if su == giu else (1 if su else -1)


static func differenza_testo(id_candidato: String, id_attuale: String) -> String:
	var scarti := scarti_di(id_candidato, id_attuale)
	var pezzi: Array[String] = []
	for voce in STATISTICHE:
		if scarti.has(String(voce[0])):
			pezzi.append("%s %+d" % [String(voce[1]).to_lower(), int(scarti[String(voce[0])])])
	if pezzi.is_empty():
		return "nessun cambiamento nelle statistiche"
	return ", ".join(pezzi)


# --- cosa si mette dove ---------------------------------------------------------

static func oggetti_per_slot(slot: String) -> Array[String]:
	var risultato: Array[String] = []
	var visti := {}
	for id_oggetto in GameState.magazzino_per_slot(slot):
		var chiave := String(id_oggetto)
		if visti.has(chiave):
			continue
		visti[chiave] = true
		var tipo := String(GameState.dati_oggetto(chiave).get("tipo", ""))
		var va_bene := tipo == "consumabile" if slot == "ultima_risorsa" \
				else (tipo == "accessorio" if slot == "accessori" else tipo == slot)
		if va_bene:
			risultato.append(chiave)
	return risultato


static func elenco_protezioni(id_classe: String) -> Array[String]:
	# le protezioni non sono numeri e sparirebbero dalla tabella: si dicono a
	# parole, con le stesse del negozio (Merce.PROTEZIONI)
	var risultato: Array[String] = []
	var slots := GameState.slot_di(id_classe)
	var addosso: Array[String] = []
	for slot in ["arma", "stigma", "ultima_risorsa"]:
		if String(slots.get(slot, "")) != "":
			addosso.append(String(slots[slot]))
	for id_oggetto in slots.get("accessori", []):
		addosso.append(String(id_oggetto))
	for id_oggetto in addosso:
		var effetto: Dictionary = GameState.dati_oggetto(id_oggetto).get("effetto_equipaggiato", {})
		var protezione: Array = Merce.PROTEZIONI.get(String(effetto.get("tipo", "")), [])
		if not protezione.is_empty():
			risultato.append("%s: %s" % [Merce.nome_di(id_oggetto), String(protezione[0])])
	var maledizione := GameState.bonus_equipaggiamento(id_classe, "resistenza_maledizione")
	if maledizione > 0:
		risultato.append("il conto della maledizione parte da %d rintocchi più in alto" % maledizione)
	return risultato


static func disegno(id_classe: String, quale: String) -> Texture2D:
	return Disegni.texture("res://art/personaggi/%s/%s.png" % [id_classe, quale])


static func classe_di(id_classe: String) -> String:
	# il mestiere, se i dati lo dicono. Non il nome al suo posto: "CLASSE
	# VERONICA" non vuol dire niente
	return String(GameState.classi.get(id_classe, {}).get("classe", ""))


static func nome_di(id_classe: String) -> String:
	return String(GameState.personaggi.get(id_classe, {}).get("nome",
			GameState.classi.get(id_classe, {}).get("nome", id_classe)))
