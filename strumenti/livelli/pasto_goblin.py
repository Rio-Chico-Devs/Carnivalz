# Il pasto del goblin: la seconda tappa delle pianure (docs/mondi.md: "il pasto del goblin, nel recinto di pietre a
# nord-est"; docs/storia.md: "una pressione strana, un posto tranquillo, poi gnarl... barf, crunch..."). Bru: "la zona
# del pasto del goblin dove il goblin e' al centro".
#
#   python3 strumenti/livelli/pasto_goblin.py [anteprima.png]      (serve numpy e Pillow)
#
# Una radura dentro un recinto di massi, nel prato; al centro il goblin (strumenti/nemici/goblin_tipico) che mangia
# davanti al fuoco, con la carne sullo spiedo, un tronco per sedersi e le ossa sparse. Bru: il pavimento "meta' di
# mattoni come la scena successiva e la meta' da dove si arriva senza sentiero, solo radura". Quindi la meta' di nord
# del recinto e' lastricata coi mattoni della pianura aperta (la tappa dopo: la strada del ruscello, stesso kit di
# Bru, stessi colori), col cordolo lungo il giro e rotta verso sud; la meta' di sud, da dove arriva Lei (dalla
# capsula), e' prato, senza sentiero, e le ossa restano nell'erba. Dal varco di nord-ovest la strada di mattoni va
# verso la pianura. Attorno il prato coi fiori al vento e gli alberi esotici, come al ruscello (stessi pezzi, stesso
# prato, stesse regole delle tavolozze di Bru).
#
# Scrive art/livelli/pasto.png (il terreno con le cose piatte: mattoni, cenere, ossa, ombre), pasto_pezzi.json (le cose
# in piedi), pasto_passi.png (dove si cammina), pasto_prato.png (dove i passi pestano l'erba), pasto_fiori.json,
# pasto.json; i pezzi nuovi in art/livelli/pezzi/pasto/ (il fuoco a fotogrammi, il tronco, il goblin che mastica).
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

LIV = rr.LIV
NUOVI = os.path.join(LIV, 'pezzi', 'pasto')
FUSI = 'pezzi/pasto/fusi/'
GOBLIN = os.path.join(QUI, '..', 'nemici', 'goblin_tipico', 'goblin_tipico.png')
W, H = 1280, 800
C = (640, 400)                          # il centro del recinto
ANELLO = (172, 106)                     # il recinto di massi: i raggi dell'ellisse (vista di tre quarti)
LASTRICO = (156, 94)                    # il lastricato: l'ellisse di cui resta la meta' di nord
ROTTO = 434                             # la riga (mossa) dove il lastricato si rompe: sotto, verso chi arriva, prato
VARCHI = [(90, 12), (213, 12)]          # i varchi nel recinto: angolo (0 a destra, 90 giu') e mezza ampiezza
# la strada di mattoni verso la pianura: parte dal lastricato ed esce dal varco di nord-ovest
STRADA = [(548, 372), (503, 342), (452, 306), (380, 268), (322, 214), (266, 140), (224, 60), (200, 0)]
PRATO = rr.PRATO
TERRA = np.array(_tav.rampa((150, 112, 78), 5, 0.30, 0.80), float)       # profondo, scuro, medio, chiaro, luce
CENERE = np.array(_tav.rampa((110, 104, 100), 4, 0.25, 0.70), float)
OSSO = np.array(_tav.rampa((226, 214, 186), 4, 0.42, 0.95), float)
CORTECCIA = np.array(_tav.rampa((120, 82, 58), 5, 0.24, 0.72), float)
CARNE = np.array(_tav.rampa((150, 72, 52), 4, 0.28, 0.72), float)
PIETRA = rr.P_NUOVA
# i mattoni della pianura: i sei colori del kit di Bru (terreni/strade_radenna, dal piu' scuro al piu' chiaro) vanno,
# nella mappa del ruscello, sui gradini 1-6 della rampa della pietra (riadatta(), controllato sulla mappa vera)
KIT = [(44, 71, 50), (66, 84, 69), (84, 103, 85), (108, 122, 105), (120, 135, 117), (141, 155, 135)]
MATTONI = PIETRA[1:7]
CORDOLO = [0, 2, 5, 3, 1, 0]            # il cordolo dal bordo verso dentro, come nel kit (scuro, luce, solco)
MOTIVO = 'diamanti'                        # dentro il lastricato: 'righe' (la spina della strada) o 'diamanti' (il nodo)
FIAMMA = np.array([(176, 58, 52), (232, 112, 48), (252, 172, 66), (255, 222, 120), (255, 248, 214)], float)
BRACE = np.array([(200, 70, 44), (246, 136, 56), (255, 200, 98)], float)

