"""Le lastre della piazza antica del ruscello (terreni/piazza_radenna.png, coi colori del foglio di Bru) coi colori che
hanno nella mappa del ruscello, dopo riadatta(): per posarle uguali in altre zone (il pasto del goblin, la scena prima;
Bru: i pavimenti delle due scene devono essere coerenti). riadatta() da' a ogni colore il suo colore nuovo guardando
tutti i colori della mappa insieme, quindi qui si rifa' il terreno del ruscello fino a prima di riadatta (senza
scrivere niente) e si prende il colore nuovo di ogni colore della piazza; i pochi che nella mappa non ci sono (coperti
da un'ombra) prendono quello del colore piu' vicino che c'e'.
uso: piazza_tavolozza.py      (scrive art/livelli/terreni/piazza_radenna_tavolozza.png; ci mette circa un minuto)"""
import os
import sys

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
sys.path.insert(0, os.path.join(QUI, '..'))
import ruscello_radenna as rr     # noqa: E402

if __name__ == '__main__':
    piazza = np.asarray(Image.open(os.path.join(rr.TER, 'piazza_radenna.png')).convert('RGBA'))
    t, F = rr.pianta()
    terreno, G = rr.disegna(t, F)
    terreno = rr.decora(terreno, G)
    terreno = rr.luce_turchese(terreno, G)
    terreno = rr.ombre(terreno, G)
    nuovo = rr.riadatta(terreno)
    q = np.rint(np.clip(terreno, 0, 255)).astype(int)
    chiave = q[..., 0] * 65536 + q[..., 1] * 256 + q[..., 2]
    fl, nf = chiave.ravel(), np.rint(nuovo).astype(int).reshape(-1, 3)
    ordine = np.argsort(fl)
    fl_ord = fl[ordine]
    op = piazza[..., 3] > 0
    cols = np.unique(piazza[op][:, :3].astype(int), axis=0)
    mappa, mancano = {}, []
    for c in cols:
        k = int(c[0]) * 65536 + int(c[1]) * 256 + int(c[2])
        i = np.searchsorted(fl_ord, k)
        if i < len(fl_ord) and fl_ord[i] == k:
            mappa[tuple(c)] = nf[ordine[i]]
        else:
            mancano.append(tuple(c))
    noti = np.array(list(mappa), float)
    for c in mancano:
        j = int(((noti - np.array(c, float)) ** 2).sum(1).argmin())
        mappa[c] = mappa[tuple(int(v) for v in noti[j])]
    out = piazza.copy()
    for y, x in zip(*np.nonzero(op)):
        out[y, x, :3] = mappa[tuple(int(v) for v in piazza[y, x, :3])]
    Image.fromarray(out, 'RGBA').save(os.path.join(rr.TER, 'piazza_radenna_tavolozza.png'))
    print('piazza_radenna_tavolozza.png: %d colori, %d presi dal colore piu\' vicino' % (len(cols), len(mancano)))
