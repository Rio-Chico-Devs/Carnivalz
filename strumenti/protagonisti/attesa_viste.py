"""Lei ferma di spalle e di lato: l'attesa come quella di fronte (attesa_davanti.py), 6 fotogrammi da ~0,1 s.
Piedi fermi; il corpo sale di 1 pixel (fotogrammi 2-4) e torna giu'; le braccia salgono con lui e poi di un altro
pixel, e scendono in ritardo; i capelli in alto (e di spalle la parte bassa dei capelli, di lato la treccia) seguono
la testa con un fotogramma di ritardo; un tallone si alza, la punta resta a terra.
- di spalle: dietro_ferma.png -> dietro_attesa.png (il tallone che si alza e' quello del piede sinistro di Lei,
  come di fronte; l'altra gamba si allunga sotto il ginocchio)
- di lato verso destra: lato_ferma.png (la ferma approvata) -> lato_attesa.png
- di lato verso sinistra: la stessa ferma specchiata, ma con la fascia del lato sinistro: il cerchio d'oro sta
  dall'altra parte della testa, quindi li' la fascia continua, con una terza croce come nella corsa verso
  sinistra -> lato_sinistro_attesa.png
uso: attesa_viste.py cartella_lei_chibi cartella_anteprime"""
import os
import sys

import numpy as np
from PIL import Image

CORPO = [0, 1, 1, 1, 0, 0]
BRACCIA = [0, 1, 2, 2, 1, 1]       # la mano; la spalla va col corpo
PUNTE = [0, 0, 1, 1, 1, 0]         # capelli e treccia: un fotogramma dopo la testa
DURATE = [110, 100, 110, 100, 100, 110]
LEI, ANTE = sys.argv[1], sys.argv[2]


def lineare(r, r0, d0, r1, d1):
    t = min(max((r - r0) / float(r1 - r0), 0.0), 1.0)
    return d0 + (d1 - d0) * t


def posa(out, src, parte, dy):
    # ogni colonna della parte sale di dy(riga, colonna); dove si allunga, la riga sopra si ripete
    H, W = parte.shape
    for x in range(W):
        rr = np.nonzero(parte[:, x])[0]
        prima = None
        for r in rr:
            dest = r - int(np.floor(dy(r, x) + 0.5))
            if prima is not None and prima[0] == r - 1 and dest - prima[1] == 2:
                out[dest - 1, x] = src[r - 1, x]
            if 0 <= dest < H:
                out[dest, x] = src[r, x]
            prima = (r, dest)


def anima(src, parti):
    # parti: (maschera, f(b, a, p) -> dy(riga, colonna)), nell'ordine in cui si disegnano (l'ultima sta sopra)
    fot = []
    for k in range(6):
        b, a, p = CORPO[k], BRACCIA[k], PUNTE[k]
        out = np.zeros_like(src)
        for m, f in parti:
            posa(out, src, m, f(b, a, p))
        fot.append(out)
    return fot


def righe(H, W, intervalli):
    # maschera da {riga: [(x0, x1), ...]}
    m = np.zeros((H, W), bool)
    for r, xx in intervalli.items():
        for x0, x1 in xx:
            m[r, x0:x1 + 1] = True
    return m


# ---------------------------------------------------------------- di spalle (40x81)
def dietro(src):
    H, W = src.shape[:2]
    op = src[..., 3] > 0
    Y, X = np.mgrid[0:H, 0:W]
    # le braccia (guanti) dalla riga 52 alle mani: a sinistra fino a x, a destra da x (letti dal disegno)
    sx = {52: 11, 53: 13, 54: 13, 55: 13, 56: 12, 57: 11, 58: 11, 59: 10, 60: 10, 61: 9, 62: 9, 63: 9, 64: 8, 65: 6}
    dx = {52: 27, 53: 25, 54: 25, 55: 25, 56: 26, 57: 27, 58: 28, 59: 28, 60: 28, 61: 28, 62: 28, 63: 29, 64: 30,
          65: 32}
    braccia = op & righe(H, W, {r: [(0, sx[r]), (dx[r], W - 1)] for r in sx})
    coda = op & (Y <= 19)                                             # le punte e il laccio
    capelli = op & (Y >= 34) & (Y <= 48) & ~braccia & ~((Y >= 46) & (X >= 10) & (X <= 28))
    gambe = op & (Y >= 63) & ~braccia
    corpo = op & ~coda & ~capelli & ~braccia & ~gambe
    return anima(src, [
        (gambe & (X <= 19), lambda b, a, p: lambda r, x: lineare(r, 77, b, 80, 0)),   # il tallone si alza
        (gambe & (X >= 20), lambda b, a, p: lambda r, x: lineare(r, 71, b, 76, 0)),   # si allunga sotto il ginocchio
        (corpo, lambda b, a, p: lambda r, x: b),
        (capelli, lambda b, a, p: lambda r, x: lineare(r, 34, b, 48, p)),
        (coda, lambda b, a, p: lambda r, x: lineare(r, 19, b, 4, p)),
        (braccia, lambda b, a, p: lambda r, x: lineare(r, 52, b, 65, a)),
    ])


