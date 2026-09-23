#!/usr/bin/env bash
# Un giocatore che non si stanca: parte dallo splash e gioca con clic e tasti
# veri, segnalando errori, blocchi e bottoni che non si lasciano premere.
#   ./prove/automa.sh                   esplora dal menu fino alla Sede, seme 1
#   ./prove/automa.sh esplora 7         un altro giro, altre scelte
#   ./prove/automa.sh scimmia 3 300     clic e tasti a caso per 300 secondi di gioco
#
# Serve Godot 4.5 o piu' (per sentire gli errori da dentro: OS.add_logger).
# Senza display gira senza finestra, veloce, e non fa scatti; con DISPLAY o
# SCATTI=1 (usa xvfb-run) salva uno scatto a ogni segnalazione in scatti/automa/.
#
# --fixed-fps 60: il tempo del gioco avanza di 1/60 di secondo a fotogramma,
# qualunque sia la velocita' della macchina. Cosi' "un minuto fermo" e' un
# minuto di gioco, e lo stesso seme gioca la stessa partita.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. GODOT=/percorso/godot ./prove/automa.sh" >&2
	exit 127
fi
LANCIA="$GODOT --headless"
if [ -n "${SCATTI:-}" ]; then
	if [ -n "${DISPLAY:-}" ]; then
		LANCIA="$GODOT"
	else
		LANCIA="xvfb-run -a $GODOT"
	fi
fi
# shellcheck disable=SC2086
timeout --foreground "${LIMITE_SECONDI:-1800}" $LANCIA --path . --fixed-fps 60 --resolution 1280x720 \
	prove/Automa.tscn -- "$@" 2>&1 \
	| grep -vE "ALSA|audio_driver_alsa|All audio drivers failed|snd_pcm|snd_func|snd_config"
exit "${PIPESTATUS[0]}"
