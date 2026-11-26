"""Lei salta la corda (di fronte), in loop: 8 fotogrammi, un giro di corda per salto.
uso: corda.py davanti_ferma.png striscia.png anteprima.gif foglio.png"""
import sys, math
import numpy as np
from PIL import Image
src0 = np.asarray(Image.open(sys.argv[1]).convert('RGBA')).copy()
H, W = src0.shape[:2]
A, G, Hc = (6, 7, 15), (22, 37, 52), (49, 59, 70)                     # i colori del guanto
ORO, ORO_SCURO = (250, 214, 129), (202, 153, 78)                      # le maniglie: l'oro del cerchio
CORDA, SCIA = (251, 217, 213), (196, 166, 177)                        # la corda chiara e la sua scia
# ---- le mani a pugno con la maniglia (la sinistra disegnata, la destra allo specchio: le braccia lo sono gia')
src = src0.copy()
for y in range(55, 62):
    for x in range(0, 11):
        src[y, x] = 0; src[y, 39 - x] = 0
PUGNO = {55: {2: A, 3: Hc, 4: G, 5: G, 6: G, 7: G, 8: G, 9: A},
         56: {2: A, 3: Hc, 4: G, 5: G, 6: G, 7: G, 8: A},
         57: {2: A, 3: G, 4: G, 5: G, 6: G, 7: A},
         58: {3: A, 4: A, 5: ORO_SCURO, 6: A},
         59: {5: ORO},
         60: {5: ORO_SCURO}}
for y, riga in PUGNO.items():
    for x, c in riga.items():
        src[y, x, :3] = c; src[y, x, 3] = 255
        src[y, 39 - x, :3] = c; src[y, 39 - x, 3] = 255
# ---- la bocca: solo un punto, aperta quel poco che basta per respirare (era un trattino alla riga 38, x 16-19)
for x in (16, 18, 19):
    src[38, x, :3] = (212, 165, 122)                                   # pelle
src[38, 17, :3] = (74, 26, 52)                                        # il punto scuro della bocca aperta
op = src[..., 3] > 0
Y, X = np.mgrid[0:H, 0:W]
coda = op & (Y <= 13)
ciocche = op & (Y >= 36) & (Y <= 45) & ((X <= 9) | (X >= 29))
braccia = op & (Y >= 46) & (Y <= 61) & ((X <= 11) | (X >= 28))
gambe = op & (Y >= 59) & ~braccia
corpo = op & ~coda & ~ciocche & ~braccia & ~gambe
# ---- le gambe: pose fatte riga per riga dalle gambe di Lei ferma (righe 59-72: l'anca, le cosce, gli stivali).
# per ogni posa le righe di partenza dalla 60 in giu' (con quanto il ginocchio va in fuori), poi il piede se cambia
COL = {'l': (6, 7, 15), 'h': (22, 37, 52), 'n': (49, 59, 70), 'm': (69, 79, 85),     # stivali
       'e': (212, 165, 122), 'c': (190, 131, 114), 'd': (157, 103, 102)}                     # pelle
PIEDI = {   # (piede sinistro da x 12, piede destro da x 20), sotto la caviglia (riga 70)
    'punta_terra': (['.lhhl..', 'lhnl...', 'lll....'], ['....lnnl', '....lhnl', '....llll']),   # tallone su, punta a terra
    'punta':       (['.lhhl..', '.lhl...', '.ll....'], ['....lnhl', '.....lnl', '.....ll.']),   # in aria, punta in giu'
}
R = lambda a, b: [(r, 0) for r in range(a, b)]
POSE = {
    # a terra le ginocchia piegate vanno verso il centro (-1) e si toccano
    'piegata':    dict(righe=R(60, 63) + [(63, -1), (64, -1), (65, -1)] + R(66, 68) + R(69, 73)),
    'accosciata': dict(righe=R(60, 62) + [(62, -1), (63, -1), (65, -1), (66, -1)] + R(67, 68) + R(69, 73), lucido={63}),
    'punte':      dict(righe=R(60, 71), piede='punta_terra'),
    'tesa':       dict(righe=R(60, 71), piede='punta'),
    'mezza':      dict(righe=R(60, 66) + [(67, 0), (69, 0), (70, 0)], piede='punta', lucido={63}),
    # ginocchia su: le cosce si alzano verso di noi (si vede piu' pelle sopra lo stivale, il bordo dritto),
    # il ginocchio prende la luce, lo stinco pende sotto corto, la punta in giu'. Disegnata dalla riga 60
    'su':         dict(disegno=(['deeeecd', 'deeeecd', 'lllllll', 'lnmmnhl', 'lhnmhhl', 'lhhhhhl',
                                 '.lhnhl.', '.lhhl..', '..lhl..', '..ll...'],
                                ['dceeeecd', 'dceeeecd', 'llllllll', '.lnmmnhl', '.lhnmhhl', '.lhhhhhl',
                                 '..lhnhl.', '..lhhl..', '...lhl..', '...ll...'])),
}
LUNGA = lambda p: 1 + (len(POSE[p]['disegno'][0]) if 'disegno' in POSE[p] else
                       len(POSE[p]['righe']) + (len(PIEDI[POSE[p]['piede']][0]) if 'piede' in POSE[p] else 0))
