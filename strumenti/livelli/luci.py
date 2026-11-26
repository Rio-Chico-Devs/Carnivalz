"""Le luci e le ombre che si muovono (Bru: "un'animazione di luci e ombre che dia dinamicita' alla scena, tipo ombre di
nuvole che passano"). Qui le due tessere che la pagina fa scorrere col vento sopra tutta la scena:
- nuvole_ombra.png, da moltiplicare: le ombre delle nuvole, macchie larghe allungate nel verso del vento; dentro
  scuriscono di un quarto tirando al viola (le ombre girano verso il viola, come nelle tavolozze di Bru), sul bordo
  meno; il bordo e' a retino (ordinato, 4x4) come le ombre degli alberi nella mappa;
- nuvole_sole.png, da sommare a schermo: dove il cielo e' piu' sgombro il sole scalda un poco la luce (giallo).
Sono tessere che si ripetono senza giunture (il rumore e' periodico), grandi 768: piu' della mappa in altezza, cosi'
la ripetizione non si vede. Le macchie di sole sotto gli alberi le fa la pagina (piccole, che si accendono e
ondeggiano).
uso: luci.py cartella_terreni [anteprima.png]"""
import os
import sys

import numpy as np
from PIL import Image

T = 768
OMBRA = [(255, 255, 255), (222, 216, 238), (190, 182, 222)]     # niente, bordo, dentro (da moltiplicare)
SOLE = [(0, 0, 0), (12, 10, 3), (28, 23, 7)]                    # niente, bordo, pieno (da sommare a schermo)
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0


def periodico(nx, ny, seme):
    # rumore liscio che si ripete: la griglia a caso ripetuta 3x3, ingrandita, e si tiene il pezzo di mezzo
    g = np.random.default_rng(seme).random((ny, nx))
    big = np.tile(g, (3, 3))
    im = Image.fromarray((big * 255).astype(np.uint8)).resize((3 * T, 3 * T), Image.BICUBIC)
    return np.asarray(im, float)[T:2 * T, T:2 * T] / 255.0


def tessere(seme=5):
    # le nuvole allungate in orizzontale (il vento soffia quasi di traverso): celle piu' larghe che alte
    F = periodico(4, 7, seme) * 0.6 + periodico(9, 15, seme + 1) * 0.3 + periodico(19, 31, seme + 2) * 0.1
    yy, xx = np.mgrid[0:T, 0:T]
    d = (BAYER[yy % 4, xx % 4] - 0.5) * 0.035            # il retino sui bordi
    q_bordo, q_dentro = np.quantile(F, [0.70, 0.81])
    q_sole, q_pieno = np.quantile(F, [0.30, 0.16])
    ombra = np.zeros((T, T, 3), np.uint8); ombra[:] = OMBRA[0]
    ombra[F + d >= q_bordo] = OMBRA[1]
    ombra[F + d >= q_dentro] = OMBRA[2]
    sole = np.zeros((T, T, 3), np.uint8); sole[:] = SOLE[0]
    sole[F + d <= q_sole] = SOLE[1]
    sole[F + d <= q_pieno] = SOLE[2]
    return ombra, sole


if __name__ == '__main__':
    TER = sys.argv[1]
    ombra, sole = tessere()
    Image.fromarray(ombra).save(os.path.join(TER, 'nuvole_ombra.png'), optimize=True)
    Image.fromarray(sole).save(os.path.join(TER, 'nuvole_sole.png'), optimize=True)
    if len(sys.argv) > 2:
        # anteprima: la tessera ripetuta 2x2 sopra un prato piatto, per vedere le forme e le giunture
        prato = np.zeros((2 * T, 2 * T, 3), float); prato[:] = (161, 220, 110)
        o = np.tile(ombra, (2, 2, 1)).astype(float) / 255.0
        s = np.tile(sole, (2, 2, 1)).astype(float)
        a = prato * o
        a = 255 - (255 - a) * (255 - s) / 255
        Image.fromarray(a.astype(np.uint8)).resize((T, T), Image.NEAREST).save(sys.argv[2])
    print('tessere', T, 'x', T)
