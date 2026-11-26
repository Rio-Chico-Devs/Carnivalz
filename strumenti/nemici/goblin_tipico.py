"""Il goblin tipico (data/personaggi.json: goblin_tipico): le pose del foglio d'esempio di Bru (115, riportato ai pixel
veri da esempi_bru.py in esempi.png) con la lingua blu del suo disegno (114). Bru: "ti ho dato un foglio pieno di
esempi... parti da quelle e semplicemente aggiungi la lingua".
Il foglio: 5 file x 5 colonne di pose; le colonne come negli esempi: di fronte, di lato (verso sinistra nelle prime
tre file, verso destra nelle ultime due), la corsa di fronte con la bocca aperta, di spalle di lato, di spalle.
Bru: "deve essere grande quanto lei ma un po' piu' piccolo" (gli esempi sono alti 43 pixel, Lei 74): tutto
ingrandito di una volta e mezza (circa 65 pixel), riquadri di 57x75 coi piedi sull'ultima riga. Non a blocchi (un
pixel su due raddoppiato, linee storte): Scale3x, che tiene dritte le diagonali, poi ogni 2x2 il colore che c'e' di
piu' (gli occhi, le zanne, la lingua e le linee scure vincono se ce ne sono almeno due, e nessuno di loro si perde);
alla fine il contorno esterno torna di un pixel solo.
La lingua (blu, coi suoi chiaro e scuro e il contorno nero come il resto) dove si vede la bocca: di fronte pende
dritta fra le zanne, sotto la punta del naso; di lato pende sul mento e piega di un pixel verso il naso; nella corsa
la lingua rosa della bocca aperta diventa blu ed esce sul mento. Di spalle non si vede.
uso: goblin_tipico.py cartella    (legge cartella/esempi.png, scrive cartella/goblin_tipico.png)"""
import os
import sys
from collections import Counter

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from esempi_bru import QH, QW, TAV  # noqa: E402

LINGUA = {'b': (66, 109, 145), 'B': (112, 160, 196), 'n': (36, 64, 90)}   # medio, luce, scuro (dal disegno 114)
COLORI = dict(TAV, **LINGUA)


def leggi(percorso):
    a = np.asarray(Image.open(percorso).convert('RGBA'))
    L = np.full(a.shape[:2], '.', dtype='<U1')
    for k, c in TAV.items():
        L[(a[..., 3] > 0) & np.all(a[..., :3] == c, -1)] = k
    assert ((L != '.') == (a[..., 3] > 0)).all(), 'colori fuori dalla tavolozza'
    return L


def dritta(ax, ay, giu=4):
    """2 pixel di larghezza, dalla bocca (riga ay) giu' per 'giu' righe, col contorno ai lati e sotto"""
    p = [(ax, ay, 'b'), (ax + 1, ay, 'b')]
    for k in range(1, giu):
        p += [(ax, ay + k, 'B' if k == 1 else 'b'), (ax + 1, ay + k, 'b' if k < giu - 1 else 'n')]
        p += [(ax - 1, ay + k, 'k'), (ax + 2, ay + k, 'k')]
    p[-4] = (ax, ay + giu - 1, 'n')
    p += [(ax, ay + giu, 'k'), (ax + 1, ay + giu, 'k')]
    return p


def storta(ax, ay, verso):
    """di lato: due righe sotto la bocca, poi piega di un pixel verso il naso (verso -1 sinistra, +1 destra)"""
    a, b = ax, ax + 1
    p = [(a, ay, 'b'), (b, ay, 'b'), (a, ay + 1, 'B' if verso < 0 else 'b'), (b, ay + 1, 'b' if verso < 0 else 'B'),
         (a - 1, ay + 1, 'k'), (b + 1, ay + 1, 'k')]
    a2, b2 = a + verso, b + verso
    p += [(a2, ay + 2, 'b'), (b2, ay + 2, 'b'), (a2 - 1, ay + 2, 'k'), (b2 + 1, ay + 2, 'k'),
          (a2, ay + 3, 'n'), (b2, ay + 3, 'n'), (a2 - 1, ay + 3, 'k'), (b2 + 1, ay + 3, 'k'),
          (a2, ay + 4, 'k'), (b2, ay + 4, 'k')]
    return p


