#!/usr/bin/env python3
# LEI SUL PIANETA, uguale al foglio di Bru: scrive art/pianeti/protagonista/lei.png
#
#   python3 strumenti/protagonisti/ricalca.py
#
# Bru ha mandato il foglio del passo di lei (fogli/lei.png: davanti, dietro, i
# quattro tempi di lato): «no devi farli uguali». Quindi niente disegno nuovo:
# si ricostruiscono i pixel del foglio.
#   - Il foglio e' un JPG ingrandito: ogni pixel del disegno e' un quadretto
#     di circa 4,5 pixel dell'immagine, non un numero intero, e sbavato. Per
#     ogni fotogramma si cerca la griglia (passo e fase in x e in y) dove
#     cadono i bordi dei quadretti.
#   - Per ogni quadretto si prende il colore piu' rappresentativo dei pixel
#     interni (il medoide: la media impasterebbe il contorno col fondo).
#   - Si toglie la scacchiera del fondo, e i colori si riducono a 40 presi dal
#     foglio stesso, cosi' il JPG non lascia sporco.
#   - I fotogrammi si allineano sulla testa, i piedi per terra.
# Il dietro: nel foglio il «back frame 1» ha la giacca e i pantaloni di lui,
# quindi si usa il «back frame 2», e per l'altro passo le sue gambe allo specchio.
#
# Il foglio del gioco: 5 colonne (fermo e i quattro tempi del passo) x 3 righe
# (giu', su, destra; la sinistra e' la destra allo specchio), fotogrammi 32x56,
# i piedi a (16, 53).
import os
import random
import sys
QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
import png

W, H = 32, 56            # un fotogramma
TERRA = 52               # l'ultima riga degli stivali; i piedi stanno a (16, TERRA + 1)
COLORI = 40
COLONNE = (24, 278, 535, 793)  # i quattro riquadri del foglio
QUADRI = {  # x, y, larghezza, altezza: dentro i riquadri, senza le scritte
    "davanti1": (COLONNE[0], 78, 244, 240),
    "davanti2": (COLONNE[2], 78, 246, 240),
    "dietro2": (COLONNE[3], 78, 244, 240),
    "lato1": (COLONNE[0], 432, 244, 216),
    "lato2": (COLONNE[1], 432, 246, 216),
    "lato3": (COLONNE[2], 432, 246, 216),
    "lato4": (COLONNE[3], 432, 244, 216),
}
# colonna del foglio -> fotogramma, per ogni direzione. Davanti e dietro il
# foglio ha due tempi, e ognuno resta per due colonne
ORDINE = ("fermo", "passo1", "medio1", "passo2", "medio2")
VISTE = {
    "giu": ("davanti1", "davanti1", "davanti1", "davanti2", "davanti2"),
    "su": ("dietro2", "dietro2", "dietro2", "dietro2_specchio", "dietro2_specchio"),
    "destra": ("lato1", "lato1", "lato2", "lato3", "lato4"),
}
GAMBE_DIETRO = 39        # nel dietro, la prima riga delle gambe (sotto gli shorts)


class Foglio:
    def __init__(self, percorso):
        self.w, self.h, self.pixel = png.leggi(percorso)

    def px(self, x, y):
        p = self.pixel[y * self.w + x]
        return p[0], p[1], p[2]


def d2(a, b):
    return (a[0] - b[0]) ** 2 * 2 + (a[1] - b[1]) ** 2 * 4 + (a[2] - b[2]) ** 2 * 3


def scacchiera(c, largo=False):
    # i due grigi del fondo, ~46 e ~96
    mx, mn = max(c), min(c)
    if largo:
        return mx - mn <= 12 and (36 <= mx <= 62 or 78 <= mx <= 110)
    return mx - mn <= 9 and (34 <= mx <= 60 or 80 <= mx <= 112)


# ---------------------------------------------------------------- la griglia

def profili(f, x0, y0, w, h):
    gx, gy = [0.0] * w, [0.0] * h
    for y in range(y0, y0 + h - 1):
        for x in range(x0, x0 + w - 1):
            a, b, c = f.px(x, y), f.px(x + 1, y), f.px(x, y + 1)
            gx[x - x0] += abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2])
            gy[y - y0] += abs(a[0] - c[0]) + abs(a[1] - c[1]) + abs(a[2] - c[2])
    return gx, gy


