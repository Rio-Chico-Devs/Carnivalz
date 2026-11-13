# Le strade di Radenna dal foglio di Bru (strumenti/livelli/fogli/
# strade_radenna.jpg), pronte da posare sull'erba (art/livelli/terreni/).
#
#   python3 strumenti/livelli/strade_radenna.py        (serve numpy e Pillow)
#
# Per ogni pezzo:
#   1. i pixel veri (passo 2,93, come gli altri fogli) e via l'alone bianco del
#      foglio sul bordo;
#   2. i tratti dritti diventano ripetibili lungo la strada: un numero intero
#      di motivi a zig-zag (55 pixel in orizzontale, 73 in verticale), e la
#      cucitura dell'erba passa dove i due capi si somigliano di piu';
#   3. via l'erba del pezzo (piu' chiara di quella del prato, coi bordi
#      scuri: si vedrebbero i rettangoli): restano la pietra e due pixel di
#      ciuffi attorno, e sotto si vede il prato vero.
# Le strade sono larghe 29 pixel (coi cordoli); i bracci dell'incrocio in
# alto e in basso pure (colonne 60-88), quelli a sinistra e a destra 26
# (righe 53-78) e cominciano dopo 9 pixel d'erba: la strada orizzontale ci
# entra sopra di 2 pixel, con la riga 27 della strada sulla riga 65 del
# braccio.
# Scrive art/livelli/terreni/strade_radenna/<nome>.png.
import os
from collections import deque

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
FUORI = os.path.join(QUI, '..', '..', 'art', 'livelli', 'terreni', 'strade_radenna')
LUMA = np.array([0.3, 0.55, 0.15])
im = np.array(Image.open(os.path.join(QUI, 'fogli', 'strade_radenna.jpg')).convert('RGB')).astype(float)
H, W, _ = im.shape
BIANCO = im.min(2) >= 222
L = im.mean(2)

# nome, scatola nel foglio, quanto margine guardare attorno (le due strade
# orizzontali in alto sono attaccate: margine 1)
PEZZI = (
    ('strada_orizzontale', (25, 23, 366, 181), 1),
    ('strada_verticale', (386, 190, 542, 691), 6),
    ('incrocio', (565, 364, 997, 744), 6),
    ('anello_1', (1031, 23, 1202, 179), 6),       # i quarti di una piazza tonda:
    ('anello_2', (1223, 23, 1382, 179), 6),       # 1 2 sopra, 3 4 sotto, accostati
    ('anello_3', (1032, 199, 1202, 343), 6),
    ('anello_4', (1223, 199, 1381, 343), 6),
    ('quarto_1', (564, 23, 703, 179), 6),         # altri quarti di piazza
    ('quarto_2', (723, 23, 880, 178), 6),
    ('tratto_corto', (24, 574, 366, 691), 6),
    ('rovina_1', (1019, 363, 1191, 545), 6),
    ('rovina_2', (1211, 363, 1384, 545), 6),
    ('rovina_3', (1020, 571, 1190, 744), 6),
    ('muretto_angolo', (1211, 571, 1384, 744), 6),
)
# i tratti dritti: quanti pixel e' lungo il motivo (le prove), e il verso
DRITTI = {'strada_orizzontale': ([55, 110], 'x'), 'strada_verticale': ([49, 73, 98, 147], 'y')}


def griglia(prof):
    n = len(prof); best = None
    for p in np.arange(2.85, 3.01, 0.005):
        for f in np.arange(0, p, 0.1):
            i = np.round(np.arange(f, n - 1, p)).astype(int); i = i[(i >= 0) & (i < n)]
            sc = prof[i].mean()
            if best is None or sc > best[0]:
                best = (sc, p, f)
    return best[1], best[2]


def pixel_veri(x0, y0, x1, y1, margine):
    a, b, c, d = max(0, y0 - margine), max(0, x0 - margine), min(H, y1 + margine + 1), min(W, x1 + margine + 1)
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
    o = np.floor(o)
    ys, xs = np.nonzero(o[..., 3])
    return o[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def vicini4(y, x, h, w):
    return [(yy, xx) for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)) if 0 <= yy < h and 0 <= xx < w]


