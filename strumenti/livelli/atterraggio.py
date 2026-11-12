# La zona d'atterraggio delle Pianure, rifatta uguale al disegno di Bru
# (strumenti/livelli/fogli/atterraggio.jpg), a colori piatti: senza raggi di
# luce, bagliori e chiaroscuri (la luce si mette dopo, nel gioco).
#
#   python3 strumenti/livelli/atterraggio.py      (serve numpy e Pillow)
#
# Il disegno dice dove sta ogni cosa: i suoi colori si raggruppano (k-medie) e
# ogni gruppo e' un materiale (acqua, sabbia, parete, erba, terra); la parete
# vera ha le righe verticali. I materiali si lisciano e si ridisegnano piatti,
# coi loro contorni; i pezzi (pini, cespugli, capsula, scala, cascate,
# muretti, resti del pasto, ninfee, sassi) si rimettono negli stessi posti.
# Scrive art/livelli/atterraggio.png, un pixel per pixel del mondo.
import os
import numpy as np, math, sys
from PIL import Image
QUI = os.path.dirname(os.path.abspath(__file__))
rif = np.array(Image.open(os.path.join(QUI, 'fogli', 'atterraggio.jpg')).convert('RGB')).astype(float)
H, W, _ = rif.shape


def box(a, k):
    a = a.astype(float)
    p = np.pad(a, k, mode='edge')
    c = p.cumsum(0).cumsum(1)
    c = np.pad(c, ((1, 0), (1, 0)))
    n = 2 * k + 1
    return (c[n:, n:] - c[:-n, n:] - c[n:, :-n] + c[:-n, :-n]) / (n * n)


# i gruppi di colore: k-medie (18) sul disegno appena sfocato
p_ = np.pad(rif, ((1, 1), (1, 1), (0, 0)), mode='edge')
sf = sum(p_[dy:dy + H, dx:dx + W] for dy in range(3) for dx in range(3)) / 9
X_ = sf.reshape(-1, 3)
rng_ = np.random.default_rng(1)
K_ = 18
centri = X_[rng_.choice(len(X_), K_, replace=False)]
sub = X_[rng_.choice(len(X_), 60000, replace=False)]
for _ in range(30):
    l_ = ((sub[:, None, :] - centri[None]) ** 2).sum(2).argmin(1)
    centri = np.array([sub[l_ == k].mean(0) if (l_ == k).any() else centri[k] for k in range(K_)])
lab_grezzo = ((X_[:, None, :] - centri[None]) ** 2).sum(2).argmin(1).reshape(H, W)
lab = lab_grezzo
# la parete vera ha le righe verticali: la luminanza cambia molto piu' in
# orizzontale che in verticale, e il colore e' beige
L_ = rif.mean(2)
gx_ = np.zeros_like(L_); gy_ = np.zeros_like(L_)
gx_[:, 1:-1] = np.abs(L_[:, 2:] - L_[:, :-2]); gy_[1:-1] = np.abs(L_[2:] - L_[:-2])
GX_, GY_ = box(gx_, 6), box(gy_, 6)
r_, g_, b_ = rif[..., 0], rif[..., 1], rif[..., 2]
aniso = (GX_ > 9) & (GX_ > 1.5 * GY_) & (r_ > g_ - 5) & (g_ > b_) & (r_ > 90)
ACQUA, SABBIA, PARETE, ERBA, SCURA, TERRA = range(6)


def poligono(pts):
    """maschera di un poligono (centri dei pixel)"""
    m = np.zeros((H, W), bool)
    ys = [p[1] for p in pts]
    for y in range(max(0, int(min(ys))), min(H, int(max(ys)) + 1)):
        cy = y + 0.5
        tagli = []
        for k in range(len(pts)):
            (ax, ay), (bx, by) = pts[k], pts[k - 1]
            if (ay <= cy < by) or (by <= cy < ay):
                tagli.append(ax + (cy - ay) * (bx - ax) / (by - ay))
        tagli.sort()
        for a, b in zip(tagli[0::2], tagli[1::2]):
            m[y, max(0, int(math.ceil(a - 0.5))):min(W, int(math.ceil(b - 0.5)))] = True
    return m


