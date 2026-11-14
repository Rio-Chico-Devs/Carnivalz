# IL CORPO DI LEI, ridisegnato pulito sotto la testa del foglio (ricalca.py).
#
# Bru: «le spalle sono troppo indietro», «le braccia sembrano fuse», «rendere
# il disegno più pulito chiaro e definito». Nel ricalco del JPG dal collo in
# giu' era tutto una massa scura: guanti, shorts e stivali dello stesso nero,
# attaccati al busto; di lato il braccio pendeva dietro la schiena. Il corpo
# qui e' disegnato a mano sul foglio di Bru (il top chiaro con lo scollo a V,
# le spalle e le braccia nude, i guanti lunghi, la pancia scoperta, la cintura
# chiara di traverso, gli shorts, le cosce, gli stivali), con le regole della
# pixel art leggibile:
#   - fra il braccio e la vita c'e' aria (un pixel di fondo): la silhouette
#     mostra le braccia anche tutta nera;
#   - ogni materiale ha il suo valore: la pelle e il top chiari, i guanti e gli
#     stivali neri lucidi (una riga di luce a sinistra), gli shorts opachi e
#     viola, la cintura chiara che li stacca dalla pancia;
#   - la luce viene da sinistra in alto, il contorno e' di un pixel, senza
#     doppioni agli angoli e senza pixel isolati;
#   - di lato il braccio pende dalla spalla sotto il collo, sul fianco, un
#     poco dietro la meta' del busto (non dietro la schiena).
# Le lettere: o contorno; P Q R S pelle dalla luce all'ombra; a b c d e f
# capelli, top e cintura (lavanda); s t u guanti e stivali (s la luce); k m n
# shorts; F G H I la fascia; 1 2 3 4 il cerchio d'oro; i l'iride.

def esa(x):
    x = x.lstrip('#')
    return tuple(int(x[i:i + 2], 16) for i in (0, 2, 4))


COLORI = {
    'o': '#1a1230',
    'P': '#e8b48c', 'Q': '#c98d66', 'R': '#9c6448', 'S': '#6c4034',
    'a': '#f4f0ff', 'b': '#dcd4f4', 'c': '#bfb3e4', 'd': '#9d8fca', 'e': '#7a6aa8', 'f': '#574880',
    's': '#4a5470', 't': '#262c3e', 'u': '#141826',
    'k': '#4e4560', 'm': '#3a3448', 'n': '#1e1a28',
    'F': '#f06a86', 'G': '#c8304e', 'H': '#922038', 'I': '#3c0a18',
    '1': '#ffe49a', '2': '#e8b040', '3': '#a8701c', '4': '#5e1226',
    'i': '#4a3060', 'x': '#3a2c58', 'y': '#241a3c', 'z': '#120c22',
}
COLORI = {k: esa(v) for k, v in COLORI.items()}