def togli_alone(o):
    o = o.copy(); h, w = o.shape[:2]
    for _ in range(2):
        m = o[..., 3] > 0
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
    # i puntini chiari soli dentro l'erba
    m = o[..., 3] > 0; lum = o[..., :3] @ LUMA
    for y, x in zip(*np.nonzero(m)):
        v = [lum[yy, xx] for yy, xx in vicini4(y, x, h, w) if m[yy, xx]]
        if len(v) >= 3 and lum[y, x] > max(v) + 60:
            o[y, x, :3] = np.median([o[yy, xx, :3] for yy, xx in vicini4(y, x, h, w) if m[yy, xx]], 0)
    return o


def taglio(e):
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
    return cam, float(c[-1].min())


def ciclico_x(T, N, O):
    # una tile larga N che si ripete in orizzontale: i primi O pixel sono la
    # continuazione del bordo destro fino al taglio piu' economico
    e = ((T[:, N:N + O].astype(float) - T[:, :O].astype(float)) ** 2).sum(-1)
    cam, costo = taglio(e)
    R = T[:, :N].copy()
    for y in range(T.shape[0]):
        R[y, :cam[y]] = T[y, N:N + cam[y]]
    return R, costo


def ripetibile(P, lunghezze, O=6):
    best = None
    for N in lunghezze:
        for s in range(0, P.shape[1] - N - O + 1):
            R, c = ciclico_x(P[:, s:s + N + O], N, O)
            if best is None or c < best[0]:
                best = (c, R)
    return best[1]


_M1 = np.array([[0.4122214708, 0.5363325363, 0.0514459929], [0.2119034982, 0.6806995451, 0.1073969566],
                [0.0883024619, 0.2817188376, 0.6299787005]])
_M2 = np.array([[0.2104542553, 0.7936177850, -0.0040720468], [1.9779984951, -2.4285922050, 0.4505937099],
                [0.0259040371, 0.7827717662, -0.8086757660]])


def in_lab(rgb):
    c = rgb / 255.0
    return np.cbrt(np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4) @ _M1.T) @ _M2.T


def allarga(m, k):
    for _ in range(k):
        p = np.pad(m, 1); m = m | p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:]
    return m


def stringi(m, k):
    for _ in range(k):
        p = np.pad(m, 1, constant_values=True); m = m & p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:]
    return m


def solo_pietra(o, frangia=2):
    # la pietra: grigia (poco croma) e non scura, con le fughe chiuse e senza
    # pezzetti sotto i 12 pixel; si tiene lei e `frangia` pixel attorno
    m = o[..., 3] > 0
    lab = in_lab(o[..., :3].reshape(-1, 3).astype(float)).reshape(o.shape[:2] + (3,))
    grigio = m & (np.hypot(lab[..., 1], lab[..., 2]) < 0.04) & (lab[..., 0] > 0.33)
    p = stringi(allarga(grigio, 2), 2) & m
    h, w = p.shape; vis = np.zeros_like(p); pietra = np.zeros_like(p)
    for y0, x0 in zip(*np.nonzero(p)):
        if vis[y0, x0]:
            continue
        q = deque([(y0, x0)]); vis[y0, x0] = True; cel = []
        while q:
            y, x = q.popleft(); cel.append((y, x))
            for yy, xx in vicini4(y, x, h, w):
                if p[yy, xx] and not vis[yy, xx]:
                    vis[yy, xx] = True; q.append((yy, xx))
        if len(cel) >= 12:
            for y, x in cel:
                pietra[y, x] = True
    r = o.copy(); r[~(allarga(pietra, frangia) & m)] = 0
    return r


os.makedirs(FUORI, exist_ok=True)
fatti = []
for nome, scatola, margine in PEZZI:
    o = pixel_veri(*scatola, margine)
    if nome in DRITTI:
        lunghezze, verso = DRITTI[nome]
        o = ripetibile(o, lunghezze) if verso == 'x' else ripetibile(o.transpose(1, 0, 2), lunghezze).transpose(1, 0, 2)
    o = solo_pietra(togli_alone(o)).astype(np.uint8)
    Image.fromarray(o).save(os.path.join(FUORI, nome + '.png'))
    fatti.append('%s %dx%d' % (nome, o.shape[1], o.shape[0]))
print('strade:', ', '.join(fatti))
