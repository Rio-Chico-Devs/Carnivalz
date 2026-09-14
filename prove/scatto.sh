#!/usr/bin/env bash
# Fotografa una schermata e la salva in scatti/.
#   ./prove/scatto.sh dialogo
#   ./prove/scatto.sh menu
#
# Non e' una prova: non misura niente e non fallisce. Serve a guardare com'e'
# venuta una schermata, che e' la cosa che le prove non sanno dire.
#
# SERVE UNA FINESTRA. Godot senza finestra non disegna: uno scatto preso in
# --headless sarebbe nero, e nero non vuol dire sbagliato, vuol dire che non e'
# stato disegnato niente. Con xvfb-run la finestra c'e' anche su un server.
set -euo pipefail
cd "$(dirname "$0")/.."
QUALE="${1:-dialogo}"
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/scatto.sh $QUALE" >&2
	exit 127
fi
LANCIA="$GODOT"
if ! [ -n "${DISPLAY:-}" ]; then
	if command -v xvfb-run >/dev/null; then
		LANCIA="xvfb-run -a $GODOT"
	else
		echo "Nessun display e nessun xvfb-run: lo scatto verrebbe nero." >&2
		exit 1
	fi
fi
# shellcheck disable=SC2086
$LANCIA --path . --resolution 1280x720 prove/Scatto.tscn -- "$QUALE" 2>&1 \
	| grep -vE "ALSA|audio_driver_alsa|All audio drivers failed|snd_pcm|snd_func|snd_config" || true
