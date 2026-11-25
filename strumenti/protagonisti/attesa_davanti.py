"""Lei ferma di fronte: l'animazione d'attesa come la GIF di Bru (6 fotogrammi, ~0,1 s l'uno).
Piedi fermi; il corpo sale di 1 pixel (fotogrammi 2-4) e torna giu' (5-6): a sinistra la coscia si
allunga, a destra (per chi guarda) la gamba sale tutta e il tallone si alza, la punta resta a terra;
le braccia salgono con lui e poi di un altro pixel, e scendono in ritardo; la coda in alto e le
ciocche ai lati seguono la testa con un fotogramma di ritardo (si accorciano e si allungano).
uso: attesa.py davanti_ferma.png striscia.png anteprima.gif foglio.png"""
import sys
import numpy as np
from PIL import Image
src = np.asarray(Image.open(sys.argv[1]).convert('RGBA'))
H, W = src.shape[:2]
op = src[..., 3] > 0
Y, X = np.mgrid[0:H, 0:W]
# le parti (righe e colonne della posa di fronte, 40x74)
coda = op & (Y <= 13)
ciocche = op & (Y >= 36) & (Y <= 45) & ((X <= 9) | (X >= 29))
braccia = op & (Y >= 46) & (Y <= 61) & ((X <= 11) | (X >= 28))
gambe = op & (Y >= 59) & ~braccia
gamba_sx, gamba_dx = gambe & (X <= 19), gambe & (X >= 20)
corpo = op & ~coda & ~ciocche & ~braccia & ~gambe
#            f1 f2 f3 f4 f5 f6
CORPO =     [0, 1, 1, 1, 0, 0]
BRACCIA =   [0, 1, 2, 2, 1, 1]     # la mano; la spalla va col corpo
PUNTE =     [0, 0, 1, 1, 1, 0]     # punte della coda e delle ciocche: un fotogramma dopo la testa
DURATE = [110, 100, 110, 100, 100, 110]


def lineare(r, r0, d0, r1, d1):
    t = np.clip((r - r0) / float(r1 - r0), 0, 1)
    return d0 + (d1 - d0) * t


def posa(out, scritto, parte, dy_di):
    # ogni colonna della parte scende o sale di dy(riga); dove si allunga, la riga sopra si ripete
    for x in range(W):
        rr = np.nonzero(parte[:, x])[0]
        prima = None
        for r in rr:
            d = int(np.floor(dy_di(r) + 0.5))
            dest = r - d
            if prima is not None and prima[0] == r - 1 and dest - prima[1] == 2:
                out[dest - 1, x] = src[r - 1, x]; scritto[dest - 1, x] = True
            if 0 <= dest < H:
                out[dest, x] = src[r, x]; scritto[dest, x] = True
            prima = (r, dest)


fot = []
for k in range(6):
    b, a, p = CORPO[k], BRACCIA[k], PUNTE[k]
    out = np.zeros_like(src); scritto = np.zeros((H, W), bool)
    posa(out, scritto, gamba_sx, lambda r: lineare(r, 58, b, 62, 0))       # piede fermo, coscia che si allunga
    posa(out, scritto, gamba_dx, lambda r: lineare(r, 69, b, 72, 0))       # il tallone si alza, la punta resta
    posa(out, scritto, corpo, lambda r: b)
    posa(out, scritto, ciocche, lambda r: lineare(r, 36, b, 45, p))
    posa(out, scritto, coda, lambda r: lineare(r, 13, b, 0, p))
    posa(out, scritto, braccia, lambda r: lineare(r, 46, b, 60, a))
    fot.append(out)
striscia = np.concatenate(fot, axis=1)
Image.fromarray(striscia, 'RGBA').save(sys.argv[2])
# anteprima: GIF ingrandita 6 volte su fondo chiaro, coi tempi della GIF di Bru
z = 6
gif = []
for f in fot:
    im = Image.new('RGB', (W * z, H * z), (205, 205, 210))
    im.paste(Image.fromarray(f, 'RGBA').resize((W * z, H * z), Image.NEAREST), (0, 0), Image.fromarray(f, 'RGBA').resize((W * z, H * z), Image.NEAREST))
    gif.append(im)
gif[0].save(sys.argv[3], save_all=True, append_images=gif[1:], duration=DURATE, loop=0)
# foglio dei 6 fotogrammi, per controllare
fg = Image.new('RGB', (6 * (W * z + 12), H * z), (205, 205, 210))
for k, im in enumerate(gif):
    fg.paste(im, (k * (W * z + 12), 0))
fg.save(sys.argv[4])
print('fatto', striscia.shape)
