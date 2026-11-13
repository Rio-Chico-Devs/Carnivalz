# Gli alberi dei biomi dai fogli di Bru (strumenti/livelli/fogli/
# alberi_magici.jpg, albero_magenta.jpg, bioma_viola.jpg, bioma_viola_2.jpg),
# uno per file, puliti pixel per pixel.
#
#   python3 strumenti/livelli/alberi_magici.py        (serve numpy e Pillow)
#
# I fogli sono pixel art ingrandita circa 2,93 volte. L'albero magenta e'
# disegnato grande il doppio degli altri: c'e' anche piccolo, preso con un
# passo doppio (5,87), alto come gli altri. Per ogni albero:
#   1. si cerca la sua griglia e si riporta ai suoi pixel veri (ogni
#      quadretto prende il colore mediano, il bianco del foglio e' vuoto);
#   2. i buchi di 1-2 pixel chiusi dentro si riempiono;
#   3. l'alone del JPG sul bordo (pixel schiariti dal bianco) prende il colore
#      del vicino dentro;
#   4. una tavolozza di 32 colori per albero, via i pixel soli;
#   5. (il bioma viola) i colori ravvivati: le scale del disegno restano, ma
#      i toni medi e chiari salgono, piu' saturi, le ombre un poco verso il
#      blu e le luci verso il caldo; i colori quasi uguali diventano uno.
# Scrive art/livelli/pezzi/alberi/<nome>.png e le loro voci nel catalogo.
import json
import os
from collections import deque

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
PEZZI = os.path.join(QUI, '..', '..', 'art', 'livelli', 'pezzi')
LUMA = np.array([0.3, 0.55, 0.15])
# il foglio, il nome, la scatola nel foglio, il passo (piu' o meno)
ALBERI = (
    ('alberi_magici', 'albero_viola', (26, 8, 474, 383), 2.93),         # il primo del foglio
    ('alberi_magici', 'albero_funghi', (947, 12, 1375, 380), 2.93),     # il terzo
    ('alberi_magici', 'cespuglione', (522, 392, 886, 762), 2.93),       # il quinto
    ('alberi_magici', 'albero_blu', (939, 390, 1387, 762), 2.93),       # il sesto
    ('albero_magenta', 'albero_magenta', (299, 8, 1097, 750), 2.93),
    ('albero_magenta', 'albero_magenta_piccolo', (299, 8, 1097, 750), 5.87),
    # il foglio del bioma viola (il primo e' l'albero magenta rimpicciolito:
    # c'e' gia')
    ('bioma_viola', 'albero_spirale', (443, 73, 615, 307), 2.93),
    ('bioma_viola', 'felce_nera', (760, 76, 1000, 313), 2.93),
    ('bioma_viola', 'ramo_storto', (1129, 73, 1334, 307), 2.93),
    ('bioma_viola', 'albero_contorto', (31, 428, 316, 721), 2.93),
    ('bioma_viola', 'albero_contorto_2', (380, 448, 680, 718), 2.93),
    ('bioma_viola', 'baccelli_luminosi', (780, 425, 985, 712), 2.93),
    ('bioma_viola', 'sfere_luminose', (1120, 507, 1343, 659), 2.93),
    # il secondo foglio del bioma viola (il terzo e' l'albero magenta: c'e'
    # gia'; baccelli, sfere e felce sono altri disegni: varianti)
    ('bioma_viola_2', 'albero_vortice', (29, 32, 331, 322), 2.93),
    ('bioma_viola_2', 'albero_vortici', (407, 58, 645, 307), 2.93),
    ('bioma_viola_2', 'albero_fiore', (1112, 58, 1355, 313), 2.93),
    ('bioma_viola_2', 'cespuglio_sfere', (44, 445, 308, 721), 2.93),
    ('bioma_viola_2', 'baccelli_luminosi_2', (419, 422, 645, 715), 2.93),
    ('bioma_viola_2', 'radici_sfere', (751, 457, 1012, 706), 2.93),
    ('bioma_viola_2', 'felce_nera_2', (1110, 431, 1343, 670), 2.93),
)
# i fogli coi colori ravvivati (5.)
RAVVIVATI = {'albero_magenta', 'bioma_viola', 'bioma_viola_2'}


# ---- i colori in OKLab (la luce e la tinta come le vede l'occhio)
_M1 = np.array([[0.4122214708, 0.5363325363, 0.0514459929], [0.2119034982, 0.6806995451, 0.1073969566],
                [0.0883024619, 0.2817188376, 0.6299787005]])
_M2 = np.array([[0.2104542553, 0.7936177850, -0.0040720468], [1.9779984951, -2.4285922050, 0.4505937099],
                [0.0259040371, 0.7827717662, -0.8086757660]])
_M1i, _M2i = np.linalg.inv(_M1), np.linalg.inv(_M2)
BLU, GIALLO = np.deg2rad(264.0), np.deg2rad(100.0)


