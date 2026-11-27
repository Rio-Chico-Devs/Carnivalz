# Il pasto del goblin: la seconda tappa delle pianure (docs/mondi.md: "il pasto del goblin, nel recinto di pietre a
# nord-est"; docs/storia.md: "una pressione strana, un posto tranquillo, poi gnarl... barf, crunch..."). Bru: "la zona
# del pasto del goblin dove il goblin e' al centro".
#
#   python3 strumenti/livelli/pasto_goblin.py [anteprima.png]      (serve numpy e Pillow)
#
# Una radura nel prato; al centro il goblin (strumenti/nemici/goblin_tipico), di spalle, curvo sulla preda che ha
# appena ucciso (un cinghiale steso sul fianco) e la divora (Bru: "e' intento a mangiare furiosamente, non c'e' bisogno
# di un fuoco o di ossa in giro, non e' che lui ha un accampamento, si e' trovato li', ha ucciso una preda e la sta
# mangiando"). Niente recinto di sassi (Bru: "non deve sembrare un'arena"). Il pavimento come la scena dopo (il ruscello,
# la pianura aperta): la strada di mattoni arriva da nord e finisce in un pezzo della piazza antica, le stesse lastre
# coi colori della mappa del ruscello (piazza_tavolozza.py), mezze mangiate dall'erba, coi ciuffi nelle fughe e sopra
# (Bru: "un po' di erba sopra le mattonelle per blendare bene"); la meta' di sud, da dove arriva Lei (dalla radura della
# Guida, arrivo.py), e' prato, senza sentiero. In cima la strada lascia la mappa dove la strada del ruscello entra in basso (stessa x, stessa
# direzione, stesso punto del motivo), cosi' le due scene si attaccano. Attorno il prato coi fiori al vento e gli alberi
# esotici, come al ruscello (stessi pezzi, stesso prato, stesse regole delle tavolozze di Bru).
#
# Scrive art/livelli/pasto.png (il terreno con le cose piatte: strada, lastre, ombre), pasto_pezzi.json (le cose
# in piedi), pasto_passi.png (dove si cammina), pasto_prato.png (dove i passi pestano l'erba), pasto_fiori.json,
# pasto.json; i pezzi nuovi in art/livelli/pezzi/pasto/ (il goblin che mangia e la preda, a fotogrammi).
import json
import os
import sys

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
sys.path.insert(0, os.path.join(QUI, '..'))
import ruscello_radenna as rr     # noqa: E402  i pezzi, il prato, le ombre e i contorni fusi del ruscello
import prato as _prato            # noqa: E402
import tavolozza as _tav          # noqa: E402
import fiori as _fiori            # noqa: E402
sys.path.insert(0, os.path.join(QUI, '..', 'nemici'))
import goblin_tipico as _gt       # noqa: E402  l'ingrandimento di una volta e mezza, come il goblin

LIV = rr.LIV
NUOVI = os.path.join(LIV, 'pezzi', 'pasto')
FUSI = 'pezzi/pasto/fusi/'
GOBLIN = os.path.join(QUI, '..', 'nemici', 'goblin_tipico', 'goblin_mangia.png')    # goblin_mangia.py
W, H = 1280, 800
PIAZZA_C = (640, 372)                   # il mezzo del pezzo di piazza antica, davanti alla strada
# la strada di mattoni verso la pianura aperta: parte dalla piazza antica, va a nord e lascia la mappa in alto
# dove la strada del ruscello (la scena dopo) entra in basso: la' la colonna 0 del motivo e' a x 595 (il mezzo a 609,5)
# e sull'ultima riga della mappa c'e' la riga 26 del motivo, che sale andando su; qui sulla prima riga ci va la 25.
# L'ultimo tratto va un filo verso destra salendo, come la' (misurato su ruscello.png)
STRADA = [(640, 330), (636, 290), (622, 200), (608, 120), (605, 60), (609.5, 0), (613, -35)]
STRADA_X0, STRADA_RIGA = 609.5, 25      # il mezzo della strada e la riga del motivo sulla prima riga della mappa
PRATO = rr.PRATO
OSSO = np.array(_tav.rampa((226, 214, 186), 4, 0.42, 0.95), float)
PELO = np.array(_tav.rampa((106, 84, 76), 4, 0.22, 0.60), float)            # il cinghiale: scuro, ombra, medio, luce
PANCIA = np.array(_tav.rampa((172, 134, 112), 2, 0.48, 0.70), float)
PIETRA = rr.P_NUOVA
# i mattoni della pianura: i sei colori del kit di Bru (terreni/strade_radenna, dal piu' scuro al piu' chiaro) vanno,
# nella mappa del ruscello, sui gradini 1-6 della rampa della pietra (riadatta(), controllato sulla mappa vera)
KIT = [(44, 71, 50), (66, 84, 69), (84, 103, 85), (108, 122, 105), (120, 135, 117), (141, 155, 135)]
MATTONI = PIETRA[1:7]

