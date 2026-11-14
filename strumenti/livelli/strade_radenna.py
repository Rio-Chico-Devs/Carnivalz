# Il kit delle strade di Radenna, dal foglio di Bru (strumenti/livelli/fogli/
# strade_radenna.jpg): pezzi da posare sull'erba (art/livelli/terreni/).
#
#   python3 strumenti/livelli/strade_radenna.py        (serve numpy e Pillow)
#
# Niente e' ridisegnato a mano: ogni pezzo viene dal foglio, pulito.
#
# LA STRADA. Il motivo a zig-zag (55 pixel) compare sei volte nelle tre strade
# orizzontali del foglio: le copie, allineate al pixel, danno per ogni punto il
# colore su cui sono d'accordo (la mediana), cosi' sparisce il rumore del JPG e
# dell'AI. Il motivo e' simmetrico destra-sinistra (lo scarto dallo specchio e'
# quello del rumore): si media col suo specchio. Poi sei toni (fuga nera,
# fuga, scuro, pietra, chiaro, spigolo), un po' piu' staccati (in OKLab); i
# cordoli e le fughe, righe dritte, di un tono solo. La strada verticale e' la
# stessa ruotata in senso antiorario: il cordolo in luce (sopra) va a
# sinistra, quello in ombra (sotto, con l'ombra di due pixel) a destra; la luce
# viene dall'alto a sinistra. Larga 29 pixel, cordoli compresi.
#
# IL NODO. Gli incroci, le T, le curve e le piazzette in fondo alle strade
# sono un nodo solo: la lastra ottagonale al centro dell'incrocio del foglio,
# 41x41 con gli smussi di 6, cosi' i lati dritti sono di 29, come la strada.
# Il bordo e' lo stesso cordolo della strada girato a cornice (in luce sopra e
# a sinistra, in ombra sotto e a destra); dentro, i rombi concentrici con la
# sequenza di anelli misurata sul nodo del foglio. Le strade ci arrivano
# dritte: la strada orizzontale con la sua riga 0 sulla riga 6 del nodo, la
# verticale con la sua colonna 0 sulla colonna 6.
#
# I FINE STRADA. Il cordolo girato a cornice chiude l'ultimo pezzo (14 pixel):
# fine_strada_dx va dopo una strada orizzontale intera (il motivo riparte da
# 0), fine_strada_sx prima; giu' e su lo stesso per le verticali.
#
# I CIUFFI. Nel foglio l'erba copre i bordi dei cordoli: dove una copia del
# motivo aveva erba sui cordoli, qui c'e' un buco e si vede il prato vero
# (stesso colore per forza). Sul nodo solo sugli smussi: sui lati possono
# arrivare strade.
#
# L'ANELLO. Una piazza tonda (76x76) attorno a un buco di 35 pixel (per un
# albero, una fontana): i quarti del foglio hanno tutti il centro nell'angolo e
# il buco di raggio 17,6; quelli disegnati uguali, sovrapposti, danno un quarto
# pulito che si ruota nei quattro angoli. Le strade ci arrivano sugli assi
# (sulle fughe fra i blocchi), centrate, e finiscono sotto l'anello a 31
# pixel dal centro: si posa prima la strada, poi l'anello.
#
# LE FOGLIE. Le quattro lastre a foglia negli angoli dell'incrocio del foglio
# sono la stessa, specchiata: sovrapposte danno una foglia pulita, da mettere
# negli angoli fra le strade, attorno ai nodi.
#
# Il resto (i quarti d'anello come nel foglio, le rovine, il muretto) resta
# com'e' disegnato, coi colori del kit e senza la sua erba.
# Scrive art/livelli/terreni/strade_radenna/<nome>.png.
import os
from collections import deque

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
FUORI = os.path.join(QUI, '..', '..', 'art', 'livelli', 'terreni', 'strade_radenna')
LUMA = np.array([0.3, 0.55, 0.15])
im = np.array(Image.open(os.path.join(QUI, 'fogli', 'strade_radenna.jpg')).convert('RGB')).astype(float)
H, W, _ = im.shape
BIANCO = im.min(2) >= 222
L = im.mean(2)


# ---------------------------------------------------------------- il foglio

