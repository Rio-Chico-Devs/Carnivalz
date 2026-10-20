#!/usr/bin/env bash
# Gli esempi di vita (prove/ProposteVita.gd), girati col Movie Maker di Godot in
# scatti/proposte_vita/: un .mp4 per esempio. Provvisorio: se ne va con le
# scelte di Bru. Serve ffmpeg, e una finestra vera (xvfb-run basta).
#   ./prove/film_vita.sh                      tutti
#   ./prove/film_vita.sh respiro mattanza     solo questi
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/film_vita.sh" >&2
	exit 127
fi
command -v ffmpeg >/dev/null || { echo "Serve ffmpeg." >&2; exit 127; }
LANCIA="$GODOT"
if ! [ -n "${DISPLAY:-}" ]; then
	LANCIA="xvfb-run -a $GODOT"
fi
CARTELLA=scatti/proposte_vita
mkdir -p "$CARTELLA"
FILM=("$@")
[ ${#FILM[@]} -gt 0 ] || FILM=(respiro squarcio turno mattanza collisioni)
for nome in "${FILM[@]}"; do
	appoggio="$(mktemp -d)"
	# lo scontro si dispone per un po' prima che l'esempio cominci: lo script
	# scrive da quale fotogramma, e il film parte da li'. Si ferma da solo
	# shellcheck disable=SC2086
	$LANCIA --path . --resolution 1280x720 --write-movie "$appoggio/f.png" --fixed-fps 30 \
			--quit-after 600 prove/ProposteVita.tscn -- film "$nome" > "$appoggio/registro.txt" 2>&1 || true
	grep -E "SCRIPT ERROR|Parse Error|^ERROR" "$appoggio/registro.txt" \
		| grep -vE "Vulkan|VK_KHR|rendering_context_driver_vulkan|Condition \"err != OK\"|Condition \"status < 0\"" || true
	inizio="$(grep -oE "INIZIO_FILM [0-9]+" "$appoggio/registro.txt" | grep -oE "[0-9]+" | head -1)"
	ffmpeg -loglevel error -y -framerate 30 -start_number "${inizio:-0}" -i "$appoggio/f%08d.png" \
			-c:v libx264 -pix_fmt yuv420p -crf 18 "$CARTELLA/$nome.mp4"
	echo "FILM $nome: dal fotogramma ${inizio:-0}, $(find "$appoggio" -name 'f*.png' | wc -l) in tutto"
	rm -rf "$appoggio"
done
