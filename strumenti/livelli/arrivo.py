# L'arrivo nelle Pianure: le due zone prima del pasto del goblin (docs/storia.md, "L'arrivo nelle Pianure di Redenna":
# il proiettore lascia il protagonista, lui si guarda intorno, il data pad suona ed e' la Guida, che apre la mappa e
# gliela spiega).
#
#   python3 strumenti/livelli/arrivo.py [cartella_anteprime]          (serve numpy e Pillow)
#   python3 strumenti/livelli/arrivo.py --cerchio prova.png            (solo il cerchio, in fretta, per provarlo)
#
# - 'comparsa': il prato dove appare Lei. Bru: "nel punto in cui appari il terreno deve essere deformato tipo cerchio nel
#   grano ma come se lo spazio fosse stato distorto". Un cerchio nel grano vero e proprio (il nido al centro, gli
#   anelli d'erba posata, i raggi, i cerchietti attorno) e poi lo spazio torto: tutto e' girato attorno al centro,
#   tanto al centro e niente lontano (i raggi diventano spirali, i cerchietti virgole, le macchie del prato attorno si
#   avvolgono), e gli anelli ondeggiano. L'erba posata e' chiara, pettinata nel verso dell'anello, e luccica dalla
#   parte della luce (in alto a sinistra); l'erba in piedi fra gli anelli e' fitta e piu' scura, ci fa ombra sopra e ci
#   sporge con le foglioline, come i bordi delle macchie del prato. A nord si esce verso la radura della Guida.
# - 'guida': uno spazio vuoto. Bru: "dove il personaggio si ferma a discutere con l'AI che gli spiega le basi della
#   mappa". Una radura di prato coi fiori, gli alberi solo attorno; a nord il pasto del goblin, a sud la comparsa.
#
# Le tre zone si attaccano in una fascia larga in mezzo (x 440-840): le mappe sono larghe uguali (1280), quindi Lei
# passa dall'una all'altra tenendo la sua x (strumenti/prova_corsa/costruisci.py, COLLEGAMENTI).
# Scrive art/livelli/<zona>.png, <zona>_pezzi.json, <zona>_passi.png, <zona>_prato.png, <zona>_fiori.json, <zona>.json.
import json
import os
import sys

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
sys.path.insert(0, os.path.join(QUI, '..'))
import ruscello_radenna as rr     # noqa: E402  i pezzi, il prato e le regole del ruscello
import prato as _prato            # noqa: E402
import fiori as _fiori            # noqa: E402
import pasto_goblin as pg         # noqa: E402  le ombre, i passi, le rampe (le stesse del pasto)

LIV = rr.LIV
PRATO = rr.PRATO
RAMPA = rr.PRATO_RAMPA            # profondo, scuro, medio, base, luce
PROFONDO, SCURO, MEDIO, BASE, LUCE = range(5)
W = 1280
FASCIA = (440, 840)               # dove si passa da una zona all'altra

# ---------------------------------------------------------------- il cerchio storto
SQ = 0.72                         # il suolo di tre quarti: un cerchio per terra e' un ovale (come le vasche)
TORSIONE, L_TORSIONE = 2.6, 125.0                     # quanto gira al centro (radianti) e fin dove arriva
ONDE, L_ONDE = ((0.07, 3, 0.8), (0.04, 2, -1.1)), 110.0   # gli anelli che ondeggiano: (quanto, lobi, fase)
NIDO = 19                                             # il nido al centro, dove appare Lei
ANELLI = ((28, 42), (54, 62), (82, 92))               # gli anelli d'erba posata (dal raggio al raggio)
RAGGI = [2 * np.pi * k / 5 + 0.35 for k in range(5)]  # i raggi fra il secondo e il terzo anello
SATELLITI = [(108.0, a + np.pi / 5, 11.0) for a in RAGGI]  # i cerchietti fuori (raggio, angolo, grandezza)
LUCE_DA = np.arctan2(-1.0, -1.0)                      # la luce viene da in alto a sinistra
PASSO_RIGHE = 3.0                                     # l'erba posata: una riga di steli ogni tre pixel


def polari(H, W_, c):
    """raggio (nella misura delle x: le y sono schiacciate) e angolo di ogni pixel attorno al centro c"""
    yy, xx = np.mgrid[0:H, 0:W_].astype(float)
    dx, dy = xx - c[0], (yy - c[1]) / SQ
    return np.hypot(dx, dy), np.arctan2(dy, dx)


