#!/usr/bin/env bash
# Misura UN solo accoppiamento, in qualche secondo.
#
#   ./prove/sonda.sh volto_sulla_parete             tutte le strategie, tutti i livelli
#   ./prove/sonda.sh volto_sulla_parete attacca 18  una riga sola
#
# E' lo stesso giocatore automatico di ./prove/simula.sh, con un filtro. Serve
# quando la domanda non e' "com'e' messo il bilanciamento" (quaranta minuti, e va
# bene cosi') ma "questa creatura e' peggiorata: per colpa di cosa?". A quella si
# risponde cambiando UNA cosa in un file di dati e rimisurando - e se ogni misura
# costa quaranta minuti, non la si fa e si tira a indovinare.
#
# NON riscrive docs/bilanciamento.md: quella resta la tabella del giro completo.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ $# -lt 1 ]; then
	echo "uso: ./prove/sonda.sh <id_creatura> [strategia] [livello]" >&2
	echo "strategie: attacca, difendi, studia, casuale" >&2
	exit 2
fi
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. Installalo, oppure: GODOT=/percorso/godot ./prove/sonda.sh ..." >&2
	exit 127
fi
"$GODOT" --headless --path . prove/Simulatore.tscn -- "$@"
