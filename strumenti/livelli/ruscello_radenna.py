# La sezione del ruscello di Radenna: un pezzo di livello a piani, fatto coi pezzi di Radenna.
#
#   python3 strumenti/livelli/ruscello_radenna.py [anteprima.png]      (serve numpy e Pillow)
#   poi: godot prove/LivelloProva.tscn -- livello ruscello
#
# Prima il TERRENO, poi gli OGGETTI sopra.
#
# Il terreno nasce da una pianta delle altezze (coordinate di terreno, viste da sopra): ogni zona ha la sua z in
# pixel (la terrazza 50, il prato 0, l'acqua -19, il piano di sotto -50). Il motore la proietta in vista 3/4
# riga per riga da nord a sud: una zona alta z si vede z pixel piu' su, e dove la z scende verso sud c'e' una
# parete alta quanto il salto (chi sta piu' a sud copre chi sta dietro). Cosi' pareti, scale, cascata e ombre
# vengono dalla pianta e tornano sempre.
#
# I materiali sono quelli dei fogli di Bru (strumenti/livelli/fogli/tile_radenna.jpg): l'erba di Radenna, la
# vasca (la sua cornice di pietra fa i cigli, il fregio a greca le pareti, il suo bordo le sponde e le spallette
# del ponte, la sua acqua coi riccioli l'acqua, col filo chiaro e la fascia scura lungo i bordi come nella vasca),
# il kit delle strade (strada, anello, il "tratto corto" che fa da lastra sul canale), le luci turchesi dell'erba.
# L'acqua e le piante luminose bagnano di turchese l'erba e la pietra vicine.
#
# Gli oggetti stanno dove c'e' un motivo: le ninfee dove l'acqua e' ferma, le canne dove e' bassa, i sassi ai
# piedi delle pareti e sotto la cascata, gli alberi a gruppi che chiudono i bordi (quelli del piano di sotto
# coprono il muro), la colonna in cima alla scala, la vasca dove finisce il ramo della piazzetta.
#
# Scrive art/livelli/ruscello.png (il terreno, con le cose piatte), ruscello_pezzi.json (le cose in piedi, che il
# gioco mette insieme a lei in ordine di piede), ruscello_passi.png (dove si cammina) e ruscello.json; e i pezzi
# nuovi in art/livelli/pezzi/ruscello/ e i terreni acqua_radenna.png e vasca_radenna.png.
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
W, H = 640, 480
ERBA, ACQUA, STRADA, SCALA, PONTE, SPALLA, PILASTRO, PALO, PILONE, LASTRA = 1, 2, 3, 4, 5, 6, 8, 9, 10, 11
VERDI = np.array([(3, 47, 32), (5, 56, 34), (6, 62, 35), (8, 67, 35), (12, 72, 35), (14, 78, 35), (20, 83, 35),
                  (25, 89, 35), (34, 97, 38), (44, 106, 42), (64, 112, 60)], float)
P = np.array([(30, 40, 33), (44, 71, 50), (66, 84, 69), (84, 103, 85), (108, 122, 105), (120, 135, 117),
              (141, 155, 135), (163, 176, 155)], float)
AQ = np.array([(1, 119, 127), (2, 133, 136), (2, 156, 149), (1, 182, 168), (2, 213, 192), (2, 231, 204),
               (18, 242, 218), (79, 253, 237), (117, 255, 252), (210, 255, 250)], float)


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

def arrotonda(punti, raggio=6, passi=6):
    # ogni vertice diventa un arco: i lati restano dritti, gli angoli morbidi tutti uguali
    p = np.array(punti, float); n = len(p); out = []
    for i in range(n):
        a, b, c = p[i - 1], p[i], p[(i + 1) % n]
        u = a - b; v = c - b; lu, lv = np.linalg.norm(u), np.linalg.norm(v)
        if lu < 1e-6 or lv < 1e-6:
            out.append(tuple(b)); continue
        r = min(raggio, lu / 2, lv / 2); p0 = b + u / lu * r; p2 = b + v / lv * r
        for k in range(passi + 1):
            t = k / passi; q = (1 - t) ** 2 * p0 + 2 * (1 - t) * t * b + t ** 2 * p2
            out.append((round(q[0], 2), round(q[1], 2)))
    return out


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


# ================================================================ la pianta della sezione

RX = 232             # la strada: x 232..260 (29, come il kit)
FX0, FX1 = 452, 488  # il canale della terrazza e la cascata
CXA, CYA = 246, 345  # l'anello della piazzetta
PILONI = [(446, 196, 50), (494, 196, 50)]   # i due piloni che chiudono la cascata
LX, LG = 443, 72     # la lastra che passa il canale (il "tratto corto" del kit, 55x29): x e riga di terreno