def disfa(r, th):
    """dove stava, prima che lo spazio si torcesse, il punto che ora e' a raggio r e angolo th: girato indietro
    (tanto al centro, niente lontano) e coi cerchi ondulati"""
    g = np.exp(-(r / L_TORSIONE) ** 2)
    w = np.exp(-(r / L_ONDE) ** 2)
    eps = w * sum(a * np.sin(k * th + f) for a, k, f in ONDE)
    return r * (1 + eps), th - TORSIONE * g


def _bilineare(F, x, y):
    H, W_ = F.shape
    x = np.clip(x, 0, W_ - 1.001); y = np.clip(y, 0, H - 1.001)
    x0, y0 = x.astype(int), y.astype(int)
    fx, fy = x - x0, y - y0
    return (F[y0, x0] * (1 - fx) * (1 - fy) + F[y0, x0 + 1] * fx * (1 - fy) + F[y0 + 1, x0] * (1 - fx) * fy
            + F[y0 + 1, x0 + 1] * fx * fy)


def deforma_macchie(c, fin_dove=132, scuro=0.42):
    """per il prato: le macchie prese da dove stavano prima della torsione (si avvolgono attorno al centro); e dentro
    il cerchio l'erba in piedi e' fitta: il campo sta fra le due soglie (il medio, a tratti lo scuro)"""
    def f(F):
        H, W_ = F.shape
        r, th = polari(H, W_, c)
        rho, phi = disfa(r, th)
        G = _bilineare(F, c[0] + rho * np.cos(phi), c[1] + SQ * rho * np.sin(phi))
        t1, t2 = np.quantile(F, [1 - scuro, 1 - scuro * 0.36])
        lo, hi = np.quantile(F, [0.05, 0.95])
        alto = t1 + 0.02 + np.clip((G - lo) / (hi - lo), 0, 1) * (t2 - t1) * 1.35
        w = np.clip((fin_dove + 18 - rho) / 30.0, 0, 1)
        return G * (1 - w) + alto * w
    return f


def _caso(*k):
    """un numero fra 0 e 1 fisso per ogni combinazione di interi"""
    h = np.zeros(np.broadcast(*k).shape, np.int64) + 1469598103
    for v in k:
        h = (h ^ (np.asarray(v, np.int64) & 0xffffffff)) * 16777619 % 4294967296
        h = (h ^ (h >> 13)) * 1274126177 % 4294967296
    return (h % 100003) / 100003.0


def posato(H, W_, c):
    """l'erba posata del cerchio: per ogni pixel il gradino della rampa del prato (-1 dove l'erba e' in piedi).
    Ogni pezzo ha le sue coordinate: 'v' attraverso le righe degli steli, 'u' lungo; negli anelli le righe girano
    attorno, nei raggi vanno dritte (in fuori), nei cerchietti girano attorno al loro centro, nel nido sono una
    spirale. Le righe sono a tratti; dalla parte della luce sono chiare (luce), dall'altra scure (medio)"""
    r, th = polari(H, W_, c)
    rho, phi = disfa(r, th)
    u = np.zeros((H, W_)); v = np.zeros((H, W_)); pezzo = np.full((H, W_), -1)
    nido = rho < NIDO
    v[nido] = rho[nido] + 2 * PASSO_RIGHE * (phi[nido] / (2 * np.pi))
    u[nido] = phi[nido] * np.maximum(rho[nido], 4)
    pezzo[nido] = 0
    for i, (a, b) in enumerate(ANELLI):
        m = (rho >= a) & (rho < b)
        v[m] = rho[m]; u[m] = phi[m] * rho[m]; pezzo[m] = 1 + i
    a, b = ANELLI[1][1], ANELLI[2][0]
    for k, ak in enumerate(RAGGI):
        d = rho * np.sin(phi - ak)
        m = (np.abs(d) < 4.5) & (np.cos(phi - ak) > 0) & (rho >= a - 1) & (rho < b + 1) & (pezzo < 0)
        v[m] = d[m] + 30; u[m] = rho[m]; pezzo[m] = 10 + k
    X, Y = rho * np.cos(phi), rho * np.sin(phi)
    for k, (rs, ang, gr) in enumerate(SATELLITI):
        px, py = X - rs * np.cos(ang), Y - rs * np.sin(ang)
        dd = np.hypot(px, py)
        m = (dd < gr) & (pezzo < 0)
        v[m] = dd[m]; u[m] = np.arctan2(py[m], px[m]) * np.maximum(dd[m], 3); pezzo[m] = 20 + k
    piatta = pezzo >= 0
    s = np.floor(v / PASSO_RIGHE).astype(int)
    riga = (v / PASSO_RIGHE - s) < 0.36
    tratto = ((u + _caso(s, pezzo) * 11) % 11) < 8
    chiaro = 0.3 + 0.7 * (0.5 + 0.5 * np.cos(th - LUCE_DA))   # dalla parte della luce l'erba posata luccica
    L = np.full((H, W_), -1)
    L[piatta] = BASE
    linea = piatta & riga & tratto
    L[linea] = np.where(_caso(s, pezzo, 7)[linea] < chiaro[linea], LUCE, MEDIO)
    return L, rho


