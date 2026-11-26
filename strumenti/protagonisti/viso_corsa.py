"""La corsa di fronte col viso della ferma (Bru: "la corsa verso il front non ha la faccia proporzionata bene alla idle
pose, le manca il naso e ha gli occhi troppo grandi"). Nella corsa l'iride era larga 5 pixel, con una colonna di
bianco verso l'esterno; ora in tutti e 12 i fotogrammi gli occhi sono quelli della ferma: iride di 4 pixel (luce e
riflesso verso l'esterno, pupilla e magenta verso il naso), le stesse ciglia e lo stesso angolo in basso. E c'e' il
naso della ferma: un pixel di luce all'altezza del fondo degli occhi e uno d'ombra sotto.
Gli occhi restano attaccati ai capelli ai lati, come nella ferma: il viso della corsa e' largo un pixel in piu', e
quel pixel va fra gli occhi. Il viso sta un po' piu' su o piu' giu' (e di un pixel a destra) secondo il fotogramma:
POSTO dice dove, rispetto al fotogramma 0. Colori della corsa (pelle e occhi), la luce del naso come nella ferma.
Rifarlo non cambia niente (toglie gli occhi e rimette gli stessi).
uso: viso_corsa.py davanti_corsa.png [anteprima.png]"""
import sys

import numpy as np
from PIL import Image

NERO = (6, 7, 15)
# i colori della ferma (le lettere) tradotti in quelli della corsa
COL = {'l': NERO,
       'A': (187, 144, 170),     # luce dell'iride
       'B': (78, 34, 90),        # pupilla
       '1': (125, 62, 135),      # magenta
       '0': (245, 205, 226),     # riflesso
       'e': (207, 158, 118),     # pelle
       'c': (187, 140, 118),     # pelle in ombra
       'd': (164, 121, 108),     # pelle scura
       '2': (225, 183, 158)}     # la luce del naso (nella ferma 227,187,158 sulla pelle 212,165,122)
# gli occhi della ferma (davanti_ferma.png, righe 30-35): il sinistro da x 9, il destro da x 21
SINISTRO = ['llll.',
            'lllll',
            'lAABB',
            'lAABB',
            'd0011',
            '.c011']
DESTRO = ['.lllll',
          'llllll',
          '.BBAAl',
          '.BBAAl',
          '.1100d',
          '.110c.']
NASO = ['2',
        'c']
# nel fotogramma 0 della corsa: le ciglia cominciano alla riga 35, il contorno dell'occhio sinistro e' a x 10, quello
# del destro a x 28 (nella ferma 9 e 26); il naso a x 16, riga 40 (nella ferma x 15, riga 35)
SX, DX, NX, RIGA = 10, 23, 16, 35
# dove sta il viso negli altri fotogrammi (dx, dy), trovato confrontando occhi e bocca col fotogramma 0
POSTO = [(0, 0), (0, 1), (0, 2), (0, 4), (0, 4), (0, 2), (0, 1), (0, 2), (1, 3), (1, 4), (1, 4), (0, 1)]
# cosa si toglie dei vecchi occhi (diventa pelle): nelle ciglia il nero, nell'iride anche i colori degli occhi e i
# chiari usati come bianco; i capelli scuri e le ombre della pelle ai lati restano
OCCHI = {NERO, (78, 34, 90), (125, 62, 135), (187, 144, 170), (245, 205, 226),
         (191, 172, 209), (206, 185, 223), (168, 148, 189)}
VECCHI = [(RIGA, RIGA + 6, 10, 16), (RIGA, RIGA + 6, 22, 29)]     # righe e colonne dei vecchi occhi


def disegna(f, righe, x0, y0):
    for j, r in enumerate(righe):
        for i, ch in enumerate(r):
            if ch != '.':
                f[y0 + j, x0 + i, :3] = COL[ch]
                f[y0 + j, x0 + i, 3] = 255


a = np.asarray(Image.open(sys.argv[1]).convert('RGBA')).copy()
prima = a.copy()
n = a.shape[1] // 40
assert n == len(POSTO)
for k in range(n):
    f = a[:, k * 40:(k + 1) * 40]
    dx, dy = POSTO[k]
    for y0, y1, x0, x1 in VECCHI:
        for y in range(y0 + dy, y1 + dy):
            for x in range(x0 + dx, x1 + dx):
                c = tuple(int(v) for v in f[y, x, :3])
                if f[y, x, 3] and (c == NERO or (y - dy >= RIGA + 2 and c in OCCHI)):
                    f[y, x, :3] = COL['e']
    disegna(f, SINISTRO, SX + dx, RIGA + dy)
    disegna(f, DESTRO, DX + dx, RIGA + dy)
    disegna(f, NASO, NX + dx, RIGA + 5 + dy)
Image.fromarray(a, 'RGBA').save(sys.argv[1])
print('cambiati', int(np.any(a != prima, axis=-1).sum()), 'pixel in', n, 'fotogrammi')

if len(sys.argv) > 2:
    # anteprima: le teste prima (sopra) e dopo (sotto), x6, con la ferma di fronte in testa a ogni riga
    import os
    ferma = np.asarray(Image.open(os.path.join(os.path.dirname(sys.argv[1]), 'davanti_ferma.png')).convert('RGBA'))
    z, h = 6, 30

    def testa(img, y0):
        t = Image.new('RGBA', (40, h), (60, 96, 62, 255))
        t.alpha_composite(Image.fromarray(np.ascontiguousarray(img[y0:y0 + h]), 'RGBA'))
        return t.convert('RGB').resize((40 * z, h * z), Image.NEAREST)
    tela = Image.new('RGB', ((n + 1) * (40 * z + 6), 2 * (h * z + 6)), (40, 40, 48))
    for r, sheet in enumerate((prima, a)):
        tela.paste(testa(ferma, 16), (0, r * (h * z + 6)))
        for k in range(n):
            tela.paste(testa(sheet[:, k * 40:(k + 1) * 40], 21 + POSTO[k][1]), ((k + 1) * (40 * z + 6), r * (h * z + 6)))
    tela.save(sys.argv[2])
