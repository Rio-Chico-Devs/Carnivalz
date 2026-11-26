"""Alberi, pini e cespugli con la tecnica degli esempi di Bru (109 il cespuglio, 110 l'albero), alla misura giusta
rispetto a lei (Bru: "gli alberi sono troppo piccoli in confronto a lei, ridimensionare in modo realistico"): lei e'
alta 73 pixel; un albero ~3 volte lei, un pino ~3,5, un cespuglio poco piu' di lei o a meta'.
Come negli esempi: la sagoma (lobi tondi), il bordo a punte di foglia, ogni lobo con la sua luce (in alto a sinistra,
come la luce della mappa) e la sua ombra, i lobi davanti sopra quelli dietro; dentro, ciuffi di foglie che spezzano i
passaggi di tono; le luci giallo-verdi a ventaglio sui lati in luce; l'indaco sotto la chioma e nelle fessure; i rami
che si vedono nei buchi; il tronco con le venature chiare dal lato della luce. I pixel sono della stessa misura di
quelli di lei (niente ingrandimenti a blocchi): una pianta grande ha piu' lobi e piu' ciuffi, non foglie piu' grosse.
Colori: quelli degli esempi di Bru (la stessa famiglia del prato).

modulo: albero(alto, seme), pino(alto, seme), cespuglio(alto, seme) -> RGBA uint8
uso: piante.py cartella_lei_chibi cartella_pezzi uscita.png   (la fila: lei, le piante nuove, le vecchie)"""
import numpy as np

# i colori degli esempi di Bru (110): chioma dallo scuro al chiaro, tronco
CHIOMA = [(47, 41, 67), (69, 62, 116), (74, 109, 111), (89, 160, 116), (101, 189, 105), (151, 208, 95)]
TRONCO = [(69, 62, 116), (110, 64, 100), (130, 66, 93), (172, 105, 88)]
# i pini: la rampa degli aghi (strumenti/tavolozza.py, 'pino'), piu' fredda, con gli stessi scuri
PINO = [(47, 41, 67), (50, 54, 77), (45, 98, 104), (62, 132, 112), (112, 157, 118), (150, 182, 135)]
LUCE = np.array([-0.62, -0.78])          # la luce viene da in alto a sinistra, come nella mappa

# i ciuffi di foglie: ventagli a punta (una tinta), dal piu' piccolo
VENTAGLI = [['X.X', '.X.'],
            ['X...X', 'XX.XX', '.XXX.', '..X..'],
            ['X.....X', 'XX.X.XX', '.XXXXX.', '..XXX..', '...X...'],
            ['.X...X.', 'XX.X.XX', 'XXXXXXX', '.XXXXX.', '..XXX..', '...X...']]


def _timbra(img, forma, x0, y0, col, dove=None):
    h, w = img.shape[:2]
    for j, r in enumerate(forma):
        for i, ch in enumerate(r):
            if ch == 'X':
                y, x = y0 + j, x0 + i
                if 0 <= y < h and 0 <= x < w and (dove is None or dove[y, x]):
                    img[y, x] = col


def _dentro_cerchi(h, w, cerchi):
    yy, xx = np.mgrid[0:h, 0:w]
    m = np.zeros((h, w), bool)
    for (cx, cy, r) in cerchi:
        m |= (xx + 0.5 - cx) ** 2 + ((yy + 0.5 - cy) / 0.92) ** 2 <= r * r
    return m


def _bordo_a_punte(m, rng, quante=0.16, lungo=(2, 4)):
    # il bordo a punte di foglia: dai pixel del bordo partono punte verso fuori (dal centro in fuori), larghe due o tre
    # pixel alla base e a punta in cima; qualche tacca verso dentro
    h, w = m.shape
    ys, xs = np.nonzero(m)
    cy, cx = ys.mean(), xs.mean()
    pad = np.pad(m, 1)
    bordo = m & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    out = m.copy()
    for y, x in zip(*np.nonzero(bordo)):
        r = rng.random()
        if r < quante:
            d = np.array([x - cx, (y - cy) * 1.3], float)
            d /= np.linalg.norm(d) + 1e-9
            q = np.array([-d[1], d[0]])                       # di traverso
            n = int(rng.integers(lungo[0], lungo[1] + 1))
            for k in range(0, n + 1):
                mezza = (n - k) / n * 1.2                        # da 1.2 a 0: la foglia si stringe
                for t in np.arange(-mezza, mezza + 0.01, 0.5):
                    xx = int(round(x + d[0] * k + q[0] * t)); yy = int(round(y + d[1] * k + q[1] * t))
                    if 0 <= yy < h and 0 <= xx < w:
                        out[yy, xx] = True
        elif r < quante + 0.06:
            out[y, x] = False
    return out


