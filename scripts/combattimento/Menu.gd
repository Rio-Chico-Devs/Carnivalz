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
# IL NODO COMBATTIMENTO, E QUESTO E' L'UNICO SENZA TIPO DI TUTTO IL FILE.
#
# Non e' una dimenticanza, e l'ho provato: scrivendo "var scontro: Combattimento"
# la suite cade in sei punti, e tipando anche il parametro di _init non cade -
# si pianta, oltre i seicento secondi, dentro il parser.
#
# Il motivo e' che qui dentro passa anche un FintoScontro (vedi prove/Prove.gd):
# un oggetto che risponde alle sole cinque domande che il menu fa davvero -
# tocca a te, la Mattanza e' accesa, chi e' vivo, il passo del tutorial, la
# scelta. Serve perche' uno scontro vero gira in tempo reale e non finisce: la
# prima versione di quella prova accendeva un combattimento intero per premere
# quattro voci di menu, e la suite si piantava.
#
# Quindi la scelta e' fra due cose che valgono tutte e due - i tipi statici, che
# in GDScript prendono gli errori al parse invece che in partita, e la
# sostituibilita', che qui e' la sola ragione per cui questa prova esiste. Vince
# la seconda, perche' il menu non usa il combattimento: gli fa cinque domande, e
# dipendere da cinque domande invece che da una classe da quattromila righe e'
# la dipendenza piu' stretta possibile, non la piu' larga.
#
# Stati.gd, che nessuno sostituisce, e' tipato: li' il tipo e' guadagno netto.
var scontro                    # il menu e' una sua vista
var contenitore: Control
# come si veste una voce: lo decide chi ospita il menu (vedi Plancia.vesti_comando)
var vestaglia := Callable()
# come si fa vedere il pannello che ospita il menu: lo sa la plancia, non il menu
var apri_il_pannello := Callable()
# "comandi" = la colonna verticale del disegno, "lista" = la griglia delle voci
var modo := "comandi"
var fuoco_gia_dato := false
var ricostruzioni := 0

func _init(nodo_scontro, silenzioso := false) -> void:
	scontro = nodo_scontro
	muta = silenzioso

func collega(nodo_azioni: Control, come_vestirle := Callable(),
		come_aprirlo := Callable()) -> void:
	contenitore = nodo_azioni
	vestaglia = come_vestirle
	apri_il_pannello = come_aprirlo

func pulisci() -> void:
	fuoco_gia_dato = false
	if muta:
		return
	# IL PANNELLO DEVE ESSERE QUELLO DEI COMANDI, se no il menu si riempie di
	# voci dentro una faccia nascosta: non si vede niente, e - peggio - nessuna
	# voce puo' prendere il fuoco, quindi nemmeno la tastiera funziona. Era il
	# caso: la plancia nasceva sulla faccia del parlato e non la cambiava mai
	# nessuno.
	if apri_il_pannello.is_valid():
		# CHI OSPITA IL MENU APRE IL PANNELLO E DICE DOVE SCRIVERE. I comandi
		# vanno nella colonna verticale, le liste nella griglia: sono due posti
		# diversi dello stesso rettangolo, e il menu non ha bisogno di sapere
		# quali.
		var dove: Variant = apri_il_pannello.call(modo)
		if dove is Control and dove != contenitore:
			svuota(contenitore)
			contenitore = dove
	svuota(contenitore)

func mostra_ricarica(non_ancora: bool) -> void:
	# CHE NON SIA ANCORA IL TUO TURNO SI VEDE, MA NON TOGLIE NIENTE. Prima lo
	# diceva il grigio dei bottoni spenti, che pero' si mangiavano il click.
	# Adesso lo dice il pannello intero, che resta premibile: il comando dato
	# presto viene sentito e aspetta il suo momento.
	if muta or contenitore == null or not is_instance_valid(contenitore):
		return
	contenitore.modulate.a = 0.55 if non_ancora else 1.0