def cerchio(out, c, rng):
    """il cerchio storto sul prato fatto (out: i colori, float): l'erba posata, l'ombra dell'erba in piedi sopra
    quella posata (la luce viene da in alto a sinistra: l'ombra cade in basso a destra), le foglioline dell'erba in
    piedi che sporgono nell'erba posata e qualche stelo chiaro dell'erba posata che resta su; poi via i pixel soli.
    Rende anche dove non vanno i fiori (il cerchio e un po' attorno)"""
    H, W_ = out.shape[:2]
    L, rho = posato(H, W_, c)
    piatta = L >= 0
    # l'ombra: un pixel d'erba posata con l'erba in piedi subito in alto a sinistra (l'erba e' bassa: un pixel)
    inpiedi = ~piatta
    om = np.zeros((H, W_), bool)
    om[1:, 1:] = inpiedi[:-1, :-1]
    om &= piatta
    L[om] = np.maximum(L[om] - 1, MEDIO)
    for i in range(5):
        out[L == i] = RAMPA[i]
    # le foglioline ai bordi: dall'erba in piedi nell'erba posata (dello stesso colore dell'erba in piedi accanto) e,
    # meno, dall'erba posata nell'erba in piedi (chiare)
    d_dentro = _prato.distanza(inpiedi, 3)                # quanti passi dall'erba in piedi, nell'erba posata
    d_fuori = _prato.distanza(piatta, 3)
    vicino = np.rint(out).astype(int)
    ys, xs = np.nonzero(((d_dentro >= 1) & (d_dentro <= 2)) | ((d_fuori >= 1) & (d_fuori <= 2)))
    for y, x in zip(ys, xs):
        f = _prato.FOGLIE[rng.integers(len(_prato.FOGLIE))]
        if piatta[y, x] and rng.random() < (0.06 if d_dentro[y, x] == 1 else 0.025):
            yy, xx = max(0, y - 2), max(0, x - 2)
            vic = inpiedi[yy:y + 3, xx:x + 3]
            if vic.any():
                py, px = np.argwhere(vic)[0]
                col = vicino[yy + py, xx + px].astype(float)
                _prato.timbra(out, f, x - 1, y - 1, col, piatta)
        elif inpiedi[y, x] and rho[y, x] < 120 and rng.random() < 0.03:
            _prato.timbra(out, f, x - 1, y - 1, RAMPA[BASE], inpiedi)
    q = np.clip(np.rint(out), 0, 255).astype(np.uint8)
    _prato.pulisci(q)
    out[:] = q
    return rho < 150