#        0          1        2       3        4           5        6        7     (la corda: 0 sopra la testa,
GAMBE = ['piegata', 'punte', 'tesa', 'mezza', 'su', 'mezza', 'punte', 'accosciata']         # 2 davanti, 4 sotto i
PIEDI_SU = [0, 0, 1, 4, 7, 4, 0, 0]                                                       # piedi, 6 dietro)
SALTO = [LUNGA(GAMBE[k]) - 14 + PIEDI_SU[k] for k in range(8)]     # quanto sale il corpo: gambe + salto
BUSTO = [0, 0, 1, 0, 0, 0, 0, -1]      # il busto si allunga quando stacca e si schiaccia quando atterra (la pancia)
SENO = [0, 0, -1, -1, 1, 1, 0, -1]     # rimbalza di un pixel: resta indietro quando stacca, sale in cima, scende all'atterraggio
SENO_RIGHE, SENO_X = (44, 48), (12, 23)
POLSI = [round(math.cos(math.radians(45 * k))) for k in range(8)]
DUR = 50
MS, MD, MA, MB = 12, 12, 10, 8           # margini della tela: sinistra, destra, sopra, sotto
CW, CH = W + MS + MD, H + MA + MB


def lineare(r, r0, d0, r1, d1):
    t = np.clip((r - r0) / float(r1 - r0), 0, 1)
    return d0 + (d1 - d0) * t


def posa(out, parte, dy_di, dx=0, per_x=False):
    for x in range(W):
        rr = np.nonzero(parte[:, x])[0]
        prima = None
        for r in rr:
            dest = r - int(np.floor((dy_di(r, x) if per_x else dy_di(r)) + 0.5))
            if prima is not None and prima[0] == r - 1 and dest - prima[1] == 2:
                out[dest - 1 + MA, x + MS + dx] = src[r - 1, x]
            if 0 <= dest + MA < CH:
                out[dest + MA, x + MS + dx] = src[r, x]
            prima = (r, dest)


def arco(theta, mani_y):
    # la corda vista di fronte: mezza ellisse fra le due maniglie, col colmo che sale e scende col giro
    xl, xr = 5 + MS, 34 + MS
    y0 = mani_y
    c = math.cos(math.radians(theta))
    colmo = y0 - 67 * c if c >= 0 else y0 + 11 * (-c)
    cx, hw = (xl + xr) / 2.0, (xr - xl) / 2.0
    gonfio = 7 * abs(c)                  # la corda e' lunga: sopra la testa e sotto i piedi si allarga oltre le mani
    pts = []
    for i in range(0, 721):
        f = math.pi * i / 720
        x = int(math.floor(cx - (hw + gonfio * math.sin(f)) * math.cos(f) + 0.5))
        y = int(math.floor(y0 + (colmo - y0) * math.sin(f) + 0.5))
        if not pts or pts[-1] != (x, y):
            pts.append((x, y))
    # pixel perfetto: via gli angoli a L, guardando la linea gia' pulita (se no a ogni gradino
    # sparivano tutti e due i pixel dell'angolo e la corda veniva tratteggiata)
    puliti = []
    for p in pts:
        if len(puliti) >= 2:
            a = puliti[-2]
            if abs(a[0] - p[0]) == 1 and abs(a[1] - p[1]) == 1:
                puliti.pop()
        puliti.append(p)
    return puliti


