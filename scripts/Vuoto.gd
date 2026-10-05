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

const SCENA_SELEZIONE := "res://scenes/Selezione.tscn"
const SCENA_EVENTI := "res://scenes/Main.tscn"
const SCENA_MAPPA := "res://scenes/Mappa.tscn"
const SCALA := 45.0           # i "pos" di mappa.json sono pixel di un vecchio 1280x720
const CENTRO := Vector2(640, 330)

@onready var strato_punti: Control = %Punti
@onready var bottone_mappa: Button = %BottoneMappa

var proiezione: Proiezione
var fratture := {}            # id -> la sua voce in mappa.json
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
	proiezione.titolo_grande = String(punto.get("nome", "Il Vuoto")).to_upper()
	proiezione.sopratitolo = "%s  ·  %d FRATTURE APERTE" % [String(punto.get("sottotitolo", "Il Vuoto")).to_upper(),
			fratture.size()]
	proiezione.confermato.connect(_su_conferma)
	DisegnoProiezione.vesti(bottone_mappa, proiezione.tinte)
	bottone_mappa.pressed.connect(func() -> void:
		Transizioni.vai(SCENA_MAPPA))
	proiezione.risali()
	strappa_le_nuove()


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


func crea_squarcio(vuoto: Dictionary) -> void:
	# ogni frattura orbita dove mappa.json la mette, attorno al centro: piu'
	# lontana piu' lenta, come un pianeta vero
	var id_vuoto := String(vuoto.get("id", ""))
	var stato := GameState.stato_visita(id_vuoto, String(vuoto.get("flag_completato", "")))
	var pos: Array = vuoto.get("pos", [CENTRO.x, CENTRO.y])
	var rel := Vector2(float(pos[0]), float(pos[1])) - CENTRO
	var orbita := clampf(4.6 + (rel.length() / SCALA - 4.0) * 0.62, 4.6, 10.8)
	var grande := String(vuoto.get("pozzo", "")) == "grande"
	var aspetto := String(vuoto.get("aspetto", ""))
	var nuova := bool(vuoto.get("nascosto", false)) and stato == "nuovo"
	fratture[id_vuoto] = vuoto
	if nuova:
		nuove.append(id_vuoto)
	proiezione.aggiungi({"id": id_vuoto, "nome": String(vuoto.get("nome", "?")), "orbita": orbita,
			"angolo": rel.angle(), "vel": CieloProiezione.misura("orbita", 0.11) / sqrt(orbita),
			"profondita": 2.5 if grande else 1.7, "largo": 0.8 if grande else 0.55, "raggio": 0.55 if grande else 0.4,
			"stato": stato, "spento": 0.75 if aspetto == "spento" else 0.0, "respiro": 1.0 if aspetto == "respira" else 0.0,
			"epoca": String(vuoto.get("epoca", "")), "testo": String(vuoto.get("descrizione", "")),
			"azione": "Entra nella frattura", "attiva": String(vuoto.get("file_eventi", "")) != "",
			"apertura": 0.0 if nuova else 1.0})


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


func _su_pianeta() -> void:
	var punto: Dictionary = GameState.punto_mappa_corrente
	if GameState.avvia_carnivalz(punto.get("id", ""), punto.get("file_eventi", "")):
		GameState.musica_ambiente = String(punto.get("musica_campagna", ""))
		Transizioni.vai(SCENA_SELEZIONE)


func _su_squarcio(vuoto: Dictionary) -> void:
	if GameState.entra_squarcio(vuoto.get("id", ""), vuoto.get("file_eventi", "")):
		GameState.musica_ambiente = String(vuoto.get("musica", ""))
		IngressoNodo.vai_al_nodo(GameState.nodo_corrente)
