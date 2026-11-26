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


# ================================================================ l'albero esotico
# Bru: "la parte superiore sembra un mucchio di palle, non tanto un albero; dagli un aspetto piu' esotico, magari con
# liane o muschi", e soprattutto la parte che poggia sul terreno. Un albero da foresta pluviale (come la ceiba e il
# fico tropicale): le radici a contrafforte, lame che si aprono sul prato, col muschio sul dorso e le felci al piede; il
# tronco grosso e un po' storto, scanalato, col muschio dal lato della luce e una liana che gli gira attorno; i rami
# che si aprono a ombrello e si vedono; la chioma a strati piatti fatti di gruppi di foglie (chiari sopra, indaco
# sotto, la frangia di foglie che pende), coi vuoti fra un gruppo e l'altro; le liane che pendono e quelle ad arco
# fra i rami, qualcuna fiorita. La luce da in alto a sinistra, i colori degli esempi di Bru.
MUSCHIO = [(65, 70, 94), (77, 121, 116), (109, 160, 103), (164, 189, 98), (209, 218, 123)]   # tavolozza 'muschio'
FIORE_LIANA = [(139, 68, 134), (219, 95, 161), (254, 147, 164)]      # magenta: ombra, pieno, luce
# la frangia: foglie che pendono dal gruppo di sopra in quello di sotto (una tinta)
FRANGE = [['XXX', 'X.X'], ['XXXX', 'X.X.', 'X...'], ['.XX.', 'X..X'], ['XXXXX', '.X.X.', '.X...'], ['XX', '.X'],
          ['XXX', '.X.', '.X.']]
LUCCICHII = [['.X.', 'X.X'], ['X.X', '.X.'], ['XX'], ['X..', '.XX']]
# la bromelia (una pianta che vive sui rami): la spiga magenta (m luce, M pieno, o ombra), le foglie verdi a rosetta
BROMELIA = ['...m...', '..mM...', '..MMo..', 'g.Mo.G.', 'gg.o.GG', '.ggGGG.']
# le foglie larghe della chioma: che pendono (a goccia, a ventaglio aperto in giu') e che salgono (ciuffi a punta)
FOGLIE_GIU = [['XXX', 'XXX', '.X.'], ['XX.', 'XXX', '.XX', '..X'], ['X.X.X', 'XXXXX', '.X.X.'], ['XXXX', '.XX.', '.X..'],
              ['XX', 'XX', 'X.']]
FOGLIE_SU = [['.X.', 'XXX'], ['X.X', 'XXX'], ['X...X', '.X.X.', '.XXX.'], ['..X', '.XX', 'XX.'], ['X.', 'XX', '.X']]


class _Tela:
    def __init__(self, h, w):
        self.h, self.w = h, w
        self.img = np.zeros((h, w, 3), np.uint8)
        self.op = np.zeros((h, w), bool)

    def metti(self, x, y, c):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            self.img[y, x] = c
            self.op[y, x] = True

    def timbra(self, forma, x0, y0, c, dove=None):
        for j, r in enumerate(forma):
            for i, ch in enumerate(r):
                if ch == 'X':
                    y, x = y0 + j, x0 + i
                    if 0 <= y < self.h and 0 <= x < self.w and (dove is None or dove[y, x]):
                        self.img[y, x] = c
                        self.op[y, x] = True


def _bezier(p0, p1, p2, n):
    t = np.linspace(0, 1, max(2, n))[:, None]
    return (1 - t) ** 2 * np.array(p0, float) + 2 * (1 - t) * t * np.array(p1, float) + t ** 2 * np.array(p2, float)


def _legno(T, punti, larghi, rampa=TRONCO, scuro_sotto=True):
    # un ramo (o il tronco): dischi lungo la curva; il lato verso la luce chiaro, quello opposto scuro
    for (x, y), lw in zip(punti, larghi):
        r = max(0.6, lw / 2)
        for yy in range(int(y - r - 1), int(y + r + 2)):
            for xx in range(int(x - r - 1), int(x + r + 2)):
                dx, dy = xx + 0.5 - x, yy + 0.5 - y
                if dx * dx + dy * dy <= r * r:
                    s = (dx * LUCE[0] + dy * LUCE[1]) / r
                    k = 3 if s > 0.42 else (2 if s > -0.2 else (1 if s > -0.7 or not scuro_sotto else 0))
                    T.metti(xx, yy, rampa[k])


def _tronco_grosso(T, pts, larghi, rng, rampa=TRONCO):
    # il tronco riga per riga: il tono da sinistra (luce) a destra (ombra), col bordo in ombra un filo piu' chiaro (la
    # luce riflessa del prato); le scanalature continue che ondeggiano piano, ognuna un gradino piu' scura, con la luce
    # sul labbro dal lato chiaro
    righe = {}
    for (x, y), lw in zip(pts, larghi):
        righe.setdefault(int(round(y)), (x, lw / 2))
    fasi = rng.uniform(0, 2 * np.pi, 6)
    solchi = (-0.7, -0.38, -0.06, 0.28, 0.6)
    rotti = {j: 0 for j in range(len(solchi))}
    for y in sorted(righe, reverse=True):
        xc, hw = righe[y]
        tono = {}
        for x in range(int(np.floor(xc - hw)), int(np.ceil(xc + hw)) + 1):
            u = (x + 0.5 - xc) / max(hw, 1)
            if abs(u) <= 1.0:
                tono[x] = 3 if u < -0.4 else (2 if u < 0.15 else (1 if u < 0.84 else 0))
        if not tono:
            continue
        xr = max(tono)
        if tono[xr] == 0 and rng.random() < 0.5:
            tono[xr] = 1                                   # il riflesso sul bordo in ombra
        for j, u0 in enumerate(solchi):
            if rotti[j] > 0:
                rotti[j] -= 1
                continue
            if rng.random() < 0.025:
                rotti[j] = int(rng.integers(1, 4))
            xg = int(round(xc + (u0 + 0.06 * np.sin(y / 6.0 + fasi[j])) * hw))
            if xg in tono:
                tono[xg] = max(0, tono[xg] - 1)
                if u0 < 0.1 and xg - 1 in tono and rng.random() < 0.55:
                    tono[xg - 1] = min(3, tono[xg - 1] + 1)
        for x, k in tono.items():
            T.metti(x, y, rampa[k])