def pianta():
    t = Terreno()
    t.zona([(-10, -110), (W + 10, -110), (W + 10, H + 100), (-10, H + 100)], 0, ERBA)            # il prato
    t.zona(arrotonda([(-10, -110), (W + 10, -110), (W + 10, 164), (592, 164), (560, 196), (362, 196), (330, 164),
                      (136, 164), (112, 140), (-10, 140)], 4), 50, ERBA)                          # la terrazza
    t.zona([(FX0, -110), (FX1, -110), (FX1, 196), (FX0, 196)], 42, ACQUA)                         # il canale
    t.zona([(LX, LG), (LX + 55, LG), (LX + 55, LG + 29), (LX, LG + 29)], 50, LASTRA)  # la lastra sul canale
    t.zona(arrotonda([(414, 197), (558, 197), (576, 215), (576, 234), (558, 252), (420, 252), (404, 258),
                      (300, 258), (276, 266), (180, 266), (150, 284), (100, 292), (60, 312), (-10, 312),
                      (-10, 268), (60, 268), (100, 248), (150, 240), (180, 222), (276, 222), (300, 214),
                      (380, 214), (396, 206)], 8), -19, ACQUA)                                    # pozza e ruscello
    t.zona(arrotonda([(-10, 390), (180, 390), (196, 406), (420, 406), (452, 374), (W + 10, 374),
                      (W + 10, H + 100), (-10, H + 100)], 4), -50, ERBA)                          # il piano di sotto
    # i piloni ai lati della cascata: larghi 11, sporgono dal muro, alti 4 in piu'
    for (x, g, z) in PILONI:
        ult = []                               # l'ultima riga del piano alto in ogni colonna (anche sullo smusso)
        for xx in range(x - 5, x + 6):
            r = np.nonzero(t.Z[g - 12 + t.B:g + 13 + t.B, xx] == z)[0]
            ult.append(g - 12 + r.max() if len(r) else g)
        a, b = min(ult) - 3, max(ult) + 4
        t.Z[a + t.B:b + t.B, x - 5:x + 6] = z + 4; t.M[a + t.B:b + t.B, x - 5:x + 6] = PILONE
    t.gradini(RX, RX + 29, 407, 437, 0, -50, 10)                                                 # scala di sotto
    t.gradini(RX, RX + 29, 135, 165, 50, 0, 10)                                                  # scala della terrazza
    for (r0, r1, z) in ((407, 437, 2), (135, 165, 52)):                                          # i fianchi
        for x0 in (RX - 4, RX + 29):
            t.Z[r0 + t.B:r1 + t.B, x0:x0 + 4] = z; t.M[r0 + t.B:r1 + t.B, x0:x0 + 4] = PILASTRO
    ZT = t.Z.copy()
    for g in range(t.HG):                      # la strada (non dentro l'anello)
        for x in range(RX, RX + 29):
            if t.M[g, x] == ERBA and not (314 <= g - t.B < 376):
                t.M[g, x] = STRADA
    # il ponte: il piano al livello del prato; ai lati le spallette (larghe 5, alte 7) che poggiano 4 righe sulle
    # sponde, coi pilastrini alle quattro teste (alti 10)
    righe = [g for g in range(t.HG) if (ZT[g, RX:RX + 29] == -19).any()]
    g0, g1 = min(righe), max(righe) + 1
    for g in range(g0, g1):
        for x in range(RX, RX + 29):
            if ZT[g, x] == -19:
                t.Z[g, x] = 0; t.M[g, x] = PONTE
    for x0 in (RX - 5, RX + 29):
        t.Z[g0 - 4:g1 + 4, x0:x0 + 5] = 7; t.M[g0 - 4:g1 + 4, x0:x0 + 5] = SPALLA
        for a in (g0 - 6, g1):
            t.Z[a:a + 6, x0:x0 + 5] = 10; t.M[a:a + 6, x0:x0 + 5] = PALO
    return t


# ================================================================ i materiali

