#!/usr/bin/env bash
# La raccolta da giocare (prove/RaccoltaProva.gd), girata col pilota automatico
# e il Movie Maker di Godot: scatti/raccolta/raccolta.mp4, e le foto dei
# momenti che lo script dice (SCATTO). Provvisorio: se ne va con la scelta di Bru.
# Serve ffmpeg, e una finestra vera (xvfb-run basta).
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/raccolta.sh" >&2
	exit 127
fi
command -v ffmpeg >/dev/null || { echo "Serve ffmpeg." >&2; exit 127; }
LANCIA="$GODOT"
if ! [ -n "${DISPLAY:-}" ]; then
	LANCIA="xvfb-run -a $GODOT"
fi
CARTELLA=scatti/raccolta
mkdir -p "$CARTELLA"
appoggio="$(mktemp -d)"
# shellcheck disable=SC2086
$LANCIA --path . --resolution 1280x720 --write-movie "$appoggio/f.png" --fixed-fps 30 \
		--quit-after 4000 prove/RaccoltaProva.tscn -- film > "$appoggio/registro.txt" 2>&1 || true
grep -E "SCRIPT ERROR|Parse Error|^ERROR|^WARNING: (The|Integer|Narrow)" "$appoggio/registro.txt" \
	| grep -vE "Vulkan|VK_KHR|rendering_context_driver_vulkan|Condition \"err != OK\"|Condition \"status < 0\"" || true
inizio="$(grep -oE "INIZIO_FILM [0-9]+" "$appoggio/registro.txt" | grep -oE "[0-9]+" | head -1)"
ffmpeg -loglevel error -y -framerate 30 -start_number "${inizio:-0}" -i "$appoggio/f%08d.png" \
		-c:v libx264 -pix_fmt yuv420p -crf 20 "$CARTELLA/raccolta.mp4"
grep -E "^SCATTO " "$appoggio/registro.txt" | while read -r _ nome fotogramma; do
	sorgente="$(printf "%s/f%08d.png" "$appoggio" "$fotogramma")"
	[ -f "$sorgente" ] && cp "$sorgente" "$CARTELLA/$nome.png" && echo "SCATTO $nome"
done
echo "FILM raccolta: dal fotogramma ${inizio:-0}, $(find "$appoggio" -name 'f*.png' | wc -l) fotogrammi"
rm -rf "$appoggio"
