# LE GAMBE DI LEI DI LATO (guarda a destra), articolate: anca, ginocchio, caviglia,
# piede col tacco. Si dice dove sta il piede, il ginocchio lo trova ik() (la
# cinematica inversa: il piede a terra resta fermo mentre il corpo avanza)
import math

L1, L2 = 18.0, 12.4          # coscia, stinco
ALTO_PIEDE = 7.0             # dalla caviglia a terra, col piede piatto (il tacco)

# il piede, in coordinate del piede: x avanti, y giu', la caviglia in (0, 0);
# piatto per terra la suola e la punta del tacco sono a y = 7
PIEDE = [(-2.4, -1.5), (2.3, -1.5), (3.0, 1.0), (5.2, 3.3), (8.2, 4.6), (9.6, 5.6),
         (9.6, 7.0), (4.6, 7.0), (2.4, 5.9), (0.2, 4.4), (-2.4, 4.0)]
TACCO = [(-2.4, 3.0), (-0.6, 3.0), (-0.9, 7.0), (-2.2, 7.0)]
PALLA = (6.0, 7.0)           # il punto della suola che resta a terra quando il tallone e' alzato
COLLO = [(2.3, -1.5), (3.0, 1.0), (5.2, 3.3), (8.2, 4.6)]   # il dorso, dove batte la luce


def ruota(p, a):
    c, s = math.cos(a), math.sin(a)
    return (p[0] * c - p[1] * s, p[0] * s + p[1] * c)


def dentro(px, py, poli):
    ins = False
    n = len(poli)
    for i in range(n):
        x1, y1 = poli[i]
        x2, y2 = poli[(i + 1) % n]
        if (y1 > py) != (y2 > py):
            xi = x1 + (py - y1) * (x2 - x1) / (y2 - y1)
            if px < xi:
                ins = not ins
    return ins


def dist_spezzata(px, py, pts):
    best = 1e9
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        dx, dy = bx - ax, by - ay
        t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)))
        best = min(best, math.hypot(px - ax - t * dx, py - ay - t * dy))
    return best


def segmento(px, py, ax, ay, bx, by):
    """(t non tagliato, t tagliato, distanza, distanza con segno: + il davanti)"""
    dx, dy = bx - ax, by - ay
    L2_ = dx * dx + dy * dy
    t = ((px - ax) * dx + (py - ay) * dy) / L2_
    tc = max(0.0, min(1.0, t))
    qx, qy = ax + tc * dx, ay + tc * dy
    L = math.sqrt(L2_)
    nx, ny = dy / L, -dx / L
    return t, tc, math.hypot(px - qx, py - qy), (px - qx) * nx + (py - qy) * ny


def ik(anca, caviglia):
    """il ginocchio, piegato in avanti"""
    hx, hy = anca
    dx, dy = caviglia[0] - hx, caviglia[1] - hy
    d = min(math.hypot(dx, dy), L1 + L2 - 1e-3)
    base = math.atan2(dx, dy)
    c = (L1 * L1 + d * d - L2 * L2) / (2 * L1 * d)
    a = math.acos(max(-1.0, min(1.0, c)))
    th = base + a
    return hx + L1 * math.sin(th), hy + L1 * math.cos(th)


def caviglia_da_palla(palla, beccheggio):
    """col tallone alzato di `beccheggio` gradi e la palla del piede in `palla`"""
    r = ruota(PALLA, math.radians(beccheggio))
    return palla[0] - r[0], palla[1] - r[1]


def piega(p, b, dita):
    """un punto del piede col tallone alzato di b (radianti): con `dita` le dita
    (davanti alla palla) restano piatte per terra, il piede si piega li'"""
    if dita and p[0] > PALLA[0]:
        bx, by = ruota(PALLA, b)
        return bx + p[0] - PALLA[0], by + p[1] - PALLA[1]
    return ruota(p, b)


def gamba(anca, caviglia, beccheggio=0.0, vicina=True, stivale=0.55, dita=False):
    """{(x, y): lettera} senza contorno; dita: il piede sulla punta, le dita
    piatte per terra"""
    hx, hy = anca
    ax, ay = caviglia
    kx, ky = ik(anca, caviglia)
    a1 = math.atan2(kx - hx, ky - hy)
    b = math.radians(beccheggio)
    piede = [(ax + x, ay + y) for x, y in (piega(p, b, dita) for p in PIEDE)]
    tacco = [(ax + x, ay + y) for x, y in (piega(p, b, dita) for p in TACCO)]
    collo = [(ax + x, ay + y) for x, y in (piega(p, b, dita) for p in COLLO)]
    pix = {}
    xs = [hx, kx, ax] + [p[0] for p in piede]
    ys = [hy, ky, ay] + [p[1] for p in piede]
    for y in range(int(min(ys)) - 6, int(max(ys)) + 7):
        for x in range(int(min(xs)) - 6, int(max(xs)) + 7):
            cx, cy = x + 0.5, y + 0.5
            t1, c1, d1, s1 = segmento(cx, cy, hx, hy, kx, ky)
            t2, c2, d2, s2 = segmento(cx, cy, kx, ky, ax, ay)
            r1 = 4.4 - 0.9 * c1
            r2 = 3.5 + 0.3 * math.sin(math.pi * min(1.0, c2 / 0.6)) - 1.4 * max(0.0, (c2 - 0.4) / 0.6)
            in1 = d1 <= r1 and t1 >= -0.1
            in2 = d2 <= r2
            nel_piede = dentro(cx, cy, piede)
            nel_tacco = dentro(cx, cy, tacco)
            if not (in1 or in2 or nel_piede or nel_tacco):
                continue
            if nel_tacco and not (in2 or nel_piede):
                ch = 'n'
            elif nel_piede and not in2 or (nel_piede and c2 > 0.95):
                # il piede: il dorso alla luce, il resto scuro
                dd = dist_spezzata(cx, cy, collo)
                ch = 'n'
                if dd < 1.3:
                    ch = 'm' if vicina else 'n'
                if vicina and 0.5 < dd < 1.2 and cx > ax + 2.5:
                    ch = 'k'
            else:
                if in2 and (not in1 or d2 / r2 < d1 / r1):
                    t, s = c2, s2 / r2
                    pezzo = 'stinco'
                else:
                    t, s = c1, s1 / r1
                    pezzo = 'coscia'
                if pezzo == 'coscia' and t < stivale:
                    if vicina:
                        ch = 'Q' if s < -0.35 else ('R' if s < 0.45 else 'S')
                    else:
                        ch = 'R' if s < -0.35 else ('S' if s < 0.45 else 'T')
                    if abs(t - stivale) * L1 < 0.9:
                        ch = 'o'
                else:
                    if vicina:
                        ch = 'n'
                        if s < -0.3: ch = 'm'
                        if -0.78 < s < -0.42: ch = 'k'
                        if s > 0.82: ch = 'm'
                    else:
                        ch = 'n'
                        if -0.78 < s < -0.42: ch = 'm'
            pix[(x, y)] = ch
    if vicina:
        # il ginocchio lucido: un pixel chiaro sul dietro del ginocchio
        nx, ny = math.cos(a1), -math.sin(a1)
        gx, gy = kx - 1.8 * nx, ky - 1.8 * ny
        if (int(gx), int(gy)) in pix and pix[(int(gx), int(gy))] in 'mk':
            pix[(int(gx), int(gy))] = 'w'
    return pix


def contorno(pix):
    """il contorno di un pixel attorno (4 vicini), come lettere 'o'"""
    out = dict(pix)
    for (x, y) in pix:
        for u, v in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if (u, v) not in pix:
                out[(u, v)] = 'o'
    return out
