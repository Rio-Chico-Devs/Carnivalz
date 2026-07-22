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
var traccia_corrente: String = ""

func _ready() -> void:
	lettore_musica = AudioStreamPlayer.new()
	lettore_musica.bus = "Master"
	add_child(lettore_musica)
	lettore_sfx = AudioStreamPlayer.new()
	lettore_sfx.bus = "Master"
	add_child(lettore_sfx)

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
