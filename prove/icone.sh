#!/usr/bin/env bash
# Scrive i file da misurare delle icone delle statistiche (scripts/crescita/IconeStatistiche.gd):
# gli SVG e i PNG in art/interfaccia/statistiche/proposta/ e il rapporto in
# docs/icone_statistiche.md. Per i PNG serve una finestra (xvfb-run basta).
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/icone.sh" >&2
	exit 127
fi
LANCIA="$GODOT"
if ! [ -n "${DISPLAY:-}" ]; then
	LANCIA="xvfb-run -a $GODOT"
fi
# shellcheck disable=SC2086
$LANCIA --path . --resolution 1280x720 prove/EsportaIcone.tscn 2>&1 \
	| grep -vE "ALSA|audio_driver_alsa|All audio drivers failed|snd_pcm|snd_func|snd_config|Vulkan|VK_KHR|rendering_context_driver_vulkan|switching to OpenGL" || true
