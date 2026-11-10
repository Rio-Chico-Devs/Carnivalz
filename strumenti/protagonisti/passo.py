# Il passo a otto tempi, fatto coi pezzi di un disegno (ricalca.py per lei).
#
# Bru: «bisogna migliorare le animazioni di movimento». Nel foglio di lei i due
# fotogrammi davanti hanno la stessa posa (la gamba destra avanti in tutti e
# due) e dietro ce n'e' uno solo: cosi' lei non alternava mai le gambe e
# sembrava strisciare. Allora il passo, davanti e dietro, si costruisce coi
# pezzi del disegno:
#   - le due gambe si separano e ognuna si allunga o si accorcia (si ripete o
#     si toglie una riga a meta' dello stivale): quella avanti scende di un
#     pixel (nella vista dall'alto e' piu' vicina a noi), quella che si alza
#     sale di uno o due;
#   - il busto scende di un pixel quando i piedi sono tutti e due a terra e
#     risale nel passaggio;
#   - le braccia vanno al contrario delle gambe: quella che va avanti scende
#     di un pixel, l'altra sale;
#   - il ciuffo segue il busto con un tempo di ritardo.

# busto (quanto scende), piede sinistro e destro (+1 piu' giu', -1 e -2
# alzato), braccio sinistro e destro (quanto scendono)
TEMPI = (
    (1, -1, 1, 1, -1),    # il piede destro tocca terra, avanti
    (1, -2, 0, 1, -1),    # il sinistro si stacca
    (0, -2, 0, 0, 0),     # il sinistro passa
    (0, -1, 0, -1, 1),    # il sinistro va avanti
    (1, 1, -1, -1, 1),    # il piede sinistro tocca terra, avanti
    (1, 0, -2, -1, 1),    # il destro si stacca
    (0, 0, -2, 0, 0),     # il destro passa
    (0, 0, -1, 1, -1),    # il destro va avanti
)
FERMO = (0, 0, 0, 0, 0)
RESPIRO = (1, 0, 0, 0, 0)     # da fermi il busto scende di un pixel, e risale


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


def tempo(g, parti, busto, piede_s, piede_d, braccio_s, braccio_d, ciuffo=0):
    """-> (fotogramma, riga di terra). parti: anca (la prima riga delle
    gambe), taglio (la prima colonna della gamba destra; = larghezza se le
    gambe vanno insieme, come di lato), braccia ((col, col) sinistro,
    (col, col) destro, (riga, riga)) o None, ciuffo (le righe sopra questa
    seguono il busto in ritardo). In piedi le gambe finiscono tutte e due
    sulla riga di terra; il piede avanti va una riga sotto."""
    w = len(g[0])
    anca, taglio = parti["anca"], parti["taglio"]
    gambe = [(c0, c1, ultima_riga(g, c0, c1, anca), piede)
             for c0, c1, piede in ((0, taglio, piede_s), (taglio, w, piede_d)) if c1 > c0]
    gambe = [x for x in gambe if x[2] is not None]
    terra = sum(fine for _, _, fine, _ in gambe) // len(gambe)
    h = terra + 2
    out = [[None] * w for _ in range(h)]
    braccia = parti.get("braccia")
    (bs0, bs1), (bd0, bd1), (br0, br1) = braccia or ((0, -1), (0, -1), (0, -1))
    ciuffo_fino = parti.get("ciuffo", 0)

    def metti(x, y, c):
        if c is not None and 0 <= x < w and 0 <= y < h:
            out[y][x] = c

    # il busto e la testa, senza le braccia; il ciuffo puo' restare indietro
    # (e allora la riga della fascia lo copre: niente buchi)
    for y in range(anca):
        for x in range(w):
            if br0 <= y <= br1 and (bs0 <= x <= bs1 or bd0 <= x <= bd1):
                continue
            metti(x, y + busto + (ciuffo if y < ciuffo_fino else 0), g[y][x])
    # le braccia, su o giu'; se scendono, sopra si ripete la prima riga
    for (c0, c1), dy in (((bs0, bs1), braccio_s), ((bd0, bd1), braccio_d)):
        for y in range(br0, br1 + 1):
            for x in range(c0, c1 + 1):
                metti(x, y + busto + dy, g[y][x])
        for k in range(max(0, dy)):
            for x in range(c0, c1 + 1):
                metti(x, br0 + busto + k, g[br0][x])
    # le gambe, dall'anca (che scende col busto) fino al piede
    for c0, c1, fine, piede in gambe:
        righe = [g[y][c0:c1] for y in range(anca, fine + 1)]
        n = (terra + piede) - (anca + busto) + 1
        for j, riga in enumerate(ridimensiona(righe, n)):
            for i, c in enumerate(riga):
                metti(c0 + i, anca + busto + j, c)
    return out, terra


def ciclo(g, parti):
    """fermo, respiro e gli otto tempi del passo"""
    fotogrammi = [tempo(g, parti, *FERMO), tempo(g, parti, *RESPIRO)]
    for i, t in enumerate(TEMPI):
        # quando il busto risale, il ciuffo resta giu' ancora un tempo
        prima = TEMPI[i - 1][0]
        fotogrammi.append(tempo(g, parti, *t, ciuffo=max(0, prima - t[0])))
    return fotogrammi
