"""Lei ferma di spalle e di lato: l'attesa come quella di fronte (attesa_davanti.py), 6 fotogrammi da ~0,1 s.
Piedi fermi; il corpo sale di 1 pixel (fotogrammi 2-4) e torna giu'; le braccia salgono con lui e poi di un altro
pixel, e scendono in ritardo; i capelli in alto (e di spalle la parte bassa dei capelli, di lato le punte dietro) seguono
la testa con un fotogramma di ritardo, interi (non si allungano ne' si accorciano: l'attacco resta sotto i
capelli della testa); un tallone si alza, la punta resta a terra.
- di spalle: dietro_ferma.png -> dietro_attesa.png (il tallone che si alza e' quello del piede sinistro di Lei,
  come di fronte; l'altra gamba si allunga sotto il ginocchio)
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
            if len(parte) > 2:
                sposta(out, src, m, f(b, a, p))
            else:
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
    # i capelli si spostano interi, con l'attacco (qualche riga sopra) che la testa copre; la parte bassa dei
    # capelli sta sopra la schiena, quindi si disegna dopo il busto e prima della testa
    coda_attacco = op & (Y <= 22) & ~braccia
    capelli_attacco = capelli | (op & (Y >= 30) & (Y <= 33))
    testa, busto = corpo & (Y <= 33), corpo & (Y >= 34)
    return anima(src, [
        (gambe & (X <= 19), lambda b, a, p: lambda r, x: lineare(r, 77, b, 80, 0)),   # il tallone si alza
        (gambe & (X >= 20), lambda b, a, p: lambda r, x: lineare(r, 71, b, 76, 0)),   # si allunga sotto il ginocchio
        (busto, lambda b, a, p: lambda r, x: b),
        (braccia, lambda b, a, p: lambda r, x: lineare(r, 52, b, 65, a)),
        (coda_attacco, lambda b, a, p: p, 'intera'),
        (capelli_attacco, lambda b, a, p: p, 'intera'),
        (testa, lambda b, a, p: lambda r, x: b),
    ])


# ---------------------------------------------------------------- di lato (40x81, ferma_lato.py)
def lato(src, a_sinistra):
    # le parti della ferma verso sinistra (viso a sinistra); verso destra le stesse colonne specchiate
    H, W = src.shape[:2]
    op = src[..., 3] > 0
    Y, X = np.mgrid[0:H, 0:W]
    Xs = X if a_sinistra else (W - 1) - X                       # la colonna come se guardasse a sinistra
    braccio = {**{r: (16, 20) for r in range(51, 63)}, 63: (15, 20), 64: (14, 20), 65: (14, 20), 66: (14, 20),
               67: (15, 19)}
    braccia = np.zeros((H, W), bool)
    for r, (x0, x1) in braccio.items():
        braccia[r] = op[r] & (Xs[r] >= x0) & (Xs[r] <= x1)
    coda = op & (Y <= 21)                                         # le punte e il laccio dei capelli
    dietro = op & (Y >= 42) & (Y <= 46) & (Xs >= 20)              # le punte dei capelli dietro la nuca
    gambe = op & (Y >= 65) & ~braccia
    corpo = op & ~coda & ~dietro & ~braccia & ~gambe
    # i capelli si spostano interi, dietro la testa: l'attacco (qualche riga sopra) resta coperto
    coda_attacco = op & (Y <= 24)
    dietro_attacco = op & (Y >= 38) & (Y <= 46) & (Xs >= 20)
    return anima(src, [
        # la gamba sale col corpo; nel piede la punta (davanti, x <= 17 guardando a sinistra) resta a terra:
        # i talloni (x 18-22) si alzano
        (gambe, lambda b, a, p: lambda r, x: b if (r < 78 or (x if a_sinistra else W - 1 - x) >= 18) else 0),
        (coda_attacco, lambda b, a, p: p, 'intera'),
        (dietro_attacco, lambda b, a, p: p, 'intera'),
        (corpo, lambda b, a, p: lambda r, x: b),
        (braccia, lambda b, a, p: lambda r, x: lineare(r, 51, b, 66, a)),
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
