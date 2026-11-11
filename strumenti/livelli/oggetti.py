# La libreria degli oggetti dei livelli: i pezzi dei fogli di Bru ricalcati
# pixel per pixel, uno per file, da rimettere nelle mappe.
#
#   python3 strumenti/livelli/oggetti.py
#
# Bru: «ti passo dei disegni cosi vedi più nel particolare come distribuire i
# pixel, siccome il problema attuale è che i pixel sembrano frastagliati e
# sembra proprio ai, invece vorrei che i disegni fossero creati pixel per pixel
# non usando un immagine ma proprio oggetti disegnati in pixel che poi vengono
# riutilizzati nelle mappe».
#
# I fogli (strumenti/livelli/fogli/oggetti_*.png) sono pixel art fatta con
# l'AI: i quadretti non hanno tutti la stessa misura, e il JPG li sporca. Per
# ogni pezzo del foglio (le macchie separate dal fondo grigio):
#   1. si ricalca un pixel ogni 2,5 pixel del foglio: il colore e' quello che
#      somiglia di piu' agli altri del quadretto; se nel quadretto e' piu' il
#      fondo che il pezzo, il pixel e' trasparente, ma solo se quel fondo
#      tocca il fuori del pezzo o e' un buco grande (la luce di un arco): le
#      crepe delle rupi sono grigie quasi come il fondo, e non devono
#      diventare buchi (col contorno venivano crocette nere);
#   2. si mettono tutti i pezzi sulla stessa tavolozza (64 colori, un poco
#      ravvivati), cosi' stanno bene insieme sulla stessa mappa;
#   3. via i pixel soli: un pixel di un colore che nessuno dei quattro vicini
#      ha prende quello dei vicini, se almeno due sono uguali (due volte);
#   4. il contorno: i pixel del bordo prendono il colore piu' scuro della loro
#      tinta (scuro verde per le foglie, scuro marrone per i tronchi...). Le
#      tessere del terreno no: stanno una accanto all'altra (e perdono i due
#      pixel del bordo, che il JPG sporca).
#
# Scrive art/livelli/oggetti/<categoria>/<nome>.png e il catalogo,
# art/livelli/oggetti/catalogo.json: per ogni oggetto la misura, la categoria e
# il piede (il punto per terra, che decide chi sta davanti).
import json
import math
import os
import random
import sys
from collections import deque

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(QUI, '..', 'protagonisti'))
import png  # noqa: E402

PASSO = 2.5            # pixel del foglio per pixel ricalcato
COLORI = 64
RAVVIVA = 1.15         # quanto si allontanano dal grigio i colori della tavolozza
FONDO_TOLLERANZA = 14  # quanto un pixel puo' scostarsi dal grigio del fondo ed essere fondo
PEZZO_MINIMO = 150     # le macchie piu' piccole sono sporco
BUCO_GRANDE = 120      # un buco chiuso piu' grande resta trasparente (la luce di un arco)