# ---------------------------------------------------------------- dove stanno le cose
FUOCO = (676, 394)                      # il piede del fuoco (il mezzo del cerchio di pietre)
GOBLIN_PIEDE = (626, 424)               # il goblin, al centro, davanti al fuoco, guarda verso chi arriva
TRONCO = (584, 384)
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
# le ossa per terra (piatte, nella mappa): (forma, x, y)
OSSA = [('osso', 712, 440), ('osso_s', 586, 452), ('teschio', 726, 420), ('osso', 690, 362), ('costole', 560, 410),
        ('osso_s', 668, 456), ('osso', 548, 372), ('osso_s', 742, 386)]
PARTENZA = [612, 776]
STANZE = [
    {"nome": "Il pasto del goblin", "rett": [470, 290, 810, 510]},
    {"nome": "L'arrivo", "rett": [500, 510, 760, 800]},
    {"nome": "Verso la pianura", "rett": [160, 0, 510, 350]},
    {"nome": "Il prato", "rett": [0, 0, W, H]},
]
GIRO = [[612, 776], [618, 700], [614, 620], [636, 548], [640, 500], [600, 470], [560, 430], [520, 380],
        [500, 344], [440, 300], [360, 250], [300, 180], [250, 100], [237, 84]]


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


def fuoco():
    """il fuoco col cerchio di pietre, i ciocchi, le braci e lo spiedo con la carne; 4 fotogrammi (le fiamme)"""
    w, h = 50, 46
    fx, fy = 25, 40                         # il piede: il mezzo del cerchio di pietre
    base = np.zeros((h, w, 4), float)
    yy, xx = np.mgrid[0:h, 0:w]
    # i ciocchi incrociati sotto il fuoco (corteccia, la punta bruciata)
    for (x0, y0, x1, y1) in ((13, 41, 36, 35), (14, 35, 37, 41), (18, 42, 31, 33)):
        n = 40
        for t in np.linspace(0, 1, n):
            x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
            for dy in (-1, 0, 1):
                X, Y = int(round(x)), int(round(y + dy))
                if 0 <= X < w and 0 <= Y < h:
                    k = 3 if dy < 0 else (2 if dy == 0 else 1)
                    if 0.35 < t < 0.65:
                        k = 0 if dy > 0 else 1          # bruciato nel mezzo
                    base[Y, X, :3] = CORTECCIA[k]; base[Y, X, 3] = 255
    # le braci fra i ciocchi
    for (x, y, k) in ((22, 37, 2), (25, 38, 1), (28, 37, 2), (24, 36, 0), (27, 39, 0), (21, 39, 1), (30, 38, 1)):
        base[y, x, :3] = BRACE[k]; base[y, x, 3] = 255
    # il cerchio di pietre: otto sassi tondi sull'ellisse
    for i in range(9):
        a = np.radians(i * 40 + 10)
        cx, cy = fx + 17 * np.cos(a), fy - 2 + 5.5 * np.sin(a)
        m = ((xx - cx) / 3.2) ** 2 + ((yy - cy) / 2.4) ** 2 <= 1
        if np.sin(a) < -0.2:                    # dietro: un po' coperte dai ciocchi
            m &= base[..., 3] == 0
        lum = np.clip(-(xx - cx) * 0.25 - (yy - cy) * 0.45, -1, 1)
        k = np.where(lum > 0.3, 6, np.where(lum < -0.3, 3, 5))
        base[m, :3] = PIETRA[k[m]]; base[m, 3] = 255
    # lo spiedo: due forcelle ai lati e il bastone con la carne in mezzo (sopra le fiamme)
    for x in (4, 45):
        for y in range(15, 41):
            base[y, x, :3] = CORTECCIA[1]; base[y, x, 3] = 255
            base[y, x + 1, :3] = CORTECCIA[2] if x == 4 else CORTECCIA[1]; base[y, x + 1, 3] = 255
        for dx, dy in ((-1, -1), (-2, -2), (2, -1), (3, -2)):
            base[15 + dy, x + dx, :3] = CORTECCIA[1]; base[15 + dy, x + dx, 3] = 255
    for x in range(3, 48):
        base[14, x, :3] = CORTECCIA[0]; base[14, x, 3] = 255
    carne = ((xx - 25) / 7.5) ** 2 + ((yy - 14.5) / 5.0) ** 2 <= 1
    lum = -(xx - 25) * 0.18 - (yy - 14.5) * 0.35
    kc = np.where(lum > 0.9, 3, np.where(lum > -0.2, 2, np.where(lum > -1.1, 1, 0)))
    base[carne, :3] = CARNE[kc[carne]]; base[carne, 3] = 255
    for x, y in ((21, 12), (24, 11), (28, 13), (22, 16), (27, 16)):        # le bruciature e il grasso lucido
        base[y, x, :3] = CARNE[0]
    base[11, 23, :3] = FIAMMA[4]; base[12, 22, :3] = OSSO[3]
    # l'osso che esce dalla carne, ai due lati del bastone
    for x in (16, 17, 33, 34):
        base[14, x, :3] = OSSO[2]
    base = _contorna(base, TERRA[0])
    # le fiamme, quattro fotogrammi: lingue che salgono dai ciocchi e guizzano, sotto la carne
    fot = []
    rng = np.random.default_rng(7)
    for f in range(4):
        a = base.copy()
        fl = np.zeros((h, w))
        for i, (cx, alto) in enumerate(((19, 12), (23, 17), (26, 19), (30, 14), (33, 9))):
            alto = alto + (2 if (i + f) % 2 == 0 else -1) + int(rng.integers(-1, 2))
            sway = np.sin((f + i * 1.7) * np.pi / 2) * 1.2
            for y in range(36 - alto, 37):
                t = (36 - y) / float(alto)
                larg = (1 - t) ** 0.7 * 3.4
                x0 = cx + sway * t
                for x in range(int(np.floor(x0 - larg)), int(np.ceil(x0 + larg)) + 1):
                    d = abs(x - x0) / max(larg, 0.4)
                    if d <= 1 and 0 <= x < w:
                        fl[y, x] = max(fl[y, x], (1 - d) * (1 - t * 0.55))
        k = np.zeros((h, w), int) - 1
        k[fl > 0.02] = 0; k[fl > 0.25] = 1; k[fl > 0.45] = 2; k[fl > 0.62] = 3; k[fl > 0.8] = 4
        sopra = (k >= 0) & ~(carne | (yy == 14) & (xx > 2) & (xx < 48))
        for v in range(5):
            m = sopra & (k == v)
            a[m, :3] = FIAMMA[v]; a[m, 3] = 255
        # qualche scintilla che sale
        for j in range(3):
            sx, sy = int(18 + rng.integers(0, 15)), int(4 + rng.integers(0, 9) - f * 2) % 12 + 2
            if a[sy, sx, 3] == 0:
                a[sy, sx, :3] = FIAMMA[3]; a[sy, sx, 3] = 255
        fot.append(a)
    return fot, (fx, fy)