def disegna_gambe(out, p, j):
    y = 59 - j + MA
    for x in range(12, 28):                                              # l'anca resta col corpo
        if gambe[59, x]:
            out[y, x + MS] = src[59, x]
    for lato, xs, verso in ((0, range(12, 19), -1), (1, range(20, 28), 1)):
        yy = y + 1
        for riga in (p['disegno'][lato] if 'disegno' in p else ()):
            for i, ch in enumerate(riga):
                if ch != '.':
                    out[yy, xs[0] + i + MS, :3] = COL[ch]; out[yy, xs[0] + i + MS, 3] = 255
            yy += 1
        for r, fuori in p.get('righe', ()):
            for x in xs:
                if gambe[r, x]:
                    c = src[r, x].copy()
                    if r in p.get('lucido', ()) and tuple(c[:3]) == COL['n']:
                        c[:3] = COL['m']                                 # il ginocchio piegato prende la luce
                    out[yy, x + MS + verso * fuori] = c
            yy += 1
        for riga in (PIEDI[p['piede']][lato] if 'piede' in p else ()):
            for i, ch in enumerate(riga):
                if ch != '.':
                    out[yy, xs[0] + i + MS, :3] = COL[ch]; out[yy, xs[0] + i + MS, 3] = 255
            yy += 1


def disegna_corda(out, punti, col, solo_vuoto=False):
    for x, y in punti:
        if 0 <= x < CW and 0 <= y < CH and (not solo_vuoto or out[y, x, 3] == 0):
            out[y, x, :3] = col; out[y, x, 3] = 255


fot = []
for k in range(8):
    th = 45 * k
    j, pl, jp = SALTO[k], POLSI[k], SALTO[k - 1]
    s, sp, b = BUSTO[k], BUSTO[k - 1], SENO[k]
    lei = np.zeros((CH, CW, 4), np.uint8)
    disegna_gambe(lei, POSE[GAMBE[k]], j)
    seno = lambda r, x: b if SENO_RIGHE[0] <= r <= SENO_RIGHE[1] and SENO_X[0] <= x <= SENO_X[1] else 0
    posa(lei, corpo, lambda r, x: (j + s + seno(r, x)) if r <= 52 else j, per_x=True)   # la riga 52 e' la pancia
    posa(lei, ciocche, lambda r: lineare(r, 36, j + s, 45, jp + sp))
    posa(lei, coda, lambda r: lineare(r, 13, j + s, 0, jp + sp))
    posa(lei, braccia, lambda r: lineare(r, 46, j + s, 60, j + s + pl))
    mani_y = 61 + MA - (j + s + pl)
    dietro = 180 < th % 360 or th % 360 == 0                             # sopra la testa e dietro: dietro a lei
    out = np.zeros((CH, CW, 4), np.uint8)
    scia = arco(th - 20, mani_y)
    corda = arco(th, mani_y)
    dietro_scia = 180 < (th - 20) % 360 or (th - 20) % 360 == 0
    if dietro_scia:
        disegna_corda(out, scia, SCIA)
    if dietro:
        disegna_corda(out, corda, CORDA)
    m = lei[..., 3] > 0
    out[m] = lei[m]
    if not dietro_scia:
        disegna_corda(out, scia, SCIA)
    if not dietro:
        disegna_corda(out, corda, CORDA)
    fot.append(out)
striscia = np.concatenate(fot, axis=1)
Image.fromarray(striscia, 'RGBA').save(sys.argv[2])
z = 5
gif = []
for f in fot:
    im = Image.new('RGB', (CW * z, CH * z), (60, 96, 62))
    g = Image.fromarray(f, 'RGBA').resize((CW * z, CH * z), Image.NEAREST)
    im.paste(g, (0, 0), g); gif.append(im)
gif[0].save(sys.argv[3], save_all=True, append_images=gif[1:], duration=DUR, loop=0)
fg = Image.new('RGB', (8 * (CW * z + 10), CH * z), (40, 40, 48))
for k, im in enumerate(gif):
    fg.paste(im, (k * (CW * z + 10), 0))
fg.save(sys.argv[4])
print('fatto', striscia.shape, 'polsi', POLSI)
