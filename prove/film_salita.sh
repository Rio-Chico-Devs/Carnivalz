#!/usr/bin/env bash
# I film della salita (prove/FilmSalita.gd), girati col Movie Maker di Godot in
# scatti/proposte_salita/: salita.mp4 (dal 7 all'8) e oltre_il_20.mp4 (la ruota
# che si spacca e scopre quella nuova). Provvisorio: se ne va con la scelta di Bru.
# Serve ffmpeg, e una finestra vera (xvfb-run basta).
#   ./prove/film_salita.sh                 tutti e due
#   ./prove/film_salita.sh oltre_il_20     uno solo
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/film_salita.sh" >&2
	exit 127
fi
command -v ffmpeg >/dev/null || { echo "Serve ffmpeg." >&2; exit 127; }
LANCIA="$GODOT"
if ! [ -n "${DISPLAY:-}" ]; then
	LANCIA="xvfb-run -a $GODOT"
fi
CARTELLA=scatti/proposte_salita
mkdir -p "$CARTELLA"
# quanti fotogrammi (a 30 al secondo): la durata dei momenti di FilmSalita.FILM, e un poco
declare -A QUANTI=([salita]=540 [oltre_il_20]=240)
FILM=("$@")
[ ${#FILM[@]} -gt 0 ] || FILM=(salita oltre_il_20)
for nome in "${FILM[@]}"; do
	appoggio="$(mktemp -d)"
	# shellcheck disable=SC2086
	$LANCIA --path . --resolution 1280x720 --write-movie "$appoggio/f.png" --fixed-fps 30 \
			--quit-after "${QUANTI[$nome]}" prove/FilmSalita.tscn -- film "$nome" 2>&1 \
		| grep -E "SCRIPT ERROR|Parse Error|^ERROR" \
		| grep -vE "Vulkan|VK_KHR|rendering_context_driver_vulkan|Condition \"err != OK\"|Condition \"status < 0\"" || true
	ffmpeg -loglevel error -y -framerate 30 -i "$appoggio/f%08d.png" -c:v libx264 -pix_fmt yuv420p -crf 18 \
			"$CARTELLA/$nome.mp4"
	echo "FILM $nome: $(find "$appoggio" -name 'f*.png' | wc -l) fotogrammi"
	rm -rf "$appoggio"
done
