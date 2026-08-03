class_name SchedaPersonaggio
extends VBoxContainer

# La scheda di un personaggio: chi è, cosa porta addosso, quanto vale.
#
# COME È FATTA, E PERCHÉ. La schermata dell'equipaggiamento è quella che il
# giocatore apre più spesso di ogni altra, ed è tradizionalmente la più confusa
# di un gioco di ruolo. Le regole che seguiamo sono tre, tutte prese da chi
# questo mestiere lo fa da vent'anni:
#
#   1. TUTTO SU UNA SCHERMATA. Statistiche ed equipaggiamento non si separano
#      in due pagine: chi cambia un accessorio vuole vedere subito cosa
#      succede alle sue statistiche, non ricordarsele mentre naviga.
#   2. SEMPRE LA DIFFERENZA, MAI SOLO IL NUMERO. Un oggetto non dice "difesa
#      +2": dice "+2" ACCANTO a quello che porti adesso, con il segno e il
#      colore. La decisione deve costare un secondo, non un calcolo.
#   3. QUELLO CHE NON PUOI ANCORA USARE SI VEDE LO STESSO, E SI CAPISCE
#      PERCHÉ. Uno slot chiuso nascosto è un premio che non sai di poter
#      vincere; uno slot chiuso mostrato col suo motivo ("si apre al livello
#      15") è un motivo per continuare.
#
# Tre colonne, senza sottomenu:
#   sinistra -> chi è: il ritratto grande, nome, classe, livello, esperienza
#   centro   -> cosa porta: arma, stigma, ultima risorsa, accessori
#   destra   -> quanto vale: le statistiche, e in fase di scelta la differenza
#
# In alto le linguette dei compagni: la squadra si guarda da qui, senza uscire.
# In basso il Diario.

# Vive dentro la Pausa (ESC), non come schermata a se': cosi' si apre da
# ovunque - mappa, stanza, Vuoto - senza cambiare scena e senza perdere il
# posto in cui si era.

# Le statistiche mostrate, nell'ordine in cui contano per chi combatte.
const STATISTICHE := [
	["hp", "Punti vita"],
	["attacco", "Attacco"],
	["difesa", "Difesa"],
	["velocita", "Velocità"],
	["aura", "Aura"],
]

var id_scelto := ""
var slot_aperto := ""          # slot di cui si stanno scegliendo gli oggetti
var indice_aperto := 0         # quale accessorio, se lo slot è "accessori"

var su_indietro := Callable()
var su_diario := Callable()

var linguette: HBoxContainer
var colonna_sinistra: VBoxContainer
var colonna_centro: VBoxContainer
var colonna_destra: VBoxContainer
var comandi: HBoxContainer

func apri(indietro: Callable, diario: Callable) -> void:
	su_indietro = indietro
	su_diario = diario
	costruisci_impalcatura()
	id_scelto = GameState.party[0] if not GameState.party.is_empty() else GameState.id_protagonista
	ridisegna()

# --- impalcatura -------------------------------------------------------------

func costruisci_impalcatura() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var colonna := self
	colonna.add_theme_constant_override("separation", 14)
	linguette = HBoxContainer.new()
	linguette.add_theme_constant_override("separation", 6)
	colonna.add_child(linguette)
	var corpo := HBoxContainer.new()
	corpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	corpo.add_theme_constant_override("separation", 18)
	colonna.add_child(corpo)
	colonna_sinistra = pannello(corpo, 1.0)
	colonna_centro = pannello(corpo, 1.2)
	colonna_destra = pannello(corpo, 1.2)
	comandi = HBoxContainer.new()
	comandi.add_theme_constant_override("separation", 10)
	colonna.add_child(comandi)

func pannello(genitore: Control, peso: float) -> VBoxContainer:
	# ogni colonna è un pannello con la stessa cornice del resto del gioco
	var cornice := PanelContainer.new()
	cornice.add_theme_stylebox_override("panel", Stile.stile_pannello())
	cornice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cornice.size_flags_stretch_ratio = peso
	genitore.add_child(cornice)
	var margini := MarginContainer.new()
	for lato in ["left", "right", "top", "bottom"]:
		margini.add_theme_constant_override("margin_" + lato, 14)
	cornice.add_child(margini)
	var dentro := VBoxContainer.new()
	dentro.add_theme_constant_override("separation", 8)
	margini.add_child(dentro)
	return dentro

func svuota(contenitore: Node) -> void:
	for figlio in contenitore.get_children():
		contenitore.remove_child(figlio)
		figlio.queue_free()

# --- disegno -----------------------------------------------------------------

