"""I fiori del prato che si muovono col vento (Bru: "Puoi fare in modo che i fiori si muovano come mossi dal vento?
Puoi anche farli meglio? Non seguire per forza il mio esempio").
Prima i fiori erano dentro la mappa: quadratini piatti visti da sopra (quattro petali agli angoli e il cuore giallo),
senza gambo ne' ombra. Ora sono piantine in piedi viste di tre quarti, come gli alberi: il gambo con una fogliolina,
la corolla chiara in alto a sinistra e in ombra in basso a destra (le ombre girano verso il blu-viola, le luci verso il
giallo, come nelle tavolozze di Bru), un'ombrina dove toccano terra. Tre specie di tre forme, a macchie come nei
prati veri: le margherite a stella (le piu', il fiore di Bru), i ranuncoli a coppa gialla lucida, le spighe viola della
salvia; grandi e piccole.
Ogni fiore ha sette pose: piegato di -3..+3 pixel (la corolla si sposta, il gambo si curva, piu' in alto che in basso;
piegato del tutto la corolla scende). La pagina sceglie la posa col vento che passa a ondate e quando lei ci passa
vicino (si scostano dai piedi).
modulo: fogli() -> (atlante RGBA, dati); uso: fiori.py cartella_terreni [anteprima.png]"""
import json
import os
import sys

import numpy as np
from PIL import Image

# i colori: il petalo e il cuore di Bru; le ombre del petalo verso il lilla; i ranuncoli dalla rampa dell'oro, la
# salvia da quella del viola (tavolozza.py: rgb(L, C, h) con l'ombra a h 290 e la luce verso il giallo)
COLORI = {
    'a': (252, 255, 232), 'b': (221, 219, 241), 'c': (189, 185, 217),           # petalo: luce, ombra, ombra fonda
    'C': (246, 228, 146), 'D': (232, 191, 93),                                  # il cuore della margherita
    'y': (254, 241, 161), 'Y': (245, 199, 97), 'O': (216, 148, 77), 'o': (163, 106, 86),   # ranuncolo
    'u': (236, 193, 231), 'v': (198, 167, 235), 'V': (147, 114, 200), 'w': (94, 81, 151),  # salvia
    'g': (89, 160, 116), 'G': (74, 109, 111),                                   # gambo e foglie (medio, scuro)
    's': (89, 160, 116),                                                        # l'ombrina per terra (medio)
}
# le specie: la corolla (righe dall'alto), la colonna della corolla dove attacca il gambo, quanto e' alto il gambo,
# le foglie (altezza dal piede, lato -1 sinistra / 1 destra)
SPECIE = {
    # la margherita: la stella di petali attorno al cuore giallo (2x2 col suo scuro), i petali di sotto in ombra
    'margherita': dict(corolla=['..a.a..', '.aaaab.', 'aaCDbbb', '.bDDcb.', '..b.c..'], attacco=3, gambo=5,
                       foglie=[(1, -1), (3, 1)]),
    'margheritina': dict(corolla=['.a.a.', 'aaCDb', '.bDc.', '..c..'], attacco=2, gambo=4, foglie=[(1, -1)]),
    # il ranuncolo: la coppa gialla lucida (il puntino di luce in alto a sinistra), l'arancio solo sotto a destra
    'ranuncolo': dict(corolla=['.y.Y.', 'yaYYO', '.YYO.', '..o..'], attacco=2, gambo=5, foglie=[(1, -1), (3, 1)]),
    'ranuncolino': dict(corolla=['yaY', 'YYO', '.o.'], attacco=1, gambo=4, foglie=[(1, 1)]),
    # la salvia dei prati: la spiga viola di fiorellini alterni, la punta chiara (rosata, la luce gira verso il giallo)
    'salvia': dict(corolla=['.u.', 'uv.', '.Vv', 'vV.', '.Vw', 'w..'], attacco=1, gambo=4, foglie=[(1, -1), (2, 1)]),
    'salvietta': dict(corolla=['.u.', 'vV.', '.Vw', '.w.'], attacco=1, gambo=3, foglie=[(1, 1)]),
}
PIEGHE = list(range(-3, 4))
FW, FH = 17, 16                          # il fotogramma; il piede del fiore alla colonna PX, riga PY
PX, PY = 8, 14


