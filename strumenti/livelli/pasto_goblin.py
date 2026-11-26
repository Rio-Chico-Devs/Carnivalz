# Il pasto del goblin: la seconda tappa delle pianure (docs/mondi.md: "il pasto del goblin, nel recinto di pietre a
# nord-est"; docs/storia.md: "una pressione strana, un posto tranquillo, poi gnarl... barf, crunch..."). Bru: "la zona
# del pasto del goblin dove il goblin e' al centro".
#
#   python3 strumenti/livelli/pasto_goblin.py [anteprima.png]      (serve numpy e Pillow)
#
# Una radura dentro un recinto di massi, nel prato; al centro il goblin (strumenti/nemici/goblin_tipico), di spalle,
# curvo sulla preda che ha appena ucciso (un cinghiale steso sul fianco) e la divora (Bru: "e' intento a mangiare
# furiosamente, non c'e' bisogno di un fuoco o di ossa in giro, non e' che lui ha un accampamento, si e' trovato li',
# ha ucciso una preda e la sta mangiando"). Bru: il pavimento "meta' di
# mattoni come la scena successiva e la meta' da dove si arriva senza sentiero, solo radura". Quindi la meta' di nord
# del recinto e' lastricata coi mattoni della pianura aperta (la tappa dopo: la strada del ruscello, stesso kit di
# Bru, stessi colori), col cordolo lungo il giro e rotta verso sud; la meta' di sud, da dove arriva Lei (dalla
# capsula), e' prato, senza sentiero. Dal varco di nord la strada di mattoni va alla pianura aperta: lascia la mappa
# in alto dove la strada del ruscello entra in basso (stessa x, stessa direzione, stesso punto del motivo), cosi' le
# due scene si attaccano. Attorno il prato coi fiori al vento e gli alberi esotici, come al ruscello (stessi pezzi,
# stesso prato, stesse regole delle tavolozze di Bru).
#
# Scrive art/livelli/pasto.png (il terreno con le cose piatte: mattoni e ombre), pasto_pezzi.json (le cose
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
C = (640, 400)                          # il centro del recinto
ANELLO = (172, 106)                     # il recinto di massi: i raggi dell'ellisse (vista di tre quarti)
LASTRICO = (156, 94)                    # il lastricato: l'ellisse di cui resta la meta' di nord
ROTTO = 434                             # la riga (mossa) dove il lastricato si rompe: sotto, verso chi arriva, prato
VARCHI = [(90, 12), (270, 12)]          # i varchi nel recinto: angolo (0 a destra, 90 giu') e mezza ampiezza
# la strada di mattoni verso la pianura aperta: parte dal lastricato, esce dal varco di nord e lascia la mappa in alto
# dove la strada del ruscello (la scena dopo) entra in basso: la' la colonna 0 del motivo e' a x 595 (il mezzo a 609,5)
# e sull'ultima riga della mappa c'e' la riga 26 del motivo, che sale andando su; qui sulla prima riga ci va la 25.
# L'ultimo tratto va un filo verso destra salendo, come la' (misurato su ruscello.png)
STRADA = [(640, 352), (636, 290), (622, 200), (608, 120), (605, 60), (609.5, 0), (613, -35)]
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
CORDOLO = [0, 2, 5, 3, 1, 0]            # il cordolo dal bordo verso dentro, come nel kit (scuro, luce, solco)
MOTIVO = 'diamanti'                        # dentro il lastricato: 'righe' (la spina della strada) o 'diamanti' (il nodo)

# ---------------------------------------------------------------- dove stanno le cose
GOBLIN_PIEDE = (640, 430)               # il goblin, al centro, di spalle a chi arriva da sud
PREDA_PIEDE = (630, 427)                # la preda per terra davanti a lui (un po' a sinistra: si vede la testa)
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
# i massi del recinto: uno ogni tanto lungo l'ellisse, fuori dai varchi, a caso fra questi
MASSI = ['masso_muschio_1', 'masso_muschio_3', 'masso_muschio_8', 'masso_muschio_9', 'masso_basso_4', 'masso_3',
         'masso_6', 'masso_muschio_8', 'masso_muschio_5', 'masso_muschio_9']
