#!/usr/bin/env python3
# LEI SUL PIANETA: scrive art/pianeti/protagonista/lei.png
#
#   python3 strumenti/protagonisti/lei.py
#
# Il disegno e' in lei/*.txt (corpo.py), il passo in passo.py e gambe.py.
# Il foglio: 10 colonne (fermo, il respiro, gli otto tempi del passo) x 3 righe
# (giu', su, destra; la sinistra e' la destra allo specchio); fotogrammi 64x112
# (lei e' alta 100 pixel, come nei disegni di Bru), i piedi al centro, tre
# righe sopra il fondo (dove li mette il gioco), con l'ombra ovale per terra.
import os
import sys

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
import corpo
import passo
import png

OMBRA = (18, 12, 24, 80)


def foglio_del_gioco():
    W, H = passo.W, passo.H
    righe = passo.foglio()
    fw, fh = W * len(righe[0]), H * len(righe)
    pix = [(0, 0, 0, 0)] * (fw * fh)
    for riga, fotogrammi in enumerate(righe):
        for colonna, f in enumerate(fotogrammi):
            for (x, y), ch in f.items():
                assert 0 <= x < W and 0 <= y < H, (riga, colonna, x, y)
            for y in range(H):
                for x in range(W):
                    ch = f.get((x, y))
                    if ch is not None:
                        p = corpo.COLORI[ch] + (255,)
                    else:
                        dx, dy = (x + 0.5 - W / 2) / 15.0, (y + 0.5 - (passo.TERRA + 0.5)) / 3.5
                        p = OMBRA if dx * dx + dy * dy < 1 else (0, 0, 0, 0)
                    pix[(riga * H + y) * fw + colonna * W + x] = p
    return fw, fh, pix


if __name__ == '__main__':
    w, h, pix = foglio_del_gioco()
    cartella = os.path.join(QUI, '..', '..', 'art', 'pianeti', 'protagonista')
    png.scrivi(os.path.join(cartella, 'lei.png'), w, h, pix)
    print('scritto lei', w, h)
