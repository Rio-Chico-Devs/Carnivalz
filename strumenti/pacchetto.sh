#!/usr/bin/env bash
# Costruisce lo zip del progetto da consegnare.
#
# NON usare "zip" su un elenco di file: cosi' l'archivio contiene solo le voci
# dei file e NESSUNA voce di cartella, e l'importatore di Godot (Progetti >
# Importa su un .zip) non riesce a creare le cartelle annidate. Il risultato e'
# un elenco di "failed extraction from package" su prove/, strumenti/ e
# scripts/combattimento/, che pero' non spiega perche'.
#
# "git archive" le voci di cartella le scrive, e in piu' prende esattamente
# quello che e' nel repo: niente build/, niente .godot/, niente file dimenticati
# in giro.
set -euo pipefail
cd "$(dirname "$0")/.."
DESTINAZIONE="${1:-/tmp/Carnivalz.zip}"
rm -f "$DESTINAZIONE"
git archive --format=zip -o "$DESTINAZIONE" HEAD
echo "→ $DESTINAZIONE ($(du -h "$DESTINAZIONE" | cut -f1), $(unzip -l "$DESTINAZIONE" | tail -1 | awk '{print $2}') file)"
