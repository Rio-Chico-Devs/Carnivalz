"""Il prato con la tecnica degli esempi di Bru (108), in quattro passi:
1. la base piatta;
2. le macchie larghe a nuvola (allungate in orizzontale, coi bordi a scaletta) in due toni piu' scuri;
3. i bordi delle macchie spezzati in foglioline oblique, tutte piegate nello stesso verso: dal chiaro sporgono foglie
   della macchia, dentro la macchia restano foglie chiare, e dentro c'e' la trama di foglie del tono vicino; sul chiaro
   qualche ciuffo di due o tre foglioline;
4. le luci giallo-verdi (ventagli di foglie) sul chiaro, i fiori bianchi col cuore giallo a gruppetti, gli accenti
   scurissimi nel cuore delle macchie.
Poi via i pixel soli. Le tinte: A gli esempi di Bru (chiaro), B una via di mezzo, C scuro come il prato di adesso.

modulo: prato(h, w, seme, tav) -> (i 4 passi (h, w, 3) uint8, i livelli delle macchie)
uso: prato.py cartella_livelli cartella_prove   (i quattro passi e lo stesso pezzo della mappa del ruscello nelle tre
     tinte, accanto a com'e' ora)"""
import numpy as np
from PIL import Image

# le tinte: base, medio, scuro, profondo (le macchie), luce, petalo e cuore (i fiori)
TINTE = {
    'A': {'base': (161, 220, 110), 'medio': (89, 160, 116), 'scuro': (74, 109, 111), 'profondo': (53, 62, 78),
          'luce': (213, 252, 135), 'petalo': (252, 255, 232), 'cuore': (246, 228, 146)},
    'B': {'base': (128, 190, 88), 'medio': (70, 138, 98), 'scuro': (56, 92, 96), 'profondo': (42, 50, 68),
          'luce': (190, 232, 118), 'petalo': (244, 248, 226), 'cuore': (240, 214, 128)},
    'C': {'base': (44, 108, 46), 'medio': (26, 82, 56), 'scuro': (20, 60, 58), 'profondo': (17, 39, 48),
          'luce': (104, 156, 60), 'petalo': (226, 232, 206), 'cuore': (226, 196, 108)},
}
# le foglioline oblique, piegate in giu' verso destra come negli esempi (una tinta sola)
FOGLIE = [['XXX.', '.XXX'], ['XXX.', '.XXX'], ['XX.', '.XX'], ['XXX..', '.XXX.', '..XX.']]
# le luci: ventagli di tre foglie col gambo
LUCI = [['XX.XX', 'XXXXX', '.XXX.', '..X..'],
        ['XXX..', '.XX.X', '..XXX', '..X..'],
        ['..XXX', 'X.XX.', 'XXX..', '..X..']]
# il fiore: quattro petali agli angoli, il cuore giallo
FIORE = ['PP.PP', 'PCCCP', '.CCC.', 'PCCCP', 'PP.PP']