func svuota(dove: Control) -> void:
	# la versione giusta sta in Albero.svuota, ed e' la stessa per tutti: questo
	# difetto l'avevamo corretto qui e solo qui, mentre era in altri nove posti
	Albero.svuota(dove)

func bottone(testo: String, richiamo: Callable, spento := false, evidenziato := false) -> void:
	if muta:
		return
	var pulsante := Button.new()
	pulsante.text = ("▶  " + testo) if evidenziato else testo
	pulsante.disabled = spento
	pulsante.custom_minimum_size = Vector2(0, 44)
	pulsante.pressed.connect(richiamo)
	contenitore.add_child(pulsante)
	# NEL DISEGNO DI BRU le voci sono scritte nere sul bianco, non bottoni: chi
	# ospita il menu decide come si vestono, perche' e' lui che sa in che
	# pannello stanno
	if vestaglia.is_valid():
		vestaglia.call()
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

func voce_in_coda(nome: String) -> void:
	# QUELLO CHE ASPETTA DEVE VEDERSI, O IL BUFFER E' SOLO RITARDO.
	#
	# Qui avevo sbagliato due volte. La prima: avevo messo questa riga DOPO il
	# return del tutorial, cioe' nell'unico combattimento che Bru gioca non
	# compariva mai. La seconda, peggiore: l'avevo fatta con un bottone spento,
	# grigio, su un pannello che mentre ricarichi e' gia' scolorito al 55% -
	# invisibile sopra invisibile.
	#
	# Ellison scrive che lo scopo del buffer e' «la PERCEZIONE di un gioco
	# reattivo». Io avevo costruito il meccanismo e saltato la percezione: premi,
	# non vedi niente, e un secondo dopo parte da solo. Indistinguibile dal lag,
	# che e' esattamente il difetto che volevo togliere.
	if muta:
		return
	var riga := Button.new()
	riga.text = "⏳  parte appena tocca a te:  %s" % nome
	riga.disabled = true
	riga.focus_mode = Control.FOCUS_NONE
	riga.custom_minimum_size = Vector2(0, 44)
	contenitore.add_child(riga)
	if vestaglia.is_valid():
		vestaglia.call()
	# il colore d'accento e il battito servono a farla NOTARE nell'istante in cui
	# compare: e' la risposta immediata al click, l'azione arriva dopo
	riga.modulate = Stile.colore("accento")
	var battito: Tween = riga.create_tween().set_loops()
	battito.tween_property(riga, "modulate:a", 0.5, 0.45)
	battito.tween_property(riga, "modulate:a", 1.0, 0.45)

# --- i menu ---

