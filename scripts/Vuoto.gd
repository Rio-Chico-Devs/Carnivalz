extends Control

# IL VUOTO: il sistema deformato intorno al pianeta del Carnivalz (storia.md,
# «Il Vuoto»). Al centro il pozzo piu' profondo e il suo pianeta, l'anomalia:
# la campagna principale, che si apre solo quando le fratture richieste sono
# state percorse - prima e' li', si vede, e la scheda dice cosa manca.
# Intorno, in orbita, le fratture (mappa.json, "vuoti" del punto), ognuna nel
# suo pozzo. Il disegno e i gesti sono in Proiezione.gd: qui le regole.
#
# Le fratture nascoste compaiono con gli oggetti o le flag giuste; finche' non
# ci entri, ogni volta che apri il Vuoto si strappano nella griglia davanti a
# te: sono la novita', e devono farsi vedere.
#
# Solo i Carnivalz sono pianeti; le fratture sono distorsioni (Proiezione,
# "forma"). Intorno girano anche i PIANETI DELLE RISORSE ("pianeti" del
# punto). Bru: «metteremo dei pianeti intorno a ogni vuoto, che sono
# visitabili per acquisire nuove risorse tramite videogiochi, potrei trovarci
# collezionabili, oggetti, minerali, tazo e risorse per l'organizzazione».
# Un pianeta col suo "file_eventi" si esplora come si entra in una frattura;
# senza, la scheda dice che arrivera'. E nel vuoto fra le orbite ci sono i
# segreti, che si trovano col cursore (SegretiVuoto).

const SCENA_SELEZIONE := "res://scenes/Selezione.tscn"
const SCENA_EVENTI := "res://scenes/Main.tscn"
const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCALA := 45.0           # i "pos" di mappa.json sono pixel di un vecchio 1280x720
const CENTRO := Vector2(640, 330)
const RISORSE := {"collezionabili": "COLLEZIONABILI", "oggetti": "OGGETTI", "minerali": "MINERALI",
		"tazo": "TAZO", "organizzazione": "PER L'ORGANIZZAZIONE"}

@onready var strato_punti: Control = %Punti
@onready var bottone_mappa: Button = %BottoneMappa

var proiezione: Proiezione
var fratture := {}            # id -> la sua voce in mappa.json
var pianeti := {}             # id -> la sua voce in mappa.json ("pianeti" del punto)
var segreti: SegretiVuoto
var nuove: Array[String] = []  # le nascoste appena comparse: si strappano entrando
var partendo := false


func _ready() -> void:
	var punto: Dictionary = GameState.punto_mappa_corrente
	AudioManager.musica(String(punto.get("musica", "")))
	proiezione = Proiezione.new()
	proiezione.livello = "vuoto"
	proiezione.strato = strato_punti
	proiezione.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(proiezione)
	move_child(proiezione, 0)
	proiezione.intestazione = "CARNIVALZ  ·  SALA OPERATIVA  ·  IL VUOTO"
	proiezione.nota_destra = "TAZO %d" % GameState.tazo
	var percorso_sfondo := String(punto.get("sfondo", ""))
	if percorso_sfondo != "" and ResourceLoader.exists(percorso_sfondo):
		proiezione.immagine_di_fondo(load(percorso_sfondo))
	crea_pianeta(punto)
	for vuoto: Dictionary in punto.get("vuoti", []):
		if vuoto_visibile(vuoto):
			crea_squarcio(vuoto)
	for pianeta: Dictionary in punto.get("pianeti", []):
		if vuoto_visibile(pianeta):
			crea_pianeta_delle_risorse(pianeta)
	crea_segreti(punto.get("segreti", []))
	proiezione.titolo_grande = String(punto.get("nome", "Il Vuoto")).to_upper()
	proiezione.sopratitolo = "%s  ·  %d FRATTURE APERTE" % [String(punto.get("sottotitolo", "Il Vuoto")).to_upper(),
			fratture.size()]
	proiezione.confermato.connect(_su_conferma)
	DisegnoProiezione.vesti(bottone_mappa, proiezione.tinte)
	bottone_mappa.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_MAPPA))
	proiezione.risali("anomalia")
	strappa_le_nuove()
	IconaMenu.metti(self)


func pianeta_accessibile(punto: Dictionary) -> bool:
	# il Carnivalz vero e proprio al centro del sistema non e' aperto da
	# subito: si apre solo quando le fratture richieste sono state percorse
	for nome_flag in punto.get("pianeta_richiede_flags", []):
		if not GameState.ha_flag(nome_flag):
			return false
	return true


func crea_pianeta(punto: Dictionary) -> void:
	var aperto := pianeta_accessibile(punto)
	var anomalia: Dictionary = punto.get("anomalia", {})
	var centro := proiezione.aggiungi({"id": "anomalia", "nome": String(anomalia.get("nome", "L'anomalia")),
			"tipo": "centro", "xz": Vector2.ZERO, "profondita": 5.2, "largo": 1.7, "raggio": 1.35, "bande": 1.0,
			"stato": "aperto" if aperto else "sigillato", "epoca": String(anomalia.get("epoca", "")),
			"testo": String(anomalia.get("descrizione" if aperto else "sigillata", "")),
			"azione": "Scendi verso l'anomalia" if aperto else "Sigillata", "attiva": aperto})
	proiezione.aggiungi_anello(centro, 5.6, Vector3(-74, 0, 16))


static func nel_vuoto(pos: Variant, vicino := 4.6, lontano := 10.8) -> Vector2:
	# i "pos" di mappa.json sono pixel di un vecchio 1280x720 intorno a
	# CENTRO: diventano un raggio d'orbita (x) e un angolo (y)
	var p: Array = pos if pos is Array and (pos as Array).size() >= 2 else [CENTRO.x, CENTRO.y]
	var rel := Vector2(float(p[0]), float(p[1])) - CENTRO
	return Vector2(clampf(4.6 + (rel.length() / SCALA - 4.0) * 0.62, vicino, lontano), rel.angle())


