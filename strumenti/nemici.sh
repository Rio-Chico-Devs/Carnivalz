#!/usr/bin/env bash
# Riscrive docs/nemici.md leggendo i dati del gioco: livelli, ruoli, stat dalla
# curva e mosse con i valori che il combattimento usera' davvero.
#   ./strumenti/nemici.sh
#
# Non e' una prova: e' una fotografia. Va rilanciato quando si tocca il
# bestiario, se no il documento racconta il gioco di ieri - ed e' peggio di non
# averlo, perche' uno se ne fida.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. Installalo, oppure: GODOT=/percorso/godot ./strumenti/nemici.sh" >&2
	exit 127
fi
"$GODOT" --headless --path . --import >/dev/null
"$GODOT" --headless --path . strumenti/SchedaNemici.tscn
