extends Node

# CARICA OGNI SCRIPT DEL PROGETTO, e basta. Lanciato con --debug, Godot stampa
# gli avvisi di GDScript mentre compila (esegui.sh li cerca e si ferma).
#
# PERCHE' SERVE. Le prove girano senza --debug, e senza --debug gli avvisi non
# si stampano: il verde non li vedeva. L'editor invece li mostra tutti, in
# giallo, appena Bru apre il progetto - e cosi' e' arrivato «la variabile voce
# del ciclo copre la funzione voce() della riga 437», in Pausa.gd, che le prove
# davano per buono da settimane. Quel giorno ce n'erano altri trenta, fra prove
# e strumenti.
#
# Si cammina tutto res:// e non un elenco di cartelle: uno script messo in una
# cartella nuova deve finire qui dentro senza che nessuno se ne ricordi.

func _ready() -> void:
	var caricati := 0
	for percorso in script_sotto("res://"):
		if load(percorso) == null:
			push_error("Avvisi: %s non si carica" % percorso)
		caricati += 1
	print("Avvisi: %d script caricati" % caricati)
	get_tree().quit(0)

func script_sotto(cartella: String) -> Array[String]:
	var trovati: Array[String] = []
	for nome in DirAccess.get_files_at(cartella):
		if nome.ends_with(".gd"):
			trovati.append(cartella.path_join(nome))
	for sotto in DirAccess.get_directories_at(cartella):
		if not sotto.begins_with("."):
			trovati.append_array(script_sotto(cartella.path_join(sotto)))
	return trovati
