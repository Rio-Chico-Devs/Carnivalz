# La mappa di un livello presa uguale dal disegno di Bru, pronta per il gioco.
#
#   python3 strumenti/livelli/ricalca_livello.py            tutti i livelli
#   python3 strumenti/livelli/ricalca_livello.py panottico  uno solo
#
# Bru: «riesci a replicare questa mappa? questo è il livello sottostante nella
# grande casa, quello bloccato all'accesso». E' il livello dietro la porta
# enorme oltre l'altare della bambola, nella Casa Gigante, che resta sigillata
# finche' non c'e' il meccanismo del varco (docs/storia.md, «Il Padiglione E e
# la porta enorme»). Bru l'ha fatto con l'AI: «THE SILENT PANOPTICON».
#
# Il disegno e' gia' alla misura del gioco: un pixel dell'immagine e' un pixel
# del mondo, e lei (alta 56) e' alta come le sagome nelle capsule del
# laboratorio. Quindi i pixel si tengono tutti com'erano, colori compresi: a
# ridurli a una tavolozza il vetro delle capsule perdeva l'azzurro e i
# pavimenti si riempivano di puntini. Si toglie solo quello che non e' mappa:
#   - la scacchiera della trasparenza, il titolo, i nomi delle stanze scritti
#     fuori, la bussola e la legenda: tutto quello che sta fuori dalle stanze
#     diventa trasparente (il gioco ci mette il buio);
#   - la scritta sul pavimento del corridoio in alto: al suo posto il
#     pavimento, ripreso dalle piastrelle di sopra (sono alte e larghe 18) e
#     dall'orlo del pavimento a sinistra della scritta.
#
# Le stanze, dove si cammina e le porte sono in art/livelli/<nome>.json:
# quelle le legge il gioco (prove/LivelloProva.gd).
import json
import math
import os
import sys

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(QUI, '..', 'protagonisti'))
import png  # noqa: E402

TRASPARENTE = (0, 0, 0, 0)

LIVELLI = {
    "panottico": dict(
        foglio="panottico.png",
        # le stanze, ognuna col suo muro e un poco della fascia nera intorno
        # (x0, y0, x1, y1, con x1 e y1 fuori). Fra una stanza e la scacchiera
        # la fascia nera e' larga almeno quindici pixel: i rettangoli non ci
        # arrivano.
        stanze=(
            (44, 141, 358, 380),     # la camera stagna
            (146, 128, 240, 141),    # la sua porta in alto, che sporge
            (136, 374, 246, 500),    # dalla camera stagna in giu', al laboratorio
            (352, 190, 1010, 326),   # il corridoio in alto
            (416, 141, 1010, 190),   # il suo muro, dove non c'e' la tacca
            (44, 494, 356, 946),     # il laboratorio
            (350, 650, 568, 886),    # il corridoio di sotto
            (532, 318, 1010, 886),   # il passaggio e la sala centrale
            (550, 886, 1010, 946),   # il fondo della sala (a sinistra c'e' la scacchiera)
        ),
        # la scritta sul pavimento: il rettangolo; dove comincia l'orlo del
        # pavimento; le colonne del passaggio che scende (li' il pavimento
        # continua e l'orlo non c'e'); la colonna da cui si prende l'orlo; da
        # dove in poi sopra la scritta ci sono i piedi dei tubi (li' il
        # pavimento si prende di fianco); le colonne pulite, a sinistra, su
        # cui si misura quanto la luce delle lampade cala scendendo
        scritte=(
            dict(rett=(569, 293, 986, 318), orlo=312, passaggio=(746, 854), riferimento=551,
                 tubi=930, pulito=(380, 569)),
        ),
        piastrella=18,
    ),
    # Le Pianure di Redenna, il primo livello. Bru: «ecco come mi piacerebbe
    # che fosse la mappa delle pianure, creiamola cosi ma riorganiziamola
    # secondo la nostra tabella di marcia, creiamo anche un uscita verso la
    # boss area sia dalla parte della palude dopo l'incontro con la tartaruga
    # che dal promontorio, la grafica la voglio esattamente cosi».
    # Il disegno e' tutto mappa (niente scacchiera): si tiene intero, e il
    # gioco lo ingrandisce due volte (art/livelli/pianure.json, "scala").
    # Si ritocca in due posti soli:
    "pianure": dict(
        foglio="pianure.png",
        # - il riquadro nero col disegno della caverna, accanto all'albero: e'
        #   un'etichetta sopra la mappa, non un posto. Al suo posto: il prato,
        #   riga per riga del verde che ha subito a sinistra, con la grana di
        #   un pezzo di prato vicino; in fondo il muretto che continua da
        #   sinistra; a destra l'albero, col bordo che va su e giu' e dentro
        #   le foglie e le radici prese piu' a destra (dove non c'e' il buco
        #   della caverna)
        riquadri=(
            dict(rett=(544, 395, 634, 476), sinistra=(536, 420, 544, 456), grana=(548, 355, 576, 383),
                 muretto=(471, 60), albero=(613, 62)),
        ),
        # - la scorciatoia: dal bivio il sentiero saliva dritto alla piazzetta
        #   lastricata (l'arena del boss) e la zona del boss si apriva sulla
        #   riva della palude. Secondo la tabella di marcia ci si arriva solo
        #   dopo la tartaruga o dal promontorio: li' si tira una siepe di rovi,
        #   presa dai grovigli che ci sono gia' nella zona corrotta. La siepe
        #   va dalla rupe della palude (a sinistra) alla sporgenza del
        #   promontorio (a destra), e il fondo e' frastagliato.
        rovi=(
            dict(da=(530, 95, 600, 135), dove=(541, 158, 703), fondo=(186, 200),
                 tieni=((624, 134, 642, 187),)),
        ),
    ),
}


