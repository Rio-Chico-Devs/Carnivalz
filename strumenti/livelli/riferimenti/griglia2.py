"""la griglia dei pixel di un'immagine di pixel art ingrandita (passo anche non intero): il passo e l'inizio che,
campionando il mezzo di ogni quadretto e ridisegnando a quadretti, rifanno meglio l'immagine (solo dove c'e' il
disegno, non la scacchiera grigia)"""
import sys
import numpy as np
from PIL import Image


def disegno(a):
    mx, mn = a.max(2), a.min(2)
    luma = a @ np.array([0.3, 0.55, 0.15])
    return ((mx - mn) > 14) | (luma < 75)


def errore_asse(a, m, s, o, asse):
    n = a.shape[1 - asse] if asse == 0 else a.shape[0]
    n = a.shape[1] if asse == 0 else a.shape[0]
    idx = np.floor((np.arange(n) - o) / s)
    c = np.clip(np.rint(o + (idx + 0.5) * s).astype(int), 0, n - 1)
    r = a[:, c] if asse == 0 else a[c, :]
    return (np.abs(r - a).sum(2) * m).sum() / m.sum()


if __name__ == '__main__':
  for p in sys.argv[1:]:
    a = np.asarray(Image.open(p).convert('RGB')).astype(float)
    m = disegno(a)
    out = []
    for asse in (0, 1):
        best = None
        for s in np.arange(2.2, 6.0, 0.01):
            for o in np.arange(0, s, s / 10):
                e = errore_asse(a, m, s, o, asse)
                if best is None or e < best[0]:
                    best = (e, s, o)
        out.append(best)
    print(p.split('/')[-1], '- x: passo %.2f inizio %.2f (err %.1f) - y: passo %.2f inizio %.2f (err %.1f)' % (
        out[0][1], out[0][2], out[0][0], out[1][1], out[1][2], out[1][0]))