def _radice(T, x0, y0, ang, L, F0, rng, rampa=TRONCO):
    # una radice a contrafforte: una lama che esce dal piede del tronco, serpeggia, si abbassa e affonda nel prato.
    # ang: la direzione sul terreno (0 a destra, 90 verso di noi, 180 a sinistra, 270 lontano); sullo schermo la
    # profondita' e' schiacciata a meta'. Il dorso prende la luce se la radice va a sinistra o verso di noi; la faccia
    # e' in ombra se va a destra; la piega dove tocca terra e' scura. Quella che viene verso di noi si vede dall'alto:
    # una cresta che si stringe, il fianco sinistro in luce e il destro in ombra. In punta qualche radichetta
    a = np.radians(ang)
    ux, uy = np.cos(a), np.sin(a) * 0.5
    curva = rng.uniform(-0.45, 0.45)
    onda, fase = rng.uniform(0.08, 0.18), rng.uniform(0, 2 * np.pi)
    n = int(L * 1.8) + 3
    davanti = uy > 0.3
    luce_dorso = rampa[3] if ux < 0.3 else rampa[2]
    faccia = rampa[2] if (ux < -0.2 or (davanti and ux < 0.2)) else rampa[1]
    largo0 = 2.0 + F0 * 0.55
    ultimo = None
    for i in range(n):
        t = i / (n - 1)
        px = x0 + ux * L * t - uy * curva * L * t * t * 1.6 - (curva * L * 0.25 * np.sin(np.pi * t) if davanti else 0)
        py = y0 + uy * L * t + ux * curva * L * t * t * 0.4
        ultimo = (px, py)
        if davanti:
            wt = largo0 * (1 - t) ** 0.9 + 1
            xa, xb = int(round(px - wt / 2)), int(round(px + wt / 2))
            for xx in range(xa, xb + 1):
                u = (xx + 0.5 - px) / max(wt / 2, 0.5)
                T.metti(xx, py, rampa[3] if u < -0.35 else (rampa[2] if u < 0.3 else rampa[1]))
            T.metti(xb, py + 1, rampa[0])
            continue
        h = F0 * (1 - t) ** 1.6 * (1 + onda * np.sin(t * 9 + fase)) + 0.6
        th = 1.0 + 2.6 * (1 - t) ** 0.8
        top = py - h
        # le scanalature sulla faccia (continuano quelle del tronco): uno o due solchi lungo la radice, un gradino piu'
        # scuri, col filo di luce sopra
        solchi = [int(round(top + h * f)) for f in ((0.45,) if h < 9 else (0.33, 0.66))] if h > 4 else []
        k_faccia = rampa.index(faccia)
        xa, xb = int(round(px - th / 2)), int(round(px + th / 2))
        for xx in range(xa, xb + 1):
            for yy in range(int(round(top)), int(round(py)) + 1):
                if yy == int(round(top)):
                    c = luce_dorso
                elif yy >= int(round(py)):
                    c = rampa[0]
                elif yy in solchi:
                    c = rampa[max(0, k_faccia - 1)]
                elif yy + 1 in solchi and k_faccia < 3:
                    c = rampa[k_faccia + 1]
                else:
                    c = faccia
                T.metti(xx, yy, c)
    # le radichette in punta: due fili che si aprono nel prato
    if ultimo is not None:
        px, py = ultimo
        for s in (-1, 1):
            if rng.random() < 0.7:
                for k in range(1, int(rng.integers(2, 5))):
                    T.metti(px + ux * k + s * 0.5 * k * (abs(uy) + 0.3), py + uy * k + s * 0.35 * k * (abs(ux) + 0.2),
                            rampa[1] if k > 1 else rampa[2])


def _muschio(T, x, y, rng, grande=False):
    # un ciuffo di muschio: un mucchietto chiaro in cima, il verde in mezzo, lo scuro sotto
    w = int(rng.integers(2, 5 if grande else 4))
    for i in range(w):
        hh = 1 + (1 if 0 < i < w - 1 and rng.random() < 0.6 else 0)
        for j in range(hh + 1):
            c = MUSCHIO[4] if j == hh else (MUSCHIO[3] if j > 0 else MUSCHIO[2])
            T.metti(x + i, y - j, c)


def _foglia_liana(T, x, y, lato, chiara):
    # una fogliolina a goccia che esce di lato e sale: la punta chiara se e' dal lato della luce
    T.metti(x + lato, y, CHIOMA[3])
    T.metti(x + 2 * lato, y - 1, CHIOMA[4] if chiara else CHIOMA[3])
    T.metti(x + lato, y - 1, CHIOMA[4] if chiara else CHIOMA[2])


def _liana(T, punti, rng, fiori=False, ciuffo=True):
    # una liana: il filo scuro con le foglioline alternate (quelle a sinistra in luce); a volte fiorita; in fondo un
    # ciuffetto di foglie
    lato = 1 if rng.random() < 0.5 else -1
    passo = int(rng.integers(2, 4))
    ultimo = None
    for k, (x, y) in enumerate(punti):
        xi, yi = int(round(x)), int(round(y))
        if (xi, yi) == ultimo:
            continue
        ultimo = (xi, yi)
        T.metti(xi, yi, CHIOMA[3] if k % 5 else CHIOMA[2])
        if k > 2 and k % passo == 0:
            lato = -lato
            _foglia_liana(T, xi, yi, lato, lato < 0)
            if fiori and rng.random() < 0.35:
                T.metti(xi - lato, yi + 1, FIORE_LIANA[1])
                T.metti(xi - lato, yi, FIORE_LIANA[2])
                T.metti(xi - 2 * lato, yi + 1, FIORE_LIANA[0])
    if ciuffo and ultimo:
        xi, yi = ultimo
        for (dx, dy, c) in ((-1, 1, CHIOMA[3]), (1, 1, CHIOMA[2]), (0, 2, CHIOMA[2]), (-2, 2, CHIOMA[4]), (2, 2, CHIOMA[2])):
            T.metti(xi + dx, yi + dy, c)


