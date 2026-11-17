# IL PASSO DI LEI (grande): il fermo, il respiro e i sedici tempi del passo per
# le tre viste, fatti coi pezzi del disegno (corpo.py, lei/*.txt).
#
# Bru sul passo a otto tempi: «there is a black stripe while she walks under
# her belly, it seems like the lower and upper part are detached», «she walks
# too fast», «it seems like only the lower part of the legs moves», «in
# frontal walking she seems more like making little jumps», «a girl walks in a
# more sexy way». Quindi:
#   - il corpo e' tutto d'un pezzo: niente righe ripetute o tolte nel busto
#     (la riga a meta' era l'orlo nero del top: la striscia), niente busto e
#     fianchi in tempi diversi. I fianchi ondeggiano di lato verso la gamba
#     che porta il peso, e la vita li segue a scalini dal petto in giu' (un
#     pixel ogni qualche riga): nessuno scalino netto;
#   - sedici tempi per due passi, e un passo lungo 30 pixel: a 60 pixel al
#     secondo (lei.json, il gioco la fa andare cosi') sono due passi al
#     secondo, come si cammina;
#   - davanti e dietro la gamba si piega al ginocchio: la coscia si accorcia
#     quando il ginocchio viene avanti, il piede in aria si alza, la gamba
#     d'appoggio va di sbieco dal fianco al piede; i piedi vanno verso la
#     linea di mezzo (un piede davanti all'altro), le braccia dondolano;
#   - il corpo scende al massimo di un pixel (davanti e dietro), la coda di
#     cavallo dondola un poco in ritardo;
#   - di lato le gambe sono articolate (gambe.py): il piede a terra va indietro
#     quanto avanza il corpo, cosi' non scivola; il tallone si alza nella
#     spinta, in aria il piede passa piegato. Il corpo scende quanto serve
#     perche' la gamba arrivi a terra (al contatto), e risale. La gamba lontana
#     e' piu' scura e un poco piu' in la' (lei e' vista un poco dall'alto).
import math

import corpo
import gambe

W, H = 64, 112            # un fotogramma
TERRA = 109               # l'origine del nodo, tre righe sopra il fondo: i piedi stanno li'

N = 16                    # i tempi del passo: due passi da otto
CICLO = 60.0              # la strada di un ciclo (due passi), in pixel del mondo
PASSO_PX = CICLO / N      # la strada per tempo (il gioco la legge da lei.json)
VELOCITA = 60.0           # pixel al secondo (lei.json)
APPOGGIO = 0.56           # la parte del ciclo col piede a terra


def liscio(v):
    return v * v * (3 - 2 * v)


def gamba_nel_ciclo(psi):
    """psi: la fase della gamba (0: il piede tocca terra davanti) ->
    (avanti: da +1 a -1 a terra e di nuovo a +1 in aria; alzata 0..1 in aria;
    tallone 0..1 a terra, alla fine (la spinta); in aria: 0..1 o None a terra)"""
    psi %= 1.0
    if psi < APPOGGIO:
        u = psi / APPOGGIO
        return 1 - 2 * u, 0.0, max(0.0, (u - 0.6) / 0.4), None
    v = (psi - APPOGGIO) / (1 - APPOGGIO)
    return -1 + 2 * liscio(v), math.sin(math.pi * v), 0.0, v


def giu_del_corpo(phi):
    """il corpo e' piu' basso quando i piedi sono tutti e due a terra (due volte
    per ciclo), piu' alto a meta' appoggio: 0..1"""
    return 0.5 + 0.5 * math.cos(4 * math.pi * phi)


