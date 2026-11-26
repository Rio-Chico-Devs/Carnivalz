"""Un foglio d'esempio di Bru (pixel art ingrandita e compressa, es. il 115 dei goblin) riportato ai pixel veri.
Il 115 e' una griglia di 5x5 pose con i pixel grandi 4,687 punti (non intero) e il fondo verde; le righe scure lo
dividono in cinque file. Qui: per ogni pixel vero la mediana del centro del suo quadrato; il fondo (riempito dai
bordi di ogni cella, si ferma al contorno nero) diventa trasparente; ogni colore va al piu' vicino (OKLab) di una
tavolozza presa dagli esempi stessi; i colori che toccano il fondo diventano contorno (dove gli esempi l'hanno
aperto) e i puntini staccati (resti della compressione) spariscono; le pose in riquadri di 38x50 coi piedi
sull'ultima riga.
uso: esempi_bru.py esempi.webp foglio.png"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from tavolozza import oklch  # noqa: E402

PASSO, X0, Y0 = 4.687, 2.2, 4.3                # il passo dei pixel e dove cominciano (misurati sul 115)
FILE = [(0, 50), (51, 101), (102, 152), (153, 203), (204, 254)]   # le file di pose (fra le righe scure)
QW, QH = 38, 50                                # il riquadro di una posa
TAV = {
    'k': (10, 14, 13),                                                                 # contorno
    'G': (106, 166, 110), 'g': (89, 155, 94), 'd': (64, 112, 80), 'D': (42, 72, 54),   # pelle
    'P': (84, 58, 104), 'p': (65, 43, 85), 'q': (47, 28, 66), 'Q': (28, 19, 42),       # capelli
    'L': (156, 115, 84), 'l': (124, 90, 71), 'h': (90, 69, 57),                        # clava e perizoma
    'w': (238, 225, 201),                                                              # occhi e zanne
    'm': (153, 78, 84), 'M': (72, 26, 34),                                             # bocca
}


def _lab(rgb):
    L, C, h = np.moveaxis(oklch(np.asarray(rgb, float)), -1, 0)
    return np.stack([L, C * np.cos(np.radians(h)), C * np.sin(np.radians(h))], -1)


def nativo(a):
    nx, ny = int((a.shape[1] - X0) / PASSO), int((a.shape[0] - Y0) / PASSO)
    out = np.zeros((ny, nx, 3), np.uint8)
    for j in range(ny):
        for i in range(nx):
            cx, cy = X0 + (i + 0.5) * PASSO, Y0 + (j + 0.5) * PASSO
            b = a[int(round(cy - 1.2)):int(round(cy + 1.2)) + 1, int(round(cx - 1.2)):int(round(cx + 1.2)) + 1]
            out[j, i] = np.median(b.reshape(-1, 3), 0)
    return out.astype(int)


def figure(a):
    H, W, _ = a.shape
    fondo_col = np.median(a[2:6, 2:6].reshape(-1, 3), 0)
    sep = [y for y in range(H) if (a[y].sum(-1) < 160).mean() > 0.7]
    simile = np.abs(a - fondo_col).sum(-1) < 45
    fondo = np.zeros((H, W), bool)
    pila = [(y, x) for y in range(H) for x in (0, W - 1)] + [(y, x) for x in range(W) for y in (0, H - 1)]
    for y in sep:
        pila += [(y - 1, x) for x in range(W)] + [(y + 1, x) for x in range(W) if y + 1 < H]
    pila = [(y, x) for y, x in pila if 0 <= y < H and simile[y, x]]
    for y, x in pila:
        fondo[y, x] = True
    while pila:
        y, x = pila.pop()
        for yy, xx in ((y, x + 1), (y + 1, x), (y, x - 1), (y - 1, x)):
            if 0 <= yy < H and 0 <= xx < W and simile[yy, xx] and not fondo[yy, xx]:
                fondo[yy, xx] = True
                pila.append((yy, xx))
    fondo[sep] = True
    return ~fondo


def lettere(a, fig):
    chiavi = list(TAV)
    P = _lab([TAV[k] for k in chiavi])
    X = _lab(a.reshape(-1, 3)).reshape(a.shape[0], a.shape[1], 3)
    idx = ((X[:, :, None, :] - P[None, None]) ** 2).sum(-1).argmin(-1)
    L = np.array(chiavi)[idx]
    L[~fig] = '.'
    return L


def bordi(L):
    """i colori che toccano il fondo: un puntino staccato (al piu' due vicini pieni) sparisce, il resto diventa
    contorno (dove il contorno degli esempi e' aperto, come sulle punte delle orecchie, si chiude)"""
    H, W = L.shape
    nuovo = L.copy()
    for y in range(H):
        for x in range(W):
            if L[y, x] in '.k':
                continue
            if not any(not (0 <= y + dy < H and 0 <= x + dx < W) or L[y + dy, x + dx] == '.'
                       for dy, dx in ((0, 1), (1, 0), (0, -1), (-1, 0))):
                continue
            pieni = sum(1 for dy in (-1, 0, 1) for dx in (-1, 0, 1) if (dy or dx) and 0 <= y + dy < H
                        and 0 <= x + dx < W and L[y + dy, x + dx] != '.')
            nuovo[y, x] = 'k' if pieni >= 3 else '.'
    L = nuovo
    for y in range(H):
        for x in range(W):
            if L[y, x] == 'k' and not any(0 <= y + dy < H and 0 <= x + dx < W and L[y + dy, x + dx] != '.'
                                          for dy in (-1, 0, 1) for dx in (-1, 0, 1) if dy or dx):
                L[y, x] = '.'
    return L


def foglio(L):
    """le cinque file di pose una sotto l'altra, senza righe scure: 5 riquadri di 38x50 per fila"""
    return np.concatenate([L[y0:y0 + QH, :5 * QW] for y0, _ in FILE], 0)


def png(L, percorso):
    img = np.zeros(L.shape + (4,), np.uint8)
    for k, c in TAV.items():
        m = L == k
        img[m, :3] = c
        img[m, 3] = 255
    Image.fromarray(img, 'RGBA').save(percorso)


if __name__ == '__main__':
    a = nativo(np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float))
    L = foglio(bordi(lettere(a.astype(float), figure(a))))
    png(L, sys.argv[2])
    print('foglio', L.shape[1], 'x', L.shape[0])
