# Il ruscello di Radenna: una pianura aperta, col ruscello, la strada, il ponte e le rovine.
#
#   python3 strumenti/livelli/ruscello_radenna.py [anteprima.png]      (serve numpy e Pillow)
#   poi: godot prove/LivelloProva.tscn -- livello ruscello
#
# Bru: «dovrebbe essere una pianura, la scena un po' piu' ampia, ci vuole piu' spazio». Quindi 1280x720 (due
# schermate per due), quasi tutta prato come nel suo disegno delle pianure: macchie d'erba piu' chiare e piu'
# scure, un ruscello che serpeggia a S con le sponde di ciottoli, una strada che curva e lo passa su un ponte,
# una piazza antica, uno stagno, alberi a gruppi sui bordi, grandi spazi aperti in mezzo.
#
# Prima il TERRENO, poi gli OGGETTI. Il terreno e' una pianta delle altezze proiettata in vista 3/4 (il prato a 0,
# l'acqua a -10: la sponda di la' si vede di faccia, quella di qua e' un ciglio). Le forme sono curve morbide:
# il ruscello e la strada sono linee (spline) con la loro larghezza; la strada e' il motivo del kit di Bru
# piegato lungo la curva, col cordolo in luce sempre dalla parte della luce (in alto a sinistra).
#
# Materiali e pezzi dai fogli di Bru: l'erba di Radenna, i ciottoli muschiosi (tile_radenna) per le sponde, la
# piazza a nove lastre (tile_radenna), l'acqua della vasca col filo chiaro lungo i bordi, il bordo della vasca
# per le spallette del ponte, i pezzi delle pianure di Radenna (vasca, vasche a gradini, ninfee, canne, pozza
# coi sassi, colonna). L'acqua e le piante luminose bagnano di turchese l'erba vicina.
#
# Scrive art/livelli/ruscello.png (il terreno, con le cose piatte), ruscello_pezzi.json (le cose in piedi, che il
# gioco mette insieme a lei in ordine di piede), ruscello_passi.png (dove si cammina) e ruscello.json; e i pezzi
# nuovi in art/livelli/pezzi/ruscello/, i terreni in art/livelli/terreni/.
import json
import os
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageDraw

QUI = os.path.dirname(os.path.abspath(__file__))
LIV = os.path.join(QUI, '..', '..', 'art', 'livelli')
TER = os.path.join(LIV, 'terreni')
PEZ = os.path.join(LIV, 'pezzi')
NUOVI = os.path.join(PEZ, 'ruscello')
FOGLIO = os.path.join(QUI, 'fogli', 'tile_radenna.jpg')
W, H = 1280, 720
ERBA, ACQUA, STRADA, RIVA, PONTE, SPALLA, SCALA, PALO = 1, 2, 3, 4, 5, 6, 7, 9
VERDI = np.array([(3, 47, 32), (5, 56, 34), (6, 62, 35), (8, 67, 35), (12, 72, 35), (14, 78, 35), (20, 83, 35),
                  (25, 89, 35), (34, 97, 38), (44, 106, 42), (64, 112, 60)], float)
P = np.array([(30, 40, 33), (44, 71, 50), (66, 84, 69), (84, 103, 85), (108, 122, 105), (120, 135, 117),
              (141, 155, 135), (163, 176, 155)], float)
AQ = np.array([(1, 119, 127), (2, 133, 136), (2, 156, 149), (1, 182, 168), (2, 213, 192), (2, 231, 204),
               (18, 242, 218), (79, 253, 237), (117, 255, 252), (210, 255, 250)], float)
FONDO = -10          # l'acqua del ruscello: 10 pixel sotto il prato


# ================================================================ dal foglio di Bru, ai pixel veri

_im = np.array(Image.open(FOGLIO).convert('RGB')).astype(float)
_BIANCO = _im.min(2) >= 222
_L = _im.mean(2)


def _griglia(prof):
    n = len(prof); best = None
    for p in np.arange(2.85, 3.01, 0.005):
        for f in np.arange(0, p, 0.1):
            i = np.round(np.arange(f, n - 1, p)).astype(int); i = i[(i >= 0) & (i < n)]
            sc = prof[i].mean()
            if best is None or sc > best[0]:
                best = (sc, p, f)
    return best[1], best[2]


def pixel_veri(x0, y0, x1, y1):
    # il disegno riportato ai suoi pixel (passo ~2,93): la mediana di ogni quadretto, niente medie sfocate
    hh, ww = _im.shape[:2]
    a, b, c, d = max(0, y0 - 6), max(0, x0 - 6), min(hh, y1 + 7), min(ww, x1 + 7)
    C = _im[a:c, b:d]; B = _BIANCO[a:c, b:d]; Lc = _L[a:c, b:d]
    px, fx = _griglia(np.abs(np.diff(Lc, axis=1)).mean(0)); py, fy = _griglia(np.abs(np.diff(Lc, axis=0)).mean(1))
    bx = np.arange(fx + 1 - px, d - b, px); by = np.arange(fy + 1 - py, c - a, py)
    o = np.zeros((len(by), len(bx), 4))
    for j in range(len(by)):
        for i in range(len(bx)):
            xa, xb = int(round(bx[i] + 0.7)), int(round(bx[i] + px - 0.7))
            ya, yb = int(round(by[j] + 0.7)), int(round(by[j] + py - 0.7))
            xa, ya = max(0, xa), max(0, ya); xb, yb = min(d - b, max(xa + 1, xb)), min(c - a, max(ya + 1, yb))
            q = C[ya:yb, xa:xb].reshape(-1, 3); bq = B[ya:yb, xa:xb].reshape(-1)
            if len(q) == 0 or bq.mean() >= 0.5:
                continue
            o[j, i, :3] = np.median(q[~bq], 0); o[j, i, 3] = 255
    return np.floor(o)


def _taglio(e):
    h, w = e.shape
    c = e.copy(); da = np.zeros((h, w), int)
    for y in range(1, h):
        for x in range(w):
            lo, hi = max(0, x - 1), min(w, x + 2)
            k = lo + int(np.argmin(c[y - 1, lo:hi])); c[y, x] += c[y - 1, k]; da[y, x] = k
    cam = np.zeros(h, int); cam[-1] = int(np.argmin(c[-1]))
    for y in range(h - 1, 0, -1):
        cam[y - 1] = da[y, cam[y]]
    return cam


def cuci(src, N, S, O, seme, tolleranza=0.25, distanza=24):
    # una trama N x N ripetibile, cucita con pezzi del disegno attaccati dove si somigliano di piu' (su un toro)
    P_ = S + O; n = N // S; h, w = src.shape[:2]
    cand = [(y, x) for y in range(h - P_ + 1) for x in range(w - P_ + 1)]
    pz = np.stack([src[y:y + P_, x:x + P_] for y, x in cand]).astype(float); pos = np.array(cand)
    rng = np.random.default_rng(seme)
    out = np.zeros((N, N, 3)); pieno = np.zeros((N, N), bool); usati = []
    for j in range(n):
        for i in range(n):
            ys = (j * S + np.arange(P_)) % N; xs = (i * S + np.arange(P_)) % N
            ex = out[np.ix_(ys, xs)]; kn = pieno[np.ix_(ys, xs)]
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
            nuovo = pz[k]; prendi = np.ones((P_, P_), bool)
            if kn.any():
                e = ((nuovo - ex) ** 2).sum(-1)
                if kn[:, :O].all():
                    cam = _taglio(e[:, :O])
                    for y in range(P_): prendi[y, :cam[y] + 1] = False
                if kn[:O, :].all():
                    cam = _taglio(e[:O, :].T)
                    for x in range(P_): prendi[:cam[x] + 1, x] = False
                if kn[:, P_ - O:].all():
                    cam = _taglio(e[:, P_ - O:])
                    for y in range(P_): prendi[y, P_ - O + cam[y]:] = False
                if kn[P_ - O:, :].all():
                    cam = _taglio(e[P_ - O:, :].T)
                    for x in range(P_): prendi[P_ - O + cam[x]:, x] = False
                prendi |= ~kn
            out[np.ix_(ys, xs)] = np.where(prendi[..., None], nuovo, ex)
            pieno[np.ix_(ys, xs)] = True
    return out.astype(np.uint8)