def griglia(prof):
    n = len(prof); best = None
    for p in np.arange(2.85, 3.01, 0.005):
        for f in np.arange(0, p, 0.1):
            i = np.round(np.arange(f, n - 1, p)).astype(int); i = i[(i >= 0) & (i < n)]
            sc = prof[i].mean()
            if best is None or sc > best[0]:
                best = (sc, p, f)
    return best[1], best[2]


def pixel_veri(x0, y0, x1, y1, margine=6):
    # il pezzo del foglio riportato ai suoi pixel veri (passo 2,93)
    a, b, c, d = max(0, y0 - margine), max(0, x0 - margine), min(H, y1 + margine + 1), min(W, x1 + margine + 1)
    C = im[a:c, b:d]; B = BIANCO[a:c, b:d]; Lc = L[a:c, b:d]
    px, fx = griglia(np.abs(np.diff(Lc, axis=1)).mean(0)); py, fy = griglia(np.abs(np.diff(Lc, axis=0)).mean(1))
    bx = np.arange(fx + 1 - px, d - b, px); by = np.arange(fy + 1 - py, c - a, py)
    o = np.zeros((len(by), len(bx), 4))
    for j in range(len(by)):
        for i in range(len(bx)):
            xa, xb = int(round(bx[i] + 0.7)), int(round(bx[i] + px - 0.7)); ya, yb = int(round(by[j] + 0.7)), int(round(by[j] + py - 0.7))
            xa, ya = max(0, xa), max(0, ya); xb, yb = min(d - b, max(xa + 1, xb)), min(c - a, max(ya + 1, yb))
            q = C[ya:yb, xa:xb].reshape(-1, 3); bq = B[ya:yb, xa:xb].reshape(-1)
            if len(q) == 0 or bq.mean() >= 0.5:
                continue
            o[j, i, :3] = np.median(q[~bq], 0); o[j, i, 3] = 255
    o = np.floor(o)
    ys, xs = np.nonzero(o[..., 3])
    return o[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


# ---------------------------------------------------------------- i colori (OKLab)

_M1 = np.array([[0.4122214708, 0.5363325363, 0.0514459929], [0.2119034982, 0.6806995451, 0.1073969566],
                [0.0883024619, 0.2817188376, 0.6299787005]])
_M2 = np.array([[0.2104542553, 0.7936177850, -0.0040720468], [1.9779984951, -2.4285922050, 0.4505937099],
                [0.0259040371, 0.7827717662, -0.8086757660]])
_M1i, _M2i = np.linalg.inv(_M1), np.linalg.inv(_M2)


def in_lab(rgb):
    c = rgb / 255.0
    return np.cbrt(np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4) @ _M1.T) @ _M2.T


def da_lch(Lk, Ck, hk):
    # il colore sullo schermo; se esce dai colori possibili, meno saturo
    for _ in range(40):
        lin = ((np.array([Lk, Ck * np.cos(hk), Ck * np.sin(hk)]) @ _M2i.T) ** 3) @ _M1i.T
        if (lin >= -1e-4).all() and (lin <= 1 + 1e-4).all():
            break
        Ck *= 0.93
    lin = np.clip(lin, 0, 1)
    return np.round(np.where(lin <= 0.0031308, lin * 12.92, 1.055 * lin ** (1 / 2.4) - 0.055) * 255.0).astype(int)


def croma_tinta(rgb):
    lab = in_lab(rgb.reshape(-1, 3).astype(float)).reshape(rgb.shape)
    return lab[..., 0], np.hypot(lab[..., 1], lab[..., 2]), np.degrees(np.arctan2(lab[..., 2], lab[..., 1])) % 360


# i sei toni della pietra, come luce nel disegno: fuga nera, fuga, scuro,
# pietra, chiaro, spigolo
CENTRI = np.array([58.0, 73.0, 85.3, 101.1, 110.6, 124.0])


def toni(rgb):
    return np.abs((rgb @ LUMA)[..., None] - CENTRI).argmin(-1)


def tavolozza(motivo, stira=1.6):
    # il colore di ogni tono: mediana dei pixel del motivo con quella luce,
    # poi piu' staccati attorno alla luce media
    idx = toni(motivo)
    base = np.array([np.median(motivo[idx == k], 0) for k in range(len(CENTRI))])
    lab = in_lab(base.astype(float))
    Lk, Ck, hk = lab[:, 0], np.hypot(lab[:, 1], lab[:, 2]), np.arctan2(lab[:, 2], lab[:, 1])
    m = Lk[1:5].mean()
    return np.array([da_lch(m + (Lk[k] - m) * stira, Ck[k], hk[k]) for k in range(len(CENTRI))], float)


