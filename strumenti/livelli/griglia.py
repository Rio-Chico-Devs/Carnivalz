# Le scene ordinate a griglia (l'esempio 126 di Bru: "ecco un esempio di come mi piacerebbe che ordinassimo le cose").
#
#   python3 strumenti/livelli/griglia.py [cartella_anteprime] [scena ...]          (serve numpy e Pillow)
#
# Come nelle mappe dei giochi a caselle: tutto sta su una griglia (caselle da 40 pixel, la larghezza di Lei); un solo
# albero da muro, largo due caselle, ripetuto a passo fisso in file che si sovrappongono (ognuno copre il tronco di
# quello dietro), fa blocchi di bosco coi bordi dritti; dove si cammina e' scavato nel bosco, con gli angoli retti; poche
# cose messe nei punti giusti (lo stagno col salice, il cartello all'imbocco, il cespuglio davanti alla nicchia); il
# prato calmo, coi segni d'erba radi.
#
# Quello che si vede e' quello che si cammina: un blocco di bosco si vede grande quanto le sue celle. Il primo albero
# ha il piede in fondo al blocco, gli altri dietro a passo di una casella finche' la chioma sta dentro; se in cima
# resta un vuoto lo chiude una chioma senza tronco. Siccome l'albero e' alto due caselle e mezzo, un blocco che sta
# sotto un posto dove si cammina deve essere alto almeno tre file (se no la chioma coprirebbe il passaggio sopra:
# lo script lo segnala). Il prato e' scuro solo fra una chioma e l'altra, mai a rettangoli; sotto la fila davanti
# l'ombra del bosco fa una fascia a onde fra i tronchi.
#
# La pianta di ogni scena e' scritta a caratteri, una riga per fila di caselle; ogni carattere e' una cella larga DUE
# caselle (80 pixel, quanto un albero) e alta una (40):
#   T albero (muro)      . prato        o la radura (prato, dove succede la scena)      ~ acqua (lo stagno)
#   S cartello           b cespuglio tondo      c cespuglio a tre      N cespuglione (nasconde quello che c'e' dietro)
#   r sasso              R gruppo di sassi      w salice               f prato coi fiori (i fiori sono nella scena)
# I cespugli, i sassi e il salice sono quelli di Bru (art/livelli/pezzi/bru, dai disegni 123-125).
# Scrive art/livelli/<scena>.png, _pezzi.json, _passi.png, _prato.png, _fiori.json, .json; i pezzi nuovi in
# art/livelli/pezzi/griglia/.
import json
import os
import sys

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
sys.path.insert(0, os.path.join(QUI, '..'))
import ruscello_radenna as rr     # noqa: E402
import prato as _prato            # noqa: E402
import piante as pt               # noqa: E402
import masse as ms                # noqa: E402  il fogliame a masse (l'albero 121 di Bru)
import scene_pianure as sp        # noqa: E402  l'acqua coi colori del ruscello, le ninfee, i funghetti

LIV = rr.LIV
PRATO = rr.PRATO
W = 1280
CASELLA = 40
CELLA = (2 * CASELLA, CASELLA)          # una cella della pianta: due caselle per una
NUOVI = os.path.join(LIV, 'pezzi', 'griglia')
REL = 'pezzi/griglia/'
CHIOMA = pt.CHIOMA
TRONCO = pt.TRONCO

# le cose della pianta: carattere -> (pezzo, spostamento del piede dal fondo-mezzo della cella, impronta (rx, ry) dove
# non si passa, centro dell'impronta sopra il piede)
COSE = {
    'S': ('cartello', (26, -6), (6, 3), 0),
    'b': ('cespuglio_tondo', (0, -4), (18, 6), 0),
    'c': ('cespuglio_triplo', (0, -4), (28, 6), 0),
    'N': ('cespuglione', (30, -4), (34, 7), 0),
    'r': ('roccia_tonda', (0, -6), (18, 5), 0),
    'R': ('rocce_gruppo', (0, -6), (32, 7), 0),
    'w': ('salice', (8, -4), (24, 18), 14),      # dietro il salice non si va: la chioma coprirebbe Lei
}
NOMI_BRU = {'cespuglione': 'cespuglio_nuvola'}


