# Le scene delle Pianure dopo il ruscello, in fila come nella tabella di marcia (docs/mondi.md) e nella storia
# (docs/storia.md, "Nelle Pianure, un passo alla volta"). Bru: "finiamo di fare le scene di tutto il livello, poi man
# mano le giudico e ti dico cosa togliere o aggiungere".
#
#   python3 strumenti/livelli/scene_pianure.py [cartella_anteprime] [scena ...]      (serve numpy e Pillow)
#
# Ogni scena e' una mappa larga 1280 come le altre (Lei passa da una all'altra tenendo la sua x), fatta con le stesse
# cose: il prato (prato.py), gli alberi e i cespugli nostri (piante.py, del ruscello), le ombre e i passi del pasto; e
# quello che serve alla scena: la strada di mattoni (il kit di Bru, come al pasto), il ruscello (coi colori e le sponde
# del ruscello), i pezzi ricalcati dai fogli di Bru (oggetti/: le caverne, le cascatelle, le rupi, le rovine) coi colori
# del gioco, e le creature a fotogrammi (che si muovono sempre, come il goblin del pasto). Dove un pezzo non e' ancora
# ridisegnato si usa quello ricalcato: Bru dira' quali rifare.
#
# Scrive art/livelli/<scena>.png, _pezzi.json, _passi.png, _prato.png, _fiori.json, .json; i pezzi in
# art/livelli/pezzi/pianure/.
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
import fiori as _fiori            # noqa: E402
import pasto_goblin as pg         # noqa: E402
import piante as pt               # noqa: E402
import tavolozza as _tav          # noqa: E402

LIV = rr.LIV
PRATO = rr.PRATO
W = 1280
OGG = os.path.join(LIV, 'oggetti')
CAT_OGG = json.load(open(os.path.join(OGG, 'catalogo.json')))['oggetti']
NUOVI = os.path.join(LIV, 'pezzi', 'pianure')
REL = 'pezzi/pianure/'
# l'acqua del ruscello (i colori della mappa del ruscello): il corpo, le strisce chiare, i due gradini verso la sponda,
# l'orlo chiaro, la sponda (la parete di terra, in ombra) e i sassolini sull'erba della riva
ACQUA = {'corpo': (86, 177, 195), 'chiaro': (103, 196, 199), 'bordo1': (94, 155, 176), 'bordo0': (97, 134, 155),
         'orlo': (170, 251, 228), 'schiuma': (203, 255, 239), 'sponda': (55, 60, 82), 'sponda2': (73, 106, 104),
         'sponda_dx': (81, 87, 111)}
SASSOLINI = [(124, 134, 122), (161, 162, 156), (191, 192, 186), (222, 223, 216)]


# ---------------------------------------------------------------- i pezzi
def _salva_pezzo(nome, a, piede, fotogrammi=None):
    os.makedirs(NUOVI, exist_ok=True)
    rr._salva(np.asarray(a, float), os.path.join(NUOVI, nome + '.png'))
    if fotogrammi is not None:
        rr._salva(np.concatenate([np.asarray(f, float) for f in fotogrammi], 1),
                  os.path.join(NUOVI, nome + '_fotogrammi.png'))
    with open(os.path.join(NUOVI, nome + '.json'), 'w') as f:
        json.dump({'piede': [int(piede[0]), int(piede[1])]}, f)


def ricalcato(nome, fatto_di=None):
    """un pezzo ricalcato dai fogli di Bru (oggetti/) coi colori del gioco e il contorno fuso nel terreno"""
    c = CAT_OGG[nome]
    a = np.asarray(Image.open(os.path.join(OGG, c['file'])).convert('RGBA'))
    sost = fatto_di if fatto_di is not None else {'chioma': 'muschio', 'tronco': 'pietra', 'oro': 'muschio'}
    a = _tav.ricolora(a, sostituisci=sost).astype(float)
    a = rr.fondi(a, True)
    _salva_pezzo(nome, a, c['piede'])
    return a, tuple(c['piede'])


def albero_gigante(alto=340, seme=29):
    """il grande albero: uno dei nostri alberi esotici (radici a contrafforte, chioma a strati), grande una volta e
    mezza gli altri"""
    a, piede = pt.albero_esotico(alto, seme, con_piede=True)
    a = rr.fondi(a.astype(float), True)
    _salva_pezzo('albero_alto_gigante', a, piede)
    return a, piede


