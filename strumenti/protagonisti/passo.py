# IL PASSO DI LEI (grande): il fermo, il respiro e gli otto tempi del passo per
# le tre viste, fatti coi pezzi del disegno (corpo.py, lei/*.txt).
#
# Gli otto tempi: contatto (il piede avanti tocca terra), giu' (il peso ci va
# sopra), passaggio (l'altra gamba passa sotto), su (la spinta); poi lo stesso
# con l'altra gamba. Da Bru, sul passo di prima: «sembra troppo un tronco di
# legno»; quindi ogni parte si muove per conto suo:
#   - i fianchi scendono di uno o due pixel quando il piede prende il peso; le
#     spalle e la testa li seguono un tempo dopo (il busto si allunga o si
#     schiaccia di un pixel: si ripete o si toglie una riga del top), la coda
#     di cavallo un tempo dopo ancora (si allunga o si schiaccia anche lei);
#   - davanti e dietro le gambe sono quelle del disegno, col gambale dello
#     stivale allungato o accorciato: il piede che va avanti scende (davanti) o
#     sale (dietro), quello in aria si alza; le braccia vanno al contrario
#     delle gambe (l'avambraccio si allunga, la mano si sposta di lato);
#   - di lato le gambe sono articolate (gambe.py): il piede a terra va indietro
#     quanto avanza il corpo nel gioco (PASSO_PX, 5 pixel a tempo), cosi' non
#     scivola; dietro si alza sulla punta, in aria passa piegato. La gamba
#     lontana e' piu' scura e un poco piu' in la' (tre righe piu' su: lei e'
#     vista un poco dall'alto). Il braccio dondola dalla spalla.
import corpo
import gambe

W, H = 64, 112            # un fotogramma
TERRA = 109               # l'origine del nodo, tre righe sopra il fondo: i piedi stanno li'

ANCHE = (1, 2, 1, 0, 1, 2, 1, 0)                 # quanto scendono i fianchi nei tempi


def ritardo(serie):
    return tuple(serie[t - 1] for t in range(len(serie)))


SPALLE = ritardo(ANCHE)                          # le spalle e la testa un tempo dopo
CODA = ritardo(SPALLE)                           # la coda di cavallo un tempo dopo ancora


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


def corpo_a_righe(out, g, fuori, coda, taglio, vita, anche, spalle, coda_giu, dx, dy):
    """il corpo senza i pezzi `fuori`, a strisce: la coda di cavallo (righe
    0..coda), la testa e il busto fino al taglio, il resto del busto, i
    fianchi; ognuna allungata o schiacciata quanto serve"""
    def riga(y):
        return [None if (x, y) in fuori or ch == '.' else ch for x, ch in enumerate(g[y])]
    sopra = (ridimensiona([riga(y) for y in range(0, coda)], coda + spalle - coda_giu)
             + [riga(y) for y in range(coda, taglio)]
             + ridimensiona([riga(y) for y in range(taglio, vita)], vita - taglio + anche - spalle))
    y0 = vita + anche - len(sopra)
    for j, r in enumerate(sopra + [riga(y) for y in range(vita, len(g))]):
        for x, ch in enumerate(r):
            if ch is not None:
                out[(x + dx, y0 + j + dy)] = ch


def per_righe(pix):
    righe = {}
    for (x, y), ch in pix.items():
        righe.setdefault(y, {})[x] = ch
    return righe


# ---------------------------------------------------------------- davanti e dietro

