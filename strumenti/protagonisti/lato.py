# Le gambe e le braccia di lato, articolate, e la spada di spalle.
from arti import traccia, disegna

# i tempi di lato: anca, ginocchio, caviglia per la gamba vicina e la lontana;
# spalla, gomito, mano per il braccio vicino e il lontano; sobbalzo
TEMPI_LATO = {
    "fermo":  dict(g_vic=[(16, 29), (16, 36), (16, 43)], g_lon=[(14, 29), (14, 36), (14, 43)],
                   b_vic=[(15, 19), (15, 25), (15, 31)], b_lon=[(13, 19), (13, 25), (13, 30)], su=0),
    "passo1": dict(g_vic=[(16, 30), (19, 37), (21, 43)], g_lon=[(14, 30), (12, 37), (9, 43)],
                   b_vic=[(15, 20), (13, 26), (11, 31)], b_lon=[(13, 20), (16, 26), (19, 29)], su=1),
    "medio1": dict(g_vic=[(16, 29), (16, 36), (16, 43)], g_lon=[(14, 29), (18, 35), (16, 41)],
                   b_vic=[(15, 19), (15, 25), (15, 31)], b_lon=[(13, 19), (13, 25), (13, 30)], su=0),
    "passo2": dict(g_vic=[(16, 30), (13, 37), (10, 43)], g_lon=[(14, 30), (17, 37), (19, 43)],
                   b_vic=[(15, 20), (18, 26), (21, 29)], b_lon=[(13, 20), (11, 26), (9, 30)], su=1),
    "medio2": dict(g_vic=[(16, 29), (19, 35), (17, 41)], g_lon=[(14, 29), (14, 36), (14, 43)],
                   b_vic=[(15, 19), (15, 25), (15, 31)], b_lon=[(13, 19), (13, 25), (13, 30)], su=0),
}

def piede(celle, caviglia, avanti=3):
    ax, ay = caviglia
    for y in range(ay - 1, ay + 2):
        for x in range(ax - 2, ax + avanti + 1):
            celle[(x, y)] = 1.0
    return celle

def gamba_lui(t, punti, vicina):
    celle = piede(traccia(punti, 5), punti[-1])
    suola = punti[-1][1] + 1
    def colore(v, x, y):
        if y >= suola - 0 and v >= 0.99:
            return 'q' if vicina else 'b'
        if v < 0.42:
            if vicina:
                return 'p' if y % 2 == 0 else 'P'
            return 'P' if y % 2 == 0 else 'b'
        if v < 0.55:
            # la ginocchiera: il bordo chiaro in alto
            return ('c' if v < 0.48 else 'K') if vicina else 'b'
        if vicina and 0.62 < v < 0.75:
            # il pannello bianco sullo stinco
            sinistra = min(c[0] for c in celle if c[1] == y)
            return 'q' if x in (sinistra + 2, sinistra + 3) else 'n'
        return 'n' if vicina else 'b'
    disegna(t, celle, colore)

def braccio_lui(t, punti, vicino):
    # la manica arrotolata al gomito: sotto si vede l'avambraccio, poi il
    # polsino d'argento e il guanto
    celle = traccia(punti, 4)
    def colore(v, x, y):
        sinistra = min(c[0] for c in celle if c[1] == y)
        if v < 0.5:
            return ('J' if x == sinistra + 1 else 'j') if vicino else 'n'
        if v < 0.56:
            return 'J' if vicino else 'n'
        if v < 0.76:
            return ('l' if x == sinistra + 1 else 's') if vicino else 'S'
        if v < 0.82:
            return 'q' if vicino else 'b'
        return ('G' if x == sinistra + 1 else 'g') if vicino else 'b'
    disegna(t, celle, colore)

def spada_su(t, su):
    # di spalle, sopra la giacca: l'elsa in alto a destra, la punta al fianco sinistro
    lama = traccia([(22, 15 + su), (10, 31 + su)], 5)
    def colore(v, x, y):
        sinistra = min(c[0] for c in lama if c[1] == y)
        destra = max(c[0] for c in lama if c[1] == y)
        if x == sinistra + 1:
            return 'y'
        if x == destra - 1:
            return 'Y'
        # la riga nera lungo la lama, come nel disegno
        return 'o' if x == sinistra + 2 and 0.2 < v < 0.8 else 'q'
    disegna(t, lama, colore)
    manico = traccia([(26, 9 + su), (23, 14 + su)], 2)
    disegna(t, manico, lambda v, x, y: 'r' if (x + y) % 2 else 'R')
    for x, y, ch in [(20, 14, 'o'), (21, 13, 'o'), (22, 14, 'Y'), (23, 15, 'Y'), (24, 15, 'o'), (25, 15, 'o'), (27, 8, 'o'), (27, 9, 'q'), (28, 9, 'o')]:
        t[y + su][x] = ch

TEMPI_LATO_LEI = {
    "fermo":  dict(g_vic=[(16, 29), (16, 36), (16, 43)], g_lon=[(14, 29), (14, 36), (14, 43)],
                   b_vic=[(15, 20), (15, 25), (15, 30)], b_lon=[(13, 20), (13, 25), (13, 29)], su=0),
    "passo1": dict(g_vic=[(16, 30), (18, 37), (20, 43)], g_lon=[(14, 30), (12, 37), (10, 43)],
                   b_vic=[(15, 21), (13, 26), (11, 30)], b_lon=[(13, 21), (15, 26), (18, 28)], su=1),
    "medio1": dict(g_vic=[(16, 29), (16, 36), (16, 43)], g_lon=[(14, 29), (17, 35), (15, 41)],
                   b_vic=[(15, 20), (15, 25), (15, 30)], b_lon=[(13, 20), (13, 25), (13, 29)], su=0),
    "passo2": dict(g_vic=[(16, 30), (14, 37), (11, 43)], g_lon=[(14, 30), (16, 37), (18, 43)],
                   b_vic=[(15, 21), (17, 26), (20, 28)], b_lon=[(13, 21), (11, 26), (9, 29)], su=1),
    "medio2": dict(g_vic=[(16, 29), (18, 35), (16, 41)], g_lon=[(14, 29), (14, 36), (14, 43)],
                   b_vic=[(15, 20), (15, 25), (15, 30)], b_lon=[(13, 20), (13, 25), (13, 29)], su=0),
}

def gamba_lei(t, punti, vicina):
    celle = piede(traccia(punti, 5), punti[-1], 2)
    # il tacco: sotto il calcagno
    ax, ay = punti[-1]
    celle[(ax - 2, ay + 2)] = 1.0
    celle[(ax - 1, ay + 2)] = 1.0
    def colore(v, x, y):
        if v < 0.22:
            return ('l' if (x + y) % 5 == 0 else 's') if vicina else 'S'
        sinistra = min(c[0] for c in celle if c[1] == y)
        if vicina and x == sinistra + 1:
            return 'J'
        return 'j' if vicina else 'n'
    disegna(t, celle, colore)

def braccio_lei(t, punti, vicino):
    celle = traccia(punti, 4)
    def colore(v, x, y):
        sinistra = min(c[0] for c in celle if c[1] == y)
        if v < 0.4:
            return ('l' if x == sinistra + 1 else 's') if vicino else 'S'
        if v < 0.47:
            return 'c' if vicino else 'K'
        return ('J' if x == sinistra + 1 else 'j') if vicino else 'n'
    disegna(t, celle, colore)
