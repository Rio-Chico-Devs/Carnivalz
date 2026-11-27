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



# ---------------------------------------------------------------- altre cose del terreno
TERRA = [(78, 70, 62), (108, 96, 78), (138, 124, 96), (166, 152, 116), (194, 180, 140)]  # la terra battuta
LEGNO_TAV = None


def _legno():
    global LEGNO_TAV
    if LEGNO_TAV is None:
        LEGNO_TAV = [tuple(int(v) for v in c) for c in pt.TRONCO]
    return LEGNO_TAV


CORTECCIA = [(44, 32, 40), (70, 50, 52), (98, 72, 66), (128, 98, 82), (158, 128, 102), (190, 162, 128)]


def tubo(out, punti, larghi, rng, rampa=None, nodi=0.0, contorno=True, dove=None):
    """un tubo lungo la curva (radici, rami, tronchi): largo da larghi[0] in fondo a larghi[1] in cima (con qualche
    nodo che si gonfia), le facce che guardano la luce (in alto a sinistra) chiare, quelle in ombra scure, a masse di
    pochi toni; il contorno scuro. Ritorna dove ha dipinto"""
    rampa = rampa or _legno()
    H_, W_ = out.shape[:2]
    lin, u = rr.curva(punti)
    n = len(lin)
    tot = max(1.0, u[-1])
    gonfi = np.ones(n)
    if nodi > 0:
        for _ in range(int(rng.integers(1, 4))):
            c, ampio = rng.uniform(0.2, 0.9), rng.uniform(0.04, 0.1)
            gonfi += nodi * np.exp(-((u / tot - c) / ampio) ** 2)
    r = (larghi[0] + (larghi[1] - larghi[0]) * (u / tot)) / 2.0 * gonfi
    x0, x1 = int(lin[:, 0].min() - r.max() - 2), int(lin[:, 0].max() + r.max() + 3)
    y0, y1 = int(lin[:, 1].min() - r.max() - 2), int(lin[:, 1].max() + r.max() + 3)
    x0, y0, x1, y1 = max(0, x0), max(0, y0), min(W_, x1), min(H_, y1)
    if x0 >= x1 or y0 >= y1:
        return np.zeros((H_, W_), bool)
    bh, bw = y1 - y0, x1 - x0
    best = np.full((bh, bw), np.inf)
    ox = np.zeros((bh, bw))
    oy = np.zeros((bh, bw))
    rr_ = np.zeros((bh, bw))
    for k in range(0, n, 1):
        px, py, rk = lin[k, 0], lin[k, 1], r[k]
        a0, a1 = max(y0, int(py - rk - 1)), min(y1, int(py + rk + 2))
        b0, b1 = max(x0, int(px - rk - 1)), min(x1, int(px + rk + 2))
        if a0 >= a1 or b0 >= b1:
            continue
        Y, X = np.mgrid[a0:a1, b0:b1]
        dx, dy = X - px, Y - py
        d = np.hypot(dx, dy) / rk                      # quanto e' dentro (0 sull'asse, 1 sul bordo)
        sub = best[a0 - y0:a1 - y0, b0 - x0:b1 - x0]
        m = d < sub
        sub[m] = d[m]
        ox[a0 - y0:a1 - y0, b0 - x0:b1 - x0][m] = dx[m]
        oy[a0 - y0:a1 - y0, b0 - x0:b1 - x0][m] = dy[m]
        rr_[a0 - y0:a1 - y0, b0 - x0:b1 - x0][m] = rk
    dentro = best <= 1.0
    if dove is not None:
        dentro &= dove[y0:y1, x0:x1]
    nx, ny = ox / (rr_ + 1e-6), oy / (rr_ + 1e-6)
    luce = -(nx * -0.6 + ny * -0.8)                    # 1 dove la faccia guarda la luce
    luce = -luce
    nt = len(rampa)
    k = np.where(luce > 0.45, nt - 2, np.where(luce > 0.0, nt - 3, np.where(luce > -0.5, nt - 4, nt - 5)))
    k = np.clip(k, 1, nt - 1)
    # il filo di luce in cima (le facce piu' esposte) e le crepe lungo
    k[(luce > 0.75) & (best < 0.85)] = nt - 1
    blocco = out[y0:y1, x0:x1]
    for i in range(nt):
        blocco[dentro & (k == i)] = rampa[i]
    pieno = np.zeros((H_, W_), bool)
    pieno[y0:y1, x0:x1] = dentro
    if contorno:
        pad = np.pad(pieno, 1)
        bordo = pieno & (~pad[:-2, 1:-1] | ~pad[2:, 1:-1] | ~pad[1:-1, :-2] | ~pad[1:-1, 2:])
        out[bordo] = rampa[0]
    return pieno


