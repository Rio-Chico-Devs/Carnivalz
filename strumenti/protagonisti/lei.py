#!/usr/bin/env python3
# LEI SUL PIANETA: scrive art/pianeti/protagonista/lei.png
#
#   python3 strumenti/protagonisti/lei.py
#
# Il disegno e' in lei/*.txt (corpo.py), il passo in passo.py e gambe.py.
# Il foglio: 18 colonne (fermo, il respiro, i sedici tempi del passo) x 3 righe
# (giu', su, destra; la sinistra e' la destra allo specchio); fotogrammi 64x120
# (lei e' alta 100 pixel, come nei disegni di Bru), i piedi al centro sulla
# riga TERRA, con l'ombra ovale per terra. Accanto, lei.json: le colonne, la
# strada per tempo, la velocita' e la riga dei piedi, per il gioco.
import json
import os
import sys

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
import corpo
import passo
import png

OMBRA = (18, 12, 24, 80)


def un_pezzo(f):
    """il fotogramma e' tutto attaccato (niente pezzi rimasti indietro)"""
    resto = set(f)
    q = [resto.pop()]
    while q:
        x, y = q.pop()
        for v in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if v in resto:
                resto.remove(v)
                q.append(v)
    return not resto


def foglio_del_gioco():
    W, H = passo.W, passo.H
    righe = passo.foglio()
    fw, fh = W * len(righe[0]), H * len(righe)
    pix = [(0, 0, 0, 0)] * (fw * fh)
    for riga, fotogrammi in enumerate(righe):
        for colonna, f in enumerate(fotogrammi):
            for (x, y), ch in f.items():
                assert 0 <= x < W and 0 <= y < H, (riga, colonna, x, y)
            assert un_pezzo(f), ('un pezzo staccato', riga, colonna)
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
    # accanto, le misure che il gioco deve sapere (prove/LivelloProva.gd e
    # MondoProva.gd, misure_del_foglio): le colonne, la strada per tempo, la velocita'
    with open(os.path.join(cartella, 'lei.json'), 'w') as f:
        json.dump({'colonne': 2 + passo.N, 'passo_px': passo.PASSO_PX, 'velocita': passo.VELOCITA,
                   'terra': passo.TERRA}, f)
        f.write('\n')
    print('scritto lei', w, h)
