# Le Pianure di Redenna composte coi pezzi della libreria
# (art/livelli/oggetti/, scritta da strumenti/livelli/oggetti.py).
#
#   python3 strumenti/livelli/compone.py
#
# Bru: «vorrei che i disegni fossero creati pixel per pixel non usando un
# immagine ma proprio oggetti disegnati in pixel che poi vengono riutilizzati
# nelle mappe».
#
# Il disegno di Bru (strumenti/livelli/fogli/pianure.png) resta la guida di
# dove stanno le cose, ma nella mappa non ne entra nemmeno un pixel:
#   1. le classi del terreno: ogni pixel del disegno diventa erba, sentiero,
#      acqua, rovi (la zona corrotta), parete, alberi o lastre, dal colore
#      (le pareti di Bru sono grigie e a fenditure verticali); poi si
#      lisciano (ogni pixel prende la classe piu' comune intorno), via le
#      macchie piccole, e la pianta corregge: dove si cammina non ci sono ne'
#      pareti ne' acqua ne' alberi. Sul promontorio le pareti sono ricalcate
#      a mano (PARETI);
#   2. il terreno, alla misura del mondo (un pixel della mappa e' un pixel del
#      mondo, come i pezzi e come lei): le trame della libreria (l'erba, la
#      sabbia, l'acqua, i rovi) e i bordi disegnati pixel per pixel (la riva,
#      il ciglio del sentiero, l'orlo e l'ombra delle pareti);
#   3. le pareti: la faccia di due rupi della libreria, ripetuta in
#      larghezza e allungata in altezza; dove l'acqua scende da una parete,
#      la cascata; le scale (gradino per gradino) dove la pianta dice che si
#      passa, e il ponticello (asse per asse);
#   4. le cose: quelle messe a mano dove le aveva disegnate Bru (A_MANO) e
#      quelle seminate (gli alberi nei boschi, le canne nella palude, gli
#      alberi secchi e i rovi nella zona corrotta, i cespugli e i sassi sul
#      prato). Quelle piatte (il cratere, i sassi) vanno nel terreno; quelle
#      che stanno in piedi diventano pezzi a parte, che il gioco mette in
#      ordine di piede con lei (chi ha il piede piu' in basso sta davanti).
#
# Scrive art/livelli/pianure.png (il terreno), pianure_pezzi.json (le cose in
# piedi: file, piede) e pianure_passi.png (dove si cammina: il pavimento della
# pianta meno gli ostacoli, l'acqua, le pareti e i piedi delle cose, piu' le
# scale e il ponticello).
import json
import math
import os
import random
import struct
import sys
import zlib
from array import array
from collections import deque

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(QUI, '..', 'protagonisti'))
import png  # noqa: E402

ARTE = os.path.join(QUI, '..', '..', 'art', 'livelli')
OGGETTI = os.path.join(ARTE, 'oggetti')

ERBA, SENTIERO, ACQUA, ROVI, PARETE, ALBERI, LASTRE = range(7)
CLASSI = 7


def esa(s):
    return (int(s[1:3], 16), int(s[3:5], 16), int(s[5:7], 16))


# ---------------------------------------------------------------- 1. le classi

def parete_grezza(r, g, b, gx, gy):
    """le pareti di Bru sono grigie (ne' verdi come le canne, ne' rosa come i
    rovi) e a fenditure verticali: la luminanza cambia molto piu' in
    orizzontale (gx) che in verticale (gy). La nebbia e l'erba no"""
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    return max(r, g, b) - min(r, g, b) < 34 and 70 < lum < 190 and gx > 9 and gx > 1.35 * gy \
        and g - r < 12 and r - g < 10 and b >= r - 8


def classe_del_colore(r, g, b):
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    sat = max(r, g, b) - min(r, g, b)
    if b > r + 8 and g - b < 10 and 85 < lum < 175:
        return ACQUA
    if r > g + 8:
        return ROVI
    if lum < 100 and g > r + 4:
        return ALBERI
    # il sentiero e' chiaro e quasi grigio (rosso quasi quanto il verde); la
    # nebbia sul prato, chiara uguale, resta verdina
    if lum > 168 and sat < 22 and r >= g - 8:
        return SENTIERO
    return ERBA


def media(d, w, h, r):
    """la media di d nel quadrato di lato 2r+1 intorno a ogni pixel"""
    s = array('d', [0.0]) * ((w + 1) * (h + 1))
    for y in range(h):
        rs = 0.0
        b, a = (y + 1) * (w + 1), y * (w + 1)
        for x in range(w):
            rs += d[y * w + x]
            s[b + x + 1] = s[a + x + 1] + rs
    out = array('d', [0.0]) * (w * h)
    for y in range(h):
        y0, y1 = max(0, y - r), min(h, y + r + 1)
        a0, a1 = y0 * (w + 1), y1 * (w + 1)
        for x in range(w):
            x0, x1 = max(0, x - r), min(w, x + r + 1)
            out[y * w + x] = (s[a1 + x1] - s[a0 + x1] - s[a1 + x0] + s[a0 + x0]) / ((x1 - x0) * (y1 - y0))
    return out


def gradienti(lum, w, h, r):
    """quanto cambia la luminanza da un pixel a quello accanto, in
    orizzontale e in verticale, nella media dei dintorni"""
    dx = array('d', [0.0]) * (w * h)
    dy = array('d', [0.0]) * (w * h)
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            i = y * w + x
            dx[i] = abs(lum[i + 1] - lum[i - 1])
            dy[i] = abs(lum[i + w] - lum[i - w])
    return media(dx, w, h, r), media(dy, w, h, r)


def moda(c, w, h, r, volte):
    """ogni pixel di bordo prende la classe piu' comune nel quadrato 2r+1"""
    for _ in range(volte):
        nuovo = bytearray(c)
        for y in range(h):
            for x in range(w):
                i = y * w + x
                k = c[i]
                if (x > 0 and c[i - 1] != k) or (x < w - 1 and c[i + 1] != k) \
                        or (y > 0 and c[i - w] != k) or (y < h - 1 and c[i + w] != k):
                    conta = [0] * CLASSI
                    for yy in range(max(0, y - r), min(h, y + r + 1)):
                        b = yy * w
                        for xx in range(max(0, x - r), min(w, x + r + 1)):
                            conta[c[b + xx]] += 1
                    meglio = max(range(CLASSI), key=conta.__getitem__)
                    if conta[meglio] > conta[k]:
                        nuovo[i] = meglio
        c = nuovo
    return c