def _pendente(T, x, y, L, rng, fiori=False):
    fase, amp, per = rng.uniform(0, 6.28), rng.uniform(0.3, 1.3), rng.uniform(14, 28)
    pts = [(x + amp * np.sin(2 * np.pi * k / per + fase) * min(1.0, k / 6), y + k) for k in range(int(L))]
    _liana(T, pts, rng, fiori)


def _arco(T, a, b, cala, rng, fiori=False):
    # una liana appesa fra due punti, che cala nel mezzo
    n = int(abs(b[0] - a[0]) * 1.5 + abs(b[1] - a[1]) + cala * 2) + 4
    pts = []
    for k in range(n):
        t = k / (n - 1)
        pts.append((a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t + cala * 4 * t * (1 - t)))
    _liana(T, pts, rng, fiori, ciuffo=False)


def _gruppo(T, mx, my, rx, ryt, ryb, tono0, rng):
    """Un gruppo di foglie della chioma: un ovale schiacciato (la cupola sopra, il fondo appena mosso), il bordo di
    sopra a ciuffi di foglie; il tono segue la cupola (chiaro in cima, indaco in fondo, non a palla), piu' chiaro a
    sinistra; dentro, foglie larghe del tono accanto che rompono i confini (a ventaglio e a goccia, che pendono); in
    cima qualche luccichio; sotto, le foglie che pendono, lunghe e corte. Ritorna dove ha dipinto."""
    x0, x1 = max(0, int(mx - rx * 1.25) - 2), min(T.w, int(mx + rx * 1.25) + 3)
    y0, y1 = max(0, int(my - ryt * 1.4) - 2), min(T.h, int(my + ryb * 1.4) + 8)
    yy, xx = np.mgrid[y0:y1, x0:x1]
    dx = (xx + 0.5 - mx) / rx
    dy = np.where(yy + 0.5 < my, (yy + 0.5 - my) / ryt, (yy + 0.5 - my) / ryb)
    ang = np.arctan2(dy, dx)
    k1, k2, k3 = int(rng.integers(6, 10)), int(rng.integers(12, 17)), int(rng.integers(20, 27))
    f1, f2, f3 = rng.uniform(0, 2 * np.pi, 3)
    mosso = 0.09 * np.sin(k1 * ang + f1) + 0.06 * np.sin(k2 * ang + f2) + 0.035 * np.sin(k3 * ang + f3)
    mosso = np.where(dy > 0, mosso * 0.45, mosso)
    m = dx * dx + dy * dy <= (1 + mosso) ** 2
    if not m.any():
        return np.zeros((T.h, T.w), bool)
    # il tono lungo la cupola: per ogni colonna dalla cima al fondo del gruppo
    cima = np.where(m.any(0), m.argmax(0), 0)
    fondo = np.where(m.any(0), m.shape[0] - 1 - m[::-1].argmax(0), 0)
    vt = np.clip((yy - y0 - cima[None, :]) / np.maximum(1, fondo - cima)[None, :], 0, 1)
    tono = tono0 - 3.1 * vt ** 0.8 - 0.5 * dx
    n = len(CHIOMA)
    liv = np.clip(np.floor(tono + 0.5), 1, n - 1).astype(int)
    blocco = T.img[y0:y1, x0:x1]
    for k in range(1, n):
        blocco[m & (liv == k)] = CHIOMA[k]
    T.op[y0:y1, x0:x1] |= m
    dove = np.zeros((T.h, T.w), bool)
    dove[y0:y1, x0:x1] = m
    frazione = tono + 0.5 - np.floor(tono + 0.5)
    # le foglie larghe sui confini fra un tono e l'altro: dove sopra e' piu' chiaro pendono foglie chiare, dove sotto
    # e' piu' scuro salgono foglie scure
    for _ in range(int(m.sum() / 9)):
        j, i = int(rng.integers(0, y1 - y0)), int(rng.integers(0, x1 - x0))
        if not m[j, i]:
            continue
        k, f = liv[j, i], frazione[j, i]
        if f > 0.6 and k + 1 < n:
            forma = _specchia(FOGLIE_GIU[rng.integers(len(FOGLIE_GIU))], rng)
            T.timbra(forma, x0 + i - 1, y0 + j - 1, CHIOMA[k + 1], dove)
        elif f < 0.3 and k - 1 >= 1:
            forma = _specchia(FOGLIE_SU[rng.integers(len(FOGLIE_SU))], rng)
            T.timbra(forma, x0 + i - 1, y0 + j - len(forma) + 1, CHIOMA[k - 1], dove)
    # i ciuffi di foglie che spuntano dal bordo di sopra, nel tono della cima
    for i in range(x1 - x0):
        if m[:, i].any() and rng.random() < 0.16:
            j = cima[i]
            forma = FOGLIE_SU[rng.integers(len(FOGLIE_SU))]
            T.timbra(forma, x0 + i - 1, y0 + j - len(forma), CHIOMA[min(n - 1, liv[j, i])])
    # i luccichii in cima, dove e' piu' chiaro
    for _ in range(int(m.sum() / 70)):
        j, i = int(rng.integers(0, y1 - y0)), int(rng.integers(0, x1 - x0))
        if m[j, i] and tono[j, i] > n - 1.3:
            T.timbra(LUCCICHII[rng.integers(len(LUCCICHII))], x0 + i - 1, y0 + j, (213, 252, 135), dove)
    # sotto: l'indaco del fondo e le foglie che pendono, lunghe e corte, con la punta che gira
    for i in range(x1 - x0):
        if not m[:, i].any():
            continue
        jb = fondo[i]
        T.metti(x0 + i, y0 + jb, CHIOMA[1])
        if rng.random() < 0.5:
            lung = int(rng.choice([1, 2, 3, 4, 6], p=[0.3, 0.3, 0.2, 0.12, 0.08]))
            xg = x0 + i
            for k in range(1, lung + 1):
                if k == lung and lung > 2:
                    xg += 1 if rng.random() < 0.5 else -1
                T.metti(xg, y0 + jb + k, CHIOMA[1] if k < lung else CHIOMA[2])
    return dove