def moda(c, k, n, classi=7):
    for _ in range(n):
        c = np.stack([box(c == i, k) for i in range(classi)]).argmax(0)
    return c


# ---------------------------------------------------------------- i materiali
gruppi = {ACQUA: [3, 7, 8, 15, 17], SABBIA: [5, 12, 13, 4], PARETE: [2, 11, 14], ERBA: [9, 6], SCURA: [1, 10, 16, 0]}
quote = {k: box(np.isin(lab, v), 5) for k, v in gruppi.items()}
righe = box(np.isin(lab, [11, 14]), 4)
cl = np.argmax(np.stack([quote[k] for k in range(5)]), 0)
cl[(righe > 0.18) & (cl == SABBIA)] = PARETE
cl[(quote[PARETE] + righe > 0.45) & (cl != ACQUA) & (cl != ERBA) & (cl != SCURA)] = PARETE
# la parete vera ha le righe verticali: senza righe intorno e' sabbia in ombra
cl[(cl == PARETE) & (box(aniso, 9) < 0.10)] = SABBIA
# il fondo scuro e' prato (il buio era ombra); i boschi e i cespugli sono pezzi
cl[cl == SCURA] = ERBA
CAMPO = [(905, 215), (985, 212), (1000, 170), (1040, 155), (1100, 160), (1130, 185), (1135, 230), (1100, 250),
         (1075, 262), (1075, 345), (1045, 352), (1018, 332), (1015, 262), (985, 250), (905, 250)]
campo_dentro = poligono([(895, 100), (1190, 100), (1190, 370), (895, 370)])
cl[campo_dentro & (cl == TERRA)] = ERBA
cl[campo_dentro & (cl == SABBIA)] = ERBA
cl[poligono(CAMPO)] = TERRA
cl = moda(cl, 4, 2)
# le pareti regolari: chiusi i buchi in orizzontale, via i pezzetti, e gli
# orli di cima e di fondo lisciati colonna per colonna
def regola(m):
    def allarga(a, k, asse):
        r = a.copy()
        for d in range(1, k + 1):
            if asse == 1:
                r[:, d:] |= a[:, :-d]; r[:, :-d] |= a[:, d:]
            else:
                r[d:] |= a[:-d]; r[:-d] |= a[d:]
        return r
    m = ~allarga(~allarga(m, 7, 1), 7, 1)
    m = ~allarga(~allarga(m, 3, 0), 3, 0)
    # le strisce di ogni colonna
    strisce = []
    for x in range(W):
        col = m[:, x]
        s_, y = [], 0
        d = np.diff(np.concatenate([[0], col.astype(int), [0]]))
        a = np.where(d == 1)[0]; b = np.where(d == -1)[0]
        strisce.append([(int(p), int(q)) for p, q in zip(a, b) if q - p >= 6])
    R = 10
    for _ in range(2):
        nuove = []
        for x in range(W):
            col = []
            for y0, y1 in strisce[x]:
                cime, fondi = [], []
                for xx in range(max(0, x - R), min(W, x + R + 1)):
                    for p, q in strisce[xx]:
                        if p < y1 and q > y0:
                            cime.append(p); fondi.append(q)
                col.append((int(round(np.mean(cime))), int(round(np.mean(fondi)))))
            nuove.append(col)
        strisce = nuove
    out = np.zeros_like(m)
    for x in range(W):
        for p, q in strisce[x]:
            out[p:q, x] = True
    return out


par = regola(cl == PARETE)
cl[(cl == PARETE) & ~par] = SABBIA
cl[par & (cl != ACQUA)] = PARETE
# il prato della capsula: tutto erba
PRATO = [(500, 292), (560, 286), (770, 296), (850, 360), (915, 418), (860, 470), (760, 498), (640, 498), (560, 470),
         (500, 400)]
