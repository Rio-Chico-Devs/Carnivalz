extends Control

# I negozi (data/negozi.json). Mostra solo quelli sbloccati, lo stock evolve
# con le fonti estinte (campo da_fonti) e l'Artigiano baratta materiali.
#
# COME SI COMPRA. Prima era un elenco piatto di righe uguali: nome, descrizione
# poetica, prezzo. Per decidere dovevi gia' sapere cosa fa un oggetto e cosa hai
# in tasca. Ora ogni riga risponde da sola alle tre domande che uno si fa
# davanti a uno scaffale:
#
#   che cosa fa      -> l'effetto in numeri ("+8 vita", "difesa +1"), non solo
#                       la descrizione. La poesia resta, ma sotto
#   ne ho gia'       -> quanti ne hai in sacca, o chi lo porta addosso se e'
#                       roba da indossare. Comprare il secondo amuleto uguale
#                       deve essere una scelta, non una distrazione
#   me lo posso      -> il prezzo, e quanti Tazo ti restano dopo. Se non puoi,
#   permettere          il bottone e' spento e si vede quanto ti manca
#
# E lo scaffale e' diviso per mestiere (usare adesso / imbracciare / indossare):
# tre categorie tra cui scegliere, non quindici righe tutte uguali da leggere.

const SCENA_MAPPA := "res://scenes/Mappa.tscn"

# l'ordine conta: prima quello che serve adesso, poi quello che serve dopo
const CATEGORIE := [
	{
		"tipi": ["consumabile"],
		"titolo": "Da usare in combattimento",
		"nota": "Si consumano. Occupano posto nella sacca.",
	},
	{
		"tipi": ["arma", "stigma"],
		"titolo": "Armi e stigmi",
		"nota": "Uno per personaggio. Uno stigma è un patto: dà e toglie.",
	},
	{
		"tipi": ["accessorio"],
		"titolo": "Accessori",
		"nota": "Fino a quattro per personaggio. Piccoli aggiustamenti che si sommano.",
	},
]

@onready var etichetta_tazo: Label = %Tazo
@onready var lista: VBoxContainer = %Lista
@onready var bottone_mappa: Button = %BottoneMappa

func _ready() -> void:
	bottone_mappa.pressed.connect(_su_mappa)
	costruisci()

func costruisci() -> void:
	etichetta_tazo.text = "Tazo: %d   •   Sacca %d/%d" % [
		GameState.tazo, GameState.sacca.size(), int(GameState.regole.get("sacca_massima", 20))]
	for figlio in lista.get_children():
		figlio.queue_free()
	for id_negozio in GameState.negozi_sbloccati:
		var negozio: Dictionary = GameState.negozi.get(id_negozio, {})
		if negozio.is_empty():
			continue
		aggiungi_intestazione(negozio)
		var in_vendita := stock_disponibile(negozio)
		for categoria in CATEGORIE:
			var voci := filtra_per_tipo(in_vendita, categoria["tipi"])
			if voci.is_empty():
				continue
			aggiungi_categoria(String(categoria["titolo"]), String(categoria["nota"]))
			for voce in voci:
				aggiungi_voce_vendita(voce)
		var baratti: Array = negozio.get("baratti", [])
		if not baratti.is_empty():
			aggiungi_categoria("Baratti", "Lui non vende: lavora quello che gli porti.")
			for baratto in baratti:
				aggiungi_voce_baratto(baratto)

func stock_disponibile(negozio: Dictionary) -> Array:
	var voci: Array = []
	for voce in negozio.get("stock", []):
		if int(voce.get("da_fonti", 0)) > GameState.fonti_estinte:
			continue  # lo stock evolve man mano che estingui fonti
		voci.append(voce)
	return voci

func filtra_per_tipo(voci: Array, tipi: Array) -> Array:
	var risultato: Array = []
	for voce in voci:
		var dati := GameState.dati_oggetto(String(voce.get("oggetto", "")))
		if String(dati.get("tipo", "consumabile")) in tipi:
			risultato.append(voce)
	return risultato

