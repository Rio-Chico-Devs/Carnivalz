# Il passo di lei, fatto coi pezzi del suo disegno (ricalca.py).
#
# Bru: «bisogna migliorare le animazioni di movimento»; e, sul primo giro:
# «già meglio ma bisogna ancora lavorarci un pochino», con l'esempio del passo
# di Samarie (Fear and Hunger: Termina). Quello che lo fa leggere bene:
#   - il ritmo a tre pose: un passo, in piedi, l'altro passo, in piedi;
#   - pose grandi e chiare. Davanti il piede che va avanti scende di due pixel
#     e va un poco in fuori, quello dietro si alza di tre; di lato il passo e'
#     largo, un piede lontano davanti e uno dietro;
#   - nei passi il corpo e' un pixel piu' giu' che in piedi;
#   - le braccia vanno al contrario delle gambe;
#   - di lato la gamba lontana e' piu' scura di quella vicina.
# Davanti e dietro le gambe sono quelle del foglio, separate e allungate o
# accorciate. Di lato il foglio ha gambe corte e tutte e due dello stesso
# scuro: si tengono testa, busto e braccio del foglio, e le gambe si
# disegnano articolate (anca, ginocchio, caviglia; arti.py) coi colori di lei.
from arti import traccia

# davanti e dietro: quanto scende il busto; dove finisce il piede sinistro e
# il destro (+ piu' giu', - alzato); quanto scendono il braccio sinistro e il
# destro; quanto va in fuori il piede sinistro e il destro
POSE = {
    "fermo":   (0, 0, 0, 0, 0, 0, 0),
    "respiro": (1, 0, 0, 0, 0, 0, 0),
    "passo_s": (1, 2, -3, -1, 1, 1, 0),
    "passo_d": (1, -3, 2, 1, -1, 0, 1),
}
# gli otto tempi del foglio del gioco: ogni posa per due tempi
RITMO = ("passo_s", "passo_s", "fermo", "fermo", "passo_d", "passo_d", "fermo", "fermo")


