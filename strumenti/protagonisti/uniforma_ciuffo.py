"""Il ciuffo (le punte sopra il laccio dei capelli) con le proporzioni di quello di fronte, il riferimento (Bru: "le
proporzioni del ciuffo, prendi come riferimento la front idle"). Di fronte e' alto 12 righe sopra il laccio e largo
22; di spalle e di lato era alto 14 e largo 26-28. Nelle corse di lato e di spalle e nella ferma di spalle il ciuffo
di ogni fotogramma si rimpicciolisce di 12/14 in altezza e in larghezza, tenuto fermo sul laccio (scelta dei pixel
piu' vicini: si saltano 1 riga e 1 colonna ogni 7, le punte restano punte). La ferma di lato prende la testa dalla
corsa, quindi va rifatta dopo (ferma_lato.py), e poi le attese (attesa_viste.py).
Si fa una volta sola: corsa.json ricorda che il ciuffo e' gia' stato ridotto.
uso: uniforma_ciuffo.py cartella_lei_chibi"""
import json
import os
import sys

import numpy as np
from PIL import Image

LEI = sys.argv[1]
S = 12 / 14.0
LACCIO = {(6, 7, 15), (22, 37, 52), (49, 59, 70), (69, 79, 85)}
FOGLI = ['dietro_ferma.png', 'dietro_corsa.png', 'lato_corsa.png', 'lato_sinistro_corsa.png']

pj = os.path.join(LEI, 'corsa.json')
note = json.load(open(pj, encoding='utf-8'))
if note.get('_ciuffo'):
    print('il ciuffo e\' gia\' stato ridotto'); sys.exit(0)


FASCIA = (126, 33, 64)


def laccio(f):
    # la prima riga (dall'alto) con 3 o piu' pixel di lattice: il laccio; se le punte lo coprono, 4 righe sopra
    # la cima della fascia (di lato e' sempre cosi')
    op = f[..., 3] > 0
    cima = int(np.nonzero(op.any(axis=1))[0].min())
    for y in range(cima, cima + 30):
        xs = [x for x in range(f.shape[1]) if op[y, x] and tuple(f[y, x, :3]) in LACCIO]
        if len(xs) >= 3:
            return y, (min(xs) + max(xs)) / 2.0
    m = np.all(f[..., :3] == FASCIA, axis=-1) & op
    if m.any():
        return int(np.nonzero(m.any(axis=1))[0].min()) - 4, None
    return None, None


def riduci(f, T, cx):
    op = f[..., 3] > 0
    cima = int(np.nonzero(op.any(axis=1))[0].min())
    src = f.copy()
    ciuffo = op.copy(); ciuffo[T:] = False
    f[:T][op[:T]] = 0
    for y in range(0, T):
        ys = T - 1 - int(np.floor((T - 1 - y) / S + 0.5))
        if ys < 0:
            continue
        for x in range(f.shape[1]):
            xs = int(np.floor(cx + (x - cx) / S + 0.5))
            if 0 <= xs < f.shape[1] and ciuffo[ys, xs]:
                f[y, x] = src[ys, xs]
    # via i pixel rimasti staccati (punte spezzate dal rimpicciolimento): si tiene solo cio' che e' attaccato al
    # laccio, toccandosi anche in diagonale
    op = f[..., 3] > 0
    visto = np.zeros_like(op)
    coda = [(T, x) for x in range(f.shape[1]) if op[T, x]]
    for q in coda:
        visto[q] = True
    while coda:
        y, x = coda.pop()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                yy, xx = y + dy, x + dx
                if 0 <= yy <= T and 0 <= xx < f.shape[1] and op[yy, xx] and not visto[yy, xx]:
                    visto[yy, xx] = True
                    coda.append((yy, xx))
    staccati = op[:T] & ~visto[:T]
    f[:T][staccati] = 0
    return T - cima, T - int(np.nonzero((f[..., 3] > 0).any(axis=1))[0].min()), int(staccati.sum())


for nome in FOGLI:
    p = os.path.join(LEI, nome)
    a = np.asarray(Image.open(p).convert('RGBA')).copy()
    n = a.shape[1] // 40
    lacci = [laccio(a[:, k * 40:(k + 1) * 40]) for k in range(n)]
    cxs = [c for _, c in lacci if c is not None]
    cx0 = float(np.median(cxs))                       # la testa e' la stessa in tutti i fotogrammi
    alt = []
    for k, (T, cx) in enumerate(lacci):
        fr = a[:, k * 40:(k + 1) * 40].copy()
        alt.append(riduci(fr, T, cx0))
        a[:, k * 40:(k + 1) * 40] = fr
    Image.fromarray(a, 'RGBA').save(p)
    print(nome, 'ciuffo: altezza prima, dopo, pixel staccati tolti', alt)
note['_ciuffo'] = ("Il ciuffo di spalle e di lato ridotto a 12/14 come quello di fronte (alto 12 sopra il laccio): "
                   "uniforma_ciuffo.py, una volta sola.")
with open(pj, 'w', encoding='utf-8') as fo:
    json.dump(note, fo, indent=2, ensure_ascii=False); fo.write('\n')