def tronco():
    """un tronco caduto, per sedersi: di traverso, la corteccia con le crepe, il taglio con gli anelli a destra"""
    w, h = 52, 24
    a = np.zeros((h, w, 4), float)
    for x in range(3, 45):
        for y in range(4, 20):
            t = (y - 4) / 15.0
            k = 4 if t < 0.15 else (3 if t < 0.4 else (2 if t < 0.75 else 1))
            if _h(x * 7 + y, 3) < 0.12 and 0.15 < t < 0.85:
                k = max(0, k - 2)                     # le crepe della corteccia
            a[y, x, :3] = CORTECCIA[k]; a[y, x, 3] = 255
    # il lato rotto a sinistra (frastagliato) e il taglio a destra con gli anelli
    for y in range(4, 20):
        for x in range(0, 3 + int(_h(y, 9) * 3)):
            a[y, x, 3] = 0
    yy, xx = np.mgrid[0:h, 0:w]
    taglio = ((xx - 45) / 4.6) ** 2 + ((yy - 12) / 8.2) ** 2 <= 1
    r = np.sqrt(((xx - 45) / 4.6) ** 2 + ((yy - 12) / 8.2) ** 2)
    anelli = np.where((r > 0.8)[..., None], CORTECCIA[2][None, None],
                      np.where(((r * 4).astype(int) % 2 == 0)[..., None], OSSO[2][None, None] * 0.9, OSSO[1][None, None]))
    a[taglio, :3] = anelli[taglio]; a[taglio, 3] = 255
    a = _contorna(a, TERRA[0])
    return a, (24, 21)