# i pezzi di ogni foglio, nell'ordine in cui li trova pezzi_del_foglio (per
# righe di 60 pixel, da sinistra): numero -> (categoria, nome). I pezzi che non
# sono qui si chiamano <foglio>_<numero>, nella categoria del foglio. (Nel
# foglio del terreno le ultime due tessere dei rovi si toccano e fanno un pezzo
# solo, il 69: da li' i numeri sono uno meno di quelli a occhio.)
FOGLI = {
    "terreno": {
        0: ("terreno", "erba_liscia"), 1: ("terreno", "erba_fitta"), 2: ("terreno", "erba_fiori"),
        3: ("terreno", "erba_fiorellini"), 4: ("terreno", "sabbia"), 5: ("terreno", "acqua"),
        6: ("terreno", "rovi_fitti"), 7: ("terreno", "rovi_fitti_2"),
        70: ("rupi", "rupe_curva_1"), 71: ("rupi", "rupe_curva_2"), 72: ("rupi", "terrazze_1"),
        73: ("rupi", "rupe_pilastro"), 74: ("rupi", "rupe_tonda_1"), 75: ("rupi", "rupe_lunga"),
        76: ("rocce", "guglia"), 77: ("rocce", "sassi_1"), 78: ("rocce", "sasso_1"), 79: ("rocce", "sasso_2"),
        80: ("terreno", "sentiero_rupe_1"), 81: ("terreno", "sentiero_rupe_2"),
        82: ("terreno", "ruscello_1"), 83: ("terreno", "ruscello_2"),
        84: ("rupi", "scala_1"), 85: ("rupi", "scala_2"), 86: ("rupi", "rupe_tonda_2"),
        87: ("acqua", "cascata_1"), 88: ("acqua", "cascata_2"), 89: ("acqua", "cascata_3"),
    },
    "alberi": {
        0: ("alberi", "albero_1"), 1: ("alberi", "albero_2"), 2: ("alberi", "albero_3"), 3: ("alberi", "albero_4"),
        4: ("alberi", "albero_grande_1"), 5: ("alberi", "albero_grande_2"),
        6: ("alberi", "pino_1"), 7: ("alberi", "pino_2"), 8: ("alberi", "pino_3"),
        9: ("cespugli", "cespuglio_1"), 10: ("cespugli", "cespuglio_2"), 11: ("cespugli", "felce_1"),
        12: ("cespugli", "felce_2"), 13: ("rovi", "rovo_secco_1"),
        14: ("alberi", "ceppo_1"), 15: ("alberi", "radici_1"), 16: ("alberi", "radici_2"),
        17: ("alberi", "ceppo_2"), 18: ("alberi", "radici_3"),
        19: ("cespugli", "cespuglio_3"), 20: ("cespugli", "cespuglio_4"), 21: ("cespugli", "erba_alta"),
        22: ("rovi", "rovo_secco_2"),
    },
    "palude": {
        0: ("rocce", "cratere"), 1: ("rocce", "masso_bruciato_1"), 4: ("rocce", "masso_bruciato_2"),
        5: ("alberi", "albero_secco_1"), 6: ("alberi", "albero_secco_2"), 7: ("alberi", "albero_secco_3"),
        8: ("rovi", "rovo_grande"), 9: ("rovi", "rovo_anello_1"), 10: ("rovi", "rovo_1"), 11: ("rovi", "rovo_2"),
        12: ("rovi", "rovo_3"), 13: ("rovi", "rovo_basso_1"), 14: ("rovi", "rovo_anello_2"),
        15: ("alberi", "albero_secco_4"), 16: ("alberi", "albero_secco_5"), 17: ("alberi", "albero_secco_6"),
        18: ("rovi", "ricciolo_1"), 19: ("rovi", "ricciolo_2"), 20: ("rovi", "ricciolo_3"),
        21: ("rovi", "rovo_basso_2"), 22: ("rovi", "rovo_basso_3"),
        23: ("acqua", "canne_1"), 24: ("acqua", "canne_2"), 25: ("acqua", "ninfee_fiori"),
        26: ("acqua", "pozza_ninfea_1"), 27: ("acqua", "pozza_ninfea_2"),
        28: ("rocce", "sasso_muschio_1"), 29: ("rocce", "sasso_muschio_2"),
        30: ("terreno", "riva_1"), 31: ("terreno", "riva_2"),
        32: ("acqua", "canne_3"), 33: ("acqua", "canne_4"), 34: ("rocce", "sasso_muschio_3"),
        35: ("acqua", "canne_5"), 36: ("acqua", "pozza_foglie_1"), 37: ("acqua", "pozza_foglie_2"),
        38: ("rocce", "sassi_muschio"), 39: ("rovine", "palo_1"), 40: ("rovine", "palo_2"),
        41: ("rovine", "cippo_1"), 42: ("rovine", "cippo_2"),
    },
    "caverna": {},
    "rovine": {
        0: ("rupi", "rupe_1"), 1: ("rupi", "rupe_2"), 2: ("rupi", "rupe_3"), 3: ("rupi", "rupe_tonda_3"),
        4: ("rupi", "rupe_grande"), 5: ("rupi", "rupe_gradino"), 6: ("rupi", "rupe_curva_3"),
        7: ("rupi", "rupe_curva_4"), 8: ("rupi", "terrazze_2"), 9: ("rupi", "terrazze_3"),
        10: ("rupi", "sporgenza_1"), 11: ("rupi", "sporgenza_2"), 12: ("rupi", "sporgenza_3"),
        13: ("rupi", "scala_dritta"), 14: ("rupi", "scala_3"), 15: ("rupi", "scala_4"),
        16: ("rupi", "scala_5"), 17: ("rupi", "scala_6"), 18: ("rovine", "scala_a_pioli"),
        19: ("rovine", "colonnato"), 20: ("rovine", "colonna"), 21: ("rovine", "colonna_rotta_1"),
        22: ("rovine", "colonna_caduta"), 23: ("rovine", "muro_rotto"), 24: ("rovine", "colonna_rotta_2"),
        25: ("rovine", "arco"), 26: ("rovine", "rilievo_1"), 27: ("rovine", "rilievo_2"),
        28: ("rovine", "blocco"),
        29: ("acqua", "cascata_4"), 30: ("acqua", "cascata_5"), 31: ("acqua", "cascata_6"),
        32: ("acqua", "cascata_7"), 33: ("acqua", "cascata_8"), 34: ("acqua", "cascata_larga"),
        35: ("acqua", "cascata_rupe_1"), 36: ("acqua", "cascata_rupe_2"), 37: ("acqua", "cascata_rupe_3"),
    },
}
# la categoria dei pezzi senza nome, foglio per foglio
SENZA_NOME = {"terreno": "tessere", "alberi": "alberi", "palude": "altro", "caverna": "caverna", "rovine": "altro"}


