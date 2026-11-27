"""Esempi del nuovo stile (lo studio delle immagini 119 e 120): una schermata 480x312 di una nostra scena rifatta con
le regole viste: il prato calmo dove si cammina (un colore, pochi segni d'erba disegnati, radi, in file), la cornice
del bosco come una massa sola che scende al quasi nero verso fuori, l'ombra della cornice sul prato, i verdi ricchi
(le ombre restano verdi), il punto importante nella luce.
Sono schermate di prova (non ancora le mappe del gioco), da confrontare con le stesse inquadrature di adesso.
uso: esempi_stile.py cartella_uscita      (scrive radura.png, arrivo.png, pasto.png)"""
import os
import sys

import numpy as np
from PIL import Image

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
OUT = sys.argv[1]
sys.path.insert(0, os.path.join(REPO, 'strumenti', 'livelli'))
import piante as pt          # noqa: E402  il fogliame a ciuffi
import prato as _prato       # noqa: E402

W, H = 480, 312
# la rampa del verde, dal quasi nero alla luce: le ombre restano verdi (vanno appena verso l'azzurro), le luci verso il
# giallo
V = [(9, 22, 16), (15, 37, 24), (22, 56, 32), (32, 80, 40), (48, 108, 46), (72, 138, 54), (104, 168, 62),
     (140, 198, 78), (192, 228, 118), (226, 242, 160)]
PAV = 7                      # il prato al sole
# i colori delle piante che abbiamo (chioma, muschio, il contorno fuso) sui gradini della rampa nuova
RICOLORA = {(47, 41, 67): 1, (55, 60, 82): 2, (63, 104, 106): 3, (73, 141, 108): 4, (117, 170, 103): 5,
            (161, 195, 118): 6, (199, 220, 138): 8, (53, 62, 78): 1, (65, 70, 94): 2, (77, 121, 116): 3,
            (109, 160, 103): 5, (164, 189, 98): 7, (209, 218, 123): 8}
# il legno dei tronchi a serpente (TRONCO di piante.py) con due gradini piu' scuri sotto, per farlo scendere nel buio
LEGNO = [(24, 18, 34), (42, 34, 66), (69, 62, 116), (110, 64, 100), (130, 66, 93), (172, 105, 88)]


def scuro_di(c):
    """il colore un gradino piu' scuro (sulla rampa del verde o del legno; gli altri verso il verde quasi nero)"""
    c = tuple(int(v) for v in c)
    if c in V:
        return V[max(0, V.index(c) - 1)]
    if c in LEGNO:
        return LEGNO[max(0, LEGNO.index(c) - 1)]
    return tuple(int(round(v * 0.62 + w * 0.38)) for v, w in zip(c, V[1]))


def scendi(img, quanti):
    """ogni pixel scende di 'quanti' gradini (per pixel)"""
    for k in range(1, int(quanti.max()) + 1):
        m = quanti >= k
        cols = {tuple(int(v) for v in img[y, x]) for y, x in zip(*np.nonzero(m))}
        tab = {c: scuro_di(c) for c in cols}
        for y, x in zip(*np.nonzero(m)):
            img[y, x] = tab[tuple(int(v) for v in img[y, x])]


def distanza(m, fino):
    return _prato.distanza(m, fino)


def pezzo(nome):
    """un pezzo nostro (art/livelli/pezzi/ruscello/fusi) coi verdi nuovi; e il piede"""
    import json
    cat = json.load(open(os.path.join(REPO, 'art/livelli/pezzi/catalogo.json')))['pezzi']
    a = np.asarray(Image.open(os.path.join(REPO, 'art/livelli/pezzi/ruscello/fusi', nome + '.png')).convert('RGBA')).copy()
    if nome in cat:
        piede = tuple(cat[nome]['piede'])
    else:
        op = a[..., 3] > 0
        ys, xs = np.nonzero(op)
        giu = ys >= ys.max() - 3
        piede = (int(round(xs[giu].mean())), int(ys.max()))
    jp = os.path.join(REPO, 'art/livelli/pezzi/ruscello', nome + '.json')
    if os.path.exists(jp):
        piede = tuple(json.load(open(jp))['piede'])
    op = a[..., 3] > 0
    for y, x in zip(*np.nonzero(op)):
        c = tuple(int(v) for v in a[y, x, :3])
        if c in RICOLORA:
            a[y, x, :3] = V[RICOLORA[c]]
    return a, piede


