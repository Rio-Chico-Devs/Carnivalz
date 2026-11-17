# IL DISEGNO DI LEI: le tre viste da ferma, pixel per pixel, in lei/*.txt
# (davanti, dietro, lato e il braccio vicino di lato, a parte perche' dondola).
# ricalca.py le passa a passo.py, che ne fa il passo, e scrive il foglio del
# gioco (art/pianeti/protagonista/lei.png).
#
# Bru: prima «no devi farli uguali» (al foglio fogli/lei.png), poi «le braccia
# sembrano fuse», «le spalle sono troppo indietro», «le gambe quando di lato
# sono troppo lunghe e rigide», «quei puntini sulla bandana fanno solo noise»,
# «un compromesso tra prima e adesso» e «lo sprite deve essere perfetto».
# Quindi: la testa e' quella del foglio (il ciuffo a punte, la frangia con la
# ciocca chiara al centro e quella scura fra gli occhi, i capelli larghi ai
# lati, gli occhi scuri a mezze palpebre), ripassata pixel per pixel senza lo
# sporco del JPG; il corpo segue il disegno di lei che ha mandato Bru (la
# fascia cremisi col cerchio d'oro sul lato destro, il girocollo, il top
# lavanda con lo scollo, i guanti lunghi neri lucidi sopra il gomito col bordo
# d'argento, la cintura chiara di traverso con la fibbia, shorts e stivali neri
# lucidi). Le regole della pixel art leggibile:
#   - la silhouette si legge anche tutta nera: fra braccio e vita c'e' aria;
#   - un valore per materiale, la luce da sinistra in alto, il nero lucido con
#     una riga di luce e un riflesso (w);
#   - contorno di un pixel, senza grumi agli angoli, niente pixel isolati
#     tranne i riflessi;
#   - di lato la spalla e' sotto il collo e il braccio a meta' busto, le gambe
#     (le disegna passo.py) lunghe come davanti.
#
# Le lettere: o contorno; a b c d e f lavanda (capelli, top, cintura), y viola
# quasi nero (sotto gli occhi); P Q R S pelle dalla luce all'ombra; F G H la
# fascia; 1 2 3 4 il cerchio d'oro; i l'iride; w s t u v il nero lucido dal
# riflesso all'ombra; g h l'argento.
import os

QUI = os.path.dirname(os.path.abspath(__file__))


def esa(x):
    x = x.lstrip('#')
    return tuple(int(x[i:i + 2], 16) for i in (0, 2, 4))


COLORI = {k: esa(v) for k, v in {
    'o': '#1a1230',
    'a': '#f4f0ff', 'b': '#dcd4f4', 'c': '#bfb3e4', 'd': '#9d8fca', 'e': '#7a6aa8', 'f': '#574880',
    'y': '#241a3c',
    'P': '#e8b48c', 'Q': '#c98d66', 'R': '#9c6448', 'S': '#6c4034',
    'F': '#f06a86', 'G': '#c8304e', 'H': '#922038',
    '1': '#ffe49a', '2': '#e8b040', '3': '#a8701c', '4': '#5e1226',
    'i': '#4a3060',
    'w': '#8a96b8', 's': '#4a5470', 't': '#262c3e', 'u': '#141826', 'v': '#0a0d16',
    'g': '#c4c8dc', 'h': '#7c829c',
}.items()}

DA = 25          # la prima riga del corpo (sotto c'e' la testa)

# le misure per il passo (passo.tempo e passo.lato): la prima riga sotto il
# ciuffo, la prima del collo (la riga a meta' del collo si ripete o si toglie:
# e' quella delle spalle, non quella del girocollo), la vita, l'anca, la prima
# colonna della gamba destra, gli avambracci (colonne e righe)
PARTI = {
    "davanti": dict(ciuffo=9, collo=24, vita=33, anca=39, taglio=13, braccia=((0, 6), (19, 25), (30, 38))),
    "dietro": dict(ciuffo=7, collo=22, vita=33, anca=39, taglio=13, braccia=((0, 6), (19, 25), (30, 38))),
}
# di lato: la x dell'anca vicina e della lontana, la riga della suola
PARTI_LATO = dict(ciuffo=5, collo=22, anca=39, anche=(19, 17), terra=49)


def leggi(nome):
    with open(os.path.join(QUI, 'lei', nome + '.txt')) as f:
        return [r.rstrip('\n') for r in f if r.strip('\n')]


def griglia(righe):
    larga = len(righe[0])
    for j, r in enumerate(righe):
        assert len(r) == larga, (j, len(r))
    return [[None if ch == '.' else COLORI[ch] for ch in r] for r in righe]


def figura(vista, ricalco=None):
    """la vista da ferma ("davanti", "dietro", "lato"); con ricalco (la griglia
    ricalcata dal foglio) la testa del ricalco sul corpo disegnato"""
    g = griglia(leggi(vista))
    if ricalco is not None:
        g = [list(r) for r in ricalco[:DA]] + g[DA:]
    return g


def braccio_di_lato():
    """il braccio vicino, di lato: {(x, y): colore}"""
    return {(x, DA + j): COLORI[ch] for j, r in enumerate(leggi('lato_braccio'))
            for x, ch in enumerate(r) if ch != '.'}
