class_name CampoCombattimento
extends RefCounted

# Il campo: le schede dei combattenti e tutto quello che si legge guardandole
# di sfuggita. Vita, aura, stress, fattore, stati addosso, chi tocca adesso.
#
# E' il canale dello STATO. Non racconta cosa e' successo (quello lo fa Voce),
# dice come stanno le cose adesso. Il giocatore ci butta l'occhio tra un'azione
# e l'altra senza doverlo leggere: per questo qui non compaiono mai frasi, solo
# numeri e nomi brevi.
#
# Il primo nemico (il boss, o il primo di un gruppo comune) resta sempre al
# centro del campo e viene disegnato grande; chi si aggiunge dopo - altri della
# stessa imboscata, o un'evocazione - si dispone ai lati, alternando destra e
# sinistra, cosi' il colpevole principale e' sempre riconoscibile a colpo d'occhio.
#
# In modalita' muta non crea nessun nodo e non aggiorna niente: il giocatore
# automatico non ha uno schermo da guardare. I combattenti restano dizionari
# identici, solo con "scheda" a null.

const SCENA_RITRATTO := preload("res://scenes/Ritratto.tscn")

var muta := false
var fila_party: HBoxContainer
var nemico_centro: HBoxContainer
var nemici_sinistra: HBoxContainer
var nemici_destra: HBoxContainer

var centrale_occupato := false
var prossimo_lato := "destra"
# quante volte e' stato chiesto di ridisegnare una scheda: lo contiamo anche da
# muti, perche' e' l'unico modo che hanno le prove di accorgersi se una scheda
# cambia PRIMA che il box abbia raccontato perche'
var aggiornamenti := 0

func _init(silenzioso := false) -> void:
	muta = silenzioso

func collega(party: HBoxContainer, centro: HBoxContainer, sinistra: HBoxContainer, destra: HBoxContainer) -> void:
	fila_party = party
	nemico_centro = centro
	nemici_sinistra = sinistra
	nemici_destra = destra

func crea_scheda(id_personaggio: String, giocatore: bool) -> Dictionary:
	# restituisce {scheda, etichetta_vita, etichetta_extra}: i tre nodi che il
	# combattente si porta dietro. Vuoti (null) se il campo e' muto.
	if muta:
		return {"scheda": null, "etichetta_vita": null, "etichetta_extra": null}
	var scheda := VBoxContainer.new()
	var ritratto := SCENA_RITRATTO.instantiate()
	scheda.add_child(ritratto)
	var vita := Label.new()
	vita.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scheda.add_child(vita)
	var extra := Label.new()
	extra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	extra.add_theme_font_size_override("font_size", 12)
	extra.modulate = Color(1, 1, 1, 0.7)
	scheda.add_child(extra)
	if giocatore:
		fila_party.add_child(scheda)
		ritratto.mostra(id_personaggio, GameState.livello_di(id_personaggio))
	else:
		var e_il_centrale := false
		if not centrale_occupato:
			centrale_occupato = true
			e_il_centrale = true
			scheda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			scheda.size_flags_vertical = Control.SIZE_EXPAND_FILL
			nemico_centro.add_child(scheda)
		elif prossimo_lato == "destra":
			nemici_destra.add_child(scheda)
			prossimo_lato = "sinistra"
		else:
			nemici_sinistra.add_child(scheda)
			prossimo_lato = "destra"
		# solo dopo add_child: prima l'@onready interno del ritratto e' ancora nullo
		if e_il_centrale:
			ritratto.imposta_grande(true)
		ritratto.mostra(id_personaggio)
	return {"scheda": scheda, "etichetta_vita": vita, "etichetta_extra": extra}

func aggiorna(combattente: Dictionary) -> void:
	# un nemico battuto lascia il campo: si dissolve e sparisce, non resta li'
	# sbiadito. I compagni a terra restano visibili (sono tuoi, non sono usciti)
	aggiornamenti += 1
	if muta or combattente.get("scheda", null) == null:
		return
	var fuori_dal_campo: bool = int(combattente.hp) <= 0 and not bool(combattente.giocatore)
	if fuori_dal_campo and not bool(combattente.get("uscito", false)):
		combattente["uscito"] = true
		congeda(combattente.scheda)
	elif not fuori_dal_campo and bool(combattente.get("uscito", false)):
		# un invincibile che si rialza torna in scena: rientra, non riappare
		combattente["uscito"] = false
		combattente.scheda.visible = true
		combattente.scheda.modulate = Color.WHITE
	if combattente.hp <= 0:
		combattente.etichetta_vita.text = "KO"
		combattente.scheda.modulate = Color(0.5, 0.4, 0.4, 0.5)
	elif combattente.get("hp_nascosti", false):
		# i boss (e i nemici scriptati come la manifestazione) non mostrano il
		# conteggio esatto degli hp: mantiene l'incertezza sullo scontro
		combattente.etichetta_vita.text = "♥ ???"
	elif not conosciuta(combattente, 1):
		combattente.etichetta_vita.text = "♥ ???"
	else:
		combattente.etichetta_vita.text = "♥ %d/%d" % [combattente.hp, combattente.hp_max]
	combattente.etichetta_extra.text = dettagli_di(combattente)

