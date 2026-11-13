# Le rocce dal foglio di Bru (strumenti/livelli/fogli/rocce.jpg), una per
# file, pulite pixel per pixel.
#
#   python3 strumenti/livelli/rocce.py        (serve numpy e Pillow)
#
# Il foglio e' pixel art ingrandita circa 3 volte (fatta con l'AI: ogni sasso
# ha la sua griglia, un poco diversa). Per ogni sasso:
#   1. si separa dal fondo bianco; i pezzetti nella stessa casella della
#      griglia del foglio (10 colonne, 9 file) sono un oggetto solo (i
#      mucchietti di sassolini);
#   2. si cerca la sua griglia (il passo fra 2,7 e 3,3, e dove comincia) e si
#      riporta ai suoi pixel veri: ogni quadretto prende il colore mediano;
#   3. tutti su una tavolozza comune di 48 colori, via i pixel soli;
#   4. il contorno: via l'alone chiaro del JPG, e il bordo ripassato col
#      colore di contorno del sasso (un filo scuro continuo).
# Scrive art/livelli/pezzi/rocce/<nome>.png e le loro voci nel catalogo dei
# pezzi (art/livelli/pezzi/catalogo.json).
import json
import os
from collections import deque

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
PEZZI = os.path.join(QUI, '..', '..', 'art', 'livelli', 'pezzi')
im = np.array(Image.open(os.path.join(QUI, 'fogli', 'rocce.jpg')).convert('RGB')).astype(float)
H, W, _ = im.shape
pieno = im.min(2) < 228


def allarga(m, k):
    r = m.copy()
    for d in range(1, k + 1):
        r[d:] |= m[:-d]; r[:-d] |= m[d:]; r[:, d:] |= m[:, :-d]; r[:, :-d] |= m[:, d:]
    return r


# 1. i pezzetti, e le caselle del foglio
unito = allarga(pieno, 1)
vis = np.zeros_like(unito)
comp = []
for y0, x0 in zip(*np.nonzero(unito)):
    if vis[y0, x0]:
        continue
    q = deque([(y0, x0)]); vis[y0, x0] = True; ys = []; xs = []
    while q:
        y, x = q.popleft(); ys.append(y); xs.append(x)
        for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= yy < H and 0 <= xx < W and unito[yy, xx] and not vis[yy, xx]:
                vis[yy, xx] = True; q.append((yy, xx))
    if len(ys) > 25:
        comp.append((min(ys) + 1, min(xs) + 1, max(ys), max(xs)))
CENTRI_Y = np.array([48, 122, 193, 268, 347, 430, 508, 600, 700])
caselle = {}
for a, b, c, d in comp:
    col = int(round(((b + d) / 2 - 68) / 140.5)); riga = int(np.abs(CENTRI_Y - (a + c) / 2).argmin())
    caselle.setdefault((riga, col), []).append((a, b, c, d))
L = im.mean(2)


def griglia(prof):
    n = len(prof); best = None
    for p in np.arange(2.70, 3.30, 0.01):
        for f in np.arange(0, p, 0.25):
            i = np.round(np.arange(f, n - 1, p)).astype(int); i = i[(i >= 0) & (i < n)]
            sc = prof[i].mean()
            if best is None or sc > best[0]:
                best = (sc, p, f)
    return best[1], best[2]


# 2. ogni sasso ai suoi pixel veri
pezzi = []
for (riga, col), pz in sorted(caselle.items()):
    y0, x0 = min(p[0] for p in pz), min(p[1] for p in pz)
    y1, x1 = max(p[2] for p in pz) + 1, max(p[3] for p in pz) + 1
    a, b, c, d = max(0, y0 - 4), max(0, x0 - 4), min(H, y1 + 4), min(W, x1 + 4)
    C = im[a:c, b:d]; Lc = L[a:c, b:d]; P = pieno[a:c, b:d]
    px, fx = griglia(np.abs(np.diff(Lc, axis=1)).mean(0)); py, fy = griglia(np.abs(np.diff(Lc, axis=0)).mean(1))
    bx = np.arange(fx + 1 - px, d - b, px); by = np.arange(fy + 1 - py, c - a, py)
    out = np.zeros((len(by), len(bx), 4))
    for j in range(len(by)):
        for i in range(len(bx)):
            xa, xb = int(round(bx[i] + 0.6)), int(round(bx[i] + px - 0.6)); ya, yb = int(round(by[j] + 0.6)), int(round(by[j] + py - 0.6))
            xa, ya = max(0, xa), max(0, ya); xb, yb = min(d - b, max(xa + 1, xb)), min(c - a, max(ya + 1, yb))
            q = C[ya:yb, xa:xb].reshape(-1, 3); pq = P[ya:yb, xa:xb].reshape(-1)
            if len(q) == 0 or pq.mean() < 0.5:
                continue
            out[j, i, :3] = np.median(q[pq], 0); out[j, i, 3] = 255
    ys, xs = np.nonzero(out[..., 3])
    pezzi.append((riga, col, out[ys.min():ys.max() + 1, xs.min():xs.max() + 1]))

# 3. la tavolozza comune (k-medie++, 48 colori) e i pixel soli
X = np.concatenate([p[2][p[2][..., 3] > 0][:, :3] for p in pezzi])
rng = np.random.default_rng(2); K = 48
cen = [X[rng.integers(len(X))]]
for _ in range(K - 1):
    dd = np.min(((X[:, None] - np.array(cen)[None]) ** 2).sum(2), 1)
    cen.append(X[rng.choice(len(X), p=dd / dd.sum())])
cen = np.array(cen, float)
for _ in range(40):
    l = ((X[:, None] - cen[None]) ** 2).sum(2).argmin(1)
    cen = np.array([X[l == q].mean(0) if (l == q).any() else cen[q] for q in range(K)])