def sentiero(H, punti, largo, rng, tenue=False):
    """un sentiero di terra battuta lungo la curva: il bordo mangiato dall'erba (ciuffi che entrano), la terra a
    chiazze di due toni coi sassolini. 'tenue': solo una scia d'erba pestata (piu' scura) e qualche chiazza di terra,
    l'impronta di chi ci passa ogni tanto"""
    lin, u = rr.curva(punti)
    D, S, V = rr.campo(lin, u, largo + 6, H, 0)
    n = _prato.liscio(H, W, 6, 6, int(rng.integers(1000))) - 0.5
    n2 = _prato.liscio(H, W, 3, 3, int(rng.integers(1000)))
    m = D + n * (6 if not tenue else 8) < largo / 2.0
    col = np.zeros((H, W, 3))
    if tenue:
        pestata = m & (n2 > 0.35)
        terra = m & (n2 > 0.72)
        return pestata, terra
    col[m] = TERRA[2]
    col[m & (n2 > 0.62)] = TERRA[3]
    col[m & (n2 < 0.25)] = TERRA[1]
    bordo = m & (D + n * 6 > largo / 2.0 - 2)
    col[bordo] = TERRA[1]
    ys, xs = np.nonzero(m)
    for i in rng.permutation(len(ys))[:len(ys) // 60]:
        y, x = ys[i], xs[i]
        col[y, x] = SASSOLINI[2]
        if y + 1 < H and m[y + 1, x]:
            col[y + 1, x] = SASSOLINI[0]
    return m, col


def rompi(via, rng, quanto=0.16, seme=3):
    """la strada antica rotta: buchi dove i mattoni mancano (ci cresce l'erba)"""
    H_ = via.shape[0]
    n = _prato.liscio(H_, W, 7, 5, seme)
    buchi = via & (n > 1 - quanto)
    return via & ~buchi


def radici_a_terra(out, x0, y0, radici, rng, acque=None):
    """le radici del grande albero sul prato: tubi grossi e storti che si assottigliano e finiscono sotto terra, coi
    nodi; ognuna (angolo in gradi, lunga, grossa, quanto curva). Sull'acqua (il ponte di radice) fanno l'ombra sotto"""
    pieno = np.zeros(out.shape[:2], bool)
    for (ang, lungo, grosso, curva) in radici:
        a0 = np.radians(ang)
        p0 = (x0 + np.cos(a0) * grosso * 0.4, y0 + np.sin(a0) * grosso * 0.2)
        a1 = a0 + curva
        p1 = (p0[0] + np.cos(a0) * lungo * 0.45, p0[1] + np.sin(a0) * lungo * 0.45 * 0.6)
        p2 = (p1[0] + np.cos(a1) * lungo * 0.55, p1[1] + np.sin(a1) * lungo * 0.55 * 0.6)
        pm = (p0[0] * 0.2 + p1[0] * 0.8, p0[1] * 0.2 + p1[1] * 0.8 - grosso * 0.15)
        m = tubo(out, [p0, pm, p1, p2], (grosso, max(3, grosso * 0.18)), rng, nodi=0.25)
        pieno |= m
    # l'ombra delle radici sotto: sul prato un gradino, sull'acqua una fascia scura (la radice sta sopra)
    giu = np.zeros(out.shape[:2], int)
    for k in range(1, 4):
        giu[_sposta(pieno, k, 0) & ~pieno & (giu == 0)] = 1
    if acque is not None:
        sull_acqua = np.zeros(out.shape[:2], bool)
        for k in range(1, 9):
            sull_acqua |= _sposta(pieno, k, k // 3)
        sull_acqua &= acque & ~pieno
        out[sull_acqua] = ACQUA['bordo0']
        giu[sull_acqua] = 0
    pg.scendi(out, giu)
    mus = [tuple(int(v) for v in c) for c in _tav.tavolozze()['muschio']]
    ys, xs = np.nonzero(pieno)
    for i in rng.permutation(len(ys))[:len(ys) // 40]:
        y, x = ys[i], xs[i]
        for (a, b) in ((0, 0), (0, 1), (-1, 0)):
            if pieno[min(y + a, pieno.shape[0] - 1), min(x + b, pieno.shape[1] - 1)]:
                out[y + a, x + b] = mus[3]
    return pieno


def ninfee(out, posti, rng):
    """le foglie di ninfea sull'acqua (un ovale col taglio, chiaro sopra e scuro sotto), qualcuna col fiore"""
    ch = [tuple(int(v) for v in c) for c in _tav.tavolozze()['chioma']]
    rosa = [(219, 95, 161), (254, 147, 164)]
    for (cx, cy, r, fiore) in posti:
        for y in range(int(cy - r), int(cy + r) + 1):
            for x in range(int(cx - r * 1.4), int(cx + r * 1.4) + 1):
                dx, dy = (x - cx) / (r * 1.4), (y - cy) / r
                d = dx * dx + dy * dy
                ang = np.degrees(np.arctan2(dy, dx))
                if d <= 1 and not (-25 < ang < 5 and d > 0.05):
                    c = ch[3] if dy < -0.2 else (ch[2] if dy < 0.45 else ch[1])
                    if d > 0.72:
                        c = ch[1] if dy > 0 else ch[2]
                    out[y, x] = c
        if fiore:
            out[int(cy) - 1, int(cx) - 1] = rosa[1]
            out[int(cy) - 1, int(cx)] = rosa[1]
            out[int(cy), int(cx) - 1] = rosa[0]
            out[int(cy) - 2, int(cx)] = (252, 255, 232)


def guado(out, posti):
    """i sassi piatti nell'acqua per passare: chiari sopra, scuri sotto, la schiuma attorno; ritorna dove si cammina"""
    H_, W_ = out.shape[:2]
    m = np.zeros((H_, W_), bool)
    P = [tuple(int(v) for v in c) for c in _tav.tavolozze()['pietra']]
    for (cx, cy, rx, ry) in posti:
        for y in range(int(cy - ry - 2), int(cy + ry + 3)):
            for x in range(int(cx - rx - 2), int(cx + rx + 3)):
                if not (0 <= y < H_ and 0 <= x < W_):
                    continue
                d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                if d <= 1:
                    dy = (y - cy) / ry
                    out[y, x] = P[4] if dy < -0.3 else (P[3] if dy < 0.4 else P[1])
                    if d > 0.75 and dy > 0:
                        out[y, x] = P[0]
                    m[y, x] = True
                elif d <= 1.5 and y > cy - ry * 0.3:
                    out[y, x] = ACQUA['schiuma'] if (x + y) % 3 else ACQUA['orlo']
    # dove si cammina: i sassi e un pixel attorno (il passo e' lungo)
    return _prato.distanza(m, 3) <= 3


def erba_alta(out, ciuffi, rng):
    """l'erba alta: fitti fili verticali piu' scuri, a ciuffi, con le punte chiare"""
    H_, W_ = out.shape[:2]
    for (cx, cy, rx, ry, quanti) in ciuffi:
        for _ in range(quanti):
            x = int(cx + rng.normal(0, rx / 2.0))
            y = int(cy + rng.normal(0, ry / 2.0))
            alto = int(rng.integers(4, 8))
            for j in range(alto):
                yy = y - j
                if 0 <= yy < H_ and 0 <= x < W_:
                    out[yy, x] = PRATO['scuro'] if j < 2 else (PRATO['medio'] if j < alto - 1 else PRATO['base'])
            if 0 <= y + 1 < H_ and 0 <= x < W_:
                out[y + 1, x] = PRATO['profondo']


def funghi(out, posti, rng):
    """i funghetti a gruppetti: il cappello rosso coi puntini, il gambo crema"""
    H_, W_ = out.shape[:2]
    rosso = [(139, 48, 72), (196, 70, 82), (232, 118, 104)]
    gambo = [(186, 168, 140), (236, 222, 196)]
    for (cx, cy, n) in posti:
        for k in range(n):
            x = int(cx + rng.integers(-6, 7))
            y = int(cy + rng.integers(-3, 4))
            forma = ['.rrr.', 'rRwRr', 'kkkkk', '..g..', '..G..'] if k % 2 == 0 else ['.rr.', 'rwRr', 'kkkk', '.g..']
            for j, riga in enumerate(forma):
                for i, c in enumerate(riga):
                    yy, xx = y - len(forma) + 1 + j, x - len(riga) // 2 + i
                    if c == '.' or not (0 <= yy < H_ and 0 <= xx < W_):
                        continue
                    out[yy, xx] = {'r': rosso[1], 'R': rosso[2], 'w': (252, 248, 236), 'k': rosso[0],
                                   'g': gambo[1], 'G': gambo[0]}[c]


def tronco_caduto(lungo=280, grosso=40, seme=5):
    """un vecchio albero caduto, steso nel prato di traverso, a volume: la corteccia grigio-bruna (un albero morto da
    tempo), chiara sopra e scura sotto, i nodi, le macchie di muschio sopra; a sinistra la zolla delle radici divelta
    (la terra scura e le radici che escono a raggiera), a destra la punta spezzata chiara e due rami secchi"""
    rng = np.random.default_rng(seme)
    mus = [tuple(int(v) for v in c) for c in _tav.tavolozze()['muschio']]
    zr = int(grosso * 0.95)                           # il raggio della zolla
    Hh, Ww = 2 * zr + 12, lungo + zr + 40
    img = np.zeros((Hh, Ww, 3))
    op = np.zeros((Hh, Ww), bool)
    base = Hh - 4
    xz = zr + 4                                       # il mezzo della zolla
    # la zolla: un disco di terra scura, la luce in alto a destra (dove la terra e' girata verso il cielo)
    yy, xx = np.mgrid[0:Hh, 0:Ww]
    n_ = _prato.liscio(Hh, Ww, 4, 4, seme) - 0.5
    cz = base - zr
    dz = np.hypot((xx - xz) / (zr * 0.8), (yy - cz) / zr) + n_ * 0.35
    zolla = dz <= 1
    img[zolla] = TERRA[1]
    img[zolla & (dz < 0.6)] = TERRA[0]
    img[zolla & (xx > xz + zr * 0.15) & (yy < cz)] = TERRA[2]
    op |= zolla
    # le radici che escono dalla zolla, a raggiera (tubi sottili)
    for k in range(9):
        a = -np.pi * 0.95 + k * (np.pi * 1.9 / 8) + rng.uniform(-0.15, 0.15)
        L_ = zr * rng.uniform(0.9, 1.4)
        p0 = (xz + np.cos(a) * zr * 0.5, cz + np.sin(a) * zr * 0.6)
        p1 = (xz + np.cos(a + 0.2) * L_, cz + np.sin(a + 0.2) * L_ * 0.9)
        p2 = (xz + np.cos(a + 0.35) * (L_ + 6), cz + np.sin(a + 0.35) * (L_ + 6) * 0.9)
        op |= tubo(img, [p0, p1, p2], (5, 2), rng, rampa=CORTECCIA)
    # il tronco: un tubo dritto che si assottiglia
    yt = base - grosso / 2.0
    op |= tubo(img, [(xz + zr * 0.5, yt), (xz + zr * 0.5 + lungo * 0.5, yt + 1), (xz + zr * 0.5 + lungo, yt + 3)],
               (grosso, grosso * 0.62), rng, rampa=CORTECCIA, nodi=0.12)
    # le crepe lunghe della corteccia (trattini scuri lungo il tronco) e il muschio a macchie sopra
    xt0, xt1 = int(xz + zr * 0.6), int(xz + zr * 0.5 + lungo - 6)
    for _ in range(int(lungo / 5)):
        x = int(rng.integers(xt0, xt1))
        r_ = grosso / 2.0 * (1 - 0.38 * (x - xt0) / max(1, xt1 - xt0))
        y = int(yt + rng.uniform(-0.55, 0.6) * r_)
        for i in range(int(rng.integers(3, 8))):
            if 0 <= x + i < Ww and op[y, x + i]:
                img[y, x + i] = CORTECCIA[1]
    for _ in range(7):
        x = int(rng.integers(xt0, xt1 - 10))
        r_ = grosso / 2.0 * (1 - 0.38 * (x - xt0) / max(1, xt1 - xt0))
        ytop = int(yt - r_) + 1
        w_ = int(rng.integers(6, 14))
        for i in range(w_):
            for j in range(int(rng.integers(2, 4))):
                if op[ytop + j, x + i]:
                    img[ytop + j, x + i] = mus[3] if j == 0 else mus[2]
    # la punta spezzata: le schegge chiare; due rami secchi
    chiaro = [(236, 214, 170), (206, 176, 132)]
    xe = int(xz + zr * 0.5 + lungo)
    for j in range(-int(grosso * 0.3), int(grosso * 0.3)):
        for i in range(int(rng.integers(1, 5))):
            x, y = xe - 3 + i, int(yt + 3 + j)
            if 0 <= x < Ww and 0 <= y < Hh:
                img[y, x] = chiaro[(i + j) % 2]
                op[y, x] = True
    for (a, L_) in ((-0.6, 22), (-1.1, 16)):
        x0 = xe - int(lungo * 0.2)
        p0 = (x0, yt - grosso * 0.25)
        op |= tubo(img, [p0, (p0[0] + np.cos(a) * L_ * 0.6, p0[1] + np.sin(a) * L_ * 0.6),
                         (p0[0] + np.cos(a - 0.3) * L_, p0[1] + np.sin(a - 0.3) * L_)], (4, 2), rng, rampa=CORTECCIA)
    a = np.zeros((Hh, Ww, 4), float)
    a[op, :3] = img[op]
    a[op, 3] = 255
    pad = np.pad(op, 1)
    bordo = op & (~pad[:-2, 1:-1] | ~pad[2:, 1:-1] | ~pad[1:-1, :-2] | ~pad[1:-1, 2:])
    a[bordo, :3] = CORTECCIA[0]
    _salva_pezzo('tronco_caduto', a, (int(xz + zr * 0.5 + lungo * 0.5), base))
    return a


def cespuglione(alto=104, seme=31):
    """un cespuglio grande e fitto (dei nostri), per coprire la bocca della grotta"""
    a = pt.cespuglio(alto, seme)
    ys, xs = np.nonzero(a[..., 3] > 0)
    a = rr.fondi(a.astype(float), True)
    _salva_pezzo('cespuglione', a, (int(round(xs[ys >= ys.max() - 3].mean())), int(ys.max())))
    return a


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
    for i, (cx, cy, rx, ry) in enumerate(z.get('pozze', [])):
        # mai un ovale perfetto: tre ovali che si toccano e il bordo mosso
        n_ = _prato.liscio(H, W, 9, 9, z['seme'] + 50 + i) - 0.5
        pz = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 + n_ * 0.7 <= 1
        pz |= ((xx - cx + rx * 0.45) / (rx * 0.6)) ** 2 + ((yy - cy - ry * 0.3) / (ry * 0.75)) ** 2 + n_ * 0.7 <= 1
        pz |= ((xx - cx - rx * 0.4) / (rx * 0.55)) ** 2 + ((yy - cy + ry * 0.25) / (ry * 0.7)) ** 2 + n_ * 0.7 <= 1
        acque |= pz
    parete = np.zeros((H, W), bool)
    alto = np.zeros((H, W), bool)
    ripiani = list(z.get('ripiani', []))
    if 'ripiano' in z:
        ripiani.insert(0, (z['ripiano'], z.get('faccia', 40), z.get('caverne', ())))
    alti = [f(H) for (f, _, _) in ripiani]
    for a_ in alti:
        alto |= a_
    if acque.any():
        riva, col = disegna_acqua(H, acque, rng)
        m = acque | riva
        out[m] = col[m]
        duro |= m
    # l'erba pestata e la terra delle scie (prima delle rupi: sul ripiano non ci sono)
    for (punti, largo) in z.get('scie', []):
        pestata, terra = sentiero(H, punti, largo, rng, tenue=True)
        pestata &= ~acque
        pg.scendi(out, pestata.astype(int))
        out[terra & ~acque] = TERRA[2]
    for (punti, largo) in z.get('sentieri', []):
        m, col = sentiero(H, punti, largo, rng)
        m &= ~acque
        out[m] = col[m]
        duro |= m
    if 'strada' in z:
        via, col = strada(H, z['strada'], z.get('riga_fondo', 26))
        via &= ~acque
        if z.get('rotta'):
            via = rompi(via, rng, z['rotta'], z['seme'])
        out[via] = col[via]
        duro |= via
    ponti = np.zeros((H, W), bool)
    for (x0, y0, rad) in z.get('radici', []):
        duro |= radici_a_terra(out, x0, y0, rad, rng)
    for (punti, larghi) in z.get('ponti_radice', []):
        # una radice enorme che scavalca l'acqua: grossa per tutta la campata, sotto la sua ombra sull'acqua
        r_ = tubo(out, punti, larghi, rng, nodi=0.18)
        sull_acqua = np.zeros((H, W), bool)
        for k in range(1, 10):
            sull_acqua |= _sposta(r_, k, k // 3)
        sull_acqua &= acque & ~r_
        out[sull_acqua] = ACQUA['bordo0']
        duro |= r_
        ponti |= _prato.distanza(r_, 3) <= 3
    erba_alta(out, z.get('erba_alta', []), rng)
    funghi(out, z.get('funghi', []), rng)
    for (f, faccia, caverne), a_ in zip(ripiani, alti):
        par, labbro, bocche = rupe(out, a_, faccia, rng, caverne, z['seme'])
        parete |= par
        duro |= par | labbro
    acqua = acque & ~parete
    ninfee(out, z.get('ninfee', []), rng)
    passa = guado(out, z.get('guado', [])) | ponti
    out, ombra = pg.ombre(out, tutte)
    rr._salva(out, os.path.join(LIV, nome + '.png'))
    # dove si cammina: non nell'acqua, non sulle impronte, non sul bordo; il ruscello che esce dalla mappa non si
    # passa a guado
    cammino = pg.passi(tutte, misura=(H, W))
    cammino[acqua] = 0
    cammino[parete | alto] = 0                            # la parete e il ripiano (non ci si sale)
    cammino[acque & ~passa] = 0
    cammino[passa & (cammino[..., 3] == 0) & ~parete & ~alto] = (255, 255, 255, 255)
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
    cascata('cascatella_alta', 32, larga=18)
    # il grande albero senza le sue radici sottili (a questa misura sembrano lance): le radici le mette la mappa,
    # grosse e storte, sul prato (radici_a_terra)
    radice = pt._radice
    pt._radice = lambda *a_, **k_: None
    a, piede = pt.albero_esotico(430, 29, con_piede=True)
    pt._radice = radice
    _salva_pezzo('albero_alto_gigante', rr.fondi(a.astype(float), True), piede)
    tronco_caduto()
    cespuglione()
    slime()
    coniglio(1, ((166, 120, 92), (206, 162, 124)))
    coniglio(2, ((196, 176, 150), (232, 216, 192)))
    ricalcato('ceppo_1', {'chioma': 'muschio', 'pietra': 'tronco', 'oro': 'muschio'})


H_ALBERO = 1080


def _bordo(xx, base, a1, p1, a2, p2, pend, x0):
    return base + a1 * np.sin((xx - x0) / p1) + a2 * np.sin(xx / p2) - pend * (xx - x0)


def ripiano_basso(H):
    """il ripiano in alto a destra (il primo salto della cascatella cade qui): il bordo mosso passa dietro il grande
    albero; a ponente finisce dritto, coperto dagli alberi"""
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    n = (_prato.liscio(H, W, 20, 20, 13) - 0.5) * 12
    return (xx > 700) & (yy < _bordo(xx, 336, 20, 130.0, 8, 31.0, 0.05, 700) + n)


def ripiano_alto(H):
    """il ripiano piu' alto, nell'angolo: da qui viene il ruscello"""
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    n = (_prato.liscio(H, W, 16, 16, 19) - 0.5) * 10
    return (xx > 990) & (yy < _bordo(xx, 176, 14, 90.0, 5, 23.0, 0.03, 990) + n)


def spuntone(H):
    """lo spuntone di roccia all'ingresso: un dosso coi cespugli sopra che nasconde la vista; la strada lo aggira"""
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    n = (_prato.liscio(H, W, 14, 14, 23) - 0.5) * 0.5
    return ((xx - 724) / 118.0) ** 2 + ((yy - 962) / 48.0) ** 2 + n < 1.0


def _piede_parete(alto, x, faccia):
    col = np.nonzero(alto[:, x])[0]
    return int(col.max()) + faccia + 1


def config_albero():
    H = H_ALBERO
    basso, alto2 = ripiano_basso(H), ripiano_alto(H)
    basso |= alto2
    yc1 = _piede_parete(alto2, 1094, 32)              # dove cade il primo salto (sul ripiano basso)
    yc2 = _piede_parete(basso, 1050, 42)              # dove cade il secondo (sul prato, nella pozza)
    yb = _piede_parete(basso, 806, 42)                # il piede della parete dove c'e' la bocca della grotta
    rad = [(178, 170, 30, 0.28), (150, 120, 24, -0.3), (122, 104, 22, 0.25), (92, 84, 20, -0.2),
           (62, 112, 22, -0.28), (30, 120, 24, -0.3), (200, 110, 20, -0.35), (338, 90, 18, 0.32)]
    return {
        'H': H, 'seme': 97, 'nome': "L'albero",
        'ripiani': [(lambda H_: basso, 42, [(806, 28, 28)]), (lambda H_: alto2, 32, ()), (spuntone, 26, ())],
        'strada': [(613.5, 1120), (613.5, 1060), (592, 1000), (548, 945), (492, 880), (452, 800), (430, 712),
                   (424, 620), (432, 530), (452, 440), (480, 350), (502, 262), (514, 170), (520, 80), (522, 0),
                   (523, -40)],
        'riga_fondo': 26, 'rotta': 0.14,
        # la deviazione: la strada e' interrotta dall'albero caduto, il sentiero gira dalla radura dello slime e torna
        # sulla strada di la' dal tronco
        'sentieri': [([(436, 724), (512, 720), (590, 708), (650, 690), (690, 650), (702, 600), (688, 540),
                       (652, 490), (592, 452), (522, 436), (462, 430)], 17)],
        # l'impronta di chi ci passa ogni tanto: dal sentiero, dietro le radici, fino al fianco del cespuglio
        'scie': [([(702, 600), (740, 546), (768, 486), (782, 436), (786, 414)], 9)],
        'ruscelli': [([(1052, yc2), (1060, yc2 + 70), (1104, 520), (1132, 620), (1104, 740), (1064, 860),
                       (1052, 980), (1055, 1120)], (34, 60)),
                     ([(1094, yc1), (1086, yc1 + 40), (1066, 300), (1052, yc2 - 30)], (22, 24)),
                     ([(1130, -40), (1120, 60), (1102, 130), (1094, yc1 - 20)], (24, 22))],
        'pozze': [(1040, yc2 + 30, 74, 32), (1092, yc1 + 18, 30, 12)],
        'ninfee': [(1006, yc2 + 30, 5, True), (1022, yc2 + 46, 4, False), (1072, yc2 + 40, 5, False),
                   (994, yc2 + 44, 4, False), (1060, yc2 + 22, 4, True), (1088, yc2 + 30, 3, False)],
        'radici': [(880, 520, rad)],
        # il ponte di radice: una radice enorme del grande albero scavalca il ruscello (ci si cammina sopra)
        'ponti_radice': [([(890, 520), (960, 512), (1040, 520), (1110, 532), (1168, 548), (1196, 560)], (30, 10))],
        'erba_alta': [(724, 706, 26, 14, 60), (650, 860, 50, 16, 70), (760, 760, 40, 12, 50), (360, 420, 40, 20, 60),
                      (1210, 640, 30, 16, 40), (560, 1000, 50, 16, 60)],
        'funghi': [(330, 590, 3), (612, 548, 2), (850, 566, 3), (930, 548, 2), (1228, 690, 3), (1190, 640, 2)],
        'alberi': [('cespuglio_1', 262, 572), ('cespuglio_2', 224, 612), ('cespuglietto_1', 296, 606),
                   ('cespuglio_1', 700, 950), ('cespuglietto_1', 766, 958), ('cespuglio_2', 1252, 600),
                   ('cespuglietto_1', 1206, 728),
                   ('albero_alto_dritto_1', 96, 170), ('albero_alto_dritto_3', 300, 128), ('albero_alto_4', 52, 470),
                   ('albero_alto_2', 160, 760), ('albero_alto_1', 300, 1060), ('albero_alto_3', 1236, 880),
                   ('albero_alto_4', 1170, 1070), ('albero_alto_dritto_2', 760, 240), ('albero_alto_dritto_1', 1180, 150),
                   ('albero_alto_2', 840, 1060), ('albero_alto_3', 120, 1010),
                   ('cespuglio_1', 250, 340), ('cespuglio_2', 330, 600), ('cespuglietto_1', 560, 760),
                   ('cespuglio_2', 1236, 470), ('cespuglietto_1', 960, 920), ('cespuglio_1', 1000, 1040),
                   ('cespuglietto_1', 640, 470), ('cespuglio_2', 716, 360), ('cespuglio_1', 360, 880),
                   ('cespuglietto_1', 1180, 560), ('cespuglio_2', 860, 820)],
        'sassi': [('sasso_4', 410, 470), ('sassolino_2', 426, 476), ('sasso_5', 1180, 760), ('sassolino_1', 1194, 766),
                  ('masso_basso_4', 230, 560), ('sasso_2', 980, 700), ('sasso_4', 1150, 520), ('masso_basso_4', 640, 930),
                  ('sasso_5', 760, 900), ('sassolino_3', 776, 906)],
        'nuovi': [('cascatella', 1050, yc2 + 2, (0, 0)), ('cascatella_alta', 1094, yc1 + 2, (0, 0)),
                  ('albero_alto_gigante', 880, 520, (44, 12)), ('cespuglione', 806, yb + 16, (40, 6)),
                  ('tronco_caduto', 470, 572, (150, 10)), ('ceppo_1', 1216, 664, (10, 4)),
                  ('slime', 762, 692, (11, 4)), ('coniglio_1', 812, 642, (0, 0)), ('coniglio_2', 842, 656, (0, 0))],
        'animati': [('cascatella', 6, 90), ('cascatella_alta', 6, 100), ('slime', 4, 190), ('coniglio_1', 2, 520),
                    ('coniglio_2', 2, 680)],
        'aperti': [(560, 1050, 680, 1080), (480, 0, 560, 90)],
        'partenza': [613, 1050], 'verso': [0, -1],
        'stanze': [{"nome": "Dal ponte", "rett": [520, 1000, 720, 1080]},
                   {"nome": "Lo spuntone", "rett": [520, 880, 860, 1000]},
                   {"nome": "La strada interrotta", "rett": [300, 500, 640, 620]},
                   {"nome": "La radura dello slime", "rett": [700, 600, 900, 760]},
                   {"nome": "Il grande albero", "rett": [740, 400, 1010, 580]},
                   {"nome": "La cascatella", "rett": [960, 300, 1180, 470]},
                   {"nome": "Il ponte di radice", "rett": [1010, 500, 1160, 580]},
                   {"nome": "Oltre il ruscello", "rett": [1150, 560, 1280, 740]},
                   {"nome": "Verso il masso", "rett": [440, 0, 600, 300]},
                   {"nome": "L'albero", "rett": [0, 0, W, H]}],
        'nota': "La scena dell'albero, fatta da strumenti/livelli/scene_pianure.py: dal ponte la strada antica, mezza "
                "rotta, gira attorno allo spuntone e al tronco caduto; un sentiero si stacca verso il grande albero e la "
                "radura dello slime e torna sulla strada piu' su (un anello); la cascatella scende a due salti, il "
                "ruscello gira attorno alle radici, coi sassi per passare dall'altra parte; la grotta e' dietro un "
                "cespuglio fitto, ai piedi della parete dietro l'albero.",
    }


SCENE = {'albero': config_albero}
PREPARA = {'albero': prepara_albero}


if __name__ == '__main__':
    args = sys.argv[1:]
    anteprime = args[0] if args and os.path.isdir(args[0]) else None
    quali = [a for a in args if a in SCENE] or list(SCENE)
    for n in quali:
        PREPARA[n]()
        z = SCENE[n]
        fai_scena(n, z() if callable(z) else z, anteprime)
