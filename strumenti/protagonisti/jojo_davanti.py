"""Lei in posa JoJo, di fronte, dal disegno 107 di Bru ("animazione jojo posing aura farming menacing"): gambe larghe,
una mano sul fianco, l'altro braccio alzato accanto alla testa, lo sguardo minaccioso. La posa e' davanti_jojo_posa.png
(il disegno di Bru portato sulla griglia 40x74 e sulla tavolozza della ferma, con tre stelle e il braccio alzato piu'
corto di 4 righe: Bru, "il braccio destro nella ref e' troppo lungo").
L'animazione, 16 fotogrammi da 90 ms:
- l'aura: un alone viola intorno a lei, piu' chiaro attaccato al corpo, e fuori lingue di fiamma che salgono;
- le ゴ ("menacing"): quattro katakana viola col contorno scuro, due per lato, che compaiono una dopo l'altra (il
  primo fotogramma tutte chiare, come un lampo), salgono piano e tremano; ognuna sparisce per 4 fotogrammi e torna;
- il respiro: il corpo sale di 1 pixel e torna giu', i piedi restano a terra (si allunga la coscia);
- il ciuffo sventola nel vento dell'aura: le punte salgono di 1 pixel ogni due fotogrammi.
Tela 72x84: lei sta a x 16, y 10 (le suole alla riga 82), ai lati c'e' posto per le ゴ.
uso: jojo_davanti.py davanti_jojo_posa.png striscia.png anteprima.gif foglio.png"""
import math
import sys

import numpy as np
from PIL import Image

src = np.asarray(Image.open(sys.argv[1]).convert('RGBA')).copy()
H, W = src.shape[:2]
TW, TH, OX, OY = 72, 84, 16, 10
N = 16
DURATE = [90] * N
CORPO = [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0]
VENTO = [0, 1, 1, 0] * 4                      # le punte del ciuffo, sopra il respiro

LATTICE = {(6, 7, 15), (22, 37, 52), (49, 59, 70), (69, 79, 85)}


def lineare(r, r0, d0, r1, d1):
    t = min(max((r - r0) / float(r1 - r0), 0.0), 1.0)
    return d0 + (d1 - d0) * t


def laccio():
    op = src[..., 3] > 0
    cima = int(np.nonzero(op.any(axis=1))[0].min())
    for y in range(cima, cima + 30):
        if sum(1 for x in range(W) if op[y, x] and tuple(src[y, x, :3]) in LATTICE) >= 3:
            return y
    raise SystemExit('laccio non trovato')


def punte(regione, origine, frazione):
    # la distanza dal laccio camminando dentro i capelli: le punte sono i pixel piu' lontani (il confine segue la
    # forma di ogni ciocca)
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
gambe = op & (Y >= 58)                         # la mano sul fianco finisce alla riga 57
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
            dest = r - int(np.floor(dy(r, x) + 0.5)) + OY
            if prima is not None and prima[0] == r - 1 and dest - prima[1] == 2:
                out[dest - 1, x + OX] = src[r - 1, x]
            if 0 <= dest < TH:
                out[dest, x + OX] = src[r, x]
            prima = (r, dest)


# ---------------------------------------------------------------- l'aura
AURA = [(196, 128, 255, 200),      # attaccata al corpo
        (160, 84, 240, 130),       # le fiamme vicine
        (128, 60, 224, 80)]        # le punte delle fiamme


def distanze(m, fino):
    # quanti pixel (anche in diagonale) mancano al corpo, fino a 'fino'
    d = np.full(m.shape, 99, int)
    d[m] = 0
    bordo = m.copy()
    for k in range(1, fino + 1):
        g = bordo.copy()
        g[1:] |= bordo[:-1]; g[:-1] |= bordo[1:]
        g[:, 1:] |= bordo[:, :-1]; g[:, :-1] |= bordo[:, 1:]
        g[1:, 1:] |= bordo[:-1, :-1]; g[:-1, :-1] |= bordo[1:, 1:]
        g[1:, :-1] |= bordo[:-1, 1:]; g[:-1, 1:] |= bordo[1:, :-1]
        d[g & (d == 99)] = k
        bordo = g
    return d


