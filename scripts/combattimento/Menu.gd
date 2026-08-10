class_name MenuCombattimento
extends RefCounted

# I bottoni delle azioni: l'unica parte del combattimento con cui il giocatore
# parla invece di guardare.
#
# Stanno in colonna sulla destra, con una larghezza riservata: il box del testo
# non si restringe quando compaiono e non si allarga quando spariscono. Un menu
# che fa saltare il resto della schermata e' un menu che si fa notare per il
# motivo sbagliato.
#
# Il primo bottone utile prende il fuoco da tastiera: il combattimento si gioca
# per intero senza mouse. Quando un passo del tutorial chiede una cosa precisa,
# quella pulsa e le altre si spengono - senza mai togliere "Studia", perche'
# guardare una creatura non e' mai un errore.
#
# In modalita' muta non costruisce niente: il giocatore automatico non preme
# bottoni, sceglie da solo (vedi "strategia" in Combattimento.gd).

var muta := false
var scontro                    # il nodo Combattimento: il menu e' una sua vista
var contenitore: HBoxContainer
var fuoco_gia_dato := false

func _init(nodo_scontro, silenzioso := false) -> void:
	scontro = nodo_scontro
	muta = silenzioso

func collega(nodo_azioni: HBoxContainer) -> void:
	contenitore = nodo_azioni

func pulisci() -> void:
	fuoco_gia_dato = false
	if muta:
		return
	for figlio in contenitore.get_children():
		figlio.queue_free()

func bottone(testo: String, richiamo: Callable, spento := false, evidenziato := false) -> void:
	if muta:
		return
	var pulsante := Button.new()
	pulsante.text = ("▶  " + testo) if evidenziato else testo
	pulsante.disabled = spento
	pulsante.custom_minimum_size = Vector2(0, 44)
	pulsante.pressed.connect(richiamo)
	contenitore.add_child(pulsante)
	if not spento and not fuoco_gia_dato:
		# il primo bottone utile prende il fuoco: si gioca anche da tastiera
		fuoco_gia_dato = true
		pulsante.grab_focus()
	if evidenziato:
		# pulsa finche' non lo premi: e' li' che deve guardare il giocatore
		pulsante.modulate = Stile.colore("accento")
		var battito: Tween = pulsante.create_tween().set_loops()
		battito.tween_property(pulsante, "modulate:a", 0.45, 0.5)
		battito.tween_property(pulsante, "modulate:a", 1.0, 0.5)

# --- i menu ---

func principale() -> void:
	pulisci()
	var passo: Dictionary = scontro.passo_tutorial()
	if not passo.is_empty():
		# tutorial: si puo' fare solo quello che ti viene chiesto (e Studia,
		# sempre libero: guardare non e' mai un errore)
		var richiesta := String(passo.get("azione", ""))
		bottone("Attacca", bersagli, richiesta != "attacca", richiesta == "attacca")
		bottone("Difenditi", scegli.bind({"tipo": "difendi"}), richiesta != "difendi", richiesta == "difendi")
		bottone("Abilità", abilita)
		bottone("Oggetti", oggetti, richiesta != "oggetto", richiesta == "oggetto")
		return
	bottone("Attacca", bersagli)
	bottone("Difenditi", scegli.bind({"tipo": "difendi"}))
	bottone("Abilità", abilita)
	bottone("Oggetti", oggetti, GameState.sacca.is_empty() and scontro.leve_utilizzabili().is_empty())
	bottone("Alleati", alleati, scontro.alleati_disponibili().is_empty())
	bottone("Fuggi", scegli.bind({"tipo": "fuggi"}), not scontro.fuga_possibile())

func bersagli() -> void:
	# L'ARMA CHE HAI IN MANO CAMBIA COSA PUOI FARE, non solo un numero. Se ne
	# porta con se' degli attacchi, "Attacca" diventa una scelta fra quelli;
	# a mani nude (o con un'arma vecchia che non ne dichiara) resta il colpo
	# normale, esattamente com'era
	var attacchi := GameState.attacchi_arma(String(scontro.attaccante_corrente.get("id", "")))
	if not attacchi.is_empty():
		colpi_darma(attacchi)
		return
	var nemici: Array[Dictionary] = scontro.vivi(false)
	if nemici.size() == 1:
		scegli({"tipo": "attacca", "bersaglio": nemici[0]})
		return
	pulisci()
	for nemico in nemici:
		bottone("Attacca %s" % nemico.nome, scegli.bind({"tipo": "attacca", "bersaglio": nemico}))

func colpi_darma(attacchi: Array[Dictionary]) -> void:
	pulisci()
	var aura := int(scontro.attaccante_corrente.get("aura", 0))
	bottone("Colpo normale", bersagli_di_attacco.bind({}))
	for attacco in attacchi:
		var costo := int(attacco.get("aura", 0))
		var etichetta := "%s  (+%d)" % [String(attacco.get("nome", "?")), int(attacco.get("bonus", 0))]
		if costo > 0:
			etichetta += "  (%d aura)" % costo
		bottone(etichetta, bersagli_di_attacco.bind(attacco), aura < costo)
	bottone("Indietro", principale)

