#!/usr/bin/env bash
# Le scritte si leggono? Fotografa le schermate del menu principale e misura il
# contrasto vero di ogni scritta col fondo che ha dietro (prove/Leggibilita.gd).
#   ./prove/leggibilita.sh                  tutto il menu principale
#   ./prove/leggibilita.sh chi_sei_nome     un passo solo
#   ALTO_CONTRASTO=1 ./prove/leggibilita.sh, TESTO_GRANDE=1 ./prove/leggibilita.sh
# Le foto, con le scritte cattive cerchiate di rosso: scatti/leggibilita/.
# Serve una finestra vera (xvfb-run basta): senza, Godot non disegna niente.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/leggibilita.sh" >&2
	exit 127
fi
LANCIA="$GODOT"
if ! [ -n "${DISPLAY:-}" ]; then
	if command -v xvfb-run >/dev/null; then
		LANCIA="xvfb-run -a $GODOT"
	else
		echo "Nessun display e nessun xvfb-run: senza finestra non si disegna niente." >&2
		exit 1
	fi
fi
# shellcheck disable=SC2086
$LANCIA --path . --resolution 1280x720 prove/Leggibilita.tscn -- "$@" 2>&1 \
	| grep -vE "ALSA|audio_driver_alsa|All audio drivers failed|snd_pcm|snd_func|snd_config|Vulkan|VK_KHR|rendering_context_driver_vulkan|switching to OpenGL" || true