func conosciuta(combattente: Dictionary, strato: int) -> bool:
	# Studiare era una cosa che si LEGGEVA: premevi, usciva del testo, e sullo
	# schermo non cambiava niente. Il giocatore capiva sempre di piu' e non lo
	# vedeva da nessuna parte.
	#
	# Adesso la scheda di una creatura si riempie a strati, uno per studio:
	#   0 studi -> "♥ ???", non sai niente di lei
	#   1 studio -> i punti vita esatti
	#   2 studi -> quanto para e quanto picchia
	# I tuoi compagni li conosci gia'; i boss restano a "???" comunque, che e'
	# una scelta piu' vecchia e piu' importante di questa.
	if combattente.giocatore or combattente.get("oggetto_scena", false):
		return true
	if not bool(GameState.regole.get("studio_rivela", true)):
		return true   # interruttore in regole.json: si torna al vecchio modo
	return int(combattente.get("volte_studiato", 0)) >= strato

func dettagli_di(combattente: Dictionary) -> String:
	if not conosciuta(combattente, 1):
		return "non l'hai ancora guardata"
	var dettagli := ""
	if not combattente.giocatore:
		dettagli += progresso_studio(combattente)
	if int(combattente.get("aura_max", 0)) > 0:
		dettagli += "Aura %d/%d · " % [int(combattente.aura), int(combattente.aura_max)]
	dettagli += "Stress %d · Dominio %d" % [combattente.stress, combattente.fattore]
	var scudo := RegoleCombattimento.difesa_di(combattente)
	if scudo > 0 and conosciuta(combattente, 2):
		dettagli += " · Dif %d" % scudo
	if not combattente.giocatore and conosciuta(combattente, 2):
		dettagli += " · Att %d" % RegoleCombattimento.attacco_di(combattente)
	if combattente.stress >= int(GameState.regole.get("soglia_stress_sopraffatto", 80)):
		dettagli += " · sopraffatto"
	if combattente.get("in_fiamme", false):
		dettagli += " · in fiamme"
	if float(combattente.get("carica_pronta", 0.0)) > 0.0:
		dettagli += " · carico"  # ha un turno in canna: il prossimo colpo e' un altro discorso
	if not combattente.giocatore and conosciuta(combattente, 2):
		var livello_ora := GameState.livello_nemico(String(combattente.id))
		if livello_ora > GameState.livello_base_nemico(String(combattente.id)):
			# si e' alimentata del tuo carnival: e' piu' forte di quanto nascesse
			dettagli += " · Lv %d (alimentata)" % livello_ora
	for id_stato in combattente.stati_attivi:
		var info_stato: Dictionary = GameState.stati.get(id_stato, {})
		var nome_stato: String = String(info_stato.get("nome", id_stato))
		var attivo: Dictionary = combattente.stati_attivi[id_stato]
		if attivo.has("turni_rimasti"):
			dettagli += " · %s (%d)" % [nome_stato, int(attivo.turni_rimasti)]
		else:
			dettagli += " · %s" % nome_stato
	if combattente.psiche in combattente.stati:
		dettagli += " · " + String(GameState.psichi.get(combattente.psiche, {}).get("nome", combattente.psiche))
	return dettagli

func progresso_studio(combattente: Dictionary) -> String:
	# Per le creature che si possono lasciare andare, quante volte le hai gia'
	# guardate e quante ne servono. Senza questo il risparmio arriva dal nulla:
	# studi, studi, e a un certo punto succede qualcosa. Con questo si vede
	# arrivare, ed e' una cosa che si sceglie invece che una che capita.
	var dati: Dictionary = GameState.personaggi.get(combattente.id, {})
	if not dati.has("risparmio"):
		return ""
	var richiesti := maxi(int(dati["risparmio"].get("studi_richiesti", 1)), 1)
	var fatti := mini(int(combattente.get("volte_studiato", 0)), richiesti)
	if fatti >= richiesti:
		return ""
	return "capita %d/%d · " % [fatti, richiesti]

func evidenzia(combattenti: Array[Dictionary], attivo: Dictionary) -> void:
	# di chi e' il turno si vede senza leggere: gli altri si spengono un po'
	if muta:
		return
	for combattente in combattenti:
		if combattente.hp <= 0 or combattente.get("scheda", null) == null:
			continue
		var suo_turno: bool = combattente.indice == attivo.indice
		combattente.scheda.modulate = Color.WHITE if suo_turno else Color(1, 1, 1, 0.65)

func congeda(scheda: Control) -> void:
	if muta or scheda == null or not is_instance_valid(scheda):
		return
	var uscita := scheda.create_tween()
	uscita.tween_property(scheda, "modulate:a", 0.0, Stile.tempo("uscita_sconfitto"))
	uscita.finished.connect(func() -> void:
		if is_instance_valid(scheda):
			scheda.visible = false)
