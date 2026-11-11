# La mappa di un livello presa dal disegno di Bru e fatta pixel art pulita,
# pronta per il gioco.
#
#   python3 strumenti/livelli/ricalca_livello.py            tutti i livelli
#   python3 strumenti/livelli/ricalca_livello.py pianure    uno solo
#
# Scrive, in art/livelli/:
#   <nome>.png         la mappa;
#   <sopra_mappa>      le cose alte (le chiome) che coprono chi ci passa dietro;
#   <passi>            dove si cammina, pixel per pixel (se la pianta lo chiede).
# Le stanze, il pavimento, gli ostacoli e le porte li scrive a mano la pianta,
# art/livelli/<nome>.json; il gioco la legge (prove/LivelloPianta.gd).
#
# Bru, sul primo giro: «come inizio non c'è male, ma bisogna rendere tutto più
# chiaro e bello da vedere per adesso è tutto blurroso, oltre che gli
# ostacoli, colonne, acqua etc devono esserci, quindi concentriamoci a
# migliorare la pixel art per ora per renderla più di qualità». Quindi:
#   - INGRANDITA POCO E SENZA SFUMARE: lo sfocato veniva soprattutto da li'
#     (le Pianure erano ingrandite quattro volte, col JPG dentro). Il gioco
#     ingrandisce a blocchi interi, e meno (art/livelli/<nome>.json).
#   - LA GRANA DEL JPG via: ogni pixel prende la media dei vicini di colore
#     quasi uguale (due volte). I bordi restano, perche' fra due colori
#     diversi non si media.
#   - I CONTORNI un poco piu' netti (si toglie una parte dello sfocato), e nelle
#     Pianure i colori un poco piu' vivi.
#   - DOVE SI CAMMINA pixel per pixel: il pavimento della pianta, meno gli
#     ostacoli, meno l'acqua e le chiome scure riconosciute dal colore
#     (tranne dove la pianta dice che si passa comunque, le scale, e sotto le
#     chiome che le passano davanti: li' bloccano solo i tronchi).
#
# Le cose che non sono mappa si tolgono come prima:
#   - il Panottico: la scacchiera, il titolo, i nomi scritti fuori, la bussola
#     e la legenda; la scritta sul pavimento del corridoio in alto, rifatta con
#     le piastrelle di sopra (sono alte e larghe 18) e con l'orlo del pavimento
#     a sinistra della scritta;
#   - le Pianure: il riquadro nero col disegno della caverna, e la scorciatoia
#     dal bivio all'arena (una siepe di rovi).
import json
import math
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
        pulizia=dict(soglia=10, volte=2, nitidezza=0.5, colori=1.0),
    ),
    # Le Pianure di Redenna, il primo livello. Bru: «ecco come mi piacerebbe
    # che fosse la mappa delle pianure, creiamola cosi ma riorganiziamola
    # secondo la nostra tabella di marcia, creiamo anche un uscita verso la
    # boss area sia dalla parte della palude dopo l'incontro con la tartaruga
    # che dal promontorio, la grafica la voglio esattamente cosi».
    "pianure": dict(
        foglio="pianure.png",
        # - il riquadro nero col disegno della caverna, accanto all'albero: e'
        #   un'etichetta sopra la mappa, non un posto. Al suo posto: il prato
        #   (del verde che ha subito a sinistra, con la grana di un pezzo di
        #   prato vicino); in fondo il muretto che continua da sinistra; a
        #   destra l'albero, col bordo che va su e giu' e dentro le foglie e le
        #   radici prese piu' a destra (dove non c'e' il buco della caverna)
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
        # La griglia: il disegno ha un salto di colore ogni 2 pixel (e' stato
        # ingrandito due volte prima del JPG), e ricalcandolo un pixel ogni 2
        # (sulla_griglia, griglia=(2, 1)) torna di 668x392. Provato: alla
        # grandezza del gioco viene a blocchi e perde il dettaglio delle
        # chiome, del masso e dei muretti. Il disegno intero, pulito, e'
        # piu' bello: si tiene intero.
        pulizia=dict(soglia=10, volte=2, nitidezza=0.5, colori=1.18),
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


def luminanza(c):
    return c[0] * 0.3 + c[1] * 0.59 + c[2] * 0.11


def scuro(c):
    return luminanza(c) < 112


# ---------------------------------------------------------------- i ritocchi

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

def sulla_griglia(g, passo, fase):
    """un pixel per quadretto passo x passo: quello che somiglia di piu' agli
    altri del quadretto (il JPG sporca i quadretti, la media sfocherebbe)"""
    h, w = len(g), len(g[0])
    alto = (h + fase + passo - 1) // passo
    largo = (w + fase + passo - 1) // passo
    out = []
    for j in range(alto):
        riga = []
        ys = [y for y in range(j * passo - fase, (j + 1) * passo - fase) if 0 <= y < h]
        for i in range(largo):
            xs = [x for x in range(i * passo - fase, (i + 1) * passo - fase) if 0 <= x < w]
            quad = [g[y][x] for y in ys for x in xs]
            migliore = min(quad, key=lambda c: sum(abs(c[0] - d[0]) + abs(c[1] - d[1]) + abs(c[2] - d[2]) for d in quad))
            riga.append(migliore)
        out.append(riga)
    return out


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
            c = (R[i], G[i], B[i])
            if p["colori"] != 1.0:
                # un poco piu' vivi: piu' lontani dal grigio, e un poco di
                # contrasto (le ombre scendono, le luci salgono)
                m = (c[0] + c[1] + c[2]) / 3.0
                c = [min(255.0, max(0.0, m + (v - m) * p["colori"])) for v in c]
                c = [tinta((v / 255.0) ** 1.08 * 255 * 1.04) for v in c]
            riga.append((c[0], c[1], c[2], g[y][x][3]))
        out.append(riga)
    return out


# ---------------------------------------------------------------- dove si cammina

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


def acqua(c):
    # l'acqua delle Pianure e' azzurro-verde: il blu supera il rosso, e il
    # verde non supera il blu di molto (nel prato lo supera di venti e passa).
    # Le ombre sul prato hanno lo stesso colore, ma sono molto piu' scure
    return c[2] > c[0] + 8 and c[1] - c[2] < 10 and 85 < luminanza(c) < 165


def chioma(c):
    return luminanza(c) < 96 and c[1] > c[0] + 6


def passi(g, pianta, pixel):
    h, w = len(g), len(g[0])
    si = [[False] * w for _ in range(h)]
    for f in pianta.get("pavimento", ()):
        riempi_forma(si, f, pixel, True)
    sempre = [[False] * w for _ in range(h)]
    for f in pianta.get("si_passa", ()):
        riempi_forma(sempre, f, pixel, True)
    no = [[False] * w for _ in range(h)]
    for f in pianta.get("ostacoli", ()):
        riempi_forma(no, f, pixel, True)
    # sotto le chiome che le passano davanti ("sopra") si cammina: lei ci va
    # dietro, e li' bloccano solo i tronchi (che sono fra gli ostacoli)
    chiome = [[False] * w for _ in range(h)]
    for x0, y0, x1, y1, _piede in pianta.get("sopra", ()):
        riempi_forma(chiome, [x0, y0, x1, y1], pixel, True)
    # acqua e chiome riconosciute dal colore; un pixel da solo non conta
    # (sono i riflessi azzurri dentro i pini, o le foglie scure sul prato):
    # conta se almeno quattro dei suoi otto vicini sono come lui
    blocca = [[False] * w for _ in range(h)]
    for y in range(h):
        for x in range(w):
            c = g[y][x]
            blocca[y][x] = (acqua(c) or (chioma(c) and not chiome[y][x])) and not sempre[y][x]
    out = []
    for y in range(h):
        for x in range(w):
            vicini = 0
            if blocca[y][x]:
                for yy in (y - 1, y, y + 1):
                    for xx in (x - 1, x, x + 1):
                        if (yy != y or xx != x) and 0 <= yy < h and 0 <= xx < w and blocca[yy][xx]:
                            vicini += 1
            ok = si[y][x] and not no[y][x] and not (blocca[y][x] and vicini >= 4)
            out.append((255, 255, 255, 255) if ok else TRASPARENTE)
    return out


# ---------------------------------------------------------------- tutto

def ricalca(nome):
    l = LIVELLI[nome]
    w, h, pix = png.leggi(os.path.join(QUI, 'fogli', l["foglio"]))
    g = [list(pix[y * w:(y + 1) * w]) for y in range(h)]
    originale = [list(r) for r in g]
    for r in l.get("riquadri", ()):
        riempi(g, r)
    for s in l.get("rovi", ()):
        siepe(g, originale, s)
    for s in l.get("scritte", ()):
        scritta(g, s, l.get("piastrella", 1))
    pixel, fase = l.get("griglia", (1, 0))
    if pixel > 1:
        g = sulla_griglia(g, pixel, fase)
    g = pulisci(g, l["pulizia"])
    h, w = len(g), len(g[0])
    # fuori dalle stanze e' trasparente; un livello senza stanze e' tutto mappa
    dentro = [[not l.get("stanze")] * w for _ in range(h)]
    for f in l.get("stanze", ()):
        riempi_forma(dentro, f, pixel, True)
    mappa = [g[y][x] if dentro[y][x] else TRASPARENTE for y in range(h) for x in range(w)]
    cartella = os.path.join(QUI, '..', '..', 'art', 'livelli')
    png.scrivi(os.path.join(cartella, nome + '.png'), w, h, mappa)
    print('scritto', nome, w, h)
    with open(os.path.join(cartella, nome + '.json')) as f:
        pianta = json.load(f)
    # le cose alte che coprono chi ci passa dietro: i rettangoli stanno nella
    # pianta ("sopra", in pixel del disegno); dentro si tengono i pixel scuri
    # (chiome e tronchi), il resto e' trasparente
    if pianta.get("sopra_mappa"):
        sopra = [TRASPARENTE] * (w * h)
        for x0, y0, x1, y1, _piede in pianta.get("sopra", ()):
            for y in range(y0 // pixel, (y1 + pixel - 1) // pixel):
                for x in range(x0 // pixel, (x1 + pixel - 1) // pixel):
                    c = g[y][x]
                    if scuro(c) and c[1] >= c[0]:
                        sopra[y * w + x] = (c[0], c[1], c[2], 255)
        png.scrivi(os.path.join(cartella, pianta["sopra_mappa"]), w, h, sopra)
        print('scritto', pianta["sopra_mappa"])
    if pianta.get("passi"):
        png.scrivi(os.path.join(cartella, pianta["passi"]), w, h, passi(g, pianta, pixel))
        print('scritto', pianta["passi"])


if __name__ == '__main__':
    for nome in (sys.argv[1:] or sorted(LIVELLI)):
        ricalca(nome)