def _felce(T, x, y, larga, rng):
    # una felce al piede: fronde che escono dal centro, si alzano e ricadono, con le foglioline a pettine
    nf = int(rng.integers(4, 7))
    for k in range(nf):
        a = np.radians(rng.uniform(-170, -10))
        l = larga * rng.uniform(0.55, 1.0)
        cade = rng.uniform(0.5, 0.9)
        prev = None
        for i in range(int(l * 1.5)):
            t = i / (l * 1.5)
            px = x + np.cos(a) * l * t
            py = y + np.sin(a) * l * t * 0.7 + cade * l * t * t
            xi, yi = int(round(px)), int(round(py))
            if (xi, yi) == prev:
                continue
            prev = (xi, yi)
            if yi > y + 2:
                break                                      # le fronde ricadono sul prato, non sotto
            T.metti(xi, yi, CHIOMA[3])
            if i % 2 == 0 and t > 0.1:
                lato = 1 if np.cos(a) >= 0 else -1
                T.metti(xi, yi - 1, CHIOMA[4] if lato < 0 else CHIOMA[3])
                T.metti(xi + lato, yi + 1, CHIOMA[2])


def albero_esotico(alto=230, seme=1, con_piede=False):
    # con_piede: ritorna anche il piede (il mezzo del tronco dove tocca terra) nel disegno ritagliato
    rng = np.random.default_rng(seme)
    Wc = alto * rng.uniform(0.95, 1.06)                      # quanto e' larga la chioma
    w, h = int(Wc) + 30, alto + 14
    T = _Tela(h, w)
    base = h - 8                                             # dove il tronco tocca terra
    cx = w / 2 + rng.uniform(-3, 3)
    cima = base - alto + 4
    yf = base - alto * rng.uniform(0.43, 0.48)               # dove il tronco si apre nei rami
    fx = cx + rng.uniform(-0.05, 0.05) * alto
    hw_f, hw_b = alto * 0.045, alto * 0.064                  # mezza larghezza del tronco in cima e al piede
    # i gruppi della chioma: un ombrello largo, a strati (quelli in alto sono dietro)
    gruppi = []
    def g(px, py, rr, schiaccia=0.42, tono=5.0):
        rx = Wc * rr * rng.uniform(0.9, 1.1)
        gruppi.append((cx + Wc * px + rng.uniform(-4, 4), cima + alto * py + rng.uniform(-3, 3), rx,
                       rx * schiaccia, rx * schiaccia * 0.55, tono))
    # tre file: dietro in alto (un poco piu' scura), in mezzo, davanti in basso (la piu' chiara, copre il fondo di
    # quelle dietro); qualche gruppo manca, per i vuoti
    for px in (-0.27, 0.0, 0.27):
        g(px + rng.uniform(-0.03, 0.03), 0.10, 0.21, schiaccia=0.5, tono=4.7)
    for px in (-0.39, -0.13, 0.13, 0.39):
        if rng.random() < 0.88:
            g(px + rng.uniform(-0.03, 0.03), 0.19, 0.16, schiaccia=0.52, tono=4.9)
    for px in (-0.25, 0.01, 0.26):
        if rng.random() < 0.85:
            g(px + rng.uniform(-0.04, 0.04), 0.28, 0.14, schiaccia=0.55, tono=5.1)
    gruppi.sort(key=lambda q: q[1])
    # le radici dietro (si vedono solo ai lati del tronco)
    for ang in (205 + rng.uniform(-10, 10), 335 + rng.uniform(-10, 10)):
        _radice(T, cx + np.cos(np.radians(ang)) * hw_b * 0.7, base - 1, ang, alto * 0.14, alto * 0.065, rng)
    # il tronco: dal piede alla forca, un po' storto, piu' largo in basso e allargato al piede
    n = int(base - yf) * 2
    curva = rng.uniform(-0.05, 0.05) * alto
    pts = _bezier((cx, base), (cx + curva, (base + yf) / 2), (fx, yf), n)
    larghi = []
    for i in range(len(pts)):
        t = i / (len(pts) - 1)
        lw = 2 * (hw_f + (hw_b - hw_f) * (1 - t) ** 2) + (alto * 0.05) * max(0.0, 1 - t / 0.12) ** 2
        larghi.append(lw)
    _tronco_grosso(T, pts, larghi, rng)
    # l'ombra della chioma sul tronco in alto: un gradino piu' scuro
    giu_chioma = max(q[1] + q[4] for q in gruppi)
    for y in range(int(yf - 4), int(min(base - 10, giu_chioma + alto * 0.06))):
        for x in range(w):
            if T.op[y, x]:
                c = tuple(T.img[y, x])
                if c in TRONCO and TRONCO.index(c) > 0:
                    T.img[y, x] = TRONCO[TRONCO.index(c) - 1]
    # le radici davanti: a sinistra, verso di noi, a destra
    for ang, L, F in ((168 + rng.uniform(-8, 8), 0.21, 0.09), (138 + rng.uniform(-10, 10), 0.16, 0.08),
                      (92 + rng.uniform(-6, 6), 0.11, 0.07), (48 + rng.uniform(-10, 10), 0.15, 0.075),
                      (12 + rng.uniform(-8, 8), 0.2, 0.085)):
        a = np.radians(ang)
        _radice(T, cx + np.cos(a) * hw_b * 0.8, base + np.sin(a) * hw_b * 0.3, ang, alto * L * rng.uniform(0.85, 1.15),
                alto * F * rng.uniform(0.85, 1.15), rng)
    # il muschio: sul dorso delle radici e sul lato in luce del tronco, piu' fitto in basso
    for y in range(int(yf), h):
        for x in range(w):
            if not T.op[y, x] or tuple(T.img[y, x]) != TRONCO[3]:
                continue
            sopra_vuoto = y == 0 or not T.op[y - 1, x]
            basso = (y - yf) / max(1, base - yf)
            if (sopra_vuoto and rng.random() < 0.5) or rng.random() < 0.035 * basso:
                _muschio(T, x - 1, y, rng, grande=basso > 0.7)
    # la liana che gira attorno al tronco: tratti in diagonale sul davanti (dietro non si vede), a giri irregolari
    # (piu' stretti e piu' larghi, ogni tanto un giro saltato: non un bastoncino di zucchero)
    y0 = base - alto * rng.uniform(0.04, 0.09)
    while True:
        passo = alto * rng.uniform(0.08, 0.15)
        if y0 - passo * 0.5 <= yf + 6:
            break
        if rng.random() < 0.8:
            tratto = []
            sale = passo * rng.uniform(0.35, 0.6)
            for k in range(int(sale)):
                t = k / sale
                y = y0 - k
                i = int(np.clip((base - y) / max(1, base - yf) * (len(pts) - 1), 0, len(pts) - 1))
                x = pts[i][0] - larghi[i] / 2 + larghi[i] * (t ** rng.uniform(0.8, 1.2))
                tratto.append((x, y))
            _liana(T, tratto, rng, ciuffo=False)
            _liana(T, [(x, y - 1) for (x, y) in tratto], rng, ciuffo=False)
        y0 -= passo
    # i rami: tre grandi dalla forca (a sinistra, in mezzo, a destra), che a meta' si dividono verso i gruppi della
    # chioma dalla loro parte; larghi in basso e sottili in cima
    attacchi = []
    for lato in (-1, 0, 1):
        mio = [q for q in gruppi if (q[0] - fx < -Wc * 0.12) == (lato < 0) and (q[0] - fx > Wc * 0.12) == (lato > 0)]
        if not mio:
            continue
        tx = np.mean([q[0] for q in mio]); ty = np.mean([q[1] + q[4] for q in mio])
        p0 = (fx + lato * hw_f * 0.4, yf + 3)
        q = (fx + (tx - fx) * 0.55, yf - (yf - ty) * 0.55)
        rp = _bezier(p0, (fx + (tx - fx) * 0.15, yf - (yf - ty) * 0.35), q, int(np.hypot(q[0] - p0[0], q[1] - p0[1]) * 1.6))
        w0 = hw_f * 2 * (0.62 if lato else 0.7)
        w1 = max(3.0, w0 * 0.55)
        _legno(T, rp, [w0 + (w1 - w0) * i / (len(rp) - 1) for i in range(len(rp))])
        attacchi.append(rp)
        for (mx, my, rx, ryt, ryb, tono) in mio:
            p2 = (mx + rng.uniform(-0.25, 0.25) * rx, my + ryb * 0.3)
            p1 = ((q[0] + p2[0]) / 2, q[1] - (q[1] - p2[1]) * 0.7)
            r2 = _bezier(q, p1, p2, int(np.hypot(p2[0] - q[0], p2[1] - q[1]) * 1.6))
            _legno(T, r2, [w1 + (2.0 - w1) * (i / (len(r2) - 1)) ** 0.8 for i in range(len(r2))])
            attacchi.append(r2)
    # il muschio sul dorso dei rami
    for y in range(int(cima), int(yf) + 4):
        for x in range(w):
            if T.op[y, x] and tuple(T.img[y, x]) == TRONCO[3] and (y == 0 or not T.op[y - 1, x]) and rng.random() < 0.3:
                _muschio(T, x - 1, y, rng)
    # le liane ad arco fra i rami, sotto la chioma
    for _ in range(int(rng.integers(2, 4))):
        i, j = rng.choice(len(attacchi), 2, replace=False)
        a = attacchi[i][int(len(attacchi[i]) * rng.uniform(0.35, 0.7))]
        b = attacchi[j][int(len(attacchi[j]) * rng.uniform(0.35, 0.7))]
        if abs(a[0] - b[0]) > 14:
            _arco(T, a, b, rng.uniform(8, 22), rng, fiori=rng.random() < 0.4)
    # la chioma, dal dietro al davanti
    chioma = np.zeros((h, w), bool)
    for (mx, my, rx, ryt, ryb, tono) in gruppi:
        chioma |= _gruppo(T, mx, my, rx, ryt, ryb, tono, rng)
    # le liane che pendono dal fondo dei gruppi
    fondi = []
    for x in range(w):
        col = np.nonzero(chioma[:, x])[0]
        if len(col):
            fondi.append((x, col.max()))
    for _ in range(int(Wc / 22)):
        x, yb = fondi[int(rng.integers(len(fondi)))]
        L = int(rng.choice([rng.uniform(8, 25), rng.uniform(25, 60), rng.uniform(60, max(61, base - yb - 30))],
                           p=[0.45, 0.4, 0.15]))
        if yb + L < base - 6:
            _pendente(T, x, yb + 2, L, rng, fiori=rng.random() < 0.25)
    # la bromelia nella forca: le foglie verdi a rosetta e la spiga magenta in mezzo
    bx, by = int(round(fx + rng.uniform(-0.3, 0.3) * hw_f)), int(round(yf - 1))
    for j, riga in enumerate(BROMELIA):
        for i, ch in enumerate(riga):
            if ch != '.':
                T.metti(bx - 3 + i, by - len(BROMELIA) + 1 + j, {'m': FIORE_LIANA[2], 'M': FIORE_LIANA[1],
                        'o': FIORE_LIANA[0], 'g': MUSCHIO[3], 'G': MUSCHIO[2]}[ch])
    # le felci al piede, fra le radici
    for s in (-1, 1):
        if rng.random() < 0.85:
            _felce(T, cx + s * (hw_b + alto * rng.uniform(0.06, 0.1)), base + 1, alto * rng.uniform(0.065, 0.085), rng)
    # i pixel soli: solo dove i quattro vicini sono pieni (le liane e le punte delle foglie, larghe un pixel, hanno i
    # vicini trasparenti: non devono prenderne il 'colore')
    pad = np.pad(T.op, 1)
    pieni = T.op & pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:]
    _ripulisci(T.img, pieni)
    out = np.zeros((h, w, 4), np.uint8)
    out[..., :3] = T.img
    out[..., 3] = T.op * 255
    ys, xs = np.nonzero(out[..., 3])
    y0, x0 = ys.min(), max(0, xs.min() - 1)
    out = out[y0:ys.max() + 1, x0:xs.max() + 2]
    return (out, (int(round(cx)) - int(x0), int(base) - int(y0))) if con_piede else out