def via_le_macchie(c, w, h, minimo):
    """le macchie piu' piccole di minimo pixel prendono la classe che le
    circonda"""
    gruppo = array('i', [-1]) * (w * h)
    c = bytearray(c)
    for i0 in range(w * h):
        if gruppo[i0] >= 0:
            continue
        k = c[i0]
        gruppo[i0] = i0
        celle = [i0]
        coda = deque([i0])
        intorno = [0] * CLASSI
        while coda:
            i = coda.popleft()
            x, y = i % w, i // w
            for j, ok in ((i - 1, x > 0), (i + 1, x < w - 1), (i - w, y > 0), (i + w, y < h - 1)):
                if not ok:
                    continue
                if c[j] == k:
                    if gruppo[j] < 0:
                        gruppo[j] = i0
                        celle.append(j)
                        coda.append(j)
                else:
                    intorno[c[j]] += 1
        if len(celle) < minimo and sum(intorno):
            nuova = max(range(CLASSI), key=intorno.__getitem__)
            for i in celle:
                c[i] = nuova
    return c


def allarga(m, w, h, rx, ry, valore):
    """m (0/1): ogni pixel diventa valore se ce n'e' uno con valore nel
    rettangolo di raggio rx, ry (dilatazione, o erosione con valore 0)"""
    # prima in orizzontale, poi in verticale (il rettangolo si separa)
    t = bytearray(m)
    if rx:
        for y in range(h):
            b = y * w
            riga = m[b:b + w]
            for x in range(w):
                if riga[x] != valore and valore in riga[max(0, x - rx):x + rx + 1]:
                    t[b + x] = valore
    out = bytearray(t)
    if ry:
        for x in range(w):
            col = t[x::w]
            for y in range(h):
                if col[y] != valore and valore in col[max(0, y - ry):y + ry + 1]:
                    out[y * w + x] = valore
    return out


def regola_le_pareti(m, w, h):
    """m: 1 dove e' parete. Via le gocce strette (apertura in orizzontale),
    chiusi i buchi (chiusura), via i pezzi piccoli, e gli orli di cima e di
    fondo lisciati colonna per colonna"""
    m = allarga(allarga(m, w, h, 3, 0, 0), w, h, 3, 0, 1)
    m = allarga(allarga(m, w, h, 4, 2, 1), w, h, 4, 2, 0)
    c = via_le_macchie(bytearray(PARETE if v else ERBA for v in m), w, h, 150)
    m = bytearray(1 if v == PARETE else 0 for v in c)
    # le strisce di ogni colonna; ogni orlo prende la media degli orli
    # delle strisce che si toccano nelle colonne vicine
    strisce = []
    for x in range(w):
        col = m[x::w]
        s, y = [], 0
        while y < h:
            if col[y]:
                y0 = y
                while y < h and col[y]:
                    y += 1
                s.append((y0, y))
            else:
                y += 1
        strisce.append(s)

    # via le strisce di una colonna sola (senza vicine che le tocchino)
    def tocca(xx, y0, y1):
        return 0 <= xx < w and any(a < y1 and b > y0 for a, b in strisce[xx])
    strisce = [[(a, b) for a, b in strisce[x] if tocca(x - 1, a, b) or tocca(x + 1, a, b)] for x in range(w)]
    R = 9
    for _ in range(2):
        nuove = []
        for x in range(w):
            col = []
            for y0, y1 in strisce[x]:
                cime, fondi = [], []
                for xx in range(max(0, x - R), min(w, x + R + 1)):
                    for a, b in strisce[xx]:
                        if a < y1 and b > y0:
                            cime.append(a)
                            fondi.append(b)
                col.append((int(round(sum(cime) / len(cime))), int(round(sum(fondi) / len(fondi)))))
            nuove.append(col)
        strisce = nuove
    out = bytearray(w * h)
    for x in range(w):
        for a, b in strisce[x]:
            for y in range(a, b):
                out[y * w + x] = 1
    return out


def dentro_forma(f, scala):
    """-> funzione (x, y) -> bool, in pixel della griglia (unita' * scala)"""
    if f and isinstance(f[0], list):
        pts = [(p[0] * scala, p[1] * scala) for p in f]

        def dentro(x, y):
            d = False
            j = len(pts) - 1
            for i in range(len(pts)):
                xi, yi = pts[i]
                xj, yj = pts[j]
                if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
                    d = not d
                j = i
            return d
        return dentro
    x0, y0, x1, y1 = (v * scala for v in f)
    return lambda x, y: x0 <= x < x1 and y0 <= y < y1


def riempi(maschera, w, h, f, scala, valore=1):
    """segna i pixel della griglia (unita' * scala) col centro dentro la forma
    f, rettangolo o poligono in unita' della pianta: riga per riga, fra un
    taglio e l'altro dei lati"""
    if not (f and isinstance(f[0], list)):
        x0, y0, x1, y1 = (v * scala for v in f)
        for y in range(max(0, int(math.ceil(y0 - 0.5))), min(h, int(math.ceil(y1 - 0.5)))):
            a, b = max(0, int(math.ceil(x0 - 0.5))), min(w, int(math.ceil(x1 - 0.5)))
            if b > a:
                maschera[y * w + a:y * w + b] = bytes([valore]) * (b - a)
        return
    pts = [(p[0] * scala, p[1] * scala) for p in f]
    ys = [p[1] for p in pts]
    for y in range(max(0, int(min(ys))), min(h, int(math.ceil(max(ys))) + 1)):
        cy = y + 0.5
        tagli = []
        for k in range(len(pts)):
            (ax, ay), (bx, by) = pts[k], pts[k - 1]
            if (ay <= cy < by) or (by <= cy < ay):
                tagli.append(ax + (cy - ay) * (bx - ax) / (by - ay))
        tagli.sort()
        for xa, xb in zip(tagli[0::2], tagli[1::2]):
            a, b = max(0, int(math.ceil(xa - 0.5))), min(w, int(math.ceil(xb - 0.5)))
            if b > a:
                maschera[y * w + a:y * w + b] = bytes([valore]) * (b - a)