pr = poligono(PRATO)
# sotto la capsula (che e' un pezzo) c'e' il prato
cl[poligono([(660, 330), (752, 330), (752, 440), (660, 440)])] = ERBA

# ---------------------------------------------------------------- i colori (piatti)
def c(s):
    return np.array([int(s[1:3], 16), int(s[3:5], 16), int(s[5:7], 16)], np.uint8)


ACQUA_BASE, ACQUA_FILO, ACQUA_SCHIUMA = c('#1890aa'), c('#0e5a78'), c('#5ccad2')
SABBIA_BASE, SABBIA_SEGNO, SABBIA_ORLO = c('#e2d6ac'), c('#c8b98a'), c('#b49c70')
ROCCIA_BASE, ROCCIA_CHIARA, ROCCIA_RIGA, ROCCIA_PIEDE = c('#c4a374'), c('#dcc398'), c('#94785a'), c('#5e4c40')
ERBA_BASE, ERBA_CIUFFO, ERBA_ORLO = c('#3ca236'), c('#2a842e'), c('#24702a')
TERRA_BASE, TERRA_SEGNO, TERRA_ORLO = c('#bc9564'), c('#9a7448'), c('#86643e')

out = np.zeros((H, W, 3), np.uint8)
base = {ACQUA: ACQUA_BASE, SABBIA: SABBIA_BASE, PARETE: ROCCIA_BASE, ERBA: ERBA_BASE, TERRA: TERRA_BASE}
for k, v in base.items():
    out[cl == k] = v


def vicino(m, k=1):
    """dove, entro k pixel (in croce), c'e' m"""
    r = np.zeros_like(m)
    for d in range(1, k + 1):
        r[d:] |= m[:-d]; r[:-d] |= m[d:]; r[:, d:] |= m[:, :-d]; r[:, :-d] |= m[:, d:]
    return r


acqua = cl == ACQUA
sabbia = cl == SABBIA
parete = cl == PARETE
erba = cl == ERBA
terra = cl == TERRA

# la roccia: colonne verticali larghe 6-11, ognuna con la riga chiara a
# sinistra e la riga scura a destra, e una crepa a meta' altezza
bordi = []
x = 0
rng = np.random.default_rng(3)
while x < W:
    bordi.append(x)
    x += int(rng.integers(6, 12))
col_di = np.zeros(W, int)
for i, b in enumerate(bordi):
    col_di[b:] = i
sinistra = np.zeros(W, bool); destra = np.zeros(W, bool)
for i, b in enumerate(bordi):
    sinistra[b] = True
    if b > 0:
        destra[b - 1] = True
Y, X = np.mgrid[0:H, 0:W]
crepa = ((Y + col_di[X] * 13) % 23 == 0)
out[parete & sinistra[X]] = ROCCIA_CHIARA
out[parete & destra[X]] = ROCCIA_RIGA
out[parete & crepa & ~sinistra[X] & ~destra[X]] = ROCCIA_RIGA
# l'orlo in cima alla parete (sotto la sabbia o l'erba) e il piede scuro in fondo
sopra = np.zeros_like(parete); sopra[1:] = ~parete[:-1]
sotto = np.zeros_like(parete); sotto[:-1] = ~parete[1:]
sotto2 = np.zeros_like(parete); sotto2[:-2] = ~parete[2:]
out[parete & sopra] = SABBIA_ORLO
out[parete & (sotto | sotto2)] = ROCCIA_PIEDE

