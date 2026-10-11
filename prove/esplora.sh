#!/usr/bin/env bash
# L'esploratore: gioca tutte le strade della storia, senza schermo, e cerca
# prigioni (posti da cui non si esce) e punti morti (posti da cui la storia non
# va piu' avanti). Vedi prove/Esploratore.gd.
#   ./prove/esplora.sh
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/esplora.sh" >&2
	exit 127
fi
timeout --foreground "${LIMITE_SECONDI:-1800}" "$GODOT" --headless --path . prove/Esploratore.tscn 2>&1 \
	| grep -vE "ALSA|audio_driver_alsa|All audio drivers failed|snd_pcm|snd_func|snd_config"
exit "${PIPESTATUS[0]}"