def classi(pianta, guida):
    w, h, pix = png.leggi(guida)
    lum = array('d', (0.299 * r + 0.587 * g + 0.114 * b for r, g, b, _a in pix))
    gx, gy = gradienti(lum, w, h, 2)
    # una parete e' dove almeno un terzo dei pixel intorno sono da parete
    grezza = array('d', (1.0 if parete_grezza(p[0], p[1], p[2], gx[i], gy[i]) else 0.0 for i, p in enumerate(pix)))
    fitta = media(grezza, w, h, 3)
    parete = regola_le_pareti(bytearray(1 if v > 0.35 else 0 for v in fitta), w, h)
    c = bytearray(classe_del_colore(p[0], p[1], p[2]) for p in pix)
    # gli alberi come le pareti: fra una chioma e l'altra c'e' ombra blu e
    # prato, ma un bosco e' un bosco
    bosco = media(array('d', (1.0 if k == ALBERI else 0.0 for k in c)), w, h, 3)
    for i in range(w * h):
        if bosco[i] > 0.4:
            c[i] = ALBERI
    # le correzioni a mano, prima di lisciare
    for k, f in CORREZIONI:
        riempi(c, w, h, f, 1, k)
    c = moda(c, w, h, 2, 3)
    c = via_le_macchie(c, w, h, 80)
    # il promontorio: le pareti sono quelle ricalcate a mano
    a_mano = bytearray(w * h)
    riempi(a_mano, w, h, PROMONTORIO, 1)
    dentro_una_faccia = bytearray(w * h)
    for f in PARETI:
        riempi(dentro_una_faccia, w, h, faccia(f), 1)
        riempi(parete, w, h, faccia(f), 1)
    for i in range(w * h):
        if a_mano[i] and c[i] in (PARETE, ACQUA):
            c[i] = ERBA
        if parete[i] and not (a_mano[i] and not dentro_una_faccia[i]):
            c[i] = PARETE
    # dove si cammina: niente pareti, acqua o alberi (fuori dagli ostacoli,
    # che sono anche i laghetti); le scale e il ponte sono pareti e acqua,
    # ma si passa
    cammina = bytearray(w * h)
    for f in pianta["pavimento"]:
        riempi(cammina, w, h, f, 1)
    for f in pianta["ostacoli"] + pianta["si_passa"]:
        riempi(cammina, w, h, f, 1, 0)
    for i in range(w * h):
        if cammina[i] and c[i] in (PARETE, ACQUA, ALBERI):
            c[i] = ERBA
    for k, f in DOPO:
        riempi(c, w, h, f, 1, k)
    prima = c
    c = moda(c, w, h, 1, 1)
    for i in range(w * h):
        if (prima[i] == PARETE) != (c[i] == PARETE):
            c[i] = prima[i]
    return w, h, c, cammina