def goblin():
    """il goblin di fronte (la prima posa del suo foglio) che mastica: nel secondo fotogramma la testa scende di un
    pixel, tutta intera"""
    g = np.asarray(Image.open(GOBLIN).convert('RGBA')).astype(float)[0:75, 0:57]
    ys, xs = np.nonzero(g[..., 3] > 0)
    y0, y1, x0, x1 = ys.min() - 2, ys.max() + 1, xs.min() - 1, xs.max() + 2
    a = g[y0:y1, x0:x1]
    piede_y = a.shape[0] - 1
    fondo = a[..., 3] > 0
    xs = np.nonzero(fondo[piede_y])[0]
    piede = (int((xs.min() + xs.max()) // 2), piede_y)
    # la testa: dall'alto fino al mento (sopra le spalle); scende di un pixel
    collo = 50 - y0
    b = a.copy()
    testa = a[:collo].copy()
    b[1:collo + 1][testa[..., 3] > 0] = testa[testa[..., 3] > 0]
    b[0] = 0
    b[1:collo + 1][(testa[..., 3] == 0) & (a[1:collo + 1, ..., 3] > 0) & (np.arange(collo)[:, None] < collo - 1)] = 0
    return [a, b], piede


def prepara_pezzi():
    os.makedirs(os.path.join(LIV, FUSI), exist_ok=True)
    fot, piede_f = fuoco()
    _salva(fot[0], os.path.join(NUOVI, 'fuoco.png'))
    _salva(np.concatenate(fot, 1), os.path.join(NUOVI, 'fuoco_fotogrammi.png'))
    t, piede_t = tronco()
    _salva(rr.fondi(t, True), os.path.join(NUOVI, 'tronco.png'))
    gf, piede_g = goblin()
    _salva(gf[0], os.path.join(NUOVI, 'goblin.png'))
    _salva(np.concatenate(gf, 1), os.path.join(NUOVI, 'goblin_fotogrammi.png'))
    for n, p in (('fuoco', piede_f), ('tronco', piede_t), ('goblin', piede_g)):
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
    for n, (x, y), imp in (('fuoco', FUOCO, (22, 8)), ('tronco', TRONCO, (24, 6)), ('goblin', GOBLIN_PIEDE, (16, 6))):
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
    il cordolo lungo il giro e lungo la strada. Verso sud il lastricato e' rotto a mattonelle: sopra una linea mossa
    sono intere (qualcuna manca), su quella linea sono spezzate, sotto non ci sono piu' (qualche coccio rimasto nel
    prato), e vicino alla rottura l'erba cresce nelle fughe; sotto c'e' solo prato. La strada di mattoni esce dal
    varco di nord-ovest (il motivo del kit piegato lungo la curva, come al ruscello). Ritorna la maschera e l'indice
    di MATTONI"""
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
    fuori = via & ~ellisse
    col = np.clip(np.rint(V + 14.5).astype(int), 6, 22)
    idx[fuori] = st[S.astype(int) % 55, col][fuori]
    # il solco dove la strada entra nel lastricato
    attacco = fuori & (np.roll(ellisse, 1, 0) | np.roll(ellisse, -1, 0) | np.roll(ellisse, 1, 1) | np.roll(ellisse, -1, 1))
    idx[attacco] = 0
    for k in range(1, 7):
        idx[mat & (d == k)] = CORDOLO[k - 1]
    # la rottura: i mattoni che toccano il prato (fuori dal cordolo) hanno lo spigolo scuro
    vicini = np.ones((H, W), bool)
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        vicini &= np.roll(np.roll(mat, dy, 0), dx, 1)
    idx[mat & ~vicini & (d > 6)] = 1
    idx[~mat] = -1
    return mat, idx


def cenere(out):
    """attorno al fuoco i mattoni anneriti (due gradini piu' giu' sulla rampa della pietra) e in mezzo la cenere
    grigia"""
    yy, xx = np.mgrid[0:H, 0:W]
    fx, fy = FUOCO[0], FUOCO[1] - 2
    r = np.sqrt(((xx - fx) / 34.0) ** 2 + ((yy - fy) / 13.0) ** 2)
    f = _prato.liscio(H, W, 5, 5, 61)
    m1 = r + (f - 0.5) * 0.5 < 1.0
    m2 = r + (f - 0.5) * 0.4 < 0.7
    out = scendi(out, 2, m1)
    out[m2] = CENERE[2]
    out[m2 & (f > 0.62)] = CENERE[3]
    return out


FORME = {
    'osso': ['.oo.....oo.', 'oOOoooooOOo', 'oOLLLLLLLOo', '.oo.....oo.'],
    'teschio': ['..ooooo..', '.oLLLLLo.', 'oLLLLLLOo', 'oLkLLkLOo', 'oLLLLLLOo', '.oOLoLOo.', '..o.o.o..'],
    'costole': ['o.o.o.o..', 'L.L.L.L..', 'LoLoLoLoo', 'OLOLOLOLO', 'L.L.L.L..', 'o.o.o.o..'],
}


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


def ossa(out, mat):
    """le ossa sparse per terra (piatte): luce in alto, ombra sotto, il contorno del piu' scuro del terreno su cui
    stanno (nell'erba, dove si arriva, o sui mattoni) e sotto un'ombrina di un gradino"""
    ombrina = np.zeros((H, W), bool)
    for (n, x0, y0) in OSSA:
        forma = FORME[n.replace('_s', '')]
        if n.endswith('_s'):
            forma = [r[::-1] for r in forma[::-1]]
        h, w = len(forma), len(forma[0])
        scuro = MATTONI[0] if mat[y0 - h // 2, x0] else rr.PRATO_RAMPA[0]
        col = {'L': OSSO[3], 'O': OSSO[2], 'o': scuro, 'k': scuro}
        for j, r in enumerate(forma):
            for i, ch in enumerate(r):
                if ch in col:
                    out[y0 - h + j, x0 - w // 2 + i] = col[ch]
        for i in range(w):
            if forma[-1][i] != '.' and 0 <= y0 < H:
                ombrina[y0, x0 - w // 2 + i] = True
    return scendi(out, 1, ombrina)


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
        if n == 'fuoco':
            continue                                     # la cenere fa gia' da ombra, e il fuoco fa luce
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
    out = cenere(out)
    out = ossa(out, mat)
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
                 "goblin al centro che mangia davanti al fuoco; la meta' di nord lastricata coi mattoni della pianura, "
                 "con la strada che esce verso la pianura, quella di sud (da dove si arriva) solo prato.",
        "nome": "Il pasto del goblin",
        "mappa": "pasto.png", "scala": 1, "pixel": 1, "ingrandimento": 2,
        "pezzi": "pasto_pezzi.json", "passi": "pasto_passi.png", "prato": "pasto_prato.png", "fiori": "pasto_fiori.json",
        "animati": {
            "pezzi/pasto/fuoco.png": {"file": "pezzi/pasto/fuoco_fotogrammi.png", "n": 4, "ms": 110},
            "pezzi/pasto/goblin.png": {"file": "pezzi/pasto/goblin_fotogrammi.png", "n": 2, "ms": 260},
        },
        "_animati": "Si muovono sempre (non solo con l'acqua): le fiamme del fuoco e il goblin che mastica.",
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
