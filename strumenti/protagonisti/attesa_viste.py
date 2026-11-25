"""Lei ferma di spalle e di lato: l'attesa come quella di fronte (attesa_davanti.py), 6 fotogrammi da ~0,1 s.
Piedi fermi a terra; il corpo sale di 1 pixel (fotogrammi 2-4) e torna giu', con la testa, i capelli, la fascia
e le braccia tutti insieme, e la gamba che si allunga sotto la coscia. Le punte del ciuffo (e di spalle quelle delle
ciocche ai lati) si piegano con un fotogramma di ritardo: il confine fra punta e resto segue la forma di ogni ciocca
(la distanza dal laccio camminando dentro i capelli), non una riga dritta (Bru).
- di spalle: dietro_ferma.png -> dietro_attesa.png
- di lato: le ferme fatte da ferma_lato.py (testa della corsa di lato, stivali come di fronte), 40x81:
  lato_destro_ferma.png -> lato_attesa.png, lato_sinistro_ferma.png -> lato_sinistro_attesa.png
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


def sposta(out, src, parte, dy):
    # la parte intera, sollevata di dy pixel: non si allunga e non si accorcia
    ys, xs = np.nonzero(parte)
    d = ys - dy
    ok = (d >= 0) & (d < out.shape[0])
    out[d[ok], xs[ok]] = src[ys[ok], xs[ok]]


def anima(src, parti):
    # parti: (maschera, f(b, a, p) -> dy(riga, colonna)) oppure (maschera, f(b, a, p) -> dy, 'intera') per i
    # capelli, che si spostano interi; nell'ordine in cui si disegnano (l'ultima sta sopra)
    fot = []
    for k in range(6):
        b, a, p = CORPO[k], BRACCIA[k], PUNTE[k]
        out = np.zeros_like(src)
        for parte in parti:
            m, f = parte[0], parte[1]
            if len(parte) > 2 and parte[2] == 'intera':
                sposta(out, src, m, f(b, a, p))
            else:
                posa(out, parte[3] if len(parte) > 3 else src, m, f(b, a, p))
        fot.append(out)
    return fot


def righe(H, W, intervalli):
    # maschera da {riga: [(x0, x1), ...]}
    m = np.zeros((H, W), bool)
    for r, xx in intervalli.items():
        for x0, x1 in xx:
            m[r, x0:x1 + 1] = True
    return m


# ---------------------------------------------------------------- le punte che si piegano
LATTICE = {(6, 7, 15), (22, 37, 52), (49, 59, 70), (69, 79, 85)}
FASCIA = (114, 38, 63)


def laccio(src):
    # la riga del laccio dei capelli: la prima (dall'alto) con 3 o piu' pixel di lattice; se non c'e', 4 righe sopra
    # la cima della fascia
    op = src[..., 3] > 0
    cima = int(np.nonzero(op.any(axis=1))[0].min())
    for y in range(cima, cima + 30):
        if sum(1 for x in range(src.shape[1]) if op[y, x] and tuple(src[y, x, :3]) in LATTICE) >= 3:
            return y
    m = np.all(src[..., :3] == FASCIA, axis=-1) & op
    return int(np.nonzero(m.any(axis=1))[0].min()) - 4


def punte(regione, origine, frazione):
    # la distanza di ogni pixel della regione dall'origine, camminando dentro la regione (anche in diagonale):
    # le punte sono i pixel piu' lontani. Il confine fra punta e resto segue cosi' la forma di ogni ciocca, non
    # una riga dritta (Bru)
    H, W = regione.shape
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


def con_punte(punta):
    # tutto si muove col corpo (b); le punte con un fotogramma di ritardo (p): dove si staccano la ciocca si
    # allunga di un pixel, dove si avvicinano si accorcia, sempre dentro la ciocca
    return lambda b, a, p: lambda r, x: p if punta[r, x] else b


# ---------------------------------------------------------------- di spalle (40x81)
def dietro(src):
    H, W = src.shape[:2]
    op = src[..., 3] > 0
    Y, X = np.mgrid[0:H, 0:W]
    T = laccio(src)
    ciuffo = op & (Y < T)
    punta = punte(ciuffo, ciuffo & (Y == T - 1), 0.5)
    punta |= op & (Y >= 43) & (Y <= 48) & ((X <= 9) | (X >= 29))      # le punte delle ciocche ai lati
    gambe = op & (Y >= 63) & (X >= 11) & (X <= 28)
    resto = op & ~gambe
    return anima(src, [
        (gambe, lambda b, a, p: lambda r, x: lineare(r, 63, b, 68, 0)),   # i piedi restano a terra
        (resto, con_punte(punta)),
    ])


# ---------------------------------------------------------------- di lato (40x81, ferma_lato.py)
def lato(src, a_sinistra):
    # testa, capelli, fascia (col cerchio d'oro), treccia, busto e braccio si muovono insieme col corpo; solo le
    # punte del ciuffo si piegano in ritardo. Il piede resta tutto a terra, tacco compreso; quando il corpo sale la
    # gamba si allunga fra la coscia e il ginocchio
    H, W = src.shape[:2]
    op = src[..., 3] > 0
    Y, X = np.mgrid[0:H, 0:W]
    T = laccio(src)
    ciuffo = op & (Y < T)
    punta = punte(ciuffo, ciuffo & (Y == T - 1), 0.5)
    gambe = op & (Y >= 65)
    resto = op & ~gambe
    return anima(src, [
        (gambe, lambda b, a, p: lambda r, x: lineare(r, 65, b, 70, 0)),
        (resto, con_punte(punta)),
    ])


def salva(fot, nome):
    Image.fromarray(np.concatenate(fot, axis=1), 'RGBA').save(os.path.join(LEI, nome))


carica = lambda n: np.asarray(Image.open(os.path.join(LEI, n)).convert('RGBA')).copy()
spalle = dietro(carica('dietro_ferma.png'))
destra = lato(carica('lato_destro_ferma.png'), False)
sinistra = lato(carica('lato_sinistro_ferma.png'), True)
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
