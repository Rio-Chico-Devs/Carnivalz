# Gli alberi dal foglio di Bru (strumenti/livelli/fogli/alberi_magici.jpg),
# uno per file, puliti pixel per pixel.
#
#   python3 strumenti/livelli/alberi_magici.py        (serve numpy e Pillow)
#
# Il foglio e' pixel art ingrandita circa 2,93 volte. Per ogni albero:
#   1. si cerca la sua griglia e si riporta ai suoi pixel veri (ogni
#      quadretto prende il colore mediano, il bianco del foglio e' vuoto);
#   2. i buchi di 1-2 pixel chiusi dentro si riempiono;
#   3. l'alone del JPG sul bordo (pixel schiariti dal bianco) prende il colore
#      del vicino dentro;
#   4. una tavolozza di 32 colori per albero, via i pixel soli.
# Scrive art/livelli/pezzi/alberi/<nome>.png e le loro voci nel catalogo.
import json
import os
from collections import deque

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
PEZZI = os.path.join(QUI, '..', '..', 'art', 'livelli', 'pezzi')
LUMA = np.array([0.3, 0.55, 0.15])
# il numero nel foglio (da sinistra a destra, dall'alto in basso), il nome,
# la scatola nel foglio
ALBERI = (
    (1, 'albero_viola', (26, 8, 474, 383)),
    (3, 'albero_funghi', (947, 12, 1375, 380)),
    (5, 'cespuglione', (522, 392, 886, 762)),
    (6, 'albero_blu', (939, 390, 1387, 762)),
)

im = np.array(Image.open(os.path.join(QUI, 'fogli', 'alberi_magici.jpg')).convert('RGB')).astype(float)
H, W, _ = im.shape
bianco = im.min(2) >= 222
L = im.mean(2)


def griglia(prof):
    n = len(prof); best = None
    for p in np.arange(2.85, 3.01, 0.005):
        for f in np.arange(0, p, 0.1):
            i = np.round(np.arange(f, n - 1, p)).astype(int); i = i[(i >= 0) & (i < n)]
            sc = prof[i].mean()
            if best is None or sc > best[0]:
                best = (sc, p, f)
    return best[1], best[2]


def macchie(m):
    h, w = m.shape; vis = np.zeros_like(m)
    for y0, x0 in zip(*np.nonzero(m)):
        if vis[y0, x0]:
            continue
        q = deque([(y0, x0)]); vis[y0, x0] = True; cel = []
        while q:
            y, x = q.popleft(); cel.append((y, x))
            for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if 0 <= yy < h and 0 <= xx < w and m[yy, xx] and not vis[yy, xx]:
                    vis[yy, xx] = True; q.append((yy, xx))
        yield cel


def tavolozza(X, K, seme=3):
    rng = np.random.default_rng(seme)
    cen = [X[rng.integers(len(X))]]
    for _ in range(K - 1):
        dd = np.min(((X[:, None] - np.array(cen)[None]) ** 2).sum(2), 1)
        cen.append(X[rng.choice(len(X), p=dd / dd.sum())])
    cen = np.array(cen, float)
    for _ in range(30):
        l = ((X[:, None] - cen[None]) ** 2).sum(2).argmin(1)
        cen = np.array([X[l == q].mean(0) if (l == q).any() else cen[q] for q in range(K)])
    return np.round(cen)


def vicini4(y, x, h, w):
    return [(yy, xx) for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)) if 0 <= yy < h and 0 <= xx < w]


