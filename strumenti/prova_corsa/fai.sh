#!/bin/sh
# Le pagine della prova corsa, da capo: Lei sul ruscello di Radenna (con l'acqua che scorre: i dati dell'acqua, i
# fotogrammi delle vasche e della pozza); e le pianure dall'arrivo: il prato dove appare Lei (strumenti/livelli/
# arrivo.py), la radura della Guida ordinata a griglia (griglia.py), il pasto del goblin (pasto_goblin.py) e il
# ruscello, collegati in fila: in cima a ogni zona si passa alla successiva, in fondo si torna.
# uso: fai.sh cartella_di_lavoro   ->   cartella_di_lavoro/prova_corsa.html e cartella_di_lavoro/prova_pianure.html
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
"$PY" "$QUI/costruisci.py" "$QUI/modello.html" "$W/prova_pianure.html" "$W" comparsa guida pasto ruscello albero