func ridisegna() -> void:
	svuota(linguette)
	svuota(colonna_sinistra)
	svuota(colonna_centro)
	svuota(colonna_destra)
	svuota(comandi)
	disegna_linguette()
	disegna_identita()
	disegna_slot()
	if slot_aperto == "":
		disegna_statistiche()
	else:
		disegna_scelta_oggetto()
	disegna_comandi()

func disegna_linguette() -> void:
	# la squadra si guarda da qui: cambiare compagno non deve costare un'uscita
	for id_classe in GameState.party:
		var bottone := Button.new()
		bottone.text = nome_di(id_classe)
		bottone.toggle_mode = true
		bottone.button_pressed = id_classe == id_scelto
		bottone.disabled = id_classe == id_scelto
		Stile.scelta(bottone)
		bottone.pressed.connect(func() -> void:
			id_scelto = id_classe
			slot_aperto = ""
			ridisegna())
		linguette.add_child(bottone)

func disegna_identita() -> void:
	var ritratto := preload("res://scenes/Ritratto.tscn").instantiate()
	ritratto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colonna_sinistra.add_child(ritratto)
	# add_child prima: dentro al ritratto l'@onready è ancora nullo
	ritratto.imposta_grande(true)
	ritratto.mostra(id_scelto, GameState.livello_di(id_scelto))
	var titolo := Label.new()
	titolo.text = nome_di(id_scelto)
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Stile.titolo_schermata(titolo)
	colonna_sinistra.add_child(titolo)
	var classe: Dictionary = GameState.classi.get(id_scelto, {})
	riga_semplice(colonna_sinistra, String(classe.get("classe", classe.get("nome", ""))), true)
	riga_semplice(colonna_sinistra, "Livello %d" % GameState.livello_di(id_scelto))
	if id_scelto == GameState.id_protagonista:
		riga_semplice(colonna_sinistra, "Esperienza %d" % int(GameState.xp.get(id_scelto, 0)))
	riga_semplice(colonna_sinistra, "Legame della squadra %d" % GameState.legame)
	var psiche := String(GameState.personaggi.get(id_scelto, {}).get("psiche", ""))
	if psiche != "":
		riga_semplice(colonna_sinistra, "Psiche: %s"
				% String(GameState.psichi.get(psiche, {}).get("nome", psiche)), true)

func disegna_slot() -> void:
	intestazione(colonna_centro, "Cosa porta addosso")
	if not GameState.e_definitivo(id_scelto):
		# chi ti accompagna per un tratto combatte al tuo fianco, ma le tue cose
		# gliele affidi solo quando resta
		riga_semplice(colonna_centro,
				"È con te solo per un tratto: non gli si affida ancora niente.", true)
		return
	voce_slot("arma", 0, "Arma")
	voce_slot("stigma", 0, "Stigma")
	voce_slot("ultima_risorsa", 0, "Ultima risorsa")
	var quanti := GameState.slot_accessori_di(id_scelto)
	var mostrati := maxi(quanti, prossimo_slot_da_aprire(quanti))
	for indice in range(mostrati):
		voce_slot("accessori", indice, "Accessorio %d" % (indice + 1))

func prossimo_slot_da_aprire(gia_aperti: int) -> int:
	# si mostra sempre uno slot chiuso in più di quelli aperti: è quello che dice
	# al giocatore che la strada continua. Oltre non si va: una colonna di
	# lucchetti non è una promessa, è rumore
	return gia_aperti + 1 if GameState.livello_slot_accessorio(gia_aperti) > 0 else gia_aperti

func voce_slot(slot: String, indice: int, etichetta: String) -> void:
	var aperto := indice < GameState.slot_accessori_di(id_scelto) or slot != "accessori"
	var id_oggetto := GameState.equipaggiato_in(id_scelto, slot, indice)
	var bottone := Button.new()
	if not aperto:
		var livello := GameState.livello_slot_accessorio(indice)
		bottone.text = "%s — 🔒 si apre al livello %d" % [etichetta, livello]
		bottone.disabled = true
	elif id_oggetto == "":
		bottone.text = "%s — vuoto" % etichetta
	else:
		bottone.text = "%s — %s" % [etichetta, nome_oggetto(id_oggetto)]
	bottone.alignment = HORIZONTAL_ALIGNMENT_LEFT
	Stile.scelta(bottone)
	if aperto:
		bottone.pressed.connect(func() -> void:
			slot_aperto = slot
			indice_aperto = indice
			ridisegna())
	colonna_centro.add_child(bottone)
	# uno slot aperto da un talento lo dice: un premio che non sai di aver vinto
	# non è un premio
	if aperto and slot == "accessori":
		var talento := GameState.talento_dello_slot(id_scelto, indice)
		if talento != "":
			riga_semplice(colonna_centro, "   grazie al tuo talento: %s" % talento, true)

