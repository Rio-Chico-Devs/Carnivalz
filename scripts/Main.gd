extends Control

# Motore eventi: mostra il nodo corrente, filtra le scelte per requisiti
# e applica gli effetti (recluta / oggetto / lascia / reset). I contenuti
# vivono solo nei JSON.
#
# Palco dialoghi sopra il box: a sinistra sempre il protagonista (o un
# alternativo indicato dal nodo), a destra l'interlocutore della
# discussione. Se il nodo indica "centro", parla un solo personaggio al
# centro e i due spazi laterali spariscono.

const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCENA_VUOTO := "res://scenes/Vuoto.tscn"
const SCENA_COMBATTIMENTO := "res://scenes/Combattimento.tscn"
const EVENTI_DEBUG := "res://data/events.json"

@onready var slot_sinistra = %SlotSinistra
@onready var slot_centro = %SlotCentro
@onready var slot_destra = %SlotDestra
@onready var nome_parlante: Label = %NomeParlante
@onready var narratore: RichTextLabel = %Narratore
@onready var contenitore_scelte: VBoxContainer = %Scelte
@onready var bottone_dialoga: Button = %BottoneDialoga
@onready var menu_compagni: HBoxContainer = %MenuCompagni
@onready var stato: Label = %Stato

func _ready() -> void:
	if GameState.eventi.is_empty():
		# scena avviata direttamente dall'editor: carica la campagna di prova
		GameState.avvia_carnivalz("debug", EVENTI_DEBUG)
	AudioManager.musica(GameState.musica_ambiente)
	for slot in [slot_sinistra, slot_centro, slot_destra]:
		slot.imposta_grande(true)  # ritratto cinematografico, riempie lo schermo sopra il box
	bottone_dialoga.pressed.connect(_su_dialoga)
	mostra_nodo(GameState.nodo_corrente)

func mostra_nodo(id_nodo: String) -> void:
	var nodo: Dictionary = GameState.eventi.get(id_nodo, {})
	if nodo.is_empty():
		push_error("Nodo evento mancante: " + id_nodo)
		return
	GameState.nodo_corrente = id_nodo
	if nodo.has("flag"):
		GameState.imposta_flag(nodo["flag"])
	if nodo.has("congeda"):
		GameState.congeda(nodo["congeda"])
	# agguato: ogni volta che si entra nella stanza si tenta la probabilita';
	# se scatta si combatte (e non si ritenta subito tornando qui a vittoria
	# ottenuta); se non scatta, la prossima visita ritenta da capo
	if nodo.has("agguato") and id_nodo not in GameState.stanze_ripulite:
		var agguato: Dictionary = nodo["agguato"]
		if GameState.rng.randf() < float(agguato.get("probabilita", 0.3)):
			var gruppi: Array = agguato.get("gruppi", [])
			if not gruppi.is_empty():
				GameState.stanze_ripulite.append(id_nodo)
				var gruppo: Array = gruppi[GameState.rng.randi_range(0, gruppi.size() - 1)]
				# fuggire da un agguato non ha penalita': si torna semplicemente qui
				GameState.prepara_combattimento(gruppo, id_nodo, "", agguato.get("se_perdi", ""), id_nodo)
				get_tree().change_scene_to_file(SCENA_COMBATTIMENTO)
				return
	narratore.text = nodo.get("testo", "")
	aggiorna_palco(nodo)
	aggiorna_stato()
	if nodo.get("espulsione_automatica", false):
		# non c'e' niente da scegliere: il posto stesso ti rigetta fuori
		for figlio in contenitore_scelte.get_children():
			figlio.queue_free()
		aggiorna_dialoga()
		await get_tree().create_timer(1.8).timeout
		GameState.congeda_tutti_temporanei()
		get_tree().change_scene_to_file(SCENA_VUOTO)
		return
	ricostruisci_scelte(nodo)
	aggiorna_dialoga()

func ricostruisci_scelte(nodo: Dictionary) -> void:
	for figlio in contenitore_scelte.get_children():
		figlio.queue_free()
	for scelta in nodo.get("scelte", []):
		if scelta.has("richiede") and not GameState.party_ha_abilita(scelta["richiede"]):
			continue  # requisito non soddisfatto: la scelta non appare proprio
		if scelta.has("richiede_legame") and GameState.legame < int(scelta["richiede_legame"]):
			continue  # evento raro: serve un legame abbastanza coltivato
		if scelta.has("richiede_ospite") and scelta["richiede_ospite"] not in GameState.ospiti:
			continue
		if scelta.has("richiede_flag") and not GameState.ha_flag(scelta["richiede_flag"]):
			continue
		if scelta.has("richiede_non_flag") and GameState.ha_flag(scelta["richiede_non_flag"]):
			continue
		if scelta.has("richiede_oggetti") and not GameState.possiede_tutti(scelta["richiede_oggetti"]):
			continue  # servono tutti i pezzi (es. la Fontana)
		if scelta.has("una_tantum") and GameState.ha_flag(scelta["una_tantum"]):
			continue  # gia' raccolto/fatto: la scelta non torna
		if int(scelta.get("tazo", 0)) < 0 and GameState.tazo < -int(scelta.get("tazo", 0)):
			continue  # non puoi pagare cio' che non hai
		var bottone := Button.new()
		bottone.text = scelta.get("testo", "…")
		bottone.pressed.connect(_su_scelta.bind(scelta))
		contenitore_scelte.add_child(bottone)

