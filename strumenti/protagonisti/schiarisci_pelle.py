"""La pelle di Lei piu' chiara, abbronzata (Bru: "la pelle della protagonista e' troppo scura, possiamo schiarirla
leggermente?", poi: "schiariamo ancora leggermente la pelle del personaggio, deve sembrare abbronzata non indiana").
Il primo giro alzava la luce di ogni tono di +0.06 (OKLab) con la stessa tinta: restava marrone, perche' quasi meta'
della pelle e' in ombra e le ombre erano rosso-viola spente. Ora la scala e' rifatta in OKLCH: il pieno dorato
(luce 0.755, tinta 64), la luce del naso verso il giallo, le ombre calde color terracotta (tinta 36, l'ombra fonda 20,
ancora verso il rosso-viola come vogliono le regole della tavolozza) piu' vicine al pieno di prima, cosi' si vede
abbronzata e non scura. Le due famiglie della pelle (la ferma e le corse, ricalcate in tempi diversi) restano due,
la corsa un filo sotto come nei disegni; i contorni scuri, la bocca, il cerchio d'oro e il resto non si toccano.
Il bordo scuro del cerchio d'oro sulla fascia e' disegnato con due marroni della pelle: schiariti farebbero un alone
rosato attorno al cerchio, quindi i pezzetti di "pelle" attaccati all'oro (al piu' 12 pixel: la pelle vera e' molto
piu' grande) tengono i colori di partenza.
Cambia sia i colori di partenza sia quelli del primo giro; si puo' rilanciare: dopo non trova piu' niente da cambiare.
uso: schiarisci_pelle.py cartella_lei_chibi"""
import glob
import os
import sys

import numpy as np
from PIL import Image

# tono: (colore di partenza, colore del primo giro) -> colore nuovo
SCALA = {
    # la ferma (e attesa, corda, dorme, jojo)
    'luce (il naso)': ((173, 135, 111), (192, 153, 129), (227, 187, 158)),
    'pieno': ((156, 116, 82), (175, 134, 99), (212, 165, 122)),
    'ombra': ((130, 85, 80), (147, 101, 95), (190, 131, 114)),
    'ombra fonda': ((97, 58, 63), (110, 70, 75), (157, 103, 102)),
    'ombra di spalle': ((117, 82, 79), (132, 96, 93), (179, 125, 113)),
    # le corse
    'corsa: luce (il naso)': ((166, 125, 106), (185, 143, 124), (225, 183, 158)),
    'corsa: pieno': ((150, 107, 78), (169, 125, 95), (207, 158, 118)),
    'corsa: pieno 2': ((150, 108, 79), (169, 126, 96), (207, 159, 119)),
    'corsa: ombra': ((128, 93, 75), (145, 109, 90), (187, 140, 118)),
    'corsa: scura': ((105, 75, 64), (118, 87, 76), (164, 121, 108)),
}
PELLE = {}                      # ogni colore della pelle (di partenza, del primo giro, nuovo) -> (partenza, nuovo)
for partenza, primo, nuovo in SCALA.values():
    for c in (partenza, primo, nuovo):
        PELLE[c] = (partenza, nuovo)
assert len(PELLE) == 3 * len(SCALA)
ORO = {(97, 60, 20), (178, 136, 62), (202, 153, 78), (223, 186, 97), (250, 214, 129)}   # il cerchio d'oro
BORDO_ORO = 12


def pezzi(m):
    """i pezzi (8 vicini) di una maschera: un numero per pezzo, 0 fuori"""
    H, W = m.shape
    lab = np.zeros((H, W), int)
    n = 0
    for y, x in zip(*np.nonzero(m)):
        if lab[y, x]:
            continue
        n += 1
        lab[y, x] = n
        pila = [(y, x)]
        while pila:
            cy, cx = pila.pop()
            for yy in range(max(cy - 1, 0), min(cy + 2, H)):
                for xx in range(max(cx - 1, 0), min(cx + 2, W)):
                    if m[yy, xx] and not lab[yy, xx]:
                        lab[yy, xx] = n
                        pila.append((yy, xx))
    return lab, n


def schiarisci(a):
    """il foglio RGBA con la pelle nuova; quanti pixel cambiano"""
    a = a.copy()
    piena = a[..., 3] > 0
    col = [[tuple(int(v) for v in a[y, x, :3]) for x in range(a.shape[1])] for y in range(a.shape[0])]
    pelle = np.array([[c in PELLE for c in r] for r in col]) & piena
    oro = np.array([[c in ORO for c in r] for r in col]) & piena
    vicino = np.zeros_like(oro)                      # i pixel che toccano l'oro (anche di spigolo)
    H, W = oro.shape
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            vicino[max(dy, 0):H + min(dy, 0), max(dx, 0):W + min(dx, 0)] |= \
                oro[max(-dy, 0):H + min(-dy, 0), max(-dx, 0):W + min(-dx, 0)]
    lab, n = pezzi(pelle)
    bordo = np.zeros_like(pelle)
    for i in range(1, n + 1):
        p = lab == i
        if p.sum() <= BORDO_ORO and (p & vicino).any():
            bordo |= p
    cambiati = 0
    for y, x in zip(*np.nonzero(pelle)):
        partenza, nuovo = PELLE[col[y][x]]
        c = partenza if bordo[y, x] else nuovo
        if c != col[y][x]:
            a[y, x, :3] = c
            cambiati += 1
    return a, cambiati, int(bordo.sum())


if __name__ == '__main__':
    LEI = sys.argv[1]
    for f in sorted(glob.glob(os.path.join(LEI, '*.png'))):
        a, n, b = schiarisci(np.asarray(Image.open(f).convert('RGBA')))
        if n:
            Image.fromarray(a, 'RGBA').save(f)
        print(os.path.basename(f), 'pixel cambiati', n, '- bordo del cerchio', b)
