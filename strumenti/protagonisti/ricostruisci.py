#!/usr/bin/env python3
# DAI DISEGNI DI BRU AI PIXEL: un disegno in pixel ingrandito (un JPG col fondo
# a scacchi) -> la sua griglia vera, una lettera per pixel coi colori di lei
# (corpo.COLORI), da ripulire a mano e mettere in lei/*.txt.
#
#   python3 strumenti/protagonisti/ricostruisci.py disegno.jpg [x0 y0 x1 y1] > vista.txt
#
# (x0 y0 x1 y1: il riquadro, se il disegno ha piu' figure.) Come: via il fondo
# a scacchi entrando dai bordi; il passo e la fase dei quadretti, dove cadono i
# salti di colore; la mediana del centro di ogni quadretto; la figura piu'
# grande; il colore di lei piu' vicino (in OKLab). I buchi chiusi col colore
# del fondo (fra il braccio e il fianco) restano vuoti. Le viste di lei in
# fogli/ sono le griglie cosi' ricostruite (prima della pulizia a mano).
import os
import sys
from collections import deque

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import corpo

FONDI = np.array([(64, 104, 120), (112, 148, 156), (68, 108, 116), (40, 56, 72), (52, 72, 88)])
SCACCHI = FONDI[:3]                  # i quadri del fondo (gli altri due sono l'ombra per terra)


def oklab(c):
    c = np.asarray(c, float) / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    l = 0.4122214708 * c[..., 0] + 0.5363325363 * c[..., 1] + 0.0514459929 * c[..., 2]
    m = 0.2119034982 * c[..., 0] + 0.6806995451 * c[..., 1] + 0.1073969566 * c[..., 2]
    s = 0.0883024619 * c[..., 0] + 0.2817188376 * c[..., 1] + 0.6299787005 * c[..., 2]
    l, m, s = np.cbrt(l), np.cbrt(m), np.cbrt(s)
    return np.stack([0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
                     1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
                     0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s], -1)


def via_il_fondo(im):
    h, w, _ = im.shape
    fondo = np.abs(im[:, :, None, :] - FONDI[None, None]).sum(axis=3).min(axis=2) < 46
    fuori = np.zeros((h, w), bool)
    q = deque((x, y) for x in range(w) for y in (0, h - 1))
    q.extend((x, y) for y in range(h) for x in (0, w - 1))
    while q:
        x, y = q.popleft()
        if 0 <= x < w and 0 <= y < h and not fuori[y, x] and fondo[y, x]:
            fuori[y, x] = True
            q.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return ~fuori


def griglia(profilo, passi):
    """(passo, fase) dove i salti di colore cadono piu' sui bordi dei quadretti"""
    meglio = None
    for p in passi:
        for k in range(60):
            o = p * k / 60
            v = np.interp(np.arange(o, len(profilo) - 1, p), np.arange(len(profilo)), profilo).mean()
            if meglio is None or v > meglio[0]:
                meglio = (v, p, o)
    return meglio[1], meglio[2]


def ricostruisci(percorso, riquadro=None):
    im = np.asarray(Image.open(percorso).convert('RGB')).astype(int)
    if riquadro:
        x0, y0, x1, y1 = riquadro
        im = im[y0:y1, x0:x1]
    h, w, _ = im.shape
    dentro = via_il_fondo(im)
    f = im.astype(float)
    gx = (np.abs(np.diff(f, axis=1)).sum(axis=2) * (dentro[:, 1:] & dentro[:, :-1])).sum(axis=0)
    gy = (np.abs(np.diff(f, axis=0)).sum(axis=2) * (dentro[1:] & dentro[:-1])).sum(axis=1)
    passi = np.arange(3.5, 12.0, 0.01)
    px, ox = griglia(gx, passi)
    py, oy = griglia(gy, passi)
    p = (px + py) / 2
    ox, oy = ox - p, oy - p
    nw, nh = int((w - ox) / p) + 1, int((h - oy) / p) + 1
    m = 0.22 * p
    celle = {}
    for j in range(nh):
        for i in range(nw):
            xs = slice(max(0, int(np.ceil(ox + i * p + m))), min(w, int(ox + (i + 1) * p - m) + 1))
            ys = slice(max(0, int(np.ceil(oy + j * p + m))), min(h, int(oy + (j + 1) * p - m) + 1))
            c, d = im[ys, xs].reshape(-1, 3), dentro[ys, xs].reshape(-1)
            if len(c) and d.sum() * 2 >= len(d):
                celle[(i, j)] = np.median(c[d], axis=0)
    # la figura: il pezzo piu' grande
    pezzi, visti = [], set()
    for c0 in celle:
        if c0 in visti:
            continue
        pezzo, q = [], deque([c0])
        visti.add(c0)
        while q:
            i, j = q.popleft()
            pezzo.append((i, j))
            for v in ((i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)):
                if v in celle and v not in visti:
                    visti.add(v)
                    q.append(v)
        pezzi.append(pezzo)
    figura = max(pezzi, key=len)
    i0, i1 = min(c[0] for c in figura), max(c[0] for c in figura)
    j0, j1 = min(c[1] for c in figura), max(c[1] for c in figura)
    lettere = list(corpo.COLORI)
    tav = oklab(np.array([corpo.COLORI[k] for k in lettere]))
    righe = []
    for j in range(j0, j1 + 1):
        r = ''
        for i in range(i0, i1 + 1):
            c = celle.get((i, j)) if (i, j) in set(figura) else None
            if c is None:
                r += '.'
            elif np.abs(SCACCHI - c).sum(axis=1).min() < 40 and c[1] - c[0] > 25 and c[2] - c[0] > 35:
                r += '.'                          # un buco chiuso: si vede il fondo
            else:
                r += lettere[int(((oklab(c)[None] - tav) ** 2).sum(-1).argmin())]
        righe.append(r)
    return righe, p


if __name__ == '__main__':
    riquadro = tuple(int(v) for v in sys.argv[2:6]) if len(sys.argv) >= 6 else None
    righe, p = ricostruisci(sys.argv[1], riquadro)
    print('\n'.join(righe))
    print('passo dei quadretti %.2f, %d x %d' % (p, len(righe[0]), len(righe)), file=sys.stderr)
