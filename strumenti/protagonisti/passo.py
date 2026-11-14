# Il passo di lei, fatto coi pezzi del suo disegno (ricalca.py).
#
# Bru: «bisogna migliorare le animazioni di movimento», l'esempio del passo di
# Samarie (Fear and Hunger: Termina), e sul passo a tre pose: «sembra troppo
# un tronco di legno». Il tronco era il corpo tutto d'un pezzo: testa, busto e
# braccia scendevano insieme di un pixel e si muovevano solo le gambe. Ora:
#   - gli otto tempi sono tutti diversi, quelli del passo vero: contatto (il
#     piede davanti tocca terra, il passo e' largo), giu' (il peso ci va
#     sopra: il corpo al punto piu' basso), passaggio (l'altra gamba passa
#     sotto, alzata), su (la spinta sulla punta: il corpo al punto piu' alto);
#     poi lo stesso con l'altra gamba;
#   - la testa segue il busto con un tempo di ritardo, e il ciuffo (davanti e
#     dietro la cresta, di lato la crocchia) segue la testa con un altro: il
#     collo e i capelli si allungano o si schiacciano di un pixel (si ripete o
#     si toglie una riga a meta'), cosi' il disegno resta quello del foglio;
#   - davanti e dietro i fianchi (gli shorts e la cima delle gambe) ondeggiano
#     di un pixel verso la gamba che porta il peso, la testa e le spalle no;
#     di lato si piega un pixel in avanti;
#   - le braccia vanno al contrario delle gambe: davanti e dietro la mano che
#     va avanti scende di due pixel e quella che va indietro sale (l'avambraccio
#     si allunga o si accorcia), di lato il braccio dondola di tre;
#   - di lato la gamba lontana e' piu' scura di quella vicina.
# Davanti e dietro le gambe sono quelle del foglio, separate e allungate o
# accorciate. Di lato il foglio ha gambe corte e tutte e due dello stesso
# scuro: si tengono testa, busto e braccio del foglio, e le gambe si
# disegnano articolate (anca, ginocchio, caviglia; arti.capsula, a spessore
# vero, che regge anche la gamba alzata) coi colori di lei.
from arti import capsula

SOPRA = 1          # una riga vuota in cima al fotogramma: la cresta che salta non si taglia
FIANCO = 2         # colonne vuote ai lati: i fianchi che ondeggiano non si tagliano
COLLO = 3          # le righe del collo, che si allungano o si schiacciano


def ritardo(serie, rispetto=None):
    """la serie un tempo dopo (il ciclo gira), ma mai piu' di un pixel lontana
    da `rispetto` (il pezzo a cui e' attaccata)"""
    rispetto = rispetto or serie
    return tuple(max(r - 1, min(r + 1, serie[t - 1])) for t, r in enumerate(rispetto))


# gli otto tempi: contatto, giu', passaggio, su, e di nuovo con l'altra gamba.
# Il busto scende di un pixel quando il piede tocca terra e prende il peso, e
# risale nel passaggio; la testa fa lo stesso un tempo dopo, il ciuffo un
# tempo dopo ancora: un'onda che sale dal busto ai capelli, mai piu' di un
# pixel fra un pezzo e l'altro
CORPO = (1, 1, 0, 0) * 2                    # quanto scende il busto (+ giu')
TESTA = ritardo(CORPO)                      # un tempo dopo il busto
CIUFFO = ritardo(TESTA)                     # un tempo dopo la testa

# davanti e dietro. Il piede: dove finisce (+ piu' giu', cioe' piu' avanti;
# - alzato); il piede a terra va indietro un pixel a tempo, quello alzato passa
# sotto e torna avanti. L'avambraccio: + piu' lungo (la mano scende, va
# avanti), - piu' corto (va indietro); il braccio va col piede dell'altra parte
PIEDE_S = (2, 1, 0, -1, -1, -2, -3, 0)
PIEDE_D = PIEDE_S[4:] + PIEDE_S[:4]
BRACCIO_S = (-2, -1, 0, 1, 2, 1, 0, -1)
BRACCIO_D = tuple(-b for b in BRACCIO_S)
ONDEGGIA = (0, -1, -1, 0, 0, 1, 1, 0)       # i fianchi verso la gamba che porta il peso
TEMPI = [dict(busto=CORPO[t], testa=TESTA[t], ciuffo=CIUFFO[t], ondeggia=ONDEGGIA[t],
              piedi=(PIEDE_S[t], PIEDE_D[t]), braccia=(BRACCIO_S[t], BRACCIO_D[t]),
              fuori=(1 if PIEDE_S[t] >= 1 else 0, 1 if PIEDE_D[t] >= 1 else 0))
         for t in range(8)]
