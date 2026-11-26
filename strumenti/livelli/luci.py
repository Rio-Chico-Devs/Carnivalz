"""Le ombre delle nuvole che passano (Bru: "un'animazione di luci e ombre che dia dinamicita' alla scena, tipo ombre di
nuvole che passano"; poi: "le ombre sembrano fumo").
Prima erano fatte col rumore a piu' strati e il bordo a retino in due toni: macchie sfilacciate, sfumate come nebbia.
Ora ogni nuvola e' una sagoma netta e tonda: un mucchio di cerchi dentro un ovale allungato quasi nel verso del vento
(grandi nel mezzo, la cupola; piccoli sul giro, le gobbe del bordo), un solo tono, il bordo a scaletta pulito del pixel
art, niente retino; nuvole grandi, medie e piccole, e fra l'una e l'altra tanto sereno.
nuvole_ombra.png e' la tessera da moltiplicare sopra tutta la scena: dentro le nuvole il colore scende un poco tirando
al blu (toglie piu' rosso che blu: il prato all'ombra va verso il verde-blu, come nelle rampe di Bru; col viola di
prima diventava color oliva), fuori e' bianca (non cambia niente). Si ripete senza giunture (i cerchi fanno il giro
della tessera), grande 768: piu' della mappa in altezza.
uso: luci.py cartella_terreni [anteprima.png [mappa.png]]"""
import os
import sys

import numpy as np
from PIL import Image

T = 768
OMBRA = (192, 210, 250)            # il tono dentro le nuvole (da moltiplicare): toglie piu' rosso, quasi niente blu
VENTO = (14, 5)                    # lo stesso della pagina: le nuvole sono allungate nel verso del vento
MISURE = [340, 300, 250, 200, 150, 110]   # quanto e' lunga ogni nuvola: grandi, medie, piccole


def _lontano(c, centri, d):
    return all(min(abs(c[0] - e[0]), T - abs(c[0] - e[0])) ** 2 +
               min(abs(c[1] - e[1]), T - abs(c[1] - e[1])) ** 2 > d * d for e in centri)


def _cerchi(rng):
    # le nuvole: per ognuna un mucchio di cerchi dentro un ovale allungato quasi nel verso del vento, grandi nel mezzo
    # (la cupola) e piccoli sul giro (le gobbe tonde del bordo)
    a0 = np.arctan2(VENTO[1], VENTO[0]) * 0.5
    centri = []
    for L in MISURE:
        for _ in range(400):
            c = rng.uniform(0, T, 2)
            if _lontano(c, [e[:2] for e in centri], 0.5 * (L + max([e[2] for e in centri], default=0)) + 30):
                break
        centri.append((c[0], c[1], L))
    cerchi = []
    for cx, cy, L in centri:
        a = a0 + rng.uniform(-0.14, 0.14)
        ux, uy = np.cos(a), np.sin(a)          # lungo
        nx, ny = -uy, ux                        # di traverso
        Wd = L * rng.uniform(0.38, 0.48)        # larga
        rmax = 0.46 * Wd
        n = 6 + int(L / 22)
        for i in range(n):
            # dentro l'ovale (0.8 della lunghezza, 0.55 della larghezza): piu' sei lontano dal centro, piu' piccolo
            while True:
                t, s = rng.uniform(-1, 1, 2)
                if t * t + s * s <= 1:
                    break
            if i == 0:
                t = s = 0.0
            rho2 = t * t + s * s
            r = max(5.0, rmax * (1 - 0.55 * rho2) * rng.uniform(0.72, 1.0))
            px, py = t * 0.5 * L * 0.8, s * 0.5 * Wd * 0.55
            cerchi.append((cx + ux * px + nx * py, cy + uy * px + ny * py, r))
    return cerchi


def _liscia(m, r):
    # via le punte e le tacche di un pixel dove i cerchi si toccano: chiude e riapre col disco di raggio r
    yy, xx = np.mgrid[-r:r + 1, -r:r + 1]
    disco = [(dy, dx) for dy, dx in zip(yy.ravel(), xx.ravel()) if dy * dy + dx * dx <= r * r + r]

    def allarga(a):
        o = np.zeros_like(a)
        for dy, dx in disco:
            o |= np.roll(np.roll(a, dy, 0), dx, 1)
        return o

    def stringi(a):
        o = np.ones_like(a)
        for dy, dx in disco:
            o &= np.roll(np.roll(a, dy, 0), dx, 1)
        return o
    return allarga(stringi(stringi(allarga(m))))


def tessera(seme=7):
    rng = np.random.default_rng(seme)
    yy, xx = np.mgrid[0:T, 0:T].astype(float)
    m = np.zeros((T, T), bool)
    for cx, cy, r in _cerchi(rng):
        dx = (xx - cx + T / 2) % T - T / 2      # il giro della tessera: niente giunture
        dy = (yy - cy + T / 2) % T - T / 2
        m |= dx * dx + dy * dy <= r * r
    m = _liscia(m, 2)
    out = np.full((T, T, 3), 255, np.uint8)
    out[m] = OMBRA
    return out, m


if __name__ == '__main__':
    TER = sys.argv[1]
    ombra, m = tessera()
    Image.fromarray(ombra).save(os.path.join(TER, 'nuvole_ombra.png'), optimize=True)
    if len(sys.argv) > 2:
        # anteprima: la tessera sopra la mappa (o un prato piatto), per vedere le forme e le giunture
        if len(sys.argv) > 3:
            sotto = np.asarray(Image.open(sys.argv[3]).convert('RGB')).astype(float)
        else:
            sotto = np.zeros((2 * T, 2 * T, 3)); sotto[:] = (161, 220, 110)
        h, w = sotto.shape[:2]
        o = np.tile(ombra, (h // T + 1, w // T + 1, 1))[:h, :w].astype(float) / 255.0
        Image.fromarray((sotto * o).astype(np.uint8)).save(sys.argv[2])
    print('tessera', T, 'x', T, 'nuvole %.0f%%' % (100 * m.mean()))