func crea_squarcio(vuoto: Dictionary) -> void:
	# ogni frattura orbita dove mappa.json la mette, attorno al centro: piu'
	# lontana piu' lenta, come un pianeta vero
	var id_vuoto := String(vuoto.get("id", ""))
	var stato := GameState.stato_visita(id_vuoto, String(vuoto.get("flag_completato", "")))
	var giro := nel_vuoto(vuoto.get("pos"))
	var orbita := giro.x
	var grande := String(vuoto.get("pozzo", "")) == "grande"
	var aspetto := String(vuoto.get("aspetto", ""))
	var nuova := bool(vuoto.get("nascosto", false)) and stato == "nuovo"
	fratture[id_vuoto] = vuoto
	if nuova:
		nuove.append(id_vuoto)
	proiezione.aggiungi({"id": id_vuoto, "nome": String(vuoto.get("nome", "?")), "orbita": orbita,
			"angolo": giro.y, "vel": CieloProiezione.misura("orbita", 0.11) / sqrt(orbita),
			"profondita": 2.5 if grande else 1.7, "largo": 0.8 if grande else 0.55, "raggio": 0.55 if grande else 0.4,
			"stato": stato, "spento": 0.75 if aspetto == "spento" else 0.0, "respiro": 1.0 if aspetto == "respira" else 0.0,
			"epoca": String(vuoto.get("epoca", "")), "testo": String(vuoto.get("descrizione", "")),
			"azione": "Entra nella frattura", "attiva": String(vuoto.get("file_eventi", "")) != "",
			"apertura": 0.0 if nuova else 1.0, "forma": "lente"})


func crea_pianeta_delle_risorse(pianeta: Dictionary) -> void:
	# un pianeta vero, a retino come i Carnivalz ma piccolo e col pozzo appena
	# accennato; la scheda dice cosa ci si trova
	var id := String(pianeta.get("id", ""))
	var giro := nel_vuoto(pianeta.get("pos"), 4.6, 12.0)
	var gioco := String(pianeta.get("file_eventi", ""))
	var risorse := PackedStringArray()
	for chiave in pianeta.get("risorse", []):
		risorse.append(String(RISORSE.get(chiave, String(chiave).to_upper())))
	pianeti[id] = pianeta
	proiezione.aggiungi({"id": id, "nome": String(pianeta.get("nome", "?")), "tipo": "pianeta",
			"orbita": giro.x, "angolo": giro.y, "vel": CieloProiezione.misura("orbita", 0.11) / sqrt(giro.x),
			"profondita": 0.9, "largo": 0.45, "raggio": 0.32, "bande": 0.5,
			"stato": GameState.stato_visita(id, String(pianeta.get("flag_completato", ""))),
			"epoca": String(pianeta.get("epoca", "")), "testo": String(pianeta.get("descrizione", "")),
			"azione": "Esplora il pianeta" if gioco != "" else "Esplorazione in arrivo", "attiva": gioco != "",
			"dati": [["RISORSE", " · ".join(risorse)]]})


func crea_segreti(voci: Array) -> void:
	segreti = SegretiVuoto.new()
	segreti.prepara(proiezione)
	for voce: Dictionary in voci:
		var giro := nel_vuoto(voce.get("pos"), 2.5, 13.0)
		segreti.nascondi(voce, Vector2.RIGHT.rotated(giro.y) * giro.x)
	# sopra la griglia e le lenti, sotto le scritte
	proiezione.add_child(segreti)
	proiezione.move_child(segreti, proiezione.sopra.get_index())
	segreti.preso.connect(func(_id: String) -> void: proiezione.nota_destra = "TAZO %d" % GameState.tazo)


func strappa_le_nuove() -> void:
	# prima la camera risale e si assesta, poi le fratture nuove si aprono una alla volta
	for id in nuove:
		var attesa := create_tween()
		attesa.tween_interval(0.0 if Movimento.ridotto() else 1.6)
		await attesa.finished
		proiezione.apri_frattura(id)


func vuoto_visibile(vuoto: Dictionary) -> bool:
	if not vuoto.get("nascosto", false):
		return true
	for id_oggetto in vuoto.get("richiede_oggetti", []):
		if not GameState.possiede_oggetto(id_oggetto):
			return false
	# richiede_flags: tutte le quest indicate devono essere completate
	for nome_flag in vuoto.get("richiede_flags", []):
		if not GameState.ha_flag(nome_flag):
			return false
	return true


func _su_conferma(id: String) -> void:
	if partendo:
		return
	if id == "anomalia":
		partendo = true
		_su_pianeta()
	elif fratture.has(id):
		partendo = true
		_su_squarcio(fratture[id])
	elif pianeti.has(id):
		partendo = true
		_su_squarcio(pianeti[id])
	elif segreti.trovati.has(id):
		segreti.prendi(id)


func _su_pianeta() -> void:
	var punto: Dictionary = GameState.punto_mappa_corrente
	if GameState.avvia_carnivalz(punto.get("id", ""), punto.get("file_eventi", "")):
		GameState.musica_ambiente = String(punto.get("musica_campagna", ""))
		Transizioni.vai(SCENA_SELEZIONE)


func _su_squarcio(vuoto: Dictionary) -> void:
	if GameState.entra_squarcio(vuoto.get("id", ""), vuoto.get("file_eventi", "")):
		GameState.musica_ambiente = String(vuoto.get("musica", ""))
		IngressoNodo.vai_al_nodo(GameState.nodo_corrente)