# ---------------------------------------------------------------- dove stanno le cose
GOBLIN_PIEDE = (640, 430)               # il goblin, al centro, di spalle a chi arriva da sud
PREDA_PIEDE = (635, 427)                # la preda per terra davanti a lui (un po' a sinistra: si vede la testa)
ALBERI = [
    # la cornice del bosco, fuori dal recinto: in alto (la chioma esce dalla mappa) gli esotici a tronco dritto
    ('albero_alto_dritto_1', 92, 176), ('albero_alto_dritto_2', 470, 118), ('albero_alto_dritto_3', 752, 128),
    ('albero_alto_dritto_1', 1002, 150), ('albero_alto_dritto_2', 1214, 178),
    # ai lati e in basso quelli a serpente, interi; i varchi dei sentieri restano liberi
    ('albero_alto_3', 1236, 420), ('albero_alto_1', 1188, 652), ('albero_alto_2', 64, 470), ('albero_alto_4', 118, 702),
    ('albero_alto_1', 384, 790), ('albero_alto_3', 880, 796), ('albero_alto_4', 1100, 798),
    # due alberi vicini al recinto, a fare ombra sul prato
    ('albero_alto_2', 346, 448), ('albero_alto_4', 968, 470),
    ('cespuglio_1', 240, 560), ('cespuglio_2', 1046, 330), ('cespuglietto_1', 806, 618), ('cespuglio_2', 470, 640),
    ('cespuglietto_1', 286, 300), ('cespuglio_1', 920, 248),
]
SASSI = [('sasso_4', 760, 560), ('sassolino_2', 776, 566), ('sasso_2', 420, 520), ('sassolino_1', 1120, 520),
         ('sasso_5', 180, 380), ('sassolino_3', 196, 386), ('masso_basso_4', 1000, 690), ('sassolino_2', 560, 720)]
PARTENZA = [612, 776]
STANZE = [
    {"nome": "Il pasto del goblin", "rett": [470, 290, 810, 510]},
    {"nome": "Dalla radura", "rett": [500, 510, 760, 800]},
    {"nome": "Verso la pianura", "rett": [560, 0, 720, 290]},
    {"nome": "Il prato", "rett": [0, 0, W, H]},
]
GIRO = [[612, 776], [618, 700], [614, 620], [636, 548], [640, 500], [600, 470], [570, 430], [586, 370],
        [626, 330], [636, 290], [622, 200], [608, 120], [606, 84]]


def _salva(a, p):
    rr._salva(np.asarray(a, float), p)


def _h(x, s):
    return rr._h(int(x), s)


# ---------------------------------------------------------------- i pezzi nuovi
def _contorna(a, col):
    """il contorno di un pixel attorno alla figura (col colore dato)"""
    op = a[..., 3] > 0
    p = np.pad(op, 1)
    fuori = ~op & (p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:])
    a[fuori, :3] = col
    a[fuori, 3] = 255
    return a


FOTOGRAMMI = 6                          # quelli di goblin_mangia.png; la preda va con lui
MS = 85                                 # millisecondi per fotogramma: mangia furiosamente


