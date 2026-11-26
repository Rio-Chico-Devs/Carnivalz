"""Il goblin tipico di spalle che divora la preda. Bru: "il goblin e' di spalle ed e' intento a mangiare furiosamente,
non c'e' bisogno di un fuoco o di ossa in giro, non e' che lui ha un accampamento, si e' trovato li', ha ucciso una
preda e la sta mangiando".
Dalla posa di spalle del foglio (goblin_tipico.png, ultima colonna, prima fila), curvo sulla preda per terra davanti a
lui: la testa (capelli e orecchie) abbassata, dietro le spalle che la coprono; le braccia piegate in avanti, che di
spalle si vedono solo fino ai gomiti, fuori ai lati; la clava posata, non si vede. Sei fotogrammi veloci: morde (la
testa affonda), affonda ancora tremando, strappa (la testa torna su a scatto, i gomiti tirano, vola un boccone), e di
nuovo dall'altra parte. Riquadri di 57x75 come il foglio, coi piedi sull'ultima riga (gli stessi della posa).
uso: goblin_mangia.py cartella   (legge cartella/goblin_tipico.png, scrive cartella/goblin_mangia.png)"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from goblin_tipico import COLORI  # noqa: E402

QW, QH = 57, 75
BOCCONE = {'r': (164, 58, 62), 'R': (214, 106, 96), 'x': (82, 26, 42)}     # carne: medio, luce, scuro
TUTTI = dict(COLORI, **BOCCONE)
#           testa giu', di lato, gomito sinistro su, destro su, boccone (x, y, lato) o niente
FOTOGRAMMI = [(7, 0, 0, 0, None),
              (9, -1, 0, 1, None),
              (3, 0, 3, 1, (7, -2, -1)),
              (8, 0, 0, 0, None),
              (9, 1, 1, 0, None),
              (3, 0, 1, 3, (47, -4, 1))]


def leggi(percorso):
    a = np.asarray(Image.open(percorso).convert('RGBA'))
    inv = {v: k for k, v in COLORI.items()}
    f = a[0:QH, 4 * QW:5 * QW]
    L = np.full((QH, QW), '.', dtype='<U1')
    for y, x in zip(*np.nonzero(f[..., 3])):
        L[y, x] = inv[tuple(int(v) for v in f[y, x, :3])]
    return L


def parti(L):
    """la testa (righe fino alla 47, senza la cima della clava), il busto con le spalle (righe 49-55; sotto le spalle
    via le braccia), il perizoma e le gambe (dalla 56 in giu', senza le mani)"""
    testa = np.full_like(L, '.')
    testa[:48] = L[:48]
    testa[44:48, 44:] = '.'
    busto = np.full_like(L, '.')
    busto[49:54, 17:41] = L[49:54, 17:41]
    busto[54:56, 21:36] = L[54:56, 21:36]
    for y in (54, 55):                       # i fianchi chiusi dove c'erano le braccia
        busto[y, 21] = busto[y, 35] = 'k'
    sotto = np.full_like(L, '.')
    sotto[56:65, 20:37] = L[56:65, 20:37]
    sotto[65:, 18:40] = L[65:, 18:40]
    for y in range(56, 65):                  # dove le mani toccavano il perizoma: contorno
        for x in (20, 36):
            if sotto[y, x] not in '.k':
                sotto[y, x] = 'k'
    return testa, busto, sotto


def arto(punti, r, lato):
    """un braccio grosso come una linea spessa r lungo i punti (spalla, gomito, mano), col contorno; luce sul bordo di
    sopra, ombra sotto (piu' scura sul braccio destro: la luce viene da sinistra)"""
    pieni = set()
    xs = [p[0] for p in punti]; ys = [p[1] for p in punti]
    for y in range(int(min(ys) - r - 1), int(max(ys) + r + 2)):
        for x in range(int(min(xs) - r - 1), int(max(xs) + r + 2)):
            for (ax, ay), (bx, by) in zip(punti, punti[1:]):
                vx, vy = bx - ax, by - ay
                u = max(0.0, min(1.0, ((x - ax) * vx + (y - ay) * vy) / float(vx * vx + vy * vy)))
                if (x - ax - u * vx) ** 2 + (y - ay - u * vy) ** 2 <= r * r:
                    pieni.add((x, y))
                    break
    out = {}
    for (x, y) in pieni:
        if any((x + dx, y + dy) not in pieni for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            out[(x, y)] = 'k'
        elif (x, y - 2) not in pieni:
            out[(x, y)] = 'G' if lato < 0 else 'g'
        elif (x, y + 2) not in pieni:
            out[(x, y)] = 'd' if lato < 0 else 'D'
        else:
            out[(x, y)] = 'g' if lato < 0 else 'd'
    return out


def boccone(x, y, lato):
    """un pezzo di carne che vola via strappato (quattro per tre col contorno scuro) e due gocce dietro"""
    p = {}
    for j, riga in enumerate(['.xx.', 'xRrx', 'xrrx', '.xx.']):
        for i, ch in enumerate(riga):
            if ch != '.':
                p[(x + i, y + j)] = ch
    p[(x + 1 - 3 * lato, y + 5)] = 'r'
    p[(x + 1 - 2 * lato, y + 8)] = 'x'
    return p


def fotogramma(testa, busto, sotto, dy, dx, su_sx, su_dx, morso):
    F = np.full((QH, QW), '.', dtype='<U1')
    # le braccia: spalla, gomito fuori, la mano su verso la bocca (dietro la testa, che la copre)
    sx = arto([(20, 52), (9, 57 - su_sx), (15, 47 - su_sx)], 2.3, -1)
    dx_ = arto([(37, 52), (48, 57 - su_dx), (42, 47 - su_dx)], 2.3, 1)
    for (x, y), ch in list(sx.items()) + list(dx_.items()):
        if 0 <= x < QW and 0 <= y < QH:
            F[y, x] = ch
    ys, xs = np.nonzero(testa != '.')
    ok = (ys + dy < QH) & (xs + dx >= 0) & (xs + dx < QW)
    F[ys[ok] + dy, xs[ok] + dx] = testa[ys[ok], xs[ok]]
    m = busto != '.'
    F[m] = busto[m]
    # davanti a testa e spalle: la parte di sopra del braccio, dalla spalla al gomito
    sx_su = arto([(20, 52), (9, 57 - su_sx)], 2.3, -1)
    dx_su = arto([(37, 52), (48, 57 - su_dx)], 2.3, 1)
    for (x, y), ch in list(sx_su.items()) + list(dx_su.items()):
        if 0 <= x < QW and 0 <= y < QH and not (ch == 'k' and F[y, x] in 'gGdD' and busto[y, x] != '.'):
            F[y, x] = ch
    m = sotto != '.'
    F[m] = sotto[m]
    if morso:
        bx, by, lato = morso
        for (x, y), ch in boccone(bx, 20 + dy + by, lato).items():
            if 0 <= y < QH and 0 <= x < QW and F[y, x] == '.':
                F[y, x] = ch
    return F


def png(fot, percorso):
    L = np.concatenate(fot, axis=1)
    img = np.zeros(L.shape + (4,), np.uint8)
    for k, c in TUTTI.items():
        m = L == k
        img[m, :3] = c
        img[m, 3] = 255
    Image.fromarray(img, 'RGBA').save(percorso)
    return img


if __name__ == '__main__':
    D = sys.argv[1]
    testa, busto, sotto = parti(leggi(os.path.join(D, 'goblin_tipico.png')))
    fot = [fotogramma(testa, busto, sotto, *f) for f in FOTOGRAMMI]
    img = png(fot, os.path.join(D, 'goblin_mangia.png'))
    print('goblin_mangia.png', img.shape[1], 'x', img.shape[0], '-', len(fot), 'fotogrammi')