def passo_e_fase(g):
    # il passo p e la fase o per cui le righe o + k*p cadono sui bordi
    media = sum(g) / len(g)
    meglio = None
    for i in range(61):
        p = 4.3 + 0.01 * i
        for k in range(24):
            o = p * k / 24
            s, n, t = 0.0, 0, o
            while t < len(g) - 1:
                j = int(t)
                s += g[j] * (1 - (t - j)) + g[j + 1] * (t - j)
                n += 1
                t += p
            v = s / n / media
            if meglio is None or v > meglio[0]:
                meglio = (v, p, o)
    return meglio[1], meglio[2]


# ---------------------------------------------------------------- il ricalco

def stacca(f, x0, y0, w, h):
    # il fondo: la scacchiera raggiungibile dal bordo del riquadro
    fuori = [[False] * w for _ in range(h)]
    pila = [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)]
    while pila:
        x, y = pila.pop()
        if not (0 <= x < w and 0 <= y < h) or fuori[y][x] or not scacchiera(f.px(x0 + x, y0 + y)):
            continue
        fuori[y][x] = True
        pila += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return fuori


def ricalca(f, x0, y0, w, h, margine=0.8):
    fuori = stacca(f, x0, y0, w, h)
    gx, gy = profili(f, x0, y0, w, h)
    px_, ox = passo_e_fase(gx)
    py_, oy = passo_e_fase(gy)
    ox -= px_ * int(ox / px_ + 1)
    oy -= py_ * int(oy / py_ + 1)
    out = []
    for j in range(int((h - oy) / py_)):
        ya, yb = oy + j * py_, oy + (j + 1) * py_
        riga = []
        for i in range(int((w - ox) / px_)):
            xa, xb = ox + i * px_, ox + (i + 1) * px_
            dentro, tutti = [], 0
            for y in range(max(0, int(ya)), min(h, int(yb) + 1)):
                if not (ya + margine <= y + 0.5 <= yb - margine):
                    continue
                for x in range(max(0, int(xa)), min(w, int(xb) + 1)):
                    if not (xa + margine <= x + 0.5 <= xb - margine):
                        continue
                    tutti += 1
                    if not fuori[y][x]:
                        dentro.append(f.px(x0 + x, y0 + y))
            if tutti == 0 or len(dentro) * 2 < tutti:
                riga.append(None)
            else:
                riga.append(min(dentro, key=lambda c: sum(d2(c, o) for o in dentro)))
        out.append(riga)
    return out


def pezzo_grande(g):
    # tiene solo il pezzo piu' grande (8-connesso): via i resti del fondo
    h, w = len(g), len(g[0])
    visto = [[False] * w for _ in range(h)]
    pezzi = []
    for y in range(h):
        for x in range(w):
            if g[y][x] is None or visto[y][x]:
                continue
            pila, pezzo = [(x, y)], []
            visto[y][x] = True
            while pila:
                a, b = pila.pop()
                pezzo.append((a, b))
                for dy in (-1, 0, 1):
                    for dx in (-1, 0, 1):
                        c, d = a + dx, b + dy
                        if 0 <= c < w and 0 <= d < h and not visto[d][c] and g[d][c] is not None:
                            visto[d][c] = True
                            pila.append((c, d))
            pezzi.append(pezzo)
    grande = set(max(pezzi, key=len))
    return [[g[y][x] if (x, y) in grande else None for x in range(w)] for y in range(h)]


def via_scacchiera(g):
    # i quadretti color fondo raggiungibili da fuori sono fondo rimasto attaccato
    h, w = len(g), len(g[0])
    fuori = [[False] * w for _ in range(h)]
    pila = [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)]
    while pila:
        x, y = pila.pop()
        if not (0 <= x < w and 0 <= y < h) or fuori[y][x]:
            continue
        c = g[y][x]
        if c is not None and not scacchiera(c, largo=True):
            continue
        fuori[y][x] = True
        pila += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return pezzo_grande([[None if fuori[y][x] else g[y][x] for x in range(w)] for y in range(h)])


def via_punte_sotto(g, righe=3):
    # sotto gli stivali il JPG lascia dei fili di un pixel: via
    h = len(g)
    for _ in range(2):
        for y in range(h - righe, h):
            for x in range(len(g[0])):
                if g[y][x] is None:
                    continue
                vicini = sum(1 for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
                             if 0 <= x + dx < len(g[0]) and 0 <= y + dy < h and g[y + dy][x + dx] is not None)
                if vicini <= 1:
                    g[y][x] = None
    return g


def ritaglia(g):
    ys = [y for y, r in enumerate(g) if any(c is not None for c in r)]
    xs = [x for r in g for x, c in enumerate(r) if c is not None]
    return [r[min(xs):max(xs) + 1] for r in g[min(ys):max(ys) + 1]]


# ---------------------------------------------------------------- i colori

