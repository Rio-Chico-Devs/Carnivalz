"""i pezzi dei riferimenti (gia' ridotti alla misura vera) coi nostri colori: ogni oggetto separato; i pixel divisi in
contorno, foglie, legno, pietra; i toni di ogni materiale ritrovati (pochi, per luce) e messi sui gradini delle nostre
rampe nello stesso ordine; il contorno tutto attorno col nostro scuro; via i pixel soli rimasti dal JPG.
uso: ricolora.py repo ridotta.png cartella_uscita nome1 nome2 ...   (i nomi degli oggetti da sinistra a destra,
     dall'alto in basso)"""
import os
import sys
import numpy as np
from PIL import Image

REPO, SRC, OUT = sys.argv[1:4]
NOMI = sys.argv[4:]
sys.path.append(os.path.join(REPO, 'strumenti'))
sys.path.append(os.path.join(REPO, 'strumenti', 'livelli'))
import tavolozza as tv  # noqa: E402

R = tv.tavolozze()
CHIOMA = [(47, 41, 67), (55, 60, 82), (63, 104, 106), (73, 141, 108), (117, 170, 103), (161, 195, 118), (199, 220, 138)]
TRONCO = [(69, 62, 116), (110, 64, 100), (130, 66, 93), (172, 105, 88)]
PIETRA = R['pietra']
SCURO = (47, 41, 67)


def oklab(c):
    L, C, h = tv.oklch(np.asarray(c, float).reshape(-1, 3)).T
    return np.stack([L, C * np.cos(np.radians(h)), C * np.sin(np.radians(h))], 1)


def kmedie(X, k, it=40):
    """k-medie semplici, partendo dai quantili della luce"""
    ordine = np.argsort(X[:, 0])
    cen = np.array([X[ordine[int((i + 0.5) / k * len(X))]] for i in range(k)])
    for _ in range(it):
        d = ((X[:, None, :] - cen[None]) ** 2).sum(2)
        lab = d.argmin(1)
        for j in range(k):
            if (lab == j).any():
                cen[j] = X[lab == j].mean(0)
    return lab, cen


def assegna(lc, lr):
    """i toni (luci lc, dal piu' scuro) sui gradini della rampa (luci lr): in ordine, ognuno sul suo, la luce piu'
    vicina possibile (programmazione dinamica)"""
    k, n = len(lc), len(lr)
    INF = 1e9
    D = np.full((k + 1, n + 1), INF)
    D[0, :] = 0
    scelta = np.zeros((k + 1, n + 1), int)
    for i in range(1, k + 1):
        for j in range(i, n + 1):
            # il tono i sul gradino j-1, i precedenti su gradini prima
            prima = D[i - 1, :j].min() if j > 0 else INF
            jj = int(D[i - 1, :j].argmin()) if j > 0 else 0
            D[i, j] = prima + abs(lc[i - 1] - lr[j - 1])
            scelta[i, j] = jj
    j = int(D[k, 1:].argmin()) + 1
    out = [0] * k
    for i in range(k, 0, -1):
        out[i - 1] = j - 1
        j = scelta[i, j]
    return out


def pezzi(op):
    H, W = op.shape
    visti = np.zeros_like(op)
    out = []
    for y, x in zip(*np.nonzero(op)):
        if visti[y, x]:
            continue
        pila, pz = [(y, x)], []
        visti[y, x] = True
        while pila:
            a, b = pila.pop()
            pz.append((a, b))
            for c, d in ((a + 1, b), (a - 1, b), (a, b + 1), (a, b - 1), (a + 1, b + 1), (a - 1, b - 1), (a + 1, b - 1),
                         (a - 1, b + 1)):
                if 0 <= c < H and 0 <= d < W and op[c, d] and not visti[c, d]:
                    visti[c, d] = True
                    pila.append((c, d))
        if len(pz) > 40:
            out.append(pz)
    return out


img = np.asarray(Image.open(SRC).convert('RGBA'))
op = img[..., 3] > 0
largo = op.copy()
for _ in range(3):
    p_ = np.pad(largo, 1)
    largo = largo | p_[:-2, 1:-1] | p_[2:, 1:-1] | p_[1:-1, :-2] | p_[1:-1, 2:]