def liscio(h, w, sx, sy, seme):
    # rumore liscio, allungato in orizzontale (sx > sy): le macchie larghe a nuvola
    g = np.random.default_rng(seme).random((h // sy + 4, w // sx + 4))
    big = Image.fromarray((g * 255).astype(np.uint8)).resize(((w // sx + 4) * sx, (h // sy + 4) * sy), Image.BICUBIC)
    return np.asarray(big)[sy:sy + h, sx:sx + w] / 255.0


def timbra(img, forma, x0, y0, colore, dove=None):
    h, w = img.shape[:2]
    for j, r in enumerate(forma):
        for i, ch in enumerate(r):
            if ch == '.':
                continue
            y, x = y0 + j, x0 + i
            if 0 <= y < h and 0 <= x < w and (dove is None or dove[y, x]):
                img[y, x] = colore if not isinstance(colore, dict) else colore[ch]


def pulisci(img):
    # i pixel soli: se i quattro vicini sono tutti dello stesso colore (e lui no), prende quel colore
    for _ in range(2):
        a = img.astype(int)
        su, giu = np.roll(a, 1, 0), np.roll(a, -1, 0)
        sx, dx = np.roll(a, 1, 1), np.roll(a, -1, 1)
        uguali = np.all(su == giu, -1) & np.all(su == sx, -1) & np.all(su == dx, -1) & ~np.all(su == a, -1)
        uguali[0] = uguali[-1] = False; uguali[:, 0] = uguali[:, -1] = False
        img[uguali] = su[uguali].astype(np.uint8)


def distanza(m, fino):
    # passi (in 8 direzioni) dal pixel piu' vicino di m, fino a 'fino'
    d = np.full(m.shape, fino + 1, int)
    d[m] = 0
    b = m.copy()
    for k in range(1, fino + 1):
        g = b.copy()
        g[1:] |= b[:-1]; g[:-1] |= b[1:]; g[:, 1:] |= b[:, :-1]; g[:, :-1] |= b[:, 1:]
        g[1:, 1:] |= b[:-1, :-1]; g[:-1, :-1] |= b[1:, 1:]; g[1:, :-1] |= b[:-1, 1:]; g[:-1, 1:] |= b[1:, :-1]
        d[g & (d > fino)] = k
        b = g
    return d


def prato(h, w, seme=1, tav=TINTE['A'], scuro=0.42):
    rng = np.random.default_rng(seme)
    T = {k: np.array(v, np.uint8) for k, v in tav.items()}
    passi = []
    # 1. la base piatta
    img = np.zeros((h, w, 3), np.uint8); img[:] = T['base']
    passi.append(img.copy())
    # 2. le macchie: due livelli di scuro sul rumore allungato; 'scuro' e' quanta parte del prato e' in ombra
    F = liscio(h, w, 64, 14, seme) * 0.6 + liscio(h, w, 24, 7, seme + 1) * 0.4
    t1, t2 = np.quantile(F, [1 - scuro, 1 - scuro * 0.36])
    liv = (F >= t1).astype(int) + (F >= t2).astype(int)
    col = [T['base'], T['medio'], T['scuro']]
    for k in (1, 2):
        img[liv == k] = col[k]
    passi.append(img.copy())
    # 3. le foglioline sui bordi e dentro le macchie, i ciuffi sul chiaro
    out = img.copy()
    PF = {1: (0.62, 0.46, 0.26), 2: (0.55, 0.4, 0.2)}           # foglie che sporgono, a distanza 1, 2, 3 dal bordo
    PD = {1: (0.45, 0.3, 0.15), 2: (0.4, 0.26, 0.12)}           # foglie chiare dentro, a distanza 1, 2, 3
    for k in (1, 2):
        dentro = liv >= k
        d_fuori = distanza(dentro, 4)
        d_dentro = distanza(~dentro, 5)
        n = int(h * w / 7)
        ys = rng.integers(0, h, n); xs = rng.integers(0, w, n)
        for y, x in zip(ys, xs):
            f = FOGLIE[rng.integers(len(FOGLIE))]
            df, dd = d_fuori[y, x], d_dentro[y, x]
            if 1 <= df <= 3 and rng.random() < PF[k][df - 1]:
                timbra(out, f, x - 1, y - 1, col[k], ~dentro | (liv == k))
            elif 1 <= dd <= 3 and rng.random() < PD[k][dd - 1]:
                timbra(out, f, x - 1, y - 1, col[k - 1], liv == k)
            elif dd > 2 and liv[y, x] == k and rng.random() < (0.2 if k == 1 else 0.1):
                # la trama dentro la macchia: foglie dello scuro (nel medio) o del medio (nello scuro)
                timbra(out, f, x - 1, y - 1, col[2] if k == 1 else col[1], liv == k)
    chiaro = (liv == 0) & (distanza(liv > 0, 3) > 3)
    for _ in range(int(h * w / 240)):
        y, x = rng.integers(0, h), rng.integers(0, w)
        if chiaro[y, x]:
            # un ciuffo: due o tre foglioline una sotto l'altra, spostate in diagonale
            for _ in range(rng.integers(2, 4)):
                timbra(out, FOGLIE[rng.integers(3)], x, y, T['medio'], chiaro)
                x += int(rng.integers(-3, 2)); y += int(rng.integers(1, 3))
    pulisci(out)
    passi.append(out.copy())
    # 4. le luci sul chiaro, i fiori a gruppetti, gli accenti scurissimi nel cuore delle macchie
    libero = np.all(out == T['base'], axis=-1)
    libero_l = distanza(~libero, 2) > 2
    for _ in range(int(h * w / 420)):
        y, x = rng.integers(0, h), rng.integers(0, w)
        if libero_l[y, x]:
            timbra(out, LUCI[rng.integers(len(LUCI))], x - 2, y - 2, T['luce'], libero)
    libero = np.all(out == T['base'], axis=-1)
    libero_f = distanza(~libero, 2) > 1
    for _ in range(int(h * w / 2200)):
        y, x = rng.integers(0, h), rng.integers(0, w)
        for _ in range(rng.integers(1, 4)):
            yy, xx = y + rng.integers(-6, 7), x + rng.integers(-7, 8)
            if 0 <= yy < h and 0 <= xx < w and libero_f[yy, xx]:
                timbra(out, FIORE, xx - 2, yy - 2, {'P': T['petalo'], 'C': T['cuore']})
                libero_f[max(0, yy - 5):yy + 6, max(0, xx - 5):xx + 6] = False
    cuore = (liv == 2) & (distanza(liv < 2, 6) > 4)
    for _ in range(int(h * w / 40)):
        y, x = rng.integers(0, h), rng.integers(0, w)
        if cuore[y, x] and rng.random() < 0.35:
            timbra(out, FOGLIE[rng.integers(len(FOGLIE))], x - 1, y - 1, T['profondo'], cuore)
    pulisci(out)
    passi.append(out)
    return passi, liv


if __name__ == '__main__':
    import json
    import os
    import sys

    from PIL import ImageDraw

    L, OUT = sys.argv[1], sys.argv[2]
    # i quattro passi, come nell'esempio di Bru
    p4, _ = prato(80, 80, seme=4)
    z = 4
    tela = Image.new('RGB', (4 * 80 * z + 3 * 8, 80 * z), (47, 41, 67))
    for i, p in enumerate(p4):
        tela.paste(Image.fromarray(p).resize((80 * z, 80 * z), Image.NEAREST), (i * (80 * z + 8), 0))
    tela.save(os.path.join(OUT, 'prato_passi.png'))
    # lo stesso pezzo della mappa del ruscello: com'e' ora e col prato nuovo nelle tre tinte (i pixel d'erba sono
    # quelli dei verdi del prato di adesso; sopra, i pezzi in piedi)
    VERDI = {(3, 47, 32), (5, 56, 34), (6, 62, 35), (8, 67, 35), (12, 72, 35), (14, 78, 35), (20, 83, 35),
             (25, 89, 35), (34, 97, 38), (44, 106, 42), (64, 112, 60)}
    m = np.asarray(Image.open(os.path.join(L, 'ruscello.png')).convert('RGB')).copy()
    erba = np.zeros(m.shape[:2], bool)
    for c in VERDI:
        erba |= np.all(m == c, axis=-1)
    x0, y0, x1, y1 = 480, 520, 740, 690
    pz = json.load(open(os.path.join(L, 'ruscello_pezzi.json'), encoding='utf-8'))['pezzi']

    def con_pezzi(base):
        im = Image.fromarray(base).convert('RGBA')
        for f, xw, yw, xd, yd in sorted(pz, key=lambda q: q[2]):
            im.alpha_composite(Image.open(os.path.join(L, f)).convert('RGBA'), (int(xw - xd), int(yw - yd)))
        return im.convert('RGB').crop((x0, y0, x1, y1)).resize(((x1 - x0) * 2, (y1 - y0) * 2), Image.NEAREST)

    pannelli = [('ora', con_pezzi(m))]
    sub = (slice(y0 - 20, y1 + 20), slice(x0 - 20, x1 + 20))
    p4, _ = prato(y1 - y0 + 40, x1 - x0 + 40, seme=11)
    ruoli = {k: np.all(p4[3] == np.array(v, np.uint8), axis=-1) for k, v in TINTE['A'].items()}
    for nome in ('A', 'B', 'C'):
        p = np.zeros_like(p4[3])
        for k, msk in ruoli.items():
            p[msk] = TINTE[nome][k]
        nuova = m.copy()
        blocco = nuova[sub]; e = erba[sub]
        blocco[e] = p[e]
        nuova[sub] = blocco
        pannelli.append((nome, con_pezzi(nuova)))
    w, h = pannelli[0][1].size
    tela = Image.new('RGB', (4 * w + 30, h + 26), (47, 41, 67))
    d = ImageDraw.Draw(tela)
    for i, (nome, im) in enumerate(pannelli):
        tela.paste(im, (i * (w + 10), 26))
        d.text((i * (w + 10) + 8, 6), nome, fill=(240, 240, 240))
    tela.save(os.path.join(OUT, 'prato_tinte.png'))
    print('fatto: prato_passi.png, prato_tinte.png')