# ================================================================ il tronco a serpente
# Bru (disegno 111): "per dare un effetto piu' particolare potremmo curvare il tronco come nel mio disegno". Il tronco
# sale dal piede, corre di lato, gira in su a gomito e torna indietro, due o tre volte, come un nastro piegato; in cima
# il ramo grande sale in un cuscino di chioma e dall'ultima corsa altri rami salgono nell'altro (due cuscini, come nel
# disegno). La corteccia segue le curve: ogni pixel prende luce e scanalature dal punto del tronco piu' vicino, cosi'
# le venature scorrono lungo le anse; sopra le corse orizzontali il muschio e le bromelie, sotto qualche liana.

def _serpente(cx, base, alto, Wc, rng):
    """il percorso del tronco: punti fitti, le corse (inizio, fine nei punti), la cima e il verso dell'ultima corsa"""
    n = int(rng.integers(2, 4))
    R = alto * 0.56 / (2 * n + 0.6)
    lun = Wc * rng.uniform(0.2, 0.25)
    verso = 1 if rng.random() < 0.5 else -1
    pts = []

    def arco(c, r, a0, a1):
        for a in np.linspace(a0, a1, max(4, int(abs(a1 - a0) * r * 2))):
            pts.append((c[0] + r * np.cos(a), c[1] + r * np.sin(a)))

    def corsa(p0, p1, onda):
        f, ph = rng.uniform(0.7, 1.4), rng.uniform(0, 2 * np.pi)
        for t in np.linspace(0, 1, max(2, int(abs(p1[0] - p0[0]) * 2))):
            pts.append((p0[0] + (p1[0] - p0[0]) * t,
                        p0[1] + (p1[1] - p0[1]) * t + onda * np.sin(np.pi * t) * np.sin(2 * np.pi * f * t + ph)))
    y = base - alto * 0.08 - R
    for t in np.linspace(0, 1, int((base - y - R) * 2) + 2):        # su dal piede
        pts.append((cx, base - (base - y - R) * t))
    if verso > 0:                                                     # il primo gomito, verso il lato
        arco((cx + R, y + R), R, np.pi, 1.5 * np.pi)
    else:
        arco((cx - R, y + R), R, 0.0, -0.5 * np.pi)
    x = cx + verso * R
    corse = []
    for k in range(n):
        xe = cx + verso * lun * (rng.uniform(0.9, 1.1) if k < n - 1 else rng.uniform(0.3, 0.6))
        ye = y + rng.uniform(-0.03, 0.03) * alto
        i0 = len(pts)
        corsa((x, y), (xe, ye), rng.uniform(1.0, 3.0))
        corse.append((i0, len(pts)))
        if k < n - 1:                                                 # il gomito: mezzo cerchio in su, in fuori
            if verso > 0:
                arco((xe, ye - R), R, 0.5 * np.pi, -0.5 * np.pi)
            else:
                arco((xe, ye - R), R, 0.5 * np.pi, 1.5 * np.pi)
            x, y = xe, ye - 2 * R
            verso = -verso
        else:
            x, y = xe, ye
    if verso > 0:                                                     # in cima: un quarto di gomito in su
        arco((x, y - R), R, 0.5 * np.pi, 0.0)
    else:
        arco((x, y - R), R, 0.5 * np.pi, np.pi)
    return np.array(pts, float), corse, verso