class Muratura:
    # la cornice della vasca di Bru: cimasa (il ciglio), fregio a greca (le pareti, 19 pixel), bordo delle sponde;
    # sotto il fregio corsi di blocchi da 10; qualche blocco del fregio liscio o col muschio, rampicanti
    PER = 49

    def __init__(self, vasca, seme):
        self.V = vasca.astype(float)
        rng = np.random.default_rng(seme)
        self.tipo = rng.choice([0, 0, 0, 1, 2], size=200)
        self.ramp = np.where(rng.random(2000) < 0.10, rng.integers(6, 26, 2000), 0)
        self.ciuffo = np.where(rng.random(W) < 0.45, rng.integers(1, 4, W), 0)
        self.file = []
        for r in range(8):
            fila = np.zeros(W + 40, int); sx = np.zeros(W + 40, int); x = -int(rng.integers(0, 24)); k = 0
            crepe = []   # una crepa storta per blocco (dove c'e'): la colonna della crepa riga per riga
            while x < W + 40:
                w = int(rng.integers(16, 31)); a, b = max(0, x), min(W + 40, x + w)
                fila[a:b] = k; sx[a:b] = x; x += w; k += 1
                c = int(rng.integers(4, w - 4)); cam = []
                for j in range(10):
                    cam.append(c); c = int(np.clip(c + rng.choice([-1, 0, 0, 1]), 2, w - 3))
                crepe.append(cam)
            self.file.append((fila, sx, rng.integers(-1, 2, k + 1), rng.random(k + 1) < 0.22, rng.random(k + 1) < 0.2,
                              crepe, rng.integers(1, 4, k + 1)))

    def cx(self, x):
        return 53 + x % self.PER

    def cimasa_nord(self, x, k):
        return self.V[4 + k, self.cx(x), :3]

    def cimasa_sud(self, x, k):
        return self.V[151 + k, self.cx(x), :3]

    def cimasa_lato(self, sinistra, k, g):
        r = 53 + g % 51
        return self.V[r, 13 - k, :3] if sinistra else self.V[r, 141 + k, :3]

    def fregio(self, x, d):
        t = self.tipo[(x // self.PER) % 200]
        c = self.V[10 + d, self.cx(x), :3]
        i = self.cx(x) - 53
        if t == 1 and 2 <= d <= 16 and 2 <= i <= self.PER - 3:
            c = P[4] if d < 6 else (P[3] if d < 13 else P[2])
            if i == 17 + d // 3:
                c = P[1]
        elif t == 2 and d <= 7 and (x * 7 + d * 3) % 5 < 3:
            c = VERDI[5 + (x + d) % 3]
        return c

    def blocchi(self, x, d):
        r = d // 10; j = d % 10
        fila, sx, tono, crepa, muschio, crepe, inizio = self.file[r % 8]
        k = fila[x]; i = x - sx[x]
        if j == 9 or i == 0:
            return P[1]
        b = 5 if j == 0 else (4 if j < 7 else 3)
        if i == 1:
            b += 1
        b += tono[k]
        if crepa[k] and inizio[k] <= j <= 8:
            if i == crepe[k][j]:
                b = 1
            elif i == crepe[k][j] + 1 and j % 3:
                b += 1
        if muschio[k] and j < 3 and (i * 3 + j) % 4:
            return VERDI[5 + (i + j) % 3]
        return P[int(np.clip(b, 0, 7))]

    def pilone(self, x, d, h, tipo, Mb, y):
        # la faccia di un pilone: il cappello chiaro con l'ombra sotto, poi blocchi alti 16 con la grana del bordo
        # della vasca di Bru, il filo chiaro a sinistra e lo smusso scuro a destra, contorno scuro
        i = 0
        while i < 11 and tipo[y, x - i - 1] == 2 and Mb[y, x - i - 1] == PILONE:
            i += 1
        if d >= h - 1 or i == 0 or i == 10:
            return P[0]
        if d == 0:
            return P[7]
        if d <= 2:
            return P[6]
        if d == 3:
            return P[5] if i < 9 else P[3]
        if d == 4:
            return P[1]
        if i == 1:
            return P[6]
        if i == 9:
            return P[2]
        if i == 8:
            return P[3]
        j = (d - 5) % 16
        if j == 15:
            return P[1]
        if j == 0:
            return P[6]
        return self.V[53 + (d * 3 + x) % 51, 147 + (i - 2) % 5, :3]

    def parete(self, x, d, h, erba_sopra):
        if d >= h - 1:
            c = P[0]
        elif d < 19:
            c = self.fregio(x, d)
        else:
            c = self.blocchi(x, d - 19)
        if erba_sopra and d < h - 2:
            L = self.ramp[x % 2000]
            if L and d < L:
                c = VERDI[3] if (d + x) % 4 == 0 else (VERDI[6] if (d // 3 + x) % 2 else VERDI[8])
            if d < self.ciuffo[x] and d < 3:
                c = VERDI[2] if d == self.ciuffo[x] - 1 else VERDI[7]
        return c


class Erba:
    def __init__(self, hg, seme):
        rng = np.random.default_rng(seme)
        tiles = [np.asarray(Image.open(os.path.join(TER, 'erba_radenna%s.png' % s)).convert('RGB')).astype(float)
                 for s in ('', '_2', '_3', '_4')]
        self.k = [((VERDI[None, None] - a[..., None, :]) ** 2).sum(-1).argmin(-1) for a in tiles]
        self.mappa = rng.integers(4, size=(hg // 64 + 2, W // 64 + 2))
        self.macro = liscio(hg, W, 52, seme + 1)

    def colore(self, x, g, luce):
        k = self.k[self.mappa[g // 64, x // 64]][g % 64, x % 64]
        m = self.macro[g, x]
        s = (2 if m > 0.80 else 1) if m > 0.64 else (-1 if m < 0.32 else 0)
        return VERDI[int(np.clip(k + s + luce, 0, 10))]


class Cascata:
    # la cortina d'acqua: filetti verticali di toni diversi (a gruppi di 1-3 colonne), trattini chiari che scendono
    # a passi diversi, il labbro chiaro in cima con la piega piu' scura sotto, i bordi scuri, la schiuma ai piedi
    def __init__(self, seme):
        rng = np.random.default_rng(seme)
        self.tono = np.zeros(W, int); x = 0
        while x < W:
            n = int(rng.integers(1, 4)); self.tono[x:x + n] = rng.choice([4, 5, 6, 6, 7, 7]); x += n
        self.passo = rng.integers(9, 19, W); self.fase = rng.integers(0, 19, W)
        self.piede = rng.integers(2, 6, W)

    def colore(self, x, d, h):
        if x in (FX0, FX1 - 1):
            return AQ[1] if d > 1 else AQ[7]
        if x in (FX0 + 1, FX1 - 2):
            return AQ[3] if d > 1 else AQ[8]
        if d == 0:
            return AQ[9]
        if d == 1:
            return AQ[8]
        if d <= 3:
            return AQ[4] if (x + d) % 2 else AQ[5]
        if d >= h - self.piede[x]:
            return AQ[9] if (x * 3 + d) % 4 else AQ[8]
        s = (d + self.fase[x]) % self.passo[x]
        if s == 0:
            return AQ[9]
        if s <= 2:
            return AQ[8]
        return AQ[self.tono[x]]


# ================================================================ il disegno del terreno

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


def disegna(t, seme=3):
    G = t.proietta()
    tipo, GY, Zb, Mb, FD, FH = G['tipo'], G['gy'], G['z'], G['m'], G['fd'], G['fh']
    rng = np.random.default_rng(seme)
    vasca = np.asarray(Image.open(os.path.join(TER, 'vasca_radenna.png')).convert('RGBA'))
    mur = Muratura(vasca, seme + 8); erba = Erba(t.HG, seme)
    acqua = np.asarray(Image.open(os.path.join(TER, 'acqua_radenna.png')).convert('RGB')).astype(float)
    st = np.asarray(Image.open(os.path.join(TER, 'strade_radenna', 'strada_verticale.png')).convert('RGBA')).astype(float)
    cas = Cascata(seme + 5)
    img = np.zeros((H, W, 3), float)
    for y in range(H):
        for x in range(W):
            k = tipo[y, x]; m = Mb[y, x]; g = GY[y, x]; z = Zb[y, x]
            luce = 1 if z >= 30 else (-1 if z <= -30 else 0)
            if k == 1:
                if m == ERBA:
                    c = erba.colore(x, g, luce)
                elif m in (STRADA, PONTE):
                    s = st[g % 55, x - RX]
                    c = s[:3] if s[3] > 0 else (erba.colore(x, g, luce) if m == STRADA else P[3])
                elif m == SCALA:                # la pedata: in fondo all'ombra dell'alzata, chiara sul filo
                    c = (P[5], P[6], P[7])[(g - t.B - (135 if g - t.B < 300 else 407)) % 3]
                elif m == PILASTRO:
                    c = P[7] if x in (RX - 3, RX + 30) else P[6]
                elif m == LASTRA:
                    c = P[5]
                elif m == SPALLA:
                    # il bordo di lato della vasca di Bru, visto da sopra: pietra coi giunti, il lato esterno a filo
                    i = x - (RX - 5) if x < RX else RX + 33 - x
                    c = mur.V[53 + g % 51, 4 + i, :3]
                elif m in (PALO, PILONE):
                    su = y == 0 or not (tipo[y - 1, x] == 1 and Mb[y - 1, x] == m)
                    sx = not (tipo[y, x - 1] == 1 and Mb[y, x - 1] == m)
                    dx = not (tipo[y, x + 1] == 1 and Mb[y, x + 1] == m)
                    c = P[7] if (su or sx) else (P[4] if dx else P[6])
                    if m == PILONE:
                        sx2 = not (tipo[y, x - 2] == 1 and Mb[y, x - 2] == m)
                        dx2 = not (tipo[y, x + 2] == 1 and Mb[y, x + 2] == m)
                        c = P[0] if (sx or dx) else (P[7] if (su or sx2) else (P[4] if dx2 else P[6]))
                else:
                    c = AQ[4]
            elif k == 2:
                d, h = FD[y, x], FH[y, x]
                if m == ACQUA:
                    c = cas.colore(x, d, h)
                elif m in (SCALA, STRADA, LASTRA):      # le alzate (anche la prima, sotto la strada), la lastra
                    c = P[3] if d == 0 else (P[2] if d < h - 1 else P[1])
                elif m == PILASTRO:
                    c = P[0] if (d >= h - 1 or x in (RX - 4, RX + 32)) else (P[6] if x in (RX - 3, RX + 30) else P[4])
                elif m == PALO:
                    sx = not (tipo[y, x - 1] == 2 and Mb[y, x - 1] == PALO)
                    dx = not (tipo[y, x + 1] == 2 and Mb[y, x + 1] == PALO)
                    c = P[5] if d == 0 else (P[0] if d >= h - 1 else (P[6] if sx else (P[2] if dx else P[4])))
                elif m == PILONE:
                    c = mur.pilone(x, d, h, tipo, Mb, y)
                elif m in (SPALLA, PONTE):
                    c = P[5] if d == 0 else (P[3] if d < h - 1 else P[1])
                else:
                    c = mur.parete(x, d, h, m == ERBA)
            else:
                c = (255, 0, 255)
            img[y, x] = c
    # l'ombra che il pilone getta sulla parete alla sua destra
    for y in range(H):
        for x in range(W - 4):
            if tipo[y, x] == 2 and Mb[y, x] == PILONE and tipo[y, x + 1] == 2 and Mb[y, x + 1] != PILONE:
                for k, f in enumerate((0.6, 0.72, 0.86)):
                    if tipo[y, x + 1 + k] == 2 and Mb[y, x + 1 + k] not in (PILONE, ACQUA):
                        img[y, x + 1 + k] *= f
    # l'acqua come nella vasca di Bru: sotto le pareti e lungo le sponde di lato una riga scura e il filo chiaro,
    # poi una fascia scura che sfuma nella trama; verso la sponda di qua si scurisce (e' piu' fonda) fino al ciglio
    acq = (tipo == 1) & (Mb == ACQUA)
    du = _corsa(acq); dd = _corsa((acq | ((tipo == 2) & (Mb == ACQUA)))[::-1])[::-1]   # sopra la cascata non si scurisce
    dl = _corsa(acq.T).T; dr = _corsa(acq.T[::-1])[::-1].T

    def scurisci(c, n):
        return AQ[max(0, int(((AQ - c) ** 2).sum(1).argmin()) - n)]
    for y, x in zip(*np.nonzero(acq)):
        c = acqua[y % 192, x % 192]
        a, b, s = du[y, x], dd[y, x], min(dl[y, x], dr[y, x])
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
        elif a <= 5 or s <= 4 or b == 1:
            c = AQ[0]
        else:
            n = max(3 if a <= 9 else (2 if a <= 13 else (1 if a <= 16 else 0)),
                    3 if s <= 6 else (2 if s <= 8 else (1 if s <= 10 else 0)),
                    4 if b <= 3 else (3 if b <= 5 else (2 if b <= 8 else (1 if b <= 11 else 0))))
            # l'ombra del ponte sull'acqua, verso valle (la luce viene da sinistra)
            if dl[y, x] <= 7 and Mb[y, x - dl[y, x]] in (SPALLA, PALO, PONTE):
                n = max(n, 3 if dl[y, x] <= 5 else 2)
            if n:
                c = scurisci(c, n)
        img[y, x] = c
    sotto = du
    # dove cade l'acqua: due cerchi che si allargano, poi la schiuma a nuvola (dischi uniti, chiari sopra e piu'
    # azzurri sotto) un poco piu' larga della cascata, e qualche bolla staccata
    fondo = [y for y in range(H) if tipo[y, (FX0 + FX1) // 2] == 2 and Mb[y, (FX0 + FX1) // 2] == ACQUA][-1] + 1
    cx, cy = (FX0 + FX1 - 1) / 2, fondo
    for (rx, ry, col) in ((31, 11, AQ[7]), (40, 16, AQ[6])):
        for yy in range(int(cy), int(cy + ry + 2)):
            for xx in range(int(cx - rx - 2), int(cx + rx + 3)):
                e = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2
                if acq[yy, xx] and 0.88 <= e <= 1.0 and (xx // 3 + yy) % 4:
                    img[yy, xx] = col
    nuvola = np.zeros((H, W), int)
    for k in range(16):
        bx = cx + rng.uniform(-19, 19); by = cy + abs(rng.normal(0, 1)) * 3; rad = rng.uniform(2.2, 4.2)
        for yy in range(int(by - rad) - 1, int(by + rad) + 2):
            for xx in range(int(bx - rad) - 1, int(bx + rad) + 2):
                q = (xx - bx) ** 2 + (yy - by) ** 2
                if q <= rad * rad:
                    nuvola[yy, xx] = max(nuvola[yy, xx], 2 if (yy - by) < rad * 0.45 else 1)
    for yy, xx in zip(*np.nonzero(nuvola)):
        if acq[yy, xx]:
            img[yy, xx] = AQ[9] if nuvola[yy, xx] == 2 else AQ[8]
    for k in range(26):
        a = rng.uniform(0.15, np.pi - 0.15); rr = rng.uniform(0.9, 1.7)
        bx, by = int(cx + np.cos(a) * rr * 24), int(cy + np.sin(a) * rr * 8)
        if acq[by, bx] and not nuvola[by, bx]:
            img[by, bx] = AQ[9]
            if rng.random() < 0.4 and acq[by, bx + 1]:
                img[by, bx + 1] = AQ[8]
    for k in range(30):
        yy, xx = int(rng.integers(0, H)), int(rng.integers(0, W))
        if acq[yy, xx] and sotto[yy, xx] > 6:
            img[yy, xx] = AQ[9]
    # nel ruscello stretto la corrente: increspature allungate che seguono il filo dell'acqua verso ovest
    centro = np.full(W, np.nan)
    for x in range(0, 412):
        r = np.nonzero(acq[200:340, x])[0]
        if len(r) > 8:
            centro[x] = 200 + r.mean()
    for k in range(26):
        x0 = int(rng.integers(6, 408))
        if np.isnan(centro[x0]):
            continue
        y0 = int(round(centro[x0] + rng.uniform(-9, 9))); L = int(rng.integers(4, 9))
        for i in range(L):
            x = x0 + i
            if x >= W or np.isnan(centro[x]):
                break
            y = int(round(y0 + centro[x] - centro[x0]))
            if acq[y, x] and du[y, x] >= 7 and dd[y, x] >= 5 and min(dl[y, x], dr[y, x]) >= 4:
                img[y, x] = AQ[7] if 0 < i < L - 1 else AQ[6]
    terra = (tipo == 1) & (Mb == ERBA)
    cigli = []
    for x in range(W):
        for y in range(H):
            if not terra[y, x]:
                continue
            for k in range(1, 7):
                if y + k < H and tipo[y + k, x] == 2 and Zb[y + k, x] == Zb[y, x]:
                    img[y, x] = mur.cimasa_nord(x, 6 - k)
                    if k == 6:
                        cigli.append((y, x))
                    break
                if y + k >= H or tipo[y + k, x] != 1 or Zb[y + k, x] != Zb[y, x]:
                    break
            for k in range(1, 8):
                if y - k >= 0 and acq[y - k, x]:
                    img[y, x] = mur.cimasa_sud(x, k - 1); break
                if y - k < 0 or tipo[y - k, x] != 1 or acq[y - k, x] or Zb[y - k, x] != Zb[y, x]:
                    break
            for k in range(1, 8):
                if x + k < W and acq[y, x + k]:
                    img[y, x] = mur.cimasa_lato(True, k - 1, GY[y, x]); break
                if x - k >= 0 and acq[y, x - k]:
                    img[y, x] = mur.cimasa_lato(False, k - 1, GY[y, x]); break
    # l'erba che ricade sulla cimasa a ciuffi: il ciglio non e' piu' una riga dritta
    ricade = np.zeros(W + 8, int); x = int(rng.integers(0, 6))
    while x < W:
        n = int(rng.integers(2, 7)); alto = int(rng.integers(1, 4))
        for i in range(n):
            ricade[x + i] = max(1, alto - abs(i - n // 2) + (1 if rng.random() < 0.3 else 0))
        x += n + int(rng.integers(3, 14))
    for (y, x) in cigli:
        luce = 1 if Zb[y, x] >= 30 else (-1 if Zb[y, x] <= -30 else 0)
        for j in range(ricade[x]):
            if y + j < H and terra[y + j, x]:
                img[y + j, x] = VERDI[2] if j == ricade[x] - 1 else erba.colore(x, GY[y + j, x], luce)
    # l'ombra ai piedi delle pareti e i contorni dove un pavimento alto confina di lato con uno basso
    for x in range(W):
        for y in range(1, H):
            if tipo[y - 1, x] == 2 and tipo[y, x] == 1 and Mb[y, x] != ACQUA:
                for k, f in enumerate((0.58, 0.72, 0.86)):
                    if y + k < H and tipo[y + k, x] == 1 and Mb[y + k, x] != ACQUA:
                        img[y + k, x] *= f
    # l'erba del piano di sotto che sale a ciuffi sul piede della parete (nell'ombra della parete)
    sale = np.zeros(W + 8, int); x = int(rng.integers(0, 9))
    while x < W:
        n = int(rng.integers(2, 6)); alto = int(rng.integers(2, 5))
        for i in range(n):
            sale[x + i] = max(1, alto - abs(i - n // 2) - (1 if rng.random() < 0.35 else 0))
        x += n + int(rng.integers(4, 18))
    for x in range(W):
        if not sale[x]:
            continue
        for y in range(1, H):
            if (tipo[y - 1, x] == 2 and Mb[y - 1, x] == ERBA and tipo[y, x] == 1 and Mb[y, x] == ERBA):
                for j in range(1, sale[x] + 1):
                    if tipo[y - j, x] == 2 and Mb[y - j, x] == ERBA:
                        img[y - j, x] = (VERDI[2] if j == sale[x] else VERDI[4 + (x + j) % 2]) * 0.8
    out = img.copy()
    for y in range(H):
        for x in range(W):
            if tipo[y, x] != 1:
                continue
            for (a, b) in ((y, x - 1), (y, x + 1), (y - 1, x)):
                if 0 <= a < H and 0 <= b < W and tipo[a, b] == 1 and Zb[a, b] < Zb[y, x] - 2:
                    out[y, x] = P[0] if Mb[y, x] in (PILASTRO, SPALLA) else img[y, x] * 0.45
                    break
    # la piazzetta: l'anello del kit e il ramo verso la vasca
    K = os.path.join(TER, 'strade_radenna')

    def kit(n):
        return np.asarray(Image.open(os.path.join(K, n + '.png')).convert('RGBA')).astype(float)
    x = CXA + 31
    while x < 440:
        _posa(out, kit('strada_orizzontale')[:, :min(55, 440 - x)], x, CYA - 14); x += 55
    _posa(out, kit('fine_strada_dx'), 440, CYA - 14)
    _posa(out, kit('anello'), CXA - 38, CYA - 38)
    _posa(out, kit('tratto_corto'), LX, LG - 50)
    return out, G


# ================================================================ gli oggetti

# le cose piatte, dipinte nel terreno: luci nell'erba, ninfee (solo sull'acqua), sassi nella pozza, piede delle canne
LUCI = [(0, 266, 16), (2, 290, 30), (3, 252, 38), (1, 520, 56), (3, 540, 70), (0, 344, 300), (2, 366, 290),
        (1, 150, 344), (3, 172, 358), (2, 136, 362), (1, 420, 352), (3, 440, 330), (0, 30, 186), (2, 52, 200)]
NINFEE = [('radenna/ninfee_loto.png', 404, 272, (52, 82)), ('radenna/ninfee_fiori.png', 40, 318, (29, 85))]
# i resti del lastricato attorno alla colonna (i pezzi rotti del kit delle strade): li' c'era una piazzetta
RUDERI = [('rovina_1', 262, 76), ('rovina_2', 352, 66), ('rovina_3', 404, 46)]
SASSI_ACQUA = [('rocce/sasso_4.png', 448, 240, (9, 15)), ('rocce/sassolino_1.png', 476, 243, (5, 8))]
CANNE = [(562, 262, False), (132, 302, True)]           # piede (x, y) e se e' specchiata
# le cose in piedi: file (da art/livelli/), piede nel mondo, piede nel disegno, impronta (dove non si passa)
#   l'impronta e' (mezza larghezza, mezza altezza) dell'ovale ai piedi: il tronco, la base
CESP = 'pezzi/ruscello/cespuglione_verde.png'
IN_PIEDI = [
    ('pezzi/alberi/albero_funghi.png', 70, 82, (69, 124), (10, 5)),
    ('pezzi/ruscello/albero_funghi_s.png', 168, 60, (76, 124), (10, 5)),
    ('pezzi/radenna/colonna_rovina.png', 322, 100, (45, 101), (22, 6)),
    (CESP, 590, 88, (64, 124), (30, 7)),
    ('pezzi/rocce/masso_muschio_8.png', 382, 106, (16, 22), (14, 4)),
    ('pezzi/rocce/sasso_5.png', 400, 110, (9, 15), (7, 3)),
    ('pezzi/rocce/masso_muschio_3.png', 112, 152, (14, 20), (12, 4)),
    ('pezzi/rocce/sassolino_2.png', 128, 156, (7, 10), (6, 3)),
    ('pezzi/rocce/masso_basso_4.png', 352, 180, (15, 15), (13, 4)),
    ('pezzi/ruscello/canne_steli.png', 562, 262 - 27, (48, 71), (0, 0)),       # attaccati al piede dipinto
    ('pezzi/ruscello/canne_steli_s.png', 132, 302 - 27, (36, 71), (0, 0)),
    ('pezzi/radenna/vasca_pietra.png', 506, 366, (53, 88), (40, 9)),
    ('pezzi/alberi/albero_funghi.png', 64, 478, (69, 124), (10, 5)),
    ('pezzi/ruscello/cespuglione_verde_s.png', 600, 476, (59, 124), (30, 7)),
    ('pezzi/rocce/masso_muschio_9.png', 156, 382, (17, 20), (14, 4)),
    ('pezzi/rocce/sasso_2.png', 174, 386, (8, 12), (6, 3)),
    ('pezzi/ruscello/baccelli.png', 528, 96, (26, 54), (8, 4)),
    ('pezzi/ruscello/baccelli_s.png', 404, 398, (25, 54), (8, 4)),
    ('pezzi/ruscello/bulbi.png', 118, 352, (15, 28), (6, 3)),
    ('pezzi/ruscello/bulbi.png', 134, 360, (15, 28), (6, 3)),
    ('pezzi/ruscello/bulbi.png', 372, 296, (15, 28), (6, 3)),
    ('pezzi/ruscello/bulbi.png', 58, 184, (15, 28), (6, 3)),
    ('pezzi/ruscello/bulbi.png', 600, 228, (15, 28), (6, 3)),
    ('pezzi/rocce/masso_muschio_1.png', 360, 398, (13, 19), (12, 4)),
    ('pezzi/rocce/sassolino_3.png', 376, 402, (6, 11), (5, 3)),
]


def _e_acqua_del_pezzo(c):
    r, g, b = c[0], c[1], c[2]
    return g > r + 40 and b > 0.72 * g and b < g + 10 and b > 90


def decora(out, G):
    tipo, Mb = G['tipo'], G['m']
    acq = (tipo == 1) & (Mb == ACQUA)
    for (n, x0, y0) in RUDERI:          # prima i resti del lastricato: le luci ci possono stare sopra
        a = np.asarray(Image.open(os.path.join(TER, 'strade_radenna', n + '.png')).convert('RGBA')).astype(float)
        for j in range(a.shape[0]):
            for i in range(a.shape[1]):
                y, x = y0 + j, x0 + i
                if 0 <= y < H and 0 <= x < W and a[j, i, 3] > 0 and tipo[y, x] == 1 and Mb[y, x] == ERBA:
                    out[y, x] = a[j, i, :3]
    for (k, x0, y0) in LUCI:
        l = np.asarray(Image.open(os.path.join(NUOVI, 'luce_%d.png' % k)).convert('RGBA')).astype(float)
        for j in range(l.shape[0]):
            for i in range(l.shape[1]):
                y, x = y0 + j, x0 + i
                if 0 <= y < H and 0 <= x < W and l[j, i, 3] > 0 and tipo[y, x] == 1 and Mb[y, x] == ERBA:
                    out[y, x] = l[j, i, :3]
    for (cx, cy, rx, ry) in ((448, 238, 9, 3), (476, 242, 6, 2)):          # la schiuma attorno ai sassi
        for y in range(int(cy - ry - 2), int(cy + ry + 3)):
            for x in range(int(cx - rx - 2), int(cx + rx + 3)):
                if acq[y, x]:
                    e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                    if 0.75 <= e <= 1.15 and (x + y) % 3:
                        out[y, x] = AQ[9] if e < 1 else AQ[8]
    for (f, fx, fy, piede) in NINFEE + SASSI_ACQUA:
        a = np.asarray(Image.open(os.path.join(PEZ, f)).convert('RGBA')).astype(float)
        sull_acqua = f.startswith('radenna')
        for j in range(a.shape[0]):
            for i in range(a.shape[1]):
                y, x = fy - piede[1] + j, fx - piede[0] + i
                if 0 <= y < H and 0 <= x < W and a[j, i, 3] > 0:
                    if sull_acqua and (not acq[y, x] or _e_acqua_del_pezzo(a[j, i])):
                        continue
                    out[y, x] = a[j, i, :3]
    c = np.asarray(Image.open(os.path.join(PEZ, 'radenna', 'canne_luminose.png')).convert('RGBA')).astype(float)
    for (fx, fy, specchio) in CANNE:
        a = c[:, ::-1] if specchio else c
        px = a.shape[1] - 1 - 48 if specchio else 48
        for j in range(a.shape[0] - 28, a.shape[0]):
            for i in range(a.shape[1]):
                y, x = fy - 98 + j, fx - px + i
                if 0 <= y < H and 0 <= x < W and a[j, i, 3] > 0 and acq[y, x]:
                    out[y, x] = a[j, i, :3]
    return out


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


def luce_turchese(out, G):
    # la luce dell'acqua e delle piante luminose sul prato, sulla pietra e sulla strada (non sull'acqua): a tre
    # gradini, con un retino 4x4 dove un gradino passa nell'altro
    tipo, Mb = G['tipo'], G['m']
    acque = (Mb == ACQUA)
    L = _sfoca(acque.astype(float), 7) * 0.9
    Y, X = np.mgrid[:H, :W]
    for (x, y, f, r) in SORGENTI:
        L += f * np.exp(-((X - x) ** 2 + (Y - y) ** 2) / (2.0 * r * r))
    for (k, x0, y0) in LUCI:
        L += 0.3 * np.exp(-((X - x0 - 6) ** 2 + (Y - y0 - 6) ** 2) / (2.0 * 7 * 7))
    bayer = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
    q = np.clip(np.floor(np.clip(L, 0, 1) * 3.2 + bayer[Y % 4, X % 4] - 0.35), 0, 3).astype(int)
    k = np.array([0.0, 0.07, 0.14, 0.24])[q]
    k[acque] = 0
    out = out + k[..., None] * np.array([10.0, 150.0, 125.0])[None, None]
    return np.clip(out, 0, 255)


def ombre(out, G):
    # l'ombra ovale per terra di ogni cosa in piedi (luce da in alto a sinistra: l'ombra va un poco a destra)
    tipo, Mb = G['tipo'], G['m']
    bayer = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
    for (f, fx, fy, piede, impronta) in IN_PIEDI:
        if impronta == (0, 0):
            continue
        w = Image.open(os.path.join(LIV, f)).size[0]
        if 'albero' in f or 'cespuglione' in f:
            # sotto le chiome il prato e' all'ombra: una macchia larga, a due gradini col retino in mezzo
            rx = 0.56 * w; ry = 0.24 * w; cx, cy = fx + 5, fy - 3
            for y in range(int(cy - ry - 1), int(cy + ry + 2)):
                for x in range(int(cx - rx - 1), int(cx + rx + 2)):
                    if 0 <= y < H and 0 <= x < W and tipo[y, x] == 1 and Mb[y, x] != ACQUA:
                        e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                        if e <= 1:
                            gr = 2 if e + bayer[y % 4, x % 4] * 0.3 < 0.55 else 1
                            out[y, x] *= 0.8 if gr == 2 else 0.9
        rx = max(5.0, 0.32 * w); ry = max(2.5, rx * 0.32); cx, cy = fx + 3, fy - 1
        for y in range(int(cy - ry - 1), int(cy + ry + 2)):
            for x in range(int(cx - rx - 1), int(cx + rx + 2)):
                if 0 <= y < H and 0 <= x < W and tipo[y, x] == 1 and Mb[y, x] != ACQUA:
                    e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                    if e <= 1:
                        out[y, x] *= 0.62 if e < 0.55 else 0.78
    return out


def anteprima(terreno):
    # il terreno con tutte le cose in piedi, in ordine di piede (come le mette il gioco)
    out = terreno.astype(float).copy()
    for (f, fx, fy, piede, _) in sorted(IN_PIEDI, key=lambda c: c[2]):
        a = np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA')).astype(float)
        _posa(out, a, fx - piede[0], fy - piede[1])
    return out


def passi(G):
    # dove si cammina: i pavimenti d'erba, strada e ponte, tutta la scala (pedate e alzate); non l'acqua, non le
    # pareti, non le spallette e i fianchi della scala, non le impronte delle cose in piedi
    tipo, Mb = G['tipo'], G['m']
    ok = (((tipo == 1) & np.isin(Mb, [ERBA, STRADA, PONTE, SCALA, LASTRA]))
          | ((tipo == 2) & np.isin(Mb, [SCALA, STRADA])))
    for (f, fx, fy, piede, (rx, ry)) in IN_PIEDI:
        if rx == 0:
            continue
        yy, xx = np.ogrid[:H, :W]
        ok &= ((xx - fx) / rx) ** 2 + ((yy - fy) / ry) ** 2 > 1
    m = np.zeros((H, W, 4), np.uint8); m[ok] = (255, 255, 255, 255)
    return m


def main():
    prepara()
    t = pianta()
    terreno, G = disegna(t)
    terreno = decora(terreno, G)
    terreno = luce_turchese(terreno, G)
    terreno = ombre(terreno, G)
    _salva(terreno, os.path.join(LIV, 'ruscello.png'))
    _salva(passi(G).astype(float), os.path.join(LIV, 'ruscello_passi.png'))
    with open(os.path.join(LIV, 'ruscello_pezzi.json'), 'w') as f:
        json.dump({"_nota": "Scritto da strumenti/livelli/ruscello_radenna.py: non toccare a mano. Ogni pezzo e' "
                            "[file (da art/livelli/), x, y del piede nel mondo, x, y del piede nel disegno].",
                   "pezzi": [[p[0], p[1], p[2], p[3][0], p[3][1]] for p in sorted(IN_PIEDI, key=lambda c: c[2])]},
                  f, indent=1, ensure_ascii=False)
        f.write('\n')
    pianta_json = {
        "_nota": "La sezione del ruscello di Radenna, fatta a piani da strumenti/livelli/ruscello_radenna.py: la "
                 "terrazza col canale e la cascata, la pozza e il ruscello col ponte, la piazzetta, la scala verso "
                 "l'atterraggio. Non e' ancora un livello del gioco: per provarla.",
        "nome": "Il ruscello di Radenna",
        "mappa": "ruscello.png", "scala": 1, "pixel": 1, "ingrandimento": 2,
        "_scala": "La mappa e' alla misura del mondo (un pixel, un pixel del mondo, come lei); la telecamera "
                  "ingrandisce due volte.",
        "pezzi": "ruscello_pezzi.json",
        "passi": "ruscello_passi.png",
        "erba": {"tinta": [0.2, 0.47], "saturazione": 0.42, "luce": [0.1, 0.85]},
        "limiti": [0, 0, W, H],
        "partenza": [246, 470], "verso": [0, -1],
        "stanze": [
            {"nome": "La scala dell'atterraggio", "rett": [0, 410, W, H]},
            {"nome": "La piazzetta", "rett": [0, 300, W, 410]},
            {"nome": "Il ponte sul ruscello", "rett": [0, 168, W, 300]},
            {"nome": "La terrazza della cascata", "rett": [0, 0, W, 168]},
        ],
        "giro": [[246, 470], [246, 440], [246, 400], [246, 360], [300, 345], [420, 345], [300, 345], [246, 320],
                 [246, 280], [246, 240], [246, 200], [246, 170], [246, 140], [246, 110], [420, 36], [520, 36],
                 [420, 36], [246, 40]],
        "_giro": "Dalla scala dell'atterraggio alla piazzetta, fino alla vasca e indietro, sul ponte, su per la scala "
                 "della terrazza, di la' dal canale sulla lastra e indietro.",
    }
    with open(os.path.join(LIV, 'ruscello.json'), 'w') as f:
        json.dump(pianta_json, f, indent=1, ensure_ascii=False)
        f.write('\n')
    if len(sys.argv) > 1:
        _salva(anteprima(terreno), sys.argv[1])
    print('ruscello: mappa %dx%d, %d cose in piedi' % (W, H, len(IN_PIEDI)))


if __name__ == '__main__':
    main()