# ---------------------------------------------------------------- le due zone
# (nome, x, y del piede). In alto gli alberi esotici a tronco dritto (la chioma esce dalla mappa, come un bosco), ai
# lati e in basso quelli a serpente, interi; la fascia di mezzo (FASCIA) resta libera per passare
ZONE = {
    'comparsa': {
        'H': 720, 'seme': 83, 'semi_fiori': (91, 37), 'nome': "Il prato dell'arrivo",
        'cerchio': (640, 440),
        'alberi': [('albero_alto_dritto_1', 110, 170), ('albero_alto_dritto_2', 330, 132),
                   ('albero_alto_dritto_3', 952, 140), ('albero_alto_dritto_1', 1172, 176),
                   ('albero_alto_2', 66, 430), ('albero_alto_3', 1222, 404),
                   ('albero_alto_4', 150, 704), ('albero_alto_1', 340, 716), ('albero_alto_3', 940, 714),
                   ('albero_alto_2', 1140, 700),
                   ('cespuglio_1', 250, 330), ('cespuglio_2', 1040, 300), ('cespuglietto_1', 214, 560),
                   ('cespuglio_2', 1066, 566), ('cespuglio_1', 560, 714), ('cespuglietto_1', 728, 712),
                   ('cespuglietto_1', 410, 236), ('cespuglietto_1', 876, 226)],
        'sassi': [('sasso_4', 296, 470), ('sassolino_2', 312, 476), ('masso_basso_4', 990, 640),
                  ('sasso_2', 862, 262), ('sassolino_1', 1110, 470), ('sasso_5', 180, 250), ('sassolino_3', 196, 256)],
        'partenza': [640, 440], 'verso': [0, 1],
        'stanze': [{"nome": "Il cerchio storto", "rett": [500, 340, 780, 540]},
                   {"nome": "Verso la radura", "rett": [440, 0, 840, 200]},
                   {"nome": "Il prato dell'arrivo", "rett": [0, 0, W, 720]}],
        'nota': "Il prato dove il proiettore lascia Lei, fatto da strumenti/livelli/arrivo.py: dove appare l'erba e' "
                "posata a cerchi come un cerchio nel grano, ma torta come se lo spazio si fosse distorto; a nord la "
                "radura della Guida.",
    },
    'guida': {
        'H': 640, 'seme': 71, 'semi_fiori': (73, 41), 'nome': "La radura della Guida",
        'cerchio': None,
        'alberi': [('albero_alto_dritto_2', 104, 160), ('albero_alto_dritto_1', 322, 128),
                   ('albero_alto_dritto_3', 958, 134), ('albero_alto_dritto_2', 1178, 168),
                   ('albero_alto_3', 62, 420), ('albero_alto_1', 1226, 380),
                   ('albero_alto_4', 300, 636), ('albero_alto_2', 990, 634), ('albero_alto_1', 120, 628),
                   ('albero_alto_4', 1170, 630),
                   ('cespuglio_2', 236, 290), ('cespuglio_1', 1060, 290), ('cespuglietto_1', 400, 230),
                   ('cespuglietto_1', 880, 222), ('cespuglio_2', 380, 626), ('cespuglietto_1', 900, 628)],
        'sassi': [('sasso_5', 260, 470), ('sassolino_3', 276, 476), ('sasso_2', 1030, 500), ('sassolino_1', 1046, 504),
                  ('masso_basso_4', 200, 380)],
        'partenza': [640, 600], 'verso': [0, -1],
        'stanze': [{"nome": "La Guida: le basi della mappa", "rett": [480, 210, 800, 450]},
                   {"nome": "Verso il pasto del goblin", "rett": [440, 0, 840, 180]},
                   {"nome": "Dal prato dell'arrivo", "rett": [440, 520, 840, 640]},
                   {"nome": "La radura", "rett": [0, 0, W, 640]}],
        'nota': "La radura della Guida, fatta da strumenti/livelli/arrivo.py: uno spazio vuoto dove Lei si ferma e la "
                "Guida le spiega la mappa; a nord il pasto del goblin, a sud il prato dell'arrivo.",
    },
}
SASSI_FUSI = 'pezzi/pasto/fusi/'          # i sassi coi colori nuovi e il contorno fuso (pasto_goblin.py)


def impiedi(z):
    """(nome, file, x, y del piede nel mondo, piede nel disegno, impronta) delle cose in piedi della zona"""
    tutte = []
    for (n, x, y) in z['alberi']:
        f, piede, (w, h) = rr.pezzo(n)
        tutte.append((n, 'pezzi/ruscello/fusi/' + os.path.basename(f), x, y, piede, rr.impronta(n, w, h)))
    for (n, x, y) in z['sassi']:
        f, piede, (w, h) = rr.pezzo(n)
        assert os.path.exists(os.path.join(LIV, SASSI_FUSI + os.path.basename(f))), n
        tutte.append((n, SASSI_FUSI + os.path.basename(f), x, y, piede, rr.impronta(n, w, h)))
    return tutte