func pickup(id_oggetto: String) -> void:
	# notifica come toast indipendente dal narratore: non si perde nel cambio
	# nodo (il narratore viene riscritto subito dopo, se la scelta ha "vai").
	# Per gli oggetti chiave (di solito indizi/lore, come le pagine di
	# giornale di Meridia) il toast resta a schermo più a lungo e mostra
	# anche la descrizione, non solo il nome.
	var dati := GameState.dati_oggetto(id_oggetto)
	var nome: String = String(dati.get("nome", id_oggetto))
	if not GameState.aggiungi_oggetto(id_oggetto):
		mostra_toast("%s: la sacca è piena, non c'è posto per lui." % nome, 2.5)
		return
	var tipo := String(dati.get("tipo", "consumabile"))
	var luogo := "nella sacca"
	match tipo:
		"collezionabile":
			luogo = "tra i collezionabili"
		"chiave":
			luogo = "tra gli oggetti chiave"
	var testo_toast := "Hai ottenuto: %s (%s)" % [nome, luogo]
	var durata := 2.2
	if tipo == "chiave":
		testo_toast += "\n%s" % String(dati.get("descrizione", ""))
		durata = 5.0
	mostra_toast(testo_toast, durata)

func mostra_toast(testo: String, durata := 2.2) -> void:
	var pannello := PanelContainer.new()
	var stile := StyleBoxFlat.new()
	stile.bg_color = Color(0, 0, 0, 0.9)
	stile.border_width_left = 2
	stile.border_width_top = 2
	stile.border_width_right = 2
	stile.border_width_bottom = 2
	stile.border_color = Color(1, 1, 1, 1)
	stile.content_margin_left = 18
	stile.content_margin_right = 18
	stile.content_margin_top = 10
	stile.content_margin_bottom = 10
	pannello.add_theme_stylebox_override("panel", stile)
	pannello.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pannello.modulate = Color(1, 1, 1, 0)
	pannello.set_anchors_preset(Control.PRESET_CENTER_TOP)
	pannello.position.y = 24
	add_child(pannello)
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etichetta.custom_minimum_size = Vector2(420, 0)
	etichetta.autowrap_mode = TextServer.AUTOWRAP_WORD
	pannello.add_child(etichetta)
	var tween := create_tween()
	tween.tween_property(pannello, "modulate:a", 1.0, 0.2)
	tween.tween_interval(durata)
	tween.tween_property(pannello, "modulate:a", 0.0, 0.4)
	tween.tween_callback(pannello.queue_free)

func aggiorna_palco(nodo: Dictionary) -> void:
	if nodo.has("centro"):
		slot_sinistra.visible = false
		slot_destra.visible = false
		slot_centro.visible = true
		mostra_slot(slot_centro, nodo["centro"], nodo.get("espr_centro", ""))
		aggiorna_nome_parlante(id_da_valore(nodo["centro"]))
		return
	slot_centro.visible = false
	slot_sinistra.visible = true
	mostra_slot(slot_sinistra, nodo.get("sinistra", GameState.id_protagonista), nodo.get("espr_sinistra", ""))
	slot_destra.visible = nodo.has("destra")
	if nodo.has("destra"):
		mostra_slot(slot_destra, nodo["destra"], nodo.get("espr_destra", ""))
	# la narrazione e' sempre vissuta come il dialogo interiore del protagonista
	aggiorna_nome_parlante(GameState.id_protagonista)

func id_da_valore(valore: Variant) -> String:
	if valore is Dictionary:
		return String(valore.get("id", ""))
	return String(valore)

func aggiorna_nome_parlante(id_personaggio: String) -> void:
	nome_parlante.text = String(GameState.personaggi.get(id_personaggio, {}).get("nome", id_personaggio))

func mostra_slot(slot, valore: Variant, espr_nodo: String) -> void:
	# valore: id stringa, oppure {id, espr}. L'espressione può anche venire
	# dalla chiave espr_<lato> del nodo.
	var id_personaggio := ""
	var espressione := "neutra"
	if valore is Dictionary:
		id_personaggio = String(valore.get("id", ""))
		espressione = String(valore.get("espr", "neutra"))
	else:
		id_personaggio = String(valore)
	if espr_nodo != "":
		espressione = espr_nodo
	slot.mostra(id_personaggio, 0, espressione)

