# Gli alberi dei livelli, disegnati pixel per pixel.
#
#   python3 strumenti/livelli/alberi.py
#
# Bru, sui pezzi ricalcati dai fogli: «i disegni e le posizioni fanno pietà,
# concentriamoci prima sui singoli elementi poi sulla messa in scena, migliora
# lo sprite degli alberi per cominciare». La grandezza andava bene: un albero
# e' alto una volta e mezza lei, un pino quasi due.
#
# Qui niente si ricalca: ogni albero e' costruito con poche forme e poche
# regole, come lo farebbe uno a mano.
#   - LA TAVOLOZZA: una rampa di verdi per le foglie, una piu' blu per gli
#     aghi, una di marroni per la corteccia. Le ombre virano al blu, le luci
#     al giallo, e sono spente come il prato. Il contorno e' il piu' scuro
#     della rampa, mai nero.
#   - LA LUCE viene sempre da in alto a sinistra.
#   - L'ALBERO TONDO: la chioma e' una cupola (alcuni ciuffi messi a mano,
#     insieme, con le tacche fra l'uno e l'altro riempite: una massa, non un
#     grappolo), riempita di FOGLIE A TIMBRO: una piccola forma col bordo
#     chiaro in alto, il corpo e la punta in ombra, timbrata fitta dall'alto in
#     basso, cosi' ogni foglia copre la punta di quella sopra. Il tono di
#     ogni foglia viene dalla luce della cupola e del suo ciuffo; nell'ombra
#     la foglia e' di un tono solo (il dettaglio sta nella luce). Sotto, il
#     tronco: luce a sinistra, ombra a destra, il buio sotto la chioma, le
#     radici che si allargano.
#   - IL PINO e' una pila di palchi: ognuno e' un cono basso col fondo a
#     punte (i rami che pendono), chiaro a sinistra e scuro a destra, con la
#     fascia d'ombra del palco di sopra.
#   - IL CONTORNO e' scuro tutto intorno, un poco meno dalla parte della luce.
#     Un pixel da solo, di un colore che nessun vicino ha, prende il colore
#     dei vicini.
#   - L'OMBRA per terra: un ovale scuro e trasparente sotto l'albero.
#
# Provato e scartato: i ciuffi come palle con un berretto di luce a
# mezzaluna (sembravano cavolfiori, o grappoli), e la chioma a sfumature
# (un tremolio di pixel, proprio il frastagliato che non va).
#
# Scrive art/livelli/pezzi/alberi/<nome>.png e il catalogo dei pezzi
# disegnati, art/livelli/pezzi/catalogo.json (misura e piede di ognuno).
import json
import math
import os
import sys

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(QUI, '..', 'protagonisti'))
import png  # noqa: E402

PEZZI = os.path.join(QUI, '..', '..', 'art', 'livelli', 'pezzi')


def esa(s):
    return (int(s[1:3], 16), int(s[3:5], 16), int(s[5:7], 16), 255)


# le rampe, dal piu' scuro al piu' chiaro
FOGLIE = [esa(c) for c in ('#13221d', '#1b3329', '#244834', '#31603d', '#437a48', '#609557', '#8bb46c')]
CORTECCIA = [esa(c) for c in ('#1c1414', '#3a2722', '#5a3c2c', '#7a5638', '#9a7448')]
OMBRA = (12, 24, 20, 96)
LUCE = (-0.55, -0.75, 0.55)      # da in alto a sinistra, e un poco da davanti
_n = math.sqrt(sum(v * v for v in LUCE))
LUCE = tuple(v / _n for v in LUCE)


class Tela:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.p = [None] * (w * h)

    def get(self, x, y):
        return self.p[y * self.w + x] if 0 <= x < self.w and 0 <= y < self.h else None

    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.p[y * self.w + x] = c

    def pixel(self):
        return [c if c is not None else (0, 0, 0, 0) for c in self.p]


# ---------------------------------------------------------------- le regole