def aura(out, k):
    m = out[..., 3] > 0
    d = distanze(m, 4)
    yy, xx = np.mgrid[0:TH, 0:TW]
    # lingue di fiamma che salgono: un'onda che scorre verso l'alto (4 onde per giro, cosi' il giro si chiude)
    onda = np.sin(0.62 * yy + 2 * math.pi * 4 * k / N + 1.4 * np.sin(0.9 * xx)) + 0.35 * np.sin(1.7 * xx)
    alta = yy < OY + 14                       # sopra la testa le fiamme vanno piu' su
    strati = [d == 1,
              (d == 2) & (onda > -0.2),
              ((d == 3) & (onda > 0.55)) | ((d == 4) & alta & (onda > 0.9))]
    sotto = out.copy()
    for s, c in zip(strati, AURA):
        out[s] = c
    out[m] = sotto[m]


# ---------------------------------------------------------------- le ゴ
GO = ['......T.T',
      '.....T.T.',
      'TTTTTT...',
      'MMMMMS...',
      '....MS...',
      '....MS...',
      'MMMMMS...',
      'SSSSSS...']
GO_COL = {'T': (240, 160, 244), 'M': (196, 82, 206), 'S': (122, 38, 142)}
CONTORNO = (40, 10, 52)
# (x, y) dell'angolo in alto a sinistra (contorno compreso) e il fotogramma in cui compare
GOS = [(1, 22, 0), (59, 14, 4), (4, 40, 8), (61, 32, 12)]
VITA = 12
TREMA = [0, 1, 0, -1]


def go(out, x0, y0, lampo):
    g = np.zeros((len(GO) + 2, len(GO[0]) + 2), object)
    for j, r in enumerate(GO):
        for i, ch in enumerate(r):
            if ch != '.':
                g[j + 1, i + 1] = 'T' if lampo else ch
    for j in range(g.shape[0]):
        for i in range(g.shape[1]):
            if g[j, i] == 0 and any(g[jj, ii] not in (0, 'O') for jj in range(max(0, j - 1), min(g.shape[0], j + 2))
                                    for ii in range(max(0, i - 1), min(g.shape[1], i + 2))):
                g[j, i] = 'O'
    for j in range(g.shape[0]):
        for i in range(g.shape[1]):
            if g[j, i] != 0 and 0 <= y0 + j < TH and 0 <= x0 + i < TW:
                c = CONTORNO if g[j, i] == 'O' else GO_COL[g[j, i]]
                out[y0 + j, x0 + i, :3] = c
                out[y0 + j, x0 + i, 3] = 255


fot = []
for k in range(N):
    b = CORPO[k]
    p = b + VENTO[k]
    out = np.zeros((TH, TW, 4), np.uint8)
    posa(out, gambe, lambda r, x: lineare(r, 58, b, 63, 0))       # i piedi a terra
    posa(out, resto, lambda r, x: p if punta[r, x] else b)
    aura(out, k)
    for i, (x0, y0, inizio) in enumerate(GOS):
        eta = (k - inizio) % N
        if eta < VITA:
            go(out, x0 + TREMA[(k + i) % 4], y0 - eta // 4, eta == 0)
    fot.append(out)
striscia = np.concatenate(fot, axis=1)
Image.fromarray(striscia, 'RGBA').save(sys.argv[2])
z = 5
gif = []
for f in fot:
    im = Image.new('RGBA', (TW, TH), (60, 96, 62, 255))
    im.alpha_composite(Image.fromarray(f, 'RGBA'))
    gif.append(im.convert('RGB').resize((TW * z, TH * z), Image.NEAREST))
gif[0].save(sys.argv[3], save_all=True, append_images=gif[1:], duration=DURATE, loop=0)
fg = Image.new('RGB', (4 * (TW * 3 + 6), 4 * (TH * 3 + 6)), (40, 40, 48))
for k, im in enumerate(gif):
    fg.paste(im.resize((TW * 3, TH * 3), Image.NEAREST), ((k % 4) * (TW * 3 + 6), (k // 4) * (TH * 3 + 6)))
fg.save(sys.argv[4])
print('fatto', striscia.shape, 'laccio alla riga', T, 'punte', int(punta.sum()))
