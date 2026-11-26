"""Lei ferma di lato, uguale alla corsa di lato: la testa (con la fascia e le stelle) e la treccia davanti al collo
sono quelle della corsa, cosi' fermandosi e ripartendo non cambia niente; il corpo e' quello della ferma approvata
(lato_ferma.png: collo, seno, braccio lungo il fianco, pantaloncini), col braccio accorciato perche' la mano finisca
coi pantaloncini e la coscia si veda intera; la gamba e' uno stivale disegnato come quelli di fronte:
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
LATTICE = {(6, 7, 15), (22, 37, 52), (49, 59, 70), (69, 79, 85)}
COL = {'l': (6, 7, 15), 'h': (22, 37, 52), 'n': (49, 59, 70), 'm': (69, 79, 85)}
CAPELLI_VECCHI = {(87, 66, 125), (114, 91, 145), (148, 136, 190), (196, 185, 225), (228, 215, 241)}
PELLE, PELLE_OMBRA, PELLE_SCURA = (187, 140, 118), (164, 121, 108), (85, 55, 39)   # i colori del collo della corsa

# le gambe verso sinistra, dalla riga 68 (bordo dello stivale) alla 80 (suole), da x 11. Bru: niente polpaccio
# grosso e niente gambe inclinate in avanti: le gambe scendono verso il baricentro (x 18 circa: testa e corpo) e i
# piedi ci stanno sotto. Una gamba sola (Bru: "se togli la gamba di dietro e' perfetta"): luce sul davanti,
# ginocchio lucido, caviglia sottile, piede col tacco; il tacco sta sotto la caviglia, non sporge dietro (Bru)
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
          '...lnhhl....',
          '..lnhlll....',
          '.lll..ll....']
# la coscia intera sotto i pantaloncini (righe 65-67, da x 11) fino al bordo dello stivale: la mano ora finisce
# all'altezza dei pantaloncini, come di fronte, e la coscia non resta mezza coperta
COSCE = ['.dceeeecd', '.dceeeecd', '.dceeeeed']
PELLI = {'d': (157, 103, 102), 'c': (190, 131, 114), 'e': (212, 165, 122)}
# la treccia: quella della corsa, che scende davanti al collo fino al petto (Bru: "hai rimosso le trecce?")
CAPELLI_CORSA = {(86, 69, 107), (110, 91, 132), (124, 105, 147), (168, 148, 189), (191, 172, 209), (206, 185, 223)}


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
    # il braccio piu' corto di 3 righe: via un pezzo dell'avambraccio (righe 55-57), il resto sale; la mano
    # finisce alla riga 64, insieme ai pantaloncini
    braccio = np.zeros((81, 40), bool)
    for y in range(51, 68):
        for x in range(14, 21):
            if out[y, x, 3] and tuple(out[y, x, :3]) in LATTICE and (x >= 16 or y >= 61):
                braccio[y, x] = True
    pezzi = out.copy()
    out[braccio] = 0
    for y in range(51, 68):
        if 55 <= y <= 57:
            continue
        d = y if y < 55 else y - 3
        for x in range(14, 21):
            if braccio[y, x]:
                out[d, x] = pezzi[y, x]
    for i, r in enumerate(COSCE):
        for j, ch in enumerate(r):
            y, x = 65 + i, 11 + j
            if ch != '.':
                out[y, x, :3] = PELLI[ch]; out[y, x, 3] = 255
    gambe(out, VICINA, 12, 68)
    # la testa sopra il collo (i capelli dietro cadono sulla schiena)
    m = testa_sx[..., 3] > 0
    out[m] = testa_sx[m]
    # la treccia della corsa (righe 49-55 del fotogramma K, alzate come la testa) davanti al collo e al petto
    base = sx_corsa[:, K * 40:(K + 1) * 40]
    for y in range(49, 56):
        for x in range(0, 17):
            if base[y, x, 3] and tuple(base[y, x, :3]) in CAPELLI_CORSA:
                out[y - 2, x] = base[y, x]
    # Bru: via la colonna davanti a vita, pantaloncini e coscia (righe 60-65), che la faceva sembrare grassa; il
    # contorno nero dei pantaloncini passa al pixel dopo
    out[60, 11] = 0
    for y in range(61, 65):
        out[y, 10] = 0
        out[y, 11, :3] = (6, 7, 15); out[y, 11, 3] = 255
    out[65:68, :12] = 0                             # anche la coscia vecchia davanti (x 10-11)
    # i buchi fra treccia e collo e fra pantaloncini e mano
    for y, x, c in ((47, 14, (86, 69, 107)), (49, 15, PELLE_OMBRA), (50, 15, PELLE_OMBRA), (64, 14, (6, 7, 15))):
        if out[y, x, 3] == 0:
            out[y, x, :3] = c; out[y, x, 3] = 255
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