def ridimensiona(righe, n):
    """una striscia di righe lunga n: si ripete o si toglie la riga a meta'"""
    righe = [list(r) for r in righe]
    while len(righe) < n:
        m = len(righe) // 2
        righe.insert(m, list(righe[m]))
    while len(righe) > max(1, n):
        del righe[len(righe) // 2]
    return righe


def chiudi(pix):
    """il contorno: ogni vuoto che tocca (4 vicini) un pixel pieno non di
    contorno diventa contorno (dove un pezzo si e' staccato dall'altro)"""
    out = dict(pix)
    for (x, y), ch in pix.items():
        if ch != 'o':
            for u, v in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if (u, v) not in pix:
                    out[(u, v)] = 'o'
    return out


def righe_da(tab):
    """{y: (x0, x1)} da [(y0, y1, x0, x1), ...]"""
    return {y: (x0, x1) for y0, y1, x0, x1 in tab for y in range(y0, y1 + 1)}


def per_righe(pix):
    righe = {}
    for (x, y), ch in pix.items():
        righe.setdefault(y, {})[x] = ch
    return righe


def tra(a, b, t):
    return a + (b - a) * t


def corpo_a_righe(out, g, fuori, coda, petto, vita, pancia, p, dx, dy):
    """il corpo senza i pezzi `fuori` (braccia e gambe): la coda di cavallo
    (righe 0..coda: si allunga o si schiaccia e la punta va di lato), la testa
    e il petto (spostati come le spalle), la vita (dalle spalle ai fianchi a
    scalini), i fianchi. Col respiro si toglie la riga `pancia` (pelle): tutto
    quello che sta sopra scende di uno"""
    giu, spalle, fianchi = p['giu'], p['spalle'], p['fianchi']
    coda_dx, coda_giu = p['coda']
    respiro = 1 if p.get('respiro') else 0

    def riga(y):
        return [None if (x, y) in fuori or ch == '.' else ch for x, ch in enumerate(g[y])]
    # la coda: le righe della ciocca, allungate o schiacciate; poi ogni riga va
    # di lato di piu' quanto piu' e' in alto
    ciocca = ridimensiona([riga(y) for y in range(0, coda)], coda + coda_giu)
    righe = []                                   # (riga, spostamento di lato)
    for j, r in enumerate(ciocca):
        righe.append((r, spalle + int(round(coda_dx * (len(ciocca) - j) / len(ciocca)))))
    for y in range(coda, len(g)):
        if respiro and y == pancia:
            continue
        if y < petto:
            s = spalle
        elif y < vita:
            s = int(round(tra(spalle, fianchi, (y - petto + 1) / (vita - petto + 1))))
        else:
            s = fianchi
        righe.append((riga(y), s))
    # i fianchi stanno dove sono (piu' giu'); tutto il resto sopra di loro
    y0 = giu + len(g) - len(righe)
    for j, (r, s) in enumerate(righe):
        for x, ch in enumerate(r):
            if ch is not None:
                out[(x + s + dx, y0 + j + dy)] = ch


# ---------------------------------------------------------------- davanti e dietro

class Vista:
    """davanti o dietro: il corpo a righe, le braccia ({y: (x0, x1)}, la riga
    della spalla e quella del polso, da che parte e' il centro), le gambe (le
    colonne, la riga da cui si cerca la pelle della coscia, le righe che si
    possono ripetere o togliere nella coscia e nello stinco, il ginocchio, la
    caviglia, da che parte e' il centro)"""

    def __init__(self, nome, coda, petto, vita, pancia, braccia, gambe_, dx, dy):
        self.g = corpo.leggi(nome)
        self.coda, self.petto, self.vita, self.pancia = coda, petto, vita, pancia
        self.braccia, self.gambe, self.dx, self.dy = braccia, gambe_, dx, dy
        self.pezzi = {}
        for b in braccia:
            for y, (a, z) in b['righe'].items():
                for x in range(a, z + 1):
                    if self.g[y][x] != '.':
                        self.pezzi[(x, y)] = b['nome']
        for gb in gambe_:
            for x in range(gb['x0'], gb['x1'] + 1):
                pelle = [y for y in range(gb['da'], len(self.g)) if self.g[y][x] in 'PQRST']
                for y in range(pelle[0] if pelle else gb['da'] + 8, len(self.g)):
                    if self.g[y][x] != '.' and (x, y) not in self.pezzi:
                        self.pezzi[(x, y)] = gb['nome']

    def pezzo(self, nome):
        return per_righe({q: self.g[q[1]][q[0]] for q, n in self.pezzi.items() if n == nome})

    def gamba(self, out, gb, mossa):
        """la gamba dal fianco al piede: la coscia accorciata (il ginocchio viene
        avanti), lo stinco allungato o accorciato quanto serve per arrivare al
        piede; di lato a scalini: dal fianco al ginocchio, dal ginocchio al piede"""
        righe = self.pezzo(gb['nome'])
        ys = sorted(righe)
        c0, c1 = gb['coscia']
        s0, s1 = gb['stinco']
        anca_dx, anca_dy = mossa['anca']
        piede_dx, piede_dy = mossa['piede']
        accorcia = mossa['coscia']
        stinco = (piede_dy - anca_dy) + accorcia      # di quanto cambia lo stinco
        x0, x1 = gb['x0'], gb['x1']

        def striscia(da, a):
            return [[righe[y].get(x) if y in righe else None for x in range(x0, x1 + 1)] for y in range(da, a + 1)]
        pezzi = [('coscia', striscia(ys[0], c0 - 1)), ('coscia', ridimensiona(striscia(c0, c1), c1 - c0 + 1 - accorcia)),
                 ('coscia', striscia(c1 + 1, gb['ginocchio'] - 1)), ('stinco', striscia(gb['ginocchio'], s0 - 1)),
                 ('stinco', ridimensiona(striscia(s0, s1), s1 - s0 + 1 + stinco)),
                 ('stinco', striscia(s1 + 1, gb['caviglia'] - 1)), ('piede', striscia(gb['caviglia'], ys[-1]))]
        nuove = [(nome, r) for nome, rr in pezzi for r in rr]
        n_coscia = sum(1 for nome, _ in nuove if nome == 'coscia')
        n_stinco = sum(1 for nome, _ in nuove if nome == 'stinco')
        k = 0
        for j, (nome, r) in enumerate(nuove):
            if nome == 'coscia':
                s = tra(anca_dx, mossa['ginocchio'], j / max(1, n_coscia))
            elif nome == 'stinco':
                s = tra(mossa['ginocchio'], piede_dx, (j - n_coscia) / max(1, n_stinco))
            else:
                s = piede_dx
            s = int(round(s))
            for i, ch in enumerate(r):
                if ch is not None:
                    out[(x0 + i + s + self.dx, ys[0] + anca_dy + j + self.dy)] = ch

    def fotogramma(self, p):
        """p: giu (quanto scende il corpo), spalle e fianchi (di quanto vanno di
        lato), coda (di lato la punta, quanto si allunga), respiro; gambe
        {nome: anca (dx, dy), piede (dx, dy), ginocchio (dx), coscia (di quanto
        si accorcia), avanti}; braccia {nome: (di quanto si allunga
        l'avambraccio, di quanto va di lato la mano)}"""
        out = {}
        # prima la gamba che sta piu' in la'
        for gb in sorted(self.gambe, key=lambda gb_: p['gambe'][gb_['nome']]['dietro']):
            self.gamba(out, gb, p['gambe'][gb['nome']])
        corpo_a_righe(out, self.g, self.pezzi, self.coda, self.petto, self.vita, self.pancia, p, self.dx, self.dy)
        respiro = 1 if p.get('respiro') else 0
        for b in self.braccia:
            allunga, sposta = p['braccia'][b['nome']]
            righe = self.pezzo(b['nome'])
            ys = sorted(righe)
            xa = min(x for r in righe.values() for x in r)
            xb = max(x for r in righe.values() for x in r)
            sopra = [righe[y] for y in ys if y < b['spalla']]
            mezzo = [y for y in ys if b['spalla'] <= y < b['polso']]
            braccio = ridimensiona([[righe[y].get(x) for x in range(xa, xb + 1)] for y in mezzo], len(mezzo) + allunga)
            nuove = sopra + [{xa + i: c for i, c in enumerate(r) if c is not None} for r in braccio] \
                + [righe[y] for y in ys if y >= b['polso']]
            for j, r in enumerate(nuove):
                k = j - len(sopra)          # dalla spalla in giu' a scalini fino alla mano
                s = 0 if k <= 0 else int(round(sposta * min(1.0, k / max(1, len(braccio)))))
                for x, ch in r.items():
                    out[(x + s + p['spalle'] + self.dx, ys[0] + p['giu'] + respiro + j + self.dy)] = ch
        return chiudi(out)


def davanti():
    # lei di fronte (il disegno di Bru col cerchio d'oro spostato a sinistra)
    bs = righe_da([(40, 43, 8, 11), (44, 46, 7, 11), (47, 50, 6, 11), (51, 51, 6, 9), (52, 54, 5, 11),
                   (55, 56, 4, 12), (57, 57, 1, 12), (58, 59, 0, 9), (60, 60, 2, 8), (61, 61, 2, 9),
                   (62, 63, 1, 8), (64, 68, 0, 8), (69, 69, 2, 7), (70, 70, 3, 6)])
    bd = righe_da([(39, 39, 29, 31), (40, 40, 29, 32), (41, 42, 29, 33), (43, 44, 28, 33), (45, 46, 29, 34),
                   (47, 49, 29, 35), (50, 51, 29, 36), (52, 53, 30, 37), (54, 54, 31, 37), (55, 55, 31, 38),
                   (56, 57, 32, 38), (58, 58, 33, 41), (59, 59, 33, 42), (60, 62, 33, 41), (63, 68, 33, 41),
                   (69, 69, 34, 40), (70, 70, 35, 39), (71, 71, 35, 38)])
    gamba = dict(da=64, coscia=(74, 79), ginocchio=81, stinco=(84, 91), caviglia=93)
    return Vista('davanti', coda=10, petto=47, vita=59, pancia=57,
                 braccia=[dict(nome='bs', righe=bs, spalla=47, polso=57, centro=1),
                          dict(nome='bd', righe=bd, spalla=41, polso=58, centro=-1)],
                 gambe_=[dict(gamba, nome='gs', x0=3, x1=20, centro=1),
                         dict(gamba, nome='gd', x0=21, x1=39, centro=-1)],
                 dx=11, dy=7)


def dietro():
    bs = righe_da([(43, 43, 10, 15), (44, 46, 9, 15), (47, 48, 8, 15), (49, 50, 7, 14), (51, 53, 6, 13),
                   (54, 54, 5, 13), (55, 57, 4, 12), (58, 59, 3, 11), (60, 60, 3, 10), (61, 61, 1, 10),
                   (62, 63, 0, 9), (64, 64, 1, 10), (65, 66, 1, 8), (67, 71, 0, 8), (72, 72, 1, 6),
                   (73, 73, 2, 6), (74, 74, 3, 5)])
    bd = righe_da([(43, 43, 31, 35), (44, 45, 31, 36), (46, 47, 31, 37), (48, 48, 32, 37), (49, 50, 32, 38),
                   (51, 52, 32, 39), (53, 54, 31, 39), (55, 55, 32, 40), (56, 57, 33, 40), (58, 58, 33, 41),
                   (59, 59, 34, 41), (60, 60, 35, 42), (61, 63, 35, 44), (64, 66, 35, 43), (67, 71, 35, 44),
                   (72, 72, 36, 44), (73, 73, 37, 42), (74, 74, 39, 41)])
    gamba = dict(da=70, coscia=(79, 83), ginocchio=85, stinco=(86, 95), caviglia=98)
    return Vista('dietro', coda=11, petto=50, vita=61, pancia=59,
                 braccia=[dict(nome='bs', righe=bs, spalla=48, polso=61, centro=1),
                          dict(nome='bd', righe=bd, spalla=48, polso=61, centro=-1)],
                 gambe_=[dict(gamba, nome='gs', x0=5, x1=21, centro=1),
                         dict(gamba, nome='gd', x0=24, x1=40, centro=-1)],
                 dx=10, dy=4)


FONDO = 2.0          # davanti e dietro: il piede avanti e dietro, in righe (avanti e' giu' davanti, su dietro)
ALZA = 4.0           # quanto si alza il piede in aria
CODA_G = 2.5         # quanto si accorcia la coscia col ginocchio in alto
DENTRO = 2           # i piedi verso la linea di mezzo, camminando
FIANCHI = 2.0        # di quanto vanno di lato i fianchi
SPALLE = 0.7         # e le spalle (poco)


def tempo_davanti_dietro(t, verso):
    """verso: +1 davanti (lei viene verso di noi), -1 dietro"""
    phi = t / N
    giu = int(round(giu_del_corpo(phi)))
    fianchi = int(round(FIANCHI * math.sin(2 * math.pi * phi)))
    spalle = int(round(SPALLE * math.sin(2 * math.pi * (phi - 0.06))))
    coda_dx = int(round(1.5 * math.sin(2 * math.pi * (phi - 0.62))))
    coda_giu = int(round(giu_del_corpo(phi - 2.0 / N))) - giu
    gambe_ = {}
    for nome, psi, centro in (('gd', phi, -1), ('gs', phi + 0.5, 1)):
        avanti, alzata, _, aria = gamba_nel_ciclo(psi)
        piede_dx = DENTRO * centro
        gambe_[nome] = dict(
            anca=(fianchi, giu),
            piede=(piede_dx, int(round(FONDO * avanti * verso - ALZA * alzata))),
            ginocchio=(fianchi + piede_dx) / 2.0 + 1.5 * alzata * centro,
            coscia=int(round(CODA_G * alzata)),
            dietro=-avanti * verso)
    # le braccia al contrario delle gambe: la mano a sinistra va avanti con la
    # gamba a destra; avanti la mano scende (davanti) o sale (dietro) e va verso
    # il centro
    a = math.cos(2 * math.pi * phi)
    braccia = {'bs': (int(round(1.5 * a * verso)), int(round(1.5 * a))),
               'bd': (int(round(-1.5 * a * verso)), int(round(1.5 * a)))}
    return dict(giu=giu, fianchi=fianchi, spalle=spalle, coda=(coda_dx, coda_giu), gambe=gambe_, braccia=braccia)


def fermo_davanti_dietro(respiro=False):
    gambe_ = {n: dict(anca=(0, 0), piede=(0, 0), ginocchio=0, coscia=0, dietro=0) for n in ('gs', 'gd')}
    return dict(giu=0, fianchi=0, spalle=0, coda=(0, 1 if respiro else 0), gambe=gambe_,
                braccia={'bs': (0, 0), 'bd': (0, 0)}, respiro=respiro)


# ---------------------------------------------------------------------- di lato
# il braccio vicino (dalla spalla alla mano), e dove stanno le anche e la terra
LATO_BRACCIO = righe_da([(41, 41, 19, 22), (42, 44, 18, 24), (45, 45, 17, 25), (46, 47, 17, 26),
                         (48, 49, 17, 25), (50, 50, 16, 24), (51, 53, 16, 24), (54, 54, 15, 24),
                         (55, 61, 15, 23), (62, 62, 17, 19), (63, 63, 17, 22), (64, 64, 16, 24),
                         (65, 66, 15, 24), (67, 76, 17, 25)])
LATO_DX, LATO_DY = 5, 7
ANCA_V = (27.5 + LATO_DX, 66.5 + LATO_DY)       # l'anca della gamba vicina
ANCA_L = (29.5 + LATO_DX, 64.5 + LATO_DY)       # e della lontana (piu' in la' e piu' avanti)
TERRA_V = 103 + LATO_DY                         # la suola vicina
TERRA_L = TERRA_V - 3                           # e la lontana
# a terra il piede va da AVANTI a AVANTI - APPOGGIO * CICLO (rispetto
# all'anca): piu' indietro che avanti, perche' dietro il tallone alzato allunga
# la gamba
AVANTI = 12.0
DIETRO = AVANTI - APPOGGIO * CICLO
TALLONE = 50.0       # gradi: quanto si alza il tallone nella spinta
ALZA_LATO = 6.0      # quanto si alza il piede in aria
BRACCIO = 5.0        # la mano vicina avanti e indietro


def piede_lato(psi, anca, terra):
    """-> (la caviglia, il beccheggio, le dita piatte per terra)"""
    avanti, alzata, tallone, aria = gamba_nel_ciclo(psi)
    x = tra(DIETRO, AVANTI, (avanti + 1) / 2)
    if aria is None:
        if tallone <= 0:
            return (anca[0] + x, terra - gambe.ALTO_PIEDE), 0.0, False
        b = TALLONE * tallone ** 1.3
        return gambe.caviglia_da_palla((anca[0] + x + gambe.PALLA[0], terra), b), b, True
    # in aria: subito dopo la spinta la punta in giu', poi piatto per toccare
    # terra; la punta non va mai sotto terra
    b = TALLONE * (1 - aria) ** 2 - 4 * aria
    su = ALZA_LATO * alzata
    giu_piede = max(gambe.ruota(q, math.radians(b))[1] for q in gambe.PIEDE + gambe.TACCO)
    return (anca[0] + x, terra - max(gambe.ALTO_PIEDE + su, giu_piede)), b, False


def scendi_per_arrivare(anca, caviglia):
    """quanto deve scendere l'anca perche' la gamba arrivi alla caviglia"""
    lungo = gambe.L1 + gambe.L2 - 0.4
    dx = caviglia[0] - anca[0]
    if abs(dx) >= lungo:
        return 99.0
    return max(0.0, (caviglia[1] - anca[1]) - math.sqrt(lungo * lungo - dx * dx))


class Lato:
    coda, petto, vita, pancia, spalla, polso = 11, 54, 62, 60, 45, 63

    def __init__(self):
        self.g = corpo.leggi('lato')
        self.braccio = {(x, y): self.g[y][x] for y, (a, b) in LATO_BRACCIO.items()
                        for x in range(a, b + 1) if self.g[y][x] != '.'}

    def fotogramma(self, p):
        out = {}
        giu = p['giu']
        for psi, anca, terra, vicina in ((p['lontano'], ANCA_L, TERRA_L, False), (p['vicino'], ANCA_V, TERRA_V, True)):
            anca = (anca[0], anca[1] + giu)
            if psi is None:                                  # da ferma: in piedi
                caviglia, b, dita = (anca[0] + (1 if not vicina else 0), terra - gambe.ALTO_PIEDE), 0.0, False
            else:
                caviglia, b, dita = piede_lato(psi, anca, terra)
            out.update(gambe.contorno(gambe.gamba(anca, caviglia, b, vicina=vicina, dita=dita)))
        corpo_a_righe(out, self.g, self.braccio, self.coda, self.petto, self.vita, self.pancia,
                      dict(giu=giu, spalle=0, fianchi=0, coda=p['coda'], respiro=p.get('respiro')), LATO_DX, LATO_DY)
        # il braccio: dalla spalla in giu' a scalini, fino a `mano` pixel alla mano;
        # tutto avanti o tutto indietro la mano sale di uno (l'arco)
        mano, n = p['mano'], self.polso - self.spalla
        respiro = 1 if p.get('respiro') else 0
        for (x, y), ch in self.braccio.items():
            k = y - self.spalla
            s = 0 if k <= 0 else int(round(mano * min(1.0, k / n)))
            su = -1 if abs(mano) >= 4 and y >= self.polso else 0
            out[(x + s + LATO_DX, y + giu + respiro + su + LATO_DY)] = ch
        return chiudi(out)


def tempo_lato(t):
    phi = t / N
    # il corpo scende un poco ai contatti, e di piu' se serve perche' la gamba
    # a terra ci arrivi
    giu = giu_del_corpo(phi)
    for psi, anca, terra in ((phi, ANCA_V, TERRA_V), (phi + 0.5, ANCA_L, TERRA_L)):
        if gamba_nel_ciclo(psi)[3] is None:
            caviglia, _, _ = piede_lato(psi, anca, terra)
            giu = max(giu, scendi_per_arrivare(anca, caviglia))
    giu = int(math.ceil(giu - 0.05))
    coda_giu = int(round(giu_del_corpo(phi - 2.0 / N))) - int(round(giu_del_corpo(phi)))
    return dict(giu=giu, coda=(0, coda_giu), mano=int(round(-BRACCIO * math.cos(2 * math.pi * phi))),
                vicino=phi, lontano=(phi + 0.5) % 1.0)


def fermo_lato(respiro=False):
    return dict(giu=0, coda=(0, 1 if respiro else 0), mano=0, vicino=None, lontano=None, respiro=respiro)


def foglio():
    """le tre righe del gioco (giu', su, destra): il fermo, il respiro e i
    sedici tempi ({(x, y): lettera} in un fotogramma W x H)"""
    righe = []
    for vista, verso in ((davanti(), 1), (dietro(), -1)):
        righe.append([vista.fotogramma(fermo_davanti_dietro()), vista.fotogramma(fermo_davanti_dietro(True))]
                     + [vista.fotogramma(tempo_davanti_dietro(t, verso)) for t in range(N)])
    lato = Lato()
    righe.append([lato.fotogramma(fermo_lato()), lato.fotogramma(fermo_lato(True))]
                 + [lato.fotogramma(tempo_lato(t)) for t in range(N)])
    return righe