func disegna_statistiche() -> void:
	intestazione(colonna_destra, "Quanto vale")
	for voce in STATISTICHE:
		var chiave: String = voce[0]
		var base := statistica_base(id_scelto, chiave)
		var bonus := bonus_di(id_scelto, chiave)
		var riga := HBoxContainer.new()
		var nome := Label.new()
		nome.text = String(voce[1])
		nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		riga.add_child(nome)
		var valore := Label.new()
		valore.text = str(base + bonus)
		riga.add_child(valore)
		if bonus != 0:
			# l'equipaggiamento non si confonde col talento: quanto viene da
			# quello che porti addosso si legge a parte, e col suo colore
			var quota := Label.new()
			quota.text = "  (%+d)" % bonus
			quota.add_theme_color_override("font_color",
					Stile.colore("positivo") if bonus > 0 else Stile.colore("pericolo"))
			riga.add_child(quota)
		colonna_destra.add_child(riga)
	var protezioni := elenco_protezioni()
	if not protezioni.is_empty():
		intestazione(colonna_destra, "Protezioni addosso")
		for testo in protezioni:
			riga_semplice(colonna_destra, "· " + testo, true)

func disegna_scelta_oggetto() -> void:
	# La regola che conta: ogni candidato mostra la DIFFERENZA rispetto a quello
	# che porti adesso in quello slot, non il suo valore assoluto. "+2 difesa,
	# −1 velocità" si decide in un secondo; "difesa 3" costa un calcolo.
	var attuale := GameState.equipaggiato_in(id_scelto, slot_aperto, indice_aperto)
	intestazione(colonna_destra, "Cosa metterci")
	if attuale != "":
		var togli := Button.new()
		togli.text = "Togli %s" % nome_oggetto(attuale)
		Stile.scelta(togli)
		togli.pressed.connect(func() -> void:
			GameState.togli_oggetto_equipaggiato(attuale)
			slot_aperto = ""
			ridisegna())
		colonna_destra.add_child(togli)
	var candidati := oggetti_per_slot(slot_aperto)
	if candidati.is_empty():
		riga_semplice(colonna_destra, "Non hai niente da mettere qui.", true)
	for id_oggetto in candidati:
		colonna_destra.add_child(riga_candidato(id_oggetto, attuale))
	var indietro := Button.new()
	indietro.text = "Indietro"
	Stile.scelta(indietro)
	indietro.pressed.connect(func() -> void:
		slot_aperto = ""
		ridisegna())
	colonna_destra.add_child(indietro)

func riga_candidato(id_oggetto: String, attuale: String) -> Control:
	var blocco := VBoxContainer.new()
	blocco.add_theme_constant_override("separation", 0)
	var bottone := Button.new()
	if slot_aperto == "arma" and GameState.portatore_di(id_oggetto) == id_scelto:
		# le armi non escono dallo zaino quando le impugni: restano li', segnate
		bottone.text = "· in uso ·  "
	var portatore := GameState.portatore_di(id_oggetto)
	var addosso_ad_altri := portatore != "" and portatore != id_scelto
	bottone.text += nome_oggetto(id_oggetto)
	if addosso_ad_altri:
		# non si nasconde: si dice chi ce l'ha. Un oggetto che sparisce
		# dall'elenco sembra perso
		bottone.text += "  (addosso a %s)" % nome_di(portatore)
	bottone.alignment = HORIZONTAL_ALIGNMENT_LEFT
	Stile.scelta(bottone)
	bottone.pressed.connect(func() -> void:
		if attuale != "":
			GameState.togli_oggetto_equipaggiato(attuale)
		GameState.equipaggia(id_scelto, slot_aperto, id_oggetto)
		slot_aperto = ""
		ridisegna())
	blocco.add_child(bottone)
	var differenze := differenza_testo(id_oggetto, attuale)
	if differenze != "":
		var delta := Label.new()
		delta.text = "   " + differenze
		Stile.etichetta_piccola(delta)
		blocco.add_child(delta)
	var descrizione := String(GameState.dati_oggetto(id_oggetto).get("descrizione", ""))
	if descrizione != "":
		var testo := Label.new()
		testo.text = "   " + descrizione
		testo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		Stile.etichetta_piccola(testo)
		blocco.add_child(testo)
	return blocco

func disegna_comandi() -> void:
	var diario := Button.new()
	diario.text = "Diario"
	Stile.scelta(diario)
	diario.pressed.connect(func() -> void:
		if su_diario.is_valid():
			su_diario.call())
	comandi.add_child(diario)
	var chiudi := Button.new()
	chiudi.text = "Indietro"
	Stile.scelta(chiudi)
	chiudi.pressed.connect(func() -> void:
		if su_indietro.is_valid():
			su_indietro.call())
	comandi.add_child(chiudi)

# --- conti -------------------------------------------------------------------

