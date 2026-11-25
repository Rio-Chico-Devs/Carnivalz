"""Lei salta la corda (di fronte), in loop: 8 fotogrammi, un giro di corda per salto.
uso: corda.py davanti_ferma.png striscia.png anteprima.gif foglio.png"""
import sys, math
import numpy as np
from PIL import Image
src0 = np.asarray(Image.open(sys.argv[1]).convert('RGBA')).copy()
H, W = src0.shape[:2]
A, G, Hc = (6, 7, 15), (22, 37, 52), (49, 59, 70)                     # i colori del guanto
ORO, ORO_SCURO = (250, 214, 129), (202, 153, 78)                      # le maniglie: l'oro del cerchio
CORDA, SCIA = (251, 217, 213), (196, 166, 177)                        # la corda chiara e la sua scia
# ---- le mani a pugno con la maniglia (la sinistra disegnata, la destra allo specchio: le braccia lo sono gia')
src = src0.copy()
for y in range(55, 62):
    for x in range(0, 11):
        src[y, x] = 0; src[y, 39 - x] = 0
PUGNO = {55: {2: A, 3: Hc, 4: G, 5: G, 6: G, 7: G, 8: G, 9: A},
         56: {2: A, 3: Hc, 4: G, 5: G, 6: G, 7: G, 8: A},
         57: {2: A, 3: G, 4: G, 5: G, 6: G, 7: A},
         58: {3: A, 4: A, 5: ORO_SCURO, 6: A},
         59: {5: ORO},
         60: {5: ORO_SCURO}}
for y, riga in PUGNO.items():
    for x, c in riga.items():
        src[y, x, :3] = c; src[y, x, 3] = 255
        src[y, 39 - x, :3] = c; src[y, 39 - x, 3] = 255
op = src[..., 3] > 0
Y, X = np.mgrid[0:H, 0:W]
coda = op & (Y <= 13)
ciocche = op & (Y >= 36) & (Y <= 45) & ((X <= 9) | (X >= 29))
braccia = op & (Y >= 46) & (Y <= 61) & ((X <= 11) | (X >= 28))
gambe = op & (Y >= 59) & ~braccia
corpo = op & ~coda & ~ciocche & ~braccia & ~gambe
#        0  1  2  3  4  5  6   7        (la corda: 0 sopra la testa, 2 davanti, 4 sotto i piedi, 6 dietro)
SALTO = [0, 0, 1, 3, 4, 3, 1, -1]      # -1: atterra e si piega sulle gambe
POLSI = [round(math.cos(math.radians(45 * k))) for k in range(8)]
DUR = 50
MS, MD, MA, MB = 12, 12, 10, 8           # margini della tela: sinistra, destra, sopra, sotto
CW, CH = W + MS + MD, H + MA + MB


def lineare(r, r0, d0, r1, d1):
    t = np.clip((r - r0) / float(r1 - r0), 0, 1)
    return d0 + (d1 - d0) * t


def posa(out, parte, dy_di, dx=0):
    for x in range(W):
        rr = np.nonzero(parte[:, x])[0]
        prima = None
        for r in rr:
            dest = r - int(np.floor(dy_di(r) + 0.5))
            if prima is not None and prima[0] == r - 1 and dest - prima[1] == 2:
                out[dest - 1 + MA, x + MS + dx] = src[r - 1, x]
            if 0 <= dest + MA < CH:
                out[dest + MA, x + MS + dx] = src[r, x]
            prima = (r, dest)


def arco(theta, mani_y):
    # la corda vista di fronte: mezza ellisse fra le due maniglie, col colmo che sale e scende col giro
    xl, xr = 5 + MS, 34 + MS
    y0 = mani_y
    c = math.cos(math.radians(theta))
    colmo = y0 - 67 * c if c >= 0 else y0 + 11 * (-c)
    cx, hw = (xl + xr) / 2.0, (xr - xl) / 2.0
    gonfio = 7 * abs(c)                  # la corda e' lunga: sopra la testa e sotto i piedi si allarga oltre le mani
    pts = []
    for i in range(0, 721):
        f = math.pi * i / 720
        x = int(math.floor(cx - (hw + gonfio * math.sin(f)) * math.cos(f) + 0.5))
        y = int(math.floor(y0 + (colmo - y0) * math.sin(f) + 0.5))
        if not pts or pts[-1] != (x, y):
            pts.append((x, y))
    # pixel perfetto: via gli angoli a L, guardando la linea gia' pulita (se no a ogni gradino
    # sparivano tutti e due i pixel dell'angolo e la corda veniva tratteggiata)
    puliti = []
    for p in pts:
        if len(puliti) >= 2:
            a = puliti[-2]
            if abs(a[0] - p[0]) == 1 and abs(a[1] - p[1]) == 1:
                puliti.pop()
        puliti.append(p)
    return puliti


def disegna_corda(out, punti, col, solo_vuoto=False):
    for x, y in punti:
        if 0 <= x < CW and 0 <= y < CH and (not solo_vuoto or out[y, x, 3] == 0):
            out[y, x, :3] = col; out[y, x, 3] = 255


fot = []
for k in range(8):
    th = 45 * k
    j, pl, jp = SALTO[k], POLSI[k], SALTO[k - 1]
    lei = np.zeros((CH, CW, 4), np.uint8)
    if j >= 0:
        posa(lei, gambe, lambda r: j)                                   # in aria: anche i piedi
    else:
        posa(lei, gambe, lambda r: lineare(r, 58, j, 62, 0))            # atterra: le cosce si piegano
    posa(lei, corpo, lambda r: j)
    posa(lei, ciocche, lambda r: lineare(r, 36, j, 45, jp))
    posa(lei, coda, lambda r: lineare(r, 13, j, 0, jp))
    posa(lei, braccia, lambda r: lineare(r, 46, j, 60, j + pl))
    mani_y = 61 + MA - (j + pl)
    dietro = 180 < th % 360 or th % 360 == 0                             # sopra la testa e dietro: dietro a lei
    out = np.zeros((CH, CW, 4), np.uint8)
    scia = arco(th - 20, mani_y)
    corda = arco(th, mani_y)
    dietro_scia = 180 < (th - 20) % 360 or (th - 20) % 360 == 0
    if dietro_scia:
        disegna_corda(out, scia, SCIA)
    if dietro:
        disegna_corda(out, corda, CORDA)
    m = lei[..., 3] > 0
    out[m] = lei[m]
    if not dietro_scia:
        disegna_corda(out, scia, SCIA)
    if not dietro:
        disegna_corda(out, corda, CORDA)
    fot.append(out)
striscia = np.concatenate(fot, axis=1)
Image.fromarray(striscia, 'RGBA').save(sys.argv[2])
z = 5
gif = []
for f in fot:
    im = Image.new('RGB', (CW * z, CH * z), (60, 96, 62))
    g = Image.fromarray(f, 'RGBA').resize((CW * z, CH * z), Image.NEAREST)
    im.paste(g, (0, 0), g); gif.append(im)
gif[0].save(sys.argv[3], save_all=True, append_images=gif[1:], duration=DUR, loop=0)
fg = Image.new('RGB', (8 * (CW * z + 10), CH * z), (40, 40, 48))
for k, im in enumerate(gif):
    fg.paste(im, (k * (CW * z + 10), 0))
fg.save(sys.argv[4])
print('fatto', striscia.shape, 'polsi', POLSI)
