#!/usr/bin/env bash
# Fa giocare il gioco al giocatore automatico e riscrive docs/bilanciamento.md.
# Ci mette qualche minuto: e' l'unico strumento del progetto che non sta in una
# pipeline, perche' 99000 scontri non si fanno a ogni push.
#   ./prove/simula.sh
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. Installalo, oppure: GODOT=/percorso/godot ./prove/simula.sh" >&2
	exit 127
fi
"$GODOT" --headless --path . --import >/dev/null
"$GODOT" --headless --path . prove/Simulatore.tscn
