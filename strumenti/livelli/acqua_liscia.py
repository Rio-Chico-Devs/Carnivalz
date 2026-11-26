"""L'acqua liscia del ruscello (Bru: "mi sono ricreduto sulla grafica dell'acqua del fiume: mi piacerebbe non avesse i
ghirigori e fosse come le acque degli altri oggetti"). Le vasche e la pozza hanno un'acqua calma: un tono pieno, piu'
scura verso i bordi, il filo chiaro sotto la sponda di la', pochi riflessi corti. Qui la tessera del ruscello fatta
cosi': il tono pieno, qualche corrente lunga e morbida appena piu' scura o piu' chiara (nel verso dell'acqua, cosi'
quando scorre si vede andare), pochi riflessi chiari corti, qualche puntino di luce. Niente ghirigori.
E' nei colori della scala vecchia dell'acqua (AQ di ruscello_radenna.py, a indice): la mappa e la pagina la usano come
la tessera di prima (scuriscono a gradini verso le sponde, la fanno scorrere lungo il filo, passano ai colori nuovi
allo stesso indice). Si ripete senza giunture, 192x192; la x e' il verso della corrente.
uso: acqua_liscia.py cartella_terreni [anteprima.png]"""
import os
import sys

import numpy as np
from PIL import Image

T = 192
AQ = np.array([(1, 119, 127), (2, 133, 136), (2, 156, 149), (1, 182, 168), (2, 213, 192), (2, 231, 204),
               (18, 242, 218), (79, 253, 237), (117, 255, 252), (210, 255, 250)], np.uint8)
FONDO = 5                                     # il tono pieno (come il mezzo dell'acqua nelle vasche)


def tessera(seme=12):
    rng = np.random.default_rng(seme)
    k = np.full((T, T), FONDO, int)
    yy, xx = np.mgrid[0:T, 0:T]

    def ovale(cx, cy, rx, ry):
        dx = (xx - cx + T / 2) % T - T / 2          # il giro della tessera
        dy = (yy - cy + T / 2) % T - T / 2
        return (dx / rx) ** 2 + (dy / ry) ** 2 <= 1
    # le correnti: ovali lunghi e sottili nel verso dell'acqua, un gradino piu' scuri o piu' chiari
    for _ in range(9):
        k[ovale(rng.uniform(0, T), rng.uniform(0, T), rng.uniform(22, 48), rng.uniform(1.6, 3.2))] = FONDO - 1
    for _ in range(5):
        k[ovale(rng.uniform(0, T), rng.uniform(0, T), rng.uniform(14, 30), rng.uniform(1.2, 2.2))] = FONDO + 1
    # i riflessi: trattini corti e chiari (le punte un gradino meno), qualcuno col puntino di luce
    for _ in range(26):
        x0, y0, L = int(rng.integers(0, T)), int(rng.integers(0, T)), int(rng.integers(3, 8))
        for i in range(L):
            k[y0 % T, (x0 + i) % T] = FONDO + 2 if 0 < i < L - 1 else FONDO + 1
        if rng.random() < 0.35:
            k[(y0 - 1) % T, (x0 + L // 2) % T] = FONDO + 3
    return AQ[k], k


if __name__ == '__main__':
    TER = sys.argv[1]
    img, k = tessera()
    Image.fromarray(img).save(os.path.join(TER, 'acqua_liscia.png'))
    if len(sys.argv) > 2:
        t = np.tile(img, (1, 2, 1))
        Image.fromarray(t).resize((t.shape[1] * 3, t.shape[0] * 3), Image.NEAREST).save(sys.argv[2])
    print('tessera', T, 'x', T, {int(v): int((k == v).sum()) for v in np.unique(k)})