oggetti = [[q for q in pz if op[q]] for pz in pezzi(largo)]
# in ordine: per righe (in alto prima), poi da sinistra
oggetti.sort(key=lambda pz: (min(p[0] for p in pz) // 40, min(p[1] for p in pz)))
os.makedirs(OUT, exist_ok=True)
for nome, pz in zip(NOMI, oggetti):
    ys, xs = np.array([p[0] for p in pz]), np.array([p[1] for p in pz])
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    m = np.zeros((y1 - y0, x1 - x0), bool)
    m[ys - y0, xs - x0] = True
    rgb = img[y0:y1, x0:x1, :3].astype(float)
    lab = oklab(rgb[m])
    L, a, b = lab.T
    C = np.hypot(a, b)
    h = (np.degrees(np.arctan2(b, a)) + 360) % 360
    # il contorno: il bordo del disegno e i pixel scurissimi
    pad = np.pad(m, 1)
    bordo = m & (~pad[:-2, 1:-1] | ~pad[2:, 1:-1] | ~pad[1:-1, :-2] | ~pad[1:-1, 2:])
    scuro = np.zeros(m.shape, bool)
    scuro[m] = L < 0.33
    contorno = bordo | scuro
    # i materiali: legno (rossi e bruni), foglie (verdi), pietra (grigi e azzurri)
    mat = np.full(m.shape, '', dtype='<U6')
    if 'roccia' in nome or 'rocce' in nome:
        tmp = np.full(L.shape, 'pietra')
    elif 'salice' in nome or 'albero' in nome:
        tmp = np.where(((h < 75) | (h > 300)) & (C > 0.025), 'legno', 'foglie')
    else:
        tmp = np.full(L.shape, 'foglie')
    mat[m] = tmp
    out = np.zeros((y1 - y0, x1 - x0, 4), np.uint8)
    for materiale, rampa, k, gradini in (('foglie', CHIOMA, 5, [1, 2, 3, 4, 5, 6]), ('legno', TRONCO, 3, [0, 1, 2, 3]),
                                          ('pietra', PIETRA, 5, [0, 1, 2, 3, 4, 5])):
        sel = m & (mat == materiale) & ~contorno
        if sel.sum() < 12:
            continue
        kk = min(k, max(1, sel.sum() // 30))
        X = oklab(rgb[sel])
        lab_, cen = kmedie(X, kk)
        ordine = np.argsort(cen[:, 0])                  # dal piu' scuro al piu' chiaro
        lr = oklab([rampa[g_] for g_ in gradini])[:, 0]
        dove = assegna(cen[ordine, 0], lr)              # ogni tono sul gradino con la luce piu' vicina, in ordine
        a_tono = {}
        for pos_, c_ in enumerate(ordine):
            a_tono[c_] = gradini[dove[pos_]]
        ys_, xs_ = np.nonzero(sel)
        for (yy, xx), l in zip(zip(ys_, xs_), lab_):
            out[yy, xx, :3] = rampa[a_tono[l]]
            out[yy, xx, 3] = 255
    out[contorno, :3] = SCURO
    out[contorno, 3] = 255
    # niente pixel soli (dentro, non sul contorno): prendono il colore piu' comune dei quattro vicini
    for _ in range(2):
        col = out[..., :3].astype(int)
        chiave = col[..., 0] * 65536 + col[..., 1] * 256 + col[..., 2]
        p = np.pad(chiave, 1, constant_values=-1)
        vic = np.stack([p[:-2, 1:-1], p[2:, 1:-1], p[1:-1, :-2], p[1:-1, 2:]])
        soli = m & ~contorno & ~np.any(vic == chiave[None], axis=0)
        for yy, xx in zip(*np.nonzero(soli)):
            v = [int(t) for t in vic[:, yy, xx] if t >= 0 and t != SCURO[0] * 65536 + SCURO[1] * 256 + SCURO[2]]
            if v:
                c = max(set(v), key=v.count)
                out[yy, xx, :3] = (c >> 16, (c >> 8) & 255, c & 255)
    Image.fromarray(out, 'RGBA').save(os.path.join(OUT, nome + '.png'))
    piede = (int((x1 - x0) // 2), int(y1 - y0 - 1))
    with open(os.path.join(OUT, nome + '.json'), 'w') as f:
        f.write('{"piede": [%d, %d]}\n' % piede)
    print(nome, '%dx%d' % (x1 - x0, y1 - y0), 'alla posizione', (int(x0), int(y0)), 'colori',
          len(np.unique(out[m][:, :3], axis=0)))