cartella = os.path.join(PEZZI, 'alberi'); os.makedirs(cartella, exist_ok=True)
voci = {}
for numero, nome, (x0, y0, x1, y1) in ALBERI:
    # 1. i pixel veri
    a, b, c, d = max(0, y0 - 6), max(0, x0 - 6), min(H, y1 + 7), min(W, x1 + 7)
    C = im[a:c, b:d]; B = bianco[a:c, b:d]; Lc = L[a:c, b:d]
    px, fx = griglia(np.abs(np.diff(Lc, axis=1)).mean(0)); py, fy = griglia(np.abs(np.diff(Lc, axis=0)).mean(1))
    bx = np.arange(fx + 1 - px, d - b, px); by = np.arange(fy + 1 - py, c - a, py)
    o = np.zeros((len(by), len(bx), 4))
    for j in range(len(by)):
        for i in range(len(bx)):
            xa, xb = int(round(bx[i] + 0.7)), int(round(bx[i] + px - 0.7)); ya, yb = int(round(by[j] + 0.7)), int(round(by[j] + py - 0.7))
            xa, ya = max(0, xa), max(0, ya); xb, yb = min(d - b, max(xa + 1, xb)), min(c - a, max(ya + 1, yb))
            q = C[ya:yb, xa:xb].reshape(-1, 3); bq = B[ya:yb, xa:xb].reshape(-1)
            if len(q) == 0 or bq.mean() >= 0.5:
                continue
            o[j, i, :3] = np.median(q[~bq], 0); o[j, i, 3] = 255
    ys, xs = np.nonzero(o[..., 3]); o = o[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    h, w = o.shape[:2]
    # 2. i buchi piccoli
    m = o[..., 3] > 0
    for cel in macchie(~m):
        if len(cel) <= 2 and not any(y in (0, h - 1) or x in (0, w - 1) for y, x in cel):
            for y, x in cel:
                o[y, x, :3] = np.median([o[yy, xx, :3] for yy, xx in vicini4(y, x, h, w) if m[yy, xx]], 0)
                o[y, x, 3] = 255
    m = o[..., 3] > 0
    # 3. l'alone
    for _ in range(2):
        pad = np.pad(m, 1)
        bordo = m & (~pad[:-2, 1:-1] | ~pad[2:, 1:-1] | ~pad[1:-1, :-2] | ~pad[1:-1, 2:])
        lum = o[..., :3] @ LUMA
        nuovo = o.copy()
        for y, x in zip(*np.nonzero(bordo)):
            v = [(lum[yy, xx], yy, xx) for yy, xx in vicini4(y, x, h, w) if m[yy, xx] and not bordo[yy, xx]] \
                or [(lum[yy, xx], yy, xx) for yy, xx in vicini4(y, x, h, w) if m[yy, xx]]
            if v and lum[y, x] > min(v)[0] + 25 and lum[y, x] > max(t[0] for t in v) - 5:
                nuovo[y, x, :3] = o[min(v)[1], min(v)[2], :3]
        o = nuovo
    # 4. la tavolozza e i pixel soli
    TAV = tavolozza(o[m][:, :3], 32)
    q = np.full((h, w), -1)
    q[m] = ((o[m][:, None, :3] - TAV[None]) ** 2).sum(2).argmin(1)
    r = q.copy()
    for y, x in zip(*np.nonzero(m)):
        v = [q[yy, xx] for yy, xx in vicini4(y, x, h, w) if q[yy, xx] >= 0]
        if len(v) == 4 and q[y, x] not in v:
            piu = max(set(v), key=v.count)
            if v.count(piu) >= 3:
                r[y, x] = piu
    fatto = np.zeros((h, w, 4), np.uint8)
    fatto[m, :3] = TAV[r[m]]; fatto[m, 3] = 255
    Image.fromarray(fatto).save(os.path.join(cartella, nome + '.png'))
    # il piede: in fondo, al centro delle radici
    giu = np.nonzero(m[h - 6:])[1]
    voci[nome] = {"file": "alberi/%s.png" % nome, "misura": [w, h], "piede": [int(round(giu.mean())), h - 2]}

percorso = os.path.join(PEZZI, 'catalogo.json')
catalogo = json.load(open(percorso)) if os.path.exists(percorso) else {"pezzi": {}}
catalogo["pezzi"].update(voci)
with open(percorso, 'w') as f:
    json.dump(catalogo, f, indent=1, ensure_ascii=False, sort_keys=True)
    f.write('\n')
print('alberi:', ', '.join('%s %dx%d' % (k, v["misura"][0], v["misura"][1]) for k, v in voci.items()))