func principale() -> void:
	ricostruzioni += 1
	modo = "comandi"
	# CINQUE VOCI, SEMPRE LE STESSE. Bru: "tu hai un menu principale di
	# combattimento: attacca, difendi, abilita', oggetti, fuggi. Attacca attacca
	# semplicemente, difendi aumenta la tua difesa cumulativamente fino a fine
	# combattimento, abilita' avra' tutti i tuoi attacchi speciali, oggetti ti fa
	# usare gli oggetti utilizzabili, fuggi ti fa scappare".
	#
	# Prima "ATTACCHI" non c'era: il colpo normale si dava cliccando sul nemico, e
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
	# LA RICARICA NON SPEGNE PIU' I BOTTONI. Un bottone `disabled` in Godot non
	# emette `pressed` e si mangia lo stesso il click: chi premeva DIFESA mentre
	# la ricarica finiva non veniva ne' servito ne' sentito, ed era il "primo
	# click morto". Adesso le voci restano premibili e il comando dato presto
	# aspetta il suo momento (Combattimento.metti_in_coda). Che non sia ancora il
	# tuo turno si vede lo stesso: l'intero pannello si scolorisce (ricarica()),
	# e l'azione in attesa e' scritta.
	#
	# `spento` resta, ma adesso vuol dire una cosa sola e vera: QUESTO NON SI PUO'
	# FARE. Non "non ancora" - proprio no, come una mossa sotto Rabbia o una voce
	# che il tutorial non ha ancora sbloccato.
	var passo: Dictionary = scontro.passo_tutorial()
	if not passo.is_empty():
		# tutorial: si puo' fare solo quello che ti viene chiesto (e Studia,
		# sempre libero: guardare non e' mai un errore)
		var richiesta := String(passo.get("azione", ""))
		# E ANCHE QUI SI VEDE COSA ASPETTA. Anzi: soprattutto qui. La lezione e'
		# il posto dove il giocatore sta imparando se i suoi comandi contano
		var in_coda_lezione: String = scontro.nome_azione_in_coda()
		if in_coda_lezione != "":
			voce_in_coda(in_coda_lezione)
		bottone("ATTACCHI", bersagli, richiesta != "attacca", richiesta == "attacca")
		bottone("DIFESA", scegli.bind({"tipo": "difendi"}), richiesta != "difendi", richiesta == "difendi")
		bottone("SKILL", abilita)
		bottone("OGGETTI", oggetti, richiesta != "oggetto", richiesta == "oggetto")
		# IN FONDO, E SOLO A CHI L'HA GIA' FATTA. In fondo perche' le voci fisse
		# non si devono spostare sotto il cursore di chi la lezione la sta
		# seguendo; e solo a chi rigioca perche' la prima volta la lezione di
		# Veronica e' anche una scena (vedi Combattimento.si_puo_saltare_la_lezione)
		if bool(scontro.si_puo_saltare_la_lezione()):
			bottone("↷  Salta la lezione", scontro.salta_la_lezione)
		return
	# Rabbia e Frastornato: "attacchi soltanto, non puoi usare mosse". Le voci
	# restano al loro posto, spente - il menu non si accorcia mai. Sparire
	# avrebbe fatto saltare tutto quello che sta sotto proprio nel momento in
	# cui il giocatore sta gia' subendo qualcosa che non capisce
	var accecato := RegoleCombattimento.solo_attacchi(scontro.attaccante_corrente)
	# L'AZIONE CHE ASPETTA SI VEDE. Un comando tenuto da parte di nascosto e'
	# proprio il "controllo appiccicoso" di cui avverte Ellison: parte qualcosa
	# che non ricordi di aver chiesto. Scritta in cima, invece, e' una promessa -
	# e cliccare qualsiasi altra voce la sostituisce, quindi si disdice da sola
	# il tipo si scrive a mano: scontro e' Variant apposta (vedi la nota sulla
	# sua dichiarazione), e dedurre da un Variant qui e' un errore, non un avviso
	var in_attesa: String = scontro.nome_azione_in_coda()
	if in_attesa != "":
		voce_in_coda(in_attesa)
	bottone("ATTACCHI", bersagli)
	bottone("DIFESA", scegli.bind({"tipo": "difendi"}), accecato)
	bottone("SKILL", abilita, accecato)
	bottone("OGGETTI", oggetti, accecato \
			or (GameState.sacca.is_empty() and scontro.leve_utilizzabili().is_empty()))
	bottone("FUGA", scegli.bind({"tipo": "fuggi"}), not scontro.fuga_possibile())
	# --- le due condizionali: compaiono solo quando ci sono davvero ---
	if not scontro.alleati_disponibili().is_empty():
		# la voce dell'aiutante resta com'era: e' un sottomenu, non un'azione
		# Bru sull'incontro dei Cunicoli: "semplicemente fa apparire nel menu
		# un'opzione aiutante con le sue mosse". Non e' un membro della squadra:
		# e' una voce in piu' finche' ti accompagna
		bottone("Aiutante", alleati)
	if not scontro.bersagli_mediabili().is_empty():
		bottone("Mediazione", mediazione)