def _chioma(img, cerchi, rampa, rng, tono_base, sfondo_scuro=True):
    """i lobi della chioma, dal fondo al davanti: ognuno e' una palla con la luce in alto a sinistra; il tono del
    lobo si sposta di uno in su o in giu' secondo quanto sta in alto (i lobi alti piu' chiari). Ritorna la sagoma."""
    h, w = img.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    cy_tot = np.mean([c[1] for c in cerchi])
    r_tot = max(c[1] + c[2] for c in cerchi) - min(c[1] - c[2] for c in cerchi)
    sagoma = np.zeros((h, w), bool)
    tono = np.full((h, w), -1.0)
    # dal fondo (dietro, in alto) al davanti (in basso): i lobi davanti coprono quelli dietro
    for (cx, cy, r) in sorted(cerchi, key=lambda c: c[1]):
        dx, dy = (xx + 0.5 - cx) / r, (yy + 0.5 - cy) / (r * 0.92)
        d2 = dx * dx + dy * dy
        m = d2 <= 1.0
        nz = np.sqrt(np.clip(1 - d2, 0, 1))
        luce = (-dx * LUCE[0] * -1 * -1 + 0) if False else (dx * LUCE[0] + dy * LUCE[1]) * 0.75 + nz * 0.45
        alto = (cy_tot - cy) / max(r_tot, 1) * 1.2              # i lobi in alto prendono piu' luce
        t = tono_base + luce * 1.6 + alto - 0.35
        tono[m] = t[m]
        sagoma |= m
    return sagoma, tono


FOGLIOLINE = [['XX.', '.XX'], ['XXX', '.XX'], ['XX', 'XX', '.X'], ['XXX.', '.XXX'], ['.X.', 'XXX', '.X.']]
STELLE = [['..X..', '.XXX.', 'XXXXX', '.XXX.', '..X..'],
          ['X...X', '.XXX.', '.XXX.', 'X.X.X'],
          ['...X...', '.X.X.X.', '..XXX..', 'XXXXXXX', '..XXX..', '.X.X.X.', '...X...']]


def _specchia(forma, rng):
    return [r[::-1] for r in forma] if rng.random() < 0.5 else forma


