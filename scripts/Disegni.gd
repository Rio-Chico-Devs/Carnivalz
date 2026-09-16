class_name Disegni
extends RefCounted

# CHIEDERE UN DISEGNO AL DISCO UNA VOLTA SOLA.
#
# Mezzo gioco e' fatto cosi': se il file c'e' vince lui, se non c'e' si disegna
# a mano. E' una buona regola - aggiungere un'icona e' aggiungere un file, senza
# toccare il codice - ma il modo in cui era scritta chiedeva al disco A OGNI
# DISEGNO:
#
#     if ResourceLoader.exists(percorso):
#         var texture: Texture2D = load(percorso)
#
# Sulla mappa della zona quelle due righe stanno dentro il disegno, e il disegno
# si rifa' a ogni fotogramma finche' il punto esclamativo pulsa: sessanta
# controlli sul filesystem al secondo per un file che c'e' o non c'e' da quando
# il gioco e' partito. `load()` almeno passa per la cache delle risorse;
# `ResourceLoader.exists()` no, quello guarda davvero.
#
# Qui la risposta si ricorda: la prima volta si chiede, poi mai piu'. Si ricorda
# anche il NO - "quel file non c'e'" e' una risposta buona quanto le altre, ed
# e' quella che capita piu' spesso finche' i disegni di Bru non ci sono.
#
# SI RICORDA FINO A FINE PARTITA. Se un disegno viene aggiunto mentre il gioco
# gira, non comparira' da solo: c'e' svuota_cache() apposta, e la chiama chi
# ricarica i dati.

static var trovati: Dictionary = {}
# quante volte si e' davvero andati a guardare. Serve alle prove: e' l'unico
# modo di dire "non ci sta piu' andando a ogni fotogramma" con un numero
static var ricerche := 0

static func texture(percorso: String) -> Texture2D:
	if percorso == "":
		return null
	if trovati.has(percorso):
		return trovati[percorso]
	ricerche += 1
	var trovata: Texture2D = load(percorso) if ResourceLoader.exists(percorso) else null
	trovati[percorso] = trovata
	return trovata

static func c_e(percorso: String) -> bool:
	return texture(percorso) != null

static func svuota_cache() -> void:
	trovati.clear()
	ricerche = 0