def _disegna(lettere, colori):
    h, w = len(lettere), len(lettere[0])
    a = np.zeros((h, w, 4), float)
    for j, r in enumerate(lettere):
        for i, ch in enumerate(r):
            if ch in colori:
                a[j, i, :3] = colori[ch]
                a[j, i, 3] = 255
    return a


def slime():
    """lo slime: una goccia di gelatina azzurra, gli occhi girati verso gli animaletti (a destra, in alto); respira
    schiacciandosi e allungandosi (quattro fotogrammi)"""
    col = {'k': (38, 50, 96), 'd': (56, 92, 156), 'm': (84, 142, 210), 'l': (142, 198, 240), 'h': (232, 248, 255),
           'o': (24, 26, 44)}
    fot = []
    for alto, largo in ((24, 32), (23, 33), (21, 35), (23, 33)):
        H_, W_ = 26, 38
        L = [['.'] * W_ for _ in range(H_)]
        cx = W_ / 2.0
        base = H_ - 1
        for y in range(H_):
            for x in range(W_):
                dy = (base - y) / float(alto)                  # 0 in fondo, 1 in cima
                if dy < 0 or dy > 1:
                    continue
                mezzo = largo / 2.0 * (1 - dy ** 2.2) ** 0.5 if dy < 1 else 0
                if dy < 0.12:
                    mezzo = largo / 2.0 * (0.92 + 0.08 * dy / 0.12)
                if abs(x + 0.5 - cx) <= mezzo:
                    lx = (x + 0.5 - cx) / max(1.0, largo / 2.0)
                    luce = -0.55 * lx + 0.9 * (dy - 0.35)
                    L[y][x] = 'l' if luce > 0.35 else ('m' if luce > -0.25 else 'd')
        # il contorno
        out = [r[:] for r in L]
        for y in range(H_):
            for x in range(W_):
                if L[y][x] != '.' and any(not (0 <= y + a < H_ and 0 <= x + b < W_) or L[y + a][x + b] == '.'
                                          for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    out[y][x] = 'k'
        top = min(y for y in range(H_) if any(c != '.' for c in out[y]))
        # la luce grande in alto a sinistra e il riflesso
        for y, x in ((top + 3, int(cx) - 8), (top + 3, int(cx) - 7), (top + 3, int(cx) - 6), (top + 4, int(cx) - 9),
                     (top + 4, int(cx) - 8), (top + 5, int(cx) - 9)):
            if out[y][x] not in '.k':
                out[y][x] = 'h'
        # gli occhi, grandi, guardano in alto a destra (verso i coniglietti)
        ye = top + int(alto * 0.38)
        for x0 in (int(cx) + 2, int(cx) + 8):
            for y in range(ye, ye + 4):
                for x in (x0, x0 + 1):
                    if out[y][x] not in '.':
                        out[y][x] = 'o'
            out[ye][x0 + 1] = 'h'
        # la bocca piccola
        out[ye + 6][int(cx) + 5] = 'k'
        out[ye + 6][int(cx) + 6] = 'k'
        fot.append(_disegna([''.join(r) for r in out], col))
    _salva_pezzo('slime', fot[0], (19, 25), fot)
    return fot


def coniglio(seme, pelo):
    """un coniglietto di profilo (verso sinistra): rosicchia l'erba e alza le orecchie (due pose)"""
    col = {'k': (58, 40, 48), 'p': pelo[0], 'P': pelo[1], 'b': (238, 220, 190), 'r': (214, 132, 142), 'o': (24, 20, 28)}
    su = ['...kk..kk......',
          '..krk.krk......',
          '..krk.krk......',
          '..kPkkkPk......',
          '.kPPPPPPPk.....',
          'kPoPPPPPPPk....',
          'kPPPPPPPPPPkk..',
          '.kkPPPPPPPPPPk.',
          '..kbPPppppPPPPk',
          '..kbbppppppPPk.',
          '..kbbppppppPk..',
          '...kkk.kk.kkk..']
    giu = ['...............',
           '....kk.kk......',
           '...krkkrk......',
           '..kPkkkPk......',
           '.kPPPPPPPk.....',
           'kPPPPPPPPPkk...',
           'kPoPPPPPPPPPk..',
           'kPPPPPPPPPPPPk.',
           '.kkbPPppppPPPPk',
           '..kbbppppppPPk.',
           '..kbbppppppPk..',
           '...kkk.kk.kkk..']
    fot = [_disegna(su, col), _disegna(giu, col)]
    nome = 'coniglio_%d' % seme
    _salva_pezzo(nome, fot[0], (7, 11), fot)
    return fot


def cascata_fotogrammi(nome, n=6):
    """la cascatella a fotogrammi: dove c'e' acqua che cade, i colori di ogni colonna scendono di due pixel a
    fotogramma (girando), cosi' le strisce corrono giu'"""
    a = np.asarray(Image.open(os.path.join(NUOVI, nome + '.png')).convert('RGBA')).astype(float)
    acqua = set(tuple(int(v) for v in c) for c in _tav.tavolozze()['acqua'])
    m = np.zeros(a.shape[:2], bool)
    for y, x in zip(*np.nonzero(a[..., 3] > 0)):
        m[y, x] = tuple(int(v) for v in a[y, x, :3]) in acqua
    fot = []
    for f in range(n):
        b = a.copy()
        for x in range(a.shape[1]):
            ys = np.nonzero(m[:, x])[0]
            if len(ys) < 4:
                continue
            # le corse verticali d'acqua della colonna
            corse = np.split(ys, np.nonzero(np.diff(ys) > 1)[0] + 1)
            for c in corse:
                if len(c) < 4:
                    continue
                b[c, x, :3] = np.roll(a[c, x, :3], 2 * f, axis=0)
        fot.append(b)
    _salva_pezzo(nome, fot[0], CAT_OGG[nome]['piede'], fot)
    return fot


def nuovo(nome):
    f = os.path.join(NUOVI, nome + '.png')
    with open(os.path.join(NUOVI, nome + '.json')) as fj:
        piede = tuple(json.load(fj)['piede'])
    w, h = Image.open(f).size
    return REL + nome + '.png', piede, (w, h)


# ---------------------------------------------------------------- il terreno
def strada(H, punti, riga_fondo=26):
    """la strada di mattoni (il motivo intero del kit di Bru piegato lungo la curva, come al pasto e al ruscello);
    la riga del motivo sull'ultima riga della mappa e' 'riga_fondo' (cosi' continua quella della scena sotto)"""
    lin, u = rr.curva(punti)
    D, S, V = rr.campo(lin, u, 18, H, 0)
    st = pg._kit('strada_verticale.png')
    k0 = int(np.abs(lin[:, 1] - (H - 1)).argmin())
    spost = (riga_fondo - int(u[k0])) % 55
    col = np.clip((V + 14.5).astype(int), 0, 28)
    tex = st[(S.astype(int) + spost) % 55, col]
    via = (D < 14.5) & (tex >= 0)
    colori = np.zeros((H, W, 3))
    colori[via] = pg.MATTONI[tex[via]]
    return via, colori


def maschera_ruscello(H, punti, larghi):
    """dove c'e' l'acqua di un ruscello: lungo la curva, largo da larghi[0] a larghi[1]"""
    lin, u = rr.curva(punti)
    D, S, V = rr.campo(lin, u, 60, H, 0)
    t = np.clip(S / max(1.0, u[-1]), 0, 1)
    return D <= (larghi[0] + (larghi[1] - larghi[0]) * t) / 2.0


def _sposta(m, dy, dx):
    """la maschera spostata di dy in giu' e dx a destra (fuori dalla mappa: falso)"""
    H, W_ = m.shape
    o = np.zeros_like(m)
    ys0, ys1 = max(0, dy), min(H, H + dy)
    xs0, xs1 = max(0, dx), min(W_, W_ + dx)
    o[ys0:ys1, xs0:xs1] = m[ys0 - dy:ys1 - dy, xs0 - dx:xs1 - dx]
    return o


def disegna_acqua(H, dentro, rng):
    """l'acqua (ruscelli e pozze) coi colori e le sponde del ruscello, vista di tre quarti con la luce da in alto a
    sinistra: il corpo con le strisce chiare (la tessera), verso la riva due gradini piu' scuri; dove la riva sta in alto
    o a sinistra (la sponda si vede e fa ombra sull'acqua) la parete di terra scura, l'orlo chiaro e la fascia d'ombra;
    in basso e a destra solo una riga scura; sull'erba della riva i sassolini"""
    tess = np.asarray(Image.open(os.path.join(LIV, 'terreni', 'acqua_radenna_tavolozza.png')).convert('RGB'))
    th, tw = tess.shape[:2]
    yy, xx = np.mgrid[0:H, 0:W]
    colori = np.zeros((H, W, 3))
    colori[dentro] = tess[yy[dentro] % th, xx[dentro] % tw]
    terra = ~dentro
    d_in = _prato.distanza(terra, 8)                  # quanti passi dalla riva, nell'acqua
    d_out = _prato.distanza(dentro, 8)                # quanti passi dall'acqua, sulla terra
    colori[dentro & (d_in <= 2)] = ACQUA['bordo1']
    colori[dentro & (d_in <= 1)] = ACQUA['bordo0']
    # la riva in alto / a sinistra: per l'acqua, la terra sta sopra o a sinistra
    su_sx = np.zeros((H, W), bool)
    for k in range(1, 7):
        su_sx |= _sposta(terra, k, 0) | _sposta(terra, k, k // 2) | _sposta(terra, 0, k)
    ombra = dentro & su_sx & (d_in <= 6)
    colori[ombra & (d_in > 1)] = ACQUA['bordo1']
    orlo = dentro & (d_in == 1) & (_sposta(terra, 1, 0) | _sposta(terra, 0, 1))
    colori[orlo] = ACQUA['orlo']
    # sulla terra: la parete della sponda dove la terra sta sopra o a sinistra dell'acqua
    sopra_acqua = _sposta(dentro, -1, 0) | _sposta(dentro, -2, 0) | _sposta(dentro, 0, -1) | _sposta(dentro, 0, -2)
    parete = terra & sopra_acqua & (d_out <= 2)
    colori[parete & (d_out == 1)] = ACQUA['sponda']
    colori[parete & (d_out == 2)] = ACQUA['sponda2']
    sotto = terra & (d_out == 1) & ~parete
    colori[sotto] = ACQUA['sponda_dx']
    riva = parete | sotto
    sassi = np.zeros((H, W), bool)
    vicino = terra & ~riva & (d_out >= 3) & (d_out <= 6)
    ys, xs = np.nonzero(vicino)
    for i in rng.permutation(len(ys))[:len(ys) // 16]:
        y, x = ys[i], xs[i]
        w_ = int(rng.integers(2, 4))
        if sassi[max(0, y - 3):y + 4, max(0, x - 4):x + 5].any():
            continue
        c = SASSOLINI[int(rng.integers(1, len(SASSOLINI)))]
        for j in range(2):
            for i_ in range(w_):
                if 0 <= y + j < H and 0 <= x + i_ < W and vicino[y + j, x + i_]:
                    colori[y + j, x + i_] = c if j == 0 else SASSOLINI[0]
                    sassi[y + j, x + i_] = True
    return riva | sassi, colori


# ---------------------------------------------------------------- le rupi
PIETRA_R = None


def rupe(out, alto, faccia, rng, caverne=(), seme=5):
    """il ripiano alto e la sua parete di roccia vista di tre quarti: sotto ogni bordo di sud del ripiano scende la
    parete, alta 'faccia' pixel; la roccia a strati (le righe chiare delle cenge, le crepe scure in verticale), chiara in
    cima e scura in fondo, coi lati che girano in ombra; in cima l'erba che sporge e pende; sotto, l'ombra della parete
    sul prato. 'caverne': (x, larga, alta) le bocche scure nella parete. Ritorna (parete, bordo dell'erba in cima,
    bocche)"""
    global PIETRA_R
    if PIETRA_R is None:
        PIETRA_R = [tuple(int(v) for v in c) for c in _tav.tavolozze()['pietra']]
    P = PIETRA_R
    H, W_ = alto.shape
    sopra = np.zeros((H, W_), int)                    # quanti pixel sotto il bordo del ripiano (0: non parete)
    for k in range(1, faccia + 1):
        su = _sposta(alto, k, 0)
        nuovo = su & ~alto & (sopra == 0)
        sopra[nuovo] = k
    parete = sopra > 0
    fy = sopra.astype(float) / faccia                 # 0 in cima, 1 in fondo
    n1 = _prato.liscio(H, W_, 9, 4, seme) - 0.5
    crepe = (_prato.liscio(H, W_, 3, 14, seme + 1) > 0.78)
    yy, xx = np.mgrid[0:H, 0:W_]
    cenge = ((sopra + (n1 * 6).astype(int)) % 9 == 0)
    tono = 4.2 - 2.4 * fy + n1 * 1.2
    tono[cenge & parete] += 0.9
    tono[crepe & parete] -= 1.6
    # i lati: dove la parete finisce a destra o a sinistra la roccia gira (a sinistra luce, a destra ombra)
    fine_dx = parete & ~_sposta(parete, 0, -1)
    fine_sx = parete & ~_sposta(parete, 0, 1)
    d_dx = np.zeros((H, W_), int)
    d_sx = np.zeros((H, W_), int)
    for k in range(1, 6):
        d_dx[parete & (d_dx == 0) & _sposta(fine_dx, 0, -k)] = k
        d_sx[parete & (d_sx == 0) & _sposta(fine_sx, 0, k)] = k
    tono[(d_dx > 0) | fine_dx] -= 1.0
    tono[(d_sx > 0) | fine_sx] += 0.6
    k_ = np.clip(np.floor(tono + 0.5), 0, len(P) - 1).astype(int)
    for i in range(len(P)):
        out[parete & (k_ == i)] = P[i]
    # il contorno della parete in fondo (dove tocca il prato): una riga scura
    fondo = parete & ~_sposta(parete, -1, 0)
    out[fondo] = P[0]
    # le bocche delle caverne: un arco scuro nella parete, con l'orlo di roccia chiara
    bocche = np.zeros((H, W_), bool)
    for (cx, larga, alta_) in caverne:
        col = parete[:, cx]
        if not col.any():
            continue
        yb = int(np.nonzero(col)[0].max())            # il piede della parete in quella colonna
        dx = (xx - cx) / (larga / 2.0)
        dy = (yb - yy) / float(alta_)
        arco = parete & (dy >= 0) & (dx * dx + np.maximum(0, dy - 0.45) ** 2 / 0.55 ** 2 <= 1.0)
        out[arco] = (24, 22, 36)
        orlo = parete & ~arco & (_sposta(arco, 1, 0) | _sposta(arco, 0, 1) | _sposta(arco, 0, -1) | _sposta(arco, -1, 0))
        out[orlo] = P[min(len(P) - 1, 4)]
        bocche |= arco
    # i lati del ripiano senza parete (a levante e a ponente): una riga scura e una di erba in ombra
    lato = alto & ~parete & (~_sposta(alto, 0, 1) | ~_sposta(alto, 0, -1)) & ~(_sposta(parete, -1, 0))
    out[lato] = P[0]
    out[alto & _sposta(lato, 0, 1) & ~lato] = PRATO['scuro']
    out[alto & _sposta(lato, 0, -1) & ~lato] = PRATO['scuro']
    # in cima: l'erba del ripiano che sporge sulla parete e pende a ciuffi
    labbro = parete & (sopra <= 1)
    out[labbro] = PRATO['medio']
    for x in range(W_):
        ys_ = np.nonzero(labbro[:, x])[0]
        if len(ys_) and rng.random() < 0.45:
            y = ys_[0]
            for j in range(1, int(rng.integers(2, 5))):
                if y + j < H and parete[y + j, x] and not bocche[y + j, x]:
                    out[y + j, x] = PRATO['medio'] if j < 2 else PRATO['scuro']
    # sotto la parete: l'ombra sul prato (due gradini, poi uno), piu' lunga a destra
    giu = np.zeros((H, W_), int)
    for k in range(1, 9):
        s_ = _sposta(parete, k, k // 3) & ~parete & ~alto
        giu[s_ & (giu == 0)] = 2 if k <= 3 else 1
    pg.scendi(out, giu)
    return parete, labbro, bocche


def cascata(nome, alta, larga=24, n=6):
    """la cascatella che cade dalla parete: l'acqua a strisce che scendono (n fotogrammi), in fondo la schiuma"""
    A = ACQUA
    fot = []
    rng = np.random.default_rng(3)
    righe = rng.random((alta + 8, larga))
    for f in range(n):
        a = np.zeros((alta + 6, larga + 4, 4), float)
        for y in range(alta + 6):
            for x in range(larga + 4):
                xi = x - 2
                bordo = xi < 0 or xi >= larga
                if bordo and y < alta:
                    continue
                if y < alta:
                    v = righe[(y - 2 * f) % (alta + 8), xi]
                    if xi in (0, larga - 1):
                        c = A['bordo0']
                    elif xi in (1, larga - 2):
                        c = A['bordo1']
                    elif v > 0.9:
                        c = A['orlo']
                    elif v > 0.6:
                        c = A['chiaro']
                    else:
                        c = A['corpo']
                else:
                    # la schiuma in fondo, che si allarga sulla pozza
                    dd = abs(x - (larga + 4) / 2.0) / ((larga + 4) / 2.0)
                    if dd > 1.0 - 0.15 * (y - alta):
                        continue
                    c = A['schiuma'] if (x + y + f) % 3 else A['orlo']
                a[y, x, :3] = c
                a[y, x, 3] = 255
        fot.append(a)
    _salva_pezzo(nome, fot[0], ((larga + 4) // 2, alta + 5), fot)
    return fot


# ---------------------------------------------------------------- le scene
def impiedi(z):
    """(nome, file, x, y del piede, piede nel disegno, impronta)"""
    tutte = []
    for (n, x, y) in z.get('alberi', []):
        f, piede, (w, h) = rr.pezzo(n)
        tutte.append((n, 'pezzi/ruscello/fusi/' + os.path.basename(f), x, y, piede, rr.impronta(n, w, h)))
    for (n, x, y) in z.get('sassi', []):
        f, piede, (w, h) = rr.pezzo(n)
        tutte.append((n, 'pezzi/pasto/fusi/' + os.path.basename(f), x, y, piede, rr.impronta(n, w, h)))
    for (n, x, y, imp) in z.get('nuovi', []):
        f, piede, (w, h) = nuovo(n)
        tutte.append((n, f, x, y, piede, imp))
    return tutte


def fai_scena(nome, z, anteprime=None):
    H = z['H']
    rng = np.random.default_rng(z['seme'])
    tutte = impiedi(z)
    segni = []
    p4, _ = _prato.prato(H, W, seme=z['seme'], tav=PRATO, fiori=segni)
    out = p4[3].astype(float)
    duro = np.zeros((H, W), bool)                         # quello che non e' prato (acqua, sponde, strada, rupi)
    acque = np.zeros((H, W), bool)
    for (punti, larghi) in z.get('ruscelli', []):
        acque |= maschera_ruscello(H, punti, larghi)
    yy, xx = np.mgrid[0:H, 0:W]
    for (cx, cy, rx, ry) in z.get('pozze', []):
        acque |= ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1
    parete = np.zeros((H, W), bool)
    bocche = np.zeros((H, W), bool)
    alto = np.zeros((H, W), bool)
    if 'ripiano' in z:
        alto = z['ripiano'](H)
    if acque.any():
        riva, col = disegna_acqua(H, acque, rng)
        m = acque | riva
        out[m] = col[m]
        duro |= m
    acqua_ = acque
    if 'ripiano' in z:
        parete, labbro, bocche = rupe(out, alto, z.get('faccia', 40), rng, z.get('caverne', ()), z['seme'])
        duro |= parete | labbro
        acqua_ = acque & ~parete
    acqua = acqua_
    if 'strada' in z:
        via, col = strada(H, z['strada'], z.get('riga_fondo', 26))
        via &= ~acqua
        out[via] = col[via]
        duro |= via
    out, ombra = pg.ombre(out, tutte)
    rr._salva(out, os.path.join(LIV, nome + '.png'))
    # dove si cammina: non nell'acqua, non sulle impronte, non sul bordo; il ruscello che esce dalla mappa non si
    # passa a guado
    cammino = pg.passi(tutte, misura=(H, W))
    cammino[acqua] = 0
    cammino[parete | alto] = 0                            # la parete e il ripiano (non ci si sale)
    cammino[acque] = 0
    for (x0, y0, x1, y1) in z.get('chiusi', []):
        cammino[y0:y1, x0:x1] = 0
    for (x0, y0, x1, y1) in z.get('aperti', []):          # i passaggi verso le altre zone, anche sul bordo
        blocco = cammino[y0:y1, x0:x1]
        libero = ~acqua[y0:y1, x0:x1]
        blocco[libero] = (255, 255, 255, 255)
    rr._salva(cammino, os.path.join(LIV, nome + '_passi.png'))
    q = np.rint(out).astype(int)
    erba = np.zeros((H, W), bool)
    for col in PRATO.values():
        erba |= np.all(q == np.array(col), axis=-1)
    erba &= ~duro
    pr = np.zeros((H, W, 4), np.uint8); pr[erba] = (255, 255, 255, 255)
    rr._salva(pr, os.path.join(LIV, nome + '_prato.png'))
    # i fiori in piedi (come al pasto), non sull'acqua ne' sulla strada
    macchie = _prato.liscio(H, W, 170, 110, z['seme'] + 7)
    q1, q2 = np.quantile(macchie, [0.62, 0.86])
    nomi = list(_fiori.SPECIE)
    ok = pg.passi(tutte, bordi=False, misura=(H, W))[..., 3] > 0
    fiori = []
    rf = np.random.default_rng(z['seme'] + 3)
    for (y, x, _g) in segni:
        piccolo = rf.random() < 0.45
        if y < 14 or x < 6 or x > W - 7 or y > H - 3:
            continue
        if not erba[y - 10:y + 2, x - 6:x + 7].all() or ombra[y - 3:y + 2, x - 4:x + 5].any() or not ok[y, x]:
            continue
        n = macchie[y, x]
        sp = 'margherita' if n < q1 else ('ranuncolo' if n < q2 else 'salvia')
        if piccolo:
            sp = {'margherita': 'margheritina', 'ranuncolo': 'ranuncolino', 'salvia': 'salvietta'}[sp]
        fiori.append([int(x), int(y), nomi.index(sp)])
    fiori.sort(key=lambda f: (f[1], f[0]))
    with open(os.path.join(LIV, nome + '_fiori.json'), 'w') as f:
        json.dump({"_nota": "Scritto da strumenti/livelli/scene_pianure.py: non toccare a mano.", "fiori": fiori}, f)
        f.write('\n')
    with open(os.path.join(LIV, nome + '_pezzi.json'), 'w') as f:
        json.dump({"_nota": "Scritto da strumenti/livelli/scene_pianure.py: non toccare a mano. Ogni pezzo e' [file "
                            "(da art/livelli/), x, y del piede nel mondo, x, y del piede nel disegno].",
                   "pezzi": [[t[1], int(t[2]), int(t[3]), int(t[4][0]), int(t[4][1])]
                             for t in sorted(tutte, key=lambda t: t[3])]}, f, indent=1, ensure_ascii=False)
        f.write('\n')
    pianta = {
        "_nota": z['nota'], "nome": z['nome'],
        "mappa": nome + ".png", "scala": 1, "pixel": 1, "ingrandimento": 2,
        "pezzi": nome + "_pezzi.json", "passi": nome + "_passi.png", "prato": nome + "_prato.png",
        "fiori": nome + "_fiori.json",
        "animati": {REL + n + '.png': {"file": REL + n + '_fotogrammi.png', "n": k, "ms": ms}
                    for (n, k, ms) in z.get('animati', [])},
        "limiti": [0, 0, W, H], "partenza": z['partenza'], "verso": z['verso'], "stanze": z['stanze'],
    }
    with open(os.path.join(LIV, nome + '.json'), 'w') as f:
        json.dump(pianta, f, indent=1, ensure_ascii=False)
        f.write('\n')
    if anteprime:
        a = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).convert('RGBA')
        for t in sorted(tutte, key=lambda t: t[3]):
            im = Image.open(os.path.join(LIV, t[1])).convert('RGBA')
            a.alpha_composite(im, (int(t[2] - t[4][0]), int(t[3] - t[4][1])))
        a.convert('RGB').save(os.path.join(anteprime, nome + '.png'))
    print('%s: %dx%d, %d cose in piedi, %d fiori' % (nome, W, H, len(tutte), len(fiori)))


# ---------------------------------------------------------------- la scena dell'albero
# docs/storia.md: "L'albero. Uno slime distratto da piccoli animali: l'imboscata la potresti tendere tu, ma la Guida
# parla troppo forte e lo slime ti nota". docs/mondi.md: "l'albero: il suo piede, accanto alla cascatella"; "la caverna
# segreta: dietro l'albero, dove guardava lo slime: la vede solo chi osserva la scena".
# La strada e il ruscello arrivano da sud dove lasciano in cima il ruscello (la strada a x 599-628, il ruscello a x
# 1025-1085, misurati su ruscello.png); il ruscello nasce dalla cascatella, che cade da una rupe in alto a destra; il
# grande albero sta accanto alla cascatella, e dietro (a nord, coperta dalla chioma) c'e' l'entrata della caverna;
# davanti, fra le radici, i coniglietti e lo slime che li guarda. La strada va avanti a nord, verso il masso.
def prepara_albero():
    cascata('cascatella', 40)
    albero_gigante()
    slime()
    coniglio(1, ((166, 120, 92), (206, 162, 124)))
    coniglio(2, ((196, 176, 150), (232, 216, 192)))


def ripiano_albero(H):
    """il ripiano in alto a destra, da dove scende la cascatella: il bordo passa dietro il grande albero"""
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    bordo = 252 + 22 * np.sin((xx - 700) / 140.0) + 8 * np.sin(xx / 37.0) - 0.10 * (xx - 700)
    n = (_prato.liscio(H, W, 20, 20, 13) - 0.5) * 12
    # a ponente il ripiano finisce dritto (il lato si vede come una riga), coperto in basso da un cespuglio
    return (xx > 696) & (yy < bordo + n)


SCENE = {
    'albero': {
        'H': 720, 'seme': 97, 'nome': "L'albero",
        'strada': [(613.5, 760), (613.5, 700), (604, 600), (580, 480), (552, 360), (528, 240), (510, 120),
                   (504, 0), (503, -40)],
        'riga_fondo': 26,
        'ripiano': ripiano_albero, 'faccia': 42,
        'caverne': [(872, 30, 30)],
        'ruscelli': [([(1010, 300), (1012, 340), (1036, 440), (1056, 560), (1055, 650), (1055, 760)], (36, 60)),
                     ([(1060, -40), (1050, 60), (1022, 150), (1012, 230), (1010, 280)], (30, 22))],
        'pozze': [(1012, 318, 40, 20)],
        'alberi': [('albero_alto_dritto_1', 96, 150), ('albero_alto_dritto_3', 300, 118), ('albero_alto_4', 54, 420),
                   ('albero_alto_2', 150, 700), ('albero_alto_1', 380, 712), ('albero_alto_3', 1236, 470),
                   ('albero_alto_4', 1180, 712), ('albero_alto_dritto_2', 1160, 150), ('albero_alto_dritto_1', 830, 96),
                   ('cespuglio_1', 240, 330), ('cespuglio_2', 330, 560), ('cespuglietto_1', 700, 640),
                   ('cespuglio_2', 1210, 330), ('cespuglietto_1', 900, 700), ('cespuglio_1', 1236, 640),
                   ('cespuglietto_1', 940, 200), ('cespuglio_2', 704, 300)],
        'sassi': [('sasso_4', 420, 450), ('sassolino_2', 436, 456), ('sasso_5', 1110, 560), ('sassolino_1', 1124, 566),
                  ('masso_basso_4', 210, 520), ('sasso_2', 950, 600), ('sasso_4', 1084, 344)],
        'nuovi': [('cascatella', 1010, 314, (0, 0)), ('albero_alto_gigante', 846, 372, (30, 9)),
                  ('slime', 742, 486, (11, 4)), ('coniglio_1', 806, 432, (0, 0)), ('coniglio_2', 836, 446, (0, 0))],
        'animati': [('cascatella', 6, 90), ('slime', 4, 190), ('coniglio_1', 2, 520), ('coniglio_2', 2, 680)],
        'aperti': [(560, 690, 680, 720), (470, 0, 540, 90)],
        'partenza': [613, 690], 'verso': [0, -1],
        'stanze': [{"nome": "Il grande albero", "rett": [660, 300, 1000, 520]},
                   {"nome": "La cascatella", "rett": [960, 260, 1100, 380]},
                   {"nome": "Dal ponte", "rett": [540, 560, 700, 720]},
                   {"nome": "Verso il masso", "rett": [440, 0, 600, 200]},
                   {"nome": "L'albero", "rett": [0, 0, W, 720]}],
        'nota': "La scena dell'albero, fatta da strumenti/livelli/scene_pianure.py: il grande albero accanto alla "
                "cascatella da cui nasce il ruscello, lo slime distratto dai coniglietti, l'entrata della caverna "
                "nascosta nella parete dietro l'albero; la strada va a nord verso il masso.",
    },
}
PREPARA = {'albero': prepara_albero}


if __name__ == '__main__':
    args = sys.argv[1:]
    anteprime = args[0] if args and os.path.isdir(args[0]) else None
    quali = [a for a in args if a in SCENE] or list(SCENE)
    for n in quali:
        PREPARA[n]()
        fai_scena(n, SCENE[n], anteprime)
