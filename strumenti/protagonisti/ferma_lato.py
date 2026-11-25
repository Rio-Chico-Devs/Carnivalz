"""Lei ferma di lato, uguale alla corsa di lato: la testa (con la fascia e le stelle) e' quella della corsa, cosi'
fermandosi e ripartendo non cambia niente sopra il collo; il corpo e' quello della ferma approvata (lato_ferma.png:
collo, busto, braccio lungo il fianco, pantaloncini) e le gambe sono stivali disegnati come quelli di fronte:
contorno nero, luce sul davanti, ginocchio lucido, caviglia sottile, piede piccolo col tacco.
Verso sinistra: testa della corsa verso sinistra (fotogramma 1, alzata perche' la fascia stia alla riga 24, come la
ferma di fronte rispetto ai piedi). Verso destra: la stessa specchiata, con la testa della corsa verso destra (la fascia
del lato destro, col cerchio d'oro). Fogli 40x81 come le corse, suole alla riga 80.
uso: ferma_lato.py cartella_lei_chibi [anteprima.png]"""
import os
import sys

import numpy as np
from PIL import Image

LEI = sys.argv[1]
K = 1                        # il fotogramma della corsa da cui si prende la testa
FASCIA = (114, 38, 63)
NOTTE = {(24, 20, 33): (6, 7, 15), (40, 37, 54): (22, 37, 52), (55, 50, 68): (49, 59, 70), (72, 63, 82): (69, 79, 85)}
COL = {'l': (6, 7, 15), 'h': (22, 37, 52), 'n': (49, 59, 70), 'm': (69, 79, 85)}
CAPELLI_VECCHI = {(87, 66, 125), (114, 91, 145), (148, 136, 190), (196, 185, 225), (228, 215, 241)}
PELLE, PELLE_OMBRA, PELLE_SCURA = (128, 93, 75), (105, 75, 64), (85, 55, 39)   # i colori del collo della corsa

# le gambe verso sinistra, dalla riga 68 (bordo dello stivale) alla 80 (suole), da x 8: la gamba vicina con la
# luce sul davanti e il ginocchio lucido; quella lontana due pixel piu' indietro, scura, si vede solo dietro
VICINA = ['...llllll...',
          '...lnhhhl...',
          '..lnmhhhl...',
          '..lnhhhhhl..',
          '...lnhhhhl..',
          '...lnhhhl...',
          '...lnhhl....',
          '...lnhhl....',
          '...lnhl.....',
          '..lnhhl.....',
          '.lnhhhll....',
          'lnhhl.ll....',
          'lll...ll....']
LONTANA = [r.replace('n', 'h').replace('m', 'h') for r in VICINA]


def leggi(nome):
    return np.asarray(Image.open(os.path.join(LEI, nome)).convert('RGBA')).copy()


def testa(foglio, viso_a_sinistra):
    # la testa della corsa nel fotogramma K (di passaggio: le braccia sono sotto il mento), fino alla riga 48,
    # piu' l'ultima riga del mento (la 49, solo dalla parte del viso)
    base = foglio[:, K * 40:(K + 1) * 40]
    m = np.all(base[..., :3] == FASCIA, axis=-1) & (base[..., 3] > 0)
    cima = int(np.nonzero(m.any(axis=1))[0].min())
    out = np.zeros_like(base)
    out[:49] = base[:49]
    viso = slice(0, 14) if viso_a_sinistra else slice(26, 40)
    out[49, viso] = base[49, viso]
    return out, cima


def gambe(out, righe, x0, y0, colori=COL):
    for i, r in enumerate(righe):
        for j, ch in enumerate(r):
            if ch != '.':
                out[y0 + i, x0 + j, :3] = colori[ch]; out[y0 + i, x0 + j, 3] = 255


def sinistra(testa_sx, cima):
    out = np.zeros((81, 40, 4), np.uint8)
    # il corpo della ferma approvata, specchiato, dal collarino (riga 42) alle cosce (riga 61), col lattice di fronte
    corpo = leggi('lato_ferma.png')[:, ::-1].copy()
    for v, n in NOTTE.items():
        corpo[np.all(corpo[..., :3] == v, axis=-1) & (corpo[..., 3] > 0), :3] = n
    # via la treccia della testa vecchia (righe 42-44: capelli davanti e dietro al collo)
    for y in range(42, 45):
        for x in range(40):
            if tuple(corpo[y, x, :3]) in CAPELLI_VECCHI:
                corpo[y, x] = 0
    dy, dx = 48 - 42, -1                # con la fascia alla riga 24 il collo della testa arriva alla 47
    for y in range(42, 62):
        for x in range(1, 40):
            if corpo[y, x, 3] > 0:
                out[y + dy, x + dx] = corpo[y, x]
    # il collo sotto il mento, fino al collarino
    for x, c in ((15, PELLE_SCURA), (16, PELLE), (17, PELLE), (18, PELLE), (19, PELLE_OMBRA)):
        out[47, x, :3] = c; out[47, x, 3] = 255
    gambe(out, LONTANA, 9, 68)
    gambe(out, VICINA, 7, 68)
    # la testa sopra il collo (i capelli dietro cadono sulla schiena)
    m = testa_sx[..., 3] > 0
    out[m] = testa_sx[m]
    return out


sx_corsa, dx_corsa = leggi('lato_sinistro_corsa.png'), leggi('lato_corsa.png')
t_sx, c_sx = testa(sx_corsa, True)
t_dx, c_dx = testa(dx_corsa, False)
# la testa allineata con la fascia alla riga 24
def alza(t, c):
    d = c - 24
    o = np.zeros_like(t)
    if d >= 0:
        o[:81 - d] = t[d:]
    else:
        o[-d:] = t[:81 + d]
    return o
t_sx, t_dx = alza(t_sx, c_sx), alza(t_dx, c_dx)
fsx = sinistra(t_sx, 24)
fdx = fsx[:, ::-1].copy()
# verso destra: tolta la testa specchiata, va la testa della corsa verso destra
specchio = t_sx[:, ::-1]
fdx[specchio[..., 3] > 0] = 0
m = t_dx[..., 3] > 0
fdx[m] = t_dx[m]
Image.fromarray(fsx, 'RGBA').save(os.path.join(LEI, 'lato_sinistro_ferma.png'))
Image.fromarray(fdx, 'RGBA').save(os.path.join(LEI, 'lato_destro_ferma.png'))
print('fascia della testa presa alla riga', c_sx, c_dx, '-> 24')

if len(sys.argv) > 2:
    # anteprima: corsa (fotogramma K) | ferma nuova | ferma vecchia, verso sinistra e verso destra, x8
    vecchia = leggi('lato_ferma.png')
    pezzi = [sx_corsa[:, K * 40:(K + 1) * 40], fsx, None, dx_corsa[:, K * 40:(K + 1) * 40], fdx, vecchia]
    z = 6
    tela = Image.new('RGB', (6 * 42 * z, 82 * z), (60, 96, 62))
    for i, p in enumerate(pezzi):
        if p is None:
            continue
        im = Image.fromarray(p, 'RGBA')
        a = p[..., 3] > 0
        suola = int(np.nonzero(a.any(axis=1))[0].max())
        t = Image.new('RGBA', (42, 82), (0, 0, 0, 0))
        t.paste(im, (1, 80 - suola), im)
        t = t.resize((42 * z, 82 * z), Image.NEAREST)
        tela.paste(t, (i * 42 * z, 0), t)
    tela.save(sys.argv[2])