# davanti e dietro: dalla riga 25 (le spalle) ai piedi (49), larghi 26, la
# meta' sinistra e la destra (la luce da sinistra: la destra e' piu' scura)
DA = 25
DAVANTI = [
    ("....oPQQccQQR", "RQQddQQRo...."),   # 25 le spalle, lo scollo a V fra le spalline
    ("...oPQQScccQR", "RQdddSQRRo..."),   # 26 il braccio nudo, l'ascella, il top
    ("...oPQQSbcccR", "RdddeSQRRo..."),   # 27
    ("...oPQQSbcccd", "ddddeSQRSo..."),   # 28
    ("...oQQRScccdd", "dddeeSRRSo..."),   # 29
    (".osstttoddeee", "eeeefossttuo."),   # 30 il bordo largo del guanto, l'orlo del top
    (".ostttuo.oPQQ", "QQRo.ostttuo."),   # 31 la vita stretta: fra braccio e pancia c'e' aria
    (".osttuo..oPQQ", "QQRo..osttuo."),   # 32 l'avambraccio
    (".osttuo..obbb", "QQRo..osttuo."),   # 33 la cintura, di traverso
    (".osttuo.occcc", "bbbbo.osttuo."),   # 34 i fianchi
    ("ostttuo.okmmm", "cccco.ostttuo"),   # 35 la mano, gli shorts
    ("ostttuo.okmmm", "mmmno.ostttuo"),   # 36
    ("osttuuo.okmmo", "ommno.osttuuo"),   # 37
    (".ooooo..onnno", "onnno..ooooo."),   # 38
    (".........oPQR", "RQRo........."),   # 39 le cosce
    (".........oQQR", "RRSo........."),   # 40
    ("........ossto", "ossto........"),   # 41 il bordo degli stivali
    ("........ostuo", "ostuo........"),   # 42
    ("........ostuo", "ostuo........"),   # 43
    ("........ostuo", "ostuo........"),   # 44
    ("........ostuo", "ostuo........"),   # 45
    ("........ostuo", "ostuo........"),   # 46
    (".......osttuo", "osttuo......."),   # 47 i piedi, verso di noi
    (".......ostuuo", "ostuuo......."),   # 48
    ("........ooooo", "ooooo........"),   # 49
]
DIETRO = [
    ("....oPQQQQQQQ", "QQQQQQQRo...."),   # 25 le spalle e la schiena nude
    ("...oPQQSccccc", "ccccdSQRRo..."),   # 26 la fascia del top sulla schiena
    ("...oPQQSQQQQQ", "QQQQRSQRRo..."),   # 27
    ("...oPQQSbcccc", "cccddSQRSo..."),   # 28 il top
    ("...oQQRSccccc", "ccdddSRRSo..."),   # 29
    (".osstttodddde", "eeeefossttuo."),   # 30
    (".ostttuo.oPQQ", "QQRo.ostttuo."),   # 31 la schiena nuda, la vita stretta
    (".osttuo..oQQQ", "QQRo..osttuo."),   # 32
    (".osttuo..oQQQ", "bbbo..osttuo."),   # 33 la cintura (da dietro scende a sinistra)
    (".osttuo.obbbb", "cccco.osttuo."),   # 34
    ("ostttuo.occcc", "mmmno.ostttuo"),   # 35
    ("ostttuo.okmmm", "mmmno.ostttuo"),   # 36 gli shorts
    ("osttuuo.okmmo", "ommno.osttuuo"),   # 37
    (".ooooo..onnno", "onnno..ooooo."),   # 38
    (".........oQQR", "RQRo........."),   # 39 le cosce
    (".........oQRR", "RRSo........."),   # 40
    ("........ossto", "ossto........"),   # 41
    ("........ostuo", "ostuo........"),   # 42
    ("........ostuo", "ostuo........"),   # 43
    ("........ostuo", "ostuo........"),   # 44
    ("........ostuo", "ostuo........"),   # 45
    ("........ostuo", "ostuo........"),   # 46
    ("........ostuo", "ostuo........"),   # 47 da dietro il piede non si vede: il tacco
    ("........ouuuo", "ouuuo........"),   # 48
    ("........ooooo", "ooooo........"),   # 49
]

