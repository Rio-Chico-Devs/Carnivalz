#!/usr/bin/env bash
# Tira fuori i suoni sintetizzati in scatti/audio/ per poterli ascoltare.
#   ./prove/ascolta.sh          tutti
#   ./prove/ascolta.sh vetro    uno solo
#
# Non e' una prova: le prove misurano che un suono ci sia e sia lungo quanto
# deve, non che SUONI come deve. Questo serve alle orecchie, come scatto.sh
# serve agli occhi.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/ascolta.sh" >&2
	exit 127
fi
"$GODOT" --headless --path . prove/Ascolta.tscn -- "$@" 2>&1 | grep -vE "^$|Godot Engine"