def incolla(img, a, x, y, piede, dove=None):
    """il pezzo col piede in (x, y); 'dove' (bool) segna i pixel coperti"""
    h, w = a.shape[:2]
    x0, y0 = int(x - piede[0]), int(y - piede[1])
    for j in range(h):
        yy = y0 + j
        if not 0 <= yy < img.shape[0]:
            continue
        for i in np.nonzero(a[j, :, 3] > 0)[0]:
            xx = x0 + i
            if 0 <= xx < img.shape[1]:
                img[yy, xx] = a[j, i, :3]
                if dove is not None:
                    dove[yy, xx] = True


def lei(img, x, y, foglio='davanti_attesa'):
    a = np.asarray(Image.open(os.path.join(REPO, 'strumenti/protagonisti/lei_chibi', foglio + '.png')).convert('RGBA'))
    f = a[:, 0:40]
    suole = int(np.nonzero((f[..., 3] > 0).any(1))[0].max())
    # l'ombra per terra: un ovale un gradino piu' scuro
    yy, xx = np.mgrid[0:H, 0:W]
    om = ((xx - x) / 11.0) ** 2 + ((yy - y) / 3.2) ** 2 <= 1
    scendi(img, om.astype(int))
    incolla(img, f.copy(), x, y, (20, suole))


# i segni d'erba: pochi, disegnati, sempre gli stessi (come negli esempi: la 'w' e la 'm' di un pixel)
SEGNI = [['...X.....X...', '..X.X.X.X.X..', '.X...X.X...X.', 'X...........X'],
         ['..X...X..', '.X.X.X.X.', 'X...X...X'],
         ['.X....X.', 'X.X..X.X', '...XX...'],
         ['..X..X..X..', '.X.XX.XX.X.', 'X.........X']]
CIUFFI_LUCE = [['.X..X.', 'X.XX.X', '.XXXX.'], ['X..X', '.XX.', '.XX.']]