# l'acqua: il filo scuro lungo la riva, la schiuma chiara subito dentro
riva = acqua & vicino(~acqua, 1)
out[acqua & vicino(~acqua, 3) & ~riva] = ACQUA_SCHIUMA
out[acqua & vicino(~acqua, 2) & ~vicino(~acqua, 1)] = ACQUA_BASE
out[riva] = ACQUA_FILO
# la sabbia: l'orlo dove tocca l'acqua, qualche segno
out[sabbia & vicino(acqua, 2)] = SABBIA_ORLO
segno = ((X // 3 + Y // 2 * 7) % 37 == 0) & ((Y % 2) == 0)
out[sabbia & segno & ~vicino(~sabbia, 3)] = SABBIA_SEGNO
# l'erba: l'orlo dove finisce, i ciuffi
out[erba & vicino(~erba, 1) & ~vicino(acqua, 1)] = ERBA_ORLO
ciuffo = (((X + (Y // 9) * 5) % 17 == 0) & (Y % 9 < 2)) | (((X + (Y // 9) * 5) % 17 == 2) & (Y % 9 == 0))
out[erba & ciuffo & ~vicino(~erba, 3)] = ERBA_CIUFFO
# la terra: l'orlo, i sassolini
out[terra & vicino(~terra, 1)] = TERRA_ORLO
out[terra & ((X * 7 + Y * 3) % 61 == 0) & ~vicino(~terra, 3)] = TERRA_SEGNO



# ================================================================ i pezzi
from collections import deque


def via_piccoli(m, minimo):
    """via le macchie di m piu' piccole di minimo pixel"""
    vis = np.zeros_like(m)
    out = m.copy()
    for y0, x0 in zip(*np.nonzero(m)):
        if vis[y0, x0]:
            continue
        q = deque([(y0, x0)]); vis[y0, x0] = True; cel = []
        while q:
            y, x = q.popleft(); cel.append((y, x))
            for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if 0 <= yy < H and 0 <= xx < W and m[yy, xx] and not vis[yy, xx]:
                    vis[yy, xx] = True; q.append((yy, xx))
        if len(cel) < minimo:
            for y, x in cel:
                out[y, x] = False
    return out


tela = Image.fromarray(out).convert('RGBA')


def col(s, a=255):
    return (int(s[1:3], 16), int(s[3:5], 16), int(s[5:7], 16), a)


class Sprite:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.p = {}

    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.p[(x, y)] = c

    def contorno(self, c):
        for (x, y) in list(self.p):
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                if (x + dx, y + dy) not in self.p and 0 <= x + dx < self.w and 0 <= y + dy < self.h:
                    self.p.setdefault((x + dx, y + dy), None)
        for k, v in list(self.p.items()):
            if v is None:
                self.p[k] = c

    def immagine(self):
        im = Image.new('RGBA', (self.w, self.h), (0, 0, 0, 0))
        for (x, y), c in self.p.items():
            im.putpixel((x, y), c)
        return im


PINO_BASE, PINO_RIGA, PINO_BORDO = col('#22703a'), col('#185a30'), col('#0e3624')
TRONCO, TRONCO_BORDO = col('#7a4a2a'), col('#3a2214')


def pino(w=58, h=82, palchi=4):
    """un pino paffuto: palchi larghi, col fondo a smerli tondi (i rami che
    pendono), una riga scura sotto ogni palco, il tronco corto"""
    s = Sprite(w, h)
    cx = w / 2
    for y in range(h - 10, h - 2):
        for x in range(int(cx - 4), int(cx + 4)):
            s.put(x, y, TRONCO)
    alto = h - 10
    for k in reversed(range(palchi)):
        cima = 1 + k * alto * 0.19
        fondo = cima + alto * 0.36
        mezza = (w / 2 - 2) * (0.42 + 0.58 * (k + 1) / palchi)
        for y in range(int(cima), int(fondo) + 5):
            f = (y + 0.5 - cima) / (fondo - cima)
            m = mezza * max(0.0, min(1.0, f)) ** 0.75
            for x in range(w):
                dx = x + 0.5 - cx
                if abs(dx) > m + 1:
                    continue
                # gli smerli: archi larghi 7 che pendono
                u = ((x + 2 * k) % 7) / 7.0
                giu = fondo + 3.5 * math.sqrt(max(0.0, 1 - (2 * u - 1) ** 2))
                if y + 0.5 > giu or abs(dx) > m:
                    continue
                c = PINO_RIGA if y + 0.5 > giu - 2 else PINO_BASE
                s.put(x, y, c)
    s.contorno(PINO_BORDO)
    return s.immagine()


CESPUGLIO_BASE, CESPUGLIO_RIGA, CESPUGLIO_BORDO = col('#2a7a3a'), col('#1e6030'), col('#0f3a22')


def cespugli(m):
    """una massa di cespugli: ciuffi tondi di 10 pixel, a file sfalsate; ogni
    ciuffo col suo bordo di sotto piu' scuro"""
    s = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    px = s.load()
    ys, xs = np.nonzero(m)
    if len(ys) == 0:
        return s
    pieno = np.zeros((H, W), bool)
    for j, y in enumerate(range(ys.min(), ys.max() + 8, 7)):
        for x in range(xs.min() - 4 + (j % 2) * 5, xs.max() + 8, 10):
            if not (0 <= y < H and 0 <= x < W) or not m[y, x]:
                continue
            for dy in range(-6, 7):
                for dx in range(-6, 7):
                    yy, xx = y + dy, x + dx
                    if 0 <= yy < H and 0 <= xx < W and dx * dx + dy * dy <= 30:
                        d = math.hypot(dx, dy)
                        px[xx, yy] = CESPUGLIO_RIGA if (d > 4.2 and dy > 1) else CESPUGLIO_BASE
                        pieno[yy, xx] = True
    bordo = vicino(pieno, 1) & ~pieno
    for y, x in zip(*np.nonzero(bordo)):
        px[x, y] = CESPUGLIO_BORDO
    return s


CAPSULA, CAPSULA_FASCIA, CAPSULA_BORDO, VETRO, VETRO_BORDO = col('#e4943a'), col('#a8582a'), col('#4a2614'), \
    col('#2f6fd0'), col('#1e2a4a')


def capsula(w=68, h=78):
    """la capsula: un uovo con la punta in su, la fascia scura alla base,
    l'oblo' blu, la riga dello sportello"""
    s = Sprite(w, h)
    cx = w / 2
    R = w / 2 - 2
    yc = h * 0.66           # dove l'uovo e' piu' largo
    for y in range(h - 2):
        py = y + 0.5
        if py < yc:
            m = R * math.sqrt(max(0.0, 1 - ((py - yc) / yc) ** 2)) ** 1.15
        else:
            m = R * math.sqrt(max(0.0, 1 - ((py - yc) / (h - 2 - yc)) ** 2 * 0.55))
        for x in range(w):
            if abs(x + 0.5 - cx) <= m:
                f = py / (h - 2)
                s.put(x, y, CAPSULA_FASCIA if f > 0.80 else CAPSULA)
    for y in range(int(h * 0.44), int(h * 0.78)):
        for x in range(int(cx - 11), int(cx + 11)):
            dx, dy = (x + 0.5 - cx) / 10, (y + 0.5 - h * 0.61) / (h * 0.15)
            if dx * dx + dy * dy <= 1:
                s.put(x, y, VETRO if dx * dx + dy * dy < 0.55 else VETRO_BORDO)
    for x in range(int(cx - 13), int(cx + 14)):
        s.put(x, int(h * 0.34), CAPSULA_FASCIA)
    s.contorno(CAPSULA_BORDO)
    return s.immagine()


def scala(x0, y0, x1, y1):
    for y in range(y0, y1):
        for x in range(x0, x1):
            v = (y - y0) % 7
            c = (ROCCIA_PIEDE if x in (x0, x1 - 1) else ROCCIA_RIGA if x - x0 < 4 or x1 - x <= 4 else
                 SABBIA_BASE if v < 4 else ROCCIA_BASE if v < 6 else ROCCIA_RIGA)
            out[y, x] = c


def cascata(x0, y0, x1, y1):
    for y in range(y0, y1):
        for x in range(x0, x1):
            c = ACQUA_SCHIUMA if (x * 5 + (y // 4)) % 7 in (0, 3) else c_('#c8f0f4') if x in (x0, x1 - 1) else ACQUA_BASE
            out[y, x] = c
    for y in range(y1, y1 + 5):
        for x in range(x0 - 4, x1 + 4):
            if 0 <= y < H and acqua[y, x]:
                out[y, x] = c_('#c8f0f4') if (x + y) % 3 else ACQUA_SCHIUMA


def c_(s):
    return c(s)


MURO, MURO_RIGA, MURO_FACCIA, MURO_BORDO, MUSCHIO = col('#a6a882'), col('#7e8062'), col('#7a7c5c'), col('#3a3e2c'), \
    col('#6a8a44')


def muro(x0, y0, x1, y1):
    """un muretto visto da sopra: il piano a blocchi, la faccia davanti
    (alta 7), il muschio a chiazze, il contorno"""
    s = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    px = s.load()
    for y in range(y0, y1):
        for x in range(x0, x1):
            if y >= y1 - 7:
                c = MURO_FACCIA if (y - y1) % 3 else MURO_RIGA
            else:
                fila = (y - y0) // 8
                c = MURO_RIGA if (y - y0) % 8 == 0 or (x - x0 + (6 if fila % 2 else 0)) % 13 == 0 else MURO
                if ((x - x0) // 5 * 3 + (y - y0) // 4 * 5) % 11 == 0:
                    c = MUSCHIO
            if x in (x0, x1 - 1) or y in (y0, y1 - 1):
                c = MURO_BORDO
            px[x, y] = c
    return s


LEGNO, LEGNO_SCURO, LEGNO_BORDO = col('#8a5a30'), col('#5e3a1e'), col('#2e1a0e')


def tronchetto(s, x0, y0, lungo, alto, inclina=0.0):
    px = s.load()
    for i in range(lungo):
        for j in range(alto):
            x, y = int(x0 + i), int(y0 + j + i * inclina)
            c = LEGNO_SCURO if j in (0, alto - 1) else LEGNO
            if i in (0, lungo - 1):
                c = col('#c89a60') if i == lungo - 1 else LEGNO_BORDO
            px[x, y] = c


def ninfea(s, x, y, fiore=False):
    px = s.load()
    for dy in range(-5, 6):
        for dx in range(-6, 7):
            d = (dx / 6) ** 2 + (dy / 4.5) ** 2
            if d <= 1 and not (dx > 0 and abs(dy) <= dx * 0.4):
                px[x + dx, y + dy] = col('#1e6a34') if d > 0.7 else col('#3c9a44')
    if fiore:
        for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 0)):
            px[x + dx - 2, y + dy - 1] = col('#f0a0c8') if (dx, dy) != (0, 0) else col('#f4d040')


def rgba(v):
    return tuple(int(t) for t in v) + (255,)


def sassolino(s, x, y, r=7):
    px = s.load()
    for dy in range(-r, r + 3):
        for dx in range(-r - 1, r + 2):
            d = (dx / (r + 0.5)) ** 2 + (dy / (r * 0.8)) ** 2
            if d <= 1:
                px[x + dx, y + dy] = rgba(SABBIA_ORLO) if d > 0.75 else rgba(SABBIA_BASE)
            elif dy > 0 and (dx / (r + 0.5)) ** 2 + ((dy - 3) / (r * 0.8)) ** 2 <= 1:
                px[x + dx, y + dy] = rgba(ROCCIA_RIGA)


# i mozziconi di parete: via
cl2 = cl.copy()
par = via_piccoli(cl == PARETE, 300)
out[(cl == PARETE) & ~par] = SABBIA_BASE

# la scala, le cascate
scala(676, 232, 742, 298)
cascata(170, 318, 202, 358)
cascata(500, 586, 536, 626)
tela = Image.fromarray(out).convert('RGBA')

# le cose per terra: i sassi e le ninfee nell'acqua, i resti del pasto
piatto = Image.new('RGBA', (W, H), (0, 0, 0, 0))
for x, y, f in ((357, 494, False), (737, 705, False), (768, 752, False), (1180, 648, False), (1227, 676, True)):
    ninfea(piatto, x, y, f)
for x, y in ((330, 455), (672, 722), (769, 716)):
    sassolino(piatto, x, y, 7)
tronchetto(piatto, 1062, 205, 30, 6, 0.9)
tronchetto(piatto, 1000, 190, 26, 6, 0.4)
tronchetto(piatto, 1008, 218, 22, 5, 0.2)
tronchetto(piatto, 1066, 158, 10, 18, 0.0)
for dx in range(-9, 10):
    for dy in range(-4, 5):
        if (dx / 9) ** 2 + (dy / 4) ** 2 <= 1:
            piatto.putpixel((1056 + dx, 190 + dy), col('#e8b440') if (dx / 9) ** 2 + (dy / 4) ** 2 < 0.55 else col('#9a6a24'))
tela.alpha_composite(piatto)

# i cespugli
CESPUGLI = [
    [(706, 180), (830, 178), (835, 224), (760, 232), (706, 226)],
    [(800, 226), (880, 205), (925, 215), (940, 300), (880, 312), (810, 285)],
    [(1172, 378), (1270, 372), (1275, 452), (1180, 455)],
    [(120, 690), (255, 688), (262, 765), (125, 770)],
    [(1195, 105), (1255, 108), (1255, 175), (1195, 170)],
]
for p in CESPUGLI:
    tela.alpha_composite(cespugli(poligono(p)))

# i muretti del campo
for x0, y0, x1, y1 in ((920, 117, 1125, 145), (910, 152, 940, 216), (1130, 115, 1186, 140), (1160, 115, 1186, 186),
                       (1102, 252, 1187, 286), (1160, 215, 1187, 286), (1252, 177, 1338, 200), (1252, 177, 1274, 286),
                       (755, 154, 850, 176), (828, 154, 850, 226)):
    tela.alpha_composite(muro(x0, y0, x1, y1))

# i pini nei boschi, e la capsula: in ordine di piede
BOSCHI = [
    [(716, 0), (1338, 0), (1338, 110), (1300, 110), (1260, 95), (1190, 100), (900, 105), (870, 140), (740, 148), (712, 110)],
    [(1290, 110), (1338, 110), (1338, 290), (1290, 250)],
    [(1285, 290), (1338, 280), (1338, 600), (1300, 560), (1280, 470)],
    [(0, 540), (60, 520), (140, 510), (230, 560), (300, 640), (345, 700), (365, 784), (0, 784)],
    [(0, 0), (170, 0), (160, 40), (100, 62), (40, 58), (0, 42)],
]
rng = np.random.default_rng(5)
posti = []
for p in BOSCHI:
    m = poligono(p)
    ys, xs = np.nonzero(m)
    cand = list(zip(xs[::37], ys[::37]))
    rng.shuffle(cand)
    for x, y in cand:
        if all((x - a) ** 2 + (y - b) ** 2 > 44 ** 2 for a, b, _ in posti):
            posti.append((int(x), int(y), 'pino'))
posti.append((706, 432, 'capsula'))
P = pino()
CAPS = capsula()
for x, y, n in sorted(posti, key=lambda t: t[1]):
    im = P if n == 'pino' else CAPS
    tela.alpha_composite(im, (x - im.width // 2, y - im.height + 2)) if x - im.width // 2 >= 0 and y - im.height + 2 >= 0 \
        else tela.paste(im, (x - im.width // 2, y - im.height + 2), im)
tela.convert('RGB').save(os.path.join(QUI, '..', '..', 'art', 'livelli', 'atterraggio.png'))
print('scritto art/livelli/atterraggio.png', W, H)