def in_lab(rgb):
    c = rgb / 255.0
    lin = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    return np.cbrt(lin @ _M1.T) @ _M2.T


def da_lch(L, C, h):
    # il colore sullo schermo; se esce dai colori possibili, meno saturo
    for _ in range(40):
        lin = ((np.array([L, C * np.cos(h), C * np.sin(h)]) @ _M2i.T) ** 3) @ _M1i.T
        if (lin >= -1e-4).all() and (lin <= 1 + 1e-4).all():
            break
        C *= 0.93
    lin = np.clip(lin, 0, 1)
    return np.round(np.where(lin <= 0.0031308, lin * 12.92, 1.055 * lin ** (1 / 2.4) - 0.055) * 255.0)


def verso(h, meta, quanto):
    # gira la tinta h verso meta, al massimo di `quanto`, per la via corta
    d = (meta - h + np.pi) % (2 * np.pi) - np.pi
    return h + np.sign(d) * min(abs(d), quanto)


def ravviva(a):
    m = a[..., 3] > 0
    cols, inv = np.unique(a[m][:, :3], axis=0, return_inverse=True)
    inv = inv.ravel()
    cnt = np.bincount(inv)
    lab = in_lab(cols.astype(float))
    L, C, H = lab[:, 0], np.hypot(lab[:, 1], lab[:, 2]), np.arctan2(lab[:, 2], lab[:, 1])
    tutti = np.repeat(L, cnt)
    lmin, lmax = np.percentile(tutti, 1), np.percentile(tutti, 99.5)
    # il piu' chiaro sale (di piu' se il pezzo e' scuro), il contorno resta
    lmax2 = min(0.92, lmax + 0.22 * (1 - lmax) + 0.06)
    nuovi = []
    for i in range(len(cols)):
        t = np.clip((L[i] - lmin) / max(1e-3, lmax - lmin), 0, 1.2)
        L2 = L[i] if L[i] < lmin else min(0.98, lmin + t ** 0.85 * (lmax2 - lmin))
        t = min(1.0, t)
        C2 = C[i] * max(1.0, 1.25 * (1 - 0.6 * max(0.0, (L2 - 0.8) / 0.2)))   # i quasi bianchi meno
        if t < 0.5:
            h2 = verso(H[i], BLU, np.deg2rad(10) * (1 - 2 * t))
        else:
            h2 = verso(H[i], GIALLO, np.deg2rad(12) * (2 * t - 1) * min(1.0, C[i] / 0.04))
        nuovi.append(da_lch(L2, C2, h2))
    nuovi = np.array(nuovi)
    # i colori nuovi quasi uguali: uno solo, quello con piu' pixel
    lab2 = in_lab(nuovi)
    tiene = []
    dove = np.arange(len(cols))
    for i in np.argsort(-cnt):
        for j in tiene:
            if np.linalg.norm(lab2[i] - lab2[j]) < 0.03:
                dove[i] = j
                break
        else:
            tiene.append(i)
    o = a.copy()
    o[m, :3] = nuovi[dove][inv].astype(np.uint8)
    return o


def griglia(prof, passo):
    n = len(prof); best = None
    for p in np.arange(round(passo * 0.973, 2), round(passo * 1.027, 2), 0.005):
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
fogli = {}
for foglio, nome, (x0, y0, x1, y1), passo in ALBERI:
    if foglio not in fogli:
        fogli[foglio] = np.array(Image.open(os.path.join(QUI, 'fogli', foglio + '.jpg')).convert('RGB')).astype(float)
    im = fogli[foglio]
    H, W, _ = im.shape
    bianco = im.min(2) >= 222
    L = im.mean(2)
    # 1. i pixel veri
    a, b, c, d = max(0, y0 - 6), max(0, x0 - 6), min(H, y1 + 7), min(W, x1 + 7)
    C = im[a:c, b:d]; B = bianco[a:c, b:d]; Lc = L[a:c, b:d]
    px, fx = griglia(np.abs(np.diff(Lc, axis=1)).mean(0), passo)
    py, fy = griglia(np.abs(np.diff(Lc, axis=0)).mean(1), passo)
    mg = 0.7 if passo < 4 else 1.2      # il bordo del quadretto che non si guarda
    bx = np.arange(fx + 1 - px, d - b, px); by = np.arange(fy + 1 - py, c - a, py)
    o = np.zeros((len(by), len(bx), 4))
    for j in range(len(by)):
        for i in range(len(bx)):
            xa, xb = int(round(bx[i] + mg)), int(round(bx[i] + px - mg)); ya, yb = int(round(by[j] + mg)), int(round(by[j] + py - mg))
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
    # 5. i colori ravvivati
    if foglio in RAVVIVATI:
        fatto = ravviva(fatto)
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
