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


def ricalca(nome):
    l = LIVELLI[nome]
    w, h, pix = png.leggi(os.path.join(QUI, 'fogli', l["foglio"]))
    g = [list(pix[y * w:(y + 1) * w]) for y in range(h)]
    p = l["piastrella"]
    for s in l["scritte"]:
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
    dentro = [[False] * w for _ in range(h)]
    for x0, y0, x1, y1 in l["stanze"]:
        for y in range(y0, y1):
            for x in range(x0, x1):
                dentro[y][x] = True
    fuori = [TRASPARENTE if not dentro[y][x] else (r, gg, bb, 255)
             for y in range(h) for x, (r, gg, bb, _) in enumerate(g[y])]
    uscita = os.path.join(QUI, '..', '..', 'art', 'livelli', nome + '.png')
    png.scrivi(uscita, w, h, fuori)
    print('scritto', nome, w, h)


if __name__ == '__main__':
    for nome in (sys.argv[1:] or sorted(LIVELLI)):
        ricalca(nome)