def fai_zona(nome, anteprime=None):
    z = ZONE[nome]
    H = z['H']
    tutte = impiedi(z)
    segni = []
    c = z['cerchio']
    p4, _ = _prato.prato(H, W, seme=z['seme'], tav=PRATO, fiori=segni, deforma=deforma_macchie(c) if c else None)
    out = p4[3].astype(float)
    senza_fiori = np.zeros((H, W), bool)
    if c:
        senza_fiori = cerchio(out, c, np.random.default_rng(z['seme']))
    out, ombra = pg.ombre(out, tutte)
    rr._salva(out, os.path.join(LIV, nome + '.png'))
    rr._salva(pg.passi(tutte, misura=(H, W)), os.path.join(LIV, nome + '_passi.png'))
    q = np.rint(out).astype(int)
    erba = np.zeros((H, W), bool)
    for col in PRATO.values():
        erba |= np.all(q == np.array(col), axis=-1)
    pr = np.zeros((H, W, 4), np.uint8); pr[erba] = (255, 255, 255, 255)
    rr._salva(pr, os.path.join(LIV, nome + '_prato.png'))
    # i fiori in piedi: come al pasto (dove il prato li avrebbe messi, al sole, dove si cammina); non nel cerchio
    macchie = _prato.liscio(H, W, 170, 110, z['semi_fiori'][0])
    q1, q2 = np.quantile(macchie, [0.62, 0.86])
    rng = np.random.default_rng(z['semi_fiori'][1])
    nomi = list(_fiori.SPECIE)
    ok = pg.passi(tutte, bordi=False, misura=(H, W))[..., 3] > 0
    fiori = []
    for (y, x, _g) in segni:
        piccolo = rng.random() < 0.45
        if y < 14 or x < 6 or x > W - 7 or y > H - 3 or senza_fiori[y, x]:
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
        json.dump({"_nota": "Scritto da strumenti/livelli/arrivo.py: non toccare a mano. I fiori del prato in piedi: "
                            "[x, y del piede nel mondo, specie (la riga di terreni/fiori.png, fiori.py)].",
                   "fiori": fiori}, f, ensure_ascii=False)
        f.write('\n')
    with open(os.path.join(LIV, nome + '_pezzi.json'), 'w') as f:
        json.dump({"_nota": "Scritto da strumenti/livelli/arrivo.py: non toccare a mano. Ogni pezzo e' [file (da "
                            "art/livelli/), x, y del piede nel mondo, x, y del piede nel disegno].",
                   "pezzi": [[t[1], int(t[2]), int(t[3]), int(t[4][0]), int(t[4][1])]
                             for t in sorted(tutte, key=lambda t: t[3])]},
                  f, indent=1, ensure_ascii=False)
        f.write('\n')
    pianta = {
        "_nota": z['nota'],
        "nome": z['nome'],
        "mappa": nome + ".png", "scala": 1, "pixel": 1, "ingrandimento": 2,
        "pezzi": nome + "_pezzi.json", "passi": nome + "_passi.png", "prato": nome + "_prato.png",
        "fiori": nome + "_fiori.json",
        "limiti": [0, 0, W, H],
        "partenza": z['partenza'], "verso": z['verso'],
        "stanze": z['stanze'],
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
    print('%s: mappa %dx%d, %d cose in piedi, %d fiori' % (nome, W, H, len(tutte), len(fiori)))


# ---------------------------------------------------------------- prova veloce del solo cerchio
def prova_cerchio(percorso):
    H, W_ = 360, 480
    c = (240, 190)
    p4, _ = _prato.prato(H, W_, seme=83, tav=PRATO, fiori=[], deforma=deforma_macchie(c))
    out = p4[3].astype(float)
    cerchio(out, c, np.random.default_rng(5))
    a = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8))
    a.resize((W_ * 2, H * 2), Image.NEAREST).save(percorso)
    print(percorso)


if __name__ == '__main__':
    if len(sys.argv) > 2 and sys.argv[1] == '--cerchio':
        prova_cerchio(sys.argv[2])
    else:
        for n in ZONE:
            fai_zona(n, sys.argv[1] if len(sys.argv) > 1 else None)
