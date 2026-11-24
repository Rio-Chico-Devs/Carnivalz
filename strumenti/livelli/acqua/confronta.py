"""L'acqua dipinta dalla pagina (salvata da prova_acqua.js) contro quella di anima.py allo stesso tempo:
devono venire uguali pixel per pixel.
uso: confronta.py acqua.npz acqua_pagina.raw tempo"""
import sys, os
QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
import numpy as np
from PIL import Image
from anima import Acqua
A = Acqua(sys.argv[1], os.path.join(QUI, '..', '..', '..', 'art', 'livelli', 'terreni', 'acqua_radenna.png'))
t = float(sys.argv[3])
js = np.fromfile(sys.argv[2], np.uint8).reshape(A.H, A.W, 4)
py = A.fotogramma(t)
m = js[..., 3] == 255
print('pixel animati: js', int(m.sum()), 'python', int(A.anim.sum()), 'uguali le maschere', bool((m == A.anim).all()))
diff = m & (js[..., :3] != py).any(2)
print('pixel diversi', int(diff.sum()))
if diff.any():
    ys, xs = np.nonzero(diff)
    for y, x in list(zip(ys, xs))[:12]:
        print((y, x), 'js', js[y, x, :3], 'py', py[y, x])
