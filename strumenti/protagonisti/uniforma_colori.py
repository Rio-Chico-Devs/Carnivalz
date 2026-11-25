"""Lei uguale in tutte le direzioni, partendo da quella di fronte: stivali, guanti e pantaloncini (il lattice nero)
con i colori della ferma di fronte in tutti i fogli: contorno (6,7,15), pieno (22,37,52), mezzo (49,59,70), luce
(69,79,85). Pelle, capelli e fascia restano quelli dei disegni di Bru. Si puo' rilanciare: i colori vecchi non ci
sono piu' e non cambia niente.
uso: uniforma_colori.py cartella_lei_chibi"""
import os
import sys

import numpy as np
from PIL import Image

LEI = sys.argv[1]
CONTORNO, PIENO, MEZZO, LUCE = (6, 7, 15), (22, 37, 52), (49, 59, 70), (69, 79, 85)
# i lattici dei fogli: le corse (di fronte e di lato, ricalcate dai disegni di Bru) e quelli di spalle
LATTICE = {
    (15, 13, 19): CONTORNO, (32, 35, 47): PIENO, (43, 46, 58): MEZZO,                       # corse
    (11, 8, 16): CONTORNO, (20, 19, 31): PIENO, (31, 32, 44): PIENO, (46, 45, 59): MEZZO,   # di spalle
}
FOGLI = ['davanti_corsa.png', 'dietro_ferma.png', 'dietro_corsa.png', 'lato_corsa.png', 'lato_sinistro_corsa.png']

for f in FOGLI:
    p = os.path.join(LEI, f)
    a = np.asarray(Image.open(p).convert('RGBA')).copy()
    cambiati = 0
    for vecchio, nuovo in LATTICE.items():
        m = np.all(a[..., :3] == vecchio, axis=-1) & (a[..., 3] > 0)
        a[m, :3] = nuovo
        cambiati += int(m.sum())
    if cambiati:
        Image.fromarray(a, 'RGBA').save(p)
    print(f, 'pixel ricolorati', cambiati)
