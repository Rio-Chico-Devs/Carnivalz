extends Control
# IL BOND, GIRATO DAL GIOCO VERO. Provvisorio come le altre vetrine.
#
# Bru, sulla purificazione lettera per lettera: «si dai mettila». Adesso e'
# nel gioco (scripts/combattimento/LuceBond.gd, docs/vita.md): qui non si
# disegna niente, si media con la Tartaruga in uno scontro vero e si guarda
# cosa succede - la luce, e dopo il racconto della mediazione nel box.
#
#   ./prove/film_bond.sh            lo gira in scatti/proposte_bond/
#   nell'editor: ProposteBond.tscn, F6

const PARTE := 0.6        # quando si media, dentro il film
const DOPO := 2.5         # quanto si guarda ancora, dopo la luce: il racconto
const ASSESTAMENTO := 90

var scena: Node
var tempo := -1.0
var mediato := false


func _ready() -> void:
	GameState.nuova_partita()
	GameState.party = ["anonimo", "veronica"]
	GameState.nemici_combattimento = ["tartaruga_innocente"]
	scena = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scena)
	for i in ASSESTAMENTO:
		await get_tree().process_frame
	# si media a scontro cominciato, come in partita: l'apertura si salta
	while not scena.scontro_avviato:
		scena.voce.coda.clear()
		scena.voce.avanza()
		await get_tree().process_frame
	scena.voce.coda.clear()
	scena.campo.evidenzia(scena.combattenti, scena.combattenti[0])
	scena.menu.principale()
	tempo = 0.0
	print("INIZIO_FILM ", Engine.get_frames_drawn())


func _process(delta: float) -> void:
	if tempo < 0.0:
		return
	tempo += delta
	if not mediato and tempo >= PARTE:
		mediato = true
		media()
	if tempo > PARTE + LuceBond.DURATA + DOPO:
		get_tree().quit()


func media() -> void:
	for combattente: Dictionary in scena.combattenti:
		if not bool(combattente.giocatore):
			combattente.vuole_mediare = true
			combattente.bond_aperto = true
			scena.media(combattente)
			return
