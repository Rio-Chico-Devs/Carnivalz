"""Lei ferma di lato, uguale alla corsa di lato. Dalla corsa (fotogramma 1, di passaggio) vengono la testa con la
fascia e le stelle, la treccia che scende davanti al collo, il collarino, il collo e la spalla: fermandosi e
ripartendo non cambia niente. Sotto, disegnati sui colori della corsa: il corsetto, la pancia, la cintura, i
pantaloncini, il braccio col guanto che scende lungo il fianco e la coscia; la gamba e' uno stivale come quelli di
fronte (contorno nero, luce sul davanti, ginocchio lucido, caviglia sottile, piede piccolo col tacco), dritto sotto
il baricentro. Le misure del busto sono quelle di fronte: dal collarino all'inguine ~18 righe, gambe 13.
Verso sinistra la testa e' alzata perche' la fascia stia alla riga 24 (come di fronte rispetto ai piedi); verso
destra la stessa specchiata, con la testa della corsa verso destra (la fascia del lato destro, col cerchio d'oro).
Fogli 40x81 come le corse, suole alla riga 80.
uso: ferma_lato.py cartella_lei_chibi [anteprima.png]"""
import os
import sys

import numpy as np
from PIL import Image

LEI = sys.argv[1]
K = 1                        # il fotogramma della corsa da cui si prendono testa, treccia e collo
FASCIA = (114, 38, 63)
LATTICE = {(6, 7, 15), (22, 37, 52), (49, 59, 70)}
TINTE = {'l': (6, 7, 15), 'h': (22, 37, 52), 'n': (49, 59, 70), 'm': (69, 79, 85),               # lattice
         'A': (86, 69, 107), 'F': (110, 91, 132), 'E': (124, 105, 147), 'B': (168, 148, 189),   # corsetto
         'D': (191, 172, 209),
         'O': (150, 107, 78), 'N': (128, 93, 75), 'S': (105, 75, 64), 'Q': (85, 55, 39)}         # pelle

# dalla riga 53 alla 67, da x 10 (verso sinistra): il corsetto col seno davanti, la pancia (61), la cintura (62-63),
# i pantaloncini (64-65), la coscia (66-67); il braccio col guanto lungo il fianco (x 17-22) fino alla mano (63-66);
# dietro il braccio si vede un pixel della schiena
BUSTO = ['..BBBENSSNSSQ..',
         '.lBDBEFlhhnhl..',
         '.lBBEEFlhhnhlA.',
         '.lEBEFAlhhnhlA.',
         '.lEEFFAlhhnhlA.',
         '..lEFFAlhhnhlA.',
         '..lFFAAlhhnhlA.',
         '...lAAAlhhnhlA.',
         '...QOONlhhnhlS.',
         '...AFFAlhhnhlA.',
         '...AEFAlhnhhhl.',
         '..lhnhhlhnhhhl.',
         '..lnhhhlhhnhhl.',
         '...QOOONllllll.',
         '...QOOOONS.....']
# la gamba, dalla riga 68 (bordo dello stivale) alla 80 (suole), da x 12. Bru: niente polpaccio grosso, niente
# gamba inclinata, i piedi sotto il baricentro (x 18 circa), una gamba sola
VICINA = ['.lllllll....',
          '.lnhhhhl....',
          '.lmnhhhl....',
          '..lnhhhl....',
          '..lnhhhl....',
          '..lnhhhl....',
          '...lnhhl....',
          '...lnhhl....',
          '....lnhl....',
          '....lnhl....',
          '...lnhhhl...',
          '..lnhhl.ll..',
          '..lll...ll..']


def leggi(nome):
    return np.asarray(Image.open(os.path.join(LEI, nome)).convert('RGBA')).copy()


def testa(foglio, viso_a_sinistra, fino_a):
    # dal fotogramma K: tutto fino alla riga fino_a (testa, treccia, collarino, collo, spalla)
    base = foglio[:, K * 40:(K + 1) * 40]
    m = np.all(base[..., :3] == FASCIA, axis=-1) & (base[..., 3] > 0)
    cima = int(np.nonzero(m.any(axis=1))[0].min())
    out = np.zeros_like(base)
    out[:fino_a + 1] = base[:fino_a + 1]
    # nelle righe 49-50 della corsa ci sono pezzi di guanto dell'altro braccio: davanti alla treccia diventano
    # capelli, sul collo pelle, dietro la nuca si tolgono
    for y in (49, 50):
        for x in range(40):
            xs = x if viso_a_sinistra else 39 - x
            if out[y, x, 3] and tuple(out[y, x, :3]) in LATTICE:
                if xs >= 23:
                    out[y, x] = 0
                elif xs <= 15:
                    out[y, x, :3] = TINTE['A']
                else:
                    out[y, x, :3] = TINTE['S' if (xs + y) % 2 else 'N']
    d = cima - 24                                     # la fascia alla riga 24
    o = np.zeros_like(out)
    o[:81 - d] = out[d:]
    return o


def disegna(out, righe, x0, y0):
    for i, r in enumerate(righe):
        for j, ch in enumerate(r):
            if ch != '.':
                out[y0 + i, x0 + j, :3] = TINTE[ch]; out[y0 + i, x0 + j, 3] = 255


sx_corsa, dx_corsa = leggi('lato_sinistro_corsa.png'), leggi('lato_corsa.png')
fsx = testa(sx_corsa, True, 54)                       # righe 0-52 dopo l'alzata
disegna(fsx, BUSTO, 10, 53)
disegna(fsx, VICINA, 12, 68)
# verso destra: la stessa specchiata, con la testa (fino alla riga 46) della corsa verso destra
fdx = fsx[:, ::-1].copy()
tdx = testa(dx_corsa, False, 54)
fdx[:47] = tdx[:47]
Image.fromarray(fsx, 'RGBA').save(os.path.join(LEI, 'lato_sinistro_ferma.png'))
Image.fromarray(fdx, 'RGBA').save(os.path.join(LEI, 'lato_destro_ferma.png'))
op = fsx[..., 3] > 0
Y, X = np.mgrid[0:81, 0:40]
print('baricentro sopra le gambe x %.1f, piede x %.1f' % (X[op & (Y < 68)].mean(), X[op & (Y >= 78)].mean()))

if len(sys.argv) > 2:
    # anteprima: corsa (fotogramma K) | ferma, verso sinistra e verso destra, x6
    pezzi = [sx_corsa[:, K * 40:(K + 1) * 40], fsx, dx_corsa[:, K * 40:(K + 1) * 40], fdx]
    z = 6
    tela = Image.new('RGB', (4 * 42 * z, 82 * z), (60, 96, 62))
    for i, p in enumerate(pezzi):
        im = Image.fromarray(p, 'RGBA')
        a = p[..., 3] > 0
        suola = int(np.nonzero(a.any(axis=1))[0].max())
        t = Image.new('RGBA', (42, 82), (0, 0, 0, 0))
        t.paste(im, (1, 80 - suola), im)
        t = t.resize((42 * z, 82 * z), Image.NEAREST)
        tela.paste(t, (i * 42 * z, 0), t)
    tela.save(sys.argv[2])