func aggiungi_intestazione(negozio: Dictionary) -> void:
	var titolo := Label.new()
	titolo.text = String(negozio.get("nome", "?"))
	titolo.add_theme_font_size_override("font_size", Stile.dimensione("sezione"))
	titolo.add_theme_color_override("font_color", Stile.colore("accento"))
	lista.add_child(titolo)
	var descrizione := Label.new()
	descrizione.text = String(negozio.get("descrizione", ""))
	descrizione.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Stile.etichetta_piccola(descrizione)
	lista.add_child(descrizione)

func aggiungi_categoria(titolo_categoria: String, nota: String) -> void:
	var spazio := Control.new()
	spazio.custom_minimum_size = Vector2(0, 10)
	lista.add_child(spazio)
	var titolo := Label.new()
	titolo.text = titolo_categoria
	titolo.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	titolo.add_theme_color_override("font_color", Stile.colore("bordo_acceso"))
	lista.add_child(titolo)
	var sottotitolo := Label.new()
	sottotitolo.text = nota
	sottotitolo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Stile.etichetta_piccola(sottotitolo)
	lista.add_child(sottotitolo)

func aggiungi_voce_vendita(voce: Dictionary) -> void:
	var id_oggetto := String(voce.get("oggetto", ""))
	var oggetto := GameState.dati_oggetto(id_oggetto)
	var prezzo := int(voce.get("prezzo", 0))
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 16)
	lista.add_child(riga)

	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 2)
	colonna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(colonna)

	var nome := Label.new()
	nome.text = String(oggetto.get("nome", id_oggetto))
	nome.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	colonna.add_child(nome)

	# cosa fa, in numeri: e' l'informazione che serve davvero a decidere
	var effetto := Label.new()
	effetto.text = riassunto_effetto(oggetto)
	effetto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effetto.add_theme_color_override("font_color", Stile.colore("positivo"))
	effetto.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
	colonna.add_child(effetto)

	var descrizione := Label.new()
	descrizione.text = String(oggetto.get("descrizione", ""))
	descrizione.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Stile.etichetta_piccola(descrizione)
	colonna.add_child(descrizione)

	var gia := quanti_ne_hai(id_oggetto)
	if gia != "":
		var posseduto := Label.new()
		posseduto.text = gia
		posseduto.add_theme_color_override("font_color", Stile.colore("accento"))
		posseduto.add_theme_font_size_override("font_size", Stile.dimensione("piccolo"))
		colonna.add_child(posseduto)

	var lato := VBoxContainer.new()
	lato.add_theme_constant_override("separation", 2)
	lato.custom_minimum_size = Vector2(190, 0)
	riga.add_child(lato)
	var sacca_piena := String(oggetto.get("tipo", "consumabile")) == "consumabile" \
			and GameState.sacca.size() >= int(GameState.regole.get("sacca_massima", 20))
	var bottone := Button.new()
	bottone.text = "Compra — %d Tazo" % prezzo
	bottone.disabled = GameState.tazo < prezzo or sacca_piena
	bottone.pressed.connect(func() -> void:
		if GameState.compra(id_oggetto, prezzo):
			costruisci())
	lato.add_child(bottone)
	var conto := Label.new()
	if sacca_piena:
		conto.text = "la sacca è piena"
	elif GameState.tazo < prezzo:
		conto.text = "ti mancano %d Tazo" % (prezzo - GameState.tazo)
	else:
		conto.text = "te ne restano %d" % (GameState.tazo - prezzo)
	conto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Stile.etichetta_piccola(conto)
	lato.add_child(conto)

func quanti_ne_hai(id_oggetto: String) -> String:
	# comprare il secondo uguale dev'essere una scelta, non una distrazione
	var tipo := String(GameState.dati_oggetto(id_oggetto).get("tipo", "consumabile"))
	if tipo == "consumabile":
		var quanti := 0
		for x in GameState.sacca:
			if String(x) == id_oggetto:
				quanti += 1
		return "" if quanti == 0 else "ne hai già %d in sacca" % quanti
	if not GameState.posseduto_equipaggiabile(id_oggetto):
		return ""
	var id_portatore := GameState.portatore_di(id_oggetto)
	if id_portatore == "":
		return "ne hai già uno, nell'armadio"
	var classe: Dictionary = GameState.classi.get(id_portatore, {})
	return "ne hai già uno, addosso a %s" % String(classe.get("nome", id_portatore))