def pulisci8(lab, mask=None, ciclico_x=False):
    # un pixel che non ha nessun vicino (anche in diagonale) del suo tono
    # prende il tono piu' comune attorno: le linee diagonali sottili restano
    h, w = lab.shape; r = lab.copy()
    for y in range(h):
        for x in range(w):
            if mask is not None and not mask[y, x]:
                continue
            v = []
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    if not (dy or dx):
                        continue
                    yy, xx = y + dy, x + dx
                    if ciclico_x:
                        xx %= w
                    if 0 <= yy < h and 0 <= xx < w and (mask is None or mask[yy, xx]):
                        v.append(lab[yy, xx])
            if v and lab[y, x] not in v:
                r[y, x] = max(set(v), key=v.count)
    return r


def allarga(m, k):
    for _ in range(k):
        p = np.pad(m, 1); m = m | p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:]
    return m


def stringi(m, k):
    for _ in range(k):
        p = np.pad(m, 1, constant_values=True); m = m & p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:]
    return m


def vicini4(y, x, h, w):
    return [(yy, xx) for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)) if 0 <= yy < h and 0 <= xx < w]


def maschera_pietra(o):
    # la pietra: grigia e non scura, con le fughe chiuse e senza pezzetti
    # sotto i 12 pixel
    m = o[..., 3] > 0
    Lk, Ck, _ = croma_tinta(o[..., :3])
    p = stringi(allarga(m & (Ck < 0.04) & (Lk > 0.33), 2), 2) & m
    h, w = p.shape; vis = np.zeros_like(p); pietra = np.zeros_like(p)
    for y0, x0 in zip(*np.nonzero(p)):
        if vis[y0, x0]:
            continue
        q = deque([(y0, x0)]); vis[y0, x0] = True; cel = []
        while q:
            y, x = q.popleft(); cel.append((y, x))
            for yy, xx in vicini4(y, x, h, w):
                if p[yy, xx] and not vis[yy, xx]:
                    vis[yy, xx] = True; q.append((yy, xx))
        if len(cel) >= 12:
            for y, x in cel:
                pietra[y, x] = True
    return pietra


def togli_alone(o):
    # il bordo schiarito dal bianco del foglio, e i puntini chiari soli
    o = o.copy(); h, w = o.shape[:2]
    for _ in range(2):
        m = o[..., 3] > 0
        pad = np.pad(m, 1)
        bordo = m & (~pad[:-2, 1:-1] | ~pad[2:, 1:-1] | ~pad[1:-1, :-2] | ~pad[1:-1, 2:])
        lum = o[..., :3] @ LUMA
        nuovo = o.copy()
        for y, x in zip(*np.nonzero(bordo)):
            v = [(lum[yy, xx], yy, xx) for yy, xx in vicini4(y, x, h, w) if m[yy, xx] and not bordo[yy, xx]] \
                or [(lum[yy, xx], yy, xx) for yy, xx in vicini4(y, x, h, w) if m[yy, xx]]
            if v and lum[y, x] > min(v)[0] + 25 and lum[y, x] > max(t[0] for t in v) - 5:
                nuovo[y, x, :3] = o[min(v)[1], min(v)[2], :3]
        o = nuovo
    m = o[..., 3] > 0; lum = o[..., :3] @ LUMA
    for y, x in zip(*np.nonzero(m)):
        v = [lum[yy, xx] for yy, xx in vicini4(y, x, h, w) if m[yy, xx]]
        if len(v) >= 3 and lum[y, x] > max(v) + 60:
            o[y, x, :3] = np.median([o[yy, xx, :3] for yy, xx in vicini4(y, x, h, w) if m[yy, xx]], 0)
    return o


# ---------------------------------------------------------------- 1. il motivo della strada

R0, R1, P = 13, 42, 55       # le righe della fascia (cordoli compresi) e il passo del motivo
o1 = pixel_veri(25, 23, 366, 181, 1)     # le tre strade orizzontali (le prime due sono attaccate)
o2 = pixel_veri(25, 185, 366, 343, 1)
o3 = pixel_veri(24, 364, 366, 545)
COPIE = [(o1, 0), (o1, 55), (o2, 0), (o2, 55), (o3, 53), (o3, -1)]


