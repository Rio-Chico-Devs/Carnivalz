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

def disegna(t, celle, colore_di, contorno='o'):
    # colore_di(t, x, y, bordo) -> lettera
    for (x, y), v in celle.items():
        if not (0 <= x < 32 and 0 <= y < 48):
            continue
        bordo = any((x + dx, y + dy) not in celle for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        t[y][x] = contorno if bordo else colore_di(v, x, y)
