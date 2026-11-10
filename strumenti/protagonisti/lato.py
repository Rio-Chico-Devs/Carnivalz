# La vista di lato: le gambe e le braccia articolate (arti.py), con lo
# stivale e il guanto attaccati in fondo; e le cose che non stanno in una
# griglia: lo spadone di lui e le code della sciarpa che ondeggiano.
from arti import traccia, disegna
from pezzi import incolla, W, H

# anca, ginocchio, caviglia per la gamba vicina e la lontana; spalla, gomito,
# mano per il braccio vicino e il lontano; quanto scende il corpo
TEMPI_LATO = {
    "fermo":  dict(g_vic=[(17, 34), (17, 37), (17, 40)], g_lon=[(15, 34), (15, 37), (15, 40)],
                   b_vic=[(16, 25), (16, 29), (16, 32)], b_lon=[(14, 25), (14, 29), (14, 32)], su=0),
    "passo1": dict(g_vic=[(17, 35), (19, 38), (21, 40)], g_lon=[(15, 35), (13, 38), (11, 40)],
                   b_vic=[(16, 26), (14, 29), (12, 31)], b_lon=[(14, 26), (17, 29), (19, 31)], su=1),
    "medio1": dict(g_vic=[(17, 34), (17, 37), (17, 40)], g_lon=[(15, 34), (18, 36), (16, 38)],
                   b_vic=[(16, 25), (16, 29), (16, 32)], b_lon=[(14, 25), (14, 29), (14, 32)], su=0),
    "passo2": dict(g_vic=[(17, 35), (15, 38), (12, 40)], g_lon=[(15, 35), (17, 38), (20, 40)],
                   b_vic=[(16, 26), (18, 29), (20, 31)], b_lon=[(14, 26), (12, 29), (10, 31)], su=1),
    "medio2": dict(g_vic=[(17, 34), (20, 36), (18, 38)], g_lon=[(15, 34), (15, 37), (15, 40)],
                   b_vic=[(16, 25), (16, 29), (16, 32)], b_lon=[(14, 25), (14, 29), (14, 32)], su=0),
}

def gamba_lui(v, x, sinistra, vicina):
    if not vicina:
        return 'n' if x > sinistra + 1 else 'b'
    if 0.3 < v < 0.42 or 0.62 < v < 0.72:
        return 'p' if x in (sinistra + 2, sinistra + 3) else 'b'
    return 'B' if x == sinistra + 1 else 'b'

def gamba_lei(v, x, sinistra, vicina):
    # la coscia nuda, il bordo dello stivale, lo stivale
    if v < 0.3:
        return ('l' if x == sinistra + 1 else 's') if vicina else 'S'
    if v < 0.4:
        return 'K' if vicina else 'j'
    return ('J' if x == sinistra + 1 else 'j') if vicina else 'n'

def braccio_lui(v, x, sinistra, vicino):
    if v < 0.6:
        return ('J' if x == sinistra + 1 else 'j') if vicino else 'n'
    return ('l' if x == sinistra + 1 else 's') if vicino else 'S'

def braccio_lei(v, x, sinistra, vicino):
    # la spalla nuda, poi il guanto lungo col bordo
    if v < 0.22:
        return ('l' if x == sinistra + 1 else 's') if vicino else 'S'
    if v < 0.3:
        return 'K' if vicino else 'j'
    return ('J' if x == sinistra + 1 else 'j') if vicino else 'n'

def gamba(t, punti, vicina, stivale, stivale_lontano, colori=gamba_lui):
    celle = traccia(punti, 6)
    def colore(v, x, y):
        return colori(v, x, min(c[0] for c in celle if c[1] == y), vicina)
    disegna(t, celle, colore)
    ax, ay = punti[-1]
    incolla(t, stivale if vicina else stivale_lontano, ax - 2, ay)

def braccio(t, punti, vicino, guanto, colori=braccio_lui, largo=5):
    celle = traccia(punti, largo)
    def colore(v, x, y):
        return colori(v, x, min(c[0] for c in celle if c[1] == y), vicino)
    disegna(t, celle, colore)
    hx, hy = punti[-1]
    g = guanto if vicino else [x.replace('G', 'g').replace('J', 'j').replace('j', 'n') for x in guanto]
    incolla(t, g, hx - 1, hy)


def spada(t, cx, cy, verso, giu=0):
    """Lo spadone a 45 gradi; (cx, cy) e' la guardia. verso=+1: la lama
    scende verso sinistra (di spalle), -1 verso destra (di fronte)."""
    cy += giu
    for y in range(H):
        for x in range(W):
            if verso > 0:
                s, u = (x + y) - (cx + cy), (y - x) - (cy - cx)
            else:
                s, u = (x - y) - (cx - cy), (x + y) - (cx + cy)
            ch = None
            if 2 <= u <= 28 and abs(s) <= 2:
                ch = 'o' if abs(s) == 2 else {-1: 'w', 0: 'c', 1: 'p'}[s]
            elif 29 <= u <= 31 and abs(s) <= 1:
                ch = 'o' if abs(s) == 1 else 'c'
            elif u == 32 and s == 0:
                ch = 'o'
            elif -1 <= u <= 1 and abs(s) <= 4:
                ch = 'o' if abs(s) == 4 or u != 0 else ('c' if s <= 0 else 'p')
            elif -9 <= u <= -2 and abs(s) <= 1:
                ch = 'o' if abs(s) == 1 else ('r' if u % 4 else 'R')
            elif -11 <= u <= -10 and abs(s) <= 2:
                ch = 'o' if abs(s) == 2 or u == -11 else 'c'
            if ch:
                t[y][x] = ch


def elsa_lato(t, giu):
    # di lato dello spadone si vede solo l'elsa, dietro la testa: la lama sta
    # sulla schiena, di taglio, e si confonderebbe con le code della sciarpa
    elsa = traccia([(5, 11 + giu), (8, 17 + giu)], 3)
    disegna(t, elsa, lambda v, x, y: 'r' if y % 2 else 'R')
    pomo = traccia([(4, 10 + giu), (5, 11 + giu)], 3)
    disegna(t, pomo, lambda v, x, y: 'c')


def code_sciarpa(t, onda, giu):
    # le due code della sciarpa, dietro il collo: pendono e ondeggiano col passo
    for punti in (([(12, 22), (8, 24), (5, 28 - onda)]), ([(12, 24), (10, 27), (8 - onda, 31)])):
        c = traccia([(x, y + giu) for x, y in punti], 3)
        disegna(t, c, lambda v, x, y: 'o' if 0.45 < v < 0.55 else ('W' if v > 0.8 else 'w'))