def _colora(img, sagoma, tono, rampa, rng, minimo=1):
    # il tono continuo diventa a gradini; foglioline del gradino accanto spezzano i confini (come nel prato);
    # poche stelle di luce dove la chioma e' piu' chiara
    n = len(rampa)
    liv = np.clip(np.floor(tono + 0.5), minimo, n - 1).astype(int)
    liv[~sagoma] = -1
    h, w = sagoma.shape
    for k in range(minimo, n):
        img[liv == k] = rampa[k]
    frazione = tono + 0.5 - np.floor(tono + 0.5)
    for _ in range(int(sagoma.sum() / 18)):
        y, x = rng.integers(0, h), rng.integers(0, w)
        if not sagoma[y, x]:
            continue
        k, f = liv[y, x], frazione[y, x]
        forma = _specchia(FOGLIOLINE[rng.integers(len(FOGLIOLINE))], rng)
        if f > 0.7 and k + 1 < n:
            _timbra(img, forma, x - 1, y - 1, rampa[k + 1], sagoma)
        elif f < 0.3 and k - 1 >= minimo:
            _timbra(img, forma, x - 1, y - 1, rampa[k - 1], sagoma)
    chiari = sagoma & (tono >= n - 1.6)
    for _ in range(int(sagoma.sum() / 45)):
        y, x = rng.integers(0, h), rng.integers(0, w)
        if chiari[y, x]:
            forma = STELLE[rng.integers(len(STELLE))]
            _timbra(img, forma, x - len(forma[0]) // 2, y - len(forma) // 2, rampa[n - 1], sagoma)
    return liv


def _ripulisci(img, dove):
    # i pixel soli dentro la pianta: prendono il colore dei quattro vicini se sono tutti uguali
    a = img.astype(int)
    su, giu = np.roll(a, 1, 0), np.roll(a, -1, 0)
    sx, dx = np.roll(a, 1, 1), np.roll(a, -1, 1)
    ug = np.all(su == giu, -1) & np.all(su == sx, -1) & np.all(su == dx, -1) & ~np.all(su == a, -1) & dove
    img[ug] = su[ug].astype(np.uint8)


def _tronco(img, x0, y0, y1, largo, rng, rampa=TRONCO, ombra_su=0.3):
    # il tronco: venature verticali (luce a sinistra, ombra a destra), piu' largo alle radici, e in alto l'ombra
    # della chioma
    alto = y1 - y0 + 1
    righe = {}
    for y in range(y0, y1 + 1):
        dal_fondo = y1 - y
        lw = largo + (4 if dal_fondo < 2 else (2 if dal_fondo < 5 else 0))
        righe[y] = (int(round(x0 - lw / 2)), lw)
    # una tinta per colonna (dalla luce all'ombra), poi venature: tratti verticali della tinta accanto
    xa_min = min(xa for xa, lw in righe.values()); xb_max = max(xa + lw for xa, lw in righe.values())
    vena = {}
    for x in range(xa_min, xb_max):
        for _ in range(max(1, alto // 7)):
            ya = int(rng.integers(y0, y1 + 1)); lung = int(rng.integers(3, 9))
            for y in range(ya, min(y1 + 1, ya + lung)):
                vena[(x, y)] = True
    for y in range(y0, y1 + 1):
        xa, lw = righe[y]
        for x in range(xa, xa + lw):
            u = (x - xa) / max(1, lw - 1)
            k = 3 if u < 0.3 else (2 if u < 0.7 else (1 if u < 0.9 else 0))
            if vena.get((x, y)) and 0 < k < 3:
                k += 1 if u < 0.5 else -1
            if (y - y0) < alto * ombra_su:
                k = max(0, k - 2)                       # l'ombra della chioma
            if 0 <= y < img.shape[0] and 0 <= x < img.shape[1]:
                img[y, x] = rampa[k]


def albero(alto=220, seme=1):
    rng = np.random.default_rng(seme)
    largo = int(alto * 0.78)
    w, h = largo + 16, alto + 4
    img = np.zeros((h, w, 3), np.uint8)
    op = np.zeros((h, w), bool)
    cx = w / 2
    base = h - 2
    ch = alto * 0.8                                     # quanto e' alta la chioma
    cima = base - alto + 2
    giu_chioma = cima + ch
    # il tronco (dietro la chioma, si vede sotto) e due o tre rami che spuntano
    lt = max(7, int(alto * 0.1))
    _tronco(img, int(cx), int(giu_chioma - ch * 0.3), base, lt, rng)
    op[int(giu_chioma - ch * 0.3):base + 1, int(cx - lt):int(cx + lt + 1)] = np.any(
        img[int(giu_chioma - ch * 0.3):base + 1, int(cx - lt):int(cx + lt + 1)] > 0, -1)
    # i lobi: uno grande al centro, una corona intorno, lobi piu' piccoli sul bordo
    R = largo * 0.5
    cerchi = [(cx, cima + ch * 0.5, R * 0.62)]
    for k in range(7):
        a = np.pi * (0.95 + k / 6.0 * 1.1) + rng.uniform(-0.12, 0.12)
        rr = R * rng.uniform(0.36, 0.46)
        cerchi.append((cx + np.cos(a) * R * 0.52, cima + ch * 0.5 + np.sin(a) * ch * 0.36, rr))
    for k in range(5):
        a = rng.uniform(0, 2 * np.pi)
        cerchi.append((cx + np.cos(a) * R * 0.3, cima + ch * 0.55 + np.sin(a) * ch * 0.22, R * rng.uniform(0.3, 0.38)))
    # la base della chioma un po' piatta, larga
    for s in (-1, 1):
        cerchi.append((cx + s * R * 0.62, cima + ch * 0.72, R * 0.34))
    sagoma, tono = _chioma(img, cerchi, CHIOMA, rng, tono_base=3.0)
    sagoma = _bordo_a_punte(sagoma, rng)
    tono_p = tono.copy()
    tono_p[sagoma & (tono < 0)] = 2.6                 # le punte nuove: il tono medio-scuro del bordo
    chioma = np.zeros_like(img)
    liv = _colora(chioma, sagoma, tono_p, CHIOMA, rng, minimo=1)
    # sotto la chioma l'indaco: le ultime righe di ogni colonna della chioma
    for x in range(w):
        ys = np.nonzero(sagoma[:, x])[0]
        if len(ys):
            yb = ys.max()
            k = rng.integers(2, 5)
            chioma[max(ys.min(), yb - k):yb + 1, x] = CHIOMA[1]
    # i rami nei buchi: qualche fessura scura con un pezzetto di ramo
    for _ in range(int(alto / 40) + 2):
        y = int(rng.uniform(cima + ch * 0.35, cima + ch * 0.8)); x = int(cx + rng.uniform(-R * 0.45, R * 0.45))
        if 0 <= y < h - 4 and sagoma[y, x]:
            lung = rng.integers(3, 7)
            for k in range(lung):
                yy, xx = y + k, x + (k // 2) * (1 if x < cx else -1)
                if sagoma[yy, xx]:
                    chioma[yy, xx] = TRONCO[2] if k % 3 else TRONCO[1]
                    if xx + 1 < w and sagoma[yy, xx + 1]:
                        chioma[yy, xx + 1] = CHIOMA[1]
    _ripulisci(chioma, sagoma)
    img[sagoma] = chioma[sagoma]
    op |= sagoma
    out = np.zeros((h, w, 4), np.uint8)
    out[..., :3] = img; out[..., 3] = op * 255
    return _taglia(out)


def pino(alto=255, seme=1):
    rng = np.random.default_rng(seme)
    w, h = int(alto * 0.5) + 12, alto + 4
    img = np.zeros((h, w, 3), np.uint8)
    op = np.zeros((h, w), bool)
    cx = w / 2
    base = h - 2
    lt = max(5, int(alto * 0.045))
    tronco_alto = int(alto * 0.12)
    _tronco(img, int(cx), base - tronco_alto - 6, base, lt, rng)
    op[base - tronco_alto - 6:base + 1] |= np.any(img[base - tronco_alto - 6:base + 1] > 0, -1)
    # i palchi, dall'alto: triangoli che si allargano, ognuno coi bordi in giu' a punte, la luce a sinistra
    n = 6 if alto > 180 else 5
    cima = base - alto + 2
    giu = base - tronco_alto
    palchi = []
    for k in range(n):
        t0 = k / n
        y_top = cima + (giu - cima) * (t0 * 0.92) - (4 if k else 0)
        y_bot = cima + (giu - cima) * ((k + 1) / n)
        mezzo = (w / 2 - 4) * (0.22 + 0.78 * (k + 1) / n)
        palchi.append((y_top, y_bot, mezzo))
    sagoma = np.zeros((h, w), bool)
    tono = np.full((h, w), -1.0)
    yy, xx = np.mgrid[0:h, 0:w]
    fondi = []
    for k, (y_top, y_bot, mezzo) in enumerate(palchi):
        t = np.clip((yy - y_top) / max(1, y_bot - y_top), 0, 1)
        larg = mezzo * (0.15 + 0.85 * t)
        # il fondo del palco a punte che pendono: un dente ogni 5-7 pixel, lungo 2-5
        passo = int(rng.integers(5, 8))
        fase = int(rng.integers(0, passo))
        dente = np.array([(passo / 2 - abs(((x + fase) % passo) - passo / 2)) for x in range(w)])
        punta = dente / (passo / 2) * rng.uniform(3, 5.5) + rng.uniform(0, 1, w)
        fondo = y_bot + punta - 1
        fondi.append(fondo)
        m = (yy >= y_top) & (yy <= fondo[None, :]) & (np.abs(xx + 0.5 - cx) <= larg + 0.5)
        u = (xx + 0.5 - cx) / np.maximum(larg, 1)
        v = (yy - y_top) / max(1, y_bot - y_top)
        t_ = 3.35 - u * 1.35 - v * 0.9 + (1 - (y_bot - cima) / (giu - cima)) * 0.4
        tono[m] = t_[m]
        sagoma |= m
    sagoma = _bordo_a_punte(sagoma, rng, quante=0.12, lungo=(1, 3))
    tono[sagoma & (tono < 0)] = 2.4
    chioma = np.zeros_like(img)
    _colora(chioma, sagoma, tono, PINO, rng, minimo=1)
    # l'ombra che ogni palco getta su quello sotto: sotto le sue punte, due pixel piu' scuri che seguono i denti
    for k, (y_top, y_bot, mezzo) in enumerate(palchi[:-1]):
        f = fondi[k]
        for x in range(w):
            y = int(f[x]) + 1
            for j in range(2):
                if 0 <= y + j < h and sagoma[y + j, x] and abs(x - cx) < mezzo + 2:
                    chioma[y + j, x] = PINO[1] if j == 0 else PINO[2]
    _ripulisci(chioma, sagoma)
    img[sagoma] = chioma[sagoma]
    op |= sagoma
    out = np.zeros((h, w, 4), np.uint8)
    out[..., :3] = img; out[..., 3] = op * 255
    return _taglia(out)


def cespuglio(alto=80, seme=1):
    rng = np.random.default_rng(seme)
    largo = int(alto * 1.45)
    w, h = largo + 12, alto + 4
    img = np.zeros((h, w, 3), np.uint8)
    cx, base = w / 2, h - 2
    R = largo / 2
    cerchi = [(cx, base - alto * 0.48, alto * 0.5)]
    for k in range(5):
        a = np.pi * (1.0 + k / 4.0)
        cerchi.append((cx + np.cos(a) * R * 0.55, base - alto * 0.42 + np.sin(a) * alto * 0.3,
                       alto * rng.uniform(0.32, 0.4)))
    for s in (-1, 1):
        cerchi.append((cx + s * R * 0.62, base - alto * 0.28, alto * 0.3))
    sagoma, tono = _chioma(img, cerchi, CHIOMA, rng, tono_base=3.0)
    sagoma &= np.mgrid[0:h, 0:w][0] <= base                 # piatto in fondo, sul prato
    sagoma = _bordo_a_punte(sagoma, rng)
    sagoma &= np.mgrid[0:h, 0:w][0] <= base
    tono[sagoma & (tono < 0)] = 2.6
    chioma = np.zeros_like(img)
    _colora(chioma, sagoma, tono, CHIOMA, rng, minimo=1)
    for x in range(w):
        ys = np.nonzero(sagoma[:, x])[0]
        if len(ys):
            chioma[max(ys.min(), ys.max() - rng.integers(1, 3)):ys.max() + 1, x] = CHIOMA[1]
    _ripulisci(chioma, sagoma)
    out = np.zeros((h, w, 4), np.uint8)
    out[..., :3] = chioma; out[..., 3] = sagoma * 255
    return _taglia(out)


def _taglia(a):
    ys, xs = np.nonzero(a[..., 3])
    return a[ys.min():ys.max() + 1, max(0, xs.min() - 1):xs.max() + 2]


if __name__ == '__main__':
    import os
    import sys

    from PIL import Image
    LEI, PEZ, OUT = sys.argv[1:4]
    lei = np.asarray(Image.open(os.path.join(LEI, 'davanti_ferma.png')).convert('RGBA'))
    vecchie = [np.asarray(Image.open(os.path.join(PEZ, f)).convert('RGBA'))
               for f in ('albero_2.png', 'pino_1.png', 'cespuglione_verde.png')]
    nuove = [albero(220, 3), pino(255, 2), cespuglio(80, 5), cespuglio(50, 8)]
    fila = [lei] + nuove + [lei] + vecchie
    gap = 12
    W = sum(a.shape[1] for a in fila) + gap * (len(fila) + 1)
    H = max(a.shape[0] for a in fila) + 20
    tela = Image.new('RGBA', (W, H), (161, 220, 110, 255))
    x = gap
    for a in fila:
        im = Image.fromarray(a, 'RGBA')
        tela.alpha_composite(im, (x, H - 10 - a.shape[0]))
        x += a.shape[1] + gap
    tela = tela.convert('RGB').resize((W * 2, H * 2), Image.NEAREST)
    tela.save(OUT)
    print('fila', tela.size)