# ---------------------------------------------------------------- l'albero da muro
def albero_tondo(largo=84, seme=3, tronco=True):
    """l'albero da muro, come l'albero 121 di Bru: la chioma tonda fatta di poche grandi masse di foglie (il bordo a
    foglie, dentro i toni piatti), la luce da in alto a sinistra, il contorno scuro tutto attorno; sotto il tronco corto
    che si allarga alle radici. Senza tronco e' la chioma che chiude in cima i blocchi (stessa misura, stesso piede)"""
    rng = np.random.default_rng(seme)
    R = largo / 2.0 - 2
    alto_t = 16
    Hh, Ww = int(2 * R + alto_t + 8), largo + 4
    img = np.zeros((Hh, Ww, 3))
    op = np.zeros((Hh, Ww), bool)
    cx, cy = Ww / 2.0, R + 3
    yy, xx = np.mgrid[0:Hh, 0:Ww].astype(float)
    # il tronco: luce a sinistra, ombra a destra, le radici in fondo; in cima l'ombra della chioma
    base = Hh - 3
    if tronco:
        for y in range(int(cy + R * 0.6), base + 1):
            t = (y - (cy + R * 0.6)) / max(1.0, base - (cy + R * 0.6))
            mezzo = 5 + 6 * t ** 3
            for x in range(int(cx - mezzo - 1), int(cx + mezzo + 2)):
                if abs(x + 0.5 - cx) <= mezzo:
                    lx = (x + 0.5 - cx) / mezzo
                    img[y, x] = TRONCO[3] if lx < -0.35 else (TRONCO[2] if lx < 0.3 else TRONCO[1])
                    op[y, x] = True
    # la chioma: un tondo col bordo a gobbe
    ang = np.arctan2(yy - cy, xx - cx)
    gobbe = 1 + 0.045 * np.sin(11 * ang + rng.uniform(0, 6)) + 0.03 * np.sin(7 * ang + rng.uniform(0, 6))
    d = np.hypot(xx - cx, (yy - cy) * 1.04) / (R * gobbe)
    m = d <= 1.0
    nx, ny = (xx - cx) / R, (yy - cy) / R
    nz = np.sqrt(np.clip(1 - nx ** 2 - ny ** 2, 0, 1))
    L = np.array([-0.5, -0.7, 0.55])
    L = L / np.linalg.norm(L)
    diff = np.clip(nx * L[0] + ny * L[1] + nz * L[2], 0, 1)
    tono = 1.6 + 4.4 * diff
    sub = np.zeros_like(img)
    liv = ms.masse(sub, m, tono, rng, rampa=CHIOMA, minimo=1, raggio=8.5, grumi=(13, 10))
    sopra = liv >= 0
    img[sopra] = sub[sopra]
    op |= sopra
    # l'ombra della chioma sul tronco
    sotto = op & ~sopra & (yy < cy + R + 4) & (yy > cy + R * 0.6)
    img[sotto] = TRONCO[0]
    # il contorno: tutto attorno, scuro
    pad = np.pad(op, 1)
    bordo = op & (~pad[:-2, 1:-1] | ~pad[2:, 1:-1] | ~pad[1:-1, :-2] | ~pad[1:-1, 2:])
    img[bordo & sopra] = CHIOMA[0]
    img[bordo & ~sopra] = (47, 41, 67)
    a = np.zeros((Hh, Ww, 4), float)
    a[op, :3] = img[op]
    a[op, 3] = 255
    return a, (int(round(cx)), base)


def cartello():
    """un cartello di legno: il paletto e la tavola con due righe scritte"""
    col = {'k': (47, 41, 67), 'L': TRONCO[3], 'l': TRONCO[2], 'd': TRONCO[1], 's': (236, 214, 170), 'S': (206, 176, 132)}
    disegno = ['.kkkkkkkkkkkkkkkkkkkk.',
               'kSsssssssssssssssssSdk',
               'kSssssssssssssssssssdk',
               'kSsdkkdkkdkkkdkkdssSdk',
               'kSssssssssssssssssssdk',
               'kSsskkdkkkdkdkkkssssdk',
               'kSssssssssssssssssssdk',
               'kSSSSSSSSSSSSSSSSSSSdk',
               '.kkkkkkkkLlldkkkkkkkk.',
               '.........Llldk........',
               '.........Llldk........',
               '.........Llldk........',
               '.........Llldk........',
               '.........Llldk........',
               '........kLllddk.......',
               '........kkkkkkk.......']
    a = sp._disegna(disegno, col)
    return a, (11, len(disegno) - 1)


