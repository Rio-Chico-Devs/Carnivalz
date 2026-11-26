"""I colori di Lei uguali in tutte le pose, come la ferma di fronte. Prima il lattice nero (stivali, guanti e
pantaloncini: contorno, pieno, mezzo, luce di fronte nelle corse e nelle viste di spalle). Poi il resto (Bru: "di lato
i colori dei capelli e degli abiti sembrano piu' spenti rispetto a quelli del front e delle animazioni", poi:
"uniformiamo, vogliamo quelli come il front"): le corse, le ferme e le attese di lato e le viste di spalle sono
ricalcate da disegni diversi e avevano ognuna le sue tavolozze: capelli (e top) piu' spenti, la fascia meno accesa,
stelle rosa, occhi e cerchio d'oro un filo diversi. Qui passano tutti ai colori della ferma di fronte:
- i capelli: la rampa di fronte ha 5 toni (scuro, ombra, medio, chiaro, luce). I 6 toni delle corse e i 9 delle
  spalle vanno per ruolo su quelli di fronte (lo scuro sullo scuro, il chiaro piu' usato sul chiaro, la luce sulla
  luce...); i toni in piu' prendono il colore che sta fra i due vicini sulla stessa rampa (in OKLab, secondo la loro
  luce): le sfumature dei disegni restano, i colori sono quelli di fronte;
- il contorno malva delle spalle (fra capelli, collo e vestiti) va sullo scuro dei capelli;
- la fascia: chiaro, ombra e scuro come di fronte;
- le stelle rosa della fascia diventano della luce dei capelli, come di fronte; lo stesso rosa negli occhi era il
  riflesso e va sul riflesso di fronte (i pezzetti rosa che toccano la fascia sono stelle, gli altri riflessi);
- gli occhi (luce dell'iride, pupilla, magenta) e il cerchio d'oro (medio e luce) come di fronte.
I fogli di fronte non cambiano. Si puo' rilanciare: dopo non trova piu' niente da cambiare. Se si rifa' un foglio
con gli script di prima (che usano i colori vecchi), dopo vanno rilanciati schiarisci_pelle.py e questo.
uso: uniforma_colori.py cartella_lei_chibi"""
import glob
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from tavolozza import oklch, rgb  # noqa: E402

# la rampa dei capelli di fronte, dallo scuro alla luce
FRONTE = [(87, 66, 125), (114, 91, 145), (148, 136, 190), (196, 185, 225), (228, 215, 241)]
# le rampe dei capelli delle altre pose (dallo scuro al chiaro) e i toni guida: indice del tono -> indice in FRONTE
CORSE = [(86, 69, 107), (110, 91, 132), (124, 105, 147), (168, 148, 189), (191, 172, 209), (206, 185, 223)]
GUIDE_CORSE = {0: 0, 1: 1, 3: 2, 4: 3, 5: 4}
SPALLE = [(87, 68, 109), (105, 83, 129), (120, 98, 145), (135, 113, 159), (151, 130, 173), (168, 146, 188),
          (181, 161, 201), (188, 168, 206), (200, 180, 215)]
GUIDE_SPALLE = {0: 0, 2: 1, 4: 2, 7: 3, 8: 4}
UNO_A_UNO = {
    # il lattice nero delle corse e delle spalle -> contorno (6,7,15), pieno (22,37,52), mezzo (49,59,70) di fronte
    (15, 13, 19): (6, 7, 15), (32, 35, 47): (22, 37, 52), (43, 46, 58): (49, 59, 70),                     # corse
    (11, 8, 16): (6, 7, 15), (20, 19, 31): (22, 37, 52), (31, 32, 44): (22, 37, 52), (46, 45, 59): (49, 59, 70),
    (228, 193, 215): FRONTE[4],                         # due pixel di luce nei capelli di spalle
    (77, 59, 77): FRONTE[0],                            # il contorno malva delle spalle
    # la fascia (corse e lato; spalle) -> chiaro, ombra, scuro di fronte
    (114, 38, 63): (126, 33, 64), (88, 30, 50): (98, 34, 62), (59, 17, 39): (74, 26, 52),
    (120, 31, 58): (126, 33, 64), (91, 24, 51): (98, 34, 62), (61, 18, 43): (74, 26, 52),
    # gli occhi: luce dell'iride, pupilla, magenta
    (187, 144, 170): (196, 166, 177), (78, 34, 90): (70, 30, 92), (125, 62, 135): (124, 58, 128),
    # il cerchio d'oro: luce e medio
    (223, 186, 97): (250, 214, 129), (178, 136, 62): (202, 153, 78),
    # il nero "notte" della ferma di lato vecchia (lato_ferma.png, la base del corpo per ferma_lato.py): il lattice
    (24, 20, 33): (6, 7, 15), (40, 37, 54): (22, 37, 52), (55, 50, 68): (49, 59, 70), (72, 63, 82): (69, 79, 85),
}
ROSA = (245, 205, 226)                                  # stelle e riflessi delle corse
STELLA, RIFLESSO = FRONTE[4], (251, 217, 213)
FASCE = {(114, 38, 63), (88, 30, 50), (59, 17, 39), (126, 33, 64), (98, 34, 62), (74, 26, 52)}


