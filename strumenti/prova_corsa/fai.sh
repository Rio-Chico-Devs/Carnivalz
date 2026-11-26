#!/bin/sh
# Le pagine della prova corsa, da capo: Lei sul ruscello di Radenna (con l'acqua che scorre: i dati dell'acqua, i
# fotogrammi delle vasche e della pozza) e nella radura del pasto del goblin (la mappa la fa
# strumenti/livelli/pasto_goblin.py), con tutto dentro.
# uso: fai.sh cartella_di_lavoro   ->   cartella_di_lavoro/prova_corsa.html e cartella_di_lavoro/prova_pasto.html
# (serve un Python con numpy e Pillow: PYTHON=/percorso/python3 fai.sh ... se non e' quello di sistema)
set -e
PY=${PYTHON:-python3}
QUI=$(cd "$(dirname "$0")" && pwd)
ACQUA="$QUI/../livelli/acqua"
W="$1"
mkdir -p "$W/dati" "$W/pezzi"
"$PY" "$ACQUA/dati_acqua.py" "$W/dati/acqua.npz"
"$PY" "$ACQUA/dati_png.py" "$W/dati/acqua.npz" "$W/dati/acqua_dati.png" "$W/dati/acqua_info.json"
"$PY" "$ACQUA/pezzi_anim.py" "$W/dati/acqua.npz" "$W/pezzi"
"$PY" "$QUI/costruisci.py" "$QUI/modello.html" "$W/prova_corsa.html" "$W"
"$PY" "$QUI/costruisci.py" "$QUI/modello.html" "$W/prova_pasto.html" "$W" pasto
