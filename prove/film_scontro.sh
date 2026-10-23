#!/usr/bin/env bash
# LA PROPOSTA DI SCHERMATA DI COMBATTIMENTO (prove/ProposteScontro.gd), girata
# col Movie Maker di Godot in scatti/proposte_scontro/: scontro.mp4, e gli
# scatti dei momenti (comandi, lista, studio, scoperta, racconto, minigioco,
# veronica). Provvisorio: se ne va con la scelta di Bru.
# Serve ffmpeg, e una finestra vera (xvfb-run basta).
#   ./prove/film_scontro.sh            il film e gli scatti
#   ./prove/film_scontro.sh scatti     solo gli scatti
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/film_scontro.sh" >&2
	exit 127
fi
command -v ffmpeg >/dev/null || { echo "Serve ffmpeg." >&2; exit 127; }
LANCIA="$GODOT"
if ! [ -n "${DISPLAY:-}" ]; then
	LANCIA="xvfb-run -a $GODOT"
fi
CARTELLA=scatti/proposte_scontro
mkdir -p "$CARTELLA"
filtra() {
	grep -E "SCRIPT ERROR|Parse Error|^ERROR" \
		| grep -vE "Vulkan|VK_KHR|rendering_context_driver_vulkan|Condition \"err != OK\"|Condition \"status < 0\"" || true
}
if [ "${1:-}" != "scatti" ]; then
	appoggio="$(mktemp -d)"
	# 38 secondi a 30 fotogrammi, e un poco: il film si ferma da solo
	# shellcheck disable=SC2086
	$LANCIA --path . --resolution 1280x720 --write-movie "$appoggio/f.png" --fixed-fps 30 \
			--quit-after 1200 prove/ProposteScontro.tscn -- film 2>&1 | filtra
	ffmpeg -loglevel error -y -framerate 30 -i "$appoggio/f%08d.png" -c:v libx264 -pix_fmt yuv420p -crf 18 \
			"$CARTELLA/scontro.mp4"
	echo "FILM scontro: $(find "$appoggio" -name 'f*.png' | wc -l) fotogrammi"
	rm -rf "$appoggio"
fi
for momento in comandi lista studio scoperta racconto minigioco veronica; do
	# shellcheck disable=SC2086
	$LANCIA --path . --resolution 1280x720 prove/ProposteScontro.tscn -- scatto "$momento" "$(pwd)/$CARTELLA" 2>&1 | filtra
	echo "SCATTO $momento"
done
