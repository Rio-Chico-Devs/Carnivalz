"""Il goblin tipico (data/personaggi.json: goblin_tipico): le pose del foglio d'esempio di Bru (115, riportato ai pixel
veri da esempi_bru.py in esempi.png) con la lingua blu del suo disegno (114). Bru: "ti ho dato un foglio pieno di
esempi... parti da quelle e semplicemente aggiungi la lingua".
Il foglio: 5 file x 5 colonne di pose, ognuna in un riquadro di 38x50 coi piedi sull'ultima riga; le colonne come
negli esempi: di fronte, di lato (verso sinistra nelle prime tre file, verso destra nelle ultime due), la corsa di
fronte con la bocca aperta, di spalle di lato, di spalle.
La lingua (blu, coi suoi chiaro e scuro e il contorno nero come il resto) dove si vede la bocca: di fronte pende
dritta fra le zanne, sotto la punta del naso; di lato pende sul mento e piega di un pixel verso il naso; nella corsa
la lingua rosa della bocca aperta diventa blu ed esce sul mento. Di spalle non si vede.
uso: goblin_tipico.py cartella    (legge cartella/esempi.png, scrive cartella/goblin_tipico.png)"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from esempi_bru import QH, QW, TAV  # noqa: E402

LINGUA = {'b': (66, 109, 145), 'B': (112, 160, 196), 'n': (36, 64, 90)}   # medio, luce, scuro (dal disegno 114)
COLORI = dict(TAV, **LINGUA)


def leggi(percorso):
    a = np.asarray(Image.open(percorso).convert('RGBA'))
    L = np.full(a.shape[:2], '.', dtype='<U1')
    for k, c in TAV.items():
        L[(a[..., 3] > 0) & np.all(a[..., :3] == c, -1)] = k
    assert ((L != '.') == (a[..., 3] > 0)).all(), 'colori fuori dalla tavolozza'
    return L


def dritta(ax, ay, giu=4):
    """2 pixel di larghezza, dalla bocca (riga ay) giu' per 'giu' righe, col contorno ai lati e sotto"""
    p = [(ax, ay, 'b'), (ax + 1, ay, 'b')]
    for k in range(1, giu):
        p += [(ax, ay + k, 'B' if k == 1 else 'b'), (ax + 1, ay + k, 'b' if k < giu - 1 else 'n')]
        p += [(ax - 1, ay + k, 'k'), (ax + 2, ay + k, 'k')]
    p[-4] = (ax, ay + giu - 1, 'n')
    p += [(ax, ay + giu, 'k'), (ax + 1, ay + giu, 'k')]
    return p


def storta(ax, ay, verso):
    """di lato: due righe sotto la bocca, poi piega di un pixel verso il naso (verso -1 sinistra, +1 destra)"""
    a, b = ax, ax + 1
    p = [(a, ay, 'b'), (b, ay, 'b'), (a, ay + 1, 'B' if verso < 0 else 'b'), (b, ay + 1, 'b' if verso < 0 else 'B'),
         (a - 1, ay + 1, 'k'), (b + 1, ay + 1, 'k')]
    a2, b2 = a + verso, b + verso
    p += [(a2, ay + 2, 'b'), (b2, ay + 2, 'b'), (a2 - 1, ay + 2, 'k'), (b2 + 1, ay + 2, 'k'),
          (a2, ay + 3, 'n'), (b2, ay + 3, 'n'), (a2 - 1, ay + 3, 'k'), (b2 + 1, ay + 3, 'k'),
          (a2, ay + 4, 'k'), (b2, ay + 4, 'k')]
    return p


def lingue(L):
    L = L.copy()

    def metti(fila, col, punti):
        for x, y, ch in punti:
            L[fila * QH + y, col * QW + x] = ch
    for f in range(5):                                  # di fronte: il viso e' lo stesso nelle cinque pose
        metti(f, 0, dritta(18, 29))
    for f, (ax, ay, verso) in enumerate([(15, 29, -1), (15, 30, -1), (15, 30, -1), (24, 29, 1), (24, 29, 1)]):
        metti(f, 1, storta(ax, ay, verso))            # di lato
    for f in range(5):                                  # la corsa di fronte, con la bocca aperta
        sub = L[f * QH:(f + 1) * QH, 2 * QW:3 * QW]
        rosa = [(x, y) for y in range(28, 33) for x in range(QW) if sub[y, x] == 'm']
        chiari = [(x, y) for y in range(28, 33) for x in range(QW) if sub[y, x] in 'Ll'
                  and any(sub[y + dy, x + dx] == 'm' for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0)))]
        tutti = sorted(rosa + chiari, key=lambda t: (t[1], t[0]))
        for x, y in tutti:
            sub[y, x] = 'b'
        sub[tutti[0][1], tutti[0][0]] = 'B'             # la luce in alto a sinistra
        fondo = max(y for x, y in tutti)
        xs = sorted(x for x, y in tutti if y == fondo)
        ax = xs[len(xs) // 2] - (1 if len(xs) % 2 == 0 else 0)
        metti(f, 2, dritta(ax, fondo + 1, 3)[2:])
    return L


if __name__ == '__main__':
    D = sys.argv[1]
    L = lingue(leggi(os.path.join(D, 'esempi.png')))
    img = np.zeros(L.shape + (4,), np.uint8)
    for k, c in COLORI.items():
        m = L == k
        img[m, :3] = c
        img[m, 3] = 255
    Image.fromarray(img, 'RGBA').save(os.path.join(D, 'goblin_tipico.png'))
    print('goblin_tipico.png', L.shape[1], 'x', L.shape[0])