def allinea(a, x0, rif):
    best = None
    for dy in (-1, 0, 1):
        for dx in (-2, -1, 0, 1, 2):
            xs = x0 + dx; ys = R0 + dy
            if xs < 0 or xs + P > a.shape[1] or ys < 0 or ys + (R1 - R0) > a.shape[0]:
                continue
            c = a[ys:ys + R1 - R0, xs:xs + P, :3].astype(float)
            d = np.abs((c - rif) @ LUMA).mean()
            if best is None or d < best[0]:
                best = (d, c)
    return None if best is None else best[1]


pezzi = [p for p in (allinea(a, x0, o1[R0:R1, 0:P, :3].astype(float)) for a, x0 in COPIE) if p is not None]
for _ in range(2):
    med = np.median(np.stack(pezzi), 0)
    pezzi = [p for p in (allinea(a, x0, med) for a, x0 in COPIE) if p is not None]
med = np.median(np.stack(pezzi), 0)
motivo = (med + med[:, [(5 - x) % P for x in range(P)]]) / 2     # simmetrico attorno a x = 2,5
TAV = tavolozza(motivo)
T55 = toni(motivo)
for y in list(range(0, 6)) + list(range(22, R1 - R0)):           # cordoli e fughe: un tono per riga
    T55[y, :] = toni(np.median(motivo[y], 0)[None])[0]
T55[6:22] = pulisci8(T55[6:22], ciclico_x=True)

# i ciuffi: l'erba sui cordoli nella prima copia del motivo
_, Ck, hk = croma_tinta(o1[R0:R0 + 29, 0:P, :3])
CIUFFI = (Ck > 0.045) & (hk > 110) & (hk < 175)
CIUFFI[4:24] = False


# ---------------------------------------------------------------- 2. cordoli, ciuffi, pezzi del kit

SU = [0, 1, 2, 5, 1, 0]          # il cordolo dal lato in luce, da fuori verso dentro
GIU = [0, 0, 2, 3, 5, 1, 0]      # dal lato in ombra
IN_LUCE = {'su', 'sx', 'su_sx', 'su_dx'}


def cornice(dist):
    # il cordolo lungo i lati dati (distanza dal lato): il lato piu' vicino
    # sceglie il profilo; -1 oltre il cordolo
    lati = list(dist); D = np.stack([dist[l] for l in lati])
    k, d = D.argmin(0), D.min(0)
    out = np.full(d.shape, -1)
    for i, l in enumerate(lati):
        prof = SU if l in IN_LUCE else GIU
        sel = (k == i) & (d >= 0) & (d < len(prof)); out[sel] = np.array(prof)[d[sel]]
    return out


def ciuffi(t, dist, lungo, senza=()):
    lati = list(dist); D = np.stack([dist[l] for l in lati])
    k, d = D.argmin(0), D.min(0)
    r = t.copy()
    for i, l in enumerate(lati):
        if l in senza:
            continue
        sel = (k == i) & (d >= 0) & (d <= 3)
        riga = np.where(l in IN_LUCE, d, 28 - d)
        erba = CIUFFI[riga.clip(0, 28), lungo[l] % P]
        r[sel & erba] = -1
    return r


def strada_o(lung, fase=0, fine=()):
    idx = (np.arange(lung) + fase) % P
    t = T55[:, idx].copy()
    h, w = t.shape; y, x = np.mgrid[0:h, 0:w]
    dist = {'su': y, 'giu': h - 1 - y}
    if 'sx' in fine:
        dist['sx'] = x
    if 'dx' in fine:
        dist['dx'] = w - 1 - x
    if fine:
        c = cornice(dist); t = np.where(c >= 0, c, t)
    return ciuffi(t, dist, {'su': x + fase, 'giu': x + fase, 'sx': y, 'dx': y})


