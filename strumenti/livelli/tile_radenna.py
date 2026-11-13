# Le tile del terreno di Radenna, ripetibili senza giunture, dal foglio di Bru
# (strumenti/livelli/fogli/tile_radenna.jpg).
#
#   python3 strumenti/livelli/tile_radenna.py        (serve numpy e Pillow)
#
# Nel foglio le tile non si ripetono bene: l'erba ha linee scure fra i
# quadrati, una fascia scura in fondo, luci e sassi dentro, e ogni quadrato e'
# piu' chiaro al centro; i ciottoli sono tagliati ai bordi. Qui:
#   1. si riporta il disegno ai suoi pixel veri (passo 2,93, come gli altri
#      fogli);
#   2. si tengono solo i pixel buoni (l'erba senza linee, luci e sassi);
#   3. si spiana la luce larga (i "cuscini"), tornando ai colori del disegno;
#   4. si cuce una tile nuova di 64x64 con pezzetti di 22x22 presi dal
#      disegno, su un toro (il bordo destro tocca il sinistro, quello di sotto
#      quello di sopra): ogni pezzo si attacca agli altri tagliando dove si
#      somigliano di piu' (nei ciottoli tagliare un sasso costa di piu', cosi'
#      i tagli passano sul muschio). Niente sfumature: solo pixel del disegno.
# Scrive art/livelli/terreni/erba_radenna.png e ciottoli_radenna.png.
import os

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
TERRENI = os.path.join(QUI, '..', '..', 'art', 'livelli', 'terreni')
LUMA = np.array([0.3, 0.55, 0.15])
im = np.array(Image.open(os.path.join(QUI, 'fogli', 'tile_radenna.jpg')).convert('RGB')).astype(float)
H, W, _ = im.shape
BIANCO = im.min(2) >= 222
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


def pixel_veri(x0, y0, x1, y1):
    a, b, c, d = max(0, y0 - 6), max(0, x0 - 6), min(H, y1 + 7), min(W, x1 + 7)
    C = im[a:c, b:d]; B = BIANCO[a:c, b:d]; Lc = L[a:c, b:d]
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
    return np.floor(o)          # colori interi, come in un PNG


def rettangolo_pieno(o):
    # il rettangolo piu' grande tutto pieno: si stringe il lato con piu' buchi
    m = o[..., 3] > 0
    ys, xs = np.nonzero(m); t, b, l, r = ys.min(), ys.max(), xs.min(), xs.max()
    while True:
        sub = m[t:b + 1, l:r + 1]
        if sub.all():
            return o[t:b + 1, l:r + 1]
        vuoti = {'t': (~sub[0]).sum(), 'b': (~sub[-1]).sum(), 'l': (~sub[:, 0]).sum(), 'r': (~sub[:, -1]).sum()}
        k = max(vuoti, key=vuoti.get)
        if k == 't': t += 1
        elif k == 'b': b -= 1
        elif k == 'l': l += 1
        else: r -= 1


def allarga(m, k):
    for _ in range(k):
        p = np.pad(m, 1); m = m | p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:]
    return m


def stringi(m):
    p = np.pad(m, 1)
    return m & p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:]


def sfoca(a, sigma):
    r = int(3 * sigma); k = np.exp(-0.5 * (np.arange(-r, r + 1) / sigma) ** 2); k /= k.sum()
    a = np.apply_along_axis(lambda v: np.convolve(np.pad(v, r, mode='edge'), k, 'valid'), 0, a)
    return np.apply_along_axis(lambda v: np.convolve(np.pad(v, r, mode='edge'), k, 'valid'), 1, a)


def spiana(rgb, ok, sigma, forza):
    lum = rgb @ LUMA
    w = ok.astype(float)
    locale = sfoca(lum * w, sigma) / np.maximum(sfoca(w, sigma), 1e-3)
    f = (np.median(locale[ok]) / np.maximum(locale, 1)) ** forza
    nuovo = np.clip(rgb * f[..., None], 0, 255)
    tav = np.unique(rgb[ok].astype(int), axis=0).astype(float)
    return tav[((nuovo[..., None, :] - tav[None, None]) ** 2).sum(-1).argmin(-1)]


def taglio(e):
    # il cammino dall'alto in basso che costa meno (una colonna per riga, che
    # si sposta di al piu' 1)
    h, w = e.shape
    c = e.copy(); da = np.zeros((h, w), int)
    for y in range(1, h):
        for x in range(w):
            lo, hi = max(0, x - 1), min(w, x + 2)
            k = lo + int(np.argmin(c[y - 1, lo:hi]))
            c[y, x] += c[y - 1, k]; da[y, x] = k
    cam = np.zeros(h, int); cam[-1] = int(np.argmin(c[-1]))
    for y in range(h - 1, 0, -1):
        cam[y - 1] = da[y, cam[y]]
    return cam


