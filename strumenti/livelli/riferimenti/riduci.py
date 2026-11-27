"""riduce un'immagine di pixel art ingrandita alla sua risoluzione vera: col passo dato trova l'inizio migliore per
ogni asse, prende il colore al centro di ogni quadretto (la mediana dei pixel di mezzo, lontano dai bordi sfocati
del JPG), toglie la scacchiera grigia (i grigi neutri collegati al bordo) e salva il PNG trasparente alla misura vera
uso: riduci.py immagine.jpg passo uscita.png"""
import sys
import numpy as np
from PIL import Image
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from griglia2 import disegno, errore_asse

p, s, out = sys.argv[1], float(sys.argv[2]), sys.argv[3]
a = np.asarray(Image.open(p).convert('RGB')).astype(float)
m = disegno(a)
H, W = a.shape[:2]
inizio = []
for asse in (0, 1):
    best = min((errore_asse(a, m, s, o, asse), o) for o in np.arange(0, s, s / 30))
    inizio.append(best[1])
ox, oy = inizio
nx, ny = int((W - ox) / s), int((H - oy) / s)
r = np.zeros((ny, nx, 3))
for j in range(ny):
    for i in range(nx):
        cx, cy = ox + (i + 0.5) * s, oy + (j + 0.5) * s
        x0, x1 = int(np.floor(cx - 0.5)), int(np.floor(cx + 0.5)) + 1
        y0, y1 = int(np.floor(cy - 0.5)), int(np.floor(cy + 0.5)) + 1
        blocco = a[max(0, y0):min(H, y1), max(0, x0):min(W, x1)].reshape(-1, 3)
        r[j, i] = np.median(blocco, axis=0)
# la scacchiera: grigi neutri, collegati al bordo
mx, mn = r.max(2), r.min(2)
luma = r @ np.array([0.3, 0.55, 0.15])
grigio = ((mx - mn) < 14) & (luma > 95)
fondo = np.zeros((ny, nx), bool)
pila = [(j, i) for j in range(ny) for i in (0, nx - 1)] + [(j, i) for i in range(nx) for j in (0, ny - 1)]
while pila:
    j, i = pila.pop()
    if 0 <= j < ny and 0 <= i < nx and grigio[j, i] and not fondo[j, i]:
        fondo[j, i] = True
        pila += [(j + 1, i), (j - 1, i), (j, i + 1), (j, i - 1)]
img = np.zeros((ny, nx, 4), np.uint8)
img[..., :3] = np.clip(np.rint(r), 0, 255).astype(np.uint8)
img[..., 3] = np.where(fondo, 0, 255)
Image.fromarray(img, 'RGBA').save(out)
print(out, 'misura vera %dx%d, inizio %.2f %.2f, pixel del disegno %d' % (nx, ny, ox, oy, int((~fondo).sum())))