class Vista:
    """davanti o dietro: il corpo a righe, le braccia ({y: (x0, x1)}, la riga
    della spalla e quella del polso), le gambe (le colonne, la riga da cui si
    cerca la pelle della coscia, le righe del gambale)"""

    def __init__(self, nome, coda, taglio, vita, braccia, gambe_, dx, dy):
        self.g = corpo.leggi(nome)
        self.coda, self.taglio, self.vita = coda, taglio, vita
        self.braccia, self.gambe, self.dx, self.dy = braccia, gambe_, dx, dy
        self.pezzi = {}
        for nome_b, righe, _, _ in braccia:
            for y, (a, b) in righe.items():
                for x in range(a, b + 1):
                    if self.g[y][x] != '.':
                        self.pezzi[(x, y)] = nome_b
        for nome_g, x0, x1, da, _ in gambe_:
            for x in range(x0, x1 + 1):
                pelle = [y for y in range(da, len(self.g)) if self.g[y][x] in 'PQRST']
                for y in range(pelle[0] if pelle else da + 8, len(self.g)):
                    if self.g[y][x] != '.' and (x, y) not in self.pezzi:
                        self.pezzi[(x, y)] = nome_g

    def pezzo(self, nome):
        return per_righe({p: self.g[p[1]][p[0]] for p, n in self.pezzi.items() if n == nome})

    def fotogramma(self, p):
        """p: anche, spalle, coda (quanto scendono); gambe {nome: (di quanto
        si allunga, di quanto va di lato il piede)}; braccia {nome: (di quanto
        si allunga l'avambraccio, di quanto va di lato la mano)}"""
        out = {}
        anche = p['anche']
        for nome, x0, x1, _, (g0, g1) in self.gambe:
            allunga, sposta = p['gambe'][nome]
            righe = self.pezzo(nome)
            ys = sorted(righe)
            sopra = [righe[y] for y in ys if y < g0]
            gambale = [y for y in ys if g0 <= y <= g1]
            gambale = ridimensiona([[righe[y].get(x) for x in range(x0, x1 + 1)] for y in gambale],
                                   len(gambale) + allunga - anche)
            nuove = sopra + [{x0 + i: c for i, c in enumerate(r) if c is not None} for r in gambale] \
                + [righe[y] for y in ys if y > g1]
            for j, r in enumerate(nuove):
                s = sposta if j >= len(sopra) + len(gambale) // 2 else 0
                for x, ch in r.items():
                    out[(x + s + self.dx, ys[0] + anche + j + self.dy)] = ch
        corpo_a_righe(out, self.g, self.pezzi, self.coda, self.taglio, self.vita, anche, p['spalle'], p['coda'],
                      self.dx, self.dy)
        for nome, _, spalla, polso in self.braccia:
            allunga, sposta = p['braccia'][nome]
            righe = self.pezzo(nome)
            ys = sorted(righe)
            xa = min(x for r in righe.values() for x in r)
            xb = max(x for r in righe.values() for x in r)
            sopra = [righe[y] for y in ys if y < spalla]
            mezzo = [y for y in ys if spalla <= y < polso]
            braccio = ridimensiona([[righe[y].get(x) for x in range(xa, xb + 1)] for y in mezzo], len(mezzo) + allunga)
            nuove = sopra + [{xa + i: c for i, c in enumerate(r) if c is not None} for r in braccio] \
                + [righe[y] for y in ys if y >= polso]
            for j, r in enumerate(nuove):
                k = j - len(sopra)        # dalla spalla in giu' a scalini fino alla mano
                s = 0 if k <= 0 else int(round(sposta * min(1.0, k / max(1, len(braccio)))))
                for x, ch in r.items():
                    out[(x + s + self.dx, ys[0] + p['spalle'] + j + self.dy)] = ch
        return chiudi(out)


def davanti():
    bs = righe_da([(47, 49, 8, 10), (50, 50, 8, 11), (51, 51, 8, 12), (52, 52, 7, 13), (53, 53, 7, 14),
                   (54, 54, 7, 13), (55, 55, 6, 13), (56, 56, 4, 12), (57, 57, 3, 13), (58, 58, 3, 12),
                   (59, 59, 4, 11), (60, 60, 4, 12), (61, 61, 3, 12), (62, 62, 3, 11), (63, 63, 2, 10),
                   (64, 65, 2, 9), (66, 67, 2, 10), (68, 68, 3, 10), (69, 69, 3, 9), (70, 70, 4, 7)])
    bd = righe_da([(37, 44, 26, 36), (45, 46, 28, 37), (47, 49, 29, 39), (50, 52, 30, 40), (53, 54, 32, 41),
                   (55, 56, 33, 42), (57, 57, 34, 43), (58, 72, 34, 44)])
    return Vista('davanti', coda=10, taglio=50, vita=58,
                 braccia=[('bs', bs, 48, 56), ('bd', bd, 41, 58)],
                 gambe_=[('gs', 11, 21, 64, (78, 87)), ('gd', 22, 36, 64, (80, 90))],
                 dx=11, dy=10)