def segni(img, pavimento, rng, passo_y=18, passo_x=40, dove_no=None):
    """i segni d'erba radi, in file sfalsate: un gradino piu' scuri del prato dove stanno"""
    for j, y in enumerate(range(8, H, passo_y)):
        spost = (passo_x // 2) * (j % 2)
        for x in range(-10 + spost, W, passo_x):
            cx, cy = x + int(rng.integers(-9, 10)), y + int(rng.integers(-3, 4))
            f = SEGNI[int(rng.integers(len(SEGNI)))]
            hh, ww = len(f), len(f[0])
            y0, x0 = cy - hh // 2, cx - ww // 2
            if y0 < 0 or x0 < 0 or y0 + hh >= H or x0 + ww >= W:
                continue
            if not pavimento[y0:y0 + hh, x0:x0 + ww].all():
                continue
            if dove_no is not None and dove_no[y0:y0 + hh, x0:x0 + ww].any():
                continue
            for jj, r in enumerate(f):
                for ii, ch in enumerate(r):
                    if ch == 'X':
                        img[y0 + jj, x0 + ii] = scuro_di(img[y0 + jj, x0 + ii])


def radura(rng, centro=(240, 196), seme=5, raggi=(160, 98), sud=True):
    """la forma liscia della radura: un ovale largo col varco a nord (verso la zona dopo) e, se c'e', a sud"""
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    cx, cy = centro
    e = ((xx - cx) / float(raggi[0])) ** 2 + ((yy - cy) / float(raggi[1])) ** 2
    nord = ((xx - cx) / 40.0) ** 2 + ((yy - 10) / 90.0) ** 2
    d = np.minimum(e, nord)
    if sud:
        d = np.minimum(d, ((xx - cx) / 66.0) ** 2 + ((yy - H) / 46.0) ** 2)
    n = _prato.liscio(H, W, 30, 30, seme) - 0.5
    return d + n * 0.18 < 1.0


def lobi_lungo(liscia, rng, passo=40, r=(24, 38), fuori=0.5, distanza_min=None, varchi=()):
    """i lobi grandi (cespugli fitti) lungo il bordo della radura liscia: centri un poco fuori dal bordo; non nei
    varchi (x0, x1, y0, y1) da dove si passa"""
    d_f = distanza(liscia, 60)
    bordo = ~liscia & (d_f == 1)
    ys, xs = np.nonzero(bordo)
    centri = []
    for i in rng.permutation(len(ys)):
        y, x = int(ys[i]), int(xs[i])
        if any(a <= x <= b and c <= y <= d for a, b, c, d in varchi):
            continue
        if all((y - a) ** 2 + (x - b) ** 2 > (distanza_min or passo) ** 2 for a, b, *_ in centri):
            rr_ = r[0] + (r[1] - r[0]) * rng.random()
            # verso fuori: dal centro della radura al punto del bordo
            vy, vx = y - 196, x - 240
            l = max(1.0, (vx * vx + vy * vy) ** 0.5)
            # ognuno un po' diverso: schiacciato o allungato, girato
            centri.append((y + vy / l * rr_ * fuori, x + vx / l * rr_ * fuori, rr_, 0.8 + 0.45 * rng.random(),
                           rng.random() * np.pi))
    return centri


def cornice(img, liscia, rng, profondo=80, sud=True):
    """la cornice del bosco: lobi grandi (cespugli fitti) che sporgono nella radura col loro bordo tondo, dietro una
    seconda fila piu' scura, e oltre il buio del bosco. Ogni lobo e' una cupola (luce in alto a sinistra, ombra in
    basso a destra), fra un lobo e l'altro la fessura scura; tutto scende verso il quasi nero andando fuori"""
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    varchi = [(178, 302, 0, 128)] + ([(170, 310, 268, H)] if sud else [])
    davanti = lobi_lungo(liscia, rng, passo=34, r=(18, 44), fuori=0.35, varchi=varchi)
    dietro = lobi_lungo(liscia, rng, passo=46, r=(30, 46), fuori=1.6,
                        varchi=[(200, 280, 0, 110)] + ([(190, 290, 280, H)] if sud else []))
    lobo = np.full((H, W), -1)
    tono = np.full((H, W), -9.0)
    gobbe = _prato.liscio(H, W, 5, 5, 41) - 0.5
    for k, (cy, cx, r, asp, ang) in enumerate(dietro + davanti):
        ux, uy = xx - cx, (yy - cy) * 1.18
        ca, sa = np.cos(ang), np.sin(ang)
        a1, a2 = ux * ca + uy * sa, (-ux * sa + uy * ca) * asp
        dd = np.hypot(a1, a2) / r + gobbe * 0.22
        dentro = dd <= 1.0
        lx, ly = (xx - cx) / r, (yy - cy) / r
        t = 6.0 - 1.1 * lx - 1.5 * ly - 1.3 * dd ** 2
        if k < len(dietro):
            t -= 2.2                                       # la fila di dietro, piu' scura
        sopra = dentro                                    # quelli davanti coprono quelli dietro (vengono dopo)
        lobo[sopra] = k
        tono[sopra] = t[sopra]
    fuori_liscia = ~liscia
    pieno = fuori_liscia | (lobo >= 0)
    aperto = ~pieno
    d_fuori = distanza(aperto, profondo + 2)
    # oltre i lobi: il bosco buio, a ciuffi scuri, che finisce nel quasi nero
    resto = pieno & (lobo < 0)
    tono[resto] = 3.2 - d_fuori[resto] / 16.0
    tono += (_prato.liscio(H, W, 9, 9, 17) - 0.5) * 0.7
    tono -= np.clip(d_fuori - 30, 0, None) / 22.0          # verso fuori, piano piano, tutto scende
    tono = np.clip(tono, 0.6, 8.4)
    img[pieno] = V[0]
    m = pieno & (tono > 0.9)
    liv = pt._fogliame(img, m, tono, rng, rampa=V, minimo=1, passo=(8, 6), lobi=np.where(lobo >= 0, lobo, 999))
    pt._contorno(img, np.where(m, liv, -1), rampa=V)
    return aperto, d_fuori


def ombra_cornice(img, aperto, d_fuori):
    """l'ombra della cornice sul prato: la fascia che la segue, piu' larga in basso a destra (la luce viene da in alto
    a sinistra), col bordo a gobbe; e il contatto, piu' scuro"""
    fuori = ~aperto
    proiettata = np.zeros((H, W), bool)
    for k in range(1, 15):
        dx, dy = int(round(k * 0.45)), k
        s = np.zeros((H, W), bool)
        s[dy:, dx:] = fuori[:H - dy, :W - dx]
        proiettata |= s
    vicino = distanza(fuori, 12)
    gobbe = _prato.liscio(H, W, 6, 6, 23)
    om = aperto & (proiettata | (vicino <= 5 + gobbe * 6))
    contatto = aperto & (vicino <= 2)
    q = np.zeros((H, W), int)
    q[om] = 1
    q[contatto] = 2
    scendi(img, q)
    return om


def scena_radura(nome='radura'):
    rng = np.random.default_rng(3)
    img = np.zeros((H, W, 3), np.uint8)
    img[:] = V[PAV]
    liscia = radura(rng)
    aperto, d_fuori = cornice(img, liscia, rng)
    coperto = np.zeros((H, W), bool)
    # gli alberi a serpente nostri, coi verdi nuovi: i tronchi sul bordo, le chiome sopra la cornice
    alberi = [('albero_alto_dritto_1', 92, 62), ('albero_alto_dritto_2', 392, 58),
              ('albero_alto_2', 22, 252), ('albero_alto_3', 470, 238)]
    for n, x, y in sorted(alberi, key=lambda t: t[2]):
        a, piede = pezzo(n)
        incolla(img, a, x, y, piede, coperto)
    # il buio che sale verso fuori: i gradini scendono con la distanza dalla radura (anche sugli alberi)
    q = np.clip((d_fuori - 26 + (_prato.liscio(H, W, 7, 7, 29) - 0.5) * 16) // 18, 0, 3).astype(int)
    q[aperto] = 0
    scendi(img, q * coperto)                               # gli alberi scendono nel buio come il fogliame
    om = ombra_cornice(img, aperto, d_fuori)
    segni(img, aperto & ~coperto, rng, dove_no=distanza(~aperto, 6) <= 5)
    lei(img, 240, 236)
    Image.fromarray(img).save(os.path.join(OUT, nome + '.png'))
    return img


# ---------------------------------------------------------------- il prato dell'arrivo, col warp
import arrivo as _ar         # noqa: E402  la torsione dello spazio (la stessa della mappa)


def avanti(sx, sy, c):
    """dove finisce (sullo schermo) il punto sx, sy del prato com'era: l'inverso di arrivo.disfa, a tentativi"""
    dx, dy = sx - c[0], (sy - c[1]) / _ar.SQ
    rho, phi = np.hypot(dx, dy), np.arctan2(dy, dx)
    r, th = rho, phi
    for _ in range(40):
        th = phi + _ar.TORSIONE * np.exp(-(r / _ar.L_TORSIONE) ** 2)
        w = np.exp(-(r / _ar.L_ONDE) ** 2)
        eps = w * sum(a * np.sin(k * th + f) for a, k, f in _ar.ONDE)
        r = rho / ((1 + eps) * (1 + _ar.RISUCCHIO * np.exp(-(r / _ar.L_RISUCCHIO) ** 2)))
    return c[0] + r * np.cos(th), c[1] + _ar.SQ * r * np.sin(th)


def scena_arrivo(nome='arrivo'):
    rng = np.random.default_rng(8)
    c = (240, 200)
    img = np.zeros((H, W, 3), np.uint8)
    img[:] = V[PAV]
    # le macchie grandi del prato (poche, lisce), prese da dove stavano prima che lo spazio si torcesse: diventano
    # bracci a spirale attorno al punto dove appare Lei
    P = 3
    F = _prato.liscio(H * P, W * P, 70, 26, 61) * 0.7 + _prato.liscio(H * P, W * P, 30, 12, 62) * 0.3
    r, th = _ar.polari(H, W, c)
    rho, phi = _ar.disfa(r, th)
    G = _ar._bilineare(F, W * (P // 2) + c[0] + rho * np.cos(phi), H * (P // 2) + c[1] + _ar.SQ * rho * np.sin(phi))
    t1, t2 = np.quantile(F, [0.70, 0.90])
    q = (G >= t1).astype(int) + (G >= t2).astype(int)
    scendi(img, q)
    liscia = radura(rng, centro=(240, 200), seme=7, raggi=(186, 112), sud=False)
    aperto, d_fuori = cornice(img, liscia, rng, sud=False)
    coperto = np.zeros((H, W), bool)
    alberi = [('albero_alto_dritto_3', 96, 54), ('albero_alto_dritto_1', 396, 50),
              ('albero_alto_4', 16, 300), ('albero_alto_1', 472, 296)]
    for n, x, y in sorted(alberi, key=lambda t: t[2]):
        a, piede = pezzo(n)
        incolla(img, a, x, y, piede, coperto)
    qq = np.clip((d_fuori - 26 + (_prato.liscio(H, W, 7, 7, 29) - 0.5) * 16) // 18, 0, 3).astype(int)
    qq[aperto] = 0
    scendi(img, qq * coperto)
    ombra_cornice(img, aperto, d_fuori)
    # i segni d'erba in file, nel prato com'era: le file girano con lo spazio (piu' fitti vicino al centro, dove la
    # spirale si deve leggere)
    pav = aperto & ~coperto
    vicino_cornice = distanza(~aperto, 6) <= 5
    for j, y in enumerate(range(-300, H + 300, 16)):
        for x in range(-400 + (j % 2) * 9, W + 400, 18):
            sx, sy = x + rng.integers(-4, 5), y + rng.integers(-2, 3)
            dd = np.hypot(sx - c[0], (sy - c[1]) / _ar.SQ)
            if dd > 120 and rng.random() < 0.6:
                continue                                   # lontano dal centro piu' radi, come nella radura
            px, py = avanti(sx, sy, c)
            if np.hypot(px - c[0], (py - c[1]) / _ar.SQ) < 26:
                continue                                   # dove appare Lei: pulito
            f = SEGNI[int(rng.integers(1, len(SEGNI)))]
            hh, ww = len(f), len(f[0])
            y0, x0 = int(round(py)) - hh // 2, int(round(px)) - ww // 2
            if y0 < 0 or x0 < 0 or y0 + hh >= H or x0 + ww >= W:
                continue
            if not pav[y0:y0 + hh, x0:x0 + ww].all() or vicino_cornice[y0:y0 + hh, x0:x0 + ww].any():
                continue
            for jj, rr_ in enumerate(f):
                for ii, ch in enumerate(rr_):
                    if ch == 'X':
                        img[y0 + jj, x0 + ii] = scuro_di(img[y0 + jj, x0 + ii])
    lei(img, c[0], c[1])
    Image.fromarray(img).save(os.path.join(OUT, nome + '.png'))
    return img


# ---------------------------------------------------------------- il pasto del goblin
def scena_pasto(nome='pasto', x0=400, y0=220):
    """la strada di mattoni e le lastre della piazza antica prese dalla mappa del pasto (solo i sassi: l'erba sopra
    diventa il prato calmo), il goblin che divora il cinghiale al centro, Lei che arriva da sud"""
    import json
    rng = np.random.default_rng(12)
    img = np.zeros((H, W, 3), np.uint8)
    img[:] = V[PAV]
    liscia = radura(rng, centro=(240, 196), seme=9, raggi=(182, 104), sud=True)
    aperto, d_fuori = cornice(img, liscia, rng, sud=True)
    L = os.path.join(REPO, 'art/livelli')
    mappa = np.asarray(Image.open(os.path.join(L, 'pasto.png')).convert('RGB'))[y0:y0 + H, x0:x0 + W]
    erba = np.asarray(Image.open(os.path.join(L, 'pasto_prato.png')).convert('RGBA'))[y0:y0 + H, x0:x0 + W, 3] > 0
    sassi = ~erba & aperto
    pietra = mappa.copy()
    for y, x in zip(*np.nonzero(sassi)):
        c = tuple(int(v) for v in pietra[y, x])
        if c in RICOLORA:
            pietra[y, x] = V[RICOLORA[c]]
    img[sassi] = pietra[sassi]
    coperto = np.zeros((H, W), bool)
    alberi = [('albero_alto_dritto_2', 70, 60), ('albero_alto_dritto_3', 410, 54),
              ('albero_alto_1', 10, 296), ('albero_alto_2', 474, 300)]
    for n, x, y in sorted(alberi, key=lambda t: t[2]):
        a, piede = pezzo(n)
        incolla(img, a, x, y, piede, coperto)
    qq = np.clip((d_fuori - 26 + (_prato.liscio(H, W, 7, 7, 29) - 0.5) * 16) // 18, 0, 3).astype(int)
    qq[aperto] = 0
    scendi(img, qq * coperto)
    ombra_cornice(img, aperto, d_fuori)
    segni(img, aperto & ~coperto & ~sassi, rng,
          dove_no=(distanza(~aperto, 6) <= 5) | (distanza(sassi, 4) <= 3))
    # il cinghiale e il goblin (il primo fotogramma), con l'ombra per terra
    yy, xx = np.mgrid[0:H, 0:W]
    for n, (px, py), (rx, ry, ox, oy) in (('preda', (635, 427), (30, 6, 2, -6)), ('goblin', (640, 430), (13, 4, 3, -1))):
        a = np.asarray(Image.open(os.path.join(L, 'pezzi/pasto', n + '.png')).convert('RGBA')).copy()
        piede = tuple(json.load(open(os.path.join(L, 'pezzi/pasto', n + '.json')))['piede'])
        x, y = px - x0, py - y0
        om = ((xx - x - ox) / rx) ** 2 + ((yy - y - oy) / ry) ** 2 <= 1
        scendi(img, om.astype(int))
        incolla(img, a, x, y, piede)
    lei(img, 236, 292, 'dietro_attesa')
    Image.fromarray(img).save(os.path.join(OUT, nome + '.png'))
    return img


if __name__ == '__main__':
    scena_radura()
    scena_arrivo()
    scena_pasto()
    print('fatto')
