"""Lei dorme in piedi, di fronte, dal disegno 106 di Bru ("parti da questa"): la testa piegata da un lato, gli occhi
chiusi, la bocca aperta con la lingua, le braccia giu' lungo i fianchi, lo stivale destro un po' in fuori. Dalla
narice esce la bolla di moccio azzurra, piena, col riflesso bianco in alto a sinistra e l'ombra sotto: si gonfia
mentre espira e si sgonfia mentre inspira, come negli anime. La bolla piu' grande e' quella disegnata da Bru, le
altre sono la stessa sempre piu' piccola, attaccata alla narice con la goccia.
La posa e' davanti_dorme_posa.png (il disegno di Bru portato sulla griglia 40x74 e sulla tavolozza, senza la bolla:
sotto c'e' la guancia). Respiro lento: quando inspira il corpo sale di 1 pixel e i piedi restano a terra (si allunga
la coscia); le punte del ciuffo seguono con un fotogramma di ritardo, come nell'attesa. 10 fotogrammi, 40x76 (2
righe libere sopra, come l'attesa).
uso: dorme_davanti.py davanti_dorme_posa.png striscia.png anteprima.gif foglio.png"""
import sys

import numpy as np
from PIL import Image

src = np.asarray(Image.open(sys.argv[1]).convert('RGBA')).copy()
H, W = src.shape[:2]
MA = 2

# i colori della bolla di Bru
COLORI = {'L': (154, 216, 231),      # azzurro
          'W': (226, 255, 255),      # il riflesso
          'D': (119, 180, 205),      # l'ombra sotto
          'N': (144, 203, 222)}      # la goccia alla narice
# le bolle, dalla piu' piccola alla piu' grande (quella di Bru), nel riquadro x 9-15, y 33-37 della posa: la narice
# e' in (15, 34), la goccia in (14, 35) le tiene attaccate
X0, Y0 = 9, 33
BOLLE = [
    ['.......',
     '......N',
     '.....L.',
     '.......',
     '.......'],
    ['.......',
     '......N',
     '...WLL.',
     '...LD..',
     '.......'],
    ['.......',
     '...L..N',
     '..LWLL.',
     '...D...',
     '.......'],
    ['.......',
     '..LL..N',
     '.LWLLL.',
     '.LLLD..',
     '..DD...'],
    ['.LLL...',
     'LWLLL.N',
     'LLLLLL.',
     'LLLLD..',
     '.DDD...'],
]
# espira (corpo giu', la bolla si gonfia e resta un attimo grande), inspira (corpo su, la bolla si sgonfia)
BOLLA = [0, 1, 1, 2, 3, 4, 3, 2, 1, 0]
SU = [0, 0, 0, 0, 0, 0, 1, 1, 1, 1]
PUNTE = SU[-1:] + SU[:-1]                # le punte del ciuffo: un fotogramma dopo
DURATE = [260, 240, 200, 240, 260, 460, 180, 170, 180, 320]

LATTICE = {(6, 7, 15), (22, 37, 52), (49, 59, 70), (69, 79, 85)}


def lineare(r, r0, d0, r1, d1):
    t = min(max((r - r0) / float(r1 - r0), 0.0), 1.0)
    return d0 + (d1 - d0) * t


def laccio():
    # la riga del laccio dei capelli: la prima (dall'alto) con 3 o piu' pixel di lattice
    op = src[..., 3] > 0
    cima = int(np.nonzero(op.any(axis=1))[0].min())
    for y in range(cima, cima + 30):
        if sum(1 for x in range(W) if op[y, x] and tuple(src[y, x, :3]) in LATTICE) >= 3:
            return y
    raise SystemExit('laccio non trovato')


def punte(regione, origine, frazione):
    # la distanza dal laccio camminando dentro i capelli (anche in diagonale): le punte sono i pixel piu' lontani,
    # cosi' il confine fra punta e resto segue la forma di ogni ciocca (Bru)
    d = np.full((H, W), -1, int)
    coda = [tuple(q) for q in np.argwhere(origine & regione)]
    for q in coda:
        d[q] = 0
    i = 0
    while i < len(coda):
        y, x = coda[i]; i += 1
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                yy, xx = y + dy, x + dx
                if 0 <= yy < H and 0 <= xx < W and regione[yy, xx] and d[yy, xx] < 0:
                    d[yy, xx] = d[y, x] + 1
                    coda.append((yy, xx))
    return regione & (d >= frazione * d.max())


op = src[..., 3] > 0
Y, X = np.mgrid[0:H, 0:W]
# le gambe: le mani (fino alla riga 61, x <= 11 e x >= 29) restano col corpo; sotto, lo stivale destro in fuori
gambe = op & (Y >= 59) & (X >= 12) & ((X <= 28) | (Y >= 62))
T = laccio()
ciuffo = op & (Y < T)
punta = punte(ciuffo, ciuffo & (Y == T - 1), 0.5)
resto = op & ~gambe


def posa(out, parte, dy):
    # ogni colonna della parte sale di dy(riga, colonna); dove si allunga, la riga sopra si ripete
    for x in range(W):
        rr = np.nonzero(parte[:, x])[0]
        prima = None
        for r in rr:
            dest = r - int(np.floor(dy(r, x) + 0.5)) + MA
            if prima is not None and prima[0] == r - 1 and dest - prima[1] == 2:
                out[dest - 1, x] = src[r - 1, x]
            if 0 <= dest < H + MA:
                out[dest, x] = src[r, x]
            prima = (r, dest)


def bolla(out, n, su):
    for j, riga in enumerate(BOLLE[n]):
        for i, ch in enumerate(riga):
            if ch != '.':
                out[Y0 + j - su + MA, X0 + i, :3] = COLORI[ch]
                out[Y0 + j - su + MA, X0 + i, 3] = 255


fot = []
for k in range(len(BOLLA)):
    b, p = SU[k], PUNTE[k]
    out = np.zeros((H + MA, W, 4), np.uint8)
    posa(out, gambe, lambda r, x: lineare(r, 58, b, 62, 0))     # i piedi a terra, la coscia si allunga
    posa(out, resto, lambda r, x: p if punta[r, x] else b)
    bolla(out, BOLLA[k], b)
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
n = len(gif)
fg = Image.new('RGB', (5 * (W * z + 8), ((n + 4) // 5) * (Hc * z + 8)), (40, 40, 48))
for k, im in enumerate(gif):
    fg.paste(im, ((k % 5) * (W * z + 8), (k // 5) * (Hc * z + 8)))
fg.save(sys.argv[4])
print('fatto', striscia.shape, 'laccio alla riga', T, 'punte', int(punta.sum()))