def dietro():
    bs = righe_da([(43, 43, 10, 15), (44, 46, 9, 15), (47, 48, 8, 15), (49, 50, 7, 14), (51, 53, 6, 13),
                   (54, 54, 5, 13), (55, 57, 4, 12), (58, 59, 3, 11), (60, 60, 3, 10), (61, 61, 1, 10),
                   (62, 63, 0, 9), (64, 64, 1, 10), (65, 66, 1, 8), (67, 71, 0, 8), (72, 72, 1, 6),
                   (73, 73, 2, 6), (74, 74, 3, 5)])
    bd = righe_da([(43, 43, 31, 35), (44, 45, 31, 36), (46, 47, 31, 37), (48, 48, 32, 37), (49, 50, 32, 38),
                   (51, 52, 32, 39), (53, 54, 31, 39), (55, 55, 32, 40), (56, 57, 33, 40), (58, 58, 33, 41),
                   (59, 59, 34, 41), (60, 60, 35, 42), (61, 63, 35, 44), (64, 66, 35, 43), (67, 71, 35, 44),
                   (72, 72, 36, 44), (73, 73, 37, 42), (74, 74, 39, 41)])
    return Vista('dietro', coda=11, taglio=52, vita=61,
                 braccia=[('bs', bs, 48, 61), ('bd', bd, 48, 61)],
                 gambe_=[('gs', 10, 21, 70, (82, 92)), ('gd', 24, 36, 70, (82, 92))],
                 dx=10, dy=4)


# Davanti e dietro, il piede: dove finisce (+ giu', - su) rispetto al disegno.
# Davanti (lei viene verso di noi) il piede che va avanti scende; nel disegno la
# gamba destra e' gia' avanti e la sinistra dietro, e il passo parte da li'.
# Dietro i piedi sono pari, e quello che va avanti sale.
FONDO = 2.5                                     # mezzo passo in profondita', in righe
PROF = (1, 0.5, 0, -0.5, -1, -0.5, 0, 0.5)      # la gamba destra: avanti (+) o dietro (-)
ALZA = (0, 0, 0, 0, 0, 2, 3, 1)                 # e quanto e' in aria


def tempi_davanti_dietro(vista):
    tempi = []
    for t in range(8):
        tl = (t + 4) % 8                         # la gamba sinistra, mezzo passo dopo
        if vista == 'davanti':
            gd = (round(FONDO * (PROF[t] - 1) - ALZA[t]), -1 if PROF[t] > 0.6 else 0)
            gs = (round(FONDO * (PROF[tl] + 1) - ALZA[tl]), -1 if PROF[tl] > 0.6 else 0)
            # la mano va avanti (scende e va verso il centro) con la gamba dell'altra parte
            braccia = {'bs': (round(1.5 * PROF[t]), round(-PROF[t])), 'bd': (round(1.5 * PROF[tl]), round(-PROF[tl]))}
        else:
            gd = (round(-FONDO * PROF[t] - ALZA[t]), 0)
            gs = (round(-FONDO * PROF[tl] - ALZA[tl]), 0)
            braccia = {'bs': (round(-1.5 * PROF[t]), 0), 'bd': (round(-1.5 * PROF[tl]), 0)}
        tempi.append(dict(anche=ANCHE[t], spalle=SPALLE[t], coda=CODA[t], gambe={'gs': gs, 'gd': gd},
                          braccia=braccia))
    return tempi


