class_name Albero
extends RefCounted

# SVUOTARE UN CONTENITORE, PER DAVVERO.
#
# `queue_free()` non libera adesso: mette in coda, e libera a fine fotogramma.
# Finche' non succede, i figli vecchi SONO ANCORA FIGLI - stanno nell'albero,
# contano in get_child_count(), e un contenitore li dispone insieme a quelli
# nuovi.
#
# Quasi sempre non si vede, perche' dura un fotogramma. Ma:
#
#   - chi svuota E RIEMPIE nella stessa chiamata - le scelte della storia, i
#     bottoni della mappa, le voci del negozio - per un fotogramma ne ha il
#     doppio, e il contenitore li mette in fila tutti;
#   - chi CONTA i figli subito dopo (una prova, un conto di righe, una misura
#     di quanto e' alto un pannello) legge il numero vecchio;
#   - chi cerca il primo figlio per dargli il fuoco da tastiera puo' trovarne
#     uno che sta morendo, e il fuoco finisce su un bottone che tra un istante
#     non c'e' piu'.
#
# Nel menu di combattimento questo difetto l'avevamo gia' trovato e corretto a
# mano, in un posto solo. Erano dieci. Adesso la versione giusta sta qui.

static func svuota(nodo: Node) -> void:
	# tolto SUBITO dall'albero, e POI messo in coda per la distruzione: dopo
	# questa riga get_child_count() dice zero, non "zero fra poco"
	if nodo == null:
		return
	for figlio in nodo.get_children():
		nodo.remove_child(figlio)
		figlio.queue_free()
