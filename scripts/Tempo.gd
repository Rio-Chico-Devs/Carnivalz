class_name Tempo
extends RefCounted

# IL TEMPO DI GIOCO NON SALTA. Godot passa a _process il tempo VERO trascorso
# dal fotogramma prima, senza un tetto: se il portatile va in sospensione con
# il gioco aperto, o il sistema si inchioda qualche secondo (un antivirus che
# scansiona, il disco che si sveglia, uno shader compilato la prima volta),
# al fotogramma dopo arrivano in un colpo solo tutti quei secondi. Per le
# animazioni non importa; per le cose a tempo si': la scelta a tempo scadeva
# mentre il coperchio era chiuso, il colpo di grazia si perdeva, la Mattanza
# si scaricava tutta. Le cose che si giocano a tempo contano al massimo
# PASSO_MASSIMO per fotogramma: sotto i dieci fotogrammi al secondo il gioco
# rallenta invece di saltare, come fanno quasi tutti i giochi.

const PASSO_MASSIMO := 0.1


static func passo(delta: float) -> float:
	return minf(delta, PASSO_MASSIMO)