def _legno_lungo(T, P, Wd, rng, rampa=TRONCO):
    """Il tronco lungo il percorso: ogni pixel prende il punto piu' vicino (in raggi); la luce da in alto a sinistra
    rispetto a quel punto; le scanalature a distanza fissa di traverso, che ondeggiano piano lungo il tronco (un
    gradino piu' scure, la luce sul labbro); il riflesso sul bordo in ombra."""
    tg = np.gradient(P, axis=0)
    tg /= np.linalg.norm(tg, axis=1)[:, None] + 1e-9
    nr = np.stack([-tg[:, 1], tg[:, 0]], 1)
    sarc = np.concatenate([[0], np.cumsum(np.linalg.norm(np.diff(P, axis=0), axis=1))])
    best = np.full((T.h, T.w), np.inf)
    idx = np.full((T.h, T.w), -1, int)
    for i in range(len(P)):
        x, y = P[i]
        r = Wd[i] / 2
        x0, x1 = max(0, int(x - r - 1)), min(T.w, int(x + r + 2))
        y0, y1 = max(0, int(y - r - 1)), min(T.h, int(y + r + 2))
        if x0 >= x1 or y0 >= y1:
            continue
        yy, xx = np.mgrid[y0:y1, x0:x1]
        d = np.hypot(xx + 0.5 - x, yy + 0.5 - y) / r
        sb, si = best[y0:y1, x0:x1], idx[y0:y1, x0:x1]
        m = d < sb
        sb[m] = d[m]
        si[m] = i
    ys, xs = np.nonzero(best <= 1.0)
    i = idx[ys, xs]
    r = Wd[i] / 2
    ox, oy = (xs + 0.5 - P[i, 0]) / r, (ys + 0.5 - P[i, 1]) / r
    sl = ox * LUCE[0] + oy * LUCE[1]
    k = np.where(sl > 0.42, 3, np.where(sl > -0.2, 2, np.where(sl > -0.72, 1, 0)))
    caso = rng.random(len(ys))
    k = np.where((best[ys, xs] > 0.8) & (sl < -0.72) & (caso < 0.5), 1, k)     # il riflesso del prato
    u = ox * nr[i, 0] + oy * nr[i, 1]
    verso_luce = np.sign(nr[i, 0] * LUCE[0] + nr[i, 1] * LUCE[1] + 1e-9)
    for j, u0 in enumerate((-0.64, -0.3, 0.04, 0.38, 0.7)):
        f1, f2 = rng.uniform(0, 2 * np.pi, 2)
        uu = u0 + 0.07 * np.sin(sarc[i] / 7.0 + f1)
        aperto = np.sin(sarc[i] / 5.3 + f2) + 0.4 * np.sin(sarc[i] / 2.3 + f1) > -1.0   # ogni tanto il solco si rompe
        du = (u - uu) * r
        solco = (np.abs(du) < 0.5) & aperto
        labbro = (du * verso_luce >= 0.5) & (du * verso_luce < 1.5) & aperto & (caso < 0.55)
        k = np.where(solco, np.maximum(0, k - 1), np.where(labbro, np.minimum(3, k + 1), k))
    T.img[ys, xs] = np.array(rampa, np.uint8)[k]
    T.op[ys, xs] = True