def posa(sp, piega):
    """Un fotogramma RGBA: il fiore piegato di 'piega' pixel (positivo: verso destra)"""
    f = np.zeros((FH, FW, 4), np.uint8)

    def metti(x, y, k):
        if 0 <= x < FW and 0 <= y < FH and k in COLORI:
            f[y, x, :3] = COLORI[k]
            f[y, x, 3] = 255
    a = abs(piega)
    giu = 0 if a < 2 else (1 if a == 2 else 2)           # piegato molto: la corolla scende
    H = max(1, sp['gambo'] - giu)
    # l'ombrina per terra, a destra del piede (la luce viene da in alto a sinistra)
    metti(PX + 1, PY, 's'); metti(PX + 2, PY, 's')
    # il gambo: dal piede in su, si curva di piu' in alto
    xs = []
    for k in range(1, H + 1):
        dx = int(round(piega * (k / H) ** 1.6))
        xs.append(dx)
        metti(PX + dx, PY - k + 1, 'g' if k < H else 'G')        # sotto la corolla e' in ombra
    # le foglie: due pixel in diagonale dal gambo, in fuori e in su
    for (h, lato) in sp['foglie']:
        if h <= H:
            x0 = PX + xs[h - 1]
            metti(x0 + lato, PY - h + 1, 'g')
            metti(x0 + 2 * lato, PY - h, 'G' if lato > 0 else 'g')
    # la corolla, con l'attacco sopra la cima del gambo
    cor = sp['corolla']
    top = PY - H - len(cor) + 1
    x0 = PX + piega - sp['attacco']
    for j, riga in enumerate(cor):
        for i, ch in enumerate(riga):
            if ch != '.':
                metti(x0 + i, top + j, ch)
    return f


def fogli():
    nomi = list(SPECIE)
    atl = np.zeros((FH * len(nomi), FW * len(PIEGHE), 4), np.uint8)
    for r, n in enumerate(nomi):
        for c, p in enumerate(PIEGHE):
            atl[r * FH:(r + 1) * FH, c * FW:(c + 1) * FW] = posa(SPECIE[n], p)
    dati = {'specie': nomi, 'pieghe': PIEGHE, 'w': FW, 'h': FH, 'px': PX, 'py': PY}
    return atl, dati


def anteprima(atl, dati, prato, uscita, z=8):
    # ogni specie in tutte le pose, sopra un pezzo di prato
    nomi = dati['specie']
    H, W = prato.shape[:2]
    righe = []
    for r in range(len(nomi)):
        celle = []
        for c in range(len(PIEGHE)):
            sotto = prato[(r * 5) % (H - FH):(r * 5) % (H - FH) + FH, (c * 9) % (W - FW):(c * 9) % (W - FW) + FW].copy()
            sp = atl[r * FH:(r + 1) * FH, c * FW:(c + 1) * FW]
            m = sp[..., 3] > 0
            sotto[m] = sp[m][:, :3]
            celle.append(sotto)
            celle.append(np.full((FH, 1, 3), 30, np.uint8))
        righe.append(np.concatenate(celle, 1))
        righe.append(np.full((1, righe[-1].shape[1], 3), 30, np.uint8))
    t = np.concatenate(righe, 0)
    Image.fromarray(t).resize((t.shape[1] * z, t.shape[0] * z), Image.NEAREST).save(uscita)


if __name__ == '__main__':
    TER = sys.argv[1]
    atl, dati = fogli()
    Image.fromarray(atl).save(os.path.join(TER, 'fiori.png'))
    with open(os.path.join(TER, 'fiori.json'), 'w', encoding='utf-8') as f:
        json.dump(dict(dati, _nota="Scritto da strumenti/livelli/fiori.py: i fiori del prato, una riga per specie, "
                       "una colonna per piega (-3..+3); il piede del fiore e' a (px, py) nel fotogramma."), f,
                  indent=1, ensure_ascii=False)
        f.write('\n')
    if len(sys.argv) > 2:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        from prato import TINTE, prato as _prato
        p, _ = _prato(60, 120, seme=5, tav=TINTE['A'])
        anteprima(atl, dati, p[2], sys.argv[2])
    print('fiori', len(dati['specie']), 'specie x', len(PIEGHE), 'pieghe')