func bersagli_di_attacco(attacco: Dictionary) -> void:
	var nemici: Array[Dictionary] = scontro.vivi(false)
	if nemici.size() == 1:
		scegli({"tipo": "attacca", "bersaglio": nemici[0], "arma": attacco})
		return
	pulisci()
	var nome := String(attacco.get("nome", "Attacca"))
	for nemico in nemici:
		bottone("%s su %s" % [nome, nemico.nome],
				scegli.bind({"tipo": "attacca", "bersaglio": nemico, "arma": attacco}))
	bottone("Indietro", bersagli)
	bottone("Indietro", principale)

func studia() -> void:
	# studiare e' un'azione mirata quanto attaccare: con piu' creature in campo
	# si sceglie chi guardare, non si prende quella che capita per prima
	var nemici: Array[Dictionary] = scontro.vivi(false)
	if nemici.size() <= 1:
		scegli({"tipo": "studia", "bersaglio": nemici[0] if not nemici.is_empty() else {}})
		return
	pulisci()
	for nemico in nemici:
		bottone("Studia %s" % nemico.nome, scegli.bind({"tipo": "studia", "bersaglio": nemico}))
	bottone("Indietro", abilita)

func abilita() -> void:
	pulisci()
	# Studia non costa niente e non costera' mai niente: guardare una creatura
	# e' il cuore del gioco, non una risorsa da amministrare
	bottone("Studia", studia)
	# Le abilita' vengono dal personaggio, non da una lista scritta qui: quelle
	# che sa fare (classes.json) incrociate con quelle che il combattimento sa
	# eseguire (regole.json). Una nuova abilita' compare da sola.
	var attaccante: Dictionary = scontro.attaccante_corrente
	var aura := int(attaccante.get("aura", 0))
	# abilita_usabili tiene conto della progressione: di una linea passa un
	# grado solo, il piu' alto. Terra bruciata prende il posto di Flagello
	# invece di stargli accanto
	for id_abilita in GameState.abilita_usabili(String(attaccante.get("id", ""))):
		var dati := GameState.abilita_combattimento(String(id_abilita))
		if dati.is_empty():
			continue  # abilita' narrativa (scasso, volo, veglia...): fuori dal combattimento
		var costo := int(dati.get("aura", 0))
		var etichetta := "%s  (%d aura)" % [String(dati.get("nome", id_abilita)), costo]
		if scontro.abilita_vuole_bersaglio(String(id_abilita)):
			bottone(etichetta, bersagli_abilita.bind(String(id_abilita)), aura < costo)
		else:
			bottone(etichetta, scegli.bind({"tipo": "abilita", "id": String(id_abilita)}), aura < costo)
	bottone("Indietro", principale)

func bersagli_abilita(id_abilita: String) -> void:
	# Vendetta, Annichilazione e Pieta' vogliono sapere su chi: si scelgono come
	# un attacco normale, non come un'abilita' che parte da sola
	var nemici: Array[Dictionary] = scontro.vivi(false)
	if nemici.size() == 1:
		scegli({"tipo": "abilita", "id": id_abilita, "bersaglio": nemici[0]})
		return
	pulisci()
	var nome := String(GameState.abilita_combattimento(id_abilita).get("nome", id_abilita))
	for nemico in nemici:
		bottone("%s su %s" % [nome, nemico.nome],
				scegli.bind({"tipo": "abilita", "id": id_abilita, "bersaglio": nemico}))
	bottone("Indietro", abilita)

func oggetti() -> void:
	pulisci()
	var conteggio := {}
	for id_oggetto in GameState.sacca:
		conteggio[id_oggetto] = int(conteggio.get(id_oggetto, 0)) + 1
	var passo: Dictionary = scontro.passo_tutorial()
	var solo_questo := String(passo.get("oggetto", "")) if not passo.is_empty() else ""
	for id_oggetto in conteggio:
		var nome: String = GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto)
		var richiesto: bool = solo_questo != "" and String(id_oggetto) == solo_questo
		bottone("%s ×%d" % [nome, conteggio[id_oggetto]],
				scegli.bind({"tipo": "oggetto", "id": id_oggetto}),
				solo_questo != "" and not richiesto, richiesto)
	for leva in scontro.leve_utilizzabili():
		if solo_questo != "":
			break  # durante il tutorial si usa solo cio' che viene chiesto
		var id_leva := String(leva.get("id", ""))
		var nome_leva := String(GameState.dati_oggetto(id_leva).get("nome", id_leva))
		bottone("Mostra: %s" % nome_leva, scegli.bind({"tipo": "leva", "id": id_leva}))
	bottone("Indietro", principale)

func alleati() -> void:
	pulisci()
	for id_ospite in scontro.alleati_disponibili():
		var nome: String = GameState.personaggi.get(id_ospite, {}).get("nome", id_ospite)
		bottone(nome, scegli.bind({"tipo": "alleato", "id": id_ospite}))
	bottone("Indietro", principale)

func scegli(azione: Dictionary) -> void:
	if not muta:
		AudioManager.interfaccia("conferma")
	pulisci()
	scontro.azione_scelta.emit(azione)