def prepara():
    os.makedirs(NUOVI, exist_ok=True)
    for nome, (a, piede) in (('albero_tondo', albero_tondo()), ('chioma_tonda', albero_tondo(tronco=False)),
                             ('cartello', cartello())):
        rr._salva(a, os.path.join(NUOVI, nome + '.png'))
        with open(os.path.join(NUOVI, nome + '.json'), 'w') as f:
            json.dump({'piede': [int(piede[0]), int(piede[1])]}, f)


def pezzo(nome):
    """(file da art/livelli/, piede, misura) di un pezzo: della griglia, di Bru (pezzi/bru), delle pianure"""
    nome = NOMI_BRU.get(nome, nome)
    for cart, rel in ((NUOVI, REL), (os.path.join(LIV, 'pezzi', 'bru'), 'pezzi/bru/'),
                      (os.path.join(LIV, 'pezzi', 'pianure'), 'pezzi/pianure/')):
        f = os.path.join(cart, nome + '.png')
        if os.path.exists(f):
            with open(os.path.join(cart, nome + '.json')) as fj:
                piede = tuple(json.load(fj)['piede'])
            w, h = Image.open(f).size
            return rel + nome + '.png', piede, (w, h)
    raise KeyError(nome)


def opaco(nome):
    """dove il disegno di un pezzo non e' trasparente"""
    f, _, _ = pezzo(nome)
    return np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA'))[..., 3] > 0


# ---------------------------------------------------------------- la pianta
def leggi(pianta):
    righe = [r for r in pianta.strip('\n').split('\n')]
    larg = max(len(r) for r in righe)
    return np.array([list(r.ljust(larg, 'T')) for r in righe])


def maschera(P, chars, H):
    """i pixel delle celle che hanno uno di questi caratteri"""
    m = np.zeros((H, W), bool)
    cw, ch = CELLA
    for j in range(P.shape[0]):
        for i in range(P.shape[1]):
            if P[j, i] in chars:
                m[j * ch:(j + 1) * ch, i * cw:(i + 1) * cw] = True
    return m


def schema(P, percorso):
    """la pianta disegnata a colori piatti, per guardarla prima di fare la scena"""
    col = {'T': (46, 92, 64), '.': (190, 214, 150), 'o': (236, 222, 140), '~': (90, 160, 200), 'S': (200, 140, 90),
           'b': (110, 170, 100), 'c': (110, 170, 100), 'N': (80, 150, 80), 'r': (160, 160, 160), 'R': (130, 130, 130),
           'w': (120, 190, 120), 'f': (240, 200, 220)}
    k = 10
    img = np.zeros((P.shape[0] * k, P.shape[1] * 2 * k, 3), np.uint8)
    for j in range(P.shape[0]):
        for i in range(P.shape[1]):
            img[j * k:(j + 1) * k - 1, i * 2 * k:(i + 1) * 2 * k - 1] = col.get(P[j, i], (255, 0, 255))
    Image.fromarray(img).resize((img.shape[1] * 2, img.shape[0] * 2), Image.NEAREST).save(percorso)


def file_alberi(P, alto):
    """i piedi degli alberi da muro e delle chiome che chiudono i blocchi in cima, colonna per colonna (vedi in
    testa); 'alto': di quanto la chioma sale sopra il piede. Ritorna anche i blocchi troppo bassi"""
    alberi, chiome, corti = [], [], []
    cw, ch = CELLA
    for i in range(P.shape[1]):
        j = 0
        while j < P.shape[0]:
            if P[j, i] != 'T':
                j += 1
                continue
            j0 = j
            while j < P.shape[0] and P[j, i] == 'T':
                j += 1
            y_su, y_giu = j0 * ch, j * ch
            x = i * cw + cw // 2
            f = y_giu - 2
            if j0 == 0:
                # il bosco continua oltre il bordo in alto
                while f > 10:
                    alberi.append((x, f))
                    f -= ch
                continue
            if f - alto < y_su:
                corti.append((j0, i, j - j0))
                alberi.append((x, f))
                continue
            while f - alto >= y_su:
                alberi.append((x, f))
                f -= ch
            if (f + ch) - alto > y_su + 3:
                chiome.append((x, y_su + alto))
    return alberi, chiome, corti


