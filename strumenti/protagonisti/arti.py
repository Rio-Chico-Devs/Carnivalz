import math
# Arti articolati per la vista di lato: anca -> ginocchio -> caviglia,
# spalla -> gomito -> mano. Si tracciano a spessore costante, poi il contorno.
def traccia(punti, largo):
    # punti: [(x, y), ...] -> {(x, y): t} con t = 0..1 lungo l'arto
    celle = {}
    lunghezze = []
    tot = 0.0
    for a, b in zip(punti, punti[1:]):
        l = max(abs(b[0] - a[0]), abs(b[1] - a[1]), 1)
        lunghezze.append(l)
        tot += l
    fatto = 0.0
    for (a, b), l in zip(zip(punti, punti[1:]), lunghezze):
        passi = int(l * 4)
        for k in range(passi + 1):
            f = k / passi
            x = a[0] + (b[0] - a[0]) * f
            y = a[1] + (b[1] - a[1]) * f
            t = (fatto + l * f) / tot
            for dx in range(largo):
                # floor(v + 0.5), non round(): round() arrotonda i .5 al pari e
                # con gli spessori pari lascia dei buchi a righe
                cx = math.floor(x - (largo - 1) / 2 + dx + 0.5)
                cy = math.floor(y + 0.5)
                if (cx, cy) not in celle or celle[(cx, cy)] > t:
                    celle[(cx, cy)] = t
        fatto += l
    return celle

def capsula(punti, r):
    # come traccia, ma lo spessore e' vero (i pixel entro r dalla spezzata):
    # regge anche gli arti quasi orizzontali, come la gamba alzata dietro
    segmenti, tot = [], 0.0
    for a, b in zip(punti, punti[1:]):
        l = math.hypot(b[0] - a[0], b[1] - a[1])
        segmenti.append((a, b, l, tot))
        tot += l
    xs = [p[0] for p in punti]
    ys = [p[1] for p in punti]
    celle = {}
    for y in range(int(min(ys) - r - 1), int(max(ys) + r + 2)):
        for x in range(int(min(xs) - r - 1), int(max(xs) + r + 2)):
            meglio = None
            for (ax, ay), (bx, by), l, t0 in segmenti:
                f = 0.0 if l == 0 else max(0.0, min(1.0, ((x - ax) * (bx - ax) + (y - ay) * (by - ay)) / (l * l)))
                d = math.hypot(x - (ax + f * (bx - ax)), y - (ay + f * (by - ay)))
                if meglio is None or d < meglio[0]:
                    meglio = (d, (t0 + f * l) / max(tot, 1e-6))
            if meglio[0] <= r:
                celle[(x, y)] = meglio[1]
    return celle

def disegna(t, celle, colore_di, contorno='o'):
    # colore_di(t, x, y, bordo) -> lettera
    for (x, y), v in celle.items():
        if not (0 <= x < len(t[0]) and 0 <= y < len(t)):
            continue
        bordo = any((x + dx, y + dy) not in celle for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        t[y][x] = contorno if bordo else colore_di(v, x, y)