def strada_v(lung, fase=0, fine=()):
    V = np.rot90(T55, 1)             # in senso antiorario: il cordolo in luce a sinistra
    idx = (np.arange(lung) + fase) % V.shape[0]
    t = V[idx, :].copy()
    h, w = t.shape; y, x = np.mgrid[0:h, 0:w]
    dist = {'sx': x, 'dx': w - 1 - x}
    if 'su' in fine:
        dist['su'] = y
    if 'giu' in fine:
        dist['giu'] = h - 1 - y
    if fine:
        c = cornice(dist); t = np.where(c >= 0, c, t)
    return ciuffi(t, dist, {'sx': y + fase, 'dx': y + fase, 'su': x, 'giu': x})


# gli anelli del nodo (distanza dal centro a passi di rombo -> tono), misurati
# sul nodo dell'incrocio del foglio
ANELLI = [2, 2, 2, 1, 4, 4, 3, 1, 1, 3, 4, 4, 2, 0, 1, 2, 4, 5, 1, 2, 2, 1] + [3] * 10


def nodo(collegati=('su', 'sx', 'giu', 'dx'), N=41, c=6):
    y, x = np.mgrid[0:N, 0:N]; M = N - 1
    dist = {'su': y, 'sx': x, 'giu': M - y, 'dx': M - x,
            'su_sx': x + y - c, 'su_dx': (M - x) + y - c, 'giu_sx': x + (M - y) - c, 'giu_dx': (M - x) + (M - y) - c}
    dentro = np.min(np.stack(list(dist.values())), 0) >= 0
    interno = np.array(ANELLI)[np.minimum(np.abs(x - 20) + np.abs(y - 20), len(ANELLI) - 1)]
    t = cornice(dist); t = np.where(t >= 0, t, interno); t[~dentro] = -1
    return ciuffi(t, dist, {l: (y if l in ('sx', 'dx') else x) for l in dist}, senza=collegati)


def anello(Q=38):
    # i quarti disegnati uguali (il primo dell'anello e il secondo "quarto"),
    # col buco nell'angolo in basso a destra
    def quarto(a):
        h, w = a.shape[:2]; q = np.zeros((Q, Q, 4)); p = a[max(0, h - Q):h, max(0, w - Q):w]
        q[Q - p.shape[0]:, Q - p.shape[1]:] = p
        return q
    rgb = np.median(np.stack([quarto(pixel_veri(1031, 23, 1202, 179)), quarto(pixel_veri(723, 23, 880, 178))])[..., :3], 0)
    y, x = np.mgrid[0:Q, 0:Q]; r = np.hypot(x + 0.5 - Q, y + 0.5 - Q)
    corona = (r >= 17.6) & (r < 35.5)
    t = np.where(corona, toni(rgb), -1)
    t[corona] = pulisci8(np.where(corona, t, 0), mask=corona)[corona]
    t[(r >= 34.6) & (r < 35.5)] = 0
    N = 2 * Q; a = np.full((N, N), -1)
    a[:Q, :Q] = t; a[:Q, Q:] = np.rot90(t, -1); a[Q:, Q:] = np.rot90(t, 2); a[Q:, :Q] = np.rot90(t, 1)
    # i ciuffi sul bordo di fuori (la posizione lungo il bordo e' l'angolo),
    # ma non attorno agli assi, dove possono arrivare le strade (larghe 29)
    y, x = np.mgrid[0:N, 0:N]; px, py = x + 0.5 - Q, y + 0.5 - Q
    r = np.hypot(px, py); d = np.floor(35.5 - r).astype(int)
    luce = (px + py) < 0
    pos = ((np.arctan2(py, px) + np.pi) * 35.5).astype(int) % P
    erba = CIUFFI[np.where(luce, d, 28 - d).clip(0, 28), pos]
    lontano = (np.abs(px) > 16) & (np.abs(py) > 16)
    a[(a >= 0) & (d >= 0) & (d <= 3) & erba & lontano] = -1
    return a