# le teste ripassate a mano (ricalca.py mano), sul ricalco: stessa silhouette, stesse ciocche,
# la fascia, il cerchio d'oro, gli occhi scuri a mezze palpebre): Bru, «quei
# puntini sulla bandana fanno solo noise». Tolti i puntini del JPG (pixel
# color shorts nella cresta, pelle nella frangia, contorni doppi), ogni ciocca
# ha la luce a sinistra in alto e l'ombra sotto; la fascia e' liscia
TESTA_DAVANTI = [   # righe 0-24, larga 26
    ".............oo...........",
    "............obo...........",
    "...........obcdooooo......",
    ".........oobbcdbbcdeoo....",
    "........obbbccdbccdeo.....",
    "........obcccdeccddeo.....",
    "........occdddecddeeeo....",
    "........ocddeeeddeefoo....",
    "....oooooddeeefeeffo......",
    "...o1123oFFFFFFFFFFo......",
    "...o1443oGGGGGGGGGGGo.....",
    "...o2443oGGGGGGGGGGGGo....",
    "...o2333oHHHHHHHHHHHHo....",
    "...ooooooefeeddeeeffeo....",
    "...ocbbcdcbbcdcbcddddeo...",
    "...ocbcdebbcdebccdedeo....",
    "...obccdeccdeRccdeedeo....",
    "...obcdeQdcdeRQdeQedeo....",
    "...obcdoooRdeRQoooRdcdo...",
    "..ocbcdRiiRQQQRRiiRdcdeo..",
    "..odcdeRQQQPQQQQQRRedeoo..",
    "...ooeeRQPPQQQQQQRReefo...",
    ".....oefRQQQQQQQQRfeeo....",
    ".....odeeRQQQQQQReedo.....",
    ".....odeefRSSSSRfeeeo.....",
]
TESTA_DIETRO = [   # righe 0-24, larga 26
    "..........ooo.............",
    "..........obo.............",
    ".......ooobcdooo..........",
    "....ooobbbcdbbcdo.........",
    "....ocbbbbbbbbbco.........",
    ".....obbbbbbbbbbdo........",
    ".....odbbbbbbbbbfo........",
    "..oooddbbbbbbbbbfeo.......",
    "....oddcbbbbbbbdfcdo......",
    "....oeddbbbbbbdfccddo.....",
    "....oeedbbbbbbffcccdo.....",
    "....oeeebbbbbdfecccdeo....",
    "...oeeeeebbbbdfdccce4o....",
    "...oeeeeecbbbeddccee4oo...",
    "...FFeeeeddbbfddbeeeo1o...",
    "...GGFFFfeddcfddefFFo2o...",
    "...GGGGGFFFFFFFFFFGGo2o...",
    "...HHGGGGGGGGGGGGGGGo3o...",
    "...oeHHHGGGGGGGGGGHHHoo...",
    "...oeeefHHHHHHHHHHfeeffo..",
    ".oooeeeedfffffffeeeeeooo..",
    "....oeeeeeeeeeeeeeeeo.....",
    ".....offfeeeeeeeeffeo.....",
    "....offfffffffffffffo.....",
    "....offefSQQQQRRSfffo.....",
]
TESTA_LATO = [   # righe 0-24, larga 32, guarda a destra
    ".....oooooooo...................",
    ".....obbbccdo...................",
    "....obbbcccdeo..................",
    "....ocbbccddeo..................",
    "..ooccbccdddeo..................",
    "..occbbcddeeeooooooooo.o........",
    "..occbbcddeffobbbccddo.o........",
    "..occccdeeffedbbbbccdeooooo.....",
    "..odccdeeffedcbbbccdeoooooFFo...",
    "..oedcdeefedcbbbbccdo1123oGGo...",
    "....odcdeedccbbccddeo1443oGGo...",
    "....oecdeedccccdddeeo2443oHHo...",
    "....oeddefedccddeFFFo2333ocdo...",
    "....oeedeedccddFFGGGGoooocbbo...",
    "......oeedddeFFGGGGGHHccbbbco...",
    "......oeedeFFGGGGHHHdccdcbbcdo..",
    "......oeHFFGGGGHHcdedccdccdeo...",
    ".......oHGGGGHHcbcdRQQQRQdeeo...",
    ".......oHGGHHccbccdRoooRQdeoo...",
    ".......oeHHedccbccdRQiiRQeo.....",
    "........ofeedccdddeRQQPQQRo.....",
    "........ofeeedddeeeRQQQQQRo.....",
    "........ooooeeeedeRQQQQRRoo.....",
    "............oeefedfRRRRSo.......",
    "............oeffedfRSSRoo.......",
]

# le misure per il passo (passo.tempo): come nel ricalco, ma sul corpo nuovo
PARTI = dict(anca=39, taglio=13, braccia=((0, 6), (19, 25), (30, 38)), vita=33)

# di lato, guardando a destra: il busto dalla riga 25 all'anca (38), largo 32;
# il braccio vicino a parte (passo.lato lo fa dondolare). Le gambe le disegna
# passo.lato, dall'anca alla riga di terra
LATO_BUSTO = [
    "...............oRQQQQRo.........",   # 25 la base del collo
    ".............oPPQQQQccco........",   # 26 la spalla, il top
    "............occccccccccco.......",   # 27 il top, dalla schiena al seno
    "............obcccccccccddo......",   # 28
    "............obccccccccddeo......",   # 29
    ".............odeeeeeeeefo.......",   # 30 l'orlo del top
    ".............oPQQQQQQQRo........",   # 31 la pancia e la schiena nude
    ".............oPQQQQQQQRo........",   # 32
    ".............oQQQQQQQRRo........",   # 33
    "............obbbbbbbbbbbo.......",   # 34 la cintura
    "............occcccccccddo.......",   # 35
    "............okmmmmmmmmmno.......",   # 36 gli shorts
    "............okmmmmmmmmmno.......",   # 37
    "............onnnnnnnnnnno.......",   # 38
]
LATO_BRACCIO = [
    "................................",   # 25
    "................................",   # 26
    "...............SPQQRS...........",   # 27 il braccio nudo, dalla spalla
    "...............SPQQRS...........",   # 28
    "...............SPQRRS...........",   # 29
    "..............ostttuo...........",   # 30 il bordo del guanto
    "...............osttuo...........",   # 31 l'avambraccio
    "...............osttuo...........",   # 32
    "...............osttuo...........",   # 33
    "...............osttuo...........",   # 34
    "..............ostttuo...........",   # 35 la mano
    "..............ostttuo...........",   # 36
    "..............osttuuo...........",   # 37
    "...............ooooo............",   # 38
]
PARTI_LATO = dict(anca=39, anche=(19, 17), terra=49, ciuffo=5, collo=23)