def tinta(v):
    return max(0, min(255, int(round(v))))


def cala(g, y, p, colonne):
    """quanto e' piu' scura la riga y di quella una piastrella piu' su, canale
    per canale, misurato sulle colonne pulite"""
    c0, c1 = colonne
    k = []
    for canale in range(3):
        qui = sum(g[y][x][canale] for x in range(c0, c1))
        su = sum(g[y - p][x][canale] for x in range(c0, c1))
        k.append(qui / su if su else 1.0)
    return k


def specchio(i, n):
    """i dentro un pezzo lungo n ripetuto a specchio (0..n-1, n-1..0, ...):
    cosi' fra una copia e l'altra non c'e' lo scalino"""
    i %= 2 * n
    return i if i < n else 2 * n - 1 - i


def scuro(c):
    return c[0] * 0.3 + c[1] * 0.59 + c[2] * 0.11 < 112


def riempi(g, r):
    """un riquadro messo sopra la mappa: al suo posto il prato, il muretto in
    fondo e il bordo dell'albero"""
    x0, y0, x1, y1 = r["rett"]
    gx0, gy0, gx1, gy1 = r["grana"]
    gw, gh = gx1 - gx0, gy1 - gy0
    media = [sum(g[y][x][c] for y in range(gy0, gy1) for x in range(gx0, gx1)) / (gw * gh) for c in range(3)]
    # il verde: quello del prato subito a sinistra (e' quasi uniforme)
    sx0, sy0, sx1, sy1 = r["sinistra"]
    n = (sx1 - sx0) * (sy1 - sy0)
    verde = [sum(g[y][x][c] for y in range(sy0, sy1) for x in range(sx0, sx1)) / n for c in range(3)]
    muro, dx = r["muretto"]
    bordo, dentro = r["albero"]
    for y in range(y0, y1):
        # dove comincia l'albero, riga per riga
        da = bordo + int(round(4 * math.sin(y * 0.13) + 2 * math.sin(y * 0.31 + 2)))
        for x in range(x0, x1):
            if x >= da:
                g[y][x] = g[y][x + dentro]
            elif y >= muro:
                # il muretto continua da sinistra (da sinistra a destra: la
                # sorgente, se e' dentro il riquadro, e' gia' rifatta)
                g[y][x] = g[y][x - dx]
            else:
                s = g[gy0 + specchio(y - y0, gh)][gx0 + specchio(x - x0, gw)]
                g[y][x] = tuple(tinta(verde[c] + s[c] - media[c]) for c in range(3)) + (255,)


