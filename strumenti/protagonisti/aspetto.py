# L'aspetto di lei come nel suo disegno (Bru: «miglioriamo l'aspetto del
# personaggio, sopra la testa non ha degli occhiali ma un cerchio d'oro»).
# Il foglio da cui e' ricalcata le metteva degli occhialoni sulla fascia; nel
# disegno di Bru la fascia e' cremisi con le stelle chiare, e sul lato destro
# della testa c'e' un cerchio d'oro. Qui, sopra il ricalco gia' pulito:
#   - la fascia ridipinta, una striscia di quattro righe (la luce sopra,
#     l'ombra sotto) che segue la testa in ogni vista, con le stelle;
#   - il cerchio d'oro: davanti a sinistra di chi guarda, di lato tondo (e'
#     il lato che si vede), da dietro di taglio sul bordo destro;
#   - gli occhi col viola-magenta del disegno.
# Le misure sono sui tre disegni puliti (davanti1, dietro2 e il lato) che
# escono da ricalca.py.

def esa(x):
    x = x.lstrip('#')
    return tuple(int(x[i:i + 2], 16) for i in (0, 2, 4))


FASCIA = [esa(c) for c in ('#f06a86', '#c8304e', '#c8304e', '#922038')]
STELLA = esa('#f4ecff')
ORO = {'y': esa('#ffe49a'), 'Y': esa('#e8b040'), 'z': esa('#a8701c'), 'R': esa('#5e1226')}
IRIDE = esa('#c048b0')
LUCE_OCCHIO = esa('#f8c0f0')

# il cerchio d'oro: y chiaro, Y oro, z scuro, R la fascia che si vede nel buco
CERCHIO = {
    "tondo": [".oooo.",
              "oyyYzo",
              "oyRRzo",
              "oYRRzo",
              "oYzzzo",
              ".oooo."],
    "taglio": [".oo",
               "oyo",
               "oYo",
               "oYo",
               "ozo",
               ".oo"],
}

# per ogni vista: la riga dove comincia la fascia, colonna per colonna; dove
# sono le stelle; dove va il cerchio (l'angolo in alto a sinistra) e com'e';
# gli occhi (dove va l'iride, due pixel, e la luce)
VISTE = {
    "davanti": dict(
        fascia=(4, 21, lambda x: 9),
        stelle=((12, 10), (17, 10), (14, 11), (19, 11)),
        cerchio=((3, 8), "tondo"),
        iridi=((8, 19), (9, 19), (16, 19), (17, 19)), luci=((8, 18), (16, 18))),
    "dietro": dict(
        fascia=(3, 21, lambda x: 14 + round(2 * (1 - ((x - 12.5) / 9.0) ** 2))),
        stelle=((8, 16), (16, 17)),
        cerchio=((20, 13), "taglio"),
        iridi=(), luci=()),
    "lato": dict(
        fascia=(9, 27, lambda x: round(16 - (x - 9) * 8 / 18.0)),
        stelle=((12, 16), (15, 15), (18, 13)),
        cerchio=((20, 8), "tondo"),
        iridi=((21, 19), (22, 19)), luci=((21, 18),)),
}


def vesti(g, vista, nero):
    """la fascia, le stelle, il cerchio d'oro e gli occhi su un disegno pulito"""
    g = [list(r) for r in g]
    h, w = len(g), len(g[0])
    v = VISTE[vista]

    def dentro(x, y):
        return 0 <= x < w and 0 <= y < h and g[y][x] is not None and g[y][x] != nero

    x0, x1, riga = v["fascia"]
    for x in range(x0, x1 + 1):
        for k, c in enumerate(FASCIA):
            if dentro(x, riga(x) + k):
                g[riga(x) + k][x] = c
    for x, y in v["stelle"]:
        if dentro(x, y):
            g[y][x] = STELLA
    (cx, cy), forma = v["cerchio"]
    for j, r in enumerate(CERCHIO[forma]):
        for i, ch in enumerate(r):
            if ch != "." and 0 <= cx + i < w and 0 <= cy + j < h:
                g[cy + j][cx + i] = nero if ch == "o" else ORO[ch]
    for x, y in v["iridi"]:
        if dentro(x, y):
            g[y][x] = IRIDE
    for x, y in v["luci"]:
        if dentro(x, y):
            g[y][x] = LUCE_OCCHIO
    return g
