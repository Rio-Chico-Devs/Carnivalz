"""Lei dorme in piedi, di fronte (Bru: "che dorme a bocca aperta con una bolla di moccio che si ingrandisce e
rimpicciolisce come negli anime giapponesi, falla molto carina").
Il viso della ferma di fronte cambia: occhi chiusi a mezzaluna (la riga delle ciglia scende e si curva, sopra la
palpebra), guanciotte rosa, bocca aperta a "o" con la lingua, un filo di bava all'angolo. Dal naso esce la bolla:
si gonfia mentre espira e si sgonfia mentre inspira, attaccata alla narice, verso la guancia; e' trasparente,
col bordo azzurro e il riflesso bianco. Respiro lento: il corpo intero sale di 1 pixel quando inspira, i piedi
restano a terra (si allunga la coscia). 12 fotogrammi, 40x76 (2 righe libere sopra, come l'attesa).
uso: dorme_davanti.py davanti_ferma.png striscia.png anteprima.gif foglio.png"""
import math
import sys

import numpy as np
from PIL import Image

src = np.asarray(Image.open(sys.argv[1]).convert('RGBA')).copy()
H, W = src.shape[:2]
MA = 2
PELLE, OMBRA, SCURO = (156, 116, 82), (130, 85, 80), (97, 58, 63)
NERO, BOCCA, LINGUA = (6, 7, 15), (74, 26, 52), (205, 118, 128)
ROSA, ROSA_SCURO = (198, 122, 116), (181, 104, 100)
BAVA = (176, 218, 238)


def metti(punti, c):
    for x, y in punti:
        src[y, x, :3] = c; src[y, x, 3] = 255


# ---- occhi chiusi: via occhi e ciglia, pelle; la riga delle ciglia scende a meta' e si curva in giu' (come ˘ ˘)
metti([(x, y) for y in range(30, 36) for x in range(9, 14)], PELLE)
metti([(x, y) for y in range(30, 36) for x in range(21, 27)], PELLE)
metti([(9, 34), (10, 35)], PELLE)
metti([(9, 32), (13, 32), (10, 33), (11, 33), (12, 33)], NERO)                                # occhio sinistro
metti([(21, 32), (26, 32), (22, 33), (23, 33), (24, 33), (25, 33)], NERO)                     # occhio destro
# ---- guanciotte rosa
metti([(10, 35), (11, 35), (12, 35), (22, 35), (23, 35), (24, 35), (25, 35)], ROSA)
metti([(11, 36), (23, 36), (24, 36)], ROSA_SCURO)
# ---- bocca aperta a "o": labbra scure, dentro buio e la lingua; il mento sotto resta
metti([(16, 38), (18, 38), (19, 38), (17, 38)], PELLE)                                       # via la bocca chiusa
metti([(17, 37), (18, 37), (16, 38), (19, 38), (16, 39), (19, 39)], SCURO)
metti([(17, 38), (18, 38)], BOCCA)
metti([(17, 39), (18, 39)], LINGUA)
# ---- il filo di bava all'angolo della bocca, giu' per il mento
metti([(20, 39), (20, 40)], BAVA)

op = src[..., 3] > 0
Y, X = np.mgrid[0:H, 0:W]
gambe = op & (Y >= 59) & (X >= 12) & (X <= 27)
resto = op & ~gambe
# respiro: espira (la bolla si gonfia, il corpo giu'), inspira (la bolla si sgonfia, il petto su)
RAGGIO = [1.0, 1.5, 2.2, 3.0, 3.8, 4.5, 5.0, 4.4, 3.5, 2.5, 1.7, 1.2]
SU = [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0]
DURATE = [200] * 12
NARICE = (14.5, 37.5)                     # sotto il naso (x 15), la bolla esce verso la guancia sinistra
VERSO = (-0.55, 0.835)


def lineare(r, r0, d0, r1, d1):
    t = min(max((r - r0) / float(r1 - r0), 0.0), 1.0)
    return d0 + (d1 - d0) * t


def posa(out, parte, dy):
    for x in range(W):
        rr = np.nonzero(parte[:, x])[0]
        prima = None
        for r in rr:
            dest = r - int(np.floor(dy(r) + 0.5)) + MA
            if prima is not None and prima[0] == r - 1 and dest - prima[1] == 2:
                out[dest - 1, x] = src[r - 1, x]
            if 0 <= dest < H + MA:
                out[dest, x] = src[r, x]
            prima = (r, dest)


def bolla(out, R, su):
    # cerchio di raggio R attaccato alla narice: bordo azzurro, dentro trasparente, riflesso bianco in alto
    cx, cy = NARICE[0] + VERSO[0] * R, NARICE[1] + VERSO[1] * R - su + MA
    Yb, Xb = np.mgrid[0:H + MA, 0:W]
    dentro = (Xb + 0.5 - cx) ** 2 + (Yb + 0.5 - cy) ** 2 <= R * R + 0.25
    bordo = dentro & ~(np.roll(dentro, 1, 0) & np.roll(dentro, -1, 0) & np.roll(dentro, 1, 1) & np.roll(dentro, -1, 1))
    for y, x in zip(*np.nonzero(dentro)):
        sotto = out[y, x].astype(float)
        if bordo[y, x]:
            c, a = (138, 200, 232), 0.85
        else:
            c, a = (214, 240, 252), 0.38
        if sotto[3] == 0:
            out[y, x] = (c[0], c[1], c[2], int(255 * a))
        else:
            out[y, x, :3] = [int(sotto[i] * (1 - a) + c[i] * a) for i in range(3)]
    # riflessi
    hx, hy = int(math.floor(cx - 0.45 * R)), int(math.floor(cy - 0.45 * R))
    if dentro[hy, hx]:
        out[hy, hx] = (255, 255, 255, 240)
    if R >= 3.0:
        if dentro[hy, hx + 1]:
            out[hy, hx + 1] = (255, 255, 255, 200)
        if dentro[hy + 1, hx]:
            out[hy + 1, hx] = (255, 255, 255, 200)
        lx, ly = int(math.floor(cx + 0.5 * R)), int(math.floor(cy + 0.4 * R))
        if dentro[ly, lx] and not bordo[ly, lx]:
            out[ly, lx] = (240, 250, 255, 180)


fot = []
for k in range(12):
    b = SU[k]
    out = np.zeros((H + MA, W, 4), np.uint8)
    posa(out, gambe, lambda r: lineare(r, 58, b, 62, 0))      # i piedi a terra, la coscia si allunga
    posa(out, resto, lambda r: b)
    bolla(out, RAGGIO[k], b)
    fot.append(out)
striscia = np.concatenate(fot, axis=1)
Image.fromarray(striscia, 'RGBA').save(sys.argv[2])
z = 6
Hc = H + MA
gif = []
for f in fot:
    im = Image.new('RGB', (W * z, Hc * z), (60, 96, 62))
    g = Image.fromarray(f, 'RGBA').resize((W * z, Hc * z), Image.NEAREST)
    im.paste(g, (0, 0), g)
    gif.append(im)
gif[0].save(sys.argv[3], save_all=True, append_images=gif[1:], duration=DURATE, loop=0)
fg = Image.new('RGB', (6 * (W * z + 8), 2 * (Hc * z + 8)), (40, 40, 48))
for k, im in enumerate(gif):
    fg.paste(im, ((k % 6) * (W * z + 8), (k // 6) * (Hc * z + 8)))
fg.save(sys.argv[4])
print('fatto', striscia.shape)
