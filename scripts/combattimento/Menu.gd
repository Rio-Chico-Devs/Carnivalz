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
		# tolto SUBITO dall'albero, non solo messo in coda: queue_free() libera a
		# fine frame, e finche' non succede il vecchio bottone sta ancora li'
		# accanto al nuovo
		contenitore.remove_child(figlio)
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
	# CINQUE VOCI, SEMPRE LE STESSE. Bru: "tu hai un menu principale di
	# combattimento: attacca, difendi, abilita', oggetti, fuggi. Attacca attacca
	# semplicemente, difendi aumenta la tua difesa cumulativamente fino a fine
	# combattimento, abilita' avra' tutti i tuoi attacchi speciali, oggetti ti fa
	# usare gli oggetti utilizzabili, fuggi ti fa scappare".
	#
	# Prima "Attacca" non c'era: il colpo normale si dava cliccando sul nemico, e
	# il menu conteneva solo il resto. Era una scorciatoia che andava scoperta -
	# chi non ci provava non trovava da nessuna parte il modo di picchiare. Il
	# click sul nemico resta come scorciatoia, ma la voce adesso c'e'.
	#
	# Nemmeno "Arma" sta piu' qui: i colpi d'arma SONO attacchi speciali e vanno
	# sotto Abilita'. Una voce di primo livello che compare solo con certe armi
	# in mano faceva un menu di lunghezza variabile per una cosa che non e' una
	# categoria a se'.
	#
	# Le due voci che compaiono e spariscono - Aiutante e Mediazione - stanno in
	# fondo apposta: le cinque fisse non si spostano mai sotto il cursore.
	#
	# E NON SPARISCE MENTRE RICARICHI: si spegne. I bottoni restano dove sono,
	# grigi, e tornano vivi quando tocca a te. Cancellarli faceva vedere la stessa
	# cosa - che non e' il tuo momento - al prezzo di non far piu' leggere niente.
	pulisci()
	if bool(scontro.mattanza_attiva):
		# durante la Mattanza sotto non c'e' un menu: c'e' una cosa sola da fare,
		# e va scritta grossa. Il bottone e' spento apposta - si preme SPAZIO,
		# non lui: un bottone premibile inviterebbe a cliccare, e cliccando non
		# succede niente
		bottone("␣  MARTELLA  ␣", principale, true)
		return
	var fermo := not bool(scontro.giocatore_pronto())
	var passo: Dictionary = scontro.passo_tutorial()
	if not passo.is_empty():
		# tutorial: si puo' fare solo quello che ti viene chiesto (e Studia,
		# sempre libero: guardare non e' mai un errore)
		var richiesta := String(passo.get("azione", ""))
		bottone("Attacca", bersagli, fermo or richiesta != "attacca", richiesta == "attacca")
		bottone("Difendi", scegli.bind({"tipo": "difendi"}), fermo or richiesta != "difendi", richiesta == "difendi")
		bottone("Abilità", abilita, fermo)
		bottone("Oggetti", oggetti, fermo or richiesta != "oggetto", richiesta == "oggetto")
		return
	# Rabbia e Frastornato: "attacchi soltanto, non puoi usare mosse". Le voci
	# restano al loro posto, spente - il menu non si accorcia mai. Sparire
	# avrebbe fatto saltare tutto quello che sta sotto proprio nel momento in
	# cui il giocatore sta gia' subendo qualcosa che non capisce
	var accecato := RegoleCombattimento.solo_attacchi(scontro.attaccante_corrente)
	bottone("Attacca", bersagli, fermo)
	bottone("Difendi", scegli.bind({"tipo": "difendi"}), fermo or accecato)
	bottone("Abilità", abilita, fermo or accecato)
	bottone("Oggetti", oggetti, fermo or accecato \
			or (GameState.sacca.is_empty() and scontro.leve_utilizzabili().is_empty()))
	bottone("Fuggi", scegli.bind({"tipo": "fuggi"}), fermo or not scontro.fuga_possibile())
	# --- le due condizionali: compaiono solo quando ci sono davvero ---
	if not scontro.alleati_disponibili().is_empty():
		# Bru sull'incontro dei Cunicoli: "semplicemente fa apparire nel menu
		# un'opzione aiutante con le sue mosse". Non e' un membro della squadra:
		# e' una voce in piu' finche' ti accompagna
		bottone("Aiutante", alleati, fermo)
	if not scontro.bersagli_mediabili().is_empty():
		bottone("Mediazione", mediazione, fermo)

