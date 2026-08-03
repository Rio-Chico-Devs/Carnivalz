#!/usr/bin/env bash
# Lancia le prove del progetto. Serve Godot 4 nel PATH (o in $GODOT).
#   ./prove/esegui.sh
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. Installalo, oppure: GODOT=/percorso/godot ./prove/esegui.sh" >&2
	exit 127
fi
echo "→ importo le risorse"
"$GODOT" --headless --path . --import >/dev/null
echo "→ il gioco si avvia"
"$GODOT" --headless --path . --quit-after 240
echo "→ prove"
"$GODOT" --headless --path . prove/Prove.tscn
