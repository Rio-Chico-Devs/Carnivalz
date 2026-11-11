# La mappa del Panottico presa dal disegno di Bru e fatta pixel art pulita,
# pronta per il gioco.
#
#   python3 strumenti/livelli/ricalca_livello.py
#
# Scrive art/livelli/<nome>.png, la mappa. Le stanze, il pavimento, gli
# ostacoli e le porte li scrive a mano la pianta, art/livelli/<nome>.json; il
# gioco la legge (prove/LivelloPianta.gd).
#
# Le Pianure non passano piu' di qui: sono composte coi pezzi della libreria
# (strumenti/livelli/compone.py), come Bru ha chiesto («vorrei che i disegni
# fossero creati pixel per pixel non usando un immagine»).
#
# Bru, sul primo giro: «come inizio non c'è male, ma bisogna rendere tutto più
# chiaro e bello da vedere per adesso è tutto blurroso». Quindi:
#   - INGRANDITA POCO E SENZA SFUMARE: il gioco ingrandisce a blocchi interi
#     (art/livelli/<nome>.json).
#   - LA GRANA DEL JPG via: ogni pixel prende la media dei vicini di colore
#     quasi uguale (due volte). I bordi restano, perche' fra due colori
#     diversi non si media.
#   - I CONTORNI un poco piu' netti (si toglie una parte dello sfocato).
#
# Le cose che non sono mappa si tolgono: la scacchiera, il titolo, i nomi
# scritti fuori, la bussola e la legenda; la scritta sul pavimento del
# corridoio in alto, rifatta con le piastrelle di sopra (sono alte e larghe 18)
# e con l'orlo del pavimento a sinistra della scritta.
import os
import sys

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(QUI, '..', 'protagonisti'))
import png  # noqa: E402

TRASPARENTE = (0, 0, 0, 0)