func statistica_base(id_classe: String, chiave: String) -> int:
	# il protagonista cresce con quello che fa (crescita.json); i compagni hanno
	# le loro statistiche scritte nei dati
	if chiave == "aura":
		return GameState.aura_massima(id_classe) - GameState.bonus_equipaggiamento(id_classe, "aura_max")
	if id_classe == GameState.id_protagonista:
		return GameState.stat_di(chiave)
	var dati: Dictionary = GameState.personaggi.get(id_classe, {})
	return int(dati.get(chiave, 0))

func bonus_di(id_classe: String, chiave: String) -> int:
	if chiave == "hp":
		return GameState.bonus_equipaggiamento(id_classe, "hp_max")
	if chiave == "aura":
		return GameState.bonus_equipaggiamento(id_classe, "aura_max")
	return GameState.bonus_equipaggiamento(id_classe, chiave)

func differenza_testo(id_candidato: String, id_attuale: String) -> String:
	# Il cuore della schermata: ogni candidato mostra la DIFFERENZA rispetto a
	# quello che porti adesso in quello slot, non il suo valore assoluto.
	# "difesa +2, velocita' −1" si decide in un secondo; "difesa 3" costa un
	# calcolo che il giocatore non deve fare.
	#
	# Il conto e' PURO: si sottrae quello che dava il vecchio e si somma quello
	# che da' il nuovo, senza mettere niente addosso a nessuno. La prima
	# versione invece equipaggiava davvero e poi rimetteva tutto a posto - e non
	# lo rimetteva a posto: con gli slot pieni l'oggetto non entrava ma veniva
	# tolto lo stesso a chi ce l'aveva, e l'ordine degli accessori cambiava ogni
	# volta. Bastava SCORRERE l'elenco per spogliare un compagno.
	# Le prove l'hanno preso al primo giro (prova_scheda_personaggio).
	var pezzi: Array[String] = []
	for voce in STATISTICHE:
		var chiave := String(voce[0])
		var interna := chiave
		if chiave == "hp":
			interna = "hp_max"
		elif chiave == "aura":
			interna = "aura_max"
		var scarto := GameState.bonus_oggetto(id_candidato, interna) \
				- GameState.bonus_oggetto(id_attuale, interna)
		if scarto != 0:
			pezzi.append("%s %+d" % [String(voce[1]).to_lower(), scarto])
	if pezzi.is_empty():
		return "nessun cambiamento nelle statistiche"
	return ", ".join(pezzi)

func oggetti_per_slot(slot: String) -> Array[String]:
	var risultato: Array[String] = []
	var visti := {}
	var sorgente: Array = GameState.magazzino_per_slot(slot)
	for id_oggetto in sorgente:
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

func elenco_protezioni() -> Array[String]:
	# le protezioni non sono numeri e sparirebbero dalla tabella: si dicono a parole
	var risultato: Array[String] = []
	var slots := GameState.slot_di(id_scelto)
	var addosso: Array[String] = []
	for slot in ["arma", "stigma", "ultima_risorsa"]:
		if String(slots.get(slot, "")) != "":
			addosso.append(String(slots[slot]))
	for id_oggetto in slots.get("accessori", []):
		addosso.append(String(id_oggetto))
	for id_oggetto in addosso:
		var effetto: Dictionary = GameState.dati_oggetto(id_oggetto).get("effetto_equipaggiato", {})
		match String(effetto.get("tipo", "")):
			"scudo_primo_stato":
				risultato.append("%s respinge il primo stato che subisci" % nome_oggetto(id_oggetto))
			"resurrezione_dimezzata":
				risultato.append("%s ti rimette in piedi una volta sola" % nome_oggetto(id_oggetto))
	var maledizione := GameState.bonus_equipaggiamento(id_scelto, "resistenza_maledizione")
	if maledizione > 0:
		risultato.append("il conto della maledizione parte da %d rintocchi più in alto" % maledizione)
	return risultato

# --- utilità -----------------------------------------------------------------

func nome_di(id_classe: String) -> String:
	return String(GameState.personaggi.get(id_classe, {}).get("nome",
			GameState.classi.get(id_classe, {}).get("nome", id_classe)))

func nome_oggetto(id_oggetto: String) -> String:
	return String(GameState.dati_oggetto(id_oggetto).get("nome", id_oggetto))

func intestazione(dove: VBoxContainer, testo: String) -> void:
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.add_theme_color_override("font_color", Stile.colore("accento"))
	etichetta.add_theme_font_size_override("font_size", Stile.dimensione("sezione"))
	dove.add_child(etichetta)

func riga_semplice(dove: VBoxContainer, testo: String, smorzata := false) -> void:
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if smorzata:
		Stile.etichetta_piccola(etichetta)
	dove.add_child(etichetta)

