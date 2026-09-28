class_name MacchinaDaScrivere
extends Node

# LA MACCHINA DA SCRIVERE, una sola per tutto il gioco. Stava dentro il box del
# testo; adesso la usa anche il racconto a schermo intero (Racconto.gd), e Bru
# l'ha detto chiaro: «abbiamo gia' il testo con un effetto sonoro ideale, per
# come appare va bene, adesso bisogna farlo anche nelle narrazioni». Quindi e'
# la STESSA, non una copia che al primo ritocco comincia a scrivere diverso.
#
# Non va a velocita' costante: si ferma dove si fermerebbe una voce. Una
# virgola e' un respiro corto, un punto una pausa vera, i puntini di
# sospensione un silenzio. Il testo arriva a pezzi di frase invece che a filo
# continuo - la stessa frase letta ad alta voce. Le durate stanno in
# data/stile.json, sezione "ritmo". Chi la usa puo' rallentarla tutta
# ("passo") e allungarne i respiri ("respiro"): il racconto di una favola va
# piu' piano di una battuta.

signal finita

# Un colpetto di voce ogni tot lettere, mentre scrive. Tre e' il numero che
# suona come parlato: a una lettera diventa una mitragliata, a cinque sembra
# che il personaggio balbetti. Durante i respiri sulla punteggiatura le lettere
# non avanzano, quindi la voce si ferma da sola dove si fermerebbe una vera.
const LETTERE_PER_BLIP := 3

var testo: RichTextLabel = null
var sta_scrivendo := false
var nome := ""                 # chi parla: la voce del blip viene dal nome
var tipo := "narrazione"
var passo := 1.0               # quanto piu' in fretta (>1) o piano (<1) del box
var respiro := 1.0             # quanto piu' lunghe le pause sulla punteggiatura
var tween_testo: Tween
var lettere_al_blip := 0


func _ready() -> void:
	set_process(false)


func scrivi(etichetta: RichTextLabel, chi := "", come := "narrazione") -> void:
	ferma()
	testo = etichetta
	nome = chi
	tipo = come
	lettere_al_blip = 0
	var totale := testo.get_total_character_count()
	var velocita := Stile.caratteri_al_secondo() * Impostazioni.velocita_testo * passo
	if totale <= 0 or velocita <= 0.0:
		testo.visible_ratio = 1.0
		_fine()
		return
	testo.visible_ratio = 0.0
	sta_scrivendo = true
	set_process(true)
	tween_testo = create_tween()
	# un pezzo di tween per ogni pezzo di frase, con in mezzo il respiro
	var scritti := 0
	for pausa_dopo in respiri(testo.get_parsed_text()):
		var fino_a: int = mini(int(pausa_dopo[0]), totale)
		var pausa: float = float(pausa_dopo[1]) * respiro
		if fino_a <= scritti or fino_a >= totale:
			continue
		tween_testo.tween_property(testo, "visible_ratio", float(fino_a) / float(totale),
				float(fino_a - scritti) / velocita)
		if pausa > 0.0:
			# chi ha alzato la velocita' del testo vuole meno attesa anche qui
			tween_testo.tween_interval(pausa / maxf(Impostazioni.velocita_testo, 0.1))
		scritti = fino_a
	if scritti < totale:
		tween_testo.tween_property(testo, "visible_ratio", 1.0,
				float(totale - scritti) / velocita)
	tween_testo.finished.connect(_fine)


static func respiri(grezzo: String) -> Array:
	# [[indice a cui fermarsi, secondi di pausa], ...]. "grezzo" e' il testo
	# senza bbcode: gli indici combaciano con quelli di visible_ratio.
	var punti: Array = []
	var lunghezza := grezzo.length()
	var i := 0
	while i < lunghezza:
		var c := grezzo[i]
		if c == ".":
			# quanti punti di fila: uno e' un punto fermo, tre sono un silenzio
			var fine := i
			while fine < lunghezza and grezzo[fine] == ".":
				fine += 1
			var sospeso := fine - i >= 2
			if c_e_altro_dopo(grezzo, fine):
				punti.append([fine, Stile.ritmo("pausa_sospensione" if sospeso else "pausa_punto")])
			i = fine
			continue
		if c == "!" or c == "?":
			var fine_forte := i
			while fine_forte < lunghezza and (grezzo[fine_forte] == "!" or grezzo[fine_forte] == "?"):
				fine_forte += 1
			if c_e_altro_dopo(grezzo, fine_forte):
				punti.append([fine_forte, Stile.ritmo("pausa_punto")])
			i = fine_forte
			continue
		if c == "," or c == ";" or c == ":":
			if c_e_altro_dopo(grezzo, i + 1):
				punti.append([i + 1, Stile.ritmo("pausa_virgola")])
		i += 1
	return punti


static func c_e_altro_dopo(grezzo: String, da: int) -> bool:
	# non ha senso respirare sull'ultima punteggiatura della frase: il
	# messaggio finisce li' e la pausa la fa gia' il giocatore
	return grezzo.substr(da).strip_edges() != ""


func completa() -> void:
	# chi legge ha fretta: il testo si chiude subito, senza saltare nulla
	if not sta_scrivendo:
		return
	ferma()
	testo.visible_ratio = 1.0
	_fine()


func ferma() -> void:
	if tween_testo != null and tween_testo.is_valid():
		tween_testo.kill()
	sta_scrivendo = false
	set_process(false)


func _process(_delta: float) -> void:
	# quante lettere sono comparse da quando ha suonato l'ultima volta
	if not sta_scrivendo or testo == null or not is_instance_valid(testo):
		set_process(false)
		return
	var scritte := int(testo.visible_ratio * testo.get_total_character_count())
	if scritte - lettere_al_blip < LETTERE_PER_BLIP:
		return
	lettere_al_blip = scritte
	AudioManager.blip(nome, tipo)


func _fine() -> void:
	sta_scrivendo = false
	set_process(false)
	finita.emit()
