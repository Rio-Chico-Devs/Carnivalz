extends Node

# SCRIVE SU DISCO I SUONI SINTETIZZATI, per poterli ascoltare.
#
# Lo stesso mestiere di prove/scatto.sh, ma per le orecchie: le prove possono
# misurare che un suono esista e sia lungo quanto deve, non che SUONI come
# deve. Questo li tira fuori in .wav e poi si sente.
#
#   ./prove/ascolta.sh          -> tutti
#   ./prove/ascolta.sh vetro    -> uno solo

const CARTELLA := "res://scatti/audio/"
const TUTTI := ["conferma", "annulla", "colpo", "cura", "raccolta", "errore", "allarme", "vetro"]

func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	var quali: Array = [String(argomenti[0])] if argomenti.size() > 0 else TUTTI
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARTELLA))
	for nome in quali:
		var suono: AudioStreamWAV = Sintesi.interfaccia(String(nome))
		var percorso := ProjectSettings.globalize_path("%s%s.wav" % [CARTELLA, nome])
		suono.save_to_wav(percorso)
		print("%-10s %5.2fs  %s" % [nome, suono.get_length(), percorso])
	get_tree().quit()