def _timbra(m, op, x, y, piede):
    """mette il disegno 'op' (vero/falso) col piede in x, y dentro la maschera m (tagliato ai bordi)"""
    H_, W_ = m.shape
    h, w = op.shape
    x0, y0 = int(x) - piede[0], int(y) - piede[1]
    a0, b0 = max(0, -y0), max(0, -x0)
    a1, b1 = min(h, H_ - y0), min(w, W_ - x0)
    if a1 > a0 and b1 > b0:
        m[y0 + a0:y0 + a1, x0 + b0:x0 + b1] |= op[a0:a1, b0:b1]


def _incolla(a, im, x0, y0):
    """alpha_composite che accetta anche i pezzi che escono dal bordo"""
    w, h = im.size
    a0, b0 = max(0, -y0), max(0, -x0)
    a1, b1 = min(h, a.size[1] - y0), min(w, a.size[0] - x0)
    if a1 > a0 and b1 > b0:
        a.alpha_composite(im.crop((b0, a0, b1, a1)), (x0 + b0, y0 + a0))


def dilata(m, r):
    """allarga la maschera di r pixel (a tondo)"""
    out = m.copy()
    H_, W_ = m.shape
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy > r * r or (dx == 0 and dy == 0):
                continue
            ys, yd = (slice(0, H_ - dy), slice(dy, H_)) if dy >= 0 else (slice(-dy, H_), slice(0, H_ + dy))
            xs, xd = (slice(0, W_ - dx), slice(dx, W_)) if dx >= 0 else (slice(-dx, W_), slice(0, W_ + dx))
            out[yd, xd] |= m[ys, xs]
    return out


def chiudi(m, r):
    """riempie i varchi piu' stretti di 2r fra le parti della maschera"""
    return ~dilata(~dilata(m, r), r)


def ovale(giu, cx, cy, rx, ry, livello):
    """un ovale d'ombra (quanti gradini scende il prato) nel campo 'giu'"""
    H_, W_ = giu.shape
    y0, y1 = max(0, int(cy - ry) - 1), min(H_, int(cy + ry) + 2)
    x0, x1 = max(0, int(cx - rx) - 1), min(W_, int(cx + rx) + 2)
    if y1 <= y0 or x1 <= x0:
        return
    yy, xx = np.mgrid[y0:y1, x0:x1]
    e = ((xx + 0.5 - cx) / rx) ** 2 + ((yy + 0.5 - cy) / ry) ** 2 <= 1
    sub = giu[y0:y1, x0:x1]
    sub[e] = np.maximum(sub[e], livello)


def stagni(P, H, seme):
    """per ogni gruppo di celle '~' uno stagno tondo-quadro (una superellisse dentro le celle) col bordo un po'
    mosso: sta nella griglia ma non e' una vasca"""
    cw, ch = CELLA
    visti = np.zeros(P.shape, bool)
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    acque = np.zeros((H, W), bool)
    for j in range(P.shape[0]):
        for i in range(P.shape[1]):
            if P[j, i] != '~' or visti[j, i]:
                continue
            gruppo, coda = [], [(j, i)]
            visti[j, i] = True
            while coda:
                a, b = coda.pop()
                gruppo.append((a, b))
                for da, db in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    na, nb = a + da, b + db
                    if 0 <= na < P.shape[0] and 0 <= nb < P.shape[1] and P[na, nb] == '~' and not visti[na, nb]:
                        visti[na, nb] = True
                        coda.append((na, nb))
            celle = np.zeros((H, W), bool)
            for (a, b) in gruppo:
                celle[a * ch:(a + 1) * ch, b * cw:(b + 1) * cw] = True
            ja, ia = [g[0] for g in gruppo], [g[1] for g in gruppo]
            y0, y1, x0, x1 = min(ja) * ch, (max(ja) + 1) * ch, min(ia) * cw, (max(ia) + 1) * cw
            cx, cy = (x0 + x1) / 2.0, (y0 + y1) / 2.0
            ax, by = (x1 - x0) / 2.0 - 6, (y1 - y0) / 2.0 - 4
            rng = np.random.default_rng(seme + 7 * j + i)
            ang = np.arctan2((yy - cy) / by, (xx - cx) / ax)
            mosso = 1 + 0.05 * np.sin(3 * ang + rng.uniform(0, 6)) + 0.035 * np.sin(5 * ang + rng.uniform(0, 6))
            s = (np.abs(xx - cx) / ax) ** 3.2 + (np.abs(yy - cy) / by) ** 3.2
            acque |= celle & (s <= mosso ** 3.2)
    return acque