def _lab(c):
    L, C, h = oklch(c)
    return np.array([L, C * np.cos(np.radians(h)), C * np.sin(np.radians(h))])


def _da_lab(v):
    return rgb(v[0], float(np.hypot(v[1], v[2])), float(np.degrees(np.arctan2(v[2], v[1])) % 360))


def rampa(toni, guide):
    """i toni guida sui colori di fronte; gli altri fra i due vicini, sulla rampa di fronte, secondo la loro luce"""
    luce = [oklch(c)[0] for c in toni]
    m = {}
    for i, c in enumerate(toni):
        if i in guide:
            m[c] = FRONTE[guide[i]]
            continue
        a = max(k for k in guide if k < i)
        b = min(k for k in guide if k > i)
        f = (luce[i] - luce[a]) / (luce[b] - luce[a])
        m[c] = _da_lab(_lab(FRONTE[guide[a]]) * (1 - f) + _lab(FRONTE[guide[b]]) * f)
    return m


COLORI = dict(UNO_A_UNO)
COLORI.update(rampa(CORSE, GUIDE_CORSE))
COLORI.update(rampa(SPALLE, GUIDE_SPALLE))
assert not set(COLORI) & set(COLORI.values()) and ROSA not in COLORI.values()


def uniforma(a):
    """il foglio RGBA coi colori di fronte; quanti pixel cambiano"""
    a = a.copy()
    piena = a[..., 3] > 0
    rosa = np.all(a[..., :3] == ROSA, -1) & piena
    fascia = np.zeros_like(rosa)
    for c in FASCE:
        fascia |= np.all(a[..., :3] == c, -1) & piena
    H, W = rosa.shape
    cambiati = 0
    visti = np.zeros_like(rosa)
    for y, x in zip(*np.nonzero(rosa)):                  # ogni pezzetto rosa (4 vicini): stella o riflesso
        if visti[y, x]:
            continue
        pezzo, pila = [], [(y, x)]
        visti[y, x] = True
        while pila:
            cy, cx = pila.pop()
            pezzo.append((cy, cx))
            for yy, xx in ((cy, cx + 1), (cy + 1, cx), (cy, cx - 1), (cy - 1, cx)):
                if 0 <= yy < H and 0 <= xx < W and rosa[yy, xx] and not visti[yy, xx]:
                    visti[yy, xx] = True
                    pila.append((yy, xx))
        stella = any(fascia[yy, xx] for cy, cx in pezzo
                     for yy, xx in ((cy, cx + 1), (cy + 1, cx), (cy, cx - 1), (cy - 1, cx)) if 0 <= yy < H and 0 <= xx < W)
        for cy, cx in pezzo:
            a[cy, cx, :3] = STELLA if stella else RIFLESSO
            cambiati += 1
    prima = a[..., :3].copy()
    for vecchio, nuovo in COLORI.items():
        k = np.all(prima == vecchio, -1) & piena
        a[k, :3] = nuovo
        cambiati += int(k.sum())
    return a, cambiati


if __name__ == '__main__':
    for f in sorted(glob.glob(os.path.join(sys.argv[1], '*.png'))):
        a, n = uniforma(np.asarray(Image.open(f).convert('RGBA')))
        if n:
            Image.fromarray(a, 'RGBA').save(f)
        print(os.path.basename(f), 'pixel cambiati', n)