# ---------------------------------------------------------------- i colori

def lineare(c):
    c /= 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def oklab(rgb):
    r, g, b = (lineare(float(v)) for v in rgb[:3])
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l, m, s = l ** (1 / 3.0), m ** (1 / 3.0), s ** (1 / 3.0)
    return (0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
            1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
            0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s)


def d2(a, b):
    return (a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2


def tinta(v):
    return max(0, min(255, int(round(v))))


# ---------------------------------------------------------------- i pezzi

def pezzi_del_foglio(percorso):
    """le macchie separate dal fondo: (fondo, [(x0, y0, x1, y1)]), in ordine
    per righe di 60 pixel e poi da sinistra"""
    w, h, pix = png.leggi(percorso)
    bordo = [pix[i] for i in range(0, 4 * w)] + [pix[i] for i in range((h - 4) * w, h * w)] \
        + [pix[y * w + x] for y in range(h) for x in (0, 1, 2, 3, w - 4, w - 3, w - 2, w - 1)]
    fondo = tuple(sorted(c[k] for c in bordo)[len(bordo) // 2] for k in range(3))
    pieno = bytearray(w * h)
    for i, c in enumerate(pix):
        if max(abs(c[0] - fondo[0]), abs(c[1] - fondo[1]), abs(c[2] - fondo[2])) > FONDO_TOLLERANZA:
            pieno[i] = 1
    visto = bytearray(w * h)
    scatole = []
    for i in range(w * h):
        if not pieno[i] or visto[i]:
            continue
        visto[i] = 1
        coda = deque([i])
        x0 = x1 = i % w
        y0 = y1 = i // w
        n = 0
        while coda:
            j = coda.popleft()
            n += 1
            x, y = j % w, j // w
            x0, x1, y0, y1 = min(x0, x), max(x1, x), min(y0, y), max(y1, y)
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < w and 0 <= yy < h:
                        k = yy * w + xx
                        if pieno[k] and not visto[k]:
                            visto[k] = 1
                            coda.append(k)
        if n > PEZZO_MINIMO:
            scatole.append((x0, y0, x1 + 1, y1 + 1))
    scatole.sort(key=lambda b: (b[1] // 60, b[0]))
    return (w, h, pix), fondo, scatole


def ricalca(foglio, fondo, scatola):
    """un pixel ogni PASSO: il colore che somiglia di piu' agli altri del
    quadretto, o trasparente se nel quadretto e' piu' il fondo"""
    w, _h, pix = foglio
    x0, y0, x1, y1 = scatola
    larghi, alti = x1 - x0, y1 - y0
    nx, ny = int(math.ceil(larghi / PASSO)), int(math.ceil(alti / PASSO))
    out = []
    for j in range(ny):
        riga = []
        ya, yb = y0 + int(round(j * PASSO)), min(y1, y0 + int(round((j + 1) * PASSO)))
        for i in range(nx):
            xa, xb = x0 + int(round(i * PASSO)), min(x1, x0 + int(round((i + 1) * PASSO)))
            quad = [pix[y * w + x] for y in range(ya, yb) for x in range(xa, xb)]
            pieni = [c for c in quad if max(abs(c[0] - fondo[0]), abs(c[1] - fondo[1]),
                                              abs(c[2] - fondo[2])) > FONDO_TOLLERANZA]
            if not pieni or len(pieni) * 2 < len(quad):
                # fondo, per ora: se poi e' un buchino chiuso dentro il pezzo
                # (una crepa grigia come il fondo) riprende il suo colore
                riga.append(('fondo', min(quad, key=lambda c: sum(d2(c, e) for e in quad))[:3] if quad else None))
                continue
            riga.append(min(pieni, key=lambda c: sum(d2(c, e) for e in pieni))[:3])
        out.append(riga)
    return chiudi_i_buchi(out)


def chiudi_i_buchi(g):
    """trasparente e' solo il fondo che tocca il fuori del pezzo, o i buchi
    grandi (la luce di un arco); i buchini chiusi tornano colore"""
    h, w = len(g), len(g[0])
    fondo = lambda y, x: isinstance(g[y][x], tuple) and len(g[y][x]) == 2 and g[y][x][0] == 'fondo'
    gruppo = [[-1] * w for _ in range(h)]
    gruppi = []
    for y in range(h):
        for x in range(w):
            if not fondo(y, x) or gruppo[y][x] >= 0:
                continue
            k = len(gruppi)
            celle, fuori = [], False
            gruppo[y][x] = k
            coda = deque([(y, x)])
            while coda:
                cy, cx = coda.popleft()
                celle.append((cy, cx))
                for yy, xx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                    if not (0 <= yy < h and 0 <= xx < w):
                        fuori = True
                    elif fondo(yy, xx) and gruppo[yy][xx] < 0:
                        gruppo[yy][xx] = k
                        coda.append((yy, xx))
            gruppi.append((celle, fuori or len(celle) > BUCO_GRANDE))
    out = [r[:] for r in g]
    for celle, vuoto in gruppi:
        for y, x in celle:
            out[y][x] = None if vuoto else g[y][x][1]
    return out


# ---------------------------------------------------------------- la tavolozza

def tavolozza(ricalcati):
    """COLORI colori per tutti i pezzi: k-medie in Oklab sui colori (raggruppati
    in quadretti di 4 livelli per canale, pesati con quanti sono)"""
    conta = {}
    for g in ricalcati:
        for riga in g:
            for c in riga:
                if c is not None:
                    k = (c[0] // 4, c[1] // 4, c[2] // 4)
                    if k in conta:
                        conta[k][0] += 1
                        conta[k][1] = (conta[k][1][0] + c[0], conta[k][1][1] + c[1], conta[k][1][2] + c[2])
                    else:
                        conta[k] = [1, tuple(c)]
    voci = [(n, tuple(s / n for s in somma)) for n, somma in conta.values()]
    lab = [oklab(c) for _n, c in voci]
    peso = [n for n, _c in voci]
    caso = random.Random(7)
    # k-medie++ (pesato), poi k-medie
    centri = [lab[max(range(len(lab)), key=lambda i: peso[i])]]
    dist = [d2(p, centri[0]) for p in lab]
    while len(centri) < COLORI:
        tot = sum(dist[i] * peso[i] for i in range(len(lab)))
        r = caso.random() * tot
        acc = 0.0
        scelto = len(lab) - 1
        for i in range(len(lab)):
            acc += dist[i] * peso[i]
            if acc >= r:
                scelto = i
                break
        centri.append(lab[scelto])
        dist = [min(dist[i], d2(lab[i], lab[scelto])) for i in range(len(lab))]
    for _ in range(25):
        gruppi = [[0.0, 0.0, 0.0, 0.0] for _ in centri]
        for i, p in enumerate(lab):
            k = min(range(len(centri)), key=lambda c: d2(p, centri[c]))
            g = gruppi[k]
            g[0] += p[0] * peso[i]
            g[1] += p[1] * peso[i]
            g[2] += p[2] * peso[i]
            g[3] += peso[i]
        centri = [(g[0] / g[3], g[1] / g[3], g[2] / g[3]) if g[3] else centri[k] for k, g in enumerate(gruppi)]
    # il colore di ogni gruppo: la media in RGB dei suoi colori, ravvivata
    somme = [[0.0, 0.0, 0.0, 0.0] for _ in centri]
    for i, p in enumerate(lab):
        k = min(range(len(centri)), key=lambda c: d2(p, centri[c]))
        n, c = voci[i]
        for ch in range(3):
            somme[k][ch] += c[ch] * n
        somme[k][3] += n
    colori = []
    for s in somme:
        if not s[3]:
            colori.append((0, 0, 0))
            continue
        c = [s[ch] / s[3] for ch in range(3)]
        m = sum(c) / 3.0
        colori.append(tuple(tinta(m + (v - m) * RAVVIVA) for v in c))
    return colori


def pulisci(g, colori, laby, scuro, vicino, contorno=True):
    h, w = len(g), len(g[0])

    def indice(c):
        if c not in vicino:
            lab = oklab(c)
            vicino[c] = min(range(len(colori)), key=lambda k: d2(lab, laby[k]))
        return vicino[c]
    q = [[-1 if c is None else indice(c) for c in riga] for riga in g]
    # via i pixel soli
    for _ in range(2):
        nuovo = [r[:] for r in q]
        for y in range(h):
            for x in range(w):
                c = q[y][x]
                if c < 0:
                    continue
                vicini = [q[yy][xx] for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1))
                          if 0 <= yy < h and 0 <= xx < w and q[yy][xx] >= 0]
                if vicini and c not in vicini:
                    piu = max(set(vicini), key=vicini.count)
                    if vicini.count(piu) >= 2:
                        nuovo[y][x] = piu
        q = nuovo
    if not contorno:
        return [[None if k < 0 else colori[k] for k in riga] for riga in q]
    # il contorno: i pixel del bordo prendono lo scuro della loro tinta
    nuovo = [r[:] for r in q]
    for y in range(h):
        for x in range(w):
            c = q[y][x]
            if c < 0:
                continue
            bordo = any(not (0 <= yy < h and 0 <= xx < w) or q[yy][xx] < 0
                        for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)))
            if bordo and laby[scuro[c]][0] < laby[c][0]:
                nuovo[y][x] = scuro[c]
    q = nuovo
    return [[None if k < 0 else colori[k] for k in riga] for riga in q]


def scuri(laby):
    """per ogni colore, il piu' scuro della stessa tinta (ab vicini); se non ce
    n'e', il piu' scuro di tutti"""
    out = []
    for k, c in enumerate(laby):
        simili = [j for j, e in enumerate(laby)
                  if math.hypot(e[1] - c[1], e[2] - c[2]) < 0.06 and e[0] < c[0] - 0.12]
        out.append(min(simili, key=lambda j: laby[j][0]) if simili else min(range(len(laby)), key=lambda j: laby[j][0]))
    return out


# ---------------------------------------------------------------- tutto

def piede(categoria, w, h):
    """il punto per terra: al centro, in fondo (le tessere del terreno non
    stanno in piedi)"""
    return [w // 2, h - 2]


def main():
    cartella = os.path.join(QUI, '..', '..', 'art', 'livelli', 'oggetti')
    tutti = []
    for foglio in FOGLI:
        img, fondo, scatole = pezzi_del_foglio(os.path.join(QUI, 'fogli', 'oggetti_%s.png' % foglio))
        for k, s in enumerate(scatole):
            categoria, nome = FOGLI[foglio].get(k, (SENZA_NOME[foglio], '%s_%d' % (foglio, k)))
            tutti.append(dict(foglio=foglio, pezzo=k, scatola=s, categoria=categoria, nome=nome,
                              ricalcato=ricalca(img, fondo, s)))
        print(foglio, len(scatole), 'pezzi')
    colori = tavolozza([t["ricalcato"] for t in tutti])
    laby = [oklab(c) for c in colori]
    scuro = scuri(laby)
    catalogo = {"_nota": "Scritto da strumenti/livelli/oggetti.py: non toccare a mano.",
                "tavolozza": ['#%02x%02x%02x' % c for c in colori], "oggetti": {}}
    vicino = {}
    for t in tutti:
        # le tessere del terreno si mettono una accanto all'altra: niente
        # contorno, e via i due pixel del bordo (il JPG li sporca)
        tessera = t["categoria"] in ("terreno", "tessere")
        g = pulisci(t["ricalcato"], colori, laby, scuro, vicino, contorno=not tessera)
        if tessera and len(g) > 8 and len(g[0]) > 8:
            g = [r[2:-2] for r in g[2:-2]]
        # via le righe e le colonne vuote intorno
        righe = [y for y, r in enumerate(g) if any(c is not None for c in r)]
        colonne = [x for x in range(len(g[0])) if any(r[x] is not None for r in g)]
        if not righe:
            continue
        g = [r[colonne[0]:colonne[-1] + 1] for r in g[righe[0]:righe[-1] + 1]]
        h, w = len(g), len(g[0])
        os.makedirs(os.path.join(cartella, t["categoria"]), exist_ok=True)
        file = os.path.join(t["categoria"], t["nome"] + '.png')
        png.scrivi(os.path.join(cartella, file), w, h,
                   [(0, 0, 0, 0) if c is None else c + (255,) for r in g for c in r])
        catalogo["oggetti"][t["nome"]] = {"file": file, "categoria": t["categoria"], "misura": [w, h],
                                          "piede": piede(t["categoria"], w, h),
                                          "foglio": t["foglio"], "pezzo": t["pezzo"]}
    with open(os.path.join(cartella, 'catalogo.json'), 'w') as f:
        json.dump(catalogo, f, indent=1, ensure_ascii=False, sort_keys=True)
        f.write('\n')
    print('scritti', len(catalogo["oggetti"]), 'oggetti')


if __name__ == '__main__':
    main()