def prato_calmo(H, rng, seme):
    """il prato calmo: la base, poche macchie larghe un gradino piu' scure (non a mimetica: grandi e lisce), e i segni
    d'erba radi in file sfalsate (come negli esempi), qualche ciuffo chiaro"""
    out = np.zeros((H, W, 3))
    out[:] = PRATO['base']
    n = _prato.liscio(H, W, 90, 45, seme)
    out[n > np.quantile(n, 0.93)] = PRATO['medio']
    segni = [['..X...X..', '.X.X.X.X.', 'X...X...X'], ['.X....X.', 'X.X..X.X', '...XX...'],
             ['..X..X..X..', '.X.XX.XX.X.', 'X.........X']]
    luce = [['X.X', '.X.'], ['.X.', 'XXX']]
    for j, y in enumerate(range(10, H, 22)):
        for x in range(-10 + (j % 2) * 24, W, 48):
            cx, cy = x + int(rng.integers(-8, 9)), y + int(rng.integers(-3, 4))
            f = segni[int(rng.integers(len(segni)))] if rng.random() < 0.8 else luce[int(rng.integers(2))]
            colore = PRATO['medio'] if f in segni else PRATO['luce']
            for jj, r in enumerate(f):
                for ii, c in enumerate(r):
                    yy, xx = cy + jj, cx + ii
                    if c == 'X' and 0 <= yy < H and 0 <= xx < W:
                        if tuple(int(v) for v in out[yy, xx]) == PRATO['medio'] and colore == PRATO['medio']:
                            out[yy, xx] = PRATO['scuro']
                        else:
                            out[yy, xx] = colore
    return out