FERMO = dict(busto=0, testa=0, ciuffo=0, ondeggia=0, piedi=(0, 0), braccia=(0, 0), fuori=(0, 0))
RESPIRO = dict(FERMO, busto=1, testa=1, ciuffo=1)


def ridimensiona(righe, n, minimo=1):
    """una striscia di righe lunga n: si ripete o si toglie la riga a meta'
    (nelle gambe e' il gambale dello stivale, nei capelli e nel collo una riga
    uguale alle vicine)"""
    righe = [list(r) for r in righe]
    while len(righe) < n:
        m = len(righe) // 2
        righe.insert(m, list(righe[m]))
    while len(righe) > max(n, minimo):
        del righe[len(righe) // 2]
    return righe


def ultima_riga(g, c0, c1, da):
    ult = None
    for y in range(da, len(g)):
        if any(g[y][x] is not None for x in range(c0, c1)):
            ult = y
    return ult


def impila(righe, parti, busto, testa, ciuffo):
    """il corpo dalla cima all'anca, coi pezzi spostati: (righe, di che pezzo
    e' ogni riga, la riga dove comincia). Il ciuffo si allunga o si schiaccia
    a meta', il collo pure; la testa e il busto restano come nel foglio. Le
    righe del busto sono (nome, riga del foglio)"""
    c, n, anca = parti["ciuffo"], parti["collo"], parti["anca"]
    pezzi = [(ridimensiona(righe(0, c), c + testa - ciuffo), "ciuffo"),
             (righe(c, n), "testa"),
             (ridimensiona(righe(n, n + COLLO), COLLO + busto - testa), "collo"),
             (righe(n + COLLO, anca), "busto")]
    tutte = [r for p, _ in pezzi for r in p]
    nomi = [nome for p, nome in pezzi for _ in p]
    nomi[len(nomi) - (anca - n - COLLO):] = [("busto", y) for y in range(n + COLLO, anca)]
    return tutte, nomi, anca + busto - len(tutte)


def tempo(g, parti, p):
    """davanti o dietro -> (fotogramma, riga di terra). parti: ciuffo (la
    prima riga sotto la cresta), collo (la prima riga del collo), vita (la
    prima riga degli shorts), anca (la prima riga delle gambe), taglio (la
    prima colonna della gamba destra),
    braccia ((col, col) sinistro, (col, col) destro, (riga, riga) degli
    avambracci). In piedi le gambe finiscono tutte e due sulla riga di terra."""
    w = len(g[0])
    anca, taglio = parti["anca"], parti["taglio"]
    gambe = [(0, taglio, ultima_riga(g, 0, taglio, anca), p["piedi"][0], -p["fuori"][0]),
             (taglio, w, ultima_riga(g, taglio, w, anca), p["piedi"][1], p["fuori"][1])]
    terra = sum(g_[2] for g_ in gambe) // 2
    h = SOPRA + terra + 3
    out = [[None] * (w + 2 * FIANCO) for _ in range(h)]
    (bs0, bs1), (bd0, bd1), (br0, br1) = parti["braccia"]
    busto, dx = p["busto"], p["ondeggia"]

    def metti(x, y, c):
        x, y = x + FIANCO, y + SOPRA
        if c is not None and 0 <= x < len(out[0]) and 0 <= y < h:
            out[y][x] = c

    def braccio(x, y):
        return br0 <= y <= br1 and (bs0 <= x <= bs1 or bd0 <= x <= bd1)

    # le gambe, dall'anca (che scende e ondeggia col busto) fino al piede;
    # prima quella dietro, poi quella davanti; la meta' di sotto della gamba
    # che va avanti va un poco in fuori
    for c0, c1, fine, piede, fuori in sorted(gambe, key=lambda g_: g_[3]):
        righe = ridimensiona([g[y][c0:c1] for y in range(anca, fine + 1)],
                             (terra + piede) - (anca + busto) + 1, 2)
        for j, riga in enumerate(righe):
            spost = fuori if j >= len(righe) // 2 else dx
            for i, c in enumerate(riga):
                metti(c0 + i + spost, anca + busto + j, c)
    # il busto e la testa, senza gli avambracci; dalla vita in giu' ondeggia
    righe, nomi, y0 = impila(lambda a, b: [[None if braccio(x, y) else g[y][x] for x in range(w)]
                                           for y in range(a, b)], parti, busto, p["testa"], p["ciuffo"])
    for j, (riga, nome) in enumerate(zip(righe, nomi)):
        spost = dx if nome[0] == "busto" and nome[1] >= parti["vita"] else 0
        for x, c in enumerate(riga):
            metti(x + spost, y0 + j, c)
    # gli avambracci, piu' lunghi o piu' corti (la riga a meta' del guanto)
    for (c0, c1), allunga in (((bs0, bs1), p["braccia"][0]), ((bd0, bd1), p["braccia"][1])):
        pezzo = ridimensiona([g[y][c0:c1 + 1] for y in range(br0, br1 + 1)], br1 - br0 + 1 + allunga)
        for j, riga in enumerate(pezzo):
            for i, c in enumerate(riga):
                metti(c0 + i, br0 + busto + j, c)
    return out, SOPRA + terra


def ciclo(g, parti):
    """fermo, il respiro e gli otto tempi del passo"""
    return [tempo(g, parti, p) for p in [FERMO, RESPIRO] + TEMPI]


# ---------------------------------------------------------------- di lato

# le gambe nelle quattro pose del passo: per la gamba che va avanti (prima) e
# per l'altra, il ginocchio e la caviglia (dx, dy) dall'anca, e il piede:
# piatto o in punta (col tallone alzato) per terra, appeso (dietro, la punta
# in giu') o alzato (davanti) in aria. Il piede per terra ha la caviglia sulla
# sua riga; quello in aria dove dice la posa
# (Bru: «le gambe quando di lato sono troppo lunghe e rigide»: sono lunghe
# nove pixel dall'anca alla caviglia, come davanti, e il ginocchio e' sempre
# un poco piegato, tranne da ferma)
GAMBE_LATO = {
    "fermo":     (((0, 4), (0, 9), "piatto"), ((0, 4), (0, 9), "piatto")),
    "contatto":  (((2, 4), (4, 9), "piatto"), ((-1, 5), (-4, 9), "punta")),
    "giu":       (((3, 4), (2, 9), "piatto"), ((0, 5), (-3, 7), "appeso")),
    "passaggio": (((1, 4), (0, 9), "piatto"), ((3, 3), (1, 7), "appeso")),
    "su":        (((0, 5), (-2, 9), "punta"), ((3, 4), (4, 8), "alzato")),
}
POSE = ("contatto", "giu", "passaggio", "su")
# il braccio vicino: quanto va avanti (+) o indietro (-) la mano; va al
# contrario della gamba vicina, che va avanti nei primi quattro tempi
MANO = (-3, -2, 0, 2, 3, 2, 0, -2)
TEMPI_LATO = [dict(busto=CORPO[t], testa=TESTA[t], ciuffo=CIUFFO[t], piega=0, mano=MANO[t],
                   gambe=GAMBE_LATO[POSE[t % 4]], vicina_avanti=t < 4)
              for t in range(8)]
FERMO_LATO = dict(busto=0, testa=0, ciuffo=0, piega=0, mano=0, gambe=GAMBE_LATO["fermo"], vicina_avanti=True)
RESPIRO_LATO = dict(FERMO_LATO, busto=1, testa=1, ciuffo=1)
# il piede, guardando a destra; la caviglia e' la colonna 2 della prima riga.
# a chiaro, b base, c scuro, o contorno
PIEDI = {
    "piatto": ["obbbo...", "oabbbbbo", "oooooooo"],
    "alzato": ["obbbo...", "oabbbbbo", "oooooooo"],
    "punta": [".obbo...", ".oabbo..", "..oooo.."],
    "appeso": [".obbo...", ".oabbo..", "..oooo.."],
}


def lato(g, parti, p, colori):
    """di lato -> (fotogramma, riga di terra). parti: ciuffo (la prima riga
    sotto la crocchia), collo (la prima riga del collo), anca (la prima riga
    sotto gli shorts), anche (la x dell'anca vicina e della lontana), terra
    (la riga della suola), braccio (il braccio vicino, {(x, y): colore}: e'
    disegnato a parte, corpo.py). colori: pelle e stivali, dal chiaro allo
    scuro, e il contorno."""
    w = len(g[0])
    anca, terra, busto = parti["anca"], parti["terra"], p["busto"]
    h = SOPRA + terra + 1
    out = [[None] * w for _ in range(h)]
    pelle, stivali, nero = colori["pelle"], colori["stivali"], colori["contorno"]

    def metti(x, y, c):
        y += SOPRA
        if c is not None and 0 <= x < w and 0 <= y < h:
            out[y][x] = c

    def gamba(hx, ginocchio, caviglia, piede, vicina):
        hy = anca - 1 + busto
        ay = terra - 2 if piede in ("piatto", "punta") else hy + caviglia[1]
        punti = [(hx, hy), (hx + ginocchio[0], hy + ginocchio[1]), (hx + caviglia[0], ay)]
        celle = capsula(punti, 2.6)
        sk = pelle[1:3] if vicina else pelle[2:4]
        st = stivali[0:3] if vicina else stivali[2:4] + stivali[3:4]
        for (x, y), v in celle.items():
            riga = [c[0] for c in celle if c[1] == y]
            sx, dx_ = min(riga), max(riga)
            if any((x + a, y + b) not in celle for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                metti(x, y, nero)
            elif v < 0.28:
                metti(x, y, sk[0] if x == sx + 1 else sk[1])
            elif v < 0.36:
                metti(x, y, st[0])
            else:
                metti(x, y, st[0] if x == sx + 1 else (st[2] if x == dx_ - 1 else st[1]))
        ax = hx + caviglia[0]
        for j, riga in enumerate(PIEDI[piede]):
            for i, ch in enumerate(riga):
                if ch != ".":
                    metti(ax - 2 + i, ay + j, {"o": nero, "a": st[0], "b": st[1], "c": st[2]}[ch])

    # prima la gamba lontana, poi la vicina
    avanti, dietro = p["gambe"]
    vicina, lontana = (avanti, dietro) if p["vicina_avanti"] else (dietro, avanti)
    gamba(parti["anche"][1], *lontana, False)
    gamba(parti["anche"][0], *vicina, True)
    # il busto e la testa sopra le gambe (la cima delle gambe sta sotto gli
    # shorts), poi il braccio vicino
    braccio = parti["braccio"]
    r0, r1 = min(y for _, y in braccio), max(y for _, y in braccio)
    tutte, nomi, y0 = impila(lambda a, b: [list(g[y]) for y in range(a, b)],
                             parti, busto, p["testa"], p["ciuffo"])
    for j, (riga, nome) in enumerate(zip(tutte, nomi)):
        spost = p["piega"] if nome[0] != "busto" else 0
        for x, c in enumerate(riga):
            metti(x + spost, y0 + j, c)
    # il braccio dondola dalla spalla: la mano va avanti o indietro di `mano`
    # e, in fondo all'arco, sale di un pixel
    su = 1 if abs(p["mano"]) >= 3 else 0
    for (x, y), c in braccio.items():
        f = (y - r0) / max(1, r1 - r0)
        metti(x + round(p["mano"] * f), y + busto - round(su * f), c)
    return out, SOPRA + terra


def ciclo_di_lato(g, parti, colori):
    return [lato(g, parti, p, colori) for p in [FERMO_LATO, RESPIRO_LATO] + TEMPI_LATO]