def foglia():
    # le quattro foglie negli angoli dell'incrocio, specchiate tutte come quella
    # in alto a sinistra e sovrapposte
    inc = pixel_veri(565, 364, 997, 744)
    B = 3
    def rit(r0, r1, c0, c1):
        return inc[max(0, r0 - B):r1 + 1 + B, max(0, c0 - B):c1 + 1 + B]
    copie = [rit(16, 43, 18, 50), rit(17, 43, 99, 130)[:, ::-1], rit(89, 114, 18, 50)[::-1], np.rot90(rit(89, 116, 98, 129), 2)]
    h = max(c.shape[0] for c in copie) + 4; w = max(c.shape[1] for c in copie) + 4
    def tela(c, dy, dx):
        t = np.zeros((h, w, 4)); t[2 + dy:2 + dy + c.shape[0], 2 + dx:2 + dx + c.shape[1]] = c
        return t
    rif = tela(copie[0], 0, 0); al = [rif]
    for c in copie[1:]:
        best = None
        for dy in range(-2, 3):
            for dx in range(-2, 3):
                if 2 + dy < 0 or 2 + dx < 0 or 2 + dy + c.shape[0] > h or 2 + dx + c.shape[1] > w:
                    continue
                t = tela(c, dy, dx)
                m = (t[..., 3] > 0) & (rif[..., 3] > 0)
                d = np.abs((t[..., :3] - rif[..., :3]) @ LUMA)[m].mean()
                if best is None or d < best[0]:
                    best = (d, t)
        al.append(best[1])
    fo = np.dstack([np.median(np.stack([a[..., :3] for a in al]), 0), np.median(np.stack([a[..., 3] for a in al]), 0)])
    pietra = maschera_pietra(fo)
    t = np.where(pietra, toni(fo[..., :3]), -1)
    t[pietra] = pulisci8(np.where(pietra, t, 0), mask=pietra)[pietra]
    t[allarga(pietra, 1) & ~pietra] = 0
    ys, xs = np.nonzero(t >= 0)
    return t[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def ricolora(o):
    # un pezzo com'e' disegnato: la sua pietra coi toni del kit, la sua erba
    # trasparente (sotto si vede il prato)
    o = togli_alone(o)
    pietra = allarga(maschera_pietra(o), 2) & (o[..., 3] > 0)
    _, Ck, _ = croma_tinta(o[..., :3])
    t = np.where(pietra & (Ck < 0.05), toni(o[..., :3]), -1)
    ys, xs = np.nonzero(t >= 0)
    return t[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


# ---------------------------------------------------------------- 3. si scrive

PEZZI = {
    'strada_orizzontale': strada_o(P),
    'strada_verticale': strada_v(P),
    'fine_strada_dx': strada_o(14, 0, ('dx',)),
    'fine_strada_sx': strada_o(14, P - 14, ('sx',)),
    'fine_strada_giu': strada_v(14, 0, ('giu',)),
    'fine_strada_su': strada_v(14, P - 14, ('su',)),
    'tratto_corto': strada_o(P, 0, ('sx', 'dx')),
    'nodo': nodo(),
    'anello': anello(),
}
f = foglia()
PEZZI.update({'foglia_1': f, 'foglia_2': f[:, ::-1], 'foglia_3': f[::-1], 'foglia_4': f[::-1, ::-1]})
for nome, scatola in (('anello_1', (1031, 23, 1202, 179)), ('anello_2', (1223, 23, 1382, 179)),
                      ('anello_3', (1032, 199, 1202, 343)), ('anello_4', (1223, 199, 1381, 343)),
                      ('quarto_1', (564, 23, 703, 179)), ('quarto_2', (723, 23, 880, 178)),
                      ('rovina_1', (1019, 363, 1191, 545)), ('rovina_2', (1211, 363, 1384, 545)),
                      ('rovina_3', (1020, 571, 1190, 744)), ('muretto_angolo', (1211, 571, 1384, 744))):
    PEZZI[nome] = ricolora(pixel_veri(*scatola))

os.makedirs(FUORI, exist_ok=True)
for vecchio in ('incrocio.png',):                 # sostituito dal nodo e dalle foglie
    if os.path.exists(os.path.join(FUORI, vecchio)):
        os.remove(os.path.join(FUORI, vecchio))
for nome, t in PEZZI.items():
    o = np.zeros(t.shape + (4,), np.uint8)
    o[t >= 0, :3] = TAV[t[t >= 0]].astype(np.uint8); o[t >= 0, 3] = 255
    Image.fromarray(o).save(os.path.join(FUORI, nome + '.png'))
print('strade:', ', '.join('%s %dx%d' % (n, t.shape[1], t.shape[0]) for n, t in PEZZI.items()))
print('tavolozza:', ' '.join('#%02x%02x%02x' % tuple(int(v) for v in c) for c in TAV))
