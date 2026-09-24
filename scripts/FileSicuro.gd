class_name FileSicuro
extends RefCounted

# SCRIVERE UNA PARTITA SENZA POTERLA ROVINARE.
#
# Prima si scriveva cosi': FileAccess.open(WRITE), store_string, close. Ma
# aprire in scrittura AZZERA il file subito - «If the file exists, it is
# truncated to zero length» (doc/classes/FileAccess.xml, Godot 4.7) - e il
# testo arriva dopo. Se il gioco si chiude in mezzo (un crash, la corrente, il
# portatile che si spegne) resta un file vuoto o a meta': la partita non c'e'
# piu', e nel menu la slot diventava «Anonimo, livello 1» che premuta scuoteva
# la testa senza dire perche'. E l'esito di store_string, che dalla 4.4 dice se
# la scrittura e' riuscita, non lo guardava nessuno: un disco pieno salvava
# «per finta».
#
# TRE COSE, tutte e tre prese dal motore e non inventate:
#
# 1. SI SCRIVE ACCANTO E SI SCAMBIA. OS.set_use_file_access_save_and_swap fa
#    scrivere su un file temporaneo nella stessa cartella e lo mette al posto
#    del vero solo alla chiusura: rename() su Linux e macOS, ReplaceFileW su
#    Windows, ritentato fino a mille volte se un antivirus tiene il file
#    (drivers/unix/file_access_unix.cpp e drivers/windows/file_access_windows.cpp,
#    4.7). Finche' lo scambio non e' fatto, il file vecchio e' intatto.
# 2. SI CONTROLLA. store_string restituisce se e' riuscita, e dopo la chiusura
#    si rilegge: se non e' identico a quello che si voleva scrivere, non si
#    dice «salvato».
# 3. SI TIENE LA RISERVA. Prima di scrivere, la versione buona di adesso si
#    copia accanto (.riserva). Se un giorno il file principale non si legge -
#    per qualunque motivo, anche non nostro - si riprende quella: si perde un
#    salvataggio, non la partita.

const RISERVA := ".riserva"


static func scrivi(percorso: String, testo: String) -> bool:
	if leggi_dizionario_da(percorso) != null:
		DirAccess.copy_absolute(vero(percorso), vero(percorso + RISERVA))
	OS.set_use_file_access_save_and_swap(true)
	var file := FileAccess.open(percorso, FileAccess.WRITE)
	var scritto := file != null and file.store_string(testo)
	if file != null:
		file.close()
	OS.set_use_file_access_save_and_swap(false)
	return scritto and FileAccess.get_file_as_string(percorso) == testo


static func esiste(percorso: String) -> bool:
	return FileAccess.file_exists(percorso) or FileAccess.file_exists(percorso + RISERVA)


static func leggi_dizionario(percorso: String) -> Variant:
	# il contenuto del file, o della sua riserva se il file non si legge;
	# null se non si legge nessuno dei due
	var buono: Variant = leggi_dizionario_da(percorso)
	if buono == null:
		buono = leggi_dizionario_da(percorso + RISERVA)
		if buono != null:
			push_warning("%s non si legge: ripresa la copia di riserva" % percorso)
	return buono


static func leggi_dizionario_da(percorso: String) -> Variant:
	if not FileAccess.file_exists(percorso):
		return null
	# JSON.parse_string, su un file rovinato, grida un errore del motore; qui un
	# file rovinato e' un caso previsto, e si risponde con la riserva
	var lettore := JSON.new()
	if lettore.parse(FileAccess.get_file_as_string(percorso)) != OK:
		return null
	return lettore.data if lettore.data is Dictionary else null


static func cancella(percorso: String) -> void:
	for quale in [percorso, percorso + RISERVA]:
		if FileAccess.file_exists(quale):
			DirAccess.remove_absolute(vero(quale))


static func vero(percorso: String) -> String:
	return ProjectSettings.globalize_path(percorso)


static func interi(valore: Variant) -> Variant:
	# UN INTERO SALVATO TORNA INTERO.
	#
	# JSON non distingue gli interi dai float, e Godot lo dice: «converting a
	# Variant to JSON text will convert all numerical values to [float] types»
	# (JSON.stringify, doc/classes/JSON.xml, Godot 4.7). Quindi una partita
	# salvata con il livello 3 si ricarica col livello 3.0. Il codice di oggi
	# regge, perche' legge quei numeri passando da int(); ma dentro a un array o
	# a un dizionario il tipo conta, e l'ho misurato sul motore: [3, 2] == [3.0,
	# 2.0] e' falso, {"a": 5} == {"a": 5.0} e' falso, un 5.0 non entra in
	# «match 5», non si trova fra le chiavi intere di un dizionario, e str() lo
	# scrive «5.0». Tutto questo succederebbe solo DOPO un caricamento - cioe'
	# proprio dove una prova che gioca da zero non guarda.
	#
	# Qui si rimette il tipo che aveva: un numero senza parte decimale torna
	# intero, fino a 2^53, oltre il quale un float non e' piu' esatto. Il
	# salvataggio della partita contiene solo interi; le impostazioni, che hanno
	# float veri (il volume, la velocita' del testo), non passano di qui.
	if valore is Dictionary:
		var dizionario := {}
		for chiave in valore:
			dizionario[chiave] = interi(valore[chiave])
		return dizionario
	if valore is Array:
		var elenco := []
		for elemento in valore:
			elenco.append(interi(elemento))
		return elenco
	if typeof(valore) == TYPE_FLOAT and is_finite(valore) and valore == floorf(valore) \
			and absf(valore) < 9007199254740992.0:
		return int(valore)
	return valore