# ---------------------------------------------------------------- la scena
def fai_scena(nome, z, anteprime=None):
    P = leggi(z['pianta'])
    H = P.shape[0] * CELLA[1]
    assert P.shape[1] * CELLA[0] == W, (P.shape, W)
    rng = np.random.default_rng(z['seme'])
    out = prato_calmo(H, rng, z['seme'])
    alberi_c = maschera(P, 'T', H)
    acque = stagni(P, H, z['seme'])
    cw, ch = CELLA
    # gli alberi da muro, colonna per colonna
    op_albero, op_chioma = opaco('albero_tondo'), opaco('chioma_tonda')
    _, piede_a, _ = pezzo('albero_tondo')
    alto = piede_a[1] - int(np.nonzero(op_albero.any(axis=1))[0][0])
    alberi, chiome, corti = file_alberi(P, alto)
    for (j0, i, n) in corti:
        print('  attenzione: il blocco di bosco in colonna %d, file %d-%d, e\' alto %d (ne servono 3): la chioma '
              'copre il passaggio sopra' % (i, j0, j0 + n - 1, n))
    tutte = [('albero_tondo', x, y, (0, 0), 0) for (x, y) in alberi] + \
            [('chioma_tonda', x, y, (0, 0), 0) for (x, y) in chiome]
    cose = dict(COSE, **z.get('cose', {}))
    for j in range(P.shape[0]):
        for i in range(P.shape[1]):
            if P[j, i] in cose:
                n, (dx, dy), imp, su = cose[P[j, i]]
                tutte.append((n, i * cw + cw // 2 + dx, (j + 1) * ch - 2 + dy, imp, su))
    pezzi = []
    for (n, x, y, imp, su) in tutte:
        f, piede, misura = pezzo(n)
        pezzi.append((n, f, x, y, piede, imp, su, misura))
    # dove stanno le chiome (e i tronchi davanti)
    chiome_m = np.zeros((H, W), bool)
    for (n, f, x, y, piede, imp, su, misura) in pezzi:
        if n == 'albero_tondo':
            _timbra(chiome_m, op_albero, x, y, piede)
        elif n == 'chioma_tonda':
            _timbra(chiome_m, op_chioma, x, y, piede)
    # le ombre: sotto la fila davanti di ogni blocco la fascia a onde fra i tronchi (due ovali per albero, che si
    # toccano con quelli accanto); sotto le altre cose un ovale spostato verso destra, la luce viene da sinistra
    giu = np.zeros((H, W), int)
    davanti = set()
    for (x, y) in alberi:
        i, j = x // cw, (y + 2) // ch - 1
        if j + 1 >= P.shape[0] or P[j + 1, i] != 'T':
            # in fondo alla fila (accanto non c'e' bosco) la fascia non sborda oltre il blocco
            fine = (i > 0 and P[j, i - 1] != 'T') or (i + 1 < P.shape[1] and P[j, i + 1] != 'T')
            davanti.add((x, y, fine))
    for (x, y, fine) in davanti:
        ovale(giu, x + 3, y - 5, 34 if fine else 47, 13, 1)
        ovale(giu, x + 3, y - 8, 28 if fine else 38, 9, 2)
    for (n, f, x, y, piede, imp, su, (w_, h_)) in pezzi:
        if n not in ('albero_tondo', 'chioma_tonda'):
            ovale(giu, x + 3, y - 1, max(6, 0.42 * w_), min(6, max(3, 0.09 * w_)), 1)
    sp.pg.scendi(out, giu)
    # fra una chioma e l'altra il prato e' in ombra: dove le chiome si toccano quasi (varchi stretti), mai a rettangoli
    scuro = chiudi(chiome_m, 8)
    out[scuro] = PRATO['scuro']
    if acque.any():
        riva, col = sp.disegna_acqua(H, acque, rng)
        m = acque | riva
        out[m] = col[m]
        if z.get('ninfee'):
            sp.ninfee(out, z['ninfee'], rng)
    if z.get('funghi'):
        sp.funghi(out, z['funghi'], rng)
    rr._salva(out, os.path.join(LIV, nome + '.png'))
    # dove si cammina: non nel bosco (ne' sotto le chiome), non nell'acqua, non sulle cose
    yy, xx = np.mgrid[0:H, 0:W]
    ok = ~alberi_c & ~dilata(chiome_m, 2) & (_prato.distanza(acque, 4) > 3)
    for (n, f, x, y, piede, (rx, ry), su, misura) in pezzi:
        if rx:
            ok &= ((xx - x) / rx) ** 2 + ((yy - (y - su)) / ry) ** 2 > 1
    # Lei e' larga: a ridosso dei muri di alberi non entra
    ok &= _prato.distanza(alberi_c, 8) > 6
    cammino = np.zeros((H, W, 4), np.uint8)
    cammino[ok] = (255, 255, 255, 255)
    rr._salva(cammino, os.path.join(LIV, nome + '_passi.png'))
    q = np.rint(out).astype(int)
    erba = np.zeros((H, W), bool)
    for c_ in PRATO.values():
        erba |= np.all(q == np.array(c_), axis=-1)
    erba &= ~alberi_c & ~acque & ~scuro
    pr = np.zeros((H, W, 4), np.uint8)
    pr[erba] = (255, 255, 255, 255)
    rr._salva(pr, os.path.join(LIV, nome + '_prato.png'))
    fiori = []
    rf = np.random.default_rng(z['seme'] + 9)
    for (cx, cy, quanti, specie) in z.get('fiori', []):
        for _ in range(quanti):
            x, y = int(cx + rf.integers(-26, 27)), int(cy + rf.integers(-10, 11))
            if 0 <= y < H and 0 <= x < W and ok[y, x]:
                fiori.append([x, y, int(specie[int(rf.integers(len(specie)))])])
    fiori.sort(key=lambda f: (f[1], f[0]))
    with open(os.path.join(LIV, nome + '_fiori.json'), 'w') as f:
        json.dump({"_nota": "Scritto da strumenti/livelli/griglia.py: non toccare a mano.", "fiori": fiori}, f)
        f.write('\n')
    with open(os.path.join(LIV, nome + '_pezzi.json'), 'w') as f:
        json.dump({"_nota": "Scritto da strumenti/livelli/griglia.py: non toccare a mano. Ogni pezzo e' [file (da "
                            "art/livelli/), x, y del piede nel mondo, x, y del piede nel disegno].",
                   "pezzi": [[t[1], int(t[2]), int(t[3]), int(t[4][0]), int(t[4][1])]
                             for t in sorted(pezzi, key=lambda t: (t[3], t[2]))]}, f, indent=1, ensure_ascii=False)
        f.write('\n')
    pianta = {"_nota": z['nota'], "nome": z['nome'], "mappa": nome + ".png", "scala": 1, "pixel": 1,
              "ingrandimento": 2, "pezzi": nome + "_pezzi.json", "passi": nome + "_passi.png",
              "prato": nome + "_prato.png", "fiori": nome + "_fiori.json", "limiti": [0, 0, W, H],
              "partenza": z['partenza'], "verso": z['verso'], "stanze": z['stanze']}
    with open(os.path.join(LIV, nome + '.json'), 'w') as f:
        json.dump(pianta, f, indent=1, ensure_ascii=False)
        f.write('\n')
    if anteprime:
        schema(P, os.path.join(anteprime, nome + '_schema.png'))
        a = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).convert('RGBA')
        for t in sorted(pezzi, key=lambda t: (t[3], t[2])):
            im = Image.open(os.path.join(LIV, t[1])).convert('RGBA')
            _incolla(a, im, int(t[2] - t[4][0]), int(t[3] - t[4][1]))
        a.convert('RGB').save(os.path.join(anteprime, nome + '.png'))
        v = np.asarray(a.convert('RGB')).copy()
        v[~ok] = (v[~ok] * 0.55).astype(np.uint8)
        Image.fromarray(v).save(os.path.join(anteprime, nome + '_passi.png'))
    print('%s: %dx%d, %d alberi, %d chiome di chiusura, %d cose' % (nome, W, H, len(alberi), len(chiome),
                                                                    len(pezzi) - len(alberi) - len(chiome)))


# ---------------------------------------------------------------- la radura della Guida, a griglia
# Si entra da sud (dal prato dell'arrivo) per il corridoio fra due muri di bosco; si sbuca nella radura, larga e
# vuota, dove Lei si ferma e la Guida le spiega la mappa. Attorno, ognuna nel suo angolo: a nord-ovest lo stagno col
# salice che ci pende sopra; a nord l'imbocco del corridoio che porta al pasto del goblin, col cartello; a nord-est una
# nicchia nel bosco coi fiori e i funghetti, nascosta da un cespuglione davanti (ci si passa di fianco: e' la prima
# volta che la curiosita' porta dietro un cespuglio); a est il sasso, a sud-ovest un cespuglio.
SCENE = {
    'guida': {
        'seme': 71, 'nome': "La radura della Guida",
        'pianta': '''
TTTTTT.TTTTTTTTT
TTTTTT.TTTTTTTTT
TTTTTT.TTTTTTTTT
TTTTTT.TTTTRTTTT
TTTTTS.TTTTfTTTT
TT~~...TTTT.TTTT
TT~~.......N.TTT
TT.w...ooo....TT
TT.....ooo....TT
TTTT.........rTT
TTTTc......TTTTT
TTTTTTT.TTTTTTTT
TTTTTTT.TTTTTTTT
TTTTTTT.TTTTTTTT
TTTTTTT.TTTTTTTT
TTTTTTT.TTTTTTTT''',
        # i fiori al vento (x, y, quanti, specie: le righe di terreni/fiori.png)
        'fiori': [(920, 186, 6, (1, 4)), (215, 330, 6, (0, 3)), (1000, 352, 6, (2, 5)), (410, 222, 4, (0, 1)),
                  (430, 410, 4, (1, 2))],
        'ninfee': [(208, 250, 5, True), (262, 226, 4, False), (284, 256, 3, False)],
        'funghi': [(898, 214, 5), (944, 200, 3)],
        'partenza': [600, 610], 'verso': [0, -1],
        'stanze': [{"nome": "La Guida: le basi della mappa", "rett": [480, 240, 800, 400]},
                   {"nome": "Lo stagno col salice", "rett": [160, 200, 400, 340]},
                   {"nome": "Verso il pasto del goblin", "rett": [400, 0, 560, 240]},
                   {"nome": "Dietro il cespuglio", "rett": [880, 120, 1040, 290]},
                   {"nome": "Dal prato dell'arrivo", "rett": [560, 440, 640, 640]},
                   {"nome": "La radura", "rett": [0, 0, W, 640]}],
        'nota': "La radura della Guida ordinata a griglia (strumenti/livelli/griglia.py): blocchi di bosco, la radura "
                "in mezzo dove parla la Guida, lo stagno col salice, il cartello, la nicchia dietro il cespuglione.",
    },
}


if __name__ == '__main__':
    args = sys.argv[1:]
    anteprime = args[0] if args and os.path.isdir(args[0]) else None
    quali = [a for a in args if a in SCENE] or list(SCENE)
    prepara()
    for n in quali:
        fai_scena(n, SCENE[n], anteprime)