# ---------------------------------------------------------------- di lato, verso destra (40x74)
CAPELLI_LATO = [(87, 66, 125), (114, 91, 145), (148, 136, 190), (196, 185, 225), (228, 215, 241)]


def lato(src):
    H, W = src.shape[:2]
    op = src[..., 3] > 0
    Y, X = np.mgrid[0:H, 0:W]
    capello = np.zeros((H, W), bool)
    for c in CAPELLI_LATO:
        capello |= np.all(src[..., :3] == c, axis=-1)
    braccia = op & righe(H, W, {**{r: [(18, 22)] for r in range(45, 57)},
                                57: [(18, 23)], 58: [(18, 24)], 59: [(18, 24)], 60: [(18, 24)], 61: [(18, 23)]})
    coda = op & (Y <= 14)
    treccia = op & capello & (Y >= 41) & (Y <= 44) & (X >= 23) & (X <= 26)
    gambe = op & (Y >= 59) & ~braccia
    corpo = op & ~coda & ~treccia & ~braccia & ~gambe
    return anima(src, [
        # la gamba sale col corpo; sotto la caviglia la punta (davanti, x >= 21) resta a terra: il tallone si alza
        (gambe, lambda b, a, p: lambda r, x: b if (r < 70 or x <= 20) else 0),
        (corpo, lambda b, a, p: lambda r, x: b),
        (treccia, lambda b, a, p: lambda r, x: p),
        (coda, lambda b, a, p: lambda r, x: lineare(r, 14, b, 0, p)),
        (braccia, lambda b, a, p: lambda r, x: lineare(r, 45, b, 60, a)),
    ])


# la fascia senza il cerchio d'oro (righe 16-24, x 23-36 della ferma verso destra): sopra, i capelli chiudono la
# testa; la fascia passa dritta col bordo scuro, l'ombra in basso e una terza croce come le altre due
PEZZA = ['BBBBA.........',
         'DCCCBAA.......',
         'DDCCCBBAAKKKK.',
         'DCCCKKKKKLLLLK',
         'KKKKLLLLLLLLLK',
         'LLOLLLLLLLLLLK',
         'LOODLLLLNNNNNK',
         'LLDNNNNNKCBKKK',
         'NNNKKKKKBCDCBA']
TINTE = {'A': (87, 66, 125), 'B': (114, 91, 145), 'C': (148, 136, 190), 'D': (196, 185, 225),
         'K': (74, 26, 52), 'L': (126, 33, 64), 'N': (98, 34, 62), 'O': (228, 215, 241)}


def senza_cerchio(src):
    out = src.copy()
    for i, riga in enumerate(PEZZA):
        for j, ch in enumerate(riga):
            y, x = 16 + i, 23 + j
            if ch == '.':
                out[y, x] = 0
            else:
                out[y, x, :3] = TINTE[ch]; out[y, x, 3] = 255
    return out


def salva(fot, nome):
    Image.fromarray(np.concatenate(fot, axis=1), 'RGBA').save(os.path.join(LEI, nome))


carica = lambda n: np.asarray(Image.open(os.path.join(LEI, n)).convert('RGBA')).copy()
spalle = dietro(carica('dietro_ferma.png'))
destra = lato(carica('lato_ferma.png'))
sinistra = [f[:, ::-1].copy() for f in lato(senza_cerchio(carica('lato_ferma.png')))]
salva(spalle, 'dietro_attesa.png')
salva(destra, 'lato_attesa.png')
salva(sinistra, 'lato_sinistro_attesa.png')

# anteprime: le quattro attese insieme (di fronte, di spalle, verso destra, verso sinistra), coi piedi sulla
# stessa riga, ingrandite 5 volte su un verde da prato: la GIF coi tempi veri e il foglio dei 6 fotogrammi
fronte = carica('davanti_attesa.png')
fronte = [fronte[:, k * 40:(k + 1) * 40] for k in range(6)]
viste = [fronte, spalle, destra, sinistra]
suole = [int(np.nonzero((v[0][..., 3] > 0).any(axis=1))[0].max()) for v in viste]
z, Hc = 5, 86
quadri = []
for k in range(6):
    tela = Image.new('RGBA', (4 * 44, Hc), (60, 96, 62, 255))
    for i, v in enumerate(viste):
        im = Image.fromarray(v[k], 'RGBA')
        tela.alpha_composite(im, (i * 44 + 2, Hc - 4 - suole[i]))
    quadri.append(tela.convert('RGB').resize((4 * 44 * z, Hc * z), Image.NEAREST))
quadri[0].save(os.path.join(ANTE, 'attese.gif'), save_all=True, append_images=quadri[1:], duration=DURATE, loop=0)
fg = Image.new('RGB', (3 * 4 * 44 * 4 + 20, 2 * Hc * 4 + 10), (40, 40, 48))
for k, q in enumerate(quadri):
    fg.paste(q.resize((4 * 44 * 4, Hc * 4), Image.NEAREST), ((k % 3) * (4 * 44 * 4 + 10), (k // 3) * (Hc * 4 + 10)))
fg.save(os.path.join(ANTE, 'attese_foglio.png'))
print('fatto: suole', suole)