LIVELLI = {
    # Il Panottico silenzioso. Bru: «riesci a replicare questa mappa? questo è
    # il livello sottostante nella grande casa, quello bloccato all'accesso».
    # E' il livello dietro la porta enorme oltre l'altare della bambola, nella
    # Casa Gigante (docs/storia.md, «Il Padiglione E e la porta enorme»). Bru
    # l'ha fatto con l'AI: «THE SILENT PANOPTICON». Un pixel del disegno e' un
    # pixel del mondo: lei (alta 56) e' alta come le sagome nelle capsule.
    "panottico": dict(
        foglio="panottico.png",
        # le stanze, ognuna col suo muro e un poco della fascia nera intorno
        # (x0, y0, x1, y1, con x1 e y1 fuori). Fra una stanza e la scacchiera
        # la fascia nera e' larga almeno quindici pixel: i rettangoli non ci
        # arrivano. Fuori e' trasparente (il gioco ci mette il buio).
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
        pulizia=dict(soglia=10, volte=2, nitidezza=0.5),
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


# ---------------------------------------------------------------- i ritocchi


def scritta(g, s, p):
    """una scritta sul pavimento: al suo posto il pavimento"""
    x0, y0, x1, y1 = s["rett"]
    a, b = s["passaggio"]
    rif = s["riferimento"]
    luce = [cala(g, y, p, s["pulito"]) for y in range(y0, y1)]
    # dall'alto in basso e da sinistra: ogni pixel prende quello una
    # piastrella piu' su (gia' pulito), con la luce un poco piu' bassa come
    # scende quella vera; sotto i tubi quello tre piastrelle piu' a sinistra;
    # sull'orlo, l'orlo a sinistra della scritta
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


# ---------------------------------------------------------------- la pixel art

def canali(g):
    h, w = len(g), len(g[0])
    return ([c[0] for r in g for c in r], [c[1] for r in g for c in r], [c[2] for r in g for c in r], w, h)


def liscia(R, G, B, w, h, soglia):
    """ogni pixel prende la media dei vicini (3x3) di colore quasi uguale: la
    grana del JPG se ne va, i bordi restano"""
    nR, nG, nB = R[:], G[:], B[:]
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            i = y * w + x
            r0, g0, b0 = R[i], G[i], B[i]
            sr = sg = sb = n = 0
            for j in (i - w - 1, i - w, i - w + 1, i - 1, i, i + 1, i + w - 1, i + w, i + w + 1):
                r, gg, b = R[j], G[j], B[j]
                if -soglia <= r - r0 <= soglia and -soglia <= gg - g0 <= soglia and -soglia <= b - b0 <= soglia:
                    sr += r
                    sg += gg
                    sb += b
                    n += 1
            nR[i], nG[i], nB[i] = (sr + n // 2) // n, (sg + n // 2) // n, (sb + n // 2) // n
    return nR, nG, nB


def nitida(C, w, h, quanto):
    """toglie una parte dello sfocato: il pixel meno la media pesata dei vicini"""
    out = C[:]
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            i = y * w + x
            media = (4 * C[i] + 2 * (C[i - 1] + C[i + 1] + C[i - w] + C[i + w])
                     + C[i - w - 1] + C[i - w + 1] + C[i + w - 1] + C[i + w + 1]) / 16.0
            out[i] = tinta(C[i] + quanto * (C[i] - media))
    return out


def pulisci(g, p):
    R, G, B, w, h = canali(g)
    for _ in range(p["volte"]):
        R, G, B = liscia(R, G, B, w, h, p["soglia"])
    R, G, B = (nitida(C, w, h, p["nitidezza"]) for C in (R, G, B))
    out = []
    for y in range(h):
        riga = []
        for x in range(w):
            i = y * w + x
            riga.append((R[i], G[i], B[i], g[y][x][3]))
        out.append(riga)
    return out


# ---------------------------------------------------------------- le stanze

def riempi_forma(maschera, f, pixel, valore):
    """un rettangolo [x0, y0, x1, y1] o un poligono [[x, y], ...] della pianta
    (in pixel del disegno) sulla maschera (in pixel della mappa): conta il
    centro di ogni pixel"""
    h, w = len(maschera), len(maschera[0])
    if not isinstance(f[0], list):
        x0, y0, x1, y1 = f
        for y in range(h):
            cy = (y + 0.5) * pixel
            if y0 <= cy < y1:
                for x in range(w):
                    if x0 <= (x + 0.5) * pixel < x1:
                        maschera[y][x] = valore
        return
    punti = [(float(p[0]), float(p[1])) for p in f]
    for y in range(h):
        cy = (y + 0.5) * pixel
        tagli = []
        for k in range(len(punti)):
            (ax, ay), (bx, by) = punti[k], punti[(k + 1) % len(punti)]
            if (ay <= cy < by) or (by <= cy < ay):
                tagli.append(ax + (cy - ay) * (bx - ax) / (by - ay))
        tagli.sort()
        for a, b in zip(tagli[0::2], tagli[1::2]):
            for x in range(w):
                if a <= (x + 0.5) * pixel < b:
                    maschera[y][x] = valore


# ---------------------------------------------------------------- tutto

def ricalca(nome):
    l = LIVELLI[nome]
    w, h, pix = png.leggi(os.path.join(QUI, 'fogli', l["foglio"]))
    g = [list(pix[y * w:(y + 1) * w]) for y in range(h)]
    for s in l.get("scritte", ()):
        scritta(g, s, l.get("piastrella", 1))
    g = pulisci(g, l["pulizia"])
    # fuori dalle stanze e' trasparente
    dentro = [[False] * w for _ in range(h)]
    for f in l["stanze"]:
        riempi_forma(dentro, f, 1, True)
    mappa = [g[y][x] if dentro[y][x] else TRASPARENTE for y in range(h) for x in range(w)]
    cartella = os.path.join(QUI, '..', '..', 'art', 'livelli')
    png.scrivi(os.path.join(cartella, nome + '.png'), w, h, mappa)
    print('scritto', nome, w, h)


if __name__ == '__main__':
    for nome in (sys.argv[1:] or sorted(LIVELLI)):
        ricalca(nome)