FERMO = dict(anche=0, spalle=0, coda=0, gambe={'gs': (0, 0), 'gd': (0, 0)}, braccia={'bs': (0, 0), 'bd': (0, 0)})
RESPIRO = dict(FERMO, spalle=1, coda=1)


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
PASSO_LATO = 5                                  # quanto avanza il corpo a ogni tempo (PASSO_PX del gioco)
# il piede vicino nei tempi: (posa, x rispetto all'anca, quanto e' in aria, il
# beccheggio: di quanto e' alzato il tallone); la lontana fa lo stesso quattro
# tempi dopo. A terra il piede va indietro di PASSO_LATO a tempo
_P = PASSO_LATO
PIEDE_LATO = [('piatto', 2 * _P, 0, 0), ('piatto', _P, 0, 0), ('piatto', 0, 0, 0), ('punta', -_P, 0, 25),
              ('punta', -2 * _P, 0, 45), ('aria', -_P - 2, 4, 50), ('aria', 0, 6, 30), ('aria', _P + 2, 3, 0)]
MANO_LATO = (-4, -2, 0, 2, 4, 2, 0, -2)         # la mano vicina: + avanti (al contrario della gamba vicina)


def piede_lato(posa, anca, terra):
    """-> (la caviglia, il beccheggio, le dita piatte per terra)"""
    modo, x, su, b = posa
    if modo == 'piatto':
        return (anca[0] + x, terra - gambe.ALTO_PIEDE), 0, False
    if modo == 'punta':
        return gambe.caviglia_da_palla((anca[0] + x + 6, terra), b), b, True
    return (anca[0] + x, terra - gambe.ALTO_PIEDE - su), b, False


class Lato:
    coda, taglio, vita, spalla, polso = 11, 52, 62, 45, 63

    def __init__(self):
        self.g = corpo.leggi('lato')
        self.braccio = {(x, y): self.g[y][x] for y, (a, b) in LATO_BRACCIO.items()
                        for x in range(a, b + 1) if self.g[y][x] != '.'}

    def fotogramma(self, p):
        out = {}
        anche = p['anche']
        for posa, anca, terra, vicina in ((p['lontano'], ANCA_L, TERRA_L, False), (p['vicino'], ANCA_V, TERRA_V, True)):
            anca = (anca[0], anca[1] + anche)
            caviglia, b, dita = piede_lato(posa, anca, terra)
            out.update(gambe.contorno(gambe.gamba(anca, caviglia, b, vicina=vicina, dita=dita)))
        corpo_a_righe(out, self.g, self.braccio, self.coda, self.taglio, self.vita, anche, p['spalle'], p['coda'],
                      LATO_DX, LATO_DY)
        # il braccio: dalla spalla in giu' a scalini, fino a `mano` pixel alla mano;
        # tutto avanti o tutto indietro la mano sale di uno (l'arco)
        mano, n = p['mano'], self.polso - self.spalla
        for (x, y), ch in self.braccio.items():
            k = y - self.spalla
            s = 0 if k <= 0 else int(round(mano * min(1.0, k / n)))
            su = -1 if abs(mano) >= 3 and y >= self.polso else 0
            out[(x + s + LATO_DX, y + p['spalle'] + su + LATO_DY)] = ch
        return chiudi(out)


def tempi_lato():
    return [dict(anche=ANCHE[t], spalle=SPALLE[t], coda=CODA[t], mano=MANO_LATO[t],
                 vicino=PIEDE_LATO[t], lontano=PIEDE_LATO[(t + 4) % 8]) for t in range(8)]


FERMO_LATO = dict(anche=0, spalle=0, coda=0, mano=0, vicino=('piatto', 0, 0, 0), lontano=('piatto', 1, 0, 0))
RESPIRO_LATO = dict(FERMO_LATO, spalle=1, coda=1)


def foglio():
    """le tre righe del gioco (giu', su, destra), dieci fotogrammi ciascuna
    ({(x, y): lettera} in un fotogramma W x H)"""
    righe = []
    for vista, nome in ((davanti(), 'davanti'), (dietro(), 'dietro')):
        righe.append([vista.fotogramma(p) for p in [FERMO, RESPIRO] + tempi_davanti_dietro(nome)])
    lato = Lato()
    righe.append([lato.fotogramma(p) for p in [FERMO_LATO, RESPIRO_LATO] + tempi_lato()])
    return righe