TAV = np.round(cen)

FAMIGLIE = {1: 'sasso', 2: 'sasso_spigoloso', 3: 'masso', 4: 'masso_basso', 5: 'masso_muschio', 6: 'lastrone',
            8: 'roccione'}
cartella = os.path.join(PEZZI, 'rocce'); os.makedirs(cartella, exist_ok=True)
conta = {}
voci = {}
for riga, col, a in pezzi:
    fam = ('sassolino' if col < 4 else 'mucchietto') if riga == 0 else ('disco' if col < 4 else 'guglia') if riga == 7 \
        else FAMIGLIE[riga]
    conta[fam] = conta.get(fam, 0) + 1
    nome = '%s_%d' % (fam, conta[fam])
    h, w = a.shape[:2]; m = a[..., 3] > 0
    q = np.full((h, w), -1)
    q[m] = ((a[m][:, None, :3] - TAV[None]) ** 2).sum(2).argmin(1)
    r = q.copy()
    for y in range(h):
        for x in range(w):
            if q[y, x] < 0:
                continue
            v = [q[y + dy, x + dx] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
                 if 0 <= x + dx < w and 0 <= y + dy < h and q[y + dy, x + dx] >= 0]
            if len(v) == 4 and q[y, x] not in v:
                piu = max(set(v), key=v.count)
                if v.count(piu) >= 3:
                    r[y, x] = piu
    o = np.zeros((h, w, 4), np.uint8)
    o[r >= 0, :3] = TAV[r[r >= 0]]; o[r >= 0, 3] = 255
    # 4. il contorno: un filo scuro continuo. Il colore di contorno del sasso
    # e' quello dei suoi pixel di bordo piu' scuri; i pixel di bordo chiari
    # che hanno dentro un vicino gia' scuro sono alone (via), gli altri pixel
    # di bordo si ripassano col colore di contorno
    def bordo(m):
        pad = np.pad(m, 1)
        return m & (~pad[:-2, 1:-1] | ~pad[2:, 1:-1] | ~pad[1:-1, :-2] | ~pad[1:-1, 2:])
    # solo i pezzi di almeno 20 pixel: i sassolini piccoli (nei mucchietti)
    # restano coi loro colori, se no il contorno li coprirebbe tutti
    piccoli = np.zeros(o.shape[:2], bool)
    vis_ = np.zeros(o.shape[:2], bool)
    for yy, xx in zip(*np.nonzero(o[..., 3] > 0)):
        if vis_[yy, xx]:
            continue
        coda = deque([(yy, xx)]); vis_[yy, xx] = True; celle = []
        while coda:
            cy, cx = coda.popleft(); celle.append((cy, cx))
            for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                if 0 <= ny < h and 0 <= nx < w and o[ny, nx, 3] > 0 and not vis_[ny, nx]:
                    vis_[ny, nx] = True; coda.append((ny, nx))
        if len(celle) < 20:
            for cy, cx in celle:
                piccoli[cy, cx] = True
    salva = o[piccoli].copy()
    lum = o[..., :3].astype(int).mean(2)
    m = (o[..., 3] > 0) & ~piccoli
    if not m.any():
        m = o[..., 3] > 0
    b = bordo(m)
    soglia = np.percentile(lum[b], 35)
    scuri = b & (lum <= soglia)
    contorno = np.median(o[scuri][:, :3], 0)
    contorno = TAV[((TAV - contorno) ** 2).sum(1).argmin()]
    for _ in range(3):
        m = (o[..., 3] > 0) & ~piccoli
        b = bordo(m)
        lum = o[..., :3].astype(int).mean(2)
        scuro = m & (lum <= soglia + 12)
        pad = np.pad(scuro, 1)
        dentro_scuro = pad[:-2, 1:-1] | pad[2:, 1:-1] | pad[1:-1, :-2] | pad[1:-1, 2:]
        via = b & (lum > soglia + 30) & dentro_scuro
        if not via.any():
            break
        o[via] = 0
    # il bordo liscio: via le spine (pixel con un solo vicino pieno), piene
    # le tacche (pixel vuoti con tre vicini pieni)
    for _ in range(3):
        m = (o[..., 3] > 0) & ~piccoli
        pad = np.pad(m, 1).astype(int)
        vicini = pad[:-2, 1:-1] + pad[2:, 1:-1] + pad[1:-1, :-2] + pad[1:-1, 2:]
        spine = m & (vicini <= 1)
        tacche = ~m & ~piccoli & (vicini >= 3)
        if not spine.any() and not tacche.any():
            break
        o[spine] = 0
        o[tacche, :3] = contorno
        o[tacche, 3] = 255
    m = (o[..., 3] > 0) & ~piccoli
    o[bordo(m), :3] = contorno
    o[piccoli] = salva
    ys, xs = np.nonzero(o[..., 3]); o = o[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    Image.fromarray(o).save(os.path.join(cartella, nome + '.png'))
    voci[nome] = {"file": "rocce/%s.png" % nome, "misura": [o.shape[1], o.shape[0]], "piede": [o.shape[1] // 2, o.shape[0] - 2]}

percorso = os.path.join(PEZZI, 'catalogo.json')
catalogo = json.load(open(percorso)) if os.path.exists(percorso) else {"pezzi": {}}
catalogo["pezzi"] = {k: v for k, v in catalogo["pezzi"].items() if not v["file"].startswith('rocce/')}
catalogo["pezzi"].update(voci)
with open(percorso, 'w') as f:
    json.dump(catalogo, f, indent=1, ensure_ascii=False, sort_keys=True)
    f.write('\n')
print('rocce:', len(voci))