func bersagli() -> void:
	modo = "lista"
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
	modo = "lista"
	var nemici: Array[Dictionary] = scontro.vivi(false)
	if nemici.size() == 1:
		scegli({"tipo": "attacca", "bersaglio": nemici[0], "arma": attacco})
		return
	pulisci()
	var nome := String(attacco.get("nome", "ATTACCHI"))
	for nemico in nemici:
		bottone("%s su %s" % [nome, nemico.nome],
				scegli.bind({"tipo": "attacca", "bersaglio": nemico, "arma": attacco}))
	# UNO SOLO. Ce n'erano due, tutti e due scritti "Indietro", che portavano in
	# posti diversi: quello sopra tornava alla scelta dell'arma, quello sotto al
	# menu. Due bottoni identici con due destini diversi non si scelgono, si
	# indovinano
	bottone("Indietro", abilita)

func mediazione() -> void:
	modo = "lista"
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
	modo = "lista"
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
	modo = "lista"
	pulisci()
	# Studia non costa niente e non costera' mai niente: guardare una creatura
	# e' il cuore del gioco, non una risorsa da amministrare
	bottone("Studia", studia)
	# Le abilita' vengono dal personaggio, non da una lista scritta qui: quelle
	# che sa fare (classes.json) incrociate con quelle che il combattimento sa
	# eseguire (regole.json). Una nuova abilita' compare da sola.
	var attaccante: Dictionary = scontro.attaccante_corrente
	var aura := int(attaccante.get("aura", 0))
	# DURANTE UNA LEZIONE SI FA SOLO QUELLO CHE VERONICA CHIEDE.
	#
	# Il menu principale gia' spegne ATTACCHI, DIFESA e OGGETTI quando il passo
	# chiede altro - ma SKILL restava aperto, e dentro c'era tutto. Bru,
	# provando: «ho notato che posso girare a zonzo, sono andato nelle skill e
	# consumato tutta l'aura, poi ho studiato veronica e in tutto questo ancora
	# non attaccavo». Arrivava alla lezione sull'aura con l'aura gia' spesa.
	#
	# SKILL deve restare APRIBILE perche' Studia sta qui dentro, e guardare una
	# creatura non e' mai un errore. A chiudersi e' il contenuto, non la porta.
	var passo: Dictionary = scontro.passo_tutorial()
	var lezione := not passo.is_empty()
	# passo vuoto -> "" da solo: il ternario era un ramo in piu' per niente
	var solo_questa := String(passo.get("id", ""))
	# I COLPI D'ARMA STANNO QUI, non in una voce loro: sono attacchi speciali
	# quanto gli altri, e l'arma che hai in mano cambia cosa sai fare
	for attacco in GameState.attacchi_arma(String(attaccante.get("id", ""))):
		var costo_arma := int(attacco.get("aura", 0))
		var etichetta_arma := "%s  (+%d)" % [String(attacco.get("nome", "?")), int(attacco.get("bonus", 0))]
		if costo_arma > 0:
			etichetta_arma += "  (%d aura)" % costo_arma
		bottone(etichetta_arma, bersagli_di_attacco.bind(attacco), aura < costo_arma or lezione)
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
		# nessuna abilita' si chiama "", quindi fuori da una lezione questo e'
		# falso da solo: il guardiano su solo_questa era un ramo per niente
		var richiesta: bool = solo_questa == String(id_abilita)
		var spenta: bool = aura < costo or senza_barra or spenta_dalla_lezione(
				String(id_abilita), lezione, solo_questa)
		if scontro.abilita_vuole_bersaglio(String(id_abilita)):
			bottone(etichetta, bersagli_abilita.bind(String(id_abilita)), spenta, richiesta)
		else:
			bottone(etichetta, scegli.bind({"tipo": "abilita", "id": String(id_abilita)}),
					spenta, richiesta)
	bottone("Indietro", principale)

func spenta_dalla_lezione(id_abilita: String, lezione: bool, solo_questa: String) -> bool:
	# durante una lezione del tutorial si accende solo quello che e' stato
	# chiesto: il resto resta li', grigio, cosi' il menu non cambia forma
	return lezione and id_abilita != solo_questa

func bersagli_abilita(id_abilita: String) -> void:
	modo = "lista"
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
	modo = "lista"
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
	modo = "lista"
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
