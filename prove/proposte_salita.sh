#!/usr/bin/env bash
# La salita vera a fotogrammi (prove/ProposteSalita.gd), fotografata in
# scatti/proposte_salita/. Provvisorio: se ne va con la scelta di Bru.
# Serve una finestra vera (xvfb-run basta): senza, Godot non disegna niente.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/proposte_crescita.sh" >&2
	exit 127
fi
LANCIA="$GODOT"
if ! [ -n "${DISPLAY:-}" ]; then
	LANCIA="xvfb-run -a $GODOT"
fi
# shellcheck disable=SC2086
$LANCIA --path . --resolution 1280x720 prove/ProposteSalita.tscn -- foto "$@" 2>&1 \
	| grep -vE "ALSA|audio_driver_alsa|All audio drivers failed|snd_pcm|snd_func|snd_config|Vulkan|VK_KHR|rendering_context_driver_vulkan|switching to OpenGL" || true