func _su_scelta(scelta: Dictionary) -> void:
	GameState.modifica_legame(-1)  # il legame respira: cala se non lo curi
	if scelta.has("flag"):
		GameState.imposta_flag(scelta["flag"])
	if scelta.has("una_tantum"):
		GameState.imposta_flag(scelta["una_tantum"])
	if scelta.has("recluta"):
		GameState.recluta(scelta["recluta"])
	if scelta.has("oggetto"):
		pickup(scelta["oggetto"])
	if scelta.has("lascia"):
		GameState.rimuovi_classe(scelta["lascia"])
	if scelta.has("ospite"):
		GameState.aggiungi_ospite(scelta["ospite"])
	if scelta.has("recluta_temporaneo"):
		GameState.recluta_temporaneo(scelta["recluta_temporaneo"], int(scelta.get("livello_alleato", 1)))
	if scelta.has("congeda"):
		GameState.congeda(scelta["congeda"])
	if scelta.has("tazo"):
		GameState.modifica_tazo(int(scelta["tazo"]))
	if scelta.has("sblocca_negozio"):
		GameState.sblocca_negozio(scelta["sblocca_negozio"])
	if scelta.has("stress"):
		for id_classe in GameState.party:
			GameState.modifica_stress(id_classe, int(scelta["stress"]))
	if scelta.has("legame"):
		GameState.modifica_legame(int(scelta["legame"]))
	if scelta.has("combatti"):
		GameState.prepara_combattimento(scelta["combatti"], scelta.get("se_vinci", ""),
				scelta.get("se_vinci_eroe", ""), scelta.get("se_perdi", ""), scelta.get("se_fuggi", ""))
		get_tree().change_scene_to_file(SCENA_COMBATTIMENTO)
		return
	if scelta.get("torna_vuoto", false):
		# uscita da uno squarcio: lo stato resta, ma gli alleati temporanei
		# non ti seguono fuori
		GameState.congeda_tutti_temporanei()
		get_tree().change_scene_to_file(SCENA_VUOTO)
		return
	if scelta.get("reset", false):
		GameState.reset_campagna()
		get_tree().change_scene_to_file(SCENA_MAPPA)
		return
	if scelta.has("vai"):
		mostra_nodo(scelta["vai"])

func aggiorna_dialoga() -> void:
	# senza compagni non c'e' nessuno con cui parlare: il bottone sparisce
	bottone_dialoga.visible = GameState.party.size() > 1
	for figlio in menu_compagni.get_children():
		figlio.queue_free()

func _su_dialoga() -> void:
	for figlio in menu_compagni.get_children():
		figlio.queue_free()
	for id_classe in GameState.party:
		if id_classe == GameState.id_protagonista:
			continue
		var bottone := Button.new()
		bottone.text = String(GameState.classi.get(id_classe, {}).get("nome", id_classe))
		bottone.pressed.connect(_su_compagno.bind(id_classe))
		menu_compagni.add_child(bottone)

func _su_compagno(id_classe: String) -> void:
	for figlio in menu_compagni.get_children():
		figlio.queue_free()
	var nome: String = String(GameState.classi.get(id_classe, {}).get("nome", id_classe))
	slot_sinistra.visible = false
	slot_destra.visible = false
	slot_centro.visible = true
	mostra_slot(slot_centro, id_classe, "")
	aggiorna_nome_parlante(id_classe)
	var voce: Dictionary = GameState.dialoghi.get(GameState.nodo_corrente, {})
	var gia_detta: bool = voce.has("una_tantum") and GameState.ha_flag(voce["una_tantum"])
	if voce.is_empty() or gia_detta:
		narratore.append_text("\n\n[i]%s non ha altro da dirti, qui.[/i]" % nome)
		return
	narratore.append_text("\n\n" + (String(voce.get("testo", "")) % nome))
	if voce.has("flag"):
		GameState.imposta_flag(voce["flag"])
	if voce.has("una_tantum"):
		GameState.imposta_flag(voce["una_tantum"])
	# la battuta puo' aver sbloccato una scelta gated da richiede_flag
	ricostruisci_scelte(GameState.eventi.get(GameState.nodo_corrente, {}))

func aggiorna_stato() -> void:
	var nomi: Array[String] = []
	for id_classe in GameState.party:
		nomi.append(String(GameState.classi.get(id_classe, {}).get("nome", id_classe)))
	var testo_party := ", ".join(nomi) if not nomi.is_empty() else "solo tu"
	stato.text = "Party: %s   •   Sacca %d/%d   •   Tazo %d   •   Legame %d" % [
		testo_party, GameState.sacca.size(), int(GameState.regole.get("sacca_massima", 20)),
		GameState.tazo, GameState.legame,
	]
