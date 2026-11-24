"""L'acqua dei pezzi, a fotogrammi: le vasche a gradini (cascatelle che scendono, spruzzi, acqua che ondeggia),
la vasca di pietra (acqua che ondeggia), la pozza coi sassi (ondeggia; presa dalla mappa finita).
uso: pezzi_anim.py acqua.npz uscita_cartella"""
import sys, os, json
import numpy as np
from PIL import Image
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
NPZ, OUT = sys.argv[1:3]
LIV = os.path.join(REPO, 'art/livelli')
FUSI = 'pezzi/ruscello/fusi/'          # i pezzi della mappa del ruscello, col contorno fuso nel terreno


def carica(nome, cartella=FUSI):
    return np.asarray(Image.open(os.path.join(LIV, cartella + nome + '.png')).convert('RGBA')).astype(int)


def erodi(m):
    e = m.copy()
    e[1:] &= m[:-1]; e[:-1] &= m[1:]; e[:, 1:] &= m[:, :-1]; e[:, :-1] &= m[:, 1:]
    return e


def ondeggia(src, out, dentro, f, N, lam, cicli=1, escludi=None):
    # ogni riga dell'acqua si sposta di -1, 0 o +1 pixel: un'onda che scende piano (i colori sono solo i suoi)
    H, W = dentro.shape
    for y in range(H):
        d = int(np.floor(np.sin(2 * np.pi * (y / lam - cicli * f / N)) + 0.5))
        if d == 0:
            continue
        for x in range(W):
            if dentro[y, x] and (escludi is None or not escludi[y, x]):
                xs = x + d
                if 0 <= xs < W and dentro[y, xs]:
                    out[y, x] = src[y, xs]


def striscia(fot):
    h, w = fot[0].shape[:2]
    s = np.zeros((h, w * len(fot), 4), np.uint8)
    for k, f in enumerate(fot):
        s[:, k * w:(k + 1) * w] = f
    return s


info = {}
# ------------------------------------------------------------ le vasche a gradini
a = carica('vasche_gradini')
r, g, b, al = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
acqua = (al > 0) & (g >= 110) & (g > r + 60)
dentro = erodi(acqua)
CADUTE = [(56, 63, 29, 38), (28, 35, 57, 66), (56, 63, 57, 71)]          # x0, x1, y0, y1 (compresi)
SPRUZZI = [(50, 69, 39, 45), (26, 40, 67, 72), (53, 66, 72, 76)]
fermi = np.zeros(acqua.shape, bool)
for (x0, x1, y0, y1) in CADUTE + SPRUZZI:
    fermi[y0:y1 + 1, x0:x1 + 1] = True
N = 30
fot = []
for f in range(N):
    o = a.copy()
    ondeggia(a, o, dentro, f, N, lam=7, cicli=2, escludi=fermi)
    for (x0, x1, y0, y1) in CADUTE:
        h = y1 - y0 + 1
        for y in range(y0, y1 + 1):
            o[y, x0:x1 + 1] = a[y0 + ((y - y0 - f) % h), x0:x1 + 1]
    f2 = f // 2
    for (x0, x1, y0, y1) in SPRUZZI:
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if acqua[y, x]:
                    xs = x + ((x * 7 + y * 3 + f2) % 3) - 1
                    if x0 <= xs <= x1 and acqua[y, xs]:
                        o[y, x] = a[y, xs]
    fot.append(o.astype(np.uint8))
Image.fromarray(striscia(fot), 'RGBA').save(os.path.join(OUT, 'vasche_gradini_anim.png'), optimize=True)
info[FUSI + 'vasche_gradini.png'] = {'file': 'vasche_gradini_anim.png', 'n': N, 'ms': 70}
# ------------------------------------------------------------ la vasca di pietra
a = carica('vasca_pietra')
r, g, b, al = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
acqua = (al > 0) & (g >= 130) & (b >= 120) & (g > r + 80)
dentro = erodi(acqua)
N = 24
fot = []
for f in range(N):
    o = a.copy()
    ondeggia(a, o, dentro, f, N, lam=6, cicli=1)
    fot.append(o.astype(np.uint8))
Image.fromarray(striscia(fot), 'RGBA').save(os.path.join(OUT, 'vasca_pietra_anim.png'), optimize=True)
info[FUSI + 'vasca_pietra.png'] = {'file': 'vasca_pietra_anim.png', 'n': N, 'ms': 100}
# ------------------------------------------------------------ la pozza coi sassi (e' dentro la mappa)
d = np.load(NPZ)
mappa = d['mappa'].astype(int)
p = carica('sassi_pozza', 'pezzi/radenna/')
r, g, b, al = p[..., 0], p[..., 1], p[..., 2], p[..., 3]
acqua_p = (al > 0) & (b - r >= 20) & (g - r >= 35)
px, py = 83, 82
X0, Y0 = 180 - px, 436 - py
h, w = acqua_p.shape
reg = mappa[Y0:Y0 + h, X0:X0 + w].copy()
# solo dove la mappa ha davvero la pozza (il pezzo e' posato solo sul prato e sulla riva)
fin = np.zeros((h, w, 4), int); fin[..., :3] = reg; fin[..., 3] = 255
dentro = erodi(acqua_p)
N = 24
fot = []
for f in range(N):
    o = fin.copy()
    ondeggia(fin, o, dentro, f, N, lam=5, cicli=1)
    o[..., 3] = np.where(acqua_p, 255, 0)
    fot.append(o.astype(np.uint8))
Image.fromarray(striscia(fot), 'RGBA').save(os.path.join(OUT, 'pozza_anim.png'), optimize=True)
info['pozza'] = {'file': 'pozza_anim.png', 'n': N, 'ms': 110, 'x': int(X0), 'y': int(Y0), 'w': int(w), 'h': int(h)}
with open(os.path.join(OUT, 'pezzi_anim.json'), 'w') as f:
    json.dump(info, f, indent=1)
print(json.dumps(info))
