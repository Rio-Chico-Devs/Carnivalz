#!/usr/bin/env bash
# Misura i tempi dell'interfaccia di combattimento. Non e' una prova: stampa
# numeri. Vuole un display (xvfb-run basta): il tempo reale misurato da muti
# sarebbe un altro gioco.
set -euo pipefail
cd "$(dirname "$0")/.."
CHI="${1:-veronica}"
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
[ -z "$GODOT" ] && { echo "Godot non trovato. GODOT=/percorso/godot $0" >&2; exit 127; }
LANCIA="$GODOT"
if [ -z "${DISPLAY:-}" ]; then
	command -v xvfb-run >/dev/null || { echo "Nessun display e nessun xvfb-run." >&2; exit 1; }
	LANCIA="xvfb-run -a $GODOT"
fi
# shellcheck disable=SC2086
$LANCIA --rendering-driver opengl3 --path . --resolution 1280x720 prove/Misura.tscn -- "$CHI" 2>&1 \
	| grep -vE "ALSA|audio_driver|snd_|All audio drivers|status < 0" || true