def albero_serpente(alto=230, seme=1, con_piede=False):
    rng = np.random.default_rng(seme)
    Wc = alto * rng.uniform(0.95, 1.05)
    w, h = int(Wc) + 40, alto + 14
    T = _Tela(h, w)
    base = h - 8
    cx = w / 2 + rng.uniform(-3, 3)
    cima = base - alto + 4
    W0 = alto * 0.1                                          # quanto e' grosso il tronco al piede
    P, corse, verso = _serpente(cx, base, alto, Wc, rng)
    sarc = np.concatenate([[0], np.cumsum(np.linalg.norm(np.diff(P, axis=0), axis=1))])
    Wd = W0 * (1 - 0.3 * sarc / sarc[-1]) + alto * 0.045 * np.clip(1 - (base - P[:, 1]) / (alto * 0.05), 0, 1) ** 2
    xt, yt = P[-1]
    # i due cuscini della chioma: quello del ramo grande dalla sua parte, l'altro dall'altra; uno piu' alto
    sA = 1 if xt >= cx else -1
    alzo = rng.uniform(-0.03, 0.03) * alto
    cuscini = [(cx + sA * Wc * rng.uniform(0.22, 0.27), cima + alto * 0.15 + alzo, sA),
               (cx - sA * Wc * rng.uniform(0.2, 0.25), cima + alto * 0.11 - alzo, -sA)]
    gruppi = []
    for (px_, py_, fuori) in cuscini:
        # (spostamento x verso fuori, y, raggio, schiacciato, tono): dietro, sopra, davanti, e uno che allunga il
        # cuscino verso fuori
        for (dx_, dy_, rr, sch, tono) in ((-0.1, -0.02, 0.15, 0.5, 4.8), (0.1, -0.03, 0.14, 0.5, 4.8),
                                           (0.0, -0.08, 0.13, 0.5, 4.9), (-0.06, 0.05, 0.14, 0.55, 5.1),
                                           (0.08, 0.055, 0.12, 0.55, 5.0), (0.2, 0.01, 0.1, 0.52, 4.9)):
            if rng.random() < 0.92:
                rx = Wc * rr * rng.uniform(0.9, 1.1)
                gruppi.append((px_ + fuori * Wc * dx_ + rng.uniform(-3, 3), py_ + alto * dy_ + rng.uniform(-2, 2), rx,
                               rx * sch, rx * sch * 0.55, tono))
    gruppi.sort(key=lambda q: q[1])
    giu_chioma = max(q[1] + q[4] for q in gruppi)
    # le radici dietro, il tronco a serpente, le radici davanti
    hw_b = W0 / 2
    for ang in (205 + rng.uniform(-10, 10), 335 + rng.uniform(-10, 10)):
        _radice(T, cx + np.cos(np.radians(ang)) * hw_b * 0.7, base - 1, ang, alto * 0.14, alto * 0.065, rng)
    _legno_lungo(T, P, Wd, rng)
    for ang, L, F in ((168 + rng.uniform(-8, 8), 0.2, 0.085), (138 + rng.uniform(-10, 10), 0.15, 0.075),
                      (92 + rng.uniform(-6, 6), 0.1, 0.065), (48 + rng.uniform(-10, 10), 0.14, 0.07),
                      (12 + rng.uniform(-8, 8), 0.19, 0.08)):
        a = np.radians(ang)
        _radice(T, cx + np.cos(a) * hw_b * 0.8, base + np.sin(a) * hw_b * 0.3, ang, alto * L * rng.uniform(0.85, 1.15),
                alto * F * rng.uniform(0.85, 1.15), rng)
    # l'ombra della chioma sul tronco in alto: un gradino piu' scuro
    for y in range(max(0, int(giu_chioma) - 2), min(h, int(giu_chioma + alto * 0.07))):
        for x in range(w):
            if T.op[y, x]:
                c = tuple(int(v) for v in T.img[y, x])
                if c in TRONCO and TRONCO.index(c) > 0:
                    T.img[y, x] = TRONCO[TRONCO.index(c) - 1]
    # i rami: quello grande dalla cima del tronco nel suo cuscino, due dall'ultima corsa nell'altro; dentro i
    # cuscini i rametti verso i gruppi
    attacchi = []
    Wt = Wd[-1]
    mioA = [q for q in gruppi if (q[0] - cx) * sA > 0]
    mioB = [q for q in gruppi if (q[0] - cx) * sA <= 0]

    def ramo(p0, w0, gr):
        if not gr:
            return
        tx = np.mean([q[0] for q in gr]); ty = np.mean([q[1] + q[4] for q in gr])
        q1 = (p0[0] + (tx - p0[0]) * 0.5, p0[1] - (p0[1] - ty) * 0.75)
        rp = _bezier(p0, (p0[0] + (tx - p0[0]) * 0.15, p0[1] - (p0[1] - ty) * 0.45), q1,
                     int(np.hypot(q1[0] - p0[0], q1[1] - p0[1]) * 1.6))
        w1 = max(3.0, w0 * 0.6)
        _legno(T, rp, [w0 + (w1 - w0) * i / max(1, len(rp) - 1) for i in range(len(rp))])
        attacchi.append(rp)
        for (mx, my, rx, ryt, ryb, tono) in gr:
            p2 = (mx + rng.uniform(-0.25, 0.25) * rx, my + ryb * 0.3)
            r2 = _bezier(q1, ((q1[0] + p2[0]) / 2, q1[1] - (q1[1] - p2[1]) * 0.7), p2,
                         int(np.hypot(p2[0] - q1[0], p2[1] - q1[1]) * 1.6))
            _legno(T, r2, [w1 + (2.0 - w1) * (i / max(1, len(r2) - 1)) ** 0.8 for i in range(len(r2))])
            attacchi.append(r2)
    ramo((xt, yt + 1), Wt * 0.95, mioA)
    i0, i1 = corse[-1]
    for f in sorted(rng.uniform(0.3, 0.8, 2)):
        j = int(i0 + (i1 - i0) * f)
        if mioB:
            ramo((P[j, 0], P[j, 1] - Wd[j] * 0.3), Wd[j] * 0.5, mioB[:3] if f < 0.55 else mioB[2:] or mioB)
    # il muschio: sul dorso delle corse e dei rami (dove sopra e' vuoto), sul lato in luce in basso
    for y in range(0, h):
        for x in range(w):
            if not T.op[y, x] or tuple(int(v) for v in T.img[y, x]) != TRONCO[3]:
                continue
            sopra_vuoto = y == 0 or not T.op[y - 1, x]
            if (sopra_vuoto and rng.random() < 0.35) or (y > base - alto * 0.1 and rng.random() < 0.03):
                _muschio(T, x - 1, y, rng, grande=y > base - alto * 0.12)
    # sopra le corse una o due bromelie; sotto le corse qualche liana corta
    dorsi, pance = [], []
    for (a_, b_) in corse:
        for j in range(a_, b_, 3):
            x, y = int(round(P[j, 0])), int(round(P[j, 1]))
            r = Wd[j] / 2
            dorsi.append((x, int(round(y - r))))
            pance.append((x, int(round(y + r)) + 1))
    for _ in range(int(rng.integers(1, 3))):
        bx, by = dorsi[int(rng.integers(len(dorsi)))]
        for j, riga in enumerate(BROMELIA):
            for i, ch in enumerate(riga):
                if ch != '.':
                    T.metti(bx - 3 + i, by - len(BROMELIA) + 2 + j, {'m': FIORE_LIANA[2], 'M': FIORE_LIANA[1],
                            'o': FIORE_LIANA[0], 'g': MUSCHIO[3], 'G': MUSCHIO[2]}[ch])
    for _ in range(int(rng.integers(2, 5))):
        x, y = pance[int(rng.integers(len(pance)))]
        if y < base - alto * 0.12:
            _pendente(T, x, y, int(rng.uniform(6, 24)), rng, fiori=rng.random() < 0.3)
    # le liane ad arco fra i rami, sotto la chioma
    for _ in range(int(rng.integers(1, 3))):
        if len(attacchi) < 2:
            break
        i, j = rng.choice(len(attacchi), 2, replace=False)
        a = attacchi[i][int(len(attacchi[i]) * rng.uniform(0.35, 0.7))]
        b = attacchi[j][int(len(attacchi[j]) * rng.uniform(0.35, 0.7))]
        if abs(a[0] - b[0]) > 14:
            _arco(T, a, b, rng.uniform(8, 20), rng, fiori=rng.random() < 0.4)
    # la chioma, dal dietro al davanti, e le liane che pendono dai cuscini
    chioma = np.zeros((h, w), bool)
    for (mx, my, rx, ryt, ryb, tono) in gruppi:
        chioma |= _gruppo(T, mx, my, rx, ryt, ryb, tono, rng)
    fondi = [(x, np.nonzero(chioma[:, x])[0].max()) for x in range(w) if chioma[:, x].any()]
    for _ in range(int(Wc / 24)):
        x, yb = fondi[int(rng.integers(len(fondi)))]
        L = int(rng.choice([rng.uniform(8, 22), rng.uniform(22, 50), rng.uniform(50, 90)], p=[0.45, 0.4, 0.15]))
        if yb + L < base - 8:
            _pendente(T, x, yb + 2, L, rng, fiori=rng.random() < 0.25)
    # le felci al piede
    for s_ in (-1, 1):
        if rng.random() < 0.85:
            _felce(T, cx + s_ * (hw_b + alto * rng.uniform(0.06, 0.1)), base + 1, alto * rng.uniform(0.065, 0.085), rng)
    pad = np.pad(T.op, 1)
    pieni = T.op & pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:]
    _ripulisci(T.img, pieni)
    out = np.zeros((h, w, 4), np.uint8)
    out[..., :3] = T.img
    out[..., 3] = T.op * 255
    ys, xs = np.nonzero(out[..., 3])
    y0, x0 = ys.min(), max(0, xs.min() - 1)
    out = out[y0:ys.max() + 1, x0:xs.max() + 2]
    return (out, (int(round(cx)) - int(x0), int(base) - int(y0))) if con_piede else out


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