def cuci(src, ok, N, S, O, seme, tolleranza=0.6, distanza=10, peso=None, forza_peso=0.0):
    P = S + O
    n = N // S
    h, w = ok.shape
    cattivo = np.pad((~ok).astype(int), ((1, 0), (1, 0))).cumsum(0).cumsum(1)
    cand = [(y, x) for y in range(h - P + 1) for x in range(w - P + 1)
            if cattivo[y + P, x + P] - cattivo[y, x + P] - cattivo[y + P, x] + cattivo[y, x] == 0]
    pz = np.stack([src[y:y + P, x:x + P] for y, x in cand]).astype(float)
    if peso is None:
        peso = np.zeros(ok.shape)
    pp = np.stack([peso[y:y + P, x:x + P] for y, x in cand]).astype(float)
    out_p = np.zeros((N, N))
    rng = np.random.default_rng(seme)
    out = np.zeros((N, N, 3)); pieno = np.zeros((N, N), bool)
    pos = np.array(cand)
    usati = []
    for j in range(n):
        for i in range(n):
            ys = (j * S + np.arange(P)) % N; xs = (i * S + np.arange(P)) % N
            ex = out[np.ix_(ys, xs)]; kn = pieno[np.ix_(ys, xs)]
            # non si riusa un pezzo preso troppo vicino a uno gia' usato
            libero = np.ones(len(cand), bool)
            for u in usati:
                libero &= np.abs(pos - pos[u]).max(1) >= distanza
            if not libero.any():
                libero[:] = True
            if not kn.any():
                k = rng.choice(np.nonzero(libero)[0])
            else:
                err = (((pz - ex[None]) ** 2).sum(-1) * kn[None]).sum((1, 2)) / kn.sum()
                err[~libero] = np.inf
                k = rng.choice(np.nonzero(err <= err.min() * (1 + tolleranza) + 1e-6)[0])
            usati.append(k)
            nuovo = pz[k]
            prendi = np.ones((P, P), bool)
            exp_ = out_p[np.ix_(ys, xs)]
            if kn.any():
                e = ((nuovo - ex) ** 2).sum(-1) + forza_peso * (pp[k] + exp_)
                if kn[:, :O].all():                       # a sinistra c'e' gia'
                    cam = taglio(e[:, :O])
                    for y in range(P): prendi[y, :cam[y] + 1] = False
                if kn[:O, :].all():                       # sopra
                    cam = taglio(e[:O, :].T)
                    for x in range(P): prendi[:cam[x] + 1, x] = False
                if kn[:, P - O:].all():                   # a destra (il giro)
                    cam = taglio(e[:, P - O:])
                    for y in range(P): prendi[y, P - O + cam[y]:] = False
                if kn[P - O:, :].all():                   # sotto (il giro)
                    cam = taglio(e[P - O:, :].T)
                    for x in range(P): prendi[P - O + cam[x]:, x] = False
                prendi |= ~kn
            out[np.ix_(ys, xs)] = np.where(prendi[..., None], nuovo, ex)
            out_p[np.ix_(ys, xs)] = np.where(prendi, pp[k], exp_)
            pieno[np.ix_(ys, xs)] = True
    return out.astype(np.uint8)


os.makedirs(TERRENI, exist_ok=True)

# l'erba: il blocco grande, 3x3 quadrati
o = pixel_veri(20, 23, 454, 507)
assert o.shape[:2] == (170, 153), o.shape
rgb = o[..., :3]; r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
luce = (b > 80) & (b > r + 35) & (g > r + 35) & ((r + g + b) / 3 > 70)
sasso = ~((g > r + 6) & (g >= b - 2))
ok = (o[..., 3] > 0) & ~allarga(luce | sasso, 2)
for c0, c1 in ((0, 6), (46, 57), (95, 106), (145, 153)):        # le linee fra i quadrati, i bordi
    ok[:, c0:c1] = False
for r0, r1 in ((0, 6), (46, 58), (96, 108), (144, 170)):        # e la fascia scura in fondo
    ok[r0:r1, :] = False
erba = cuci(spiana(rgb, ok, 6.0, 0.7), ok, 64, 16, 6, seme=2)
Image.fromarray(erba).save(os.path.join(TERRENI, 'erba_radenna.png'))

# i ciottoli: la tile piccola, senza il bordino
o = rettangolo_pieno(pixel_veri(964, 574, 1138, 744))
rgb = o[..., :3]
ok = np.ones(o.shape[:2], bool)
ok[:1] = ok[-1:] = False; ok[:, :1] = ok[:, -1:] = False
piano = spiana(rgb, ok, 8.0, 0.5)
# il muschio: verde e saturo (in OKLab); il resto e' sasso, e pesa di piu'
# verso il centro del sasso
_M1 = np.array([[0.4122214708, 0.5363325363, 0.0514459929], [0.2119034982, 0.6806995451, 0.1073969566],
                [0.0883024619, 0.2817188376, 0.6299787005]])
_M2 = np.array([[0.2104542553, 0.7936177850, -0.0040720468], [1.9779984951, -2.4285922050, 0.4505937099],
                [0.0259040371, 0.7827717662, -0.8086757660]])
c = piano / 255.0
lab = np.cbrt(np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4) @ _M1.T) @ _M2.T
croma = np.hypot(lab[..., 1], lab[..., 2]); tinta = np.degrees(np.arctan2(lab[..., 2], lab[..., 1])) % 360
muschio = (croma > 0.07) & (tinta > 100) & (tinta < 160)
peso = (~muschio).astype(float); dentro = ~muschio
for _ in range(3):
    dentro = stringi(dentro); peso += dentro
ciottoli = cuci(piano, ok, 64, 16, 6, seme=2, distanza=6, peso=peso, forza_peso=3000.0)
Image.fromarray(ciottoli).save(os.path.join(TERRENI, 'ciottoli_radenna.png'))
print('terreni: erba_radenna 64x64, ciottoli_radenna 64x64')