def ridimensiona(righe, n):
    """un pezzo di gamba (lista di righe) lungo n: si ripete o si toglie la
    riga a meta', dove c'e' solo il gambale dello stivale"""
    righe = [list(r) for r in righe]
    while len(righe) < n:
        m = len(righe) // 2
        righe.insert(m, list(righe[m]))
    while len(righe) > max(n, 2):
        del righe[len(righe) // 2]
    return righe


def ultima_riga(g, c0, c1, da):
    ult = None
    for y in range(da, len(g)):
        if any(g[y][x] is not None for x in range(c0, c1)):
            ult = y
    return ult


def tempo(g, parti, busto, piede_s, piede_d, braccio_s, braccio_d, fuori_s=0, fuori_d=0):
    """davanti o dietro -> (fotogramma, riga di terra). parti: anca (la prima
    riga delle gambe), taglio (la prima colonna della gamba destra), braccia
    ((col, col) sinistro, (col, col) destro, (riga, riga)). In piedi le gambe
    finiscono tutte e due sulla riga di terra."""
    w = len(g[0])
    anca, taglio = parti["anca"], parti["taglio"]
    gambe = [(0, taglio, ultima_riga(g, 0, taglio, anca), piede_s, -fuori_s),
             (taglio, w, ultima_riga(g, taglio, w, anca), piede_d, fuori_d)]
    terra = sum(g_[2] for g_ in gambe) // 2
    h = terra + 3
    out = [[None] * w for _ in range(h)]
    (bs0, bs1), (bd0, bd1), (br0, br1) = parti["braccia"]

    def metti(x, y, c):
        if c is not None and 0 <= x < w and 0 <= y < h:
            out[y][x] = c

    # il busto e la testa, senza le braccia
    for y in range(anca):
        for x in range(w):
            if not (br0 <= y <= br1 and (bs0 <= x <= bs1 or bd0 <= x <= bd1)):
                metti(x, y + busto, g[y][x])
    # le braccia, su o giu'; se scendono, sopra si ripete la prima riga
    for (c0, c1), dy in (((bs0, bs1), braccio_s), ((bd0, bd1), braccio_d)):
        for y in range(br0, br1 + 1):
            for x in range(c0, c1 + 1):
                metti(x, y + busto + dy, g[y][x])
        for k in range(max(0, dy)):
            for x in range(c0, c1 + 1):
                metti(x, br0 + busto + k, g[br0][x])
    # le gambe, dall'anca (che scende col busto) fino al piede; la meta' di
    # sotto della gamba che va avanti si sposta un poco in fuori
    for c0, c1, fine, piede, fuori in gambe:
        righe = ridimensiona([g[y][c0:c1] for y in range(anca, fine + 1)],
                             (terra + piede) - (anca + busto) + 1)
        for j, riga in enumerate(righe):
            dx = fuori if j >= len(righe) // 2 else 0
            for i, c in enumerate(riga):
                metti(c0 + i + dx, anca + busto + j, c)
    return out, terra


def ciclo(g, parti):
    """fermo, il respiro e gli otto tempi del passo"""
    return [tempo(g, parti, *POSE[p]) for p in ("fermo", "respiro") + RITMO]


# ---------------------------------------------------------------- di lato

# le gambe: (dx, dy) del ginocchio e della caviglia dall'anca, per la vicina e
# la lontana; il piede (piatto o in punta, col tallone alzato); quanto scende
# il busto; quanto va avanti (+) o indietro (-) la mano del braccio vicino
POSE_LATO = {
    "fermo":   dict(busto=0, vicina=((0, 5), (0, 10)), lontana=((0, 5), (0, 10)),
                    piedi=("piatto", "piatto"), mano=0),
    "respiro": dict(busto=1, vicina=((0, 5), (0, 10)), lontana=((0, 5), (0, 10)),
                    piedi=("piatto", "piatto"), mano=0),
    "passo_v": dict(busto=1, vicina=((3, 5), (6, 9)), lontana=((-2, 5), (-6, 8)),
                    piedi=("piatto", "punta"), mano=-2),
    "passo_l": dict(busto=1, vicina=((-2, 5), (-6, 8)), lontana=((3, 5), (6, 9)),
                    piedi=("punta", "piatto"), mano=2),
}
RITMO_LATO = ("passo_v", "passo_v", "fermo", "fermo", "passo_l", "passo_l", "fermo", "fermo")
# il piede, guardando a destra; la caviglia e' la colonna 2 della prima riga.
# a chiaro, b base, c scuro, o contorno
PIEDI = {
    "piatto": ["obbbo...", "oabbbbbo", "oooooooo"],
    "punta": [".obbo...", ".oabbo..", "..oooo.."],
}


def lato(g, parti, posa, colori):
    """di lato -> (fotogramma, riga di terra). parti: anca (la prima riga
    sotto gli shorts), anche (la x dell'anca vicina e della lontana), terra
    (la riga della suola), braccio (righe e ultima colonna del braccio
    vicino). colori: pelle e stivali, dal chiaro allo scuro, il contorno, e
    guanto(c) che dice se un colore e' del guanto."""
    w, p = len(g[0]), POSE_LATO[posa]
    anca, terra, busto = parti["anca"], parti["terra"], p["busto"]
    h = terra + 1
    out = [[None] * w for _ in range(h)]
    pelle, stivali, nero = colori["pelle"], colori["stivali"], colori["contorno"]

    def gamba(hx, ginocchio, caviglia, piede, vicina):
        hy = anca - 1 + busto
        ay = terra - 2 if piede == "piatto" else terra - 2
        punti = [(hx, hy), (hx + ginocchio[0], hy + (ay - hy) // 2), (hx + caviglia[0], ay)]
        celle = traccia(punti, 6)
        sk = pelle[1:3] if vicina else pelle[2:4]
        st = stivali[0:3] if vicina else stivali[2:4] + stivali[3:4]
        for (x, y), v in celle.items():
            if not (0 <= x < w and 0 <= y < h):
                continue
            riga = [c[0] for c in celle if c[1] == y]
            sx, dx_ = min(riga), max(riga)
            if any((x + a, y + b) not in celle for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                out[y][x] = nero
            elif v < 0.28:
                out[y][x] = sk[0] if x == sx + 1 else sk[1]
            elif v < 0.36:
                out[y][x] = st[0]
            else:
                out[y][x] = st[0] if x == sx + 1 else (st[2] if x == dx_ - 1 else st[1])
        ax = hx + caviglia[0]
        for j, riga in enumerate(PIEDI[piede]):
            for i, ch in enumerate(riga):
                x, y = ax - 2 + i, ay + j
                if ch != "." and 0 <= x < w and 0 <= y < h:
                    out[y][x] = {"o": nero, "a": st[0], "b": st[1], "c": st[2]}[ch]

    # prima la gamba lontana, poi la vicina
    lx, vx = parti["anche"][1], parti["anche"][0]
    gamba(lx, *p["lontana"], p["piedi"][1], False)
    gamba(vx, *p["vicina"], p["piedi"][0], True)
    # il busto e la testa sopra le gambe (la cima delle gambe sta sotto gli
    # shorts); il braccio vicino si piega in avanti o indietro verso la mano
    (r0, r1), ultima = parti["braccio"]
    braccio = {(x, y): g[y][x] for y in range(r0, r1 + 1) for x in range(min(ultima + 1, w))
               if g[y][x] is not None and colori["guanto"](g[y][x])}
    for y in range(anca):
        for x in range(w):
            c = g[y][x]
            if (x, y) in braccio:
                # dietro il braccio c'e' il fianco: il primo colore a destra
                c = next((g[y][k] for k in range(x + 1, w) if (k, y) not in braccio), None)
            if c is not None and 0 <= y + busto < h:
                out[y + busto][x] = c
    for (x, y), c in braccio.items():
        dx = round(p["mano"] * (y - r0) / max(1, r1 - r0))
        if 0 <= x + dx < w and 0 <= y + busto < h:
            out[y + busto][x + dx] = c
    # dietro il braccio il foglio lascia un baffo di contorno, una riga sola
    # che sporge orizzontale: si toglie
    for _ in range(4):
        for y in range(r0 + busto, anca + busto):
            for x in range(w):
                if out[y][x] != nero or out[y - 1][x] is not None or out[y + 1][x] is not None:
                    continue
                if sum(1 for k in (x - 1, x + 1) if 0 <= k < w and out[y][k] is not None) <= 1:
                    out[y][x] = None
    return out, terra


def ciclo_di_lato(g, parti, colori):
    return [lato(g, parti, p, colori) for p in ("fermo", "respiro") + RITMO_LATO]
