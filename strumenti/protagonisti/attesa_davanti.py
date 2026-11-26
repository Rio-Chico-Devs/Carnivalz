"""Lei ferma di fronte: l'animazione d'attesa come la GIF di Bru (6 fotogrammi, ~0,1 s l'uno).
Piedi fermi; il corpo sale di 1 pixel (fotogrammi 2-4) e torna giu' (5-6): a sinistra la coscia si
allunga, a destra (per chi guarda) la gamba sale tutta e il tallone si alza, la punta resta a terra;
le braccia salgono con lui e poi di un altro pixel, e scendono in ritardo.
I capelli (le punte in alto e le ciocche ai lati del viso) seguono la testa con un fotogramma di ritardo,
interi: si spostano senza allungarsi ne' accorciarsi, e l'attacco resta sotto i capelli della testa, che li
copre (Bru: prima "sembra come se fosse solo croppato"). Sopra c'e' un margine di 2 righe, cosi' le punte
che salgono non escono dal fotogramma (40x76).
uso: attesa.py davanti_ferma.png striscia.png anteprima.gif foglio.png"""
import sys
import numpy as np
from PIL import Image
src = np.asarray(Image.open(sys.argv[1]).convert('RGBA'))
H, W = src.shape[:2]
MA = 2                                  # righe libere sopra
op = src[..., 3] > 0
Y, X = np.mgrid[0:H, 0:W]
# le parti (righe e colonne della posa di fronte, 40x74)
# in ritardo vanno solo i capelli: nelle righe dell'attacco e nelle zone delle ciocche ci sono anche il bordo di sopra
# del cerchio d'oro, il bordo della fascia, le ciglia e la pelle ai lati del viso, che devono muoversi interi con la
# testa (Bru: il cerchio "deve muoversi ma non allungarsi... per intero, non aggiungendo o sottraendo pixel")
CAPELLI_COL = {(87, 66, 125), (114, 91, 145), (148, 136, 190), (196, 185, 225), (228, 215, 241)}
LACCETTI = {(22, 37, 52)}                                              # i laccetti scuri delle ciocche
capelli = np.zeros(op.shape, bool)
for c in CAPELLI_COL:
    capelli |= np.all(src[..., :3] == c, axis=-1)
laccetti = np.zeros(op.shape, bool)
for c in LACCETTI:
    laccetti |= np.all(src[..., :3] == c, axis=-1)
punte = op & (Y <= 13)                                                 # le punte in alto e il laccio
ciocche = op & (Y >= 36) & (Y <= 45) & ((X <= 9) | (X >= 29)) & (capelli | laccetti)
braccia = op & (Y >= 46) & (Y <= 61) & ((X <= 11) | (X >= 28))
gambe = op & (Y >= 59) & ~braccia
gamba_sx, gamba_dx = gambe & (X <= 19), gambe & (X >= 20)
corpo = op & ~punte & ~ciocche & ~braccia & ~gambe
# i capelli che si muovono, con l'attacco: qualche riga sopra che la testa poi copre
punte_attacco = op & (Y <= 16) & ~braccia & ((Y <= 13) | capelli)
ciocche_attacco = op & (Y >= 32) & (Y <= 45) & ((X <= 9) | (X >= 29)) & (capelli | laccetti)
#            f1 f2 f3 f4 f5 f6
CORPO =     [0, 1, 1, 1, 0, 0]
BRACCIA =   [0, 1, 2, 2, 1, 1]     # la mano; la spalla va col corpo
CAPELLI =   [0, 0, 1, 1, 1, 0]     # punte e ciocche: un fotogramma dopo la testa
DURATE = [110, 100, 110, 100, 100, 110]


def lineare(r, r0, d0, r1, d1):
    t = np.clip((r - r0) / float(r1 - r0), 0, 1)
    return d0 + (d1 - d0) * t


def posa(out, parte, dy_di):
    # ogni colonna della parte scende o sale di dy(riga); dove si allunga, la riga sopra si ripete
    for x in range(W):
        rr = np.nonzero(parte[:, x])[0]
        prima = None
        for r in rr:
            d = int(np.floor(dy_di(r) + 0.5))
            dest = r - d + MA
            if prima is not None and prima[0] == r - 1 and dest - prima[1] == 2:
                out[dest - 1, x] = src[r - 1, x]
            if 0 <= dest < H + MA:
                out[dest, x] = src[r, x]
            prima = (r, dest)


def sposta(out, parte, dy):
    # la parte intera, sollevata di dy pixel
    ys, xs = np.nonzero(parte)
    out[ys - dy + MA, xs] = src[ys, xs]


fot = []
for k in range(6):
    b, a, c = CORPO[k], BRACCIA[k], CAPELLI[k]
    out = np.zeros((H + MA, W, 4), np.uint8)
    posa(out, gamba_sx, lambda r: lineare(r, 58, b, 62, 0))       # piede fermo, coscia che si allunga
    posa(out, gamba_dx, lambda r: lineare(r, 69, b, 72, 0))       # il tallone si alza, la punta resta
    posa(out, braccia, lambda r: lineare(r, 46, b, 60, a))
    sposta(out, punte_attacco, c)                                 # dietro la testa: l'attacco resta coperto
    sposta(out, ciocche_attacco, c)
    sposta(out, corpo, b)
    fot.append(out)
striscia = np.concatenate(fot, axis=1)
Image.fromarray(striscia, 'RGBA').save(sys.argv[2])
# anteprima: GIF ingrandita 6 volte su fondo chiaro, coi tempi della GIF di Bru
z = 6
Hc = H + MA
gif = []
for f in fot:
    im = Image.new('RGB', (W * z, Hc * z), (205, 205, 210))
    g = Image.fromarray(f, 'RGBA').resize((W * z, Hc * z), Image.NEAREST)
    im.paste(g, (0, 0), g)
    gif.append(im)
gif[0].save(sys.argv[3], save_all=True, append_images=gif[1:], duration=DURATE, loop=0)
# foglio dei 6 fotogrammi, per controllare
fg = Image.new('RGB', (6 * (W * z + 12), Hc * z), (205, 205, 210))
for k, im in enumerate(gif):
    fg.paste(im, (k * (W * z + 12), 0))
fg.save(sys.argv[4])
print('fatto', striscia.shape)
