class_name RegiaCombattimento
extends RefCounted

# LA REGIA DI UNO SCONTRO: chi muove per primo, e chi parla quando.
#
# Bru, sulle Pianure di Redenna: «inizia il combattimento col goblin che ha la
# precedenza, se i nemici tendono imboscate o ti colgono di sorpresa hanno la
# precedenza come turno, in questo caso durante il combattimento invece di
# veronica avremo la guida che parla».
#
# L'ALLENAMENTO E' UN COPIONE, QUESTO NO. Con Veronica ogni passo chiede
# un'azione e finche' non la fai non si va avanti (tutorial_combattimento, nel
# file di lei). Qui lo scontro e' vero e si gioca libero: sopra c'e' solo
# qualcuno che commenta, in tre momenti che si possono dire nei dati.
#
# E STA NEL NODO, NON NELLA CREATURA. Lo stesso goblin, in un'altra stanza, non
# ha nessuno che gli parla sopra: a parlare e' la scena, non il goblin.
#
#   "combattimento_automatico": {
#     "nemici": ["goblin_tipico"],
#     "regia": {
#       "precedenza": "nemici",   <- "nemici", "squadra", o niente: decide la velocita'
#       "battute": [
#         {"quando": "inizio", "righe": [...]},
#         {"quando": "dopo_il_nemico", "volta": 1, "righe": [...]},
#         {"quando": "dopo_di_te", "volta": 2, "righe": [...], "apre_bond": true}
#       ]
#     }
#   }
#
# Le righe sono battute come quelle dell'allenamento ({"tipo", "chi", "testo",
# "evidenzia"}): mentre si leggono il mondo e' fermo, e si va avanti col click.

# Chi apre lo scontro la consegna con il resto (GameState.prepara_combattimento),
# e con il resto si scorda: la regia di questo scontro non deve finire nel
# prossimo, che magari e' un agguato in un'altra stanza.

var scontro: Combattimento
var dati: Dictionary = {}
var dette: Array[int] = []    # le battute gia' dette: ognuna una volta sola
var tue := 0                  # quante volte hai agito tu
var sue := 0                  # quante volte ha agito chi hai davanti

func _init(nodo_scontro: Combattimento, regia: Dictionary) -> void:
	scontro = nodo_scontro
	dati = regia

# --- chi muove per primo ---------------------------------------------------

func precedenza() -> String:
	# «la precedenza la ha chi ha la velocita' maggiore»: quando i dati non
	# dicono niente la risposta e' vuota, e il primo giro lo ordina la
	# velocita'. Un'imboscata lo ribalta: chi l'ha tesa muove tutto per primo
	# (vedi Turni.gd)
	var prima := String(dati.get("precedenza", ""))
	return prima if prima == "nemici" or prima == "squadra" else ""

# --- chi parla quando ------------------------------------------------------

func all_inizio() -> void:
	di("inizio", 0)

func dopo_il_nemico() -> void:
	sue += 1
	di("dopo_il_nemico", sue)

func dopo_di_te(chi: Dictionary) -> void:
	# "tu" e' il protagonista, chiunque lo muova: un compagno che agisce da solo
	# non conta come una tua mossa
	if not chi.giocatore or String(chi.id) != GameState.id_protagonista:
		return
	tue += 1
	di("dopo_di_te", tue)

func di(momento: String, conto: int) -> void:
	if not scontro.in_corso:
		return   # a scontro chiuso non si commenta: c'e' gia' chi racconta la fine
	var battute: Array = dati.get("battute", [])
	for i in battute.size():
		var battuta: Dictionary = battute[i]
		if i in dette or String(battuta.get("quando", "")) != momento:
			continue
		if momento != "inizio" and int(battuta.get("volta", 1)) != conto:
			continue
		dette.append(i)
		parla(battuta.get("righe", []))
		if bool(battuta.get("apre_bond", false)):
			apri_il_bond()

func parla(righe: Array) -> void:
	for riga in righe:
		if scontro.fase_governa_il_tempo():
			# in partita: come Veronica, il mondo si ferma e si legge al proprio passo
			scontro.scrivi_messaggio_tutorial(riga)
			continue
		# SENZA NESSUNO CHE LEGGE IL MONDO NON SI FERMA. Nelle prove e col
		# giocatore automatico _process non gira: un tempo fermato qui non
		# ripartirebbe mai piu'
		var msg: Dictionary = riga
		var testo := String(msg.get("testo", "")).replace("{nome}",
				String(GameState.personaggi.get(GameState.id_protagonista, {}).get("nome", "")))
		if String(msg.get("tipo", "narrazione")) == "dialogo":
			var chi := String(msg.get("chi", GameState.id_protagonista))
			scontro.voce.accoda(testo, "dialogo",
					String(GameState.personaggi.get(chi, {}).get("nome", chi)), true)
		else:
			scontro.voce.accoda("[i]%s[/i]" % testo, "narrazione", "", false)

func apri_il_bond() -> void:
	# «adesso si accende l'opzione bond». La creatura che ha una mediazione nei
	# suoi dati diventa mediabile ADESSO, senza aspettare lo studio: quello che
	# lo studio le avrebbe fatto capire l'ha appena detto la scena. Il tasto si
	# accende da solo (vedi Combattimento.aggiorna_pronto_giocatore)
	for nemico in scontro.vivi(false):
		if not scontro.dati_mediazione(nemico).is_empty():
			nemico.bond_aperto = true
			# e stasera vuole: la mediazione si tira a sorte all'ingresso (vedi
			# tira_volonta_di_mediare), ma qui a decidere e' la scena. Senza
			# questa riga una creatura con meno del 100% di voglia lascerebbe la
			# Guida a dire «si puo'» davanti a un BOND che resta spento
			nemico.vuole_mediare = true
			nemico.mediazione_annunciata = true

# --- la fuga che la zona non concede ---------------------------------------

func fuga_negata() -> Dictionary:
	# «in questo livello l'opzione fuga non deve funzionare se non contro
	# l'apparizione, la guida ti ferma» (Bru). E' una regola della ZONA, non di
	# uno scontro: sta nella mappa di zona, accanto alle stanze, e vale per
	# tutti gli scontri di li' tranne quelli che nomina
	var regola: Dictionary = GameState.mappa_zona.get("fuga_negata", {})
	if regola.is_empty():
		return {}
	for combattente in scontro.combattenti:
		if not combattente.giocatore and String(combattente.id) in regola.get("tranne", []):
			return {}
	return regola

func ferma_la_fuga() -> bool:
	# true = la fuga non parte, e chi l'ha fermata l'ha detto
	var regola := fuga_negata()
	if regola.is_empty():
		return false
	parla([{"tipo": "dialogo", "chi": String(regola.get("chi", "guida")),
			"testo": String(regola.get("testo", ""))}])
	return true