def kmedie(punti, k, giri=25):
    random.seed(5)
    centri = random.sample(punti, k)
    for _ in range(giri):
        gruppi = [[] for _ in range(k)]
        for p in punti:
            gruppi[min(range(k), key=lambda j: d2(p, centri[j]))].append(p)
        centri = [tuple(sum(q[t] for q in g) / len(g) for t in range(3)) if g else centri[i]
                  for i, g in enumerate(gruppi)]
    return [tuple(int(round(v)) for v in c) for c in centri]


def quantizza(g, tavolozza):
    return [[None if c is None else min(tavolozza, key=lambda m: d2(c, m)) for c in r] for r in g]


# ---------------------------------------------------------------- il foglio del gioco

def specchia_gambe(g, da):
    centro = (len(g[0]) - 1) / 2
    out = [list(r) for r in g]
    for y in range(da, len(g)):
        for x in range(len(g[0])):
            sx = int(round(2 * centro - x))
            out[y][x] = g[y][sx] if 0 <= sx < len(g[0]) else None
    return out


def diversi(a, b, dx, righe):
    # quanto differiscono due teste spostate di dx: le celle piene e vuote
    n = 0
    for y in range(min(righe, len(a), len(b))):
        for x in range(-4, W + 4):
            pa = a[y][x] if 0 <= x < len(a[0]) else None
            xb = x - dx
            pb = b[y][xb] if 0 <= xb < len(b[0]) else None
            n += (pa is None) != (pb is None)
    return n


def posa(g, guida=None):
    """-> (x, y) dove mettere il ricalco nel fotogramma: l'ultima riga a terra,
    in orizzontale centrato, o allineato sulla testa della guida"""
    y = TERRA + 1 - len(g)
    if guida is None:
        return (W - len(g[0])) // 2, y
    gx, gfig = guida
    dx = min(range(-4, 5), key=lambda d: (diversi(gfig, g, d, 20), abs(d)))
    return gx + dx, y


def fotogramma(g, x0, y0):
    t = [[None] * W for _ in range(H)]
    for y, r in enumerate(g):
        for x, c in enumerate(r):
            if c is not None and 0 <= x0 + x < W and 0 <= y0 + y < H:
                t[y0 + y][x0 + x] = c
    return t


def foglio_del_gioco(ricalchi):
    fw, fh = W * 5, H * 3
    pix = [(0, 0, 0, 0)] * (fw * fh)
    for riga, vista in enumerate(("giu", "su", "destra")):
        nomi = VISTE[vista]
        prima = ricalchi[nomi[0]]
        x0, y0 = posa(prima)
        for colonna, nome in enumerate(nomi):
            g = ricalchi[nome]
            x, y = posa(g, (x0, prima)) if nome != nomi[0] else (x0, y0)
            t = fotogramma(g, x, y)
            for yy in range(H):
                for xx in range(W):
                    c = t[yy][xx]
                    if c is not None:
                        p = (c[0], c[1], c[2], 255)
                    else:
                        # l'ombra ovale per terra sotto i piedi
                        dx, dy = (xx + 0.5 - 16) / 9.0, (yy + 0.5 - (TERRA + 1.5)) / 2.0
                        p = (18, 12, 24, 80) if dx * dx + dy * dy < 1 else (0, 0, 0, 0)
                    pix[(riga * H + yy) * fw + colonna * W + xx] = p
    return fw, fh, pix


def ricalchi_di_lei(percorso):
    f = Foglio(percorso)
    grezzi = {}
    for nome, quadro in QUADRI.items():
        grezzi[nome] = via_punte_sotto(ritaglia(via_scacchiera(pezzo_grande(ricalca(f, *quadro)))))
    tutti = [c for g in grezzi.values() for r in g for c in r if c is not None]
    tavolozza = kmedie(tutti, COLORI)
    ricalchi = {nome: ritaglia(quantizza(g, tavolozza)) for nome, g in grezzi.items()}
    ricalchi["dietro2_specchio"] = specchia_gambe(ricalchi["dietro2"], GAMBE_DIETRO)
    return ricalchi


if __name__ == '__main__':
    ricalchi = ricalchi_di_lei(os.path.join(QUI, 'fogli', 'lei.png'))
    for nome, g in sorted(ricalchi.items()):
        assert len(g) <= TERRA + 1 and len(g[0]) <= W, (nome, len(g[0]), len(g))
    w, h, pix = foglio_del_gioco(ricalchi)
    cartella = os.path.join(QUI, '..', '..', 'art', 'pianeti', 'protagonista')
    png.scrivi(os.path.join(cartella, 'lei.png'), w, h, pix)
    print('scritto lei', w, h)