SASSI = [('sasso_4', 760, 560), ('sassolino_2', 776, 566), ('sasso_2', 420, 520), ('sassolino_1', 1120, 520),
         ('sasso_5', 180, 380), ('sassolino_3', 196, 386), ('masso_basso_4', 1000, 690), ('sassolino_2', 560, 720)]
PARTENZA = [612, 776]
STANZE = [
    {"nome": "Il pasto del goblin", "rett": [470, 290, 810, 510]},
    {"nome": "L'arrivo", "rett": [500, 510, 760, 800]},
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
    H, W = 24, 50
    yy, xx = np.mgrid[0:H, 0:W]
    cx, cy, rx, ry = 29, 10.5, 15.5, 7.0                              # il corpo, tozzo
    corpo = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1
    corpo |= ((xx - 19) / 7.5) ** 2 + ((yy - 6.5) / 4.5) ** 2 <= 1    # la gobba sulle spalle
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
    gambe = [((17, 16), (15, 21)), ((22, 17), (21, 22)), ((37, 16), (40, 21)), ((42, 15), (45, 20))]
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
    for x, y in ((44, 9), (45, 8), (46, 7), (47, 6), (48, 5), (48, 6), (47, 5)):
        coda[y, x] = True
    pieno = corpo | testa | muso | orecchio | zampe | coda
    # le setole lungo la gobba e la schiena: la riga di sopra frastagliata
    for x in range(13, 43, 2):
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
        elif dy > 0.32 and 15 <= x <= 43:
            L[y, x] = 'v'
        elif luce > 0.42:
            L[y, x] = 'F'
        elif luce > -0.25:
            L[y, x] = 'f'
        else:
            L[y, x] = 's'
    L[1:3][pieno[1:3] & (L[1:3] != '.')] = 'S'                     # le setole scure in cima
    # la ferita sulla pancia, dove mangia: carne, la costola che si vede
    ferita = ((xx - 30) / 4.6) ** 2 + ((yy - 14.0) / 2.3) ** 2 <= 1
    L[ferita & pieno] = 'r'
    L[13, 27] = L[13, 28] = 'R'
    L[15, 33] = L[15, 32] = 'x'
    L[14, 29] = L[14, 31] = 'w'
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
    for n in sorted(set(MASSI + [s[0] for s in SASSI])):
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


def massi_del_recinto():
    """un masso ogni 27 pixel circa lungo l'ellisse del recinto, fuori dai varchi; ogni tanto un sassolino in mezzo"""
    rng = np.random.default_rng(23)
    out = []
    a = 0.0
    while a < 360:
        dentro_varco = any(abs(((a - c + 180) % 360) - 180) < m for c, m in VARCHI)
        rad = np.radians(a)
        x = C[0] + ANELLO[0] * np.cos(rad) + rng.uniform(-3, 3)
        y = C[1] + ANELLO[1] * np.sin(rad) + rng.uniform(-2, 2)
        if not dentro_varco:
            out.append((MASSI[int(rng.integers(len(MASSI)))], int(round(x)), int(round(y))))
        # il passo lungo l'ellisse: 27 pixel di strada (piu' gradi dove l'ellisse e' stretta)
        dx, dy = -ANELLO[0] * np.sin(rad), ANELLO[1] * np.cos(rad)
        a += np.degrees(27.0 / max(1.0, np.hypot(dx, dy)))
    return out


def impiedi():
    """(nome, file, x, y del piede nel mondo, piede nel disegno, impronta (mezza larghezza, mezza altezza))"""
    tutte = []
    for (n, x, y) in ALBERI:
        f, piede, (w, h) = rr.pezzo(n)
        tutte.append((n, 'pezzi/ruscello/fusi/' + os.path.basename(f), x, y, piede, rr.impronta(n, w, h)))
    for (n, x, y) in massi_del_recinto() + SASSI:
        f, piede, (w, h) = rr.pezzo(n)
        tutte.append((n, FUSI + os.path.basename(f), x, y, piede, rr.impronta(n, w, h)))
    for n, (x, y), imp in (('preda', PREDA_PIEDE, (36, 9)), ('goblin', GOBLIN_PIEDE, (14, 5))):
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


def _pulisci(m, y0, y1, x0, x1, isole=10, buchi=6):
    """nel riquadro: via i pezzetti di mattone piu' piccoli di 'isole' pixel e i buchi piu' piccoli di 'buchi'"""
    sub = m[y0:y1, x0:x1].copy()
    for valore, minimo in ((True, isole), (False, buchi)):
        visti = np.zeros(sub.shape, bool)
        h, w = sub.shape
        for y, x in zip(*np.nonzero(sub == valore)):
            if visti[y, x]:
                continue
            pezzo, pila = [], [(y, x)]
            visti[y, x] = True
            while pila:
                cy, cx = pila.pop()
                pezzo.append((cy, cx))
                for yy, xx in ((cy + 1, cx), (cy - 1, cx), (cy, cx + 1), (cy, cx - 1)):
                    if 0 <= yy < h and 0 <= xx < w and not visti[yy, xx] and sub[yy, xx] == valore:
                        visti[yy, xx] = True
                        pila.append((yy, xx))
            if len(pezzo) < minimo:
                for cy, cx in pezzo:
                    sub[cy, cx] = not valore
    m = m.copy()
    m[y0:y1, x0:x1] = sub
    return m


def lastricato():
    """i mattoni: la meta' di nord del recinto lastricata, mattonelle quadrate coi rombi del nodo del kit (MOTIVO),
    il cordolo lungo il giro. Verso sud il lastricato e' rotto a mattonelle: sopra una linea mossa
    sono intere (qualcuna manca), su quella linea sono spezzate, sotto non ci sono piu' (qualche coccio rimasto nel
    prato), e vicino alla rottura l'erba cresce nelle fughe; sotto c'e' solo prato. La strada di mattoni esce dal
    varco di nord (il motivo del kit piegato lungo la curva, come al ruscello) e in cima combacia con quella del
    ruscello; dove entra nel lastricato i motivi non combaciano e l'erba copre la giuntura. Ritorna la maschera e
    l'indice di MATTONI"""
    yy, xx = np.mgrid[0:H, 0:W]
    ang = np.arctan2((yy - C[1]) / LASTRICO[1], (xx - C[0]) / LASTRICO[0])
    giro = rr.rumore1(400, 23, 7)[((ang + np.pi) / (2 * np.pi) * 359).astype(int)]
    r = np.sqrt(((xx - C[0]) / LASTRICO[0]) ** 2 + ((yy - C[1]) / LASTRICO[1]) ** 2)
    ellisse = r < 1 + (giro - 0.5) * 0.03
    lin, u = curva(STRADA)
    D, S, V = rr.campo(lin, u, 18, H, 0)
    via = D < 14.5
    tutto = ellisse | via                                # fin dove arriva il cordolo (sulla rottura no)
    # le mattonelle (29 pixel, come i rombi del nodo): il mezzo di ognuna, un numero a caso per ognuna, e la riga
    # della rottura che passa li'
    T = 29
    ty, tx = (yy - C[1]) // T, (xx - C[0]) // T
    yc, xc = C[1] + ty * T + T / 2.0, C[0] + tx * T + T / 2.0
    caso = (((ty + 50) * 7919 + (tx + 50) * 104729) % 1000) / 1000.0
    caso2 = (((ty + 50) * 15485863 + (tx + 50) * 32452843) % 997) / 997.0
    onda = rr.rumore1(W + T, 61, 11)
    riga = ROTTO + (onda[np.clip(xc, 0, W - 1).astype(int)] - 0.5) * 30
    intera = yc < riga - 9
    sparita = yc > riga + 9
    f = _prato.liscio(H, W, 5, 4, 13)
    tiene = intera | (~intera & ~sparita & (yy < riga + (f - 0.5) * 16))
    tiene &= ~(intera & (yc > riga - 9 - T) & (caso < 0.13))         # qualcuna manca, nella fila sopra la rottura
    ox, oy = (caso2 - 0.5) * 12, (caso - 0.5) * 10                   # un coccio in qualche mattonella sparita
    coccio = sparita & (yc < riga + 9 + 2 * T) & (caso2 > 0.72) & \
        (((xx - xc - ox) / 7.0) ** 2 + ((yy - yc - oy) / 5.0) ** 2 + (f - 0.5) * 1.4 < 1)
    fughe = ((yy - C[1]) % T == T - 1) | ((xx - C[0]) % T == T - 1)
    erba_fughe = fughe & (yy > riga - 1.5 * T) & (_prato.liscio(H, W, 3, 3, 17) > 0.62)     # ciuffetti corti
    # il cordolo non e' a mattonelle: si spezza dove passa la linea mossa, pixel per pixel
    d = rr._distanza(~tutto, 7)
    cordolo = ellisse & (d <= 6)
    sul_cordolo = yy < ROTTO + (onda[xx] - 0.5) * 30 + (f - 0.5) * 16
    mat = (ellisse & ~cordolo & (tiene | coccio) & ~erba_fughe) | (cordolo & sul_cordolo) | via
    mat = _pulisci(mat, C[1] - LASTRICO[1] - 4, C[1] + LASTRICO[1] + 4, C[0] - LASTRICO[0] - 4,
                   C[0] + LASTRICO[0] + 4)
    st = _kit('strada_verticale.png')
    idx = np.full((H, W), -1)
    if MOTIVO == 'diamanti':
        blocco = _kit('nodo.png')[6:35, 6:35]            # i rombi del nodo (la fuga scura sotto e a destra)
        dentro = blocco[(yy - C[1]) % T, (xx - C[0]) % T]
    else:
        dentro = st[(yy - C[1]) % 55, 6 + (xx - C[0]) % 16]     # le righe a spina della strada, una accanto all'altra
    idx[ellisse] = dentro[ellisse]
    # la strada fuori dal lastricato: il motivo intero del kit (anche i cordoli, frastagliati: dove il motivo e'
    # vuoto c'e' il prato) piegato lungo la curva, come al ruscello; la riga del motivo e' spostata perche' in cima
    # combaci con la strada del ruscello
    fuori = via & ~ellisse
    k0 = int(np.abs(lin[:, 1]).argmin())
    spost = (STRADA_RIGA - int(u[k0])) % 55
    col = np.clip((V + 14.5).astype(int), 0, 28)
    tex = st[(S.astype(int) + spost) % 55, col]
    idx[fuori] = tex[fuori]
    mat &= ~(fuori & (tex < 0))
    for k in range(1, 7):
        idx[mat & ellisse & (d == k)] = CORDOLO[k - 1]
    # dove la strada entra nel lastricato i due motivi non combaciano: ci cresce l'erba sopra (Bru: "coprire i punti
    # di giuntura con un po' di erba"), una striscia sfrangiata lungo il bordo dell'ellisse
    vicino_bordo = np.abs(r - 1) * LASTRICO[1]
    ciuffi = _prato.liscio(H, W, 3, 3, 23)
    giunta = via & (((vicino_bordo < 2.2) & (ciuffi > 0.38)) | ((vicino_bordo < 4.5) & (ciuffi > 0.66)))
    # e sugli angoli, dove i cordoli della strada incontrano quello del lastricato, un ciuffo un po' piu' grande
    angoli = via & (vicino_bordo < 6) & (D > 8.5) & (ciuffi > 0.3)
    mat &= ~(giunta | angoli)
    # la rottura: i mattoni che toccano il prato (fuori dal cordolo) hanno lo spigolo scuro
    vicini = np.ones((H, W), bool)
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        vicini &= np.roll(np.roll(mat, dy, 0), dx, 1)
    idx[mat & ~vicini & (d > 6) & ~fuori] = 1
    idx[~mat] = -1
    return mat, idx


def scendi(out, quanto, maschera=None):
    """i pixel scendono di 'quanto' gradini (per pixel) lungo la rampa del loro materiale: il prato (tre al piu') o
    la pietra dei mattoni (due al piu'); gli altri colori restano"""
    q = np.rint(out).astype(int)
    quanto = np.broadcast_to(quanto, (H, W))
    if maschera is None:
        maschera = quanto > 0
    for rampa, extra, massimo in ((rr.PRATO_RAMPA, (PRATO['petalo'], PRATO['cuore']), 3), (PIETRA, (), 2)):
        pos = np.full((H, W), -1)
        for i, c in enumerate(np.asarray(rampa).astype(int)):
            pos[np.all(q == c, axis=-1)] = i
        for c in extra:                                  # i fiorellini del prato: come la luce
            pos[np.all(q == np.array(c), axis=-1)] = len(rampa) - 1
        m = maschera & (pos >= 0) & (quanto > 0)
        out[m] = np.asarray(rampa, float)[np.maximum(0, pos[m] - np.minimum(quanto[m], massimo))]
    return out


def ombre(out, tutte):
    """le ombre delle cose in piedi: sul prato scendono di gradini lungo la sua rampa (come al ruscello), sui mattoni
    lungo quella della pietra"""
    bayer = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
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


def passi(tutte, bordi=True):
    """dove si cammina: dappertutto, tranne il bordo della mappa e le impronte delle cose in piedi. Il recinto e' un
    muro: fra un masso e il successivo (a meno di 45 pixel, cioe' non attraverso i varchi) una striscia di 4 pixel per
    parte lungo la linea dei piedi, se no Lei passa fra le impronte dei massi ed esce dal recinto"""
    ok = np.ones((H, W), bool)
    yy, xx = np.ogrid[:H, :W]
    for (n, f, fx, fy, piede, (rx, ry)) in tutte:
        if rx:
            ok &= ((xx - fx) / rx) ** 2 + ((yy - fy) / ry) ** 2 > 1
    anello = [(x, y) for _, x, y in massi_del_recinto()]
    for (x0, y0), (x1, y1) in zip(anello, anello[1:] + anello[:1]):
        lung = np.hypot(x1 - x0, y1 - y0)
        if lung >= 45:
            continue
        ya, yb, xa, xb = min(y0, y1) - 5, max(y0, y1) + 6, min(x0, x1) - 5, max(x0, x1) + 6
        sy, sx = np.mgrid[ya:yb, xa:xb]
        t = np.clip(((sx - x0) * (x1 - x0) + (sy - y0) * (y1 - y0)) / lung ** 2, 0, 1)
        vicino = np.hypot(sx - (x0 + t * (x1 - x0)), sy - (y0 + t * (y1 - y0))) <= 4
        ok[ya:yb, xa:xb] &= ~vicino
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
    mat, idx = lastricato()
    out[mat] = MATTONI[idx[mat]]
    # i mattoni rotti sono un filo piu' alti del prato: sotto lo spigolo, sull'erba, un'ombrina di un gradino
    sotto = np.zeros((H, W), bool)
    sotto[1:] = mat[:-1] & ~mat[1:]
    out = scendi(out, 1, sotto)
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
                 "goblin al centro, di spalle, che divora la preda; la meta' di nord lastricata coi mattoni della pianura, "
                 "con la strada che esce verso la pianura, quella di sud (da dove si arriva) solo prato.",
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