def via_i_pixel_soli(t, pieni=None):
    """un pixel di un colore che nessuno dei quattro vicini ha prende il
    colore piu' comune fra i vicini (se almeno due sono uguali)"""
    nuovo = list(t.p)
    for y in range(t.h):
        for x in range(t.w):
            c = t.get(x, y)
            if c is None or c[3] < 255 or (pieni is not None and c not in pieni):
                continue
            vicini = [t.get(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))]
            vicini = [v for v in vicini if v is not None and v[3] == 255]
            if vicini and c not in vicini:
                piu = max(set(vicini), key=vicini.count)
                if vicini.count(piu) >= 2:
                    nuovo[y * t.w + x] = piu
    t.p = nuovo


def contorno(t, scuro, chiaro, centro):
    """il contorno, fuori dalla sagoma: scuro, ma un poco meno dalla parte
    della luce (in alto a sinistra rispetto al centro della chioma)"""
    w, h = t.w, t.h
    cx, cy = centro
    dentro = [c is not None and c[3] == 255 for c in t.p]
    nuovo = list(t.p)
    for y in range(h):
        for x in range(w):
            if dentro[y * w + x]:
                continue
            if any(0 <= x + dx < w and 0 <= y + dy < h and dentro[(y + dy) * w + x + dx]
                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                vx, vy = x + 0.5 - cx, y + 0.5 - cy
                d = math.hypot(vx, vy) or 1.0
                luce = (vx * LUCE[0] + vy * LUCE[1]) / d
                nuovo[y * w + x] = chiaro if luce > 0.55 else scuro
    t.p = nuovo


def ombra_per_terra(t, cx, cy, rx, ry):
    for y in range(int(cy - ry), int(cy + ry) + 1):
        for x in range(int(cx - rx), int(cx + rx) + 1):
            if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1 and t.get(x, y) is None:
                t.put(x, y, OMBRA)


# ---------------------------------------------------------------- l'albero tondo

# le foglie, a timbro: '+' il bordo chiaro, '=' il corpo, '-' la punta in
# ombra. Punta in basso, a destra come vuole la luce; tre forme, a caso
FOGLIE_TIMBRI = (
    ('.++..',
     '+===.',
     '.==--',
     '..-..'),
    ('..++.',
     '.+==-',
     '+==-.',
     '.-...'),
    ('.+++.',
     '+===-',
     '.=--.'),
)


def albero_tondo(w, h, ciuffi, tronco_da, largo, radici, ombra):
    t = Tela(w, h)
    cx = w / 2.0
    ombra_per_terra(t, cx + 2, h - 3, *ombra)
    tronco(t, cx, tronco_da, h - 3, largo, radici)
    # la cupola: tutti i ciuffi insieme, con le tacche fra l'uno e l'altro
    # riempite (una chioma e' una massa, non un grappolo); dentro e' buio
    cupola = [False] * (w * h)
    for x, y, r in ciuffi:
        for yy in range(int(y - r) - 1, int(y + r) + 2):
            for xx in range(int(x - r) - 1, int(x + r) + 2):
                if 0 <= xx < w and 0 <= yy < h and math.hypot(xx + 0.5 - x, yy + 0.5 - y) <= r:
                    cupola[yy * w + xx] = True
    cupola = chiudi(cupola, w, h, 2)
    for i, dentro in enumerate(cupola):
        if dentro:
            t.p[i] = FOGLIE[1]
    xs = [i % w for i in range(w * h) if cupola[i]]
    ys = [i // w for i in range(w * h) if cupola[i]]
    mx, my = (min(xs) + max(xs) + 1) / 2.0, (min(ys) + max(ys) + 1) / 2.0
    rx, ry = (max(xs) - min(xs) + 1) / 2.0, (max(ys) - min(ys) + 1) / 2.0
    # le foglie: dall'alto in basso (quella sotto copre la punta di quella
    # sopra), a file sfalsate ogni 3 pixel, un poco a caso. Il tono di ogni
    # foglia: la luce della cupola e quella del ciuffo in cui sta
    posti = []
    for j, y in enumerate(range(int(my - ry) - 1, int(my + ry) + 1, 3)):
        for x in range(int(mx - rx) - 2 + (j % 2) * 2, int(mx + rx) + 1, 4):
            fx = x + int(caso(x, y, 1) * 4) - 2
            fy = y + int(caso(x, y, 2) * 3) - 1
            if 0 <= fx + 2 < w and 0 <= fy + 1 < h and cupola[(fy + 1) * w + fx + 2]:
                posti.append((fy, fx))
    posti.sort()
    for fy, fx in posti:
        px, py = fx + 2.5, fy + 2.0
        grande = sfera(px - mx, py - my, rx * 1.05, ry * 1.05)
        vicino = min(ciuffi, key=lambda c: math.hypot(px - c[0], py - c[1]) / c[2])
        piccola = sfera(px - vicino[0], py - vicino[1], vicino[2] * 1.1, vicino[2] * 1.1)
        luce = 0.5 * (grande if grande is not None else -0.3) + 0.5 * (piccola if piccola is not None else -0.2)
        base = 1 if luce < 0.05 else 2 if luce < 0.3 else 3 if luce < 0.52 else 4 if luce < 0.72 else 5
        # in fondo al ciuffo le foglie sono in ombra: lo staccano da quello sotto
        if py - vicino[1] > vicino[2] * 0.6:
            base -= 1
        timbro = FOGLIE_TIMBRI[int(caso(fx, fy, 3) * len(FOGLIE_TIMBRI))]
        for j, riga in enumerate(timbro):
            for i, ch in enumerate(riga):
                if ch == '.':
                    continue
                x, y = fx + i, fy + j
                if not (0 <= x < w and 0 <= y < h):
                    continue
                # fuori dalla cupola, solo il bordo di sopra della foglia
                # (le foglie del bordo sporgono un poco, non la punta)
                if not cupola[y * w + x] and ch != '+' and y > my:
                    continue
                # nell'ombra la foglia e' tutta di un tono (il dettaglio sta
                # nella luce, come si fa a mano)
                if base <= 2:
                    k = base if ch != '-' else base - 1
                else:
                    k = base + (1 if ch == '+' else -1 if ch == '-' else 0)
                t.put(x, y, FOGLIE[max(1, min(6, k))])
    contorno(t, FOGLIE[0], FOGLIE[1], (mx, my))
    via_i_pixel_soli(t)
    return t


def caso(*v):
    """un numero fisso in [0, 1) per ogni combinazione di interi"""
    h = 2166136261
    for x in v:
        h = ((h ^ (int(x) & 0xffffffff)) * 16777619) & 0xffffffff
    h ^= h >> 13
    h = (h * 1274126177) & 0xffffffff
    return (h ^ (h >> 16)) / 4294967296.0


def sfera(dx, dy, rx, ry):
    """quanta luce prende il punto (dx, dy) di un ovale rx x ry visto come
    una palla; None se e' fuori"""
    nx, ny = dx / rx, dy / ry
    q = nx * nx + ny * ny
    if q > 1.0:
        return None
    nz = math.sqrt(1.0 - q)
    return nx * LUCE[0] + ny * LUCE[1] + nz * LUCE[2]


def chiudi(m, w, h, r):
    """allarga di r e poi stringe di r: le tacche strette si riempiono"""
    def allarga(m, valore):
        out = list(m)
        for y in range(h):
            for x in range(w):
                if m[y * w + x] != valore and any(
                        0 <= x + dx < w and 0 <= y + dy < h and m[(y + dy) * w + x + dx] == valore
                        for dx in range(-r, r + 1) for dy in range(-r, r + 1) if dx * dx + dy * dy <= r * r):
                    out[y * w + x] = valore
        return out
    return allarga(allarga(m, True), False)


def tronco(t, cx, top, base, largo, radici):
    """il tronco, che si allarga in fondo nelle radici: luce a sinistra,
    ombra a destra, due nodi nella corteccia, il buio sotto la chioma"""
    for y in range(top, base + 1):
        f = (y - top) / max(1, base - top)
        allarga = max(0.0, (f - 0.4) / 0.6) ** 2.0 * radici
        mezzo = largo / 2.0 + allarga
        x0, x1 = int(round(cx - mezzo)), int(round(cx + mezzo))
        for x in range(x0, x1):
            u = (x + 0.5 - (cx - mezzo)) / (2 * mezzo)
            tono = 4 if u < 0.18 else 3 if u < 0.55 else 2 if u < 0.82 else 1
            if y - top < 2:
                tono = 1
            elif y - top < 4:
                tono = min(tono, 2)
            t.put(x, y, CORTECCIA[tono])
    # i nodi: due trattini scuri
    for nx, ny in ((cx - 1, top + (base - top) * 0.4), (cx + 1, top + (base - top) * 0.65)):
        t.put(int(nx), int(ny), CORTECCIA[1])
        t.put(int(nx), int(ny) + 1, CORTECCIA[2])
    # le radici: in fondo, attaccate al tronco, una punta per parte
    mezzo = largo / 2.0 + radici
    x0, x1 = int(round(cx - mezzo)), int(round(cx + mezzo))
    for x, y, tono in ((x0 - 1, base, 3), (x0 - 2, base, 2), (x0 - 1, base - 1, 3),
                       (x1, base, 1), (x1 + 1, base, 1), (x1, base - 1, 2)):
        t.put(x, y, CORTECCIA[tono])


# gli alberi tondi: (larghezza, altezza, i ciuffi (x, y, raggio), dove
# comincia il tronco, quanto e' largo, quanto si allargano le radici, l'ombra
# (rx, ry)). I ciuffi sono messi a mano: uno grande in cima, due di fianco, la
# fila di mezzo, quella davanti. Insieme fanno la cupola; ognuno da' alle
# foglie che ha dentro la sua luce
TONDI = {
    'albero_1': (56, 72,
                 [(27, 14, 11), (15, 21, 9), (40, 20, 10),
                  (9, 35, 8), (24, 30, 11), (44, 34, 9),
                  (16, 45, 9), (33, 44, 10), (46, 47, 7)],
                 52, 7, 5, (18, 4)),
    'albero_2': (60, 74,
                 [(30, 13, 10), (18, 18, 9), (43, 18, 9),
                  (10, 32, 8), (29, 27, 12), (50, 32, 8),
                  (17, 44, 10), (36, 43, 10), (51, 47, 7), (27, 50, 8)],
                 54, 8, 5, (20, 4)),
    'albero_3': (52, 70,
                 [(26, 14, 10), (14, 23, 8), (38, 23, 9),
                  (24, 31, 10), (11, 40, 7), (40, 40, 8), (27, 45, 9)],
                 50, 7, 4, (16, 4)),
    'albero_4': (64, 76,
                 [(31, 13, 11), (18, 19, 9), (45, 18, 10),
                  (9, 34, 8), (25, 30, 11), (42, 31, 11), (56, 35, 7),
                  (16, 47, 9), (33, 48, 11), (50, 48, 9)],
                 56, 8, 6, (22, 5)),
}


# ---------------------------------------------------------------- il pino

AGHI = [esa(c) for c in ('#0f1d1c', '#152d2a', '#1c4237', '#265841', '#34704b', '#4d8a58', '#77a866')]


def pino(w, h, palchi, tronco_da, largo, ombra):
    """palchi: (y della punta, y del fondo, mezza larghezza in fondo, quanto
    sono larghe le punte dei rami)"""
    t = Tela(w, h)
    cx = w / 2.0
    ombra_per_terra(t, cx + 1, h - 3, *ombra)
    tronco(t, cx, tronco_da, h - 3, largo, 2)
    # dal basso in alto: ogni palco copre la cima di quello sotto
    for k, (cima, fondo, mezza, denti) in reversed(list(enumerate(palchi))):
        palco(t, cx, cima, fondo, mezza, denti, k)
    contorno(t, AGHI[0], AGHI[1], (cx, h * 0.45))
    via_i_pixel_soli(t)
    return t


def palco(t, cx, cima, fondo, mezza, denti, k):
    """un palco di rami: un cono basso, il fondo fatto di punte a V (i rami
    che pendono, non tutti uguali). Ogni punta ha il berretto chiaro in cima
    a sinistra e il filo scuro sotto. Il palco e' chiaro a sinistra e scuro
    a destra, e in cima ha la fascia scura dell'ombra di quello sopra"""
    alto = fondo - cima
    n = max(2, int(round(2 * mezza / denti)))
    passo = 2 * mezza / n
    for y in range(int(cima), int(fondo) + 4):
        for x in range(int(cx - mezza) - 3, int(cx + mezza) + 4):
            px, py = x + 0.5, y + 0.5
            dx = px - cx
            f = (py - cima) / alto
            if f < 0:
                continue
            # la punta piu' vicina, sul fondo: ognuna scende di un poco, e
            # non tutte uguali
            i = min(n - 1, max(0, int((dx + mezza) / passo)))
            tx = cx - mezza + (i + 0.5) * passo
            punta = fondo + 2.5 - 2.0 * abs(i + 0.5 - n / 2.0) / (n / 2.0) + (caso(k, i, 7) - 0.5) * 2.0
            q = abs(px - tx) / (passo / 2.0)            # 0 al centro della punta, 1 fra due punte
            giu = punta - 3.6 * q ** 1.15
            # un fianco un poco piu' largo dell'altro, palco per palco
            storto = 1.0 + (caso(k, 1 if dx < 0 else 2, 8) - 0.5) * 0.14
            m = mezza * storto * min(1.0, f) ** 0.8 + 1.5 * (1 - q) * (f > 0.6)
            if py > giu or abs(dx) > m:
                continue
            u = dx / max(1.0, mezza)
            # il tono: chiaro a sinistra, scuro a destra
            tono = 4 if u < -0.35 else 3 if u < 0.3 else 2
            # in fondo, ogni punta: il berretto chiaro in cima a sinistra
            if py > giu - 4.5 and px < tx + passo * 0.15 and py < giu - 1.5:
                tono += 1
            elif py > giu - 1.6:
                tono -= 1
            # gli aghi: righe a 45 gradi, che dal tronco scendono verso fuori
            elif abs(dx) > 2 and (int(py) - int(abs(dx)) + k) % 4 == 0 and f > 0.4 and tono >= 3:
                tono -= 1
            # in cima, l'ombra del palco di sopra: una fascia scura sotto le
            # sue punte
            if k > 0 and f < 0.45:
                tono -= 1 if f > 0.3 else 2
            t.put(x, y, AGHI[max(1, min(6, tono))])


PINI = {
    # (larghezza, altezza, palchi, dove comincia il tronco, largo, ombra)
    'pino_1': (48, 96,
               [(2, 15, 7, 5), (9, 27, 11, 6), (18, 41, 15, 6), (29, 56, 18, 6), (41, 71, 21, 7), (54, 84, 23, 7)],
               82, 6, (16, 4)),
    'pino_2': (44, 100,
               [(2, 17, 6, 5), (10, 30, 10, 5), (20, 44, 13, 6), (31, 59, 16, 6), (43, 74, 18, 6), (56, 88, 20, 7)],
               86, 6, (14, 4)),
    'pino_3': (52, 90,
               [(3, 16, 8, 5), (11, 29, 13, 6), (21, 44, 17, 6), (33, 60, 21, 7), (46, 77, 24, 7)],
               75, 7, (18, 4)),
}


# ---------------------------------------------------------------- tutto

def main():
    cartella = os.path.join(PEZZI, 'alberi')
    os.makedirs(cartella, exist_ok=True)
    catalogo = {"_nota": "Scritto da strumenti/livelli/alberi.py: non toccare a mano.", "pezzi": {}}
    disegni = [(n, albero_tondo(*v)) for n, v in TONDI.items()] + [(n, pino(*v)) for n, v in PINI.items()]
    for nome, t in disegni:
        png.scrivi(os.path.join(cartella, nome + '.png'), t.w, t.h, t.pixel())
        catalogo["pezzi"][nome] = {"file": "alberi/%s.png" % nome, "misura": [t.w, t.h], "piede": [t.w // 2, t.h - 3]}
    percorso = os.path.join(PEZZI, 'catalogo.json')
    vecchio = {}
    if os.path.exists(percorso):
        with open(percorso) as f:
            vecchio = json.load(f).get("pezzi", {})
    vecchio = {k: v for k, v in vecchio.items() if not v["file"].startswith('alberi/')}
    catalogo["pezzi"].update(vecchio)
    with open(percorso, 'w') as f:
        json.dump(catalogo, f, indent=1, ensure_ascii=False, sort_keys=True)
        f.write('\n')
    print('alberi:', ', '.join(n for n, _t in disegni))


if __name__ == '__main__':
    main()