def faccia(cima):
    """una parete dai punti del suo orlo di cima, ognuno con la sua altezza:
    [(x, y, alta), ...] -> il poligono. Fra un punto e l'altro, ogni 4 unita',
    l'orlo e il piede si muovono un poco (sempre uguale: il caso ha il seme
    nel punto), come le rupi disegnate"""
    sopra, sotto = [], []
    for (xa, ya, aa), (xb, yb, ab) in zip(cima, cima[1:]):
        n = max(1, int(math.hypot(xb - xa, yb - ya) // 4))
        for k in range(n):
            t = k / n
            x, y, a = xa + (xb - xa) * t, ya + (yb - ya) * t, aa + (ab - aa) * t
            caso = random.Random(int(x) * 7919 + int(y))
            su = caso.choice((-1.5, -1, -0.5, 0, 0, 0.5, 1))
            sopra.append([x, y + su])
            sotto.append([x, y + a + caso.choice((-1.5, -0.5, 0, 0.5, 1, 2))])
    x, y, a = cima[-1]
    sopra.append([x, y])
    sotto.append([x, y + a])
    return sopra + sotto[::-1]


# Il promontorio a mano: li' le pareti di Bru sono tante e intrecciate (tre
# ripiani, le scale in diagonale, la nebbia sopra) e riconoscerle dal colore
# viene a pezzi. Dentro PROMONTORIO valgono solo queste, ricalcate sul
# disegno: l'orlo di cima, punto per punto, con l'altezza della parete li'
PROMONTORIO = [[690, 0], [1336, 0], [1336, 548], [975, 548], [975, 300], [690, 280]]
PARETI = (
    # la sporgenza e, sotto la cima, la parete lunga fino al prato
    [(700, 212, 56), (708, 230, 38), (760, 231, 37), (820, 229, 40), (900, 229, 42), (977, 231, 41)],
    # la cima, sopra
    [(818, 178, 51), (840, 171, 58), (900, 169, 60), (923, 163, 66), (935, 155, 74), (950, 143, 86),
     (967, 124, 105), (1000, 122, 108)],
    # il fianco ovest della cima, accanto alla scala alta
    [(784, 40, 12), (790, 60, 30), (796, 100, 40), (802, 130, 40)],
    # il muro ovest del promontorio di destra
    [(1000, 122, 200), (1012, 112, 260), (1024, 104, 330), (1038, 96, 370)],
    # il ripiano in alto a destra
    [(1038, 96, 140), (1060, 135, 103), (1100, 158, 80), (1140, 168, 66), (1220, 170, 64), (1300, 170, 62),
     (1314, 150, 84), (1336, 140, 94)],
    # il secondo ripiano: a sinistra e a destra della scala
    [(1040, 300, 70), (1090, 298, 75), (1130, 300, 72)],
    [(1140, 268, 130), (1180, 268, 126), (1250, 266, 128), (1300, 262, 134), (1336, 250, 150)],
    # il terzo ripiano, sotto la scala
    [(1030, 397, 50), (1100, 397, 52), (1150, 398, 50)],
    # il ripiano basso, fino al prato e al bosco
    [(985, 470, 68), (1050, 470, 64), (1100, 468, 68), (1160, 468, 70), (1215, 470, 62)],
    [(1215, 470, 20), (1250, 440, 40), (1272, 412, 52), (1336, 408, 52)],
)
# le scale del promontorio di destra (non ci si va: sono il paesaggio)
SCALE_DECORO = (
    [[1088, 150], [1104, 142], [1142, 262], [1126, 270]],
    [[1146, 292], [1162, 286], [1190, 396], [1174, 402]],
    [1050, 472, 1078, 536],
)


# le correzioni a mano (unita' della pianta). Prima di lisciare: il riquadro
# della caverna che Bru aveva disegnato sopra la mappa (sotto c'erano il prato
# e una pozza). Dopo: la siepe di rovi che chiude la scorciatoia dal bivio
# all'arena (al boss si arriva solo dalla scala della rupe, dopo la
# tartaruga, o dal promontorio); l'arena lastricata in cima alla zona
# corrotta; il cratere e la capsula, che sono pezzi, su un fondo di pietra e
# di prato; l'isola del grande albero, che e' un pezzo anche lui
CORREZIONI = (
    (ERBA, [544, 395, 634, 476]),
    (ACQUA, [[548, 440], [600, 446], [634, 470], [634, 478], [548, 478]]),
)
DOPO = (
    (ROVI, [[541, 156], [704, 156], [704, 190], [690, 196], [668, 192], [646, 197], [622, 193], [598, 198],
            [574, 194], [552, 198], [541, 195]]),
    (LASTRE, [[636, 30], [700, 30], [704, 70], [682, 84], [680, 160], [658, 160], [656, 84], [634, 70]]),
    (SENTIERO, [[770, 350], [790, 332], [830, 324], [866, 332], [888, 360], [894, 400], [886, 430], [850, 440],
                [790, 438], [766, 420], [760, 390]]),
    (ERBA, [650, 738, 690, 778]),
    (ERBA, [[606, 336], [700, 326], [748, 360], [748, 470], [700, 492], [640, 492], [606, 440]]),
)


# ---------------------------------------------------------------- 2. il terreno

def a_misura_del_mondo(c, w, h, k):
    """la mappa delle classi ingrandita k volte, e poi lisciata ai bordi: gli
    scalini di k pixel diventano curve di pixel singoli"""
    out = bytearray(w * k * h * k)
    for y in range(h):
        riga = bytes(v for v in c[y * w:(y + 1) * w] for _ in range(k))
        for j in range(k):
            out[(y * k + j) * w * k:(y * k + j + 1) * w * k] = riga
    return moda(out, w * k, h * k, 1, 2)


def leggi_pezzo(file):
    w, h, pix = png.leggi(os.path.join(OGGETTI, file) if not os.path.isabs(file) else file)
    return w, h, pix


def ritaglia(t, x0, y0, x1, y1):
    w, _h, pix = t
    return x1 - x0, y1 - y0, [pix[y * w + x] for y in range(y0, y1) for x in range(x0, x1)]


def affianca(a, b):
    """due trame alte uguali, una accanto all'altra"""
    aw, ah, ap = a
    bw, bh, bp = b
    assert ah == bh, (ah, bh)
    return aw + bw, ah, [p for y in range(ah) for p in ap[y * aw:(y + 1) * aw] + bp[y * bw:(y + 1) * bw]]


def specchio(v, n):
    """la trama ripetuta a specchio: niente cuciture"""
    v %= 2 * n
    return v if v < n else 2 * n - 1 - v


def rumore(w, h, cella, seme):
    """rumore liscio in [0, 1]: valori a caso su una griglia, interpolati"""
    caso = random.Random(seme)
    gw, gh = w // cella + 2, h // cella + 2
    griglia = [[caso.random() for _ in range(gw)] for _ in range(gh)]
    out = array('f', [0.0]) * (w * h)
    liscia = [((i + 0.5) / cella) for i in range(cella)]
    liscia = [t * t * (3 - 2 * t) for t in liscia]
    for y in range(h):
        j, fy = y // cella, liscia[y % cella]
        a, b = griglia[j], griglia[j + 1]
        riga = [a[i] + (b[i] - a[i]) * fy for i in range(gw)]
        base = y * w
        for x in range(w):
            i = x // cella
            fx = liscia[x % cella]
            out[base + x] = riga[i] + (riga[i + 1] - riga[i]) * fx
    return out


def piu_scuro(c, quanto=0.72):
    return tuple(int(v * quanto) for v in c[:3])


# i colori disegnati a mano, fuori dalle trame
RIVA_SCURA = esa('#2c343d')       # il filo scuro sotto la sponda
ACQUA_OMBRA = esa('#415d70')      # l'acqua all'ombra della sponda
SCHIUMA = esa('#9abcc9')          # il filo chiaro dove l'acqua tocca terra
SCHIUMA_CASCATA = esa('#c6e9eb')
ORLO = esa('#d9d3b2')             # l'orlo chiaro in cima alle pareti
ORLO_OMBRA = esa('#afaf9a')
PARETE_CONTORNO = esa('#3e4a54')
SABBIA_OMBRA = esa('#bab8a2')
SABBIA_ORLO = esa('#c5c6b0')
ERBA_CIGLIO = esa('#5a7f56')
ERBA_SCURA = esa('#6a8b63')
PRUGNA = [esa(v) for v in ('#5a2f47', '#733d58', '#8e4d6b', '#a8607e')]
LASTRE_COLORI = [esa(v) for v in ('#8f6a3e', '#b8915a', '#c9a46a', '#dcbc84')]


def terreno(K, W, H):
    """i colori del terreno, classe per classe, con le trame della libreria:
    l'erba, l'acqua e i rovi ripetuti dritti (sono grana, e a specchio
    venivano macchie simmetriche), la sabbia a specchio (e' una striscia di
    sentiero, coi bordi)"""
    liscia = leggi_pezzo('terreno/erba_liscia.png')
    fitta = leggi_pezzo('terreno/erba_fitta.png')
    fiori = leggi_pezzo('terreno/erba_fiorellini.png')
    sabbia = leggi_pezzo('terreno/sabbia.png')
    sabbia = ritaglia(sabbia, 6, 0, sabbia[0] - 6, sabbia[1])
    acqua = leggi_pezzo('terreno/acqua.png')
    rovi = leggi_pezzo('terreno/rovi_fitti.png')
    prato = liscia[2][(liscia[1] // 2) * liscia[0] + liscia[0] // 2][:3]
    # i rovi per terra: l'erba fitta, coi colori della prugna (dal piu' scuro
    # al piu' chiaro, come l'erba)
    toni = sorted(set(p[:3] for p in fitta[2]), key=lambda c: c[0] * 0.3 + c[1] * 0.59 + c[2] * 0.11)
    a_prugna = {c: PRUGNA[min(3, i * 4 // len(toni))] for i, c in enumerate(toni)}
    n1 = rumore(W, H, 40, 1)
    n2 = rumore(W, H, 24, 2)
    out = bytearray(W * H * 3)
    for y in range(H):
        for x in range(W):
            i = y * W + x
            k = K[i]
            if k == ERBA or k == ALBERI:
                v = n1[i]
                if v > 0.6 or (v > 0.54 and (x + y) & 1):
                    c = fitta[2][(y % fitta[1]) * fitta[0] + x % fitta[0]]
                elif n2[i] > 0.78:
                    c = fiori[2][(y % fiori[1]) * fiori[0] + x % fiori[0]]
                else:
                    c = prato
            elif k == SENTIERO:
                c = sabbia[2][specchio(y, sabbia[1]) * sabbia[0] + specchio(x, sabbia[0])]
            elif k == ACQUA:
                c = acqua[2][(y % acqua[1]) * acqua[0] + x % acqua[0]]
            elif k == ROVI:
                v = n1[i]
                if v > 0.68 or (v > 0.63 and (x + y) & 1):
                    c = rovi[2][(y % rovi[1]) * rovi[0] + x % rovi[0]]
                else:
                    c = a_prugna[fitta[2][(y % fitta[1]) * fitta[0] + x % fitta[0]][:3]]
            elif k == LASTRE:
                # pietre di 12x8, a file sfalsate, con la luce in alto a sinistra
                fila = y // 8
                xx = x + (6 if fila & 1 else 0)
                u, v = xx % 12, y % 8
                if u == 0 or v == 0:
                    c = LASTRE_COLORI[0]
                elif u == 1 or v == 1:
                    c = LASTRE_COLORI[3]
                else:
                    c = LASTRE_COLORI[1 + ((xx // 12 + fila) * 7 % 3 == 0)]
            else:
                c = prato
            out[3 * i:3 * i + 3] = bytes(c[:3])
    return out


def bordi(K, W, H, out):
    """i bordi fra una classe e l'altra, pixel per pixel"""
    def metti(i, c):
        out[3 * i:3 * i + 3] = bytes(c[:3])
    for y in range(1, H - 1):
        for x in range(1, W - 1):
            i = y * W + x
            k = K[i]
            su, giu, sx, dx = K[i - W], K[i + W], K[i - 1], K[i + 1]
            if k == ACQUA:
                if su != ACQUA and su != PARETE:
                    metti(i, RIVA_SCURA)
                elif K[i - 2 * W] != ACQUA and K[i - 2 * W] != PARETE or y > 2 and K[i - 3 * W] not in (ACQUA, PARETE):
                    metti(i, ACQUA_OMBRA)
                elif giu != ACQUA or sx != ACQUA or dx != ACQUA:
                    metti(i, SCHIUMA)
            elif k == SENTIERO:
                if su in (ERBA, ALBERI, ROVI):
                    metti(i, SABBIA_OMBRA)
                elif K[i - 2 * W] in (ERBA, ALBERI, ROVI) or sx in (ERBA, ALBERI) or dx in (ERBA, ALBERI):
                    metti(i, SABBIA_ORLO)
            elif k in (ERBA, ALBERI):
                if giu == SENTIERO or giu == ACQUA:
                    metti(i, ERBA_CIGLIO)
                elif sx == SENTIERO or dx == SENTIERO or su == SENTIERO:
                    metti(i, ERBA_SCURA)
                elif (sx == ROVI or dx == ROVI or su == ROVI or giu == ROVI) and (x + y) & 1:
                    metti(i, PRUGNA[2])
            elif k == ROVI:
                if (sx in (ERBA, ALBERI) or dx in (ERBA, ALBERI) or su in (ERBA, ALBERI)
                        or giu in (ERBA, ALBERI)) and (x + y) & 1:
                    metti(i, out[3 * (i - 1):3 * (i - 1) + 3] if sx in (ERBA, ALBERI) else ERBA_SCURA)


def pareti(K, W, H, out, scale, ponti):
    """le pareti, colonna per colonna: l'orlo chiaro in cima, la faccia di
    rupe_1 e rupe_2 una accanto all'altra (ripetute a specchio in larghezza,
    allungate ripetendo le file di mezzo), il contorno scuro in fondo e l'ombra per terra. Dove sopra c'e'
    acqua, la cascata"""
    rupe = affianca(ritaglia(leggi_pezzo('rupi/rupe_1.png'), 6, 10, 70, 57),
                    ritaglia(leggi_pezzo('rupi/rupe_2.png'), 6, 12, 60, 59))
    cascata = leggi_pezzo('acqua/cascata_4.png')
    cascata = ritaglia(cascata, 4, 2, cascata[0] - 4, cascata[1] - 6)
    tw, th, tp = rupe
    cw, ch, cp = cascata
    SOTTO = 8                       # le ultime file della rupe: la base
    MEZZO0, MEZZO1 = 6, th - SOTTO  # le file che si ripetono

    def metti(i, c):
        out[3 * i:3 * i + 3] = bytes(c[:3])
    for x in range(W):
        y = 0
        while y < H:
            if K[y * W + x] != PARETE:
                y += 1
                continue
            y0 = y
            while y < H and K[y * W + x] == PARETE:
                y += 1
            y1 = y
            n = y1 - y0
            sopra = K[(y0 - 1) * W + x] if y0 > 0 else PARETE
            cade = sopra == ACQUA
            if y0 > 0 and not cade and sopra != PARETE:
                metti((y0 - 1) * W + x, ORLO)
                if y0 > 1 and K[(y0 - 2) * W + x] != PARETE:
                    metti((y0 - 2) * W + x, ORLO_OMBRA if K[(y0 - 2) * W + x] != SENTIERO else ORLO)
            for yy in range(y0, y1):
                r = yy - y0
                i = yy * W + x
                if cade:
                    c = cp[specchio(r, ch) * cw + specchio(x, cw)]
                else:
                    # le file di mezzo si ripetono, ogni volta spostate di
                    # lato: niente griglia
                    giro = 0
                    if r >= n - SOTTO:
                        ty = th - (n - r)
                    elif r < MEZZO1:
                        ty = r
                    else:
                        giro = 1 + (r - MEZZO1) // (MEZZO1 - MEZZO0)
                        ty = MEZZO0 + (r - MEZZO1) % (MEZZO1 - MEZZO0)
                    c = tp[max(0, ty) * tw + specchio(x + giro * 41, tw)]
                    if (K[i - 1] != PARETE and x > 0) or (x < W - 1 and K[i + 1] != PARETE) or yy == y1 - 1:
                        c = PARETE_CONTORNO
                metti(i, c)
            # sotto: l'ombra per terra, o la schiuma dove cade l'acqua
            for d in range(3):
                yy = y1 + d
                if yy >= H:
                    break
                i = yy * W + x
                if K[i] == PARETE:
                    break
                if cade and K[i] == ACQUA:
                    metti(i, SCHIUMA_CASCATA if d < 2 else SCHIUMA)
                elif d < 2:
                    metti(i, piu_scuro(out[3 * i:3 * i + 3], 0.78 if d == 0 else 0.88))
    # le scale e i ponti, sopra le pareti
    for f in scale:
        dipingi_forma(out, W, H, f, gradino)
    for f in ponti:
        dipingi_forma(out, W, H, f, asse_del_ponte)


GRADINI = [esa(v) for v in ('#3e4a54', '#72797a', '#afaf9a', '#c5c6b0', '#d9d3b2')]


def gradino(x, y):
    """i gradini di pietra, alti 6: l'orlo chiaro in cima, la pedata,
    l'alzata in ombra; una crepa ogni tanto"""
    v = y % 6
    if v == 0:
        return GRADINI[4]
    if v in (1, 2):
        return GRADINI[3] if (x * 7 + (y // 6) * 13) % 23 else GRADINI[2]
    if v == 3:
        return GRADINI[2]
    return GRADINI[1] if v == 4 else GRADINI[0]


TAVOLE = [esa(v) for v in ('#3d2a1e', '#6b4a30', '#8a6440', '#a57c52')]


def asse_del_ponte(x, y):
    """le assi di legno del ponticello, di traverso, con la luce in alto"""
    v = y % 6
    if v == 0:
        return TAVOLE[0]
    if v == 1:
        return TAVOLE[3]
    return TAVOLE[2] if (x // 7 + y // 6) % 3 else TAVOLE[1]


def dipingi_forma(out, W, H, f, colore, scala=2):
    if f and isinstance(f[0], list):
        xs, ys = [p[0] * scala for p in f], [p[1] * scala for p in f]
    else:
        xs, ys = [f[0] * scala, f[2] * scala], [f[1] * scala, f[3] * scala]
    dentro = dentro_forma(f, scala)
    x0, x1 = max(0, int(min(xs))), min(W, int(math.ceil(max(xs))))
    y0, y1 = max(0, int(min(ys))), min(H, int(math.ceil(max(ys))))
    for y in range(y0, y1):
        for x in range(x0, x1):
            if dentro(x + 0.5, y + 0.5):
                i = y * W + x
                bordo = not (dentro(x - 0.5, y + 0.5) and dentro(x + 1.5, y + 0.5))
                out[3 * i:3 * i + 3] = bytes(PARETE_CONTORNO if bordo else colore(x - x0, y - y0)[:3])


# ---------------------------------------------------------------- 4. le cose

# Le cose messe a mano, dove le aveva disegnate Bru: (nome, x, y) col piede in
# unita' della pianta. "capsula" e' la capsula del gioco
# (art/pianeti/pianure/capsula.png), le altre sono della libreria
A_MANO = (
    # l'atterraggio
    ('capsula', 671, 760),
    # il recinto del pasto del goblin: i muretti, e i tre alberi sopra
    ('blocco', 764, 659), ('blocco', 784, 659), ('muro_rotto', 761, 682), ('blocco', 761, 700),
    ('blocco', 852, 659), ('muro_rotto', 863, 675), ('blocco', 863, 697), ('blocco', 842, 714), ('blocco', 862, 714),
    ('albero_2', 772, 634), ('pino_1', 798, 630), ('pino_2', 818, 628), ('pino_3', 840, 631),
    # il grande albero, con il bosco dietro
    ('albero_1', 640, 424), ('albero_3', 712, 414), ('pino_1', 676, 402), ('albero_grande_1', 676, 490),
    # il cratere col masso (piatto, nel terreno: sta in DIPINTI) e le rovine
    # sulla piattaforma
    ('colonna_rotta_1', 862, 346), ('blocco', 884, 372), ('muro_rotto', 876, 398), ('arco', 852, 442),
    # i pini sotto la sporgenza
    ('pino_2', 731, 281), ('pino_1', 715, 292), ('pino_3', 808, 292), ('pino_2', 792, 302),
    ('pino_1', 876, 280), ('pino_3', 860, 290), ('pino_2', 959, 308), ('pino_1', 943, 318),
    # la sporgenza: l'arco, il pino, la colonna
    ('arco', 762, 150), ('pino_3', 782, 163), ('colonna_rotta_1', 775, 226), ('blocco', 808, 222),
    # la cima
    ('colonna', 815, 84), ('colonnato', 877, 72), ('pino_1', 915, 96), ('pino_2', 940, 97),
    ('colonna_rotta_2', 873, 162), ('blocco', 903, 165), ('colonna', 933, 150), ('colonna_rotta_1', 950, 122),
    # il promontorio di destra (il paesaggio)
    ('colonnato', 1172, 58), ('blocco', 1123, 62), ('colonna', 1095, 93), ('colonna_caduta', 1100, 118),
    ('muro_rotto', 1133, 107), ('blocco', 1162, 80), ('colonna_rotta_1', 1222, 87), ('colonna', 1238, 110),
    ('colonna_rotta_2', 1205, 147), ('pino_1', 1070, 80), ('pino_2', 1095, 52), ('pino_3', 1267, 87),
    ('pino_1', 1250, 153), ('pino_2', 1268, 140), ('colonna_caduta', 1073, 310), ('colonna_caduta', 1212, 367),
    # l'altro recinto, a destra
    ('blocco', 1110, 625), ('muro_rotto', 1110, 652), ('blocco', 1112, 690), ('blocco', 1160, 622),
    ('blocco', 1180, 622), ('muro_rotto', 1216, 634), ('blocco', 1160, 702), ('blocco', 1200, 702),
    ('muro_rotto', 1218, 694),
    # la siepe di rovi sulla scorciatoia
    ('rovo_2', 556, 196), ('rovo_1', 584, 194), ('rovo_3', 612, 197), ('rovo_grande', 642, 196),
    ('rovo_2', 676, 195), ('rovo_1', 698, 190),
    # la zona corrotta: le colonne
    ('colonna_rotta_1', 576, 74), ('colonna_rotta_2', 604, 122), ('colonna', 80, 70), ('colonna_rotta_1', 270, 82),
    ('colonna_rotta_2', 305, 98), ('colonna', 440, 40), ('colonna_rotta_2', 632, 180), ('colonna', 745, 85),
)
# le cose piatte, dipinte nel terreno (lei ci passa sopra o non ci arriva);
# anche i sassi seminati sul prato
DIPINTI = (
    ('cratere', 825, 404),
)

# dove si seminano le cose da sole: i boschi (pini nelle pinete, alberi
# tondi altrove), le canne nella palude, gli alberi secchi e i rovi nella zona
# corrotta, i cespugli e i sassi sul prato. Mai dove si cammina, e mai vicino
# al giro del pilota
PALUDE = [[40, 120], [660, 120], [660, 470], [40, 470]]
PINETE = ([700, 0, 1336, 330],)
TONDI = ('albero_1', 'albero_2', 'albero_3', 'albero_4')
PINI = ('pino_1', 'pino_2', 'pino_3')
SECCHI = ('albero_secco_1', 'albero_secco_2', 'albero_secco_3', 'albero_secco_4', 'albero_secco_5',
          'albero_secco_6', 'radici_1', 'radici_2')
ROVI_PEZZI = ('rovo_1', 'rovo_2', 'rovo_3', 'rovo_basso_1', 'rovo_basso_2', 'rovo_basso_3', 'ricciolo_1',
              'ricciolo_2', 'ricciolo_3', 'rovo_secco_1', 'rovo_secco_2')
CANNE = ('canne_2', 'canne_3', 'canne_4', 'canne_5')
CESPUGLI = ('cespuglio_1', 'cespuglio_2', 'cespuglio_3', 'cespuglio_4', 'felce_1', 'felce_2', 'erba_alta')
SASSI = ('sasso_1', 'sasso_2', 'sassi_1', 'sasso_muschio_1', 'sasso_muschio_2', 'sasso_muschio_3')


def semina(dove, w, h, distanza, seme):
    """punti a caso (in unita') dove dove(x, y) e' vero, mai piu' vicini di
    distanza: un quadretto per volta, in ordine sparso"""
    caso = random.Random(seme)
    passo = distanza / 1.5
    celle = [(i, j) for j in range(int(h / passo) + 1) for i in range(int(w / passo) + 1)]
    caso.shuffle(celle)
    presi = {}
    out = []
    for i, j in celle:
        x, y = (i + caso.random()) * passo, (j + caso.random()) * passo
        if not dove(x, y):
            continue
        gi, gj = int(x // distanza), int(y // distanza)
        if any(math.hypot(x - a, y - b) < distanza
               for di in (-1, 0, 1) for dj in (-1, 0, 1) for a, b in presi.get((gi + di, gj + dj), ())):
            continue
        presi.setdefault((gi, gj), []).append((x, y))
        out.append((x, y))
    return out


def lontano_dal_giro(giro, margine):
    segmenti = list(zip(giro, giro[1:]))

    def lontano(x, y):
        for (ax, ay), (bx, by) in segmenti:
            dx, dy = bx - ax, by - ay
            t = 0.0 if dx == dy == 0 else max(0.0, min(1.0, ((x - ax) * dx + (y - ay) * dy) / (dx * dx + dy * dy)))
            if math.hypot(x - ax - t * dx, y - ay - t * dy) < margine:
                return False
        return True
    return lontano


def seminate(c, w, h, cammina, pianta):
    """le cose seminate: [(nome, x, y)] in unita'"""
    lontano = lontano_dal_giro(pianta["giro"], 22)
    palude = dentro_forma(PALUDE, 1)
    pinete = [dentro_forma(f, 1) for f in PINETE]

    def classe(x, y):
        xi, yi = int(x), int(y)
        return c[yi * w + xi] if 0 <= xi < w and 0 <= yi < h else -1

    def libero(x, y, r):
        return all(not cammina[int(yy) * w + int(xx)]
                   for xx, yy in ((x, y), (x - r, y), (x + r, y), (x, y - r), (x, y + r))
                   if 0 <= int(xx) < w and 0 <= int(yy) < h)

    def tutto(x, y, r, k):
        return all(classe(xx, yy) == k for xx, yy in ((x, y), (x - r, y), (x + r, y), (x, y - r), (x, y + r)))
    out = []
    caso = random.Random(11)
    for x, y in semina(lambda x, y: tutto(x, y, 4, ALBERI) and libero(x, y + 10, 6) and lontano(x, y + 10), w, h, 17, 1):
        pino = any(f(x, y) for f in pinete)
        out.append((caso.choice(PINI if pino else TONDI), x, y + 10))
    for x, y in semina(lambda x, y: palude(x, y) and tutto(x, y, 7, ACQUA), w, h, 30, 2):
        out.append((caso.choice(CANNE), x, y + 6))
    for x, y in semina(lambda x, y: tutto(x, y, 6, ROVI) and lontano(x, y), w, h, 46, 3):
        out.append((caso.choice(SECCHI), x, y))
    for x, y in semina(lambda x, y: tutto(x, y, 4, ROVI) and lontano(x, y) and libero(x, y, 6), w, h, 30, 4):
        out.append((caso.choice(ROVI_PEZZI), x, y))
    for x, y in semina(lambda x, y: tutto(x, y, 6, ERBA) and libero(x, y, 10) and lontano(x, y), w, h, 52, 5):
        out.append((caso.choice(CESPUGLI), x, y))
    for x, y in semina(lambda x, y: tutto(x, y, 5, ERBA) and libero(x, y, 8), w, h, 64, 6):
        out.append((caso.choice(SASSI), x, y))
    return out


# dove posano i piedi le cose (in pixel del mondo, intorno al piede): un
# ovale largo una parte della cosa, o due per l'arco (le due gambe)
def impronte(nome, larga):
    if nome.startswith('albero_grande'):
        return [(0, 0, 26, 8)]
    if nome.startswith(('albero', 'pino', 'radici')):
        return [(0, 0, 6, 3)]
    if nome == 'arco':
        return [(-larga * 0.36, 0, 6, 4), (larga * 0.36, 0, 6, 4)]
    if nome == 'colonnato':
        return [(0, 0, larga * 0.46, 5)]
    if nome.startswith(('colonna', 'blocco', 'muro')):
        return [(0, 0, larga * 0.42, 5)]
    if nome == 'capsula':
        return [(0, 0, 14, 6)]
    if nome.startswith(('rovo', 'cespuglio', 'felce', 'erba_alta')):
        return [(0, 0, larga * 0.34, 4)]
    return []


def le_cose(c, w, h, cammina, pianta, catalogo, scala):
    """-> (pezzi: [file, x, y, piede x, piede y] in pixel del mondo, in ordine
    di piede; dipinti: lo stesso per quelli piatti)"""
    def pezzo(nome, x, y):
        if nome == 'capsula':
            return ['../pianeti/pianure/capsula.png', int(round(x * scala)), int(round(y * scala)), 16, 30]
        o = catalogo["oggetti"][nome]
        return ['oggetti/' + o["file"], int(round(x * scala)), int(round(y * scala))] + o["piede"]
    semi = [t for t in seminate(c, w, h, cammina, pianta) if 0 <= t[1] < w and 0 <= t[2] < h - 1]
    tutti = [pezzo(*t) for t in A_MANO] + [pezzo(*t) for t in semi if t[0] not in SASSI]
    tutti.sort(key=lambda p: (p[2], p[1]))
    # i sassi sono piatti: nel terreno, sotto tutto
    return tutti, [pezzo(*t) for t in DIPINTI] + [pezzo(*t) for t in semi if t[0] in SASSI]


def incolla(out, W, H, pezzo):
    file, x, y, px, py = pezzo
    pw, ph, pix = leggi_pezzo(os.path.join(ARTE, file))
    x0, y0 = x - px, y - py
    for j in range(ph):
        yy = y0 + j
        if not 0 <= yy < H:
            continue
        for i in range(pw):
            xx = x0 + i
            p = pix[j * pw + i]
            if p[3] > 127 and 0 <= xx < W:
                k = 3 * (yy * W + xx)
                out[k:k + 3] = bytes(p[:3])


# ---------------------------------------------------------------- 5. i passi

def passi(K, W, H, scala, pezzi, pianta):
    """dove si cammina, pixel per pixel del mondo: il pavimento meno gli
    ostacoli, meno l'acqua e le pareti, meno i piedi delle cose; le scale e il
    ponte si' (si_passa)"""
    sempre = bytearray(W * H)
    for f in pianta["si_passa"]:
        riempi(sempre, W, H, f, scala)
    pavimento = bytearray(W * H)
    for f in pianta["pavimento"]:
        riempi(pavimento, W, H, f, scala)
    for f in pianta["ostacoli"]:
        riempi(pavimento, W, H, f, scala, 0)
    ok = bytearray(W * H)
    for i in range(W * H):
        ok[i] = sempre[i] or (pavimento[i] and K[i] != ACQUA and K[i] != PARETE)
    for file, x, y, _px, _py in pezzi:
        nome = os.path.splitext(os.path.basename(file))[0]
        larga = leggi_misura(file)
        for dx, dy, rx, ry in impronte(nome, larga):
            cx, cy = x + dx, y + dy
            for yy in range(int(cy - ry), int(cy + ry) + 1):
                for xx in range(int(cx - rx), int(cx + rx) + 1):
                    if 0 <= xx < W and 0 <= yy < H and ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1:
                        ok[yy * W + xx] = 0
    rgba = bytearray(W * H * 4)
    for i in range(W * H):
        if ok[i]:
            rgba[4 * i:4 * i + 4] = b'\xff\xff\xff\xff'
    return rgba


_misure = {}


def leggi_misura(file):
    if file not in _misure:
        with open(os.path.join(ARTE, file), 'rb') as f:
            _misure[file] = struct.unpack('>I', f.read(24)[16:20])[0]
    return _misure[file]


# ---------------------------------------------------------------- tutto

def scrivi_png(percorso, w, h, rgb=None, rgba=None):
    """un PNG veloce, da righe di byte gia' pronte"""
    if rgba is None:
        rgba = bytearray(w * h * 4)
        rgba[0::4] = rgb[0::3]
        rgba[1::4] = rgb[1::3]
        rgba[2::4] = rgb[2::3]
        rgba[3::4] = b'\xff' * (w * h)
    grezzo = b''.join(b'\x00' + bytes(rgba[y * w * 4:(y + 1) * w * 4]) for y in range(h))

    def blocco(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    with open(percorso, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(blocco(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)))
        f.write(blocco(b'IDAT', zlib.compress(grezzo, 9)))
        f.write(blocco(b'IEND', b''))


def main():
    with open(os.path.join(ARTE, 'pianure.json')) as f:
        pianta = json.load(f)
    with open(os.path.join(OGGETTI, 'catalogo.json')) as f:
        catalogo = json.load(f)
    scala = 2
    w, h, c, cammina = classi(pianta, os.path.join(QUI, 'fogli', 'pianure.png'))
    if len(sys.argv) > 1:
        colori = [esa(s) for s in ('#78986e', '#e1dfc1', '#4d6a7c', '#8a4f6e', '#6b6559', '#2e453e', '#c08a3e')]
        png.scrivi(sys.argv[1], w, h, [colori[k] + (255,) for k in c])
    K = a_misura_del_mondo(c, w, h, scala)
    W, H = w * scala, h * scala
    out = terreno(K, W, H)
    bordi(K, W, H, out)
    ponti = [f for f in pianta["si_passa"] if f == [790, 546, 810, 592]]
    scale = [f for f in pianta["si_passa"] if f not in ponti] + list(SCALE_DECORO)
    pareti(K, W, H, out, scale, ponti)
    pezzi, dipinti = le_cose(c, w, h, cammina, pianta, catalogo, scala)
    for p in dipinti:
        incolla(out, W, H, p)
    scrivi_png(os.path.join(ARTE, 'pianure.png'), W, H, rgb=out)
    with open(os.path.join(ARTE, 'pianure_pezzi.json'), 'w') as f:
        f.write('{"_nota": "Scritto da strumenti/livelli/compone.py: non toccare a mano. Ogni pezzo e\' '
                '[file (da art/livelli/), x, y del piede nel mondo, x, y del piede nel disegno].",\n'
                ' "pezzi": [\n')
        f.write(',\n'.join('  ' + json.dumps(p) for p in pezzi))
        f.write('\n ]}\n')
    scrivi_png(os.path.join(ARTE, 'pianure_passi.png'), W, H, rgba=passi(K, W, H, scala, pezzi, pianta))
    print('pianure: %dx%d, %d pezzi' % (W, H, len(pezzi)))


if __name__ == '__main__':
    main()