def siepe(g, originale, s):
    """una siepe di rovi, coi grovigli presi da un pezzo della zona corrotta e
    ripetuti a specchio; il fondo va su e giu' fra due righe"""
    sx0, sy0, sx1, sy1 = s["da"]
    tw, th = sx1 - sx0, sy1 - sy0
    xa, alto, xb = s["dove"]
    f0, f1 = s["fondo"]
    sfuma = s.get("sfuma", 10)
    for x in range(xa, xb):
        onda = 0.5 + 0.5 * math.sin(x * 0.21) * math.cos(x * 0.077)
        fondo = int(round(f0 + (f1 - f0) * onda))
        for y in range(alto, fondo + 2):
            rovo = originale[sy0 + specchio(y - alto, th)][sx0 + specchio(x - xa, tw)]
            # in cima la siepe sfuma nella zona corrotta che c'e' gia'; in
            # fondo due righe a meta' col prato
            k = min(1.0, (y - alto + 1) / float(sfuma))
            if y >= fondo:
                k = 0.6 if y == fondo else 0.3
            sotto = originale[y][x]
            g[y][x] = tuple(tinta(sotto[c] + (rovo[c] - sotto[c]) * k) for c in range(3)) + (255,)
    # le colonne che ci sono dentro restano davanti (solo i loro pixel: le
    # colonne sono verdi, la zona corrotta no)
    for x0, y0, x1, y1 in s.get("tieni", ()):
        for y in range(y0, y1):
            for x in range(x0, x1):
                c = originale[y][x]
                if c[1] > c[0] + 5:
                    g[y][x] = c


def ricalca(nome):
    l = LIVELLI[nome]
    w, h, pix = png.leggi(os.path.join(QUI, 'fogli', l["foglio"]))
    g = [list(pix[y * w:(y + 1) * w]) for y in range(h)]
    originale = [list(r) for r in g]
    for r in l.get("riquadri", ()):
        riempi(g, r)
    for s in l.get("rovi", ()):
        siepe(g, originale, s)
    p = l.get("piastrella", 1)
    for s in l.get("scritte", ()):
        x0, y0, x1, y1 = s["rett"]
        a, b = s["passaggio"]
        rif = s["riferimento"]
        luce = [cala(g, y, p, s["pulito"]) for y in range(y0, y1)]
        # dall'alto in basso e da sinistra: ogni pixel prende quello una
        # piastrella piu' su (gia' pulito), con la luce un poco piu' bassa
        # come scende quella vera; sotto i tubi quello tre piastrelle piu' a
        # sinistra; sull'orlo, l'orlo a sinistra della scritta
        for y in range(y0, y1):
            for x in range(x0, x1):
                if y < s["orlo"] or a <= x < b:
                    if x >= s["tubi"] and not a <= x < b:
                        g[y][x] = g[y][x - 3 * p]
                    else:
                        r, gg, bb, al = g[y - p][x]
                        k = luce[y - y0]
                        g[y][x] = (tinta(r * k[0]), tinta(gg * k[1]), tinta(bb * k[2]), al)
                else:
                    g[y][x] = g[y][rif + (x - rif) % p]
    # fuori dalle stanze e' trasparente; un livello senza stanze e' tutto mappa
    dentro = [[not l.get("stanze")] * w for _ in range(h)]
    for x0, y0, x1, y1 in l.get("stanze", ()):
        for y in range(y0, y1):
            for x in range(x0, x1):
                dentro[y][x] = True
    fuori = [TRASPARENTE if not dentro[y][x] else (r, gg, bb, 255)
             for y in range(h) for x, (r, gg, bb, _) in enumerate(g[y])]
    cartella = os.path.join(QUI, '..', '..', 'art', 'livelli')
    png.scrivi(os.path.join(cartella, nome + '.png'), w, h, fuori)
    print('scritto', nome, w, h)
    # le cose alte che coprono chi ci passa dietro: i rettangoli stanno nella
    # pianta ("sopra"); dentro si tengono i pixel scuri (chiome e tronchi), il
    # resto e' trasparente
    with open(os.path.join(cartella, nome + '.json')) as f:
        pianta = json.load(f)
    if pianta.get("sopra_mappa"):
        sopra = [TRASPARENTE] * (w * h)
        for x0, y0, x1, y1, _piede in pianta.get("sopra", ()):
            for y in range(y0, y1):
                for x in range(x0, x1):
                    c = g[y][x]
                    if scuro(c) and c[1] >= c[0]:
                        sopra[y * w + x] = (c[0], c[1], c[2], 255)
        png.scrivi(os.path.join(cartella, pianta["sopra_mappa"]), w, h, sopra)
        print('scritto', pianta["sopra_mappa"])


if __name__ == '__main__':
    for nome in (sys.argv[1:] or sorted(LIVELLI)):
        ricalca(nome)