def griglia(righe, larghe):
    out = []
    for r in righe:
        riga = r[0] + r[1] if isinstance(r, tuple) else r
        assert len(riga) == larghe, (riga, len(riga))
        out.append([None if ch == '.' else COLORI[ch] for ch in riga])
    return out


def pulisci_testa(g, fino, occhi=()):
    """la testa del ricalco com'e', con la sua trama, senza lo sporco del JPG:
    il colore degli shorts finito nei capelli torna viola scuro, la pelle
    sola in mezzo ai capelli, quello che resta dentro la fascia e i toni
    senza nessun vicino uguale prendono il colore piu' frequente intorno. Gli
    occhi restano"""
    capelli = {COLORI[k] for k in 'abcdefxyzi'}
    fascia = {COLORI[k] for k in 'FGHI4'}
    pelle = {COLORI[k] for k in 'PQRS'}
    cambia = {COLORI['m']: COLORI['x'], COLORI['n']: COLORI['y']}
    h, w = len(g), len(g[0])
    g = [[cambia.get(c, c) if y < fino else c for c in r] for y, r in enumerate(g)]

    def c(x, y):
        return g[y][x] if 0 <= x < w and 0 <= y < h else None

    for _ in range(2):
        nuovo = [list(r) for r in g]
        for y in range(fino):
            for x in range(w):
                v = g[y][x]
                if v is None or (x, y) in occhi:
                    continue
                q4 = [c(x + a, y + b) for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))]
                q8 = q4 + [c(x + a, y + b) for a, b in ((1, 1), (-1, -1), (1, -1), (-1, 1))]
                vicini = [q for q in q8 if q in capelli]
                nastro = [q for q in q8 if q in fascia]
                if sum(1 for q in q4 if q in fascia) >= 3 and v not in fascia:
                    # pelle o capelli rimasti in mezzo alla fascia
                    nuovo[y][x] = max(set(nastro), key=nastro.count)
                elif not vicini:
                    continue
                elif v in pelle and sum(1 for q in q4 if q in pelle) <= 1 \
                        and sum(1 for q in q4 if q in capelli | fascia) >= 3:
                    nuovo[y][x] = max(set(vicini), key=vicini.count)
                elif v in capelli and None not in q4 and v not in q8:
                    nuovo[y][x] = max(set(vicini), key=vicini.count)
        g = nuovo
    return g


def rivesti(g, vista, testa="pulita", occhi=()):
    """il corpo disegnato qui (dalla riga DA in giu') sotto la testa: "pulita"
    quella del ricalco (g) senza lo sporco, "fedele" quella del ricalco com'e',
    "mano" quella ripassata a mano"""
    w = len(g[0])
    if vista == "lato":
        corpo, sopra = griglia(LATO_BUSTO, w), TESTA_LATO
    else:
        assert w == 26, w
        corpo = griglia(DAVANTI if vista == "davanti" else DIETRO, 26)
        sopra = TESTA_DAVANTI if vista == "davanti" else TESTA_DIETRO
    if testa == "mano":
        return griglia(sopra, w) + corpo
    g = [list(r) for r in g[:DA]]
    return (pulisci_testa(g, DA, occhi) if testa == "pulita" else g) + corpo


def braccio_di_lato(w):
    """il braccio vicino, di lato: {(x, y): colore}"""
    out = {}
    for j, riga in enumerate(LATO_BRACCIO):
        assert len(riga) == w, (riga, len(riga))
        for x, ch in enumerate(riga):
            if ch != '.':
                out[(x, DA + j)] = COLORI[ch]
    return out