def lingue(L):
    L = L.copy()

    def metti(fila, col, punti):
        for x, y, ch in punti:
            L[fila * QH + y, col * QW + x] = ch
    for f in range(5):                                  # di fronte: il viso e' lo stesso nelle cinque pose
        metti(f, 0, dritta(18, 29))
    for f, (ax, ay, verso) in enumerate([(15, 29, -1), (15, 30, -1), (15, 30, -1), (24, 29, 1), (24, 29, 1)]):
        metti(f, 1, storta(ax, ay, verso))            # di lato
    for f in range(5):                                  # la corsa di fronte, con la bocca aperta
        sub = L[f * QH:(f + 1) * QH, 2 * QW:3 * QW]
        rosa = [(x, y) for y in range(28, 33) for x in range(QW) if sub[y, x] == 'm']
        chiari = [(x, y) for y in range(28, 33) for x in range(QW) if sub[y, x] in 'Ll'
                  and any(sub[y + dy, x + dx] == 'm' for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0)))]
        tutti = sorted(rosa + chiari, key=lambda t: (t[1], t[0]))
        for x, y in tutti:
            sub[y, x] = 'b'
        sub[tutti[0][1], tutti[0][0]] = 'B'             # la luce in alto a sinistra
        fondo = max(y for x, y in tutti)
        xs = sorted(x for x, y in tutti if y == fondo)
        ax = xs[len(xs) // 2] - (1 if len(xs) % 2 == 0 else 0)
        metti(f, 2, dritta(ax, fondo + 1, 3)[2:])
    return L


# ------------------------------------------------------------------ una volta e mezza
IMPORTANTI = 'wbBnk'    # occhi e zanne, la lingua, le linee: i dettagli piccoli che non devono sparire
V4 = ((0, 1), (1, 0), (0, -1), (-1, 0))


def scale3x(L):
    H, W = L.shape
    P = np.pad(L, 1, mode='constant', constant_values='.')
    O = np.empty((H * 3, W * 3), dtype=L.dtype)
    for y in range(H):
        for x in range(W):
            A, B, C = P[y, x], P[y, x + 1], P[y, x + 2]
            D, E, F = P[y + 1, x], P[y + 1, x + 1], P[y + 1, x + 2]
            G, Hh, I = P[y + 2, x], P[y + 2, x + 1], P[y + 2, x + 2]
            e = [E] * 9
            if B != Hh and D != F:
                if D == B:
                    e[0] = D
                if (D == B and E != C) or (B == F and E != A):
                    e[1] = B
                if B == F:
                    e[2] = F
                if (D == B and E != G) or (D == Hh and E != A):
                    e[3] = D
                if (B == F and E != I) or (Hh == F and E != C):
                    e[5] = F
                if D == Hh:
                    e[6] = D
                if (D == Hh and E != I) or (Hh == F and E != G):
                    e[7] = Hh
                if Hh == F:
                    e[8] = F
            O[y * 3:y * 3 + 3, x * 3:x * 3 + 3] = np.array(e).reshape(3, 3)
    return O


def dimezza(O):
    H, W = O.shape[0] // 2, O.shape[1] // 2
    R = np.empty((H, W), dtype=O.dtype)
    for y in range(H):
        for x in range(W):
            c = Counter(O[2 * y:2 * y + 2, 2 * x:2 * x + 2].ravel().tolist()).most_common()
            imp = [s for s, n in c if n >= 2 and s in IMPORTANTI]
            if imp:
                R[y, x] = min(imp, key=IMPORTANTI.index)
                continue
            top = [s for s, n in c if n == c[0][1]]
            colori = [s for s in top if s not in '.k']
            R[y, x] = top[0] if len(top) == 1 else (colori[0] if colori else ('k' if 'k' in top else top[0]))
    return R


def ripristina(L, R):
    """ogni pixel di occhi, zanne e lingua (e ogni pupilla) del piccolo ha almeno un pixel uguale nel suo posto
    ingrandito; se no lo si mette al centro"""
    H, W = L.shape
    for y in range(H):
        for x in range(W):
            s = L[y, x]
            pupilla = s == 'k' and sum(1 for dy, dx in V4 if 0 <= y + dy < H and 0 <= x + dx < W
                                       and L[y + dy, x + dx] == 'w') >= 2
            if s not in 'wbBn' and not pupilla:
                continue
            y0, y1 = int(np.floor(y * 1.5)), int(np.ceil((y + 1) * 1.5))
            x0, x1 = int(np.floor(x * 1.5)), int(np.ceil((x + 1) * 1.5))
            if not (R[y0:y1, x0:x1] == s).any():
                R[min(int(round((y + 0.5) * 1.5 - 0.5)), R.shape[0] - 1),
                  min(int(round((x + 0.5) * 1.5 - 0.5)), R.shape[1] - 1)] = s
    return R


def contorni(L):
    """il contorno esterno chiuso e di un pixel: un colore che tocca il vuoto diventa contorno; un contorno doppio
    (che non tocca il vuoto, accanto a uno che lo tocca, col colore dall'altra parte, e non in mezzo a una linea)
    diventa il colore accanto; i pixel di contorno rimasti soli spariscono"""
    L = L.copy()
    H, W = L.shape

    def dentro(y, x):
        return 0 <= y < H and 0 <= x < W

    def tocca_vuoto(y, x):
        return any(not dentro(y + dy, x + dx) or L[y + dy, x + dx] == '.' for dy, dx in V4)
    for y in range(H):
        for x in range(W):
            if L[y, x] not in '.k' and tocca_vuoto(y, x):
                L[y, x] = 'k'
    esterno = np.array([[L[y, x] == 'k' and tocca_vuoto(y, x) for x in range(W)] for y in range(H)])
    nuovo = L.copy()
    for y in range(H):
        for x in range(W):
            if L[y, x] != 'k' or esterno[y, x]:
                continue
            vic = [(y + dy, x + dx) for dy, dx in V4 if dentro(y + dy, x + dx)]
            colori = [L[a, b] for a, b in vic if L[a, b] not in '.k']
            if not colori or not any(esterno[a, b] for a, b in vic):
                continue
            linea = any(dentro(y - dy, x - dx) and dentro(y + dy, x + dx) and L[y - dy, x - dx] == 'k'
                        and L[y + dy, x + dx] == 'k' and not esterno[y - dy, x - dx] and not esterno[y + dy, x + dx]
                        for dy, dx in ((1, 0), (0, 1)))
            if not linea:
                nuovo[y, x] = Counter(colori).most_common(1)[0][0]
    L = nuovo
    for y in range(H):
        for x in range(W):
            if L[y, x] == 'k' and not any(dentro(y + dy, x + dx) and L[y + dy, x + dx] not in '.k'
                                          for dy in (-1, 0, 1) for dx in (-1, 0, 1) if dy or dx):
                L[y, x] = '.'
    return L


def ingrandisci(L):
    return contorni(ripristina(L, dimezza(scale3x(L))))


if __name__ == '__main__':
    D = sys.argv[1]
    L = ingrandisci(lingue(leggi(os.path.join(D, 'esempi.png'))))
    img = np.zeros(L.shape + (4,), np.uint8)
    for k, c in COLORI.items():
        m = L == k
        img[m, :3] = c
        img[m, 3] = 255
    Image.fromarray(img, 'RGBA').save(os.path.join(D, 'goblin_tipico.png'))
    print('goblin_tipico.png', L.shape[1], 'x', L.shape[0])