func riassunto_effetto(oggetto: Dictionary) -> String:
	# l'effetto in numeri. Le chiavi sono le stesse che legge il combattimento,
	# quindi un oggetto nuovo si racconta da solo senza toccare questo file
	var effetto: Dictionary = oggetto.get("effetto_equipaggiato", oggetto.get("effetto", {}))
	var voci: Array[String] = []
	for chiave in effetto:
		var nome_chiave := String(chiave)
		match nome_chiave:
			"tipo":
				continue
			"hp":
				voci.append("%+d vita" % int(effetto[chiave]))
			"aura":
				voci.append("%+d aura" % int(effetto[chiave]))
			"stress":
				voci.append("stress %+d" % int(effetto[chiave]))
			"danno":
				voci.append("%d danni, ignora le difese" % int(effetto[chiave]))
			"speranza":
				voci.append("speranza %+d" % int(effetto[chiave]))
			"difesa_incontro":
				voci.append("difesa %+d per tutto lo scontro" % int(effetto[chiave]))
			"cura_stato":
				var definizione: Dictionary = GameState.stati.get(effetto[chiave], {})
				voci.append("toglie %s" % String(definizione.get("nome", effetto[chiave])).to_lower())
			"cura_stati":
				voci.append("toglie ogni male")
			"attacco":
				voci.append("attacco %+d" % int(effetto[chiave]))
			"difesa":
				voci.append("difesa %+d" % int(effetto[chiave]))
			"velocita":
				voci.append("velocità %+d" % int(effetto[chiave]))
			"hp_max":
				voci.append("vita massima %+d" % int(effetto[chiave]))
			"aura_max":
				voci.append("aura massima %+d" % int(effetto[chiave]))
			"aura_per_turno":
				voci.append("aura per turno %+d" % int(effetto[chiave]))
			"resistenza_maledizione":
				voci.append("maledizione: %+d rintocchi prima della fine" % int(effetto[chiave]))
			_:
				voci.append("%s %+d" % [nome_chiave, int(effetto[chiave])])
	match String(effetto.get("tipo", "")):
		"scudo_primo_stato":
			voci.append("respinge il primo male che ti prende")
		"resurrezione_dimezzata":
			voci.append("ti rimette in piedi una volta, a metà vita")
	return ", ".join(voci) if not voci.is_empty() else "—"

func aggiungi_voce_baratto(baratto: Dictionary) -> void:
	var richiesti: Array = baratto.get("richiede", [])
	var prodotto := String(baratto.get("produce", ""))
	var nomi_materiali: Array[String] = []
	var mancanti: Array[String] = []
	# un materiale richiesto due volte va posseduto due volte: si scala la copia
	var disponibili: Array = GameState.collezionabili.duplicate()
	for materiale in richiesti:
		var id_materiale := String(materiale)
		var nome_materiale := String(GameState.dati_oggetto(id_materiale).get("nome", id_materiale))
		nomi_materiali.append(nome_materiale)
		if id_materiale in disponibili:
			disponibili.erase(id_materiale)
		elif nome_materiale not in mancanti:
			mancanti.append(nome_materiale)
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 16)
	lista.add_child(riga)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 2)
	colonna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(colonna)
	var nome := Label.new()
	nome.text = String(GameState.dati_oggetto(prodotto).get("nome", prodotto))
	nome.add_theme_font_size_override("font_size", Stile.dimensione("nome"))
	colonna.add_child(nome)
	var costo := Label.new()
	costo.text = "in cambio di: " + ", ".join(nomi_materiali)
	costo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Stile.etichetta_piccola(costo)
	colonna.add_child(costo)
	var lato := VBoxContainer.new()
	lato.add_theme_constant_override("separation", 2)
	lato.custom_minimum_size = Vector2(190, 0)
	riga.add_child(lato)
	var bottone := Button.new()
	bottone.text = "Baratta"
	bottone.disabled = not mancanti.is_empty()
	bottone.pressed.connect(func() -> void:
		if GameState.baratta(richiesti, prodotto):
			costruisci())
	lato.add_child(bottone)
	if not mancanti.is_empty():
		var manca := Label.new()
		manca.text = "ti manca: " + ", ".join(mancanti)
		manca.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		Stile.etichetta_piccola(manca)
		lato.add_child(manca)

func _su_mappa() -> void:
	Transizioni.vai(SCENA_MAPPA)
