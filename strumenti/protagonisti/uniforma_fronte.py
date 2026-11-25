"""Lei di fronte uguale in tutti i fogli: via la croce piu' a destra della fascia (Bru: "al front devi togliere la
stella piu' a destra"), nella ferma e nei 12 fotogrammi della corsa di fronte. Al suo posto il colore della fascia
che ha intorno. Si puo' rilanciare: se le croci sono gia' tre non cambia niente.
Poi vanno rifatte l'attesa (attesa_davanti.py) e il salto della corda (corda_davanti.py), che partono dalla ferma.
uso: uniforma_fronte.py cartella_lei_chibi"""
import os
import sys
from collections import Counter

import numpy as np
from PIL import Image

LEI = sys.argv[1]


def rattoppa(a, punti):
    # ogni pixel della croce prende il colore piu' frequente fra i vicini che non sono croce (prima le braccia,
    # poi il centro, che a quel punto ha i vicini gia' rattoppati)
    punti = set(punti)
    for p in sorted(punti, key=lambda q: sum((q[0] + dx, q[1] + dy) in punti
                                             for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))):
        x, y = p
        vic = [tuple(a[y + dy, x + dx]) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
               if (x + dx, y + dy) not in punti and a[y + dy, x + dx, 3] > 0]
        a[y, x] = Counter(vic).most_common(1)[0][0]
        punti.discard(p)


# la ferma: le quattro croci (chiare, come le luci dei capelli) hanno il centro a x 15, 20, 25, 29;
# l'ultima e' il segno + intorno a (29, 21)
p = os.path.join(LEI, 'davanti_ferma.png')
a = np.asarray(Image.open(p).convert('RGBA')).copy()
CROCE = [(29, 20), (28, 21), (29, 21), (30, 21), (29, 22)]
if tuple(a[21, 29, :3]) == (228, 215, 241):
    rattoppa(a, CROCE)
    Image.fromarray(a, 'RGBA').save(p)
    print('ferma: tolta la quarta croce')

# la corsa: le croci sono segni + di 5 pixel (245, 205, 226) sopra la riga 35; se sono quattro, via l'ultima
p = os.path.join(LEI, 'davanti_corsa.png')
a = np.asarray(Image.open(p).convert('RGBA')).copy()
Q = np.all(a[..., :3] == (245, 205, 226), axis=-1) & (a[..., 3] > 0)
n = a.shape[1] // 40
for k in range(n):
    centri = []
    for y in range(1, 35):
        for x in range(k * 40 + 1, k * 40 + 39):
            if Q[y, x] and Q[y - 1, x] and Q[y + 1, x] and Q[y, x - 1] and Q[y, x + 1]:
                centri.append((x, y))
    if len(centri) == 4:
        x, y = max(centri)
        rattoppa(a, [(x, y), (x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)])
        print('corsa', k, ': tolta la croce a', (x - k * 40, y))
Image.fromarray(a, 'RGBA').save(p)
