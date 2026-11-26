"""La pelle di Lei un poco piu' chiara (Bru: "la pelle della protagonista e' troppo scura, possiamo schiarirla
leggermente?"). Ogni tono della pelle sale di luce (OKLab: +0.06 le luci e il pieno, +0.055 le ombre, +0.045-0.05 le
ombre fonde, cosi' il volume resta) con la stessa tinta e la stessa intensita': resta abbronzata, solo piu' chiara.
Le due famiglie di colori della pelle (quella della ferma e quella delle corse, ricalcate dai disegni di Bru in tempi
diversi) cambiano ognuna coi suoi; i contorni scuri, la bocca, il cerchio d'oro e il resto non si toccano.
Si puo' rilanciare: i colori vecchi non ci sono piu' e non cambia niente.
uso: schiarisci_pelle.py cartella_lei_chibi"""
import glob
import os
import sys

import numpy as np
from PIL import Image

PELLE = {
    # la ferma (e attesa, corda, dorme, jojo)
    (173, 135, 111): (192, 153, 129),    # luce (il naso)
    (156, 116, 82): (175, 134, 99),      # pieno
    (130, 85, 80): (147, 101, 95),       # ombra
    (97, 58, 63): (110, 70, 75),         # ombra fonda
    (117, 82, 79): (132, 96, 93),        # ombra (di spalle)
    # le corse
    (166, 125, 106): (185, 143, 124),    # luce (il naso)
    (150, 107, 78): (169, 125, 95),      # pieno
    (150, 108, 79): (169, 126, 96),      # pieno
    (128, 93, 75): (145, 109, 90),       # ombra
    (105, 75, 64): (118, 87, 76),        # scura
}

if __name__ == '__main__':
    LEI = sys.argv[1]
    fogli = sorted(glob.glob(os.path.join(LEI, '*.png')))
    # i colori nuovi non devono esserci gia' (si confonderebbero con altro)
    for f in fogli:
        a = np.asarray(Image.open(f).convert('RGBA'))
        presenti = {tuple(int(v) for v in p) for p in a[a[..., 3] > 0][:, :3]}
        doppi = presenti & set(PELLE.values()) - set()
        vecchi = presenti & set(PELLE)
        assert not (doppi and vecchi), (f, doppi)
    for f in fogli:
        a = np.asarray(Image.open(f).convert('RGBA')).copy()
        n = 0
        for vecchio, nuovo in PELLE.items():
            m = np.all(a[..., :3] == vecchio, -1) & (a[..., 3] > 0)
            a[m, :3] = nuovo
            n += int(m.sum())
        if n:
            Image.fromarray(a, 'RGBA').save(f)
        print(os.path.basename(f), 'pixel di pelle schiariti', n)