def _oklab(rgb):
    c = rgb / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    l = 0.4122214708 * c[..., 0] + 0.5363325363 * c[..., 1] + 0.0514459929 * c[..., 2]
    m = 0.2119034982 * c[..., 0] + 0.6806995451 * c[..., 1] + 0.1073969566 * c[..., 2]
    s = 0.0883024619 * c[..., 0] + 0.2817188376 * c[..., 1] + 0.6299787005 * c[..., 2]
    l, m, s = np.cbrt(l), np.cbrt(m), np.cbrt(s)
    return np.stack([0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
                     1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
                     0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s], -1)


def _salva(a, percorso):
    os.makedirs(os.path.dirname(percorso), exist_ok=True)
    Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), 'RGBA' if a.shape[-1] == 4 else 'RGB').save(percorso)


def _pianta_staccata(o):
    # una piantina del foglio senza l'erba intorno: si tiene il pezzo piu' grande non verde, col bordo scurito
    lab = _oklab(o[..., :3])
    h = np.degrees(np.arctan2(lab[..., 2], lab[..., 1])); C = np.hypot(lab[..., 1], lab[..., 2])
    pianta = (o[..., 3] > 0) & ~((h > 115) & (h < 170) & (C > 0.04))
    hh, ww = pianta.shape; ide = np.zeros((hh, ww), int); k = 0; quanti = {}
    for y in range(hh):
        for x in range(ww):
            if pianta[y, x] and ide[y, x] == 0:
                k += 1; q = deque([(y, x)]); ide[y, x] = k; n = 0
                while q:
                    cy, cx = q.popleft(); n += 1
                    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        ny, nx = cy + dy, cx + dx
                        if 0 <= ny < hh and 0 <= nx < ww and pianta[ny, nx] and ide[ny, nx] == 0:
                            ide[ny, nx] = k; q.append((ny, nx))
                quanti[k] = n
    tieni = ide == max(quanti, key=quanti.get)
    out = np.zeros_like(o); out[tieni] = o[tieni]; out[tieni, 3] = 255
    ys, xs = np.nonzero(tieni); out = out[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    m = out[..., 3] > 0; p = np.pad(m, 1)
    bordo = m & ~(p[2:, 1:-1] & p[:-2, 1:-1] & p[1:-1, 2:] & p[1:-1, :-2])
    out[bordo, :3] = np.minimum(out[bordo, :3], out[bordo, :3] * 0.6 + 6)
    return out


def _luce(x0, y0, x1, y1):
    o = pixel_veri(x0, y0, x1, y1)
    r, g, b = o[..., 0], o[..., 1], o[..., 2]
    m = (b > r + 50) & (g > 120) & (b > 110) & (o[..., 3] > 0)
    out = np.zeros_like(o); out[m] = o[m]; out[m, 3] = 255
    ys, xs = np.nonzero(m)
    return out[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def prepara():
    # i terreni e i pezzi nuovi presi dai fogli di Bru (sempre uguali: niente caso senza seme)
    vasca = pixel_veri(940, 20, 1392, 512)                       # la vasca intera: cornice e acqua (173x159)
    _salva(vasca, os.path.join(TER, 'vasca_radenna.png'))
    acqua = cuci(vasca[33:148, 18:138, :3], 192, 32, 10, seme=4) # la sua acqua, ripetibile 192x192
    _salva(acqua, os.path.join(TER, 'acqua_radenna.png'))
    luci = [_luce(53, 39, 120, 128), _luce(338, 350, 384, 380), _luce(336, 108, 357, 128), _luce(119, 415, 138, 434)]
    for k, l in enumerate(luci):
        _salva(l, os.path.join(NUOVI, 'luce_%d.png' % k))
    bulbi = _pianta_staccata(pixel_veri(470, 570, 640, 745))
    baccelli = _pianta_staccata(pixel_veri(1210, 570, 1385, 745))[:-3]
    _salva(bulbi, os.path.join(NUOVI, 'bulbi.png'))
    _salva(baccelli, os.path.join(NUOVI, 'baccelli.png'))
    _salva(baccelli[:, ::-1], os.path.join(NUOVI, 'baccelli_s.png'))
    # il cespuglione coi verdi del prato di Radenna (per luce), un poco piu' chiaro in cima
    a = np.asarray(Image.open(os.path.join(PEZ, 'alberi', 'cespuglione.png')).convert('RGBA')).astype(float)
    m = a[..., 3] > 0; lum = a[..., :3] @ np.array([0.3, 0.55, 0.15])
    q = np.zeros_like(lum); v = np.sort(lum[m]); q[m] = np.searchsorted(v, lum[m]) / len(v)
    rampa = np.array([(4, 30, 26), (5, 46, 32), (8, 62, 36), (14, 78, 38), (24, 92, 40), (38, 106, 44),
                      (58, 122, 52), (88, 142, 66)], float)
    k = np.clip((q * len(rampa)).astype(int), 0, len(rampa) - 1)
    verde = a.copy(); verde[m, :3] = rampa[k[m]]
    _salva(verde, os.path.join(NUOVI, 'cespuglione_verde.png'))
    _salva(verde[:, ::-1], os.path.join(NUOVI, 'cespuglione_verde_s.png'))
    f = np.asarray(Image.open(os.path.join(PEZ, 'alberi', 'albero_funghi.png')).convert('RGBA'))
    _salva(f[:, ::-1].astype(float), os.path.join(NUOVI, 'albero_funghi_s.png'))
    # le canne: gli steli in piedi (pezzo), il piede d'acqua e muschio va dipinto sull'acqua
    c = np.asarray(Image.open(os.path.join(PEZ, 'radenna', 'canne_luminose.png')).convert('RGBA')).astype(float)
    _salva(c[:-28], os.path.join(NUOVI, 'canne_steli.png'))
    _salva(c[:-28, ::-1], os.path.join(NUOVI, 'canne_steli_s.png'))


# ================================================================ forme e rumore

def liscio(hh, ww, scala, seme):
    g = np.random.default_rng(seme).random((hh // scala + 3, ww // scala + 3))
    big = Image.fromarray((g * 255).astype(np.uint8)).resize(((ww // scala + 3) * scala, (hh // scala + 3) * scala),
                                                             Image.BICUBIC)
    return np.asarray(big)[:hh, :ww] / 255.0


# ================================================================ il motore a piani

class Terreno:
    def __init__(self, base=110, sotto=110):
        self.B = base; self.HG = H + base + sotto
        self.Z = np.zeros((self.HG, W), np.int32); self.M = np.zeros((self.HG, W), np.int32)

    def zona(self, poligono, z, mat):
        # una zona in coordinate di terreno (la pianta vista da sopra)
        im = Image.new('L', (W, self.HG), 0)
        ImageDraw.Draw(im).polygon([(x, y + self.B) for x, y in poligono], fill=255)
        m = np.asarray(im) > 0
        self.Z[m] = z; self.M[m] = mat

    def gradini(self, x0, x1, y_alto, y_basso, z_alto, z_basso, passi):
        n = y_basso - y_alto
        for k in range(passi):
            r0 = y_alto + (k * n) // passi; r1 = y_alto + ((k + 1) * n) // passi
            self.Z[r0 + self.B:r1 + self.B, x0:x1] = z_alto - ((k + 1) * (z_alto - z_basso)) // passi
            self.M[r0 + self.B:r1 + self.B, x0:x1] = SCALA

    def proietta(self):
        # da nord a sud: il pavimento di ogni riga va z pixel piu' su; se la riga dopo e' piu' bassa, c'e' una parete
        HS = H + self.B
        tipo = np.zeros((HS, W), np.int8); gy = np.full((HS, W), -1, np.int32); zb = np.zeros((HS, W), np.int32)
        mb = np.zeros((HS, W), np.int32); fd = np.zeros((HS, W), np.int32); fh = np.zeros((HS, W), np.int32)
        for x in range(W):
            for g in range(self.HG):
                z = self.Z[g, x]; sy = g - z
                if 0 <= sy < HS:
                    tipo[sy, x] = 1; gy[sy, x] = g; zb[sy, x] = z; mb[sy, x] = self.M[g, x]
                if g + 1 < self.HG and self.Z[g + 1, x] < z:
                    alto = z - self.Z[g + 1, x]
                    for d in range(alto):
                        s2 = sy + 1 + d
                        if 0 <= s2 < HS:
                            tipo[s2, x] = 2; gy[s2, x] = g; zb[s2, x] = z; mb[s2, x] = self.M[g, x]
                            fd[s2, x] = d; fh[s2, x] = alto
        sl = slice(self.B, self.B + H)
        return dict(tipo=tipo[sl], gy=gy[sl], z=zb[sl], m=mb[sl], fd=fd[sl], fh=fh[sl])


def _corsa(m):
    # per ogni pixel vero, quanti veri di fila ci sono sopra di lui, lui compreso (fuori dall'immagine conta vero)
    d = np.zeros(m.shape, int); run = np.full(m.shape[1], 99)
    for y in range(m.shape[0]):
        run = np.where(m[y], run + 1, 0); d[y] = run
    return d


def _posa(out, a, x0, y0):
    for j in range(a.shape[0]):
        for i in range(a.shape[1]):
            y, x = y0 + j, x0 + i
            if 0 <= y < H and 0 <= x < W and a[j, i, 3] > 0:
                out[y, x] = a[j, i, :3]


def _e_acqua_del_pezzo(c):
    r, g, b = c[0], c[1], c[2]
    return g > r + 40 and b > 0.72 * g and b < g + 10 and b > 90


def _sfoca(a, r):
    # media su un quadrato di lato 2r+1, due volte (quasi una campana)
    for _ in range(2):
        p = np.pad(a, r, mode='edge'); c = p.cumsum(0).cumsum(1)
        c = np.pad(c, ((1, 0), (1, 0)))
        n = 2 * r + 1
        a = (c[n:, n:] - c[:-n, n:] - c[n:, :-n] + c[:-n, :-n]) / (n * n)
    return a


# le luci in piedi che bagnano il terreno di turchese: (x, y, forza, raggio)
SORGENTI = ([(470, 205, 1.0, 26), (562, 256, 0.75, 22), (132, 296, 0.75, 22), (506, 352, 0.45, 26),
             (528, 92, 0.55, 14), (404, 394, 0.55, 14)] +
            [(x, y - 4, 0.5, 11) for (x, y) in ((118, 352), (134, 360), (372, 296), (58, 184), (600, 228))])


# ================================================================ i materiali nuovi della pianura

def _pezzi(m):
    # i pezzi connessi di una maschera: per ognuno i pixel (y, x)
    hh, ww = m.shape; ide = np.zeros((hh, ww), int); tutti = []
    for y in range(hh):
        for x in range(ww):
            if m[y, x] and ide[y, x] == 0:
                ide[y, x] = len(tutti) + 1; q = deque([(y, x)]); pix = []
                while q:
                    cy, cx = q.popleft(); pix.append((cy, cx))
                    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        ny, nx = cy + dy, cx + dx
                        if 0 <= ny < hh and 0 <= nx < ww and m[ny, nx] and ide[ny, nx] == 0:
                            ide[ny, nx] = len(tutti) + 1; q.append((ny, nx))
                tutti.append(np.array(pix))
    return tutti


def _senza_erba(o):
    # un pezzo del foglio senza l'erba intorno (e fra le lastre): restano pietra e sassi; via anche il bordo
    # scuro del riquadro del foglio (pezzi sottili lungo i lati) e i puntini bianchi del fondo
    lab = _oklab(o[..., :3])
    h = np.degrees(np.arctan2(lab[..., 2], lab[..., 1])); C = np.hypot(lab[..., 1], lab[..., 2])
    erba = (h > 105) & (h < 175) & (C > 0.045)
    out = o.copy(); out[erba | (o[..., 3] == 0) | (o[..., :3].min(2) > 200)] = 0
    ys, xs = np.nonzero(out[..., 3] > 0)
    out = out[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    hh, ww = out.shape[:2]
    # il bordo del riquadro del foglio: i pixel scuri lungo i lati e la fascia d'erba scura in fondo
    scuro = out[..., :3].max(2) < 62
    Y, X = np.mgrid[0:hh, 0:ww]
    out[scuro & ((Y >= hh - 16) | (X <= 3) | (X >= ww - 4) | (Y <= 3))] = 0
    for pix in _pezzi(out[..., 3] > 0):
        ys, xs = pix[:, 0], pix[:, 1]
        sottile = min(ys.max() - ys.min(), xs.max() - xs.min()) <= 3
        bordo = ys.min() <= 4 or xs.min() <= 4 or ys.max() >= hh - 5 or xs.max() >= ww - 5
        if (sottile and bordo) or len(pix) < 4:
            out[ys, xs] = 0
    ys, xs = np.nonzero(out[..., 3] > 0)
    return out[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def prepara_pianura():
    # i ciottoli delle sponde ci sono gia': terreni/ciottoli_radenna.png, di strumenti/livelli/tile_radenna.py
    prepara()
    _salva(_senza_erba(pixel_veri(470, 15, 925, 515)), os.path.join(TER, 'piazza_radenna.png'))   # la piazza


# ================================================================ curve

def curva(punti, passo=1.0):
    # una spline che passa per i punti (Catmull-Rom), ricampionata a un pixel: i punti e la strada fatta
    p = np.array(punti, float)
    p = np.vstack([2 * p[0] - p[1], p, 2 * p[-1] - p[-2]])
    fitti = []
    for i in range(1, len(p) - 2):
        p0, p1, p2, p3 = p[i - 1], p[i], p[i + 1], p[i + 2]
        n = int(np.linalg.norm(p2 - p1) * 3) + 2
        t = np.linspace(0, 1, n, endpoint=False)[:, None]
        fitti.append(0.5 * (2 * p1 + (p2 - p0) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t ** 2
                            + (3 * p1 - p0 - 3 * p2 + p3) * t ** 3))
    fitti.append(p[-2][None])
    f = np.vstack(fitti)
    s = np.concatenate([[0], np.cumsum(np.linalg.norm(np.diff(f, axis=0), axis=1))])
    u = np.arange(0, s[-1], passo)
    return np.stack([np.interp(u, s, f[:, 0]), np.interp(u, s, f[:, 1])], 1), u


def campo(linea, u, raggio, hg, b):
    # per ogni pixel del terreno vicino alla linea: la distanza, la strada fatta lungo la linea fin li', e da che
    # parte sta (positivo a destra di chi la percorre)
    D = np.full((hg, W), np.inf); S = np.zeros((hg, W)); V = np.zeros((hg, W))
    tg = np.gradient(linea, axis=0); tg /= np.linalg.norm(tg, axis=1)[:, None] + 1e-9
    for k in range(len(linea)):
        px, py = linea[k, 0], linea[k, 1] + b
        x0, x1 = max(0, int(px - raggio)), min(W, int(px + raggio) + 2)
        y0, y1 = max(0, int(py - raggio)), min(hg, int(py + raggio) + 2)
        if x0 >= x1 or y0 >= y1:
            continue
        dx = np.arange(x0, x1)[None, :] - px; dy = np.arange(y0, y1)[:, None] - py
        d2 = dx * dx + dy * dy
        sub = D[y0:y1, x0:x1]; m = d2 < sub
        if m.any():
            sub[m] = d2[m]
            S[y0:y1, x0:x1][m] = u[k]
            V[y0:y1, x0:x1][m] = (tg[k, 0] * dy - tg[k, 1] * dx)[m]
    return np.sqrt(D), S, V


def rumore1(n, scala, seme):
    v = np.random.default_rng(seme).random(int(n / scala) + 3)
    x = np.arange(n) / scala; i = x.astype(int); f = x - i; f = f * f * (3 - 2 * f)
    return v[i] * (1 - f) + v[i + 1] * f


def _distanza(m, kmax):
    # quanti passi dalla maschera (a croce e in diagonale a passi alterni: quasi tondo), fino a kmax
    d = np.full(m.shape, kmax + 1, int); d[m] = 0; f = m.copy()
    for k in range(1, kmax + 1):
        g = f.copy()
        g[1:] |= f[:-1]; g[:-1] |= f[1:]; g[:, 1:] |= f[:, :-1]; g[:, :-1] |= f[:, 1:]
        if k % 2 == 0:
            g[1:, 1:] |= f[:-1, :-1]; g[1:, :-1] |= f[:-1, 1:]; g[:-1, 1:] |= f[1:, :-1]; g[:-1, :-1] |= f[1:, 1:]
        d[g & ~f] = k; f = g
    return d


def _chiudi(m, k):
    # chiusura: allarga di k e poi stringe di k (riempie le fughe fra le lastre)
    d = _distanza(m, k) <= k
    return ~(_distanza(~d, k) <= k)


# ================================================================ la pianta

# il ruscello: entra in alto a destra, scende a S e se ne va a sinistra; mezza larghezza nei punti
FIUME = [(1062, -70), (1034, 26), (972, 116), (866, 188), (744, 226), (622, 244), (522, 280), (452, 350),
         (414, 438), (334, 514), (208, 556), (82, 572), (-80, 578)]
LARGHI = [23, 23, 25, 27, 28, 28, 30, 32, 31, 29, 28, 27, 27]
STAGNO = (416, 320, 72, 46)          # lo stagno sulla curva di fuori: centro e raggi (si fonde col ruscello)
# la strada: arriva dal basso (dall'atterraggio), attraversa la piazza dritta nel mezzo, passa il ponte (dritta
# sull'acqua) e sale in alto
VIA = [(604, 800), (612, 700), (646, 622), (650, 600), (650, 505), (650, 410), (654, 388), (684, 346),
       (700, 300), (700, 260), (700, 220), (700, 180), (694, 128), (662, 70), (612, 10), (590, -80)]
RX = 686                              # il ponte: la strada dritta sull'acqua, x 686..714
PIAZZA = (650, 505)                   # il centro della piazza antica (nove lastre del foglio di Bru)


def pianta():
    t = Terreno(base=40, sotto=40)
    hg, b = t.HG, t.B
    t.Z[:] = 0; t.M[:] = ERBA
    lin, u = curva(FIUME)
    D, S, V = campo(lin, u, 70, hg, b)
    uc = [u[np.argmin(((lin - np.array(p, float)) ** 2).sum(1))] for p in FIUME]
    w = np.interp(S, uc, LARGHI) + (rumore1(int(u[-1]) + 2, 23, 5)[S.astype(int)] - 0.5) * 3
    # lo stagno: un'ellisse un po' storta, fusa col ruscello con un raccordo morbido (unione liscia delle distanze)
    cx, cy, rx, ry = STAGNO
    Y, X = np.mgrid[0:hg, 0:W]; gy = Y - b
    ang = np.arctan2((gy - cy) / ry, (X - cx) / rx)
    r = 1 + (rumore1(400, 37, 9)[((ang + np.pi) / (2 * np.pi) * 359).astype(int)] - 0.5) * 0.12
    f1 = np.where(np.isfinite(D), D, 1e4) - w
    f2 =(np.sqrt(((X - cx) / rx) ** 2 + ((gy - cy) / ry) ** 2) - r) * min(rx, ry)
    k = 34.0
    hh_ = np.clip(0.5 + 0.5 * (f2 - f1) / k, 0, 1)
    acqua = (f2 * (1 - hh_) + f1 * hh_ - k * hh_ * (1 - hh_)) < 0
    dist = _distanza(acqua, 9)
    largo = 3 + 5 * liscio(hg, W, 29, 11)
    riva = (~acqua) & (dist <= largo)
    t.Z[acqua] = FONDO; t.M[acqua] = ACQUA; t.M[riva] = RIVA
    vl, vu = curva(VIA)
    DV, SV, VV = campo(vl, vu, 22, hg, b)
    strada = DV < 14.5
    t.M[strada & ~acqua] = STRADA
    # sotto la piazza niente strada: fra le lastre c'e' l'erba
    pz = np.asarray(Image.open(os.path.join(TER, 'piazza_radenna.png')).convert('RGBA'))[..., 3] > 0
    ph, pw = pz.shape; x0, y0 = PIAZZA[0] - pw // 2, PIAZZA[1] - ph // 2
    sub = t.M[y0 + b:y0 + b + ph, x0:x0 + pw]
    sub[_chiudi(pz, 4) & (sub == STRADA)] = ERBA
    # il ponte: il piano al livello del prato sopra l'acqua e le sponde; le spallette (larghe 5, alte 7) col bordo
    # della vasca di Bru, che poggiano 3 righe oltre le sponde; i pilastrini alle quattro teste (alti 10)
    righe = [g for g in range(hg) if (acqua | riva)[g, RX:RX + 29].any()]
    g0, g1 = min(righe), max(righe) + 1
    t.Z[g0:g1, RX:RX + 29] = 0; t.M[g0:g1, RX:RX + 29] = PONTE
    for x0 in (RX - 5, RX + 29):
        t.Z[g0 - 3:g1 + 3, x0:x0 + 5] = 7; t.M[g0 - 3:g1 + 3, x0:x0 + 5] = SPALLA
        for a in (g0 - 9, g1 + 3):
            t.Z[a:a + 6, x0:x0 + 5] = 10; t.M[a:a + 6, x0:x0 + 5] = PALO
    return t, dict(S=S, V=V, D=D, w=w, SV=SV, VV=VV, dist=dist, largo=largo, acqua=acqua, lin=lin, u=u)


# ================================================================ i colori

class Erba:
    # i quattro quadrati d'erba di Bru mescolati a caso, e sopra le macchie larghe della pianura (piu' scure,
    # piu' chiare) come nel suo disegno
    def __init__(self, hg, seme):
        rng = np.random.default_rng(seme)
        tiles = [np.asarray(Image.open(os.path.join(TER, 'erba_radenna%s.png' % s)).convert('RGB')).astype(float)
                 for s in ('', '_2', '_3', '_4')]
        self.k = np.stack([((VERDI[None, None] - a[..., None, :]) ** 2).sum(-1).argmin(-1) for a in tiles])
        self.mappa = rng.integers(4, size=(hg // 64 + 2, W // 64 + 2))
        m = liscio(hg, W, 120, seme + 1) * 0.6 + liscio(hg, W, 41, seme + 2) * 0.4
        self.macchia = np.array([-2, 0, 1, 2])[np.digitize(m, np.quantile(m, [0.22, 0.55, 0.8]))]

    def colori(self, X, G):
        k = self.k[self.mappa[G // 64, X // 64], G % 64, X % 64]
        return VERDI[np.clip(k + self.macchia[G, X], 0, 10)]


def _verde(t):
    lab = _oklab(t[..., :3])
    h = np.degrees(np.arctan2(lab[..., 2], lab[..., 1])); C = np.hypot(lab[..., 1], lab[..., 2])
    return (h > 105) & (h < 175) & (C > 0.05)


def disegna(t, F, seme=3):
    G = t.proietta()
    tipo, GY, Zb, Mb, FD, FH = G['tipo'], G['gy'], G['z'], G['m'], G['fd'], G['fh']
    rng = np.random.default_rng(seme)
    V_ = np.asarray(Image.open(os.path.join(TER, 'vasca_radenna.png')).convert('RGBA')).astype(float)
    acqua_t = np.asarray(Image.open(os.path.join(TER, 'acqua_radenna.png')).convert('RGB')).astype(float)
    sassi_t = np.asarray(Image.open(os.path.join(TER, 'ciottoli_radenna.png')).convert('RGB')).astype(float)
    muschio_t = _verde(sassi_t)
    st = np.asarray(Image.open(os.path.join(TER, 'strade_radenna', 'strada_verticale.png')).convert('RGBA')).astype(float)
    erba = Erba(t.HG, seme)
    gyc = np.clip(GY, 0, t.HG - 1)
    X = np.repeat(np.arange(W)[None, :], H, 0)
    pav = tipo == 1; fac = tipo == 2
    img = np.zeros((H, W, 3))
    prato = erba.colori(X, gyc)
    img[pav & (Mb == ERBA)] = prato[pav & (Mb == ERBA)]
    # la strada e il piano del ponte: il motivo del kit piegato lungo la curva
    col = np.clip((F['VV'][gyc, X] + 14.5).astype(int), 0, 28); row = F['SV'][gyc, X].astype(int) % 55
    tex = st[row, col]
    m = pav & np.isin(Mb, [STRADA, PONTE]); pieno = tex[..., 3] > 0
    img[m & pieno] = tex[m & pieno][:, :3]
    img[m & ~pieno & (Mb == STRADA)] = prato[m & ~pieno & (Mb == STRADA)]
    img[m & ~pieno & (Mb == PONTE)] = P[3]
    # le sponde: i ciottoli di Bru; verso il prato il muschio lascia il posto all'erba
    sh, sw = sassi_t.shape[:2]
    sas = sassi_t[gyc % sh, X % sw]; mus = muschio_t[gyc % sh, X % sw]
    fuori = F['dist'][gyc, X] > F['largo'][gyc, X] * 0.55
    m = pav & (Mb == RIVA)
    img[m] = sas[m]
    img[m & mus & fuori] = prato[m & mus & fuori]
    # la sponda di la' vista di faccia: gli stessi ciottoli nell'ombra, piu' scuri giu' verso l'acqua
    f = fac & np.isin(Mb, [RIVA, ERBA, STRADA])
    fd = FD.astype(float); fh = np.maximum(FH, 1).astype(float)
    sas_f = sassi_t[(gyc + FD) % sh, X % sw]
    scuro = (0.74 - 0.26 * fd / fh)[..., None]
    img[f] = (sas_f * scuro)[f]
    img[f & (FD >= FH - 1)] = P[0] * 0.8
    # le spallette, i pilastrini
    for y, x in zip(*np.nonzero(pav & (Mb == SPALLA))):
        i = x - (RX - 5) if x < RX else RX + 33 - x
        img[y, x] = V_[53 + gyc[y, x] % 51, 4 + i, :3]
    for y, x in zip(*np.nonzero(pav & (Mb == PALO))):
        su = y == 0 or not (tipo[y - 1, x] == 1 and Mb[y - 1, x] == PALO)
        sx = not (tipo[y, x - 1] == 1 and Mb[y, x - 1] == PALO)
        dx = not (tipo[y, x + 1] == 1 and Mb[y, x + 1] == PALO)
        img[y, x] = P[7] if (su or sx) else (P[4] if dx else P[6])
    for y, x in zip(*np.nonzero(fac & np.isin(Mb, [PALO, SPALLA, PONTE]))):
        d, h, mm = FD[y, x], FH[y, x], Mb[y, x]
        if mm == PALO:
            sx = not (tipo[y, x - 1] == 2 and Mb[y, x - 1] == PALO)
            dx = not (tipo[y, x + 1] == 2 and Mb[y, x + 1] == PALO)
            img[y, x] = P[5] if d == 0 else (P[0] if d >= h - 1 else (P[6] if sx else (P[2] if dx else P[4])))
        else:
            img[y, x] = P[5] if d == 0 else (P[3] if d < h - 1 else P[1])
    # l'acqua come nella vasca di Bru: sotto la sponda di la' la riga scura e il filo chiaro, poi una fascia scura;
    # lungo le sponde di lato lo stesso; verso la sponda di qua piu' fonda e scura
    acq = pav & (Mb == ACQUA)
    du = _corsa(acq); dd = _corsa(acq[::-1])[::-1]
    dl = _corsa(acq.T).T; dr = _corsa(acq.T[::-1])[::-1].T

    def scurisci(c, n):
        return AQ[max(0, int(((AQ - c) ** 2).sum(1).argmin()) - n)]
    for y, x in zip(*np.nonzero(acq)):
        c = acqua_t[y % 192, x % 192]
        a, bb, s = du[y, x], dd[y, x], min(dl[y, x], dr[y, x])
        if a == 1:
            c = (7, 55, 59)
        elif s == 1:
            c = (18, 58, 57)
        elif a == 2:
            c = (97, 235, 222)
        elif s == 2:
            c = (126, 250, 248)
        elif a == 3:
            c = AQ[2]
        elif a <= 5 or s <= 3 or bb == 1:
            c = AQ[0]
        else:
            n = max(3 if a <= 8 else (2 if a <= 12 else (1 if a <= 15 else 0)),
                    3 if s <= 5 else (2 if s <= 7 else (1 if s <= 9 else 0)),
                    4 if bb <= 3 else (3 if bb <= 5 else (2 if bb <= 8 else (1 if bb <= 11 else 0))))
            if dl[y, x] <= 7 and Mb[y, x - dl[y, x]] in (SPALLA, PALO, PONTE):     # l'ombra del ponte
                n = max(n, 3 if dl[y, x] <= 5 else 2)
            if n:
                c = scurisci(c, n)
        img[y, x] = c
    # la corrente: increspature allungate lungo il filo del ruscello (non nello stagno)
    lin, u = F['lin'], F['u']
    tg = np.gradient(lin, axis=0); tg /= np.linalg.norm(tg, axis=1)[:, None] + 1e-9
    for k in range(70):
        i = int(rng.integers(20, len(lin) - 20)); off = rng.uniform(-0.5, 0.5)
        px, py = lin[i]; nx, ny = -tg[i, 1], tg[i, 0]
        wid = np.interp(i, [0, len(lin)], [20, 20])
        L = int(rng.integers(5, 11))
        for j in range(L):
            q = min(len(lin) - 1, i + j)
            x = int(round(lin[q, 0] + nx * off * wid)); y = int(round(lin[q, 1] + ny * off * wid)) - FONDO
            if 0 <= y < H and 0 <= x < W and acq[y, x] and du[y, x] >= 6 and dd[y, x] >= 5 and \
                    min(dl[y, x], dr[y, x]) >= 5:
                img[y, x] = AQ[7] if 0 < j < L - 1 else AQ[6]
    for k in range(60):
        yy, xx = int(rng.integers(0, H)), int(rng.integers(0, W))
        if acq[yy, xx] and du[yy, xx] > 6 and dd[yy, xx] > 3:
            img[yy, xx] = AQ[9]
    # l'ombra ai piedi della sponda di la' sull'acqua e' gia' nella fascia scura; sul prato sotto le spallette:
    for x in range(W):
        for y in range(1, H):
            if fac[y - 1, x] and pav[y, x] and Mb[y, x] != ACQUA and Mb[y - 1, x] in (PALO, SPALLA):
                for k, ff in enumerate((0.6, 0.78)):
                    if y + k < H and pav[y + k, x] and Mb[y + k, x] != ACQUA:
                        img[y + k, x] *= ff
    # la piazza antica: le nove lastre di Bru posate sul prato (la strada ci passa sotto)
    pz = np.asarray(Image.open(os.path.join(TER, 'piazza_radenna.png')).convert('RGBA')).astype(float)
    _posa(img, pz, PIAZZA[0] - pz.shape[1] // 2, PIAZZA[1] - pz.shape[0] // 2)
    return img, G


# ================================================================ gli oggetti

_CAT = json.load(open(os.path.join(PEZ, 'catalogo.json')))['pezzi']
SPECCHIATI = ['colonna_rovina', 'pino_1', 'pino_2']   # copie girate (nome_s)


def pezzo(nome):
    # file (da art/livelli/), piede nel disegno e misura di un pezzo: dal catalogo, o tra i pezzi nuovi
    if nome in _CAT:
        return 'pezzi/' + _CAT[nome]['file'], tuple(_CAT[nome]['piede']), tuple(_CAT[nome]['misura'])
    f = os.path.join(NUOVI, nome + '.png')
    a = np.asarray(Image.open(f).convert('RGBA'))[..., 3] > 0
    ys, xs = np.nonzero(a)
    giu = ys >= ys.max() - 3
    return 'pezzi/ruscello/' + nome + '.png', (int(round(xs[giu].mean())), int(ys.max())), (a.shape[1], a.shape[0])


def prepara_specchiati():
    for n in SPECCHIATI:
        f, (px, py), (w, h) = pezzo(n)
        a = np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA')).astype(float)
        _salva(a[:, ::-1], os.path.join(NUOVI, n + '_s.png'))


def impronta(nome, w, h):
    # dove non si passa, attorno al piede: (mezza larghezza, mezza altezza) dell'ovale
    if 'albero' in nome or 'pino' in nome:
        return (9, 4)
    if 'cespuglione' in nome:
        return (int(w * 0.36), 7)
    for chiave, imp in (('colonna', (22, 7)), ('vasca_pietra', (42, 10)), ('vasche_gradini', (40, 12)),
                        ('felce', (14, 4)), ('canne', (0, 0))):
        if chiave in nome:
            return imp
    if 'masso' in nome or 'sass' in nome:
        return (max(4, int(w * 0.42)), max(2, int(h * 0.2)))
    return (max(4, int(w * 0.28)), 3)


# le cose in piedi, a gruppi e con un motivo: (nome, x, y del piede)
ALBERI = [
    # il bosco in alto a sinistra: pini, un albero a funghi, alberelli e cespuglioni, fitto nell'angolo
    ('pino_2', 34, 96), ('pino_1', 84, 64), ('pino_3', 10, 170), ('albero_funghi', 160, 130), ('albero_2', 116, 186),
    ('cespuglione_verde', 250, 72), ('pino_2_s', 320, 34), ('albero_4', 52, 238),
    # il bordo in alto, a gruppetti, coi varchi della strada e del ruscello
    ('pino_1', 402, 26), ('albero_1', 446, 42), ('cespuglione_verde_s', 490, 14),
    ('pino_1_s', 704, 28), ('albero_3', 744, 46), ('albero_funghi_s', 820, 40), ('pino_3', 902, 22),
    # in alto a destra, oltre il ruscello
    ('pino_1', 1132, 46), ('albero_2', 1160, 98), ('albero_funghi', 1198, 140), ('pino_2', 1252, 66),
    ('cespuglione_verde_s', 1250, 250),
    # il bordo a destra
    ('pino_3', 1264, 360), ('albero_4', 1238, 402), ('pino_1', 1268, 536), ('albero_1', 1236, 584),
    # il bordo in basso, a gruppi, col varco della strada
    ('pino_1_s', 20, 656), ('albero_funghi', 64, 712), ('albero_2', 120, 676), ('cespuglione_verde_s', 176, 718),
    ('pino_2', 262, 708), ('pino_3', 300, 686),
    ('albero_3', 424, 702), ('cespuglione_verde', 478, 716),
    ('pino_2_s', 716, 718), ('albero_1', 760, 698),
    ('albero_funghi', 880, 716), ('pino_3', 944, 704), ('albero_4', 978, 684),
    ('cespuglione_verde', 1052, 716), ('albero_funghi_s', 1150, 714), ('albero_2', 1198, 670), ('pino_1', 1242, 642),
    ('pino_2_s', 1266, 716),
    # il bordo a sinistra
    ('pino_2', 14, 304), ('albero_4', 34, 352), ('cespuglione_verde', 22, 428), ('pino_1_s', 10, 508),
    # l'albero solo, nel prato grande
    ('albero_funghi_s', 962, 470),
]
COSE = [
    # la piazza antica: due colonne in diagonale, la vasca di pietra accanto
    ('colonna_rovina', 600, 452), ('colonna_rovina_s', 702, 576), ('vasca_pietra', 794, 522),
    # le vasche a gradini sopra lo stagno: l'acqua scende verso lo stagno
    ('vasche_gradini', 292, 246),
    # i sassi: sulle curve di fuori del ruscello, ai piedi degli alberi, nel prato a gruppetti
    ('masso_muschio_8', 474, 268), ('sasso_5', 492, 272), ('masso_muschio_3', 1006, 152), ('sassolino_2', 1020, 156),
    ('masso_muschio_9', 314, 528), ('sasso_2', 332, 532), ('masso_basso_4', 936, 494), ('sassolino_1', 990, 488),
    ('masso_muschio_1', 1106, 420), ('sasso_4', 1124, 426), ('masso_muschio_8', 140, 214), ('sassolino_3', 156, 218),
    ('masso_muschio_3', 560, 640), ('sassolino_2', 576, 644), ('masso_basso_4', 846, 330),
    # le piante luminose: vicino all'acqua e sotto gli alberi
    ('bulbi', 334, 386), ('bulbi', 350, 394), ('bulbi', 488, 436), ('bulbi', 214, 454), ('bulbi', 1084, 254),
    ('bulbi', 902, 476), ('baccelli', 566, 322), ('baccelli_s', 884, 266), ('baccelli', 1154, 526),
    ('bulbi', 1004, 606), ('bulbi', 1020, 614), ('bulbi', 72, 304), ('baccelli_s', 1078, 168), ('bulbi', 520, 318),
]
# le canne: il piede nell'acqua bassa vicino alla riva (gli steli stanno in piedi, il piede e' dipinto sull'acqua)
CANNE = [(360, 352, False), (448, 410, True), (962, 126, False)]
# le cose piatte: ninfee (solo sull'acqua ferma), la pozza coi sassi (una sorgente), i resti del lastricato
NINFEE = [('ninfee_loto', 426, 338), ('ninfee_fiori', 374, 320), ('ninfee_fiori', 140, 588)]
POZZE = [('sassi_pozza', 180, 436)]
RUDERI = [('rovina_1', 548, 452), ('rovina_3', 728, 470), ('rovina_2', 556, 572)]
# i sassi nella corrente, con la schiuma attorno: (pezzo, x, y del piede sullo schermo)
SASSI_ACQUA = [('sasso_4', 578, 264), ('sassolino_1', 596, 270), ('sasso_5', 186, 568), ('sasso_4', 1004, 92)]
LUCI = [(0, 420, 120), (2, 444, 136), (3, 404, 146), (1, 880, 60), (3, 900, 74), (0, 760, 380), (2, 782, 396),
        (1, 236, 360), (3, 256, 372), (2, 222, 380), (1, 1000, 400), (3, 1020, 380), (0, 40, 400), (2, 62, 414),
        (0, 1160, 330), (2, 1180, 346), (1, 860, 620), (3, 880, 640), (0, 480, 620), (2, 500, 636), (1, 1220, 470),
        (3, 1236, 486), (0, 600, 160), (3, 620, 172)]


def _impiedi():
    tutte = []
    for (n, x, y) in ALBERI + COSE:
        f, piede, (w, h) = pezzo(n)
        tutte.append((n, f, x, y, piede, impronta(n, w, h)))
    for (x, y, s) in CANNE:
        n = 'canne_steli_s' if s else 'canne_steli'
        f, piede, _ = pezzo(n)
        tutte.append((n, f, x, y - 27, (piede[0], 71), (0, 0)))
    return tutte


def _e_acqua_del_pezzo_v(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    return (g > r + 40) & (b > 0.72 * g) & (b < g + 10) & (b > 90)


def decora(out, G):
    tipo, Mb = G['tipo'], G['m']
    acq = (tipo == 1) & (Mb == ACQUA)
    erba = (tipo == 1) & (Mb == ERBA)
    for (n, x0, y0) in RUDERI:
        a = np.asarray(Image.open(os.path.join(TER, 'strade_radenna', n + '.png')).convert('RGBA')).astype(float)
        _posa_su(out, a, x0, y0, erba)
    for (n, fx, fy) in POZZE:
        f, (px, py), _ = pezzo(n)
        a = np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA')).astype(float)
        _posa_su(out, a, fx - px, fy - py, (tipo == 1) & np.isin(Mb, [ERBA, RIVA]))
    for (k, x0, y0) in LUCI:
        a = np.asarray(Image.open(os.path.join(NUOVI, 'luce_%d.png' % k)).convert('RGBA')).astype(float)
        _posa_su(out, a, x0, y0, erba)
    for (n, fx, fy) in NINFEE:
        f, (px, py), _ = pezzo(n)
        a = np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA')).astype(float)
        a[_e_acqua_del_pezzo_v(a), 3] = 0
        _posa_su(out, a, fx - px, fy - py, acq)
    for (n, fx, fy) in SASSI_ACQUA:
        f, (px, py), (w, h) = pezzo(n)
        rx, ry = w * 0.62, max(2.5, h * 0.3)
        for y in range(int(fy - ry - 3), int(fy + ry + 4)):          # la schiuma: un anello a puntini
            for x in range(int(fx - rx - 3), int(fx + rx + 4)):
                if 0 <= y < H and 0 <= x < W and acq[y, x]:
                    e = ((x - fx) / rx) ** 2 + ((y - fy) / ry) ** 2
                    if 0.7 <= e <= 1.25 and (x + 2 * y) % 3:
                        out[y, x] = AQ[9] if e < 1 else AQ[8]
        a = np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA')).astype(float)
        _posa_su(out, a, fx - px, fy - py, acq)
    c = np.asarray(Image.open(os.path.join(PEZ, 'radenna', 'canne_luminose.png')).convert('RGBA')).astype(float)
    for (fx, fy, specchio) in CANNE:
        a = c[:, ::-1] if specchio else c
        px = a.shape[1] - 1 - 48 if specchio else 48
        base = a.copy(); base[:72, :, 3] = 0
        # sulla riva il piede delle canne e' una pozzetta di fango e muschio: sull'acqua, sui ciottoli e sull'erba
        _posa_su(out, base, fx - px, fy - 98, (tipo == 1) & np.isin(Mb, [ACQUA, RIVA, ERBA]))
    return out


def _posa_su(out, a, x0, y0, dove):
    for j in range(a.shape[0]):
        for i in range(a.shape[1]):
            y, x = y0 + j, x0 + i
            if 0 <= y < H and 0 <= x < W and a[j, i, 3] > 0 and dove[y, x]:
                out[y, x] = a[j, i, :3]


# le luci che bagnano il terreno di turchese: (x, y, forza, raggio)
def _sorgenti():
    s = []
    for (n, f, x, y, piede, imp) in _impiedi():
        if 'canne' in n:
            s.append((x, y + 20, 0.7, 22))
        elif 'bulbi' in n:
            s.append((x, y - 4, 0.5, 11))
        elif 'baccelli' in n or 'sfere' in n:
            s.append((x, y - 4, 0.55, 14))
        elif 'albero_blu' in n:
            s.append((x, y - 10, 0.45, 40))
        elif 'vasca' in n:
            s.append((x, y - 8, 0.5, 28))
    for (n, fx, fy) in POZZE:
        s.append((fx - 30, fy - 30, 0.4, 26))
    return s


def luce_turchese(out, G):
    tipo, Mb = G['tipo'], G['m']
    acque = (Mb == ACQUA)
    L = _sfoca(acque.astype(float), 7) * 0.9
    Y, X = np.mgrid[:H, :W]
    for (x, y, f, r) in _sorgenti():
        x0, x1, y0, y1 = max(0, x - 3 * r), min(W, x + 3 * r), max(0, y - 3 * r), min(H, y + 3 * r)
        L[y0:y1, x0:x1] += f * np.exp(-((X[y0:y1, x0:x1] - x) ** 2 + (Y[y0:y1, x0:x1] - y) ** 2) / (2.0 * r * r))
    for (k, x0, y0) in LUCI:
        L[max(0, y0 - 15):y0 + 28, max(0, x0 - 15):x0 + 28] += 0.3 * np.exp(
            -((X[max(0, y0 - 15):y0 + 28, max(0, x0 - 15):x0 + 28] - x0 - 6) ** 2
              + (Y[max(0, y0 - 15):y0 + 28, max(0, x0 - 15):x0 + 28] - y0 - 6) ** 2) / 98.0)
    bayer = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
    q = np.clip(np.floor(np.clip(L, 0, 1) * 3.2 + bayer[Y % 4, X % 4] - 0.35), 0, 3).astype(int)
    k = np.array([0.0, 0.07, 0.14, 0.24])[q]
    k[acque] = 0
    out = out + k[..., None] * np.array([10.0, 150.0, 125.0])[None, None]
    return np.clip(out, 0, 255)


def ombre(out, G):
    # l'ombra ovale di ogni cosa in piedi (luce da in alto a sinistra: va un poco a destra); sotto le chiome il
    # prato e' all'ombra, una macchia larga a due gradini col retino
    tipo, Mb = G['tipo'], G['m']
    bayer = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
    for (n, f, fx, fy, piede, imp) in _impiedi():
        if 'canne' in n:
            continue
        w = Image.open(os.path.join(LIV, f)).size[0]
        if 'albero' in n or 'cespuglione' in n or 'pino' in n:
            rx = 0.56 * w; ry = 0.24 * w; cx, cy = fx + 5, fy - 3
            for y in range(int(cy - ry - 1), int(cy + ry + 2)):
                for x in range(int(cx - rx - 1), int(cx + rx + 2)):
                    if 0 <= y < H and 0 <= x < W and tipo[y, x] == 1 and Mb[y, x] != ACQUA:
                        e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                        if e <= 1:
                            out[y, x] *= 0.8 if e + bayer[y % 4, x % 4] * 0.3 < 0.55 else 0.9
        rx = max(5.0, 0.32 * w); ry = max(2.5, rx * 0.32); cx, cy = fx + 3, fy - 1
        for y in range(int(cy - ry - 1), int(cy + ry + 2)):
            for x in range(int(cx - rx - 1), int(cx + rx + 2)):
                if 0 <= y < H and 0 <= x < W and tipo[y, x] == 1 and Mb[y, x] != ACQUA:
                    e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                    if e <= 1:
                        out[y, x] *= 0.62 if e < 0.55 else 0.78
    return out


def anteprima(terreno):
    out = terreno.astype(float).copy()
    for (n, f, fx, fy, piede, imp) in sorted(_impiedi(), key=lambda c: c[3]):
        a = np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA')).astype(float)
        _posa(out, a, fx - piede[0], fy - piede[1])
    return out


def passi(G):
    # dove si cammina: prato, strada, piano del ponte, sponde di ciottoli (in cima); non l'acqua, non la sponda di
    # faccia, non le spallette; non i piedi delle cose in piedi e la pozza coi sassi
    tipo, Mb = G['tipo'], G['m']
    ok = (tipo == 1) & np.isin(Mb, [ERBA, STRADA, PONTE, RIVA])
    yy, xx = np.ogrid[:H, :W]
    for (n, f, fx, fy, piede, (rx, ry)) in _impiedi():
        if rx:
            ok &= ((xx - fx) / rx) ** 2 + ((yy - fy) / ry) ** 2 > 1
    for (n, fx, fy) in POZZE:
        ok &= ((xx - (fx - 30)) / 40.0) ** 2 + ((yy - (fy - 34)) / 22.0) ** 2 > 1
    m = np.zeros((H, W, 4), np.uint8); m[ok] = (255, 255, 255, 255)
    return m


PARTENZA = [612, 700]
STANZE = [
    {"nome": "L'arrivo", "rett": [480, 600, 800, 720]},
    {"nome": "La piazza antica", "rett": [540, 400, 860, 600]},
    {"nome": "Il ponte", "rett": [620, 140, 780, 340]},
    {"nome": "Lo stagno", "rett": [250, 200, 520, 420]},
    {"nome": "La pianura", "rett": [0, 0, W, H]},
]
GIRO = [[612, 700], [650, 610], [650, 505], [650, 420], [688, 352], [700, 300], [700, 200], [694, 140],
        [600, 196], [420, 250], [600, 196], [690, 120], [650, 62], [606, 12]]


def main():
    prepara_pianura()
    prepara_specchiati()
    t, F = pianta()
    terreno, G = disegna(t, F)
    terreno = decora(terreno, G)
    terreno = luce_turchese(terreno, G)
    terreno = ombre(terreno, G)
    _salva(terreno, os.path.join(LIV, 'ruscello.png'))
    _salva(passi(G).astype(float), os.path.join(LIV, 'ruscello_passi.png'))
    with open(os.path.join(LIV, 'ruscello_pezzi.json'), 'w') as f:
        json.dump({"_nota": "Scritto da strumenti/livelli/ruscello_radenna.py: non toccare a mano. Ogni pezzo e' "
                            "[file (da art/livelli/), x, y del piede nel mondo, x, y del piede nel disegno].",
                   "pezzi": [[c[1], c[2], c[3], c[4][0], c[4][1]] for c in sorted(_impiedi(), key=lambda c: c[3])]},
                  f, indent=1, ensure_ascii=False)
        f.write('\n')
    pianta_json = {
        "_nota": "Il ruscello di Radenna, una pianura aperta fatta da strumenti/livelli/ruscello_radenna.py: il "
                 "ruscello a S con lo stagno, la strada che passa la piazza antica e il ponte, i boschetti sui bordi. "
                 "Non e' ancora un livello del gioco: per provarla.",
        "nome": "Il ruscello di Radenna",
        "mappa": "ruscello.png", "scala": 1, "pixel": 1, "ingrandimento": 2,
        "_scala": "La mappa e' alla misura del mondo (un pixel, un pixel del mondo, come lei); la telecamera "
                  "ingrandisce due volte.",
        "pezzi": "ruscello_pezzi.json",
        "passi": "ruscello_passi.png",
        "erba": {"tinta": [0.2, 0.47], "saturazione": 0.42, "luce": [0.1, 0.85]},
        "limiti": [0, 0, W, H],
        "partenza": PARTENZA, "verso": [0, -1],
        "stanze": STANZE,
        "giro": GIRO,
        "_giro": "Dalla strada che arriva dal basso, attraverso la piazza antica, sul ponte, fino allo stagno e "
                 "indietro, poi su per la strada.",
    }
    with open(os.path.join(LIV, 'ruscello.json'), 'w') as f:
        json.dump(pianta_json, f, indent=1, ensure_ascii=False)
        f.write('\n')
    if len(sys.argv) > 1:
        _salva(anteprima(terreno), sys.argv[1])
    print('ruscello: mappa %dx%d, %d cose in piedi' % (W, H, len(_impiedi())))


if __name__ == '__main__':
    main()
