extends Node

# Autoload audio, data-driven e a prova di file mancanti: finché gli audio
# non esistono in res://audio/, tutto resta silenzioso senza errori.
# - musica di sottofondo in loop (una alla volta), per menu/mappa/Vuoto/
#   frattura/combattimento;
# - versi dei nemici (comparsa e morte) e voci registrate dei boss.
#
# Convenzioni di percorso (sovrascrivibili nei dati):
#   versi:  res://audio/versi/<id>.wav          (comparsa)
#           res://audio/versi/<id>_morte.wav    (morte, opzionale)
#   voci:   res://audio/voci/<id>_<evento>.wav  (inizio/cedimento/sconfitta)
#   musica: .ogg consigliato (loop pulito)

var lettore_musica: AudioStreamPlayer
var lettore_sfx: AudioStreamPlayer
var lettore_voce: AudioStreamPlayer   # i blip: hanno un lettore loro, o taglierebbero i versi
var traccia_corrente: String = ""
var suoni_pronti: Dictionary = {}     # chiave -> AudioStream gia' costruito

func _ready() -> void:
	_assicura_bus("Musica")
	_assicura_bus("Effetti")
	lettore_musica = AudioStreamPlayer.new()
	lettore_musica.bus = "Musica"
	add_child(lettore_musica)
	lettore_sfx = AudioStreamPlayer.new()
	lettore_sfx.bus = "Effetti"
	add_child(lettore_sfx)
	lettore_voce = AudioStreamPlayer.new()
	lettore_voce.bus = "Effetti"
	add_child(lettore_voce)

func _assicura_bus(nome: String) -> void:
	# "Musica" ed "Effetti" sono bus separati (figli di "Master") cosi' le
	# Opzioni possono regolarne il volume indipendentemente; creati al volo
	# se il progetto non li ha ancora (niente file di bus layout da mantenere)
	if AudioServer.get_bus_index(nome) != -1:
		return
	AudioServer.add_bus()
	var indice := AudioServer.bus_count - 1
	AudioServer.set_bus_name(indice, nome)
	AudioServer.set_bus_send(indice, "Master")

# --- musica ---

func musica(percorso: String) -> void:
	if percorso == traccia_corrente and lettore_musica.playing:
		return  # già in riproduzione: non riavviare passando tra le scene
	traccia_corrente = percorso
	if percorso == "" or not ResourceLoader.exists(percorso):
		lettore_musica.stop()
		return
	var stream: AudioStream = load(percorso)
	_imposta_loop(stream)
	lettore_musica.stream = stream
	lettore_musica.play()

func musica_chiave(chiave: String) -> void:
	musica(String(GameState.audio.get("musica", {}).get(chiave, "")))

func _imposta_loop(stream: AudioStream) -> void:
	# loop robusto sia per .ogg che per .wav
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif "loop" in stream:
		stream.set("loop", true)

# --- effetti (versi, voci) ---

func sfx(percorso: String) -> void:
	if percorso == "" or not ResourceLoader.exists(percorso):
		return
	lettore_sfx.stream = load(percorso)
	lettore_sfx.play()

func verso(id_personaggio: String, dati: Dictionary, momento: String) -> void:
	# momento: "comparsa" | "morte"
	var percorso := ""
	if momento == "morte":
		percorso = String(dati.get("morte", ""))
		if percorso == "":
			var conv := "res://audio/versi/%s_morte.wav" % id_personaggio
			percorso = conv if ResourceLoader.exists(conv) else ""
		if percorso == "":  # nessun verso di morte dedicato: riusa il growl
			percorso = _growl(id_personaggio, dati)
	else:
		percorso = _growl(id_personaggio, dati)
	sfx(percorso)

func _growl(id_personaggio: String, dati: Dictionary) -> String:
	var esplicito := String(dati.get("growl", ""))
	return esplicito if esplicito != "" else "res://audio/versi/%s.wav" % id_personaggio

func voce_boss(id_personaggio: String, dati: Dictionary, evento: String) -> void:
	# evento: "inizio" | "cedimento" | "sconfitta"
	var voci: Dictionary = dati.get("voci", {})
	var percorso := String(voci.get(evento, ""))
	if percorso == "":
		percorso = "res://audio/voci/%s_%s.wav" % [id_personaggio, evento]
	sfx(percorso)

# --- suoni costruiti al volo (vedi Sintesi.gd) ---
#
# Il gioco non ha nessun file audio. Restare muti pero' non e' neutrale: un
# testo che scorre in silenzio non sembra "in attesa dell'audio", sembra morto.
# Questi suoni li costruiamo campione per campione all'avvio, costano niente, e
# si fanno da parte da soli: se il .wav corrispondente esiste, vince lui.

func _suono(chiave: String, percorso_vero: String, costruisci: Callable) -> AudioStream:
	if suoni_pronti.has(chiave):
		return suoni_pronti[chiave]
	var suono: AudioStream
	if percorso_vero != "" and ResourceLoader.exists(percorso_vero):
		suono = load(percorso_vero)   # il file vero di Bru ha sempre la precedenza
	else:
		suono = costruisci.call()
	suoni_pronti[chiave] = suono
	return suono

func interfaccia(nome: String) -> void:
	# conferma, annulla, colpo, cura, raccolta, errore. Sostituibili copiando un
	# file in res://audio/ui/<nome>.wav: non c'e' niente da ricablare
	var suono := _suono("ui:" + nome, "res://audio/ui/%s.wav" % nome,
			func() -> AudioStream: return Sintesi.interfaccia(nome))
	lettore_sfx.stream = suono
	lettore_sfx.play()

func blip(nome_parlante: String, tipo := "dialogo") -> void:
	# Un colpetto di voce per gruppo di lettere, mentre la macchina da scrivere
	# scrive. E' il trucco piu' vecchio del mondo (Undertale, Animal Crossing,
	# Banjo) e resta il modo piu' economico che esista per far sembrare parlato
	# un testo scritto.
	#
	# L'altezza e la forma d'onda vengono dal NOME di chi parla: due personaggi
	# suonano sempre diversi, lo stesso personaggio sempre uguale. Chi vuole
	# scegliersela la mette nei dati sotto "voce": {"altezza": 320, "forma": "sega"}.
	if tipo != "dialogo" or nome_parlante.strip_edges() == "":
		# narrazione e notifiche non hanno una bocca: voce neutra, piu' bassa
		lettore_voce.stream = _suono("blip:", "", func() -> AudioStream: return Sintesi.blip_narrazione())
	else:
		var dati_voce: Dictionary = _voce_di(nome_parlante)
		lettore_voce.stream = _suono("blip:" + nome_parlante, "",
				func() -> AudioStream: return Sintesi.blip(nome_parlante, dati_voce))
	lettore_voce.play()

func _voce_di(nome_parlante: String) -> Dictionary:
	# la targhetta porta il nome visualizzato, non l'id: si cerca per nome
	for dati in GameState.personaggi.values():
		if dati is Dictionary and String(dati.get("nome", "")) == nome_parlante:
			return dati.get("voce", {})
	return {}