func bersagli() -> void:
	# "Attacca attacca semplicemente": il colpo normale, e l'unica domanda e' su
	# chi. Con un nemico solo in campo non si chiede nemmeno quello
	var nemici: Array[Dictionary] = scontro.vivi(false)
	if nemici.size() == 1:
		scegli({"tipo": "attacca", "bersaglio": nemici[0]})
		return
	pulisci()
	for nemico in nemici:
		bottone("Attacca %s" % nemico.nome, scegli.bind({"tipo": "attacca", "bersaglio": nemico}))
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
	# UNO SOLO. Ce n'erano due, tutti e due scritti "Indietro", che portavano in
	# posti diversi: quello sopra tornava alla scelta dell'arma, quello sotto al
	# menu. Due bottoni identici con due destini diversi non si scelgono, si
	# indovinano
	bottone("Indietro", abilita)

func mediazione() -> void:
	# la voce rara. Ci si arriva solo dopo che lo studio ha rivelato che questa
	# creatura ascolta - e con un solo mediabile in campo non c'e' niente da
	# scegliere: la si media e basta
	var mediabili: Array[Dictionary] = scontro.bersagli_mediabili()
	if mediabili.size() == 1:
		scegli({"tipo": "media", "bersaglio": mediabili[0]})
		return
	pulisci()
	for nemico in mediabili:
		bottone("Media con %s" % nemico.nome, scegli.bind({"tipo": "media", "bersaglio": nemico}))
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
	# I COLPI D'ARMA STANNO QUI, non in una voce loro: sono attacchi speciali
	# quanto gli altri, e l'arma che hai in mano cambia cosa sai fare
	for attacco in GameState.attacchi_arma(String(attaccante.get("id", ""))):
		var costo_arma := int(attacco.get("aura", 0))
		var etichetta_arma := "%s  (+%d)" % [String(attacco.get("nome", "?")), int(attacco.get("bonus", 0))]
		if costo_arma > 0:
			etichetta_arma += "  (%d aura)" % costo_arma
		bottone(etichetta_arma, bersagli_di_attacco.bind(attacco), aura < costo_arma)
	# abilita_usabili tiene conto della progressione: di una linea passa un
	# grado solo, il piu' alto. Terra bruciata prende il posto di Flagello
	# invece di stargli accanto
	for id_abilita in GameState.abilita_usabili(String(attaccante.get("id", ""))):
		var dati := GameState.abilita_combattimento(String(id_abilita))
		if dati.is_empty():
			continue  # abilita' narrativa (scasso, volo, veglia...): fuori dal combattimento
		var costo := int(dati.get("aura", 0))
		var etichetta := "%s  (%d aura)" % [String(dati.get("nome", id_abilita)), costo]
		# LA BARRA SPEGNE QUELLO CHE NON PUOI ANCORA CHIAMARE. Bru, sulla
		# Mattanza: "quando riempi almeno una barra puoi andare in mattanza, solo
		# in quel momento". Un bottone acceso che poi ti risponde "non hai
		# abbastanza dominio" e' un bottone che ha mentito
		var senza_barra := not bool(scontro.dominio_sufficiente(attaccante, dati))
		if bool(dati.get("consuma_tutto", false)):
			etichetta = "%s  (tutta la barra)" % String(dati.get("nome", id_abilita))
		elif float(dati.get("dominio", 0.0)) > 0.0:
			etichetta += "  (%.1f barre)" % float(dati.get("dominio", 0.0))
		if scontro.abilita_vuole_bersaglio(String(id_abilita)):
			bottone(etichetta, bersagli_abilita.bind(String(id_abilita)), aura < costo or senza_barra)
		else:
			bottone(etichetta, scegli.bind({"tipo": "abilita", "id": String(id_abilita)}),
					aura < costo or senza_barra)
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
	# IL BLOCCO ERA QUI. Il menu emetteva un segnale che, tolti i turni, non
	# ascoltava piu' nessuno: l'azione non partiva, il menu restava chiuso e il
	# gioco sembrava piantato. In tempo reale l'azione si esegue subito, e chi
	# decide se la tua ricarica e' pronta e' agisci_ora
	scontro.agisci_ora(azione)
	# e si torna subito al menu principale: se restasse dov'era, chi ha scelto
	# dentro un sottomenu ci resterebbe dentro senza un modo di uscirne
	if scontro.in_corso:
		principale()