def goblin():
    """il goblin di spalle che divora (goblin_mangia.png, 6 fotogrammi), tutti tagliati allo stesso riquadro; il piede
    in fondo nel mezzo"""
    g = np.asarray(Image.open(GOBLIN).convert('RGBA')).astype(float)
    fot = [g[:, i * 57:(i + 1) * 57] for i in range(FOTOGRAMMI)]
    op = np.any([f[..., 3] > 0 for f in fot], axis=0)
    ys, xs = np.nonzero(op)
    y0, y1, x0, x1 = ys.min() - 1, ys.max() + 1, xs.min() - 1, xs.max() + 2
    fot = [f[y0:y1, x0:x1] for f in fot]
    piede_y = fot[0].shape[0] - 1
    xs = np.nonzero(op[y1 - 1, x0:x1])[0]
    return fot, (int((xs.min() + xs.max()) // 2), piede_y)


def preda_lettere(scatto):
    """il cinghiale ucciso, steso sul fianco destro (la testa a sinistra, le zampe verso chi guarda), disegnato alla
    misura del foglio d'esempio (2/3) e poi ingrandito come il goblin. 'scatto': 1 le zampe davanti, 2 quelle dietro
    sobbalzano quando il goblin strappa. Lettere: k contorno, S s f F pelo, v pancia, o O grugno e narice, w zanna e
    costola, h zoccolo, r R x carne"""
    H, W = 24, 42
    yy, xx = np.mgrid[0:H, 0:W]
    cx, cy, rx, ry = 25, 10.5, 11.5, 7.0                              # il corpo, tozzo e corto (Bru: era troppo lungo)
    corpo = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1
    corpo |= ((xx - 18) / 6.5) ** 2 + ((yy - 6.5) / 4.5) ** 2 <= 1    # la gobba sulle spalle
    tx, ty, trx, try_ = 10.5, 12.0, 7.5, 6.0                          # la testa, grossa
    testa = ((xx - tx) / trx) ** 2 + ((yy - ty) / try_) ** 2 <= 1
    muso = ((xx - 3.0) / 2.6) ** 2 + ((yy - 14.0) / 2.8) ** 2 <= 1
    orecchio = np.zeros((H, W), bool)
    for y in range(2, 8):
        for x in range(9, 18):
            if (y - 2) * 1.0 >= abs(x - 13.5) * 0.85 - 0.5:
                orecchio[y, x] = True
    zampe = np.zeros((H, W), bool)
    zoccoli = np.zeros((H, W), bool)
    gambe = [((16, 16), (14, 21)), ((20, 17), (19, 22)), ((30, 16), (32, 21)), ((34, 15), (37, 20))]
    for i, ((ax, ay), (bx, by)) in enumerate(gambe):
        if (scatto == 1 and i < 2) or (scatto == 2 and i >= 2):
            bx, by = bx + (-1 if i < 2 else 1), by - 1                # il calcio
        for s in np.linspace(0, 1, 30):
            x, y = ax + (bx - ax) * s, ay + (by - ay) * s
            m = (xx - x) ** 2 + (yy - y) ** 2 <= 1.45 ** 2
            zampe |= m
            if s > 0.78:
                zoccoli |= m
    coda = np.zeros((H, W), bool)
    for x, y in ((36, 9), (37, 8), (38, 7), (39, 6), (40, 5), (40, 6), (39, 5)):
        coda[y, x] = True
    pieno = corpo | testa | muso | orecchio | zampe | coda
    # le setole lungo la gobba e la schiena: la riga di sopra frastagliata
    for x in range(13, 36, 2):
        y = int(np.nonzero(corpo[:, x])[0].min())
        if y > 0:
            pieno[y - 1, x] = True
    L = np.full((H, W), '.', dtype='<U1')
    for y, x in zip(*np.nonzero(pieno)):
        if zampe[y, x] and not corpo[y, x]:
            L[y, x] = 'h' if zoccoli[y, x] else ('F' if x < (16 if y < 18 else 15) else 'f')
            continue
        if muso[y, x] and not testa[y, x] or (muso[y, x] and x < 5):
            L[y, x] = 'o'
            continue
        if orecchio[y, x] and not testa[y, x]:
            L[y, x] = 's' if x > 12 else 'f'
            continue
        if coda[y, x]:
            L[y, x] = 's'
            continue
        if testa[y, x] and not corpo[y, x]:
            dx, dy = (x - tx) / trx, (y - ty) / try_
        else:
            dx, dy = (x - cx) / rx, (y - cy) / ry
        luce = -0.45 * dx - 0.9 * dy
        if dy > 0.82:
            L[y, x] = 's'
        elif dy > 0.32 and 15 <= x <= 35:
            L[y, x] = 'v'
        elif luce > 0.42:
            L[y, x] = 'F'
        elif luce > -0.25:
            L[y, x] = 'f'
        else:
            L[y, x] = 's'
    L[1:3][pieno[1:3] & (L[1:3] != '.')] = 'S'                     # le setole scure in cima
    # la ferita sulla pancia, dove mangia: carne, la costola che si vede
    ferita = ((xx - 24) / 4.0) ** 2 + ((yy - 14.0) / 2.3) ** 2 <= 1
    L[ferita & pieno] = 'r'
    L[13, 21] = L[13, 22] = 'R'
    L[15, 27] = L[15, 26] = 'x'
    L[14, 23] = L[14, 25] = 'w'
    # il grugno: la narice; la zanna che sale dalla mascella, dietro il grugno; l'occhio chiuso
    L[14, 1] = L[13, 1] = 'O'
    L[16, 7] = L[15, 7] = L[14, 6] = 'w'
    L[10, 11] = L[10, 12] = 'k'
    # il contorno: i pixel pieni che toccano il vuoto
    out = L.copy()
    for y, x in zip(*np.nonzero(L != '.')):
        if any(not (0 <= y + dy < H and 0 <= x + dx < W) or L[y + dy, x + dx] == '.'
               for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            out[y, x] = 'k'
    return out


def preda():
    """il cinghiale a fotogrammi, insieme al goblin: quando lui strappa (fotogrammi 3 e 6) le zampe sobbalzano"""
    col = {'k': (36, 26, 38), 'S': PELO[0], 's': PELO[1], 'f': PELO[2], 'F': PELO[3], 'v': PANCIA[1],
           'o': (206, 142, 136), 'O': (112, 58, 70), 'w': OSSO[3], 'h': (60, 44, 54),
           'r': (164, 58, 62), 'R': (214, 106, 96), 'x': (82, 26, 42)}
    scatti = [0, 0, 1, 0, 0, 2]
    fot = []
    for f in range(FOTOGRAMMI):
        L = _gt.ingrandisci(preda_lettere(scatti[f]))
        a = np.zeros(L.shape + (4,), float)
        for k, c in col.items():
            m = L == k
            a[m, :3] = c
            a[m, 3] = 255
        fot.append(a)
    h, w = fot[0].shape[:2]
    return fot, (w // 2, h - 1)


def prepara_pezzi():
    os.makedirs(os.path.join(LIV, FUSI), exist_ok=True)
    for vecchio in ('fuoco.png', 'fuoco_fotogrammi.png', 'fuoco.json', 'tronco.png', 'tronco.json'):
        if os.path.exists(os.path.join(NUOVI, vecchio)):            # la scena di prima: non ci sono piu'
            os.remove(os.path.join(NUOVI, vecchio))
    gf, piede_g = goblin()
    _salva(gf[0], os.path.join(NUOVI, 'goblin.png'))
    _salva(np.concatenate(gf, 1), os.path.join(NUOVI, 'goblin_fotogrammi.png'))
    pf, piede_p = preda()
    _salva(pf[0], os.path.join(NUOVI, 'preda.png'))
    _salva(np.concatenate(pf, 1), os.path.join(NUOVI, 'preda_fotogrammi.png'))
    for n, p in (('goblin', piede_g), ('preda', piede_p)):
        with open(os.path.join(NUOVI, n + '.json'), 'w') as f:
            json.dump({'piede': [int(p[0]), int(p[1])]}, f)
    # i massi e i sassi del catalogo, coi colori nuovi e il contorno fuso (come al ruscello)
    for n in sorted(set(s[0] for s in SASSI)):
        f, piede, misura = rr.pezzo(n)
        a = np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA'))
        a = _tav.ricolora(a, sostituisci=rr._fatto_di(n)).astype(float)
        _salva(rr.fondi(a, True), os.path.join(LIV, FUSI + os.path.basename(f)))


def nuovo(n):
    f = os.path.join(NUOVI, n + '.png')
    with open(os.path.join(NUOVI, n + '.json')) as fj:
        piede = tuple(json.load(fj)['piede'])
    w, h = Image.open(f).size
    return 'pezzi/pasto/' + n + '.png', piede, (w, h)


def impiedi():
    """(nome, file, x, y del piede nel mondo, piede nel disegno, impronta (mezza larghezza, mezza altezza))"""
    tutte = []
    for (n, x, y) in ALBERI:
        f, piede, (w, h) = rr.pezzo(n)
        tutte.append((n, 'pezzi/ruscello/fusi/' + os.path.basename(f), x, y, piede, rr.impronta(n, w, h)))
    for (n, x, y) in SASSI:
        f, piede, (w, h) = rr.pezzo(n)
        tutte.append((n, FUSI + os.path.basename(f), x, y, piede, rr.impronta(n, w, h)))
    for n, (x, y), imp in (('preda', PREDA_PIEDE, (28, 8)), ('goblin', GOBLIN_PIEDE, (14, 5))):
        f, piede, _ = nuovo(n)
        tutte.append((n, f, x, y, piede, imp))
    return tutte


# ---------------------------------------------------------------- il terreno
def curva(punti, passo=1.0):
    return rr.curva(punti, passo)


def _kit(nome):
    """un pezzo del kit delle strade di Bru come indici di KIT (-1 dove e' vuoto)"""
    a = np.asarray(Image.open(os.path.join(LIV, 'terreni', 'strade_radenna', nome)).convert('RGBA')).astype(int)
    k = np.full(a.shape[:2], -1)
    for i, c in enumerate(KIT):
        k[(a[..., 3] > 0) & np.all(a[..., :3] == c, -1)] = i
    assert ((k >= 0) == (a[..., 3] > 0)).all(), nome
    return k


def _pezzi(m):
    """le parti connesse (4 vicini) della maschera, dalla piu' grande"""
    H_, W_ = m.shape
    visti = np.zeros_like(m)
    out = []
    for y, x in zip(*np.nonzero(m)):
        if visti[y, x]:
            continue
        pezzo, pila = [], [(y, x)]
        visti[y, x] = True
        while pila:
            cy, cx = pila.pop()
            pezzo.append((cy, cx))
            for yy, xx in ((cy + 1, cx), (cy - 1, cx), (cy, cx + 1), (cy, cx - 1)):
                if 0 <= yy < H_ and 0 <= xx < W_ and m[yy, xx] and not visti[yy, xx]:
                    visti[yy, xx] = True
                    pila.append((yy, xx))
        out.append(pezzo)
    return sorted(out, key=len, reverse=True)


def pavimento():
    """la strada di mattoni e il pezzo di piazza antica: la maschera, i colori, e le lastre sotto un ciuffo d'erba
    (dove l'erba ci fa un'ombrina). La strada: il motivo intero del kit (anche i cordoli frastagliati: dove il motivo e'
    vuoto c'e' il prato) piegato lungo la curva, come al ruscello; la riga del motivo e' spostata perche' in cima
    combaci con la strada del ruscello. Le lastre: quelle della piazza antica del ruscello, coi suoi colori, senza i
    sassolini attorno; la strada ci passa sotto (fra le lastre c'e' l'erba, non la strada). L'erba sopra le lastre: sul
    bordo di fuori se le mangia (sfrangiata), due lastre d'angolo sono mezze coperte, qualche ciuffo nelle fughe e
    sopra; dove la strada arriva alle lastre, ciuffi sulla giuntura"""
    yy, xx = np.mgrid[0:H, 0:W]
    a = np.asarray(Image.open(os.path.join(LIV, 'terreni', 'piazza_radenna_tavolozza.png')).convert('RGBA')).astype(float)
    piena = np.zeros(a.shape[:2], bool)
    for y, x in _pezzi(a[..., 3] > 0)[0]:
        piena[y, x] = True
    ph, pw = piena.shape
    x0, y0 = PIAZZA_C[0] - pw // 2, PIAZZA_C[1] - ph // 2
    lastra = np.zeros((H, W), bool)
    lastra[y0:y0 + ph, x0:x0 + pw] = piena
    colori = np.zeros((H, W, 3))
    colori[y0:y0 + ph, x0:x0 + pw] = a[..., :3]
    impronta = rr._chiudi(lastra, 6)                     # la piazza con le sue fughe
    dentro = rr._distanza(~impronta, 9)                  # quanti passi dal bordo, dentro la piazza
    n1, n2 = _prato.liscio(H, W, 4, 4, 31), _prato.liscio(H, W, 3, 3, 37)
    erba = ((dentro <= 2) & (n1 > 0.32)) | ((dentro <= 6) & (n1 > 0.62)) | ((dentro <= 9) & (n1 > 0.80))
    erba |= n2 > 0.88                                     # i ciuffetti sopra le lastre e nelle fughe
    for cx, cy, r in ((x0 + 22, y0 + 28, 21), (x0 + pw - 20, y0 + ph - 22, 17)):    # le due lastre mezze coperte
        erba |= np.hypot(xx - cx, (yy - cy) * 1.15) + (n1 - 0.5) * 14 < r
    # dove arriva la strada il bordo della lastra resta (la strada ci entra), con qualche ciuffo solo sulla giuntura
    lin, u = curva(STRADA)
    D, S, V = rr.campo(lin, u, 18, H, 0)
    erba &= ~((D < 17) & (dentro <= 9) & (yy < y0 + 40))
    lastra &= ~erba
    for pezzo in _pezzi(lastra)[1:]:                     # niente briciole di lastra in mezzo all'erba
        if len(pezzo) < 14:
            for y, x in pezzo:
                lastra[y, x] = False
    # l'ombrina dell'erba sulle lastre (la luce viene da in alto a sinistra): sotto e a destra di un ciuffo
    sopra = np.zeros((H, W), bool)
    sopra[1:] |= ~lastra[:-1]
    sopra[1:, 1:] |= ~lastra[:-1, :-1]
    ombrina = lastra & sopra & impronta
    # la strada, fino alla piazza (sotto la piazza niente strada)
    st = _kit('strada_verticale.png')
    k0 = int(np.abs(lin[:, 1]).argmin())
    spost = (STRADA_RIGA - int(u[k0])) % 55
    col = np.clip((V + 14.5).astype(int), 0, 28)
    tex = st[(S.astype(int) + spost) % 55, col]
    fuori = rr._distanza(impronta, 6)                    # quanti passi dalla piazza, fuori
    via = (D < 14.5) & ~impronta & (tex >= 0)
    giunta = via & (((fuori <= 2) & (n2 > 0.50)) | ((fuori <= 4) & (n2 > 0.78)))
    via &= ~giunta
    mat = via | lastra
    colori[via] = MATTONI[tex[via]]
    return mat, colori, ombrina


RAMPE = None


def scendi(out, quanto, maschera=None):
    """i pixel scendono di 'quanto' gradini (per pixel) lungo la rampa del loro materiale: il prato (tre al piu'), la
    pietra dei mattoni, e le rampe delle lastre della piazza (pietra, muschio, chioma, ombra; due al piu'); gli altri
    colori restano"""
    global RAMPE
    if RAMPE is None:
        tav = _tav.tavolozze()
        RAMPE = {}
        lista = [(rr.PRATO_RAMPA, 3), (PIETRA, 2)] + [(tav[k], 2) for k in ('pietra', 'muschio', 'chioma', 'ombra')]
        for rampa, massimo in lista:
            r = np.asarray(rampa, float)
            for i, c in enumerate(r.astype(int)):
                RAMPE.setdefault(tuple(int(v) for v in c), (r, i, massimo))
        r = np.asarray(rr.PRATO_RAMPA, float)
        for c in (PRATO['petalo'], PRATO['cuore']):        # i fiorellini del prato: come la luce
            RAMPE.setdefault(tuple(c), (r, len(r) - 1, 3))
    quanto = np.broadcast_to(quanto, out.shape[:2])      # la misura della mappa (anche di altre zone)
    if maschera is None:
        maschera = quanto > 0
    m = maschera & (quanto > 0)
    q = np.rint(out).astype(int)
    for y, x in zip(*np.nonzero(m)):
        v = RAMPE.get((int(q[y, x, 0]), int(q[y, x, 1]), int(q[y, x, 2])))
        if v is not None:
            rampa, i, massimo = v
            out[y, x] = rampa[max(0, i - min(int(quanto[y, x]), massimo))]
    return out


def ombre(out, tutte):
    """le ombre delle cose in piedi: sul prato scendono di gradini lungo la sua rampa (come al ruscello), sui mattoni
    lungo quella della pietra"""
    bayer = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
    H, W = out.shape[:2]                                  # la misura della mappa (anche di altre zone)
    giu = np.zeros((H, W), int)
    for (n, f, fx, fy, piede, imp) in tutte:
        w = Image.open(os.path.join(LIV, f)).size[0]
        if 'albero' in n or 'cespugli' in n:
            rx = 0.56 * w; ry = 0.24 * w; cx, cy = fx + 5, fy - 3
            for y in range(int(cy - ry - 1), int(cy + ry + 2)):
                for x in range(int(cx - rx - 1), int(cx + rx + 2)):
                    if 0 <= y < H and 0 <= x < W:
                        e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                        if e <= 1 and (e + bayer[y % 4, x % 4] * 0.3 < 0.55 or (x + y) % 2 == 0):
                            giu[y, x] += 1
        rx = max(5.0, 0.32 * w); ry = max(2.5, rx * 0.32); cx, cy = fx + 3, fy - 1
        if 'albero_alto' in n:
            rx, ry = max(13.0, 0.13 * w), 6.0
        if n == 'goblin':
            rx, ry = 13.0, 4.0
        if n == 'preda':
            rx, ry, cx, cy = 34.0, 6.0, fx + 2, fy - 6          # l'ombra del cinghiale steso
        for y in range(int(cy - ry - 1), int(cy + ry + 2)):
            for x in range(int(cx - rx - 1), int(cx + rx + 2)):
                if 0 <= y < H and 0 <= x < W:
                    e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                    if e <= 1:
                        giu[y, x] += 2 if e < 0.55 else 1
    return scendi(out, giu), giu > 0


def passi(tutte, bordi=True, misura=None):
    """dove si cammina: dappertutto, tranne il bordo della mappa e le impronte delle cose in piedi ('misura': (alto,
    largo) della mappa, se non e' questa)"""
    H, W = misura or (globals()['H'], globals()['W'])
    ok = np.ones((H, W), bool)
    yy, xx = np.ogrid[:H, :W]
    for (n, f, fx, fy, piede, (rx, ry)) in tutte:
        if rx:
            ok &= ((xx - fx) / rx) ** 2 + ((yy - fy) / ry) ** 2 > 1
    # ai bordi della mappa Lei resta tutta dentro (e' alta 74 e larga 40): sopra fino a dove arriva la testa, ai lati
    # mezza larghezza
    if bordi:
        ok[:, :22] = ok[:, -22:] = False
        ok[:76] = False
    m = np.zeros((H, W, 4), np.uint8)
    m[ok] = (255, 255, 255, 255)
    return m


def main():
    os.makedirs(NUOVI, exist_ok=True)
    prepara_pezzi()
    tutte = impiedi()
    fiori_segni = []
    passi_prato, _ = _prato.prato(H, W, seme=58, tav=PRATO, fiori=fiori_segni)
    out = passi_prato[3].astype(float)
    mat, colori, ombrina = pavimento()
    out[mat] = colori[mat]
    out = scendi(out, 1, ombrina)
    out, ombra = ombre(out, tutte)
    _salva(out, os.path.join(LIV, 'pasto.png'))
    cammino = passi(tutte)
    _salva(cammino, os.path.join(LIV, 'pasto_passi.png'))
    # dove i passi pestano l'erba: i colori del prato (anche all'ombra), non i mattoni
    q = np.rint(out).astype(int)
    erba = np.zeros((H, W), bool)
    for c in list(PRATO.values()):
        erba |= np.all(q == np.array(c), axis=-1)
    erba &= ~mat
    pr = np.zeros((H, W, 4), np.uint8); pr[erba] = (255, 255, 255, 255)
    _salva(pr, os.path.join(LIV, 'pasto_prato.png'))
    # i fiori in piedi: dove il prato li avrebbe messi, nel prato al sole e dove si cammina
    macchie = _prato.liscio(H, W, 170, 110, 77)
    q1, q2 = np.quantile(macchie, [0.62, 0.86])
    rng = np.random.default_rng(31)
    nomi = list(_fiori.SPECIE)
    ok = passi(tutte, bordi=False)[..., 3] > 0          # anche ai bordi, dove Lei non arriva
    fiori = []
    for (y, x, _g) in fiori_segni:
        piccolo = rng.random() < 0.45
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
    with open(os.path.join(LIV, 'pasto_fiori.json'), 'w') as f:
        json.dump({"_nota": "Scritto da strumenti/livelli/pasto_goblin.py: non toccare a mano. I fiori del prato in "
                            "piedi: [x, y del piede nel mondo, specie (la riga di terreni/fiori.png, fiori.py)].",
                   "fiori": fiori}, f, ensure_ascii=False)
        f.write('\n')
    with open(os.path.join(LIV, 'pasto_pezzi.json'), 'w') as f:
        json.dump({"_nota": "Scritto da strumenti/livelli/pasto_goblin.py: non toccare a mano. Ogni pezzo e' "
                            "[file (da art/livelli/), x, y del piede nel mondo, x, y del piede nel disegno].",
                   "pezzi": [[c[1], int(c[2]), int(c[3]), int(c[4][0]), int(c[4][1])]
                             for c in sorted(tutte, key=lambda c: c[3])]},
                  f, indent=1, ensure_ascii=False)
        f.write('\n')
    pianta = {
        "_nota": "Il pasto del goblin, fatto da strumenti/livelli/pasto_goblin.py: la radura nel recinto di massi col "
                 "goblin al centro, di spalle, che divora la preda; la strada di mattoni della pianura arriva da nord "
                 "fino a un pezzo della piazza antica coperto d'erba; a sud, da dove si arriva, solo prato.",
        "nome": "Il pasto del goblin",
        "mappa": "pasto.png", "scala": 1, "pixel": 1, "ingrandimento": 2,
        "pezzi": "pasto_pezzi.json", "passi": "pasto_passi.png", "prato": "pasto_prato.png", "fiori": "pasto_fiori.json",
        "animati": {
            "pezzi/pasto/goblin.png": {"file": "pezzi/pasto/goblin_fotogrammi.png", "n": FOTOGRAMMI, "ms": MS},
            "pezzi/pasto/preda.png": {"file": "pezzi/pasto/preda_fotogrammi.png", "n": FOTOGRAMMI, "ms": MS},
        },
        "_animati": "Si muovono sempre (non solo con l'acqua), insieme: il goblin che divora e la preda che sobbalza.",
        "limiti": [0, 0, W, H],
        "partenza": PARTENZA, "verso": [0, -1],
        "stanze": STANZE,
        "giro": GIRO,
    }
    with open(os.path.join(LIV, 'pasto.json'), 'w') as f:
        json.dump(pianta, f, indent=1, ensure_ascii=False)
        f.write('\n')
    if len(sys.argv) > 1:
        # l'anteprima: il terreno con sopra le cose in piedi in ordine di piede
        a = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).convert('RGBA')
        for c in sorted(tutte, key=lambda c: c[3]):
            im = Image.open(os.path.join(LIV, c[1])).convert('RGBA')
            a.alpha_composite(im, (int(c[2] - c[4][0]), int(c[3] - c[4][1])))
        a.convert('RGB').save(sys.argv[1])
    print('pasto del goblin: mappa %dx%d, %d cose in piedi, %d fiori' % (W, H, len(tutte), len(fiori)))


if __name__ == '__main__':
    main()
