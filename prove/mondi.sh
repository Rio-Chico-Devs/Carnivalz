#!/usr/bin/env bash
# I MONDI DA ESPLORARE (prove/MondoProva.gd, prove/MondoGenera.gd), tutti in
# scatti/mondi/:
#   - il controllo: trenta semi per bioma, ognuno si deve poter finire;
#   - il pilota automatico gioca due pianeti fino in fondo (senza finestra);
#   - le panoramiche: pianeti interi, un pixel del disegno per pixel, prima
#     (selvaggi) e dopo (colonizzati);
#   - il film col pilota automatico (mondi.mp4) e le foto dei suoi momenti.
# Provvisorio come la prova. Serve ffmpeg, e una finestra (xvfb-run basta).
#   ./prove/mondi.sh            tutto
#   ./prove/mondi.sh controllo  solo il controllo e il pilota
#   ./prove/mondi.sh tessere    scrive in art/pianeti/ i PNG delle tessere che mancano
set -euo pipefail
MODO="${1:-}"
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/mondi.sh" >&2
	exit 127
fi
if [ "$MODO" = "tessere" ]; then
	# i PNG che mancano in art/pianeti/ (quelli che ci sono non si toccano)
	"$GODOT" --headless --path . prove/MondoProva.tscn -- tessere 2>&1 | grep -E "TESSERE|ERROR"
	exit 0
fi
CARTELLA=scatti/mondi
mkdir -p "$CARTELLA"
rumore='Vulkan|VK_KHR|vulkan|Condition "(err|status)|OpenGL|ALSA|audio|V-Sync|vsync|^ +at: |DisplayServerX11|^Godot|^$'

echo "→ il controllo dei semi"
"$GODOT" --headless --path . prove/MondoProva.tscn -- controlla 30 2>&1 | grep -vE "$rumore" | tail -4

echo "→ il pilota automatico, fino alla fine"
for coppia in "3 pianure" "8 ardente"; do
	set -- $coppia
	esito="$(timeout 600 "$GODOT" --headless --path . --fixed-fps 60 prove/MondoProva.tscn -- film seme "$1" bioma "$2" 2>&1 | grep -E "FINITO|SCRIPT ERROR|^ERROR" || true)"
	echo "  $2 $1: ${esito:-NON FINITO}"
	case "$esito" in *FINITO*) ;; *) exit 1 ;; esac
done
[ "$MODO" = "controllo" ] && exit 0

LANCIA="$GODOT"
GRANDE="$GODOT"
if ! [ -n "${DISPLAY:-}" ]; then
	LANCIA="xvfb-run -a $GODOT"
	GRANDE="xvfb-run -a -s \"-screen 0 1800x1300x24\" $GODOT"
fi

echo "→ le panoramiche"
for coppia in "3 pianure" "8 ardente" "21 pianure"; do
	set -- $coppia
	for stato in "" colonizzato; do
		# shellcheck disable=SC2086
		eval $GRANDE --path . --resolution 1664x1216 prove/MondoProva.tscn -- panoramica seme "$1" bioma "$2" $stato 2>&1 \
			| grep -E "FOTO|SCRIPT ERROR|^ERROR" | grep -vE "$rumore" || true
	done
done

echo "→ il film"
appoggio="$(mktemp -d)"
# shellcheck disable=SC2086
$LANCIA --path . --resolution 1280x720 --write-movie "$appoggio/f.png" --fixed-fps 30 \
		prove/MondoProva.tscn -- film 3600 seme 3 > "$appoggio/registro.txt" 2>&1 || true
grep -E "SCRIPT ERROR|Parse Error|^ERROR" "$appoggio/registro.txt" | grep -vE "$rumore" || true
ffmpeg -loglevel error -y -framerate 30 -i "$appoggio/f%08d.png" -c:v libx264 -pix_fmt yuv420p -crf 20 "$CARTELLA/mondi.mp4"
grep -E "^SCATTO " "$appoggio/registro.txt" | while read -r _ nome fotogramma; do
	cp "$(printf "%s/f%08d.png" "$appoggio" "$fotogramma")" "$CARTELLA/$nome.png"
done
rm -rf "$appoggio"
ls "$CARTELLA"
